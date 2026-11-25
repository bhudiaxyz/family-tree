# Family Tree: Design and Architecture

How the app is built: what each module does, how saga data flows from JSON to the screen, and why it works the way it does. The [README](README.md) is the user-facing summary and highlights; this document is everything else: architecture, data, algorithms, build and tests, and the full controls reference (§16), for anyone changing the code.

## Contents

- [1. Overview](#1-overview)
- [2. Source layout](#2-source-layout)
- [3. Data model](#3-data-model)
    - [The data file: `SagaFile`](#the-data-file-sagafile)
    - [Database tables: `SagaRecord`](#database-tables-sagarecord)
    - [In-memory format: `Tree`](#in-memory-format-tree)
    - [Where the data comes from](#where-the-data-comes-from)
- [4. Graph construction: union nodes](#4-graph-construction-union-nodes)
- [5. Layout](#5-layout)
    - [Generations (`src/tree/generations.ts`)](#generations-srctreegenerationsts)
    - [Starting order along each row (`src/tree/row-order.ts`)](#starting-order-along-each-row-srctreerow-orderts)
    - [Forces](#forces)
    - [2D mode (`src/graph/flat.ts`)](#2d-mode-srcgraphflatts)
    - [Switching trees and the camera](#switching-trees-and-the-camera)
- [6. Highlighting (`src/graph/highlight.ts`, `src/ui/state.ts`)](#6-highlighting-srcgraphhighlightts-srcuistatets)
- [7. Interaction (`src/ui/`)](#7-interaction-srcui)
- [8. Navigation features](#8-navigation-features)
- [9. Relationship finder (`src/tree/relationship.ts`)](#9-relationship-finder-srctreerelationshipts)
- [10. GEDCOM import](#10-gedcom-import)
- [11. Files in and out: images, local files, no-WebGL](#11-files-in-and-out-images-local-files-no-webgl)
- [12. Rendering](#12-rendering)
- [13. Devices and GPU tiers (`src/render/tier.ts`, `src/render/device.ts`)](#13-devices-and-gpu-tiers-srcrendertierts-srcrenderdevicets)
- [14. Build, tests and dependencies](#14-build-tests-and-dependencies)
- [15. Extension points](#15-extension-points)
- [16. Controls reference](#16-controls-reference)

## 1. Overview

The app turns a list of people and families into a 3D graph and draws it with three.js. It is a static site: saga data is fetched as JSON, and layout, rendering and every query run in the browser. There is no server code.

```
public/data/<category>/<id>.json ─fetch─► data/source.ts ─────────► ui/sagas.ts show() ─► graph.ts showTree() ─► three.js scene
 (or VITE_DATA_URL)            expandSaga(): file → tables         reset UI state          union-node graph,      OrbitControls,
                               toTree():     tables → Tree         palette, legend         pinned generations,    frame loop in main.ts
                                                                                           d3-force-3d layout
```

The code splits into four layers, and dependencies only point downwards:

| Layer     | Modules                                                                                     | Knows about                              |
| --------- | ------------------------------------------------------------------------------------------- | ---------------------------------------- |
| UI        | `src/ui/*`                                                                                  | the DOM, app state, everything below     |
| Rendering | `src/graph/*`, `src/render/*`                                                               | three.js; the `Tree` shape; no DOM UI    |
| Logic     | `src/tree/*`: `family.ts`, `search.ts`, `relationship.ts`, `generations.ts`, `row-order.ts` | the `Tree` shape only: pure, unit-tested |
| Data      | `src/data/*`: `schema.ts`, `source.ts`, `gedcom.ts`                                         | file formats and where data lives        |

The logic layer has no three.js or DOM imports, so `npm test` runs it directly in Node against every saga.

## 2. Source layout

```
src/
  main.ts           composition root: UI start-up, frame loop, context loss (index.html loads it, with the no-WebGL fallback)
  style.css         all UI styling, every colour a :root variable
  tree/             the family logic, pure (no three.js, no DOM): family queries, relationships, rows and row order
  data/             saga file formats, loading, GEDCOM parsing
  graph/            the tree as a three.js object: nodes, links, layout forces, highlight, names, guides, 2D mode
  render/           scene, camera, labels, nebula sky, palettes, GPU tiers
  ui/               panels, menu, search, picking, keyboard, minimap, URL state
```

Folders follow the layers above, and dependencies only point downwards: `ui/` may use anything, `graph/` and `render/` (the rendering layer, which may use each other) only `tree/` and `data/` below them, and `tree/` only `data/` types, which is what lets `npm test` run it in Node.

Every source file opens with a header comment in the same shape (what the module is; **What it does**; **Usage**; **Notes**). Inside each file the order is always: imports, then types, then constants and module state, then functions, then module-level wiring (event listeners, force registrations, start-up calls), which runs last so everything it uses already exists. A constant that must be built from a helper at load time uses a `function` declaration for that helper (they hoist; arrow-function constants don't). Section dividers (`// --- … ---`) still name what each piece belongs to, though a section's state may now sit above its code. Where two modules need the same types, those go in a shared file (`graph/graph-types.ts`) rather than making the modules import each other: there are no circular imports.

| File                                             | Role                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `index.html`                                     | Page markup only: header (title, author, search, toolbar), help and chart dialogs, tour bar, relationship finder, details panel, toast, hover card, touch pad, no-WebGL notice. Loads the fonts, the favicon, `src/style.css`, and `src/main.ts` by dynamic import (showing the no-WebGL notice if it fails).                                                                                                                                                                                           |
| `src/style.css`                                  | All UI styling. Every colour, shadow, radius and text size is a variable in `:root` (§12, _Theming_); the rules below only reference them. Touch and phone rules at the end.                                                                                                                                                                                                                                                                                                                            |
| `src/main.ts`                                    | Composition root: starts the UI, handles GPU context loss, and runs the frame loop with idle throttling (§7). `index.html` loads it by dynamic import from a small inline script; if that fails (no WebGL, or the chunk won't download) the script shows the no-WebGL notice instead of a blank page.                                                                                                                                                                                                   |
| **UI**                                           |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `src/ui/state.ts`                                | Shared app state (`state`: tree, saga, selected, hovered, relationship pair, house, group, collapsed, focus, 2D, sibling mode) and `refreshHighlight()`, which turns that state into one highlight (§6); the page elements, looked up once (`$`, `el(tag, props)`), with name suggestions attached before any other listener so an open list gets Escape first; the toast, person links and fly-to; and the shareable URL: `writeUrl()` (replace) and `pushUrl()` (a history entry per person visited). |
| `src/ui/sagas.ts`                                | Saga loading (`openSaga`), `show()` (resets every per-tree state), the nebula schedule, the lil-gui menu (2D, Right-angles, Settings, `toggle2d` for the `D` key), the pinned list and start-up from the URL.                                                                                                                                                                                                                                                                                           |
| `src/ui/panel.ts`                                | Selection (`select` / `deselect`), the details panel, browsing history, recently viewed, "relative to" tags, group highlights, moving between relatives (`Alt` + arrows, `Alt` + `S`) and panel swipes.                                                                                                                                                                                                                                                                                                 |
| `src/ui/visibility.ts`                           | What's shown around the selected person: focus mode (the Focus buttons, the four sides toggle, the depth dropdown, the "nobody recorded" notice) and collapsed branches (the Collapse / Expand button and "+ n" tags). Both only change state; `refreshHighlight()` applies it.                                                                                                                                                                                                                         |
| `src/ui/guide.ts`                                | The help dialog (`?`), the chart dialog (`C`) and the guided tour (`T`) (§8).                                                                                                                                                                                                                                                                                                                                                                                                                           |
| `src/ui/legend.ts`                               | The house legend in the menu: light, frame or clear a house.                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `src/ui/navigate.ts`                             | Fit family, step zoom, generation steps, pinned people (`localStorage`), the view remembered per saga for the visit, the overlay insets the camera fits around, and the off-screen chip pointing to the selected person.                                                                                                                                                                                                                                                                                |
| `src/ui/relate.ts`                               | The relationship finder panel (§9).                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| `src/ui/picking.ts`                              | Mouse and touch picking of people, marriage nodes and links: hover, tap, double tap, long press, click again to deselect, and the hover cards (person, link, family) (§7).                                                                                                                                                                                                                                                                                                                              |
| `src/ui/input.ts`                                | Keyboard shortcuts, the touch pad, and the "Find a person" box: a name, or a relationship query (§8).                                                                                                                                                                                                                                                                                                                                                                                                   |
| `src/ui/minimap.ts`                              | The overview map: a 2D canvas, redrawn only when the view, layout or highlight changes.                                                                                                                                                                                                                                                                                                                                                                                                                 |
| `src/ui/files.ts`                                | Image export, and loading GEDCOM or saga JSON files by picker or drag-and-drop (§11).                                                                                                                                                                                                                                                                                                                                                                                                                   |
| `src/ui/suggest.ts`                              | The suggestion list shared by the search and finder boxes (replaces `<datalist>`, which many mobile browsers ignore). Each entry is a person id, so namesakes can't be confused.                                                                                                                                                                                                                                                                                                                        |
| **Rendering**                                    |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `src/graph/graph.ts`                             | Public entry for the tree as a three.js object: `showTree(tree)` builds nodes and links and pins generation heights, `generationOf()`, `peopleBbox()` for framing, `stepGraph()` per frame. Re-exports the parts below.                                                                                                                                                                                                                                                                                 |
| `src/graph/core.ts`                              | The `ThreeForceGraph` instance, person and marriage-node objects, the physics and convergence settings, `setElbowLinks()` (re-places every link), `isShown()` and the shared helpers on bound objects.                                                                                                                                                                                                                                                                                                  |
| `src/graph/graph-types.ts`                       | The graph's shared types (`Node`, `SimNode`, `Link`, `End`, `Bound`) and small helpers (`endId`, `midpoint`, `approach`), apart from `core.ts` so `links.ts` can use them without the two importing each other.                                                                                                                                                                                                                                                                                         |
| `src/graph/links.ts`                             | Link lines: a fat screen-space line per link with its own material, the path glow, and `placeLink()`: straight in 3D, right-angled connectors in 2D, with `laneOffset()` for each family's bar height (§12).                                                                                                                                                                                                                                                                                            |
| `src/graph/forces.ts`                            | The row forces, in 2D and 3D: name spacing with space between family groups, sibling and couple pulls, parents over children, and marriage nodes pinned between their parents (§5).                                                                                                                                                                                                                                                                                                                     |
| `src/graph/highlight.ts`                         | `highlight(people, opts)` sets per-object targets; `stepFades()` eases towards them each frame (§6).                                                                                                                                                                                                                                                                                                                                                                                                    |
| `src/graph/names.ts`                             | Label distance fade, name de-overlap, and the tag above each person ("relative to" words and collapse badges).                                                                                                                                                                                                                                                                                                                                                                                          |
| `src/graph/siblings.ts`                          | The sibling overlay: dashed lines and labels between consecutive siblings.                                                                                                                                                                                                                                                                                                                                                                                                                              |
| `src/graph/guides.ts`                            | Guide lines, and the "Row n" labels pinned to the left edge of the screen.                                                                                                                                                                                                                                                                                                                                                                                                                              |
| `src/graph/flat.ts`                              | 2D mode: the depth squash, the right-angled link switch and `drawnZ()` (§5).                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `src/graph/d3-force-3d.d.ts`                     | Types for the one `d3-force-3d` export used (`forceZ`).                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| `src/render/scene.ts`                            | Renderer, lights, fog, background, camera, OrbitControls, the optional bloom composer, resize, `captureView()` for image export, context-loss events. No family-tree knowledge.                                                                                                                                                                                                                                                                                                                         |
| `src/render/camera.ts`                           | Camera behaviour on top of OrbitControls: auto-fit, fly-to, fit-to-people, glide, held-direction pan, reduced motion. Frame-rate independent.                                                                                                                                                                                                                                                                                                                                                           |
| `src/render/labels.ts`                           | Name and relationship labels (`SpriteText`), house badges, `fontsReady`, and disposal.                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `src/render/palettes.ts`                         | Every colour the 3D scene uses, as one `Palette`; `paletteFor(sagaId)` (§12).                                                                                                                                                                                                                                                                                                                                                                                                                           |
| `src/render/nebula.ts`, `src/render/nebula.frag` | The procedural nebula sky, baked into a cube texture per saga (§12).                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| `src/render/tier.ts`, `src/render/device.ts`     | GPU tier detection and the quality table; the detected result shared with every module (§13).                                                                                                                                                                                                                                                                                                                                                                                                           |
| **Logic**                                        |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `src/tree/family.ts`                             | Pure family queries: lineage and roles, siblings, cousins, descendants, ancestry, tour route, relatives, link labels, house depths.                                                                                                                                                                                                                                                                                                                                                                     |
| `src/tree/search.ts`                             | Search: by name (fuzzy, `searchPeople`, `findByName`), by relationship (`searchRelation`), namesake hints (`distinguish`), forgiving house names (`houseNamed`).                                                                                                                                                                                                                                                                                                                                        |
| `src/tree/relationship.ts`                       | `relate(tree, a, b)` and `labelAll(tree, centre)` (§9).                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| `src/tree/generations.ts`                        | `generations(tree, mode)`: a row for every person, with siblings (`together`) or couples (`apart`) kept on one row (§5).                                                                                                                                                                                                                                                                                                                                                                                |
| `src/tree/row-order.ts`                          | `rowOrder(tree, rows)`: each person's starting place along their row, in unbroken sibling runs chained through marriages, then crossing-reduction sweeps; `linkCrossings()` (§5).                                                                                                                                                                                                                                                                                                                       |
| **Data**                                         |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `src/data/schema.ts`                             | `SagaFile`, `SagaRecord` and `Tree`, `expandSaga()` / `compactSaga()` between the first two, `SagaIndexEntry` and `readManifest()`, `CATEGORIES` and `sagaPath()` (§3).                                                                                                                                                                                                                                                                                                                                 |
| `src/data/source.ts`                             | `listSagas()`, `sagaTitle(entry)`, `loadSaga(entry)`, `toRecord()`, `toTree()`. The only file that knows where data comes from.                                                                                                                                                                                                                                                                                                                                                                         |
| `src/data/gedcom.ts`                             | `parseGedcom(text)`: GEDCOM 5.5, 5.5.1 and 7 → `Tree`, plus warnings (§10).                                                                                                                                                                                                                                                                                                                                                                                                                             |
| **Data files and scripts**                       |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `public/data/sagas.json`                         | The manifest: a map of saga id → category (`{ "got": "fiction", … }`), in menu order; the first loads at start-up.                                                                                                                                                                                                                                                                                                                                                                                      |
| `public/data/<category>/<id>.json`               | One `SagaFile` per saga, in its category's folder.                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| `db/schema.sql`, `db/seed.sql`                   | Relational tables matching `SagaRecord`, and a seed generated from the JSON.                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `scripts/data.mts`                               | Shared by scripts and tests: reads the manifest and sagas through `sagaPath()` and `expandSaga()`, exactly as the app does.                                                                                                                                                                                                                                                                                                                                                                             |
| `scripts/seed-sql.mts`                           | Generates `db/seed.sql`; `--check` fails if it is out of date.                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| `scripts/gedcom-to-saga.mts`                     | The GEDCOM importer, with `gedcom-source.mts` (file or URL) and `gedcom-names.mts` (display names); corrections in `gedcom-renames/` (§10).                                                                                                                                                                                                                                                                                                                                                             |
| `scripts/*.test.mts`                             | `npm test` (§14).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| `vite.config.ts`, `tsconfig.json`                | Base path `/family-tree/`, the three.js vendor chunk; strict TypeScript, type-check only.                                                                                                                                                                                                                                                                                                                                                                                                               |

## 3. Data model

Saga data has three shapes, each built from the one before:

| Shape        | Where                              | For                                     | Built by                   |
| ------------ | ---------------------------------- | --------------------------------------- | -------------------------- |
| `SagaFile`   | `public/data/<category>/<id>.json` | people writing and editing family trees | hand, or the GEDCOM import |
| `SagaRecord` | the database (`db/schema.sql`)     | storage: one array per table            | `expandSaga(file)`         |
| `Tree`       | in memory                          | the renderer, layout and logic          | `toTree(record)`           |

You only ever edit `SagaFile`s. The database seed and everything the app shows are generated from them.

### The data file: `SagaFile`

One JSON file per saga, named after its id, in its category's folder. A trimmed example (`fiction/dune.json`):

```jsonc
{
    "id": "dune", // lower-case; matches the file name and the key in sagas.json
    "title": "Dune", // shown in the menu and at the top left
    "source": {
        "work": "Dune",
        "medium": "Novel series (1965–1985); Dune, Dune Messiah, Children of Dune",
        "author": "Frank Herbert; …",
        "canon": "Novels",
        "genre": "Science fiction",
        "covers": "Houses Atreides, Harkonnen and Corrino, the Fremen, and the Bene Gesserit, through Leto II and Ghanima.",
    },
    "notes": ["Jessica is the Baron's daughter by Mohiam (revealed in the novels), so Paul is Harkonnen by blood."],
    "houses": { "Atreides": "#2e8b57", "Harkonnen": "#8a1c1c" },
    "people": [
        { "id": "leto", "name": "Duke Leto Atreides", "house": "Atreides", "sex": "m" }, // optional "born": "YYYY-MM-DD"
        { "id": "jessica", "name": "Lady Jessica", "house": "Bene Gesserit", "sex": "f" },
        { "id": "paul", "name": "Paul Atreides", "house": "Atreides", "sex": "m" },
    ],
    "families": [
        { "parents": ["leto", "jessica"], "children": ["paul", "alia"] },
        { "parents": ["paul", "chani"], "children": ["leto2", "ghanima"] },
        { "parents": ["paul", "irulan"], "children": [] },
    ],
}
```

| Field         | Meaning                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `id`, `title` | The saga's id (its file name and its key in `sagas.json`) and display title, which the menu shows.                                                                                                                                                                                                                                                                                                                                          |
| `source`      | `work`, `medium`, `author`, `canon` (which sources count), `genre` and `covers` (what the tree spans). Plain text; `author` is shown under the title.                                                                                                                                                                                                                                                                                       |
| `notes`       | Caveats for readers, e.g. where sources disagree. An empty list if there are none.                                                                                                                                                                                                                                                                                                                                                          |
| `houses`      | House (family name, or pantheon) → any CSS colour. Every person's `house` must be listed. The order is kept in the database.                                                                                                                                                                                                                                                                                                                |
| `people`      | `id` is short, lower-case and unique within the saga (`eddard`, `jon`); families and links (`?person=jon`) refer to it. `name` is what the tree shows. `sex` is `"m"` or `"f"` and picks words like _father_ or _mother_. `born` is optional: an ISO date, `YYYY-MM-DD`, with `00` for an unknown month or day (`1430-00-00` is "about 1430"); where it's recorded, people born in the same decade share a row (§5) and the panel shows it. |
| `families`    | Everyone's relationships, as a list of families (below).                                                                                                                                                                                                                                                                                                                                                                                    |

**Families.** A family is one union: `parents` (zero, one or two person ids) and `children` (zero or more). People are never linked to each other directly; everything goes through a family. That one rule covers every case:

| Situation                          | How to write it                                                                  | Example                                     |
| ---------------------------------- | -------------------------------------------------------------------------------- | ------------------------------------------- |
| A couple and their children        | `{ "parents": ["a", "b"], "children": ["c", "d"] }`                              | Eddard + Catelyn → Robb, Sansa, …           |
| A marriage with no children        | `{ "parents": ["a", "b"], "children": [] }`                                      | Daenerys + Drogo                            |
| Only one parent known              | `{ "parents": ["a"], "children": ["c"] }`                                        | Robert → Gendry                             |
| Remarriage                         | a separate family for each marriage                                              | Robert + Cersei, Jaime + Cersei             |
| Half-siblings                      | one family per set of parents, sharing the parent they have in common            | Jon, and Rhaenys and Aegon, through Rhaegar |
| Siblings whose parents are unknown | `{ "parents": [], "children": ["a", "b"] }`                                      | Gavilar and Dalinar Kholin                  |
| Adoption or fostering              | a separate family with `"adoptive": true`; the child stays in their birth family | Leia: Anakin + Padmé, and Bail + Breha      |
| Someone with no known relatives    | a one-person family: `{ "parents": ["a"], "children": [] }`                      | Skuld (Norse gods)                          |

Leave `adoptive` out unless it's true. A one-person family exists only so that "everyone is in a family" holds; the graph doesn't draw it (§4).

**Rules.** `expandSaga()` checks these whenever a file is loaded, by the app, by a dropped file and by `npm test`, and stops with a message naming the saga and family (e.g. `dune: family 7: unknown person "chanii"`):

- person ids are unique, and every `house` is listed in `houses`;
- a `born` date, if given, is `YYYY-MM-DD` (month 00–12, day 00–31; 00 is unknown);
- every id in a family is a person in the file;
- a family has at most two parents and isn't empty;
- nobody is both a parent and a child of the same family;
- everyone is in at least one family.

`trees.test.mts` also checks that the files and `sagas.json` agree: each listed saga's file exists in its category's folder, and there are no files the manifest doesn't list.

**Adding or changing a saga.**

1. Edit or create `public/data/<category>/<id>.json`. For a new saga, also add `"<id>": "<category>"` to `public/data/sagas.json`; its position is its place in the menu.
2. Run `npm run db:seed` to regenerate `db/seed.sql`, and commit it with the data.
3. Run `npm test`. It fails on any of the mistakes above, and if `seed.sql` wasn't regenerated.

To bring in a family from a genealogy program instead, use `npm run import:gedcom` (§10), which writes the file and its manifest entry.

### Database tables: `SagaRecord`

`expandSaga()` turns a file into normalised tables, one array per table, mapping one-to-one onto rows in [db/schema.sql](db/schema.sql):

| Array      | Row                               | SQL table                                              | From the file                           |
| ---------- | --------------------------------- | ------------------------------------------------------ | --------------------------------------- |
| (top)      | `id, title, source{…}`            | `saga` (+ `category` and `position` from `sagas.json`) | as written                              |
| `notes`    | string                            | `saga_note`                                            | as written                              |
| `houses`   | `{ name, color }`                 | `house`                                                | one row per `houses` entry, in order    |
| `people`   | `{ id, name, house, sex, born? }` | `person`                                               | as written                              |
| `families` | `{ id, adoptive }`                | `family`                                               | one row per family; the id is generated |
| `members`  | `{ family, person, role }`        | `family_member`                                        | one row per parent, then one per child  |

Family ids are generated from position (`dune-f1`, `dune-f2`, …), so they're never written by hand and nothing outside the database uses them. `members` is the join table, with `role` set to `parent` or `child`. Ids are scoped to the saga (the SQL primary keys are `(saga_id, id)`), so the same character id can appear in several sagas. `compactSaga()` does the reverse; the GEDCOM importer uses it to write the record it builds as a file.

**Loading it into a database.** Both files work in PostgreSQL and SQLite:

```sh
createdb family_tree && psql -d family_tree -f db/schema.sql -f db/seed.sql
sqlite3 family_tree.db "PRAGMA foreign_keys = ON;" ".read db/schema.sql" ".read db/seed.sql"   # FKs need the pragma
```

**The seed.** `scripts/seed-sql.mts` (`npm run db:seed`) generates `db/seed.sql` from the JSON:

- one `BEGIN … COMMIT` transaction;
- sagas in `sagas.json` order, stored in `saga.position`, so an API can return the menu order with `ORDER BY position`;
- per saga, `DELETE FROM saga` first, then `INSERT`s in dependency order (saga → notes → houses → people → families → members), so every foreign key holds at every statement. `ON DELETE CASCADE` on every link to `saga` (and from `family_member` to `family` and `person`) makes the delete-then-insert re-runnable, and removing a saga removes all its rows;
- laid out for reading: a header listing the sagas, a banner per saga, a heading per table, people grouped by house, and each family as its own block headed by a summary such as `-- got-f3: Rhaegar Targaryen + Lyanna Stark → Jon Snow`;
- SQL string literals with `'` doubled; booleans as `TRUE`/`FALSE`, which PostgreSQL and SQLite 3.23+ both accept.

It is excluded from Prettier because it is generated. `npm test` checks it two ways: `seed-sql.mts --check` fails if it differs from what the JSON would generate, and `seed-sql.test.mts` loads it twice into an in-memory SQLite database (Node's built-in `node:sqlite`) with foreign keys on, rebuilds every saga from the tables, asserts each matches its JSON and the manifest order, then deletes a saga and asserts nothing is left.

**Categories and paths.** `CATEGORIES` in `schema.ts` is `fiction`, `history`, `mythology`, `religion`; each is a folder and a value of `saga.category`. `sagaPath(entry)` builds `<category>/<id>.json` and is the only place that path is built, so the app, scripts and tests can't disagree. It throws on an unknown category rather than build a path from it, so a bad manifest entry can't make the loader request `../x`. Adding a category means adding it to `CATEGORIES`, to the `CHECK` constraint in `db/schema.sql`, and creating the folder.

### In-memory format: `Tree`

`toTree()` groups `members` back into `parents` and `children` and turns `houses` into a colour lookup:

```ts
type Tree = {
    title: string;
    author: string;
    people: Record<id, { name: string; house: string; sex: "m" | "f"; born?: string }>; // born: YYYY-MM-DD
    families: { parents: id[]; children: id[]; adoptive?: boolean }[];
    houseColors: Record<house, cssColor>;
};
```

Families mean the same as in the file. Adoption only changes labels and relationship words; the layout treats an adoptive family like any other.

### Where the data comes from

`source.ts` fetches `${base}/sagas.json` and `${base}/<category>/<id>.json`. `base` is `VITE_DATA_URL` if set at build time, otherwise `${BASE_URL}data`, the files in `public/data/`, which Vite copies into `dist/`:

```sh
VITE_DATA_URL=https://my-bucket.example.com/sagas npm run build
```

- **Object store** (S3, Azure Blob, GCS): upload the same files and set `VITE_DATA_URL`.
- **Database:** put an API in front of `db/schema.sql`. `toRecord()` accepts a `SagaFile` or an already normalised `SagaRecord` (told apart by its `members` array), so the API can return rows as they are.

Either way nothing outside `source.ts` changes; a host on another origin must send CORS headers. **The manifest** is only `{ "<id>": "<category>" }`, in menu order: the category locates the file, and everything else about a saga lives in that file, so there is nothing to keep in step. `readManifest()` turns it into `{ id, category }` entries and checks them (lower-case slug ids, known categories). An all-digit id is rejected because JavaScript orders integer-like object keys first, which would silently reorder the menu. The menu is built straight away with ids as labels; `sagaTitle()` then fetches every saga file in the background and each label switches to the saga's `title` as its file arrives (`OptionController.options()` refills the `<select>` in place, keeping the handler and selection). Nothing waits on those fetches: the first saga opens at once, and the browser caches the responses, so switching sagas later costs no extra download. All 17 files together are about 42 KB gzipped.

Because the URL and the menu carry only a saga id, `ui/sagas.ts` keeps the entries in a map by id, and `loadSaga(entry)` takes the entry, which includes the category. `openSaga()` shows "Loading…", ignores a response that arrives after a newer request, and on failure shows the error in the title.

## 4. Graph construction: union nodes

`showTree()` in `graph.ts` turns a `Tree` into a directed graph with two kinds of node:

- a **person node** for each entry in `people`;
- a **union node** (`family<i>`) for each family with at least two members.

and two kinds of link:

- `spouse`: parent → union;
- `child`: union → child.

```
Rhaegar ─spouse─┐                 ┌─child─► Jon
                ├─► (family2) ────┘
Lyanna  ─spouse─┘
```

This is the usual way to model genealogy as a graph. Linking people directly (spouse ↔ spouse, parent → child) creates cycles and duplicate parent edges. With union nodes every edge points from an older generation to a younger one, so the graph is a **DAG**, which the layout depends on.

A family with one parent and no children (common in imported GEDCOM files, 45 across the sagas) is skipped: drawn, it was a "father" or "mother" link to a dot leading nowhere. It stays in the data, where it keeps "everyone is in a family" true.

Sibling lines are not graph links (they'd pull siblings together and distort the layout); see §12.

## 5. Layout

`three-forcegraph` runs a `d3-force-3d` simulation: link springs, many-body repulsion and centring. The vertical position is fixed rather than simulated.

### Generations (`src/tree/generations.ts`)

`generations(tree, mode)` gives every person a row, and `showTree()` pins each node's `fy` to `GEN_GAP` (110, the same in 2D and 3D, so switching never moves rows; it was 80, which left 2D connectors too short a drop for their labels) × row, with union nodes half a row below their parents. This replaces the library's `dagMode`, which counted depth from the roots, so married-in spouses with no parents in the data (Elia Martell, Khal Drogo) floated up to the top row.

**Two modes.** Siblings, couples and "parents above children" can't all hold when someone marries into another generation (Ginny married Harry, a generation below the Weasleys). Descent always holds; `mode` says which of the other two wins:

| Mode                | Always on one row    | Lined up where possible | Menu / URL                                  |
| ------------------- | -------------------- | ----------------------- | ------------------------------------------- |
| `together` (always) | brothers and sisters | couples                 | used by the app                             |
| `apart`             | couples              | brothers and sisters    | kept in `generations.ts` and its tests only |

The algorithm is the same for both; only what's merged in step 1, and the alignment pass in step 6, differ (step 7 runs in both):

1. **Merge.** A union-find joins the people who must share a row: each family's children (`together`), or each family's co-parents (`apart`).
2. **Longest-path layering.** Kahn's algorithm runs over parent-group → child-group edges (every parent of every child), giving every group a level below all its ancestors.
3. **Pull down.** Groups are pushed down as far as their children allow, so an in-law's parents sit just above their child, not in the oldest row.
4. **Fallbacks.** Families with no parents add no edges. A child grouped with their own parent, or any cycle, can't be layered and falls back rather than throwing.
5. **Descent repair.** In a densely intermarried pantheon, step 1 chains generations together: Jupiter partners Venus, Venus partners Mars, and Mars is Jupiter's son, so the Roman gods had 55 parents on or below their own child. A pass walks parents before children and pushes any child not below _every_ parent to one row below the deepest. Only those children move.
6. **Alignment.** `together` runs `alignSpouses`: for each couple on two rows, move one partner with all their brothers and sisters (so no set splits) onto the other's row, if every parent stays above every child and fewer couples end up split. If that can't work, move the higher partner's whole branch down instead (their brothers and sisters, every ancestor with the ancestors' brothers and sisters, and anyone married into it on the same row), pushing anyone below down as needed; kept only if fewer couples split and no sibling set does. Harry Potter's line has three recorded generations and the Weasleys' two, so this puts Arthur and Molly level with James and Lily, and Ginny with Harry. Couples split across every saga: 49 → 38. `apart` runs `alignSiblings`: move a sibling (with their spouses) onto a brother's or sister's row under the same conditions, keeping couples together.
7. **Eras** (`alignEras`, both modes), only where birth dates are recorded: people born in the same decade share a row where they can. For each dated person on a different row from others of their decade, it tries moving their group (brothers and sisters, the partners on their row, and every descendant with theirs, so nothing inside the group changes shape) to the row where most of their decade sit. A move is kept only if fewer same-decade pairs are on different rows, every parent stays above every child, and no more sibling sets or couples are split: generations still come first, and dates only choose between rows the family structure allows. A tree with no dates scores 0 and is left exactly as it was, which `generations.test.mts` checks for every undated saga. On the Tudors (64 of 268 people dated) same-decade pairs on different rows went from 75 to 40 of 187, and couples split from 11 to 6; on Nehru–Gandhi (17 of 32) from 2 to 1 of 9. Its limit: someone held high by one child's long line can't move (James IV of Scotland stays on the Tudors' top row, above his 1470s peers, because his daughter Janet's descendants pin her, and moving her would part her from her husband).

Measured over all 17 sagas:

| Mode       | Sibling sets split | Couples split | Long parent→child links | Rows (Roman gods) |
| ---------- | ------------------ | ------------- | ----------------------- | ----------------- |
| `together` | 1                  | 38            | 142                     | 26                |
| `apart`    | 19                 | 35            | 201                     | 31                |

The app always uses `together` (the menu toggle and `?siblings=apart` were removed): same-generation family reading as one row is what people expect, brothers and sisters, cousins and so on side by side. With the branch move in step 6, most cross-generation marriages now line up too (Ginny sits with Harry and with her brothers). The one sibling set it still splits is a contradiction in the data, not a limit of the layout: the Roman file lists Daphne as a child of Oceanus and Tethys and also of Ladon, her own brother, so she can't be on his row and below him. `apart` is kept in `generations.ts` and its tests, as the other end of the trade.

Other approaches were measured and rejected: forcing every set onto one row after layering (couples split 35 → 158, Roman gods 31 → 217 rows); in `apart`, moving siblings together with their descendants (aligned more sets, but Harry Potter's long links went 2 → 14 and the Tudors' 19 → 59, which reads as a missing generation); and moving a branch _up_ in step 6, which left its descendants behind (Harry and Ginny's children two rows below them), so branches only ever move down.

`generations.test.mts` runs both modes on every saga: every child below _every_ parent; split-set and split-couple ratchets per mode (`LIMITS`; lower them when the layout improves, never raise them); in `apart`, couples split only in `INTERMARRIED` sagas (Roman gods, the Bible); Ginny with her brothers and with Harry, and Arthur level with James (`together`), or with Harry (`apart`); and in both, the GoT married-in spouses beside their partners and descent through Aeneas, Mars and Lot.

**Rows and generations.** The edge labels name each row's birth era where enough of its people are dated (at least 20%: "1460s", the decade of the middle birth year, with the span over the middle 60% in the tooltip, "born 1440s–1470s"; `rowEras()` in `graph.ts`), and otherwise say "Row n", because a row is a layout level. The panel's **Generation n** is the row most of the person's brothers and sisters share, with the row added when it differs ("Generation 2 (row 3)"); clicking it frames the person with their siblings.

### Starting order along each row (`src/tree/row-order.ts`)

The forces (below) only nudge people sideways, and names can't pass through each other, so the order a row starts in is roughly the order it ends in. Started at random, couples were split by strangers and siblings scattered. `rowOrder(tree, rows)` therefore gives every person a starting `x`, in three stages:

1. **Family walk, in blocks.** From the oldest row down, each family's brothers and sisters are placed as one unbroken run, in the order of their parents above (`SEED_STEP` = 26 units apart, a new group `SEED_GROUP` = 45 further along). Brothers and sisters always take precedence: one sibling who has a partner not yet placed goes at the run's right-hand end, followed by the partner and then the partner's own brothers and sisters, so families married into each other chain along the row (Starks, Eddard | Catelyn, the Tullys, Lysa | Jon Arryn, the Arryns). Other married siblings stay with their brothers and sisters, and their partners are placed with their own family. (Placing each sibling's partner beside them split the set: Catelyn sat with the Starks, away from Lysa and Edmure.) People with no recorded parents are still placed as a set where they're siblings (Gavilar and Dalinar Kholin). Each run, with the partners that chain onto it, is a **block**.
2. **Crossing sweeps.** Barycentre sweeps, as in Sugiyama-style layered drawing, reorder whole blocks, never splitting one: upwards, each row's blocks by the mean position of their children; downwards, by the mean position of their parents. Each half-sweep is kept only if it reduces crossings (`linkCrossings()`, which counts lines from each family's marriage node, between its parents, to each child on the next row, so a couple's own lines never count), for up to `SWEEPS` (4) rounds. The downward half runs last, so children end up ordered under their parents.
3. **Centring.** Each row is centred on 0.

Across every saga this took crossings from 777 to 299. `generations.test.mts` holds that as a ratchet (`MAX_CROSSINGS`) and checks that no family's children are ever split (people recorded in two families, by adoption or as Daphne is, are left out of that check).

`showTree()` seeds `x`, `y` and `z` on every node: d3 re-places a node at random if any of the three is missing, and a frame drawn before d3's first tick would frame the camera on an undefined `y`, putting the camera at NaN for good (a blank view; `stepCamera` now also refuses a framing box with a NaN in it). Marriage nodes start at their family's mean `x`.

### Forces

The library's own forces, tuned:

- **Bounded repulsion.** `charge` has `distanceMax(120)`. Every saga contains families that aren't connected, and with unlimited repulsion they pushed each other apart forever (a tree grew from 175 to over 700 units wide in 8 s).
- **Depth for parallax.** A `forceZ` pulls each house towards its own z plane, spread over `DEPTH` (240): biggest houses in the middle, alternating front and back (`houseDepths()`). It is weak (0.08), so links still shape the layout; the tree ends up about 175 deep, which is what gives panning real parallax (nearest people move about 1.24× as far as the farthest).
- **Convergence.** The library defaults (`cooldownTicks = Infinity`, `cooldownTime = 15 s`) kept the physics, auto-fit and full-rate rendering running for 15 s per load. With heights pinned there's little left to solve: `d3AlphaDecay(0.045)` and `d3VelocityDecay(0.65)` settle it in about 4 s, and `cooldownTicks(300)` / `cooldownTime(5000)` stop it hard, after which idle throttling takes over (§7).

The row forces in `src/graph/forces.ts`, which act in 2D and 3D alike:

| Force                  | What it does                                                                                                                                                                | Tuning                                                                             |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| `spreadRows`           | Neighbours on a row never overlap: each pair keeps their two name half-widths (from the name sprites) plus a gap apart, by correcting positions directly                    | gap 12; `GROUP_SPACE` 45 more between people who are neither partners nor siblings |
| `clusterSiblings`      | Brothers and sisters pull towards their family's centre                                                                                                                     | `SIBLING_PULL` 0.5 × alpha                                                         |
| `pullCouples`          | A mother and father on one row pull together until side by side (a pull only, so someone with several spouses ends up between them)                                         | `COUPLE_PULL` 0.8, `PARTNER_SPACE` 2                                               |
| `parentsOverChildren`  | A family's parents and its children pull towards each other's centre, so a couple sits over its own brood                                                                   | `OVER_PULL` 0.35 (parents move 0.6 of it, children all of it)                      |
| `unionsBetweenParents` | Each marriage node is pinned to its parents' midpoint, sideways and in depth (left to the springs it settled between the parents and their children, off to one side in 2D) | set every tick                                                                     |

`spreadRows` corrects positions rather than adding velocity: velocity kicks built up momentum against the pulls, and Game of Thrones made 188 sideways direction reversals while settling. With the correction and the higher velocity decay it makes 62, and comes to a complete rest.

### 2D mode (`src/graph/flat.ts`)

The menu's 2D toggle, the `D` key or `?view=2d` eases the graph's z scale towards about 0 (1e-3, not 0, which would make the matrices singular for raycasting), squashing the house planes flat. Each person object is counter-scaled so spheres stay round; links, sibling lines and guides simply flatten. Everything else, picking included, uses `drawnZ()` for the flattened depth. The camera turns to face the plane and rotation is disabled (`setFlatView`).

While flat, links are drawn as right-angled family-tree connectors (§12, _Links_); the menu's **Right-angles** row, shown only in 2D, switches back to straight lines. The dashed sibling lines are hidden then (the shared sibling bar already shows them), and so are the links' travelling dots (they'd run along the straight line, off the connector). Switching re-places every link directly (`setElbowLinks` in `core.ts`) rather than restarting the layout: the row forces run in both modes and the row gap is the same, so nothing the layout depends on changes. Restarting it at full energy made busy sagas shimmy for seconds.

### Switching trees and the camera

`show(tree)` in `ui/sagas.ts` resets every per-tree state (selection, relationship, group, collapsed branches, history, focus, tags), applies the palette, then calls `showTree()`. That frees the previous tree's per-person materials and label textures first (`SpriteText` makes a canvas texture per label, and these used to build up with every switch), rebuilds the sibling overlay and guides, and calls `graph.graphData()`.

The camera (`camera.ts`) has these modes, and the user always wins. All motion is frame-rate independent: easing closes `1 - exp(-rate × dt)` of the gap per frame and panning scales with `dt`, so 120 Hz behaves like 60 Hz.

| Mode       | When                                                | What it does                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| ---------- | --------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| auto-fit   | after a load or deselect, `F`, the pad's ◯          | eases towards a view fitting `peopleBbox()`: people only, the 5th–95th percentile in width on wide screens (one stray family doesn't zoom everyone out), every person in portrait, every generation in height, measured to the box centre; never smaller than 120 × 130 units, so a focus mode that leaves one person frames them at a sensible distance instead of filling the screen with their sphere. A saga's **first** view (`fitTree(true)`) is never further out than names 10 px tall (`FIRST_NAME_PX`; whole-tree fits left most sagas' names at 5–6 px), and a tree too tall to fit at that zoom, or much taller than it is wide (`TALL`, the Bible's 78 rows), opens across its width from its oldest rows (at least six rows high); `F` still shows everything |
| fit people | Fit family, a framed house, a group, focus mode     | `fitPeople(nodes)`: the same fit for a chosen set                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| flight     | selecting with `fly`, search, panel links, the tour | eases towards the person's **live** position (the layout may still be moving) for about a second                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| glide      | generation steps, the minimap, a restored view      | eases the orbit target (and optionally distance) to a point                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| user       | any OrbitControls drag, arrow key or pad press      | cancels all of the above at once, so they never pull the camera back while you're exploring                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |

With reduced motion on (the OS setting), every move jumps to its end. Switching to another saga and back restores the view you left (`rememberView` / `restoreView`, kept in memory only, so a fresh visit or a shared link starts from the whole tree).

## 6. Highlighting (`src/graph/highlight.ts`, `src/ui/state.ts`)

All highlighting runs through one function and one easing pass.

**`refreshHighlight()`** in `ui/state.ts` is the single place that decides what's lit, from `state`, in priority order:

1. a relationship pair → its connecting path, in gold;
2. a group (a relationship search or namesakes) → those people;
3. a house → its members;
4. the selected (or hovered) person → their line with roles, filtered by focus mode.

A selection, a house or a group fades everything else to `FADED` (6%), so what you chose reads clearly. A hover preview dims the rest only to the default 12%, so moving the mouse across the tree doesn't keep blanking it out.

Before any of that it collects every descendant of each collapsed person into a "folded" set (`setFolded`), hidden whatever else is lit. Every UI action that changes what should be lit changes `state` and calls `refreshHighlight()`; nothing else calls `highlight()`.

**`highlight(people, { roles, path, step, hideOthers, dim, centre })`** sets a target per object and returns; it never animates. `centre` is the selected person (a hover preview passes none).

- **Targets.** Everything outside `people` gets `dim` (12% by default; `hideOthers`, i.e. focus mode, gives 0). Links and sibling lines take the lower of their two ends. Folded people and anything touching them get 0.
- **Union nodes** light only when at least two of their members are lit (a couple, or a parent and child). With "any member" a lit parent dragged in a link to a dot leading to nobody lit: Robert's "father" link to Gendry stayed bright while only Robert was shown.
- **Direction and distance.** `lineageRoles(tree, id)` gives each person in the line its side (`self`, `ancestor`, `descendant`, `spouse`) and generation distance, breadth-first so a cousin marriage counts the shorter route. Brightness falls 12% a generation, down to 55%. Siblings and cousins focus modes build their own roles (`sibling`, `cousin`, distance 0).
- **Colour.** Each side with a colour (`palette().lineage`: ancestor rose, descendant blue, sibling green, cousin violet) gets a faint emissive tint _and_ a ring sprite in exactly that colour. The tint alone was mixed into the house colour and couldn't match the panel key; the ring always does. The panel's Focus buttons are the key: each is drawn in its side's colour with a shape (▲ ▼ ◆ ◇) so it doesn't rely on colour alone. The CSS variables must match `palettes.ts`.
- **Path.** Path people get a gold ring and glow; path links are drawn brighter, gold and wider (`LINK_PX` × 2.6), the hovered step more so, with a wide, faint additive glow line under them. A step passes through a union node, so `linksAlong()` marks both halves.
- **Selection glow.** The selected person (`centre`) gets an inner glow (emissive 0.8) and a soft additive halo sprite in their own colour, behind the sphere; the two ends of a relationship path get the full halo, the people between a softer one (0.55). Both show with the Glow (bloom) option off, so the person you're on is always easy to pick out.
- **Hovered link.** `setHoverLink(link)` (from `ui/picking.ts`) lifts the link under the pointer 0.7 of the way towards path styling, so you can see which line the hover card describes.

**`stepFades(dt)`** eases every object's opacity, glow and tint towards its target each frame (settling in about 0.3 s), so highlights fade rather than snap. Anything fully faded is made invisible, and `isShown()` (target > 0) is what picking, name de-overlap, the minimap and `peopleBbox()` test, so focus mode and collapsed branches drop out of all of them, and the camera frames only what's left, with no extra code in those modules. Labels keep the factor in `userData.dim`, which `names.ts` combines with its distance fade. **Text fades further than spheres:** below 0.5 the factor is squared for names, link labels, sibling labels and tags (`textDim`), so 12% becomes about 1.5% and 6% about 0.4%. A faint sphere still shows the tree's shape, but faint text is only clutter around the line you're reading. Lit labels (1, or 0.55–1 by distance within a line) are unchanged. **Names are the exception:** they're always shown for anyone on screen, at least `NAME_FLOOR` (35%) for a faded person, scaled down for faded people near the camera (their names are big and would shout over the line you're reading) and only to nothing as a person is hidden outright (focus mode, a collapsed branch). See §12, _Name de-overlap_.

**Per-link materials.** three-forcegraph shares one material per link colour by default, so dimming one gold link dimmed them all. Each link is our own object (`graph/links.ts`) with its own `LineMaterial`, at a resting opacity of 0.45; `stepFades` eases its opacity, colour (towards gold) and pixel width.

## 7. Interaction (`src/ui/`)

**Picking.** Each person's sphere has `userData.personId`, each marriage node's group `userData.unionId`, and each link line `userData.link`. Mouse and pen use an exact `Raycaster` hit, in priority order: a person, then a marriage node (its dot or ring), then a link, skipping anything hidden or faded below 30%. Links are fat screen-space lines, which `LineSegments2` raycasts within their width plus `raycaster.params.Line2.threshold` (3 px: enough to point at a 1.6 px line, tight enough that a click in a busy 2D area still reaches empty space; 6 px caught most clicks). A fingertip covers about 7 mm and hides what's beneath it, so a raycast often hit a sphere _in front of_ the intended one (2 of 14 test taps were wrong); touch instead picks the person whose screen centre is nearest the tap, within 28 px, falling back to the raycast (14 of 14 afterwards).

**Taps, double taps and long press** work the same for every pointer type. A tap counts only if it started on the canvas, used one pointer, and moved less than a per-type slop (5 px mouse, 8 pen, 12 touch). A second finger makes it a pinch, and `pointercancel` abandons it. Two taps on one person within 350 ms fly to them (`dblclick` is unreliable on mobile). A 450 ms touch hold previews that person's line, with a short vibration where supported. `downAt` is cleared after every `pointerup`, so a tap on a panel can never also select whoever is behind it.

**Hover card.** With a mouse, hovering previews a person's line; with someone selected, a small card says how the hovered person relates to them (`relate()`). Over a link, the card says whose it is ("Robb Stark · son of Eddard Stark & Catelyn Stark") and the link brightens; clicking it goes to the person at its end, or, if they're selected already, across the family (a child's link to their parent, a parent's to their spouse). Over a marriage node, the card names the couple and their children; clicking it lights up and frames the whole family (`showGroup`), and clicking it again clears it. The card is placed at the pointer and only follows it while no button is down, so it hides as soon as the view moves (OrbitControls `start`, the wheel, arrow keys); otherwise it stayed put while the tree rotated under it.

**Selection and history.** `select(id, fly)` in `panel.ts` is the one way in: it records the previous person in the panel's trail, pushes a browser history entry (`pushUrl`), clears any house or group, refreshes the highlight, fills the panel, and flies or refits. `deselect()` is the one way out (✕, Escape, an empty click, clicking the selected person again, clearing the search); a double click on the selected person still flies to them. An empty click also clears a house or a group, in that order. The panel's ◀ and `Backspace` walk the trail; the browser's Back walks the same entries through `popstate`.

**Details panel.** Filled from `relatives()` (parents or adoptive parents, siblings or foster siblings, spouses, children). Above the name: recently viewed people as chips (the last 3 distinct people in the trail) and the line of descent from `ancestry()`, which at each step follows the parent with the deeper recorded ancestry (father on a tie, birth before adoptive), so Rahul Gandhi's line runs through Indira to the Nehrus, not to Feroze. Long lines collapse to head, an expandable "… n more …", and tail. Under the house: the generation (click to go to that row), the number sharing the name, and the descendant count (click to show only them). Swiping the panel sideways on touch moves between siblings, as `Alt` + ← → does.

**Search** (`ui/input.ts`, `ui/suggest.ts`, `tree/search.ts`). `searchPeople()` folds names (lower case, accents and punctuation removed) and ranks exact, then a word starting with the query, then containing it, then a close spelling: one edit from 4 letters, two from 6, by optimal-string-alignment distance (a swap of neighbours is one edit). Within a tier the file's order is kept, so main figures come first. Suggestions are people, not names: the picked id is stored on the box, and namesakes get a hint from `distinguish()` (parents, else a child, else a spouse). Relationship queries are in §8.

**Keyboard** (`input.ts`). One `keydown` handler; keys are ignored while typing in an input, except Escape. `Alt` + arrows and `Alt` + `S` move between relatives (§8); `Alt` + `S` reads `e.code`, because on a Mac `Alt` + `S` types "ß". `D` switches 2D and 3D through the menu's own control (`toggle2d` in `sagas.ts`), so the checkbox stays in step. Arrow keys call `holdPan()` / `releasePan()` in `camera.ts`, which pans by 540 px a second while held, smoother than OrbitControls' own per-key-repeat step; losing window focus releases everything. A separate capture-phase listener lets Escape end a tour before an input or its suggestion list can take the key, and stops it there, so one Escape does one thing.

**Escape**, in order: end a tour, close a suggestion list, close the finder, deselect, clear a house, clear a group. Dialogs close themselves (native `<dialog>`).

**URL state** (`ui/state.ts`). `?saga`, `person`, `with`, `house`, and `view=2d|3d`. Selecting a new person adds a history entry; everything else uses `replaceState`. A person (or pair) wins over a house. At start-up, `?saga` picks the saga; a person, pair or house is applied after 1.5 s, once the layout has placed nodes and built the objects a highlight dims. An imported file has nothing shareable, so its URL keeps only `view`.

**Idle throttling.** A settled tree that nobody touches was redrawn 60 times a second for nothing. Each frame `main.ts` compares a cheap fingerprint (camera, orbit target and a stride of node positions, to one decimal); while it changes, or for 600 ms after any input, frames run at full rate. Once still, whole frames are skipped down to `quality.idleFps`. Any pointer, key, wheel or resize wakes it. Comparing real state rather than trusting "moving" flags means a forgotten flag can never freeze the view. Measured idle frames over 2 s: low 19–20 (was 48–51), medium 37, high 25.

**Touch and phones.**

- `html, body { touch-action: none }` gives pinch and drag to the 3D view, and double tap selects instead of zooming the page. Panels set `touch-action: pan-y` and `overscroll-behavior: contain`, so they scroll without moving the view.
- Controls are at least 44 px on coarse pointers, and inputs 16 px so iOS Safari doesn't zoom on focus.
- `env(safe-area-inset-*)` keeps overlays clear of the notch and home bar; `100dvh` stops the mobile URL bar cutting panels off; `visualViewport` resizes are followed.
- Below 600 px the menu starts collapsed (lil-gui sets an inline width, so the CSS needs `!important`), panels span the width, and the pad, tour bar and minimap move or hide around the open panel. In landscape the header shrinks and panels move to the side.
- Verified with real touch input (DevTools-protocol touch events, which run the browser's own gesture handling) on an emulated Pixel 7.

**Menu** (`sagas.ts`, lil-gui). The saga list; 2D, with a **Right-angles** row under it shown only while 2D is on (`controller.show()`); a **Settings** folder, closed by default, with Glow, Generation guides and Nebula sky; then the Houses and Pinned folders. Settings and Right-angles are remembered in `localStorage` (`ft.glow`, `ft.guides`, `ft.nebula`, `ft.rightAngles`); 2D comes from the URL, so links share it. The stylesheet themes lil-gui through its CSS variables to match the panels, and gives checkboxes a faint outline so an unticked one doesn't vanish into the background.

## 8. Navigation features

These are small and mostly reuse the highlight, camera and panel machinery above.

| Feature                  | How it works                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| ------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Focus mode               | In `visibility.ts`. `state.focus` is `off`, `all` (the line), `ancestors`, `descendants`, `siblings` or `cousins`; `refreshHighlight()` filters the roles and sets `hideOthers`. `focusDepth` (1, 2, 3 or all) drops anyone further than that many generations; the dropdown greys out depths beyond how far the selected person's line reaches (`showDepths`), since most fiction lines are only one or two deep and every choice looked the same. `L` toggles the line. The four side buttons toggle: pressing the one that's on turns focus off. When a side finds nobody (Cersei has no recorded cousins), a toast says so, rather than leave the person alone on screen.                                                                                     |
| Siblings, cousins        | `siblingsOf()`: anyone sharing a family as a child, half and foster siblings included. `cousinsOf()`: children of a parent's siblings, minus the person and their own siblings.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| Moving between relatives | `stepToRelative()` / `stepToSpouse()` in `panel.ts`. `Alt` + ↑ goes to the parent the line of descent follows; ↓ to the child you last came up from (a `cameUpFrom` map, checked before use), else the first child; ← → to the previous or next sibling, wrapping, or a spouse if there are none; `Alt` + `S` to a spouse, and again to the next (it starts after whoever you came from, so from Cersei, having come from Robert, it goes on to Jaime). A toast says so when there's no spouse. Swiping the panel sideways does ← →.                                                                                                                                                                                                                              |
| Off-screen chip          | `stepOffscreen()` in `navigate.ts`, every drawn frame: when the selected person projects outside 92% of the view (or behind the camera, where the projection is mirrored and flipped back), a chip with an arrow and their name sits at the screen edge in their direction, clear of the header and panel insets; clicking it flies back. It only touches the DOM when its position, angle or name changes.                                                                                                                                                                                                                                                                                                                                                       |
| Fit family (`G`)         | `immediateFamily()` (parents, siblings, spouses, children) → `fitPeople()`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| Generation steps         | `Page Up`/`Page Down` and the "Row n" edge labels `glideTo()` that row's height, keeping the sideways position (`goToGeneration()`). The panel's **Generation n** is the row most of the person's brothers and sisters share; where a sibling sits on another row than most of their brothers and sisters (the Roman gods' Daphne), the panel adds the row: "Generation 2 (row 3)". Clicking it frames the person with their siblings.                                                                                                                                                                                                                                                                                                                            |
| Houses                   | The legend button cycles: first click lights the house (`state.house`), the second frames all its members (`frameHouse` → `fitPeople`), the third clears. `?house=` is matched by `houseNamed()`, which folds case, accents and punctuation and accepts a leading "House", so `stark`, `STARK` and `House%20Stark` all find "Stark"; the URL is rewritten with the real name.                                                                                                                                                                                                                                                                                                                                                                                     |
| Groups                   | `showGroup(ids, label)` sets `state.group`, refits and toasts the count; `Esc`, an empty click or selecting anyone clears it. Used by relationship search, namesakes and marriage-node clicks (a family).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| Relationship search      | `searchRelation(tree, query)` recognises "X's word" and "word of X", singularises the word (`children` → `child`, `sons` → `son`) and maps it to a composition of hops (`up`, `down`, siblings, filtered by sex): `grandmother` is up, then up filtered to `f`. Of the people the name could mean (up to 10 search matches), the one with the most such relatives wins, so "sons of Jacob" finds Jacob (Israel)'s eleven rather than a minor Jacob with none. A query of neither shape, or an unknown word, falls through to a name search.                                                                                                                                                                                                                       |
| Namesakes                | `namesakes()`: everyone with the exact same name, offered in the panel only when there's more than one.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| Collapse branch          | In `visibility.ts`. `state.collapsed` holds people whose descendants are folded. `refreshFolds()` sets the "+ n" tags (`setFoldBadges`, sharing the tag sprite with "relative to" words, which they override) and refreshes the highlight, which hides the folded set (§6). It's all opacity, so the layout doesn't move and expanding is instant. Cleared on saga change.                                                                                                                                                                                                                                                                                                                                                                                        |
| Recently viewed          | The last 3 distinct people in the panel's trail, as chips.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| Chart (`C`)              | A native `<dialog>` with the line of descent above and descendants as nested `<details>` (first two levels open), so the browser does the folding. A `seen` set lists anyone reachable twice through intermarriage only once. Adam's 448 descendants build in about 17 ms.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| Guided tour (`T`)        | `tourLine(tree, id)`: the selected person's `ancestry()`, then on down through the child with the deepest line of descendants at each step; with nobody selected, `longestLine()` over the whole tree. Each stop calls `select(id, true)` and captions it; 4 s per stop, with pause, previous, next and end. Ending the tour (`Esc`, End tour, the play button) returns to the person it started from, or deselects, so the selection a tour leaves behind never becomes the next tour's start.                                                                                                                                                                                                                                                                   |
| Help (`?`)               | A native `<dialog>` with the shortcut list written once in `index.html`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| Pins                     | ☆ in the panel; per saga in `localStorage` under `ft.pins.<saga>`, listed in the menu's Pinned folder (hidden while empty).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| Minimap (`M`)            | A 2D canvas: one dot per person in their house colour, from the front, plus a frame for the view. It frames the 2nd–98th percentile sideways (one outlier, like the Bible's Mariam, would squash the tree into a sliver), redraws only when a fingerprint of the view and highlight changes, and click or drag `glideTo()`s there. Each redraw clears the whole pixel buffer whatever the transform and clips to the map, and the view frame is skipped when it's nearly edge-on (corners landing absurdly far away). The canvas size starts at 0, so the first `resize()` really sizes it: starting at the wide shape made it return early and left the browser's default 300 × 150 canvas, too wide and only partly cleared, which left streaks while rotating. |
| "Relative to" tags       | `labelAll(tree, id)` tags every person with their relationship to the selected one; under 1 ms for a whole saga, even Fire & Blood. Follows the selection.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |

The dialogs use native `<dialog>` with `showModal()`, which gives Escape, focus trapping and a backdrop for free; a click on the backdrop (the dialog element itself) closes it.

## 9. Relationship finder (`src/tree/relationship.ts`)

`relate(tree, a, b)` returns `{ summary, label, kind, path, steps, commonAncestors, routes, adoptive }`, or `null` if the two aren't connected. `kind` is `self`, `blood`, `spouse`, `step`, `in-law` or `path`. Graph indexes (parents, spouses) are built once per tree and cached in a `WeakMap`.

- **Blood relationships** use the standard genealogical method. The closest common ancestor gives the generations up from each side, `(ga, gb)`, which are named:

    | `ga`, `gb`  | Label                                                     |
    | ----------- | --------------------------------------------------------- |
    | 0, n        | father/mother, grand-, great-grand-… (a is above b)       |
    | n, 0        | son/daughter, grand-, great-grand-…                       |
    | 1, 1        | brother/sister                                            |
    | n, 1 / 1, n | nephew/niece, uncle/aunt: grand- at 3, great-grand- at 4… |
    | otherwise   | cousin of degree `min − 1`, removed `\|ga − gb\|` times   |

- **Half-relations:** the route meets at a single ancestor who had a partner, and that partner isn't also a common ancestor at the same distance (Aegon II is Aegon III's _half-uncle_).
- **Every route.** Intermarried families are related several ways. `allDistances()` keeps every distance to every ancestor, not just the shortest, and a meeting point counts only if no other common ancestor sits below it on both lines at those distances. The closest route is the headline (Aegon III is Baelon's _grandson_ through Daemon); the others are listed (_also great-grandson_, through Rhaenyra). Ties prefer a birth route to an adoptive one.
- **Common ancestors:** the lowest meeting points, usually a couple (Jon and Daenerys: _Aerys II & Rhaella_).
- **Step-relations:** a parent's spouse who isn't your parent (_step-mother_), a spouse's child (_step-son_), children of a parent's spouse with no parent in common (_step-brother_).
- **In-laws:** one marriage plus a blood relationship, either way round: a spouse's relative (_mother-in-law_) or a relative's spouse (_sister-in-law_), re-gendered for the first person. This named 151 in-law and 20 step pairs in Game of Thrones that were previously just "connected by marriage".
- **Further connections** only by marriage have no standard word; they're described step by step along the shortest path over parent, child and spouse links.
- **`path`** is always that shortest chain, which the highlight draws in gold (§6).

`relationship.test.mts` checks facts from the sagas and a synthetic tree laid out like the standard cousin chart; the synthetic test caught an off-by-one in the nephew line that no saga test would have.

## 10. GEDCOM import

### In the browser (`src/data/gedcom.ts`)

GEDCOM is line based: `LEVEL [@XREF@] TAG [VALUE]`. `parseGedcom()` builds the record tree from the levels, then maps records:

| GEDCOM                                                         | Tree                                                                                   |
| -------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| `INDI` with `NAME "Given /Surname/"` (or `GIVN`/`SURN`), `SEX` | person; the house is the surname; a `SEX` other than M or F becomes `m` with a warning |
| `FAM` with `HUSB`, `WIFE`, `CHIL`                              | family (at most two parents)                                                           |
| `CHIL` + `PEDI adopted`/`foster`, or `_FREL`/`_MREL`           | a separate `adoptive` family with the same parents                                     |
| `INDI` → `FAMC` + `PEDI adopted`                               | the same, when the marker is on the person's side                                      |

Birth dates come from `BIRT DATE`, else `CHR` or `BAPM` (often all a parish register has), as `YYYY-MM-DD` by `isoDate()`: `28 JAN 1456/1457` (old and new style) takes the later year, `1457-01-28`; qualifiers (`ABT`, `EST`, `CAL`, `BEF`, `AFT`, `BET … AND`) are dropped and the first date used; a missing day or month is `00`. The importer passes them into the saga file. Of the seven sample files, only the Tudors (64 people) and Nehru–Gandhi (17) record enough to use; the Bible and Norse files date a handful, the other pantheons none. It tolerates a BOM, CRLF, lower-case tags, indentation and malformed lines. Only the first `NAME` is read (later ones are alternates). A pointer to a missing person is dropped with a warning, and a birth family left empty because all its children were adopted is dropped. It throws only if there are no `INDI` records. Houses are coloured from `palette().importHouses` (40 colours, in surname order), and past those by golden-angle hues, so no two houses share a colour however many surnames a file has. Warnings go to the console.

### As a saga (`scripts/gedcom-to-saga.mts`)

```sh
npm run import:gedcom -- "English+Tudor+Royal+Family.ged" --id english-royal --category history --title "English Royal Family (Tudors)"
npm run import:gedcom -- "Greek+Gods.ged" --id greek-gods --category mythology --title "Greek Gods" --names mythology --house "Greek pantheon" --genre Mythology
npm run import:gedcom -- "https://github.com/D-Jeffrey/gedcom-samples/blob/main/…/Babylonian%2BGods.ged" --id babylonian-gods --category mythology --title "Babylonian Gods" --names mythology --house "Babylonian pantheon" --rename scripts/gedcom-renames/babylonian-gods.json
npm run db:seed    # then refresh the database seed
```

It writes `public/data/<category>/<id>.json` and adds `"<id>": "<category>"` to `sagas.json` (at the end for a new saga, in place on a re-import).

| Option                          | Meaning                                                                                                                                                                                                                                                                     |
| ------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `--id`, `--title`, `--category` | The saga's id (lower-case letters, digits, hyphens), menu title and folder.                                                                                                                                                                                                 |
| `--names person` (default)      | "Given Surname"; monarchs by regnal name (`Henry VIII`, not `Henry Tudor`); no titles or dates.                                                                                                                                                                             |
| `--names mythology`             | For deity files that put the name in the surname slot and a description in front ("queen of the Gods /Hera/"): drop the description, keep real two-part names ("Numa Pompilius").                                                                                           |
| `--house`, `--color`            | Put everyone in one house (a pantheon) instead of one per surname, and its colour.                                                                                                                                                                                          |
| `--genre`                       | The saga's genre (default `History`).                                                                                                                                                                                                                                       |
| `--rename <file.json>`          | Reviewed corrections keyed by GEDCOM record id: `"I364": ["King David of Judah and Israel", "david"]` sets the name and id; a third value sets the house. Stops if a record id isn't in the file or an id is taken. Examples, each explained, in `scripts/gedcom-renames/`. |

How it works:

- **Input** (`gedcom-source.mts`): a local path or an `https://` URL; a GitHub `blob` page link is rewritten to `raw.githubusercontent.com`. Both are capped at 20 MB (the same as in the app); downloads are cut off at 30 s and counted as they stream, so a wrong `Content-Length` can't get past the cap. A download that doesn't start with `0 HEAD` is refused, naming a proxy or web filter when the response was HTML or redirected to another host: a filter answers with its own page, status 200, which would otherwise parse as an empty tree. Tested offline.
- **Encoding:** strict UTF-8 first, then Windows-1252 (many 5.5 files say `CHAR ANSI`); decoding those as UTF-8 would corrupt names like _Auðr_.
- **Display names** (`gedcom-names.mts`, pure and tested against the samples' real patterns): no peerage titles or dates; a regnal name from a `TITL` like "King Ferdinand V of Castile and Aragon" → "Ferdinand V" ("Queen Consort" is a role and doesn't match). Only the person's own `TITL` is read; `SOUR` records also have `TITL`, which are book titles. Placeholder first names ("... /Tudor/") become "(unnamed son) Tudor".
- **Ids** are slugs of the display name, numbered in file order where they repeat, so re-importing gives the same ids. Ids chosen in `--rename` are reserved first.
- **Houses:** one per surname, the 12 largest coloured individually and the rest grouped as "Other families"; or one house with `--house`.
- **People with no relatives** get a one-person family and are listed in the notes. In the Norse file, 13 figures are linked only to 19 people the file never defines, a defect in the source; the links are dropped rather than guessed.
- **Source details:** the compiler (`SUBM`), software, date and `SOUR` titles go into `source` and `notes`.

## 11. Files in and out: images, local files, no-WebGL

- **Image export** (`savePng`, `P`). The save location is asked for _first_, because `showSaveFilePicker` needs the click or keypress that started it, and that permission expires during capture. Chromium gets a real Save dialog (name and folder); other browsers get a name prompt and a normal download. Cancelling either saves nothing. `captureView(scale, overlay)` then renders one frame at 2× the screen (capped by the GPU's max texture size) and copies the canvas into a 2D canvas in the same step, before WebGL can clear its buffer. This avoids `preserveDrawingBuffer: true`, which would cost performance every frame for an occasional export. The overlay stamps the saga title and author.
- **Loading a file** (folder button, or drag onto the page). `.json` goes through `toRecord()` and `toTree()` after a shape check (people, families and houses present), so it gets exactly the built-in sagas' validation; anything else goes to `parseGedcom()`. Files over 20 MB are refused before reading. Either is shown with `showImported()` as saga id `imported`, for the visit only, and the URL keeps only `view`.
- **No WebGL.** `index.html` loads `main.ts` by dynamic import from a small inline script. `scene.ts` throws `NoWebGLError` if there's no WebGL 2 context or `WebGLRenderer` fails (e.g. a blocklisted GPU); the script catches it and shows the notice. A failed chunk download gets the same notice with that reason.
- **Context loss** pauses the frame loop and shows a message; on `webglcontextrestored` the tree and sky are rebuilt, because GPU resources don't survive it.

## 12. Rendering

| Element         | Implementation                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Person          | A `Group`: a shared `SphereGeometry(4, …)` (48×24 on high, 20×12 on low) with its own matte `MeshStandardMaterial` in the house colour (roughness 0.78), so shape comes from the light-to-shadow gradient, not a hotspot; a `SpriteText` name above (`NAME_Y` 10), a house badge below, a tag above the name (`TAG_Y` 17.5), a gold path ring and a lineage ring, and an additive halo in the house colour for the selected person and a relationship path, all hidden until lit. Every child's local matrix is computed once and frozen (`matrixAutoUpdate = false`): three.js otherwise recomposed about five matrices per person per frame (about 20% of a frame orbiting the Bible).                                                                                                                                                                                                                                                                                                                                                                             |
| Union           | A small dot in a ring, pinned between its parents (`unionsBetweenParents`) and a little above or below the half row for its family's lane (`laneOffset`, ±9 units over four lanes); the ring grows (×1.35) while its couple is lit. Hover or click it (§7).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| Links           | Our own objects (`graph/links.ts`), a `Group` of [line, label, glow]: a fat screen-space `LineSegments2` with its own `LineMaterial`, 1.6 CSS px wide at any zoom (the library's 0.6-unit cylinders thinned to broken, shimmering sub-pixel lines when zoomed out), fogged; a relationship label; and a wide, faint additive copy for a path's glow. Every link is three segments, written in place, so its buffer never resizes. Spouse links (parent → union) are gold and labelled father/mother when the family has children, otherwise husband/wife; child links (union → child) are grey, with two travelling dots towards the child in 3D, and labelled son/daughter; "adoptive"/"adopted" in front for adoptive families. In 3D a link is straight, its label beside the person it names, at most 20 units along it (`LABEL_REACH`: on a link across several rows, Ginny's "daughter" at the midpoint sat among her brothers and read as Bill's). `linkResolution` must hold the view size in CSS px (set each frame), or widths and link picking are wrong. |
| Links in 2D     | Right-angled family-tree connectors: a parent's line drops from under their badge to the union's height and runs across to it, so a couple reads as joined by a bar; a child's line drops from the union to a sibling bar just below it (`BAR_DROP` 6), runs across and down to just above the child's name, so brothers and sisters hang off one bar. Each family's union sits in its own lane, so neighbouring families' bars never coincide, and both bars start from the union, so the lines always meet at the dot. Labels sit on each line's vertical drop. Rows are 110 apart (`GEN_GAP`), leaving the drop long enough for "son"/"daughter" to sit clear of the names.                                                                                                                                                                                                                                                                                                                                                                                       |
| Sibling line    | Dashed green `LineSegments` between consecutive children, labelled brothers/sisters/brother & sister. Not graph links (they'd distort the layout); `updateSiblings()` moves them to the live positions each frame. Hidden while 2D right-angled links are on (the sibling bar already shows them).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| Labels          | `SpriteText`, drawn to a canvas once, so the first saga waits for `document.fonts.load()` (up to 3 s). Names are Roboto Condensed 700 on two centred lines (the last word, usually the surname, on the second: half as wide, so neighbours collide far less); relationship labels Roboto 500 on a translucent dark background. Relationship labels fade from 220 to 480 units from the camera (except on a highlighted line) and fade out when under about 5–7 px tall on screen (`MIN_LABEL_PX`), where they'd only be smudges.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| Name de-overlap | A few times a second (`quality.labelDeclutterMs`) names are projected to screen boxes, sorted by priority (highlighted first, then nearest), and tested against those already placed through a coarse screen grid (near-linear; it was O(n²), about 170k comparisons for the Bible). Names never disappear: one overlapped by a more important name is drawn at 40% (`COLLIDED`). Names in the highlighted line are grown to at least 20 px tall (up to 2.5×, `MIN_NAME_PX` / `MAX_GROW`), but only where the grown name still fits; growth eases, and lifts the name and its tag clear of the sphere.                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| House badge     | A camera-facing disc in the house colour with the house's initial; one cached texture per house, ink chosen for contrast. Original artwork, no franchise sigils.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| Guides          | A faint horizontal cross at each row, and a label for each row kept on the left edge of the screen at its height, so it's there however you pan or zoom: the row's birth era ("1490s") where enough of its people are dated, else "Row n".                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| Lighting        | ACES filmic tone mapping. A strong warm key light from upper left (3.4), a low hemisphere fill (0.22), a faint `RoomEnvironment` (0.12) and a cool rim light from behind. The fallback background is a faint radial vignette.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| Fog             | Depth shading: `THREE.Fog` from 0.85 × the camera's distance to the orbit target out to that distance + 320 (`FOG_DEPTH`, sized to the tree's depth rather than the distance: at 2.4× the distance the back of the tree was hardly fogged), so people darken the further back they are and brighten as rotating brings them forward. The nebula is at infinity and isn't fogged.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| Glow            | Optional `UnrealBloomPass`, built lazily the first time glow is on; its blur buffers render at `quality.bloomScale`. `OutputPass` tone-maps, so the renderer's own tone mapping is off while the composer runs.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| Camera          | `PerspectiveCamera` (50°) with damped `OrbitControls`: enough perspective for pan parallax without fish-eye at the edges.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |

The graph is one `Object3D` in the app's own scene, which is why the app uses `three-forcegraph` rather than `3d-force-graph` (which brings its own renderer and camera): the app keeps control of the renderer, camera, controls and frame loop.

**Palettes** (`palettes.ts`). Every colour the 3D scene uses lives in one `Palette`: links, path glow, the four lineage colours, labels, sibling and guide lines, badges, lights, fog, the vignette, the nebula, the image stamp and imported house colours. House colours come from each saga's data. `paletteFor(sagaId)` merges `DEFAULT_PALETTE` with that saga's entry in `SAGA_PALETTES` (empty for now). Colours are baked into materials and textures when built, so `show()` calls `usePalette()`, `resetBadges()` and `applyScenePalette()` _before_ building the tree. The HTML UI has its own CSS variables; where they must agree the field is commented.

**Theming.** Two places hold every colour, so a re-skin touches only them:

- **The HTML UI**, in `:root` at the top of `style.css`:
    - **base colours:** `--bg`, `--surface`, `--ink`, `--gold`;
    - **shades of them:** `--ink-soft`/`-faint`/`-placeholder`, `--gold-bright`/`-muted`/`-tint`, `--line`, `--underline`;
    - **surfaces:** `--control-bg`, `--surface-hover`/`-active`/`-faint`, `--hover-bg`, `--selected-bg`, `--backdrop`;
    - **feedback:** `--error`, and shadows `--shadow-sm`/`-md`/`-lg`;
    - **shape:** `--radius`, `--radius-panel`;
    - **text sizes:** `--text-xs` … `--text-heading`, plus the fonts `--fd`/`--fb`.

    The rules below `:root` contain no colour literals. The few pixel font sizes left are tied to a glyph or a touch target (the title, the pad's arrows, the pin star, the phone overrides) and are commented where they're set.

- **The 3D scene, minimap and legend swatches**, in `palettes.ts` (`Palette`). Where the two must agree, the palette field's comment names the CSS variable: the lineage colours `--ancestor` … `--cousin`, and the gold of the path and minimap.

A new theme is a second `:root` block (or a class on `<html>`) overriding the CSS variables, plus a `Palette` in `SAGA_PALETTES` or a replacement for `DEFAULT_PALETTE`.

**Nebula sky** (`nebula.ts`). A shader on the inside of a sphere, rendered by a `CubeCamera` into a cube render target once per saga and used as `scene.background`, so it's drawn at infinity: it never moves when you pan and isn't fogged.

- Separate warped noise fields for hydrogen-alpha (crimson), oxygen-III (teal) and reflection (pale blue) dust, so colours sit side by side instead of averaging to brown, with dark dust lanes cut through.
- Sparse stars and about a dozen soft galaxies (mostly spirals at random tilts), added after the brightness cap with their own ceiling.
- **Dim by design:** a soft-knee cap holds the brightest pixel under `maxLuma` on screen, converted to linear because the texture is sRGB (a linear cap of 0.12 had shown as about 38%). Measured with the tree hidden: brightest pixel under 10% on every saga.
- Seeded from the saga id (the same sky every visit); size, octaves and mipmaps from the tier (256 px / 5 octaves on low, about 1.6 MB; 1024 px / 10 on high, about 34 MB). The bake runs two frames after the tree appears so the tree draws first, a newer request supersedes an older one, and a failed bake falls back to the vignette.

**Frame loop** (`main.ts`):

```ts
renderer.setAnimationLoop((now) => {
    // skip the whole frame if idle and under quality.idleFps (§7)
    stepGraph(camera, target, dt, now, w, h); // physics, 2D squash, sibling overlay, fades, label fade, de-overlap, names, guides
    stepCamera(dt, peopleBbox); // auto-fit, flights, glides, held pan, then OrbitControls damping
    updateFog();
    draw(); // with or without the glow composer
});
```

The simulation stops after about 4 s; after that `tickFrame` only animates link particles and idle throttling drops the rate. In dev builds only, `window.__ft` exposes `{ camera, controls, graph, scene, renderer }` for browser tests.

## 13. Devices and GPU tiers (`src/render/tier.ts`, `src/render/device.ts`)

The target is devices up to about seven years old (2018+): iPhone XR / iPad 6th gen, Galaxy S9, laptops with Intel UHD 620. **Tiers only change optional visual effects and cost; every feature works on every tier.**

**Detection** runs once, synchronously, before the renderer is created (antialiasing can only be chosen at context creation), on a throwaway WebGL2 context. Signals, most reliable first:

1. **Capabilities:** max texture size, float render targets, MSAA samples. Under 4096 px textures or no float targets means low, whatever the GPU name says.
2. **Renderer string** (`WEBGL_debug_renderer_info`) matched against GPU families: discrete NVIDIA/AMD, Intel Iris Xe/Arc, Apple M-series and "Apple GPU" → high; Intel UHD/Iris and AMD APUs → medium; older Intel HD → low; Adreno 650+ → high, 630–640 → medium; Mali G710+ → high, G5x–G7x → medium; Xclipse, PowerVR → medium; software renderers → low. Firefox and Safari may mask the string, so it only refines the capability check.
3. **`deviceMemory` and `hardwareConcurrency`** for unknown GPUs and as a cap: ≤ 2 GB forces low, ≤ 4 GB keeps mobiles out of high.

`?tier=low|medium|high` forces a tier, and the result is logged. `classify()` is pure; `tier.test.mts` checks it against real devices' renderer strings (including both Galaxy S22 Ultra variants) and that the quality table never gets cheaper as the tier rises.

| Setting                   | Low    | Medium | High     |
| ------------------------- | ------ | ------ | -------- |
| Max pixel ratio           | 1.25   | 2      | 2        |
| MSAA                      | off    | on     | on       |
| Glow by default           | off    | off    | on       |
| Bloom buffer scale        | 1/3    | 1/2    | 1/2      |
| Nebula face size, octaves | 256, 5 | 512, 7 | 1024, 10 |
| Nebula mipmaps            | off    | on     | on       |
| Sphere segments           | 20×12  | 32×18  | 48×24    |
| Name de-overlap interval  | 300 ms | 180 ms | 120 ms   |
| Idle frame rate           | 10 fps | 20 fps | 30 fps   |

Above low the renderer asks for `powerPreference: "high-performance"`; there's no stencil buffer; bloom is only offered where half-float targets exist. `device.ts` holds the result in its own module so `scene.ts`, `nebula.ts`, `graph.ts` and `main.ts` can read it without importing each other (`scene` imports `nebula`, so nebula reading from scene would be circular). Measured on emulated devices: first content in about 0.9–1.0 s on low and 1.3–2 s on high.

## 14. Build, tests and dependencies

Built with [three.js](https://threejs.org/), [three-forcegraph](https://github.com/vasturiano/three-forcegraph), [three-spritetext](https://github.com/vasturiano/three-spritetext), [lil-gui](https://lil-gui.georgealways.com/), TypeScript and Vite. The output is a static site: `dist/` runs on GitHub Pages (`.github/workflows/deploy-pages.yml` builds and deploys on push to `main`) or any static host.

```sh
npm install
npm run dev             # Vite dev server, http://localhost:5173/family-tree/
npm run build           # tsc --noEmit, then the production bundle in dist/
npm run preview         # serve dist/
npm test                # every scripts/*.test.mts, plus seed-sql.mts --check
npm run db:seed         # regenerate db/seed.sql
npm run import:gedcom   # §10
npm run format          # Prettier (format:check to verify only)
```

**Tests** run TypeScript directly with Node's `--experimental-strip-types`, with no test framework: each file is plain `assert` calls that print an `ok` line per group.

| Test                    | Checks                                                                                                                                                                                                            |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `trees.test.mts`        | every saga expands; files and manifest agree; folders match categories                                                                                                                                            |
| `family.test.mts`       | lineage, relatives, ancestry, labels, fuzzy search, namesakes, siblings, cousins, descendants, tour route, relationship search, house names (`tree/family.ts`, `tree/search.ts`)                                  |
| `relationship.test.mts` | relationship words on saga facts and a synthetic cousin chart                                                                                                                                                     |
| `generations.test.mts`  | descent under every parent; split-sibling and split-couple ratchets per mode; Ginny with her brothers and with Harry; the row order: no family's children split, and the crossing-lines ratchet (`MAX_CROSSINGS`) |
| `gedcom*.test.mts`      | the parser, display names, file/URL input (offline), and a distinct colour for every house in a 60-surname file                                                                                                   |
| `tier.test.mts`         | GPU classification and the quality table                                                                                                                                                                          |
| `seed-sql.test.mts`     | the SQL seed round-trip in SQLite                                                                                                                                                                                 |

UI behaviour (panels, dialogs, the tour, picking, the menu, 2D switching, the no-WebGL notice) is checked by driving the dev build in headless Chrome (Playwright, or the DevTools protocol directly): `window.__ft` exposes `{ camera, controls, graph, scene, renderer }` in dev builds for reading positions and the camera. Starting Chrome with `--disable-webgl --disable-webgl2` exercises the no-WebGL path.

| Package            | Purpose                                                                                                         |
| ------------------ | --------------------------------------------------------------------------------------------------------------- |
| `three`            | Rendering.                                                                                                      |
| `three-forcegraph` | The graph as a three.js object; force layout via `d3-force-3d`.                                                 |
| `d3-force-3d`      | `forceZ` for the house planes. Already a dependency of `three-forcegraph`; declared because the app imports it. |
| `three-spritetext` | Camera-facing labels.                                                                                           |
| `lil-gui`          | The menu.                                                                                                       |
| `typescript`       | Type-checking only (`noEmit`; Vite strips types).                                                               |
| `vite`             | Dev server and bundler.                                                                                         |
| `prettier`         | Formatting.                                                                                                     |

`manualChunks` puts every module whose path contains `three` into one cached vendor chunk: three.js and both graph libraries, about 770 kB minified or 200 kB gzipped, hence `chunkSizeWarningLimit: 800`. The base path is `/family-tree/`, for GitHub Pages; `dist/` runs on any static host.

## 15. Extension points

- **Data:** an API over `db/schema.sql`, or an object store, via `VITE_DATA_URL` (§3).
- **Layout modes:** the app always uses `together` (§5); `apart` is kept, tested, at the other end of the trade, and a per-saga choice could come back through the saga file if a densely intermarried pantheon reads better with it.
- **Ages:** the data has no birth years, so rows stand in for age bands through the generation structure. An optional `born` year on people (filled by the importer where a GEDCOM file has `BIRT DATE`) could let alignment prefer rows of similar age within a threshold.
- **Row order:** only one married sibling per family can sit at a join with their partner's family (§5); the others' partners sit with their own family. Choosing which sibling joins by how many crossings it saves would improve busy rows.
- **Themes:** add entries to `SAGA_PALETTES` for the 3D scene, and override the `:root` variables in `style.css` for the UI (§12, _Theming_). A light theme would mostly mean new values for `--bg`, `--surface`, `--ink` and the shadows.
- **Relationship words:** more in-law and step names (step-grandparents, co-parents-in-law), and more words for relationship search (`RELATION_WORDS` in `tree/search.ts`).
- **Tours:** `tourLine()` follows one line; scripted tours with captions per saga could replace it where a saga has a story to tell.
- **Large trees:** beyond about 5k nodes, switch to `forceEngine("ngraph")` or instanced meshes instead of an object per person; the row order's crossing count (all pairs on a row) and `rowOrder`'s block sweeps would want an indexed count too.

## 16. Controls reference

Every control, as a user meets it (the help dialog in `index.html` lists the keys; keep the two and `ui/input.ts` in step).

### Mouse and keyboard

| Do this                                       | To                                                                                                          |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| Drag                                          | Orbit (in 2D: pan)                                                                                          |
| Right-drag, or arrow keys                     | Pan                                                                                                         |
| Scroll, or `+` / `-`                          | Zoom                                                                                                        |
| `Shift` + arrow keys                          | Orbit in small steps                                                                                        |
| Hover a person                                | Preview their line; with someone selected, see how they relate                                              |
| Click a person                                | Select them and open their details; click them again, or empty space, to deselect                           |
| Double-click a person                         | Select them and fly to them                                                                                 |
| `/`                                           | Find a person, or a relationship                                                                            |
| `Alt` + arrow keys                            | Go to the selected person's parent (↑), child (↓) or sibling (← →); ↓ returns to the child you came up from |
| `Alt` + `S`                                   | Go to the selected person's spouse (again for the next)                                                     |
| Hover or click a line between people          | See whose link it is (it brightens); click to go to that person, or across the family                       |
| Hover or click a marriage dot                 | See the couple and their children; click to light up and frame the family, again to clear                   |
| `Backspace`, or the browser's Back            | Back to the person before                                                                                   |
| `G`                                           | Frame the selected person's immediate family                                                                |
| `C`                                           | Chart of the selected person's ancestors and descendants                                                    |
| `L`                                           | Show only the selected person's line (again for everyone)                                                   |
| `R`                                           | How are two people related?                                                                                 |
| `T`                                           | Guided tour down the selected person's line                                                                 |
| `F`                                           | Fit the whole tree (a saga first opens close enough to read names, from its oldest rows)                    |
| `Page Up` / `Page Down`, or a **Row n** label | Move a row up or down, or go to that row                                                                    |
| `D`                                           | Switch between 2D and 3D                                                                                    |
| `M`                                           | Show or hide the overview map                                                                               |
| `P`                                           | Save the view as an image                                                                                   |
| `Esc`                                         | Close, deselect, end a tour, or clear a highlight                                                           |
| `?`                                           | Keyboard shortcuts                                                                                          |

### Touch

| Do this                      | To                                                     |
| ---------------------------- | ------------------------------------------------------ |
| One-finger drag              | Orbit (in 2D: pan)                                     |
| Two-finger drag              | Pan                                                    |
| Pinch                        | Zoom                                                   |
| Tap a person                 | Select them; tap empty space to deselect               |
| Double-tap a person          | Select them and fly to them                            |
| Press and hold a person      | Preview their line                                     |
| Swipe the details panel ← →  | Next or previous sibling                               |
| On-screen pad (bottom right) | Hold an arrow to pan, ◯ to fit the tree, + / − to zoom |

On touch screens every control is at least 44 px tall, a tap picks the nearest person even where people overlap, and the page itself never zooms or scrolls, so pinch and drag always move the tree.

### On screen

- **Toolbar** (top left): _How are they related?_, load a file (folder), save an image (camera), tour (play) and help (?).
- **Details panel** (bottom left, once someone is selected): their relatives as links, line of descent, generation, recent people, a ☆ to pin them, _Fit family_, _Chart_, _Collapse branch_, _Tag everyone's relationship_, and the **Focus** buttons.
- **Menu** (top right): the saga, 2D (with **Right-angles** for right-angled links while in 2D), a **Settings** folder (glow, generation guides, nebula sky), the **Houses** list (click a house to light it, again to frame it, a third time to clear it) and your **Pinned** people.
- **Overview map** (bottom right): the whole tree and the part on screen; click or drag on it to move there.
- **Off-screen chip**: when the selected person is out of view, a chip at the edge of the screen points to them; click it to fly back.
