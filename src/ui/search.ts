// Search: the "Find a person" box, by name or relationship ("Arya's cousins", "children of Zeus").
//
// What it does: on change, a relationship phrase lights up the people it finds as a group (showGroup), otherwise
// the named person is selected. Clearing the box or pressing Escape deselects.
// Usage: no exports. A side-effect module: app.ts imports it only for its listeners on the #search box.
// Notes: `change` also fires on blur. Clicking a relative in the panel selects them and writes them into the box
// first, so the blur's `change` then names the person already selected and is ignored; acting on stale text used to
// re-select the person searched for. The box holds a person (picked from its suggestion list), not just a name; see
// suggest.ts. The clear (x) button and deleting the text fire `input`, not `change`, so `input` is handled too.

import { searchRelation } from "../family.ts";
import { personIn } from "../suggest.ts";
import { search } from "./dom.ts";
import { deselect, select, showGroup } from "./panel.ts";
import { notify, state } from "./state.ts";

// `change` also fires on blur. Clicking a relative in the panel selects them and writes them into the box first, so
// the blur's `change` then names the person already selected and is ignored; acting on stale text used to re-select
// the person searched for. The box holds a person (picked from its list), not just a name; see suggest.ts.
search.addEventListener("change", () => {
    // "Arya's cousins", "children of Zeus": light up who that finds, rather than picking one person by name.
    const rel = state.tree && !search.dataset.person ? searchRelation(state.tree, search.value) : null;
    if (rel) {
        const name = state.tree!.people[rel.from].name;
        if (!rel.ids.length) return notify(`No ${rel.word} of ${name} in this tree.`);
        return showGroup(rel.ids, `${name}'s ${rel.word}`);
    }
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
