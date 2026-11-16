import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";
import { RoomEnvironment } from "three/addons/environments/RoomEnvironment.js";
import ThreeForceGraph from "three-forcegraph";
import SpriteText from "three-spritetext";
import GUI from "lil-gui";
import type { SagaIndexEntry, Tree } from "./data/schema.ts";
import { listSagas, loadSaga } from "./data/source.ts";
import { generations } from "./generations.ts";
import { forceZ } from "d3-force-3d";

type Node = { id: string; name?: string; house?: string; x?: number; y?: number; z?: number; fy?: number };
// The library swaps link source/target ids for node objects once the simulation starts.
type End = string | Node;
type Link = { source: End; target: End; kind: "spouse" | "child"; label: string };
const endId = (e: End) => (typeof e === "string" ? e : e.id);
type P = { x?: number; y?: number; z?: number };

let tree: Tree;
const role = (id: string, m: string, f: string) => (tree.people[id].sex === "m" ? m : f);

// Must match the Google Fonts families loaded in index.html.
const DISPLAY_FONT = '"Roboto Condensed", "Arial Narrow", Arial, sans-serif';
const BODY_FONT = 'Roboto, "Helvetica Neue", Arial, sans-serif';

// SpriteText rasterises to a canvas once, so the web fonts must be ready before any label is built.
// Capped wait: if the font CDN is slow or blocked, carry on with the fallback fonts.
const fontsReady = Promise.race([
    Promise.all(["700 16px 'Roboto Condensed'", "500 16px Roboto"].map((f) => document.fonts.load(f))),
    new Promise((r) => setTimeout(r, 3000)),
]);

const linkLabel = (text: string, color: string) => {
    const s = new SpriteText(text, 2, color);
    s.fontFace = BODY_FONT;
    s.fontWeight = "500";
    s.backgroundColor = "rgba(7,7,10,.7)";
    s.padding = 0.6;
    return s;
};
const midpoint = (obj: THREE.Object3D, a: P, b: P) =>
    obj.position.set((a.x! + b.x!) / 2, (a.y! + b.y!) / 2, (a.z! + b.z!) / 2);

const personGeo = new THREE.SphereGeometry(4, 48, 24);
const unionGeo = new THREE.SphereGeometry(1.2, 12, 6);
const unionMat = new THREE.MeshBasicMaterial({ color: 0xffffff });
const siblingMat = new THREE.LineDashedMaterial({ color: 0x5f8f7a, dashSize: 2, gapSize: 1.5 });

// Vertical gap between generations. Each node's height is pinned (fy) from generations(), instead of dagMode,
// which measured depth from roots and pushed married-in spouses to the top row.
const GEN_GAP = 80;

const graph = new ThreeForceGraph<Node, Link>()
    .nodeThreeObject((n) => {
        if (!n.name) return new THREE.Mesh(unionGeo, unionMat);
        const color = tree.houseColors[n.house!] ?? "#888";
        const g = new THREE.Group();
        // Clearcoat gives a sharp highlight over a softer base, which reads as a rounded, glossy surface.
        const mat = new THREE.MeshPhysicalMaterial({
            color,
            roughness: 0.45,
            metalness: 0.1,
            clearcoat: 1,
            clearcoatRoughness: 0.15,
        });
        const sphere = new THREE.Mesh(personGeo, mat);
        sphere.userData.personId = n.id; // picked by the raycaster for hover/click
        g.add(sphere);
        const label = new SpriteText(n.name, 4, "#e8dcc1");
        label.fontFace = DISPLAY_FONT;
        label.fontWeight = "700";
        label.position.y = 8;
        g.add(label);
        return g;
    })
    .linkColor((l) => (l.kind === "spouse" ? "#c9ad73" : "#667"))
    .linkWidth(0.6)
    .linkDirectionalParticles((l) => (l.kind === "child" ? 2 : 0))
    .linkDirectionalParticleWidth(1.2)
    .linkThreeObjectExtend(true)
    .linkThreeObject((l) => linkLabel(l.label, l.kind === "spouse" ? "#e6cf95" : "#b8b8c8"))
    .linkPositionUpdate((label, { start, end }) => {
        midpoint(label, start, end);
        return false; // still let the library position the default line
    });
// Unbounded repulsion drives disconnected families apart forever; cap its range so the tree stays compact.
graph.d3Force("charge")!.distanceMax(120);

