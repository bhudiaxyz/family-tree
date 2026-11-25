// Test for src/data/gedcom.ts: the in-app GEDCOM import (parseGedcom).
//
// Covers: formats real exporters produce (5.5.1 with CRLF and BOM, and 7), adoption markers, and messy input; the
//   parsed trees are also run through generations() and relate().
// Data: small synthetic GEDCOM strings written in the file, no saga files.
// Run alone: node --experimental-strip-types --no-warnings scripts/gedcom.test.mts
// Notes: no ratchets or allow-lists. Display-name rules for stored imports live in gedcom-names.test.mts.

import assert from "node:assert/strict";
import { parseGedcom } from "../src/data/gedcom.ts";
import { generations } from "../src/tree/generations.ts";
import { relate } from "../src/tree/relationship.ts";

// A small three-generation family in GEDCOM 5.5.1, with CRLF line endings and a BOM as many exporters write it.
const ged551 = [
    "﻿0 HEAD",
    "1 GEDC",
    "2 VERS 5.5.1",
    "1 CHAR UTF-8",
    "0 @I1@ INDI",
    "1 NAME Arthur /Weasley/",
    "1 SEX M",
    "1 FAMS @F1@",
    "0 @I2@ INDI",
    "1 NAME Molly /Prewett/",
    "1 SEX F",
    "1 FAMS @F1@",
    "0 @I3@ INDI",
    "1 NAME Ron /Weasley/",
    "1 SEX M",
    "1 FAMC @F1@",
    "1 FAMS @F2@",
    "0 @I4@ INDI",
    "1 NAME Ginny /Weasley/",
    "1 SEX F",
    "1 FAMC @F1@",
    "0 @I5@ INDI",
    "1 NAME Hermione /Granger/",
    "1 SEX F",
    "1 FAMS @F2@",
    "0 @I6@ INDI",
    "1 NAME Rose /Weasley/",
    "1 SEX F",
    "1 FAMC @F2@",
    "0 @F1@ FAM",
    "1 HUSB @I1@",
    "1 WIFE @I2@",
    "1 CHIL @I3@",
    "1 CHIL @I4@",
    "0 @F2@ FAM",
    "1 HUSB @I3@",
    "1 WIFE @I5@",
    "1 CHIL @I6@",
    "0 TRLR",
].join("\r\n");

const { tree, warnings } = parseGedcom(ged551, "Weasleys");
assert.deepEqual(warnings, []);
assert.equal(Object.keys(tree.people).length, 6);
assert.deepEqual(tree.people.I1, { name: "Arthur Weasley", house: "Weasley", sex: "m" });
assert.deepEqual(tree.people.I2, { name: "Molly Prewett", house: "Prewett", sex: "f" });
assert.equal(tree.families.length, 2);
assert.deepEqual(tree.families[0], { parents: ["I1", "I2"], children: ["I3", "I4"] });
assert.deepEqual(Object.keys(tree.houseColors).sort(), ["Granger", "Prewett", "Weasley"]);
// The imported tree works with the rest of the app's logic.
assert.equal(relate(tree, "I6", "I1")?.label, "granddaughter");
assert.equal(relate(tree, "I6", "I4")?.label, "niece");
assert.equal(generations(tree).get("I6"), 2);

// Adoption: PEDI on the family's CHIL link (5.5.1), and Ancestry/FTM _FREL/_MREL tags.
const adopt = parseGedcom(
    [
        "0 @I1@ INDI",
        "1 NAME Owen /Lars/",
        "1 SEX M",
        "0 @I2@ INDI",
        "1 NAME Beru /Whitesun/",
        "1 SEX F",
        "0 @I3@ INDI",
        "1 NAME Luke /Skywalker/",
        "1 SEX M",
        "0 @I4@ INDI",
        "1 NAME Bail /Organa/",
        "1 SEX M",
        "0 @I5@ INDI",
        "1 NAME Leia /Organa/",
        "1 SEX F",
        "0 @F1@ FAM",
        "1 HUSB @I1@",
        "1 WIFE @I2@",
        "1 CHIL @I3@",
        "2 PEDI adopted",
        "0 @F2@ FAM",
        "1 HUSB @I4@",
        "1 CHIL @I5@",
        "2 _FREL Adopted",
    ].join("\n")
).tree;
assert.deepEqual(
    adopt.families.map((f) => [f.parents, f.children, !!f.adoptive]),
    [
        [["I1", "I2"], ["I3"], true],
        [["I4"], ["I5"], true],
    ]
);
assert.equal(relate(adopt, "I3", "I1")?.summary, "Luke Skywalker is the son of Owen Lars (by adoption).");

