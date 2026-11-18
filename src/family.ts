// Pure family-tree queries over a Tree: no three.js, no DOM, so they are unit-tested in scripts/family.test.mts.
import type { Tree } from "./data/schema.ts";

type Sex = Tree["people"][string]["sex"];
const by = (sex: Sex, m: string, f: string) => (sex === "m" ? m : f);
type Family = Tree["families"][number];

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

/** How a person in someone's line relates to them: which side, and how many generations away (0 for self/spouse). */
export type LineRole = { side: "self" | "ancestor" | "descendant" | "spouse" | "sibling"; distance: number };

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

/** Lower-case, without accents or punctuation, so "Apsû" matches "apsu" and "García" matches "garcia". */
export const fold = (s: string) =>
    s
        .normalize("NFKD")
        .replace(/[̀-ͯ]/g, "")
        .toLowerCase()
        .replace(/[^\p{L}\p{N}]+/gu, " ")
        .trim();

/**
 * Edit distance between two words, counting a swap of two neighbouring letters as one edit (optimal string
 * alignment), the commonest typo. Returns `max + 1` straight away when the lengths alone differ by more than `max`.
 */
function editDistance(a: string, b: string, max: number): number {
    if (Math.abs(a.length - b.length) > max) return max + 1;
    // No early exit inside the loop: a swap is only credited a row later, so a row that looks past `max` can still
    // come back to it. Names are short, so the full table is cheap.
    let before: number[] = [];
    let prev = Array.from({ length: b.length + 1 }, (_, j) => j);
    for (let i = 1; i <= a.length; i++) {
        const cur = [i];
        for (let j = 1; j <= b.length; j++) {
            cur[j] = Math.min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + (a[i - 1] === b[j - 1] ? 0 : 1));
            if (i > 1 && j > 1 && a[i - 1] === b[j - 2] && a[i - 2] === b[j - 1])
                cur[j] = Math.min(cur[j], before[j - 2] + 1);
        }
        before = prev;
        prev = cur;
    }
    return prev[b.length];
}

/**
 * People matching a search, best first: exact name, then names starting with the query, then containing it, then a
 * close spelling of any word in the name (one typo from 4 letters, two from 6: "Ghandi" finds Gandhi).
 * Accents, case and punctuation are ignored throughout. Returns person ids.
 */
export function searchPeople(tree: Tree, query: string, limit = Infinity): string[] {
    const q = fold(query);
    if (!q) return [];
    const typos = q.length >= 6 ? 2 : q.length >= 4 ? 1 : 0;
    const scored: [string, number, number][] = [];
    Object.entries(tree.people).forEach(([id, p], order) => {
        const n = fold(p.name);
        let score = -1;
        if (n === q) score = 0;
        else if (n.startsWith(q) || n.split(" ").some((w) => w.startsWith(q))) score = 1;
        else if (n.includes(q)) score = 2;
        else if (typos) {
            // Compare the query with each word of the name, and with the whole name for multi-word queries.
            const d = Math.min(editDistance(q, n, typos), ...n.split(" ").map((w) => editDistance(q, w, typos)));
            if (d <= typos) score = 2 + d;
        }
        if (score >= 0) scored.push([id, score, order]);
    });
    // Within a tier, keep the file's order (the saga's main figures come first), as the search always has.
    scored.sort((a, b) => a[1] - b[1] || a[2] - b[2]);
    return scored.slice(0, limit).map(([id]) => id);
}

/** Find one person by name: the best match from searchPeople, or null. */
export const findByName = (tree: Tree, query: string): string | null => searchPeople(tree, query, 1)[0] ?? null;

/**
 * A short way to tell apart people who share a name: "son of Methushael", "father of Noah", "wife of Abraham", or
 * null for anyone whose name is unique in the tree. Shown beside the name in search suggestions.
 */
export function distinguish(tree: Tree, id: string): string | null {
    const p = tree.people[id];
    const same = Object.values(tree.people).filter((o) => o.name === p.name).length;
    if (same < 2) return null;
    const name = (pid: string) => tree.people[pid].name;
    const birth = birthFamily(tree, id);
    if (birth) return `${by(p.sex, "son", "daughter")} of ${birth.parents.map(name).join(" & ")}`;
    const own = tree.families.filter((f) => f.parents.includes(id));
    const child = own.flatMap((f) => f.children)[0];
    if (child) return `${by(p.sex, "father", "mother")} of ${name(child)}`;
    const spouse = own.flatMap((f) => f.parents).find((s) => s !== id);
    if (spouse) return `${by(p.sex, "husband", "wife")} of ${name(spouse)}`;
    return p.house;
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
