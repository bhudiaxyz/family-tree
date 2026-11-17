// Picking people on the canvas: hover highlights (mouse only), click/tap selects, double tap flies, long press previews.
import * as THREE from "three";
import { drawnZ, graph, isShown, type Node } from "../graph.ts";
import { relate } from "../relationship.ts";
import { camera, renderer } from "../scene.ts";
import { $, relatePanel } from "./dom.ts";
import { setHouse } from "./legend.ts";
import { deselect, select } from "./panel.ts";
import { fillRelate } from "./relate.ts";
import { refreshHighlight, state } from "./state.ts";

const raycaster = new THREE.Raycaster();
const pointer = new THREE.Vector2();
// Who is under the pointer?
//  - Mouse/pen: an exact raycast, nearest sphere wins. A cursor is precise, so "the one in front" is what you meant.
//  - Touch: a fingertip covers ~7 mm and hides what's beneath it, so a raycast often hits a sphere in FRONT of the
//    intended one when people overlap (measured: 2 of 14 taps picked the wrong person on a phone). Instead, pick the
//    person whose on-screen centre is closest to the tap, within a finger-sized radius. Fall back to the raycast.
const FINGER_PX = 28;
function pick(e: PointerEvent | MouseEvent): string | null {
    if ((e as PointerEvent).pointerType === "touch") {
        const id = nearestOnScreen(e.clientX, e.clientY, FINGER_PX);
        if (id) return id;
    }
    pointer.set((e.clientX / innerWidth) * 2 - 1, -(e.clientY / innerHeight) * 2 + 1);
    raycaster.setFromCamera(pointer, camera);
    for (const hit of raycaster.intersectObject(graph, true)) {
        const id = hit.object.userData.personId as string | undefined;
        if (id && hit.object.visible) return id; // the raycaster doesn't skip hidden (focus mode) objects itself
    }
    return null;
}

const projected = new THREE.Vector3();
function nearestOnScreen(x: number, y: number, radius: number): string | null {
    let best: string | null = null;
    let bestD = radius;
    for (const n of graph.graphData().nodes) {
        if (!n.name || n.x === undefined || !isShown(n as Node)) continue;
        projected.set(n.x, n.y!, drawnZ(n.z!)).project(camera);
        if (projected.z > 1) continue; // behind the camera
        const d = Math.hypot(((projected.x + 1) / 2) * innerWidth - x, ((1 - projected.y) / 2) * innerHeight - y);
        if (d < bestD) {
            bestD = d;
            best = n.id;
        }
    }
    return best;
}

// Tap/click handling that works the same for mouse, pen and touch:
//  - A tap counts only if it started on the canvas, used one pointer, and moved less than TAP_SLOP (a finger moves a
//    little even when "still"; 5 px was too tight on phones). A second finger turns it into a pinch, never a tap.
//  - Two taps on the same person within DOUBLE_MS fly to them (dblclick is unreliable on mobile browsers).
//  - Press and hold on a person (touch) previews their line, the touch equivalent of mouse hover.
//  - pointercancel (the browser took over for scrolling/zooming) abandons the tap.
// downAt is cleared after every pointerup, so a click on the panel can never also select whoever is behind it.
const TAP_SLOP = { mouse: 5, pen: 8, touch: 12 } as Record<string, number>;
const DOUBLE_MS = 350;
const HOLD_MS = 450;
const canvas = renderer.domElement;
const active = new Set<number>(); // pointers currently down on the canvas
let downAt: { x: number; y: number; type: string; multi: boolean } | null = null;
let lastTap: { id: string; at: number } | null = null;
let holdTimer = 0;

