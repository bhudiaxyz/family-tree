// Entry point. Checks WebGL first and only then loads the 3D app, so a browser without WebGL gets a clear message
// (and the saga list is still readable) instead of a blank page or an uncaught error.
import "./style.css";

const notice = document.getElementById("no-webgl")!;

function showNotice(reason: string) {
    document.getElementById("no-webgl-reason")!.textContent = reason;
    notice.hidden = false;
    document.body.classList.add("no-3d");
}

import("./app.ts").catch((e: Error) => {
    // NoWebGLError from scene.ts, or a failed chunk download (offline / blocked); either way the 3D view can't start.
    const reason =
        e.name === "NoWebGLError" || /webgl/i.test(e.message) ? e.message : `The app failed to load: ${e.message}`;
    showNotice(reason);
    console.error(e);
});
