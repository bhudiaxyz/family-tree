// The 3D app, loaded by main.ts once WebGL is known to work. Wiring only: saga loading and URL state, selection and
// the details panel, the relationship finder, search, GEDCOM import, PNG export, picking, keyboard/pad input, and the
// frame loop. Rendering lives in scene.ts / graph.ts, camera behaviour in camera.ts, and the logic in family.ts,
// relationship.ts and data/gedcom.ts.
import * as THREE from "three";
import GUI from "lil-gui";
import { quality } from "./device.ts";
import { parseGedcom } from "./data/gedcom.ts";
import type { SagaIndexEntry, Tree } from "./data/schema.ts";
import { listSagas, loadSaga } from "./data/source.ts";
import { findByName, lineage, relatives } from "./family.ts";
import { labelAll, relate } from "./relationship.ts";
import { fontsReady, resetBadges } from "./labels.ts";
import { palette, paletteFor, usePalette } from "./palettes.ts";
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
import { bakeNebula } from "./nebula.ts";
import {
    applyScenePalette,
    camera,
    captureView,
    controls,
    draw,
    glow,
    renderer,
    scene,
    setGlow,
    setSky,
    updateFog,
} from "./scene.ts";

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
            g.shadowColor = palette().png.shadow;
            g.shadowBlur = 6 * s;
            g.fillStyle = palette().png.title;
            g.font = `700 ${24 * s}px "Roboto Condensed", "Arial Narrow", Arial, sans-serif`;
            g.fillText((tree?.title ?? "Family tree").toUpperCase(), 20 * s, 16 * s);
            g.fillStyle = palette().png.author;
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
// Who is under the pointer?
//  - Mouse/pen: an exact raycast, nearest sphere wins. A cursor is precise, so "the one in front" is what you meant.
//  - Touch: a fingertip covers ~7 mm and hides what's beneath it, so a raycast often hits a sphere in FRONT of the
//    intended one when people overlap (measured: 2 of 14 taps picked the wrong person on a phone). Instead, pick the
//    person whose on-screen centre is closest to the tap, within a finger-sized radius. Fall back to the raycast.
const FINGER_PX = 28;
function pick(e: PointerEvent | MouseEvent): string | null {
    if ((e as PointerEvent).pointerType === "touch") {
        const id = nearestOnScreen(e.clientX, e.clientY, FINGER_PX);
        if (id) return id;
    }
    pointer.set((e.clientX / innerWidth) * 2 - 1, -(e.clientY / innerHeight) * 2 + 1);
    raycaster.setFromCamera(pointer, camera);
    for (const hit of raycaster.intersectObject(graph, true)) {
        const id = hit.object.userData.personId as string | undefined;
        if (id) return id;
    }
    return null;
}

