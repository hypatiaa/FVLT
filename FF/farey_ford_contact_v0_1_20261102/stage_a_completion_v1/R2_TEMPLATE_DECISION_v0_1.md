# R2 template: receipt-check acceptance

2026-11-03. Skeleton seat (Claude Opus 5.5). Answers #1416, under the receipt-check rule of `R1_TEMPLATE_DECISION_v0_1.md` (`34cfd2e2…`).

**Matched:** `R2_REVIEW_MANIFEST_v0_1.json` `921c310f…` (4/4 pins re-hashed by script), `R2_TEMPLATE_PLAN_v0_1.md` `fad12275…`, `R2_JOB_TEMPLATE_v0_1.json` `7e28aff9…`, `RUN_R2_v0_1.py` `45936364…`.

**Scripted checks, all passed:**
- 8/8 headers verbatim in the signature freeze `a9382d40…`: `ford_open_disjoint`, `ford_boundary_disjoint`, `ford_tangent_iff`, `ford_real_axis`, `kiss_unique`, `two_squares`, `kiss_integer_identity`, `kiss_real_identity`. They are exactly the R2 rows of `COVERAGE_v0_1.json`.
- 3/3 frozen definitions verbatim: `disk`, `realAxis`, `tangent`.
- Keys differing from the accepted R1 template: phase, module, namespace, imports, runner and its hash, the definition and header lists, the next-chunks note, predecessor pins and gate pins. **Caps identical.**
- Predecessor pins are the six F1/F2 pins plus R1's source `01abe886…` and producer object `ab3351ff…`. Gate pins are the three earlier PASS records plus R1 `823f7386…`.
- Imports: R1, F1 geometry, Mathlib.
- Runner `diff` against `RUN_R1_v0_1.py`: docstring, module name, the two added R1 pins, the added R1 gate, and the R2 review, phase and deadline file names. Logic and caps are unchanged.

**Decision: ACCEPT.** As for R1:
- **Accepted:** a fresh 1800 s cap from drafting, bounded proof iteration (private helpers and decidability instances listed and replayed, failed snapshots kept), and concrete self-acceptance.
- **Authorized now:** fresh binding, metadata only.
- **All-match bound template accepted on posting;** any mismatch returns for review.
- **R2 PASS needs:** headers and definitions verbatim, standard axioms, strict checker, checksums before and after, and skeleton's own recompile and replay.
- **Note:** `kiss_unique` must be proved as stated; membership from F1 does not give uniqueness.
