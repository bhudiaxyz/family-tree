// Relationship finder: how two people are related, in words, plus the chain of people that connects them.
//
// What it does: relate(a, b) tries four methods in order and returns the first that matches:
//   1. Blood (incl. adoptive line): find a common ancestor, count generations up from each person (ga, gb) and name
//      it: direct line when one count is 0, siblings at (1,1), aunt/uncle and niece/nephew when one count is 1,
//      cousins otherwise (degree = min - 1, removed = |ga - gb|).
//   2. Step-relations: a parent's spouse who isn't your parent, a spouse's child who isn't yours, and children of a
//      parent's spouse (step-brother).
//   3. In-laws: one marriage at either end of a blood relationship (mother-in-law, sister-in-law).
//   4. Anything further: the shortest chain through the family graph, described step by step (stepWord).
// Usage: relate() and stepWord() are used by src/ui/ (relate.ts, picking.ts, state.ts); labelAll() gives the "relative
// to" tags (panel.ts). Types: Relationship, Step, Route. No three.js or DOM imports; tested in
// scripts/relationship.test.mts.
// Notes: the closest common ancestor gives the headline, but every other route is also reported (common in
// intermarried houses). path/steps are what the graph highlights as the gold path, so keep them a connected chain.

import type { Tree } from "./data/schema.ts";

type Sex = "m" | "f";
export type Step = { from: string; to: string; via: "parent" | "child" | "spouse"; adoptive: boolean };
export type Route = { label: string; ancestors: string[]; adoptive: boolean };
export type Relationship = {
    /** Plain-English summary, e.g. "Jon Snow is the nephew of Daenerys Targaryen". */
    summary: string;
    /** Short label of how `a` relates to `b` ("nephew", "sister-in-law", "step-son"…), or null if only a path. */
    label: string | null;
    /** Kind of relationship, for styling and explanation. */
    kind: "self" | "blood" | "spouse" | "step" | "in-law" | "path";
    /** People along the connecting chain, `a` first and `b` last (for highlighting). */
    path: string[];
    /** Each hop along the path, for a step-by-step explanation. */
    steps: Step[];
    /** The closest common ancestor(s) for a blood relationship: usually a couple, sometimes one person. */
    commonAncestors: string[];
    /** Every distinct blood route, closest first. More than one when the families intermarry. */
    routes: Route[];
    /** True if the headline relationship passes through an adoption. */
    adoptive: boolean;
};

const ORDINAL = ["", "first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth", "ninth", "tenth"];
const TIMES = ["", "once", "twice", "three times", "four times", "five times", "six times"];
const ordinal = (n: number) => ORDINAL[n] ?? `${n}th`;
const times = (n: number) => TIMES[n] ?? `${n} times`;
const by = (sex: Sex, m: string, f: string) => (sex === "m" ? m : f);
/** "great-great-" style prefix for n extra generations; beyond 3, "4× great-". */
const greats = (n: number) => (n <= 0 ? "" : n <= 3 ? "great-".repeat(n) : `${n}× great-`);

// --- Graph indexes (built once per tree, cached) ----------------------------------------------------------------
type Index = {
    up: Map<string, { id: string; adoptive: boolean }[]>; // child → parents
    spouses: Map<string, Set<string>>; // person → co-parents in any family
};
const cache = new WeakMap<Tree, Index>();
function index(tree: Tree): Index {
    let ix = cache.get(tree);
    if (ix) return ix;
    ix = { up: new Map(), spouses: new Map() };
    for (const f of tree.families) {
        for (const c of f.children)
            for (const p of f.parents) {
                if (!ix.up.has(c)) ix.up.set(c, []);
                ix.up.get(c)!.push({ id: p, adoptive: !!f.adoptive });
            }
        for (const p of f.parents) {
            if (!ix.spouses.has(p)) ix.spouses.set(p, new Set());
            for (const q of f.parents) if (q !== p) ix.spouses.get(p)!.add(q);
        }
    }
    cache.set(tree, ix);
    return ix;
}

