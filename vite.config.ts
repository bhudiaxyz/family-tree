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
