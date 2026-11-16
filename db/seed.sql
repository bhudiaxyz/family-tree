-- =================================================================================================
-- Family Tree: database seed
-- Generated from public/data/*.json by scripts/seed-sql.mts. Do not edit: run `npm run db:seed`.
-- Contents: 10 sagas, 296 people, 126 families, 421 family-member rows.
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

BEGIN;


-- =================================================================================================
-- SAGA 1 of 10: GAME OF THRONES   [id: got, category: fiction]
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
-- SAGA 2 of 10: FIRE & BLOOD   [id: fireblood, category: fiction]
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
-- SAGA 3 of 10: THE LORD OF THE RINGS   [id: lotr, category: fiction]
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
-- SAGA 4 of 10: THE SILMARILLION   [id: silmarillion, category: fiction]
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
-- SAGA 5 of 10: DUNE   [id: dune, category: fiction]
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
-- SAGA 6 of 10: HARRY POTTER   [id: potter, category: fiction]
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
-- SAGA 7 of 10: STAR WARS   [id: starwars, category: fiction]
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
-- SAGA 8 of 10: THE WHEEL OF TIME   [id: wot, category: fiction]
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
-- SAGA 9 of 10: THE STORMLIGHT ARCHIVE   [id: stormlight, category: fiction]
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
-- SAGA 10 of 10: THE WITCHER   [id: witcher, category: fiction]
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
-- End of seed: 10 sagas.
-- =================================================================================================
COMMIT;