// Depth for parallax: pull each house towards its own z plane so the tree has real near/far layers. Panning then
// shifts near families across the screen faster than distant ones (true perspective parallax, not a faked offset).
// Houses alternate front/back of centre; depth is a pull (strength < 1), so links and repulsion still shape it.
const DEPTH = 240; // front-to-back spread of house planes, in world units
let houseZ = new Map<string, number>();
graph.d3Force(
    "depth",
    forceZ<Node>((n) => (n.house ? (houseZ.get(n.house) ?? 0) : 0)).strength((n) => (n.house ? 0.08 : 0.02))
);

// Sibling lines + labels live outside the graph data (as links they'd break the generation layering)
// and are repositioned from the live node positions every frame.
const siblings = new THREE.Group();
graph.add(siblings);
let siblingPairs: [Node, Node][] = [];
let siblingLines: THREE.LineSegments;
let siblingLabels: SpriteText[] = [];

function load(t: Tree) {
    tree = t;
    clearSelection();
    // Pin each generation to its own height; union nodes sit halfway between parents and children.
    const gen = generations(t);
    const rows = Math.max(...gen.values());
    // Spread house planes evenly over DEPTH, ordered by house size so the biggest families sit near the middle.
    const houses = Object.keys(t.houseColors);
    const size = (h: string) => Object.values(t.people).filter((p) => p.house === h).length;
    const byMiddle = [...houses].sort((a, b) => size(b) - size(a));
    houseZ = new Map(
        byMiddle.map((h, i) => {
            const k = houses.length > 1 ? i / (houses.length - 1) : 0.5;
            const side = i % 2 ? -1 : 1; // alternate in front of / behind the centre
            return [h, side * k * (DEPTH / 2)];
        })
    );
    const y = (g: number) => (rows / 2 - g) * GEN_GAP;
    const nodes: Node[] = Object.entries(t.people).map(([id, p]) => ({ id, ...p, fy: y(gen.get(id)!) }));
    const links: Link[] = [];
    const pairs: [string, string][] = [];
    t.families.forEach((f, i) => {
        const u = `family${i}`;
        const pg = f.parents.length ? gen.get(f.parents[0])! : Math.min(...f.children.map((c) => gen.get(c)!)) - 1;
        nodes.push({ id: u, fy: y(pg + 0.5) });
        const hasKids = f.children.length > 0;
        const [by, of] = f.adoptive ? ["adoptive ", "adopted "] : ["", ""];
        for (const p of f.parents) {
            const label = hasKids ? by + role(p, "father", "mother") : role(p, "husband", "wife");
            links.push({ source: p, target: u, kind: "spouse", label });
        }
        for (const c of f.children)
            links.push({ source: u, target: c, kind: "child", label: of + role(c, "son", "daughter") });
        // Chain consecutive siblings rather than all pairs, to keep large families readable.
        for (let k = 1; k < f.children.length; k++) pairs.push([f.children[k - 1], f.children[k]]);
    });

    const byId = new Map(nodes.map((n) => [n.id, n]));
    siblingPairs = pairs.map(([a, b]) => [byId.get(a)!, byId.get(b)!]);
    siblings.traverse((o) => (o as SpriteText).material?.dispose());
    siblings.clear();
    const geo = new THREE.BufferGeometry();
    geo.setAttribute("position", new THREE.Float32BufferAttribute(siblingPairs.length * 6, 3));
    siblingLines?.geometry.dispose();
    siblingLines = new THREE.LineSegments(geo, siblingMat);
    siblingLabels = pairs.map(([a, b]) => {
        const sa = t.people[a].sex;
        const text = sa === t.people[b].sex ? role(a, "brothers", "sisters") : "brother & sister";
        return linkLabel(text, "#8fc4ab");
    });
    siblings.add(siblingLines, ...siblingLabels);

    graph.graphData({ nodes, links });
    // Rebuild the people list used by the search box.
    names.replaceChildren(
        ...Object.values(t.people)
            .map((p) => p.name)
            .sort()
            .map((n) => Object.assign(document.createElement("option"), { value: n }))
    );
    search.value = "";
    title.textContent = t.title;
    author.textContent = t.author;
    controls.reset();
    autoFit = true;
}

