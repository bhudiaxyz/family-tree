# Family Tree

An interactive 3D family tree visualizer that runs in the browser. Each person is a sphere coloured by house, marriages and parentage are links, and every generation sits on its own layer. You can orbit around the tree, zoom in and pan.

Ten sample trees from science fiction and fantasy are included. Use the **Saga** drop-down at the top right to switch between them:

| Saga                   | Author                                                 | Families                                                                            |
| ---------------------- | ------------------------------------------------------ | ----------------------------------------------------------------------------------- |
| Game of Thrones (TV)   | David Benioff & D. B. Weiss, after George R. R. Martin | Stark, Tully, Arryn, Targaryen, Lannister, Baratheon                                |
| Fire & Blood           | George R. R. Martin                                    | Targaryen from Aegon the Conqueror to the Dance of the Dragons; Velaryon, Hightower |
| The Lord of the Rings  | J. R. R. Tolkien                                       | Half-elven, Elendil and the Dúnedain, Rohan, Gondor                                 |
| The Silmarillion       | J. R. R. Tolkien                                       | House of Finwë, Thingol and Lúthien, down to Elrond and Elros                       |
| Dune                   | Frank Herbert                                          | Atreides, Harkonnen, Corrino, Fremen                                                |
| Harry Potter           | J. K. Rowling                                          | Potter, Weasley, Black, Malfoy                                                      |
| Star Wars (films)      | George Lucas                                           | Skywalker, Lars, Naberrie, Organa, Solo, Palpatine                                  |
| The Wheel of Time      | Robert Jordan                                          | Mantear, Trakand, Damodred, al'Thor                                                 |
| The Stormlight Archive | Brandon Sanderson                                      | Kholin, Davar, Kaladin's family                                                     |
| The Witcher            | Andrzej Sapkowski                                      | Cintra's royal line from Lara Dorren to Ciri                                        |

Each saga's `source` field gives the work, medium, author, which canon it follows, genre and what it covers. `notes` records modelling choices, such as where the sources disagree or where generations were skipped.

The family data was written from memory and then reviewed saga by saga against fan wikis that cite the books (A Wiki of Ice and Fire, Tolkien Gateway, Coppermind and others). Most of those sites block automated access, so only Coppermind could actually be fetched; the rest of the review was also done from memory. One real error was found and fixed: Taringail and Moiraine Damodred are cousins, not siblings. Several house labels were corrected too. Treat the data as carefully reviewed rather than authoritative.

