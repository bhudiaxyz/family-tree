// Highlight: dim (or, in focus mode, hide) everything outside a person's line or a relationship path, and ease the
// fades each frame. highlight() only sets targets per object; stepFades() eases every object towards them each frame,
// so highlights fade in and out instead of snapping. Within a line, direction is shown too: ancestors glow warm,
// descendants cool, and each generation further away is a little fainter. A relationship path glows gold, and the
// finder's hovered step brighter still.
import * as THREE from "three";
import SpriteText from "three-spritetext";
import type { LineRole } from "../family.ts";
import { palette } from "../palettes.ts";
import { approach, boundLinks, boundNodes, endId, graph, type Link, LINK_OPACITY } from "./core.ts";
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
};

/** Dim everything outside `people` (null clears it); see HighlightOptions for the extras. */
export function highlight(people: Set<string> | null, opts: HighlightOptions = {}): void {
    const { roles, path = [], step = null, hideOthers = false, dim = DIM } = opts;
    focus = people;
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
    const lit = (id: string) => !people || people.has(id) || unionsLit.has(id);
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
        setTarget(obj, lit(n.id) ? level(n.id) : out);
        if (obj?.userData.isUnion) obj.userData.scaleTarget = people && lit(n.id) ? 1.35 : 1; // couples stand out
        const pathRing = obj?.children.find((c) => c.userData.isPathRing);
        if (pathRing) pathRing.userData.dimTarget = onPath.has(n.id) && path.length > 1 ? 1 : 0;
        const sphere = obj?.children[0] as THREE.Mesh<THREE.BufferGeometry, THREE.MeshStandardMaterial> | undefined;
        if (!sphere?.material.emissive) continue;
        // Glow: the path's people in their own colour, the hovered step's two people brighter.
        sphere.userData.glow = onStep.has(n.id) ? 1.6 : onPath.has(n.id) && path.length > 1 ? 1 : 0;
        // Direction tint (only for a person's line, not a relationship path, which has its own gold).
        const side = path.length ? undefined : roles?.get(n.id)?.side;
        const tint =
            side === "ancestor"
                ? p.ancestor
                : side === "descendant"
                  ? p.descendant
                  : side === "sibling"
                    ? p.sibling
                    : null;
        sphere.userData.tint = tint;
        // The same colour as a ring, matching the panel's key exactly (the tint alone is mixed into the house colour).
        const lineRing = obj!.children.find((c) => c.userData.isLineRing) as THREE.Sprite | undefined;
        if (lineRing) {
            if (tint != null) lineRing.material.color.set(tint); // keep the old colour while fading out
            lineRing.userData.dimTarget = tint != null && lit(n.id) ? level(n.id) : 0;
        }
    }
    for (const l of boundLinks()) {
        const on = pathLinks.has(l) || (lit(endId(l.source)) && lit(endId(l.target)));
        const dim = on ? Math.min(level(endId(l.source)), level(endId(l.target))) : out;
        setTarget(l.__lineObj, dim);
        setTarget(l.__photonsObj, dim);
        if (l.__lineObj) l.__lineObj.userData.path = stepLinks.has(l) ? 2 : pathLinks.has(l) ? 1 : 0;
    }
    siblingPairs.forEach(([a, b], i) => setTarget(siblingLabels[i], lit(a.id) && lit(b.id) ? 1 : out));
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
export const clearFocus = () => (focus = null);

function setTarget(obj: THREE.Object3D | undefined, dim: number) {
    obj?.traverse((o) => (o.userData.dimTarget = dim));
}

const tintColour = new THREE.Color();
const stepGold = new THREE.Color();

// Ease every object's dim, glow and tint towards its target. Meshes and lines get opacity directly; labels keep the
// factor in userData.dim, which names.ts combines with the distance fade. Anything fully faded is made invisible, so
// focus mode also takes hidden people out of picking and drawing.
export function stepFades(dt: number): void {
    const k = 1 - Math.exp(-FADE_RATE * dt);
    const fadeObject = (root: THREE.Object3D | undefined) =>
        root?.traverse((o) => {
            const target = (o.userData.dimTarget ?? 1) as number;
            const dim = approach((o.userData.dim ?? 1) as number, target, k);
            o.userData.dim = Math.abs(dim - target) < 0.002 ? target : dim;
            // Labels are faded by names.ts, link lines below; everything else (spheres, badges, dots) here.
            if (o instanceof SpriteText || o.userData.isLinkLine) return;
            const m = (o as THREE.Mesh).material as THREE.Material | undefined;
            if (!m) return;
            o.visible = o.userData.dim > 0.01;
            m.transparent = true;
            m.userData.baseOpacity ??= m.opacity;
            m.opacity = o.userData.dim * (m.userData.baseOpacity as number);
            if (m instanceof THREE.MeshStandardMaterial) {
                const glow = approach((o.userData.glowNow ?? 0) as number, (o.userData.glow ?? 0) as number, k);
                o.userData.glowNow = glow;
                const tintOn = o.userData.tint == null ? 0 : 1;
                const tint = approach((o.userData.tintNow ?? 0) as number, tintOn, k);
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
            const s = approach((obj!.userData.scaleNow ?? 1) as number, (obj!.userData.scaleTarget ?? 1) as number, k);
            obj!.userData.scaleNow = s;
            unionRing.scale.setScalar(3.6 * s);
        }
    }
    const gold = palette().links.pathGlow;
    stepGold.set(palette().lineage.step);
    for (const l of boundLinks()) {
        fadeObject(l.__lineObj);
        fadeObject(l.__photonsObj); // the travelling dots: the library re-uses the template's material for them
        // Path links: brighter (full opacity, gold) and thicker than resting links; the hovered step more so.
        const line = l.__lineObj?.children[0] as
            THREE.Mesh<THREE.BufferGeometry, THREE.MeshLambertMaterial> | undefined;
        if (!line) continue;
        line.userData.isLinkLine = true;
        const p = approach((line.userData.pathNow ?? 0) as number, (l.__lineObj!.userData.path ?? 0) as number, k);
        line.userData.pathNow = p;
        const dim = (line.userData.dim ?? 1) as number;
        line.visible = dim > 0.01;
        line.material.opacity = dim * Math.min(1, LINK_OPACITY + (1 - LINK_OPACITY) * p);
        line.material.emissive.set(gold).multiplyScalar(0.6 * Math.min(p, 1));
        if (p > 1) line.material.emissive.lerp(stepGold, Math.min(1, p - 1));
        line.scale.x = line.scale.y = 1 + 1.6 * p;
    }
    siblingLabels.forEach(fadeObject);
    const sd = approach((siblings.userData.dim ?? 1) as number, (siblings.userData.dimTarget ?? 1) as number, k);
    siblings.userData.dim = sd;
    siblingMat.opacity = sd;
    siblings.visible = sd > 0.01;
}
