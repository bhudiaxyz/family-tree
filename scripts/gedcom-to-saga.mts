// Convert a GEDCOM file into a saga data file (SagaFile JSON, families inline) for public/data/<category>/<id>.json, and add it to
// sagas.json. Repeatable: re-running replaces the saga's file and manifest entry.
//
//   npm run import:gedcom -- <file.ged | https://…> --id english-royal --category history --title "English Royal Family (Tudors)"
//
// The input can be a local path or an https:// URL; a GitHub page link is fetched as its raw file (gedcom-source.mts).
//
// The app's own parser (src/data/gedcom.ts) builds the family structure; this script adds what a *stored* saga needs
// and the in-browser import doesn't: clean display names (a monarch by their regnal name, everyone else by name only),
// stable readable ids, a manageable set of house colours, and source/notes metadata.
//
// Input is untrusted text: it is only ever parsed, never executed, and the output is plain JSON.
import fs from "node:fs";
import path from "node:path";
import {
    CATEGORIES,
    type Category,
    compactSaga,
    expandSaga,
    type SagaIndexEntry,
    type SagaRecord,
} from "../src/data/schema.ts";
import { parseGedcom } from "../src/data/gedcom.ts";
import { displayName as nameFor, type NameMode } from "./gedcom-names.mts";
import { readSource, sourceName } from "./gedcom-source.mts";

// --- Arguments ----------------------------------------------------------------------------------------------------
const args = process.argv.slice(2);
const flag = (name: string) => {
    const i = args.indexOf(`--${name}`);
    return i >= 0 ? args[i + 1] : undefined;
};
const file = args.find((a) => !a.startsWith("--") && !args[args.indexOf(a) - 1]?.startsWith("--"));
const id = flag("id");
const category = flag("category") as Category | undefined;
const title = flag("title");
// --names person|mythology (default person): how a NAME is read; see scripts/gedcom-names.mts.
const nameMode = (flag("names") ?? "person") as NameMode;
if (nameMode !== "person" && nameMode !== "mythology") throw new Error("--names must be person or mythology");
// --house "<name>": put everyone in one house (e.g. a pantheon), instead of one house per surname. Mythology files
// have no real surnames, so grouping by "surname" would make every deity its own house.
const singleHouse = flag("house");
// --color "<css colour>" for that one house (default the first import colour, a strong red).
// --genre "<text>" for the saga's source.genre (default History).
const genre = flag("genre") ?? "History";
// --rename <file.json>: corrections keyed by GEDCOM record id, for files that write some names badly (titles in the
// NAME field, a given name in the surname slot, a repeated surname). Keys starting with "_" are comments. A value is
// the display name, or [display name, id] to also choose the person's id (short ids make tidy links: "david" rather
// than "king-david-of-judah-and-israel"), or [display name, id, house] to also set their house, where the surname
// slot was wrong (that house replaces the GEDCOM surname everywhere, including when sizing houses). See
// scripts/gedcom-renames/.
const renameFile = flag("rename");
const renameEntries = renameFile
    ? Object.entries(JSON.parse(fs.readFileSync(renameFile, "utf8")) as Record<string, string | string[]>)
          .filter(([k]) => !k.startsWith("_"))
          .map(([k, v]) => [k, typeof v === "string" ? [v] : v] as const)
    : [];
const renames = new Map(renameEntries.map(([k, v]) => [k, v[0]]));
const renameIds = new Map(renameEntries.filter(([, v]) => v[1]).map(([k, v]) => [k, v[1]!]));
const renameHouses = new Map(renameEntries.filter(([, v]) => v[2]).map(([k, v]) => [k, v[2]!]));
if (!file || !id || !category || !title)
    throw new Error(
        `usage: gedcom-to-saga <file.ged | https://url> --id <id> --category <${CATEGORIES.join("|")}> --title "<title>" [--names person|mythology] [--house "<name>" [--color "<css>"]] [--genre "<text>"] [--rename <file.json>]`
    );
if (!CATEGORIES.includes(category)) throw new Error(`--category must be one of ${CATEGORIES.join(", ")}`);
if (!/^[a-z0-9-]+$/.test(id)) throw new Error("--id must be lower-case letters, digits and hyphens");