Built with [three.js](https://threejs.org/), [three-forcegraph](https://github.com/vasturiano/three-forcegraph), [three-spritetext](https://github.com/vasturiano/three-spritetext), TypeScript and Vite.

## Running

```sh
npm install
npm run dev        # development server on http://localhost:5173/family-tree/
npm run build      # type-check + production bundle in dist/
npm run preview    # serve the production bundle
npm test           # check saga data, generation layout, and that db/seed.sql loads and matches the JSON
npm run db:seed    # regenerate db/seed.sql from the saga files in public/data/
npm run format     # format everything with Prettier (format:check to verify only)
```

### Deploying and data location

The saga data is static JSON in [public/data/](public/data/):

```
public/data/
├── sagas.json            the manifest: every saga, in drop-down order
├── fiction/              one folder per category
│   ├── got.json
│   └── …
└── history/              (for historical families)
```

Each saga's `category` in `sagas.json`, `fiction` or `history`, says which folder its file is in. Vite copies the whole folder to `dist/data/`, so GitHub Pages or any static host serves it alongside the app with no extra setup.

To load data from somewhere else, such as an object store bucket (S3, Azure Blob, GCS) or an API in front of a database, set `VITE_DATA_URL` at build time:

```sh
VITE_DATA_URL=https://my-bucket.example.com/sagas npm run build
```

That base URL must serve `sagas.json` and `<category>/<id>.json` in the same shape, with CORS allowing the site's origin.

### Loading the data into a database

[db/schema.sql](db/schema.sql) creates the tables, and [db/seed.sql](db/seed.sql) fills them with every saga in `public/data/`. Both work in PostgreSQL and SQLite:

```sh
# PostgreSQL
createdb family_tree
psql -d family_tree -f db/schema.sql -f db/seed.sql

# SQLite (foreign keys are checked only with the pragma on)
sqlite3 family_tree.db "PRAGMA foreign_keys = ON;" ".read db/schema.sql" ".read db/seed.sql"
```

The seed runs in one transaction and can be re-run: each saga is deleted first, and the schema's `ON DELETE CASCADE` rules remove its rows from every table. `seed.sql` is generated, so edit the JSON and run `npm run db:seed` rather than editing it by hand. `npm test` fails if it is out of date.

## Controls

| Input                                     | Action                                                               |
| ----------------------------------------- | -------------------------------------------------------------------- |
| Left-drag / one-finger drag               | Orbit                                                                |
| Scroll / pinch                            | Zoom                                                                 |
| Right-drag / two-finger drag              | Pan                                                                  |
| Arrow keys (hold)                         | Pan left, right, up, down                                            |
| Shift + arrow keys                        | Orbit in small steps                                                 |
| On-screen arrow pad (touch screens only)  | Hold to pan; the centre button refits the whole tree                 |
| Hover a person (mouse)                    | Highlight their line: ancestors, descendants and spouses; others dim |
| Click / tap a person                      | Select them and open a details panel; click empty space to deselect  |
| Double-click / double-tap a person        | Select them and fly to them                                          |
| Press and hold a person (touch)           | Preview their line, like hovering with a mouse                       |
| Click a name in the details panel         | Jump to that relative                                                |
| Type in **Find a person…** (or press `/`) | Search by name; choosing a result selects and flies to them          |
| Clear the search (✕) or press `Esc`       | Deselect, and ease back to the whole tree                            |
| **How are they related?** (or press `R`)  | Open the relationship finder (see below)                             |
| **Import GEDCOM**, or drop a `.ged` file  | Load your own family tree (see below)                                |
| **Save PNG** (or press `P`)               | Download the current view as a high-resolution image                 |
| `F`                                       | Fit the whole tree in view                                           |

Any drag, zoom or pan takes the camera back from auto-framing or a fly-to straight away. If your system is set to reduce motion, camera moves jump straight to their end instead of animating.

On phones and tablets every control is at least 44 px tall, tapping a person picks the one nearest your finger even where people overlap, and the page itself never zooms or scrolls: pinch and drag always move the 3D view.

Relationship labels (mother, son, sisters…) fade out with distance so the view doesn't clutter; zoom in to read them. Labels on a highlighted line stay readable at any distance.

### Display options

The **Sagas** menu (top right) also has:

- **Glow:** a soft bloom on the highlighted path and lit spheres. On by default only on fast GPUs.
- **Generation guides:** faint horizontal lines and "Generation n" labels at each row.
- **Nebula sky:** a faint procedural nebula behind the tree, different for each saga. Turn it off for a plain dark background.

Your choices are remembered on this device.

### Relationship finder

Pick two people, by typing their names or by clicking them in the 3D view while the finder is open. It tells you how the first person is related to the second, e.g. _"Jon Snow is the nephew of Daenerys Targaryen"_, lists each step of the connection, and highlights the path in gold. It names:

- direct lines: son, grandmother, great-great-grandson…
- siblings and half-siblings;
- aunts, uncles, nieces and nephews, including grand- and great-grand-;
- cousins by degree and removal, e.g. _second cousin once removed_;
- in-laws: mother-in-law, sister-in-law, uncle by marriage…;
- step-relations: step-mother, step-son, step-brother…;
- spouses, and longer connections only by marriage, which it describes step by step;
- adoption, flagged as _(by adoption)_.

It also shows their **closest common ancestors** (e.g. _Aerys II & Rhaella_ for Jon and Daenerys). When two people are related in more than one way, which is common among the Targaryens, the closest relationship is the headline and the others are listed too, e.g. _"Also related as: great-grandson"_. ⇅ swaps the two people, and the link `?saga=got&person=jon&with=daenerys` opens straight to a relationship.

### Everyone's relationship to one person

Select a person and press **Tag everyone's relationship** in their details panel: every other person in the tree gets a small tag saying how they relate to them (uncle, second cousin, sister-in-law…). The tags follow your selection; press the button again to hide them.

### Importing your own family (GEDCOM)

GEDCOM (`.ged`) is the standard export format of genealogy software and sites: Ancestry, FamilySearch, MyHeritage, Gramps, Family Tree Maker and others. Use **Import GEDCOM**, or drag a file onto the page. Everything happens in your browser, and nothing is uploaded.

- **Supported:** GEDCOM 5.5, 5.5.1 and 7. People, marriages and children are imported, and adoptions are recognised whether they're marked on the child's family link or with Ancestry/FTM's `_FREL`/`_MREL` tags.
- **Houses:** people are grouped and coloured by surname.
- **Problems are reported, not fatal:** a missing sex (shown as male, because the labels need one), or a link to a person who isn't in the file, is listed in the browser console after import.
- An imported tree isn't saved and can't be shared by link. Choosing a saga from the menu replaces it.

### Devices

It runs on desktops, laptops, tablets and phones up to about seven years old (2018 and later: for example an iPhone XR or iPad 6th generation, a Galaxy S9, or a laptop with Intel UHD 620 graphics). On start-up it checks the device's graphics and picks a quality tier, low, medium or high. That sets the render resolution, antialiasing, the glow default, the sky's detail and how often it redraws when nothing is moving. Every feature works on every tier; only optional visual effects differ. Older devices get a lighter, smoother version, and newer ones get the extra detail. Add `?tier=low`, `?tier=medium` or `?tier=high` to the address to force a tier, e.g. to preview how it looks on an older phone.

When nothing is moving, it redraws far less often to save battery, and wakes instantly when you touch, click or press a key.

### When 3D isn't available

The app needs WebGL 2. Without it, for example with hardware acceleration turned off, an old browser or a blocklisted GPU, it shows an explanation and what to try instead of a blank page. If the graphics context is lost mid-session (a driver reset or too many tabs), it pauses and resumes once the browser restores it.

### Shareable links

The address bar tracks what you're looking at, so any view can be shared or bookmarked:

- `?saga=dune` opens a saga.
- `?saga=starwars&person=leia` opens a saga with a person selected.
- `?saga=got&person=jon&with=daenerys` opens the relationship finder for two people.

Unknown sagas fall back to the first one, and unknown people are ignored.

## Using your own family

Copy one of the saga files, for example [fiction/got.json](public/data/fiction/got.json), into the folder for its category (`public/data/fiction/` or `public/data/history/`) as `<id>.json`. Then add `{ id, category, title, work, author }` to [sagas.json](public/data/sagas.json), with `category` matching the folder. The order of `sagas.json` sets the drop-down order, and the first entry loads at startup. `npm test` checks that every file is in its category's folder and that nothing is missing or left over. Each saga file holds normalised tables, one row per item, ready to map onto a database:

- `id`, `title`, `source` (work, medium, author, canon, genre, covers) and `notes`. The title is shown at the top left, with `source.author` in smaller italics beneath it.
- `houses`: `{ name, color }`, where `color` is any CSS colour.
- `people`: `{ id, name, house, sex }`. `sex` (`"m"` or `"f"`) picks the link labels: father/mother, son/daughter, brothers/sisters.
- `families`: `{ id, adoptive }`. Each family is one union. A remarriage is another family. `adoptive: true` changes the labels to adoptive father/mother and adopted son/daughter.
- `members`: `{ family, person, role }`, where `role` is `"parent"` (0–2 per family) or `"child"`. A family with no parent rows groups siblings whose parents are unknown.

Run `npm test` afterwards to catch typos in ids.

See [DESIGN.md](DESIGN.md) for how the data becomes a 3D graph.

## Licence

MIT, see [LICENSE](LICENSE).
