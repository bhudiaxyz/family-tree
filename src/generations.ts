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
    return new Map(ids.map((id) => [id, level.get(find(id))! - min]));
}
