// Relate: the relationship finder.
//
// What it does: two name boxes, the relationship between them, common ancestors and the step-by-step chain
// (`openRelate`, `closeRelate`, `toggleRelate`, `updateRelate`, `fillRelate`, `resetRelate`). Hovering a step lights
// that step; a new relationship pulses its steps in turn from the first person to the second.
// Usage: input.ts (R key), panel.ts and sagas.ts (open/reset), picking.ts (fillRelate: clicks fill the boxes).
// Notes: sets state.relPair and state.relStep, then calls refreshHighlight and writeUrl (?person=&with=). The result
// recomputes when either box changes; exact or partial names work, as in the main search. The pulse runs once per
// pair and is skipped for reduced motion. Button and box handlers are attached at import time (loaded via panel.ts).
// Element ids (#rel-result, #rel-steps, #rel-notes, #rel-swap, #relate-close) must match index.html.

import { fitTree } from "../render/camera.ts";
import { relate, stepWord } from "../tree/relationship.ts";
import { personIn, setPerson } from "./suggest.ts";

import {
    $,
    btnRelate,
    el,
    flyToPerson,
    personLink,
    refreshHighlight,
    relA,
    relatePanel,
    relB,
    state,
    writeUrl,
} from "./state.ts";

const relResult = $("rel-result");
const relSteps = $("rel-steps");
const relNotes = $("rel-notes");

// --- Pulse: when a new relationship appears, light each step in turn, from the first person to the second ------------
// Shows which way the path runs, once per pair. Reduced motion skips it (the whole path is already lit).
const PULSE_MS = 380;

let pulseTimer = 0;
let lastPulsed = "";

export function openRelate(from?: string): void {
    relatePanel.hidden = false;
    btnRelate.setAttribute("aria-pressed", "true");
    if (from && state.tree) setPerson(relA, from);
    (relA.value ? relB : relA).focus();
    updateRelate();
}

export function closeRelate(): void {
    stopPulse();
    state.relStep = null;
    relatePanel.hidden = true;
    btnRelate.setAttribute("aria-pressed", "false");
    state.relPair = null;
    clearResult();
    refreshHighlight();
    writeUrl();
}

export const toggleRelate = () => (relatePanel.hidden ? openRelate(state.selected ?? undefined) : closeRelate());

/** Empty the finder for a new tree: both boxes and the result, without touching the highlight or URL. */
export function resetRelate(): void {
    stopPulse();
    state.relStep = null;
    relatePanel.hidden = true;
    btnRelate.setAttribute("aria-pressed", "false");
    setPerson(relA, null);
    setPerson(relB, null);
    clearResult();
}

function clearResult() {
    relResult.textContent = "";
    relSteps.replaceChildren();
    relNotes.replaceChildren();
}

/** Fill the finder's next empty box ("From" first, then "To") with a tapped person. */
export function fillRelate(id: string): void {
    setPerson(relA.value ? relB : relA, id);
    updateRelate();
}

// Recompute whenever either name changes. Exact or partial names both work, as in the main search.
export function updateRelate(): void {
    const { tree } = state;
    if (!tree) return;
    const a = personIn(relA);
    const b = personIn(relB);
    relSteps.replaceChildren();
    relNotes.replaceChildren();
    if (!a || !b) {
        stopPulse();
        state.relPair = state.relStep = null;
        lastPulsed = "";
        relResult.textContent = relA.value && relB.value ? "Pick two people from the list." : "";
        refreshHighlight();
        writeUrl();
        return;
    }
    if (state.relPair?.[0] !== a || state.relPair?.[1] !== b) state.relStep = null; // a step of the old pair
    state.relPair = [a, b];
    const r = relate(tree, a, b);
    if (!r) {
        relResult.textContent = `${tree.people[a].name} and ${tree.people[b].name} aren't connected in this tree.`;
    } else {
        relResult.textContent = r.summary;
        // Who they descend from in common, and any other ways they're related (intermarried families).
        const extra: HTMLElement[] = [];
        if (r.commonAncestors.length) {
            const p = el("p", { className: "rel-note" });
            p.append(r.commonAncestors.length > 1 ? "Closest common ancestors: " : "Closest common ancestor: ");
            r.commonAncestors.forEach((id, i) => {
                if (i) p.append(" & ");
                p.append(personLink(id, () => flyToPerson(id)));
            });
            extra.push(p);
        }
        if (r.routes.length > 1) {
            const p = el("p", { className: "rel-note" });
            p.textContent = `Also related as: ${r.routes
                .slice(1)
                .map((x) => x.label + (x.adoptive ? " (by adoption)" : ""))
                .join(", ")}.`;
            extra.push(p);
        }
        relNotes.replaceChildren(...extra);
        // Step-by-step chain, each name clickable to fly there. Hovering (or focusing) a step lights up just that hop.
        for (const s of r.steps) {
            const li = document.createElement("li");
            li.append(
                `${stepWord(tree, s)}: `,
                personLink(s.to, () => flyToPerson(s.to))
            );
            const show = () => (stopPulse(), setStep([s.from, s.to]));
            li.addEventListener("pointerenter", show);
            li.addEventListener("focusin", show);
            li.addEventListener("pointerleave", () => setStep(null));
            li.addEventListener("focusout", () => setStep(null));
            relSteps.append(li);
        }
        if (!pulsed(a, b)) pulse(r.steps.map((s) => [s.from, s.to] as [string, string]));
    }
    refreshHighlight();
    writeUrl();
    // Frame the two people: the camera eases to fit the whole tree, which keeps both ends of the path in view.
    fitTree();
}

function setStep(step: [string, string] | null) {
    state.relStep = step;
    refreshHighlight();
}

const pulsed = (a: string, b: string) => {
    const key = `${a}|${b}`;
    const seen = key === lastPulsed;
    lastPulsed = key;
    return seen;
};

function pulse(steps: [string, string][]) {
    stopPulse();
    if (!steps.length || matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    let i = 0;
    const next = () => {
        setStep(i < steps.length ? steps[i++] : null);
        if (state.relStep) pulseTimer = window.setTimeout(next, PULSE_MS);
    };
    next();
}

function stopPulse() {
    clearTimeout(pulseTimer);
    pulseTimer = 0;
}

for (const input of [relA, relB]) {
    input.addEventListener("change", updateRelate);
    input.addEventListener("input", () => !input.value && updateRelate());
}

$("rel-swap").onclick = () => {
    const [a, b] = [personIn(relA), personIn(relB)];
    setPerson(relA, b);
    setPerson(relB, a);
    updateRelate();
};

btnRelate.onclick = toggleRelate;
$("relate-close").onclick = closeRelate;
