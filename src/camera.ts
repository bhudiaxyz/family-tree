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

/** Hand the camera to the user: stop auto-fit and any fly-to. */
export function takeCamera(): void {
    autoFit = false;
    flight = null;
}
controls.addEventListener("start", takeCamera);

/** Ease back to the whole tree (after loading a saga, deselecting, or the pad's fit button). */
export function fitTree(): void {
    flight = null;
    autoFit = true;
}

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
function stepFit(bbox: Bbox, dt: number) {
    const { x, y, z } = bbox;
    const center = new THREE.Vector3((x[0] + x[1]) / 2, (y[0] + y[1]) / 2, (z[0] + z[1]) / 2);
    const tanHalf = Math.tan(THREE.MathUtils.degToRad(camera.fov) / 2);
    const portrait = camera.aspect < 1;
    const fitH = (y[1] - y[0]) / 2 / tanHalf;
    const fitW = (x[1] - x[0]) / 2 / (tanHalf * camera.aspect);
    const dist = Math.max(fitH * (portrait ? 1.12 : 1), fitW) * FIT_MARGIN;
    // Nudge the target down a touch so the header and toolbar overlay don't cover the top generation.
    center.y += (y[1] - y[0]) * 0.04;
    const k = ease(6, dt);
    controls.target.lerp(center, k);
    camera.position.lerp(center.clone().add(new THREE.Vector3(0, 0, dist)), k);
}

const FLY_SECONDS = 1;
const FLY_DISTANCE = 90;
function stepFlight(dt: number) {
    if (!flight) return;
    const { node, dir } = flight;
    flight.t = Math.min(1, flight.t + dt / FLY_SECONDS);
    const k = ease(2.4 + 12 * flight.t ** 2, dt); // gentle start, firm finish
    const target = new THREE.Vector3(node.x, node.y, drawnZ(node.z!)); // as drawn (2D mode squashes z)
    controls.target.lerp(target, k);
    camera.position.lerp(target.clone().addScaledVector(dir, FLY_DISTANCE), k);
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
    const offset = camera.position.clone().sub(controls.target);
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
    const box = autoFit ? bbox() : null;
    if (box) stepFit(box, dt);
    stepFlight(dt);
    stepPan(dt);
    stepFlatView(dt);
    controls.update();
}
