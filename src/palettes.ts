// Colour themes for the 3D scene: links, labels, lights, fog, background and the procedural nebula.
//
// One Palette per look. `paletteFor(sagaId)` picks the theme for a saga, so each family tree can later get its own
// colours (e.g. icy blues for one saga, embers for another) by adding an entry to SAGA_PALETTES. Everything that
// draws in 3D reads its colours from here; nothing in graph.ts / scene.ts / labels.ts / nebula.ts hardcodes one.
//
// Not covered here: the HTML UI (header, panels, buttons), whose colours are CSS variables in src/style.css. Where
// the two must agree (the gold accent, the ink colour) the matching CSS variable is noted on the field.
//
// House colours (one per family/house) live in each saga's data file, not here: they are part of the story's data.

/** Any CSS colour string or a 0xRRGGBB number, as three.js `Color` accepts both. */
export type Colour = string | number;

export type Palette = {
    name: string;

    /** Family links: spouse→union and union→child lines, and their highlighted-path glow. */
    links: { spouse: Colour; child: Colour; pathGlow: Colour };
    /**
     * Highlight tints showing direction in a person's line: ancestors warm, descendants cool, mixed gently into the
     * house colour (as emissive light, so the house colour still reads); siblings (Siblings focus) green. `step` is
     * the finder's hovered step.
     */
    lineage: { ancestor: Colour; descendant: Colour; sibling: Colour; step: Colour };
    /** Relationship label text on spouse / child links, on sibling lines, and the "relative to" tags. */
    labels: {
        name: string; // person names (≈ CSS --ink)
        spouse: string;
        child: string;
        sibling: string;
        tag: string;
        backing: string; // translucent box behind relationship labels
        guide: string; // "Generation n"
    };
    siblingLine: Colour;
    guideLine: Colour;
    union: Colour; // the small marriage/union dots
    /** House badge: dark outline, and ink for the initial on light / dark houses. */
    badge: { outline: string; inkOnLight: string; inkOnDark: string };
    /** Fallback colour for a person whose house has no colour. */
    unknownHouse: string;

    /** Scene lighting (see scene.ts for why it's balanced this way: strong key, low fill, cool rim). */
    lights: {
        key: Colour;
        keyIntensity: number;
        rim: Colour;
        rimIntensity: number;
        skyFill: Colour;
        groundFill: Colour;
        fillIntensity: number;
        environment: number; // RoomEnvironment reflection strength
    };
    /** Depth fog colour: should sit close to the background's average so far people fade into it, not into grey. */
    fog: Colour;
    /** Flat fallback background (radial vignette), shown until the nebula is baked and if it's turned off. */
    vignette: { inner: string; outer: string };

    /**
     * The procedural nebula sky (nebula.ts). Its colours are generated from a random base hue within `hue`, so each
     * saga's sky differs while staying in the theme. Brightness is capped by `maxLuma` for readability: the tree's
     * labels are drawn at ~85–95% brightness, so keep this low (≈0.08–0.15).
     */
    nebula: {
        hue: [number, number]; // range for the base hue, 0–1 around the colour wheel
        saturation: [number, number];
        lightness: [number, number];
        hueSpread: [number, number]; // how far the accent blobs drift from the base hue
        haze: [number, number, number]; // faint tint in empty sky (linear RGB, 0–1)
        star: [number, number, number];
        /** Fraction of star cells that hold a star (0–1). Low = a sprinkling; the dust should dominate. */
        starDensity: number;
        /** Fraction of large cells holding a faint distant galaxy (0–1). A few per sky at ~0.06. */
        galaxyDensity: number;
        /** Strength of the dark dust lanes cutting through the glow (0 = none, 1 = strong). */
        dustLanes: number;
        /**
         * The dust colours, modelled on real nebulae (linear RGB, 0–1, before the brightness cap). Keep them physical
         * for a believable sky: hydrogen-alpha emission is crimson/magenta, oxygen-III is teal/cyan, reflection
         * nebulae are pale blue. A theme can shift them (e.g. warmer for a desert saga) but should keep the contrast.
         */
        emissionH: [number, number, number];
        emissionO: [number, number, number];
        reflection: [number, number, number];
        maxLuma: number;
        /**
         * Overall level of the sky before the cap (linear multiplier). The nebula is meant to be a faint backdrop with
         * the tree as the focal point, so this is low. Measured on screen at 0.18: sky average ≈ 3%, brightest ≈ 11%.
         */
        brightness: number;
    };

    /** Saved PNG: title and author stamped in the corner (≈ CSS --gold-bright and --ink-soft). */
    png: { title: string; author: string; shadow: string };

    /** Colours handed out to houses in an imported GEDCOM file (by surname), which has none of its own. */
    importHouses: string[];
};

