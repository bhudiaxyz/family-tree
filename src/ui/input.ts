// Input: keyboard shortcuts and the on-screen touch pad.
//
// What it does: maps keys to actions (/ search, ? help, C chart, T tour, R relate, P save PNG, F fit, G family, + -
// zoom, Page Up/Down generation, M minimap, L line focus, Backspace back, Escape, arrows pan, Shift or Ctrl + arrows
// rotate, Alt + arrows move to a relative) and wires the pad's buttons (hold to pan, fit, zoom).
// Usage: no exports. A side-effect module: app.ts imports it for its listeners. It is also what pulls in guide.ts,
// files.ts and minimap.ts.
// Notes: shortcuts are ignored while typing in an input. Escape is handled twice: a capture-phase listener ends a
// tour before any input can take the key, then the main handler closes the finder, deselects, clears the house, then
// the group, in that order. Panning stops on keyup and on window blur. Keep the help dialog in index.html in sync
// with the keys here.

import { type Dir, fitTree, holdPan, nudgeRotate, releaseAllPans, releasePan } from "../camera.ts";
import { relatePanel, search } from "./dom.ts";
import { savePng } from "./files.ts";
import { endTour, openChart, startTour, toggleHelp, touring } from "./guide.ts";
import { setHouse } from "./legend.ts";
import { toggleMinimap } from "./minimap.ts";
import { fitFamily, stepGeneration, zoomIn, zoomOut } from "./navigate.ts";
import { setFocus } from "./visibility.ts";
import { clearGroup, deselect, goBack, stepToRelative } from "./panel.ts";
import { closeRelate, toggleRelate } from "./relate.ts";
import { state } from "./state.ts";

// --- Keyboard -------------------------------------------------------------------------------------------------------
const KEY_DIR: Record<string, Dir> = { ArrowLeft: "left", ArrowRight: "right", ArrowUp: "up", ArrowDown: "down" };
const typing = () => document.activeElement instanceof HTMLInputElement;
// Escape ends a tour wherever the focus is, before an input or its suggestion list can take the key (capture phase).
addEventListener(
    "keydown",
    (e) => {
        if (e.key !== "Escape" || !touring()) return;
        e.stopImmediatePropagation(); // one Escape, one thing: end the tour, don't also deselect
        endTour();
    },
    { capture: true }
);
addEventListener("keydown", (e) => {
    // Alt + arrows: move to a relative of the selected person (up: parent, down: child, left/right: sibling).
    if (e.altKey && !typing() && KEY_DIR[e.key] && state.selected)
        return (e.preventDefault(), stepToRelative(KEY_DIR[e.key]));
    if (typing() || e.ctrlKey || e.metaKey || e.altKey) {
        if (!typing() && KEY_DIR[e.key] && (e.ctrlKey || e.metaKey)) (e.preventDefault(), nudgeRotate(KEY_DIR[e.key]));
        return;
    }
    if (e.key === "/") return (e.preventDefault(), search.focus());
    if (e.key === "?") return (e.preventDefault(), toggleHelp());
    if ((e.key === "c" || e.key === "C") && state.selected) return openChart();
    if (e.key === "t" || e.key === "T") return touring() ? endTour() : startTour();
    if (e.key === "r" || e.key === "R") return (e.preventDefault(), toggleRelate());
    if (e.key === "p" || e.key === "P") return (e.preventDefault(), void savePng());
    if (e.key === "f" || e.key === "F") return fitTree();
    // G: frame the selected person's immediate family. + / -: zoom. Page Up / Down: a generation older / younger.
    if ((e.key === "g" || e.key === "G") && state.selected) return fitFamily();
    if (e.key === "+" || e.key === "=") return (e.preventDefault(), zoomIn());
    if (e.key === "-" || e.key === "_") return (e.preventDefault(), zoomOut());
    if (e.key === "PageUp" || e.key === "PageDown")
        return (e.preventDefault(), stepGeneration(e.key === "PageUp" ? -1 : 1));
    if (e.key === "m" || e.key === "M") return toggleMinimap();
    // L: show only this person's line, or everyone again. Backspace: back to the person before.
    if ((e.key === "l" || e.key === "L") && state.selected) return setFocus(state.focus === "off" ? "all" : "off");
    if (e.key === "Backspace" && state.selected) return (e.preventDefault(), goBack());
    if (e.key === "Escape") {
        if (!relatePanel.hidden) return closeRelate();
        if (state.selected) return deselect();
        if (state.house) return setHouse(null);
        if (state.group) return clearGroup();
        return;
    }
    const dir = KEY_DIR[e.key];
    if (!dir) return;
    e.preventDefault(); // stop the page scrolling
    if (e.shiftKey) nudgeRotate(dir);
    else holdPan(dir);
});
addEventListener("keyup", (e) => {
    const dir = KEY_DIR[e.key];
    if (dir) releasePan(dir);
});
addEventListener("blur", releaseAllPans); // don't keep panning if the window loses focus mid-press

// --- Touch pad: press and hold to pan; pointer capture keeps it working when the finger slides off ----------------
for (const btn of document.querySelectorAll<HTMLButtonElement>("#pad button[data-dir]")) {
    const dir = btn.dataset.dir as Dir;
    btn.addEventListener("pointerdown", (e) => {
        btn.setPointerCapture(e.pointerId);
        holdPan(dir);
    });
    for (const ev of ["pointerup", "pointercancel", "lostpointercapture"])
        btn.addEventListener(ev, () => releasePan(dir));
}
document.querySelector<HTMLButtonElement>("#pad [data-action=fit]")!.onclick = fitTree;
document.querySelector<HTMLButtonElement>("#pad [data-action=zoom-in]")!.onclick = zoomIn;
document.querySelector<HTMLButtonElement>("#pad [data-action=zoom-out]")!.onclick = zoomOut;
