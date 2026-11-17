// Nebula sky fragment shader, baked into a cube texture by nebula.ts (see the notes there). Each fragment's vDir is a
// direction on the sky sphere. __OCTAVES__ is substituted with the tier's octave count before compiling.
precision highp float;
uniform float seed;
uniform float res1;
uniform float res2;
uniform float resMix;
uniform float maxLuma;
uniform float brightness;
uniform vec3 haze;
uniform vec3 starColour;
uniform float starDensity;
uniform float galaxyDensity;
uniform float dustLanes;
uniform vec3 emissionH;
uniform vec3 emissionO;
uniform vec3 reflectionBlue;
uniform sampler2D palette;
varying vec3 vDir;

#define OCTAVES __OCTAVES__ // replaced per bake (nebula.ts): loop bounds must be constants in GLSL ES

// Classic 3D Perlin noise (Stefan Gustavson, public domain) — the "glsl-noise/classic/3d" the original imports.
vec4 permute(vec4 x) { return mod(((x * 34.0) + 1.0) * x, 289.0); }
vec4 taylorInvSqrt(vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }
vec3 fade(vec3 t) { return t * t * t * (t * (t * 6.0 - 15.0) + 10.0); }
float cnoise(vec3 P) {
    vec3 Pi0 = floor(P), Pi1 = Pi0 + vec3(1.0);
    Pi0 = mod(Pi0, 289.0); Pi1 = mod(Pi1, 289.0);
    vec3 Pf0 = fract(P), Pf1 = Pf0 - vec3(1.0);
    vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
    vec4 iy = vec4(Pi0.yy, Pi1.yy);
    vec4 iz0 = Pi0.zzzz, iz1 = Pi1.zzzz;
    vec4 ixy = permute(permute(ix) + iy);
    vec4 ixy0 = permute(ixy + iz0), ixy1 = permute(ixy + iz1);
    vec4 gx0 = ixy0 / 7.0, gy0 = fract(floor(gx0) / 7.0) - 0.5;
    gx0 = fract(gx0);
    vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
    vec4 sz0 = step(gz0, vec4(0.0));
    gx0 -= sz0 * (step(0.0, gx0) - 0.5); gy0 -= sz0 * (step(0.0, gy0) - 0.5);
    vec4 gx1 = ixy1 / 7.0, gy1 = fract(floor(gx1) / 7.0) - 0.5;
    gx1 = fract(gx1);
    vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
    vec4 sz1 = step(gz1, vec4(0.0));
    gx1 -= sz1 * (step(0.0, gx1) - 0.5); gy1 -= sz1 * (step(0.0, gy1) - 0.5);
    vec3 g000 = vec3(gx0.x, gy0.x, gz0.x), g100 = vec3(gx0.y, gy0.y, gz0.y);
    vec3 g010 = vec3(gx0.z, gy0.z, gz0.z), g110 = vec3(gx0.w, gy0.w, gz0.w);
    vec3 g001 = vec3(gx1.x, gy1.x, gz1.x), g101 = vec3(gx1.y, gy1.y, gz1.y);
    vec3 g011 = vec3(gx1.z, gy1.z, gz1.z), g111 = vec3(gx1.w, gy1.w, gz1.w);
    vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
    g000 *= norm0.x; g010 *= norm0.y; g100 *= norm0.z; g110 *= norm0.w;
    vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
    g001 *= norm1.x; g011 *= norm1.y; g101 *= norm1.z; g111 *= norm1.w;
    float n000 = dot(g000, Pf0), n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
    float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z)), n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
    float n001 = dot(g001, vec3(Pf0.xy, Pf1.z)), n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
    float n011 = dot(g011, vec3(Pf0.x, Pf1.yz)), n111 = dot(g111, Pf1);
    vec3 fade_xyz = fade(Pf0);
    vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
    vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
    return 2.2 * mix(n_yz.x, n_yz.y, fade_xyz.x);
}

