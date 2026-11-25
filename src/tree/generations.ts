// Generations: assigns every person a layout row (0 = oldest) so parents sit above children.
//
// What it does: groups people who must share a row (union-find), then longest-path layers the groups, pulls childless
// roots down next to their descendants, repairs any child not below a parent, and finally greedily moves people to
// satisfy the sibling/couple preference. The two modes (SiblingMode) differ in what is grouped and aligned:
//   "together" (default): each family's children share a row; a couple may sit on two rows (alignSpouses).
//   "apart": each family's co-parents share a row; a sibling who married across generations sits with their partner
//   (alignSiblings).
// Usage: generations(tree, mode) is called by graph/graph.ts showTree() and by scripts/generations.test.mts, which
// covers it. The order along each row is row-order.ts's. No three.js or DOM imports.
// Notes: priorities, highest first: descent always holds (every parent strictly above every child, even in a cyclic or
// densely intermarried tree); then the chosen mode's grouping; then the other preference only where it fits; then,
// only where birth dates are recorded, the same decade on the same row (alignEras). The
// alignment passes are greedy and bounded (5 or 8 passes), so they always end but may leave some splits.

import { bornYear, type Tree } from "../data/schema.ts";

/**
 * Which rule wins when siblings and couples can't both share a row (someone married into another generation):
 * - "together" (default): brothers and sisters always share a row (unless one is also another's child, as Daphne is
 *   Ladon's in the Roman file); a couple may sit on two rows, joined by a slope.
 * - "apart": couples always share a row; a sibling who married across generations sits with their partner.
 */
export type SiblingMode = "together" | "apart";

