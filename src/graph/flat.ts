// 2D mode: squash the house depth planes flat by easing the graph's z scale towards ~0, then two layout forces that
// only act while flat: spread each generation row so names don't overlap, and cluster siblings together.
import { approach, boundNodes, graph, type SimNode } from "./core.ts";

// Each node's object is counter-scaled so spheres stay round; links, sibling lines and guides simply flatten. Not
// exactly 0, which would make the matrices singular (raycasting and normals invert them).
const FLAT = 1e-3;
let flatTarget = 1;
const isFlat = () => flatTarget !== 1;

export function setFlat(on: boolean): void {
    flatTarget = on ? FLAT : 1;
    graph.d3ReheatSimulation(); // re-run the layout so the row spacing below applies (or relaxes when back in 3D)
}

/** A node's z as drawn (node data keeps the simulation's z; the graph's scale squashes it in 2D). */
export const drawnZ = (z: number) => z * graph.scale.z;

export function stepFlat(dt: number): void {
    const s = graph.scale.z;
    const next = Math.abs(s - flatTarget) < 1e-3 ? flatTarget : approach(s, flatTarget, 1 - Math.exp(-5 * dt));
    graph.scale.z = next;
    // Every frame, not just while easing: a saga loaded in 2D builds fresh node objects at scale 1.
    for (const n of boundNodes()) n.__threeObj?.scale.setZ(1 / next);
}

// In 3D, people in the same generation can share an x and still be apart in depth; flattened, they'd sit on top of
// each other. So in 2D a force pushes neighbours in each generation row apart until their names no longer touch.
// ponytail: name width estimated from character count; measure the label sprites if long names still collide.
const NAME_CHAR_W = 2; // world units per character of a name label (4 units tall, condensed bold)
const ROW_GAP = 5; // clearance between neighbouring names
const halfWidth = (n: SimNode) => Math.max(4, n.name!.length * NAME_CHAR_W) / 2;
function spreadRows() {
    let nodes: SimNode[] = [];
    const force = () => {
        if (!isFlat()) return;
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
                const overlap = halfWidth(a) + halfWidth(b) + ROW_GAP - (b.x! - a.x!);
                if (overlap <= 0) continue;
                a.vx = (a.vx ?? 0) - overlap * 0.25;
                b.vx = (b.vx ?? 0) + overlap * 0.25;
            }
        }
    };
    force.initialize = (n: SimNode[]) => (nodes = n);
    return force;
}
graph.d3Force("spreadRows", spreadRows());

// Also in 2D, siblings are pulled sideways towards their family's centre, so brothers and sisters sit side by side
// rather than interleaved with cousins. spreadRows keeps them from overlapping, so they pack into a tight cluster.
const SIBLING_PULL = 0.15;
let siblingGroups: SimNode[][] = [];
/** Each family's children (only families with two or more), set when a tree is shown. */
export const setSiblingGroups = (groups: SimNode[][]) => (siblingGroups = groups);
function clusterSiblings(alpha: number) {
    if (!isFlat()) return;
    for (const group of siblingGroups) {
        const placed = group.filter((n) => n.x !== undefined);
        if (placed.length < 2) continue;
        const cx = placed.reduce((s, n) => s + n.x!, 0) / placed.length;
        for (const n of placed) n.vx = (n.vx ?? 0) + (cx - n.x!) * SIBLING_PULL * alpha;
    }
}
graph.d3Force("clusterSiblings", clusterSiblings);
