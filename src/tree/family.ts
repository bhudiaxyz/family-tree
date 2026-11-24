// Family queries: pure questions about a Tree (relatives, lines of descent, link words, house depths).
//
// What it does: relatives (relatives, siblingsOf, cousinsOf, immediateFamily, descendantsOf, descendantCount,
// namesakes, parentsOf, childrenOf); lines of descent (lineageRoles/lineage for the highlight, ancestry for the panel
// trail, tourLine and longestLine for the guided tour); link words (parentLabel, childLabel, siblingLabel); house
// depth planes (houseDepths).
// Usage: imported by graph/ (graph.ts, core, highlight, siblings) and most of src/ui. No three.js or DOM imports, so
// it is unit-tested directly in scripts/family.test.mts.
// Notes: search by name or relationship is in search.ts, and naming how two people are related in relationship.ts;
// this answers who someone's relatives are. Anything that must tell two people with the same name apart goes by id,
// never by name.
import type { Tree } from "../data/schema.ts";

type Sex = Tree["people"][string]["sex"];
type Family = Tree["families"][number];

/** How a person in someone's line relates to them: which side, and how many generations away (0 for self/spouse). */
export type LineRole = {
    side: "self" | "ancestor" | "descendant" | "spouse" | "sibling" | "cousin";
    distance: number;
};

const by = (sex: Sex, m: string, f: string) => (sex === "m" ? m : f);

/**
 * The family a person was born into: one they're a child of, with at least one parent recorded, preferring a birth
 * family over an adoptive one. Undefined for someone whose parents aren't in the tree.
 */
export const birthFamily = (tree: Tree, id: string): Family | undefined =>
    tree.families.find((f) => f.children.includes(id) && f.parents.length && !f.adoptive) ??
    tree.families.find((f) => f.children.includes(id) && f.parents.length);

/** The person and their immediate family: parents, siblings, spouses and children (for "Fit family"). */
export function immediateFamily(tree: Tree, id: string): string[] {
    const out = new Set([id]);
    for (const f of tree.families)
        if (f.children.includes(id) || f.parents.includes(id))
            for (const p of [...f.parents, ...f.children]) out.add(p);
    return [...out];
}

/** Brothers and sisters: anyone sharing a family as a child (half and foster siblings included), without the person. */
export function siblingsOf(tree: Tree, id: string): string[] {
    const out = new Set<string>();
    for (const f of tree.families) if (f.children.includes(id)) for (const c of f.children) out.add(c);
    out.delete(id);
    return [...out];
}

export const parentsOf = (tree: Tree, id: string) =>
    tree.families.filter((f) => f.children.includes(id)).flatMap((f) => f.parents);

export const childrenOf = (tree: Tree, id: string) =>
    tree.families.filter((f) => f.parents.includes(id)).flatMap((f) => f.children);

/** First cousins: children of a parent's siblings, without the person or their own siblings. */
export function cousinsOf(tree: Tree, id: string): string[] {
    const out = new Set<string>();
    for (const p of parentsOf(tree, id))
        for (const u of siblingsOf(tree, p)) for (const c of childrenOf(tree, u)) out.add(c);
    out.delete(id);
    for (const s of siblingsOf(tree, id)) out.delete(s);
    return [...out];
}

/** Everyone sharing this person's exact name, the person included (one entry when the name is unique). */
export const namesakes = (tree: Tree, id: string): string[] =>
    Object.keys(tree.people).filter((o) => tree.people[o].name === tree.people[id].name);

/** Everyone descended from this person (not the person): for collapsing a branch. */
export function descendantsOf(tree: Tree, id: string): Set<string> {
    const out = new Set<string>();
    const queue = [id];
    while (queue.length)
        for (const c of childrenOf(tree, queue.shift()!)) if (!out.has(c) && c !== id) (out.add(c), queue.push(c));
    return out;
}

/**
 * A guided tour's route through one person: down from their oldest known ancestor to them (as the panel's line of
 * descent), then on through their longest line of descendants. Without a person, the tree's longest line.
 */
export function tourLine(tree: Tree, id?: string | null): string[] {
    if (!id || !tree.people[id]) return longestLine(tree);
    // Generations of recorded descent below each person, memoised; `visiting` stops a cycle in bad data.
    const depth = new Map<string, number>();
    const visiting = new Set<string>();
    const below = (pid: string): number => {
        const known = depth.get(pid);
        if (known !== undefined) return known;
        if (visiting.has(pid)) return 0;
        visiting.add(pid);
        const kids = childrenOf(tree, pid);
        const d = kids.length ? 1 + Math.max(...kids.map(below)) : 0;
        visiting.delete(pid);
        depth.set(pid, d);
        return d;
    };
    const line = ancestry(tree, id);
    const seen = new Set(line);
    for (let cur = id; ;) {
        const kids = childrenOf(tree, cur).filter((c) => !seen.has(c));
        if (!kids.length) break;
        cur = kids.reduce((a, b) => (below(b) > below(a) ? b : a)); // the child with the deepest line; first on a tie
        seen.add(cur);
        line.push(cur);
    }
    return line;
}

/**
 * The longest line of descent in the tree, oldest first: the tour's route when nobody is selected. Ties go to the
 * line starting earliest in the file, where a saga lists its main figures.
 */
export function longestLine(tree: Tree): string[] {
    let best: string[] = [];
    for (const id of Object.keys(tree.people)) {
        const line = ancestry(tree, id);
        if (line.length > best.length) best = line;
    }
    return best;
}

/**
 * The person, all their ancestors and descendants, and their spouses, each with its side and generation distance.
 * Breadth-first, so `distance` is the shortest number of generations (a cousin marriage can reach someone twice).
 */
