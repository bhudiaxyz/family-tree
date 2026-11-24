// Sagas: loading and showing a saga (or an imported tree), the nebula sky behind it, and the menu (lil-gui).
//
// What it does: `start()` reads the URL, builds the menu (saga picker, glow, guides, 2D, 2D right-angled links,
// Settings folder (glow, guides, nebula), Houses and
// Pinned folders) and opens the first saga; `openSaga` loads one; `showImported` shows a GEDCOM file.
// Usage: main.ts calls start() and rebuildAfterContextLoss(); files.ts calls showImported().
// Notes: `show()` resets all per-tree state (selection, relationship, group, collapsed, trail, card, panel, palette)
// before building the new tree, then fits (or restores the remembered view) and writes the URL. `openSaga` ignores a
// slow response if another saga was picked since. A linked person or house is applied 1.5 s later, once the layout
// has placed nodes. `afterRebuild()` re-applies tags, folds, highlight and panel two animation frames after a
// re-layout, because the graph library only builds its objects on its next tick. The sky bake is deferred two frames
// so the tree draws first.

import GUI from "lil-gui";
import { fitTree, setFlatView } from "../render/camera.ts";
import type { SagaIndexEntry, Tree } from "../data/schema.ts";
import { listSagas, loadSaga, sagaTitle } from "../data/source.ts";
import { houseNamed } from "../tree/search.ts";
import { setFlat, setGuidesVisible, setRightAngles, showTree } from "../graph/graph.ts";
import { fontsReady, resetBadges } from "../render/labels.ts";
import { bakeNebula } from "../render/nebula.ts";
import { paletteFor, usePalette } from "../render/palettes.ts";
import { applyScenePalette, controls, glow, renderer, setGlow, setSky, warmUp } from "../render/scene.ts";
import { setPerson, setSuggestions } from "./suggest.ts";

import {
    author,
    el,
    IMPORTED,
    onPopState,
    panel,
    refreshHighlight,
    relA,
    relB,
    search,
    state,
    title,
    writeUrl,
} from "./state.ts";

import { mountLegend, setHouse, setLegend } from "./legend.ts";
import { onPinsChanged, pinned, rememberView, restoreView } from "./navigate.ts";
import { clearTrail, onHistoryBack, refreshPanel, relativeToId, select, setRelativeTo } from "./panel.ts";
import { resetCard } from "./picking.ts";
import { openRelate, resetRelate } from "./relate.ts";
import { refreshFolds, setFocus } from "./visibility.ts";

// The manifest (sagas.json), keyed by id. The URL and the menu only carry an id; the entry adds the category that
// the data file's path needs (data/<category>/<id>.json, see sagaPath in schema.ts).
const sagaIndex = new Map<string, SagaIndexEntry>();

let request = 0; // ignore a slow response if the user has already picked another saga

// --- Nebula sky: baked per saga, a frame after the tree appears -------------------------------------------------
// Baking takes a few hundred ms on a phone. Doing it in the next frame lets the new tree draw first (against the flat
// vignette), then the sky fades in instead of the saga switch feeling stuck. A newer request supersedes an older one.
let skyRequest = 0;

let nebulaOn = true;

// --- Pinned people: a menu folder listing the people starred in the panel ---------------------------------------
const pinList = el("ul", { id: "pin-list" });

let pinFolder: GUI | null = null;

async function openSaga(id: string, person?: string | null, withPerson?: string | null, house?: string | null) {
    const mine = ++request;
    rememberView(state.sagaId); // so switching back here returns to this view
    state.sagaId = id;
    title.textContent = "Loading…";
    author.textContent = "";
    try {
        const entry = sagaIndex.get(id);
        if (!entry) throw new Error(`no saga "${id}" in sagas.json`);
        const t = await loadSaga(entry);
        if (mine !== request) return;
        show(t);
        // Give the layout a moment to place nodes (and build their objects, which a highlight dims) before selecting
        // a linked person and flying to them, or lighting a linked house. A person takes precedence over a house.
        const linkedHouse = houseNamed(t, house);
        if ((person && t.people[person]) || linkedHouse)
            setTimeout(() => {
                if (mine !== request) return;
                if (person && t.people[person]) {
                    if (withPerson && t.people[withPerson]) {
                        setPerson(relA, person);
                        setPerson(relB, withPerson);
                        openRelate();
                    } else select(person, true);
                } else setHouse(linkedHouse);
            }, 1500);
    } catch (e) {
        if (mine === request) title.textContent = `Could not load saga: ${(e as Error).message}`;
        console.error(e);
    }
}

