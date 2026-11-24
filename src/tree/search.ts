// Search: finding people by name or by relationship, forgivingly.
//
// What it does: searchPeople() ranks names by exact match, then a word starting with the query, then containing it,
// then a close spelling (one edit from 4 letters, two from 6, by optimal-string-alignment distance); findByName() is
// the best match; searchRelation() answers "Arya's cousins" or "children of Zeus" (the person with the most such
// relatives wins, so "sons of Jacob" finds Jacob (Israel)); distinguish() is the hint that tells namesakes apart
// (parents, else a child, else a spouse); houseNamed() matches a house forgivingly ("stark", "House%20Stark").
// Usage: ui/input.ts and ui/suggest.ts (the search and finder boxes), ui/sagas.ts and ui/legend.ts (?house= links);
// unit-tested in scripts/family.test.mts. Pure: no three.js or DOM imports.
// Notes: every name comparison goes through fold() (ignores accents, case and punctuation). Results are person ids,
// never names, so namesakes can't be confused. Within a match tier the file's order is kept, so main figures come
// first.

import type { Tree } from "../data/schema.ts";
import { birthFamily, childrenOf, cousinsOf, descendantsOf, lineageRoles, parentsOf, siblingsOf } from "./family.ts";

type Sex = Tree["people"][string]["sex"];

// Relationship words for "Arya's grandmother" / "children of Zeus" searches: word → who to collect, from a person.
type Hop = (tree: Tree, ids: string[]) => string[];

const RELATION_WORDS: Record<string, Hop> = {
    parent: up,
    father: sex("m", up),
    mother: sex("f", up),
    child: down,
    son: sex("m", down),
    daughter: sex("f", down),
    sibling: (t, ids) => ids.flatMap((i) => siblingsOf(t, i)),
    brother: sex("m", (t, ids) => ids.flatMap((i) => siblingsOf(t, i))),
    sister: sex("f", (t, ids) => ids.flatMap((i) => siblingsOf(t, i))),
    spouse: (t, ids) =>
        ids
            .flatMap((i) => t.families.filter((f) => f.parents.includes(i)).flatMap((f) => f.parents))
            .filter((x) => !ids.includes(x)),
    grandparent: then(up, up),
    grandfather: then(up, sex("m", up)),
    grandmother: then(up, sex("f", up)),
    grandchild: then(down, down),
    grandson: then(down, sex("m", down)),
    granddaughter: then(down, sex("f", down)),
    cousin: (t, ids) => ids.flatMap((i) => cousinsOf(t, i)),
    uncle: sex(
        "m",
        then(up, (t, ids) => ids.flatMap((i) => siblingsOf(t, i)))
    ),
    aunt: sex(
        "f",
        then(up, (t, ids) => ids.flatMap((i) => siblingsOf(t, i)))
    ),
    nephew: sex(
        "m",
        then((t, ids) => ids.flatMap((i) => siblingsOf(t, i)), down)
    ),
    niece: sex(
        "f",
        then((t, ids) => ids.flatMap((i) => siblingsOf(t, i)), down)
    ),
    ancestor: (t, ids) =>
        ids.flatMap((i) => [...lineageRoles(t, i)].filter(([, r]) => r.side === "ancestor").map(([p]) => p)),
    descendant: (t, ids) => ids.flatMap((i) => [...descendantsOf(t, i)]),
};

const PLURAL: Record<string, string> = { children: "child", grandchildren: "grandchild" };

const by = (sex: Sex, m: string, f: string) => (sex === "m" ? m : f);

// Hops are function declarations, so RELATION_WORDS (built from them at load time) can sit with the constants.
function up(t: Tree, ids: string[]): string[] {
    return ids.flatMap((i) => parentsOf(t, i));
}

function down(t: Tree, ids: string[]): string[] {
    return ids.flatMap((i) => childrenOf(t, i));
}

/** A hop, keeping only people of one sex (or everyone, for null). */
function sex(s: Sex | null, hop: Hop): Hop {
    return (t, ids) => hop(t, ids).filter((i) => !s || t.people[i].sex === s);
}

/** Hops one after another: `then(up, up)` is grandparents. */
function then(...hops: Hop[]): Hop {
    return (t, ids) => hops.reduce((acc, h) => h(t, acc), ids);
}

const singular = (w: string) =>
    PLURAL[w] ?? (w.endsWith("es") && RELATION_WORDS[w.slice(0, -2)] ? w.slice(0, -2) : w.replace(/s$/, ""));

/**
 * A relationship search: "Arya's grandmother", "children of Zeus", "sons of Jacob". Returns the person searched from
 * and who matches, or null if the query isn't of that shape (the search box then matches names as usual).
 */
export function searchRelation(tree: Tree, query: string): { from: string; word: string; ids: string[] } | null {
    const q = query.trim();
    const possessive = /^(.+?)['’]s?\s+(\p{L}+)$/u.exec(q); // "Arya's mother"
    const of = /^(\p{L}+)\s+of\s+(.+)$/iu.exec(q); // "children of Zeus"
    const [who, raw] = possessive ? [possessive[1], possessive[2]] : of ? [of[2], of[1]] : [];
    if (!who || !raw) return null;
    const hop: Hop | undefined = RELATION_WORDS[singular(raw.toLowerCase())];
    if (!hop) return null;
    // Of the people the name could mean (the Bible has three Jacobs), take the best match that has any such relative,
    // so "sons of Jacob" finds Jacob (Israel)'s twelve rather than nobody.
    const candidates = searchPeople(tree, who, 10);
    if (!candidates.length) return null;
    const found = candidates.map((from) => ({ from, ids: [...new Set(hop(tree, [from]))] }));
    // The one with the most such relatives wins; ties keep the search's order (best name match first).
    const { from, ids } = found.reduce((best, f) => (f.ids.length > best.ids.length ? f : best));
    return { from, word: raw.toLowerCase(), ids };
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

/**
 * The house a link names, matched forgivingly: case, accents, spaces and punctuation don't matter, so ?house=stark,
 * ?house=STARK and ?house=House%20Stark all find "Stark". Null if the saga has no such house.
 */
export function houseNamed(tree: Tree, wanted: string | null | undefined): string | null {
    if (!wanted) return null;
    const houses = [...new Set([...Object.keys(tree.houseColors), ...Object.values(tree.people).map((p) => p.house)])];
    const w = fold(wanted);
    return houses.find((h) => fold(h) === w) ?? houses.find((h) => fold(`house ${h}`) === w) ?? null;
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
