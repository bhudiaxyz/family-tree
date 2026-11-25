// Panel: selection and the details panel for the selected person.
//
// What it does: `select`/`deselect`; fills the panel (relatives, line of descent, recent chips, generation, namesakes,
// descendant count, pin); the back trail (`goBack`, `onHistoryBack`, `clearTrail`); "relative to" mode; moving between
// relatives (`stepToRelative`, Alt + arrows or a swipe; `stepToSpouse`, Alt + S); groups (`showGroup`, `clearGroup`).
// Usage: imported by input, search, picking, legend, guide, relate, sagas and others; also wires the panel's buttons.
// Notes: `select()` and `deselect()` are the only ways in and out of a selection; they set state, call refreshHighlight
// and update the URL (select pushes history, the rest replace). The trail is kept here, as well as in the browser's
// history, so the back button can name who it returns to. Focus mode and collapse live in visibility.ts; the panel only
// hosts their controls. Panel element ids must match index.html.

import { fitPeople, fitTree } from "../render/camera.ts";
import { bornText } from "../data/schema.ts";
import { ancestry, birthFamily, descendantCount, namesakes, relatives, siblingsOf } from "../tree/family.ts";
import { generationOf, nodeById, setRelativeTags } from "../graph/graph.ts";
import { labelAll } from "../tree/relationship.ts";
import { setPerson } from "./suggest.ts";

import {
    $,
    el,
    flyToPerson,
    notify,
    panel,
    personLink,
    pushUrl,
    refreshHighlight,
    search,
    state,
    writeUrl,
} from "./state.ts";

import { fitFamily, isPinned, onPinsChanged, togglePin } from "./navigate.ts";
import { openRelate } from "./relate.ts";
import { setFocus, showCollapse, showDepths } from "./visibility.ts";

const panelName = $("panel-name-text");
const panelTrail = $("panel-trail");
const panelCount = $("panel-count");
const panelRecent = $("panel-recent");
const pinButton = $<HTMLButtonElement>("panel-pin");
const panelHouse = $("panel-house");
const panelList = $("panel-list");
const back = $<HTMLButtonElement>("panel-back");
const backName = $("panel-back-name");

// --- Browsing history: the people visited, so you can wander from relative to relative and come back ---------------
// Kept here (not only in the browser's history) so the panel's ◀ can name who you'd go back to. Each new selection
// is also a browser history entry, so the browser's Back button and a phone's back gesture walk the same trail.
const trail: string[] = [];

// --- Recently viewed: the last few people as chips, newest first, so you can jump back several steps at once ------
const RECENT = 3;

// --- "Relative to" mode ---------------------------------------------------------------------------------------------
const btnRelativeTo = $("panel-relative-to");

let relativeTo: string | null = null;

// --- Moving between relatives from the keyboard (Alt + arrows, Alt + S) or a swipe ----------------------------------
// Up: the parent the line of descent above the name follows, so the two always agree. Down: the child you last came
// up from, so up then down returns you along the same line, else the first child. Left/right: the previous/next
// sibling (wrapping), or a spouse when there are none.
const cameUpFrom = new Map<string, string>(); // parent → the child last stepped up from (checked before use)

// --- Line of descent: a clickable trail from the oldest known ancestor down to this person ---------------------------
// Long lines (the Bible runs 70+ generations) show the start, an ellipsis that expands, and the last few steps.
const TRAIL_HEAD = 2;

const TRAIL_TAIL = 3;

// --- Swipe the panel left/right (touch) to move to the next/previous sibling, like Alt + ← → ---------------------------
let swipeFrom: { x: number; y: number } | null = null;

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
    state.group = null; // ...and a searched group
    if (relativeTo) setRelativeTo(id); // tags follow the selection, so they always describe the person shown
    refreshHighlight();
    fillPanel(id);
    setPerson(search, id); // keep the search box showing who is selected
    if (fromHistory) writeUrl();
    // 3. Move the camera: in focus mode frame the line that's left (fit follows the shown people), else fly if asked.
    if (state.focus !== "off") fitTree();
    else if (fly) flyToPerson(id);
}