/** Show a tree loaded from a GEDCOM file, cancelling any saga load still in flight. */
export function showImported(t: Tree): void {
    request++;
    state.sagaId = IMPORTED;
    show(t);
}

/** The id the sky is seeded from: the saga id, or the imported file's title. */
const skyId = () => (state.sagaId === IMPORTED ? `import:${state.tree?.title ?? ""}` : state.sagaId);

function show(t: Tree) {
    state.tree = t;
    state.selected = state.hovered = null;
    state.relPair = state.relStep = null;
    state.group = null;
    state.collapsed.clear();
    clearTrail();
    resetCard();
    panel.hidden = true;
    setPerson(search, null);
    resetRelate();
    setRelativeTo(null);
    // Theme first: materials, labels and badges pick up their colours when built, so the palette must be active
    // before showTree() creates them. An imported file uses the default theme (keyed by its own name for the sky).
    usePalette(paletteFor(state.sagaId === IMPORTED ? "" : state.sagaId));
    resetBadges(); // badge textures are cached per house; drop them so they redraw in the new theme's ink/outline
    applyScenePalette();
    showTree(t, state.siblings);
    void warmUp(); // compile the new tree's shaders before it's drawn (see scene.ts), so it appears without a stall
    setLegend(t);
    refreshFolds();
    setFocus("off");
    scheduleSky(skyId());
    setSuggestions(t);
    title.textContent = t.title;
    author.textContent = t.author;
    controls.reset();
    if (!restoreView(state.sagaId)) fitTree(true); // back to where you were, else the tree (a tall one from its top)
    showPins();
    writeUrl();
}

/** Rebuild the tree and sky after the GPU context was restored (every GPU resource died with it). */
export function rebuildAfterContextLoss(): void {
    resetBadges();
    applyScenePalette();
    if (!state.tree) return;
    showTree(state.tree, state.siblings);
    void warmUp(); // every program died with the context
    afterRebuild(); // the new objects start lit and untagged
    scheduleSky(skyId());
}

/**
 * Re-apply the per-person state to a rebuilt tree's new objects: collapse and "relative to" tags, the highlight, and
 * the panel (whose generation row may have changed). The library only builds those objects on its next tick, in the
 * frame loop, so this waits two frames; done straight away it found no objects and everything came back blank.
 */
function afterRebuild(): void {
    const tree = state.tree;
    afterTwoFrames(() => {
        if (state.tree !== tree) return; // another saga opened meanwhile
        setRelativeTo(relativeToId());
        refreshFolds();
        refreshHighlight();
        if (state.selected) refreshPanel();
    });
}

/** Run `fn` two frames from now: after the library's next tick has built objects, and after the tree has drawn. */
const afterTwoFrames = (fn: () => void) => requestAnimationFrame(() => requestAnimationFrame(fn));

function scheduleSky(id: string) {
    const mine = ++skyRequest;
    if (!nebulaOn) return setSky(null);
    afterTwoFrames(() => {
        if (mine !== skyRequest || !nebulaOn) return;
        try {
            setSky(bakeNebula(renderer, id));
        } catch (e) {
            console.warn("Nebula bake failed; using the plain background.", e); // e.g. float targets unsupported
            setSky(null);
        }
    });
}

// --- Start-up: read the URL, build the menu, open the first saga -----------------------------------------------
export function start(): void {
    onPopState(onHistoryBack); // the browser's Back / Forward walks the people visited (see panel.ts)
    Promise.all([listSagas(), fontsReady])
        .then(([sagas]: [SagaIndexEntry[], unknown]) => {
            for (const s of sagas) sagaIndex.set(s.id, s);
            const params = new URLSearchParams(location.search);
            const wanted = params.get("saga");
            const first = sagas.some((s) => s.id === wanted) ? wanted! : sagas[0].id;
            buildMenu(sagas, first, params);
            return openSaga(first, params.get("person"), params.get("with"), params.get("house"));
        })
        .catch((e) => {
            title.textContent = `Could not load saga list: ${(e as Error).message}`;
            console.error(e);
        });
}

