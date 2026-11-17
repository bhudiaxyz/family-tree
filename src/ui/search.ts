// The "Find a person" box.
import { findByName } from "../family.ts";
import { search } from "./dom.ts";
import { deselect, select } from "./panel.ts";
import { state } from "./state.ts";

// `change` also fires on blur. After a search, clicking a relative in the panel selects them and writes their name
// into the box, then the box blurs and fires `change` with the value it had before; acting on that re-selected the
// searched person. Only treat it as a new search when the text names someone other than the current selection.
search.addEventListener("change", () => {
    const { tree, selected } = state;
    if (!tree || search.value === (selected && tree.people[selected].name)) return;
    const id = findByName(tree, search.value);
    if (id && id !== selected) select(id, true);
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
