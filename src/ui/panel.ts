// Selection and the details panel for the selected person: relatives, a back button through the people visited,
// focus mode (show only this person's line), and "relative to" mode (tag everyone with how they're related).
import { fitTree } from "../camera.ts";
import { ancestry, birthFamily, descendantCount, relatives } from "../family.ts";
import { setRelativeTags } from "../graph.ts";
import { labelAll } from "../relationship.ts";
import { setPerson } from "../suggest.ts";
import { $, panel, search } from "./dom.ts";
import { fitFamily, isPinned, onPinsChanged, togglePin } from "./navigate.ts";
import { openRelate } from "./relate.ts";
import { type Focus, flyToPerson, personLink, refreshHighlight, state } from "./state.ts";
import { pushUrl, writeUrl } from "./url.ts";

const panelName = $("panel-name-text");
const panelTrail = $("panel-trail");
const panelCount = $("panel-count");
const pinButton = $<HTMLButtonElement>("panel-pin");
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
    if (!state.tree) return;
    // 1. Record the step: the trail and a browser history entry (unless we're walking back through them).
    if (!fromHistory && state.selected !== id) {
        if (state.selected) trail.push(state.selected);
        pushUrl(id);
    }
    // 2. Show the person.
    state.selected = id;
    state.house = null; // a person's line replaces a legend house highlight
    if (relativeTo) setRelativeTo(id); // tags follow the selection, so they always describe the person shown
    refreshHighlight();
    fillPanel(id);
    setPerson(search, id); // keep the search box showing who is selected
    if (fromHistory) writeUrl();
    // 3. Move the camera: in focus mode frame the line that's left (fit follows the shown people), else fly if asked.
    if (state.focus !== "off") fitTree();
    else if (fly) flyToPerson(id);
}

/** Fill the details panel for a person and show it. */
function fillPanel(id: string) {
    const tree = state.tree!;
    const p = tree.people[id];
    panelName.textContent = p.name;
    panelHouse.textContent = p.house;
    panelHouse.style.color = tree.houseColors[p.house] ?? "";
    panelList.replaceChildren(...relatives(tree, id).flatMap(([label, ids]) => relativeRow(label, ids)));
    showTrail(id);
    showCount(id);
    showPin(id);
    updateBack();
    panel.hidden = false;
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
    setPerson(search, null);
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

// --- Moving between relatives from the keyboard (Alt + arrows) or a swipe ------------------------------------------
// Up: the parent the line of descent above the name follows, so the two always agree. Down: the first child.
// Left/right: the previous/next sibling (wrapping), or a spouse when there are none.
export function stepToRelative(dir: "up" | "down" | "left" | "right"): void {
    const { tree, selected } = state;
    if (!tree || !selected) return;
    const birth = birthFamily(tree, selected);
    const own = tree.families.filter((f) => f.parents.includes(selected));
    let next: string | undefined;
    if (dir === "up") next = ancestry(tree, selected).at(-2);
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

// --- Line of descent: a clickable trail from the oldest known ancestor down to this person ---------------------------
// Long lines (the Bible runs 70+ generations) show the start, an ellipsis that expands, and the last few steps.
const TRAIL_HEAD = 2;
const TRAIL_TAIL = 3;
function showTrail(id: string) {
    const line = ancestry(state.tree!, id);
    panelTrail.hidden = line.length < 2;
    if (line.length < 2) return panelTrail.replaceChildren();
    const link = (pid: string) => personLink(pid, () => select(pid, true));
    const parts = (ids: string[]) => ids.flatMap((pid, i) => (i ? [" › ", link(pid)] : [link(pid)]));
    const above = line.slice(0, -1); // the person themselves is the panel's heading
    if (above.length <= TRAIL_HEAD + TRAIL_TAIL + 1) return panelTrail.replaceChildren(...parts(above), " ›");
    const more = Object.assign(document.createElement("button"), {
        className: "trail-more",
        textContent: `… ${above.length - TRAIL_HEAD - TRAIL_TAIL} more …`,
        title: "Show the whole line",
    });
    more.onclick = () => panelTrail.replaceChildren(...parts(above), " ›");
    panelTrail.replaceChildren(
        ...parts(above.slice(0, TRAIL_HEAD)),
        " › ",
        more,
        " › ",
        ...parts(above.slice(-TRAIL_TAIL)),
        " ›"
    );
}

// --- Descendant count: "14 descendants over 4 generations"; click to show just them --------------------------------
function showCount(id: string) {
    const { people, generations } = descendantCount(state.tree!, id);
    panelCount.replaceChildren();
    if (!people) return;
    const b = Object.assign(document.createElement("button"), {
        className: "count-link",
        textContent: `${people} descendant${people === 1 ? "" : "s"} over ${generations} generation${generations === 1 ? "" : "s"}`,
        title: "Show only their descendants",
    });
    b.onclick = () => setFocus("descendants");
    panelCount.append(b);
}

// --- Pin ----------------------------------------------------------------------------------------------------------
function showPin(id: string) {
    const on = isPinned(id);
    pinButton.textContent = on ? "★" : "☆";
    pinButton.setAttribute("aria-pressed", String(on));
    pinButton.title = on ? "Unpin" : "Pin this person (they're listed in the menu)";
}
pinButton.onclick = () => state.selected && togglePin(state.selected);
onPinsChanged(() => state.selected && showPin(state.selected));

$("panel-fit").onclick = fitFamily;

// --- Focus depth: how many generations up and down focus mode shows ---------------------------------------------------
const depthSelect = $<HTMLSelectElement>("panel-depth");
depthSelect.onchange = () => {
    state.focusDepth = Number(depthSelect.value);
    if (state.focus === "off")
        setFocus("all"); // choosing a depth means you want to focus
    else (refreshHighlight(), fitTree());
};

// --- Swipe the panel left/right (touch) to move to the next/previous sibling, like Alt + ← → ---------------------------
let swipeFrom: { x: number; y: number } | null = null;
panel.addEventListener("pointerdown", (e) => {
    if (e.pointerType === "touch") swipeFrom = { x: e.clientX, y: e.clientY };
});
panel.addEventListener("pointerup", (e) => {
    if (!swipeFrom) return;
    const dx = e.clientX - swipeFrom.x;
    const dy = e.clientY - swipeFrom.y;
    swipeFrom = null;
    // A clear sideways swipe only: at least 60 px, and mostly horizontal, so scrolling the panel isn't mistaken for it.
    if (Math.abs(dx) > 60 && Math.abs(dx) > 2 * Math.abs(dy)) stepToRelative(dx < 0 ? "right" : "left");
});
panel.addEventListener("pointercancel", () => (swipeFrom = null));
