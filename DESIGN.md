# Family Tree: Design and Architecture

## 1. Overview

The app turns a list of people and families into a 3D graph and draws it with three.js. It is a static site: saga data is fetched as JSON, and layout and rendering run in the browser.

```
public/data/*.json ──fetch──► src/data/source.ts ──► src/main.ts load() ──► three-forcegraph ──► three.js scene
 (or VITE_DATA_URL)            toTree(): tables→Tree     graph build        d3-force-3d          OrbitControls
                                     ▲
                         lil-gui "Saga" drop-down (from sagas.json)
```

## 2. Source layout

| File                     | Role                                                                                                                                                                                                          |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `index.html`             | Full-screen page; loads Roboto and Roboto Condensed from Google Fonts (`--fd` display, `--fb` body); the `#title` / `#author` header overlay and the dark lil-gui theme; loads `src/main.ts`.                 |
| `public/data/sagas.json` | Manifest: `{ id, title, work, author }` per saga. Sets the drop-down order; the first entry loads at startup.                                                                                                 |
| `public/data/<id>.json`  | One saga each (`got`, `fireblood`, `lotr`, `silmarillion`, `dune`, `potter`, `starwars`, `wot`, `stormlight`, `witcher`) as a `SagaRecord`: normalised tables plus `source` and `notes`.                      |
| `src/data/schema.ts`     | `SagaIndexEntry` and `SagaRecord` (the stored format), and `Tree` (the in-memory format the renderer uses).                                                                                                   |
| `src/data/source.ts`     | `listSagas()` and `loadSaga(id)` fetch from the data base URL. `toTree()` turns a `SagaRecord` into a `Tree`. This is the only file that knows where data comes from.                                         |
| `db/schema.sql`          | Relational tables matching `SagaRecord`, for a future database backend.                                                                                                                                       |
| `src/main.ts`            | `load(tree)` converts a tree to graph nodes/links and rebuilds the sibling overlay. Also configures the graph object, renderer, camera, lights, controls and GUI, and runs the frame loop.                    |
| `scripts/trees.test.mts` | `npm test`: checks every saga file. `sagas.json` matches the files, every house, person and family reference resolves, everyone is in a family, no family has more than two parents, and `toTree()` succeeds. |
| `vite.config.ts`         | Dev server port; splits `three` and the graph libraries into their own chunk.                                                                                                                                 |
| `tsconfig.json`          | Strict TypeScript, bundler module resolution, type-check only (`noEmit`). Vite does the transpiling.                                                                                                          |

## 3. Data model

### Stored format: `SagaRecord`

Each saga is stored as normalised tables, one array per table, so it maps one-to-one onto rows in [db/schema.sql](db/schema.sql):

| Array      | Row                        | SQL table       |
| ---------- | -------------------------- | --------------- |
| (top)      | `id, title, source{…}`     | `saga`          |
| `notes`    | string                     | `saga_note`     |
| `houses`   | `{ name, color }`          | `house`         |
| `people`   | `{ id, name, house, sex }` | `person`        |
| `families` | `{ id, adoptive }`         | `family`        |
| `members`  | `{ family, person, role }` | `family_member` |

`members` is the join table: one row per person per family, with `role` set to `parent` or `child`. Ids are scoped to the saga (the SQL primary keys are `(saga_id, id)`), so the same character id can appear in several sagas.

**Data source.** `source.ts` fetches `${base}/sagas.json` and `${base}/<id>.json`. `base` is `VITE_DATA_URL` if it is set at build time. Otherwise it is `${BASE_URL}data`, the files in `public/data/`, which Vite copies into `dist/`. To switch to an object store, upload the same files and set `VITE_DATA_URL`. To switch to a database, put an API in front of `db/schema.sql` that returns the same JSON. In both cases nothing outside `source.ts` changes. Whichever host you use must send CORS headers if it is on a different origin from the site.

**Selection.** `select(id)` in `main.ts` shows "Loading…" and ignores any response that arrives after a newer selection. On failure it shows the error in the title instead of leaving a blank screen.

### In-memory format: `Tree`

`toTree()` groups `members` by family into `parents` and `children` arrays and turns `houses` into a colour lookup:

```ts
type Tree = {
    title: string;
    people: Record<id, { name: string; house: string; sex: "m" | "f" }>;
    families: { parents: id[]; children: id[]; adoptive?: boolean }[];
    houseColors: Record<house, cssColor>;
};
```

A **family** is one union: zero to two parents and zero or more children. People are not linked to each other directly. Everything goes through a family. This means:

- remarriages are separate families (Robert + Cersei, Jaime + Cersei);
- a childless marriage is a family with `children: []` (Daenerys + Drogo);
- a single or unknown co-parent is a one-item `parents` list (Robert → Gendry);
- half-siblings come out right, because they belong to different families that share one parent (Jon, and Rhaenys and Aegon, through Rhaegar);
- siblings with unknown parents are a family with `parents: []` (Gavilar and Dalinar Kholin). The union node becomes a root;
- adoption is a separate family with `adoptive: true`, so a child can have both birth and adoptive parents (Leia: Anakin + Padmé and Bail + Breha). Only the labels change; the layout treats it like any other family.

## 4. Graph construction: union nodes

`main.ts` turns the data into a directed graph with two kinds of node:

- a **person node** for each entry in `people`;
- a **union node** (`family<i>`) for each entry in `families`.

and two kinds of link:

- `spouse`: parent → union;
- `child`: union → child.

```
Rhaegar ─spouse─┐                 ┌─child─► Jon
                ├─► (family2) ────┘
Lyanna  ─spouse─┘
```

This is the usual way to model genealogy as a graph. Linking people directly (spouse ↔ spouse, parent → child) creates cycles and duplicate parent edges. With union nodes, every edge points from an older generation to a younger one, so the graph is a **DAG** (directed acyclic graph). The layout below depends on that.

