// Device: the detected device tier and its quality settings, shared by every module with a cost to tune.
//
// What it does: runs tier.ts detect() once at first import and exports the result as `device` and its row of QUALITY
// as `quality`; logs the tier so bug reports can name it. `?tier=low|medium|high` forces one.
// Usage: scene.ts, nebula.ts, graph.ts and app.ts import `device` and `quality`.
// Notes: separate from scene.ts to avoid a cycle: scene.ts imports nebula.ts, so nebula.ts could not import scene.ts
// for these values. It depends only on tier.ts and the browser, and must be imported before the renderer is created.

import { detect, type Quality, QUALITY } from "./tier.ts";

export const device = detect();
export const quality: Quality = QUALITY[device.tier];
console.info(`[family-tree] quality tier: ${device.tier} (${device.reason})`);
