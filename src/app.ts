// The 3D app, loaded by main.ts once WebGL is known to work: starts the UI, handles GPU context loss, and runs the
// frame loop. The UI features live in src/ui/ (state, panel, relate, search, files, input, picking, sagas); rendering
// in scene.ts / graph.ts, camera behaviour in camera.ts, and the logic in family.ts, relationship.ts and data/.
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
let lastPrint = "";
function fingerprint(): string {
    const c = camera.position;
    const t = controls.target;
    const nodes = graph.graphData().nodes;
    // One decimal place: positions span hundreds of units, and OrbitControls damping / auto-fit easing converge
    // asymptotically (measured 0.008 units/s at rest), so finer rounding kept waking the loop for invisible motion.
    let s = `${c.x.toFixed(1)},${c.y.toFixed(1)},${c.z.toFixed(1)},${t.x.toFixed(1)},${t.y.toFixed(1)},${t.z.toFixed(1)}`;
    // A stride through the nodes is enough to see the layout still settling; checking all of them isn't needed.
    for (let i = 0; i < nodes.length; i += Math.max(1, nodes.length >> 3)) s += `|${nodes[i].x?.toFixed(1)}`;
    return s;
}

let last = 0;
let lastDrawn = 0;
renderer.setAnimationLoop((now) => {
    const dt = last ? Math.min((now - last) / 1000, 0.1) : 1 / 60; // seconds; clamped so a backgrounded tab can't jump
    last = now;
    if (paused) return;
    const print = fingerprint();
    if (print !== lastPrint) {
        lastPrint = print;
        wake();
    }
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
