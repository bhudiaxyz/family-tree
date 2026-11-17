// What the app is showing, shared by the UI modules: the tree, who is selected or hovered, the relationship shown.
// Plain data plus the few helpers every feature needs (highlight, toast, links to people, fly-to).
import { flyTo } from "../camera.ts";
import type { Tree } from "../data/schema.ts";
import { lineage } from "../family.ts";
import { highlight, nodeById } from "../graph.ts";
import { relate } from "../relationship.ts";
import { $ } from "./dom.ts";

export const IMPORTED = "imported"; // saga id used in the URL / GUI for a GEDCOM file loaded from disk

export const state = {
    tree: null as Tree | null,
    sagaId: "",
    selected: null as string | null,
    hovered: null as string | null,
    relPair: null as [string, string] | null, // the relationship currently shown, if any
    view2d: false, // ?view=2d|3d, 3d by default
};

// What to light up: a relationship path takes priority; otherwise the selected/hovered person's line.
export function refreshHighlight(): void {
    const { tree, relPair } = state;
    if (!tree) return highlight(null);
    if (relPair) {
        const r = relate(tree, ...relPair);
        return highlight(r ? new Set(r.path) : new Set(relPair), r?.path ?? []);
    }
    const id = state.selected ?? state.hovered;
    highlight(id ? lineage(tree, id) : null);
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
