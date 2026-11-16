// Checks generation layering on every saga:
//   - DESCENT, always: every child sits below EVERY one of its parents (the earlier test only compared the first
//     parent, which is how a child above its second parent went unnoticed in the Roman gods);
//   - MARRIAGE: co-parents share a row, except where a saga's intermarriage makes that impossible together with
//     descent (listed in INTERMARRIED, with why), and married-in spouses line up with their partner.
import assert from "node:assert/strict";
import { toTree } from "../src/data/source.ts";
import { generations } from "../src/generations.ts";
import { readIndex, readSaga, treeById } from "./data.mts";

// Sagas where "spouses share a row" cannot hold alongside "parents above children": Jupiter partners Venus, Venus
// partners Mars, Mars is Jupiter's son, so the couples span generations. Descent wins; these couples may be split.
const INTERMARRIED = new Set(["roman-gods"]);

for (const entry of readIndex()) {
    const { id } = entry;
    const t = toTree(readSaga(entry));
    const gen = generations(t);
    let skips = 0;
    let split = 0;
    for (const f of t.families) {
        const rows = new Set(f.parents.map((p) => gen.get(p)));
        if (rows.size > 1) {
            assert.ok(INTERMARRIED.has(id), `${id}: co-parents ${f.parents} on different rows`);
            split++;
        }
        for (const p of f.parents)
            for (const c of f.children) {
                assert.ok(
                    gen.get(c)! > gen.get(p)!,
                    `${id}: ${c} (row ${gen.get(c)}) not below parent ${p} (row ${gen.get(p)})`
                );
                if (gen.get(c)! - gen.get(p)! > 1) skips++;
            }
    }
    const note = split ? `, ${split} couples split by intermarriage` : "";
    console.log(
        `ok  ${t.title}: ${Math.max(...gen.values()) + 1} generations, ${skips} long parent→child links${note}`
    );
}

// The originally reported problem: married-in spouses with no parents in the data.
const got = treeById("got");
const g = generations(got);
for (const [spouse, partner] of [
    ["elia", "rhaegar"],
    ["drogo", "daenerys"],
    ["selyse", "stannis"],
])
    assert.equal(g.get(spouse), g.get(partner), `got: ${spouse} should share ${partner}'s row`);
console.log("ok  Game of Thrones: Elia, Drogo and Selyse share their spouse's row");

// The Roman case that needed the descent repair: Aeneas below both his parents, Mars below Jupiter.
const rome = treeById("roman-gods");
const r = generations(rome);
assert.ok(
    r.get("aeneas")! > r.get("anchises")! && r.get("aeneas")! > r.get("venus")!,
    "Aeneas below Anchises and Venus"
);
assert.ok(r.get("mars")! > r.get("jupiter")!, "Mars below Jupiter");
console.log("ok  Roman gods: descent holds through the intermarriage (Aeneas, Mars)");
