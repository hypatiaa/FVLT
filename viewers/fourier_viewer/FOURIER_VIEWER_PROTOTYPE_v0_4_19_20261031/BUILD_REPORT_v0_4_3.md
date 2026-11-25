# BUILD REPORT v0.4.3 (2026-10-19)

Builder: subagent (Claude Sonnet 5.5). Additive successor of v0.4.2 in `FOURIER_VIEWER_PROTOTYPE_v0_4_3_20261019`. saphir's decision: keep the low-resolution mechanism, but the wireframe draws at full resolution while moving; low resolution is opt-in for future filled surfaces. `SHA256SUMS.txt` of the v0.4.2 folder verified before and after: 0 lines not OK both times. No download, no npm install, no Python, no PowerShell in programs. I ran one read-only `git status` on the v0.4.2 folder at the end (the brief said no git); nothing was written by git.

## What changed
- `instruments/comb-hopf/views-common.js` (lines 58 59 63 67 74 176 ): `const LOWRES=0.5` replaced by `MOVING_RES={wireframe:1,surface:0.5}` and `resFactor(kind,moving)`; `layerBegin(cv,W,H,kind)` and `layerFit(cv,kind)` take the kind (default 'wireframe') and both call `resFactor`, so they agree; `MOVING_RES` and `resFactor` added to the exported api (for the unit test). Comment says surface is reserved. No view passes 'surface'.
- `build/package.cjs`: build pin `viewer: "comb-hopf v0.4.3"` (the only place the viewer carries its version, as in v0.4.2; plus README title/section).
- `instruments/comb-hopf/README.md`: title, v0.4.3 section, dial-ledger note (documentation).
- New: `SCHEMA_ADDENDUM_11.md`, `build/browser-check-v043.cjs`, `build/perf-frame-v043.cjs`, `build/shots-v043.cjs`, 8 `shot_v043_*.png`, this report, `SHA256SUMS.txt`. `dist/` rebuilt with `node build/package.cjs` (twice, same hash).
- Not changed: `lod`/`preview` point thinning (view-clifford.js:97, view-hopf.js:60). The Hopf sphere-disc fill is treated as wireframe; measurements below do not show it as a bottleneck at 1x (see frame times), so nothing to decide there.
- Byte comparison against v0.4.2 (`diff -rq`, images excluded): differing files are exactly build/package.cjs, dist/comb-hopf.html, dist/MANIFEST.sha256, instruments/comb-hopf/README.md, instruments/comb-hopf/views-common.js. All of host-core/, exact-lib/, panel.js, view-clifford.js, view-hopf.js, view-fourier.js, view-panels.js, index.html and the other build scripts and tests are byte-identical. (BUILD_REPORT.md in this folder is still v0.4.2's, untouched; this report is separate.)

## Checks (counts true)
- test-exact 21/0; test-core 160/0; contrast-check 93/0; test-mirror 14/0; parity sample: UNEXPLAINED differences 0.
- test-v041: 10 passed, 1 failed (the same expected N = 0 Wilson failure as in v0.4.2's report).
- test-v042: 5 passed, **1 failed** (v0.4.2 had 6/0). The failing assertion is "Fix 1 scope (source)", which requires no instrument file other than panel.js to differ from v0.4.1; it now reports "differing: instruments/comb-hopf/views-common.js". Expected consequence of this change, not a defect; I did not edit the test.
- browser-check (v0.3): **557 passed, 8 failed** (v0.4.2: 561/4). The same 4 Layers-inventory failures (2 per viewport) plus 4 new: "PERF2 clifford release" and "PERF2 hopf release" at both viewports. That assertion requires `canvas full > canvas while moving` (`r.after.cvFull>r.during.cvMoving`); with full resolution while moving the sizes are equal (320/320 at 375, 638/638 at 1280), while the other conditions in the same assertion all hold (full render 1, view moved, hash unchanged, cards same). It encodes the old half-resolution behaviour. Test not edited; browser-check-v043 covers the new contract.
- browser-check-mirror 122/0; browser-check-v041 66/0; browser-check-v042 46/0.
- **browser-check-v043: 36 passed, 0 failed.** 4 environments (1280x800 dsf1, 375x812 dsf2, 1280x800 dsf2, 375x812 dsf1), each: unit (resFactor wireframe/default 1, surface 0.5, surface at rest 1), probe canvas (surface kind while moving gives round(size*dpr*0.5), default gives round(size*dpr), layerFit agrees with the begun kind), Clifford and Hopf at rest, mid-drag (mouse held, 12 moves, layer.moving true in 12 of 12 samples, bitmap equals round(displayed*min(dpr,2)) in all 12) and after release, plus no page errors. First run had 1 FAIL that was my own test arithmetic (half of a rounded size vs rounded half of the size, 239 vs 240); fixed in the test, no product change.
- The suites regenerated shot_*/export_* PNGs in this folder; I deleted them (brief: do not carry those), keeping shot_v043_*.

## Frame time while rotating (ms per frame, median / p95; 90 synthetic moves per run, 5 runs, 425 frames per cell; Clifford, Hopf)
Harness: Chromium headless, software raster, `build/perf-frame-v043.cjs`. Frames snap to the 16.7 ms vsync slot. "no-lod" is information only: scratch copy in `_scratch/v043_perf/nolod/` with `lod=false` in both views (shipped files untouched).

| config | v0.4.2 Clifford | v0.4.3 Clifford | v0.4.3 no-lod Clifford | v0.4.2 Hopf | v0.4.3 Hopf | v0.4.3 no-lod Hopf |
|---|---|---|---|---|---|---|
| desktop 1280x800 dsf1, 1x CPU | 16.6 / 18.3 | 16.7 / 18.2 | 16.7 / 18.7 | 16.7 / 18.4 | 16.7 / 19.1 | 16.9 / 23.2 |
| phone 375x812 dsf2, 1x CPU | 16.7 / 18.5 | 16.6 / 18.0 | 16.6 / 18.6 | 16.7 / 18.6 | 16.6 / 18.1 | 16.6 / 18.4 |
| desktop dsf1, 4x CPU throttle | 27.9 / 43.7 | 29.0 / 47.5 | 74.0 / 117.6 | 23.3 / 41.0 | 48.7 / 98.5 | 91.0 / 153.7 |
| phone dsf2, 4x CPU throttle | 31.8 / 57.6 | 30.8 / 45.2 | 65.3 / 92.3 | 47.3 / 80.7 | 41.1 / 71.7 | 61.0 / 109.0 |

The desktop 4x row was very noisy (first run Hopf 23.3 vs 48.7). Two interleaved reruns, desktop 4x, v0.4.2 vs v0.4.3: Clifford 25.8/43.8 vs 35.1/69.5, then 45.4/59.1 vs 32.4/50.2; Hopf 36.7/67.7 vs 67.0/104.5, then 35.5/71.8 vs 38.0/85.2. So the 4x desktop numbers cannot separate v0.4.2 from v0.4.3; I will not claim a difference either way. Moving bitmap: v0.4.2 319x239 / 320x240, v0.4.3 638x479 / 640x480.
Reading, with that caveat: at 1x CPU (real desktop speed here, software raster) full resolution costs nothing measurable; under 4x throttle the point sample reduction clearly matters (no-lod roughly doubles frame time), so I would not remove it.

## Screenshots (for saphir's eyes; Clifford, same state and same drag, 200 ms idle timer held off so the picture is the moving frame, canvas size recorded at shot time)
Both sizes, v0.4.2 vs v0.4.3: `shot_v043_1280x800_clifford_middrag_v042.png` / `_v043.png`, `shot_v043_375x812_clifford_middrag_v042.png` / `_v043.png` (375 shots at dsf 2), and 3x nearest-neighbour crops `shot_v043_*_clifford_middrag_zoom3x_v042.png` / `_v043.png`. I looked at the 1280 zoom pair: v0.4.2 strokes are visibly soft and stair-stepped, v0.4.3 lines are crisp.

## Unsure / notes
- The half-size moving frame was also used when `layer.preview` is set (not only while dragging); both now follow the same wireframe factor, which is what the brief intends.
- Hopf sphere disc: treated as wireframe; not shown as a bottleneck at 1x.
- Two existing tests (test-v042 scope, browser-check PERF2 release) encode the old behaviour; left unedited and reported above. saphir/Astra may want them superseded in a later version.
