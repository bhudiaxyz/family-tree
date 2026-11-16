// The family tree as a three.js object: build nodes/links from a Tree, the sibling overlay, highlight and label fade.
import * as THREE from "three";
import ThreeForceGraph from "three-forcegraph";
import SpriteText from "three-spritetext";
import { forceZ } from "d3-force-3d";
import type { Tree } from "./data/schema.ts";
import { generations } from "./generations.ts";
import { childLabel, houseDepths, parentLabel, siblingLabel } from "./family.ts";
import { disposeLabel, nameLabel, relationLabel } from "./labels.ts";

export type Node = { id: string; name?: string; house?: string; x?: number; y?: number; z?: number; fy?: number };
// The library swaps link source/target ids for node objects once the simulation starts.
type End = string | Node;
type Link = { source: End; target: End; kind: "spouse" | "child"; label: string };
// Objects the library attaches to its data (see three-forcegraph's objBindAttr).
type Bound = { __threeObj?: THREE.Object3D; __lineObj?: THREE.Object3D };
type Pos = { x?: number; y?: number; z?: number };

const endId = (e: End) => (typeof e === "string" ? e : e.id);
const midpoint = (obj: THREE.Object3D, a: Pos, b: Pos) =>
    obj.position.set((a.x! + b.x!) / 2, (a.y! + b.y!) / 2, (a.z! + b.z!) / 2);

const GEN_GAP = 80; // vertical gap between generations (world units)
const DEPTH = 240; // front-to-back spread of the house planes (world units)
const DIM = 0.12; // opacity of everything outside a highlighted line
const LABEL_NEAR = 110; // relationship labels are fully visible within this distance of the camera…
const LABEL_FAR = 240; // …and hidden beyond this one

const personGeo = new THREE.SphereGeometry(4, 48, 24);
const unionGeo = new THREE.SphereGeometry(1.2, 12, 6);
const unionMat = new THREE.MeshBasicMaterial({ color: 0xffffff });
const siblingMat = new THREE.LineDashedMaterial({ color: 0x5f8f7a, dashSize: 2, gapSize: 1.5, transparent: true });

let tree: Tree;
let houseZ = new Map<string, number>();

export const graph = new ThreeForceGraph<Node, Link>()
    .nodeThreeObject((n) => {
        if (!n.name) return new THREE.Mesh(unionGeo, unionMat);
        // Matte, satin-like surface: high roughness spreads the highlight wide and soft, so the form reads from the
        // light-to-shadow gradient (see the key/fill balance in scene.ts) rather than from a glossy hotspot.
        const mat = new THREE.MeshStandardMaterial({
            color: tree.houseColors[n.house!] ?? "#888",
            roughness: 0.78,
            metalness: 0,
        });
        const sphere = new THREE.Mesh(personGeo, mat);
        sphere.userData.personId = n.id; // picked by the raycaster for hover/click
        const label = nameLabel(n.name);
        label.position.y = 8;
        return new THREE.Group().add(sphere, label);
    })
    .linkColor((l) => (l.kind === "spouse" ? "#c9ad73" : "#667"))
    .linkWidth(0.6)
    .linkDirectionalParticles((l) => (l.kind === "child" ? 2 : 0))
    .linkDirectionalParticleWidth(1.2)
    .linkThreeObjectExtend(true)
    .linkThreeObject((l) => relationLabel(l.label, l.kind === "spouse" ? "#e6cf95" : "#b8b8c8"))
    .linkPositionUpdate((label, { start, end }) => {
        midpoint(label, start, end);
        return false; // still let the library position the default line
    });

// Unbounded repulsion drives disconnected families apart forever; cap its range so the tree stays compact.
graph.d3Force("charge")!.distanceMax(120);
// Depth for parallax: pull each house towards its own z plane, so panning moves near families faster than far ones.
// A weak pull (strength < 1), so links and repulsion still shape the layout.
graph.d3Force(
    "depth",
    forceZ<Node>((n) => (n.house ? (houseZ.get(n.house) ?? 0) : 0)).strength((n) => (n.house ? 0.08 : 0.02))
);

// --- Sibling overlay ------------------------------------------------------------------------------------------------
// Drawn outside the graph data: as links they would pull siblings together and distort the layout. Repositioned
// from the live node positions every frame.
const siblings = new THREE.Group();
graph.add(siblings);
let siblingPairs: [Node, Node][] = [];
let siblingLabels: SpriteText[] = [];
const siblingLines = new THREE.LineSegments(new THREE.BufferGeometry(), siblingMat);
siblings.add(siblingLines);

function setSiblings(t: Tree, byId: Map<string, Node>, pairs: [string, string][]) {
    siblingLabels.forEach(disposeLabel);
    siblings.remove(...siblingLabels);
    siblingPairs = pairs.map(([a, b]) => [byId.get(a)!, byId.get(b)!]);
    siblingLabels = pairs.map(([a, b]) => relationLabel(siblingLabel(t, a, b), "#8fc4ab"));
    if (siblingLabels.length) siblings.add(...siblingLabels);
    siblingLines.geometry.dispose();
    siblingLines.geometry = new THREE.BufferGeometry();
    siblingLines.geometry.setAttribute("position", new THREE.Float32BufferAttribute(pairs.length * 6, 3));
}

function updateSiblings() {
    const pos = siblingLines.geometry.attributes.position as THREE.BufferAttribute | undefined;
    if (!pos) return; // no tree shown yet (the frame loop starts before the first saga loads)
    siblingPairs.forEach(([a, b], i) => {
        if (a.x === undefined || b.x === undefined) return;
        pos.setXYZ(i * 2, a.x, a.y!, a.z!);
        pos.setXYZ(i * 2 + 1, b.x, b.y!, b.z!);
        midpoint(siblingLabels[i], a, b);
    });
    pos.needsUpdate = true;
    siblingLines.geometry.computeBoundingSphere();
    siblingLines.computeLineDistances();
}

