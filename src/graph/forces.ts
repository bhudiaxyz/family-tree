// Row forces: keep names apart and families grouped along each generation row, in 2D and 3D alike.
//
// What it does: registers five d3 forces on the graph's simulation, in this order of effect:
//   spreadRows           neighbours on a row never overlap: names keep a gap, wider between family groups
//   clusterSiblings      brothers and sisters pull towards their family's centre
//   pullCouples          a mother and father on one row pull together until side by side
//   parentsOverChildren  a family's parents and children pull towards each other's centre (parents over their brood)
//   unionsBetweenParents a marriage node is pinned to its parents' midpoint
// Usage: graph.ts showTree() calls setSiblingGroups, setCouples, setFamilies and setUnions with the new tree's nodes.
// Importing this module registers the forces (graph.ts does), so it has no other exports.
// Notes: these only refine the starting order from tree/row-order.ts; none of them can move a name past another
// (spreadRows corrects positions directly), so a wrong starting order stays wrong. spreadRows is a position
// correction, not a velocity kick: kicks built up momentum against the pulls and made the layout shimmy as it settled.
// Widths come from the name sprites (graph/names.ts keeps their resting size in userData.baseScale).

import { graph, nameOf } from "./core.ts";
import { type SimNode } from "./graph-types.ts";

// People in the same generation can share an x and still be apart in depth; flattened (or seen from the front),
// they'd sit on top of each other. So a force pushes neighbours in each generation row apart until their names no
// longer touch, with extra space between couple groups (gapBetween).
// Widths are the name sprites' own (at their resting size, before names.ts grows any); before a person's objects are
// built, a character-count estimate stands in.
const NAME_CHAR_W = 2; // world units per character of a name label (4 units tall, condensed bold)

const SPREAD_SHARE = 0.4; // of an overlap, moved by each of the two names per tick

// Between couple groups: a person beside someone who isn't their partner, where either of them has a partner on the
// row, keeps COUPLE_SPACE more clearance, so each couple reads as its own pair rather than running into the next
// (Arthur and Molly packed against Druella and Cygnus, with their lines crossing). Unmarried siblings stay close.
// Likewise brothers and sisters stay close, and the space goes between groups: anyone beside someone who is neither
// their partner nor their sibling keeps GROUP_SPACE more clearance, so each couple and each set of siblings reads as
// its own group.
const GROUP_SPACE = 45; // wide: each family cluster stands clearly apart from its neighbours

// Siblings are pulled sideways towards their family's centre (in 2D and 3D), so brothers and sisters sit side by side
// rather than interleaved with cousins. spreadRows keeps them from overlapping, so they pack into a tight cluster.
const SIBLING_PULL = 0.5; // strong: brothers and sisters pack tightly (0.15 let cousins and in-laws drift between them)

let siblingGroups: SimNode[][] = [];
let siblingPairs = new Set<string>();

// In 2D and 3D, a mother and father on the same row are pulled firmly sideways towards each other until they sit
// side by side, just apart (PARTNER_SPACE), so a couple reads as a pair with their children below. Only a pull, never
// a push (spreadRows keeps names apart), so someone with several spouses ends up between them. Once a strong pull
// jammed couples into each other; the seeded family order and GROUP_SPACE now keep them apart.
const COUPLE_PULL = 0.8;

const PARTNER_SPACE = 2;
let couples: [SimNode, SimNode][] = [];
let partners = new Set<string>();

// Parents over their children: each family's parents and its children are pulled sideways towards each other's
// centre, so a mother and father sit directly above their own brood and the family reads as one block (spreadRows
// keeps the space between blocks). Children move more than parents: a parent may have several families to sit over.
const OVER_PULL = 0.35; // firm: a couple sits centred over their brothers-and-sisters group

let families: { parents: SimNode[]; children: SimNode[] }[] = [];

// A union (marriage) node sits between its parents: pinned to their midpoint, sideways and in depth, every tick (one
// parent: under them). Left to the springs it settled between the parents and their children, so in 2D the couple's
// bar ran off to one side (James and Lily's ended halfway to Harry). The springs still pull the parents towards the
// children; only the union's own position is fixed.
let unions: { union: SimNode & { vz?: number }; parents: SimNode[] }[] = [];

// Clearance between neighbouring names: the same in 2D and 3D (leaving room for right-angled drop lines), so switching
// changes nothing the layout depends on and needs no restart.
const rowGap = () => 12;

const halfWidth = (n: SimNode) => {
    const s = nameOf(n);
    const w = s ? ((s.userData.baseScale as { x: number } | undefined)?.x ?? s.scale.x) : n.name!.length * NAME_CHAR_W;
    return Math.max(4, w) / 2;
};

