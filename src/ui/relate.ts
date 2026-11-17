// The relationship finder: two name boxes, the relationship between them, common ancestors and the step-by-step chain.
import { fitTree } from "../camera.ts";
import { findByName } from "../family.ts";
import { relate, stepWord } from "../relationship.ts";
import { $, btnRelate, relA, relatePanel, relB } from "./dom.ts";
import { flyToPerson, personLink, refreshHighlight, state } from "./state.ts";
import { writeUrl } from "./url.ts";

const relResult = $("rel-result");
const relSteps = $("rel-steps");
const relNotes = $("rel-notes");

export function openRelate(from?: string): void {
    relatePanel.hidden = false;
    btnRelate.setAttribute("aria-pressed", "true");
    if (from && state.tree) relA.value = state.tree.people[from].name;
    (relA.value ? relB : relA).focus();
    updateRelate();
}

export function closeRelate(): void {
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
    relatePanel.hidden = true;
    btnRelate.setAttribute("aria-pressed", "false");
    relA.value = relB.value = "";
    clearResult();
}

function clearResult() {
    relResult.textContent = "";
    relSteps.replaceChildren();
    relNotes.replaceChildren();
}

/** Fill the finder's next empty box ("From" first, then "To") with a tapped person. */
export function fillRelate(id: string): void {
    (relA.value ? relB : relA).value = state.tree!.people[id].name;
    updateRelate();
}

// Recompute whenever either name changes. Exact or partial names both work, as in the main search.
export function updateRelate(): void {
    const { tree } = state;
    if (!tree) return;
    const a = findByName(tree, relA.value);
    const b = findByName(tree, relB.value);
    relSteps.replaceChildren();
    relNotes.replaceChildren();
    if (!a || !b) {
        state.relPair = null;
        relResult.textContent = relA.value && relB.value ? "Pick two people from the list." : "";
        refreshHighlight();
        writeUrl();
        return;
    }
    state.relPair = [a, b];
    const r = relate(tree, a, b);
    if (!r) {
        relResult.textContent = `${tree.people[a].name} and ${tree.people[b].name} aren't connected in this tree.`;
    } else {
        relResult.textContent = r.summary;
        // Who they descend from in common, and any other ways they're related (intermarried families).
        const extra: HTMLElement[] = [];
        if (r.commonAncestors.length) {
            const p = Object.assign(document.createElement("p"), { className: "rel-note" });
            p.append(r.commonAncestors.length > 1 ? "Closest common ancestors: " : "Closest common ancestor: ");
            r.commonAncestors.forEach((id, i) => {
                if (i) p.append(" & ");
                p.append(personLink(id, () => flyToPerson(id)));
            });
            extra.push(p);
        }
        if (r.routes.length > 1) {
            const p = Object.assign(document.createElement("p"), { className: "rel-note" });
            p.textContent = `Also related as: ${r.routes
                .slice(1)
                .map((x) => x.label + (x.adoptive ? " (by adoption)" : ""))
                .join(", ")}.`;
            extra.push(p);
        }
        relNotes.replaceChildren(...extra);
        // Step-by-step chain, each name clickable to fly there.
        for (const s of r.steps) {
            const li = document.createElement("li");
            li.append(
                `${stepWord(tree, s)}: `,
                personLink(s.to, () => flyToPerson(s.to))
            );
            relSteps.append(li);
        }
    }
    refreshHighlight();
    writeUrl();
    // Frame the two people: the camera eases to fit the whole tree, which keeps both ends of the path in view.
    fitTree();
}

for (const input of [relA, relB]) {
    input.addEventListener("change", updateRelate);
    input.addEventListener("input", () => !input.value && updateRelate());
}
$("rel-swap").onclick = () => {
    [relA.value, relB.value] = [relB.value, relA.value];
    updateRelate();
};
btnRelate.onclick = toggleRelate;
$("relate-close").onclick = closeRelate;
