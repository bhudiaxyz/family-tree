import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";
import { RoomEnvironment } from "three/addons/environments/RoomEnvironment.js";
import ThreeForceGraph from "three-forcegraph";
import SpriteText from "three-spritetext";
import GUI from "lil-gui";
import type { Tree } from "./data/schema.ts";
import { listSagas, loadSaga } from "./data/source.ts";

type Node = { id: string; name?: string; house?: string; x?: number; y?: number; z?: number };
type Link = { source: string; target: string; kind: "spouse" | "child"; label: string };
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

const graph = new ThreeForceGraph<Node, Link>()
    .dagMode("td")
    .dagLevelDistance(40)
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
        g.add(new THREE.Mesh(personGeo, mat));
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

// Sibling lines + labels live outside the graph data (as links they'd break the generation layering)
// and are repositioned from the live node positions every frame.
const siblings = new THREE.Group();
graph.add(siblings);
let siblingPairs: [Node, Node][] = [];
let siblingLines: THREE.LineSegments;
let siblingLabels: SpriteText[] = [];

function load(t: Tree) {
    tree = t;
    // Union ("family") nodes sit between parents and children so the graph stays acyclic for dagMode.
    const nodes: Node[] = Object.entries(t.people).map(([id, p]) => ({ id, ...p }));
    const links: Link[] = [];
    const pairs: [string, string][] = [];
    t.families.forEach((f, i) => {
        const u = `family${i}`;
        nodes.push({ id: u });
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
    title.textContent = t.title;
    author.textContent = t.author;
    controls.reset();
    autoFit = true;
}

// Frame the whole tree while the layout settles; the first user drag/zoom hands control back.
let autoFit = true;
function fitCamera() {
    const { x, y, z } = graph.getGraphBbox();
    const center = new THREE.Vector3((x[0] + x[1]) / 2, (y[0] + y[1]) / 2, (z[0] + z[1]) / 2);
    const radius = Math.hypot(x[1] - x[0], y[1] - y[0], z[1] - z[0]) / 2;
    const fov = THREE.MathUtils.degToRad(camera.fov) / 2;
    const dist = (radius / Math.sin(Math.min(fov, Math.atan(Math.tan(fov) * camera.aspect)))) * 0.85;
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

const camera = new THREE.PerspectiveCamera(60, innerWidth / innerHeight, 1, 5000);
camera.position.set(0, 0, 320);
const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;
controls.saveState();
controls.addEventListener("start", () => (autoFit = false));

const title = document.getElementById("title")!;
const author = document.getElementById("author")!;

// Ignore a slow response if the user has already picked another saga.
let request = 0;
async function select(id: string) {
    const mine = ++request;
    title.textContent = "Loading…";
    author.textContent = "";
    try {
        const t = await loadSaga(id);
        if (mine === request) load(t);
    } catch (e) {
        if (mine === request) title.textContent = `Could not load saga: ${(e as Error).message}`;
        console.error(e);
    }
}

Promise.all([listSagas(), fontsReady])
    .then(([sagas]) => {
        const state = { saga: sagas[0].id };
        new GUI({ title: "Family tree" })
            .add(state, "saga", Object.fromEntries(sagas.map((s) => [s.title, s.id])))
            .name("Saga")
            .onChange(select);
        return select(state.saga);
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

renderer.setAnimationLoop(() => {
    graph.tickFrame();
    if (siblingLines) updateSiblings();
    if (autoFit && graph.graphData().nodes.length) fitCamera();
    controls.update();
    renderer.render(scene, camera);
});
