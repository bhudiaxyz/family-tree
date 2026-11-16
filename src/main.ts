// App wiring: saga loading, selection, details panel, search, picking, keyboard/pad input, URL state, frame loop.
// Rendering lives in scene.ts / graph.ts, camera behaviour in camera.ts, and family queries in family.ts.
import "./style.css";
import * as THREE from "three";
import GUI from "lil-gui";
import type { SagaIndexEntry, Tree } from "./data/schema.ts";
import { listSagas, loadSaga } from "./data/source.ts";
import { findByName, lineage, relatives } from "./family.ts";
import { fontsReady } from "./labels.ts";
import { camera, controls, renderer, scene } from "./scene.ts";
import { graph, highlight, nodeById, showTree, stepGraph } from "./graph.ts";
import { type Dir, fitTree, flyTo, holdPan, nudgeRotate, releaseAllPans, releasePan, stepCamera } from "./camera.ts";

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

let tree: Tree | null = null;
let sagaId = "";
let selected: string | null = null;
let hovered: string | null = null;

const refreshHighlight = () => {
    const id = selected ?? hovered;
    highlight(id && tree ? lineage(tree, id) : null);
};

// --- Selection and details panel ------------------------------------------------------------------------------------
function select(id: string, fly = false) {
    if (!tree) return;
    selected = id;
    refreshHighlight();
    const p = tree.people[id];
    panelName.textContent = p.name;
    panelHouse.textContent = p.house;
    panelHouse.style.color = tree.houseColors[p.house] ?? "";
    panelList.replaceChildren(...relatives(tree, id).flatMap(([label, ids]) => relativeRow(label, ids)));
    panel.hidden = false;
    search.value = p.name; // keep the search box showing who is selected
    writeUrl();
    if (fly) {
        const node = nodeById(id);
        if (node) flyTo(node);
    }
}

function relativeRow(label: string, ids: string[]): HTMLElement[] {
    const dd = document.createElement("dd");
    ids.forEach((rid, i) => {
        if (i) dd.append(", ");
        const a = Object.assign(document.createElement("a"), { href: "#", textContent: tree!.people[rid].name });
        a.onclick = (e) => {
            e.preventDefault();
            select(rid, true);
        };
        dd.append(a);
    });
    return [Object.assign(document.createElement("dt"), { textContent: label }), dd];
}

/** The single way out of a selection: close button, Escape, an empty click, or clearing the search. */
function deselect() {
    selected = null;
    panel.hidden = true;
    search.value = "";
    fitTree(); // ease back to the whole tree, so the orbit pivot is no longer the last person
    refreshHighlight();
    writeUrl();
}
$("panel-close").onclick = deselect;

// --- Search ---------------------------------------------------------------------------------------------------------
search.addEventListener("change", () => {
    const id = tree && findByName(tree, search.value);
    if (id) select(id, true);
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

// --- Keyboard -------------------------------------------------------------------------------------------------------
const KEY_DIR: Record<string, Dir> = { ArrowLeft: "left", ArrowRight: "right", ArrowUp: "up", ArrowDown: "down" };
const typing = () => document.activeElement instanceof HTMLInputElement;
addEventListener("keydown", (e) => {
    if (e.key === "/" && !typing()) {
        e.preventDefault();
        search.focus();
        return;
    }
    if (e.key === "Escape" && selected) return deselect();
    const dir = KEY_DIR[e.key];
    if (!dir || typing()) return;
    e.preventDefault(); // stop the page scrolling
    if (e.shiftKey || e.ctrlKey || e.metaKey) nudgeRotate(dir);
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
function pick(e: PointerEvent): string | null {
    pointer.set((e.clientX / innerWidth) * 2 - 1, -(e.clientY / innerHeight) * 2 + 1);
    raycaster.setFromCamera(pointer, camera);
    for (const hit of raycaster.intersectObject(graph, true)) {
        const id = hit.object.userData.personId as string | undefined;
        if (id) return id;
    }
    return null;
}

// A click only counts if it started on the canvas and the pointer barely moved (otherwise it was an orbit drag).
// downAt is cleared after every pointerup, so a click on the panel can never also select whoever is behind it.
const canvas = renderer.domElement;
let downAt: [number, number] | null = null;
canvas.addEventListener("pointerdown", (e) => (downAt = [e.clientX, e.clientY]));
addEventListener("pointerup", () => setTimeout(() => (downAt = null)));
canvas.addEventListener("pointermove", (e) => {
    if (e.pointerType !== "mouse" || e.buttons) return; // hover is mouse-only; touch uses tap
    const id = pick(e);
    canvas.style.cursor = id ? "pointer" : "";
    if (id !== hovered) {
        hovered = id;
        refreshHighlight();
    }
});
canvas.addEventListener("pointerup", (e) => {
    if (!downAt || Math.hypot(e.clientX - downAt[0], e.clientY - downAt[1]) > 5) return;
    const id = pick(e);
    if (id) select(id);
    else if (selected) deselect();
});

// --- Loading sagas, and shareable links (?saga=<id>&person=<id>) ---------------------------------------------------
function writeUrl() {
    const q = new URLSearchParams({ saga: sagaId });
    if (selected) q.set("person", selected);
    history.replaceState(null, "", `?${q}`);
}

let request = 0; // ignore a slow response if the user has already picked another saga
async function openSaga(id: string, person?: string | null) {
    const mine = ++request;
    sagaId = id;
    title.textContent = "Loading…";
    author.textContent = "";
    try {
        const t = await loadSaga(id);
        if (mine !== request) return;
        show(t);
        // Give the layout a moment to place nodes before selecting a linked person and flying to them.
        if (person && t.people[person]) setTimeout(() => mine === request && select(person, true), 1500);
    } catch (e) {
        if (mine === request) title.textContent = `Could not load saga: ${(e as Error).message}`;
        console.error(e);
    }
}

function show(t: Tree) {
    tree = t;
    selected = hovered = null;
    panel.hidden = true;
    search.value = "";
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

Promise.all([listSagas(), fontsReady])
    .then(([sagas]: [SagaIndexEntry[], unknown]) => {
        const params = new URLSearchParams(location.search);
        const wanted = params.get("saga");
        const state = { saga: sagas.some((s) => s.id === wanted) ? wanted! : sagas[0].id };
        const gui = new GUI({ title: "Sagas" });
        gui.add(state, "saga", Object.fromEntries(sagas.map((s) => [s.title, s.id])))
            .name("Saga")
            .onChange((id: string) => openSaga(id));
        if (matchMedia("(max-width: 600px)").matches) gui.close(); // on phones the open menu covers the title
        return openSaga(state.saga, params.get("person"));
    })
    .catch((e) => {
        title.textContent = `Could not load saga list: ${(e as Error).message}`;
        console.error(e);
    });

// --- Frame loop -----------------------------------------------------------------------------------------------------
// Dev-only hook for browser tests to read camera and node state; stripped from production builds.
if (import.meta.env.DEV) Object.assign(window, { __ft: { camera, controls, graph } });

let last = 0;
renderer.setAnimationLoop((now) => {
    const dt = last ? Math.min((now - last) / 1000, 0.1) : 1 / 60; // seconds; clamped so a backgrounded tab can't jump
    last = now;
    stepGraph(camera);
    stepCamera(dt, () => (graph.graphData().nodes.length ? graph.getGraphBbox() : null));
    renderer.render(scene, camera);
});
