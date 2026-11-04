# FF-3 data definition repair: decision v0.1 (bus #1516)

2026-11-04. Skeleton (Claude Opus 5.5), on saphir's "Yes, decide it". Under `FF3_FREEZE_DECISION_v0_1.md` (`9e7d01b9...`, #1511), a definition change returns for review; this is that review.

**Decision: ACCEPTED as an additive successor.** `FF3_DEFINITIONS_PROPOSED_v0_2.lean.txt` (`02814fa15dfdafc3551d63943baedf57655f6b671c618895ca8dd8f490809388`) is accepted. The original `3c606060...` stays preserved and pinned.

## What was checked

- **The diff against `3c606060...`** shows exactly two changed lines:
  - line 47, in `fareySet`: `fun m =>` becomes `fun (m : ℕ) =>`;
  - line 51, in `shellEvents`: the same change.

  Every other line is byte-identical.
- **The compile log `1a8036ea...`** confirms the cause. The binder was inferred as `m : ℚ`, while the image is taken over `Finset ℕ` (`Finset.range (q + 1)` filtered by `Nat.Coprime`, and `Finset.range N`), which gave two type-mismatch errors.
- **Launch timing.** The failed run `Batch01Data01` started at 1793779214.4, after #1515 was posted (1793779160).

## Meaning

The annotation states the type both definitions already meant: m ranges over the natural numbers of `Finset.range`, and is then cast to ℚ inside the body.
- `fareySet B` is still the set of m/q with 1 ≤ q ≤ B, 0 ≤ m ≤ q and gcd(m, q) = 1.
- `shellEvents B` is still the set of (N, mN/(N−1)) with 2 ≤ N ≤ B+1 and 0 ≤ m < N.

My scripted check `SKELETON_FF3_SIGNATURE_CHECK_v0_1.cjs` (`1ffdefb7...`) already mirrored both definitions with natural-number m, so its 928,003 checks with 0 failures apply to the repaired text unchanged. No statement, guard or scope changes.

## Comparison and binding rule from now on

- **Data source.** The `FVLTRosetteFordDataV1` source must equal the `FVLT.PhasorFordV1` data text of `02814fa1...` byte for byte, with import boilerplate pinned per job.
- **Comparison receipts** must name:
  - the packet manifest `6c9d2f76...`, kept as the runner's `freeze_sha256`, which the runner asserts against the template;
  - the successor `02814fa1...`;
  - this decision's hash.

  They must also set `data_definitions_exact: true` against the successor.
- **No template or runner change is needed:** the v22 successor stays as runner `643fef34...` and template `79bb00ed...`.
- **Unchanged:** the 37 headers `b8a052dc...`, the target index, the checker `9c6f2ac1...` and all limits.
- **Binding and clock.** The #1511 rules apply: all-match binding on posting, jobs posted before launch, and proof-only retries. Batch 1 keeps origin 1793778950 and deadline 1793780750 with no reset. After that, a fresh posted binding is required.
- **Anything beyond these two annotations** returns for review.
