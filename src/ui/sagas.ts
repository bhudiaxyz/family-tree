// Loading and showing a saga (or an imported tree), the nebula sky behind it, and the menu (lil-gui).
import GUI from "lil-gui";
import { fitTree, setFlatView } from "../camera.ts";
import type { SagaIndexEntry, Tree } from "../data/schema.ts";
import { listSagas, loadSaga, sagaTitle } from "../data/source.ts";
import { houseNamed } from "../family.ts";
import type { SiblingMode } from "../generations.ts";
import { setFlat, setGuidesVisible, showTree } from "../graph.ts";
import { fontsReady, resetBadges } from "../labels.ts";
import { bakeNebula } from "../nebula.ts";
import { paletteFor, usePalette } from "../palettes.ts";
import { applyScenePalette, controls, glow, renderer, setGlow, setSky } from "../scene.ts";
import { setPerson, setSuggestions } from "../suggest.ts";
import { author, el, panel, relA, relB, search, title } from "./dom.ts";
import { mountLegend, setHouse, setLegend } from "./legend.ts";
import { onPinsChanged, pinned, rememberView, restoreView } from "./navigate.ts";
import { clearTrail, onHistoryBack, refreshPanel, relativeToId, select, setRelativeTo } from "./panel.ts";
import { resetCard } from "./picking.ts";
import { openRelate, resetRelate } from "./relate.ts";
import { IMPORTED, refreshHighlight, state } from "./state.ts";
import { onPopState, writeUrl } from "./url.ts";
import { refreshFolds, setFocus } from "./visibility.ts";

// The manifest (sagas.json), keyed by id. The URL and the menu only carry an id; the entry adds the category that
// the data file's path needs (data/<category>/<id>.json, see sagaPath in schema.ts).
const sagaIndex = new Map<string, SagaIndexEntry>();

let request = 0; // ignore a slow response if the user has already picked another saga
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
    setLegend(t);
    refreshFolds();
    setFocus("off");
    scheduleSky(skyId());
    setSuggestions(t);
    title.textContent = t.title;
    author.textContent = t.author;
    controls.reset();
    if (!restoreView(state.sagaId)) fitTree(); // back to where you were in this saga, else the whole tree
    showPins();
    writeUrl();
}

/** Rebuild the tree and sky after the GPU context was restored (every GPU resource died with it). */
export function rebuildAfterContextLoss(): void {
    resetBadges();
    applyScenePalette();
    if (!state.tree) return;
    showTree(state.tree, state.siblings);
    afterRebuild(); // the new objects start lit and untagged
    scheduleSky(skyId());
}

/**
 * Re-lay the current tree with siblings together or apart (the menu toggle). The selection, highlight, collapsed
 * branches and relationship stay as they are; people glide to their new rows as the layout settles.
 */
function setSiblingMode(mode: SiblingMode): void {
    state.siblings = mode;
    if (state.sagaId) writeUrl();
    if (!state.tree) return;
    showTree(state.tree, mode);
    fitTree();
    afterRebuild();
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

// --- Nebula sky: baked per saga, a frame after the tree appears -------------------------------------------------
// Baking takes a few hundred ms on a phone. Doing it in the next frame lets the new tree draw first (against the flat
// vignette), then the sky fades in instead of the saga switch feeling stuck. A newer request supersedes an older one.
let skyRequest = 0;
let nebulaOn = true;
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
    // Display options. Glow defaults off on touch devices (GPU/battery); these are remembered between visits.
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
    // 2D: the tree flattens onto its front plane (animated), the camera turns to face it, rotation is disabled.
    // Comes from the URL (so links share it), not localStorage: no ?view=2d means 3D.
    const flat = { on: params.get("view") === "2d" };
    const set2d = (on: boolean) => {
        state.view2d = on;
        setFlat(on);
        setFlatView(on);
        if (state.sagaId) writeUrl(); // at start-up openSaga writes it once the saga id is known
    };
    set2d(flat.on);
    gui.add(flat, "on").name("2D").onChange(set2d);
    // Siblings together (default) puts brothers and sisters on one row; off keeps couples on one row instead. From
    // the URL like 2D (?siblings=apart), so a shared link shows the same layout.
    const layout = { together: params.get("siblings") !== "apart" };
    state.siblings = layout.together ? "together" : "apart";
    gui.add(layout, "together")
        .name("Siblings together")
        .onChange((on: boolean) => setSiblingMode(on ? "together" : "apart"));
    const sky = { nebula: stored("ft.nebula", true) };
    nebulaOn = sky.nebula;
    gui.add(sky, "nebula")
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

// --- Pinned people: a menu folder listing the people starred in the panel ---------------------------------------
const pinList = el("ul", { id: "pin-list" });
let pinFolder: GUI | null = null;
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
