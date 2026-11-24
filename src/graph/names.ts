// Names: label visibility, i.e. distance fade, name de-overlap, and the "relative to" tags above each person.
//
// What it does: fadeLabels() fades relationship labels with camera distance; declutter() hides names that collide on
// screen, keeping highlighted people and then the nearest, and grows highlighted names that would be too small to
// read (userData.baseScale is a name's resting size); stepNames() eases name size, name and tag opacity each frame;
// setRelativeTags() and setFoldBadges() set the small tag text above a person (a fold badge wins).
// Usage: all called from graph.ts (stepGraph) and re-exported for the UI.
// Notes: declutter runs only every quality.labelDeclutterMs, then visibility eases so names fade rather than pop; its
// box test uses a screen grid (near-linear). fadeLabels and stepNames skip work that hasn't changed (a still camera,
// settled fades, names already at their target), so a settled view costs almost nothing here. Text outside a highlight fades faster than spheres (textDim
// squares the dim), and all of these combine with highlight.ts's userData.dim, so run them after stepFades.

import * as THREE from "three";
import SpriteText from "three-spritetext";
import { quality } from "../render/device.ts";
import { boundLinks, boundNodes, layoutRunning, NAME_Y, nameOf, TAG_Y } from "./core.ts";
import { approach } from "./graph-types.ts";
import { fadesSettled, focus } from "./highlight.ts";
import { siblingLabels } from "./siblings.ts";

type Box = {
    s: SpriteText;
    x0: number;
    x1: number;
    y0: number;
    y1: number;
    prio: number;
    grow: number;
    cx: number;
    cy: number;
    w: number;
    h: number;
};

// Relationship labels are fully visible within LABEL_NEAR of the camera and hidden beyond LABEL_FAR. The whole-tree
// view of a typical saga is ~300–450 units away, so these keep the labels on at that zoom and only drop them when
// zoomed well out, where they'd be too small to read anyway. (It was 110–240: they only appeared once zoomed in.)
const LABEL_NEAR = 220;

const LABEL_FAR = 480;

// --- Distance fade ----------------------------------------------------------------------------------------------
const tmp = new THREE.Vector3();

// Relationship labels fade out with distance; those on the highlighted line stay readable at any distance. The result
// only depends on the camera position and each label's dim, so when neither changed since the last pass there's
// nothing to do (a settled, still view would otherwise walk every link label each frame).
const lastCam = new THREE.Vector3(Infinity, 0, 0);

const MIN_LABEL_PX = 7; // relationship labels shorter than this on screen fade out (fully under 5 px)
const TAN_HALF_FOV = Math.tan(THREE.MathUtils.degToRad(50) / 2); // scene.ts's camera is 50°

// Names are always shown for anyone on screen: a person faded behind a highlight keeps their name at NAME_FLOOR
// (other text fades with textDim), scaled down smoothly to nothing only as the person is hidden altogether (focus
// mode, a collapsed branch), so they never pop.
const NAME_FLOOR = 0.35;

const FADED = 0.06; // the dim a selection fades the rest to (ui/state.ts); the floor is full from here up
const NEAR_FROM = 60; // world units from the camera: a faded name's floor is smallest (FLOOR_NEAR) here...
const NEAR_TO = 240; // ...and full from here
const FLOOR_NEAR = 0.3;

// --- Name de-overlap ----------------------------------------------------------------------------------------------
// Names never disappear. Where two collide on screen, the more important keeps full strength (highlighted people
// first, then the person nearest the camera) and the other is drawn at COLLIDED, still readable but clearly behind.
// Screen boxes are estimated from the projected label width/height. The layout is recomputed a few times a second
// (not every frame); opacity then eases, so names fade rather than pop.
// Placed boxes go in a coarse screen grid, so each name is tested only against boxes in the cells it overlaps rather
// than every name placed so far (that was O(n²): ~170k comparisons for the Bible's 583 names, several times a second).
const NAME_GAP = 4; // px of clearance kept between name boxes

const COLLIDED = 0.4; // strength of a name overlapped by a more important one
const MIN_NAME_PX = 20; // a lit name (two lines) is grown to at least this many px tall, if it has room...
const MAX_GROW = 2.5; // ...but never past this many times its own size
const CELL = 96; // px; about the width of a typical name at the whole-tree zoom
let declutterAt = 0;
const nameShown = new WeakMap<SpriteText, number>(); // target strength per name (1 or COLLIDED)
const p = new THREE.Vector3();
const edge = new THREE.Vector3();

// --- "Relative to" tags: a small label above each person saying how they relate to the centre person ------------
// The same tag shows "+ 42" over a person whose branch is collapsed; that wins over a relationship word.
let relative: Map<string, string | null> | null = null;

