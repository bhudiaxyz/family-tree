// Generation guides: a faint band and a "Generation n" label at each row, so you can tell where you are.
import * as THREE from "three";
import SpriteText from "three-spritetext";
import { disposeLabel, relationLabel } from "../labels.ts";
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

/** Rebuild the guides for generations 0…rows, at the heights given by `y`. */
export function setGuides(rows: number, y: (g: number) => number): void {
    guides.traverse((o) => o instanceof SpriteText && disposeLabel(o));
    for (const c of guides.children) if (c instanceof THREE.LineSegments) c.geometry.dispose();
    guides.clear();
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
        const label = relationLabel(`Generation ${g + 1}`, palette().labels.guide);
        label.backgroundColor = false as unknown as string; // no backing box for these
        label.userData.guideLabel = true;
        label.position.set(0, y(g) + 3, 0);
        guides.add(line, label);
    }
}

export const setGuidesVisible = (on: boolean) => (guides.visible = on);