// --- Highlight: hovering or selecting a person dims everyone outside their direct line ------------------------
// Line = the person, all ancestors and descendants, plus spouses of the person (so their marriages stay visible).
function lineage(id: string): Set<string> {
    const keep = new Set([id]);
    const walk = (start: string, up: boolean) => {
        const stack = [start];
        while (stack.length) {
            const cur = stack.pop()!;
            for (const f of tree.families) {
                const from = up ? f.children : f.parents;
                const to = up ? f.parents : f.children;
                if (!from.includes(cur)) continue;
                for (const next of to) if (!keep.has(next)) (keep.add(next), stack.push(next));
            }
        }
    };
    walk(id, true);
    walk(id, false);
    for (const f of tree.families) if (f.parents.includes(id)) f.parents.forEach((p) => keep.add(p));
    return keep;
}

let focus: Set<string> | null = null; // people in the highlighted line, or null for "show everything"
const DIM = 0.12;

// Opacity for a link given the focused line. Union nodes count as "in" when any of their parents/children are.
function applyFocus() {
    const { nodes, links } = graph.graphData();
    const unionIn = new Set<string>();
    if (focus)
        for (const l of links) {
            const s = endId(l.source);
            const tg = endId(l.target);
            if ((l.kind === "spouse" && focus.has(s)) || (l.kind === "child" && focus.has(tg)))
                unionIn.add(l.kind === "spouse" ? tg : s);
        }
    const on = (id: string) => !focus || focus.has(id) || unionIn.has(id);
    for (const n of nodes) setOpacity((n as { __threeObj?: THREE.Object3D }).__threeObj, on(n.id) ? 1 : DIM);
    for (const l of links) {
        const lit = on(endId(l.source)) && on(endId(l.target));
        setOpacity((l as { __lineObj?: THREE.Object3D }).__lineObj, lit ? 1 : DIM);
    }
    siblingPairs.forEach(([a, b], i) => setOpacity(siblingLabels[i], on(a.id) && on(b.id) ? 1 : DIM));
    (siblingLines.material as THREE.Material).opacity = focus ? DIM : 1;
    (siblingLines.material as THREE.Material).transparent = true;
}

// Labels are faded every frame by fadeLabels(), so for them only record the factor; meshes/lines get it directly.
function setOpacity(obj: THREE.Object3D | undefined, opacity: number) {
    obj?.traverse((o) => {
        if (o instanceof SpriteText) return void (o.userData.dim = opacity);
        const m = (o as THREE.Mesh).material as THREE.Material | undefined;
        if (!m || m === unionMat) return;
        m.transparent = true;
        m.opacity = opacity * ((m.userData.baseOpacity ??= m.opacity) as number);
    });
}

// --- Renderer, scene, camera -------------------------------------------------------------------------------
const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
renderer.setSize(innerWidth, innerHeight);
renderer.toneMapping = THREE.ACESFilmicToneMapping;
document.body.appendChild(renderer.domElement);

const scene = new THREE.Scene();
scene.add(graph);
// Environment map supplies soft reflections; dim fill + strong key keeps a visible dark side; rim light outlines edges.
scene.environment = new THREE.PMREMGenerator(renderer).fromScene(new RoomEnvironment()).texture;
scene.environmentIntensity = 0.35;
scene.add(new THREE.HemisphereLight(0xfff4e0, 0x10101a, 0.4));
const key = new THREE.DirectionalLight(0xfff1d6, 2.5);
key.position.set(1, 2, 3);
const rim = new THREE.DirectionalLight(0x8fb4ff, 1.5);
rim.position.set(-2, 1, -3);
scene.add(key, rim);

// 50° keeps perspective (and so pan parallax) visible without fish-eye distortion at the tree edges.
const camera = new THREE.PerspectiveCamera(50, innerWidth / innerHeight, 1, 5000);
camera.position.set(0, 0, 320);
const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;
controls.saveState();
// Any drag/zoom/pan hands the camera back to the user: stop both the auto-fit and any fly-to in progress.
controls.addEventListener("start", () => ((autoFit = false), (flight = null)));

