// App wiring: starts the UI, handles GPU context loss, and runs the throttled frame loop.
//
// What it does: adds the graph to the scene, applies prefers-reduced-motion to the camera, calls start() from
// ui/sagas.ts, pauses on ft:contextlost and rebuilds on ft:contextrestored, then drives renderer.setAnimationLoop.
// Usage: loaded only by main.ts via dynamic import; exports nothing. UI features live in src/ui/, rendering in
// scene.ts / graph.ts, camera behaviour in camera.ts, logic in family.ts, relationship.ts and data/.
// Notes: the loop skips whole frames (no simulation, no draw) once nothing has changed for IDLE_AFTER ms, down to
// quality.idleFps. "Changed" is a fingerprint of camera, orbit target and a stride of node positions, rounded to one
// decimal (damping converges asymptotically, so finer rounding never settled). The feature modules imported only
// for side effects (search, input, picking) attach their own listeners. window.__ft is a dev-only test hook.

import { quality } from "./device.ts";
import { setReducedMotion, stepCamera } from "./camera.ts";
import { graph, peopleBbox, stepGraph } from "./graph.ts";
import { camera, controls, draw, renderer, scene, updateFog } from "./scene.ts";
import { notify } from "./ui/state.ts";
import { rebuildAfterContextLoss, start } from "./ui/sagas.ts";
// Feature modules that only attach event listeners.
import "./ui/search.ts";
import "./ui/input.ts";
import "./ui/picking.ts";
import { stepMinimap } from "./ui/minimap.ts";

scene.add(graph);

const prefersReduced = matchMedia("(prefers-reduced-motion: reduce)");
setReducedMotion(prefersReduced.matches);
prefersReduced.addEventListener("change", () => setReducedMotion(prefersReduced.matches));

start();

// --- GPU context loss: pause, tell the user, and resume when the browser restores it ------------------------------
let paused = false;
addEventListener("ft:contextlost", () => {
    paused = true;
    notify("The graphics context was lost; trying to restore it…", true);
});
addEventListener("ft:contextrestored", () => {
    paused = false;
    rebuildAfterContextLoss(); // textures, materials, the cached badges and the baked sky all died with the context
    notify("Graphics restored.");
});

// --- Frame loop -----------------------------------------------------------------------------------------------------
// Dev-only hook for browser tests to read camera and node state; stripped from production builds.
if (import.meta.env.DEV) Object.assign(window, { __ft: { camera, controls, graph, scene, renderer } });

// IDLE THROTTLING (battery). A settled tree that nobody is touching was redrawn 60 times a second for nothing, the
// biggest single drain on phones and laptops. Each frame compares a cheap fingerprint of everything that can move
// (camera, orbit target, and a sample of node positions); while it changes, or for IDLE_AFTER ms after any input,
// frames run at full rate. Once still, frames are skipped down to quality.idleFps (link particles keep moving, just
// slower). Any pointer, key, wheel or resize wakes it at once. Comparing real state rather than trusting "moving"
// flags means a forgotten flag can never freeze the view: the worst case is rendering a little more than needed.
const IDLE_AFTER = 600; // ms of stillness before throttling
let lastActive = performance.now();
const wake = () => (lastActive = performance.now());
for (const ev of ["pointerdown", "pointermove", "wheel", "keydown", "resize", "touchstart"])
    addEventListener(ev, wake, { passive: true });
// The fingerprint is kept as numbers (rounded to one decimal) rather than a string, so the check allocates nothing
// per frame. One decimal place: positions span hundreds of units, and OrbitControls damping / auto-fit easing converge
// asymptotically (measured 0.008 units/s at rest), so finer rounding kept waking the loop for invisible motion.
const SAMPLES = 9; // camera + target (6) and a stride through the nodes (up to 9): enough to see the layout settling
const print = new Float64Array(6 + SAMPLES);
const round1 = (v: number | undefined) => Math.round((v ?? 0) * 10);
/** Update the fingerprint of everything that can move; true if it changed since the last frame. */
function changed(): boolean {
    const c = camera.position;
    const t = controls.target;
    const nodes = graph.graphData().nodes;
    const stride = Math.max(1, Math.ceil(nodes.length / SAMPLES));
    let diff = false;
    for (let j = 0; j < print.length; j++) {
        const v = j < 6 ? round1([c.x, c.y, c.z, t.x, t.y, t.z][j]) : round1(nodes[(j - 6) * stride]?.x);
        if (print[j] !== v) {
            print[j] = v;
            diff = true;
        }
    }
    return diff;
}

let last = 0;
let lastDrawn = 0;
renderer.setAnimationLoop((now) => {
    const dt = last ? Math.min((now - last) / 1000, 0.1) : 1 / 60; // seconds; clamped so a backgrounded tab can't jump
    last = now;
    if (paused) return;
    if (changed()) wake();
    const idle = now - lastActive > IDLE_AFTER;
    if (idle && now - lastDrawn < 1000 / quality.idleFps) return; // skip this frame entirely: no simulation, no draw
    const step = idle ? Math.min((now - lastDrawn) / 1000, 0.1) : dt;
    lastDrawn = now;
    stepGraph(camera, controls.target, step, now, innerWidth, innerHeight);
    stepMinimap();
    stepCamera(step, peopleBbox);
    updateFog();
    draw();
});
