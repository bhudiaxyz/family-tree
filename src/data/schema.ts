// Storage schema: one saga = normalised tables, matching db/schema.sql one-to-one.
// Any backend (static JSON, object store, REST API over a database) only has to return these shapes.

/**
 * What kind of family a saga is. Each category is a sub-folder of the data directory (`<category>/<id>.json`), and
 * the same value is stored in the `saga.category` column. Add a value here to add a category; the list is closed so
 * a bad manifest entry can't make the loader request an arbitrary path.
 */
export const CATEGORIES = ["fiction", "history", "mythology"] as const;
export type Category = (typeof CATEGORIES)[number];

export type SagaIndexEntry = { id: string; category: Category; title: string; work: string; author: string };

/**
 * Path of a saga's data file, relative to the data directory: `<category>/<id>.json`. The ONE place this path is
 * built, used by the app's loader and by every script and test, so they can never disagree about where files live.
 * Throws on an unknown category rather than building a path from it.
 */
export function sagaPath(entry: Pick<SagaIndexEntry, "id" | "category">): string {
    if (!(CATEGORIES as readonly string[]).includes(entry.category))
        throw new Error(
            `Saga "${entry.id}" has unknown category "${entry.category}" (expected ${CATEGORIES.join(" or ")})`
        );
    return `${entry.category}/${encodeURIComponent(entry.id)}.json`;
}

export type SagaRecord = {
    id: string;
    title: string;
    source: { work: string; medium: string; author: string; canon: string; genre: string; covers: string };
    notes: string[];
    houses: { name: string; color: string }[];
    people: { id: string; name: string; house: string; sex: "m" | "f" }[];
    families: { id: string; adoptive: boolean }[];
    members: { family: string; person: string; role: "parent" | "child" }[];
};

// App view: what the renderer consumes. Built from a SagaRecord by toTree().
// A family is a union of 0-2 parents with 0+ children; remarriages are separate families.
// `parents: []` groups siblings whose parents are unknown. `adoptive` labels the links as adoptive/adopted.
export type Tree = {
    title: string;
    author: string;
    people: Record<string, { name: string; house: string; sex: "m" | "f" }>;
    families: { parents: string[]; children: string[]; adoptive?: boolean }[];
    houseColors: Record<string, string>;
};
