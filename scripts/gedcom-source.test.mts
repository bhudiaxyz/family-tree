// Test for scripts/gedcom-source.mts: URL handling for the GEDCOM importer, offline.
//
// Covers: GitHub page links rewritten to raw URLs (path kept encoded), other hosts used as given, only https accepted,
//   and decoded source names. Data: URL strings only; no network access and no files.
// Run alone: node --experimental-strip-types --no-warnings scripts/gedcom-source.test.mts
// Notes: no ratchets or allow-lists. readSource() (the actual download) is deliberately not tested here.

import assert from "node:assert/strict";
import { downloadUrl, isUrl, sourceName } from "./gedcom-source.mts";

const page =
    "https://github.com/D-Jeffrey/gedcom-samples/blob/main/famous%20family%20trees/religious%20figures%20and%20systems/Babylonian%2BGods.ged";

// A GitHub page link is fetched as the raw file; the path stays encoded exactly as given.
assert.equal(
    downloadUrl(page).href,
    "https://raw.githubusercontent.com/D-Jeffrey/gedcom-samples/main/famous%20family%20trees/religious%20figures%20and%20systems/Babylonian%2BGods.ged"
);
assert.equal(
    downloadUrl("https://github.com/o/r/raw/main/a.ged").href,
    "https://raw.githubusercontent.com/o/r/main/a.ged"
);
// Raw links and other hosts are used as given.
const raw = "https://raw.githubusercontent.com/o/r/main/a.ged";
assert.equal(downloadUrl(raw).href, raw);
assert.equal(downloadUrl("https://example.org/trees/family.ged").href, "https://example.org/trees/family.ged");
// Only https: no plain http, no file:// or other schemes.
assert.throws(() => downloadUrl("http://example.org/a.ged"), /only https/);
assert.throws(() => downloadUrl("file:///etc/passwd"), /only https/);

// The file's readable name, for the saga's notes.
assert.equal(sourceName(page), "Babylonian+Gods.ged");
assert.equal(sourceName("C:/samples/Greek+Gods.ged"), "Greek+Gods.ged");
assert.ok(isUrl(page) && !isUrl("C:/samples/Greek+Gods.ged") && !isUrl("Greek+Gods.ged"));

console.log("ok  GEDCOM import source: GitHub links → raw files, https only, readable file names");