// --- Panning with arrow keys and the on-screen pad ------------------------------------------------------------
// Both feed the same "held directions" set; the frame loop pans smoothly while any is held (instead of the
// OrbitControls key handler, which steps once per key-repeat). Shift/Ctrl/Cmd + arrows rotate instead of pan.
const held = new Set<string>();
const PAN_PX = 9; // pixels of screen-space pan per frame
const DIRS: Record<string, [number, number]> = { left: [1, 0], right: [-1, 0], up: [0, 1], down: [0, -1] };
const KEY_DIR: Record<string, string> = { ArrowLeft: "left", ArrowRight: "right", ArrowUp: "up", ArrowDown: "down" };
const takeCamera = () => ((autoFit = false), (flight = null));
function stepPan() {
    if (!held.size) return;
    let dx = 0;
    let dy = 0;
    for (const d of held) ((dx += DIRS[d][0] * PAN_PX), (dy += DIRS[d][1] * PAN_PX));
    controls.pan(dx, dy);
}
addEventListener("keydown", (e) => {
    const dir = KEY_DIR[e.key];
    if (!dir || isTyping()) return;
    e.preventDefault(); // stop the page scrolling
    takeCamera();
    if (e.shiftKey || e.ctrlKey || e.metaKey) {
        // Rotate around the target in small steps, as OrbitControls' own key handler does.
        const a = 0.05 * (dir === "left" || dir === "up" ? 1 : -1);
        const offset = camera.position.clone().sub(controls.target);
        const axis =
            dir === "left" || dir === "right"
                ? camera.up
                : new THREE.Vector3().crossVectors(camera.up, offset).normalize();
        camera.position.copy(controls.target).add(offset.applyAxisAngle(axis, a));
        return;
    }
    held.add(dir);
});
addEventListener("keyup", (e) => KEY_DIR[e.key] && held.delete(KEY_DIR[e.key]));
addEventListener("blur", () => held.clear()); // don't keep panning if the window loses focus mid-press
const isTyping = () => document.activeElement instanceof HTMLInputElement;

// Pad buttons: press-and-hold pans; pointer capture keeps it working when the finger slides off the button.
for (const btn of document.querySelectorAll<HTMLButtonElement>("#pad button[data-dir]")) {
    const dir = btn.dataset.dir!;
    btn.addEventListener("pointerdown", (e) => (btn.setPointerCapture(e.pointerId), takeCamera(), held.add(dir)));
    for (const ev of ["pointerup", "pointercancel", "lostpointercapture"])
        btn.addEventListener(ev, () => held.delete(dir));
}
document.querySelector<HTMLButtonElement>("#pad [data-action=fit]")!.onclick = () => (
    (flight = null),
    (autoFit = true)
);

// --- Picking --------------------------------------------------------------------------------------------------
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

let selected: string | null = null;
let hovered: string | null = null;
function refreshFocus() {
    const id = selected ?? hovered;
    focus = id ? lineage(id) : null;
    applyFocus();
}
function clearSelection() {
    selected = hovered = null;
    focus = null;
    panel.hidden = true;
}

// Distinguish a click from an orbit drag: only treat it as a click if the pointer barely moved. downAt is reset on
// every pointerup, so a click that started on the panel or search box can never be mistaken for a canvas click.
let downAt: [number, number] | null = null;
renderer.domElement.addEventListener("pointerdown", (e) => (downAt = [e.clientX, e.clientY]));
addEventListener("pointerup", () => setTimeout(() => (downAt = null)));
renderer.domElement.addEventListener("pointermove", (e) => {
    if (e.pointerType !== "mouse" || e.buttons) return; // hover is mouse-only; touch uses tap
    const id = pick(e);
    renderer.domElement.style.cursor = id ? "pointer" : "";
    if (id !== hovered) ((hovered = id), refreshFocus());
});
renderer.domElement.addEventListener("pointerup", (e) => {
    if (!downAt || Math.hypot(e.clientX - downAt[0], e.clientY - downAt[1]) > 5) return;
    const id = pick(e);
    if (id) select(id);
    else if (selected) deselect();
});

// --- Details panel ----------------------------------------------------------------------------------------------
function select(id: string, fly = false) {
    selected = id;
    refreshFocus();
    const p = tree.people[id];
    const rel = relatives(id);
    panelName.textContent = p.name;
    panelHouse.textContent = p.house;
    panelHouse.style.color = tree.houseColors[p.house] ?? "";
    panelList.replaceChildren(
        ...rel
            .map(([label, ids]) => {
                const dt = Object.assign(document.createElement("dt"), { textContent: label });
                const dd = document.createElement("dd");
                ids.forEach((rid, i) => {
                    if (i) dd.append(", ");
                    const a = Object.assign(document.createElement("a"), {
                        href: "#",
                        textContent: tree.people[rid].name,
                    });
                    a.onclick = (ev) => (ev.preventDefault(), select(rid, true));
                    dd.append(a);
                });
                return [dt, dd];
            })
            .flat()
    );
    panel.hidden = false;
    search.value = p.name; // keep the search box showing who is selected
    writeUrl();
    if (fly) flyTo(id);
}
// Single exit path for every way of letting go of a person: close button, Escape, empty click, clearing the search.
function deselect() {
    selected = null;
    flight = null; // stop any fly-to still heading for that person
    autoFit = true; // ease back to the whole tree, so the orbit pivot is no longer the last person (drag cancels)
    panel.hidden = true;
    search.value = "";
    refreshFocus();
    writeUrl();
}