// --- Building a tree ------------------------------------------------------------------------------------------------
/** Replace the displayed tree. Generations are pinned to fixed heights; union nodes sit half a row below parents. */
export function showTree(t: Tree): void {
    tree = t;
    houseZ = houseDepths(t, DEPTH);
    const gen = generations(t);
    const rows = Math.max(0, ...gen.values());
    const y = (g: number) => (rows / 2 - g) * GEN_GAP;

    const nodes: Node[] = Object.entries(t.people).map(([id, p]) => ({ id, ...p, fy: y(gen.get(id)!) }));
    const links: Link[] = [];
    const pairs: [string, string][] = [];
    t.families.forEach((f, i) => {
        const u = `family${i}`;
        const parentRow = f.parents.length
            ? gen.get(f.parents[0])!
            : f.children.length
              ? Math.min(...f.children.map((c) => gen.get(c)!)) - 1
              : 0;
        nodes.push({ id: u, fy: y(parentRow + 0.5) });
        for (const p of f.parents) links.push({ source: p, target: u, kind: "spouse", label: parentLabel(t, p, f) });
        for (const c of f.children) links.push({ source: u, target: c, kind: "child", label: childLabel(t, c, f) });
        // Chain consecutive siblings rather than all pairs, to keep large families readable.
        for (let k = 1; k < f.children.length; k++) pairs.push([f.children[k - 1], f.children[k]]);
    });

    // Free the previous tree's per-node materials and label textures before the library drops the objects.
    for (const n of graph.graphData().nodes as (Node & Bound)[]) disposeObject(n.__threeObj);
    for (const l of graph.graphData().links as (Link & Bound)[]) disposeObject(l.__lineObj?.children[1]);

    setSiblings(t, new Map(nodes.map((n) => [n.id, n])), pairs);
    graph.graphData({ nodes, links });
    focus = null;
}

function disposeObject(obj: THREE.Object3D | undefined) {
    obj?.traverse((o) => {
        if (o instanceof SpriteText) return disposeLabel(o);
        const m = (o as THREE.Mesh).material as THREE.Material | undefined;
        if (m && m !== unionMat) m.dispose(); // shared geometries and the union material are reused
    });
}

/** Live node for a person (its position is updated by the simulation), if the tree has been laid out. */
export const nodeById = (id: string): Node | undefined => graph.graphData().nodes.find((n) => n.id === id);

// --- Highlight ------------------------------------------------------------------------------------------------------
let focus: Set<string> | null = null; // people in the highlighted line, or null to show everything

/** Dim everything outside `people` (null clears the highlight). Union nodes stay lit when any member is in it. */
export function highlight(people: Set<string> | null): void {
    focus = people;
    const { nodes, links } = graph.graphData();
    const unionsLit = new Set<string>();
    if (people)
        for (const l of links) {
            if (l.kind === "spouse" && people.has(endId(l.source))) unionsLit.add(endId(l.target));
            if (l.kind === "child" && people.has(endId(l.target))) unionsLit.add(endId(l.source));
        }
    const lit = (id: string) => !people || people.has(id) || unionsLit.has(id);
    for (const n of nodes as (Node & Bound)[]) setOpacity(n.__threeObj, lit(n.id) ? 1 : DIM);
    for (const l of links as (Link & Bound)[])
        setOpacity(l.__lineObj, lit(endId(l.source)) && lit(endId(l.target)) ? 1 : DIM);
    siblingPairs.forEach(([a, b], i) => setOpacity(siblingLabels[i], lit(a.id) && lit(b.id) ? 1 : DIM));
    siblingMat.opacity = people ? DIM : 1;
}

// Labels are faded every frame by fadeLabels(), so for them only record the factor; meshes and lines get it directly.
function setOpacity(obj: THREE.Object3D | undefined, opacity: number) {
    obj?.traverse((o) => {
        if (o instanceof SpriteText) return void (o.userData.dim = opacity);
        const m = (o as THREE.Mesh).material as THREE.Material | undefined;
        if (!m || m === unionMat) return;
        m.transparent = true;
        m.opacity = opacity * ((m.userData.baseOpacity ??= m.opacity) as number);
    });
}

// --- Label fade -----------------------------------------------------------------------------------------------------
const tmp = new THREE.Vector3();
// Relationship labels fade out with distance; those on the highlighted line stay readable at any distance.
function fadeLabels(camera: THREE.Camera) {
    const fade = (s: SpriteText) => {
        const dim = (s.userData.dim ?? 1) as number;
        const d = camera.position.distanceTo(s.getWorldPosition(tmp));
        const near = focus !== null && dim === 1 ? 1 : (LABEL_FAR - d) / (LABEL_FAR - LABEL_NEAR);
        s.material.transparent = true;
        s.material.opacity = dim * THREE.MathUtils.clamp(near, 0, 1);
        s.visible = s.material.opacity > 0.02;
    };
    for (const l of graph.graphData().links as (Link & Bound)[]) {
        const label = l.__lineObj?.children[1];
        if (label instanceof SpriteText) fade(label);
    }
    siblingLabels.forEach(fade);
}

/** Advance the simulation and the overlays by one frame. */
export function stepGraph(camera: THREE.Camera): void {
    graph.tickFrame();
    updateSiblings();
    fadeLabels(camera);
}
