// Navigate: getting around a tree.
//
// What it does: frames the selected person's family (`fitFamily`), zooms by steps (`zoomIn`, `zoomOut`), moves a
// generation at a time (`goToGeneration`, `stepGeneration`), keeps pinned people (`pinned`, `togglePin`,
// `onPinsChanged`), remembers the view per saga (`rememberView`, `restoreView`) and points to the selected person
// when they're off screen (`stepOffscreen`).
// Usage: input.ts (keys, touch pad), panel.ts (fit, pins), sagas.ts (views, pin list), main.ts (stepOffscreen each
// frame). The camera moves themselves are in camera.ts.
// Notes: pins are stored per saga in localStorage ("ft.pins.<saga>") and filtered to people still in the tree. The
// remembered views are kept in memory only, so a fresh visit or shared link starts from the whole tree. Clicking a
// generation row in the scene calls goToGeneration (via onRowPicked, registered at import time).

import * as THREE from "three";
import { fitPeople, glideTo, setViewInsets, viewState, zoomBy } from "../render/camera.ts";
import { immediateFamily } from "../tree/family.ts";
import { drawnZ, generationRows, nodeById, onRowPicked } from "../graph/graph.ts";
import { camera, controls } from "../render/scene.ts";
import { $, flyToPerson, panel, relatePanel, state } from "./state.ts";

// --- Zoom by steps (the pad's ± and the + / - keys) --------------------------------------------------------------
const ZOOM_STEP = 1.35;

// --- A generation at a time --------------------------------------------------------------------------------------
const aim = new THREE.Vector3();

const listeners = new Set<() => void>();

// --- Remember the view per saga, for this visit ----------------------------------------------------------------------
// Switching to another saga and back returns to where you were, instead of the whole-tree view. Kept in memory only:
// a fresh visit (or a shared link) should start from the whole tree.
const views = new Map<string, { target: THREE.Vector3; dist: number; dir: THREE.Vector3 }>();

// --- Keep camera fits clear of the overlays ------------------------------------------------------------------------
// The header and toolbar cover the top of the view, and the details panel or finder the bottom, so framing the whole
// visible area put Ancestors' oldest rows under the toolbar and Descendants' youngest behind the panel. Measure what's
// covered and tell the camera. A full-width panel (phones) covers the bottom outright; a desktop card in the lower
// left counts for a third of its height, enough to lift the youngest row clear of it.
const header = document.querySelector("header");

let coverTop = 0; // the insets in CSS px, also kept for the off-screen pointer
let coverBottom = 0;
const watch = new ResizeObserver(measureInsets);

// --- Off-screen pointer: when the selected person is out of view, a chip at the screen edge points to them --------
// On a big tree (the Bible's 78 rows) it's easy to pan away and lose whoever you were looking at. Click it to fly
// back. Called every drawn frame by main.ts; it only touches the DOM when what it shows changes.
const offscreen = $<HTMLButtonElement>("offscreen");

const offArrow = offscreen.querySelector<HTMLElement>(".arrow")!;
const offName = offscreen.querySelector<HTMLElement>(".name")!;
const proj = new THREE.Vector3();
const EDGE = 0.92; // inside this much of the view (in NDC) counts as on screen
let shownAt = "";

// --- Fit the family: the selected person with their parents, siblings, spouses and children -------------------------
export function fitFamily(): void {
    if (!state.selected || !state.tree) return;
    fitPeople(immediateFamily(state.tree, state.selected).flatMap((id) => nodeById(id) ?? []));
}

export const zoomIn = () => zoomBy(1 / ZOOM_STEP);
export const zoomOut = () => zoomBy(ZOOM_STEP);

/** Glide so the given generation row is in the middle of the view, keeping the current sideways position. */
export function goToGeneration(row: number): void {
    const rows = generationRows();
    if (!rows.length) return;
    const g = THREE.MathUtils.clamp(row, 0, rows.length - 1);
    glideTo(aim.copy(controls.target).setY(rows[g]));
}

/** The generation row nearest the middle of the view. */
function currentGeneration(): number {
    const rows = generationRows();
    let best = 0;
    rows.forEach((y, g) => Math.abs(y - controls.target.y) < Math.abs(rows[best] - controls.target.y) && (best = g));
    return best;
}

/** Step the view one generation up (older, -1) or down (younger, +1). */
export const stepGeneration = (by: -1 | 1) => goToGeneration(currentGeneration() + by);

// --- Pinned people: a short list per saga, kept on this device ---------------------------------------------------
const PIN_KEY = (saga: string) => `ft.pins.${saga}`;

