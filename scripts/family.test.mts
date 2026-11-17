// Unit tests for src/family.ts against real saga data, so the expectations are facts about the stories.
import assert from "node:assert/strict";
import type { Tree } from "../src/data/schema.ts";
import {
    ancestry,
    childLabel,
    descendantCount,
    distinguish,
    findByName,
    houseDepths,
    lineage,
    lineageRoles,
    parentLabel,
    relatives,
    searchPeople,
    siblingLabel,
} from "../src/family.ts";
import { treeById } from "./data.mts";

const saga = (id: string): Tree => treeById(id);
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
// lineageRoles: side and generation distance, used to tint and fade the highlight.
const nedRoles = lineageRoles(got, "eddard");
assert.deepEqual(nedRoles.get("eddard"), { side: "self", distance: 0 });
assert.deepEqual(nedRoles.get("rickard"), { side: "ancestor", distance: 1 });
assert.deepEqual(nedRoles.get("arya"), { side: "descendant", distance: 1 });
assert.deepEqual(nedRoles.get("catelyn"), { side: "spouse", distance: 0 });
assert.deepEqual(lineageRoles(got, "jon").get("aerys"), { side: "ancestor", distance: 2 });

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

// Search ignores accents, case and punctuation, ranks exact > prefix > contains > close spelling, and tolerates typos.
const babylon = saga("babylonian-gods");
assert.equal(findByName(babylon, "apsu"), "apsu", "accents ignored: apsu finds Apsû");
const nehru = saga("nehru-gandhi");
assert.equal(findByName(nehru, "Ghandi")?.endsWith("gandhi"), true, "a typo still finds a Gandhi");
assert.equal(findByName(nehru, "Jawarharlal"), "jawaharlal-nehru", "one wrong letter");
assert.equal(findByName(got, "Jnn"), null, "short queries don't fuzz-match (too many false hits)");
assert.deepEqual(searchPeople(got, "stark", 3).length, 3, "limit applies");
assert.equal(searchPeople(got, "Eddard Stark")[0], "eddard", "the exact name ranks first");

// Telling namesakes apart: only for repeated names, by parents, else a child, else a spouse.
const bible = saga("bible");
const lamechs = Object.keys(bible.people).filter((id) => bible.people[id].name === "Lamech");
assert.equal(lamechs.length, 2, "the Bible has two Lamechs");
const hints = lamechs.map((id) => distinguish(bible, id));
assert.ok(hints.every(Boolean) && hints[0] !== hints[1], `Lamechs told apart: ${hints.join(" / ")}`);
assert.equal(distinguish(got, "jon"), null, "a unique name needs no hint");

// Ancestry: one line back to the oldest ancestor, through the father first; and descendant counts.
assert.deepEqual(ancestry(nehru, "rahul-gandhi"), [
    "gangadhar-nehru",
    "motilal-nehru",
    "jawaharlal-nehru",
    "indira-gandhi",
    "rajiv-gandhi",
    "rahul-gandhi",
]);
assert.deepEqual(ancestry(got, "rickard").at(-1), "rickard");
// Jawaharlal, Vijaya Lakshmi, Krishna; Indira, three Pandit and two Hutheesing grandchildren; Rajiv, Sanjay; Rahul, Priyanka, Varun.
assert.deepEqual(descendantCount(nehru, "motilal-nehru"), { people: 14, generations: 4 });

// House depths: within ±depth/2, the biggest house at the centre, one plane per house.
const z = houseDepths(got, 240);
assert.equal(z.size, Object.keys(got.houseColors).length);
for (const v of z.values()) assert.ok(Math.abs(v) <= 120);
assert.equal(z.get("Stark"), 0, "the biggest house sits in the middle plane");
assert.equal(houseDepths({ ...got, houseColors: { Stark: "#fff" } }, 240).get("Stark"), 0, "single house: no NaN");

console.log("ok  family queries: lineage, relatives, ancestry, link labels, search (fuzzy), namesakes, house depths");
