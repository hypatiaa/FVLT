# R3 template: receipt-check acceptance

2026-11-03. Skeleton seat (Claude Opus 5.5). Answers #1421, under the receipt-check rule of `R1_TEMPLATE_DECISION_v0_1.md` (`34cfd2e2…`). saphir's go for the R audits carries forward to R3.

**Matched:** `R3_REVIEW_MANIFEST_v0_1.json` `596a3f8b…` (4/4 pins re-hashed by script), `R3_TEMPLATE_PLAN_v0_1.md` `c5610b69…`, `R3_JOB_TEMPLATE_v0_1.json` `876cf251…`, `RUN_R3_v0_1.py` `446d2ced…`.

**Scripted checks, all passed:**
- 10/10 headers verbatim in the signature freeze `a9382d40…`, exactly the R3 rows of `COVERAGE_v0_1.json`.
- 2/2 frozen definition headers verbatim: `vertexSet` (full body) and `integerPath : SimpleGraph ℕ`.
- The template fixes `integerPath` adjacency as exactly |(a : ℤ) − (b : ℤ)| = 1, with symmetry and looplessness as proof fields only. That matches the freeze's prose specification (signature freeze line 39).
- `unitFrac_tangent` is placed in `FVLT.FordGeometryV1`, the others in `FVLT.FareyContactV1`, as the freeze's placement note says.
- Caps are identical to R1 and R2. Imports are R2 and Mathlib.
- There are 10 predecessor pins (adding R2's source `c3251f10…` and object `ce38bf44…`) and 5 gate records (adding R2 PASS `48e4ee94…`).
- Runner `diff` against `RUN_R2_v0_1.py`: docstring, module name, the two R2 pins, the R2 gate, and the R3 file names. Logic and caps are unchanged.

**Decision: ACCEPT.**
- **Accepted:** a fresh 1800 s cap from drafting, bounded proof iteration (private helpers and decidability instances listed and replayed, failed snapshots kept), and concrete self-acceptance.
- **Authorized now:** fresh binding, metadata only.
- **All-match bound template accepted on posting;** any mismatch returns for review.
- **R3 PASS needs:** headers and definitions verbatim; `integerPath`'s adjacency checked against the frozen prose at the audit; standard axioms; the strict checker; checksums before and after; skeleton's own recompile and replay.
