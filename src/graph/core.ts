// Graph core: the ThreeForceGraph instance, person and marriage-node objects, the physics settings, shared types.
//
// What it does: defines how a person (sphere, name, badge, tag, path and line rings, halo), a union (marriage) node
// and a link's travelling dots look; hands link building and placing to links.ts; configures the physics (charge
// range, per-house depth pull, fast cooldown); and exposes helpers for the other files (boundNodes/boundLinks,
// isShown, nameOf, disposeObject, approach, endId, setElbowLinks).
// Usage: every other file in src/graph/ builds on this one; graph.ts calls useTree() and re-exports graph, isShown and
// Node. The row forces live in forces.ts, link geometry in links.ts.
// Notes: useTree() must run before graphData(). Per-object materials (not the library's shared ones) are essential,
// because highlight.ts fades each object separately. The userData flags set here and in links.ts (isName, isTag,
// isPathRing, isLineRing, isHalo, isUnion, isUnionRing, unionId, personId, isLinkLine, link) are read by highlight.ts,
// names.ts and ui/picking.ts: keep them in sync.

import * as THREE from "three";
import { forceZ } from "d3-force-3d";
import ThreeForceGraph from "three-forcegraph";
import SpriteText from "three-spritetext";
import type { LineSegments2 } from "three/addons/lines/LineSegments2.js";
import { quality } from "../render/device.ts";
import type { Tree } from "../data/schema.ts";
import { houseDepths } from "../tree/family.ts";
import { disposeLabel, houseBadge, nameLabel, relationLabel } from "../render/labels.ts";
import { palette } from "../render/palettes.ts";
import { linkGlow, linkLine, placeLink, useElbows } from "./links.ts";
import type { Bound, Link, Node } from "./graph-types.ts";

export const DEPTH = 240; // front-to-back spread of the house planes (world units)
export const NAME_Y = 10; // centre of a person's name label above theirs: two lines, ~8.6 tall (names.ts grows it)
export const TAG_Y = 17.5; // the "relative to" tag, just above the name (names.ts lifts it as the name grows)

// Detail per tier (device.ts): 48×24 ≈ 2,300 triangles per person on high, 20×12 ≈ 480 on low: a 5× saving for old
// GPUs, with no visible difference at the size spheres appear on a phone.
const personGeo = new THREE.SphereGeometry(4, ...quality.sphereSegments);

const unionGeo = new THREE.SphereGeometry(0.9, 12, 6);
const dotGeo = new THREE.SphereGeometry(0.6, 4, 4); // link particles

// A thin ring, drawn once and shared: around union (marriage) nodes so couples read at a glance, and around people on
// a relationship path, a shape cue that doesn't depend on colour.
let ringTex: THREE.CanvasTexture | null = null;

// A soft radial glow, drawn once and shared: the halo behind a selected person or one on a relationship path.
let haloTex: THREE.CanvasTexture | null = null;

/** True while the force layout is still moving nodes (from a new graphData() until the engine stops). */
export let layoutRunning = false;

let tree: Tree;
let houseZ = new Map<string, number>();

