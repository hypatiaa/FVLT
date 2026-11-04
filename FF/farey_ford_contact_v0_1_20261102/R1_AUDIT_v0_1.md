# R1 audit: **R1 PASS recorded**

2026-11-03. Skeleton seat (Claude Opus 5.5), on saphir's instruction ("Yes audit 1413"). Answers #1413.

**Producer package matched:** `stage_a_completion_v1/RESULT_R1_v0_1.md` `2aeacb73…`, `FINAL_R1_MANIFEST_v0_1.json` `33ad9fa5…`. **All 63 manifest entries re-hashed locally by script, sizes included: 63 match, 0 differ.**

**Binding.** Bound template `8ebcc040…` and fresh receipt `f5cd392c…` (`all_expected_equal: true`, latest v19). By script, the bound template differs from the accepted draft `50b379ba…` only in `status`, `input_receipt_file`, `input_receipt_sha256` and `manager_template_decision_sha256`. Headers, definitions, runner and caps are unchanged. So the accept-on-posting rule of `R1_TEMPLATE_DECISION_v0_1.md` (`34cfd2e2…`) applied correctly.

**Source** `FVLTFareyArithmeticCompletionV1.lean` `01abe886…`. Scripted comparison (`SKELETON_R1_AUDIT/SKELETON_R1_COMPARE_OUTPUT_20261103.txt`, 0 failures):
- the 7 frozen headers and 3 frozen definitions (`rawValue`, `mediant`, `unitFrac`) occur verbatim in the source and the signature freeze;
- the public declarations are exactly those 10;
- the two private helpers are `coprime_from_det` and `unitFrac_data`;
- `det` and `fareyAdj` are not redeclared;
- the imports are `FVLTFareyCertificatesV1` and Mathlib only;
- there is no `sorry`, `admit`, `native_decide`, `unsafe`, `partial` or `axiom`.

**Independent recompile and replay by skeleton on nucleus**, in a separate folder `~/skeleton_audit/r1_20261103/`, with the exact sources, the pinned checker and executable, the latest library v19, and the template limits:
- F1 arithmetic, F2 certificates and R1 all exit 0 with 0 errors. R1 took 1.96 s and 3.50 GB.
- **Axioms:** 9 of 9 reports (7 targets and 2 helpers) are `[propext, Classical.choice, Quot.sound]`.
- **Strict checker:** 29/29 constants, `failures: []`, 0 unsafe, partial or `sorryAx`, `g1Excluded: true`.
- **Library:** `sha256sum -c` OK before and after.
- The R1 olean bytes differ from the producer's (`2db67446…` vs `ab3351ff…`, built over skeleton's own F2 rebuild). They are not a target; the proofs were rechecked from source.

**Verdict: R1 PASS.** It covers exactly the 7 frozen statements:
- `raw_det_one_coprime`, `rawValue_num_den`, `rawValue_canonical` and `rawValue_unique`;
- `coprime_den_not_adj`;
- `adjacent_mediant`;
- `rosette`.

Manager-audited count: 19 + 7 = **26 of 60**, with 34 remaining (R2 8, R3 10, R4 11, R5 5). Not yet VERIFIED or FIDELITY-REVIEWED; the final 60-target integration stays separately gated.

**Next:** R2, under its own template, reviewed as a receipt check per `34cfd2e2…`.
