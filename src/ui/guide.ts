// Guide: help, chart and tour.
//
// What it does: the shortcut list dialog (?, `toggleHelp`), an outline chart of one person's ancestors and descendants
// (C, `openChart`), and a guided tour that flies down a line of descent (T: `startTour`, `endTour`, `touring`).
// Usage: input.ts calls these for the keys; the dialogs' buttons are wired here at import time (loaded via input.ts).
// Notes: the dialogs are native <dialog>s (#help, #chart), which handle Escape, focus and the backdrop themselves; a
// click on the backdrop closes them. The tour goes through the selected person (ancestors, them, longest line of
// descendants) if there is one, else down the saga's longest line (tourLine in family.ts). Escape ends a tour first
// (see the capture-phase listener in input.ts). The help text in index.html must match the shortcuts.

import { ancestry, relatives, tourLine } from "../family.ts";
import { $, el } from "./dom.ts";
import { deselect, select } from "./panel.ts";
import { notify, personLink, state } from "./state.ts";

// --- Dialogs: open, and close on ✕ or a click on the backdrop ----------------------------------------------------
const help = $<HTMLDialogElement>("help");
const chart = $<HTMLDialogElement>("chart");
for (const d of [help, chart]) {
    d.querySelector<HTMLButtonElement>("[data-close]")!.onclick = () => d.close();
    d.addEventListener("click", (e) => e.target === d && d.close()); // the backdrop is the dialog itself
}
export const toggleHelp = () => (help.open ? help.close() : help.showModal());
$("btn-help").onclick = toggleHelp;

// --- Chart: one person's line as an outline. Ancestors above (oldest first), descendants below as nested lists ----
// Each branch is a <details>, so the browser folds and unfolds it; the first two levels start open.
const OPEN_LEVELS = 2;
export function openChart(): void {
    const tree = state.tree;
    const id = state.selected;
    if (!tree || !id) return;
    const go = (pid: string) => personLink(pid, () => (chart.close(), select(pid, true)));
    $("chart-title").textContent = tree.people[id].name;
    const body = $("chart-body");
    body.replaceChildren();

    const line = ancestry(tree, id).slice(0, -1);
    if (line.length) {
        const up = el("p", { className: "chart-line" });
        line.forEach((pid, i) => up.append(...(i ? [" › ", go(pid)] : [go(pid)])));
        up.append(" ›");
        body.append(heading("Line of descent"), up);
    }

    const seen = new Set([id]); // intermarriage can reach a person twice; list them once
    const childrenOf = (pid: string) => {
        const kids = relatives(tree, pid)
            .filter(([label]) => label === "Children" || label === "Adopted children")
            .flatMap(([, ids]) => ids)
            .filter((c) => !seen.has(c));
        for (const c of kids) seen.add(c);
        return kids;
    };
    const branch = (pid: string, depth: number): HTMLElement => {
        const kids = childrenOf(pid);
        const name = go(pid);
        const li = document.createElement("li");
        if (!kids.length) return (li.append(name), li);
        const d = el("details", { open: depth < OPEN_LEVELS });
        const s = document.createElement("summary");
        s.append(name, el("span", { className: "n", textContent: ` ${kids.length}` }));
        const ul = document.createElement("ul");
        ul.append(...kids.map((c) => branch(c, depth + 1)));
        d.append(s, ul);
        li.append(d);
        return li;
    };
    // The person is the dialog's heading, so their children are the outline's top level.
    const kids = childrenOf(id);
    if (kids.length) {
        const root = document.createElement("ul");
        root.className = "chart-tree";
        root.append(...kids.map((c) => branch(c, 1)));
        body.append(heading("Descendants"), root);
    }
    if (!line.length && !kids.length)
        body.append(
            el("p", {
                className: "tip",
                textContent: "No recorded parents or children.",
            })
        );
    chart.showModal();
}
const heading = (text: string) => el("h3", { textContent: text });
$("panel-chart").onclick = openChart;

// --- Guided tour: fly down a line of descent, a few seconds per person ----------------------------------------------
// Through the selected person when there is one (their ancestors, them, then their longest line of descendants),
// otherwise down the saga's longest line.
const STEP_MS = 4000;
const bar = $("tour");
const text = $("tour-text");
const stepLabel = $("tour-step");
const play = $<HTMLButtonElement>("tour-play");
let stops: string[] = [];
let centre: string | null = null; // who the tour was started from, if anyone
let at = 0;
let timer = 0;

function show(i: number) {
    const tree = state.tree;
    if (!tree) return endTour();
    at = Math.max(0, Math.min(stops.length - 1, i));
    const id = stops[at];
    select(id, true);
    const p = tree.people[id];
    const next = stops[at + 1];
    const here = id === centre ? " (where you started)" : "";
    text.textContent =
        (at === 0
            ? `${p.name}${here}, the oldest known ancestor of this line, of House ${p.house}.`
            : `${p.name}${here}, ${p.sex === "m" ? "son" : "daughter"} of ${tree.people[stops[at - 1]].name}.`) +
        (next ? "" : " The end of the line.");
    stepLabel.textContent = `${at + 1} / ${stops.length}`;
}
function schedule() {
    clearTimeout(timer);
    if (play.getAttribute("aria-pressed") === "true" && at < stops.length - 1)
        timer = window.setTimeout(() => (show(at + 1), schedule()), STEP_MS);
}
export function startTour(): void {
    if (!state.tree) return;
    centre = state.selected;
    stops = tourLine(state.tree, centre);
    if (stops.length < 2) {
        const who = centre ? state.tree.people[centre].name : "This saga";
        return notify(`${who} has no recorded parents or children to tour.`);
    }
    bar.hidden = false;
    play.setAttribute("aria-pressed", "true");
    play.textContent = "Pause";
    show(0);
    schedule();
}
/** Stop the tour and go back to whoever you'd selected before it (each stop selects its person on the way). */
export function endTour(): void {
    clearTimeout(timer);
    if (bar.hidden) return;
    bar.hidden = true;
    if (centre && state.tree?.people[centre]) select(centre, true);
    else deselect();
}
export const touring = () => !bar.hidden;
$("btn-tour").onclick = () => (touring() ? endTour() : startTour());
$("tour-end").onclick = endTour;
$("tour-prev").onclick = () => (show(at - 1), schedule());
$("tour-next").onclick = () => (show(at + 1), schedule());
play.onclick = () => {
    const on = play.getAttribute("aria-pressed") !== "true";
    play.setAttribute("aria-pressed", String(on));
    play.textContent = on ? "Pause" : "Play";
    schedule();
};