/** Name the blood relationship of a to b from generations-up counts (ga from a, gb from b). */
function bloodLabel(sexA: Sex, ga: number, gb: number, half: boolean): string {
    const h = half ? "half-" : "";
    if (ga === 0 && gb === 0) return "the same person";
    if (gb === 0) return greats(ga - 2) + (ga >= 2 ? "grand" : "") + by(sexA, "son", "daughter"); // a is below b
    if (ga === 0) return greats(gb - 2) + (gb >= 2 ? "grand" : "") + by(sexA, "father", "mother"); // a is above b
    if (ga === 1 && gb === 1) return h + by(sexA, "brother", "sister");
    // a is (ga-1) generations below b's sibling: nephew at ga 2, grandnephew at 3, great-grandnephew at 4…
    if (gb === 1) return h + greats(ga - 3) + (ga >= 3 ? "grand" : "") + by(sexA, "nephew", "niece");
    if (ga === 1) return h + greats(gb - 3) + (gb >= 3 ? "grand" : "") + by(sexA, "uncle", "aunt");
    const degree = Math.min(ga, gb) - 1;
    const removed = Math.abs(ga - gb);
    return `${h}${ordinal(degree)} cousin${removed ? ` ${times(removed)} removed` : ""}`;
}

type Blood = { ga: number; gb: number; label: string; ancestors: string[]; adoptive: boolean };

// Every (generations-up) distance from `from` to each ancestor, by any route: Map<ancestor, Set<distance>>.
// Unlike ancestors(), which keeps only the shortest, this keeps all of them, so a double descent shows twice.
function allDistances(ix: Index, from: string): Map<string, Map<number, boolean>> {
    const out = new Map<string, Map<number, boolean>>(); // ancestor → distance → adoptive
    const walk = (id: string, gen: number, adoptive: boolean, seen: Set<string>) => {
        if (seen.has(id)) return; // guard against bad data with a cycle
        const d = out.get(id) ?? new Map<number, boolean>();
        d.set(gen, (d.get(gen) ?? true) && adoptive); // a birth route at the same distance wins
        out.set(id, d);
        seen.add(id);
        for (const p of ix.up.get(id) ?? []) walk(p.id, gen + 1, adoptive || p.adoptive, seen);
        seen.delete(id);
    };
    walk(from, 0, false, new Set());
    return out;
}

// All blood routes from a to b, closest first: one per distinct (ga, gb) pair, naming the common ancestor(s) at that
// distance. A meeting point only counts as the top of a route if neither line passes through another common
// ancestor on the way up to it at those distances (the "lowest" common ancestors), so Jon/Daenerys reports
// Aerys & Rhaella, not also Aerys's parents. Double descent (Aegon III from Baelon) yields two routes.
function bloodRoutes(tree: Tree, ix: Index, a: string, b: string): Blood[] {
    const da = allDistances(ix, a);
    const db = allDistances(ix, b);
    const common = [...da.keys()].filter((id) => db.has(id));
    if (!common.length) return [];
    // (ancestor, ga, gb) is a lowest meeting point if no other common ancestor c sits between it and both people:
    // i.e. not (c is below the ancestor by k, and a is ga-k from c, and b is gb-k from c) for some k ≥ 1.
    const isLowest = (id: string, ga: number, gb: number) =>
        !common.some((c) => {
            if (c === id) return false;
            const above = allDistances(ix, c).get(id); // distances from c up to id
            if (!above) return false;
            for (const k of above.keys()) if (da.get(c)?.has(ga - k) && db.get(c)?.has(gb - k)) return true;
            return false;
        });
    const meetings: { id: string; ga: number; gb: number; adoptive: boolean }[] = [];
    for (const id of common)
        for (const [ga, adA] of da.get(id)!)
            for (const [gb, adB] of db.get(id)!)
                if (isLowest(id, ga, gb)) meetings.push({ id, ga, gb, adoptive: adA || adB });
    const groups = new Map<string, Blood>();
    for (const m of meetings) {
        const { id, ga, gb } = m;
        const key = `${ga},${gb}`;
        const adoptive = m.adoptive;
        const g = groups.get(key);
        if (g) {
            g.ancestors.push(id);
            g.adoptive &&= adoptive;
        } else groups.set(key, { ga, gb, label: "", ancestors: [id], adoptive });
    }
    for (const g of groups.values()) {
        // Half: the route meets at a single ancestor who had a partner, and that partner isn't ALSO a common ancestor
        // at the same distance (if they were, they'd be in g.ancestors). With no known partner it counts as full.
        const only = g.ancestors.length === 1 ? g.ancestors[0] : null;
        const half = g.ga >= 1 && g.gb >= 1 && !!only && (ix.spouses.get(only)?.size ?? 0) > 0;
        g.label = bloodLabel(tree.people[a].sex, g.ga, g.gb, half);
    }
    // Closest first; ties prefer birth routes over adoptive ones.
    return [...groups.values()].sort((x, y) => x.ga + x.gb - (y.ga + y.gb) || Number(x.adoptive) - Number(y.adoptive));
}

