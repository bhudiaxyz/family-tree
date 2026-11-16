// Renderer, scene, lights, camera and orbit controls. No family-tree knowledge.
import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";
import { RoomEnvironment } from "three/addons/environments/RoomEnvironment.js";

export const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
renderer.setSize(innerWidth, innerHeight);
renderer.toneMapping = THREE.ACESFilmicToneMapping;
document.body.appendChild(renderer.domElement);

export const scene = new THREE.Scene();
// Environment map supplies soft reflections; dim fill + strong key keeps a visible dark side; rim light outlines edges.
scene.environment = new THREE.PMREMGenerator(renderer).fromScene(new RoomEnvironment()).texture;
scene.environmentIntensity = 0.35;
const key = new THREE.DirectionalLight(0xfff1d6, 2.5);
key.position.set(1, 2, 3);
const rim = new THREE.DirectionalLight(0x8fb4ff, 1.5);
rim.position.set(-2, 1, -3);
scene.add(new THREE.HemisphereLight(0xfff4e0, 0x10101a, 0.4), key, rim);

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
