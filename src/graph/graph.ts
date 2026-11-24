// Graph: the public entry point for the family tree as a three.js object.
//
// What it does: showTree() builds the nodes (people pinned to a row height, plus one union node per family) and links
// for a Tree, frames it (peopleBbox) and resets highlight and guides; stepGraph() advances everything once per frame.
// Usage: imported by main.ts and src/ui/*; re-exports the public parts of src/graph/. The parts:
//   core.ts         the graph instance, person and marriage-node objects, physics settings
//   graph-types.ts  shared node and link types and small helpers
//   links.ts        link lines, path glow, straight and right-angled geometry
//   forces.ts       row forces: name spacing, siblings, couples, parents over children, marriage nodes
//   flat.ts         2D mode: depth squash and the right-angled link switch
//   highlight.ts    dimming outside a line, path glow     names.ts     label fades, name de-overlap, relation tags
//   siblings.ts     dashed sibling lines and labels        guides.ts    "Row n" guides and labels
// Notes: showTree must dispose the previous tree's per-node materials before graphData() replaces them. The order in
// stepGraph matters: highlight fades set opacity targets that fadeLabels/declutter/stepNames then combine for labels.

import type * as THREE from "three";
import type { Tree } from "../data/schema.ts";
import { childLabel, parentLabel } from "../tree/family.ts";
import { generations, type SiblingMode } from "../tree/generations.ts";
import { rowOrder } from "../tree/row-order.ts";
import { boundLinks, boundNodes, disposeObject, graph, isShown, markLayoutRunning, useTree } from "./core.ts";
import { type Link, type Node } from "./graph-types.ts";
import { drawnZ, stepFlat } from "./flat.ts";
import { elbowLinks, laneOffset, linkResolution } from "./links.ts";
import { setCouples, setFamilies, setSiblingGroups, setUnions } from "./forces.ts";
import { setGuides, stepGuides } from "./guides.ts";
import { clearFocus, stepFades } from "./highlight.ts";
import { declutter, fadeLabels, stepNames } from "./names.ts";
import { setSiblings, siblings, updateSiblings } from "./siblings.ts";
export { graph, isShown, layoutRunning } from "./core.ts";
export { endId, type Link, type Node } from "./graph-types.ts";
export { drawnZ, setFlat, setRightAngles } from "./flat.ts";
export { generationRows, onRowPicked, setGuidesVisible } from "./guides.ts";
export { type HighlightOptions, highlight, setFolded, setHoverLink } from "./highlight.ts";
export { setFoldBadges, setRelativeTags } from "./names.ts";

// Vertical gap between generations (world units). The same in 2D and 3D, so switching never moves rows; 110 (it was
// 80) leaves 2D's right-angled connectors a long drop to each child, with its "son"/"daughter" label clear of names.
const GEN_GAP = 110;

let rowOf = new Map<string, number>();
let rowCount = 0;
const MIN_FRAME_W = 120; // world units; a generation row is 110 apart
const MIN_FRAME_H = 130;

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

    const seed = rowOrder(t, gen);
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
    // Right-angled connectors already show brothers and sisters hanging off one bar: the dashed sibling lines and
    // their "brothers" labels only cluttered the name row, so they're hidden then (3D and straight 2D keep them).
    siblings.visible = !elbowLinks() && ((siblings.userData.dim ?? 1) as number) > 0.01;
    fadeLabels(camera);
    declutter(camera, viewW, viewH, now);
    stepNames(dt);
    stepGuides(camera, target, viewH);
}
