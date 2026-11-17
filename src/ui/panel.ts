// Selection and the details panel for the selected person: relatives, a back button through the people visited,
// focus mode (show only this person's line), and "relative to" mode (tag everyone with how they're related).
import { fitTree } from "../camera.ts";
import { relatives } from "../family.ts";
import { setRelativeTags } from "../graph.ts";
import { labelAll } from "../relationship.ts";
import { $, panel, search } from "./dom.ts";
import { openRelate } from "./relate.ts";
import { type Focus, flyToPerson, personLink, refreshHighlight, state } from "./state.ts";
import { pushUrl, writeUrl } from "./url.ts";

const panelName = $("panel-name");
const panelHouse = $("panel-house");
const panelList = $("panel-list");
const back = $<HTMLButtonElement>("panel-back");
const backName = $("panel-back-name");

// --- Browsing history: the people visited, so you can wander from relative to relative and come back ---------------
// Kept here (not only in the browser's history) so the panel's ◀ can name who you'd go back to. Each new selection
// is also a browser history entry, so the browser's Back button and a phone's back gesture walk the same trail.
const trail: string[] = [];

/** Select a person: light their line, fill the panel, and (unless `fromHistory`) add them to the trail. */
export function select(id: string, fly = false, fromHistory = false): void {
    const { tree } = state;
    if (!tree) return;
    if (!fromHistory && state.selected !== id) {
        if (state.selected) trail.push(state.selected);
        pushUrl(id);
    }
    state.selected = id;
    state.house = null; // a person's line replaces a legend house highlight
    if (relativeTo) setRelativeTo(id); // tags follow the selection, so they always describe the person shown
    refreshHighlight();
    const p = tree.people[id];
    panelName.textContent = p.name;
    panelHouse.textContent = p.house;
    panelHouse.style.color = tree.houseColors[p.house] ?? "";
    panelList.replaceChildren(...relatives(tree, id).flatMap(([label, ids]) => relativeRow(label, ids)));
    panel.hidden = false;
    search.value = p.name; // keep the search box showing who is selected
    updateBack();
    if (fromHistory) writeUrl();
    if (state.focus !== "off")
        fitTree(); // focus mode: frame the line that's left (fit follows the shown people)
    else if (fly) flyToPerson(id);
}

function updateBack() {
    const prev = trail.at(-1);
    back.hidden = !prev || !state.tree?.people[prev];
    backName.textContent = prev ? (state.tree!.people[prev]?.name ?? "") : "";
}

/** Go back to the previous person in the trail (the panel's ◀, Backspace, or the browser's Back). */
export function goBack(): void {
    const prev = trail.pop();
    if (prev && state.tree?.people[prev]) select(prev, true, true);
    else updateBack();
}
// The ◀ and Backspace walk the panel's own trail (never off the page, unlike history.back() on a fresh deep link);
// the browser's Back walks the history entries pushUrl() made. Either way you return to the person before.
back.onclick = goBack;

/** Called on the browser's Back: the URL's person is where to go (or nobody). */
export function onHistoryBack(person: string | null): void {
    if (person && state.tree?.people[person]) {
        if (trail.at(-1) === person) trail.pop();
        select(person, true, true);
    } else if (state.selected) deselect(true);
}

/** Forget the trail (a new tree). */
export const clearTrail = () => (trail.length = 0);

function relativeRow(label: string, ids: string[]): HTMLElement[] {
    const dd = document.createElement("dd");
    ids.forEach((rid, i) => {
        if (i) dd.append(", ");
        dd.append(personLink(rid, () => select(rid, true)));
    });
    return [Object.assign(document.createElement("dt"), { textContent: label }), dd];
}

/** The single way out of a selection: close button, Escape, an empty click, or clearing the search. */
export function deselect(fromHistory = false): void {
    if (!fromHistory && state.selected) trail.push(state.selected);
    state.selected = null;
    panel.hidden = true;
    search.value = "";
    setRelativeTo(null);
    fitTree(); // ease back to the whole tree, so the orbit pivot is no longer the last person
    refreshHighlight();
    writeUrl();
}
$("panel-close").onclick = () => deselect();
$("panel-relate").onclick = () => state.selected && openRelate(state.selected);

// --- Focus mode -----------------------------------------------------------------------------------------------------
const focusButtons = [...document.querySelectorAll<HTMLButtonElement>(".panel-focus button")];
export function setFocus(f: Focus): void {
    state.focus = f;
    for (const b of focusButtons) b.setAttribute("aria-checked", String(b.dataset.focus === f));
    refreshHighlight();
    fitTree(); // frame what's shown: the line on its own, or the whole tree again
}
for (const b of focusButtons) b.onclick = () => setFocus(b.dataset.focus as Focus);

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

// --- Moving between relatives from the keyboard (Alt + arrows) ------------------------------------------------------
// Up: a parent. Down: a child. Left/right: the previous/next sibling (wrapping), or a spouse when there are none.
export function stepToRelative(dir: "up" | "down" | "left" | "right"): void {
    const { tree, selected } = state;
    if (!tree || !selected) return;
    const birth =
        tree.families.find((f) => f.children.includes(selected) && !f.adoptive) ??
        tree.families.find((f) => f.children.includes(selected));
    const own = tree.families.filter((f) => f.parents.includes(selected));
    let next: string | undefined;
    if (dir === "up") next = birth?.parents[0];
    else if (dir === "down") next = own.flatMap((f) => f.children)[0];
    else {
        const sibs = birth?.children ?? [];
        if (sibs.length > 1) {
            const i = sibs.indexOf(selected);
            next = sibs[(i + (dir === "right" ? 1 : sibs.length - 1)) % sibs.length];
        } else next = own.flatMap((f) => f.parents).find((p) => p !== selected);
    }
    if (next) select(next, true);
}
