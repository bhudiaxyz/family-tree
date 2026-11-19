// Nebula: a procedural sky, baked once per saga into a cube texture used as the scene background.
//
// What it does: bakeNebula() renders nebula.frag on the inside of a sphere with a CubeCamera into a
// WebGLCubeRenderTarget; the saga id seeds a small RNG that picks the gradient palette and noise offsets.
// Usage: ui/sagas.ts bakes and passes the result to scene.ts setSky(); scene.ts calls disposeNebula().
// Exports bakeNebula, disposeNebula, defaultNebulaOptions and NebulaOptions.
// Notes: ported from procedural-worlds (nebulaMap.frag, NebulaEnvMap, NebulaTexture). Dim by design: the shader caps
// output near 12% (palette nebula.maxLuma); never raise it without checking names and labels read against the brightest
// sky. A cube texture as scene.background is drawn at infinity: it never moves on pan, isn't clipped by far, and is not
// fogged. Bake cost is tiered (7 octaves at 512 px on phones vs 16 at 1024 originally); memory is 6 * size^2 * 4 bytes,
// +1/3 with mipmaps. Bake with tone mapping off, or the capped values get brightened. Deterministic per saga id.

import * as THREE from "three";
import { quality } from "./device.ts";
import { type Palette, palette } from "./palettes.ts";
import fragmentShader from "./nebula.frag?raw";

// --- Seeded random (mulberry32), so a saga id always gives the same palette and noise offsets ---------------------
function hashString(s: string): number {
    let h = 2166136261;
    for (let i = 0; i < s.length; i++) h = Math.imul(h ^ s.charCodeAt(i), 16777619);
    return h >>> 0;
}
function rng(seed: number) {
    let a = seed >>> 0;
    return () => {
        a = (a + 0x6d2b79f5) >>> 0;
        let t = a;
        t = Math.imul(t ^ (t >>> 15), t | 1);
        t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
        return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };
}

// --- Colour palette: a soft canvas gradient, as in procedural-worlds' NebulaTexture --------------------------------
// A base hue plus radial blobs at that hue and two complementary-ish offsets. Kept darker and less saturated than the
// original (lightness 0.08–0.28) because the shader multiplies it by cloud density anyway.
function paletteTexture(rand: () => number, theme: Palette["nebula"]): THREE.CanvasTexture {
    const size = 256;
    const c = document.createElement("canvas");
    c.width = c.height = size;
    const g = c.getContext("2d")!;
    // Base hue, saturation and lightness come from the theme (palettes.ts), randomised within its ranges.
    const pickIn = ([lo, hi]: [number, number]) => lo + rand() * (hi - lo);
    const base = new THREE.Color().setHSL(pickIn(theme.hue), pickIn(theme.saturation), pickIn(theme.lightness));
    const angle = pickIn(theme.hueSpread);
    g.fillStyle = `#${base.getHexString()}`;
    g.fillRect(0, 0, size, size);
    const blobs = 20 + Math.floor(rand() * 40);
    for (let i = 0; i < blobs; i++) {
        const x = rand() * size;
        const y = rand() * size;
        const r = 40 + rand() * 90;
        const pick = rand();
        const hue = pick < 0.33 ? 0 : pick < 0.66 ? angle : -angle;
        const col = base.clone().offsetHSL(hue + (rand() - 0.5) * 0.2, (rand() - 0.6) * 0.4, (rand() - 0.5) * 0.18);
        const [cr, cg, cb] = [col.r, col.g, col.b].map((v) => Math.round(THREE.MathUtils.clamp(v, 0, 1) * 255));
        const grad = g.createRadialGradient(x, y, 0, x, y, r);
        grad.addColorStop(0, `rgba(${cr},${cg},${cb},1)`);
        grad.addColorStop(1, `rgba(${cr},${cg},${cb},0)`);
        g.fillStyle = grad;
        g.fillRect(0, 0, size, size);
    }
    const t = new THREE.CanvasTexture(c);
    t.colorSpace = THREE.SRGBColorSpace;
    t.wrapS = t.wrapT = THREE.MirroredRepeatWrapping;
    return t;
}

