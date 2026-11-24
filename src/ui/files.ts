// Files: saving the view as a PNG, and importing a GEDCOM or saga JSON file.
//
// What it does: `savePng` captures the view (a Save dialog where `showSaveFilePicker` exists, else a name prompt and
// a download); import takes a file from the picker or a .ged or .json dropped on the window, parses it and shows it.
// Usage: input.ts calls savePng (P); imports are displayed through showImported (sagas.ts). The import buttons and
// drop handlers are attached at import time, so this is loaded through input.ts.
// Notes: the save picker is asked for first because it needs the click or keypress that started it, which expires
// during capture. An imported tree has the saga id IMPORTED, so it is not shareable by URL and uses the default theme.
// #btn-png, #btn-import and #file must match index.html.

import { parseGedcom } from "../data/gedcom.ts";
import { toRecord, toTree } from "../data/source.ts";
import { palette } from "../render/palettes.ts";
import { captureView } from "../render/scene.ts";
import { $, el, notify, state } from "./state.ts";
import { showImported } from "./sagas.ts";

// --- PNG export -----------------------------------------------------------------------------------------------------
type SaveHandle = { createWritable(): Promise<{ write(b: Blob): Promise<void>; close(): Promise<void> }> };

type SavePicker = (o: object) => Promise<SaveHandle>;

// --- GEDCOM import --------------------------------------------------------------------------------------------------
const fileInput = $<HTMLInputElement>("file");

export async function savePng(): Promise<void> {
    const { tree } = state;
    const suggested = `${(tree?.title ?? "family-tree").replace(/[^\w-]+/g, "-").toLowerCase()}.png`;
    // Ask where to save first: the picker needs the click/keypress that started this, which expires during capture.
    // Chromium has a real Save dialog (name + folder); elsewhere, ask for a name and download to the usual folder.
    const picker = (window as unknown as { showSaveFilePicker?: SavePicker }).showSaveFilePicker;
    let handle: SaveHandle | undefined;
    let name = suggested;
    try {
        if (picker)
            handle = await picker({
                suggestedName: suggested,
                types: [{ description: "PNG image", accept: { "image/png": [".png"] } }],
            });
        else {
            const answer = prompt("Save the image as:", suggested)?.trim();
            if (!answer) return;
            name = /\.png$/i.test(answer) ? answer : `${answer}.png`;
        }
    } catch (e) {
        if ((e as Error).name === "AbortError") return; // cancelled the dialog
        return notify(`Couldn't save the image: ${(e as Error).message}`, true);
    }
    try {
        const blob = await captureView(2, (g, w) => {
            // Stamp the saga title and author in the corner so a saved image is self-explanatory.
            const s = w / innerWidth;
            g.textBaseline = "top";
            g.shadowColor = palette().png.shadow;
            g.shadowBlur = 6 * s;
            g.fillStyle = palette().png.title;
            g.font = `700 ${24 * s}px "Roboto Condensed", "Arial Narrow", Arial, sans-serif`;
            g.fillText((tree?.title ?? "Family tree").toUpperCase(), 20 * s, 16 * s);
            g.fillStyle = palette().png.author;
            g.font = `italic ${13 * s}px Roboto, Arial, sans-serif`;
            g.fillText(tree?.author ?? "", 20 * s, 46 * s);
        });
        if (handle) {
            const out = await handle.createWritable();
            await out.write(blob);
            await out.close();
        } else {
            const a = el("a", { href: URL.createObjectURL(blob), download: name });
            a.click();
            setTimeout(() => URL.revokeObjectURL(a.href), 10_000);
        }
        notify("Saved the current view as a PNG.");
    } catch (e) {
        notify(`Couldn't save the image: ${(e as Error).message}`, true);
    }
}

async function importFile(file: File) {
    if (file.size > 20 * 1024 * 1024)
        return notify("That file is larger than 20 MB; GEDCOM files are usually far smaller.", true);
    try {
        // A saga file in the app's own JSON format (public/data/<category>/<id>.json), checked as the app's own are.
        if (/\.json$/i.test(file.name)) {
            const data = JSON.parse(await file.text());
            if (!Array.isArray(data?.people) || !Array.isArray(data?.families) || typeof data.houses !== "object")
                throw new Error("not a saga file (expected people, families and houses)");
            const t = toTree(toRecord(data));
            showImported(t);
            const n = Object.keys(t.people).length;
            return notify(`Opened ${t.title}: ${n} ${n === 1 ? "person" : "people"} from ${file.name}.`);
        }
        const { tree: t, warnings } = parseGedcom(await file.text(), file.name.replace(/\.(ged|gedcom)$/i, ""));
        showImported(t);
        const n = Object.keys(t.people).length;
        notify(
            `Imported ${n} ${n === 1 ? "person" : "people"} from ${file.name}` +
                (warnings.length ? ` (${warnings.length} warnings, see console)` : ".")
        );
        if (warnings.length) console.warn("GEDCOM import warnings:\n" + warnings.join("\n"));
    } catch (e) {
        notify(`Couldn't import ${file.name}: ${(e as Error).message}`, true);
    }
}

$("btn-png").onclick = savePng;
$("btn-import").onclick = () => fileInput.click();

fileInput.onchange = () => {
    const f = fileInput.files?.[0];
    if (f) importFile(f);
    fileInput.value = ""; // allow re-importing the same file
};

addEventListener("dragover", (e) => {
    if (e.dataTransfer?.types.includes("Files")) e.preventDefault();
});

addEventListener("drop", (e) => {
    const f = e.dataTransfer?.files[0];
    if (!f) return;
    e.preventDefault();
    importFile(f);
});