export function pinned(): string[] {
    if (!state.tree) return [];
    try {
        const ids = JSON.parse(localStorage.getItem(PIN_KEY(state.sagaId)) ?? "[]") as string[];
        return ids.filter((id) => state.tree!.people[id]); // drop anyone no longer in the saga
    } catch {
        return [];
    }
}

export const isPinned = (id: string) => pinned().includes(id);

export function togglePin(id: string): void {
    const ids = pinned();
    const next = ids.includes(id) ? ids.filter((x) => x !== id) : [...ids, id];
    localStorage.setItem(PIN_KEY(state.sagaId), JSON.stringify(next));
    for (const fn of listeners) fn();
}

/** Run `fn` whenever the pins change (the menu's list and the panel's star redraw). */
export const onPinsChanged = (fn: () => void) => listeners.add(fn);

export function rememberView(saga: string): void {
    if (!saga) return;
    const { target, dist } = viewState();
    views.set(saga, { target, dist, dir: camera.position.clone().sub(controls.target).normalize() });
}

/** Restore a remembered view for this saga; false if there isn't one (the caller then fits the whole tree). */
export function restoreView(saga: string): boolean {
    const v = views.get(saga);
    if (!v) return false;
    camera.position.copy(v.target).addScaledVector(v.dir, v.dist);
    glideTo(v.target, v.dist);
    return true;
}

function measureInsets(): void {
    const top = header?.getBoundingClientRect().bottom ?? 0;
    let bottom = 0;
    for (const el of [panel, relatePanel]) {
        if (el.hidden) continue;
        const r = el.getBoundingClientRect();
        const covered = innerHeight - r.top;
        // Full width (phones): the panel really covers the bottom. A desktop card in a corner: keep the lowest row a
        // little above it, without shrinking the view by the card's whole height.
        bottom = Math.max(bottom, r.width > innerWidth / 3 ? covered : covered / 3);
    }
    coverTop = top + 8;
    coverBottom = bottom ? bottom + 8 : 0;
    setViewInsets(coverTop, coverBottom);
}

export function stepOffscreen(): void {
    const node = state.selected ? nodeById(state.selected) : undefined;
    if (!node || node.x === undefined) return hideOffscreen();
    proj.set(node.x, node.y!, drawnZ(node.z!)).project(camera);
    // Behind the camera the projection comes out mirrored: flip it so the arrow still points the right way.
    const behind = proj.z > 1;
    const [x, y] = behind ? [-proj.x, -proj.y] : [proj.x, proj.y];
    if (!behind && Math.abs(x) < EDGE && Math.abs(y) < EDGE) return hideOffscreen();
    // Push the direction out to the edge of the view, then keep the chip inside it and clear of the header and panel.
    const s = 1 / Math.max(Math.abs(x), Math.abs(y), 1e-6);
    const w = offscreen.offsetWidth || 120;
    const h = offscreen.offsetHeight || 28;
    const left = THREE.MathUtils.clamp(((x * s + 1) / 2) * innerWidth - w / 2, 8, innerWidth - w - 8);
    const top = THREE.MathUtils.clamp(
        ((1 - y * s) / 2) * innerHeight - h / 2,
        coverTop,
        innerHeight - coverBottom - h - 8
    );
    const angle = Math.atan2(-y, x); // screen y runs down
    const name = state.tree!.people[state.selected!].name;
    const at = `${Math.round(left)},${Math.round(top)},${angle.toFixed(2)},${name}`;
    if (at === shownAt) return;
    shownAt = at;
    offName.textContent = name;
    offscreen.title = `${name} is off screen: fly back to them`;
    offArrow.style.transform = `rotate(${angle}rad)`;
    offscreen.style.transform = `translate(${Math.round(left)}px, ${Math.round(top)}px)`;
    offscreen.hidden = false;
}

function hideOffscreen(): void {
    if (offscreen.hidden) return;
    offscreen.hidden = true;
    shownAt = "";
}

onRowPicked(goToGeneration);
for (const el of [header, panel, relatePanel]) if (el) watch.observe(el);
addEventListener("resize", measureInsets);

// Showing or hiding a panel doesn't resize it in a way ResizeObserver reports from 0, so watch `hidden` as well.
new MutationObserver(measureInsets).observe(panel, { attributes: true, attributeFilter: ["hidden"] });

new MutationObserver(measureInsets).observe(relatePanel, { attributes: true, attributeFilter: ["hidden"] });
measureInsets();
offscreen.onclick = () => state.selected && flyToPerson(state.selected);
