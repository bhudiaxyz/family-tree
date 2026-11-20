// Highlight: dim (or, in focus mode, hide) everything outside a person's line or a relationship path.
//
// What it does: highlight() only sets a target opacity per object (userData.dimTarget); stepFades() eases every
// object towards it each frame, so highlights fade in and out instead of snapping. Within a line, direction shows too:
// ancestors glow warm, descendants cool, and each generation further away is a little fainter. A relationship path
// glows gold, and the finder's hovered step brighter still.
// Usage: graph.ts re-exports highlight, setFolded and HighlightOptions and calls stepFades()/clearFocus(); names.ts
// reads the exported focus set to keep lit labels readable.
// Notes: labels are not faded here; they keep the factor in userData.dim and names.ts combines it with the distance
// fade. A family's union dot lights only when two of its members are lit. Fully faded objects are made invisible,
// which also removes them from picking.

import * as THREE from "three";
import SpriteText from "three-spritetext";
import type { LineSegments2 } from "three/addons/lines/LineSegments2.js";
import type { LineRole } from "../family.ts";
import { palette } from "../palettes.ts";
import { approach, boundLinks, boundNodes, endId, graph, type Link, LINK_OPACITY, LINK_PX } from "./core.ts";
import { siblingLabels, siblingMat, siblingPairs, siblings } from "./siblings.ts";

const DIM = 0.12; // opacity of everything outside a highlighted line
const HIDDEN = 0; // ...or, in focus mode, nothing at all
const FADE_RATE = 10; // highlight fades converge at this rate per second (≈ 0.3 s to settle)
const DISTANCE_FADE = 0.12; // each generation away from the centre person is this much fainter...
const MIN_LIT = 0.55; // ...down to this, so even distant ancestors stay clearly part of the line
const TINT = 0.32; // strength of the ancestor/descendant tint (emissive, on top of the house colour)

/** People in the highlighted line, or null to show everything (read by names.ts to keep their labels readable). */
export let focus: Set<string> | null = null;
let pathLinks = new Set<Link>(); // links on a relationship path, drawn brighter and thicker

export type HighlightOptions = {
    /** Side and distance per person (a selected person's line), for the direction tint and distance fade. */
    roles?: Map<string, LineRole>;
    /** A relationship chain, drawn as a gold path. */
    path?: string[];
    /** One step of the path, [from, to], emphasised further (hovering a step in the finder). */
    step?: [string, string] | null;
    /** Hide everything outside the highlight instead of dimming it. */
    hideOthers?: boolean;
    /** How far to dim everything outside the highlight (default DIM); a house view fades the rest further. */
    dim?: number;
    /** The selected person: glows and gets a halo, so they're easy to pick out (a hover preview passes none). */
    centre?: string | null;
};

/** People folded away under a collapsed branch: hidden whatever the highlight. Set by the UI (state.collapsed). */
let folded = new Set<string>();
export const setFolded = (ids: Set<string>) => (folded = ids);

