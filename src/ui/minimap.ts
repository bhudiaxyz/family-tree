// Minimap: the whole tree in a corner, with a frame showing the part on screen.
//
// What it does: draws a dot per person in their house colour, the highlight, and the view's footprint; click or drag
// on it to move the view there (`stepMinimap` draws, `setMinimap`/`toggleMinimap` show or hide, remembered in
// localStorage "ft.minimap").
// Usage: app.ts calls stepMinimap() every frame; input.ts calls toggleMinimap (M).
// Notes: drawn in 2D from the front, not as a second 3D render; it only redraws when a fingerprint of the view, layout
// or highlight changes. The shape follows the tree (landscape for wide, portrait for tall) and frames the 2nd to 98th
// percentile sideways so one outlier can't squash the tree. Clicks clamp to the tree's extent. The elements are
// created here and appended to <body>; see #minimap in style.css.

import * as THREE from "three";
import { glideTo } from "../camera.ts";
import { graph, isShown, layoutRunning, type Node } from "../graph.ts";
import { palette } from "../palettes.ts";
import { camera, controls } from "../scene.ts";
import { state } from "./state.ts";
import { el } from "./dom.ts";

// The map's shape follows the tree's: landscape for a wide tree, portrait for a tall one (the Bible is 78 rows by a
// handful of people), about the same area either way. Set per saga in fit().
let W = 168;
let H = 120;
const SHAPES = { wide: [168, 120], tall: [110, 190] } as const;
const PAD = 8;
const wrap = el("div", { id: "minimap" });
const canvas = document.createElement("canvas"); // drawn at 2× for sharpness (see resize)
canvas.setAttribute("role", "img");
canvas.setAttribute("aria-label", "Overview of the whole tree; click to move the view there");
const toggle = el("button", { id: "minimap-toggle", textContent: "▣" });
toggle.title = "Show or hide the overview map (M)";
toggle.setAttribute("aria-pressed", "true");
wrap.append(canvas);
document.body.append(wrap, toggle);
const g = canvas.getContext("2d")!;
function resize(w: number, h: number) {
    if (w === W && h === H && canvas.width) return;
    W = w;
    H = h;
    canvas.width = W * 2;
    canvas.height = H * 2;
    canvas.style.width = wrap.style.width = `${W}px`;
    canvas.style.height = wrap.style.height = `${H}px`;
    document.documentElement.style.setProperty("--map-h", `${H}px`); // the toggle sits just above the map
    g.setTransform(2, 0, 0, 2, 0, 0);
}
resize(SHAPES.wide[0], SHAPES.wide[1]);

let last = ""; // fingerprint of the last drawn state (see stepMinimap); declared before setMinimap runs below
let on = localStorage.getItem("ft.minimap") !== "false";
export function setMinimap(show: boolean): void {
    on = show;
    wrap.hidden = !show;
    toggle.setAttribute("aria-pressed", String(show));
    localStorage.setItem("ft.minimap", String(show));
    last = "";
}
export const toggleMinimap = () => setMinimap(!on);
toggle.onclick = toggleMinimap;
setMinimap(on);

// World → map: fit the people's x/y extent into the canvas, keeping proportions.
let box = { x0: 0, x1: 1, y0: 0, y1: 1, s: 1, ox: 0, oy: 0 };
// Frame the 2nd–98th percentile sideways, like the camera's fit: one outlier (the Bible's Mariam, who has no relatives
// and drifts off on her own) would otherwise squash the whole tree into a sliver. Every generation is kept.
function fit(nodes: Node[]) {
    const pct = (v: number[], q: number) => v[Math.min(v.length - 1, Math.max(0, Math.round(q * (v.length - 1))))];
    const xs = nodes.map((n) => n.x!).sort((a, b) => a - b);
    const ys = nodes.map((n) => n.y!);
    const x0 = pct(xs, 0.02);
    const x1 = pct(xs, 0.98);
    const y0 = Math.min(...ys);
    const y1 = Math.max(...ys);
    const [w, h] = (y1 - y0) / Math.max(1, x1 - x0) > 1.6 ? SHAPES.tall : SHAPES.wide;
    resize(w, h);
    const s = Math.min((W - 2 * PAD) / Math.max(1, x1 - x0), (H - 2 * PAD) / Math.max(1, y1 - y0));
    box = { x0, x1, y0, y1, s, ox: (W - (x1 - x0) * s) / 2, oy: (H - (y1 - y0) * s) / 2 };
}
const toMap = (x: number, y: number) => [box.ox + (x - box.x0) * box.s, box.oy + (box.y1 - y) * box.s] as const;
const toWorld = (mx: number, my: number) => [box.x0 + (mx - box.ox) / box.s, box.y1 - (my - box.oy) / box.s] as const;

