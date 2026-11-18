import type { Tree } from "./data/schema.ts";

// Generation number per person (0 = oldest). Parents sit one generation above their children, and spouses share
// a generation, so people who married in line up with their partner rather than floating up to the top row.
// Solved as longest-path layering over a graph where each family's parents are merged into one group:
// group → child-group edges, then every person takes their group's level.
export function generations(t: Tree): Map<string, number> {
    const ids = Object.keys(t.people);
    // Union-find: co-parents of any family form one group.
    const root = new Map(ids.map((id) => [id, id]));
    const find = (id: string): string => {
        while (root.get(id) !== id) id = root.get(id)!;
        return id;
    };
    for (const f of t.families) for (const p of f.parents.slice(1)) root.set(find(p), find(f.parents[0]));

    // Edges between groups: parent group → child's group. Families with no parents add no edges.
    const edges = new Map<string, Set<string>>();
    for (const f of t.families) {
        if (!f.parents.length) continue;
        const from = find(f.parents[0]);
        for (const c of f.children) {
            const to = find(c);
            if (to === from) continue; // a child married into its own parents' group: cannot be layered, skip
            (edges.get(from) ?? edges.set(from, new Set()).get(from)!).add(to);
        }
    }

    // Longest path from roots (Kahn's algorithm). A cycle would leave groups unlevelled; they fall back to 0.
    const groups = [...new Set(ids.map(find))];
    const indeg = new Map(groups.map((g) => [g, 0]));
    for (const tos of edges.values()) for (const to of tos) indeg.set(to, indeg.get(to)! + 1);
    const level = new Map(groups.map((g) => [g, 0]));
    const queue = groups.filter((g) => indeg.get(g) === 0);
    while (queue.length) {
        const g = queue.shift()!;
        for (const to of edges.get(g) ?? []) {
            level.set(to, Math.max(level.get(to)!, level.get(g)! + 1));
            indeg.set(to, indeg.get(to)! - 1);
            if (indeg.get(to) === 0) queue.push(to);
        }
    }

    // Longest-path pushes childless roots (e.g. an in-law's parents) to the top. Pull every group down as far as its
    // children allow, so ancestors sit just above their descendants instead of in the oldest row.
    const order = [...level.keys()].sort((a, b) => level.get(b)! - level.get(a)!);
    for (const g of order) {
        const kids = [...(edges.get(g) ?? [])];
        if (kids.length) level.set(g, Math.min(...kids.map((k) => level.get(k)!)) - 1);
    }
    const min = Math.min(...level.values());
    const gen = new Map(ids.map((id) => [id, level.get(find(id))! - min]));

    // Descent repair. Merging co-parents into one group is right for ordinary families (it's what puts married-in
    // spouses on their partner's row), but in a densely intermarried pantheon it chains generations together:
    // Jupiter partners Venus, Venus partners Mars, Mars is Jupiter's son, so a father and son end up in one group, or
    // in groups the layering can't order, and the Roman gods had 55 parents on or below their own child. Walk parents
    // before children and push any child that isn't below every parent down to one row below the deepest.
    //
    // Only those children move, so a tree that was already valid (every saga except the Roman gods, measured) gets
    // exactly the same layout as before. A cycle in bad data (someone their own ancestor) can't be ordered; the walk
    // is bounded so it ends rather than looping.
    const kidsOf = new Map<string, string[]>(ids.map((id) => [id, []]));
    const parentCount = new Map(ids.map((id) => [id, 0]));
    for (const f of t.families)
        for (const p of f.parents)
            for (const c of f.children)
                if (p !== c && kidsOf.has(p) && parentCount.has(c)) {
                    kidsOf.get(p)!.push(c);
                    parentCount.set(c, parentCount.get(c)! + 1);
                }
    const remaining = new Map(parentCount);
    const ready = ids.filter((id) => remaining.get(id) === 0);
    for (let i = 0; i < ready.length; i++) {
        const p = ready[i];
        for (const c of kidsOf.get(p)!) {
            if (gen.get(c)! <= gen.get(p)!) gen.set(c, gen.get(p)! + 1);
            remaining.set(c, remaining.get(c)! - 1);
            if (remaining.get(c) === 0) ready.push(c);
        }
    }
    alignSiblings(t, gen, kidsOf);
    return gen;
}

/**
 * Siblings on one row where possible. A sibling who married into another generation (or whose parents were pushed
 * apart by intermarriage) can end up a row or more from their brothers and sisters. Try moving them, with their
 * spouses on the same row, to a sibling's row; keep a move only if every parent stays above every child, couples
 * stay together, and fewer sibling sets are split overall. Greedy and bounded, so it always ends.
 */
function alignSiblings(t: Tree, gen: Map<string, number>, kidsOf: Map<string, string[]>): void {
    const parentsOf = new Map<string, string[]>([...kidsOf.keys()].map((id) => [id, []]));
    const spousesOf = new Map<string, Set<string>>([...kidsOf.keys()].map((id) => [id, new Set()]));
    for (const [p, kids] of kidsOf) for (const c of kids) parentsOf.get(c)!.push(p);
    for (const f of t.families)
        for (const a of f.parents) for (const b of f.parents) if (a !== b) spousesOf.get(a)?.add(b);
    const sets = t.families.filter((f) => f.children.length > 1).map((f) => f.children.filter((c) => gen.has(c)));
    const splits = () => sets.reduce((n, s) => n + new Set(s.map((c) => gen.get(c))).size - 1, 0);

    // A person and every spouse (transitively) on their row: they move together so couples stay aligned.
    const groupOf = (id: string) => {
        const row = gen.get(id)!;
        const group = new Set([id]);
        for (const g of group) for (const s of spousesOf.get(g)!) if (gen.get(s) === row) group.add(s);
        return group;
    };
    const fits = (group: Set<string>) =>
        [...group].every(
            (g) =>
                parentsOf.get(g)!.every((p) => gen.get(p)! < gen.get(g)!) &&
                kidsOf.get(g)!.every((c) => gen.get(c)! > gen.get(g)!)
        );

    let best = splits();
    for (let pass = 0; pass < 5 && best > 0; pass++) {
        let moved = false;
        for (const s of sets)
            for (const c of s)
                for (const row of new Set(s.map((x) => gen.get(x)!))) {
                    const delta = row - gen.get(c)!;
                    if (!delta) continue;
                    const group = groupOf(c);
                    for (const g of group) gen.set(g, gen.get(g)! + delta);
                    const now = splits();
                    if (fits(group) && now < best) {
                        best = now;
                        moved = true;
                        break;
                    }
                    for (const g of group) gen.set(g, gen.get(g)! - delta); // undo
                }
        if (!moved) break;
    }
    const min = Math.min(...gen.values());
    if (min) for (const [id, g] of gen) gen.set(id, g - min); // keep the oldest row at 0
}