// --- Decode: GEDCOM 5.5 files are often "ANSI" (Windows-1252), not UTF-8 ------------------------------------------
// Decoding a Windows-1252 file as UTF-8 would turn accented names into replacement characters, so try strict UTF-8
// first and fall back to Windows-1252 (a superset of Latin-1) if the bytes aren't valid UTF-8.
const raw = await readSource(file);
const fileName = sourceName(file); // "Babylonian+Gods.ged", for the notes, whether local or downloaded
let text: string;
let encoding: string;
try {
    text = new TextDecoder("utf-8", { fatal: true }).decode(raw);
    encoding = "UTF-8";
} catch {
    text = new TextDecoder("windows-1252").decode(raw);
    encoding = "Windows-1252";
}
text = text.replace(/^﻿/, "");

// --- Records, by level (only what this script reads beyond the app's parser) ---------------------------------------
type Rec = { tag: string; xref?: string; value: string; children: Rec[] };
function records(src: string): Rec[] {
    const roots: Rec[] = [];
    const stack: { level: number; rec: Rec }[] = [];
    for (const line of src.split(/\r\n|\r|\n/)) {
        const m = /^\s*(\d+)\s+(?:(@[^@]+@)\s+)?(\S+)(?:\s(.*))?$/.exec(line);
        if (!m) continue;
        const level = Number(m[1]);
        const rec: Rec = { tag: m[3].toUpperCase(), xref: m[2], value: (m[4] ?? "").trim(), children: [] };
        while (stack.length && stack[stack.length - 1].level >= level) stack.pop();
        (stack.length ? stack[stack.length - 1].rec.children : roots).push(rec);
        stack.push({ level, rec });
    }
    return roots;
}
const recs = records(text);
const child = (r: Rec, tag: string) => r.children.find((c) => c.tag === tag);
const kids = (r: Rec, tag: string) => r.children.filter((c) => c.tag === tag);

// The most telling title for a display name. A monarch's title wins ("King Henry VIII"); otherwise the highest
// peerage rank. Titles are read only from the person's own INDI record: SOUR records also have TITL lines ("The
// Complete Peerage"), which are book titles, not people's titles.
const RANK: [RegExp, number][] = [
    [/^(King|Queen)\b/i, 100],
    [/\b(Prince|Princess)\b/i, 80],
    [/\bDuke\b|\bDuchess\b/i, 60],
    [/\bMarquess\b|\bMarchioness\b/i, 55],
    [/\bEarl\b|\bCountess\b/i, 50],
    [/\bViscount/i, 40],
    [/\bBaron\b|\bLord\b|\bLady\b/i, 30],
    [/\bKnight\b|\bSir\b/i, 10],
];
const rankOf = (t: string) => RANK.find(([re]) => re.test(t))?.[1] ?? 0;
function bestTitle(indi: Rec): string | null {
    const titles = kids(indi, "TITL")
        .map((t) => t.value)
        .filter(Boolean);
    if (!titles.length) return null;
    return titles.sort((a, b) => rankOf(b) - rankOf(a))[0];
}

// --- Build the tree with the app's parser, then enrich ------------------------------------------------------------
const { tree, warnings } = parseGedcom(text, title);
const indis = new Map(recs.filter((r) => r.tag === "INDI" && r.xref).map((r) => [r.xref!.replace(/@/g, ""), r]));
for (const gid of renames.keys())
    if (!indis.has(gid)) throw new Error(`--rename: no INDI record ${gid} in ${fileName}`);

// Display name from the raw NAME and the person's own TITL values, by the tested rules in gedcom-names.mts (clean
// names; monarchs by regnal name; "(unnamed son)" placeholders; mythology mode for deity files).
function displayName(gid: string, sex: "m" | "f"): string {
    const fixed = renames.get(gid);
    if (fixed) return fixed;
    const indi = indis.get(gid);
    const raw = indi ? (child(indi, "NAME")?.value ?? "") : "";
    const titles = indi ? kids(indi, "TITL").map((c) => c.value) : [];
    return nameFor(raw, nameMode, sex, titles);
}

// Readable, stable ids from names ("henry-tudor"), disambiguated in GEDCOM order ("henry-tudor-2"), so a re-import of
// the same file gives the same ids. The original GEDCOM id is kept in the notes mapping for traceability.
const slug = (s: string) =>
    s
        .normalize("NFKD")
        .replace(/[̀-ͯ]/g, "")
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, "-")
        .replace(/^-|-$/g, "") || "person";