// The view's footprint on the tree's plane (z = 0 is close enough for an overview): where the screen corners land.
const ray = new THREE.Raycaster();
const plane = new THREE.Plane(new THREE.Vector3(0, 0, 1), 0);
const hit = new THREE.Vector3();
const ndc = new THREE.Vector2();
function footprint(): [number, number][] {
    const pts: [number, number][] = [];
    for (const [x, y] of [
        [-1, -1],
        [1, -1],
        [1, 1],
        [-1, 1],
    ]) {
        ray.setFromCamera(ndc.set(x, y), camera);
        if (ray.ray.intersectPlane(plane, hit)) pts.push([hit.x, hit.y]);
    }
    return pts;
}

/** Redraw if anything visible changed; called from the frame loop. */
// A still camera over a settled layout with the same highlight needs no redraw: check that cheaply first, before
// filtering the nodes and building the full key (which allocated every frame).
const lastCam = new THREE.Vector3(Infinity, 0, 0);
const lastTarget = new THREE.Vector3();
let lastState = "";
export function stepMinimap(): void {
    if (!on || !state.tree) return;
    const quickState = `${state.selected}|${state.house}|${state.focus}|${state.group?.label}`;
    if (
        !layoutRunning &&
        camera.position.equals(lastCam) &&
        controls.target.equals(lastTarget) &&
        quickState === lastState
    )
        return;
    lastCam.copy(camera.position);
    lastTarget.copy(controls.target);
    lastState = quickState;
    const nodes = graph.graphData().nodes.filter((n) => n.name && n.x !== undefined) as Node[];
    if (!nodes.length) return;
    // Cheap change check, like the frame loop's idle test: camera, target, a sample of nodes, and the selection.
    const c = camera.position;
    const t = controls.target;
    let key = `${c.x.toFixed(0)},${c.y.toFixed(0)},${c.z.toFixed(0)},${t.x.toFixed(0)},${t.y.toFixed(0)}|${state.selected}|${state.house}|${state.focus}`;
    for (let i = 0; i < nodes.length; i += Math.max(1, nodes.length >> 3)) key += `|${nodes[i].x!.toFixed(0)}`;
    if (key === last) return;
    last = key;
    fit(nodes);
    g.clearRect(0, 0, W, H);
    const colours = state.tree.houseColors;
    for (const n of nodes) {
        if (n.x! < box.x0 - 1 || n.x! > box.x1 + 1) continue; // an outlier beyond the framed width
        const shown = isShown(n);
        const [x, y] = toMap(n.x!, n.y!);
        g.globalAlpha = shown ? 0.9 : 0.2;
        g.fillStyle = colours[n.house!] ?? palette().unknownHouse;
        g.fillRect(x - 1.25, y - 1.25, 2.5, 2.5);
    }
    // The selected person, ringed, so you can find them on a big tree.
    const sel = state.selected && nodes.find((n) => n.id === state.selected);
    if (sel) {
        const [x, y] = toMap(sel.x!, sel.y!);
        g.globalAlpha = 1;
        g.strokeStyle = palette().minimap.selected;
        g.lineWidth = 1.5;
        g.beginPath();
        g.arc(x, y, 4, 0, Math.PI * 2);
        g.stroke();
    }
    // The part of the tree on screen.
    const fp = footprint();
    if (fp.length === 4) {
        g.globalAlpha = 1;
        g.strokeStyle = palette().minimap.view;
        g.lineWidth = 1;
        g.beginPath();
        fp.forEach(([wx, wy], i) => {
            const [x, y] = toMap(wx, wy);
            if (i) g.lineTo(x, y);
            else g.moveTo(x, y);
        });
        g.closePath();
        g.stroke();
    }
}

// Click or drag: move the view's centre to that point of the tree, at the current distance.
const aim = new THREE.Vector3();
// Clamped to the tree's extent: a click in the map's empty margin moves to the nearest edge of the tree, never off
// into empty space.
function moveTo(e: PointerEvent) {
    const r = canvas.getBoundingClientRect();
    const [x, y] = toWorld(((e.clientX - r.left) / r.width) * W, ((e.clientY - r.top) / r.height) * H);
    glideTo(
        aim.set(THREE.MathUtils.clamp(x, box.x0, box.x1), THREE.MathUtils.clamp(y, box.y0, box.y1), controls.target.z)
    );
}
canvas.addEventListener("pointerdown", (e) => {
    canvas.setPointerCapture(e.pointerId);
    moveTo(e);
});
canvas.addEventListener("pointermove", (e) => e.buttons && moveTo(e));
