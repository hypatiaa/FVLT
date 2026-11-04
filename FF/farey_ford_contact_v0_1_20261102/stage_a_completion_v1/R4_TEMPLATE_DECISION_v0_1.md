# R4 template: receipt-check acceptance

2026-11-03. Skeleton seat (Claude Opus 5.5). Answers #1426, under the receipt-check rule of `R1_TEMPLATE_DECISION_v0_1.md` (`34cfd2e2…`) and saphir's go ("Go").

**Matched:** `R4_REVIEW_MANIFEST_v0_1.json` `f7d20cec…` (4/4 pins re-hashed by script), `R4_TEMPLATE_PLAN_v0_1.md` `10d29b3a…`, `R4_JOB_TEMPLATE_v0_1.json` `6f59c2e5…`, `RUN_R4_v0_1.py` `3d6cb153…`.

**Scripted checks, all passed:**
- 11/11 headers verbatim in the signature freeze `a9382d40…`, exactly the R4 rows of `COVERAGE_v0_1.json`.
- The one new definition, `unreducedPhases`, is verbatim. The only permitted change is the binder annotation `e : ℕ` pre-cleared by erratum S1 (`SIGNATURE_FREEZE_ERRATUM_S1.md`, `03c54bbf…`, pinned in the template). All other bytes are unchanged.
- Caps are identical to R1–R3. Imports are R3 and Mathlib.
- There are 12 predecessor pins (adding R3's source `21b2efd2…` and object `8d5f4cae…`) and 6 gate records (adding R3 PASS `8003559f…`).
- Runner `diff` against `RUN_R3_v0_1.py`: docstring, module name, the two R3 pins, the R3 gate, and the R4 file names. Logic and caps are unchanged.

**Decision: ACCEPT.**
- **Accepted:** a fresh 1800 s cap from drafting, bounded proof iteration (private helpers and decidability instances listed and replayed, failed snapshots kept), and concrete self-acceptance.
- **Authorized now:** fresh binding, metadata only.
- **All-match bound template accepted on posting;** any mismatch returns for review.
- **R4 PASS needs:** headers verbatim; `unreducedPhases` verbatim except the S1 annotation; the interior, numerator-range, positivity and admissibility binders preserved as frozen; standard axioms; the strict checker; checksums before and after; skeleton's own recompile and replay.
