// Graph core: the ThreeForceGraph instance, node and link objects, force layout, shared types and helpers.
//
// What it does: defines how a person, union (marriage) node, link, link label and particle look (nodeThreeObject etc.),
// configures the physics (charge range, per-house depth pull, fast cooldown) and exposes helpers for the other files.
// Links are our own objects (a fat screen-space line plus its label): straight in 3D, right-angled elbows in 2D.
// Usage: every other file in src/graph/ builds on this one; src/graph.ts calls useTree() and re-exports graph, isShown
// and Node. Exports include graph, Node/Link/Bound types, boundNodes/boundLinks, nameOf, disposeObject, approach.
// Notes: useTree() must run before graphData(). Per-object materials (not the library's shared ones) are essential,
// because highlight.ts fades each object separately. The userData flags set here (isName, isTag, isPathRing,
// isLineRing, isUnion, isUnionRing, personId, isLinkLine, link) are read by highlight.ts, names.ts and picking: keep
// them in sync. A link object is a Group of [line, label, glow], in that order (highlight.ts and names.ts index it).
// linkResolution must hold the view size in CSS px (stepGraph sets it each frame), or line widths and link picking
// are wrong.

import * as THREE from "three";
import { forceZ } from "d3-force-3d";
import ThreeForceGraph from "three-forcegraph";
import SpriteText from "three-spritetext";
import { LineMaterial } from "three/addons/lines/LineMaterial.js";
import { LineSegments2 } from "three/addons/lines/LineSegments2.js";
import { LineSegmentsGeometry } from "three/addons/lines/LineSegmentsGeometry.js";
import { quality } from "../device.ts";
import type { Tree } from "../data/schema.ts";
import { houseDepths } from "../family.ts";
import { disposeLabel, houseBadge, nameLabel, relationLabel } from "../labels.ts";
import { palette } from "../palettes.ts";

export type Node = {
    id: string;
    name?: string;
    house?: string;
    x?: number;
    y?: number;
    z?: number;
    fy?: number;
    lane?: number; // union nodes only: which bar height its 2D connectors use (see placeLink)
};
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
// Links are drawn this many CSS px wide at any distance. The old 0.6-unit cylinders thinned to broken, shimmering
// sub-pixel lines when zoomed out; a screen-space width stays crisp and visible. Path links are wider (highlight.ts).
export const LINK_PX = 1.6;
export const NAME_Y = 10; // centre of a person's name label above theirs: two lines, ~8.6 tall (names.ts grows it)
export const TAG_Y = 17.5; // the "relative to" tag, just above the name (names.ts lifts it as the name grows)
/** The view size in CSS px, shared by every link material (fat lines need it); set each frame by stepGraph. */
export const linkResolution = new THREE.Vector2(innerWidth, innerHeight);

// Detail per tier (device.ts): 48×24 ≈ 2,300 triangles per person on high, 20×12 ≈ 480 on low: a 5× saving for old
// GPUs, with no visible difference at the size spheres appear on a phone.
const personGeo = new THREE.SphereGeometry(4, ...quality.sphereSegments);
const unionGeo = new THREE.SphereGeometry(0.9, 12, 6);
const dotGeo = new THREE.SphereGeometry(0.6, 4, 4); // link particles

// A thin ring, drawn once and shared: around union (marriage) nodes so couples read at a glance, and around people on
// a relationship path, a shape cue that doesn't depend on colour.
let ringTex: THREE.CanvasTexture | null = null;
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
// A soft radial glow, drawn once and shared: the halo behind a selected person or one on a relationship path.
let haloTex: THREE.CanvasTexture | null = null;
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

/** True while the force layout is still moving nodes (from a new graphData() until the engine stops). */
export let layoutRunning = false;
export const markLayoutRunning = () => (layoutRunning = true);

/** Compute an object's local matrix now and stop recomputing it each frame (it never moves within its group). */
function freeze(o: THREE.Object3D): void {
    o.updateMatrix();
    o.matrixAutoUpdate = false;
}