canvas.addEventListener("pointerdown", (e) => {
    active.add(e.pointerId);
    if (active.size > 1) {
        if (downAt) downAt.multi = true; // pinch/rotate: not a tap
        clearTimeout(holdTimer);
        return;
    }
    downAt = { x: e.clientX, y: e.clientY, type: e.pointerType, multi: false };
    if (e.pointerType !== "mouse") {
        clearTimeout(holdTimer);
        holdTimer = window.setTimeout(() => {
            const id = pick(e);
            if (!id || state.relPair) return;
            state.hovered = id; // long-press preview of this person's line
            refreshHighlight();
            showCard(id, e.clientX, e.clientY);
            navigator.vibrate?.(10);
        }, HOLD_MS);
    }
});
const endPointer = (e: PointerEvent) => {
    active.delete(e.pointerId);
    clearTimeout(holdTimer);
};
canvas.addEventListener("pointercancel", (e) => {
    endPointer(e);
    hideCard();
    downAt = null;
});
canvas.addEventListener("pointerleave", (e) => e.pointerType === "mouse" && hideCard());
addEventListener("pointerup", () => setTimeout(() => (downAt = null)));
canvas.addEventListener("pointermove", (e) => {
    // Moving past the slop cancels the long-press (it's a drag).
    if (downAt && Math.hypot(e.clientX - downAt.x, e.clientY - downAt.y) > TAP_SLOP[downAt.type])
        clearTimeout(holdTimer);
    if (e.pointerType !== "mouse" || e.buttons) return; // hover is mouse-only; touch uses long-press
    const id = pick(e);
    canvas.style.cursor = id ? "pointer" : "";
    if (id) showCard(id, e.clientX, e.clientY);
    else hideCard();
    if (id !== state.hovered) {
        state.hovered = id;
        if (!state.relPair) refreshHighlight(); // hover doesn't disturb a relationship being shown
    }
});
canvas.addEventListener("pointerup", (e) => {
    endPointer(e);
    const start = downAt;
    if (!start || start.multi || active.size) return;
    if (Math.hypot(e.clientX - start.x, e.clientY - start.y) > (TAP_SLOP[start.type] ?? 8)) return;
    // End a touch long-press preview on release.
    if (start.type !== "mouse") hideCard();
    if (start.type !== "mouse" && state.hovered && !state.selected) {
        state.hovered = null;
        refreshHighlight();
    }
    const id = pick(e);
    // With the finder open, taps fill it: the first sets "From" if empty, otherwise "To".
    if (id && !relatePanel.hidden && state.tree) return fillRelate(id);
    const now = performance.now();
    const double = !!id && lastTap?.id === id && now - lastTap.at < DOUBLE_MS;
    lastTap = id ? { id, at: now } : null;
    if (id)
        select(id, double); // a double tap / double click flies to them
    else if (state.selected) deselect();
    else if (state.house) setHouse(null); // clicking empty space also clears a house picked in the legend
});

// --- Hover card: who this is, and how they're related to the selected person ----------------------------------------
// Answers "how is this person related to me?" without switching on tags for the whole tree. Follows the mouse; on
// touch it shows during a long press. The relationship comes from relate(), the same as the finder's headline.
const card = $("hovercard");
let cardFor = "";
function showCard(id: string, x: number, y: number) {
    const { tree, selected } = state;
    if (!tree) return;
    if (cardFor !== id) {
        cardFor = id;
        const p = tree.people[id];
        const rel = selected && selected !== id ? relate(tree, id, selected) : null;
        const name = Object.assign(document.createElement("strong"), { textContent: p.name });
        const house = Object.assign(document.createElement("span"), { className: "card-house", textContent: p.house });
        house.style.color = tree.houseColors[p.house] ?? "";
        const parts: (string | globalThis.Node)[] = [name, house];
        if (rel?.label) {
            const how = document.createElement("span");
            how.className = "card-rel";
            how.textContent = `${rel.label} of ${tree.people[selected!].name}`;
            parts.push(how);
        } else if (selected && selected !== id) {
            // No short name for it (a distant or in-law connection): say so plainly, the finder has the full chain.
            const how = document.createElement("span");
            how.className = "card-rel";
            how.textContent = rel
                ? `related to ${tree.people[selected].name} (see "How are they related?")`
                : `not related to ${tree.people[selected].name}`;
            parts.push(how);
        }
        card.replaceChildren(...parts);
    }
    card.hidden = false;
    // Beside the pointer, flipped to stay on screen; above a finger so it isn't hidden under it.
    const touch = state.hovered === id && downAt?.type === "touch";
    const w = card.offsetWidth;
    const h = card.offsetHeight;
    const left = x + 16 + w > innerWidth ? x - 16 - w : x + 16;
    const top = touch ? y - h - 40 : y + 16 + h > innerHeight ? y - 16 - h : y + 16;
    card.style.transform = `translate(${Math.max(4, left)}px, ${Math.max(4, top)}px)`;
}
function hideCard() {
    card.hidden = true;
    cardFor = "";
}
/** Refresh the card's text after the selection changes (its relationship is to the selected person). */
export const resetCard = () => (cardFor = "");
