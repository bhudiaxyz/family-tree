// Flat (2D) mode: squash the house depth planes flat and switch links to right-angled connectors.
//
// What it does: eases the graph's z scale towards ~0 and back (setFlat, stepFlat), counter-scaling each person so
// spheres stay round; draws links as right-angled family-tree connectors while flat, unless setRightAngles(false)
// asks for straight ones, and hides the links' travelling dots then (they'd run along the straight line, off the
// connector). drawnZ() gives a node's on-screen z.
// Usage: graph.ts re-exports setFlat, setRightAngles and drawnZ and calls stepFlat() each frame; ui/sagas.ts and
// ui/menu.ts switch 2D and Right-angles.
// Notes: the scale is 1e-3, not 0, because singular matrices break raycasting and normals. Node data keeps the
// simulation's z; use drawnZ() for the on-screen z. Switching re-places the links directly (core.ts setElbowLinks)
// with no layout restart: the row forces (forces.ts) run in 2D and 3D alike, so nothing the layout depends on changes.

import { boundLinks, boundNodes, graph, setElbowLinks } from "./core.ts";
import { approach } from "./graph-types.ts";

// Each node's object is counter-scaled so spheres stay round; links, sibling lines and guides simply flatten. Not
// exactly 0, which would make the matrices singular (raycasting and normals invert them).
const FLAT = 1e-3;

let flatTarget = 1;
let rightAngles = true;

const isFlat = () => flatTarget !== 1;
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