// A renamed person's id is the one given in the rename file, if any; otherwise ids come from the display name as for
// everyone else. (Without --rename nothing changes, so existing imports keep their ids.)
const idName = (gid: string, sex: "m" | "f") => renameIds.get(gid) ?? displayName(gid, sex);
const used = new Map<string, number>();
const newId = new Map<string, string>();
// Ids chosen in the rename file are reserved first, and must come out exactly as written: numbering one ("lud-2")
// would quietly break the links it was chosen for, so a clash with anyone, earlier or later in the file, is an error.
const chosen = new Set<string>();
for (const [gid, id] of renameIds) {
    if (slug(id) !== id)
        throw new Error(`--rename: id "${id}" for ${gid} must be lower-case letters, digits and hyphens`);
    if (chosen.has(id)) throw new Error(`--rename: id "${id}" is chosen twice`);
    chosen.add(id);
}
for (const [gid, p] of Object.entries(tree.people)) {
    // From the display name, so Henry VIII is "henry-viii" and an unnamed Tudor is "unnamed-son-tudor", not "tudor".
    const s = slug(idName(gid, p.sex));
    if (renameIds.has(gid)) {
        if (used.has(s)) throw new Error(`--rename: id "${s}" for ${gid} is already used by another person`);
        used.set(s, 1);
        newId.set(gid, s);
        continue;
    }
    // Everyone else is numbered in file order as before, stepping past any id the rename file reserved.
    let n = used.get(s) ?? 0;
    let id: string;
    do id = ++n === 1 ? s : `${s}-${n}`;
    while (chosen.has(id));
    used.set(s, n);
    newId.set(gid, id);
}

// Houses: one per surname is ~95 here, far more than colours can tell apart. The biggest houses (by number of
// people) keep their own colour; every other surname shares one muted "Other families" colour.
const HOUSE_COLOURS = [
    "#c8102e",
    "#e0b23a",
    "#3b6fb6",
    "#3f9a4b",
    "#8a5fd0",
    "#e07a2e",
    "#4aa8c8",
    "#d24fa8",
    "#9aa9b8",
    "#a87a4a",
    "#7fc4ff",
    "#b3202a",
];
const KEEP_HOUSES = HOUSE_COLOURS.length;
const OTHER = "Other families";
// A house set by --rename replaces the surname before houses are sized, so a fixed name doesn't leave a stray house.
for (const [gid, house] of renameHouses) tree.people[gid].house = house;
const size = new Map<string, number>();
for (const p of Object.values(tree.people)) size.set(p.house, (size.get(p.house) ?? 0) + 1);
const major = [...size]
    .filter(([h]) => h !== "Unknown")
    .sort((a, b) => b[1] - a[1])
    .slice(0, KEEP_HOUSES)
    .map(([h]) => h);
const houseOf = (h: string) => singleHouse ?? (major.includes(h) ? h : OTHER);

// --- Assemble the SagaRecord --------------------------------------------------------------------------------------
const head = recs.find((r) => r.tag === "HEAD");
const sourceTitles = recs
    .filter((r) => r.tag === "SOUR" && r.xref)
    .map((r) => child(r, "TITL")?.value)
    .filter((t): t is string => !!t);
const submitter = recs.find((r) => r.tag === "SUBM");
const app = head && child(head, "SOUR");

const people = Object.entries(tree.people).map(([gid, p]) => ({
    id: newId.get(gid)!,
    name: displayName(gid, p.sex),
    house: houseOf(p.house),
    sex: p.sex,
}));
// People the source records with no relatives at all (e.g. the Norse file links 19 people it never defines, leaving
// figures like Skuld and Gefjun with nobody). They are real figures, so keep them, each in a one-person family: the
// model's way of saying "no known relatives", which keeps them visible and satisfies "everyone is in a family".
const related = new Set(tree.families.flatMap((f) => [...f.parents, ...f.children]));
const loners = Object.keys(tree.people).filter((gid) => !related.has(gid));
for (const gid of loners) tree.families.push({ parents: [gid], children: [] });

