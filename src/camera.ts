// Camera behaviour on top of OrbitControls: auto-fit to the whole tree, fly-to a person, and held-direction panning.
// Three modes, and the user always wins: any drag/zoom, arrow key or pad press cancels auto-fit and fly-to.
//
// Motion is frame-rate independent: easing uses 1 - exp(-rate·dt) and panning scales with dt, so a 120 Hz screen
// behaves like a 60 Hz one.
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

/** Ease back to the whole tree (after loading a saga, deselecting, or the pad's fit button). */
export function fitTree(): void {
    flight = null;
    glide = null;
    fitGroup = null;
    autoFit = true;
}

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
// On a portrait phone the width is the constraint; the header takes the top of the screen, so leave a little room.
const FIT_MARGIN = 1.02;
// Scratch vectors, reused every frame: allocating new ones per frame made garbage-collection pauses on phones.
const center = new THREE.Vector3();
const goal = new THREE.Vector3();
const offset = new THREE.Vector3();
function stepFit(bbox: Bbox, dt: number) {
    const { x, y, z } = bbox;
    center.set((x[0] + x[1]) / 2, (y[0] + y[1]) / 2, (z[0] + z[1]) / 2);
    const tanHalf = Math.tan(THREE.MathUtils.degToRad(camera.fov) / 2);
    const portrait = camera.aspect < 1;
    const fitH = (y[1] - y[0]) / 2 / tanHalf;
    const fitW = (x[1] - x[0]) / 2 / (tanHalf * camera.aspect);
    const dist = Math.max(fitH * (portrait ? 1.12 : 1), fitW) * FIT_MARGIN;
    // Nudge the target down a touch so the header and toolbar overlay don't cover the top generation.
    center.y += (y[1] - y[0]) * 0.04;
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
    if (box) stepFit(box, dt);
    stepFlight(dt);
    stepGlide(dt);
    stepPan(dt);
    stepFlatView(dt);
    controls.update();
}