// PEDI on the individual's FAMC link instead (also valid GEDCOM): birth family kept, adoptive one split out.
const famc = parseGedcom(
    [
        "0 @I1@ INDI",
        "1 NAME Tam /al'Thor/",
        "1 SEX M",
        "0 @I2@ INDI",
        "1 NAME Rand /al'Thor/",
        "1 SEX M",
        "1 FAMC @F1@",
        "2 PEDI adopted",
        "0 @I3@ INDI",
        "1 NAME Kari /al'Thor/",
        "1 SEX F",
        "0 @F1@ FAM",
        "1 HUSB @I1@",
        "1 WIFE @I3@",
        "1 CHIL @I2@",
    ].join("\n")
).tree;
assert.deepEqual(
    famc.families.map((f) => [f.parents, f.children, !!f.adoptive]),
    [[["I1", "I3"], ["I2"], true]],
    "the now-empty birth entry is dropped, the adoption kept"
);

// GEDCOM 7 style and messy input: lower-case tags, extra whitespace, a name without slashes, unknown sex,
// a pointer to a missing person, and a malformed line.
const messy = parseGedcom(
    [
        "0 HEAD",
        "1 GEDC",
        "2 VERS 7.0",
        "0 @A@ INDI",
        "  1 name   Gandalf",
        "1 SEX U",
        "0 @B@ INDI",
        "1 NAME  Frodo  /Baggins/ ",
        "1 SEX M",
        "this line is not gedcom",
        "0 @F@ FAM",
        "1 HUSB @A@",
        "1 CHIL @B@",
        "1 CHIL @MISSING@",
    ].join("\n")
);
assert.equal(messy.tree.people.A.name, "Gandalf");
assert.equal(messy.tree.people.A.house, "Unknown");
assert.equal(messy.tree.people.B.name, "Frodo Baggins");
assert.deepEqual(messy.tree.families, [{ parents: ["A"], children: ["B"] }]);
assert.equal(messy.warnings.length, 2, "unknown sex, and the CHIL pointing to a missing person");
assert.ok(messy.warnings.some((w) => w.includes("Gandalf") && w.includes("sex")));

// Not GEDCOM at all.
assert.throws(() => parseGedcom("hello world"), /No individuals/);

console.log("ok  GEDCOM import: 5.5.1, GEDCOM 7, adoption (PEDI, _FREL, FAMC), messy input, works with app logic");

// A large file: every surname still gets a colour of its own, past the palette's list (golden-angle hues after it).
{
    const n = 60;
    const lines = ["0 HEAD", "1 GEDC", "2 VERS 5.5.1"];
    for (let i = 0; i < n; i++)
        lines.push(`0 @I${i}@ INDI`, `1 NAME Person /Surname${String(i).padStart(2, "0")}/`, "1 SEX M");
    lines.push("0 TRLR");
    const { tree } = parseGedcom(lines.join("\n"));
    const colours = Object.values(tree.houseColors);
    assert.equal(colours.length, n, `${n} houses`);
    assert.equal(new Set(colours).size, n, "no two houses share a colour");
    console.log(`ok  GEDCOM import: ${n} surnames, ${new Set(colours).size} distinct house colours`);
}

// Birth dates as YYYY-MM-DD (00 for an unknown part): old/new style years, qualifiers and partial dates.
{
    const { isoDate } = await import("../src/data/gedcom.ts");
    const cases: [string, string | null][] = [
        ["28 Jan 1456/1457", "1457-01-28"],
        ["11 Feb 1465", "1465-02-11"],
        ["ABT 1430", "1430-00-00"],
        ["BET 1430 AND 1435", "1430-00-00"],
        ["JAN 1500", "1500-01-00"],
        ["1456/57", "1457-00-00"],
        ["0925", "0925-00-00"],
        ["UNKNOWN", null],
    ];
    for (const [d, want] of cases) assert.equal(isoDate(d), want, d);
    const { tree } = parseGedcom("0 HEAD\n0 @I1@ INDI\n1 NAME A /B/\n1 CHR\n2 DATE 3 MAR 1600\n0 TRLR");
    assert.equal(tree.people.I1.born, "1600-03-03", "christening date when there's no birth");
    console.log("ok  GEDCOM import: birth dates as YYYY-MM-DD (old/new style, qualifiers, partial, christening)");
}
