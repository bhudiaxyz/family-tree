// Graph: the public entry point for the family tree as a three.js object.
//
// What it does: showTree() builds the nodes (people pinned to a row height, plus one union node per family) and links
// for a Tree, frames it (peopleBbox) and resets highlight and guides; stepGraph() advances everything once per frame.
// Usage: imported by app.ts and src/ui/*; re-exports the public parts of src/graph/. The parts:
//   core.ts       the graph instance, node/link objects, force layout, shared types and helpers
//   siblings.ts   dashed sibling lines and labels        guides.ts   "Row n" guides and labels
//   flat.ts       2D mode: depth squash, row spacing, sibling clustering
//   highlight.ts  dimming outside a line, path glow      names.ts    label fades, name de-overlap, relation tags
// Notes: showTree must dispose the previous tree's per-node materials before graphData() replaces them. The order in
// stepGraph matters: highlight fades set opacity targets that fadeLabels/declutter/stepNames then combine for labels.

import type * as THREE from "three";
import type { Tree } from "./data/schema.ts";
import { childLabel, parentLabel } from "./family.ts";
import { generations, type SiblingMode } from "./generations.ts";
import {
    boundLinks,
    boundNodes,
    disposeObject,
    graph,
    isShown,
    laneOffset,
    type Link,
    linkResolution,
    markLayoutRunning,
    type Node,
    useTree,
} from "./graph/core.ts";
import { drawnZ, setCouples, setFamilies, setSiblingGroups, setUnions, stepFlat } from "./graph/flat.ts";
import { setGuides, stepGuides } from "./graph/guides.ts";
import { clearFocus, stepFades } from "./graph/highlight.ts";
import { declutter, fadeLabels, stepNames } from "./graph/names.ts";
import { setSiblings, updateSiblings } from "./graph/siblings.ts";

export { endId, graph, isShown, layoutRunning, type Link, type Node } from "./graph/core.ts";
export { drawnZ, setFlat, setRightAngles } from "./graph/flat.ts";
export { generationRows, onRowPicked, setGuidesVisible } from "./graph/guides.ts";
export { type HighlightOptions, highlight, setFolded } from "./graph/highlight.ts";
export { setFoldBadges, setRelativeTags } from "./graph/names.ts";

// Vertical gap between generations (world units). The same in 2D and 3D, so switching never moves rows; 110 (it was
// 80) leaves 2D's right-angled connectors a long drop to each child, with its "son"/"daughter" label clear of names.
const GEN_GAP = 110;

let rowOf = new Map<string, number>();
let rowCount = 0;
/** A person's generation row (0 = oldest) in the shown tree, and how many rows there are. */
export const generationOf = (id: string) => ({ row: rowOf.get(id) ?? 0, of: rowCount });

