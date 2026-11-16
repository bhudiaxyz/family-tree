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

| File                           | Role                                                                                                                                                                                                                                                                                                                                       |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `index.html`                   | Full-screen page; loads Roboto and Roboto Condensed from Google Fonts (`--fd` display, `--fb` body); the `#title` / `#author` header overlay and the dark lil-gui theme; loads `src/main.ts`.                                                                                                                                              |
| `public/data/sagas.json`       | Manifest: `{ id, title, work, author }` per saga. Sets the drop-down order; the first entry loads at startup.                                                                                                                                                                                                                              |
| `public/data/<id>.json`        | One saga each (`got`, `fireblood`, `lotr`, `silmarillion`, `dune`, `potter`, `starwars`, `wot`, `stormlight`, `witcher`) as a `SagaRecord`: normalised tables plus `source` and `notes`.                                                                                                                                                   |
| `src/data/schema.ts`           | `SagaIndexEntry` and `SagaRecord` (the stored format), and `Tree` (the in-memory format the renderer uses).                                                                                                                                                                                                                                |
| `src/data/source.ts`           | `listSagas()` and `loadSaga(id)` fetch from the data base URL. `toTree()` turns a `SagaRecord` into a `Tree`. This is the only file that knows where data comes from.                                                                                                                                                                      |
| `db/schema.sql`                | Relational tables matching `SagaRecord`, for a future database backend.                                                                                                                                                                                                                                                                    |
| `src/main.ts`                  | `load(tree)` converts a tree to graph nodes and links, pins each generation's height and rebuilds the sibling overlay. Also handles picking, highlight, the details panel, search, fly-to, panning, label fade and URL state (§5a). Also configures the graph object, renderer, camera, lights, controls and GUI, and runs the frame loop. |
| `scripts/generations.test.mts` | `npm test`: generation rows (co-parents share a row, children sit below their parents, married-in spouses line up with their partner).                                                                                                                                                                                                     |
| `src/generations.ts`           | `generations(tree)`: a generation number for every person (see §5).                                                                                                                                                                                                                                                                        |
| `scripts/trees.test.mts`       | `npm test`: checks every saga file. `sagas.json` matches the files, every house, person and family reference resolves, everyone is in a family, no family has more than two parents, and `toTree()` succeeds.                                                                                                                              |
| `vite.config.ts`               | Dev server port; splits `three` and the graph libraries into their own chunk.                                                                                                                                                                                                                                                              |
| `tsconfig.json`                | Strict TypeScript, bundler module resolution, type-check only (`noEmit`). Vite does the transpiling.                                                                                                                                                                                                                                       |

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

`three-forcegraph` runs a `d3-force-3d` simulation: link springs, many-body repulsion and centring. The vertical position is fixed rather than simulated.

### Generations (`src/generations.ts`)

`generations(tree)` gives every person a generation number, and `load()` pins each node's `fy` to `GEN_GAP` (80) × generation. Union nodes sit half a row below their parents. This replaces the library's `dagMode`, which counted depth from the roots: anyone with no parents in the data was a root, so married-in spouses (Elia Martell, Khal Drogo, Selyse Florent) floated up to the top row.

The algorithm:

1. **Merge spouses.** A union-find joins each family's co-parents into one group, so spouses always share a row.
2. **Longest-path layering.** Kahn's algorithm runs over the parent-group → child-group edges, giving every group a level below all of its ancestors.
3. **Pull down.** Groups are then pushed down as far as their children allow, so an in-law's parents sit just above their child, not in the oldest row.
4. **Fallbacks.** Families with no parents add no edges. A child who married into their own parents' group, or any cycle, can't be layered and falls back gracefully rather than throwing.

`scripts/generations.test.mts` (part of `npm test`) checks on every saga that co-parents share a row, that children sit below their parents, and that the three GoT spouses above now line up with their partners.

### Forces

- The many-body repulsion (`charge`) has `distanceMax(120)`. Every saga contains families that aren't connected to each other. With unlimited repulsion they push each other apart forever, and a tree grew from about 175 to over 700 units wide within 8 seconds.
- **Depth for parallax.** A `forceZ` ("depth") pulls each house towards its own z plane, spread over `DEPTH` (240) units. The planes are ordered by house size, biggest in the middle, alternating front and back. The pull is weak (strength 0.08), so links and repulsion still shape the layout, and in practice the tree ends up about 175 units deep. That depth is what gives panning real perspective parallax: in a measured pan, the nearest people moved about 1.24× as far on screen as the farthest. A stronger effect needs a stronger pull (which starts to fight the links) or a closer camera.

### Switching trees and camera framing

`load(tree)` builds new nodes and links and calls `graph.graphData()`, which reheats the simulation. It also disposes of and rebuilds the sibling overlay, rebuilds the search list, clears any selection and resets the camera.

The camera has three modes, and the user always wins:

| Mode      | When                                            | What it does                                                                                                                                                                              |
| --------- | ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `autoFit` | After `load()`, after deselecting, pad ◯ button | Each frame, `fitCamera()` eases towards a view that fits the tree's **width and height**. Depth is left out on purpose: including it would push the camera back and flatten the parallax. |
| `flight`  | Search result or panel link                     | `stepFlight()` eases towards the person's **live** position (the layout may still be moving) for about a second, then stops.                                                              |
| user      | Any OrbitControls `start`, arrow key or pad     | Both modes above are cancelled at once, so they never pull the camera back while you're exploring.                                                                                        |