/** Redraw the panel for the selected person (after the tree is re-laid out, which can change their row). */
export const refreshPanel = () => state.selected && fillPanel(state.selected);

/** Fill the details panel for a person and show it. */
function fillPanel(id: string) {
    const tree = state.tree!;
    const p = tree.people[id];
    panelName.textContent = p.name;
    // The house, and the birth date where the data has one ("born 28 Jun 1491").
    panelHouse.replaceChildren(
        p.house,
        ...(p.born ? [el("span", { className: "panel-born", textContent: ` · born ${bornText(p.born)}` })] : [])
    );
    panelHouse.style.color = tree.houseColors[p.house] ?? "";
    panelList.replaceChildren(...relatives(tree, id).flatMap(([label, ids]) => relativeRow(label, ids)));
    showTrail(id);
    showCount(id);
    showPin(id);
    showRecent(id);
    showCollapse(id);
    showDepths(id);
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

/** Called on the browser's Back: the URL's person is where to go (or nobody). */
export function onHistoryBack(person: string | null): void {
    if (person && state.tree?.people[person]) {
        if (trail.at(-1) === person) trail.pop();
        select(person, true, true);
    } else if (state.selected) deselect(true);
}

/** Forget the trail (a new tree). */
export const clearTrail = () => (trail.length = 0);

function showRecent(id: string) {
    const seen = [...new Set([...trail].reverse())].filter((p) => p !== id && state.tree!.people[p]).slice(0, RECENT);
    panelRecent.hidden = !seen.length;
    panelRecent.replaceChildren(
        ...seen.map((p) => {
            const b = el("button", {
                className: "chip",
                textContent: state.tree!.people[p].name,
                title: `Back to ${state.tree!.people[p].name}`,
            });
            b.onclick = () => select(p, true);
            return b;
        })
    );
}

function relativeRow(label: string, ids: string[]): HTMLElement[] {
    const dd = document.createElement("dd");
    ids.forEach((rid, i) => {
        if (i) dd.append(", ");
        dd.append(personLink(rid, () => select(rid, true)));
    });
    return [el("dt", { textContent: label }), dd];
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

/** Who the "relative to" tags describe, if they're on. */
export const relativeToId = () => relativeTo;

export function setRelativeTo(id: string | null): void {
    relativeTo = id && state.tree ? id : null;
    setRelativeTags(relativeTo ? labelAll(state.tree!, relativeTo) : null);
    btnRelativeTo.setAttribute("aria-pressed", String(!!relativeTo));
    btnRelativeTo.textContent = relativeTo ? "Hide relationship tags" : "Tag everyone's relationship";
}

export function stepToRelative(dir: "up" | "down" | "left" | "right"): void {
    const { tree, selected } = state;
    if (!tree || !selected) return;
    const birth = birthFamily(tree, selected);
    const own = tree.families.filter((f) => f.parents.includes(selected));
    let next: string | undefined;
    if (dir === "up") {
        next = ancestry(tree, selected).at(-2);
        if (next) cameUpFrom.set(next, selected);
    } else if (dir === "down") {
        const children = own.flatMap((f) => f.children);
        const back = cameUpFrom.get(selected);
        next = back && children.includes(back) ? back : children[0];
    } else {
        const sibs = birth?.children ?? [];
        if (sibs.length > 1) {
            const i = sibs.indexOf(selected);
            next = sibs[(i + (dir === "right" ? 1 : sibs.length - 1)) % sibs.length];
        } else next = own.flatMap((f) => f.parents).find((p) => p !== selected);
    }
    if (next) select(next, true);
}

/** Alt + S: go to a spouse; again for the next one (from Cersei, having come from Robert, it goes on to Jaime). */
export function stepToSpouse(): void {
    const { tree, selected } = state;
    if (!tree || !selected) return;
    const spouses = [
        ...new Set(tree.families.filter((f) => f.parents.includes(selected)).flatMap((f) => f.parents)),
    ].filter((p) => p !== selected);
    if (!spouses.length) return notify(`${tree.people[selected].name} has no recorded spouse.`);
    select(spouses[(spouses.indexOf(trail.at(-1) ?? "") + 1) % spouses.length], true);
}

function showTrail(id: string) {
    const line = ancestry(state.tree!, id);
    panelTrail.hidden = line.length < 2;
    if (line.length < 2) return panelTrail.replaceChildren();
    const link = (pid: string) => personLink(pid, () => select(pid, true));
    const parts = (ids: string[]) => ids.flatMap((pid, i) => (i ? [" › ", link(pid)] : [link(pid)]));
    const above = line.slice(0, -1); // the person themselves is the panel's heading
    if (above.length <= TRAIL_HEAD + TRAIL_TAIL + 1) return panelTrail.replaceChildren(...parts(above), " ›");
    const more = el("button", {
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

/** The value that appears most often; ties go to the first. */
const mostCommon = (xs: number[]) => {
    const n = new Map<number, number>();
    for (const x of xs) n.set(x, (n.get(x) ?? 0) + 1);
    return [...n].reduce((a, b) => (b[1] > a[1] ? b : a))[0];
};

// --- Under the house: the generation (click to go to that row), namesakes, and the descendant count ---------------
function showCount(id: string) {
    const { people, generations } = descendantCount(state.tree!, id);
    panelCount.replaceChildren();
    // Generation: the row the person's brothers and sisters share (the one most of them are on). It's usually their own
    // row, but a sibling who married into another generation sits with their partner (Ginny with Harry, a row below the
    // Weasleys), and calling her generation 3 would put her level with her own nephew. Then the row is shown as well.
    const { row, of } = generationOf(id);
    const sibRows = siblingsOf(state.tree!, id).map((s) => generationOf(s).row);
    const generation = sibRows.length ? mostCommon([row, ...sibRows]) : row;
    if (of > 1) {
        const g = el("button", {
            className: "count-link",
            textContent: generation === row ? `Generation ${row + 1}` : `Generation ${generation + 1} (row ${row + 1})`,
            title:
                generation === row
                    ? "Show this person with their brothers and sisters"
                    : `Their brothers and sisters are generation ${generation + 1}; they sit on row ${row + 1} beside their spouse. Show them all`,
        });
        // Frame the person with their brothers and sisters: their generation, wherever each of them sits. (It used to
        // glide to the person's row, which does nothing visible when that row is already centred.)
        g.onclick = () => fitPeople([id, ...siblingsOf(state.tree!, id)].flatMap((p) => nodeById(p) ?? []));
        panelCount.append(g);
    }
    const same = namesakes(state.tree!, id);
    if (same.length > 1) {
        const n = el("button", {
            className: "count-link",
            textContent: `${same.length} named ${state.tree!.people[id].name}`,
            title: "Light up everyone with this name",
        });
        n.onclick = () => showGroup(same, `Everyone named ${state.tree!.people[id].name}`);
        panelCount.append(" · ", n);
    }
    if (!people) return;
    if (panelCount.childNodes.length) panelCount.append(" · ");
    const b = el("button", {
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

// --- A group of people found by a search or a namesake link, lit on their own like a house ---------------------
export function showGroup(ids: string[], label: string): void {
    if (state.selected) deselect();
    state.house = null;
    state.group = { ids, label };
    refreshHighlight();
    fitPeople(ids.flatMap((i) => nodeById(i) ?? []));
    notify(`${label}: ${ids.length}. Press Esc to clear.`);
}

export function clearGroup(): void {
    if (!state.group) return;
    state.group = null;
    refreshHighlight();
}

// The ◀ and Backspace walk the panel's own trail (never off the page, unlike history.back() on a fresh deep link);
// the browser's Back walks the history entries pushUrl() made. Either way you return to the person before.
back.onclick = goBack;

$("panel-close").onclick = () => deselect();
$("panel-relate").onclick = () => state.selected && openRelate(state.selected);
btnRelativeTo.onclick = () => setRelativeTo(relativeTo === state.selected ? null : state.selected);
pinButton.onclick = () => state.selected && togglePin(state.selected);
onPinsChanged(() => state.selected && showPin(state.selected));
$("panel-fit").onclick = fitFamily;

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
