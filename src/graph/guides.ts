// Generation guides: a faint line at each generation's height, and a "Generation n" label pinned to the left edge of
// the screen at that row's height. The labels used to be 3D sprites at x = 0 (the tree's centre), so they vanished as
// soon as you panned sideways or zoomed in, exactly when you'd want to know which generation you're looking at.
import * as THREE from "three";
import { palette } from "../palettes.ts";
import { graph } from "./core.ts";

const guides = new THREE.Group();
graph.add(guides);
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
    rowLabels = rowY.map((_, g) =>
        Object.assign(document.createElement("span"), { textContent: `Generation ${g + 1}` })
    );
    labelLayer.replaceChildren(...rowLabels);
    lastTops = [];
}

export function setGuidesVisible(on: boolean): void {
    guides.visible = shown = on;
    labelLayer.hidden = !on;
}

// Each frame: where does each row's height cross the left part of the screen? Project a point on the row straight
// in front of the camera (its x and z), so the label tracks the row whatever the pan, zoom or orbit. Rows off screen,
// or seen too edge-on to place (looking straight down), are hidden. Only labels whose position changed are touched.
const pt = new THREE.Vector3();
// Bottom edge of the header overlay, measured on resize (reading layout every frame would force reflows).
const header = document.querySelector("header");
let headerEdge = 0;
const measureHeader = () => (headerEdge = (header?.getBoundingClientRect().bottom ?? 0) + 4);
addEventListener("resize", measureHeader);
const headerBottom = () => headerEdge || measureHeader();
let lastTops: number[] = [];
export function stepGuides(camera: THREE.PerspectiveCamera, target: THREE.Vector3, viewH: number): void {
    if (!shown || !rowLabels.length) return;
    for (let g = 0; g < rowY.length; g++) {
        pt.set(target.x, rowY[g], target.z).project(camera);
        const raw = pt.z > 1 || pt.y < -1.05 || pt.y > 1.05 ? -1 : Math.round(((1 - pt.y) / 2) * viewH);
        // A row under the header (title, search, toolbar) is clamped to just below it, so the top generation stays
        // labelled at the default view; the next row down hides it once it reaches the same place.
        const top = raw >= 0 && raw < headerBottom() ? headerBottom() : raw;
        if (top === lastTops[g]) continue;
        lastTops[g] = top;
        const el = rowLabels[g];
        el.hidden = top < 0;
        if (top >= 0) el.style.transform = `translateY(${top}px)`;
    }
}
