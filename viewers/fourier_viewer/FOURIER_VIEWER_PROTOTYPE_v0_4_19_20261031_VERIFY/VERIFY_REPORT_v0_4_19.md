# VERIFY REPORT v0.4.19 (fix round on v0.4.18)

*2026-10-31. Independent verifier: Claude Opus 5.5 (subagent). I built none of this. I read the code and wrote my own checks first, and read the builder's report only after that.*

Inputs:
- Brief `BUILD_BRIEF_v0_4_19_FIX_ROUND.md`, sha256 114028d0…eef252b (checked).
- Build `dist/comb-hopf.html`, 08eb1f1d0bdde7de496cb1e6ed1b1fa5707f2bf9586b259d530a22362c41a3d2 (checked).
- `BUILD_REPORT_v0_4_19.md`, e7d16a0c…e1e3e8 (checked).

Compute:
- All mechanical work ran on membrane (Tailscale, `ssh membrane`).
- Node and Sage ran through `run_capped_v2.sh` as jobs VERIFY-0419-01 … 09, one at a time, with caps never raised.
- Browser work ran directly with the lock held through `flock -n`: one full `runall.sh` and my own probe.
- My membrane folder is `~/membrane_compute/viewer/verify_0419/`. It holds untouched uploads (`orig/`), a copy path-mapped by my own `vpathmap.cjs` (`root/`; other versions are read-only symlinks to the existing mirror), and my outputs.

## Overall verdict

**PASS WITH FLAGS.**
- Every exact check passed with my own code: Goldbach order, D1 pieces, pixelCert, A₅ by two routes, the arcs, the checker, the list's honesty and its reproduction on a second run, and VIEWERS_LATEST.
- The main flag is visual. For D1 at per_j ≥ 1024, the j = 30 pictures at q = 1 and q = 2 are one solid amber region. The q = 1 caption ("one full forward fibre loop" per event) is true of the drawn data, but it cannot be seen. The brief's fallback, a label on the card, was not added.
- The other flags are minor. See "Findings".

