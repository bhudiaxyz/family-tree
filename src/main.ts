// Entry point: checks WebGL, then loads the 3D app, so a browser without it gets a message instead of a blank page.
//
// What it does: imports style.css, then dynamically imports app.ts; if that fails, shows the #no-webgl notice from
// index.html with the reason and adds the "no-3d" class to <body>.
// Usage: the script tag in index.html; exports nothing.
// Notes: app.ts must stay a dynamic import. scene.ts throws NoWebGLError at import time when WebGL 2 is missing, and
// only a dynamic import lets that be caught here (a failed chunk download, offline or blocked, takes the same path).
// The saga list stays readable in the notice state, which is what "no-3d" is for in style.css.

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
