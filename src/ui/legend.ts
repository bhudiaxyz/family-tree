// House legend, shown as a "Houses" folder in the menu: each house's colour and number of people. Click one to light
// up the whole house, again to frame it, and a third time to clear it: shows how intermarried families spread.
import type GUI from "lil-gui";
import type { Tree } from "../data/schema.ts";
import { fitPeople } from "../camera.ts";
import { nodeById } from "../graph.ts";
import { deselect } from "./panel.ts";
import { refreshHighlight, state } from "./state.ts";
import { writeUrl } from "./url.ts";

const list = Object.assign(document.createElement("ul"), { id: "legend-list" });
list.setAttribute("aria-label", "Houses");

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
    const clear = Object.assign(document.createElement("button"), { textContent: "✕ Show all houses" });
    clear.onclick = () => setHouse(null);
    all.append(clear);
    list.replaceChildren(
        all,
        ...houses.map(([house, n]) => {
            const li = document.createElement("li");
            const b = document.createElement("button");
            b.dataset.house = house;
            b.setAttribute("aria-pressed", "false");
            const swatch = Object.assign(document.createElement("span"), { className: "swatch" });
            swatch.style.background = tree.houseColors[house] ?? "#888";
            const name = Object.assign(document.createElement("span"), { className: "house", textContent: house });
            const size = Object.assign(document.createElement("span"), { className: "n", textContent: String(n) });
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

let framed = false; // the lit house has been framed (its second click), so the next click clears it

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
