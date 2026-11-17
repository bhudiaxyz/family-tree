// The family tree as a three.js object: build nodes/links from a Tree, the sibling overlay, highlight and label fade.
import * as THREE from "three";
import { forceZ } from "d3-force-3d";
import ThreeForceGraph from "three-forcegraph";
import SpriteText from "three-spritetext";
import { quality } from "./device.ts";
import type { Tree } from "./data/schema.ts";
import { childLabel, houseDepths, parentLabel, siblingLabel } from "./family.ts";
import { generations } from "./generations.ts";
import { disposeLabel, houseBadge, nameLabel, relationLabel } from "./labels.ts";
import { palette } from "./palettes.ts";

export type Node = { id: string; name?: string; house?: string; x?: number; y?: number; z?: number; fy?: number };
// The library swaps link source/target ids for node objects once the simulation starts.
type End = string | Node;
type Link = { source: End; target: End; kind: "spouse" | "child"; label: string };
// Objects the library attaches to its data (see three-forcegraph's objBindAttr).
type Bound = { __threeObj?: THREE.Object3D; __lineObj?: THREE.Object3D; __photonsObj?: THREE.Object3D };
type Pos = { x?: number; y?: number; z?: number };

const endId = (e: End) => (typeof e === "string" ? e : e.id);
const midpoint = (obj: THREE.Object3D, a: Pos, b: Pos) =>
    obj.position.set((a.x! + b.x!) / 2, (a.y! + b.y!) / 2, (a.z! + b.z!) / 2);

const GEN_GAP = 80; // vertical gap between generations (world units)
const DEPTH = 240; // front-to-back spread of the house planes (world units)
const DIM = 0.12; // opacity of everything outside a highlighted line
const LINK_OPACITY = 0.45; // resting opacity of family links (the library default, 0.2, is too faint at a distance)
const FADE_RATE = 10; // highlight fades converge at this rate per second (≈ 0.3 s to settle)
const LABEL_NEAR = 110; // relationship labels are fully visible within this distance of the camera…
const LABEL_FAR = 240; // …and hidden beyond this one

// Detail per tier (device.ts): 48×24 ≈ 2,300 triangles per person on high, 20×12 ≈ 480 on low: a 5× saving for old
// GPUs, with no visible difference at the size spheres appear on a phone.
const personGeo = new THREE.SphereGeometry(4, ...quality.sphereSegments);
const unionGeo = new THREE.SphereGeometry(1.2, 12, 6);
const dotGeo = new THREE.SphereGeometry(0.6, 4, 4); // link particles
const siblingMat = new THREE.LineDashedMaterial({
    color: palette().siblingLine,
    dashSize: 2,
    gapSize: 1.5,
    transparent: true,
});

let tree: Tree;
let houseZ = new Map<string, number>();

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
        (l) =>
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
    siblingLabels = pairs.map(([a, b]) => relationLabel(siblingLabel(t, a, b), palette().labels.sibling));
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
    for (const l of graph.graphData().links as (Link & Bound)[]) {
        disposeObject(l.__lineObj?.children[1]);
        disposeObject(l.__photonsObj?.children[0]); // the dots share one material per link
    }

    const byId = new Map(nodes.map((n) => [n.id, n]));
    siblingGroups = t.families.filter((f) => f.children.length > 1).map((f) => f.children.map((c) => byId.get(c)!));
    setSiblings(t, byId, pairs);
    setGuides(rows, y);
    graph.graphData({ nodes, links });
    focus = null;
}

function disposeObject(obj: THREE.Object3D | undefined) {
    obj?.traverse((o) => {
        if (o instanceof SpriteText) return disposeLabel(o);
        // Shared geometries and the cached house-badge textures are reused: only free the per-object material
        // (disposing a SpriteMaterial leaves its shared texture alone).
        ((o as THREE.Mesh).material as THREE.Material | undefined)?.dispose();
    });
}

