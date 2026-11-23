// Flat (2D) mode: squash the house depth planes and lay out each row so names don't collide.
//
// What it does: eases the graph's z scale towards ~0 (setFlat, stepFlat), and registers two d3 forces that act only
// while flat: spreadRows (spread each generation row so names don't overlap) and clusterSiblings (pull brothers and
// sisters towards their family's centre).
// While flat, links are drawn as right-angled family-tree connectors unless setRightAngles(false) asks for straight
// ones; the link travelling dots are hidden then, since they'd run along the straight line, off the connector.
// Usage: graph.ts re-exports setFlat, setRightAngles and drawnZ and calls setSiblingGroups() in showTree() and
// stepFlat() each frame.
// Notes: the scale is 1e-3, not 0, because singular matrices break raycasting and normals; each node object is
// counter-scaled so spheres stay round. Node data keeps the simulation's z; use drawnZ() for the on-screen z. Link
// shapes are re-placed directly when they change (core.ts setElbowLinks), with no layout restart.

import { approach, boundLinks, boundNodes, graph, nameOf, setElbowLinks, type SimNode } from "./core.ts";

// Each node's object is counter-scaled so spheres stay round; links, sibling lines and guides simply flatten. Not
// exactly 0, which would make the matrices singular (raycasting and normals invert them).
const FLAT = 1e-3;
let flatTarget = 1;
const isFlat = () => flatTarget !== 1;
let rightAngles = true;
const elbowsOn = () => isFlat() && rightAngles;

export function setFlat(on: boolean): void {
    flatTarget = on ? FLAT : 1;
    setElbowLinks(elbowsOn()); // re-places the links; no layout restart: the row forces run in 2D and 3D alike
}

/** In 2D, draw links as right-angled connectors (true, the default) or straight lines. No effect in 3D. */
export function setRightAngles(on: boolean): void {
    rightAngles = on;
    setElbowLinks(elbowsOn());
}

/** A node's z as drawn (node data keeps the simulation's z; the graph's scale squashes it in 2D). */
export const drawnZ = (z: number) => z * graph.scale.z;

export function stepFlat(dt: number): void {
    const s = graph.scale.z;
    const next = Math.abs(s - flatTarget) < 1e-3 ? flatTarget : approach(s, flatTarget, 1 - Math.exp(-5 * dt));
    graph.scale.z = next;
    // Every frame, not just while easing: a saga loaded in 2D builds fresh node objects at scale 1.
    for (const n of boundNodes()) n.__threeObj?.scale.setZ(1 / next);
    // The travelling dots follow the straight line, so they'd float off a right-angled connector.
    const dots = !elbowsOn();
    for (const l of boundLinks()) if (l.__photonsObj) l.__photonsObj.visible = dots;
}

// People in the same generation can share an x and still be apart in depth; flattened (or seen from the front),
// they'd sit on top of each other. So a force pushes neighbours in each generation row apart until their names no
// longer touch, with extra space between couple groups (gapBetween).
// Widths are the name sprites' own (at their resting size, before names.ts grows any); before a person's objects are
// built, a character-count estimate stands in.
const NAME_CHAR_W = 2; // world units per character of a name label (4 units tall, condensed bold)
// Clearance between neighbouring names: the same in 2D and 3D (leaving room for right-angled drop lines), so switching
// changes nothing the layout depends on and needs no restart.
const rowGap = () => 12;
const SPREAD_SHARE = 0.4; // of an overlap, moved by each of the two names per tick
const halfWidth = (n: SimNode) => {
    const s = nameOf(n);
    const w = s ? ((s.userData.baseScale as { x: number } | undefined)?.x ?? s.scale.x) : n.name!.length * NAME_CHAR_W;
    return Math.max(4, w) / 2;
};
// Between couple groups: a person beside someone who isn't their partner, where either of them has a partner on the
// row, keeps COUPLE_SPACE more clearance, so each couple reads as its own pair rather than running into the next
// (Arthur and Molly packed against Druella and Cygnus, with their lines crossing). Unmarried siblings stay close.
// Likewise brothers and sisters stay close, and the space goes between groups: anyone beside someone who is neither
// their partner nor their sibling keeps GROUP_SPACE more clearance, so each couple and each set of siblings reads as
// its own group.
const GROUP_SPACE = 45; // wide: each family cluster stands clearly apart from its neighbours
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
graph.d3Force("spreadRows", spreadRows());

// Siblings are pulled sideways towards their family's centre (in 2D and 3D), so brothers and sisters sit side by side
// rather than interleaved with cousins. spreadRows keeps them from overlapping, so they pack into a tight cluster.
const SIBLING_PULL = 0.5; // strong: brothers and sisters pack tightly (0.15 let cousins and in-laws drift between them)
let siblingGroups: SimNode[][] = [];
let siblingPairs = new Set<string>();
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
graph.d3Force("clusterSiblings", clusterSiblings);

// In 2D and 3D, a mother and father on the same row are pulled firmly sideways towards each other until they sit
// side by side, just apart (PARTNER_SPACE), so a couple reads as a pair with their children below. Only a pull, never
// a push (spreadRows keeps names apart), so someone with several spouses ends up between them. Once a strong pull
// jammed couples into each other; the seeded family order and GROUP_SPACE now keep them apart.
const COUPLE_PULL = 0.8;
const PARTNER_SPACE = 2;
let couples: [SimNode, SimNode][] = [];
let partners = new Set<string>();
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
graph.d3Force("pullCouples", pullCouples);

// Parents over their children: each family's parents and its children are pulled sideways towards each other's
// centre, so a mother and father sit directly above their own brood and the family reads as one block (spreadRows
// keeps the space between blocks). Children move more than parents: a parent may have several families to sit over.
const OVER_PULL = 0.35; // firm: a couple sits centred over their brothers-and-sisters group
let families: { parents: SimNode[]; children: SimNode[] }[] = [];
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
graph.d3Force("parentsOverChildren", parentsOverChildren);

// A union (marriage) node sits between its parents: pinned to their midpoint, sideways and in depth, every tick (one
// parent: under them). Left to the springs it settled between the parents and their children, so in 2D the couple's
// bar ran off to one side (James and Lily's ended halfway to Harry). The springs still pull the parents towards the
// children; only the union's own position is fixed.
let unions: { union: SimNode & { vz?: number }; parents: SimNode[] }[] = [];
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
graph.d3Force("unionsBetweenParents", unionsBetweenParents);
