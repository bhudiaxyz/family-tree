// Links: how each family line is built and where it goes, straight in 3D and right-angled in 2D.
//
// What it does: builds a link's line (a fat screen-space LineSegments2 with its own material, so it fades on its own
// and keeps a constant pixel width at any zoom) and its path glow (linkGlow); placeLink() writes a link's three
// segments and positions its label: a straight line in 3D, or a right-angled family-tree connector in 2D, where a
// parent's line drops from under their badge and runs across to the marriage node, and a child's line drops below
// it, runs across and down to just above the child's name. laneOffset() is how far each family's marriage node sits
// above or below the half row, so neighbouring families' bars never coincide.
// Usage: core.ts builds and places links through the graph library (linkThreeObject, linkPositionUpdate) and owns
// setElbowLinks (re-placing every link); highlight.ts styles lines with LINK_PX and LINK_OPACITY; graph.ts sets
// linkResolution each frame and pins marriage nodes with laneOffset.
// Notes: nothing imported from core.ts (types come from graph-types.ts), so the two don't import each other. A link object is a Group
// of [line, label, glow], in that order (highlight.ts and names.ts index it). linkResolution must hold the view size in
// CSS px, or line widths and link picking (picking.ts, raycasting LineSegments2) are wrong. Every link is three
// segments, so its buffer is written in place and never resized.

import * as THREE from "three";
import { LineMaterial } from "three/addons/lines/LineMaterial.js";
import { LineSegments2 } from "three/addons/lines/LineSegments2.js";
import { LineSegmentsGeometry } from "three/addons/lines/LineSegmentsGeometry.js";
import { palette } from "../render/palettes.ts";
import type { Link } from "./graph-types.ts";

type Pos = { x?: number; y?: number; z?: number };

export const LINK_OPACITY = 0.45; // resting opacity of family links (the library default, 0.2, is too faint at a distance)

// Links are drawn this many CSS px wide at any distance. The old 0.6-unit cylinders thinned to broken, shimmering
// sub-pixel lines when zoomed out; a screen-space width stays crisp and visible. Path links are wider (highlight.ts).
export const LINK_PX = 1.6;

/** The view size in CSS px, shared by every link material (fat lines need it); set each frame by stepGraph. */
export const linkResolution = new THREE.Vector2(innerWidth, innerHeight);

// --- Where a link and its label go -----------------------------------------------------------------------------------
// Every link is three segments (four points), so its buffer never needs resizing: in 3D a straight line split in
// thirds; in 2D a right-angled family-tree connector. In 2D a parent drops from under their badge and runs across to
// the union, so a couple reads as joined by a bar; a child link drops below the union, runs across to above the child
// and down to just over their name, so brothers and sisters hang off one shared bar.
// Lanes: if every couple's bar sat at its union's height (and every sibling bar the same drop below it), neighbouring
// families' horizontal runs lay on top of each other and you couldn't tell whose mother line was whose. So each
// family on a row gets a lane (graph.ts assigns them in turn): its union node is pinned at that lane's height
// (laneOffset), and both its bars are drawn from the union, so the lines always meet at the dot.
const SEGMENTS = 3;

const BELOW_BADGE = 8; // a parent's line starts under their house badge (it sits 6.2 below centre, 3.2 across)
const ABOVE_NAME = 15.5; // a child's line ends above their name (two lines centred on NAME_Y)
const BAR_DROP = 6; // the sibling bar sits just under the union, so the drop to each child is long (2D rows are

// taller too, graph.ts GEN_GAP): its "son"/"daughter" label then sits clear of the names
export const LANES = 4; // bar heights per row, so up to four neighbouring families' bars never coincide

const LANE_GAP = 6; // world units between lanes (a row is 110; the union sits about 55 below its parents)
const LABEL_REACH = 20; // world units along a straight link from its person; half an ordinary link
let elbows = false;
const pts = new Float32Array((SEGMENTS + 1) * 3);

export function linkLine(l: Link): LineSegments2 {
    const geometry = new LineSegmentsGeometry();
    geometry.setPositions(new Float32Array(SEGMENTS * 6)); // written in place by placeLink
    const material = new LineMaterial({
        color: l.kind === "spouse" ? palette().links.spouse : palette().links.child,
        linewidth: LINK_PX,
        transparent: true,
        opacity: LINK_OPACITY,
        depthWrite: false,
        fog: true,
    });
    material.uniforms.resolution.value = linkResolution; // one shared vector, updated each frame
    material.userData.base = material.color.clone(); // highlight.ts tints towards gold from this
    const line = new LineSegments2(geometry, material);
    line.userData.isLinkLine = true;
    line.userData.ownGeometry = true; // disposeObject frees it (other geometries are shared)
    line.userData.link = l; // picking.ts: which link the pointer is on
    return line;
}

