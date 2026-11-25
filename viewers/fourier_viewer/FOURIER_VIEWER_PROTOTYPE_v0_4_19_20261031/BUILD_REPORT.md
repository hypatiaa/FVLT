# BUILD_REPORT — Fourier viewer prototype v0.1 (2026-10-13)

Builder: Claude Sonnet 5.5 (subagent). Built to SCHEMA.md plus ADDENDUM 1–4 and the coordinator's mid-task messages (tabs, shared state, readouts, view controls, exports, large type, clean surface). `SCHEMA*.md` untouched. Nothing outside this folder was edited; the frozen v0.3.2 folder was only `require`d read-only by tests and the parity sample.

## Files (bytes)

| File | Bytes |
|---|---|
| exact-lib/exact.js | 6980 |
| exact-lib/test-exact.cjs | 3314 |
| host-core/comb-core.js | 15225 |
| host-core/comb-numeric.js | 8488 |
| host-core/gearbox-core.js | 2480 |
| host-core/shell-core.js | 4594 |
| host-core/fraction-stack-core.js | 3335 |
| host-core/reference-stops.cjs (shares no code) | 2065 |
| host-core/test-core.cjs | 31511 |
| host-core/parity-sample.cjs | 4170 |
| instruments/comb-hopf/views-common.js | 7628 |
| instruments/comb-hopf/view-fourier.js / view-clifford.js / view-hopf.js / view-panels.js | 7194 / 7601 / 7600 / 6190 |
| instruments/comb-hopf/panel.js | 33905 |
| instruments/comb-hopf/index.html (dev page) | 8171 |
| instruments/comb-hopf/README.md (dial ledger, degenerate cases, deferred list) | 8345 |
| build/package.cjs, build/browser-check.cjs, build/contrast-check.cjs | 1345, 6913, 1781 |
| dist/comb-hopf.html (single self-contained file) | 119070 |
| dist/MANIFEST.sha256 | 1247 |
| shot_*.png (375x812 and 1280x800, every tab; Clifford with fraction stack), export_*.png (PNG exports from the browser test) | in folder root |

Dist page sha256: `9c8780056c990619f7a59bfca119f1af41941a3c88754407e58b1163253b2f1b`. `sha256sum -c dist/MANIFEST.sha256` (run from the folder root) verifies every module and the page: all OK.

## Commands run (from the prototype folder)

```
node exact-lib/test-exact.cjs
node host-core/test-core.cjs
node host-core/parity-sample.cjs
node build/package.cjs
node build/contrast-check.cjs
node build/browser-check.cjs          (Playwright 1.61.1 from s6_atom/node_modules, chromium, file://, no server)
sha256sum -c dist/MANIFEST.sha256
```

## Test summary lines (verbatim)

```
test-exact: 20 passed, 0 failed
test-core: 80 passed, 0 failed
browser-check: 46 passed, 0 failed
contrast-check: 93 pass, 0 fail
parity sample: 2000 states; exact phase/k_c differences: 0; stepper compared 2000, identical value 1587
UNEXPLAINED differences: 0
```

Test-core highlights (each a PASS line): the #245 witnesses (N=1, m=720, t₁=−3, t₂=−2, s=−1 forward gives −1439/1440; N=13!+1, m=7, t₁=t₂=3, s=10⁶ both directions); endpoint cases (i)–(v) with positive and negative controls; 4a–4f; a 5,000-state random sweep, both directions (stops 6721, range-limit landings 1524, no-movement 1713, 2258 dense states with m ≥ 300) against the independent `reference-stops.cjs` with a no-skip check on each, 0 mismatches; the D1 witness; invariant-wrap, dial-change (including the t₁ change that closes the gate, and play through N = 0), R21-S, R21-R, R21-EFF-REPLAY, mirror, two histories, unchanged-outcome byte identity, import refusal controls; exact SPREAD/ALIGN flags against numerical |K_m| < 1e-9 at 2,000 states (166 zero-kernel states, 0 disagreements); G-HOPF-BASE-S2-01 fixtures and CHART-COMPAT (worst 6.4e-16 over 300 states); S³ lift identity z₁/z₂ = ρ·e^{iπks/N}; stereographic statuses; gearbox analyze() against frozen v0.3.2 gearbox.js on 2,000 states (0 differences); Wilson shell-N N = 2…200 and order-m p = 2…200; divisors (T = 12, non-integer t₂·s, s = 0, t₂ = 0, truncation, refusal above 10¹⁸, factorisation of a 10¹⁸-scale semiprime); contrast at N = 5, 6, 7, 30; shell bracket; the fraction stack (host fixture B=24, N=9, m=5, s=72/5: q = 5, 630 heads, 126 columns, spread-zero columns exactly 18/5, 36/5, 54/5, 72/5, 108/5; lattice q cases; gate reasons; spread-zero agrees with a port of the host's `fractionSpinSpreadZero` and with numerical |K_m| on 9,830 columns of 200 random lattices; selection count min(raw, 4000) including 13!-scale raw counts); numerical register (gate residual within bound and unit norm < 1e-12 on 500 states, worst 3.3e-16).

Browser check (46): at 375 and 1280 px no console errors, zero network requests, no horizontal scroll, every tab renders, tab switch leaves settings unchanged; no visible text below 13 px on the Fourier, Clifford, Hopf and Panels tabs (about 205–260 text elements per check, SVG text scaled by the rendered viewBox factor); all buttons, inputs, selects and summaries ≥ 40 px high at both viewports; spin ◀ ▶ moves `s_typed`; a dial change keeps `s_typed`; the Clifford fraction stack caption appears; PNG export of the Fourier, Clifford and Hopf tabs downloads, the file has the PNG signature, and the SHA-256 shown in the page equals the file's; Export pair downloads 4 files; exact JSON ends with LF and omits tab and view; the Panels tab lists 17 cards; the ⓘ toggle opens the notes; dragging the Hopf view changes only the view state.

## Parity sample against v0.3.2 (informative, not R18)

2,000 random integer-gear states (m 2…720, N 1…10⁶, t₁, t₂ in −9…9 including 0, s with denominators up to 720). Exact k_c and tooth phases (mod 2): 0 differences. Stepper value: 1,587 identical, 413 different. Every difference, by class:

- **413 × class (a), mandated by R20.2/4e:** m ≥ 3 with t₁ = 0 or t₂ = 0 (host integer gearbox inactive). The host snaps to an integer (then clamps to its range); the rebuild refuses with the reason. Examples: m=3, t₁=−2, t₂=0, N=7, s=−869/2: host −434, rebuild refused. m=12, t₁=0, t₂=2, N=329, s=894/25: host 35, rebuild refused.
- **0 × class (d)** in this sample: no PAIR (m = 2) state landed within 1/1000 of an integer, so the host epsilon skip did not occur. The (d) classification code (reproduce the host with ε, reproduce the rebuild with ε = 0) exists but was not exercised.
- **0 unexplained.**

Not in the random sample, covered by named tests instead: the D1 typed-entry wrap (class (d) in R21; test "R21 D1 witness"), the unchanged range after a step (class (a)).

## Contrast ratios (WCAG, `node build/contrast-check.cjs`, all ≥ 4.5)

Host values for comparison: `--text-dim` #6a6a86 on #0c0c18 = 3.72 (fails); `--text-mid` #9999b3 on #131321 = 6.62 (passes, raised anyway for margin); host `--accent-defend` #ff4444 passes (5.70) but is raised to #ff6b6b.

| Text colour | on bg-deep | on bg-panel | on bg-card |
|---|---|---|---|
| `--text-dim` #9a9ab8 (raised) | 7.11 | 6.73 | 7.01 |
| `--text-mid` #b4b4cc (raised) | 9.56 | 9.05 | 9.43 |
| `--text-bright` #d4d4e8 | 13.30 | 12.58 | 13.12 |
| `--accent-z0-text` #c084fc (host #a855f7 is 4.84 on bg-card, kept for lines only) | 7.35 | 6.95 | 7.25 |
| `--accent-defend` #ff6b6b | 7.00 | 6.62 | 6.90 |
| pressed button: #0c0c18 on #00e5ff fill | 12.62 | | |

The full 93-pair table (every accent and tooth colour used as text, on all four backgrounds) is printed by the script. Tooth colours used as table text are lightened at run time by `readable()` until they reach 4.5 against the card background; the host blue #3b82f6 is 5.21 on bg-card, so only colours that fail are changed.

## Done

Four tabs on one shared state (Fourier, Clifford, Hopf, Panels) with the host's palette and fonts, dark only, large type, A−/A+ (90–160 %, localStorage, not exported); full classical control set; R20 exact stepper; R21 typed/effective spin with the drawn-objects wrap gate (k_c, N·t₁, c·t₂); phasor table (exact columns plus numerical z); gearbox, both Wilson readouts, divisors (exact, no integer shadow), shell card with exact contrast and bracket; per-view camera controls and layers; the S³ lift and Clifford torus with meshes and s-orbits; Hopf base with gates and trails; fraction stack (4,000-head budget, never materialised); all exports (JSON, state, CSV, Copy Stats, Lift JSON, PNG, pair) with SHA-256; Panels tab with 17 placeholder cards and the module interface `{id, title, group, register, coupling, source, render(el, model), actions}` plus `M.commit.spin / M.commit.dial` (R21 rules), open state in localStorage with try/catch; clean surface: provenance, gate ids, map ids, error-bound formulas and host line references sit behind ⓘ toggles, closed by default; a failing Hopf gate shows a red banner on the surface. The page contains no manifest, test output or review references.

## Not done, or uncertain (honest list)

- **R13a tension.** R13a asks each delivered page to record the digests of its shared-library modules. saphir's clean-surface rule says no manifests in the page. I followed the latter: the digests are in `dist/MANIFEST.sha256` beside the page, not inside it. Needs a decision.
- **Noise minima and trail** (host `buildTrail`): not ported; deferred and listed in the README. Rosette, stacks other than the fraction stack, weaves, sweep, η leaf sweep, M−/M+ rows deferred as instructed.
- **Contrast overlay:** only the exact contrast value line is shown on the Fourier tab; no separate host "contrast" overlay was invented.
- **PAIR guards:** m = 2 stepping is active whenever N > 0 (integer lattice), regardless of t₁, t₂. This is my reading of "its own guards"; not verified against anything else.
- **Four circles on the Clifford leaf** (meridian, parallel, Hopf, opposite) are my reading; the addendum gives colours and widths only. Gearbox "current comb order" wording is also my reading.
- **"Export Lift JSON" and the pair JSON** use new schema ids (`fv-comb-hopf-lift/0.1`, `fv-comb-hopf-pair/0.1`); the cubic-Fourier/host export formats were not reproduced.
- **PNG export** includes the caption lines drawn under the picture; the exported PNG's content was checked for validity and hash, not pixel-compared to the screen.
- **Phone:** tested only in Playwright emulation (375 px, touch flag); no real phone. Fraction-stack and Clifford drawing with 4,000 points was not timed on a phone.
- **Text-size 90 % step** renders smaller than 13 px by the user's own choice (the 13 px floor is guaranteed at 100 % and above). The font check ran at 100 %.
- **Copy Stats** clipboard path was not exercised in the browser test (the fallback text box is shown).
- Spread of `s` slider: the slider's decimal is `toFixed(6)`; for very large E the slider resolution is coarse (typed entry stays exact).
- The v0.1 offline certificate verifier is not built (only the exact export exists).
- The Panels tab's per-card open state uses localStorage; not tested across reloads.

## Fix round 1 (2026-10-13)

Four fixes requested by the coordinator; nothing else changed.

1. **R13a pins.** `dist/comb-hopf.html` now ends with a non-rendered `<script type="application/json" id="fv-build-pins">` block just before `</body>`, listing the schema id (`fv-comb-hopf/0.1`) and the path and sha256 of each of the 12 inlined modules. It is not shown in the UI. The page's own hash stays in `dist/MANIFEST.sha256` only. New test in `test-core.cjs`: the pins equal the hashes of the module files, in the inlined order, and the block sits at the end of the page. (This supersedes the "R13a tension" item above.)
2. **Text-size floor.** A− now stops at 100%; the range is 100–160%. The 13 px check was re-run at 100% and at 160% on the Fourier, Clifford, Hopf and Panels tabs at both 375 and 1280 px: no visible text below 13 px, and no horizontal scroll at 160%. (The 90% caveat in the earlier "Not done" list no longer applies.)
3. **Phasor table headers.** Headers are now `key`, `k_c`, `tooth φ (exact)`, `carrier (exact)`, `offset (exact)`, `z (numerical)`, set not to wrap. The column definitions moved behind the card's ⓘ. Browser check confirms the header height is a single line at both viewports.
4. **Carrier row.** Odd m: one row `z[0] (carrier)` (the carrier is the c = 0 tooth). Even m: no c = 0 tooth, so a separate row `carrier (not a tooth)` shows its exact phase t₁s (+1 if n₆ < 0) mod 2 with its order, and the numerical ρ·e^{iπt₁s}. Verified in the browser at m = 3 (one carrier row) and m = 4 (separate row, phase 1, order 2).

Results after the fixes (verbatim):

```
test-exact: 20 passed, 0 failed
test-core: 81 passed, 0 failed
browser-check: 64 passed, 0 failed
contrast-check: 93 pass, 0 fail
```

`sha256sum -c dist/MANIFEST.sha256`: all OK. Screenshots (`shot_*.png`) and the exported PNGs were regenerated by the browser check. The parity sample was not affected by the fixes (unchanged: 2000 states, 413 class (a), 0 unexplained).

**New dist sha256:** `a88f0c226d40f1f4661fd17ba0de3bba7b5e806a33c32e981b4096772e25231b` (dist/comb-hopf.html).

## Fix round 2 (2026-10-13)

Nine items from the cold verification (flags F1 to F9). Nothing else was changed. `SCHEMA*.md` and the VERIFY folder untouched.

1. **F1 Import state.** The export card has a paste box and a Load button. Load runs `C.importAny` (the URL-load R21.5 validation): refused as a whole with the reason shown, or restored exactly (`s_eff` as stored, never re-derived). Decision to note: on refusal the current state is kept unchanged (the URL path shows defaults because there is no current state); the message says so.
2. **F2 Numerical readouts.** The Phasors card (beside Q-residual) now shows, each labelled "numerical": `|W|` with ±bound, `|W|/ρ` with ±bound/ρ, and the W₁ latitude-gate residual with its bound and a within / EXCEEDS flag. At ρ = 0 the `|W|/ρ` row reads "|W|/ρ undefined (ρ = 0)".
3. **F3 ⛶ fullscreen.** Fourier, Clifford and Hopf: Fullscreen API on the view frame (webkit prefix fallback). Where it is unavailable or refused, the frame gets a CSS "maximised" class with a Close button (Esc also closes). Font scaling uses min(width/W, height/H) so SVG text stays ≥ 13 px when letterboxed.
4. **F4 ✥ pan on Clifford.** New toggle (view key `cp`): one-finger drag pans instead of rotating; Shift+drag still pans. Fourier already pans on every drag, so no toggle was added there (not requested).
5. **F5 Witness polygon.** Hidden whenever the shell changes (factorial n₁, or integer B, or the mode); Test is needed again. A φ₃ (N) or gear change does not hide it. Decision to note: "shell" is read as the base, since the witness is the independent candidate p with n₁ = p − 1.
6. **F6 "kept: wrap not invariant here".** New `C.wrapKept(st)`: N > 0, gate closed, and `center(s_typed, N) ≠ s_typed`. Shown for the D1 shell with s = 49 or −24; not shown for 5, 24, or when the gate is open (then the wrapped label shows instead).
7. **F7 Contrast band and lock.** New `SH.contrastBand(c)`: exact rational comparison against 3 and 2 (strict); the page uses it. The decimal is display only. Test uses 3 + 10⁻⁴⁰, where the float equals 3 but the exact band is "defend / lock".
8. **F8 ρ = 0 Clifford.** The leaf mesh is not drawn (the leaf is the circle z₁ = 0 through the projection pole); the x₃ axis is drawn as a line and labelled "a line through the origin, closed at ∞". The old "projects to a circle" wording is gone (page and README).
9. **F9 PAIR (m = 2).** Behaviour unchanged. README now has "Declared PAIR guard": owner decision 2026-10-13, integer lattice ℤ, active whenever N > 0 (R20.2 "PAIR declares its own guards"). A test pins it.

