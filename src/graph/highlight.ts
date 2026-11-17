// Highlight: dim everything outside a person's line (or a relationship path), and ease the fades each frame.
// highlight() only sets a target "dim" per object (1 = lit, DIM = faded); stepFades() eases every object towards its
// target each frame, so highlights fade in and out instead of snapping. A relationship path additionally glows.
import * as THREE from "three";
import SpriteText from "three-spritetext";
import { palette } from "../palettes.ts";
import { approach, boundLinks, boundNodes, endId, graph, type Link, LINK_OPACITY } from "./core.ts";
import { siblingLabels, siblingMat, siblingPairs, siblings } from "./siblings.ts";

const DIM = 0.12; // opacity of everything outside a highlighted line
const FADE_RATE = 10; // highlight fades converge at this rate per second (≈ 0.3 s to settle)

/** People in the highlighted line, or null to show everything (read by names.ts to keep their labels readable). */
export let focus: Set<string> | null = null;
let pathLinks = new Set<Link>(); // links on a relationship path, drawn brighter and thicker

/** Dim everything outside `people` (null clears it). `path` (a relationship chain) is emphasised on top. */
export function highlight(people: Set<string> | null, path: string[] = []): void {
    focus = people;
    const { links } = graph.graphData();
    const unionsLit = new Set<string>();
    if (people)
        for (const l of links) {
            if (l.kind === "spouse" && people.has(endId(l.source))) unionsLit.add(endId(l.target));
            if (l.kind === "child" && people.has(endId(l.target))) unionsLit.add(endId(l.source));
        }
    const lit = (id: string) => !people || people.has(id) || unionsLit.has(id);

    // A path step between two people goes through their family's union node: parent→union→child, or
    // spouse→union←spouse. Mark both halves of each step.
    pathLinks = new Set();
    const onPath = new Set(path);
    for (let i = 0; i + 1 < path.length; i++) {
        const [a, b] = [path[i], path[i + 1]];
        const touching = (p: string) => links.filter((l) => endId(l.source) === p || endId(l.target) === p);
        for (const la of touching(a)) {
            const ua = la.kind === "spouse" ? endId(la.target) : endId(la.source);
            const lb = touching(b).find((l) => (l.kind === "spouse" ? endId(l.target) : endId(l.source)) === ua);
            if (lb) {
                pathLinks.add(la);
                pathLinks.add(lb);
                break;
            }
        }
    }

    for (const n of boundNodes()) {
        setTarget(n.__threeObj, lit(n.id) ? 1 : DIM);
        const sphere = n.__threeObj?.children[0] as
            THREE.Mesh<THREE.BufferGeometry, THREE.MeshStandardMaterial> | undefined;
        if (sphere?.material.emissive) sphere.userData.glow = onPath.has(n.id) && path.length > 1 ? 1 : 0;
    }
    for (const l of boundLinks()) {
        const on = pathLinks.has(l) || (lit(endId(l.source)) && lit(endId(l.target)));
        setTarget(l.__lineObj, on ? 1 : DIM);
        setTarget(l.__photonsObj, on ? 1 : DIM);
        if (l.__lineObj) l.__lineObj.userData.path = pathLinks.has(l) ? 1 : 0;
    }
    siblingPairs.forEach(([a, b], i) => setTarget(siblingLabels[i], lit(a.id) && lit(b.id) ? 1 : DIM));
    siblings.userData.dimTarget = people ? DIM : 1;
}

/** Forget the highlight without touching objects (a new tree's objects start lit). */
export const clearFocus = () => (focus = null);

function setTarget(obj: THREE.Object3D | undefined, dim: number) {
    obj?.traverse((o) => (o.userData.dimTarget = dim));
}

// Ease every object's dim (and path glow) towards its target. Meshes and lines get opacity directly; labels keep
// the factor in userData.dim, which names.ts combines with the distance fade.
export function stepFades(dt: number): void {
    const k = 1 - Math.exp(-FADE_RATE * dt);
    const fadeObject = (root: THREE.Object3D | undefined) =>
        root?.traverse((o) => {
            const target = (o.userData.dimTarget ?? 1) as number;
            const dim = approach((o.userData.dim ?? 1) as number, target, k);
            o.userData.dim = dim;
            // Labels are faded by names.ts, link lines below; everything else (spheres, badges, dots) here.
            if (o instanceof SpriteText || o.userData.isLinkLine) return;
            const m = (o as THREE.Mesh).material as THREE.Material | undefined;
            if (!m) return;
            m.transparent = true;
            m.userData.baseOpacity ??= m.opacity;
            m.opacity = dim * (m.userData.baseOpacity as number);
            if (m instanceof THREE.MeshStandardMaterial) {
                const glow = approach((o.userData.glowNow ?? 0) as number, (o.userData.glow ?? 0) as number, k);
                o.userData.glowNow = glow;
                m.emissive.copy(m.color).multiplyScalar(0.45 * glow); // the path's people light up in their colour
            }
        });
    for (const n of boundNodes()) fadeObject(n.__threeObj);
    for (const l of boundLinks()) {
        fadeObject(l.__lineObj);
        fadeObject(l.__photonsObj); // the travelling dots: the library re-uses the template's material for them
        // Path links: brighter (full opacity, gold) and thicker than resting links.
        const line = l.__lineObj?.children[0] as
            THREE.Mesh<THREE.BufferGeometry, THREE.MeshLambertMaterial> | undefined;
        if (!line) continue;
        line.userData.isLinkLine = true;
        const p = approach((line.userData.pathNow ?? 0) as number, (l.__lineObj!.userData.path ?? 0) as number, k);
        line.userData.pathNow = p;
        line.material.opacity = (line.userData.dim ?? 1) * (LINK_OPACITY + (1 - LINK_OPACITY) * p);
        line.material.emissive.set(palette().links.pathGlow).multiplyScalar(0.6 * p);
        line.scale.x = line.scale.y = 1 + 1.6 * p;
    }
    siblingLabels.forEach(fadeObject);
    const sd = approach((siblings.userData.dim ?? 1) as number, (siblings.userData.dimTarget ?? 1) as number, k);
    siblings.userData.dim = sd;
    siblingMat.opacity = sd;
}