const gapBetween = (a: SimNode, b: SimNode) =>
    rowGap() + (partners.has(pairKey(a, b)) || siblingPairs.has(pairKey(a, b)) ? 0 : GROUP_SPACE);

function spreadRows() {
    let nodes: SimNode[] = [];
    // In both modes: in 3D people on a row can differ in depth, but seen from the front (the usual view) their names
    // still collided, and couples ran together the same way.
    const force = () => {
        const rows = new Map<number, SimNode[]>();
        for (const n of nodes) {
            if (!n.name || n.x === undefined) continue;
            const row = rows.get(n.fy!) ?? [];
            rows.set(n.fy!, row);
            row.push(n);
        }
        for (const row of rows.values()) {
            row.sort((a, b) => a.x! - b.x!);
            for (let i = 1; i < row.length; i++) {
                const [a, b] = [row[i - 1], row[i]];
                const overlap = halfWidth(a) + halfWidth(b) + gapBetween(a, b) - (b.x! - a.x!);
                if (overlap <= 0) continue;
                // A position correction, not a velocity kick: pushes added to velocity built up momentum against the
                // sibling and couple pulls and made the layout shimmy as it settled. Each side moves a share of the
                // overlap now, and any speed towards the other is dropped.
                a.x! -= overlap * SPREAD_SHARE;
                b.x! += overlap * SPREAD_SHARE;
                if ((a.vx ?? 0) > 0) a.vx = 0;
                if ((b.vx ?? 0) < 0) b.vx = 0;
            }
        }
    };
    force.initialize = (n: SimNode[]) => (nodes = n);
    return force;
}

/** Each family's children (only families with two or more), set when a tree is shown. */
export function setSiblingGroups(groups: SimNode[][]): void {
    siblingGroups = groups;
    siblingPairs = new Set(groups.flatMap((g) => g.flatMap((a, i) => g.slice(i + 1).map((b) => pairKey(a, b)))));
}

function clusterSiblings(alpha: number) {
    for (const group of siblingGroups) {
        const placed = group.filter((n) => n.x !== undefined);
        if (placed.length < 2) continue;
        const cx = placed.reduce((s, n) => s + n.x!, 0) / placed.length;
        for (const n of placed) n.vx = (n.vx ?? 0) + (cx - n.x!) * SIBLING_PULL * alpha;
    }
}

const pairKey = (a: SimNode, b: SimNode) => (a.id < b.id ? `${a.id}|${b.id}` : `${b.id}|${a.id}`);

/** Each family's two parents, where they share a row; set when a tree is shown. */
export function setCouples(pairs: [SimNode, SimNode][]): void {
    couples = pairs;
    partners = new Set(pairs.map(([a, b]) => pairKey(a, b)));
}

function pullCouples(alpha: number) {
    for (const [a, b] of couples) {
        if (a.x === undefined || b.x === undefined) continue;
        const dx = b.x - a.x;
        const gap = Math.abs(dx) - (halfWidth(a) + halfWidth(b) + rowGap() + PARTNER_SPACE);
        if (gap <= 0) continue;
        const push = Math.sign(dx) * gap * COUPLE_PULL * alpha;
        a.vx = (a.vx ?? 0) + push;
        b.vx = (b.vx ?? 0) - push;
    }
}

/** Every family with both parents and children recorded; set when a tree is shown. */
export const setFamilies = (fs: typeof families) => (families = fs);

const meanX = (ns: SimNode[]) => ns.reduce((s, n) => s + n.x!, 0) / ns.length;

function parentsOverChildren(alpha: number) {
    for (const { parents, children } of families) {
        if (parents.some((n) => n.x === undefined) || children.some((n) => n.x === undefined)) continue;
        const d = meanX(children) - meanX(parents);
        for (const p of parents) p.vx = (p.vx ?? 0) + d * OVER_PULL * 0.6 * alpha;
        for (const c of children) c.vx = (c.vx ?? 0) - d * OVER_PULL * alpha;
    }
}

/** Each union node with its parents; set when a tree is shown. */
export const setUnions = (us: typeof unions) => (unions = us);

function unionsBetweenParents() {
    for (const { union, parents } of unions) {
        if (parents.some((p) => p.x === undefined)) continue;
        union.x = meanX(parents);
        union.z = parents.reduce((s, p) => s + p.z!, 0) / parents.length;
        union.vx = union.vz = 0;
    }
}

graph.d3Force("spreadRows", spreadRows());
graph.d3Force("clusterSiblings", clusterSiblings);
graph.d3Force("pullCouples", pullCouples);
graph.d3Force("parentsOverChildren", parentsOverChildren);
graph.d3Force("unionsBetweenParents", unionsBetweenParents);
