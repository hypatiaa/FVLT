# BUILD REPORT v0.4.18 (2026-10-31): surface pens with the Goldbach stream, and the v0.4.17 fix-ups

Builder: subagent, Claude Opus 5.5. Brief: `FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031_BRIEF/BUILD_BRIEF_v0_4_18_SURFACE_PENS_GOLDBACH.md`, sha256 dd95554bfadb5b9e43945ac9c16b3400257963e9142822c77fb4e32cc4e24830 (checked before reading). Owner updates followed during the build: membrane jobs through the capped runner in `~/membrane_compute/viewer/v0_4_18/` (MEMBRANE_COMPUTE_SETUP_v0_1.md, 7369e1fc…); the new browser checks and the screenshots on membrane; then (update 2) all browser suites on membrane, v0.4.17 first as the Linux baseline, then v0.4.18; the final Neo runall dropped.

- **Base v0.4.17** (verified PASS: `FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029_VERIFY/VERIFY_REPORT_v0_4_17.md`, 95a8427c…, hash checked). It inherits v0.4.16, **whose independent verification is still open**; v0.4.18 inherits that, and its own independent verification is open.
- New folder `FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/`, a full copy of v0.4.17 (`sha256sum -c` of the copy: 363/363 OK before any change). **Nothing in v0.4.17 or earlier was edited:** after the build, v0.4.17's SHA256SUMS.txt passes 363/363 (its dist af217ccc…, its SHA256SUMS.txt 9bd3dfa2…).
- No git, no downloads; network only ssh/scp to membrane over Tailscale (`saphir@[ts-redact-4]`). I ran no Python myself (test-v0410 makes its own live `python -I` call of disk_checks.py inside the old suite; on membrane there is no `python`, see below). Nothing was written into `rule30_prize_research_2026_10_26/`; three of its pinned files were read and copied to membrane for test-rule30-ladder.
- **Hosts.** Neo (Windows): editing, packaging, development probes (not of record). **Membrane (Linux, Ubuntu 24.04, node v24.13.0, Playwright 1.61.1 with Chromium 149): every test output of record in this report.** The node suites ran through the capped runner (jobs VIEW-NODE-0418-01 … 07) and again inside the full runall. Every browser check and every screenshot (`shot_v0418_linux_*`) was made there. There are no Neo screenshots of record.

## What was built

### Part A: the streams (exact), `host-core/pen-streams-core.js`
- Rule 30 / Rule 150 from one black cell, Uint8 rows of width 2T + 5, s_t = −1 iff x_t(0) ⊕ x_t(1) = 1; tooth events q = r = 1. Fair coin: xorshift32 (13, 17, 5) on a BigInt kept in [0, 2³²) (the same values as the skeleton's `>>> 0` code, with no Number conversion), + on odd; seed 1 … 2³² − 1, "New seed" by `crypto.getRandomValues`.
- **Goldbach shell N** (even, 4 … 1,448): the mask of `goldbach-core.js`, read unchanged; one sign per tooth; + iff N/2 ± c·t₂ are both prime (the equal pair at c = 0 included).
  - **A reading of the brief, recorded.** The brief says "the shell's teeth in the track's order, c = 0, 1, 2, …". The v0.4.14 comb lists the teeth in offset order (−(m−1)/2 …, or odd c for even m), which does not start at c = 0. The brief also says "the stream length is the number of teeth". So I used **every tooth of the comb once, ordered c = 0 first, then |c| = 1, 2, 3, … with +c before −c**. With that, #+ = 2g(N) − δ (δ = 1 when N/2 is prime; the equal pair is counted once), checked exactly for all 723 shells. If the owner meant only the c ≥ 0 half (then #+ = g(N)), it is a small change; see Open.
  - Readouts: g(N), #+, #−, the relation, the net turning (#+ − #−)·90°. The g(N) = 0 guard was exercised in the test with an injected empty pair set; the minimum g(N) on 4 … 1,448 is 1.
- **Goldbach run** to N_max (≤ 1,448): the shells concatenated; the boundaries are amber ticks on the strips. N_max = 1,448: 723 shells, 257,430 signs, 30,534 + = 2·15,331 − 128.
- On both cards, with a Goldbach stream, the guards "The pen draws the prime-pair mask; it proves nothing about Goldbach." and "Closure reaches conjugation, not Goldbach." are printed. The bias toward − is stated as a drawing-register observation only.

### Part B: the curvature pen, `host-core/pen-curvature-core.js`, `host-core/field-q2-q5-tau.js`
- **k = 0, lattice:** exact integers, heading in ℤ/4.
- **k = +1, octahedron:** exact flags (integer vectors). The display uses the integer quaternion (7, 3, −2, −1), an exact rational rotation (norm 63). Great-circle arcs run through the rational points ((16 − k²)/(16 + k²), 8k/(16 + k²)). The trail lift 1 + λ·t/T is rational and is labelled a drawing device.
- **k = −1, the {5,4} disk:** **F = ℚ(√2, √5, τ), τ² = √5 − 1**, degree 8, built as a tower field: BigInt-rational coefficient vectors, the reduction table (checked entry by entry), inverses by tower conjugates; then F[i] and SU(1,1). The correction in the brief holds: cosh²(ℓ/2) = (3 + √5)/4 and sinh²(ℓ/2) = (√5 − 1)/4, both checked exactly.
  - Runs with T ≤ 64 are exact over F[i].
  - Longer runs use **exact chunk products**. Every step matrix is X/4 with X integral, so 64 steps form an integer matrix over 4⁶⁴, computed without gcds through the reduction table. Only the chunk products are multiplied as BigInt intervals, with a shared power-of-two exponent.
  - This replaced my first version, which took an interval product per step. Its enclosures widened by about 1.04 bits per step, so it needed P = 4,672 bits at T = 4,096 and took 7–8 s in Chromium. With chunks, the measured loss is at most 3 bits per chunk join (tested), and P = 128 + 8 bits per join: **P = 256 at T = 1,024 and P = 640 at T = 4,096**. The card doubles P if the distance shows fewer than 6 guaranteed places.
  - Follow the pen: Q_j = g_u⁻¹ g_(u−j) (checked exactly for j ≤ 40), over the last W steps; the absolute view when it is off. Edges are drawn through tanh(kℓ/8), k = 0 … 4: r₂ and r₄ lie in F, r₁ comes from interval roots, r₃ from tanh addition. The {5,4} patch is an exact BFS over F[i] frames, depth 8, 334 edges.
  - Distance: cosh d = |a|² + |b|². This equals (1 + |z|²)/(1 − |z|²) because |a|² − |b|² = 1 exactly; the direct quotient would cancel catastrophically. d = log(cosh d + √(cosh² d − 1)) by an outward-rounded atanh series. Both are intervals with guaranteed digits.
  - Cap: 4,096 steps, with the visible label "k = −1 drawn to T = 4096; the rest is not drawn (stream length …)".

### Part C: the squeezed-sphere pen, `host-core/pen-sphere-core.js`
- **For free α and θ I chose the guaranteed numerical register, not Q(ζ₉₆).** Q(ζ₉₆) was implemented in the test and benchmarked on membrane (log below): its coefficients grow by about 2 bits per step, and the cost per step grows with them. Its frames do meet the interval enclosures. It is too slow for a card at T = 1,328, and its positions would still need enclosures for the pixels and the cells.
- The card uses a **ball register**. The frame (x, v, x × v) moves by one orthogonal 3 × 3 matrix per sign. A rounded midpoint and a rigorous Frobenius radius are carried; since the true step is orthogonal, the radius grows **linearly** in T. P = 96 bits; the final radius is 30,543 ulp at T = 1,328 and 94,207 ulp at T = 4,096.
- A per-step interval register (P = 64 + T) is kept as the cross-check: every ball meets its enclosure, and the coverage and uncertain counts agree.
- **The dodecahedron preset is exact in K = ℚ(√3, √5)** (cos θ = 1/2, sin θ = √3/2, cos α = √5/3, sin α = 2/3). See "What the dodecahedron preset was shown to do".
- Coverage uses the skeleton's 432 cells (24 z-bands × 18 sectors). A point whose enclosure meets a cell boundary is counted as uncertain. Exact points follow the skeleton's atan2 conventions. For the dodecahedron preset every cell is decided exactly in K: the sector rays at multiples of 60° have cos and sin in K, and the other rays cannot pass through a point of K³ off the axis, so enclosures decide them.
- Tooth events (Rule 30, q = r = 1) are amber dots. Cap 4,096, with a visible label.

### Part D: placement and UI, `instruments/comb-hopf/panel-pens.js`
- A new Panels group, **"E. Surface pens (exact)"**, placed last, with "Curvature pen (exact)" (three panels side by side, stacked at 375 px) and "Squeezed-sphere pen (exact)". Both are collapsed on a fresh page and compute only when opened.
- Shared dials: stream, T, seed, N, N_max, follow, W. Card dials: α, θ and the preset on the sphere card; λ on the curvature card.
- A stream strip under each panel: cyan +, red −, amber shell ticks, and a white bar where a panel is capped.
- Degenerate cases are drawn and labelled: T = 0, the caps, g(N) = 0 (guard).
- Card text: the Lean citations `FVLTS4sSqueezeCornersV1` (v15) and `FVLTS4sRule150PenV1.pen_confined` (v16); the labels A₄ not S₄, FINITE readouts, no periodicity claim, idea credit to saphir. The about text gives the prior art: the four skeleton pages with their hashes, the handoff, and the note that `FVLTS4sRule150PenV1` is not `FVLTTurnFourierPenV1`.
- **The D1 link.** D1's card body gains one paragraph, "See also: the surface pens …", which opens the Panels tab with the pen card open. The pen cards link to D1 (Clifford tab, rl = 1). D1 is otherwise byte-identical: `browser-check-legacy-panels-v0418` shows that with D1 on, the cards equal v0.4.16's once that paragraph is removed, and browser-check-v0416 (the D1 suite) passes 218/0.
- Dial ledger: the README sections "Dial ledger: group E surface pens (v0.4.18)" and "Dial ledger additions: group D fix-ups (v0.4.18)". `SCHEMA_ADDENDUM_25.md` covers the state, the dials and the three registers.

### Part E: the v0.4.17 fix-ups (`view-panels.js`, `panel-elliptic.js`)
1. The group D heading is "D. Elliptic and BSD".
2. The case table is five stacked blocks. The browser check measures the client rects of every word at both sizes; no word is broken.
3. The scatter has zoom 1×, 2× and 4×, with a window moved by ◀ ▶ ▼ ▲ in half-window steps, and a minimum dot of 3 px (p = 97 at 1×: 3 px dots).
4. When P1 = P2, the P2 outline is drawn 6 px larger, and both colours are present.
5. "ν (nu)".
6. U+2212 in the refused 11a1 Δ.
7. F3: additive reduction is labelled "additive". Test curves: y² = x³ + 5 (additive at 5) and 27a1 (additive at 3). a_p = 0 by the naive count and by the character sum; the reduction type by the cusp and by p | c4 with p | Δ.

### Part F: the old checks
- None was edited.
- `build/EXPECTED_FAILS_v0418.txt` lists, with an attribution for each line, the FAIL lines of test-v0410 … v0414, browser-check-v0410 … v0414 and browser-check-v0417 on v0.4.18 (membrane).
- `build/check-expected-fails-v0418.cjs` reads the logs of the same run (or runs the suites with `--run`). It passes only if each suite's FAIL set equals the list exactly.
- `build/browser-check-legacy-panels-v0418.cjs` renders v0.4.16 and v0.4.18 on the same host and shows them equal once the four cards of v0.4.17 and v0.4.18 are removed, the group-E heading is removed, and the decided D heading is mapped back.
- I added browser-check-v0417 to the list, because the new cards and the heading break it in the same way.

## The no-float rule
- `build/no-float-v0418.cjs` applies v0.4.17's scanner rules unchanged to all 16 new files: 16/16 clean on membrane (job VIEW-NODE-0418-06, again as job -07 after the last edit, and in the full run).
- Allowlisted: the BigInt-guarded `px` helper in panel-pens.js, and the skeleton's verbatim `map(Math.round)` line in the test-only transcription file. Decimal strings that the tests expect are built from integer strings.
- Checked by reading, because a lexical scan cannot decide it: no `/` on Number operands in the new files. I found one in a test during the build and removed it (the chunk-join count now uses BigInt).
- Integer Numbers that remain: loop indices; Int8, Int32 and Uint8 arrays of signs, bits and lattice coordinates; small canvas constants; integer `Date.now()` milliseconds; `process.hrtime.bigint()`.
- panel-elliptic.js stays clean under no-float-elliptic (8/8).
- The existing viewer code (the tabs, the Poincaré card) still uses floats; I did not touch it.

## What the dodecahedron preset was shown to do (exact, in K = ℚ(√3, √5))
- cos²θ + sin²θ = 1 and cos²α + sin²α = 1 exactly.
- **Five lefts return to the start flag exactly**, so a pentagonal face closes; five rights do too; three lefts do not.
- Closing the start flag under the two moves gives **exactly 60 flags on 20 vertices**. Every frame has |x| = |v| = 1 and x·v = 0 exactly.
- Every vertex has exactly three others at x·y = √5/3.
- The dot products between distinct vertices are exactly those of the regular dodecahedron:

| x·y | ordered pairs |
|---|---|
| √5/3 | 60 |
| 1/3 | 120 |
| −1/3 | 120 |
| −√5/3 | 60 |
| −1 | 20 |

- The moves generate a group of **order 60**. Its elements have orders 1, 2, 3 and 5, with 1, 15, 20 and 24 elements, which is A₅'s profile; each move has order 5.
- Hence every stream walks the edges of a spherical dodecahedron. Rule 30 and the coin at T = 1,328, and the first 4,096 Goldbach-run signs, each visit all 20 vertices and all 60 flags. Coverage is 20/432, every cell decided exactly.
- Not shown: which faces a given stream traces, or how often; nothing beyond the finite structure above. That the group is A₅ is inferred from its order and its class profile, not from an explicit isomorphism.

## Counts: "pixels not certified" and "uncertain cells"
- **Pixels not certified: 0** in every browser run of record (membrane), at both viewports. This covers the disk in follow and absolute views at every tested T (for example 0 of 2,671 at T = 512 following, 0 of 22,152 at T = 4,096 absolute), the {5,4} patch (0 of 1,670 in the node test) and the sphere (0 of 1,329 at T = 1,328). Lattice and octahedron pixels come from exact rationals, so there is nothing to certify.
- **Uncertain cells: 0** for the default sphere run (Rule 30, T = 1,328, α = 3/96, θ = 2/24; 406 of 432 cells) and for the dodecahedron preset (exact). **3** for α = 24/96, θ = 4/24 at T = 1,328: points that lie exactly on cell boundaries, which no enclosure can decide. They are reported, not placed.

## Timings (membrane)
- **Goldbach run, N_max = 1,448** (257,430 steps). Node: lattice 1 ms, octahedron 70 ms. Chromium: lattice 14 ms, octahedron 208–219 ms, and 1.8 s for the whole two-card update (drawing 257,430 lifted arcs on the octahedron dominates).
- **k = −1, Rule 30.** Node: T = 1,024 in 6 ms (P = 256, d = 309.396527759557); T = 4,096 in 27 ms (P = 640, d = 1308.231479757862, cosh d = 7.189235585065 × 10^567). Chromium: 5 ms and 21–22 ms compute, 11–12 ms draw. The absolute view at T = 4,096: 107 ms compute and 133–136 ms draw.
- **Sphere pen, T = 1,328.** Ball register: 4 ms in node; 15–17 ms compute and 3 ms draw in Chromium. The interval cross-check: 121 ms in node.
- The first draw of the {5,4} patch (the exact BFS) costs about 230–240 ms, once per page.

## Precisions chosen
- **Disk:** exact over F[i] for T ≤ 64. Otherwise P = 128 + 8·⌈T/64⌉ bits: 256 at T = 1,024, 640 at T = 4,096, 224 for the 706-tooth shell. Relative precision left at T = 4,096: 2^−569. Trail frames at P(W). The enclosures used for drawing are compacted to 160 bits.
- **Sphere:** balls at 96 bits; the interval cross-check at 64 + T bits.
- **Distance:** printed with 12 guaranteed places, computed at 96 bits.
- **Trigonometric constants:** 40 guard bits.

## Screenshots (all made on membrane by `build/shots-v0418.cjs` in the final run; 40 files `shot_v0418_linux_{1280x800,375x812}_*.png`)
Names: panels_groupE_closed (a viewport shot), curv_r30_T512, sph_r30_T512, curv_r150_T4096, curv_r30_T4096, curv_r30_T4096_absolute, sph_r30_T1328, sph_dodeca_r30_T1328, curv_gbshell_1448, curv_gbshell_24, curv_gbrun_1448, sph_gbrun_1448, curv_T0, ell_cases_p5, ell_p5_P1eqP2, ell_p97_zoom1, ell_p97_zoom2, ell_p97_zoom4, per_11a1_refused, ell_points_card_p97 (all at both sizes).

I looked at: 1280 curv_gbrun_1448, 1280 curv_r30_T4096_absolute, 1280 panels_groupE_closed, 1280 sph_r30_T1328, 1280 ell_p5_P1eqP2, 375 curv_gbshell_1448, 375 sph_dodeca_r30_T1328 (before and after the label fix), 375 ell_cases_p5 and 375 ell_p97_zoom2. Earlier, during development on Neo, I also looked at the curvature and sphere cards at both sizes. I did not open the others one by one.

What I saw:
- **Group E closed (1280):** "E. SURFACE PENS (EXACT)" is the last heading, after the two group-D exact cards, with the two pen cards collapsed.
- **Goldbach run to 1,448 (1280):**
  - The readout block shows 723 shells, 257,430 teeth, + 30,534, the relation "holds (exact)", the net turning −196362·90°, and both guards plus the bias note.
  - Octahedron: the lifted trail rings the faces (orange, with the back side in grey).
  - Lattice: a cyan-to-orange cluster, max |x| 115, |y| 208.
  - Disk: the pen at the centre with a short trail; most of the last 200 steps already sit near the boundary.
  - Strips: mostly red, with a band of amber shell ticks along the bottom; the disk strip has a white cap bar near its start (4,096 of 257,430).
  - The cap label is visible. The T slider shows a stale value while disabled; the label says T does not apply.
- **Goldbach shell 1,448 (375):** the readout (g = 20, + 40, 666 −, net −626·90°, the tooth order and the list of c). The lattice drawing is a narrow column of squares (26 points). The octahedron reaches 8 flags, with the trail on one side. Disk d = 25.08. The panels are stacked; no sideways scroll.
- **Rule 30, T = 4,096, absolute disk (1280):** the path leaves the origin, runs along a few tiling edges and then hugs the boundary (light blue, oldest steps). The {5,4} patch is drawn faintly, with the green start dot at the centre. The readout gives "absolute view from the start · pixels not certified: 0 of 22152".
- **Sphere, Rule 30, T = 1,328 (1280):**
  - A dense web of geodesic steps, cyan and orange by age, with back-side steps faint.
  - Amber tooth dots everywhere (339 events).
  - The readout gives the ball register, P = 96, final radius 30543·2^−96, coverage 406/432, uncertain 0, pixels not certified 0 of 1329.
- **Dodecahedron preset (375):** the projected dodecahedron is clearly visible: pentagons with three edges at each vertex, front edges orange, back edges faint, and amber tooth dots at the vertices. In the first shot the label "preset" broke inside the word ("pres / et"); I fixed it (nowrap), reran everything, and the final shot reads "preset" on one line. The select text is cut off at the right edge of its box ("cos α…"), which is cosmetic.
- **Case table (375):** five stacked blocks, the doubling block highlighted in green with ▶. "not 2-torsion" is on one line, and the λ formula wraps between tokens.
- **p = 97 at zoom 2× (375):** a 49-cell window with 3 px or larger dots and the axis labels 0 / 48. At 1× the dots are 3 px (fixed minimum).
- **P1 = P2 at p = 5 (1280):** the amber P1 box sits inside a larger violet P2 box; the green P1 + P2 box is next to it. Both outlines are visible.
- Nothing else looked wrong to me. saphir's eye on the colours (the age palette, the red-dominated Goldbach strips) is the one that counts.

## The Linux FAIL sets: v0.4.17 (baseline) and v0.4.18 (final), both on membrane, and the difference
FAIL counts per suite are in the two SUMMARY files below. The **difference** (a FAIL line present in v0.4.18 and absent in v0.4.17, or the reverse) consists only of these lines:

```
== browser-check-v0410
  v0.4.17 only: FAIL 1280x800 both cards present in group B after the G. Robin card, adjacent, and collapsed on a fresh page; all other cards unchanged (open) orbit-point-index:true contact-sweep:true tooth-contacts:true basel-cone:true reciprocal-record:true pi-b-shell:true g-robin-margin:true branch-primitivity:false poincare-disk:false cayley-m3:true m4-atom:true m5-structure:true m6-walk:true m7-divisor-atom:true mcomb-elliptic-bsd:true carrier-addition:true exact-curve-bsd:true clifford-elliptic-bridge:true arithmetic-fourier:true elliptic-points-exact:false period-lattice-exact:false
  v0.4.17 only: FAIL 375x812 both cards present in group B after the G. Robin card, adjacent, and collapsed on a fresh page; all other cards unchanged (open) orbit-point-index:true contact-sweep:true tooth-contacts:true basel-cone:true reciprocal-record:true pi-b-shell:true g-robin-margin:true branch-primitivity:false poincare-disk:false cayley-m3:true m4-atom:true m5-structure:true m6-walk:true m7-divisor-atom:true mcomb-elliptic-bsd:true carrier-addition:true exact-curve-bsd:true clifford-elliptic-bridge:true arithmetic-fourier:true elliptic-points-exact:false period-lattice-exact:false
  v0.4.18 only: FAIL 1280x800 both cards present in group B after the G. Robin card, adjacent, and collapsed on a fresh page; all other cards unchanged (open) orbit-point-index:true contact-sweep:true tooth-contacts:true basel-cone:true reciprocal-record:true pi-b-shell:true g-robin-margin:true branch-primitivity:false poincare-disk:false cayley-m3:true m4-atom:true m5-structure:true m6-walk:true m7-divisor-atom:true mcomb-elliptic-bsd:true carrier-addition:true exact-curve-bsd:true clifford-elliptic-bridge:true arithmetic-fourier:true elliptic-points-exact:false period-lattice-exact:false pen-curvature-exact:false pen-sphere-exact:false
  v0.4.18 only: FAIL 375x812 both cards present in group B after the G. Robin card, adjacent, and collapsed on a fresh page; all other cards unchanged (open) orbit-point-index:true contact-sweep:true tooth-contacts:true basel-cone:true reciprocal-record:true pi-b-shell:true g-robin-margin:true branch-primitivity:false poincare-disk:false cayley-m3:true m4-atom:true m5-structure:true m6-walk:true m7-divisor-atom:true mcomb-elliptic-bsd:true carrier-addition:true exact-curve-bsd:true clifford-elliptic-bridge:true arithmetic-fourier:true elliptic-points-exact:false period-lattice-exact:false pen-curvature-exact:false pen-sphere-exact:false
== browser-check-v0417
  v0.4.18 only: FAIL 1280x800 identical to v0.4.16 on 6 states (stage, caption, cards, address, html stage); on the Panels tab the only difference is the two new card elements {"tab":"panels"} new=2 | {"tab":"panels","shellMode":"integer","B":"24"} new=2
  v0.4.18 only: FAIL 1280x800 both cards in group D after the legacy D placeholders, adjacent, collapsed on a fresh page (23 cards) orbit-point-index:true:true contact-sweep:true:true tooth-contacts:true:true basel-cone:true:true reciprocal-record:true:true pi-b-shell:true:true g-robin-margin:true:false branch-primitivity:false:false poincare-disk:false:false cayley-m3:true:true m4-atom:true:true m5-structure:true:true m6-walk:true:true m7-divisor-atom:true:true mcomb-elliptic-bsd:true:true carrier-addition:true:true exact-curve-bsd:true:true clifford-elliptic-bridge:true:true arithmetic-fourier:true:true elliptic-points-exact:false:false period-lattice-exact:false:false pen-curvature-exact:false:false pen-sphere-exact:false:false
  v0.4.18 only: FAIL 375x812 identical to v0.4.16 on 6 states (stage, caption, cards, address, html stage); on the Panels tab the only difference is the two new card elements {"tab":"panels"} new=2 | {"tab":"panels","shellMode":"integer","B":"24"} new=2
  v0.4.18 only: FAIL 375x812 both cards in group D after the legacy D placeholders, adjacent, collapsed on a fresh page (23 cards) orbit-point-index:true:true contact-sweep:true:true tooth-contacts:true:true basel-cone:true:true reciprocal-record:true:true pi-b-shell:true:true g-robin-margin:true:false branch-primitivity:false:false poincare-disk:false:false cayley-m3:true:true m4-atom:true:true m5-structure:true:true m6-walk:true:true m7-divisor-atom:true:true mcomb-elliptic-bsd:true:true carrier-addition:true:true exact-curve-bsd:true:true clifford-elliptic-bridge:true:true arithmetic-fourier:true:true elliptic-points-exact:false:false period-lattice-exact:false:false pen-curvature-exact:false:false pen-sphere-exact:false:false
== test-v0411
  v0.4.17 only: FAIL panel-g-robin.js, panel-bd.js and 6 other source files are byte-identical to v0.4.10 host-core/comb-numeric.js
  v0.4.18 only: FAIL panel-g-robin.js, panel-bd.js and 6 other source files are byte-identical to v0.4.10 host-core/comb-numeric.js,instruments/comb-hopf/view-panels.js
== test-v0412
  v0.4.17 only: FAIL source files differing from v0.4.11: host-core/comb-numeric.js, host-core/elliptic-exact-core.js, host-core/elliptic-period-core.js, host-core/goldbach-core.js, host-core/rule30-ladder-core.js, instruments/comb-hopf/index.html, instruments/comb-hopf/panel-elliptic.js, instruments/comb-hopf/panel.js, instruments/comb-hopf/view-clifford.js, instruments/comb-hopf/view-fourier.js, instruments/comb-hopf/view-hopf.js host-core/comb-numeric.js,host-core/elliptic-exact-core.js,host-core/elliptic-period-core.js,host-core/goldbach-core.js,host-core/rule30-ladder-core.js,instruments/comb-hopf/index.html,instruments/comb-hopf/panel-elliptic.js,instruments/comb-hopf/panel.js,instruments/comb-hopf/view-clifford.js,instruments/comb-hopf/view-fourier.js,instruments/comb-hopf/view-hopf.js
  v0.4.18 only: FAIL source files differing from v0.4.11: host-core/comb-numeric.js, host-core/elliptic-exact-core.js, host-core/elliptic-period-core.js, host-core/field-q2-q5-tau.js, host-core/goldbach-core.js, host-core/pen-curvature-core.js, host-core/pen-interval-core.js, host-core/pen-sphere-core.js, host-core/pen-streams-core.js, host-core/rule30-ladder-core.js, instruments/comb-hopf/index.html, instruments/comb-hopf/panel-elliptic.js, instruments/comb-hopf/panel-pens.js, instruments/comb-hopf/panel.js, instruments/comb-hopf/view-clifford.js, instruments/comb-hopf/view-fourier.js, instruments/comb-hopf/view-hopf.js, instruments/comb-hopf/view-panels.js host-core/comb-numeric.js,host-core/elliptic-exact-core.js,host-core/elliptic-period-core.js,host-core/field-q2-q5-tau.js,host-core/goldbach-core.js,host-core/pen-curvature-core.js,host-core/pen-interval-core.js,host-core/pen-sphere-core.js,host-core/pen-streams-core.js,host-core/rule30-ladder-core.js,instruments/comb-hopf/index.html,instruments/comb-hopf/panel-elliptic.js,instruments/comb-hopf/panel-pens.js,instruments/comb-hopf/panel.js,instruments/comb-hopf/view-clifford.js,instruments/comb-hopf/view-fourier.js,instruments/comb-hopf/view-hopf.js,instruments/comb-hopf/view-panels.js
== test-v0413
  v0.4.17 only: FAIL source files differing from v0.4.12: host-core/comb-numeric.js, host-core/elliptic-exact-core.js, host-core/elliptic-period-core.js, host-core/goldbach-core.js, host-core/rule30-ladder-core.js, instruments/comb-hopf/index.html, instruments/comb-hopf/panel-elliptic.js, instruments/comb-hopf/panel.js, instruments/comb-hopf/view-clifford.js, instruments/comb-hopf/view-fourier.js, instruments/comb-hopf/view-hopf.js host-core/comb-numeric.js,host-core/elliptic-exact-core.js,host-core/elliptic-period-core.js,host-core/goldbach-core.js,host-core/rule30-ladder-core.js,instruments/comb-hopf/index.html,instruments/comb-hopf/panel-elliptic.js,instruments/comb-hopf/panel.js,instruments/comb-hopf/view-clifford.js,instruments/comb-hopf/view-fourier.js,instruments/comb-hopf/view-hopf.js
  v0.4.18 only: FAIL source files differing from v0.4.12: host-core/comb-numeric.js, host-core/elliptic-exact-core.js, host-core/elliptic-period-core.js, host-core/field-q2-q5-tau.js, host-core/goldbach-core.js, host-core/pen-curvature-core.js, host-core/pen-interval-core.js, host-core/pen-sphere-core.js, host-core/pen-streams-core.js, host-core/rule30-ladder-core.js, instruments/comb-hopf/index.html, instruments/comb-hopf/panel-elliptic.js, instruments/comb-hopf/panel-pens.js, instruments/comb-hopf/panel.js, instruments/comb-hopf/view-clifford.js, instruments/comb-hopf/view-fourier.js, instruments/comb-hopf/view-hopf.js, instruments/comb-hopf/view-panels.js host-core/comb-numeric.js,host-core/elliptic-exact-core.js,host-core/elliptic-period-core.js,host-core/field-q2-q5-tau.js,host-core/goldbach-core.js,host-core/pen-curvature-core.js,host-core/pen-interval-core.js,host-core/pen-sphere-core.js,host-core/pen-streams-core.js,host-core/rule30-ladder-core.js,instruments/comb-hopf/index.html,instruments/comb-hopf/panel-elliptic.js,instruments/comb-hopf/panel-pens.js,instruments/comb-hopf/panel.js,instruments/comb-hopf/view-clifford.js,instruments/comb-hopf/view-fourier.js,instruments/comb-hopf/view-hopf.js,instruments/comb-hopf/view-panels.js
== test-v0414
  v0.4.18 only: FAIL comb-core.js, orbit-core.js, fraction-stack-core.js, stack-core.js, gearbox-core.js, shell-core.js, ca-core.js, exact-lib unchanged against v0.4.13
== test-v042
  v0.4.17 only: FAIL Fix 1 scope (source): host-core/comb-core.js differs from v0.4.1 by exactly one added line (the N = 0 branch of wilsonN); every other host-core module and exact-lib file is byte-identical to v0.4.1; instruments/comb-hopf/panel.js differs only in clampPhi (lines 45 and 48); no other instrument file differs (10 files byte-identical; panel.js lines differing: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 298, 299, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 314, 315, 316, 317, 318, 319, 320, 321, 322, 323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 342, 343, 344, 345, 346, 347, 348, 349, 350, 351, 352, 353, 354, 355, 356, 357, 358, 359, 360, 361, 362, 363, 364, 365, 366, 367, 368, 369, 370, 371, 372, 373, 374, 375, 376, 377, 378, 379, 380, 381, 382, 383, 384, 385, 386, 387, 388, 389, 390, 391, 392, 393, 394, 395, 396, 397, 398, 399, 400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 412, 413, 414, 415, 416, 417, 418, 419, 420, 421, 422, 423, 424, 425, 426, 427, 428, 429, 430, 431, 432, 433, 434, 435, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447, 448, 449, 450, 451, 452, 453, 454, 455, 456, 457, 458, 459, 460, 461, 462, 463, 464, 465, 466, 467, 468, 469, 470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523, 524, 525, 526, 527, 528, 529, 530, 531, 532, 533, 534, 535, 536, 537, 538, 539, 540, 541, 542, 543, 544, 545, 546, 547, 548, 549, 550, 551, 552, 553, 554, 555, 556, 557, 558, 559, 560, 561, 562, 563, 564, 565, 566, 567, 568, 569, 570, 571, 572, 573, 574, 575, 576, 577, 578, 579, 580, 581, 582, 583, 584, 585, 586, 587, 588, 589, 590, 591, 592, 593, 594, 595, 596, 597, 598, 599, 600, 601, 602, 603, 604, 605, 606, 607, 608, 609, 610, 611, 612, 613, 614, 615, 616, 617, 618, 619, 620; new host-core files: branch-disk-core.js, ca-core.js, elliptic-exact-core.js, elliptic-period-core.js, goldbach-core.js, rhm-core.js, rule30-ladder-core.js, stack-core.js, test-elliptic-exact.cjs, test-elliptic-period.cjs, test-rule30-ladder.cjs, test-v042.cjs) differing: host-core/comb-numeric.js, host-core/parity-sample.cjs, host-core/test-core.cjs, instruments/comb-hopf/index.html, instruments/comb-hopf/view-clifford.js, instruments/comb-hopf/view-fourier.js, instruments/comb-hopf/view-hopf.js, instruments/comb-hopf/view-panels.js, instruments/comb-hopf/views-common.js
  v0.4.18 only: FAIL Fix 1 scope (source): host-core/comb-core.js differs from v0.4.1 by exactly one added line (the N = 0 branch of wilsonN); every other host-core module and exact-lib file is byte-identical to v0.4.1; instruments/comb-hopf/panel.js differs only in clampPhi (lines 45 and 48); no other instrument file differs (10 files byte-identical; panel.js lines differing: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 298, 299, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 314, 315, 316, 317, 318, 319, 320, 321, 322, 323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 342, 343, 344, 345, 346, 347, 348, 349, 350, 351, 352, 353, 354, 355, 356, 357, 358, 359, 360, 361, 362, 363, 364, 365, 366, 367, 368, 369, 370, 371, 372, 373, 374, 375, 376, 377, 378, 379, 380, 381, 382, 383, 384, 385, 386, 387, 388, 389, 390, 391, 392, 393, 394, 395, 396, 397, 398, 399, 400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 412, 413, 414, 415, 416, 417, 418, 419, 420, 421, 422, 423, 424, 425, 426, 427, 428, 429, 430, 431, 432, 433, 434, 435, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447, 448, 449, 450, 451, 452, 453, 454, 455, 456, 457, 458, 459, 460, 461, 462, 463, 464, 465, 466, 467, 468, 469, 470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523, 524, 525, 526, 527, 528, 529, 530, 531, 532, 533, 534, 535, 536, 537, 538, 539, 540, 541, 542, 543, 544, 545, 546, 547, 548, 549, 550, 551, 552, 553, 554, 555, 556, 557, 558, 559, 560, 561, 562, 563, 564, 565, 566, 567, 568, 569, 570, 571, 572, 573, 574, 575, 576, 577, 578, 579, 580, 581, 582, 583, 584, 585, 586, 587, 588, 589, 590, 591, 592, 593, 594, 595, 596, 597, 598, 599, 600, 601, 602, 603, 604, 605, 606, 607, 608, 609, 610, 611, 612, 613, 614, 615, 616, 617, 618, 619, 620; new host-core files: branch-disk-core.js, ca-core.js, elliptic-exact-core.js, elliptic-period-core.js, field-q2-q5-tau.js, goldbach-core.js, pen-curvature-core.js, pen-interval-core.js, pen-sphere-core.js, pen-streams-core.js, rhm-core.js, rule30-ladder-core.js, stack-core.js, test-elliptic-exact.cjs, test-elliptic-period.cjs, test-pen-curvature.cjs, test-pen-fields.cjs, test-pen-sphere.cjs, test-pen-streams.cjs, test-rule30-ladder.cjs, test-v0418-fixups.cjs, test-v042.cjs, transcription-skeleton-pens.cjs) differing: host-core/comb-numeric.js, host-core/parity-sample.cjs, host-core/test-core.cjs, instruments/comb-hopf/index.html, instruments/comb-hopf/view-clifford.js, instruments/comb-hopf/view-fourier.js, instruments/comb-hopf/view-hopf.js, instruments/comb-hopf/view-panels.js, instruments/comb-hopf/views-common.js
```

Every "v0.4.18 only" line is attributed in `build/EXPECTED_FAILS_v0418.txt` (test-v0411 … v0414, browser-check-v0410, browser-check-v0417), except the changed test-v042 provenance line, which is attributed in Open 3. There is no other regression on Linux.

<details><summary>All FAIL lines, v0.4.17 on membrane (Linux baseline, run417)</summary>

```
browser-check-mirror	FAIL 375x812 v0.4 menu inventory: Fourier Layers = Teeth, Walk, Amber polygon, ÷ Divisors, Mirror axis (5); Clifford pressed layers with swatches = leaf, s-orbits, Grid, Mirror axis (4) {"f":["Teeth","Walk","Amber polygon","÷ Divisors","Mirror axis","○ Full stack","○ Fraction stack"],"c":["leaf","orb","grid","mirror"]}
browser-check-mirror	FAIL 1280x800 v0.4 menu inventory: Fourier Layers = Teeth, Walk, Amber polygon, ÷ Divisors, Mirror axis (5); Clifford pressed layers with swatches = leaf, s-orbits, Grid, Mirror axis (4) {"f":["Teeth","Walk","Amber polygon","÷ Divisors","Mirror axis","○ Full stack","○ Fraction stack"],"c":["leaf","orb","grid","mirror"]}
browser-check-v041	FAIL 375x812 n1_1 fourier: renders without a refusal or error, first screen holds (transport bottom 838 ≤ 812), no visible text below 13 px (smallest 13.000) {"L":{"tr":838.21875,"vh":812,"status":"","svg":31},"bad":[]}
browser-check-v041	FAIL 375x812 n1_2 fourier: renders without a refusal or error, first screen holds (transport bottom 838 ≤ 812), no visible text below 13 px (smallest 13.000) {"L":{"tr":838.21875,"vh":812,"status":"","svg":40},"bad":[]}
browser-check-v041	FAIL 375x812 n1_1_continuous fourier: renders without a refusal or error, first screen holds (transport bottom 874 ≤ 812), no visible text below 13 px (smallest 13.000) {"L":{"tr":874.21875,"vh":812,"status":"","svg":34},"bad":[]}
browser-check-v041	FAIL 375x812 B1_integer fourier: renders without a refusal or error, first screen holds (transport bottom 838 ≤ 812), no visible text below 13 px (smallest 13.000) {"L":{"tr":838.21875,"vh":812,"status":"","svg":32},"bad":[]}
browser-check-v0410	FAIL 1280x800 byte-identical to v0.4.9 for 28 states (incl. tilt −1/2): stage, canvas, caption, about, cards, address, hash, state AND exact JSON, state JSON, CSV, Lift JSON, stats (28/28 exports); Panels tab (8 states) differs only by the two new collapsed card elements (0) panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3=1&m=8&t1= hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3=1&m=8&t1= hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=49&nMode=integer&phi3=0&m=15&t1=1&t hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=49&nMode=integer&phi3=0&m=15&t1=1&t hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=9&nMode=integer&phi3=0&m=7&t1=1&t2= hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=9&nMode=integer&phi3=0&m=7&t1=1&t2= hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=5040&nMode=integer&phi3=12&m=9&t1=1 hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=5040&nMode=integer&phi3=12&m=9&t1=1 hstage(2)
browser-check-v0410	FAIL 1280x800 both cards present in group B after the G. Robin card, adjacent, and collapsed on a fresh page; all other cards unchanged (open) orbit-point-index:true contact-sweep:true tooth-contacts:true basel-cone:true reciprocal-record:true pi-b-shell:true g-robin-margin:true branch-primitivity:false poincare-disk:false cayley-m3:true m4-atom:true m5-structure:true m6-walk:true m7-divisor-atom:true mcomb-elliptic-bsd:true carrier-addition:true exact-curve-bsd:true clifford-elliptic-bridge:true arithmetic-fourier:true elliptic-points-exact:false period-lattice-exact:false
browser-check-v0410	FAIL 375x812 byte-identical to v0.4.9 for 28 states (incl. tilt −1/2): stage, canvas, caption, about, cards, address, hash, state AND exact JSON, state JSON, CSV, Lift JSON, stats (28/28 exports); Panels tab (8 states) differs only by the two new collapsed card elements (0) panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3=1&m=8&t1= hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3=1&m=8&t1= hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=49&nMode=integer&phi3=0&m=15&t1=1&t hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=49&nMode=integer&phi3=0&m=15&t1=1&t hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=9&nMode=integer&phi3=0&m=7&t1=1&t2= hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=9&nMode=integer&phi3=0&m=7&t1=1&t2= hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=5040&nMode=integer&phi3=12&m=9&t1=1 hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=5040&nMode=integer&phi3=12&m=9&t1=1 hstage(2)
browser-check-v0410	FAIL 375x812 both cards present in group B after the G. Robin card, adjacent, and collapsed on a fresh page; all other cards unchanged (open) orbit-point-index:true contact-sweep:true tooth-contacts:true basel-cone:true reciprocal-record:true pi-b-shell:true g-robin-margin:true branch-primitivity:false poincare-disk:false cayley-m3:true m4-atom:true m5-structure:true m6-walk:true m7-divisor-atom:true mcomb-elliptic-bsd:true carrier-addition:true exact-curve-bsd:true clifford-elliptic-bridge:true arithmetic-fourier:true elliptic-points-exact:false period-lattice-exact:false
browser-check-v0411	FAIL 1280x800 byte-identical to v0.4.10 for 32 states (incl. tilt −1/2, stack on / reciprocal off): stage, canvas, caption, about, cards, address, hash AND exact JSON, state JSON, CSV, Lift JSON, stats (32/32 exports) panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3 hstage | panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3 hstage | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=9&nMode=integer&phi3=0&m= hstage | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=9&nMode=integer&phi3=0&m= hstage
browser-check-v0411	FAIL 375x812 byte-identical to v0.4.10 for 32 states (incl. tilt −1/2, stack on / reciprocal off): stage, canvas, caption, about, cards, address, hash AND exact JSON, state JSON, CSV, Lift JSON, stats (32/32 exports) panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3 hstage | panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3 hstage | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=9&nMode=integer&phi3=0&m= hstage | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=9&nMode=integer&phi3=0&m= hstage
browser-check-v0412	FAIL 1280x800 fl off: byte-identical to v0.4.11 for 34 states (incl. tilt −1/2, stack / reciprocal / fraction on): stage, canvas, caption, about, cards, address, hash AND exact JSON, state JSON, CSV, Lift JSON, stats (34/34 exports) panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3 hstage | panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3 hstage
browser-check-v0412	FAIL 375x812 fl off: byte-identical to v0.4.11 for 34 states (incl. tilt −1/2, stack / reciprocal / fraction on): stage, canvas, caption, about, cards, address, hash AND exact JSON, state JSON, CSV, Lift JSON, stats (34/34 exports) panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3 hstage | panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3 hstage
browser-check-v0413	FAIL 1280x800 fl off: byte-identical to v0.4.12 for 36 states (tilt -1/2 too): stage, canvas, caption, about, cards, address, hash and the five exports (36/36) panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3 hstage | panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3 hstage
browser-check-v0413	FAIL 375x812 fl off: byte-identical to v0.4.12 for 36 states (tilt -1/2 too): stage, canvas, caption, about, cards, address, hash and the five exports (36/36) panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3 hstage | panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3 hstage
browser-check-v0414	FAIL 1280x800 track off: byte-identical to v0.4.13 for 32 states (incl. the Goldbach shells without the flag, tilt −1/2 too): stage, canvas, caption, about, cards, address, hash and the five exports (32/32) panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=in hstage | panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=in hstage | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=11&nMode=intege hstage | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=11&nMode=intege hstage
browser-check-v0414	FAIL 375x812 track off: byte-identical to v0.4.13 for 32 states (incl. the Goldbach shells without the flag, tilt −1/2 too): stage, canvas, caption, about, cards, address, hash and the five exports (32/32) panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=in hstage | panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=in hstage | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=11&nMode=intege hstage | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=11&nMode=intege hstage
browser-check-v044	FAIL 1280x800 the preset menu lists exactly 2,6,12,60,120,360,2520,5040,55440,720720
browser-check-v044	FAIL 1280x800 layout B=55440: 23 value cells in C1/C2/constants lie inside their card, are >= 40% of the card inner width (or on their own row), no single-character lines, no page scroll {"bad":["rhm-c1 single-character line in [−0.071310031214214456408696, "],"cells":23,"sw":1265,"iw":1280}
browser-check-v044	FAIL 1280x800 layout B=720720: 23 value cells in C1/C2/constants lie inside their card, are >= 40% of the card inner width (or on their own row), no single-character lines, no page scroll {"bad":["rhm-c1 single-character line in [−0.124904813854560748862942, "],"cells":23,"sw":1265,"iw":1280}
browser-check-v044	FAIL 1280x800 exactly 16 other Panels cards remain placeholders ("not yet rebuilt"); the g-robin card is not one
browser-check-v044	FAIL 375x812 the preset menu lists exactly 2,6,12,60,120,360,2520,5040,55440,720720
browser-check-v044	FAIL 375x812 exactly 16 other Panels cards remain placeholders ("not yet rebuilt"); the g-robin card is not one
browser-check-v047	FAIL 1280x800 t1*s in Z: tilt 0 caption "★ lab sum real"; tilt 1 caption "★ pair phases conjugate (t₁·s ∈ ℤ); tilted walk not real in general" ALIGN yes · SPREAD yes ★ lab sum real · Q-res 0.0e+0 (numerical) · mirror axis = real axis (t₁·s ∈ ℤ) || ALIGN yes · SPREAD yes ★ teeth conjugate (t₁·s ∈ ℤ); walk not real · Q-res 6.0e+0 (numerical) · mirror axis = real axis (t₁·s ∈ ℤ)
browser-check-v047	FAIL 375x812 t1*s in Z: tilt 0 caption "★ lab sum real"; tilt 1 caption "★ pair phases conjugate (t₁·s ∈ ℤ); tilted walk not real in general" ALIGN yes · SPREAD yes ★ lab sum real · Q-res 0.0e+0 (numerical) · mirror axis = real axis (t₁·s ∈ ℤ) || ALIGN yes · SPREAD yes ★ teeth conjugate (t₁·s ∈ ℤ); walk not real · Q-res 6.0e+0 (numerical) · mirror axis = real axis (t₁·s ∈ ℤ)
browser-check-v048	FAIL 1280x800 tilt -1: Q-res part "Q-res x (numerical)" fully visible (not cut by the ellipsis) ALIGN yes · SPREAD no ★ teeth conjugate (t₁·s ∈ ℤ); walk not real · Q-res 6.1e+0 (numerical) · mirror axis = real axis (t₁·s ∈ ℤ)
browser-check-v048	FAIL 1280x800 tilt -3/5: Q-res part "Q-res x (numerical)" fully visible (not cut by the ellipsis) ALIGN yes · SPREAD no ★ teeth conjugate (t₁·s ∈ ℤ); walk not real · Q-res 5.2e+0 (numerical) · mirror axis = real axis (t₁·s ∈ ℤ)
browser-check-v048	FAIL 1280x800 tilt 1: Q-res part "Q-res x (numerical)" fully visible (not cut by the ellipsis) ALIGN yes · SPREAD no ★ teeth conjugate (t₁·s ∈ ℤ); walk not real · Q-res 5.3e+1 (numerical) · mirror axis = real axis (t₁·s ∈ ℤ)
browser-check	FAIL 375x812 Lift JSON branches equal the old viewer exactRationalLift.branches (c as string); independent of branch visibility
browser-check	FAIL 375x812 Fourier Layers menu: Teeth, Walk, Amber polygon, Divisors
browser-check	FAIL 375x812 Guides none: no circles, no swatches; layer swatches only on pressed layers
browser-check	FAIL 375x812 drawer alpha opens with its presets+slider {"sl":2,"pre":6,"dl":0,"box":2,"steppers":4}
browser-check	FAIL 375x812 v0.3 the N mode switch (one toggle button, aria-pressed) is in the φ₃ row, not pressed by default ("N∈ℤ"); step 2: the φ₃ label is a chip "φ₃ 23" in the row and no φ₃ box is on the surface (it is in the φ₃ drawer); the instrument panel keeps the cap: 41 visible controls (ⓘ excluded) <= 40 {"inRow":true,"pressed":"false","txt":"N∈ℤ","box":false,"chip":"φ₃ 23"} {"instNoInfo":41,"frame":{"t":357.21875,"b":599.21875,"vis":true},"phi":{"t":688.21875,"b":745.21875,"vis":true},"s":{"t":747.21875,"b":796.21875,"vis":true},"tr":{"t":798.21875,"b":838.21875,"vis":true},"vh":812}
browser-check	FAIL 375x812 v0.3 step 2 (F1): visible controls in the instrument panel in continuous mode (default φ₃, nothing opened, ⓘ excluded): 41 <= 40 {"instNoInfo":41,"frame":{"t":357.21875,"b":599.21875,"vis":true},"phi":{"t":688.21875,"b":745.21875,"vis":true},"s":{"t":747.21875,"b":796.21875,"vis":true},"tr":{"t":798.21875,"b":838.21875,"vis":true},"vh":812}
browser-check	FAIL 375x812 v0.3 first screen in integer mode (default φ₃): view frame, φ₃ row (to 745), s row (to 796) and transport (to 838) inside the first 812 px {"instNoInfo":41,"frame":{"t":357.21875,"b":599.21875,"vis":true},"phi":{"t":688.21875,"b":745.21875,"vis":true},"s":{"t":747.21875,"b":796.21875,"vis":true},"tr":{"t":798.21875,"b":838.21875,"vis":true},"vh":812}
browser-check	FAIL 375x812 v0.3 first screen in continuous mode (default φ₃): view frame, φ₃ row (to 745), s row (to 796) and transport (to 838) inside the first 812 px {"instNoInfo":41,"frame":{"t":357.21875,"b":599.21875,"vis":true},"phi":{"t":688.21875,"b":745.21875,"vis":true},"s":{"t":747.21875,"b":796.21875,"vis":true},"tr":{"t":798.21875,"b":838.21875,"vis":true},"vh":812}
browser-check	FAIL 375x812 v0.3 step 2 (F1): visible controls in the instrument panel between shells (N = 43/2, continuous mode, nothing opened, ⓘ excluded): 41 <= 40 {"instNoInfo":41,"frame":{"t":393.21875,"b":635.21875,"vis":true},"phi":{"t":724.21875,"b":781.21875,"vis":true},"s":{"t":783.21875,"b":832.21875,"vis":true},"tr":{"t":834.21875,"b":874.21875,"vis":true},"vh":812}
browser-check	FAIL 375x812 v0.3 fourier: the warning line carries the short form "between shells: shell arithmetic undefined" once, in full, on one line, role degenerate, not ellipsized; the shell readout shows N = 43/2 {"n":1,"t":"between shells: shell arithmetic undefined","lines":2,"cls":"warnline","trunc":false,"vis":true,"inView":true,"ell":"clip","shell":"B = n₁! = 24 · N = 43/2"}
browser-check	FAIL 375x812 v0.3 clifford: the warning line carries the short form "between shells: shell arithmetic undefined" once, in full, on one line, role degenerate, not ellipsized; the shell readout shows N = 43/2 {"n":1,"t":"between shells: shell arithmetic undefined","lines":2,"cls":"warnline","trunc":false,"vis":true,"inView":true,"ell":"clip","shell":"B = n₁! = 24 · N = 43/2"}
browser-check	FAIL 375x812 v0.3 hopf: the warning line carries the short form "between shells: shell arithmetic undefined" once, in full, on one line, role degenerate, not ellipsized; the shell readout shows N = 43/2 {"n":1,"t":"between shells: shell arithmetic undefined","lines":2,"cls":"warnline","trunc":false,"vis":true,"inView":true,"ell":"clip","shell":"B = n₁! = 24 · N = 43/2"}
browser-check	FAIL 375x812 v0.3 panels: the warning line carries the short form "between shells: shell arithmetic undefined" once, in full, on one line, role degenerate, not ellipsized; the shell readout shows N = 43/2 {"n":1,"t":"between shells: shell arithmetic undefined","lines":2,"cls":"warnline","trunc":false,"vis":true,"inView":true,"ell":"clip","shell":"B = n₁! = 24 · N = 43/2"}
browser-check	FAIL 375x812 v0.3 step 2 (F2) first screen between shells (N = 11/4, B = 24, φ₃ = 89/4, m = 2, fourier, nothing opened): view frame (393.2-635.2), φ₃ row (to 781.2), s row (to 832.2) and transport (to 874.2) inside the first 812 px {"frame":{"t":393.2,"b":635.2,"vis":true},"html":{"t":0,"b":0,"vis":false},"phi":{"t":724.2,"b":781.2,"vis":true},"s":{"t":783.2,"b":832.2,"vis":true},"tr":{"t":834.2,"b":874.2,"vis":true},"vh":812,"y":0,"shell":"B = n₁! = 24 · N = 11/4","opened":{"phiDrawer":false,"gearDrawer":0,"menu":0,"sinfo":false,"about":0,"exp":false}}
browser-check	FAIL 375x812 v0.3 step 2 (F2) first screen between shells (N = 11/4, B = 24, φ₃ = 89/4, m = 2, clifford, nothing opened): view frame (393.2-635.2), φ₃ row (to 781.2), s row (to 832.2) and transport (to 874.2) inside the first 812 px {"frame":{"t":393.2,"b":635.2,"vis":true},"html":{"t":0,"b":0,"vis":false},"phi":{"t":724.2,"b":781.2,"vis":true},"s":{"t":783.2,"b":832.2,"vis":true},"tr":{"t":834.2,"b":874.2,"vis":true},"vh":812,"y":0,"shell":"B = n₁! = 24 · N = 11/4","opened":{"phiDrawer":false,"gearDrawer":0,"menu":0,"sinfo":false,"about":0,"exp":false}}
browser-check	FAIL 375x812 v0.3 step 2 (F2) first screen between shells (N = 11/4, B = 24, φ₃ = 89/4, m = 2, hopf, nothing opened): view frame (393.2-635.2), φ₃ row (to 781.2), s row (to 832.2) and transport (to 874.2) inside the first 812 px {"frame":{"t":393.2,"b":635.2,"vis":true},"html":{"t":0,"b":0,"vis":false},"phi":{"t":724.2,"b":781.2,"vis":true},"s":{"t":783.2,"b":832.2,"vis":true},"tr":{"t":834.2,"b":874.2,"vis":true},"vh":812,"y":0,"shell":"B = n₁! = 24 · N = 11/4","opened":{"phiDrawer":false,"gearDrawer":0,"menu":0,"sinfo":false,"about":0,"exp":false}}
browser-check	FAIL 375x812 v0.3 step 2 (F2) first screen between shells (N = 11/4, B = 24, φ₃ = 89/4, m = 5, fourier, nothing opened): view frame (393.2-635.2), φ₃ row (to 781.2), s row (to 832.2) and transport (to 874.2) inside the first 812 px {"frame":{"t":393.2,"b":635.2,"vis":true},"html":{"t":0,"b":0,"vis":false},"phi":{"t":724.2,"b":781.2,"vis":true},"s":{"t":783.2,"b":832.2,"vis":true},"tr":{"t":834.2,"b":874.2,"vis":true},"vh":812,"y":0,"shell":"B = n₁! = 24 · N = 11/4","opened":{"phiDrawer":false,"gearDrawer":0,"menu":0,"sinfo":false,"about":0,"exp":false}}
browser-check	FAIL 375x812 v0.3 step 2 (F2) first screen between shells (N = 11/4, B = 24, φ₃ = 89/4, m = 5, clifford, nothing opened): view frame (393.2-635.2), φ₃ row (to 781.2), s row (to 832.2) and transport (to 874.2) inside the first 812 px {"frame":{"t":393.2,"b":635.2,"vis":true},"html":{"t":0,"b":0,"vis":false},"phi":{"t":724.2,"b":781.2,"vis":true},"s":{"t":783.2,"b":832.2,"vis":true},"tr":{"t":834.2,"b":874.2,"vis":true},"vh":812,"y":0,"shell":"B = n₁! = 24 · N = 11/4","opened":{"phiDrawer":false,"gearDrawer":0,"menu":0,"sinfo":false,"about":0,"exp":false}}
browser-check	FAIL 375x812 v0.3 step 2 (F2) first screen between shells (N = 11/4, B = 24, φ₃ = 89/4, m = 5, hopf, nothing opened): view frame (393.2-635.2), φ₃ row (to 781.2), s row (to 832.2) and transport (to 874.2) inside the first 812 px {"frame":{"t":393.2,"b":635.2,"vis":true},"html":{"t":0,"b":0,"vis":false},"phi":{"t":724.2,"b":781.2,"vis":true},"s":{"t":783.2,"b":832.2,"vis":true},"tr":{"t":834.2,"b":874.2,"vis":true},"vh":812,"y":0,"shell":"B = n₁! = 24 · N = 11/4","opened":{"phiDrawer":false,"gearDrawer":0,"menu":0,"sinfo":false,"about":0,"exp":false}}
browser-check	FAIL 375x812 PERF2 clifford release: one full render, view moved, exact JSON hash unchanged by the camera, cards identical, canvas back at full resolution (was 320, now 320) {"full":1,"viewMoved":true,"sha":true,"cardsSame":true,"cvFull":320}
browser-check	FAIL 375x812 PERF2 hopf release: one full render, view moved, exact JSON hash unchanged by the camera, cards identical, canvas back at full resolution (was 320, now 320) {"full":1,"viewMoved":true,"sha":true,"cardsSame":true,"cvFull":320}
browser-check	FAIL 375x812 fourier: visible controls in the instrument panel with (i) excluded <= 40 (addendum 7 F1): 41 (with (i) 43; whole page 47 / 54) {"total":54,"totalNoInfo":47,"inst":43,"instNoInfo":41,"infos":7,"instInfos":2,"buttons":49,"inputs":4,"selects":1,"frame":{"t":357.21875,"b":599.21875,"vis":true},"phi":{"t":688.21875,"b":745.21875,"vis":true},"s":{"t":747.21875,"b":796.21875,"vis":true},"tr":{"t":798.21875,"b":838.21875,"vis":true},"vh":812}
browser-check	FAIL 375x812 fourier first screen: view frame (357-599), phi3 row (to 745), s row (to 796) and transport (to 838) all inside the first 812 px {"total":54,"totalNoInfo":47,"inst":43,"instNoInfo":41,"infos":7,"instInfos":2,"buttons":49,"inputs":4,"selects":1,"frame":{"t":357.21875,"b":599.21875,"vis":true},"phi":{"t":688.21875,"b":745.21875,"vis":true},"s":{"t":747.21875,"b":796.21875,"vis":true},"tr":{"t":798.21875,"b":838.21875,"vis":true},"vh":812}
browser-check	FAIL 375x812 clifford: visible controls in the instrument panel with (i) excluded <= 40 (addendum 7 F1): 41 (with (i) 43; whole page 47 / 54) {"total":54,"totalNoInfo":47,"inst":43,"instNoInfo":41,"infos":7,"instInfos":2,"buttons":49,"inputs":4,"selects":1,"frame":{"t":357.21875,"b":599.21875,"vis":true},"phi":{"t":688.21875,"b":745.21875,"vis":true},"s":{"t":747.21875,"b":796.21875,"vis":true},"tr":{"t":798.21875,"b":838.21875,"vis":true},"vh":812}
browser-check	FAIL 375x812 clifford first screen: view frame (357-599), phi3 row (to 745), s row (to 796) and transport (to 838) all inside the first 812 px {"total":54,"totalNoInfo":47,"inst":43,"instNoInfo":41,"infos":7,"instInfos":2,"buttons":49,"inputs":4,"selects":1,"frame":{"t":357.21875,"b":599.21875,"vis":true},"phi":{"t":688.21875,"b":745.21875,"vis":true},"s":{"t":747.21875,"b":796.21875,"vis":true},"tr":{"t":798.21875,"b":838.21875,"vis":true},"vh":812}
browser-check	FAIL 375x812 hopf: visible controls in the instrument panel with (i) excluded <= 40 (addendum 7 F1): 41 (with (i) 43; whole page 47 / 54) {"total":54,"totalNoInfo":47,"inst":43,"instNoInfo":41,"infos":7,"instInfos":2,"buttons":49,"inputs":4,"selects":1,"frame":{"t":357.21875,"b":599.21875,"vis":true},"phi":{"t":688.21875,"b":745.21875,"vis":true},"s":{"t":747.21875,"b":796.21875,"vis":true},"tr":{"t":798.21875,"b":838.21875,"vis":true},"vh":812}
browser-check	FAIL 375x812 hopf first screen: view frame (357-599), phi3 row (to 745), s row (to 796) and transport (to 838) all inside the first 812 px {"total":54,"totalNoInfo":47,"inst":43,"instNoInfo":41,"infos":7,"instInfos":2,"buttons":49,"inputs":4,"selects":1,"frame":{"t":357.21875,"b":599.21875,"vis":true},"phi":{"t":688.21875,"b":745.21875,"vis":true},"s":{"t":747.21875,"b":796.21875,"vis":true},"tr":{"t":798.21875,"b":838.21875,"vis":true},"vh":812}
browser-check	FAIL panels tab lists 17 placeholder cards
browser-check	FAIL 1280x800 Lift JSON branches equal the old viewer exactRationalLift.branches (c as string); independent of branch visibility
browser-check	FAIL 1280x800 Fourier Layers menu: Teeth, Walk, Amber polygon, Divisors
browser-check	FAIL 1280x800 Guides none: no circles, no swatches; layer swatches only on pressed layers
browser-check	FAIL 1280x800 drawer alpha opens with its presets+slider {"sl":2,"pre":6,"dl":0,"box":2,"steppers":4}
browser-check	FAIL 1280x800 v0.3 the N mode switch (one toggle button, aria-pressed) is in the φ₃ row, not pressed by default ("N∈ℤ"); step 2: the φ₃ label is a chip "φ₃ 23" in the row and no φ₃ box is on the surface (it is in the φ₃ drawer); the instrument panel keeps the cap: 41 visible controls (ⓘ excluded) <= 40 {"inRow":true,"pressed":"false","txt":"N∈ℤ","box":false,"chip":"φ₃ 23"} {"instNoInfo":41,"frame":{"t":265.5,"b":746,"vis":true},"phi":{"t":798,"b":855,"vis":true},"s":{"t":859,"b":908,"vis":true},"tr":{"t":912,"b":952,"vis":true},"vh":800}
browser-check	FAIL 1280x800 v0.3 step 2 (F1): visible controls in the instrument panel in continuous mode (default φ₃, nothing opened, ⓘ excluded): 41 <= 40 {"instNoInfo":41,"frame":{"t":-161.5,"b":319,"vis":true},"phi":{"t":371,"b":428,"vis":true},"s":{"t":432,"b":481,"vis":true},"tr":{"t":485,"b":525,"vis":true},"vh":800}
browser-check	FAIL 1280x800 v0.3 step 2 (F1): visible controls in the instrument panel between shells (N = 43/2, continuous mode, nothing opened, ⓘ excluded): 41 <= 40 {"instNoInfo":41,"frame":{"t":290,"b":770.5,"vis":true},"phi":{"t":822.5,"b":879.5,"vis":true},"s":{"t":883.5,"b":932.5,"vis":true},"tr":{"t":936.5,"b":976.5,"vis":true},"vh":800}
browser-check	FAIL 1280x800 PERF2 clifford release: one full render, view moved, exact JSON hash unchanged by the camera, cards identical, canvas back at full resolution (was 638, now 638) {"full":1,"viewMoved":true,"sha":true,"cardsSame":true,"cvFull":638}
browser-check	FAIL 1280x800 PERF2 hopf release: one full render, view moved, exact JSON hash unchanged by the camera, cards identical, canvas back at full resolution (was 638, now 638) {"full":1,"viewMoved":true,"sha":true,"cardsSame":true,"cvFull":638}
browser-check	FAIL 1280x800 fourier: visible controls in the instrument panel with (i) excluded <= 40 (addendum 7 F1): 41 (with (i) 43; whole page 47 / 54) {"total":54,"totalNoInfo":47,"inst":43,"instNoInfo":41,"infos":7,"instInfos":2,"buttons":49,"inputs":4,"selects":1,"frame":{"t":265.5,"b":746,"vis":true},"phi":{"t":798,"b":855,"vis":true},"s":{"t":859,"b":908,"vis":true},"tr":{"t":912,"b":952,"vis":true},"vh":800}
browser-check	FAIL 1280x800 clifford: visible controls in the instrument panel with (i) excluded <= 40 (addendum 7 F1): 41 (with (i) 43; whole page 47 / 54) {"total":54,"totalNoInfo":47,"inst":43,"instNoInfo":41,"infos":7,"instInfos":2,"buttons":49,"inputs":4,"selects":1,"frame":{"t":265.5,"b":746,"vis":true},"phi":{"t":798,"b":855,"vis":true},"s":{"t":859,"b":908,"vis":true},"tr":{"t":912,"b":952,"vis":true},"vh":800}
browser-check	FAIL 1280x800 hopf: visible controls in the instrument panel with (i) excluded <= 40 (addendum 7 F1): 41 (with (i) 43; whole page 47 / 54) {"total":54,"totalNoInfo":47,"inst":43,"instNoInfo":41,"infos":7,"instInfos":2,"buttons":49,"inputs":4,"selects":1,"frame":{"t":265.5,"b":746,"vis":true},"phi":{"t":798,"b":855,"vis":true},"s":{"t":859,"b":908,"vis":true},"tr":{"t":912,"b":952,"vis":true},"vh":800}
test-core	FAIL fv-build-pins block in dist page equals the sha256 of every inlined module file
test-core	FAIL reference export is readable and is the m=7, N=4, s=4/7 state
test-core	FAIL orbit branches reproduce the export orbitBranches exactly (raw winding, divisor, primitive winding, canonical type, 7 entries)
test-core	FAIL lift branches reproduce exactRationalLift.branches exactly (raw_rate, scale, cleared rate, factor, primitive, closure period, k_c, class, type, chi); c is a string in the new export
test-core	FAIL generated field at the reference state is Q(zeta_14) and the shell reference Q(zeta_24): both equal the export
test-core	FAIL ambient field derived from the definitions (carrier and offset phases separately, brute force) at the reference state is Q(zeta_14); the export states Q(zeta_56): difference recorded, not forced (56 = lcm(14, 2N))
test-core	FAIL phase container equals the frozen export ambient Q(zeta_56) at the reference state, with the full factor 2qN = 2*7*4
test-v041	FAIL unchanged states: the 408-state v0.4 preset grid plus 1,600 random states valid in v0.4 (factorial n₁ 3–6, integer B 2–61, both N modes, N = 0 included) give byte-identical exact export, state export, address, readouts, Lift branches, gates, field line, stop set, step record, fraction-stack caption, numerical model, orbit samples and mirror pairs under the v0.4 and v0.4.1 modules (2008 states compared, 62 with N = 0, 62 differences)
test-v0410	FAIL B4 disk_checks.py ran live (python -I, stdin closed): exit 0, "FAILURES: 0"
test-v0410	FAIL B4 Astra’s orbit, n = 1…30: 124 pairs (n, m), largest m 901 (disk_checks.py: ?): ζ = (k − m − 2n·i)/(k + m + 2), |ζ|² = (k + m − 2)/(k + m + 2), cosh d = (k + m)/2 = (a² + b² + c² + d²)/2, an SL(2, ℤ) matrix with γi = (n + i)/m (independent complex arithmetic), Cayley image of (n + i)/m = ζ, ζ on the Farey edge a/c — b/d, mirror m ↔ k = ζ ↦ −ζ̄; 0 rows equal the script’s printed ζ 
test-v0410	FAIL B6 15 source files byte-identical to v0.4.9 (comb-core, orbit-core, comb-numeric, stack-core, shell-core, ca-core, exact-lib, panel-g-robin, the three tab views, views-common …) host-core/comb-numeric.js,host-core/stack-core.js,instruments/comb-hopf/view-fourier.js,instruments/comb-hopf/view-clifford.js,instruments/comb-hopf/view-hopf.js
test-v0411	FAIL panel-g-robin.js, panel-bd.js and 6 other source files are byte-identical to v0.4.10 host-core/comb-numeric.js
test-v0412	FAIL source files differing from v0.4.11: host-core/comb-numeric.js, host-core/elliptic-exact-core.js, host-core/elliptic-period-core.js, host-core/goldbach-core.js, host-core/rule30-ladder-core.js, instruments/comb-hopf/index.html, instruments/comb-hopf/panel-elliptic.js, instruments/comb-hopf/panel.js, instruments/comb-hopf/view-clifford.js, instruments/comb-hopf/view-fourier.js, instruments/comb-hopf/view-hopf.js host-core/comb-numeric.js,host-core/elliptic-exact-core.js,host-core/elliptic-period-core.js,host-core/goldbach-core.js,host-core/rule30-ladder-core.js,instruments/comb-hopf/index.html,instruments/comb-hopf/panel-elliptic.js,instruments/comb-hopf/panel.js,instruments/comb-hopf/view-clifford.js,instruments/comb-hopf/view-fourier.js,instruments/comb-hopf/view-hopf.js
test-v0413	FAIL source files differing from v0.4.12: host-core/comb-numeric.js, host-core/elliptic-exact-core.js, host-core/elliptic-period-core.js, host-core/goldbach-core.js, host-core/rule30-ladder-core.js, instruments/comb-hopf/index.html, instruments/comb-hopf/panel-elliptic.js, instruments/comb-hopf/panel.js, instruments/comb-hopf/view-clifford.js, instruments/comb-hopf/view-fourier.js, instruments/comb-hopf/view-hopf.js host-core/comb-numeric.js,host-core/elliptic-exact-core.js,host-core/elliptic-period-core.js,host-core/goldbach-core.js,host-core/rule30-ladder-core.js,instruments/comb-hopf/index.html,instruments/comb-hopf/panel-elliptic.js,instruments/comb-hopf/panel.js,instruments/comb-hopf/view-clifford.js,instruments/comb-hopf/view-fourier.js,instruments/comb-hopf/view-hopf.js
test-v042	FAIL Fix 1 scope (source): host-core/comb-core.js differs from v0.4.1 by exactly one added line (the N = 0 branch of wilsonN); every other host-core module and exact-lib file is byte-identical to v0.4.1; instruments/comb-hopf/panel.js differs only in clampPhi (lines 45 and 48); no other instrument file differs (10 files byte-identical; panel.js lines differing: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 298, 299, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 314, 315, 316, 317, 318, 319, 320, 321, 322, 323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 342, 343, 344, 345, 346, 347, 348, 349, 350, 351, 352, 353, 354, 355, 356, 357, 358, 359, 360, 361, 362, 363, 364, 365, 366, 367, 368, 369, 370, 371, 372, 373, 374, 375, 376, 377, 378, 379, 380, 381, 382, 383, 384, 385, 386, 387, 388, 389, 390, 391, 392, 393, 394, 395, 396, 397, 398, 399, 400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 412, 413, 414, 415, 416, 417, 418, 419, 420, 421, 422, 423, 424, 425, 426, 427, 428, 429, 430, 431, 432, 433, 434, 435, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447, 448, 449, 450, 451, 452, 453, 454, 455, 456, 457, 458, 459, 460, 461, 462, 463, 464, 465, 466, 467, 468, 469, 470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523, 524, 525, 526, 527, 528, 529, 530, 531, 532, 533, 534, 535, 536, 537, 538, 539, 540, 541, 542, 543, 544, 545, 546, 547, 548, 549, 550, 551, 552, 553, 554, 555, 556, 557, 558, 559, 560, 561, 562, 563, 564, 565, 566, 567, 568, 569, 570, 571, 572, 573, 574, 575, 576, 577, 578, 579, 580, 581, 582, 583, 584, 585, 586, 587, 588, 589, 590, 591, 592, 593, 594, 595, 596, 597, 598, 599, 600, 601, 602, 603, 604, 605, 606, 607, 608, 609, 610, 611, 612, 613, 614, 615, 616, 617, 618, 619, 620; new host-core files: branch-disk-core.js, ca-core.js, elliptic-exact-core.js, elliptic-period-core.js, goldbach-core.js, rhm-core.js, rule30-ladder-core.js, stack-core.js, test-elliptic-exact.cjs, test-elliptic-period.cjs, test-rule30-ladder.cjs, test-v042.cjs) differing: host-core/comb-numeric.js, host-core/parity-sample.cjs, host-core/test-core.cjs, instruments/comb-hopf/index.html, instruments/comb-hopf/view-clifford.js, instruments/comb-hopf/view-fourier.js, instruments/comb-hopf/view-hopf.js, instruments/comb-hopf/view-panels.js, instruments/comb-hopf/views-common.js
```
</details>

<details><summary>All FAIL lines, v0.4.18 on membrane (final run, run418b)</summary>

```
browser-check-mirror	FAIL 375x812 v0.4 menu inventory: Fourier Layers = Teeth, Walk, Amber polygon, ÷ Divisors, Mirror axis (5); Clifford pressed layers with swatches = leaf, s-orbits, Grid, Mirror axis (4) {"f":["Teeth","Walk","Amber polygon","÷ Divisors","Mirror axis","○ Full stack","○ Fraction stack"],"c":["leaf","orb","grid","mirror"]}
browser-check-mirror	FAIL 1280x800 v0.4 menu inventory: Fourier Layers = Teeth, Walk, Amber polygon, ÷ Divisors, Mirror axis (5); Clifford pressed layers with swatches = leaf, s-orbits, Grid, Mirror axis (4) {"f":["Teeth","Walk","Amber polygon","÷ Divisors","Mirror axis","○ Full stack","○ Fraction stack"],"c":["leaf","orb","grid","mirror"]}
browser-check-v041	FAIL 375x812 n1_1 fourier: renders without a refusal or error, first screen holds (transport bottom 838 ≤ 812), no visible text below 13 px (smallest 13.000) {"L":{"tr":838.21875,"vh":812,"status":"","svg":31},"bad":[]}
browser-check-v041	FAIL 375x812 n1_2 fourier: renders without a refusal or error, first screen holds (transport bottom 838 ≤ 812), no visible text below 13 px (smallest 13.000) {"L":{"tr":838.21875,"vh":812,"status":"","svg":40},"bad":[]}
browser-check-v041	FAIL 375x812 n1_1_continuous fourier: renders without a refusal or error, first screen holds (transport bottom 874 ≤ 812), no visible text below 13 px (smallest 13.000) {"L":{"tr":874.21875,"vh":812,"status":"","svg":34},"bad":[]}
browser-check-v041	FAIL 375x812 B1_integer fourier: renders without a refusal or error, first screen holds (transport bottom 838 ≤ 812), no visible text below 13 px (smallest 13.000) {"L":{"tr":838.21875,"vh":812,"status":"","svg":32},"bad":[]}
browser-check-v0410	FAIL 1280x800 byte-identical to v0.4.9 for 28 states (incl. tilt −1/2): stage, canvas, caption, about, cards, address, hash, state AND exact JSON, state JSON, CSV, Lift JSON, stats (28/28 exports); Panels tab (8 states) differs only by the two new collapsed card elements (0) panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3=1&m=8&t1= hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3=1&m=8&t1= hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=49&nMode=integer&phi3=0&m=15&t1=1&t hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=49&nMode=integer&phi3=0&m=15&t1=1&t hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=9&nMode=integer&phi3=0&m=7&t1=1&t2= hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=9&nMode=integer&phi3=0&m=7&t1=1&t2= hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=5040&nMode=integer&phi3=12&m=9&t1=1 hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=5040&nMode=integer&phi3=12&m=9&t1=1 hstage(2)
browser-check-v0410	FAIL 1280x800 both cards present in group B after the G. Robin card, adjacent, and collapsed on a fresh page; all other cards unchanged (open) orbit-point-index:true contact-sweep:true tooth-contacts:true basel-cone:true reciprocal-record:true pi-b-shell:true g-robin-margin:true branch-primitivity:false poincare-disk:false cayley-m3:true m4-atom:true m5-structure:true m6-walk:true m7-divisor-atom:true mcomb-elliptic-bsd:true carrier-addition:true exact-curve-bsd:true clifford-elliptic-bridge:true arithmetic-fourier:true elliptic-points-exact:false period-lattice-exact:false pen-curvature-exact:false pen-sphere-exact:false
browser-check-v0410	FAIL 375x812 byte-identical to v0.4.9 for 28 states (incl. tilt −1/2): stage, canvas, caption, about, cards, address, hash, state AND exact JSON, state JSON, CSV, Lift JSON, stats (28/28 exports); Panels tab (8 states) differs only by the two new collapsed card elements (0) panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3=1&m=8&t1= hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3=1&m=8&t1= hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=49&nMode=integer&phi3=0&m=15&t1=1&t hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=49&nMode=integer&phi3=0&m=15&t1=1&t hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=9&nMode=integer&phi3=0&m=7&t1=1&t2= hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=9&nMode=integer&phi3=0&m=7&t1=1&t2= hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=5040&nMode=integer&phi3=12&m=9&t1=1 hstage(2) | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=5040&nMode=integer&phi3=12&m=9&t1=1 hstage(2)
browser-check-v0410	FAIL 375x812 both cards present in group B after the G. Robin card, adjacent, and collapsed on a fresh page; all other cards unchanged (open) orbit-point-index:true contact-sweep:true tooth-contacts:true basel-cone:true reciprocal-record:true pi-b-shell:true g-robin-margin:true branch-primitivity:false poincare-disk:false cayley-m3:true m4-atom:true m5-structure:true m6-walk:true m7-divisor-atom:true mcomb-elliptic-bsd:true carrier-addition:true exact-curve-bsd:true clifford-elliptic-bridge:true arithmetic-fourier:true elliptic-points-exact:false period-lattice-exact:false pen-curvature-exact:false pen-sphere-exact:false
browser-check-v0411	FAIL 1280x800 byte-identical to v0.4.10 for 32 states (incl. tilt −1/2, stack on / reciprocal off): stage, canvas, caption, about, cards, address, hash AND exact JSON, state JSON, CSV, Lift JSON, stats (32/32 exports) panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3 hstage | panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3 hstage | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=9&nMode=integer&phi3=0&m= hstage | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=9&nMode=integer&phi3=0&m= hstage
browser-check-v0411	FAIL 375x812 byte-identical to v0.4.10 for 32 states (incl. tilt −1/2, stack on / reciprocal off): stage, canvas, caption, about, cards, address, hash AND exact JSON, state JSON, CSV, Lift JSON, stats (32/32 exports) panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3 hstage | panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3 hstage | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=9&nMode=integer&phi3=0&m= hstage | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=9&nMode=integer&phi3=0&m= hstage
browser-check-v0412	FAIL 1280x800 fl off: byte-identical to v0.4.11 for 34 states (incl. tilt −1/2, stack / reciprocal / fraction on): stage, canvas, caption, about, cards, address, hash AND exact JSON, state JSON, CSV, Lift JSON, stats (34/34 exports) panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3 hstage | panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3 hstage
browser-check-v0412	FAIL 375x812 fl off: byte-identical to v0.4.11 for 34 states (incl. tilt −1/2, stack / reciprocal / fraction on): stage, canvas, caption, about, cards, address, hash AND exact JSON, state JSON, CSV, Lift JSON, stats (34/34 exports) panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3 hstage | panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3 hstage
browser-check-v0413	FAIL 1280x800 fl off: byte-identical to v0.4.12 for 36 states (tilt -1/2 too): stage, canvas, caption, about, cards, address, hash and the five exports (36/36) panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3 hstage | panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3 hstage
browser-check-v0413	FAIL 375x812 fl off: byte-identical to v0.4.12 for 36 states (tilt -1/2 too): stage, canvas, caption, about, cards, address, hash and the five exports (36/36) panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3 hstage | panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=integer&phi3 hstage
browser-check-v0414	FAIL 1280x800 track off: byte-identical to v0.4.13 for 32 states (incl. the Goldbach shells without the flag, tilt −1/2 too): stage, canvas, caption, about, cards, address, hash and the five exports (32/32) panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=in hstage | panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=in hstage | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=11&nMode=intege hstage | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=11&nMode=intege hstage
browser-check-v0414	FAIL 375x812 track off: byte-identical to v0.4.13 for 32 states (incl. the Goldbach shells without the flag, tilt −1/2 too): stage, canvas, caption, about, cards, address, hash and the five exports (32/32) panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=in hstage | panels #v=fv-comb-hopf/0.2&shellMode=factorial&n1=7&B=5040&nMode=in hstage | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=11&nMode=intege hstage | panels #v=fv-comb-hopf/0.2&shellMode=integer&n1=4&B=11&nMode=intege hstage
browser-check-v0417	FAIL 1280x800 identical to v0.4.16 on 6 states (stage, caption, cards, address, html stage); on the Panels tab the only difference is the two new card elements {"tab":"panels"} new=2 | {"tab":"panels","shellMode":"integer","B":"24"} new=2
browser-check-v0417	FAIL 1280x800 both cards in group D after the legacy D placeholders, adjacent, collapsed on a fresh page (23 cards) orbit-point-index:true:true contact-sweep:true:true tooth-contacts:true:true basel-cone:true:true reciprocal-record:true:true pi-b-shell:true:true g-robin-margin:true:false branch-primitivity:false:false poincare-disk:false:false cayley-m3:true:true m4-atom:true:true m5-structure:true:true m6-walk:true:true m7-divisor-atom:true:true mcomb-elliptic-bsd:true:true carrier-addition:true:true exact-curve-bsd:true:true clifford-elliptic-bridge:true:true arithmetic-fourier:true:true elliptic-points-exact:false:false period-lattice-exact:false:false pen-curvature-exact:false:false pen-sphere-exact:false:false
browser-check-v0417	FAIL 375x812 identical to v0.4.16 on 6 states (stage, caption, cards, address, html stage); on the Panels tab the only difference is the two new card elements {"tab":"panels"} new=2 | {"tab":"panels","shellMode":"integer","B":"24"} new=2
browser-check-v0417	FAIL 375x812 both cards in group D after the legacy D placeholders, adjacent, collapsed on a fresh page (23 cards) orbit-point-index:true:true contact-sweep:true:true tooth-contacts:true:true basel-cone:true:true reciprocal-record:true:true pi-b-shell:true:true g-robin-margin:true:false branch-primitivity:false:false poincare-disk:false:false cayley-m3:true:true m4-atom:true:true m5-structure:true:true m6-walk:true:true m7-divisor-atom:true:true mcomb-elliptic-bsd:true:true carrier-addition:true:true exact-curve-bsd:true:true clifford-elliptic-bridge:true:true arithmetic-fourier:true:true elliptic-points-exact:false:false period-lattice-exact:false:false pen-curvature-exact:false:false pen-sphere-exact:false:false
browser-check-v044	FAIL 1280x800 the preset menu lists exactly 2,6,12,60,120,360,2520,5040,55440,720720
browser-check-v044	FAIL 1280x800 layout B=55440: 23 value cells in C1/C2/constants lie inside their card, are >= 40% of the card inner width (or on their own row), no single-character lines, no page scroll {"bad":["rhm-c1 single-character line in [−0.071310031214214456408696, "],"cells":23,"sw":1265,"iw":1280}
browser-check-v044	FAIL 1280x800 layout B=720720: 23 value cells in C1/C2/constants lie inside their card, are >= 40% of the card inner width (or on their own row), no single-character lines, no page scroll {"bad":["rhm-c1 single-character line in [−0.124904813854560748862942, "],"cells":23,"sw":1265,"iw":1280}
browser-check-v044	FAIL 1280x800 exactly 16 other Panels cards remain placeholders ("not yet rebuilt"); the g-robin card is not one
browser-check-v044	FAIL 375x812 the preset menu lists exactly 2,6,12,60,120,360,2520,5040,55440,720720
browser-check-v044	FAIL 375x812 exactly 16 other Panels cards remain placeholders ("not yet rebuilt"); the g-robin card is not one
browser-check-v047	FAIL 1280x800 t1*s in Z: tilt 0 caption "★ lab sum real"; tilt 1 caption "★ pair phases conjugate (t₁·s ∈ ℤ); tilted walk not real in general" ALIGN yes · SPREAD yes ★ lab sum real · Q-res 0.0e+0 (numerical) · mirror axis = real axis (t₁·s ∈ ℤ) || ALIGN yes · SPREAD yes ★ teeth conjugate (t₁·s ∈ ℤ); walk not real · Q-res 6.0e+0 (numerical) · mirror axis = real axis (t₁·s ∈ ℤ)
browser-check-v047	FAIL 375x812 t1*s in Z: tilt 0 caption "★ lab sum real"; tilt 1 caption "★ pair phases conjugate (t₁·s ∈ ℤ); tilted walk not real in general" ALIGN yes · SPREAD yes ★ lab sum real · Q-res 0.0e+0 (numerical) · mirror axis = real axis (t₁·s ∈ ℤ) || ALIGN yes · SPREAD yes ★ teeth conjugate (t₁·s ∈ ℤ); walk not real · Q-res 6.0e+0 (numerical) · mirror axis = real axis (t₁·s ∈ ℤ)
browser-check-v048	FAIL 1280x800 tilt -1: Q-res part "Q-res x (numerical)" fully visible (not cut by the ellipsis) ALIGN yes · SPREAD no ★ teeth conjugate (t₁·s ∈ ℤ); walk not real · Q-res 6.1e+0 (numerical) · mirror axis = real axis (t₁·s ∈ ℤ)
browser-check-v048	FAIL 1280x800 tilt -3/5: Q-res part "Q-res x (numerical)" fully visible (not cut by the ellipsis) ALIGN yes · SPREAD no ★ teeth conjugate (t₁·s ∈ ℤ); walk not real · Q-res 5.2e+0 (numerical) · mirror axis = real axis (t₁·s ∈ ℤ)
browser-check-v048	FAIL 1280x800 tilt 1: Q-res part "Q-res x (numerical)" fully visible (not cut by the ellipsis) ALIGN yes · SPREAD no ★ teeth conjugate (t₁·s ∈ ℤ); walk not real · Q-res 5.3e+1 (numerical) · mirror axis = real axis (t₁·s ∈ ℤ)
browser-check	FAIL 375x812 Lift JSON branches equal the old viewer exactRationalLift.branches (c as string); independent of branch visibility
browser-check	FAIL 375x812 Fourier Layers menu: Teeth, Walk, Amber polygon, Divisors
browser-check	FAIL 375x812 Guides none: no circles, no swatches; layer swatches only on pressed layers
browser-check	FAIL 375x812 drawer alpha opens with its presets+slider {"sl":2,"pre":6,"dl":0,"box":2,"steppers":4}
browser-check	FAIL 375x812 v0.3 the N mode switch (one toggle button, aria-pressed) is in the φ₃ row, not pressed by default ("N∈ℤ"); step 2: the φ₃ label is a chip "φ₃ 23" in the row and no φ₃ box is on the surface (it is in the φ₃ drawer); the instrument panel keeps the cap: 41 visible controls (ⓘ excluded) <= 40 {"inRow":true,"pressed":"false","txt":"N∈ℤ","box":false,"chip":"φ₃ 23"} {"instNoInfo":41,"frame":{"t":357.21875,"b":599.21875,"vis":true},"phi":{"t":688.21875,"b":745.21875,"vis":true},"s":{"t":747.21875,"b":796.21875,"vis":true},"tr":{"t":798.21875,"b":838.21875,"vis":true},"vh":812}
browser-check	FAIL 375x812 v0.3 step 2 (F1): visible controls in the instrument panel in continuous mode (default φ₃, nothing opened, ⓘ excluded): 41 <= 40 {"instNoInfo":41,"frame":{"t":357.21875,"b":599.21875,"vis":true},"phi":{"t":688.21875,"b":745.21875,"vis":true},"s":{"t":747.21875,"b":796.21875,"vis":true},"tr":{"t":798.21875,"b":838.21875,"vis":true},"vh":812}
browser-check	FAIL 375x812 v0.3 first screen in integer mode (default φ₃): view frame, φ₃ row (to 745), s row (to 796) and transport (to 838) inside the first 812 px {"instNoInfo":41,"frame":{"t":357.21875,"b":599.21875,"vis":true},"phi":{"t":688.21875,"b":745.21875,"vis":true},"s":{"t":747.21875,"b":796.21875,"vis":true},"tr":{"t":798.21875,"b":838.21875,"vis":true},"vh":812}
browser-check	FAIL 375x812 v0.3 first screen in continuous mode (default φ₃): view frame, φ₃ row (to 745), s row (to 796) and transport (to 838) inside the first 812 px {"instNoInfo":41,"frame":{"t":357.21875,"b":599.21875,"vis":true},"phi":{"t":688.21875,"b":745.21875,"vis":true},"s":{"t":747.21875,"b":796.21875,"vis":true},"tr":{"t":798.21875,"b":838.21875,"vis":true},"vh":812}
browser-check	FAIL 375x812 v0.3 step 2 (F1): visible controls in the instrument panel between shells (N = 43/2, continuous mode, nothing opened, ⓘ excluded): 41 <= 40 {"instNoInfo":41,"frame":{"t":393.21875,"b":635.21875,"vis":true},"phi":{"t":724.21875,"b":781.21875,"vis":true},"s":{"t":783.21875,"b":832.21875,"vis":true},"tr":{"t":834.21875,"b":874.21875,"vis":true},"vh":812}
browser-check	FAIL 375x812 v0.3 fourier: the warning line carries the short form "between shells: shell arithmetic undefined" once, in full, on one line, role degenerate, not ellipsized; the shell readout shows N = 43/2 {"n":1,"t":"between shells: shell arithmetic undefined","lines":2,"cls":"warnline","trunc":false,"vis":true,"inView":true,"ell":"clip","shell":"B = n₁! = 24 · N = 43/2"}
browser-check	FAIL 375x812 v0.3 clifford: the warning line carries the short form "between shells: shell arithmetic undefined" once, in full, on one line, role degenerate, not ellipsized; the shell readout shows N = 43/2 {"n":1,"t":"between shells: shell arithmetic undefined","lines":2,"cls":"warnline","trunc":false,"vis":true,"inView":true,"ell":"clip","shell":"B = n₁! = 24 · N = 43/2"}
browser-check	FAIL 375x812 v0.3 hopf: the warning line carries the short form "between shells: shell arithmetic undefined" once, in full, on one line, role degenerate, not ellipsized; the shell readout shows N = 43/2 {"n":1,"t":"between shells: shell arithmetic undefined","lines":2,"cls":"warnline","trunc":false,"vis":true,"inView":true,"ell":"clip","shell":"B = n₁! = 24 · N = 43/2"}
browser-check	FAIL 375x812 v0.3 panels: the warning line carries the short form "between shells: shell arithmetic undefined" once, in full, on one line, role degenerate, not ellipsized; the shell readout shows N = 43/2 {"n":1,"t":"between shells: shell arithmetic undefined","lines":2,"cls":"warnline","trunc":false,"vis":true,"inView":true,"ell":"clip","shell":"B = n₁! = 24 · N = 43/2"}
browser-check	FAIL 375x812 v0.3 step 2 (F2) first screen between shells (N = 11/4, B = 24, φ₃ = 89/4, m = 2, fourier, nothing opened): view frame (393.2-635.2), φ₃ row (to 781.2), s row (to 832.2) and transport (to 874.2) inside the first 812 px {"frame":{"t":393.2,"b":635.2,"vis":true},"html":{"t":0,"b":0,"vis":false},"phi":{"t":724.2,"b":781.2,"vis":true},"s":{"t":783.2,"b":832.2,"vis":true},"tr":{"t":834.2,"b":874.2,"vis":true},"vh":812,"y":0,"shell":"B = n₁! = 24 · N = 11/4","opened":{"phiDrawer":false,"gearDrawer":0,"menu":0,"sinfo":false,"about":0,"exp":false}}
browser-check	FAIL 375x812 v0.3 step 2 (F2) first screen between shells (N = 11/4, B = 24, φ₃ = 89/4, m = 2, clifford, nothing opened): view frame (393.2-635.2), φ₃ row (to 781.2), s row (to 832.2) and transport (to 874.2) inside the first 812 px {"frame":{"t":393.2,"b":635.2,"vis":true},"html":{"t":0,"b":0,"vis":false},"phi":{"t":724.2,"b":781.2,"vis":true},"s":{"t":783.2,"b":832.2,"vis":true},"tr":{"t":834.2,"b":874.2,"vis":true},"vh":812,"y":0,"shell":"B = n₁! = 24 · N = 11/4","opened":{"phiDrawer":false,"gearDrawer":0,"menu":0,"sinfo":false,"about":0,"exp":false}}
browser-check	FAIL 375x812 v0.3 step 2 (F2) first screen between shells (N = 11/4, B = 24, φ₃ = 89/4, m = 2, hopf, nothing opened): view frame (393.2-635.2), φ₃ row (to 781.2), s row (to 832.2) and transport (to 874.2) inside the first 812 px {"frame":{"t":393.2,"b":635.2,"vis":true},"html":{"t":0,"b":0,"vis":false},"phi":{"t":724.2,"b":781.2,"vis":true},"s":{"t":783.2,"b":832.2,"vis":true},"tr":{"t":834.2,"b":874.2,"vis":true},"vh":812,"y":0,"shell":"B = n₁! = 24 · N = 11/4","opened":{"phiDrawer":false,"gearDrawer":0,"menu":0,"sinfo":false,"about":0,"exp":false}}
browser-check	FAIL 375x812 v0.3 step 2 (F2) first screen between shells (N = 11/4, B = 24, φ₃ = 89/4, m = 5, fourier, nothing opened): view frame (393.2-635.2), φ₃ row (to 781.2), s row (to 832.2) and transport (to 874.2) inside the first 812 px {"frame":{"t":393.2,"b":635.2,"vis":true},"html":{"t":0,"b":0,"vis":false},"phi":{"t":724.2,"b":781.2,"vis":true},"s":{"t":783.2,"b":832.2,"vis":true},"tr":{"t":834.2,"b":874.2,"vis":true},"vh":812,"y":0,"shell":"B = n₁! = 24 · N = 11/4","opened":{"phiDrawer":false,"gearDrawer":0,"menu":0,"sinfo":false,"about":0,"exp":false}}
browser-check	FAIL 375x812 v0.3 step 2 (F2) first screen between shells (N = 11/4, B = 24, φ₃ = 89/4, m = 5, clifford, nothing opened): view frame (393.2-635.2), φ₃ row (to 781.2), s row (to 832.2) and transport (to 874.2) inside the first 812 px {"frame":{"t":393.2,"b":635.2,"vis":true},"html":{"t":0,"b":0,"vis":false},"phi":{"t":724.2,"b":781.2,"vis":true},"s":{"t":783.2,"b":832.2,"vis":true},"tr":{"t":834.2,"b":874.2,"vis":true},"vh":812,"y":0,"shell":"B = n₁! = 24 · N = 11/4","opened":{"phiDrawer":false,"gearDrawer":0,"menu":0,"sinfo":false,"about":0,"exp":false}}
browser-check	FAIL 375x812 v0.3 step 2 (F2) first screen between shells (N = 11/4, B = 24, φ₃ = 89/4, m = 5, hopf, nothing opened): view frame (393.2-635.2), φ₃ row (to 781.2), s row (to 832.2) and transport (to 874.2) inside the first 812 px {"frame":{"t":393.2,"b":635.2,"vis":true},"html":{"t":0,"b":0,"vis":false},"phi":{"t":724.2,"b":781.2,"vis":true},"s":{"t":783.2,"b":832.2,"vis":true},"tr":{"t":834.2,"b":874.2,"vis":true},"vh":812,"y":0,"shell":"B = n₁! = 24 · N = 11/4","opened":{"phiDrawer":false,"gearDrawer":0,"menu":0,"sinfo":false,"about":0,"exp":false}}
browser-check	FAIL 375x812 PERF2 clifford release: one full render, view moved, exact JSON hash unchanged by the camera, cards identical, canvas back at full resolution (was 320, now 320) {"full":1,"viewMoved":true,"sha":true,"cardsSame":true,"cvFull":320}
browser-check	FAIL 375x812 PERF2 hopf release: one full render, view moved, exact JSON hash unchanged by the camera, cards identical, canvas back at full resolution (was 320, now 320) {"full":1,"viewMoved":true,"sha":true,"cardsSame":true,"cvFull":320}
browser-check	FAIL 375x812 fourier: visible controls in the instrument panel with (i) excluded <= 40 (addendum 7 F1): 41 (with (i) 43; whole page 47 / 54) {"total":54,"totalNoInfo":47,"inst":43,"instNoInfo":41,"infos":7,"instInfos":2,"buttons":49,"inputs":4,"selects":1,"frame":{"t":357.21875,"b":599.21875,"vis":true},"phi":{"t":688.21875,"b":745.21875,"vis":true},"s":{"t":747.21875,"b":796.21875,"vis":true},"tr":{"t":798.21875,"b":838.21875,"vis":true},"vh":812}
browser-check	FAIL 375x812 fourier first screen: view frame (357-599), phi3 row (to 745), s row (to 796) and transport (to 838) all inside the first 812 px {"total":54,"totalNoInfo":47,"inst":43,"instNoInfo":41,"infos":7,"instInfos":2,"buttons":49,"inputs":4,"selects":1,"frame":{"t":357.21875,"b":599.21875,"vis":true},"phi":{"t":688.21875,"b":745.21875,"vis":true},"s":{"t":747.21875,"b":796.21875,"vis":true},"tr":{"t":798.21875,"b":838.21875,"vis":true},"vh":812}
browser-check	FAIL 375x812 clifford: visible controls in the instrument panel with (i) excluded <= 40 (addendum 7 F1): 41 (with (i) 43; whole page 47 / 54) {"total":54,"totalNoInfo":47,"inst":43,"instNoInfo":41,"infos":7,"instInfos":2,"buttons":49,"inputs":4,"selects":1,"frame":{"t":357.21875,"b":599.21875,"vis":true},"phi":{"t":688.21875,"b":745.21875,"vis":true},"s":{"t":747.21875,"b":796.21875,"vis":true},"tr":{"t":798.21875,"b":838.21875,"vis":true},"vh":812}
browser-check	FAIL 375x812 clifford first screen: view frame (357-599), phi3 row (to 745), s row (to 796) and transport (to 838) all inside the first 812 px {"total":54,"totalNoInfo":47,"inst":43,"instNoInfo":41,"infos":7,"instInfos":2,"buttons":49,"inputs":4,"selects":1,"frame":{"t":357.21875,"b":599.21875,"vis":true},"phi":{"t":688.21875,"b":745.21875,"vis":true},"s":{"t":747.21875,"b":796.21875,"vis":true},"tr":{"t":798.21875,"b":838.21875,"vis":true},"vh":812}
browser-check	FAIL 375x812 hopf: visible controls in the instrument panel with (i) excluded <= 40 (addendum 7 F1): 41 (with (i) 43; whole page 47 / 54) {"total":54,"totalNoInfo":47,"inst":43,"instNoInfo":41,"infos":7,"instInfos":2,"buttons":49,"inputs":4,"selects":1,"frame":{"t":357.21875,"b":599.21875,"vis":true},"phi":{"t":688.21875,"b":745.21875,"vis":true},"s":{"t":747.21875,"b":796.21875,"vis":true},"tr":{"t":798.21875,"b":838.21875,"vis":true},"vh":812}
browser-check	FAIL 375x812 hopf first screen: view frame (357-599), phi3 row (to 745), s row (to 796) and transport (to 838) all inside the first 812 px {"total":54,"totalNoInfo":47,"inst":43,"instNoInfo":41,"infos":7,"instInfos":2,"buttons":49,"inputs":4,"selects":1,"frame":{"t":357.21875,"b":599.21875,"vis":true},"phi":{"t":688.21875,"b":745.21875,"vis":true},"s":{"t":747.21875,"b":796.21875,"vis":true},"tr":{"t":798.21875,"b":838.21875,"vis":true},"vh":812}
browser-check	FAIL panels tab lists 17 placeholder cards
browser-check	FAIL 1280x800 Lift JSON branches equal the old viewer exactRationalLift.branches (c as string); independent of branch visibility
browser-check	FAIL 1280x800 Fourier Layers menu: Teeth, Walk, Amber polygon, Divisors
browser-check	FAIL 1280x800 Guides none: no circles, no swatches; layer swatches only on pressed layers
browser-check	FAIL 1280x800 drawer alpha opens with its presets+slider {"sl":2,"pre":6,"dl":0,"box":2,"steppers":4}
browser-check	FAIL 1280x800 v0.3 the N mode switch (one toggle button, aria-pressed) is in the φ₃ row, not pressed by default ("N∈ℤ"); step 2: the φ₃ label is a chip "φ₃ 23" in the row and no φ₃ box is on the surface (it is in the φ₃ drawer); the instrument panel keeps the cap: 41 visible controls (ⓘ excluded) <= 40 {"inRow":true,"pressed":"false","txt":"N∈ℤ","box":false,"chip":"φ₃ 23"} {"instNoInfo":41,"frame":{"t":265.5,"b":746,"vis":true},"phi":{"t":798,"b":855,"vis":true},"s":{"t":859,"b":908,"vis":true},"tr":{"t":912,"b":952,"vis":true},"vh":800}
browser-check	FAIL 1280x800 v0.3 step 2 (F1): visible controls in the instrument panel in continuous mode (default φ₃, nothing opened, ⓘ excluded): 41 <= 40 {"instNoInfo":41,"frame":{"t":-161.5,"b":319,"vis":true},"phi":{"t":371,"b":428,"vis":true},"s":{"t":432,"b":481,"vis":true},"tr":{"t":485,"b":525,"vis":true},"vh":800}
browser-check	FAIL 1280x800 v0.3 step 2 (F1): visible controls in the instrument panel between shells (N = 43/2, continuous mode, nothing opened, ⓘ excluded): 41 <= 40 {"instNoInfo":41,"frame":{"t":290,"b":770.5,"vis":true},"phi":{"t":822.5,"b":879.5,"vis":true},"s":{"t":883.5,"b":932.5,"vis":true},"tr":{"t":936.5,"b":976.5,"vis":true},"vh":800}
browser-check	FAIL 1280x800 PERF2 clifford release: one full render, view moved, exact JSON hash unchanged by the camera, cards identical, canvas back at full resolution (was 638, now 638) {"full":1,"viewMoved":true,"sha":true,"cardsSame":true,"cvFull":638}
browser-check	FAIL 1280x800 PERF2 hopf release: one full render, view moved, exact JSON hash unchanged by the camera, cards identical, canvas back at full resolution (was 638, now 638) {"full":1,"viewMoved":true,"sha":true,"cardsSame":true,"cvFull":638}
browser-check	FAIL 1280x800 fourier: visible controls in the instrument panel with (i) excluded <= 40 (addendum 7 F1): 41 (with (i) 43; whole page 47 / 54) {"total":54,"totalNoInfo":47,"inst":43,"instNoInfo":41,"infos":7,"instInfos":2,"buttons":49,"inputs":4,"selects":1,"frame":{"t":265.5,"b":746,"vis":true},"phi":{"t":798,"b":855,"vis":true},"s":{"t":859,"b":908,"vis":true},"tr":{"t":912,"b":952,"vis":true},"vh":800}
browser-check	FAIL 1280x800 clifford: visible controls in the instrument panel with (i) excluded <= 40 (addendum 7 F1): 41 (with (i) 43; whole page 47 / 54) {"total":54,"totalNoInfo":47,"inst":43,"instNoInfo":41,"infos":7,"instInfos":2,"buttons":49,"inputs":4,"selects":1,"frame":{"t":265.5,"b":746,"vis":true},"phi":{"t":798,"b":855,"vis":true},"s":{"t":859,"b":908,"vis":true},"tr":{"t":912,"b":952,"vis":true},"vh":800}
browser-check	FAIL 1280x800 hopf: visible controls in the instrument panel with (i) excluded <= 40 (addendum 7 F1): 41 (with (i) 43; whole page 47 / 54) {"total":54,"totalNoInfo":47,"inst":43,"instNoInfo":41,"infos":7,"instInfos":2,"buttons":49,"inputs":4,"selects":1,"frame":{"t":265.5,"b":746,"vis":true},"phi":{"t":798,"b":855,"vis":true},"s":{"t":859,"b":908,"vis":true},"tr":{"t":912,"b":952,"vis":true},"vh":800}
test-core	FAIL fv-build-pins block in dist page equals the sha256 of every inlined module file
test-core	FAIL reference export is readable and is the m=7, N=4, s=4/7 state
test-core	FAIL orbit branches reproduce the export orbitBranches exactly (raw winding, divisor, primitive winding, canonical type, 7 entries)
test-core	FAIL lift branches reproduce exactRationalLift.branches exactly (raw_rate, scale, cleared rate, factor, primitive, closure period, k_c, class, type, chi); c is a string in the new export
test-core	FAIL generated field at the reference state is Q(zeta_14) and the shell reference Q(zeta_24): both equal the export
test-core	FAIL ambient field derived from the definitions (carrier and offset phases separately, brute force) at the reference state is Q(zeta_14); the export states Q(zeta_56): difference recorded, not forced (56 = lcm(14, 2N))
test-core	FAIL phase container equals the frozen export ambient Q(zeta_56) at the reference state, with the full factor 2qN = 2*7*4
test-v041	FAIL unchanged states: the 408-state v0.4 preset grid plus 1,600 random states valid in v0.4 (factorial n₁ 3–6, integer B 2–61, both N modes, N = 0 included) give byte-identical exact export, state export, address, readouts, Lift branches, gates, field line, stop set, step record, fraction-stack caption, numerical model, orbit samples and mirror pairs under the v0.4 and v0.4.1 modules (2008 states compared, 62 with N = 0, 62 differences)
test-v0410	FAIL B4 disk_checks.py ran live (python -I, stdin closed): exit 0, "FAILURES: 0"
test-v0410	FAIL B4 Astra’s orbit, n = 1…30: 124 pairs (n, m), largest m 901 (disk_checks.py: ?): ζ = (k − m − 2n·i)/(k + m + 2), |ζ|² = (k + m − 2)/(k + m + 2), cosh d = (k + m)/2 = (a² + b² + c² + d²)/2, an SL(2, ℤ) matrix with γi = (n + i)/m (independent complex arithmetic), Cayley image of (n + i)/m = ζ, ζ on the Farey edge a/c — b/d, mirror m ↔ k = ζ ↦ −ζ̄; 0 rows equal the script’s printed ζ 
test-v0410	FAIL B6 15 source files byte-identical to v0.4.9 (comb-core, orbit-core, comb-numeric, stack-core, shell-core, ca-core, exact-lib, panel-g-robin, the three tab views, views-common …) host-core/comb-numeric.js,host-core/stack-core.js,instruments/comb-hopf/view-fourier.js,instruments/comb-hopf/view-clifford.js,instruments/comb-hopf/view-hopf.js
test-v0411	FAIL panel-g-robin.js, panel-bd.js and 6 other source files are byte-identical to v0.4.10 host-core/comb-numeric.js,instruments/comb-hopf/view-panels.js
test-v0412	FAIL source files differing from v0.4.11: host-core/comb-numeric.js, host-core/elliptic-exact-core.js, host-core/elliptic-period-core.js, host-core/field-q2-q5-tau.js, host-core/goldbach-core.js, host-core/pen-curvature-core.js, host-core/pen-interval-core.js, host-core/pen-sphere-core.js, host-core/pen-streams-core.js, host-core/rule30-ladder-core.js, instruments/comb-hopf/index.html, instruments/comb-hopf/panel-elliptic.js, instruments/comb-hopf/panel-pens.js, instruments/comb-hopf/panel.js, instruments/comb-hopf/view-clifford.js, instruments/comb-hopf/view-fourier.js, instruments/comb-hopf/view-hopf.js, instruments/comb-hopf/view-panels.js host-core/comb-numeric.js,host-core/elliptic-exact-core.js,host-core/elliptic-period-core.js,host-core/field-q2-q5-tau.js,host-core/goldbach-core.js,host-core/pen-curvature-core.js,host-core/pen-interval-core.js,host-core/pen-sphere-core.js,host-core/pen-streams-core.js,host-core/rule30-ladder-core.js,instruments/comb-hopf/index.html,instruments/comb-hopf/panel-elliptic.js,instruments/comb-hopf/panel-pens.js,instruments/comb-hopf/panel.js,instruments/comb-hopf/view-clifford.js,instruments/comb-hopf/view-fourier.js,instruments/comb-hopf/view-hopf.js,instruments/comb-hopf/view-panels.js
test-v0413	FAIL source files differing from v0.4.12: host-core/comb-numeric.js, host-core/elliptic-exact-core.js, host-core/elliptic-period-core.js, host-core/field-q2-q5-tau.js, host-core/goldbach-core.js, host-core/pen-curvature-core.js, host-core/pen-interval-core.js, host-core/pen-sphere-core.js, host-core/pen-streams-core.js, host-core/rule30-ladder-core.js, instruments/comb-hopf/index.html, instruments/comb-hopf/panel-elliptic.js, instruments/comb-hopf/panel-pens.js, instruments/comb-hopf/panel.js, instruments/comb-hopf/view-clifford.js, instruments/comb-hopf/view-fourier.js, instruments/comb-hopf/view-hopf.js, instruments/comb-hopf/view-panels.js host-core/comb-numeric.js,host-core/elliptic-exact-core.js,host-core/elliptic-period-core.js,host-core/field-q2-q5-tau.js,host-core/goldbach-core.js,host-core/pen-curvature-core.js,host-core/pen-interval-core.js,host-core/pen-sphere-core.js,host-core/pen-streams-core.js,host-core/rule30-ladder-core.js,instruments/comb-hopf/index.html,instruments/comb-hopf/panel-elliptic.js,instruments/comb-hopf/panel-pens.js,instruments/comb-hopf/panel.js,instruments/comb-hopf/view-clifford.js,instruments/comb-hopf/view-fourier.js,instruments/comb-hopf/view-hopf.js,instruments/comb-hopf/view-panels.js
test-v0414	FAIL comb-core.js, orbit-core.js, fraction-stack-core.js, stack-core.js, gearbox-core.js, shell-core.js, ca-core.js, exact-lib unchanged against v0.4.13
test-v042	FAIL Fix 1 scope (source): host-core/comb-core.js differs from v0.4.1 by exactly one added line (the N = 0 branch of wilsonN); every other host-core module and exact-lib file is byte-identical to v0.4.1; instruments/comb-hopf/panel.js differs only in clampPhi (lines 45 and 48); no other instrument file differs (10 files byte-identical; panel.js lines differing: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 298, 299, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 314, 315, 316, 317, 318, 319, 320, 321, 322, 323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 342, 343, 344, 345, 346, 347, 348, 349, 350, 351, 352, 353, 354, 355, 356, 357, 358, 359, 360, 361, 362, 363, 364, 365, 366, 367, 368, 369, 370, 371, 372, 373, 374, 375, 376, 377, 378, 379, 380, 381, 382, 383, 384, 385, 386, 387, 388, 389, 390, 391, 392, 393, 394, 395, 396, 397, 398, 399, 400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 412, 413, 414, 415, 416, 417, 418, 419, 420, 421, 422, 423, 424, 425, 426, 427, 428, 429, 430, 431, 432, 433, 434, 435, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447, 448, 449, 450, 451, 452, 453, 454, 455, 456, 457, 458, 459, 460, 461, 462, 463, 464, 465, 466, 467, 468, 469, 470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523, 524, 525, 526, 527, 528, 529, 530, 531, 532, 533, 534, 535, 536, 537, 538, 539, 540, 541, 542, 543, 544, 545, 546, 547, 548, 549, 550, 551, 552, 553, 554, 555, 556, 557, 558, 559, 560, 561, 562, 563, 564, 565, 566, 567, 568, 569, 570, 571, 572, 573, 574, 575, 576, 577, 578, 579, 580, 581, 582, 583, 584, 585, 586, 587, 588, 589, 590, 591, 592, 593, 594, 595, 596, 597, 598, 599, 600, 601, 602, 603, 604, 605, 606, 607, 608, 609, 610, 611, 612, 613, 614, 615, 616, 617, 618, 619, 620; new host-core files: branch-disk-core.js, ca-core.js, elliptic-exact-core.js, elliptic-period-core.js, field-q2-q5-tau.js, goldbach-core.js, pen-curvature-core.js, pen-interval-core.js, pen-sphere-core.js, pen-streams-core.js, rhm-core.js, rule30-ladder-core.js, stack-core.js, test-elliptic-exact.cjs, test-elliptic-period.cjs, test-pen-curvature.cjs, test-pen-fields.cjs, test-pen-sphere.cjs, test-pen-streams.cjs, test-rule30-ladder.cjs, test-v0418-fixups.cjs, test-v042.cjs, transcription-skeleton-pens.cjs) differing: host-core/comb-numeric.js, host-core/parity-sample.cjs, host-core/test-core.cjs, instruments/comb-hopf/index.html, instruments/comb-hopf/view-clifford.js, instruments/comb-hopf/view-fourier.js, instruments/comb-hopf/view-hopf.js, instruments/comb-hopf/view-panels.js, instruments/comb-hopf/views-common.js
```
</details>

**SUMMARY of the v0.4.17 baseline run on membrane (`membrane_run/baseline_v0417_linux/SUMMARY_v0417.txt`)**

```
test-exact exit=0 test-exact: 21 passed, 0 failed
test-core exit=1 test-core: 153 passed, 7 failed
contrast-check exit=0 contrast-check: 93 pass, 0 fail
test-mirror exit=0 test-mirror (T-MA): 14 passed, 0 failed
test-v041 exit=1 test-v041: 10 passed, 1 failed
test-v042 exit=1 test-v042: 5 passed, 1 failed
test-v044 exit=0 11 passed, 0 failed
test-v047 exit=0 test-v047 unit: 33 pass, 0 fail
test-v049 exit=0 v0.4.9 unit check: 25 pass / 0 fail
test-v0410 exit=1 SUMMARY test-v0410: 17 pass / 3 fail
test-v0411 exit=1 SUMMARY test-v0411: 15 pass, 1 fail
test-v0412 exit=1 SUMMARY test-v0412: 11 pass, 1 fail
test-v0413 exit=1 SUMMARY test-v0413: 5 pass, 1 fail
test-v0414 exit=0 SUMMARY test-v0414 22 passed, 0 failed
test-rule30-ladder exit=0 SUMMARY test-rule30-ladder: 55 passed, 0 failed
test-elliptic-exact exit=0 SUMMARY test-elliptic-exact: 43 passed, 0 failed
test-elliptic-period exit=0 SUMMARY test-elliptic-period: 49 passed, 0 failed
no-float-elliptic exit=0 SUMMARY no-float-elliptic: 8 passed, 0 failed
browser-check-mirror exit=1 browser-check-mirror: 120 passed, 2 failed
browser-check-v041 exit=1 browser-check-v041: 62 passed, 4 failed
browser-check-v042 exit=0 browser-check-v042: 46 passed, 0 failed
browser-check-v043 exit=0 browser-check-v043: 36 passed, 0 failed
browser-check-v044 exit=1 216 passed, 6 failed
browser-check-v045 exit=0 58 passed, 0 failed
browser-check-v046 exit=0 16 passed, 0 failed
browser-check-v047 exit=1 browser-check-v047: 58 passed, 2 failed
browser-check-v048 exit=1 v0.4.8 browser check: 16 pass / 3 fail
browser-check-v049 exit=0 v0.4.9 browser check: 52 pass / 0 fail
browser-check-v0410 exit=1 SUMMARY browser-check-v0410: 100 pass / 4 fail
browser-check-v0411 exit=1 SUMMARY browser-check-v0411: 80 pass, 2 fail
browser-check-v0412 exit=1 SUMMARY browser-check-v0412: 76 pass, 2 fail
browser-check-v0413 exit=1 SUMMARY browser-check-v0413: 72 pass, 2 fail
browser-check-v0414 exit=1 SUMMARY browser-check-v0414 94 passed, 2 failed
browser-check-v0416 exit=0 SUMMARY browser-check-v0416: 218 passed, 0 failed
browser-check-v0417 exit=0 SUMMARY browser-check-v0417: 77 passed, 0 failed
browser-check exit=1 browser-check: 531 passed, 40 failed
ALLDONE
```

**SUMMARY of the final v0.4.18 run on membrane (`build/_logs/SUMMARY_v0418.txt`)**

```
test-exact exit=0 test-exact: 21 passed, 0 failed
test-core exit=1 test-core: 153 passed, 7 failed
contrast-check exit=0 contrast-check: 93 pass, 0 fail
test-mirror exit=0 test-mirror (T-MA): 14 passed, 0 failed
test-v041 exit=1 test-v041: 10 passed, 1 failed
test-v042 exit=1 test-v042: 5 passed, 1 failed
test-v044 exit=0 11 passed, 0 failed
test-v047 exit=0 test-v047 unit: 33 pass, 0 fail
test-v049 exit=0 v0.4.9 unit check: 25 pass / 0 fail
test-v0410 exit=1 SUMMARY test-v0410: 17 pass / 3 fail
test-v0411 exit=1 SUMMARY test-v0411: 15 pass, 1 fail
test-v0412 exit=1 SUMMARY test-v0412: 11 pass, 1 fail
test-v0413 exit=1 SUMMARY test-v0413: 5 pass, 1 fail
test-v0414 exit=1 SUMMARY test-v0414 21 passed, 1 failed
test-rule30-ladder exit=0 SUMMARY test-rule30-ladder: 55 passed, 0 failed
test-elliptic-exact exit=0 SUMMARY test-elliptic-exact: 43 passed, 0 failed
test-elliptic-period exit=0 SUMMARY test-elliptic-period: 49 passed, 0 failed
no-float-elliptic exit=0 SUMMARY no-float-elliptic: 8 passed, 0 failed
test-pen-streams exit=0 SUMMARY test-pen-streams: 41 passed, 0 failed
test-pen-fields exit=0 SUMMARY test-pen-fields: 26 passed, 0 failed
test-pen-curvature exit=0 SUMMARY test-pen-curvature: 43 passed, 0 failed
test-pen-sphere exit=0 SUMMARY test-pen-sphere: 27 passed, 0 failed
test-v0418-fixups exit=0 SUMMARY test-v0418-fixups: 11 passed, 0 failed
no-float-v0418 exit=0 SUMMARY no-float-v0418: 16 passed, 0 failed
browser-check-mirror exit=1 browser-check-mirror: 120 passed, 2 failed
browser-check-v041 exit=1 browser-check-v041: 62 passed, 4 failed
browser-check-v042 exit=0 browser-check-v042: 46 passed, 0 failed
browser-check-v043 exit=0 browser-check-v043: 36 passed, 0 failed
browser-check-v044 exit=1 216 passed, 6 failed
browser-check-v045 exit=0 58 passed, 0 failed
browser-check-v046 exit=0 16 passed, 0 failed
browser-check-v047 exit=1 browser-check-v047: 58 passed, 2 failed
browser-check-v048 exit=1 v0.4.8 browser check: 16 pass / 3 fail
browser-check-v049 exit=0 v0.4.9 browser check: 52 pass / 0 fail
browser-check-v0410 exit=1 SUMMARY browser-check-v0410: 100 pass / 4 fail
browser-check-v0411 exit=1 SUMMARY browser-check-v0411: 80 pass, 2 fail
browser-check-v0412 exit=1 SUMMARY browser-check-v0412: 76 pass, 2 fail
browser-check-v0413 exit=1 SUMMARY browser-check-v0413: 72 pass, 2 fail
browser-check-v0414 exit=1 SUMMARY browser-check-v0414 94 passed, 2 failed
browser-check-v0416 exit=0 SUMMARY browser-check-v0416: 218 passed, 0 failed
browser-check-v0417 exit=1 SUMMARY browser-check-v0417: 73 passed, 4 failed
browser-check-v0418 exit=0 SUMMARY browser-check-v0418: 128 passed, 0 failed
browser-check-legacy-panels-v0418 exit=0 SUMMARY browser-check-legacy-panels-v0418: 5 passed, 0 failed
browser-check exit=1 browser-check: 531 passed, 40 failed
check-expected-fails-v0418 exit=0 SUMMARY check-expected-fails-v0418: 11 passed, 0 failed
ALLDONE
```

## Host of every check

| Check | Host | How |
|---|---|---|
| host-core/test-pen-streams.cjs (job VIEW-NODE-0418-01) | membrane | capped runner: exit 0, wall 0:00.64, peak RSS 75380 KiB, library check OK/OK, 2026-10-31T12:39:05Z |
| host-core/test-pen-fields.cjs (job VIEW-NODE-0418-02) | membrane | capped runner: exit 0, wall 0:00.08, peak RSS 57464 KiB, library check OK/OK, 2026-10-31T12:39:06Z |
| host-core/test-pen-curvature.cjs (job VIEW-NODE-0418-03) | membrane | capped runner: exit 0, wall 0:02.26, peak RSS 291160 KiB, library check OK/OK, 2026-10-31T12:39:12Z |
| host-core/test-pen-sphere.cjs (job VIEW-NODE-0418-04) | membrane | capped runner: exit 0, wall 0:10.35, peak RSS 244724 KiB, library check OK/OK, 2026-10-31T12:39:15Z |
| host-core/test-v0418-fixups.cjs (job VIEW-NODE-0418-05) | membrane | capped runner: exit 0, wall 0:00.02, peak RSS 45548 KiB, library check OK/OK, 2026-10-31T12:39:26Z |
| build/no-float-v0418.cjs (job VIEW-NODE-0418-06) | membrane | capped runner: exit 0, wall 0:00.03, peak RSS 48832 KiB, library check OK/OK, 2026-10-31T12:39:26Z |
| build/no-float-v0418.cjs (job VIEW-NODE-0418-07) | membrane | capped runner: exit 0, wall 0:00.03, peak RSS 48388 KiB, library check OK/OK, 2026-10-31T14:18:06Z |
| every suite of `build/runall.sh` (node and browser, old and new, 47 runs) on v0.4.17 | membrane | direct, `flock -n` on the runner lock, mirror copy, NODE_PATH playwright (run417, start 2026-10-31T12:03:50Z) |
| test-v0410 … v0414, browser-check-v0410 … v0414, v0417 on v0.4.18 (to write the expected list) | membrane | direct, under the lock (pre418; logs in `membrane_run/pre418_expected_fails/`) |
| every suite of `build/runall.sh` on v0.4.18, first run | membrane | direct, under the lock (run418; logs in `membrane_run/run418_first_linux/`) |
| every suite of `build/runall.sh` on v0.4.18, **final run of record**, ending with check-expected-fails-v0418 | membrane | direct, under the lock (run418b, start 2026-10-31T13:40:55Z; logs in `build/_logs/`) |
| shots-v0418 (40 screenshots) | membrane | direct, under the lock, right after the final run |
| development probes, dev runs of browser-check-v0418 and legacy-panels | Neo | not of record |

Receipts (RECEIPT.json, stdout, stderr, PREREG, MANIFEST.sha256, time.log) of the seven capped jobs are in `membrane_receipts/VIEW-NODE-0418-01 … 07/`, with the PREREG texts also as `membrane_receipts/prereg_0*.txt`. The folders used on membrane: `~/membrane_compute/viewer/v0_4_18/` (capped jobs) and `~/membrane_compute/viewer/mirror/` (full runs). `~/fv_builds/` was not used. I made no membrane run outside the runner other than the browser runs above, a one-off Chromium test of `file:////` URLs, and two probes for the 375 px overflow (all node + playwright, under the lock, no files written outside `~/membrane_compute/viewer/`).

## PATHMAP (the rewrite for the membrane run copies)


Membrane (Ubuntu 24.04, reached over Tailscale as `saphir@[ts-redact-4]`) ran the old and new suites from **copies**. The originals in this build folder (on Neo) were not touched.

### Layout on membrane
- Mirror root: `/home/saphir/membrane_compute/viewer/mirror/`, holding:
  - the full build folders `FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/` and `FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/` (copies);
  - the predecessors the suites reference, without `*.png` and `build/_logs`: v0.3, v0.4, v0.4.1 … v0.4.16 (the glob also brought the small v0.4.16 BRIEF and VERIFY folders);
  - read-only copies of the other inputs the old suites read: `FOURIER_VIEWER_LIBS/exact-lib-0.2.0/dist/exact-lib.js`, `cubic_Fourier/DIVISOR_COMB_RIEMANN_v0_3_2_20261012/`, `cold audit fourier/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/monodromy-31-linked-reduction.html`, `FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029_BRIEF/SAGE_REFERENCE_37a1_20261029.txt`, `POINCARE_DISK_VIEW_INVESTIGATION_v0_1_20261020/disk_checks.py`, and the three pinned files of `rule30_prize_research_2026_10_26/` that test-rule30-ladder hashes (copied from Neo, read only; nothing was written into the Neo folder).
  - Not mirrored: `C:/Users/robin/Downloads/fvlt_fourier_m7_fact-4-24_…json` (test-core's reference export): 6 test-core lines fail on membrane in both runs for that reason.
- Node-only capped jobs: `/home/saphir/membrane_compute/viewer/v0_4_18/` (a plain copy of this folder, no rewrite needed: the new node suites use relative paths only).
- Node v24.13.0 (`~/.local/bin/node` → `~/opt/node-v24.13.0-linux-x64/bin/node`); Playwright 1.61.1 with Chromium 149 through `NODE_PATH=~/opt/playwright-1.61.1/node_modules`.

### The rewrite (pathmap.cjs, in this folder)
Applied to the `.cjs` and `.sh` files of `build/`, `host-core/` and `exact-lib/` of each mirror copy, and nothing else:
1. `require('C:/Users/robin/s6_atom/node_modules/playwright')` → `require('playwright')`;
2. `file:///C:/Users/robin/s6_atom` → `file:///home/saphir/membrane_compute/viewer/mirror`;
3. `C:/Users/robin/s6_atom` → `/home/saphir/membrane_compute/viewer/mirror`.
The helper `u = p => 'file:///' + p…` was left as it is: on Linux it gives `file:////home/…`, which Chromium 149 normalises to `file:///home/…` (tested on membrane before the runs). The v0.4.18 scripts resolve playwright through NODE_PATH and fall back to the Neo path, so rule 3 only changes their fallback strings.
Files changed: 47 in the v0.4.17 copy, 50 in the v0.4.18 copy (the 47 plus browser-check-v0418, shots-v0418 and browser-check-legacy-panels-v0418). The complete `diff -ru` outputs (original copy against rewritten copy) follow, and are also kept as `pathmap_417.diff` and `pathmap_418.diff`.

### Runs, in order (one at a time; the lock `~/membrane_compute/.lock` held with `flock -n` for every browser run)
1. v0.4.17 full `build/runall.sh` (Linux baseline), mirror copy: `run417` (started 2026-10-31T12:03:50Z).
2. Capped node jobs VIEW-NODE-0418-01 … 06 (receipts in `../membrane_receipts/`).
3. The 11 suites of the expected-fails list on v0.4.18 (test-v0410 … v0414, browser-check-v0410 … v0414, browser-check-v0417), to write `build/EXPECTED_FAILS_v0418.txt`.
4. v0.4.18 full `build/runall.sh`, mirror copy: `run418`, which ends with check-expected-fails-v0418 reading the logs of that same run.
5. `build/shots-v0418.cjs` (screenshots `shot_v0418_linux_*`).
No browser run used the capped runner (`ulimit -v` breaks Chromium); each checked the lock first.

### diff: v0.4.17 copy
```diff
diff -ru orig417/build/browser-check.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check.cjs
--- orig417/build/browser-check.cjs	2026-10-31 12:03:40.108642454 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check.cjs	2026-10-31 12:03:40.135642323 +0000
@@ -1,7 +1,7 @@
 'use strict';
 // Browser check (Playwright from s6_atom/node_modules): loads dist/comb-hopf.html over file://, screenshots, exercises tabs, stepping, exports.
 const path=require('path'),fs=require('fs');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').replace(/\\/g,'/');
 let pass=0,fail=0,minFont=1e9;
 const expOpen=async(p,imp)=>{if(!(await p.locator('#expmenu').isVisible()))await p.click('#expBtn');if(imp&&!(await p.locator('#imp').isVisible()))await p.click('#impShow');await p.waitForTimeout(40);};const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x?' '+x:''));c?pass++:fail++;};
diff -ru orig417/build/browser-check-mirror.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-mirror.cjs
--- orig417/build/browser-check-mirror.cjs	2026-10-31 12:03:40.108642454 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-mirror.cjs	2026-10-31 12:03:40.131642342 +0000
@@ -2,7 +2,7 @@
 // v0.4 browser check of the mirror axis (T-MA in the page; R1–R4 as amended by the S0 design review §5). Playwright from s6_atom/node_modules, dist page over file://.
 // The v0.3 suite build/browser-check.cjs runs unchanged beside this one.
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').replace(/\\/g,'/');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
 const B={shellMode:'integer',B:'24',nMode:'integer',n6:'1',alpha:'0'};
diff -ru orig417/build/browser-check-v0410.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v0410.cjs
--- orig417/build/browser-check-v0410.cjs	2026-10-31 12:03:40.108642454 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v0410.cjs	2026-10-31 12:03:40.132642337 +0000
@@ -3,9 +3,9 @@
 // (1) counts 39/41/39/41 unchanged, also on the n² + 1 track; (2) every v0.4.9 check state: state, address, exact export (JSON, state, CSV, Lift JSON, stats), caption, cards, about, canvas and PNG export byte-identical to v0.4.9;
 // the Panels tab differs only by the two new (collapsed) card elements; (3) the cards: contents, gates, idle captions, canvas geometry, tessellation parity, pairing lines; (4) the preset track and its address key; (5) no horizontal scroll at 375; (6) shots shot_v0410_*.
 const fs=require('fs'),path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const url=u(path.join(root,'dist','comb-hopf.html')),url49=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_9_20261020/dist/comb-hopf.html');
+const url=u(path.join(root,'dist','comb-hopf.html')),url49=u('/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_9_20261020/dist/comb-hopf.html');
 const CC=require('../host-core/comb-core.js'),BD=require('../host-core/branch-disk-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
 const addr=(o,extra)=>CC.encodeAddress(CC.initial(o))+(extra||'');
diff -ru orig417/build/browser-check-v0411.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v0411.cjs
--- orig417/build/browser-check-v0411.cjs	2026-10-31 12:03:40.108642454 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v0411.cjs	2026-10-31 12:03:40.132642337 +0000
@@ -4,9 +4,9 @@
 // (3) the layer: view keys fr/cr/hr only when on, menu item only while the Full stack is on, toggle round trip, reload restores, data attributes, canvas changes;
 // (4) Hopf: ink at the expected reflected positions (control: the primary positions); (5) no key collision; (6) no horizontal scroll at 375; (7) shots shot_v0411_*.
 const fs=require('fs'),path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const url=u(path.join(root,'dist','comb-hopf.html')),url410=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_10_20261020/dist/comb-hopf.html');
+const url=u(path.join(root,'dist','comb-hopf.html')),url410=u('/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_10_20261020/dist/comb-hopf.html');
 const CC=require('../host-core/comb-core.js'),SC=require('../host-core/stack-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
 const addr=(o,extra)=>CC.encodeAddress(CC.initial(o))+(extra||'');
diff -ru orig417/build/browser-check-v0412.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v0412.cjs
--- orig417/build/browser-check-v0412.cjs	2026-10-31 12:03:40.108642454 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v0412.cjs	2026-10-31 12:03:40.132642337 +0000
@@ -4,9 +4,9 @@
 // (3) the layer: key fl only when on, menu item only while the Full stack is on, toggle round trip, reload, inert with the stack off, data attributes, caption wording, throat circle, log rings, R(1) = R_t;
 // (4) pixel probe: ink at the expected log positions of both halves; Clifford and Hopf unchanged by fl; (5) key unique; (6) no horizontal scroll; (7) shots shot_v0412_*.
 const fs=require('fs'),path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const url=u(path.join(root,'dist','comb-hopf.html')),url411=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_11_20261021/dist/comb-hopf.html');
+const url=u(path.join(root,'dist','comb-hopf.html')),url411=u('/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_11_20261021/dist/comb-hopf.html');
 const CC=require('../host-core/comb-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
 const addr=(o,extra)=>CC.encodeAddress(CC.initial(o))+(extra||'');
diff -ru orig417/build/browser-check-v0413.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v0413.cjs
--- orig417/build/browser-check-v0413.cjs	2026-10-31 12:03:40.108642454 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v0413.cjs	2026-10-31 12:03:40.132642337 +0000
@@ -1,9 +1,9 @@
 'use strict';
 // v0.4.13 browser check (SCHEMA_ADDENDUM_21): in log mode only the stack is log-mapped; pen, teeth, carrier on a linear scale with a scale bar. 1280x800 and 375x812.
 const fs=require('fs'),path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const url=u(path.join(root,'dist','comb-hopf.html')),url412=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_12_20261021/dist/comb-hopf.html');
+const url=u(path.join(root,'dist','comb-hopf.html')),url412=u('/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_12_20261021/dist/comb-hopf.html');
 const CC=require('../host-core/comb-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
 const addr=(o,extra)=>CC.encodeAddress(CC.initial(o))+(extra||'');
diff -ru orig417/build/browser-check-v0414.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v0414.cjs
--- orig417/build/browser-check-v0414.cjs	2026-10-31 12:03:40.108642454 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v0414.cjs	2026-10-31 12:03:40.133642332 +0000
@@ -1,9 +1,9 @@
 'use strict';
 // v0.4.14 browser check (SCHEMA_ADDENDUM_22): the Goldbach prime-pair track "Goldbach N ▸". 1280x800 and 375x812. The reference arithmetic is independent of goldbach-core (own sieve, own G_N).
 const fs=require('fs'),path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const url=u(path.join(root,'dist','comb-hopf.html')),url413=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_13_20261021/dist/comb-hopf.html');
+const url=u(path.join(root,'dist','comb-hopf.html')),url413=u('/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_13_20261021/dist/comb-hopf.html');
 const CC=require('../host-core/comb-core.js'),GB=require('../host-core/goldbach-core.js'),X=require('../exact-lib/exact-lib-0.2.0.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
 const LIM=1500,comp=new Uint8Array(LIM+1);comp[0]=comp[1]=1;for(let i=2;i*i<=LIM;i++)if(!comp[i])for(let j=i*i;j<=LIM;j+=i)comp[j]=1;
diff -ru orig417/build/browser-check-v0416.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v0416.cjs
--- orig417/build/browser-check-v0416.cjs	2026-10-31 12:03:40.108642454 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v0416.cjs	2026-10-31 12:03:40.133642332 +0000
@@ -3,10 +3,10 @@
 // Cases: rule 30 j = 3 (doubling), rule 30 j = 5 (stall), rule 90 j = 3 (density 0), each at q = 1, 2, 4, 8. Expected values come from the core (itself checked against the pinned rule30 fixture by test-rule30-ladder).
 // D1 off: the page is compared with the v0.4.14 build (stage, canvas, caption, about, cards, address) on 8 states, and the visible-control counts are compared.
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const CC=require('../host-core/comb-core.js'),RL=require('../host-core/rule30-ladder-core.js');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const url=u(path.join(root,'dist','comb-hopf.html')),url414=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_14_20261021/dist/comb-hopf.html');
+const url=u(path.join(root,'dist','comb-hopf.html')),url414=u('/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_14_20261021/dist/comb-hopf.html');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
 const addr=(o)=>CC.encodeAddress(CC.initial(o));
 const count=pg=>pg.evaluate(()=>{const vis=e=>{const r=e.getBoundingClientRect(),cs=getComputedStyle(e);return r.width>0&&r.height>0&&cs.display!=='none'&&cs.visibility!=='hidden'&&!e.closest('[style*="display: none"]')&&!e.closest('[hidden]');};
diff -ru orig417/build/browser-check-v0417.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v0417.cjs
--- orig417/build/browser-check-v0417.cjs	2026-10-31 12:03:40.108642454 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v0417.cjs	2026-10-31 12:03:40.133642332 +0000
@@ -6,10 +6,10 @@
 // elements are removed, and the other tabs are identical to v0.4.16 (stage, caption, cards, address). The v0.4.16 page is read only (sha256 pinned).
 // No floating point: pixel counts are integers; times are integer milliseconds from Date.now.
 const path=require('path'),fs=require('fs'),crypto=require('crypto');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const CC=require('../host-core/comb-core.js'),EX=require('../host-core/elliptic-exact-core.js'),PE=require('../host-core/elliptic-period-core.js');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const OLD='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_16_20261028/dist/comb-hopf.html',OLDSHA='1da7dc8f8cad8c31f22e302a92e763fdc95b71abf4d3dc559fcad33df88c1b71';
+const OLD='/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_16_20261028/dist/comb-hopf.html',OLDSHA='1da7dc8f8cad8c31f22e302a92e763fdc95b71abf4d3dc559fcad33df88c1b71';
 const url=u(path.join(root,'dist','comb-hopf.html')),url416=u(OLD);
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
 const addr=o=>CC.encodeAddress(CC.initial(o));
diff -ru orig417/build/browser-check-v041.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v041.cjs
--- orig417/build/browser-check-v041.cjs	2026-10-31 12:03:40.108642454 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v041.cjs	2026-10-31 12:03:40.132642337 +0000
@@ -2,9 +2,9 @@
 // v0.4.1 browser check (SCHEMA_ADDENDUM_9): shell range n1 = 1..13 / B >= 1, the star on t1*s in Z, the carrier foliation (display register).
 // Playwright from s6_atom/node_modules; dist pages over file:// (v0.4 page read-only, for the byte-identity comparison with the foliation off).
 const path=require('path'),crypto=require('crypto');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').replace(/\\/g,'/');
-const url04='file:///C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_20261019/dist/comb-hopf.html';
+const url04='file:///home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_20261019/dist/comb-hopf.html';
 const CC=require('../host-core/comb-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
 const addr=o=>CC.encodeAddress(CC.enterSpin(CC.initial(o),o.sTyped||'1'));
diff -ru orig417/build/browser-check-v042.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v042.cjs
--- orig417/build/browser-check-v042.cjs	2026-10-31 12:03:40.108642454 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v042.cjs	2026-10-31 12:03:40.133642332 +0000
@@ -2,9 +2,9 @@
 // v0.4.2 browser check (SCHEMA_ADDENDUM_10): (1) the N = 0 Wilson wording on the page and in the exports; (2) the shell-switch clamp phi3 -> B (N = 1).
 // Playwright from s6_atom/node_modules; dist pages over file://. The v0.4.1 page is opened read-only, for the comparisons.
 const path=require('path'),crypto=require('crypto');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').replace(/\\/g,'/');
-const url41='file:///C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_1_20261019/dist/comb-hopf.html';
+const url41='file:///home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_1_20261019/dist/comb-hopf.html';
 const CC=require('../host-core/comb-core.js');
 const NEW='N = 0: no comb, so the Wilson test does not apply.',OLD='N = 1 is not prime.';
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
diff -ru orig417/build/browser-check-v043.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v043.cjs
--- orig417/build/browser-check-v043.cjs	2026-10-31 12:03:40.108642454 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v043.cjs	2026-10-31 12:03:40.133642332 +0000
@@ -2,7 +2,7 @@
 // v0.4.3 browser check (SCHEMA_ADDENDUM_11): the canvas bitmap is full resolution while the camera moves (Clifford and Hopf), and after release;
 // the 'surface' kind still yields half size (unit level, through FVViews.resFactor and a probe canvas).
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/');
 const REPRO={shellMode:'factorial',n1:'4',phi3:'6',alpha:'-1/50',n6:'1',t1:'1',t2:'-21/4',m:'3'};
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
diff -ru orig417/build/browser-check-v044.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v044.cjs
--- orig417/build/browser-check-v044.cjs	2026-10-31 12:03:40.108642454 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v044.cjs	2026-10-31 12:03:40.134642328 +0000
@@ -3,9 +3,9 @@
 // (port of the accepted RH margin panel) read from the DOM and compared with rhm-core.js, no horizontal scroll at 375,
 // non-CA states unchanged against the v0.4.3 dist, and the shot_v044_* screenshots.
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const url=u(path.join(root,'dist','comb-hopf.html')),url43=u(path.join('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_3_20261019','dist','comb-hopf.html'));
+const url=u(path.join(root,'dist','comb-hopf.html')),url43=u(path.join('/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_3_20261019','dist','comb-hopf.html'));
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
 const EXP={2:['3/2','2.152786','fails'],6:['2','0.961281','fails'],12:['7/3','0.712138','fails'],60:['14/5','0.289388','fails'],120:['3','0.210828','fails'],360:['13/4','0.092881','fails'],2520:['26/7','0.048447','fails'],5040:['403/105','0.021217','fails'],55440:['1612/385','\u22120.071311','holds'],720720:['248/55','\u22120.124905','holds']};
 const SAMPLES=[{shellMode:'factorial',n1:'4',phi3:'6',m:'3',t1:'1',t2:'1',tab:'fourier'},{shellMode:'factorial',n1:'5',phi3:'0',m:'6',t1:'1',t2:'-21/4',tab:'clifford'},{shellMode:'integer',B:'24',phi3:'20',m:'5',t1:'1',t2:'2',tab:'hopf'},
diff -ru orig417/build/browser-check-v045.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v045.cjs
--- orig417/build/browser-check-v045.cjs	2026-10-31 12:03:40.108642454 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v045.cjs	2026-10-31 12:03:40.134642328 +0000
@@ -4,9 +4,9 @@
 // "visible controls ... <= 40" assertions, the two continuous-mode inventory assertions, and the "N mode switch" assertion). The counting method is the old one verbatim (layout(): visible button/input/select
 // inside #inst or .header, minus .info buttons).
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const url=u(path.join(root,'dist','comb-hopf.html')),url44=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_4_20261020/dist/comb-hopf.html');
+const url=u(path.join(root,'dist','comb-hopf.html')),url44=u('/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_4_20261020/dist/comb-hopf.html');
 const CC=require('../host-core/comb-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
 const PRESETS=['2','6','12','60','120','360','2520','5040','55440','720720'];
diff -ru orig417/build/browser-check-v046.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v046.cjs
--- orig417/build/browser-check-v046.cjs	2026-10-31 12:03:40.108642454 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v046.cjs	2026-10-31 12:03:40.134642328 +0000
@@ -1,9 +1,9 @@
 'use strict';
 // v0.4.6 browser check (SCHEMA_ADDENDUM_14): n1 group hidden in integer mode; counts; addresses identical to v0.4.5.
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const url=u(path.join(root,'dist','comb-hopf.html')),url45=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_5_20261020/dist/comb-hopf.html');
+const url=u(path.join(root,'dist','comb-hopf.html')),url45=u('/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_5_20261020/dist/comb-hopf.html');
 const CC=require('../host-core/comb-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
 const addr=o=>CC.encodeAddress(CC.initial(o));
diff -ru orig417/build/browser-check-v047.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v047.cjs
--- orig417/build/browser-check-v047.cjs	2026-10-31 12:03:40.108642454 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v047.cjs	2026-10-31 12:03:40.134642328 +0000
@@ -1,9 +1,9 @@
 'use strict';
 // v0.4.7 browser check (SCHEMA_ADDENDUM_15): alpha_Tilt as a walk weight. Design note section 9, tests 1 (browser part), 6, 7, 8, 10, 11, and the shots.
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const url=u(path.join(root,'dist','comb-hopf.html')),url46=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_6_20261020/dist/comb-hopf.html');
+const url=u(path.join(root,'dist','comb-hopf.html')),url46=u('/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_6_20261020/dist/comb-hopf.html');
 const CC=require('../host-core/comb-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
 const addr=(o,tilt)=>CC.encodeAddress(CC.initial(o))+(tilt?'&tilt='+tilt:'');
diff -ru orig417/build/browser-check-v048.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v048.cjs
--- orig417/build/browser-check-v048.cjs	2026-10-31 12:03:40.108642454 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v048.cjs	2026-10-31 12:03:40.134642328 +0000
@@ -1,9 +1,9 @@
 'use strict';
 // v0.4.8 check (SCHEMA_ADDENDUM_16): shorter tilt wording in the Fourier caption; Q-res visible at 1280x800; tilt 0 identical to v0.4.7; Panels relabel; shots.
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const url=u(path.join(root,'dist','comb-hopf.html')),url47=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_7_20261020/dist/comb-hopf.html');
+const url=u(path.join(root,'dist','comb-hopf.html')),url47=u('/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_7_20261020/dist/comb-hopf.html');
 const CC=require('../host-core/comb-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
 const gopen=async(pg,hash,base)=>{await pg.goto((base||url)+hash);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(400);};
diff -ru orig417/build/browser-check-v049.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v049.cjs
--- orig417/build/browser-check-v049.cjs	2026-10-31 12:03:40.108642454 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/browser-check-v049.cjs	2026-10-31 12:03:40.134642328 +0000
@@ -4,9 +4,9 @@
 // (3) the page's stack equals stack-core in Node and the OLD instrument's buildFullStack (frozen file, run in a Node vm); (4) dots really drawn; (5) address key only when on;
 // (6) signature cache: an s change does not redraw the stack bitmap; (7) no horizontal scroll at 375; (8) shots shot_v049_*.
 const fs=require('fs'),vm=require('vm'),path=require('path'),crypto=require('crypto');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const url=u(path.join(root,'dist','comb-hopf.html')),url48=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_8_20261020/dist/comb-hopf.html');
+const url=u(path.join(root,'dist','comb-hopf.html')),url48=u('/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_8_20261020/dist/comb-hopf.html');
 const CC=require('../host-core/comb-core.js'),SC=require('../host-core/stack-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
 const addr=(o,extra)=>CC.encodeAddress(CC.initial(o))+(extra||'');
@@ -16,7 +16,7 @@
 const snap=pg=>pg.evaluate(()=>({stage:document.getElementById('stage').innerHTML,cv:(()=>{try{return document.getElementById('stagecv').toDataURL();}catch(e){return '';}})(),caption:document.getElementById('caption').innerHTML,about:document.getElementById('about').innerHTML,cards:document.getElementById('cards').innerHTML,addr:document.getElementById('addr').textContent,hash:location.hash,st:JSON.stringify(FVPanel.state)}));
 const pngHash=pg=>pg.evaluate(async()=>{const b=await FVPanel.exportPng();const a=new Uint8Array(await b.arrayBuffer());const d=await crypto.subtle.digest('SHA-256',a);return [...new Uint8Array(d)].map(x=>x.toString(16).padStart(2,'0')).join('');});
 // ---- the old instrument's buildFullStack in a vm (read only)
-const OLD='C:/Users/robin/s6_atom/cold audit fourier/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/monodromy-31-linked-reduction.html',src=fs.readFileSync(OLD,'utf8');
+const OLD='/home/saphir/membrane_compute/viewer/mirror/cold audit fourier/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/monodromy-31-linked-reduction.html',src=fs.readFileSync(OLD,'utf8');
 function block(t){const i=src.indexOf(t);let j=src.indexOf('{',i),d=0;for(;j<src.length;j++){if(src[j]==='{')d++;else if(src[j]==='}'){d--;if(d===0)break;}}return src.slice(i,j+1);}
 const vctx={Math,Number,String,Object,Array,JSON};vm.createContext(vctx);
 vm.runInContext('var state={};function factorial(n){let f=1;for(let k=2;k<=n;k++)f*=k;return f;}function gearboxExactText(k){return state[k+"Exact"];}let _stackCache=null,_stackCacheKey=null,_stackDrawSig=null;\n'+['function selectedShellBase(','function selectedShellSpan(','function combOffsets(','function combKernel(','function reducedHalfTurns(','function stableGearboxAngle(','function computeVernier(','function buildFullStack('].map(block).join('\n'),vctx);
diff -ru orig417/build/package.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/package.cjs
--- orig417/build/package.cjs	2026-10-31 12:03:40.108642454 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/package.cjs	2026-10-31 12:03:40.135642323 +0000
@@ -4,7 +4,7 @@
 const root=path.join(__dirname,'..'),dir=path.join(root,'instruments','comb-hopf');
 const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
 let html=fs.readFileSync(path.join(dir,'index.html'),'utf8');
-const LIBSHA='3edfc8fb396fda90cfa945963eb18ccdf243f5a491e3ee49275b5c459a223a71',LIBSRC='C:/Users/robin/s6_atom/FOURIER_VIEWER_LIBS/exact-lib-0.2.0/dist/exact-lib.js';
+const LIBSHA='3edfc8fb396fda90cfa945963eb18ccdf243f5a491e3ee49275b5c459a223a71',LIBSRC='/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_LIBS/exact-lib-0.2.0/dist/exact-lib.js';
 const libCopy=path.join(root,'exact-lib','exact-lib-0.2.0.js');
 if(sha(fs.readFileSync(libCopy))!==LIBSHA)throw Error('exact-lib 0.2.0 sha256 mismatch');
 if(fs.existsSync(LIBSRC)&&sha(fs.readFileSync(LIBSRC))!==LIBSHA)throw Error('exact-lib 0.2.0 source sha256 mismatch');
diff -ru orig417/build/perf-bench.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/perf-bench.cjs
--- orig417/build/perf-bench.cjs	2026-10-31 12:03:40.108642454 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/perf-bench.cjs	2026-10-31 12:03:40.135642323 +0000
@@ -1,7 +1,7 @@
 'use strict';
 // Performance bench (Playwright from s6_atom/node_modules). Usage: node perf-bench.cjs [url] ; prints JSON tables for 1x and 4x CPU throttle.
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url=process.argv[2]||'file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/');
 const REPRO={shellMode:'factorial',n1:'4',phi3:'6',alpha:'-1/50',n6:'1',t1:'1',t2:'-21/4',m:'3'};
 const med=a=>{const s=[...a].sort((x,y)=>x-y);return s[Math.floor(s.length/2)];};
diff -ru orig417/build/perf-camera.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/perf-camera.cjs
--- orig417/build/perf-camera.cjs	2026-10-31 12:03:40.109642449 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/perf-camera.cjs	2026-10-31 12:03:40.135642323 +0000
@@ -2,7 +2,7 @@
 // Camera / drag / first-render bench (performance round 2). Usage: node perf-camera.cjs [url] ; JSON for 1x and 4x CPU throttle.
 // Camera: 60 synthetic pointer/wheel events, one per animation frame, at the reproduction state. fps = 60 / total seconds (frame-rate limited at about 58 on this harness).
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url=process.argv[2]||'file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/');
 const REPRO={shellMode:'factorial',n1:'4',phi3:'6',alpha:'-1/50',n6:'1',t1:'1',t2:'-21/4',m:'3'};
 const med=a=>{const s=[...a].sort((x,y)=>x-y);return s[Math.floor(s.length/2)];};
diff -ru orig417/build/perf-camprofile.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/perf-camprofile.cjs
--- orig417/build/perf-camprofile.cjs	2026-10-31 12:03:40.109642449 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/perf-camprofile.cjs	2026-10-31 12:03:40.135642323 +0000
@@ -1,7 +1,7 @@
 'use strict';
 // CDP Profiler + trace categories while rotating the camera 60 frames on one tab (reproduction state). Usage: node perf-camprofile.cjs [tab] [throttle] [kind]
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist',process.env.F||'comb-hopf.html').split(path.sep).join('/'),tab=process.argv[2]||'hopf',thr=+process.argv[3]||4,kind=process.argv[4]||'rotate';
 (async()=>{
   const b=await chromium.launch(),ctx=await b.newContext({viewport:{width:1280,height:800}}),page=await ctx.newPage(),cdp=await ctx.newCDPSession(page);
diff -ru orig417/build/perf-cdp.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/perf-cdp.cjs
--- orig417/build/perf-cdp.cjs	2026-10-31 12:03:40.109642449 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/perf-cdp.cjs	2026-10-31 12:03:40.135642323 +0000
@@ -1,7 +1,7 @@
 'use strict';
 // CDP Profiler + Tracing: self time by function and main-thread event categories while stepping phi3 40 times on one tab at the reproduction state.
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url=process.argv[2]||'file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/'),tab=process.argv[3]||'clifford',mode=process.argv[4]||'step',thr=+process.argv[5]||1;
 (async()=>{
   const b=await chromium.launch(),ctx=await b.newContext({viewport:{width:1280,height:800}}),page=await ctx.newPage(),cdp=await ctx.newCDPSession(page);
diff -ru orig417/build/perf-first.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/perf-first.cjs
--- orig417/build/perf-first.cjs	2026-10-31 12:03:40.109642449 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/perf-first.cjs	2026-10-31 12:03:40.135642323 +0000
@@ -1,7 +1,7 @@
 'use strict';
 // First render, A/B interleaved: page load to the first frame presented after the first full render (rAF after FVPanel.perf.n > 0), per tab, 1x and 4x CPU throttle.
 // Usage: node perf-first.cjs <urlA> [urlB] ; load order alternates A, B, A, B ... (9 loads each) so machine noise hits both alike; medians.
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const urls=process.argv.slice(2);if(!urls.length)throw Error('usage: node perf-first.cjs urlA [urlB]');
 const REPRO={shellMode:'factorial',n1:'4',phi3:'6',alpha:'-1/50',n6:'1',t1:'1',t2:'-21/4',m:'3'};
 const med=a=>{const s=[...a].sort((x,y)=>x-y);return s[Math.floor(s.length/2)];};
diff -ru orig417/build/perf-frame-v043.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/perf-frame-v043.cjs
--- orig417/build/perf-frame-v043.cjs	2026-10-31 12:03:40.109642449 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/perf-frame-v043.cjs	2026-10-31 12:03:40.136642318 +0000
@@ -1,7 +1,7 @@
 'use strict';
 // v0.4.3: frame time while rotating (Clifford and Hopf). Usage: node perf-frame-v043.cjs <url> <width> <height> <dsf> <throttle> [runs]
 // 90 synthetic pointer moves per run, one per animation frame, as perf-camera.cjs does; per-frame time = interval between consecutive frames. Reports median and p95 over all frames of all runs.
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const [url,W,H,DSF,THR,RUNS]=[process.argv[2],+process.argv[3],+process.argv[4],+process.argv[5],+process.argv[6],+(process.argv[7]||5)];
 const REPRO={shellMode:'factorial',n1:'4',phi3:'6',alpha:'-1/50',n6:'1',t1:'1',t2:'-21/4',m:'3'};
 const q=(a,p)=>{const s=[...a].sort((x,y)=>x-y);return s[Math.min(s.length-1,Math.floor(p*s.length))];};
diff -ru orig417/build/perf-load.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/perf-load.cjs
--- orig417/build/perf-load.cjs	2026-10-31 12:03:40.109642449 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/perf-load.cjs	2026-10-31 12:03:40.136642318 +0000
@@ -1,7 +1,7 @@
 'use strict';
 // Where the page-load time goes: CDP trace of one load (throttle via argv[2]), main-thread events by name. Usage: node perf-load.cjs [throttle] [hash]
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/'),thr=+process.argv[2]||4,hash=process.argv[3]||'';
 (async()=>{
   const b=await chromium.launch(),ctx=await b.newContext({viewport:{width:1280,height:800}}),page=await ctx.newPage(),cdp=await ctx.newCDPSession(page);
diff -ru orig417/build/perf-profile.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/perf-profile.cjs
--- orig417/build/perf-profile.cjs	2026-10-31 12:03:40.109642449 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/perf-profile.cjs	2026-10-31 12:03:40.136642318 +0000
@@ -1,7 +1,7 @@
 'use strict';
 // Where does a render go? Per-phase wall times (performance.now) at the reproduction state, per tab, plus DOM/SVG size.
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url=process.argv[2]||'file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/');
 (async()=>{
   const b=await chromium.launch(),ctx=await b.newContext({viewport:{width:1280,height:800}}),page=await ctx.newPage();
diff -ru orig417/build/probe-old-lift-alpha.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/probe-old-lift-alpha.cjs
--- orig417/build/probe-old-lift-alpha.cjs	2026-10-31 12:03:40.109642449 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/probe-old-lift-alpha.cjs	2026-10-31 12:03:40.136642318 +0000
@@ -2,7 +2,7 @@
 // v0.4.9 read-only probe (PORT_NOTE §7): does the OLD instrument's lift stack change with alpha, and what does its camera autofit (prepareCameraScreen) do with it?
 // Runs the old PlaneCliffordLiftCore (read from the frozen file, never edited) in a Node vm for saphir's state n1 = 4, m = 2, t1 = t2 = 1, n6 = 1.
 const fs=require('fs'),vm=require('vm');
-const OLD='C:/Users/robin/s6_atom/cold audit fourier/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/monodromy-31-linked-reduction.html',src=fs.readFileSync(OLD,'utf8');
+const OLD='/home/saphir/membrane_compute/viewer/mirror/cold audit fourier/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/monodromy-31-linked-reduction.html',src=fs.readFileSync(OLD,'utf8');
 function block(t){const i=src.indexOf(t);let j=src.indexOf('{',i),d=0;for(;j<src.length;j++){if(src[j]==='{')d++;else if(src[j]==='}'){d--;if(d===0)break;}}return src.slice(i,j+1);}
 const ctx={Math,Number,BigInt,String,Object,Array,Set,Map,RangeError,TypeError,Error,JSON,isFinite};vm.createContext(ctx);
 vm.runInContext(block('function combOffsets(')+'\nvar PlaneCliffordLiftCore='+block('const PlaneCliffordLiftCore = (() => {').replace('const PlaneCliffordLiftCore = ','')+')();this.L=PlaneCliffordLiftCore;',ctx);
diff -ru orig417/build/probe-old-page-alpha.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/probe-old-page-alpha.cjs
--- orig417/build/probe-old-page-alpha.cjs	2026-10-31 12:03:40.109642449 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/probe-old-page-alpha.cjs	2026-10-31 12:03:40.136642318 +0000
@@ -1,8 +1,8 @@
 'use strict';
 // v0.4.9 read-only probe (PORT_NOTE §7): open the OLD instrument page (frozen file, not edited), Clifford lift + Full stack, press alpha -1 / 0 / +1,
 // and record state.alpha, the stack lift's point norms, the camera fit and a hash of the Clifford canvas.
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright'),crypto=require('crypto'),path=require('path');
-const OLD='file:///C:/Users/robin/s6_atom/cold%20audit%20fourier/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/monodromy-31-linked-reduction.html';
+const {chromium}=require('playwright'),crypto=require('crypto'),path=require('path');
+const OLD='file:///home/saphir/membrane_compute/viewer/mirror/cold%20audit%20fourier/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/monodromy-31-linked-reduction.html';
 const out=process.argv[2];
 (async()=>{const b=await chromium.launch();const pg=await (await b.newContext({viewport:{width:1280,height:900},deviceScaleFactor:1})).newPage();const errs=[];pg.on('pageerror',e=>errs.push(String(e)));
   await pg.goto(OLD);await pg.waitForTimeout(4000);
diff -ru orig417/build/shots-v0414.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/shots-v0414.cjs
--- orig417/build/shots-v0414.cjs	2026-10-31 12:03:40.109642449 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/shots-v0414.cjs	2026-10-31 12:03:40.136642318 +0000
@@ -1,6 +1,6 @@
 'use strict';
 // v0.4.14 shots: the Goldbach track, Fourier (pen = G_N, ghosted teeth) and Clifford (Goldbach tori on one leaf), N = 24 (s = 4/3, near-zero pen) and N = 30 (s = 15/4), at 1280x800 and 375x812.
-const path=require('path');const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const path=require('path');const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/');
 const CC=require('../host-core/comb-core.js'),GB=require('../host-core/goldbach-core.js');
 (async()=>{const b=await chromium.launch();
diff -ru orig417/build/shots-v0416.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/shots-v0416.cjs
--- orig417/build/shots-v0416.cjs	2026-10-31 12:03:40.109642449 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/shots-v0416.cjs	2026-10-31 12:03:40.136642318 +0000
@@ -1,7 +1,7 @@
 'use strict';
 // v0.4.16 screenshots (SCHEMA_ADDENDUM_23): the D1 Rule 30 ladder card on the Clifford tab, 1280x800 and 375x812. Page only (full page at 375 so the card shows).
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const CC=require('../host-core/comb-core.js');
 const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/');
 const addr=view=>CC.encodeAddress(CC.initial({tab:'clifford',view}));
diff -ru orig417/build/shots-v0417.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/shots-v0417.cjs
--- orig417/build/shots-v0417.cjs	2026-10-31 12:03:40.109642449 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/shots-v0417.cjs	2026-10-31 12:03:40.136642318 +0000
@@ -1,7 +1,7 @@
 'use strict';
 // v0.4.17 screenshots (SCHEMA_ADDENDUM_24): the two group-D exact cards of the Panels tab, 1280x800 and 375x812. Card element shots, plus the group-D list.
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const CC=require('../host-core/comb-core.js');
 const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/')+CC.encodeAddress(CC.initial({tab:'panels'}));
 const setDial=(pg,role,v)=>pg.evaluate(([r,v])=>{const x=document.querySelector('[data-role="'+r+'"]');x.value=v;x.dispatchEvent(new Event('change',{bubbles:true}));},[role,String(v)]);
diff -ru orig417/build/shots-v043.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/shots-v043.cjs
--- orig417/build/shots-v043.cjs	2026-10-31 12:03:40.109642449 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/shots-v043.cjs	2026-10-31 12:03:40.136642318 +0000
@@ -1,8 +1,8 @@
 'use strict';
 // v0.4.3: mid-drag screenshots of v0.4.2 vs v0.4.3, Clifford view, same state and same drag. The 200 ms idle timer that ends "moving" is held off during the shot (page setTimeout wrapper), so the picture is the moving frame.
 // Usage: node shots-v043.cjs <outdir>
-const path=require('path');const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
-const out=process.argv[2],S='C:/Users/robin/s6_atom/';
+const path=require('path');const {chromium}=require('playwright');
+const out=process.argv[2],S='/home/saphir/membrane_compute/viewer/mirror/';
 const U={v042:'file:///'+S+'FOURIER_VIEWER_PROTOTYPE_v0_4_2_20261019/dist/comb-hopf.html',v043:'file:///'+S+'FOURIER_VIEWER_PROTOTYPE_v0_4_3_20261019/dist/comb-hopf.html'};
 const REPRO={shellMode:'factorial',n1:'4',phi3:'6',alpha:'-1/50',n6:'1',t1:'1',t2:'-21/4',m:'3'};
 (async()=>{
diff -ru orig417/build/shots-v047.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/shots-v047.cjs
--- orig417/build/shots-v047.cjs	2026-10-31 12:03:40.109642449 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/shots-v047.cjs	2026-10-31 12:03:40.136642318 +0000
@@ -1,7 +1,7 @@
 'use strict';
 // v0.4.7 shots: Fourier and Hopf base at alpha_Tilt = -1, -0.6, 0, +1 for B = 6 (n1 = 3), m = 7, N = 5, s = 1; 1280x800 and 375x812.
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/');
 const CC=require('../host-core/comb-core.js');
 (async()=>{
diff -ru orig417/build/test-v0410.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/test-v0410.cjs
--- orig417/build/test-v0410.cjs	2026-10-31 12:03:40.109642449 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/test-v0410.cjs	2026-10-31 12:03:40.136642318 +0000
@@ -5,7 +5,7 @@
 const fs=require('fs'),path=require('path'),crypto=require('crypto'),cp=require('child_process');
 const X=require('../exact-lib/exact-lib-0.2.0.js'),C=require('../host-core/comb-core.js'),O=require('../host-core/orbit-core.js'),SH=require('../host-core/shell-core.js'),BD=require('../host-core/branch-disk-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
-const root=path.join(__dirname,'..'),V49='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_9_20261020';
+const root=path.join(__dirname,'..'),V49='/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_9_20261020';
 const sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
 const euclid=(a,b)=>{a=a<0n?-a:a;b=b<0n?-b:b;while(b){[a,b]=[b,a%b];}return a;};
 const shell=(n,o)=>C.initial({shellMode:'integer',B:String(n*n),phi3:'0',m:String(2*n+1),t1:'1',t2:'1',...(o||{})});
@@ -139,7 +139,7 @@
   ok('B3 F(a) (Lemma II.5g), contact edges |as − cq| = 1 (Def II.5h) and isolated beads for N = 2, 5, 10, 12, 17, 26, 30, 50, 60, 101, 120, 360, 720, 5040 equal an independent enumeration; N = 12 = 2²·3 has orders 3, 2: F = {1/3, 1/2, 2/3}, 2 edges',bad.length===0&&d12.F.map(x=>x.join('/')).join()==='1/3,1/2,2/3'&&d12.edges.length===2,bad.join(' | '));
 }
 { // B4. Astra's points, n <= 30, against disk_checks.py run live
-  const script='C:/Users/robin/s6_atom/POINCARE_DISK_VIEW_INVESTIGATION_v0_1_20261020/disk_checks.py';
+  const script='/home/saphir/membrane_compute/viewer/mirror/POINCARE_DISK_VIEW_INVESTIGATION_v0_1_20261020/disk_checks.py';
   let out='',pyok=true;try{out=cp.execFileSync('python',['-I',script],{stdio:['ignore','pipe','pipe'],encoding:'utf8',timeout:120000});}catch(e){pyok=false;out=String(e);}
   ok('B4 disk_checks.py ran live (python -I, stdin closed): exit 0, "FAILURES: 0"',pyok&&/FAILURES: 0/.test(out));
   const m4=/C4 n = 1\.\.30: (\d+) pairs[^\n]*largest m = (\d+)/.exec(out);
diff -ru orig417/build/test-v0411.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/test-v0411.cjs
--- orig417/build/test-v0411.cjs	2026-10-31 12:03:40.109642449 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/test-v0411.cjs	2026-10-31 12:03:40.136642318 +0000
@@ -3,7 +3,7 @@
 const fs=require('fs'),path=require('path'),crypto=require('crypto');
 const C=require('../host-core/comb-core.js'),NUM=require('../host-core/comb-numeric.js'),SC=require('../host-core/stack-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
-const root=path.join(__dirname,'..'),OLD='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_10_20261020';
+const root=path.join(__dirname,'..'),OLD='/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_10_20261020';
 const sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
 const stOf=o=>C.initial({shellMode:'factorial',n1:'4',phi3:'2',m:'2',...o});
 const hop=(x,y)=>{const q=x*x+y*y,d=1+q;return [2*x/d,2*y/d,(q-1)/d];};
diff -ru orig417/build/test-v0412.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/test-v0412.cjs
--- orig417/build/test-v0412.cjs	2026-10-31 12:03:40.109642449 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/test-v0412.cjs	2026-10-31 12:03:40.137642313 +0000
@@ -6,7 +6,7 @@
 require('../instruments/comb-hopf/view-fourier.js');
 const {logModel,logR}=globalThis.FVStackView;
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
-const root=path.join(__dirname,'..'),OLD='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_11_20261021';
+const root=path.join(__dirname,'..'),OLD='/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_11_20261021';
 const sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
 const stOf=o=>C.initial({shellMode:'factorial',n1:'4',phi3:'2',m:'2',...o});
 const ST=[{alpha:'1',n6:'1',m:'2'},{alpha:'-1',n6:'1',m:'2'},{alpha:'2',n6:'1/2',m:'3'},{alpha:'1/2',n6:'3',m:'5'},{alpha:'-1',n6:'-1',m:'4'},{alpha:'3',n6:'-2',m:'2'},{alpha:'-2',n6:'2/3',m:'3'},{n1:'3',alpha:'1',n6:'1',m:'2',phi3:'5'},{n1:'4',phi3:'22',alpha:'1',n6:'1',m:'2'},{n1:'4',phi3:'22',alpha:'-1',n6:'1',m:'2'}];
diff -ru orig417/build/test-v0413.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/test-v0413.cjs
--- orig417/build/test-v0413.cjs	2026-10-31 12:03:40.109642449 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/test-v0413.cjs	2026-10-31 12:03:40.137642313 +0000
@@ -3,7 +3,7 @@
 // (3) the two named panel files and every source file except view-fourier.js equal v0.4.12. The pen drawing is checked in browser-check-v0413.
 const fs=require('fs'),path=require('path'),crypto=require('crypto'),vm=require('vm');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
-const root=path.join(__dirname,'..'),OLD='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_12_20261021';
+const root=path.join(__dirname,'..'),OLD='/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_12_20261021';
 const sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
 ok('v0.4.12 dist sha256 unchanged (b6e0e6e8…)',sha(OLD+'/dist/comb-hopf.html')==='b6e0e6e839b26bfd6304b9f5a273ca171d6a606fb416d663fc1c5da12debf090');
 ok('v0.4.12 SHA256SUMS.txt sha256 unchanged (7d90774e…)',sha(OLD+'/SHA256SUMS.txt')==='7d90774ea9c7f33069df594ad429ae312fb7d30e7eecff5172f260f5f5b7379f');
diff -ru orig417/build/test-v0414.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/test-v0414.cjs
--- orig417/build/test-v0414.cjs	2026-10-31 12:03:40.109642449 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/test-v0414.cjs	2026-10-31 12:03:40.137642313 +0000
@@ -1,7 +1,7 @@
 'use strict';
 // v0.4.14 core test (SCHEMA_ADDENDUM_22): the Goldbach prime-pair mask. Node only. The reference code below is independent of goldbach-core (own sieve, own direct G_N sum).
 const fs=require('fs'),path=require('path'),crypto=require('crypto');
-const root=path.join(__dirname,'..'),BASE='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_13_20261021/';
+const root=path.join(__dirname,'..'),BASE='/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_13_20261021/';
 const C=require('../host-core/comb-core.js'),NUM=require('../host-core/comb-numeric.js'),O=require('../host-core/orbit-core.js'),GB=require('../host-core/goldbach-core.js'),X=require('../exact-lib/exact-lib-0.2.0.js');
 const C0=require(BASE+'host-core/comb-core.js'),NUM0=require(BASE+'host-core/comb-numeric.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
diff -ru orig417/build/test-v047.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/test-v047.cjs
--- orig417/build/test-v047.cjs	2026-10-31 12:03:40.109642449 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/test-v047.cjs	2026-10-31 12:03:40.137642313 +0000
@@ -5,7 +5,7 @@
 const path=require('path');
 const root=path.join(__dirname,'..');
 const C=require('../host-core/comb-core.js'),NUM=require('../host-core/comb-numeric.js'),X=require('../exact-lib/exact-lib-0.2.0.js');
-const OLD='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_6_20261020/';
+const OLD='/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_6_20261020/';
 const C6=require(OLD+'host-core/comb-core.js'),N6=require(OLD+'host-core/comb-numeric.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{if(!c)console.log('FAIL '+n+(x?' '+x:''));c?pass++:fail++;};
 let seed=20261020;const rnd=()=>{seed=(seed*1664525+1013904223)>>>0;return seed/4294967296;};const pick=a=>a[Math.floor(rnd()*a.length)];
diff -ru orig417/build/test-v049.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/test-v049.cjs
--- orig417/build/test-v049.cjs	2026-10-31 12:03:40.109642449 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/test-v049.cjs	2026-10-31 12:03:40.137642313 +0000
@@ -3,7 +3,7 @@
 // The old instrument's own functions (computeVernier, buildFullStack, PlaneCliffordLiftCore, ContinuousRadialDisplayV1) are read from the frozen file (never edited)
 // and run in a Node vm; their point sets are compared with host-core/stack-core.js, which uses this viewer's exact core.
 const fs=require('fs'),vm=require('vm'),path=require('path'),crypto=require('crypto');
-const OLD='C:/Users/robin/s6_atom/cold audit fourier/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/monodromy-31-linked-reduction.html';
+const OLD='/home/saphir/membrane_compute/viewer/mirror/cold audit fourier/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/monodromy-31-linked-reduction.html';
 const OLD_SHA='b4cee4e30a753eda7c62f72e8043d6d5c9b3f69c3c2e1dd0da9a3f9ab5b8e248';
 const X=require('../exact-lib/exact-lib-0.2.0.js'),C=require('../host-core/comb-core.js'),NUM=require('../host-core/comb-numeric.js'),SC=require('../host-core/stack-core.js'),FS=require('../host-core/fraction-stack-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
diff -ru orig417/build/transcribe-elliptic-fixture.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/transcribe-elliptic-fixture.cjs
--- orig417/build/transcribe-elliptic-fixture.cjs	2026-10-31 12:03:40.109642449 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/transcribe-elliptic-fixture.cjs	2026-10-31 12:03:40.137642313 +0000
@@ -3,7 +3,7 @@
 // A parser, not a recomputation: it checks the source sha256 first, then reads each line by a fixed pattern and fails on anything it does not recognise.
 // No floating point: every value stays a string or a BigInt-checked integer string.
 const fs=require('fs'),path=require('path'),crypto=require('crypto');
-const SRC='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029_BRIEF/SAGE_REFERENCE_37a1_20261029.txt';
+const SRC='/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029_BRIEF/SAGE_REFERENCE_37a1_20261029.txt';
 const PIN='599c68552af2521c0b762298875c922e4c03aef29ae7ad4573af614642ab6a72';
 const buf=fs.readFileSync(SRC),h=crypto.createHash('sha256').update(buf).digest('hex');
 if(h!==PIN)throw Error('source sha256 mismatch: '+h);
diff -ru orig417/build/transcribe-rule30-fixture.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/transcribe-rule30-fixture.cjs
--- orig417/build/transcribe-rule30-fixture.cjs	2026-10-31 12:03:40.109642449 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/build/transcribe-rule30-fixture.cjs	2026-10-31 12:03:40.137642313 +0000
@@ -2,7 +2,7 @@
 // v0.4.16: transcribes the pinned rule30 outputs (READ ONLY; nothing in rule30_prize_research_2026_10_26/ is run, copied or written) into fixtures/rule30-ladder-fixture.json.
 // The source sha256 values are checked against the brief's pins before anything is written.
 const fs=require('fs'),path=require('path'),crypto=require('crypto');
-const SRC='C:/Users/robin/s6_atom/rule30_prize_research_2026_10_26/';
+const SRC='/home/saphir/membrane_compute/viewer/mirror/rule30_prize_research_2026_10_26/';
 const PINS={'opus_two_adic_n2_densities_v0_1_20261028.output.txt':'72d0bd143c106c37ff3b1e8a46aa44d7605a8c17a88bee0990b0ce886fc7efcf',
   'opus_two_adic_n2_lemma_check_v0_1_20261028.output.txt':'fa24e8067419383eb0184b4868468a3d6b1c5072ac20e8cd1e75ef887585defd',
   'opus_two_adic_n2_v0_1_20261028.sha256':'677bfe28bae82f6fed3b4716a2fceacd521e2c8c281b5063d1f0fe173e8035a8'};
diff -ru orig417/host-core/parity-sample.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/host-core/parity-sample.cjs
--- orig417/host-core/parity-sample.cjs	2026-10-31 12:03:40.111642440 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/host-core/parity-sample.cjs	2026-10-31 12:03:40.137642313 +0000
@@ -2,7 +2,7 @@
 // Informative parity sample (not R18): 2000 random integer-gear states, rebuild vs frozen v0.3.2 comb-core.js / control-math.js (read-only load).
 // Every difference is listed with its class: (a) mandated by R20/R21, (d) reference defect reproduced by exact arithmetic, or UNEXPLAINED.
 const X=require('../exact-lib/exact-lib-0.2.0.js'),C=require('./comb-core.js');
-const F='C:/Users/robin/s6_atom/cubic_Fourier/DIVISOR_COMB_RIEMANN_v0_3_2_20261012/';
+const F='/home/saphir/membrane_compute/viewer/mirror/cubic_Fourier/DIVISOR_COMB_RIEMANN_v0_3_2_20261012/';
 const HC=require(F+'comb-core.js'),HM=require(F+'control-math.js');
 let seed=0x12345678;const rnd=()=>{seed^=seed<<13;seed>>>=0;seed^=seed>>>17;seed^=seed<<5;seed>>>=0;return seed/4294967296;};
 const ri=(a,b)=>a+Math.floor(rnd()*(b-a+1)),pick=a=>a[ri(0,a.length-1)];
diff -ru orig417/host-core/test-core.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/host-core/test-core.cjs
--- orig417/host-core/test-core.cjs	2026-10-31 12:03:40.111642440 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/host-core/test-core.cjs	2026-10-31 12:03:40.138642308 +0000
@@ -197,7 +197,7 @@
 
 // ---------- addendum tests: shell core, flags, gates, lift, gearbox parity
 const SH=require('./shell-core.js');
-const FROZEN='C:/Users/robin/s6_atom/cubic_Fourier/DIVISOR_COMB_RIEMANN_v0_3_2_20261012/';
+const FROZEN='/home/saphir/membrane_compute/viewer/mirror/cubic_Fourier/DIVISOR_COMB_RIEMANN_v0_3_2_20261012/';
 t('SPREAD/ALIGN exact flags vs numerical |K_m| < 1e-9 at 2000 random states (any disagreement fails)',()=>{
   let bad=0,zeros=0;
   for(let i=0;i<2000;i++){
diff -ru orig417/host-core/test-elliptic-exact.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/host-core/test-elliptic-exact.cjs
--- orig417/host-core/test-elliptic-exact.cjs	2026-10-31 12:03:40.111642440 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/host-core/test-elliptic-exact.cjs	2026-10-31 12:03:40.138642308 +0000
@@ -6,7 +6,7 @@
 let pass=0,fail=0;
 function t(name,fn){let ok=false,msg='';try{const r=fn();ok=r===true;if(!ok&&r!==false)msg=' '+r;}catch(e){msg=' threw: '+e.message;}console.log((ok?'PASS ':'FAIL ')+name+msg);ok?pass++:fail++;}
 const FIX=path.join(__dirname,'..','fixtures','elliptic-37a1-fixture.json'),fx=JSON.parse(fs.readFileSync(FIX,'utf8'));
-const SRC='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029_BRIEF/SAGE_REFERENCE_37a1_20261029.txt';
+const SRC='/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029_BRIEF/SAGE_REFERENCE_37a1_20261029.txt';
 const B=s=>BigInt(s),A=fx.ainvs.map(B),C=E.curveQ(A),P=E.pt(E.Q(B(fx.generator.x)),E.Q(B(fx.generator.y)));
 const qs=E.qascii;
 t('fixture records the source sha256 599c6855…',()=>fx.source.sha256==='599c68552af2521c0b762298875c922e4c03aef29ae7ad4573af614642ab6a72');
diff -ru orig417/host-core/test-rule30-ladder.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/host-core/test-rule30-ladder.cjs
--- orig417/host-core/test-rule30-ladder.cjs	2026-10-31 12:03:40.111642440 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/host-core/test-rule30-ladder.cjs	2026-10-31 12:03:40.138642308 +0000
@@ -13,7 +13,7 @@
 const REF={};for(const r of [30,90,150]){const xs=[];let x=1n;do{xs.push(x);x=F[r](x)&M35;}while(x!==1n&&xs.length<100000);REF[r]=xs;}
 const bit=(x,j)=>Number((x>>BigInt(j))&1n);
 t('fixture source hashes recorded (densities 72d0bd14…, lemma fa24e806…, manifest 677bfe28…)',()=>fx.sources.map(s=>s.sha256.slice(0,8)).join()==='72d0bd14,fa24e806,677bfe28');
-{const SRC='C:/Users/robin/s6_atom/rule30_prize_research_2026_10_26/';let seen=0,okh=true;
+{const SRC='/home/saphir/membrane_compute/viewer/mirror/rule30_prize_research_2026_10_26/';let seen=0,okh=true;
  for(const s of fx.sources){const f=SRC+path.basename(s.file);if(fs.existsSync(f)){seen++;if(crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex')!==s.sha256)okh=false;}}
  t('pinned sources still match their sha256 (read only; '+seen+' of 3 present)',()=>okh&&seen===3);}
 for(const r of L.RULES){const R=fx.rules[r],T=L.table(r);
```

### diff: v0.4.18 copy
```diff
diff -ru orig418/build/browser-check.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check.cjs
--- orig418/build/browser-check.cjs	2026-10-31 12:37:31.881403754 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check.cjs	2026-10-31 12:37:31.909403609 +0000
@@ -1,7 +1,7 @@
 'use strict';
 // Browser check (Playwright from s6_atom/node_modules): loads dist/comb-hopf.html over file://, screenshots, exercises tabs, stepping, exports.
 const path=require('path'),fs=require('fs');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').replace(/\\/g,'/');
 let pass=0,fail=0,minFont=1e9;
 const expOpen=async(p,imp)=>{if(!(await p.locator('#expmenu').isVisible()))await p.click('#expBtn');if(imp&&!(await p.locator('#imp').isVisible()))await p.click('#impShow');await p.waitForTimeout(40);};const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x?' '+x:''));c?pass++:fail++;};
diff -ru orig418/build/browser-check-legacy-panels-v0418.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-legacy-panels-v0418.cjs
--- orig418/build/browser-check-legacy-panels-v0418.cjs	2026-10-31 12:37:31.881403754 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-legacy-panels-v0418.cjs	2026-10-31 12:37:31.905403630 +0000
@@ -5,11 +5,11 @@
 //   the group heading element "E. Surface pens (exact)" (v0.4.18);
 //   and the decided group-D heading text "D. Elliptic and BSD" is mapped back to v0.4.16's "D. Elliptic and BSD (placement pending saphir)" (fix-up 1).
 // Also: the other tabs are identical (stage, caption, cards, address), and with D1 on, the cards differ only by the one "see also" paragraph.
-// Both pages render in the same browser on the same host. The v0.4.16 page is read only (sha256 pinned). Location: FV_ROOT (default C:/Users/robin/s6_atom).
+// Both pages render in the same browser on the same host. The v0.4.16 page is read only (sha256 pinned). Location: FV_ROOT (default /home/saphir/membrane_compute/viewer/mirror).
 const path=require('path'),fs=require('fs'),crypto=require('crypto'),{pathToFileURL}=require('url');
-const PW=(()=>{try{return require('playwright');}catch(e){return require(process.env.PLAYWRIGHT_DIR||'C:/Users/robin/s6_atom/node_modules/playwright');}})();
+const PW=(()=>{try{return require('playwright');}catch(e){return require(process.env.PLAYWRIGHT_DIR||'/home/saphir/membrane_compute/viewer/mirror/node_modules/playwright');}})();
 const CC=require('../host-core/comb-core.js');
-const root=path.join(__dirname,'..'),FV_ROOT=process.env.FV_ROOT||'C:/Users/robin/s6_atom';
+const root=path.join(__dirname,'..'),FV_ROOT=process.env.FV_ROOT||'/home/saphir/membrane_compute/viewer/mirror';
 const OLD=path.join(FV_ROOT,'FOURIER_VIEWER_PROTOTYPE_v0_4_16_20261028','dist','comb-hopf.html'),OLDSHA='1da7dc8f8cad8c31f22e302a92e763fdc95b71abf4d3dc559fcad33df88c1b71';
 const url=pathToFileURL(path.join(root,'dist','comb-hopf.html')).href,url416=pathToFileURL(OLD).href;
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
diff -ru orig418/build/browser-check-mirror.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-mirror.cjs
--- orig418/build/browser-check-mirror.cjs	2026-10-31 12:37:31.881403754 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-mirror.cjs	2026-10-31 12:37:31.905403630 +0000
@@ -2,7 +2,7 @@
 // v0.4 browser check of the mirror axis (T-MA in the page; R1–R4 as amended by the S0 design review §5). Playwright from s6_atom/node_modules, dist page over file://.
 // The v0.3 suite build/browser-check.cjs runs unchanged beside this one.
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').replace(/\\/g,'/');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
 const B={shellMode:'integer',B:'24',nMode:'integer',n6:'1',alpha:'0'};
diff -ru orig418/build/browser-check-v0410.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v0410.cjs
--- orig418/build/browser-check-v0410.cjs	2026-10-31 12:37:31.881403754 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v0410.cjs	2026-10-31 12:37:31.905403630 +0000
@@ -3,9 +3,9 @@
 // (1) counts 39/41/39/41 unchanged, also on the n² + 1 track; (2) every v0.4.9 check state: state, address, exact export (JSON, state, CSV, Lift JSON, stats), caption, cards, about, canvas and PNG export byte-identical to v0.4.9;
 // the Panels tab differs only by the two new (collapsed) card elements; (3) the cards: contents, gates, idle captions, canvas geometry, tessellation parity, pairing lines; (4) the preset track and its address key; (5) no horizontal scroll at 375; (6) shots shot_v0410_*.
 const fs=require('fs'),path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const url=u(path.join(root,'dist','comb-hopf.html')),url49=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_9_20261020/dist/comb-hopf.html');
+const url=u(path.join(root,'dist','comb-hopf.html')),url49=u('/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_9_20261020/dist/comb-hopf.html');
 const CC=require('../host-core/comb-core.js'),BD=require('../host-core/branch-disk-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
 const addr=(o,extra)=>CC.encodeAddress(CC.initial(o))+(extra||'');
diff -ru orig418/build/browser-check-v0411.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v0411.cjs
--- orig418/build/browser-check-v0411.cjs	2026-10-31 12:37:31.881403754 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v0411.cjs	2026-10-31 12:37:31.906403625 +0000
@@ -4,9 +4,9 @@
 // (3) the layer: view keys fr/cr/hr only when on, menu item only while the Full stack is on, toggle round trip, reload restores, data attributes, canvas changes;
 // (4) Hopf: ink at the expected reflected positions (control: the primary positions); (5) no key collision; (6) no horizontal scroll at 375; (7) shots shot_v0411_*.
 const fs=require('fs'),path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const url=u(path.join(root,'dist','comb-hopf.html')),url410=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_10_20261020/dist/comb-hopf.html');
+const url=u(path.join(root,'dist','comb-hopf.html')),url410=u('/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_10_20261020/dist/comb-hopf.html');
 const CC=require('../host-core/comb-core.js'),SC=require('../host-core/stack-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
 const addr=(o,extra)=>CC.encodeAddress(CC.initial(o))+(extra||'');
diff -ru orig418/build/browser-check-v0412.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v0412.cjs
--- orig418/build/browser-check-v0412.cjs	2026-10-31 12:37:31.881403754 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v0412.cjs	2026-10-31 12:37:31.906403625 +0000
@@ -4,9 +4,9 @@
 // (3) the layer: key fl only when on, menu item only while the Full stack is on, toggle round trip, reload, inert with the stack off, data attributes, caption wording, throat circle, log rings, R(1) = R_t;
 // (4) pixel probe: ink at the expected log positions of both halves; Clifford and Hopf unchanged by fl; (5) key unique; (6) no horizontal scroll; (7) shots shot_v0412_*.
 const fs=require('fs'),path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const url=u(path.join(root,'dist','comb-hopf.html')),url411=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_11_20261021/dist/comb-hopf.html');
+const url=u(path.join(root,'dist','comb-hopf.html')),url411=u('/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_11_20261021/dist/comb-hopf.html');
 const CC=require('../host-core/comb-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
 const addr=(o,extra)=>CC.encodeAddress(CC.initial(o))+(extra||'');
diff -ru orig418/build/browser-check-v0413.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v0413.cjs
--- orig418/build/browser-check-v0413.cjs	2026-10-31 12:37:31.881403754 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v0413.cjs	2026-10-31 12:37:31.906403625 +0000
@@ -1,9 +1,9 @@
 'use strict';
 // v0.4.13 browser check (SCHEMA_ADDENDUM_21): in log mode only the stack is log-mapped; pen, teeth, carrier on a linear scale with a scale bar. 1280x800 and 375x812.
 const fs=require('fs'),path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const url=u(path.join(root,'dist','comb-hopf.html')),url412=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_12_20261021/dist/comb-hopf.html');
+const url=u(path.join(root,'dist','comb-hopf.html')),url412=u('/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_12_20261021/dist/comb-hopf.html');
 const CC=require('../host-core/comb-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
 const addr=(o,extra)=>CC.encodeAddress(CC.initial(o))+(extra||'');
diff -ru orig418/build/browser-check-v0414.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v0414.cjs
--- orig418/build/browser-check-v0414.cjs	2026-10-31 12:37:31.881403754 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v0414.cjs	2026-10-31 12:37:31.906403625 +0000
@@ -1,9 +1,9 @@
 'use strict';
 // v0.4.14 browser check (SCHEMA_ADDENDUM_22): the Goldbach prime-pair track "Goldbach N ▸". 1280x800 and 375x812. The reference arithmetic is independent of goldbach-core (own sieve, own G_N).
 const fs=require('fs'),path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const url=u(path.join(root,'dist','comb-hopf.html')),url413=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_13_20261021/dist/comb-hopf.html');
+const url=u(path.join(root,'dist','comb-hopf.html')),url413=u('/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_13_20261021/dist/comb-hopf.html');
 const CC=require('../host-core/comb-core.js'),GB=require('../host-core/goldbach-core.js'),X=require('../exact-lib/exact-lib-0.2.0.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
 const LIM=1500,comp=new Uint8Array(LIM+1);comp[0]=comp[1]=1;for(let i=2;i*i<=LIM;i++)if(!comp[i])for(let j=i*i;j<=LIM;j+=i)comp[j]=1;
diff -ru orig418/build/browser-check-v0416.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v0416.cjs
--- orig418/build/browser-check-v0416.cjs	2026-10-31 12:37:31.881403754 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v0416.cjs	2026-10-31 12:37:31.906403625 +0000
@@ -3,10 +3,10 @@
 // Cases: rule 30 j = 3 (doubling), rule 30 j = 5 (stall), rule 90 j = 3 (density 0), each at q = 1, 2, 4, 8. Expected values come from the core (itself checked against the pinned rule30 fixture by test-rule30-ladder).
 // D1 off: the page is compared with the v0.4.14 build (stage, canvas, caption, about, cards, address) on 8 states, and the visible-control counts are compared.
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const CC=require('../host-core/comb-core.js'),RL=require('../host-core/rule30-ladder-core.js');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const url=u(path.join(root,'dist','comb-hopf.html')),url414=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_14_20261021/dist/comb-hopf.html');
+const url=u(path.join(root,'dist','comb-hopf.html')),url414=u('/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_14_20261021/dist/comb-hopf.html');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
 const addr=(o)=>CC.encodeAddress(CC.initial(o));
 const count=pg=>pg.evaluate(()=>{const vis=e=>{const r=e.getBoundingClientRect(),cs=getComputedStyle(e);return r.width>0&&r.height>0&&cs.display!=='none'&&cs.visibility!=='hidden'&&!e.closest('[style*="display: none"]')&&!e.closest('[hidden]');};
diff -ru orig418/build/browser-check-v0417.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v0417.cjs
--- orig418/build/browser-check-v0417.cjs	2026-10-31 12:37:31.881403754 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v0417.cjs	2026-10-31 12:37:31.908403615 +0000
@@ -6,10 +6,10 @@
 // elements are removed, and the other tabs are identical to v0.4.16 (stage, caption, cards, address). The v0.4.16 page is read only (sha256 pinned).
 // No floating point: pixel counts are integers; times are integer milliseconds from Date.now.
 const path=require('path'),fs=require('fs'),crypto=require('crypto');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const CC=require('../host-core/comb-core.js'),EX=require('../host-core/elliptic-exact-core.js'),PE=require('../host-core/elliptic-period-core.js');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const OLD='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_16_20261028/dist/comb-hopf.html',OLDSHA='1da7dc8f8cad8c31f22e302a92e763fdc95b71abf4d3dc559fcad33df88c1b71';
+const OLD='/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_16_20261028/dist/comb-hopf.html',OLDSHA='1da7dc8f8cad8c31f22e302a92e763fdc95b71abf4d3dc559fcad33df88c1b71';
 const url=u(path.join(root,'dist','comb-hopf.html')),url416=u(OLD);
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
 const addr=o=>CC.encodeAddress(CC.initial(o));
diff -ru orig418/build/browser-check-v0418.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v0418.cjs
--- orig418/build/browser-check-v0418.cjs	2026-10-31 12:37:31.881403754 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v0418.cjs	2026-10-31 12:37:31.908403615 +0000
@@ -3,7 +3,7 @@
 // at 1280x800 and 375x812. Expected values come from the cores run here in Node (themselves checked by test-pen-*). Portable: playwright through
 // NODE_PATH (or PLAYWRIGHT_DIR), with Neo's path as the fallback. No floating point: counts are integers, times integer milliseconds from Date.now.
 const path=require('path'),fs=require('fs'),{pathToFileURL}=require('url');
-const PW=(()=>{try{return require('playwright');}catch(e){return require(process.env.PLAYWRIGHT_DIR||'C:/Users/robin/s6_atom/node_modules/playwright');}})();
+const PW=(()=>{try{return require('playwright');}catch(e){return require(process.env.PLAYWRIGHT_DIR||'/home/saphir/membrane_compute/viewer/mirror/node_modules/playwright');}})();
 const CC=require('../host-core/comb-core.js'),ST=require('../host-core/pen-streams-core.js'),CV=require('../host-core/pen-curvature-core.js'),SP=require('../host-core/pen-sphere-core.js'),EX=require('../host-core/elliptic-exact-core.js');
 const root=path.join(__dirname,'..'),url=pathToFileURL(path.join(root,'dist','comb-hopf.html')).href;
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
diff -ru orig418/build/browser-check-v041.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v041.cjs
--- orig418/build/browser-check-v041.cjs	2026-10-31 12:37:31.881403754 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v041.cjs	2026-10-31 12:37:31.905403630 +0000
@@ -2,9 +2,9 @@
 // v0.4.1 browser check (SCHEMA_ADDENDUM_9): shell range n1 = 1..13 / B >= 1, the star on t1*s in Z, the carrier foliation (display register).
 // Playwright from s6_atom/node_modules; dist pages over file:// (v0.4 page read-only, for the byte-identity comparison with the foliation off).
 const path=require('path'),crypto=require('crypto');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').replace(/\\/g,'/');
-const url04='file:///C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_20261019/dist/comb-hopf.html';
+const url04='file:///home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_20261019/dist/comb-hopf.html';
 const CC=require('../host-core/comb-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
 const addr=o=>CC.encodeAddress(CC.enterSpin(CC.initial(o),o.sTyped||'1'));
diff -ru orig418/build/browser-check-v042.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v042.cjs
--- orig418/build/browser-check-v042.cjs	2026-10-31 12:37:31.881403754 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v042.cjs	2026-10-31 12:37:31.908403615 +0000
@@ -2,9 +2,9 @@
 // v0.4.2 browser check (SCHEMA_ADDENDUM_10): (1) the N = 0 Wilson wording on the page and in the exports; (2) the shell-switch clamp phi3 -> B (N = 1).
 // Playwright from s6_atom/node_modules; dist pages over file://. The v0.4.1 page is opened read-only, for the comparisons.
 const path=require('path'),crypto=require('crypto');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').replace(/\\/g,'/');
-const url41='file:///C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_1_20261019/dist/comb-hopf.html';
+const url41='file:///home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_1_20261019/dist/comb-hopf.html';
 const CC=require('../host-core/comb-core.js');
 const NEW='N = 0: no comb, so the Wilson test does not apply.',OLD='N = 1 is not prime.';
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
diff -ru orig418/build/browser-check-v043.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v043.cjs
--- orig418/build/browser-check-v043.cjs	2026-10-31 12:37:31.881403754 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v043.cjs	2026-10-31 12:37:31.908403615 +0000
@@ -2,7 +2,7 @@
 // v0.4.3 browser check (SCHEMA_ADDENDUM_11): the canvas bitmap is full resolution while the camera moves (Clifford and Hopf), and after release;
 // the 'surface' kind still yields half size (unit level, through FVViews.resFactor and a probe canvas).
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/');
 const REPRO={shellMode:'factorial',n1:'4',phi3:'6',alpha:'-1/50',n6:'1',t1:'1',t2:'-21/4',m:'3'};
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
diff -ru orig418/build/browser-check-v044.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v044.cjs
--- orig418/build/browser-check-v044.cjs	2026-10-31 12:37:31.881403754 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v044.cjs	2026-10-31 12:37:31.908403615 +0000
@@ -3,9 +3,9 @@
 // (port of the accepted RH margin panel) read from the DOM and compared with rhm-core.js, no horizontal scroll at 375,
 // non-CA states unchanged against the v0.4.3 dist, and the shot_v044_* screenshots.
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const url=u(path.join(root,'dist','comb-hopf.html')),url43=u(path.join('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_3_20261019','dist','comb-hopf.html'));
+const url=u(path.join(root,'dist','comb-hopf.html')),url43=u(path.join('/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_3_20261019','dist','comb-hopf.html'));
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
 const EXP={2:['3/2','2.152786','fails'],6:['2','0.961281','fails'],12:['7/3','0.712138','fails'],60:['14/5','0.289388','fails'],120:['3','0.210828','fails'],360:['13/4','0.092881','fails'],2520:['26/7','0.048447','fails'],5040:['403/105','0.021217','fails'],55440:['1612/385','\u22120.071311','holds'],720720:['248/55','\u22120.124905','holds']};
 const SAMPLES=[{shellMode:'factorial',n1:'4',phi3:'6',m:'3',t1:'1',t2:'1',tab:'fourier'},{shellMode:'factorial',n1:'5',phi3:'0',m:'6',t1:'1',t2:'-21/4',tab:'clifford'},{shellMode:'integer',B:'24',phi3:'20',m:'5',t1:'1',t2:'2',tab:'hopf'},
diff -ru orig418/build/browser-check-v045.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v045.cjs
--- orig418/build/browser-check-v045.cjs	2026-10-31 12:37:31.881403754 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v045.cjs	2026-10-31 12:37:31.908403615 +0000
@@ -4,9 +4,9 @@
 // "visible controls ... <= 40" assertions, the two continuous-mode inventory assertions, and the "N mode switch" assertion). The counting method is the old one verbatim (layout(): visible button/input/select
 // inside #inst or .header, minus .info buttons).
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const url=u(path.join(root,'dist','comb-hopf.html')),url44=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_4_20261020/dist/comb-hopf.html');
+const url=u(path.join(root,'dist','comb-hopf.html')),url44=u('/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_4_20261020/dist/comb-hopf.html');
 const CC=require('../host-core/comb-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
 const PRESETS=['2','6','12','60','120','360','2520','5040','55440','720720'];
diff -ru orig418/build/browser-check-v046.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v046.cjs
--- orig418/build/browser-check-v046.cjs	2026-10-31 12:37:31.881403754 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v046.cjs	2026-10-31 12:37:31.908403615 +0000
@@ -1,9 +1,9 @@
 'use strict';
 // v0.4.6 browser check (SCHEMA_ADDENDUM_14): n1 group hidden in integer mode; counts; addresses identical to v0.4.5.
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const url=u(path.join(root,'dist','comb-hopf.html')),url45=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_5_20261020/dist/comb-hopf.html');
+const url=u(path.join(root,'dist','comb-hopf.html')),url45=u('/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_5_20261020/dist/comb-hopf.html');
 const CC=require('../host-core/comb-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
 const addr=o=>CC.encodeAddress(CC.initial(o));
diff -ru orig418/build/browser-check-v047.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v047.cjs
--- orig418/build/browser-check-v047.cjs	2026-10-31 12:37:31.881403754 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v047.cjs	2026-10-31 12:37:31.908403615 +0000
@@ -1,9 +1,9 @@
 'use strict';
 // v0.4.7 browser check (SCHEMA_ADDENDUM_15): alpha_Tilt as a walk weight. Design note section 9, tests 1 (browser part), 6, 7, 8, 10, 11, and the shots.
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const url=u(path.join(root,'dist','comb-hopf.html')),url46=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_6_20261020/dist/comb-hopf.html');
+const url=u(path.join(root,'dist','comb-hopf.html')),url46=u('/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_6_20261020/dist/comb-hopf.html');
 const CC=require('../host-core/comb-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
 const addr=(o,tilt)=>CC.encodeAddress(CC.initial(o))+(tilt?'&tilt='+tilt:'');
diff -ru orig418/build/browser-check-v048.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v048.cjs
--- orig418/build/browser-check-v048.cjs	2026-10-31 12:37:31.881403754 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v048.cjs	2026-10-31 12:37:31.909403609 +0000
@@ -1,9 +1,9 @@
 'use strict';
 // v0.4.8 check (SCHEMA_ADDENDUM_16): shorter tilt wording in the Fourier caption; Q-res visible at 1280x800; tilt 0 identical to v0.4.7; Panels relabel; shots.
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const url=u(path.join(root,'dist','comb-hopf.html')),url47=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_7_20261020/dist/comb-hopf.html');
+const url=u(path.join(root,'dist','comb-hopf.html')),url47=u('/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_7_20261020/dist/comb-hopf.html');
 const CC=require('../host-core/comb-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
 const gopen=async(pg,hash,base)=>{await pg.goto((base||url)+hash);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(400);};
diff -ru orig418/build/browser-check-v049.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v049.cjs
--- orig418/build/browser-check-v049.cjs	2026-10-31 12:37:31.881403754 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/browser-check-v049.cjs	2026-10-31 12:37:31.909403609 +0000
@@ -4,9 +4,9 @@
 // (3) the page's stack equals stack-core in Node and the OLD instrument's buildFullStack (frozen file, run in a Node vm); (4) dots really drawn; (5) address key only when on;
 // (6) signature cache: an s change does not redraw the stack bitmap; (7) no horizontal scroll at 375; (8) shots shot_v049_*.
 const fs=require('fs'),vm=require('vm'),path=require('path'),crypto=require('crypto');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
-const url=u(path.join(root,'dist','comb-hopf.html')),url48=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_8_20261020/dist/comb-hopf.html');
+const url=u(path.join(root,'dist','comb-hopf.html')),url48=u('/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_8_20261020/dist/comb-hopf.html');
 const CC=require('../host-core/comb-core.js'),SC=require('../host-core/stack-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
 const addr=(o,extra)=>CC.encodeAddress(CC.initial(o))+(extra||'');
@@ -16,7 +16,7 @@
 const snap=pg=>pg.evaluate(()=>({stage:document.getElementById('stage').innerHTML,cv:(()=>{try{return document.getElementById('stagecv').toDataURL();}catch(e){return '';}})(),caption:document.getElementById('caption').innerHTML,about:document.getElementById('about').innerHTML,cards:document.getElementById('cards').innerHTML,addr:document.getElementById('addr').textContent,hash:location.hash,st:JSON.stringify(FVPanel.state)}));
 const pngHash=pg=>pg.evaluate(async()=>{const b=await FVPanel.exportPng();const a=new Uint8Array(await b.arrayBuffer());const d=await crypto.subtle.digest('SHA-256',a);return [...new Uint8Array(d)].map(x=>x.toString(16).padStart(2,'0')).join('');});
 // ---- the old instrument's buildFullStack in a vm (read only)
-const OLD='C:/Users/robin/s6_atom/cold audit fourier/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/monodromy-31-linked-reduction.html',src=fs.readFileSync(OLD,'utf8');
+const OLD='/home/saphir/membrane_compute/viewer/mirror/cold audit fourier/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/monodromy-31-linked-reduction.html',src=fs.readFileSync(OLD,'utf8');
 function block(t){const i=src.indexOf(t);let j=src.indexOf('{',i),d=0;for(;j<src.length;j++){if(src[j]==='{')d++;else if(src[j]==='}'){d--;if(d===0)break;}}return src.slice(i,j+1);}
 const vctx={Math,Number,String,Object,Array,JSON};vm.createContext(vctx);
 vm.runInContext('var state={};function factorial(n){let f=1;for(let k=2;k<=n;k++)f*=k;return f;}function gearboxExactText(k){return state[k+"Exact"];}let _stackCache=null,_stackCacheKey=null,_stackDrawSig=null;\n'+['function selectedShellBase(','function selectedShellSpan(','function combOffsets(','function combKernel(','function reducedHalfTurns(','function stableGearboxAngle(','function computeVernier(','function buildFullStack('].map(block).join('\n'),vctx);
diff -ru orig418/build/package.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/package.cjs
--- orig418/build/package.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/package.cjs	2026-10-31 12:37:31.910403604 +0000
@@ -4,7 +4,7 @@
 const root=path.join(__dirname,'..'),dir=path.join(root,'instruments','comb-hopf');
 const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
 let html=fs.readFileSync(path.join(dir,'index.html'),'utf8');
-const LIBSHA='3edfc8fb396fda90cfa945963eb18ccdf243f5a491e3ee49275b5c459a223a71',LIBSRC='C:/Users/robin/s6_atom/FOURIER_VIEWER_LIBS/exact-lib-0.2.0/dist/exact-lib.js';
+const LIBSHA='3edfc8fb396fda90cfa945963eb18ccdf243f5a491e3ee49275b5c459a223a71',LIBSRC='/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_LIBS/exact-lib-0.2.0/dist/exact-lib.js';
 const libCopy=path.join(root,'exact-lib','exact-lib-0.2.0.js');
 if(sha(fs.readFileSync(libCopy))!==LIBSHA)throw Error('exact-lib 0.2.0 sha256 mismatch');
 if(fs.existsSync(LIBSRC)&&sha(fs.readFileSync(LIBSRC))!==LIBSHA)throw Error('exact-lib 0.2.0 source sha256 mismatch');
diff -ru orig418/build/perf-bench.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/perf-bench.cjs
--- orig418/build/perf-bench.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/perf-bench.cjs	2026-10-31 12:37:31.910403604 +0000
@@ -1,7 +1,7 @@
 'use strict';
 // Performance bench (Playwright from s6_atom/node_modules). Usage: node perf-bench.cjs [url] ; prints JSON tables for 1x and 4x CPU throttle.
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url=process.argv[2]||'file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/');
 const REPRO={shellMode:'factorial',n1:'4',phi3:'6',alpha:'-1/50',n6:'1',t1:'1',t2:'-21/4',m:'3'};
 const med=a=>{const s=[...a].sort((x,y)=>x-y);return s[Math.floor(s.length/2)];};
diff -ru orig418/build/perf-camera.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/perf-camera.cjs
--- orig418/build/perf-camera.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/perf-camera.cjs	2026-10-31 12:37:31.910403604 +0000
@@ -2,7 +2,7 @@
 // Camera / drag / first-render bench (performance round 2). Usage: node perf-camera.cjs [url] ; JSON for 1x and 4x CPU throttle.
 // Camera: 60 synthetic pointer/wheel events, one per animation frame, at the reproduction state. fps = 60 / total seconds (frame-rate limited at about 58 on this harness).
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url=process.argv[2]||'file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/');
 const REPRO={shellMode:'factorial',n1:'4',phi3:'6',alpha:'-1/50',n6:'1',t1:'1',t2:'-21/4',m:'3'};
 const med=a=>{const s=[...a].sort((x,y)=>x-y);return s[Math.floor(s.length/2)];};
diff -ru orig418/build/perf-camprofile.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/perf-camprofile.cjs
--- orig418/build/perf-camprofile.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/perf-camprofile.cjs	2026-10-31 12:37:31.910403604 +0000
@@ -1,7 +1,7 @@
 'use strict';
 // CDP Profiler + trace categories while rotating the camera 60 frames on one tab (reproduction state). Usage: node perf-camprofile.cjs [tab] [throttle] [kind]
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist',process.env.F||'comb-hopf.html').split(path.sep).join('/'),tab=process.argv[2]||'hopf',thr=+process.argv[3]||4,kind=process.argv[4]||'rotate';
 (async()=>{
   const b=await chromium.launch(),ctx=await b.newContext({viewport:{width:1280,height:800}}),page=await ctx.newPage(),cdp=await ctx.newCDPSession(page);
diff -ru orig418/build/perf-cdp.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/perf-cdp.cjs
--- orig418/build/perf-cdp.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/perf-cdp.cjs	2026-10-31 12:37:31.910403604 +0000
@@ -1,7 +1,7 @@
 'use strict';
 // CDP Profiler + Tracing: self time by function and main-thread event categories while stepping phi3 40 times on one tab at the reproduction state.
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url=process.argv[2]||'file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/'),tab=process.argv[3]||'clifford',mode=process.argv[4]||'step',thr=+process.argv[5]||1;
 (async()=>{
   const b=await chromium.launch(),ctx=await b.newContext({viewport:{width:1280,height:800}}),page=await ctx.newPage(),cdp=await ctx.newCDPSession(page);
diff -ru orig418/build/perf-first.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/perf-first.cjs
--- orig418/build/perf-first.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/perf-first.cjs	2026-10-31 12:37:31.910403604 +0000
@@ -1,7 +1,7 @@
 'use strict';
 // First render, A/B interleaved: page load to the first frame presented after the first full render (rAF after FVPanel.perf.n > 0), per tab, 1x and 4x CPU throttle.
 // Usage: node perf-first.cjs <urlA> [urlB] ; load order alternates A, B, A, B ... (9 loads each) so machine noise hits both alike; medians.
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const urls=process.argv.slice(2);if(!urls.length)throw Error('usage: node perf-first.cjs urlA [urlB]');
 const REPRO={shellMode:'factorial',n1:'4',phi3:'6',alpha:'-1/50',n6:'1',t1:'1',t2:'-21/4',m:'3'};
 const med=a=>{const s=[...a].sort((x,y)=>x-y);return s[Math.floor(s.length/2)];};
diff -ru orig418/build/perf-frame-v043.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/perf-frame-v043.cjs
--- orig418/build/perf-frame-v043.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/perf-frame-v043.cjs	2026-10-31 12:37:31.910403604 +0000
@@ -1,7 +1,7 @@
 'use strict';
 // v0.4.3: frame time while rotating (Clifford and Hopf). Usage: node perf-frame-v043.cjs <url> <width> <height> <dsf> <throttle> [runs]
 // 90 synthetic pointer moves per run, one per animation frame, as perf-camera.cjs does; per-frame time = interval between consecutive frames. Reports median and p95 over all frames of all runs.
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const [url,W,H,DSF,THR,RUNS]=[process.argv[2],+process.argv[3],+process.argv[4],+process.argv[5],+process.argv[6],+(process.argv[7]||5)];
 const REPRO={shellMode:'factorial',n1:'4',phi3:'6',alpha:'-1/50',n6:'1',t1:'1',t2:'-21/4',m:'3'};
 const q=(a,p)=>{const s=[...a].sort((x,y)=>x-y);return s[Math.min(s.length-1,Math.floor(p*s.length))];};
diff -ru orig418/build/perf-load.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/perf-load.cjs
--- orig418/build/perf-load.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/perf-load.cjs	2026-10-31 12:37:31.910403604 +0000
@@ -1,7 +1,7 @@
 'use strict';
 // Where the page-load time goes: CDP trace of one load (throttle via argv[2]), main-thread events by name. Usage: node perf-load.cjs [throttle] [hash]
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/'),thr=+process.argv[2]||4,hash=process.argv[3]||'';
 (async()=>{
   const b=await chromium.launch(),ctx=await b.newContext({viewport:{width:1280,height:800}}),page=await ctx.newPage(),cdp=await ctx.newCDPSession(page);
diff -ru orig418/build/perf-profile.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/perf-profile.cjs
--- orig418/build/perf-profile.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/perf-profile.cjs	2026-10-31 12:37:31.910403604 +0000
@@ -1,7 +1,7 @@
 'use strict';
 // Where does a render go? Per-phase wall times (performance.now) at the reproduction state, per tab, plus DOM/SVG size.
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url=process.argv[2]||'file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/');
 (async()=>{
   const b=await chromium.launch(),ctx=await b.newContext({viewport:{width:1280,height:800}}),page=await ctx.newPage();
diff -ru orig418/build/probe-old-lift-alpha.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/probe-old-lift-alpha.cjs
--- orig418/build/probe-old-lift-alpha.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/probe-old-lift-alpha.cjs	2026-10-31 12:37:31.910403604 +0000
@@ -2,7 +2,7 @@
 // v0.4.9 read-only probe (PORT_NOTE §7): does the OLD instrument's lift stack change with alpha, and what does its camera autofit (prepareCameraScreen) do with it?
 // Runs the old PlaneCliffordLiftCore (read from the frozen file, never edited) in a Node vm for saphir's state n1 = 4, m = 2, t1 = t2 = 1, n6 = 1.
 const fs=require('fs'),vm=require('vm');
-const OLD='C:/Users/robin/s6_atom/cold audit fourier/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/monodromy-31-linked-reduction.html',src=fs.readFileSync(OLD,'utf8');
+const OLD='/home/saphir/membrane_compute/viewer/mirror/cold audit fourier/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/monodromy-31-linked-reduction.html',src=fs.readFileSync(OLD,'utf8');
 function block(t){const i=src.indexOf(t);let j=src.indexOf('{',i),d=0;for(;j<src.length;j++){if(src[j]==='{')d++;else if(src[j]==='}'){d--;if(d===0)break;}}return src.slice(i,j+1);}
 const ctx={Math,Number,BigInt,String,Object,Array,Set,Map,RangeError,TypeError,Error,JSON,isFinite};vm.createContext(ctx);
 vm.runInContext(block('function combOffsets(')+'\nvar PlaneCliffordLiftCore='+block('const PlaneCliffordLiftCore = (() => {').replace('const PlaneCliffordLiftCore = ','')+')();this.L=PlaneCliffordLiftCore;',ctx);
diff -ru orig418/build/probe-old-page-alpha.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/probe-old-page-alpha.cjs
--- orig418/build/probe-old-page-alpha.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/probe-old-page-alpha.cjs	2026-10-31 12:37:31.910403604 +0000
@@ -1,8 +1,8 @@
 'use strict';
 // v0.4.9 read-only probe (PORT_NOTE §7): open the OLD instrument page (frozen file, not edited), Clifford lift + Full stack, press alpha -1 / 0 / +1,
 // and record state.alpha, the stack lift's point norms, the camera fit and a hash of the Clifford canvas.
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright'),crypto=require('crypto'),path=require('path');
-const OLD='file:///C:/Users/robin/s6_atom/cold%20audit%20fourier/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/monodromy-31-linked-reduction.html';
+const {chromium}=require('playwright'),crypto=require('crypto'),path=require('path');
+const OLD='file:///home/saphir/membrane_compute/viewer/mirror/cold%20audit%20fourier/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/monodromy-31-linked-reduction.html';
 const out=process.argv[2];
 (async()=>{const b=await chromium.launch();const pg=await (await b.newContext({viewport:{width:1280,height:900},deviceScaleFactor:1})).newPage();const errs=[];pg.on('pageerror',e=>errs.push(String(e)));
   await pg.goto(OLD);await pg.waitForTimeout(4000);
diff -ru orig418/build/shots-v0414.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/shots-v0414.cjs
--- orig418/build/shots-v0414.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/shots-v0414.cjs	2026-10-31 12:37:31.910403604 +0000
@@ -1,6 +1,6 @@
 'use strict';
 // v0.4.14 shots: the Goldbach track, Fourier (pen = G_N, ghosted teeth) and Clifford (Goldbach tori on one leaf), N = 24 (s = 4/3, near-zero pen) and N = 30 (s = 15/4), at 1280x800 and 375x812.
-const path=require('path');const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const path=require('path');const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/');
 const CC=require('../host-core/comb-core.js'),GB=require('../host-core/goldbach-core.js');
 (async()=>{const b=await chromium.launch();
diff -ru orig418/build/shots-v0416.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/shots-v0416.cjs
--- orig418/build/shots-v0416.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/shots-v0416.cjs	2026-10-31 12:37:31.910403604 +0000
@@ -1,7 +1,7 @@
 'use strict';
 // v0.4.16 screenshots (SCHEMA_ADDENDUM_23): the D1 Rule 30 ladder card on the Clifford tab, 1280x800 and 375x812. Page only (full page at 375 so the card shows).
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const CC=require('../host-core/comb-core.js');
 const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/');
 const addr=view=>CC.encodeAddress(CC.initial({tab:'clifford',view}));
diff -ru orig418/build/shots-v0417.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/shots-v0417.cjs
--- orig418/build/shots-v0417.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/shots-v0417.cjs	2026-10-31 12:37:31.910403604 +0000
@@ -1,7 +1,7 @@
 'use strict';
 // v0.4.17 screenshots (SCHEMA_ADDENDUM_24): the two group-D exact cards of the Panels tab, 1280x800 and 375x812. Card element shots, plus the group-D list.
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const CC=require('../host-core/comb-core.js');
 const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/')+CC.encodeAddress(CC.initial({tab:'panels'}));
 const setDial=(pg,role,v)=>pg.evaluate(([r,v])=>{const x=document.querySelector('[data-role="'+r+'"]');x.value=v;x.dispatchEvent(new Event('change',{bubbles:true}));},[role,String(v)]);
diff -ru orig418/build/shots-v0418.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/shots-v0418.cjs
--- orig418/build/shots-v0418.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/shots-v0418.cjs	2026-10-31 12:37:31.910403604 +0000
@@ -2,7 +2,7 @@
 // v0.4.18 screenshots: the group E pen cards and the fixed group-D cards, at 1280x800 and 375x812 (card element shots; groupE_closed is a viewport shot).
 // File names: shot_v0418_<os>_<viewport>_<name>.png, <os> = linux on membrane, win on Neo. Portable playwright resolution as in browser-check-v0418.
 const path=require('path'),{pathToFileURL}=require('url');
-const PW=(()=>{try{return require('playwright');}catch(e){return require(process.env.PLAYWRIGHT_DIR||'C:/Users/robin/s6_atom/node_modules/playwright');}})();
+const PW=(()=>{try{return require('playwright');}catch(e){return require(process.env.PLAYWRIGHT_DIR||'/home/saphir/membrane_compute/viewer/mirror/node_modules/playwright');}})();
 const CC=require('../host-core/comb-core.js');
 const root=path.join(__dirname,'..'),url=pathToFileURL(path.join(root,'dist','comb-hopf.html')).href,OS=process.platform==='linux'?'linux':'win';
 const addr=o=>CC.encodeAddress(CC.initial(o));
diff -ru orig418/build/shots-v043.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/shots-v043.cjs
--- orig418/build/shots-v043.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/shots-v043.cjs	2026-10-31 12:37:31.911403599 +0000
@@ -1,8 +1,8 @@
 'use strict';
 // v0.4.3: mid-drag screenshots of v0.4.2 vs v0.4.3, Clifford view, same state and same drag. The 200 ms idle timer that ends "moving" is held off during the shot (page setTimeout wrapper), so the picture is the moving frame.
 // Usage: node shots-v043.cjs <outdir>
-const path=require('path');const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
-const out=process.argv[2],S='C:/Users/robin/s6_atom/';
+const path=require('path');const {chromium}=require('playwright');
+const out=process.argv[2],S='/home/saphir/membrane_compute/viewer/mirror/';
 const U={v042:'file:///'+S+'FOURIER_VIEWER_PROTOTYPE_v0_4_2_20261019/dist/comb-hopf.html',v043:'file:///'+S+'FOURIER_VIEWER_PROTOTYPE_v0_4_3_20261019/dist/comb-hopf.html'};
 const REPRO={shellMode:'factorial',n1:'4',phi3:'6',alpha:'-1/50',n6:'1',t1:'1',t2:'-21/4',m:'3'};
 (async()=>{
diff -ru orig418/build/shots-v047.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/shots-v047.cjs
--- orig418/build/shots-v047.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/shots-v047.cjs	2026-10-31 12:37:31.911403599 +0000
@@ -1,7 +1,7 @@
 'use strict';
 // v0.4.7 shots: Fourier and Hopf base at alpha_Tilt = -1, -0.6, 0, +1 for B = 6 (n1 = 3), m = 7, N = 5, s = 1; 1280x800 and 375x812.
 const path=require('path');
-const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
+const {chromium}=require('playwright');
 const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/');
 const CC=require('../host-core/comb-core.js');
 (async()=>{
diff -ru orig418/build/test-v0410.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/test-v0410.cjs
--- orig418/build/test-v0410.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/test-v0410.cjs	2026-10-31 12:37:31.911403599 +0000
@@ -5,7 +5,7 @@
 const fs=require('fs'),path=require('path'),crypto=require('crypto'),cp=require('child_process');
 const X=require('../exact-lib/exact-lib-0.2.0.js'),C=require('../host-core/comb-core.js'),O=require('../host-core/orbit-core.js'),SH=require('../host-core/shell-core.js'),BD=require('../host-core/branch-disk-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
-const root=path.join(__dirname,'..'),V49='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_9_20261020';
+const root=path.join(__dirname,'..'),V49='/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_9_20261020';
 const sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
 const euclid=(a,b)=>{a=a<0n?-a:a;b=b<0n?-b:b;while(b){[a,b]=[b,a%b];}return a;};
 const shell=(n,o)=>C.initial({shellMode:'integer',B:String(n*n),phi3:'0',m:String(2*n+1),t1:'1',t2:'1',...(o||{})});
@@ -139,7 +139,7 @@
   ok('B3 F(a) (Lemma II.5g), contact edges |as − cq| = 1 (Def II.5h) and isolated beads for N = 2, 5, 10, 12, 17, 26, 30, 50, 60, 101, 120, 360, 720, 5040 equal an independent enumeration; N = 12 = 2²·3 has orders 3, 2: F = {1/3, 1/2, 2/3}, 2 edges',bad.length===0&&d12.F.map(x=>x.join('/')).join()==='1/3,1/2,2/3'&&d12.edges.length===2,bad.join(' | '));
 }
 { // B4. Astra's points, n <= 30, against disk_checks.py run live
-  const script='C:/Users/robin/s6_atom/POINCARE_DISK_VIEW_INVESTIGATION_v0_1_20261020/disk_checks.py';
+  const script='/home/saphir/membrane_compute/viewer/mirror/POINCARE_DISK_VIEW_INVESTIGATION_v0_1_20261020/disk_checks.py';
   let out='',pyok=true;try{out=cp.execFileSync('python',['-I',script],{stdio:['ignore','pipe','pipe'],encoding:'utf8',timeout:120000});}catch(e){pyok=false;out=String(e);}
   ok('B4 disk_checks.py ran live (python -I, stdin closed): exit 0, "FAILURES: 0"',pyok&&/FAILURES: 0/.test(out));
   const m4=/C4 n = 1\.\.30: (\d+) pairs[^\n]*largest m = (\d+)/.exec(out);
diff -ru orig418/build/test-v0411.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/test-v0411.cjs
--- orig418/build/test-v0411.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/test-v0411.cjs	2026-10-31 12:37:31.911403599 +0000
@@ -3,7 +3,7 @@
 const fs=require('fs'),path=require('path'),crypto=require('crypto');
 const C=require('../host-core/comb-core.js'),NUM=require('../host-core/comb-numeric.js'),SC=require('../host-core/stack-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
-const root=path.join(__dirname,'..'),OLD='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_10_20261020';
+const root=path.join(__dirname,'..'),OLD='/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_10_20261020';
 const sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
 const stOf=o=>C.initial({shellMode:'factorial',n1:'4',phi3:'2',m:'2',...o});
 const hop=(x,y)=>{const q=x*x+y*y,d=1+q;return [2*x/d,2*y/d,(q-1)/d];};
diff -ru orig418/build/test-v0412.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/test-v0412.cjs
--- orig418/build/test-v0412.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/test-v0412.cjs	2026-10-31 12:37:31.911403599 +0000
@@ -6,7 +6,7 @@
 require('../instruments/comb-hopf/view-fourier.js');
 const {logModel,logR}=globalThis.FVStackView;
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
-const root=path.join(__dirname,'..'),OLD='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_11_20261021';
+const root=path.join(__dirname,'..'),OLD='/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_11_20261021';
 const sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
 const stOf=o=>C.initial({shellMode:'factorial',n1:'4',phi3:'2',m:'2',...o});
 const ST=[{alpha:'1',n6:'1',m:'2'},{alpha:'-1',n6:'1',m:'2'},{alpha:'2',n6:'1/2',m:'3'},{alpha:'1/2',n6:'3',m:'5'},{alpha:'-1',n6:'-1',m:'4'},{alpha:'3',n6:'-2',m:'2'},{alpha:'-2',n6:'2/3',m:'3'},{n1:'3',alpha:'1',n6:'1',m:'2',phi3:'5'},{n1:'4',phi3:'22',alpha:'1',n6:'1',m:'2'},{n1:'4',phi3:'22',alpha:'-1',n6:'1',m:'2'}];
diff -ru orig418/build/test-v0413.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/test-v0413.cjs
--- orig418/build/test-v0413.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/test-v0413.cjs	2026-10-31 12:37:31.911403599 +0000
@@ -3,7 +3,7 @@
 // (3) the two named panel files and every source file except view-fourier.js equal v0.4.12. The pen drawing is checked in browser-check-v0413.
 const fs=require('fs'),path=require('path'),crypto=require('crypto'),vm=require('vm');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
-const root=path.join(__dirname,'..'),OLD='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_12_20261021';
+const root=path.join(__dirname,'..'),OLD='/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_12_20261021';
 const sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
 ok('v0.4.12 dist sha256 unchanged (b6e0e6e8…)',sha(OLD+'/dist/comb-hopf.html')==='b6e0e6e839b26bfd6304b9f5a273ca171d6a606fb416d663fc1c5da12debf090');
 ok('v0.4.12 SHA256SUMS.txt sha256 unchanged (7d90774e…)',sha(OLD+'/SHA256SUMS.txt')==='7d90774ea9c7f33069df594ad429ae312fb7d30e7eecff5172f260f5f5b7379f');
diff -ru orig418/build/test-v0414.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/test-v0414.cjs
--- orig418/build/test-v0414.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/test-v0414.cjs	2026-10-31 12:37:31.911403599 +0000
@@ -1,7 +1,7 @@
 'use strict';
 // v0.4.14 core test (SCHEMA_ADDENDUM_22): the Goldbach prime-pair mask. Node only. The reference code below is independent of goldbach-core (own sieve, own direct G_N sum).
 const fs=require('fs'),path=require('path'),crypto=require('crypto');
-const root=path.join(__dirname,'..'),BASE='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_13_20261021/';
+const root=path.join(__dirname,'..'),BASE='/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_13_20261021/';
 const C=require('../host-core/comb-core.js'),NUM=require('../host-core/comb-numeric.js'),O=require('../host-core/orbit-core.js'),GB=require('../host-core/goldbach-core.js'),X=require('../exact-lib/exact-lib-0.2.0.js');
 const C0=require(BASE+'host-core/comb-core.js'),NUM0=require(BASE+'host-core/comb-numeric.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
diff -ru orig418/build/test-v047.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/test-v047.cjs
--- orig418/build/test-v047.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/test-v047.cjs	2026-10-31 12:37:31.911403599 +0000
@@ -5,7 +5,7 @@
 const path=require('path');
 const root=path.join(__dirname,'..');
 const C=require('../host-core/comb-core.js'),NUM=require('../host-core/comb-numeric.js'),X=require('../exact-lib/exact-lib-0.2.0.js');
-const OLD='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_6_20261020/';
+const OLD='/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_6_20261020/';
 const C6=require(OLD+'host-core/comb-core.js'),N6=require(OLD+'host-core/comb-numeric.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{if(!c)console.log('FAIL '+n+(x?' '+x:''));c?pass++:fail++;};
 let seed=20261020;const rnd=()=>{seed=(seed*1664525+1013904223)>>>0;return seed/4294967296;};const pick=a=>a[Math.floor(rnd()*a.length)];
diff -ru orig418/build/test-v049.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/test-v049.cjs
--- orig418/build/test-v049.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/test-v049.cjs	2026-10-31 12:37:31.911403599 +0000
@@ -3,7 +3,7 @@
 // The old instrument's own functions (computeVernier, buildFullStack, PlaneCliffordLiftCore, ContinuousRadialDisplayV1) are read from the frozen file (never edited)
 // and run in a Node vm; their point sets are compared with host-core/stack-core.js, which uses this viewer's exact core.
 const fs=require('fs'),vm=require('vm'),path=require('path'),crypto=require('crypto');
-const OLD='C:/Users/robin/s6_atom/cold audit fourier/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/monodromy-31-linked-reduction.html';
+const OLD='/home/saphir/membrane_compute/viewer/mirror/cold audit fourier/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/monodromy-31-linked-reduction.html';
 const OLD_SHA='b4cee4e30a753eda7c62f72e8043d6d5c9b3f69c3c2e1dd0da9a3f9ab5b8e248';
 const X=require('../exact-lib/exact-lib-0.2.0.js'),C=require('../host-core/comb-core.js'),NUM=require('../host-core/comb-numeric.js'),SC=require('../host-core/stack-core.js'),FS=require('../host-core/fraction-stack-core.js');
 let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
diff -ru orig418/build/transcribe-elliptic-fixture.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/transcribe-elliptic-fixture.cjs
--- orig418/build/transcribe-elliptic-fixture.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/transcribe-elliptic-fixture.cjs	2026-10-31 12:37:31.911403599 +0000
@@ -3,7 +3,7 @@
 // A parser, not a recomputation: it checks the source sha256 first, then reads each line by a fixed pattern and fails on anything it does not recognise.
 // No floating point: every value stays a string or a BigInt-checked integer string.
 const fs=require('fs'),path=require('path'),crypto=require('crypto');
-const SRC='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029_BRIEF/SAGE_REFERENCE_37a1_20261029.txt';
+const SRC='/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029_BRIEF/SAGE_REFERENCE_37a1_20261029.txt';
 const PIN='599c68552af2521c0b762298875c922e4c03aef29ae7ad4573af614642ab6a72';
 const buf=fs.readFileSync(SRC),h=crypto.createHash('sha256').update(buf).digest('hex');
 if(h!==PIN)throw Error('source sha256 mismatch: '+h);
diff -ru orig418/build/transcribe-rule30-fixture.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/transcribe-rule30-fixture.cjs
--- orig418/build/transcribe-rule30-fixture.cjs	2026-10-31 12:37:31.882403748 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/transcribe-rule30-fixture.cjs	2026-10-31 12:37:31.912403594 +0000
@@ -2,7 +2,7 @@
 // v0.4.16: transcribes the pinned rule30 outputs (READ ONLY; nothing in rule30_prize_research_2026_10_26/ is run, copied or written) into fixtures/rule30-ladder-fixture.json.
 // The source sha256 values are checked against the brief's pins before anything is written.
 const fs=require('fs'),path=require('path'),crypto=require('crypto');
-const SRC='C:/Users/robin/s6_atom/rule30_prize_research_2026_10_26/';
+const SRC='/home/saphir/membrane_compute/viewer/mirror/rule30_prize_research_2026_10_26/';
 const PINS={'opus_two_adic_n2_densities_v0_1_20261028.output.txt':'72d0bd143c106c37ff3b1e8a46aa44d7605a8c17a88bee0990b0ce886fc7efcf',
   'opus_two_adic_n2_lemma_check_v0_1_20261028.output.txt':'fa24e8067419383eb0184b4868468a3d6b1c5072ac20e8cd1e75ef887585defd',
   'opus_two_adic_n2_v0_1_20261028.sha256':'677bfe28bae82f6fed3b4716a2fceacd521e2c8c281b5063d1f0fe173e8035a8'};
diff -ru orig418/host-core/parity-sample.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/host-core/parity-sample.cjs
--- orig418/host-core/parity-sample.cjs	2026-10-31 12:37:31.884403738 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/host-core/parity-sample.cjs	2026-10-31 12:37:31.912403594 +0000
@@ -2,7 +2,7 @@
 // Informative parity sample (not R18): 2000 random integer-gear states, rebuild vs frozen v0.3.2 comb-core.js / control-math.js (read-only load).
 // Every difference is listed with its class: (a) mandated by R20/R21, (d) reference defect reproduced by exact arithmetic, or UNEXPLAINED.
 const X=require('../exact-lib/exact-lib-0.2.0.js'),C=require('./comb-core.js');
-const F='C:/Users/robin/s6_atom/cubic_Fourier/DIVISOR_COMB_RIEMANN_v0_3_2_20261012/';
+const F='/home/saphir/membrane_compute/viewer/mirror/cubic_Fourier/DIVISOR_COMB_RIEMANN_v0_3_2_20261012/';
 const HC=require(F+'comb-core.js'),HM=require(F+'control-math.js');
 let seed=0x12345678;const rnd=()=>{seed^=seed<<13;seed>>>=0;seed^=seed>>>17;seed^=seed<<5;seed>>>=0;return seed/4294967296;};
 const ri=(a,b)=>a+Math.floor(rnd()*(b-a+1)),pick=a=>a[ri(0,a.length-1)];
diff -ru orig418/host-core/test-core.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/host-core/test-core.cjs
--- orig418/host-core/test-core.cjs	2026-10-31 12:37:31.884403738 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/host-core/test-core.cjs	2026-10-31 12:37:31.912403594 +0000
@@ -197,7 +197,7 @@
 
 // ---------- addendum tests: shell core, flags, gates, lift, gearbox parity
 const SH=require('./shell-core.js');
-const FROZEN='C:/Users/robin/s6_atom/cubic_Fourier/DIVISOR_COMB_RIEMANN_v0_3_2_20261012/';
+const FROZEN='/home/saphir/membrane_compute/viewer/mirror/cubic_Fourier/DIVISOR_COMB_RIEMANN_v0_3_2_20261012/';
 t('SPREAD/ALIGN exact flags vs numerical |K_m| < 1e-9 at 2000 random states (any disagreement fails)',()=>{
   let bad=0,zeros=0;
   for(let i=0;i<2000;i++){
diff -ru orig418/host-core/test-elliptic-exact.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/host-core/test-elliptic-exact.cjs
--- orig418/host-core/test-elliptic-exact.cjs	2026-10-31 12:37:31.884403738 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/host-core/test-elliptic-exact.cjs	2026-10-31 12:37:31.912403594 +0000
@@ -6,7 +6,7 @@
 let pass=0,fail=0;
 function t(name,fn){let ok=false,msg='';try{const r=fn();ok=r===true;if(!ok&&r!==false)msg=' '+r;}catch(e){msg=' threw: '+e.message;}console.log((ok?'PASS ':'FAIL ')+name+msg);ok?pass++:fail++;}
 const FIX=path.join(__dirname,'..','fixtures','elliptic-37a1-fixture.json'),fx=JSON.parse(fs.readFileSync(FIX,'utf8'));
-const SRC='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029_BRIEF/SAGE_REFERENCE_37a1_20261029.txt';
+const SRC='/home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029_BRIEF/SAGE_REFERENCE_37a1_20261029.txt';
 const B=s=>BigInt(s),A=fx.ainvs.map(B),C=E.curveQ(A),P=E.pt(E.Q(B(fx.generator.x)),E.Q(B(fx.generator.y)));
 const qs=E.qascii;
 t('fixture records the source sha256 599c6855…',()=>fx.source.sha256==='599c68552af2521c0b762298875c922e4c03aef29ae7ad4573af614642ab6a72');
diff -ru orig418/host-core/test-rule30-ladder.cjs mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/host-core/test-rule30-ladder.cjs
--- orig418/host-core/test-rule30-ladder.cjs	2026-10-31 12:37:31.885403733 +0000
+++ mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/host-core/test-rule30-ladder.cjs	2026-10-31 12:37:31.913403589 +0000
@@ -13,7 +13,7 @@
 const REF={};for(const r of [30,90,150]){const xs=[];let x=1n;do{xs.push(x);x=F[r](x)&M35;}while(x!==1n&&xs.length<100000);REF[r]=xs;}
 const bit=(x,j)=>Number((x>>BigInt(j))&1n);
 t('fixture source hashes recorded (densities 72d0bd14…, lemma fa24e806…, manifest 677bfe28…)',()=>fx.sources.map(s=>s.sha256.slice(0,8)).join()==='72d0bd14,fa24e806,677bfe28');
-{const SRC='C:/Users/robin/s6_atom/rule30_prize_research_2026_10_26/';let seen=0,okh=true;
+{const SRC='/home/saphir/membrane_compute/viewer/mirror/rule30_prize_research_2026_10_26/';let seen=0,okh=true;
  for(const s of fx.sources){const f=SRC+path.basename(s.file);if(fs.existsSync(f)){seen++;if(crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex')!==s.sha256)okh=false;}}
  t('pinned sources still match their sha256 (read only; '+seen+' of 3 present)',()=>okh&&seen===3);}
 for(const r of L.RULES){const R=fx.rules[r],T=L.table(r);
```

## Test outputs (verbatim)

Node suites as run by the capped runner on membrane (`membrane_receipts/*/stdout.txt`); the same suites in the final full run printed the same PASS lines (timings aside).

**test-pen-streams (membrane, job VIEW-NODE-0418-01)**

```
PASS Rule 30 signs = skeleton caSigns(30, 0)
PASS Rule 150 signs = skeleton caSigns(150, 0)
PASS Rule 30 signs = skeleton caSigns(30, 1)
PASS Rule 150 signs = skeleton caSigns(150, 1)
PASS Rule 30 signs = skeleton caSigns(30, 2)
PASS Rule 150 signs = skeleton caSigns(150, 2)
PASS Rule 30 signs = skeleton caSigns(30, 300)
PASS Rule 150 signs = skeleton caSigns(150, 300)
PASS Rule 30 signs = skeleton caSigns(30, 1328)
PASS Rule 150 signs = skeleton caSigns(150, 1328)
PASS Rule 30 signs = skeleton caSigns(30, 4096)
PASS Rule 150 signs = skeleton caSigns(150, 4096)
PASS coin seed 1 T = 300 = skeleton coinSigns (xorshift32 13, 17, 5; + on odd)
PASS coin seed 1 T = 4096 = skeleton coinSigns (xorshift32 13, 17, 5; + on odd)
PASS coin seed 5 T = 300 = skeleton coinSigns (xorshift32 13, 17, 5; + on odd)
PASS coin seed 5 T = 4096 = skeleton coinSigns (xorshift32 13, 17, 5; + on odd)
PASS coin seed 2 T = 300 = skeleton coinSigns (xorshift32 13, 17, 5; + on odd)
PASS coin seed 2 T = 4096 = skeleton coinSigns (xorshift32 13, 17, 5; + on odd)
PASS coin seed 4294967295 T = 300 = skeleton coinSigns (xorshift32 13, 17, 5; + on odd)
PASS coin seed 4294967295 T = 4096 = skeleton coinSigns (xorshift32 13, 17, 5; + on odd)
PASS Rule 150: the centre cell x_t(0) is black for every t < 4096 (kit center150)
PASS Rule 30: s_t = −1 exactly when q XOR r = 1, tooth exactly when q = r = 1 (1042 tooth events in 4096 steps)
PASS Rule 30 centre x_t(0), t < 32, equals an independent BigInt row computation
PASS seed 0 and 2^32 are refused
PASS T outside 0 … 4096 or not an integer is refused
PASS every Goldbach shell N = 4 … 1448: one sign per tooth, stream length = number of teeth m
PASS every shell: + exactly on the teeth with N/2 ± c·t₂ both prime (independent BigInt primality), − on the ghosted teeth
PASS every shell: tooth order c = 0, 1, −1, 2, −2, … (as present in the comb)
PASS every shell: #+ = 2g(N) − δ (δ = 1 when N/2 is prime: the equal pair counted once)
PASS N = 4: g(N) = 1, #+ = 1, teeth 3, net turning (#+ − #−)·90° = -1·90°
PASS N = 6: g(N) = 1, #+ = 1, teeth 3, net turning (#+ − #−)·90° = -1·90°
PASS N = 24: g(N) = 3, #+ = 6, teeth 8, net turning (#+ − #−)·90° = 4·90°
PASS N = 26: g(N) = 3, #+ = 5, teeth 11, net turning (#+ − #−)·90° = -1·90°
PASS N = 1448: g(N) = 20, #+ = 40, teeth 706, net turning (#+ − #−)·90° = -626·90°
PASS empty-fibre guard (injected empty pair set, unreachable for 4 ≤ N ≤ 1448): g = 0, every tooth ghosted, the label is set
PASS g(N) ≥ 1 for every even 4 ≤ N ≤ 1448 (so the empty-fibre label never shows on a real shell): min g = 1
PASS Goldbach run to 1448 = the 723 shells concatenated in order (257430 signs, 30534 +), boundaries at the shell starts
PASS Goldbach run to 1448: #+ = 30534 = 2·Σg(N) − Σδ = 2·15331 − 128 (holds); built in 38 ms
PASS Goldbach run is biased to − (226896 − against 30534 +); recorded as a drawing-register observation only
PASS N_max must be even and 4 … 1448
PASS the printed guards carry the brief wording
SUMMARY test-pen-streams: 41 passed, 0 failed
```

**test-pen-fields (membrane, job VIEW-NODE-0418-02)**

```
PASS F: √2·√2 = 2, √5·√5 = 5, τ·τ = √5 − 1 (τ² = √5 − 1)
PASS F: √2·√5 = √10 (basis e3), (√10)² = 10, (√2τ)² = 2√5 − 2, (√10 τ)² = 10√5 − 10
PASS F: all 64 entries of the reduction table agree with the product of the basis enclosures (2^−128)
PASS F: commutative, associative, distributive on 60 random triples
PASS F: x · x⁻¹ = 1 on 120 random elements (inverse by the tower conjugates)
PASS K = ℚ(√3, √5): x · x⁻¹ = 1 on 120 random elements
PASS cosh²(ℓ/2) − sinh²(ℓ/2) = 1 exactly: ((√2 + √10)/4)² − (τ/2)² = 1
PASS cosh²(ℓ/2) = (3 + √5)/4 and sinh²(ℓ/2) = (√5 − 1)/4 = cos 72° (so sinh(ℓ/2) ∉ ℚ(√2, √5): the field needs τ)
PASS cosh(ℓ/2) = cos 36°/sin 45°: the F enclosure meets the quotient of the series enclosures (2^−200)
PASS sinh²(ℓ/2) = cos 72°: enclosures meet
PASS τ = 1.1117859405028… (guaranteed digits: 1.111785940503)
PASS edge ℓ = 2 arccosh(cos 36°/sin 45°) = 1.06127506190504 to 14 places (skeleton: 1.0612751): d of one step from 0, by the interval log
PASS det = |a|² − |b|² = 1 exactly for R(±90°), T(ℓ), M_L = R(90°)T(ℓ), M_R = R(−90°)T(ℓ)
PASS (rotate-left · step)^5 = −I in SU(1,1) over F: five lefts close a face of the disk
PASS (rotate-right · step)^5 = −I likewise
PASS (M_L)^k and (M_R)^k ≠ ±I for k = 1 … 4 (the face has exactly five edges)
PASS R(90°)^4 = −I (the vertex has four edges; −I acts as the identity on the disk)
PASS K: cos²60° + sin²60° = 1 and (√5/3)² + (2/3)² = 1 exactly
PASS cos² + sin² ∋ 1 and widths ≤ 2^−88 for rational turns p/q, q ≤ 96 (sampled)
PASS exact quadrant values: cos(1/4 turn) = 0, sin(1/4) = 1, cos(1/2) = −1 are point intervals
PASS cos(1/6 turn) ∋ 1/2, sin(1/12 turn) ∋ 1/2, cos(1/8 turn)² ∋ 1/2
PASS π = 3.14159265358979323846264338327950288… (Machin, guaranteed digits)
PASS ln 2 = 0.693147180559945309417232121458… and ln 10 = 2.302585092994045684017991454684…
PASS log of a huge number: log(2^5000) = 5000 ln 2 = 3465.73590279972654708616…
PASS isqrt is the exact floor square root on 2000 values
PASS outward rounding: [−3, −1]·[2, 5] at scale 0 = [−15, −2]; division by an interval containing 0 is refused
SUMMARY test-pen-fields: 26 passed, 0 failed
```

**test-pen-curvature (membrane, job VIEW-NODE-0418-03)**

```
PASS T = 300, Rule 30: lattice positions = the skeleton planePen (transcription), all 301
PASS T = 300, Rule 30: octahedron vertices = the skeleton spherePen (transcription), all 301; each flag direction v_t = −x_(t−1)
PASS T = 300, Rule 150: lattice positions = the skeleton planePen (transcription), all 301
PASS T = 300, Rule 150: octahedron vertices = the skeleton spherePen (transcription), all 301; each flag direction v_t = −x_(t−1)
PASS T = 300, coin seed 1: lattice positions = the skeleton planePen (transcription), all 301
PASS T = 300, coin seed 1: octahedron vertices = the skeleton spherePen (transcription), all 301; each flag direction v_t = −x_(t−1)
PASS T = 300, coin seed 5: lattice positions = the skeleton planePen (transcription), all 301
PASS T = 300, coin seed 5: octahedron vertices = the skeleton spherePen (transcription), all 301; each flag direction v_t = −x_(t−1)
PASS lattice: 4 lefts close a face, 4 rights too; 1, 2, 3 do not
PASS octahedron: 3 lefts close a face (back to the start flag), 3 rights too; 1 and 2 do not
PASS disk: 5 lefts return the pen to 0 exactly (product −I), 5 rights too
PASS Rule 150 planar pen to T = 4096: |x| ≤ 3, |y| ≤ 2 (max 3, 2), 13 lattice points visited (13: a FINITE count)
PASS octahedron: the two moves (as permutations of the 24 flags) generate a group of order 12, element orders {"1":1,"2":3,"3":8}, non-abelian, both moves of order 3: A₄ (the only group of order 12 with 8 elements of order 3), not S₄
PASS octahedron: the start flag has an orbit of exactly 12 of the 24 flags
PASS octahedron flags reached, Rule 30 T = 4096 (4096 steps): 12 of 24 (vertices 6/6); the whole orbit of 12
PASS octahedron flags reached, Rule 150 T = 4096 (4096 steps): 12 of 24 (vertices 6/6); the whole orbit of 12
PASS octahedron flags reached, coin seed 1 T = 4096 (4096 steps): 12 of 24 (vertices 6/6); the whole orbit of 12
PASS octahedron flags reached, coin seed 5 T = 4096 (4096 steps): 12 of 24 (vertices 6/6); the whole orbit of 12
PASS octahedron flags reached, Goldbach shell 24 (8 steps): 7 of 24 (vertices 5/6); a short stream reaches part of the 12-flag orbit only
PASS octahedron flags reached, Goldbach shell 1448 (706 steps): 8 of 24 (vertices 5/6); a short stream reaches part of the 12-flag orbit only
PASS octahedron flags reached, Goldbach run to 1448 (257430 steps): 12 of 24 (vertices 6/6); the whole orbit of 12
PASS TIMING Goldbach run N_max = 1448 (257430 steps): lattice 1 ms, octahedron 145 ms (lattice: 6499 points, max |x| 115, |y| 208)
PASS disk T = 64, Rule 30: the interval product (P = 136) contains the exact F[i] product entrywise
PASS disk T = 64, Rule 30: d exact-route 29.285573798460 meets d interval-route 29.285573798460
PASS disk T = 64, Rule 30: det = 1 exactly for the exact product
PASS disk T = 64, Rule 150: the interval product (P = 136) contains the exact F[i] product entrywise
PASS disk T = 64, Rule 150: d exact-route 22.018552700006 meets d interval-route 22.018552700006
PASS disk T = 64, Rule 150: det = 1 exactly for the exact product
PASS disk T = 64, coin seed 1: the interval product (P = 136) contains the exact F[i] product entrywise
PASS disk T = 64, coin seed 1: d exact-route 22.187244650365 meets d interval-route 22.187244650365
PASS disk T = 64, coin seed 1: det = 1 exactly for the exact product
PASS disk T = 64, coin seed 5: the interval product (P = 136) contains the exact F[i] product entrywise
PASS disk T = 64, coin seed 5: d exact-route 20.308363000951 meets d interval-route 20.308363000951
PASS disk T = 64, coin seed 5: det = 1 exactly for the exact product
PASS trail: Q_j = g_u⁻¹ g_(u−j) exactly for j = 1 … 40 (u = 40, Rule 30)
PASS trail: every interval trail point Q_j(0) contains the exact point (j = 0 … 40)
PASS TIMING k = −1, Rule 30, T = 1024: 7 ms at P = 256 bits; d = 309.396527759557 (12 guaranteed places), cosh d = 1.169970012097 × 10^134; enclosure width 2^18 against magnitude 2^270 (relative precision 2^−252)
PASS TIMING k = −1, Rule 30, T = 4096: 47 ms at P = 640 bits; d = 1308.231479757862 (12 guaranteed places), cosh d = 7.189235585065 × 10^567; enclosure width 2^87 against magnitude 2^656 (relative precision 2^−569)
PASS chunked exact products (CHUNK = 64): precision lost at P = 2048: Rule 30 71 bits over 64 joins; Rule 150 151 bits over 64 joins; coin seed 1 69 bits over 64 joins; coin seed 5 63 bits over 64 joins; Goldbach shell 1448 16 bits over 12 joins; Goldbach run (first 4096) 82 bits over 64 joins; worst ≤ 3 bits per join, within the 8 allowed
PASS follow the pen, T = 4096, W = 600: pixels not certified 0 of 3601 (67 ms)
PASS absolute view, T = 4096: pixels not certified 0 of 24577 (457 ms)
PASS {5,4} tiling patch, exact BFS depth 8: 334 edges, pixels not certified 0 of 1670 (253 ms)
PASS {5,4} patch (depth 6, 106 edges, exact keys in F[i]): every vertex degree ≤ 4, the start vertex has degree 4
SUMMARY test-pen-curvature: 43 passed, 0 failed
```

**test-pen-sphere (membrane, job VIEW-NODE-0418-04)**

```
PASS dodecahedron preset: cos θ = 1/2, sin θ = √3/2, cos α = √5/3, sin α = 2/3 with cos² + sin² = 1 exactly in K
PASS dodecahedron: five lefts return to the start flag exactly (a pentagonal face closes), five rights too; three lefts do not
PASS dodecahedron: closing the start flag under the two moves gives exactly 60 flags on 20 vertices (60 on 20)
PASS dodecahedron: every reached frame has |x| = |v| = 1 and x · v = 0 exactly
PASS dodecahedron: every vertex has exactly 3 others at x · y = cos α = √5/3 (its edge neighbours)
PASS dodecahedron: the dot products between distinct vertices are exactly √5/3 (60), 1/3 (120), −1/3 (120), −√5/3 (60), −1 (20 antipodes): the regular dodecahedron’s
PASS dodecahedron: the moves generate a group of order 60 with element orders {"1":1,"2":15,"3":20,"5":24} (A₅’s profile 1, 15, 20, 24), each move of order 5 (44 ms)
PASS dodecahedron, Rule 30 T = 1328: every position is one of the 20 vertices (20 visited, 60 flags), coverage 20/432 exact, 0 uncertain (91 ms)
PASS dodecahedron, coin seed 1 T = 1328: every position is one of the 20 vertices (20 visited, 60 flags), coverage 20/432 exact, 0 uncertain (88 ms)
PASS dodecahedron, Goldbach run to 1448 (first 4096): every position is one of the 20 vertices (20 visited, 60 flags), coverage 20/432 exact, 0 uncertain (171 ms)
PASS TIMING sphere pen, Rule 30, T = 1328, α = 3/96, θ = 2/24: 120 ms at P = 1392 bits; widest enclosure 2^978·2^−1392; pixels not certified (R = 140 px) 0; |x|² ∋ 1; coverage 406/432, uncertain cells 0 (33 ms)
PASS TIMING sphere pen, Rule 30, T = 4096, α = 3/96, θ = 2/24: 1873 ms at P = 4160 bits; widest enclosure 2^3015·2^−4160; pixels not certified (R = 140 px) 0; |x|² ∋ 1; coverage 432/432, uncertain cells 0 (92 ms)
PASS TIMING sphere pen, Rule 30, T = 1328, α = 24/96, θ = 4/24: 79 ms at P = 1392 bits; widest enclosure 2^1011·2^−1392; pixels not certified (R = 140 px) 0; |x|² ∋ 1; coverage 411/432, uncertain cells 3 (30 ms)
PASS TIMING sphere pen, Rule 30, T = 1328, α = 1/96, θ = 11/24: 124 ms at P = 1392 bits; widest enclosure 2^499·2^−1392; pixels not certified (R = 140 px) 0; |x|² ∋ 1; coverage 13/432, uncertain cells 0 (41 ms)
PASS TIMING ball register, Rule 30, T = 1328, α = 3/96, θ = 2/24: 8 ms at P = 96 bits, final radius 30543 ulp; every ball meets the interval-register enclosure; pixels not certified 0; coverage 406/432, uncertain 0 (interval register: 406, 0)
PASS TIMING ball register, Rule 30, T = 4096, α = 3/96, θ = 2/24: 17 ms at P = 96 bits, final radius 94207 ulp; every ball meets the interval-register enclosure; pixels not certified 0; coverage 432/432, uncertain 0 (interval register: 432, 0)
PASS TIMING ball register, Rule 30, T = 1328, α = 24/96, θ = 4/24: 7 ms at P = 96 bits, final radius 22575 ulp; every ball meets the interval-register enclosure; pixels not certified 0; coverage 411/432, uncertain 3 (interval register: 411, 3)
PASS TIMING ball register, coin seed 1, T = 1328, α = 5/96, θ = 7/24: 3 ms at P = 96 bits, final radius 27887 ulp; every ball meets the interval-register enclosure; pixels not certified 0; coverage 354/432, uncertain 0 (interval register: 354, 0)
PASS TIMING ball register, Goldbach run to 1448 (first 4096), T = 4096, α = 3/96, θ = 2/24: 7 ms at P = 96 bits, final radius 94207 ulp; every ball meets the interval-register enclosure; pixels not certified 0; coverage 432/432, uncertain 0 (interval register: 432, 0)
PASS ball register, α = 24/96, θ = 6/24, Rule 30, T = 300: every ball contains the exact octahedron vertex
PASS α = 24/96, θ = 6/24 (the octahedron), Rule 30, T = 300: every interval position contains the exact octahedron vertex
PASS α = 24/96, θ = 6/24 (the octahedron), coin seed 5, T = 300: every interval position contains the exact octahedron vertex
PASS Q(ζ₉₆) exact frames (α = 3/96, θ = 2/24, Rule 30, T = 64) meet the interval enclosures at every 8th step
PASS Q(ζ₉₆) benchmark (degree 32, Φ₉₆ = x³² − x¹⁶ + 1): T = 16: 7 ms, numerators up to 29 bits over 2^30; T = 32: 14 ms, numerators up to 59 bits over 2^60; T = 64: 40 ms, numerators up to 119 bits over 2^120; T = 128: 119 ms, numerators up to 239 bits over 2^240; T = 256: 424 ms, numerators up to 479 bits over 2^480; T = 512: 1691 ms, numerators up to 958 bits over 2^960. Each step costs about 24 products of 32 × 32 BigInt convolutions on coefficients that grow by about 2 bits per step, so the cost per step grows with T; against the interval register (T = 1328: see the timing above) the exact field is far slower, and its positions would still need enclosures for the pixels and the cells. Chosen: the guaranteed numerical register (the ball register for the card, the interval register as its cross-check).
PASS coverage cell of the start point (0, 0, 1): band 23, sector 9 (the skeleton’s atan2(0, 0) = 0), decided exactly
PASS coverage cell of (−1, 0, 0): band 12, sector 17 (atan2 = π, clamped as the skeleton does)
PASS a point whose enclosure straddles a sector ray (here the ray at angle 0) is counted as uncertain, not placed; a nearby decided point is placed
SUMMARY test-pen-sphere: 27 passed, 0 failed
```

**test-v0418-fixups (membrane, job VIEW-NODE-0418-05)**

```
PASS y² = x³ + 5 at p = 5: reduction type by the tangent cone = additive (additive (cusp))
PASS y² = x³ + 5 at p = 5: second route, p | c4 = 0 and p | Δ = −10800 (additive)
PASS y² = x³ + 5 at p = 5: a_p = 0 (the reference value for additive reduction) by route (i), naive count 6 = p + 1
PASS y² = x³ + 5 at p = 5: a_p = 0 by route (ii), the character sum
PASS y² = x³ + 5 at p = 5: the label shown is "additive", not "additive multiplicative" (the label rule of panel-elliptic.js, v0.4.18)
PASS 27a1: y² + y = x³ − 7 at p = 3: reduction type by the tangent cone = additive (additive (cusp))
PASS 27a1: y² + y = x³ − 7 at p = 3: second route, p | c4 = 0 and p | Δ = −19683 (additive)
PASS 27a1: y² + y = x³ − 7 at p = 3: a_p = 0 (the reference value for additive reduction) by route (i), naive count 4 = p + 1
PASS 27a1: y² + y = x³ − 7 at p = 3: a_p = 0 by route (ii), the character sum
PASS 27a1: y² + y = x³ − 7 at p = 3: the label shown is "additive", not "additive multiplicative" (the label rule of panel-elliptic.js, v0.4.18)
PASS y² = x³ + 5 at p = 7: good reduction (p ∤ Δ), routes agree: a_p = 1
SUMMARY test-v0418-fixups: 11 passed, 0 failed
```

**no-float-v0418 (membrane, job VIEW-NODE-0418-06)**

```
PASS host-core/pen-interval-core.js: no banned token
PASS host-core/field-q2-q5-tau.js: no banned token
PASS host-core/pen-streams-core.js: no banned token
PASS host-core/pen-curvature-core.js: no banned token
PASS host-core/pen-sphere-core.js: no banned token
PASS instruments/comb-hopf/panel-pens.js: no banned token (allowlisted at line 10)
PASS host-core/transcription-skeleton-pens.cjs: no banned token (allowlisted at line 35)
PASS host-core/test-pen-streams.cjs: no banned token
PASS host-core/test-pen-fields.cjs: no banned token
PASS host-core/test-pen-curvature.cjs: no banned token
PASS host-core/test-pen-sphere.cjs: no banned token
PASS host-core/test-v0418-fixups.cjs: no banned token
PASS build/browser-check-v0418.cjs: no banned token
PASS build/shots-v0418.cjs: no banned token
PASS build/browser-check-legacy-panels-v0418.cjs: no banned token
PASS build/check-expected-fails-v0418.cjs: no banned token
SUMMARY no-float-v0418: 16 passed, 0 failed
```

**no-float-v0418 (rerun after the last panel-pens.js edit) (membrane, job VIEW-NODE-0418-07)**

```
PASS host-core/pen-interval-core.js: no banned token
PASS host-core/field-q2-q5-tau.js: no banned token
PASS host-core/pen-streams-core.js: no banned token
PASS host-core/pen-curvature-core.js: no banned token
PASS host-core/pen-sphere-core.js: no banned token
PASS instruments/comb-hopf/panel-pens.js: no banned token (allowlisted at line 10)
PASS host-core/transcription-skeleton-pens.cjs: no banned token (allowlisted at line 35)
PASS host-core/test-pen-streams.cjs: no banned token
PASS host-core/test-pen-fields.cjs: no banned token
PASS host-core/test-pen-curvature.cjs: no banned token
PASS host-core/test-pen-sphere.cjs: no banned token
PASS host-core/test-v0418-fixups.cjs: no banned token
PASS build/browser-check-v0418.cjs: no banned token
PASS build/shots-v0418.cjs: no banned token
PASS build/browser-check-legacy-panels-v0418.cjs: no banned token
PASS build/check-expected-fails-v0418.cjs: no banned token
SUMMARY no-float-v0418: 16 passed, 0 failed
```

## Browser-check output (verbatim, membrane, final run)

**browser-check-v0418 (`build/_logs/browser-check-v0418.run.log`)**

```
PASS 1280x800 group headings: "D. Elliptic and BSD" (placement decided) and "E. Surface pens (exact)" last
PASS 1280x800 the two pen cards are the last two cards (group E), collapsed on a fresh page; the v0.4.17 group-D cards still close group D (23 cards)
PASS 1280x800 a collapsed pen card computes nothing ("Open the card to compute.")
PASS 1280x800 Rule 30 T = 512: lattice readout = core (219 points, max |x| 24, |y| 11)
PASS 1280x800 Rule 30 T = 512: octahedron readout = core (12 flags of 24; group order 12, A₄)
PASS 1280x800 Rule 30 T = 512: k = −1 distance d = core 175.204234001017 (drawn to T = 512), pixels not certified 0
PASS 1280x800 Rule 30 T = 512: no cap label (stream length 512 ≤ 4096)
PASS 1280x800 Rule 30 T = 512: ink on the three canvases and the sphere
PASS 1280x800 Rule 30 T = 512: no horizontal page scroll
PASS 1280x800 Rule 150 T = 4096: lattice readout = core (13 points, max |x| 3, |y| 2)
PASS 1280x800 Rule 150 T = 4096: octahedron readout = core (12 flags of 24; group order 12, A₄)
PASS 1280x800 Rule 150 T = 4096: k = −1 distance d = core 1232.358485148210 (drawn to T = 4096), pixels not certified 0
PASS 1280x800 Rule 150 T = 4096: no cap label (stream length 4096 ≤ 4096)
PASS 1280x800 Rule 150 T = 4096: the confinement line cites FVLTS4sRule150PenV1.pen_confined and shows 13 points
PASS 1280x800 Rule 150 T = 4096: ink on the three canvases and the sphere
PASS 1280x800 Rule 150 T = 4096: no horizontal page scroll
PASS 1280x800 coin seed 5 T = 304: lattice readout = core (126 points, max |x| 9, |y| 8)
PASS 1280x800 coin seed 5 T = 304: octahedron readout = core (12 flags of 24; group order 12, A₄)
PASS 1280x800 coin seed 5 T = 304: k = −1 distance d = core 107.151391161030 (drawn to T = 304), pixels not certified 0
PASS 1280x800 coin seed 5 T = 304: no cap label (stream length 304 ≤ 4096)
PASS 1280x800 coin seed 5 T = 304: ink on the three canvases and the sphere
PASS 1280x800 coin seed 5 T = 304: no horizontal page scroll
PASS 1280x800 Goldbach shell N = 1448: lattice readout = core (26 points, max |x| 1, |y| 7)
PASS 1280x800 Goldbach shell N = 1448: octahedron readout = core (8 flags of 24; group order 12, A₄)
PASS 1280x800 Goldbach shell N = 1448: k = −1 distance d = core 25.081875610155 (drawn to T = 706), pixels not certified 0
PASS 1280x800 Goldbach shell N = 1448: no cap label (stream length 706 ≤ 4096)
PASS 1280x800 Goldbach shell N = 1448: exact readouts (g = 20, + signs 40, relation holds) and both guards printed
PASS 1280x800 Goldbach shell N = 1448: strip carries 1 shell tick(s) and all 706 signs
PASS 1280x800 Goldbach shell N = 1448: ink on the three canvases and the sphere
PASS 1280x800 Goldbach shell N = 1448: no horizontal page scroll
PASS 1280x800 Goldbach run N_max = 1448: lattice readout = core (6499 points, max |x| 115, |y| 208)
PASS 1280x800 Goldbach run N_max = 1448: octahedron readout = core (12 flags of 24; group order 12, A₄)
PASS 1280x800 Goldbach run N_max = 1448: k = −1 distance d = core 512.367770990972 (drawn to T = 4096), pixels not certified 0
PASS 1280x800 Goldbach run N_max = 1448: the caps are visible labels: "k = −1 drawn to T = 4096; the rest is not drawn" and the sphere likewise
PASS 1280x800 Goldbach run N_max = 1448: exact readouts (g = 15331, + signs 30534, relation holds) and both guards printed
PASS 1280x800 Goldbach run N_max = 1448: strip carries 723 shell tick(s) and all 257430 signs
PASS 1280x800 Goldbach run N_max = 1448: ink on the three canvases and the sphere
PASS 1280x800 Goldbach run N_max = 1448: no horizontal page scroll
PASS 1280x800 T = 0: lattice readout = core (1 points, max |x| 0, |y| 0)
PASS 1280x800 T = 0: octahedron readout = core (1 flags of 24; group order 12, A₄)
PASS 1280x800 T = 0: k = −1 distance d = core 0.000000000000 (drawn to T = 0), pixels not certified 0
PASS 1280x800 T = 0: no cap label (stream length 0 ≤ 4096)
PASS 1280x800 T = 0: the label is drawn and the pens stay at the start (0 lattice steps)
PASS 1280x800 T = 0: ink on the three canvases and the sphere
PASS 1280x800 T = 0: no horizontal page scroll
PASS 1280x800 k = −1, Rule 30, T = 48: register exact over F[i]; pixels not certified 0
PASS 1280x800 k = −1, Rule 30, T = 1024: register guaranteed intervals; pixels not certified 0
PASS 1280x800 k = −1, Rule 30, T = 4096: register guaranteed intervals; pixels not certified 0
PASS 1280x800 follow off, T = 4096: absolute view from the start, pixels not certified 0
PASS 1280x800 sphere, Rule 30, T = 1328, α = 3/96, θ = 2/24: coverage 406/432 and uncertain 0 = core; tooth events 339; pixels not certified 0
PASS 1280x800 sphere dodecahedron preset (exact in ℚ(√3, √5)): coverage 20/432, uncertain 0, the exact statement shown (five lefts close a face; 60 flags, 20 vertices; order 60, A₅ profile)
PASS 1280x800 pen card "see also" opens D1 (Clifford tab, rl = 1, D1 card shown, with its link back)
PASS 1280x800 D1 "see also" opens the Panels tab with the curvature pen card open
PASS 1280x800 fix-up 2: the case table is stacked (5 blocks, one active) and no word is broken across lines
PASS 1280x800 fix-up 3: p = 97 at zoom 1×: the whole grid, dots of 3 px (minimum), all affine points drawn (n = 94 counts O too)
PASS 1280x800 fix-up 3: zoom 2×: a window of 49 cells, larger dots, part of the points drawn
PASS 1280x800 fix-up 3: the ▶ arrow pans the window (x from 24)
PASS 1280x800 fix-up 3: zoom 4×: a window of 25 cells
PASS 1280x800 fix-up 4: P1 = P2: both outlines visible (amber 240 px, violet 288 px; violet drawn 6 px larger)
PASS 1280x800 fix-up 5: "ν (nu)" in the sum line
PASS 1280x800 fix-up 6: the refused 11a1 Δ prints −161051 with U+2212
PASS 1280x800 fix-up 7 (F3): the label rule gives "additive" (not "additive multiplicative"), "nonsplit multiplicative", "split multiplicative", "good"; p = 37 row reads "nonsplit multiplicative"
PASS 1280x800 no horizontal page scroll with the group-D and group-E cards open
PASS 1280x800 no page errors and no console errors
PASS 375x812 group headings: "D. Elliptic and BSD" (placement decided) and "E. Surface pens (exact)" last
PASS 375x812 the two pen cards are the last two cards (group E), collapsed on a fresh page; the v0.4.17 group-D cards still close group D (23 cards)
PASS 375x812 a collapsed pen card computes nothing ("Open the card to compute.")
PASS 375x812 Rule 30 T = 512: lattice readout = core (219 points, max |x| 24, |y| 11)
PASS 375x812 Rule 30 T = 512: octahedron readout = core (12 flags of 24; group order 12, A₄)
PASS 375x812 Rule 30 T = 512: k = −1 distance d = core 175.204234001017 (drawn to T = 512), pixels not certified 0
PASS 375x812 Rule 30 T = 512: no cap label (stream length 512 ≤ 4096)
PASS 375x812 Rule 30 T = 512: ink on the three canvases and the sphere
PASS 375x812 Rule 30 T = 512: no horizontal page scroll
PASS 375x812 Rule 150 T = 4096: lattice readout = core (13 points, max |x| 3, |y| 2)
PASS 375x812 Rule 150 T = 4096: octahedron readout = core (12 flags of 24; group order 12, A₄)
PASS 375x812 Rule 150 T = 4096: k = −1 distance d = core 1232.358485148210 (drawn to T = 4096), pixels not certified 0
PASS 375x812 Rule 150 T = 4096: no cap label (stream length 4096 ≤ 4096)
PASS 375x812 Rule 150 T = 4096: the confinement line cites FVLTS4sRule150PenV1.pen_confined and shows 13 points
PASS 375x812 Rule 150 T = 4096: ink on the three canvases and the sphere
PASS 375x812 Rule 150 T = 4096: no horizontal page scroll
PASS 375x812 coin seed 5 T = 304: lattice readout = core (126 points, max |x| 9, |y| 8)
PASS 375x812 coin seed 5 T = 304: octahedron readout = core (12 flags of 24; group order 12, A₄)
PASS 375x812 coin seed 5 T = 304: k = −1 distance d = core 107.151391161030 (drawn to T = 304), pixels not certified 0
PASS 375x812 coin seed 5 T = 304: no cap label (stream length 304 ≤ 4096)
PASS 375x812 coin seed 5 T = 304: ink on the three canvases and the sphere
PASS 375x812 coin seed 5 T = 304: no horizontal page scroll
PASS 375x812 Goldbach shell N = 1448: lattice readout = core (26 points, max |x| 1, |y| 7)
PASS 375x812 Goldbach shell N = 1448: octahedron readout = core (8 flags of 24; group order 12, A₄)
PASS 375x812 Goldbach shell N = 1448: k = −1 distance d = core 25.081875610155 (drawn to T = 706), pixels not certified 0
PASS 375x812 Goldbach shell N = 1448: no cap label (stream length 706 ≤ 4096)
PASS 375x812 Goldbach shell N = 1448: exact readouts (g = 20, + signs 40, relation holds) and both guards printed
PASS 375x812 Goldbach shell N = 1448: strip carries 1 shell tick(s) and all 706 signs
PASS 375x812 Goldbach shell N = 1448: ink on the three canvases and the sphere
PASS 375x812 Goldbach shell N = 1448: no horizontal page scroll
PASS 375x812 Goldbach run N_max = 1448: lattice readout = core (6499 points, max |x| 115, |y| 208)
PASS 375x812 Goldbach run N_max = 1448: octahedron readout = core (12 flags of 24; group order 12, A₄)
PASS 375x812 Goldbach run N_max = 1448: k = −1 distance d = core 512.367770990972 (drawn to T = 4096), pixels not certified 0
PASS 375x812 Goldbach run N_max = 1448: the caps are visible labels: "k = −1 drawn to T = 4096; the rest is not drawn" and the sphere likewise
PASS 375x812 Goldbach run N_max = 1448: exact readouts (g = 15331, + signs 30534, relation holds) and both guards printed
PASS 375x812 Goldbach run N_max = 1448: strip carries 723 shell tick(s) and all 257430 signs
PASS 375x812 Goldbach run N_max = 1448: ink on the three canvases and the sphere
PASS 375x812 Goldbach run N_max = 1448: no horizontal page scroll
PASS 375x812 T = 0: lattice readout = core (1 points, max |x| 0, |y| 0)
PASS 375x812 T = 0: octahedron readout = core (1 flags of 24; group order 12, A₄)
PASS 375x812 T = 0: k = −1 distance d = core 0.000000000000 (drawn to T = 0), pixels not certified 0
PASS 375x812 T = 0: no cap label (stream length 0 ≤ 4096)
PASS 375x812 T = 0: the label is drawn and the pens stay at the start (0 lattice steps)
PASS 375x812 T = 0: ink on the three canvases and the sphere
PASS 375x812 T = 0: no horizontal page scroll
PASS 375x812 k = −1, Rule 30, T = 48: register exact over F[i]; pixels not certified 0
PASS 375x812 k = −1, Rule 30, T = 1024: register guaranteed intervals; pixels not certified 0
PASS 375x812 k = −1, Rule 30, T = 4096: register guaranteed intervals; pixels not certified 0
PASS 375x812 follow off, T = 4096: absolute view from the start, pixels not certified 0
PASS 375x812 sphere, Rule 30, T = 1328, α = 3/96, θ = 2/24: coverage 406/432 and uncertain 0 = core; tooth events 339; pixels not certified 0
PASS 375x812 sphere dodecahedron preset (exact in ℚ(√3, √5)): coverage 20/432, uncertain 0, the exact statement shown (five lefts close a face; 60 flags, 20 vertices; order 60, A₅ profile)
PASS 375x812 pen card "see also" opens D1 (Clifford tab, rl = 1, D1 card shown, with its link back)
PASS 375x812 D1 "see also" opens the Panels tab with the curvature pen card open
PASS 375x812 fix-up 2: the case table is stacked (5 blocks, one active) and no word is broken across lines
PASS 375x812 fix-up 3: p = 97 at zoom 1×: the whole grid, dots of 3 px (minimum), all affine points drawn (n = 94 counts O too)
PASS 375x812 fix-up 3: zoom 2×: a window of 49 cells, larger dots, part of the points drawn
PASS 375x812 fix-up 3: the ▶ arrow pans the window (x from 24)
PASS 375x812 fix-up 3: zoom 4×: a window of 25 cells
PASS 375x812 fix-up 4: P1 = P2: both outlines visible (amber 240 px, violet 288 px; violet drawn 6 px larger)
PASS 375x812 fix-up 5: "ν (nu)" in the sum line
PASS 375x812 fix-up 6: the refused 11a1 Δ prints −161051 with U+2212
PASS 375x812 fix-up 7 (F3): the label rule gives "additive" (not "additive multiplicative"), "nonsplit multiplicative", "split multiplicative", "good"; p = 37 row reads "nonsplit multiplicative"
PASS 375x812 no horizontal page scroll with the group-D and group-E cards open
PASS 375x812 no page errors and no console errors
TIMING 1280x800 Rule 30 T = 512: both cards recomputed and drawn in 0 ms (dial change to readouts)
TIMING 1280x800 Rule 30 T = 512: lattice 0 ms, octahedron 1 ms, disk 6 + 239 ms, sphere 9 + 2 ms
TIMING 1280x800 Rule 150 T = 4096: both cards recomputed and drawn in 684 ms (dial change to readouts)
TIMING 1280x800 Rule 150 T = 4096: lattice 1 ms, octahedron 3 ms, disk 25 + 16 ms, sphere 56 + 10 ms
TIMING 1280x800 coin seed 5 T = 304: both cards recomputed and drawn in 314 ms (dial change to readouts)
TIMING 1280x800 coin seed 5 T = 304: lattice 0 ms, octahedron 1 ms, disk 1 + 12 ms, sphere 4 + 1 ms
TIMING 1280x800 Goldbach shell N = 1448: both cards recomputed and drawn in 141 ms (dial change to readouts)
TIMING 1280x800 Goldbach shell N = 1448: lattice 0 ms, octahedron 0 ms, disk 4 + 11 ms, sphere 13 + 3 ms
TIMING 1280x800 Goldbach run N_max = 1448: both cards recomputed and drawn in 1817 ms (dial change to readouts)
TIMING 1280x800 Goldbach run N_max = 1448: lattice 14 ms, octahedron 208 ms, disk 21 + 11 ms, sphere 51 + 8 ms
TIMING 1280x800 T = 0: both cards recomputed and drawn in 91 ms (dial change to readouts)
TIMING 1280x800 T = 0: lattice 0 ms, octahedron 0 ms, disk 0 + 1 ms, sphere 0 + 1 ms
TIMING 1280x800 k = −1 T = 48: 7 ms compute + 12 ms draw (exact)
TIMING 1280x800 k = −1 T = 1024: 5 ms compute + 11 ms draw (256)
TIMING 1280x800 k = −1 T = 4096: 22 ms compute + 11 ms draw (640)
TIMING 1280x800 k = −1 T = 4096 absolute view: 107 ms compute + 133 ms draw
TIMING 1280x800 sphere T = 1328: 15 ms compute + 3 ms draw (ball register, P = 96 bits)
TIMING 375x812 Rule 30 T = 512: both cards recomputed and drawn in 0 ms (dial change to readouts)
TIMING 375x812 Rule 30 T = 512: lattice 0 ms, octahedron 1 ms, disk 7 + 231 ms, sphere 9 + 2 ms
TIMING 375x812 Rule 150 T = 4096: both cards recomputed and drawn in 310 ms (dial change to readouts)
TIMING 375x812 Rule 150 T = 4096: lattice 1 ms, octahedron 4 ms, disk 26 + 14 ms, sphere 56 + 9 ms
TIMING 375x812 coin seed 5 T = 304: both cards recomputed and drawn in 299 ms (dial change to readouts)
TIMING 375x812 coin seed 5 T = 304: lattice 0 ms, octahedron 0 ms, disk 1 + 12 ms, sphere 4 + 1 ms
TIMING 375x812 Goldbach shell N = 1448: both cards recomputed and drawn in 110 ms (dial change to readouts)
TIMING 375x812 Goldbach shell N = 1448: lattice 0 ms, octahedron 1 ms, disk 3 + 11 ms, sphere 9 + 2 ms
TIMING 375x812 Goldbach run N_max = 1448: both cards recomputed and drawn in 1764 ms (dial change to readouts)
TIMING 375x812 Goldbach run N_max = 1448: lattice 14 ms, octahedron 219 ms, disk 18 + 13 ms, sphere 50 + 8 ms
TIMING 375x812 T = 0: both cards recomputed and drawn in 88 ms (dial change to readouts)
TIMING 375x812 T = 0: lattice 0 ms, octahedron 0 ms, disk 0 + 2 ms, sphere 0 + 1 ms
TIMING 375x812 k = −1 T = 48: 4 ms compute + 8 ms draw (exact)
TIMING 375x812 k = −1 T = 1024: 5 ms compute + 11 ms draw (256)
TIMING 375x812 k = −1 T = 4096: 21 ms compute + 12 ms draw (640)
TIMING 375x812 k = −1 T = 4096 absolute view: 107 ms compute + 136 ms draw
TIMING 375x812 sphere T = 1328: 17 ms compute + 3 ms draw (ball register, P = 96 bits)
SUMMARY browser-check-v0418: 128 passed, 0 failed
```

**browser-check-legacy-panels-v0418 (`build/_logs/browser-check-legacy-panels-v0418.run.log`)**

```
PASS v0.4.16 reference page present and unchanged (sha256 1da7dc8f…) at /home/saphir/membrane_compute/viewer/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_16_20261028/dist/comb-hopf.html
PASS 1280x800 identical to v0.4.16 on 7 states (stage, caption, cards, address, html stage); on the Panels tab after removing the 4 cards of v0.4.17/v0.4.18, the group-E heading, and mapping the decided D heading back
PASS 1280x800 D1 on: stage, caption, address identical to v0.4.16; the cards differ only by the one "see also" paragraph of D1
PASS 375x812 identical to v0.4.16 on 7 states (stage, caption, cards, address, html stage); on the Panels tab after removing the 4 cards of v0.4.17/v0.4.18, the group-E heading, and mapping the decided D heading back
PASS 375x812 D1 on: stage, caption, address identical to v0.4.16; the cards differ only by the one "see also" paragraph of D1
SUMMARY browser-check-legacy-panels-v0418: 5 passed, 0 failed
```

**check-expected-fails-v0418 (`build/_logs/check-expected-fails-v0418.run.log`)**

```
PASS test-v0410: the FAIL lines equal the expected list (3 expected, 3 found)
PASS test-v0411: the FAIL lines equal the expected list (1 expected, 1 found)
PASS test-v0412: the FAIL lines equal the expected list (1 expected, 1 found)
PASS test-v0413: the FAIL lines equal the expected list (1 expected, 1 found)
PASS test-v0414: the FAIL lines equal the expected list (1 expected, 1 found)
PASS browser-check-v0410: the FAIL lines equal the expected list (4 expected, 4 found)
PASS browser-check-v0411: the FAIL lines equal the expected list (2 expected, 2 found)
PASS browser-check-v0412: the FAIL lines equal the expected list (2 expected, 2 found)
PASS browser-check-v0413: the FAIL lines equal the expected list (2 expected, 2 found)
PASS browser-check-v0414: the FAIL lines equal the expected list (2 expected, 2 found)
PASS browser-check-v0417: the FAIL lines equal the expected list (4 expected, 4 found)
SUMMARY check-expected-fails-v0418: 11 passed, 0 failed
```

**shots-v0418 (membrane, `membrane_run/shots418b.log`)**

```
shot_v0418_linux_1280x800_panels_groupE_closed.png
shot_v0418_linux_1280x800_curv_r30_T512.png
shot_v0418_linux_1280x800_sph_r30_T512.png
shot_v0418_linux_1280x800_curv_r150_T4096.png
shot_v0418_linux_1280x800_curv_r30_T4096.png
shot_v0418_linux_1280x800_curv_r30_T4096_absolute.png
shot_v0418_linux_1280x800_sph_r30_T1328.png
shot_v0418_linux_1280x800_sph_dodeca_r30_T1328.png
shot_v0418_linux_1280x800_curv_gbshell_1448.png
shot_v0418_linux_1280x800_curv_gbshell_24.png
shot_v0418_linux_1280x800_curv_gbrun_1448.png
shot_v0418_linux_1280x800_sph_gbrun_1448.png
shot_v0418_linux_1280x800_curv_T0.png
shot_v0418_linux_1280x800_ell_cases_p5.png
shot_v0418_linux_1280x800_ell_p5_P1eqP2.png
shot_v0418_linux_1280x800_ell_p97_zoom1.png
shot_v0418_linux_1280x800_ell_p97_zoom2.png
shot_v0418_linux_1280x800_ell_p97_zoom4.png
shot_v0418_linux_1280x800_per_11a1_refused.png
shot_v0418_linux_1280x800_ell_points_card_p97.png
shot_v0418_linux_375x812_panels_groupE_closed.png
shot_v0418_linux_375x812_curv_r30_T512.png
shot_v0418_linux_375x812_sph_r30_T512.png
shot_v0418_linux_375x812_curv_r150_T4096.png
shot_v0418_linux_375x812_curv_r30_T4096.png
shot_v0418_linux_375x812_curv_r30_T4096_absolute.png
shot_v0418_linux_375x812_sph_r30_T1328.png
shot_v0418_linux_375x812_sph_dodeca_r30_T1328.png
shot_v0418_linux_375x812_curv_gbshell_1448.png
shot_v0418_linux_375x812_curv_gbshell_24.png
shot_v0418_linux_375x812_curv_gbrun_1448.png
shot_v0418_linux_375x812_sph_gbrun_1448.png
shot_v0418_linux_375x812_curv_T0.png
shot_v0418_linux_375x812_ell_cases_p5.png
shot_v0418_linux_375x812_ell_p5_P1eqP2.png
shot_v0418_linux_375x812_ell_p97_zoom1.png
shot_v0418_linux_375x812_ell_p97_zoom2.png
shot_v0418_linux_375x812_ell_p97_zoom4.png
shot_v0418_linux_375x812_per_11a1_refused.png
shot_v0418_linux_375x812_ell_points_card_p97.png
SUMMARY shots-v0418: 40 screenshots
```

## Open
1. **Goldbach tooth order.** "c = 0, 1, 2, … in the track's order" cannot be met literally (the track's comb order does not start at c = 0, and even-m shells have no c = 0 tooth). I used every tooth once, in the order c = 0, 1, −1, 2, −2, …, with #+ = 2g(N) − δ. If only the c ≥ 0 half was meant (#+ = g(N), length ⌈m/2⌉), that is the owner's call and a small change to `goldbachShell`.
2. **"Every stream reaches exactly 12 of the 24 flags"** holds for every long stream tested (Rule 30, Rule 150 and the coin at T = 4,096; the Goldbach run). It does **not** hold for short streams: Goldbach shell 24 (8 steps) reaches 7 flags, and shell 1,448 (706 steps) reaches 8. The 12-flag orbit (A₄) is exact. The test asserts = 12 for the long streams and ≤ 12 for the short shells, and says so.
3. **Expected-fails scope.**
   - I added browser-check-v0417 to the brief's v0410–v0414 list, because it breaks for the same Panels reason.
   - **test-v042's** single provenance FAIL line also changed: it now lists the new v0.4.18 files. It is not in the expected list (outside v0410–v0414), so it is attributed here. It is the only other changed line.
   - The test-v0411 and test-v0414 lines changed because `view-panels.js` changed (the group E heading and the decided D heading). test-v0414's "unchanged against v0.4.13" line is new in v0.4.18 for that reason.
4. **Linux-only FAIL lines.** These are present in both Linux runs (so they cancel) but are not in the Windows v0.4.17 run:
   - browser-check (40 FAIL lines on Linux against 23 on Windows: layout heights and control counts at 375 px with Linux fonts, and the Lift JSON comparison with the old viewer);
   - browser-check-v041 (4), browser-check-v044 (+2), browser-check-v048 (3): layout and ellipsis lines;
   - test-core: +6, because its reference export `C:/Users/robin/Downloads/fvlt_fourier_m7_…json` was not mirrored (it lives outside the project folders);
   - test-v0410 B4: membrane has `python3` but no `python`.
   None comes from v0.4.18.
5. **First full v0.4.18 run.** It had 7 FAIL lines in browser-check-v0418: horizontal scroll at 375 px on Linux, caused by the sphere card's preset select (wider Linux fonts; it passed on Neo). I fixed it, then fixed a word break in the "preset" label seen in the screenshots, and reran the whole suite. The final run of record is clean (128/0). The first run's logs are kept in `membrane_run/run418_first_linux/`.
6. **Uncertain cells.** Some (α, θ) put positions exactly on cell boundaries (3 at α = 24/96, θ = 4/24, T = 1,328). They are counted and not placed; deciding them would need an exact register for those angles.
7. **Q(ζ₉₆) is not used** for general angles (benchmark above). The dodecahedron preset is the only exact sphere register.
8. **Cost.** The Goldbach run on the curvature card takes about 1.8 s per change in Chromium (the octahedron draws 257,430 lifted arcs). The disk and the sphere are capped at 4,096 steps, with labels.
9. **A₅ identification.** For the dodecahedron preset, A₅ is inferred from order 60 and the element-order profile, not from an explicit isomorphism. The group order and the orbit sizes are exact.
10. **Not covered by the browser checks:** the drawn geometry beyond ink presence and the exact readouts. The pen positions are checked through the cores (node), not by reading pixels.
11. **Exports.** The pen cards are not in the JSON, state, CSV, Lift JSON, PNG or address (display only, by design).
12. **VIEWERS_LATEST.** The v0.4.17, v0.4.16 and v0.4.14 rows still say "latest" next to the new v0.4.18 row (additive edits only). `sha256sum -c` there passes 45/45.
13. **Independent verification** of v0.4.18 is open, and so is that of the inherited v0.4.16. I wrote both the checks and the cards.

## Files added or changed relative to the v0.4.17 copy (sha256)

222 added, 26 changed; none removed. This report and SHA256SUMS.txt are not listed; SHA256SUMS.txt (regenerated) covers every file in the folder except itself, this report included. `build/_logs/` holds the logs of the final membrane run (they replace the copied v0.4.17 Windows logs of the same names; v0.4.17's own logs are unchanged in its folder).

```
added cd077adaf3cc10c169aaab83ece20ecda0990d14330bc1eba3983edf3bc162b7 SCHEMA_ADDENDUM_25.md
added af1c48f6ea232b77dd312902c5d509c6aa3ddd078091074c23d222fd4655f48e build/EXPECTED_FAILS_v0418.txt
added a0d14144af0a590a1c097feca98085d8936f21f4039ee042fa82bbf8da7d1e62 build/_logs/SUMMARY_v0418.txt
added 05e4dc215b17565f7c1056fa0518203705f17bc37cc4379b4903aeb5844e2047 build/_logs/browser-check-legacy-panels-v0418.run.log
changed 4763ae0c8991e3027c87a4a778b8090ffa685966e3dae730f78d8f84a46bfdac build/_logs/browser-check-v041.run.log
changed b32de49a30979745b18fcab763fbf69fff911dbdc121fd42a65fdaaa972dae50 build/_logs/browser-check-v0410.run.log
changed 21cc797ea298f12eae4c11d564a79ca4efe31cba0e9880e6f73516bd71188871 build/_logs/browser-check-v0414.run.log
changed 9c8008928514557ef62d98b13c8d2f24fe4c406e6644373104632fd92be690bc build/_logs/browser-check-v0417.run.log
added b41c67e8f9ab6f4cad5f30c2f3d4a4c61da7a19fe3fcbae5b5d534febdccd3e3 build/_logs/browser-check-v0418.run.log
changed b49890c1597c063f7bad1a59ac61499babbd9a00cb04ec6d1184e701d1f84f83 build/_logs/browser-check-v044.run.log
changed c285e9c6e9f3b93cbe7c9ecb6aed068041042f99cf2fdc34b022792d2f020b08 build/_logs/browser-check-v048.run.log
changed b08fb1fba327b1662b72c60f1b968796b36b602b66ea57b8fecc62219ca234f5 build/_logs/browser-check-v049.run.log
changed 41d2024b8ea0b3a71d93f4e73e49c18b9c81b63d2ec9bb5f4a91116e55ae6ac7 build/_logs/browser-check.run.log
added 3871806a4415f148ace10b9996ed306891666a94bfa4f5ee468b4068a3049bdc build/_logs/check-expected-fails-v0418.run.log
changed e0a474996a9a4a948c881debdda1041e13757b20216ff4ef92fc01d28102c941 build/_logs/no-float-elliptic.run.log
added d0e02182afac993bf0aad8fb053c79a2f58f0f28782787581dd26468f5d3064c build/_logs/no-float-v0418.run.log
changed eca25e6a5b69893a334be405cf8d0d2f88b1f2c8de33b042fbcd30cf5aa308b5 build/_logs/test-core.run.log
changed 853ed7b1f9dd373691fa34e5098a94a9e5cefb47112fb1947ae0dca94cb8f906 build/_logs/test-elliptic-period.run.log
added f3e94f19475d18ba11cd529dc6d7acdf95a68c3d7f98a935701a9641eb076f08 build/_logs/test-pen-curvature.run.log
added 4e474288b7450495c1e9f7e613390c6ccbebd92eee6f3355c391900160aaa244 build/_logs/test-pen-fields.run.log
added 07a2a5164dd56c6de01a08f9ac97e14d243e14ed1ee192ae3fafccc0b31ffd48 build/_logs/test-pen-sphere.run.log
added 7122061b08a457a41734f335a3a9dbe283caf47bade5294bdc8cba4977d54e14 build/_logs/test-pen-streams.run.log
changed 7fd400d10bf1db4fa45e13986ee9243a4ba5e2cbabb71da44c63b5a5e1085c94 build/_logs/test-v0410.run.log
changed dc6bf40d9708b46b769fe4ab0c95c8cee6dd1c5f54d6dc293bde4f5a32aad125 build/_logs/test-v0411.run.log
changed 309c6ede085e284852c0789cd87082190aac3ceb3d03a4f4ec489e4fadd9c4df build/_logs/test-v0412.run.log
changed 20a1eb98228a99c7a6824c8332d7965ef8cca52816b3159fcff6985451526ad5 build/_logs/test-v0413.run.log
changed 265e5d11fbb26db9397a25617479eb379e88fbd0982cde730331a9d598340b33 build/_logs/test-v0414.run.log
added 431824a5602afbccd0cb09f4771d7bfd3eef9c401d2bd51a7b3ce80f6b3d08fb build/_logs/test-v0418-fixups.run.log
changed e04fcd76741a259482574a25a984570d95c0a1ed7706e8411c2a27134fe5589f build/_logs/test-v042.run.log
added 3a6f1f4056ebcaf6123291d62104ef2252241cd779d147071214a53d26efefc2 build/browser-check-legacy-panels-v0418.cjs
added 8681dc07bb462e3de896d32d588638627988f6a537a1bb7c24342104f40d272c build/browser-check-v0418.cjs
added e458fdc56a071d7e2518bd826ce19078f8fc57bd8e96b5afa578cedb4a5ed77a build/check-expected-fails-v0418.cjs
added 26e445d419baab45f8505b0bb80ce587676f57f6e04e8fe121b8d4633a870454 build/no-float-v0418.cjs
changed 7adaf720d40fa591f313e42ecf38b707e0fc42e6c0886c00c2443fb1f3ac144a build/package.cjs
changed dcd9a37d8aa6626387cddd8d4005f13ba9d800a1c6e0ab3c1a03718cd08f8850 build/runall.sh
added affddd868dc2deb201c0e9b46976139a3228727cef524c9d1817afda1d81d40e build/shots-v0418.cjs
changed d811319ee4c15c4790be45cbd67e3ec85ca0c6a369a4bbd957c0bd3a8b0166a9 dist/MANIFEST.sha256
changed 0ccc87aef5612d572bdf4459eeeb5b00014b3b63b3c90dd66548a5f1225968e8 dist/comb-hopf.html
added d0f3056a2c327b6e625ab19baaccb7c6dd5ac533718006f1d96b464dcb3f502e host-core/field-q2-q5-tau.js
added 2309e243c737c5ddb24ddd67ee6213d36e7a755ef4a21d6bed64b6004f6737df host-core/pen-curvature-core.js
added 312227e77b4260c28fda6b370d931cc3bb21be728d408af61220fd0f261f3cfc host-core/pen-interval-core.js
added 2b951fae932686c2b15afef63ad14c08d5e908885ee6217d7b9a358f02f0b599 host-core/pen-sphere-core.js
added 546515971852088af54c279db72d613fe8632fd866445eea81782ba3b6f743d2 host-core/pen-streams-core.js
added 63f69474607d508e3b1f59f6b170d4a4d69ba95a15ff31770569275ed9b81eb5 host-core/test-pen-curvature.cjs
added 481f8e34426d1806a55f4c0b0bfc96d25d5a701767c74106670b6203834bb1c9 host-core/test-pen-fields.cjs
added 62b2a29c872581a0d3ac47b06dc67c46c62402978870e26d7281332013458497 host-core/test-pen-sphere.cjs
added 30135e52cfe44ee7f89bacf34b4c7f7b4ccfca5ee36335a97b701af4ba10e950 host-core/test-pen-streams.cjs
added 327434c1f5a1ffaee76803858a40e93cac2f89eeb91cf5f5e7925da78fa3ef09 host-core/test-v0418-fixups.cjs
added ae3c90ae35d17f73afe37c86e605a7ac176ee0470b05bfe41f51015f04e13209 host-core/transcription-skeleton-pens.cjs
changed ad3dc21cdc1923b6f2b1153ed5e5ea13eb7d7bd2ecfec8ea0a58ef40067ae90e instruments/comb-hopf/README.md
changed 80cd86fd49fa1e74f16ac7b1e11cfb6c7b712d5702eca335f3cb93caab25f6ae instruments/comb-hopf/index.html
changed e6b379cc253226bdf008d79d19155ef2ee7d0e524ab05f925368c809da5423dd instruments/comb-hopf/panel-elliptic.js
added 93c3bfbe3468356514f60bda37c69145a994d20a133fffb7467a603d4bfd38c0 instruments/comb-hopf/panel-pens.js
changed 4db53a98c24695068b37e0bfa2f22f2f68c26c37642b5efc20af366a8c7962fd instruments/comb-hopf/view-clifford.js
changed e5eaf01acc544ab9dbfc4cbf2674c5505427ea26f13544217771786deca56fff instruments/comb-hopf/view-panels.js
added fcc178b79c2c06e33b2f008b7626fd7c8206c1b66d410ab69fa0a5264d6742a9 membrane_receipts/VIEW-NODE-0418-01/MANIFEST.sha256
added 202b84a38f5e5304aa4b46306f7070c554778776bd9edb673fa8f6d6d248ef31 membrane_receipts/VIEW-NODE-0418-01/PREREG
added 696b38bd09429adb31c4506cd15fe71738dc3918105142e1a0ca332c3a8d4bff membrane_receipts/VIEW-NODE-0418-01/RECEIPT.json
added e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 membrane_receipts/VIEW-NODE-0418-01/stderr.txt
added 7122061b08a457a41734f335a3a9dbe283caf47bade5294bdc8cba4977d54e14 membrane_receipts/VIEW-NODE-0418-01/stdout.txt
added b0d4a150679b592e6a7dff8f484e6c37cd03048c579e70fd8c3de9c4f38db10e membrane_receipts/VIEW-NODE-0418-01/time.log
added c46db9a9b228c512b239e9d521a49df60b62c3123cca904afdf434d716bd8526 membrane_receipts/VIEW-NODE-0418-02/MANIFEST.sha256
added 7d8791efb0e25e9fae504f4532e37ef031126e088d95494e1b29c93adc7dbfe1 membrane_receipts/VIEW-NODE-0418-02/PREREG
added 65a0a54184dd51fe4aa3b4d8d5ef36d60cfeae3ada236071b98c165b1a92b7a9 membrane_receipts/VIEW-NODE-0418-02/RECEIPT.json
added e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 membrane_receipts/VIEW-NODE-0418-02/stderr.txt
added 4e474288b7450495c1e9f7e613390c6ccbebd92eee6f3355c391900160aaa244 membrane_receipts/VIEW-NODE-0418-02/stdout.txt
added 78ded08c20e2665f553d1cdeb80b0af5dafb2a524b30e852984ef5d0ed72ecfe membrane_receipts/VIEW-NODE-0418-02/time.log
added 154fd62264e3e0e02d9a8723487834257ef8897a873c9bdd60e2df4844014ce7 membrane_receipts/VIEW-NODE-0418-03/MANIFEST.sha256
added d889b536bbf72081141a7cee7bdd910c275730bda6b38a30bb4367bb10d8f29e membrane_receipts/VIEW-NODE-0418-03/PREREG
added edaada3b7994afcb14b90ebb0054da8c87607ec0676f04dd07d47eb9d0eddec5 membrane_receipts/VIEW-NODE-0418-03/RECEIPT.json
added e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 membrane_receipts/VIEW-NODE-0418-03/stderr.txt
added 0f9b32cf486423719f4e884f1031b4b76d1e7bcbbf3d7d2944a6443d45260c93 membrane_receipts/VIEW-NODE-0418-03/stdout.txt
added 28049ddfd25efcc4e2633e4e3798ee3532bcef5b2e139ad1006979317bf9f59c membrane_receipts/VIEW-NODE-0418-03/time.log
added bbe6fe84f5b1bf3e162fd5108da78d550e4824c7d24d3acdbb95a2c9c4a24052 membrane_receipts/VIEW-NODE-0418-04/MANIFEST.sha256
added 2e3b34d7e30cae01cc0bd854c90c8ceea2ff124e8d7e2f449315ad2cb7d67fd4 membrane_receipts/VIEW-NODE-0418-04/PREREG
added 4ed0bb9110cdd64c61d0b60730e2a03c6dd59e27102be963d6fb879ef44fe298 membrane_receipts/VIEW-NODE-0418-04/RECEIPT.json
added e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 membrane_receipts/VIEW-NODE-0418-04/stderr.txt
added a40aabf83680ff9a82752497b173f7c4b1ad8e701556d175ebd127be77e6e81b membrane_receipts/VIEW-NODE-0418-04/stdout.txt
added 905eebb8bcff794955b4ea56a03f43a39015e8910bce42e6c4ecfa6fec02d295 membrane_receipts/VIEW-NODE-0418-04/time.log
added c19b3507ccd719ae8a3c9f68e36383984ba839c5f18b57921e1916a53dc5c434 membrane_receipts/VIEW-NODE-0418-05/MANIFEST.sha256
added bf2e28cdf55394e991f69c8696a7a7a24647f86689677652e1e364b12c201fa8 membrane_receipts/VIEW-NODE-0418-05/PREREG
added 8dda8c486ddac9b1151cafe4bb86a71228f90c9be0a5345e0a4e693f37ef9320 membrane_receipts/VIEW-NODE-0418-05/RECEIPT.json
added e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 membrane_receipts/VIEW-NODE-0418-05/stderr.txt
added 431824a5602afbccd0cb09f4771d7bfd3eef9c401d2bd51a7b3ce80f6b3d08fb membrane_receipts/VIEW-NODE-0418-05/stdout.txt
added 0d8f2368413b02a0efc42dbaf3c15f94ea8b2bd478b30f997c3ae7cef24147f1 membrane_receipts/VIEW-NODE-0418-05/time.log
added 02b15de61358234c1b04187a8a8ea6d61ca62f2f288a91d88a06f7ba060f385c membrane_receipts/VIEW-NODE-0418-06/MANIFEST.sha256
added 65797e3b3e3f09e43e139affb68cf0097da2c1534b014b0bed863ddbf0774f87 membrane_receipts/VIEW-NODE-0418-06/PREREG
added cd1815b9bacff9d7b02069ea1dc044b884927a9dcf1f641261ba427c4e8a02a0 membrane_receipts/VIEW-NODE-0418-06/RECEIPT.json
added e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 membrane_receipts/VIEW-NODE-0418-06/stderr.txt
added d0e02182afac993bf0aad8fb053c79a2f58f0f28782787581dd26468f5d3064c membrane_receipts/VIEW-NODE-0418-06/stdout.txt
added 69a42af2b3679c3687e0108b25a0d0b889e3969fac04da19110c4d5ff9a208e2 membrane_receipts/VIEW-NODE-0418-06/time.log
added 8fdfc927b37d8b5cb8bb4fac793835401319435f18b8cd8c59d3a90ba2e2f722 membrane_receipts/VIEW-NODE-0418-07/MANIFEST.sha256
added 3b053494bf2299a33605dc937d1117557e994ed8b201bdde38fbbb21130995ff membrane_receipts/VIEW-NODE-0418-07/PREREG
added bb03e5f6a1906696e0588631a5bb8465afd40ef44022ed972bf4f2da1c98ffb8 membrane_receipts/VIEW-NODE-0418-07/RECEIPT.json
added e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 membrane_receipts/VIEW-NODE-0418-07/stderr.txt
added d0e02182afac993bf0aad8fb053c79a2f58f0f28782787581dd26468f5d3064c membrane_receipts/VIEW-NODE-0418-07/stdout.txt
added 8871660c71e30916bc239273eaa401db827623240767616012da0e02bbcd0d0d membrane_receipts/VIEW-NODE-0418-07/time.log
added 202b84a38f5e5304aa4b46306f7070c554778776bd9edb673fa8f6d6d248ef31 membrane_receipts/prereg_01.txt
added 7d8791efb0e25e9fae504f4532e37ef031126e088d95494e1b29c93adc7dbfe1 membrane_receipts/prereg_02.txt
added d889b536bbf72081141a7cee7bdd910c275730bda6b38a30bb4367bb10d8f29e membrane_receipts/prereg_03.txt
added 2e3b34d7e30cae01cc0bd854c90c8ceea2ff124e8d7e2f449315ad2cb7d67fd4 membrane_receipts/prereg_04.txt
added bf2e28cdf55394e991f69c8696a7a7a24647f86689677652e1e364b12c201fa8 membrane_receipts/prereg_05.txt
added 65797e3b3e3f09e43e139affb68cf0097da2c1534b014b0bed863ddbf0774f87 membrane_receipts/prereg_06.txt
added c0a2d5d7f39a24a633590518cf71381ee633a72e126325f65c9450ba37c1bbc0 membrane_run/PATHMAP.md
added 8c5ed7de280e762bad9bcee078264cc9bd597d5eac5e3038573bb136787b3337 membrane_run/baseline_v0417_linux/SUMMARY_v0414.txt
added 654bef3bd7dcbe39991e09196005be49c0cf396984f8846070703f6ffe2fe937 membrane_run/baseline_v0417_linux/SUMMARY_v0416.txt
added 477c94723557311704e9c5b4624e650f8657cd428cf231b947063b667cfb4def membrane_run/baseline_v0417_linux/SUMMARY_v0417.txt
added 4d85c1ec89b9fafcbe8c9c3bc6070ddf393f9a6ff4664df996275dc6b7dc6beb membrane_run/baseline_v0417_linux/browser-check-mirror.run.log
added 4763ae0c8991e3027c87a4a778b8090ffa685966e3dae730f78d8f84a46bfdac membrane_run/baseline_v0417_linux/browser-check-v041.run.log
added 5491d835df740d2d9aab9158faad665e4f568e3d04c2c909a21154717945f8ea membrane_run/baseline_v0417_linux/browser-check-v0410.run.log
added 2cc6d890f609f970cb9ec6ddf9cef941704e6695d9558c887c97bad2d4f386a7 membrane_run/baseline_v0417_linux/browser-check-v0411.run.log
added 6eec2ffa8e218fb9b1c3709550248c5f6a5744f62805b86852732c3ee513f540 membrane_run/baseline_v0417_linux/browser-check-v0412.run.log
added 8460fbf065ffd889f26d5dfc586b144ec5c6105e07240c2904a6d51084b2a841 membrane_run/baseline_v0417_linux/browser-check-v0413.run.log
added fa326de1e26ecdad66d3985036e5c723aca89f12e96ff328d759106a9be810df membrane_run/baseline_v0417_linux/browser-check-v0414.run.log
added a084acc8bbda34125bff8e0691e87fb2df8002355b1a9828ecc1b9249d6bcc51 membrane_run/baseline_v0417_linux/browser-check-v0416.run.log
added f96c80d67cc435bd576901485e7647c6be53c125d0ede3b6f54a3cdd65cddf49 membrane_run/baseline_v0417_linux/browser-check-v0417.run.log
added 9216e7c23ec8b593dd777b14a9e0258948cc0749a1695266b19b42611068302f membrane_run/baseline_v0417_linux/browser-check-v042.run.log
added 443d57321ab039f8819e92487b84c4c543498c26c2666369a2db2156c4504e07 membrane_run/baseline_v0417_linux/browser-check-v043.run.log
added b49890c1597c063f7bad1a59ac61499babbd9a00cb04ec6d1184e701d1f84f83 membrane_run/baseline_v0417_linux/browser-check-v044.run.log
added 8a68b8906b042a1e73a99fcdfe3154a038750bb682057841f30fe92b2f3533cc membrane_run/baseline_v0417_linux/browser-check-v045.run.log
added a6ad7876618ff07c28667c5452b565abed45261e9e6dfeb7986e17aa036ae936 membrane_run/baseline_v0417_linux/browser-check-v046.run.log
added 8f6c06758baa1e4dda52c97820ffbf81c909c0d831032f200e178eadb6613032 membrane_run/baseline_v0417_linux/browser-check-v047.run.log
added c285e9c6e9f3b93cbe7c9ecb6aed068041042f99cf2fdc34b022792d2f020b08 membrane_run/baseline_v0417_linux/browser-check-v048.run.log
added 94b76ecd38fa18f25d0cc8a65e7ef3ba3bff9245845d7f6148119014cfea34e5 membrane_run/baseline_v0417_linux/browser-check-v049.run.log
added fb82544624751cd53cca468b1d3408587d2cf1d8592f13fbe31ca8ec62a0defa membrane_run/baseline_v0417_linux/browser-check.run.log
added 1b8ca203da750f5ce6469a799c520b3918c421393396ee033bb4908ebf5b4a7b membrane_run/baseline_v0417_linux/contrast-check.run.log
added 9249bb009a37d9f6678f457cd82de719f07187e8e58e65f086aaf09770a37069 membrane_run/baseline_v0417_linux/no-float-elliptic.run.log
added eca25e6a5b69893a334be405cf8d0d2f88b1f2c8de33b042fbcd30cf5aa308b5 membrane_run/baseline_v0417_linux/test-core.run.log
added 876b389044a46b3f82c4263849f443fcf2b448ea7f9b701e5e3b2161a8e9bc8b membrane_run/baseline_v0417_linux/test-elliptic-exact.run.log
added 778127d590871d62c058709e555352591d170b8e8c2035640a1d67c74c1db4ac membrane_run/baseline_v0417_linux/test-elliptic-period.run.log
added dc1846c26f52880f699f1de172fd849f077920c45322f6b954fb2c66284cb5c3 membrane_run/baseline_v0417_linux/test-exact.run.log
added 5a555091cc1c227c98b1610a6236f75da0cdd9ebbb40ca2cb4801f8954ae4e32 membrane_run/baseline_v0417_linux/test-mirror.run.log
added b9135a8a7cc8624303e4e3a74528ab0dbced578caee5f16c0e4c672aa503645d membrane_run/baseline_v0417_linux/test-rule30-ladder.run.log
added ea8a2f42a6e04eb92215b6fd89aa11a4072bc8b65fd92e458d9f17ff16e1e88e membrane_run/baseline_v0417_linux/test-v041.run.log
added 7fd400d10bf1db4fa45e13986ee9243a4ba5e2cbabb71da44c63b5a5e1085c94 membrane_run/baseline_v0417_linux/test-v0410.run.log
added 493c49f49a35858461dc262f96910541d5742bc4d0f8f0229673e3c30270af9d membrane_run/baseline_v0417_linux/test-v0411.run.log
added e20c160724d4ff1997d3b50f0fef3c932b54ed3d0ef6991db32f82e5fe4ede73 membrane_run/baseline_v0417_linux/test-v0412.run.log
added f15d4eece594d3a5a563f36fa88802fb4aa1a06f6fc90e08c6b5337527df8498 membrane_run/baseline_v0417_linux/test-v0413.run.log
added f3eb5031af71171bf2f999e06c534dad4c2d27d5add0d7a161e45186b9fc39f2 membrane_run/baseline_v0417_linux/test-v0414.run.log
added a2e501aa03cbe1bb1a81a70cda7a80f9975b7160fbcabcd81f50a5b39b7e1f74 membrane_run/baseline_v0417_linux/test-v042.run.log
added 3babc9a98d8e0a309c3a95100bd4cba2ff0365cbee63e0642960aad3793f1d87 membrane_run/baseline_v0417_linux/test-v044.run.log
added 7b69e15a3a5acc80217776468255ad21a8bc8ce6d87f258e5892cb3160eb131a membrane_run/baseline_v0417_linux/test-v047.run.log
added d4365a439bb52d56fa2053e9c971d1e66d35b11888dc6f8b895f44779972af5c membrane_run/baseline_v0417_linux/test-v049.run.log
added 55464d58b93d45d5ffee4212e353f918bdff5e3f1e3222cb81ce35d6914ff874 membrane_run/pathmap.cjs
added ca5c3d0817aae871b1732f794fc59f3ebd6a10c4953000712f4ede9d5965b4e0 membrane_run/pathmap_417.diff
added 5f0326e8be05fb19104480c249c353b6cd574eb819d64af8902d92587143d749 membrane_run/pathmap_418.diff
added 5e3f82dca562245b12cef890855e7a8dd0cd97e478ee491e77d3aab90ebd29d4 membrane_run/pre418_expected_fails/browser-check-v0410.run.log
added 2cc6d890f609f970cb9ec6ddf9cef941704e6695d9558c887c97bad2d4f386a7 membrane_run/pre418_expected_fails/browser-check-v0411.run.log
added 6eec2ffa8e218fb9b1c3709550248c5f6a5744f62805b86852732c3ee513f540 membrane_run/pre418_expected_fails/browser-check-v0412.run.log
added 8460fbf065ffd889f26d5dfc586b144ec5c6105e07240c2904a6d51084b2a841 membrane_run/pre418_expected_fails/browser-check-v0413.run.log
added 282ee7f58018d88280a4f907b5fdb79780aa671625ced7d113295327a86b736b membrane_run/pre418_expected_fails/browser-check-v0414.run.log
added 7a272c2343cb6841588b583d54890cd358003142bbc949d44ef0b1413669cdff membrane_run/pre418_expected_fails/browser-check-v0417.run.log
added 7fd400d10bf1db4fa45e13986ee9243a4ba5e2cbabb71da44c63b5a5e1085c94 membrane_run/pre418_expected_fails/test-v0410.run.log
added dc6bf40d9708b46b769fe4ab0c95c8cee6dd1c5f54d6dc293bde4f5a32aad125 membrane_run/pre418_expected_fails/test-v0411.run.log
added 309c6ede085e284852c0789cd87082190aac3ceb3d03a4f4ec489e4fadd9c4df membrane_run/pre418_expected_fails/test-v0412.run.log
added 20a1eb98228a99c7a6824c8332d7965ef8cca52816b3159fcff6985451526ad5 membrane_run/pre418_expected_fails/test-v0413.run.log
added 265e5d11fbb26db9397a25617479eb379e88fbd0982cde730331a9d598340b33 membrane_run/pre418_expected_fails/test-v0414.run.log
added 8c5ed7de280e762bad9bcee078264cc9bd597d5eac5e3038573bb136787b3337 membrane_run/run418_first_linux/SUMMARY_v0414.txt
added 654bef3bd7dcbe39991e09196005be49c0cf396984f8846070703f6ffe2fe937 membrane_run/run418_first_linux/SUMMARY_v0416.txt
added b3a569d4513042057cdaa099439b344d6b3206302516982763f3733947ef5d5e membrane_run/run418_first_linux/SUMMARY_v0417.txt
added 1a61d22a1e00aae529ba2e18c5054de44b90115ac65412a8396ab4a5b7cdb299 membrane_run/run418_first_linux/SUMMARY_v0418.txt
added 05e4dc215b17565f7c1056fa0518203705f17bc37cc4379b4903aeb5844e2047 membrane_run/run418_first_linux/browser-check-legacy-panels-v0418.run.log
added 4d85c1ec89b9fafcbe8c9c3bc6070ddf393f9a6ff4664df996275dc6b7dc6beb membrane_run/run418_first_linux/browser-check-mirror.run.log
added 4763ae0c8991e3027c87a4a778b8090ffa685966e3dae730f78d8f84a46bfdac membrane_run/run418_first_linux/browser-check-v041.run.log
added 2e9e3614b79a745ccffb57e8fdb276f254200da2a41bbab989b51495175f2455 membrane_run/run418_first_linux/browser-check-v0410.run.log
added 2cc6d890f609f970cb9ec6ddf9cef941704e6695d9558c887c97bad2d4f386a7 membrane_run/run418_first_linux/browser-check-v0411.run.log
added 6eec2ffa8e218fb9b1c3709550248c5f6a5744f62805b86852732c3ee513f540 membrane_run/run418_first_linux/browser-check-v0412.run.log
added 8460fbf065ffd889f26d5dfc586b144ec5c6105e07240c2904a6d51084b2a841 membrane_run/run418_first_linux/browser-check-v0413.run.log
added 610feaa45f1cb828d1264d85f69089834c5bee8a18d30fcd027b6f873470c256 membrane_run/run418_first_linux/browser-check-v0414.run.log
added a084acc8bbda34125bff8e0691e87fb2df8002355b1a9828ecc1b9249d6bcc51 membrane_run/run418_first_linux/browser-check-v0416.run.log
added 570a1afe1dbf1c0898a4b19e48ef6c5d0b5da630d49860623d5b900622ffe103 membrane_run/run418_first_linux/browser-check-v0417.run.log
added 34a8047df4bd1d805f96a856595f85d7bd51c118f75fe24c429eedb08dec604f membrane_run/run418_first_linux/browser-check-v0418.run.log
added 9216e7c23ec8b593dd777b14a9e0258948cc0749a1695266b19b42611068302f membrane_run/run418_first_linux/browser-check-v042.run.log
added 443d57321ab039f8819e92487b84c4c543498c26c2666369a2db2156c4504e07 membrane_run/run418_first_linux/browser-check-v043.run.log
added b49890c1597c063f7bad1a59ac61499babbd9a00cb04ec6d1184e701d1f84f83 membrane_run/run418_first_linux/browser-check-v044.run.log
added 8a68b8906b042a1e73a99fcdfe3154a038750bb682057841f30fe92b2f3533cc membrane_run/run418_first_linux/browser-check-v045.run.log
added a6ad7876618ff07c28667c5452b565abed45261e9e6dfeb7986e17aa036ae936 membrane_run/run418_first_linux/browser-check-v046.run.log
added 8f6c06758baa1e4dda52c97820ffbf81c909c0d831032f200e178eadb6613032 membrane_run/run418_first_linux/browser-check-v047.run.log
added c285e9c6e9f3b93cbe7c9ecb6aed068041042f99cf2fdc34b022792d2f020b08 membrane_run/run418_first_linux/browser-check-v048.run.log
added b08fb1fba327b1662b72c60f1b968796b36b602b66ea57b8fecc62219ca234f5 membrane_run/run418_first_linux/browser-check-v049.run.log
added e3deccd1c5513e86e14be4124d21818e1b627740046e926f8e0476c7a4932680 membrane_run/run418_first_linux/browser-check.run.log
added 3871806a4415f148ace10b9996ed306891666a94bfa4f5ee468b4068a3049bdc membrane_run/run418_first_linux/check-expected-fails-v0418.run.log
added 1b8ca203da750f5ce6469a799c520b3918c421393396ee033bb4908ebf5b4a7b membrane_run/run418_first_linux/contrast-check.run.log
added e0a474996a9a4a948c881debdda1041e13757b20216ff4ef92fc01d28102c941 membrane_run/run418_first_linux/no-float-elliptic.run.log
added d0e02182afac993bf0aad8fb053c79a2f58f0f28782787581dd26468f5d3064c membrane_run/run418_first_linux/no-float-v0418.run.log
added eca25e6a5b69893a334be405cf8d0d2f88b1f2c8de33b042fbcd30cf5aa308b5 membrane_run/run418_first_linux/test-core.run.log
added 876b389044a46b3f82c4263849f443fcf2b448ea7f9b701e5e3b2161a8e9bc8b membrane_run/run418_first_linux/test-elliptic-exact.run.log
added fecc8bc1af918e83ac5ea48221c459bd0d72137396e0d367fc42c9d3c0ac56b1 membrane_run/run418_first_linux/test-elliptic-period.run.log
added dc1846c26f52880f699f1de172fd849f077920c45322f6b954fb2c66284cb5c3 membrane_run/run418_first_linux/test-exact.run.log
added 5a555091cc1c227c98b1610a6236f75da0cdd9ebbb40ca2cb4801f8954ae4e32 membrane_run/run418_first_linux/test-mirror.run.log
added 13f920901c22c4873aa39d52de44992a436060f0d17bbaaed78de064915deda4 membrane_run/run418_first_linux/test-pen-curvature.run.log
added 4e474288b7450495c1e9f7e613390c6ccbebd92eee6f3355c391900160aaa244 membrane_run/run418_first_linux/test-pen-fields.run.log
added 410faa69c1c498dddee80faa8b788f23061880ad115560de0ca686d82582e267 membrane_run/run418_first_linux/test-pen-sphere.run.log
added 55b350d1a75e42256fe81e368f69829ab1ef016da59a6b40ea305f07525f1ec6 membrane_run/run418_first_linux/test-pen-streams.run.log
added b9135a8a7cc8624303e4e3a74528ab0dbced578caee5f16c0e4c672aa503645d membrane_run/run418_first_linux/test-rule30-ladder.run.log
added ea8a2f42a6e04eb92215b6fd89aa11a4072bc8b65fd92e458d9f17ff16e1e88e membrane_run/run418_first_linux/test-v041.run.log
added 7fd400d10bf1db4fa45e13986ee9243a4ba5e2cbabb71da44c63b5a5e1085c94 membrane_run/run418_first_linux/test-v0410.run.log
added dc6bf40d9708b46b769fe4ab0c95c8cee6dd1c5f54d6dc293bde4f5a32aad125 membrane_run/run418_first_linux/test-v0411.run.log
added 309c6ede085e284852c0789cd87082190aac3ceb3d03a4f4ec489e4fadd9c4df membrane_run/run418_first_linux/test-v0412.run.log
added 20a1eb98228a99c7a6824c8332d7965ef8cca52816b3159fcff6985451526ad5 membrane_run/run418_first_linux/test-v0413.run.log
added 265e5d11fbb26db9397a25617479eb379e88fbd0982cde730331a9d598340b33 membrane_run/run418_first_linux/test-v0414.run.log
added 431824a5602afbccd0cb09f4771d7bfd3eef9c401d2bd51a7b3ce80f6b3d08fb membrane_run/run418_first_linux/test-v0418-fixups.run.log
added e04fcd76741a259482574a25a984570d95c0a1ed7706e8411c2a27134fe5589f membrane_run/run418_first_linux/test-v042.run.log
added 3babc9a98d8e0a309c3a95100bd4cba2ff0365cbee63e0642960aad3793f1d87 membrane_run/run418_first_linux/test-v044.run.log
added 7b69e15a3a5acc80217776468255ad21a8bc8ce6d87f258e5892cb3160eb131a membrane_run/run418_first_linux/test-v047.run.log
added d4365a439bb52d56fa2053e9c971d1e66d35b11888dc6f8b895f44779972af5c membrane_run/run418_first_linux/test-v049.run.log
added 3a62b604d80602fd25d319641711e85726e7a748f354d814069ddc4dd7d23623 membrane_run/shots418.log
added 3a62b604d80602fd25d319641711e85726e7a748f354d814069ddc4dd7d23623 membrane_run/shots418b.log
added 989279d3734bc25f338bea6dd3d012bf17824823935097d9d97d60d4b5f2d86e shot_v0418_linux_1280x800_curv_T0.png
added 4a36bb2730f41c0cdffae2c03764c91de494829a1e06bcbebd00893484d3c755 shot_v0418_linux_1280x800_curv_gbrun_1448.png
added 24dd1fc50d429e3625fba10934cef32ca6798205e240fa7d3d667cc298ea9791 shot_v0418_linux_1280x800_curv_gbshell_1448.png
added fa8ebfac2505d81cace3ec6027dbf0c996018e10370b5c847c38a9fbd13ca4aa shot_v0418_linux_1280x800_curv_gbshell_24.png
added 04cfc90f72fdea47871ed9c69bfc36c9bf514008d7219c54651a355c85805602 shot_v0418_linux_1280x800_curv_r150_T4096.png
added 1a7ee3f1dbcd741baa76995ec753ea30c1d214fb8e0c9017ccaddeca75de5d26 shot_v0418_linux_1280x800_curv_r30_T4096.png
added 68225123e1997eb7958f4e2b6ba296bd42087006ef61c8fbc084b10e4782c828 shot_v0418_linux_1280x800_curv_r30_T4096_absolute.png
added 6a35dc059e6a8f318e7f4981e023f3063614f6f7bd40418f9c8e4d1859c72cbe shot_v0418_linux_1280x800_curv_r30_T512.png
added 0db3086cad1746fca2730d7dbf57b5e9065a17ec932acd1cdae601179f0484d4 shot_v0418_linux_1280x800_ell_cases_p5.png
added 99e98588bba8388e2df4a9a7e6214dca6c554185ac6c3835bdd0d7751dbbad8c shot_v0418_linux_1280x800_ell_p5_P1eqP2.png
added 874ceacdc28376a2e70d4b02e0922b642cd1adb1e2b2da1075a930c9b229a2ca shot_v0418_linux_1280x800_ell_p97_zoom1.png
added dc1b4a0467d49d64930bcde73492e899e1b8e23dd94afd6ca2403cb4b2be7a10 shot_v0418_linux_1280x800_ell_p97_zoom2.png
added e9497a535a3a296dc3d5acc3d804c88e505c8072e7387c119af9b169218e3567 shot_v0418_linux_1280x800_ell_p97_zoom4.png
added b45571826f54ca367730a3247ad82096ae6b5b1887f3ff17e82250b42ea037ec shot_v0418_linux_1280x800_ell_points_card_p97.png
added e531f84c43798373c6b1bc86a50f848ec073df749c9a1ab66a8b5f3cac8c0f14 shot_v0418_linux_1280x800_panels_groupE_closed.png
added 53c47779b14f274acaf8a6fc69c68f6b67588c36f2c9abf16436e7f8ac0a9cd9 shot_v0418_linux_1280x800_per_11a1_refused.png
added bca4831f4a7ab2ebbc6a6f2924f120f69281ff4a6e7f5b98020f9690cda979ed shot_v0418_linux_1280x800_sph_dodeca_r30_T1328.png
added 4b64d5cea8dd3b54c868cd4040de8a3b58af46908942c21907ff303acb8986a2 shot_v0418_linux_1280x800_sph_gbrun_1448.png
added 160306c121304f20f0ca39bc50a07f4874b93b9fb018511b136a58a9112d5533 shot_v0418_linux_1280x800_sph_r30_T1328.png
added ce5e9f6a09ac79fc491953b1bfca6ec026bbd9f3af19e6b9183744b1667dfc2d shot_v0418_linux_1280x800_sph_r30_T512.png
added 9ea4d7f43b8c724d9d0cf85b676b7b4916539dfd0768aa134e304586f6eadc2e shot_v0418_linux_375x812_curv_T0.png
added 1801b1ed118a50f1319038f4742c66e12c7396e8cf3d5c3d8679054c04cdf0d8 shot_v0418_linux_375x812_curv_gbrun_1448.png
added 3c90e424cc63cc34fe670c6cf5cb77a586d41effd9bfa32a2f9ff34b927e6aa0 shot_v0418_linux_375x812_curv_gbshell_1448.png
added 55b352d331ffae04fd830fb36e67fec5511991ce29aa05cd3c2b6812d4da8710 shot_v0418_linux_375x812_curv_gbshell_24.png
added f4c691a4ae3e0a44adcf8fda260b5118d5ffa59f81d06b06bcccddfc134ef97a shot_v0418_linux_375x812_curv_r150_T4096.png
added 46fac5102c009e3a0e6352d7df4116915785958e2c2c633beb8d2c8b18677ece shot_v0418_linux_375x812_curv_r30_T4096.png
added dbd5502dd039531c4c361bb7093bce1f6db0a7df923349903f5e26f794162387 shot_v0418_linux_375x812_curv_r30_T4096_absolute.png
added c3562b0eed2cf2709424f4ca80bb9925bb10d42ff2d6d193ed3ca973a8d57fa2 shot_v0418_linux_375x812_curv_r30_T512.png
added fad66066b4ca78d7ed59a82d8ee2ecf94ded76f16fb4c51ea3a11229e9e9f4a2 shot_v0418_linux_375x812_ell_cases_p5.png
added 6135620bf1545b50c7e4e8af3fdfb94ac119fc7dcbc8f0e777953d597a5dddfa shot_v0418_linux_375x812_ell_p5_P1eqP2.png
added a249da0a3e5327a39d72bb242891bc15c385f0881716f102ac23562b5291586c shot_v0418_linux_375x812_ell_p97_zoom1.png
added 9614173bcb9df21cd624e64ef99a72234a7ef73ea1accd6533410f8e7862a50b shot_v0418_linux_375x812_ell_p97_zoom2.png
added 6826c031fb1112570067ea0410485f9220d372f08602a4f2f6b46ccf3b434a76 shot_v0418_linux_375x812_ell_p97_zoom4.png
added 7dfc5d7b211c250b0b1349d31706eaa86980c135adc76e95fe6e1d476e255ec7 shot_v0418_linux_375x812_ell_points_card_p97.png
added f57ef9821d4f8a427b84e54de6bd7f2b16084c118d658c531e26852ae640493f shot_v0418_linux_375x812_panels_groupE_closed.png
added 9b36b1fde69544522fe07175e2853ce3c8b5035ec8118043664148643fac00ab shot_v0418_linux_375x812_per_11a1_refused.png
added 3ffbd997ee14aa7ae95a0f6aeb76e5d51e7d2639d5c4ab9de67a3b5308f099f6 shot_v0418_linux_375x812_sph_dodeca_r30_T1328.png
added 2479321fd9fce6ab8d7b1aafc2692e61ab8947eab075675b16664861b0ea5684 shot_v0418_linux_375x812_sph_gbrun_1448.png
added 9740d0eabb62fd1fcda5120edc699b7900f73fc09b007f685ea25e88b8a106f0 shot_v0418_linux_375x812_sph_r30_T1328.png
added 99db6df8d8d44489ab0173ed9252b03421b98069297d599f3f056a9d28a941bb shot_v0418_linux_375x812_sph_r30_T512.png
```

Outside the build folder (additive): `VIEWERS_LATEST/fourier_viewer_comb-hopf_v0_4_18.html` (byte-identical to dist), one card in `index.html`, one table row and one notes entry in `README.md`, one appended line in `SHA256SUMS.txt` with the README and index rows refreshed (see the summary for the hashes).
