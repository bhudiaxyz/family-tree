// Unit tests for src/family.ts against real saga data, so the expectations are facts about the stories.
import assert from "node:assert/strict";
import fs from "node:fs";
import type { SagaRecord, Tree } from "../src/data/schema.ts";
import { toTree } from "../src/data/source.ts";
import { childLabel, findByName, houseDepths, lineage, parentLabel, relatives, siblingLabel } from "../src/family.ts";

const saga = (id: string): Tree =>
    toTree(JSON.parse(fs.readFileSync(new URL(`../public/data/${id}.json`, import.meta.url), "utf8")) as SagaRecord);
const got = saga("got");
const sw = saga("starwars");
const family = (t: Tree, parents: string[]) =>
    t.families.find((f) => f.parents.length === parents.length && parents.every((p) => f.parents.includes(p)))!;

// lineage: Jon's line covers both parents and grandparents, but not unrelated houses or his half-siblings' mother.
const jon = lineage(got, "jon");
for (const id of ["jon", "rhaegar", "lyanna", "aerys", "rhaella", "rickard", "lyarra"]) assert.ok(jon.has(id), id);
for (const id of ["tywin", "cersei", "elia", "robb"]) assert.ok(!jon.has(id), `${id} is not in Jon's line`);
// Spouses are included (so the marriage stays visible), descendants too.
const ned = lineage(got, "eddard");
for (const id of ["catelyn", "robb", "sansa", "arya", "bran", "rickon", "rickard"]) assert.ok(ned.has(id), id);

// relatives: grouping and adoptive labels.
const rel = (t: Tree, id: string) => Object.fromEntries(relatives(t, id));
assert.deepEqual(rel(got, "jon"), { Parents: ["rhaegar", "lyanna"] });
assert.deepEqual(rel(sw, "luke"), {
    "Adoptive parents": ["owen", "beru"],
    Parents: ["anakin", "padme"],
    Siblings: ["leia"],
});
const rhaegar = rel(got, "rhaegar");
assert.deepEqual(rhaegar.Spouse, ["lyanna", "elia"]);
assert.deepEqual(rhaegar.Children, ["jon", "rhaenys", "aegon"]);
assert.deepEqual(rel(sw, "owen")["Adopted children"], ["luke"]);

// Link labels.
assert.equal(parentLabel(got, "eddard", family(got, ["eddard", "catelyn"])), "father");
assert.equal(parentLabel(got, "daenerys", family(got, ["drogo", "daenerys"])), "wife");
assert.equal(parentLabel(sw, "beru", family(sw, ["owen", "beru"])), "adoptive mother");
assert.equal(childLabel(sw, "luke", family(sw, ["owen", "beru"])), "adopted son");
assert.equal(childLabel(got, "sansa", family(got, ["eddard", "catelyn"])), "daughter");
assert.equal(siblingLabel(got, "robb", "bran"), "brothers");
assert.equal(siblingLabel(got, "sansa", "arya"), "sisters");
assert.equal(siblingLabel(got, "robb", "sansa"), "brother & sister");

// Search.
assert.equal(findByName(got, "Jon Snow"), "jon");
assert.equal(findByName(got, "  jon snow "), "jon");
assert.equal(findByName(got, "Jon"), "jon", "a partial match prefers the first person whose name contains it");
assert.equal(findByName(got, "Arryn"), "jonArryn");
assert.equal(findByName(got, ""), null);
assert.equal(findByName(got, "Gandalf"), null);

// House depths: within ±depth/2, the biggest house at the centre, one plane per house.
const z = houseDepths(got, 240);
assert.equal(z.size, Object.keys(got.houseColors).length);
for (const v of z.values()) assert.ok(Math.abs(v) <= 120);
assert.equal(z.get("Stark"), 0, "the biggest house sits in the middle plane");
assert.equal(houseDepths({ ...got, houseColors: { Stark: "#fff" } }, 240).get("Stark"), 0, "single house: no NaN");

console.log("ok  family queries: lineage, relatives, link labels, search, house depths");