// Shortest chain between two people through parent, child and spouse links (BFS over the family graph).
function shortestPath(tree: Tree, a: string, b: string): Step[] | null {
    const adj = new Map<string, Step[]>();
    const add = (s: Step) => {
        if (!adj.has(s.from)) adj.set(s.from, []);
        adj.get(s.from)!.push(s);
    };
    for (const f of tree.families) {
        const adoptive = !!f.adoptive;
        for (const p of f.parents)
            for (const c of f.children) {
                add({ from: c, to: p, via: "parent", adoptive });
                add({ from: p, to: c, via: "child", adoptive });
            }
        for (const p of f.parents)
            for (const q of f.parents) if (p !== q) add({ from: p, to: q, via: "spouse", adoptive: false });
    }
    const back = new Map<string, Step | null>([[a, null]]);
    const queue = [a];
    while (queue.length) {
        const cur = queue.shift()!;
        if (cur === b) break;
        for (const s of adj.get(cur) ?? []) {
            if (back.has(s.to)) continue;
            back.set(s.to, s);
            queue.push(s.to);
        }
    }
    if (!back.has(b)) return null;
    const steps: Step[] = [];
    for (let s = back.get(b); s; s = back.get(s.from)!) steps.unshift(s);
    return steps;
}

/** Words for one hop, e.g. "father" for a step from a child up to their father. */
export function stepWord(tree: Tree, s: Step): string {
    const sex = tree.people[s.to].sex;
    if (s.via === "parent") return (s.adoptive ? "adoptive " : "") + by(sex, "father", "mother");
    if (s.via === "child") return (s.adoptive ? "adopted " : "") + by(sex, "son", "daughter");
    return by(sex, "husband", "wife");
}

// In-law and step names from a blood label (b's relative → a, plus one marriage). Only the common, unambiguous
// ones get a name; deeper chains fall back to the described path.
const IN_LAW: Record<string, [string, string]> = {
    father: ["father-in-law", "mother-in-law"],
    mother: ["father-in-law", "mother-in-law"],
    son: ["son-in-law", "daughter-in-law"],
    daughter: ["son-in-law", "daughter-in-law"],
    brother: ["brother-in-law", "sister-in-law"],
    sister: ["brother-in-law", "sister-in-law"],
    "half-brother": ["brother-in-law", "sister-in-law"],
    "half-sister": ["brother-in-law", "sister-in-law"],
    uncle: ["uncle by marriage", "aunt by marriage"],
    aunt: ["uncle by marriage", "aunt by marriage"],
    nephew: ["nephew by marriage", "niece by marriage"],
    niece: ["nephew by marriage", "niece by marriage"],
    grandfather: ["grandfather-in-law", "grandmother-in-law"],
    grandmother: ["grandfather-in-law", "grandmother-in-law"],
    "first cousin": ["cousin by marriage", "cousin by marriage"],
};