// Generation number per person (0 = oldest). Parents sit one generation above their children, siblings share a
// row (or, with "apart", spouses do), and people who married in line up with their partner where they can.
// Solved as longest-path layering over a graph whose nodes are groups that must share a row: each family's children
// ("together") or each family's co-parents ("apart"). Group → child-group edges, then every person takes their
// group's level.
export function generations(t: Tree, mode: SiblingMode = "together"): Map<string, number> {
    const ids = Object.keys(t.people);
    // Union-find over the people who must share a row.
    const root = new Map(ids.map((id) => [id, id]));
    const find = (id: string): string => {
        while (root.get(id) !== id) id = root.get(id)!;
        return id;
    };
    for (const f of t.families) {
        const same = mode === "together" ? f.children : f.parents;
        for (const p of same.slice(1)) root.set(find(p), find(same[0]));
    }

    // Edges between groups: each parent's group → each child's group. Families with no parents add no edges.
    const edges = new Map<string, Set<string>>();
    for (const f of t.families)
        for (const p of f.parents)
            for (const c of f.children) {
                const from = find(p);
                const to = find(c);
                if (to === from) continue; // a child grouped with their own parent: cannot be layered, skip
                (edges.get(from) ?? edges.set(from, new Set()).get(from)!).add(to);
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
    if (mode === "together") alignSpouses(t, gen, kidsOf, ready);
    else alignSiblings(t, gen, kidsOf);
    alignEras(t, gen, kidsOf); // where birth dates are recorded: the same decade on the same row
    return gen;
}

/**
 * Couples on one row where possible, for "together" (the mirror of alignSiblings). Layering by sibling groups leaves
 * a spouse wherever their own family puts them, often a row from their partner. For each couple on two rows, try
 * moving either partner (with all their brothers and sisters, so no set is split) to the other's row; keep the move
 * only if every parent stays above every child and fewer couples are split. Greedy and bounded, so it always ends.
 *
 * If that can't work (the partner's parents would then be on their row), try moving their whole branch instead: the
 * brothers and sisters, every ancestor and the ancestors' own brothers and sisters, so generations of one family stay
 * level with the other's. Anyone below then too close to a parent is pushed down. Kept only if fewer couples are
 * split and no brothers and sisters are. Harry Potter's line has three recorded generations and the Weasleys' two, so
 * Ginny sat a row above Harry; moving the Weasley branch down a row puts Arthur and Molly level with James and Lily,
 * and Ginny with Harry (and Ron with Hermione).
 */
function alignSpouses(t: Tree, gen: Map<string, number>, kidsOf: Map<string, string[]>, order: string[]): void {
    const siblingsOf = new Map<string, Set<string>>([...kidsOf.keys()].map((id) => [id, new Set([id])]));
    for (const f of t.families) for (const a of f.children) for (const b of f.children) siblingsOf.get(a)?.add(b);
    // Sibling groups are transitive (half-siblings link two families): close each person's set.
    for (const set of siblingsOf.values()) for (const x of set) for (const y of siblingsOf.get(x)!) set.add(y);
    const couples = t.families.filter((f) => f.parents.length === 2).map((f) => f.parents as [string, string]);
    const split = () => couples.filter(([a, b]) => gen.get(a) !== gen.get(b)).length;
    const descentHolds = (group: Set<string>) =>
        [...group].every(
            (g) =>
                kidsOf.get(g)!.every((c) => gen.get(c)! > gen.get(g)!) &&
                [...kidsOf].every(([p, kids]) => !kids.includes(g) || gen.get(p)! < gen.get(g)!)
        );
    const parentsOf = new Map<string, string[]>([...kidsOf.keys()].map((id) => [id, []]));
    for (const [p, kids] of kidsOf) for (const c of kids) parentsOf.get(c)!.push(p);
    const sets = t.families.filter((f) => f.children.length > 1).map((f) => f.children.filter((c) => gen.has(c)));
    const siblingSplits = () => sets.reduce((n, set) => n + new Set(set.map((c) => gen.get(c))).size - 1, 0);
    const spousesOf = new Map<string, string[]>([...kidsOf.keys()].map((id) => [id, []]));
    for (const [x, y] of couples) (spousesOf.get(x)!.push(y), spousesOf.get(y)!.push(x));
    // Someone's branch: their brothers and sisters and every ancestor, with each ancestor's brothers and sisters, and
    // anyone married into it on the same row (Fleur beside Bill, Hermione beside Ron), so those couples move together.
    const branchOf = (who: string) => {
        const branch = new Set<string>();
        const todo = [who];
        for (let x = todo.pop(); x !== undefined; x = todo.pop()) {
            const row = gen.get(x)!;
            const spouses = spousesOf.get(x)!.filter((s) => gen.get(s) === row);
            for (const y of [...siblingsOf.get(x)!, ...parentsOf.get(x)!, ...spouses])
                if (!branch.has(y)) branch.add(y) && todo.push(y);
        }
        return branch;
    };
    // Move a branch by `delta` rows, then push anyone left on or above a parent down below them (parents first).
    const moveBranch = (branch: Set<string>, delta: number) => {
        for (const g of branch) gen.set(g, gen.get(g)! + delta);
        for (const c of order) {
            const lowest = Math.max(-Infinity, ...parentsOf.get(c)!.map((p) => gen.get(p)!));
            if (gen.get(c)! <= lowest) gen.set(c, lowest + 1);
        }
    };
    let best = split();
    let bestSiblings = siblingSplits();
    for (let pass = 0; pass < 8 && best > 0; pass++) {
        let moved = false;
        for (const [a, b] of couples) {
            if (gen.get(a) === gen.get(b)) continue;
            for (const [who, to] of [
                [a, gen.get(b)!],
                [b, gen.get(a)!],
            ] as const) {
                const group = siblingsOf.get(who)!;
                const delta = to - gen.get(who)!;
                for (const g of group) gen.set(g, gen.get(g)! + delta);
                const now = split();
                if (descentHolds(group) && now < best) {
                    best = now;
                    moved = true;
                    break;
                }
                for (const g of group) gen.set(g, gen.get(g)! - delta); // undo
            }
            if (moved || gen.get(a) === gen.get(b)) continue;
            // The whole branch instead (see above): the higher partner's, moved down. Only down: moving a branch up
            // left its descendants behind (Harry and Ginny's children two rows below them), whereas moving down pushes
            // anyone below along with it.
            for (const [who, to] of [
                [a, gen.get(b)!],
                [b, gen.get(a)!],
            ] as const) {
                if (to <= gen.get(who)!) continue;
                const saved = new Map(gen);
                moveBranch(branchOf(who), to - gen.get(who)!);
                const now = split();
                const sib = siblingSplits();
                if (now < best && sib <= bestSiblings) {
                    best = now;
                    bestSiblings = sib;
                    moved = true;
                    break;
                }
                for (const [id, g] of saved) gen.set(id, g); // undo
            }
        }
        if (!moved) break;
    }
    const min = Math.min(...gen.values());
    if (min) for (const [id, g] of gen) gen.set(id, g - min); // keep the oldest row at 0
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

/**
 * Eras, where birth dates are recorded: people born in the same decade (the 1480s, the 1490s…) share a row where they
 * can. For each dated person on a different row from others of their decade, try moving their group to that row: their
 * brothers and sisters and the partners beside them, and every descendant with theirs, so nothing inside the group
 * changes shape. A move is kept only if fewer same-decade pairs end up on different rows, every parent stays above
 * every child, and no more sibling sets or couples are split than before: generations still come first, and dates
 * only choose between rows the family structure allows. A tree with no dates (most sagas) scores 0 and is left
 * exactly as it was. Greedy and bounded (ERA_PASSES), so it always ends.
 */
const ERA_PASSES = 6;
const ERA_EXTRA_ROWS = 2; // rows the era pass may add to the tree's height
function alignEras(t: Tree, gen: Map<string, number>, kidsOf: Map<string, string[]>): void {
    const decade = new Map<string, number>();
    for (const [id, p] of Object.entries(t.people)) {
        const y = bornYear(p);
        if (y !== null && gen.has(id)) decade.set(id, Math.floor(y / 10));
    }
    const dated = [...decade.keys()];
    // Same-decade pairs on different rows: what this pass reduces.
    const eraSplits = () => {
        let n = 0;
        for (let i = 0; i < dated.length; i++)
            for (let j = i + 1; j < dated.length; j++)
                if (decade.get(dated[i]) === decade.get(dated[j]) && gen.get(dated[i]) !== gen.get(dated[j])) n++;
        return n;
    };
    if (eraSplits() === 0) return;

    const parentsOf = new Map<string, string[]>([...kidsOf.keys()].map((id) => [id, []]));
    for (const [p, kids] of kidsOf) for (const c of kids) parentsOf.get(c)!.push(p);
    const spousesOf = new Map<string, string[]>([...kidsOf.keys()].map((id) => [id, []]));
    const couples = t.families.filter((f) => f.parents.length === 2).map((f) => f.parents as [string, string]);
    for (const [a, b] of couples) (spousesOf.get(a)!.push(b), spousesOf.get(b)!.push(a));
    const sets = t.families.filter((f) => f.children.length > 1).map((f) => f.children.filter((c) => gen.has(c)));
    const siblingsOf = new Map<string, string[]>([...kidsOf.keys()].map((id) => [id, []]));
    for (const set of sets) for (const c of set) siblingsOf.get(c)!.push(...set);
    const splitCouples = () => couples.filter(([a, b]) => gen.get(a) !== gen.get(b)).length;
    const splitSets = () => sets.reduce((n, set) => n + new Set(set.map((c) => gen.get(c))).size - 1, 0);
    const descentHolds = () => [...kidsOf].every(([p, kids]) => kids.every((c) => gen.get(c)! > gen.get(p)!));

    // A person's group: brothers and sisters and the partners on their row, then every descendant with theirs. (A
    // person held high by one child's long line can't move: James IV of Scotland stays on the Tudors' top row, above
    // his 1470s peers, because his daughter Janet's descendants pin her, and moving her would part her from her
    // husband. Rows with too few dates to speak for them keep "Row n" labels: graph/graph.ts rowEras.)
    const groupOf = (who: string) => {
        const group = new Set<string>();
        const todo = [who];
        for (let x = todo.pop(); x !== undefined; x = todo.pop()) {
            if (group.has(x)) continue;
            group.add(x);
            const row = gen.get(x)!;
            todo.push(...siblingsOf.get(x)!, ...kidsOf.get(x)!, ...spousesOf.get(x)!.filter((s) => gen.get(s) === row));
        }
        return group;
    };

    // What a move must improve: same-decade pairs on different rows, with a couple reunited worth COUPLE_WEIGHT of
    // them, so the pass prefers moves that also bring partners together. Couples may never get worse than they are
    // at that point (checked per move, not only against the start). With more Tudor dates, taking any move that
    // grouped decades (couples merely no worse than at the start) left 11 couples split where 6 had been.
    const COUPLE_WEIGHT = 8;
    const score = () => eraSplits() + COUPLE_WEIGHT * splitCouples();
    let best = score();
    let couplesNow = splitCouples();
    const setsBefore = splitSets();
    // And the tree may grow by at most ERA_EXTRA_ROWS: unbounded, many small moves stretched the Tudors from 9 rows to 19 (two extra rows let them keep 6 couples split rather than 8).
    const height = () => Math.max(...gen.values()) - Math.min(...gen.values());
    const heightLimit = height() + ERA_EXTRA_ROWS;
    for (let pass = 0; pass < ERA_PASSES && eraSplits() > 0; pass++) {
        let moved = false;
        for (const who of dated) {
            // Rows where others of this decade sit, most of them first.
            const rows = new Map<number, number>();
            for (const o of dated)
                if (o !== who && decade.get(o) === decade.get(who))
                    rows.set(gen.get(o)!, (rows.get(gen.get(o)!) ?? 0) + 1);
            const targets = [...rows].sort((a, b) => b[1] - a[1]).map(([r]) => r);
            for (const to of targets) {
                const delta = to - gen.get(who)!;
                if (!delta) break; // already with most of their decade
                const group = groupOf(who);
                for (const g of group) gen.set(g, gen.get(g)! + delta);
                const now = score();
                const couples = splitCouples();
                if (
                    now < best &&
                    descentHolds() &&
                    couples <= couplesNow &&
                    splitSets() <= setsBefore &&
                    height() <= heightLimit
                ) {
                    best = now;
                    couplesNow = couples;
                    moved = true;
                    break;
                }
                for (const g of group) gen.set(g, gen.get(g)! - delta); // undo
            }
        }
        if (!moved) break;
    }
    const min = Math.min(...gen.values());
    if (min) for (const [id, g] of gen) gen.set(id, g - min); // keep the oldest row at 0
}
