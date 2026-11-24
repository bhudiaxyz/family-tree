// Row guides: a faint line at each row's height, and a "Row n" button pinned to the left edge of the screen at it.
//
// What it does: setGuides() rebuilds the lines and the buttons in #gen-labels (index.html); stepGuides() moves each
// button every frame to where its row projects on screen, hiding rows that are off screen or seen edge-on.
// Usage: graph.ts calls setGuides() and stepGuides(); re-exports generationRows, onRowPicked and setGuidesVisible
// for the UI (click, tap or Page Up / Page Down to jump between rows).
// Notes: the labels used to be 3D sprites at x = 0, which vanished as soon as you panned sideways or zoomed in. They
// say "Row", not "Generation": a row is a layout level, and a person who married across generations sits on their
// partner's row. A row under the header is pinned just below it; only labels whose position changed are touched.

import * as THREE from "three";
import { palette } from "../render/palettes.ts";
import { graph } from "./core.ts";

const guides = new THREE.Group();

const guideMat = new THREE.LineBasicMaterial({
    color: palette().guideLine,
    transparent: true,
    opacity: 0.07,
    depthWrite: false,
});

// The screen labels live in #gen-labels (index.html); one <span> per row, moved each frame by stepGuides().
const labelLayer = document.getElementById("gen-labels") as HTMLElement;

let rowY: number[] = []; // world height of each generation row
let rowLabels: HTMLElement[] = [];
let shown = true;
let rowPicked: ((row: number) => void) | null = null;

// Each frame: where does each row's height cross the left part of the screen? Project a point on the row straight
// in front of the camera (its x and z), so the label tracks the row whatever the pan, zoom or orbit. Rows off screen,
// or seen too edge-on to place (looking straight down), are hidden. Only labels whose position changed are touched.
const pt = new THREE.Vector3();

// Bottom edge of the header overlay, measured on resize (reading layout every frame would force reflows).
const header = document.querySelector("header");

let headerEdge = 0;
let lastTops: number[] = [];
const raws: number[] = [];
const LABEL_H = 16; // px a label needs before the next one

/** Rebuild the guides for generations 0…rows, at the heights given by `y`. */
export function setGuides(rows: number, y: (g: number) => number): void {
    for (const c of guides.children) if (c instanceof THREE.LineSegments) c.geometry.dispose();
    guides.clear();
    rowY = [];
    for (let g = 0; g <= rows; g++) {
        // A long horizontal line in the x-z plane at this generation's height (a cross, so it reads from any angle).
        const L = 600;
        const geo = new THREE.BufferGeometry().setFromPoints([
            new THREE.Vector3(-L, y(g), 0),
            new THREE.Vector3(L, y(g), 0),
            new THREE.Vector3(0, y(g), -L),
            new THREE.Vector3(0, y(g), L),
        ]);
        const line = new THREE.LineSegments(geo, guideMat);
        line.userData.guideRow = g;
        guides.add(line);
        rowY.push(y(g));
    }
    // Buttons, so a row can be jumped to with a click, a tap or the keyboard (see onRowPicked).
    rowLabels = rowY.map((_, g) => {
        // "Row", not "Generation": a row is a layout level, and someone who married into another generation sits on
        // their partner's row (Ginny is on row 3 with Harry, though she's generation 2 with her brothers).
        const b = Object.assign(document.createElement("button"), { textContent: `Row ${g + 1}` });
        b.title = `Go to row ${g + 1} (Page Up / Page Down step between rows)`;
        b.onclick = () => rowPicked?.(g);
        return b;
    });
    labelLayer.replaceChildren(...rowLabels);
    lastTops = [];
}

/** World height of each row, top (oldest) first: for stepping a row at a time (Page Up / Page Down). */
export const generationRows = (): readonly number[] => rowY;

/** Called with the row number when a "Row n" label is clicked. */
export const onRowPicked = (fn: (row: number) => void) => (rowPicked = fn);

export function setGuidesVisible(on: boolean): void {
    guides.visible = shown = on;
    labelLayer.hidden = !on;
}

const measureHeader = () => (headerEdge = (header?.getBoundingClientRect().bottom ?? 0) + 4);
const headerBottom = () => headerEdge || measureHeader();

export function stepGuides(camera: THREE.PerspectiveCamera, target: THREE.Vector3, viewH: number): void {
    if (!shown || !rowLabels.length) return;
    for (let g = 0; g < rowY.length; g++) {
        pt.set(target.x, rowY[g], target.z).project(camera);
        raws[g] = pt.z > 1 || pt.y < -1.05 || pt.y > 1.05 ? -1 : Math.round(((1 - pt.y) / 2) * viewH);
    }
    const edge = headerBottom();
    for (let g = 0; g < rowY.length; g++) {
        // A row under the header (title, search, toolbar) is pinned just below it, so the top generation stays
        // labelled at the default view. Only the lowest such row is pinned, and only while the next row's own label
        // is far enough down not to collide with it; rows are ordered top to bottom.
        const raw = raws[g];
        const next = raws[g + 1] ?? -1;
        const underHeader = raw >= 0 && raw < edge;
        const top = !underHeader ? raw : (next >= 0 && next < edge) || (next >= 0 && next < edge + LABEL_H) ? -1 : edge;
        if (top === lastTops[g]) continue;
        lastTops[g] = top;
        const el = rowLabels[g];
        el.hidden = top < 0;
        if (top >= 0) el.style.transform = `translateY(${top}px)`;
    }
}

graph.add(guides);
addEventListener("resize", measureHeader);
