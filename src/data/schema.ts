// Storage schema: one saga = normalised tables, matching db/schema.sql one-to-one.
// Any backend (static JSON, object store, REST API over a database) only has to return these shapes.

export type SagaIndexEntry = { id: string; title: string; work: string; author: string };

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
