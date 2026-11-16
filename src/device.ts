// The detected device tier and its quality settings, shared by every module that has a cost to tune.
//
// Lives in its own module (rather than in scene.ts) so that scene.ts, nebula.ts, graph.ts and app.ts can all read the
// quality settings without importing each other: scene.ts imports nebula.ts, so if nebula.ts imported scene.ts for
// these values it would be a circular import. Everything here depends only on tier.ts and the browser.
//
// Detection runs once, at first import, before the renderer is created (antialiasing must be chosen at context
// creation). It's logged so a bug report can say which tier ran; `?tier=low|medium|high` forces one for testing.
import { detect, type Quality, QUALITY } from "./tier.ts";

export const device = detect();
export const quality: Quality = QUALITY[device.tier];
console.info(`[family-tree] quality tier: ${device.tier} (${device.reason})`);
