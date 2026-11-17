// Shareable links: ?saga=<id>&person=<id>&with=<id>&view=2d|3d, kept in sync with replaceState (no history entry
// per click). Read once at start-up by sagas.ts.
import { IMPORTED, state } from "./state.ts";

export function writeUrl(): void {
    const view = state.view2d ? "2d" : "3d";
    if (state.sagaId === IMPORTED) return history.replaceState(null, "", `?view=${view}`); // nothing else shareable
    const q = new URLSearchParams({ saga: state.sagaId, view });
    if (state.relPair) {
        q.set("person", state.relPair[0]);
        q.set("with", state.relPair[1]);
    } else if (state.selected) q.set("person", state.selected);
    history.replaceState(null, "", `?${q}`);
}