/** Dim everything outside `people` (null clears it); see HighlightOptions for the extras. */
export function highlight(people: Set<string> | null, opts: HighlightOptions = {}): void {
    const { roles, path = [], step = null, hideOthers = false, dim = DIM, centre = null } = opts;
    focus = people;
    settled = false;
    const out = people && hideOthers ? HIDDEN : dim;
    const { links } = graph.graphData();
    // A family's dot lights only when two of its members are lit (a couple, or a parent and child), so a lit parent
    // doesn't drag in a "father" link that leads to nobody lit (Robert's link to Gendry when only Robert is shown).
    const unionsLit = new Set<string>();
    if (people) {
        const litMembers = new Map<string, number>();
        for (const l of links) {
            const [person, union] = l.kind === "spouse" ? [l.source, l.target] : [l.target, l.source];
            if (people.has(endId(person))) litMembers.set(endId(union), (litMembers.get(endId(union)) ?? 0) + 1);
        }
        for (const [u, n] of litMembers) if (n >= 2) unionsLit.add(u);
    }
    const lit = (id: string) => !folded.has(id) && (!people || people.has(id) || unionsLit.has(id));
    // A person's brightness within the line: full at the centre, fading with generations away.
    const level = (id: string) => {
        const r = roles?.get(id);
        return r ? Math.max(MIN_LIT, 1 - DISTANCE_FADE * r.distance) : 1;
    };

    pathLinks = linksAlong(links, path);
    const stepLinks = step ? linksAlong(links, step) : new Set<Link>();
    const onPath = new Set(path);
    const onStep = new Set(step ?? []);

    const p = palette().lineage;
    for (const n of boundNodes()) {
        const obj = n.__threeObj;
        setTarget(obj, folded.has(n.id) ? HIDDEN : lit(n.id) ? level(n.id) : out);
        if (obj?.userData.isUnion) obj.userData.scaleTarget = people && lit(n.id) ? 1.35 : 1; // couples stand out
        const pathRing = obj?.children.find((c) => c.userData.isPathRing);
        const pathed = onPath.has(n.id) && path.length > 1;
        if (pathRing) pathRing.userData.dimTarget = pathed ? 1 : 0;
        // Halo: the selected person, and everyone on a relationship path (its two ends brighter).
        const halo = obj?.children.find((c) => c.userData.isHalo);
        if (halo && !folded.has(n.id))
            halo.userData.dimTarget =
                n.id === centre || n.id === path[0] || n.id === path.at(-1) ? 1 : pathed ? 0.55 : 0;
        const sphere = obj?.children[0] as THREE.Mesh<THREE.BufferGeometry, THREE.MeshStandardMaterial> | undefined;
        if (!sphere?.material.emissive) continue;
        // Glow: the path's people in their own colour, the hovered step's two people brighter; the selected person too.
        sphere.userData.glow = onStep.has(n.id) ? 1.6 : pathed ? 1 : n.id === centre ? 0.8 : 0;
        // Direction tint (only for a person's line, not a relationship path, which has its own gold).
        const side = path.length ? undefined : roles?.get(n.id)?.side;
        const tint = side && side !== "self" && side !== "spouse" ? p[side] : null;
        sphere.userData.tint = tint;
        // The same colour as a ring, matching the panel's key exactly (the tint alone is mixed into the house colour).
        const lineRing = obj!.children.find((c) => c.userData.isLineRing) as THREE.Sprite | undefined;
        if (lineRing) {
            if (tint != null) lineRing.material.color.set(tint); // keep the old colour while fading out
            lineRing.userData.dimTarget = tint != null && lit(n.id) ? level(n.id) : 0;
        }
    }
    for (const l of boundLinks()) {
        const gone = folded.has(endId(l.source)) || folded.has(endId(l.target));
        const on = pathLinks.has(l) || (lit(endId(l.source)) && lit(endId(l.target)));
        const dim = gone ? HIDDEN : on ? Math.min(level(endId(l.source)), level(endId(l.target))) : out;
        setTarget(l.__lineObj, dim);
        setTarget(l.__photonsObj, dim);
        if (l.__lineObj) l.__lineObj.userData.path = stepLinks.has(l) ? 2 : pathLinks.has(l) ? 1 : 0;
    }
    siblingPairs.forEach(([a, b], i) =>
        setTarget(siblingLabels[i], folded.has(a.id) || folded.has(b.id) ? HIDDEN : lit(a.id) && lit(b.id) ? 1 : out)
    );
    siblings.userData.dimTarget = people ? out : 1;
}

// A path step between two people goes through their family's union node: parent→union→child, or
// spouse→union←spouse. Mark both halves of each step.
function linksAlong(links: Link[], path: string[]): Set<Link> {
    const found = new Set<Link>();
    const touching = (p: string) => links.filter((l) => endId(l.source) === p || endId(l.target) === p);
    const union = (l: Link) => (l.kind === "spouse" ? endId(l.target) : endId(l.source));
    for (let i = 0; i + 1 < path.length; i++) {
        const tb = touching(path[i + 1]);
        for (const la of touching(path[i])) {
            const lb = tb.find((l) => union(l) === union(la));
            if (lb) {
                found.add(la).add(lb);
                break;
            }
        }
    }
    return found;
}

/** Forget the highlight without touching objects (a new tree's objects start lit). */
export const clearFocus = () => {
    focus = null;
    settled = false; // the new tree's objects have no fade state yet
};

// Once every fade has reached its target, stepFades() has nothing to do until a new highlight() (or a new tree):
// skipping it then saves a walk over every person and link object each frame, the largest per-frame CPU cost in a
// big saga (measured 18% of a frame while orbiting the Bible). `moved` is set by any value that still changed.
let settled = false;
let moved = false;
/** Ease `cur` towards `target`, snapping when close so it settles; notes that something moved. */
const ease = (cur: number, target: number, k: number) => {
    if (cur === target) return cur;
    moved = true;
    const next = approach(cur, target, k);
    return Math.abs(next - target) < 0.002 ? target : next;
};

function setTarget(obj: THREE.Object3D | undefined, dim: number) {
    obj?.traverse((o) => (o.userData.dimTarget = dim));
}

const tintColour = new THREE.Color();
const goldColour = new THREE.Color();
const stepGold = new THREE.Color();

