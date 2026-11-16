// Minimal typing for the one d3-force-3d export used here (the package ships no types).
declare module "d3-force-3d" {
    interface ForceZ<N> {
        (alpha: number): void;
        z(z: number | ((node: N) => number)): ForceZ<N>;
        strength(s: number | ((node: N) => number)): ForceZ<N>;
    }
    export function forceZ<N = unknown>(z?: number | ((node: N) => number)): ForceZ<N>;
}