let foldBadges = new Map<string, string>();

// Text outside a highlight fades further than the spheres: a faint sphere still shows the tree's shape, but faint
// text is only clutter around the line you're reading. Squaring the dim factor leaves lit labels (1) as they are and
// takes a 12% dim to ~1.5% and a 6% one to ~0.4%. Within a line (dims of 0.55–1 by distance) labels stay readable.
const textDim = (dim: number) => (dim < 0.5 ? dim * dim : dim);

export function fadeLabels(camera: THREE.Camera): void {
    if (!layoutRunning && fadesSettled() && camera.position.equals(lastCam)) return;
    lastCam.copy(camera.position);
    const fade = (s: SpriteText) => {
        const dim = (s.userData.dim ?? 1) as number;
        // The world matrix was updated by last frame's render; reading it avoids getWorldPosition(), which walks up and
        // recomputes every parent's matrix for each label (a few hundred labels × every frame while orbiting).
        const d = camera.position.distanceTo(tmp.setFromMatrixPosition(s.matrixWorld));
        const near = focus !== null && dim === 1 ? 1 : (LABEL_FAR - d) / (LABEL_FAR - LABEL_NEAR);
        s.material.transparent = true;
        // Too small to read (under ~5 px tall, e.g. "son" at the whole-tree zoom) is only a smudge: fade it out by 7 px.
        const px = (s.scale.y * innerHeight) / (2 * d * TAN_HALF_FOV);
        const readable = THREE.MathUtils.smoothstep(px, MIN_LABEL_PX - 2, MIN_LABEL_PX);
        s.material.opacity = textDim(dim) * THREE.MathUtils.clamp(near, 0, 1) * readable;
        s.visible = s.material.opacity > 0.02;
    };
    for (const l of boundLinks()) {
        const label = l.__lineObj?.children[1];
        if (label instanceof SpriteText) fade(label);
    }
    siblingLabels.forEach(fade);
}

// `near` (0–1, from declutter) scales the floor down for faded people close to the camera: their names are big, and
// at the full floor they shouted over the line you're reading (Bellatrix and Rosier, in front of the Weasleys).
const nameDim = (dim: number, near = 1) => Math.max(textDim(dim), NAME_FLOOR * near * Math.min(1, dim / FADED));

export function declutter(camera: THREE.PerspectiveCamera, viewW: number, viewH: number, now: number): void {
    if (now - declutterAt < quality.labelDeclutterMs) return;
    declutterAt = now;
    const boxes: Box[] = [];
    for (const n of boundNodes()) {
        const s = nameOf(n);
        if (!s) continue;
        s.userData.growTarget = 1;
        const target = (n.__threeObj!.userData.dimTarget ?? 1) as number;
        if (nameDim(target) < 0.02) continue; // hidden: doesn't take up room
        p.setFromMatrixPosition(s.matrixWorld); // updated by the last render; avoids recomputing every parent
        const depth = p.distanceTo(camera.position);
        s.userData.near = THREE.MathUtils.clamp((depth - NEAR_FROM) / (NEAR_TO - NEAR_FROM), FLOOR_NEAR, 1);
        edge.copy(p).project(camera);
        if (edge.z > 1) continue; // behind the camera
        const cx = ((edge.x + 1) / 2) * viewW;
        const cy = ((1 - edge.y) / 2) * viewH;
        // World size of the sprite → pixels at this depth.
        const pxPerUnit = viewH / (2 * depth * Math.tan(THREE.MathUtils.degToRad(camera.fov) / 2));
        const lit = focus !== null && focus.has(n.id); // in the highlighted line (its dim may be < 1 by distance)
        // Names in the highlighted line keep a readable size when zoomed out: grown (up to MAX_GROW) so they're at
        // least MIN_NAME_PX tall, but only where the grown name has room (tested below). Everyone else: world size.
        const base = (s.userData.baseScale ??= s.scale.clone()) as THREE.Vector3;
        const grow = lit ? THREE.MathUtils.clamp(MIN_NAME_PX / (base.y * pxPerUnit), 1, MAX_GROW) : 1;
        const w = base.x * pxPerUnit;
        const h = base.y * pxPerUnit;
        boxes.push({ s, cx, cy, w, h, grow, x0: 0, x1: 0, y0: 0, y1: 0, prio: (lit ? 1e6 : 0) - depth });
    }
    // The box at a given size (it grows upwards from the name's base, like growName does).
    const size = (b: Box, g: number) => {
        b.x0 = b.cx - (b.w * g) / 2;
        b.x1 = b.cx + (b.w * g) / 2;
        b.y1 = b.cy + b.h / 2;
        b.y0 = b.y1 - b.h * g;
        return b;
    };
    boxes.sort((a, b) => b.prio - a.prio);
    const grid = new Map<number, Box[]>();
    const cells = (b: Box) => {
        const out: number[] = [];
        const cx0 = Math.floor((b.x0 - NAME_GAP) / CELL);
        const cx1 = Math.floor((b.x1 + NAME_GAP) / CELL);
        const cy0 = Math.floor((b.y0 - NAME_GAP) / CELL);
        const cy1 = Math.floor((b.y1 + NAME_GAP) / CELL);
        for (let cx = cx0; cx <= cx1; cx++) for (let cy = cy0; cy <= cy1; cy++) out.push(cx * 100003 + cy);
        return out;
    };
    const overlaps = (b: Box, o: Box) =>
        b.x0 < o.x1 + NAME_GAP && b.x1 > o.x0 - NAME_GAP && b.y0 < o.y1 + NAME_GAP && b.y1 > o.y0 - NAME_GAP;
    const hits = (b: Box) => cells(b).some((c) => grid.get(c)?.some((o) => overlaps(b, o)));
    for (const b of boxes) {
        // Grown if that fits, else at its own size; if even that overlaps a stronger name, drawn behind it.
        let grow = b.grow;
        if (grow > 1 && hits(size(b, grow))) grow = 1;
        const hit = hits(size(b, grow));
        b.s.userData.growTarget = grow;
        nameShown.set(b.s, hit ? COLLIDED : 1);
        if (!hit) for (const c of cells(b)) (grid.get(c) ?? grid.set(c, []).get(c)!).push(b);
    }
}