// --- Generation guides: a faint band and a "Generation n" label at each row, so you can tell where you are --------
const guides = new THREE.Group();
graph.add(guides);
const guideMat = new THREE.LineBasicMaterial({
    color: palette().guideLine,
    transparent: true,
    opacity: 0.07,
    depthWrite: false,
});
function setGuides(rows: number, y: (g: number) => number) {
    guides.traverse((o) => o instanceof SpriteText && disposeLabel(o));
    for (const c of guides.children) if (c instanceof THREE.LineSegments) c.geometry.dispose();
    guides.clear();
    for (let g = 0; g <= rows; g++) {
        // A long horizontal line in the x-z plane at this generation's height (a cross, so it reads from any angle).
        const L = 600;
        const geo = new THREE.BufferGeometry().setFromPoints([
            new THREE.Vector3(-L, y(g), 0),
            new THREE.Vector3(L, y(g), 0),
            new THREE.Vector3(0, y(g), -L),
            new THREE.Vector3(0, y(g), L),
        ]);
        const line = new THREE.LineSegments(geo, guideMat);
        line.userData.guideRow = g;
        const label = relationLabel(`Generation ${g + 1}`, palette().labels.guide);
        label.backgroundColor = false as unknown as string; // no backing box for these
        label.userData.guideLabel = true;
        label.position.set(0, y(g) + 3, 0);
        guides.add(line, label);
    }
}
export const setGuidesVisible = (on: boolean) => (guides.visible = on);

// --- 2D mode: squash the house depth planes flat by easing the graph's z scale towards ~0 -------------------------
// Each node's object is counter-scaled so spheres stay round; links, sibling lines and guides simply flatten. Not
// exactly 0, which would make the matrices singular (raycasting and normals invert them).
const FLAT = 1e-3;
let flatTarget = 1;
export function setFlat(on: boolean): void {
    flatTarget = on ? FLAT : 1;
    graph.d3ReheatSimulation(); // re-run the layout so the row spacing below applies (or relaxes when back in 3D)
}

