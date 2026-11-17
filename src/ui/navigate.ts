// Getting around a tree: framing the selected person's family, zooming without a wheel, stepping a generation at a
// time, pinned people, and coming back to where you were in a saga. The keys and buttons that call these are in
// input.ts and the panel; the camera moves themselves are in camera.ts.
import * as THREE from "three";
import { fitPeople, glideTo, viewState, zoomBy } from "../camera.ts";
import { immediateFamily } from "../family.ts";
import { generationRows, nodeById, onRowPicked } from "../graph.ts";
import { camera, controls } from "../scene.ts";
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
function goToGeneration(row: number): void {
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