// --- Shader: the nebula, evaluated per direction on the inside of a sphere -----------------------------------------
// Rendered by a CubeCamera from the centre of an inverted sphere, so each fragment's normalised position IS the view
// direction: no per-face coordinate maths is needed (the original's getSphericalCoord).
const vertexShader = /* glsl */ `
    varying vec3 vDir;
    void main() {
        vDir = normalize(position);
        gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    }
`;

// The fragment shader lives in nebula.frag (bundled as a string by Vite's ?raw import, so it's plain GLSL with
// editor highlighting rather than a template string).

/**
 * Bake settings. Defaults come from the device tier (device.ts / tier.ts QUALITY). Memory per sky: 6 faces × size² ×
 * 4 bytes, ×4/3 with mipmaps: 256 px ≈ 1.6 MB (low), 512 ≈ 8 MB (medium), 1024 ≈ 34 MB (high).
 */
export type NebulaOptions = { resolution: number; octaves: number; mipmaps: boolean; maxLuma: number };

export const defaultNebulaOptions = (): NebulaOptions => ({
    resolution: quality.nebulaSize,
    octaves: quality.nebulaOctaves,
    mipmaps: quality.nebulaMipmaps,
    maxLuma: palette().nebula.maxLuma,
});

/**
 * Bake a nebula cube texture for `id` (a saga id or file name). Returns the cube texture; the caller sets it as
 * scene.background and disposes the previous one. Pure GPU work: nothing is drawn on screen while baking.
 */
export function bakeNebula(
    renderer: THREE.WebGLRenderer,
    id: string,
    opts = defaultNebulaOptions()
): THREE.CubeTexture {
    const rand = rng(hashString(id));
    const theme = palette().nebula;
    const gradient = paletteTexture(rand, theme);
    const material = new THREE.ShaderMaterial({
        vertexShader,
        fragmentShader: fragmentShader.replaceAll("__OCTAVES__", String(opts.octaves)),
        uniforms: {
            seed: { value: rand() * 1000 },
            res1: { value: 1 + rand() * 2 },
            res2: { value: 1 + rand() * 2 },
            resMix: { value: 1 + rand() * 2 },
            maxLuma: { value: opts.maxLuma },
            brightness: { value: theme.brightness },
            haze: { value: new THREE.Vector3(...theme.haze) },
            starColour: { value: new THREE.Vector3(...theme.star) },
            starDensity: { value: theme.starDensity },
            galaxyDensity: { value: theme.galaxyDensity },
            dustLanes: { value: theme.dustLanes },
            emissionH: { value: new THREE.Vector3(...theme.emissionH) },
            emissionO: { value: new THREE.Vector3(...theme.emissionO) },
            reflectionBlue: { value: new THREE.Vector3(...theme.reflection) },
            palette: { value: gradient },
        },
        side: THREE.BackSide, // seen from inside
        depthWrite: false,
    });
    const sky = new THREE.Mesh(new THREE.SphereGeometry(10, 64, 32), material);
    const bakeScene = new THREE.Scene().add(sky);
    const target = new THREE.WebGLCubeRenderTarget(opts.resolution, {
        // Mipmaps avoid shimmer when the sky is minified, but cost a third more memory and a generation pass; the
        // low tier skips them (its 256 px faces are barely minified on a phone screen anyway).
        generateMipmaps: opts.mipmaps,
        minFilter: opts.mipmaps ? THREE.LinearMipmapLinearFilter : THREE.LinearFilter,
        colorSpace: THREE.SRGBColorSpace,
    });
    const cubeCamera = new THREE.CubeCamera(0.1, 100, target);

    // Bake without the app's tone mapping, which would otherwise brighten and compress the carefully capped values.
    const tm = renderer.toneMapping;
    renderer.toneMapping = THREE.NoToneMapping;
    cubeCamera.update(renderer, bakeScene);
    renderer.toneMapping = tm;

    // Free everything but the cube texture itself.
    sky.geometry.dispose();
    material.dispose();
    gradient.dispose();
    (target.texture as THREE.CubeTexture & { userData: Record<string, unknown> }).userData.target = target; // keep for dispose
    return target.texture as unknown as THREE.CubeTexture;
}

/** Free a texture made by bakeNebula (its render target owns the GPU memory). */
export function disposeNebula(tex: THREE.Texture | null): void {
    const target = (tex?.userData as { target?: THREE.WebGLCubeRenderTarget } | undefined)?.target;
    target?.dispose();
}
