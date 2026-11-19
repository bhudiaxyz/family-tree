// Shared data access for scripts and tests: reads the manifest and saga files the way the app does.
//
// What it does: exports dataDir (public/data/), readIndex(), readSagaFile(), readSaga() and treeById(), all built on
// readManifest(), sagaPath(), expandSaga() and toTree() from src/, so scripts never disagree with the loader on layout.
// Usage: imported by seed-sql.mts and most *.test.mts; not run directly.
// Notes: read-only (it never writes). Files are located only via sagaPath(), so a change to the data layout is made in
// src/data/schema.ts, not here. treeById() throws for an id missing from sagas.json.

import fs from "node:fs";
import {
    expandSaga,
    readManifest,
    type SagaFile,
    type SagaIndexEntry,
    type SagaManifest,
    type SagaRecord,
    sagaPath,
    type Tree,
} from "../src/data/schema.ts";
import { toTree } from "../src/data/source.ts";

/** The data directory (public/data/), as a file URL. */
export const dataDir = new URL("../public/data/", import.meta.url);

const readJson = <T,>(relative: string): T => JSON.parse(fs.readFileSync(new URL(relative, dataDir), "utf8"));

/** The manifest, sagas.json (saga id → category), as entries in menu order, checked as the app checks it. */
export const readIndex = (): SagaIndexEntry[] => readManifest(readJson<SagaManifest>("sagas.json"));

/** One saga's data file as written, from <category>/<id>.json. */
export const readSagaFile = (entry: SagaIndexEntry): SagaFile => readJson<SagaFile>(sagaPath(entry));

/** One saga, expanded into its normalised record (the database tables). */
export const readSaga = (entry: SagaIndexEntry): SagaRecord => expandSaga(readSagaFile(entry));

/** A saga as the app sees it (a Tree), looked up by id in the manifest. */
export function treeById(id: string): Tree {
    const entry = readIndex().find((s) => s.id === id);
    if (!entry) throw new Error(`no saga "${id}" in sagas.json`);
    return toTree(readSaga(entry));
}
