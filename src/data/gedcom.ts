// GEDCOM import: turns a GEDCOM 5.5 / 5.5.1 / 7 file (the genealogy exchange format) into a Tree.
//
// What it does: parses "LEVEL [@XREF@] TAG [VALUE]" lines into a record tree, reads INDI (NAME, SEX, FAMC) and FAM
// (HUSB, WIFE, CHIL) records, treats surnames as houses, and splits adopted or foster children into their own family.
// Usage: ui/files.ts calls parseGedcom(), which returns a GedcomResult (tree and warnings). Pure, no DOM; tested in
// scripts/gedcom.test.mts.
// Notes: malformed lines are skipped and problems become warnings, not failures; a file with no INDI throws. Unknown
// sex becomes "m" (the app needs m/f for labels) and is warned about. Adoption is read from CHIL PEDI / _FREL / _MREL
// and also from PEDI on an individual's FAMC. House colours come from palette().importHouses (palettes.ts).

import { palette } from "../render/palettes.ts";
import type { Tree } from "./schema.ts";

type Line = { level: number; xref?: string; tag: string; value: string };
type Rec = { line: Line; children: Rec[] };
export type GedcomResult = { tree: Tree; warnings: string[] };

// "0 @I1@ INDI", "1 NAME John /Smith/", "2 CONT …". Tolerates CRLF, a BOM, leading spaces and tabs.
const LINE = /^\s*(\d+)\s+(?:(@[^@]+@)\s+)?(\S+)(?:\s(.*))?$/;

function parseLines(text: string): Line[] {
    const lines: Line[] = [];
    for (const raw of text.replace(/^﻿/, "").split(/\r\n|\r|\n/)) {
        if (!raw.trim()) continue;
        const m = LINE.exec(raw);
        if (!m) continue; // skip malformed lines rather than failing the whole import
        lines.push({ level: Number(m[1]), xref: m[2], tag: m[3].toUpperCase(), value: (m[4] ?? "").trim() });
    }
    return lines;
}

// Build the record tree from levels: each line becomes a child of the nearest preceding line one level up.
function toRecords(lines: Line[]): Rec[] {
    const roots: Rec[] = [];
    const stack: Rec[] = [];
    for (const line of lines) {
        const rec: Rec = { line, children: [] };
        while (stack.length && stack[stack.length - 1].line.level >= line.level) stack.pop();
        (stack.length ? stack[stack.length - 1].children : roots).push(rec);
        stack.push(rec);
    }
    return roots;
}

const sub = (r: Rec, tag: string) => r.children.find((c) => c.line.tag === tag);
const subs = (r: Rec, tag: string) => r.children.filter((c) => c.line.tag === tag);

