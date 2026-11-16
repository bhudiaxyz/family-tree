// Relationship finder: how two people are related, in words, plus the chain of people that connects them.
// Pure logic (no three.js / DOM), unit-tested in scripts/relationship.test.mts.
//
// Blood relationships use the standard genealogical method: find the closest common ancestor, count generations up
// from each person (a, b), then name it — direct line when one count is 0, siblings at (1,1), aunt/uncle and
// niece/nephew when one count is 1, and cousins otherwise: degree = min(a,b) - 1, removed = |a - b|.
// Anything else (marriage, step-, in-law chains) falls back to a described path through the family graph.
import type { Tree } from "./data/schema.ts";

type Sex = "m" | "f";
export type Step = { from: string; to: string; via: "parent" | "child" | "spouse"; adoptive: boolean };
export type Relationship = {
    /** Plain-English summary, e.g. "Jon Snow is the nephew of Daenerys Targaryen". */
    summary: string;
    /** Short label of how `a` relates to `b` ("nephew", "second cousin once removed"…), or null if only a path. */
    label: string | null;
    /** People along the connecting chain, `a` first and `b` last (for highlighting). */
    path: string[];
    /** Each hop along the path, for a step-by-step explanation. */
    steps: Step[];
    /** True if the chain passes through an adoption. */
    adoptive: boolean;
};

const ORDINAL = ["", "first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth", "ninth", "tenth"];
const TIMES = ["", "once", "twice", "three times", "four times", "five times", "six times"];
const ordinal = (n: number) => ORDINAL[n] ?? `${n}th`;
const times = (n: number) => TIMES[n] ?? `${n} times`;
const by = (sex: Sex, m: string, f: string) => (sex === "m" ? m : f);

/** "great-great-" style prefix for n extra generations; beyond 3, "4× great-". */
const greats = (n: number) => (n <= 0 ? "" : n <= 3 ? "great-".repeat(n) : `${n}× great-`);

// Parent links (birth and adoptive) for walking up the tree.
function parentsOf(tree: Tree): Map<string, { id: string; adoptive: boolean }[]> {
    const up = new Map<string, { id: string; adoptive: boolean }[]>();
    for (const f of tree.families)
        for (const c of f.children)
            for (const p of f.parents) {
                if (!up.has(c)) up.set(c, []);
                up.get(c)!.push({ id: p, adoptive: !!f.adoptive });
            }
    return up;
}

// Every ancestor of `id` with its distance (generations up) and whether the route used an adoption. BFS, so the
// first time an ancestor is reached is by the fewest generations; ties prefer the birth route.
function ancestors(up: ReturnType<typeof parentsOf>, id: string) {
    const seen = new Map<string, { gen: number; adoptive: boolean }>([[id, { gen: 0, adoptive: false }]]);
    let frontier = [id];
    for (let gen = 1; frontier.length; gen++) {
        const next: string[] = [];
        for (const cur of frontier)
            for (const p of up.get(cur) ?? []) {
                const adoptive = seen.get(cur)!.adoptive || p.adoptive;
                const prev = seen.get(p.id);
                if (!prev) {
                    seen.set(p.id, { gen, adoptive });
                    next.push(p.id);
                } else if (prev.gen === gen && prev.adoptive && !adoptive) prev.adoptive = false;
            }
        frontier = next;
    }
    return seen;
}

