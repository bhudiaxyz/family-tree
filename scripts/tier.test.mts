// Test for src/tier.ts: GPU tier classification (classify).
//
// Data: renderer strings real devices report (WEBGL_debug_renderer_info, or the masked string when a browser hides it),
//   written inline; no saga files. Covers the supported range, devices up to ~7 years old.
// Run alone: node --experimental-strip-types --no-warnings scripts/tier.test.mts  (also part of npm test)
// Notes: no ratchets. When a new device is misclassified, add its renderer string here with the tier it should get.

import assert from "node:assert/strict";
import { classify, type GpuInfo, QUALITY } from "../src/tier.ts";

const base: GpuInfo = {
    renderer: "",
    maxTextureSize: 16384,
    floatTargets: true,
    halfFloatTargets: true,
    maxSamples: 4,
    mobile: false,
};
const tier = (renderer: string, extra: Partial<GpuInfo> = {}) => classify({ ...base, renderer, ...extra }).tier;

// Desktops and laptops.
assert.equal(tier("ANGLE (NVIDIA, NVIDIA GeForce RTX 3060 Direct3D11 vs_5_0 ps_5_0, D3D11)"), "high");
assert.equal(tier("ANGLE (NVIDIA, NVIDIA GeForce GTX 1050 Ti Direct3D11 vs_5_0 ps_5_0, D3D11)"), "high");
assert.equal(tier("ANGLE (AMD, AMD Radeon RX 580 Series Direct3D11 vs_5_0 ps_5_0, D3D11)"), "high");
assert.equal(tier("ANGLE (Intel, Intel(R) Iris(R) Xe Graphics Direct3D11 vs_5_0 ps_5_0, D3D11)"), "high");
assert.equal(
    tier("ANGLE (Intel, Intel(R) UHD Graphics 620 Direct3D11 vs_5_0 ps_5_0, D3D11)"),
    "medium",
    "2017–18 laptop iGPU"
);
assert.equal(tier("ANGLE (Intel, Intel(R) HD Graphics 620 Direct3D11 vs_5_0 ps_5_0, D3D11)"), "medium");
assert.equal(tier("ANGLE (Intel, Intel(R) HD Graphics 4000 Direct3D11 vs_5_0 ps_5_0, D3D11)"), "low", "2012 iGPU");
assert.equal(tier("ANGLE (AMD, AMD Radeon(TM) Vega 8 Graphics Direct3D11 vs_5_0 ps_5_0, D3D11)"), "medium", "APU");
assert.equal(tier("Apple M1"), "high");
assert.equal(tier("Apple M2 Pro"), "high");

// Apple mobile: Safari masks every Apple GPU to "Apple GPU". The capability floors still apply.
assert.equal(tier("Apple GPU", { mobile: true }), "high", "iPad / iPhone in Safari");
assert.equal(
    tier("Apple GPU", { mobile: true, maxTextureSize: 4096, floatTargets: false }),
    "medium",
    "older iPad: no fp32 targets"
);

// Android.
assert.equal(tier("Adreno (TM) 730", { mobile: true }), "high", "Galaxy S22 Ultra (Snapdragon 8 Gen 1)");
assert.equal(tier("Samsung Xclipse 920", { mobile: true }), "medium", "Galaxy S22 Ultra (Exynos)");
assert.equal(tier("Adreno (TM) 650", { mobile: true }), "high", "Snapdragon 865 (2020)");
assert.equal(tier("Adreno (TM) 630", { mobile: true }), "medium", "Galaxy S9 / Pixel 3 (2018)");
assert.equal(tier("Adreno (TM) 540", { mobile: true }), "low", "2017 flagship");
assert.equal(tier("Mali-G72", { mobile: true }), "medium", "Galaxy S9 Exynos (2018)");
assert.equal(tier("Mali-G710", { mobile: true }), "high");
assert.equal(tier("Mali-T880", { mobile: true }), "low", "2016");
assert.equal(tier("PowerVR Rogue GE8320", { mobile: true }), "medium");

// Software rendering is always low, even on a big machine.
assert.equal(tier("Google SwiftShader"), "low");
assert.equal(
    tier("ANGLE (Google, Vulkan 1.3.0 (SwiftShader Device (Subzero) (0x0000C0DE)), SwiftShader driver)"),
    "low"
);
assert.equal(tier("llvmpipe (LLVM 15.0.7, 256 bits)"), "low");

// Capability floors beat the renderer string.
assert.equal(tier("NVIDIA GeForce RTX 4090", { maxTextureSize: 2048 }), "low");
assert.equal(tier("NVIDIA GeForce RTX 4090", { halfFloatTargets: false, floatTargets: false }), "low");
assert.equal(tier("Adreno (TM) 730", { mobile: true, deviceMemory: 2 }), "low", "≤2 GB caps everything");
assert.equal(tier("Adreno (TM) 730", { mobile: true, deviceMemory: 4 }), "medium", "≤4 GB mobile stays medium");
assert.equal(tier("NVIDIA GeForce RTX 3060", { floatTargets: false }), "medium");

// Unknown / masked GPUs: decided by memory and cores, conservatively.
assert.equal(tier("WebKit WebGL", { deviceMemory: 8, cores: 12 }), "high");
assert.equal(tier("WebKit WebGL", { deviceMemory: 4, cores: 8, mobile: true }), "medium");
assert.equal(tier("WebKit WebGL", { deviceMemory: 2, cores: 4 }), "low");
assert.equal(tier("WebKit WebGL"), "medium", "nothing known: medium");

// The quality table is monotonic: higher tiers never cost less than lower ones on any axis.
const order = ["low", "medium", "high"] as const;
for (const k of ["pixelRatio", "bloomScale", "nebulaSize", "nebulaOctaves", "idleFps"] as const)
    for (let i = 1; i < 3; i++)
        assert.ok(
            QUALITY[order[i]][k] >= QUALITY[order[i - 1]][k],
            `${k} must not drop from ${order[i - 1]} to ${order[i]}`
        );

console.log("ok  GPU tiers: desktop, laptop, Apple, Android, software, capability floors, unknown GPUs, quality table");
