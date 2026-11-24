// Row order: where each person starts along their row, kept in family groups, with as few crossing lines as it can.
//
// What it does: rowOrder(tree, rows) walks the tree from the oldest row down, placing each family's brothers and
// sisters as one unbroken run under their parents, and chaining families married into each other (one sibling with
// a partner at the run's end, then the partner and their own siblings); then barycentre sweeps reorder whole groups
// to reduce crossing lines, and each row is centred. linkCrossings() counts crossings, from each marriage node.
// Usage: graph/graph.ts showTree() seeds every node's x from rowOrder(); scripts/generations.test.mts checks that no
// family's children are split and holds the crossing count as a ratchet. Pure: no three.js or DOM imports.
// Notes: the layout's forces (graph/forces.ts) only refine this order and can't move a name past another, so this is
// what decides who sits next to whom. Brothers and sisters always take precedence over partners: only one married
// sibling per family can sit at the join; the sweeps only ever move whole groups.

import type { Tree } from "../data/schema.ts";

// --- Starting order along each row ----------------------------------------------------------------------------------
// The forces only nudge people sideways, and names can't pass through each other (spreadRows), so whatever order the
// layout starts in is roughly the order it ends in. Started at random, couples were split by strangers and brothers
// and sisters scattered. So each row starts in family order: walk the tree from the oldest row down; a person is
// placed with their spouses beside them, and each family's children are placed together, in the order of their
// parents above, so a couple starts over its own children. A new group (not a spouse or sibling of the one before)
// starts SEED_GROUP further along. Each row is then centred. The forces refine this; they don't have to find it.
const SEED_STEP = 26; // world units between neighbours in a group

const SEED_GROUP = 45; // extra space before a new group (matches GROUP_SPACE in graph/forces.ts)

// --- Fewer crossing links: reorder whole blocks along each row ----------------------------------------------------
// The family walk above leaves some lines crossing: an in-law's parents sit wherever their own family put them, so the
// line down to their child cuts across other families. The usual remedy (the barycentre heuristic, as in Sugiyama-style
// layered drawing) sweeps the rows: order each row's blocks by the mean position of their children (upwards), then of
// their parents (downwards), and repeat. Only whole blocks move, so brothers and sisters and couples always stay
// together, and the last sweep is downwards, so children's blocks end up ordered under their parents. A block with no
// relatives in the row it's ordered by keeps its place. Sweeps run while they reduce crossings (at most SWEEPS times).
const SWEEPS = 4;

export function rowOrder(t: Tree, gen: Map<string, number>): Map<string, number> {
    const asParent = new Map<string, Tree["families"]>();
    for (const f of t.families) for (const p of f.parents) asParent.set(p, [...(asParent.get(p) ?? []), f]);
    const isChild = new Set(t.families.flatMap((f) => f.children));
    const spouses = (id: string) =>
        (asParent.get(id) ?? []).flatMap((f) => f.parents).filter((p) => p !== id && gen.get(p) === gen.get(id));
    const x = new Map<string, number>();
    const next = new Map<number, number>(); // the next free x on each row
    // Each person's block: a family's brothers and sisters with the partners beside them (a new group starts one).
    // Blocks are never split; the crossing sweeps below only reorder whole blocks.
    const blockOf = new Map<string, number>();
    let blocks = 0;
    // Place someone at the end of their row; `withSpouses` places their partners on the row right after them (for
    // couples with no parents recorded; sibling groups place partners themselves, below).
    const place = (id: string, newGroup: boolean, withSpouses = true) => {
        if (x.has(id)) return;
        const row = gen.get(id)!;
        const at = next.get(row);
        const pos = at === undefined ? 0 : at + (newGroup ? SEED_GROUP : 0);
        x.set(id, pos);
        blockOf.set(id, newGroup || at === undefined ? ++blocks : blocks);
        next.set(row, pos + SEED_STEP);
        if (withSpouses) for (const s of spouses(id)) place(s, false);
    };
    const birthFamily = new Map<string, string[]>();
    for (const f of t.families) for (const c of f.children) if (!birthFamily.has(c)) birthFamily.set(c, f.children);
    // A family's children, kept together in one unbroken run: brothers and sisters always take precedence. One who
    // has a partner not yet placed goes at the right-hand end, then the partner, then the partner's own brothers and
    // sisters, chaining the families: Starks, Eddard | Catelyn, the Tullys, Lysa | Jon Arryn, the Arryns. (Putting the
    // partner beside each married sibling split the set: Catelyn sat with the Starks, away from Lysa and Edmure.)
    // Other married siblings stay with their brothers and sisters; their partners are placed with their own family.
    const placeSiblings = (children: string[], continuing = false) => {
        const kids = children.filter((c) => !x.has(c));
        if (!kids.length) return;
        const freePartner = (c: string) => spouses(c).find((s) => !x.has(s));
        const exit = kids.find((c) => freePartner(c));
        const order = [...kids.filter((c) => c !== exit), ...(exit ? [exit] : [])];
        order.forEach((c, i) => place(c, i === 0 && !continuing, false));
        if (!exit) return;
        const partner = freePartner(exit)!;
        place(partner, false, false);
        placeSiblings(birthFamily.get(partner) ?? [], true);
    };
    const ids = Object.keys(t.people);
    const done = new Set<Tree["families"][number]>();
    for (let row = 0; row <= Math.max(0, ...gen.values()); row++) {
        const inRow = ids.filter((id) => gen.get(id) === row);
        // People with no parents recorded, unless they married someone who has (they're placed beside them).
        // (Through placeSiblings, so a set of brothers and sisters with no parents recorded, like Gavilar and Dalinar
        // Kholin, still sits together, and partners chain on as above.)
        for (const id of inRow)
            if (!isChild.has(id) && spouses(id).every((s) => !isChild.has(s)))
                placeSiblings(birthFamily.get(id) ?? [id]);
        for (const id of inRow) placeSiblings(birthFamily.get(id) ?? [id]); // anyone still left
        for (const id of inRow.sort((a, b) => x.get(a)! - x.get(b)!))
            for (const f of asParent.get(id) ?? []) {
                if (done.has(f)) continue;
                done.add(f);
                placeSiblings(f.children);
            }
    }
    for (const id of ids) place(id, true); // defensive: anyone without a row walk (shouldn't happen)
    sweepCrossings(t, gen, x, blockOf);
    const span = new Map<number, [number, number]>();
    for (const [id, v] of x) {
        const r = gen.get(id)!;
        const [lo, hi] = span.get(r) ?? [v, v];
        span.set(r, [Math.min(lo, v), Math.max(hi, v)]);
    }
    for (const [id, v] of x) {
        const [lo, hi] = span.get(gen.get(id)!)!;
        x.set(id, v - (lo + hi) / 2);
    }
    return x;
}

