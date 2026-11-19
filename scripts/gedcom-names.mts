// GEDCOM display-name rules: turns a raw NAME ("Given /Surname/ Suffix") into the name a saga shows. Pure functions.
//
// What it does: two modes. person (default): "Henry /Tudor/" -> "Henry Tudor", monarchs by regnal name (from TITL),
//   e.g. "Henry VIII". mythology: the deity's name is in the SURNAME slot ("queen of the Gods /Hera/", "The war god
//   /Ares/", "of Greek Mythology /Eros/"); a descriptive given part (lower-case, or starting The/A/An/Of) is dropped,
//   a real given name ("Acca /Larentia/", "Hati /Hródvitnisson/") is kept.
// Usage: imported by gedcom-to-saga.mts; checked by gedcom-names.test.mts against real patterns in the sample files.
// Notes: no I/O. The heuristics (DESCRIPTIVE, ROLE_WORD, REGNAL) were tuned on the Tudor, Greek, Norse and Roman files:
//   change them only with a matching case in the test.

/** Placeholders genealogies use for an unrecorded given name: "... /Tudor/", "?", "_", "Unknown", "NN". */
const UNNAMED = /^(?:\.{2,}|…|\?+|_+|-+|unknown|unk|nn|n\.?n\.?)$/i;

/** King/Queen + a name + a Roman numeral ("King Ferdinand V of Castile and Aragon"); "Queen Consort" doesn't match. */
const REGNAL = /^(?:King|Queen)\s+([A-Z][\w'-]*(?:\s+[A-Z][\w'-]*)?)\s+([IVXLC]+)\b/;

/**
 * A descriptive given part in mythology files: "queen of the Gods", "The war god", "a god", "of Greek Mythology".
 * Two signals: it starts lower-case (startsLower), or it starts with an article/preposition word. The word test is
 * case-insensitive but deliberately has NO single-letter class: an earlier /^(?:[a-z]|…)/i matched every letter
 * under the i flag, so real given names ("Acca /Larentia/", "Hati /Hródvitnisson/") were dropped too.
 */
const DESCRIPTIVE = /^(?:the|a|an|of)\b/i;
/**
 * Capitalised descriptions also occur ("Trojan Hero /Aeneas/", "King of Sparta /Menelaus/", "Cyclops /Polyphemus/").
 * What separates them from real two-part names ("Numa /Pompilius/", "Rhea /Silvia/", "Ascanius /Iulus/"): a real given
 * name is one word, so a given part of two or more words is a description; a single word is a description only if it
 * is a role or kind of being.
 */
const ROLE_WORD =
    /^(?:King|Queen|Prince|Princess|Lord|Lady|Hero|Heroine|God|Goddess|Titan|Titaness|Giant|Giantess|Nymph|Cyclops|Monster|Mortal|Demigod|Hunter|Seer|Priestess|Muse)$/;
const isDescription = (given: string) =>
    DESCRIPTIVE.test(given) ||
    startsLower(given) ||
    given.trim().split(/\s+/).length >= 2 ||
    ROLE_WORD.test(given.trim());
const startsLower = (s: string) => /^\p{Ll}/u.test(s);

/** Split a GEDCOM NAME value into its parts. Values without slashes are all "given". */
export function splitName(raw: string): { given: string; surname: string; suffix: string } {
    const m = /^(.*?)\s*\/(.*?)\/\s*(.*)$/.exec(raw.trim());
    if (!m) return { given: raw.trim(), surname: "", suffix: "" };
    return { given: m[1].trim(), surname: m[2].trim(), suffix: m[3].trim() };
}

export type NameMode = "person" | "mythology";

/**
 * The clean display name for a GEDCOM NAME. `titles` are the person's own TITL values (from their INDI record only).
 * `sex` picks the wording for an unnamed person. Never returns punctuation-only placeholders.
 */
export function displayName(raw: string, mode: NameMode, sex: "m" | "f", titles: string[] = []): string {
    for (const t of titles) {
        const m = REGNAL.exec(t);
        if (m) return `${m[1]} ${m[2]}`;
    }
    const unnamed = sex === "f" ? "(unnamed daughter)" : "(unnamed son)";
    let { given, surname, suffix } = splitName(raw);
    // Brackets mark an alternative form, e.g. "Sibil /(Sif)/": keep the inner name without brackets.
    surname = surname.replace(/^\((.*)\)$/, "$1").trim();
    given = given.replace(/^\((.*)\)$/, "$1").trim();
    const withSuffix = (s: string) => (suffix ? `${s} ${suffix}` : s);

    if (mode === "mythology") {
        // Placeholder surnames ("A /Giantess/", "Rich /Girl/", "The /Lares/"): the surname slot holds a generic noun, so
        // the whole thing is the name; keep it as written. These capitalise the given part. A lower-case article
        // ("a god /Jupiter/") is instead a description in front of a real name, handled below. That case is the only
        // thing telling the two shapes apart in these files.
        if (surname && given && /^(?:A|An|The|Rich|Poor|Old|Young)\b/.test(given) && given.split(/\s+/).length <= 2)
            return withSuffix(`${given} ${surname}`);
        if (surname) {
            // When the given part ends in "of"/"of the" (or a possessive), the surname finishes the phrase rather than
            // naming anyone: "Giant Teacher of Odin of Nine Magic /Charms/" is a description of Bölþorn, whose name
            // the file omits. Dropping the prefix would leave "Charms", so keep the compiler's whole description.
            if (/(?:\bof(?:\s+the)?|'s)\s*$/i.test(given) || /\bof\b.*\bof\b/i.test(given))
                return withSuffix(`${given} ${surname}`);
            // A descriptive given part is dropped; a real given name (one capitalised, non-role word) is kept.
            const keepGiven = given && !isDescription(given);
            return withSuffix(keepGiven ? `${given} ${surname}` : surname);
        }
        if (given) return withSuffix(given); // "Sibil //"
        return unnamed;
    }

    // person mode
    if (UNNAMED.test(given)) return surname ? `${unnamed} ${surname}` : unnamed;
    const full = [given, surname].filter(Boolean).join(" ");
    return full ? withSuffix(full) : unnamed;
}