let tree: Tree;
let houseZ = new Map<string, number>();
/** The tree the node objects are built from (house colours) and its house depth planes. Set before graphData(). */
export function useTree(t: Tree): void {
    tree = t;
    houseZ = houseDepths(t, DEPTH);
}

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

function linkLine(l: Link): LineSegments2 {
    const geometry = new LineSegmentsGeometry();
    geometry.setPositions(new Float32Array(SEGMENTS * 6)); // written in place by placeLink
    const material = new LineMaterial({
        color: l.kind === "spouse" ? palette().links.spouse : palette().links.child,
        linewidth: LINK_PX,
        transparent: true,
        opacity: LINK_OPACITY,
        depthWrite: false,
        fog: true,
    });
    material.uniforms.resolution.value = linkResolution; // one shared vector, updated each frame
    material.userData.base = material.color.clone(); // highlight.ts tints towards gold from this
    const line = new LineSegments2(geometry, material);
    line.userData.isLinkLine = true;
    line.userData.ownGeometry = true; // disposeObject frees it (other geometries are shared)
    line.userData.link = l; // picking.ts: which link the pointer is on
    return line;
}

/**
 * A wide, faint, additive copy of a link line (sharing its buffer), shown under a relationship path so the route
 * glows without the Glow option. Hidden at rest; highlight.ts fades it with the path.
 */
function linkGlow(line: LineSegments2): LineSegments2 {
    const material = new LineMaterial({
        color: palette().links.pathGlow,
        linewidth: LINK_PX * 6,
        transparent: true,
        opacity: 0,
        depthWrite: false,
        blending: THREE.AdditiveBlending,
        fog: true,
    });
    material.uniforms.resolution.value = linkResolution;
    const glow = new LineSegments2(line.geometry, material);
    glow.userData.isLinkLine = true; // faded by highlight.ts's link pass, not the generic one
    glow.visible = false;
    return glow;
}

// --- Where a link and its label go -----------------------------------------------------------------------------------
// Every link is three segments (four points), so its buffer never needs resizing: in 3D a straight line split in
// thirds; in 2D a right-angled family-tree connector. In 2D a parent drops from under their badge and runs across to
// the union, so a couple reads as joined by a bar; a child link drops below the union, runs across to above the child
// and down to just over their name, so brothers and sisters hang off one shared bar.
// Lanes: if every couple's bar sat at its union's height (and every sibling bar the same drop below it), neighbouring
// families' horizontal runs lay on top of each other and you couldn't tell whose mother line was whose. So each
// family on a row gets a lane (graph.ts assigns them in turn, `Node.lane`), and its bars sit at that lane's height.
const SEGMENTS = 3;
const BELOW_BADGE = 8; // a parent's line starts under their house badge (it sits 6.2 below centre, 3.2 across)
const ABOVE_NAME = 15.5; // a child's line ends above their name (two lines centred on NAME_Y)
const BAR_DROP = 12; // the sibling bar sits at least this far below the union
export const LANES = 4; // bar heights per row, so up to four neighbouring families' bars never coincide
const LANE_GAP = 4; // world units between lanes (a row is 80; the union sits 40 below its parents)
const LABEL_REACH = 20; // world units along a straight link from its person; half an ordinary link
let elbows = false;
/** Draw links as right-angled connectors (2D) or straight (3D). Called by flat.ts; takes effect as the layout runs. */
export const setElbowLinks = (on: boolean) => (elbows = on);

