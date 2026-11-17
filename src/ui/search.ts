// The "Find a person" box.
import { personIn } from "../suggest.ts";
import { search } from "./dom.ts";
import { deselect, select } from "./panel.ts";
import { state } from "./state.ts";

// `change` also fires on blur. Clicking a relative in the panel selects them and writes them into the box first, so
// the blur's `change` then names the person already selected and is ignored; acting on stale text used to re-select
// the person searched for. The box holds a person (picked from its list), not just a name; see suggest.ts.
search.addEventListener("change", () => {
    const id = personIn(search);
    if (id && id !== state.selected) select(id, true);
});
// The clear (✕) button and deleting the text fire `input`, not `change` (which waits for blur).
search.addEventListener("input", () => {
    if (!search.value && state.selected) deselect();
});
search.addEventListener("keydown", (e) => {
    if (e.key !== "Escape") return;
    search.blur();
    if (state.selected) deselect();
    else search.value = "";
});
