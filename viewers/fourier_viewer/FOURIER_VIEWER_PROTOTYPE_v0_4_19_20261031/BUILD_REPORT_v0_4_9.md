# BUILD REPORT v0.4.9 (2026-10-20)
Builder: subagent (Claude Opus 5.5). Additive successor of v0.4.8 (dist 0a370288...b8ec, SHA256SUMS.txt c7025ce7...a57f8ea, checked before and after: unchanged, 0 lines not OK). Copy made without shot_*/export_* images and SHA256SUMS.txt. Stopping is shared. Node only (Playwright from s6_atom/node_modules); no git, download, install or PowerShell in programs. panel-g-robin.js untouched. The frozen old instrument (monodromy-31-linked-reduction.html, sha256 b4cee4e3...e248) was only read and run read-only in a Node vm / Playwright page.

## saphir's request
"we have lost the ability to use alpha in the old Monodromy instrument. I want to see the full stack coordinates. can you put the coordinate system into the new viewer?" Port note first: `PORT_NOTE.md` (what the old full / fraction stack are, registers, dependence, placement, the α finding §7, the independent sources §8).

## Change
- New `host-core/stack-core.js` (fv-stack-core 0.1.0): the full stack on this viewer's exact core (comb-core resolve/offsets/phaseRep/teeth, comb-numeric stereo). Exact phase residues (N·t₁ + c·t₂)·s/N mod 2 by integer arithmetic; amplitude n₆·N^α and coordinates float64 as comb-numeric compute(). Host lattice and thinning rule (gridCap 58,081, m-independent through m = 30), host Clifford head selection (budget 12,000 − m).
- Views (Layers menu, default off): Fourier ✦/○ Full stack (canvas dots, signature-cached bitmap, frame fitted to the stack) and ⅟/○ Fraction stack (heads on |z| = |ρ|); Clifford ✦/○ Full stack (each point lifted on its own leaf ρ_N); Hopf ✦/○ Full stack (chart image) and ⅟/○ Fraction stack (current latitude). "Stack opacity 0.50" (cycles 0.50/0.30/0.15/0.06, the host's "▒ α 0.50" = state.stackAlpha, renamed so it is not confused with the amplitude exponent α), shown only while a full stack is on. Captions state the register, thinning, the N = 0 column, n₆ = 0, current N = 0; on a thinned Hopf stack the caption says indices are skipped and pixel resolution does not certify labels at large N (STACK_LABEL_RESOLUTION v0.11).
- View-string keys (written only when on / not default): fs, ff, cs, hs, hf, so. Address id unchanged; a v0.4.8 reader ignores them.
- Files changed: index.html (one script tag), panel.js (lazy stack model, fraction heads in the plane, PNG export includes the canvas when the Fourier stack is on), view-fourier.js, view-clifford.js, view-hopf.js, README.md (title, v0.4.9 section, dial ledger), build/package.cjs (viewer v0.4.9), dist/*. New: host-core/stack-core.js, PORT_NOTE.md, SCHEMA_ADDENDUM_17.md, build/test-v049.cjs, build/browser-check-v049.cjs, build/probe-old-lift-alpha.cjs, build/probe-old-page-alpha.cjs, build/_logs/*.run.log + SUMMARY_v049.txt, 14 shot_v049_* images, this report, SHA256SUMS.txt.

## Old-vs-new point comparison
- Plane: the old buildFullStack() (run from the frozen file in a vm) = stack-core for 39 states (n₁ 3/4/5 × α −1/0/1/1/2 × m 2/3/7, plus n₆ −1, n₆ 1/2 with t₁ 1/2, t₂ 2, α −1/3, and t₁ 3, t₂ −1, α 2): 747,238 points, same lattice and order, max |Δ|/max(1,|ρ_N|) = 1.8e-14.
- Exact: the stack's phase residues equal comb-core teeth() phases exactly (714 sampled points).
- Clifford: the old lift stack (PlaneCliffordLiftCore exact lane where it applies, ContinuousRadialDisplayV1 for continuous α / n₆ / rational gears) = the new lift, 39 states, same head selection, max relative |Δ| 9.4e-14.
- Browser: the page's stack = stack-core in Node within 1e-13 relative (Chromium and Node float64 cos/sin/pow differ in last bits; bitwise equality failed first, so the tolerance is stated) = old buildFullStack ≤ 1e-12, 7 states.
- saphir's reference state (n₁ 4, N 5 (φ₃ 20), α 1, n₆ 1, t₁ = t₂ = 1, m 2): at s = 0 and s = 1 the page draws 650 cells × 2 = 1,300 points, step 1 (no thinning), equal to the old buildFullStack (max |Δ| 3.6e-14); teeth 5 + 0i (s = 0) and −4.045084972 ± 2.938926261i (s = 1), as the old readout. By eye against images/33.png and 35.png: the same dot field (rows of dots symmetric about the real axis, the same arm pattern); the old frame shows only the inner part (radius ~12 of 25), the new frame is fitted to the whole stack (radius 25), so the new picture is a zoomed-out version of the same set.

## Checks (true counts; old tests unedited)
exact-lib/test-exact 21/0; test-core 159/1 (same failure as v0.4.8: fv-build-pins); contrast-check 93/0; test-mirror 14/0; test-v041 10/1; test-v042 5/1; test-v044 11/0; test-v047 33/0; **test-v049 25/0**. browser-check-v041 66/0; v042 46/0; v043 36/0; v044 222/0; v045 58/0; v046 16/0; v047 58/2 (same 2 as v0.4.8); v048 19/0; browser-check (v0.3) 543/22 (same failure names as v0.4.8); **browser-check-v049 52/0** (26 per viewport).
**One change against v0.4.8:** browser-check-mirror 120/2 (v0.4.8: 122/0). Both failures (one per viewport) are the old "v0.4 menu inventory" test, which lists the Fourier Layers menu literally and now also sees "○ Full stack", "○ Fraction stack". Expected consequence of adding the toggles to the Layers menu; test not edited.
browser-check-v049: counts 39/41/39/41 unchanged with the toggles off and on (all three views, both viewports); toggles off byte-identical to v0.4.8 for 20 states incl. tilt −1/2 (stage, canvas, caption, about, cards, address, hash, state) and PNG export identical (4/4); the stack follows exact α 3/7, −5/2, 8; address writes view=fs=1 only while on and off restores the v0.4.8 address; Stack opacity cycles and writes so=0.3; signature cache (two s steps redraw nothing, an α change redraws once); n₁ = 5, m = 3 rebuild + draw ~60 ms; degenerate labels (n₆ = 0, B = 5040 thinned, current N = 0, N = 0 column); α_Tilt does not change the stack; no horizontal scroll at 375; no page errors.
test-v049 also reproduces, on four fixed layers (s = 1, 2, 3, 7; c = +1; N = 1 … 121), the planar separation, the exact layer phase, the chordal identity of the host chart and the nearest-point bound L_N from STACK_LABEL_RESOLUTION v0.11 (numerical except the phase, which is exact).

## Shots (looked at them)
shot_v049_{1280x800,375x812}_{fourier,clifford}_fullstack_alpha_{1,1_2,m1}.png (n₁ 4, N 4, m 2, n₆ 1, t₁ = t₂ = 1, s 1) and shot_v049_1280x800_fourier_fullstack_N5_s{0,1}_alpha_1.png (saphir's reference state). Fourier α = 1: the full disc of arms to radius 25; α = 1/2: the same arms compressed to radius 5; α = −1: the stack collapses into the unit disc around the origin (radii 1/N), as it must. Clifford α = 1: the cloud gathers at the two points x = ±1 of the meridional page (ρ_N large); α = 1/2: two lobed clusters on the page; α = −1: the cloud runs along the axis through the tube (ρ_N small). Dots readable on the dark background at 1280 and 375 (opacity 0.50 default, 2.2-unit squares).

## α finding (PORT_NOTE §7, short)
The old data path keeps α (cache keys, specs and liftToS3 all use it; the old lift stack's norms change with α). The old page opened in S³ leaf-sweep mode, where every point is reprojected onto the display leaf with ρ_display = 1, keeping only arg z₁, arg z₂: the radius, the only carrier of α, is discarded by design, so α = −1/0/+1 look the same there. The new viewer has no such reprojection.

## Not ported, and why
- Travel marks / coverage rings and the meridional sweep's display copies: they need the meridional sweep (γ rotation of the stack page), which this viewer does not have.
- The old rosette (integer-s locus at fixed N), the dot-mini marker scale and branch chips on Fourier: not requested; Fourier has no branch filter (the Clifford stack honours its branch chips).
- Sacks labels, prime annotations, Landau material: deliberately not added; "label overlay from STACK_LABEL_RESOLUTION" is a possible later step for saphir.

## Uncertain / departures
- The Fourier frame is fitted to include the stack while it is on (the old Plane frame followed the current comb, so its stack ran off the frame); the current comb is then small and zoom (+) brings it back. saphir may prefer the old framing.
- The Clifford frame is not fitted to the stack (guide, leaf, current teeth only): far stack points (small ρ_N near the pole) can lie off the frame; they are counted in data-n, not separately in the caption.
- At current N = 0 or a refused state the stack is not drawn (labelled), though it is independent of the current N (the old Clifford showed "historical full-stack context").
- The Hopf comb chart divides every stack point by the current ρ, not its own ρ_N (labelled).
- Page vs Node stack values agree to 1e-13 relative, not bitwise.
- Which old code path set the leaf-sweep mode at load was observed, not traced (one candidate named in PORT_NOTE §7).
- The independent sources in PORT_NOTE §8 are another session's results, not externally reviewed.
- Old browser suites regenerated old shot_*/export_* images; all non-shot_v049 images were deleted after the last run, before SHA256SUMS.txt.