// "John /Smith/" → { name: "John Smith", surname: "Smith" }. Falls back to GIVN/SURN sub-tags.
function parseName(indi: Rec): { name: string; surname: string } {
    const n = sub(indi, "NAME");
    const raw = n?.line.value ?? "";
    const surname = /\/([^/]*)\//.exec(raw)?.[1].trim() || (n && sub(n, "SURN")?.line.value) || "";
    const given =
        raw
            .replace(/\/[^/]*\//, " ")
            .replace(/\s+/g, " ")
            .trim() ||
        (n && sub(n, "GIVN")?.line.value) ||
        "";
    const name = [given, raw.includes("/") ? surname : ""].filter(Boolean).join(" ").replace(/\s+/g, " ").trim();
    return { name: name || surname || "Unknown", surname };
}

/** Parse GEDCOM text into a Tree. Throws only if there are no individuals at all. */
export function parseGedcom(text: string, title = "Imported family"): GedcomResult {
    const records = toRecords(parseLines(text));
    const warnings: string[] = [];
    const people: Tree["people"] = {};
    const idOf = new Map<string, string>(); // GEDCOM xref (@I1@) → our id (I1)
    const clean = (xref: string) => xref.replace(/@/g, "");

    for (const r of records.filter((r) => r.line.tag === "INDI" && r.line.xref)) {
        const id = clean(r.line.xref!);
        const { name, surname } = parseName(r);
        const sexTag = sub(r, "SEX")?.line.value.toUpperCase();
        // The app needs m/f for labels (father/mother…). Unknown sex defaults to "m" and is reported.
        if (sexTag !== "M" && sexTag !== "F") warnings.push(`${name}: sex not recorded as M or F, shown as male`);
        people[id] = { name, house: surname || "Unknown", sex: sexTag === "F" ? "f" : "m" };
        idOf.set(r.line.xref!, id);
    }
    if (!Object.keys(people).length) throw new Error("No individuals (INDI records) found: is this a GEDCOM file?");

    const families: Tree["families"] = [];
    for (const r of records.filter((r) => r.line.tag === "FAM")) {
        const ref = (tag: string) =>
            subs(r, tag)
                .map((c) => idOf.get(c.line.value))
                .filter((id): id is string => {
                    if (!id) warnings.push(`Family ${r.line.xref ?? "?"}: ${tag} points to a missing person`);
                    return !!id;
                });
        const parents = [...ref("HUSB"), ...ref("WIFE")].slice(0, 2);
        const children = subs(r, "CHIL").filter((c) => {
            if (idOf.has(c.line.value)) return true;
            warnings.push(`Family ${r.line.xref ?? "?"}: CHIL points to a missing person`);
            return false;
        });
        // Split children by relationship to the parents: birth vs adopted/foster (PEDI, or Ancestry/FTM _FREL/_MREL).
        const adopted = (c: Rec) =>
            ["PEDI", "_FREL", "_MREL"].some((t) => /adopt|foster/i.test(sub(c, t)?.line.value ?? ""));
        const birth = children.filter((c) => !adopted(c)).map((c) => idOf.get(c.line.value));
        const adoptive = children.filter(adopted).map((c) => idOf.get(c.line.value));
        const ok = (ids: (string | undefined)[]) => ids.filter((id): id is string => !!id);
        if (!parents.length && !children.length) continue;
        // Keep the birth family unless every child in it is adopted: a couple with no children at all is still a
        // marriage, but an entry left empty only because its children moved to the adoptive copy is just noise.
        if (birth.length || !adoptive.length) families.push({ parents, children: ok(birth) });
        if (adoptive.length) families.push({ parents, children: ok(adoptive), adoptive: true });
    }

    // PEDI can also sit on the individual's FAMC link instead of the family's CHIL; honour that too.
    const emptied = new Set<Tree["families"][number]>();
    for (const r of records.filter((r) => r.line.tag === "INDI" && r.line.xref)) {
        for (const famc of subs(r, "FAMC")) {
            if (!/adopt|foster/i.test(sub(famc, "PEDI")?.line.value ?? "")) continue;
            const child = idOf.get(r.line.xref!)!;
            const fam = families.find(
                (f) => !f.adoptive && f.children.includes(child) && famOf(records, famc.line.value, idOf, f)
            );
            if (!fam) continue;
            fam.children = fam.children.filter((c) => c !== child);
            if (!fam.children.length) emptied.add(fam); // emptied only by moving its children out: drop it below
            families.push({ parents: fam.parents, children: [child], adoptive: true });
        }
    }

    const kept = families.filter((f) => !emptied.has(f) && (f.parents.length || f.children.length));
    const surnames = [...new Set(Object.values(people).map((p) => p.house))].sort();
    const colours = palette().importHouses; // palettes.ts: the colour set handed out to imported surnames
    // Past the palette's list, step round the colour wheel by the golden angle (≈137.5°), so every further house still
    // gets a colour of its own instead of repeating one (a large Tudor-style file has dozens of surnames).
    const colourFor = (i: number) =>
        i < colours.length ? colours[i] : `hsl(${Math.round((i * 137.508) % 360)}, 55%, ${i % 2 ? 48 : 60}%)`;
    const houseColors = Object.fromEntries(surnames.map((s, i) => [s, colourFor(i)]));
    return { tree: { title, author: "Imported from GEDCOM", people, families: kept, houseColors }, warnings };
}

// Does family `f` (already built) correspond to the GEDCOM FAM record `xref`? Compared by parents.
function famOf(records: Rec[], xref: string, idOf: Map<string, string>, f: Tree["families"][number]): boolean {
    const r = records.find((x) => x.line.tag === "FAM" && x.line.xref === xref);
    if (!r) return false;
    const parents = r.children
        .filter((c) => c.line.tag === "HUSB" || c.line.tag === "WIFE")
        .map((c) => idOf.get(c.line.value));
    return parents.length === f.parents.length && parents.every((p) => p && f.parents.includes(p));
}
