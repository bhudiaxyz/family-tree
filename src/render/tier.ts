// Tiering: one synchronous probe at start-up picks a quality tier, and every cost-bearing setting comes from QUALITY.
//
// What it does: probe() reads WebGL2 capabilities and the renderer string; classify() maps a GpuInfo to a Tier with a
// reason; detect() combines them with the `?tier=` override; QUALITY holds the per-tier settings (render resolution,
// bloom, nebula bake size, antialiasing, label density, idle fps...).
// Usage: device.ts calls detect() and exports the result; tests in scripts/tier.test.mts call classify() directly.
// Notes: target is devices up to ~7 years old (2018+: iPhone XR, iPad 6th gen, Galaxy S9, UHD 620), which land in
// "low" or "medium" and stay fully usable. Tier only disables optional visual effects, never a feature. Signals, most
// reliable first: (1) WebGL2 capabilities, hard limits; (2) the unmasked renderer string, matched against FAMILIES
// (first match wins; Firefox and Safari may mask it, so it only refines); (3) deviceMemory and hardwareConcurrency as
// tie-breakers. classify() is pure (no DOM) so it can be tested against real renderer strings.

export type Tier = "low" | "medium" | "high";

export type GpuInfo = {
    renderer: string; // unmasked if available, else the masked string
    maxTextureSize: number;
    floatTargets: boolean; // EXT_color_buffer_float: needed for HDR bloom render targets
    halfFloatTargets: boolean; // EXT_color_buffer_half_float / float
    maxSamples: number; // MSAA
    deviceMemory?: number; // GB, Chromium only (rounded down: 0.25 … 8)
    cores?: number;
    mobile: boolean; // touch-first device (coarse pointer) — affects battery-sensitive defaults, not capability
};

/** Every cost-bearing setting, by tier. Change quality here, not in the modules that use it. */
export type Quality = {
    pixelRatio: number; // cap on device pixels per CSS pixel for the main render
    antialias: boolean; // MSAA on the default framebuffer
    bloom: boolean; // default for the "Glow" toggle (user can still turn it on/off)
    bloomScale: number; // bloom render-target size as a fraction of the screen (it's a blur; low res is fine)
    nebulaSize: number; // cube face size for the baked sky
    nebulaOctaves: number;
    nebulaMipmaps: boolean;
    sphereSegments: [number, number]; // person sphere detail
    labelDeclutterMs: number; // how often to re-run the name overlap pass
    idleFps: number; // frame rate once nothing is moving (battery)
};

// Renderer-string families. Order matters: first match wins. Patterns are case-insensitive.
const FAMILIES: [RegExp, Tier][] = [
    // Software renderers: always low (a GPU-less VM, or a blocklisted driver falling back to the CPU).
    [/swiftshader|llvmpipe|softpipe|microsoft basic render|software/i, "low"],

    // Discrete and recent desktop GPUs.
    [/nvidia|geforce|quadro|rtx|gtx\s*1[0-9]{3}/i, "high"],
    [/radeon\s*(rx|pro|vii)|amd\s*radeon(?!.*(vega\s*[3-8]\b|r[2-7]\b))/i, "high"],
    [/apple\s*m[1-9]|apple\s*gpu/i, "high"], // M-series Macs and iPads; "Apple GPU" is what Safari masks every Apple GPU to
    [/intel.*(arc|iris(\(r\))?\s*xe)/i, "high"], // ANGLE writes "Iris(R) Xe": allow the trademark mark

    // Mobile: Adreno 6xx and up (Snapdragon 845, 2018+): 630/640 medium, 650+ (S865+, S22 Ultra's 730) high.
    [/adreno.*\b(7[0-9]{2}|6[5-9][0-9])\b/i, "high"],
    [/adreno.*\b6[0-4][0-9]\b/i, "medium"],
    [/adreno/i, "low"],
    // Mali: G7x/G610+ (2018+) medium; G710+/G715/Immortalis high; older Mali low.
    [/mali-g7[1-9][0-9]|mali-g6[1-9][0-9]|immortalis/i, "high"],
    [/mali-g(7[0-9]|5[0-9]|6[0-9])\b/i, "medium"],
    [/mali/i, "low"],
    [/xclipse|powervr|samsung/i, "medium"], // S22's Xclipse 920 (Exynos) has good WebGL but young drivers
    // Integrated desktop/laptop GPUs: Intel UHD/HD 6xx and Iris (2017+) medium; older HD Graphics low.
    [/intel.*(uhd|iris)/i, "medium"],
    [/intel.*hd\s*graphics\s*[5-6][0-9]{2}/i, "medium"],
    [/intel/i, "low"],
    [/amd|radeon/i, "medium"], // APUs (Vega 3–8 integrated)
];