| # | Check | Verdict |
|---|---|---|
| 1 | Integrity (build sums, dist MANIFEST, VIEWERS_LATEST sums, v0.4.18 untouched) | PASS |
| 2 | No floats in new and changed computation | PASS (inherited float sites listed; notes) |
| 3.1 | Goldbach tooth order (own enumeration, N = 4 comb case included) | PASS |
| 3.2 | D1 event pieces (count, strict forward, end point) | PASS (code and data); **caption vs picture: FLAG** (see §5) |
| 3.3 | Expected-fails checker and list | PASS (one blind spot noted) |
| 3.4 | Pixel counts and P-doubling rule | PASS (one wording flag on the y axis) |
| 3.5 | A₅ (own Sage isomorphism on the build's moves) and the wording | PASS; Codex bus numbers INCONCLUSIVE (not in my file list) |
| 3.6 | Visual items (dials, ticks, tooth toggle, dodecahedron arcs) | PASS (own probe and screenshots; one cosmetic wrap) |
| 3.7 | Fixups test uses the real redLabel | PASS (a mutation test confirms it) |
| 3.8 | VIEWERS_LATEST labels, README, SHA256SUMS | PASS |
| 4 | Builder's new suites re-run; full v0.4.19 runall; expected-fails on my logs | PASS (51/0 on a second run) |
| 5 | D1 j = 30 screenshots vs caption | **FLAG**: the caption does not match what a viewer can see |

## 1. Integrity: PASS

| What | Result |
|---|---|
| Build `SHA256SUMS.txt` (`sha256sum -c`) | 771/771 OK |
| Build sums coverage | every file in the folder except the sums file is listed, and nothing listed is missing |
| `dist/MANIFEST.sha256` | 32/32 OK; includes the new `host-core/d1-event-pieces.js` 03faa610… |
| `VIEWERS_LATEST/SHA256SUMS.txt` | 46/46 OK |
| `fourier_viewer_comb-hopf_v0_4_19.html` | identical to dist (08eb1f1d…) |
| v0.4.18 own `SHA256SUMS.txt` | 586/586 OK (v0.4.18 untouched) |
| Uploaded copies on membrane | re-checked there against the build sums: v0.4.19 171/171, v0.4.18 155/155 (code files; logs and images excluded) |

Diff v0.4.18 → v0.4.19:
- Changed code: pen-curvature-core, pen-interval-core, pen-sphere-core, panel-pens, view-clifford, comb-hopf `index.html` (one script tag), `package.cjs`, `runall.sh`.
- New: `d1-event-pieces.js`, three new tests, seven new build scripts, `EXPECTED_FAILS_v0419.txt`, `SCHEMA_ADDENDUM_26.md`, the report and the membrane records.
- Not changed: `pen-streams-core.js`, `goldbach-core.js`, `rule30-ladder-core.js`, `panel-elliptic.js` and the fixtures (byte-identical to v0.4.18).
- Note: the copy's `build/_logs` holds the v0.4.19 run's logs. The old `SUMMARY_v0414…v0418.txt` files of the copied folder are absent, and the old `.run.log` files were overwritten by the new run. These are logs, not code, and the originals remain in v0.4.18.

## 2. No floats: PASS (with notes)

- I read every changed or new computation file: d1-event-pieces, pixelCert, the P_DOUBLINGS_MAX comment, dodecaArc/dodecaArcs, and the panel-pens diff (tickEvery, diskModel mul, the doubling loop, drawSphere arcs and toggle).
  - All arithmetic is BigInt or small integer Numbers.
  - Every "/" I found in the new lines is a BigInt division (strip, tickEvery, pixels).
- My own lexical scan (job 02, `float_scan.json`) strips strings and comments first.
  - It found no `Math.`, float literal, Float*Array, parseFloat, toFixed or performance.now in any new or changed file except view-clifford.js.
  - The one `Number(` is the allowlisted `px` helper.
- view-clifford.js: my added-line scan flags two **modified** lines.
  - One is the `const a=Math.SQRT1_2,…,sub=Math.max(1,Math.ceil(720/pj))` line, which v0.4.18 also had, minus `,n=c.points.length`.
  - The other is the samples line with `cvDot(…,2.6,…,0.8,…)`, which v0.4.18 also had.
  - The float tokens in both are inherited and unchanged. No new float computation was added; the new points go through the inherited `rlTurn`/`at`.
  - I record E1 of job 02 as "FAIL by my automatic rule, PASS on reading". The brief excludes this file from no-float-v0419.
- **Inherited float sites that remain**, as the builder lists them, and I agree:
  - view-clifford.js D1 projection: `rlTurn` (2π·num/den), `at` with `Math.SQRT1_2`/cos/sin, the numerical stereographic projection, Float64Array buffers, the 256-point rings, Math.max/ceil in `sub`, and `V.projectInto`.
  - The rest of the inherited Fourier/Clifford/Hopf views.
- The builder's no-float-v0419: 17/0 (job 06 and the full run).

## 3. Brief items, independent evidence

### 3.1 Goldbach order: PASS (job 02, `verify_0419.cjs` §A)

My route:
- Primality by trial division.
- My own comb: m = a_max + 1, or 3; t₂ = 2 for odd N/2.
- My own generator: walk |c| upward and emit +|c| then −|c|; odd m from 0, even m over odd |c|.
- My own mask.

| N | m | t₂ | g | δ | teeth | #+ = 2g − δ | order |
|---|---|---|---|---|---|---|---|
| 4 | 3 | 1 | 1 | 1 | 3 | 1 | 0, 1, −1 (signs +, −, −) |
| 6 | 3 | 2 | 1 | 1 | 3 | 1 | 0, 1, −1 |
| 24 | 8 | 1 | 3 | 0 | 8 | 6 | 1, −1, 3, −3, … |
| 100 | 48 | 1 | 6 | 0 | 48 | 12 | 1, −1, 3, −3, … |
| 1448 | 706 | 1 | 20 | 0 | 706 | 40 | 1, −1, 3, −3, … |

- **N = 4** is the comb exception (a_max = 0, so m = 3 is odd although N ≡ 0 mod 4). The build handles it, and the card sentence names it.
- Every even N from 4 to 1,448: the build's order and signs equal mine.
- At pair level, every prime pair p ≠ q sits at +c, then −c immediately after, both +; the equal pair sits at c = 0.
- Run to 1,448: 723 shells, 257,430 signs, boundaries and every sign equal to mine; #+ = 30,534 = 2·15,331 − 128.
- The stream code is unchanged (byte-identical).
- The card sentence states the order with "counted twice … the equal pair once", and both guards are still printed. I saw this in my probe and in the code.
- `SCHEMA_ADDENDUM_26` §1 records "decided by saphir, 2026-10-31".
- The builder's test-v0419-goldbach-order: 29/0.

### 3.2 D1 event pieces: PASS in code and data (job 02 §B; own probe)

My construction uses only the D1 core's per_j and ψ, with N built as my own cumulative sum of ψ:
- e = the smallest multiple of sub that is ≥ 32 at q = 1, or ≥ 16 otherwise.
- Point i of event step t: base (t·e + i)/(per·e), fibre (N·e + i)/(q·e).

The build's `FVD1Pieces.build` equals my construction **point for point** (BigInt cross-multiplication) for Rule 30 j ∈ {26, 30, 34, 3} × q ∈ {1, 2}. In every case:
- every event step has ≥ need pieces;
- fibre and base are strictly forward along every piece, through to the next step's first point;
- the fibre advances exactly 1/q per event step;
- base-step points equal the v0.4.18 curve's;
- the end point equals the v0.4.18 core's;
- the build's audit agrees.

| j | q | per | sub | e | event steps | pieces min | end (base \| fibre) |
|---|---|---|---|---|---|---|---|
| 26 | 1 | 1024 | 1 | 32 | 768 | 32 | 1/1 \| 768/1 |
| 26 | 2 | 1024 | 1 | 16 | 768 | 16 | 1/1 \| 384/1 |
| 30 | 1 | 4096 | 1 | 32 | 3070 | 32 | 1/1 \| 3070/1 |
| 30 | 2 | 4096 | 1 | 16 | 3070 | 16 | 1/1 \| 1535/1 |
| 34 | 1 | 4096 | 1 | 32 | 3043 | 32 | 1/1 \| 3043/1 |
| 34 | 2 | 4096 | 1 | 16 | 6086 | 16 | 2/1 \| 3043/1 |
| 3 | 1 | 2 | 360 | 360 | 1 | 360 | 1/1 \| 1/1 |
| 3 | 2 | 2 | 360 | 360 | 2 | 360 | 2/1 \| 1/1 |

- The same checks hold on a sweep of 420 curves: rules 30, 90 and 150, j = 0 … 34, q ∈ {1, 2, 4, 8}.
- The D1 core and fixtures are byte-identical to v0.4.18.
- In the browser, my own probe at both widths read the page's `r30-curve` attributes for j = 30 at q = 1 and 2, j = 34 at q = 2 and j = 26 at q = 1. Pieces min ≥ need, not-forward 0, and the end equals the core end.
- The builder's browser-check-d1-v0419: 173/0 in my full run.

### 3.3 Expected-fails checker and list: PASS

- **Code reading.** The checker compares, per listed suite:
  - the FAIL-line multiset;
  - the exit code from the run's summary file;
  - the SUMMARY line and its counts.

  It also fails on unlisted suites and on missing logs, and it is host-tagged: it exits 2 off membrane. Timings "N ms" are normalised to "<n> ms", as the builder discloses.
- **My injected logs** (job 07; `ef_inject.sh`, on my own full-run logs, checker unchanged):

| Case | Exit | Wanted | Caught by |
|---|---|---|---|
| real logs | 0 | 0 | — |
| one injected FAIL | 1 | 1 | UNEXPECTED |
| one expected FAIL removed | 1 | 1 | MISSING |
| crash replacing a log | 1 | 1 | MISSING + SUMMARY + COUNTS |
| **prints all its expected FAIL lines, then crashes** (test-v0410, exit unchanged at 1) | 1 | 1 | SUMMARY + COUNTS only |
| an exit-0 suite crashes after its PASS lines | 1 | 1 | EXIT + SUMMARY |
| exit code changed alone | 1 | 1 | EXIT |
| other host in the list | 2 | 2 | NOT THE HOST OF RECORD |
| blind-spot probe: all expected FAILs **and** the SUMMARY line, then a crash, with the same exit code | 0 | — | not caught |

  The last row is a known limitation (low; see Findings).
- **List honesty** (job 08, `list_honesty.cjs`; baseline logs of record copied from `membrane_run/baseline_v0418_linux/`):
  - The list has 51 suites: 86 `[baseline]` lines and 17 `[new card]` lines.
  - Every `[baseline]` line is in the same suite's v0.4.18 Linux baseline log, and no `[new card]` line is there.
  - Three baseline lines went away: test-v042, test-v0412 and test-v0413 provenance lines, each replaced by a `[new card]` line that also names the new file.
  - The new-card causes I checked in the logs:
    - browser-check-v0418's ten FAILs are its old regex for "pixels not certified" against the new two-count readout (item 4); the counts themselves are 0;
    - legacy-panels' two are the D1 attributes (item 2);
    - check-expected-fails-v0418's two are a cascade.
- **It holds on a second run.** In the builder's own run of record the in-run checker failed 47/4 against the builder's *pre-run* prediction; the list was rebuilt afterwards from the same logs. My independent full run on membrane (18:19:14Z – 18:55:33Z, exit 0):
  - the in-run `check-expected-fails-v0419` gave **51 passed, 0 failed**;
  - the FAIL multiset of every suite equals the list on my logs and on the builder's logs (job 08);
  - my SUMMARY_v0419.txt equals the builder's line for line except that one checker line (47/4 there, 51/0 here).

### 3.4 Pixel counts and P doubling: PASS (one wording flag)

- **pixelCert** (job 02 §C): 200,000 random enclosures on both axes, flipped and not. `wide` (4·(hi − lo)·R > 2^W) and `undecided` (floor(lo) ≠ floor(hi) of the drawn coordinate) equal my own definitions in every case.
- **Cards** (my probe, both widths):
  - disk, Rule 30, follow the pen: "enclosure wider than ¼ px: 0 of 2671", "pixel undecided: 55" at T = 512 and 48 at T = 4,096;
  - sphere, T = 1,328: 0 of 1,329 wide, 0 undecided;
  - dodecahedron: 0 of 10,625 wide, 0 undecided;
  - `data-uncertified` is kept, and `data-undecided` is new and equals the printed number.
- **Doubling.** The code (renderCurv loop) doubles P while the distance has fewer than 6 places **or** the wide count is > 0, up to `P_DOUBLINGS_MAX = 2`, and prints "P doubled k times". The core comment (pen-curvature-core lines 108–113) now says the same. With the threshold raised to an unreachable 50 places in my probe: doublings 2, cap flag 1, and the note "Precision cap reached" is shown. No real stream triggers a doubling (builder's statement; consistent with "P doubled 0 times" everywhere I looked).
- **Wording flag (y axis).** On the flipped axis the drawn pixel is `off − floor(mid)`, which for non-integer values is ceil(true coordinate), not floor.
  - In my random test, on 3,843 of 3,843 *decided* flipped cases the drawn integer differs by one from floor(true). The non-flipped axis gave 0 of 3,932.
  - The card's sentence ("undecided … so the drawn pixel, the floor of the midpoint, may be one off the true one") implies decided points are drawn at the true pixel. On the y axis that holds only up to this ceil/floor convention.
  - This is inherited from v0.4.18's `pixel()`, which is unchanged, and is at most one pixel. The brief's definition of m is implemented exactly.

### 3.5 A₅ and wording: PASS; Codex numbers INCONCLUSIVE

- **My Sage** (job 03, `verify_a5.sage`). Moves are dumped by my own BFS with the build's `dodecaStep` (job 02), not with the builder's dump script.
  - Route 1, permutations of the 60 flags:
    - order 60;
    - `is_isomorphic(AlternatingGroup(5))` True;
    - regular;
    - both moves of order 5;
    - element orders 1:1, 2:15, 3:20, 5:24.
  - Route 2, matrices transcribed from the DODECA constants over ℚ(√3, √5):
    - orthogonal, det 1;
    - BFS closure of 60;
    - the regular representation is isomorphic to A₅;
    - the build's move equals right multiplication by these matrices on all 60 dumped flags.
  - 20 unit vertices; all 30 edges at dot √5/3 exactly.
- **Arcs** (jobs 03–05): all 630 coordinate enclosures (30 edges × 7 points × 3) contain the true normalised point.
  - 620 are decided by 600-bit intervals.
  - The rest are the build's [0, 0] enclosures, decided exactly in K: 24 [0, 0] enclosures, all exact zeros, and no exact zero has a non-point enclosure.
  - Job 03 printed FAIL on its strict-containment line before the zeros were decided (an INCONCLUSIVE form, resolved in job 05).
- **Card note.** It says "isomorphic to A₅", cites VERIFY-0418-18 (9a77f4ca…; I checked that hash against the v0.4.18 verify receipts) and the build's VIEW-SAGE-0419-02 (46dd9ccc…; checked against `membrane_receipts`), and keeps the element orders.
- **Codex wording.** The Lean line reads "Codex-reviewed (PASS WITH FLAGS, #1310 / #1318)"; "both Codex-reviewed" is gone; the CREDIT line is consistent. **Whether #1310 / #1318 are the right bus numbers I could not check** (the rule30 ledger is outside my file list): INCONCLUSIVE. The builder also did not check them.

### 3.6 Visual items: PASS (own probe, own screenshots in `probe/`)

- **Sphere dials:** follow and W are visible, disabled, and each carries "(not used on this card)". Cosmetic: at 1280 the W note wraps onto its own line before "tooth events".
- **Ticks**, run to 1,448:
  - curvature strips (260 px): k = 80, 10 ticks drawn;
  - sphere strip (320 px): k = 73, 10 drawn;
  - my own smallest-k computation agrees;
  - the note "ticks every k shells" is printed.
- **Tooth events:** the toggle is on by default (339 events). Off draws 0 dots and still prints the count ("not drawn: toggle off"). The dots are now small, and the T = 1,328 web stays readable (screenshot).
- **Dodecahedron:** `data-edges="arcs"`, arcPoints = 7·1,328. The screenshot shows a clean dodecahedron with curved edges.

### 3.7 Fixups test: PASS

- The test runs the unchanged `panel-elliptic.js` in a vm context and calls its exported `FVEllipticCards.redLabel`/`redShort`. No export had to be added; the file is byte-identical to v0.4.18.
- Mutation (job 09): with redLabel broken back to "additive multiplicative" in a scratch copy, the unchanged test fails 7/3 (exit 1). The untouched copy passes 10/0.

### 3.8 VIEWERS_LATEST: PASS

- Only v0.4.19 carries "(latest)" among the comb-hopf cards.
- v0.4.18, v0.4.17, v0.4.16 and v0.4.14 carry "(superseded by v0.4.19)".
- Other viewers' labels are as before (curvature pen, sphere pen, divisor cancellation, Farey "latest" unchanged).
- The README has the new latest row and relabelled rows.
- `sha256sum -c` 46/46.

## 4. Suites on membrane

| Job | What | Result | RECEIPT.json sha256 |
|---|---|---|---|
| VERIFY-0419-01 | my verify script | exit 1, relative-path bug in my script (no checks ran) | ab7bf8bb97bdf34e72283ef80766321b5420b3a9b9e2e000b859c3628c2d192e |
| VERIFY-0419-02 | verify_0419.cjs (A–E) | 25 PASS, 1 automatic FAIL (E1 view-clifford inherited tokens; PASS on reading, §2) | 03c51a2a16bbefe8a8509ada9cc98bd43593d9befeb4684268be9fa3e93355b4 |
| VERIFY-0419-03 | verify_a5.sage | 11 PASS, arc line not certain (decided in 05) | 78643013a9a77ca62d4adeab5d8790b7e8f16e68f6a5c752b9a227d4d36cb242 |
| VERIFY-0419-04 | diag_arcs.sage | 10 undecided, 0 outside | aa0117ae3f85af82a0df8d953f0e2ba98b4e2cfcfd009bfbccf14326e173fdee |
| VERIFY-0419-05 | exact_zero_arcs.sage | PASS (24/24 exact zeros) | e13a29a002a819cac87cf78d1667af111b62c7d5518bdbc6fadf2cc8a85ed768 |
| VERIFY-0419-06 | builder's new node suites | goldbach-order 29/0, fixups 10/0, pens 15/0, no-float-v0419 17/0 | 9d791dbca0445eb31a6d0041bb03dc74a9ab7edb74e1e613454da8ae34145cb5 |
| VERIFY-0419-07 | injected-log checker test | all 9 cases as wanted | 99128f4b8d192e896accb07fec7cd63942bae16c056cc598042592d67ffa115c |
| VERIFY-0419-08 | list honesty | 3/0 | ecf783265630860712b62c91942a121cc887f9a16f43eb402d19cf9f2aa43a21 |
| VERIFY-0419-09 | fixups mutation | mutated run exit 1; clean run 10/0 | 1da7a45691ea283b9f74035666d3eb65301f1520f92ce2c2f9efd3019dc19373 |
| direct, lock held | full v0.4.19 `runall.sh` | exit 0, 52 suites; checker 51/0 | SUMMARY 106db398…cd63, checker log 99c1209f…895a |
| direct, lock held | own probe `vprobe-0419.cjs` (v2) | 26/0 | `probe/vprobe.log` |

Full-run totals:
- New suites: d1 173/0, v0419 66/0, goldbach-order 29/0, fixups 10/0, pens 15/0, no-float-v0419 17/0.
- Every old suite has the same counts as the builder's run of record. Verbatim summary: `full_run_logs/SUMMARY_v0419.txt`.

## 5. D1 j = 30 screenshots versus the caption: FLAG

My screenshots (`probe/v_1280x800_d1_r30_j30_q1_page.png`, `…_q2_page.png`, and the 375 px stage shots) show the leaf as **one solid filled amber oval** at both q = 1 and q = 2. The two are indistinguishable from each other, and no single loop, step or direction can be seen.

The q = 1 caption reads: "fibre constant (q = 1): … the declared lift still draws each event as one full forward fibre loop (2π/q = 2π)". In the data this is now true: 3,070 event steps × 32 pieces, each a full forward loop, verified exactly. But a viewer cannot see it: 3,070 loops cover the leaf. So the caption does not match what is visible.

The brief said: "If any row still can't, label it on the card instead." No label was added. The builder disclosed this as Open 1.

## Findings, ranked

1. **D1 legibility at per_j ≥ 1024 (item 2, last bullet not met).** The chord and zero-length defect is fixed, verified exactly. But at j = 30 (and j = 26 … 34) the q = 1 and q = 2 pictures are a solid amber region, so the caption's "full forward fibre loop" cannot be seen. The fallback label was not added. This is the owner's call for v0.4.20: a label or a step window.
2. **Expected-fails: first attempt failed in the run of record; the rebuilt list now reproduces.** The builder's in-run checker gave 47/4 on its own pre-run prediction, and the list was rebuilt afterwards on the same logs. My independent second run passes 51/0, and the FAIL multisets match exactly, so the rebuilt list holds. Disclosed: "N ms" normalisation.
3. **Checker blind spot (low).** A suite that prints all its expected FAIL lines **and** its SUMMARY line, then crashes with the expected exit code, passes. The four cases the brief required all give exit 1.
4. **Pixel wording on the y axis (low, inherited).** The drawn y pixel is ceil-convention: in 3,843 of 3,843 random decided flipped cases it is one off floor(true). The card implies that only undecided points can be one off. The brief's definition of m is met exactly.
5. **Codex bus numbers #1310 / #1318: INCONCLUSIVE.** They are not verifiable within my closed file list, and not checked by the builder either.
6. **Old checks failing by design.** browser-check-v0418 (10, old wording regex), legacy-panels (2, D1 attributes) and check-expected-fails-v0418 (2, cascade) are labelled `[new card]` and verified against the baseline. Their pixel assertions are carried by browser-check-v0419 and by my probe.
7. **view-clifford.js.** Two modified lines carry inherited float tokens (`Math.SQRT1_2`/`Math.ceil`; 2.6/0.8 dot sizes). They are unchanged in substance, and no new float computation was added. The D1 projection remains an open float site, as the builder states.
8. **Cosmetic.** The W "(not used on this card)" note wraps onto its own line. The copied folder's old `_logs` SUMMARY files were dropped and its old run logs overwritten (logs only).

## Process notes (mine, stated plainly)

- I hashed the build, dist MANIFEST, VIEWERS_LATEST and v0.4.18 sums with `sha256sum -c` on Neo. The membrane copies were re-checked on membrane.
- **Slip:** I once ran `python -I -B - < /dev/null` on Neo, a stdin form that the rules forbid. It contained no script, executed nothing, hung, and was stopped. No other Python ran.
- Job 01 failed on a path bug in my script; the rerun is job 02.
- My first browser probe (v1, `probe_v1_crashed/` on membrane) crashed on a screenshot of a re-rendering card. Its Node process stayed alive while holding no lock: the lock was free afterwards, and I killed the process. v2 retries the screenshots and ran 26/0.
- Job 08's receipt copied the node binary as an input. I removed it from my local copy only; its hash is in that job's MANIFEST.
- No git, no downloads. Nothing was written outside this folder and `~/membrane_compute/viewer/verify_0419/`.

## Files (this folder)

- Scripts: `verify_0419.cjs`, `verify_a5.sage`, `diag_arcs.sage`, `exact_zero_arcs.sage`, `list_honesty.cjs`, `ef_inject.sh`, `vprobe-0419.cjs`, `vpathmap.cjs`, `run_full.sh`, `job01.sh`, `job06.sh`, `job09.sh`, `prereg_01…09.txt`.
- Outputs: `d1_rows.json`, `float_scan.json`, `out06/` (logs of the builder's suites), `full_run_logs/` (my full run), `probe/` (probe log and 26 screenshots `v_*.png`), `receipts/VERIFY-0419-01 … 09`.