/** Name the blood relationship of a to b from generations-up counts (ga from a, gb from b). */
function bloodLabel(sexA: Sex, ga: number, gb: number, half: boolean): string {
    const h = half ? "half-" : "";
    if (ga === 0 && gb === 0) return "the same person";
    if (gb === 0) return greats(ga - 2) + (ga >= 2 ? "grand" : "") + by(sexA, "son", "daughter"); // a is below b
    if (ga === 0) return greats(gb - 2) + (gb >= 2 ? "grand" : "") + by(sexA, "father", "mother"); // a is above b
    if (ga === 1 && gb === 1) return h + by(sexA, "brother", "sister");
    // a is (ga-1) generations below b's sibling: nephew at ga 2, grandnephew at 3, great-grandnephew at 4…
    if (gb === 1) return greats(ga - 3) + (ga >= 3 ? "grand" : "") + by(sexA, "nephew", "niece");
    if (ga === 1) return greats(gb - 3) + (gb >= 3 ? "grand" : "") + by(sexA, "uncle", "aunt");
    const degree = Math.min(ga, gb) - 1;
    const removed = Math.abs(ga - gb);
    return `${h}${ordinal(degree)} cousin${removed ? ` ${times(removed)} removed` : ""}`;
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
function stepWord(tree: Tree, s: Step): string {
    const sex = tree.people[s.to].sex;
    const adopt = s.adoptive ? "adoptive " : "";
    if (s.via === "parent") return adopt + by(sex, "father", "mother");
    if (s.via === "child") return (s.adoptive ? "adopted " : "") + by(sex, "son", "daughter");
    return by(sex, "husband", "wife");
}

/** How `a` is related to `b`, or null if they are not connected at all in this tree. */
export function relate(tree: Tree, a: string, b: string): Relationship | null {
    // Half-relation: the two lines meet at an ancestor whose partner (in some family) is not ALSO a common ancestor at
    // the same distance. With only one known parent there is no partner to compare, so it counts as full.
    const isHalf = (
        ancestor: string,
        ga: number,
        gb: number,
        ua: ReturnType<typeof ancestors>,
        ub: ReturnType<typeof ancestors>
    ) => {
        const partners = tree.families.filter((f) => f.parents.includes(ancestor)).flatMap((f) => f.parents);
        const others = partners.filter((p) => p !== ancestor);
        if (!others.length) return false;
        return !others.some((p) => ua.get(p)?.gen === ga && ub.get(p)?.gen === gb);
    };
    const name = (id: string) => tree.people[id].name;
    if (a === b)
        return {
            summary: `${name(a)} is the same person.`,
            label: "the same person",
            path: [a],
            steps: [],
            adoptive: false,
        };

    const steps = shortestPath(tree, a, b);
    if (!steps) return null;
    const path = [a, ...steps.map((s) => s.to)];

    // Blood (or adoptive-line) relationship via the closest common ancestor, if there is one.
    const up = parentsOf(tree);
    const ua = ancestors(up, a);
    const ub = ancestors(up, b);
    let best: { id: string; ga: number; gb: number; adoptive: boolean } | null = null;
    for (const [id, x] of ua) {
        const y = ub.get(id);
        if (!y) continue;
        const c = { id, ga: x.gen, gb: y.gen, adoptive: x.adoptive || y.adoptive };
        const total = (r: typeof c) => r.ga + r.gb;
        if (!best || total(c) < total(best) || (total(c) === total(best) && best.adoptive && !c.adoptive)) best = c;
    }

    if (best) {
        const half = best.ga >= 1 && best.gb >= 1 && isHalf(best.id, best.ga, best.gb, ua, ub);
        const label = bloodLabel(tree.people[a].sex, best.ga, best.gb, half);
        const qualifier = best.adoptive ? " (by adoption)" : "";
        return {
            summary: `${name(a)} is the ${label} of ${name(b)}${qualifier}.`,
            label,
            path,
            steps,
            adoptive: best.adoptive,
        };
    }

    // Spouse, or a connection only through marriage: describe the chain step by step.
    if (steps.length === 1 && steps[0].via === "spouse")
        return {
            summary: `${name(a)} is the ${stepWord(tree, { ...steps[0], from: b, to: a })} of ${name(b)}.`,
            label: by(tree.people[a].sex, "husband", "wife"),
            path,
            steps,
            adoptive: false,
        };
    const chain = steps.map((s) => `${stepWord(tree, s)} ${name(s.to)}`).join(", whose ");
    return {
        summary: `${name(a)} is connected by marriage: ${name(a)}'s ${chain}.`,
        label: null,
        path,
        steps,
        adoptive: steps.some((s) => s.adoptive),
    };
}
