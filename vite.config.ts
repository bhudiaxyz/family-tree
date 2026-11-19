// Vite config: served under /family-tree/ (GitHub Pages path) on port 5173, targeting es2020.
// three.js is split into its own "three" chunk; chunkSizeWarningLimit is raised to 800 kB because that chunk is large.
// Keep `base` in step with where the site is deployed.

import { defineConfig } from "vite";

export default defineConfig({
    base: "/family-tree/",
    server: { port: 5173 },
    build: {
        target: "es2020",
        chunkSizeWarningLimit: 800,
        rollupOptions: {
            output: {
                manualChunks: (id) => (id.includes("three") ? "three" : undefined),
            },
        },
    },
});
