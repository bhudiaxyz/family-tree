# Family Tree

An interactive 3D family tree visualizer that runs in the browser. Each person is a sphere coloured by house, marriages and parentage are links, and every generation sits on its own layer. You can orbit around the tree, zoom in and pan.

Fourteen sample trees are included: ten from science fiction and fantasy, a historical royal family, and three pantheons. Use the **Saga** drop-down at the top right to switch between them:

| Saga                          | Author                                                 | Families                                                                            |
| ----------------------------- | ------------------------------------------------------ | ----------------------------------------------------------------------------------- |
| Game of Thrones (TV)          | David Benioff & D. B. Weiss, after George R. R. Martin | Stark, Tully, Arryn, Targaryen, Lannister, Baratheon                                |
| Fire & Blood                  | George R. R. Martin                                    | Targaryen from Aegon the Conqueror to the Dance of the Dragons; Velaryon, Hightower |
| The Lord of the Rings         | J. R. R. Tolkien                                       | Half-elven, Elendil and the Dúnedain, Rohan, Gondor                                 |
| The Silmarillion              | J. R. R. Tolkien                                       | House of Finwë, Thingol and Lúthien, down to Elrond and Elros                       |
| Dune                          | Frank Herbert                                          | Atreides, Harkonnen, Corrino, Fremen                                                |
| Harry Potter                  | J. K. Rowling                                          | Potter, Weasley, Black, Malfoy                                                      |
| Star Wars (films)             | George Lucas                                           | Skywalker, Lars, Naberrie, Organa, Solo, Palpatine                                  |
| The Wheel of Time             | Robert Jordan                                          | Mantear, Trakand, Damodred, al'Thor                                                 |
| The Stormlight Archive        | Brandon Sanderson                                      | Kholin, Davar, Kaladin's family                                                     |
| The Witcher                   | Andrzej Sapkowski                                      | Cintra's royal line from Lara Dorren to Ciri                                        |
| English Royal Family (Tudors) | Chris Phillips (GEDCOM)                                | Tudors, Plantagenets, Stewarts and the families they married into: 268 people       |
| Greek Gods                    | GEDCOM sample                                          | Olympians, Titans and heroes: 69 figures                                            |
| Norse Gods                    | GEDCOM sample                                          | Æsir, Vanir and giants: 117 figures                                                 |
| Roman Gods                    | GEDCOM sample                                          | Gods, heroes and the line of Aeneas: 322 figures                                    |
| Babylonian Gods               | Juan Ignacio Pucheu (GEDCOM)                           | The Enuma Elish creation story, Apsû and Tiamat to Marduk and Nabu: 29 figures      |
| Nehru–Gandhi Family           | Juan Ignacio Pucheu (GEDCOM)                           | Six generations from Gangadhar Nehru to Rahul, Priyanka and Varun Gandhi: 32 people |
| The Bible                     | Jeffrey Philip Stoker (GEDCOM)                         | Adam to Jesus, and the medieval lines traced from Noah: 583 people                  |

Each saga's `source` field gives the work, medium, author, which canon it follows, genre and what it covers. `notes` records modelling choices, such as where the sources disagree or where generations were skipped.

