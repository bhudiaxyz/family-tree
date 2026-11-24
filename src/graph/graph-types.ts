// Graph types: the graph's node and link types and a few small helpers, used across src/graph/ and the UI.
//
// What it does: defines Node (a person or marriage node as the layout sees it), SimNode (with d3's velocity), Link
// (a parent → marriage node "spouse" link or a marriage node → child "child" link), End and Bound (the three.js
// objects the graph library attaches); and endId(), midpoint() and approach().
// Usage: imported by every file in src/graph/ and by ui/ through graph/graph.ts's re-exports.
// Notes: kept apart from core.ts so modules core.ts uses (links.ts) can share these types without importing core.ts,
// which would make the two import each other. Only types and pure helpers here: no state, no three.js objects built.

import type * as THREE from "three";

export type Node = {
    id: string;
    name?: string;
    house?: string;
    x?: number;
    y?: number;
    z?: number;
    fy?: number;
};
/** A node while the simulation runs: d3 adds a velocity, which the row forces (forces.ts) push on. */
export type SimNode = Node & { vx?: number };
// The library swaps link source/target ids for node objects once the simulation starts.
export type End = string | Node;
export type Link = { source: End; target: End; kind: "spouse" | "child"; label: string };
// Objects the library attaches to its data (see three-forcegraph's objBindAttr).
export type Bound = { __threeObj?: THREE.Object3D; __lineObj?: THREE.Object3D; __photonsObj?: THREE.Object3D };
type Pos = { x?: number; y?: number; z?: number };

export const endId = (e: End) => (typeof e === "string" ? e : e.id);
export const midpoint = (obj: THREE.Object3D, a: Pos, b: Pos) =>
    obj.position.set((a.x! + b.x!) / 2, (a.y! + b.y!) / 2, (a.z! + b.z!) / 2);
/** Move `cur` a fraction `k` of the way to `target` (k from 1 - exp(-rate·dt), so easing is frame-rate independent). */
export const approach = (cur: number, target: number, k: number) => cur + (target - cur) * k;