vec3 hash3(vec3 p) {
    p = vec3(dot(p, vec3(127.1, 311.7, 74.7)), dot(p, vec3(269.5, 183.3, 246.1)), dot(p, vec3(113.5, 271.9, 124.6)));
    return fract(sin(p) * 43758.5453123);
}
float hash1(vec3 p) { return fract(sin(dot(p, vec3(91.7, 47.3, 13.9))) * 15731.743); }

// Sparse stars: Worley-style cells, but only a fraction (density) of cells holds a star at all, and each star
// has its own brightness. This is what keeps it "a sprinkling": the original put a point in EVERY cell, which
// reads as an even layer of dots across the whole sky.
float stars(vec3 p, float density, float sharpness) {
    vec3 i = floor(p), f = fract(p);
    float s = 0.0;
    for (int x = -1; x <= 1; x++)
    for (int y = -1; y <= 1; y++)
    for (int z = -1; z <= 1; z++) {
        vec3 o = vec3(float(x), float(y), float(z));
        vec3 cell = i + o;
        if (hash1(cell) > density) continue; // most cells are empty
        float dist = length(o + hash3(cell) - f);
        float brightness = 0.35 + 0.65 * hash1(cell + 7.1);
        s = max(s, brightness * pow(max(0.0, 1.0 - dist * 1.25), sharpness));
    }
    return s;
}

// Galaxies: soft, cloud-like discs a few degrees across, seen at a random tilt. Most are spirals (two or three
// logarithmic arms, broken into clumps by noise, with dark dust between them); a few are smooth ellipticals.
// A warm core (old stars) fades to bluer outskirts (young stars in the arms). One possible galaxy per large cell
// on the sky sphere, and only a few cells (density) hold one. Returns colour, not yet scaled to the sky's level.
vec3 galaxies(vec3 d, float scale, float density) {
    vec3 p = d * scale + seed; // the seed moves the cell grid, so each saga has its own galaxies
    vec3 i = floor(p), f = fract(p);
    vec3 col = vec3(0.0);
    for (int x = -1; x <= 1; x++)
    for (int y = -1; y <= 1; y++)
    for (int z = -1; z <= 1; z++) {
        vec3 o = vec3(float(x), float(y), float(z));
        vec3 cell = i + o;
        if (hash1(cell + 3.3) > density) continue;
        vec3 rel = o + 0.25 + 0.5 * hash3(cell + 11.0) - f;
        float size = 0.14 + 0.18 * hash1(cell + 31.0); // disc radius, in cell units
        if (length(rel) > size * 2.5) continue;           // too far to contribute: skip the noise below
        // Disc frame: (u, v) in the galaxy's plane, h along its axis. Dividing h out by the tilt is what makes a
        // face-on disc round and an edge-on one a thin streak.
        vec3 ax = normalize(hash3(cell + 19.0) - 0.5);
        vec3 ay = normalize(cross(ax, normalize(hash3(cell + 23.0) - 0.5)));
        vec3 az = cross(ax, ay);
        vec2 uv = vec2(dot(rel, ax), dot(rel, ay)) / size;
        float h = dot(rel, az) / size;
        float r = length(uv);
        float thick = 0.12 + 0.1 * hash1(cell + 29.0);
        float disc = exp(-r * 1.6) * exp(-h * h / (thick * thick));
        float bulge = exp(-(r * r + h * h) * 30.0);
        float spiral = step(0.2, hash1(cell + 41.0)); // 80% spirals, 20% ellipticals
        float arms = 2.0 + step(0.6, hash1(cell + 43.0));
        float wind = 3.0 + 3.0 * hash1(cell + 47.0); // how tightly the arms wind
        float theta = atan(uv.y, uv.x);
        float arm = 0.5 + 0.5 * cos(arms * (theta - wind * log(r + 0.05)) + hash1(cell + 53.0) * 6.283);
        arm = pow(arm, 2.5);
        // Clumps and dust: noise in the disc plane breaks the arms into knots and cuts dark lanes through them.
        float clump = 0.5 + 0.5 * cnoise(vec3(uv * 6.0, hash1(cell + 59.0) * 50.0));
        float dust = smoothstep(0.35, 0.75, 0.5 + 0.5 * cnoise(vec3(uv * 11.0, hash1(cell + 61.0) * 50.0 + 7.0)));
        float spiralLight = disc * (0.5 + 3.6 * arm * clump) * mix(1.0, 0.45, dust * arm);
        float ellipticalLight = 0.7 * exp(-r * r * 2.5 - h * h * 4.0) * (0.85 + 0.3 * clump);
        float light = mix(ellipticalLight, spiralLight, spiral) * (0.6 + 0.4 * hash1(cell + 37.0));
        vec3 warm = vec3(1.0, 0.86, 0.66);
        vec3 cool = mix(vec3(0.62, 0.72, 1.0), vec3(0.95, 0.75, 0.95), hash1(cell + 67.0) * 0.5);
        col += mix(warm, mix(warm, cool, smoothstep(0.1, 0.8, r)), spiral) * light + warm * bulge * 1.4;
    }
    return col;
}