/** Replace the displayed tree. Generations are pinned to fixed heights; union nodes sit half a row below parents. */
export function showTree(t: Tree, mode: SiblingMode = "together"): void {
    useTree(t);
    const gen = generations(t, mode);
    const rows = Math.max(0, ...gen.values());
    rowOf = gen;
    rowCount = rows + 1;
    const y = (g: number) => (rows / 2 - g) * GEN_GAP;

    const seed = seedX(t, gen);
    const nodes: Node[] = Object.entries(t.people).map(([id, p]) => ({
        id,
        ...p,
        fy: y(gen.get(id)!),
        // Seeded in family order (seedX). All three must be set: d3 re-places a node at random if any is missing, and
        // a frame drawn before d3's first tick would frame the camera on an undefined y (NaN: a blank view for good).
        x: seed.get(id),
        y: y(gen.get(id)!),
        z: 0,
    }));
    const mean = (ids: string[]) => ids.reduce((s, id) => s + seed.get(id)!, 0) / ids.length;
    const links: Link[] = [];
    const pairs: [string, string][] = [];
    const lanesUsed = new Map<number, number>(); // per parent row
    t.families.forEach((f, i) => {
        // One parent and no children (common in imported GEDCOM files) is a link to a dot leading nowhere: skip it.
        if (f.parents.length + f.children.length < 2) return;
        const u = `family${i}`;
        const parentRow = f.parents.length
            ? gen.get(f.parents[0])!
            : f.children.length
              ? Math.min(...f.children.map((c) => gen.get(c)!)) - 1
              : 0;
        // Families on the same row take lanes in turn (file order keeps neighbours apart): the union sits a little
        // above or below the half row, so neighbouring families' 2D bars, drawn from it, never coincide.
        const lane = lanesUsed.get(parentRow) ?? 0;
        lanesUsed.set(parentRow, lane + 1);
        const uy = y(parentRow + 0.5) + laneOffset(lane);
        nodes.push({
            id: u,
            fy: uy,
            x: mean([...f.parents, ...f.children]),
            y: uy,
            z: 0,
        });
        for (const p of f.parents) links.push({ source: p, target: u, kind: "spouse", label: parentLabel(t, p, f) });
        for (const c of f.children) links.push({ source: u, target: c, kind: "child", label: childLabel(t, c, f) });
        // Chain consecutive siblings rather than all pairs, to keep large families readable.
        for (let k = 1; k < f.children.length; k++) pairs.push([f.children[k - 1], f.children[k]]);
    });

    // Free the previous tree's per-node materials and label textures before the library drops the objects.
    for (const n of boundNodes()) disposeObject(n.__threeObj);
    for (const l of boundLinks()) {
        disposeObject(l.__lineObj); // the line's material and buffer, and the label
        disposeObject(l.__photonsObj?.children[0]); // the dots share one material per link
    }

    const byId = new Map(nodes.map((n) => [n.id, n]));
    setSiblingGroups(t.families.filter((f) => f.children.length > 1).map((f) => f.children.map((c) => byId.get(c)!)));
    setCouples(
        t.families
            .filter((f) => f.parents.length === 2 && gen.get(f.parents[0]) === gen.get(f.parents[1]))
            .map((f) => [byId.get(f.parents[0])!, byId.get(f.parents[1])!])
    );
    setFamilies(
        t.families
            .filter((f) => f.parents.length && f.children.length)
            .map((f) => ({
                parents: f.parents.map((p) => byId.get(p)!),
                children: f.children.map((c) => byId.get(c)!),
            }))
    );
    setUnions(
        t.families.flatMap((f, i) =>
            f.parents.length && byId.has(`family${i}`)
                ? [{ union: byId.get(`family${i}`)!, parents: f.parents.map((p) => byId.get(p)!) }]
                : []
        )
    );
    setSiblings(t, byId, pairs);
    setGuides(rows, y);
    markLayoutRunning();
    graph.graphData({ nodes, links });
    clearFocus();
}

// --- Starting order along each row ----------------------------------------------------------------------------------
// The forces only nudge people sideways, and names can't pass through each other (spreadRows), so whatever order the
// layout starts in is roughly the order it ends in. Started at random, couples were split by strangers and brothers
// and sisters scattered. So each row starts in family order: walk the tree from the oldest row down; a person is
// placed with their spouses beside them, and each family's children are placed together, in the order of their
// parents above, so a couple starts over its own children. A new group (not a spouse or sibling of the one before)
// starts SEED_GROUP further along. Each row is then centred. The forces refine this; they don't have to find it.
const SEED_STEP = 26; // world units between neighbours in a group
const SEED_GROUP = 34; // extra space before a new group
function seedX(t: Tree, gen: Map<string, number>): Map<string, number> {
    const asParent = new Map<string, Tree["families"]>();
    for (const f of t.families) for (const p of f.parents) asParent.set(p, [...(asParent.get(p) ?? []), f]);
    const isChild = new Set(t.families.flatMap((f) => f.children));
    const spouses = (id: string) =>
        (asParent.get(id) ?? []).flatMap((f) => f.parents).filter((p) => p !== id && gen.get(p) === gen.get(id));
    const x = new Map<string, number>();
    const next = new Map<number, number>(); // the next free x on each row
    const place = (id: string, newGroup: boolean) => {
        if (x.has(id)) return;
        const row = gen.get(id)!;
        const at = next.get(row);
        const pos = at === undefined ? 0 : at + (newGroup ? SEED_GROUP : 0);
        x.set(id, pos);
        next.set(row, pos + SEED_STEP);
        for (const s of spouses(id)) place(s, false);
    };
    const ids = Object.keys(t.people);
    const done = new Set<Tree["families"][number]>();
    for (let row = 0; row <= Math.max(0, ...gen.values()); row++) {
        const inRow = ids.filter((id) => gen.get(id) === row);
        // People with no parents recorded, unless they married someone who has (they're placed beside them).
        for (const id of inRow) if (!isChild.has(id) && spouses(id).every((s) => !isChild.has(s))) place(id, true);
        for (const id of inRow) place(id, true); // anyone still left (a spouse placed nowhere else)
        for (const id of inRow.sort((a, b) => x.get(a)! - x.get(b)!))
            for (const f of asParent.get(id) ?? []) {
                if (done.has(f)) continue;
                done.add(f);
                f.children.forEach((c, i) => place(c, i === 0));
            }
    }
    for (const id of ids) place(id, true); // defensive: anyone without a row walk (shouldn't happen)
    const span = new Map<number, [number, number]>();
    for (const [id, v] of x) {
        const r = gen.get(id)!;
        const [lo, hi] = span.get(r) ?? [v, v];
        span.set(r, [Math.min(lo, v), Math.max(hi, v)]);
    }
    for (const [id, v] of x) {
        const [lo, hi] = span.get(gen.get(id)!)!;
        x.set(id, v - (lo + hi) / 2);
    }
    return x;
}

