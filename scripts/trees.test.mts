// Checks every saga in public/data: manifest and files agree, every reference resolves,
// every person is in a family, and toTree() produces a usable tree.
import assert from "node:assert/strict";
import fs from "node:fs";
import { toTree } from "../src/data/source.ts";
import type { SagaIndexEntry, SagaRecord } from "../src/data/schema.ts";

const dir = new URL("../public/data/", import.meta.url);
const read = <T,>(f: string): T => JSON.parse(fs.readFileSync(new URL(f, dir), "utf8"));
const index = read<SagaIndexEntry[]>("sagas.json");
const files = fs.readdirSync(dir).filter((f) => f !== "sagas.json");
assert.deepEqual(files.map((f) => f.replace(/\.json$/, "")).sort(), index.map((s) => s.id).sort(), "sagas.json out of sync with files");

for (const entry of index) {
    const s = read<SagaRecord>(`${entry.id}.json`);
    assert.equal(s.id, entry.id);
    assert.equal(s.title, entry.title, `${s.id}: title differs from sagas.json`);
    const houses = new Set(s.houses.map((h) => h.name));
    const people = new Set(s.people.map((p) => p.id));
    const families = new Set(s.families.map((f) => f.id));
    assert.equal(people.size, s.people.length, `${s.id}: duplicate person id`);
    for (const p of s.people) assert.ok(houses.has(p.house), `${s.id}: no house "${p.house}"`);
    for (const m of s.members) {
        assert.ok(families.has(m.family), `${s.id}: unknown family "${m.family}"`);
        assert.ok(people.has(m.person), `${s.id}: unknown person "${m.person}"`);
    }
    const inFamily = new Set(s.members.map((m) => m.person));
    for (const id of people) assert.ok(inFamily.has(id), `${s.id}: "${id}" is in no family`);
    const t = toTree(s);
    for (const f of t.families) assert.ok(f.parents.length <= 2, `${s.id}: family with ${f.parents.length} parents`);
    console.log(`ok  ${t.title}: ${s.people.length} people, ${s.families.length} families`);
}
