# Family Tree

An interactive 3D family tree that runs in the browser. Each person is a sphere coloured by house, marriages and parentage are links, and every generation sits on its own layer. You can orbit around the tree, zoom in and pan.

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

Each saga's `source` field gives the work, medium, author, which canon it follows, genre and what it covers. `notes` records modelling choices, such as where the sources disagree or where generations were skipped. The family data was written from memory, so check it against the source before relying on it.

Built with [three.js](https://threejs.org/), [three-forcegraph](https://github.com/vasturiano/three-forcegraph), [three-spritetext](https://github.com/vasturiano/three-spritetext), TypeScript and Vite.

## Running

```sh
npm install
npm run dev        # development server on http://localhost:5173/family-tree/
npm run build      # type-check + production bundle in dist/
npm run preview    # serve the production bundle
npm test           # check every saga in public/data (references resolve, everyone is in a family, manifest in sync)
```

### Deploying and data location

The saga data is static JSON in [public/data/](public/data/). Vite copies it to `dist/data/`, so it is served by GitHub Pages or any static host alongside the app with no extra setup.

To load data from somewhere else, such as an object store bucket (S3, Azure Blob, GCS) or an API in front of a database, set `VITE_DATA_URL` at build time:

```sh
VITE_DATA_URL=https://my-bucket.example.com/sagas npm run build
```

That base URL must serve `sagas.json` and `<id>.json` in the same shape, with CORS allowing the site's origin. [db/schema.sql](db/schema.sql) has matching relational tables.

## Controls

| Input                   | Action |
| ----------------------- | ------ |
| Left-drag / one-finger  | Orbit  |
| Scroll / pinch          | Zoom   |
| Right-drag / two-finger | Pan    |

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
