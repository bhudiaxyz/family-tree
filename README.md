# Family Tree

An interactive 3D family tree that runs in the browser. Each person is a sphere coloured by house, marriages and parentage are links, and every generation sits on its own row. Orbit, zoom and pan around the tree, or flatten it to 2D, then search, trace lines of descent and ask how any two people are related.

## Sagas

Seventeen trees are included. Pick one from the **Saga** menu at the top right.

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

The ten fiction sagas were written from memory and reviewed against fan wikis that cite the books; treat them as carefully reviewed rather than authoritative. The seven GEDCOM sagas reproduce public sample files collected by D-Jeffrey, gaps included. Each saga records its sources and modelling choices in its `source` and `notes` fields.

## Highlights

- **Generations on rows.** Brothers and sisters share a row and sit together, each couple sits side by side above their own children, and families are spaced apart so each reads as a group. Ancestors glow rose and descendants blue, fading with each generation away. The selected person, and everyone on a relationship path, get a soft halo. In 2D, links are drawn as right-angled family-tree connectors (or straight, if you prefer), each family's bars in its own lane so they don't overlap. Names sit on two centred lines and are always shown.
- **Search that forgives.** Accents and small typos don't matter (`apsu` finds Apsû, `Ghandi` finds Gandhi), and people who share a name are told apart. Type a relationship to find people by it: _Arya's cousins_, _children of Zeus_, _sons of Jacob_.
- **How are they related?** Pick any two people for a plain-English answer (_Jon Snow is the nephew of Daenerys Targaryen_): cousins by degree and removal, half-, step- and in-law relations, adoption, common ancestors, and every route between intermarried houses, with the path drawn in gold.
- **Focus on part of the tree.** Show just one person's line, ancestors, descendants, siblings or first cousins, limited to a few generations if you like. Collapse a branch to fold its descendants away.
- **Find your way around.** The details panel shows the line of descent, the generation, recently viewed people and pinned favourites. There's an outline chart for each person, an overview map, a guided tour down a line, and Back to retrace your steps.
- **Houses.** Light up a house to see how it spreads through the tree, then frame all its members.
- **Your own family.** Load a GEDCOM file from any genealogy program, or a saga JSON file, straight in the browser. Nothing is uploaded.
- **Share a view.** The address bar tracks the saga, person, relationship, house, and 2D/3D, so any view can be bookmarked or shared.
- **Runs on most devices.** Desktops, tablets and phones from about 2018 onwards. Quality adjusts to the device's graphics, every feature works everywhere, and it redraws rarely when idle to save battery.

## Controls

Press `?` in the app for the full list of keyboard shortcuts.

### Mouse and keyboard

| Do this                                       | To                                                                                                          |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| Drag                                          | Orbit (in 2D: pan)                                                                                          |
| Right-drag, or arrow keys                     | Pan                                                                                                         |
| Scroll, or `+` / `-`                          | Zoom                                                                                                        |
| `Shift` + arrow keys                          | Orbit in small steps                                                                                        |
| Hover a person                                | Preview their line; with someone selected, see how they relate                                              |
| Click a person                                | Select them and open their details; click empty space to deselect                                           |
| Double-click a person                         | Select them and fly to them                                                                                 |
| `/`                                           | Find a person, or a relationship                                                                            |
| `Alt` + arrow keys                            | Go to the selected person's parent (↑), child (↓) or sibling (← →); ↓ returns to the child you came up from |
| `Alt` + `S`                                   | Go to the selected person's spouse (again for the next)                                                     |
| Hover or click a line between people          | See whose link it is; click to go to that person, or across the family                                      |
| `Backspace`, or the browser's Back            | Back to the person before                                                                                   |
| `G`                                           | Frame the selected person's immediate family                                                                |
| `C`                                           | Chart of the selected person's ancestors and descendants                                                    |
| `L`                                           | Show only the selected person's line (again for everyone)                                                   |
| `R`                                           | How are two people related?                                                                                 |
| `T`                                           | Guided tour down the selected person's line                                                                 |
| `F`                                           | Fit the whole tree (a saga first opens close enough to read names, from its oldest rows)                    |
| `Page Up` / `Page Down`, or a **Row n** label | Move a row up or down, or go to that row                                                                    |
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

## Getting started

```sh
npm install
npm run dev        # http://localhost:5173/family-tree/
npm test           # data, layout, relationships, GEDCOM, database seed
npm run build      # type-check and build into dist/
```

Built with [three.js](https://threejs.org/), [three-forcegraph](https://github.com/vasturiano/three-forcegraph), [three-spritetext](https://github.com/vasturiano/three-spritetext), TypeScript and Vite. The output is a static site: `dist/` runs on GitHub Pages or any static host.

To add a saga of your own, write a JSON file or import a GEDCOM file with `npm run import:gedcom`. [DESIGN.md](DESIGN.md) covers the data format, the importer, loading data from a database or object store, and how the app works inside.

## Licence

MIT, see [LICENSE](LICENSE).
