// What the app is showing, shared by the UI modules: the tree, who is selected or hovered, the relationship shown.
// Plain data plus the few helpers every feature needs (highlight, toast, links to people, fly-to).
import { flyTo } from "../camera.ts";
import type { Tree } from "../data/schema.ts";
import { type LineRole, lineageRoles, siblingsOf } from "../family.ts";
import { highlight, nodeById } from "../graph.ts";
import { relate } from "../relationship.ts";
import { $ } from "./dom.ts";

export const IMPORTED = "imported"; // saga id used in the URL / GUI for a GEDCOM file loaded from disk

/** Focus mode: show only the highlighted line ("all"), or just one side of it; "off" dims the rest instead. */
export type Focus = "off" | "all" | "ancestors" | "descendants" | "siblings";

export const state = {
    tree: null as Tree | null,
    sagaId: "",
    selected: null as string | null,
    hovered: null as string | null,
    relPair: null as [string, string] | null, // the relationship currently shown, if any
    relStep: null as [string, string] | null, // the finder step being hovered, if any
    house: null as string | null, // a house picked in the legend, highlighted on its own
    focus: "off" as Focus,
    focusDepth: 0, // generations up and down that focus mode shows; 0 = all
    view2d: false, // ?view=2d|3d, 3d by default
};

// What to light up, in priority order: a relationship path; a house from the legend; the selected (or hovered)
// person's line, with direction and distance so ancestors and descendants read apart.
export function refreshHighlight(): void {
    const { tree, relPair, focus } = state;
    if (!tree) return highlight(null);
    const hideOthers = focus !== "off";
    if (relPair) {
        const r = relate(tree, ...relPair);
        const path = r?.path ?? [];
        return highlight(new Set(path.length ? path : relPair), { path, step: state.relStep, hideOthers });
    }
    if (state.house) {
        const house = state.house;
        const ids = Object.keys(tree.people).filter((id) => tree.people[id].house === house);
        return highlight(new Set(ids), { hideOthers });
    }
    const id = state.selected ?? state.hovered;
    if (!id) return highlight(null);
    // Siblings: just the person and their brothers and sisters (they're not in the line, so no depth or side).
    const roles: Map<string, LineRole> =
        focus === "siblings"
            ? new Map([
                  [id, { side: "self", distance: 0 }],
                  ...siblingsOf(tree, id).map((s): [string, LineRole] => [s, { side: "sibling", distance: 0 }]),
              ])
            : lineageRoles(tree, id);
    // Focus on one side: keep that side, the person and their spouses (so the couple at the top/bottom stays whole).
    // Focus depth: keep only people within that many generations (spouses and the person count as distance 0).
    if (focus !== "off" && state.focusDepth > 0)
        for (const [pid, r] of roles) if (r.distance > state.focusDepth) roles.delete(pid);
    if (focus === "ancestors" || focus === "descendants") {
        const side = focus === "ancestors" ? "ancestor" : "descendant";
        for (const [pid, r] of roles)
            if (r.side !== side && r.side !== "self" && r.side !== "spouse") roles.delete(pid);
    }
    highlight(new Set(roles.keys()), { roles, hideOthers: hideOthers && id === state.selected });
}

const toast = $("toast");
let toastTimer = 0;
export function notify(message: string, error = false): void {
    toast.textContent = message;
    toast.classList.toggle("error", error);
    toast.hidden = false;
    clearTimeout(toastTimer);
    toastTimer = window.setTimeout(() => (toast.hidden = true), error ? 6000 : 3000);
}

export function flyToPerson(id: string): void {
    const node = nodeById(id);
    if (node) flyTo(node);
}

/** A link showing a person's name, running `onClick` instead of navigating. */
export function personLink(id: string, onClick: () => void): HTMLAnchorElement {
    const a = Object.assign(document.createElement("a"), { href: "#", textContent: state.tree!.people[id].name });
    a.onclick = (e) => {
        e.preventDefault();
        onClick();
    };
    return a;
}