const families = tree.families.map((f, i) => ({ id: `${id}-f${i + 1}`, adoptive: !!f.adoptive }));
const members = tree.families.flatMap((f, i) => [
    ...f.parents.map((p) => ({ family: `${id}-f${i + 1}`, person: newId.get(p)!, role: "parent" as const })),
    ...f.children.map((c) => ({ family: `${id}-f${i + 1}`, person: newId.get(c)!, role: "child" as const })),
]);
const houses = singleHouse
    ? [{ name: singleHouse, color: flag("color") ?? HOUSE_COLOURS[0] }]
    : [
          ...major.map((name, i) => ({ name, color: HOUSE_COLOURS[i] })),
          ...(people.some((p) => p.house === OTHER) ? [{ name: OTHER, color: "#6f6a78" }] : []),
      ];

const saga: SagaRecord = {
    id,
    title,
    source: {
        work: title,
        medium: `GEDCOM genealogy (${fileName})`,
        // A SUBM record without a NAME (the Roman gods file) would read "Compiled by unknown"; say it plainly instead.
        author:
            submitter && child(submitter, "NAME")?.value
                ? `Compiled by ${child(submitter, "NAME")!.value}`
                : "Unknown compiler",
        canon: sourceTitles.length ? `Sources cited: ${sourceTitles.join("; ")}` : "As recorded in the GEDCOM file",
        genre,
        covers: `${people.length} people and ${families.length} families, imported from a public GEDCOM sample.`,
    },
    notes: [
        `Imported from ${fileName} (${encoding}; ${app?.value ?? "unknown software"}${app && child(app, "VERS") ? " " + child(app, "VERS")!.value : ""}; file dated ${child(head ?? { tag: "", value: "", children: [] }, "DATE")?.value ?? "unknown"}) by scripts/gedcom-to-saga.mts.`,
        nameMode === "mythology"
            ? 'Names are read in mythology mode: the deity\'s name is the GEDCOM surname part, and descriptive text in the given-name part (e.g. "queen of the Gods") is dropped.'
            : "Display names are the person's name only; a monarch is shown by their regnal name (e.g. King Henry VIII). Titles, title dates and life dates are not imported.",
        ...(renames.size
            ? [
                  `${renames.size} names were corrected from ${path.basename(renameFile!)}, where the file writes them badly (e.g. "${[...renames.values()][0]}"); the reasons are in that file.`,
              ]
            : []),
        singleHouse
            ? `Everyone is in one house, "${singleHouse}": the file has no real surnames to group by.`
            : `Houses are surnames; only the ${major.length} largest keep their own colour, the rest are grouped as "${OTHER}".`,
        ...(loners.length
            ? [
                  `${loners.length} people have no recorded relatives in the source and are shown on their own: ${loners.map((g) => people.find((p) => p.id === newId.get(g))!.name).join(", ")}.`,
              ]
            : []),
        ...(warnings.length ? [`Import warnings: ${warnings.join("; ")}`] : []),
    ],
    houses,
    people,
    families,
    members,
};

// --- Write the saga file and the manifest entry -------------------------------------------------------------------
const dataDir = new URL("../public/data/", import.meta.url);
const out = new URL(`${category}/${id}.json`, dataDir);
fs.mkdirSync(new URL(`${category}/`, dataDir), { recursive: true });
// Written in the hand-editable form (families inline); expandSaga() checks it the same way the app will load it.
const sagaFile = compactSaga(saga);
expandSaga(sagaFile);
fs.writeFileSync(out, JSON.stringify(sagaFile, null, 4) + "\n");

const manifestUrl = new URL("sagas.json", dataDir);
const manifest: SagaIndexEntry[] = JSON.parse(fs.readFileSync(manifestUrl, "utf8"));
const entry: SagaIndexEntry = { id, category, title, work: saga.source.work, author: saga.source.author };
const at = manifest.findIndex((s) => s.id === id);
if (at >= 0) manifest[at] = entry;
else manifest.push(entry);
fs.writeFileSync(manifestUrl, JSON.stringify(manifest, null, 4) + "\n");

console.log(
    `wrote ${category}/${id}.json: ${people.length} people, ${families.length} families, ${houses.length} houses` +
        ` (${encoding}${warnings.length ? `, ${warnings.length} warnings` : ""}); sagas.json ${at >= 0 ? "updated" : "extended"}`
);
