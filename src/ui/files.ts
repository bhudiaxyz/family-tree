// Files in and out: save the view as a PNG, and import a GEDCOM file (file picker, or drag a .ged onto the window).
import { parseGedcom } from "../data/gedcom.ts";
import { palette } from "../palettes.ts";
import { captureView } from "../scene.ts";
import { $ } from "./dom.ts";
import { showImported } from "./sagas.ts";
import { notify, state } from "./state.ts";

// --- PNG export -----------------------------------------------------------------------------------------------------
export async function savePng(): Promise<void> {
    const { tree } = state;
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
        const a = Object.assign(document.createElement("a"), {
            href: URL.createObjectURL(blob),
            download: `${(tree?.title ?? "family-tree").replace(/[^\w-]+/g, "-").toLowerCase()}.png`,
        });
        a.click();
        setTimeout(() => URL.revokeObjectURL(a.href), 10_000);
        notify("Saved the current view as a PNG.");
    } catch (e) {
        notify(`Couldn't save the image: ${(e as Error).message}`, true);
    }
}
$("btn-png").onclick = savePng;

// --- GEDCOM import --------------------------------------------------------------------------------------------------
const fileInput = $<HTMLInputElement>("file");
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

async function importFile(file: File) {
    if (file.size > 20 * 1024 * 1024)
        return notify("That file is larger than 20 MB; GEDCOM files are usually far smaller.", true);
    try {
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
