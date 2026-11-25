-- =================================================================================================
-- Family Tree: database seed
-- Generated from public/data/*.json by scripts/seed-sql.mts. Do not edit: run `npm run db:seed`.
-- Contents: 17 sagas, 1716 people, 908 families, 2666 family-member rows.
-- =================================================================================================
--
-- Load after db/schema.sql:
--   PostgreSQL: psql -d family_tree -f db/schema.sql -f db/seed.sql
--   SQLite:     sqlite3 family_tree.db "PRAGMA foreign_keys = ON;" ".read db/schema.sql" ".read db/seed.sql"
--
-- Each saga is one section: it is deleted first (cascading to all its rows), then re-inserted in dependency
-- order (saga, notes, houses, people, families with their members), so the file can be re-run safely.
--
-- Sagas, in drop-down order:
--    1. Game of Thrones          fiction   got
--    2. Fire & Blood             fiction   fireblood
--    3. The Lord of the Rings    fiction   lotr
--    4. The Silmarillion         fiction   silmarillion
--    5. Dune                     fiction   dune
--    6. Harry Potter             fiction   potter
--    7. Star Wars                fiction   starwars
--    8. The Wheel of Time        fiction   wot
--    9. The Stormlight Archive   fiction   stormlight
--   10. The Witcher              fiction   witcher
--   11. English Royal Family (Tudors) history   english-royal
--   12. Greek Gods               mythology greek-gods
--   13. Norse Gods               mythology norse-gods
--   14. Roman Gods               mythology roman-gods
--   15. The Bible                religion  bible
--   16. Babylonian Gods          mythology babylonian-gods
--   17. Nehru–Gandhi Family      history   nehru-gandhi

BEGIN;


-- =================================================================================================
-- SAGA 1 of 17: GAME OF THRONES   [id: got, category: fiction]
-- Author:  David Benioff & D. B. Weiss; novels by George R. R. Martin
-- Medium:  Television series (HBO, 2011–2019), based on A Song of Ice and Fire
-- Canon:   TV show (where it differs from the books, the show is followed)
-- Covers:  Stark, Tully, Arryn, Targaryen, Lannister and Baratheon, from Robert's Rebellion to
-- the show's present.
-- Rows:    9 houses, 42 people, 15 families, 57 members
-- =================================================================================================

-- ── Reset (removes this saga and, by cascade, all of its rows) ─────────────────────────────────
DELETE FROM saga WHERE id = 'got';

-- ── Saga ───────────────────────────────────────────────────────────────────────────────────────
INSERT INTO saga (id, category, position, title, work, medium, author, canon, genre, covers) VALUES
    ('got', 'fiction', 0, 'Game of Thrones', 'Game of Thrones', 'Television series (HBO, 2011–2019), based on A Song of Ice and Fire', 'David Benioff & D. B. Weiss; novels by George R. R. Martin', 'TV show (where it differs from the books, the show is followed)', 'Fantasy', 'Stark, Tully, Arryn, Targaryen, Lannister and Baratheon, from Robert''s Rebellion to the show''s present.');

-- ── Houses (9) ─────────────────────────────────────────────────────────────────────────────────
INSERT INTO house (saga_id, name, color) VALUES
    ('got', 'Stark', '#9aa9b8'),
    ('got', 'Tully', '#3f6fd1'),
    ('got', 'Arryn', '#7fc4ff'),
    ('got', 'Targaryen', '#c0262d'),
    ('got', 'Martell', '#e88a2b'),
    ('got', 'Dothraki', '#a5793f'),
    ('got', 'Lannister', '#e0b23a'),
    ('got', 'Baratheon', '#f2d64b'),
    ('got', 'Florent', '#9c6ad6');

-- ── People (42, grouped by house) ──────────────────────────────────────────────────────────────
-- Stark (11)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('got', 'rickard', 'Rickard Stark', 'Stark', 'm', NULL),
    ('got', 'lyarra', 'Lyarra Stark', 'Stark', 'f', NULL),
    ('got', 'eddard', 'Eddard Stark', 'Stark', 'm', NULL),
    ('got', 'lyanna', 'Lyanna Stark', 'Stark', 'f', NULL),
    ('got', 'benjen', 'Benjen Stark', 'Stark', 'm', NULL),
    ('got', 'robb', 'Robb Stark', 'Stark', 'm', NULL),
    ('got', 'sansa', 'Sansa Stark', 'Stark', 'f', NULL),
    ('got', 'arya', 'Arya Stark', 'Stark', 'f', NULL),
    ('got', 'bran', 'Bran Stark', 'Stark', 'm', NULL),
    ('got', 'rickon', 'Rickon Stark', 'Stark', 'm', NULL),
    ('got', 'jon', 'Jon Snow', 'Stark', 'm', NULL);
-- Tully (4)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('got', 'hoster', 'Hoster Tully', 'Tully', 'm', NULL),
    ('got', 'catelyn', 'Catelyn Tully', 'Tully', 'f', NULL),
    ('got', 'lysa', 'Lysa Tully', 'Tully', 'f', NULL),
    ('got', 'edmure', 'Edmure Tully', 'Tully', 'm', NULL);
-- Arryn (2)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('got', 'jonArryn', 'Jon Arryn', 'Arryn', 'm', NULL),
    ('got', 'robin', 'Robin Arryn', 'Arryn', 'm', NULL);
-- Targaryen (7)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('got', 'aerys', 'Aerys II Targaryen', 'Targaryen', 'm', NULL),
    ('got', 'rhaella', 'Rhaella Targaryen', 'Targaryen', 'f', NULL),
    ('got', 'rhaegar', 'Rhaegar Targaryen', 'Targaryen', 'm', NULL),
    ('got', 'viserys', 'Viserys Targaryen', 'Targaryen', 'm', NULL),
    ('got', 'daenerys', 'Daenerys Targaryen', 'Targaryen', 'f', NULL),
    ('got', 'rhaenys', 'Rhaenys Targaryen', 'Targaryen', 'f', NULL),
    ('got', 'aegon', 'Aegon Targaryen', 'Targaryen', 'm', NULL);
-- Martell (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('got', 'elia', 'Elia Martell', 'Martell', 'f', NULL);
-- Dothraki (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('got', 'drogo', 'Khal Drogo', 'Dothraki', 'm', NULL);
-- Lannister (8)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('got', 'tywin', 'Tywin Lannister', 'Lannister', 'm', NULL),
    ('got', 'joanna', 'Joanna Lannister', 'Lannister', 'f', NULL),
    ('got', 'cersei', 'Cersei Lannister', 'Lannister', 'f', NULL),
    ('got', 'jaime', 'Jaime Lannister', 'Lannister', 'm', NULL),
    ('got', 'tyrion', 'Tyrion Lannister', 'Lannister', 'm', NULL),
    ('got', 'joffrey', 'Joffrey Baratheon', 'Lannister', 'm', NULL),
    ('got', 'myrcella', 'Myrcella Baratheon', 'Lannister', 'f', NULL),
    ('got', 'tommen', 'Tommen Baratheon', 'Lannister', 'm', NULL);
-- Baratheon (7)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('got', 'steffon', 'Steffon Baratheon', 'Baratheon', 'm', NULL),
    ('got', 'cassana', 'Cassana Baratheon', 'Baratheon', 'f', NULL),
    ('got', 'robert', 'Robert Baratheon', 'Baratheon', 'm', NULL),
    ('got', 'stannis', 'Stannis Baratheon', 'Baratheon', 'm', NULL),
    ('got', 'renly', 'Renly Baratheon', 'Baratheon', 'm', NULL),
    ('got', 'shireen', 'Shireen Baratheon', 'Baratheon', 'f', NULL),
    ('got', 'gendry', 'Gendry', 'Baratheon', 'm', NULL);
-- Florent (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('got', 'selyse', 'Selyse Florent', 'Florent', 'f', NULL);

-- ── Families (15, each followed by its members) ────────────────────────────────────────────────
-- got-f1: Rickard Stark + Lyarra Stark → Eddard Stark, Lyanna Stark, Benjen Stark
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('got', 'got-f1', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('got', 'got-f1', 'rickard', 'parent'),
    ('got', 'got-f1', 'lyarra', 'parent'),
    ('got', 'got-f1', 'eddard', 'child'),
    ('got', 'got-f1', 'lyanna', 'child'),
    ('got', 'got-f1', 'benjen', 'child');
-- got-f2: Eddard Stark + Catelyn Tully → Robb Stark, Sansa Stark, Arya Stark, Bran Stark, Rickon Stark
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('got', 'got-f2', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('got', 'got-f2', 'eddard', 'parent'),
    ('got', 'got-f2', 'catelyn', 'parent'),
    ('got', 'got-f2', 'robb', 'child'),
    ('got', 'got-f2', 'sansa', 'child'),
    ('got', 'got-f2', 'arya', 'child'),
    ('got', 'got-f2', 'bran', 'child'),
    ('got', 'got-f2', 'rickon', 'child');
-- got-f3: Rhaegar Targaryen + Lyanna Stark → Jon Snow
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('got', 'got-f3', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('got', 'got-f3', 'rhaegar', 'parent'),
    ('got', 'got-f3', 'lyanna', 'parent'),
    ('got', 'got-f3', 'jon', 'child');
-- got-f4: Hoster Tully → Catelyn Tully, Lysa Tully, Edmure Tully
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('got', 'got-f4', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('got', 'got-f4', 'hoster', 'parent'),
    ('got', 'got-f4', 'catelyn', 'child'),
    ('got', 'got-f4', 'lysa', 'child'),
    ('got', 'got-f4', 'edmure', 'child');
-- got-f5: Jon Arryn + Lysa Tully → Robin Arryn
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('got', 'got-f5', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('got', 'got-f5', 'jonArryn', 'parent'),
    ('got', 'got-f5', 'lysa', 'parent'),
    ('got', 'got-f5', 'robin', 'child');
-- got-f6: Aerys II Targaryen + Rhaella Targaryen → Rhaegar Targaryen, Viserys Targaryen, Daenerys Targaryen
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('got', 'got-f6', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('got', 'got-f6', 'aerys', 'parent'),
    ('got', 'got-f6', 'rhaella', 'parent'),
    ('got', 'got-f6', 'rhaegar', 'child'),
    ('got', 'got-f6', 'viserys', 'child'),
    ('got', 'got-f6', 'daenerys', 'child');
-- got-f7: Rhaegar Targaryen + Elia Martell → Rhaenys Targaryen, Aegon Targaryen
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('got', 'got-f7', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('got', 'got-f7', 'rhaegar', 'parent'),
    ('got', 'got-f7', 'elia', 'parent'),
    ('got', 'got-f7', 'rhaenys', 'child'),
    ('got', 'got-f7', 'aegon', 'child');
-- got-f8: Khal Drogo + Daenerys Targaryen (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('got', 'got-f8', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('got', 'got-f8', 'drogo', 'parent'),
    ('got', 'got-f8', 'daenerys', 'parent');
-- got-f9: Tywin Lannister + Joanna Lannister → Cersei Lannister, Jaime Lannister, Tyrion Lannister
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('got', 'got-f9', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('got', 'got-f9', 'tywin', 'parent'),
    ('got', 'got-f9', 'joanna', 'parent'),
    ('got', 'got-f9', 'cersei', 'child'),
    ('got', 'got-f9', 'jaime', 'child'),
    ('got', 'got-f9', 'tyrion', 'child');
-- got-f10: Steffon Baratheon + Cassana Baratheon → Robert Baratheon, Stannis Baratheon, Renly Baratheon
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('got', 'got-f10', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('got', 'got-f10', 'steffon', 'parent'),
    ('got', 'got-f10', 'cassana', 'parent'),
    ('got', 'got-f10', 'robert', 'child'),
    ('got', 'got-f10', 'stannis', 'child'),
    ('got', 'got-f10', 'renly', 'child');
-- got-f11: Robert Baratheon + Cersei Lannister (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('got', 'got-f11', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('got', 'got-f11', 'robert', 'parent'),
    ('got', 'got-f11', 'cersei', 'parent');
-- got-f12: Jaime Lannister + Cersei Lannister → Joffrey Baratheon, Myrcella Baratheon, Tommen Baratheon
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('got', 'got-f12', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('got', 'got-f12', 'jaime', 'parent'),
    ('got', 'got-f12', 'cersei', 'parent'),
    ('got', 'got-f12', 'joffrey', 'child'),
    ('got', 'got-f12', 'myrcella', 'child'),
    ('got', 'got-f12', 'tommen', 'child');
-- got-f13: Robert Baratheon → Gendry
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('got', 'got-f13', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('got', 'got-f13', 'robert', 'parent'),
    ('got', 'got-f13', 'gendry', 'child');
-- got-f14: Stannis Baratheon + Selyse Florent → Shireen Baratheon
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('got', 'got-f14', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('got', 'got-f14', 'stannis', 'parent'),
    ('got', 'got-f14', 'selyse', 'parent'),
    ('got', 'got-f14', 'shireen', 'child');
-- got-f15: Tyrion Lannister + Sansa Stark (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('got', 'got-f15', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('got', 'got-f15', 'tyrion', 'parent'),
    ('got', 'got-f15', 'sansa', 'parent');


-- =================================================================================================
-- SAGA 2 of 17: FIRE & BLOOD   [id: fireblood, category: fiction]
-- Author:  George R. R. Martin
-- Medium:  Novel (2018), a fictional history; adapted as HBO's House of the Dragon (2022–)
-- Canon:   Book (where it differs from the show, the book is followed)
-- Covers:  House Targaryen from Aegon the Conqueror to the Dance of the Dragons and its
-- aftermath: seven generations, with heavy intermarriage.
-- Rows:    5 houses, 40 people, 18 families, 66 members
-- =================================================================================================

-- ── Reset (removes this saga and, by cascade, all of its rows) ─────────────────────────────────
DELETE FROM saga WHERE id = 'fireblood';

-- ── Saga ───────────────────────────────────────────────────────────────────────────────────────
INSERT INTO saga (id, category, position, title, work, medium, author, canon, genre, covers) VALUES
    ('fireblood', 'fiction', 1, 'Fire & Blood', 'Fire & Blood', 'Novel (2018), a fictional history; adapted as HBO''s House of the Dragon (2022–)', 'George R. R. Martin', 'Book (where it differs from the show, the book is followed)', 'Fantasy', 'House Targaryen from Aegon the Conqueror to the Dance of the Dragons and its aftermath: seven generations, with heavy intermarriage.');

-- ── Notes (modelling choices and where sources disagree) ───────────────────────────────────────
INSERT INTO saga_note (saga_id, position, note) VALUES
    ('fireblood', 0, 'Rhaenyra''s three eldest are officially Laenor''s; the books strongly imply Harwin Strong. Shown as Laenor''s.'),
    ('fireblood', 1, 'only the main royal line; Jaehaerys I had 13 children, add the rest if wanted.');

-- ── Houses (5) ─────────────────────────────────────────────────────────────────────────────────
INSERT INTO house (saga_id, name, color) VALUES
    ('fireblood', 'Targaryen', '#c0262d'),
    ('fireblood', 'Velaryon', '#3c8fa8'),
    ('fireblood', 'Baratheon', '#f2d64b'),
    ('fireblood', 'Arryn', '#7fc4ff'),
    ('fireblood', 'Hightower', '#3f9a4b');

-- ── People (40, grouped by house) ──────────────────────────────────────────────────────────────
-- Targaryen (28)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('fireblood', 'aegonI', 'Aegon I the Conqueror', 'Targaryen', 'm', NULL),
    ('fireblood', 'visenya', 'Visenya', 'Targaryen', 'f', NULL),
    ('fireblood', 'rhaenysQ', 'Rhaenys (queen)', 'Targaryen', 'f', NULL),
    ('fireblood', 'aenys', 'Aenys I', 'Targaryen', 'm', NULL),
    ('fireblood', 'maegor', 'Maegor the Cruel', 'Targaryen', 'm', NULL),
    ('fireblood', 'aegonU', 'Aegon the Uncrowned', 'Targaryen', 'm', NULL),
    ('fireblood', 'rhaenaA', 'Rhaena', 'Targaryen', 'f', NULL),
    ('fireblood', 'viserysA', 'Viserys (son of Aenys)', 'Targaryen', 'm', NULL),
    ('fireblood', 'jaehaerys', 'Jaehaerys I', 'Targaryen', 'm', NULL),
    ('fireblood', 'alysanne', 'Alysanne', 'Targaryen', 'f', NULL),
    ('fireblood', 'aemon', 'Aemon (Prince of Dragonstone)', 'Targaryen', 'm', NULL),
    ('fireblood', 'baelon', 'Baelon the Brave', 'Targaryen', 'm', NULL),
    ('fireblood', 'alyssaT', 'Alyssa Targaryen', 'Targaryen', 'f', NULL),
    ('fireblood', 'rhaenys', 'Rhaenys (Queen Who Never Was)', 'Targaryen', 'f', NULL),
    ('fireblood', 'viserysI', 'Viserys I', 'Targaryen', 'm', NULL),
    ('fireblood', 'daemon', 'Daemon Targaryen', 'Targaryen', 'm', NULL),
    ('fireblood', 'rhaenyra', 'Rhaenyra Targaryen', 'Targaryen', 'f', NULL),
    ('fireblood', 'aegonII', 'Aegon II', 'Targaryen', 'm', NULL),
    ('fireblood', 'helaena', 'Helaena', 'Targaryen', 'f', NULL),
    ('fireblood', 'aemond', 'Aemond One-Eye', 'Targaryen', 'm', NULL),
    ('fireblood', 'daeron', 'Daeron the Daring', 'Targaryen', 'm', NULL),
    ('fireblood', 'baela', 'Baela Targaryen', 'Targaryen', 'f', NULL),
    ('fireblood', 'rhaenaD', 'Rhaena Targaryen', 'Targaryen', 'f', NULL),
    ('fireblood', 'aegonIII', 'Aegon III', 'Targaryen', 'm', NULL),
    ('fireblood', 'viserysII', 'Viserys II', 'Targaryen', 'm', NULL),
    ('fireblood', 'jaehaerysH', 'Jaehaerys (son of Aegon II)', 'Targaryen', 'm', NULL),
    ('fireblood', 'jaehaera', 'Jaehaera', 'Targaryen', 'f', NULL),
    ('fireblood', 'maelor', 'Maelor', 'Targaryen', 'm', NULL);
-- Velaryon (8)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('fireblood', 'alyssa', 'Alyssa Velaryon', 'Velaryon', 'f', NULL),
    ('fireblood', 'corlys', 'Corlys Velaryon', 'Velaryon', 'm', NULL),
    ('fireblood', 'laena', 'Laena Velaryon', 'Velaryon', 'f', NULL),
    ('fireblood', 'laenor', 'Laenor Velaryon', 'Velaryon', 'm', NULL),
    ('fireblood', 'jacaerys', 'Jacaerys Velaryon', 'Velaryon', 'm', NULL),
    ('fireblood', 'lucerys', 'Lucerys Velaryon', 'Velaryon', 'm', NULL),
    ('fireblood', 'joffreyV', 'Joffrey Velaryon', 'Velaryon', 'm', NULL),
    ('fireblood', 'daenaera', 'Daenaera Velaryon', 'Velaryon', 'f', NULL);
-- Baratheon (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('fireblood', 'jocelyn', 'Jocelyn Baratheon', 'Baratheon', 'f', NULL);
-- Arryn (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('fireblood', 'aemma', 'Aemma Arryn', 'Arryn', 'f', NULL);
-- Hightower (2)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('fireblood', 'alicent', 'Alicent Hightower', 'Hightower', 'f', NULL),
    ('fireblood', 'otto', 'Otto Hightower', 'Hightower', 'm', NULL);

-- ── Families (18, each followed by its members) ────────────────────────────────────────────────
-- fireblood-f1: Aegon I the Conqueror + Rhaenys (queen) → Aenys I
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('fireblood', 'fireblood-f1', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('fireblood', 'fireblood-f1', 'aegonI', 'parent'),
    ('fireblood', 'fireblood-f1', 'rhaenysQ', 'parent'),
    ('fireblood', 'fireblood-f1', 'aenys', 'child');
-- fireblood-f2: Aegon I the Conqueror + Visenya → Maegor the Cruel
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('fireblood', 'fireblood-f2', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('fireblood', 'fireblood-f2', 'aegonI', 'parent'),
    ('fireblood', 'fireblood-f2', 'visenya', 'parent'),
    ('fireblood', 'fireblood-f2', 'maegor', 'child');
-- fireblood-f3: Aenys I + Alyssa Velaryon → Aegon the Uncrowned, Rhaena, Viserys (son of Aenys), Jaehaerys I, Alysanne
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('fireblood', 'fireblood-f3', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('fireblood', 'fireblood-f3', 'aenys', 'parent'),
    ('fireblood', 'fireblood-f3', 'alyssa', 'parent'),
    ('fireblood', 'fireblood-f3', 'aegonU', 'child'),
    ('fireblood', 'fireblood-f3', 'rhaenaA', 'child'),
    ('fireblood', 'fireblood-f3', 'viserysA', 'child'),
    ('fireblood', 'fireblood-f3', 'jaehaerys', 'child'),
    ('fireblood', 'fireblood-f3', 'alysanne', 'child');
-- fireblood-f4: Aegon the Uncrowned + Rhaena (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('fireblood', 'fireblood-f4', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('fireblood', 'fireblood-f4', 'aegonU', 'parent'),
    ('fireblood', 'fireblood-f4', 'rhaenaA', 'parent');
-- fireblood-f5: Maegor the Cruel + Rhaena (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('fireblood', 'fireblood-f5', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('fireblood', 'fireblood-f5', 'maegor', 'parent'),
    ('fireblood', 'fireblood-f5', 'rhaenaA', 'parent');
-- fireblood-f6: Jaehaerys I + Alysanne → Aemon (Prince of Dragonstone), Baelon the Brave, Alyssa Targaryen
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('fireblood', 'fireblood-f6', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('fireblood', 'fireblood-f6', 'jaehaerys', 'parent'),
    ('fireblood', 'fireblood-f6', 'alysanne', 'parent'),
    ('fireblood', 'fireblood-f6', 'aemon', 'child'),
    ('fireblood', 'fireblood-f6', 'baelon', 'child'),
    ('fireblood', 'fireblood-f6', 'alyssaT', 'child');
-- fireblood-f7: Aemon (Prince of Dragonstone) + Jocelyn Baratheon → Rhaenys (Queen Who Never Was)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('fireblood', 'fireblood-f7', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('fireblood', 'fireblood-f7', 'aemon', 'parent'),
    ('fireblood', 'fireblood-f7', 'jocelyn', 'parent'),
    ('fireblood', 'fireblood-f7', 'rhaenys', 'child');
-- fireblood-f8: Baelon the Brave + Alyssa Targaryen → Viserys I, Daemon Targaryen
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('fireblood', 'fireblood-f8', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('fireblood', 'fireblood-f8', 'baelon', 'parent'),
    ('fireblood', 'fireblood-f8', 'alyssaT', 'parent'),
    ('fireblood', 'fireblood-f8', 'viserysI', 'child'),
    ('fireblood', 'fireblood-f8', 'daemon', 'child');
-- fireblood-f9: Corlys Velaryon + Rhaenys (Queen Who Never Was) → Laena Velaryon, Laenor Velaryon
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('fireblood', 'fireblood-f9', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('fireblood', 'fireblood-f9', 'corlys', 'parent'),
    ('fireblood', 'fireblood-f9', 'rhaenys', 'parent'),
    ('fireblood', 'fireblood-f9', 'laena', 'child'),
    ('fireblood', 'fireblood-f9', 'laenor', 'child');
-- fireblood-f10: Viserys I + Aemma Arryn → Rhaenyra Targaryen
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('fireblood', 'fireblood-f10', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('fireblood', 'fireblood-f10', 'viserysI', 'parent'),
    ('fireblood', 'fireblood-f10', 'aemma', 'parent'),
    ('fireblood', 'fireblood-f10', 'rhaenyra', 'child');
-- fireblood-f11: Otto Hightower → Alicent Hightower
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('fireblood', 'fireblood-f11', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('fireblood', 'fireblood-f11', 'otto', 'parent'),
    ('fireblood', 'fireblood-f11', 'alicent', 'child');
-- fireblood-f12: Viserys I + Alicent Hightower → Aegon II, Helaena, Aemond One-Eye, Daeron the Daring
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('fireblood', 'fireblood-f12', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('fireblood', 'fireblood-f12', 'viserysI', 'parent'),
    ('fireblood', 'fireblood-f12', 'alicent', 'parent'),
    ('fireblood', 'fireblood-f12', 'aegonII', 'child'),
    ('fireblood', 'fireblood-f12', 'helaena', 'child'),
    ('fireblood', 'fireblood-f12', 'aemond', 'child'),
    ('fireblood', 'fireblood-f12', 'daeron', 'child');
-- fireblood-f13: Laenor Velaryon + Rhaenyra Targaryen → Jacaerys Velaryon, Lucerys Velaryon, Joffrey Velaryon
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('fireblood', 'fireblood-f13', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('fireblood', 'fireblood-f13', 'laenor', 'parent'),
    ('fireblood', 'fireblood-f13', 'rhaenyra', 'parent'),
    ('fireblood', 'fireblood-f13', 'jacaerys', 'child'),
    ('fireblood', 'fireblood-f13', 'lucerys', 'child'),
    ('fireblood', 'fireblood-f13', 'joffreyV', 'child');
-- fireblood-f14: Daemon Targaryen + Laena Velaryon → Baela Targaryen, Rhaena Targaryen
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('fireblood', 'fireblood-f14', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('fireblood', 'fireblood-f14', 'daemon', 'parent'),
    ('fireblood', 'fireblood-f14', 'laena', 'parent'),
    ('fireblood', 'fireblood-f14', 'baela', 'child'),
    ('fireblood', 'fireblood-f14', 'rhaenaD', 'child');
-- fireblood-f15: Daemon Targaryen + Rhaenyra Targaryen → Aegon III, Viserys II
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('fireblood', 'fireblood-f15', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('fireblood', 'fireblood-f15', 'daemon', 'parent'),
    ('fireblood', 'fireblood-f15', 'rhaenyra', 'parent'),
    ('fireblood', 'fireblood-f15', 'aegonIII', 'child'),
    ('fireblood', 'fireblood-f15', 'viserysII', 'child');
-- fireblood-f16: Aegon II + Helaena → Jaehaerys (son of Aegon II), Jaehaera, Maelor
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('fireblood', 'fireblood-f16', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('fireblood', 'fireblood-f16', 'aegonII', 'parent'),
    ('fireblood', 'fireblood-f16', 'helaena', 'parent'),
    ('fireblood', 'fireblood-f16', 'jaehaerysH', 'child'),
    ('fireblood', 'fireblood-f16', 'jaehaera', 'child'),
    ('fireblood', 'fireblood-f16', 'maelor', 'child');
-- fireblood-f17: Aegon III + Jaehaera (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('fireblood', 'fireblood-f17', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('fireblood', 'fireblood-f17', 'aegonIII', 'parent'),
    ('fireblood', 'fireblood-f17', 'jaehaera', 'parent');
-- fireblood-f18: Aegon III + Daenaera Velaryon (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('fireblood', 'fireblood-f18', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('fireblood', 'fireblood-f18', 'aegonIII', 'parent'),
    ('fireblood', 'fireblood-f18', 'daenaera', 'parent');


-- =================================================================================================
-- SAGA 3 of 17: THE LORD OF THE RINGS   [id: lotr, category: fiction]
-- Author:  J. R. R. Tolkien
-- Medium:  Novel (1954–1955), with its appendices; The Silmarillion for the earliest generations
-- Canon:   Books, chiefly Appendix A ("Annals of the Kings and Rulers")
-- Covers:  The half-elven line and House of Elrond, the heirs of Isildur down to Aragorn, and
-- the royal houses of Rohan and Gondor.
-- Rows:    8 houses, 32 people, 13 families, 43 members
-- =================================================================================================

-- ── Reset (removes this saga and, by cascade, all of its rows) ─────────────────────────────────
DELETE FROM saga WHERE id = 'lotr';

-- ── Saga ───────────────────────────────────────────────────────────────────────────────────────
INSERT INTO saga (id, category, position, title, work, medium, author, canon, genre, covers) VALUES
    ('lotr', 'fiction', 2, 'The Lord of the Rings', 'The Lord of the Rings', 'Novel (1954–1955), with its appendices; The Silmarillion for the earliest generations', 'J. R. R. Tolkien', 'Books, chiefly Appendix A ("Annals of the Kings and Rulers")', 'High fantasy', 'The half-elven line and House of Elrond, the heirs of Isildur down to Aragorn, and the royal houses of Rohan and Gondor.');

-- ── Notes (modelling choices and where sources disagree) ───────────────────────────────────────
INSERT INTO saga_note (saga_id, position, note) VALUES
    ('lotr', 0, 'Valandil→Arathorn skips ~37 generations of Chieftains; add them if the full line matters.');

-- ── Houses (8) ─────────────────────────────────────────────────────────────────────────────────
INSERT INTO house (saga_id, name, color) VALUES
    ('lotr', 'Half-elven', '#b9d7f0'),
    ('lotr', 'Lothlórien', '#e6cf6a'),
    ('lotr', 'Númenor', '#3b6fb6'),
    ('lotr', 'Elendil', '#e8e8ee'),
    ('lotr', 'Dúnedain', '#5b7a5a'),
    ('lotr', 'Rohan', '#3f9a4b'),
    ('lotr', 'Gondor', '#c8ccd8'),
    ('lotr', 'Dol Amroth', '#4aa8c8');

-- ── People (32, grouped by house) ──────────────────────────────────────────────────────────────
-- Half-elven (6)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('lotr', 'earendil', 'Eärendil', 'Half-elven', 'm', NULL),
    ('lotr', 'elwing', 'Elwing', 'Half-elven', 'f', NULL),
    ('lotr', 'elrond', 'Elrond', 'Half-elven', 'm', NULL),
    ('lotr', 'elladan', 'Elladan', 'Half-elven', 'm', NULL),
    ('lotr', 'elrohir', 'Elrohir', 'Half-elven', 'm', NULL),
    ('lotr', 'arwen', 'Arwen Undómiel', 'Half-elven', 'f', NULL);
-- Lothlórien (3)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('lotr', 'celeborn', 'Celeborn', 'Lothlórien', 'm', NULL),
    ('lotr', 'galadriel', 'Galadriel', 'Lothlórien', 'f', NULL),
    ('lotr', 'celebrian', 'Celebrían', 'Lothlórien', 'f', NULL);
-- Númenor (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('lotr', 'elros', 'Elros Tar-Minyatur', 'Númenor', 'm', NULL);
-- Elendil (5)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('lotr', 'elendil', 'Elendil', 'Elendil', 'm', NULL),
    ('lotr', 'isildur', 'Isildur', 'Elendil', 'm', NULL),
    ('lotr', 'anarion', 'Anárion', 'Elendil', 'm', NULL),
    ('lotr', 'elendur', 'Elendur', 'Elendil', 'm', NULL),
    ('lotr', 'valandil', 'Valandil', 'Elendil', 'm', NULL);
-- Dúnedain (4)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('lotr', 'arathorn', 'Arathorn II', 'Dúnedain', 'm', NULL),
    ('lotr', 'gilraen', 'Gilraen', 'Dúnedain', 'f', NULL),
    ('lotr', 'aragorn', 'Aragorn II Elessar', 'Dúnedain', 'm', NULL),
    ('lotr', 'eldarion', 'Eldarion', 'Dúnedain', 'm', NULL);
-- Rohan (7)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('lotr', 'thengel', 'Thengel', 'Rohan', 'm', NULL),
    ('lotr', 'theoden', 'Théoden', 'Rohan', 'm', NULL),
    ('lotr', 'theodwyn', 'Théodwyn', 'Rohan', 'f', NULL),
    ('lotr', 'eomund', 'Éomund', 'Rohan', 'm', NULL),
    ('lotr', 'theodred', 'Théodred', 'Rohan', 'm', NULL),
    ('lotr', 'eomer', 'Éomer', 'Rohan', 'm', NULL),
    ('lotr', 'eowyn', 'Éowyn', 'Rohan', 'f', NULL);
-- Gondor (5)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('lotr', 'morwen', 'Morwen of Lossarnach', 'Gondor', 'f', NULL),
    ('lotr', 'denethor', 'Denethor II', 'Gondor', 'm', NULL),
    ('lotr', 'boromir', 'Boromir', 'Gondor', 'm', NULL),
    ('lotr', 'faramir', 'Faramir', 'Gondor', 'm', NULL),
    ('lotr', 'elboron', 'Elboron', 'Gondor', 'm', NULL);
-- Dol Amroth (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('lotr', 'finduilas', 'Finduilas', 'Dol Amroth', 'f', NULL);

-- ── Families (13, each followed by its members) ────────────────────────────────────────────────
-- lotr-f1: Eärendil + Elwing → Elrond, Elros Tar-Minyatur
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('lotr', 'lotr-f1', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('lotr', 'lotr-f1', 'earendil', 'parent'),
    ('lotr', 'lotr-f1', 'elwing', 'parent'),
    ('lotr', 'lotr-f1', 'elrond', 'child'),
    ('lotr', 'lotr-f1', 'elros', 'child');
-- lotr-f2: Celeborn + Galadriel → Celebrían
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('lotr', 'lotr-f2', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('lotr', 'lotr-f2', 'celeborn', 'parent'),
    ('lotr', 'lotr-f2', 'galadriel', 'parent'),
    ('lotr', 'lotr-f2', 'celebrian', 'child');
-- lotr-f3: Elrond + Celebrían → Elladan, Elrohir, Arwen Undómiel
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('lotr', 'lotr-f3', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('lotr', 'lotr-f3', 'elrond', 'parent'),
    ('lotr', 'lotr-f3', 'celebrian', 'parent'),
    ('lotr', 'lotr-f3', 'elladan', 'child'),
    ('lotr', 'lotr-f3', 'elrohir', 'child'),
    ('lotr', 'lotr-f3', 'arwen', 'child');
-- lotr-f4: Elendil → Isildur, Anárion
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('lotr', 'lotr-f4', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('lotr', 'lotr-f4', 'elendil', 'parent'),
    ('lotr', 'lotr-f4', 'isildur', 'child'),
    ('lotr', 'lotr-f4', 'anarion', 'child');
-- lotr-f5: Isildur → Elendur, Valandil
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('lotr', 'lotr-f5', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('lotr', 'lotr-f5', 'isildur', 'parent'),
    ('lotr', 'lotr-f5', 'elendur', 'child'),
    ('lotr', 'lotr-f5', 'valandil', 'child');
-- lotr-f6: Valandil → Arathorn II
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('lotr', 'lotr-f6', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('lotr', 'lotr-f6', 'valandil', 'parent'),
    ('lotr', 'lotr-f6', 'arathorn', 'child');
-- lotr-f7: Arathorn II + Gilraen → Aragorn II Elessar
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('lotr', 'lotr-f7', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('lotr', 'lotr-f7', 'arathorn', 'parent'),
    ('lotr', 'lotr-f7', 'gilraen', 'parent'),
    ('lotr', 'lotr-f7', 'aragorn', 'child');
-- lotr-f8: Aragorn II Elessar + Arwen Undómiel → Eldarion
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('lotr', 'lotr-f8', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('lotr', 'lotr-f8', 'aragorn', 'parent'),
    ('lotr', 'lotr-f8', 'arwen', 'parent'),
    ('lotr', 'lotr-f8', 'eldarion', 'child');
-- lotr-f9: Thengel + Morwen of Lossarnach → Théoden, Théodwyn
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('lotr', 'lotr-f9', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('lotr', 'lotr-f9', 'thengel', 'parent'),
    ('lotr', 'lotr-f9', 'morwen', 'parent'),
    ('lotr', 'lotr-f9', 'theoden', 'child'),
    ('lotr', 'lotr-f9', 'theodwyn', 'child');
-- lotr-f10: Théoden → Théodred
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('lotr', 'lotr-f10', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('lotr', 'lotr-f10', 'theoden', 'parent'),
    ('lotr', 'lotr-f10', 'theodred', 'child');
-- lotr-f11: Éomund + Théodwyn → Éomer, Éowyn
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('lotr', 'lotr-f11', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('lotr', 'lotr-f11', 'eomund', 'parent'),
    ('lotr', 'lotr-f11', 'theodwyn', 'parent'),
    ('lotr', 'lotr-f11', 'eomer', 'child'),
    ('lotr', 'lotr-f11', 'eowyn', 'child');
-- lotr-f12: Denethor II + Finduilas → Boromir, Faramir
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('lotr', 'lotr-f12', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('lotr', 'lotr-f12', 'denethor', 'parent'),
    ('lotr', 'lotr-f12', 'finduilas', 'parent'),
    ('lotr', 'lotr-f12', 'boromir', 'child'),
    ('lotr', 'lotr-f12', 'faramir', 'child');
-- lotr-f13: Faramir + Éowyn → Elboron
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('lotr', 'lotr-f13', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('lotr', 'lotr-f13', 'faramir', 'parent'),
    ('lotr', 'lotr-f13', 'eowyn', 'parent'),
    ('lotr', 'lotr-f13', 'elboron', 'child');


-- =================================================================================================
-- SAGA 4 of 17: THE SILMARILLION   [id: silmarillion, category: fiction]
-- Author:  J. R. R. Tolkien, edited by Christopher Tolkien
-- Medium:  Mythopoeic history of Middle-earth (1977, published posthumously)
-- Canon:   The published Silmarillion (not Tolkien's later, conflicting notes)
-- Covers:  House of Finwë (Fëanor, Fingolfin, Finarfin), and the lines of Lúthien and Tuor down
-- to Elrond and Elros: eight generations.
-- Rows:    10 houses, 41 people, 15 families, 56 members
-- =================================================================================================

-- ── Reset (removes this saga and, by cascade, all of its rows) ─────────────────────────────────
DELETE FROM saga WHERE id = 'silmarillion';

-- ── Saga ───────────────────────────────────────────────────────────────────────────────────────
INSERT INTO saga (id, category, position, title, work, medium, author, canon, genre, covers) VALUES
    ('silmarillion', 'fiction', 3, 'The Silmarillion', 'The Silmarillion', 'Mythopoeic history of Middle-earth (1977, published posthumously)', 'J. R. R. Tolkien, edited by Christopher Tolkien', 'The published Silmarillion (not Tolkien''s later, conflicting notes)', 'High fantasy', 'House of Finwë (Fëanor, Fingolfin, Finarfin), and the lines of Lúthien and Tuor down to Elrond and Elros: eight generations.');

-- ── Notes (modelling choices and where sources disagree) ───────────────────────────────────────
INSERT INTO saga_note (saga_id, position, note) VALUES
    ('silmarillion', 0, 'Orodreth follows the published Silmarillion (son of Finarfin), not Tolkien''s later notes.');

-- ── Houses (10) ────────────────────────────────────────────────────────────────────────────────
INSERT INTO house (saga_id, name, color) VALUES
    ('silmarillion', 'Finwë', '#e8e0c8'),
    ('silmarillion', 'Fëanor', '#d9531e'),
    ('silmarillion', 'Fingolfin', '#3b6fb6'),
    ('silmarillion', 'Finarfin', '#e6cf6a'),
    ('silmarillion', 'Vanyar', '#f5f0d0'),
    ('silmarillion', 'Teleri', '#7fc4d8'),
    ('silmarillion', 'Sindar', '#8fb0c8'),
    ('silmarillion', 'Maiar', '#c8a8e8'),
    ('silmarillion', 'Edain', '#7a8a5a'),
    ('silmarillion', 'Half-elven', '#b9d7f0');

-- ── People (41, grouped by house) ──────────────────────────────────────────────────────────────
-- Finwë (2)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('silmarillion', 'finwe', 'Finwë', 'Finwë', 'm', NULL),
    ('silmarillion', 'miriel', 'Míriel', 'Finwë', 'f', NULL);
-- Fëanor (10)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('silmarillion', 'feanor', 'Fëanor', 'Fëanor', 'm', NULL),
    ('silmarillion', 'nerdanel', 'Nerdanel', 'Fëanor', 'f', NULL),
    ('silmarillion', 'maedhros', 'Maedhros', 'Fëanor', 'm', NULL),
    ('silmarillion', 'maglor', 'Maglor', 'Fëanor', 'm', NULL),
    ('silmarillion', 'celegorm', 'Celegorm', 'Fëanor', 'm', NULL),
    ('silmarillion', 'caranthir', 'Caranthir', 'Fëanor', 'm', NULL),
    ('silmarillion', 'curufin', 'Curufin', 'Fëanor', 'm', NULL),
    ('silmarillion', 'amrod', 'Amrod', 'Fëanor', 'm', NULL),
    ('silmarillion', 'amras', 'Amras', 'Fëanor', 'm', NULL),
    ('silmarillion', 'celebrimbor', 'Celebrimbor', 'Fëanor', 'm', NULL);
-- Fingolfin (6)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('silmarillion', 'fingolfin', 'Fingolfin', 'Fingolfin', 'm', NULL),
    ('silmarillion', 'fingon', 'Fingon', 'Fingolfin', 'm', NULL),
    ('silmarillion', 'turgon', 'Turgon', 'Fingolfin', 'm', NULL),
    ('silmarillion', 'aredhel', 'Aredhel', 'Fingolfin', 'f', NULL),
    ('silmarillion', 'maeglin', 'Maeglin', 'Fingolfin', 'm', NULL),
    ('silmarillion', 'idril', 'Idril', 'Fingolfin', 'f', NULL);
-- Finarfin (6)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('silmarillion', 'finarfin', 'Finarfin', 'Finarfin', 'm', NULL),
    ('silmarillion', 'finrod', 'Finrod Felagund', 'Finarfin', 'm', NULL),
    ('silmarillion', 'orodreth', 'Orodreth', 'Finarfin', 'm', NULL),
    ('silmarillion', 'angrod', 'Angrod', 'Finarfin', 'm', NULL),
    ('silmarillion', 'aegnor', 'Aegnor', 'Finarfin', 'm', NULL),
    ('silmarillion', 'galadriel', 'Galadriel', 'Finarfin', 'f', NULL);
-- Vanyar (2)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('silmarillion', 'indis', 'Indis', 'Vanyar', 'f', NULL),
    ('silmarillion', 'elenwe', 'Elenwë', 'Vanyar', 'f', NULL);
-- Teleri (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('silmarillion', 'earwen', 'Eärwen', 'Teleri', 'f', NULL);
-- Sindar (6)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('silmarillion', 'eol', 'Eöl', 'Sindar', 'm', NULL),
    ('silmarillion', 'celeborn', 'Celeborn', 'Sindar', 'm', NULL),
    ('silmarillion', 'celebrian', 'Celebrían', 'Sindar', 'f', NULL),
    ('silmarillion', 'thingol', 'Elu Thingol', 'Sindar', 'm', NULL),
    ('silmarillion', 'luthien', 'Lúthien', 'Sindar', 'f', NULL),
    ('silmarillion', 'nimloth', 'Nimloth', 'Sindar', 'f', NULL);
-- Maiar (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('silmarillion', 'melian', 'Melian', 'Maiar', 'f', NULL);
-- Edain (3)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('silmarillion', 'tuor', 'Tuor', 'Edain', 'm', NULL),
    ('silmarillion', 'beren', 'Beren', 'Edain', 'm', NULL),
    ('silmarillion', 'elros', 'Elros', 'Edain', 'm', NULL);
-- Half-elven (4)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('silmarillion', 'dior', 'Dior', 'Half-elven', 'm', NULL),
    ('silmarillion', 'elwing', 'Elwing', 'Half-elven', 'f', NULL),
    ('silmarillion', 'earendil', 'Eärendil', 'Half-elven', 'm', NULL),
    ('silmarillion', 'elrond', 'Elrond', 'Half-elven', 'm', NULL);

-- ── Families (15, each followed by its members) ────────────────────────────────────────────────
-- silmarillion-f1: Finwë + Míriel → Fëanor
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('silmarillion', 'silmarillion-f1', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('silmarillion', 'silmarillion-f1', 'finwe', 'parent'),
    ('silmarillion', 'silmarillion-f1', 'miriel', 'parent'),
    ('silmarillion', 'silmarillion-f1', 'feanor', 'child');
-- silmarillion-f2: Finwë + Indis → Fingolfin, Finarfin
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('silmarillion', 'silmarillion-f2', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('silmarillion', 'silmarillion-f2', 'finwe', 'parent'),
    ('silmarillion', 'silmarillion-f2', 'indis', 'parent'),
    ('silmarillion', 'silmarillion-f2', 'fingolfin', 'child'),
    ('silmarillion', 'silmarillion-f2', 'finarfin', 'child');
-- silmarillion-f3: Fëanor + Nerdanel → Maedhros, Maglor, Celegorm, Caranthir, Curufin, Amrod, Amras
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('silmarillion', 'silmarillion-f3', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('silmarillion', 'silmarillion-f3', 'feanor', 'parent'),
    ('silmarillion', 'silmarillion-f3', 'nerdanel', 'parent'),
    ('silmarillion', 'silmarillion-f3', 'maedhros', 'child'),
    ('silmarillion', 'silmarillion-f3', 'maglor', 'child'),
    ('silmarillion', 'silmarillion-f3', 'celegorm', 'child'),
    ('silmarillion', 'silmarillion-f3', 'caranthir', 'child'),
    ('silmarillion', 'silmarillion-f3', 'curufin', 'child'),
    ('silmarillion', 'silmarillion-f3', 'amrod', 'child'),
    ('silmarillion', 'silmarillion-f3', 'amras', 'child');
-- silmarillion-f4: Curufin → Celebrimbor
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('silmarillion', 'silmarillion-f4', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('silmarillion', 'silmarillion-f4', 'curufin', 'parent'),
    ('silmarillion', 'silmarillion-f4', 'celebrimbor', 'child');
-- silmarillion-f5: Fingolfin → Fingon, Turgon, Aredhel
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('silmarillion', 'silmarillion-f5', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('silmarillion', 'silmarillion-f5', 'fingolfin', 'parent'),
    ('silmarillion', 'silmarillion-f5', 'fingon', 'child'),
    ('silmarillion', 'silmarillion-f5', 'turgon', 'child'),
    ('silmarillion', 'silmarillion-f5', 'aredhel', 'child');
-- silmarillion-f6: Turgon + Elenwë → Idril
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('silmarillion', 'silmarillion-f6', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('silmarillion', 'silmarillion-f6', 'turgon', 'parent'),
    ('silmarillion', 'silmarillion-f6', 'elenwe', 'parent'),
    ('silmarillion', 'silmarillion-f6', 'idril', 'child');
-- silmarillion-f7: Eöl + Aredhel → Maeglin
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('silmarillion', 'silmarillion-f7', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('silmarillion', 'silmarillion-f7', 'eol', 'parent'),
    ('silmarillion', 'silmarillion-f7', 'aredhel', 'parent'),
    ('silmarillion', 'silmarillion-f7', 'maeglin', 'child');
-- silmarillion-f8: Finarfin + Eärwen → Finrod Felagund, Orodreth, Angrod, Aegnor, Galadriel
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('silmarillion', 'silmarillion-f8', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('silmarillion', 'silmarillion-f8', 'finarfin', 'parent'),
    ('silmarillion', 'silmarillion-f8', 'earwen', 'parent'),
    ('silmarillion', 'silmarillion-f8', 'finrod', 'child'),
    ('silmarillion', 'silmarillion-f8', 'orodreth', 'child'),
    ('silmarillion', 'silmarillion-f8', 'angrod', 'child'),
    ('silmarillion', 'silmarillion-f8', 'aegnor', 'child'),
    ('silmarillion', 'silmarillion-f8', 'galadriel', 'child');
-- silmarillion-f9: Celeborn + Galadriel → Celebrían
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('silmarillion', 'silmarillion-f9', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('silmarillion', 'silmarillion-f9', 'celeborn', 'parent'),
    ('silmarillion', 'silmarillion-f9', 'galadriel', 'parent'),
    ('silmarillion', 'silmarillion-f9', 'celebrian', 'child');
-- silmarillion-f10: Elu Thingol + Melian → Lúthien
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('silmarillion', 'silmarillion-f10', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('silmarillion', 'silmarillion-f10', 'thingol', 'parent'),
    ('silmarillion', 'silmarillion-f10', 'melian', 'parent'),
    ('silmarillion', 'silmarillion-f10', 'luthien', 'child');
-- silmarillion-f11: Beren + Lúthien → Dior
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('silmarillion', 'silmarillion-f11', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('silmarillion', 'silmarillion-f11', 'beren', 'parent'),
    ('silmarillion', 'silmarillion-f11', 'luthien', 'parent'),
    ('silmarillion', 'silmarillion-f11', 'dior', 'child');
-- silmarillion-f12: Dior + Nimloth → Elwing
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('silmarillion', 'silmarillion-f12', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('silmarillion', 'silmarillion-f12', 'dior', 'parent'),
    ('silmarillion', 'silmarillion-f12', 'nimloth', 'parent'),
    ('silmarillion', 'silmarillion-f12', 'elwing', 'child');
-- silmarillion-f13: Tuor + Idril → Eärendil
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('silmarillion', 'silmarillion-f13', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('silmarillion', 'silmarillion-f13', 'tuor', 'parent'),
    ('silmarillion', 'silmarillion-f13', 'idril', 'parent'),
    ('silmarillion', 'silmarillion-f13', 'earendil', 'child');
-- silmarillion-f14: Eärendil + Elwing → Elrond, Elros
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('silmarillion', 'silmarillion-f14', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('silmarillion', 'silmarillion-f14', 'earendil', 'parent'),
    ('silmarillion', 'silmarillion-f14', 'elwing', 'parent'),
    ('silmarillion', 'silmarillion-f14', 'elrond', 'child'),
    ('silmarillion', 'silmarillion-f14', 'elros', 'child');
-- silmarillion-f15: Elrond + Celebrían (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('silmarillion', 'silmarillion-f15', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('silmarillion', 'silmarillion-f15', 'elrond', 'parent'),
    ('silmarillion', 'silmarillion-f15', 'celebrian', 'parent');


-- =================================================================================================
-- SAGA 5 of 17: DUNE   [id: dune, category: fiction]
-- Author:  Frank Herbert; Dmitri, Abulurd and Anirul from the prequels by Brian Herbert & Kevin
-- J. Anderson
-- Medium:  Novel series (1965–1985); Dune, Dune Messiah, Children of Dune
-- Canon:   Novels
-- Covers:  Houses Atreides, Harkonnen and Corrino, the Fremen, and the Bene Gesserit, through
-- Leto II and Ghanima.
-- Rows:    5 houses, 23 people, 12 families, 35 members
-- =================================================================================================

-- ── Reset (removes this saga and, by cascade, all of its rows) ─────────────────────────────────
DELETE FROM saga WHERE id = 'dune';

-- ── Saga ───────────────────────────────────────────────────────────────────────────────────────
INSERT INTO saga (id, category, position, title, work, medium, author, canon, genre, covers) VALUES
    ('dune', 'fiction', 4, 'Dune', 'Dune', 'Novel series (1965–1985); Dune, Dune Messiah, Children of Dune', 'Frank Herbert; Dmitri, Abulurd and Anirul from the prequels by Brian Herbert & Kevin J. Anderson', 'Novels', 'Science fiction', 'Houses Atreides, Harkonnen and Corrino, the Fremen, and the Bene Gesserit, through Leto II and Ghanima.');

-- ── Notes (modelling choices and where sources disagree) ───────────────────────────────────────
INSERT INTO saga_note (saga_id, position, note) VALUES
    ('dune', 0, 'Jessica is the Baron''s daughter by Mohiam (revealed in the novels), so Paul is Harkonnen by blood.'),
    ('dune', 1, 'Anirul (Shaddam IV''s wife, mother of Irulan and Wensicia) is named in the prequels, not Frank Herbert''s novels.');

-- ── Houses (5) ─────────────────────────────────────────────────────────────────────────────────
INSERT INTO house (saga_id, name, color) VALUES
    ('dune', 'Atreides', '#2e8b57'),
    ('dune', 'Harkonnen', '#8a1c1c'),
    ('dune', 'Corrino', '#d4a72c'),
    ('dune', 'Bene Gesserit', '#6b4c9a'),
    ('dune', 'Fremen', '#c98b4a');

-- ── People (23, grouped by house) ──────────────────────────────────────────────────────────────
-- Atreides (8)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('dune', 'paulus', 'Paulus Atreides', 'Atreides', 'm', NULL),
    ('dune', 'leto', 'Duke Leto Atreides', 'Atreides', 'm', NULL),
    ('dune', 'paul', 'Paul Atreides (Muad''Dib)', 'Atreides', 'm', NULL),
    ('dune', 'alia', 'Alia Atreides', 'Atreides', 'f', NULL),
    ('dune', 'letoFirst', 'Leto (first son)', 'Atreides', 'm', NULL),
    ('dune', 'leto2', 'Leto II', 'Atreides', 'm', NULL),
    ('dune', 'ghanima', 'Ghanima', 'Atreides', 'f', NULL),
    ('dune', 'duncan', 'Duncan Idaho (ghola)', 'Atreides', 'm', NULL);
-- Harkonnen (5)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('dune', 'dmitri', 'Dmitri Harkonnen', 'Harkonnen', 'm', NULL),
    ('dune', 'vladimir', 'Baron Vladimir Harkonnen', 'Harkonnen', 'm', NULL),
    ('dune', 'abulurd', 'Abulurd Rabban', 'Harkonnen', 'm', NULL),
    ('dune', 'rabban', 'Glossu Rabban', 'Harkonnen', 'm', NULL),
    ('dune', 'feyd', 'Feyd-Rautha', 'Harkonnen', 'm', NULL);
-- Corrino (4)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('dune', 'shaddam', 'Shaddam IV', 'Corrino', 'm', NULL),
    ('dune', 'irulan', 'Princess Irulan', 'Corrino', 'f', NULL),
    ('dune', 'wensicia', 'Wensicia', 'Corrino', 'f', NULL),
    ('dune', 'farad', 'Farad''n Corrino', 'Corrino', 'm', NULL);
-- Bene Gesserit (3)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('dune', 'jessica', 'Lady Jessica', 'Bene Gesserit', 'f', NULL),
    ('dune', 'gaius', 'Gaius Helen Mohiam', 'Bene Gesserit', 'f', NULL),
    ('dune', 'anirul', 'Anirul', 'Bene Gesserit', 'f', NULL);
-- Fremen (3)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('dune', 'chani', 'Chani', 'Fremen', 'f', NULL),
    ('dune', 'liet', 'Liet-Kynes', 'Fremen', 'm', NULL),
    ('dune', 'faroula', 'Faroula', 'Fremen', 'f', NULL);

-- ── Families (12, each followed by its members) ────────────────────────────────────────────────
-- dune-f1: Paulus Atreides → Duke Leto Atreides
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('dune', 'dune-f1', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('dune', 'dune-f1', 'paulus', 'parent'),
    ('dune', 'dune-f1', 'leto', 'child');
-- dune-f2: Dmitri Harkonnen → Baron Vladimir Harkonnen, Abulurd Rabban
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('dune', 'dune-f2', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('dune', 'dune-f2', 'dmitri', 'parent'),
    ('dune', 'dune-f2', 'vladimir', 'child'),
    ('dune', 'dune-f2', 'abulurd', 'child');
-- dune-f3: Baron Vladimir Harkonnen + Gaius Helen Mohiam → Lady Jessica
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('dune', 'dune-f3', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('dune', 'dune-f3', 'vladimir', 'parent'),
    ('dune', 'dune-f3', 'gaius', 'parent'),
    ('dune', 'dune-f3', 'jessica', 'child');
-- dune-f4: Abulurd Rabban → Glossu Rabban, Feyd-Rautha
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('dune', 'dune-f4', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('dune', 'dune-f4', 'abulurd', 'parent'),
    ('dune', 'dune-f4', 'rabban', 'child'),
    ('dune', 'dune-f4', 'feyd', 'child');
-- dune-f5: Duke Leto Atreides + Lady Jessica → Paul Atreides (Muad'Dib), Alia Atreides
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('dune', 'dune-f5', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('dune', 'dune-f5', 'leto', 'parent'),
    ('dune', 'dune-f5', 'jessica', 'parent'),
    ('dune', 'dune-f5', 'paul', 'child'),
    ('dune', 'dune-f5', 'alia', 'child');
-- dune-f6: Liet-Kynes + Faroula → Chani
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('dune', 'dune-f6', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('dune', 'dune-f6', 'liet', 'parent'),
    ('dune', 'dune-f6', 'faroula', 'parent'),
    ('dune', 'dune-f6', 'chani', 'child');
-- dune-f7: Paul Atreides (Muad'Dib) + Chani → Leto (first son), Leto II, Ghanima
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('dune', 'dune-f7', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('dune', 'dune-f7', 'paul', 'parent'),
    ('dune', 'dune-f7', 'chani', 'parent'),
    ('dune', 'dune-f7', 'letoFirst', 'child'),
    ('dune', 'dune-f7', 'leto2', 'child'),
    ('dune', 'dune-f7', 'ghanima', 'child');
-- dune-f8: Shaddam IV + Anirul → Princess Irulan, Wensicia
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('dune', 'dune-f8', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('dune', 'dune-f8', 'shaddam', 'parent'),
    ('dune', 'dune-f8', 'anirul', 'parent'),
    ('dune', 'dune-f8', 'irulan', 'child'),
    ('dune', 'dune-f8', 'wensicia', 'child');
-- dune-f9: Paul Atreides (Muad'Dib) + Princess Irulan (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('dune', 'dune-f9', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('dune', 'dune-f9', 'paul', 'parent'),
    ('dune', 'dune-f9', 'irulan', 'parent');
-- dune-f10: Wensicia → Farad'n Corrino
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('dune', 'dune-f10', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('dune', 'dune-f10', 'wensicia', 'parent'),
    ('dune', 'dune-f10', 'farad', 'child');
-- dune-f11: Duncan Idaho (ghola) + Alia Atreides (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('dune', 'dune-f11', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('dune', 'dune-f11', 'duncan', 'parent'),
    ('dune', 'dune-f11', 'alia', 'parent');
-- dune-f12: Farad'n Corrino + Ghanima (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('dune', 'dune-f12', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('dune', 'dune-f12', 'farad', 'parent'),
    ('dune', 'dune-f12', 'ghanima', 'parent');


-- =================================================================================================
-- SAGA 6 of 17: HARRY POTTER   [id: potter, category: fiction]
-- Author:  J. K. Rowling
-- Medium:  Novel series (1997–2007)
-- Canon:   Novels, including the epilogue of Deathly Hallows, plus Rowling's published family
-- details (e.g. Fleamont Potter)
-- Covers:  Potter, Evans/Dursley, Weasley, Black/Tonks/Lupin and Malfoy families, through the
-- epilogue children.
-- Rows:    13 houses, 42 people, 13 families, 51 members
-- =================================================================================================

-- ── Reset (removes this saga and, by cascade, all of its rows) ─────────────────────────────────
DELETE FROM saga WHERE id = 'potter';

-- ── Saga ───────────────────────────────────────────────────────────────────────────────────────
INSERT INTO saga (id, category, position, title, work, medium, author, canon, genre, covers) VALUES
    ('potter', 'fiction', 5, 'Harry Potter', 'Harry Potter', 'Novel series (1997–2007)', 'J. K. Rowling', 'Novels, including the epilogue of Deathly Hallows, plus Rowling''s published family details (e.g. Fleamont Potter)', 'Fantasy', 'Potter, Evans/Dursley, Weasley, Black/Tonks/Lupin and Malfoy families, through the epilogue children.');

-- ── Houses (13) ────────────────────────────────────────────────────────────────────────────────
INSERT INTO house (saga_id, name, color) VALUES
    ('potter', 'Potter', '#b8342f'),
    ('potter', 'Evans', '#e58fa8'),
    ('potter', 'Dursley', '#9c8f7a'),
    ('potter', 'Weasley', '#e07a2e'),
    ('potter', 'Prewett', '#d9a441'),
    ('potter', 'Delacour', '#a8c8ef'),
    ('potter', 'Granger', '#8b5a2b'),
    ('potter', 'Black', '#4b4f6b'),
    ('potter', 'Tonks', '#d24fa8'),
    ('potter', 'Lupin', '#7a8a6a'),
    ('potter', 'Malfoy', '#3f9a74'),
    ('potter', 'Greengrass', '#a3c96a'),
    ('potter', 'Rosier', '#8a8f6a');

-- ── People (42, grouped by house) ──────────────────────────────────────────────────────────────
-- Potter (7)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('potter', 'fleamont', 'Fleamont Potter', 'Potter', 'm', NULL),
    ('potter', 'euphemia', 'Euphemia Potter', 'Potter', 'f', NULL),
    ('potter', 'james', 'James Potter', 'Potter', 'm', NULL),
    ('potter', 'harry', 'Harry Potter', 'Potter', 'm', NULL),
    ('potter', 'jamesS', 'James Sirius Potter', 'Potter', 'm', NULL),
    ('potter', 'albus', 'Albus Severus Potter', 'Potter', 'm', NULL),
    ('potter', 'lilyL', 'Lily Luna Potter', 'Potter', 'f', NULL);
-- Evans (2)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('potter', 'lily', 'Lily Evans', 'Evans', 'f', NULL),
    ('potter', 'petunia', 'Petunia Dursley', 'Evans', 'f', NULL);
-- Dursley (2)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('potter', 'vernon', 'Vernon Dursley', 'Dursley', 'm', NULL),
    ('potter', 'dudley', 'Dudley Dursley', 'Dursley', 'm', NULL);
-- Weasley (11)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('potter', 'arthur', 'Arthur Weasley', 'Weasley', 'm', NULL),
    ('potter', 'bill', 'Bill Weasley', 'Weasley', 'm', NULL),
    ('potter', 'charlie', 'Charlie Weasley', 'Weasley', 'm', NULL),
    ('potter', 'percy', 'Percy Weasley', 'Weasley', 'm', NULL),
    ('potter', 'fred', 'Fred Weasley', 'Weasley', 'm', NULL),
    ('potter', 'george', 'George Weasley', 'Weasley', 'm', NULL),
    ('potter', 'ron', 'Ron Weasley', 'Weasley', 'm', NULL),
    ('potter', 'ginny', 'Ginny Weasley', 'Weasley', 'f', NULL),
    ('potter', 'victoire', 'Victoire Weasley', 'Weasley', 'f', NULL),
    ('potter', 'rose', 'Rose Weasley', 'Weasley', 'f', NULL),
    ('potter', 'hugo', 'Hugo Weasley', 'Weasley', 'm', NULL);
-- Prewett (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('potter', 'molly', 'Molly Weasley', 'Prewett', 'f', NULL);
-- Delacour (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('potter', 'fleur', 'Fleur Delacour', 'Delacour', 'f', NULL);
-- Granger (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('potter', 'hermione', 'Hermione Granger', 'Granger', 'f', NULL);
-- Black (8)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('potter', 'cygnus', 'Cygnus Black', 'Black', 'm', NULL),
    ('potter', 'bellatrix', 'Bellatrix Lestrange', 'Black', 'f', NULL),
    ('potter', 'andromeda', 'Andromeda Tonks', 'Black', 'f', NULL),
    ('potter', 'narcissa', 'Narcissa Malfoy', 'Black', 'f', NULL),
    ('potter', 'orion', 'Orion Black', 'Black', 'm', NULL),
    ('potter', 'walburga', 'Walburga Black', 'Black', 'f', NULL),
    ('potter', 'sirius', 'Sirius Black', 'Black', 'm', NULL),
    ('potter', 'regulus', 'Regulus Black', 'Black', 'm', NULL);
-- Tonks (2)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('potter', 'ted', 'Ted Tonks', 'Tonks', 'm', NULL),
    ('potter', 'tonks', 'Nymphadora Tonks', 'Tonks', 'f', NULL);
-- Lupin (2)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('potter', 'remus', 'Remus Lupin', 'Lupin', 'm', NULL),
    ('potter', 'teddy', 'Teddy Lupin', 'Lupin', 'm', NULL);
-- Malfoy (3)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('potter', 'lucius', 'Lucius Malfoy', 'Malfoy', 'm', NULL),
    ('potter', 'draco', 'Draco Malfoy', 'Malfoy', 'm', NULL),
    ('potter', 'scorpius', 'Scorpius Malfoy', 'Malfoy', 'm', NULL);
-- Greengrass (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('potter', 'astoria', 'Astoria Greengrass', 'Greengrass', 'f', NULL);
-- Rosier (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('potter', 'druella', 'Druella Rosier', 'Rosier', 'f', NULL);

-- ── Families (13, each followed by its members) ────────────────────────────────────────────────
-- potter-f1: Fleamont Potter + Euphemia Potter → James Potter
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('potter', 'potter-f1', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('potter', 'potter-f1', 'fleamont', 'parent'),
    ('potter', 'potter-f1', 'euphemia', 'parent'),
    ('potter', 'potter-f1', 'james', 'child');
-- potter-f2: James Potter + Lily Evans → Harry Potter
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('potter', 'potter-f2', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('potter', 'potter-f2', 'james', 'parent'),
    ('potter', 'potter-f2', 'lily', 'parent'),
    ('potter', 'potter-f2', 'harry', 'child');
-- potter-f3: Vernon Dursley + Petunia Dursley → Dudley Dursley
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('potter', 'potter-f3', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('potter', 'potter-f3', 'vernon', 'parent'),
    ('potter', 'potter-f3', 'petunia', 'parent'),
    ('potter', 'potter-f3', 'dudley', 'child');
-- potter-f4: Harry Potter + Ginny Weasley → James Sirius Potter, Albus Severus Potter, Lily Luna Potter
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('potter', 'potter-f4', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('potter', 'potter-f4', 'harry', 'parent'),
    ('potter', 'potter-f4', 'ginny', 'parent'),
    ('potter', 'potter-f4', 'jamesS', 'child'),
    ('potter', 'potter-f4', 'albus', 'child'),
    ('potter', 'potter-f4', 'lilyL', 'child');
-- potter-f5: Arthur Weasley + Molly Weasley → Bill Weasley, Charlie Weasley, Percy Weasley, Fred Weasley, George Weasley, Ron Weasley, Ginny Weasley
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('potter', 'potter-f5', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('potter', 'potter-f5', 'arthur', 'parent'),
    ('potter', 'potter-f5', 'molly', 'parent'),
    ('potter', 'potter-f5', 'bill', 'child'),
    ('potter', 'potter-f5', 'charlie', 'child'),
    ('potter', 'potter-f5', 'percy', 'child'),
    ('potter', 'potter-f5', 'fred', 'child'),
    ('potter', 'potter-f5', 'george', 'child'),
    ('potter', 'potter-f5', 'ron', 'child'),
    ('potter', 'potter-f5', 'ginny', 'child');
-- potter-f6: Bill Weasley + Fleur Delacour → Victoire Weasley
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('potter', 'potter-f6', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('potter', 'potter-f6', 'bill', 'parent'),
    ('potter', 'potter-f6', 'fleur', 'parent'),
    ('potter', 'potter-f6', 'victoire', 'child');
-- potter-f7: Ron Weasley + Hermione Granger → Rose Weasley, Hugo Weasley
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('potter', 'potter-f7', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('potter', 'potter-f7', 'ron', 'parent'),
    ('potter', 'potter-f7', 'hermione', 'parent'),
    ('potter', 'potter-f7', 'rose', 'child'),
    ('potter', 'potter-f7', 'hugo', 'child');
-- potter-f8: Cygnus Black + Druella Rosier → Bellatrix Lestrange, Andromeda Tonks, Narcissa Malfoy
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('potter', 'potter-f8', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('potter', 'potter-f8', 'cygnus', 'parent'),
    ('potter', 'potter-f8', 'druella', 'parent'),
    ('potter', 'potter-f8', 'bellatrix', 'child'),
    ('potter', 'potter-f8', 'andromeda', 'child'),
    ('potter', 'potter-f8', 'narcissa', 'child');
-- potter-f9: Orion Black + Walburga Black → Sirius Black, Regulus Black
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('potter', 'potter-f9', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('potter', 'potter-f9', 'orion', 'parent'),
    ('potter', 'potter-f9', 'walburga', 'parent'),
    ('potter', 'potter-f9', 'sirius', 'child'),
    ('potter', 'potter-f9', 'regulus', 'child');
-- potter-f10: Ted Tonks + Andromeda Tonks → Nymphadora Tonks
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('potter', 'potter-f10', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('potter', 'potter-f10', 'ted', 'parent'),
    ('potter', 'potter-f10', 'andromeda', 'parent'),
    ('potter', 'potter-f10', 'tonks', 'child');
-- potter-f11: Remus Lupin + Nymphadora Tonks → Teddy Lupin
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('potter', 'potter-f11', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('potter', 'potter-f11', 'remus', 'parent'),
    ('potter', 'potter-f11', 'tonks', 'parent'),
    ('potter', 'potter-f11', 'teddy', 'child');
-- potter-f12: Lucius Malfoy + Narcissa Malfoy → Draco Malfoy
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('potter', 'potter-f12', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('potter', 'potter-f12', 'lucius', 'parent'),
    ('potter', 'potter-f12', 'narcissa', 'parent'),
    ('potter', 'potter-f12', 'draco', 'child');
-- potter-f13: Draco Malfoy + Astoria Greengrass → Scorpius Malfoy
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('potter', 'potter-f13', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('potter', 'potter-f13', 'draco', 'parent'),
    ('potter', 'potter-f13', 'astoria', 'parent'),
    ('potter', 'potter-f13', 'scorpius', 'child');


-- =================================================================================================
-- SAGA 7 of 17: STAR WARS   [id: starwars, category: fiction]
-- Author:  Created by George Lucas; sequel trilogy by J. J. Abrams and Rian Johnson
-- Medium:  Film series, the Skywalker saga (1977–2019), Episodes I–IX
-- Canon:   Films (current Disney canon)
-- Covers:  Skywalker, Lars, Naberrie, Organa and Solo, and the Palpatine line down to Rey.
-- Rows:    8 houses, 19 people, 10 families, 28 members
-- =================================================================================================

-- ── Reset (removes this saga and, by cascade, all of its rows) ─────────────────────────────────
DELETE FROM saga WHERE id = 'starwars';

-- ── Saga ───────────────────────────────────────────────────────────────────────────────────────
INSERT INTO saga (id, category, position, title, work, medium, author, canon, genre, covers) VALUES
    ('starwars', 'fiction', 6, 'Star Wars', 'Star Wars', 'Film series, the Skywalker saga (1977–2019), Episodes I–IX', 'Created by George Lucas; sequel trilogy by J. J. Abrams and Rian Johnson', 'Films (current Disney canon)', 'Science fiction (space opera)', 'Skywalker, Lars, Naberrie, Organa and Solo, and the Palpatine line down to Rey.');

-- ── Notes (modelling choices and where sources disagree) ───────────────────────────────────────
INSERT INTO saga_note (saga_id, position, note) VALUES
    ('starwars', 0, 'Dathan is a strand-cast clone of Palpatine, shown here as his son; add a "clone" kind if that matters.');

-- ── Houses (8) ─────────────────────────────────────────────────────────────────────────────────
INSERT INTO house (saga_id, name, color) VALUES
    ('starwars', 'Skywalker', '#4f9be8'),
    ('starwars', 'Lars', '#c9a46a'),
    ('starwars', 'Naberrie', '#d77fb0'),
    ('starwars', 'Organa', '#e8e8ee'),
    ('starwars', 'Solo', '#8a6a4a'),
    ('starwars', 'Palpatine', '#b3202a'),
    ('starwars', 'Unknown', '#8a8a96'),
    ('starwars', 'Whitesun', '#d8c89a');

-- ── People (19, grouped by house) ──────────────────────────────────────────────────────────────
-- Skywalker (3)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('starwars', 'shmi', 'Shmi Skywalker', 'Skywalker', 'f', NULL),
    ('starwars', 'anakin', 'Anakin Skywalker', 'Skywalker', 'm', NULL),
    ('starwars', 'luke', 'Luke Skywalker', 'Skywalker', 'm', NULL);
-- Lars (2)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('starwars', 'cliegg', 'Cliegg Lars', 'Lars', 'm', NULL),
    ('starwars', 'owen', 'Owen Lars', 'Lars', 'm', NULL);
-- Naberrie (4)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('starwars', 'padme', 'Padmé Amidala', 'Naberrie', 'f', NULL),
    ('starwars', 'ruwee', 'Ruwee Naberrie', 'Naberrie', 'm', NULL),
    ('starwars', 'jobal', 'Jobal Naberrie', 'Naberrie', 'f', NULL),
    ('starwars', 'sola', 'Sola Naberrie', 'Naberrie', 'f', NULL);
-- Organa (3)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('starwars', 'leia', 'Leia Organa', 'Organa', 'f', NULL),
    ('starwars', 'bail', 'Bail Organa', 'Organa', 'm', NULL),
    ('starwars', 'breha', 'Breha Organa', 'Organa', 'f', NULL);
-- Solo (2)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('starwars', 'han', 'Han Solo', 'Solo', 'm', NULL),
    ('starwars', 'ben', 'Ben Solo (Kylo Ren)', 'Solo', 'm', NULL);
-- Palpatine (3)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('starwars', 'palpatine', 'Sheev Palpatine', 'Palpatine', 'm', NULL),
    ('starwars', 'dathan', 'Dathan', 'Palpatine', 'm', NULL),
    ('starwars', 'rey', 'Rey', 'Palpatine', 'f', NULL);
-- Unknown (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('starwars', 'miramir', 'Miramir', 'Unknown', 'f', NULL);
-- Whitesun (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('starwars', 'beru', 'Beru Whitesun Lars', 'Whitesun', 'f', NULL);

-- ── Families (10, each followed by its members) ────────────────────────────────────────────────
-- starwars-f1: Shmi Skywalker → Anakin Skywalker
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('starwars', 'starwars-f1', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('starwars', 'starwars-f1', 'shmi', 'parent'),
    ('starwars', 'starwars-f1', 'anakin', 'child');
-- starwars-f2: Cliegg Lars → Owen Lars
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('starwars', 'starwars-f2', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('starwars', 'starwars-f2', 'cliegg', 'parent'),
    ('starwars', 'starwars-f2', 'owen', 'child');
-- starwars-f3: Cliegg Lars + Shmi Skywalker (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('starwars', 'starwars-f3', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('starwars', 'starwars-f3', 'cliegg', 'parent'),
    ('starwars', 'starwars-f3', 'shmi', 'parent');
-- starwars-f4: Owen Lars + Beru Whitesun Lars → Luke Skywalker   [adoptive]
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('starwars', 'starwars-f4', TRUE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('starwars', 'starwars-f4', 'owen', 'parent'),
    ('starwars', 'starwars-f4', 'beru', 'parent'),
    ('starwars', 'starwars-f4', 'luke', 'child');
-- starwars-f5: Ruwee Naberrie + Jobal Naberrie → Padmé Amidala, Sola Naberrie
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('starwars', 'starwars-f5', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('starwars', 'starwars-f5', 'ruwee', 'parent'),
    ('starwars', 'starwars-f5', 'jobal', 'parent'),
    ('starwars', 'starwars-f5', 'padme', 'child'),
    ('starwars', 'starwars-f5', 'sola', 'child');
-- starwars-f6: Anakin Skywalker + Padmé Amidala → Luke Skywalker, Leia Organa
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('starwars', 'starwars-f6', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('starwars', 'starwars-f6', 'anakin', 'parent'),
    ('starwars', 'starwars-f6', 'padme', 'parent'),
    ('starwars', 'starwars-f6', 'luke', 'child'),
    ('starwars', 'starwars-f6', 'leia', 'child');
-- starwars-f7: Bail Organa + Breha Organa → Leia Organa   [adoptive]
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('starwars', 'starwars-f7', TRUE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('starwars', 'starwars-f7', 'bail', 'parent'),
    ('starwars', 'starwars-f7', 'breha', 'parent'),
    ('starwars', 'starwars-f7', 'leia', 'child');
-- starwars-f8: Han Solo + Leia Organa → Ben Solo (Kylo Ren)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('starwars', 'starwars-f8', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('starwars', 'starwars-f8', 'han', 'parent'),
    ('starwars', 'starwars-f8', 'leia', 'parent'),
    ('starwars', 'starwars-f8', 'ben', 'child');
-- starwars-f9: Sheev Palpatine → Dathan
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('starwars', 'starwars-f9', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('starwars', 'starwars-f9', 'palpatine', 'parent'),
    ('starwars', 'starwars-f9', 'dathan', 'child');
-- starwars-f10: Dathan + Miramir → Rey
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('starwars', 'starwars-f10', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('starwars', 'starwars-f10', 'dathan', 'parent'),
    ('starwars', 'starwars-f10', 'miramir', 'parent'),
    ('starwars', 'starwars-f10', 'rey', 'child');


-- =================================================================================================
-- SAGA 8 of 17: THE WHEEL OF TIME   [id: wot, category: fiction]
-- Author:  Robert Jordan; final three books completed by Brandon Sanderson
-- Medium:  Novel series (1990–2013), 14 books
-- Canon:   Novels
-- Covers:  Rand al'Thor's Aiel and Andoran royal ancestry, and the Trakand/Damodred
-- half-siblings linked through his mother Tigraine.
-- Rows:    7 houses, 17 people, 11 families, 27 members
-- =================================================================================================

-- ── Reset (removes this saga and, by cascade, all of its rows) ─────────────────────────────────
DELETE FROM saga WHERE id = 'wot';

-- ── Saga ───────────────────────────────────────────────────────────────────────────────────────
INSERT INTO saga (id, category, position, title, work, medium, author, canon, genre, covers) VALUES
    ('wot', 'fiction', 7, 'The Wheel of Time', 'The Wheel of Time', 'Novel series (1990–2013), 14 books', 'Robert Jordan; final three books completed by Brandon Sanderson', 'Novels', 'Epic fantasy', 'Rand al''Thor''s Aiel and Andoran royal ancestry, and the Trakand/Damodred half-siblings linked through his mother Tigraine.');

-- ── Notes (modelling choices and where sources disagree) ───────────────────────────────────────
INSERT INTO saga_note (saga_id, position, note) VALUES
    ('wot', 0, 'Tigraine is both Galad''s mother (by Taringail) and Rand''s (by Janduin), which links the two halves.'),
    ('wot', 1, 'Taringail and Moiraine are cousins, not siblings; Taringail''s parents are not named, so he has a parentless entry.');

-- ── Houses (7) ─────────────────────────────────────────────────────────────────────────────────
INSERT INTO house (saga_id, name, color) VALUES
    ('wot', 'Mantear', '#d77f3a'),
    ('wot', 'Trakand', '#e0b23a'),
    ('wot', 'Damodred', '#3f9a4b'),
    ('wot', 'Aiel', '#b08a5a'),
    ('wot', 'al''Thor', '#5a7fa8'),
    ('wot', 'al''Vere', '#8a6ac8'),
    ('wot', 'Farshaw', '#c8a8d8');

-- ── People (17, grouped by house) ──────────────────────────────────────────────────────────────
-- Mantear (3)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('wot', 'mordrellen', 'Mordrellen', 'Mantear', 'f', NULL),
    ('wot', 'tigraine', 'Tigraine Mantear', 'Mantear', 'f', NULL),
    ('wot', 'luc', 'Luc Mantear', 'Mantear', 'm', NULL);
-- Trakand (3)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('wot', 'morgase', 'Morgase Trakand', 'Trakand', 'f', NULL),
    ('wot', 'elayne', 'Elayne Trakand', 'Trakand', 'f', NULL),
    ('wot', 'gawyn', 'Gawyn Trakand', 'Trakand', 'm', NULL);
-- Damodred (4)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('wot', 'taringail', 'Taringail Damodred', 'Damodred', 'm', NULL),
    ('wot', 'galad', 'Galad Damodred', 'Damodred', 'm', NULL),
    ('wot', 'moiraine', 'Moiraine Damodred', 'Damodred', 'f', NULL),
    ('wot', 'dalresin', 'Dalresin Damodred', 'Damodred', 'm', NULL);
-- Aiel (2)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('wot', 'janduin', 'Janduin', 'Aiel', 'm', NULL),
    ('wot', 'aviendha', 'Aviendha', 'Aiel', 'f', NULL);
-- al'Thor (3)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('wot', 'tam', 'Tam al''Thor', 'al''Thor', 'm', NULL),
    ('wot', 'kari', 'Kari al''Thor', 'al''Thor', 'f', NULL),
    ('wot', 'rand', 'Rand al''Thor', 'al''Thor', 'm', NULL);
-- al'Vere (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('wot', 'egwene', 'Egwene al''Vere', 'al''Vere', 'f', NULL);
-- Farshaw (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('wot', 'min', 'Min Farshaw', 'Farshaw', 'f', NULL);

-- ── Families (11, each followed by its members) ────────────────────────────────────────────────
-- wot-f1: Mordrellen → Tigraine Mantear, Luc Mantear
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('wot', 'wot-f1', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('wot', 'wot-f1', 'mordrellen', 'parent'),
    ('wot', 'wot-f1', 'tigraine', 'child'),
    ('wot', 'wot-f1', 'luc', 'child');
-- wot-f2: Dalresin Damodred → Moiraine Damodred
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('wot', 'wot-f2', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('wot', 'wot-f2', 'dalresin', 'parent'),
    ('wot', 'wot-f2', 'moiraine', 'child');
-- wot-f3: Taringail Damodred + Tigraine Mantear → Galad Damodred
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('wot', 'wot-f3', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('wot', 'wot-f3', 'taringail', 'parent'),
    ('wot', 'wot-f3', 'tigraine', 'parent'),
    ('wot', 'wot-f3', 'galad', 'child');
-- wot-f4: Janduin + Tigraine Mantear → Rand al'Thor
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('wot', 'wot-f4', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('wot', 'wot-f4', 'janduin', 'parent'),
    ('wot', 'wot-f4', 'tigraine', 'parent'),
    ('wot', 'wot-f4', 'rand', 'child');
-- wot-f5: Tam al'Thor + Kari al'Thor → Rand al'Thor   [adoptive]
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('wot', 'wot-f5', TRUE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('wot', 'wot-f5', 'tam', 'parent'),
    ('wot', 'wot-f5', 'kari', 'parent'),
    ('wot', 'wot-f5', 'rand', 'child');
-- wot-f6: Taringail Damodred + Morgase Trakand → Elayne Trakand, Gawyn Trakand
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('wot', 'wot-f6', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('wot', 'wot-f6', 'taringail', 'parent'),
    ('wot', 'wot-f6', 'morgase', 'parent'),
    ('wot', 'wot-f6', 'elayne', 'child'),
    ('wot', 'wot-f6', 'gawyn', 'child');
-- wot-f7: Rand al'Thor + Elayne Trakand (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('wot', 'wot-f7', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('wot', 'wot-f7', 'rand', 'parent'),
    ('wot', 'wot-f7', 'elayne', 'parent');
-- wot-f8: Rand al'Thor + Min Farshaw (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('wot', 'wot-f8', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('wot', 'wot-f8', 'rand', 'parent'),
    ('wot', 'wot-f8', 'min', 'parent');
-- wot-f9: Rand al'Thor + Aviendha (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('wot', 'wot-f9', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('wot', 'wot-f9', 'rand', 'parent'),
    ('wot', 'wot-f9', 'aviendha', 'parent');
-- wot-f10: Gawyn Trakand + Egwene al'Vere (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('wot', 'wot-f10', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('wot', 'wot-f10', 'gawyn', 'parent'),
    ('wot', 'wot-f10', 'egwene', 'parent');
-- wot-f11: (parents unknown) → Taringail Damodred
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('wot', 'wot-f11', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('wot', 'wot-f11', 'taringail', 'child');


-- =================================================================================================
-- SAGA 9 of 17: THE STORMLIGHT ARCHIVE   [id: stormlight, category: fiction]
-- Author:  Brandon Sanderson
-- Medium:  Novel series (2010–), set in the Cosmere
-- Canon:   Novels (up to Wind and Truth)
-- Covers:  House Kholin and its marriages, House Davar (Shallan's family), and Kaladin's family.
-- Rows:    4 houses, 22 people, 9 families, 30 members
-- =================================================================================================

-- ── Reset (removes this saga and, by cascade, all of its rows) ─────────────────────────────────
DELETE FROM saga WHERE id = 'stormlight';

-- ── Saga ───────────────────────────────────────────────────────────────────────────────────────
INSERT INTO saga (id, category, position, title, work, medium, author, canon, genre, covers) VALUES
    ('stormlight', 'fiction', 8, 'The Stormlight Archive', 'The Stormlight Archive', 'Novel series (2010–), set in the Cosmere', 'Brandon Sanderson', 'Novels (up to Wind and Truth)', 'Epic fantasy', 'House Kholin and its marriages, House Davar (Shallan''s family), and Kaladin''s family.');

-- ── Notes (modelling choices and where sources disagree) ───────────────────────────────────────
INSERT INTO saga_note (saga_id, position, note) VALUES
    ('stormlight', 0, 'Unnamed parents: Gavilar & Dalinar, and Evi & Toh, are parentless sibling groups.'),
    ('stormlight', 1, 'Navani marries Gavilar, then after his death Dalinar.'),
    ('stormlight', 2, 'Aesudan''s birth house is not named in the books; she is shown in House Kholin by marriage.');

-- ── Houses (4) ─────────────────────────────────────────────────────────────────────────────────
INSERT INTO house (saga_id, name, color) VALUES
    ('stormlight', 'Kholin', '#2f5fb0'),
    ('stormlight', 'Riran', '#d8c8a8'),
    ('stormlight', 'Davar', '#c44a3a'),
    ('stormlight', 'Khinar', '#6a9a7a');

-- ── People (22, grouped by house) ──────────────────────────────────────────────────────────────
-- Kholin (9)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('stormlight', 'gavilar', 'Gavilar Kholin', 'Kholin', 'm', NULL),
    ('stormlight', 'navani', 'Navani Kholin', 'Kholin', 'f', NULL),
    ('stormlight', 'dalinar', 'Dalinar Kholin', 'Kholin', 'm', NULL),
    ('stormlight', 'elhokar', 'Elhokar', 'Kholin', 'm', NULL),
    ('stormlight', 'aesudan', 'Aesudan', 'Kholin', 'f', NULL),
    ('stormlight', 'gavinor', 'Gavinor', 'Kholin', 'm', NULL),
    ('stormlight', 'jasnah', 'Jasnah Kholin', 'Kholin', 'f', NULL),
    ('stormlight', 'adolin', 'Adolin Kholin', 'Kholin', 'm', NULL),
    ('stormlight', 'renarin', 'Renarin Kholin', 'Kholin', 'm', NULL);
-- Riran (2)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('stormlight', 'evi', 'Evi', 'Riran', 'f', NULL),
    ('stormlight', 'toh', 'Toh', 'Riran', 'm', NULL);
-- Davar (6)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('stormlight', 'shallan', 'Shallan Davar', 'Davar', 'f', NULL),
    ('stormlight', 'lin', 'Lin Davar', 'Davar', 'm', NULL),
    ('stormlight', 'helaran', 'Helaran Davar', 'Davar', 'm', NULL),
    ('stormlight', 'balat', 'Balat Davar', 'Davar', 'm', NULL),
    ('stormlight', 'wikim', 'Wikim Davar', 'Davar', 'm', NULL),
    ('stormlight', 'jushu', 'Jushu Davar', 'Davar', 'm', NULL);
-- Khinar (5)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('stormlight', 'lirin', 'Lirin', 'Khinar', 'm', NULL),
    ('stormlight', 'hesina', 'Hesina', 'Khinar', 'f', NULL),
    ('stormlight', 'kaladin', 'Kaladin', 'Khinar', 'm', NULL),
    ('stormlight', 'tien', 'Tien', 'Khinar', 'm', NULL),
    ('stormlight', 'oroden', 'Oroden', 'Khinar', 'm', NULL);

-- ── Families (9, each followed by its members) ─────────────────────────────────────────────────
-- stormlight-f1: (parents unknown) → Gavilar Kholin, Dalinar Kholin
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('stormlight', 'stormlight-f1', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('stormlight', 'stormlight-f1', 'gavilar', 'child'),
    ('stormlight', 'stormlight-f1', 'dalinar', 'child');
-- stormlight-f2: Gavilar Kholin + Navani Kholin → Elhokar, Jasnah Kholin
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('stormlight', 'stormlight-f2', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('stormlight', 'stormlight-f2', 'gavilar', 'parent'),
    ('stormlight', 'stormlight-f2', 'navani', 'parent'),
    ('stormlight', 'stormlight-f2', 'elhokar', 'child'),
    ('stormlight', 'stormlight-f2', 'jasnah', 'child');
-- stormlight-f3: Elhokar + Aesudan → Gavinor
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('stormlight', 'stormlight-f3', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('stormlight', 'stormlight-f3', 'elhokar', 'parent'),
    ('stormlight', 'stormlight-f3', 'aesudan', 'parent'),
    ('stormlight', 'stormlight-f3', 'gavinor', 'child');
-- stormlight-f4: (parents unknown) → Evi, Toh
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('stormlight', 'stormlight-f4', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('stormlight', 'stormlight-f4', 'evi', 'child'),
    ('stormlight', 'stormlight-f4', 'toh', 'child');
-- stormlight-f5: Dalinar Kholin + Evi → Adolin Kholin, Renarin Kholin
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('stormlight', 'stormlight-f5', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('stormlight', 'stormlight-f5', 'dalinar', 'parent'),
    ('stormlight', 'stormlight-f5', 'evi', 'parent'),
    ('stormlight', 'stormlight-f5', 'adolin', 'child'),
    ('stormlight', 'stormlight-f5', 'renarin', 'child');
-- stormlight-f6: Dalinar Kholin + Navani Kholin (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('stormlight', 'stormlight-f6', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('stormlight', 'stormlight-f6', 'dalinar', 'parent'),
    ('stormlight', 'stormlight-f6', 'navani', 'parent');
-- stormlight-f7: Lin Davar → Helaran Davar, Balat Davar, Wikim Davar, Jushu Davar, Shallan Davar
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('stormlight', 'stormlight-f7', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('stormlight', 'stormlight-f7', 'lin', 'parent'),
    ('stormlight', 'stormlight-f7', 'helaran', 'child'),
    ('stormlight', 'stormlight-f7', 'balat', 'child'),
    ('stormlight', 'stormlight-f7', 'wikim', 'child'),
    ('stormlight', 'stormlight-f7', 'jushu', 'child'),
    ('stormlight', 'stormlight-f7', 'shallan', 'child');
-- stormlight-f8: Adolin Kholin + Shallan Davar (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('stormlight', 'stormlight-f8', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('stormlight', 'stormlight-f8', 'adolin', 'parent'),
    ('stormlight', 'stormlight-f8', 'shallan', 'parent');
-- stormlight-f9: Lirin + Hesina → Kaladin, Tien, Oroden
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('stormlight', 'stormlight-f9', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('stormlight', 'stormlight-f9', 'lirin', 'parent'),
    ('stormlight', 'stormlight-f9', 'hesina', 'parent'),
    ('stormlight', 'stormlight-f9', 'kaladin', 'child'),
    ('stormlight', 'stormlight-f9', 'tien', 'child'),
    ('stormlight', 'stormlight-f9', 'oroden', 'child');


-- =================================================================================================
-- SAGA 10 of 17: THE WITCHER   [id: witcher, category: fiction]
-- Author:  Andrzej Sapkowski
-- Medium:  Novel and short-story series (1986–2013), the Witcher saga
-- Canon:   Books (not the games or the Netflix series)
-- Covers:  The royal line of Cintra and the Elder Blood from Lara Dorren to Ciri, and her
-- guardians Geralt and Yennefer.
-- Rows:    10 houses, 18 people, 10 families, 28 members
-- =================================================================================================

-- ── Reset (removes this saga and, by cascade, all of its rows) ─────────────────────────────────
DELETE FROM saga WHERE id = 'witcher';

-- ── Saga ───────────────────────────────────────────────────────────────────────────────────────
INSERT INTO saga (id, category, position, title, work, medium, author, canon, genre, covers) VALUES
    ('witcher', 'fiction', 9, 'The Witcher', 'The Witcher', 'Novel and short-story series (1986–2013), the Witcher saga', 'Andrzej Sapkowski', 'Books (not the games or the Netflix series)', 'Fantasy (Slavic-inspired)', 'The royal line of Cintra and the Elder Blood from Lara Dorren to Ciri, and her guardians Geralt and Yennefer.');

-- ── Notes (modelling choices and where sources disagree) ───────────────────────────────────────
INSERT INTO saga_note (saga_id, position, note) VALUES
    ('witcher', 0, 'Ciri''s names trace the Elder Blood: Cirilla, Fiona, Elen, Riannon.'),
    ('witcher', 1, 'Geralt and Yennefer are Ciri''s guardians by destiny, not adoption; modelled as adoptive parents.');

-- ── Houses (10) ────────────────────────────────────────────────────────────────────────────────
INSERT INTO house (saga_id, name, color) VALUES
    ('witcher', 'Aen Seidhe', '#9ad8b0'),
    ('witcher', 'Lod', '#b0a8d8'),
    ('witcher', 'Cintra', '#d4a72c'),
    ('witcher', 'Temeria', '#3b6fb6'),
    ('witcher', 'Kovir', '#7fa8c8'),
    ('witcher', 'Ebbing', '#a87a4a'),
    ('witcher', 'Skellige', '#4a8a9a'),
    ('witcher', 'Nilfgaard', '#2a2a3a'),
    ('witcher', 'Witchers', '#a8a8b0'),
    ('witcher', 'Sorceresses', '#6a3a8a');

-- ── People (18, grouped by house) ──────────────────────────────────────────────────────────────
-- Aen Seidhe (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('witcher', 'lara', 'Lara Dorren', 'Aen Seidhe', 'f', NULL);
-- Lod (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('witcher', 'cregennan', 'Cregennan of Lod', 'Lod', 'm', NULL);
-- Cintra (8)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('witcher', 'riannon', 'Riannon', 'Cintra', 'f', NULL),
    ('witcher', 'fiona', 'Fiona', 'Cintra', 'f', NULL),
    ('witcher', 'corbett', 'Corbett', 'Cintra', 'm', NULL),
    ('witcher', 'dagorad', 'Dagorad', 'Cintra', 'm', NULL),
    ('witcher', 'adalia', 'Adalia the Leech', 'Cintra', 'f', NULL),
    ('witcher', 'calanthe', 'Calanthe', 'Cintra', 'f', NULL),
    ('witcher', 'pavetta', 'Pavetta', 'Cintra', 'f', NULL),
    ('witcher', 'ciri', 'Cirilla Fiona Elen Riannon', 'Cintra', 'f', NULL);
-- Temeria (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('witcher', 'goidemar', 'Goidemar', 'Temeria', 'm', NULL);
-- Kovir (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('witcher', 'elen', 'Elen of Kovir', 'Kovir', 'f', NULL);
-- Ebbing (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('witcher', 'roegner', 'Roegner of Ebbing', 'Ebbing', 'm', NULL);
-- Skellige (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('witcher', 'eist', 'Eist Tuirseach', 'Skellige', 'm', NULL);
-- Nilfgaard (2)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('witcher', 'duny', 'Duny (Emhyr var Emreis)', 'Nilfgaard', 'm', NULL),
    ('witcher', 'fergus', 'Fergus var Emreis', 'Nilfgaard', 'm', NULL);
-- Witchers (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('witcher', 'geralt', 'Geralt of Rivia', 'Witchers', 'm', NULL);
-- Sorceresses (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('witcher', 'yennefer', 'Yennefer of Vengerberg', 'Sorceresses', 'f', NULL);

-- ── Families (10, each followed by its members) ────────────────────────────────────────────────
-- witcher-f1: Cregennan of Lod + Lara Dorren → Riannon
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('witcher', 'witcher-f1', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('witcher', 'witcher-f1', 'cregennan', 'parent'),
    ('witcher', 'witcher-f1', 'lara', 'parent'),
    ('witcher', 'witcher-f1', 'riannon', 'child');
-- witcher-f2: Goidemar + Riannon → Fiona
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('witcher', 'witcher-f2', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('witcher', 'witcher-f2', 'goidemar', 'parent'),
    ('witcher', 'witcher-f2', 'riannon', 'parent'),
    ('witcher', 'witcher-f2', 'fiona', 'child');
-- witcher-f3: Fiona → Corbett
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('witcher', 'witcher-f3', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('witcher', 'witcher-f3', 'fiona', 'parent'),
    ('witcher', 'witcher-f3', 'corbett', 'child');
-- witcher-f4: Corbett + Elen of Kovir → Dagorad, Adalia the Leech
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('witcher', 'witcher-f4', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('witcher', 'witcher-f4', 'corbett', 'parent'),
    ('witcher', 'witcher-f4', 'elen', 'parent'),
    ('witcher', 'witcher-f4', 'dagorad', 'child'),
    ('witcher', 'witcher-f4', 'adalia', 'child');
-- witcher-f5: Dagorad + Adalia the Leech → Calanthe
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('witcher', 'witcher-f5', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('witcher', 'witcher-f5', 'dagorad', 'parent'),
    ('witcher', 'witcher-f5', 'adalia', 'parent'),
    ('witcher', 'witcher-f5', 'calanthe', 'child');
-- witcher-f6: Roegner of Ebbing + Calanthe → Pavetta
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('witcher', 'witcher-f6', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('witcher', 'witcher-f6', 'roegner', 'parent'),
    ('witcher', 'witcher-f6', 'calanthe', 'parent'),
    ('witcher', 'witcher-f6', 'pavetta', 'child');
-- witcher-f7: Eist Tuirseach + Calanthe (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('witcher', 'witcher-f7', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('witcher', 'witcher-f7', 'eist', 'parent'),
    ('witcher', 'witcher-f7', 'calanthe', 'parent');
-- witcher-f8: Fergus var Emreis → Duny (Emhyr var Emreis)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('witcher', 'witcher-f8', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('witcher', 'witcher-f8', 'fergus', 'parent'),
    ('witcher', 'witcher-f8', 'duny', 'child');
-- witcher-f9: Duny (Emhyr var Emreis) + Pavetta → Cirilla Fiona Elen Riannon
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('witcher', 'witcher-f9', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('witcher', 'witcher-f9', 'duny', 'parent'),
    ('witcher', 'witcher-f9', 'pavetta', 'parent'),
    ('witcher', 'witcher-f9', 'ciri', 'child');
-- witcher-f10: Geralt of Rivia + Yennefer of Vengerberg → Cirilla Fiona Elen Riannon   [adoptive]
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('witcher', 'witcher-f10', TRUE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('witcher', 'witcher-f10', 'geralt', 'parent'),
    ('witcher', 'witcher-f10', 'yennefer', 'parent'),
    ('witcher', 'witcher-f10', 'ciri', 'child');


-- =================================================================================================
-- SAGA 11 of 17: ENGLISH ROYAL FAMILY (TUDORS)   [id: english-royal, category: history]
-- Author:  Compiled by Chris Phillips
-- Medium:  GEDCOM genealogy (English+Tudor+Royal+Family.ged)
-- Canon:   Sources cited: The Complete Peerage; Scots Peerage; Mary Boleyn's Carey children  -
-- offspring of King Henry VIII?; The Earlier Tudors 1485-1558; Dictionary of National Biography
-- Covers:  268 people and 175 families, imported from a public GEDCOM sample.
-- Rows:    13 houses, 268 people, 175 families, 459 members
-- =================================================================================================

-- ── Reset (removes this saga and, by cascade, all of its rows) ─────────────────────────────────
DELETE FROM saga WHERE id = 'english-royal';

-- ── Saga ───────────────────────────────────────────────────────────────────────────────────────
INSERT INTO saga (id, category, position, title, work, medium, author, canon, genre, covers) VALUES
    ('english-royal', 'history', 10, 'English Royal Family (Tudors)', 'English Royal Family (Tudors)', 'GEDCOM genealogy (English+Tudor+Royal+Family.ged)', 'Compiled by Chris Phillips', 'Sources cited: The Complete Peerage; Scots Peerage; Mary Boleyn''s Carey children  - offspring of King Henry VIII?; The Earlier Tudors 1485-1558; Dictionary of National Biography', 'History', '268 people and 175 families, imported from a public GEDCOM sample.');

-- ── Notes (modelling choices and where sources disagree) ───────────────────────────────────────
INSERT INTO saga_note (saga_id, position, note) VALUES
    ('english-royal', 0, 'Imported from English+Tudor+Royal+Family.ged (Windows-1252; PAF 5.1.12.0; file dated 30 Aug 2003) by scripts/gedcom-to-saga.mts.'),
    ('english-royal', 1, 'Display names are the person''s name only; a monarch is shown by their regnal name (e.g. King Henry VIII). Titles, title dates and life dates are not imported.'),
    ('english-royal', 2, 'Houses are surnames; only the 12 largest keep their own colour, the rest are grouped as "Other families".');

-- ── Houses (13) ────────────────────────────────────────────────────────────────────────────────
INSERT INTO house (saga_id, name, color) VALUES
    ('english-royal', 'Stewart', '#c8102e'),
    ('english-royal', 'Tudor', '#e0b23a'),
    ('english-royal', 'Howard', '#3b6fb6'),
    ('english-royal', 'Plantagenet', '#3f9a4b'),
    ('english-royal', 'Grey', '#8a5fd0'),
    ('english-royal', 'Douglas', '#e07a2e'),
    ('english-royal', 'Stafford', '#4aa8c8'),
    ('english-royal', 'Seymour', '#d24fa8'),
    ('english-royal', 'Neville', '#9aa9b8'),
    ('english-royal', 'Valois', '#a87a4a'),
    ('english-royal', 'Stuart', '#7fc4ff'),
    ('english-royal', 'Stanley', '#b3202a'),
    ('english-royal', 'Other families', '#6f6a78');

-- ── People (268, grouped by house) ─────────────────────────────────────────────────────────────
-- Stewart (21)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('english-royal', 'james-stewart', 'James Stewart', 'Stewart', 'm', '1507-02-21'),
    ('english-royal', 'henry-stewart', 'Henry Stewart', 'Stewart', 'm', NULL),
    ('english-royal', 'andrew-stewart', 'Andrew Stewart', 'Stewart', 'm', NULL),
    ('english-royal', 'janet-stewart', 'Janet Stewart', 'Stewart', 'f', NULL),
    ('english-royal', 'john-stewart', 'John Stewart', 'Stewart', 'm', NULL),
    ('english-royal', 'james-stewart-2', 'James Stewart', 'Stewart', 'm', '1473-03-17'),
    ('english-royal', 'arthur-stewart', 'Arthur Stewart', 'Stewart', 'm', '1509-10-20'),
    ('english-royal', 'unnamed-daughter-stewart', '(unnamed daughter) Stewart', 'Stewart', 'f', '1508-07-15'),
    ('english-royal', 'james-stewart-3', 'James Stewart', 'Stewart', 'm', '1512-04-10'),
    ('english-royal', 'unnamed-daughter-stewart-2', '(unnamed daughter) Stewart', 'Stewart', 'f', '1512-00-00'),
    ('english-royal', 'alexander-stewart', 'Alexander Stewart', 'Stewart', 'm', '1513-09-09'),
    ('english-royal', 'alexander-stewart-2', 'Alexander Stewart', 'Stewart', 'm', '1493-00-00'),
    ('english-royal', 'catherine-stewart', 'Catherine Stewart', 'Stewart', 'f', NULL),
    ('english-royal', 'james-stewart-4', 'James Stewart', 'Stewart', 'm', '1499-00-00'),
    ('english-royal', 'margaret-stewart', 'Margaret Stewart', 'Stewart', 'f', '1497-00-00'),
    ('english-royal', 'isabella-stewart', 'Isabella Stewart', 'Stewart', 'f', NULL),
    ('english-royal', 'james-stewart-5', 'James Stewart', 'Stewart', 'm', NULL),
    ('english-royal', 'janet-stewart-2', 'Janet Stewart', 'Stewart', 'f', NULL),
    ('english-royal', 'james-stewart-6', 'James Stewart', 'Stewart', 'm', '1540-05-22'),
    ('english-royal', 'arthur-stewart-2', 'Arthur Stewart', 'Stewart', 'm', '1541-04-00'),
    ('english-royal', 'mary-stewart', 'Mary Stewart', 'Stewart', 'f', '1542-12-00');
-- Tudor (12)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('english-royal', 'henry-vii', 'Henry VII', 'Tudor', 'm', '1457-01-28'),
    ('english-royal', 'edmund-tudor', 'Edmund Tudor', 'Tudor', 'm', '1430-00-00'),
    ('english-royal', 'henry-viii', 'Henry VIII', 'Tudor', 'm', '1491-06-28'),
    ('english-royal', 'edmund-tudor-2', 'Edmund Tudor', 'Tudor', 'm', '1499-02-00'),
    ('english-royal', 'arthur-tudor', 'Arthur Tudor', 'Tudor', 'm', '1486-09-20'),
    ('english-royal', 'henry-tudor', 'Henry Tudor', 'Tudor', 'm', '1511-01-01'),
    ('english-royal', 'unnamed-son-tudor', '(unnamed son) Tudor', 'Tudor', 'm', '1514-11-00'),
    ('english-royal', 'edward-vi', 'Edward VI', 'Tudor', 'm', '1537-10-12'),
    ('english-royal', 'mary-tudor', 'Mary Tudor', 'Tudor', 'f', '1495-03-18'),
    ('english-royal', 'margaret-tudor', 'Margaret Tudor', 'Tudor', 'f', '1489-11-28'),
    ('english-royal', 'elizabeth-i', 'Elizabeth I', 'Tudor', 'f', '1533-09-07'),
    ('english-royal', 'mary-i', 'Mary I', 'Tudor', 'f', '1516-02-18');
-- Howard (12)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('english-royal', 'catherine-howard', 'Catherine Howard', 'Howard', 'f', NULL),
    ('english-royal', 'mary-howard', 'Mary Howard', 'Howard', 'f', NULL),
    ('english-royal', 'thomas-howard', 'Thomas Howard', 'Howard', 'm', '1473-00-00'),
    ('english-royal', 'elizabeth-howard', 'Elizabeth Howard', 'Howard', 'f', NULL),
    ('english-royal', 'thomas-howard-2', 'Thomas Howard', 'Howard', 'm', '1443-00-00'),
    ('english-royal', 'unnamed-son-howard', '(unnamed son) Howard', 'Howard', 'm', NULL),
    ('english-royal', 'dorothy-howard', 'Dorothy Howard', 'Howard', 'f', NULL),
    ('english-royal', 'edmund-howard', 'Edmund Howard', 'Howard', 'm', NULL),
    ('english-royal', 'frances-howard', 'Frances Howard', 'Howard', 'f', NULL),
    ('english-royal', 'william-howard', 'William Howard', 'Howard', 'm', NULL),
    ('english-royal', 'frances-howard-2', 'Frances Howard', 'Howard', 'f', NULL),
    ('english-royal', 'thomas-howard-3', 'Thomas Howard', 'Howard', 'm', NULL);
-- Plantagenet (10)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('english-royal', 'elizabeth-plantagenet', 'Elizabeth Plantagenet', 'Plantagenet', 'f', '1465-02-11'),
    ('english-royal', 'edward-iv', 'Edward IV', 'Plantagenet', 'm', '1442-04-28'),
    ('english-royal', 'arthur-plantagenet', 'Arthur Plantagenet', 'Plantagenet', 'm', NULL),
    ('english-royal', 'cecily-plantagenet', 'Cecily Plantagenet', 'Plantagenet', 'f', '1469-03-20'),
    ('english-royal', 'edward-v', 'Edward V', 'Plantagenet', 'm', '1470-11-00'),
    ('english-royal', 'richard-plantagenet', 'Richard Plantagenet', 'Plantagenet', 'm', '1473-08-17'),
    ('english-royal', 'george-plantagenet', 'George Plantagenet', 'Plantagenet', 'm', '1477-03-00'),
    ('english-royal', 'anne-plantagenet', 'Anne Plantagenet', 'Plantagenet', 'f', '1475-11-02'),
    ('english-royal', 'anne-plantagenet-2', 'Anne Plantagenet', 'Plantagenet', 'f', NULL),
    ('english-royal', 'richard-plantagenet-2', 'Richard Plantagenet', 'Plantagenet', 'm', NULL);
-- Grey (10)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('english-royal', 'elizabeth-grey', 'Elizabeth Grey', 'Grey', 'f', NULL),
    ('english-royal', 'edward-grey', 'Edward Grey', 'Grey', 'm', NULL),
    ('english-royal', 'john-grey', 'John Grey', 'Grey', 'm', NULL),
    ('english-royal', 'thomas-grey', 'Thomas Grey', 'Grey', 'm', NULL),
    ('english-royal', 'thomas-grey-2', 'Thomas Grey', 'Grey', 'm', '1477-06-22'),
    ('english-royal', 'henry-grey', 'Henry Grey', 'Grey', 'm', '1517-01-17'),
    ('english-royal', 'jane-grey', 'Jane Grey', 'Grey', 'f', '1537-10-00'),
    ('english-royal', 'henry-grey-2', 'Henry Grey', 'Grey', 'm', NULL),
    ('english-royal', 'catherine-grey', 'Catherine Grey', 'Grey', 'f', '1540-08-00'),
    ('english-royal', 'mary-grey', 'Mary Grey', 'Grey', 'f', NULL);
-- Douglas (8)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('english-royal', 'archibald-douglas', 'Archibald Douglas', 'Douglas', 'm', '1490-00-00'),
    ('english-royal', 'george-douglas', 'George Douglas', 'Douglas', 'm', NULL),
    ('english-royal', 'janet-douglas', 'Janet Douglas', 'Douglas', 'f', NULL),
    ('english-royal', 'james-douglas', 'James Douglas', 'Douglas', 'm', NULL),
    ('english-royal', 'janet-douglas-2', 'Janet Douglas', 'Douglas', 'f', NULL),
    ('english-royal', 'william-douglas', 'William Douglas', 'Douglas', 'm', NULL),
    ('english-royal', 'margaret-douglas', 'Margaret Douglas', 'Douglas', 'f', '1515-10-00'),
    ('english-royal', 'james-douglas-2', 'James Douglas', 'Douglas', 'm', NULL);
-- Stafford (6)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('english-royal', 'henry-stafford', 'Henry Stafford', 'Stafford', 'm', NULL),
    ('english-royal', 'humphrey-stafford', 'Humphrey Stafford', 'Stafford', 'm', NULL),
    ('english-royal', 'elizabeth-stafford', 'Elizabeth Stafford', 'Stafford', 'f', '1497-00-00'),
    ('english-royal', 'edward-stafford', 'Edward Stafford', 'Stafford', 'm', NULL),
    ('english-royal', 'henry-stafford-2', 'Henry Stafford', 'Stafford', 'm', NULL),
    ('english-royal', 'william-stafford', 'William Stafford', 'Stafford', 'm', NULL);
-- Seymour (6)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('english-royal', 'jane-seymour', 'Jane Seymour', 'Seymour', 'f', NULL),
    ('english-royal', 'john-seymour', 'John Seymour', 'Seymour', 'm', NULL),
    ('english-royal', 'edward-seymour', 'Edward Seymour', 'Seymour', 'm', '1537-10-12'),
    ('english-royal', 'edward-seymour-2', 'Edward Seymour', 'Seymour', 'm', '1500-00-00'),
    ('english-royal', 'thomas-seymour', 'Thomas Seymour', 'Seymour', 'm', '1508-00-00'),
    ('english-royal', 'william-seymour', 'William Seymour', 'Seymour', 'm', NULL);
-- Neville (6)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('english-royal', 'margaret-neville', 'Margaret Neville', 'Neville', 'f', '1466-00-00'),
    ('english-royal', 'john-neville', 'John Neville', 'Neville', 'm', NULL),
    ('english-royal', 'catherine-neville', 'Catherine Neville', 'Neville', 'f', NULL),
    ('english-royal', 'eleanor-neville', 'Eleanor Neville', 'Neville', 'f', NULL),
    ('english-royal', 'richard-neville', 'Richard Neville', 'Neville', 'm', NULL),
    ('english-royal', 'john-neville-2', 'John Neville', 'Neville', 'm', NULL);
-- Valois (6)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('english-royal', 'louis-xii', 'Louis XII', 'Valois', 'm', NULL),
    ('english-royal', 'henry-ii', 'Henry II', 'Valois', 'm', NULL),
    ('english-royal', 'henry-of-valois', 'Henry of Valois', 'Valois', 'm', NULL),
    ('english-royal', 'madeleine-of-valois', 'Madeleine of Valois', 'Valois', 'f', '1520-08-00'),
    ('english-royal', 'francis-i', 'Francis I', 'Valois', 'm', NULL),
    ('english-royal', 'francis-ii', 'Francis II', 'Valois', 'm', NULL);
-- Stuart (6)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('english-royal', 'ludovic-stuart', 'Ludovic Stuart', 'Stuart', 'm', NULL),
    ('english-royal', 'matthew-stuart', 'Matthew Stuart', 'Stuart', 'm', NULL),
    ('english-royal', 'henry-stuart', 'Henry Stuart', 'Stuart', 'm', NULL),
    ('english-royal', 'charles-stuart', 'Charles Stuart', 'Stuart', 'm', NULL),
    ('english-royal', 'arabella-stuart', 'Arabella Stuart', 'Stuart', 'f', NULL),
    ('english-royal', 'james-stuart', 'James Stuart', 'Stuart', 'm', '1566-06-19');
-- Stanley (5)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('english-royal', 'thomas-stanley', 'Thomas Stanley', 'Stanley', 'm', '1435-00-00'),
    ('english-royal', 'george-stanley', 'George Stanley', 'Stanley', 'm', '1460-00-00'),
    ('english-royal', 'thomas-stanley-2', 'Thomas Stanley', 'Stanley', 'm', '1485-00-00'),
    ('english-royal', 'edward-stanley', 'Edward Stanley', 'Stanley', 'm', '1509-05-10'),
    ('english-royal', 'henry-stanley', 'Henry Stanley', 'Stanley', 'm', '1531-09-00');
-- Other families (160)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('english-royal', 'margaret-beaufort', 'Margaret Beaufort', 'Other families', 'f', '1443-05-31'),
    ('english-royal', 'john-de-la-pole', 'John de la Pole', 'Other families', 'm', NULL),
    ('english-royal', 'john-beaufort', 'John Beaufort', 'Other families', 'm', NULL),
    ('english-royal', 'margaret-beauchamp', 'Margaret Beauchamp', 'Other families', 'f', NULL),
    ('english-royal', 'oliver-st-john', 'Oliver St John', 'Other families', 'm', NULL),
    ('english-royal', 'john-beauchamp', 'John Beauchamp', 'Other families', 'm', NULL),
    ('english-royal', 'catherine-of-aragon', 'Catherine of Aragon', 'Other families', 'f', '1485-12-05'),
    ('english-royal', 'anne-boleyn', 'Anne Boleyn', 'Other families', 'f', NULL),
    ('english-royal', 'anne-of-cleves', 'Anne of Cleves', 'Other families', 'f', '1515-09-22'),
    ('english-royal', 'catherine-parr', 'Catherine Parr', 'Other families', 'f', NULL),
    ('english-royal', 'elizabeth-blount', 'Elizabeth Blount', 'Other families', 'f', NULL),
    ('english-royal', 'henry-fitzroy', 'Henry Fitzroy', 'Other families', 'm', '1519-00-00'),
    ('english-royal', 'ferdinand-v', 'Ferdinand V', 'Other families', 'm', NULL),
    ('english-royal', 'isabella-of-castile', 'Isabella of Castile', 'Other families', 'f', NULL),
    ('english-royal', 'john-ii', 'John II', 'Other families', 'm', NULL),
    ('english-royal', 'thomas-boleyn', 'Thomas Boleyn', 'Other families', 'm', NULL),
    ('english-royal', 'charles-brandon', 'Charles Brandon', 'Other families', 'm', '1484-00-00'),
    ('english-royal', 'william-brandon', 'William Brandon', 'Other families', 'm', NULL),
    ('english-royal', 'elizabeth-bruyn', 'Elizabeth Bruyn', 'Other families', 'f', NULL),
    ('english-royal', 'henry-bruyn', 'Henry Bruyn', 'Other families', 'm', NULL),
    ('english-royal', 'anne-browne', 'Anne Browne', 'Other families', 'f', NULL),
    ('english-royal', 'isabella-ingaldesthorpe', 'Isabella Ingaldesthorpe', 'Other families', 'f', NULL),
    ('english-royal', 'edmund-ingaldesthorpe', 'Edmund Ingaldesthorpe', 'Other families', 'm', NULL),
    ('english-royal', 'john-mortimer', 'John Mortimer', 'Other families', 'm', NULL),
    ('english-royal', 'anthony-browne', 'Anthony Browne', 'Other families', 'm', NULL),
    ('english-royal', 'catherine-willoughby', 'Catherine Willoughby', 'Other families', 'f', '1520-03-22'),
    ('english-royal', 'william-willoughby', 'William Willoughby', 'Other families', 'm', NULL),
    ('english-royal', 'mary-de-salinas', 'Mary de Salinas', 'Other families', 'f', NULL),
    ('english-royal', 'richard-bertie', 'Richard Bertie', 'Other families', 'm', NULL),
    ('english-royal', 'elizabeth-drummond', 'Elizabeth Drummond', 'Other families', 'f', NULL),
    ('english-royal', 'john-drummond', 'John Drummond', 'Other families', 'm', NULL),
    ('english-royal', 'david-fleming', 'David Fleming', 'Other families', 'm', NULL),
    ('english-royal', 'margaret-hepburn', 'Margaret Hepburn', 'Other families', 'f', NULL),
    ('english-royal', 'patrick-hepburn', 'Patrick Hepburn', 'Other families', 'm', NULL),
    ('english-royal', 'margaret-maxwell', 'Margaret Maxwell', 'Other families', 'f', NULL),
    ('english-royal', 'robert-maxwell', 'Robert Maxwell', 'Other families', 'm', NULL),
    ('english-royal', 'william-baillie', 'William Baillie', 'Other families', 'm', NULL),
    ('english-royal', 'margaret-kennedy', 'Margaret Kennedy', 'Other families', 'f', NULL),
    ('english-royal', 'john-kennedy', 'John Kennedy', 'Other families', 'm', NULL),
    ('english-royal', 'unnamed-daughter-leslie', '(unnamed daughter) Leslie', 'Other families', 'f', NULL),
    ('english-royal', 'hugh-kennedy', 'Hugh Kennedy', 'Other families', 'm', NULL),
    ('english-royal', 'alexander-gordon', 'Alexander Gordon', 'Other families', 'm', NULL),
    ('english-royal', 'janet-campbell', 'Janet Campbell', 'Other families', 'f', NULL),
    ('english-royal', 'archibald-campbell', 'Archibald Campbell', 'Other families', 'm', NULL),
    ('english-royal', 'patrick-ruthven', 'Patrick Ruthven', 'Other families', 'm', NULL),
    ('english-royal', 'james-gray', 'James Gray', 'Other families', 'm', NULL),
    ('english-royal', 'elizabeth-wydvill', 'Elizabeth Wydvill', 'Other families', 'f', NULL),
    ('english-royal', 'elizabeth-talbot', 'Elizabeth Talbot', 'Other families', 'f', NULL),
    ('english-royal', 'edmund-dudley', 'Edmund Dudley', 'Other families', 'm', '1470-00-00'),
    ('english-royal', 'honor-grenville', 'Honor Grenville', 'Other families', 'f', NULL),
    ('english-royal', 'john-basset', 'John Basset', 'Other families', 'm', NULL),
    ('english-royal', 'thomas-grenville', 'Thomas Grenville', 'Other families', 'm', NULL),
    ('english-royal', 'isabella-gilbert', 'Isabella Gilbert', 'Other families', 'f', NULL),
    ('english-royal', 'otes-gilbert', 'Otes Gilbert', 'Other families', 'm', NULL),
    ('english-royal', 'john-welles', 'John Welles', 'Other families', 'm', NULL),
    ('english-royal', 'richard-wydvill', 'Richard Wydvill', 'Other families', 'm', NULL),
    ('english-royal', 'elizabeth-welles', 'Elizabeth Welles', 'Other families', 'f', NULL),
    ('english-royal', 'anne-welles', 'Anne Welles', 'Other families', 'f', NULL),
    ('english-royal', 'thomas-kyme', 'Thomas Kyme', 'Other families', 'm', NULL),
    ('english-royal', 'anne-mowbray', 'Anne Mowbray', 'Other families', 'f', '1472-12-10'),
    ('english-royal', 'john-mowbray', 'John Mowbray', 'Other families', 'm', NULL),
    ('english-royal', 'elizabeth-talbot-2', 'Elizabeth Talbot', 'Other families', 'f', NULL),
    ('english-royal', 'john-talbot', 'John Talbot', 'Other families', 'm', NULL),
    ('english-royal', 'elizabeth-tylney', 'Elizabeth Tylney', 'Other families', 'f', NULL),
    ('english-royal', 'humphrey-bourchier', 'Humphrey Bourchier', 'Other families', 'm', NULL),
    ('english-royal', 'john-bourchier', 'John Bourchier', 'Other families', 'm', NULL),
    ('english-royal', 'frederick-tylney', 'Frederick Tylney', 'Other families', 'm', NULL),
    ('english-royal', 'elizabeth-cheney', 'Elizabeth Cheney', 'Other families', 'f', NULL),
    ('english-royal', 'lawrence-cheney', 'Lawrence Cheney', 'Other families', 'm', NULL),
    ('english-royal', 'elizabeth-cokayne', 'Elizabeth Cokayne', 'Other families', 'f', NULL),
    ('english-royal', 'john-cokayne', 'John Cokayne', 'Other families', 'm', NULL),
    ('english-royal', 'agnes-tylney', 'Agnes Tylney', 'Other families', 'f', NULL),
    ('english-royal', 'hugh-tylney', 'Hugh Tylney', 'Other families', 'm', NULL),
    ('english-royal', 'philip-tylney', 'Philip Tylney', 'Other families', 'm', NULL),
    ('english-royal', 'unnamed-daughter-tailboys', '(unnamed daughter) Tailboys', 'Other families', 'f', NULL),
    ('english-royal', 'walter-tailboys', 'Walter Tailboys', 'Other families', 'm', NULL),
    ('english-royal', 'ralph-scrope', 'Ralph Scrope', 'Other families', 'm', NULL),
    ('english-royal', 'eleanor-percy', 'Eleanor Percy', 'Other families', 'f', NULL),
    ('english-royal', 'henry-percy', 'Henry Percy', 'Other families', 'm', NULL),
    ('english-royal', 'richard-wydvill-2', 'Richard Wydvill', 'Other families', 'm', NULL),
    ('english-royal', 'jacqueline-de-luxembourg', 'Jacqueline de Luxembourg', 'Other families', 'f', NULL),
    ('english-royal', 'peter-de-luxembourg', 'Peter de Luxembourg', 'Other families', 'm', NULL),
    ('english-royal', 'anne-holand', 'Anne Holand', 'Other families', 'f', NULL),
    ('english-royal', 'henry-holand', 'Henry Holand', 'Other families', 'm', NULL),
    ('english-royal', 'cecily-bonville', 'Cecily Bonville', 'Other families', 'f', NULL),
    ('english-royal', 'william-bonville', 'William Bonville', 'Other families', 'm', NULL),
    ('english-royal', 'henry-brandon', 'Henry Brandon', 'Other families', 'm', '1516-03-11'),
    ('english-royal', 'frances-brandon', 'Frances Brandon', 'Other families', 'f', '1517-07-16'),
    ('english-royal', 'adrian-stokes', 'Adrian Stokes', 'Other families', 'm', NULL),
    ('english-royal', 'margaret-wotton', 'Margaret Wotton', 'Other families', 'f', NULL),
    ('english-royal', 'william-medley', 'William Medley', 'Other families', 'm', NULL),
    ('english-royal', 'robert-wotton', 'Robert Wotton', 'Other families', 'm', NULL),
    ('english-royal', 'anne-belknap', 'Anne Belknap', 'Other families', 'f', NULL),
    ('english-royal', 'henry-belknap', 'Henry Belknap', 'Other families', 'm', NULL),
    ('english-royal', 'catherine-fitzalan', 'Catherine FitzAlan', 'Other families', 'f', NULL),
    ('english-royal', 'william-fitzalan', 'William FitzAlan', 'Other families', 'm', NULL),
    ('english-royal', 'anne-percy', 'Anne Percy', 'Other families', 'f', NULL),
    ('english-royal', 'eleanor-brandon', 'Eleanor Brandon', 'Other families', 'f', NULL),
    ('english-royal', 'henry-clifford', 'Henry Clifford', 'Other families', 'm', NULL),
    ('english-royal', 'margaret-clifford', 'Margaret Clifford', 'Other families', 'f', NULL),
    ('english-royal', 'anne-dacre', 'Anne Dacre', 'Other families', 'f', NULL),
    ('english-royal', 'william-dacre', 'William Dacre', 'Other families', 'm', NULL),
    ('english-royal', 'elizabeth-talbot-3', 'Elizabeth Talbot', 'Other families', 'f', NULL),
    ('english-royal', 'george-talbot', 'George Talbot', 'Other families', 'm', NULL),
    ('english-royal', 'alice-montagu', 'Alice Montagu', 'Other families', 'f', NULL),
    ('english-royal', 'thomas-montagu', 'Thomas Montagu', 'Other families', 'm', NULL),
    ('english-royal', 'joan-le-strange', 'Joan le Strange', 'Other families', 'f', NULL),
    ('english-royal', 'john-le-strange', 'John le Strange', 'Other families', 'm', NULL),
    ('english-royal', 'jacquette-wydvill', 'Jacquette Wydvill', 'Other families', 'f', NULL),
    ('english-royal', 'anne-hastings', 'Anne Hastings', 'Other families', 'f', NULL),
    ('english-royal', 'edward-hastings', 'Edward Hastings', 'Other families', 'm', NULL),
    ('english-royal', 'mary-hungerford', 'Mary Hungerford', 'Other families', 'f', NULL),
    ('english-royal', 'thomas-hungerford', 'Thomas Hungerford', 'Other families', 'm', NULL),
    ('english-royal', 'margaret-barlow', 'Margaret Barlow', 'Other families', 'f', NULL),
    ('english-royal', 'ellis-barlow', 'Ellis Barlow', 'Other families', 'm', NULL),
    ('english-royal', 'anne-reddish', 'Anne Reddish', 'Other families', 'f', NULL),
    ('english-royal', 'otes-reddish', 'Otes Reddish', 'Other families', 'm', NULL),
    ('english-royal', 'mary-cotton', 'Mary Cotton', 'Other families', 'f', NULL),
    ('english-royal', 'george-cotton', 'George Cotton', 'Other families', 'm', NULL),
    ('english-royal', 'mary-onley', 'Mary Onley', 'Other families', 'f', NULL),
    ('english-royal', 'john-onley', 'John Onley', 'Other families', 'm', NULL),
    ('english-royal', 'thomas-keyes', 'Thomas Keyes', 'Other families', 'm', NULL),
    ('english-royal', 'anne-stanhope', 'Anne Stanhope', 'Other families', 'f', NULL),
    ('english-royal', 'henry-herbert', 'Henry Herbert', 'Other families', 'm', NULL),
    ('english-royal', 'margaret-gamage', 'Margaret Gamage', 'Other families', 'f', NULL),
    ('english-royal', 'thomas-gamage', 'Thomas Gamage', 'Other families', 'm', NULL),
    ('english-royal', 'henry-pranell', 'Henry Pranell', 'Other families', 'm', NULL),
    ('english-royal', 'mabel-burton', 'Mabel Burton', 'Other families', 'f', NULL),
    ('english-royal', 'nicholas-burton', 'Nicholas Burton', 'Other families', 'm', NULL),
    ('english-royal', 'margery-wentworth', 'Margery Wentworth', 'Other families', 'f', NULL),
    ('english-royal', 'henry-wentworth', 'Henry Wentworth', 'Other families', 'm', NULL),
    ('english-royal', 'thomas-parr', 'Thomas Parr', 'Other families', 'm', NULL),
    ('english-royal', 'maud-green', 'Maud Green', 'Other families', 'f', NULL),
    ('english-royal', 'thomas-green', 'Thomas Green', 'Other families', 'm', NULL),
    ('english-royal', 'edward-burgh', 'Edward Burgh', 'Other families', 'm', NULL),
    ('english-royal', 'gilbert-gray', 'Gilbert Gray', 'Other families', 'm', NULL),
    ('english-royal', 'elizabeth-cavendish', 'Elizabeth Cavendish', 'Other families', 'f', NULL),
    ('english-royal', 'william-cavendish', 'William Cavendish', 'Other families', 'm', NULL),
    ('english-royal', 'margaret-boyd', 'Margaret Boyd', 'Other families', 'f', NULL),
    ('english-royal', 'janet-kennedy', 'Janet Kennedy', 'Other families', 'f', NULL),
    ('english-royal', 'elizabeth-campbell', 'Elizabeth Campbell', 'Other families', 'f', NULL),
    ('english-royal', 'colin-campbell', 'Colin Campbell', 'Other families', 'm', NULL),
    ('english-royal', 'margaret-drummond', 'Margaret Drummond', 'Other families', 'f', NULL),
    ('english-royal', 'john-gordon', 'John Gordon', 'Other families', 'm', NULL),
    ('english-royal', 'john-drummond-2', 'John Drummond', 'Other families', 'm', NULL),
    ('english-royal', 'malcolm-fleming', 'Malcolm Fleming', 'Other families', 'm', NULL),
    ('english-royal', 'mary-of-lorraine', 'Mary of Lorraine', 'Other families', 'f', NULL),
    ('english-royal', 'louis-of-orleans', 'Louis of Orleans', 'Other families', 'm', NULL),
    ('english-royal', 'catherine-de-medicis', 'Catherine de Medicis', 'Other families', 'f', NULL),
    ('english-royal', 'james-hepburn', 'James Hepburn', 'Other families', 'm', NULL),
    ('english-royal', 'anne-of-oldenburg', 'Anne of Oldenburg', 'Other families', 'f', NULL),
    ('english-royal', 'mary-boleyn', 'Mary Boleyn', 'Other families', 'f', NULL),
    ('english-royal', 'william-carey', 'William Carey', 'Other families', 'm', NULL),
    ('english-royal', 'henry-carey', 'Henry Carey', 'Other families', 'm', '1526-03-04'),
    ('english-royal', 'catherine-carey', 'Catherine Carey', 'Other families', 'f', '1524-00-00'),
    ('english-royal', 'francis-knollys', 'Francis Knollys', 'Other families', 'm', NULL),
    ('english-royal', 'anne-morgan', 'Anne Morgan', 'Other families', 'f', NULL),
    ('english-royal', 'philip-ii', 'Philip II', 'Other families', 'm', NULL),
    ('english-royal', 'guilford-dudley', 'Guilford Dudley', 'Other families', 'm', NULL),
    ('english-royal', 'margaret-kyme', 'Margaret Kyme', 'Other families', 'f', NULL);

-- ── Families (175, each followed by its members) ───────────────────────────────────────────────
-- english-royal-f1: Henry VII + Elizabeth Plantagenet → Arthur Tudor, Margaret Tudor, Henry VIII, Mary Tudor, Edmund Tudor
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f1', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f1', 'henry-vii', 'parent'),
    ('english-royal', 'english-royal-f1', 'elizabeth-plantagenet', 'parent'),
    ('english-royal', 'english-royal-f1', 'arthur-tudor', 'child'),
    ('english-royal', 'english-royal-f1', 'margaret-tudor', 'child'),
    ('english-royal', 'english-royal-f1', 'henry-viii', 'child'),
    ('english-royal', 'english-royal-f1', 'mary-tudor', 'child'),
    ('english-royal', 'english-royal-f1', 'edmund-tudor-2', 'child');
-- english-royal-f2: Edmund Tudor + Margaret Beaufort → Henry VII
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f2', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f2', 'edmund-tudor', 'parent'),
    ('english-royal', 'english-royal-f2', 'margaret-beaufort', 'parent'),
    ('english-royal', 'english-royal-f2', 'henry-vii', 'child');
-- english-royal-f3: Edward IV + Elizabeth Wydvill → Elizabeth Plantagenet, Cecily Plantagenet, Edward V, Richard Plantagenet, Anne Plantagenet, George Plantagenet
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f3', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f3', 'edward-iv', 'parent'),
    ('english-royal', 'english-royal-f3', 'elizabeth-wydvill', 'parent'),
    ('english-royal', 'english-royal-f3', 'elizabeth-plantagenet', 'child'),
    ('english-royal', 'english-royal-f3', 'cecily-plantagenet', 'child'),
    ('english-royal', 'english-royal-f3', 'edward-v', 'child'),
    ('english-royal', 'english-royal-f3', 'richard-plantagenet', 'child'),
    ('english-royal', 'english-royal-f3', 'anne-plantagenet', 'child'),
    ('english-royal', 'english-royal-f3', 'george-plantagenet', 'child');
-- english-royal-f4: John de la Pole + Margaret Beaufort (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f4', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f4', 'john-de-la-pole', 'parent'),
    ('english-royal', 'english-royal-f4', 'margaret-beaufort', 'parent');
-- english-royal-f5: Henry Stafford + Margaret Beaufort (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f5', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f5', 'henry-stafford', 'parent'),
    ('english-royal', 'english-royal-f5', 'margaret-beaufort', 'parent');
-- english-royal-f6: Thomas Stanley + Margaret Beaufort (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f6', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f6', 'thomas-stanley', 'parent'),
    ('english-royal', 'english-royal-f6', 'margaret-beaufort', 'parent');
-- english-royal-f7: John Beaufort + Margaret Beauchamp → Margaret Beaufort
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f7', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f7', 'john-beaufort', 'parent'),
    ('english-royal', 'english-royal-f7', 'margaret-beauchamp', 'parent'),
    ('english-royal', 'english-royal-f7', 'margaret-beaufort', 'child');
-- english-royal-f8: Oliver St John + Margaret Beauchamp (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f8', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f8', 'oliver-st-john', 'parent'),
    ('english-royal', 'english-royal-f8', 'margaret-beauchamp', 'parent');
-- english-royal-f9: John Beauchamp → Margaret Beauchamp
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f9', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f9', 'john-beauchamp', 'parent'),
    ('english-royal', 'english-royal-f9', 'margaret-beauchamp', 'child');
-- english-royal-f10: Humphrey Stafford → Henry Stafford
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f10', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f10', 'humphrey-stafford', 'parent'),
    ('english-royal', 'english-royal-f10', 'henry-stafford', 'child');
-- english-royal-f11: Thomas Stanley + Eleanor Neville → George Stanley
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f11', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f11', 'thomas-stanley', 'parent'),
    ('english-royal', 'english-royal-f11', 'eleanor-neville', 'parent'),
    ('english-royal', 'english-royal-f11', 'george-stanley', 'child');
-- english-royal-f12: Henry VIII + Catherine of Aragon → Henry Tudor, (unnamed son) Tudor, Mary I
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f12', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f12', 'henry-viii', 'parent'),
    ('english-royal', 'english-royal-f12', 'catherine-of-aragon', 'parent'),
    ('english-royal', 'english-royal-f12', 'henry-tudor', 'child'),
    ('english-royal', 'english-royal-f12', 'unnamed-son-tudor', 'child'),
    ('english-royal', 'english-royal-f12', 'mary-i', 'child');
-- english-royal-f13: Henry VIII + Anne Boleyn → Elizabeth I
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f13', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f13', 'henry-viii', 'parent'),
    ('english-royal', 'english-royal-f13', 'anne-boleyn', 'parent'),
    ('english-royal', 'english-royal-f13', 'elizabeth-i', 'child');
-- english-royal-f14: Henry VIII + Jane Seymour → Edward VI
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f14', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f14', 'henry-viii', 'parent'),
    ('english-royal', 'english-royal-f14', 'jane-seymour', 'parent'),
    ('english-royal', 'english-royal-f14', 'edward-vi', 'child');
-- english-royal-f15: Henry VIII + Anne of Cleves (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f15', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f15', 'henry-viii', 'parent'),
    ('english-royal', 'english-royal-f15', 'anne-of-cleves', 'parent');
-- english-royal-f16: Henry VIII + Catherine Howard (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f16', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f16', 'henry-viii', 'parent'),
    ('english-royal', 'english-royal-f16', 'catherine-howard', 'parent');
-- english-royal-f17: Henry VIII + Catherine Parr (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f17', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f17', 'henry-viii', 'parent'),
    ('english-royal', 'english-royal-f17', 'catherine-parr', 'parent');
-- english-royal-f18: Henry VIII + Elizabeth Blount → Henry Fitzroy
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f18', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f18', 'henry-viii', 'parent'),
    ('english-royal', 'english-royal-f18', 'elizabeth-blount', 'parent'),
    ('english-royal', 'english-royal-f18', 'henry-fitzroy', 'child');
-- english-royal-f19: Arthur Tudor + Catherine of Aragon (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f19', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f19', 'arthur-tudor', 'parent'),
    ('english-royal', 'english-royal-f19', 'catherine-of-aragon', 'parent');
-- english-royal-f20: Ferdinand V + Isabella of Castile → Catherine of Aragon
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f20', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f20', 'ferdinand-v', 'parent'),
    ('english-royal', 'english-royal-f20', 'isabella-of-castile', 'parent'),
    ('english-royal', 'english-royal-f20', 'catherine-of-aragon', 'child');
-- english-royal-f21: Thomas Boleyn + Elizabeth Howard → Anne Boleyn, Mary Boleyn
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f21', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f21', 'thomas-boleyn', 'parent'),
    ('english-royal', 'english-royal-f21', 'elizabeth-howard', 'parent'),
    ('english-royal', 'english-royal-f21', 'anne-boleyn', 'child'),
    ('english-royal', 'english-royal-f21', 'mary-boleyn', 'child');
-- english-royal-f22: John Seymour + Margery Wentworth → Jane Seymour, Edward Seymour, Thomas Seymour
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f22', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f22', 'john-seymour', 'parent'),
    ('english-royal', 'english-royal-f22', 'margery-wentworth', 'parent'),
    ('english-royal', 'english-royal-f22', 'jane-seymour', 'child'),
    ('english-royal', 'english-royal-f22', 'edward-seymour-2', 'child'),
    ('english-royal', 'english-royal-f22', 'thomas-seymour', 'child');
-- english-royal-f23: Edmund Howard → Catherine Howard
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f23', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f23', 'edmund-howard', 'parent'),
    ('english-royal', 'english-royal-f23', 'catherine-howard', 'child');
-- english-royal-f24: Edward Burgh + Catherine Parr (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f24', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f24', 'edward-burgh', 'parent'),
    ('english-royal', 'english-royal-f24', 'catherine-parr', 'parent');
-- english-royal-f25: John Neville + Catherine Parr (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f25', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f25', 'john-neville-2', 'parent'),
    ('english-royal', 'english-royal-f25', 'catherine-parr', 'parent');
-- english-royal-f26: Thomas Seymour + Catherine Parr (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f26', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f26', 'thomas-seymour', 'parent'),
    ('english-royal', 'english-royal-f26', 'catherine-parr', 'parent');
-- english-royal-f27: Thomas Parr + Maud Green → Catherine Parr
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f27', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f27', 'thomas-parr', 'parent'),
    ('english-royal', 'english-royal-f27', 'maud-green', 'parent'),
    ('english-royal', 'english-royal-f27', 'catherine-parr', 'child');
-- english-royal-f28: Henry Fitzroy + Mary Howard (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f28', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f28', 'henry-fitzroy', 'parent'),
    ('english-royal', 'english-royal-f28', 'mary-howard', 'parent');
-- english-royal-f29: Thomas Howard + Elizabeth Stafford → Mary Howard, Thomas Howard
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f29', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f29', 'thomas-howard', 'parent'),
    ('english-royal', 'english-royal-f29', 'elizabeth-stafford', 'parent'),
    ('english-royal', 'english-royal-f29', 'mary-howard', 'child'),
    ('english-royal', 'english-royal-f29', 'thomas-howard-3', 'child');
-- english-royal-f30: Thomas Howard + Anne Plantagenet → (unnamed son) Howard
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f30', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f30', 'thomas-howard', 'parent'),
    ('english-royal', 'english-royal-f30', 'anne-plantagenet', 'parent'),
    ('english-royal', 'english-royal-f30', 'unnamed-son-howard', 'child');
-- english-royal-f31: Thomas Howard + Elizabeth Tylney → Elizabeth Howard, Thomas Howard, Edmund Howard
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f31', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f31', 'thomas-howard-2', 'parent'),
    ('english-royal', 'english-royal-f31', 'elizabeth-tylney', 'parent'),
    ('english-royal', 'english-royal-f31', 'elizabeth-howard', 'child'),
    ('english-royal', 'english-royal-f31', 'thomas-howard', 'child'),
    ('english-royal', 'english-royal-f31', 'edmund-howard', 'child');
-- english-royal-f32: Edward Stafford + Eleanor Percy → Elizabeth Stafford
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f32', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f32', 'edward-stafford', 'parent'),
    ('english-royal', 'english-royal-f32', 'eleanor-percy', 'parent'),
    ('english-royal', 'english-royal-f32', 'elizabeth-stafford', 'child');
-- english-royal-f33: John II → Isabella of Castile
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f33', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f33', 'john-ii', 'parent'),
    ('english-royal', 'english-royal-f33', 'isabella-of-castile', 'child');
-- english-royal-f34: Thomas Howard + Agnes Tylney → Dorothy Howard, William Howard
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f34', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f34', 'thomas-howard-2', 'parent'),
    ('english-royal', 'english-royal-f34', 'agnes-tylney', 'parent'),
    ('english-royal', 'english-royal-f34', 'dorothy-howard', 'child'),
    ('english-royal', 'english-royal-f34', 'william-howard', 'child');
-- english-royal-f35: Louis XII + Mary Tudor (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f35', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f35', 'louis-xii', 'parent'),
    ('english-royal', 'english-royal-f35', 'mary-tudor', 'parent');
-- english-royal-f36: Charles Brandon + Mary Tudor → Henry Brandon, Frances Brandon, Eleanor Brandon
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f36', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f36', 'charles-brandon', 'parent'),
    ('english-royal', 'english-royal-f36', 'mary-tudor', 'parent'),
    ('english-royal', 'english-royal-f36', 'henry-brandon', 'child'),
    ('english-royal', 'english-royal-f36', 'frances-brandon', 'child'),
    ('english-royal', 'english-royal-f36', 'eleanor-brandon', 'child');
-- english-royal-f37: Charles Brandon + Anne Browne (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f37', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f37', 'charles-brandon', 'parent'),
    ('english-royal', 'english-royal-f37', 'anne-browne', 'parent');
-- english-royal-f38: Charles Brandon + Margaret Neville (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f38', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f38', 'charles-brandon', 'parent'),
    ('english-royal', 'english-royal-f38', 'margaret-neville', 'parent');
-- english-royal-f39: Charles Brandon + Catherine Willoughby (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f39', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f39', 'charles-brandon', 'parent'),
    ('english-royal', 'english-royal-f39', 'catherine-willoughby', 'parent');
-- english-royal-f40: William Brandon + Elizabeth Bruyn → Charles Brandon
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f40', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f40', 'william-brandon', 'parent'),
    ('english-royal', 'english-royal-f40', 'elizabeth-bruyn', 'parent'),
    ('english-royal', 'english-royal-f40', 'charles-brandon', 'child');
-- english-royal-f41: Henry Bruyn → Elizabeth Bruyn
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f41', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f41', 'henry-bruyn', 'parent'),
    ('english-royal', 'english-royal-f41', 'elizabeth-bruyn', 'child');
-- english-royal-f42: Anthony Browne → Anne Browne
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f42', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f42', 'anthony-browne', 'parent'),
    ('english-royal', 'english-royal-f42', 'anne-browne', 'child');
-- english-royal-f43: John Mortimer + Margaret Neville (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f43', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f43', 'john-mortimer', 'parent'),
    ('english-royal', 'english-royal-f43', 'margaret-neville', 'parent');
-- english-royal-f44: John Neville + Isabella Ingaldesthorpe → Margaret Neville
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f44', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f44', 'john-neville', 'parent'),
    ('english-royal', 'english-royal-f44', 'isabella-ingaldesthorpe', 'parent'),
    ('english-royal', 'english-royal-f44', 'margaret-neville', 'child');
-- english-royal-f45: Edmund Ingaldesthorpe → Isabella Ingaldesthorpe
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f45', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f45', 'edmund-ingaldesthorpe', 'parent'),
    ('english-royal', 'english-royal-f45', 'isabella-ingaldesthorpe', 'child');
-- english-royal-f46: Richard Bertie + Catherine Willoughby (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f46', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f46', 'richard-bertie', 'parent'),
    ('english-royal', 'english-royal-f46', 'catherine-willoughby', 'parent');
-- english-royal-f47: William Willoughby + Mary de Salinas → Catherine Willoughby
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f47', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f47', 'william-willoughby', 'parent'),
    ('english-royal', 'english-royal-f47', 'mary-de-salinas', 'parent'),
    ('english-royal', 'english-royal-f47', 'catherine-willoughby', 'child');
-- english-royal-f48: Archibald Douglas + Margaret Hepburn (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f48', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f48', 'archibald-douglas', 'parent'),
    ('english-royal', 'english-royal-f48', 'margaret-hepburn', 'parent');
-- english-royal-f49: Archibald Douglas + Margaret Tudor → Margaret Douglas
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f49', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f49', 'archibald-douglas', 'parent'),
    ('english-royal', 'english-royal-f49', 'margaret-tudor', 'parent'),
    ('english-royal', 'english-royal-f49', 'margaret-douglas', 'child');
-- english-royal-f50: Archibald Douglas + Margaret Maxwell (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f50', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f50', 'archibald-douglas', 'parent'),
    ('english-royal', 'english-royal-f50', 'margaret-maxwell', 'parent');
-- english-royal-f51: George Douglas + Elizabeth Drummond → Archibald Douglas
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f51', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f51', 'george-douglas', 'parent'),
    ('english-royal', 'english-royal-f51', 'elizabeth-drummond', 'parent'),
    ('english-royal', 'english-royal-f51', 'archibald-douglas', 'child');
-- english-royal-f52: David Fleming + Elizabeth Drummond (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f52', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f52', 'david-fleming', 'parent'),
    ('english-royal', 'english-royal-f52', 'elizabeth-drummond', 'parent');
-- english-royal-f53: John Drummond → Elizabeth Drummond
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f53', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f53', 'john-drummond', 'parent'),
    ('english-royal', 'english-royal-f53', 'elizabeth-drummond', 'child');
-- english-royal-f54: Patrick Hepburn + Janet Douglas → Margaret Hepburn
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f54', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f54', 'patrick-hepburn', 'parent'),
    ('english-royal', 'english-royal-f54', 'janet-douglas', 'parent'),
    ('english-royal', 'english-royal-f54', 'margaret-hepburn', 'child');
-- english-royal-f55: James Douglas → Janet Douglas
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f55', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f55', 'james-douglas', 'parent'),
    ('english-royal', 'english-royal-f55', 'janet-douglas', 'child');
-- english-royal-f56: Henry Stewart + Margaret Tudor (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f56', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f56', 'henry-stewart', 'parent'),
    ('english-royal', 'english-royal-f56', 'margaret-tudor', 'parent');
-- english-royal-f57: William Baillie + Margaret Maxwell (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f57', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f57', 'william-baillie', 'parent'),
    ('english-royal', 'english-royal-f57', 'margaret-maxwell', 'parent');
-- english-royal-f58: Robert Maxwell + Janet Douglas → Margaret Maxwell
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f58', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f58', 'robert-maxwell', 'parent'),
    ('english-royal', 'english-royal-f58', 'janet-douglas-2', 'parent'),
    ('english-royal', 'english-royal-f58', 'margaret-maxwell', 'child');
-- english-royal-f59: William Douglas → Janet Douglas
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f59', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f59', 'william-douglas', 'parent'),
    ('english-royal', 'english-royal-f59', 'janet-douglas-2', 'child');
-- english-royal-f60: Henry Stewart + (unnamed daughter) Leslie (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f60', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f60', 'henry-stewart', 'parent'),
    ('english-royal', 'english-royal-f60', 'unnamed-daughter-leslie', 'parent');
-- english-royal-f61: Henry Stewart + Janet Stewart (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f61', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f61', 'henry-stewart', 'parent'),
    ('english-royal', 'english-royal-f61', 'janet-stewart', 'parent');
-- english-royal-f62: Andrew Stewart + Margaret Kennedy → Henry Stewart
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f62', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f62', 'andrew-stewart', 'parent'),
    ('english-royal', 'english-royal-f62', 'margaret-kennedy', 'parent'),
    ('english-royal', 'english-royal-f62', 'henry-stewart', 'child');
-- english-royal-f63: John Kennedy → Margaret Kennedy, Janet Kennedy
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f63', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f63', 'john-kennedy', 'parent'),
    ('english-royal', 'english-royal-f63', 'margaret-kennedy', 'child'),
    ('english-royal', 'english-royal-f63', 'janet-kennedy', 'child');
-- english-royal-f64: Alexander Gordon + Janet Stewart (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f64', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f64', 'alexander-gordon', 'parent'),
    ('english-royal', 'english-royal-f64', 'janet-stewart', 'parent');
-- english-royal-f65: Hugh Kennedy + Janet Stewart (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f65', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f65', 'hugh-kennedy', 'parent'),
    ('english-royal', 'english-royal-f65', 'janet-stewart', 'parent');
-- english-royal-f66: Patrick Ruthven + Janet Stewart (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f66', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f66', 'patrick-ruthven', 'parent'),
    ('english-royal', 'english-royal-f66', 'janet-stewart', 'parent');
-- english-royal-f67: James Gray + Janet Stewart (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f67', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f67', 'james-gray', 'parent'),
    ('english-royal', 'english-royal-f67', 'janet-stewart', 'parent');
-- english-royal-f68: John Stewart + Janet Campbell → Janet Stewart
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f68', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f68', 'john-stewart', 'parent'),
    ('english-royal', 'english-royal-f68', 'janet-campbell', 'parent'),
    ('english-royal', 'english-royal-f68', 'janet-stewart', 'child');
-- english-royal-f69: Archibald Campbell → Janet Campbell
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f69', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f69', 'archibald-campbell', 'parent'),
    ('english-royal', 'english-royal-f69', 'janet-campbell', 'child');
-- english-royal-f70: Edward IV → Arthur Plantagenet
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f70', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f70', 'edward-iv', 'parent'),
    ('english-royal', 'english-royal-f70', 'arthur-plantagenet', 'child');
-- english-royal-f71: John Grey + Elizabeth Wydvill → Thomas Grey
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f71', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f71', 'john-grey', 'parent'),
    ('english-royal', 'english-royal-f71', 'elizabeth-wydvill', 'parent'),
    ('english-royal', 'english-royal-f71', 'thomas-grey', 'child');
-- english-royal-f72: Richard Wydvill + Jacqueline de Luxembourg → Elizabeth Wydvill, Richard Wydvill, Jacquette Wydvill
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f72', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f72', 'richard-wydvill', 'parent'),
    ('english-royal', 'english-royal-f72', 'jacqueline-de-luxembourg', 'parent'),
    ('english-royal', 'english-royal-f72', 'elizabeth-wydvill', 'child'),
    ('english-royal', 'english-royal-f72', 'richard-wydvill-2', 'child'),
    ('english-royal', 'english-royal-f72', 'jacquette-wydvill', 'child');
-- english-royal-f73: Arthur Plantagenet + Elizabeth Grey (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f73', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f73', 'arthur-plantagenet', 'parent'),
    ('english-royal', 'english-royal-f73', 'elizabeth-grey', 'parent');
-- english-royal-f74: Arthur Plantagenet + Honor Grenville (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f74', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f74', 'arthur-plantagenet', 'parent'),
    ('english-royal', 'english-royal-f74', 'honor-grenville', 'parent');
-- english-royal-f75: Edmund Dudley + Elizabeth Grey (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f75', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f75', 'edmund-dudley', 'parent'),
    ('english-royal', 'english-royal-f75', 'elizabeth-grey', 'parent');
-- english-royal-f76: Edward Grey + Elizabeth Talbot → Elizabeth Grey
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f76', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f76', 'edward-grey', 'parent'),
    ('english-royal', 'english-royal-f76', 'elizabeth-talbot', 'parent'),
    ('english-royal', 'english-royal-f76', 'elizabeth-grey', 'child');
-- english-royal-f77: John Basset + Honor Grenville (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f77', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f77', 'john-basset', 'parent'),
    ('english-royal', 'english-royal-f77', 'honor-grenville', 'parent');
-- english-royal-f78: Thomas Grenville + Isabella Gilbert → Honor Grenville
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f78', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f78', 'thomas-grenville', 'parent'),
    ('english-royal', 'english-royal-f78', 'isabella-gilbert', 'parent'),
    ('english-royal', 'english-royal-f78', 'honor-grenville', 'child');
-- english-royal-f79: Otes Gilbert → Isabella Gilbert
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f79', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f79', 'otes-gilbert', 'parent'),
    ('english-royal', 'english-royal-f79', 'isabella-gilbert', 'child');
-- english-royal-f80: Ralph Scrope + Cecily Plantagenet (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f80', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f80', 'ralph-scrope', 'parent'),
    ('english-royal', 'english-royal-f80', 'cecily-plantagenet', 'parent');
-- english-royal-f81: John Welles + Cecily Plantagenet → Elizabeth Welles, Anne Welles
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f81', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f81', 'john-welles', 'parent'),
    ('english-royal', 'english-royal-f81', 'cecily-plantagenet', 'parent'),
    ('english-royal', 'english-royal-f81', 'elizabeth-welles', 'child'),
    ('english-royal', 'english-royal-f81', 'anne-welles', 'child');
-- english-royal-f82: Thomas Kyme + Cecily Plantagenet → Margaret Kyme
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f82', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f82', 'thomas-kyme', 'parent'),
    ('english-royal', 'english-royal-f82', 'cecily-plantagenet', 'parent'),
    ('english-royal', 'english-royal-f82', 'margaret-kyme', 'child');
-- english-royal-f83: Richard Plantagenet + Anne Mowbray (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f83', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f83', 'richard-plantagenet', 'parent'),
    ('english-royal', 'english-royal-f83', 'anne-mowbray', 'parent');
-- english-royal-f84: John Mowbray + Elizabeth Talbot → Anne Mowbray
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f84', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f84', 'john-mowbray', 'parent'),
    ('english-royal', 'english-royal-f84', 'elizabeth-talbot-2', 'parent'),
    ('english-royal', 'english-royal-f84', 'anne-mowbray', 'child');
-- english-royal-f85: John Talbot → Elizabeth Talbot
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f85', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f85', 'john-talbot', 'parent'),
    ('english-royal', 'english-royal-f85', 'elizabeth-talbot-2', 'child');
-- english-royal-f86: Humphrey Bourchier + Elizabeth Tylney → John Bourchier
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f86', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f86', 'humphrey-bourchier', 'parent'),
    ('english-royal', 'english-royal-f86', 'elizabeth-tylney', 'parent'),
    ('english-royal', 'english-royal-f86', 'john-bourchier', 'child');
-- english-royal-f87: Frederick Tylney + Elizabeth Cheney → Elizabeth Tylney
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f87', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f87', 'frederick-tylney', 'parent'),
    ('english-royal', 'english-royal-f87', 'elizabeth-cheney', 'parent'),
    ('english-royal', 'english-royal-f87', 'elizabeth-tylney', 'child');
-- english-royal-f88: Lawrence Cheney + Elizabeth Cokayne → Elizabeth Cheney
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f88', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f88', 'lawrence-cheney', 'parent'),
    ('english-royal', 'english-royal-f88', 'elizabeth-cokayne', 'parent'),
    ('english-royal', 'english-royal-f88', 'elizabeth-cheney', 'child');
-- english-royal-f89: John Cokayne → Elizabeth Cokayne
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f89', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f89', 'john-cokayne', 'parent'),
    ('english-royal', 'english-royal-f89', 'elizabeth-cokayne', 'child');
-- english-royal-f90: Hugh Tylney + (unnamed daughter) Tailboys → Agnes Tylney, Philip Tylney
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f90', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f90', 'hugh-tylney', 'parent'),
    ('english-royal', 'english-royal-f90', 'unnamed-daughter-tailboys', 'parent'),
    ('english-royal', 'english-royal-f90', 'agnes-tylney', 'child'),
    ('english-royal', 'english-royal-f90', 'philip-tylney', 'child');
-- english-royal-f91: Walter Tailboys → (unnamed daughter) Tailboys
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f91', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f91', 'walter-tailboys', 'parent'),
    ('english-royal', 'english-royal-f91', 'unnamed-daughter-tailboys', 'child');
-- english-royal-f92: Henry Percy → Eleanor Percy, Anne Percy
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f92', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f92', 'henry-percy', 'parent'),
    ('english-royal', 'english-royal-f92', 'eleanor-percy', 'child'),
    ('english-royal', 'english-royal-f92', 'anne-percy', 'child');
-- english-royal-f93: Peter de Luxembourg → Jacqueline de Luxembourg
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f93', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f93', 'peter-de-luxembourg', 'parent'),
    ('english-royal', 'english-royal-f93', 'jacqueline-de-luxembourg', 'child');
-- english-royal-f94: Thomas Grey + Anne Holand (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f94', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f94', 'thomas-grey', 'parent'),
    ('english-royal', 'english-royal-f94', 'anne-holand', 'parent');
-- english-royal-f95: Thomas Grey + Cecily Bonville → Thomas Grey
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f95', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f95', 'thomas-grey', 'parent'),
    ('english-royal', 'english-royal-f95', 'cecily-bonville', 'parent'),
    ('english-royal', 'english-royal-f95', 'thomas-grey-2', 'child');
-- english-royal-f96: Henry Holand + Anne Plantagenet → Anne Holand
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f96', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f96', 'henry-holand', 'parent'),
    ('english-royal', 'english-royal-f96', 'anne-plantagenet-2', 'parent'),
    ('english-royal', 'english-royal-f96', 'anne-holand', 'child');
-- english-royal-f97: Richard Plantagenet → Anne Plantagenet
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f97', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f97', 'richard-plantagenet-2', 'parent'),
    ('english-royal', 'english-royal-f97', 'anne-plantagenet-2', 'child');
-- english-royal-f98: Henry Stafford + Cecily Bonville (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f98', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f98', 'henry-stafford-2', 'parent'),
    ('english-royal', 'english-royal-f98', 'cecily-bonville', 'parent');
-- english-royal-f99: William Bonville + Catherine Neville → Cecily Bonville
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f99', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f99', 'william-bonville', 'parent'),
    ('english-royal', 'english-royal-f99', 'catherine-neville', 'parent'),
    ('english-royal', 'english-royal-f99', 'cecily-bonville', 'child');
-- english-royal-f100: Henry Grey + Frances Brandon → Jane Grey, Catherine Grey, Mary Grey
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f100', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f100', 'henry-grey', 'parent'),
    ('english-royal', 'english-royal-f100', 'frances-brandon', 'parent'),
    ('english-royal', 'english-royal-f100', 'jane-grey', 'child'),
    ('english-royal', 'english-royal-f100', 'catherine-grey', 'child'),
    ('english-royal', 'english-royal-f100', 'mary-grey', 'child');
-- english-royal-f101: Adrian Stokes + Frances Brandon (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f101', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f101', 'adrian-stokes', 'parent'),
    ('english-royal', 'english-royal-f101', 'frances-brandon', 'parent');
-- english-royal-f102: Thomas Grey + Margaret Wotton → Henry Grey
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f102', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f102', 'thomas-grey-2', 'parent'),
    ('english-royal', 'english-royal-f102', 'margaret-wotton', 'parent'),
    ('english-royal', 'english-royal-f102', 'henry-grey', 'child');
-- english-royal-f103: William Medley + Margaret Wotton (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f103', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f103', 'william-medley', 'parent'),
    ('english-royal', 'english-royal-f103', 'margaret-wotton', 'parent');
-- english-royal-f104: Robert Wotton + Anne Belknap → Margaret Wotton
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f104', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f104', 'robert-wotton', 'parent'),
    ('english-royal', 'english-royal-f104', 'anne-belknap', 'parent'),
    ('english-royal', 'english-royal-f104', 'margaret-wotton', 'child');
-- english-royal-f105: Henry Belknap → Anne Belknap
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f105', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f105', 'henry-belknap', 'parent'),
    ('english-royal', 'english-royal-f105', 'anne-belknap', 'child');
-- english-royal-f106: Henry Grey + Catherine FitzAlan (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f106', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f106', 'henry-grey', 'parent'),
    ('english-royal', 'english-royal-f106', 'catherine-fitzalan', 'parent');
-- english-royal-f107: William FitzAlan + Anne Percy → Catherine FitzAlan
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f107', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f107', 'william-fitzalan', 'parent'),
    ('english-royal', 'english-royal-f107', 'anne-percy', 'parent'),
    ('english-royal', 'english-royal-f107', 'catherine-fitzalan', 'child');
-- english-royal-f108: Henry Clifford + Eleanor Brandon → Margaret Clifford
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f108', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f108', 'henry-clifford', 'parent'),
    ('english-royal', 'english-royal-f108', 'eleanor-brandon', 'parent'),
    ('english-royal', 'english-royal-f108', 'margaret-clifford', 'child');
-- english-royal-f109: Henry Clifford + Anne Dacre (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f109', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f109', 'henry-clifford', 'parent'),
    ('english-royal', 'english-royal-f109', 'anne-dacre', 'parent');
-- english-royal-f110: Henry Stanley + Margaret Clifford (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f110', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f110', 'henry-stanley', 'parent'),
    ('english-royal', 'english-royal-f110', 'margaret-clifford', 'parent');
-- english-royal-f111: William Dacre + Elizabeth Talbot → Anne Dacre
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f111', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f111', 'william-dacre', 'parent'),
    ('english-royal', 'english-royal-f111', 'elizabeth-talbot-3', 'parent'),
    ('english-royal', 'english-royal-f111', 'anne-dacre', 'child');
-- english-royal-f112: George Talbot → Elizabeth Talbot
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f112', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f112', 'george-talbot', 'parent'),
    ('english-royal', 'english-royal-f112', 'elizabeth-talbot-3', 'child');
-- english-royal-f113: Richard Neville + Alice Montagu → Eleanor Neville
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f113', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f113', 'richard-neville', 'parent'),
    ('english-royal', 'english-royal-f113', 'alice-montagu', 'parent'),
    ('english-royal', 'english-royal-f113', 'eleanor-neville', 'child');
-- english-royal-f114: Thomas Montagu → Alice Montagu
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f114', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f114', 'thomas-montagu', 'parent'),
    ('english-royal', 'english-royal-f114', 'alice-montagu', 'child');
-- english-royal-f115: George Stanley + Joan le Strange → Thomas Stanley
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f115', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f115', 'george-stanley', 'parent'),
    ('english-royal', 'english-royal-f115', 'joan-le-strange', 'parent'),
    ('english-royal', 'english-royal-f115', 'thomas-stanley-2', 'child');
-- english-royal-f116: John le Strange + Jacquette Wydvill → Joan le Strange
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f116', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f116', 'john-le-strange', 'parent'),
    ('english-royal', 'english-royal-f116', 'jacquette-wydvill', 'parent'),
    ('english-royal', 'english-royal-f116', 'joan-le-strange', 'child');
-- english-royal-f117: Thomas Stanley + Anne Hastings → Edward Stanley
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f117', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f117', 'thomas-stanley-2', 'parent'),
    ('english-royal', 'english-royal-f117', 'anne-hastings', 'parent'),
    ('english-royal', 'english-royal-f117', 'edward-stanley', 'child');
-- english-royal-f118: Edward Hastings + Mary Hungerford → Anne Hastings
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f118', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f118', 'edward-hastings', 'parent'),
    ('english-royal', 'english-royal-f118', 'mary-hungerford', 'parent'),
    ('english-royal', 'english-royal-f118', 'anne-hastings', 'child');
-- english-royal-f119: Thomas Hungerford → Mary Hungerford
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f119', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f119', 'thomas-hungerford', 'parent'),
    ('english-royal', 'english-royal-f119', 'mary-hungerford', 'child');
-- english-royal-f120: Edward Stanley + Dorothy Howard → Henry Stanley
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f120', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f120', 'edward-stanley', 'parent'),
    ('english-royal', 'english-royal-f120', 'dorothy-howard', 'parent'),
    ('english-royal', 'english-royal-f120', 'henry-stanley', 'child');
-- english-royal-f121: Edward Stanley + Margaret Barlow (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f121', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f121', 'edward-stanley', 'parent'),
    ('english-royal', 'english-royal-f121', 'margaret-barlow', 'parent');
-- english-royal-f122: Edward Stanley + Mary Cotton (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f122', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f122', 'edward-stanley', 'parent'),
    ('english-royal', 'english-royal-f122', 'mary-cotton', 'parent');
-- english-royal-f123: Ellis Barlow + Anne Reddish → Margaret Barlow
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f123', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f123', 'ellis-barlow', 'parent'),
    ('english-royal', 'english-royal-f123', 'anne-reddish', 'parent'),
    ('english-royal', 'english-royal-f123', 'margaret-barlow', 'child');
-- english-royal-f124: Otes Reddish → Anne Reddish
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f124', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f124', 'otes-reddish', 'parent'),
    ('english-royal', 'english-royal-f124', 'anne-reddish', 'child');
-- english-royal-f125: Henry Grey + Mary Cotton (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f125', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f125', 'henry-grey-2', 'parent'),
    ('english-royal', 'english-royal-f125', 'mary-cotton', 'parent');
-- english-royal-f126: George Cotton + Mary Onley → Mary Cotton
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f126', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f126', 'george-cotton', 'parent'),
    ('english-royal', 'english-royal-f126', 'mary-onley', 'parent'),
    ('english-royal', 'english-royal-f126', 'mary-cotton', 'child');
-- english-royal-f127: John Onley → Mary Onley
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f127', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f127', 'john-onley', 'parent'),
    ('english-royal', 'english-royal-f127', 'mary-onley', 'child');
-- english-royal-f128: Henry Herbert + Catherine Grey (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f128', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f128', 'henry-herbert', 'parent'),
    ('english-royal', 'english-royal-f128', 'catherine-grey', 'parent');
-- english-royal-f129: Edward Seymour + Catherine Grey (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f129', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f129', 'edward-seymour', 'parent'),
    ('english-royal', 'english-royal-f129', 'catherine-grey', 'parent');
-- english-royal-f130: Thomas Keyes + Mary Grey (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f130', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f130', 'thomas-keyes', 'parent'),
    ('english-royal', 'english-royal-f130', 'mary-grey', 'parent');
-- english-royal-f131: Edward Seymour + Frances Howard (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f131', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f131', 'edward-seymour', 'parent'),
    ('english-royal', 'english-royal-f131', 'frances-howard', 'parent');
-- english-royal-f132: Edward Seymour + Frances Howard (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f132', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f132', 'edward-seymour', 'parent'),
    ('english-royal', 'english-royal-f132', 'frances-howard-2', 'parent');
-- english-royal-f133: Edward Seymour + Anne Stanhope → Edward Seymour
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f133', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f133', 'edward-seymour-2', 'parent'),
    ('english-royal', 'english-royal-f133', 'anne-stanhope', 'parent'),
    ('english-royal', 'english-royal-f133', 'edward-seymour', 'child');
-- english-royal-f134: William Howard + Margaret Gamage → Frances Howard
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f134', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f134', 'william-howard', 'parent'),
    ('english-royal', 'english-royal-f134', 'margaret-gamage', 'parent'),
    ('english-royal', 'english-royal-f134', 'frances-howard', 'child');
-- english-royal-f135: Thomas Gamage → Margaret Gamage
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f135', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f135', 'thomas-gamage', 'parent'),
    ('english-royal', 'english-royal-f135', 'margaret-gamage', 'child');
-- english-royal-f136: Henry Pranell + Frances Howard (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f136', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f136', 'henry-pranell', 'parent'),
    ('english-royal', 'english-royal-f136', 'frances-howard-2', 'parent');
-- english-royal-f137: Ludovic Stuart + Frances Howard (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f137', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f137', 'ludovic-stuart', 'parent'),
    ('english-royal', 'english-royal-f137', 'frances-howard-2', 'parent');
-- english-royal-f138: Thomas Howard + Mabel Burton → Frances Howard
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f138', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f138', 'thomas-howard-3', 'parent'),
    ('english-royal', 'english-royal-f138', 'mabel-burton', 'parent'),
    ('english-royal', 'english-royal-f138', 'frances-howard-2', 'child');
-- english-royal-f139: Nicholas Burton → Mabel Burton
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f139', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f139', 'nicholas-burton', 'parent'),
    ('english-royal', 'english-royal-f139', 'mabel-burton', 'child');
-- english-royal-f140: Henry Wentworth → Margery Wentworth
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f140', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f140', 'henry-wentworth', 'parent'),
    ('english-royal', 'english-royal-f140', 'margery-wentworth', 'child');
-- english-royal-f141: Thomas Green → Maud Green
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f141', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f141', 'thomas-green', 'parent'),
    ('english-royal', 'english-royal-f141', 'maud-green', 'child');
-- english-royal-f142: Gilbert Gray → James Gray
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f142', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f142', 'gilbert-gray', 'parent'),
    ('english-royal', 'english-royal-f142', 'james-gray', 'child');
-- english-royal-f143: James Stewart + Margaret Tudor → James Stewart, (unnamed daughter) Stewart, Arthur Stewart, James Stewart, (unnamed daughter) Stewart, Alexander Stewart
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f143', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f143', 'james-stewart-2', 'parent'),
    ('english-royal', 'english-royal-f143', 'margaret-tudor', 'parent'),
    ('english-royal', 'english-royal-f143', 'james-stewart', 'child'),
    ('english-royal', 'english-royal-f143', 'unnamed-daughter-stewart', 'child'),
    ('english-royal', 'english-royal-f143', 'arthur-stewart', 'child'),
    ('english-royal', 'english-royal-f143', 'james-stewart-3', 'child'),
    ('english-royal', 'english-royal-f143', 'unnamed-daughter-stewart-2', 'child'),
    ('english-royal', 'english-royal-f143', 'alexander-stewart', 'child');
-- english-royal-f144: Matthew Stuart + Margaret Douglas → Henry Stuart, Charles Stuart
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f144', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f144', 'matthew-stuart', 'parent'),
    ('english-royal', 'english-royal-f144', 'margaret-douglas', 'parent'),
    ('english-royal', 'english-royal-f144', 'henry-stuart', 'child'),
    ('english-royal', 'english-royal-f144', 'charles-stuart', 'child');
-- english-royal-f145: Charles Stuart + Elizabeth Cavendish → Arabella Stuart
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f145', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f145', 'charles-stuart', 'parent'),
    ('english-royal', 'english-royal-f145', 'elizabeth-cavendish', 'parent'),
    ('english-royal', 'english-royal-f145', 'arabella-stuart', 'child');
-- english-royal-f146: William Cavendish → Elizabeth Cavendish
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f146', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f146', 'william-cavendish', 'parent'),
    ('english-royal', 'english-royal-f146', 'elizabeth-cavendish', 'child');
-- english-royal-f147: William Seymour + Arabella Stuart (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f147', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f147', 'william-seymour', 'parent'),
    ('english-royal', 'english-royal-f147', 'arabella-stuart', 'parent');
-- english-royal-f148: James Stewart + Margaret Boyd → Alexander Stewart, Catherine Stewart
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f148', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f148', 'james-stewart-2', 'parent'),
    ('english-royal', 'english-royal-f148', 'margaret-boyd', 'parent'),
    ('english-royal', 'english-royal-f148', 'alexander-stewart-2', 'child'),
    ('english-royal', 'english-royal-f148', 'catherine-stewart', 'child');
-- english-royal-f149: James Douglas + Catherine Stewart (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f149', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f149', 'james-douglas-2', 'parent'),
    ('english-royal', 'english-royal-f149', 'catherine-stewart', 'parent');
-- english-royal-f150: James Stewart + Janet Kennedy → James Stewart
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f150', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f150', 'james-stewart-2', 'parent'),
    ('english-royal', 'english-royal-f150', 'janet-kennedy', 'parent'),
    ('english-royal', 'english-royal-f150', 'james-stewart-4', 'child');
-- english-royal-f151: James Stewart + Elizabeth Campbell (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f151', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f151', 'james-stewart-4', 'parent'),
    ('english-royal', 'english-royal-f151', 'elizabeth-campbell', 'parent');
-- english-royal-f152: Colin Campbell → Elizabeth Campbell
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f152', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f152', 'colin-campbell', 'parent'),
    ('english-royal', 'english-royal-f152', 'elizabeth-campbell', 'child');
-- english-royal-f153: James Stewart + Margaret Drummond → Margaret Stewart
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f153', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f153', 'james-stewart-2', 'parent'),
    ('english-royal', 'english-royal-f153', 'margaret-drummond', 'parent'),
    ('english-royal', 'english-royal-f153', 'margaret-stewart', 'child');
-- english-royal-f154: John Gordon + Margaret Stewart (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f154', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f154', 'john-gordon', 'parent'),
    ('english-royal', 'english-royal-f154', 'margaret-stewart', 'parent');
-- english-royal-f155: John Drummond + Margaret Stewart (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f155', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f155', 'john-drummond-2', 'parent'),
    ('english-royal', 'english-royal-f155', 'margaret-stewart', 'parent');
-- english-royal-f156: James Stewart + Isabella Stewart → Janet Stewart
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f156', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f156', 'james-stewart-2', 'parent'),
    ('english-royal', 'english-royal-f156', 'isabella-stewart', 'parent'),
    ('english-royal', 'english-royal-f156', 'janet-stewart-2', 'child');
-- english-royal-f157: James Stewart → Isabella Stewart
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f157', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f157', 'james-stewart-5', 'parent'),
    ('english-royal', 'english-royal-f157', 'isabella-stewart', 'child');
-- english-royal-f158: Malcolm Fleming + Janet Stewart (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f158', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f158', 'malcolm-fleming', 'parent'),
    ('english-royal', 'english-royal-f158', 'janet-stewart-2', 'parent');
-- english-royal-f159: Henry II + Janet Stewart → Henry of Valois
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f159', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f159', 'henry-ii', 'parent'),
    ('english-royal', 'english-royal-f159', 'janet-stewart-2', 'parent'),
    ('english-royal', 'english-royal-f159', 'henry-of-valois', 'child');
-- english-royal-f160: James Stewart + Madeleine of Valois (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f160', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f160', 'james-stewart-3', 'parent'),
    ('english-royal', 'english-royal-f160', 'madeleine-of-valois', 'parent');
-- english-royal-f161: Francis I → Madeleine of Valois
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f161', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f161', 'francis-i', 'parent'),
    ('english-royal', 'english-royal-f161', 'madeleine-of-valois', 'child');
-- english-royal-f162: James Stewart + Mary of Lorraine → James Stewart, Arthur Stewart, Mary Stewart
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f162', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f162', 'james-stewart-3', 'parent'),
    ('english-royal', 'english-royal-f162', 'mary-of-lorraine', 'parent'),
    ('english-royal', 'english-royal-f162', 'james-stewart-6', 'child'),
    ('english-royal', 'english-royal-f162', 'arthur-stewart-2', 'child'),
    ('english-royal', 'english-royal-f162', 'mary-stewart', 'child');
-- english-royal-f163: Louis of Orleans + Mary of Lorraine (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f163', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f163', 'louis-of-orleans', 'parent'),
    ('english-royal', 'english-royal-f163', 'mary-of-lorraine', 'parent');
-- english-royal-f164: Francis II + Mary Stewart (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f164', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f164', 'francis-ii', 'parent'),
    ('english-royal', 'english-royal-f164', 'mary-stewart', 'parent');
-- english-royal-f165: Henry II + Catherine de Medicis → Francis II
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f165', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f165', 'henry-ii', 'parent'),
    ('english-royal', 'english-royal-f165', 'catherine-de-medicis', 'parent'),
    ('english-royal', 'english-royal-f165', 'francis-ii', 'child');
-- english-royal-f166: Henry Stuart + Mary Stewart → James Stuart
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f166', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f166', 'henry-stuart', 'parent'),
    ('english-royal', 'english-royal-f166', 'mary-stewart', 'parent'),
    ('english-royal', 'english-royal-f166', 'james-stuart', 'child');
-- english-royal-f167: James Hepburn + Mary Stewart (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f167', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f167', 'james-hepburn', 'parent'),
    ('english-royal', 'english-royal-f167', 'mary-stewart', 'parent');
-- english-royal-f168: James Stuart + Anne of Oldenburg (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f168', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f168', 'james-stuart', 'parent'),
    ('english-royal', 'english-royal-f168', 'anne-of-oldenburg', 'parent');
-- english-royal-f169: William Carey + Mary Boleyn (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f169', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f169', 'william-carey', 'parent'),
    ('english-royal', 'english-royal-f169', 'mary-boleyn', 'parent');
-- english-royal-f170: William Stafford + Mary Boleyn (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f170', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f170', 'william-stafford', 'parent'),
    ('english-royal', 'english-royal-f170', 'mary-boleyn', 'parent');
-- english-royal-f171: Henry VIII + Mary Boleyn → Henry Carey, Catherine Carey
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f171', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f171', 'henry-viii', 'parent'),
    ('english-royal', 'english-royal-f171', 'mary-boleyn', 'parent'),
    ('english-royal', 'english-royal-f171', 'henry-carey', 'child'),
    ('english-royal', 'english-royal-f171', 'catherine-carey', 'child');
-- english-royal-f172: Francis Knollys + Catherine Carey (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f172', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f172', 'francis-knollys', 'parent'),
    ('english-royal', 'english-royal-f172', 'catherine-carey', 'parent');
-- english-royal-f173: Henry Carey + Anne Morgan (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f173', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f173', 'henry-carey', 'parent'),
    ('english-royal', 'english-royal-f173', 'anne-morgan', 'parent');
-- english-royal-f174: Philip II + Mary I (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f174', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f174', 'philip-ii', 'parent'),
    ('english-royal', 'english-royal-f174', 'mary-i', 'parent');
-- english-royal-f175: Guilford Dudley + Jane Grey (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('english-royal', 'english-royal-f175', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('english-royal', 'english-royal-f175', 'guilford-dudley', 'parent'),
    ('english-royal', 'english-royal-f175', 'jane-grey', 'parent');


-- =================================================================================================
-- SAGA 12 of 17: GREEK GODS   [id: greek-gods, category: mythology]
-- Author:  Unknown compiler
-- Medium:  GEDCOM genealogy (Greek+Gods.ged)
-- Canon:   As recorded in the GEDCOM file
-- Covers:  69 people and 45 families, imported from a public GEDCOM sample.
-- Rows:    1 houses, 69 people, 45 families, 126 members
-- =================================================================================================

-- ── Reset (removes this saga and, by cascade, all of its rows) ─────────────────────────────────
DELETE FROM saga WHERE id = 'greek-gods';

-- ── Saga ───────────────────────────────────────────────────────────────────────────────────────
INSERT INTO saga (id, category, position, title, work, medium, author, canon, genre, covers) VALUES
    ('greek-gods', 'mythology', 11, 'Greek Gods', 'Greek Gods', 'GEDCOM genealogy (Greek+Gods.ged)', 'Unknown compiler', 'As recorded in the GEDCOM file', 'Mythology', '69 people and 45 families, imported from a public GEDCOM sample.');

-- ── Notes (modelling choices and where sources disagree) ───────────────────────────────────────
INSERT INTO saga_note (saga_id, position, note) VALUES
    ('greek-gods', 0, 'Imported from Greek+Gods.ged (UTF-8; FTW 10.0; file dated 27 JAN 2004) by scripts/gedcom-to-saga.mts.'),
    ('greek-gods', 1, 'Names are read in mythology mode: the deity''s name is the GEDCOM surname part, and descriptive text in the given-name part (e.g. "queen of the Gods") is dropped.'),
    ('greek-gods', 2, 'Everyone is in one house, "Greek pantheon": the file has no real surnames to group by.');

-- ── Houses (1) ─────────────────────────────────────────────────────────────────────────────────
INSERT INTO house (saga_id, name, color) VALUES
    ('greek-gods', 'Greek pantheon', '#c8102e');

-- ── People (69, grouped by house) ──────────────────────────────────────────────────────────────
-- Greek pantheon (69)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('greek-gods', 'andromache', 'Andromache', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'hera', 'Hera', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'eros', 'Eros', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'hebe', 'Hebe', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'ares', 'Ares', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'adonis', 'Adonis', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'dionne', 'Dionne', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'aphrodite', 'Aphrodite', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'anchises', 'Anchises', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'aeneas', 'Aeneas', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'creusa', 'Creusa', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'silvius-aeneas', 'Silvius Aeneas', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'numa-pompilius', 'Numa Pompilius', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'rhea-silvia', 'Rhea Silvia', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'fetebir', 'Fetebir', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'lavinia', 'Lavinia', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'ascanius-iulus', 'Ascanius Iulus', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'ate', 'Ate', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'neoptolemus', 'Neoptolemus', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'persephone', 'Persephone', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'demeter', 'Demeter', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'hades', 'Hades', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'cronus', 'Cronus', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'rhea', 'Rhea', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'hephaestus', 'Hephaestus', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'hercules', 'Hercules', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'alcmene', 'Alcmene', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'megara', 'Megara', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'deianira', 'Deianira', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'uranus', 'Uranus', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'gaea', 'Gaea', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'poseidon', 'Poseidon', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'amphitrite', 'Amphitrite', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'triton', 'Triton', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'medusa', 'Medusa', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'pegasus', 'Pegasus', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'orion', 'Orion', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'polyphemus', 'Polyphemus', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'hestia', 'Hestia', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'eileithya', 'Eileithya', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'achilles', 'Achilles', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'peleus', 'Peleus', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'thetis', 'Thetis', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'neures', 'Neures', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'pontus', 'Pontus', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'doris', 'Doris', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'oceanus', 'Oceanus', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'chaos', 'Chaos', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'thethys', 'Thethys', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'deidamia', 'Deidamia', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'hermione', 'Hermione', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'helen', 'Helen', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'menelaus', 'Menelaus', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'zeus', 'Zeus', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'leda', 'Leda', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'polydueces', 'Polydueces', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'a-titan-coeus', 'A Titan Coeus', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'a-titan-crius', 'A Titan Crius', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'a-titan-hyperion', 'A Titan Hyperion', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'a-titan-iapetus', 'A Titan Iapetus', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'a-titan-thea', 'A Titan Thea', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'a-titan-themis', 'A Titan Themis', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'phoebe', 'Phoebe', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'a-titan-mnemosyne', 'A Titan Mnemosyne', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'athena', 'Athena', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'apollo', 'Apollo', 'Greek pantheon', 'm', NULL),
    ('greek-gods', 'artemis', 'Artemis', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'leto', 'Leto', 'Greek pantheon', 'f', NULL),
    ('greek-gods', 'eris', 'Eris', 'Greek pantheon', 'f', NULL);

-- ── Families (45, each followed by its members) ────────────────────────────────────────────────
-- greek-gods-f1: Andromache (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f1', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f1', 'andromache', 'parent');
-- greek-gods-f2: (parents unknown) → Andromache
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f2', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f2', 'andromache', 'child');
-- greek-gods-f3: (parents unknown) → Anchises
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f3', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f3', 'anchises', 'child');
-- greek-gods-f4: Anchises + Aphrodite → Aeneas
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f4', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f4', 'anchises', 'parent'),
    ('greek-gods', 'greek-gods-f4', 'aphrodite', 'parent'),
    ('greek-gods', 'greek-gods-f4', 'aeneas', 'child');
-- greek-gods-f5: Aeneas + Creusa → Silvius Aeneas, Numa Pompilius
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f5', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f5', 'aeneas', 'parent'),
    ('greek-gods', 'greek-gods-f5', 'creusa', 'parent'),
    ('greek-gods', 'greek-gods-f5', 'silvius-aeneas', 'child'),
    ('greek-gods', 'greek-gods-f5', 'numa-pompilius', 'child');
-- greek-gods-f6: Numa Pompilius → Rhea Silvia
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f6', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f6', 'numa-pompilius', 'parent'),
    ('greek-gods', 'greek-gods-f6', 'rhea-silvia', 'child');
-- greek-gods-f7: Fetebir + Rhea Silvia (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f7', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f7', 'fetebir', 'parent'),
    ('greek-gods', 'greek-gods-f7', 'rhea-silvia', 'parent');
-- greek-gods-f8: Aeneas + Lavinia → Ascanius Iulus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f8', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f8', 'aeneas', 'parent'),
    ('greek-gods', 'greek-gods-f8', 'lavinia', 'parent'),
    ('greek-gods', 'greek-gods-f8', 'ascanius-iulus', 'child');
-- greek-gods-f9: Andromache (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f9', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f9', 'andromache', 'parent');
-- greek-gods-f10: Zeus + Dionne → Aphrodite
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f10', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f10', 'zeus', 'parent'),
    ('greek-gods', 'greek-gods-f10', 'dionne', 'parent'),
    ('greek-gods', 'greek-gods-f10', 'aphrodite', 'child');
-- greek-gods-f11: Adonis + Aphrodite (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f11', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f11', 'adonis', 'parent'),
    ('greek-gods', 'greek-gods-f11', 'aphrodite', 'parent');
-- greek-gods-f12: Ares + Aphrodite (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f12', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f12', 'ares', 'parent'),
    ('greek-gods', 'greek-gods-f12', 'aphrodite', 'parent');
-- greek-gods-f13: Hephaestus + Aphrodite → Eros
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f13', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f13', 'hephaestus', 'parent'),
    ('greek-gods', 'greek-gods-f13', 'aphrodite', 'parent'),
    ('greek-gods', 'greek-gods-f13', 'eros', 'child');
-- greek-gods-f14: Zeus + Hera → Hephaestus, Ares, Hebe, Eileithya
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f14', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f14', 'zeus', 'parent'),
    ('greek-gods', 'greek-gods-f14', 'hera', 'parent'),
    ('greek-gods', 'greek-gods-f14', 'hephaestus', 'child'),
    ('greek-gods', 'greek-gods-f14', 'ares', 'child'),
    ('greek-gods', 'greek-gods-f14', 'hebe', 'child'),
    ('greek-gods', 'greek-gods-f14', 'eileithya', 'child');
-- greek-gods-f15: Neoptolemus + Andromache (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f15', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f15', 'neoptolemus', 'parent'),
    ('greek-gods', 'greek-gods-f15', 'andromache', 'parent');
-- greek-gods-f16: Zeus + Eris → Ate
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f16', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f16', 'zeus', 'parent'),
    ('greek-gods', 'greek-gods-f16', 'eris', 'parent'),
    ('greek-gods', 'greek-gods-f16', 'ate', 'child');
-- greek-gods-f17: Hercules + Megara (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f17', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f17', 'hercules', 'parent'),
    ('greek-gods', 'greek-gods-f17', 'megara', 'parent');
-- greek-gods-f18: Hercules + Deianira (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f18', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f18', 'hercules', 'parent'),
    ('greek-gods', 'greek-gods-f18', 'deianira', 'parent');
-- greek-gods-f19: Hercules + Hebe (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f19', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f19', 'hercules', 'parent'),
    ('greek-gods', 'greek-gods-f19', 'hebe', 'parent');
-- greek-gods-f20: (parents unknown) → Adonis
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f20', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f20', 'adonis', 'child');
-- greek-gods-f21: Adonis + Persephone (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f21', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f21', 'adonis', 'parent'),
    ('greek-gods', 'greek-gods-f21', 'persephone', 'parent');
-- greek-gods-f22: Zeus + Demeter → Persephone
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f22', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f22', 'zeus', 'parent'),
    ('greek-gods', 'greek-gods-f22', 'demeter', 'parent'),
    ('greek-gods', 'greek-gods-f22', 'persephone', 'child');
-- greek-gods-f23: Hades + Persephone (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f23', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f23', 'hades', 'parent'),
    ('greek-gods', 'greek-gods-f23', 'persephone', 'parent');
-- greek-gods-f24: Cronus + Rhea → Demeter, Hera, Poseidon, Hades, Hestia, Zeus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f24', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f24', 'cronus', 'parent'),
    ('greek-gods', 'greek-gods-f24', 'rhea', 'parent'),
    ('greek-gods', 'greek-gods-f24', 'demeter', 'child'),
    ('greek-gods', 'greek-gods-f24', 'hera', 'child'),
    ('greek-gods', 'greek-gods-f24', 'poseidon', 'child'),
    ('greek-gods', 'greek-gods-f24', 'hades', 'child'),
    ('greek-gods', 'greek-gods-f24', 'hestia', 'child'),
    ('greek-gods', 'greek-gods-f24', 'zeus', 'child');
-- greek-gods-f25: Zeus + Alcmene → Hercules
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f25', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f25', 'zeus', 'parent'),
    ('greek-gods', 'greek-gods-f25', 'alcmene', 'parent'),
    ('greek-gods', 'greek-gods-f25', 'hercules', 'child');
-- greek-gods-f26: Alcmene (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f26', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f26', 'alcmene', 'parent');
-- greek-gods-f27: Uranus + Gaea → Cronus, Rhea, Oceanus, Thethys, A Titan Coeus, A Titan Crius, A Titan Hyperion, A Titan Iapetus, A Titan Thea, A Titan Themis, Phoebe, A Titan Mnemosyne
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f27', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f27', 'uranus', 'parent'),
    ('greek-gods', 'greek-gods-f27', 'gaea', 'parent'),
    ('greek-gods', 'greek-gods-f27', 'cronus', 'child'),
    ('greek-gods', 'greek-gods-f27', 'rhea', 'child'),
    ('greek-gods', 'greek-gods-f27', 'oceanus', 'child'),
    ('greek-gods', 'greek-gods-f27', 'thethys', 'child'),
    ('greek-gods', 'greek-gods-f27', 'a-titan-coeus', 'child'),
    ('greek-gods', 'greek-gods-f27', 'a-titan-crius', 'child'),
    ('greek-gods', 'greek-gods-f27', 'a-titan-hyperion', 'child'),
    ('greek-gods', 'greek-gods-f27', 'a-titan-iapetus', 'child'),
    ('greek-gods', 'greek-gods-f27', 'a-titan-thea', 'child'),
    ('greek-gods', 'greek-gods-f27', 'a-titan-themis', 'child'),
    ('greek-gods', 'greek-gods-f27', 'phoebe', 'child'),
    ('greek-gods', 'greek-gods-f27', 'a-titan-mnemosyne', 'child');
-- greek-gods-f28: Poseidon + Amphitrite → Triton
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f28', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f28', 'poseidon', 'parent'),
    ('greek-gods', 'greek-gods-f28', 'amphitrite', 'parent'),
    ('greek-gods', 'greek-gods-f28', 'triton', 'child');
-- greek-gods-f29: Poseidon + Medusa → Pegasus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f29', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f29', 'poseidon', 'parent'),
    ('greek-gods', 'greek-gods-f29', 'medusa', 'parent'),
    ('greek-gods', 'greek-gods-f29', 'pegasus', 'child');
-- greek-gods-f30: Poseidon → Orion
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f30', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f30', 'poseidon', 'parent'),
    ('greek-gods', 'greek-gods-f30', 'orion', 'child');
-- greek-gods-f31: Poseidon → Polyphemus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f31', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f31', 'poseidon', 'parent'),
    ('greek-gods', 'greek-gods-f31', 'polyphemus', 'child');
-- greek-gods-f32: Achilles + Deidamia → Neoptolemus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f32', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f32', 'achilles', 'parent'),
    ('greek-gods', 'greek-gods-f32', 'deidamia', 'parent'),
    ('greek-gods', 'greek-gods-f32', 'neoptolemus', 'child');
-- greek-gods-f33: Peleus + Thetis → Achilles
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f33', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f33', 'peleus', 'parent'),
    ('greek-gods', 'greek-gods-f33', 'thetis', 'parent'),
    ('greek-gods', 'greek-gods-f33', 'achilles', 'child');
-- greek-gods-f34: Neures + Doris → Thetis
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f34', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f34', 'neures', 'parent'),
    ('greek-gods', 'greek-gods-f34', 'doris', 'parent'),
    ('greek-gods', 'greek-gods-f34', 'thetis', 'child');
-- greek-gods-f35: Pontus + Gaea → Neures
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f35', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f35', 'pontus', 'parent'),
    ('greek-gods', 'greek-gods-f35', 'gaea', 'parent'),
    ('greek-gods', 'greek-gods-f35', 'neures', 'child');
-- greek-gods-f36: Chaos → Gaea
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f36', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f36', 'chaos', 'parent'),
    ('greek-gods', 'greek-gods-f36', 'gaea', 'child');
-- greek-gods-f37: Oceanus + Thethys → Doris
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f37', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f37', 'oceanus', 'parent'),
    ('greek-gods', 'greek-gods-f37', 'thethys', 'parent'),
    ('greek-gods', 'greek-gods-f37', 'doris', 'child');
-- greek-gods-f38: Neoptolemus + Hermione (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f38', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f38', 'neoptolemus', 'parent'),
    ('greek-gods', 'greek-gods-f38', 'hermione', 'parent');
-- greek-gods-f39: Menelaus + Helen → Hermione
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f39', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f39', 'menelaus', 'parent'),
    ('greek-gods', 'greek-gods-f39', 'helen', 'parent'),
    ('greek-gods', 'greek-gods-f39', 'hermione', 'child');
-- greek-gods-f40: Zeus + Leda → Helen, Polydueces
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f40', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f40', 'zeus', 'parent'),
    ('greek-gods', 'greek-gods-f40', 'leda', 'parent'),
    ('greek-gods', 'greek-gods-f40', 'helen', 'child'),
    ('greek-gods', 'greek-gods-f40', 'polydueces', 'child');
-- greek-gods-f41: Leda (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f41', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f41', 'leda', 'parent');
-- greek-gods-f42: Eris (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f42', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f42', 'eris', 'parent');
-- greek-gods-f43: Zeus → Athena
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f43', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f43', 'zeus', 'parent'),
    ('greek-gods', 'greek-gods-f43', 'athena', 'child');
-- greek-gods-f44: Zeus + Leto → Apollo, Artemis
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f44', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f44', 'zeus', 'parent'),
    ('greek-gods', 'greek-gods-f44', 'leto', 'parent'),
    ('greek-gods', 'greek-gods-f44', 'apollo', 'child'),
    ('greek-gods', 'greek-gods-f44', 'artemis', 'child');
-- greek-gods-f45: A Titan Coeus + Phoebe → Leto
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('greek-gods', 'greek-gods-f45', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('greek-gods', 'greek-gods-f45', 'a-titan-coeus', 'parent'),
    ('greek-gods', 'greek-gods-f45', 'phoebe', 'parent'),
    ('greek-gods', 'greek-gods-f45', 'leto', 'child');


-- =================================================================================================
-- SAGA 13 of 17: NORSE GODS   [id: norse-gods, category: mythology]
-- Author:  Unknown compiler
-- Medium:  GEDCOM genealogy (Norse+Gods.ged)
-- Canon:   Sources cited: RCKarnes; World Family Tree Vol. 5; Aderholt Hillman Hughes Solomon
-- Dunn Funderburg; Guy Allen Sims
-- Covers:  117 people and 59 families, imported from a public GEDCOM sample.
-- Rows:    1 houses, 117 people, 59 families, 158 members
-- =================================================================================================

-- ── Reset (removes this saga and, by cascade, all of its rows) ─────────────────────────────────
DELETE FROM saga WHERE id = 'norse-gods';

-- ── Saga ───────────────────────────────────────────────────────────────────────────────────────
INSERT INTO saga (id, category, position, title, work, medium, author, canon, genre, covers) VALUES
    ('norse-gods', 'mythology', 12, 'Norse Gods', 'Norse Gods', 'GEDCOM genealogy (Norse+Gods.ged)', 'Unknown compiler', 'Sources cited: RCKarnes; World Family Tree Vol. 5; Aderholt Hillman Hughes Solomon Dunn Funderburg; Guy Allen Sims', 'Mythology', '117 people and 59 families, imported from a public GEDCOM sample.');

-- ── Notes (modelling choices and where sources disagree) ───────────────────────────────────────
INSERT INTO saga_note (saga_id, position, note) VALUES
    ('norse-gods', 0, 'Imported from Norse+Gods.ged (Windows-1252; FTM Family Tree Maker (17.0.0.440); file dated 20 November 2007) by scripts/gedcom-to-saga.mts.'),
    ('norse-gods', 1, 'Names are read in mythology mode: the deity''s name is the GEDCOM surname part, and descriptive text in the given-name part (e.g. "queen of the Gods") is dropped.'),
    ('norse-gods', 2, 'Everyone is in one house, "Norse pantheon": the file has no real surnames to group by.'),
    ('norse-gods', 3, '13 people have no recorded relatives in the source and are shown on their own: Fjalar, Galar, Gefjun, Lofn, Sága, Seaxneat, Sjöfn, Skirnir, Skuld, Vár, Verdandi, Vör, Wyrd.'),
    ('norse-gods', 4, 'Import warnings: Heimdall: sex not recorded as M or F, shown as male; Ve: sex not recorded as M or F, shown as male; Vidar: sex not recorded as M or F, shown as male; Vör: sex not recorded as M or F, shown as male; Family @F000-1@: CHIL points to a missing person; Family @F000-2@: CHIL points to a missing person; Family @F000-4@: CHIL points to a missing person; Family @F000-6@: CHIL points to a missing person; Family @F00-10@: CHIL points to a missing person; Family @F00-11@: CHIL points to a missing person; Family @F00-12@: CHIL points to a missing person; Family @F00-13@: CHIL points to a missing person; Family @F00-14@: CHIL points to a missing person; Family @F00-15@: CHIL points to a missing person; Family @F00-16@: CHIL points to a missing person; Family @F00-17@: CHIL points to a missing person; Family @F00-18@: CHIL points to a missing person; Family @F00-23@: CHIL points to a missing person; Family @F00-24@: CHIL points to a missing person; Family @F00-25@: CHIL points to a missing person; Family @F00-26@: CHIL points to a missing person; Family @F00-27@: CHIL points to a missing person; Family @F00-28@: CHIL points to a missing person');

-- ── Houses (1) ─────────────────────────────────────────────────────────────────────────────────
INSERT INTO house (saga_id, name, color) VALUES
    ('norse-gods', 'Norse pantheon', '#c8102e');

-- ── People (117, grouped by house) ─────────────────────────────────────────────────────────────
-- Norse pantheon (117)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('norse-gods', 'bestla', 'Bestla', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'sibil', 'Sibil', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'angrboda', 'Angrboda', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'annar', 'Annar', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'au-r', 'Auðr', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'au-umbla', 'Auðumbla', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'aurbo-a', 'Aurboða', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'gir', 'Ægir', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'baldr', 'Baldr', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'baugi', 'Baugi', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'bara', 'Bára', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'beli', 'Beli', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'blo-ughadda', 'Blóðughadda', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'bolthorn', 'Bolthorn', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'borr', 'Borr', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'bragi', 'Bragi', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'buri', 'Búri', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'bylgja', 'Bylgja', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'byleistr', 'Býleistr', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'giant-teacher-of-odin-of-nine-magic-charms', 'Giant Teacher of Odin of Nine Magic Charms', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'dagr', 'Dagr', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'delling', 'Delling', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'dufa', 'Dúfa', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'farbauti', 'Fárbauti', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'fenrir', 'Fenrir', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'fjalar', 'Fjalar', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'fjolnir', 'Fjölnir', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'fornjot', 'Fornjót', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'forseti', 'Forseti', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'freyja', 'Freyja', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'freyr', 'Freyr', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'frigg', 'Frigg', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'galar', 'Galar', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'gangr', 'Gangr', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'gefjun', 'Gefjun', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'gerd', 'Gerd', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'gersemi', 'Gersemi', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'a-giantess', 'A Giantess', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'gilling', 'Gilling', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'rich-girl', 'Rich Girl', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'glaur', 'Glaur', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'grid', 'Grid', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'gunnlo', 'Gunnlöð', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'hefring', 'Hefring', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'heimdall', 'Heimdall', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'hel', 'Hel', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'helbindi', 'Helbindi', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'hermod', 'Hermod', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'himingl-va', 'Himinglæva', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'hnoss', 'Hnoss', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'ho-r', 'Höðr', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'hati-hrodvitnisson', 'Hati Hródvitnisson', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'hronn', 'Hrönn', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'idi', 'Idi', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'i-unn', 'Iðunn', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'jarnsaxa', 'Járnsaxa', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'jor', 'Jörð', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'jormungandr', 'Jörmungandr', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'kari', 'Kári', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'kolga', 'Kólga', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'kvasir', 'Kvasir', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'laufey', 'Laufey', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'lofn', 'Lofn', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'logi', 'Logi', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'loki', 'Loki', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'magni', 'Magni', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'mani', 'Máni', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'mimir', 'Mímir', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'mo-i', 'Móði', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'mundilfari', 'Mundilfari', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'naglfari', 'Naglfari', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'nanna', 'Nanna', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'narfi', 'Narfi', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'nepr', 'Nepr', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'nerthus', 'Nerthus', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'njor-r', 'Njörðr', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'nott', 'Nótt', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'odin', 'Odin', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'olvaldi', 'Olvaldi', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'o-r', 'Óðr', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'ran', 'Rán', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'rindr', 'Rindr', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'all-the-female-god-s-saliva', 'All the Female God''s Saliva', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'all-the-male-god-s-saliva', 'All the Male God''s Saliva', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'saga', 'Sága', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'seaxneat', 'Seaxneat', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'sif', 'Sif', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'sigyn', 'Sigyn', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'sjofn', 'Sjöfn', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'ska-i', 'Skaði', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'skirnir', 'Skirnir', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'skoll', 'Skoll', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'skuld', 'Skuld', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'several-sons', 'Several Sons', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'sowilo', 'Sowilo', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'sunna', 'Sunna', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'suttungr', 'Suttungr', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'thjazi', 'Thjazi', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'thor', 'Thor', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'tyr', 'Týr', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'ru-r', 'Þrúðr', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'ullr', 'Ullr', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'unknown', 'Unknown', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'unknown-2', 'Unknown', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'unknown-3', 'Unknown', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'unnr', 'Unnr', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'vali', 'Váli', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'var', 'Vár', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 've', 'Ve', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'verdandi', 'Verdandi', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'vidar', 'Vidar', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'vili', 'Vili', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'visbur', 'Visbur', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'vor', 'Vör', 'Norse pantheon', 'm', NULL),
    ('norse-gods', 'gilling-s-wife', 'Gilling''s Wife', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'wyrd', 'Wyrd', 'Norse pantheon', 'f', NULL),
    ('norse-gods', 'ynglingatal', 'Ynglingatal', 'Norse pantheon', 'm', NULL);

-- ── Families (59, each followed by its members) ────────────────────────────────────────────────
-- norse-gods-f1: Borr + Bestla → Odin, Ve, Vili
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f1', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f1', 'borr', 'parent'),
    ('norse-gods', 'norse-gods-f1', 'bestla', 'parent'),
    ('norse-gods', 'norse-gods-f1', 'odin', 'child'),
    ('norse-gods', 'norse-gods-f1', 've', 'child'),
    ('norse-gods', 'norse-gods-f1', 'vili', 'child');
-- norse-gods-f2: Búri → Borr
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f2', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f2', 'buri', 'parent'),
    ('norse-gods', 'norse-gods-f2', 'borr', 'child');
-- norse-gods-f3: Odin + Frigg → Baldr, Höðr, Bragi, Týr
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f3', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f3', 'odin', 'parent'),
    ('norse-gods', 'norse-gods-f3', 'frigg', 'parent'),
    ('norse-gods', 'norse-gods-f3', 'baldr', 'child'),
    ('norse-gods', 'norse-gods-f3', 'ho-r', 'child'),
    ('norse-gods', 'norse-gods-f3', 'bragi', 'child'),
    ('norse-gods', 'norse-gods-f3', 'tyr', 'child');
-- norse-gods-f4: Borr (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f4', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f4', 'borr', 'parent');
-- norse-gods-f5: Sibil (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f5', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f5', 'sibil', 'parent');
-- norse-gods-f6: Odin + Jörð → Thor
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f6', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f6', 'odin', 'parent'),
    ('norse-gods', 'norse-gods-f6', 'jor', 'parent'),
    ('norse-gods', 'norse-gods-f6', 'thor', 'child');
-- norse-gods-f7: Odin + Grid → Vidar
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f7', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f7', 'odin', 'parent'),
    ('norse-gods', 'norse-gods-f7', 'grid', 'parent'),
    ('norse-gods', 'norse-gods-f7', 'vidar', 'child');
-- norse-gods-f8: Odin + Rindr (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f8', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f8', 'odin', 'parent'),
    ('norse-gods', 'norse-gods-f8', 'rindr', 'parent');
-- norse-gods-f9: Bolthorn → Bestla, Giant Teacher of Odin of Nine Magic Charms
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f9', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f9', 'bolthorn', 'parent'),
    ('norse-gods', 'norse-gods-f9', 'bestla', 'child'),
    ('norse-gods', 'norse-gods-f9', 'giant-teacher-of-odin-of-nine-magic-charms', 'child');
-- norse-gods-f10: Auðumbla → Búri
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f10', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f10', 'au-umbla', 'parent'),
    ('norse-gods', 'norse-gods-f10', 'buri', 'child');
-- norse-gods-f11: Fárbauti + Laufey → Loki, Býleistr, Helbindi
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f11', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f11', 'farbauti', 'parent'),
    ('norse-gods', 'norse-gods-f11', 'laufey', 'parent'),
    ('norse-gods', 'norse-gods-f11', 'loki', 'child'),
    ('norse-gods', 'norse-gods-f11', 'byleistr', 'child'),
    ('norse-gods', 'norse-gods-f11', 'helbindi', 'child');
-- norse-gods-f12: Loki + Angrboda → Fenrir, Jörmungandr, Hel
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f12', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f12', 'loki', 'parent'),
    ('norse-gods', 'norse-gods-f12', 'angrboda', 'parent'),
    ('norse-gods', 'norse-gods-f12', 'fenrir', 'child'),
    ('norse-gods', 'norse-gods-f12', 'jormungandr', 'child'),
    ('norse-gods', 'norse-gods-f12', 'hel', 'child');
-- norse-gods-f13: Fenrir + A Giantess → Hati Hródvitnisson, Skoll
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f13', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f13', 'fenrir', 'parent'),
    ('norse-gods', 'norse-gods-f13', 'a-giantess', 'parent'),
    ('norse-gods', 'norse-gods-f13', 'hati-hrodvitnisson', 'child'),
    ('norse-gods', 'norse-gods-f13', 'skoll', 'child');
-- norse-gods-f14: Baldr + Nanna → Forseti
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f14', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f14', 'baldr', 'parent'),
    ('norse-gods', 'norse-gods-f14', 'nanna', 'parent'),
    ('norse-gods', 'norse-gods-f14', 'forseti', 'child');
-- norse-gods-f15: Nepr → Nanna
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f15', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f15', 'nepr', 'parent'),
    ('norse-gods', 'norse-gods-f15', 'nanna', 'child');
-- norse-gods-f16: Odin → Nepr
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f16', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f16', 'odin', 'parent'),
    ('norse-gods', 'norse-gods-f16', 'nepr', 'child');
-- norse-gods-f17: Vili + Frigg (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f17', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f17', 'vili', 'parent'),
    ('norse-gods', 'norse-gods-f17', 'frigg', 'parent');
-- norse-gods-f18: Mímir → Several Sons
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f18', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f18', 'mimir', 'parent'),
    ('norse-gods', 'norse-gods-f18', 'several-sons', 'child');
-- norse-gods-f19: Unknown → Njörðr
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f19', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f19', 'unknown', 'parent'),
    ('norse-gods', 'norse-gods-f19', 'njor-r', 'child');
-- norse-gods-f20: Njörðr + Skaði (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f20', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f20', 'njor-r', 'parent'),
    ('norse-gods', 'norse-gods-f20', 'ska-i', 'parent');
-- norse-gods-f21: Thjazi → Skaði
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f21', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f21', 'thjazi', 'parent'),
    ('norse-gods', 'norse-gods-f21', 'ska-i', 'child');
-- norse-gods-f22: Olvaldi → Thjazi, Gangr, Idi
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f22', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f22', 'olvaldi', 'parent'),
    ('norse-gods', 'norse-gods-f22', 'thjazi', 'child'),
    ('norse-gods', 'norse-gods-f22', 'gangr', 'child'),
    ('norse-gods', 'norse-gods-f22', 'idi', 'child');
-- norse-gods-f23: Njörðr + Nerthus → Freyr, Freyja
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f23', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f23', 'njor-r', 'parent'),
    ('norse-gods', 'norse-gods-f23', 'nerthus', 'parent'),
    ('norse-gods', 'norse-gods-f23', 'freyr', 'child'),
    ('norse-gods', 'norse-gods-f23', 'freyja', 'child');
-- norse-gods-f24: Freyr + Gerd → Fjölnir
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f24', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f24', 'freyr', 'parent'),
    ('norse-gods', 'norse-gods-f24', 'gerd', 'parent'),
    ('norse-gods', 'norse-gods-f24', 'fjolnir', 'child');
-- norse-gods-f25: Fjölnir → Ynglingatal
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f25', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f25', 'fjolnir', 'parent'),
    ('norse-gods', 'norse-gods-f25', 'ynglingatal', 'child');
-- norse-gods-f26: Ægir + Aurboða → Beli, Gerd
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f26', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f26', 'gir', 'parent'),
    ('norse-gods', 'norse-gods-f26', 'aurbo-a', 'parent'),
    ('norse-gods', 'norse-gods-f26', 'beli', 'child'),
    ('norse-gods', 'norse-gods-f26', 'gerd', 'child');
-- norse-gods-f27: Bragi + Iðunn (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f27', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f27', 'bragi', 'parent'),
    ('norse-gods', 'norse-gods-f27', 'i-unn', 'parent');
-- norse-gods-f28: Annar + Nótt → Jörð
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f28', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f28', 'annar', 'parent'),
    ('norse-gods', 'norse-gods-f28', 'nott', 'parent'),
    ('norse-gods', 'norse-gods-f28', 'jor', 'child');
-- norse-gods-f29: Narfi → Nótt
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f29', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f29', 'narfi', 'parent'),
    ('norse-gods', 'norse-gods-f29', 'nott', 'child');
-- norse-gods-f30: Loki + Sigyn → Narfi, Váli
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f30', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f30', 'loki', 'parent'),
    ('norse-gods', 'norse-gods-f30', 'sigyn', 'parent'),
    ('norse-gods', 'norse-gods-f30', 'narfi', 'child'),
    ('norse-gods', 'norse-gods-f30', 'vali', 'child');
-- norse-gods-f31: Ægir + Rán → Bára, Blóðughadda, Bylgja, Dúfa, Hefring, Himinglæva, Hrönn, Kólga, Unnr
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f31', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f31', 'gir', 'parent'),
    ('norse-gods', 'norse-gods-f31', 'ran', 'parent'),
    ('norse-gods', 'norse-gods-f31', 'bara', 'child'),
    ('norse-gods', 'norse-gods-f31', 'blo-ughadda', 'child'),
    ('norse-gods', 'norse-gods-f31', 'bylgja', 'child'),
    ('norse-gods', 'norse-gods-f31', 'dufa', 'child'),
    ('norse-gods', 'norse-gods-f31', 'hefring', 'child'),
    ('norse-gods', 'norse-gods-f31', 'himingl-va', 'child'),
    ('norse-gods', 'norse-gods-f31', 'hronn', 'child'),
    ('norse-gods', 'norse-gods-f31', 'kolga', 'child'),
    ('norse-gods', 'norse-gods-f31', 'unnr', 'child');
-- norse-gods-f32: Fornjót → Ægir, Logi, Kári
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f32', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f32', 'fornjot', 'parent'),
    ('norse-gods', 'norse-gods-f32', 'gir', 'child'),
    ('norse-gods', 'norse-gods-f32', 'logi', 'child'),
    ('norse-gods', 'norse-gods-f32', 'kari', 'child');
-- norse-gods-f33: Delling + Nótt → Dagr
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f33', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f33', 'delling', 'parent'),
    ('norse-gods', 'norse-gods-f33', 'nott', 'parent'),
    ('norse-gods', 'norse-gods-f33', 'dagr', 'child');
-- norse-gods-f34: Naglfari + Nótt → Auðr
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f34', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f34', 'naglfari', 'parent'),
    ('norse-gods', 'norse-gods-f34', 'nott', 'parent'),
    ('norse-gods', 'norse-gods-f34', 'au-r', 'child');
-- norse-gods-f35: Auðr → Rich Girl
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f35', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f35', 'au-r', 'parent'),
    ('norse-gods', 'norse-gods-f35', 'rich-girl', 'child');
-- norse-gods-f36: Visbur + Rich Girl (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f36', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f36', 'visbur', 'parent'),
    ('norse-gods', 'norse-gods-f36', 'rich-girl', 'parent');
-- norse-gods-f37: Thor + Sif → Þrúðr, Móði
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f37', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f37', 'thor', 'parent'),
    ('norse-gods', 'norse-gods-f37', 'sif', 'parent'),
    ('norse-gods', 'norse-gods-f37', 'ru-r', 'child'),
    ('norse-gods', 'norse-gods-f37', 'mo-i', 'child');
-- norse-gods-f38: Thor + Járnsaxa → Magni
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f38', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f38', 'thor', 'parent'),
    ('norse-gods', 'norse-gods-f38', 'jarnsaxa', 'parent'),
    ('norse-gods', 'norse-gods-f38', 'magni', 'child');
-- norse-gods-f39: Unknown + Sif → Ullr
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f39', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f39', 'unknown-2', 'parent'),
    ('norse-gods', 'norse-gods-f39', 'sif', 'parent'),
    ('norse-gods', 'norse-gods-f39', 'ullr', 'child');
-- norse-gods-f40: Óðr + Freyja → Hnoss, Gersemi
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f40', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f40', 'o-r', 'parent'),
    ('norse-gods', 'norse-gods-f40', 'freyja', 'parent'),
    ('norse-gods', 'norse-gods-f40', 'hnoss', 'child'),
    ('norse-gods', 'norse-gods-f40', 'gersemi', 'child');
-- norse-gods-f41: Odin → Hermod, Heimdall
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f41', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f41', 'odin', 'parent'),
    ('norse-gods', 'norse-gods-f41', 'hermod', 'child'),
    ('norse-gods', 'norse-gods-f41', 'heimdall', 'child');
-- norse-gods-f42: Mundilfari + Glaur → Sowilo, Sunna, Máni
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f42', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f42', 'mundilfari', 'parent'),
    ('norse-gods', 'norse-gods-f42', 'glaur', 'parent'),
    ('norse-gods', 'norse-gods-f42', 'sowilo', 'child'),
    ('norse-gods', 'norse-gods-f42', 'sunna', 'child'),
    ('norse-gods', 'norse-gods-f42', 'mani', 'child');
-- norse-gods-f43: All the Male God's Saliva + All the Female God's Saliva → Kvasir
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f43', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f43', 'all-the-male-god-s-saliva', 'parent'),
    ('norse-gods', 'norse-gods-f43', 'all-the-female-god-s-saliva', 'parent'),
    ('norse-gods', 'norse-gods-f43', 'kvasir', 'child');
-- norse-gods-f44: Gilling + Gilling's Wife → Suttungr
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f44', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f44', 'gilling', 'parent'),
    ('norse-gods', 'norse-gods-f44', 'gilling-s-wife', 'parent'),
    ('norse-gods', 'norse-gods-f44', 'suttungr', 'child');
-- norse-gods-f45: Gilling + Unknown → Baugi
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f45', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f45', 'gilling', 'parent'),
    ('norse-gods', 'norse-gods-f45', 'unknown-3', 'parent'),
    ('norse-gods', 'norse-gods-f45', 'baugi', 'child');
-- norse-gods-f46: Suttungr → Gunnlöð
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f46', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f46', 'suttungr', 'parent'),
    ('norse-gods', 'norse-gods-f46', 'gunnlo', 'child');
-- norse-gods-f47: Fjalar (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f47', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f47', 'fjalar', 'parent');
-- norse-gods-f48: Galar (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f48', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f48', 'galar', 'parent');
-- norse-gods-f49: Gefjun (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f49', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f49', 'gefjun', 'parent');
-- norse-gods-f50: Lofn (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f50', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f50', 'lofn', 'parent');
-- norse-gods-f51: Sága (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f51', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f51', 'saga', 'parent');
-- norse-gods-f52: Seaxneat (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f52', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f52', 'seaxneat', 'parent');
-- norse-gods-f53: Sjöfn (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f53', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f53', 'sjofn', 'parent');
-- norse-gods-f54: Skirnir (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f54', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f54', 'skirnir', 'parent');
-- norse-gods-f55: Skuld (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f55', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f55', 'skuld', 'parent');
-- norse-gods-f56: Vár (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f56', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f56', 'var', 'parent');
-- norse-gods-f57: Verdandi (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f57', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f57', 'verdandi', 'parent');
-- norse-gods-f58: Vör (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f58', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f58', 'vor', 'parent');
-- norse-gods-f59: Wyrd (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('norse-gods', 'norse-gods-f59', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('norse-gods', 'norse-gods-f59', 'wyrd', 'parent');


-- =================================================================================================
-- SAGA 14 of 17: ROMAN GODS   [id: roman-gods, category: mythology]
-- Author:  Unknown compiler
-- Medium:  GEDCOM genealogy (Roman+Gods.ged)
-- Canon:   As recorded in the GEDCOM file
-- Covers:  322 people and 165 families, imported from a public GEDCOM sample.
-- Rows:    1 houses, 322 people, 165 families, 508 members
-- =================================================================================================

-- ── Reset (removes this saga and, by cascade, all of its rows) ─────────────────────────────────
DELETE FROM saga WHERE id = 'roman-gods';

-- ── Saga ───────────────────────────────────────────────────────────────────────────────────────
INSERT INTO saga (id, category, position, title, work, medium, author, canon, genre, covers) VALUES
    ('roman-gods', 'mythology', 13, 'Roman Gods', 'Roman Gods', 'GEDCOM genealogy (Roman+Gods.ged)', 'Unknown compiler', 'As recorded in the GEDCOM file', 'Mythology', '322 people and 165 families, imported from a public GEDCOM sample.');

-- ── Notes (modelling choices and where sources disagree) ───────────────────────────────────────
INSERT INTO saga_note (saga_id, position, note) VALUES
    ('roman-gods', 0, 'Imported from Roman+Gods.ged (Windows-1252; FTM Family Tree Maker (17.0.0.440); file dated 19 November 2007) by scripts/gedcom-to-saga.mts.'),
    ('roman-gods', 1, 'Names are read in mythology mode: the deity''s name is the GEDCOM surname part, and descriptive text in the given-name part (e.g. "queen of the Gods") is dropped.'),
    ('roman-gods', 2, 'Everyone is in one house, "Roman pantheon": the file has no real surnames to group by.'),
    ('roman-gods', 3, '2 people have no recorded relatives in the source and are shown on their own: Honos, Virtus.'),
    ('roman-gods', 4, 'Import warnings: Achaeus: sex not recorded as M or F, shown as male; Aesimus: sex not recorded as M or F, shown as male; Amulius: sex not recorded as M or F, shown as male; Antevorta: sex not recorded as M or F, shown as male; Aratus: sex not recorded as M or F, shown as male; Bellerophon: sex not recorded as M or F, shown as male; Brutus of Britain: sex not recorded as M or F, shown as male; Cadmus: sex not recorded as M or F, shown as male; Carmenta: sex not recorded as M or F, shown as male; Carystus.: sex not recorded as M or F, shown as male; Dardanus: sex not recorded as M or F, shown as male; Deidameia: sex not recorded as M or F, shown as male; Egeria: sex not recorded as M or F, shown as male; Electra: sex not recorded as M or F, shown as male; Endeis: sex not recorded as M or F, shown as male; Epimetheus: sex not recorded as M or F, shown as male; Erichtonius: sex not recorded as M or F, shown as male; Eurypylus: sex not recorded as M or F, shown as male; Ganymede: sex not recorded as M or F, shown as male; Gigantes: sex not recorded as M or F, shown as male; Gorgorphone: sex not recorded as M or F, shown as male; Harmonia: sex not recorded as M or F, shown as male; Hellen: sex not recorded as M or F, shown as male; Herulus: sex not recorded as M or F, shown as male; Hippe: sex not recorded as M or F, shown as male; Hyades: sex not recorded as M or F, shown as male; Icarius: sex not recorded as M or F, shown as male; II Lares: sex not recorded as M or F, shown as male; The Lares: sex not recorded as M or F, shown as male; Lavinia: sex not recorded as M or F, shown as male; Libera: sex not recorded as M or F, shown as male; Maia: sex not recorded as M or F, shown as male; Makedon: sex not recorded as M or F, shown as male; The Manes: sex not recorded as M or F, shown as male; The Minyas: sex not recorded as M or F, shown as male; Nox: sex not recorded as M or F, shown as male; Lydian nymphs: sex not recorded as M or F, shown as male; Ocyrhoe: sex not recorded as M or F, shown as male; Pallas: sex not recorded as M or F, shown as male; Panacea: sex not recorded as M or F, shown as male; Pandora: sex not recorded as M or F, shown as male; Pax: sex not recorded as M or F, shown as male; Penelope: sex not recorded as M or F, shown as male; Perimede: sex not recorded as M or F, shown as male; Perleres: sex not recorded as M or F, shown as male; Picumnus: sex not recorded as M or F, shown as male; Pleiades: sex not recorded as M or F, shown as male; Postvorta: sex not recorded as M or F, shown as male; Prometheus: sex not recorded as M or F, shown as male; Salus: sex not recorded as M or F, shown as male; Sarpedon: sex not recorded as M or F, shown as male; Sinon: sex not recorded as M or F, shown as male; 49 Other Sons: sex not recorded as M or F, shown as male; Stimula: sex not recorded as M or F, shown as male; Tenes: sex not recorded as M or F, shown as male; 3000 Rivers (Sons of Oceanus and Tethys): sex not recorded as M or F, shown as male; Thestius: sex not recorded as M or F, shown as male; Tiresias: sex not recorded as M or F, shown as male; Trivia: sex not recorded as M or F, shown as male; Tros: sex not recorded as M or F, shown as male; Unknown: sex not recorded as M or F, shown as male; Virtue: sex not recorded as M or F, shown as male; Virtus: sex not recorded as M or F, shown as male');

-- ── Houses (1) ─────────────────────────────────────────────────────────────────────────────────
INSERT INTO house (saga_id, name, color) VALUES
    ('roman-gods', 'Roman pantheon', '#c8102e');

-- ── People (322, grouped by house) ─────────────────────────────────────────────────────────────
-- Roman pantheon (322)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('roman-gods', 'jupiter', 'Jupiter', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'unnamed-daughter', '(unnamed daughter)', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'abrota', 'Abrota', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'aceso', 'Aceso', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'achaeus', 'Achaeus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'achilles', 'Achilles', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'achiroe', 'Achiroe', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'acis', 'Acis', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'aegeus', 'Aegeus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'aegyptus', 'Aegyptus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'aeneas', 'Aeneas', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'aesculapius', 'Aesculapius', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'aesimus', 'Aesimus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'aglaea', 'Aglaea', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'agrippa', 'Agrippa', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'ajax', 'Ajax', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'alba', 'Alba', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'alcmene', 'Alcmene', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'alexiares', 'Alexiares', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'almon', 'Almon', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'amata', 'Amata', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'amphithea', 'Amphithea', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'amulius', 'Amulius', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'anchises', 'Anchises', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'anicetus', 'Anicetus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'antevorta', 'Antevorta', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'anticlea', 'Anticlea', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'anton', 'Anton', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'apollo', 'Apollo', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'aquilo', 'Aquilo', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'aratus', 'Aratus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'arcesius', 'Arcesius', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'aricia', 'Aricia', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'aristodama', 'Aristodama', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'ascanius', 'Ascanius', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'asopus', 'Asopus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'asteria', 'Asteria', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'astraeus', 'Astraeus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'astyoche', 'Astyoche', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'ate', 'Ate', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'atlas', 'Atlas', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'atys', 'Atys', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'aurora', 'Aurora', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'auster', 'Auster', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'autolycus', 'Autolycus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'aventinus', 'Aventinus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'olus', 'Æolus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'bacchus', 'Bacchus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'bellerophon', 'Bellerophon', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'bellona', 'Bellona', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'belus', 'Belus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'bia', 'Bia', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'brutus-of-britain', 'Brutus of Britain', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'caca', 'Caca', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'cacus', 'Cacus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'cadmus', 'Cadmus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'caelus', 'Caelus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'caliadne', 'Caliadne', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'capetus', 'Capetus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'capys', 'Capys', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'carmenta', 'Carmenta', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'carmenta-2', 'Carmenta', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'carystus', 'Carystus.', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'cephalus', 'Cephalus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'ceres', 'Ceres', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'chaos', 'Chaos', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'chariclo', 'Chariclo', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'charopus', 'Charopus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'chione', 'Chione', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'chiron', 'Chiron', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'chryse', 'Chryse', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'cleopatra', 'Cleopatra', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'clitunno', 'Clitunno', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'clymene', 'Clymene', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'clymene-2', 'Clymene', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'clytius', 'Clytius', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'coronis', 'Coronis', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'cratos', 'Cratos', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'creusa', 'Creusa', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'crius', 'Crius', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'cupid', 'Cupid', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'cychreus', 'Cychreus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'cycnus', 'Cycnus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'danaus', 'Danaus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'daphne', 'Daphne', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'dardanus', 'Dardanus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'decima', 'Decima', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'deianira', 'Deianira', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'deidameia', 'Deidameia', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'deidamia', 'Deidamia', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'deioneus', 'Deioneus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'deliades', 'Deliades', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'deucalion', 'Deucalion', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'deucalion-2', 'Deucalion', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'diana', 'Diana', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'dione', 'Dione', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'discordia', 'Discordia', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'discordia-2', 'Discordia', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'dolops', 'Dolops', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'doris', 'Doris', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'dorus', 'Dorus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'egeria', 'Egeria', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'eileithya', 'Eileithya', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'electra', 'Electra', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'endeis', 'Endeis', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'eos', 'Eos', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'epimetheus', 'Epimetheus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'epione', 'Epione', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'erichtonius', 'Erichtonius', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'eros', 'Eros', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'eurybia', 'Eurybia', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'eurynome', 'Eurynome', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'eurypylus', 'Eurypylus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'evander', 'Evander', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'everes', 'Everes', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'fama', 'Fama', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'fauna', 'Fauna', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'faunus', 'Faunus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'faustulus', 'Faustulus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'favonius', 'Favonius', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'feronia', 'Feronia', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'fontus', 'Fontus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'ganymede', 'Ganymede', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'gigantes', 'Gigantes', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'glaucus', 'Glaucus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'glaucus-2', 'Glaucus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'gorgorphone', 'Gorgorphone', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'graecus', 'Graecus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'harmonia', 'Harmonia', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'helen', 'Helen', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'hellen', 'Hellen', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'hemithea', 'Hemithea', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'hercules', 'Hercules', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'hermione', 'Hermione', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'hermus', 'Hermus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'hermus-2', 'Hermus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'hersilia', 'Hersilia', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'herulus', 'Herulus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'hesione', 'Hesione', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'hicetaon', 'Hicetaon', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'hippasus', 'Hippasus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'hippe', 'Hippe', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'honos', 'Honos', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'hyades', 'Hyades', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'hyperion', 'Hyperion', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'hypermnestra', 'Hypermnestra', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'iapetus', 'Iapetus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'iaso', 'Iaso', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'icarius', 'Icarius', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'ilus', 'Ilus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'iphiclus', 'Iphiclus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'iustitia', 'Iustitia', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'janus', 'Janus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'juno', 'Juno', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'justitia', 'Justitia', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'juturna', 'Juturna', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'juventas', 'Juventas', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'ladon', 'Ladon', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'laertes', 'Laertes', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'lampus', 'Lampus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'laodamia', 'Laodamia', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'laomedon', 'Laomedon', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'lara', 'Lara', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'acca-larentia', 'Acca Larentia', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'lares-i', 'Lares I', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'lares-ii', 'Lares II', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'the-lares', 'The Lares', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'latinus', 'Latinus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'latinus-2', 'Latinus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'latona', 'Latona', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'lavinia', 'Lavinia', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'leda', 'Leda', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'leucippe', 'Leucippe', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'libera', 'Libera', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'lucifer', 'Lucifer', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'luna', 'Luna', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'lycus', 'Lycus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'lynceus', 'Lynceus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'machaon', 'Machaon', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'magnetas', 'Magnetas', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'maia', 'Maia', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'makedon', 'Makedon', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'the-manes', 'The Manes', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'mania', 'Mania', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'mantus', 'Mantus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'marica', 'Marica', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'mars', 'Mars', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'meditrina', 'Meditrina', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'medusa', 'Medusa', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'megara', 'Megara', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'melanippus', 'Melanippus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'menelaus', 'Menelaus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'mercury', 'Mercury', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'metis', 'Metis', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'metope', 'Metope', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'minerva', 'Minerva', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'minyas', 'Minyas', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'the-minyas', 'The Minyas', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'moneta', 'Moneta', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'mors', 'Mors', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'morta', 'Morta', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'neoptolemus', 'Neoptolemus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'neptune', 'Neptune', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'neures', 'Neures', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'nireus', 'Nireus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'nisos', 'Nisos', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'nona', 'Nona', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'nox', 'Nox', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'numitor', 'Numitor', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'lydian-nymphs', 'Lydian nymphs', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'oceanus', 'Oceanus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'ocyrhoe', 'Ocyrhoe', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'oebalus', 'Oebalus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'ops', 'Ops', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'orion', 'Orion', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'orseis', 'Orseis', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'pallas', 'Pallas', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'pallas-2', 'Pallas', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'pallas-3', 'Pallas', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'panacea', 'Panacea', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'pandion-ii', 'Pandion II', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'pandora', 'Pandora', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'pandora-2', 'Pandora', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'pax', 'Pax', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'pegasus', 'Pegasus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'peleus', 'Peleus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'penelope', 'Penelope', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'penia', 'Penia', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'periboea', 'Periboea', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'perimede', 'Perimede', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'perleres', 'Perleres', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'philyra', 'Philyra', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'phlegyas', 'Phlegyas', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'phoebe', 'Phoebe', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'phylacus', 'Phylacus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'picumnus', 'Picumnus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'pleiades', 'Pleiades', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'pluto', 'Pluto', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'podalirius', 'Podalirius', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'polus', 'Polus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'polydueces', 'Polydueces', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'polyphemus', 'Polyphemus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'polyxo', 'Polyxo', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'pomona', 'Pomona', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'pontus', 'Pontus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'porus', 'Porus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'postvorta', 'Postvorta', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'priam', 'Priam', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'procas', 'Procas', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'proclia', 'Proclia', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'prometheus', 'Prometheus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'prometheus-2', 'Prometheus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'pronoia', 'Pronoia', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'proserpina', 'Proserpina', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'psyche', 'Psyche', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'pyrrha', 'Pyrrha', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'pyrrha-2', 'Pyrrha', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'remus', 'Remus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'robigo', 'Robigo', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'robigus', 'Robigus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'kings-of-rome', 'Kings of Rome', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'romulus', 'Romulus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'salacia', 'Salacia', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'salamis', 'Salamis', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'salus', 'Salus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'sarpedon', 'Sarpedon', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'saturn', 'Saturn', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'rhea-silvia', 'Rhea Silvia', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'silvius', 'Silvius', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'silvius-2', 'Silvius', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'aeneas-silvius', 'Aeneas Silvius', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'latinus-silvius', 'Latinus Silvius', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'romulus-silvius', 'Romulus Silvius', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'tiberinus-silvius', 'Tiberinus Silvius', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'sinon', 'Sinon', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'sisyphus', 'Sisyphus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'sol', 'Sol', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'somnus', 'Somnus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'sons', 'Sons', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'statanus', 'Statanus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'statina', 'Statina', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'stilbe', 'Stilbe', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'stimula', 'Stimula', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'strymo', 'Strymo', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'symaethis', 'Symaethis', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'telamon', 'Telamon', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'telemachus', 'Telemachus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'telephus', 'Telephus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'telesphorus', 'Telesphorus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'tellus', 'Tellus', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'tenes', 'Tenes', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'tethys', 'Tethys)', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'tethys-2', 'Tethys', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'teucer', 'Teucer', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'thea', 'Thea', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'thestius', 'Thestius', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'thetis', 'Thetis', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'tiberinus', 'Tiberinus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'tiresias', 'Tiresias', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'tithonus', 'Tithonus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'triton', 'Triton', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'trivia', 'Trivia', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'tros', 'Tros', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'turnus', 'Turnus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'ulysses', 'Ulysses', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'unknown', 'Unknown', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'unknown-2', 'Unknown', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'unknown-3', 'Unknown', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'unknown-4', 'Unknown', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'venus', 'Venus', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'veritas', 'Veritas', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'vertumnus', 'Vertumnus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'vesta', 'Vesta', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'victoria', 'Victoria', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'virbius', 'Virbius', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'virtue', 'Virtue', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'virtus', 'Virtus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'volupta', 'Volupta', 'Roman pantheon', 'f', NULL),
    ('roman-gods', 'vulcan', 'Vulcan', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'vulturnus', 'Vulturnus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'xuthus', 'Xuthus', 'Roman pantheon', 'm', NULL),
    ('roman-gods', 'zelus', 'Zelus', 'Roman pantheon', 'm', NULL);

-- ── Families (165, each followed by its members) ───────────────────────────────────────────────
-- roman-gods-f1: (unnamed daughter) (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f1', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f1', 'unnamed-daughter', 'parent');
-- roman-gods-f2: (parents unknown) → (unnamed daughter)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f2', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f2', 'unnamed-daughter', 'child');
-- roman-gods-f3: (parents unknown) → Anchises
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f3', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f3', 'anchises', 'child');
-- roman-gods-f4: Anchises + Venus → Aeneas
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f4', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f4', 'anchises', 'parent'),
    ('roman-gods', 'roman-gods-f4', 'venus', 'parent'),
    ('roman-gods', 'roman-gods-f4', 'aeneas', 'child');
-- roman-gods-f5: Numitor → Rhea Silvia
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f5', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f5', 'numitor', 'parent'),
    ('roman-gods', 'roman-gods-f5', 'rhea-silvia', 'child');
-- roman-gods-f6: Tiberinus + Rhea Silvia (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f6', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f6', 'tiberinus', 'parent'),
    ('roman-gods', 'roman-gods-f6', 'rhea-silvia', 'parent');
-- roman-gods-f7: Aeneas + Creusa → Ascanius
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f7', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f7', 'aeneas', 'parent'),
    ('roman-gods', 'roman-gods-f7', 'creusa', 'parent'),
    ('roman-gods', 'roman-gods-f7', 'ascanius', 'child');
-- roman-gods-f8: (unnamed daughter) (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f8', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f8', 'unnamed-daughter', 'parent');
-- roman-gods-f9: Jupiter + Dione (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f9', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f9', 'jupiter', 'parent'),
    ('roman-gods', 'roman-gods-f9', 'dione', 'parent');
-- roman-gods-f10: Mars + Venus → Harmonia
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f10', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f10', 'mars', 'parent'),
    ('roman-gods', 'roman-gods-f10', 'venus', 'parent'),
    ('roman-gods', 'roman-gods-f10', 'harmonia', 'child');
-- roman-gods-f11: Vulcan + Venus → Cacus, Caca
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f11', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f11', 'vulcan', 'parent'),
    ('roman-gods', 'roman-gods-f11', 'venus', 'parent'),
    ('roman-gods', 'roman-gods-f11', 'cacus', 'child'),
    ('roman-gods', 'roman-gods-f11', 'caca', 'child');
-- roman-gods-f12: Jupiter + Juno → Vulcan, Juventas, Eileithya, Bellona, Mars
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f12', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f12', 'jupiter', 'parent'),
    ('roman-gods', 'roman-gods-f12', 'juno', 'parent'),
    ('roman-gods', 'roman-gods-f12', 'vulcan', 'child'),
    ('roman-gods', 'roman-gods-f12', 'juventas', 'child'),
    ('roman-gods', 'roman-gods-f12', 'eileithya', 'child'),
    ('roman-gods', 'roman-gods-f12', 'bellona', 'child'),
    ('roman-gods', 'roman-gods-f12', 'mars', 'child');
-- roman-gods-f13: Neoptolemus + (unnamed daughter) (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f13', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f13', 'neoptolemus', 'parent'),
    ('roman-gods', 'roman-gods-f13', 'unnamed-daughter', 'parent');
-- roman-gods-f14: Jupiter + Discordia → Ate
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f14', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f14', 'jupiter', 'parent'),
    ('roman-gods', 'roman-gods-f14', 'discordia', 'parent'),
    ('roman-gods', 'roman-gods-f14', 'ate', 'child');
-- roman-gods-f15: Hercules + Megara (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f15', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f15', 'hercules', 'parent'),
    ('roman-gods', 'roman-gods-f15', 'megara', 'parent');
-- roman-gods-f16: Hercules + Deianira (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f16', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f16', 'hercules', 'parent'),
    ('roman-gods', 'roman-gods-f16', 'deianira', 'parent');
-- roman-gods-f17: Hercules + Juventas → Anton, Alexiares, Anicetus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f17', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f17', 'hercules', 'parent'),
    ('roman-gods', 'roman-gods-f17', 'juventas', 'parent'),
    ('roman-gods', 'roman-gods-f17', 'anton', 'child'),
    ('roman-gods', 'roman-gods-f17', 'alexiares', 'child'),
    ('roman-gods', 'roman-gods-f17', 'anicetus', 'child');
-- roman-gods-f18: Jupiter + Ceres → Proserpina
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f18', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f18', 'jupiter', 'parent'),
    ('roman-gods', 'roman-gods-f18', 'ceres', 'parent'),
    ('roman-gods', 'roman-gods-f18', 'proserpina', 'child');
-- roman-gods-f19: Pluto + Proserpina (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f19', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f19', 'pluto', 'parent'),
    ('roman-gods', 'roman-gods-f19', 'proserpina', 'parent');
-- roman-gods-f20: Saturn + Ops → Ceres, Juno, Pluto, Vesta, Jupiter, Veritas, Neptune
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f20', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f20', 'saturn', 'parent'),
    ('roman-gods', 'roman-gods-f20', 'ops', 'parent'),
    ('roman-gods', 'roman-gods-f20', 'ceres', 'child'),
    ('roman-gods', 'roman-gods-f20', 'juno', 'child'),
    ('roman-gods', 'roman-gods-f20', 'pluto', 'child'),
    ('roman-gods', 'roman-gods-f20', 'vesta', 'child'),
    ('roman-gods', 'roman-gods-f20', 'jupiter', 'child'),
    ('roman-gods', 'roman-gods-f20', 'veritas', 'child'),
    ('roman-gods', 'roman-gods-f20', 'neptune', 'child');
-- roman-gods-f21: Jupiter + Alcmene → Hercules
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f21', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f21', 'jupiter', 'parent'),
    ('roman-gods', 'roman-gods-f21', 'alcmene', 'parent'),
    ('roman-gods', 'roman-gods-f21', 'hercules', 'child');
-- roman-gods-f22: Alcmene (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f22', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f22', 'alcmene', 'parent');
-- roman-gods-f23: Caelus + Tellus → Saturn, Ops, Polus, Crius, Hyperion, Iapetus, Thea, Justitia, Phoebe, Moneta, Fama, Gigantes, Oceanus, Tethys
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f23', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f23', 'caelus', 'parent'),
    ('roman-gods', 'roman-gods-f23', 'tellus', 'parent'),
    ('roman-gods', 'roman-gods-f23', 'saturn', 'child'),
    ('roman-gods', 'roman-gods-f23', 'ops', 'child'),
    ('roman-gods', 'roman-gods-f23', 'polus', 'child'),
    ('roman-gods', 'roman-gods-f23', 'crius', 'child'),
    ('roman-gods', 'roman-gods-f23', 'hyperion', 'child'),
    ('roman-gods', 'roman-gods-f23', 'iapetus', 'child'),
    ('roman-gods', 'roman-gods-f23', 'thea', 'child'),
    ('roman-gods', 'roman-gods-f23', 'justitia', 'child'),
    ('roman-gods', 'roman-gods-f23', 'phoebe', 'child'),
    ('roman-gods', 'roman-gods-f23', 'moneta', 'child'),
    ('roman-gods', 'roman-gods-f23', 'fama', 'child'),
    ('roman-gods', 'roman-gods-f23', 'gigantes', 'child'),
    ('roman-gods', 'roman-gods-f23', 'oceanus', 'child'),
    ('roman-gods', 'roman-gods-f23', 'tethys-2', 'child');
-- roman-gods-f24: Neptune + Salacia → Triton
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f24', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f24', 'neptune', 'parent'),
    ('roman-gods', 'roman-gods-f24', 'salacia', 'parent'),
    ('roman-gods', 'roman-gods-f24', 'triton', 'child');
-- roman-gods-f25: Neptune + Medusa → Pegasus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f25', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f25', 'neptune', 'parent'),
    ('roman-gods', 'roman-gods-f25', 'medusa', 'parent'),
    ('roman-gods', 'roman-gods-f25', 'pegasus', 'child');
-- roman-gods-f26: Achilles + Deidamia → Neoptolemus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f26', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f26', 'achilles', 'parent'),
    ('roman-gods', 'roman-gods-f26', 'deidamia', 'parent'),
    ('roman-gods', 'roman-gods-f26', 'neoptolemus', 'child');
-- roman-gods-f27: Peleus + Thetis → Achilles
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f27', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f27', 'peleus', 'parent'),
    ('roman-gods', 'roman-gods-f27', 'thetis', 'parent'),
    ('roman-gods', 'roman-gods-f27', 'achilles', 'child');
-- roman-gods-f28: Neures + Doris → Thetis
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f28', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f28', 'neures', 'parent'),
    ('roman-gods', 'roman-gods-f28', 'doris', 'parent'),
    ('roman-gods', 'roman-gods-f28', 'thetis', 'child');
-- roman-gods-f29: Pontus + Tellus → Neures
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f29', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f29', 'pontus', 'parent'),
    ('roman-gods', 'roman-gods-f29', 'tellus', 'parent'),
    ('roman-gods', 'roman-gods-f29', 'neures', 'child');
-- roman-gods-f30: Oceanus + Tethys → Doris, Clitunno, Tethys), Tiberinus, Hermus, Daphne, Ladon
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f30', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f30', 'oceanus', 'parent'),
    ('roman-gods', 'roman-gods-f30', 'tethys-2', 'parent'),
    ('roman-gods', 'roman-gods-f30', 'doris', 'child'),
    ('roman-gods', 'roman-gods-f30', 'clitunno', 'child'),
    ('roman-gods', 'roman-gods-f30', 'tethys', 'child'),
    ('roman-gods', 'roman-gods-f30', 'tiberinus', 'child'),
    ('roman-gods', 'roman-gods-f30', 'hermus', 'child'),
    ('roman-gods', 'roman-gods-f30', 'daphne', 'child'),
    ('roman-gods', 'roman-gods-f30', 'ladon', 'child');
-- roman-gods-f31: Neoptolemus + Hermione (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f31', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f31', 'neoptolemus', 'parent'),
    ('roman-gods', 'roman-gods-f31', 'hermione', 'parent');
-- roman-gods-f32: Menelaus + Helen → Hermione
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f32', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f32', 'menelaus', 'parent'),
    ('roman-gods', 'roman-gods-f32', 'helen', 'parent'),
    ('roman-gods', 'roman-gods-f32', 'hermione', 'child');
-- roman-gods-f33: Jupiter + Leda → Helen, Polydueces
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f33', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f33', 'jupiter', 'parent'),
    ('roman-gods', 'roman-gods-f33', 'leda', 'parent'),
    ('roman-gods', 'roman-gods-f33', 'helen', 'child'),
    ('roman-gods', 'roman-gods-f33', 'polydueces', 'child');
-- roman-gods-f34: Leda (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f34', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f34', 'leda', 'parent');
-- roman-gods-f35: Discordia (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f35', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f35', 'discordia', 'parent');
-- roman-gods-f36: Jupiter + Metis → Minerva, Porus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f36', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f36', 'jupiter', 'parent'),
    ('roman-gods', 'roman-gods-f36', 'metis', 'parent'),
    ('roman-gods', 'roman-gods-f36', 'minerva', 'child'),
    ('roman-gods', 'roman-gods-f36', 'porus', 'child');
-- roman-gods-f37: Jupiter + Latona → Apollo, Diana
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f37', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f37', 'jupiter', 'parent'),
    ('roman-gods', 'roman-gods-f37', 'latona', 'parent'),
    ('roman-gods', 'roman-gods-f37', 'apollo', 'child'),
    ('roman-gods', 'roman-gods-f37', 'diana', 'child');
-- roman-gods-f38: Polus + Phoebe → Latona, Asteria
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f38', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f38', 'polus', 'parent'),
    ('roman-gods', 'roman-gods-f38', 'phoebe', 'parent'),
    ('roman-gods', 'roman-gods-f38', 'latona', 'child'),
    ('roman-gods', 'roman-gods-f38', 'asteria', 'child');
-- roman-gods-f39: Iapetus + Clymene → Atlas, Epimetheus, Prometheus, Prometheus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f39', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f39', 'iapetus', 'parent'),
    ('roman-gods', 'roman-gods-f39', 'clymene', 'parent'),
    ('roman-gods', 'roman-gods-f39', 'atlas', 'child'),
    ('roman-gods', 'roman-gods-f39', 'epimetheus', 'child'),
    ('roman-gods', 'roman-gods-f39', 'prometheus', 'child'),
    ('roman-gods', 'roman-gods-f39', 'prometheus-2', 'child');
-- roman-gods-f40: Atlas → Pleiades, Hyades
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f40', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f40', 'atlas', 'parent'),
    ('roman-gods', 'roman-gods-f40', 'pleiades', 'child'),
    ('roman-gods', 'roman-gods-f40', 'hyades', 'child');
-- roman-gods-f41: Epimetheus + Pandora → Pyrrha
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f41', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f41', 'epimetheus', 'parent'),
    ('roman-gods', 'roman-gods-f41', 'pandora', 'parent'),
    ('roman-gods', 'roman-gods-f41', 'pyrrha', 'child');
-- roman-gods-f42: Deucalion + Pyrrha → Hellen
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f42', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f42', 'deucalion', 'parent'),
    ('roman-gods', 'roman-gods-f42', 'pyrrha', 'parent'),
    ('roman-gods', 'roman-gods-f42', 'hellen', 'child');
-- roman-gods-f43: Hellen → Æolus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f43', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f43', 'hellen', 'parent'),
    ('roman-gods', 'roman-gods-f43', 'olus', 'child');
-- roman-gods-f44: Perleres + Gorgorphone → Deidameia
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f44', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f44', 'perleres', 'parent'),
    ('roman-gods', 'roman-gods-f44', 'gorgorphone', 'parent'),
    ('roman-gods', 'roman-gods-f44', 'deidameia', 'child');
-- roman-gods-f45: Oebalus + Gorgorphone → Icarius
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f45', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f45', 'oebalus', 'parent'),
    ('roman-gods', 'roman-gods-f45', 'gorgorphone', 'parent'),
    ('roman-gods', 'roman-gods-f45', 'icarius', 'child');
-- roman-gods-f46: Icarius → Penelope
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f46', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f46', 'icarius', 'parent'),
    ('roman-gods', 'roman-gods-f46', 'penelope', 'child');
-- roman-gods-f47: Deidameia → Thestius
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f47', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f47', 'deidameia', 'parent'),
    ('roman-gods', 'roman-gods-f47', 'thestius', 'child');
-- roman-gods-f48: Thestius → Leda
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f48', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f48', 'thestius', 'parent'),
    ('roman-gods', 'roman-gods-f48', 'leda', 'child');
-- roman-gods-f49: Ulysses + Penelope → Telemachus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f49', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f49', 'ulysses', 'parent'),
    ('roman-gods', 'roman-gods-f49', 'penelope', 'parent'),
    ('roman-gods', 'roman-gods-f49', 'telemachus', 'child');
-- roman-gods-f50: Pleiades → Electra, Maia
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f50', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f50', 'pleiades', 'parent'),
    ('roman-gods', 'roman-gods-f50', 'electra', 'child'),
    ('roman-gods', 'roman-gods-f50', 'maia', 'child');
-- roman-gods-f51: Electra + Jupiter → Dardanus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f51', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f51', 'electra', 'parent'),
    ('roman-gods', 'roman-gods-f51', 'jupiter', 'parent'),
    ('roman-gods', 'roman-gods-f51', 'dardanus', 'child');
-- roman-gods-f52: Dardanus → Erichtonius
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f52', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f52', 'dardanus', 'parent'),
    ('roman-gods', 'roman-gods-f52', 'erichtonius', 'child');
-- roman-gods-f53: Erichtonius → Tros
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f53', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f53', 'erichtonius', 'parent'),
    ('roman-gods', 'roman-gods-f53', 'tros', 'child');
-- roman-gods-f54: Tros → Ganymede, Ilus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f54', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f54', 'tros', 'parent'),
    ('roman-gods', 'roman-gods-f54', 'ganymede', 'child'),
    ('roman-gods', 'roman-gods-f54', 'ilus', 'child');
-- roman-gods-f55: Jupiter + Maia → Mercury
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f55', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f55', 'jupiter', 'parent'),
    ('roman-gods', 'roman-gods-f55', 'maia', 'parent'),
    ('roman-gods', 'roman-gods-f55', 'mercury', 'child');
-- roman-gods-f56: Harmonia + Cadmus → Stimula
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f56', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f56', 'harmonia', 'parent'),
    ('roman-gods', 'roman-gods-f56', 'cadmus', 'parent'),
    ('roman-gods', 'roman-gods-f56', 'stimula', 'child');
-- roman-gods-f57: Stimula → Bacchus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f57', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f57', 'stimula', 'parent'),
    ('roman-gods', 'roman-gods-f57', 'bacchus', 'child');
-- roman-gods-f58: Bacchus + Ceres → Libera
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f58', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f58', 'bacchus', 'parent'),
    ('roman-gods', 'roman-gods-f58', 'ceres', 'parent'),
    ('roman-gods', 'roman-gods-f58', 'libera', 'child');
-- roman-gods-f59: Apollo + Coronis → Aesculapius
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f59', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f59', 'apollo', 'parent'),
    ('roman-gods', 'roman-gods-f59', 'coronis', 'parent'),
    ('roman-gods', 'roman-gods-f59', 'aesculapius', 'child');
-- roman-gods-f60: Hyperion + Thea → Aurora, Sol, Luna, Eos
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f60', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f60', 'hyperion', 'parent'),
    ('roman-gods', 'roman-gods-f60', 'thea', 'parent'),
    ('roman-gods', 'roman-gods-f60', 'aurora', 'child'),
    ('roman-gods', 'roman-gods-f60', 'sol', 'child'),
    ('roman-gods', 'roman-gods-f60', 'luna', 'child'),
    ('roman-gods', 'roman-gods-f60', 'eos', 'child');
-- roman-gods-f61: Astraeus + Aurora → Aquilo, Auster, Vulturnus, Favonius, Lucifer
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f61', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f61', 'astraeus', 'parent'),
    ('roman-gods', 'roman-gods-f61', 'aurora', 'parent'),
    ('roman-gods', 'roman-gods-f61', 'aquilo', 'child'),
    ('roman-gods', 'roman-gods-f61', 'auster', 'child'),
    ('roman-gods', 'roman-gods-f61', 'vulturnus', 'child'),
    ('roman-gods', 'roman-gods-f61', 'favonius', 'child'),
    ('roman-gods', 'roman-gods-f61', 'lucifer', 'child');
-- roman-gods-f62: Mars + Bellona (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f62', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f62', 'mars', 'parent'),
    ('roman-gods', 'roman-gods-f62', 'bellona', 'parent');
-- roman-gods-f63: Jupiter + Venus → Cupid
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f63', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f63', 'jupiter', 'parent'),
    ('roman-gods', 'roman-gods-f63', 'venus', 'parent'),
    ('roman-gods', 'roman-gods-f63', 'cupid', 'child');
-- roman-gods-f64: Cupid + Psyche → Volupta
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f64', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f64', 'cupid', 'parent'),
    ('roman-gods', 'roman-gods-f64', 'psyche', 'parent'),
    ('roman-gods', 'roman-gods-f64', 'volupta', 'child');
-- roman-gods-f65: Chaos → Tellus, Nox
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f65', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f65', 'chaos', 'parent'),
    ('roman-gods', 'roman-gods-f65', 'tellus', 'child'),
    ('roman-gods', 'roman-gods-f65', 'nox', 'child');
-- roman-gods-f66: Jupiter + Iustitia → Pax
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f66', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f66', 'jupiter', 'parent'),
    ('roman-gods', 'roman-gods-f66', 'iustitia', 'parent'),
    ('roman-gods', 'roman-gods-f66', 'pax', 'child');
-- roman-gods-f67: Aesculapius + Epione → Salus, Meditrina, Panacea, Iaso, Aceso, Aglaea, Machaon, Podalirius, Telesphorus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f67', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f67', 'aesculapius', 'parent'),
    ('roman-gods', 'roman-gods-f67', 'epione', 'parent'),
    ('roman-gods', 'roman-gods-f67', 'salus', 'child'),
    ('roman-gods', 'roman-gods-f67', 'meditrina', 'child'),
    ('roman-gods', 'roman-gods-f67', 'panacea', 'child'),
    ('roman-gods', 'roman-gods-f67', 'iaso', 'child'),
    ('roman-gods', 'roman-gods-f67', 'aceso', 'child'),
    ('roman-gods', 'roman-gods-f67', 'aglaea', 'child'),
    ('roman-gods', 'roman-gods-f67', 'machaon', 'child'),
    ('roman-gods', 'roman-gods-f67', 'podalirius', 'child'),
    ('roman-gods', 'roman-gods-f67', 'telesphorus', 'child');
-- roman-gods-f68: Nox → Mors, Somnus, Discordia, Decima, Morta, Nona
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f68', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f68', 'nox', 'parent'),
    ('roman-gods', 'roman-gods-f68', 'mors', 'child'),
    ('roman-gods', 'roman-gods-f68', 'somnus', 'child'),
    ('roman-gods', 'roman-gods-f68', 'discordia-2', 'child'),
    ('roman-gods', 'roman-gods-f68', 'decima', 'child'),
    ('roman-gods', 'roman-gods-f68', 'morta', 'child'),
    ('roman-gods', 'roman-gods-f68', 'nona', 'child');
-- roman-gods-f69: Mercury + Carmenta → Faunus, Evander
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f69', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f69', 'mercury', 'parent'),
    ('roman-gods', 'roman-gods-f69', 'carmenta', 'parent'),
    ('roman-gods', 'roman-gods-f69', 'faunus', 'child'),
    ('roman-gods', 'roman-gods-f69', 'evander', 'child');
-- roman-gods-f70: Faunus + Marica → Fauna, Latinus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f70', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f70', 'faunus', 'parent'),
    ('roman-gods', 'roman-gods-f70', 'marica', 'parent'),
    ('roman-gods', 'roman-gods-f70', 'fauna', 'child'),
    ('roman-gods', 'roman-gods-f70', 'latinus-2', 'child');
-- roman-gods-f71: Evander → Pallas
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f71', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f71', 'evander', 'parent'),
    ('roman-gods', 'roman-gods-f71', 'pallas', 'child');
-- roman-gods-f72: Mars + Rhea Silvia → Remus, Romulus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f72', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f72', 'mars', 'parent'),
    ('roman-gods', 'roman-gods-f72', 'rhea-silvia', 'parent'),
    ('roman-gods', 'roman-gods-f72', 'remus', 'child'),
    ('roman-gods', 'roman-gods-f72', 'romulus', 'child');
-- roman-gods-f73: Ilus → Laomedon
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f73', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f73', 'ilus', 'parent'),
    ('roman-gods', 'roman-gods-f73', 'laomedon', 'child');
-- roman-gods-f74: Laomedon + Strymo → Tithonus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f74', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f74', 'laomedon', 'parent'),
    ('roman-gods', 'roman-gods-f74', 'strymo', 'parent'),
    ('roman-gods', 'roman-gods-f74', 'tithonus', 'child');
-- roman-gods-f75: Laomedon + Leucippe → Priam, Astyoche, Lampus, Hicetaon, Clytius, Proclia, Hesione
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f75', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f75', 'laomedon', 'parent'),
    ('roman-gods', 'roman-gods-f75', 'leucippe', 'parent'),
    ('roman-gods', 'roman-gods-f75', 'priam', 'child'),
    ('roman-gods', 'roman-gods-f75', 'astyoche', 'child'),
    ('roman-gods', 'roman-gods-f75', 'lampus', 'child'),
    ('roman-gods', 'roman-gods-f75', 'hicetaon', 'child'),
    ('roman-gods', 'roman-gods-f75', 'clytius', 'child'),
    ('roman-gods', 'roman-gods-f75', 'proclia', 'child'),
    ('roman-gods', 'roman-gods-f75', 'hesione', 'child');
-- roman-gods-f76: Telephus + Astyoche → Eurypylus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f76', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f76', 'telephus', 'parent'),
    ('roman-gods', 'roman-gods-f76', 'astyoche', 'parent'),
    ('roman-gods', 'roman-gods-f76', 'eurypylus', 'child');
-- roman-gods-f77: Lampus → Dolops
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f77', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f77', 'lampus', 'parent'),
    ('roman-gods', 'roman-gods-f77', 'dolops', 'child');
-- roman-gods-f78: Hicetaon → Melanippus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f78', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f78', 'hicetaon', 'parent'),
    ('roman-gods', 'roman-gods-f78', 'melanippus', 'child');
-- roman-gods-f79: Cycnus + Proclia → Tenes, Hemithea
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f79', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f79', 'cycnus', 'parent'),
    ('roman-gods', 'roman-gods-f79', 'proclia', 'parent'),
    ('roman-gods', 'roman-gods-f79', 'tenes', 'child'),
    ('roman-gods', 'roman-gods-f79', 'hemithea', 'child');
-- roman-gods-f80: Telamon + Hesione → Teucer
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f80', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f80', 'telamon', 'parent'),
    ('roman-gods', 'roman-gods-f80', 'hesione', 'parent'),
    ('roman-gods', 'roman-gods-f80', 'teucer', 'child');
-- roman-gods-f81: Telamon + Periboea → Ajax
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f81', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f81', 'telamon', 'parent'),
    ('roman-gods', 'roman-gods-f81', 'periboea', 'parent'),
    ('roman-gods', 'roman-gods-f81', 'ajax', 'child');
-- roman-gods-f82: Caelus → Venus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f82', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f82', 'caelus', 'parent'),
    ('roman-gods', 'roman-gods-f82', 'venus', 'child');
-- roman-gods-f83: Mercury + Lara → Lares I, Lares II
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f83', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f83', 'mercury', 'parent'),
    ('roman-gods', 'roman-gods-f83', 'lara', 'parent'),
    ('roman-gods', 'roman-gods-f83', 'lares-i', 'child'),
    ('roman-gods', 'roman-gods-f83', 'lares-ii', 'child');
-- roman-gods-f84: Almon → Lara
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f84', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f84', 'almon', 'parent'),
    ('roman-gods', 'roman-gods-f84', 'lara', 'child');
-- roman-gods-f85: Unknown → Juturna, Turnus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f85', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f85', 'unknown', 'parent'),
    ('roman-gods', 'roman-gods-f85', 'juturna', 'child'),
    ('roman-gods', 'roman-gods-f85', 'turnus', 'child');
-- roman-gods-f86: Janus + Juturna → Fontus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f86', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f86', 'janus', 'parent'),
    ('roman-gods', 'roman-gods-f86', 'juturna', 'parent'),
    ('roman-gods', 'roman-gods-f86', 'fontus', 'child');
-- roman-gods-f87: Hercules + Acca Larentia (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f87', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f87', 'hercules', 'parent'),
    ('roman-gods', 'roman-gods-f87', 'acca-larentia', 'parent');
-- roman-gods-f88: Faustulus + Acca Larentia (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f88', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f88', 'faustulus', 'parent'),
    ('roman-gods', 'roman-gods-f88', 'acca-larentia', 'parent');
-- roman-gods-f89: Feronia → Herulus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f89', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f89', 'feronia', 'parent'),
    ('roman-gods', 'roman-gods-f89', 'herulus', 'child');
-- roman-gods-f90: Romulus + Hersilia → Kings of Rome
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f90', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f90', 'romulus', 'parent'),
    ('roman-gods', 'roman-gods-f90', 'hersilia', 'parent'),
    ('roman-gods', 'roman-gods-f90', 'kings-of-rome', 'child');
-- roman-gods-f91: Procas → Numitor
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f91', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f91', 'procas', 'parent'),
    ('roman-gods', 'roman-gods-f91', 'numitor', 'child');
-- roman-gods-f92: Aventinus → Procas
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f92', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f92', 'aventinus', 'parent'),
    ('roman-gods', 'roman-gods-f92', 'procas', 'child');
-- roman-gods-f93: Romulus Silvius → Aventinus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f93', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f93', 'romulus-silvius', 'parent'),
    ('roman-gods', 'roman-gods-f93', 'aventinus', 'child');
-- roman-gods-f94: Agrippa → Romulus Silvius
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f94', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f94', 'agrippa', 'parent'),
    ('roman-gods', 'roman-gods-f94', 'romulus-silvius', 'child');
-- roman-gods-f95: Tiberinus Silvius → Agrippa
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f95', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f95', 'tiberinus-silvius', 'parent'),
    ('roman-gods', 'roman-gods-f95', 'agrippa', 'child');
-- roman-gods-f96: Capetus → Tiberinus Silvius
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f96', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f96', 'capetus', 'parent'),
    ('roman-gods', 'roman-gods-f96', 'tiberinus-silvius', 'child');
-- roman-gods-f97: Capys → Capetus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f97', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f97', 'capys', 'parent'),
    ('roman-gods', 'roman-gods-f97', 'capetus', 'child');
-- roman-gods-f98: Atys → Capys
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f98', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f98', 'atys', 'parent'),
    ('roman-gods', 'roman-gods-f98', 'capys', 'child');
-- roman-gods-f99: Alba → Atys
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f99', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f99', 'alba', 'parent'),
    ('roman-gods', 'roman-gods-f99', 'atys', 'child');
-- roman-gods-f100: Latinus Silvius → Alba
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f100', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f100', 'latinus-silvius', 'parent'),
    ('roman-gods', 'roman-gods-f100', 'alba', 'child');
-- roman-gods-f101: Aeneas Silvius → Latinus Silvius
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f101', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f101', 'aeneas-silvius', 'parent'),
    ('roman-gods', 'roman-gods-f101', 'latinus-silvius', 'child');
-- roman-gods-f102: Silvius → Aeneas Silvius
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f102', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f102', 'silvius-2', 'parent'),
    ('roman-gods', 'roman-gods-f102', 'aeneas-silvius', 'child');
-- roman-gods-f103: Aeneas + Lavinia → Silvius, Amulius
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f103', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f103', 'aeneas', 'parent'),
    ('roman-gods', 'roman-gods-f103', 'lavinia', 'parent'),
    ('roman-gods', 'roman-gods-f103', 'silvius-2', 'child'),
    ('roman-gods', 'roman-gods-f103', 'amulius', 'child');
-- roman-gods-f104: Latinus → Lavinia
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f104', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f104', 'latinus', 'parent'),
    ('roman-gods', 'roman-gods-f104', 'lavinia', 'child');
-- roman-gods-f105: Ascanius → Silvius
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f105', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f105', 'ascanius', 'parent'),
    ('roman-gods', 'roman-gods-f105', 'silvius', 'child');
-- roman-gods-f106: Silvius → Brutus of Britain
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f106', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f106', 'silvius', 'parent'),
    ('roman-gods', 'roman-gods-f106', 'brutus-of-britain', 'child');
-- roman-gods-f107: Belus + Achiroe → Danaus, Aegyptus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f107', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f107', 'belus', 'parent'),
    ('roman-gods', 'roman-gods-f107', 'achiroe', 'parent'),
    ('roman-gods', 'roman-gods-f107', 'danaus', 'child'),
    ('roman-gods', 'roman-gods-f107', 'aegyptus', 'child');
-- roman-gods-f108: Danaus → Lynceus, Sons
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f108', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f108', 'danaus', 'parent'),
    ('roman-gods', 'roman-gods-f108', 'lynceus', 'child'),
    ('roman-gods', 'roman-gods-f108', 'sons', 'child');
-- roman-gods-f109: Lynceus + Hypermnestra (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f109', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f109', 'lynceus', 'parent'),
    ('roman-gods', 'roman-gods-f109', 'hypermnestra', 'parent');
-- roman-gods-f110: Unknown → Belus, Picumnus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f110', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f110', 'unknown-2', 'parent'),
    ('roman-gods', 'roman-gods-f110', 'belus', 'child'),
    ('roman-gods', 'roman-gods-f110', 'picumnus', 'child');
-- roman-gods-f111: Latinus + Amata → Lavinia
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f111', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f111', 'latinus-2', 'parent'),
    ('roman-gods', 'roman-gods-f111', 'amata', 'parent'),
    ('roman-gods', 'roman-gods-f111', 'lavinia', 'child');
-- roman-gods-f112: Porus + Penia → Eros
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f112', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f112', 'porus', 'parent'),
    ('roman-gods', 'roman-gods-f112', 'penia', 'parent'),
    ('roman-gods', 'roman-gods-f112', 'eros', 'child');
-- roman-gods-f113: Unknown → Robigus, Robigo
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f113', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f113', 'unknown-3', 'parent'),
    ('roman-gods', 'roman-gods-f113', 'robigus', 'child'),
    ('roman-gods', 'roman-gods-f113', 'robigo', 'child');
-- roman-gods-f114: Veritas → Virtue
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f114', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f114', 'veritas', 'parent'),
    ('roman-gods', 'roman-gods-f114', 'virtue', 'child');
-- roman-gods-f115: Vertumnus + Pomona (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f115', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f115', 'vertumnus', 'parent'),
    ('roman-gods', 'roman-gods-f115', 'pomona', 'parent');
-- roman-gods-f116: Virbius + Aricia (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f116', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f116', 'virbius', 'parent'),
    ('roman-gods', 'roman-gods-f116', 'aricia', 'parent');
-- roman-gods-f117: Pallas → Aricia
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f117', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f117', 'pallas-2', 'parent'),
    ('roman-gods', 'roman-gods-f117', 'aricia', 'child');
-- roman-gods-f118: Pandion II → Pallas, Aegeus, Nisos, Lycus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f118', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f118', 'pandion-ii', 'parent'),
    ('roman-gods', 'roman-gods-f118', 'pallas-2', 'child'),
    ('roman-gods', 'roman-gods-f118', 'aegeus', 'child'),
    ('roman-gods', 'roman-gods-f118', 'nisos', 'child'),
    ('roman-gods', 'roman-gods-f118', 'lycus', 'child');
-- roman-gods-f119: Nisos + Abrota → Eurynome
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f119', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f119', 'nisos', 'parent'),
    ('roman-gods', 'roman-gods-f119', 'abrota', 'parent'),
    ('roman-gods', 'roman-gods-f119', 'eurynome', 'child');
-- roman-gods-f120: Glaucus + Eurynome → Bellerophon, Deliades
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f120', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f120', 'glaucus', 'parent'),
    ('roman-gods', 'roman-gods-f120', 'eurynome', 'parent'),
    ('roman-gods', 'roman-gods-f120', 'bellerophon', 'child'),
    ('roman-gods', 'roman-gods-f120', 'deliades', 'child');
-- roman-gods-f121: Bellerophon → Unknown, Laodamia
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f121', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f121', 'bellerophon', 'parent'),
    ('roman-gods', 'roman-gods-f121', 'unknown-4', 'child'),
    ('roman-gods', 'roman-gods-f121', 'laodamia', 'child');
-- roman-gods-f122: Unknown → Glaucus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f122', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f122', 'unknown-4', 'parent'),
    ('roman-gods', 'roman-gods-f122', 'glaucus-2', 'child');
-- roman-gods-f123: Sisyphus → Glaucus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f123', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f123', 'sisyphus', 'parent'),
    ('roman-gods', 'roman-gods-f123', 'glaucus', 'child');
-- roman-gods-f124: Laodamia → Sarpedon
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f124', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f124', 'laodamia', 'parent'),
    ('roman-gods', 'roman-gods-f124', 'sarpedon', 'child');
-- roman-gods-f125: Faunus + Symaethis → Acis
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f125', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f125', 'faunus', 'parent'),
    ('roman-gods', 'roman-gods-f125', 'symaethis', 'parent'),
    ('roman-gods', 'roman-gods-f125', 'acis', 'child');
-- roman-gods-f126: Charopus + Aglaea → Nireus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f126', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f126', 'charopus', 'parent'),
    ('roman-gods', 'roman-gods-f126', 'aglaea', 'parent'),
    ('roman-gods', 'roman-gods-f126', 'nireus', 'child');
-- roman-gods-f127: Phlegyas → Coronis
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f127', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f127', 'phlegyas', 'parent'),
    ('roman-gods', 'roman-gods-f127', 'coronis', 'child');
-- roman-gods-f128: Aesculapius + Aristodama → Aratus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f128', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f128', 'aesculapius', 'parent'),
    ('roman-gods', 'roman-gods-f128', 'aristodama', 'parent'),
    ('roman-gods', 'roman-gods-f128', 'aratus', 'child');
-- roman-gods-f129: Hermus → Lydian nymphs
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f129', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f129', 'hermus', 'parent'),
    ('roman-gods', 'roman-gods-f129', 'lydian-nymphs', 'child');
-- roman-gods-f130: Aegyptus + Caliadne → Hermus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f130', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f130', 'aegyptus', 'parent'),
    ('roman-gods', 'roman-gods-f130', 'caliadne', 'parent'),
    ('roman-gods', 'roman-gods-f130', 'hermus-2', 'child');
-- roman-gods-f131: Hermus + Cleopatra (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f131', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f131', 'hermus-2', 'parent'),
    ('roman-gods', 'roman-gods-f131', 'cleopatra', 'parent');
-- roman-gods-f132: Danaus + Polyxo → Cleopatra
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f132', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f132', 'danaus', 'parent'),
    ('roman-gods', 'roman-gods-f132', 'polyxo', 'parent'),
    ('roman-gods', 'roman-gods-f132', 'cleopatra', 'child');
-- roman-gods-f133: Mantus + Mania → The Lares, The Manes
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f133', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f133', 'mantus', 'parent'),
    ('roman-gods', 'roman-gods-f133', 'mania', 'parent'),
    ('roman-gods', 'roman-gods-f133', 'the-lares', 'child'),
    ('roman-gods', 'roman-gods-f133', 'the-manes', 'child');
-- roman-gods-f134: Moneta → Egeria, Antevorta, Postvorta, Carmenta
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f134', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f134', 'moneta', 'parent'),
    ('roman-gods', 'roman-gods-f134', 'egeria', 'child'),
    ('roman-gods', 'roman-gods-f134', 'antevorta', 'child'),
    ('roman-gods', 'roman-gods-f134', 'postvorta', 'child'),
    ('roman-gods', 'roman-gods-f134', 'carmenta-2', 'child');
-- roman-gods-f135: Statanus + Statina (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f135', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f135', 'statanus', 'parent'),
    ('roman-gods', 'roman-gods-f135', 'statina', 'parent');
-- roman-gods-f136: Asteria → Trivia
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f136', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f136', 'asteria', 'parent'),
    ('roman-gods', 'roman-gods-f136', 'trivia', 'child');
-- roman-gods-f137: Crius + Eurybia → Astraeus, Pallas
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f137', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f137', 'crius', 'parent'),
    ('roman-gods', 'roman-gods-f137', 'eurybia', 'parent'),
    ('roman-gods', 'roman-gods-f137', 'astraeus', 'child'),
    ('roman-gods', 'roman-gods-f137', 'pallas-3', 'child');
-- roman-gods-f138: Pallas → Victoria, Zelus, Cratos, Bia
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f138', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f138', 'pallas-3', 'parent'),
    ('roman-gods', 'roman-gods-f138', 'victoria', 'child'),
    ('roman-gods', 'roman-gods-f138', 'zelus', 'child'),
    ('roman-gods', 'roman-gods-f138', 'cratos', 'child'),
    ('roman-gods', 'roman-gods-f138', 'bia', 'child');
-- roman-gods-f139: Mars + Chryse → Phlegyas
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f139', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f139', 'mars', 'parent'),
    ('roman-gods', 'roman-gods-f139', 'chryse', 'parent'),
    ('roman-gods', 'roman-gods-f139', 'phlegyas', 'child');
-- roman-gods-f140: Saturn + Philyra → Chiron
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f140', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f140', 'saturn', 'parent'),
    ('roman-gods', 'roman-gods-f140', 'philyra', 'parent'),
    ('roman-gods', 'roman-gods-f140', 'chiron', 'child');
-- roman-gods-f141: Oceanus (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f141', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f141', 'oceanus', 'parent');
-- roman-gods-f142: Chiron + Chariclo → Hippe, Endeis, Ocyrhoe, Carystus.
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f142', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f142', 'chiron', 'parent'),
    ('roman-gods', 'roman-gods-f142', 'chariclo', 'parent'),
    ('roman-gods', 'roman-gods-f142', 'hippe', 'child'),
    ('roman-gods', 'roman-gods-f142', 'endeis', 'child'),
    ('roman-gods', 'roman-gods-f142', 'ocyrhoe', 'child'),
    ('roman-gods', 'roman-gods-f142', 'carystus', 'child');
-- roman-gods-f143: Cychreus + Stilbe → Chariclo
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f143', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f143', 'cychreus', 'parent'),
    ('roman-gods', 'roman-gods-f143', 'stilbe', 'parent'),
    ('roman-gods', 'roman-gods-f143', 'chariclo', 'child');
-- roman-gods-f144: Everes + Chariclo → Tiresias
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f144', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f144', 'everes', 'parent'),
    ('roman-gods', 'roman-gods-f144', 'chariclo', 'parent'),
    ('roman-gods', 'roman-gods-f144', 'tiresias', 'child');
-- roman-gods-f145: Neptune + Salamis → Cychreus, Orion, Polyphemus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f145', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f145', 'neptune', 'parent'),
    ('roman-gods', 'roman-gods-f145', 'salamis', 'parent'),
    ('roman-gods', 'roman-gods-f145', 'cychreus', 'child'),
    ('roman-gods', 'roman-gods-f145', 'orion', 'child'),
    ('roman-gods', 'roman-gods-f145', 'polyphemus', 'child');
-- roman-gods-f146: Asopus + Metope → Salamis
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f146', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f146', 'asopus', 'parent'),
    ('roman-gods', 'roman-gods-f146', 'metope', 'parent'),
    ('roman-gods', 'roman-gods-f146', 'salamis', 'child');
-- roman-gods-f147: Ladon → Metope, Daphne
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f147', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f147', 'ladon', 'parent'),
    ('roman-gods', 'roman-gods-f147', 'metope', 'child'),
    ('roman-gods', 'roman-gods-f147', 'daphne', 'child');
-- roman-gods-f148: Laertes + Anticlea → Ulysses
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f148', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f148', 'laertes', 'parent'),
    ('roman-gods', 'roman-gods-f148', 'anticlea', 'parent'),
    ('roman-gods', 'roman-gods-f148', 'ulysses', 'child');
-- roman-gods-f149: Arcesius → Laertes
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f149', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f149', 'arcesius', 'parent'),
    ('roman-gods', 'roman-gods-f149', 'laertes', 'child');
-- roman-gods-f150: Cephalus + Clymene → Arcesius
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f150', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f150', 'cephalus', 'parent'),
    ('roman-gods', 'roman-gods-f150', 'clymene-2', 'parent'),
    ('roman-gods', 'roman-gods-f150', 'arcesius', 'child');
-- roman-gods-f151: Minyas → Clymene, The Minyas
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f151', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f151', 'minyas', 'parent'),
    ('roman-gods', 'roman-gods-f151', 'clymene-2', 'child'),
    ('roman-gods', 'roman-gods-f151', 'the-minyas', 'child');
-- roman-gods-f152: The Minyas → Hippasus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f152', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f152', 'the-minyas', 'parent'),
    ('roman-gods', 'roman-gods-f152', 'hippasus', 'child');
-- roman-gods-f153: Phylacus + Clymene → Iphiclus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f153', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f153', 'phylacus', 'parent'),
    ('roman-gods', 'roman-gods-f153', 'clymene-2', 'parent'),
    ('roman-gods', 'roman-gods-f153', 'iphiclus', 'child');
-- roman-gods-f154: Deioneus → Cephalus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f154', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f154', 'deioneus', 'parent'),
    ('roman-gods', 'roman-gods-f154', 'cephalus', 'child');
-- roman-gods-f155: Æolus → Deioneus, Perleres
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f155', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f155', 'olus', 'parent'),
    ('roman-gods', 'roman-gods-f155', 'deioneus', 'child'),
    ('roman-gods', 'roman-gods-f155', 'perleres', 'child');
-- roman-gods-f156: Hellen + Orseis → Æolus, Dorus, Xuthus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f156', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f156', 'hellen', 'parent'),
    ('roman-gods', 'roman-gods-f156', 'orseis', 'parent'),
    ('roman-gods', 'roman-gods-f156', 'olus', 'child'),
    ('roman-gods', 'roman-gods-f156', 'dorus', 'child'),
    ('roman-gods', 'roman-gods-f156', 'xuthus', 'child');
-- roman-gods-f157: Deucalion + Pyrrha → Pandora, Hellen
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f157', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f157', 'deucalion-2', 'parent'),
    ('roman-gods', 'roman-gods-f157', 'pyrrha-2', 'parent'),
    ('roman-gods', 'roman-gods-f157', 'pandora-2', 'child'),
    ('roman-gods', 'roman-gods-f157', 'hellen', 'child');
-- roman-gods-f158: Pandora → Graecus, Magnetas, Makedon
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f158', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f158', 'pandora-2', 'parent'),
    ('roman-gods', 'roman-gods-f158', 'graecus', 'child'),
    ('roman-gods', 'roman-gods-f158', 'magnetas', 'child'),
    ('roman-gods', 'roman-gods-f158', 'makedon', 'child');
-- roman-gods-f159: Xuthus → Achaeus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f159', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f159', 'xuthus', 'parent'),
    ('roman-gods', 'roman-gods-f159', 'achaeus', 'child');
-- roman-gods-f160: Prometheus + Pronoia → Deucalion
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f160', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f160', 'prometheus', 'parent'),
    ('roman-gods', 'roman-gods-f160', 'pronoia', 'parent'),
    ('roman-gods', 'roman-gods-f160', 'deucalion', 'child');
-- roman-gods-f161: Autolycus + Amphithea → Anticlea, Perimede, Aesimus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f161', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f161', 'autolycus', 'parent'),
    ('roman-gods', 'roman-gods-f161', 'amphithea', 'parent'),
    ('roman-gods', 'roman-gods-f161', 'anticlea', 'child'),
    ('roman-gods', 'roman-gods-f161', 'perimede', 'child'),
    ('roman-gods', 'roman-gods-f161', 'aesimus', 'child');
-- roman-gods-f162: Aesimus → Sinon
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f162', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f162', 'aesimus', 'parent'),
    ('roman-gods', 'roman-gods-f162', 'sinon', 'child');
-- roman-gods-f163: Mercury + Chione → Amphithea
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f163', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f163', 'mercury', 'parent'),
    ('roman-gods', 'roman-gods-f163', 'chione', 'parent'),
    ('roman-gods', 'roman-gods-f163', 'amphithea', 'child');
-- roman-gods-f164: Honos (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f164', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f164', 'honos', 'parent');
-- roman-gods-f165: Virtus (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('roman-gods', 'roman-gods-f165', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('roman-gods', 'roman-gods-f165', 'virtus', 'parent');


-- =================================================================================================
-- SAGA 15 of 17: THE BIBLE   [id: bible, category: religion]
-- Author:  Compiled by Jeffrey Philip Stoker
-- Medium:  GEDCOM genealogy (Bible+Family+Tree.ged)
-- Canon:   As recorded in the GEDCOM file
-- Covers:  583 people and 317 families, imported from a public GEDCOM sample.
-- Rows:    1 houses, 583 people, 317 families, 911 members
-- =================================================================================================

-- ── Reset (removes this saga and, by cascade, all of its rows) ─────────────────────────────────
DELETE FROM saga WHERE id = 'bible';

-- ── Saga ───────────────────────────────────────────────────────────────────────────────────────
INSERT INTO saga (id, category, position, title, work, medium, author, canon, genre, covers) VALUES
    ('bible', 'religion', 14, 'The Bible', 'The Bible', 'GEDCOM genealogy (Bible+Family+Tree.ged)', 'Compiled by Jeffrey Philip Stoker', 'As recorded in the GEDCOM file', 'Religion', '583 people and 317 families, imported from a public GEDCOM sample.');

-- ── Notes (modelling choices and where sources disagree) ───────────────────────────────────────
INSERT INTO saga_note (saga_id, position, note) VALUES
    ('bible', 0, 'Imported from Bible+Family+Tree.ged (UTF-8; PAF 5.2.18.0; file dated 9 Aug 2002) by scripts/gedcom-to-saga.mts.'),
    ('bible', 1, 'Display names are the person''s name only; a monarch is shown by their regnal name (e.g. King Henry VIII). Titles, title dates and life dates are not imported.'),
    ('bible', 2, '36 names were corrected from bible.json, where the file writes them badly (e.g. "Jacob (Israel)"); the reasons are in that file.'),
    ('bible', 3, 'Everyone is in one house, "Bible": the file has no real surnames to group by.'),
    ('bible', 4, '1 people have no recorded relatives in the source and are shown on their own: Mariam.'),
    ('bible', 5, 'Import warnings: Heth: sex not recorded as M or F, shown as male; Hivite: sex not recorded as M or F, shown as male; Isui: sex not recorded as M or F, shown as male; Ishuah: sex not recorded as M or F, shown as male; Sarah: sex not recorded as M or F, shown as male');

-- ── Houses (1) ─────────────────────────────────────────────────────────────────────────────────
INSERT INTO house (saga_id, name, color) VALUES
    ('bible', 'Bible', '#c9ad73');

-- ── People (583, grouped by house) ─────────────────────────────────────────────────────────────
-- Bible (583)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('bible', 'mizraim', 'Mizraim', 'Bible', 'm', NULL),
    ('bible', 'phut', 'Phut', 'Bible', 'm', NULL),
    ('bible', 'cush', 'Cush', 'Bible', 'm', NULL),
    ('bible', 'sabtah', 'Sabtah', 'Bible', 'm', NULL),
    ('bible', 'raamah', 'Raamah', 'Bible', 'm', NULL),
    ('bible', 'canaan', 'Canaan', 'Bible', 'm', NULL),
    ('bible', 'egyptus', 'Egyptus', 'Bible', 'f', NULL),
    ('bible', 'reumah', 'Reumah', 'Bible', 'f', NULL),
    ('bible', 'leah', 'Leah', 'Bible', 'f', NULL),
    ('bible', 'jacob', 'Jacob (Israel)', 'Bible', 'm', NULL),
    ('bible', 'isaac', 'Isaac', 'Bible', 'm', NULL),
    ('bible', 'rebekah', 'Rebekah', 'Bible', 'f', NULL),
    ('bible', 'abraham-abram', 'Abraham (Abram)', 'Bible', 'm', NULL),
    ('bible', 'terah', 'Terah', 'Bible', 'm', NULL),
    ('bible', 'nahor', 'Nahor', 'Bible', 'm', NULL),
    ('bible', 'serug', 'Serug', 'Bible', 'm', NULL),
    ('bible', 'reu', 'Reu', 'Bible', 'm', NULL),
    ('bible', 'peleg', 'Peleg', 'Bible', 'm', NULL),
    ('bible', 'eber', 'Eber', 'Bible', 'm', NULL),
    ('bible', 'salah', 'Salah', 'Bible', 'm', NULL),
    ('bible', 'arphaxad', 'Arphaxad', 'Bible', 'm', NULL),
    ('bible', 'shem', 'Shem', 'Bible', 'm', NULL),
    ('bible', 'noah', 'Noah', 'Bible', 'm', NULL),
    ('bible', 'lamech', 'Lamech', 'Bible', 'm', NULL),
    ('bible', 'methuselah', 'Methuselah', 'Bible', 'm', NULL),
    ('bible', 'enoch', 'Enoch', 'Bible', 'm', NULL),
    ('bible', 'jared', 'Jared', 'Bible', 'm', NULL),
    ('bible', 'mahalaleel', 'Mahalaleel', 'Bible', 'm', NULL),
    ('bible', 'cainan', 'Cainan', 'Bible', 'm', NULL),
    ('bible', 'enos', 'Enos', 'Bible', 'm', NULL),
    ('bible', 'seth', 'Seth', 'Bible', 'm', NULL),
    ('bible', 'adam', 'Adam', 'Bible', 'm', NULL),
    ('bible', 'japheth', 'Japheth', 'Bible', 'm', NULL),
    ('bible', 'ham', 'Ham', 'Bible', 'm', NULL),
    ('bible', 'titea', 'Titea', 'Bible', 'f', NULL),
    ('bible', 'tait', 'Tait', 'Bible', 'm', NULL),
    ('bible', 'oghaman', 'Oghaman', 'Bible', 'm', NULL),
    ('bible', 'beouman', 'Beouman', 'Bible', 'm', NULL),
    ('bible', 'heber-scut-scott', 'Heber Scut (Scott)', 'Bible', 'm', NULL),
    ('bible', 'sruth', 'Sruth', 'Bible', 'm', NULL),
    ('bible', 'asruth-easruth', 'Asruth (Easruth)', 'Bible', 'm', NULL),
    ('bible', 'gaodhal-glas', 'Gaodhal Glas', 'Bible', 'm', NULL),
    ('bible', 'niul', 'Niul', 'Bible', 'm', NULL),
    ('bible', 'phoeniusa-farsaidh', 'King Phoeniusa Farsaidh of Scythia', 'Bible', 'm', NULL),
    ('bible', 'boath', 'Boath', 'Bible', 'm', NULL),
    ('bible', 'magog', 'Magog', 'Bible', 'm', NULL),
    ('bible', 'scota', 'Scota', 'Bible', 'f', NULL),
    ('bible', 'huz', 'Huz', 'Bible', 'm', NULL),
    ('bible', 'hazo', 'Hazo', 'Bible', 'm', NULL),
    ('bible', 'chesed', 'Chesed', 'Bible', 'm', NULL),
    ('bible', 'adah', 'Adah', 'Bible', 'f', NULL),
    ('bible', 'buz', 'Buz', 'Bible', 'm', NULL),
    ('bible', 'nenall', 'Nenall', 'Bible', 'm', NULL),
    ('bible', 'laban', 'Laban', 'Bible', 'm', NULL),
    ('bible', 'abel', 'Abel', 'Bible', 'm', NULL),
    ('bible', 'zilah', 'Zilah', 'Bible', 'f', NULL),
    ('bible', 'enoch-2', 'Enoch', 'Bible', 'm', NULL),
    ('bible', 'irad', 'Irad', 'Bible', 'm', NULL),
    ('bible', 'mahujael', 'Mahujael', 'Bible', 'm', NULL),
    ('bible', 'methusael', 'Methusael', 'Bible', 'm', NULL),
    ('bible', 'lamech-2', 'Lamech', 'Bible', 'm', NULL),
    ('bible', 'trbal-cain', 'Trbal-Cain', 'Bible', 'm', NULL),
    ('bible', 'adah-2', 'Adah', 'Bible', 'f', NULL),
    ('bible', 'naamah', 'Naamah', 'Bible', 'm', NULL),
    ('bible', 'jabal', 'Jabal', 'Bible', 'm', NULL),
    ('bible', 'meshech', 'Meshech', 'Bible', 'm', NULL),
    ('bible', 'madai', 'Madai', 'Bible', 'm', NULL),
    ('bible', 'tubul', 'Tubul', 'Bible', 'm', NULL),
    ('bible', 'gomor', 'Gomor', 'Bible', 'm', NULL),
    ('bible', 'tiras', 'Tiras', 'Bible', 'm', NULL),
    ('bible', 'javan', 'Javan', 'Bible', 'm', NULL),
    ('bible', 'ashkeraz', 'Ashkeraz', 'Bible', 'm', NULL),
    ('bible', 'riphath', 'Riphath', 'Bible', 'm', NULL),
    ('bible', 'togarmar', 'Togarmar', 'Bible', 'm', NULL),
    ('bible', 'tarshish', 'Tarshish', 'Bible', 'm', NULL),
    ('bible', 'elisaah', 'Elisaah', 'Bible', 'm', NULL),
    ('bible', 'kittim', 'Kittim', 'Bible', 'm', NULL),
    ('bible', 'dodanim', 'Dodanim', 'Bible', 'm', NULL),
    ('bible', 'havilah', 'Havilah', 'Bible', 'm', NULL),
    ('bible', 'sabtecha', 'Sabtecha', 'Bible', 'm', NULL),
    ('bible', 'seba', 'Seba', 'Bible', 'm', NULL),
    ('bible', 'nimrod', 'Nimrod', 'Bible', 'm', NULL),
    ('bible', 'sheba', 'Sheba', 'Bible', 'm', NULL),
    ('bible', 'dedan', 'Dedan', 'Bible', 'm', NULL),
    ('bible', 'sidon', 'Sidon', 'Bible', 'm', NULL),
    ('bible', 'heth', 'Heth', 'Bible', 'm', NULL),
    ('bible', 'jebusite', 'Jebusite', 'Bible', 'm', NULL),
    ('bible', 'amorite', 'Amorite', 'Bible', 'm', NULL),
    ('bible', 'girgassite', 'Girgassite', 'Bible', 'm', NULL),
    ('bible', 'hivite', 'Hivite', 'Bible', 'm', NULL),
    ('bible', 'arkite', 'Arkite', 'Bible', 'm', NULL),
    ('bible', 'sirite', 'Sirite', 'Bible', 'm', NULL),
    ('bible', 'arvadite', 'Arvadite', 'Bible', 'm', NULL),
    ('bible', 'zemarite', 'Zemarite', 'Bible', 'm', NULL),
    ('bible', 'hamathite', 'Hamathite', 'Bible', 'm', NULL),
    ('bible', 'ludim', 'Ludim', 'Bible', 'm', NULL),
    ('bible', 'anamim', 'Anamim', 'Bible', 'm', NULL),
    ('bible', 'lehabim', 'Lehabim', 'Bible', 'm', NULL),
    ('bible', 'nephtuihim', 'Nephtuihim', 'Bible', 'm', NULL),
    ('bible', 'pethusim', 'Pethusim', 'Bible', 'm', NULL),
    ('bible', 'caphtorim', 'Caphtorim', 'Bible', 'm', NULL),
    ('bible', 'casluhim', 'Casluhim', 'Bible', 'm', NULL),
    ('bible', 'philstem', 'Philstem', 'Bible', 'm', NULL),
    ('bible', 'aram', 'Aram', 'Bible', 'm', NULL),
    ('bible', 'asshur', 'Asshur', 'Bible', 'm', NULL),
    ('bible', 'lud', 'Lud', 'Bible', 'm', NULL),
    ('bible', 'elam', 'Elam', 'Bible', 'm', NULL),
    ('bible', 'hul', 'Hul', 'Bible', 'm', NULL),
    ('bible', 'mash', 'Mash', 'Bible', 'm', NULL),
    ('bible', 'uz', 'Uz', 'Bible', 'm', NULL),
    ('bible', 'gether', 'Gether', 'Bible', 'm', NULL),
    ('bible', 'jokan', 'Jokan', 'Bible', 'm', NULL),
    ('bible', 'almodad', 'Almodad', 'Bible', 'm', NULL),
    ('bible', 'sheleph', 'Sheleph', 'Bible', 'm', NULL),
    ('bible', 'hazarmaveth', 'Hazarmaveth', 'Bible', 'm', NULL),
    ('bible', 'jerah', 'Jerah', 'Bible', 'm', NULL),
    ('bible', 'hadoram', 'Hadoram', 'Bible', 'm', NULL),
    ('bible', 'uzal', 'Uzal', 'Bible', 'm', NULL),
    ('bible', 'diklah', 'Diklah', 'Bible', 'm', NULL),
    ('bible', 'obal', 'Obal', 'Bible', 'm', NULL),
    ('bible', 'abimael', 'Abimael', 'Bible', 'm', NULL),
    ('bible', 'sheba-2', 'Sheba', 'Bible', 'm', NULL),
    ('bible', 'ophir', 'Ophir', 'Bible', 'm', NULL),
    ('bible', 'havilah-2', 'Havilah', 'Bible', 'm', NULL),
    ('bible', 'jobab', 'Jobab', 'Bible', 'm', NULL),
    ('bible', 'haran', 'Haran', 'Bible', 'm', NULL),
    ('bible', 'milcah', 'Milcah', 'Bible', 'f', NULL),
    ('bible', 'sarai', 'Sarai (Sarah)', 'Bible', 'f', NULL),
    ('bible', 'lot', 'Lot', 'Bible', 'm', NULL),
    ('bible', 'iscah', 'Iscah', 'Bible', 'f', NULL),
    ('bible', 'tebah', 'Tebah', 'Bible', 'm', NULL),
    ('bible', 'gaham', 'Gaham', 'Bible', 'm', NULL),
    ('bible', 'thahash', 'Thahash', 'Bible', 'm', NULL),
    ('bible', 'maachah', 'Maachah', 'Bible', 'm', NULL),
    ('bible', 'bethuel', 'Bethuel', 'Bible', 'm', NULL),
    ('bible', 'moab', 'Moab', 'Bible', 'm', NULL),
    ('bible', 'benammi', 'Benammi', 'Bible', 'm', NULL),
    ('bible', 'pildesh', 'Pildesh', 'Bible', 'm', NULL),
    ('bible', 'jidlaph', 'Jidlaph', 'Bible', 'm', NULL),
    ('bible', 'kemuel', 'Kemuel', 'Bible', 'm', NULL),
    ('bible', 'aram-2', 'Aram', 'Bible', 'm', NULL),
    ('bible', 'rachal', 'Rachal', 'Bible', 'f', NULL),
    ('bible', 'bilhah', 'Bilhah', 'Bible', 'f', NULL),
    ('bible', 'zalpah', 'Zalpah', 'Bible', 'f', NULL),
    ('bible', 'esau', 'Esau', 'Bible', 'm', NULL),
    ('bible', 'bashemath', 'Bashemath', 'Bible', 'f', NULL),
    ('bible', 'nahath', 'Nahath', 'Bible', 'm', NULL),
    ('bible', 'adbeel', 'Adbeel', 'Bible', 'm', NULL),
    ('bible', 'mibsam', 'Mibsam', 'Bible', 'm', NULL),
    ('bible', 'nephish', 'Nephish', 'Bible', 'm', NULL),
    ('bible', 'mishma', 'Mishma', 'Bible', 'm', NULL),
    ('bible', 'kedemah', 'Kedemah', 'Bible', 'm', NULL),
    ('bible', 'dumah', 'Dumah', 'Bible', 'm', NULL),
    ('bible', 'tema', 'Tema', 'Bible', 'm', NULL),
    ('bible', 'jetur', 'Jetur', 'Bible', 'm', NULL),
    ('bible', 'kendar', 'Kendar', 'Bible', 'm', NULL),
    ('bible', 'massa', 'Massa', 'Bible', 'm', NULL),
    ('bible', 'nebajoth', 'Nebajoth', 'Bible', 'm', NULL),
    ('bible', 'hadar', 'Hadar', 'Bible', 'm', NULL),
    ('bible', 'ephah', 'Ephah', 'Bible', 'm', NULL),
    ('bible', 'epher', 'Epher', 'Bible', 'm', NULL),
    ('bible', 'hanoch', 'Hanoch', 'Bible', 'm', NULL),
    ('bible', 'abida', 'Abida', 'Bible', 'm', NULL),
    ('bible', 'eldaah', 'Eldaah', 'Bible', 'm', NULL),
    ('bible', 'hagar', 'Hagar', 'Bible', 'f', NULL),
    ('bible', 'ishmael', 'Ishmael', 'Bible', 'm', NULL),
    ('bible', 'dedan-2', 'Dedan', 'Bible', 'm', NULL),
    ('bible', 'shuah', 'Shuah', 'Bible', 'm', NULL),
    ('bible', 'sheba-3', 'Sheba', 'Bible', 'm', NULL),
    ('bible', 'madan', 'Madan', 'Bible', 'm', NULL),
    ('bible', 'ishbak', 'Ishbak', 'Bible', 'm', NULL),
    ('bible', 'judith', 'Judith', 'Bible', 'f', NULL),
    ('bible', 'keturah', 'Keturah', 'Bible', 'f', NULL),
    ('bible', 'zemran', 'Zemran', 'Bible', 'm', NULL),
    ('bible', 'jokshon', 'Jokshon', 'Bible', 'm', NULL),
    ('bible', 'eve', 'Eve', 'Bible', 'f', NULL),
    ('bible', 'cain', 'Cain', 'Bible', 'm', NULL),
    ('bible', 'nahor-2', 'Nahor', 'Bible', 'm', NULL),
    ('bible', 'lot-elder-daughter', 'Elder daughter of Lot', 'Bible', 'f', NULL),
    ('bible', 'lot-younger-daughter', 'Younger daughter of Lot', 'Bible', 'f', NULL),
    ('bible', 'jubal', 'Jubal', 'Bible', 'm', NULL),
    ('bible', 'reuel-jethro', 'Reuel (Jethro)', 'Bible', 'm', NULL),
    ('bible', 'aholitamah', 'Aholitamah', 'Bible', 'f', NULL),
    ('bible', 'aeush', 'Aeush', 'Bible', 'm', NULL),
    ('bible', 'jaalam', 'Jaalam', 'Bible', 'm', NULL),
    ('bible', 'korah', 'Korah', 'Bible', 'm', NULL),
    ('bible', 'anah', 'Anah', 'Bible', 'm', NULL),
    ('bible', 'dishon', 'Dishon', 'Bible', 'm', NULL),
    ('bible', 'hemden', 'Hemden', 'Bible', 'm', NULL),
    ('bible', 'eshben', 'Eshben', 'Bible', 'm', NULL),
    ('bible', 'ithran', 'Ithran', 'Bible', 'm', NULL),
    ('bible', 'cheran', 'Cheran', 'Bible', 'm', NULL),
    ('bible', 'zibeon', 'Zibeon', 'Bible', 'm', NULL),
    ('bible', 'ajah', 'Ajah', 'Bible', 'm', NULL),
    ('bible', 'seir', 'Seir', 'Bible', 'm', NULL),
    ('bible', 'timna', 'Timna', 'Bible', 'm', NULL),
    ('bible', 'lotan', 'Lotan', 'Bible', 'm', NULL),
    ('bible', 'stobal', 'Stobal', 'Bible', 'm', NULL),
    ('bible', 'ezer', 'Ezer', 'Bible', 'm', NULL),
    ('bible', 'dishan', 'Dishan', 'Bible', 'm', NULL),
    ('bible', 'uz-2', 'Uz', 'Bible', 'm', NULL),
    ('bible', 'aran', 'Aran', 'Bible', 'm', NULL),
    ('bible', 'bilhan', 'Bilhan', 'Bible', 'm', NULL),
    ('bible', 'zaavan', 'Zaavan', 'Bible', 'm', NULL),
    ('bible', 'akan', 'Akan', 'Bible', 'm', NULL),
    ('bible', 'alvan', 'Alvan', 'Bible', 'm', NULL),
    ('bible', 'manahath', 'Manahath', 'Bible', 'm', NULL),
    ('bible', 'ebal', 'Ebal', 'Bible', 'm', NULL),
    ('bible', 'shepho', 'Shepho', 'Bible', 'm', NULL),
    ('bible', 'onam', 'Onam', 'Bible', 'm', NULL),
    ('bible', 'hori', 'Hori', 'Bible', 'm', NULL),
    ('bible', 'hemam', 'Hemam', 'Bible', 'm', NULL),
    ('bible', 'zarah', 'Zarah', 'Bible', 'f', NULL),
    ('bible', 'shanmah', 'Shanmah', 'Bible', 'f', NULL),
    ('bible', 'zipporah', 'Zipporah', 'Bible', 'f', NULL),
    ('bible', 'mizzah', 'Mizzah', 'Bible', 'm', NULL),
    ('bible', 'follian-falach', 'Follian (Falach)', 'Bible', 'm', NULL),
    ('bible', 'eithriall', 'Eithriall', 'Bible', 'm', NULL),
    ('bible', 'irial-faidh', 'King Irial Faidh of Ireland', 'Bible', 'm', NULL),
    ('bible', 'tamar-tephi', 'Princess Tamar Tephi of Judah', 'Bible', 'f', NULL),
    ('bible', 'mattaniah', 'King Mattaniah (Zedekiah) of Judah', 'Bible', 'm', NULL),
    ('bible', 'josiah', 'King Josiah of Judah', 'Bible', 'm', NULL),
    ('bible', 'hammutal', 'Hammutal, daughter of Jeremiah', 'Bible', 'f', NULL),
    ('bible', 'eochaid-i-heremon-ireland', 'Eochaid I (Heremon) Ireland', 'Bible', 'm', NULL),
    ('bible', 'jeremiah', 'Jeremiah the Prophet', 'Bible', 'm', NULL),
    ('bible', 'hilkiah', 'Hilkiah', 'Bible', 'm', NULL),
    ('bible', 'gemariah', 'Gemariah', 'Bible', 'f', NULL),
    ('bible', 'elasah', 'Elasah', 'Bible', 'f', NULL),
    ('bible', 'shaphan', 'Shaphan', 'Bible', 'm', NULL),
    ('bible', 'ahitub', 'Ahitub', 'Bible', 'm', NULL),
    ('bible', 'amariah', 'Amariah', 'Bible', 'm', NULL),
    ('bible', 'holdiah', 'Holdiah', 'Bible', 'f', NULL),
    ('bible', 'ezra', 'Ezra', 'Bible', 'm', NULL),
    ('bible', 'hanameel', 'Hanameel', 'Bible', 'm', NULL),
    ('bible', 'shallum', 'Shallum', 'Bible', 'm', NULL),
    ('bible', 'zadok', 'Zadok', 'Bible', 'm', NULL),
    ('bible', 'azariah', 'Azariah', 'Bible', 'm', NULL),
    ('bible', 'meraioth', 'Meraioth', 'Bible', 'm', NULL),
    ('bible', 'zerahiah', 'Zerahiah', 'Bible', 'm', NULL),
    ('bible', 'uzzi', 'Uzzi', 'Bible', 'm', NULL),
    ('bible', 'bukki', 'Bukki', 'Bible', 'm', NULL),
    ('bible', 'abishuah', 'Abishuah', 'Bible', 'm', NULL),
    ('bible', 'phineas', 'Phineas', 'Bible', 'm', NULL),
    ('bible', 'eleazer', 'Eleazer', 'Bible', 'm', NULL),
    ('bible', 'aaron', 'Aaron', 'Bible', 'm', NULL),
    ('bible', 'amram', 'Amram', 'Bible', 'm', NULL),
    ('bible', 'kohath', 'Kohath', 'Bible', 'm', NULL),
    ('bible', 'levi', 'Levi', 'Bible', 'm', NULL),
    ('bible', 'joiadah', 'Joiadah', 'Bible', 'm', NULL),
    ('bible', 'eliashib', 'Eliashib', 'Bible', 'm', NULL),
    ('bible', 'joachim', 'Joachim', 'Bible', 'm', NULL),
    ('bible', 'joshuah', 'Joshuah', 'Bible', 'm', NULL),
    ('bible', 'josedech', 'Josedech', 'Bible', 'm', NULL),
    ('bible', 'seriah', 'Seriah', 'Bible', 'm', NULL),
    ('bible', 'jochebed', 'Jochebed', 'Bible', 'f', NULL),
    ('bible', 'merari', 'Merari', 'Bible', 'm', NULL),
    ('bible', 'libni', 'Libni', 'Bible', 'm', NULL),
    ('bible', 'shimi', 'Shimi', 'Bible', 'm', NULL),
    ('bible', 'mahali', 'Mahali', 'Bible', 'm', NULL),
    ('bible', 'mushi', 'Mushi', 'Bible', 'm', NULL),
    ('bible', 'moses', 'Moses', 'Bible', 'm', NULL),
    ('bible', 'mirham', 'Mirham', 'Bible', 'f', NULL),
    ('bible', 'elisheba', 'Elisheba', 'Bible', 'f', NULL),
    ('bible', 'jehudisah', 'Jehudisah', 'Bible', 'f', NULL),
    ('bible', 'jether', 'Jether', 'Bible', 'm', NULL),
    ('bible', 'mered', 'Mered', 'Bible', 'm', NULL),
    ('bible', 'ephar', 'Ephar', 'Bible', 'm', NULL),
    ('bible', 'jalon', 'Jalon', 'Bible', 'm', NULL),
    ('bible', 'mariam', 'Mariam', 'Bible', 'f', NULL),
    ('bible', 'shammai', 'Shammai', 'Bible', 'm', NULL),
    ('bible', 'ishbah', 'Ishbah', 'Bible', 'm', NULL),
    ('bible', 'jerad', 'Jerad', 'Bible', 'm', NULL),
    ('bible', 'heber', 'Heber', 'Bible', 'm', NULL),
    ('bible', 'jekuthiel', 'Jekuthiel', 'Bible', 'm', NULL),
    ('bible', 'eshteemca', 'Eshteemca', 'Bible', 'm', NULL),
    ('bible', 'gedor', 'Gedor', 'Bible', 'm', NULL),
    ('bible', 'socho', 'Socho', 'Bible', 'm', NULL),
    ('bible', 'zanoah', 'Zanoah', 'Bible', 'm', NULL),
    ('bible', 'reuben', 'Reuben', 'Bible', 'm', NULL),
    ('bible', 'gershon', 'Gershon', 'Bible', 'm', NULL),
    ('bible', 'libnah', 'Libnah', 'Bible', 'f', NULL),
    ('bible', 'shallum-2', 'Shallum', 'Bible', 'm', NULL),
    ('bible', 'mulek', 'Mulek', 'Bible', 'm', NULL),
    ('bible', 'azaniah', 'Azaniah', 'Bible', 'm', NULL),
    ('bible', 'johanan', 'Johanan', 'Bible', 'm', NULL),
    ('bible', 'jehoiakim', 'Jehoiakim', 'Bible', 'm', NULL),
    ('bible', 'jeconiah', 'Jeconiah', 'Bible', 'm', NULL),
    ('bible', 'zedekiah', 'Zedekiah', 'Bible', 'm', NULL),
    ('bible', 'assir', 'Assir', 'Bible', 'm', NULL),
    ('bible', 'malchiram', 'Malchiram', 'Bible', 'm', NULL),
    ('bible', 'pedaiah', 'Pedaiah', 'Bible', 'm', NULL),
    ('bible', 'shenazar', 'Shenazar', 'Bible', 'm', NULL),
    ('bible', 'jacamiah', 'Jacamiah', 'Bible', 'm', NULL),
    ('bible', 'hoshama', 'Hoshama', 'Bible', 'm', NULL),
    ('bible', 'nedabiah', 'Nedabiah', 'Bible', 'm', NULL),
    ('bible', 'zerubbabel', 'Zerubbabel', 'Bible', 'm', NULL),
    ('bible', 'shimei', 'Shimei', 'Bible', 'm', NULL),
    ('bible', 'meshullam', 'Meshullam', 'Bible', 'm', NULL),
    ('bible', 'hananiah', 'Hananiah', 'Bible', 'm', NULL),
    ('bible', 'saeloith', 'Saeloith', 'Bible', 'f', NULL),
    ('bible', 'rephaiah', 'Rephaiah', 'Bible', 'm', NULL),
    ('bible', 'miriam', 'Miriam', 'Bible', 'm', NULL),
    ('bible', 'salathiel', 'Salathiel', 'Bible', 'm', NULL),
    ('bible', 'gershom', 'Gershom', 'Bible', 'm', NULL),
    ('bible', 'hanoch-2', 'Hanoch', 'Bible', 'm', NULL),
    ('bible', 'phallu', 'Phallu', 'Bible', 'm', NULL),
    ('bible', 'hezron', 'Hezron', 'Bible', 'm', NULL),
    ('bible', 'carmi', 'Carmi', 'Bible', 'm', NULL),
    ('bible', 'ohad', 'Ohad', 'Bible', 'm', NULL),
    ('bible', 'jachin', 'Jachin', 'Bible', 'm', NULL),
    ('bible', 'zohar', 'Zohar', 'Bible', 'm', NULL),
    ('bible', 'shaul', 'Shaul', 'Bible', 'm', NULL),
    ('bible', 'jemeul', 'Jemeul', 'Bible', 'm', NULL),
    ('bible', 'jamin', 'Jamin', 'Bible', 'm', NULL),
    ('bible', 'shimea', 'Shimea', 'Bible', 'm', NULL),
    ('bible', 'simeon', 'Simeon', 'Bible', 'm', NULL),
    ('bible', 'jehoram', 'King Jehoram (Joram) of Judah', 'Bible', 'm', NULL),
    ('bible', 'ahaziah', 'Ahaziah', 'Bible', 'm', NULL),
    ('bible', 'athaliah', 'Athaliah', 'Bible', 'f', NULL),
    ('bible', 'bathsheba', 'Bathsheba', 'Bible', 'f', NULL),
    ('bible', 'garcia-ii', 'King García II of Navarre', 'Bible', 'm', NULL),
    ('bible', 'chimene-ximena', 'Chimene (Ximena)', 'Bible', 'f', NULL),
    ('bible', 'sancho-iii', 'King Sancho III of Navarre', 'Bible', 'm', NULL),
    ('bible', 'munia-ninia', 'Munia (Ninia)', 'Bible', 'f', NULL),
    ('bible', 'sancho-ii', 'Sancho II', 'Bible', 'm', NULL),
    ('bible', 'urraca', 'Urraca', 'Bible', 'f', NULL),
    ('bible', 'sancho-i', 'Sancho I', 'Bible', 'm', NULL),
    ('bible', 'theuda-toda', 'Theuda (Toda)', 'Bible', 'f', NULL),
    ('bible', 'ram', 'Ram', 'Bible', 'm', NULL),
    ('bible', 'amminadab', 'Amminadab', 'Bible', 'm', NULL),
    ('bible', 'morianton', 'Morianton', 'Bible', 'm', NULL),
    ('bible', 'rahab-rachab', 'Rahab (Rachab)', 'Bible', 'f', NULL),
    ('bible', 'salmon', 'Salmon', 'Bible', 'm', NULL),
    ('bible', 'shelah', 'Shelah', 'Bible', 'm', NULL),
    ('bible', 'ruth', 'Ruth of Moab', 'Bible', 'f', NULL),
    ('bible', 'onan', 'Onan', 'Bible', 'm', NULL),
    ('bible', 'boas', 'Boas', 'Bible', 'm', NULL),
    ('bible', 'obed', 'Obed', 'Bible', 'm', NULL),
    ('bible', 'riplakish', 'Riplakish', 'Bible', 'm', NULL),
    ('bible', 'jesse', 'Jesse', 'Bible', 'm', NULL),
    ('bible', 'pharez', 'Pharez', 'Bible', 'm', NULL),
    ('bible', 'hezron-2', 'Hezron', 'Bible', 'm', NULL),
    ('bible', 'vingener', 'Vingener', 'Bible', 'm', NULL),
    ('bible', 'tror-thor', 'Tror (Thor)', 'Bible', 'm', NULL),
    ('bible', 'priam-daughter', 'Daughter of Priam', 'Bible', 'f', NULL),
    ('bible', 'priam', 'King Priam of Troy', 'Bible', 'm', NULL),
    ('bible', 'lamoedon', 'Lamoedon', 'Bible', 'm', NULL),
    ('bible', 'ilus', 'Ilus', 'Bible', 'm', NULL),
    ('bible', 'tros', 'King Tros of Troy', 'Bible', 'm', NULL),
    ('bible', 'erichthonius', 'Erichthonius', 'Bible', 'm', NULL),
    ('bible', 'darda', 'Darda', 'Bible', 'm', NULL),
    ('bible', 'zarah-2', 'Zarah', 'Bible', 'm', NULL),
    ('bible', 'tamar', 'Tamar', 'Bible', 'f', NULL),
    ('bible', 'hamul', 'Hamul', 'Bible', 'm', NULL),
    ('bible', 'memnon', 'Memnon', 'Bible', 'm', NULL),
    ('bible', 'silvius', 'Silvius', 'Bible', 'm', NULL),
    ('bible', 'aeneas', 'Aeneas', 'Bible', 'm', NULL),
    ('bible', 'capps', 'Capps', 'Bible', 'm', NULL),
    ('bible', 'assaracus', 'Assaracus', 'Bible', 'm', NULL),
    ('bible', 'shuah-2', 'Shuah', 'Bible', 'f', NULL),
    ('bible', 'rehoboam-roboam', 'Rehoboam (Roboam)', 'Bible', 'm', NULL),
    ('bible', 'nathan', 'Nathan', 'Bible', 'm', NULL),
    ('bible', 'abia', 'Abia', 'Bible', 'm', NULL),
    ('bible', 'david', 'King David of Judah and Israel', 'Bible', 'm', NULL),
    ('bible', 'asa', 'King Asa of Judah', 'Bible', 'm', NULL),
    ('bible', 'shabod', 'Shabod', 'Bible', 'm', NULL),
    ('bible', 'josaphat', 'Josaphat', 'Bible', 'm', NULL),
    ('bible', 'nabah', 'Princess Nabah', 'Bible', 'f', NULL),
    ('bible', 'dinah', 'Dinah', 'Bible', 'f', NULL),
    ('bible', 'joash', 'King Joash of Judah', 'Bible', 'm', NULL),
    ('bible', 'amaziah', 'Amaziah', 'Bible', 'm', NULL),
    ('bible', 'solomon', 'King Solomon of Judah', 'Bible', 'm', NULL),
    ('bible', 'azuarius', 'Azuarius', 'Bible', 'm', NULL),
    ('bible', 'nashon-naasson', 'Nashon (Naasson)', 'Bible', 'm', NULL),
    ('bible', 'er', 'Er', 'Bible', 'm', NULL),
    ('bible', 'judah-judas', 'Judah (Judas)', 'Bible', 'm', NULL),
    ('bible', 'brutus', 'Brutus of Britain', 'Bible', 'm', NULL),
    ('bible', 'anchises', 'Anchises', 'Bible', 'm', NULL),
    ('bible', 'tola', 'Tola', 'Bible', 'm', NULL),
    ('bible', 'shimron', 'Shimron', 'Bible', 'm', NULL),
    ('bible', 'phuvah', 'Phuvah', 'Bible', 'm', NULL),
    ('bible', 'job', 'Job', 'Bible', 'm', NULL),
    ('bible', 'issachar', 'Issachar', 'Bible', 'm', NULL),
    ('bible', 'jahleel', 'Jahleel', 'Bible', 'm', NULL),
    ('bible', 'sered', 'Sered', 'Bible', 'm', NULL),
    ('bible', 'elon', 'Elon', 'Bible', 'm', NULL),
    ('bible', 'zebulun', 'Zebulun', 'Bible', 'm', NULL),
    ('bible', 'uzziah-azariah', 'Uzziah (Azariah)', 'Bible', 'm', NULL),
    ('bible', 'jotham', 'King Jotham of Judah', 'Bible', 'm', NULL),
    ('bible', 'ahaz', 'Ahaz', 'Bible', 'm', NULL),
    ('bible', 'hezekiah', 'Hezekiah', 'Bible', 'm', NULL),
    ('bible', 'manasseh', 'Manasseh', 'Bible', 'm', NULL),
    ('bible', 'milcah-2', 'Milcah', 'Bible', 'f', NULL),
    ('bible', 'hoglah', 'Hoglah', 'Bible', 'f', NULL),
    ('bible', 'noah-2', 'Noah', 'Bible', 'f', NULL),
    ('bible', 'zelophehad', 'Zelophehad', 'Bible', 'm', NULL),
    ('bible', 'hepher', 'Hepher', 'Bible', 'm', NULL),
    ('bible', 'bashan', 'Bashan', 'Bible', 'm', NULL),
    ('bible', 'gilead', 'Gilead', 'Bible', 'm', NULL),
    ('bible', 'machir', 'MacHir', 'Bible', 'm', NULL),
    ('bible', 'shemida', 'Shemida', 'Bible', 'm', NULL),
    ('bible', 'hepher-2', 'Hepher', 'Bible', 'm', NULL),
    ('bible', 'shechem', 'Shechem', 'Bible', 'm', NULL),
    ('bible', 'asriel', 'Asriel', 'Bible', 'm', NULL),
    ('bible', 'helek', 'Helek', 'Bible', 'm', NULL),
    ('bible', 'abiezer', 'Abiezer', 'Bible', 'm', NULL),
    ('bible', 'ephraim', 'Ephraim', 'Bible', 'm', NULL),
    ('bible', 'manasseh-2', 'Manasseh', 'Bible', 'm', NULL),
    ('bible', 'asenath', 'Asenath', 'Bible', 'f', NULL),
    ('bible', 'joseph', 'Joseph', 'Bible', 'm', NULL),
    ('bible', 'shillem', 'Shillem', 'Bible', 'm', NULL),
    ('bible', 'jezer', 'Jezer', 'Bible', 'm', NULL),
    ('bible', 'guni', 'Guni', 'Bible', 'm', NULL),
    ('bible', 'jahzeel', 'Jahzeel', 'Bible', 'm', NULL),
    ('bible', 'naphtali', 'Naphtali', 'Bible', 'm', NULL),
    ('bible', 'hushim', 'Hushim', 'Bible', 'm', NULL),
    ('bible', 'dan', 'Dan', 'Bible', 'm', NULL),
    ('bible', 'shule', 'Shule', 'Bible', 'm', NULL),
    ('bible', 'heth-2', 'Heth', 'Bible', 'm', NULL),
    ('bible', 'shez', 'Shez', 'Bible', 'm', NULL),
    ('bible', 'malchiel', 'Malchiel', 'Bible', 'm', NULL),
    ('bible', 'heber-2', 'Heber', 'Bible', 'm', NULL),
    ('bible', 'amon', 'King Amon of Judah', 'Bible', 'm', NULL),
    ('bible', 'joseph-2', 'Joseph', 'Bible', 'm', NULL),
    ('bible', 'mattathias', 'Mattathias', 'Bible', 'm', NULL),
    ('bible', 'simon-daughter', 'Daughter of Simon the Just', 'Bible', 'f', NULL),
    ('bible', 'semei', 'Semei', 'Bible', 'm', NULL),
    ('bible', 'joseph-3', 'Joseph', 'Bible', 'm', NULL),
    ('bible', 'juda', 'Juda', 'Bible', 'm', NULL),
    ('bible', 'joanna', 'Joanna', 'Bible', 'm', NULL),
    ('bible', 'rhesa', 'Rhesa', 'Bible', 'm', NULL),
    ('bible', 'zorobabel', 'Zorobabel', 'Bible', 'm', NULL),
    ('bible', 'salathiel-2', 'Salathiel', 'Bible', 'm', NULL),
    ('bible', 'neri', 'Neri', 'Bible', 'm', NULL),
    ('bible', 'melchi', 'Melchi', 'Bible', 'm', NULL),
    ('bible', 'addi', 'Addi', 'Bible', 'm', NULL),
    ('bible', 'cosam', 'Cosam', 'Bible', 'm', NULL),
    ('bible', 'elmodam', 'Elmodam', 'Bible', 'm', NULL),
    ('bible', 'er-2', 'Er', 'Bible', 'm', NULL),
    ('bible', 'jose', 'Jose', 'Bible', 'm', NULL),
    ('bible', 'eliezer', 'Eliezer', 'Bible', 'm', NULL),
    ('bible', 'jorim', 'Jorim', 'Bible', 'm', NULL),
    ('bible', 'jesus', 'Jesus Christ', 'Bible', 'm', NULL),
    ('bible', 'levi-2', 'Levi', 'Bible', 'm', NULL),
    ('bible', 'simeon-2', 'Simeon', 'Bible', 'm', NULL),
    ('bible', 'juda-2', 'Juda', 'Bible', 'm', NULL),
    ('bible', 'joseph-4', 'Joseph', 'Bible', 'm', NULL),
    ('bible', 'eliakim', 'Eliakim', 'Bible', 'm', NULL),
    ('bible', 'melea', 'Melea', 'Bible', 'm', NULL),
    ('bible', 'menan', 'Menan', 'Bible', 'm', NULL),
    ('bible', 'mattatha', 'Mattatha', 'Bible', 'm', NULL),
    ('bible', 'amalech', 'Amalech', 'Bible', 'm', NULL),
    ('bible', 'beli', 'King Beli the Great of the Britons', 'Bible', 'm', NULL),
    ('bible', 'anna', 'Anna, cousin of Joseph', 'Bible', 'f', NULL),
    ('bible', 'matthat', 'Matthat', 'Bible', 'm', NULL),
    ('bible', 'melchi-2', 'Melchi', 'Bible', 'm', NULL),
    ('bible', 'janna', 'Janna', 'Bible', 'm', NULL),
    ('bible', 'bran', 'Bran the Blessed', 'Bible', 'm', NULL),
    ('bible', 'penardin', 'Penardin', 'Bible', 'm', NULL),
    ('bible', 'llyr', 'Llyr Lediaith (King Lear)', 'Bible', 'f', NULL),
    ('bible', 'azor', 'Azor', 'Bible', 'm', NULL),
    ('bible', 'mahlah', 'Mahlah', 'Bible', 'f', NULL),
    ('bible', 'aodh-glas', 'Aodh Glas', 'Bible', 'm', NULL),
    ('bible', 'manogan', 'Manogan', 'Bible', 'm', NULL),
    ('bible', 'lud-britons', 'King Lud of the Britons', 'Bible', 'm', NULL),
    ('bible', 'sadoc', 'Sadoc', 'Bible', 'm', NULL),
    ('bible', 'eleazar', 'Eleazar', 'Bible', 'm', NULL),
    ('bible', 'achim', 'Achim', 'Bible', 'm', NULL),
    ('bible', 'eliud', 'Eliud', 'Bible', 'm', NULL),
    ('bible', 'heli', 'Heli', 'Bible', 'm', NULL),
    ('bible', 'jacob-2', 'Jacob', 'Bible', 'm', NULL),
    ('bible', 'matthan', 'Matthan', 'Bible', 'm', NULL),
    ('bible', 'abiud', 'Abiud', 'Bible', 'm', NULL),
    ('bible', 'salathiel-3', 'Salathiel', 'Bible', 'm', NULL),
    ('bible', 'jechonias', 'Jechonias', 'Bible', 'm', NULL),
    ('bible', 'josias', 'Josias', 'Bible', 'm', NULL),
    ('bible', 'amon-2', 'Amon', 'Bible', 'm', NULL),
    ('bible', 'manasses', 'Manasses', 'Bible', 'm', NULL),
    ('bible', 'ezekias', 'Ezekias', 'Bible', 'm', NULL),
    ('bible', 'achaz', 'Achaz', 'Bible', 'm', NULL),
    ('bible', 'joatham', 'Joatham', 'Bible', 'm', NULL),
    ('bible', 'ozias', 'Ozias', 'Bible', 'm', NULL),
    ('bible', 'mattathias-2', 'Mattathias', 'Bible', 'm', NULL),
    ('bible', 'maath', 'Maath', 'Bible', 'm', NULL),
    ('bible', 'nagga', 'Nagga', 'Bible', 'm', NULL),
    ('bible', 'esli', 'Esli', 'Bible', 'm', NULL),
    ('bible', 'omer', 'Omer', 'Bible', 'm', NULL),
    ('bible', 'benjaman', 'Benjaman', 'Bible', 'm', NULL),
    ('bible', 'emer', 'Emer', 'Bible', 'm', NULL),
    ('bible', 'kib', 'Kib', 'Bible', 'm', NULL),
    ('bible', 'elon-2', 'Elon', 'Bible', 'm', NULL),
    ('bible', 'orihah', 'Orihah', 'Bible', 'm', NULL),
    ('bible', 'ezbon', 'Ezbon', 'Bible', 'm', NULL),
    ('bible', 'zorobabel-2', 'Zorobabel', 'Bible', 'm', NULL),
    ('bible', 'shuni', 'Shuni', 'Bible', 'm', NULL),
    ('bible', 'arodi', 'Arodi', 'Bible', 'm', NULL),
    ('bible', 'haggi', 'Haggi', 'Bible', 'm', NULL),
    ('bible', 'eri', 'Eri', 'Bible', 'm', NULL),
    ('bible', 'ziphion', 'Ziphion', 'Bible', 'm', NULL),
    ('bible', 'gad', 'Gad', 'Bible', 'm', NULL),
    ('bible', 'sigurd-i', 'King Sigurd I of Norway', 'Bible', 'm', NULL),
    ('bible', 'tirzah', 'Tirzah', 'Bible', 'f', NULL),
    ('bible', 'elizabeth', 'Elizabeth, cousin of Mary', 'Bible', 'f', NULL),
    ('bible', 'coriantum', 'Coriantum', 'Bible', 'm', NULL),
    ('bible', 'com', 'Com', 'Bible', 'm', NULL),
    ('bible', 'isui', 'Isui', 'Bible', 'm', NULL),
    ('bible', 'ishuah', 'Ishuah', 'Bible', 'm', NULL),
    ('bible', 'enos-2', 'Enos', 'Bible', 'm', NULL),
    ('bible', 'beriah', 'Beriah', 'Bible', 'm', NULL),
    ('bible', 'ashbel', 'Ashbel', 'Bible', 'm', NULL),
    ('bible', 'jarom', 'Jarom', 'Bible', 'm', NULL),
    ('bible', 'omni', 'Omni', 'Bible', 'm', NULL),
    ('bible', 'chemish', 'Chemish', 'Bible', 'm', NULL),
    ('bible', 'amaron', 'Amaron', 'Bible', 'm', NULL),
    ('bible', 'mohonria-moriancuma', 'Mohonria Moriancuma', 'Bible', 'm', NULL),
    ('bible', 'becher', 'Becher', 'Bible', 'm', NULL),
    ('bible', 'ard', 'Ard', 'Bible', 'm', NULL),
    ('bible', 'naaman', 'Naaman', 'Bible', 'm', NULL),
    ('bible', 'huppim', 'Huppim', 'Bible', 'm', NULL),
    ('bible', 'naum', 'Naum', 'Bible', 'm', NULL),
    ('bible', 'amos', 'Amos', 'Bible', 'm', NULL),
    ('bible', 'jonan', 'Jonan', 'Bible', 'm', NULL),
    ('bible', 'muppim', 'Muppim', 'Bible', 'm', NULL),
    ('bible', 'eli', 'Eli', 'Bible', 'm', NULL),
    ('bible', 'gera', 'Gera', 'Bible', 'm', NULL),
    ('bible', 'lehi', 'Lehi', 'Bible', 'm', NULL),
    ('bible', 'iddo', 'Iddo', 'Bible', 'm', NULL),
    ('bible', 'jacob-3', 'Jacob', 'Bible', 'm', NULL),
    ('bible', 'joeph', 'Joeph', 'Bible', 'm', NULL),
    ('bible', 'nephi', 'Nephi', 'Bible', 'm', NULL),
    ('bible', 'sam', 'Sam', 'Bible', 'm', NULL),
    ('bible', 'lemul', 'Lemul', 'Bible', 'm', NULL),
    ('bible', 'laman', 'Laman', 'Bible', 'm', NULL),
    ('bible', 'sariah', 'Sariah', 'Bible', 'f', NULL),
    ('bible', 'belah', 'Belah', 'Bible', 'm', NULL),
    ('bible', 'rosh', 'Rosh', 'Bible', 'm', NULL),
    ('bible', 'sarah', 'Sarah', 'Bible', 'm', NULL),
    ('bible', 'jimnah', 'Jimnah', 'Bible', 'm', NULL),
    ('bible', 'asher', 'Asher', 'Bible', 'm', NULL),
    ('bible', 'zachariah', 'Zachariah', 'Bible', 'm', NULL),
    ('bible', 'john-baptist', 'John the Baptist', 'Bible', 'm', NULL),
    ('bible', 'levi-3', 'Levi', 'Bible', 'm', NULL),
    ('bible', 'joseph-5', 'Joseph', 'Bible', 'm', NULL),
    ('bible', 'joseph-6', 'Joseph', 'Bible', 'm', NULL),
    ('bible', 'areli', 'Areli', 'Bible', 'm', NULL),
    ('bible', 'eliakim-2', 'Eliakim', 'Bible', 'm', NULL),
    ('bible', 'mary', 'Mary', 'Bible', 'f', NULL),
    ('bible', 'matthat-2', 'Matthat', 'Bible', 'm', NULL),
    ('bible', 'kim', 'Kim', 'Bible', 'm', NULL),
    ('bible', 'levi-4', 'Levi', 'Bible', 'm', NULL),
    ('bible', 'corom', 'Corom', 'Bible', 'm', NULL),
    ('bible', 'kish', 'Kish', 'Bible', 'm', NULL),
    ('bible', 'lib', 'Lib', 'Bible', 'm', NULL),
    ('bible', 'heth-3', 'Heth', 'Bible', 'm', NULL),
    ('bible', 'aaron-2', 'Aaron', 'Bible', 'm', NULL),
    ('bible', 'amnigaddah', 'Amnigaddah', 'Bible', 'm', NULL),
    ('bible', 'coriantam', 'Coriantam', 'Bible', 'm', NULL),
    ('bible', 'shiblon', 'Shiblon', 'Bible', 'm', NULL),
    ('bible', 'seth-2', 'Seth', 'Bible', 'm', NULL),
    ('bible', 'anah-2', 'Anah', 'Bible', 'm', NULL),
    ('bible', 'ethem', 'Ethem', 'Bible', 'm', NULL),
    ('bible', 'moron', 'Moron', 'Bible', 'm', NULL),
    ('bible', 'coriantor', 'Coriantor', 'Bible', 'm', NULL),
    ('bible', 'ether', 'Ether', 'Bible', 'm', NULL),
    ('bible', 'com-2', 'Com', 'Bible', 'm', NULL),
    ('bible', 'pagag', 'Pagag', 'Bible', 'm', NULL),
    ('bible', 'jacon', 'Jacon', 'Bible', 'm', NULL),
    ('bible', 'father-of-jared', 'Father of Jared', 'Bible', 'm', NULL),
    ('bible', 'corianumr', 'Corianumr', 'Bible', 'm', NULL),
    ('bible', 'a-daughter-of-jared', 'A Daughter of Jared', 'Bible', 'f', NULL),
    ('bible', 'jared-2', 'Jared', 'Bible', 'm', NULL),
    ('bible', 'gilgah', 'Gilgah', 'Bible', 'm', NULL),
    ('bible', 'mahah', 'Mahah', 'Bible', 'm', NULL),
    ('bible', 'a-son-of-alish', 'A Son of Alish', 'Bible', 'm', NULL),
    ('bible', 'jared-3', 'Jared', 'Bible', 'm', NULL),
    ('bible', 'esrom', 'Esrom', 'Bible', 'm', NULL),
    ('bible', 'nimrah', 'Nimrah', 'Bible', 'm', NULL),
    ('bible', 'akish', 'Akish', 'Bible', 'm', NULL),
    ('bible', 'corihor', 'Corihor', 'Bible', 'm', NULL),
    ('bible', 'noah-3', 'Noah', 'Bible', 'm', NULL),
    ('bible', 'cohor', 'Cohor', 'Bible', 'm', NULL),
    ('bible', 'cohor-2', 'Cohor', 'Bible', 'm', NULL),
    ('bible', 'nimrod-2', 'Nimrod', 'Bible', 'm', NULL);

-- ── Families (317, each followed by its members) ───────────────────────────────────────────────
-- bible-f1: Mizraim → Ludim, Anamim, Lehabim, Nephtuihim, Pethusim, Caphtorim, Casluhim
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f1', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f1', 'mizraim', 'parent'),
    ('bible', 'bible-f1', 'ludim', 'child'),
    ('bible', 'bible-f1', 'anamim', 'child'),
    ('bible', 'bible-f1', 'lehabim', 'child'),
    ('bible', 'bible-f1', 'nephtuihim', 'child'),
    ('bible', 'bible-f1', 'pethusim', 'child'),
    ('bible', 'bible-f1', 'caphtorim', 'child'),
    ('bible', 'bible-f1', 'casluhim', 'child');
-- bible-f2: Ham + Egyptus → Cush, Phut, Canaan, Mizraim
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f2', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f2', 'ham', 'parent'),
    ('bible', 'bible-f2', 'egyptus', 'parent'),
    ('bible', 'bible-f2', 'cush', 'child'),
    ('bible', 'bible-f2', 'phut', 'child'),
    ('bible', 'bible-f2', 'canaan', 'child'),
    ('bible', 'bible-f2', 'mizraim', 'child');
-- bible-f3: Cush → Raamah, Sabtah, Havilah, Sabtecha, Seba, Nimrod
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f3', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f3', 'cush', 'parent'),
    ('bible', 'bible-f3', 'raamah', 'child'),
    ('bible', 'bible-f3', 'sabtah', 'child'),
    ('bible', 'bible-f3', 'havilah', 'child'),
    ('bible', 'bible-f3', 'sabtecha', 'child'),
    ('bible', 'bible-f3', 'seba', 'child'),
    ('bible', 'bible-f3', 'nimrod', 'child');
-- bible-f4: Raamah → Sheba, Dedan
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f4', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f4', 'raamah', 'parent'),
    ('bible', 'bible-f4', 'sheba', 'child'),
    ('bible', 'bible-f4', 'dedan', 'child');
-- bible-f5: Canaan → Sidon, Heth, Jebusite, Amorite, Girgassite, Hivite, Arkite, Sirite, Arvadite, Zemarite, Hamathite
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f5', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f5', 'canaan', 'parent'),
    ('bible', 'bible-f5', 'sidon', 'child'),
    ('bible', 'bible-f5', 'heth', 'child'),
    ('bible', 'bible-f5', 'jebusite', 'child'),
    ('bible', 'bible-f5', 'amorite', 'child'),
    ('bible', 'bible-f5', 'girgassite', 'child'),
    ('bible', 'bible-f5', 'hivite', 'child'),
    ('bible', 'bible-f5', 'arkite', 'child'),
    ('bible', 'bible-f5', 'sirite', 'child'),
    ('bible', 'bible-f5', 'arvadite', 'child'),
    ('bible', 'bible-f5', 'zemarite', 'child'),
    ('bible', 'bible-f5', 'hamathite', 'child');
-- bible-f6: Nahor + Reumah → Tebah, Gaham, Thahash, Maachah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f6', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f6', 'nahor-2', 'parent'),
    ('bible', 'bible-f6', 'reumah', 'parent'),
    ('bible', 'bible-f6', 'tebah', 'child'),
    ('bible', 'bible-f6', 'gaham', 'child'),
    ('bible', 'bible-f6', 'thahash', 'child'),
    ('bible', 'bible-f6', 'maachah', 'child');
-- bible-f7: Jacob (Israel) + Leah → Levi, Simeon, Judah (Judas), Zebulun, Reuben, Dinah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f7', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f7', 'jacob', 'parent'),
    ('bible', 'bible-f7', 'leah', 'parent'),
    ('bible', 'bible-f7', 'levi', 'child'),
    ('bible', 'bible-f7', 'simeon', 'child'),
    ('bible', 'bible-f7', 'judah-judas', 'child'),
    ('bible', 'bible-f7', 'zebulun', 'child'),
    ('bible', 'bible-f7', 'reuben', 'child'),
    ('bible', 'bible-f7', 'dinah', 'child');
-- bible-f8: Leah (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f8', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f8', 'leah', 'parent');
-- bible-f9: Laban → Leah, Rachal
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f9', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f9', 'laban', 'parent'),
    ('bible', 'bible-f9', 'leah', 'child'),
    ('bible', 'bible-f9', 'rachal', 'child');
-- bible-f10: Jacob (Israel) + Rachal → Joseph, Benjaman
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f10', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f10', 'jacob', 'parent'),
    ('bible', 'bible-f10', 'rachal', 'parent'),
    ('bible', 'bible-f10', 'joseph', 'child'),
    ('bible', 'bible-f10', 'benjaman', 'child');
-- bible-f11: Jacob (Israel) + Bilhah → Dan, Naphtali
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f11', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f11', 'jacob', 'parent'),
    ('bible', 'bible-f11', 'bilhah', 'parent'),
    ('bible', 'bible-f11', 'dan', 'child'),
    ('bible', 'bible-f11', 'naphtali', 'child');
-- bible-f12: Jacob (Israel) + Zalpah → Gad, Asher
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f12', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f12', 'jacob', 'parent'),
    ('bible', 'bible-f12', 'zalpah', 'parent'),
    ('bible', 'bible-f12', 'gad', 'child'),
    ('bible', 'bible-f12', 'asher', 'child');
-- bible-f13: Isaac + Rebekah → Jacob (Israel), Esau
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f13', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f13', 'isaac', 'parent'),
    ('bible', 'bible-f13', 'rebekah', 'parent'),
    ('bible', 'bible-f13', 'jacob', 'child'),
    ('bible', 'bible-f13', 'esau', 'child');
-- bible-f14: Abraham (Abram) + Sarai (Sarah) → Isaac
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f14', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f14', 'abraham-abram', 'parent'),
    ('bible', 'bible-f14', 'sarai', 'parent'),
    ('bible', 'bible-f14', 'isaac', 'child');
-- bible-f15: Bethuel → Rebekah, Laban
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f15', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f15', 'bethuel', 'parent'),
    ('bible', 'bible-f15', 'rebekah', 'child'),
    ('bible', 'bible-f15', 'laban', 'child');
-- bible-f16: Abraham (Abram) + Hagar → Ishmael
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f16', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f16', 'abraham-abram', 'parent'),
    ('bible', 'bible-f16', 'hagar', 'parent'),
    ('bible', 'bible-f16', 'ishmael', 'child');
-- bible-f17: Abraham (Abram) + Keturah → Zemran, Jokshon, Madan, Ishbak, Shuah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f17', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f17', 'abraham-abram', 'parent'),
    ('bible', 'bible-f17', 'keturah', 'parent'),
    ('bible', 'bible-f17', 'zemran', 'child'),
    ('bible', 'bible-f17', 'jokshon', 'child'),
    ('bible', 'bible-f17', 'madan', 'child'),
    ('bible', 'bible-f17', 'ishbak', 'child'),
    ('bible', 'bible-f17', 'shuah', 'child');
-- bible-f18: Terah → Abraham (Abram), Haran, Nahor
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f18', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f18', 'terah', 'parent'),
    ('bible', 'bible-f18', 'abraham-abram', 'child'),
    ('bible', 'bible-f18', 'haran', 'child'),
    ('bible', 'bible-f18', 'nahor-2', 'child');
-- bible-f19: Nahor → Terah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f19', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f19', 'nahor', 'parent'),
    ('bible', 'bible-f19', 'terah', 'child');
-- bible-f20: Serug → Nahor
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f20', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f20', 'serug', 'parent'),
    ('bible', 'bible-f20', 'nahor', 'child');
-- bible-f21: Reu → Serug
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f21', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f21', 'reu', 'parent'),
    ('bible', 'bible-f21', 'serug', 'child');
-- bible-f22: Peleg → Reu
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f22', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f22', 'peleg', 'parent'),
    ('bible', 'bible-f22', 'reu', 'child');
-- bible-f23: Eber → Jokan, Peleg
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f23', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f23', 'eber', 'parent'),
    ('bible', 'bible-f23', 'jokan', 'child'),
    ('bible', 'bible-f23', 'peleg', 'child');
-- bible-f24: Salah → Eber
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f24', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f24', 'salah', 'parent'),
    ('bible', 'bible-f24', 'eber', 'child');
-- bible-f25: Arphaxad → Salah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f25', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f25', 'arphaxad', 'parent'),
    ('bible', 'bible-f25', 'salah', 'child');
-- bible-f26: Shem → Arphaxad, Aram, Asshur, Lud, Elam
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f26', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f26', 'shem', 'parent'),
    ('bible', 'bible-f26', 'arphaxad', 'child'),
    ('bible', 'bible-f26', 'aram', 'child'),
    ('bible', 'bible-f26', 'asshur', 'child'),
    ('bible', 'bible-f26', 'lud', 'child'),
    ('bible', 'bible-f26', 'elam', 'child');
-- bible-f27: Noah + Titea → Shem, Ham, Japheth
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f27', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f27', 'noah', 'parent'),
    ('bible', 'bible-f27', 'titea', 'parent'),
    ('bible', 'bible-f27', 'shem', 'child'),
    ('bible', 'bible-f27', 'ham', 'child'),
    ('bible', 'bible-f27', 'japheth', 'child');
-- bible-f28: Lamech → Noah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f28', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f28', 'lamech', 'parent'),
    ('bible', 'bible-f28', 'noah', 'child');
-- bible-f29: Methuselah → Lamech
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f29', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f29', 'methuselah', 'parent'),
    ('bible', 'bible-f29', 'lamech', 'child');
-- bible-f30: Enoch → Methuselah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f30', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f30', 'enoch', 'parent'),
    ('bible', 'bible-f30', 'methuselah', 'child');
-- bible-f31: Jared → Enoch
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f31', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f31', 'jared', 'parent'),
    ('bible', 'bible-f31', 'enoch', 'child');
-- bible-f32: Mahalaleel → Jared
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f32', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f32', 'mahalaleel', 'parent'),
    ('bible', 'bible-f32', 'jared', 'child');
-- bible-f33: Cainan → Mahalaleel
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f33', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f33', 'cainan', 'parent'),
    ('bible', 'bible-f33', 'mahalaleel', 'child');
-- bible-f34: Enos → Cainan
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f34', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f34', 'enos', 'parent'),
    ('bible', 'bible-f34', 'cainan', 'child');
-- bible-f35: Seth → Enos
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f35', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f35', 'seth', 'parent'),
    ('bible', 'bible-f35', 'enos', 'child');
-- bible-f36: Adam + Eve → Cain, Abel, Seth
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f36', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f36', 'adam', 'parent'),
    ('bible', 'bible-f36', 'eve', 'parent'),
    ('bible', 'bible-f36', 'cain', 'child'),
    ('bible', 'bible-f36', 'abel', 'child'),
    ('bible', 'bible-f36', 'seth', 'child');
-- bible-f37: Japheth → Meshech, Magog, Madai, Tubul, Gomor, Tiras, Javan
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f37', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f37', 'japheth', 'parent'),
    ('bible', 'bible-f37', 'meshech', 'child'),
    ('bible', 'bible-f37', 'magog', 'child'),
    ('bible', 'bible-f37', 'madai', 'child'),
    ('bible', 'bible-f37', 'tubul', 'child'),
    ('bible', 'bible-f37', 'gomor', 'child'),
    ('bible', 'bible-f37', 'tiras', 'child'),
    ('bible', 'bible-f37', 'javan', 'child');
-- bible-f38: Tait (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f38', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f38', 'tait', 'parent');
-- bible-f39: Oghaman → Tait
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f39', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f39', 'oghaman', 'parent'),
    ('bible', 'bible-f39', 'tait', 'child');
-- bible-f40: Beouman → Oghaman
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f40', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f40', 'beouman', 'parent'),
    ('bible', 'bible-f40', 'oghaman', 'child');
-- bible-f41: Heber Scut (Scott) → Beouman
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f41', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f41', 'heber-scut-scott', 'parent'),
    ('bible', 'bible-f41', 'beouman', 'child');
-- bible-f42: Sruth → Heber Scut (Scott)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f42', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f42', 'sruth', 'parent'),
    ('bible', 'bible-f42', 'heber-scut-scott', 'child');
-- bible-f43: Asruth (Easruth) → Sruth
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f43', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f43', 'asruth-easruth', 'parent'),
    ('bible', 'bible-f43', 'sruth', 'child');
-- bible-f44: Gaodhal Glas → Asruth (Easruth)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f44', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f44', 'gaodhal-glas', 'parent'),
    ('bible', 'bible-f44', 'asruth-easruth', 'child');
-- bible-f45: Niul + Scota → Gaodhal Glas
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f45', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f45', 'niul', 'parent'),
    ('bible', 'bible-f45', 'scota', 'parent'),
    ('bible', 'bible-f45', 'gaodhal-glas', 'child');
-- bible-f46: Niul (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f46', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f46', 'niul', 'parent');
-- bible-f47: King Phoeniusa Farsaidh of Scythia → Nenall, Niul
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f47', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f47', 'phoeniusa-farsaidh', 'parent'),
    ('bible', 'bible-f47', 'nenall', 'child'),
    ('bible', 'bible-f47', 'niul', 'child');
-- bible-f48: Boath → King Phoeniusa Farsaidh of Scythia
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f48', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f48', 'boath', 'parent'),
    ('bible', 'bible-f48', 'phoeniusa-farsaidh', 'child');
-- bible-f49: Magog → Boath
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f49', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f49', 'magog', 'parent'),
    ('bible', 'bible-f49', 'boath', 'child');
-- bible-f50: (parents unknown) → Scota
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f50', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f50', 'scota', 'child');
-- bible-f51: Nahor + Milcah → Bethuel, Huz, Buz, Kemuel, Chesed, Hazo, Pildesh, Jidlaph
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f51', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f51', 'nahor-2', 'parent'),
    ('bible', 'bible-f51', 'milcah', 'parent'),
    ('bible', 'bible-f51', 'bethuel', 'child'),
    ('bible', 'bible-f51', 'huz', 'child'),
    ('bible', 'bible-f51', 'buz', 'child'),
    ('bible', 'bible-f51', 'kemuel', 'child'),
    ('bible', 'bible-f51', 'chesed', 'child'),
    ('bible', 'bible-f51', 'hazo', 'child'),
    ('bible', 'bible-f51', 'pildesh', 'child'),
    ('bible', 'bible-f51', 'jidlaph', 'child');
-- bible-f52: Esau + Adah (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f52', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f52', 'esau', 'parent'),
    ('bible', 'bible-f52', 'adah', 'parent');
-- bible-f53: Lamech + Zilah → Trbal-Cain, Naamah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f53', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f53', 'lamech-2', 'parent'),
    ('bible', 'bible-f53', 'zilah', 'parent'),
    ('bible', 'bible-f53', 'trbal-cain', 'child'),
    ('bible', 'bible-f53', 'naamah', 'child');
-- bible-f54: Enoch → Irad
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f54', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f54', 'enoch-2', 'parent'),
    ('bible', 'bible-f54', 'irad', 'child');
-- bible-f55: Cain → Enoch
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f55', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f55', 'cain', 'parent'),
    ('bible', 'bible-f55', 'enoch-2', 'child');
-- bible-f56: Irad → Mahujael
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f56', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f56', 'irad', 'parent'),
    ('bible', 'bible-f56', 'mahujael', 'child');
-- bible-f57: Mahujael → Methusael
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f57', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f57', 'mahujael', 'parent'),
    ('bible', 'bible-f57', 'methusael', 'child');
-- bible-f58: Methusael → Lamech
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f58', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f58', 'methusael', 'parent'),
    ('bible', 'bible-f58', 'lamech-2', 'child');
-- bible-f59: Lamech + Adah → Jabal, Jubal
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f59', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f59', 'lamech-2', 'parent'),
    ('bible', 'bible-f59', 'adah-2', 'parent'),
    ('bible', 'bible-f59', 'jabal', 'child'),
    ('bible', 'bible-f59', 'jubal', 'child');
-- bible-f60: Gomor → Ashkeraz, Riphath, Togarmar
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f60', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f60', 'gomor', 'parent'),
    ('bible', 'bible-f60', 'ashkeraz', 'child'),
    ('bible', 'bible-f60', 'riphath', 'child'),
    ('bible', 'bible-f60', 'togarmar', 'child');
-- bible-f61: Javan → Tarshish, Elisaah, Kittim, Dodanim
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f61', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f61', 'javan', 'parent'),
    ('bible', 'bible-f61', 'tarshish', 'child'),
    ('bible', 'bible-f61', 'elisaah', 'child'),
    ('bible', 'bible-f61', 'kittim', 'child'),
    ('bible', 'bible-f61', 'dodanim', 'child');
-- bible-f62: Ashkeraz (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f62', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f62', 'ashkeraz', 'parent');
-- bible-f63: Casluhim → Philstem
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f63', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f63', 'casluhim', 'parent'),
    ('bible', 'bible-f63', 'philstem', 'child');
-- bible-f64: Aram → Hul, Mash, Uz, Gether
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f64', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f64', 'aram', 'parent'),
    ('bible', 'bible-f64', 'hul', 'child'),
    ('bible', 'bible-f64', 'mash', 'child'),
    ('bible', 'bible-f64', 'uz', 'child'),
    ('bible', 'bible-f64', 'gether', 'child');
-- bible-f65: Jokan → Almodad, Sheleph, Hazarmaveth, Jerah, Hadoram, Uzal, Diklah, Obal, Abimael, Sheba, Ophir, Havilah, Jobab
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f65', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f65', 'jokan', 'parent'),
    ('bible', 'bible-f65', 'almodad', 'child'),
    ('bible', 'bible-f65', 'sheleph', 'child'),
    ('bible', 'bible-f65', 'hazarmaveth', 'child'),
    ('bible', 'bible-f65', 'jerah', 'child'),
    ('bible', 'bible-f65', 'hadoram', 'child'),
    ('bible', 'bible-f65', 'uzal', 'child'),
    ('bible', 'bible-f65', 'diklah', 'child'),
    ('bible', 'bible-f65', 'obal', 'child'),
    ('bible', 'bible-f65', 'abimael', 'child'),
    ('bible', 'bible-f65', 'sheba-2', 'child'),
    ('bible', 'bible-f65', 'ophir', 'child'),
    ('bible', 'bible-f65', 'havilah-2', 'child'),
    ('bible', 'bible-f65', 'jobab', 'child');
-- bible-f66: Haran → Sarai (Sarah), Milcah, Lot, Iscah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f66', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f66', 'haran', 'parent'),
    ('bible', 'bible-f66', 'sarai', 'child'),
    ('bible', 'bible-f66', 'milcah', 'child'),
    ('bible', 'bible-f66', 'lot', 'child'),
    ('bible', 'bible-f66', 'iscah', 'child');
-- bible-f67: Lot + Elder daughter of Lot → Moab
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f67', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f67', 'lot', 'parent'),
    ('bible', 'bible-f67', 'lot-elder-daughter', 'parent'),
    ('bible', 'bible-f67', 'moab', 'child');
-- bible-f68: Lot + Younger daughter of Lot → Benammi
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f68', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f68', 'lot', 'parent'),
    ('bible', 'bible-f68', 'lot-younger-daughter', 'parent'),
    ('bible', 'bible-f68', 'benammi', 'child');
-- bible-f69: Lot → Elder daughter of Lot, Younger daughter of Lot
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f69', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f69', 'lot', 'parent'),
    ('bible', 'bible-f69', 'lot-elder-daughter', 'child'),
    ('bible', 'bible-f69', 'lot-younger-daughter', 'child');
-- bible-f70: Kemuel → Aram
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f70', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f70', 'kemuel', 'parent'),
    ('bible', 'bible-f70', 'aram-2', 'child');
-- bible-f71: Esau + Bashemath → Reuel (Jethro)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f71', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f71', 'esau', 'parent'),
    ('bible', 'bible-f71', 'bashemath', 'parent'),
    ('bible', 'bible-f71', 'reuel-jethro', 'child');
-- bible-f72: Follian (Falach) (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f72', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f72', 'follian-falach', 'parent');
-- bible-f73: Esau + Judith (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f73', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f73', 'esau', 'parent'),
    ('bible', 'bible-f73', 'judith', 'parent');
-- bible-f74: Anah → Aholitamah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f74', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f74', 'anah', 'parent'),
    ('bible', 'bible-f74', 'aholitamah', 'child');
-- bible-f75: Ishmael → Massa, Nebajoth, Hadar, Kendar, Tema, Adbeel, Jetur, Mibsam, Nephish, Mishma, Kedemah, Dumah, Bashemath
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f75', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f75', 'ishmael', 'parent'),
    ('bible', 'bible-f75', 'massa', 'child'),
    ('bible', 'bible-f75', 'nebajoth', 'child'),
    ('bible', 'bible-f75', 'hadar', 'child'),
    ('bible', 'bible-f75', 'kendar', 'child'),
    ('bible', 'bible-f75', 'tema', 'child'),
    ('bible', 'bible-f75', 'adbeel', 'child'),
    ('bible', 'bible-f75', 'jetur', 'child'),
    ('bible', 'bible-f75', 'mibsam', 'child'),
    ('bible', 'bible-f75', 'nephish', 'child'),
    ('bible', 'bible-f75', 'mishma', 'child'),
    ('bible', 'bible-f75', 'kedemah', 'child'),
    ('bible', 'bible-f75', 'dumah', 'child'),
    ('bible', 'bible-f75', 'bashemath', 'child');
-- bible-f76: Madan → Ephah, Epher, Hanoch, Abida, Eldaah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f76', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f76', 'madan', 'parent'),
    ('bible', 'bible-f76', 'ephah', 'child'),
    ('bible', 'bible-f76', 'epher', 'child'),
    ('bible', 'bible-f76', 'hanoch', 'child'),
    ('bible', 'bible-f76', 'abida', 'child'),
    ('bible', 'bible-f76', 'eldaah', 'child');
-- bible-f77: Dedan (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f77', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f77', 'dedan-2', 'parent');
-- bible-f78: Jokshon → Sheba, Dedan
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f78', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f78', 'jokshon', 'parent'),
    ('bible', 'bible-f78', 'sheba-3', 'child'),
    ('bible', 'bible-f78', 'dedan-2', 'child');
-- bible-f79: Esau + Aholitamah → Aeush, Jaalam, Korah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f79', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f79', 'esau', 'parent'),
    ('bible', 'bible-f79', 'aholitamah', 'parent'),
    ('bible', 'bible-f79', 'aeush', 'child'),
    ('bible', 'bible-f79', 'jaalam', 'child'),
    ('bible', 'bible-f79', 'korah', 'child');
-- bible-f80: Reuel (Jethro) → Nahath, Zarah, Shanmah, Zipporah, Mizzah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f80', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f80', 'reuel-jethro', 'parent'),
    ('bible', 'bible-f80', 'nahath', 'child'),
    ('bible', 'bible-f80', 'zarah', 'child'),
    ('bible', 'bible-f80', 'shanmah', 'child'),
    ('bible', 'bible-f80', 'zipporah', 'child'),
    ('bible', 'bible-f80', 'mizzah', 'child');
-- bible-f81: Zibeon → Anah, Ajah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f81', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f81', 'zibeon', 'parent'),
    ('bible', 'bible-f81', 'anah', 'child'),
    ('bible', 'bible-f81', 'ajah', 'child');
-- bible-f82: Dishon → Hemden, Eshben, Ithran, Cheran
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f82', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f82', 'dishon', 'parent'),
    ('bible', 'bible-f82', 'hemden', 'child'),
    ('bible', 'bible-f82', 'eshben', 'child'),
    ('bible', 'bible-f82', 'ithran', 'child'),
    ('bible', 'bible-f82', 'cheran', 'child');
-- bible-f83: Seir → Timna, Lotan, Stobal, Zibeon, Ezer, Dishan
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f83', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f83', 'seir', 'parent'),
    ('bible', 'bible-f83', 'timna', 'child'),
    ('bible', 'bible-f83', 'lotan', 'child'),
    ('bible', 'bible-f83', 'stobal', 'child'),
    ('bible', 'bible-f83', 'zibeon', 'child'),
    ('bible', 'bible-f83', 'ezer', 'child'),
    ('bible', 'bible-f83', 'dishan', 'child');
-- bible-f84: Lotan → Hori, Hemam
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f84', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f84', 'lotan', 'parent'),
    ('bible', 'bible-f84', 'hori', 'child'),
    ('bible', 'bible-f84', 'hemam', 'child');
-- bible-f85: Stobal → Alvan, Manahath, Ebal, Shepho, Onam
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f85', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f85', 'stobal', 'parent'),
    ('bible', 'bible-f85', 'alvan', 'child'),
    ('bible', 'bible-f85', 'manahath', 'child'),
    ('bible', 'bible-f85', 'ebal', 'child'),
    ('bible', 'bible-f85', 'shepho', 'child'),
    ('bible', 'bible-f85', 'onam', 'child');
-- bible-f86: Ezer → Bilhan, Zaavan, Akan
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f86', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f86', 'ezer', 'parent'),
    ('bible', 'bible-f86', 'bilhan', 'child'),
    ('bible', 'bible-f86', 'zaavan', 'child'),
    ('bible', 'bible-f86', 'akan', 'child');
-- bible-f87: Dishan → Uz, Aran
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f87', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f87', 'dishan', 'parent'),
    ('bible', 'bible-f87', 'uz-2', 'child'),
    ('bible', 'bible-f87', 'aran', 'child');
-- bible-f88: Eithriall → Follian (Falach)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f88', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f88', 'eithriall', 'parent'),
    ('bible', 'bible-f88', 'follian-falach', 'child');
-- bible-f89: King Irial Faidh of Ireland → Eithriall
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f89', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f89', 'irial-faidh', 'parent'),
    ('bible', 'bible-f89', 'eithriall', 'child');
-- bible-f90: Eochaid I (Heremon) Ireland + Princess Tamar Tephi of Judah → King Irial Faidh of Ireland
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f90', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f90', 'eochaid-i-heremon-ireland', 'parent'),
    ('bible', 'bible-f90', 'tamar-tephi', 'parent'),
    ('bible', 'bible-f90', 'irial-faidh', 'child');
-- bible-f91: King Mattaniah (Zedekiah) of Judah → Mulek, Princess Tamar Tephi of Judah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f91', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f91', 'mattaniah', 'parent'),
    ('bible', 'bible-f91', 'mulek', 'child'),
    ('bible', 'bible-f91', 'tamar-tephi', 'child');
-- bible-f92: King Josiah of Judah + Hammutal, daughter of Jeremiah → King Mattaniah (Zedekiah) of Judah, Shallum
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f92', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f92', 'josiah', 'parent'),
    ('bible', 'bible-f92', 'hammutal', 'parent'),
    ('bible', 'bible-f92', 'mattaniah', 'child'),
    ('bible', 'bible-f92', 'shallum-2', 'child');
-- bible-f93: King Josiah of Judah → Johanan, Jehoiakim
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f93', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f93', 'josiah', 'parent'),
    ('bible', 'bible-f93', 'johanan', 'child'),
    ('bible', 'bible-f93', 'jehoiakim', 'child');
-- bible-f94: Jeremiah the Prophet + Libnah → Hammutal, daughter of Jeremiah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f94', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f94', 'jeremiah', 'parent'),
    ('bible', 'bible-f94', 'libnah', 'parent'),
    ('bible', 'bible-f94', 'hammutal', 'child');
-- bible-f95: Hilkiah → Jeremiah the Prophet, Shaphan, Azaniah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f95', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f95', 'hilkiah', 'parent'),
    ('bible', 'bible-f95', 'jeremiah', 'child'),
    ('bible', 'bible-f95', 'shaphan', 'child'),
    ('bible', 'bible-f95', 'azaniah', 'child');
-- bible-f96: Shallum → Hilkiah, Hanameel
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f96', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f96', 'shallum', 'parent'),
    ('bible', 'bible-f96', 'hilkiah', 'child'),
    ('bible', 'bible-f96', 'hanameel', 'child');
-- bible-f97: Shaphan + Gemariah → Elasah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f97', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f97', 'shaphan', 'parent'),
    ('bible', 'bible-f97', 'gemariah', 'parent'),
    ('bible', 'bible-f97', 'elasah', 'child');
-- bible-f98: Ahitub → Zadok
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f98', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f98', 'ahitub', 'parent'),
    ('bible', 'bible-f98', 'zadok', 'child');
-- bible-f99: Amariah → Ahitub
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f99', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f99', 'amariah', 'parent'),
    ('bible', 'bible-f99', 'ahitub', 'child');
-- bible-f100: Azariah → Amariah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f100', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f100', 'azariah', 'parent'),
    ('bible', 'bible-f100', 'amariah', 'child');
-- bible-f101: Ezra + Holdiah → Jether, Mered, Ephar, Jalon
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f101', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f101', 'ezra', 'parent'),
    ('bible', 'bible-f101', 'holdiah', 'parent'),
    ('bible', 'bible-f101', 'jether', 'child'),
    ('bible', 'bible-f101', 'mered', 'child'),
    ('bible', 'bible-f101', 'ephar', 'child'),
    ('bible', 'bible-f101', 'jalon', 'child');
-- bible-f102: Ezra + Jehudisah → Miriam, Shammai, Jerad, Heber, Ishbah, Jekuthiel
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f102', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f102', 'ezra', 'parent'),
    ('bible', 'bible-f102', 'jehudisah', 'parent'),
    ('bible', 'bible-f102', 'miriam', 'child'),
    ('bible', 'bible-f102', 'shammai', 'child'),
    ('bible', 'bible-f102', 'jerad', 'child'),
    ('bible', 'bible-f102', 'heber', 'child'),
    ('bible', 'bible-f102', 'ishbah', 'child'),
    ('bible', 'bible-f102', 'jekuthiel', 'child');
-- bible-f103: Seriah → Josedech, Ezra
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f103', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f103', 'seriah', 'parent'),
    ('bible', 'bible-f103', 'josedech', 'child'),
    ('bible', 'bible-f103', 'ezra', 'child');
-- bible-f104: Zadok → Shallum
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f104', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f104', 'zadok', 'parent'),
    ('bible', 'bible-f104', 'shallum', 'child');
-- bible-f105: Meraioth → Azariah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f105', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f105', 'meraioth', 'parent'),
    ('bible', 'bible-f105', 'azariah', 'child');
-- bible-f106: Zerahiah → Meraioth
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f106', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f106', 'zerahiah', 'parent'),
    ('bible', 'bible-f106', 'meraioth', 'child');
-- bible-f107: Uzzi → Zerahiah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f107', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f107', 'uzzi', 'parent'),
    ('bible', 'bible-f107', 'zerahiah', 'child');
-- bible-f108: Bukki → Uzzi
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f108', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f108', 'bukki', 'parent'),
    ('bible', 'bible-f108', 'uzzi', 'child');
-- bible-f109: Abishuah → Bukki
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f109', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f109', 'abishuah', 'parent'),
    ('bible', 'bible-f109', 'bukki', 'child');
-- bible-f110: Phineas → Abishuah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f110', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f110', 'phineas', 'parent'),
    ('bible', 'bible-f110', 'abishuah', 'child');
-- bible-f111: Eleazer → Phineas
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f111', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f111', 'eleazer', 'parent'),
    ('bible', 'bible-f111', 'phineas', 'child');
-- bible-f112: Aaron + Elisheba → Eleazer
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f112', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f112', 'aaron', 'parent'),
    ('bible', 'bible-f112', 'elisheba', 'parent'),
    ('bible', 'bible-f112', 'eleazer', 'child');
-- bible-f113: Amram + Jochebed → Aaron, Mirham, Moses
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f113', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f113', 'amram', 'parent'),
    ('bible', 'bible-f113', 'jochebed', 'parent'),
    ('bible', 'bible-f113', 'aaron', 'child'),
    ('bible', 'bible-f113', 'mirham', 'child'),
    ('bible', 'bible-f113', 'moses', 'child');
-- bible-f114: Kohath → Amram
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f114', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f114', 'kohath', 'parent'),
    ('bible', 'bible-f114', 'amram', 'child');
-- bible-f115: Levi → Gershon, Kohath, Jochebed, Merari
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f115', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f115', 'levi', 'parent'),
    ('bible', 'bible-f115', 'gershon', 'child'),
    ('bible', 'bible-f115', 'kohath', 'child'),
    ('bible', 'bible-f115', 'jochebed', 'child'),
    ('bible', 'bible-f115', 'merari', 'child');
-- bible-f116: Joiadah (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f116', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f116', 'joiadah', 'parent');
-- bible-f117: Eliashib → Joiadah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f117', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f117', 'eliashib', 'parent'),
    ('bible', 'bible-f117', 'joiadah', 'child');
-- bible-f118: Joachim → Eliashib
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f118', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f118', 'joachim', 'parent'),
    ('bible', 'bible-f118', 'eliashib', 'child');
-- bible-f119: Joshuah → Joachim
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f119', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f119', 'joshuah', 'parent'),
    ('bible', 'bible-f119', 'joachim', 'child');
-- bible-f120: Josedech → Joshuah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f120', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f120', 'josedech', 'parent'),
    ('bible', 'bible-f120', 'joshuah', 'child');
-- bible-f121: Azaniah → Seriah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f121', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f121', 'azaniah', 'parent'),
    ('bible', 'bible-f121', 'seriah', 'child');
-- bible-f122: Merari → Mahali, Mushi
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f122', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f122', 'merari', 'parent'),
    ('bible', 'bible-f122', 'mahali', 'child'),
    ('bible', 'bible-f122', 'mushi', 'child');
-- bible-f123: Gershon → Libni, Shimi
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f123', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f123', 'gershon', 'parent'),
    ('bible', 'bible-f123', 'libni', 'child'),
    ('bible', 'bible-f123', 'shimi', 'child');
-- bible-f124: Moses + Zipporah → Gershom
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f124', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f124', 'moses', 'parent'),
    ('bible', 'bible-f124', 'zipporah', 'parent'),
    ('bible', 'bible-f124', 'gershom', 'child');
-- bible-f125: Ishbah → Eshteemca
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f125', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f125', 'ishbah', 'parent'),
    ('bible', 'bible-f125', 'eshteemca', 'child');
-- bible-f126: Jerad → Gedor
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f126', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f126', 'jerad', 'parent'),
    ('bible', 'bible-f126', 'gedor', 'child');
-- bible-f127: Heber → Socho
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f127', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f127', 'heber', 'parent'),
    ('bible', 'bible-f127', 'socho', 'child');
-- bible-f128: Jekuthiel → Zanoah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f128', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f128', 'jekuthiel', 'parent'),
    ('bible', 'bible-f128', 'zanoah', 'child');
-- bible-f129: Reuben → Hanoch, Phallu, Hezron, Carmi
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f129', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f129', 'reuben', 'parent'),
    ('bible', 'bible-f129', 'hanoch-2', 'child'),
    ('bible', 'bible-f129', 'phallu', 'child'),
    ('bible', 'bible-f129', 'hezron', 'child'),
    ('bible', 'bible-f129', 'carmi', 'child');
-- bible-f130: Jehoiakim → Jeconiah, Zedekiah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f130', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f130', 'jehoiakim', 'parent'),
    ('bible', 'bible-f130', 'jeconiah', 'child'),
    ('bible', 'bible-f130', 'zedekiah', 'child');
-- bible-f131: Jeconiah → Assir, Salathiel, Malchiram, Pedaiah, Shenazar, Jacamiah, Hoshama, Nedabiah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f131', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f131', 'jeconiah', 'parent'),
    ('bible', 'bible-f131', 'assir', 'child'),
    ('bible', 'bible-f131', 'salathiel', 'child'),
    ('bible', 'bible-f131', 'malchiram', 'child'),
    ('bible', 'bible-f131', 'pedaiah', 'child'),
    ('bible', 'bible-f131', 'shenazar', 'child'),
    ('bible', 'bible-f131', 'jacamiah', 'child'),
    ('bible', 'bible-f131', 'hoshama', 'child'),
    ('bible', 'bible-f131', 'nedabiah', 'child');
-- bible-f132: Pedaiah → Zerubbabel, Shimei
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f132', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f132', 'pedaiah', 'parent'),
    ('bible', 'bible-f132', 'zerubbabel', 'child'),
    ('bible', 'bible-f132', 'shimei', 'child');
-- bible-f133: Zerubbabel → Meshullam, Hananiah, Saeloith
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f133', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f133', 'zerubbabel', 'parent'),
    ('bible', 'bible-f133', 'meshullam', 'child'),
    ('bible', 'bible-f133', 'hananiah', 'child'),
    ('bible', 'bible-f133', 'saeloith', 'child');
-- bible-f134: Meshullam (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f134', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f134', 'meshullam', 'parent');
-- bible-f135: Hananiah (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f135', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f135', 'hananiah', 'parent');
-- bible-f136: Rephaiah + Saeloith (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f136', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f136', 'rephaiah', 'parent'),
    ('bible', 'bible-f136', 'saeloith', 'parent');
-- bible-f137: Simeon → Jemeul, Jamin, Ohad, Jachin, Zohar
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f137', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f137', 'simeon', 'parent'),
    ('bible', 'bible-f137', 'jemeul', 'child'),
    ('bible', 'bible-f137', 'jamin', 'child'),
    ('bible', 'bible-f137', 'ohad', 'child'),
    ('bible', 'bible-f137', 'jachin', 'child'),
    ('bible', 'bible-f137', 'zohar', 'child');
-- bible-f138: Simeon → Shaul, Jachin, Jamin, Jemeul, Ohad, Zohar
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f138', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f138', 'simeon', 'parent'),
    ('bible', 'bible-f138', 'shaul', 'child'),
    ('bible', 'bible-f138', 'jachin', 'child'),
    ('bible', 'bible-f138', 'jamin', 'child'),
    ('bible', 'bible-f138', 'jemeul', 'child'),
    ('bible', 'bible-f138', 'ohad', 'child'),
    ('bible', 'bible-f138', 'zohar', 'child');
-- bible-f139: King García II of Navarre + Chimene (Ximena) → King Sancho III of Navarre
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f139', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f139', 'garcia-ii', 'parent'),
    ('bible', 'bible-f139', 'chimene-ximena', 'parent'),
    ('bible', 'bible-f139', 'sancho-iii', 'child');
-- bible-f140: Sancho II + Urraca → King García II of Navarre
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f140', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f140', 'sancho-ii', 'parent'),
    ('bible', 'bible-f140', 'urraca', 'parent'),
    ('bible', 'bible-f140', 'garcia-ii', 'child');
-- bible-f141: King Sancho III of Navarre + Munia (Ninia) (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f141', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f141', 'sancho-iii', 'parent'),
    ('bible', 'bible-f141', 'munia-ninia', 'parent');
-- bible-f142: Sancho I + Theuda (Toda) → Sancho II
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f142', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f142', 'sancho-i', 'parent'),
    ('bible', 'bible-f142', 'theuda-toda', 'parent'),
    ('bible', 'bible-f142', 'sancho-ii', 'child');
-- bible-f143: (parents unknown) → Urraca
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f143', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f143', 'urraca', 'child');
-- bible-f144: Azuarius → Theuda (Toda)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f144', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f144', 'azuarius', 'parent'),
    ('bible', 'bible-f144', 'theuda-toda', 'child');
-- bible-f145: Ram → Amminadab
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f145', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f145', 'ram', 'parent'),
    ('bible', 'bible-f145', 'amminadab', 'child');
-- bible-f146: Hezron → Ram
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f146', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f146', 'hezron-2', 'parent'),
    ('bible', 'bible-f146', 'ram', 'child');
-- bible-f147: Amminadab → Nashon (Naasson)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f147', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f147', 'amminadab', 'parent'),
    ('bible', 'bible-f147', 'nashon-naasson', 'child');
-- bible-f148: Jesse → King David of Judah and Israel
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f148', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f148', 'jesse', 'parent'),
    ('bible', 'bible-f148', 'david', 'child');
-- bible-f149: Salmon + Rahab (Rachab) → Boas
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f149', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f149', 'salmon', 'parent'),
    ('bible', 'bible-f149', 'rahab-rachab', 'parent'),
    ('bible', 'bible-f149', 'boas', 'child');
-- bible-f150: Nashon (Naasson) → Salmon
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f150', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f150', 'nashon-naasson', 'parent'),
    ('bible', 'bible-f150', 'salmon', 'child');
-- bible-f151: Judah (Judas) + Shuah → Er, Shelah, Onan
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f151', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f151', 'judah-judas', 'parent'),
    ('bible', 'bible-f151', 'shuah-2', 'parent'),
    ('bible', 'bible-f151', 'er', 'child'),
    ('bible', 'bible-f151', 'shelah', 'child'),
    ('bible', 'bible-f151', 'onan', 'child');
-- bible-f152: Boas + Ruth of Moab → Obed
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f152', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f152', 'boas', 'parent'),
    ('bible', 'bible-f152', 'ruth', 'parent'),
    ('bible', 'bible-f152', 'obed', 'child');
-- bible-f153: Obed → Jesse
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f153', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f153', 'obed', 'parent'),
    ('bible', 'bible-f153', 'jesse', 'child');
-- bible-f154: Pharez → Hezron, Hamul
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f154', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f154', 'pharez', 'parent'),
    ('bible', 'bible-f154', 'hezron-2', 'child'),
    ('bible', 'bible-f154', 'hamul', 'child');
-- bible-f155: Judah (Judas) + Tamar → Pharez, Zarah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f155', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f155', 'judah-judas', 'parent'),
    ('bible', 'bible-f155', 'tamar', 'parent'),
    ('bible', 'bible-f155', 'pharez', 'child'),
    ('bible', 'bible-f155', 'zarah-2', 'child');
-- bible-f156: Vingener (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f156', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f156', 'vingener', 'parent');
-- bible-f157: Tror (Thor) → Vingener
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f157', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f157', 'tror-thor', 'parent'),
    ('bible', 'bible-f157', 'vingener', 'child');
-- bible-f158: Memnon + Daughter of Priam → Tror (Thor)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f158', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f158', 'memnon', 'parent'),
    ('bible', 'bible-f158', 'priam-daughter', 'parent'),
    ('bible', 'bible-f158', 'tror-thor', 'child');
-- bible-f159: King Priam of Troy → Daughter of Priam
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f159', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f159', 'priam', 'parent'),
    ('bible', 'bible-f159', 'priam-daughter', 'child');
-- bible-f160: Lamoedon → King Priam of Troy
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f160', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f160', 'lamoedon', 'parent'),
    ('bible', 'bible-f160', 'priam', 'child');
-- bible-f161: Ilus → Lamoedon
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f161', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f161', 'ilus', 'parent'),
    ('bible', 'bible-f161', 'lamoedon', 'child');
-- bible-f162: King Tros of Troy → Assaracus, Ilus
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f162', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f162', 'tros', 'parent'),
    ('bible', 'bible-f162', 'assaracus', 'child'),
    ('bible', 'bible-f162', 'ilus', 'child');
-- bible-f163: Erichthonius → King Tros of Troy
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f163', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f163', 'erichthonius', 'parent'),
    ('bible', 'bible-f163', 'tros', 'child');
-- bible-f164: Darda → Erichthonius
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f164', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f164', 'darda', 'parent'),
    ('bible', 'bible-f164', 'erichthonius', 'child');
-- bible-f165: Zarah → Darda
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f165', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f165', 'zarah-2', 'parent'),
    ('bible', 'bible-f165', 'darda', 'child');
-- bible-f166: Er + Tamar (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f166', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f166', 'er', 'parent'),
    ('bible', 'bible-f166', 'tamar', 'parent');
-- bible-f167: Silvius → Brutus of Britain
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f167', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f167', 'silvius', 'parent'),
    ('bible', 'bible-f167', 'brutus', 'child');
-- bible-f168: Aeneas → Silvius
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f168', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f168', 'aeneas', 'parent'),
    ('bible', 'bible-f168', 'silvius', 'child');
-- bible-f169: Anchises → Aeneas
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f169', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f169', 'anchises', 'parent'),
    ('bible', 'bible-f169', 'aeneas', 'child');
-- bible-f170: Capps → Anchises
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f170', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f170', 'capps', 'parent'),
    ('bible', 'bible-f170', 'anchises', 'child');
-- bible-f171: Assaracus → Azuarius, Capps
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f171', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f171', 'assaracus', 'parent'),
    ('bible', 'bible-f171', 'azuarius', 'child'),
    ('bible', 'bible-f171', 'capps', 'child');
-- bible-f172: Brutus of Britain (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f172', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f172', 'brutus', 'parent');
-- bible-f173: Issachar → Tola, Shimron, Phuvah, Job
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f173', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f173', 'issachar', 'parent'),
    ('bible', 'bible-f173', 'tola', 'child'),
    ('bible', 'bible-f173', 'shimron', 'child'),
    ('bible', 'bible-f173', 'phuvah', 'child'),
    ('bible', 'bible-f173', 'job', 'child');
-- bible-f174: Zebulun → Sered, Elon, Jahleel
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f174', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f174', 'zebulun', 'parent'),
    ('bible', 'bible-f174', 'sered', 'child'),
    ('bible', 'bible-f174', 'elon', 'child'),
    ('bible', 'bible-f174', 'jahleel', 'child');
-- bible-f175: King Joash of Judah → Amaziah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f175', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f175', 'joash', 'parent'),
    ('bible', 'bible-f175', 'amaziah', 'child');
-- bible-f176: Ahaziah + Athaliah → King Joash of Judah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f176', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f176', 'ahaziah', 'parent'),
    ('bible', 'bible-f176', 'athaliah', 'parent'),
    ('bible', 'bible-f176', 'joash', 'child');
-- bible-f177: Amaziah → Uzziah (Azariah)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f177', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f177', 'amaziah', 'parent'),
    ('bible', 'bible-f177', 'uzziah-azariah', 'child');
-- bible-f178: King Solomon of Judah + Princess Nabah → Rehoboam (Roboam)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f178', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f178', 'solomon', 'parent'),
    ('bible', 'bible-f178', 'nabah', 'parent'),
    ('bible', 'bible-f178', 'rehoboam-roboam', 'child');
-- bible-f179: King David of Judah and Israel + Bathsheba → Shimea, Shabod, Nathan, King Solomon of Judah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f179', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f179', 'david', 'parent'),
    ('bible', 'bible-f179', 'bathsheba', 'parent'),
    ('bible', 'bible-f179', 'shimea', 'child'),
    ('bible', 'bible-f179', 'shabod', 'child'),
    ('bible', 'bible-f179', 'nathan', 'child'),
    ('bible', 'bible-f179', 'solomon', 'child');
-- bible-f180: Rehoboam (Roboam) → Abia
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f180', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f180', 'rehoboam-roboam', 'parent'),
    ('bible', 'bible-f180', 'abia', 'child');
-- bible-f181: Nathan → Mattatha
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f181', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f181', 'nathan', 'parent'),
    ('bible', 'bible-f181', 'mattatha', 'child');
-- bible-f182: Abia → King Asa of Judah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f182', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f182', 'abia', 'parent'),
    ('bible', 'bible-f182', 'asa', 'child');
-- bible-f183: King Asa of Judah → Josaphat
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f183', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f183', 'asa', 'parent'),
    ('bible', 'bible-f183', 'josaphat', 'child');
-- bible-f184: Josaphat → King Jehoram (Joram) of Judah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f184', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f184', 'josaphat', 'parent'),
    ('bible', 'bible-f184', 'jehoram', 'child');
-- bible-f185: King Jehoram (Joram) of Judah → Ozias, Ahaziah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f185', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f185', 'jehoram', 'parent'),
    ('bible', 'bible-f185', 'ozias', 'child'),
    ('bible', 'bible-f185', 'ahaziah', 'child');
-- bible-f186: Uzziah (Azariah) → King Jotham of Judah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f186', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f186', 'uzziah-azariah', 'parent'),
    ('bible', 'bible-f186', 'jotham', 'child');
-- bible-f187: King Jotham of Judah → Ahaz
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f187', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f187', 'jotham', 'parent'),
    ('bible', 'bible-f187', 'ahaz', 'child');
-- bible-f188: Ahaz → Hezekiah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f188', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f188', 'ahaz', 'parent'),
    ('bible', 'bible-f188', 'hezekiah', 'child');
-- bible-f189: Hezekiah → Manasseh
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f189', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f189', 'hezekiah', 'parent'),
    ('bible', 'bible-f189', 'manasseh', 'child');
-- bible-f190: Manasseh → King Amon of Judah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f190', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f190', 'manasseh', 'parent'),
    ('bible', 'bible-f190', 'amon', 'child');
-- bible-f191: Aodh Glas (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f191', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f191', 'aodh-glas', 'parent');
-- bible-f192: (parents unknown) → Aodh Glas
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f192', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f192', 'aodh-glas', 'child');
-- bible-f193: King Amon of Judah → King Josiah of Judah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f193', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f193', 'amon', 'parent'),
    ('bible', 'bible-f193', 'josiah', 'child');
-- bible-f194: Joseph → Janna
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f194', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f194', 'joseph-2', 'parent'),
    ('bible', 'bible-f194', 'janna', 'child');
-- bible-f195: Mattathias + Daughter of Simon the Just → Joseph
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f195', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f195', 'mattathias', 'parent'),
    ('bible', 'bible-f195', 'simon-daughter', 'parent'),
    ('bible', 'bible-f195', 'joseph-2', 'child');
-- bible-f196: Amos → Mattathias
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f196', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f196', 'amos', 'parent'),
    ('bible', 'bible-f196', 'mattathias', 'child');
-- bible-f197: Semei → Mattathias
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f197', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f197', 'semei', 'parent'),
    ('bible', 'bible-f197', 'mattathias-2', 'child');
-- bible-f198: Joseph → Semei
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f198', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f198', 'joseph-3', 'parent'),
    ('bible', 'bible-f198', 'semei', 'child');
-- bible-f199: Juda → Joseph
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f199', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f199', 'juda', 'parent'),
    ('bible', 'bible-f199', 'joseph-3', 'child');
-- bible-f200: Joanna → Juda
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f200', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f200', 'joanna', 'parent'),
    ('bible', 'bible-f200', 'juda', 'child');
-- bible-f201: Rhesa → Joanna
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f201', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f201', 'rhesa', 'parent'),
    ('bible', 'bible-f201', 'joanna', 'child');
-- bible-f202: Zorobabel → Rhesa
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f202', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f202', 'zorobabel', 'parent'),
    ('bible', 'bible-f202', 'rhesa', 'child');
-- bible-f203: Salathiel → Zorobabel
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f203', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f203', 'salathiel-2', 'parent'),
    ('bible', 'bible-f203', 'zorobabel', 'child');
-- bible-f204: Neri → Salathiel
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f204', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f204', 'neri', 'parent'),
    ('bible', 'bible-f204', 'salathiel-2', 'child');
-- bible-f205: Melchi → Neri
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f205', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f205', 'melchi', 'parent'),
    ('bible', 'bible-f205', 'neri', 'child');
-- bible-f206: Addi → Melchi
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f206', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f206', 'addi', 'parent'),
    ('bible', 'bible-f206', 'melchi', 'child');
-- bible-f207: Cosam → Addi
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f207', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f207', 'cosam', 'parent'),
    ('bible', 'bible-f207', 'addi', 'child');
-- bible-f208: Elmodam → Cosam
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f208', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f208', 'elmodam', 'parent'),
    ('bible', 'bible-f208', 'cosam', 'child');
-- bible-f209: Er → Elmodam
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f209', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f209', 'er-2', 'parent'),
    ('bible', 'bible-f209', 'elmodam', 'child');
-- bible-f210: Jose → Er
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f210', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f210', 'jose', 'parent'),
    ('bible', 'bible-f210', 'er-2', 'child');
-- bible-f211: Eliezer → Jose
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f211', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f211', 'eliezer', 'parent'),
    ('bible', 'bible-f211', 'jose', 'child');
-- bible-f212: Jorim → Eliezer
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f212', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f212', 'jorim', 'parent'),
    ('bible', 'bible-f212', 'eliezer', 'child');
-- bible-f213: Matthat → Jorim
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f213', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f213', 'matthat-2', 'parent'),
    ('bible', 'bible-f213', 'jorim', 'child');
-- bible-f214: Joseph + Mary → Jesus Christ
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f214', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f214', 'joseph-5', 'parent'),
    ('bible', 'bible-f214', 'mary', 'parent'),
    ('bible', 'bible-f214', 'jesus', 'child');
-- bible-f215: Levi → Matthat
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f215', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f215', 'levi-2', 'parent'),
    ('bible', 'bible-f215', 'matthat-2', 'child');
-- bible-f216: Simeon → Levi
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f216', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f216', 'simeon-2', 'parent'),
    ('bible', 'bible-f216', 'levi-2', 'child');
-- bible-f217: Juda → Simeon
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f217', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f217', 'juda-2', 'parent'),
    ('bible', 'bible-f217', 'simeon-2', 'child');
-- bible-f218: Joseph → Juda
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f218', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f218', 'joseph-4', 'parent'),
    ('bible', 'bible-f218', 'juda-2', 'child');
-- bible-f219: Jonan → Joseph
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f219', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f219', 'jonan', 'parent'),
    ('bible', 'bible-f219', 'joseph-4', 'child');
-- bible-f220: Eliakim → Jonan
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f220', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f220', 'eliakim', 'parent'),
    ('bible', 'bible-f220', 'jonan', 'child');
-- bible-f221: Melea → Eliakim
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f221', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f221', 'melea', 'parent'),
    ('bible', 'bible-f221', 'eliakim', 'child');
-- bible-f222: Menan → Melea
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f222', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f222', 'menan', 'parent'),
    ('bible', 'bible-f222', 'melea', 'child');
-- bible-f223: Mattatha → Menan
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f223', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f223', 'mattatha', 'parent'),
    ('bible', 'bible-f223', 'menan', 'child');
-- bible-f224: Amalech (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f224', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f224', 'amalech', 'parent');
-- bible-f225: King Beli the Great of the Britons → King Lud of the Britons, Amalech
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f225', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f225', 'beli', 'parent'),
    ('bible', 'bible-f225', 'lud-britons', 'child'),
    ('bible', 'bible-f225', 'amalech', 'child');
-- bible-f226: Manogan + Anna, cousin of Joseph → Penardin, King Beli the Great of the Britons
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f226', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f226', 'manogan', 'parent'),
    ('bible', 'bible-f226', 'anna', 'parent'),
    ('bible', 'bible-f226', 'penardin', 'child'),
    ('bible', 'bible-f226', 'beli', 'child');
-- bible-f227: Joseph → Anna, cousin of Joseph
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f227', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f227', 'joseph-6', 'parent'),
    ('bible', 'bible-f227', 'anna', 'child');
-- bible-f228: Matthat → Heli, Joseph
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f228', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f228', 'matthat', 'parent'),
    ('bible', 'bible-f228', 'heli', 'child'),
    ('bible', 'bible-f228', 'joseph-6', 'child');
-- bible-f229: Levi → Matthat
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f229', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f229', 'levi-3', 'parent'),
    ('bible', 'bible-f229', 'matthat', 'child');
-- bible-f230: Melchi → Levi
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f230', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f230', 'melchi-2', 'parent'),
    ('bible', 'bible-f230', 'levi-3', 'child');
-- bible-f231: Janna → Melchi
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f231', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f231', 'janna', 'parent'),
    ('bible', 'bible-f231', 'melchi-2', 'child');
-- bible-f232: Bran the Blessed (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f232', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f232', 'bran', 'parent');
-- bible-f233: Penardin + Llyr Lediaith (King Lear) → Bran the Blessed
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f233', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f233', 'penardin', 'parent'),
    ('bible', 'bible-f233', 'llyr', 'parent'),
    ('bible', 'bible-f233', 'bran', 'child');
-- bible-f234: Azor → Sadoc
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f234', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f234', 'azor', 'parent'),
    ('bible', 'bible-f234', 'sadoc', 'child');
-- bible-f235: Eliakim → Azor
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f235', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f235', 'eliakim-2', 'parent'),
    ('bible', 'bible-f235', 'azor', 'child');
-- bible-f236: King Lud of the Britons (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f236', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f236', 'lud-britons', 'parent');
-- bible-f237: Sadoc → Achim
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f237', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f237', 'sadoc', 'parent'),
    ('bible', 'bible-f237', 'achim', 'child');
-- bible-f238: Eleazar → Matthan
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f238', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f238', 'eleazar', 'parent'),
    ('bible', 'bible-f238', 'matthan', 'child');
-- bible-f239: Eliud → Eleazar
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f239', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f239', 'eliud', 'parent'),
    ('bible', 'bible-f239', 'eleazar', 'child');
-- bible-f240: Achim → Eliud
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f240', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f240', 'achim', 'parent'),
    ('bible', 'bible-f240', 'eliud', 'child');
-- bible-f241: Heli → Joseph
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f241', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f241', 'heli', 'parent'),
    ('bible', 'bible-f241', 'joseph-5', 'child');
-- bible-f242: Jacob → Mary
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f242', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f242', 'jacob-2', 'parent'),
    ('bible', 'bible-f242', 'mary', 'child');
-- bible-f243: Matthan → Elizabeth, cousin of Mary, Jacob
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f243', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f243', 'matthan', 'parent'),
    ('bible', 'bible-f243', 'elizabeth', 'child'),
    ('bible', 'bible-f243', 'jacob-2', 'child');
-- bible-f244: Abiud → Eliakim
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f244', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f244', 'abiud', 'parent'),
    ('bible', 'bible-f244', 'eliakim-2', 'child');
-- bible-f245: Zorobabel → Abiud
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f245', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f245', 'zorobabel-2', 'parent'),
    ('bible', 'bible-f245', 'abiud', 'child');
-- bible-f246: Salathiel → Zorobabel
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f246', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f246', 'salathiel-3', 'parent'),
    ('bible', 'bible-f246', 'zorobabel-2', 'child');
-- bible-f247: Jechonias → Salathiel
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f247', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f247', 'jechonias', 'parent'),
    ('bible', 'bible-f247', 'salathiel-3', 'child');
-- bible-f248: Josias → Jechonias
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f248', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f248', 'josias', 'parent'),
    ('bible', 'bible-f248', 'jechonias', 'child');
-- bible-f249: Amon → Josias
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f249', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f249', 'amon-2', 'parent'),
    ('bible', 'bible-f249', 'josias', 'child');
-- bible-f250: Manasses → Amon
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f250', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f250', 'manasses', 'parent'),
    ('bible', 'bible-f250', 'amon-2', 'child');
-- bible-f251: Ezekias → Manasses
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f251', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f251', 'ezekias', 'parent'),
    ('bible', 'bible-f251', 'manasses', 'child');
-- bible-f252: Achaz → Ezekias
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f252', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f252', 'achaz', 'parent'),
    ('bible', 'bible-f252', 'ezekias', 'child');
-- bible-f253: Joatham → Achaz
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f253', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f253', 'joatham', 'parent'),
    ('bible', 'bible-f253', 'achaz', 'child');
-- bible-f254: Ozias → Joatham
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f254', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f254', 'ozias', 'parent'),
    ('bible', 'bible-f254', 'joatham', 'child');
-- bible-f255: Mattathias → Maath
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f255', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f255', 'mattathias-2', 'parent'),
    ('bible', 'bible-f255', 'maath', 'child');
-- bible-f256: Maath → Nagga
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f256', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f256', 'maath', 'parent'),
    ('bible', 'bible-f256', 'nagga', 'child');
-- bible-f257: Nagga → Esli
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f257', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f257', 'nagga', 'parent'),
    ('bible', 'bible-f257', 'esli', 'child');
-- bible-f258: Esli → Naum
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f258', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f258', 'esli', 'parent'),
    ('bible', 'bible-f258', 'naum', 'child');
-- bible-f259: Elon → Adah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f259', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f259', 'elon-2', 'parent'),
    ('bible', 'bible-f259', 'adah', 'child');
-- bible-f260: Naum → Amos
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f260', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f260', 'naum', 'parent'),
    ('bible', 'bible-f260', 'amos', 'child');
-- bible-f261: King Sigurd I of Norway (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f261', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f261', 'sigurd-i', 'parent');
-- bible-f262: Zachariah + Elizabeth, cousin of Mary → John the Baptist
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f262', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f262', 'zachariah', 'parent'),
    ('bible', 'bible-f262', 'elizabeth', 'parent'),
    ('bible', 'bible-f262', 'john-baptist', 'child');
-- bible-f263: Iddo → Zachariah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f263', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f263', 'iddo', 'parent'),
    ('bible', 'bible-f263', 'zachariah', 'child');
-- bible-f264: Gad → Ziphion, Eri, Haggi, Arodi, Shuni, Areli, Ezbon
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f264', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f264', 'gad', 'parent'),
    ('bible', 'bible-f264', 'ziphion', 'child'),
    ('bible', 'bible-f264', 'eri', 'child'),
    ('bible', 'bible-f264', 'haggi', 'child'),
    ('bible', 'bible-f264', 'arodi', 'child'),
    ('bible', 'bible-f264', 'shuni', 'child'),
    ('bible', 'bible-f264', 'areli', 'child'),
    ('bible', 'bible-f264', 'ezbon', 'child');
-- bible-f265: Asher → Jimnah, Sarah, Ishuah, Isui, Beriah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f265', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f265', 'asher', 'parent'),
    ('bible', 'bible-f265', 'jimnah', 'child'),
    ('bible', 'bible-f265', 'sarah', 'child'),
    ('bible', 'bible-f265', 'ishuah', 'child'),
    ('bible', 'bible-f265', 'isui', 'child'),
    ('bible', 'bible-f265', 'beriah', 'child');
-- bible-f266: Beriah → Heber, Malchiel
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f266', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f266', 'beriah', 'parent'),
    ('bible', 'bible-f266', 'heber-2', 'child'),
    ('bible', 'bible-f266', 'malchiel', 'child');
-- bible-f267: Dan → Hushim
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f267', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f267', 'dan', 'parent'),
    ('bible', 'bible-f267', 'hushim', 'child');
-- bible-f268: Naphtali → Jahzeel, Guni, Jezer, Shillem
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f268', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f268', 'naphtali', 'parent'),
    ('bible', 'bible-f268', 'jahzeel', 'child'),
    ('bible', 'bible-f268', 'guni', 'child'),
    ('bible', 'bible-f268', 'jezer', 'child'),
    ('bible', 'bible-f268', 'shillem', 'child');
-- bible-f269: Joseph + Asenath → Manasseh, Ephraim
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f269', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f269', 'joseph', 'parent'),
    ('bible', 'bible-f269', 'asenath', 'parent'),
    ('bible', 'bible-f269', 'manasseh-2', 'child'),
    ('bible', 'bible-f269', 'ephraim', 'child');
-- bible-f270: Manasseh → Abiezer, Helek, Asriel, Shechem, Hepher, Shemida, MacHir
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f270', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f270', 'manasseh-2', 'parent'),
    ('bible', 'bible-f270', 'abiezer', 'child'),
    ('bible', 'bible-f270', 'helek', 'child'),
    ('bible', 'bible-f270', 'asriel', 'child'),
    ('bible', 'bible-f270', 'shechem', 'child'),
    ('bible', 'bible-f270', 'hepher-2', 'child'),
    ('bible', 'bible-f270', 'shemida', 'child'),
    ('bible', 'bible-f270', 'machir', 'child');
-- bible-f271: MacHir → Gilead, Bashan
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f271', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f271', 'machir', 'parent'),
    ('bible', 'bible-f271', 'gilead', 'child'),
    ('bible', 'bible-f271', 'bashan', 'child');
-- bible-f272: Gilead → Hepher
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f272', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f272', 'gilead', 'parent'),
    ('bible', 'bible-f272', 'hepher', 'child');
-- bible-f273: Hepher → Zelophehad
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f273', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f273', 'hepher', 'parent'),
    ('bible', 'bible-f273', 'zelophehad', 'child');
-- bible-f274: Zelophehad → Mahlah, Noah, Hoglah, Milcah, Tirzah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f274', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f274', 'zelophehad', 'parent'),
    ('bible', 'bible-f274', 'mahlah', 'child'),
    ('bible', 'bible-f274', 'noah-2', 'child'),
    ('bible', 'bible-f274', 'hoglah', 'child'),
    ('bible', 'bible-f274', 'milcah-2', 'child'),
    ('bible', 'bible-f274', 'tirzah', 'child');
-- bible-f275: Benjaman → Belah, Rosh, Ashbel, Huppim, Naaman, Ard, Becher, Gera, Eli, Muppim
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f275', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f275', 'benjaman', 'parent'),
    ('bible', 'bible-f275', 'belah', 'child'),
    ('bible', 'bible-f275', 'rosh', 'child'),
    ('bible', 'bible-f275', 'ashbel', 'child'),
    ('bible', 'bible-f275', 'huppim', 'child'),
    ('bible', 'bible-f275', 'naaman', 'child'),
    ('bible', 'bible-f275', 'ard', 'child'),
    ('bible', 'bible-f275', 'becher', 'child'),
    ('bible', 'bible-f275', 'gera', 'child'),
    ('bible', 'bible-f275', 'eli', 'child'),
    ('bible', 'bible-f275', 'muppim', 'child');
-- bible-f276: Lehi + Sariah → Laman, Lemul, Sam, Nephi, Joeph, Jacob
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f276', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f276', 'lehi', 'parent'),
    ('bible', 'bible-f276', 'sariah', 'parent'),
    ('bible', 'bible-f276', 'laman', 'child'),
    ('bible', 'bible-f276', 'lemul', 'child'),
    ('bible', 'bible-f276', 'sam', 'child'),
    ('bible', 'bible-f276', 'nephi', 'child'),
    ('bible', 'bible-f276', 'joeph', 'child'),
    ('bible', 'bible-f276', 'jacob-3', 'child');
-- bible-f277: Jacob → Enos
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f277', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f277', 'jacob-3', 'parent'),
    ('bible', 'bible-f277', 'enos-2', 'child');
-- bible-f278: Enos → Jarom
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f278', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f278', 'enos-2', 'parent'),
    ('bible', 'bible-f278', 'jarom', 'child');
-- bible-f279: Jarom → Omni
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f279', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f279', 'jarom', 'parent'),
    ('bible', 'bible-f279', 'omni', 'child');
-- bible-f280: Omni → Chemish, Amaron
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f280', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f280', 'omni', 'parent'),
    ('bible', 'bible-f280', 'chemish', 'child'),
    ('bible', 'bible-f280', 'amaron', 'child');
-- bible-f281: Mohonria Moriancuma → Pagag
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f281', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f281', 'mohonria-moriancuma', 'parent'),
    ('bible', 'bible-f281', 'pagag', 'child');
-- bible-f282: Father of Jared → Mohonria Moriancuma, Jared
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f282', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f282', 'father-of-jared', 'parent'),
    ('bible', 'bible-f282', 'mohonria-moriancuma', 'child'),
    ('bible', 'bible-f282', 'jared-2', 'child');
-- bible-f283: Orihah → Kib
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f283', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f283', 'orihah', 'parent'),
    ('bible', 'bible-f283', 'kib', 'child');
-- bible-f284: Jared → Gilgah, Jacon, Orihah, Mahah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f284', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f284', 'jared-2', 'parent'),
    ('bible', 'bible-f284', 'gilgah', 'child'),
    ('bible', 'bible-f284', 'jacon', 'child'),
    ('bible', 'bible-f284', 'orihah', 'child'),
    ('bible', 'bible-f284', 'mahah', 'child');
-- bible-f285: Kib → Corihor, Shule
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f285', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f285', 'kib', 'parent'),
    ('bible', 'bible-f285', 'corihor', 'child'),
    ('bible', 'bible-f285', 'shule', 'child');
-- bible-f286: Shule → Omer
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f286', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f286', 'shule', 'parent'),
    ('bible', 'bible-f286', 'omer', 'child');
-- bible-f287: Omer → Emer, Esrom, Corianumr, Jared
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f287', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f287', 'omer', 'parent'),
    ('bible', 'bible-f287', 'emer', 'child'),
    ('bible', 'bible-f287', 'esrom', 'child'),
    ('bible', 'bible-f287', 'corianumr', 'child'),
    ('bible', 'bible-f287', 'jared-3', 'child');
-- bible-f288: Emer → Coriantum
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f288', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f288', 'emer', 'parent'),
    ('bible', 'bible-f288', 'coriantum', 'child');
-- bible-f289: Coriantum → Com
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f289', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f289', 'coriantum', 'parent'),
    ('bible', 'bible-f289', 'com', 'child');
-- bible-f290: Com → Heth
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f290', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f290', 'com', 'parent'),
    ('bible', 'bible-f290', 'heth-2', 'child');
-- bible-f291: Heth → Shez
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f291', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f291', 'heth-2', 'parent'),
    ('bible', 'bible-f291', 'shez', 'child');
-- bible-f292: Shez → Riplakish
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f292', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f292', 'shez', 'parent'),
    ('bible', 'bible-f292', 'riplakish', 'child');
-- bible-f293: Riplakish → Morianton
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f293', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f293', 'riplakish', 'parent'),
    ('bible', 'bible-f293', 'morianton', 'child');
-- bible-f294: Morianton → Kim
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f294', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f294', 'morianton', 'parent'),
    ('bible', 'bible-f294', 'kim', 'child');
-- bible-f295: Kim → Levi
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f295', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f295', 'kim', 'parent'),
    ('bible', 'bible-f295', 'levi-4', 'child');
-- bible-f296: Levi → Corom
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f296', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f296', 'levi-4', 'parent'),
    ('bible', 'bible-f296', 'corom', 'child');
-- bible-f297: Corom → Kish
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f297', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f297', 'corom', 'parent'),
    ('bible', 'bible-f297', 'kish', 'child');
-- bible-f298: Kish → Lib
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f298', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f298', 'kish', 'parent'),
    ('bible', 'bible-f298', 'lib', 'child');
-- bible-f299: Lib → Heth
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f299', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f299', 'lib', 'parent'),
    ('bible', 'bible-f299', 'heth-3', 'child');
-- bible-f300: Heth → Aaron
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f300', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f300', 'heth-3', 'parent'),
    ('bible', 'bible-f300', 'aaron-2', 'child');
-- bible-f301: Aaron → Amnigaddah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f301', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f301', 'aaron-2', 'parent'),
    ('bible', 'bible-f301', 'amnigaddah', 'child');
-- bible-f302: Amnigaddah → Coriantam
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f302', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f302', 'amnigaddah', 'parent'),
    ('bible', 'bible-f302', 'coriantam', 'child');
-- bible-f303: Coriantam → Com
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f303', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f303', 'coriantam', 'parent'),
    ('bible', 'bible-f303', 'com-2', 'child');
-- bible-f304: Shiblon → Seth
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f304', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f304', 'shiblon', 'parent'),
    ('bible', 'bible-f304', 'seth-2', 'child');
-- bible-f305: Com → Shiblon
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f305', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f305', 'com-2', 'parent'),
    ('bible', 'bible-f305', 'shiblon', 'child');
-- bible-f306: Seth → Anah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f306', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f306', 'seth-2', 'parent'),
    ('bible', 'bible-f306', 'anah-2', 'child');
-- bible-f307: Anah → Ethem
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f307', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f307', 'anah-2', 'parent'),
    ('bible', 'bible-f307', 'ethem', 'child');
-- bible-f308: Ethem → Moron
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f308', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f308', 'ethem', 'parent'),
    ('bible', 'bible-f308', 'moron', 'child');
-- bible-f309: Moron → Coriantor
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f309', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f309', 'moron', 'parent'),
    ('bible', 'bible-f309', 'coriantor', 'child');
-- bible-f310: Coriantor → Ether
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f310', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f310', 'coriantor', 'parent'),
    ('bible', 'bible-f310', 'ether', 'child');
-- bible-f311: Akish + A Daughter of Jared → A Son of Alish, Nimrah
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f311', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f311', 'akish', 'parent'),
    ('bible', 'bible-f311', 'a-daughter-of-jared', 'parent'),
    ('bible', 'bible-f311', 'a-son-of-alish', 'child'),
    ('bible', 'bible-f311', 'nimrah', 'child');
-- bible-f312: Jared → A Daughter of Jared
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f312', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f312', 'jared-3', 'parent'),
    ('bible', 'bible-f312', 'a-daughter-of-jared', 'child');
-- bible-f313: Corihor → Noah, Cohor
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f313', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f313', 'corihor', 'parent'),
    ('bible', 'bible-f313', 'noah-3', 'child'),
    ('bible', 'bible-f313', 'cohor', 'child');
-- bible-f314: Noah → Cohor
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f314', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f314', 'noah-3', 'parent'),
    ('bible', 'bible-f314', 'cohor-2', 'child');
-- bible-f315: Cohor → Nimrod
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f315', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f315', 'cohor-2', 'parent'),
    ('bible', 'bible-f315', 'nimrod-2', 'child');
-- bible-f316: Anah → Dishon   [adoptive]
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f316', TRUE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f316', 'anah', 'parent'),
    ('bible', 'bible-f316', 'dishon', 'child');
-- bible-f317: Mariam (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('bible', 'bible-f317', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('bible', 'bible-f317', 'mariam', 'parent');


-- =================================================================================================
-- SAGA 16 of 17: BABYLONIAN GODS   [id: babylonian-gods, category: mythology]
-- Author:  Compiled by Juan Ignacio Pucheu
-- Medium:  GEDCOM genealogy (Babylonian+Gods.ged)
-- Canon:   As recorded in the GEDCOM file
-- Covers:  29 people and 9 families, imported from a public GEDCOM sample.
-- Rows:    1 houses, 29 people, 9 families, 40 members
-- =================================================================================================

-- ── Reset (removes this saga and, by cascade, all of its rows) ─────────────────────────────────
DELETE FROM saga WHERE id = 'babylonian-gods';

-- ── Saga ───────────────────────────────────────────────────────────────────────────────────────
INSERT INTO saga (id, category, position, title, work, medium, author, canon, genre, covers) VALUES
    ('babylonian-gods', 'mythology', 15, 'Babylonian Gods', 'Babylonian Gods', 'GEDCOM genealogy (Babylonian+Gods.ged)', 'Compiled by Juan Ignacio Pucheu', 'As recorded in the GEDCOM file', 'Mythology', '29 people and 9 families, imported from a public GEDCOM sample.');

-- ── Notes (modelling choices and where sources disagree) ───────────────────────────────────────
INSERT INTO saga_note (saga_id, position, note) VALUES
    ('babylonian-gods', 0, 'Imported from Babylonian+Gods.ged (UTF-8; PAF 5.2.18.0; file dated 22 Jul 2008) by scripts/gedcom-to-saga.mts.'),
    ('babylonian-gods', 1, 'Names are read in mythology mode: the deity''s name is the GEDCOM surname part, and descriptive text in the given-name part (e.g. "queen of the Gods") is dropped.'),
    ('babylonian-gods', 2, '1 display names were corrected from babylonian-gods.json, where the file put titles or epithets in the name (e.g. "(42 further names of Marduk)").'),
    ('babylonian-gods', 3, 'Everyone is in one house, "Babylonian pantheon": the file has no real surnames to group by.');

-- ── Houses (1) ─────────────────────────────────────────────────────────────────────────────────
INSERT INTO house (saga_id, name, color) VALUES
    ('babylonian-gods', 'Babylonian pantheon', '#4aa8c8');

-- ── People (29, grouped by house) ──────────────────────────────────────────────────────────────
-- Babylonian pantheon (29)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('babylonian-gods', 'primal-wasteland', 'Primal wasteland', 'Babylonian pantheon', 'm', NULL),
    ('babylonian-gods', 'apsu', 'Apsû', 'Babylonian pantheon', 'm', NULL),
    ('babylonian-gods', 'tiamat', 'Tiamat', 'Babylonian pantheon', 'f', NULL),
    ('babylonian-gods', 'mummu', 'Mummu', 'Babylonian pantheon', 'm', NULL),
    ('babylonian-gods', 'lahmu', 'Lahmu', 'Babylonian pantheon', 'm', NULL),
    ('babylonian-gods', 'lahamu', 'Lahamu', 'Babylonian pantheon', 'f', NULL),
    ('babylonian-gods', 'kingu', 'Kingu', 'Babylonian pantheon', 'm', NULL),
    ('babylonian-gods', 'sky-arch', 'Sky arch', 'Babylonian pantheon', 'm', NULL),
    ('babylonian-gods', 'world-of-men', 'World of men', 'Babylonian pantheon', 'm', NULL),
    ('babylonian-gods', 'dust', 'Dust', 'Babylonian pantheon', 'f', NULL),
    ('babylonian-gods', 'man', 'Man', 'Babylonian pantheon', 'm', NULL),
    ('babylonian-gods', 'anshar', 'Anshar', 'Babylonian pantheon', 'm', NULL),
    ('babylonian-gods', 'kishar', 'Kishar', 'Babylonian pantheon', 'f', NULL),
    ('babylonian-gods', 'ea', 'Ea', 'Babylonian pantheon', 'm', NULL),
    ('babylonian-gods', 'anu', 'Anu', 'Babylonian pantheon', 'm', NULL),
    ('babylonian-gods', 'anatu', 'Anatu', 'Babylonian pantheon', 'f', NULL),
    ('babylonian-gods', 'marduk', 'Marduk', 'Babylonian pantheon', 'm', NULL),
    ('babylonian-gods', 'sarpanitum', 'Sarpanitum', 'Babylonian pantheon', 'f', NULL),
    ('babylonian-gods', 'nabu', 'Nabu', 'Babylonian pantheon', 'm', NULL),
    ('babylonian-gods', 'tashmetum', 'Tashmetum', 'Babylonian pantheon', 'f', NULL),
    ('babylonian-gods', 'asaru', 'Asaru', 'Babylonian pantheon', 'm', NULL),
    ('babylonian-gods', 'asarualim', 'Asarualim', 'Babylonian pantheon', 'm', NULL),
    ('babylonian-gods', 'asarualimnunna', 'Asarualimnunna', 'Babylonian pantheon', 'm', NULL),
    ('babylonian-gods', 'asaruludu', 'Asaruludu', 'Babylonian pantheon', 'm', NULL),
    ('babylonian-gods', 'en-ki', 'En-Ki', 'Babylonian pantheon', 'm', NULL),
    ('babylonian-gods', 'namru', 'Namru', 'Babylonian pantheon', 'f', NULL),
    ('babylonian-gods', 'namtillaku', 'Namtillaku', 'Babylonian pantheon', 'f', NULL),
    ('babylonian-gods', 'tutu', 'Tutu', 'Babylonian pantheon', 'm', NULL),
    ('babylonian-gods', 'marduk-names', '(42 further names of Marduk)', 'Babylonian pantheon', 'm', NULL);

-- ── Families (9, each followed by its members) ─────────────────────────────────────────────────
-- babylonian-gods-f1: Primal wasteland → Apsû, Tiamat, Mummu
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('babylonian-gods', 'babylonian-gods-f1', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('babylonian-gods', 'babylonian-gods-f1', 'primal-wasteland', 'parent'),
    ('babylonian-gods', 'babylonian-gods-f1', 'apsu', 'child'),
    ('babylonian-gods', 'babylonian-gods-f1', 'tiamat', 'child'),
    ('babylonian-gods', 'babylonian-gods-f1', 'mummu', 'child');
-- babylonian-gods-f2: Apsû + Tiamat → Lahmu, Lahamu, Kingu, Sky arch, World of men
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('babylonian-gods', 'babylonian-gods-f2', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('babylonian-gods', 'babylonian-gods-f2', 'apsu', 'parent'),
    ('babylonian-gods', 'babylonian-gods-f2', 'tiamat', 'parent'),
    ('babylonian-gods', 'babylonian-gods-f2', 'lahmu', 'child'),
    ('babylonian-gods', 'babylonian-gods-f2', 'lahamu', 'child'),
    ('babylonian-gods', 'babylonian-gods-f2', 'kingu', 'child'),
    ('babylonian-gods', 'babylonian-gods-f2', 'sky-arch', 'child'),
    ('babylonian-gods', 'babylonian-gods-f2', 'world-of-men', 'child');
-- babylonian-gods-f3: Kingu + Dust → Man
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('babylonian-gods', 'babylonian-gods-f3', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('babylonian-gods', 'babylonian-gods-f3', 'kingu', 'parent'),
    ('babylonian-gods', 'babylonian-gods-f3', 'dust', 'parent'),
    ('babylonian-gods', 'babylonian-gods-f3', 'man', 'child');
-- babylonian-gods-f4: Lahmu + Lahamu → Anshar, Kishar
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('babylonian-gods', 'babylonian-gods-f4', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('babylonian-gods', 'babylonian-gods-f4', 'lahmu', 'parent'),
    ('babylonian-gods', 'babylonian-gods-f4', 'lahamu', 'parent'),
    ('babylonian-gods', 'babylonian-gods-f4', 'anshar', 'child'),
    ('babylonian-gods', 'babylonian-gods-f4', 'kishar', 'child');
-- babylonian-gods-f5: Anshar + Kishar → Ea, Anu, Anatu
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('babylonian-gods', 'babylonian-gods-f5', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('babylonian-gods', 'babylonian-gods-f5', 'anshar', 'parent'),
    ('babylonian-gods', 'babylonian-gods-f5', 'kishar', 'parent'),
    ('babylonian-gods', 'babylonian-gods-f5', 'ea', 'child'),
    ('babylonian-gods', 'babylonian-gods-f5', 'anu', 'child'),
    ('babylonian-gods', 'babylonian-gods-f5', 'anatu', 'child');
-- babylonian-gods-f6: Ea → Marduk
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('babylonian-gods', 'babylonian-gods-f6', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('babylonian-gods', 'babylonian-gods-f6', 'ea', 'parent'),
    ('babylonian-gods', 'babylonian-gods-f6', 'marduk', 'child');
-- babylonian-gods-f7: Marduk + Sarpanitum → Nabu
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('babylonian-gods', 'babylonian-gods-f7', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('babylonian-gods', 'babylonian-gods-f7', 'marduk', 'parent'),
    ('babylonian-gods', 'babylonian-gods-f7', 'sarpanitum', 'parent'),
    ('babylonian-gods', 'babylonian-gods-f7', 'nabu', 'child');
-- babylonian-gods-f8: Nabu + Tashmetum (no children)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('babylonian-gods', 'babylonian-gods-f8', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('babylonian-gods', 'babylonian-gods-f8', 'nabu', 'parent'),
    ('babylonian-gods', 'babylonian-gods-f8', 'tashmetum', 'parent');
-- babylonian-gods-f9: Anu → Asaru, Asarualim, Asarualimnunna, Asaruludu, En-Ki, Namru, Namtillaku, Tutu, (42 further names of Marduk)
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('babylonian-gods', 'babylonian-gods-f9', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('babylonian-gods', 'babylonian-gods-f9', 'anu', 'parent'),
    ('babylonian-gods', 'babylonian-gods-f9', 'asaru', 'child'),
    ('babylonian-gods', 'babylonian-gods-f9', 'asarualim', 'child'),
    ('babylonian-gods', 'babylonian-gods-f9', 'asarualimnunna', 'child'),
    ('babylonian-gods', 'babylonian-gods-f9', 'asaruludu', 'child'),
    ('babylonian-gods', 'babylonian-gods-f9', 'en-ki', 'child'),
    ('babylonian-gods', 'babylonian-gods-f9', 'namru', 'child'),
    ('babylonian-gods', 'babylonian-gods-f9', 'namtillaku', 'child'),
    ('babylonian-gods', 'babylonian-gods-f9', 'tutu', 'child'),
    ('babylonian-gods', 'babylonian-gods-f9', 'marduk-names', 'child');


-- =================================================================================================
-- SAGA 17 of 17: NEHRU–GANDHI FAMILY   [id: nehru-gandhi, category: history]
-- Author:  Compiled by Juan Ignacio Pucheu
-- Medium:  GEDCOM genealogy (Nehru-Ghandi+Family.ged)
-- Canon:   As recorded in the GEDCOM file
-- Covers:  32 people and 12 families, imported from a public GEDCOM sample.
-- Rows:    7 houses, 32 people, 12 families, 43 members
-- =================================================================================================

-- ── Reset (removes this saga and, by cascade, all of its rows) ─────────────────────────────────
DELETE FROM saga WHERE id = 'nehru-gandhi';

-- ── Saga ───────────────────────────────────────────────────────────────────────────────────────
INSERT INTO saga (id, category, position, title, work, medium, author, canon, genre, covers) VALUES
    ('nehru-gandhi', 'history', 16, 'Nehru–Gandhi Family', 'Nehru–Gandhi Family', 'GEDCOM genealogy (Nehru-Ghandi+Family.ged)', 'Compiled by Juan Ignacio Pucheu', 'As recorded in the GEDCOM file', 'History', '32 people and 12 families, imported from a public GEDCOM sample.');

-- ── Notes (modelling choices and where sources disagree) ───────────────────────────────────────
INSERT INTO saga_note (saga_id, position, note) VALUES
    ('nehru-gandhi', 0, 'Imported from Nehru-Ghandi+Family.ged (UTF-8; PAF 5.2.18.0; file dated 10 Jul 2008) by scripts/gedcom-to-saga.mts.'),
    ('nehru-gandhi', 1, 'Display names are the person''s name only; a monarch is shown by their regnal name (e.g. King Henry VIII). Titles, title dates and life dates are not imported.'),
    ('nehru-gandhi', 2, '11 names were corrected from nehru-gandhi.json, where the file writes them badly (e.g. "Gangadhar Nehru"); the reasons are in that file.'),
    ('nehru-gandhi', 3, 'Houses are surnames; only the 7 largest keep their own colour, the rest are grouped as "Other families".'),
    ('nehru-gandhi', 4, 'Import warnings: Bansi Dhar Nehru: sex not recorded as M or F, shown as male; Harsha Hutheesing: sex not recorded as M or F, shown as male');

-- ── Houses (7) ─────────────────────────────────────────────────────────────────────────────────
INSERT INTO house (saga_id, name, color) VALUES
    ('nehru-gandhi', 'Nehru', '#c8102e'),
    ('nehru-gandhi', 'Gandhi', '#e0b23a'),
    ('nehru-gandhi', 'Pandit', '#3b6fb6'),
    ('nehru-gandhi', 'Hutheesing', '#3f9a4b'),
    ('nehru-gandhi', 'Kaul', '#8a5fd0'),
    ('nehru-gandhi', 'Maino', '#e07a2e'),
    ('nehru-gandhi', 'Anand', '#4aa8c8');

-- ── People (32, grouped by house) ──────────────────────────────────────────────────────────────
-- Nehru (16)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('nehru-gandhi', 'gangadhar-nehru', 'Gangadhar Nehru', 'Nehru', 'm', NULL),
    ('nehru-gandhi', 'bansi-dhar-nehru', 'Bansi Dhar Nehru', 'Nehru', 'm', NULL),
    ('nehru-gandhi', 'nandlal-nehru', 'Nandlal Nehru', 'Nehru', 'm', NULL),
    ('nehru-gandhi', 'motilal-nehru', 'Motilal Nehru', 'Nehru', 'm', '1861-05-06'),
    ('nehru-gandhi', 'shyamlal-nehru', 'Shyamlal Nehru', 'Nehru', 'm', NULL),
    ('nehru-gandhi', 'uma-nehru', 'Uma Nehru', 'Nehru', 'f', NULL),
    ('nehru-gandhi', 'shyam-kumari-nehru', 'Shyam Kumari Nehru', 'Nehru', 'f', NULL),
    ('nehru-gandhi', 'arun-nehru', 'Arun Nehru', 'Nehru', 'm', NULL),
    ('nehru-gandhi', 'brijlal-nehru', 'Brijlal Nehru', 'Nehru', 'm', NULL),
    ('nehru-gandhi', 'rameshwari-raina', 'Rameshwari Raina', 'Nehru', 'f', '1886-00-00'),
    ('nehru-gandhi', 'braj-kumar-nehru', 'Braj Kumar Nehru', 'Nehru', 'm', '1909-09-04'),
    ('nehru-gandhi', 'swarup-rani', 'Swarup Rani', 'Nehru', 'f', NULL),
    ('nehru-gandhi', 'jawaharlal-nehru', 'Jawaharlal Nehru', 'Nehru', 'm', '1889-11-14'),
    ('nehru-gandhi', 'vijaya-lakshmi-nehru', 'Vijaya Lakshmi Nehru', 'Nehru', 'f', '1900-00-00'),
    ('nehru-gandhi', 'krishna-nehru', 'Krishna Nehru', 'Nehru', 'f', '1907-00-00'),
    ('nehru-gandhi', 'indira-gandhi', 'Indira Gandhi', 'Nehru', 'f', '1917-11-19');
-- Gandhi (6)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('nehru-gandhi', 'feroze-gandhi', 'Feroze Gandhi', 'Gandhi', 'm', '1912-08-12'),
    ('nehru-gandhi', 'rajiv-gandhi', 'Rajiv Gandhi', 'Gandhi', 'm', '1944-08-20'),
    ('nehru-gandhi', 'sanjay-gandhi', 'Sanjay Gandhi', 'Gandhi', 'm', '1946-12-14'),
    ('nehru-gandhi', 'rahul-gandhi', 'Rahul Gandhi', 'Gandhi', 'm', '1970-06-19'),
    ('nehru-gandhi', 'priyanka-gandhi', 'Priyanka Gandhi', 'Gandhi', 'f', '1972-01-12'),
    ('nehru-gandhi', 'feroze-varun-gandhi', 'Feroze Varun Gandhi', 'Gandhi', 'm', '1980-03-13');
-- Pandit (4)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('nehru-gandhi', 'ranjit-sitaram-pandit', 'Ranjit Sitaram Pandit', 'Pandit', 'm', NULL),
    ('nehru-gandhi', 'nayantara-sahgal', 'Nayantara Sahgal', 'Pandit', 'f', '1927-00-00'),
    ('nehru-gandhi', 'chandralekha-mehta', 'Chandralekha Mehta', 'Pandit', 'f', NULL),
    ('nehru-gandhi', 'rita-dar', 'Rita Dar', 'Pandit', 'f', NULL);
-- Hutheesing (3)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('nehru-gandhi', 'gunottam-hutheesing', 'Gunottam Hutheesing', 'Hutheesing', 'm', NULL),
    ('nehru-gandhi', 'harsha-hutheesing', 'Harsha Hutheesing', 'Hutheesing', 'm', NULL),
    ('nehru-gandhi', 'ajit-hutheesing', 'Ajit Hutheesing', 'Hutheesing', 'm', NULL);
-- Kaul (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('nehru-gandhi', 'kamala-kaul', 'Kamala Kaul', 'Kaul', 'f', '1899-00-00');
-- Maino (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('nehru-gandhi', 'sonia-maino', 'Sonia Maino', 'Maino', 'f', '1946-12-09');
-- Anand (1)
INSERT INTO person (saga_id, id, name, house, sex, born) VALUES
    ('nehru-gandhi', 'maneka-anand', 'Maneka Anand', 'Anand', 'f', '1956-08-26');

-- ── Families (12, each followed by its members) ────────────────────────────────────────────────
-- nehru-gandhi-f1: Gangadhar Nehru → Bansi Dhar Nehru, Nandlal Nehru, Motilal Nehru
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('nehru-gandhi', 'nehru-gandhi-f1', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('nehru-gandhi', 'nehru-gandhi-f1', 'gangadhar-nehru', 'parent'),
    ('nehru-gandhi', 'nehru-gandhi-f1', 'bansi-dhar-nehru', 'child'),
    ('nehru-gandhi', 'nehru-gandhi-f1', 'nandlal-nehru', 'child'),
    ('nehru-gandhi', 'nehru-gandhi-f1', 'motilal-nehru', 'child');
-- nehru-gandhi-f2: Nandlal Nehru → Shyamlal Nehru, Brijlal Nehru
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('nehru-gandhi', 'nehru-gandhi-f2', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('nehru-gandhi', 'nehru-gandhi-f2', 'nandlal-nehru', 'parent'),
    ('nehru-gandhi', 'nehru-gandhi-f2', 'shyamlal-nehru', 'child'),
    ('nehru-gandhi', 'nehru-gandhi-f2', 'brijlal-nehru', 'child');
-- nehru-gandhi-f3: Shyamlal Nehru + Uma Nehru → Shyam Kumari Nehru
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('nehru-gandhi', 'nehru-gandhi-f3', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('nehru-gandhi', 'nehru-gandhi-f3', 'shyamlal-nehru', 'parent'),
    ('nehru-gandhi', 'nehru-gandhi-f3', 'uma-nehru', 'parent'),
    ('nehru-gandhi', 'nehru-gandhi-f3', 'shyam-kumari-nehru', 'child');
-- nehru-gandhi-f4: Shyam Kumari Nehru → Arun Nehru
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('nehru-gandhi', 'nehru-gandhi-f4', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('nehru-gandhi', 'nehru-gandhi-f4', 'shyam-kumari-nehru', 'parent'),
    ('nehru-gandhi', 'nehru-gandhi-f4', 'arun-nehru', 'child');
-- nehru-gandhi-f5: Brijlal Nehru + Rameshwari Raina → Braj Kumar Nehru
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('nehru-gandhi', 'nehru-gandhi-f5', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('nehru-gandhi', 'nehru-gandhi-f5', 'brijlal-nehru', 'parent'),
    ('nehru-gandhi', 'nehru-gandhi-f5', 'rameshwari-raina', 'parent'),
    ('nehru-gandhi', 'nehru-gandhi-f5', 'braj-kumar-nehru', 'child');
-- nehru-gandhi-f6: Motilal Nehru + Swarup Rani → Jawaharlal Nehru, Vijaya Lakshmi Nehru, Krishna Nehru
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('nehru-gandhi', 'nehru-gandhi-f6', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('nehru-gandhi', 'nehru-gandhi-f6', 'motilal-nehru', 'parent'),
    ('nehru-gandhi', 'nehru-gandhi-f6', 'swarup-rani', 'parent'),
    ('nehru-gandhi', 'nehru-gandhi-f6', 'jawaharlal-nehru', 'child'),
    ('nehru-gandhi', 'nehru-gandhi-f6', 'vijaya-lakshmi-nehru', 'child'),
    ('nehru-gandhi', 'nehru-gandhi-f6', 'krishna-nehru', 'child');
-- nehru-gandhi-f7: Jawaharlal Nehru + Kamala Kaul → Indira Gandhi
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('nehru-gandhi', 'nehru-gandhi-f7', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('nehru-gandhi', 'nehru-gandhi-f7', 'jawaharlal-nehru', 'parent'),
    ('nehru-gandhi', 'nehru-gandhi-f7', 'kamala-kaul', 'parent'),
    ('nehru-gandhi', 'nehru-gandhi-f7', 'indira-gandhi', 'child');
-- nehru-gandhi-f8: Feroze Gandhi + Indira Gandhi → Rajiv Gandhi, Sanjay Gandhi
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('nehru-gandhi', 'nehru-gandhi-f8', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('nehru-gandhi', 'nehru-gandhi-f8', 'feroze-gandhi', 'parent'),
    ('nehru-gandhi', 'nehru-gandhi-f8', 'indira-gandhi', 'parent'),
    ('nehru-gandhi', 'nehru-gandhi-f8', 'rajiv-gandhi', 'child'),
    ('nehru-gandhi', 'nehru-gandhi-f8', 'sanjay-gandhi', 'child');
-- nehru-gandhi-f9: Rajiv Gandhi + Sonia Maino → Rahul Gandhi, Priyanka Gandhi
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('nehru-gandhi', 'nehru-gandhi-f9', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('nehru-gandhi', 'nehru-gandhi-f9', 'rajiv-gandhi', 'parent'),
    ('nehru-gandhi', 'nehru-gandhi-f9', 'sonia-maino', 'parent'),
    ('nehru-gandhi', 'nehru-gandhi-f9', 'rahul-gandhi', 'child'),
    ('nehru-gandhi', 'nehru-gandhi-f9', 'priyanka-gandhi', 'child');
-- nehru-gandhi-f10: Sanjay Gandhi + Maneka Anand → Feroze Varun Gandhi
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('nehru-gandhi', 'nehru-gandhi-f10', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('nehru-gandhi', 'nehru-gandhi-f10', 'sanjay-gandhi', 'parent'),
    ('nehru-gandhi', 'nehru-gandhi-f10', 'maneka-anand', 'parent'),
    ('nehru-gandhi', 'nehru-gandhi-f10', 'feroze-varun-gandhi', 'child');
-- nehru-gandhi-f11: Ranjit Sitaram Pandit + Vijaya Lakshmi Nehru → Nayantara Sahgal, Chandralekha Mehta, Rita Dar
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('nehru-gandhi', 'nehru-gandhi-f11', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('nehru-gandhi', 'nehru-gandhi-f11', 'ranjit-sitaram-pandit', 'parent'),
    ('nehru-gandhi', 'nehru-gandhi-f11', 'vijaya-lakshmi-nehru', 'parent'),
    ('nehru-gandhi', 'nehru-gandhi-f11', 'nayantara-sahgal', 'child'),
    ('nehru-gandhi', 'nehru-gandhi-f11', 'chandralekha-mehta', 'child'),
    ('nehru-gandhi', 'nehru-gandhi-f11', 'rita-dar', 'child');
-- nehru-gandhi-f12: Gunottam Hutheesing + Krishna Nehru → Harsha Hutheesing, Ajit Hutheesing
INSERT INTO family (saga_id, id, adoptive) VALUES
    ('nehru-gandhi', 'nehru-gandhi-f12', FALSE);
INSERT INTO family_member (saga_id, family_id, person_id, role) VALUES
    ('nehru-gandhi', 'nehru-gandhi-f12', 'gunottam-hutheesing', 'parent'),
    ('nehru-gandhi', 'nehru-gandhi-f12', 'krishna-nehru', 'parent'),
    ('nehru-gandhi', 'nehru-gandhi-f12', 'harsha-hutheesing', 'child'),
    ('nehru-gandhi', 'nehru-gandhi-f12', 'ajit-hutheesing', 'child');


-- =================================================================================================
-- End of seed: 17 sagas.
-- =================================================================================================
COMMIT;