/** The default theme: warm gold accents on a deep blue-violet night sky. */
export const DEFAULT_PALETTE: Palette = {
    name: "Night gold",
    links: { spouse: "#c9ad73", child: "#667", pathGlow: 0xc9ad73 }, // spouse/pathGlow ≈ CSS --gold
    lineage: { ancestor: 0xffb066, descendant: 0x6fc6ff, sibling: 0x7ee08a, step: 0xfff1c4 }, // ≈ CSS --ancestor etc.
    labels: {
        name: "#e8dcc1", // ≈ CSS --ink
        spouse: "#e6cf95", // ≈ CSS --gold-bright
        child: "#b8b8c8",
        sibling: "#8fc4ab",
        tag: "#8fd0b6",
        backing: "rgba(7,7,10,.7)",
        guide: "rgba(201,173,115,.55)",
    },
    siblingLine: 0x5f8f7a,
    guideLine: 0xc9ad73,
    union: 0xffffff,
    badge: { outline: "rgba(7,7,10,.85)", inkOnLight: "#141318", inkOnDark: "#f4ead2" },
    unknownHouse: "#888",
    lights: {
        key: 0xfff1d6,
        keyIntensity: 3.4,
        rim: 0x8fb4ff,
        rimIntensity: 1.2,
        skyFill: 0xfff4e0,
        groundFill: 0x0a0a12,
        fillIntensity: 0.22,
        environment: 0.12,
    },
    fog: 0x0b0a10,
    vignette: { inner: "#15141b", outer: "#050507" },
    nebula: {
        hue: [0.5, 0.85], // teal → blue → violet: cool hues sit quietly behind warm gold labels
        saturation: [0.25, 0.55],
        lightness: [0.1, 0.2],
        hueSpread: [0.08, 0.33],
        haze: [0.006, 0.007, 0.012], // near-zero: a faint tint beside clouds, never an even grey (see nebula.ts)
        star: [0.9, 0.92, 1.0],
        starDensity: 1.25, // ×1.25 = 25% more stars; scales both layers' cell fractions in nebula.ts
        galaxyDensity: 0.25, // fraction of large sky cells (nebula.ts, scale 3) holding a galaxy: about a dozen in all
        dustLanes: 0.8,
        emissionH: [0.55, 0.05, 0.16], // hydrogen-alpha: deep crimson
        emissionO: [0.03, 0.34, 0.38], // oxygen-III: teal
        reflection: [0.12, 0.2, 0.42], // dust-scattered starlight: pale blue
        maxLuma: 0.12, // on-screen brightness ceiling (0–1): nothing in the sky goes above 12%
        brightness: 0.18,
    },
    png: { title: "#e6cf95", author: "rgba(232,220,193,.75)", shadow: "#000" },
    importHouses: [
        "#c0262d",
        "#3b6fb6",
        "#e0b23a",
        "#3f9a4b",
        "#8a5fd0",
        "#e07a2e",
        "#4aa8c8",
        "#d24fa8",
        "#9aa9b8",
        "#a87a4a",
        "#5b7a5a",
        "#c8a8e8",
        "#b3202a",
        "#7fc4ff",
        "#d77fb0",
        "#6a9a7a",
        "#e6cf6a",
        "#8a8f6a",
        "#4b4f6b",
        "#e58fa8",
    ],
};

/**
 * Per-saga themes. Each entry overrides parts of the default; unlisted sagas use DEFAULT_PALETTE. Overrides are
 * merged one level deep, so `{ nebula: { hue: [...] } }` changes only the nebula hue.
 *
 * Example (not enabled):
 *   dune: { name: "Arrakis", nebula: { hue: [0.02, 0.12] }, fog: 0x100a06, vignette: { inner: "#1b140c", outer: "#070503" } },
 */
const SAGA_PALETTES: Record<string, DeepPartial<Palette>> = {};

type DeepPartial<T> = {
    [K in keyof T]?: T[K] extends readonly unknown[] ? T[K] : T[K] extends object ? Partial<T[K]> : T[K];
};

// --- The active palette ---------------------------------------------------------------------------------------------
// Modules read `palette()` when they build objects. Colours are baked into materials, labels and the nebula when
// those are created, so changing palette takes effect for whatever is built next: app.ts calls usePalette() before
// building a saga's tree and re-baking its sky, and scene.ts re-applies lights and fog in applyScenePalette().
let active: Palette = DEFAULT_PALETTE;
export const palette = (): Palette => active;
export const usePalette = (p: Palette): void => void (active = p);

/** The palette for a saga (or for an imported file / unknown id): the default with that saga's overrides applied. */
export function paletteFor(sagaId: string): Palette {
    const o = SAGA_PALETTES[sagaId];
    if (!o) return DEFAULT_PALETTE;
    const out = { ...DEFAULT_PALETTE } as Record<string, unknown>;
    for (const [k, v] of Object.entries(o)) {
        const base = (DEFAULT_PALETTE as Record<string, unknown>)[k];
        out[k] =
            v && typeof v === "object" && !Array.isArray(v) && base && typeof base === "object" ? { ...base, ...v } : v;
    }
    return out as Palette;
}
