// Camera behaviour on top of OrbitControls: auto-fit to the tree, fly-to a person, glides, and held-direction pan.
//
// What it does: keeps module-level state for auto-fit (whole tree or a group), a timed flight to a node, a glide to a
// fixed target and distance, held pan directions, and a 2D mode that eases the view face-on. stepCamera() advances all.
// Usage: app.ts calls stepCamera() each frame and setReducedMotion(); ui/ calls fitTree, fitPeople, flyTo, glideTo,
// zoomBy, viewState, holdPan / releasePan / releaseAllPans, nudgeRotate, setFlatView and takeCamera.
// Notes: the user always wins: any OrbitControls "start" event, arrow key or pad press calls takeCamera(), which
// cancels auto-fit, flight and glide. Motion is frame-rate independent: easing is 1 - exp(-rate * dt) and panning
// scales with dt. Fit uses width and height only, not depth: fitting the front face of the house planes' parallax
// spread zoomed the first view far too far out. Scratch vectors are reused to avoid per-frame garbage on phones.

import * as THREE from "three";
import { camera, controls } from "./scene.ts";
import { drawnZ } from "./graph.ts";

type Pos = { x?: number; y?: number; z?: number };
type Bbox = { x: [number, number]; y: [number, number]; z: [number, number] };

/** Fraction to close per frame so a lerp converges at `rate` per second regardless of frame time. */
const ease = (rate: number, dt: number) => (reducedMotion ? 1 : 1 - Math.exp(-rate * dt));

// prefers-reduced-motion: camera moves (fit, fly-to) jump straight to their end instead of animating.
let reducedMotion = false;
export const setReducedMotion = (on: boolean) => {
    reducedMotion = on;
    controls.enableDamping = !on;
};

let autoFit = true;
let flight: { node: Pos; dir: THREE.Vector3; t: number } | null = null;
// What auto-fit frames: the whole tree (null), or a group of people (fitPeople), followed live while the layout moves.
let fitGroup: Pos[] | null = null;
// A camera glide to a fixed target and distance (glideTo): generation steps, the minimap, a restored view.
let glide: { target: THREE.Vector3; dist: number } | null = null;

/** Hand the camera to the user: stop auto-fit, any fly-to or glide. */
export function takeCamera(): void {
    autoFit = false;
    flight = null;
    glide = null;
}
controls.addEventListener("start", takeCamera);

/**
 * Ease back to the whole tree (after loading a saga, deselecting, or the pad's fit button). With `top`, a tree much
 * taller than the screen (the Bible's 78 rows) is framed by its width from the oldest rows down, rather than shrunk
 * to a sliver; Page Down then walks down it. Only a fresh load asks for that; F and ◯ still show everything.
 */
export function fitTree(top = false): void {
    flight = null;
    glide = null;
    fitGroup = null;
    fitTop = top;
    autoFit = true;
}
let fitTop = false;

/** Ease to frame just these people (a person and their immediate family), keeping the current viewing angle. */
export function fitPeople(nodes: Pos[]): void {
    const placed = nodes.filter((n) => n.x !== undefined);
    if (!placed.length) return;
    flight = null;
    glide = null;
    fitGroup = placed;
    autoFit = true;
}

/** Glide the orbit target to `target`, `dist` away (or at the current distance), keeping the viewing angle. */
export function glideTo(target: THREE.Vector3, dist = camera.position.distanceTo(controls.target)): void {
    autoFit = false;
    flight = null;
    glide = { target: target.clone(), dist };
}

/** Zoom in (factor < 1) or out (factor > 1) by a step, towards the orbit target; for the pad's ± and the keyboard. */
export function zoomBy(factor: number): void {
    const cur = camera.position.distanceTo(controls.target);
    const next = THREE.MathUtils.clamp(cur * factor, controls.minDistance || 8, Math.min(controls.maxDistance, 4000));
    glideTo(controls.target, next);
}

/** Where the camera is looking and from how far: for remembering a saga's view and the minimap. */
export const viewState = () => ({ target: controls.target.clone(), dist: camera.position.distanceTo(controls.target) });

/** Fly to a node, following its live position (the layout may still be settling) for about a second. */
export function flyTo(node: Pos): void {
    if (node.x === undefined) return;
    autoFit = false;
    flight = { node, dir: camera.position.clone().sub(controls.target).normalize(), t: 0 };
}

