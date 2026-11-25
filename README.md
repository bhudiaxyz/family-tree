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

- **A tree that reads like one.** Every generation has its own row, with families married into one another kept level (Harry and Ginny share a row, and so do their parents). Brothers and sisters sit together, each couple sits above its own children, and family groups are spaced apart, arranged so that as few lines cross as possible. Where birth dates are known (Harry Potter, the Tudors, the Nehru–Gandhi family), people born in the same decade share a row and each row is labelled with its era (_1490s_). Names sit on two lines and are always shown.
- **3D or 2D.** Orbit a 3D tree, where people further back darken and brighten as they turn towards you, or flatten it to 2D with classic right-angled family-tree connectors (or straight lines, if you prefer). Press `D` to switch.
- **See whose line it is.** Ancestors glow rose and descendants blue, fading with each generation away. The selected person and anyone on a relationship path get a soft halo. Hover a line or a marriage dot to see whose it is; click it to follow it or to light up the whole family.
- **Search that forgives.** Accents and small typos don't matter (`apsu` finds Apsû, `Ghandi` finds Gandhi), and people who share a name are told apart. Type a relationship to find people by it: _Arya's cousins_, _children of Zeus_, _sons of Jacob_.
- **How are they related?** Pick any two people for a plain-English answer (_Jon Snow is the nephew of Daenerys Targaryen_): cousins by degree and removal, half-, step- and in-law relations, adoption, common ancestors, and every route between intermarried houses, with the path drawn in gold.
- **Focus on part of the tree.** Show just one person's line, ancestors, descendants, siblings or first cousins, limited to a few generations if you like. Collapse a branch to fold its descendants away.
- **Find your way around.** Step between parents, children, siblings and spouses from the keyboard. The details panel shows the line of descent, the generation, recently viewed people and pinned favourites. There's an outline chart for each person, an overview map, a guided tour down a line, a pointer back to the selected person when they're off screen, and Back to retrace your steps.
- **Houses.** Light up a house to see how it spreads through the tree, then frame all its members.
- **Your own family.** Load a GEDCOM file from any genealogy program, or a saga JSON file, straight in the browser; every surname gets a colour of its own. Nothing is uploaded.
- **Share a view.** The address bar tracks the saga, person, relationship, house, and 2D/3D, so any view can be bookmarked or shared.
- **Runs on most devices.** Desktops, tablets and phones from about 2018 onwards, by mouse, keyboard or touch. Quality adjusts to the device's graphics, every feature works everywhere, and it redraws rarely when idle to save battery.

Press `?` in the app for the keyboard shortcuts. [DESIGN.md](DESIGN.md) has everything else: the full controls reference, getting started and building, the data format and adding a saga, and how the app works inside.

## Licence

MIT, see [LICENSE](LICENSE).