## 5. Layout

`three-forcegraph` runs a `d3-force-3d` simulation: link springs, many-body repulsion and centring.

`dagMode("td")` fixes each node's `y` to its DAG depth, which is the **longest path from any root**. Nodes keep moving freely in `x` and `z`, so each generation spreads out over a horizontal plane rather than a flat 2D tree.

- `dagLevelDistance(40)` is the vertical gap between depth levels. A generation spans two levels (person, then union), so generations are 80 units apart.
- A cycle in the data makes the library throw `Invalid DAG structure!`. With union nodes this only happens if the data itself is wrong, for example someone listed as their own ancestor.
- The many-body repulsion (`charge`) has `distanceMax(120)`. Every saga contains families that aren't connected to each other. With unlimited repulsion they push each other apart forever, and a tree grew from about 175 to over 700 units wide within 8 seconds.

### Switching trees and camera framing

`load(tree)` builds new nodes and links and calls `graph.graphData()`, which reheats the simulation. It also disposes of and rebuilds the sibling overlay and resets the camera. While `autoFit` is true, each frame `fitCamera()` eases the camera towards a distance that fits `graph.getGraphBbox()` in the view. The first OrbitControls `start` event (any drag or zoom) sets `autoFit` to false, so the camera never fights the user. Each `load()` sets it back to true.

**Known limitation:** depth is counted from roots. A person with no parents in the data is a root, so they land on the top layer even if they married into a later generation. Elia Martell, Khal Drogo and Selyse Florent show this. The planned fix is to work out each person's generation from their spouse or children, then set `fy` directly instead of using `dagMode`.

## 6. Rendering

| Element      | Implementation                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Person       | `Group` of a `SphereGeometry(4, 48, 24)` with a clearcoated `MeshPhysicalMaterial` in the house colour, plus a `SpriteText` name label above it that always faces the camera. The geometry is shared. Each person gets its own material.                                                                                                                                                                                                                                           |
| Union        | Small `SphereGeometry(1.2)` with a shared white `MeshBasicMaterial`.                                                                                                                                                                                                                                                                                                                                                                                                               |
| Spouse link  | Gold (`#c9ad73`), labelled at its midpoint: father/mother when the family has children, otherwise husband/wife. "Adoptive " is added in front for `adoptive` families.                                                                                                                                                                                                                                                                                                             |
| Child link   | Grey (`#667`), with two particles moving towards the child to show the direction of descent. Labelled son/daughter, or adopted son/daughter.                                                                                                                                                                                                                                                                                                                                       |
| Sibling line | Dashed green `LineSegments` between consecutive children of a family, labelled brothers/sisters/brother & sister. These are not graph links: as links they would change DAG depths. They sit in `graph` and are moved to the live node positions every frame by `updateSiblings()`.                                                                                                                                                                                                |
| Labels       | All labels use `SpriteText`. Names are Roboto Condensed 700 at height 4; relationship labels are Roboto 500 at height 2, on a translucent dark background. `SpriteText` draws its text to a canvas once, so the first saga loads only after `document.fonts.load()` has the web fonts (up to 3 s, then the fallback fonts are used). Link labels use `linkThreeObjectExtend(true)` so the library still draws the line, and `linkPositionUpdate` places the label at the midpoint. |
| Lighting     | ACES filmic tone mapping. A `RoomEnvironment` map (PMREM, intensity 0.35) gives soft reflections. A dim `HemisphereLight` fills in, a strong warm key `DirectionalLight` lights the front, and a cool blue rim light from behind outlines the spheres.                                                                                                                                                                                                                             |
| Camera       | `PerspectiveCamera` (60°) with `OrbitControls` damping. It starts at z = 320 and then auto-fits the tree (see §5).                                                                                                                                                                                                                                                                                                                                                                 |

The graph is one `Object3D` added to the app's own scene. The app keeps control of the renderer, camera and controls. This is why it uses `three-forcegraph` rather than `3d-force-graph`, which brings its own renderer and camera. Later 3D additions, such as picking, custom shaders or extra scene objects, can then use plain three.js.

### Frame loop

```ts
renderer.setAnimationLoop(() => {
    graph.tickFrame(); // advance the force simulation and update node/link transforms
    controls.update(); // apply orbit damping
    renderer.render(scene, camera);
});
```

The simulation cools and stops on its own (d3 alpha decay). After that, `tickFrame` only animates the link particles.

## 7. Build and dependencies

| Package            | Purpose                                                             |
| ------------------ | ------------------------------------------------------------------- |
| `three`            | Rendering.                                                          |
| `three-forcegraph` | Graph as a three.js object; force and DAG layout via `d3-force-3d`. |
| `three-spritetext` | Name labels that face the camera.                                   |
| `lil-gui`          | The "Saga" drop-down.                                               |
| `typescript`       | Type-checking (`npm run build` runs `tsc --noEmit` first).          |
| `vite`             | Dev server and bundler.                                             |

`manualChunks` puts every module whose path contains `three` into one cached vendor chunk. That covers three.js and both graph libraries, about 720 kB minified or 190 kB gzipped, so `chunkSizeWarningLimit` is set to 800.

## 8. Extension points

- **Data loading:** a GEDCOM importer that writes `SagaRecord` JSON, or an API over `db/schema.sql` (see §3).
- **Generation-correct layout:** see the known limitation in §5.
- **Interaction:** a `Raycaster` against the node objects for hover and click, to highlight ancestors and descendants or show a details panel.
- **Graph queries:** `graphology` for relationship paths ("how is Jon related to Daenerys?").
- **Large trees:** for more than about 5k nodes, switch `forceEngine("ngraph")` or use instanced meshes in place of per-node objects.
