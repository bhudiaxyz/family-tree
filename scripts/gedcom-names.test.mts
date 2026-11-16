// Display-name rules against the real NAME patterns in the imported sample files (Tudors, Greek, Norse, Roman gods).
import assert from "node:assert/strict";
import { displayName } from "./gedcom-names.mts";

const person = (raw: string, sex: "m" | "f" = "m", titles: string[] = []) => displayName(raw, "person", sex, titles);
const myth = (raw: string, sex: "m" | "f" = "m") => displayName(raw, "mythology", sex);

// People (English Tudor Royal Family).
assert.equal(person("Henry /Tudor/"), "Henry Tudor");
assert.equal(person("Henry /Tudor/", "m", ["Duke of Cornwall", "King Henry VIII"]), "Henry VIII");
assert.equal(person("Ferdinand /Trastámara/", "m", ["King Ferdinand V of Castile and Aragon"]), "Ferdinand V");
assert.equal(person("Mary /Tudor/", "f", ["Queen Mary I"]), "Mary I");
assert.equal(person("Katherine /Parr/", "f", ["Queen Consort"]), "Katherine Parr", "a role is not a regnal name");
assert.equal(person("Edmund /Tudor/", "m", ["Knight", "Earl of Richmond"]), "Edmund Tudor", "peerage titles stay out");
assert.equal(person("... /Tudor/", "m"), "(unnamed son) Tudor");
assert.equal(person("... /Stewart/", "f"), "(unnamed daughter) Stewart");
assert.equal(person("John de la /Pole/"), "John de la Pole");

// Greek: the deity is the /…/ part; descriptive given text is dropped.
assert.equal(myth("queen of the Gods /Hera/", "f"), "Hera");
assert.equal(myth("The war god /Ares/"), "Ares");
assert.equal(myth("of Greek Mythology /Eros/"), "Eros");
assert.equal(myth("goddess of youth /Hebe/", "f"), "Hebe");
assert.equal(myth("/Gaea/", "f"), "Gaea");

// Norse: brackets, an empty surname, placeholder surnames, and a genuine two-part name.
// Sif (Thor's wife); the file's ALIA line reads "Sif Sibil", Sibil being a Latinised form. Both names are kept.
assert.equal(myth("Sibil /(Sif)/", "f"), "Sibil Sif");
assert.equal(myth("Sibil //", "f"), "Sibil");
assert.equal(myth("A /Giantess/", "f"), "A Giantess");
assert.equal(myth("Rich /Girl/", "f"), "Rich Girl");
assert.equal(myth("Hati /Hródvitnisson/"), "Hati Hródvitnisson");
assert.equal(myth("/Auðumbla/", "f"), "Auðumbla");
assert.equal(myth("Giant Teacher of Odin of Nine Magic /Charms/"), "Giant Teacher of Odin of Nine Magic Charms");

// Roman: a descriptive "a god", "of Troy", real two-part names, suffixes, and an empty name.
assert.equal(myth("a god /Jupiter/"), "Jupiter");
assert.equal(myth("of Troy /Helen/", "f"), "Helen");
assert.equal(myth("Acca /Larentia/", "f"), "Acca Larentia");
assert.equal(myth("The /Lares/"), "The Lares");
assert.equal(myth("/Lares/ II"), "Lares II");
assert.equal(myth("/Pandion/ II"), "Pandion II");
assert.equal(myth("//", "f"), "(unnamed daughter)");
assert.equal(myth("Brutus of /Britain/"), "Brutus of Britain");

console.log("ok  GEDCOM display names: people, regnal names, unnamed placeholders, Greek/Norse/Roman mythology");

// Capitalised descriptions vs real two-part names (Greek/Roman files).
assert.equal(myth("Trojan Hero /Aeneas/"), "Aeneas");
assert.equal(myth("King of Sparta /Menelaus/"), "Menelaus");
assert.equal(myth("King of the Myrmidans /Peleus/"), "Peleus");
assert.equal(myth("Theban Princess /Megara/", "f"), "Megara");
assert.equal(myth("Cyclops /Polyphemus/"), "Polyphemus");
assert.equal(myth("Greek and Roman Mythology /Polydueces/"), "Polydueces");
assert.equal(myth("Numa /Pompilius/"), "Numa Pompilius");
assert.equal(myth("Rhea /Silvia/", "f"), "Rhea Silvia");
assert.equal(myth("Ascanius /Iulus/"), "Ascanius Iulus");
assert.equal(myth("Silvius /Aeneas/"), "Silvius Aeneas");
console.log("ok  GEDCOM display names: capitalised descriptions dropped, real two-part names kept");

// Descriptions the compiler wrote in place of a name are kept whole (the real name isn't in the file).
assert.equal(myth("Gilling's /Wife/", "f"), "Gilling's Wife");
assert.equal(myth("Several /Sons/"), "Several Sons");
console.log("ok  GEDCOM display names: placeholder descriptions kept whole");