function relatives(id: string): [string, string[]][] {
    const out = new Map<string, Set<string>>();
    const add = (label: string, rid: string) => (out.get(label) ?? out.set(label, new Set()).get(label)!).add(rid);
    for (const f of tree.families) {
        if (f.children.includes(id)) {
            f.parents.forEach((p) => add(f.adoptive ? "Adoptive parents" : "Parents", p));
            f.children.filter((c) => c !== id).forEach((c) => add(f.adoptive ? "Foster siblings" : "Siblings", c));
        }
        if (f.parents.includes(id)) {
            f.parents.filter((p) => p !== id).forEach((p) => add("Spouse", p));
            f.children.forEach((c) => add(f.adoptive ? "Adopted children" : "Children", c));
        }
    }
    return [...out].map(([k, v]) => [k, [...v]]);
}

// --- Fly-to: ease the camera to look at a person from a short distance --------------------------------------------
// Follows the node's live position (the layout may still be settling) and ends after ~1 s; it never keeps hold of
// the camera — the first user drag cancels it (see controls "start").
let flight: { node: Node; dir: THREE.Vector3; t: number } | null = null;
function flyTo(id: string) {
    const node = graph.graphData().nodes.find((x) => x.id === id);
    if (!node || node.x === undefined) return;
    autoFit = false;
    flight = { node, dir: camera.position.clone().sub(controls.target).normalize(), t: 0 };
}
function stepFlight() {
    if (!flight) return;
    const { node, dir } = flight;
    flight.t = Math.min(1, flight.t + 1 / 60);
    const k = 0.04 + 0.2 * flight.t ** 2; // gentle start, firm finish
    const target = new THREE.Vector3(node.x, node.y, node.z);
    controls.target.lerp(target, k);
    camera.position.lerp(target.clone().addScaledVector(dir, 90), k);
    if (flight.t === 1) flight = null;
}

// Frame the whole tree while the layout settles; the first user drag/zoom hands control back.
let autoFit = true;
// Fits the tree's width and height to the view from the front. Depth (z) is ignored on purpose: it doesn't change
// what fits on screen, and including it would push the camera back and flatten the pan parallax.
function fitCamera() {
    const { x, y, z } = graph.getGraphBbox();
    const center = new THREE.Vector3((x[0] + x[1]) / 2, (y[0] + y[1]) / 2, (z[0] + z[1]) / 2);
    const halfFov = THREE.MathUtils.degToRad(camera.fov) / 2;
    const fitH = (y[1] - y[0]) / 2 / Math.tan(halfFov);
    const fitW = (x[1] - x[0]) / 2 / (Math.tan(halfFov) * camera.aspect);
    const dist = Math.max(fitH, fitW) * 1.08 + (z[1] - center.z); // margin, and measured from the front face
    controls.target.lerp(center, 0.1);
    camera.position.lerp(center.clone().add(new THREE.Vector3(0, 0, dist)), 0.1);
}

function updateSiblings() {
    const pos = siblingLines.geometry.attributes.position as THREE.BufferAttribute;
    siblingPairs.forEach(([a, b], i) => {
        if (a.x === undefined || b.x === undefined) return;
        pos.setXYZ(i * 2, a.x, a.y!, a.z!);
        pos.setXYZ(i * 2 + 1, b.x, b.y!, b.z!);
        midpoint(siblingLabels[i], a, b);
    });
    pos.needsUpdate = true;
    siblingLines.geometry.computeBoundingSphere();
    siblingLines.computeLineDistances();
}

const title = document.getElementById("title")!;
const author = document.getElementById("author")!;
const panel = document.getElementById("panel")!;
const panelName = document.getElementById("panel-name")!;
const panelHouse = document.getElementById("panel-house")!;
const panelList = document.getElementById("panel-list")!;
document.getElementById("panel-close")!.onclick = deselect;

