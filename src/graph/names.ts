// Names: label visibility, i.e. distance fade, name de-overlap, and the "relative to" tags above each person.
//
// What it does: fadeLabels() fades relationship labels with camera distance; declutter() hides names that collide on
// screen, keeping highlighted people and then the nearest; stepNames() eases name and tag opacity each frame;
// setRelativeTags() and setFoldBadges() set the small tag text above a person (a fold badge wins).
// Usage: all called from graph.ts (stepGraph) and re-exported for the UI.
// Notes: declutter runs only every quality.labelDeclutterMs, then visibility eases so names fade rather than pop; its
// box test uses a screen grid (near-linear). fadeLabels and stepNames skip work that hasn't changed (a still camera,
// settled fades, names already at their target), so a settled view costs almost nothing here. Text outside a highlight fades faster than spheres (textDim
// squares the dim), and all of these combine with highlight.ts's userData.dim, so run them after stepFades.

import * as THREE from "three";
import SpriteText from "three-spritetext";
import { quality } from "../device.ts";
import { approach, boundLinks, boundNodes, layoutRunning, nameOf } from "./core.ts";
import { fadesSettled, focus } from "./highlight.ts";
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
// Relationship labels fade out with distance; those on the highlighted line stay readable at any distance. The result
// only depends on the camera position and each label's dim, so when neither changed since the last pass there's
// nothing to do (a settled, still view would otherwise walk every link label each frame).
const lastCam = new THREE.Vector3(Infinity, 0, 0);
export function fadeLabels(camera: THREE.Camera): void {
    if (!layoutRunning && fadesSettled() && camera.position.equals(lastCam)) return;
    lastCam.copy(camera.position);
    const fade = (s: SpriteText) => {
        const dim = (s.userData.dim ?? 1) as number;
        // The world matrix was updated by last frame's render; reading it avoids getWorldPosition(), which walks up and
        // recomputes every parent's matrix for each label (a few hundred labels × every frame while orbiting).
        const d = camera.position.distanceTo(tmp.setFromMatrixPosition(s.matrixWorld));
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
// Placed boxes go in a coarse screen grid, so each name is tested only against boxes in the cells it overlaps rather
// than every name placed so far (that was O(n²): ~170k comparisons for the Bible's 583 names, several times a second).
const NAME_GAP = 4; // px of clearance kept between name boxes
const CELL = 96; // px; about the width of a typical name at the whole-tree zoom
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
        p.setFromMatrixPosition(s.matrixWorld); // updated by the last render; avoids recomputing every parent
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
    const grid = new Map<number, Box[]>();
    const cells = (b: Box) => {
        const out: number[] = [];
        const cx0 = Math.floor((b.x0 - NAME_GAP) / CELL);
        const cx1 = Math.floor((b.x1 + NAME_GAP) / CELL);
        const cy0 = Math.floor((b.y0 - NAME_GAP) / CELL);
        const cy1 = Math.floor((b.y1 + NAME_GAP) / CELL);
        for (let cx = cx0; cx <= cx1; cx++) for (let cy = cy0; cy <= cy1; cy++) out.push(cx * 100003 + cy);
        return out;
    };
    const overlaps = (b: Box, o: Box) =>
        b.x0 < o.x1 + NAME_GAP && b.x1 > o.x0 - NAME_GAP && b.y0 < o.y1 + NAME_GAP && b.y1 > o.y0 - NAME_GAP;
    for (const b of boxes) {
        const keys = cells(b);
        const hit = keys.some((c) => grid.get(c)?.some((o) => overlaps(b, o)));
        nameShown.set(b.s, hit ? 0 : 1);
        if (!hit) for (const c of keys) (grid.get(c) ?? grid.set(c, []).get(c)!).push(b);
    }
}

export function stepNames(dt: number): void {
    const k = 1 - Math.exp(-12 * dt);
    for (const n of boundNodes()) {
        const s = nameOf(n);
        if (!s) continue;
        const want = nameShown.get(s) ?? 1;
        const dim = (n.__threeObj!.userData.dim ?? 1) as number;
        // Skip a name that's already where it should be (most of them, once the view has settled).
        if (s.userData.shown === want && s.userData.lastDim === dim) continue;
        const shown = approach((s.userData.shown ?? 1) as number, want, k);
        s.userData.shown = Math.abs(shown - want) < 0.002 ? want : shown;
        s.userData.lastDim = dim;
        s.material.transparent = true;
        s.material.opacity = (s.userData.shown as number) * textDim(dim);
        s.visible = s.material.opacity > 0.02;
        // "Relative to" tags fade with their person too (focus mode hides them with the person).
        const tag = tagOf(n.__threeObj!);
        if (tag?.userData.text) {
            tag.material.transparent = true;
            tag.material.opacity = textDim(dim);
            tag.visible = tag.material.opacity > 0.02;
        }
    }
}

/** The tag sprite above a person, cached on their object (looked up every frame otherwise). */
function tagOf(obj: THREE.Object3D): SpriteText | undefined {
    return (obj.userData.tagSprite ??= obj.children.find((c) => c.userData.isTag)) as SpriteText | undefined;
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
        const tag = n.__threeObj && tagOf(n.__threeObj);
        if (!tag) continue;
        const text = foldBadges.get(n.id) ?? relative?.get(n.id) ?? null;
        tag.userData.text = text; // stepNames() shows it (faded with its person) only while it has text
        const name = nameOf(n);
        if (name) delete name.userData.lastDim; // make stepNames() revisit this person's tag
        tag.visible = !!text;
        if (text && tag.text !== text) tag.text = text;
    }
}
