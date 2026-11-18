// Label visibility: relationship labels fade with distance, colliding names are thinned out, and the "relative to"
// tags above each person.
import * as THREE from "three";
import SpriteText from "three-spritetext";
import { quality } from "../device.ts";
import { approach, boundLinks, boundNodes, nameOf } from "./core.ts";
import { focus } from "./highlight.ts";
import { siblingLabels } from "./siblings.ts";

// Relationship labels are fully visible within LABEL_NEAR of the camera and hidden beyond LABEL_FAR. The whole-tree
// view of a typical saga is ~300–450 units away, so these keep the labels on at that zoom and only drop them when
// zoomed well out, where they'd be too small to read anyway. (It was 110–240: they only appeared once zoomed in.)
const LABEL_NEAR = 220;
const LABEL_FAR = 480;

// --- Distance fade ----------------------------------------------------------------------------------------------
const tmp = new THREE.Vector3();
// Text outside a highlight fades further than the spheres: a faint sphere still shows the tree's shape, but faint
// text is only clutter around the line you're reading. Squaring the dim factor leaves lit labels (1) as they are and
// takes a 12% dim to ~1.5% and a 6% one to ~0.4%. Within a line (dims of 0.55–1 by distance) labels stay readable.
const textDim = (dim: number) => (dim < 0.5 ? dim * dim : dim);
// Relationship labels fade out with distance; those on the highlighted line stay readable at any distance.
export function fadeLabels(camera: THREE.Camera): void {
    const fade = (s: SpriteText) => {
        const dim = (s.userData.dim ?? 1) as number;
        const d = camera.position.distanceTo(s.getWorldPosition(tmp));
        const near = focus !== null && dim === 1 ? 1 : (LABEL_FAR - d) / (LABEL_FAR - LABEL_NEAR);
        s.material.transparent = true;
        s.material.opacity = textDim(dim) * THREE.MathUtils.clamp(near, 0, 1);
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
        const target = (n.__threeObj!.userData.dimTarget ?? 1) as number;
        if (textDim(target) < 0.02) continue; // hidden, or faded past reading: doesn't take up room
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
        const lit = focus !== null && focus.has(n.id); // in the highlighted line (its dim may be < 1 by distance)
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
        const dim = (n.__threeObj!.userData.dim ?? 1) as number;
        s.material.opacity = shown * textDim(dim);
        s.visible = s.material.opacity > 0.02;
        // "Relative to" tags fade with their person too (focus mode hides them with the person).
        const tag = n.__threeObj!.children.find((c) => c.userData.isTag) as SpriteText | undefined;
        if (tag?.userData.text) {
            tag.material.transparent = true;
            tag.material.opacity = textDim(dim);
            tag.visible = tag.material.opacity > 0.02;
        }
    }
}

// --- "Relative to" tags: a small label above each person saying how they relate to the centre person ------------
// The same tag shows "+ 42" over a person whose branch is collapsed; that wins over a relationship word.
let relative: Map<string, string | null> | null = null;
let foldBadges = new Map<string, string>();
export function setRelativeTags(labels: Map<string, string | null> | null): void {
    relative = labels;
    drawTags();
}
export function setFoldBadges(badges: Map<string, string>): void {
    foldBadges = badges;
    drawTags();
}
function drawTags(): void {
    for (const n of boundNodes()) {
        const tag = n.__threeObj?.children.find((c) => c.userData.isTag) as SpriteText | undefined;
        if (!tag) continue;
        const text = foldBadges.get(n.id) ?? relative?.get(n.id) ?? null;
        tag.userData.text = text; // stepNames() shows it (faded with its person) only while it has text
        tag.visible = !!text;
        if (text && tag.text !== text) tag.text = text;
    }
}
