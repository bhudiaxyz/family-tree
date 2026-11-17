// Sibling overlay: a dashed line and a "brother & sister" label between consecutive siblings. Drawn outside the graph
// data: as links they would pull siblings together and distort the layout. Repositioned from the live node positions
// every frame.
import * as THREE from "three";
import type SpriteText from "three-spritetext";
import type { Tree } from "../data/schema.ts";
import { siblingLabel } from "../family.ts";
import { disposeLabel, relationLabel } from "../labels.ts";
import { palette } from "../palettes.ts";
import { graph, midpoint, type Node } from "./core.ts";

/** The dashed-line material; its opacity is faded as one by the highlight (highlight.ts). */
export const siblingMat = new THREE.LineDashedMaterial({
    color: palette().siblingLine,
    dashSize: 2,
    gapSize: 1.5,
    transparent: true,
});
export const siblings = new THREE.Group();
graph.add(siblings);
export let siblingPairs: [Node, Node][] = [];
export let siblingLabels: SpriteText[] = [];
const siblingLines = new THREE.LineSegments(new THREE.BufferGeometry(), siblingMat);
siblings.add(siblingLines);

export function setSiblings(t: Tree, byId: Map<string, Node>, pairs: [string, string][]): void {
    siblingLabels.forEach(disposeLabel);
    siblings.remove(...siblingLabels);
    siblingPairs = pairs.map(([a, b]) => [byId.get(a)!, byId.get(b)!]);
    siblingLabels = pairs.map(([a, b]) => relationLabel(siblingLabel(t, a, b), palette().labels.sibling));
    if (siblingLabels.length) siblings.add(...siblingLabels);
    siblingLines.geometry.dispose();
    siblingLines.geometry = new THREE.BufferGeometry();
    siblingLines.geometry.setAttribute("position", new THREE.Float32BufferAttribute(pairs.length * 6, 3));
}

export function updateSiblings(): void {
    const pos = siblingLines.geometry.attributes.position as THREE.BufferAttribute | undefined;
    if (!pos) return; // no tree shown yet (the frame loop starts before the first saga loads)
    siblingPairs.forEach(([a, b], i) => {
        if (a.x === undefined || b.x === undefined) return;
        pos.setXYZ(i * 2, a.x, a.y!, a.z!);
        pos.setXYZ(i * 2 + 1, b.x, b.y!, b.z!);
        midpoint(siblingLabels[i], a, b);
    });
    pos.needsUpdate = true;
    siblingLines.geometry.computeBoundingSphere();
    siblingLines.computeLineDistances();
}
