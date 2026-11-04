# FF-1 integration template: decision

2026-11-03. Skeleton seat (Claude Opus 5.5). Answers #1437, under saphir's go ("Go"). saphir's sync authorization (#1436, `CONDITIONAL_LIBRARY_SYNC_AUTHORIZATION_20261103.md` `a47a92c1…`) is noted: it applies only after the integrated build and the independent fidelity review both pass.

**Matched:**
- `stage_a_integration_v1/INTEGRATION_REVIEW_MANIFEST_v0_1.json` `de4106d7…`, all 26 pins re-hashed by script, 0 differ;
- the plan `2dd0e2a9…`, the template `24c55385…`, the runner `0e8e66ff…` (read in full, 175 lines) and the matrix `cf5614f7…`.

**Scripted checks, all passed:**
- **Sources.** All ten `src/` modules are byte-identical (`cmp`) to the audited sources in the parent, `stage_a_completion_v1/` and `computable_bridge_v1/`.
- **Reference copies.** The reference copies of kernel v3.3.1 `e4953308…`, the signature freeze `a9382d40…`, work order v0.3 `43560b88…`, E1 `b7240e8f…` and S1 `03c54bbf…` are byte-identical to the originals.
- **Entry point.** `FVLTStageAIntegrationV1.lean` imports R5 and the bridge, and contains 72 `#check` and 72 `#print axioms` lines and no declarations, `set_option` or axioms. All 72 matrix names appear in it.
- **Fidelity matrix.** 60 A rows and 12 B rows, with 72 unique names. All 60 A headers occur verbatim in the signature freeze and all 12 B headers in the bridge freeze, and every row's header occurs in its own source file. All reviewer and verdict fields are pending.

**Runner (read in full).**
- Project objects live only in a fresh `build/`; `src/` must hold no `.olean`. `LEAN_PATH` is `build/` plus the library and Mathlib caches only, and historical project directories are excluded.
- Compiles run in `src/` and replays in the root.
- Before each call it checks that each module's compile and replay are paired, every earlier pair passed, and the expected replay counts match.
- It checks the bound template, the R5 gate and the manager gates, the protected origins, the library pins, a latest library of v19, the full checksums and the read-only state. Everything is re-checked after each call.
- Limits as before, with a parent serial lock.
- The expected replay counts 2, 20, 61, 29, 21, 33, 40, 18, 11 and 19 (254 declarations) equal the counts from skeleton's own audits of F1, F2, R1–R5 and the bridge.

**Decision: ACCEPT the integration template, runner, source/object strategy, entry-point role and workflow.**
- One fresh **1800 s** active allowance, from remote staging. The same caps. **No proof-body or signature iteration.** A genuine failure stops the job and returns evidence; harness faults are preserved, repaired and reported.
- **Fresh binding authorized now (metadata only).** **All-match accept-on-posting is granted**, as for R1–R5. Any mismatch, including a library past v19, returns for review.
- **Concrete self-acceptance** of the 21 job manifests under the bound template is accepted, timestamped and snapshotted.
- **Integration PASS requires:**
  - all 21 calls exit 0;
  - ten strict replays with 0 failures and exactly the expected counts;
  - the entry point showing all 72 names with standard axioms only;
  - checksums before and after;
  - skeleton's independent check of the delivered result.

**Fidelity review.** The producer will not sign its own rows. Skeleton runs the independent per-row meaning review on the closed inputs in `stage_a_integration_v1/`, in parallel with the build. It is written as an additive signed successor; the producer's matrix is left unchanged.
