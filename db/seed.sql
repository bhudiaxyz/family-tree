-- =================================================================================================
-- Family Tree: database seed
-- Generated from public/data/*.json by scripts/seed-sql.mts. Do not edit: run `npm run db:seed`.
-- Contents: 14 sagas, 1072 people, 570 families, 1672 family-member rows.
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

BEGIN;


-- =================================================================================================
-- SAGA 1 of 14: GAME OF THRONES   [id: got, category: fiction]
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
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('got', 'rickard', 'Rickard Stark', 'Stark', 'm'),
    ('got', 'lyarra', 'Lyarra Stark', 'Stark', 'f'),
    ('got', 'eddard', 'Eddard Stark', 'Stark', 'm'),
    ('got', 'lyanna', 'Lyanna Stark', 'Stark', 'f'),
    ('got', 'benjen', 'Benjen Stark', 'Stark', 'm'),
    ('got', 'robb', 'Robb Stark', 'Stark', 'm'),
    ('got', 'sansa', 'Sansa Stark', 'Stark', 'f'),
    ('got', 'arya', 'Arya Stark', 'Stark', 'f'),
    ('got', 'bran', 'Bran Stark', 'Stark', 'm'),
    ('got', 'rickon', 'Rickon Stark', 'Stark', 'm'),
    ('got', 'jon', 'Jon Snow', 'Stark', 'm');
-- Tully (4)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('got', 'hoster', 'Hoster Tully', 'Tully', 'm'),
    ('got', 'catelyn', 'Catelyn Tully', 'Tully', 'f'),
    ('got', 'lysa', 'Lysa Tully', 'Tully', 'f'),
    ('got', 'edmure', 'Edmure Tully', 'Tully', 'm');
-- Arryn (2)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('got', 'jonArryn', 'Jon Arryn', 'Arryn', 'm'),
    ('got', 'robin', 'Robin Arryn', 'Arryn', 'm');
-- Targaryen (7)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('got', 'aerys', 'Aerys II Targaryen', 'Targaryen', 'm'),
    ('got', 'rhaella', 'Rhaella Targaryen', 'Targaryen', 'f'),
    ('got', 'rhaegar', 'Rhaegar Targaryen', 'Targaryen', 'm'),
    ('got', 'viserys', 'Viserys Targaryen', 'Targaryen', 'm'),
    ('got', 'daenerys', 'Daenerys Targaryen', 'Targaryen', 'f'),
    ('got', 'rhaenys', 'Rhaenys Targaryen', 'Targaryen', 'f'),
    ('got', 'aegon', 'Aegon Targaryen', 'Targaryen', 'm');
-- Martell (1)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('got', 'elia', 'Elia Martell', 'Martell', 'f');
-- Dothraki (1)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('got', 'drogo', 'Khal Drogo', 'Dothraki', 'm');
-- Lannister (8)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('got', 'tywin', 'Tywin Lannister', 'Lannister', 'm'),
    ('got', 'joanna', 'Joanna Lannister', 'Lannister', 'f'),
    ('got', 'cersei', 'Cersei Lannister', 'Lannister', 'f'),
    ('got', 'jaime', 'Jaime Lannister', 'Lannister', 'm'),
    ('got', 'tyrion', 'Tyrion Lannister', 'Lannister', 'm'),
    ('got', 'joffrey', 'Joffrey Baratheon', 'Lannister', 'm'),
    ('got', 'myrcella', 'Myrcella Baratheon', 'Lannister', 'f'),
    ('got', 'tommen', 'Tommen Baratheon', 'Lannister', 'm');
-- Baratheon (7)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('got', 'steffon', 'Steffon Baratheon', 'Baratheon', 'm'),
    ('got', 'cassana', 'Cassana Baratheon', 'Baratheon', 'f'),
    ('got', 'robert', 'Robert Baratheon', 'Baratheon', 'm'),
    ('got', 'stannis', 'Stannis Baratheon', 'Baratheon', 'm'),
    ('got', 'renly', 'Renly Baratheon', 'Baratheon', 'm'),
    ('got', 'shireen', 'Shireen Baratheon', 'Baratheon', 'f'),
    ('got', 'gendry', 'Gendry', 'Baratheon', 'm');
-- Florent (1)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('got', 'selyse', 'Selyse Florent', 'Florent', 'f');

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
-- SAGA 2 of 14: FIRE & BLOOD   [id: fireblood, category: fiction]
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
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('fireblood', 'aegonI', 'Aegon I the Conqueror', 'Targaryen', 'm'),
    ('fireblood', 'visenya', 'Visenya', 'Targaryen', 'f'),
    ('fireblood', 'rhaenysQ', 'Rhaenys (queen)', 'Targaryen', 'f'),
    ('fireblood', 'aenys', 'Aenys I', 'Targaryen', 'm'),
    ('fireblood', 'maegor', 'Maegor the Cruel', 'Targaryen', 'm'),
    ('fireblood', 'aegonU', 'Aegon the Uncrowned', 'Targaryen', 'm'),
    ('fireblood', 'rhaenaA', 'Rhaena', 'Targaryen', 'f'),
    ('fireblood', 'viserysA', 'Viserys (son of Aenys)', 'Targaryen', 'm'),
    ('fireblood', 'jaehaerys', 'Jaehaerys I', 'Targaryen', 'm'),
    ('fireblood', 'alysanne', 'Alysanne', 'Targaryen', 'f'),
    ('fireblood', 'aemon', 'Aemon (Prince of Dragonstone)', 'Targaryen', 'm'),
    ('fireblood', 'baelon', 'Baelon the Brave', 'Targaryen', 'm'),
    ('fireblood', 'alyssaT', 'Alyssa Targaryen', 'Targaryen', 'f'),
    ('fireblood', 'rhaenys', 'Rhaenys (Queen Who Never Was)', 'Targaryen', 'f'),
    ('fireblood', 'viserysI', 'Viserys I', 'Targaryen', 'm'),
    ('fireblood', 'daemon', 'Daemon Targaryen', 'Targaryen', 'm'),
    ('fireblood', 'rhaenyra', 'Rhaenyra Targaryen', 'Targaryen', 'f'),
    ('fireblood', 'aegonII', 'Aegon II', 'Targaryen', 'm'),
    ('fireblood', 'helaena', 'Helaena', 'Targaryen', 'f'),
    ('fireblood', 'aemond', 'Aemond One-Eye', 'Targaryen', 'm'),
    ('fireblood', 'daeron', 'Daeron the Daring', 'Targaryen', 'm'),
    ('fireblood', 'baela', 'Baela Targaryen', 'Targaryen', 'f'),
    ('fireblood', 'rhaenaD', 'Rhaena Targaryen', 'Targaryen', 'f'),
    ('fireblood', 'aegonIII', 'Aegon III', 'Targaryen', 'm'),
    ('fireblood', 'viserysII', 'Viserys II', 'Targaryen', 'm'),
    ('fireblood', 'jaehaerysH', 'Jaehaerys (son of Aegon II)', 'Targaryen', 'm'),
    ('fireblood', 'jaehaera', 'Jaehaera', 'Targaryen', 'f'),
    ('fireblood', 'maelor', 'Maelor', 'Targaryen', 'm');
-- Velaryon (8)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('fireblood', 'alyssa', 'Alyssa Velaryon', 'Velaryon', 'f'),
    ('fireblood', 'corlys', 'Corlys Velaryon', 'Velaryon', 'm'),
    ('fireblood', 'laena', 'Laena Velaryon', 'Velaryon', 'f'),
    ('fireblood', 'laenor', 'Laenor Velaryon', 'Velaryon', 'm'),
    ('fireblood', 'jacaerys', 'Jacaerys Velaryon', 'Velaryon', 'm'),
    ('fireblood', 'lucerys', 'Lucerys Velaryon', 'Velaryon', 'm'),
    ('fireblood', 'joffreyV', 'Joffrey Velaryon', 'Velaryon', 'm'),
    ('fireblood', 'daenaera', 'Daenaera Velaryon', 'Velaryon', 'f');
-- Baratheon (1)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('fireblood', 'jocelyn', 'Jocelyn Baratheon', 'Baratheon', 'f');
-- Arryn (1)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('fireblood', 'aemma', 'Aemma Arryn', 'Arryn', 'f');
-- Hightower (2)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('fireblood', 'alicent', 'Alicent Hightower', 'Hightower', 'f'),
    ('fireblood', 'otto', 'Otto Hightower', 'Hightower', 'm');

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
-- SAGA 3 of 14: THE LORD OF THE RINGS   [id: lotr, category: fiction]
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
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('lotr', 'earendil', 'Eärendil', 'Half-elven', 'm'),
    ('lotr', 'elwing', 'Elwing', 'Half-elven', 'f'),
    ('lotr', 'elrond', 'Elrond', 'Half-elven', 'm'),
    ('lotr', 'elladan', 'Elladan', 'Half-elven', 'm'),
    ('lotr', 'elrohir', 'Elrohir', 'Half-elven', 'm'),
    ('lotr', 'arwen', 'Arwen Undómiel', 'Half-elven', 'f');
-- Lothlórien (3)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('lotr', 'celeborn', 'Celeborn', 'Lothlórien', 'm'),
    ('lotr', 'galadriel', 'Galadriel', 'Lothlórien', 'f'),
    ('lotr', 'celebrian', 'Celebrían', 'Lothlórien', 'f');
-- Númenor (1)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('lotr', 'elros', 'Elros Tar-Minyatur', 'Númenor', 'm');
-- Elendil (5)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('lotr', 'elendil', 'Elendil', 'Elendil', 'm'),
    ('lotr', 'isildur', 'Isildur', 'Elendil', 'm'),
    ('lotr', 'anarion', 'Anárion', 'Elendil', 'm'),
    ('lotr', 'elendur', 'Elendur', 'Elendil', 'm'),
    ('lotr', 'valandil', 'Valandil', 'Elendil', 'm');
-- Dúnedain (4)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('lotr', 'arathorn', 'Arathorn II', 'Dúnedain', 'm'),
    ('lotr', 'gilraen', 'Gilraen', 'Dúnedain', 'f'),
    ('lotr', 'aragorn', 'Aragorn II Elessar', 'Dúnedain', 'm'),
    ('lotr', 'eldarion', 'Eldarion', 'Dúnedain', 'm');
-- Rohan (7)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('lotr', 'thengel', 'Thengel', 'Rohan', 'm'),
    ('lotr', 'theoden', 'Théoden', 'Rohan', 'm'),
    ('lotr', 'theodwyn', 'Théodwyn', 'Rohan', 'f'),
    ('lotr', 'eomund', 'Éomund', 'Rohan', 'm'),
    ('lotr', 'theodred', 'Théodred', 'Rohan', 'm'),
    ('lotr', 'eomer', 'Éomer', 'Rohan', 'm'),
    ('lotr', 'eowyn', 'Éowyn', 'Rohan', 'f');
-- Gondor (5)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('lotr', 'morwen', 'Morwen of Lossarnach', 'Gondor', 'f'),
    ('lotr', 'denethor', 'Denethor II', 'Gondor', 'm'),
    ('lotr', 'boromir', 'Boromir', 'Gondor', 'm'),
    ('lotr', 'faramir', 'Faramir', 'Gondor', 'm'),
    ('lotr', 'elboron', 'Elboron', 'Gondor', 'm');
-- Dol Amroth (1)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('lotr', 'finduilas', 'Finduilas', 'Dol Amroth', 'f');

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
-- SAGA 4 of 14: THE SILMARILLION   [id: silmarillion, category: fiction]
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
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('silmarillion', 'finwe', 'Finwë', 'Finwë', 'm'),
    ('silmarillion', 'miriel', 'Míriel', 'Finwë', 'f');
-- Fëanor (10)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('silmarillion', 'feanor', 'Fëanor', 'Fëanor', 'm'),
    ('silmarillion', 'nerdanel', 'Nerdanel', 'Fëanor', 'f'),
    ('silmarillion', 'maedhros', 'Maedhros', 'Fëanor', 'm'),
    ('silmarillion', 'maglor', 'Maglor', 'Fëanor', 'm'),
    ('silmarillion', 'celegorm', 'Celegorm', 'Fëanor', 'm'),
    ('silmarillion', 'caranthir', 'Caranthir', 'Fëanor', 'm'),
    ('silmarillion', 'curufin', 'Curufin', 'Fëanor', 'm'),
    ('silmarillion', 'amrod', 'Amrod', 'Fëanor', 'm'),
    ('silmarillion', 'amras', 'Amras', 'Fëanor', 'm'),
    ('silmarillion', 'celebrimbor', 'Celebrimbor', 'Fëanor', 'm');
-- Fingolfin (6)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('silmarillion', 'fingolfin', 'Fingolfin', 'Fingolfin', 'm'),
    ('silmarillion', 'fingon', 'Fingon', 'Fingolfin', 'm'),
    ('silmarillion', 'turgon', 'Turgon', 'Fingolfin', 'm'),
    ('silmarillion', 'aredhel', 'Aredhel', 'Fingolfin', 'f'),
    ('silmarillion', 'maeglin', 'Maeglin', 'Fingolfin', 'm'),
    ('silmarillion', 'idril', 'Idril', 'Fingolfin', 'f');
-- Finarfin (6)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('silmarillion', 'finarfin', 'Finarfin', 'Finarfin', 'm'),
    ('silmarillion', 'finrod', 'Finrod Felagund', 'Finarfin', 'm'),
    ('silmarillion', 'orodreth', 'Orodreth', 'Finarfin', 'm'),
    ('silmarillion', 'angrod', 'Angrod', 'Finarfin', 'm'),
    ('silmarillion', 'aegnor', 'Aegnor', 'Finarfin', 'm'),
    ('silmarillion', 'galadriel', 'Galadriel', 'Finarfin', 'f');
-- Vanyar (2)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('silmarillion', 'indis', 'Indis', 'Vanyar', 'f'),
    ('silmarillion', 'elenwe', 'Elenwë', 'Vanyar', 'f');
-- Teleri (1)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('silmarillion', 'earwen', 'Eärwen', 'Teleri', 'f');
-- Sindar (6)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('silmarillion', 'eol', 'Eöl', 'Sindar', 'm'),
    ('silmarillion', 'celeborn', 'Celeborn', 'Sindar', 'm'),
    ('silmarillion', 'celebrian', 'Celebrían', 'Sindar', 'f'),
    ('silmarillion', 'thingol', 'Elu Thingol', 'Sindar', 'm'),
    ('silmarillion', 'luthien', 'Lúthien', 'Sindar', 'f'),
    ('silmarillion', 'nimloth', 'Nimloth', 'Sindar', 'f');
-- Maiar (1)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('silmarillion', 'melian', 'Melian', 'Maiar', 'f');
-- Edain (3)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('silmarillion', 'tuor', 'Tuor', 'Edain', 'm'),
    ('silmarillion', 'beren', 'Beren', 'Edain', 'm'),
    ('silmarillion', 'elros', 'Elros', 'Edain', 'm');
-- Half-elven (4)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('silmarillion', 'dior', 'Dior', 'Half-elven', 'm'),
    ('silmarillion', 'elwing', 'Elwing', 'Half-elven', 'f'),
    ('silmarillion', 'earendil', 'Eärendil', 'Half-elven', 'm'),
    ('silmarillion', 'elrond', 'Elrond', 'Half-elven', 'm');

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
-- SAGA 5 of 14: DUNE   [id: dune, category: fiction]
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
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('dune', 'paulus', 'Paulus Atreides', 'Atreides', 'm'),
    ('dune', 'leto', 'Duke Leto Atreides', 'Atreides', 'm'),
    ('dune', 'paul', 'Paul Atreides (Muad''Dib)', 'Atreides', 'm'),
    ('dune', 'alia', 'Alia Atreides', 'Atreides', 'f'),
    ('dune', 'letoFirst', 'Leto (first son)', 'Atreides', 'm'),
    ('dune', 'leto2', 'Leto II', 'Atreides', 'm'),
    ('dune', 'ghanima', 'Ghanima', 'Atreides', 'f'),
    ('dune', 'duncan', 'Duncan Idaho (ghola)', 'Atreides', 'm');
-- Harkonnen (5)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('dune', 'dmitri', 'Dmitri Harkonnen', 'Harkonnen', 'm'),
    ('dune', 'vladimir', 'Baron Vladimir Harkonnen', 'Harkonnen', 'm'),
    ('dune', 'abulurd', 'Abulurd Rabban', 'Harkonnen', 'm'),
    ('dune', 'rabban', 'Glossu Rabban', 'Harkonnen', 'm'),
    ('dune', 'feyd', 'Feyd-Rautha', 'Harkonnen', 'm');
-- Corrino (4)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('dune', 'shaddam', 'Shaddam IV', 'Corrino', 'm'),
    ('dune', 'irulan', 'Princess Irulan', 'Corrino', 'f'),
    ('dune', 'wensicia', 'Wensicia', 'Corrino', 'f'),
    ('dune', 'farad', 'Farad''n Corrino', 'Corrino', 'm');
-- Bene Gesserit (3)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('dune', 'jessica', 'Lady Jessica', 'Bene Gesserit', 'f'),
    ('dune', 'gaius', 'Gaius Helen Mohiam', 'Bene Gesserit', 'f'),
    ('dune', 'anirul', 'Anirul', 'Bene Gesserit', 'f');
-- Fremen (3)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('dune', 'chani', 'Chani', 'Fremen', 'f'),
    ('dune', 'liet', 'Liet-Kynes', 'Fremen', 'm'),
    ('dune', 'faroula', 'Faroula', 'Fremen', 'f');

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
-- SAGA 6 of 14: HARRY POTTER   [id: potter, category: fiction]
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
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('potter', 'fleamont', 'Fleamont Potter', 'Potter', 'm'),
    ('potter', 'euphemia', 'Euphemia Potter', 'Potter', 'f'),
    ('potter', 'james', 'James Potter', 'Potter', 'm'),
    ('potter', 'harry', 'Harry Potter', 'Potter', 'm'),
    ('potter', 'jamesS', 'James Sirius Potter', 'Potter', 'm'),
    ('potter', 'albus', 'Albus Severus Potter', 'Potter', 'm'),
    ('potter', 'lilyL', 'Lily Luna Potter', 'Potter', 'f');
-- Evans (2)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('potter', 'lily', 'Lily Evans', 'Evans', 'f'),
    ('potter', 'petunia', 'Petunia Dursley', 'Evans', 'f');
-- Dursley (2)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('potter', 'vernon', 'Vernon Dursley', 'Dursley', 'm'),
    ('potter', 'dudley', 'Dudley Dursley', 'Dursley', 'm');
-- Weasley (11)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('potter', 'arthur', 'Arthur Weasley', 'Weasley', 'm'),
    ('potter', 'bill', 'Bill Weasley', 'Weasley', 'm'),
    ('potter', 'charlie', 'Charlie Weasley', 'Weasley', 'm'),
    ('potter', 'percy', 'Percy Weasley', 'Weasley', 'm'),
    ('potter', 'fred', 'Fred Weasley', 'Weasley', 'm'),
    ('potter', 'george', 'George Weasley', 'Weasley', 'm'),
    ('potter', 'ron', 'Ron Weasley', 'Weasley', 'm'),
    ('potter', 'ginny', 'Ginny Weasley', 'Weasley', 'f'),
    ('potter', 'victoire', 'Victoire Weasley', 'Weasley', 'f'),
    ('potter', 'rose', 'Rose Weasley', 'Weasley', 'f'),
    ('potter', 'hugo', 'Hugo Weasley', 'Weasley', 'm');
-- Prewett (1)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('potter', 'molly', 'Molly Weasley', 'Prewett', 'f');
-- Delacour (1)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('potter', 'fleur', 'Fleur Delacour', 'Delacour', 'f');
-- Granger (1)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('potter', 'hermione', 'Hermione Granger', 'Granger', 'f');
-- Black (8)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('potter', 'cygnus', 'Cygnus Black', 'Black', 'm'),
    ('potter', 'bellatrix', 'Bellatrix Lestrange', 'Black', 'f'),
    ('potter', 'andromeda', 'Andromeda Tonks', 'Black', 'f'),
    ('potter', 'narcissa', 'Narcissa Malfoy', 'Black', 'f'),
    ('potter', 'orion', 'Orion Black', 'Black', 'm'),
    ('potter', 'walburga', 'Walburga Black', 'Black', 'f'),
    ('potter', 'sirius', 'Sirius Black', 'Black', 'm'),
    ('potter', 'regulus', 'Regulus Black', 'Black', 'm');
-- Tonks (2)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('potter', 'ted', 'Ted Tonks', 'Tonks', 'm'),
    ('potter', 'tonks', 'Nymphadora Tonks', 'Tonks', 'f');
-- Lupin (2)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('potter', 'remus', 'Remus Lupin', 'Lupin', 'm'),
    ('potter', 'teddy', 'Teddy Lupin', 'Lupin', 'm');
-- Malfoy (3)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('potter', 'lucius', 'Lucius Malfoy', 'Malfoy', 'm'),
    ('potter', 'draco', 'Draco Malfoy', 'Malfoy', 'm'),
    ('potter', 'scorpius', 'Scorpius Malfoy', 'Malfoy', 'm');
-- Greengrass (1)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('potter', 'astoria', 'Astoria Greengrass', 'Greengrass', 'f');
-- Rosier (1)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('potter', 'druella', 'Druella Rosier', 'Rosier', 'f');

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
-- SAGA 7 of 14: STAR WARS   [id: starwars, category: fiction]
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
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('starwars', 'shmi', 'Shmi Skywalker', 'Skywalker', 'f'),
    ('starwars', 'anakin', 'Anakin Skywalker', 'Skywalker', 'm'),
    ('starwars', 'luke', 'Luke Skywalker', 'Skywalker', 'm');
-- Lars (2)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('starwars', 'cliegg', 'Cliegg Lars', 'Lars', 'm'),
    ('starwars', 'owen', 'Owen Lars', 'Lars', 'm');
-- Naberrie (4)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('starwars', 'padme', 'Padmé Amidala', 'Naberrie', 'f'),
    ('starwars', 'ruwee', 'Ruwee Naberrie', 'Naberrie', 'm'),
    ('starwars', 'jobal', 'Jobal Naberrie', 'Naberrie', 'f'),
    ('starwars', 'sola', 'Sola Naberrie', 'Naberrie', 'f');
-- Organa (3)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('starwars', 'leia', 'Leia Organa', 'Organa', 'f'),
    ('starwars', 'bail', 'Bail Organa', 'Organa', 'm'),
    ('starwars', 'breha', 'Breha Organa', 'Organa', 'f');
-- Solo (2)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('starwars', 'han', 'Han Solo', 'Solo', 'm'),
    ('starwars', 'ben', 'Ben Solo (Kylo Ren)', 'Solo', 'm');
-- Palpatine (3)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('starwars', 'palpatine', 'Sheev Palpatine', 'Palpatine', 'm'),
    ('starwars', 'dathan', 'Dathan', 'Palpatine', 'm'),
    ('starwars', 'rey', 'Rey', 'Palpatine', 'f');
-- Unknown (1)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('starwars', 'miramir', 'Miramir', 'Unknown', 'f');
-- Whitesun (1)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('starwars', 'beru', 'Beru Whitesun Lars', 'Whitesun', 'f');

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
-- SAGA 8 of 14: THE WHEEL OF TIME   [id: wot, category: fiction]
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
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('wot', 'mordrellen', 'Mordrellen', 'Mantear', 'f'),
    ('wot', 'tigraine', 'Tigraine Mantear', 'Mantear', 'f'),
    ('wot', 'luc', 'Luc Mantear', 'Mantear', 'm');
-- Trakand (3)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('wot', 'morgase', 'Morgase Trakand', 'Trakand', 'f'),
    ('wot', 'elayne', 'Elayne Trakand', 'Trakand', 'f'),
    ('wot', 'gawyn', 'Gawyn Trakand', 'Trakand', 'm');
-- Damodred (4)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('wot', 'taringail', 'Taringail Damodred', 'Damodred', 'm'),
    ('wot', 'galad', 'Galad Damodred', 'Damodred', 'm'),
    ('wot', 'moiraine', 'Moiraine Damodred', 'Damodred', 'f'),
    ('wot', 'dalresin', 'Dalresin Damodred', 'Damodred', 'm');
-- Aiel (2)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('wot', 'janduin', 'Janduin', 'Aiel', 'm'),
    ('wot', 'aviendha', 'Aviendha', 'Aiel', 'f');
-- al'Thor (3)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('wot', 'tam', 'Tam al''Thor', 'al''Thor', 'm'),
    ('wot', 'kari', 'Kari al''Thor', 'al''Thor', 'f'),
    ('wot', 'rand', 'Rand al''Thor', 'al''Thor', 'm');
-- al'Vere (1)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('wot', 'egwene', 'Egwene al''Vere', 'al''Vere', 'f');
-- Farshaw (1)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('wot', 'min', 'Min Farshaw', 'Farshaw', 'f');

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
-- SAGA 9 of 14: THE STORMLIGHT ARCHIVE   [id: stormlight, category: fiction]
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
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('stormlight', 'gavilar', 'Gavilar Kholin', 'Kholin', 'm'),
    ('stormlight', 'navani', 'Navani Kholin', 'Kholin', 'f'),
    ('stormlight', 'dalinar', 'Dalinar Kholin', 'Kholin', 'm'),
    ('stormlight', 'elhokar', 'Elhokar', 'Kholin', 'm'),
    ('stormlight', 'aesudan', 'Aesudan', 'Kholin', 'f'),
    ('stormlight', 'gavinor', 'Gavinor', 'Kholin', 'm'),
    ('stormlight', 'jasnah', 'Jasnah Kholin', 'Kholin', 'f'),
    ('stormlight', 'adolin', 'Adolin Kholin', 'Kholin', 'm'),
    ('stormlight', 'renarin', 'Renarin Kholin', 'Kholin', 'm');
-- Riran (2)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('stormlight', 'evi', 'Evi', 'Riran', 'f'),
    ('stormlight', 'toh', 'Toh', 'Riran', 'm');
-- Davar (6)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('stormlight', 'shallan', 'Shallan Davar', 'Davar', 'f'),
    ('stormlight', 'lin', 'Lin Davar', 'Davar', 'm'),
    ('stormlight', 'helaran', 'Helaran Davar', 'Davar', 'm'),
    ('stormlight', 'balat', 'Balat Davar', 'Davar', 'm'),
    ('stormlight', 'wikim', 'Wikim Davar', 'Davar', 'm'),
    ('stormlight', 'jushu', 'Jushu Davar', 'Davar', 'm');
-- Khinar (5)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('stormlight', 'lirin', 'Lirin', 'Khinar', 'm'),
    ('stormlight', 'hesina', 'Hesina', 'Khinar', 'f'),
    ('stormlight', 'kaladin', 'Kaladin', 'Khinar', 'm'),
    ('stormlight', 'tien', 'Tien', 'Khinar', 'm'),
    ('stormlight', 'oroden', 'Oroden', 'Khinar', 'm');

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
-- SAGA 10 of 14: THE WITCHER   [id: witcher, category: fiction]
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
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('witcher', 'lara', 'Lara Dorren', 'Aen Seidhe', 'f');
-- Lod (1)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('witcher', 'cregennan', 'Cregennan of Lod', 'Lod', 'm');
-- Cintra (8)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('witcher', 'riannon', 'Riannon', 'Cintra', 'f'),
    ('witcher', 'fiona', 'Fiona', 'Cintra', 'f'),
    ('witcher', 'corbett', 'Corbett', 'Cintra', 'm'),
    ('witcher', 'dagorad', 'Dagorad', 'Cintra', 'm'),
    ('witcher', 'adalia', 'Adalia the Leech', 'Cintra', 'f'),
    ('witcher', 'calanthe', 'Calanthe', 'Cintra', 'f'),
    ('witcher', 'pavetta', 'Pavetta', 'Cintra', 'f'),
    ('witcher', 'ciri', 'Cirilla Fiona Elen Riannon', 'Cintra', 'f');
-- Temeria (1)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('witcher', 'goidemar', 'Goidemar', 'Temeria', 'm');
-- Kovir (1)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('witcher', 'elen', 'Elen of Kovir', 'Kovir', 'f');
-- Ebbing (1)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('witcher', 'roegner', 'Roegner of Ebbing', 'Ebbing', 'm');
-- Skellige (1)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('witcher', 'eist', 'Eist Tuirseach', 'Skellige', 'm');
-- Nilfgaard (2)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('witcher', 'duny', 'Duny (Emhyr var Emreis)', 'Nilfgaard', 'm'),
    ('witcher', 'fergus', 'Fergus var Emreis', 'Nilfgaard', 'm');
-- Witchers (1)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('witcher', 'geralt', 'Geralt of Rivia', 'Witchers', 'm');
-- Sorceresses (1)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('witcher', 'yennefer', 'Yennefer of Vengerberg', 'Sorceresses', 'f');

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
-- SAGA 11 of 14: ENGLISH ROYAL FAMILY (TUDORS)   [id: english-royal, category: history]
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
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('english-royal', 'james-stewart', 'James Stewart', 'Stewart', 'm'),
    ('english-royal', 'henry-stewart', 'Henry Stewart', 'Stewart', 'm'),
    ('english-royal', 'andrew-stewart', 'Andrew Stewart', 'Stewart', 'm'),
    ('english-royal', 'janet-stewart', 'Janet Stewart', 'Stewart', 'f'),
    ('english-royal', 'john-stewart', 'John Stewart', 'Stewart', 'm'),
    ('english-royal', 'james-stewart-2', 'James Stewart', 'Stewart', 'm'),
    ('english-royal', 'arthur-stewart', 'Arthur Stewart', 'Stewart', 'm'),
    ('english-royal', 'unnamed-daughter-stewart', '(unnamed daughter) Stewart', 'Stewart', 'f'),
    ('english-royal', 'james-stewart-3', 'James Stewart', 'Stewart', 'm'),
    ('english-royal', 'unnamed-daughter-stewart-2', '(unnamed daughter) Stewart', 'Stewart', 'f'),
    ('english-royal', 'alexander-stewart', 'Alexander Stewart', 'Stewart', 'm'),
    ('english-royal', 'alexander-stewart-2', 'Alexander Stewart', 'Stewart', 'm'),
    ('english-royal', 'catherine-stewart', 'Catherine Stewart', 'Stewart', 'f'),
    ('english-royal', 'james-stewart-4', 'James Stewart', 'Stewart', 'm'),
    ('english-royal', 'margaret-stewart', 'Margaret Stewart', 'Stewart', 'f'),
    ('english-royal', 'isabella-stewart', 'Isabella Stewart', 'Stewart', 'f'),
    ('english-royal', 'james-stewart-5', 'James Stewart', 'Stewart', 'm'),
    ('english-royal', 'janet-stewart-2', 'Janet Stewart', 'Stewart', 'f'),
    ('english-royal', 'james-stewart-6', 'James Stewart', 'Stewart', 'm'),
    ('english-royal', 'arthur-stewart-2', 'Arthur Stewart', 'Stewart', 'm'),
    ('english-royal', 'mary-stewart', 'Mary Stewart', 'Stewart', 'f');
-- Tudor (12)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('english-royal', 'henry-vii', 'Henry VII', 'Tudor', 'm'),
    ('english-royal', 'edmund-tudor', 'Edmund Tudor', 'Tudor', 'm'),
    ('english-royal', 'henry-viii', 'Henry VIII', 'Tudor', 'm'),
    ('english-royal', 'edmund-tudor-2', 'Edmund Tudor', 'Tudor', 'm'),
    ('english-royal', 'arthur-tudor', 'Arthur Tudor', 'Tudor', 'm'),
    ('english-royal', 'henry-tudor', 'Henry Tudor', 'Tudor', 'm'),
    ('english-royal', 'unnamed-son-tudor', '(unnamed son) Tudor', 'Tudor', 'm'),
    ('english-royal', 'edward-vi', 'Edward VI', 'Tudor', 'm'),
    ('english-royal', 'mary-tudor', 'Mary Tudor', 'Tudor', 'f'),
    ('english-royal', 'margaret-tudor', 'Margaret Tudor', 'Tudor', 'f'),
    ('english-royal', 'elizabeth-i', 'Elizabeth I', 'Tudor', 'f'),
    ('english-royal', 'mary-i', 'Mary I', 'Tudor', 'f');
-- Howard (12)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('english-royal', 'catherine-howard', 'Catherine Howard', 'Howard', 'f'),
    ('english-royal', 'mary-howard', 'Mary Howard', 'Howard', 'f'),
    ('english-royal', 'thomas-howard', 'Thomas Howard', 'Howard', 'm'),
    ('english-royal', 'elizabeth-howard', 'Elizabeth Howard', 'Howard', 'f'),
    ('english-royal', 'thomas-howard-2', 'Thomas Howard', 'Howard', 'm'),
    ('english-royal', 'unnamed-son-howard', '(unnamed son) Howard', 'Howard', 'm'),
    ('english-royal', 'dorothy-howard', 'Dorothy Howard', 'Howard', 'f'),
    ('english-royal', 'edmund-howard', 'Edmund Howard', 'Howard', 'm'),
    ('english-royal', 'frances-howard', 'Frances Howard', 'Howard', 'f'),
    ('english-royal', 'william-howard', 'William Howard', 'Howard', 'm'),
    ('english-royal', 'frances-howard-2', 'Frances Howard', 'Howard', 'f'),
    ('english-royal', 'thomas-howard-3', 'Thomas Howard', 'Howard', 'm');
-- Plantagenet (10)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('english-royal', 'elizabeth-plantagenet', 'Elizabeth Plantagenet', 'Plantagenet', 'f'),
    ('english-royal', 'edward-iv', 'Edward IV', 'Plantagenet', 'm'),
    ('english-royal', 'arthur-plantagenet', 'Arthur Plantagenet', 'Plantagenet', 'm'),
    ('english-royal', 'cecily-plantagenet', 'Cecily Plantagenet', 'Plantagenet', 'f'),
    ('english-royal', 'edward-v', 'Edward V', 'Plantagenet', 'm'),
    ('english-royal', 'richard-plantagenet', 'Richard Plantagenet', 'Plantagenet', 'm'),
    ('english-royal', 'george-plantagenet', 'George Plantagenet', 'Plantagenet', 'm'),
    ('english-royal', 'anne-plantagenet', 'Anne Plantagenet', 'Plantagenet', 'f'),
    ('english-royal', 'anne-plantagenet-2', 'Anne Plantagenet', 'Plantagenet', 'f'),
    ('english-royal', 'richard-plantagenet-2', 'Richard Plantagenet', 'Plantagenet', 'm');
-- Grey (10)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('english-royal', 'elizabeth-grey', 'Elizabeth Grey', 'Grey', 'f'),
    ('english-royal', 'edward-grey', 'Edward Grey', 'Grey', 'm'),
    ('english-royal', 'john-grey', 'John Grey', 'Grey', 'm'),
    ('english-royal', 'thomas-grey', 'Thomas Grey', 'Grey', 'm'),
    ('english-royal', 'thomas-grey-2', 'Thomas Grey', 'Grey', 'm'),
    ('english-royal', 'henry-grey', 'Henry Grey', 'Grey', 'm'),
    ('english-royal', 'jane-grey', 'Jane Grey', 'Grey', 'f'),
    ('english-royal', 'henry-grey-2', 'Henry Grey', 'Grey', 'm'),
    ('english-royal', 'catherine-grey', 'Catherine Grey', 'Grey', 'f'),
    ('english-royal', 'mary-grey', 'Mary Grey', 'Grey', 'f');
-- Douglas (8)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('english-royal', 'archibald-douglas', 'Archibald Douglas', 'Douglas', 'm'),
    ('english-royal', 'george-douglas', 'George Douglas', 'Douglas', 'm'),
    ('english-royal', 'janet-douglas', 'Janet Douglas', 'Douglas', 'f'),
    ('english-royal', 'james-douglas', 'James Douglas', 'Douglas', 'm'),
    ('english-royal', 'janet-douglas-2', 'Janet Douglas', 'Douglas', 'f'),
    ('english-royal', 'william-douglas', 'William Douglas', 'Douglas', 'm'),
    ('english-royal', 'margaret-douglas', 'Margaret Douglas', 'Douglas', 'f'),
    ('english-royal', 'james-douglas-2', 'James Douglas', 'Douglas', 'm');
-- Stafford (6)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('english-royal', 'henry-stafford', 'Henry Stafford', 'Stafford', 'm'),
    ('english-royal', 'humphrey-stafford', 'Humphrey Stafford', 'Stafford', 'm'),
    ('english-royal', 'elizabeth-stafford', 'Elizabeth Stafford', 'Stafford', 'f'),
    ('english-royal', 'edward-stafford', 'Edward Stafford', 'Stafford', 'm'),
    ('english-royal', 'henry-stafford-2', 'Henry Stafford', 'Stafford', 'm'),
    ('english-royal', 'william-stafford', 'William Stafford', 'Stafford', 'm');
-- Seymour (6)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('english-royal', 'jane-seymour', 'Jane Seymour', 'Seymour', 'f'),
    ('english-royal', 'john-seymour', 'John Seymour', 'Seymour', 'm'),
    ('english-royal', 'edward-seymour', 'Edward Seymour', 'Seymour', 'm'),
    ('english-royal', 'edward-seymour-2', 'Edward Seymour', 'Seymour', 'm'),
    ('english-royal', 'thomas-seymour', 'Thomas Seymour', 'Seymour', 'm'),
    ('english-royal', 'william-seymour', 'William Seymour', 'Seymour', 'm');
-- Neville (6)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('english-royal', 'margaret-neville', 'Margaret Neville', 'Neville', 'f'),
    ('english-royal', 'john-neville', 'John Neville', 'Neville', 'm'),
    ('english-royal', 'catherine-neville', 'Catherine Neville', 'Neville', 'f'),
    ('english-royal', 'eleanor-neville', 'Eleanor Neville', 'Neville', 'f'),
    ('english-royal', 'richard-neville', 'Richard Neville', 'Neville', 'm'),
    ('english-royal', 'john-neville-2', 'John Neville', 'Neville', 'm');
-- Valois (6)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('english-royal', 'louis-xii', 'Louis XII', 'Valois', 'm'),
    ('english-royal', 'henry-ii', 'Henry II', 'Valois', 'm'),
    ('english-royal', 'henry-of-valois', 'Henry of Valois', 'Valois', 'm'),
    ('english-royal', 'madeleine-of-valois', 'Madeleine of Valois', 'Valois', 'f'),
    ('english-royal', 'francis-i', 'Francis I', 'Valois', 'm'),
    ('english-royal', 'francis-ii', 'Francis II', 'Valois', 'm');
-- Stuart (6)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('english-royal', 'ludovic-stuart', 'Ludovic Stuart', 'Stuart', 'm'),
    ('english-royal', 'matthew-stuart', 'Matthew Stuart', 'Stuart', 'm'),
    ('english-royal', 'henry-stuart', 'Henry Stuart', 'Stuart', 'm'),
    ('english-royal', 'charles-stuart', 'Charles Stuart', 'Stuart', 'm'),
    ('english-royal', 'arabella-stuart', 'Arabella Stuart', 'Stuart', 'f'),
    ('english-royal', 'james-stuart', 'James Stuart', 'Stuart', 'm');
-- Stanley (5)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('english-royal', 'thomas-stanley', 'Thomas Stanley', 'Stanley', 'm'),
    ('english-royal', 'george-stanley', 'George Stanley', 'Stanley', 'm'),
    ('english-royal', 'thomas-stanley-2', 'Thomas Stanley', 'Stanley', 'm'),
    ('english-royal', 'edward-stanley', 'Edward Stanley', 'Stanley', 'm'),
    ('english-royal', 'henry-stanley', 'Henry Stanley', 'Stanley', 'm');
-- Other families (160)
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('english-royal', 'margaret-beaufort', 'Margaret Beaufort', 'Other families', 'f'),
    ('english-royal', 'john-de-la-pole', 'John de la Pole', 'Other families', 'm'),
    ('english-royal', 'john-beaufort', 'John Beaufort', 'Other families', 'm'),
    ('english-royal', 'margaret-beauchamp', 'Margaret Beauchamp', 'Other families', 'f'),
    ('english-royal', 'oliver-st-john', 'Oliver St John', 'Other families', 'm'),
    ('english-royal', 'john-beauchamp', 'John Beauchamp', 'Other families', 'm'),
    ('english-royal', 'catherine-of-aragon', 'Catherine of Aragon', 'Other families', 'f'),
    ('english-royal', 'anne-boleyn', 'Anne Boleyn', 'Other families', 'f'),
    ('english-royal', 'anne-of-cleves', 'Anne of Cleves', 'Other families', 'f'),
    ('english-royal', 'catherine-parr', 'Catherine Parr', 'Other families', 'f'),
    ('english-royal', 'elizabeth-blount', 'Elizabeth Blount', 'Other families', 'f'),
    ('english-royal', 'henry-fitzroy', 'Henry Fitzroy', 'Other families', 'm'),
    ('english-royal', 'ferdinand-v', 'Ferdinand V', 'Other families', 'm'),
    ('english-royal', 'isabella-of-castile', 'Isabella of Castile', 'Other families', 'f'),
    ('english-royal', 'john-ii', 'John II', 'Other families', 'm'),
    ('english-royal', 'thomas-boleyn', 'Thomas Boleyn', 'Other families', 'm'),
    ('english-royal', 'charles-brandon', 'Charles Brandon', 'Other families', 'm'),
    ('english-royal', 'william-brandon', 'William Brandon', 'Other families', 'm'),
    ('english-royal', 'elizabeth-bruyn', 'Elizabeth Bruyn', 'Other families', 'f'),
    ('english-royal', 'henry-bruyn', 'Henry Bruyn', 'Other families', 'm'),
    ('english-royal', 'anne-browne', 'Anne Browne', 'Other families', 'f'),
    ('english-royal', 'isabella-ingaldesthorpe', 'Isabella Ingaldesthorpe', 'Other families', 'f'),
    ('english-royal', 'edmund-ingaldesthorpe', 'Edmund Ingaldesthorpe', 'Other families', 'm'),
    ('english-royal', 'john-mortimer', 'John Mortimer', 'Other families', 'm'),
    ('english-royal', 'anthony-browne', 'Anthony Browne', 'Other families', 'm'),
    ('english-royal', 'catherine-willoughby', 'Catherine Willoughby', 'Other families', 'f'),
    ('english-royal', 'william-willoughby', 'William Willoughby', 'Other families', 'm'),
    ('english-royal', 'mary-de-salinas', 'Mary de Salinas', 'Other families', 'f'),
    ('english-royal', 'richard-bertie', 'Richard Bertie', 'Other families', 'm'),
    ('english-royal', 'elizabeth-drummond', 'Elizabeth Drummond', 'Other families', 'f'),
    ('english-royal', 'john-drummond', 'John Drummond', 'Other families', 'm'),
    ('english-royal', 'david-fleming', 'David Fleming', 'Other families', 'm'),
    ('english-royal', 'margaret-hepburn', 'Margaret Hepburn', 'Other families', 'f'),
    ('english-royal', 'patrick-hepburn', 'Patrick Hepburn', 'Other families', 'm'),
    ('english-royal', 'margaret-maxwell', 'Margaret Maxwell', 'Other families', 'f'),
    ('english-royal', 'robert-maxwell', 'Robert Maxwell', 'Other families', 'm'),
    ('english-royal', 'william-baillie', 'William Baillie', 'Other families', 'm'),
    ('english-royal', 'margaret-kennedy', 'Margaret Kennedy', 'Other families', 'f'),
    ('english-royal', 'john-kennedy', 'John Kennedy', 'Other families', 'm'),
    ('english-royal', 'unnamed-daughter-leslie', '(unnamed daughter) Leslie', 'Other families', 'f'),
    ('english-royal', 'hugh-kennedy', 'Hugh Kennedy', 'Other families', 'm'),
    ('english-royal', 'alexander-gordon', 'Alexander Gordon', 'Other families', 'm'),
    ('english-royal', 'janet-campbell', 'Janet Campbell', 'Other families', 'f'),
    ('english-royal', 'archibald-campbell', 'Archibald Campbell', 'Other families', 'm'),
    ('english-royal', 'patrick-ruthven', 'Patrick Ruthven', 'Other families', 'm'),
    ('english-royal', 'james-gray', 'James Gray', 'Other families', 'm'),
    ('english-royal', 'elizabeth-wydvill', 'Elizabeth Wydvill', 'Other families', 'f'),
    ('english-royal', 'elizabeth-talbot', 'Elizabeth Talbot', 'Other families', 'f'),
    ('english-royal', 'edmund-dudley', 'Edmund Dudley', 'Other families', 'm'),
    ('english-royal', 'honor-grenville', 'Honor Grenville', 'Other families', 'f'),
    ('english-royal', 'john-basset', 'John Basset', 'Other families', 'm'),
    ('english-royal', 'thomas-grenville', 'Thomas Grenville', 'Other families', 'm'),
    ('english-royal', 'isabella-gilbert', 'Isabella Gilbert', 'Other families', 'f'),
    ('english-royal', 'otes-gilbert', 'Otes Gilbert', 'Other families', 'm'),
    ('english-royal', 'john-welles', 'John Welles', 'Other families', 'm'),
    ('english-royal', 'richard-wydvill', 'Richard Wydvill', 'Other families', 'm'),
    ('english-royal', 'elizabeth-welles', 'Elizabeth Welles', 'Other families', 'f'),
    ('english-royal', 'anne-welles', 'Anne Welles', 'Other families', 'f'),
    ('english-royal', 'thomas-kyme', 'Thomas Kyme', 'Other families', 'm'),
    ('english-royal', 'anne-mowbray', 'Anne Mowbray', 'Other families', 'f'),
    ('english-royal', 'john-mowbray', 'John Mowbray', 'Other families', 'm'),
    ('english-royal', 'elizabeth-talbot-2', 'Elizabeth Talbot', 'Other families', 'f'),
    ('english-royal', 'john-talbot', 'John Talbot', 'Other families', 'm'),
    ('english-royal', 'elizabeth-tylney', 'Elizabeth Tylney', 'Other families', 'f'),
    ('english-royal', 'humphrey-bourchier', 'Humphrey Bourchier', 'Other families', 'm'),
    ('english-royal', 'john-bourchier', 'John Bourchier', 'Other families', 'm'),
    ('english-royal', 'frederick-tylney', 'Frederick Tylney', 'Other families', 'm'),
    ('english-royal', 'elizabeth-cheney', 'Elizabeth Cheney', 'Other families', 'f'),
    ('english-royal', 'lawrence-cheney', 'Lawrence Cheney', 'Other families', 'm'),
    ('english-royal', 'elizabeth-cokayne', 'Elizabeth Cokayne', 'Other families', 'f'),
    ('english-royal', 'john-cokayne', 'John Cokayne', 'Other families', 'm'),
    ('english-royal', 'agnes-tylney', 'Agnes Tylney', 'Other families', 'f'),
    ('english-royal', 'hugh-tylney', 'Hugh Tylney', 'Other families', 'm'),
    ('english-royal', 'philip-tylney', 'Philip Tylney', 'Other families', 'm'),
    ('english-royal', 'unnamed-daughter-tailboys', '(unnamed daughter) Tailboys', 'Other families', 'f'),
    ('english-royal', 'walter-tailboys', 'Walter Tailboys', 'Other families', 'm'),
    ('english-royal', 'ralph-scrope', 'Ralph Scrope', 'Other families', 'm'),
    ('english-royal', 'eleanor-percy', 'Eleanor Percy', 'Other families', 'f'),
    ('english-royal', 'henry-percy', 'Henry Percy', 'Other families', 'm'),
    ('english-royal', 'richard-wydvill-2', 'Richard Wydvill', 'Other families', 'm'),
    ('english-royal', 'jacqueline-de-luxembourg', 'Jacqueline de Luxembourg', 'Other families', 'f'),
    ('english-royal', 'peter-de-luxembourg', 'Peter de Luxembourg', 'Other families', 'm'),
    ('english-royal', 'anne-holand', 'Anne Holand', 'Other families', 'f'),
    ('english-royal', 'henry-holand', 'Henry Holand', 'Other families', 'm'),
    ('english-royal', 'cecily-bonville', 'Cecily Bonville', 'Other families', 'f'),
    ('english-royal', 'william-bonville', 'William Bonville', 'Other families', 'm'),
    ('english-royal', 'henry-brandon', 'Henry Brandon', 'Other families', 'm'),
    ('english-royal', 'frances-brandon', 'Frances Brandon', 'Other families', 'f'),
    ('english-royal', 'adrian-stokes', 'Adrian Stokes', 'Other families', 'm'),
    ('english-royal', 'margaret-wotton', 'Margaret Wotton', 'Other families', 'f'),
    ('english-royal', 'william-medley', 'William Medley', 'Other families', 'm'),
    ('english-royal', 'robert-wotton', 'Robert Wotton', 'Other families', 'm'),
    ('english-royal', 'anne-belknap', 'Anne Belknap', 'Other families', 'f'),
    ('english-royal', 'henry-belknap', 'Henry Belknap', 'Other families', 'm'),
    ('english-royal', 'catherine-fitzalan', 'Catherine FitzAlan', 'Other families', 'f'),
    ('english-royal', 'william-fitzalan', 'William FitzAlan', 'Other families', 'm'),
    ('english-royal', 'anne-percy', 'Anne Percy', 'Other families', 'f'),
    ('english-royal', 'eleanor-brandon', 'Eleanor Brandon', 'Other families', 'f'),
    ('english-royal', 'henry-clifford', 'Henry Clifford', 'Other families', 'm'),
    ('english-royal', 'margaret-clifford', 'Margaret Clifford', 'Other families', 'f'),
    ('english-royal', 'anne-dacre', 'Anne Dacre', 'Other families', 'f'),
    ('english-royal', 'william-dacre', 'William Dacre', 'Other families', 'm'),
    ('english-royal', 'elizabeth-talbot-3', 'Elizabeth Talbot', 'Other families', 'f'),
    ('english-royal', 'george-talbot', 'George Talbot', 'Other families', 'm'),
    ('english-royal', 'alice-montagu', 'Alice Montagu', 'Other families', 'f'),
    ('english-royal', 'thomas-montagu', 'Thomas Montagu', 'Other families', 'm'),
    ('english-royal', 'joan-le-strange', 'Joan le Strange', 'Other families', 'f'),
    ('english-royal', 'john-le-strange', 'John le Strange', 'Other families', 'm'),
    ('english-royal', 'jacquette-wydvill', 'Jacquette Wydvill', 'Other families', 'f'),
    ('english-royal', 'anne-hastings', 'Anne Hastings', 'Other families', 'f'),
    ('english-royal', 'edward-hastings', 'Edward Hastings', 'Other families', 'm'),
    ('english-royal', 'mary-hungerford', 'Mary Hungerford', 'Other families', 'f'),
    ('english-royal', 'thomas-hungerford', 'Thomas Hungerford', 'Other families', 'm'),
    ('english-royal', 'margaret-barlow', 'Margaret Barlow', 'Other families', 'f'),
    ('english-royal', 'ellis-barlow', 'Ellis Barlow', 'Other families', 'm'),
    ('english-royal', 'anne-reddish', 'Anne Reddish', 'Other families', 'f'),
    ('english-royal', 'otes-reddish', 'Otes Reddish', 'Other families', 'm'),
    ('english-royal', 'mary-cotton', 'Mary Cotton', 'Other families', 'f'),
    ('english-royal', 'george-cotton', 'George Cotton', 'Other families', 'm'),
    ('english-royal', 'mary-onley', 'Mary Onley', 'Other families', 'f'),
    ('english-royal', 'john-onley', 'John Onley', 'Other families', 'm'),
    ('english-royal', 'thomas-keyes', 'Thomas Keyes', 'Other families', 'm'),
    ('english-royal', 'anne-stanhope', 'Anne Stanhope', 'Other families', 'f'),
    ('english-royal', 'henry-herbert', 'Henry Herbert', 'Other families', 'm'),
    ('english-royal', 'margaret-gamage', 'Margaret Gamage', 'Other families', 'f'),
    ('english-royal', 'thomas-gamage', 'Thomas Gamage', 'Other families', 'm'),
    ('english-royal', 'henry-pranell', 'Henry Pranell', 'Other families', 'm'),
    ('english-royal', 'mabel-burton', 'Mabel Burton', 'Other families', 'f'),
    ('english-royal', 'nicholas-burton', 'Nicholas Burton', 'Other families', 'm'),
    ('english-royal', 'margery-wentworth', 'Margery Wentworth', 'Other families', 'f'),
    ('english-royal', 'henry-wentworth', 'Henry Wentworth', 'Other families', 'm'),
    ('english-royal', 'thomas-parr', 'Thomas Parr', 'Other families', 'm'),
    ('english-royal', 'maud-green', 'Maud Green', 'Other families', 'f'),
    ('english-royal', 'thomas-green', 'Thomas Green', 'Other families', 'm'),
    ('english-royal', 'edward-burgh', 'Edward Burgh', 'Other families', 'm'),
    ('english-royal', 'gilbert-gray', 'Gilbert Gray', 'Other families', 'm'),
    ('english-royal', 'elizabeth-cavendish', 'Elizabeth Cavendish', 'Other families', 'f'),
    ('english-royal', 'william-cavendish', 'William Cavendish', 'Other families', 'm'),
    ('english-royal', 'margaret-boyd', 'Margaret Boyd', 'Other families', 'f'),
    ('english-royal', 'janet-kennedy', 'Janet Kennedy', 'Other families', 'f'),
    ('english-royal', 'elizabeth-campbell', 'Elizabeth Campbell', 'Other families', 'f'),
    ('english-royal', 'colin-campbell', 'Colin Campbell', 'Other families', 'm'),
    ('english-royal', 'margaret-drummond', 'Margaret Drummond', 'Other families', 'f'),
    ('english-royal', 'john-gordon', 'John Gordon', 'Other families', 'm'),
    ('english-royal', 'john-drummond-2', 'John Drummond', 'Other families', 'm'),
    ('english-royal', 'malcolm-fleming', 'Malcolm Fleming', 'Other families', 'm'),
    ('english-royal', 'mary-of-lorraine', 'Mary of Lorraine', 'Other families', 'f'),
    ('english-royal', 'louis-of-orleans', 'Louis of Orleans', 'Other families', 'm'),
    ('english-royal', 'catherine-de-medicis', 'Catherine de Medicis', 'Other families', 'f'),
    ('english-royal', 'james-hepburn', 'James Hepburn', 'Other families', 'm'),
    ('english-royal', 'anne-of-oldenburg', 'Anne of Oldenburg', 'Other families', 'f'),
    ('english-royal', 'mary-boleyn', 'Mary Boleyn', 'Other families', 'f'),
    ('english-royal', 'william-carey', 'William Carey', 'Other families', 'm'),
    ('english-royal', 'henry-carey', 'Henry Carey', 'Other families', 'm'),
    ('english-royal', 'catherine-carey', 'Catherine Carey', 'Other families', 'f'),
    ('english-royal', 'francis-knollys', 'Francis Knollys', 'Other families', 'm'),
    ('english-royal', 'anne-morgan', 'Anne Morgan', 'Other families', 'f'),
    ('english-royal', 'philip-ii', 'Philip II', 'Other families', 'm'),
    ('english-royal', 'guilford-dudley', 'Guilford Dudley', 'Other families', 'm'),
    ('english-royal', 'margaret-kyme', 'Margaret Kyme', 'Other families', 'f');

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
-- SAGA 12 of 14: GREEK GODS   [id: greek-gods, category: mythology]
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
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('greek-gods', 'andromache', 'Andromache', 'Greek pantheon', 'f'),
    ('greek-gods', 'hera', 'Hera', 'Greek pantheon', 'f'),
    ('greek-gods', 'eros', 'Eros', 'Greek pantheon', 'm'),
    ('greek-gods', 'hebe', 'Hebe', 'Greek pantheon', 'f'),
    ('greek-gods', 'ares', 'Ares', 'Greek pantheon', 'm'),
    ('greek-gods', 'adonis', 'Adonis', 'Greek pantheon', 'm'),
    ('greek-gods', 'dionne', 'Dionne', 'Greek pantheon', 'f'),
    ('greek-gods', 'aphrodite', 'Aphrodite', 'Greek pantheon', 'f'),
    ('greek-gods', 'anchises', 'Anchises', 'Greek pantheon', 'm'),
    ('greek-gods', 'aeneas', 'Aeneas', 'Greek pantheon', 'm'),
    ('greek-gods', 'creusa', 'Creusa', 'Greek pantheon', 'f'),
    ('greek-gods', 'silvius-aeneas', 'Silvius Aeneas', 'Greek pantheon', 'm'),
    ('greek-gods', 'numa-pompilius', 'Numa Pompilius', 'Greek pantheon', 'm'),
    ('greek-gods', 'rhea-silvia', 'Rhea Silvia', 'Greek pantheon', 'f'),
    ('greek-gods', 'fetebir', 'Fetebir', 'Greek pantheon', 'm'),
    ('greek-gods', 'lavinia', 'Lavinia', 'Greek pantheon', 'f'),
    ('greek-gods', 'ascanius-iulus', 'Ascanius Iulus', 'Greek pantheon', 'm'),
    ('greek-gods', 'ate', 'Ate', 'Greek pantheon', 'f'),
    ('greek-gods', 'neoptolemus', 'Neoptolemus', 'Greek pantheon', 'm'),
    ('greek-gods', 'persephone', 'Persephone', 'Greek pantheon', 'f'),
    ('greek-gods', 'demeter', 'Demeter', 'Greek pantheon', 'f'),
    ('greek-gods', 'hades', 'Hades', 'Greek pantheon', 'm'),
    ('greek-gods', 'cronus', 'Cronus', 'Greek pantheon', 'm'),
    ('greek-gods', 'rhea', 'Rhea', 'Greek pantheon', 'f'),
    ('greek-gods', 'hephaestus', 'Hephaestus', 'Greek pantheon', 'm'),
    ('greek-gods', 'hercules', 'Hercules', 'Greek pantheon', 'm'),
    ('greek-gods', 'alcmene', 'Alcmene', 'Greek pantheon', 'f'),
    ('greek-gods', 'megara', 'Megara', 'Greek pantheon', 'f'),
    ('greek-gods', 'deianira', 'Deianira', 'Greek pantheon', 'f'),
    ('greek-gods', 'uranus', 'Uranus', 'Greek pantheon', 'm'),
    ('greek-gods', 'gaea', 'Gaea', 'Greek pantheon', 'f'),
    ('greek-gods', 'poseidon', 'Poseidon', 'Greek pantheon', 'm'),
    ('greek-gods', 'amphitrite', 'Amphitrite', 'Greek pantheon', 'f'),
    ('greek-gods', 'triton', 'Triton', 'Greek pantheon', 'm'),
    ('greek-gods', 'medusa', 'Medusa', 'Greek pantheon', 'f'),
    ('greek-gods', 'pegasus', 'Pegasus', 'Greek pantheon', 'm'),
    ('greek-gods', 'orion', 'Orion', 'Greek pantheon', 'm'),
    ('greek-gods', 'polyphemus', 'Polyphemus', 'Greek pantheon', 'm'),
    ('greek-gods', 'hestia', 'Hestia', 'Greek pantheon', 'f'),
    ('greek-gods', 'eileithya', 'Eileithya', 'Greek pantheon', 'f'),
    ('greek-gods', 'achilles', 'Achilles', 'Greek pantheon', 'm'),
    ('greek-gods', 'peleus', 'Peleus', 'Greek pantheon', 'm'),
    ('greek-gods', 'thetis', 'Thetis', 'Greek pantheon', 'f'),
    ('greek-gods', 'neures', 'Neures', 'Greek pantheon', 'm'),
    ('greek-gods', 'pontus', 'Pontus', 'Greek pantheon', 'm'),
    ('greek-gods', 'doris', 'Doris', 'Greek pantheon', 'f'),
    ('greek-gods', 'oceanus', 'Oceanus', 'Greek pantheon', 'm'),
    ('greek-gods', 'chaos', 'Chaos', 'Greek pantheon', 'm'),
    ('greek-gods', 'thethys', 'Thethys', 'Greek pantheon', 'f'),
    ('greek-gods', 'deidamia', 'Deidamia', 'Greek pantheon', 'f'),
    ('greek-gods', 'hermione', 'Hermione', 'Greek pantheon', 'f'),
    ('greek-gods', 'helen', 'Helen', 'Greek pantheon', 'f'),
    ('greek-gods', 'menelaus', 'Menelaus', 'Greek pantheon', 'm'),
    ('greek-gods', 'zeus', 'Zeus', 'Greek pantheon', 'm'),
    ('greek-gods', 'leda', 'Leda', 'Greek pantheon', 'f'),
    ('greek-gods', 'polydueces', 'Polydueces', 'Greek pantheon', 'm'),
    ('greek-gods', 'a-titan-coeus', 'A Titan Coeus', 'Greek pantheon', 'm'),
    ('greek-gods', 'a-titan-crius', 'A Titan Crius', 'Greek pantheon', 'm'),
    ('greek-gods', 'a-titan-hyperion', 'A Titan Hyperion', 'Greek pantheon', 'm'),
    ('greek-gods', 'a-titan-iapetus', 'A Titan Iapetus', 'Greek pantheon', 'm'),
    ('greek-gods', 'a-titan-thea', 'A Titan Thea', 'Greek pantheon', 'f'),
    ('greek-gods', 'a-titan-themis', 'A Titan Themis', 'Greek pantheon', 'f'),
    ('greek-gods', 'phoebe', 'Phoebe', 'Greek pantheon', 'f'),
    ('greek-gods', 'a-titan-mnemosyne', 'A Titan Mnemosyne', 'Greek pantheon', 'f'),
    ('greek-gods', 'athena', 'Athena', 'Greek pantheon', 'f'),
    ('greek-gods', 'apollo', 'Apollo', 'Greek pantheon', 'm'),
    ('greek-gods', 'artemis', 'Artemis', 'Greek pantheon', 'f'),
    ('greek-gods', 'leto', 'Leto', 'Greek pantheon', 'f'),
    ('greek-gods', 'eris', 'Eris', 'Greek pantheon', 'f');

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
-- SAGA 13 of 14: NORSE GODS   [id: norse-gods, category: mythology]
-- Author:  Compiled by unknown
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
    ('norse-gods', 'mythology', 12, 'Norse Gods', 'Norse Gods', 'GEDCOM genealogy (Norse+Gods.ged)', 'Compiled by unknown', 'Sources cited: RCKarnes; World Family Tree Vol. 5; Aderholt Hillman Hughes Solomon Dunn Funderburg; Guy Allen Sims', 'Mythology', '117 people and 59 families, imported from a public GEDCOM sample.');

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
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('norse-gods', 'bestla', 'Bestla', 'Norse pantheon', 'f'),
    ('norse-gods', 'sibil', 'Sibil', 'Norse pantheon', 'f'),
    ('norse-gods', 'angrboda', 'Angrboda', 'Norse pantheon', 'f'),
    ('norse-gods', 'annar', 'Annar', 'Norse pantheon', 'm'),
    ('norse-gods', 'au-r', 'Auðr', 'Norse pantheon', 'f'),
    ('norse-gods', 'au-umbla', 'Auðumbla', 'Norse pantheon', 'f'),
    ('norse-gods', 'aurbo-a', 'Aurboða', 'Norse pantheon', 'f'),
    ('norse-gods', 'gir', 'Ægir', 'Norse pantheon', 'm'),
    ('norse-gods', 'baldr', 'Baldr', 'Norse pantheon', 'm'),
    ('norse-gods', 'baugi', 'Baugi', 'Norse pantheon', 'm'),
    ('norse-gods', 'bara', 'Bára', 'Norse pantheon', 'f'),
    ('norse-gods', 'beli', 'Beli', 'Norse pantheon', 'm'),
    ('norse-gods', 'blo-ughadda', 'Blóðughadda', 'Norse pantheon', 'f'),
    ('norse-gods', 'bolthorn', 'Bolthorn', 'Norse pantheon', 'm'),
    ('norse-gods', 'borr', 'Borr', 'Norse pantheon', 'm'),
    ('norse-gods', 'bragi', 'Bragi', 'Norse pantheon', 'm'),
    ('norse-gods', 'buri', 'Búri', 'Norse pantheon', 'm'),
    ('norse-gods', 'bylgja', 'Bylgja', 'Norse pantheon', 'f'),
    ('norse-gods', 'byleistr', 'Býleistr', 'Norse pantheon', 'm'),
    ('norse-gods', 'giant-teacher-of-odin-of-nine-magic-charms', 'Giant Teacher of Odin of Nine Magic Charms', 'Norse pantheon', 'm'),
    ('norse-gods', 'dagr', 'Dagr', 'Norse pantheon', 'm'),
    ('norse-gods', 'delling', 'Delling', 'Norse pantheon', 'm'),
    ('norse-gods', 'dufa', 'Dúfa', 'Norse pantheon', 'f'),
    ('norse-gods', 'farbauti', 'Fárbauti', 'Norse pantheon', 'm'),
    ('norse-gods', 'fenrir', 'Fenrir', 'Norse pantheon', 'm'),
    ('norse-gods', 'fjalar', 'Fjalar', 'Norse pantheon', 'm'),
    ('norse-gods', 'fjolnir', 'Fjölnir', 'Norse pantheon', 'm'),
    ('norse-gods', 'fornjot', 'Fornjót', 'Norse pantheon', 'm'),
    ('norse-gods', 'forseti', 'Forseti', 'Norse pantheon', 'm'),
    ('norse-gods', 'freyja', 'Freyja', 'Norse pantheon', 'f'),
    ('norse-gods', 'freyr', 'Freyr', 'Norse pantheon', 'm'),
    ('norse-gods', 'frigg', 'Frigg', 'Norse pantheon', 'f'),
    ('norse-gods', 'galar', 'Galar', 'Norse pantheon', 'm'),
    ('norse-gods', 'gangr', 'Gangr', 'Norse pantheon', 'm'),
    ('norse-gods', 'gefjun', 'Gefjun', 'Norse pantheon', 'f'),
    ('norse-gods', 'gerd', 'Gerd', 'Norse pantheon', 'f'),
    ('norse-gods', 'gersemi', 'Gersemi', 'Norse pantheon', 'f'),
    ('norse-gods', 'a-giantess', 'A Giantess', 'Norse pantheon', 'f'),
    ('norse-gods', 'gilling', 'Gilling', 'Norse pantheon', 'm'),
    ('norse-gods', 'rich-girl', 'Rich Girl', 'Norse pantheon', 'f'),
    ('norse-gods', 'glaur', 'Glaur', 'Norse pantheon', 'f'),
    ('norse-gods', 'grid', 'Grid', 'Norse pantheon', 'f'),
    ('norse-gods', 'gunnlo', 'Gunnlöð', 'Norse pantheon', 'f'),
    ('norse-gods', 'hefring', 'Hefring', 'Norse pantheon', 'f'),
    ('norse-gods', 'heimdall', 'Heimdall', 'Norse pantheon', 'm'),
    ('norse-gods', 'hel', 'Hel', 'Norse pantheon', 'f'),
    ('norse-gods', 'helbindi', 'Helbindi', 'Norse pantheon', 'm'),
    ('norse-gods', 'hermod', 'Hermod', 'Norse pantheon', 'm'),
    ('norse-gods', 'himingl-va', 'Himinglæva', 'Norse pantheon', 'f'),
    ('norse-gods', 'hnoss', 'Hnoss', 'Norse pantheon', 'f'),
    ('norse-gods', 'ho-r', 'Höðr', 'Norse pantheon', 'm'),
    ('norse-gods', 'hati-hrodvitnisson', 'Hati Hródvitnisson', 'Norse pantheon', 'm'),
    ('norse-gods', 'hronn', 'Hrönn', 'Norse pantheon', 'f'),
    ('norse-gods', 'idi', 'Idi', 'Norse pantheon', 'm'),
    ('norse-gods', 'i-unn', 'Iðunn', 'Norse pantheon', 'f'),
    ('norse-gods', 'jarnsaxa', 'Járnsaxa', 'Norse pantheon', 'f'),
    ('norse-gods', 'jor', 'Jörð', 'Norse pantheon', 'f'),
    ('norse-gods', 'jormungandr', 'Jörmungandr', 'Norse pantheon', 'm'),
    ('norse-gods', 'kari', 'Kári', 'Norse pantheon', 'm'),
    ('norse-gods', 'kolga', 'Kólga', 'Norse pantheon', 'm'),
    ('norse-gods', 'kvasir', 'Kvasir', 'Norse pantheon', 'm'),
    ('norse-gods', 'laufey', 'Laufey', 'Norse pantheon', 'f'),
    ('norse-gods', 'lofn', 'Lofn', 'Norse pantheon', 'f'),
    ('norse-gods', 'logi', 'Logi', 'Norse pantheon', 'm'),
    ('norse-gods', 'loki', 'Loki', 'Norse pantheon', 'm'),
    ('norse-gods', 'magni', 'Magni', 'Norse pantheon', 'm'),
    ('norse-gods', 'mani', 'Máni', 'Norse pantheon', 'm'),
    ('norse-gods', 'mimir', 'Mímir', 'Norse pantheon', 'm'),
    ('norse-gods', 'mo-i', 'Móði', 'Norse pantheon', 'm'),
    ('norse-gods', 'mundilfari', 'Mundilfari', 'Norse pantheon', 'm'),
    ('norse-gods', 'naglfari', 'Naglfari', 'Norse pantheon', 'm'),
    ('norse-gods', 'nanna', 'Nanna', 'Norse pantheon', 'f'),
    ('norse-gods', 'narfi', 'Narfi', 'Norse pantheon', 'm'),
    ('norse-gods', 'nepr', 'Nepr', 'Norse pantheon', 'm'),
    ('norse-gods', 'nerthus', 'Nerthus', 'Norse pantheon', 'f'),
    ('norse-gods', 'njor-r', 'Njörðr', 'Norse pantheon', 'm'),
    ('norse-gods', 'nott', 'Nótt', 'Norse pantheon', 'f'),
    ('norse-gods', 'odin', 'Odin', 'Norse pantheon', 'm'),
    ('norse-gods', 'olvaldi', 'Olvaldi', 'Norse pantheon', 'm'),
    ('norse-gods', 'o-r', 'Óðr', 'Norse pantheon', 'm'),
    ('norse-gods', 'ran', 'Rán', 'Norse pantheon', 'f'),
    ('norse-gods', 'rindr', 'Rindr', 'Norse pantheon', 'f'),
    ('norse-gods', 'all-the-female-god-s-saliva', 'All the Female God''s Saliva', 'Norse pantheon', 'f'),
    ('norse-gods', 'all-the-male-god-s-saliva', 'All the Male God''s Saliva', 'Norse pantheon', 'm'),
    ('norse-gods', 'saga', 'Sága', 'Norse pantheon', 'f'),
    ('norse-gods', 'seaxneat', 'Seaxneat', 'Norse pantheon', 'm'),
    ('norse-gods', 'sif', 'Sif', 'Norse pantheon', 'f'),
    ('norse-gods', 'sigyn', 'Sigyn', 'Norse pantheon', 'f'),
    ('norse-gods', 'sjofn', 'Sjöfn', 'Norse pantheon', 'f'),
    ('norse-gods', 'ska-i', 'Skaði', 'Norse pantheon', 'f'),
    ('norse-gods', 'skirnir', 'Skirnir', 'Norse pantheon', 'm'),
    ('norse-gods', 'skoll', 'Skoll', 'Norse pantheon', 'm'),
    ('norse-gods', 'skuld', 'Skuld', 'Norse pantheon', 'f'),
    ('norse-gods', 'several-sons', 'Several Sons', 'Norse pantheon', 'm'),
    ('norse-gods', 'sowilo', 'Sowilo', 'Norse pantheon', 'f'),
    ('norse-gods', 'sunna', 'Sunna', 'Norse pantheon', 'f'),
    ('norse-gods', 'suttungr', 'Suttungr', 'Norse pantheon', 'm'),
    ('norse-gods', 'thjazi', 'Thjazi', 'Norse pantheon', 'm'),
    ('norse-gods', 'thor', 'Thor', 'Norse pantheon', 'm'),
    ('norse-gods', 'tyr', 'Týr', 'Norse pantheon', 'm'),
    ('norse-gods', 'ru-r', 'Þrúðr', 'Norse pantheon', 'f'),
    ('norse-gods', 'ullr', 'Ullr', 'Norse pantheon', 'm'),
    ('norse-gods', 'unknown', 'Unknown', 'Norse pantheon', 'm'),
    ('norse-gods', 'unknown-2', 'Unknown', 'Norse pantheon', 'm'),
    ('norse-gods', 'unknown-3', 'Unknown', 'Norse pantheon', 'f'),
    ('norse-gods', 'unnr', 'Unnr', 'Norse pantheon', 'f'),
    ('norse-gods', 'vali', 'Váli', 'Norse pantheon', 'm'),
    ('norse-gods', 'var', 'Vár', 'Norse pantheon', 'f'),
    ('norse-gods', 've', 'Ve', 'Norse pantheon', 'm'),
    ('norse-gods', 'verdandi', 'Verdandi', 'Norse pantheon', 'f'),
    ('norse-gods', 'vidar', 'Vidar', 'Norse pantheon', 'm'),
    ('norse-gods', 'vili', 'Vili', 'Norse pantheon', 'm'),
    ('norse-gods', 'visbur', 'Visbur', 'Norse pantheon', 'm'),
    ('norse-gods', 'vor', 'Vör', 'Norse pantheon', 'm'),
    ('norse-gods', 'gilling-s-wife', 'Gilling''s Wife', 'Norse pantheon', 'f'),
    ('norse-gods', 'wyrd', 'Wyrd', 'Norse pantheon', 'f'),
    ('norse-gods', 'ynglingatal', 'Ynglingatal', 'Norse pantheon', 'm');

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
-- SAGA 14 of 14: ROMAN GODS   [id: roman-gods, category: mythology]
-- Author:  Compiled by unknown
-- Medium:  GEDCOM genealogy (Roman+Gods.ged)
-- Canon:   As recorded in the GEDCOM file
-- Covers:  322 people and 165 families, imported from a public GEDCOM sample.
-- Rows:    1 houses, 322 people, 165 families, 508 members
-- =================================================================================================

-- ── Reset (removes this saga and, by cascade, all of its rows) ─────────────────────────────────
DELETE FROM saga WHERE id = 'roman-gods';

-- ── Saga ───────────────────────────────────────────────────────────────────────────────────────
INSERT INTO saga (id, category, position, title, work, medium, author, canon, genre, covers) VALUES
    ('roman-gods', 'mythology', 13, 'Roman Gods', 'Roman Gods', 'GEDCOM genealogy (Roman+Gods.ged)', 'Compiled by unknown', 'As recorded in the GEDCOM file', 'Mythology', '322 people and 165 families, imported from a public GEDCOM sample.');

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
INSERT INTO person (saga_id, id, name, house, sex) VALUES
    ('roman-gods', 'jupiter', 'Jupiter', 'Roman pantheon', 'm'),
    ('roman-gods', 'unnamed-daughter', '(unnamed daughter)', 'Roman pantheon', 'f'),
    ('roman-gods', 'abrota', 'Abrota', 'Roman pantheon', 'f'),
    ('roman-gods', 'aceso', 'Aceso', 'Roman pantheon', 'f'),
    ('roman-gods', 'achaeus', 'Achaeus', 'Roman pantheon', 'm'),
    ('roman-gods', 'achilles', 'Achilles', 'Roman pantheon', 'm'),
    ('roman-gods', 'achiroe', 'Achiroe', 'Roman pantheon', 'f'),
    ('roman-gods', 'acis', 'Acis', 'Roman pantheon', 'm'),
    ('roman-gods', 'aegeus', 'Aegeus', 'Roman pantheon', 'm'),
    ('roman-gods', 'aegyptus', 'Aegyptus', 'Roman pantheon', 'm'),
    ('roman-gods', 'aeneas', 'Aeneas', 'Roman pantheon', 'm'),
    ('roman-gods', 'aesculapius', 'Aesculapius', 'Roman pantheon', 'm'),
    ('roman-gods', 'aesimus', 'Aesimus', 'Roman pantheon', 'm'),
    ('roman-gods', 'aglaea', 'Aglaea', 'Roman pantheon', 'f'),
    ('roman-gods', 'agrippa', 'Agrippa', 'Roman pantheon', 'm'),
    ('roman-gods', 'ajax', 'Ajax', 'Roman pantheon', 'm'),
    ('roman-gods', 'alba', 'Alba', 'Roman pantheon', 'm'),
    ('roman-gods', 'alcmene', 'Alcmene', 'Roman pantheon', 'f'),
    ('roman-gods', 'alexiares', 'Alexiares', 'Roman pantheon', 'm'),
    ('roman-gods', 'almon', 'Almon', 'Roman pantheon', 'm'),
    ('roman-gods', 'amata', 'Amata', 'Roman pantheon', 'f'),
    ('roman-gods', 'amphithea', 'Amphithea', 'Roman pantheon', 'f'),
    ('roman-gods', 'amulius', 'Amulius', 'Roman pantheon', 'm'),
    ('roman-gods', 'anchises', 'Anchises', 'Roman pantheon', 'm'),
    ('roman-gods', 'anicetus', 'Anicetus', 'Roman pantheon', 'm'),
    ('roman-gods', 'antevorta', 'Antevorta', 'Roman pantheon', 'm'),
    ('roman-gods', 'anticlea', 'Anticlea', 'Roman pantheon', 'f'),
    ('roman-gods', 'anton', 'Anton', 'Roman pantheon', 'm'),
    ('roman-gods', 'apollo', 'Apollo', 'Roman pantheon', 'm'),
    ('roman-gods', 'aquilo', 'Aquilo', 'Roman pantheon', 'm'),
    ('roman-gods', 'aratus', 'Aratus', 'Roman pantheon', 'm'),
    ('roman-gods', 'arcesius', 'Arcesius', 'Roman pantheon', 'm'),
    ('roman-gods', 'aricia', 'Aricia', 'Roman pantheon', 'f'),
    ('roman-gods', 'aristodama', 'Aristodama', 'Roman pantheon', 'f'),
    ('roman-gods', 'ascanius', 'Ascanius', 'Roman pantheon', 'm'),
    ('roman-gods', 'asopus', 'Asopus', 'Roman pantheon', 'm'),
    ('roman-gods', 'asteria', 'Asteria', 'Roman pantheon', 'f'),
    ('roman-gods', 'astraeus', 'Astraeus', 'Roman pantheon', 'm'),
    ('roman-gods', 'astyoche', 'Astyoche', 'Roman pantheon', 'f'),
    ('roman-gods', 'ate', 'Ate', 'Roman pantheon', 'f'),
    ('roman-gods', 'atlas', 'Atlas', 'Roman pantheon', 'm'),
    ('roman-gods', 'atys', 'Atys', 'Roman pantheon', 'm'),
    ('roman-gods', 'aurora', 'Aurora', 'Roman pantheon', 'f'),
    ('roman-gods', 'auster', 'Auster', 'Roman pantheon', 'm'),
    ('roman-gods', 'autolycus', 'Autolycus', 'Roman pantheon', 'm'),
    ('roman-gods', 'aventinus', 'Aventinus', 'Roman pantheon', 'm'),
    ('roman-gods', 'olus', 'Æolus', 'Roman pantheon', 'm'),
    ('roman-gods', 'bacchus', 'Bacchus', 'Roman pantheon', 'm'),
    ('roman-gods', 'bellerophon', 'Bellerophon', 'Roman pantheon', 'm'),
    ('roman-gods', 'bellona', 'Bellona', 'Roman pantheon', 'f'),
    ('roman-gods', 'belus', 'Belus', 'Roman pantheon', 'm'),
    ('roman-gods', 'bia', 'Bia', 'Roman pantheon', 'f'),
    ('roman-gods', 'brutus-of-britain', 'Brutus of Britain', 'Roman pantheon', 'm'),
    ('roman-gods', 'caca', 'Caca', 'Roman pantheon', 'f'),
    ('roman-gods', 'cacus', 'Cacus', 'Roman pantheon', 'm'),
    ('roman-gods', 'cadmus', 'Cadmus', 'Roman pantheon', 'm'),
    ('roman-gods', 'caelus', 'Caelus', 'Roman pantheon', 'm'),
    ('roman-gods', 'caliadne', 'Caliadne', 'Roman pantheon', 'f'),
    ('roman-gods', 'capetus', 'Capetus', 'Roman pantheon', 'm'),
    ('roman-gods', 'capys', 'Capys', 'Roman pantheon', 'm'),
    ('roman-gods', 'carmenta', 'Carmenta', 'Roman pantheon', 'f'),
    ('roman-gods', 'carmenta-2', 'Carmenta', 'Roman pantheon', 'm'),
    ('roman-gods', 'carystus', 'Carystus.', 'Roman pantheon', 'm'),
    ('roman-gods', 'cephalus', 'Cephalus', 'Roman pantheon', 'm'),
    ('roman-gods', 'ceres', 'Ceres', 'Roman pantheon', 'f'),
    ('roman-gods', 'chaos', 'Chaos', 'Roman pantheon', 'm'),
    ('roman-gods', 'chariclo', 'Chariclo', 'Roman pantheon', 'f'),
    ('roman-gods', 'charopus', 'Charopus', 'Roman pantheon', 'm'),
    ('roman-gods', 'chione', 'Chione', 'Roman pantheon', 'f'),
    ('roman-gods', 'chiron', 'Chiron', 'Roman pantheon', 'm'),
    ('roman-gods', 'chryse', 'Chryse', 'Roman pantheon', 'f'),
    ('roman-gods', 'cleopatra', 'Cleopatra', 'Roman pantheon', 'f'),
    ('roman-gods', 'clitunno', 'Clitunno', 'Roman pantheon', 'm'),
    ('roman-gods', 'clymene', 'Clymene', 'Roman pantheon', 'f'),
    ('roman-gods', 'clymene-2', 'Clymene', 'Roman pantheon', 'f'),
    ('roman-gods', 'clytius', 'Clytius', 'Roman pantheon', 'm'),
    ('roman-gods', 'coronis', 'Coronis', 'Roman pantheon', 'f'),
    ('roman-gods', 'cratos', 'Cratos', 'Roman pantheon', 'm'),
    ('roman-gods', 'creusa', 'Creusa', 'Roman pantheon', 'f'),
    ('roman-gods', 'crius', 'Crius', 'Roman pantheon', 'm'),
    ('roman-gods', 'cupid', 'Cupid', 'Roman pantheon', 'm'),
    ('roman-gods', 'cychreus', 'Cychreus', 'Roman pantheon', 'm'),
    ('roman-gods', 'cycnus', 'Cycnus', 'Roman pantheon', 'm'),
    ('roman-gods', 'danaus', 'Danaus', 'Roman pantheon', 'm'),
    ('roman-gods', 'daphne', 'Daphne', 'Roman pantheon', 'f'),
    ('roman-gods', 'dardanus', 'Dardanus', 'Roman pantheon', 'm'),
    ('roman-gods', 'decima', 'Decima', 'Roman pantheon', 'f'),
    ('roman-gods', 'deianira', 'Deianira', 'Roman pantheon', 'f'),
    ('roman-gods', 'deidameia', 'Deidameia', 'Roman pantheon', 'm'),
    ('roman-gods', 'deidamia', 'Deidamia', 'Roman pantheon', 'f'),
    ('roman-gods', 'deioneus', 'Deioneus', 'Roman pantheon', 'm'),
    ('roman-gods', 'deliades', 'Deliades', 'Roman pantheon', 'm'),
    ('roman-gods', 'deucalion', 'Deucalion', 'Roman pantheon', 'm'),
    ('roman-gods', 'deucalion-2', 'Deucalion', 'Roman pantheon', 'm'),
    ('roman-gods', 'diana', 'Diana', 'Roman pantheon', 'f'),
    ('roman-gods', 'dione', 'Dione', 'Roman pantheon', 'f'),
    ('roman-gods', 'discordia', 'Discordia', 'Roman pantheon', 'f'),
    ('roman-gods', 'discordia-2', 'Discordia', 'Roman pantheon', 'f'),
    ('roman-gods', 'dolops', 'Dolops', 'Roman pantheon', 'm'),
    ('roman-gods', 'doris', 'Doris', 'Roman pantheon', 'f'),
    ('roman-gods', 'dorus', 'Dorus', 'Roman pantheon', 'm'),
    ('roman-gods', 'egeria', 'Egeria', 'Roman pantheon', 'm'),
    ('roman-gods', 'eileithya', 'Eileithya', 'Roman pantheon', 'f'),
    ('roman-gods', 'electra', 'Electra', 'Roman pantheon', 'm'),
    ('roman-gods', 'endeis', 'Endeis', 'Roman pantheon', 'm'),
    ('roman-gods', 'eos', 'Eos', 'Roman pantheon', 'f'),
    ('roman-gods', 'epimetheus', 'Epimetheus', 'Roman pantheon', 'm'),
    ('roman-gods', 'epione', 'Epione', 'Roman pantheon', 'f'),
    ('roman-gods', 'erichtonius', 'Erichtonius', 'Roman pantheon', 'm'),
    ('roman-gods', 'eros', 'Eros', 'Roman pantheon', 'f'),
    ('roman-gods', 'eurybia', 'Eurybia', 'Roman pantheon', 'f'),
    ('roman-gods', 'eurynome', 'Eurynome', 'Roman pantheon', 'f'),
    ('roman-gods', 'eurypylus', 'Eurypylus', 'Roman pantheon', 'm'),
    ('roman-gods', 'evander', 'Evander', 'Roman pantheon', 'm'),
    ('roman-gods', 'everes', 'Everes', 'Roman pantheon', 'm'),
    ('roman-gods', 'fama', 'Fama', 'Roman pantheon', 'm'),
    ('roman-gods', 'fauna', 'Fauna', 'Roman pantheon', 'f'),
    ('roman-gods', 'faunus', 'Faunus', 'Roman pantheon', 'm'),
    ('roman-gods', 'faustulus', 'Faustulus', 'Roman pantheon', 'm'),
    ('roman-gods', 'favonius', 'Favonius', 'Roman pantheon', 'm'),
    ('roman-gods', 'feronia', 'Feronia', 'Roman pantheon', 'f'),
    ('roman-gods', 'fontus', 'Fontus', 'Roman pantheon', 'm'),
    ('roman-gods', 'ganymede', 'Ganymede', 'Roman pantheon', 'm'),
    ('roman-gods', 'gigantes', 'Gigantes', 'Roman pantheon', 'm'),
    ('roman-gods', 'glaucus', 'Glaucus', 'Roman pantheon', 'm'),
    ('roman-gods', 'glaucus-2', 'Glaucus', 'Roman pantheon', 'm'),
    ('roman-gods', 'gorgorphone', 'Gorgorphone', 'Roman pantheon', 'm'),
    ('roman-gods', 'graecus', 'Graecus', 'Roman pantheon', 'm'),
    ('roman-gods', 'harmonia', 'Harmonia', 'Roman pantheon', 'm'),
    ('roman-gods', 'helen', 'Helen', 'Roman pantheon', 'f'),
    ('roman-gods', 'hellen', 'Hellen', 'Roman pantheon', 'm'),
    ('roman-gods', 'hemithea', 'Hemithea', 'Roman pantheon', 'f'),
    ('roman-gods', 'hercules', 'Hercules', 'Roman pantheon', 'm'),
    ('roman-gods', 'hermione', 'Hermione', 'Roman pantheon', 'f'),
    ('roman-gods', 'hermus', 'Hermus', 'Roman pantheon', 'm'),
    ('roman-gods', 'hermus-2', 'Hermus', 'Roman pantheon', 'm'),
    ('roman-gods', 'hersilia', 'Hersilia', 'Roman pantheon', 'f'),
    ('roman-gods', 'herulus', 'Herulus', 'Roman pantheon', 'm'),
    ('roman-gods', 'hesione', 'Hesione', 'Roman pantheon', 'f'),
    ('roman-gods', 'hicetaon', 'Hicetaon', 'Roman pantheon', 'm'),
    ('roman-gods', 'hippasus', 'Hippasus', 'Roman pantheon', 'm'),
    ('roman-gods', 'hippe', 'Hippe', 'Roman pantheon', 'm'),
    ('roman-gods', 'honos', 'Honos', 'Roman pantheon', 'm'),
    ('roman-gods', 'hyades', 'Hyades', 'Roman pantheon', 'm'),
    ('roman-gods', 'hyperion', 'Hyperion', 'Roman pantheon', 'm'),
    ('roman-gods', 'hypermnestra', 'Hypermnestra', 'Roman pantheon', 'f'),
    ('roman-gods', 'iapetus', 'Iapetus', 'Roman pantheon', 'm'),
    ('roman-gods', 'iaso', 'Iaso', 'Roman pantheon', 'f'),
    ('roman-gods', 'icarius', 'Icarius', 'Roman pantheon', 'm'),
    ('roman-gods', 'ilus', 'Ilus', 'Roman pantheon', 'm'),
    ('roman-gods', 'iphiclus', 'Iphiclus', 'Roman pantheon', 'm'),
    ('roman-gods', 'iustitia', 'Iustitia', 'Roman pantheon', 'f'),
    ('roman-gods', 'janus', 'Janus', 'Roman pantheon', 'm'),
    ('roman-gods', 'juno', 'Juno', 'Roman pantheon', 'f'),
    ('roman-gods', 'justitia', 'Justitia', 'Roman pantheon', 'f'),
    ('roman-gods', 'juturna', 'Juturna', 'Roman pantheon', 'f'),
    ('roman-gods', 'juventas', 'Juventas', 'Roman pantheon', 'f'),
    ('roman-gods', 'ladon', 'Ladon', 'Roman pantheon', 'm'),
    ('roman-gods', 'laertes', 'Laertes', 'Roman pantheon', 'm'),
    ('roman-gods', 'lampus', 'Lampus', 'Roman pantheon', 'm'),
    ('roman-gods', 'laodamia', 'Laodamia', 'Roman pantheon', 'f'),
    ('roman-gods', 'laomedon', 'Laomedon', 'Roman pantheon', 'm'),
    ('roman-gods', 'lara', 'Lara', 'Roman pantheon', 'f'),
    ('roman-gods', 'acca-larentia', 'Acca Larentia', 'Roman pantheon', 'f'),
    ('roman-gods', 'lares-i', 'Lares I', 'Roman pantheon', 'm'),
    ('roman-gods', 'lares-ii', 'Lares II', 'Roman pantheon', 'm'),
    ('roman-gods', 'the-lares', 'The Lares', 'Roman pantheon', 'm'),
    ('roman-gods', 'latinus', 'Latinus', 'Roman pantheon', 'm'),
    ('roman-gods', 'latinus-2', 'Latinus', 'Roman pantheon', 'm'),
    ('roman-gods', 'latona', 'Latona', 'Roman pantheon', 'f'),
    ('roman-gods', 'lavinia', 'Lavinia', 'Roman pantheon', 'm'),
    ('roman-gods', 'leda', 'Leda', 'Roman pantheon', 'f'),
    ('roman-gods', 'leucippe', 'Leucippe', 'Roman pantheon', 'f'),
    ('roman-gods', 'libera', 'Libera', 'Roman pantheon', 'm'),
    ('roman-gods', 'lucifer', 'Lucifer', 'Roman pantheon', 'm'),
    ('roman-gods', 'luna', 'Luna', 'Roman pantheon', 'f'),
    ('roman-gods', 'lycus', 'Lycus', 'Roman pantheon', 'm'),
    ('roman-gods', 'lynceus', 'Lynceus', 'Roman pantheon', 'm'),
    ('roman-gods', 'machaon', 'Machaon', 'Roman pantheon', 'm'),
    ('roman-gods', 'magnetas', 'Magnetas', 'Roman pantheon', 'm'),
    ('roman-gods', 'maia', 'Maia', 'Roman pantheon', 'm'),
    ('roman-gods', 'makedon', 'Makedon', 'Roman pantheon', 'm'),
    ('roman-gods', 'the-manes', 'The Manes', 'Roman pantheon', 'm'),
    ('roman-gods', 'mania', 'Mania', 'Roman pantheon', 'f'),
    ('roman-gods', 'mantus', 'Mantus', 'Roman pantheon', 'm'),
    ('roman-gods', 'marica', 'Marica', 'Roman pantheon', 'f'),
    ('roman-gods', 'mars', 'Mars', 'Roman pantheon', 'm'),
    ('roman-gods', 'meditrina', 'Meditrina', 'Roman pantheon', 'f'),
    ('roman-gods', 'medusa', 'Medusa', 'Roman pantheon', 'f'),
    ('roman-gods', 'megara', 'Megara', 'Roman pantheon', 'f'),
    ('roman-gods', 'melanippus', 'Melanippus', 'Roman pantheon', 'm'),
    ('roman-gods', 'menelaus', 'Menelaus', 'Roman pantheon', 'm'),
    ('roman-gods', 'mercury', 'Mercury', 'Roman pantheon', 'm'),
    ('roman-gods', 'metis', 'Metis', 'Roman pantheon', 'f'),
    ('roman-gods', 'metope', 'Metope', 'Roman pantheon', 'f'),
    ('roman-gods', 'minerva', 'Minerva', 'Roman pantheon', 'f'),
    ('roman-gods', 'minyas', 'Minyas', 'Roman pantheon', 'm'),
    ('roman-gods', 'the-minyas', 'The Minyas', 'Roman pantheon', 'm'),
    ('roman-gods', 'moneta', 'Moneta', 'Roman pantheon', 'f'),
    ('roman-gods', 'mors', 'Mors', 'Roman pantheon', 'm'),
    ('roman-gods', 'morta', 'Morta', 'Roman pantheon', 'f'),
    ('roman-gods', 'neoptolemus', 'Neoptolemus', 'Roman pantheon', 'm'),
    ('roman-gods', 'neptune', 'Neptune', 'Roman pantheon', 'm'),
    ('roman-gods', 'neures', 'Neures', 'Roman pantheon', 'm'),
    ('roman-gods', 'nireus', 'Nireus', 'Roman pantheon', 'm'),
    ('roman-gods', 'nisos', 'Nisos', 'Roman pantheon', 'm'),
    ('roman-gods', 'nona', 'Nona', 'Roman pantheon', 'f'),
    ('roman-gods', 'nox', 'Nox', 'Roman pantheon', 'm'),
    ('roman-gods', 'numitor', 'Numitor', 'Roman pantheon', 'm'),
    ('roman-gods', 'lydian-nymphs', 'Lydian nymphs', 'Roman pantheon', 'm'),
    ('roman-gods', 'oceanus', 'Oceanus', 'Roman pantheon', 'm'),
    ('roman-gods', 'ocyrhoe', 'Ocyrhoe', 'Roman pantheon', 'm'),
    ('roman-gods', 'oebalus', 'Oebalus', 'Roman pantheon', 'm'),
    ('roman-gods', 'ops', 'Ops', 'Roman pantheon', 'f'),
    ('roman-gods', 'orion', 'Orion', 'Roman pantheon', 'm'),
    ('roman-gods', 'orseis', 'Orseis', 'Roman pantheon', 'f'),
    ('roman-gods', 'pallas', 'Pallas', 'Roman pantheon', 'm'),
    ('roman-gods', 'pallas-2', 'Pallas', 'Roman pantheon', 'm'),
    ('roman-gods', 'pallas-3', 'Pallas', 'Roman pantheon', 'm'),
    ('roman-gods', 'panacea', 'Panacea', 'Roman pantheon', 'm'),
    ('roman-gods', 'pandion-ii', 'Pandion II', 'Roman pantheon', 'm'),
    ('roman-gods', 'pandora', 'Pandora', 'Roman pantheon', 'm'),
    ('roman-gods', 'pandora-2', 'Pandora', 'Roman pantheon', 'f'),
    ('roman-gods', 'pax', 'Pax', 'Roman pantheon', 'm'),
    ('roman-gods', 'pegasus', 'Pegasus', 'Roman pantheon', 'm'),
    ('roman-gods', 'peleus', 'Peleus', 'Roman pantheon', 'm'),
    ('roman-gods', 'penelope', 'Penelope', 'Roman pantheon', 'm'),
    ('roman-gods', 'penia', 'Penia', 'Roman pantheon', 'f'),
    ('roman-gods', 'periboea', 'Periboea', 'Roman pantheon', 'f'),
    ('roman-gods', 'perimede', 'Perimede', 'Roman pantheon', 'm'),
    ('roman-gods', 'perleres', 'Perleres', 'Roman pantheon', 'm'),
    ('roman-gods', 'philyra', 'Philyra', 'Roman pantheon', 'f'),
    ('roman-gods', 'phlegyas', 'Phlegyas', 'Roman pantheon', 'm'),
    ('roman-gods', 'phoebe', 'Phoebe', 'Roman pantheon', 'f'),
    ('roman-gods', 'phylacus', 'Phylacus', 'Roman pantheon', 'm'),
    ('roman-gods', 'picumnus', 'Picumnus', 'Roman pantheon', 'm'),
    ('roman-gods', 'pleiades', 'Pleiades', 'Roman pantheon', 'm'),
    ('roman-gods', 'pluto', 'Pluto', 'Roman pantheon', 'm'),
    ('roman-gods', 'podalirius', 'Podalirius', 'Roman pantheon', 'm'),
    ('roman-gods', 'polus', 'Polus', 'Roman pantheon', 'm'),
    ('roman-gods', 'polydueces', 'Polydueces', 'Roman pantheon', 'm'),
    ('roman-gods', 'polyphemus', 'Polyphemus', 'Roman pantheon', 'm'),
    ('roman-gods', 'polyxo', 'Polyxo', 'Roman pantheon', 'f'),
    ('roman-gods', 'pomona', 'Pomona', 'Roman pantheon', 'f'),
    ('roman-gods', 'pontus', 'Pontus', 'Roman pantheon', 'm'),
    ('roman-gods', 'porus', 'Porus', 'Roman pantheon', 'm'),
    ('roman-gods', 'postvorta', 'Postvorta', 'Roman pantheon', 'm'),
    ('roman-gods', 'priam', 'Priam', 'Roman pantheon', 'm'),
    ('roman-gods', 'procas', 'Procas', 'Roman pantheon', 'm'),
    ('roman-gods', 'proclia', 'Proclia', 'Roman pantheon', 'f'),
    ('roman-gods', 'prometheus', 'Prometheus', 'Roman pantheon', 'm'),
    ('roman-gods', 'prometheus-2', 'Prometheus', 'Roman pantheon', 'm'),
    ('roman-gods', 'pronoia', 'Pronoia', 'Roman pantheon', 'f'),
    ('roman-gods', 'proserpina', 'Proserpina', 'Roman pantheon', 'f'),
    ('roman-gods', 'psyche', 'Psyche', 'Roman pantheon', 'f'),
    ('roman-gods', 'pyrrha', 'Pyrrha', 'Roman pantheon', 'f'),
    ('roman-gods', 'pyrrha-2', 'Pyrrha', 'Roman pantheon', 'f'),
    ('roman-gods', 'remus', 'Remus', 'Roman pantheon', 'm'),
    ('roman-gods', 'robigo', 'Robigo', 'Roman pantheon', 'f'),
    ('roman-gods', 'robigus', 'Robigus', 'Roman pantheon', 'm'),
    ('roman-gods', 'kings-of-rome', 'Kings of Rome', 'Roman pantheon', 'm'),
    ('roman-gods', 'romulus', 'Romulus', 'Roman pantheon', 'm'),
    ('roman-gods', 'salacia', 'Salacia', 'Roman pantheon', 'f'),
    ('roman-gods', 'salamis', 'Salamis', 'Roman pantheon', 'f'),
    ('roman-gods', 'salus', 'Salus', 'Roman pantheon', 'm'),
    ('roman-gods', 'sarpedon', 'Sarpedon', 'Roman pantheon', 'm'),
    ('roman-gods', 'saturn', 'Saturn', 'Roman pantheon', 'm'),
    ('roman-gods', 'rhea-silvia', 'Rhea Silvia', 'Roman pantheon', 'f'),
    ('roman-gods', 'silvius', 'Silvius', 'Roman pantheon', 'm'),
    ('roman-gods', 'silvius-2', 'Silvius', 'Roman pantheon', 'm'),
    ('roman-gods', 'aeneas-silvius', 'Aeneas Silvius', 'Roman pantheon', 'm'),
    ('roman-gods', 'latinus-silvius', 'Latinus Silvius', 'Roman pantheon', 'm'),
    ('roman-gods', 'romulus-silvius', 'Romulus Silvius', 'Roman pantheon', 'm'),
    ('roman-gods', 'tiberinus-silvius', 'Tiberinus Silvius', 'Roman pantheon', 'm'),
    ('roman-gods', 'sinon', 'Sinon', 'Roman pantheon', 'm'),
    ('roman-gods', 'sisyphus', 'Sisyphus', 'Roman pantheon', 'm'),
    ('roman-gods', 'sol', 'Sol', 'Roman pantheon', 'm'),
    ('roman-gods', 'somnus', 'Somnus', 'Roman pantheon', 'm'),
    ('roman-gods', 'sons', 'Sons', 'Roman pantheon', 'm'),
    ('roman-gods', 'statanus', 'Statanus', 'Roman pantheon', 'm'),
    ('roman-gods', 'statina', 'Statina', 'Roman pantheon', 'f'),
    ('roman-gods', 'stilbe', 'Stilbe', 'Roman pantheon', 'f'),
    ('roman-gods', 'stimula', 'Stimula', 'Roman pantheon', 'm'),
    ('roman-gods', 'strymo', 'Strymo', 'Roman pantheon', 'f'),
    ('roman-gods', 'symaethis', 'Symaethis', 'Roman pantheon', 'f'),
    ('roman-gods', 'telamon', 'Telamon', 'Roman pantheon', 'm'),
    ('roman-gods', 'telemachus', 'Telemachus', 'Roman pantheon', 'm'),
    ('roman-gods', 'telephus', 'Telephus', 'Roman pantheon', 'm'),
    ('roman-gods', 'telesphorus', 'Telesphorus', 'Roman pantheon', 'm'),
    ('roman-gods', 'tellus', 'Tellus', 'Roman pantheon', 'f'),
    ('roman-gods', 'tenes', 'Tenes', 'Roman pantheon', 'm'),
    ('roman-gods', 'tethys', 'Tethys)', 'Roman pantheon', 'm'),
    ('roman-gods', 'tethys-2', 'Tethys', 'Roman pantheon', 'f'),
    ('roman-gods', 'teucer', 'Teucer', 'Roman pantheon', 'm'),
    ('roman-gods', 'thea', 'Thea', 'Roman pantheon', 'f'),
    ('roman-gods', 'thestius', 'Thestius', 'Roman pantheon', 'm'),
    ('roman-gods', 'thetis', 'Thetis', 'Roman pantheon', 'f'),
    ('roman-gods', 'tiberinus', 'Tiberinus', 'Roman pantheon', 'm'),
    ('roman-gods', 'tiresias', 'Tiresias', 'Roman pantheon', 'm'),
    ('roman-gods', 'tithonus', 'Tithonus', 'Roman pantheon', 'm'),
    ('roman-gods', 'triton', 'Triton', 'Roman pantheon', 'm'),
    ('roman-gods', 'trivia', 'Trivia', 'Roman pantheon', 'm'),
    ('roman-gods', 'tros', 'Tros', 'Roman pantheon', 'm'),
    ('roman-gods', 'turnus', 'Turnus', 'Roman pantheon', 'm'),
    ('roman-gods', 'ulysses', 'Ulysses', 'Roman pantheon', 'm'),
    ('roman-gods', 'unknown', 'Unknown', 'Roman pantheon', 'm'),
    ('roman-gods', 'unknown-2', 'Unknown', 'Roman pantheon', 'm'),
    ('roman-gods', 'unknown-3', 'Unknown', 'Roman pantheon', 'm'),
    ('roman-gods', 'unknown-4', 'Unknown', 'Roman pantheon', 'm'),
    ('roman-gods', 'venus', 'Venus', 'Roman pantheon', 'f'),
    ('roman-gods', 'veritas', 'Veritas', 'Roman pantheon', 'f'),
    ('roman-gods', 'vertumnus', 'Vertumnus', 'Roman pantheon', 'm'),
    ('roman-gods', 'vesta', 'Vesta', 'Roman pantheon', 'f'),
    ('roman-gods', 'victoria', 'Victoria', 'Roman pantheon', 'f'),
    ('roman-gods', 'virbius', 'Virbius', 'Roman pantheon', 'm'),
    ('roman-gods', 'virtue', 'Virtue', 'Roman pantheon', 'm'),
    ('roman-gods', 'virtus', 'Virtus', 'Roman pantheon', 'm'),
    ('roman-gods', 'volupta', 'Volupta', 'Roman pantheon', 'f'),
    ('roman-gods', 'vulcan', 'Vulcan', 'Roman pantheon', 'm'),
    ('roman-gods', 'vulturnus', 'Vulturnus', 'Roman pantheon', 'm'),
    ('roman-gods', 'xuthus', 'Xuthus', 'Roman pantheon', 'm'),
    ('roman-gods', 'zelus', 'Zelus', 'Roman pantheon', 'm');

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
-- End of seed: 14 sagas.
-- =================================================================================================
COMMIT;
