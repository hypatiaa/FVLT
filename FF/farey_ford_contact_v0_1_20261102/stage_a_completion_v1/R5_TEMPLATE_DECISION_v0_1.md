# R5 template: receipt-check acceptance

2026-11-03. Skeleton seat (Claude Opus 5.5). Answers #1431, under the receipt-check rule of `R1_TEMPLATE_DECISION_v0_1.md` (`34cfd2e2…`) and saphir's go ("Go").

**Matched:** `R5_REVIEW_MANIFEST_v0_1.json` `39e4ebd2…` (4/4 pins re-hashed by script), `R5_TEMPLATE_PLAN_v0_1.md` `6ccc92c7…`, `R5_JOB_TEMPLATE_v0_1.json` `61f05461…`, `RUN_R5_v0_1.py` `d28faa68…`.

**Scripted checks, all passed:**
- 5/5 headers verbatim in the signature freeze `a9382d40…`, exactly the R5 rows of `COVERAGE_v0_1.json`: `fixture4321_connected`, `fixture4321_repair_edges`, `fixture83_certificate`, `fixture83_counts`, `fixture83_isolated`.
- No new definitions.
- Caps are identical to R1–R4. Imports are R4 and Mathlib.
- There are 14 predecessor pins (adding R4's source `81b55661…` and object `875d7726…`) and 7 gate records (adding R4 PASS `ffbb7419…`).
- Runner `diff` against `RUN_R4_v0_1.py`: docstring, module name, the two R4 pins, the R4 gate, and the R5 file names. Logic and caps are unchanged.

**Prior evidence for the fixtures** (finite, not proof): skeleton's exact recount (`SKELETON_FIXTURE_RECOUNT_20261103.cjs`), the scripted signature check and Sage all gave:
- (4,3,2,1): V = 9, E = 10, connected; repair edges 1/5–1/4 and 3/4–4/5;
- (8,3): V = 11, E = 8, 3 components, isolated {1/9, 8/9}, and one large part of 9.

**Decision: ACCEPT.**
- **Accepted:** a fresh 1800 s cap from drafting, bounded proof iteration (private helpers and decidability instances listed and replayed, failed snapshots kept), and concrete self-acceptance.
- **Authorized now:** fresh binding, metadata only.
- **All-match bound template accepted on posting;** any mismatch returns for review.
- **Finite checks:** kernel `decide`, Mathlib's proved bounded-walk decider, or explicit certificates. Never `native_decide`.
- **R5 PASS needs:** the actual frozen (8,3) partition certificate (the five clauses through the audited bijection), not counts alone; standard axioms; the strict checker; checksums before and after; skeleton's own recompile and replay.

An audited R5 completes **individual** coverage of the 60 targets. The integrated build of all 60 and the per-row fidelity review keep their own concrete gates.
