// DOM: the page's fixed UI elements from index.html, looked up once, plus tiny element helpers.
//
// What it does: exports `$` (get by id, typed), `el` (create an element with properties) and the shared elements
// (title, author, panel, search, relatePanel, relA, relB, btnRelate). Attaches name suggestions to the name boxes.
// Usage: imported by nearly every ui module; it has no UI logic of its own.
// Notes: the ids are looked up at import time and must exist in index.html (a rename there breaks start-up). The
// suggestions are attached here, before any feature module adds its own listeners to those boxes, so an open
// suggestion list gets Escape first (see suggest.ts).

import { attachSuggestions } from "../suggest.ts";

export const $ = <T extends HTMLElement = HTMLElement>(id: string) => document.getElementById(id) as T;

/** A new element with properties set: `el("button", { className: "chip", textContent: name })`. */
export const el = <K extends keyof HTMLElementTagNameMap>(tag: K, props: Partial<HTMLElementTagNameMap[K]> = {}) =>
    Object.assign(document.createElement(tag), props);
export const title = $("title");
export const author = $("author");
export const panel = $("panel");
export const search = $<HTMLInputElement>("search");
export const relatePanel = $("relate");
export const relA = $<HTMLInputElement>("rel-a");
export const relB = $<HTMLInputElement>("rel-b");
export const btnRelate = $("btn-relate");

for (const box of [search, relA, relB]) attachSuggestions(box);