/**
 * Box around the people (not union nodes or guides), for framing the camera. Uses the 5th–95th percentile on each
 * axis, so one stray family off to the side doesn't push the whole view out; padded by a person's radius and label.
 * Null until the layout has placed anyone.
 */
export function peopleBbox(): { x: [number, number]; y: [number, number]; z: [number, number] } | null {
    // In focus mode, only the people still shown, so the camera closes in on the highlighted line.
    const pts = boundNodes().filter((n) => n.name && n.x !== undefined && isShown(n));
    if (!pts.length) return null;
    const range = (k: "x" | "y" | "z", lo = 0.05, hi = 0.95): [number, number] => {
        const v = pts.map((n) => n[k]!).sort((a, b) => a - b);
        const at = (q: number) => v[Math.min(v.length - 1, Math.max(0, Math.round(q * (v.length - 1))))];
        return [at(lo), at(hi)];
    };
    // Width: trim the 5% stragglers on wide screens, where it tightens the view. On a portrait phone, though, width is
    // the binding constraint, so trimming it pushes those people off the sides (measured: 39 of 42 visible); keep all.
    const portrait = innerWidth < innerHeight;
    const x = portrait ? range("x", 0, 1) : range("x");
    const z = range("z").map(drawnZ) as [number, number];
    // Vertical extent uses every person: generations are few and pinned, so there are no stray rows to ignore, and
    // cutting the top/bottom row would hide a whole generation. Pad for the name label above and badge below.
    const y = range("y", 0, 1);
    // Never frame tighter than about one person with their family around them: a focus mode can leave a single person
    // (Cersei has no recorded cousins), and fitting their bare sphere put the camera a few units from it.
    const atLeast = ([lo, hi]: [number, number], min: number): [number, number] => {
        const grow = Math.max(0, min - (hi - lo)) / 2;
        return [lo - grow, hi + grow];
    };
    return { x: atLeast([x[0] - 6, x[1] + 6], MIN_FRAME_W), y: atLeast([y[0] - 9, y[1] + 16], MIN_FRAME_H), z };
}
const MIN_FRAME_W = 120; // world units; a generation row is 110 apart
const MIN_FRAME_H = 130;

/** Live node for a person (its position is updated by the simulation), if the tree has been laid out. */
export const nodeById = (id: string): Node | undefined => graph.graphData().nodes.find((n) => n.id === id);

/** Advance the simulation, highlight fades and overlays by one frame. */
export function stepGraph(
    camera: THREE.PerspectiveCamera,
    target: THREE.Vector3,
    dt: number,
    now: number,
    viewW: number,
    viewH: number
): void {
    linkResolution.set(viewW, viewH); // fat link lines are sized in CSS px against this
    graph.tickFrame();
    stepFlat(dt);
    updateSiblings();
    stepFades(dt);
    fadeLabels(camera);
    declutter(camera, viewW, viewH, now);
    stepNames(dt);
    stepGuides(camera, target, viewH);
}
