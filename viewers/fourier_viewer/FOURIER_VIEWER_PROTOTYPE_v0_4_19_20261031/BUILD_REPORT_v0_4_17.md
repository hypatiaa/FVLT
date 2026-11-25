# BUILD REPORT v0.4.17 (2026-10-29): group D exact, the exact elliptic core and the period panel

Builder: subagent, Claude Opus 5.5. Brief: `FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029_BRIEF/BUILD_BRIEF_v0_4_17_EXACT_ELLIPTIC.md`. Go: saphir ("Just do your recommendation, an exact elliptic core first … Then the period panel with guaranteed digits"; **"No floating point"**). Placement: the track owner's lean (group D of the comb-hopf Panels tab, new cards marked "exact"; the legacy placeholders untouched).

- **Base v0.4.16**, whose independent verification is still open: **v0.4.17 inherits that open status.** New folder `FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029/`, a whole copy of `FOURIER_VIEWER_PROTOTYPE_v0_4_16_20261028/` (shots, SHA256SUMS.txt and build/_logs included). This build's runs overwrote the logs and shots whose names coincide; `SUMMARY_v0414.txt` and `SUMMARY_v0416.txt` are the copied files, unchanged; this run's summary is `build/_logs/SUMMARY_v0417.txt`.
- **Nothing in v0.4.16 or earlier was edited.** After the build, `sha256sum -c SHA256SUMS.txt` in the v0.4.16 folder passes for every file; its `dist/comb-hopf.html` is 1da7dc8f8cad8c31f22e302a92e763fdc95b71abf4d3dc559fcad33df88c1b71 and its SHA256SUMS.txt is d127a20f5cedd746dd2e2861cdfa81d3e5cc0b9f7ca4fc2425c1b30bc29ce4a5. VIEWERS_LATEST got additive rows only (below).
- No git, no network, no downloads, no Python (Node only).
- **Fixture source hash:** `SAGE_REFERENCE_37a1_20261029.txt` sha256 **599c68552af2521c0b762298875c922e4c03aef29ae7ad4573af614642ab6a72**, checked before transcription (by `build/transcribe-elliptic-fixture.cjs`, which refuses on a mismatch) and again by `test-elliptic-exact` on every run. The hash is recorded in `fixtures/elliptic-37a1-fixture.json` (`source.sha256`).

## What was built

### Part 1: exact elliptic core (finished and passing before Part 2 was started)
1. `host-core/elliptic-exact-core.js` (fv-elliptic-exact-core 0_1_0, global `FVEllipticExact`; no DOM). Fields: ℚ (BigInt rationals, reduced, den > 0) and F_p (BigInt residues in [0, p), inverses by the extended Euclidean algorithm). General Weierstrass [a1, a2, a3, a4, a6]; b2, b4, b6, b8, c4, c6, Δ. O is the flag `{inf: true}`. Negation −(x, y) = (x, −y − a1x − a3). `add` implements the five-case table and returns the result, the case label and a key; `caseOf` evaluates all five conditions and **throws unless exactly one holds**. `doublingLambda` refuses at 2-torsion. `mul` = left-to-right double-and-add with the label of every step (the first step is always O + P). Membership, reduction mod p (O when p divides a denominator), enc, exhaustive point lists, singular points, a_p route (i) (naive projective count, singular point included) and route (ii) (character sum on y′² = 4x³ + b2x² + 2b4x + b6, Legendre symbols by **Jacobi reciprocity**, no modular powering; odd p only; **p = 2 uses route (i) only**), reduction type from the tangent cone at the singular point (valid for every p, also 2 and 3), Sage's change of model (u, r, s, t), point orders and a cyclicity witness.
2. `fixtures/elliptic-37a1-fixture.json`, written by `build/transcribe-elliptic-fixture.cjs` (a parser: fixed patterns, fails on anything unrecognised). Exact integers and rationals as strings; the decimal values as **strings**. The Ω string in the source has 58 places only (the others 109 to 110); the fixture records the place counts.
3. `host-core/test-elliptic-exact.cjs`, wired into `build/runall.sh` after `test-rule30-ladder`.

### Part 2: period panel with guaranteed digits
4. `host-core/elliptic-period-core.js` (fv-elliptic-period-core 0_1_0, global `FVEllipticPeriod`). BigInt only; every real quantity is a dyadic interval [lo, hi]·2^−W with outward rounding, W = ⌈33220·D/10000⌉ + 48 guard bits (W = 215 at D = 50, 381 at D = 100). Roots of 4x³ + b2x² + 2b4x + b6: a Sturm sequence over ℚ isolates them, exact sign bisection refines them (exact rational roots come out as point intervals). Square roots by BigInt isqrt (floor for lo, ceiling for hi). AGM in interval arithmetic: a′ = [⌊(a.lo + b.lo)/2⌋, ⌈(a.hi + b.hi)/2⌉], b′ = [isqrt(a.lo·b.lo), ⌈√(a.hi·b.hi)⌉]. **AGM convergence bound used:** stop when a_n.hi − b_n.lo ≤ 16·2^−W; since b_n ≤ M ≤ a_n for every n, M ∈ [b_N.lo, a_N.hi] (7 steps at D = 50 and at D = 100 for 37a1). π by Machin, π = 16 atan(1/5) − 4 atan(1/239), each term floored, error below (terms + 1)·2^−W per series (alternating decreasing series; 80 + 24 terms at D = 100). ω1 = π/AGM(√(e1−e3), √(e1−e2)), ω2/i = π/AGM(√(e1−e3), √(e2−e3)), τ/i = (ω2/i)/ω1 as an interval quotient, Ω = 2ω1 with the reason shown (Δ > 0: E(ℝ) has two components). Digit strings print only the places on which round-half-up of lo and of hi agree (at most D), with the width `n·2^−W ≤ 10^−k`. **Δ < 0 is refused** with the visible label "Δ < 0: not implemented in the exact register" (no complex AGM was built); Δ = 0 is refused as singular.
5. `host-core/test-elliptic-period.cjs` and `build/no-float-elliptic.cjs`, both wired into `build/runall.sh`.

