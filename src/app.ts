// The 3D app, loaded by main.ts once WebGL is known to work. Wiring only: saga loading and URL state, selection and
// the details panel, the relationship finder, search, GEDCOM import, PNG export, picking, keyboard/pad input, and the
// frame loop. Rendering lives in scene.ts / graph.ts, camera behaviour in camera.ts, and the logic in family.ts,
// relationship.ts and data/gedcom.ts.
import * as THREE from "three";
import GUI from "lil-gui";
import type { SagaIndexEntry, Tree } from "./data/schema.ts";
import { listSagas, loadSaga } from "./data/source.ts";
import { parseGedcom } from "./data/gedcom.ts";
import { findByName, lineage, relatives } from "./family.ts";
import { labelAll, relate } from "./relationship.ts";
import { fontsReady } from "./labels.ts";
import { camera, captureView, controls, draw, glow, renderer, scene, setGlow, updateFog } from "./scene.ts";
import {
    graph,
    highlight,
    nodeById,
    peopleBbox,
    setGuidesVisible,
    setRelativeTags,
    showTree,
    stepGraph,
} from "./graph.ts";
import {
    type Dir,
    fitTree,
    flyTo,
    holdPan,
    nudgeRotate,
    releaseAllPans,
    releasePan,
    setReducedMotion,
    stepCamera,
} from "./camera.ts";

scene.add(graph);

const $ = <T extends HTMLElement = HTMLElement>(id: string) => document.getElementById(id) as T;
const title = $("title");
const author = $("author");
const panel = $("panel");
const panelName = $("panel-name");
const panelHouse = $("panel-house");
const panelList = $("panel-list");
const search = $<HTMLInputElement>("search");
const names = $("names");
const relatePanel = $("relate");
const relA = $<HTMLInputElement>("rel-a");
const relB = $<HTMLInputElement>("rel-b");
const relResult = $("rel-result");
const relSteps = $("rel-steps");
const relNotes = $("rel-notes");
const toast = $("toast");

const IMPORTED = "imported"; // saga id used in the URL / GUI for a GEDCOM file loaded from disk

let tree: Tree | null = null;
let sagaId = "";
let selected: string | null = null;
let hovered: string | null = null;
let relPair: [string, string] | null = null; // the relationship currently shown, if any

// What to light up: a relationship path takes priority; otherwise the selected/hovered person's line.
function refreshHighlight() {
    if (!tree) return highlight(null);
    if (relPair) {
        const r = relate(tree, ...relPair);
        return highlight(r ? new Set(r.path) : new Set(relPair), r?.path ?? []);
    }
    const id = selected ?? hovered;
    highlight(id ? lineage(tree, id) : null);
}

let toastTimer = 0;
function notify(message: string, error = false) {
    toast.textContent = message;
    toast.classList.toggle("error", error);
    toast.hidden = false;
    clearTimeout(toastTimer);
    toastTimer = window.setTimeout(() => (toast.hidden = true), error ? 6000 : 3000);
}

