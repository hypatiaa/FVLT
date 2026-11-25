# BUILD REPORT v0.4.8 (2026-10-20)
Builder: subagent (Claude Sonnet 5.5). Additive successor of v0.4.7 (dist 377db936...6a4d, SHA256SUMS_v2.txt f6d58ed2...a198 checked before and after, 0 lines not OK). Copy made without shot_*/export_* images, SHA256SUMS*.txt and MANIFEST_NOTE_v2.txt. Stopping is shared. Node only. panel-g-robin.js untouched.
## saphir's decisions (2026-10-20, "Yes, do both")
1. Panels row relabel "(teeth only; the tilted walk is not mirror-symmetric)" KEPT, recorded as adopted (README v0.4.8, SCHEMA_ADDENDUM_16).
2. Fourier one-line caption shortened at alpha_Tilt != 0.
Old: `★ pair phases conjugate (t₁·s ∈ ℤ); tilted walk not real in general`
New: `★ teeth conjugate (t₁·s ∈ ℤ); walk not real`
Full caption now e.g. "ALIGN yes · SPREAD no ★ teeth conjugate (t₁·s ∈ ℤ); walk not real · Q-res 6.1e+0 (numerical) · mirror axis = real axis (t₁·s ∈ ℤ)". The line stays tap-expandable (existing); Panels keeps the long wording. Hopf caption: no star or Q-res text, its tilt line is the separate orange line; unchanged. Orange α_Tilt line unchanged. No CSS/layout change.
## Files
Changed: instruments/comb-hopf/view-fourier.js (one string), README.md (title + v0.4.8 section), build/package.cjs (viewer string), dist/comb-hopf.html, dist/MANIFEST.sha256. New: SCHEMA_ADDENDUM_16.md, build/browser-check-v048.cjs, build/_logs/*, this report, 4 shot_v048_* images, SHA256SUMS.txt. Everything else byte-identical to v0.4.7.
## Checks (true counts, old tests unedited)
test-exact 21/0; test-core 159/1 (same failure as v0.4.7); contrast-check 93/0; test-mirror 14/0; test-v041 10/1; test-v042 5/1 (same expected); test-v044 11/0; test-v047 33/0. browser-check-mirror 122/0; v041 66/0; v042 46/0; v043 36/0; v044 222/0; v045 58/0; v046 16/0; browser-check (v0.3) 543/22 (same as v0.4.7).
**One change against v0.4.7:** browser-check-v047 58/2 (v0.4.7: 60/0). The 2 failures (one per viewport) are the old test asserting the literal old caption wording "★ pair phases conjugate ... tilted walk not real in general"; direct, intended consequence of decision 2; test not edited. All other 58 pass (incl. Panels at tilt 1 and tilt-0 identity against v0.4.6).
**browser-check-v048 19/0** (1280x800 and 375x812): new wording at tilts -1, -3/5, 1; at 1280 the "Q-res x (numerical)" part fully visible (measured with a DOM range against the line box) for all three; Hopf one-line captions carry no star/Q-res and are not cut; tilt 0 caption, about and stage byte-identical to v0.4.7 for 6 states at both sizes; Panels relabel present.
## Shots (looked at them)
shot_v048_{1280x800,375x812}_fourier_caption_tilt_{m1,p1}.png. At 1280 the line shows "...walk not real · Q-res 6.1e+0 (numerical)…" and only the trailing "mirror axis" suffix is ellipsised. At 375 the one-line caption is ellipsised early (as in v0.4.7; brief required Q-res only at 1280); tap expands it.
## Uncertain
- At 1280 the line is still ellipsised at its end (the mirror-axis suffix), by design: only Q-res was required visible.
- At 375 Q-res is not visible on the collapsed line (not required).
- Old browser suites regenerated old shot_*/export_* PNGs; deleted after all runs, before SHA256SUMS.txt.