### Panels (UI)
6. `instruments/comb-hopf/panel-elliptic.js`: two cards registered in group D, after the five legacy D placeholders (unchanged). Both are `collapsed: true` and compute only when opened. Display only: their dials live in the module (`FVEllipticCards.S`), not in the host state, the address or the exports.
   - **Elliptic points (exact)** (`elliptic-points-exact`): curve preset 37a1 (the only one); dial k = 1 … 20 with kP as exact rationals and the double-and-add trace (operation, case, result); dial p over the 25 primes below 100 with the E(F_p) scatter on a p × p canvas grid (integer pixels) and O as a labelled diamond outside the grid; P1 / P2 selects over E_ns(F_p), with P1 + P2 and the active row of the five-case table highlighted; the enc collision count; the a_p table (p, #E, a_p (i), a_p (ii), agree, reduction). At p = 37 the singular point (5, 18) is drawn in red and labelled "nonsplit mult.", a warning line names the reduction type, and the row of 37 is shaded and labelled.
   - **Period lattice (exact intervals)** (`period-lattice-exact`): curve select (37a1; 11a1 to show the Δ < 0 refusal), dial D = 10 … 100, the guaranteed digits and widths of e1, e2, e3, ω1, ω2/i, τ/i and Ω, the Ω = 2ω1 reason, both AGM step tables, the π method, and the rectangular fundamental cell (integer pixels from BigInt division of the lower endpoints) labelled ω1 and ω2, with its four neighbours dashed.
7. Smaller changes: `instruments/comb-hopf/index.html` (three script tags); `build/package.cjs` (version string `comb-hopf v0.4.17`); `build/runall.sh` (the new runs; summary file SUMMARY_v0417.txt); `instruments/comb-hopf/README.md` (v0.4.17 section with the "group D exact" dial ledger: preset, k, p, P1/P2, curve, D); `SCHEMA_ADDENDUM_24.md` (card state, dials, registers: the exact register is BigInt, interval enclosures are the numerical register with guarantees, canvas pixels are the drawing register).
8. `dist/comb-hopf.html` rebuilt with `build/package.cjs`; `dist/MANIFEST.sha256` and `SHA256SUMS.txt` regenerated (SHA256SUMS lists every file in the folder except itself, same format as v0.4.16).
9. `build/browser-check-v0417.cjs` and `build/shots-v0417.cjs`.
10. VIEWERS_LATEST: `fourier_viewer_comb-hopf_v0_4_17.html` added (byte-identical to dist, af217ccc…); one card in `index.html`, one table row and one notes entry in `README.md`, one line appended to `SHA256SUMS.txt`. Additive only: the v0.4.16 and v0.4.14 rows still say "latest" (see Open).

## The no-float rule

`no-float-elliptic` scans the full text (code, strings and comments) of the 8 new JS files and bans: the Math object (all of it, not only on non-integers), parseFloat, parseInt, toFixed / toPrecision / toExponential, Float32Array / Float64Array, performance.now, decimal literals, exponent literals, the Number namespace, and every `Number(...)` call outside an allowlist. Result: 8 of 8 clean.

**Explicit exceptions:**
- The one allowlisted `Number(...)`: the canvas pixel helper in `panel-elliptic.js`, line 9, `const px=b=>{if(typeof b!=='bigint')throw Error('px needs a BigInt');return Number(b);};`. It converts BigInt integers only.
- Integer-valued JS Numbers that are not arithmetic of the mathematics: loop counters and array / string indices; small integer canvas constants (line widths 1 and 2, dash [4, 4], marker sizes 6 and 24, `setTransform(1,0,0,1,0,0)`); DOM `selectedIndex`; integer milliseconds from `Date.now()` (timing display only); in the browser check, unary `+` on integer strings (option indices, pixel sizes read back from data attributes) and integer pixel-byte counts.
- Not decidable by a lexical scan, so checked by reading: `/` on Numbers. I read the new files for it; every `/` in a computation is a BigInt division. The scan does not prove this.
- `build/no-float-elliptic.cjs` is excluded from its own scan (it has to spell the banned tokens).
- The rule covers the new files. The existing viewer code (for example the Poincaré disk card and the tab drawings) still uses floats; none of it was touched.

## enc() injectivity finding

- **a1 = a3 = 0: injective (proved).** Over F_p the affine points over one x have y-values y and −y. For odd p and y ≠ 0, y and p − y have opposite parity (their sum p is odd), so 2x + (y mod 2) separates them; y = 0 is a single point. For p = 2, squaring is a bijection of F_2, so each x has at most one y. O is encoded as 2p, outside the affine range [0, 2p) (this code's convention). Checked exhaustively for y² = x³ − 16x + 16 and y² = x³ + x + 1, every p < 100.
- **37a1 (a3 = 1): not injective at any odd p (proved, and checked).** The partner of y is y′ = −y − 1 mod p; with canonical residues y + y′ = p − 1, which is even for odd p, so y ≡ y′ (mod 2) and every x carrying two points gives a collision. The collision count equals the number of such x for every odd p < 100 (p = 5: 3, p = 37: 18, p = 97: 46). At p = 2 enc is injective (y and y + 1 differ in parity). Recorded, not adopted: enc′ = 2x + ((2y + a1x + a3) mod p mod 2) is injective on 37a1 for every odd p < 100.

## Timing at D = 100

- Node, cold (cache cleared), `process.hrtime.bigint()`: **5 ms 375 µs** in the full run (5 to 8 ms over the runs I made).
- Browser (Chromium via Playwright), first computation at D = 100: 10 ms at 1280×800 and 6 ms at 375×812 (Date.now, integer ms); dial round trip 14 and 12 ms. D = 50 shows 0 ms because the card's first render had already cached it.
- Far below 2 s, so no worker was added; results are cached per (curve, D).

## Checks (one sequential run of `build/runall.sh`, 45 minutes, true counts)

**New suites, all passing:** test-elliptic-exact 43 / 0, test-elliptic-period 49 / 0, no-float-elliptic 8 / 0, browser-check-v0417 77 / 0.

**Old suites.** I compared every old log's FAIL lines with the v0.4.16 logs, line by line (programmatically). Unchanged: test-exact, test-core, contrast-check, test-mirror, test-v041, test-v042, test-v044, test-v047, test-v049, test-v0410, test-v0411, test-v0414, test-rule30-ladder, browser-check-mirror, browser-check-v041 … v049, browser-check-v0416, browser-check (same counts and the same FAIL lines as in v0.4.16). Changed:
- **test-v0412, test-v0413** (provenance): the existing single FAIL, which lists the source files that differ from v0.4.11 / v0.4.12, now also lists `elliptic-exact-core.js`, `elliptic-period-core.js` and `panel-elliptic.js`. Counts unchanged (11 / 1, 5 / 1).
- **New FAILs in five old browser checks**, all of one kind. These checks compare the Panels-tab HTML byte for byte with an older build (v0.4.9 … v0.4.13), and v0.4.10's also requires that no card after its own two is collapsed. The two new collapsed cards break that comparison:
  - browser-check-v0410: 104 / 0 → 100 / 4 ("byte-identical to v0.4.9 …, Panels tab … differs only by the two new collapsed card elements", and "both cards present in group B … all other cards unchanged (open)"), at both viewports;
  - browser-check-v0411: 82 / 0 → 80 / 2; browser-check-v0412: 78 / 0 → 76 / 2; browser-check-v0413: 74 / 0 → 72 / 2; browser-check-v0414: 96 / 0 → 94 / 2 (the "byte-identical to v0.4.x" line, at both viewports).
  I parsed every one of these FAIL lines: each lists only Panels-tab states and only the `hstage` field (no stage, canvas, caption, cards, address or export differs). browser-check-v0417 shows that the v0.4.17 page equals v0.4.16 on 6 states once the two new card elements are removed. So the brief's "all existing tests must pass unchanged" is **not met to the letter** for these five checks. I did not edit them. Any new Panels card breaks them; whether to accept that or to update the old checks is the owner's call (Open 1).

Disclosures: (a) I wrote both the checks and the cards; the independent verifier has not run. (b) browser-check-v0417 passed on its first run. The core tests failed twice while I was building them, and I fixed the cause each time: a missing case in root isolation (a root at the open end of an isolating interval, found by y² = x³ − x), and a test that tried to compare Ω at 100 places against a 58-place string (it now compares at 56 places and also checks Ω = 2ω1 against the ω1 string). (c) The cyan-ink test on the scatter shows only that points are drawn; the geometry is checked through the data attributes against the core.

## Test outputs (verbatim)

**Suite summary** (`build/_logs/SUMMARY_v0417.txt`):

```
test-exact exit=0 test-exact: 21 passed, 0 failed
test-core exit=1 test-core: 159 passed, 1 failed
contrast-check exit=0 contrast-check: 93 pass, 0 fail
test-mirror exit=0 test-mirror (T-MA): 14 passed, 0 failed
test-v041 exit=1 test-v041: 10 passed, 1 failed
test-v042 exit=1 test-v042: 5 passed, 1 failed
test-v044 exit=0 11 passed, 0 failed
test-v047 exit=0 test-v047 unit: 33 pass, 0 fail
test-v049 exit=0 v0.4.9 unit check: 25 pass / 0 fail
test-v0410 exit=1 SUMMARY test-v0410: 19 pass / 1 fail
test-v0411 exit=1 SUMMARY test-v0411: 15 pass, 1 fail
test-v0412 exit=1 SUMMARY test-v0412: 11 pass, 1 fail
test-v0413 exit=1 SUMMARY test-v0413: 5 pass, 1 fail
test-v0414 exit=0 SUMMARY test-v0414 22 passed, 0 failed
test-rule30-ladder exit=0 SUMMARY test-rule30-ladder: 55 passed, 0 failed
test-elliptic-exact exit=0 SUMMARY test-elliptic-exact: 43 passed, 0 failed
test-elliptic-period exit=0 SUMMARY test-elliptic-period: 49 passed, 0 failed
no-float-elliptic exit=0 SUMMARY no-float-elliptic: 8 passed, 0 failed
browser-check-mirror exit=1 browser-check-mirror: 120 passed, 2 failed
browser-check-v041 exit=0 browser-check-v041: 66 passed, 0 failed
browser-check-v042 exit=0 browser-check-v042: 46 passed, 0 failed
browser-check-v043 exit=0 browser-check-v043: 36 passed, 0 failed
browser-check-v044 exit=1 218 passed, 4 failed
browser-check-v045 exit=0 58 passed, 0 failed
browser-check-v046 exit=0 16 passed, 0 failed
browser-check-v047 exit=1 browser-check-v047: 58 passed, 2 failed
browser-check-v048 exit=0 v0.4.8 browser check: 19 pass / 0 fail
browser-check-v049 exit=0 v0.4.9 browser check: 52 pass / 0 fail
browser-check-v0410 exit=1 SUMMARY browser-check-v0410: 100 pass / 4 fail
browser-check-v0411 exit=1 SUMMARY browser-check-v0411: 80 pass, 2 fail
browser-check-v0412 exit=1 SUMMARY browser-check-v0412: 76 pass, 2 fail
browser-check-v0413 exit=1 SUMMARY browser-check-v0413: 72 pass, 2 fail
browser-check-v0414 exit=1 SUMMARY browser-check-v0414 94 passed, 2 failed
browser-check-v0416 exit=0 SUMMARY browser-check-v0416: 218 passed, 0 failed
browser-check-v0417 exit=0 SUMMARY browser-check-v0417: 77 passed, 0 failed
browser-check exit=1 browser-check: 542 passed, 23 failed
ALLDONE
```

**test-elliptic-exact** (`build/_logs/test-elliptic-exact.run.log`):

```
PASS fixture records the source sha256 599c6855…
PASS the source file is present and still matches its sha256 (read only)
PASS ainvs = (0, 0, 1, −1, 0) (37a1)
PASS invariants b2, b4, b6, b8, c4, c6 = fixture (0, -2, 1, -1, 48, -216)
PASS Δ = 37 = fixture discriminant, and 1728 Δ = c4³ − c6²
PASS P = (0, −1) lies on the curve; O is a flag, not a coordinate
PASS short model via (u, r, s, t) = (1/2, 0, 0, −1/2): [0, 0, 0, −16, 16] = fixture y² = x³ − 16x + 16
PASS short model discriminant = u^(−12) Δ = 4096·37
PASS kP for k = 1 … 10 = fixture (exact rationals)
PASS double-and-add labels: each step’s case equals this test’s own classification, and the sequence follows the bits of k (k = 1 … 20)
PASS kP labels k = 1 … 10 as recorded: 1: p1inf; 2: p1inf>doubling; 3: p1inf>doubling>generic; 4: p1inf>doubling>doubling; 5: p1inf>doubling>doubling>generic; 6: p1inf>doubling>generic>doubling; 7: p1inf>doubling>generic>doubling>generic; 8: p1inf>doubling>doubling>doubling; 9: p1inf>doubling>doubling>doubling>generic; 10: p1inf>doubling>doubling>generic>doubling
PASS kP by double-and-add = (k−1)P + P by the table, k = 1 … 20 (the chain step at k = 2 is the doubling case, the rest generic)
PASS every kP (k ≤ 20) lies on the curve
PASS map to the short model: x′ = 4x, y′ = 8y + 4, every kP (k ≤ 10) lands on y² = x³ − 16x + 16 and the map commutes with [k]
PASS −P = (0, 0) by −(x, y) = (x, −y − a1x − a3); P + (−P) = O, case “P2 = −P1”
PASS O + P = P (case “P1 = O”), P + O = P (case “P2 = O”), O + O = O (case “P1 = O”)
PASS [0]P = O and [−3]P = −(3P)
PASS exactly-one assertion: two off-curve points with x1 = x2 that are neither equal nor opposite are refused (no case applies)
PASS 2-torsion over F_5: T = (2, 2) has 2y + a1x + a3 = 0; T + T is the case “P2 = −P1” and gives O
PASS 2-torsion over F_5: the doubling formula refuses T (division by 2y + a1x + a3 = 0)
PASS 2-torsion over F_5: [2]T = O by double-and-add, labels P1 = O, P2 = −P1
PASS Jacobi symbol (by reciprocity) = Legendre symbol from the table of squares, every a mod p, odd p < 100
PASS a_p route (i) (naive projective count, singular point included) = fixture for all 25 p < 100
PASS a_p route (ii) (character sum, Jacobi reciprocity) = fixture for all 24 odd p < 100; p = 2 uses route (i) only
PASS routes (i) and (ii) agree for every odd p < 100, the bad prime 37 included
PASS #E(F_p) = p + 1 − a_p = fixture E.Np(p) for all 24 good p < 100
PASS at p = 37 the naive count 39 = p + 2 includes the singular point (E_ns(F_37) has p + 1 = 38 points)
PASS Hasse bound |a_p| ≤ 2√p (as a_p² ≤ 4p) for every good p < 100
PASS p = 37: reduction type nonsplit multiplicative (node, tangents conjugate over F_p2) (tangent cone at the singular point (5, 18)), matching a_37 = −1
PASS p = 37: independent route: 37 ∤ c4 = 48 (multiplicative) and −c6 = 216 is a non-square mod 37 (nonsplit)
PASS every other p < 100 has good reduction (p ∤ Δ = 37)
PASS order of P mod p divides #E(F_p) for every good p < 60
PASS E(F_p) cyclic for every good p < 60, by a point of full order (found by search), and #E(F_p) = fixture
PASS …which matches the fixture’s abelian invariants (n,) for 3 ≤ p < 60, p ≠ 37 (p = 2: #E = 5, cyclic, not in the fixture list)
PASS orders of P mod p, p < 60 good: 2:5|5 3:7|7 5:8|8 7:9|9 11:17|17 13:16|16 17:18|18 19:20|20 23:11|22 29:12|24 31:18|36 41:51|51 43:14|42 47:57|57 53:53|53 59:13|52
PASS reduction mod p is a homomorphism on kP, k = 1 … 10, every good p < 100; O exactly when p divides a denominator
PASS 5P = (1/4, −3/8) reduces to O mod 2; 7P = (−5/9, …) reduces to O mod 3
PASS enc(A) = 2x + (y mod 2) is injective on E(F_p) for a1 = a3 = 0: short model y² = x³ − 16x + 16 and y² = x³ + x + 1, every p < 100 (exhaustive)
PASS enc on 37a1 (a3 = 1): injective at p = 2 only; at every odd p < 100 the collisions are exactly the x with two points (y + y′ = p − 1 is even, so y ≡ y′ mod 2)
PASS enc collisions on 37a1 per p (collisions / x-values with two points): 2:0/2 3:3/3 5:3/3 7:4/4 11:8/8 13:7/7 17:8/8 19:9/9 23:10/10 29:11/11 31:17/17 37:18/18 41:25/25 43:20/20 47:28/28 53:26/26 59:25/25 61:34/34 67:28/28 71:31/31 73:37/37 79:37/37 83:49/49 89:42/42 97:46/46
PASS the y-pairing proof for 37a1, checked: for odd p and every affine point, the partner y′ = −y − 1 mod p satisfies y + y′ = p − 1
PASS not adopted, recorded only: enc′(A) = 2x + ((2y + a1x + a3) mod p mod 2) is injective on 37a1 for every odd p < 100
PASS curves over F_p keep residues canonical in [0, p) (all points of 37a1 mod 97)
SUMMARY test-elliptic-exact: 43 passed, 0 failed
```

**test-elliptic-period** (`build/_logs/test-elliptic-period.run.log`):

```
PASS cold period computation at D = 100 (W = 381 bits): 5 ms 375 µs (process.hrtime.bigint); under 2 s
PASS D = 50: W = 215 working bits; Δ = 37 > 0; not refused
PASS D = 50: e1 enclosure meets the Sage string ± 10^−105 and has width ≤ 10^−50 (width = 1·2^−215 ≤ 10^−64)
PASS D = 50: e1 guaranteed digits (50 places) = the Sage string rounded to the same places
PASS D = 50: e2 enclosure meets the Sage string ± 10^−105 and has width ≤ 10^−50 (width = 1·2^−215 ≤ 10^−64)
PASS D = 50: e2 guaranteed digits (50 places) = the Sage string rounded to the same places
PASS D = 50: e3 enclosure meets the Sage string ± 10^−105 and has width ≤ 10^−50 (width = 1·2^−215 ≤ 10^−64)
PASS D = 50: e3 guaranteed digits (50 places) = the Sage string rounded to the same places
PASS D = 50: w1 enclosure meets the Sage string ± 10^−105 and has width ≤ 10^−50 (width = 1524·2^−215 ≤ 10^−61)
PASS D = 50: w1 guaranteed digits (50 places) = the Sage string rounded to the same places
PASS D = 50: w2_over_i enclosure meets the Sage string ± 10^−105 and has width ≤ 10^−50 (width = 1246·2^−215 ≤ 10^−61)
PASS D = 50: w2_over_i guaranteed digits (50 places) = the Sage string rounded to the same places
PASS D = 50: Omega enclosure meets the Sage string ± 10^−58 and has width ≤ 10^−50 (width = 3048·2^−215 ≤ 10^−61)
PASS D = 50: Omega guaranteed digits (50 places) = the Sage string rounded to the same places
PASS D = 50: Omega = 2·w1 exactly as intervals, and 2·(w1 string) lies in the Omega enclosure ± 2·10^−105
PASS D = 50: tau/i = (w2/i)/w1 is consistent: tau/i · w1 meets w2/i (interval product)
PASS D = 50: roots ordered e1 > e2 > e3 with disjoint enclosures
PASS D = 50: Vieta on the enclosures of 4x³ − 4x + 1: e1+e2+e3 ∋ 0, e1e2+e1e3+e2e3 ∋ −1, e1e2e3 ∋ −1/4
PASS D = 50: AGM(√(e1−e3), √(e1−e2)) step table monotone over 7 rows: a_n.hi non-increasing, b_n.lo non-decreasing, b_n.lo ≤ a_n.hi; stop gap ≤ 16 ulps
PASS D = 50: AGM(√(e1−e3), √(e2−e3)) step table monotone over 7 rows: a_n.hi non-increasing, b_n.lo non-decreasing, b_n.lo ≤ a_n.hi; stop gap ≤ 16 ulps
PASS D = 100: W = 381 working bits; Δ = 37 > 0; not refused
PASS D = 100: e1 enclosure meets the Sage string ± 10^−105 and has width ≤ 10^−100 (width = 1·2^−381 ≤ 10^−114)
PASS D = 100: e1 guaranteed digits (100 places) = the Sage string rounded to the same places
PASS D = 100: e2 enclosure meets the Sage string ± 10^−105 and has width ≤ 10^−100 (width = 1·2^−381 ≤ 10^−114)
PASS D = 100: e2 guaranteed digits (100 places) = the Sage string rounded to the same places
PASS D = 100: e3 enclosure meets the Sage string ± 10^−105 and has width ≤ 10^−100 (width = 1·2^−381 ≤ 10^−114)
PASS D = 100: e3 guaranteed digits (100 places) = the Sage string rounded to the same places
PASS D = 100: w1 enclosure meets the Sage string ± 10^−105 and has width ≤ 10^−100 (width = 2681·2^−381 ≤ 10^−111)
PASS D = 100: w1 guaranteed digits (100 places) = the Sage string rounded to the same places
PASS D = 100: w2_over_i enclosure meets the Sage string ± 10^−105 and has width ≤ 10^−100 (width = 2195·2^−381 ≤ 10^−111)
PASS D = 100: w2_over_i guaranteed digits (100 places) = the Sage string rounded to the same places
PASS D = 100: Omega enclosure meets the Sage string ± 10^−58 and has width ≤ 10^−100 (width = 5362·2^−381 ≤ 10^−110)
PASS D = 100: Omega guaranteed digits (100 places) = the Sage string rounded to the same places (compared at 56 places: the Omega string has 58)
PASS D = 100: Omega = 2·w1 exactly as intervals, and 2·(w1 string) lies in the Omega enclosure ± 2·10^−105
PASS D = 100: tau/i = (w2/i)/w1 is consistent: tau/i · w1 meets w2/i (interval product)
PASS D = 100: roots ordered e1 > e2 > e3 with disjoint enclosures
PASS D = 100: Vieta on the enclosures of 4x³ − 4x + 1: e1+e2+e3 ∋ 0, e1e2+e1e3+e2e3 ∋ −1, e1e2e3 ∋ −1/4
PASS D = 100: AGM(√(e1−e3), √(e1−e2)) step table monotone over 8 rows: a_n.hi non-increasing, b_n.lo non-decreasing, b_n.lo ≤ a_n.hi; stop gap ≤ 16 ulps
PASS D = 100: AGM(√(e1−e3), √(e2−e3)) step table monotone over 8 rows: a_n.hi non-increasing, b_n.lo non-decreasing, b_n.lo ≤ a_n.hi; stop gap ≤ 16 ulps
PASS the AGM bound is reported in the record: stopped at n = 7 when a_n.hi − b_n.lo ≤ 16·2^−W; the true AGM M satisfies b_n ≤ M ≤ a_n for every n (b_n increasing, a_n decreasing), so M ∈ [b_n.lo, a_n.hi]
PASS π (Machin, 80 + 24 terms) meets an independent Euler-formula enclosure 4 atan(1/2) + 4 atan(1/3), width ≤ 10^−100
PASS π digits at D = 100, point removed, begin with the integer 314159265358979323846264338327950288419716939937510 (3 and the first 50 places, a well-known constant)
PASS every D = 10 … 100: all seven readouts print D guaranteed places and have width ≤ 10^−D
PASS D outside 10 … 100 or not an integer is refused
PASS Δ < 0 (11a1, Δ = -161051): refused with the label “Δ < 0: not implemented in the exact register”, no numbers
PASS Δ = 0 (y² = x³): refused (singular)
PASS y² = x³ − x: exact roots 1, 0, −1 found as point intervals; w1 and w2/i agree (square lattice, τ = i)
PASS isqrt and isqrtCeil are exact floor and ceiling square roots on 2000 test values
PASS no-float-elliptic scan passes on all 8 new files (8 clean)
SUMMARY test-elliptic-period: 49 passed, 0 failed
```

**no-float-elliptic** (`build/_logs/no-float-elliptic.run.log`):

```
PASS host-core/elliptic-exact-core.js: no banned token
PASS host-core/elliptic-period-core.js: no banned token
PASS instruments/comb-hopf/panel-elliptic.js: no banned token (allowlisted Number(...) at line 9)
PASS host-core/test-elliptic-exact.cjs: no banned token
PASS host-core/test-elliptic-period.cjs: no banned token
PASS build/transcribe-elliptic-fixture.cjs: no banned token
PASS build/browser-check-v0417.cjs: no banned token
PASS build/shots-v0417.cjs: no banned token
SUMMARY no-float-elliptic: 8 passed, 0 failed
```

## Browser-check output (verbatim)

**browser-check-v0417** (`build/_logs/browser-check-v0417.run.log`):

```
PASS v0.4.16 reference page present and unchanged (sha256 1da7dc8f…)
PASS 1280x800 identical to v0.4.16 on 6 states (stage, caption, cards, address, html stage); on the Panels tab the only difference is the two new card elements
PASS 1280x800 both cards in group D after the legacy D placeholders, adjacent, collapsed on a fresh page (21 cards)
PASS 1280x800 the legacy group-D placeholders mcomb-elliptic-bsd and clifford-elliptic-bridge are still present and still "not yet rebuilt"
PASS 1280x800 card titles carry the word "exact"
PASS 1280x800 opened cards render (points card and period card bodies present)
PASS 1280x800 k = 1: 1P = (0, −1) (exact, over ℚ), 1 steps with case labels p1inf
PASS 1280x800 k = 5: 5P = (1/4, −3/8) (exact, over ℚ), 4 steps with case labels p1inf>doubling>doubling>generic
PASS 1280x800 k = 10: 10P = (161/16, 2001/64) (exact, over ℚ), 5 steps with case labels p1inf>doubling>doubling>generic>doubling
PASS 1280x800 k = 10 matches the Sage fixture 10P = (161/16, 2001/64)
PASS 1280x800 p = 5: scatter of 8 points drawn (O as the marker outside the grid), P1/P2 lists 8 points of the group, no draw error, cyan ink present
PASS 1280x800 p = 5: good reduction, no singular mark, #E(F_5) = 8
PASS 1280x800 p = 5: no horizontal page scroll
PASS 1280x800 p = 37: scatter of 39 points drawn (O as the marker outside the grid), P1/P2 lists 38 points of the group, no draw error, cyan ink present
PASS 1280x800 p = 37 (bad): singular point (5, 18) drawn and labelled; reduction nonsplit multiplicative; warning line present; count line states 39 points in all, 38 nonsingular
PASS 1280x800 p = 37: no horizontal page scroll
PASS 1280x800 p = 97: scatter of 94 points drawn (O as the marker outside the grid), P1/P2 lists 94 points of the group, no draw error, cyan ink present
PASS 1280x800 p = 97: good reduction, no singular mark, #E(F_97) = 94
PASS 1280x800 p = 97: no horizontal page scroll
PASS 1280x800 p = 5, P1 = O, P2 = (0, 4): exactly one highlighted row, the case "P1 = O" (p1inf), sum (0, 4)
PASS 1280x800 p = 5, P1 = (0, 4), P2 = O: exactly one highlighted row, the case "P2 = O" (p2inf), sum (0, 4)
PASS 1280x800 p = 5, P1 = (2, 2), P2 = (2, 2): exactly one highlighted row, the case "P2 = −P1" (opposite), sum O
PASS 1280x800 p = 5, P1 = (0, 4), P2 = (1, 0): exactly one highlighted row, the case "generic" (generic), sum (0, 0)
PASS 1280x800 p = 5, P1 = (0, 4), P2 = (0, 4): exactly one highlighted row, the case "doubling" (doubling), sum (1, 4)
PASS 1280x800 a_p table: 25 rows equal to both core routes; agree = yes on 24 odd p, "route (i) only" at p = 2
PASS 1280x800 a_p table: p = 37 labelled nonsplit multiplicative, every other row good
PASS 1280x800 D = 10: the seven readouts equal the core digits and widths, each with 10 guaranteed places
PASS 1280x800 D = 10: AGM step tables have 6 and 5 rows; the cell is drawn (130 × 106 px); Ω reason shown
PASS 1280x800 D = 10: compute time shown (4 ms) and under 2000 ms; no horizontal scroll
PASS 1280x800 D = 50: the seven readouts equal the core digits and widths, each with 50 guaranteed places
PASS 1280x800 D = 50: AGM step tables have 7 and 7 rows; the cell is drawn (130 × 106 px); Ω reason shown
PASS 1280x800 D = 50: compute time shown (0 ms) and under 2000 ms; no horizontal scroll
PASS 1280x800 D = 100: the seven readouts equal the core digits and widths, each with 100 guaranteed places
PASS 1280x800 D = 100: AGM step tables have 8 and 8 rows; the cell is drawn (130 × 106 px); Ω reason shown
PASS 1280x800 D = 100: compute time shown (10 ms) and under 2000 ms; no horizontal scroll
PASS 1280x800 curve 11a1: the refusal label "Δ < 0: not implemented in the exact register" is visible and no readout is shown
PASS 1280x800 no horizontal page scroll with both cards open
PASS 1280x800 Collapse / Open panels: both cards reopen with their dials kept (k = 10, D = 100)
PASS 1280x800 no page errors and no console errors
PASS 375x812 identical to v0.4.16 on 6 states (stage, caption, cards, address, html stage); on the Panels tab the only difference is the two new card elements
PASS 375x812 both cards in group D after the legacy D placeholders, adjacent, collapsed on a fresh page (21 cards)
PASS 375x812 the legacy group-D placeholders mcomb-elliptic-bsd and clifford-elliptic-bridge are still present and still "not yet rebuilt"
PASS 375x812 card titles carry the word "exact"
PASS 375x812 opened cards render (points card and period card bodies present)
PASS 375x812 k = 1: 1P = (0, −1) (exact, over ℚ), 1 steps with case labels p1inf
PASS 375x812 k = 5: 5P = (1/4, −3/8) (exact, over ℚ), 4 steps with case labels p1inf>doubling>doubling>generic
PASS 375x812 k = 10: 10P = (161/16, 2001/64) (exact, over ℚ), 5 steps with case labels p1inf>doubling>doubling>generic>doubling
PASS 375x812 k = 10 matches the Sage fixture 10P = (161/16, 2001/64)
PASS 375x812 p = 5: scatter of 8 points drawn (O as the marker outside the grid), P1/P2 lists 8 points of the group, no draw error, cyan ink present
PASS 375x812 p = 5: good reduction, no singular mark, #E(F_5) = 8
PASS 375x812 p = 5: no horizontal page scroll
PASS 375x812 p = 37: scatter of 39 points drawn (O as the marker outside the grid), P1/P2 lists 38 points of the group, no draw error, cyan ink present
PASS 375x812 p = 37 (bad): singular point (5, 18) drawn and labelled; reduction nonsplit multiplicative; warning line present; count line states 39 points in all, 38 nonsingular
PASS 375x812 p = 37: no horizontal page scroll
PASS 375x812 p = 97: scatter of 94 points drawn (O as the marker outside the grid), P1/P2 lists 94 points of the group, no draw error, cyan ink present
PASS 375x812 p = 97: good reduction, no singular mark, #E(F_97) = 94
PASS 375x812 p = 97: no horizontal page scroll
PASS 375x812 p = 5, P1 = O, P2 = (0, 4): exactly one highlighted row, the case "P1 = O" (p1inf), sum (0, 4)
PASS 375x812 p = 5, P1 = (0, 4), P2 = O: exactly one highlighted row, the case "P2 = O" (p2inf), sum (0, 4)
PASS 375x812 p = 5, P1 = (2, 2), P2 = (2, 2): exactly one highlighted row, the case "P2 = −P1" (opposite), sum O
PASS 375x812 p = 5, P1 = (0, 4), P2 = (1, 0): exactly one highlighted row, the case "generic" (generic), sum (0, 0)
PASS 375x812 p = 5, P1 = (0, 4), P2 = (0, 4): exactly one highlighted row, the case "doubling" (doubling), sum (1, 4)
PASS 375x812 a_p table: 25 rows equal to both core routes; agree = yes on 24 odd p, "route (i) only" at p = 2
PASS 375x812 a_p table: p = 37 labelled nonsplit multiplicative, every other row good
PASS 375x812 D = 10: the seven readouts equal the core digits and widths, each with 10 guaranteed places
PASS 375x812 D = 10: AGM step tables have 6 and 5 rows; the cell is drawn (130 × 106 px); Ω reason shown
PASS 375x812 D = 10: compute time shown (2 ms) and under 2000 ms; no horizontal scroll
PASS 375x812 D = 50: the seven readouts equal the core digits and widths, each with 50 guaranteed places
PASS 375x812 D = 50: AGM step tables have 7 and 7 rows; the cell is drawn (130 × 106 px); Ω reason shown
PASS 375x812 D = 50: compute time shown (0 ms) and under 2000 ms; no horizontal scroll
PASS 375x812 D = 100: the seven readouts equal the core digits and widths, each with 100 guaranteed places
PASS 375x812 D = 100: AGM step tables have 8 and 8 rows; the cell is drawn (130 × 106 px); Ω reason shown
PASS 375x812 D = 100: compute time shown (6 ms) and under 2000 ms; no horizontal scroll
PASS 375x812 curve 11a1: the refusal label "Δ < 0: not implemented in the exact register" is visible and no readout is shown
PASS 375x812 no horizontal page scroll with both cards open
PASS 375x812 Collapse / Open panels: both cards reopen with their dials kept (k = 10, D = 100)
PASS 375x812 no page errors and no console errors
TIMING 1280x800 D = 10: page compute 4 ms, dial round trip 10 ms
TIMING 1280x800 D = 50: page compute 0 ms, dial round trip 5 ms
TIMING 1280x800 D = 100: page compute 10 ms, dial round trip 14 ms
TIMING 375x812 D = 10: page compute 2 ms, dial round trip 5 ms
TIMING 375x812 D = 50: page compute 0 ms, dial round trip 3 ms
TIMING 375x812 D = 100: page compute 6 ms, dial round trip 12 ms
SUMMARY browser-check-v0417: 77 passed, 0 failed
```

## Screenshots

Files: `shot_v0417_{1280x800,375x812}_{panels_groupD_closed, points_k1_p5, points_k5_p5, points_k10_p5, points_k10_p37_bad, points_k10_p97, period_D10, period_D50, period_D100, period_11a1_refused}.png` (card element shots; the groupD shot is a viewport shot).

I looked at: 1280 points k10 p37, 1280 period 11a1, 1280 groupD closed, 375 points k5 p5, 375 points k10 p97, 375 period D100, plus my own earlier probe shots of the points card (k5 p5) and the period card (D50) at 1280. I did not view the others individually.

What I saw:
- **Points card, p = 37 (1280):** the trace for k = 10 has five rows (O + P, doubling, doubling, generic, doubling) ending at (161/16, 2001/64). The 37 × 37 grid is legible, with 37 cyan points; the singular point (5, 18) is a larger red square with a red line down to the label "singular (5, 18): nonsplit mult." under the grid. The warning line above names the bad prime and the reduction type. O is a white diamond to the right of the grid. The doubling row of the case table is highlighted in green with a ▶.
- **Points card, p = 5 (375):** the grid has 7 large cyan squares; P1 and P2 (both (0, 4)) share one box and the sum (1, 4) has a green box. The a_p table scrolls horizontally inside its box; the page itself does not scroll sideways (checked). The case table's condition column wraps into a narrow column at 375 px; it is readable but tall.
- **Points card, p = 97 (375):** correct but faint: at 3 px per cell the points are about 2 px on a phone. This is the weakest picture (Open 3).
- **Period card, D = 100 (375):** the seven readouts wrap over three to four lines each, with the width line under each; the cell drawing is centred with its neighbours; the AGM tables scroll inside their boxes. D = 50 at 1280: one line per value. "computed in 0 ms (cached per D)" appears when a cached D is shown again.
- **Period card, 11a1:** the refusal label in amber and the explanation line, no numbers. The Δ there prints as "-161051" with an ASCII hyphen, unlike the "−" elsewhere (cosmetic).
- **Group D, cards closed (1280):** the shot shows the legacy D placeholders; the two new cards are further down, outside this viewport shot. The browser check confirms their position and collapsed state; the shot does not show it.

Nothing looked wrong to me beyond the faint p = 97 scatter, the tall case table at 375 and the ASCII hyphen. saphir's eye on the colours and the density is the one that counts.

## Open

1. **Five old browser checks now fail on the Panels tab** (v0410, v0411, v0412, v0413, v0414; 12 FAIL lines in all, listed above), because they compare the Panels-tab HTML with older builds and v0.4.10's expects no further collapsed cards. Only the `hstage` field of Panels states differs. Not fixed: the old checks were not edited. The owner decides whether to accept this or to update those checks in a successor.
2. **Group label.** The group D heading still reads "D. Elliptic and BSD (placement pending saphir)". The placement is now decided, but changing the label would change every old Panels comparison too, so I left it.
3. **Dense scatter.** At p = 97 the points are about 3 px (2 px on a phone). No zoom was added.
4. **Δ < 0** is refused (no complex AGM in exact interval arithmetic). Only 37a1 (computed) and 11a1 (refused) are offered.
5. **Ω reference.** The source's Ω string has 58 places, not about 110, so Ω is compared with it at its own precision (± 10^−58, and the digits at 56 places), and Ω = 2ω1 is checked against the ω1 string (± 2·10^−104). Ω at D = 100 is therefore checked through ω1, not directly.
6. **`/` on Numbers** is not checked mechanically (see the no-float section).
7. **Cyclicity** was checked by finding a point of full order by exhaustive search for every good p < 60 (p = 2 too, which the fixture does not list). That is a proof for these p, not a general statement.
8. **Exports.** The new cards are not in the JSON, state, CSV, Lift JSON or PNG exports, nor in the address (display only, by design).
9. **VIEWERS_LATEST.** The v0.4.16 and v0.4.14 rows still say "latest" next to the new v0.4.17 row (additive edits only).
10. **Independent verification** of v0.4.17, and of the inherited v0.4.16, is open.

## Files added or changed relative to the v0.4.16 copy (sha256). This report and SHA256SUMS.txt are not listed; SHA256SUMS.txt covers every file. The shot and log files were regenerated by the suite run (the old browser checks write their screenshots into the folder).

```
added 245c1ed26568d6bd0c98bd4a72e18eb86e24cafa47fe0e0ef763a2e25532a941 SCHEMA_ADDENDUM_24.md
added b3a569d4513042057cdaa099439b344d6b3206302516982763f3733947ef5d5e build/_logs/SUMMARY_v0417.txt
changed 2196f2c2e33d2d181dd25aeb123a3c2fa1433c5437c0a630fa1523b8a4c06af2 build/_logs/browser-check-v0410.run.log
changed 2cc6d890f609f970cb9ec6ddf9cef941704e6695d9558c887c97bad2d4f386a7 build/_logs/browser-check-v0411.run.log
changed 6eec2ffa8e218fb9b1c3709550248c5f6a5744f62805b86852732c3ee513f540 build/_logs/browser-check-v0412.run.log
changed 8460fbf065ffd889f26d5dfc586b144ec5c6105e07240c2904a6d51084b2a841 build/_logs/browser-check-v0413.run.log
changed a11f28fbf8d25801cfda35bd45179160570d9cf5bd3dee7a2eb716258035c7df build/_logs/browser-check-v0414.run.log
added bd97108584f9ec47b3648931aecdcd5f5c5f6bcae89e71c25ce8f408bf07c251 build/_logs/browser-check-v0417.run.log
changed 40497a098813acc3c77be12813ef9745f10db4391c8c72f70bed4cf3fec69fc4 build/_logs/browser-check-v049.run.log
changed 5c5115b9b9fe569ff004d1fbaa21c91d75e62ca726e5b2fbb331ceb258d53341 build/_logs/browser-check.run.log
added 9249bb009a37d9f6678f457cd82de719f07187e8e58e65f086aaf09770a37069 build/_logs/no-float-elliptic.run.log
added 876b389044a46b3f82c4263849f443fcf2b448ea7f9b701e5e3b2161a8e9bc8b build/_logs/test-elliptic-exact.run.log
added 384aec23f79d31377f7085d02b16d06a03049a31fe195fb41009ae5a54ea51a6 build/_logs/test-elliptic-period.run.log
changed e20c160724d4ff1997d3b50f0fef3c932b54ed3d0ef6991db32f82e5fe4ede73 build/_logs/test-v0412.run.log
changed f15d4eece594d3a5a563f36fa88802fb4aa1a06f6fc90e08c6b5337527df8498 build/_logs/test-v0413.run.log
changed d9a10f0cd902e206fd84fac80bffb6a895f1817587cc6f3f7d87484a76294ff5 build/_logs/test-v042.run.log
added ebcf6568d186e902c076ebb83c059a8268870c39d3f0f8b9bc267866f4bdb692 build/browser-check-v0417.cjs
added 8fc8b0b0d3f8598d815be3bb327532d68999722eafb47142a7bdcbd31c9c19c9 build/no-float-elliptic.cjs
changed 313303aefbbfa9832881be6fa6aef26e2aea025f6d76f3dff2e36f658cc3ff70 build/package.cjs
changed 8dd9015cec190f50c1619a1b39e6079d2d19983591ca84ea9ae351a2b55b23d6 build/runall.sh
added 5b7329233c3209f8a1254ecc1e689f25af2b5c883e6e3e859070fcaf0289951e build/shots-v0417.cjs
added ca838e9d16fed7ed175b246fb194a160bbaabf624c1522555605daa38262786d build/transcribe-elliptic-fixture.cjs
changed 5c8e51d3abac0eaea46fa0faebac2919e257306e0fab5f85e3cd6ef054812118 dist/MANIFEST.sha256
changed af217cccf42a0d9f18ca4a6f16b5e824052bc7215d460b6fe26a7a626b6f3181 dist/comb-hopf.html
added 12e80f6faec4caf308a8bc4a46a55aca71600a73506d178d0d1630c119bb0c4d fixtures/elliptic-37a1-fixture.json
added e187412c300d1dc0d26e6c5a455ca396103f9076caea28ae00d4f8ed0fe58a62 host-core/elliptic-exact-core.js
added 43c11437013fb736fa01138d954412e37b871fa6b6e48893c396e1a0d2dffed9 host-core/elliptic-period-core.js
added ea84da9a80673d50e2f00edcc3a4cda28775a4e2520561d99718bae5388b86f5 host-core/test-elliptic-exact.cjs
added 442648656f100a39701948544005cafba6890633dec5bae3ff85f214c39cb101 host-core/test-elliptic-period.cjs
changed 86a1e1cf214f3c15d092748cfd7a7c8d6f3d97b54fda2b8fd9f4ab4e5f6dec24 instruments/comb-hopf/README.md
changed 138198c41c97ee739fe3e76ecf7ec717148b8c2a9064e72d4b6d914233b1f8e5 instruments/comb-hopf/index.html
added 70b0324e76b61aca448e697a7e423abcfdef091c51f5d3e82a340c30d6da832b instruments/comb-hopf/panel-elliptic.js
changed f3e9e6c04836805828fb72b633f914fea63cc78955b3e0eacdb9f707dd2ec54a shot_1280x800_panels.png
changed 912320bafb65173439a04b26807156b72ca54774cf5e23fdfde4bcac69881ad4 shot_375x812_panels.png
changed afd5eb327284a21a9972c2254690ea6fcb38628fb278d4a1dd9c54f0b6deb5a6 shot_v02_panels_1280x800.png
changed 1918bf3ff1ce1d71de7b755c787bae625944e39c9af1728b271bac22aaa92778 shot_v02_panels_375x812.png
added c80dfc838bca6ec889bf96d7e32af9dbcc629583234e470fd460823d30b80402 shot_v0417_1280x800_panels_groupD_closed.png
added 2cae18925fda73cf1037b2cac6814f1a1f7de0282a35e1d8b342e5bb7fc5dbf3 shot_v0417_1280x800_period_11a1_refused.png
added e73da1ba98bd47bdc539c0df2de98e63f35e95228b677c63d17a3a32678b3620 shot_v0417_1280x800_period_D10.png
added 4d8f3aed3aa56be2d90090ea0fe251006ad31f64677625303eec9fdad5b20c8e shot_v0417_1280x800_period_D100.png
added 1b1f1837194e76eb0efdad3d14b10315579d34627ef39f18541b7b5340ac4c93 shot_v0417_1280x800_period_D50.png
added 2f7bc91e2b17fd3ee7ac9fb75028443c32477e60eaf76728f798553f6ecd7681 shot_v0417_1280x800_points_k10_p37_bad.png
added a1a3dc3035ab7a0cbe8dd7fc11975e881e5565206235853d8bd026d6d7330689 shot_v0417_1280x800_points_k10_p5.png
added 23cda5a0b2ad8078a4fba48142c0d31ba7f3eb39fb7841d59ecf409f488c0226 shot_v0417_1280x800_points_k10_p97.png
added 3f748c0bf79db8e69e3a519fd2c82681b0f0f5465a3bf8fd9d36f74b1f2d3b73 shot_v0417_1280x800_points_k1_p5.png
added 6fe18b463fba2b6a0907582c8d05379a07fae8263a3b28646dd2ce94f2ecb97e shot_v0417_1280x800_points_k5_p5.png
added cccabc7f1fc407b0cc8884dd90acc9c88f80a318b834b318998371370fd51e29 shot_v0417_375x812_panels_groupD_closed.png
added 9b1531b2caae1e97084793f9168a1eed71c6a1412f833074e4af3ba6000594e9 shot_v0417_375x812_period_11a1_refused.png
added 7916607b941c719ff62739ed55216d9b3a711ea3020303dfa5bb9311b2b6477c shot_v0417_375x812_period_D10.png
added f045acbe998a35d64a15f2bfcffc3b5c96530a60be93f12912164c0b1053bd8f shot_v0417_375x812_period_D100.png
added e9ec28dcc86adf93717a55b6d566b8de6de691f7d99d8bf817e6c4fe7dd8accf shot_v0417_375x812_period_D50.png
added 6fce9aa3595d0463f4160d33516dffa3f850545873f9d4de25ca51c272885a32 shot_v0417_375x812_points_k10_p37_bad.png
added 3b02e9b6c106086b6deffa338659d1ecb6837b629c4cd0647b36329d547df45b shot_v0417_375x812_points_k10_p5.png
added e45689b3f98f2aa688218c341b9685c9dcc741d0aa1febe5eb346b760ee771d4 shot_v0417_375x812_points_k10_p97.png
added 2b70710ef5c3bb7f8732c122e606881bc86b3ec2e7ea93dc9ff28ad11c1c5f07 shot_v0417_375x812_points_k1_p5.png
added 7ec23bd8a25109c0131e916abd842286be829e7224fb2fd48366389faac7ea58 shot_v0417_375x812_points_k5_p5.png
changed d44c10ff149d392f6a5cb5faab85e1a6ab911b9232c22df07904bac08839b289 shot_v044_1280x800_panels_robin_CA5040.png
changed 5b8eeede7dbc8e4f19c8f80e667fe2c4bb7fa79a6663f03a6cb71b84ad341085 shot_v044_1280x800_panels_robin_CA55440.png
changed edb4200150d0557c185e7c74263be70cd985d06cd1f6afd191c312016a001afa shot_v044_1280x800_panels_robin_CA55440_c1c2.png
changed 37530ade817d13cbcf8e99e1d50b79b593c337c710896c0b352d5f557e661df9 shot_v044_1280x800_panels_robin_CA55440_constants.png
changed 651fa3f3bab7a98ee3178e8c9695d65dd99dd4c896c7dfaa172889ddfe2d4898 shot_v044_1280x800_panels_robin_CA55440_factors.png
changed 2b5a1c68c53ee6b028c8f58c21dfd07599cc90a7a8c7603156817e3f82f8f7a8 shot_v044_1280x800_panels_robin_CA720720.png
changed e4d4e0000dcf034070f663e2526f4735a9b80de3229d0824b052fb0adc56a808 shot_v044_375x812_panels_robin_CA5040.png
changed b53ca855794c9cb402bef271848ad7bb32a79ad8764844648f2684bb7138650d shot_v044_375x812_panels_robin_CA55440.png
changed d26a87ef10dee81530d15b2c10e33c45a392cb9d3cd41f4cba83a1a621e776c7 shot_v044_375x812_panels_robin_CA55440_c1c2.png
changed 261b6a6987fe84175428a4699c2a2ee1c5d52f8a8335dbd93f497534c094d51c shot_v044_375x812_panels_robin_CA55440_factors.png
changed 9d63d63d5b92f9467e17067b9ba23ee176fbf8931b643fcfa75067855e818242 shot_v044_375x812_panels_robin_CA720720.png
changed 5c3f23b508f297d8e7c2f215ad8a59ce19d6572c658550c9381373b59fe66c71 shot_v045_1280x800_panels_CA5040_fresh.png
changed 459f3e94804409734cb3f7d44267bf6713c62838486b8aa88f1aa265de1dae2b shot_v045_1280x800_panels_CA55440_fresh.png
changed 46c9a97cb2a98cd09095d78803bcb05c33a0130781e8b0f7753804a7df612978 shot_v045_375x812_panels_CA5040_fresh.png
changed 6b6aeaa29f7768859f0020644a31083ecf524fa8e692bfc63d331ae2cbea1e6c shot_v045_375x812_panels_CA55440_fresh.png
```

VIEWERS_LATEST (outside the folder, additive):

```
af217cccf42a0d9f18ca4a6f16b5e824052bc7215d460b6fe26a7a626b6f3181 fourier_viewer_comb-hopf_v0_4_17.html
b69a9649fb7122f4e2d87d1303ecbeb4bea20a1b0379c16eb1576b0460f07340 index.html
d990bf2494fda0e1e99b9b668ba5df844b912fa7a7ee9ecdfadea25230ccfb6a README.md
2916160a35a97ac3dfa55cfd3d2f21d55dbc258aa790d4521863d9bece693613 SHA256SUMS.txt
```
