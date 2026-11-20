// URL: shareable links, kept in step with the state.
//
// What it does: builds ?saga=<id>&person=<id>&with=<id>&house=<name>&view=2d|3d from `state`, writes it
// (`writeUrl`, `pushUrl`) and reports the browser's Back/Forward (`onPopState`).
// Usage: panel.ts calls pushUrl on select; legend, relate, visibility, sagas and others call writeUrl; sagas.ts reads
// the query once at start-up and registers onPopState.
// Notes: selecting a new person pushes a history entry (pushUrl), so the browser's Back walks the people visited;
// everything else uses replaceState (writeUrl). pushUrl sets state.selected only while building the URL, then restores
// it; the caller sets it afterwards. A file imported from disk is not shareable, so only ?view= is written for it.
// The default (3D) is left out of the link.

import { IMPORTED, state } from "./state.ts";

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
