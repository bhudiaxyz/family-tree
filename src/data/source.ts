import { expandSaga, type SagaFile, type SagaIndexEntry, type SagaRecord, sagaPath, type Tree } from "./schema.ts";

// Where saga data lives. Defaults to the static JSON in public/data/.
// Point VITE_DATA_URL at an object store bucket or an API in front of a database; it must serve
// `${base}/sagas.json` and `${base}/<category>/<id>.json` (see sagaPath) in the shapes from schema.ts.
const base = (import.meta.env?.VITE_DATA_URL ?? `${import.meta.env?.BASE_URL ?? "/"}data`).replace(/\/$/, "");

async function getJson<T>(path: string): Promise<T> {
    const res = await fetch(`${base}/${path}`);
    if (!res.ok) throw new Error(`Failed to load ${path}: ${res.status} ${res.statusText}`);
    return res.json() as Promise<T>;
}

export const listSagas = () => getJson<SagaIndexEntry[]>("sagas.json");
/** Load a saga from `<category>/<id>.json`. Takes the manifest entry, because the category is part of the path. */
export const loadSaga = async (entry: SagaIndexEntry) =>
    toTree(toRecord(await getJson<SagaFile | SagaRecord>(sagaPath(entry))));

/**
 * Either shape a backend may serve: the hand-written file (families inline, expanded here) or an already normalised
 * record (e.g. an API over the database, which has member rows). Told apart by whether `members` is present.
 */
export const toRecord = (data: SagaFile | SagaRecord): SagaRecord => ("members" in data ? data : expandSaga(data));

export function toTree(s: SagaRecord): Tree {
    const families = new Map(
        s.families.map((f) => [f.id, { parents: [] as string[], children: [] as string[], adoptive: f.adoptive }])
    );
    for (const m of s.members) {
        const f = families.get(m.family);
        if (!f) throw new Error(`${s.id}: member row references unknown family "${m.family}"`);
        (m.role === "parent" ? f.parents : f.children).push(m.person);
    }
    return {
        title: s.title,
        author: s.source.author,
        people: Object.fromEntries(s.people.map(({ id, ...p }) => [id, p])),
        families: [...families.values()],
        houseColors: Object.fromEntries(s.houses.map((h) => [h.name, h.color])),
    };
}
