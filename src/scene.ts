// Renderer, scene, lights, camera and orbit controls. No family-tree knowledge.
import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";
import { RoomEnvironment } from "three/addons/environments/RoomEnvironment.js";

/** True if this browser can create a WebGL2 context (three.js r163+ requires WebGL2). */
export function hasWebGL(): boolean {
    try {
        return !!document.createElement("canvas").getContext("webgl2");
    } catch {
        return false;
    }
}

/** Error thrown when the 3D view cannot start; main.ts catches it and shows a message instead of a blank page. */
export class NoWebGLError extends Error {
    override name = "NoWebGLError";
}

if (!hasWebGL()) throw new NoWebGLError("WebGL 2 is not available");

export const renderer = (() => {
    try {
        return new THREE.WebGLRenderer({ antialias: true });
    } catch (e) {
        throw new NoWebGLError((e as Error).message); // e.g. GPU blocklisted, or the context limit was reached
    }
})();
renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
renderer.setSize(innerWidth, innerHeight);
renderer.toneMapping = THREE.ACESFilmicToneMapping;
document.body.appendChild(renderer.domElement);

export const scene = new THREE.Scene();
// Lighting for depth: one strong warm key from upper left gives each sphere a clear lit side, terminator and shadow
// side. The fill is kept low so the shadow side stays dark (but not black), the environment adds only a faint
// ambient tint (more would flatten the gradient), and a cool rim from behind separates the spheres from the background.
scene.environment = new THREE.PMREMGenerator(renderer).fromScene(new RoomEnvironment()).texture;
scene.environmentIntensity = 0.12;
const key = new THREE.DirectionalLight(0xfff1d6, 3.4);
key.position.set(-2, 3, 2.5);
const rim = new THREE.DirectionalLight(0x8fb4ff, 1.2);
rim.position.set(2, 1, -3);
scene.add(new THREE.HemisphereLight(0xfff4e0, 0x0a0a12, 0.22), key, rim);
// A faint radial vignette behind the tree: depth cue and a less flat black. Drawn as the scene background.
scene.background = vignette();

// 50° keeps perspective (and so pan parallax) visible without fish-eye distortion at the tree edges.
export const camera = new THREE.PerspectiveCamera(50, innerWidth / innerHeight, 1, 5000);
camera.position.set(0, 0, 320);

export const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;
controls.saveState();

addEventListener("resize", () => {
    camera.aspect = innerWidth / innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(innerWidth, innerHeight);
});

// Losing the GPU context (driver reset, too many tabs) would otherwise freeze the view silently.
renderer.domElement.addEventListener("webglcontextlost", (e) => {
    e.preventDefault(); // allow the browser to restore it
    dispatchEvent(new CustomEvent("ft:contextlost"));
});
renderer.domElement.addEventListener("webglcontextrestored", () =>
    dispatchEvent(new CustomEvent("ft:contextrestored"))
);

function vignette(): THREE.Texture {
    const c = document.createElement("canvas");
    c.width = c.height = 256;
    const g = c.getContext("2d")!;
    const grad = g.createRadialGradient(128, 110, 10, 128, 128, 180);
    grad.addColorStop(0, "#15141b");
    grad.addColorStop(1, "#050507");
    g.fillStyle = grad;
    g.fillRect(0, 0, 256, 256);
    const t = new THREE.CanvasTexture(c);
    t.colorSpace = THREE.SRGBColorSpace;
    return t;
}

/**
 * Capture the current view as a PNG, at `scale` × the screen resolution for a sharper image.
 *
 * WebGL may clear its drawing buffer as soon as the frame is composited, and toBlob() is asynchronous, so the frame
 * is rendered and copied into a 2D canvas in the same synchronous step; the copy is then encoded at leisure. This
 * avoids `preserveDrawingBuffer`, which would cost performance on every frame just to support an occasional export.
 * `overlay` draws on top of the copy (title, credits) before encoding.
 */
export async function captureView(scale = 2, overlay?: (g: CanvasRenderingContext2D, width: number) => void) {
    const size = renderer.getSize(new THREE.Vector2());
    const ratio = renderer.getPixelRatio();
    const target = Math.min(ratio * scale, 4);
    const copy = document.createElement("canvas");
    try {
        renderer.setPixelRatio(target);
        renderer.setSize(size.x, size.y, false);
        renderer.render(scene, camera);
        copy.width = renderer.domElement.width;
        copy.height = renderer.domElement.height;
        copy.getContext("2d")!.drawImage(renderer.domElement, 0, 0); // same task as render(): buffer still intact
    } finally {
        renderer.setPixelRatio(ratio);
        renderer.setSize(size.x, size.y, false);
    }
    overlay?.(copy.getContext("2d")!, copy.width);
    const blob = await new Promise<Blob | null>((resolve) => copy.toBlob(resolve, "image/png"));
    if (!blob) throw new Error("The browser could not encode the image");
    return blob;
}
