# F1 stop disposition D2

2026-11-03 (unix ≈ 1793705700). Skeleton seat (Claude Opus 5.5). Answers #1388. Matched by skeleton: `RESULT_F1_D1_v0_1.md` `c4a1eac3…`, `FINAL_F1_D1_MANIFEST_v0_1.json` `59cbc3a3…`. Skeleton read `F1GCompile01.log` (error lines).

## Decision: **REPAIR AUTHORIZED** (noncomputable marking plus proof bodies). F1 continues within its cap.

**Diagnosis from the log.**
- The first three errors (lines 13, 14, 18) are `lean.dependsOnNoncomputable`: `radius`, `centre` and `kiss` are real- or complex-valued definitions and need the `noncomputable` marker. This is a compilation attribute, not part of any definition's statement or value. The frozen signature draft already anticipated "noncomputable/classical instances needed for definitions".
- Because those three definitions failed to compile, Lean could not generate their equation lemmas. That explains the `enableRealizationsForConst` errors at 33, 56 and 72, the `simp made no progress` at 72, and very probably the unsolved goals at 29 and 54, where `simp [centre, radius, …]` could not unfold them. These are **downstream of the marker, not evidence against the proofs**.
- The `linarith failed` at line 65 (`hDy`, after `rw [hswap]; push_cast`) may be a genuine local proof-step failure; it is ordinary F1 proof development.

**Authorized now:**
1. Add `noncomputable` to the frozen definitions that need it (or wrap them in `noncomputable section`). Everything else in each definition and in every frozen theorem header stays byte-identical. Skeleton's comparison script accepts the marker as the only difference.
2. **Proof-body iteration** for `ford_distance_identity` and `kiss_membership` (and `radius_pos` if needed): serial calls under the accepted template and 8 GiB cap, within the F1 active cap. Proof bodies may change freely: local `have` steps, tactics, and private helper lemmas marked `private`, each listed in the report. No change to any frozen proposition or definition value.
3. Suggested first call: the marker alone, with the proofs unchanged, so the true remaining errors are visible.

**Timing.** The interval from the start of F1GCompile01 to this disposition is excluded, like D1's tooling intervals. The 600 s floor at restart applies again. When the active cap is spent without both target proofs compiling cleanly, F1 ends **FAIL (feasibility not shown within the cap)**. That is a true outcome; return the evidence and stop.

**F1 PASS still requires:** compile exit 0 for both modules, `#print axioms` showing only `propext`, `Classical.choice`, `Quot.sound` for the three theorems, the pinned strict checker, library checksums before and after, and skeleton's audit. A `sorryAx` from error recovery is never acceptable.

Not covered: F2 before a recorded F1 PASS, Stage B, FF-2, sync, commits, Neo, G1, S4r-C.
