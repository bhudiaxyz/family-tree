// Text labels (three-spritetext) and the fonts they use.
import SpriteText from "three-spritetext";

// Must match the Google Fonts families loaded in index.html and --fd / --fb in style.css.
const DISPLAY_FONT = '"Roboto Condensed", "Arial Narrow", Arial, sans-serif';
const BODY_FONT = 'Roboto, "Helvetica Neue", Arial, sans-serif';

/**
 * Resolves once the web fonts are ready, or after 3 s if the font CDN is slow or blocked (labels then use the
 * fallback fonts). SpriteText rasterises to a canvas once, so no label may be built before this resolves.
 */
export const fontsReady: Promise<unknown> = Promise.race([
    Promise.all(["700 16px 'Roboto Condensed'", "500 16px Roboto"].map((f) => document.fonts.load(f))),
    new Promise((r) => setTimeout(r, 3000)),
]);

/** Person name, shown above their sphere. */
export function nameLabel(text: string): SpriteText {
    const s = new SpriteText(text, 4, "#e8dcc1");
    s.fontFace = DISPLAY_FONT;
    s.fontWeight = "700";
    return s;
}

/** Relationship label (mother, son, sisters…) on a translucent dark backing. */
export function relationLabel(text: string, color: string): SpriteText {
    const s = new SpriteText(text, 2, color);
    s.fontFace = BODY_FONT;
    s.fontWeight = "500";
    s.backgroundColor = "rgba(7,7,10,.7)";
    s.padding = 0.6;
    return s;
}

/** Free a label's canvas texture and material (SpriteText creates one of each per label). */
export function disposeLabel(s: SpriteText): void {
    s.material.map?.dispose();
    s.material.dispose();
}