The last seven were imported from public GEDCOM sample files collected by D-Jeffrey (see [Importing a GEDCOM file as a saga](#importing-a-gedcom-file-as-a-saga)); they reproduce those files, including their gaps. The ten fiction sagas were written from memory and then reviewed saga by saga against fan wikis that cite the books (A Wiki of Ice and Fire, Tolkien Gateway, Coppermind and others). Most of those sites block automated access, so only Coppermind could actually be fetched; the rest of the review was also done from memory. One real error was found and fixed: Taringail and Moiraine Damodred are cousins, not siblings. Several house labels were corrected too. Treat the data as carefully reviewed rather than authoritative.

Built with [three.js](https://threejs.org/), [three-forcegraph](https://github.com/vasturiano/three-forcegraph), [three-spritetext](https://github.com/vasturiano/three-spritetext), TypeScript and Vite.

## Running

```sh
npm install
npm run dev        # development server on http://localhost:5173/family-tree/
npm run build      # type-check + production bundle in dist/
npm run preview    # serve the production bundle
npm test           # check saga data, generation layout, and that db/seed.sql loads and matches the JSON
npm run db:seed    # regenerate db/seed.sql from the saga files in public/data/
npm run import:gedcom -- <file.ged or https URL> --id <id> --category <c> --title "…"   # add a GEDCOM file as a saga
npm run format     # format everything with Prettier (format:check to verify only)
```

### Deploying and data location

The saga data is static JSON in [public/data/](public/data/):

```
public/data/
├── sagas.json            the manifest: every saga, in drop-down order
├── fiction/              one folder per category: fiction, history, mythology, religion
│   ├── got.json
│   └── …
├── history/              historical families
├── mythology/            pantheons
└── religion/             religious genealogies
```

Each saga's `category` in `sagas.json` (`fiction`, `history`, `mythology` or `religion`) says which folder its file is in. Vite copies the whole folder to `dist/data/`, so GitHub Pages or any static host serves it alongside the app with no extra setup.

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

| Input                                                      | Action                                                                                                                                                                                                          |
| ---------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Left-drag / one-finger drag                                | Orbit                                                                                                                                                                                                           |
| Scroll / pinch                                             | Zoom                                                                                                                                                                                                            |
| Right-drag / two-finger drag                               | Pan                                                                                                                                                                                                             |
| Arrow keys (hold)                                          | Pan left, right, up, down                                                                                                                                                                                       |
| Shift + arrow keys                                         | Orbit in small steps                                                                                                                                                                                            |
| On-screen arrow pad (touch screens only)                   | Hold to pan; the centre button refits the whole tree                                                                                                                                                            |
| Hover a person (mouse)                                     | Highlight their line; with someone selected, a card says how they're related                                                                                                                                    |
| Click / tap a person                                       | Select them and open a details panel; click empty space to deselect                                                                                                                                             |
| Double-click / double-tap a person                         | Select them and fly to them                                                                                                                                                                                     |
| Press and hold a person (touch)                            | Preview their line, like hovering with a mouse                                                                                                                                                                  |
| Click a name in the details panel                          | Jump to that relative                                                                                                                                                                                           |
| ◀ in the details panel, `Backspace`, or the browser's Back | Return to the person you were looking at before                                                                                                                                                                 |
| `Alt` + arrow keys                                         | Move to the selected person's parent (↑), child (↓) or sibling (← →)                                                                                                                                            |
| **Focus** in the details panel (or `L`)                    | Show only this person's line, or just their ancestors, descendants or siblings                                                                                                                                  |
| Type in **Find a person…** (or press `/`)                  | Search by name, ignoring accents and small typos (`apsu` finds Apsû, `Ghandi` finds Gandhi); people who share a name are told apart (_Lamech · son of Methushael_). Choosing a result selects and flies to them |
| Clear the search (✕) or press `Esc`                        | Deselect (or clear a house), and ease back to the whole tree                                                                                                                                                    |
| **How are they related?** (or press `R`)                   | Open the relationship finder (see below)                                                                                                                                                                        |
| **Import** (upload icon), or drop a `.ged` file            | Load your own family tree (see below)                                                                                                                                                                           |
| **Save image** (picture icon, or press `P`)                | Save the current view as a high-resolution image, choosing its name (and folder, in Chrome or Edge)                                                                                                             |
| `F`                                                        | Fit the whole tree in view                                                                                                                                                                                      |
| **Fit family** in the details panel (or `G`)               | Frame the selected person with their parents, siblings, spouses and children                                                                                                                                    |
| `+` / `-`, or **+** / **−** on the touch pad               | Zoom in and out                                                                                                                                                                                                 |
| `Page Up` / `Page Down`, or click a **Generation n** label | Move the view a generation up or down, or to that generation                                                                                                                                                    |
| The overview map (bottom right), or `M` to show or hide it | See the whole tree and the part on screen; click or drag on it to move there                                                                                                                                    |
| Swipe the details panel left or right (touch)              | Move to the next or previous sibling                                                                                                                                                                            |
| ☆ beside the name in the details panel                     | Pin the person; pinned people are listed in the menu's **Pinned** folder for this saga                                                                                                                          |

Any drag, zoom or pan takes the camera back from auto-framing or a fly-to straight away. If your system is set to reduce motion, camera moves jump straight to their end instead of animating.

On phones and tablets every control is at least 44 px tall, tapping a person picks the one nearest your finger even where people overlap, and the page itself never zooms or scrolls: pinch and drag always move the 3D view.

Relationship labels (mother, son, sisters…) show at the normal whole-tree view and fade out only when you zoom well out, so the view doesn't clutter. Labels on a highlighted line stay readable at any distance.

**Getting around.** The details panel shows the person's line of descent above their name (_Adam › Seth › … › Lamech ›_), each name a link; long lines collapse, and the ellipsis expands them. Under the house it counts their descendants (_428 descendants over 66 generations_); click that to show only them. **Focus** has a generations setting (1, 2, 3 or all) to limit how far up and down the line it reaches, which helps in very deep trees. Switching to another saga and back returns to where you were.

**Reading a highlight.** When you select someone, their ancestors glow warm (amber) and their descendants cool (blue), and each generation further away is a little fainter, so you can see at a glance who is above and below them. Couples' marriage rings grow while they're lit. On a relationship path, the people are ringed in gold; when it first appears a pulse runs along it from the first person to the second, and hovering a step in the finder's list lights just that hop.

### Display options

The **Sagas** menu (top right) also has:

- **Glow:** a soft bloom on the highlighted path and lit spheres. On by default only on fast GPUs.
- **Generation guides:** faint horizontal lines at each row, and "Generation n" labels that stay on the left edge of the screen however you pan or zoom.
- **2D:** flattens the tree onto one plane (animated both ways) and turns the camera to face it. Rotation is off; drag to pan, scroll or pinch to zoom. The nebula sky is unaffected.
- **Nebula sky:** a faint procedural nebula behind the tree, different for each saga. Turn it off for a plain dark background.
- **Houses:** every house with its colour and number of people. Click one to light up the whole house; click it again, choose **✕ Show all houses**, press `Esc` or click empty space to clear it.

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

GEDCOM (`.ged`) is the standard export format of genealogy software and sites: Ancestry, FamilySearch, MyHeritage, Gramps, Family Tree Maker and others. Use the **Import** (upload icon) button, or drag a file onto the page. Everything happens in your browser, and nothing is uploaded.

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
- `&view=2d` (on any of these) opens in 2D; `view=3d` is the default.

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

### Importing a GEDCOM file as a saga

The in-app **Import** (upload icon) button shows a file for the current visit only. To add a GEDCOM file to the app permanently, as a saga in the menu, run the importer. It reads a local file or an `https://` URL, writes `public/data/<category>/<id>.json` and adds the saga to `sagas.json`, and re-running it replaces both:

```sh
npm run import:gedcom -- "English+Tudor+Royal+Family.ged" --id english-royal --category history --title "English Royal Family (Tudors)"
npm run import:gedcom -- "Greek+Gods.ged" --id greek-gods --category mythology --title "Greek Gods" --names mythology --house "Greek pantheon" --genre Mythology
npm run import:gedcom -- "Bible+Family+Tree.ged" --id bible --category religion --title "The Bible" --house Bible --color "#c9ad73" --genre Religion --rename scripts/gedcom-renames/bible.json
npm run import:gedcom -- "https://github.com/D-Jeffrey/gedcom-samples/blob/main/famous%20family%20trees/religious%20figures%20and%20systems/Babylonian%2BGods.ged" --id babylonian-gods --category mythology --title "Babylonian Gods" --names mythology --house "Babylonian pantheon" --color "#4aa8c8" --genre Mythology --rename scripts/gedcom-renames/babylonian-gods.json
npm run db:seed    # then refresh the database seed
```

| Option                          | Meaning                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `--id`, `--title`, `--category` | The saga's id (lower-case letters, digits, hyphens), its menu title, and its folder.                                                                                                                                                                                                                                                                                                                                                                                                     |
| `--names person` (default)      | Names are "Given Surname". Monarchs are shown by regnal name, e.g. `Henry VIII` rather than `Henry Tudor`. Titles and dates are left out to keep names clean.                                                                                                                                                                                                                                                                                                                            |
| `--names mythology`             | For deity files, which put the god's name in the surname slot and a description in front ("queen of the Gods /Hera/"): the description is dropped and real two-part names ("Numa Pompilius") are kept.                                                                                                                                                                                                                                                                                   |
| `--house`                       | Put everyone in one house (e.g. a pantheon), instead of one house per surname.                                                                                                                                                                                                                                                                                                                                                                                                           |
| `--color`                       | The colour for that one house (default a strong red).                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| `--genre`                       | The saga's genre (default `History`).                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| `--rename <file.json>`          | Corrections for names the file writes badly, keyed by GEDCOM record id. `"I364": ["King David of Judah and Israel", "david"]` sets the display name and the person's id (used in links); a third value, `["Swarup Rani", "swarup-rani", "Nehru"]`, also sets their house, for a name with the given name in the surname slot. The importer stops if a record id isn't in the file or a chosen id is already taken. Examples, each explaining its corrections: `scripts/gedcom-renames/`. |

**From a URL.** Give an `https://` address instead of a file. A GitHub page link (`github.com/…/blob/…`) is fetched as the raw file, so you can paste the address from the browser. Downloads are limited to 20 MB and 30 seconds. If what comes back isn't a GEDCOM file, the importer stops rather than import an empty tree; the usual cause is a proxy or company web filter that blocks file-hosting sites (including `raw.githubusercontent.com`) and returns its own web page instead. In that case download the file another way and import the local copy.

The importer handles GEDCOM 5.5 to 7 and both UTF-8 and older "ANSI" (Windows-1252) files. Unrecorded first names ("... Tudor") become "(unnamed son) Tudor". People with no recorded relatives are kept, on their own. Anything it couldn't resolve, such as a link to someone the file never defines, is listed in the saga's notes.

## Licence

MIT, see [LICENSE](LICENSE).
