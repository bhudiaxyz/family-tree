// Schema: the saga data shapes, the saga manifest, and the conversions between them.
//
// What it does: defines SagaFile (hand-edited JSON, families inline), SagaRecord (normalised tables, matching
// db/schema.sql), Tree (what the renderer consumes), and the manifest types. expandSaga() and compactSaga() convert
// between SagaFile and SagaRecord; readManifest() validates sagas.json; sagaPath() builds a data file's path.
// Usage: data/source.ts, data/gedcom.ts, ui/ and the core logic modules import the types; scripts and tests import all.
// Notes: sagaPath() is the only place the `<category>/<id>.json` path is built, so the loader, scripts and tests agree.
// CATEGORIES is closed so a bad manifest entry can't request an arbitrary path. Saga ids reject all-digit slugs because
// JS orders integer-like object keys first, which would reorder the menu. expandSaga() throws on the first bad
// reference, naming saga and family. SagaRecord must stay in step with db/schema.sql.

/**
 * What kind of family a saga is. Each category is a sub-folder of the data directory (`<category>/<id>.json`), and
 * the same value is stored in the `saga.category` column. Add a value here to add a category; the list is closed so
 * a bad manifest entry can't make the loader request an arbitrary path.
 */
export type Category = (typeof CATEGORIES)[number];

/**
 * One saga in the manifest. sagas.json is a map of saga id → category, in menu order (`{ "got": "fiction", … }`);
 * everything else about a saga (title, author, …) is in its own data file. Read it with readManifest().
 */
export type SagaIndexEntry = { id: string; category: Category };

export type SagaManifest = Record<string, Category>;

/**
 * A saga data file as written by hand (public/data/<category>/<id>.json): families inline, with their members.
 * Expanded into the normalised SagaRecord by expandSaga(); nothing else reads this shape.
 */
export type SagaFile = {
    id: string;
    title: string;
    source: SagaRecord["source"];
    notes: string[];
    /** House name → colour. */
    houses: Record<string, string>;
    people: SagaRecord["people"];
    /** 0–2 parents and 0+ children; a remarriage is a separate family. `adoptive` only when true. */
    families: { parents: string[]; children: string[]; adoptive?: boolean }[];
};

/** The normalised form: one array per database table (db/schema.sql). Built from a SagaFile by expandSaga(). */
export type SagaRecord = {
    id: string;
    title: string;
    source: { work: string; medium: string; author: string; canon: string; genre: string; covers: string };
    notes: string[];
    houses: { name: string; color: string }[];
    /**
     * `born` is optional: an ISO date, `YYYY-MM-DD`, with `00` for an unknown month or day (`1430-00-00` is "about
     * 1430"). Where it's known, people born in the same decade share a row (tree/generations.ts, alignEras).
     */
    people: { id: string; name: string; house: string; sex: "m" | "f"; born?: string }[];
    families: { id: string; adoptive: boolean }[];
    members: { family: string; person: string; role: "parent" | "child" }[];
};

// App view: what the renderer consumes. Built from a SagaRecord by toTree().
// A family is a union of 0-2 parents with 0+ children; remarriages are separate families.
// `parents: []` groups siblings whose parents are unknown. `adoptive` labels the links as adoptive/adopted.
export type Tree = {
    title: string;
    author: string;
    people: Record<string, { name: string; house: string; sex: "m" | "f"; born?: string }>;
    families: { parents: string[]; children: string[]; adoptive?: boolean }[];
    houseColors: Record<string, string>;
};

export const CATEGORIES = ["fiction", "history", "mythology", "religion"] as const;

/**
 * The manifest as entries, in menu order (the first is opened at start-up), checked as it's read. Saga ids are
 * lower-case slugs; an all-digit id is rejected because JavaScript orders integer-like object keys first, which
 * would silently reorder the menu.
 */
export function readManifest(manifest: SagaManifest): SagaIndexEntry[] {
    return Object.entries(manifest).map(([id, category]) => {
        if (!/^[a-z0-9]+(-[a-z0-9]+)*$/.test(id) || /^\d+$/.test(id))
            throw new Error(`sagas.json: "${id}" isn't a valid saga id (lower-case letters, digits and hyphens)`);
        sagaPath({ id, category }); // throws on an unknown category
        return { id, category };
    });
}

