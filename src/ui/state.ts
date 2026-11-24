// State: what the app is showing, the page's fixed elements, and the shareable URL: what every UI module shares.
//
// What it does: holds `state` (tree, saga id, selected, hovered, relationship pair and step, house, searched group,
// collapsed branches, focus mode and depth, 2D flag, sibling mode) and `refreshHighlight()`, the one place that turns
// it into what is lit; the page elements from index.html, looked up once (`$`, `el`, title, author, panel, search,
// the finder's boxes); the toast (`notify`), `flyToPerson` and `personLink`; and the URL kept in step with the state
// (`writeUrl`, `pushUrl`, `onPopState`).
// Usage: imported by every other ui module.
// Notes: other modules change `state` and then call refreshHighlight(); none of them call graph's highlight()
// directly. Priority: relationship path, then searched group, then house, then the selected-or-hovered person's line
// (narrowed by focus mode and depth); collapsed branches are applied first, whatever else is lit. Element ids are
// looked up at import time and must exist in index.html. Name suggestions are attached to the name boxes here, before
// any feature module adds listeners to them, so an open suggestion list gets Escape first (see suggest.ts). Selecting
// a new person pushes a history entry (pushUrl), so the browser's Back walks the people visited; everything else uses
// replaceState (writeUrl). A file imported from disk isn't shareable, so only ?view= is written for it.
import { flyTo } from "../render/camera.ts";
import type { Tree } from "../data/schema.ts";
import type { SiblingMode } from "../tree/generations.ts";
import { cousinsOf, descendantsOf, type LineRole, lineageRoles, siblingsOf } from "../tree/family.ts";
import { highlight, nodeById, setFolded } from "../graph/graph.ts";
import { relate } from "../tree/relationship.ts";
import { attachSuggestions } from "./suggest.ts";

/** Focus mode: show only the highlighted line ("all"), or just one side of it; "off" dims the rest instead. */
export type Focus = "off" | "all" | "ancestors" | "descendants" | "siblings" | "cousins";

export const title = $("title");
export const author = $("author");
export const panel = $("panel");
export const search = $<HTMLInputElement>("search");
export const relatePanel = $("relate");
export const relA = $<HTMLInputElement>("rel-a");
export const relB = $<HTMLInputElement>("rel-b");
export const btnRelate = $("btn-relate");

/** How far a selection, house or group fades everything else (the default dim, for hovering, is 12%). */
const FADED = 0.06;

export const IMPORTED = "imported"; // saga id used in the URL / GUI for a GEDCOM file loaded from disk

export const state = {
    tree: null as Tree | null,
    sagaId: "",
    selected: null as string | null,
    hovered: null as string | null,
    relPair: null as [string, string] | null, // the relationship currently shown, if any
    relStep: null as [string, string] | null, // the finder step being hovered, if any
    house: null as string | null, // a house picked in the legend, highlighted on its own
    group: null as { ids: string[]; label: string } | null, // people found by a search ("Arya's cousins", namesakes)
    collapsed: new Set<string>(), // people whose descendants are folded away (hidden from the view)
    focus: "off" as Focus,
    focusDepth: 0, // generations up and down that focus mode shows; 0 = all
    view2d: false, // ?view=2d|3d, 3d by default
    siblings: "together" as SiblingMode, // always: brothers and sisters share a row (the "apart" mode is unused)
};

const toast = $("toast");
let toastTimer = 0;

// --- Page elements, looked up once ------------------------------------------------------------------------------
/** A page element by id (typed). A function declaration, so the element lookups below can use it at load time. */
export function $<T extends HTMLElement = HTMLElement>(id: string): T {
    return document.getElementById(id) as T;
}

/** A new element with properties set: `el("button", { className: "chip", textContent: name })`. */
export function el<K extends keyof HTMLElementTagNameMap>(
    tag: K,
    props: Partial<HTMLElementTagNameMap[K]> = {}
): HTMLElementTagNameMap[K] {
    return Object.assign(document.createElement(tag), props);
}

// What to light up, in priority order: a relationship path; a house from the legend; the selected (or hovered)
// person's line, with direction and distance so ancestors and descendants read apart.
export function refreshHighlight(): void {
    const { tree, relPair, focus } = state;
    if (!tree) return highlight(null);
    // Collapsed branches: their descendants are hidden whatever else is lit (a branch inside another counts once).
    const folded = new Set<string>();
    for (const c of state.collapsed) if (tree.people[c]) for (const d of descendantsOf(tree, c)) folded.add(d);
    setFolded(folded);
    const hideOthers = focus !== "off";
    if (relPair) {
        const r = relate(tree, ...relPair);
        const path = r?.path ?? [];
        return highlight(new Set(path.length ? path : relPair), { path, step: state.relStep, hideOthers });
    }
    if (state.group) return highlight(new Set(state.group.ids), { hideOthers, dim: FADED });
    if (state.house) {
        const house = state.house;
        const ids = Object.keys(tree.people).filter((id) => tree.people[id].house === house);
        // Fade the other houses well back, so the picked house's spread across the tree stands out.
        return highlight(new Set(ids), { hideOthers, dim: FADED });
    }
    const id = state.selected ?? state.hovered;
    if (!id) return highlight(null);
    // Siblings / cousins: just the person and those relatives (they're not in the line, so no depth or side).
    const sideways = (side: "sibling" | "cousin", ids: string[]) =>
        new Map<string, LineRole>([
            [id, { side: "self", distance: 0 }],
            ...ids.map((s): [string, LineRole] => [s, { side, distance: 0 }]),
        ]);
    const roles: Map<string, LineRole> =
        focus === "siblings"
            ? sideways("sibling", siblingsOf(tree, id))
            : focus === "cousins"
              ? sideways("cousin", cousinsOf(tree, id))
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
    // A selected person fades the rest well back (like a house), so their line reads clearly; a hover preview dims
    // more lightly, so moving the mouse across the tree doesn't keep blanking it out.
    const selected = id === state.selected;
    highlight(new Set(roles.keys()), {
        roles,
        hideOthers: hideOthers && selected,
        dim: selected ? FADED : undefined,
        centre: selected ? id : null, // the selected person glows; a hover preview doesn't
    });
}

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
    const a = el("a", { href: "#", textContent: state.tree!.people[id].name });
    a.onclick = (e) => {
        e.preventDefault();
        onClick();
    };
    return a;
}

// --- The URL: shareable links, kept in step with the state ---------------------------------------------------------
function query(): string {
    const view = state.view2d ? "2d" : "3d";
    const q = new URLSearchParams(state.sagaId === IMPORTED ? { view } : { saga: state.sagaId, view });
    if (state.sagaId === IMPORTED) return `?${q}`; // nothing else shareable for a file loaded from disk
    if (state.relPair) {
        q.set("person", state.relPair[0]);
        q.set("with", state.relPair[1]);
    } else if (state.selected) q.set("person", state.selected);
    else if (state.house) q.set("house", state.house);
    return `?${q}`;
}

export const writeUrl = (): void => history.replaceState({ person: state.selected }, "", query());

/** A new history entry for selecting `person` (state.selected is set by the caller just after). */
export function pushUrl(person: string): void {
    const was = state.selected;
    state.selected = person;
    history.pushState({ person }, "", query());
    state.selected = was;
}

/** Run `onBack(person)` when the browser goes back or forward to an entry made by pushUrl / writeUrl. */
export function onPopState(onBack: (person: string | null) => void): void {
    addEventListener("popstate", (e) => onBack((e.state as { person?: string | null } | null)?.person ?? null));
}

for (const box of [search, relA, relB]) attachSuggestions(box);
