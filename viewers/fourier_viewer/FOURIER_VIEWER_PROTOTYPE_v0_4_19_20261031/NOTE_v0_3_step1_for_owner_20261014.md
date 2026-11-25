# v0.3 step 1, continuous N (option B): note for the B1-viewer owner session

Claude Fable 5.1 (saphir's session), 2026-10-14. Answers HANDOFF.md §5. Unsealed; no git commits were made anywhere.

## What changed

- `nMode` dial (`integer` | `continuous`), default integer; in continuous mode φ₃ is an exact rational and N = B + 1 − φ₃ is rational. Exact: k_c, phases and orders, ALIGN/SPREAD flags, lift phases, windings, gcd reduction, knot types, closure periods. Switched off with the verbatim label "between shells: N = p/q; shell arithmetic undefined": Wilson (both), gearbox residency, divisors, shell contrast and bracket, Lift JSON integrality gates, fraction stack (idle with reason), order-m witness.
- Handoff §2 conditions: SPREAD refused 4e between shells ("SPREAD needs an integer gearbox: N = p/q"), ALIGN and PAIR work; R21 gate over Nq (closed and open cases tested); exact closure period kept when the drawing is partial; container C = 2·q·a·L_k for N = a/b (derived, tested, labelled convention; `host_ambient_equivalent` only for integer N with L_k = 1); ρ numerical with the bound now using |ln N| (conservative for N < 1, unchanged on shells).
- UI: one toggle N∈ℤ / N∈ℚ beside the φ₃ row; φ₃ box (continuous mode only, Enter applies, decimal or fraction); slider step 1/100 shell; shell marks on the track; ◀ ▶ snap to shells; Play ▶ N advances 1/100 per tick in continuous mode; rounding on switch back is announced; between-shells line on every tab's warning line.
- Schema: address/state/exact ids 0.2, lift 0.3, pair 0.2; a 0.1 address is upgraded (integer mode), 0.1 JSON files are refused. `SCHEMA_ADDENDUM_8.md` is the spec. README dial ledger and stepping section updated. `BUILD_REPORT.md` section "v0.3 step 1" has all 52 observation lines and the speed tables.
- Start point: the v0.2 tree as of 2026-10-14 including the Astra fix round (base-fixed orbits, even-kernel caption); the handoff's dist pin `3ea3e151…` predates that round. Pins of the source tree: `SOURCE_PINS_v0_2_tree_20261014.txt`. The v0.2 folder was not modified (checked after the build and after verification).

## Counts (builder, reproduced by me, reproduced by the verifier)

```
test-exact: 21 passed, 0 failed
test-core: 157 passed, 0 failed            (134 baseline PASS lines verbatim and in order + 23 new)
parity sample: 2000 states; UNEXPLAINED differences: 0   (output byte-identical to v0.2)
contrast-check: 93 pass, 0 fail
browser-check: 524 passed, 0 failed        (468 + 56 new; changed lines only 277, 315, 714 + appended block)
dist/comb-hopf.html  caf5ce9eaa46f0faf0942ec2476b720057327f0756a7237ec2dfbb41d79fd7f1
dist/MANIFEST.sha256 9bd0b578b9bf26cd69e0dc4c48623cf84cbe37cf91e19473dac7359f408eca8f
```

## Verifier (fresh Opus, closed file list): PASS_WITH_FLAGS

`../FOURIER_VIEWER_PROTOTYPE_v0_3_VERIFY_20261014/VERIFY.md` (inputs pinned in `INPUT_PINS.sha256`). 33 independent probes OK, 0 bad; integer mode unchanged; label verbatim everywhere; nothing claims continuous N recovers k.

Flags, with my disposition:
- **F1 owner decision.** 41 visible controls in continuous mode (cap 40); the φ₃ box is the extra one. My recommendation: move the box into a φ₃ drawer like the other dials.
- **F2 owner decision.** First screen at 375×812 between shells: Fourier transport ends at 882 px (70 over); Clifford and Hopf at 943 px (131 over, s row below the fold). Integer mode on those tabs: 855. Cause: the mandated label wraps to two lines, plus the SPREAD-refusal line. Options: shorter label, or accept one scroll between shells on a phone. The BUILD_REPORT gives only the Fourier number; correct it in the next round.
- **F3 closed by me** except the speed numbers: browser-check diff, older docs, parity identity all confirmed read-only against v0.2.
- **F4 builder fix next round.** `comb-numeric.js` line 118 comment still says `(1+ln N)`.
- **F5 builder fix next round.** README v0.3 sections do not state C = 2·q·a·L_k; comb-core comment lines 266–268 still describe the integer container.
- **F6 owner decision.** The page's `fv-build-pins` block uses `"schema":"fv-comb-hopf/0.2"`, the same id as the exact export.
- **F7 informational.** `test-core.cjs` line endings normalised to LF.

Builder readings to confirm: order-m witness and Divisors switched off between shells although neither depends on N; tie φ₃ = j + ½ rounds to j + 1; shell marks only when B + 1 ≤ 1000; state export carries `nMode` but not derived N.

F4 and F5 were left unfixed on purpose so that the verified pins stand; they belong in the same round as the F1/F2 decision.

## Not done

- `SCHEMA.md`, addenda 1–7 and `FUNCTIONALITY_LEDGER.md` untouched (byte-identical). No continuous-mode screenshot added.
- Push to `hypatiaa/fourier-viewer`: owner's, at saphir's word.

## Step 2: fix round after VERIFY (2026-10-14, saphir's decisions)

Decisions (saphir, "go with your leans"): F1 φ₃ box → drawer, and after the builder's honest stop, ⏮ moved into that drawer too (the chip is a button and counted, the old label was not); F2 short per-tab line "between shells: shell arithmetic undefined" (cards and exact export keep the full handoff wording), SPREAD refusal moved to the s-row stepper message and the s ⓘ, and after the second stop a phone margin trim (caption block 4→1 px, lines 2→1 px, at ≤ 480 px while a warning shows); F6 build-pins id `fv-comb-hopf-build/0.1`; F4, F5 documentation fixes. Brief: `BUILD_BRIEF_v0_3_step2_fixround_20261014.md`; addendum 8 §10 A1–A3; README amendments marked.

Results (builder, reproduced by me, reproduced by the delta verifier):

```
test-exact 21/0 · test-core 160/0 (134 v0.2 lines verbatim) · parity UNEXPLAINED 0 (byte-identical) · contrast 93/0 · browser-check 561/0
controls: 40 / 40 / 40 (integer / continuous / between shells)
first screen 375×812 between shells, N = 11/4, m = 2 and 5: 811 px on Fourier, Clifford, Hopf (asserted)
not asserted, stated in README: Clifford/Hopf with m ≥ 3 orbit warnings, 830 (integer m = 5), 870 (N = 43/2)
φ₃ slider at 375 px: 114–132 px (was 55)
dist/comb-hopf.html  88e43e38a91eb448a3cf5aafda09157eb080d5a5d731dbc0e2a2d4927b206cf2
dist/MANIFEST.sha256 bb315a6a5bfb90569a8fa54e4ff495bd67b6fbf70b1c1ab74509f31004220111
```

Delta verifier (fresh Opus, closed file list): **PASS_WITH_FLAGS**, `../FOURIER_VIEWER_PROTOTYPE_v0_3_VERIFY_20261014/round2/DELTA_VERIFY_R2.md`. Its flags:
- **R2-F1 (medium, owner decision, predates this round).** The first-screen and one-line results hold with the test machine's font (Consolas). Simulating a phone-width monospace (Courier New) the short line wraps; the transport then ends at 876 between shells and 840 already in the default state. Simulation, not a device measurement. Options: declare "measured with the test fonts", add a wide-font measurement to browser-check, or shorten the rows on phones. Device check requested from saphir (page sent to the phone).
- **R2-F2 (low, owner decision).** A PNG exported between shells shows no value of N (short caption, no N label in the drawing); pair JSON still carries it; addendum A1 does not list the PNG. My lean: print N in the PNG caption line of the export only (it has no width limit), next round.
- **R2-F3 (informational).** Cap holds at exactly 40; the tappable caption line (since v0.2) is not counted by the addendum-7 rule.
- **R2-F4 closed by me:** the bound comment has always been at comb-numeric line 4 in v0.2 and v0.3 (VERIFY step 1 cited "line 118", a slip); comb-numeric changed only at lines 4–5, 42–47, 112–126, 144 across both rounds (diff against v0.2); no stale "1+ln N" remains anywhere. Not closed: pre-round copies of browser-check, test-core, addendum 8, BUILD_REPORT do not exist, so "no other assertion changed" rests on the builder's listing plus the verifier's read of the code.
- **R2-F5 (informational).** The trim applies to every warning caption at phone width (hence integer Clifford/Hopf 835→830) and uses CSS `:has()`; older browsers do not trim (≈816).

Status: unsealed, no commits. Ready for the owner session's push at saphir's word, with R2-F1 and R2-F2 as the open decisions.