// Same shaping as the original: a folded sine of noise, summed over octaves.
float cloud(vec3 p, float s) {
    float n = cnoise(p + s);
    return sin(n * 4.0 * cos(n * 2.0)) * 0.5 + 0.5;
}
float cloudNoise(vec3 p, float frq, float s) {
    float n = 0.0, gain = 1.0;
    for (int i = 0; i < OCTAVES; i++) {
        n += cloud(p * gain / frq, s + float(i) * 10.0) * 0.5 / gain;
        gain *= 2.0;
    }
    return n;
}
float ridged(vec3 p, float frq, float s) {
    float n = 0.0, gain = 1.0;
    for (int i = 0; i < OCTAVES; i++) {
        n += abs(cnoise(p * gain / frq + s + float(i) * 10.0)) * 0.5 / gain;
        gain *= 2.0;
    }
    n = 1.0 - n;
    return 1.0 - n * n;
}

void main() {
    vec3 d = normalize(vDir);

    // 1. NEBULA DUST, coloured the way real nebulae are. Their colour is physics, not a free choice:
    //    - hydrogen-alpha emission glows crimson / magenta (most of what you see in emission nebulae);
    //    - doubly-ionised oxygen (O III) glows teal / cyan, usually nearer hot young stars;
    //    - reflection nebulae (dust scattering starlight) are a pale blue;
    //    - cold dust absorbs light, cutting dark brown-black lanes through the glow.
    //    Each component gets its OWN noise field, so the colours sit side by side in separate structures (as in
    //    Hubble images) instead of averaging into the muddy brown a single blended palette produced.
    //    c1 warps everything (domain warping gives the wispy, folded shapes).
    float c1 = cloudNoise(d, res1, seed);
    float c2 = cloudNoise(d + vec3(c1 * res2 * 0.2), res2, seed + 310.4);
    float c3 = cloudNoise(d + vec3(c1 * 0.15), resMix, seed + 661.384);
    float c4 = cloudNoise(d * 1.3 + vec3(c2 * 0.25), res2 * 0.8, seed + 902.7);

    // Coverage: each component only switches on in the denser part of its noise, so clouds fill roughly a third
    // of the sky and the rest stays dark space. Summed octaves cluster around 0.5, so thresholds must sit above
    // that: at 0.30–0.46 almost every pixel passed and the whole sky became an evenly lit coloured wall.
    float hAlpha = pow(smoothstep(0.55, 0.85, c2), 2.0);      // crimson clouds
    float oxygen = pow(smoothstep(0.60, 0.88, c3), 2.4);      // teal, in smaller pockets
    float reflection = pow(smoothstep(0.62, 0.90, c4), 2.6);  // pale-blue wisps
    vec3 col = emissionH * hAlpha + emissionO * oxygen * 0.85 + reflectionBlue * reflection * 0.6;

    // Where hydrogen and oxygen overlap real nebulae turn magenta-pink rather than grey; keep that, gently.
    col += vec3(0.25, 0.0, 0.18) * hAlpha * oxygen;

    // Per-saga variation within the theme: a subtle tint from the generated palette (palettes.ts hue range).
    col *= mix(vec3(1.0), texture2D(palette, vec2(c3, c1)).rgb * 3.0, 0.25);

    // Dark dust lanes: a finer warped noise absorbs light in filaments through the glow (the dark rifts of real
    // emission nebulae), which gives the dust depth and structure rather than a flat haze.
    float lanes = cloudNoise(d * 1.7 + vec3(c2 * 0.35), res1 * 0.6, seed + 127.9);
    col *= mix(1.0, smoothstep(0.32, 0.62, lanes), 0.7 * dustLanes);

    // Faint haze so the gaps between clouds aren't pure black.
    // Only where there's some cloud nearby (so empty space stays truly dark), and tiny: on an sRGB display even
    // linear 0.003 shows as ~7% grey, which made the whole sky look evenly lit when this was added everywhere.
    col += haze * ridged(d, 1.0, seed + 38.476) * smoothstep(0.30, 0.60, max(c2, c3));


    // OVERALL LEVEL: the sky is a faint background and the tree is the focal point, so everything is scaled well
    // down first. Tune "brightness" (palettes.ts) to make the whole sky dimmer or brighter.
    col *= brightness;

    // READABILITY CAP (soft knee) on SCREEN brightness. The cube texture is sRGB, so a linear value v is shown as
    // roughly v^(1/2.2): linear 0.12 displays as ~38%, which is why an earlier linear cap of 0.12 still looked
    // bright. maxLuma is the on-screen limit (0–1); convert it to linear here. Below the knee nothing changes,
    // so the dust keeps its range; only the brightest patches are compressed smoothly towards the limit.
    float capLin = pow(maxLuma, 2.2);
    float luma = dot(col, vec3(0.2126, 0.7152, 0.0722));
    float knee = capLin * 0.5;
    if (luma > knee) {
        float over = luma - knee;
        float target = knee + (capLin - knee) * (1.0 - exp(-over / (capLin - knee)));
        col *= target / luma;
    }
    col = min(col, vec3(capLin * 1.8)); // hard ceiling for any single channel (bright star/galaxy cores)

    // 2. A SPRINKLING OF STARS, added AFTER the cap. Added before it (as at first), a star on top of a cloud
    //    that was already near the limit got squashed flat by the soft knee, and the stars all but vanished.
    //    Here they sit on top as crisp points with their own ceiling (starCap), still faint next to the labels.
    //    Densities are per cell: at 420 cells across a face even 6% is thousands of dots (an even dusting), so the
    //    faint layer is under 1%; bright stars are a little more common inside the dust (star-forming regions).
    float bright = stars(d * 160.0 + seed, starDensity * 0.08, 10.0);
    float faint = stars(d * 420.0 + seed * 1.7, starDensity * 0.010, 16.0);
    float starCap = pow(maxLuma * 2.6, 2.2); // stars may reach ~31% on screen: visible points, never a glare
    col += starColour * starCap * min(1.0, bright * (0.55 + hAlpha) + faint * 0.6);

    // 3. A FEW GALAXIES: soft cloud-like spirals and ellipticals, added after the cap like the stars, with their
    //    own ceiling (~26% on screen at their brightest core) so they read as distant glows behind the tree.
    vec3 gal = galaxies(d, 3.0, galaxyDensity);
    float galCap = pow(maxLuma * 2.2, 2.2);
    col += galCap * gal / (1.0 + max(gal.r, max(gal.g, gal.b))); // soft-saturate so cores never clip to white

    gl_FragColor = vec4(col, 1.0);
}