/**
 * Path of a saga's data file, relative to the data directory: `<category>/<id>.json`. The ONE place this path is
 * built, used by the app's loader and by every script and test, so they can never disagree about where files live.
 * Throws on an unknown category rather than building a path from it.
 */
export function sagaPath(entry: SagaIndexEntry): string {
    if (!(CATEGORIES as readonly string[]).includes(entry.category))
        throw new Error(
            `Saga "${entry.id}" has unknown category "${entry.category}" (expected ${CATEGORIES.join(" or ")})`
        );
    return `${entry.category}/${encodeURIComponent(entry.id)}.json`;
}

/**
 * Expand a data file into the normalised record (the database's tables): generated family ids `<saga>-f1`, `-f2`, …
 * in file order, and one member row per parent then per child. Checks the file as it goes and throws on the first
 * mistake, naming the saga and the family, so a bad edit fails loudly in tests and when loaded, not in the 3D view.
 */
export function expandSaga(file: SagaFile): SagaRecord {
    const where = (i: number) => `${file.id}: family ${i + 1}`;
    const people = new Set(file.people.map((p) => p.id));
    if (people.size !== file.people.length) throw new Error(`${file.id}: duplicate person id`);
    for (const p of file.people) {
        if (!(p.house in file.houses)) throw new Error(`${file.id}: ${p.id} is in unknown house "${p.house}"`);
        if (p.born !== undefined && !isBorn(p.born))
            throw new Error(`${file.id}: ${p.id} has born "${p.born}" (want YYYY-MM-DD, 00 for an unknown part)`);
    }
    const families: SagaRecord["families"] = [];
    const members: SagaRecord["members"] = [];
    file.families.forEach((f, i) => {
        const id = `${file.id}-f${i + 1}`;
        if (f.parents.length > 2) throw new Error(`${where(i)} has ${f.parents.length} parents (at most 2)`);
        if (!f.parents.length && !f.children.length) throw new Error(`${where(i)} is empty`);
        for (const p of [...f.parents, ...f.children])
            if (!people.has(p)) throw new Error(`${where(i)}: unknown person "${p}"`);
        const both = f.parents.find((p) => f.children.includes(p));
        if (both) throw new Error(`${where(i)}: "${both}" is both a parent and a child`);
        families.push({ id, adoptive: !!f.adoptive });
        for (const person of f.parents) members.push({ family: id, person, role: "parent" });
        for (const person of f.children) members.push({ family: id, person, role: "child" });
    });
    const inFamily = new Set(members.map((m) => m.person));
    const loner = file.people.find((p) => !inFamily.has(p.id));
    if (loner) throw new Error(`${file.id}: ${loner.id} is in no family (give them a one-person family)`);
    return {
        id: file.id,
        title: file.title,
        source: file.source,
        notes: file.notes,
        houses: Object.entries(file.houses).map(([name, color]) => ({ name, color })),
        people: file.people,
        families,
        members,
    };
}

/** A `born` value: `YYYY-MM-DD`, month 00–12 and day 00–31, where 00 means unknown. */
export const isBorn = (s: string): boolean => {
    const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(s);
    return !!m && +m[2] <= 12 && +m[3] <= 31;
};

/** A `born` date for people to read: "28 Jan 1457", "Jan 1500" or "1430", leaving out the parts that are unknown. */
export function bornText(born: string): string {
    const [y, m, d] = born.split("-").map(Number);
    const month = m ? ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][m - 1] : "";
    return [m && d ? d : "", month, y].filter(Boolean).join(" ");
}

/** The year someone was born, if recorded (`born` is YYYY-MM-DD). */
export const bornYear = (p: { born?: string }): number | null => (p.born ? Number(p.born.slice(0, 4)) : null);

/** The reverse of expandSaga, for tools that build a normalised record (the GEDCOM importer, the conversion). */
export function compactSaga(s: SagaRecord): SagaFile {
    const byFamily = new Map(s.families.map((f) => [f.id, { parents: [] as string[], children: [] as string[] }]));
    for (const m of s.members) byFamily.get(m.family)![m.role === "parent" ? "parents" : "children"].push(m.person);
    return {
        id: s.id,
        title: s.title,
        source: s.source,
        notes: s.notes,
        houses: Object.fromEntries(s.houses.map((h) => [h.name, h.color])),
        people: s.people,
        families: s.families.map((f) => ({ ...byFamily.get(f.id)!, ...(f.adoptive ? { adoptive: true } : {}) })),
    };
}