/** How `a` is related to `b`, or null if they are not connected at all in this tree. */
export function relate(tree: Tree, a: string, b: string): Relationship | null {
    const name = (id: string) => tree.people[id].name;
    const sexA = tree.people[a].sex;
    const base = { commonAncestors: [] as string[], routes: [] as Route[], adoptive: false };
    if (a === b)
        return {
            ...base,
            summary: `${name(a)} is the same person.`,
            label: "the same person",
            kind: "self",
            path: [a],
            steps: [],
        };

    const steps = shortestPath(tree, a, b);
    if (!steps) return null;
    const path = [a, ...steps.map((s) => s.to)];
    const ix = index(tree);
    const of = (label: string, extra = "") => `${name(a)} is the ${label} of ${name(b)}${extra}.`;

    // 1. Blood, via the closest common ancestor (plus every other route).
    const routes = bloodRoutes(tree, ix, a, b);
    if (routes.length) {
        const best = routes[0];
        return {
            summary: of(best.label, best.adoptive ? " (by adoption)" : ""),
            label: best.label,
            kind: "blood",
            path,
            steps,
            commonAncestors: best.ancestors,
            routes: routes.map((r) => ({ label: r.label, ancestors: r.ancestors, adoptive: r.adoptive })),
            adoptive: best.adoptive,
        };
    }

    const spousesOf = (id: string) => [...(ix.spouses.get(id) ?? [])];
    const parentsOf = (id: string) => (ix.up.get(id) ?? []).map((p) => p.id);

    // 2. Spouse.
    if (spousesOf(b).includes(a))
        return {
            ...base,
            summary: of(by(sexA, "husband", "wife")),
            label: by(sexA, "husband", "wife"),
            kind: "spouse",
            path,
            steps,
        };

    // 3. Step-relations: a is the spouse of b's parent (and not b's parent), or b is the spouse of a's parent, …
    if (parentsOf(b).some((p) => spousesOf(p).includes(a)))
        return {
            ...base,
            summary: of(by(sexA, "step-father", "step-mother")),
            label: by(sexA, "step-father", "step-mother"),
            kind: "step",
            path,
            steps,
        };
    if (parentsOf(a).some((p) => spousesOf(p).includes(b)))
        return {
            ...base,
            summary: of(by(sexA, "step-son", "step-daughter")),
            label: by(sexA, "step-son", "step-daughter"),
            kind: "step",
            path,
            steps,
        };
    // …and step-siblings: a's parent is married to b's parent, with no parent in common.
    const pa = parentsOf(a);
    const pb = parentsOf(b);
    if (!pa.some((p) => pb.includes(p)) && pa.some((p) => pb.some((q) => spousesOf(p).includes(q))))
        return {
            ...base,
            summary: of(by(sexA, "step-brother", "step-sister")),
            label: by(sexA, "step-brother", "step-sister"),
            kind: "step",
            path,
            steps,
        };

    // 4. In-laws. Two shapes, both "one marriage + a blood relationship":
    //    (i)  a is a blood relative of b's spouse s:  how a relates to s names it (a is s's mother → mother-in-law).
    //    (ii) a's spouse s is a blood relative of b:  how s relates to b names it (s is b's brother → a is b's
    //         sister-in-law). The labels are always re-gendered for a.
    const inLaw = (bloodLabel: string) => {
        const pair = IN_LAW[bloodLabel];
        return pair ? by(sexA, pair[0], pair[1]) : null;
    };
    for (const s of spousesOf(b)) {
        const r = bloodRoutes(tree, ix, a, s)[0];
        const label = r && inLaw(r.label);
        if (label) return { ...base, summary: of(label), label, kind: "in-law", path, steps };
    }
    for (const s of spousesOf(a)) {
        const r = bloodRoutes(tree, ix, s, b)[0];
        const label = r && inLaw(r.label);
        if (label) return { ...base, summary: of(label), label, kind: "in-law", path, steps };
    }

    // 5. Further connections only by marriage: describe the chain.
    const chain = steps.map((s) => `${stepWord(tree, s)} ${name(s.to)}`).join(", whose ");
    return {
        ...base,
        summary: `${name(a)} is connected by marriage: ${name(a)}'s ${chain}.`,
        label: null,
        kind: "path",
        path,
        steps,
        adoptive: steps.some((s) => s.adoptive),
    };
}

/**
 * Label every other person by their relationship to `centre` ("Relative to" mode): blood, step and in-law names,
 * or null where the connection is too distant to name. Cheap enough for a few hundred people.
 */
export function labelAll(tree: Tree, centre: string): Map<string, string | null> {
    const out = new Map<string, string | null>();
    for (const id of Object.keys(tree.people)) {
        if (id === centre) continue;
        const r = relate(tree, id, centre);
        out.set(id, r?.label ?? null);
    }
    return out;
}