const projected = new THREE.Vector3();
function nearestOnScreen(x: number, y: number, radius: number): string | null {
    let best: string | null = null;
    let bestD = radius;
    for (const n of graph.graphData().nodes) {
        if (!n.name || n.x === undefined) continue;
        projected.set(n.x, n.y!, n.z!).project(camera);
        if (projected.z > 1) continue; // behind the camera
        const d = Math.hypot(((projected.x + 1) / 2) * innerWidth - x, ((1 - projected.y) / 2) * innerHeight - y);
        if (d < bestD) {
            bestD = d;
            best = n.id;
        }
    }
    return best;
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
    setRelativeTo(null);
    // Theme first: materials, labels and badges pick up their colours when built, so the palette must be active
    // before showTree() creates them. An imported file uses the default theme (keyed by its own name for the sky).
    const themeId = sagaId === IMPORTED ? "" : sagaId;
    usePalette(paletteFor(themeId));
    resetBadges(); // badge textures are cached per house; drop them so they redraw in the new theme's ink/outline
    applyScenePalette();
    showTree(t);
    scheduleSky(sagaId === IMPORTED ? `import:${t.title}` : sagaId);
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

// --- Nebula sky: baked per saga, a frame after the tree appears -------------------------------------------------
// Baking takes a few hundred ms on a phone. Doing it in the next frame lets the new tree draw first (against the flat
// vignette), then the sky fades in instead of the saga switch feeling stuck. A newer request supersedes an older one.
let skyRequest = 0;
let nebulaOn = true;
function scheduleSky(id: string) {
    const mine = ++skyRequest;
    if (!nebulaOn) return setSky(null);
    requestAnimationFrame(() =>
        requestAnimationFrame(() => {
            if (mine !== skyRequest || !nebulaOn) return;
            try {
                setSky(bakeNebula(renderer, id));
            } catch (e) {
                console.warn("Nebula bake failed; using the plain background.", e); // e.g. float targets unsupported
                setSky(null);
            }
        })
    );
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
        const sky = { nebula: stored("ft.nebula", true) };
        nebulaOn = sky.nebula;
        gui.add(sky, "nebula")
            .name("Nebula sky")
            .onChange((on: boolean) => {
                nebulaOn = on;
                localStorage.setItem("ft.nebula", String(on));
                scheduleSky(sagaId === IMPORTED ? `import:${tree?.title ?? ""}` : sagaId);
            });
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
    // Every GPU resource died with the context: textures, materials, the cached badges and the baked sky. Rebuild.
    resetBadges();
    applyScenePalette();
    if (tree) {
        showTree(tree);
        scheduleSky(sagaId === IMPORTED ? `import:${tree.title}` : sagaId);
    }
    notify("Graphics restored.");
});

// --- Frame loop -----------------------------------------------------------------------------------------------------
// Dev-only hook for browser tests to read camera and node state; stripped from production builds.
if (import.meta.env.DEV) Object.assign(window, { __ft: { camera, controls, graph, scene, renderer } });

// IDLE THROTTLING (battery). A settled tree that nobody is touching was redrawn 60 times a second for nothing, the
// biggest single drain on phones and laptops. Each frame compares a cheap fingerprint of everything that can move
// (camera, orbit target, and a sample of node positions); while it changes, or for IDLE_AFTER ms after any input,
// frames run at full rate. Once still, frames are skipped down to quality.idleFps (link particles keep moving, just
// slower). Any pointer, key, wheel or resize wakes it at once. Comparing real state rather than trusting "moving"
// flags means a forgotten flag can never freeze the view: the worst case is rendering a little more than needed.
const IDLE_AFTER = 600; // ms of stillness before throttling
let lastActive = performance.now();
const wake = () => (lastActive = performance.now());
for (const ev of ["pointerdown", "pointermove", "wheel", "keydown", "resize", "touchstart"])
    addEventListener(ev, wake, { passive: true });
let lastPrint = "";
function fingerprint(): string {
    const c = camera.position;
    const t = controls.target;
    const nodes = graph.graphData().nodes;
    let s = `${c.x.toFixed(2)},${c.y.toFixed(2)},${c.z.toFixed(2)},${t.x.toFixed(2)},${t.y.toFixed(2)},${t.z.toFixed(2)}`;
    // A stride through the nodes is enough to see the layout still settling; checking all of them isn't needed.
    for (let i = 0; i < nodes.length; i += Math.max(1, nodes.length >> 3)) s += `|${nodes[i].x?.toFixed(1)}`;
    return s;
}

let last = 0;
let lastDrawn = 0;
renderer.setAnimationLoop((now) => {
    const dt = last ? Math.min((now - last) / 1000, 0.1) : 1 / 60; // seconds; clamped so a backgrounded tab can't jump
    last = now;
    if (paused) return;
    const print = fingerprint();
    if (print !== lastPrint) {
        lastPrint = print;
        wake();
    }
    const idle = now - lastActive > IDLE_AFTER;
    if (idle && now - lastDrawn < 1000 / quality.idleFps) return; // skip this frame entirely: no simulation, no draw
    const step = idle ? Math.min((now - lastDrawn) / 1000, 0.1) : dt;
    lastDrawn = now;
    stepGraph(camera, step, now, innerWidth, innerHeight);
    stepCamera(step, peopleBbox);
    updateFog();
    draw();
});
