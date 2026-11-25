// Seed generator: writes db/seed.sql (portable PostgreSQL/SQLite) from public/data/*.json, matching db/schema.sql.
//
// What it does: one transaction, sagas in sagas.json order, rows inserted parents-before-children so foreign keys
// hold at every statement. Each saga is deleted first (ON DELETE CASCADE clears its rows), so the file is re-runnable.
// Layout: a boxed banner per saga, a sub-section per table, people grouped by house, one INSERT per family.
// Usage: npm run db:seed (OVERWRITES db/seed.sql; commit it with data changes). npm run db:seed -- --check compares
//   instead and exits 1 without writing if db/seed.sql is out of date; npm test runs it that way.
// Notes: output is deterministic, so --check is a plain string compare (CRLF-normalised). seed-sql.test.mts loads the
// result into SQLite. Reads only through data.mts; writes only db/seed.sql.

import fs from "node:fs";
import { readIndex, readSaga } from "./data.mts";

// SQL string literal: single quotes doubled (O'Brien → 'O''Brien'). Data is plain text, so this is sufficient.
const q = (s: string) => `'${s.replace(/'/g, "''")}'`;
const bool = (b: boolean) => (b ? "TRUE" : "FALSE");
// Comments can't contain a line break, and "*/" never matters for "--" comments; collapse whitespace to be safe.
const c = (s: string) => s.replace(/\s+/g, " ").trim();

// Multi-row INSERT, one row per line; returns [] for an empty table so no invalid "VALUES ;" is emitted.
function insert(table: string, cols: string[], rows: string[][]): string[] {
    if (!rows.length) return [];
    const values = rows.map((r, i) => `    (${r.join(", ")})${i === rows.length - 1 ? ";" : ","}`);
    return [`INSERT INTO ${table} (${cols.join(", ")}) VALUES`, ...values];
}

const WIDTH = 100;
const rule = (ch: string) => `-- ${ch.repeat(WIDTH - 3)}`;
// Boxed banner: the heading line of each saga, easy to spot when scrolling or folding.
function banner(lines: string[]): string[] {
    const inner = WIDTH - 6;
    const wrap = (s: string): string[] => {
        const out: string[] = [];
        let cur = "";
        for (const word of s.split(" ")) {
            if (cur && (cur + " " + word).length > inner) (out.push(cur), (cur = word));
            else cur = cur ? `${cur} ${word}` : word;
        }
        return [...out, cur];
    };
    return [rule("="), ...lines.flatMap(wrap).map((l) => `-- ${l}`), rule("=")];
}
// Sub-section heading for one table within a saga.
const section = (title: string, detail = "") => [
    "",
    `-- ── ${title}${detail ? ` (${detail})` : ""} ${"─".repeat(Math.max(3, WIDTH - 9 - title.length - (detail ? detail.length + 3 : 0)))}`,
];

const index = readIndex();
const sagas = index.map((e) => readSaga(e));
const totals = {
    people: sagas.reduce((n, s) => n + s.people.length, 0),
    families: sagas.reduce((n, s) => n + s.families.length, 0),
    members: sagas.reduce((n, s) => n + s.members.length, 0),
};

const out: string[] = [
    ...banner([
        "Family Tree: database seed",
        "Generated from public/data/*.json by scripts/seed-sql.mts. Do not edit: run `npm run db:seed`.",
        `Contents: ${sagas.length} sagas, ${totals.people} people, ${totals.families} families, ${totals.members} family-member rows.`,
    ]),
    "--",
    "-- Load after db/schema.sql:",
    "--   PostgreSQL: psql -d family_tree -f db/schema.sql -f db/seed.sql",
    '--   SQLite:     sqlite3 family_tree.db "PRAGMA foreign_keys = ON;" ".read db/schema.sql" ".read db/seed.sql"',
    "--",
    "-- Each saga is one section: it is deleted first (cascading to all its rows), then re-inserted in dependency",
    "-- order (saga, notes, houses, people, families with their members), so the file can be re-run safely.",
    "--",
    "-- Sagas, in drop-down order:",
    ...sagas.map(
        (s, i) => `--   ${String(i + 1).padStart(2)}. ${s.title.padEnd(24)} ${index[i].category.padEnd(9)} ${s.id}`
    ),
    "",
    "BEGIN;",
];

