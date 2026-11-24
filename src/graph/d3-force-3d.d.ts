// Minimal typings for d3-force-3d (the package ships none): only forceZ, which graph/core.ts uses.
// Add declarations here if more of the package is needed.

declare module "d3-force-3d" {
    interface ForceZ<N> {
        (alpha: number): void;
        z(z: number | ((node: N) => number)): ForceZ<N>;
        strength(s: number | ((node: N) => number)): ForceZ<N>;
    }
    export function forceZ<N = unknown>(z?: number | ((node: N) => number)): ForceZ<N>;
}
