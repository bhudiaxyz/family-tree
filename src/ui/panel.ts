// Selection and the details panel for the selected person, plus "relative to" mode (tag everyone with how they're
// related to the selected person).
import { fitTree } from "../camera.ts";
import { relatives } from "../family.ts";
import { setRelativeTags } from "../graph.ts";
import { labelAll } from "../relationship.ts";
import { $, panel, search } from "./dom.ts";
import { openRelate } from "./relate.ts";
import { flyToPerson, personLink, refreshHighlight, state } from "./state.ts";
import { writeUrl } from "./url.ts";

const panelName = $("panel-name");
const panelHouse = $("panel-house");
const panelList = $("panel-list");

export function select(id: string, fly = false): void {
    const { tree } = state;
    if (!tree) return;
    state.selected = id;
    if (relativeTo) setRelativeTo(id); // tags follow the selection, so they always describe the person shown
    refreshHighlight();
    const p = tree.people[id];
    panelName.textContent = p.name;
    panelHouse.textContent = p.house;
    panelHouse.style.color = tree.houseColors[p.house] ?? "";
    panelList.replaceChildren(...relatives(tree, id).flatMap(([label, ids]) => relativeRow(label, ids)));
    panel.hidden = false;
    search.value = p.name; // keep the search box showing who is selected
    writeUrl();
    if (fly) flyToPerson(id);
}

function relativeRow(label: string, ids: string[]): HTMLElement[] {
    const dd = document.createElement("dd");
    ids.forEach((rid, i) => {
        if (i) dd.append(", ");
        dd.append(personLink(rid, () => select(rid, true)));
    });
    return [Object.assign(document.createElement("dt"), { textContent: label }), dd];
}

/** The single way out of a selection: close button, Escape, an empty click, or clearing the search. */
export function deselect(): void {
    state.selected = null;
    panel.hidden = true;
    search.value = "";
    setRelativeTo(null);
    fitTree(); // ease back to the whole tree, so the orbit pivot is no longer the last person
    refreshHighlight();
    writeUrl();
}
$("panel-close").onclick = deselect;
$("panel-relate").onclick = () => state.selected && openRelate(state.selected);

// --- "Relative to" mode ---------------------------------------------------------------------------------------------
const btnRelativeTo = $("panel-relative-to");
let relativeTo: string | null = null;
export function setRelativeTo(id: string | null): void {
    relativeTo = id && state.tree ? id : null;
    setRelativeTags(relativeTo ? labelAll(state.tree!, relativeTo) : null);
    btnRelativeTo.setAttribute("aria-pressed", String(!!relativeTo));
    btnRelativeTo.textContent = relativeTo ? "Hide relationship tags" : "Tag everyone's relationship";
}
btnRelativeTo.onclick = () => setRelativeTo(relativeTo === state.selected ? null : state.selected);