export const graph = new ThreeForceGraph<Node, Link>()
    .nodeThreeObject((n) => {
        // Union (marriage) nodes: a small dot in a ring. Their own materials, so they fade with the highlight; the
        // group is scaled up by highlight.ts while its couple is lit.
        if (!n.name) {
            const dot = new THREE.Mesh(unionGeo, new THREE.MeshBasicMaterial({ color: palette().union }));
            const unionRing = ring(palette().union, 3.6, 0.45);
            unionRing.userData.isUnionRing = true; // only the ring grows when the couple is lit, not the dot
            freeze(dot); // the ring is rescaled by highlight.ts, so it stays automatic
            const group = new THREE.Group().add(dot, unionRing);
            group.userData.isUnion = true;
            group.userData.unionId = n.id; // picking.ts: hover or click a family's marriage node
            return group;
        }
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
        label.position.y = NAME_Y;
        label.userData.isName = true;
        // House badge just below the sphere, and a "relative to" tag above the name (filled in by setRelativeTags).
        const badge = houseBadge(n.house!, tree.houseColors[n.house!] ?? palette().unknownHouse);
        badge.position.set(0, -6.2, 0);
        const tag = relationLabel(" ", palette().labels.tag);
        tag.position.y = TAG_Y;
        tag.visible = false;
        tag.userData.isTag = true;
        // Ring around the person while they're on a relationship path (faded in by highlight.ts; starts hidden).
        const pathRing = ring(palette().links.pathGlow, 12, 0.9);
        pathRing.userData.isPathRing = true;
        pathRing.userData.dim = pathRing.userData.dimTarget = 0;
        pathRing.visible = false;
        // Ring in the lineage key's colour (rose ancestor / blue descendant) while in a selected person's line, so the
        // direction reads whatever the house colour; recoloured by highlight.ts.
        const lineRing = ring(palette().lineage.ancestor, 10, 0.85);
        lineRing.userData.isLineRing = true;
        lineRing.userData.dim = lineRing.userData.dimTarget = 0;
        lineRing.visible = false;
        // A soft halo in the person's own colour while they're selected or on a relationship path, so they're easy to
        // find with the Glow (bloom) option off as well. Additive, so it brightens what's behind rather than covers it.
        const halo = new THREE.Sprite(
            new THREE.SpriteMaterial({
                map: haloTexture(),
                color: tree.houseColors[n.house!] ?? palette().unknownHouse,
                transparent: true,
                opacity: 0.9,
                depthWrite: false,
                blending: THREE.AdditiveBlending,
            })
        );
        halo.scale.setScalar(22);
        halo.userData.isHalo = true;
        halo.userData.dim = halo.userData.dimTarget = 0;
        halo.visible = false;
        // These never move or resize relative to their person, so compute their local matrices once rather than every
        // frame: three.js otherwise recomposes ~5 matrices per person per frame (measured ~20% of a frame orbiting the
        // Bible). The group itself still updates (the layout moves it, 2D mode counter-scales it). The tag is left
        // automatic because SpriteText rescales itself when its text changes.
        for (const o of [sphere, label, badge, pathRing, lineRing, halo]) freeze(o);
        return new THREE.Group().add(sphere, label, badge, tag, pathRing, lineRing, halo);
    })
    .linkDirectionalParticles((l) => (l.kind === "child" ? 2 : 0))
    // Own material per link (the library shares one per colour), so a link's dots fade with its highlight.
    // Same look as the library default: 0.6 radius, 4 segments, at opacity 0.6; colour from the palette.
    .linkDirectionalParticleThreeObject(
        () =>
            new THREE.Mesh(
                dotGeo,
                new THREE.MeshLambertMaterial({ color: palette().particle, transparent: true, opacity: 0.6 })
            )
    )
    // Our own link object, replacing the library's cylinder: [line, label]. The line is a fat screen-space line
    // (LineSegments2) with its own material, so each link fades on its own (the library shares one per colour) and
    // keeps a constant pixel width at any zoom. It is raycastable, so links can be hovered and clicked (picking.ts).
    .linkThreeObjectExtend(false)
    .linkThreeObject((l) => {
        const line = linkLine(l);
        const label = relationLabel(l.label, l.kind === "spouse" ? palette().labels.spouse : palette().labels.child);
        return new THREE.Group().add(line, label, linkGlow(line));
    })
    .linkPositionUpdate((obj, { start, end }, l) => {
        const [line, label] = obj.children as [LineSegments2, THREE.Object3D];
        placeLink(line, label, start, end, l);
        return true; // fully placed here: the library has no default line to update
    });

/**
 * Draw links as right-angled connectors (2D) or straight (3D). Called by flat.ts. Every link is re-placed at once, so
 * switching needs no layout restart (that restart, at full energy, made Game of Thrones shimmy for seconds).
 */
let elbowsOn = false;

function ringTexture(): THREE.CanvasTexture {
    if (ringTex) return ringTex;
    const c = document.createElement("canvas");
    c.width = c.height = 64;
    const g = c.getContext("2d")!;
    g.lineWidth = 5;
    g.strokeStyle = "#fff";
    g.beginPath();
    g.arc(32, 32, 27, 0, Math.PI * 2);
    g.stroke();
    ringTex = new THREE.CanvasTexture(c);
    ringTex.colorSpace = THREE.SRGBColorSpace;
    return ringTex;
}

