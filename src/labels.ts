// Text labels (three-spritetext) and the fonts they use.
import * as THREE from "three";
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

/**
 * Small round house badge: a disc in the house colour with the house's initial, drawn as a camera-facing sprite.
 * One texture per house (cached), shared by everyone in it. Original artwork: no real-world or franchise sigils.
 */
const badgeTextures = new Map<string, THREE.CanvasTexture>();
export function houseBadge(house: string, color: string): THREE.Sprite {
    const key = `${house}|${color}`;
    let tex = badgeTextures.get(key);
    if (!tex) {
        const c = document.createElement("canvas");
        c.width = c.height = 64;
        const g = c.getContext("2d")!;
        g.beginPath();
        g.arc(32, 32, 29, 0, Math.PI * 2);
        g.fillStyle = color;
        g.fill();
        g.lineWidth = 3;
        g.strokeStyle = "rgba(7,7,10,.85)";
        g.stroke();
        // Ink colour that reads on the disc: dark on light houses, light on dark ones.
        const [r, gg, b] = new THREE.Color(color).toArray();
        g.fillStyle = 0.299 * r + 0.587 * gg + 0.114 * b > 0.55 ? "#141318" : "#f4ead2";
        g.font = `700 34px ${DISPLAY_FONT}`;
        g.textAlign = "center";
        g.textBaseline = "middle";
        g.fillText(([...house.replace(/^(House|the)\s+/i, "")][0] ?? "?").toUpperCase(), 32, 34);
        tex = new THREE.CanvasTexture(c);
        tex.colorSpace = THREE.SRGBColorSpace;
        badgeTextures.set(key, tex);
    }
    const s = new THREE.Sprite(new THREE.SpriteMaterial({ map: tex, transparent: true, depthWrite: false }));
    s.scale.setScalar(3.2);
    s.userData.badge = true;
    return s;
}
/** Drop cached badge textures (e.g. after a GPU context loss, when they must be recreated). */
export function resetBadges(): void {
    for (const t of badgeTextures.values()) t.dispose();
    badgeTextures.clear();
}

/** Free a label's canvas texture and material (SpriteText creates one of each per label). */
export function disposeLabel(s: SpriteText): void {
    s.material.map?.dispose();
    s.material.dispose();
}
