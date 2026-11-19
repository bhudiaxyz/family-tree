// Shareable links: ?saga=<id>&person=<id>&with=<id>&house=<name>&view=2d|3d&siblings=apart. Most changes update the current history entry
// (replaceState); selecting a new person adds an entry (pushUrl), so the browser's Back walks through the people
// visited. Read once at start-up by sagas.ts.
import { IMPORTED, state } from "./state.ts";

function query(): string {
    const view = state.view2d ? "2d" : "3d";
    const q = new URLSearchParams(state.sagaId === IMPORTED ? { view } : { saga: state.sagaId, view });
    if (state.siblings === "apart") q.set("siblings", "apart"); // the default ("together") is left out
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
