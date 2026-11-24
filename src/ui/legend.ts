// Legend: the house legend, shown as a "Houses" folder in the menu.
//
// What it does: lists each house with its colour and number of people (`setLegend`, `mountLegend`). Click a house to
// light it up, again to frame it (`frameHouse`), a third time to clear it; `setHouse` highlights or clears one.
// Usage: sagas.ts mounts and rebuilds it; input.ts, picking.ts and sagas.ts call setHouse.
// Notes: selecting a person clears the house (panel.ts), and picking a house deselects the person. setHouse sets
// state.house, clears state.group, calls refreshHighlight and writes ?house= (only once a tree is up). `framed`
// remembers that the lit house has been framed so the next click clears it. Escape and a click on empty space also
// clear it, and a "Show all houses" button is shown while one is picked. Styled by #legend-list in style.css.

import type GUI from "lil-gui";
import type { Tree } from "../data/schema.ts";
import { fitPeople } from "../render/camera.ts";
import { nodeById } from "../graph/graph.ts";
import { palette } from "../render/palettes.ts";
import { deselect } from "./panel.ts";
import { el, refreshHighlight, state, writeUrl } from "./state.ts";

const list = el("ul", { id: "legend-list" });
let framed = false; // the lit house has been framed (its second click), so the next click clears it

/** Put the legend in a collapsed "Houses" folder of the menu. */
export function mountLegend(gui: GUI): void {
    const folder = gui.addFolder("Houses").close();
    folder.$children.append(list);
}

/** Rebuild the legend for a tree: houses by size, largest first. */
export function setLegend(tree: Tree): void {
    const count = new Map<string, number>();
    for (const p of Object.values(tree.people)) count.set(p.house, (count.get(p.house) ?? 0) + 1);
    const houses = [...count].sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0]));
    // Shown only while a house is picked: the obvious way back (Escape and clicking empty space also clear it).
    const all = document.createElement("li");
    all.className = "legend-clear";
    const clear = el("button", { textContent: "✕ Show all houses" });
    clear.onclick = () => setHouse(null);
    all.append(clear);
    list.replaceChildren(
        all,
        ...houses.map(([house, n]) => {
            const li = document.createElement("li");
            const b = document.createElement("button");
            b.dataset.house = house;
            b.setAttribute("aria-pressed", "false");
            const swatch = el("span", { className: "swatch" });
            swatch.style.background = tree.houseColors[house] ?? palette().unknownHouse;
            const name = el("span", { className: "house", textContent: house });
            const size = el("span", { className: "n", textContent: String(n) });
            b.append(swatch, name, size);
            // First click lights the house; a second frames it (all its members in view); a third clears it.
            b.onclick = () => {
                if (state.selected && state.house !== house) deselect(); // a house view replaces a person's line
                if (state.house !== house) return setHouse(house);
                if (!framed) return frameHouse(house);
                setHouse(null);
            };
            b.title = "Click to light up this house, again to frame it, a third time to clear";
            li.append(b);
            return li;
        })
    );
    setHouse(null);
}

/** Bring every member of a house into view. */
export function frameHouse(house: string): void {
    const tree = state.tree;
    if (!tree) return;
    framed = true;
    fitPeople(
        Object.keys(tree.people)
            .filter((id) => tree.people[id].house === house)
            .flatMap((id) => nodeById(id) ?? [])
    );
}

/** Highlight one house (null clears it). A selected person's line takes over again when they're selected. */
export function setHouse(house: string | null): void {
    framed = false;
    state.house = house;
    state.group = null;
    for (const b of list.querySelectorAll<HTMLButtonElement>("button[data-house]"))
        b.setAttribute("aria-pressed", String(b.dataset.house === house));
    list.classList.toggle("has-house", !!house);
    refreshHighlight();
    if (state.tree) writeUrl(); // ?house= (only once a tree is up: setLegend clears it while a saga is being shown)
}

list.setAttribute("aria-label", "Houses");
