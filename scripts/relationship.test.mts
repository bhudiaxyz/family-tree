// Relationship finder against facts from the stories (and the standard cousin table).
import assert from "node:assert/strict";
import fs from "node:fs";
import { toTree } from "../src/data/source.ts";
import type { SagaRecord, Tree } from "../src/data/schema.ts";
import { relate } from "../src/relationship.ts";

const saga = (id: string): Tree =>
    toTree(JSON.parse(fs.readFileSync(new URL(`../public/data/${id}.json`, import.meta.url), "utf8")) as SagaRecord);
const got = saga("got");
const fb = saga("fireblood");
const sw = saga("starwars");
const lotr = saga("lotr");
const potter = saga("potter");

const label = (t: Tree, a: string, b: string) => relate(t, a, b)?.label;

// Direct line.
assert.equal(label(got, "robb", "eddard"), "son");
assert.equal(label(got, "eddard", "robb"), "father");
assert.equal(label(got, "robb", "rickard"), "grandson");
assert.equal(label(got, "rickard", "robb"), "grandfather");
// Aegon III descends from Baelon twice: via Rhaenyra ← Viserys I (3 up) and via his father Daemon (2 up). The closest
// route wins, so he is Baelon's grandson — the kind of Targaryen tangle the finder has to get right.
assert.equal(label(fb, "aegonIII", "baelon"), "grandson");
assert.equal(label(fb, "jacaerys", "baelon"), "great-grandson", "Jacaerys ← Rhaenyra ← Viserys I ← Baelon");

// Siblings, half-siblings.
assert.equal(label(got, "sansa", "arya"), "sister");
assert.equal(label(got, "jon", "aegon"), "half-brother", "Jon and Aegon share only Rhaegar");
assert.equal(label(fb, "rhaenyra", "aegonII"), "half-sister", "Rhaenyra and Aegon II share only Viserys I");

// Aunt/uncle and niece/nephew.
assert.equal(label(got, "jon", "daenerys"), "nephew", "Jon is Daenerys's nephew (Rhaegar's son)");
assert.equal(label(got, "daenerys", "jon"), "aunt");
assert.equal(label(got, "benjen", "robb"), "uncle");
assert.equal(label(potter, "teddy", "andromeda"), "grandson");

// Cousins.
assert.equal(label(got, "jon", "robb"), "first cousin", "Jon (Lyanna's son) and Robb (Ned's son)");
assert.equal(label(got, "robin", "robb"), "first cousin", "Lysa and Catelyn are sisters");
assert.equal(label(fb, "rhaenyra", "laenor"), "second cousin", "Viserys I and Rhaenys are first cousins");
assert.equal(
    label(fb, "jacaerys", "rhaenys"),
    "grandson",
    "Jacaerys's father Laenor is Rhaenys's son (closer than any cousin route)"
);
assert.equal(
    label(fb, "baela", "rhaenyra"),
    "first cousin",
    "Baela's father Daemon and Rhaenyra's father Viserys I are brothers"
);

// Adoption.
const luke = relate(sw, "luke", "owen")!;
assert.equal(luke.label, "son");
assert.ok(luke.adoptive && luke.summary.includes("(by adoption)"));
assert.equal(label(sw, "luke", "leia"), "brother", "birth siblings, not via adoption");
assert.ok(!relate(sw, "luke", "leia")!.adoptive);

// Marriage only.
assert.equal(label(got, "catelyn", "eddard"), "wife");
const inLaw = relate(got, "catelyn", "benjen")!;
assert.equal(inLaw.label, null, "Catelyn and Benjen are related only by marriage");
assert.ok(inLaw.summary.startsWith("Catelyn Tully is connected by marriage"));
assert.deepEqual(inLaw.path[0], "catelyn");
assert.deepEqual(inLaw.path.at(-1), "benjen");

// Paths are real chains (each consecutive pair is linked), endpoints correct.
for (const [t, a, b] of [
    [got, "jon", "daenerys"],
    [fb, "jacaerys", "rhaenys"],
    [lotr, "aragorn", "elrond"],
] as const) {
    const r = relate(t, a, b)!;
    assert.equal(r.path[0], a);
    assert.equal(r.path.at(-1), b);
    assert.equal(r.steps.length, r.path.length - 1);
}

// Not connected, and self.
assert.equal(relate(got, "jon", "jon")!.label, "the same person");
const unrelated = relate(sw, "luke", "rey");
assert.equal(unrelated, null, "Skywalkers and Palpatines aren't linked in this tree");

console.log("ok  relationship finder: direct line, siblings, half-siblings, aunt/nephew, cousins, adoption, marriage");

// Cousin wording on a synthetic tree where the answer is fixed by the standard cousin chart. One root couple; two
// lines descend from their two children, so every pair's relationship is unambiguous.
//            r1 + r2
//         ┌─────┴─────┐
//         a1          b1
//         a2          b2
//         a3          b3
//         a4
const ids = ["r1", "r2", "a1", "a2", "a3", "a4", "b1", "b2", "b3"];
const chart: Tree = {
    title: "chart",
    author: "",
    houseColors: { X: "#fff" },
    people: Object.fromEntries(ids.map((id) => [id, { name: id, house: "X", sex: id === "r2" ? "f" : "m" }])),
    families: [
        { parents: ["r1", "r2"], children: ["a1", "b1"] },
        { parents: ["a1"], children: ["a2"] },
        { parents: ["a2"], children: ["a3"] },
        { parents: ["a3"], children: ["a4"] },
        { parents: ["b1"], children: ["b2"] },
        { parents: ["b2"], children: ["b3"] },
    ],
};
const c = (a: string, b: string) => label(chart, a, b);
assert.equal(c("a1", "b1"), "brother");
assert.equal(c("a2", "b1"), "nephew");
assert.equal(c("a3", "b1"), "grandnephew");
assert.equal(c("a4", "b1"), "great-grandnephew");
assert.equal(c("b1", "a3"), "granduncle");
assert.equal(c("a2", "b2"), "first cousin");
assert.equal(c("a3", "b2"), "first cousin once removed");
assert.equal(c("a4", "b2"), "first cousin twice removed");
assert.equal(c("a3", "b3"), "second cousin");
assert.equal(c("a4", "b3"), "second cousin once removed");
assert.equal(c("a4", "r1"), "great-great-grandson");
console.log("ok  relationship finder: cousin chart (degree and removal) on a synthetic tree");