New tests: test-core +6 (contrastBand exact thresholds; contrastBand against BigInt cross-multiplication for N = 2…400; panel does not use the float; wrapKept D1 cases; wrapKept over 1,500 random states; PAIR guard). browser-check +88 (152 total): import (address and JSON, restore as stored, 5 refusals each with state unchanged, empty box), R21.2 label present and absent, witness hide and its controls, numerical readouts, ρ = 0 axis and label with control, ✥ pan versus rotate, real fullscreen on three tabs, maximised fallback with Close and Esc on three tabs, contrast colour and lock at N = 30, 6, 5. A first browser run failed only on my own wait selector after `reload` (the Hopf tab's first SVG element is hidden `<defs>`); fixed the selector, no check was changed.

Results after the fixes (verbatim):

```
test-exact: 20 passed, 0 failed
test-core: 87 passed, 0 failed
contrast-check: 93 pass, 0 fail
browser-check: 152 passed, 0 failed
parity sample: UNEXPLAINED differences: 0 (unchanged)
```

`sha256sum -c dist/MANIFEST.sha256`: all OK. Screenshots regenerated (new: `shot_1280x800_clifford_rho0.png`). Not run in a real phone browser: ✥ pan was tested with mouse pointer events in a 375 px touch-flag context, and the real Fullscreen API was tested in headless Chromium only; the webkit-prefixed path was not exercised.

**New dist sha256:** `76bb9f0412bde760237b637c71ff454bfa34c46cb8084058f58976ae1ced263a` (dist/comb-hopf.html). This supersedes `a88f0c22…` and the older hash in the file table above.

## Fix round 3 (2026-10-13)

Two owner decisions applied; nothing else changed. `SCHEMA*.md` untouched.

1. **Import refusal (R21.5).** A pasted state that fails validation now behaves like a failing URL load: the current state is replaced by the explicit defaults (shown as a new state), the refusal reason is shown (status line and the import message), and the current state is not kept. The Fix round 2 item 1 "current state is kept unchanged" is superseded. Test changed: after each of the 5 refusals the state equals the defaults (and differs from the previous state) and the reason is visible. Empty box still says "Nothing to load" and changes nothing.
2. **Witness polygon.** Hidden whenever the rendered shell N changes: phi3, n1, B and the shell mode (the shell key is now mode, base and resolved N). The play-mode phi3 step also goes through this rule. Supersedes Fix round 2 item 5's "a phi3 change does not hide it". Tests: new check that the polygon is hidden after a phi3 step and needs Test again; the old control now changes only the gear (it used to step phi3 too, which contradicts the new rule), so it is renamed "persists across a gear change". No assertion was weakened.

Results (verbatim):

```
test-exact: 20 passed, 0 failed
test-core: 87 passed, 0 failed
contrast-check: 93 pass, 0 fail
browser-check: 156 passed, 0 failed
```

`sha256sum -c dist/MANIFEST.sha256`: all OK.

**New dist sha256:** see line below (dist/comb-hopf.html).
9ed72a52c22ffcac653b9386f6c84b81a180c04432ec5ae6b03f72287aceddf6 *dist/comb-hopf.html

## Fix round 4 (orbit sampling)

Defect: s-orbits (Clifford) and tooth trails (Hopf) used 49 samples over a window of +-1.15*pi/|rate|, so curves were polygons and windows did not close. Fix (host-core/comb-numeric.js `orbits`, view-clifford.js, view-hopf.js):

1. Step in s chosen so that u = pi*t1*s, v = pi*c*t2*s/N (and the S2 angle pi*k*s/N) each advance at most 2 degrees per step.
2. Window: one full period, centred on the current s, closed (first point = last). Period = lcm(2/|t1|, 2N/|c*t2|) computed exactly with BigInt rationals (`orbitPeriod`; a zero rate imposes no condition).
3. If that needs more than 4,000 points, a 4,000-point window centred on s is drawn and labelled "partial orbit" (both views).
4. Points projecting to the pole (CLIPPED_NEAR_POLE) are null; the Clifford view splits the polyline there and never joins across them.

Example state (B=24, phi3=21, N=4, m=7, t1=t2=1, n6=1, alpha=0, s=408/125): every tooth has a closed orbit of at least 181 points; longest drawn segment 8.91 view units (limit 19.2 = 3% of 640) on Clifford, 6.45 on Hopf. Note: the Hopf comb-walk polyline (amber, 12 samples per edge) was not part of this task and is unchanged.

New tests: test-core +6 (exact period, 2-degree steps and closure, partial window, pole null); browser-check +12 (both viewports, Clifford and Hopf: teeth drawn, >= 100 points, segment <= 3% of width, no partial label). No test weakened.

Results (verbatim):
```
test-exact: 20 passed, 0 failed
test-core: 93 passed, 0 failed
contrast-check: 93 pass, 0 fail
browser-check: 168 passed, 0 failed
parity sample: UNEXPLAINED differences: 0
```
`sha256sum -c dist/MANIFEST.sha256`: all OK. Screenshots regenerated.

**New dist sha256:** `1de1c3a919b4adcf3c3dfa3e4f12259293dbc6a39ef2b590f51e13ca558c5ae2` (dist/comb-hopf.html).

## v0.1.1 (2026-10-13)

Built to SCHEMA_ADDENDUM_5. SCHEMA*.md and FUNCTIONALITY_LEDGER.md untouched.

Changes:
1. `host-core/orbit-core.js` (new, BigInt): exact orbit branches (raw rate, denominator scale L, cleared rate, common factor, primitive winding, closure period, k_c, knot class, canonical type, chi), stationary/undefined branches labelled and never omitted; cyclotomic field readout (generated, ambient, shell reference). Reproduces the reference export's `orbitBranches` and `exactRationalLift.branches` exactly at n1=4, phi3=21, m=7, t1=t2=1, s=4/7, n6=1, alpha=1.
2. Clifford tab "S3 orbit branches" card: chips (c, raw, primitive, xd, type), All, None, tap toggles, long-press (550 ms) or shift-click isolates. Hidden branches hide the s-orbit and the tooth dot. Visibility is view key `ch` (address only, never the exact export). Orbits are drawn in the chip colour. Phasors card shows `field ... . ambient ... (exact)`.
3. Lift JSON schema `fv-comb-hopf-lift/0.2` with `branches[]` (exact strings).
4. Page defaults now phi3=23 (N=2), m=2. Older tests set their state explicitly (phi3=2, m=3); none weakened. Default-state checks added.
5. Hopf comb-walk edges: `edgeCurve` samples each planar edge (>=32 intervals, bisected to <=2 degrees per step), maps through fromAffine, breaks at the north pole.

Ambient-field finding: derived from definitions (lcm of orders of carrier phase e^{i pi t1 s} and offset phases e^{-i pi c t2 s/N}, brute-force checked) the ambient field at the reference state is Q(zeta_14), equal to the generated field. The export says Q(zeta_56). I did not force agreement. 56 = lcm(14, 2N), so the export seems to include the 2N-th roots of unity; that is my conjecture, not verified against the host. Convention note: the sign of n6 is treated as an amplitude, not part of the carrier phase, so the generated field is always contained in the ambient one.

Pre-existing, unchanged: a tooth with S2 rate k_c = 0 is treated as "stationary" (no orbit drawn) even when its S3 winding (a,b) is nonzero (a Hopf fibre); the card still lists its branch.

Results (verbatim):
```
test-exact: 20 passed, 0 failed
test-core: 117 passed, 0 failed
contrast-check: 93 pass, 0 fail
browser-check: 210 passed, 0 failed
parity sample: UNEXPLAINED differences: 0
```
`sha256sum -c dist/MANIFEST.sha256`: all OK. Screenshots regenerated (new: shot_*_clifford_branches.png).

**New dist sha256:** `066ace8930149d119067fd7b7da6c22bc3afb2c03fc276f222ecc35d90da53b1` (dist/comb-hopf.html).

## v0.2 Release A (2026-10-13)

Built to SCHEMA_ADDENDUM_6 and the 44 items of FUNCTIONALITY_LEDGER section 3 "Release A", in the ledger's inner order, one git commit per step (all four suites passing before each commit). `SCHEMA*.md` and `FUNCTIONALITY_LEDGER.md` untouched. exact-lib 0.2.0 is inlined; `exact-lib/exact.js` (0.1) stays as history, not inlined.

**exact-lib 0.2.0.** `exact-lib/exact-lib-0.2.0.js` is a byte copy of `FOURIER_VIEWER_LIBS/exact-lib-0.2.0/dist/exact-lib.js`, sha256 `3edfc8fb396fda90cfa945963eb18ccdf243f5a491e3ee49275b5c459a223a71` (checked by `build/package.cjs` against both files, and by test-exact). No prototype code needed changing for the API (the browser global `FVExact` is kept by the library). `fv-build-pins` now has schema `fv-comb-hopf/0.2`, an `exact_lib` record (name, version, sha256, source, inlined path) and the per-module hashes.

Per-step suite counts (test-exact / test-core / contrast-check / browser-check; parity sample 0 unexplained at every step):

| step | what | exact | core | contrast | browser | dist sha256 (first 8) |
|---|---|---|---|---|---|---|
| 0 | switch to exact-lib 0.2.0, pins | 21 | 117 | 93 | 210 | 598241f8 |
| 1 | layout order and phone stack; shell row (S2, S3), slider rows, start button (T3), speed button (T4), s row Enter-applies (L3, L4), header (K10), text floor | 21 | 117 | 93 | 229 | 878b647c |
| 2 | gearbox chips with drawers, lanes deleted (S4 to S16) | 21 | 117 | 93 | 249 | 8133dd5e |
| 3 | Layers and Camera menus (F2, F7, F8, C4, C16, C17, C22, H1, H3, T6) | 21 | 117 | 93 | 267 | 4b9d83a5 |
| 4 | one caption line per view, cuts behind the info box (V3, F12, F13, C24, H4, H5), cards merged (K1, K4, K7a, K7c, K7d, K7f, K9) | 21 | 117 | 93 | 278 | ab331be2 |
| 5 | Export menu (X6), Copy formula | 21 | 117 | 93 | 286 | 06766cce |
| 6 | orbit-core and cyclotomic readout (X7e): generated and phase container | 21 | 121 | 93 | 288 | 0571e992 |
| 7 | Lift JSON 0.2 (X4): schema, branches, cyclotomic_field; N = 0 and fractional k_c checks | 21 | 121 | 93 | 292 | 0571e992 |

**Final dist sha256:** `0571e9922175f419261fad8f68bc779d584e94488d0f340ef0926326340a1709` (dist/comb-hopf.html). `sha256sum -c dist/MANIFEST.sha256`: all OK (regenerated by `build/package.cjs`).

**Text floor.** Every `font-size` in the page CSS is wrapped in `max(13px, ...)`. SVG text is sized by the CSS rule `#stage text` from `--svgk` (rendered px per user unit, kept current by a ResizeObserver), giving exactly max(13px, 13px x scale) on screen; the font-size attribute (rounded up, not down) is only the fallback for the PNG export. The 12.9992 px came from rounding the SVG font to 2 decimals. The check is now strict (`< 13 - 1e-6`) and runs at every A+ step (100 to 160 %) on all tabs at both viewports: smallest measured text 13.0000 px (at 100 %), 14.3 at 110 %, up to 20.8 at 160 %.

**Cyclotomic fields (owner decision).** `FVCombCore.cyclotomic(st)` (BigInt). Generated: minimal Q(zeta_L). Phase container: Q(zeta_{2qN}) for s = p/q, times D (lcm of the k_c denominators) when some k_c is not an integer; the label says so. Reference state (B = 24, N = 4, m = 7, t1 = t2 = 1, s = 4/7): generated Q(zeta_14), container Q(zeta_56) = 2*7*4, `host_ambient_equivalent: true`; tested against the frozen export (`generated` Q(zeta_14), `ambient` Q(zeta_56)). Also tested on 2,000 random states (container holds every tooth phase, contains the generated field, D handling, equivalence flag). JSON fields `generated`, `phase_container`, `host_ambient_equivalent` (plus `phase_container_factor`, `q`, `N`, `k_denominator_lcm`) in `exact.cyclotomic_field` of the exact JSON and in `cyclotomic_field` of the Lift JSON. The derived orbit-rate "ambient" of v0.1.1 is still computed by `FVOrbit.field(...).ambient` (its tests stay) but is no longer shown or exported.

**First screen, 375x812 (measured, default state, nothing open).** View frame 350 to 603 px (Fourier, Clifford) or 331 to 584 (Hopf); phi3 row to 706 / 687; s row to 757 / 738; transport to 799 / 780. All inside 812; the view starts at 350 px (v0.1: 1870). The browser test measures it on Fourier, Clifford and Hopf. Desktop 1280: cards in a 380 px right column at x = 860 (as in the old host), the view centred in the instrument panel. The Panels tab has no frame and is not part of the first-screen test.

**Visible controls (buttons + inputs + selects, nothing open).** The about-40 target is NOT met. Real numbers:

| tab | 375 px, whole page | 375 px, instrument panel + header | 1280 px, whole page | 1280 px, instrument panel + header |
|---|---|---|---|---|
| Fourier | 61 | 50 | 71 | 60 |
| Clifford | 61 | 50 | 71 | 60 |
| Hopf base | 61 | 50 | 71 | 60 |
| Panels | 74 | 63 | 84 | 73 |

The old host showed 83 (Plane), 113 (Clifford), 91 (Hopf). Where the count comes from (Fourier, 375 px): A-/A+ 2, shell row 3 (n!, integer, n1 select), five gearbox chips 20 (label, minus, box, plus each), view row 4, strip 7 (Layers, Camera, +, -, reset, full view, info), phi3 row 4, s row 5, transport 3, Export row 2 = 50; cards 11 (five info buttons; Wilson: candidate box, Hide, previous gear, next gear, m = n1+1, g = 0). At 1280 px the n1 select is replaced by eleven chips (+10), as the ledger specifies for desktop. Reaching 40 would mean breaking the chips or the info boxes the addendum keeps; I did not. The Panels tab counts 17 open placeholder cards with one info button each (default open, as in v0.1). The test records the counts and asserts only that the drawing tabs stay under 83.

**Existing tests changed (layout only; the behaviour asserted is unchanged).**
1. 13 px check: threshold 12.99 became strict `13 - 1e-6`, and it now also runs at every A+ step (new checks, none removed).
2. Witness test with the n1 click: at 375 px it uses the n1 select (`#n1_sel`), because the chips are hidden on a phone. Desktop still clicks `#n1_5`.
3. Witness Test: the Test button is gone (ledger K7a: Enter = Test); tests press Enter in `#w_p`. The two "not active until Test is pressed" text asserts became "the order-m rows (`phi relation`) are absent", since that caption line was cut.
4. Export clicks (JSON, pair, Lift JSON) and the Import box open the Export menu first (helper `expOpen`); PNG is still one tap.
5. Clifford: the fraction stack toggle and the pan toggle are clicked inside the Layers / Camera menus; the pan test reads the pressed state in the menu.
6. Branch tests: the chips live in Layers, Advanced (menu opened first); `All` and `None` became one `All / None` toggle (`#br_toggle`) with the same sequence (hide all, show all, isolate, show all); "branch card shown on Clifford only" became "no chips in the Fourier Layers menu".
7. Field line at the reference state: `field Q(zeta_14) . ambient Q(zeta_14)` became `generated Q(zeta_14) . phase container Q(zeta_{2qN}) = Q(zeta_56) (q = 7, N = 4)` (owner decision). In test-core the "field line" test was replaced the same way; the derived-ambient tests stay.

**Other behaviour notes.** Dial left/right buttons for alpha and n6 step by 1 (the old fine steps were not specified; the box and the drawer slider reach any value). "g = 0" is read as phi3 = 0 (INFERRED; the host meaning of that button was not read). Long overlay text no longer draws in the SVG or on the surface: only degenerate-case labels (rho = 0, partial orbit, AT_INFINITY, gate failure) stay visible; everything else is behind the info box. Pinch markers, float entropy/regime readouts and the noise minima are not built (owner Q3 and Q4; minima in Release B). No Wolfram link or text exists (tested). Screenshots: `shot_v02_<tab>_375x812.png` and `shot_v02_<tab>_1280x800.png` for fourier, clifford, hopf, panels (viewport only, default state, nothing open); the older `shot_*` files were regenerated too. Not tested: a real phone (Playwright emulation only); the clipboard (a fallback text box is shown).

## v0.2 Release A fix round (2026-10-13, SCHEMA_ADDENDUM_7 and Sol's conditions)

Implemented F1 to F9. No git command was run. SCHEMA*.md, FUNCTIONALITY_LEDGER.md and the VERIFY folder untouched.

**Final counts:** test-exact 21/0, test-core 132/0, contrast-check 93/0, browser-check 356/0, parity sample 2000 states, UNEXPLAINED differences 0. `sha256sum -c dist/MANIFEST.sha256` all OK. Screenshots shot_v02_<tab>_<w>.png regenerated.

**Visible controls (buttons + inputs + selects; nothing open; default state).** Target: at most 40 in the instrument panel with (i) excluded: MET on the three drawing tabs, identical at both widths.

| tab | page, with (i) | page, without | panel + header, with (i) | panel + header, without |
|---|---|---|---|---|
| Fourier, Clifford, Hopf (375 and 1280) | 52 | 45 | 41 | 39 |
| Panels (375 and 1280) | 65 | 41 | 54 | 35 |

(Before: 61/50 at 375, 71/60 at 1280.) The test asserts <= 40 on the three drawing tabs; Panels is outside Release A and is recorded only (its panel count without (i) is 35 anyway).

**Captions (F2, F8).** One line on every drawing tab at 375 and 1280, default and reference state, and for both Clifford fraction-stack paragraphs; truncated ones end in an ellipsis and expand on tap. The text-size readout is one line, also at 160%. Per Sol's condition only informational lines (role "line", active fraction caption) are ellipsized; degenerate, gate-banner, idle-fraction warnings are full lines, and a stepping refusal now shows in full in the s row (outside the (i)). Tests: N = 0 and t1 = 0 refusal at 375, full text visible, not truncated. First screen at 375: transport ends at 762 px (was 799.5).

**F3/F4/F5/F6/F7.** Each-value-once table implemented and tested (N once in the shell readout; Q-res and ALIGN/SPREAD in the Fourier caption only; spread t2*s/N once; K_m kernel behind the Phasors (i)). m drawer has an (i) with the register line. Lift JSON gates computed in `FVOrbit.gates` with PASS and FAIL tests (exact_rational_lift, closed_orbits, integral_frequencies; prime_pair SEPARATE_GATE; rank4 OUT_OF_SCOPE). Stationary branches (both phase rates zero) and N = 0 branches count as having no finite closure period (FAIL, listed): a literal reading of the addendum. Field labels "generated by the phase factors" and "phase container (convention)", C = 2qN*L_k, JSON `L_k`, `phase_container_formula`, `rho_irrational`; tested at the reference state (generated Q(zeta_14), container Q(zeta_56), L_k = 1) and on a fractional case (t1 = 1/3, N = 4, m = 3, s = 3/5: generated Q(zeta_40), L_k = 3, container Q(zeta_120)).

**Layout-position tests changed.** (1) alpha box test opens the alpha drawer first; (2) n1 witness test uses the select at both widths; (3) gearbox chips test: 5 label buttons, no input in the row, 9 buttons, t1/t2 steppers beside chips; (4) drawer test also checks box and stepper counts; (5) chip stepper test: alpha and m steppers are inside their drawers; (6) field-line test text; (7) fractional-k_c Lift test wording (L_k); (8) the control-count test (was < 83, now instrument panel without (i) <= 40, with all counts logged). Added F2, F3, F4, F5, F6, F7, F8 and warning tests.

**Correction (Sol via saphir, 2026-10-13).** Earlier sections used the wrong wording for the generated field: the "v0.2 Release A" section, paragraph "Cyclotomic fields (owner decision)" ("Generated: minimal Q(zeta_L)"), and the v0.1.1 section line describing the generated field. The right wording is: "the field generated by the phase factors e^{iπ·k_c·s/N}" (not necessarily the field of the phasor values, since rho = n6*N^alpha can be irrational; the phasor values may need Q(zeta_L, rho)). Hits corrected in code, JSON note, labels, README: comb-core.js (note, comment), orbit-core.js (label, comment), panel.js (Phasors (i)), README.md (cyclotomic readout). BUILD_REPORT earlier lines left as record.

**New dist sha256:** see final message.

## v0.2 Release A fix round 2 (2026-10-13, owner decisions on DELTA_VERIFY_R2)

No git command run. SCHEMA*.md and the VERIFY folder untouched. R20/R21 behaviour unchanged.

- **F-R2-1.** Stationary teeth now emit a caption warning with role `degenerate` ("stationary: c = … (no orbit)" on Clifford, "(no trail)" on Hopf), shown full on the warning line, never ellipsized. The old dim SVG text is gone. Browser tests for both tabs at 375 and 1280.
- **F-R2-2.** When the stop set is inactive, the s ◀ ▶ buttons get `aria-disabled="true"` and are dimmed (not the `disabled` attribute, so pressing still gives the R20 refusal), and the s row shows "stepping unavailable — <reason>" before any press. Tests for t1 = 0 (m = 3), t1 = t2 = 0 (m = 4), non-integer gear, N = 0, plus the reference state (no line, arrows enabled); each press still refuses and the state is unchanged. Harness note: Playwright will not click an `aria-disabled` button, so the two existing/new press tests use `click(..., {force:true})`; assertions unchanged.
- **SPREAD on the phone.** Fourier caption is now "ALIGN … · SPREAD … ★ · Q-res … (numerical)". Test: flags precede Q-res and the flag text lies inside the line without a tap, at 375 and 1280.
- **F-R2-3.** README: title v0.2, Release A table rows corrected (drawer-only ◀ ▶ for α, n₆, m; n₁ select; witness has no Test button), deferred list updated (Clifford orbit-branch filter is built), fix-round-2 table added.

**Counts:** test-exact 21/0, test-core 132/0, contrast-check 93/0, browser-check 380/0 (was 356; +24), parity sample 2000 states, UNEXPLAINED 0. Controls unchanged: panel without ⓘ 39 (drawing tabs). MANIFEST regenerated, all OK; screenshots regenerated.

**New dist sha256:** `c3010a3433b0df6fe2573c8b859b0cabbe447889d499350098f515af8990adb5`

## Performance round (2026-10-13, owner: "very slow")

No git command run. SCHEMA*.md untouched. R20/R21 and every readout unchanged; exact values still come only from BigInt. Scripts kept in build/: `perf-bench.cjs` (the tables below), `perf-profile.cjs` (per-phase times, SVG size), `perf-cdp.cjs` (CDP Profiler and Tracing). Reproduction state (owner screenshot, Clifford tab): n1 = 4 (B = 24), phi3 = 6 (N = 19), alpha = -1/50, n6 = 1, t1 = 1, t2 = -21/4, m = 3, s = -627/250; the page shows "partial orbit: 2 orbit(s) ..." exactly as in the screenshot. Playwright, Chromium headless (software raster), 1280x800, medians; the x4 column is `Emulation.setCPUThrottlingRate` 4 (a phone proxy, not a phone). "sync" = JS time of the call (render included); "to frame" = until the next frame has been produced (includes up to one 16.7 ms vsync wait, so about 17 to 20 ms is a floor on this harness). The machine is noisy: repeated runs vary by about +-15 %.

**Where the time went (measured, reproduction state, Clifford, desktop, per phi3 step).** Exact computations are negligible: resolve 0.01 ms, readouts 0.04, stopSet 0.01, divisors 0.03, field 0.13, branches 0.13, numeric compute 0.10, leaf mesh 0.22. The orbit sampling (two partial orbits of 4,000 points) is 2.3 ms. The cost was drawing: the Clifford view put 343,000 characters of path data and about 25,000 path points into the SVG (23 elements): string formatting (`f2`) 4.4 ms, `innerHTML` parse 3.6 ms, native DOM about 8 ms, and rasterising those paths 44 ms of raster time per step (RasterTask, trace). Hopf: 132,000 characters, about 9,700 points, 159 elements. Fourier: 49 characters (cheap). Every continuous input event rendered synchronously (30 slider events = 30 full renders, no coalescing), and the model built the orbits and meshes for every tab, including Fourier and Panels. Inactive tabs were already not rendered.

**Fixes (each backed by the measurement above).**
1. Canvas layer under a thin SVG overlay (Clifford meshes and s-orbits; Hopf disc, grid, latitude, trails, walk curves). The SVG keeps labels, tooth dots, walk vertices, hit targets, and an empty stub per orbit, trail and walk run and per mesh, carrying `data-role`, `data-c`, `stroke`, `data-n` (R17 attributes kept). The projected points of each drawn run are recorded in `FVViews.layerRuns()`; the geometry tests read those instead of the SVG `points` attribute (the only test change, 6 assertions). Clifford SVG: 23 -> 13 elements, 343 KB -> 0 of path data. PNG export composites the canvas under the SVG and flushes any preview first.
2. Coalescing: range `input` events and camera drags (drag, wheel, pinch) update the state and every exact readout at once, then render at most once per animation frame; the full render runs on release (`change`, pointer up) or 200 ms after the last input. Discrete clicks and changes still render synchronously. The address hash is written at most every 250 ms during a drag.
3. Preview, drawing register only, labelled with a `preview` caption line while active: orbits sampled at 1/8 of the points (partial flag, period and span are those of the full sampling), mesh lines every second line, long runs strided. All readouts (cards, shell row, s box, flags) are exact and current in every preview frame.
4. Memoisation: the numerical model and the orbits are cached on the exact state (tab and camera excluded, so a camera drag recomputes neither); orbits are lazy (Fourier and Panels never compute them); the Hopf walk curves are cached on the numerical model; mesh extents are cached on the mesh; the leaf mesh stays cached on rho.
5. DOM writes: the cards are patched in place (only changed nodes touched); the shell readout, s readout, phi marks, status, address and play note are written only when changed.
6. Canvas stroking: vertices closer than 0.25 view units are not sent to the rasteriser (the recorded run keeps every point); widths in (1, 2] are drawn as two 1 px passes offset by half the extra width (a 1.6 px stroke on a 4,000-point curve measured 10.6 ms against 0.95 ms for 1 px).
7. Visual glitch: the "(see note)" stand-in for a long degenerate label was always `text-anchor="middle"`, so a label placed at x = 10 ("partial orbit ...") was centred on the left edge and clipped to "...e note)". It now keeps the caller's anchor (default start). Test added; the same fix covers the Hopf tab.

**Before and after (ms; sync / to frame).**

| Measurement (desktop 1280x800) | Before | After |
|---|---|---|
| Clifford at the reproduction state: phi3 step | 25.4 / 31.4 | 16.7 / 24.8 |
| Clifford: t2 step | 18.1 / 23.9 | 9.5 / 19.3 |
| Clifford: s step | 19.6 / 25.5 | 10.4 / 20.8 |
| Hopf: phi3 / t2 / s | 15.7, 12.0, 14.6 / 24.2, 23.6, 24.7 | 13.9, 7.0, 12.4 / 22.0, 21.3, 21.1 |
| Fourier: phi3 / t2 / s | 5.3, 4.1, 5.1 / 20.8, 22.0, 21.3 | 3.7, 3.6, 2.2 / 20.9, 20.0, 19.4 |
| Panels: phi3 / t2 / s | 6.5, 7.9, 5.4 / 25.3, 24.6, 24.8 | 3.1, 4.6, 3.8 / 21.5, 24.1, 22.7 |
| Slider drag phi3 (30 events, one per frame), fps | 33.5 | 58.3 (frame-rate limited) |
| Slider drag s (30 events, one per frame), fps | 32.0 | 58.1 (frame-rate limited) |
| 30 input events in one task, total time phi3 / s | 1059 / 776 | 21 / 24 |
| Tab switch (6 pairs), to frame | 17.5 to 23.9 | 16.0 to 21.2 |
| First render (JS, `fv-init`): default Fourier / repro Clifford | 62 / 99 | 65 / 86 |

| Measurement (x4 CPU throttle) | Before | After |
|---|---|---|
| Clifford: phi3 / t2 / s step | 154.6, 126.5, 210.2 / 200.6, 178.4, 291.6 | 136.4, 79.4, 71.0 / 199.9, 131.4, 129.5 |
| Hopf: phi3 / t2 / s | 102.6, 75.8, 108.4 / 178.9, 142.0, 175.7 | 127.4, 80.9, 95.0 / 207.2, 143.9, 176.1 |
| Fourier: phi3 / t2 / s | 59.9, 36.7, 39.1 / 130.9, 96.0, 98.5 | 34.4, 32.2, 32.3 / 65.5, 59.1, 63.4 |
| Panels: phi3 / t2 / s | 66.6, 50.8, 81.0 / 159.5, 169.4, 182.2 | 39.6, 35.5, 35.9 / 116.6, 91.5, 112.0 |
| Slider drag phi3 / s, fps | 4.7 / 4.6 | 9.7 / 9.1 |
| 30 input events in one task, total phi3 / s | 4178 / 4815 | 131 / 170 |
| Tab switch, to frame | 105 to 196 | 68 to 193 |
| First render: default Fourier / repro Clifford | 353 / 562 | 384 / 461 |

**Targets.**

| Target | Desktop | x4 throttle |
|---|---|---|
| State-change render at the reproduction state (< 50 ms desktop, < 200 ms x4) | MET: 16.7 ms sync (24.8 to next frame); t2 and s about 10 ms | t2 and s MET (79 and 71 sync, 131 and 130 to frame); phi3 sync 136 MET, to frame 199.9 is at the limit, not a margin |
| Slider drag (>= 30 fps desktop, >= 15 fps x4) | MET: 58 fps (the frame rate of this harness) | NOT MET: 9.7 fps (phi3), 9.1 fps (s); before 4.7 and 4.6 |
| Tab switch (< 100 ms desktop) | MET: 16 to 21 ms to frame | not required (68 to 193 ms) |

Why the x4 drag target is missed: per drag frame (preview) the x4 cost is about 36 to 44 ms of JS (cards patch 12 ms, controls 3.5, the view 15 to 25, model 2 to 4) plus about 12 to 17 ms of layout and 10 to 17 ms of canvas flush, about 100 ms in all. The cards and controls must stay exact and current, so they were not skipped; the rest is page layout and canvas raster in this software-raster Chromium. Hopf phi3 at x4 (127 vs 103 ms sync) did not improve: each phi3 step changes N, so the walk curves are rebuilt and the canvas flush of trails and walk is paid; I did not chase it. First render did not change measurably (65 vs 62 ms default Fourier): it is dominated by parsing and the first layout, not by drawing. Not tested: a real phone, a GPU-backed canvas (raster would be cheaper there), a real mouse at 1000 Hz.

**Tests.** Added 16 browser assertions (8 per width): reproduction state reached; state-change regression bound (median of 7 under 250 ms to next frame, measured about 18 ms unthrottled); canvas layer drawn and SVG overlay small with data-attribute stubs; clipped-text fix; preview coalescing (30 input events: no synchronous render, 1 render, state and s box current, "preview" caption); preview draws fewer points and the full sample returns; PNG export is a full frame; no page errors. Six existing geometry assertions now read `FVViews.layerRuns()` (same checks, same thresholds).

**Final counts:** test-exact 21/0, test-core 132/0, contrast-check 93/0, browser-check 396/0 (was 380; +16), parity sample 2000 states, UNEXPLAINED 0. `sha256sum -c dist/MANIFEST.sha256` all OK. Screenshots regenerated by browser-check.

**New dist sha256:** `d9d76ed7a319e9aacaff9308fbc411f689527d93331e54fa6fd2736d93da5e22`

## Performance round 2 (2026-10-13)

No git command run. SCHEMA*.md untouched. R20/R21 and every readout unchanged; exact values only from BigInt. Same harness as round 1 (Playwright, Chromium headless, software raster, 1280x800, CDP CPU throttle x4 as a phone proxy). New scripts in build/: `perf-camera.cjs` (camera, slider drag, first render; medians of 3 runs, with the minimum), `perf-first.cjs` (first render, before/after interleaved), `perf-camprofile.cjs`, `perf-load.cjs`. The machine is noisy (other processes; frame rates snap to 60/30/20/15 fps steps because a frame that misses a 16.7 ms slot waits for the next); "before" and "after" below were measured back to back in one session.

**Camera (measured for the first time).** Before: every camera move ran the full model, cards and controls once per frame; the drag only coalesced to one render per frame. Now a camera move (rotate, pan, wheel, pinch) changes the view string only, then reprojects cached typed arrays (Float64Array xyz per mesh, orbit run, trail, walk curve, vertices, dots; built once per exact-state change) and redraws the canvas plus the small SVG overlay, once per frame. The model, orbit samples and meshes are not recomputed (test counts calls). While the camera moves, the canvas is drawn at half resolution (commit cost scales with pixels), long curves at about 300 points and meshes every second line; the full-resolution frame, caption and cards come on release or 200 ms after the last move. Canvas-size changes no longer trigger a render on the Fourier tab (which does not use the canvas).

| fps, 60 events | x1 before | x1 after | x4 before | x4 after |
|---|---|---|---|---|
| Clifford rotate / wheel / pinch / pan | about 60 (harness cap) | 59.8 / 59.8 / 59.7 / 59.9 | 15.7 / 16.1 / 15.4 / 16.8 | 22.8 / 25.9 / 23.3 / 26.1 |
| Hopf rotate / wheel / pinch | about 60 | 59.9 / 59.7 / 59.8 | 10.5 / 11.1 / 9.8 | 21.0 / 19.2 / 17.2 |
| Fourier wheel / pinch / pan | about 60 | 59.8 / 59.8 / 59.9 | 17.4 / 16.2 / 20.6 | 26.8 / 28.9 / 28.3 |

Targets: desktop >= 50 fps MET (59.7 to 59.9, the harness limit). x4 >= 20 fps: Clifford MET (23 to 26), Fourier MET, Hopf rotate MET (21), Hopf wheel 19.2 and pinch 17.2 NOT MET (minimum runs 18.5 and 16.5). Cause: per frame about 12 ms of JS (3 ms real) but the rest is Chromium software compositing (canvas commit about 8 to 12 ms at x4, SVG paint, layout); Hopf redraws more curves (grid, trails, walk) than Clifford. A GPU canvas was not tested.

**Slider drag at x4 (30 input events, one per frame).** Cards (phasor table, flags, Wilson, divisors, shell) now update at most 4 times per second from one consistent state (`PERF.cardsAddr` records which) and exactly on release; while a drag is active `#cards` carries `data-preview` with a dim "preview" line and reduced opacity. The canvas also draws at half resolution during the drag. Divisor list moved from the card into the model so the phi3 marks stay current.

| fps | x1 before | x1 after | x4 before | x4 after |
|---|---|---|---|---|
| Clifford phi3 / s | about 60 | 59.1 / 58.8 | 10.8 / 11.2 | 13.3 / 14.0 |
| Hopf phi3 / s | about 60 | 59.1 / 59.7 | 7.5 / 5.9 | 11.5 / 8.9 |
| Fourier phi3 / s | about 60 | 59.4 / 59.4 | 7.3 / 11.8 | 19.0 / 23.1 |

Target >= 15 fps at x4: Fourier MET; Clifford 13.3 / 14.0 and Hopf 11.5 / 8.9 NOT MET (minimum runs 8.9 and 7.0). Cause: besides the JS (model, geometry rebuild at each step, controls), the per-frame cost is native: layout of the changing controls, SVG and canvas commit and raster in software mode; Hopf also rebuilds the walk curves and trails mapping at every phi3 step. Card updates during the drag: 8 to 13 in about 3 s (<= 4/s).

**R17.** Every tooth dot and walk vertex is drawn on the canvas and has a transparent SVG element at the same position (`data-role`, `data-c`, `data-t`; vertex 0 has no `data-c`, it is the start, vertex t >= 1 carries the c of the tooth added). Every branch orbit and trail has one SVG `rect` proxy (bounding box of the drawn curve, invisible, no pointer events) with `data-role`, `data-c`, `data-branch`, `data-t`, `data-n`; walk curves have one `data-role="walk"` box each. Positions are recorded in `FVViews.layerMarks()` and rewritten every frame, so they are current during and after camera moves. Orbit elements are `rect`, not `polyline`: three selectors in browser-check changed. Pair export (PNG, exact JSON, state) tested after camera moves: exact hash equals a fresh export, canvas at full resolution.

**First render** (page load to the first frame presented after the first full render; median of 9, before and after interleaved):

| | x1 before | x1 after | x4 before | x4 after |
|---|---|---|---|---|
| default (Fourier) | 139 | 107 | 1069 | 816 |
| Clifford (repro) | 162 | 140 | 1151 | 991 |
| Fourier (repro) | 143 | 107 | 992 | 844 |
| Hopf (repro) | 172 | 139 | 1169 | 1014 |
| Panels (repro) | 143 | 106 | 1176 | 1022 |

Dominators found by trace: (1) the first layout needs system font fallback for the symbol glyphs (arrows, info, full view): 400 ms at x4 against 40 ms for plain text. Fix: `'Segoe UI Symbol'` named in `--font-mono` (about 25 percent of the first frame; the (i) glyph is drawn slightly thinner on this system). (2) A second full render followed the first on the Fourier tab (the unused canvas failed the size check, and the scrollbar appearing resized the frame); fixed (canvas flag per view, `scrollbar-gutter: stable`, released in the maximised view). What remains is browser start-up: HTML and script parse and compile (about 330 ms at x4), and one first layout even for an unstyled page (about 150 to 540 ms at x4).

**Tests.** Added 62 browser assertions (31 per width): camera path (no full render, no recomputation, exact JSON hash and cards unchanged, release gives one full render at full canvas resolution, desktop fps bound >= 30), wheel/pinch/pan, R17 positions within 1 px of the canvas-drawn positions for dots, vertices and orbits (m = 3 and m = 7, at rest and after a drag, canvas pixel lit), cards <= 4 updates per second with the marker, cards after release equal a fresh page, mid-drag cards equal a fresh page at their recorded update state, pair export.

**Final counts:** test-exact 21/0, test-core 132/0, contrast-check 93/0, browser-check 460/0 (was 396), parity sample 2000 states, UNEXPLAINED 0. `sha256sum -c dist/MANIFEST.sha256` all OK; screenshots regenerated.

**New dist sha256:** `3ea3e151592c458cd656fbab0de2f8e79f72fc4e2aad5876c7b76d7a8aeeef62`

## Fix round (2026-10-14, Astra novelty review: stationary quotient, even-kernel caption)

Defects (both confirmed by reading the code):
1. A stationary quotient hid a moving fiber. host-core/comb-numeric.js orbits() returned stationary (no s2, no s3) whenever the quotient rate pi*k_c/N was 0, although k_c = 0 can coexist with nonzero carrier and offset rates (example: N = 2, m = 2, t1 = 1, t2 = 2, tooth c = -1, lifted winding pair (2,2)). The exact register (orbit-core.js line 39) was already right. Now a tooth is stationary only when the quotient and both lifted rates are 0; k_c = 0 with a nonzero lifted rate is baseFixed (s2 empty, S3 orbit computed as for a moving tooth). (corrected 2026-10-14)
2. Even-comb kernel caption (panel.js, Phasors card about-text) said e^{iβ} ∈ μ_m∖{1} for both parities; for even m the zeros are e^{2iβ} ∈ μ_m∖{1} (K_m = sin(mβ)/sin(β)). The exact flag in comb-core.js readouts() was already correct. (corrected 2026-10-14)

Files changed: host-core/comb-numeric.js (orbits(): baseFixed flag, s2 skipped when base fixed, comment); instruments/comb-hopf/view-hopf.js (skip trails with empty s2; base-fixed warning line); instruments/comb-hopf/view-clifford.js (draw base-fixed teeth; base-fixed warning line); instruments/comb-hopf/panel.js (kernel caption by parity); instruments/comb-hopf/README.md (degenerate-cases paragraph and warning table row, both marked "(corrected 2026-10-14)"); host-core/test-core.cjs (2 new checks); build/browser-check.cjs (4 new assertion groups x 2 viewports); dist rebuilt (dist/comb-hopf.html sha256 91492afe137e64b765fcaad35e3fd2d9224c01eada3e72be77d93df83b615ec9, MANIFEST regenerated).

New checks: test-core (a) N=2,m=2,t1=1,t2=2: c=-1 stationary false, baseFixed true, s2 empty, s3 nonempty finite, period "2"; c=+1 normal; (b) t1=t2=0 all stationary, and t1=0,t2=1,m=3: only c=0 stationary. browser-check: base-fixed caption text on the Hopf and Clifford tabs for the N=2 state (no stationary caption); Phasors (i) contains e^{2iβ} ∈ μ_m for m=4 and e^{iβ} ∈ μ_m without e^{2iβ} for m=7; existing F-R2-1 check still passes.

Final summary lines (verbatim):
```
test-core: 134 passed, 0 failed
browser-check: 468 passed, 0 failed
```

## v0.3 step 1: continuous N, option B (2026-10-14)

Builder: subagent (Claude Opus 5.5) under `BUILD_BRIEF_v0_3_CONTINUOUS_N_20261014.md` and the owner's handoff `../FOURIER_VIEWER_HANDOFF_FABLE_CONTINUOUS_N_20261014/HANDOFF.md` (§2 conditions 1–6). Spec of record: `SCHEMA_ADDENDUM_8.md` (new). No git command run. Nothing under `../FOURIER_VIEWER_PROTOTYPE_v0_1_20261013/` was edited (its `dist/comb-hopf.html` was copied read-only to the scratchpad for the A/B speed runs). Not verified yet: an independent verifier with a closed file list comes next.

Order of work: baseline of every suite on the untouched copy (test-exact 21/0, test-core 134/0, browser-check 468/0, contrast 93/0, parity UNEXPLAINED 0, perf-bench and perf-camera saved); exact core; test-core re-run and diffed against the baseline (all 134 baseline PASS lines identical in text and order, the six informative lines identical; the only differences were the build-pins check before the rebuild and the address-version assertion of item 4.4); consumers; UI; docs; dist; all suites; speed scripts.

### 1. Summary lines (verbatim, final run)

```
test-exact: 21 passed, 0 failed
test-core: 157 passed, 0 failed
parity sample: 2000 states; exact phase/k_c differences: 0; stepper compared 2000, identical value 1587
UNEXPLAINED differences: 0
contrast-check: 93 pass, 0 fail
browser-check: 524 passed, 0 failed
```
`node build/package.cjs` rebuilt the page and the manifest (deterministic: two builds gave the same sha256). `sha256sum -c dist/MANIFEST.sha256`: all 14 lines OK. The parity-sample output is byte-identical to the baseline. Counts: test-core 134 → 157 (+23); browser-check 468 → 524 (+56: 29 at 375×812, 27 at 1280×800).

### 2. Files changed (line references in the files as they now are)

- `host-core/comb-core.js` (0.2.0): header 3–6; schema ids 0.2, `ADDRESS_ID_V01`, `N_MODES`, `DIAL_KEYS` with `nMode`, `DEFAULTS.nMode`, `BETWEEN` label 11–19; `resolve` 26–42 (nMode check 29, φ₃ integer or exact rational 32–34, `Nq`/`N`/`Nint`/`phi3q` 40–41); `canonicalDial(k,v,st)` 43–47; `teeth` over `Nq` 52–58; `wilsonOf` 66; `gearbox` (between shells → `G.between`) 68–72; `readouts` 73–83; `gate` 85–93; `center` (BigInt or rational N) 94–96; `derive`, `wrapKept` 97–106; `normalise` 107; `switchNMode` 124–131; `shellStep` 134–138; `PHI_STEP`, `playNStep` 140–144; `stopSet` SPREAD refusal between shells 153–157; `step` refusal label 189; `validateState` 194–209; `decodeAddress` 0.1 upgrade 213–223; `cycloJson` 226–234; `exportExact` 235–258; `rhoIrr` for N = a/b 270–274; `cyclotomic` with C = 2·q·a·L_k 275–285; `divisorsOf` 286–291; api 292–293.
- `host-core/gearbox-core.js`: `between()` 28–38, api 39 (`analyze` untouched).
- `host-core/orbit-core.js`: note 5; `closurePeriod` for rational N 19–24; `branches` 37–38, 43; `field` 75, 80, 84; `gates` between shells 105–108.
- `host-core/comb-numeric.js`: note 5; `compute` with N = number(Nq) and |ln N| in the bound 42–47; `orbitPeriod` 112–116; `orbits` 120, 126; `fractionPoints` 144.
- `host-core/fraction-stack-core.js`: idle between shells 11–12.
- `instruments/comb-hopf/panel.js`: `shellKey` 13; `clampPhi` exact 48; model contrast and divisors 75, 82; φ₃ row with the box and the switch 104–105; φ₃ ◀ ▶ snap and `nmode` 128–131; slider and box 189–190; Play N 201; shell readout with N as a fraction 234; φ₃ controls sync 244–249; SPREAD-refusal line 258; play note and shell marks 266–271; container ⓘ text 302–303; between-shells cards 306–311; stats 376; Lift 0.3 with `nMode`, `N`, `N_integer` 382; formula 418; pair 0.2 424; between-shells warning line on every tab 499; a 0.1 address shown as its 0.2 address 522.
- `instruments/comb-hopf/index.html`: CSS for the shell marks, the φ₃ box, the switch, `#phirow` wrapping at large text sizes 52–53.
- `instruments/comb-hopf/view-fourier.js`: bound text with |ln N| 76.
- `instruments/comb-hopf/README.md`: title; numerical bound; address id; dial-ledger rows for the switch, the box, the slider step and Play N; stepping paragraph; degenerate-cases paragraph; exports; closing section "v0.3 step 1".
- `SCHEMA_ADDENDUM_8.md`: new.
- `host-core/test-core.cjs`: line 158 (item 4.4); new block 523–659.
- `build/browser-check.cjs`: lines 277, 315, 714 (item 4.4); new block 498–585.
- `dist/comb-hopf.html`, `dist/MANIFEST.sha256`: rebuilt. The `shot_*.png` and `export_*.png` files were regenerated by browser-check.

### 3. New checks, one line each

test-core (23):
1. resolve: nMode defaults to integer; continuous φ₃ accepts 7/2, 3.5, 0 (stored 7/2, 7/2, 0); Nq = 43/2, N null, Nint false; integer mode refuses 7/2; continuous refuses 51/2 and −1/2; φ₃ = 25 gives N = 0; unknown nMode refused. PASS.
2. Rational-N phases equal a direct computation (k_c, tooth phase mod 2, carrier, offset, every order) and the numerical tooth equals ρ·e^{iπk_c s/N} from floats: 1,000 random states, 682 between shells, 0 mismatches. PASS.
3. ALIGN and SPREAD flags with rational N agree with the numerical kernel |K_m(β)| < 1e-9: 2,000 states, 177 zero-kernel states, 0 disagreements. PASS.
4. §2.1 named state N = 7/2, m = 5, t₁ = t₂ = 1, s = 1/3: stop set ALIGN only, SPREAD refused (4e) "SPREAD needs an integer gearbox: N = 7/2"; forward → 1, backward → 0, both ALIGN; the step label and the exact export carry the refusal; no ALIGN stop skipped. PASS.
5. §2.1 40 forward and 40 backward steps at N = 43/2, m = 7, t₁ = 2, t₂ = 3 land only on ALIGN stops in ℤ/2; on the shell N = 21 of the same continuous mode the SPREAD families return with no refusal. PASS.
6. §2.1 PAIR between shells (N = 7/2, s = 1/3): forward 1, backward 0, no refusal; t₁ = 0 and non-integer gears keep their own 4e reasons. PASS.
7. §2.2 closed gate N = 7/2, t₁ = t₂ = 1, m = 3: k_c ∈ ½ℤ∖ℤ, gate closed, typed 9 kept (s_eff = 9, E = 9) with the "kept" label; typed 3 has none (E = 7/2). PASS.
8. §2.2 open gate N = 7/2, t₁ = t₂ = 2, m = 3: k_c = 5, 7, 9, gate open, typed 9 → s_eff = 2, E = 7/2; at s ∈ {2, 1/3, −5/7, 3/2} and s + 7 the exact tooth, carrier and offset phases are equal, the floats of e^{iπk s/N} agree within 1e-12, the numerical walk endpoints within the bound. PASS.
9. §2.3 N = 7/2, t₁ = t₂ = 1, m = 3: c = 1 raw (7/2, −1), L = 2, cleared (7, −2), primitive (7, −2), T(2,7)−, k_c = 9/2; closure periods 14, 14, 2. PASS.
10. §2.3 the closure period is the least s > 0 at which both phases return (brute force, 600 random rational-N states, more than 1,000 branches); numeric `orbitPeriod` agrees. PASS.
11. §2.3 long period N = 1234567/1000 (B = 2000, m = 3): the c = ±1 orbits are partial with 4,000 points and the exact period 2469134 is in the orbit record, the branch and the Lift `closure_period_s`; c = 0 period 2. PASS.
12. §2.4 container over 1,500 random states (more than 900 between shells): C = 2·q·a·L_k; every tooth order divides C; every k_c·s/N·C/2 ∈ ℤ; C = 2qN·L_k on a shell; generated = brute-force least n and divides C; `host_ambient_equivalent` iff N integer and L_k = 1. PASS.
13. §2.4 named state N = 7/2, t₁ = t₂ = 1, m = 3, s = 1/3: L_k = 2, a = 7, C = 84, generated ℚ(ζ₄₂), factor `2qa*L_k`, formula "C = 2*q*a*L_k (N = a/b in lowest terms)", JSON N "7/2", N_integer false, label ℚ(ζ₈₄). PASS.
14. §2.5 fraction stack idle at N = 9/2 with the label (caption "fraction stack idle — between shells: N = 9/2; …"); the shell N = 9 in continuous mode gives q = 5, 630 heads as in integer mode. PASS.
15. §2.6 ρ = √3.5 within the bound at N = 7/2, α = 1/2; `rho_irrational` exact: (7/2, 1/2) true, (9/4, 1/2) false, (8/27, 1/3) and (8/27, 2/3) false, (9/4, 1/3) true, N = 1 false; the exact export of a between-shells state has no decimal float (schema id aside) and no rho value. PASS.
16. Bound with |ln N|: positive and finite at N = 1/2; equal to the old formula at N = 5. PASS.
17. Integer-only readouts at N = 7/2: both Wilson readouts, gearbox `BETWEEN_SHELLS` (eligible false, residency null), divisors, shell contrast and bracket null with the label, Lift `integral_frequencies` NOT_EVALUATED with the label, `prime_pair` reason suffix, `closed_orbits` PASS; exports carry nMode, N "7/2", N_integer false; schema `fv-comb-hopf/0.2`. PASS.
18. Continuous mode on an integer shell equals integer mode for 400 random states: teeth, readouts, stop set, gates, branches, cyclotomic JSON and exact export identical apart from nMode; φ₃, s_eff, E unchanged by the switch. PASS.
19. Address round trip with nMode = continuous and φ₃ = 7/2 (and the state JSON); refused: `phi3=3.5` (non-canonical), φ₃ 7/2 with nMode integer, a 0.2 address without nMode, nMode "rational". PASS.
20. 0.1 upgrade: the v0.2 perf reproduction address (0.1, no nMode) loads as nMode = integer with every key unchanged (N = 19) and re-encodes as 0.2; a 0.1 address carrying nMode is refused; a 0.1 state JSON is refused. PASS.
21. Mode switch: integer → continuous keeps φ₃ 23 with no note; continuous → integer 7/2 → 4 (tie upward) with the note "N continuous → integer: φ₃ = 7/2 rounded to the nearest shell φ₃ = 4 (N = 21).", 13/4 → 3, 27/4 → 7; an integer φ₃ 5 switches with no note. PASS.
22. φ₃ arrows: continuous 7/2 → 4 (N − 1) and 3 (N + 1); at 4 → 5 and 3; 1/100 → 0; 2499/100 → 25; integer mode φ₃ ± 1 clamped (25 stays 25, 0 stays 0); Play N: 7 → 8 (integer), 7 → 701/100 (continuous), 2499/100 → 25, null at 25. PASS.
23. N = 0 in continuous mode (φ₃ = 25) is the empty state (readouts, numeric, stepping, field); φ₃ = 49/2 (N = 1/2) is not empty and is between shells. PASS.

browser-check (each at 375×812 and 1280×800 unless marked):
1. The switch is one toggle in the φ₃ row, `aria-pressed` false, text "N∈ℤ", no φ₃ box in integer mode; visible controls in the instrument panel (ⓘ excluded) at the default state 40 ≤ 40. PASS.
2. Integer → continuous: `aria-pressed` true ("N∈ℚ"), φ₃ stays 23, the box shows 23, no message. PASS.
3. (375 only) First screen, integer mode, default φ₃: frame, φ₃ row to 701, s row to 752, transport to 794 ≤ 812. PASS.
4. (375 only) First screen, continuous mode, default φ₃: the same numbers. PASS.
5. Continuous slider: step 0.01, max 25, 26 integer-shell marks at j/25. PASS.
6. The box accepts 7/2 (Enter): φ₃ = 7/2, shell readout "N = 43/2", address `nMode=continuous&phi3=7/2`. PASS.
7. The box accepts 6.25 (→ 25/4) and refuses 26 with "Shell position φ₃ must be 0 through B + 1.", state unchanged. PASS.
8. Slider value 12.37 commits φ₃ = 1237/100. PASS.
9. ◀ ▶ from 7/2: 4, 3, then 2. PASS.
10. Play ▶ N advances 1/100 of a shell per tick (3/100 after about three ticks) and the note says so. PASS.
11. Continuous → integer at 27/4: φ₃ = 7 and the message "N continuous → integer: φ₃ = 27/4 rounded to the nearest shell φ₃ = 7 (N = 18).". PASS.
12–15. Fourier, Clifford, Hopf, Panels at N = 43/2: the warning line carries "between shells: N = 43/2; shell arithmetic undefined" once, in full, class `warnline`, not ellipsized, inside the viewport. PASS ×4.
16–19. The same four tabs between shells: no visible text below 13 px (smallest 13.000 px). PASS ×4.
20. Cards between shells: Wilson, Divisors and Shell show the label and no values; Phasors present; the flag card shows the spread 2/129. PASS.
21. The s row at m = 5 between shells shows "SPREAD refused (4e): SPREAD needs an integer gearbox: N = 43/2" before any press, not truncated. PASS.
22. s ▶ from 1/3 lands on the ALIGN stop 1; label "ALIGN stop (t₁·s ∈ ℤ); SPREAD refused (4e): …". PASS.
23. s ◀ from 1/3 lands on the ALIGN stop 0 with the same refusal. PASS.
24. Lift JSON between shells: schema `fv-comb-hopf-lift/0.3`, nMode continuous, N "43/2", N_integer false, `integral_frequencies` NOT_EVALUATED with the label, `closed_orbits` PASS, `prime_pair` reason ends with the label. PASS.
25. Exact JSON between shells: schema `fv-comb-hopf/0.2`, `state.nMode` continuous, `exact.N` "43/2", N_integer false, gearbox `BETWEEN_SHELLS`, shell contrast null with the label. PASS.
26. Tab switches change no setting in continuous mode. PASS.
27. Tab switches change no setting in integer mode. PASS.
28. A 0.1 address (v0.2 era) opens as nMode = integer with no refusal banner and is shown as its 0.2 address. PASS.
29. Zero network requests in the continuous-N pages. PASS.

Informative lines (not PASS/FAIL): `CONTROLS … v0.3: instrument panel without ⓘ: integer mode 40, continuous mode (φ₃ box shown) 41` (both widths); `FIRSTSCREEN 375x812 v0.3 between shells (N = 43/2, m = 5, Fourier): transport bottom 882 of 812 px; φ₃ row to 742; s row to 793`.

**Speed** (the reproduction state of the performance rounds, integer mode; Playwright, Chromium headless, software raster, 1280×800). The machine was noisy in this session: the same file differs by up to 2× between runs at ×4, and the baseline taken at the start was faster than later runs of the same file. So the v0.2 page (`91492afe…`, copied read-only) and the v0.3 page (`caf5ce9e…`) were run interleaved, two runs each.

| perf-bench (ms or fps; run 1 / run 2) | v0.2 page | v0.3 page |
|---|---|---|
| ×1 Clifford φ₃ step, sync / to frame | 22.3, 11.8 / 34.4, 22.0 | 13.5, 15.4 / 22.9, 26.3 |
| ×1 Clifford t₂ step, sync | 12.3, 10.3 | 13.6, 10.2 |
| ×1 Clifford s step, sync | 14.9, 10.9 | 24.5, 9.9 |
| ×1 Hopf φ₃ step, sync | 10.9, 17.0 | 12.2, 16.6 |
| ×1 Fourier φ₃ step, sync | 5.9, 4.6 | 5.8, 4.5 |
| ×1 slider drag φ₃ / s, fps | 55.2, 58.0 / 56.5, 56.1 | 56.8, 55.0 / 56.9, 59.3 |
| ×4 Clifford φ₃ step, sync | 117.7, 100.7 | 140.7, 110.9 |
| ×4 Clifford t₂ step, sync | 78.8, 65.5 | 73.9, 66.4 |
| ×4 Hopf φ₃ step, sync | 110.1, 91.2 | 99.1, 122.4 |
| ×4 slider drag φ₃, fps | 9.6, 9.4 | 10.1, 10.7 |
| ×4 first render default Fourier / repro Clifford | 177.0, 157.4 / 207.0, 339.2 | 134.6, 152.1 / 424.0, 244.8 |

| perf-camera (fps; run 1, run 2) | v0.2 page | v0.3 page |
|---|---|---|
| ×1 camera Clifford rotate / Hopf rotate / Fourier wheel | 59.6, 59.5 / 59.7, 59.8 / 59.7, 59.9 | 59.9, 59.5 / 59.5, 59.5 / 59.7, 59.7 |
| ×1 drag Clifford φ₃ / Hopf φ₃ / Fourier φ₃ | 59.5, 59.6 / 54.3, 58.5 / 58.5, 59.8 | 58.5, 56.2 / 53.6, 59.0 / 59.5, 59.8 |
| ×4 camera Clifford rotate / Hopf rotate | 21.6, 21.7 / 13.1, 26.0 | 34.5, 17.0 / 30.8, 30.8 |
| ×4 drag Clifford φ₃ / Hopf φ₃ / Fourier φ₃ | 13.2, 19.9 / 13.8, 12.4 / 27.6, 15.9 | 10.8, 19.8 / 9.5, 11.2 / 25.2, 13.5 |

In-page render phases (`FVPanel.perf` medians over 60 alternating φ₃ / t₂ / s steps at the reproduction state, four interleaved rounds per page, ×1): Fourier total 1.7–2.5 ms (v0.2) and 2.2–2.4 ms (v0.3); Clifford 3.8–5.0 ms and 4.0–4.3 ms; model, cards and controls each within 0.1 ms of each other. Reading: no regression is measurable at ×1; at ×4 the spread between runs of one page is larger than any difference between the pages, so a small ×4 change can be neither shown nor excluded. browser-check's own regression bounds (state change < 250 ms to next frame, camera ≥ 30 fps) pass.

### 4. Not done, uncertain, or for the owner to decide

1. **Control cap in continuous mode: 41.** At the default state (integer mode) the instrument panel shows 40 visible controls without ⓘ (39 before, plus the switch), so the cap check holds. In continuous mode the φ₃ box is visible and the count is 41. A visible switch and a visible box cannot both fit in 40 without hiding another control; the existing cap check measures the default state with nothing open (the gear drawers also add 5 to 7 controls when open). I chose one toggle button because two buttons would make 41 at the default state. Owner decision: accept 41 in continuous mode, or put the box (and possibly the switch) behind the φ₃ label in the drawer pattern of addendum 7 F1.
2. **First screen at 375×812 between shells: transport ends at 882 px, 70 px below the fold.** It holds in both modes at the default φ₃ (checks 3 and 4: transport at 794). Between shells the mandated warning line wraps to two lines at 375 px (about 41 px), and at m ≥ 3 the s-row line "SPREAD refused (4e): …" adds about 45 px. Other warning lines already do the same today (stepping unavailable, N = 0). Recorded as an informative line, not as a PASS. Owner decision whether the first-screen guard covers warning states.
   **Correction (marked 2026-10-14, step 2, VERIFY F2):** the 882 px above is the Fourier tab only. At the same state (N = 43/2, m = 5) Clifford and Hopf end at **943 px** (131 px over; s row to 854), and integer mode at N = 21, m = 5 on those tabs ends at 855 px.
3. **φ₃ slider width at 375 px in continuous mode: 55 px** (88 px in integer mode), because the box shares the row. Usable; the box and the snapping arrows carry the precision.
4. **Test changes forced by the schema bump (no assertion removed or loosened):** test-core line 158: the unknown-version refusal now replaces `fv-comb-hopf/0.2` by `fv-comb-hopf/0.3` (it replaced `0.1` by `0.2`; 0.2 is now current and 0.1 is the accepted upgrade). browser-check lines 277 and 315 expect `fv-comb-hopf-lift/0.3` (were 0.2); line 714 expects `fv-comb-hopf-pair/0.2` (was 0.1). Two of my own new test-core checks were corrected before they ever passed: the share of between-shells states (I guessed more than 700 of 1,000; the generator gives 682; now more than 500) and a "no decimal float" regex that matched the schema id "0.2" (the schema field is now left out of that scan).
5. **The numerical bound uses |ln N|, not ln N** (brief §1.9 says "ln of that number"). For N < 1, reachable only between shells, 1 + ln N can be negative and the stated bound would be wrong; |ln N| = ln N on every shell, so integer-mode bounds are unchanged (test-core check 16).
6. **Names chosen by the builder:** Lift `integral_frequencies` status `NOT_EVALUATED` between shells (reason = the label); `prime_pair` keeps `SEPARATE_GATE` with the label appended to its reason; exact-export key `betweenShells`; switch text `N∈ℤ` / `N∈ℚ`. `BETWEEN_SHELLS` is the brief's.
7. **Readings the owner may want to check:** (a) the order-m witness (candidate p) is switched off between shells as part of "Wilson (both readouts)", although it does not depend on N; (b) the Divisors card is switched off between shells as the brief lists it, although its list (shells N′ with t₂·s/N′ ∈ ℤ) does not depend on the current N; (c) continuous → integer sends a tie φ₃ = j + 1/2 to j + 1 (the smaller N); (d) integer-shell marks are drawn only when B + 1 ≤ 1000 (n₁ ≤ 6); above that the φ₃ label's title says so.
8. **Exports:** the exact export and the Lift JSON carry `nMode`, `N` (exact text) and `N_integer`; the state export carries `nMode` inside `state` but not the derived `N` / `N_integer` (the state stays the address and nothing else). State and exact JSON files of schema 0.1 are refused, not upgraded; only the 0.1 address is upgraded (brief §3).
9. Not touched: `SCHEMA.md`, addenda 1–7, `FUNCTIONALITY_LEDGER.md`, `HOST_LIBRARY_MAP.md`. No continuous-mode screenshot was added (browser-check regenerates the existing set).

### 5. Pins

- `dist/comb-hopf.html` sha256 `caf5ce9eaa46f0faf0942ec2476b720057327f0756a7237ec2dfbb41d79fd7f1`
- `dist/MANIFEST.sha256` sha256 `9bd0b578b9bf26cd69e0dc4c48623cf84cbe37cf91e19473dac7359f408eca8f`
- Inlined exact-lib 0.2.0 unchanged: `3edfc8fb396fda90cfa945963eb18ccdf243f5a491e3ee49275b5c459a223a71`

## v0.3 step 2: fix round after VERIFY (2026-10-14)

Builder: subagent (Claude Opus 5.5) under `BUILD_BRIEF_v0_3_step2_fixround_20261014.md` (ground rules of the step-1 brief §0). Inputs: `../FOURIER_VIEWER_PROTOTYPE_v0_3_VERIFY_20261014/VERIFY.md` and `NOTE_v0_3_step1_for_owner_20261014.md`. No git command run. Nothing under `../FOURIER_VIEWER_PROTOTYPE_v0_1_20261013/` was edited. Its `host-core/test-core.cjs` and `host-core/parity-sample.cjs` were only run, for the diffs below.

**Result: two items cannot be met as written; both are stopped and reported here, and every other item is done.**
- Item 1 (F1): the drawer is built as specified. The cap of 40 visible controls is **not met in either mode**: the count is 41 in integer mode and 41 in continuous mode.
- Item 2 (F2): both changes are made. The first screen at 375×812 between shells **still overflows by 3.7 px** (transport bottom 815.7 of 812) on Fourier, Clifford and Hopf, at m = 2 and m = 5. Panels holds.
- The checks that measure these two things fail and are reported, not loosened: browser-check gives 541 passed, 18 failed.

### 1. Dispositions

| Flag | Disposition (owner leans, saphir "go with your leans") | Done |
|---|---|---|
| F1 control cap | φ₃ drawer. The φ₃ label is now a chip that opens a φ₃ drawer (◀ exact box ▶ and a range line) in both modes. In integer mode the box takes integers only; a fraction is refused with "N integer mode: φ₃ must be an integer; switch to N∈ℚ for fractions". Slider, ⏮, ◀ ▶ and the toggle stay on the row | built. **Cap not met: 41 / 41** (see §5.1) |
| F2 phone first screen | short warning line "between shells: shell arithmetic undefined" (one line at 375 px); the fraction stays in the shell readout and the full label stays in every card and record. The SPREAD refusal moved to the s-row stepper message (on a step) and the s ⓘ. Addendum 8 amended (§10 A1), original text kept | built. **First screen still 3.7 px over on three tabs** (see §5.2) |
| F3 untested claims | closed by the owner session (note); speed not re-run in this round (not in the brief's command list) | — |
| F4 stale bound comment | `comb-numeric.js` line 4: the bound comment reads (1+ln N) → (1+\|ln N\|), as the code (line 47), the README and addendum 8 §7 | done |
| F5 container formula in README; stale comb-core comment | README v0.3 step-1 section states C = 2·q·a·L_k with its one-sentence derivation and the convention label. `comb-core.js` comment 269–272 is the general N = a/b form | done |
| F6 build-pins id | `fv-comb-hopf-build/0.1` (`package.cjs` 17); test-core and browser assertions added; addendum 8 §10 A3 | done |
| F7 line endings | informational. This round restored, line by line, the original mixed CRLF/LF endings of `comb-core.js`, `panel.js` and `README.md`, which the editor had normalised. Diffs against the pre-round sources (taken byte-for-byte from the step-1 dist page) show only content lines | — |

### 2. Files changed (line references in the files as they now are)

- `host-core/comb-core.js`: `BETWEEN_SHORT`, with its comment, at 20–22; container comment (F5) at 269–272; `BETWEEN_SHORT` in the api at 296. Nothing else changed. The diff against the pre-round file is 10 lines.
- `host-core/comb-numeric.js`: line 4, the bound formula comment (F4).
- `instruments/comb-hopf/panel.js`:
  - φ₃ row with the chip `lab_phi3` and the `#phidrawer` container: 104–106.
  - One drawer at a time (`drawer` act clears the φ₃ refusal line): 124.
  - The box goes through `phiBox`: 191.
  - `PHI_INT_REFUSAL` and `phiBox`: 196–205.
  - `drawerHtml` skips φ₃: 219.
  - `phiDrawerHtml`: 230–240.
  - s ⓘ states the SPREAD refusal: 247.
  - φ₃ chip text, title, aria-expanded and drawer sync: 267, 270–271.
  - SPREAD refusal now in the stepper message after a step, no longer permanent: 281.
  - Warning line short form: 522.
- `instruments/comb-hopf/index.html`: 53–54. The φ₃ chip padding in the row and the φ₃ drawer style; the old `#phi_tx` row rule is removed.
- `build/package.cjs`: 17, build-pins id `fv-comb-hopf-build/0.1`.
- `host-core/test-core.cjs`:
  - 315: the build-pins id, by decision F6. The PASS line text is unchanged.
  - New block 660–679: three checks.
- `build/browser-check.cjs`:
  - Changed assertions: 517, 521, 522 (informative), 588 and 601. Each is listed in §4.
  - New checks: 523–540, 568–577, 582, 602–607 and 619–646.
- `instruments/comb-hopf/README.md`:
  - The φ₃ box row is marked amended, and a new φ₃ chip/drawer row is added in the dial ledger (29–30).
  - Marked amendments in the stepping paragraph and the between-shells paragraph.
  - The step-1 counts paragraph is marked superseded.
  - New paragraph: the phase container between shells (F5).
  - New section "v0.3 step 2".
- `SCHEMA_ADDENDUM_8.md`: new §10 Amendments. A1 is the F2 label split and the SPREAD placement, marked "amended 2026-10-14, saphir F2". A2 is the F1 drawer; A3 is the F6 pins id. §1–§9 are unchanged.
- `BUILD_REPORT.md`:
  - One marked correction line in the step-1 section (§4 item 2): the Clifford and Hopf figures.
  - This section.
- `dist/comb-hopf.html` and `dist/MANIFEST.sha256` were rebuilt; two builds give the same sha256. browser-check regenerated the `shot_*.png` and `export_*.png` files.

### 3. New checks, one observation each

test-core (3 new; 157 → 160):
1. The warning-line short form is exactly "between shells: shell arithmetic undefined", with no fraction. The full label is unchanged at N = 11/4 (B = 24) in the readouts, Wilson, gearbox (`BETWEEN_SHELLS`), divisors, fraction-stack caption, exact export (`betweenShells`, `shell.status`) and the Lift `integral_frequencies` reason. PASS.
2. The SPREAD refusal at N = 11/4, m = 5, s = 1/3 is unchanged in the core:
   - The stop set has ALIGN only, with one refusal "SPREAD needs an integer gearbox: N = 11/4".
   - Forward lands on 1 and backward on 0.
   - The step label ends with "; SPREAD refused (4e): …".
   - The exact export's stepping field is "COMB; SPREAD refused (4e): …".

   PASS.
3. The build-pins id `fv-comb-hopf-build/0.1`, read from the dist page, differs from the exact-export id `fv-comb-hopf/0.2` and the state-export id `fv-comb-hopf-state/0.2`, both read from real exports, and from the address id. PASS.

browser-check (both viewports unless marked; 35 new checks: 23 at 375×812, 12 at 1280×800):
1. Cap in continuous mode at the default φ₃, nothing opened: **41 > 40. FAIL** at both widths.
2. Cap between shells (N = 43/2, continuous, nothing opened): **41 > 40. FAIL** at both widths.
3. The φ₃ chip opens the drawer under the φ₃ row:
   - ◀ exact box ▶, with the box holding 23.
   - Range line "0 … 25 · decimal or fraction · Enter applies".
   - `aria-expanded` true, and no gear drawer open.

   PASS.
4. With the φ₃ drawer open, no visible text is below 13 px and the drawer's controls are ≥ 40 px high. PASS.
5. The drawer box applies 89/4 (Enter): φ₃ = 89/4 exactly, shell readout "N = 11/4", chip "φ₃ 89/4". The drawer stays open with the box holding 89/4, and there is no message. PASS.
6. The drawer ◀ ▶ are the row's shell steps: from 89/4, ◀ (N − 1) gives 23 and ▶ (N + 1) gives 22. PASS.
7. Tapping the chip again closes the drawer: no box on the page, `aria-expanded` false, φ₃ unchanged. PASS.
8. Integer mode (after the 27/4 → 7 switch), with range line "0 … 25 · integer (N∈ℤ) · Enter applies":
   - 7/2 is refused with "N integer mode: φ₃ must be an integer; switch to N∈ℚ for fractions", in the message line and in the drawer.
   - The state is unchanged (φ₃ = 7, integer mode).

   PASS.
9. Integer-mode drawer: 8/2 is applied as the integer 4 and the refusal clears; 26 is refused with the range reason and the state is unchanged. PASS.
10. After s ▶ between shells, the s-row stepper message shows "SPREAD refused (4e): SPREAD needs an integer gearbox: N = 43/2" in full, visible and not truncated. PASS.
11. The same after s ◀. PASS.
12–19. (375 only) First screen between shells at N = 11/4 (B = 24, φ₃ = 89/4), nothing opened, scrollY 0, shell readout "N = 11/4":

    | Case | Transport bottom | Result |
    |---|---|---|
    | m = 2: Fourier, Clifford, Hopf | 815.7 > 812 | **FAIL** (×3) |
    | m = 2: Panels (stage top visible, transport 506.2) | 506.2 | PASS |
    | m = 5: Fourier, Clifford, Hopf | 815.7 > 812 | **FAIL** (×3) |
    | m = 5: Panels | 506.2 | PASS |

    On the failing tabs the φ₃ row ends at 722.7 and the s row at 773.7, so both are inside.
20–22. (375 only) φ₃ slider ≥ s slider − toggle width:

    | State | φ₃ slider | s slider | Toggle |
    |---|---|---|---|
    | Integer mode, default | 88.0 px | 23.6 px | 40.0 px |
    | Continuous mode, default φ₃ | 87.7 px | 23.6 px | 40.3 px |
    | Between shells, N = 11/4 | 70.1 px | 23.6 px | 40.3 px |

    PASS ×3.
23. The build-pins id `fv-comb-hopf-build/0.1`, the exact-export id `fv-comb-hopf/0.2` and the state-export id `fv-comb-hopf-state/0.2` are pairwise distinct. The pins id is read from the page; the other two come from the Export JSON and Export state buttons. PASS.

### 4. Assertions changed by decision (no other assertion changed)

- test-core 315: the build-pins id expected is `fv-comb-hopf-build/0.1` (was `fv-comb-hopf/0.2`) (F6).
- browser-check 517 (was 516):
  - "no φ₃ box in integer mode" (computed `display: none` of `#phi_tx`) became "the φ₃ label is a chip 'φ₃ 23' in the row and no φ₃ box is on the surface" (F1; the box element no longer exists until the drawer opens).
  - Its cap clause (≤ 40) is unchanged and now FAILs at 41.
- browser-check 521 (was 519): "the φ₃ exact box appears holding 23" became "no box appears on the surface; the chip reads φ₃ 23" (F1). The box holding 23 is now checked in the drawer (new check 3).
- browser-check 522 (was 520, informative console line): "(φ₃ box shown)" became "(φ₃ drawer closed)".
- browser-check 588 (was 556): the warning line between shells is expected as the short form "between shells: shell arithmetic undefined" (was the full label with "N = 43/2"). Added to the same assertion: exactly one line, and the shell readout shows "N = 43/2" (F2).
- browser-check 601 (was 563–564): "SPREAD refused … shown before any press, in full" became "before any press there is no SPREAD line under the view; the s ⓘ states 'SPREAD refused (4e): SPREAD needs an integer gearbox: N = 43/2' in full" (F2). The after-press placement is new checks 10–11.
- The step-1 box checks (browser-check 546–551) and the ◀ ▶, Play N and switch checks keep their assertions unchanged. The box is now reached by opening the drawer first (line 540).

### 5. Not met, and why

1. **F1 cap: 41 visible controls in both modes (cap 40).**
   - Before this round: integer 40, continuous 41 (the box).
   - After: integer 41, continuous 41.
   - Arithmetic: the φ₃ label was plain text (a `span`, not counted). As a chip it is a button and counts (+1 in both modes). The box left the surface (−1 in continuous mode only).
   - The brief keeps the slider, ⏮, ◀ ▶ and the toggle on the row, so nothing else leaves it. As written, ≤ 40 cannot hold in either mode.
   - Failing checks, left failing and not loosened:
     - the step-1 switch check (517) at both widths;
     - the addendum-7 per-tab cap check (Fourier, Clifford, Hopf) at both widths;
     - the two new continuous-mode cap checks at both widths.

     That is 12 of the 18 failures.
   - Options for saphir, by count, not built:
     - (a) put the N∈ℤ / N∈ℚ toggle into the φ₃ drawer: 40 in both modes;
     - (b) put ⏮ into the drawer: 40 in both modes;
     - (c) accept 41.
2. **F2 first screen: 3.7 px over on Fourier, Clifford and Hopf at N = 11/4 (m = 2 and m = 5); Panels holds.**
   - The two changes worked: the label is one line, and there is no SPREAD line under the view before a press.
   - What remains is the one-line warning itself. It adds 21.5 px to a layout that ends at 794.2 on a shell. 794.2 + 21.5 = 815.7.
   - Clifford and Hopf no longer differ from Fourier at N = 11/4: no base-fixed or partial-orbit line appears there.
   - Per brief, I stopped here. The 6 first-screen checks are left failing and are not loosened. saphir decides.
   - Not touched, because they are outside this item's two changes: the other warning lines that already push the transport down on a shell in integer mode, such as the base-fixed line at N = 2, m = 5 (835) and the partial-orbit line at N = 21, m = 5 (855).
3. Observations, no action taken:
   - **s slider is 23.6 px wide at 375 px** (since v0.2: the set-s box and ⓘ share the s row). So the slider criterion "φ₃ ≥ s − toggle" is weak: the right side is negative. The φ₃ slider widths themselves are in check 20–22.
   - **PNG captions:** the PNG export draws the caption lines under the picture, so a between-shells PNG now carries the short form without the fraction. The pair export's exact JSON (`exact.N`, `exact.betweenShells`) keeps it.
   - Speed scripts were not re-run (not in this brief's command list). This round adds no per-frame work: one string, one drawer sync (`setHtml`, unchanged markup when closed), and one less paragraph.

### 6. First-screen bottoms at 375×812 (transport bottom; scrollY 0, nothing opened; Fourier / Clifford / Hopf / Panels)

Before = step-1 page `caf5ce9e…`, measured in this round with the same script; after = this page.

| State | Before | After |
|---|---|---|
| Integer mode, N = 2, m = 2 (default) | 794 / 794 / 794 / 483 | 794 / 794 / 794 / 483 |
| Integer mode, N = 2, m = 5 | 794 / 835 / 835 / 483 | 794 / 835 / 835 / 483 |
| Integer mode, N = 21, m = 5 | 794 / 855 / 855 / 483 | 794 / 855 / 855 / 483 |
| Continuous on a shell, N = 2, m = 2 | 794 / 794 / 794 / 483 | 794 / 794 / 794 / 483 |
| Continuous on a shell, N = 2, m = 5 | 794 / 835 / 835 / 483 | 794 / 835 / 835 / 483 |
| Between shells, N = 11/4, m = 2 | 835 / 835 / 835 / 526 | 816 / 816 / 816 / 506 |
| Between shells, N = 11/4, m = 5 | 882 / 882 / 882 / 573 | 816 / 816 / 816 / 506 |
| Between shells, N = 43/2, m = 5, s = 1/3 (verifier's state) | 882 / 943 / 943 / 573 | 816 / 876 / 876 / 506 |

Notes on the table:
- The verifier's figures (882 Fourier, 943 Clifford and Hopf) are reproduced in the before column.
- Integer and on-shell rows are unchanged.
- Between shells, the warning line went from 2 lines to 1, and the 45 px SPREAD line is gone.
- At N = 43/2, Clifford and Hopf keep a three-line partial-orbit warning, a degenerate case that is not part of this item.
- φ₃ slider width at 375: before, integer 87.6 px and continuous 55.1 px. After, integer 88.0 px, continuous 87.7 px (default φ₃), 70.1 px (89/4) and 78.9 px (7/2). The s slider is 23.6 px and the toggle 40.0–40.3 px.

### 7. Summary lines (verbatim, final run in the brief's order)

```
test-exact: 21 passed, 0 failed
test-core: 160 passed, 0 failed
parity sample: 2000 states; exact phase/k_c differences: 0; stepper compared 2000, identical value 1587
UNEXPLAINED differences: 0
contrast-check: 93 pass, 0 fail
smallest text measured in this run: 13.0000 px
browser-check: 541 passed, 18 failed
```

Run notes:
- `node build/package.cjs` exited 0.
- `sha256sum -c dist/MANIFEST.sha256`: 14 of 14 OK.
- The first 134 test-core PASS lines are verbatim, and in order, the 134 PASS lines of the v0.2 folder's test-core (`diff` empty). The first 157 equal the step-1 run.
- The parity output is byte-identical to the v0.2 folder's run.
- browser-check exits 1. The 18 failures are exactly those listed in §5.1 (12) and §5.2 (6).

### 8. Pins

- `dist/comb-hopf.html` sha256 `d4311139c0db01f176ea31d7df98178898e327f6b11801f419ed7e6a74f3292b`
- `dist/MANIFEST.sha256` sha256 `c9f3079f2b5be070b7bc9ed6aa927cfc9233e56e71dedb30b4437762f35b2932`
- Inlined exact-lib 0.2.0 unchanged: `3edfc8fb396fda90cfa945963eb18ccdf243f5a491e3ee49275b5c459a223a71`

### 9. Resolution of the two stops (saphir's decisions, 2026-10-14)

saphir decided both stopped items, and the coordinator relayed the decisions. Sections 1–8 above stand as written; they record the state before this resolution.

**The two decisions**

- **Stop 1 (cap):** ⏮ (start, N = 1) moves into the φ₃ drawer. The N∈ℤ / N∈ℚ toggle stays on the row.
- **Stop 2 (first screen):** trim the caption block's vertical margin while a warning line is present. The first-screen assertions stay as written. The 13 px floor and the never-ellipsized rule are untouched.

**Changes**

- `instruments/comb-hopf/panel.js`:
  - 104–105: ⏮ removed from the φ₃ row, and the comment amended.
  - 230 and 236: ⏮ (`data-act="start"`, id `phi_start`, unchanged action φ₃ = B) is now the first button in the φ₃ drawer.
  - Line endings were restored to the step-2 file's mixed CRLF/LF, so the diff shows content lines only.
- `instruments/comb-hopf/index.html`, 109–110: in the 480 px media rule, `#caption:has(p.warnline){margin:1px 0}#caption:has(p.warnline) p{margin:1px 0}`.
  - The margins were 4 px for the block and 2 px per paragraph.
  - Font size and line height are unchanged.
  - The rule applies only while a warning line is present, so states without one are unaffected.
- `build/browser-check.cjs`, 530–535: one new check per viewport. No assertion was changed.
- `instruments/comb-hopf/README.md`:
  - 178: φ₃ row ledger row, marked amended.
  - 179: new ⏮ ledger row (where it lives, what it does), marked "amended 2026-10-14, saphir F1".
  - 186: the count paragraph, amended to 40 in both modes.
  - 188: the first-screen rule sentence, marked "amended 2026-10-14, saphir F2". It states where the rule is asserted and what is not asserted, and gives the N = 43/2 numbers as informational.
- `SCHEMA_ADDENDUM_8.md`, 99 and 101: the A2 and A1 resolution notes. Nothing above them was changed.
- `dist/` was rebuilt.

**New check, one observation (both viewports)**

1. ⏮ is in the φ₃ drawer and not on the φ₃ row. It sets φ₃ = B = 24 (N = 1), and the drawer stays open. PASS ×2.

**Checks that were failing in §5 and now pass as written (no assertion changed)**

- Cap checks, 12 in all:
  - 517 at both widths;
  - the addendum-7 per-tab caps for Fourier, Clifford and Hopf at both widths;
  - the continuous-mode and between-shells caps at both widths.
- First-screen checks at N = 11/4 for m = 2 and m = 5: 6.

**Counts per mode** (instrument panel, ⓘ excluded, nothing opened; both widths)

| Mode | Step 1 | Step 2 (before resolution) | Now |
|---|---|---|---|
| Integer | 40 | 41 | **40** |
| Continuous | 41 | 41 | **40** |
| Between shells | — | 41 | **40** |

**First-screen bottoms at 375×812** (transport bottom; scrollY 0, nothing opened; Fourier / Clifford / Hopf / Panels)

| State | Step 1 | Step 2 | Now |
|---|---|---|---|
| Integer, N = 2, m = 2 (default) | 794 / 794 / 794 / 483 | 794 / 794 / 794 / 483 | 794 / 794 / 794 / 483 |
| Integer, N = 2, m = 5 | 794 / 835 / 835 / 483 | 794 / 835 / 835 / 483 | 794 / 830 / 830 / 483 |
| Integer, N = 21, m = 5 | 794 / 855 / 855 / 483 | 794 / 855 / 855 / 483 | 794 / 850 / 850 / 483 |
| Continuous on a shell, N = 2, m = 2 | 794 / 794 / 794 / 483 | same | 794 / 794 / 794 / 483 |
| Continuous on a shell, N = 2, m = 5 | 794 / 835 / 835 / 483 | same | 794 / 830 / 830 / 483 |
| Between shells, N = 11/4, m = 2 | 835 / 835 / 835 / 526 | 816 / 816 / 816 / 506 | **811 / 811 / 811 / 504** |
| Between shells, N = 11/4, m = 5 | 882 / 882 / 882 / 573 | 816 / 816 / 816 / 506 | **811 / 811 / 811 / 504** |
| Between shells, N = 43/2, m = 5, s = 1/3 (informational) | 882 / 943 / 943 / 573 | 816 / 876 / 876 / 506 | 811 / 870 / 870 / 504 |

Notes on the table:
- Exact transport bottoms at N = 11/4, from browser-check: before the trim 815.7 (step 2), now **810.7 ≤ 812**, a margin of 1.3 px. The φ₃ row ends at 717.7 and the s row at 768.7.
- The trim saved 5.0 px: 3 px above the block, 1 px between the two lines, 1 px below.
- The trim also lowers the not-asserted integer Clifford/Hopf states that carry a warning line by 5 px: 835 → 830 and 855 → 850.

**φ₃ slider width at 375 px** (⏮ left the row):

| State | φ₃ slider |
|---|---|
| Integer mode | 132.0 px |
| Continuous, default φ₃ | 131.7 px |
| Between shells, N = 11/4 | 114.1 px |
| Between shells, N = 43/2 | 122.9 px |

In step 2 these were 88.0, 87.7, 70.1 and 78.9 px. The s slider is 23.6 px and the toggle 40.0–40.3 px.

**Not met:** none. Observation: the first screen between shells now holds with only 1.3 px to spare. A further line or a font-metric change would break it, and the check would show that.

**Summary lines (verbatim, final run in the brief's order)**

```
test-exact: 21 passed, 0 failed
test-core: 160 passed, 0 failed
parity sample: 2000 states; exact phase/k_c differences: 0; stepper compared 2000, identical value 1587
UNEXPLAINED differences: 0
contrast-check: 93 pass, 0 fail
smallest text measured in this run: 13.0000 px
browser-check: 561 passed, 0 failed
```

Run notes:
- `node build/package.cjs` exited 0.
- `sha256sum -c dist/MANIFEST.sha256`: 14 of 14 OK.
- The first 134 test-core PASS lines are verbatim and in order the v0.2 folder's 134 (`diff` empty).
- The parity output is byte-identical to the v0.2 folder's run.
- browser-check: 559 checks of §7 plus 2 new ones, 0 failed.

**Pins after the resolution**

- `dist/comb-hopf.html` sha256 `88e43e38a91eb448a3cf5aafda09157eb080d5a5d731dbc0e2a2d4927b206cf2`
- `dist/MANIFEST.sha256` sha256 `bb315a6a5bfb90569a8fa54e4ff495bd67b6fbf70b1c1ab74509f31004220111`
- Inlined exact-lib 0.2.0 unchanged: `3edfc8fb396fda90cfa945963eb18ccdf243f5a491e3ee49275b5c459a223a71`

## v0.4 (2026-10-19): the comb's mirror axis

Builder: subagent (Claude Opus 5.5). Additive successor in its own folder `FOURIER_VIEWER_PROTOTYPE_v0_4_20261019`, a copy of the v0.3 tree. Nothing outside this folder and the session scratchpad was edited. No git command was run, and nothing was downloaded. `SCHEMA*.md`, `FUNCTIONALITY_LEDGER.md` and the v0.3 folder are untouched.

### Inputs (sha256 computed by this generator)

- v0.3 base `FOURIER_VIEWER_PROTOTYPE_v0_3_20261014/dist/comb-hopf.html`: `88e43e38a91eb448a3cf5aafda09157eb080d5a5d731dbc0e2a2d4927b206cf2`. Its `dist/MANIFEST.sha256` verifies 14 of 14 lines (checked before the copy and again here).
- Feature note (Claude Fable 5.1, from saphir's observations): `9267e39f736bd10662daf6429783912f3bc23331ec0efafd95c66fe9ade82760`.
- Exact check `t_ma_exact_check.py` (Opus): `f93fd0096420b5f0bf625c8287589ab6653fd2f05083b1a7f13479ea09ab551f`.
- S0 design review §5 (Codex, discipline coordinator, review #539), received as amendments during the build: `012628569a61f1045895f2ac85bebefa2e6d114cbf769066ff2e5200456dd742`.

### What was built

See the README section "v0.4" for the full description and the dial ledger rows. In short:
- **R1:** both reference longitudes (β = 0 solid, β = π dashed) on the active leaf for every comb, with the label in the caption line, and a Layers toggle "Mirror axis" (view key `cm`, default on).
- **R2:** same-time tip coincidences per common period, M = P·|c·t₂|/N exact, marked on the leaf, plus the separate image-intersection count 2|p·q|.
- **R3:** the parity line, labelled (mnemonic), in the Layers menu under the branch chips.
- **R4:** on the Fourier tab, the carrier-relative mirror line e^{iπ(t₁s + f)}·ℝ, toggle "Mirror axis" (view key `fm`, default on), with the caption phrase only when t₁·s ∈ ℤ.
- **R5:** not applicable (no braid tab).

Code: exact functions are appended to `host-core/orbit-core.js` (`mirrorParity`, `mirrorPairs`, `mirrorMeeting`, `mirrorConjugate`, `mirrorCarrierPhase`; BigInt only). Numerical and drawing functions are appended to `host-core/comb-numeric.js` (`mirrorLongitudes`, `mirrorLiftPoint`, `unproject`, `longitudeDistance`, `mirrorGeometry`, `MIRROR_CAP`). They were appended rather than put in new modules, so the v0.3 build-pins test, which lists the inlined modules, holds unchanged. The views and `panel.js` draw and list them. The build pins gain `viewer: "comb-hopf v0.4"`; the pins id stays `fv-comb-hopf-build/0.1`. Address, state, exact, Lift and pair schema ids are unchanged, because no export changed.

Files added: `build/browser-check-mirror.cjs`, `host-core/test-mirror.cjs`.

Files changed against v0.3 (byte comparison; PNGs and this report excluded): `build/package.cjs`, `dist/comb-hopf.html`, `dist/MANIFEST.sha256`, `host-core/comb-numeric.js`, `host-core/orbit-core.js`, `instruments/comb-hopf/panel.js`, `instruments/comb-hopf/README.md`, `instruments/comb-hopf/view-clifford.js`, `instruments/comb-hopf/view-fourier.js`.

### Amendments from the S0 design review §5 (adopted; they take precedence over the feature note and the brief)

1. **R2 renamed and split.** The count is "same-time tip coincidences per common period", M = P·|c·t₂|/N, with events s_k = k·N/|c·t₂| for 0 ≤ k < M. "Image intersections" 2|p·q| is shown separately and is not claimed to lie on the longitudes. The 1e-9 on-longitude test applies to the same-time events only.
2. **Zero-rate guards.**
   - c·t₂ = 0: "coincide continuously"; no events and no division.
   - t₁ = 0: "same transverse circle"; the c = 0 tooth is labelled stationary, a point.
   - ρ = 0: collapsed leaf; no longitudes and no events, with a degenerate caption line. This replaces my first version, which drew two points.
3. **R4: the carrier-relative axis.** The drawn line is e^{iπ(t₁s + f)}·ℝ at every s, not the fixed real axis. The caption says only when it coincides with the real axis (t₁·s ∈ ℤ). Q-res is not cited as a certificate. The review's counterexample is a test.
4. **R1/R3 wording.** "pants (mnemonic)" and "line … (mnemonic)" are given as text only, with no Y drawn. The reference curves are drawn independently of the teeth.
5. **Negative control.** A one-sided start offset π/120 on tooth +c only, labelled as breaking the mirror pairing. The mirror-preserving paired offset is kept as an informative contrast, not as the control.
6. **R5:** not applicable. The README notes that separated braid strands are distinct from the intersecting mirror pair.

Amendment test lines (verbatim, from `host-core/test-mirror.cjs` and `build/browser-check-mirror.cjs`):

```
PASS T-MA 4 (negative control, one-sided start offset): shifting only tooth +c by β₀ = π/120 breaks the mirror pairing; its same-time events with tooth −c (2x ≡ β₀ mod 2π, x = π·c·t₂·s/N) all leave the reference longitudes: every one is farther than 1e-9 from both (distance β₀/2 = π/240 expected), and the on-longitude test that passes T-MA 2 rejects them (2690 offset events, smallest distance to a longitude 1.3090e-2 rad, π/240 = 1.3090e-2)
PASS T-MA 4b (informative contrast, not the negative control): a mirror-preserving paired offset (+β₀ on tooth +c, −β₀ on tooth −c) still puts every same-time event on a reference longitude (within 1e-9) (2690 events)
PASS T-MA 5: image intersections are a separate count: exact enumeration of the intersection points of the closed images of c and −c (windings (A, B) and (A, −B) over P) gives 2|A·B| = 2|p·q| (the count shown), the same-time ones (τ = τ′) number M, and only those lie on the reference longitudes (numerical, 1e-9) (689 pairs, 17688 image intersections enumerated) 
PASS T-MA example (feature note; review §5): N = 5, t₁ = t₂ = 1, m = 6, pair ±1: P = 10, M = 2 same-time events at s = 0 (β = 0) and s = 5 (β = π); 10 image intersections; tooth −1 at s = 1 and tooth +1 at s = 9 meet at one point that is not on a reference longitude
PASS guards: c·t₂ = 0 (t₂ = 0) gives status "coincident" for every pair, no count, no events, no division; t₁ = 0 keeps M = 2 isolated events per pair, labels both images as the same transverse circle (no image-intersection count) and the c = 0 tooth as stationary (a point, the orbit sampler agrees); N = 0 gives "undefined"; ρ = 0 (n₆ = 0) is a collapsed leaf: no longitudes, no events
PASS parity readout (R3, labelled mnemonic): odd m → "mirror c ↦ −c fixes 1 tooth (c = 0): pants (mnemonic)", label "c = 0 · carrier tooth"; even m → "… fixes 0 teeth: line between c = ∓1 (mnemonic)", label "reference carrier · no tooth"; for m = 2..40
PASS R4 (review §5): N = 5, m = 6 (offsets ±1, ±3, ±5), t₁ = 1/2, t₂ = 1, s = 1, ρ = 1: the lab-frame resultant is −i (numerical, within the bound), t₁·s ∉ ℤ so the axis is not the real axis (mirrorConjugate false), and the resultant divided by the carrier e^{iπ/2} is real (−1) within the bound
PASS R4: over every preset, the resultant divided by the carrier phase e^{iπ(t₁s + f)} is real within the numerical bound (symmetric offsets), and the lab-frame resultant is real within the bound whenever t₁·s ∈ ℤ (mirrorConjugate) (180 presets with t₁·s ∈ ℤ)
PASS 375x812 guard t₂ = 0: no event marks, the longitudes still drawn, the pair line says the trajectories coincide continuously
PASS 375x812 guard t₁ = 0: the c = 0 tooth is labelled stationary (a point, not the whole longitude); the pair line says both images are the same transverse circle and gives no image-intersection number
PASS 375x812 guard ρ = 0 (collapsed leaf): no longitudes, no events, a full degenerate caption line says so
PASS 375x812 R4 t₁·s ∈ ℤ (N = 5, m = 6, t₁ = t₂ = 1, s = 1): the mirror axis is drawn on the real axis (horizontal) and the caption says "mirror axis = real axis (t₁·s ∈ ℤ)" after Q-res
PASS 375x812 R4 review counterexample (N = 5, offsets ±1, ±3, ±5, t₁ = 1/2, t₂ = 1, s = 1, ρ = 1): resultant −i (numerical), the drawn mirror axis is the carrier line e^{iπ/2}·ℝ (vertical), not the real axis, and the caption makes no real-axis claim
PASS 375x812 R4 Fourier "Mirror axis" toggle off removes the line (view key fm=0)
PASS 1280x800 guard t₂ = 0: no event marks, the longitudes still drawn, the pair line says the trajectories coincide continuously
PASS 1280x800 guard t₁ = 0: the c = 0 tooth is labelled stationary (a point, not the whole longitude); the pair line says both images are the same transverse circle and gives no image-intersection number
PASS 1280x800 guard ρ = 0 (collapsed leaf): no longitudes, no events, a full degenerate caption line says so
PASS 1280x800 R4 t₁·s ∈ ℤ (N = 5, m = 6, t₁ = t₂ = 1, s = 1): the mirror axis is drawn on the real axis (horizontal) and the caption says "mirror axis = real axis (t₁·s ∈ ℤ)" after Q-res
PASS 1280x800 R4 review counterexample (N = 5, offsets ±1, ±3, ±5, t₁ = 1/2, t₂ = 1, s = 1, ρ = 1): resultant −i (numerical), the drawn mirror axis is the carrier line e^{iπ/2}·ℝ (vertical), not the real axis, and the caption makes no real-axis claim
PASS 1280x800 R4 Fourier "Mirror axis" toggle off removes the line (view key fm=0)
```

### Per-suite results (verbatim summary lines, final run, in this order)

```
package exit 0
test-exact: 21 passed, 0 failed
test-core: 160 passed, 0 failed
    e.g. [(a)] 6 t1=0 t2=-3 N=711156 s=379/144 mine refused (t₁ = 0: ALIGN and SPREAD stops are undef) host 3
UNEXPLAINED differences: 0
contrast-check: 93 pass, 0 fail
smallest text measured in this run: 13.0000 px
browser-check: 559 passed, 4 failed
test-mirror (T-MA): 14 passed, 0 failed
browser-check-mirror: 122 passed, 0 failed
manifest: 14 of 14 lines OK
```

- v0.3 suites, run unchanged:
  - test-exact, test-core, the parity sample and contrast-check give the same output, byte for byte, as their run on the untouched copy before any change.
  - browser-check has 4 failing assertions; they are listed below. Every other v0.3 browser assertion passes, including:
    - the cap of 40 visible controls;
    - the first-screen rule at 375×812;
    - the 13 px floor;
    - the R17 position checks;
    - the PERF bounds (the SVG overlay at the reproduction state stays under 60 elements).
- browser-check ran 563 assertions; the run on the untouched v0.3 copy ran 561 passed, 0 failed. The difference is two conditional v0.3 checks, which run only when a caption is truncated. At 1280 px the Clifford caption line, with the mirror label appended, is now ellipsized, so they run and pass:

```
PASS 1280x800 F2 tapping a truncated caption expands it (default, clifford): 2 lines
PASS 1280x800 F2 tapping again collapses it to one line (default, clifford)
```

- Failing v0.3 assertions (verbatim). These are not loosened. The v0.4 successor check is in `browser-check-mirror.cjs` ("v0.4 menu inventory").

```
FAIL 375x812 Fourier Layers menu: Teeth, Walk, Amber polygon, Divisors
FAIL 375x812 Guides none: no circles, no swatches; layer swatches only on pressed layers
FAIL 1280x800 Fourier Layers menu: Teeth, Walk, Amber polygon, Divisors
FAIL 1280x800 Guides none: no circles, no swatches; layer swatches only on pressed layers
```

  Cause: both assertions count the v0.3 inventory of the Layers menus. The Fourier assertion expects exactly 4 layer items; v0.4 adds "Mirror axis" as a fifth. The Clifford assertion expects exactly 3 pressed layers with colour swatches; v0.4 adds the "Mirror axis" toggle, pressed by default and with its swatch, as a fourth. This is a direct consequence of R1 and R4 ("a toggle in the existing controls style"). Moving the toggles out of the Layers menus or removing the swatch would only hide that.

### T-MA (verbatim)

`node host-core/test-mirror.cjs`:

```
INFO preset grid: 408 states (396 on integer shells, 12 between shells)
PASS T-MA 1: for every preset and every mirror pair, the drawn same-time tip coincidences number exactly M = P·|c·t₂|/N (P = lcm_Q(2/|t₁|, 2N/|c·t₂|) recomputed here), M is an even integer, and the events are s_k = k·N/|c·t₂|, 0 ≤ k < M, alternating β = 0 / β = π (816 pairs with c·t₂ ≠ 0, 2690 events drawn; 127 partial-orbit pairs checked in T-MA 6; 0 pairs with c·t₂ = 0) 
PASS T-MA 2: every drawn same-time event lies on a reference longitude within 1e-9 (|arg z₂ − β| from the inverse projection of the drawn 3D point; |z₁| = a, |z₂| = b), on β = 0 for even k and β = π for odd k; tooth −c is at the same point (1e-9); the unreduced float lift of both teeth at s_k agrees (1e-9) (worst on-longitude 1.33e-15, worst c / −c separation 0.00e+0, worst unreduced-lift difference 9.49e-15; 0 bad)
PASS T-MA 3: for every odd comb with t₁ ≠ 0 the drawn c = 0 orbit lies on the β = 0 longitude within 1e-9 at every point (|arg z₂|, |z₁| = a, |z₂| = b) and covers it (largest gap in arg z₁ ≤ 2.01°); the drawn β = 0 longitude points lie on it as well (202 odd combs, worst 2.01e-15, largest arg z₁ gap 2.000°)
PASS T-MA 4 (negative control, one-sided start offset): shifting only tooth +c by β₀ = π/120 breaks the mirror pairing; its same-time events with tooth −c (2x ≡ β₀ mod 2π, x = π·c·t₂·s/N) all leave the reference longitudes: every one is farther than 1e-9 from both (distance β₀/2 = π/240 expected), and the on-longitude test that passes T-MA 2 rejects them (2690 offset events, smallest distance to a longitude 1.3090e-2 rad, π/240 = 1.3090e-2)
PASS T-MA 4b (informative contrast, not the negative control): a mirror-preserving paired offset (+β₀ on tooth +c, −β₀ on tooth −c) still puts every same-time event on a reference longitude (within 1e-9) (2690 events)
PASS T-MA 5: image intersections are a separate count: exact enumeration of the intersection points of the closed images of c and −c (windings (A, B) and (A, −B) over P) gives 2|A·B| = 2|p·q| (the count shown), the same-time ones (τ = τ′) number M, and only those lie on the reference longitudes (numerical, 1e-9) (689 pairs, 17688 image intersections enumerated) 
PASS T-MA 6: for every pair whose orbit is drawn as a partial window, the drawn same-time events are exactly the s_k = k·N/|c·t₂| inside the drawn window [s − span/2, s + span/2] (recounted here), flagged partial, never more than M, and the exact M is still the pair count (127 partial-orbit pairs)
PASS drawing cap: at m = 720 (360 pairs) the drawn events stop at MIRROR_CAP = 2000 and the geometry says so (capped, labelled in the view); every exact count is still reported (drawn 2000)
PASS T-MA example (feature note; review §5): N = 5, t₁ = t₂ = 1, m = 6, pair ±1: P = 10, M = 2 same-time events at s = 0 (β = 0) and s = 5 (β = π); 10 image intersections; tooth −1 at s = 1 and tooth +1 at s = 9 meet at one point that is not on a reference longitude
PASS guards: c·t₂ = 0 (t₂ = 0) gives status "coincident" for every pair, no count, no events, no division; t₁ = 0 keeps M = 2 isolated events per pair, labels both images as the same transverse circle (no image-intersection count) and the c = 0 tooth as stationary (a point, the orbit sampler agrees); N = 0 gives "undefined"; ρ = 0 (n₆ = 0) is a collapsed leaf: no longitudes, no events
PASS parity readout (R3, labelled mnemonic): odd m → "mirror c ↦ −c fixes 1 tooth (c = 0): pants (mnemonic)", label "c = 0 · carrier tooth"; even m → "… fixes 0 teeth: line between c = ∓1 (mnemonic)", label "reference carrier · no tooth"; for m = 2..40
PASS R4 (review §5): N = 5, m = 6 (offsets ±1, ±3, ±5), t₁ = 1/2, t₂ = 1, s = 1, ρ = 1: the lab-frame resultant is −i (numerical, within the bound), t₁·s ∉ ℤ so the axis is not the real axis (mirrorConjugate false), and the resultant divided by the carrier e^{iπ/2} is real (−1) within the bound
PASS R4: over every preset, the resultant divided by the carrier phase e^{iπ(t₁s + f)} is real within the numerical bound (symmetric offsets), and the lab-frame resultant is real within the bound whenever t₁·s ∈ ℤ (mirrorConjugate) (180 presets with t₁·s ∈ ℤ)
PASS display register only: against the v0.3 modules (read-only), every preset gives identical branches (Lift entries), gates, field line, exact export and state export; the branch count stays m (the reference longitudes are no branch) (408 states, 0 differences)
INFO worst numerical figures: on-longitude 1.332e-15, c/−c separation 0.000e+0, unreduced-lift difference 9.495e-15
test-mirror (T-MA): 14 passed, 0 failed
```

`node build/browser-check-mirror.cjs` (full output):

```
PASS 375x812 T-MA preset 0 (N = 5, m = 5, t₁ = 1, t₂ = 1, s = 1/3): drawn same-time events per pair equal the exact M = P·|c·t₂|/N (±1: 2 of M = 2, ±2: 4 of M = 4)
PASS 375x812 T-MA preset 0 (N = 5, m = 5, t₁ = 1, t₂ = 1, s = 1/3): every drawn event lies on a reference longitude within 1e-9 (worst 1.57e-16), on β = 0 for even k and β = π for odd k, and it is drawn on the canvas (its centre or ring pixel; marks of different pairs can share a point and overlap)
PASS 375x812 T-MA preset 0 (N = 5, m = 5, t₁ = 1, t₂ = 1, s = 1/3): both reference longitudes drawn (β = 0 and β = π stubs, two canvas runs of 361 points, labels "β = 0" and "β = π"), independent of whether a tooth traverses them
PASS 375x812 T-MA preset 0 (N = 5, m = 5, t₁ = 1, t₂ = 1, s = 1/3): caption line carries the label "c = 0 · carrier tooth"
PASS 375x812 T-MA preset 1 (N = 5, m = 6, t₁ = 1, t₂ = 1, s = 1/3): drawn same-time events per pair equal the exact M = P·|c·t₂|/N (±1: 2 of M = 2, ±3: 6 of M = 6, ±5: 2 of M = 2)
PASS 375x812 T-MA preset 1 (N = 5, m = 6, t₁ = 1, t₂ = 1, s = 1/3): every drawn event lies on a reference longitude within 1e-9 (worst 2.36e-16), on β = 0 for even k and β = π for odd k, and it is drawn on the canvas (its centre or ring pixel; marks of different pairs can share a point and overlap)
PASS 375x812 T-MA preset 1 (N = 5, m = 6, t₁ = 1, t₂ = 1, s = 1/3): both reference longitudes drawn (β = 0 and β = π stubs, two canvas runs of 361 points, labels "β = 0" and "β = π"), independent of whether a tooth traverses them
PASS 375x812 T-MA preset 1 (N = 5, m = 6, t₁ = 1, t₂ = 1, s = 1/3): caption line carries the label "reference carrier · no tooth"
PASS 375x812 T-MA preset 2 (N = 5, m = 6, t₁ = 1, t₂ = 1, s = 0): drawn same-time events per pair equal the exact M = P·|c·t₂|/N (±1: 2 of M = 2, ±3: 6 of M = 6, ±5: 2 of M = 2)
PASS 375x812 T-MA preset 2 (N = 5, m = 6, t₁ = 1, t₂ = 1, s = 0): every drawn event lies on a reference longitude within 1e-9 (worst 2.36e-16), on β = 0 for even k and β = π for odd k, and it is drawn on the canvas (its centre or ring pixel; marks of different pairs can share a point and overlap)
PASS 375x812 T-MA preset 2 (N = 5, m = 6, t₁ = 1, t₂ = 1, s = 0): both reference longitudes drawn (β = 0 and β = π stubs, two canvas runs of 361 points, labels "β = 0" and "β = π"), independent of whether a tooth traverses them
PASS 375x812 T-MA preset 2 (N = 5, m = 6, t₁ = 1, t₂ = 1, s = 0): caption line carries the label "reference carrier · no tooth"
PASS 375x812 T-MA preset 3 (N = 4, m = 7, t₁ = 1, t₂ = 1, s = 4/7): drawn same-time events per pair equal the exact M = P·|c·t₂|/N (±1: 2 of M = 2, ±2: 2 of M = 2, ±3: 6 of M = 6)
PASS 375x812 T-MA preset 3 (N = 4, m = 7, t₁ = 1, t₂ = 1, s = 4/7): every drawn event lies on a reference longitude within 1e-9 (worst 2.36e-16), on β = 0 for even k and β = π for odd k, and it is drawn on the canvas (its centre or ring pixel; marks of different pairs can share a point and overlap)
PASS 375x812 T-MA preset 3 (N = 4, m = 7, t₁ = 1, t₂ = 1, s = 4/7): both reference longitudes drawn (β = 0 and β = π stubs, two canvas runs of 361 points, labels "β = 0" and "β = π"), independent of whether a tooth traverses them
PASS 375x812 T-MA preset 3 (N = 4, m = 7, t₁ = 1, t₂ = 1, s = 4/7): caption line carries the label "c = 0 · carrier tooth"
PASS 375x812 T-MA preset 4 (N = 8, m = 4, t₁ = 1/2, t₂ = 1, s = 1): drawn same-time events per pair equal the exact M = P·|c·t₂|/N (±1: 2 of M = 2, ±3: 6 of M = 6)
PASS 375x812 T-MA preset 4 (N = 8, m = 4, t₁ = 1/2, t₂ = 1, s = 1): every drawn event lies on a reference longitude within 1e-9 (worst 2.36e-16), on β = 0 for even k and β = π for odd k, and it is drawn on the canvas (its centre or ring pixel; marks of different pairs can share a point and overlap)
PASS 375x812 T-MA preset 4 (N = 8, m = 4, t₁ = 1/2, t₂ = 1, s = 1): both reference longitudes drawn (β = 0 and β = π stubs, two canvas runs of 361 points, labels "β = 0" and "β = π"), independent of whether a tooth traverses them
PASS 375x812 T-MA preset 4 (N = 8, m = 4, t₁ = 1/2, t₂ = 1, s = 1): caption line carries the label "reference carrier · no tooth"
PASS 375x812 T-MA preset 5 (N = 6, m = 3, t₁ = 2, t₂ = 1/3, s = -5/2): drawn same-time events per pair equal the exact M = P·|c·t₂|/N (±1: 1 in a partial window of M = 2)
PASS 375x812 T-MA preset 5 (N = 6, m = 3, t₁ = 2, t₂ = 1/3, s = -5/2): every drawn event lies on a reference longitude within 1e-9 (worst 1.57e-16), on β = 0 for even k and β = π for odd k, and it is drawn on the canvas (its centre or ring pixel; marks of different pairs can share a point and overlap)
PASS 375x812 T-MA preset 5 (N = 6, m = 3, t₁ = 2, t₂ = 1/3, s = -5/2): both reference longitudes drawn (β = 0 and β = π stubs, two canvas runs of 361 points, labels "β = 0" and "β = π"), independent of whether a tooth traverses them
PASS 375x812 T-MA preset 5 (N = 6, m = 3, t₁ = 2, t₂ = 1/3, s = -5/2): caption line carries the label "c = 0 · carrier tooth"
PASS 375x812 T-MA preset 6 (N = 3, m = 8, t₁ = 3/2, t₂ = -3/2, s = 7/3, n₆ = −1): drawn same-time events per pair equal the exact M = P·|c·t₂|/N (±1: 2 of M = 2, ±3: 2 of M = 2, ±5: 10 of M = 10, ±7: 14 of M = 14)
PASS 375x812 T-MA preset 6 (N = 3, m = 8, t₁ = 3/2, t₂ = -3/2, s = 7/3, n₆ = −1): every drawn event lies on a reference longitude within 1e-9 (worst 2.22e-16), on β = 0 for even k and β = π for odd k, and it is drawn on the canvas (its centre or ring pixel; marks of different pairs can share a point and overlap)
PASS 375x812 T-MA preset 6 (N = 3, m = 8, t₁ = 3/2, t₂ = -3/2, s = 7/3, n₆ = −1): both reference longitudes drawn (β = 0 and β = π stubs, two canvas runs of 361 points, labels "β = 0" and "β = π"), independent of whether a tooth traverses them
PASS 375x812 T-MA preset 6 (N = 3, m = 8, t₁ = 3/2, t₂ = -3/2, s = 7/3, n₆ = −1): caption line carries the label "reference carrier · no tooth"
PASS 375x812 T-MA preset 7 (N = 2, m = 2, t₁ = 1, t₂ = 1, s = 1): drawn same-time events per pair equal the exact M = P·|c·t₂|/N (±1: 2 of M = 2)
PASS 375x812 T-MA preset 7 (N = 2, m = 2, t₁ = 1, t₂ = 1, s = 1): every drawn event lies on a reference longitude within 1e-9 (worst 1.57e-16), on β = 0 for even k and β = π for odd k, and it is drawn on the canvas (its centre or ring pixel; marks of different pairs can share a point and overlap)
PASS 375x812 T-MA preset 7 (N = 2, m = 2, t₁ = 1, t₂ = 1, s = 1): both reference longitudes drawn (β = 0 and β = π stubs, two canvas runs of 361 points, labels "β = 0" and "β = π"), independent of whether a tooth traverses them
PASS 375x812 T-MA preset 7 (N = 2, m = 2, t₁ = 1, t₂ = 1, s = 1): caption line carries the label "reference carrier · no tooth"
PASS 375x812 T-MA preset 8 (N = 10, m = 5, t₁ = -1, t₂ = 2, s = 0): drawn same-time events per pair equal the exact M = P·|c·t₂|/N (±1: 2 of M = 2, ±2: 4 of M = 4)
PASS 375x812 T-MA preset 8 (N = 10, m = 5, t₁ = -1, t₂ = 2, s = 0): every drawn event lies on a reference longitude within 1e-9 (worst 0.00e+0), on β = 0 for even k and β = π for odd k, and it is drawn on the canvas (its centre or ring pixel; marks of different pairs can share a point and overlap)
PASS 375x812 T-MA preset 8 (N = 10, m = 5, t₁ = -1, t₂ = 2, s = 0): both reference longitudes drawn (β = 0 and β = π stubs, two canvas runs of 361 points, labels "β = 0" and "β = π"), independent of whether a tooth traverses them
PASS 375x812 T-MA preset 8 (N = 10, m = 5, t₁ = -1, t₂ = 2, s = 0): caption line carries the label "c = 0 · carrier tooth"
PASS 375x812 T-MA preset 9 (N = 43/2, m = 4, t₁ = 1, t₂ = 1, s = 1/3): drawn same-time events per pair equal the exact M = P·|c·t₂|/N (±1: 2 in a partial window of M = 4, ±3: 5 in a partial window of M = 12)
PASS 375x812 T-MA preset 9 (N = 43/2, m = 4, t₁ = 1, t₂ = 1, s = 1/3): every drawn event lies on a reference longitude within 1e-9 (worst 1.57e-16), on β = 0 for even k and β = π for odd k, and it is drawn on the canvas (its centre or ring pixel; marks of different pairs can share a point and overlap)
PASS 375x812 T-MA preset 9 (N = 43/2, m = 4, t₁ = 1, t₂ = 1, s = 1/3): both reference longitudes drawn (β = 0 and β = π stubs, two canvas runs of 361 points, labels "β = 0" and "β = π"), independent of whether a tooth traverses them
PASS 375x812 T-MA preset 9 (N = 43/2, m = 4, t₁ = 1, t₂ = 1, s = 1/3): caption line carries the label "reference carrier · no tooth"
PASS 375x812 T-MA preset 10 (N = 5, m = 5, t₁ = 0, t₂ = 1, s = 1/3): drawn same-time events per pair equal the exact M = P·|c·t₂|/N (±1: 2 of M = 2, ±2: 2 of M = 2)
PASS 375x812 T-MA preset 10 (N = 5, m = 5, t₁ = 0, t₂ = 1, s = 1/3): every drawn event lies on a reference longitude within 1e-9 (worst 1.57e-16), on β = 0 for even k and β = π for odd k, and it is drawn on the canvas (its centre or ring pixel; marks of different pairs can share a point and overlap)
PASS 375x812 T-MA preset 10 (N = 5, m = 5, t₁ = 0, t₂ = 1, s = 1/3): both reference longitudes drawn (β = 0 and β = π stubs, two canvas runs of 361 points, labels "β = 0" and "β = π"), independent of whether a tooth traverses them
PASS 375x812 T-MA preset 10 (N = 5, m = 5, t₁ = 0, t₂ = 1, s = 1/3): caption line carries the label "c = 0 · carrier tooth"
PASS 375x812 odd comb: Layers menu has the "Mirror axis" toggle (pressed by default), the parity line "mirror c ↦ −c fixes 1 tooth (c = 0): pants (mnemonic) · c = 0 · carrier tooth" and the ±1 line
PASS 375x812 odd comb with the Layers menu open: no visible text below 13 px (smallest 13.000 px)
PASS 375x812 even comb: Layers menu has the "Mirror axis" toggle (pressed by default), the parity line "mirror c ↦ −c fixes 0 teeth: line between c = ∓1 (mnemonic) · reference carrier · no tooth" and the ±1 line
PASS 375x812 even comb with the Layers menu open: no visible text below 13 px (smallest 13.000 px)
PASS 375x812 toggle off: no longitudes, no event marks, no caption phrase, view key cm=0 in the address, the exact export byte-identical, the pair line still gives the exact M and says "layer off"
PASS 375x812 toggle on again: longitudes and the 10 event marks of the Z6 comb back, cm back to its default (not in the address)
PASS 375x812 after a camera drag: still 10 event marks, moved on screen, each on a reference longitude within 1e-9
PASS 375x812 guard t₂ = 0: no event marks, the longitudes still drawn, the pair line says the trajectories coincide continuously
PASS 375x812 guard t₁ = 0: the c = 0 tooth is labelled stationary (a point, not the whole longitude); the pair line says both images are the same transverse circle and gives no image-intersection number
PASS 375x812 guard ρ = 0 (collapsed leaf): no longitudes, no events, a full degenerate caption line says so
PASS 375x812 R4 t₁·s ∈ ℤ (N = 5, m = 6, t₁ = t₂ = 1, s = 1): the mirror axis is drawn on the real axis (horizontal) and the caption says "mirror axis = real axis (t₁·s ∈ ℤ)" after Q-res
PASS 375x812 R4 review counterexample (N = 5, offsets ±1, ±3, ±5, t₁ = 1/2, t₂ = 1, s = 1, ρ = 1): resultant −i (numerical), the drawn mirror axis is the carrier line e^{iπ/2}·ℝ (vertical), not the real axis, and the caption makes no real-axis claim
PASS 375x812 Fourier tab with the mirror axis: no visible text below 13 px (smallest 13.000 px)
PASS 375x812 R4 Fourier "Mirror axis" toggle off removes the line (view key fm=0)
PASS 375x812 v0.4 menu inventory: Fourier Layers = Teeth, Walk, Amber polygon, ÷ Divisors, Mirror axis (5); Clifford pressed layers with swatches = leaf, s-orbits, Grid, Mirror axis (4)
PASS 375x812 no horizontal scroll
PASS 375x812 no console or page errors in the mirror checks
PASS 1280x800 T-MA preset 0 (N = 5, m = 5, t₁ = 1, t₂ = 1, s = 1/3): drawn same-time events per pair equal the exact M = P·|c·t₂|/N (±1: 2 of M = 2, ±2: 4 of M = 4)
PASS 1280x800 T-MA preset 0 (N = 5, m = 5, t₁ = 1, t₂ = 1, s = 1/3): every drawn event lies on a reference longitude within 1e-9 (worst 1.57e-16), on β = 0 for even k and β = π for odd k, and it is drawn on the canvas (its centre or ring pixel; marks of different pairs can share a point and overlap)
PASS 1280x800 T-MA preset 0 (N = 5, m = 5, t₁ = 1, t₂ = 1, s = 1/3): both reference longitudes drawn (β = 0 and β = π stubs, two canvas runs of 361 points, labels "β = 0" and "β = π"), independent of whether a tooth traverses them
PASS 1280x800 T-MA preset 0 (N = 5, m = 5, t₁ = 1, t₂ = 1, s = 1/3): caption line carries the label "c = 0 · carrier tooth"
PASS 1280x800 T-MA preset 1 (N = 5, m = 6, t₁ = 1, t₂ = 1, s = 1/3): drawn same-time events per pair equal the exact M = P·|c·t₂|/N (±1: 2 of M = 2, ±3: 6 of M = 6, ±5: 2 of M = 2)
PASS 1280x800 T-MA preset 1 (N = 5, m = 6, t₁ = 1, t₂ = 1, s = 1/3): every drawn event lies on a reference longitude within 1e-9 (worst 2.36e-16), on β = 0 for even k and β = π for odd k, and it is drawn on the canvas (its centre or ring pixel; marks of different pairs can share a point and overlap)
PASS 1280x800 T-MA preset 1 (N = 5, m = 6, t₁ = 1, t₂ = 1, s = 1/3): both reference longitudes drawn (β = 0 and β = π stubs, two canvas runs of 361 points, labels "β = 0" and "β = π"), independent of whether a tooth traverses them
PASS 1280x800 T-MA preset 1 (N = 5, m = 6, t₁ = 1, t₂ = 1, s = 1/3): caption line carries the label "reference carrier · no tooth"
PASS 1280x800 T-MA preset 2 (N = 5, m = 6, t₁ = 1, t₂ = 1, s = 0): drawn same-time events per pair equal the exact M = P·|c·t₂|/N (±1: 2 of M = 2, ±3: 6 of M = 6, ±5: 2 of M = 2)
PASS 1280x800 T-MA preset 2 (N = 5, m = 6, t₁ = 1, t₂ = 1, s = 0): every drawn event lies on a reference longitude within 1e-9 (worst 2.36e-16), on β = 0 for even k and β = π for odd k, and it is drawn on the canvas (its centre or ring pixel; marks of different pairs can share a point and overlap)
PASS 1280x800 T-MA preset 2 (N = 5, m = 6, t₁ = 1, t₂ = 1, s = 0): both reference longitudes drawn (β = 0 and β = π stubs, two canvas runs of 361 points, labels "β = 0" and "β = π"), independent of whether a tooth traverses them
PASS 1280x800 T-MA preset 2 (N = 5, m = 6, t₁ = 1, t₂ = 1, s = 0): caption line carries the label "reference carrier · no tooth"
PASS 1280x800 T-MA preset 3 (N = 4, m = 7, t₁ = 1, t₂ = 1, s = 4/7): drawn same-time events per pair equal the exact M = P·|c·t₂|/N (±1: 2 of M = 2, ±2: 2 of M = 2, ±3: 6 of M = 6)
PASS 1280x800 T-MA preset 3 (N = 4, m = 7, t₁ = 1, t₂ = 1, s = 4/7): every drawn event lies on a reference longitude within 1e-9 (worst 2.36e-16), on β = 0 for even k and β = π for odd k, and it is drawn on the canvas (its centre or ring pixel; marks of different pairs can share a point and overlap)
PASS 1280x800 T-MA preset 3 (N = 4, m = 7, t₁ = 1, t₂ = 1, s = 4/7): both reference longitudes drawn (β = 0 and β = π stubs, two canvas runs of 361 points, labels "β = 0" and "β = π"), independent of whether a tooth traverses them
PASS 1280x800 T-MA preset 3 (N = 4, m = 7, t₁ = 1, t₂ = 1, s = 4/7): caption line carries the label "c = 0 · carrier tooth"
PASS 1280x800 T-MA preset 4 (N = 8, m = 4, t₁ = 1/2, t₂ = 1, s = 1): drawn same-time events per pair equal the exact M = P·|c·t₂|/N (±1: 2 of M = 2, ±3: 6 of M = 6)
PASS 1280x800 T-MA preset 4 (N = 8, m = 4, t₁ = 1/2, t₂ = 1, s = 1): every drawn event lies on a reference longitude within 1e-9 (worst 2.36e-16), on β = 0 for even k and β = π for odd k, and it is drawn on the canvas (its centre or ring pixel; marks of different pairs can share a point and overlap)
PASS 1280x800 T-MA preset 4 (N = 8, m = 4, t₁ = 1/2, t₂ = 1, s = 1): both reference longitudes drawn (β = 0 and β = π stubs, two canvas runs of 361 points, labels "β = 0" and "β = π"), independent of whether a tooth traverses them
PASS 1280x800 T-MA preset 4 (N = 8, m = 4, t₁ = 1/2, t₂ = 1, s = 1): caption line carries the label "reference carrier · no tooth"
PASS 1280x800 T-MA preset 5 (N = 6, m = 3, t₁ = 2, t₂ = 1/3, s = -5/2): drawn same-time events per pair equal the exact M = P·|c·t₂|/N (±1: 1 in a partial window of M = 2)
PASS 1280x800 T-MA preset 5 (N = 6, m = 3, t₁ = 2, t₂ = 1/3, s = -5/2): every drawn event lies on a reference longitude within 1e-9 (worst 1.57e-16), on β = 0 for even k and β = π for odd k, and it is drawn on the canvas (its centre or ring pixel; marks of different pairs can share a point and overlap)
PASS 1280x800 T-MA preset 5 (N = 6, m = 3, t₁ = 2, t₂ = 1/3, s = -5/2): both reference longitudes drawn (β = 0 and β = π stubs, two canvas runs of 361 points, labels "β = 0" and "β = π"), independent of whether a tooth traverses them
PASS 1280x800 T-MA preset 5 (N = 6, m = 3, t₁ = 2, t₂ = 1/3, s = -5/2): caption line carries the label "c = 0 · carrier tooth"
PASS 1280x800 T-MA preset 6 (N = 3, m = 8, t₁ = 3/2, t₂ = -3/2, s = 7/3, n₆ = −1): drawn same-time events per pair equal the exact M = P·|c·t₂|/N (±1: 2 of M = 2, ±3: 2 of M = 2, ±5: 10 of M = 10, ±7: 14 of M = 14)
PASS 1280x800 T-MA preset 6 (N = 3, m = 8, t₁ = 3/2, t₂ = -3/2, s = 7/3, n₆ = −1): every drawn event lies on a reference longitude within 1e-9 (worst 2.22e-16), on β = 0 for even k and β = π for odd k, and it is drawn on the canvas (its centre or ring pixel; marks of different pairs can share a point and overlap)
PASS 1280x800 T-MA preset 6 (N = 3, m = 8, t₁ = 3/2, t₂ = -3/2, s = 7/3, n₆ = −1): both reference longitudes drawn (β = 0 and β = π stubs, two canvas runs of 361 points, labels "β = 0" and "β = π"), independent of whether a tooth traverses them
PASS 1280x800 T-MA preset 6 (N = 3, m = 8, t₁ = 3/2, t₂ = -3/2, s = 7/3, n₆ = −1): caption line carries the label "reference carrier · no tooth"
PASS 1280x800 T-MA preset 7 (N = 2, m = 2, t₁ = 1, t₂ = 1, s = 1): drawn same-time events per pair equal the exact M = P·|c·t₂|/N (±1: 2 of M = 2)
PASS 1280x800 T-MA preset 7 (N = 2, m = 2, t₁ = 1, t₂ = 1, s = 1): every drawn event lies on a reference longitude within 1e-9 (worst 1.57e-16), on β = 0 for even k and β = π for odd k, and it is drawn on the canvas (its centre or ring pixel; marks of different pairs can share a point and overlap)
PASS 1280x800 T-MA preset 7 (N = 2, m = 2, t₁ = 1, t₂ = 1, s = 1): both reference longitudes drawn (β = 0 and β = π stubs, two canvas runs of 361 points, labels "β = 0" and "β = π"), independent of whether a tooth traverses them
PASS 1280x800 T-MA preset 7 (N = 2, m = 2, t₁ = 1, t₂ = 1, s = 1): caption line carries the label "reference carrier · no tooth"
PASS 1280x800 T-MA preset 8 (N = 10, m = 5, t₁ = -1, t₂ = 2, s = 0): drawn same-time events per pair equal the exact M = P·|c·t₂|/N (±1: 2 of M = 2, ±2: 4 of M = 4)
PASS 1280x800 T-MA preset 8 (N = 10, m = 5, t₁ = -1, t₂ = 2, s = 0): every drawn event lies on a reference longitude within 1e-9 (worst 0.00e+0), on β = 0 for even k and β = π for odd k, and it is drawn on the canvas (its centre or ring pixel; marks of different pairs can share a point and overlap)
PASS 1280x800 T-MA preset 8 (N = 10, m = 5, t₁ = -1, t₂ = 2, s = 0): both reference longitudes drawn (β = 0 and β = π stubs, two canvas runs of 361 points, labels "β = 0" and "β = π"), independent of whether a tooth traverses them
PASS 1280x800 T-MA preset 8 (N = 10, m = 5, t₁ = -1, t₂ = 2, s = 0): caption line carries the label "c = 0 · carrier tooth"
PASS 1280x800 T-MA preset 9 (N = 43/2, m = 4, t₁ = 1, t₂ = 1, s = 1/3): drawn same-time events per pair equal the exact M = P·|c·t₂|/N (±1: 2 in a partial window of M = 4, ±3: 5 in a partial window of M = 12)
PASS 1280x800 T-MA preset 9 (N = 43/2, m = 4, t₁ = 1, t₂ = 1, s = 1/3): every drawn event lies on a reference longitude within 1e-9 (worst 1.57e-16), on β = 0 for even k and β = π for odd k, and it is drawn on the canvas (its centre or ring pixel; marks of different pairs can share a point and overlap)
PASS 1280x800 T-MA preset 9 (N = 43/2, m = 4, t₁ = 1, t₂ = 1, s = 1/3): both reference longitudes drawn (β = 0 and β = π stubs, two canvas runs of 361 points, labels "β = 0" and "β = π"), independent of whether a tooth traverses them
PASS 1280x800 T-MA preset 9 (N = 43/2, m = 4, t₁ = 1, t₂ = 1, s = 1/3): caption line carries the label "reference carrier · no tooth"
PASS 1280x800 T-MA preset 10 (N = 5, m = 5, t₁ = 0, t₂ = 1, s = 1/3): drawn same-time events per pair equal the exact M = P·|c·t₂|/N (±1: 2 of M = 2, ±2: 2 of M = 2)
PASS 1280x800 T-MA preset 10 (N = 5, m = 5, t₁ = 0, t₂ = 1, s = 1/3): every drawn event lies on a reference longitude within 1e-9 (worst 1.57e-16), on β = 0 for even k and β = π for odd k, and it is drawn on the canvas (its centre or ring pixel; marks of different pairs can share a point and overlap)
PASS 1280x800 T-MA preset 10 (N = 5, m = 5, t₁ = 0, t₂ = 1, s = 1/3): both reference longitudes drawn (β = 0 and β = π stubs, two canvas runs of 361 points, labels "β = 0" and "β = π"), independent of whether a tooth traverses them
PASS 1280x800 T-MA preset 10 (N = 5, m = 5, t₁ = 0, t₂ = 1, s = 1/3): caption line carries the label "c = 0 · carrier tooth"
PASS 1280x800 odd comb: Layers menu has the "Mirror axis" toggle (pressed by default), the parity line "mirror c ↦ −c fixes 1 tooth (c = 0): pants (mnemonic) · c = 0 · carrier tooth" and the ±1 line
PASS 1280x800 odd comb with the Layers menu open: no visible text below 13 px (smallest 13.000 px)
PASS 1280x800 even comb: Layers menu has the "Mirror axis" toggle (pressed by default), the parity line "mirror c ↦ −c fixes 0 teeth: line between c = ∓1 (mnemonic) · reference carrier · no tooth" and the ±1 line
PASS 1280x800 even comb with the Layers menu open: no visible text below 13 px (smallest 13.000 px)
PASS 1280x800 toggle off: no longitudes, no event marks, no caption phrase, view key cm=0 in the address, the exact export byte-identical, the pair line still gives the exact M and says "layer off"
PASS 1280x800 toggle on again: longitudes and the 10 event marks of the Z6 comb back, cm back to its default (not in the address)
PASS 1280x800 after a camera drag: still 10 event marks, moved on screen, each on a reference longitude within 1e-9
PASS 1280x800 guard t₂ = 0: no event marks, the longitudes still drawn, the pair line says the trajectories coincide continuously
PASS 1280x800 guard t₁ = 0: the c = 0 tooth is labelled stationary (a point, not the whole longitude); the pair line says both images are the same transverse circle and gives no image-intersection number
PASS 1280x800 guard ρ = 0 (collapsed leaf): no longitudes, no events, a full degenerate caption line says so
PASS 1280x800 R4 t₁·s ∈ ℤ (N = 5, m = 6, t₁ = t₂ = 1, s = 1): the mirror axis is drawn on the real axis (horizontal) and the caption says "mirror axis = real axis (t₁·s ∈ ℤ)" after Q-res
PASS 1280x800 R4 review counterexample (N = 5, offsets ±1, ±3, ±5, t₁ = 1/2, t₂ = 1, s = 1, ρ = 1): resultant −i (numerical), the drawn mirror axis is the carrier line e^{iπ/2}·ℝ (vertical), not the real axis, and the caption makes no real-axis claim
PASS 1280x800 Fourier tab with the mirror axis: no visible text below 13 px (smallest 13.000 px)
PASS 1280x800 R4 Fourier "Mirror axis" toggle off removes the line (view key fm=0)
PASS 1280x800 v0.4 menu inventory: Fourier Layers = Teeth, Walk, Amber polygon, ÷ Divisors, Mirror axis (5); Clifford pressed layers with swatches = leaf, s-orbits, Grid, Mirror axis (4)
PASS 1280x800 no horizontal scroll
PASS 1280x800 no console or page errors in the mirror checks
browser-check-mirror: 122 passed, 0 failed
```

### Screenshots (written by build/browser-check-mirror.cjs; each was looked at)

- `shot_v04_1280x800_clifford_even.png`
- `shot_v04_1280x800_clifford_even_layers.png`
- `shot_v04_1280x800_clifford_odd.png`
- `shot_v04_1280x800_clifford_odd_layers.png`
- `shot_v04_1280x800_fourier.png`
- `shot_v04_1280x800_fourier_counterexample.png`
- `shot_v04_375x812_clifford_even.png`
- `shot_v04_375x812_clifford_even_layers.png`
- `shot_v04_375x812_clifford_odd.png`
- `shot_v04_375x812_clifford_odd_layers.png`
- `shot_v04_375x812_fourier.png`
- `shot_v04_375x812_fourier_counterexample.png`

The v0.3 screenshot set (`shot_*.png`, `export_*.png`) was regenerated by the v0.3 browser-check. It now shows the mirror layer, which is on by default.

### Not applicable, not done, deviations, observations

1. **R5 is not applicable.** There is no braid tab, and none was invented.
2. **Colour.** The mirror objects use the carrier's violet `#c084fc`, not the merged viewer's gold. Gold is almost the tooth colour `#fbbf24` (c = ±3 for even m, ±2 for odd m) and was indistinguishable from it in the first screenshots.
3. **Where the counts are shown.** The per-pair counts are lines under the branch chips (Layers, Advanced), coloured like the pair, not text inside each chip. The v0.3 chip-text tests pin the chip text.
4. **Plane tab (R4).** The brief asked to mark "the real axis when the comb has conjugate pairs". Per the review, v0.4 draws the carrier-relative line at every s; it equals the real axis only when t₁·s ∈ ℤ.
5. **Observation (no change made, existing readout).** The v0.3 Fourier caption shows ★ in green whenever s ∈ ℤ (inherited host convention, SCHEMA_ADDENDUM_2). At the review's counterexample (t₁ = 1/2, s = 1) it shows ★ with Q-res 1.0e+0 (screenshot `shot_v04_1280x800_fourier_counterexample.png`), because the lab-frame sum is real only when t₁·s ∈ ℤ. Whether ★ should key on t₁·s ∈ ℤ is for saphir; v0.4 does not change exact or existing readouts.
6. **Same-time events of different pairs can share a point** (for example, at s = 0 every pair meets on β = 0). Their marks overlap. The browser pixel check accepts the centre or the ring pixel for that reason.
7. **Drawing caps.** At most 2,000 events are drawn per state, with a degenerate caption line when the cap is reached. At most 8 pair lines are shown in the Layers menu, followed by "⋯ n more pairs".
8. **Not tested:** a real phone (Playwright emulation only), and speed scripts (`perf-*.cjs`, not run). The v0.3 PERF regression bounds in browser-check pass.

### Pins

- `dist/comb-hopf.html` sha256 `78c2110106f2d4f45ae34b9cc2af024eabd353483b32499a06e19a3fa3998838` (two consecutive `node build/package.cjs` runs give the same hash)
- `dist/MANIFEST.sha256` sha256 `b6becd0e81ae844dcf171eb2705b5bdc0e76f6e62d5846e6785446416a94511a`
- Inlined exact-lib 0.2.0 unchanged: `3edfc8fb396fda90cfa945963eb18ccdf243f5a491e3ee49275b5c459a223a71`
- `SHA256SUMS.txt` (LF) lists every file of this folder except itself; its own hash is reported outside it.

Credits:
- saphir: the observations;
- Claude Fable 5.1: the feature note;
- Codex (discipline coordinator): the S0 design review amendments (review #539);
- the v0.1–v0.3 builders: as recorded in the sections above (v0.1: Claude Sonnet 5.5; v0.3 steps 1 and 2: Claude Opus 5.5 subagents; the v0.2 sections name no builder);
- Claude Opus 5.5: v0.4.

## v0.4.1 (2026-10-19): shell range n₁ 1–13 and B ≥ 1, the ★ on t₁·s ∈ ℤ, carrier foliation

Builder: subagent (Claude Opus 5.5). Additive successor of v0.4 in `FOURIER_VIEWER_PROTOTYPE_v0_4_1_20261019`.
- The v0.4 folder was copied after its `SHA256SUMS.txt` (`70017399370681a02faedb287cae0d9fd035df014440c8fb47fd1002b9180d90`) verified 85 of 85 files.
- v0.4 and v0.3 were not touched, and nothing outside this folder and the scratchpad was edited. No git command was run, and nothing was downloaded.
- The domain changes are specified in `SCHEMA_ADDENDUM_9.md` (new); `SCHEMA.md` and addenda 1–8 are unchanged.
- The build was interrupted by a usage limit. On resumption every changed file was re-diffed against v0.4 and found complete, and every suite was then re-run from a clean start (the results below).

### Inputs (sha256 computed by this generator)

- v0.4 dist `78c2110106f2d4f45ae34b9cc2af024eabd353483b32499a06e19a3fa3998838`.
- Merged viewer `monodromy-31-linked-reduction.html` (v0.8.8-fix.5 foliation design; read for meaning only, with grep and line ranges): `b4cee4e30a753eda7c62f72e8043d6d5c9b3f69c3c2e1dd0da9a3f9ab5b8e248`.
- S0 design review (Codex, #539): `012628569a61f1045895f2ac85bebefa2e6d114cbf769066ff2e5200456dd742`.

### What was built

1. **Shell range.**
   - n₁ = 1…13 and B ≥ 1. Only `comb-core.js` `resolve` changed (two bounds and their reasons).
   - The n₁ select runs 1…13, ◀ stops at 1, and the M box aria-label reads 1.
   - The B = 1, 2 audit is in addendum 9 §1. No readout needed new code: Wilson, gearbox, contrast, bracket, divisors, fraction stack, field and exports already handled N ≤ 2 and N = 0 honestly. This was checked by test, below.
2. **The ★.**
   - It is keyed on t₁·s ∈ ℤ (model field `labReal`) and worded "★ lab sum real".
   - The exact-flags card gains the carrier-relative row (identity; imaginary part numerical, with the bound) and the exact lab-frame row.
3. **Carrier foliation (Clifford tab).**
   - The view keys are `cff` (default 0), `cfk` (default 24) and `cfb` (default 0). The exact lattice and labels come from `orbit-core.js` `carrierFoliation` (BigInt); the points come from `comb-numeric.js` `foliationGeometry`.
   - The view draws the family (faint), the selected β (white) and β + π (white, dashed), with a label. Guards: t₁ = 0 draws points and a caption; a collapsed leaf draws nothing and a caption.
   - The readouts are in the Layers menu. The Hopf base is Clifford only, for the reason given in addendum 9 §3.
4. **Version.** The build pins read `viewer: "comb-hopf v0.4.1"`. The README title and the v0.4.1 section are updated. Schema ids are unchanged (addendum 9 §1).

Files added: `build/browser-check-v041.cjs`, `host-core/test-v041.cjs`, `SCHEMA_ADDENDUM_9.md`.

Files changed against v0.4 (byte comparison; PNGs and this report excluded): `build/package.cjs`, `dist/comb-hopf.html`, `dist/MANIFEST.sha256`, `host-core/comb-core.js`, `host-core/comb-numeric.js`, `host-core/orbit-core.js`, `instruments/comb-hopf/panel.js`, `instruments/comb-hopf/README.md`, `instruments/comb-hopf/view-clifford.js`, `instruments/comb-hopf/view-fourier.js`.

### Per-suite results (verbatim summary lines, final run)

```
package exit 0
second build: 21a1d8ca0e78ba0f2305169fc310e3814634f3b47db7da1ccadedcd107919170  dist/comb-hopf.html
test-exact: 21 passed, 0 failed
test-core: 160 passed, 0 failed
    e.g. [(a)] 6 t1=0 t2=-3 N=711156 s=379/144 mine refused (t₁ = 0: ALIGN and SPREAD stops are undef) host 3
UNEXPLAINED differences: 0
contrast-check: 93 pass, 0 fail
test-mirror (T-MA): 14 passed, 0 failed
test-v041: 11 passed, 0 failed
smallest text measured in this run: 13.0000 px
browser-check: 561 passed, 4 failed
browser-check-mirror: 122 passed, 0 failed
browser-check-v041: 66 passed, 0 failed
manifest: 14 of 14 lines OK
```

### The v0.3 and v0.4 suites, run unchanged

- **Test files.** 7 of 7 are byte-identical to v0.4's: `exact-lib/test-exact.cjs`, `host-core/test-core.cjs`, `host-core/parity-sample.cjs`, `build/contrast-check.cjs`, `build/browser-check.cjs`, `host-core/test-mirror.cjs`, `build/browser-check-mirror.cjs`.
  - No v0.3 or v0.4 test asserted the old bounds (n₁ ≥ 3, B ≥ 2): a search of every test file for those bounds and their refusal texts found none. So no test was changed.
  - The widened refusal texts are tested in `test-v041.cjs`.
- **Same output as the v0.4 run, byte for byte:** exact yes, core yes, parity yes, contrast yes, mirror yes.
- **browser-check (v0.3):** 565 assertions ran; the v0.4 run ran 563. The same 4 Layers-inventory assertions fail as in v0.4 (see the v0.4 section for the cause). No assertion changed from PASS to FAIL or back.
  The two extra assertions are conditional v0.3 caption checks, which run only when a caption is truncated. At 1280 px the Fourier caption, with "★ lab sum real" added, is now ellipsized in the default state, so they run and pass:
```
PASS 1280x800 F2 caption is exactly one line (default state, fourier): 1 (ellipsis)
PASS 1280x800 F2 tapping a truncated caption expands it (default, fourier): 2 lines
PASS 1280x800 F2 tapping again collapses it to one line (default, fourier)
```
  Measured timings and frame rates differ between the two runs only in their values; every bound passes.
  Failing lines, verbatim:
```
FAIL 375x812 Fourier Layers menu: Teeth, Walk, Amber polygon, Divisors
FAIL 375x812 Guides none: no circles, no swatches; layer swatches only on pressed layers
FAIL 1280x800 Fourier Layers menu: Teeth, Walk, Amber polygon, Divisors
FAIL 1280x800 Guides none: no circles, no swatches; layer swatches only on pressed layers
```
- **browser-check-mirror (v0.4):** no assertion changed outcome.

### v0.4.1 tests (verbatim)

`node host-core/test-v041.cjs`:

```
PASS shell range: n₁ = 1 and n₁ = 2 resolve to B = 1! = 1 and B = 2! = 2; integer B = 1 resolves; n₁ = 0, n₁ = 14 and B = 0 are refused with the widened reasons ("1–13", "1–6,227,020,800")
PASS shell range: on B = 1 and B = 2 (n₁ = 1, 2 and integer B = 1, 2), every shell position in both N modes (integer φ₃ and φ₃ ∈ ¼ℤ), m = 2..5, five gears, three spins: every exact readout, export, stop set, step, branch, gate, field, divisor report, fraction-stack caption, mirror and foliation record and the numerical model evaluate without an exception and without a NaN; N ≤ 0 is refused by orbit-core and comb-numeric (3480 states, 480 with N = 0, 1800 between shells) 
PASS shell range B = 1, 2: honest labels — N = 1: Wilson "N = 1 is not prime.", shell contrast undefined (N < 2), Wilson gearbox at n₁ = 1, m = 2, φ₃ = 0 (N = 2 = 1! + 1): WILSON_PRIME_RESIDENT; at n₁ = 2, m = 3, φ₃ = 0 (N = 3 = 2! + 1): WILSON_PRIME_RESIDENT; between shells on B = 1 (φ₃ = 1/2, N = 3/2): every shell readout carries the between-shells label; the fraction stack is idle at N = 3/2 and evaluates at N = 2
PASS unchanged states: the 408-state v0.4 preset grid plus 1,600 random states valid in v0.4 (factorial n₁ 3–6, integer B 2–61, both N modes, N = 0 included) give byte-identical exact export, state export, address, readouts, Lift branches, gates, field line, stop set, step record, fraction-stack caption, numerical model, orbit samples and mirror pairs under the v0.4 and v0.4.1 modules (2008 states compared, 62 with N = 0, 0 differences)
PASS previously refused states: every state v0.4 refuses is refused by v0.4.1 with the same reason, except n₁ ∈ {1, 2} and integer B = 1, which are now valid, and the two widened range reasons themselves (11 newly valid, 18 still refused)
PASS ★ (SCHEMA_ADDENDUM_9 §2): keyed on t₁·s ∈ ℤ, the exact ALIGN condition. Review counterexample N = 5, m = 6, t₁ = 1/2, t₂ = 1, s = 1, ρ = 1: s ∈ ℤ but t₁·s = 1/2 ∉ ℤ, so no ★; the lab resultant is −i (|Im W| = 1, numerical); W·e^{−iπ(t₁s+f)} is real (numerical, within the bound)
PASS ★: over the preset grid and the random states, "t₁·s ∈ ℤ" equals the exact ALIGN flag, and whenever it holds the lab-frame |Im W| is within the numerical bound (1000 states with ★)
PASS foliation: for every preset, K ∈ {6, 12, 24, 120} and selected k ∈ {0, 1, 10, 119, 120, 239, −1, 241}, every drawn point of every family curve, of the selected curve and of its companion has arg z₂ = β within 1e-9 and |z₁| = a, |z₂| = b within 1e-9 (inverse projection of the drawn 3D points) (3285420 points, worst 4.00e-15)
PASS foliation: the selected β is reported exactly as (k mod 240)/120·π reduced (k = 10 → "1/12·π", 119 → "119/120·π", 120 → "1·π", −1 → "239/120·π", 241 → "1/120·π"); the companion is β + π exactly ((k + 120) mod 240) and its drawn curve sits at arg z₂ = β + π (1e-9); the family is β = 2πj/K, j = 0..K−1; β = 0 and β = π are flagged as the mirror's fixed longitudes
PASS foliation guards: t₁ = 0 → the carrier is stationary, every family member is one point at the carrier phase θ = π(t₁s + f) with arg z₂ = β; ρ = 0 (n₆ = 0) → collapsed, nothing drawn; teeth on the foliation: odd m → c = 0 only, even m → none, t₂ = 0 → every tooth
PASS foliation is display register only: for the preset grid, branches, gates, exports and readouts do not depend on the foliation dials (they are view keys, excluded from the exact export); the exact export is identical with view "cff=1;cfk=120;cfb=17" and with view ""
test-v041: 11 passed, 0 failed
```

`node build/browser-check-v041.cjs`:

```
PASS 375x812 shell range: the n₁ select offers 1 … 13 (13 options)
PASS 375x812 shell range: selecting n₁ = 2 gives B = 2 (φ₃ clamped into 0 … B + 1 = 3), no refusal
PASS 375x812 shell range: selecting n₁ = 1 gives B = 1 (φ₃ clamped into 0 … B + 1 = 2), no refusal, and ◀ n₁ is disabled at the bottom
PASS 375x812 shell range: integer base B = 1 is accepted (shell readout B = 1 · N = 2)
PASS 375x812 n1_1 fourier: renders without a refusal or error, first screen holds (transport bottom 794 ≤ 812), no visible text below 13 px (smallest 13.000)
PASS 375x812 n1_1 clifford: renders without a refusal or error (transport bottom 830, informative), no visible text below 13 px (smallest 13.000)
PASS 375x812 n1_1 hopf: renders without a refusal or error (transport bottom 830, informative), no visible text below 13 px (smallest 13.000)
PASS 375x812 n1_1 panels: renders without a refusal or error (transport bottom 483, informative), no visible text below 13 px (smallest 13.000)
PASS 375x812 n1_2 fourier: renders without a refusal or error, first screen holds (transport bottom 794 ≤ 812), no visible text below 13 px (smallest 13.000)
PASS 375x812 n1_2 clifford: renders without a refusal or error (transport bottom 794, informative), no visible text below 13 px (smallest 13.000)
PASS 375x812 n1_2 hopf: renders without a refusal or error (transport bottom 794, informative), no visible text below 13 px (smallest 13.000)
PASS 375x812 n1_2 panels: renders without a refusal or error (transport bottom 483, informative), no visible text below 13 px (smallest 13.000)
PASS 375x812 n1_1_continuous fourier: renders without a refusal or error, first screen holds (transport bottom 811 ≤ 812), no visible text below 13 px (smallest 13.000)
PASS 375x812 n1_1_continuous clifford: renders without a refusal or error (transport bottom 811, informative), no visible text below 13 px (smallest 13.000)
PASS 375x812 n1_1_continuous hopf: renders without a refusal or error (transport bottom 811, informative), no visible text below 13 px (smallest 13.000)
PASS 375x812 n1_1_continuous panels: renders without a refusal or error (transport bottom 504, informative), no visible text below 13 px (smallest 13.000)
PASS 375x812 B1_integer fourier: renders without a refusal or error, first screen holds (transport bottom 812 ≤ 812), no visible text below 13 px (smallest 13.000)
PASS 375x812 B1_integer clifford: renders without a refusal or error (transport bottom 812, informative), no visible text below 13 px (smallest 13.000)
PASS 375x812 B1_integer hopf: renders without a refusal or error (transport bottom 812, informative), no visible text below 13 px (smallest 13.000)
PASS 375x812 B1_integer panels: renders without a refusal or error (transport bottom 500, informative), no visible text below 13 px (smallest 13.000)
PASS 375x812 ★ counterexample (N = 5, m = 6, t₁ = 1/2, t₂ = 1, s = 1, ρ = 1): no ★ in the caption (s ∈ ℤ but t₁·s ∉ ℤ), Q-res 1.0e+0; the card says "lab-frame W real (t₁·s ∈ ℤ, exact) no" and gives the carrier-relative Im within the bound
PASS 375x812 ★ default state (t₁·s = 1 ∈ ℤ): "SPREAD … ★ lab sum real" precedes Q-res, and the card says "yes ★"
PASS 375x812 foliation: the "Carrier foliation" toggle is visible in the Clifford Layers menu, not pressed by default; leaf counts 6, 12, 24, 120 offered; readout says off; nothing drawn
PASS 375x812 foliation: every Layers-menu control is at least 40 px high
PASS 375x812 foliation on, β ▶▶ ×3, β ▶, ◀ β, leaves 12: view cff=1, cfb=30, cfk=12; readout "selected β = 1/4·π (exact, β/π = k/120, k = 30) · companion β + π = 5/4·π (dashed)"; 12 family runs, the selected (β/π = 1/4) and companion (5/4) stubs, label "β = 1/4·π"; every drawn point has arg z₂ = β and |z₁|, |z₂| = a, b within 1e-9 (worst 4.44e-16)
PASS 375x812 foliation with the Layers menu open: no visible text below 13 px (smallest 13.000)
PASS 375x812 foliation on an even comb (m = 6): 24 family runs, readout "no tooth lies on the foliation (even comb)"
PASS 375x812 N = 1 via φ₃ = B (n₁ = 4, m = 2, t₁ = t₂ = 1) with the foliation on: 24 + 2 runs drawn
PASS 375x812 foliation guard t₁ = 0: labelled (each carrier orbit is a point), drawn as 24 + 2 points, no curves
PASS 375x812 foliation guard ρ = 0: nothing drawn, labelled "collapsed leaf (ρ = 0): the carrier foliation is not drawn."
PASS 375x812 foliation off: for 8 states the Clifford SVG overlay, caption, canvas pixels (PNG data URL), recorded runs and marks equal the v0.4 page byte for byte
PASS 375x812 no console or page errors in the v0.4.1 checks
PASS 375x812 no horizontal scroll
PASS 1280x800 shell range: the n₁ select offers 1 … 13 (13 options)
PASS 1280x800 shell range: selecting n₁ = 2 gives B = 2 (φ₃ clamped into 0 … B + 1 = 3), no refusal
PASS 1280x800 shell range: selecting n₁ = 1 gives B = 1 (φ₃ clamped into 0 … B + 1 = 2), no refusal, and ◀ n₁ is disabled at the bottom
PASS 1280x800 shell range: integer base B = 1 is accepted (shell readout B = 1 · N = 2)
PASS 1280x800 n1_1 fourier: renders without a refusal or error, first screen holds (transport bottom 952 ≤ 800), no visible text below 13 px (smallest 13.000)
PASS 1280x800 n1_1 clifford: renders without a refusal or error (transport bottom 977, informative), no visible text below 13 px (smallest 13.000)
PASS 1280x800 n1_1 hopf: renders without a refusal or error (transport bottom 977, informative), no visible text below 13 px (smallest 13.000)
PASS 1280x800 n1_1 panels: renders without a refusal or error (transport bottom 439, informative), no visible text below 13 px (smallest 13.000)
PASS 1280x800 n1_2 fourier: renders without a refusal or error, first screen holds (transport bottom 952 ≤ 800), no visible text below 13 px (smallest 13.000)
PASS 1280x800 n1_2 clifford: renders without a refusal or error (transport bottom 952, informative), no visible text below 13 px (smallest 13.000)
PASS 1280x800 n1_2 hopf: renders without a refusal or error (transport bottom 952, informative), no visible text below 13 px (smallest 13.000)
PASS 1280x800 n1_2 panels: renders without a refusal or error (transport bottom 439, informative), no visible text below 13 px (smallest 13.000)
PASS 1280x800 n1_1_continuous fourier: renders without a refusal or error, first screen holds (transport bottom 977 ≤ 800), no visible text below 13 px (smallest 13.000)
PASS 1280x800 n1_1_continuous clifford: renders without a refusal or error (transport bottom 977, informative), no visible text below 13 px (smallest 13.000)
PASS 1280x800 n1_1_continuous hopf: renders without a refusal or error (transport bottom 977, informative), no visible text below 13 px (smallest 13.000)
PASS 1280x800 n1_1_continuous panels: renders without a refusal or error (transport bottom 468, informative), no visible text below 13 px (smallest 13.000)
PASS 1280x800 B1_integer fourier: renders without a refusal or error, first screen holds (transport bottom 952 ≤ 800), no visible text below 13 px (smallest 13.000)
PASS 1280x800 B1_integer clifford: renders without a refusal or error (transport bottom 952, informative), no visible text below 13 px (smallest 13.000)
PASS 1280x800 B1_integer hopf: renders without a refusal or error (transport bottom 952, informative), no visible text below 13 px (smallest 13.000)
PASS 1280x800 B1_integer panels: renders without a refusal or error (transport bottom 439, informative), no visible text below 13 px (smallest 13.000)
PASS 1280x800 ★ counterexample (N = 5, m = 6, t₁ = 1/2, t₂ = 1, s = 1, ρ = 1): no ★ in the caption (s ∈ ℤ but t₁·s ∉ ℤ), Q-res 1.0e+0; the card says "lab-frame W real (t₁·s ∈ ℤ, exact) no" and gives the carrier-relative Im within the bound
PASS 1280x800 ★ default state (t₁·s = 1 ∈ ℤ): "SPREAD … ★ lab sum real" precedes Q-res, and the card says "yes ★"
PASS 1280x800 foliation: the "Carrier foliation" toggle is visible in the Clifford Layers menu, not pressed by default; leaf counts 6, 12, 24, 120 offered; readout says off; nothing drawn
PASS 1280x800 foliation: every Layers-menu control is at least 40 px high
PASS 1280x800 foliation on, β ▶▶ ×3, β ▶, ◀ β, leaves 12: view cff=1, cfb=30, cfk=12; readout "selected β = 1/4·π (exact, β/π = k/120, k = 30) · companion β + π = 5/4·π (dashed)"; 12 family runs, the selected (β/π = 1/4) and companion (5/4) stubs, label "β = 1/4·π"; every drawn point has arg z₂ = β and |z₁|, |z₂| = a, b within 1e-9 (worst 4.44e-16)
PASS 1280x800 foliation with the Layers menu open: no visible text below 13 px (smallest 13.000)
PASS 1280x800 foliation on an even comb (m = 6): 24 family runs, readout "no tooth lies on the foliation (even comb)"
PASS 1280x800 N = 1 via φ₃ = B (n₁ = 4, m = 2, t₁ = t₂ = 1) with the foliation on: 24 + 2 runs drawn
PASS 1280x800 foliation guard t₁ = 0: labelled (each carrier orbit is a point), drawn as 24 + 2 points, no curves
PASS 1280x800 foliation guard ρ = 0: nothing drawn, labelled "collapsed leaf (ρ = 0): the carrier foliation is not drawn."
PASS 1280x800 foliation off: for 8 states the Clifford SVG overlay, caption, canvas pixels (PNG data URL), recorded runs and marks equal the v0.4 page byte for byte
PASS 1280x800 no console or page errors in the v0.4.1 checks
PASS 1280x800 no horizontal scroll
browser-check-v041: 66 passed, 0 failed
```

### Screenshots (written by build/browser-check-v041.cjs; each was looked at)

- `shot_v041_1280x800_B1_integer_clifford.png`
- `shot_v041_1280x800_B1_integer_fourier.png`
- `shot_v041_1280x800_N1_foliation.png`
- `shot_v041_1280x800_foliation_even.png`
- `shot_v041_1280x800_foliation_odd.png`
- `shot_v041_1280x800_foliation_odd_layers.png`
- `shot_v041_1280x800_n1_1_clifford.png`
- `shot_v041_1280x800_n1_1_continuous_clifford.png`
- `shot_v041_1280x800_n1_1_continuous_fourier.png`
- `shot_v041_1280x800_n1_1_fourier.png`
- `shot_v041_1280x800_n1_2_clifford.png`
- `shot_v041_1280x800_n1_2_fourier.png`
- `shot_v041_1280x800_star_counterexample.png`
- `shot_v041_375x812_B1_integer_clifford.png`
- `shot_v041_375x812_B1_integer_fourier.png`
- `shot_v041_375x812_N1_foliation.png`
- `shot_v041_375x812_foliation_even.png`
- `shot_v041_375x812_foliation_odd.png`
- `shot_v041_375x812_foliation_odd_layers.png`
- `shot_v041_375x812_n1_1_clifford.png`
- `shot_v041_375x812_n1_1_continuous_clifford.png`
- `shot_v041_375x812_n1_1_continuous_fourier.png`
- `shot_v041_375x812_n1_1_fourier.png`
- `shot_v041_375x812_n1_2_clifford.png`
- `shot_v041_375x812_n1_2_fourier.png`
- `shot_v041_375x812_star_counterexample.png`

Coverage of the requested shots:
- N = 1 via φ₃ = B with m = 2, t₁ = t₂ = 1 and the foliation on: `*_N1_foliation`;
- the n₁ = 2 and n₁ = 1 shells: `*_n1_2_*`, `*_n1_1_*` and `*_n1_1_continuous_*`;
- integer B = 1: `*_B1_integer_*`;
- the ★ counterexample, now without ★: `*_star_counterexample`;
- an odd and an even comb with the foliation and a selected β ≠ 0: `*_foliation_odd` (β = 1/4·π, K = 12) and `*_foliation_even` (β = 1/12·π, K = 24), plus the Layers menu open in `*_foliation_odd_layers`.

### Not done, observations, for decision

1. **Pre-existing, not changed:** at N = 0, on any shell, the exact readout `wilsonN` and the exact export carry "N = 1 is not prime.".
   - Correcting it would change the exact export of states that were already valid, which the brief forbids.
   - It is recorded in addendum 9 §1 for a decision.
2. **Shell change clamps φ₃** (unchanged rule): from the default φ₃ = 23, choosing n₁ = 1 or 2 lands on φ₃ = B + 1, that is N = 0, the labelled empty state.
3. **Hopf base:** Clifford only; the reason is in addendum 9 §3.
4. **Not tested:** a real phone (Playwright emulation only), and the speed scripts. The v0.3 speed bounds in browser-check pass.

### Pins

- `dist/comb-hopf.html` sha256 `21a1d8ca0e78ba0f2305169fc310e3814634f3b47db7da1ccadedcd107919170` (two consecutive builds give the same hash)
- `dist/MANIFEST.sha256` sha256 `92477b998335bb746325357ce1646a0823a5aa598a6ea6bf56cc39c7e5f377a7`
- `SHA256SUMS.txt` (LF) lists every file of this folder except itself.

Credits:
- saphir: the requests;
- the merged viewer's v0.8.8-fix.5: the foliation design;
- Claude Fable 5.1: the feature note;
- Codex: review #539;
- the earlier builders: as recorded above;
- Claude Opus 5.5: v0.4.1.

## v0.4.2 (2026-10-19): the N = 0 Wilson wording and the shell-switch clamp

Builder: subagent (Claude Opus 5.5). Additive successor of v0.4.1 in `FOURIER_VIEWER_PROTOTYPE_v0_4_2_20261019`, approved by saphir on 2026-10-19 ("fix both in one small successor, v0.4.2. I like your leans.").
- The v0.4.1 folder was copied after its `SHA256SUMS.txt` (`685014e630eb11bb24a5672ee42666fe7a1796abcb7772cabf0c777895785921`) verified 114 of 114 files; v0.4 (`70017399…0d90`, 85 of 85) and v0.3 (`dist/MANIFEST.sha256`, 14 of 14) verified too.
- v0.4.1, v0.4 and v0.3 were not edited. Nothing outside this folder, the scratchpad and `s6_atom/_scratch/v042_ref041/` (a reference copy, below) was written. No git command was run and nothing was downloaded.
- Both changes are specified in `SCHEMA_ADDENDUM_10.md` (new). The defects were recorded by the v0.4.1 build report (addendum 9 §1; "v0.4.1", items 1 and 2 of "Not done, observations, for decision").

### Inputs (sha256 computed by this generator)

- v0.4.1 dist `21a1d8ca0e78ba0f2305169fc310e3814634f3b47db7da1ccadedcd107919170`.
- v0.4.1 `SHA256SUMS.txt` `685014e630eb11bb24a5672ee42666fe7a1796abcb7772cabf0c777895785921`; v0.4.1 `dist/MANIFEST.sha256` `92477b998335bb746325357ce1646a0823a5aa598a6ea6bf56cc39c7e5f377a7`.

### What was built

1. **Fix 1, the N = 0 Wilson wording.** `host-core/comb-core.js` `wilsonN` gains one line, the N = 0 branch: label "N = 0: no comb, so the Wilson test does not apply.", with `checked: false`, `prime: null`, `residue: null` (the module's existing "not evaluated" pattern; these three are internal and not exported).
   - That one function feeds the exact field `exact.wilsonN`, the Wilson card line and the stats line "Wilson shell-N: …". Nothing else carries the label: the PNG caption, drawing, CSV, state and Lift exports never did.
   - N = 1 keeps "N = 1 is not prime.".
2. **Fix 2, the shell-switch clamp.** `instruments/comb-hopf/panel.js` `clampPhi`: when a shell switch (n₁ select, ◀ n₁ ▶, shell mode, M box) leaves φ₃ above the new B + 1, φ₃ := B (N = 1). It was B + 1 (N = 0).
   - It is one exact comparison used in both N modes, so continuous mode follows the same rule. There is no separate continuous-mode clamp.
   - N = 0 is still chosen directly with φ₃ = B + 1.
3. **Version.** The build pins read `viewer: "comb-hopf v0.4.2"` (`build/package.cjs`). The README title, the README v0.4.2 section and the dial-ledger rows were added. Schema ids are unchanged.

Files added: `SCHEMA_ADDENDUM_10.md`, `host-core/test-v042.cjs`, `build/browser-check-v042.cjs`, and 8 `shot_v042_*.png`.

Files changed against v0.4.1 (byte comparison; this report excluded): `build/package.cjs`, `dist/comb-hopf.html`, `dist/MANIFEST.sha256`, `host-core/comb-core.js` (1 line added), `instruments/comb-hopf/panel.js` (lines 45 and 48: the comment and the clamp value), `instruments/comb-hopf/README.md`.
- Running the old browser suites rewrote their screenshots and `export_*.png` in this folder. Every one came out byte-identical to the v0.4.1 copy.

### Per-suite results (verbatim summary lines, final run)

Exit codes: package1 exit 0; package2 exit 0; test-exact exit 0; test-core exit 0; parity exit 0; contrast exit 0; test-mirror exit 0; test-v041 exit 1; test-v042 exit 0; browser-check exit 1; browser-check-mirror exit 0; browser-check-v041 exit 0; browser-check-v042 exit 0; manifest exit 0.

```
second build: 2b59d23c2e1b6bd96856d695f4cb45eb5f653927ee433b2079c12975452aad14  dist/comb-hopf.html (first build 2b59d23c2e1b6bd96856d695f4cb45eb5f653927ee433b2079c12975452aad14, identical)
test-exact: 21 passed, 0 failed
test-core: 160 passed, 0 failed
parity sample: 2000 states; exact phase/k_c differences: 0; stepper compared 2000, identical value 1587
  413 x (a) R20.2/4e: refusal where the host snaps to an integer
    e.g. [(a)] 3 t1=-2 t2=0 N=7 s=-869/2 mine refused (t₂ = 0: SPREAD stops are undefined, so s) host -434
    e.g. [(a)] 7 t1=-3 t2=0 N=12 s=-519/20 mine refused (t₂ = 0: SPREAD stops are undefined, so s) host -519/20
    e.g. [(a)] 12 t1=0 t2=2 N=329 s=894/25 mine refused (t₁ = 0: ALIGN and SPREAD stops are undef) host 35
    e.g. [(a)] 6 t1=0 t2=-3 N=711156 s=379/144 mine refused (t₁ = 0: ALIGN and SPREAD stops are undef) host 3
UNEXPLAINED differences: 0
contrast-check: 93 pass, 0 fail
test-mirror (T-MA): 14 passed, 0 failed
test-v041: 10 passed, 1 failed
test-v042: 6 passed, 0 failed
smallest text measured in this run: 13.0000 px
browser-check: 561 passed, 4 failed
browser-check-mirror: 122 passed, 0 failed
browser-check-v041: 66 passed, 0 failed
browser-check-v042: 46 passed, 0 failed
manifest: 14 of 14 lines OK
```

Affirmative and refusal counts:
- **Parity sample.** The 413 "(a)" lines are declared refusals: R20.2/4e, refusal where the host snaps to an integer. They are counted apart from the identical values (1587 of 2000), and no difference is unexplained.
- **The other suites** report assertions only. Their refusal-path checks (for example the range refusals in test-v041) are counted inside the PASS totals.

### The v0.3, v0.4 and v0.4.1 suites, run unchanged

- **Test files.** None was edited: `exact-lib/test-exact.cjs`, `host-core/test-core.cjs`, `host-core/parity-sample.cjs`, `build/contrast-check.cjs`, `build/browser-check.cjs`, `host-core/test-mirror.cjs`, `build/browser-check-mirror.cjs`, `host-core/test-v041.cjs` and `build/browser-check-v041.cjs` are byte-identical to v0.4.1's (the byte comparison above lists none of them).
- **test-exact, test-core, parity, contrast-check, test-mirror.** The same summary lines as the v0.4.1 run.
- **test-v041: 10 passed, 1 failed.** The failure is the expected consequence of Fix 1, not an unexplained one:
```
FAIL unchanged states: the 408-state v0.4 preset grid plus 1,600 random states valid in v0.4 (factorial n₁ 3–6, integer B 2–61, both N modes, N = 0 included) give byte-identical exact export, state export, address, readouts, Lift branches, gates, field line, stop set, step record, fraction-stack caption, numerical model, orbit samples and mirror pairs under the v0.4 and v0.4.1 modules (2008 states compared, 62 with N = 0, 62 differences)
```
  - The 62 differences are exactly the 62 N = 0 states of the 2,008-state set: 62 states with N = 0 and 62 differences.
  - That assertion compares v0.4 with the current modules and allowed no difference at N = 0. Fix 1 changes the N = 0 Wilson label by design.
  - The adapted assertion is in `test-v042.cjs` ("adapted from test-v041 'unchanged states'"). Against the v0.4 modules it shows 0 differences at the 1,946 N ≠ 0 states and, at each of the 62 N = 0 states, only the Wilson fields.
  - Every other test-v041 assertion passes, including "N = 1: Wilson 'N = 1 is not prime.'".
- **browser-check (v0.3): 561 passed, 4 failed**, the same 4 Layers-inventory failures as v0.4 and v0.4.1. Failing lines, verbatim:
```
FAIL 375x812 Fourier Layers menu: Teeth, Walk, Amber polygon, Divisors
FAIL 375x812 Guides none: no circles, no swatches; layer swatches only on pressed layers
FAIL 1280x800 Fourier Layers menu: Teeth, Walk, Amber polygon, Divisors
FAIL 1280x800 Guides none: no circles, no swatches; layer swatches only on pressed layers
```
  - **Pass/fail comparison.** v0.4.1's `browser-check.cjs` was run against the v0.4.1 dist from a byte copy in `s6_atom/_scratch/v042_ref041/` (`build/browser-check.cjs`, `dist/comb-hopf.html` sha256 `21a1d8ca…9170`, `host-core/`, `exact-lib/`), so nothing was written into the v0.4.1 folder. It gave "browser-check: 561 passed, 4 failed".
  - The two logs' PASS/FAIL lines were compared as sorted lists, with every number replaced by `#` (timings, frame rates and measured sizes vary). The lists are identical: 0 differing lines (565 assertions each). The PASS/FAIL sequence in run order is also identical, so no assertion changed from PASS to FAIL or back.
- **browser-check-mirror (122/0) and browser-check-v041 (66/0).** No failures.
  - browser-check-v041 selects n₁ = 2 and then n₁ = 1 in sequence and accepts any N in the shell readout, so its assertions hold under both clamp rules.

### v0.4.2 tests (verbatim)

`node host-core/test-v042.cjs`:

```
PASS Fix 1 wording: at N = 0 the shell-N Wilson record is {checked: false, prime: null, residue: null, label: "N = 0: no comb, so the Wilson test does not apply."} on every shell (factorial n₁ = 1…13, integer B ∈ {1, 2, 3, 24, 61, 6227020800}) in both N modes; the exact export field exact.wilsonN carries the same label; N = 1 keeps "N = 1 is not prime.", N = 2 and N = 13 are evaluated as before (38 N = 0 states, 0 wrong) 
PASS Fix 1 scope (source): host-core/comb-core.js differs from v0.4.1 by exactly one added line (the N = 0 branch of wilsonN); every other host-core module and exact-lib file is byte-identical to v0.4.1; instruments/comb-hopf/panel.js differs only in clampPhi (lines 45 and 48); no other instrument file differs (19 files byte-identical; panel.js lines differing: 45, 48; new host-core files: test-v042.cjs)
PASS Fix 1 exactness vs v0.4.1: the 408-state preset grid plus 1,600 random states of test-v041 — for every N ≠ 0 state the exact export (also with the order-m witness p = 5), state export, address, readouts, Lift branches, gates, field line, stop set, both step records, fraction-stack caption, numerical model, orbit samples, mirror pairs, mirror parity, foliation record, cyclotomic record and divisor report are byte-identical; for every N = 0 state exactly the Wilson fields differ: exportExact.exact.wilsonN, exportExactWitness5.exact.wilsonN, readouts.wilsonN.checked, readouts.wilsonN.label, readouts.wilsonN.prime, readouts.wilsonN.residue (2008 states compared, 1946 with N ≠ 0: 0 differences; 62 with N = 0: 0 outside the Wilson fields; differing fields per N = 0 state: 6 fields in 62 states; per field: exportExact.exact.wilsonN ×62, exportExactWitness5.exact.wilsonN ×62, readouts.wilsonN.checked ×62, readouts.wilsonN.label ×62, readouts.wilsonN.prime ×62, readouts.wilsonN.residue ×62)
PASS Fix 1 exactness vs v0.4.1 on B = 1, 2 (the test-v041 set: n₁ = 1, 2 and integer B = 1, 2, every shell position in both N modes): N ≠ 0 byte-identical; N = 0 differs exactly in the Wilson fields (3480 states compared, 3000 with N ≠ 0: 0 differences; 480 with N = 0: 0 outside the Wilson fields; differing fields per N = 0 state: 6 fields in 480 states; per field: exportExact.exact.wilsonN ×480, exportExactWitness5.exact.wilsonN ×480, readouts.wilsonN.checked ×480, readouts.wilsonN.label ×480, readouts.wilsonN.prime ×480, readouts.wilsonN.residue ×480)
PASS adapted from test-v041 "unchanged states" (v0.4 modules): the same 2,008 states — N ≠ 0 byte-identical to v0.4; N = 0 differs exactly in the Wilson fields (the v0.4.1 assertion of 0 differences no longer holds at N = 0 because of Fix 1, by design) (2008 states compared, 1946 with N ≠ 0: 0 differences; 62 with N = 0: 0 outside the Wilson fields; differing fields per N = 0 state: 6 fields in 62 states; per field: exportExact.exact.wilsonN ×62, exportExactWitness5.exact.wilsonN ×62, readouts.wilsonN.checked ×62, readouts.wilsonN.label ×62, readouts.wilsonN.prime ×62, readouts.wilsonN.residue ×62)
PASS address/state format unchanged: ADDRESS_ID, ADDRESS_ID_V01, STATE_SCHEMA, EXACT_SCHEMA, DIAL_KEYS, ADDRESS_KEYS, DEFAULTS and N_MODES equal v0.4.1; every address of the 2,008 + 3,480 states round-trips and equals the v0.4.1 address (5488 addresses, 0 differences)
test-v042: 6 passed, 0 failed
```

The counts asked for:
- **N = 0 states.** The 408 + 1,600 set has 2,008 states, 62 of them with N = 0 and 1,946 with N ≠ 0. The B = 1, 2 set has 3,480 states, 480 with N = 0 and 3,000 with N ≠ 0.
- **Differing fields per N = 0 state: 6 named leaves, the same 6 in every one.**
  - One exact-export field, `exact.wilsonN`. It is counted twice, because the test makes the exact export both with and without the order-m witness: `exportExact.exact.wilsonN` and `exportExactWitness5.exact.wilsonN`.
  - The four leaves of the internal readout record: `readouts.wilsonN.label`, `.checked`, `.prime` and `.residue`.
- **On the page,** the Wilson card line and the stats line also change (browser-check-v042).

`node build/browser-check-v042.cjs`:

```
PASS 375x812 Fix 2: from the default state (n₁ = 4, φ₃ = 23, N = 2), picking n₁ = 1 in the select gives B = 1, φ₃ = B = 1, N = 1 (shell readout "B = n₁! = 1 · N = 1"), no refusal
PASS 375x812 Fix 2: n₁ = 1 landing on N = 1 shows the Wilson card "N = 1 is not prime."
INFO 375x812 v0.4.1 page, same transition: φ₃ = 2, shell readout "B = n₁! = 1 · N = 0 (no shell)"
PASS 375x812 Fix 2 control: on the v0.4.1 page the same transition gives φ₃ = B + 1 = 2 (N = 0); the two states differ in φ₃ only
PASS 375x812 Fix 2: from the default state in continuous N mode (N∈ℚ) (n₁ = 4, φ₃ = 23, N = 2), picking n₁ = 1 in the select gives B = 1, φ₃ = B = 1, N = 1 (shell readout "B = n₁! = 1 · N = 1"), no refusal
INFO 375x812 v0.4.1 page, same transition: φ₃ = 2, shell readout "B = n₁! = 1 · N = 0 (no shell)"
PASS 375x812 Fix 2 control: on the v0.4.1 page the same transition gives φ₃ = B + 1 = 2 (N = 0); the two states differ in φ₃ only
PASS 375x812 Fix 2: from the default state (n₁ = 4, φ₃ = 23, N = 2), picking n₁ = 2 in the select gives B = 2, φ₃ = B = 2, N = 1 (shell readout "B = n₁! = 2 · N = 1"), no refusal
PASS 375x812 Fix 2: n₁ = 2 landing on N = 1 shows the Wilson card "N = 1 is not prime."
INFO 375x812 v0.4.1 page, same transition: φ₃ = 3, shell readout "B = n₁! = 2 · N = 0 (no shell)"
PASS 375x812 Fix 2 control: on the v0.4.1 page the same transition gives φ₃ = B + 1 = 3 (N = 0); the two states differ in φ₃ only
PASS 375x812 Fix 2: from the default state in continuous N mode (N∈ℚ) (n₁ = 4, φ₃ = 23, N = 2), picking n₁ = 2 in the select gives B = 2, φ₃ = B = 2, N = 1 (shell readout "B = n₁! = 2 · N = 1"), no refusal
INFO 375x812 v0.4.1 page, same transition: φ₃ = 3, shell readout "B = n₁! = 2 · N = 0 (no shell)"
PASS 375x812 Fix 2 control: on the v0.4.1 page the same transition gives φ₃ = B + 1 = 3 (N = 0); the two states differ in φ₃ only
PASS 375x812 Fix 2 continuous mode: φ₃ = 47/2 (N = 3/2), picking n₁ = 2 gives φ₃ = 2, N = 1 (exact comparison 47/2 > B + 1 = 3)
PASS 375x812 Fix 2 integer base: from the default, integer mode (B = 24, φ₃ = 23 kept, N = 2), then M box 1 + Enter gives B = 1, φ₃ = 1, N = 1 ("B = 1 · N = 1")
INFO 375x812 v0.4.1 page, same transition: φ₃ = 2, shell readout "B = 1 · N = 0 (no shell)"
PASS 375x812 Fix 2 rule boundary (as specified): default → n₁ = 2 (φ₃ = 2, N = 1) → n₁ = 1: φ₃ = 2 is inside 0 … B + 1 = 2, so no clamp fires and the state is N = 0 ("B = n₁! = 1 · N = 0 (no  hell)"); recorded for decision
PASS 375x812 N = 0 still reachable: after n₁ = 1 (φ₃ = 1), typing φ₃ = 2 = B + 1 in the φ₃ box gives N = 0 ("B = n₁! = 1 · N = 0 (no shell)"), no refusal; Wilson card "N = 0: no comb, so the Wilson test does not apply."
PASS 375x812 N = 0 still reachable: from n₁ = 1, φ₃ = 1 (N = 1), ◀ (N − 1) gives φ₃ = 2, N = 0
PASS 375x812 N = 0 still reachable: on the default shell the φ₃ slider at its maximum gives φ₃ = 25 = B + 1, N = 0
PASS 375x812 Fix 2 scope: 627 transitions (19 start states × 33 actions: n₁ = 1…13, n₁ ◀ ▶, shell mode both ways, M box B ∈ {1, 2, 3, 5, 24, 100, 6227020800}, φ₃ ◀ ▶, start, g = 0, N mode, m ◀ ▶, t₁ ▶, s ▶) on the v0.4.2 and v0.4.1 pages: 513 give the same state; 114 differ, every one a shell switch with the old φ₃ above the new B + 1, where v0.4.1 gives φ₃ = B + 1 and v0.4.2 gives φ₃ = B, nothing else differing; 0 others
PASS 375x812 Fix 1 page outputs, fourier tab: 12 states (7 with N ≠ 0, 5 with N = 0) on the v0.4.2 and v0.4.1 pages — cards text, drawing (SVG stage), shell readout, stats, exact JSON, state JSON, CSV, Lift JSON and the PNG export (sha256) are byte-identical for N ≠ 0; for N = 0 they are identical except that the one occurrence of "N = 1 is not prime." in the Wilson card, the stats line "Wilson shell-N: …" and the exact field exact.wilsonN reads "N = 0: no comb, so the Wilson test does not apply."
PASS 375x812 Fix 1 page outputs, clifford tab: 12 states (7 with N ≠ 0, 5 with N = 0) on the v0.4.2 and v0.4.1 pages — cards text, drawing (SVG stage), shell readout, stats, exact JSON, state JSON, CSV, Lift JSON and the PNG export (sha256) are byte-identical for N ≠ 0; for N = 0 they are identical except that the one occurrence of "N = 1 is not prime." in the Wilson card, the stats line "Wilson shell-N: …" and the exact field exact.wilsonN reads "N = 0: no comb, so the Wilson test does not apply."
PASS 375x812 Fix 1 page outputs, panels tab: 12 states (7 with N ≠ 0, 5 with N = 0) on the v0.4.2 and v0.4.1 pages — cards text, drawing (SVG stage), shell readout, stats, exact JSON, state JSON, CSV, Lift JSON and the PNG export (sha256; the Panels tab refuses the PNG on both pages) are byte-identical for N ≠ 0; for N = 0 they are identical except that the one occurrence of "N = 1 is not prime." in the Wilson card, the stats line "Wilson shell-N: …" and the exact field exact.wilsonN reads "N = 0: no comb, so the Wilson test does not apply."
PASS 375x812 N = 0 (default shell, φ₃ = 25): the Wilson card reads "N = 0: no comb, so the Wilson test does not apply." and the shell readout "B = n₁! = 24 · N = 0 (no shell)"
PASS 375x812 no console or page errors in the v0.4.2 checks (v0.4.2 page)
INFO 375x812 v0.4.1 page console/page errors: 0
PASS 375x812 no horizontal scroll
PASS 1280x800 Fix 2: from the default state (n₁ = 4, φ₃ = 23, N = 2), picking n₁ = 1 in the select gives B = 1, φ₃ = B = 1, N = 1 (shell readout "B = n₁! = 1 · N = 1"), no refusal
PASS 1280x800 Fix 2: n₁ = 1 landing on N = 1 shows the Wilson card "N = 1 is not prime."
INFO 1280x800 v0.4.1 page, same transition: φ₃ = 2, shell readout "B = n₁! = 1 · N = 0 (no shell)"
PASS 1280x800 Fix 2 control: on the v0.4.1 page the same transition gives φ₃ = B + 1 = 2 (N = 0); the two states differ in φ₃ only
PASS 1280x800 Fix 2: from the default state in continuous N mode (N∈ℚ) (n₁ = 4, φ₃ = 23, N = 2), picking n₁ = 1 in the select gives B = 1, φ₃ = B = 1, N = 1 (shell readout "B = n₁! = 1 · N = 1"), no refusal
INFO 1280x800 v0.4.1 page, same transition: φ₃ = 2, shell readout "B = n₁! = 1 · N = 0 (no shell)"
PASS 1280x800 Fix 2 control: on the v0.4.1 page the same transition gives φ₃ = B + 1 = 2 (N = 0); the two states differ in φ₃ only
PASS 1280x800 Fix 2: from the default state (n₁ = 4, φ₃ = 23, N = 2), picking n₁ = 2 in the select gives B = 2, φ₃ = B = 2, N = 1 (shell readout "B = n₁! = 2 · N = 1"), no refusal
PASS 1280x800 Fix 2: n₁ = 2 landing on N = 1 shows the Wilson card "N = 1 is not prime."
INFO 1280x800 v0.4.1 page, same transition: φ₃ = 3, shell readout "B = n₁! = 2 · N = 0 (no shell)"
PASS 1280x800 Fix 2 control: on the v0.4.1 page the same transition gives φ₃ = B + 1 = 3 (N = 0); the two states differ in φ₃ only
PASS 1280x800 Fix 2: from the default state in continuous N mode (N∈ℚ) (n₁ = 4, φ₃ = 23, N = 2), picking n₁ = 2 in the select gives B = 2, φ₃ = B = 2, N = 1 (shell readout "B = n₁! = 2 · N = 1"), no refusal
INFO 1280x800 v0.4.1 page, same transition: φ₃ = 3, shell readout "B = n₁! = 2 · N = 0 (no shell)"
PASS 1280x800 Fix 2 control: on the v0.4.1 page the same transition gives φ₃ = B + 1 = 3 (N = 0); the two states differ in φ₃ only
PASS 1280x800 Fix 2 continuous mode: φ₃ = 47/2 (N = 3/2), picking n₁ = 2 gives φ₃ = 2, N = 1 (exact comparison 47/2 > B + 1 = 3)
PASS 1280x800 Fix 2 integer base: from the default, integer mode (B = 24, φ₃ = 23 kept, N = 2), then M box 1 + Enter gives B = 1, φ₃ = 1, N = 1 ("B = 1 · N = 1")
INFO 1280x800 v0.4.1 page, same transition: φ₃ = 2, shell readout "B = 1 · N = 0 (no shell)"
PASS 1280x800 Fix 2 rule boundary (as specified): default → n₁ = 2 (φ₃ = 2, N = 1) → n₁ = 1: φ₃ = 2 is inside 0 … B + 1 = 2, so no clamp fires and the state is N = 0 ("B = n₁! = 1 · N = 0 (no  hell)"); recorded for decision
PASS 1280x800 N = 0 still reachable: after n₁ = 1 (φ₃ = 1), typing φ₃ = 2 = B + 1 in the φ₃ box gives N = 0 ("B = n₁! = 1 · N = 0 (no shell)"), no refusal; Wilson card "N = 0: no comb, so the Wilson test does not apply."
PASS 1280x800 N = 0 still reachable: from n₁ = 1, φ₃ = 1 (N = 1), ◀ (N − 1) gives φ₃ = 2, N = 0
PASS 1280x800 N = 0 still reachable: on the default shell the φ₃ slider at its maximum gives φ₃ = 25 = B + 1, N = 0
PASS 1280x800 Fix 2 scope: 627 transitions (19 start states × 33 actions: n₁ = 1…13, n₁ ◀ ▶, shell mode both ways, M box B ∈ {1, 2, 3, 5, 24, 100, 6227020800}, φ₃ ◀ ▶, start, g = 0, N mode, m ◀ ▶, t₁ ▶, s ▶) on the v0.4.2 and v0.4.1 pages: 513 give the same state; 114 differ, every one a shell switch with the old φ₃ above the new B + 1, where v0.4.1 gives φ₃ = B + 1 and v0.4.2 gives φ₃ = B, nothing else differing; 0 others
PASS 1280x800 Fix 1 page outputs, fourier tab: 12 states (7 with N ≠ 0, 5 with N = 0) on the v0.4.2 and v0.4.1 pages — cards text, drawing (SVG stage), shell readout, stats, exact JSON, state JSON, CSV, Lift JSON and the PNG export (sha256) are byte-identical for N ≠ 0; for N = 0 they are identical except that the one occurrence of "N = 1 is not prime." in the Wilson card, the stats line "Wilson shell-N: …" and the exact field exact.wilsonN reads "N = 0: no comb, so the Wilson test does not apply."
PASS 1280x800 Fix 1 page outputs, clifford tab: 12 states (7 with N ≠ 0, 5 with N = 0) on the v0.4.2 and v0.4.1 pages — cards text, drawing (SVG stage), shell readout, stats, exact JSON, state JSON, CSV, Lift JSON and the PNG export (sha256) are byte-identical for N ≠ 0; for N = 0 they are identical except that the one occurrence of "N = 1 is not prime." in the Wilson card, the stats line "Wilson shell-N: …" and the exact field exact.wilsonN reads "N = 0: no comb, so the Wilson test does not apply."
PASS 1280x800 Fix 1 page outputs, panels tab: 12 states (7 with N ≠ 0, 5 with N = 0) on the v0.4.2 and v0.4.1 pages — cards text, drawing (SVG stage), shell readout, stats, exact JSON, state JSON, CSV, Lift JSON and the PNG export (sha256; the Panels tab refuses the PNG on both pages) are byte-identical for N ≠ 0; for N = 0 they are identical except that the one occurrence of "N = 1 is not prime." in the Wilson card, the stats line "Wilson shell-N: …" and the exact field exact.wilsonN reads "N = 0: no comb, so the Wilson test does not apply."
PASS 1280x800 N = 0 (default shell, φ₃ = 25): the Wilson card reads "N = 0: no comb, so the Wilson test does not apply." and the shell readout "B = n₁! = 24 · N = 0 (no shell)"
PASS 1280x800 no console or page errors in the v0.4.2 checks (v0.4.2 page)
INFO 1280x800 v0.4.1 page console/page errors: 0
PASS 1280x800 no horizontal scroll
browser-check-v042: 46 passed, 0 failed
```

### Screenshots (written by build/browser-check-v042.cjs; each was looked at)

- `shot_v042_1280x800_B1_integer_from_default.png`
- `shot_v042_1280x800_N0_wilson.png`
- `shot_v042_1280x800_n1_1_from_default.png`
- `shot_v042_1280x800_n1_2_from_default.png`
- `shot_v042_375x812_B1_integer_from_default.png`
- `shot_v042_375x812_N0_wilson.png`
- `shot_v042_375x812_n1_1_from_default.png`
- `shot_v042_375x812_n1_2_from_default.png`

What each pair shows (375×812 and 1280×800):
- `*_N0_wilson`: the default shell at φ₃ = 25 (N = 0), with the Wilson card scrolled into view. It reads "N = 0: no comb, so the Wilson test does not apply."; the gearbox reads "UNDEFINED (N = 0)", as before.
- `*_n1_1_from_default` and `*_n1_2_from_default`: n₁ = 1 and n₁ = 2 picked in the select from the default state. The shell readout reads "B = n₁! = 1 · N = 1" and "B = n₁! = 2 · N = 1", with φ₃ = 1 and φ₃ = 2 on the chip.
- `*_B1_integer_from_default`: from the default, integer mode, then M box 1 + Enter. The readout reads "B = 1 · N = 1", with φ₃ = 1 on the chip.
- Nothing is clipped at either width.

### Not done, observations, for decision

1. **The clamp boundary, as specified.** The rule fires only when φ₃ is above the new range.
   - Default → n₁ = 2 (φ₃ = 2, N = 1) → n₁ = 1 keeps φ₃ = 2, which is B + 1 on the new shell, so it lands on N = 0 (tested, "rule boundary").
   - A rule that kept N = 1 here (for example "keep N when it still fits, else N = 1") would be a further change. It was not made.
2. **The internal record at N = 0** (`checked`, `prime`, `residue`) was aligned with the new label (`false`, `null`, `null`).
   - It is not exported and nothing reads it at N = 0. It is listed field by field in the test.
   - If saphir prefers a label-only change, it is a one-line revert of those three values.
3. **Pair export.** At N = 0 its `exact.sha256` changes with the exact export. The format is unchanged.
4. **Not tested:** a real phone (Playwright emulation only), and the speed scripts (`build/perf-*.cjs`). The v0.3 speed bounds in browser-check pass.

### Pins

- `dist/comb-hopf.html` sha256 `2b59d23c2e1b6bd96856d695f4cb45eb5f653927ee433b2079c12975452aad14` (two consecutive builds give the same hash).
- `dist/MANIFEST.sha256` sha256 `d24a6a387b2c3990679cd3535955144a31e5ca00907f2ab27d67be83a98cba83`.
- `SHA256SUMS.txt` (LF) lists every file of this folder except itself.

Credits:
- saphir: the decision;
- the v0.4.1 build report: both defects (addendum 9 §1);
- the earlier builders: as recorded above;
- Claude Opus 5.5: v0.4.2.
