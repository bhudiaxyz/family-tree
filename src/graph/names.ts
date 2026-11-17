// Label visibility: relationship labels fade with distance, colliding names are thinned out, and the "relative to"
// tags above each person.
import * as THREE from "three";
import SpriteText from "three-spritetext";
import { quality } from "../device.ts";
import { approach, boundLinks, boundNodes, nameOf } from "./core.ts";
import { focus } from "./highlight.ts";
import { siblingLabels } from "./siblings.ts";

const LABEL_NEAR = 110; // relationship labels are fully visible within this distance of the camera…
const LABEL_FAR = 240; // …and hidden beyond this one

// --- Distance fade ----------------------------------------------------------------------------------------------
const tmp = new THREE.Vector3();
// Relationship labels fade out with distance; those on the highlighted line stay readable at any distance.
export function fadeLabels(camera: THREE.Camera): void {
    const fade = (s: SpriteText) => {
        const dim = (s.userData.dim ?? 1) as number;
        const d = camera.position.distanceTo(s.getWorldPosition(tmp));
        const near = focus !== null && dim === 1 ? 1 : (LABEL_FAR - d) / (LABEL_FAR - LABEL_NEAR);
        s.material.transparent = true;
        s.material.opacity = dim * THREE.MathUtils.clamp(near, 0, 1);
        s.visible = s.material.opacity > 0.02;
    };
    for (const l of boundLinks()) {
        const label = l.__lineObj?.children[1];
        if (label instanceof SpriteText) fade(label);
    }
    siblingLabels.forEach(fade);
}

// --- Name de-overlap ----------------------------------------------------------------------------------------------
// Names that collide on screen are faded out, keeping the most important one: highlighted people first, then the
// person nearest the camera. Screen boxes are estimated from the projected label width/height. The layout is
// recomputed a few times a second (not every frame); visibility then eases, so names fade rather than pop.
// ponytail: O(n²) box test, fine for the few hundred names a family tree has; use a grid if trees reach thousands.
const NAME_GAP = 4; // px of clearance kept between name boxes
let declutterAt = 0;
const nameShown = new WeakMap<SpriteText, number>(); // target opacity per name (0/1)
const p = new THREE.Vector3();
const edge = new THREE.Vector3();
type Box = { s: SpriteText; x0: number; x1: number; y0: number; y1: number; prio: number };

export function declutter(camera: THREE.PerspectiveCamera, viewW: number, viewH: number, now: number): void {
    if (now - declutterAt < quality.labelDeclutterMs) return;
    declutterAt = now;
    const boxes: Box[] = [];
    for (const n of boundNodes()) {
        const s = nameOf(n);
        if (!s) continue;
        s.getWorldPosition(p);
        const depth = p.distanceTo(camera.position);
        edge.copy(p).project(camera);
        if (edge.z > 1) continue; // behind the camera
        const cx = ((edge.x + 1) / 2) * viewW;
        const cy = ((1 - edge.y) / 2) * viewH;
        // World size of the sprite → pixels at this depth.
        const pxPerUnit = viewH / (2 * depth * Math.tan(THREE.MathUtils.degToRad(camera.fov) / 2));
        const w = s.scale.x * pxPerUnit;
        const h = s.scale.y * pxPerUnit;
        const lit = (n.__threeObj!.userData.dimTarget ?? 1) === 1 && focus !== null;
        boxes.push({
            s,
            x0: cx - w / 2,
            x1: cx + w / 2,
            y0: cy - h / 2,
            y1: cy + h / 2,
            prio: (lit ? 1e6 : 0) - depth,
        });
    }
    boxes.sort((a, b) => b.prio - a.prio);
    const placed: Box[] = [];
    for (const b of boxes) {
        const hit = placed.some(
            (o) => b.x0 < o.x1 + NAME_GAP && b.x1 > o.x0 - NAME_GAP && b.y0 < o.y1 + NAME_GAP && b.y1 > o.y0 - NAME_GAP
        );
        nameShown.set(b.s, hit ? 0 : 1);
        if (!hit) placed.push(b);
    }
}

export function stepNames(dt: number): void {
    const k = 1 - Math.exp(-12 * dt);
    for (const n of boundNodes()) {
        const s = nameOf(n);
        if (!s) continue;
        const shown = (s.userData.shown = approach((s.userData.shown ?? 1) as number, nameShown.get(s) ?? 1, k));
        s.material.transparent = true;
        s.material.opacity = shown * ((n.__threeObj!.userData.dim ?? 1) as number);
        s.visible = s.material.opacity > 0.02;
    }
}

// --- "Relative to" tags: a small label above each person saying how they relate to the centre person ------------
export function setRelativeTags(labels: Map<string, string | null> | null): void {
    for (const n of boundNodes()) {
        const tag = n.__threeObj?.children.find((c) => c.userData.isTag) as SpriteText | undefined;
        if (!tag) continue;
        const text = labels?.get(n.id) ?? null;
        tag.visible = !!text;
        if (text && tag.text !== text) tag.text = text;
    }
}
