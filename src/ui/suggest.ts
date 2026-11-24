// Suggestions: name suggestions for the search and relationship-finder boxes.
//
// What it does: one shared listbox, placed under (or, near the bottom of the screen, above) whichever box has focus.
// Each suggestion is a person, not just a name: picking one stores their id on the box (box.dataset.person) before
// firing change. Matching ignores accents and tolerates typos (searchPeople in tree/search.ts).
// Usage: setSuggestions() per saga, attachSuggestions() per box, personIn() and setPerson() to read and fill a box;
// used by src/ui/ (state.ts, sagas.ts, input.ts, relate.ts, panel.ts).
// Notes: replaces <datalist>, which many mobile browsers show badly or not at all (Firefox for Android ignores it; iOS
// only offers matches in the keyboard bar after typing). People who share a name get a hint ("Lamech · son of
// Methushael"), so the two Lamechs in the Bible can't be confused. Typing clears the stored id.

import type { Tree } from "../data/schema.ts";
import { distinguish, searchPeople } from "../tree/search.ts";

const list = Object.assign(document.createElement("ul"), { id: "suggest", role: "listbox", hidden: true });
const MAX_SHOWN = 60; // the list scrolls; more than this is noise
let tree: Tree | null = null;
let everyone: string[] = []; // all ids, alphabetical: shown before anything is typed
let hint = new Map<string, string | null>();
let input: HTMLInputElement | null = null;
let active = -1;
let shown: string[] = [];

/** The people to offer (the current saga's). */
export function setSuggestions(t: Tree): void {
    tree = t;
    everyone = Object.keys(t.people).sort((a, b) => t.people[a].name.localeCompare(t.people[b].name));
    hint = new Map(everyone.map((id) => [id, distinguish(t, id)]));
    if (input) render();
}

/** Text for a person in a box: their name, plus the hint if someone else shares it. */
export const label = (id: string) => {
    const h = hint.get(id);
    return tree ? (h ? `${tree.people[id].name} · ${h}` : tree.people[id].name) : "";
};

/**
 * The person a box refers to: the one picked from its list, if the text still shows them; otherwise the best search
 * match for whatever was typed. Used by the search box and the relationship finder.
 */
export function personIn(box: HTMLInputElement): string | null {
    if (!tree || !box.value.trim()) return null;
    const picked = box.dataset.person;
    if (picked && tree.people[picked] && box.value === label(picked)) return picked;
    return searchPeople(tree, box.value.replace(/ · .*$/, ""), 1)[0] ?? null;
}

/** Show a person in a box (when the app fills it), remembering who it is. */
export function setPerson(box: HTMLInputElement, id: string | null): void {
    box.value = id && tree ? label(id) : "";
    if (id) box.dataset.person = id;
    else delete box.dataset.person;
}

function render() {
    if (!input || !tree) return;
    const q = input.value.replace(/ · .*$/, "").trim();
    shown = (q ? searchPeople(tree, q) : everyone).slice(0, MAX_SHOWN);
    active = -1;
    list.replaceChildren(
        ...shown.map((id, i) => {
            const li = Object.assign(document.createElement("li"), { id: `suggest-${i}` });
            li.append(tree!.people[id].name);
            const h = hint.get(id);
            if (h) li.append(Object.assign(document.createElement("span"), { className: "hint", textContent: h }));
            li.setAttribute("role", "option");
            // Cancelling pointerdown keeps focus in the box, so its blur doesn't close the list mid-tap. The pick itself
            // waits for click: closing the list on pointerdown let the tap's click land on whatever was underneath.
            li.addEventListener("pointerdown", (e) => e.preventDefault());
            li.addEventListener("click", () => pick(id));
            return li;
        })
    );
    // Nothing to show, or the box already names exactly the one match: keep the list out of the way.
    const exact = shown.length === 1 && input.value === label(shown[0]);
    list.hidden = !shown.length || exact;
    input.setAttribute("aria-expanded", String(!list.hidden));
    if (!list.hidden) place();
}

function place() {
    const r = input!.getBoundingClientRect();
    const viewH = visualViewport?.height ?? innerHeight; // excludes the on-screen keyboard
    const below = viewH - r.bottom - 8;
    const above = r.top - 8;
    const up = below < 180 && above > below;
    Object.assign(list.style, {
        left: `${r.left}px`,
        width: `${Math.max(r.width, 240)}px`,
        top: up ? "" : `${r.bottom + 2}px`,
        bottom: up ? `${innerHeight - r.top + 2}px` : "",
        maxHeight: `${Math.min(280, up ? above : below)}px`,
    });
}

function pick(id: string) {
    if (!input) return;
    setPerson(input, id);
    close();
    input.dispatchEvent(new Event("change"));
}

function close() {
    list.hidden = true;
    input?.setAttribute("aria-expanded", "false");
}

function highlight(i: number) {
    list.children[active]?.removeAttribute("aria-selected");
    active = i;
    const li = list.children[i];
    li?.setAttribute("aria-selected", "true");
    li?.scrollIntoView({ block: "nearest" });
    if (li) input?.setAttribute("aria-activedescendant", li.id);
    else input?.removeAttribute("aria-activedescendant");
}

/** Offer suggestions on this box: on focus (everyone) and while typing (the best matches). */
export function attachSuggestions(box: HTMLInputElement): void {
    box.setAttribute("role", "combobox");
    box.setAttribute("aria-controls", "suggest");
    box.setAttribute("aria-autocomplete", "list");
    box.setAttribute("aria-expanded", "false");
    box.addEventListener("focus", () => ((input = box), render()));
    box.addEventListener("input", () => (delete box.dataset.person, render())); // typing forgets the picked person
    box.addEventListener("blur", () => (close(), (input = null)));
    box.addEventListener("keydown", (e) => {
        if (list.hidden) return;
        const n = list.children.length;
        if (e.key === "ArrowDown" || e.key === "ArrowUp") {
            e.preventDefault();
            highlight((active + (e.key === "ArrowDown" ? 1 : n - 1 + (active < 0 ? 1 : 0))) % n);
        } else if (e.key === "Enter" && active >= 0) {
            e.preventDefault();
            pick(shown[active]);
        } else if (e.key === "Escape") {
            e.stopImmediatePropagation(); // first Escape closes the list; the next one is the box's own
            close();
        }
    });
}

document.body.append(list);
addEventListener("resize", () => input && !list.hidden && place());
visualViewport?.addEventListener("resize", () => input && !list.hidden && place());