/**
 * A wide, faint, additive copy of a link line (sharing its buffer), shown under a relationship path so the route
 * glows without the Glow option. Hidden at rest; highlight.ts fades it with the path.
 */
export function linkGlow(line: LineSegments2): LineSegments2 {
    const material = new LineMaterial({
        color: palette().links.pathGlow,
        linewidth: LINK_PX * 6,
        transparent: true,
        opacity: 0,
        depthWrite: false,
        blending: THREE.AdditiveBlending,
        fog: true,
    });
    material.uniforms.resolution.value = linkResolution;
    const glow = new LineSegments2(line.geometry, material);
    glow.userData.isLinkLine = true; // faded by highlight.ts's link pass, not the generic one
    glow.visible = false;
    return glow;
}

/** How far a family's union node sits above (+) or below (−) the half-row height, for its lane. */
export const laneOffset = (lane: number) => ((lane % LANES) - (LANES - 1) / 2) * LANE_GAP;

/** Draw links as right-angled connectors (2D) or straight (3D); core.ts setElbowLinks re-places them. */
export const useElbows = (on: boolean) => (elbows = on);

/** True while links are drawn as right-angled connectors. */
export const elbowLinks = () => elbows;

const put = (i: number, x: number, y: number, z: number) => pts.set([x, y, z], i * 3);

export function placeLink(line: LineSegments2, label: THREE.Object3D, start: Pos, end: Pos, l: Link): void {
    const [a, b] = [start as Required<Pos>, end as Required<Pos>];
    const kind = l.kind;
    if (elbows && kind === "child") {
        // a = union, b = child: down a little from the union, across, and down to just above the child's name
        const top = b.y + ABOVE_NAME;
        const bar = Math.max(top, a.y - BAR_DROP);
        put(0, a.x, a.y, a.z);
        put(1, a.x, bar, a.z);
        put(2, b.x, bar, b.z);
        put(3, b.x, top, b.z);
        label.position.set(b.x, (bar + top) / 2, b.z);
    } else if (elbows) {
        // a = parent, b = union: down from the parent to the union's height and across to it; the bar is split in two
        // to make the third segment
        const from = a.y - BELOW_BADGE;
        put(0, a.x, from, a.z);
        put(1, a.x, b.y, a.z);
        put(2, (a.x + b.x) / 2, b.y, (a.z + b.z) / 2);
        put(3, b.x, b.y, b.z);
        label.position.set(a.x, (from + b.y) / 2, a.z);
    } else {
        for (let i = 0; i <= SEGMENTS; i++) {
            const t = i / SEGMENTS;
            put(i, a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t, a.z + (b.z - a.z) * t);
        }
        // A label sits beside the person it describes: "son"/"daughter" near the child, "father"/"mother"/"wife" near
        // the parent, at most LABEL_REACH along the link. On an ordinary link (half a row, 40 units) that's its
        // midpoint. A link across several rows (Ginny sits with Harry, two rows below Arthur and Molly) used to put
        // its label at the midpoint, among her brothers, where "daughter" read as Bill's.
        const [near, far] = kind === "child" ? [b, a] : [a, b]; // child links run union → child; spouse parent → union
        const len = Math.hypot(far.x - near.x, far.y - near.y, far.z - near.z);
        const t = len > 0 ? Math.min(0.5, LABEL_REACH / len) : 0.5;
        label.position.set(near.x + (far.x - near.x) * t, near.y + (far.y - near.y) * t, near.z + (far.z - near.z) * t);
    }
    // Segment s runs from point s to point s + 1, so the interleaved buffer is the points with each inner one twice.
    const start3 = line.geometry.attributes.instanceStart as THREE.InterleavedBufferAttribute;
    const buf = start3.data.array as Float32Array;
    for (let s = 0; s < SEGMENTS; s++) for (let j = 0; j < 6; j++) buf[s * 6 + j] = pts[s * 3 + j];
    start3.data.needsUpdate = true;
    line.geometry.computeBoundingSphere(); // culling and picking use it
}
