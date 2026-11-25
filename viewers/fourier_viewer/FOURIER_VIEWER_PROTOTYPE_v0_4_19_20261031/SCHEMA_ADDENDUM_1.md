# Schema addendum 1: three tabs, the host's views, look and feel

Date: 2026-10-13. Owner: Opus (B1-viewer owner session). This addendum extends SCHEMA.md; where the two differ, this one governs.

## Authority

saphir, 2026-10-13, in the owner session's chat:
1. "I want the three main windows. the original fourier instrument, the clifford torus, and the hopf display, also the cubic fourier viewer goes that way"
2. "they can all be on tabs."
3. "they all share the settings"
4. "lets keep the look and feel of the old viewer but it has to reflect the current state of the mathematics"
5. "I want to have the readouts of the phasors, gearbox, wilson, the main controls that are the classical instrument, divisors,"
6. "we need full controls on the viewer windows, keep the json and png outputs"

## Source

The host conventions below come from a read-only extraction of the frozen host `cold audit fourier/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/monodromy-31-linked-reduction.html`. "L" means a line number in that file. The builder may read the cited line ranges, read-only.

## A0. Shell and settings

- **Tabs:** `Fourier` | `Clifford` | `Hopf`, one visible at a time. Room is left for more tabs; the cubic Fourier viewer will be rebuilt on this structure later.
- **One shared state** drives every tab, and switching tabs changes nothing but `tab`.
- **Host name map.** n₇ = φ₃ − 1, and N = n₃ = B − n₇ = B + 1 − φ₃.
- **Display text** keeps the host labels where they exist ("N = …").

## A. Fourier tab (host Plane view, `renderPhasorSvg` L9735–~10040, `computeVernier` L7365–7432)

**Maths.**
- k_c = N·t₁ + c·t₂. Radius ρ = n₆·N^α, which is 0 when n₆ = 0.
- Tooth phase: exp(iπ(t₁s + c·t₂·s/N)) = exp(iπ·k_c·s/N). The exact phase reduction stays in comb-core.
- Sum identity: Σ z_c = ρ·e^{iπt₁s}·K_m(β), with β = π·t₂·s/N.
  - K_odd = sin(mβ/2)/sin(β/2);
  - K_even = sin(mβ)/sin(β).
- **Exact flags** (exact register), decided in comb-core on rationals. Each is labelled with its exact condition:
  - **ALIGN:** t₁·s ∈ ℤ.
  - **SPREAD:** K_m = 0.
    - Odd m: m·t₂·s/(2N) ∈ ℤ and t₂·s/(2N) ∉ ℤ.
    - Even m: m·t₂·s/N ∈ ℤ and t₂·s/N ∉ ℤ.
  - Verify both K_m conditions against the closed form before relying on them. Add a test that compares the exact flag with the numerical |K_m| at random states.
- **Q-res = |Im Σ|** is numerical: label it, with its bound.

**Drawing.**
- **Background:** polar grid circles at "nice" radii (1/2/5/10 steps), stroke `--line-grid`, width 0.8; axes `--line-axis`, width 1.
- **Radius circle:** dashed, radius |ρ|, `--text-mid`, opacity 0.45, dash 3,4.
- **Teeth:**
  - tooth rays from the origin, in tooth colour: width 3 for |c| = 1, 2.2 otherwise;
  - the carrier ray in purple `--accent-z0`, dashed, width 2.5;
  - tooth markers: ring r = 3, then a filled dot with a white stroke.
- **Walk and sum:**
  - partial-sum walk W_t in `--accent-spine` (amber) with small vertex dots;
  - the endpoint Σ as a spine-coloured circle plus a 3 px dot;
  - an origin dot, white.
- **Overlays:**
  - `N = …`;
  - `Q-res = …` (numerical, labelled), green when s ∈ ℤ and cyan otherwise;
  - `s ∈ ℤ → sin(sπ) = 0` when it applies.
- **Deferred:** the rosette, the "contrast" overlay and the noise-minima markers wait until addendum 2 defines them. Do not invent them.

**Interaction.**
- Drag pans, the wheel zooms (zoom 0.5–1000), and two-finger pinch zooms.
- Tap or click picks a tooth, which highlights its row in the phasor table.

## B. Clifford tab (host `PlaneCliffordLiftCore` L4648, `liftToS3` L4766, `stereographicProject` L4842, `renderClifford` L11546)

**Lift to S³.** Verbatim from the host, L4775–4813. The exact phases go in comb-core; the floats go in comb-numeric.
- carrier u = π·t₁·s, plus π if n₆ < 0, goes to z₁;
- offset v = π·c·t₂·s/N goes to z₂ with a **negative** sign;
- ρ = |n₆|·N^α;
- z₁ = (ρ/√(1+ρ²))·e^{iu} and z₂ = (1/√(1+ρ²))·e^{−iv};
- identity: z₁/z₂ = ρ·e^{iπ·k_c·s/N}, which is the Fourier tooth. Test it numerically.
- **Exact register:** the carrier phase t₁·s mod 2, plus 1 if n₆ < 0, and the offset phase −c·t₂·s/N mod 2, each with its cyclotomic order. These appear in the phasor table as two extra columns, "carrier" and "offset".

