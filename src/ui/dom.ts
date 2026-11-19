// The page's UI elements, looked up once. Name suggestions are attached here, before any feature module adds its own
// listeners to these boxes, so an open suggestion list gets Escape first.
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
