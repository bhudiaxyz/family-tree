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
npm run db:seed    # regenerate db/seed.sql from public/data/*.json
npm run format     # format everything with Prettier (format:check to verify only)
```

### Deploying and data location

The saga data is static JSON in [public/data/](public/data/). Vite copies it to `dist/data/`, so it is served by GitHub Pages or any static host alongside the app with no extra setup.

To load data from somewhere else, such as an object store bucket (S3, Azure Blob, GCS) or an API in front of a database, set `VITE_DATA_URL` at build time:

```sh
VITE_DATA_URL=https://my-bucket.example.com/sagas npm run build
```

That base URL must serve `sagas.json` and `<id>.json` in the same shape, with CORS allowing the site's origin.

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
| Double-click a person                     | Select them and fly to them                                          |
| Click a name in the details panel         | Jump to that relative                                                |
| Type in **Find a person…** (or press `/`) | Search by name; choosing a result selects and flies to them          |
| Clear the search (✕) or press `Esc`       | Deselect, and ease back to the whole tree                            |
| **How are they related?** (or press `R`)  | Open the relationship finder (see below)                             |
| **Import GEDCOM**, or drop a `.ged` file  | Load your own family tree (see below)                                |
| **Save PNG** (or press `P`)               | Download the current view as a high-resolution image                 |
| `F`                                       | Fit the whole tree in view                                           |

Any drag, zoom or pan takes the camera back from auto-framing or a fly-to straight away. If your system is set to reduce motion, camera moves jump straight to their end instead of animating.

### Relationship finder

Pick two people, by typing their names or by clicking them in the 3D view while the finder is open. It tells you how the first person is related to the second, e.g. _"Jon Snow is the nephew of Daenerys Targaryen"_, lists each step of the connection, and highlights the path in gold. It names:

- direct lines: son, grandmother, great-great-grandson…
- siblings and half-siblings;
- aunts, uncles, nieces and nephews, including grand- and great-grand-;
- cousins by degree and removal, e.g. _second cousin once removed_;
- spouses, and connections only by marriage, which it describes step by step;
- adoption, flagged as _(by adoption)_.

When two people are related in more than one way, which is common among the Targaryens, it reports the closest relationship. ⇅ swaps the two people, and the link `?saga=got&person=jon&with=daenerys` opens straight to a relationship.

### Importing your own family (GEDCOM)

GEDCOM (`.ged`) is the standard export format of genealogy software and sites: Ancestry, FamilySearch, MyHeritage, Gramps, Family Tree Maker and others. Use **Import GEDCOM**, or drag a file onto the page. Everything happens in your browser, and nothing is uploaded.

- **Supported:** GEDCOM 5.5, 5.5.1 and 7. People, marriages and children are imported, and adoptions are recognised whether they're marked on the child's family link or with Ancestry/FTM's `_FREL`/`_MREL` tags.
- **Houses:** people are grouped and coloured by surname.
- **Problems are reported, not fatal:** a missing sex (shown as male, because the labels need one), or a link to a person who isn't in the file, is listed in the browser console after import.
- An imported tree isn't saved and can't be shared by link. Choosing a saga from the menu replaces it.

### When 3D isn't available

The app needs WebGL 2. Without it, for example with hardware acceleration turned off, an old browser or a blocklisted GPU, it shows an explanation and what to try instead of a blank page. If the graphics context is lost mid-session (a driver reset or too many tabs), it pauses and resumes once the browser restores it.

Relationship labels (mother, son, sisters…) fade out with distance so the view doesn't clutter; zoom in to read them. Labels on a highlighted line stay readable at any distance.

### Shareable links

The address bar tracks what you're looking at, so any view can be shared or bookmarked:

- `?saga=dune` opens a saga.
- `?saga=starwars&person=leia` opens a saga with a person selected.
- `?saga=got&person=jon&with=daenerys` opens the relationship finder for two people.

Unknown sagas fall back to the first one, and unknown people are ignored.

## Using your own family

Copy one of the files in [public/data/](public/data/), for example [got.json](public/data/got.json), as `<id>.json`. Then add `{ id, title, work, author }` to [sagas.json](public/data/sagas.json), which sets the drop-down order; the first entry loads at startup. Each saga file holds normalised tables, one row per item, ready to map onto a database:

- `id`, `title`, `source` (work, medium, author, canon, genre, covers) and `notes`. The title is shown at the top left, with `source.author` in smaller italics beneath it.
- `houses`: `{ name, color }`, where `color` is any CSS colour.
- `people`: `{ id, name, house, sex }`. `sex` (`"m"` or `"f"`) picks the link labels: father/mother, son/daughter, brothers/sisters.
- `families`: `{ id, adoptive }`. Each family is one union. A remarriage is another family. `adoptive: true` changes the labels to adoptive father/mother and adopted son/daughter.
- `members`: `{ family, person, role }`, where `role` is `"parent"` (0–2 per family) or `"child"`. A family with no parent rows groups siblings whose parents are unknown.

Run `npm test` afterwards to catch typos in ids.

See [DESIGN.md](DESIGN.md) for how the data becomes a 3D graph.

## Licence

MIT, see [LICENSE](LICENSE).