// Fits the people's width and height to the view, measured to the box centre. Depth is left out on purpose: the house
// planes spread people front to back for parallax, and fitting the front face (as before) pushed the camera back by
// that whole depth, so the first view was far too zoomed out. Near people may now sit slightly past the frame edge
// in perspective, which reads as closer and more immersive; the 5–95% box (peopleBbox) already trims stragglers.
//
// The fit is into the part of the screen that isn't covered: the header and toolbar take the top, and the details
// panel (or, on phones, the finder) the bottom. Without that, Ancestors put the oldest rows under the toolbar and
// Descendants put the youngest behind the panel. The UI reports those insets with setViewInsets().
const FIT_MARGIN = 1.08; // breathing room around what's framed, so the outer rows aren't on the very edge
let insetTop = 0; // px of the view covered at the top (header) and bottom (panel), set by the UI
let insetBottom = 0;
/** Tell the camera how much of the view is covered by overlays, top and bottom (CSS px), so fits avoid them. */
export function setViewInsets(top: number, bottom: number): void {
    insetTop = Math.max(0, top);
    insetBottom = Math.max(0, bottom);
}
// Scratch vectors, reused every frame: allocating new ones per frame made garbage-collection pauses on phones.
const center = new THREE.Vector3();
const goal = new THREE.Vector3();
const offset = new THREE.Vector3();
const TALL = 2; // a tree needing over twice the distance for its height as for its width counts as tall...
const TALL_MIN_H = 660; // ...and is then framed at least this high (six rows of 110), from its top
const NAME_LINE = 4; // world units per line of a name label (labels.ts)
const FIRST_NAME_PX = 10; // a saga's first view is never so far out that a name line is under this many px
function stepFit(bbox: Bbox, dt: number, top: boolean) {
    const { x, y, z } = bbox;
    center.set((x[0] + x[1]) / 2, (y[0] + y[1]) / 2, (z[0] + z[1]) / 2);
    const tanHalf = Math.tan(THREE.MathUtils.degToRad(camera.fov) / 2);
    const viewH = Math.max(1, innerHeight);
    // The free band, as a fraction of the view height. On a phone the panel really does cover the bottom ~45%, so fit
    // into what's left (a floor of a quarter keeps a near-full-screen overlay from pushing the camera absurdly far).
    const free = Math.max(0.25, (viewH - insetTop - insetBottom) / viewH);
    const fitH = (y[1] - y[0]) / 2 / (tanHalf * free);
    const fitW = (x[1] - x[0]) / 2 / (tanHalf * camera.aspect);
    let dist = Math.max(fitH, fitW) * FIT_MARGIN;
    if (top && fitH > TALL * fitW) {
        // Tall: fit the width (or six rows, if narrower still) and put the oldest row at the top of the free band.
        // Never further out than the plain fit: a short narrow tree (Dune's 5 rows) counts as tall, and six rows
        // there were taller than the whole tree, which zoomed most sagas' first view out instead of in.
        dist = Math.min(dist, Math.max(fitW, TALL_MIN_H / 2 / (tanHalf * free)) * FIT_MARGIN);
        center.y = y[1] - dist * tanHalf * free;
    }
    if (top && dist > (viewH * NAME_LINE) / (2 * tanHalf * FIRST_NAME_PX)) {
        // A saga's first view opens close enough to read names (most whole-tree fits left them 5–6 px tall). If the
        // tree doesn't fit at that zoom, start from its oldest rows, centred sideways; F shows the whole tree.
        dist = (viewH * NAME_LINE) / (2 * tanHalf * FIRST_NAME_PX);
        const half = dist * tanHalf * free; // half the free band's height, in world units
        if ((y[1] - y[0]) / 2 > half) center.y = y[1] - half;
    }
    // Centre the box in the free band, not the whole view: move the target by the band's offset from the view centre.
    // At distance `dist` the view spans 2·dist·tanHalf world units vertically; the band's centre sits
    // (insetBottom - insetTop) / 2 px above the view's centre.
    const unitsPerPx = (2 * dist * tanHalf) / viewH;
    center.y -= ((insetBottom - insetTop) / 2) * unitsPerPx;
    const k = ease(6, dt);
    controls.target.lerp(center, k);
    camera.position.lerp(goal.copy(center).setZ(center.z + dist), k);
}