function haloTexture(): THREE.CanvasTexture {
    if (haloTex) return haloTex;
    const c = document.createElement("canvas");
    c.width = c.height = 64;
    const g = c.getContext("2d")!;
    const grad = g.createRadialGradient(32, 32, 0, 32, 32, 32);
    grad.addColorStop(0, "rgba(255,255,255,0.9)");
    grad.addColorStop(0.3, "rgba(255,255,255,0.45)");
    grad.addColorStop(1, "rgba(255,255,255,0)");
    g.fillStyle = grad;
    g.fillRect(0, 0, 64, 64);
    haloTex = new THREE.CanvasTexture(c);
    haloTex.colorSpace = THREE.SRGBColorSpace;
    return haloTex;
}

function ring(colour: THREE.ColorRepresentation, size: number, opacity: number): THREE.Sprite {
    const s = new THREE.Sprite(
        new THREE.SpriteMaterial({ map: ringTexture(), color: colour, transparent: true, opacity, depthWrite: false })
    );
    s.scale.setScalar(size);
    return s;
}

export const markLayoutRunning = () => (layoutRunning = true);

/** Compute an object's local matrix now and stop recomputing it each frame (it never moves within its group). */
function freeze(o: THREE.Object3D): void {
    o.updateMatrix();
    o.matrixAutoUpdate = false;
}

/** The tree the node objects are built from (house colours) and its house depth planes. Set before graphData(). */
export function useTree(t: Tree): void {
    tree = t;
    houseZ = houseDepths(t, DEPTH);
}

export function setElbowLinks(on: boolean): void {
    if (on === elbowsOn) return;
    elbowsOn = on;
    useElbows(on);
    for (const l of boundLinks()) {
        const obj = l.__lineObj;
        if (!obj || typeof l.source === "string" || typeof l.target === "string" || l.source.x === undefined) continue;
        placeLink(obj.children[0] as LineSegments2, obj.children[1], l.source, l.target, l);
    }
}

/** The library's node and link data, with the three.js objects it has bound to each. */
export const boundNodes = () => graph.graphData().nodes as (Node & Bound)[];

export const boundLinks = () => graph.graphData().links as (Link & Bound)[];

/** False for a person hidden by focus mode (their target opacity is 0): skipped by picking, framing and labels. */
export const isShown = (n: Node & Bound) => (n.__threeObj?.userData.dimTarget ?? 1) > 0;

/** A person's name label (the sprite above their sphere), if their object has been built. */
export const nameOf = (n: Node & Bound) =>
    n.__threeObj?.children.find((c) => c.userData.isName) as SpriteText | undefined;

/** Free an object's per-object materials, label textures and link buffers (shared geometries and badges are kept). */
export function disposeObject(obj: THREE.Object3D | undefined): void {
    obj?.traverse((o) => {
        if (o instanceof SpriteText) return disposeLabel(o);
        if (o.userData.ownGeometry) (o as THREE.Mesh).geometry.dispose(); // a link's line buffer
        // Disposing a SpriteMaterial leaves its shared (cached badge) texture alone.
        ((o as THREE.Mesh).material as THREE.Material | undefined)?.dispose();
    });
}

// Unbounded repulsion drives disconnected families apart forever; cap its range so the tree stays compact.
graph.d3Force("charge")!.distanceMax(120);

// CONVERGENCE. The library defaults are cooldownTicks = Infinity and cooldownTime = 15 s, so every saga load ran
// the physics (and, through auto-fit, moved the camera and forced full-rate rendering) for 15 seconds: measured
// nodes still drifting 3 units/s at 12 s. With heights pinned per generation and a weak depth pull there's little
// left to solve, so cool faster (alphaDecay 0.045 ≈ 150 ticks to rest vs d3's 300), damp more so it doesn't wobble
// while settling, and stop hard at 300 ticks or 5 s, whichever comes first. Once stopped, nothing moves, so the
// frame loop's idle throttling (main.ts) can take over. Interaction never needs the simulation running.
graph.d3AlphaDecay(0.045).d3VelocityDecay(0.65).cooldownTicks(300).cooldownTime(5000);

// Per-frame passes that skip work once things are still (names.ts) need to know the layout has stopped moving nodes.
graph.onEngineStop(() => (layoutRunning = false));

// Depth for parallax: pull each house towards its own z plane, so panning moves near families faster than far ones.
// A weak pull (strength < 1), so links and repulsion still shape the layout.
graph.d3Force(
    "depth",
    forceZ<Node>((n) => (n.house ? (houseZ.get(n.house) ?? 0) : 0)).strength((n) => (n.house ? 0.08 : 0.02))
);
