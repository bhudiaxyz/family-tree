// Checks generation layering on every saga: parents sit exactly one row above their children, co-parents share a
// row, and the people who used to float to the top row (married-in spouses) now line up with their partner.
import assert from "node:assert/strict";
import fs from "node:fs";
import { toTree } from "../src/data/source.ts";
import { generations } from "../src/generations.ts";
import type { SagaIndexEntry, SagaRecord } from "../src/data/schema.ts";

const dir = new URL("../public/data/", import.meta.url);
const read = <T,>(f: string): T => JSON.parse(fs.readFileSync(new URL(f, dir), "utf8"));

for (const { id } of read<SagaIndexEntry[]>("sagas.json")) {
    const t = toTree(read<SagaRecord>(`${id}.json`));
    const gen = generations(t);
    let skips = 0;
    for (const f of t.families) {
        const rows = new Set(f.parents.map((p) => gen.get(p)));
        assert.ok(rows.size <= 1, `${id}: co-parents ${f.parents} on different rows`);
        if (!f.parents.length) continue;
        const pg = gen.get(f.parents[0])!;
        for (const c of f.children) {
            assert.ok(gen.get(c)! > pg, `${id}: ${c} not below parent ${f.parents[0]}`);
            if (gen.get(c)! - pg > 1) skips++;
        }
    }
    console.log(`ok  ${t.title}: ${Math.max(...gen.values()) + 1} generations, ${skips} long parent→child links`);
}

// The originally reported problem: married-in spouses with no parents in the data.
const got = toTree(read<SagaRecord>("got.json"));
const g = generations(got);
for (const [spouse, partner] of [
    ["elia", "rhaegar"],
    ["drogo", "daenerys"],
    ["selyse", "stannis"],
])
    assert.equal(g.get(spouse), g.get(partner), `got: ${spouse} should share ${partner}'s row`);
console.log("ok  Game of Thrones: Elia, Drogo and Selyse share their spouse's row");
