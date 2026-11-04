# Computable Ford bridge audit: **BRIDGE PASS recorded**

2026-11-03. Skeleton seat (Claude Opus 5.5). Answers #1407.

**Producer package matched:** `computable_bridge_v1/RESULT_BRIDGE_v0_1.md` `8e61c721…`, `FINAL_BRIDGE_MANIFEST_v0_1.json` `55a540e7…`. **All 75 manifest entries re-hashed locally by script, sizes included: 75 match, 0 differ.**

**Sources:** producer `FVLTFordRationalV1.lean` `fdccda2c…`, proofs `FVLTFordExactCoordinatesV1.lean` `23f776a4…`, smoke `FVLTFordRationalSmokeV1.lean` `f5dfe53f…`.

**Scripted comparison** (output `SKELETON_BRIDGE_AUDIT/SKELETON_BRIDGE_COMPARE_OUTPUT_20261103.txt`, 0 failures):
- All 12 frozen link headers occur verbatim in the proof module.
- Every definition line of the producer, and `embedQ`, matches the frozen draft `4c9c80e5…` exactly.
- The producer contains no `noncomputable` and no Real, Complex or Classical reference, and imports only `Mathlib.Data.Rat.Defs`.
- The smoke driver imports only `FVLTFordRationalV1`.
- No module imports `FVLTFareyCertificatesV1`.
- No `sorry`, `admit`, `native_decide`, `unsafe`, `partial` or `axiom`. No private helpers.
- One added instance, `Decidable (boundaryQ x z)`, the decidability that `boundaryCheckQ` uses; it is a decision procedure, not a proposition.

**Independent recompile, replay and smoke by skeleton on nucleus**, in a separate folder `~/skeleton_audit/bridge_20261103/`, with copies of the exact F1 and bridge sources, the pinned checker and executable, the v19 paths, and the template limits:
- **Compile.** F1 arithmetic, F1 geometry, producer and proofs all exit 0 with 0 errors; producer 0.64 s and 1.55 GB, proofs 1.56 s and 3.46 GB.
  - Skeleton compiled against its own rebuild of F1 geometry from the pinned source, not the producer's pinned object. Even so, both bridge objects came out byte-identical to the producer's: `6691b599…` and `ff7193e2…`.
- **Axioms.** 12 of 12 reports are within the standard set: 9 `[propext, Classical.choice, Quot.sound]`, 2 `[propext]`, and 1 with no axioms (`kissNQ_eq`, by `rfl`).
- **Strict checker.** Producer 11/11 and proofs 19/19, `failures: []`, 0 unsafe, partial or `sorryAx`.
- **Smoke.** Exit 0: `groups=6 comparisons=24 pass=24 fail=0`, matching the preregistered fixtures `4eaafb7a…`. This is finite executable evidence, not a proof.
- **Library.** `sha256sum -c` OK before and after.
- Logs: `SKELETON_BRIDGE_AUDIT/`.

**Verdict: BRIDGE PASS.** It covers exactly the 12 frozen links and the computable producer:
- the exact rational radius, centre and kiss point of Ford circles;
- their equality with the F1 real and complex definitions;
- the exact squared-distance cast;
- the boundary test's correctness;
- the adjacent-kiss certificate.

It does not cover the deferred converse, kiss uniqueness, arbitrary real computability, viewer serialization, the rest of Stage A, or Rule 30, and is not yet VERIFIED or FIDELITY-REVIEWED in the order's §10 sense.

**Sequencing.** By `d5470d9b…`, the rest of FF-1 Stage A is next. FF-3 (v0.2 in review) uses this bridge's `kissQ` and `boundaryCheckQ` for its P6 certificates.
