# Family Tree: Design and Architecture

## Contents

- [1. Overview](#1-overview)
- [2. Source layout](#2-source-layout)
- [3. Data model](#3-data-model)
    - [Stored format: SagaRecord](#stored-format-sagarecord)
    - [In-memory format: Tree](#in-memory-format-tree)
- [4. Graph construction: union nodes](#4-graph-construction-union-nodes)
- [5. Layout](#5-layout)
    - [Generations (src/generations.ts)](#generations-srcgenerationsts)
    - [Forces](#forces)
    - [Switching trees and camera framing](#switching-trees-and-camera-framing)
- [5a. Interaction (src/ui/, src/family.ts)](#5a-interaction-srcui-srcfamilyts)
- [5b. Relationship finder (src/relationship.ts)](#5b-relationship-finder-srcrelationshipts)
- [5c. GEDCOM import (src/data/gedcom.ts)](#5c-gedcom-import-srcdatagedcomts)
    - [Importing a GEDCOM file as a saga (scripts/gedcom-to-saga.mts)](#importing-a-gedcom-file-as-a-saga-scriptsgedcom-to-sagamts)
- [5d. PNG export and no-WebGL](#5d-png-export-and-no-webgl)
- [6. Rendering](#6-rendering)
    - [6a. Palettes (src/palettes.ts)](#6a-palettes-srcpalettests)
    - [6b. Nebula sky (src/nebula.ts)](#6b-nebula-sky-srcnebulats)
    - [Frame loop](#frame-loop)
- [7. Build and dependencies](#7-build-and-dependencies)
- [8. Devices and GPU tiers (src/tier.ts, src/device.ts)](#8-devices-and-gpu-tiers-srctierts-srcdevicets)
- [9. Extension points](#9-extension-points)

## 1. Overview

The app turns a list of people and families into a 3D graph and draws it with three.js. It is a static site: saga data is fetched as JSON, and layout and rendering run in the browser.

```
public/data/<category>/*.json ──fetch──► src/data/source.ts ──► src/ui/sagas.ts show() ──► three-forcegraph ──► three.js scene
 (or VITE_DATA_URL)            toTree(): tables→Tree     graph build        d3-force-3d          OrbitControls
                                     ▲
                         lil-gui "Saga" drop-down (from sagas.json)
```

## 2. Source layout

| File                               | Role                                                                                                                                                                                                                                                                  |
| ---------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `index.html`                       | Page markup only: header (title, author, search, toolbar), details panel, relationship finder, toast, touch pad and the no-WebGL notice. Loads Roboto and Roboto Condensed from Google Fonts and `src/main.ts`. `viewport-fit=cover` for iPhone safe areas.           |
| `src/style.css`                    | All UI styling, with the UI palette and fonts as CSS variables. Includes the touch rules (44 px targets, safe areas, `100dvh`, no page zoom).                                                                                                                         |
| `src/main.ts`                      | Entry point (about 1 kB). Dynamically imports `app.ts`; if that fails (no WebGL, or the chunk won't download) it shows the no-WebGL notice instead of a blank page.                                                                                                   |
| `src/app.ts`                       | Starts the UI, handles GPU context loss, and runs the frame loop with idle throttling (§5a).                                                                                                                                                                          |
| `src/ui/state.ts`                  | Shared app state (tree, saga id, selected, hovered, relationship pair, 2D flag), `refreshHighlight()`, the toast, person links and fly-to.                                                                                                                            |
| `src/ui/dom.ts`                    | The page elements, looked up once; attaches name suggestions before any other listener.                                                                                                                                                                               |
| `src/ui/url.ts`                    | `writeUrl()`: keeps `?saga`, `person`, `with` and `view` in sync.                                                                                                                                                                                                     |
| `src/ui/panel.ts`                  | Selection, the details panel and "Relative to" tags.                                                                                                                                                                                                                  |
| `src/ui/relate.ts`                 | The relationship finder (§5b).                                                                                                                                                                                                                                        |
| `src/ui/search.ts`                 | The "Find a person" box.                                                                                                                                                                                                                                              |
| `src/ui/files.ts`                  | PNG export and GEDCOM import, including drag-and-drop (§5c).                                                                                                                                                                                                          |
| `src/ui/input.ts`                  | Keyboard shortcuts and the touch pad.                                                                                                                                                                                                                                 |
| `src/ui/picking.ts`                | Mouse and touch picking: hover, tap, double tap, long press.                                                                                                                                                                                                          |
| `src/ui/sagas.ts`                  | Saga loading, `show()`, the nebula schedule, the menu and start-up.                                                                                                                                                                                                   |
| `src/suggest.ts`                   | Name suggestion list for the search and finder boxes (replaces `<datalist>`, which many mobile browsers ignore).                                                                                                                                                      |
| `src/tier.ts`                      | Pure GPU tier logic: `classify(gpu)` → low / medium / high, the `QUALITY` table, and `probe()` / `detect()` (§8).                                                                                                                                                     |
| `src/device.ts`                    | The detected tier and its `quality` settings, shared by every module. Its own module so `scene.ts` and `nebula.ts` can both read it without importing each other (§8).                                                                                                |
| `src/scene.ts`                     | Renderer (tier-chosen antialias, pixel ratio), lights and fog from the palette, background (vignette or baked nebula), camera, OrbitControls, the optional bloom composer, resize, `captureView()` for PNG export, and context-loss events. No family-tree knowledge. |
| `src/graph.ts`                     | Public entry for the tree as a three.js object: `showTree(tree)` builds nodes and links and pins generation heights, `peopleBbox()` for framing, `stepGraph()` per frame. Re-exports the parts below (§5).                                                            |
| `src/graph/core.ts`                | The `ThreeForceGraph` instance, node and link objects, the force layout and convergence settings, shared types and helpers.                                                                                                                                           |
| `src/graph/siblings.ts`            | The sibling overlay (dashed lines and labels).                                                                                                                                                                                                                        |
| `src/graph/guides.ts`              | Generation guides.                                                                                                                                                                                                                                                    |
| `src/graph/flat.ts`                | 2D mode: the depth squash, row spacing and sibling clustering forces.                                                                                                                                                                                                 |
| `src/graph/highlight.ts`           | `highlight(people, path)` and the eased fades, including the gold path glow.                                                                                                                                                                                          |
| `src/graph/names.ts`               | Label distance fade, name de-overlap and "Relative to" tags.                                                                                                                                                                                                          |
| `src/camera.ts`                    | Camera behaviour on top of OrbitControls: auto-fit, fly-to, held-direction panning and reduced motion. Frame-rate independent.                                                                                                                                        |
| `src/nebula.ts`                    | Procedural nebula sky baked into a cube texture per saga, dim by design (§6b).                                                                                                                                                                                        |
| `src/nebula.frag`                  | The nebula fragment shader, imported as a string with `?raw` (§6b).                                                                                                                                                                                                   |
| `src/palettes.ts`                  | Colour themes for the 3D scene (links, labels, lights, fog, background, nebula, PNG stamp, imported houses). `paletteFor(sagaId)` and the active palette (§6a).                                                                                                       |
| `src/labels.ts`                    | Name and relationship labels (`SpriteText`), house badges, `fontsReady`, and disposal.                                                                                                                                                                                |
| `src/family.ts`                    | Pure family queries: `lineage`, `relatives`, link labels, `findByName`, `houseDepths`.                                                                                                                                                                                |
| `src/relationship.ts`              | `relate(tree, a, b)` and `labelAll(tree, centre)`: blood, step and in-law names, common ancestors, every route, and the connecting path (§5b).                                                                                                                        |
| `src/generations.ts`               | `generations(tree)`: a generation number for every person (§5).                                                                                                                                                                                                       |
| `src/data/schema.ts`               | `SagaIndexEntry` and `SagaRecord` (the stored format), and `Tree` (the in-memory format the renderer uses).                                                                                                                                                           |
| `src/data/source.ts`               | `listSagas()` and `loadSaga(id)` fetch from the data base URL; `toTree()` turns a `SagaRecord` into a `Tree`. The only file that knows where the data comes from.                                                                                                     |
| `src/data/gedcom.ts`               | `parseGedcom(text)`: GEDCOM 5.5, 5.5.1 and 7 → `Tree`, plus warnings (§5c).                                                                                                                                                                                           |
| `src/d3-force-3d.d.ts`             | Types for the one `d3-force-3d` export used (`forceZ`).                                                                                                                                                                                                               |
| `public/data/sagas.json`           | Manifest: `{ id, category, title, work, author }` per saga. Sets the drop-down order; the first entry loads at startup.                                                                                                                                               |
| `public/data/<category>/<id>.json` | One saga each as a `SagaRecord`: normalised tables plus `source` and `notes`, in its category's folder (`fiction/` or `history/`).                                                                                                                                    |
| `db/schema.sql`, `db/seed.sql`     | Relational tables matching `SagaRecord`, and a generated seed with every saga (§3).                                                                                                                                                                                   |
| `scripts/*.test.mts`               | `npm test`: saga data, family queries, relationships, GEDCOM, generations, GPU tiers, and the SQL seed round-trip.                                                                                                                                                    |
| `scripts/data.mts`                 | Shared by the scripts and tests: `readIndex()`, `readSaga(entry)` and `treeById(id)`, reading files through `sagaPath()` exactly as the app does.                                                                                                                     |
| `scripts/seed-sql.mts`             | Generates `db/seed.sql`; with `--check`, fails if it is out of date.                                                                                                                                                                                                  |
| `vite.config.ts`, `tsconfig.json`  | Dev server and base path, vendor chunk; strict TypeScript, type-check only.                                                                                                                                                                                           |

## 3. Data model

### Stored format: `SagaRecord`

Each saga is stored as normalised tables, one array per table, so it maps one-to-one onto rows in [db/schema.sql](db/schema.sql):

| Array      | Row                        | SQL table                                              |
| ---------- | -------------------------- | ------------------------------------------------------ |
| (top)      | `id, title, source{…}`     | `saga` (+ `category` and `position` from `sagas.json`) |
| `notes`    | string                     | `saga_note`                                            |
| `houses`   | `{ name, color }`          | `house`                                                |
| `people`   | `{ id, name, house, sex }` | `person`                                               |
| `families` | `{ id, adoptive }`         | `family`                                               |
| `members`  | `{ family, person, role }` | `family_member`                                        |

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

**Categories and paths.** Each manifest entry has a `category`, one of `CATEGORIES` in `schema.ts` (`fiction`, `history`, `mythology`), which is also the sub-folder its data file lives in. `sagaPath(entry)` builds `<category>/<id>.json`, and it is the only place that path is built: the app's loader and every script and test (through `scripts/data.mts`) use it, so they can't disagree about where files live. It throws on an unknown category instead of building a path from it, so a bad manifest entry can't make the loader request something like `../x`. The list is closed on purpose: adding a category means adding it to `CATEGORIES`, to the `CHECK` constraint on `saga.category` in `db/schema.sql`, and creating the folder. `trees.test.mts` checks that every file is in its category's folder, that the manifest and folders match exactly, and that no saga file is left in the data root. `seed-sql.test.mts` checks that the database rejects an unknown category.

Because the URL and the menu carry only a saga id, `ui/sagas.ts` keeps the manifest as a map from id to entry, and `loadSaga(entry)` takes the entry, which includes the category.

**Data source.** `source.ts` fetches `${base}/sagas.json` and `${base}/<category>/<id>.json`. `base` is `VITE_DATA_URL` if it is set at build time. Otherwise it is `${BASE_URL}data`, the files in `public/data/`, which Vite copies into `dist/`. To switch to an object store, upload the same files and set `VITE_DATA_URL`. To switch to a database, put an API in front of `db/schema.sql` that returns the same JSON. In both cases nothing outside `source.ts` changes. Whichever host you use must send CORS headers if it is on a different origin from the site.

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
5. **Descent repair.** Merging co-parents (step 1) is right for ordinary families, but in a densely intermarried pantheon it chains generations together: Jupiter partners Venus, Venus partners Mars, and Mars is Jupiter's son, so father and son can land in groups the layering can't order. The Roman gods had 55 parents on or below their own child. A final pass walks parents before children and pushes any child that isn't below _every_ parent to one row below the deepest one. Only those children move, so every other saga's layout is unchanged; this was measured against the previous algorithm on all 14 sagas, with identical results for the 13 that were already valid.

Descent always holds; marriage is the rule that gives way. In the Roman gods, 32 couples are split across rows because no layout could keep them together and also keep parents above children. The repaired tree is 31 generations deep, so it draws as a tall, narrow column. `generations.test.mts` checks descent against _every_ parent (it used to check only the first, which is how this went unnoticed), and allows split couples only in sagas listed in `INTERMARRIED`.

An attempt to replace step 1 with "descent first, align spouses softly" was measured and rejected: it fixed the Roman tree but split couples and lengthened links in sagas that had been correct. The Tudors went from 16 long parent-to-child links to 82, with 7 split couples where there had been none.

`scripts/generations.test.mts` (part of `npm test`) checks on every saga that co-parents share a row, that children sit below their parents, and that the three GoT spouses above now line up with their partners.

### Forces

- The many-body repulsion (`charge`) has `distanceMax(120)`. Every saga contains families that aren't connected to each other. With unlimited repulsion they push each other apart forever, and a tree grew from about 175 to over 700 units wide within 8 seconds.
- **Depth for parallax.** A `forceZ` ("depth") pulls each house towards its own z plane, spread over `DEPTH` (240) units. The planes are ordered by house size, biggest in the middle, alternating front and back. The pull is weak (strength 0.08), so links and repulsion still shape the layout, and in practice the tree ends up about 175 units deep. That depth is what gives panning real perspective parallax: in a measured pan, the nearest people moved about 1.24× as far on screen as the farthest. A stronger effect needs a stronger pull (which starts to fight the links) or a closer camera.

- **Convergence.** The library defaults are `cooldownTicks = Infinity` and `cooldownTime = 15 s`, so every saga load ran the physics, and through auto-fit moved the camera and forced full-rate rendering, for 15 seconds: nodes were measured still drifting 3 units per second at 12 s. Heights are pinned and the depth pull is weak, so there's little left to solve: `d3AlphaDecay(0.045)` and `d3VelocityDecay(0.5)` settle it in about 4 s, and `cooldownTicks(300)` / `cooldownTime(5000)` stop it hard. Once stopped, nothing moves, so idle throttling can take over (§5a).

### Switching trees and camera framing

`show(tree)` in `ui/sagas.ts` resets the selection, panel and search list and calls `showTree(tree)` in `graph.ts`. That builds new nodes and links and calls `graph.graphData()`, which reheats the simulation. Before that it frees the previous tree's per-person materials and all label textures, because `SpriteText` makes a canvas texture per label, and these used to build up with every saga switch. It also rebuilds the sibling overlay, keeping its one shared material.

The camera (`camera.ts`) has three modes, and the user always wins. All its motion is frame-rate independent: easing closes `1 - exp(-rate × dt)` of the gap each frame and panning scales with `dt`, so a 120 Hz screen behaves like a 60 Hz one. Before, both ran per frame, so on a 120 Hz screen they went twice as fast.

| Mode      | When                                            | What it does                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| --------- | ----------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `autoFit` | After `load()`, after deselecting, pad ◯ button | Each frame, `stepFit()` eases towards a view that fits `peopleBbox()`: the people only (not union nodes or guides), 5th–95th percentile in width on wide screens so one stray family doesn't zoom everyone out, but every person in portrait (where width is the constraint), and every generation in height. It is measured to the box centre; fitting the front face, as at first, pushed the camera back by the whole house-plane depth and made the first view far too zoomed out. |
| `flight`  | Search result or panel link                     | `stepFlight()` eases towards the person's **live** position (the layout may still be moving) for about a second, then stops.                                                                                                                                                                                                                                                                                                                                                           |
| user      | Any OrbitControls `start`, arrow key or pad     | Both modes above are cancelled at once, so they never pull the camera back while you're exploring.                                                                                                                                                                                                                                                                                                                                                                                     |

## 5a. Interaction (`src/ui/`, `src/family.ts`)

**Picking.** Each person's sphere has `userData.personId`.

- **Mouse and pen:** an exact `Raycaster` hit; the nearest sphere wins.
- **Touch:** a fingertip covers about 7 mm and hides what's beneath it, so a raycast often hit a sphere _in front of_ the intended one where people overlap (measured: 2 of 14 taps chose the wrong person on a phone). Touch picks the person whose on-screen centre is nearest the tap, within 28 px, falling back to the raycast. Measured afterwards: 14 of 14.

**Taps, double-taps and long-press** are handled the same way for every pointer type. A tap counts only if it started on the canvas, used one pointer, and moved less than a per-type slop (5 px mouse, 8 pen, 12 touch; 5 px was too tight for fingers). A second finger turns it into a pinch, never a tap, and `pointercancel` (the browser took over) abandons it. Two taps on the same person within 350 ms fly to them, because `dblclick` is unreliable on mobile. Holding a touch for 450 ms previews that person's line (the touch equivalent of hover), with a short vibration where supported. `downAt` is cleared after every `pointerup`, so a tap on a panel can never also select whoever is behind it.

**Highlight.** `lineage(tree, id)` in `family.ts` walks the families upwards and downwards to collect all ancestors and descendants, plus the person's spouses. `highlight()` in `graph/highlight.ts` sets a target for everything outside that set of 12% opacity, including union nodes, links and sibling lines; a union stays lit when any of its members is in the line. `stepFades()` eases every object towards its target, settling in about 0.3 s, so highlights fade rather than snap. For labels, the eased `dim` factor is combined each frame with the distance fade.

**Per-link materials.** By default three-forcegraph shares one material per link colour. Dimming one gold spouse link therefore dimmed them all, and the last link processed set every link's opacity. `linkMaterial()` now gives each link its own material, at a resting opacity of 0.45 (the library's default 0.2 was too faint).

**Label fade.** `fadeLabels()` fades relationship labels from fully visible at 110 units from the camera to hidden at 240, and turns them off entirely once almost transparent. Labels on the highlighted line skip the fade. Person names are never faded.

**Details panel and search.** `select(id)` fills the panel from `relatives(tree, id)` (parents or adoptive parents, siblings or foster siblings, spouse, children or adopted children). Each name is a link to that person. `select` also puts the person's name in the search box and writes the URL. `deselect()` is the single way out (close button, Esc, an empty click, or clearing the search): it calls `fitTree()`, which stops any flight and eases back to the whole tree, empties the search and URL, and clears the highlight. Search listens to `change` to select, and to `input` so the clear (✕) button deselects immediately instead of waiting for blur.

**Panning.** Arrow keys and the on-screen pad call `holdPan()` and `releasePan()` in `camera.ts`, and `stepPan()` calls `controls.pan()` every frame, by 540 px per second scaled by `dt`, while any direction is held. That gives smooth movement instead of OrbitControls' own handler, which steps once per key-repeat. Arrows are ignored while typing in an input, Shift/Ctrl/Cmd plus an arrow rotates instead, and losing window focus clears `held`. The pad appears only for `(pointer: coarse)`, and it uses pointer capture so a finger sliding off a button still releases it.

**"Relative to" mode.** The details panel's _Tag everyone's relationship_ button calls `labelAll(tree, id)` and shows each person's relationship to the selected one as a small tag above their name. It takes under 1 ms for a whole saga, even the intermarried Fire & Blood. The tags follow the selection, so they always describe the person shown, and are cleared on deselect or saga change.

**Idle throttling (battery).** A settled tree that nobody touches was redrawn 60 times a second for nothing, the biggest drain on phones and laptops. Each frame compares a cheap fingerprint (camera, orbit target and a stride of node positions, to one decimal place); while it changes, or for 600 ms after any input, frames run at full rate. Once still, whole frames (simulation and draw) are skipped down to `quality.idleFps`. Any pointer, key, wheel or resize wakes it at once. Comparing real state rather than trusting "moving" flags means a forgotten flag can never freeze the view. Measured idle frames over 2 s: low 19–20 (10 fps target; it was 48–51 before), medium 37, high 25.

**URL state.** `writeUrl()` keeps `?saga=…&person=…&view=2d|3d` in sync using `history.replaceState`, so there is no history entry for every click. On startup, `?saga` picks the saga and `?person` is selected once the layout has had 1.5 s to place it.

**Mobile and touch.**

- **No page zoom or scroll:** `html, body { touch-action: none }` gives pinch and drag to the 3D view, and double-tap selects instead of zooming the page. Panels set `touch-action: pan-y` and `overscroll-behavior: contain` so they still scroll with a finger without moving the view behind them.
- **Touch targets:** at least 44 px on coarse pointers (Apple and Material guidance), and inputs at 16 px so iOS Safari doesn't zoom when they're focused.
- **Safe areas and viewport:** overlays use `env(safe-area-inset-*)` for the iPhone notch and home bar, and `100dvh` so the mobile URL bar can't cut panels off. `visualViewport` resize events are followed as well as `window` ones.
- **Layout:** below 600 px lil-gui starts collapsed (its `.lil-root` sets an inline width, so the stylesheet needs `!important`); panels span the width; the pad moves up when a panel is open. In landscape on a phone the header shrinks and panels move to the side.
- **Verified with real touch input** (Chrome DevTools-protocol touch events, which run the browser's own gesture handling, unlike synthetic events) on an emulated Pixel 7: tap, tap-empty, one-finger orbit, two-finger pinch, double-tap, long-press, panel scroll and toolbar taps.

## 5b. Relationship finder (`src/relationship.ts`)

`relate(tree, a, b)` returns `{ summary, label, kind, path, steps, commonAncestors, routes, adoptive }`, or `null` if the two aren't connected. `kind` is `self`, `blood`, `spouse`, `step`, `in-law` or `path`. Graph indexes (parents, spouses) are built once per tree and cached in a `WeakMap`.

- **Blood relationships** use the standard genealogical method. Breadth-first search finds every ancestor of each person with its distance. The **closest common ancestor** gives the generations up from each side, `(ga, gb)`, and those are named:

    | `ga`, `gb`  | Label                                                     |
    | ----------- | --------------------------------------------------------- |
    | 0, n        | father/mother, grand-, great-grand-… (a is above b)       |
    | n, 0        | son/daughter, grand-, great-grand-…                       |
    | 1, 1        | brother/sister                                            |
    | n, 1 / 1, n | nephew/niece, uncle/aunt: grand- at 3, great-grand- at 4… |
    | otherwise   | cousin of degree `min(ga, gb) − 1`, removed `             | ga − gb | ` times |

- **Half-relations:** the route meets at a single ancestor who had a partner, and that partner isn't also a common ancestor at the same distance. This covers half-siblings, half-uncles/aunts and half-nephews/nieces (Aegon II is Aegon III's _half-uncle_) as well as half-cousins.
- **Common ancestors:** the lowest meeting point(s), usually a couple (Jon and Daenerys: _Aerys II & Rhaella_), shown in the panel and highlighted.
- **Every route:** heavily intermarried families such as the Targaryens are related through several routes. `allDistances()` keeps every distance to every ancestor (not just the shortest), and a meeting point counts only if no other common ancestor sits below it on both lines at those distances. The closest route is the headline, so Aegon III is Baelon's _grandson_ through Daemon; the panel adds "Also related as: great-grandson" through Rhaenyra. When routes tie, a birth route is preferred over an adoptive one.
- **Adoption** counts as parenthood but is flagged _(by adoption)_.
- **Step-relations:** a parent's spouse who isn't your parent (_step-mother_), a spouse's child who isn't yours (_step-son_), and children of a parent's spouse with no parent in common (_step-brother_). Cersei is Gendry's step-mother.
- **In-laws:** one marriage plus a blood relationship, in either order: a relative of your spouse (_mother-in-law_) or the spouse of your relative (_sister-in-law_). Catelyn is Benjen's sister-in-law. The blood label is re-gendered for the first person. Across the Game of Thrones tree this names 151 in-law and 20 step pairs that were previously only described as "connected by marriage".
- **Further marriage-only connections** (e.g. two wives of the same man, Elia and Lyanna) have no standard word. They are found by a shortest path over parent, child and spouse links and described step by step.
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

It tolerates a BOM, CRLF line endings, lower-case tags, indentation and malformed lines. Only the first `NAME` of a record is read: later ones are alternate names (the Norse file gives Sibil a second `NAME Sibil /(Sif)/`). A pointer to a missing person is dropped with a warning, and a birth family left empty only because its children were all adopted is dropped too. It throws only if there are no `INDI` records at all. The 20 MB size check happens before parsing, in `ui/files.ts`.

### Importing a GEDCOM file as a saga (`scripts/gedcom-to-saga.mts`)

The in-browser parser builds the family structure. The importer reuses it and adds what a stored saga needs:

- **Encoding:** strict UTF-8 first, then Windows-1252 (many GEDCOM 5.5 files say `CHAR ANSI`). Decoding those as UTF-8 would corrupt names such as Old Norse _Auðr_ and _Þrúðr_.
- **Display names** come from `scripts/gedcom-names.mts`, which is pure and tested in `gedcom-names.test.mts` against the real name patterns in the sample files. Names are kept clean: no peerage titles, title dates or life years. A monarch is shown by regnal name, taken from a `TITL` of the form King/Queen + name + Roman numeral ("King Ferdinand V of Castile and Aragon" becomes "Ferdinand V"; "Queen Consort" is a role and doesn't match). Only the person's own `TITL` lines are read; `SOUR` records also have `TITL`, which are book titles.
- **Mythology mode** (`--names mythology`): the name is the `/…/` part. A description in front is dropped. That covers lower-case text, a leading article, two or more words, or a role word ("queen of the Gods /Hera/", "Trojan Hero /Aeneas/", "Cyclops /Polyphemus/"). A real one-word given name is kept ("Numa /Pompilius/"). A placeholder ("A /Giantess/", "Gilling's /Wife/") is the only name the file gives, so it's kept whole. The Wikipedia links in the Norse file were checked as a possible source of names and rejected: most point to a related figure's page (Bára to Ægir), so using them would rename people.
- **Unnamed people:** a placeholder given name ("... /Tudor/") becomes "(unnamed son) Tudor".
- **Ids** are slugs of the display name (`henry-viii`, `unnamed-son-tudor`), numbered in file order where they repeat, so re-importing gives the same ids.
- **Houses:** one per surname, with only the 12 largest coloured individually and the rest grouped as "Other families"; or one house for everyone with `--house` (pantheons have no real surnames).
- **People with no relatives** get a one-person family, so they stay visible and "everyone is in a family" holds. These are listed in the notes. In the Norse file, 13 figures (Skuld, Gefjun, Sága and others) are only linked to 19 people the file never defines, which is a defect in the source. A repair of those broken ids was tried and found no matches, so the links are dropped rather than guessed.
- **Source details:** the compiler (`SUBM`), the file's software and date, and the titles of its `SOUR` records go into `source` and `notes`.

## 5d. PNG export and no-WebGL

- **`captureView(scale, overlay)`** renders one frame at `scale` × the screen resolution (capped at 4×) and copies the canvas into a 2D canvas in the same step, before the browser can clear WebGL's buffer. It then encodes the copy as a PNG. This avoids `preserveDrawingBuffer: true`, which would cost performance on every frame just to allow an occasional export. The overlay stamps the saga title and author in the corner.
- **No WebGL.** `main.ts` is a tiny entry point that dynamically imports `app.ts`. `scene.ts` checks for a WebGL 2 context and throws `NoWebGLError`, as it does if `WebGLRenderer` itself fails (e.g. a blocklisted GPU). `main.ts` catches the error and shows the notice, hiding the header and pad, instead of a blank page. A failed chunk download, such as offline, gets the same notice with that reason.
- **Context loss** at runtime pauses the frame loop and shows a message. On `webglcontextrestored` the tree is rebuilt, because textures and materials don't survive a lost context.

## 6. Rendering

| Element      | Implementation                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Person       | `Group` of a `SphereGeometry(4, …quality.sphereSegments)` (48×24 on high, 20×12 on low) with a matte `MeshStandardMaterial` in the house colour (roughness 0.78, no metalness, no clearcoat), so the shape comes from the gradient between lit and shadowed sides rather than a glossy hotspot, plus a `SpriteText` name label above it that always faces the camera. The geometry is shared. Each person gets its own material.                                                                                                                   |
| Union        | Small `SphereGeometry(1.2)` with a shared white `MeshBasicMaterial`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| Spouse link  | Gold (`#c9ad73`), labelled at its midpoint: father/mother when the family has children, otherwise husband/wife. "Adoptive " is added in front for `adoptive` families.                                                                                                                                                                                                                                                                                                                                                                             |
| Child link   | Grey (`#667`), with two particles moving towards the child to show the direction of descent. Labelled son/daughter, or adopted son/daughter.                                                                                                                                                                                                                                                                                                                                                                                                       |
| Sibling line | Dashed green `LineSegments` between consecutive children of a family, labelled brothers/sisters/brother & sister. These are not graph links: as links they would pull siblings together and distort the layout. They sit in `graph` and are moved to the live node positions every frame by `updateSiblings()`.                                                                                                                                                                                                                                    |
| Labels       | All labels use `SpriteText`. Names are Roboto Condensed 700 at height 4; relationship labels are Roboto 500 at height 2, on a translucent dark background. `SpriteText` draws its text to a canvas once, so the first saga loads only after `document.fonts.load()` has the web fonts (up to 3 s, then the fallback fonts are used). Link labels use `linkThreeObjectExtend(true)` so the library still draws the line, and `linkPositionUpdate` places the label at the midpoint.                                                                 |
| Lighting     | ACES filmic tone mapping, set up for depth. A strong warm key `DirectionalLight` (3.4) from upper left gives each sphere a clear lit side, terminator and shadow side. A low `HemisphereLight` fill (0.22) keeps the shadow side dark but not black. A faint `RoomEnvironment` (0.12) adds only an ambient tint, because more would flatten the gradient. A cool blue rim light from behind separates the spheres from the background. The background is a faint radial vignette (lighter in the middle) rather than flat black, which adds depth. |
| Camera       | `PerspectiveCamera` (50°) with `OrbitControls` damping. 50° keeps perspective, and so pan parallax, visible without fish-eye distortion at the edges. It starts at z = 320 and then auto-fits the tree (see §5).                                                                                                                                                                                                                                                                                                                                   |

| House badge | A small camera-facing disc in the house colour with the house's initial, below each person. One cached canvas texture per house; ink is dark on light houses and light on dark ones. Original artwork, no franchise sigils. |
| Guides | A faint horizontal cross and a "Generation n" label at each row, toggled from the menu. |
| Depth fog | `THREE.Fog` in the palette's fog colour, its range following the camera's distance to the orbit target (`updateFog()`), so it fades the far side of whatever you look at, in the overview and close up. The nebula background is drawn at infinity and isn't fogged. |
| Glow | Optional `UnrealBloomPass` (menu toggle; on by default only on the high tier). The composer is built lazily the first time glow is on, and `ScaledBloomPass` renders its blur buffers at `quality.bloomScale` of the screen, because the composer otherwise resizes the pass to full resolution. `OutputPass` tone-maps, so the renderer's own tone mapping is switched off while the composer runs. |
| Name de-overlap | A few times a second (`quality.labelDeclutterMs`), names are projected to screen boxes and sorted by priority (highlighted first, then nearest); a name whose box overlaps one already placed fades out. O(n²) on a few hundred names, marked with a `ponytail:` note for very large trees. |

The graph is one `Object3D` added to the app's own scene. The app keeps control of the renderer, camera and controls. This is why it uses `three-forcegraph` rather than `3d-force-graph`, which brings its own renderer and camera. Later 3D additions, such as picking, custom shaders or extra scene objects, can then use plain three.js.

### 6a. Palettes (`src/palettes.ts`)

Every colour the 3D scene uses lives in one `Palette`: links and the path glow, label colours, sibling and guide lines, badges, lights, fog, the fallback vignette, the nebula's colours and brightness, the PNG stamp, and the colours handed to imported GEDCOM houses. House colours are part of each saga's data and stay there. The HTML UI keeps its own CSS variables; where the two must agree (gold, ink) the matching variable is noted on the palette field.

`paletteFor(sagaId)` returns `DEFAULT_PALETTE` merged one level deep with that saga's entry in `SAGA_PALETTES` (empty for now), so a saga can later get its own theme by overriding a few fields. Colours are baked into materials, labels, badges and the sky when they're built, so `show()` in `ui/sagas.ts` calls `usePalette()`, `resetBadges()` and `applyScenePalette()` _before_ building the tree, and re-bakes the sky afterwards.

### 6b. Nebula sky (`src/nebula.ts`)

A port of procedural-worlds' nebula technique, baked once per saga into a cube texture used as `scene.background`:

- **How it's drawn:** a shader on the inside of a sphere, rendered by a `CubeCamera` into a `WebGLCubeRenderTarget`. Each fragment's position is its view direction, so there's no per-face maths and no seams. As a background it's drawn at infinity: it never moves when you pan, can't be clipped by the far plane, and isn't fogged.
- **Dust, coloured like real nebulae:** separate warped noise fields for hydrogen-alpha emission (crimson), oxygen-III (teal) and reflection nebulae (pale blue), so the colours sit side by side instead of averaging to brown; magenta where hydrogen and oxygen overlap; finer noise cuts dark dust lanes through the glow. Thresholds sit above the noise's central cluster (~0.5), so clouds cover a minority of the sky and the rest is dark space.
- **Stars and galaxies:** sparse Worley-style cells where only a small fraction hold a star (8% bright, 1% faint, ×1.25 by `starDensity`), and about a dozen soft, cloud-like galaxies seeded per saga: mostly spirals (two or three clumpy, dust-laned arms, warm core to bluer outskirts) seen at random tilts from face-on to edge-on, plus a few smooth ellipticals. Galaxies, like stars, are added after the cap with their own ceiling (about 26% on screen at a core). Stars are added _after_ the brightness cap, with their own small ceiling; added before it, the cap squashed them flat on top of clouds.
- **Dim by design:** the sky is a faint backdrop and the tree is the focal point. `brightness` scales everything down, then a soft-knee cap holds the brightest pixel under `maxLuma` _on screen_. The texture is sRGB, so the cap converts the on-screen limit to linear (`pow(maxLuma, 2.2)`); a linear cap of 0.12 had shown as about 38%. Measured with the tree hidden: brightest pixel under 10% on every saga, star cores up to about 25%.
- **Deterministic and per tier:** the seed comes from the saga id, so each saga has its own sky, the same every visit. Size, octaves and mipmaps come from the tier (256 px / 5 octaves / no mipmaps on low, about 1.6 MB; 1024 px / 10 octaves on high, about 34 MB). The bake runs two frames after the tree appears, so the tree draws first; a newer request supersedes an older one; a failed bake falls back to the vignette. The menu's _Nebula sky_ toggle turns it off.

### Frame loop

```ts
renderer.setAnimationLoop((now) => {
    // skip the whole frame if idle and under quality.idleFps (§5a)
    stepGraph(camera, dt, now, w, h); // graph.ts: physics, sibling overlay, highlight fades, label fade, name de-overlap
    stepCamera(dt, peopleBbox); // camera.ts: auto-fit, fly-to, held-direction pan, then OrbitControls damping
    updateFog(); // scene.ts: fog band follows the camera
    draw(); // scene.ts: with or without the glow composer
});
```

In dev builds only (`import.meta.env.DEV`), `window.__ft` exposes `{ camera, controls, graph, scene, renderer }` so browser tests can measure the camera and node positions. Production builds strip it out.

The simulation stops after about 4 s (§5). After that, `tickFrame` only animates the link particles, and idle throttling drops the frame rate.

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

## 8. Devices and GPU tiers (`src/tier.ts`, `src/device.ts`)

The app targets devices up to about seven years old (2018+): for example iPhone XR / iPad 6th gen (A10–A12), Galaxy S9 (Mali-G72 or Adreno 630) and 2017–18 laptops with Intel UHD 620. Those get a fully usable app; newer and discrete GPUs get extra fidelity. **Tiers only ever change optional visual effects and cost; every feature works at every tier.**

**Detection** runs once, synchronously, before the renderer is created (antialiasing can only be chosen at context creation), on a throwaway WebGL2 context that is released straight away. Signals, most reliable first:

1. **Capabilities:** max texture size, float render targets (`EXT_color_buffer_float` / half-float), MSAA samples. Hard limits that are never wrong: under 4096 px textures or no float targets means low, whatever the GPU name says.
2. **Renderer string** (`WEBGL_debug_renderer_info`) matched against GPU families: NVIDIA/AMD discrete, Intel Iris Xe/Arc, Apple M-series and "Apple GPU" → high; Intel UHD/Iris, AMD APUs → medium; older Intel HD → low; Adreno 650+ → high, 630–640 → medium, older → low; Mali G710+ → high, G5x–G7x → medium, older → low; Xclipse, PowerVR → medium; software renderers (SwiftShader, llvmpipe) → low. Firefox and Safari may mask the string (Safari reports every Apple GPU as "Apple GPU"), so it only refines the capability check.
3. **`deviceMemory` and `hardwareConcurrency`** for unknown GPUs, and as a cap: ≤ 2 GB forces low, ≤ 4 GB keeps mobiles out of high.

`?tier=low|medium|high` forces a tier for testing, and the result is logged (`[family-tree] quality tier: …`). `classify()` is pure, and `scripts/tier.test.mts` checks it against renderer strings real devices report, including the Galaxy S22 Ultra in both its Snapdragon (Adreno 730 → high) and Exynos (Xclipse 920 → medium) versions, plus a check that the quality table never gets cheaper as the tier rises.

**`QUALITY`** holds every cost-bearing setting in one table:

| Setting                   | Low    | Medium | High     |
| ------------------------- | ------ | ------ | -------- |
| Max pixel ratio           | 1.25   | 2      | 2        |
| MSAA                      | off    | on     | on       |
| Glow (bloom) by default   | off    | off    | on       |
| Bloom buffer scale        | 1/3    | 1/2    | 1/2      |
| Nebula face size, octaves | 256, 5 | 512, 7 | 1024, 10 |
| Nebula mipmaps            | off    | on     | on       |
| Sphere segments           | 20×12  | 32×18  | 48×24    |
| Name de-overlap interval  | 300 ms | 180 ms | 120 ms   |
| Idle frame rate           | 10 fps | 20 fps | 30 fps   |

**Other device-dependent costs:** the renderer asks for `powerPreference: "high-performance"` above low (dual-GPU laptops get the discrete GPU) and no stencil buffer. PNG export is capped by the GPU's real max texture size rather than a guess about phones. Bloom can only be enabled where half-float targets exist, so it can't render black on an unsupported GPU.

**`device.ts`** holds the result (`device`, `quality`) in its own module, so `scene.ts`, `nebula.ts`, `graph.ts` and `app.ts` all read it without importing each other: `scene.ts` imports `nebula.ts`, so nebula reading the tier from scene would be a circular import. The import graph is one-way: `tier` → `device` → `nebula`/`scene` → `camera`/`graph` → `app`.

**Measured on emulated devices** (with `?tier=`): the phone renders at 2× instead of its native 3.75× (768 × 1648 for a 384 × 824 screen), and the low-tier phone at 1.25× (400 × 822). First content: about 0.9–1.0 s on low and 1.3–2 s on high (the larger sky bake). No errors on any tier.

## 9. Extension points

- **Data loading:** an API over `db/schema.sql` (see §3). Committed GEDCOM imports already go through `scripts/gedcom-to-saga.mts` (§5c).
- **Tall trees:** a tree as deep as the Roman gods (31 generations) fits the screen as a narrow column; the camera fit could weight width over height, or the generation gap could shrink with depth.
- **Stronger parallax:** a stronger depth pull, a closer camera, or a narrower FOV with the camera moved in to compensate (see §5).
- **Per-saga themes:** add entries to `SAGA_PALETTES` in `palettes.ts` (e.g. warmer dust for Dune).
- **Relationship finder:** more in-law and step names (step-grandparents, co-parents-in-law).
- **Large trees:** for more than about 5k nodes, switch `forceEngine("ngraph")` or use instanced meshes in place of per-node objects.