export function lineageRoles(tree: Tree, id: string): Map<string, LineRole> {
    const roles = new Map<string, LineRole>([[id, { side: "self", distance: 0 }]]);
    const walk = (up: boolean) => {
        let frontier = [id];
        for (let d = 1; frontier.length; d++) {
            const next: string[] = [];
            for (const cur of frontier)
                for (const f of tree.families) {
                    if (!(up ? f.children : f.parents).includes(cur)) continue;
                    for (const n of up ? f.parents : f.children)
                        if (!roles.has(n)) {
                            roles.set(n, { side: up ? "ancestor" : "descendant", distance: d });
                            next.push(n);
                        }
                }
            frontier = next;
        }
    };
    walk(true);
    walk(false);
    for (const f of tree.families)
        if (f.parents.includes(id))
            for (const p of f.parents) if (!roles.has(p)) roles.set(p, { side: "spouse", distance: 0 });
    return roles;
}

/** The person, all their ancestors and descendants, and their spouses: everything a highlight keeps lit. */
export const lineage = (tree: Tree, id: string): Set<string> => new Set(lineageRoles(tree, id).keys());

/**
 * The person's line back to their oldest known ancestor, oldest first: [Adam, Seth, …, Noah, id]. One clear line, not
 * a tree: at each step it follows the parent with the deeper recorded ancestry (so Rahul Gandhi's line runs through
 * Indira to the Nehrus, not to Feroze, whose parents aren't recorded), the father on a tie, and birth parents before
 * adoptive ones.
 */
export function ancestry(tree: Tree, id: string): string[] {
    const birthOf = (pid: string) => birthFamily(tree, pid);
    // Generations of recorded ancestry above each person, memoised; `visiting` stops a cycle in bad data.
    const depth = new Map<string, number>();
    const visiting = new Set<string>();
    const depthOf = (pid: string): number => {
        const known = depth.get(pid);
        if (known !== undefined) return known;
        if (visiting.has(pid)) return 0;
        visiting.add(pid);
        const fam = birthOf(pid);
        const d = fam ? 1 + Math.max(...fam.parents.map(depthOf)) : 0;
        visiting.delete(pid);
        depth.set(pid, d);
        return d;
    };
    const line = [id];
    const seen = new Set(line);
    for (let fam = birthOf(id); fam;) {
        const best = Math.max(...fam.parents.map(depthOf));
        const deepest = fam.parents.filter((p) => depthOf(p) === best);
        const next = deepest.find((p) => tree.people[p].sex === "m") ?? deepest[0];
        if (seen.has(next)) break; // bad data (someone their own ancestor) can't loop forever
        seen.add(next);
        line.unshift(next);
        fam = birthOf(next);
    }
    return line;
}

/** How many descendants someone has, and over how many generations (for the panel: "12 descendants, 4 generations"). */
export function descendantCount(tree: Tree, id: string): { people: number; generations: number } {
    let people = 0;
    let generations = 0;
    for (const r of lineageRoles(tree, id).values())
        if (r.side === "descendant") {
            people++;
            generations = Math.max(generations, r.distance);
        }
    return { people, generations };
}

/** Relatives grouped for the details panel, in a stable order: [label, ids][]. Adoptive families are labelled so. */
export function relatives(tree: Tree, id: string): [string, string[]][] {
    const groups = new Map<string, Set<string>>();
    const add = (label: string, rid: string) => {
        if (!groups.has(label)) groups.set(label, new Set());
        groups.get(label)!.add(rid);
    };
    for (const f of tree.families) {
        if (f.children.includes(id)) {
            for (const p of f.parents) add(f.adoptive ? "Adoptive parents" : "Parents", p);
            for (const c of f.children) if (c !== id) add(f.adoptive ? "Foster siblings" : "Siblings", c);
        }
        if (f.parents.includes(id)) {
            for (const p of f.parents) if (p !== id) add("Spouse", p);
            for (const c of f.children) add(f.adoptive ? "Adopted children" : "Children", c);
        }
    }
    return [...groups].map(([label, ids]) => [label, [...ids]]);
}

/** Label for the link from a parent to their family's union node. */
export function parentLabel(tree: Tree, parent: string, family: Family): string {
    const sex = tree.people[parent].sex;
    if (!family.children.length) return by(sex, "husband", "wife");
    return (family.adoptive ? "adoptive " : "") + by(sex, "father", "mother");
}

/** Label for the link from a family's union node to a child. */
export function childLabel(tree: Tree, child: string, family: Family): string {
    return (family.adoptive ? "adopted " : "") + by(tree.people[child].sex, "son", "daughter");
}

/** Label for a sibling pair. */
export function siblingLabel(tree: Tree, a: string, b: string): string {
    const sa = tree.people[a].sex;
    return sa === tree.people[b].sex ? by(sa, "brothers", "sisters") : "brother & sister";
}

/** z plane per house for the depth force: spread over `depth`, biggest houses nearest the middle, alternating sides. */
export function houseDepths(tree: Tree, depth: number): Map<string, number> {
    const houses = Object.keys(tree.houseColors);
    const size = new Map(houses.map((h) => [h, 0]));
    for (const p of Object.values(tree.people)) size.set(p.house, (size.get(p.house) ?? 0) + 1);
    const ordered = [...houses].sort((a, b) => size.get(b)! - size.get(a)!);
    return new Map(
        ordered.map((h, i) => {
            const k = houses.length > 1 ? i / (houses.length - 1) : 0;
            return [h, (i % 2 ? -1 : 1) * k * (depth / 2)];
        })
    );
}
