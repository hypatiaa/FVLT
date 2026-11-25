# BUILD REPORT v0.4.4 (2026-10-20)

Builder: subagent (Claude Sonnet 5.5). Additive successor of v0.4.3 (`FOURIER_VIEWER_PROTOTYPE_v0_4_3_20261019`; its SHA256SUMS checked before and after: 0 lines not OK; folder untouched). saphir's decisions: CA presets as an alternate track (preset set B); the inequality information lives with G. Robin, not in the top bar; the previous FVLT viewer's G. Robin panel content goes into that card. Stopping is shared. No git, no download, no npm install, no Python, no PowerShell in programs.

## What changed
- Top bar (`panel.js`): third base button CA beside n! and integer; in CA mode a select of 2, 6, 12, 60, 120, 360, 2520, 5040, 55440, 720720 replaces the M box, and the n1 stepper is hidden. A choice dials `{shellMode: integer, B}`. UI overlay, not in the state or address. CA with a non-preset B sets 5040. The overlay ends when the state leaves the presets. Model field `ca` added. Nothing else in the top bar (no readout). Geometry from the browser check: the shell row is 40 px high at 1280 before and in CA mode (one row); 67 px at 375 before and in CA mode (two rows, as before): no extra row; no horizontal page scroll at either size; select width 99 px.
- Panels card `g-robin-margin` (new `panel-g-robin.js`, wired by one block in `view-panels.js`; the other 16 cards untouched, still "not yet rebuilt"): port of the frozen host panel RH_MARGIN_V0_1 (table below).
- New files: `host-core/rhm-core.js` (byte copy, sha256 2a483c04d35e6a41eafcfcedd717716e7299f2bd743ed084562b5ab92cd4fe62, from MCOMB_FCA_M7_COMBINED_BCD_RH_MARGIN_v0_1_20261001, MANIFEST 3f562965306039d56fedba77819076f3c47ba0be9488e7236330cabd4fbe2ef1), `host-core/ca-core.js` (preset list, caution text, cached readout used by the unit test), `instruments/comb-hopf/panel-g-robin.js`, `build/test-v044.cjs`, `build/browser-check-v044.cjs`, `SCHEMA_ADDENDUM_12.md`, this report, 8 `shot_v044_*.png`, `SHA256SUMS.txt`.
- Edited: `panel.js` (CA button/select/overlay, model.ca), `view-panels.js`, `index.html` (script tags rhm-core, ca-core, panel-g-robin; CSS), `build/package.cjs` (viewer string comb-hopf v0.4.4), `README.md` (title, v0.4.4 section, dial ledger). Ported faithfully rather than reinvented: rhm-core.js is byte-identical, so every exact output is the accepted core's.
- `diff -rq` against v0.4.3 (images excluded): differing files are package.cjs, dist/*, README.md, index.html, panel.js, view-panels.js; added files as listed. comb-core, orbit-core, shell-core, gearbox-core, comb-numeric, the views and exact-lib are identical.

## CA membership (exact)
From the definition (Alaoglu-Erdos): n is CA iff some eps > 0 has sigma(n)/n^(1+eps) >= sigma(k)/k^(1+eps) for all k. The function is multiplicative, so it is maximised prime by prime; with eps = u/v the comparison of g_p(a) = sigma(p^a)/p^(a(1+eps)) is an integer inequality. The finite argument (primes >= P must have exponent 0; exponents >= a0 are dominated by exponent 0) is written in `build/test-v044.cjs`. Witnesses: 2: 1/2, 6: 1/4, 12: 1/5, 60: 1/9, 120: 1/11, 360: 1/14, 2520: 1/15, 5040: 1/22, 55440: 1/28, 720720: 1/35. Controls: 4, 8, 24, 36, 720, 5039, 10080, 1441441 have no witness; the prime-by-prime maximiser at each witness is exactly a preset. Not claimed: that the list is complete up to 720720; the CA = superior highly composite coincidence (checked nowhere, printed nowhere). Not extended beyond 720720.

## Readout table (card at 128 bits; exact fraction from rhm-core, threshold numerical)
| B | sigma(B)/B | e^gamma ln ln B (numerical enclosure, 6 decimals outward) | margin Delta_R (numerical) | side / applicability | Robin |
|---|---|---|---|---|---|
| 2 | 3/2 | [-0.652787, -0.652786] | [2.152786, 2.152787] | ABOVE / OUT_OF_RANGE | fails |
| 6 | 2 | [1.038718, 1.038719] | [0.961281, 0.961282] | ABOVE / OUT_OF_RANGE | fails |
| 12 | 7/3 | [1.621194, 1.621195] | [0.712138, 0.712139] | ABOVE / OUT_OF_RANGE | fails |
| 60 | 14/5 | [2.510611, 2.510612] | [0.289388, 0.289389] | ABOVE / OUT_OF_RANGE | fails |
| 120 | 3 | [2.789171, 2.789172] | [0.210828, 0.210829] | ABOVE / OUT_OF_RANGE | fails |
| 360 | 13/4 | [3.157118, 3.157119] | [0.092881, 0.092882] | ABOVE / OUT_OF_RANGE | fails |
| 2520 | 26/7 | [3.665838, 3.665839] | [0.048447, 0.048448] | ABOVE / OUT_OF_RANGE | fails |
| 5040 | 403/105 | [3.816877, 3.816878] | [0.021217, 0.021218] | ABOVE / OUT_OF_RANGE (boundary note shown) | fails |
| 55440 | 1612/385 | [4.258323, 4.258324] | [-0.071311, -0.071310] | BELOW / IN_RANGE | holds |
| 720720 | 248/55 | [4.633995, 4.633996] | [-0.124905, -0.124904] | BELOW / IN_RANGE | holds |

Sign: margin = value minus threshold; negative means Robin's inequality holds. "fails" at 5040 and below is the numerical fact that the value is above the threshold; the criterion itself quantifies N > 5040 only, and the card says so beside the verdict. The card shows 24 decimals at 128 bits. Check at B = 24 against saphir's screenshots of the previous viewer: C1 5/2, C2 3, threshold [2.059398835087633225937464, 2.059398835087633225937465], margins [0.440601164912366774062535, ...536] and [0.940601164912366774062535, ...536], ABOVE/ABOVE, OUT_OF_RANGE / NOT_IN_FAMILY, primorial_k null, factors 2^3 x 3: all match (asserted in the browser check).

## Host panel elements: ported / adapted / omitted
| Element of RH_MARGIN_V0_1 | Status |
|---|---|
| Title "G. Robin (1984) and Nicolas (1983) margins of the host shell base B" | ported (the host's "candidate panel v0.1" suffix dropped) |
| Intro (record rh-criteria-readout 0.1.0, kind rh_atom_margins, certified outward enclosures, margin = value minus threshold, reads only) | ported, wording shortened, Delta_R named |
| precision_bits select (2,3,4,5,6,16,64,128 default,256) | ported (card-local variable) |
| export record (canonical JSON) button | adapted: downloads the canonical bytes; `source` names the card and pins the embedded rhm-core.js sha256 (a page cannot hash itself), not a whole-package identity as the host did; the host's refusal paths while computing or stale do not exist (no async) |
| Status line "record for B = ... built by the BigInt port" | ported |
| Scope sentence and rh_status NOT_EVIDENCE box | ported; Sol's caution added as a third line of the same box (not duplicated) |
| Atom box (B, factorization, mode, factorial_index, precision_bits) | ported; added "mode CA" when the overlay is on, and a "CA track: CA #k of the 10 presets" line |
| C1 G. Robin box (statement, value with approximation, threshold, margin, exact endpoints, side, what it asks, applicability, boundary note) | ported; one row added: Robin inequality holds/fails at this B (agrees with side), noting the criterion quantifies N > 5040 |
| C2 Nicolas box (same rows, primorial_k, k = 1 note) | ported |
| Per-prime factors table and exact product check | ported (table in a scroll container) |
| Constants box (gamma, e^gamma, ln B, ln ln B, Euler-Maclaurin n, m, remainder, working bits, method) | ported |
| Canonical bytes disclosure | ported |
| Credits line | ported verbatim; separate line "Port into the Fourier viewer v0.4.4: builder (Claude)." |
| Micro-button toggle | omitted: the Panels card (details) is the toggle; the record is built only while the card is open |
| Embedded Web Worker, epoch/stale-result rejection, 30 s budget, host-error and computing states | omitted: a panel module renders synchronously from the shared model; the build is deterministic and cached by input key. Measured in Node here: cold build 16 ms (B = 720720, 64 bits), 3 ms (128 bits). The accepted TIMING_CLARIFICATION says a worker is acceptable below 50 ms and that the final-package cold main-thread maximum there was 40.4 ms (individual measurements, no phone-runtime claim); I did not measure in a phone runtime |
| 250 ms poll and global click/change/keyup refresh | omitted: the card re-renders with the Panels tab on each model change |
| Keyboard isolation of arrow keys inside the panel | adapted: only the precision select stops keydown propagation |
| McombRhMarginDiagnosticsV1 test hooks | omitted (tests read the DOM and compare with rhm-core) |
| Layout | adapted: kv rows stack to one column below 481 px, C1 and C2 stack to one column at 375 (checked), text 13 px by the viewer's contrast rule (host used 11 to 12 px) |

Refusal path: a B with a prime factor above 10^6 shows the refusal and the record domain, export disabled (tested with 2000006).

## Checks (true counts)
- test-exact 21/0; test-core 159/1 (expected: "fv-build-pins block" hard-codes the 13-module list; rhm-core.js, ca-core.js and panel-g-robin.js are now inlined); contrast-check 93/0; test-mirror 14/0; test-v041 10/1 and test-v042 5/1 (the same expected failures reported for v0.4.3).
- browser-check-mirror 122/0; browser-check-v041 66/0; browser-check-v042 46/0; browser-check-v043 36/0. (browser-check-v041 failed 8 on an intermediate build in which the card used 11 px text; it passes after the 13 px fix.)
- browser-check (v0.3): **545 passed, 20 failed** (v0.4.3: 557/8). The 8 old failures are unchanged. 12 are new, all the visible-control cap: the CA button makes the instrument panel 41 visible controls over the old cap of 40 (addendum 7 F1): per viewport the fourier, clifford and hopf "visible controls ... <= 40" assertions, the two continuous-mode inventory assertions, and the "N mode switch" assertion that includes the cap. Not edited. Decision for saphir: the cap of 40 and a third base button do not both hold; drop a control elsewhere or raise the cap. The Panels placeholder-count assertions in the old suites did not change.
- **test-v044 11/0**: CA witnesses and controls; maximiser cross-check; exact sigma(B)/B equals hand values for all ten (and 19344/5040 = 403/105); threshold enclosure against a floating-point cross-check to 1e-9; margin signs; caution text; rhm-core byte hash; record side at 5040 and 55440; factorial coincidence at 2, 6, 120, 5040 (state differs only in shellMode, resolve identical; readouts differ in the gearbox group only).
- **browser-check-v044 214/0** at 1280x800 and 375x812: CA button and menu, no readout in the top bar, no scroll at 375; for each preset the card equals rhm-core.js outputs (c1/c2 values, margins, thresholds, sides, applicability, constants, canonical record bytes, factor check), caution visible, credits verbatim, C1/C2 side by side at 1280 and stacked at 375; n! mode n1 = 3, 5, 7, 10, 13 equal rhm-core in factorial mode; B = 24 anchor values; B = 1; a B with a prime above 10^6; precision 16; export download name; 16 placeholders remain; six non-CA states at both sizes byte-identical to v0.4.3 in address, stage SVG, cards, caption, shell readout and state.
- Screenshots for saphir: `shot_v044_{1280x800,375x812}_panels_robin_CA{5040,55440,720720}.png` (Panels tab, card open) and `shot_v044_*_topbar_CA5040.png` (top bar in CA mode). I viewed the 375 55440 and top bar shots; a first layout showed word-splitting in prose lines, fixed.

## Uncertain
- The CA overlay is UI-only: reloading from an address shows integer mode with B (still the preset), CA unpressed.
- Factorial CA presets are integer-mode states, so the factorial-only Wilson gate is inactive there (as for any integer base).
- The export identity is adapted (see table); an Astra look is advisable.

# Round 2 (2026-10-20): value-column collapse in the G. Robin card

Defect (seen in round 1's shot_v044_1280x800_panels_robin_CA55440.png, reported by the track owner): in the C1, C2 and constants boxes the value column collapsed to about one character wide, laid out one glyph per line, with C2 values spilling out of the box. Cause: the key/value grid was `max-content minmax(0,1fr)` while round 1 also set `overflow-wrap:anywhere` on dt and dd; with anywhere-wrapping the 1fr column's minimum content became one character and the max-content key column took the width. Round 1 was kept unchanged at `dist_round1/comb-hopf.html` (sha256 cef0d141f40eb3e5713b7cb2aa64d059e1d637ad9a94570e0a4db1097cb22f6f).
Fix (`index.html` CSS only): `.rhm-kv` grid is now `minmax(6rem,34%) minmax(0,1fr)`; dt uses `overflow-wrap:break-word`, dd keeps `anywhere`; below 481 px the grid is still one column. No JS, state or exact-output change.
New check (browser-check-v044, 8 assertions): at 1280x800 and 375x812, for B = 24, 5040, 55440, 720720, every dd in C1, C2 and constants (7 + 7 + 9 cells, depending on B) lies inside its card, is at least 40% of the card's inner width or on its own row below its key, has no single-character line (character rects grouped by line) and no glyph outside the card, the card does not scroll horizontally, and the page has no horizontal scroll. Negative control: the same width test run on dist_round1 flags 7 of 7 C1 cells as narrow.
Counts after round 2: test-exact 21/0; test-core 159/1; contrast-check 93/0; test-mirror 14/0; test-v041 10/1; test-v042 5/1 (same expected failures as round 1); test-v044 11/0; browser-check-v044 222/0 (was 214, plus the 8 layout assertions); browser-check-mirror 122/0; v041 66/0; v042 46/0; v043 36/0; browser-check (v0.3) 545/20 (identical to round 1: the same 8 old failures and the 12 control-cap failures).
Shots retaken (all 8 round-1 names), plus new at both sizes: `shot_v044_<size>_panels_robin_CA55440_c1c2.png`, `_factors.png`, `_constants.png` (6 files). I looked at the 1280 and 375 c1c2 shots and the 1280 constants shot: value column wraps at a reasonable width, nothing outside its box.
Open decisions untouched: control cap 40, export source identity, worker omission, CA overlay on reload.