// The box around a group of people, padded like peopleBbox() for names above and badges below.
function groupBox(nodes: Pos[]): Bbox {
    const xs = nodes.map((n) => n.x!);
    const ys = nodes.map((n) => n.y!);
    const zs = nodes.map((n) => drawnZ(n.z!));
    const pad = (v: number[], lo: number, hi: number): [number, number] => [Math.min(...v) - lo, Math.max(...v) + hi];
    // At least a little width and height, so a single person or a couple isn't framed absurdly close.
    const x = pad(xs, 30, 30);
    const y = pad(ys, 25, 30);
    return { x, y, z: [Math.min(...zs), Math.max(...zs)] };
}

const offsetDir = new THREE.Vector3();
function stepGlide(dt: number) {
    if (!glide) return;
    const k = ease(6, dt);
    offsetDir.subVectors(camera.position, controls.target).normalize();
    controls.target.lerp(glide.target, k);
    camera.position.lerp(goal.copy(glide.target).addScaledVector(offsetDir, glide.dist), k);
    if (
        controls.target.distanceTo(glide.target) < 0.05 &&
        Math.abs(camera.position.distanceTo(controls.target) - glide.dist) < 0.05
    )
        glide = null;
}

const FLY_SECONDS = 1;
const FLY_DISTANCE = 90;
function stepFlight(dt: number) {
    if (!flight) return;
    const { node, dir } = flight;
    flight.t = Math.min(1, flight.t + dt / FLY_SECONDS);
    const k = ease(2.4 + 12 * flight.t ** 2, dt); // gentle start, firm finish
    center.set(node.x!, node.y!, drawnZ(node.z!)); // as drawn (2D mode squashes z)
    controls.target.lerp(center, k);
    camera.position.lerp(goal.copy(center).addScaledVector(dir, FLY_DISTANCE), k);
    if (flight.t === 1) flight = null;
}

// --- Held-direction panning (arrow keys and the touch pad share this) ----------------------------------------------
export type Dir = "left" | "right" | "up" | "down";
const held = new Set<Dir>();
const PAN_PX_PER_SECOND = 540;
const PAN: Record<Dir, [number, number]> = { left: [1, 0], right: [-1, 0], up: [0, 1], down: [0, -1] };

export const holdPan = (dir: Dir) => (takeCamera(), held.add(dir));
export const releasePan = (dir: Dir) => held.delete(dir);
export const releaseAllPans = () => held.clear();

function stepPan(dt: number) {
    if (!held.size) return;
    let dx = 0;
    let dy = 0;
    for (const d of held) {
        dx += PAN[d][0];
        dy += PAN[d][1];
    }
    controls.pan(dx * PAN_PX_PER_SECOND * dt, dy * PAN_PX_PER_SECOND * dt);
}

// --- 2D mode: no rotation; left drag / one finger pans; the camera eases round to face the tree head-on -----------
let flat = false;
export function setFlatView(on: boolean): void {
    flat = on;
    controls.enableRotate = !on;
    controls.mouseButtons.LEFT = on ? THREE.MOUSE.PAN : THREE.MOUSE.ROTATE;
    controls.touches.ONE = on ? THREE.TOUCH.PAN : THREE.TOUCH.ROTATE;
}
const FRONT = new THREE.Vector3(0, 0, 1);
function stepFlatView(dt: number) {
    if (!flat) return;
    offset.subVectors(camera.position, controls.target);
    const dist = offset.length();
    offset.normalize().lerp(FRONT, ease(5, dt)).normalize();
    camera.position.copy(controls.target).addScaledVector(offset, dist);
}

/** Rotate around the target in a small step (Shift/Ctrl/Cmd + arrow), as OrbitControls' own key handler does. */
export function nudgeRotate(dir: Dir): void {
    if (flat) return;
    takeCamera();
    const angle = 0.05 * (dir === "left" || dir === "up" ? 1 : -1);
    const offset = camera.position.clone().sub(controls.target);
    const axis =
        dir === "left" || dir === "right" ? camera.up : new THREE.Vector3().crossVectors(camera.up, offset).normalize();
    camera.position.copy(controls.target).add(offset.applyAxisAngle(axis, angle));
}

/** Advance all camera behaviour by one frame. `bbox` is only read while auto-fitting. */
export function stepCamera(dt: number, bbox: () => Bbox | null): void {
    const box = autoFit ? (fitGroup ? groupBox(fitGroup) : bbox()) : null;
    // A box with a NaN in it (a node not yet placed) would put the camera at NaN, and it never recovers: skip it.
    if (box && [...box.x, ...box.y, ...box.z].every(Number.isFinite)) stepFit(box, dt, fitTop && !fitGroup);
    stepFlight(dt);
    stepGlide(dt);
    stepPan(dt);
    stepFlatView(dt);
    controls.update();
}