// Ease every object's dim, glow and tint towards its target. Meshes and lines get opacity directly; labels keep the
// factor in userData.dim, which names.ts combines with the distance fade. Anything fully faded is made invisible, so
// focus mode also takes hidden people out of picking and drawing.
export function stepFades(dt: number): void {
    if (settled) return;
    moved = false;
    const k = 1 - Math.exp(-FADE_RATE * dt);
    const fadeObject = (root: THREE.Object3D | undefined) =>
        root?.traverse((o) => {
            o.userData.dim = ease((o.userData.dim ?? 1) as number, (o.userData.dimTarget ?? 1) as number, k);
            // Labels are faded by names.ts, link lines below; everything else (spheres, badges, dots) here.
            if (o instanceof SpriteText || o.userData.isLinkLine) return;
            const m = (o as THREE.Mesh).material as THREE.Material | undefined;
            if (!m) return;
            o.visible = o.userData.dim > 0.01;
            m.transparent = true;
            m.userData.baseOpacity ??= m.opacity;
            m.opacity = o.userData.dim * (m.userData.baseOpacity as number);
            if (m instanceof THREE.MeshStandardMaterial) {
                const glow = ease((o.userData.glowNow ?? 0) as number, (o.userData.glow ?? 0) as number, k);
                o.userData.glowNow = glow;
                const tintOn = o.userData.tint == null ? 0 : 1;
                const tint = ease((o.userData.tintNow ?? 0) as number, tintOn, k);
                o.userData.tintNow = tint;
                if (tintOn) o.userData.tintColour = o.userData.tint; // keep the last colour while fading out
                // The path's people light up in their own colour; a line's ancestors/descendants take a warm/cool tint.
                m.emissive.copy(m.color).multiplyScalar(0.45 * glow);
                if (tint > 0.001 && o.userData.tintColour != null)
                    m.emissive.add(
                        tintColour.set(o.userData.tintColour as THREE.ColorRepresentation).multiplyScalar(TINT * tint)
                    );
            }
        });
    for (const n of boundNodes()) {
        const obj = n.__threeObj;
        fadeObject(obj);
        // Grow the marriage ring (not the dot) while its couple is lit.
        const unionRing = obj?.userData.isUnion ? obj.children.find((c) => c.userData.isUnionRing) : undefined;
        if (unionRing) {
            const s = ease((obj!.userData.scaleNow ?? 1) as number, (obj!.userData.scaleTarget ?? 1) as number, k);
            obj!.userData.scaleNow = s;
            unionRing.scale.setScalar(3.6 * s);
        }
    }
    goldColour.set(palette().links.pathGlow);
    stepGold.set(palette().lineage.step);
    for (const l of boundLinks()) {
        fadeObject(l.__lineObj);
        fadeObject(l.__photonsObj); // the travelling dots: the library re-uses the template's material for them
        // Path links: brighter (full opacity, gold) and wider than resting links; the hovered step more so.
        const line = l.__lineObj?.children[0] as LineSegments2 | undefined;
        if (!line) continue;
        const p = ease((line.userData.pathNow ?? 0) as number, (l.__lineObj!.userData.path ?? 0) as number, k);
        line.userData.pathNow = p;
        const dim = (line.userData.dim ?? 1) as number;
        const m = line.material;
        line.visible = dim > 0.01;
        m.opacity = dim * Math.min(1, LINK_OPACITY + (1 - LINK_OPACITY) * p);
        m.color.copy(m.userData.base as THREE.Color).lerp(goldColour, Math.min(p, 1));
        if (p > 1) m.color.lerp(stepGold, Math.min(1, p - 1));
        m.linewidth = LINK_PX * (1 + 1.6 * p);
        // The glow line under a path link: faint at rest on the path, stronger on the hovered step.
        const glow = l.__lineObj!.children[2] as LineSegments2 | undefined;
        if (glow) {
            glow.material.opacity = dim * 0.28 * Math.min(p, 1.6);
            glow.visible = glow.material.opacity > 0.01;
        }
    }
    siblingLabels.forEach(fadeObject);
    const sd = ease((siblings.userData.dim ?? 1) as number, (siblings.userData.dimTarget ?? 1) as number, k);
    siblings.userData.dim = sd;
    siblingMat.opacity = sd;
    siblings.visible = sd > 0.01;
    // Settled only once a whole pass changed nothing AND every object has been built (the library adds them over its
    // first ticks, and a new object has no fade state yet).
    settled = !moved && boundNodes().every((n) => n.__threeObj);
}

/** True once every fade has reached its target (names.ts skips its own passes then, if the camera is still too). */
export const fadesSettled = () => settled;