**Projection.**
- Stereographic from the north pole x₄ = +1, with (x₁, x₂, x₃, x₄) = (Re z₁, Im z₁, Re z₂, Im z₂).
- d = 1 − x₄, computed stably as (x₁² + x₂² + x₃²)/(1 + x₄) when x₄ > 0.
- Image = (x₁, x₂, x₃)/d.
- If d < 1e-9 the point is labelled AT_INFINITY or CLIPPED_NEAR_POLE and is not drawn as a finite point (the degenerate case is labelled).
- The leaf of radius ρ projects to a torus with main radius √(1+ρ²)/ρ and tube radius 1/ρ.

**Drawn.**
- **Clifford reference surface:** a 64×32 mesh with |z₁| = |z₂| = 1/√2 (R = √2, r = 1), `rgb(184,192,212)` at alpha 0.02–0.09, width 0.55, labelled "Clifford reference surface · guide only".
- **Actual leaf mesh at the current ρ:** `rgb(34,211,238)` at alpha 0.04–0.21, width 0.78.
- **The current teeth** as dots in tooth colour.
- **The s-orbits:** each tooth's curve as s varies over one period window. Sample it like the Hopf trails (see C).
- **Toggles:** "Tρ leaf", "s-orbits", "Grid", "Four circles".
- **Four circles:** meridian `#38bdf8`, parallel `#34d399`, Hopf `#fbbf24`, opposite `#f472b6`, at widths 2.4–2.7.
- **Degenerate cases:**
  - ρ = 0: the leaf collapses to the circle z₁ = 0, which projects to a circle. Draw it and label it.
  - N ≤ 0: no lift; label it.

**Camera.**
- Yaw about z, then pitch about x, then an orthographic projection. The fit uses the union of the points and the guide: `fit = min((W−48)/spanX, (H−48)/spanY)`. Points are depth-sorted.
- Defaults: azimuth −0.65, elevation 0.45, zoom 0.95.
- **Drag:** azimuth +0.008 per px, elevation +0.008 per px, clamped to ±(π/2 − 0.01).
- **Wheel and pinch:** ×0.9 or ×1.1, clamped to 0.25–8.
- **Buttons:** ISO TOP, ISO SIDE, Top (a camera ray along +z collapses the torus to an annulus), and Reset.

**Wrap gate.** With the Clifford tab present, the S³ lift is a drawn object. The R21 wrap gate therefore requires, for every drawn tooth:
- k_c ∈ ℤ;
- N·t₁ ∈ ℤ;
- c·t₂ ∈ ℤ.

This follows REQUIREMENTS v0.1.7 l.252 and bus #366. The gate is decided over the instrument's drawn objects, never over the active tab, so switching tabs never changes s_eff.

## C. Hopf tab (host `HopfBaseDisplayV1` L8027–8135, `renderHopfBase` L12018–~12200)

- **Map:** `HOPF_BASE_S2_Z1_Z2_V1`:
  - q = (2(Re z₁ Re z₂ + Im z₁ Im z₂), 2(Im z₁ Re z₂ − Re z₁ Im z₂), |z₁|² − |z₂|²);
  - `fromAffine(w) = [2Re w, 2Im w, |w|²−1]/(1+|w|²)`;
  - w = z₁/z₂ (chart `CP1_AFFINE_Z1_OVER_Z2_V1`). North is w = ∞; south is w = 0.
- **Gates.** Port both and run them in the tests. In the page, a gate failure shows a labelled red banner instead of throwing.
  - `G-HOPF-BASE-S2-01` fixtures:
    - (1,0),(0,0) → (0,0,1);
    - (0,0),(1,0) → (0,0,−1);
    - (√½,0),(√½,0) → (1,0,0);
    - (0,√½),(√½,0) → (0,1,0);
    - fromAffine(1) → (1,0,0).
  - `G-HOPF-BASE-S2-CHART-COMPAT`: for every current tooth, the S² point from the S³ lift equals fromAffine(Fourier tooth z) to within 1e-10.
- **Walk on S² (comb addition, SCHEMA §4):**
  - the partial sums W_t, mapped by fromAffine;
  - the chart toggle "host chart w = W" (default) or "comb-page chart w = W/ρ".
  - The walk is new in this view, so it is drawn in `--accent-spine` and labelled "comb walk (partial sums)".
- **Sphere:**
  - an orthographic disc of radius min(W,H)·0.385·zoom, centred at (W/2, H/2 + 3);
  - fill: a radial gradient `rgba(226,232,240,0.22)` → `rgba(71,85,105,0.17)` → `rgba(15,23,42,0.52)`;
  - rim: `rgba(203,213,225,0.58)`, width 1.4.
- **Grid:**
  - latitudes at z = 0, ±0.25, ±0.5, ±0.75, and 12 longitudes;
  - front lines `rgba(148,163,184,0.28)`, the equator at 0.48 with width 1.15;
  - back lines `rgba(100,116,139,0.12)`;
  - axes q₁, q₂, q₃ in `rgba(165,180,252,0.48)`, with labels "N · w=∞" and "S · w=0".
