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

| File                            | Role                                                                                                                                                                                                                                                                                                                        |
| ------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `index.html`                    | Page markup only: header (title, author, search, toolbar), details panel, relationship finder, toast, touch pad and the no-WebGL notice. Loads Roboto and Roboto Condensed from Google Fonts and `src/main.ts`.                                                                                                             |
| `src/style.css`                 | All UI styling, with the palette and fonts as CSS variables (`--fd` display, `--fb` body). Imported by `main.ts`, so Vite bundles and minifies it.                                                                                                                                                                          |
| `src/main.ts`                   | Entry point (about 1 kB). Dynamically imports `app.ts` and, if that fails because there's no WebGL or the chunk won't download, shows the no-WebGL notice instead of a blank page.                                                                                                                                          |
| `src/app.ts`                    | App wiring: saga loading and URL state, selection and the details panel, the relationship finder, search, GEDCOM import, PNG export, picking, keyboard and pad input, GPU context loss, and the frame loop (§5a).                                                                                                           |
| `src/scene.ts`                  | Renderer, scene, lights, background vignette, camera, OrbitControls and resize. `hasWebGL()` and `NoWebGLError`, `captureView()` for PNG export, and WebGL context-loss events. No family-tree knowledge.                                                                                                                   |
| `src/graph.ts`                  | The tree as a three.js object: `showTree(tree)` builds nodes and links and pins generation heights, plus the sibling overlay, `highlight(people, path)` with eased fades and the gold path glow, and the label fade. Each link has its own material. Frees the previous tree's materials and label textures on each switch. |
| `src/camera.ts`                 | Camera behaviour on top of OrbitControls: auto-fit, fly-to and held-direction panning. Frame-rate independent.                                                                                                                                                                                                              |
| `src/family.ts`                 | Pure family queries, with no three.js or DOM: `lineage`, `relatives`, link labels, `findByName`, `houseDepths`.                                                                                                                                                                                                             |
| `src/relationship.ts`           | `relate(tree, a, b)`: names how `a` is related to `b` and returns the connecting path (§5b).                                                                                                                                                                                                                                |
| `src/generations.ts`            | `generations(tree)`: a generation number for every person (§5).                                                                                                                                                                                                                                                             |
| `src/labels.ts`                 | Name and relationship labels (`SpriteText`), `fontsReady`, and `disposeLabel`.                                                                                                                                                                                                                                              |
| `src/data/schema.ts`            | `SagaIndexEntry` and `SagaRecord` (the stored format), and `Tree` (the in-memory format the renderer uses).                                                                                                                                                                                                                 |
| `src/data/source.ts`            | `listSagas()` and `loadSaga(id)` fetch from the data base URL. `toTree()` turns a `SagaRecord` into a `Tree`. This is the only file that knows where the data comes from.                                                                                                                                                   |
| `src/data/gedcom.ts`            | `parseGedcom(text)`: GEDCOM 5.5, 5.5.1 and 7 → `Tree`, plus warnings (§5c).                                                                                                                                                                                                                                                 |
| `src/d3-force-3d.d.ts`          | Types for the one `d3-force-3d` export used (`forceZ`).                                                                                                                                                                                                                                                                     |
| `public/data/sagas.json`        | Manifest: `{ id, title, work, author }` per saga. Sets the drop-down order; the first entry loads at startup.                                                                                                                                                                                                               |
| `public/data/<id>.json`         | One saga each (`got`, `fireblood`, `lotr`, `silmarillion`, `dune`, `potter`, `starwars`, `wot`, `stormlight`, `witcher`) as a `SagaRecord`: normalised tables plus `source` and `notes`.                                                                                                                                    |
| `db/schema.sql`                 | Relational tables matching `SagaRecord`, for a database backend (PostgreSQL or SQLite).                                                                                                                                                                                                                                     |
| `db/seed.sql`                   | Generated by `npm run db:seed`: inserts every saga from `public/data/`. Do not edit by hand (§3).                                                                                                                                                                                                                           |
| `scripts/trees.test.mts`        | `npm test`: every saga file. `sagas.json` matches the files, every reference resolves, everyone is in a family, no family has more than two parents.                                                                                                                                                                        |
| `scripts/family.test.mts`       | `npm test`: `family.ts` against real saga data (Jon's lineage, Luke's adoptive parents, link labels, search, house depths).                                                                                                                                                                                                 |
| `scripts/relationship.test.mts` | `npm test`: relationships from the sagas (Jon is Daenerys's nephew, half-siblings, Targaryen double descent) and a synthetic cousin chart.                                                                                                                                                                                  |
| `scripts/gedcom.test.mts`       | `npm test`: GEDCOM 5.5.1 and 7, adoption markers, messy input, and that an imported tree works with the relationship and generation logic.                                                                                                                                                                                  |
| `scripts/generations.test.mts`  | `npm test`: generation rows (co-parents share a row, children sit below parents, married-in spouses line up with their partner).                                                                                                                                                                                            |
| `scripts/seed-sql.mts`          | Generates `db/seed.sql`; with `--check`, fails if it is out of date (part of `npm test`).                                                                                                                                                                                                                                   |
| `scripts/seed-sql.test.mts`     | `npm test`: loads schema and seed into in-memory SQLite and checks every saga round-trips to its JSON.                                                                                                                                                                                                                      |
| `vite.config.ts`                | Dev server port and base path; splits `three` and the graph libraries into their own chunk.                                                                                                                                                                                                                                 |
| `tsconfig.json`                 | Strict TypeScript, bundler module resolution, type-check only (`noEmit`). Vite does the transpiling.                                                                                                                                                                                                                        |

## 3. Data model

### Stored format: `SagaRecord`

Each saga is stored as normalised tables, one array per table, so it maps one-to-one onto rows in [db/schema.sql](db/schema.sql):

| Array      | Row                        | SQL table                                     |
| ---------- | -------------------------- | --------------------------------------------- |
| (top)      | `id, title, source{…}`     | `saga` (+ `position` = order in `sagas.json`) |
| `notes`    | string                     | `saga_note`                                   |
| `houses`   | `{ name, color }`          | `house`                                       |
| `people`   | `{ id, name, house, sex }` | `person`                                      |
| `families` | `{ id, adoptive }`         | `family`                                      |
| `members`  | `{ family, person, role }` | `family_member`                               |

`members` is the join table: one row per person per family, with `role` set to `parent` or `child`. Ids are scoped to the saga (the SQL primary keys are `(saga_id, id)`), so the same character id can appear in several sagas.

**Database seed.** `scripts/seed-sql.mts` (`npm run db:seed`) generates `db/seed.sql` from the JSON:

- one `BEGIN … COMMIT` transaction;
- sagas in `sagas.json` order, with that order stored in `saga.position`, so a database API can return the drop-down order with `ORDER BY position`;
- for each saga, `DELETE FROM saga` first, then `INSERT`s in dependency order (saga → notes → houses → people → families → members), so every foreign key holds at every statement;
- laid out for reading: a file header with the saga list, a boxed banner per saga (title, id, author, medium, canon, coverage and row counts), and a `── Section ──` heading per table. People are grouped under a comment for each house. Each family is its own block, headed by a readable summary such as `-- got-f3: Rhaegar Targaryen + Lyanna Stark → Jon Snow`, and marked `[adoptive]`, `(no children)` or `(parents unknown)` where those apply. Because people are grouped by house, their row order differs from the JSON, so the round-trip test compares people as a set;
- values written as SQL string literals with `'` doubled. Booleans are `TRUE`/`FALSE`, which PostgreSQL and SQLite (3.23+) both accept.

The schema has `ON DELETE CASCADE` on every table's link to `saga` (and from `family_member` to `family` and `person`). That makes the delete-then-insert re-runnable, and removing a saga removes all its rows. The file is excluded from Prettier (`.prettierignore`) because it is generated.

`npm test` checks it in two ways:

- `seed-sql.mts --check` fails if `seed.sql` differs from what the JSON would generate now, so the two can't drift apart.
- `seed-sql.test.mts` loads `schema.sql` and `seed.sql` into an in-memory SQLite database (Node's built-in `node:sqlite`, so no database install) with `PRAGMA foreign_keys = ON`. It loads the seed twice, rebuilds every saga from the tables, and asserts each is identical to its JSON file and to the `sagas.json` order. Finally it deletes a saga and asserts nothing is left in any table.

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

`generations(tree)` gives every person a generation number, and `showTree()` (in `graph.ts`) pins each node's `fy` to `GEN_GAP` (80) × generation. Union nodes sit half a row below their parents. This replaces the library's `dagMode`, which counted depth from the roots: anyone with no parents in the data was a root, so married-in spouses (Elia Martell, Khal Drogo, Selyse Florent) floated up to the top row.

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

`show(tree)` in `main.ts` resets the selection, panel and search list and calls `showTree(tree)` in `graph.ts`. That builds new nodes and links and calls `graph.graphData()`, which reheats the simulation. Before that it frees the previous tree's per-person materials and all label textures, because `SpriteText` makes a canvas texture per label, and these used to build up with every saga switch. It also rebuilds the sibling overlay, keeping its one shared material.

The camera (`camera.ts`) has three modes, and the user always wins. All its motion is frame-rate independent: easing closes `1 - exp(-rate × dt)` of the gap each frame and panning scales with `dt`, so a 120 Hz screen behaves like a 60 Hz one. Before, both ran per frame, so on a 120 Hz screen they went twice as fast.

| Mode      | When                                            | What it does                                                                                                                                                                            |
| --------- | ----------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `autoFit` | After `load()`, after deselecting, pad ◯ button | Each frame, `stepFit()` eases towards a view that fits the tree's **width and height**. Depth is left out on purpose: including it would push the camera back and flatten the parallax. |
| `flight`  | Search result or panel link                     | `stepFlight()` eases towards the person's **live** position (the layout may still be moving) for about a second, then stops.                                                            |
| user      | Any OrbitControls `start`, arrow key or pad     | Both modes above are cancelled at once, so they never pull the camera back while you're exploring.                                                                                      |

## 5a. Interaction (`src/app.ts`, `src/family.ts`)

**Picking.** Each person's sphere has `userData.personId`, and a `Raycaster` against `graph` finds the person under the pointer. Hover is mouse-only. A click counts only if the pointer moved less than 5 px since a `pointerdown` that began on the canvas. Without that check, an orbit drag would count as a click, and so would a click on the panel that then lands on the canvas, which used to re-select the old person.

**Highlight.** `lineage(tree, id)` in `family.ts` walks the families upwards and downwards to collect all ancestors and descendants, plus the person's spouses. `highlight()` in `graph.ts` sets a target for everything outside that set of 12% opacity, including union nodes, links and sibling lines; a union stays lit when any of its members is in the line. `stepFades()` eases every object towards its target, settling in about 0.3 s, so highlights fade rather than snap. For labels, the eased `dim` factor is combined each frame with the distance fade.

**Per-link materials.** By default three-forcegraph shares one material per link colour. Dimming one gold spouse link therefore dimmed them all, and the last link processed set every link's opacity. `linkMaterial()` now gives each link its own material, at a resting opacity of 0.45 (the library's default 0.2 was too faint).

**Label fade.** `fadeLabels()` fades relationship labels from fully visible at 110 units from the camera to hidden at 240, and turns them off entirely once almost transparent. Labels on the highlighted line skip the fade. Person names are never faded.

**Details panel and search.** `select(id)` fills the panel from `relatives(tree, id)` (parents or adoptive parents, siblings or foster siblings, spouse, children or adopted children). Each name is a link to that person. `select` also puts the person's name in the search box and writes the URL. `deselect()` is the single way out (close button, Esc, an empty click, or clearing the search): it calls `fitTree()`, which stops any flight and eases back to the whole tree, empties the search and URL, and clears the highlight. Search listens to `change` to select, and to `input` so the clear (✕) button deselects immediately instead of waiting for blur.

**Panning.** Arrow keys and the on-screen pad call `holdPan()` and `releasePan()` in `camera.ts`, and `stepPan()` calls `controls.pan()` every frame, by 540 px per second scaled by `dt`, while any direction is held. That gives smooth movement instead of OrbitControls' own handler, which steps once per key-repeat. Arrows are ignored while typing in an input, Shift/Ctrl/Cmd plus an arrow rotates instead, and losing window focus clears `held`. The pad appears only for `(pointer: coarse)`, and it uses pointer capture so a finger sliding off a button still releases it.

**URL state.** `writeUrl()` keeps `?saga=…&person=…` in sync using `history.replaceState`, so there is no history entry for every click. On startup, `?saga` picks the saga and `?person` is selected once the layout has had 1.5 s to place it.

**Mobile.** Below 600 px wide, lil-gui starts collapsed. Its root (`.lil-root`) has an inline width, so the stylesheet needs `!important` to shrink it. The panel spans the screen width, and the pad moves up when the panel is open.

## 5b. Relationship finder (`src/relationship.ts`)

`relate(tree, a, b)` returns `{ summary, label, path, steps, adoptive }`, or `null` if the two aren't connected.

- **Blood relationships** use the standard genealogical method. Breadth-first search finds every ancestor of each person with its distance. The **closest common ancestor** gives the generations up from each side, `(ga, gb)`, and those are named:

    | `ga`, `gb`  | Label                                                     |
    | ----------- | --------------------------------------------------------- |
    | 0, n        | father/mother, grand-, great-grand-… (a is above b)       |
    | n, 0        | son/daughter, grand-, great-grand-…                       |
    | 1, 1        | brother/sister                                            |
    | n, 1 / 1, n | nephew/niece, uncle/aunt: grand- at 3, great-grand- at 4… |
    | otherwise   | cousin of degree `min(ga, gb) − 1`, removed `             | ga − gb | ` times |

- **Half-relations:** the two lines meet at an ancestor whose partner isn't also a common ancestor at the same distance.
- **Multiple routes:** heavily intermarried families such as the Targaryens are related through several routes. The closest route wins, so Aegon III is Baelon's _grandson_ through Daemon, not his great-grandson through Rhaenyra. When routes tie, a birth route is preferred over an adoptive one.
- **Adoption** counts as parenthood but is flagged _(by adoption)_.
- **Marriage-only connections** (spouses, in-laws, step-relations) have no common ancestor. They are found by a shortest path over parent, child and spouse links and described step by step.
- **`path`** is always that shortest chain, which `highlight(people, path)` lights in gold. Path people glow in their house colour and path links are drawn brighter and thicker. A path step between two people passes through their family's union node, so both halves are marked.
- **Tests:** `relationship.test.mts` checks facts from the sagas and a synthetic tree laid out like the standard cousin chart. The synthetic test caught an off-by-one in the nephew line (grand- one generation too late) that no saga test would have.

## 5c. GEDCOM import (`src/data/gedcom.ts`)

GEDCOM is line based: `LEVEL [@XREF@] TAG [VALUE]`. `parseGedcom()` builds the record tree from the levels and then maps the records:

| GEDCOM                                                         | Tree                                                                                     |
| -------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `INDI` with `NAME "Given /Surname/"` (or `GIVN`/`SURN`), `SEX` | person. The house is the surname, and `SEX` other than M or F becomes `m` with a warning |
| `FAM` with `HUSB`, `WIFE`, `CHIL`                              | family (at most two parents)                                                             |
| `CHIL` + `PEDI adopted`/`foster`, or `_FREL`/`_MREL`           | a separate `adoptive` family with the same parents                                       |
| `INDI` → `FAMC` + `PEDI adopted`                               | the same, when the marker is on the person's side                                        |

It tolerates a BOM, CRLF line endings, lower-case tags, indentation and malformed lines. A pointer to a missing person is dropped with a warning, and a birth family left empty only because its children were all adopted is dropped too. It throws only if there are no `INDI` records at all. The 20 MB size check happens before parsing, in `app.ts`.

## 5d. PNG export and no-WebGL

- **`captureView(scale, overlay)`** renders one frame at `scale` × the screen resolution (capped at 4×) and copies the canvas into a 2D canvas in the same step, before the browser can clear WebGL's buffer. It then encodes the copy as a PNG. This avoids `preserveDrawingBuffer: true`, which would cost performance on every frame just to allow an occasional export. The overlay stamps the saga title and author in the corner.
- **No WebGL.** `main.ts` is a tiny entry point that dynamically imports `app.ts`. `scene.ts` checks for a WebGL 2 context and throws `NoWebGLError`, as it does if `WebGLRenderer` itself fails (e.g. a blocklisted GPU). `main.ts` catches the error and shows the notice, hiding the header and pad, instead of a blank page. A failed chunk download, such as offline, gets the same notice with that reason.
- **Context loss** at runtime pauses the frame loop and shows a message. On `webglcontextrestored` the tree is rebuilt, because textures and materials don't survive a lost context.

## 6. Rendering

| Element      | Implementation                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Person       | `Group` of a `SphereGeometry(4, 48, 24)` with a matte `MeshStandardMaterial` in the house colour (roughness 0.78, no metalness, no clearcoat), so the shape comes from the gradient between lit and shadowed sides rather than a glossy hotspot, plus a `SpriteText` name label above it that always faces the camera. The geometry is shared. Each person gets its own material.                                                                                                                                                                  |
| Union        | Small `SphereGeometry(1.2)` with a shared white `MeshBasicMaterial`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| Spouse link  | Gold (`#c9ad73`), labelled at its midpoint: father/mother when the family has children, otherwise husband/wife. "Adoptive " is added in front for `adoptive` families.                                                                                                                                                                                                                                                                                                                                                                             |
| Child link   | Grey (`#667`), with two particles moving towards the child to show the direction of descent. Labelled son/daughter, or adopted son/daughter.                                                                                                                                                                                                                                                                                                                                                                                                       |
| Sibling line | Dashed green `LineSegments` between consecutive children of a family, labelled brothers/sisters/brother & sister. These are not graph links: as links they would pull siblings together and distort the layout. They sit in `graph` and are moved to the live node positions every frame by `updateSiblings()`.                                                                                                                                                                                                                                    |
| Labels       | All labels use `SpriteText`. Names are Roboto Condensed 700 at height 4; relationship labels are Roboto 500 at height 2, on a translucent dark background. `SpriteText` draws its text to a canvas once, so the first saga loads only after `document.fonts.load()` has the web fonts (up to 3 s, then the fallback fonts are used). Link labels use `linkThreeObjectExtend(true)` so the library still draws the line, and `linkPositionUpdate` places the label at the midpoint.                                                                 |
| Lighting     | ACES filmic tone mapping, set up for depth. A strong warm key `DirectionalLight` (3.4) from upper left gives each sphere a clear lit side, terminator and shadow side. A low `HemisphereLight` fill (0.22) keeps the shadow side dark but not black. A faint `RoomEnvironment` (0.12) adds only an ambient tint, because more would flatten the gradient. A cool blue rim light from behind separates the spheres from the background. The background is a faint radial vignette (lighter in the middle) rather than flat black, which adds depth. |
| Camera       | `PerspectiveCamera` (50°) with `OrbitControls` damping. 50° keeps perspective, and so pan parallax, visible without fish-eye distortion at the edges. It starts at z = 320 and then auto-fits the tree (see §5).                                                                                                                                                                                                                                                                                                                                   |

The graph is one `Object3D` added to the app's own scene. The app keeps control of the renderer, camera and controls. This is why it uses `three-forcegraph` rather than `3d-force-graph`, which brings its own renderer and camera. Later 3D additions, such as picking, custom shaders or extra scene objects, can then use plain three.js.

### Frame loop

```ts
renderer.setAnimationLoop((now) => {
    const dt = /* seconds since the last frame, clamped to 0.1 */;
    stepGraph(camera); // graph.ts: tick the simulation, move the sibling overlay, fade relationship labels
    stepCamera(dt, bbox); // camera.ts: auto-fit, fly-to, held-direction pan, then OrbitControls damping
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
- **Relationship finder:** all relationships, not just the closest (e.g. listing both of Aegon III's routes to Baelon).
- **Large trees:** for more than about 5k nodes, switch `forceEngine("ngraph")` or use instanced meshes in place of per-node objects.
