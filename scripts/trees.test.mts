// Checks every saga in public/data: the manifest and the files agree (each file in its category's folder, nothing
// missing or stray), every reference resolves, everyone is in a family, and toTree() produces a usable tree.
import assert from "node:assert/strict";
import fs from "node:fs";
import { CATEGORIES, sagaPath } from "../src/data/schema.ts";
import { toTree } from "../src/data/source.ts";
import { dataDir, readIndex, readSaga } from "./data.mts";

const index = readIndex();

// Every manifest entry has a known category, and ids are unique across categories.
for (const s of index)
    assert.ok((CATEGORIES as readonly string[]).includes(s.category), `${s.id}: unknown category "${s.category}"`);
assert.equal(new Set(index.map((s) => s.id)).size, index.length, "duplicate saga id in sagas.json");

// Files on disk ↔ manifest, per category folder: no saga missing its file, no file missing from the manifest, and no
// saga files left in the data root (they belong in a category folder).
const onDisk = CATEGORIES.flatMap((c) => {
    const dir = new URL(`${c}/`, dataDir);
    return fs.existsSync(dir)
        ? fs
              .readdirSync(dir)
              .filter((f) => f.endsWith(".json"))
              .map((f) => `${c}/${f.replace(/\.json$/, "")}`)
        : [];
});
assert.deepEqual(
    onDisk.sort(),
    index.map((s) => `${s.category}/${s.id}`).sort(),
    "sagas.json out of sync with the category folders"
);
const stray = fs.readdirSync(dataDir).filter((f) => f.endsWith(".json") && f !== "sagas.json");
assert.deepEqual(stray, [], `saga files in the data root; move them into a category folder: ${stray.join(", ")}`);

for (const entry of index) {
    const s = readSaga(entry);
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
    console.log(
        `ok  ${entry.category}/${entry.id} ${t.title}: ${s.people.length} people, ${s.families.length} families`
    );
}

// sagaPath refuses an unknown category instead of building a path from it (a bad manifest can't request "../x").
assert.equal(sagaPath({ id: "got", category: "fiction" }), "fiction/got.json");
assert.throws(() => sagaPath({ id: "x", category: "../secrets" as never }), /unknown category/);
console.log("ok  sagaPath: <category>/<id>.json, unknown categories rejected");
