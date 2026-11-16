-- Relational schema for saga data. Mirrors src/data/schema.ts (SagaRecord) table for table.
-- Portable SQL (PostgreSQL / SQLite). An API serving /sagas.json and /<category>/<id>.json from these tables
-- can replace the static files: set VITE_DATA_URL to its base URL.

CREATE TABLE saga (
    id       TEXT PRIMARY KEY,
    -- Kind of family; also the data sub-folder (<category>/<id>.json). Keep in step with CATEGORIES in
    -- src/data/schema.ts when adding a category.
    category TEXT NOT NULL CHECK (category IN ('fiction', 'history')),
    position INTEGER NOT NULL UNIQUE,  -- drop-down order (sagas.json order); lowest loads first
    title    TEXT NOT NULL,
    work    TEXT NOT NULL,
    medium  TEXT NOT NULL,
    author  TEXT NOT NULL,
    canon   TEXT NOT NULL,
    genre   TEXT NOT NULL,
    covers  TEXT NOT NULL
);

CREATE TABLE saga_note (
    saga_id  TEXT NOT NULL REFERENCES saga(id) ON DELETE CASCADE,
    position INTEGER NOT NULL,
    note     TEXT NOT NULL,
    PRIMARY KEY (saga_id, position)
);

CREATE TABLE house (
    saga_id TEXT NOT NULL REFERENCES saga(id) ON DELETE CASCADE,
    name    TEXT NOT NULL,
    color   TEXT NOT NULL,
    PRIMARY KEY (saga_id, name)
);

-- Person ids are unique within a saga (the same character can appear in several sagas).
CREATE TABLE person (
    saga_id TEXT NOT NULL,
    id      TEXT NOT NULL,
    name    TEXT NOT NULL,
    house   TEXT NOT NULL,
    sex     TEXT NOT NULL CHECK (sex IN ('m', 'f')),
    PRIMARY KEY (saga_id, id),
    FOREIGN KEY (saga_id) REFERENCES saga(id) ON DELETE CASCADE,
    FOREIGN KEY (saga_id, house) REFERENCES house(saga_id, name)
);

CREATE TABLE family (
    saga_id  TEXT NOT NULL REFERENCES saga(id) ON DELETE CASCADE,
    id       TEXT NOT NULL,
    adoptive BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (saga_id, id)
);

CREATE TABLE family_member (
    saga_id   TEXT NOT NULL,
    family_id TEXT NOT NULL,
    person_id TEXT NOT NULL,
    role      TEXT NOT NULL CHECK (role IN ('parent', 'child')),
    PRIMARY KEY (saga_id, family_id, person_id, role),
    FOREIGN KEY (saga_id, family_id) REFERENCES family(saga_id, id) ON DELETE CASCADE,
    FOREIGN KEY (saga_id, person_id) REFERENCES person(saga_id, id) ON DELETE CASCADE
);