// --- Selection and details panel ------------------------------------------------------------------------------------
function select(id: string, fly = false) {
    if (!tree) return;
    selected = id;
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

function flyToPerson(id: string) {
    const node = nodeById(id);
    if (node) flyTo(node);
}

function personLink(id: string, onClick: () => void): HTMLAnchorElement {
    const a = Object.assign(document.createElement("a"), { href: "#", textContent: tree!.people[id].name });
    a.onclick = (e) => {
        e.preventDefault();
        onClick();
    };
    return a;
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
function deselect() {
    selected = null;
    panel.hidden = true;
    search.value = "";
    setRelativeTo(null);
    fitTree(); // ease back to the whole tree, so the orbit pivot is no longer the last person
    refreshHighlight();
    writeUrl();
}
$("panel-close").onclick = deselect;
$("panel-relate").onclick = () => selected && openRelate(selected);

// --- "Relative to" mode: tag everyone with how they're related to one person -----------------------------------
const btnRelativeTo = $("panel-relative-to");
let relativeTo: string | null = null;
function setRelativeTo(id: string | null) {
    relativeTo = id && tree ? id : null;
    setRelativeTags(relativeTo ? labelAll(tree!, relativeTo) : null);
    btnRelativeTo.setAttribute("aria-pressed", String(!!relativeTo));
    btnRelativeTo.textContent = relativeTo ? "Hide relationship tags" : "Tag everyone's relationship";
}
btnRelativeTo.onclick = () => setRelativeTo(relativeTo === selected ? null : selected);

// --- Relationship finder --------------------------------------------------------------------------------------------
const btnRelate = $("btn-relate");

function openRelate(from?: string) {
    relatePanel.hidden = false;
    btnRelate.setAttribute("aria-pressed", "true");
    if (from && tree) relA.value = tree.people[from].name;
    (relA.value ? relB : relA).focus();
    updateRelate();
}

function closeRelate() {
    relatePanel.hidden = true;
    btnRelate.setAttribute("aria-pressed", "false");
    relPair = null;
    relResult.textContent = "";
    relSteps.replaceChildren();
    relNotes.replaceChildren();
    refreshHighlight();
    writeUrl();
}

// Recompute whenever either name changes. Exact or partial names both work, as in the main search.
function updateRelate() {
    if (!tree) return;
    const a = findByName(tree, relA.value);
    const b = findByName(tree, relB.value);
    relSteps.replaceChildren();
    relNotes.replaceChildren();
    if (!a || !b) {
        relPair = null;
        relResult.textContent = relA.value && relB.value ? "Pick two people from the list." : "";
        refreshHighlight();
        writeUrl();
        return;
    }
    relPair = [a, b];
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
            const word = stepWord(s.via, tree.people[s.to].sex, s.adoptive);
            li.append(
                `${word}: `,
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

function stepWord(via: "parent" | "child" | "spouse", sex: "m" | "f", adoptive: boolean) {
    const pick = (m: string, f: string) => (sex === "m" ? m : f);
    if (via === "parent") return (adoptive ? "adoptive " : "") + pick("father", "mother");
    if (via === "child") return (adoptive ? "adopted " : "") + pick("son", "daughter");
    return pick("husband", "wife");
}

for (const input of [relA, relB]) {
    input.addEventListener("change", updateRelate);
    input.addEventListener("input", () => !input.value && updateRelate());
}
$("rel-swap").onclick = () => {
    [relA.value, relB.value] = [relB.value, relA.value];
    updateRelate();
};
btnRelate.onclick = () => (relatePanel.hidden ? openRelate(selected ?? undefined) : closeRelate());
$("relate-close").onclick = closeRelate;

// --- Search ---------------------------------------------------------------------------------------------------------
// `change` also fires on blur. After a search, clicking a relative in the panel selects them and writes their name
// into the box, then the box blurs and fires `change` with the value it had before; acting on that re-selected the
// searched person. Only treat it as a new search when the text names someone other than the current selection.
search.addEventListener("change", () => {
    if (!tree || search.value === (selected && tree.people[selected].name)) return;
    const id = findByName(tree, search.value);
    if (id && id !== selected) select(id, true);
});
// The clear (✕) button and deleting the text fire `input`, not `change` (which waits for blur).
search.addEventListener("input", () => {
    if (!search.value && selected) deselect();
});
search.addEventListener("keydown", (e) => {
    if (e.key !== "Escape") return;
    search.blur();
    if (selected) deselect();
    else search.value = "";
});

// --- PNG export -----------------------------------------------------------------------------------------------------
async function savePng() {
    try {
        const blob = await captureView(2, (g, w) => {
            // Stamp the saga title and author in the corner so a saved image is self-explanatory.
            const s = w / innerWidth;
            g.textBaseline = "top";
            g.shadowColor = "#000";
            g.shadowBlur = 6 * s;
            g.fillStyle = "#e6cf95";
            g.font = `700 ${24 * s}px "Roboto Condensed", "Arial Narrow", Arial, sans-serif`;
            g.fillText((tree?.title ?? "Family tree").toUpperCase(), 20 * s, 16 * s);
            g.fillStyle = "rgba(232,220,193,.75)";
            g.font = `italic ${13 * s}px Roboto, Arial, sans-serif`;
            g.fillText(tree?.author ?? "", 20 * s, 46 * s);
        });
        const a = Object.assign(document.createElement("a"), {
            href: URL.createObjectURL(blob),
            download: `${(tree?.title ?? "family-tree").replace(/[^\w-]+/g, "-").toLowerCase()}.png`,
        });
        a.click();
        setTimeout(() => URL.revokeObjectURL(a.href), 10_000);
        notify("Saved the current view as a PNG.");
    } catch (e) {
        notify(`Couldn't save the image: ${(e as Error).message}`, true);
    }
}
$("btn-png").onclick = savePng;

// --- GEDCOM import: file picker, or drag a .ged file onto the window ---------------------------------------------
const fileInput = $<HTMLInputElement>("file");
$("btn-import").onclick = () => fileInput.click();
fileInput.onchange = () => {
    const f = fileInput.files?.[0];
    if (f) importFile(f);
    fileInput.value = ""; // allow re-importing the same file
};
addEventListener("dragover", (e) => {
    if (e.dataTransfer?.types.includes("Files")) e.preventDefault();
});
addEventListener("drop", (e) => {
    const f = e.dataTransfer?.files[0];
    if (!f) return;
    e.preventDefault();
    importFile(f);
});

async function importFile(file: File) {
    if (file.size > 20 * 1024 * 1024)
        return notify("That file is larger than 20 MB; GEDCOM files are usually far smaller.", true);
    try {
        const { tree: t, warnings } = parseGedcom(await file.text(), file.name.replace(/\.(ged|gedcom)$/i, ""));
        request++; // cancel any saga load still in flight
        sagaId = IMPORTED;
        show(t);
        const n = Object.keys(t.people).length;
        notify(
            `Imported ${n} ${n === 1 ? "person" : "people"} from ${file.name}` +
                (warnings.length ? ` (${warnings.length} warnings, see console)` : ".")
        );
        if (warnings.length) console.warn("GEDCOM import warnings:\n" + warnings.join("\n"));
    } catch (e) {
        notify(`Couldn't import ${file.name}: ${(e as Error).message}`, true);
    }
}

// --- Keyboard -------------------------------------------------------------------------------------------------------
const KEY_DIR: Record<string, Dir> = { ArrowLeft: "left", ArrowRight: "right", ArrowUp: "up", ArrowDown: "down" };
const typing = () => document.activeElement instanceof HTMLInputElement;
addEventListener("keydown", (e) => {
    if (typing() || e.ctrlKey || e.metaKey || e.altKey) {
        if (!typing() && KEY_DIR[e.key] && (e.ctrlKey || e.metaKey)) (e.preventDefault(), nudgeRotate(KEY_DIR[e.key]));
        return;
    }
    if (e.key === "/") return (e.preventDefault(), search.focus());
    if (e.key === "r" || e.key === "R")
        return (e.preventDefault(), relatePanel.hidden ? openRelate(selected ?? undefined) : closeRelate());
    if (e.key === "p" || e.key === "P") return (e.preventDefault(), void savePng());
    if (e.key === "f" || e.key === "F") return fitTree();
    if (e.key === "Escape") {
        if (!relatePanel.hidden) return closeRelate();
        if (selected) return deselect();
        return;
    }
    const dir = KEY_DIR[e.key];
    if (!dir) return;
    e.preventDefault(); // stop the page scrolling
    if (e.shiftKey) nudgeRotate(dir);
    else holdPan(dir);
});
addEventListener("keyup", (e) => {
    const dir = KEY_DIR[e.key];
    if (dir) releasePan(dir);
});
addEventListener("blur", releaseAllPans); // don't keep panning if the window loses focus mid-press

// --- Touch pad: press and hold to pan; pointer capture keeps it working when the finger slides off ----------------
for (const btn of document.querySelectorAll<HTMLButtonElement>("#pad button[data-dir]")) {
    const dir = btn.dataset.dir as Dir;
    btn.addEventListener("pointerdown", (e) => {
        btn.setPointerCapture(e.pointerId);
        holdPan(dir);
    });
    for (const ev of ["pointerup", "pointercancel", "lostpointercapture"])
        btn.addEventListener(ev, () => releasePan(dir));
}
document.querySelector<HTMLButtonElement>("#pad [data-action=fit]")!.onclick = fitTree;

// --- Picking: hover highlights (mouse only), click/tap selects -----------------------------------------------------
const raycaster = new THREE.Raycaster();
const pointer = new THREE.Vector2();
function pick(e: PointerEvent | MouseEvent): string | null {
    pointer.set((e.clientX / innerWidth) * 2 - 1, -(e.clientY / innerHeight) * 2 + 1);
    raycaster.setFromCamera(pointer, camera);
    for (const hit of raycaster.intersectObject(graph, true)) {
        const id = hit.object.userData.personId as string | undefined;
        if (id) return id;
    }
    return null;
}

// Tap/click handling that works the same for mouse, pen and touch:
//  - A tap counts only if it started on the canvas, used one pointer, and moved less than TAP_SLOP (a finger moves a
//    little even when "still"; 5 px was too tight on phones). A second finger turns it into a pinch, never a tap.
//  - Two taps on the same person within DOUBLE_MS fly to them (dblclick is unreliable on mobile browsers).
//  - Press and hold on a person (touch) previews their line, the touch equivalent of mouse hover.
//  - pointercancel (the browser took over for scrolling/zooming) abandons the tap.
// downAt is cleared after every pointerup, so a click on the panel can never also select whoever is behind it.
const TAP_SLOP = { mouse: 5, pen: 8, touch: 12 } as Record<string, number>;
const DOUBLE_MS = 350;
const HOLD_MS = 450;
const canvas = renderer.domElement;
const active = new Set<number>(); // pointers currently down on the canvas
let downAt: { x: number; y: number; type: string; multi: boolean } | null = null;
let lastTap: { id: string; at: number } | null = null;
let holdTimer = 0;

canvas.addEventListener("pointerdown", (e) => {
    active.add(e.pointerId);
    if (active.size > 1) {
        if (downAt) downAt.multi = true; // pinch/rotate: not a tap
        clearTimeout(holdTimer);
        return;
    }
    downAt = { x: e.clientX, y: e.clientY, type: e.pointerType, multi: false };
    if (e.pointerType !== "mouse") {
        clearTimeout(holdTimer);
        holdTimer = window.setTimeout(() => {
            const id = pick(e);
            if (!id || relPair) return;
            hovered = id; // long-press preview of this person's line
            refreshHighlight();
            navigator.vibrate?.(10);
        }, HOLD_MS);
    }
});
const endPointer = (e: PointerEvent) => {
    active.delete(e.pointerId);
    clearTimeout(holdTimer);
};
canvas.addEventListener("pointercancel", (e) => {
    endPointer(e);
    downAt = null;
});
addEventListener("pointerup", () => setTimeout(() => (downAt = null)));
canvas.addEventListener("pointermove", (e) => {
    // Moving past the slop cancels the long-press (it's a drag).
    if (downAt && Math.hypot(e.clientX - downAt.x, e.clientY - downAt.y) > TAP_SLOP[downAt.type])
        clearTimeout(holdTimer);
    if (e.pointerType !== "mouse" || e.buttons) return; // hover is mouse-only; touch uses long-press
    const id = pick(e);
    canvas.style.cursor = id ? "pointer" : "";
    if (id !== hovered) {
        hovered = id;
        if (!relPair) refreshHighlight(); // hover doesn't disturb a relationship being shown
    }
});
canvas.addEventListener("pointerup", (e) => {
    endPointer(e);
    const start = downAt;
    if (!start || start.multi || active.size) return;
    if (Math.hypot(e.clientX - start.x, e.clientY - start.y) > (TAP_SLOP[start.type] ?? 8)) return;
    // End a touch long-press preview on release.
    if (start.type !== "mouse" && hovered && !selected) {
        hovered = null;
        refreshHighlight();
    }
    const id = pick(e);
    // With the finder open, taps fill it: the first sets "From" if empty, otherwise "To".
    if (id && !relatePanel.hidden && tree) {
        (relA.value ? relB : relA).value = tree.people[id].name;
        return updateRelate();
    }
    const now = performance.now();
    const double = !!id && lastTap?.id === id && now - lastTap.at < DOUBLE_MS;
    lastTap = id ? { id, at: now } : null;
    if (id)
        select(id, double); // a double tap / double click flies to them
    else if (selected) deselect();
});

// --- Loading sagas, and shareable links (?saga=<id>&person=<id>&with=<id>) ----------------------------------------
function writeUrl() {
    if (sagaId === IMPORTED) return history.replaceState(null, "", location.pathname); // nothing shareable on disk
    const q = new URLSearchParams({ saga: sagaId });
    if (relPair) {
        q.set("person", relPair[0]);
        q.set("with", relPair[1]);
    } else if (selected) q.set("person", selected);
    history.replaceState(null, "", `?${q}`);
}

let request = 0; // ignore a slow response if the user has already picked another saga
async function openSaga(id: string, person?: string | null, withPerson?: string | null) {
    const mine = ++request;
    sagaId = id;
    title.textContent = "Loading…";
    author.textContent = "";
    try {
        const t = await loadSaga(id);
        if (mine !== request) return;
        show(t);
        // Give the layout a moment to place nodes before selecting a linked person and flying to them.
        if (person && t.people[person])
            setTimeout(() => {
                if (mine !== request) return;
                if (withPerson && t.people[withPerson]) {
                    relA.value = t.people[person].name;
                    relB.value = t.people[withPerson].name;
                    openRelate();
                } else select(person, true);
            }, 1500);
    } catch (e) {
        if (mine === request) title.textContent = `Could not load saga: ${(e as Error).message}`;
        console.error(e);
    }
}

function show(t: Tree) {
    tree = t;
    selected = hovered = null;
    relPair = null;
    panel.hidden = true;
    relatePanel.hidden = true;
    btnRelate.setAttribute("aria-pressed", "false");
    search.value = relA.value = relB.value = relResult.textContent = "";
    relSteps.replaceChildren();
    relNotes.replaceChildren();
    showTree(t);
    names.replaceChildren(
        ...Object.values(t.people)
            .map((p) => p.name)
            .sort()
            .map((value) => Object.assign(document.createElement("option"), { value }))
    );
    title.textContent = t.title;
    author.textContent = t.author;
    controls.reset();
    fitTree();
    writeUrl();
}

const prefersReduced = matchMedia("(prefers-reduced-motion: reduce)");
setReducedMotion(prefersReduced.matches);
prefersReduced.addEventListener("change", () => setReducedMotion(prefersReduced.matches));

Promise.all([listSagas(), fontsReady])
    .then(([sagas]: [SagaIndexEntry[], unknown]) => {
        const params = new URLSearchParams(location.search);
        const wanted = params.get("saga");
        const state = { saga: sagas.some((s) => s.id === wanted) ? wanted! : sagas[0].id };
        const gui = new GUI({ title: "Sagas" });
        gui.add(state, "saga", Object.fromEntries(sagas.map((s) => [s.title, s.id])))
            .name("Saga")
            .onChange((id: string) => openSaga(id));
        // Display options. Glow defaults off on touch devices (GPU/battery); both are remembered between visits.
        const stored = (k: string, dflt: boolean) => (localStorage.getItem(k) ?? String(dflt)) === "true";
        const view = { glow: stored("ft.glow", glow), guides: stored("ft.guides", true) };
        setGlow(view.glow);
        setGuidesVisible(view.guides);
        gui.add(view, "glow")
            .name("Glow")
            .onChange((on: boolean) => (setGlow(on), localStorage.setItem("ft.glow", String(on))));
        gui.add(view, "guides")
            .name("Generation guides")
            .onChange((on: boolean) => (setGuidesVisible(on), localStorage.setItem("ft.guides", String(on))));
        if (matchMedia("(max-width: 600px)").matches) gui.close(); // on phones the open menu covers the title
        return openSaga(state.saga, params.get("person"), params.get("with"));
    })
    .catch((e) => {
        title.textContent = `Could not load saga list: ${(e as Error).message}`;
        console.error(e);
    });

// --- GPU context loss: pause, tell the user, and resume when the browser restores it ------------------------------
let paused = false;
addEventListener("ft:contextlost", () => {
    paused = true;
    notify("The graphics context was lost; trying to restore it…", true);
});
addEventListener("ft:contextrestored", () => {
    paused = false;
    if (tree) showTree(tree); // textures and materials must be rebuilt on the new context
    notify("Graphics restored.");
});

// --- Frame loop -----------------------------------------------------------------------------------------------------
// Dev-only hook for browser tests to read camera and node state; stripped from production builds.
if (import.meta.env.DEV) Object.assign(window, { __ft: { camera, controls, graph } });

let last = 0;
renderer.setAnimationLoop((now) => {
    const dt = last ? Math.min((now - last) / 1000, 0.1) : 1 / 60; // seconds; clamped so a backgrounded tab can't jump
    last = now;
    if (paused) return;
    stepGraph(camera, dt, now, innerWidth, innerHeight);
    stepCamera(dt, peopleBbox);
    updateFog();
    draw();
});