/** Switch between 2D and 3D (the D key), as the menu's checkbox does. Set once the menu is built. */
export let toggle2d = () => {};

function buildMenu(sagas: SagaIndexEntry[], first: string, params: URLSearchParams) {
    const gui = new GUI({ title: "Sagas" });
    // sagas.json has only ids, so the menu starts with ids as labels and takes each saga's title from its own file
    // as it arrives. Nothing waits for these: the first saga opens straight away (and its file is one of them).
    const names = new Map(sagas.map((s) => [s.id, s.id]));
    const menu = gui
        .add({ saga: first }, "saga", Object.fromEntries(sagas.map((s) => [s.id, s.id])))
        .name("Saga")
        .onChange((id: string) => openSaga(id));
    for (const s of sagas)
        sagaTitle(s)
            .then((title) => {
                names.set(s.id, title);
                menu.options(Object.fromEntries(sagas.map((x) => [names.get(x.id)!, x.id])));
            })
            .catch(() => {}); // an unreadable saga keeps its id as the label; opening it shows the error
    // 2D: the tree flattens onto its front plane (animated), the camera turns to face it, rotation is disabled.
    // Comes from the URL (so links share it), not localStorage: no ?view=2d means 3D.
    const stored = (k: string, dflt: boolean) => (localStorage.getItem(k) ?? String(dflt)) === "true";
    const flat = { on: params.get("view") === "2d" };
    // In 2D, links as right-angled family-tree connectors (default) or straight lines. Remembered on this device, and
    // only offered while 2D is on, since 3D links are always straight.
    const links = { rightAngles: stored("ft.rightAngles", true) };
    setRightAngles(links.rightAngles);
    const set2d = (on: boolean) => {
        state.view2d = on;
        setFlat(on);
        setFlatView(on);
        rightAnglesItem.show(on);
        if (state.sagaId) writeUrl(); // at start-up openSaga writes it once the saga id is known
    };
    const twoD = gui.add(flat, "on").name("2D").onChange(set2d);
    toggle2d = () => twoD.setValue(!flat.on); // the D key: setValue updates the checkbox and calls set2d
    // Its own row, just under 2D (lil-gui has one control per row).
    const rightAnglesItem = gui
        .add(links, "rightAngles")
        .name("Right-angles")
        .onChange((on: boolean) => (setRightAngles(on), localStorage.setItem("ft.rightAngles", String(on))));
    set2d(flat.on);
    // Brothers and sisters always share a row (tree/generations.ts "together"); there's no longer a menu choice for it.
    // Display settings, in a folder that starts closed. Glow defaults off on touch devices (GPU/battery); all are
    // remembered between visits.
    const settings = gui.addFolder("Settings").close();
    const view = {
        glow: stored("ft.glow", glow),
        guides: stored("ft.guides", true),
        nebula: stored("ft.nebula", true),
    };
    setGlow(view.glow);
    setGuidesVisible(view.guides);
    nebulaOn = view.nebula;
    settings
        .add(view, "glow")
        .name("Glow")
        .onChange((on: boolean) => (setGlow(on), localStorage.setItem("ft.glow", String(on))));
    settings
        .add(view, "guides")
        .name("Generation guides")
        .onChange((on: boolean) => (setGuidesVisible(on), localStorage.setItem("ft.guides", String(on))));
    settings
        .add(view, "nebula")
        .name("Nebula sky")
        .onChange((on: boolean) => {
            nebulaOn = on;
            localStorage.setItem("ft.nebula", String(on));
            scheduleSky(skyId());
        });
    mountLegend(gui); // a collapsed "Houses" folder: click a house to light it up
    mountPins(gui); // a "Pinned" folder: the people starred in the panel, for this saga
    if (matchMedia("(max-width: 600px)").matches) gui.close(); // on phones the open menu covers the title
}

function mountPins(gui: GUI) {
    pinFolder = gui.addFolder("Pinned").close();
    pinFolder.$children.append(pinList);
    showPins();
}

function showPins() {
    const ids = pinned();
    pinFolder?.show(ids.length > 0);
    pinList.replaceChildren(
        ...ids.map((id) => {
            const li = document.createElement("li");
            const b = el("button", { textContent: state.tree!.people[id].name });
            b.onclick = () => select(id, true);
            li.append(b);
            return li;
        })
    );
}

onPinsChanged(showPins);
