// Pure family-tree queries over a Tree: no three.js, no DOM, so they are unit-tested in scripts/family.test.mts.
import type { Tree } from "./data/schema.ts";

type Sex = Tree["people"][string]["sex"];
const by = (sex: Sex, m: string, f: string) => (sex === "m" ? m : f);

/** The person, all their ancestors and descendants, and their spouses: everything a highlight keeps lit. */
export function lineage(tree: Tree, id: string): Set<string> {
    const keep = new Set([id]);
    const walk = (up: boolean) => {
        const stack = [id];
        while (stack.length) {
            const cur = stack.pop()!;
            for (const f of tree.families) {
                if (!(up ? f.children : f.parents).includes(cur)) continue;
                for (const next of up ? f.parents : f.children)
                    if (!keep.has(next)) {
                        keep.add(next);
                        stack.push(next);
                    }
            }
        }
    };
    walk(true);
    walk(false);
    for (const f of tree.families) if (f.parents.includes(id)) for (const p of f.parents) keep.add(p);
    return keep;
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
export function parentLabel(tree: Tree, parent: string, family: Tree["families"][number]): string {
    const sex = tree.people[parent].sex;
    if (!family.children.length) return by(sex, "husband", "wife");
    return (family.adoptive ? "adoptive " : "") + by(sex, "father", "mother");
}

/** Label for the link from a family's union node to a child. */
export function childLabel(tree: Tree, child: string, family: Tree["families"][number]): string {
    return (family.adoptive ? "adopted " : "") + by(tree.people[child].sex, "son", "daughter");
}

/** Label for a sibling pair. */
export function siblingLabel(tree: Tree, a: string, b: string): string {
    const sa = tree.people[a].sex;
    return sa === tree.people[b].sex ? by(sa, "brothers", "sisters") : "brother & sister";
}

/** Find a person by name: exact match first, then the first name containing the query (case-insensitive). */
export function findByName(tree: Tree, query: string): string | null {
    const q = query.trim().toLowerCase();
    if (!q) return null;
    const entries = Object.entries(tree.people);
    const hit =
        entries.find(([, p]) => p.name.toLowerCase() === q) ??
        entries.find(([, p]) => p.name.toLowerCase().includes(q));
    return hit?.[0] ?? null;
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
