// Test for src/generations.ts: generation layering of every saga, in both sibling modes.
//
// Checks: DESCENT always (every child sits below EVERY parent, not just the first); "together" (default): brothers
//   and sisters share a row, couples line up where that allows; "apart": couples share a row except in INTERMARRIED
//   sagas, siblings line up where that allows.
// Data: every real saga in public/data, via readIndex()/readSaga().
// Run alone: node --experimental-strip-types --no-warnings scripts/generations.test.mts
// Ratchets: LIMITS (max split sibling sets and split couples per mode). Lower them when the layout improves; never
//   raise them to make a change pass.
// Allow-list: INTERMARRIED, sagas where spouses-share-a-row can't hold with parents-above-children, so descent wins.
//   Roman gods: Jupiter partners Venus, Venus partners Mars, Mars is Jupiter's son. Bible: Lot fathers children by his
//   own two daughters (Genesis 19), so each couple is a father and a daughter a generation apart.

import assert from "node:assert/strict";
import type { Tree } from "../src/data/schema.ts";
import { toTree } from "../src/data/source.ts";
import { generations, type SiblingMode } from "../src/generations.ts";
import { readIndex, readSaga, treeById } from "./data.mts";

// Sagas where "spouses share a row" cannot hold alongside "parents above children", so descent wins and these couples
// may be split. Roman gods: Jupiter partners Venus, Venus partners Mars, Mars is Jupiter's son. Bible: Lot fathers
// children by his own two daughters (Genesis 19), so each couple is a father and a daughter a generation apart.
const INTERMARRIED = new Set(["roman-gods", "bible"]);

const LIMITS: Record<SiblingMode, { siblingSets: number; couples: number }> = {
    together: { siblingSets: 1, couples: 49 }, // the one split set: a Roman sibling the descent repair must move
    apart: { siblingSets: 19, couples: 35 },
};

const splitSiblings = (t: Tree, gen: Map<string, number>) =>
    t.families.filter((f) => new Set(f.children.map((c) => gen.get(c))).size > 1).length;

for (const mode of ["together", "apart"] as const) {
    let siblingSets = 0;
    let couples = 0;
    for (const entry of readIndex()) {
        const { id } = entry;
        const t = toTree(readSaga(entry));
        const gen = generations(t, mode);
        let skips = 0;
        let split = 0;
        for (const f of t.families) {
            if (new Set(f.parents.map((p) => gen.get(p))).size > 1) {
                if (mode === "apart")
                    assert.ok(INTERMARRIED.has(id), `${id}: co-parents ${f.parents} on different rows`);
                split++;
            }
            for (const p of f.parents)
                for (const c of f.children) {
                    assert.ok(
                        gen.get(c)! > gen.get(p)!,
                        `${mode} ${id}: ${c} (row ${gen.get(c)}) not below parent ${p} (row ${gen.get(p)})`
                    );
                    if (gen.get(c)! - gen.get(p)! > 1) skips++;
                }
        }
        const sibs = splitSiblings(t, gen);
        siblingSets += sibs;
        couples += split;
        const notes = [split && `${split} couples split`, sibs && `${sibs} sibling sets split`].filter(Boolean);
        console.log(
            `ok  ${mode} ${t.title}: ${Math.max(...gen.values()) + 1} rows, ${skips} long parent→child links` +
                (notes.length ? `, ${notes.join(", ")}` : "")
        );
    }
    const max = LIMITS[mode];
    assert.ok(siblingSets <= max.siblingSets, `${mode}: ${siblingSets} sibling sets split (limit ${max.siblingSets})`);
    assert.ok(couples <= max.couples, `${mode}: ${couples} couples split (limit ${max.couples})`);
    console.log(`ok  ${mode}: ${siblingSets} sibling sets and ${couples} couples split, across every saga`);
}

// "together": every set of brothers and sisters shares a row unless that's impossible: one of them is also another's
// child. The Roman file lists Daphne as a child of Oceanus and Tethys AND of Ladon, her own brother, so she can't be
// on his row and below him. Anything else split is a layout bug.
for (const entry of readIndex()) {
    const t = treeById(entry.id);
    const g = generations(t);
    for (const f of t.families) {
        if (new Set(f.children.map((c) => g.get(c))).size < 2) continue;
        const contradictory = f.children.some((c) =>
            t.families.some((x) => x.children.includes(c) && x.parents.some((p) => f.children.includes(p)))
        );
        assert.ok(contradictory, `together ${entry.id}: siblings ${f.children} split though they could share a row`);
    }
}
console.log("ok  together: every set of siblings shares a row, except where one is another's child (Daphne and Ladon)");

// "together": the case that started it. Ginny sits with her brothers, not a row below with Harry.
{
    const g = generations(treeById("potter"));
    for (const b of ["bill", "charlie", "percy", "fred", "george", "ron"])
        assert.equal(g.get("ginny"), g.get(b), `together: Ginny on ${b}'s row`);
    const a = generations(treeById("potter"), "apart");
    assert.equal(a.get("ginny"), a.get("harry"), "apart: Ginny on Harry's row");
    console.log("ok  Ginny: with her brothers (together), with Harry (apart)");
}

// Both modes: married-in spouses with no parents in the data line up with their partner (the original problem), and
// the intermarried pantheons keep descent.
for (const mode of ["together", "apart"] as const) {
    const g = generations(treeById("got"), mode);
    for (const [spouse, partner] of [
        ["elia", "rhaegar"],
        ["drogo", "daenerys"],
        ["selyse", "stannis"],
    ])
        assert.equal(g.get(spouse), g.get(partner), `${mode} got: ${spouse} should share ${partner}'s row`);

    const r = generations(treeById("roman-gods"), mode);
    assert.ok(
        r.get("aeneas")! > r.get("anchises")! && r.get("aeneas")! > r.get("venus")!,
        `${mode}: Aeneas below both`
    );
    assert.ok(r.get("mars")! > r.get("jupiter")!, `${mode}: Mars below Jupiter`);

    const bible = treeById("bible");
    const b = generations(bible, mode);
    for (const d of ["lot-elder-daughter", "lot-younger-daughter"]) {
        assert.ok(b.get(d)! > b.get("lot")!, `${mode}: ${d} below Lot`);
        for (const f of bible.families.filter((f) => f.parents.includes(d) && f.parents.includes("lot")))
            for (const c of f.children) assert.ok(b.get(c)! > b.get(d)!, `${mode}: ${c} below ${d} and Lot`);
    }
    console.log(`ok  ${mode}: Elia, Drogo and Selyse with their spouses; descent holds for Aeneas, Mars and Lot`);
}