function sweepCrossings(t: Tree, gen: Map<string, number>, x: Map<string, number>, blockOf: Map<string, number>): void {
    const parentsOf = new Map<string, string[]>();
    const kidsOf = new Map<string, string[]>();
    for (const f of t.families)
        for (const p of f.parents)
            for (const c of f.children) {
                (parentsOf.get(c) ?? parentsOf.set(c, []).get(c)!).push(p);
                (kidsOf.get(p) ?? kidsOf.set(p, []).get(p)!).push(c);
            }
    const rows = new Map<number, string[]>();
    for (const [id, r] of gen) (rows.get(r) ?? rows.set(r, []).get(r)!).push(id);
    const last = Math.max(0, ...rows.keys());
    // Re-lay one row in the order of its blocks' keys (the mean x of each block's relatives in `by`).
    const reorder = (row: number, by: Map<string, string[]>) => {
        const ids = (rows.get(row) ?? []).sort((a, b) => x.get(a)! - x.get(b)!);
        const groups = new Map<number, string[]>();
        for (const id of ids)
            (groups.get(blockOf.get(id)!) ?? groups.set(blockOf.get(id)!, []).get(blockOf.get(id)!)!).push(id);
        const keyed = [...groups.values()].map((members, i) => {
            const rel = members.flatMap((m) => by.get(m) ?? []).filter((r) => x.has(r));
            const own = members.reduce((s, m) => s + x.get(m)!, 0) / members.length;
            return { members, i, key: rel.length ? rel.reduce((s, r) => s + x.get(r)!, 0) / rel.length : own };
        });
        keyed.sort((a, b) => a.key - b.key || a.i - b.i);
        let pos = 0;
        keyed.forEach(({ members }, k) => {
            if (k) pos += SEED_GROUP;
            for (const m of members) (x.set(m, pos), (pos += SEED_STEP));
            pos -= SEED_STEP;
        });
    };
    // Each half-sweep is kept only if it reduces crossings (a whole round that didn't help stopped the search, though
    // one of its halves often would have). The downward half runs last, so children end up under their parents.
    let best = linkCrossings(t, gen, x);
    const attempt = (sweep: () => void) => {
        const saved = new Map(x);
        sweep();
        const now = linkCrossings(t, gen, x);
        if (now < best) return ((best = now), true);
        for (const [id, v] of saved) x.set(id, v);
        return false;
    };
    for (let i = 0; i < SWEEPS && best > 0; i++) {
        const up = attempt(() => {
            for (let r = last - 1; r >= 0; r--) reorder(r, kidsOf); // upwards: parents over their children
        });
        const down = attempt(() => {
            for (let r = 1; r <= last; r++) reorder(r, parentsOf); // downwards: children under their parents
        });
        if (!up && !down) break;
    }
}

/**
 * How many lines from a family to its children cross, between rows next to each other, for an order along each row.
 * A family's lines start from its marriage node, between its parents (as drawn), so a couple's own lines to their
 * children never count as crossing each other; only lines of different families do.
 */
export function linkCrossings(t: Tree, gen: Map<string, number>, x: Map<string, number>): number {
    const byRow = new Map<number, [number, number][]>();
    for (const f of t.families) {
        if (!f.parents.length) continue;
        const r = Math.max(...f.parents.map((p) => gen.get(p)!));
        const u = f.parents.reduce((s, p) => s + x.get(p)!, 0) / f.parents.length;
        for (const c of f.children)
            if (gen.get(c) === r + 1) (byRow.get(r) ?? byRow.set(r, []).get(r)!).push([u, x.get(c)!]);
    }
    let n = 0;
    for (const segs of byRow.values())
        for (let i = 0; i < segs.length; i++)
            for (let j = i + 1; j < segs.length; j++)
                if ((segs[i][0] - segs[j][0]) * (segs[i][1] - segs[j][1]) < 0) n++;
    return n;
}
