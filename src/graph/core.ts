// The graph instance itself: node and link objects, the force layout, shared types and helpers. Every other file in
// src/graph/ builds on this one; src/graph.ts is the public entry point that ties them together.
import * as THREE from "three";
import { forceZ } from "d3-force-3d";
import ThreeForceGraph from "three-forcegraph";
import SpriteText from "three-spritetext";
import { quality } from "../device.ts";
import type { Tree } from "../data/schema.ts";
import { houseDepths } from "../family.ts";
import { disposeLabel, houseBadge, nameLabel, relationLabel } from "../labels.ts";
import { palette } from "../palettes.ts";

export type Node = { id: string; name?: string; house?: string; x?: number; y?: number; z?: number; fy?: number };
/** A node while the simulation runs: d3 adds a velocity, which the custom forces (flat.ts) push on. */
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

export const DEPTH = 240; // front-to-back spread of the house planes (world units)
export const LINK_OPACITY = 0.45; // resting opacity of family links (the library default, 0.2, is too faint at a distance)

// Detail per tier (device.ts): 48×24 ≈ 2,300 triangles per person on high, 20×12 ≈ 480 on low: a 5× saving for old
// GPUs, with no visible difference at the size spheres appear on a phone.
const personGeo = new THREE.SphereGeometry(4, ...quality.sphereSegments);
const unionGeo = new THREE.SphereGeometry(1.2, 12, 6);
const dotGeo = new THREE.SphereGeometry(0.6, 4, 4); // link particles

let tree: Tree;
let houseZ = new Map<string, number>();
/** The tree the node objects are built from (house colours) and its house depth planes. Set before graphData(). */
export function useTree(t: Tree): void {
    tree = t;
    houseZ = houseDepths(t, DEPTH);
}

export const graph = new ThreeForceGraph<Node, Link>()
    .nodeThreeObject((n) => {
        // Union (marriage) nodes get their own material too, so they can fade with the highlight like people do.
        if (!n.name) return new THREE.Mesh(unionGeo, new THREE.MeshBasicMaterial({ color: palette().union }));
        // Matte, satin-like surface: high roughness spreads the highlight wide and soft, so the form reads from the
        // light-to-shadow gradient (see the key/fill balance in scene.ts) rather than from a glossy hotspot.
        const mat = new THREE.MeshStandardMaterial({
            color: tree.houseColors[n.house!] ?? palette().unknownHouse,
            roughness: 0.78,
            metalness: 0,
        });
        const sphere = new THREE.Mesh(personGeo, mat);
        sphere.userData.personId = n.id; // picked by the raycaster for hover/click
        const label = nameLabel(n.name);
        label.position.y = 8;
        label.userData.isName = true;
        // House badge just below the sphere, and a "relative to" tag above the name (filled in by setRelativeTags).
        const badge = houseBadge(n.house!, tree.houseColors[n.house!] ?? palette().unknownHouse);
        badge.position.set(0, -6.2, 0);
        const tag = relationLabel(" ", palette().labels.tag);
        tag.position.y = 12;
        tag.visible = false;
        tag.userData.isTag = true;
        return new THREE.Group().add(sphere, label, badge, tag);
    })
    // One material per link. The library otherwise shares one material per colour, so dimming one link dimmed every
    // link of that colour and the last one processed decided them all.
    .linkMaterial(
        (l) =>
            new THREE.MeshLambertMaterial({
                color: l.kind === "spouse" ? palette().links.spouse : palette().links.child,
                transparent: true,
                opacity: LINK_OPACITY,
                depthWrite: false,
            })
    )
    .linkWidth(0.6)
    .linkDirectionalParticles((l) => (l.kind === "child" ? 2 : 0))
    // Own material per link (the library shares one per colour), so a link's dots fade with its highlight.
    // Same look as the library default: 0.6 radius, 4 segments, #f0f0f0 at opacity 0.6.
    .linkDirectionalParticleThreeObject(
        () =>
            new THREE.Mesh(dotGeo, new THREE.MeshLambertMaterial({ color: 0xf0f0f0, transparent: true, opacity: 0.6 }))
    )
    .linkThreeObjectExtend(true)
    .linkThreeObject((l) =>
        relationLabel(l.label, l.kind === "spouse" ? palette().labels.spouse : palette().labels.child)
    )
    .linkPositionUpdate((label, { start, end }) => {
        midpoint(label, start, end);
        return false; // still let the library position the default line
    });

// Unbounded repulsion drives disconnected families apart forever; cap its range so the tree stays compact.
graph.d3Force("charge")!.distanceMax(120);

// CONVERGENCE. The library defaults are cooldownTicks = Infinity and cooldownTime = 15 s, so every saga load ran
// the physics (and, through auto-fit, moved the camera and forced full-rate rendering) for 15 seconds: measured
// nodes still drifting 3 units/s at 12 s. With heights pinned per generation and a weak depth pull there's little
// left to solve, so cool faster (alphaDecay 0.045 ≈ 150 ticks to rest vs d3's 300), damp more so it doesn't wobble
// while settling, and stop hard at 300 ticks or 5 s, whichever comes first. Once stopped, nothing moves, so the
// frame loop's idle throttling (app.ts) can take over. Interaction never needs the simulation running.
graph.d3AlphaDecay(0.045).d3VelocityDecay(0.5).cooldownTicks(300).cooldownTime(5000);
// Depth for parallax: pull each house towards its own z plane, so panning moves near families faster than far ones.
// A weak pull (strength < 1), so links and repulsion still shape the layout.
graph.d3Force(
    "depth",
    forceZ<Node>((n) => (n.house ? (houseZ.get(n.house) ?? 0) : 0)).strength((n) => (n.house ? 0.08 : 0.02))
);

/** The library's node and link data, with the three.js objects it has bound to each. */
export const boundNodes = () => graph.graphData().nodes as (Node & Bound)[];
export const boundLinks = () => graph.graphData().links as (Link & Bound)[];

/** A person's name label (the sprite above their sphere), if their object has been built. */
export const nameOf = (n: Node & Bound) =>
    n.__threeObj?.children.find((c) => c.userData.isName) as SpriteText | undefined;

/** Free an object's per-object materials and label textures (shared geometries and badge textures are kept). */
export function disposeObject(obj: THREE.Object3D | undefined): void {
    obj?.traverse((o) => {
        if (o instanceof SpriteText) return disposeLabel(o);
        // Disposing a SpriteMaterial leaves its shared (cached badge) texture alone.
        ((o as THREE.Mesh).material as THREE.Material | undefined)?.dispose();
    });
}