- **Current latitude circle:** at q₃ = (ρ²−1)/(ρ²+1), amber `rgba(251,191,36,0.74)`, width 1.8.
- **Tooth trails:** 49 samples over s ± 1.15π/|rate|, with rate = π·k_c/N (rate = 0: no trail, labelled stationary).
  - Colour `toothColorRgba(c, 0.72)`, width 1.55.
  - A selected trail is at 0.98, width 3.
- **Tooth dots:**
  - r = 5.2, or 7.2 when selected;
  - alpha 0.98 in front, 0.48 behind;
  - a selected dot has a white stroke, a dashed ring and a signed label.
- **Overlays:**
  - "Hopf base S² ≅ CP¹ · n current teeth";
  - the latitude q₃ with ρ, and the chart agreement;
  - the selection q = (…);
  - "Plane chart w = Z₁/Z₂ = …";
  - the gate status: "G-HOPF-BASE-S2-01 PASS · each complete Hopf fibre maps to one base point · DISPLAY ONLY".
- **Camera:**
  - default azimuth −0.72, tilt 0.24;
  - yaw, then tilt: `[horizontal, ct*z − st*depth0, st*z + ct*depth0]`;
  - drag: azimuth +0.008·dx, tilt −0.008·dy (clamped ±π/2);
  - zoom 0.65–1.45, wheel ×0.92 or ×1.08, buttons ×1.1;
  - Reset;
  - tap selects the nearest tooth.

## D. Look and feel (host L1211–1229, L1237, L1263; dark only in the host)

**Palette.**

```
--bg-deep:#0c0c18; --bg-panel:#131321; --bg-inset:#08080f; --bg-card:#0e0e1a;
--line-grid:#2e2e4a; --line-axis:#45456a;
--text-dim:#6a6a86; --text-mid:#9999b3; --text-bright:#d4d4e8;
--accent-z1:#00e5ff; --accent-z2:#ff5e6c; --accent-z0:#a855f7;
--accent-warn:#fbbf24; --accent-good:#10b981; --accent-defend:#ff4444;
--accent-spine:#f59e0b; --accent-purple:#a855f7;
```

- The page is dark only, like the host. SCHEMA §8's light/dark line is withdrawn.

**Fonts.**
- No web fonts.
- Body: `ui-monospace, SFMono-Regular, Menlo, Consolas, 'JetBrains Mono', monospace`, 13px, line-height 1.45.
- Title h1: `Georgia, 'Cormorant Garamond', 'Times New Roman', serif`, weight 500, 26px.
- SVG text: 10px, using the same monospace stack.

**Layout.**
- Body padding 24px (12px at ≤ 480 px), with a faint radial wash: `rgba(0,229,255,0.05)` at 12% 8% and `rgba(255,94,108,0.05)` at 88% 92%.
- `.header`: max-width 1200px, with a bottom border in `--line-axis`.
- `.panel`: `--bg-panel` background, radius 6px, padding 14px, border `1px solid --line-grid`.
- `.panel-label`: 9px, uppercase, letter-spacing 0.2em, `--text-dim`.

**Controls.**
- Buttons and inputs on `--bg-inset`. Hover and focus use a `--accent-z1` border.
- A pressed tab or toggle (`aria-pressed`) has a cyan fill with `--bg-deep` text.
- The primary action uses an `--accent-spine` fill.
- Sliders use `accent-color: --accent-z1`.

**View frame.**
- The `.svg-frame` has a `--bg-deep` background, a `--line-grid` border, radius 4px, `cursor: grab` and `touch-action: none`.

**Tooth colours.** Pairs are (negative c, positive c), by |c| rank:

| Rank | negative c | positive c |
|---|---|---|
| 1 | `#00e5ff` | `#ff5e6c` |
| 2 | `#10b981` | `#fbbf24` |
| 3 | `#3b82f6` | `#f472b6` |
| 4 | `#84cc16` | `#fb923c` |
| 5 | `#2dd4bf` | `#e879f9` |
| 6 | `#a3a3c2` | `#eab308` |

- The cycle repeats beyond rank 6.
- c = 0 (odd m) uses `--text-bright`.
- The carrier is `--accent-z0`.

## E. Current mathematics over host behaviour

Where the host and the current mathematics differ, the current mathematics wins. That means:
- R20/R21 stepping and the spin address;
- the v0.3.2 wording: "Exact neighbouring-tooth alignment", "ALIGN stop (t₁·s ∈ ℤ)", never a bare "contact", and the two distinct Wilson readouts;
- the three registers kept apart, with every numerical value labelled;
- degenerate cases drawn and labelled.

The host's "FLOAT64 DISPLAY ONLY" labels stay where they are true.

## F. Readouts and controls (addendum 2 to follow)

Coming in addendum 2:
- the phasor table and its columns;
- the gearbox readout (port v0.3.2 `gearbox.js analyze()` now);
- both Wilson readouts;
- the divisors readout;
- the classical instrument's main control set;
- the per-view host controls;
- the host's JSON/PNG export formats.

Until then, build them as in my messages: shared readout cards, generic view controls, Export state, Export exact, Export PNG and Export pair.