export const QUALITY: Record<Tier, Quality> = {
    low: {
        pixelRatio: 1.25,
        antialias: false,
        bloom: false,
        bloomScale: 0.33,
        nebulaSize: 256,
        nebulaOctaves: 5,
        nebulaMipmaps: false,
        sphereSegments: [20, 12],
        labelDeclutterMs: 300,
        idleFps: 10,
    },
    medium: {
        pixelRatio: 2,
        antialias: true,
        bloom: false,
        bloomScale: 0.5,
        nebulaSize: 512,
        nebulaOctaves: 7,
        nebulaMipmaps: true,
        sphereSegments: [32, 18],
        labelDeclutterMs: 180,
        idleFps: 20,
    },
    high: {
        pixelRatio: 2,
        antialias: true,
        bloom: true,
        bloomScale: 0.5,
        nebulaSize: 1024,
        nebulaOctaves: 10,
        nebulaMipmaps: true,
        sphereSegments: [48, 24],
        labelDeclutterMs: 120,
        idleFps: 30,
    },
};

/** Classify a device into a tier. Pure: unit-tested in scripts/tier.test.mts. */
export function classify(g: GpuInfo): { tier: Tier; reason: string } {
    // Hard capability floors first: these are never wrong, whatever the renderer string says.
    if (g.maxTextureSize < 4096) return { tier: "low", reason: `max texture ${g.maxTextureSize}px` };
    if (!g.halfFloatTargets) return { tier: "low", reason: "no float render targets" };

    let tier: Tier | null = null;
    let reason = "";
    for (const [re, t] of FAMILIES)
        if (re.test(g.renderer)) {
            tier = t;
            reason = `GPU "${g.renderer.slice(0, 60)}"`;
            break;
        }
    // Unknown or masked GPU: decide from memory/cores, conservatively (medium unless clearly weak or strong).
    if (!tier) {
        const mem = g.deviceMemory ?? (g.mobile ? 4 : 8);
        const cores = g.cores ?? 4;
        tier = mem <= 2 || cores <= 2 ? "low" : mem >= 8 && cores >= 8 && !g.mobile ? "high" : "medium";
        reason = `unknown GPU; ${g.deviceMemory ?? "?"} GB, ${g.cores ?? "?"} cores`;
    }
    // Low memory caps the tier regardless of GPU (large textures and the nebula bake must fit).
    if (g.deviceMemory !== undefined && g.deviceMemory <= 2 && tier !== "low") {
        tier = "low";
        reason += "; ≤2 GB memory";
    } else if (g.deviceMemory !== undefined && g.deviceMemory <= 4 && tier === "high" && g.mobile) {
        tier = "medium";
        reason += "; ≤4 GB on mobile";
    }
    // No full float targets: bloom falls back to half-float, which is fine, but keep the very top tier honest.
    if (tier === "high" && !g.floatTargets) {
        tier = "medium";
        reason += "; no 32-bit float targets";
    }
    return { tier, reason };
}

/** Probe the browser. Uses a throwaway canvas, so it can run before the renderer exists. */
export function probe(): GpuInfo | null {
    const canvas = document.createElement("canvas");
    let gl: WebGL2RenderingContext | null = null;
    try {
        gl = canvas.getContext("webgl2", { failIfMajorPerformanceCaveat: false });
    } catch {
        return null;
    }
    if (!gl) return null;
    const dbg = gl.getExtension("WEBGL_debug_renderer_info");
    const renderer = String(
        (dbg && gl.getParameter(dbg.UNMASKED_RENDERER_WEBGL)) || gl.getParameter(gl.RENDERER) || "unknown"
    );
    const info: GpuInfo = {
        renderer,
        maxTextureSize: gl.getParameter(gl.MAX_TEXTURE_SIZE) as number,
        floatTargets: !!gl.getExtension("EXT_color_buffer_float"),
        halfFloatTargets: !!(
            gl.getExtension("EXT_color_buffer_float") || gl.getExtension("EXT_color_buffer_half_float")
        ),
        maxSamples: gl.getParameter(gl.MAX_SAMPLES) as number,
        deviceMemory: (navigator as Navigator & { deviceMemory?: number }).deviceMemory,
        cores: navigator.hardwareConcurrency || undefined,
        mobile: matchMedia("(pointer: coarse)").matches,
    };
    gl.getExtension("WEBGL_lose_context")?.loseContext(); // free the probe context straight away
    return info;
}

/** Detect once per page load; `?tier=` overrides. */
export function detect(): { tier: Tier; reason: string; gpu: GpuInfo | null } {
    const gpu = probe();
    const forced = new URLSearchParams(location.search).get("tier");
    if (forced === "low" || forced === "medium" || forced === "high")
        return { tier: forced, reason: "forced by ?tier=", gpu };
    if (!gpu) return { tier: "low", reason: "WebGL2 probe failed", gpu };
    return { ...classify(gpu), gpu };
}
