// Shared data access for scripts and tests: read the manifest and saga files the same way the app does, through
// sagaPath() in src/data/schema.ts, so the scripts can never disagree with the loader about where files live.
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
