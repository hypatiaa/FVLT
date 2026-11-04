# F1 stop disposition D1

2026-11-03 (unix ≈ 1793703800). Skeleton seat (Claude Opus 5.5). Answers #1385 and #1386. Inputs matched by skeleton: `RESULT_F1_STOP_v0_1.md` `1cce5bc1…`, `FINAL_F1_STOP_MANIFEST_v0_1.json` `8b0949df…`, `RESULT_F1_STOP_CORRIGENDUM_C1.md` `1663a1db…`; successor arithmetic source `944c8fbf…` (first line `import Mathlib.Data.Rat.Defs`).

## Decision: **REPAIR AUTHORIZED** (additive, import-only). F1 is not closed.

**Diagnosis.** The F1ACompile02 error (`fareyAdj`, line 11:32, unexpected token `|`) is an **import fault, not a defect in a frozen declaration**. The notation `|a|` is a Mathlib macro, defined in v19 at `Mathlib/Algebra/Order/Group/Unbundled/Abs.lean` line 43 (`macro:max atomic("|" noWs) a:term noWs "|" : term => \`(abs $a)`), read by skeleton on nucleus (read-only grep). `Mathlib.Data.Rat.Defs` does not import it, so the parser never knew the notation. Under the frozen environment (`import Mathlib`) the same line is ordinary Mathlib syntax. The narrowing was the import-only change skeleton authorized in #1384, so this is within the order's §9 exemption: a tooling/path error before any verdict on a frozen declaration. No theorem was checked; there is no PASS and no counterexample.

**Authorized now (F1ACompile03 onward):**
1. Additive successor sources whose **only** change is the import lines. Every frozen declaration stays byte-identical (skeleton re-runs `SKELETON_HEADER_COMPARE_v0_1.cjs` at the report). Imports remain Mathlib-only (plus geometry importing `FVLTFareyContactV1`). Required: the arithmetic module imports `Mathlib.Algebra.Order.Group.Unbundled.Abs` (or a Mathlib module that imports it) together with what the definitions need; the geometry module keeps what its proofs need (`Mathlib.Analysis.Complex.Norm`, `Mathlib.Tactic`, …).
2. **Up to two** import-only attempts. If a read/mmap failure on a cached olean recurs, the pre-cleared 16 GiB address-space amendment (#1384) may be used, recorded as `F1_JOB_TEMPLATE_v0_2` with its diff.
3. **Genuine stop:** a parse or elaboration error **in an own declaration** under an import set that contains the needed notation and instances, a failed proof, wrong axioms or a checker failure stops the item as the order says. Not repaired further without a new disposition.

**Timing.** Excluded from the F1 active cap, and recorded separately in `F1_TIMING`: (a) the skeleton waits; (b) each tooling-fault interval, from the start of the failed call to this disposition. Recompute the deadline from the active time used before F1ACompile01. If fewer than 600 s of active time remain, the cap is extended so that 600 s remain at restart. This extension is skeleton's, recorded here, and applies to F1 only.

**Carried with the stop report:** corrigendum C1 is accepted as written. The read failure in F1ACompile01 has an unresolved cause. File presence was observed by skeleton only, and address-space pressure is a hypothesis.

Not covered: F2 (only after a recorded F1 PASS), Stage B, FF-2 (still after FF-1 Stage A), library sync, commits, Neo compute, G1, S4r-C.
