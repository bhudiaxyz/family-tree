// Navigate: getting around a tree.
//
// What it does: frames the selected person's family (`fitFamily`), zooms by steps (`zoomIn`, `zoomOut`), moves a
// generation at a time (`goToGeneration`, `stepGeneration`), keeps pinned people (`pinned`, `togglePin`,
// `onPinsChanged`) and remembers the view per saga (`rememberView`, `restoreView`).
// Usage: input.ts (keys, touch pad), panel.ts (fit, pins), sagas.ts (views, pin list). The camera moves themselves
// are in camera.ts.
// Notes: pins are stored per saga in localStorage ("ft.pins.<saga>") and filtered to people still in the tree. The
// remembered views are kept in memory only, so a fresh visit or shared link starts from the whole tree. Clicking a
// generation row in the scene calls goToGeneration (via onRowPicked, registered at import time).

import * as THREE from "three";
import { fitPeople, glideTo, setViewInsets, viewState, zoomBy } from "../camera.ts";
import { immediateFamily } from "../family.ts";
import { generationRows, nodeById, onRowPicked } from "../graph.ts";
import { camera, controls } from "../scene.ts";
import { panel, relatePanel } from "./dom.ts";
import { state } from "./state.ts";

// --- Fit the family: the selected person with their parents, siblings, spouses and children -------------------------
export function fitFamily(): void {
    if (!state.selected || !state.tree) return;
    fitPeople(immediateFamily(state.tree, state.selected).flatMap((id) => nodeById(id) ?? []));
}

// --- Zoom by steps (the pad's ± and the + / - keys) --------------------------------------------------------------
const ZOOM_STEP = 1.35;
export const zoomIn = () => zoomBy(1 / ZOOM_STEP);
export const zoomOut = () => zoomBy(ZOOM_STEP);

// --- A generation at a time --------------------------------------------------------------------------------------
const aim = new THREE.Vector3();
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
onRowPicked(goToGeneration);

// --- Pinned people: a short list per saga, kept on this device ---------------------------------------------------
const PIN_KEY = (saga: string) => `ft.pins.${saga}`;
const listeners = new Set<() => void>();
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

// --- Remember the view per saga, for this visit ----------------------------------------------------------------------
// Switching to another saga and back returns to where you were, instead of the whole-tree view. Kept in memory only:
// a fresh visit (or a shared link) should start from the whole tree.
const views = new Map<string, { target: THREE.Vector3; dist: number; dir: THREE.Vector3 }>();
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

// --- Keep camera fits clear of the overlays ------------------------------------------------------------------------
// The header and toolbar cover the top of the view, and the details panel or finder the bottom, so framing the whole
// visible area put Ancestors' oldest rows under the toolbar and Descendants' youngest behind the panel. Measure what's
// covered and tell the camera. A full-width panel (phones) covers the bottom outright; a desktop card in the lower
// left counts for a third of its height, enough to lift the youngest row clear of it.
const header = document.querySelector("header");
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
    setViewInsets(top + 8, bottom ? bottom + 8 : 0);
}
const watch = new ResizeObserver(measureInsets);
for (const el of [header, panel, relatePanel]) if (el) watch.observe(el);
addEventListener("resize", measureInsets);
// Showing or hiding a panel doesn't resize it in a way ResizeObserver reports from 0, so watch `hidden` as well.
new MutationObserver(measureInsets).observe(panel, { attributes: true, attributeFilter: ["hidden"] });
new MutationObserver(measureInsets).observe(relatePanel, { attributes: true, attributeFilter: ["hidden"] });
measureInsets();