const pts = new Float32Array((SEGMENTS + 1) * 3);
const put = (i: number, x: number, y: number, z: number) => pts.set([x, y, z], i * 3);
function placeLink(line: LineSegments2, label: THREE.Object3D, start: Pos, end: Pos, l: Link): void {
    const [a, b] = [start as Required<Pos>, end as Required<Pos>];
    const kind = l.kind;
    const union = kind === "spouse" ? l.target : l.source;
    const lane = typeof union === "string" ? 0 : (union.lane ?? 0);
    if (elbows && kind === "child") {
        // a = union, b = child; the sibling bar drops further below the union the higher its family's lane
        const top = b.y + ABOVE_NAME;
        const bar = Math.max(top, a.y - BAR_DROP - lane * LANE_GAP);
        put(0, a.x, a.y, a.z);
        put(1, a.x, bar, a.z);
        put(2, b.x, bar, b.z);
        put(3, b.x, top, b.z);
        label.position.set(b.x, (bar + top) / 2, b.z);
    } else if (elbows) {
        // a = parent, b = union: down from the parent to the family's lane, across, and up or down into the union
        const from = a.y - BELOW_BADGE;
        const bar = b.y + (lane - (LANES - 1) / 2) * LANE_GAP;
        put(0, a.x, from, a.z);
        put(1, a.x, bar, a.z);
        put(2, b.x, bar, b.z);
        put(3, b.x, b.y, b.z);
        label.position.set(a.x, (from + bar) / 2, a.z);
    } else {
        for (let i = 0; i <= SEGMENTS; i++) {
            const t = i / SEGMENTS;
            put(i, a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t, a.z + (b.z - a.z) * t);
        }
        // A label sits beside the person it describes: "son"/"daughter" near the child, "father"/"mother"/"wife" near
        // the parent, at most LABEL_REACH along the link. On an ordinary link (half a row, 40 units) that's its
        // midpoint. A link across several rows (Ginny sits with Harry, two rows below Arthur and Molly) used to put
        // its label at the midpoint, among her brothers, where "daughter" read as Bill's.
        const [near, far] = kind === "child" ? [b, a] : [a, b]; // child links run union → child; spouse parent → union
        const len = Math.hypot(far.x - near.x, far.y - near.y, far.z - near.z);
        const t = len > 0 ? Math.min(0.5, LABEL_REACH / len) : 0.5;
        label.position.set(near.x + (far.x - near.x) * t, near.y + (far.y - near.y) * t, near.z + (far.z - near.z) * t);
    }
    // Segment s runs from point s to point s + 1, so the interleaved buffer is the points with each inner one twice.
    const start3 = line.geometry.attributes.instanceStart as THREE.InterleavedBufferAttribute;
    const buf = start3.data.array as Float32Array;
    for (let s = 0; s < SEGMENTS; s++) for (let j = 0; j < 6; j++) buf[s * 6 + j] = pts[s * 3 + j];
    start3.data.needsUpdate = true;
    line.geometry.computeBoundingSphere(); // culling and picking use it
}

// Unbounded repulsion drives disconnected families apart forever; cap its range so the tree stays compact.
graph.d3Force("charge")!.distanceMax(120);

// CONVERGENCE. The library defaults are cooldownTicks = Infinity and cooldownTime = 15 s, so every saga load ran
// the physics (and, through auto-fit, moved the camera and forced full-rate rendering) for 15 seconds: measured
// nodes still drifting 3 units/s at 12 s. With heights pinned per generation and a weak depth pull there's little
// left to solve, so cool faster (alphaDecay 0.045 ≈ 150 ticks to rest vs d3's 300), damp more so it doesn't wobble
// while settling, and stop hard at 300 ticks or 5 s, whichever comes first. Once stopped, nothing moves, so the
// frame loop's idle throttling (app.ts) can take over. Interaction never needs the simulation running.
graph.d3AlphaDecay(0.045).d3VelocityDecay(0.5).cooldownTicks(300).cooldownTime(5000);
// Per-frame passes that skip work once things are still (names.ts) need to know the layout has stopped moving nodes.
graph.onEngineStop(() => (layoutRunning = false));
// Depth for parallax: pull each house towards its own z plane, so panning moves near families faster than far ones.
// A weak pull (strength < 1), so links and repulsion still shape the layout.
graph.d3Force(
    "depth",
    forceZ<Node>((n) => (n.house ? (houseZ.get(n.house) ?? 0) : 0)).strength((n) => (n.house ? 0.08 : 0.02))
);

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