// --- Search: type a name, pick it from the list (or press Enter) to select and fly to that person ----------------
const search = document.getElementById("search") as HTMLInputElement;
const names = document.getElementById("names")!;
const byName = (q: string) => {
    const s = q.trim().toLowerCase();
    if (!s) return null;
    const entries = Object.entries(tree.people);
    return (entries.find(([, p]) => p.name.toLowerCase() === s) ??
        entries.find(([, p]) => p.name.toLowerCase().includes(s)))?.[0];
};
search.addEventListener("change", () => {
    const id = byName(search.value);
    if (id) select(id, true);
});
// The clear (x) button and deleting the text fire `input`, not `change` (which waits for blur): clear the selection
// immediately so the panel, highlight and URL all let go of the last search.
search.addEventListener("input", () => {
    if (!search.value && selected) deselect();
});
search.addEventListener("keydown", (e) => {
    if (e.key !== "Escape") return;
    search.value = "";
    search.blur();
    if (selected) deselect();
});
addEventListener("keydown", (e) => {
    if (e.key === "/" && document.activeElement !== search) (e.preventDefault(), search.focus());
    if (e.key === "Escape" && selected) deselect();
});

// --- Shareable links: ?saga=<id>&person=<id> ----------------------------------------------------------------------
const params = new URLSearchParams(location.search);
let sagaId = "";
function writeUrl() {
    const q = new URLSearchParams({ saga: sagaId });
    if (selected) q.set("person", selected);
    history.replaceState(null, "", `?${q}`);
}

// Ignore a slow response if the user has already picked another saga.
let request = 0;
async function openSaga(id: string, person?: string | null) {
    const mine = ++request;
    sagaId = id;
    title.textContent = "Loading…";
    author.textContent = "";
    try {
        const t = await loadSaga(id);
        if (mine !== request) return;
        load(t);
        writeUrl();
        // Wait for the layout to place nodes before selecting a linked person and flying to them.
        if (person && t.people[person]) setTimeout(() => mine === request && select(person, true), 1500);
    } catch (e) {
        if (mine === request) title.textContent = `Could not load saga: ${(e as Error).message}`;
        console.error(e);
    }
}

Promise.all([listSagas(), fontsReady])
    .then(([sagas]: [SagaIndexEntry[], unknown]) => {
        const wanted = params.get("saga");
        const state = { saga: sagas.some((s) => s.id === wanted) ? wanted! : sagas[0].id };
        const gui = new GUI({ title: "Sagas" });
        gui.add(state, "saga", Object.fromEntries(sagas.map((s) => [s.title, s.id])))
            .name("Saga")
            .onChange((id: string) => openSaga(id));
        // On phones the open menu covers the title; start it collapsed (tap "Sagas" to open).
        if (matchMedia("(max-width: 600px)").matches) gui.close();
        return openSaga(state.saga, params.get("person"));
    })
    .catch((e) => {
        title.textContent = `Could not load saga list: ${(e as Error).message}`;
        console.error(e);
    });

addEventListener("resize", () => {
    camera.aspect = innerWidth / innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(innerWidth, innerHeight);
});

// --- Label clutter: fade relationship labels out with distance, so only nearby ones are readable ---------------
// Fully visible within NEAR, gone beyond FAR (world units from the camera). Names are always shown.
const NEAR = 110;
const FAR = 240;
const tmp = new THREE.Vector3();
function fadeLabels() {
    const fade = (s: SpriteText) => {
        const d = camera.position.distanceTo(s.getWorldPosition(tmp));
        const k = keepLabel(s) ? 1 : THREE.MathUtils.clamp((FAR - d) / (FAR - NEAR), 0, 1);
        s.material.transparent = true;
        s.material.opacity = (s.userData.dim ?? 1) * k; // dim = highlight factor set by applyFocus()
        s.visible = s.material.opacity > 0.02;
    };
    for (const l of graph.graphData().links) {
        const label = (l as { __lineObj?: THREE.Object3D }).__lineObj?.children[1];
        if (label instanceof SpriteText) fade(label);
    }
    siblingLabels.forEach(fade);
}
// Relationship labels on the highlighted line stay readable at any distance, so a selection is never invisible.
const keepLabel = (s: SpriteText) => focus !== null && (s.userData.dim ?? 1) === 1;

// Dev-only hook for browser tests to read camera state; stripped from production builds.
if (import.meta.env.DEV) Object.assign(window, { __ft: { camera, controls, graph } });

renderer.setAnimationLoop(() => {
    graph.tickFrame();
    if (siblingLines) updateSiblings();
    if (autoFit && graph.graphData().nodes.length) fitCamera();
    stepFlight();
    stepPan();
    fadeLabels();
    controls.update();
    renderer.render(scene, camera);
});
