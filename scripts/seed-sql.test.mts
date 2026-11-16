// Loads db/schema.sql + db/seed.sql into an in-memory SQLite database (foreign keys ON), then rebuilds every saga
// from the tables and checks it matches public/data/*.json exactly. Also checks the seed is re-runnable and that
// deleting a saga cascades. Uses Node's built-in node:sqlite, so no database install is needed.
import assert from "node:assert/strict";
import fs from "node:fs";
import { DatabaseSync } from "node:sqlite";
import type { SagaIndexEntry, SagaRecord } from "../src/data/schema.ts";

const file = (p: string) => fs.readFileSync(new URL(`../${p}`, import.meta.url), "utf8");
const json = <T,>(f: string): T => JSON.parse(file(`public/data/${f}`));

const db = new DatabaseSync(":memory:");
db.exec("PRAGMA foreign_keys = ON;");
db.exec(file("db/schema.sql"));
const seed = file("db/seed.sql");
db.exec(seed);
db.exec(seed); // re-runnable: second load must not duplicate or violate keys

// node:sqlite returns null-prototype rows; spread them into plain objects so deepStrictEqual compares values only.
const all = (sql: string, ...args: (string | number)[]) =>
    db
        .prepare(sql)
        .all(...args)
        .map((r) => ({ ...r })) as Record<string, unknown>[];

// Manifest: saga order and fields.
const index = json<SagaIndexEntry[]>("sagas.json");
const dbIndex = all("SELECT id, title, work, author FROM saga ORDER BY position");
assert.deepEqual(dbIndex, index, "saga table differs from sagas.json (order or fields)");

for (const { id } of index) {
    const s = json<SagaRecord>(`${id}.json`);
    const saga = all("SELECT * FROM saga WHERE id = ?", id)[0];
    const rebuilt: SagaRecord = {
        id,
        title: saga.title as string,
        source: {
            work: saga.work as string,
            medium: saga.medium as string,
            author: saga.author as string,
            canon: saga.canon as string,
            genre: saga.genre as string,
            covers: saga.covers as string,
        },
        notes: all("SELECT note FROM saga_note WHERE saga_id = ? ORDER BY position", id).map((r) => r.note as string),
        houses: all("SELECT name, color FROM house WHERE saga_id = ? ORDER BY rowid", id) as SagaRecord["houses"],
        people: all(
            "SELECT id, name, house, sex FROM person WHERE saga_id = ? ORDER BY rowid",
            id
        ) as SagaRecord["people"],
        families: all("SELECT id, adoptive FROM family WHERE saga_id = ? ORDER BY rowid", id).map((r) => ({
            id: r.id as string,
            adoptive: r.adoptive === 1,
        })),
        members: all(
            "SELECT family_id AS family, person_id AS person, role FROM family_member WHERE saga_id = ? ORDER BY rowid",
            id
        ) as SagaRecord["members"],
    };
    // The seed groups people by house for readability, so their row order differs from the JSON; compare them as a
    // set (sorted by id). Everything else keeps its order, which matters for notes and the drop-down position.
    const byId = (ps: SagaRecord["people"]) => [...ps].sort((a, b) => a.id.localeCompare(b.id));
    assert.deepEqual(byId(rebuilt.people), byId(s.people), `${id}: people differ from ${id}.json`);
    assert.deepEqual(
        { ...rebuilt, people: [] },
        { ...s, people: [] },
        `${id}: database round-trip differs from ${id}.json`
    );
    console.log(`ok  ${s.title}: round-trips (${s.people.length} people, ${s.members.length} member rows)`);
}

// Cascade: deleting a saga removes all its rows from every table.
db.exec("DELETE FROM saga WHERE id = 'got'");
for (const t of ["saga_note", "house", "person", "family", "family_member"]) {
    const n = (db.prepare(`SELECT COUNT(*) AS n FROM ${t} WHERE saga_id = 'got'`).get() as { n: number }).n;
    assert.equal(n, 0, `${t}: rows left after deleting saga`);
}
console.log("ok  re-running the seed is safe, and deleting a saga cascades to every table");
