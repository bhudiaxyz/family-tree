// Where the importer reads a GEDCOM file from: a local path, or an https:// URL. GitHub page links
// (github.com/<owner>/<repo>/blob/<ref>/<path>) are turned into their raw file URL, so the address from the browser
// works as is. Downloads are capped in size and time; the bytes are only ever parsed (see gedcom-to-saga.mts).
import fs from "node:fs";
import path from "node:path";

/** Largest file accepted, local or downloaded: the in-app import has the same 20 MB limit (ui/files.ts). */
export const MAX_BYTES = 20 * 1024 * 1024;
const TIMEOUT_MS = 30_000;

export const isUrl = (s: string) => /^[a-z][a-z0-9+.-]*:\/\//i.test(s);

/**
 * The URL to download for `input`: a GitHub "blob" page becomes raw.githubusercontent.com; any other https URL is
 * used as given. Throws for anything that isn't https, so a typo can't fetch over plain http or a file:// path.
 */
export function downloadUrl(input: string): URL {
    const url = new URL(input);
    if (url.protocol !== "https:") throw new Error(`only https:// URLs can be imported, not ${url.protocol}//`);
    const blob = url.hostname === "github.com" && /^\/([^/]+)\/([^/]+)\/(?:blob|raw)\/(.+)$/.exec(url.pathname);
    if (blob) return new URL(`https://raw.githubusercontent.com/${blob[1]}/${blob[2]}/${blob[3]}`);
    return url;
}

/** The file's own name, decoded ("Babylonian%2BGods.ged" → "Babylonian+Gods.ged"), for the saga's notes. */
export function sourceName(input: string): string {
    if (!isUrl(input)) return path.basename(input);
    const last = new URL(input).pathname.split("/").filter(Boolean).pop() ?? "download.ged";
    return decodeURIComponent(last);
}

/** Read a GEDCOM file's bytes from a local path or an https URL. */
export async function readSource(input: string): Promise<Uint8Array> {
    if (!isUrl(input)) {
        const size = fs.statSync(input).size;
        if (size > MAX_BYTES) throw new Error(`${input} is ${size} bytes; the limit is ${MAX_BYTES}`);
        return fs.readFileSync(input);
    }
    const url = downloadUrl(input);
    const res = await fetch(url, { redirect: "follow", signal: AbortSignal.timeout(TIMEOUT_MS) });
    if (!res.ok) throw new Error(`couldn't download ${url}: ${res.status} ${res.statusText}`);
    const declared = Number(res.headers.get("content-length") ?? 0);
    if (declared > MAX_BYTES) throw new Error(`${url} is ${declared} bytes; the limit is ${MAX_BYTES}`);
    // Read in chunks so an undeclared or wrong length still can't exceed the cap.
    const chunks: Uint8Array[] = [];
    let total = 0;
    for await (const chunk of res.body as unknown as AsyncIterable<Uint8Array>) {
        total += chunk.length;
        if (total > MAX_BYTES) throw new Error(`${url} is larger than the ${MAX_BYTES}-byte limit`);
        chunks.push(chunk);
    }
    const bytes = new Uint8Array(total);
    let at = 0;
    for (const c of chunks) (bytes.set(c, at), (at += c.length));
    // A GitHub page or an error page served as 200 would otherwise be parsed as an empty family tree.
    if (!/^\s*(?:﻿)?0\s+HEAD\b/.test(new TextDecoder().decode(bytes.subarray(0, 64))))
        throw new Error(
            `${url} isn't a GEDCOM file (it doesn't start with "0 HEAD"); for GitHub, link to the file itself`
        );
    return bytes;
}