## 5a. Interaction (`src/main.ts`)

**Picking.** Each person's sphere has `userData.personId`, and a `Raycaster` against `graph` finds the person under the pointer. Hover is mouse-only. A click counts only if the pointer moved less than 5 px since a `pointerdown` that began on the canvas. Without that check, an orbit drag would count as a click, and so would a click on the panel that then lands on the canvas, which used to re-select the old person.

**Highlight.** `lineage(id)` walks the families upwards and downwards to collect all ancestors and descendants, plus the person's spouses. `applyFocus()` dims everything outside that set to 12% opacity, including union nodes, links and sibling lines; a union stays lit when any of its members is in the line. Meshes have their opacity set directly. For labels, a `dim` factor is recorded and combined each frame with the distance fade.

**Label fade.** `fadeLabels()` fades relationship labels from fully visible at 110 units from the camera to hidden at 240, and turns them off entirely once almost transparent. Labels on the highlighted line skip the fade. Person names are never faded.

**Details panel and search.** `select(id)` fills the panel from `relatives(id)` (parents or adoptive parents, siblings or foster siblings, spouse, children or adopted children). Each name is a link to that person. `select` also puts the person's name in the search box and writes the URL. `deselect()` is the single way out (close button, Esc, an empty click, or clearing the search): it stops any flight, turns `autoFit` back on, empties the search and URL, and clears the highlight. Search listens to `change` to select, and to `input` so the clear (✕) button deselects immediately instead of waiting for blur.

**Panning.** Arrow keys and the on-screen pad add directions to a `held` set, and `stepPan()` calls `controls.pan()` every frame while any direction is held. That gives smooth movement instead of OrbitControls' own handler, which steps once per key-repeat. Arrows are ignored while typing in an input, Shift/Ctrl/Cmd plus an arrow rotates instead, and losing window focus clears `held`. The pad appears only for `(pointer: coarse)`, and it uses pointer capture so a finger sliding off a button still releases it.

**URL state.** `writeUrl()` keeps `?saga=…&person=…` in sync using `history.replaceState`, so there is no history entry for every click. On startup, `?saga` picks the saga and `?person` is selected once the layout has had 1.5 s to place it.

**Mobile.** Below 600 px wide, lil-gui starts collapsed. Its root (`.lil-root`) has an inline width, so the stylesheet needs `!important` to shrink it. The panel spans the screen width, and the pad moves up when the panel is open.

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
| Camera       | `PerspectiveCamera` (50°) with `OrbitControls` damping. 50° keeps perspective, and so pan parallax, visible without fish-eye distortion at the edges. It starts at z = 320 and then auto-fits the tree (see §5).                                                                                                                                                                                                                                                                   |

The graph is one `Object3D` added to the app's own scene. The app keeps control of the renderer, camera and controls. This is why it uses `three-forcegraph` rather than `3d-force-graph`, which brings its own renderer and camera. Later 3D additions, such as picking, custom shaders or extra scene objects, can then use plain three.js.

### Frame loop

```ts
renderer.setAnimationLoop(() => {
    graph.tickFrame(); // advance the force simulation and update node/link transforms
    if (siblingLines) updateSiblings(); // move the sibling overlay to the live node positions
    if (autoFit && graph.graphData().nodes.length) fitCamera(); // ease towards the whole-tree view
    stepFlight(); // fly-to a searched / linked person
    stepPan(); // arrow keys and on-screen pad
    fadeLabels(); // distance fade × highlight dim for relationship labels
    controls.update(); // apply orbit damping
    renderer.render(scene, camera);
});
```

In dev builds only (`import.meta.env.DEV`), `window.__ft` exposes `{ camera, controls, graph }` so browser tests can measure the camera and node positions. Production builds strip it out.

The simulation cools and stops on its own (d3 alpha decay). After that, `tickFrame` only animates the link particles.

## 7. Build and dependencies

| Package            | Purpose                                                                                                                                                                                  |
| ------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `three`            | Rendering.                                                                                                                                                                               |
| `three-forcegraph` | Graph as a three.js object; force layout via `d3-force-3d`.                                                                                                                              |
| `d3-force-3d`      | `forceZ` for the house depth planes. It is already a dependency of `three-forcegraph`, declared directly because the app imports it; `src/d3-force-3d.d.ts` types the one function used. |
| `prettier`         | Formatting (`npm run format`). YAML is kept at 2-space indents by an override in `.prettierrc`.                                                                                          |
| `three-spritetext` | Name labels that face the camera.                                                                                                                                                        |
| `lil-gui`          | The "Saga" drop-down.                                                                                                                                                                    |
| `typescript`       | Type-checking (`npm run build` runs `tsc --noEmit` first).                                                                                                                               |
| `vite`             | Dev server and bundler.                                                                                                                                                                  |

`manualChunks` puts every module whose path contains `three` into one cached vendor chunk. That covers three.js and both graph libraries, about 720 kB minified or 190 kB gzipped, so `chunkSizeWarningLimit` is set to 800.

## 8. Extension points

- **Data loading:** a GEDCOM importer that writes `SagaRecord` JSON, or an API over `db/schema.sql` (see §3).
- **Stronger parallax:** a stronger depth pull, a closer camera, or a narrower FOV with the camera moved in to compensate (see §5).
- **Graph queries:** `graphology` for relationship paths ("how is Jon related to Daenerys?").
- **Large trees:** for more than about 5k nodes, switch `forceEngine("ngraph")` or use instanced meshes in place of per-node objects.