sagas.forEach((s, position) => {
    const id = q(s.id);
    const src = s.source;
    const category = index[position].category; // from the manifest: it's also the data sub-folder
    const name = (pid: string) => s.people.find((p) => p.id === pid)?.name ?? pid;

    out.push(
        "",
        "",
        ...banner([
            `SAGA ${position + 1} of ${sagas.length}: ${s.title.toUpperCase()}   [id: ${s.id}, category: ${category}]`,
            `Author:  ${src.author}`,
            `Medium:  ${src.medium}`,
            `Canon:   ${src.canon}`,
            `Covers:  ${src.covers}`,
            `Rows:    ${s.houses.length} houses, ${s.people.length} people, ${s.families.length} families, ${s.members.length} members`,
        ])
    );

    out.push(...section("Reset", "removes this saga and, by cascade, all of its rows"));
    out.push(`DELETE FROM saga WHERE id = ${id};`);

    out.push(...section("Saga"));
    out.push(
        ...insert(
            "saga",
            ["id", "category", "position", "title", "work", "medium", "author", "canon", "genre", "covers"],
            [
                [
                    id,
                    q(category),
                    String(position),
                    q(s.title),
                    q(src.work),
                    q(src.medium),
                    q(src.author),
                    q(src.canon),
                    q(src.genre),
                    q(src.covers),
                ],
            ]
        )
    );

    if (s.notes.length) {
        out.push(...section("Notes", "modelling choices and where sources disagree"));
        out.push(
            ...insert(
                "saga_note",
                ["saga_id", "position", "note"],
                s.notes.map((n, i) => [id, String(i), q(n)])
            )
        );
    }

    out.push(...section("Houses", `${s.houses.length}`));
    out.push(
        ...insert(
            "house",
            ["saga_id", "name", "color"],
            s.houses.map((h) => [id, q(h.name), q(h.color)])
        )
    );

    // People, grouped by house in house order, each group with its own heading comment.
    out.push(...section("People", `${s.people.length}, grouped by house`));
    const cols = ["saga_id", "id", "name", "house", "sex", "born"];
    for (const h of s.houses) {
        const members = s.people.filter((p) => p.house === h.name);
        if (!members.length) continue;
        out.push(`-- ${h.name} (${members.length})`);
        out.push(
            ...insert(
                "person",
                cols,
                members.map((p) => [id, q(p.id), q(p.name), q(p.house), q(p.sex), p.born ? q(p.born) : "NULL"])
            )
        );
    }

    // Families: one block each, headed by a readable summary, family row then its member rows.
    out.push(...section("Families", `${s.families.length}, each followed by its members`));
    for (const f of s.families) {
        const rows = s.members.filter((m) => m.family === f.id);
        const parents = rows.filter((m) => m.role === "parent").map((m) => name(m.person));
        const kids = rows.filter((m) => m.role === "child").map((m) => name(m.person));
        const who = parents.length ? parents.join(" + ") : "(parents unknown)";
        const summary = kids.length ? `${who} → ${kids.join(", ")}` : `${who} (no children)`;
        out.push(`-- ${f.id}: ${c(summary)}${f.adoptive ? "   [adoptive]" : ""}`);
        out.push(...insert("family", ["saga_id", "id", "adoptive"], [[id, q(f.id), bool(f.adoptive)]]));
        out.push(
            ...insert(
                "family_member",
                ["saga_id", "family_id", "person_id", "role"],
                rows.map((m) => [id, q(m.family), q(m.person), q(m.role)])
            )
        );
    }
});

out.push("", "", rule("="), `-- End of seed: ${sagas.length} sagas.`, rule("="), "COMMIT;", "");

const sql = out.join("\n");
const target = new URL("../db/seed.sql", import.meta.url);
// --check: fail if db/seed.sql is out of date with the JSON (used by npm test), without rewriting it.
if (process.argv.includes("--check")) {
    const current = fs.existsSync(target) ? fs.readFileSync(target, "utf8").replace(/\r\n/g, "\n") : "";
    if (current !== sql) {
        console.error("db/seed.sql is out of date with public/data: run `npm run db:seed`");
        process.exit(1);
    }
    console.log("ok  db/seed.sql is up to date with public/data");
} else {
    fs.writeFileSync(target, sql);
    console.log(
        `wrote db/seed.sql: ${sagas.length} sagas, ${totals.people} people, ${totals.families} families, ${totals.members} members`
    );
}
