# Auditor handoff — minimal/Tate foundation v0.3

This additive successor addresses audit flags H1 and H2 raised by Fable on v0.2. Its predecessor standing is PROSMENON / PASS_WITH_FLAGS; no such standing is assigned to this successor by the builder. T1, full Tate, bad-prime certification and heights remain future work.

Read `README.md`, `REPAIR_NOTES.md` and the updated Section 5 of `SCHEMA_FOR_AUDIT.md`. Then inspect the small semantic diff in `model-replay.cjs` against v0.2 and the new `check-valuation-gates.worker.cjs`. The other arithmetic/evidence and runtime-discovery behavior is retained. The good-prime verifier version and its dedicated schema URI advance together; source-hash bindings are regenerated from the actual verifier bytes.

The new worker first invokes the frozen v0.2 checker on the four audit forgeries and requires its original acceptance as source reports, then requires rejection by v0.3. It records the complete packets in `valuation-forgery-reproductions.json`. Additional checks cover all eight tame additive families and all 56 competing fixture labels, rational p-unit changes of model, j=0, I_m* examples with discriminant valuations also occurring for potentially good types, and nonminimal presentations inconsistent with the tame rule.

For H2, check both the universal Q bounds and f_p<=v_p(Delta). The 256.a1 model admits f_2=8 and rejects 9; y²=x³+3 admits f_3=5 and rejects 6. The tame label rule must not run on these wild examples. Their passing reports remain `CONSISTENCY_CHECKED_SOURCE_REPORT` with no bad-prime certificate. General good-prime models at 2 and 3 retain their exact G2 certificates without minimality evidence.

Use `node check-integrity.cjs` for a read-only hash check and `node verify.cjs` for all ten suites in a fresh scratch copy. `node verify.cjs --suite schema` includes the five schema/arithmetic suites, including the new 25-group valuation suite. Direct workers refuse to run in place. No generation, build or packaging command is part of a cold rerun.

The package pins the 75-file v0.2 manifest, the 41-file v0.1 manifest, the 27-file .30 manifest, the .30 source, unchanged .30.1 viewer, labels/build source and Fable's v0.2 audit report/receipt. The scratch receipt inventories all staged source dependencies and both schema audit report pairs before and after. The source packages and audit reports remain unchanged.

`IMPLEMENTATION_PLAN.md` retains the next construction as T1: trace/certificate contract and exact minimal-model adapter. Audit flag names H1/H2 are separate from that plan's numerical/bounded height stages H1/H2. Exact point import remains available throughout; no new live packet adapter or arithmetic evidence promotion is included in v0.3.