export function stepNames(dt: number): void {
    const k = 1 - Math.exp(-12 * dt);
    for (const n of boundNodes()) {
        const s = nameOf(n);
        if (!s) continue;
        growName(s, k);
        const want = nameShown.get(s) ?? 1;
        const dim = (n.__threeObj!.userData.dim ?? 1) as number;
        // Skip a name that's already where it should be (most of them, once the view has settled).
        const near = (s.userData.near ?? 1) as number;
        if (s.userData.shown === want && s.userData.lastDim === dim && s.userData.lastNear === near) continue;
        const shown = approach((s.userData.shown ?? 1) as number, want, k);
        s.userData.shown = Math.abs(shown - want) < 0.002 ? want : shown;
        s.userData.lastDim = dim;
        s.userData.lastNear = near;
        s.material.transparent = true;
        s.material.opacity = (s.userData.shown as number) * nameDim(dim, near);
        s.visible = s.material.opacity > 0.02;
        // "Relative to" tags fade with their person too (focus mode hides them with the person).
        const tag = tagOf(n.__threeObj!);
        if (tag?.userData.text) {
            tag.material.transparent = true;
            tag.material.opacity = textDim(dim);
            tag.visible = tag.material.opacity > 0.02;
        }
    }
}

/** Ease a name towards the size declutter() chose, lifting it so it stays clear of the sphere as it grows. */
function growName(s: SpriteText, k: number): void {
    const want = (s.userData.growTarget ?? 1) as number;
    const now = (s.userData.growNow ?? 1) as number;
    if (now === want) return;
    const next = approach(now, want, k);
    const g = Math.abs(next - want) < 0.005 ? want : next;
    s.userData.growNow = g;
    const base = s.userData.baseScale as THREE.Vector3;
    s.scale.copy(base).multiplyScalar(g);
    s.position.y = NAME_Y + ((g - 1) * base.y) / 2;
    s.updateMatrix(); // names don't update their matrix automatically (core.ts freezes them)
    const tag = s.parent && tagOf(s.parent);
    if (tag) tag.position.y = TAG_Y + (g - 1) * base.y; // keep the tag above the grown name
}

/** The tag sprite above a person, cached on their object (looked up every frame otherwise). */
function tagOf(obj: THREE.Object3D): SpriteText | undefined {
    return (obj.userData.tagSprite ??= obj.children.find((c) => c.userData.isTag)) as SpriteText | undefined;
}

export function setRelativeTags(labels: Map<string, string | null> | null): void {
    relative = labels;
    drawTags();
}

export function setFoldBadges(badges: Map<string, string>): void {
    foldBadges = badges;
    drawTags();
}

function drawTags(): void {
    for (const n of boundNodes()) {
        const tag = n.__threeObj && tagOf(n.__threeObj);
        if (!tag) continue;
        const text = foldBadges.get(n.id) ?? relative?.get(n.id) ?? null;
        tag.userData.text = text; // stepNames() shows it (faded with its person) only while it has text
        const name = nameOf(n);
        if (name) delete name.userData.lastDim; // make stepNames() revisit this person's tag
        tag.visible = !!text;
        if (text && tag.text !== text) tag.text = text;
    }
}