// In 3D, people in the same generation can share an x and still be apart in depth; flattened, they'd sit on top of
// each other. So in 2D a force pushes neighbours in each generation row apart until their names no longer touch.
// ponytail: name width estimated from character count; measure the label sprites if long names still collide.
const NAME_CHAR_W = 2; // world units per character of a name label (4 units tall, condensed bold)
const ROW_GAP = 5; // clearance between neighbouring names
const halfWidth = (n: Node) => Math.max(4, n.name!.length * NAME_CHAR_W) / 2;
function spreadRows() {
    let nodes: (Node & { vx?: number })[] = [];
    const force = () => {
        if (flatTarget === 1) return;
        const rows = new Map<number, typeof nodes>();
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
    force.initialize = (n: typeof nodes) => (nodes = n);
    return force;
}
graph.d3Force("spreadRows", spreadRows());

// Also in 2D, siblings are pulled sideways towards their family's centre, so brothers and sisters sit side by side
// rather than interleaved with cousins. spreadRows keeps them from overlapping, so they pack into a tight cluster.
const SIBLING_PULL = 0.15;
let siblingGroups: (Node & { vx?: number })[][] = [];
function clusterSiblings(alpha: number) {
    if (flatTarget === 1) return;
    for (const group of siblingGroups) {
        const placed = group.filter((n) => n.x !== undefined);
        if (placed.length < 2) continue;
        const cx = placed.reduce((s, n) => s + n.x!, 0) / placed.length;
        for (const n of placed) n.vx = (n.vx ?? 0) + (cx - n.x!) * SIBLING_PULL * alpha;
    }
}
graph.d3Force("clusterSiblings", clusterSiblings);
/** A node's z as drawn (node data keeps the simulation's z; the graph's scale squashes it in 2D). */
export const drawnZ = (z: number) => z * graph.scale.z;
function stepFlat(dt: number) {
    const s = graph.scale.z;
    const next = Math.abs(s - flatTarget) < 1e-3 ? flatTarget : approach(s, flatTarget, 1 - Math.exp(-5 * dt));
    graph.scale.z = next;
    // Every frame, not just while easing: a saga loaded in 2D builds fresh node objects at scale 1.
    for (const n of graph.graphData().nodes as (Node & Bound)[]) n.__threeObj?.scale.setZ(1 / next);
}

/**
 * Box around the people (not union nodes or guides), for framing the camera. Uses the 5th–95th percentile on each
 * axis, so one stray family off to the side doesn't push the whole view out; padded by a person's radius and label.
 * Null until the layout has placed anyone.
 */
export function peopleBbox(): { x: [number, number]; y: [number, number]; z: [number, number] } | null {
    const pts = graph.graphData().nodes.filter((n) => n.name && n.x !== undefined);
    if (!pts.length) return null;
    const range = (k: "x" | "y" | "z", lo = 0.05, hi = 0.95): [number, number] => {
        const v = pts.map((n) => n[k]!).sort((a, b) => a - b);
        const at = (q: number) => v[Math.min(v.length - 1, Math.max(0, Math.round(q * (v.length - 1))))];
        return [at(lo), at(hi)];
    };
    // Width: trim the 5% stragglers on wide screens, where it tightens the view. On a portrait phone, though, width is
    // the binding constraint, so trimming it pushes those people off the sides (measured: 39 of 42 visible); keep all.
    const portrait = innerWidth < innerHeight;
    const x = portrait ? range("x", 0, 1) : range("x");
    const z = range("z").map(drawnZ) as [number, number];
    // Vertical extent uses every person: generations are few and pinned, so there are no stray rows to ignore, and
    // cutting the top/bottom row would hide a whole generation. Pad for the name label above and badge below.
    const y = range("y", 0, 1);
    return { x: [x[0] - 6, x[1] + 6], y: [y[0] - 9, y[1] + 12], z };
}

/** Live node for a person (its position is updated by the simulation), if the tree has been laid out. */
export const nodeById = (id: string): Node | undefined => graph.graphData().nodes.find((n) => n.id === id);

// --- Highlight ------------------------------------------------------------------------------------------------------
// highlight() only sets a target "dim" per object (1 = lit, DIM = faded); stepFades() eases every object towards its
// target each frame, so highlights fade in and out instead of snapping. A relationship path additionally glows.
let focus: Set<string> | null = null; // people in the highlighted line, or null to show everything
let pathLinks = new Set<Link>(); // links on a relationship path, drawn brighter and thicker

/** Dim everything outside `people` (null clears it). `path` (a relationship chain) is emphasised on top. */
export function highlight(people: Set<string> | null, path: string[] = []): void {
    focus = people;
    const { nodes, links } = graph.graphData();
    const unionsLit = new Set<string>();
    if (people)
        for (const l of links) {
            if (l.kind === "spouse" && people.has(endId(l.source))) unionsLit.add(endId(l.target));
            if (l.kind === "child" && people.has(endId(l.target))) unionsLit.add(endId(l.source));
        }
    const lit = (id: string) => !people || people.has(id) || unionsLit.has(id);

    // A path step between two people goes through their family's union node: parent→union→child, or
    // spouse→union←spouse. Mark both halves of each step.
    pathLinks = new Set();
    const onPath = new Set(path);
    for (let i = 0; i + 1 < path.length; i++) {
        const [a, b] = [path[i], path[i + 1]];
        const touching = (p: string) => links.filter((l) => endId(l.source) === p || endId(l.target) === p);
        for (const la of touching(a)) {
            const ua = la.kind === "spouse" ? endId(la.target) : endId(la.source);
            const lb = touching(b).find((l) => (l.kind === "spouse" ? endId(l.target) : endId(l.source)) === ua);
            if (lb) {
                pathLinks.add(la);
                pathLinks.add(lb);
                break;
            }
        }
    }

    for (const n of nodes as (Node & Bound)[]) {
        setTarget(n.__threeObj, lit(n.id) ? 1 : DIM);
        const sphere = n.__threeObj?.children[0] as
            THREE.Mesh<THREE.BufferGeometry, THREE.MeshStandardMaterial> | undefined;
        if (sphere?.material.emissive) sphere.userData.glow = onPath.has(n.id) && path.length > 1 ? 1 : 0;
    }
    for (const l of links as (Link & Bound)[]) {
        const on = pathLinks.has(l) || (lit(endId(l.source)) && lit(endId(l.target)));
        setTarget(l.__lineObj, on ? 1 : DIM);
        setTarget(l.__photonsObj, on ? 1 : DIM);
        if (l.__lineObj) l.__lineObj.userData.path = pathLinks.has(l) ? 1 : 0;
    }
    siblingPairs.forEach(([a, b], i) => setTarget(siblingLabels[i], lit(a.id) && lit(b.id) ? 1 : DIM));
    siblings.userData.dimTarget = people ? DIM : 1;
}

function setTarget(obj: THREE.Object3D | undefined, dim: number) {
    obj?.traverse((o) => (o.userData.dimTarget = dim));
}

const approach = (cur: number, target: number, k: number) => cur + (target - cur) * k;

// Ease every object's dim (and path glow) towards its target. Meshes and lines get opacity directly; labels keep
// the factor in userData.dim, which fadeLabels() combines with the distance fade.
function stepFades(dt: number) {
    const k = 1 - Math.exp(-FADE_RATE * dt);
    const fadeObject = (root: THREE.Object3D | undefined) =>
        root?.traverse((o) => {
            const target = (o.userData.dimTarget ?? 1) as number;
            const dim = approach((o.userData.dim ?? 1) as number, target, k);
            o.userData.dim = dim;
            // Labels are faded by fadeLabels() / stepNames(), link lines below; everything else (spheres, badges) here.
            if (o instanceof SpriteText || o.userData.isLinkLine) return;
            const m = (o as THREE.Mesh).material as THREE.Material | undefined;
            if (!m) return;
            m.transparent = true;
            m.userData.baseOpacity ??= m.opacity;
            m.opacity = dim * (m.userData.baseOpacity as number);
            if (m instanceof THREE.MeshStandardMaterial) {
                const glow = approach((o.userData.glowNow ?? 0) as number, (o.userData.glow ?? 0) as number, k);
                o.userData.glowNow = glow;
                m.emissive.copy(m.color).multiplyScalar(0.45 * glow); // the path's people light up in their colour
            }
        });
    const { nodes, links } = graph.graphData();
    for (const n of nodes as (Node & Bound)[]) fadeObject(n.__threeObj);
    for (const l of links as (Link & Bound)[]) {
        fadeObject(l.__lineObj);
        fadeObject(l.__photonsObj); // the travelling dots: the library re-uses the template's material for them
        // Path links: brighter (full opacity, gold) and thicker than resting links.
        const line = l.__lineObj?.children[0] as
            THREE.Mesh<THREE.BufferGeometry, THREE.MeshLambertMaterial> | undefined;
        if (!line) continue;
        line.userData.isLinkLine = true;
        const p = approach((line.userData.pathNow ?? 0) as number, (l.__lineObj!.userData.path ?? 0) as number, k);
        line.userData.pathNow = p;
        line.material.opacity = (line.userData.dim ?? 1) * (LINK_OPACITY + (1 - LINK_OPACITY) * p);
        line.material.emissive.set(palette().links.pathGlow).multiplyScalar(0.6 * p);
        line.scale.x = line.scale.y = 1 + 1.6 * p;
    }
    siblingLabels.forEach(fadeObject);
    const sd = approach((siblings.userData.dim ?? 1) as number, (siblings.userData.dimTarget ?? 1) as number, k);
    siblings.userData.dim = sd;
    siblingMat.opacity = sd;
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

// --- Name de-overlap ----------------------------------------------------------------------------------------------
// Names that collide on screen are faded out, keeping the most important one: highlighted people first, then the
// person nearest the camera. Screen boxes are estimated from the projected label width/height. The layout is
// recomputed a few times a second (not every frame); visibility then eases, so names fade rather than pop.
// ponytail: O(n²) box test, fine for the few hundred names a family tree has; use a grid if trees reach thousands.
const NAME_GAP = 4; // px of clearance kept between name boxes
let declutterAt = 0;
const nameShown = new WeakMap<SpriteText, number>(); // target opacity per name (0/1)
function declutter(camera: THREE.PerspectiveCamera, viewW: number, viewH: number, now: number) {
    if (now - declutterAt < quality.labelDeclutterMs) return;
    declutterAt = now;
    type Box = { s: SpriteText; x0: number; x1: number; y0: number; y1: number; prio: number };
    const boxes: Box[] = [];
    const p = new THREE.Vector3();
    const edge = new THREE.Vector3();
    for (const n of graph.graphData().nodes as (Node & Bound)[]) {
        const g = n.__threeObj;
        const s = g?.children.find((c) => c.userData.isName) as SpriteText | undefined;
        if (!s) continue;
        s.getWorldPosition(p);
        const depth = p.distanceTo(camera.position);
        edge.copy(p).project(camera);
        if (edge.z > 1) continue; // behind the camera
        const cx = ((edge.x + 1) / 2) * viewW;
        const cy = ((1 - edge.y) / 2) * viewH;
        // World size of the sprite → pixels at this depth.
        const pxPerUnit = viewH / (2 * depth * Math.tan(THREE.MathUtils.degToRad(camera.fov) / 2));
        const w = s.scale.x * pxPerUnit;
        const h = s.scale.y * pxPerUnit;
        const lit = (g!.userData.dimTarget ?? 1) === 1 && focus !== null;
        boxes.push({
            s,
            x0: cx - w / 2,
            x1: cx + w / 2,
            y0: cy - h / 2,
            y1: cy + h / 2,
            prio: (lit ? 1e6 : 0) - depth,
        });
    }
    boxes.sort((a, b) => b.prio - a.prio);
    const placed: Box[] = [];
    for (const b of boxes) {
        const hit = placed.some(
            (o) => b.x0 < o.x1 + NAME_GAP && b.x1 > o.x0 - NAME_GAP && b.y0 < o.y1 + NAME_GAP && b.y1 > o.y0 - NAME_GAP
        );
        nameShown.set(b.s, hit ? 0 : 1);
        if (!hit) placed.push(b);
    }
}
function stepNames(dt: number) {
    const k = 1 - Math.exp(-12 * dt);
    for (const n of graph.graphData().nodes as (Node & Bound)[]) {
        const s = n.__threeObj?.children.find((c) => c.userData.isName) as SpriteText | undefined;
        if (!s) continue;
        const shown = (s.userData.shown = approach((s.userData.shown ?? 1) as number, nameShown.get(s) ?? 1, k));
        s.material.transparent = true;
        s.material.opacity = shown * ((n.__threeObj!.userData.dim ?? 1) as number);
        s.visible = s.material.opacity > 0.02;
    }
}

// --- "Relative to" tags: a small label above each person saying how they relate to the centre person ------------
export function setRelativeTags(labels: Map<string, string | null> | null): void {
    for (const n of graph.graphData().nodes as (Node & Bound)[]) {
        const tag = n.__threeObj?.children.find((c) => c.userData.isTag) as SpriteText | undefined;
        if (!tag) continue;
        const text = labels?.get(n.id) ?? null;
        tag.visible = !!text;
        if (text && tag.text !== text) tag.text = text;
    }
}

/** Advance the simulation, highlight fades and overlays by one frame. */
export function stepGraph(
    camera: THREE.PerspectiveCamera,
    dt: number,
    now: number,
    viewW: number,
    viewH: number
): void {
    graph.tickFrame();
    stepFlat(dt);
    updateSiblings();
    stepFades(dt);
    fadeLabels(camera);
    declutter(camera, viewW, viewH, now);
    stepNames(dt);
}
