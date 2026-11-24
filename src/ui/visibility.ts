// Visibility: what is shown of the tree around the selected person, and the panel controls for it.
//
// What it does: focus mode (only their line, one side, siblings or cousins, optionally a few generations deep:
// `setFocus`, `showDepths`) and collapsed branches (descendants folded away, a "+ N" tag left: `toggleCollapse`,
// `showCollapse`, `refreshFolds`).
// Usage: panel.ts and input.ts call setFocus/showCollapse/showDepths; sagas.ts calls refreshFolds and setFocus("off").
// Notes: both only change state (focus, focusDepth, collapsed) and the tags; refreshHighlight (state.ts) turns that
// into what is hidden, so the two combine freely (a branch can be collapsed while in Line focus). Attaches its button
// handlers at import time (a side-effect module, loaded through panel.ts); the .panel-focus buttons, #panel-depth and
// #panel-collapse must exist in index.html. Depths that would show nobody new are greyed out.

import { fitTree } from "../render/camera.ts";
import type { Tree } from "../data/schema.ts";
import { cousinsOf, descendantsOf, type LineRole, lineageRoles, siblingsOf } from "../tree/family.ts";
import { setFoldBadges } from "../graph/graph.ts";
import { $, type Focus, notify, refreshHighlight, state } from "./state.ts";

// --- Focus mode -----------------------------------------------------------------------------------------------------
const focusButtons = [...document.querySelectorAll<HTMLButtonElement>(".panel-focus button")];

// The one-sided focus modes: who each shows, and how to say so when there's nobody.
const SIDE: Partial<Record<Focus, { word: string; find: (tree: Tree, id: string) => string[] }>> = {
    ancestors: { word: "ancestors", find: (t, id) => onSide(t, id, "ancestor") },
    descendants: { word: "descendants", find: (t, id) => onSide(t, id, "descendant") },
    siblings: { word: "brothers or sisters", find: siblingsOf },
    cousins: { word: "first cousins", find: cousinsOf },
};

// --- Focus depth: how many generations up and down focus mode shows ---------------------------------------------------
const depthSelect = $<HTMLSelectElement>("panel-depth");

// --- Collapsed branches ---------------------------------------------------------------------------------------------
const btnCollapse = $<HTMLButtonElement>("panel-collapse");

const onSide = (tree: Tree, id: string, side: LineRole["side"]) =>
    [...lineageRoles(tree, id)].filter(([, r]) => r.side === side).map(([p]) => p);

export function setFocus(f: Focus): void {
    state.focus = f;
    // Say so when a focus mode finds nobody, rather than leave the person alone on screen.
    const side = SIDE[f];
    const { tree, selected } = state;
    if (side && tree && selected && !side.find(tree, selected).length)
        notify(`${tree.people[selected].name} has no ${side.word} recorded in this tree.`);
    for (const b of focusButtons) b.setAttribute("aria-checked", String(b.dataset.focus === f));
    refreshHighlight();
    fitTree(); // frame what's shown: the line on its own, or the whole tree again
}

// Grey out the depths that would show nobody new: Eddard's line runs only one generation each way, so 1, 2, 3 and
// all show the same 9 people, and the menu looked broken. The tooltip says how far this person's line reaches.
export function showDepths(id: string) {
    const reach = Math.max(0, ...[...lineageRoles(state.tree!, id).values()].map((r) => r.distance));
    for (const o of depthSelect.options) {
        const d = Number(o.value);
        o.disabled = d > 0 && d > reach && d !== state.focusDepth; // keep the current choice selectable
    }
    depthSelect.title = reach
        ? `This line reaches ${reach} generation${reach === 1 ? "" : "s"} up or down; choose how many to show`
        : "No recorded parents or children";
}

/** The panel's Collapse / Expand button for this person (hidden for anyone with no descendants). */
export function showCollapse(id: string) {
    const n = descendantsOf(state.tree!, id).size;
    btnCollapse.hidden = !n;
    const on = state.collapsed.has(id);
    btnCollapse.setAttribute("aria-pressed", String(on));
    btnCollapse.textContent = on ? `Expand branch (${n})` : "Collapse branch";
}

/** Fold or unfold a person's descendants. */
export function toggleCollapse(id: string): void {
    if (state.collapsed.has(id)) state.collapsed.delete(id);
    else state.collapsed.add(id);
    refreshFolds();
    if (state.selected) showCollapse(state.selected);
}

/** Redraw the "+ N" tags and the hidden branches (after a toggle, or a new tree). */
export function refreshFolds(): void {
    const tree = state.tree;
    const badges = new Map<string, string>();
    if (tree) for (const c of state.collapsed) if (tree.people[c]) badges.set(c, `+ ${descendantsOf(tree, c).size}`);
    setFoldBadges(badges);
    refreshHighlight();
}

// The four side buttons (Ancestors, Descendants, Siblings, Cousins) toggle: pressing the one that's on turns focus off.
// Off and Line are plain choices (L toggles the line from the keyboard).
for (const b of focusButtons)
    b.onclick = () => {
        const f = b.dataset.focus as Focus;
        setFocus(f === state.focus && b.classList.contains("key") ? "off" : f);
    };

depthSelect.onchange = () => {
    state.focusDepth = Number(depthSelect.value);
    if (state.focus === "off")
        setFocus("all"); // choosing a depth means you want to focus
    else (refreshHighlight(), fitTree());
};

btnCollapse.onclick = () => state.selected && toggleCollapse(state.selected);
