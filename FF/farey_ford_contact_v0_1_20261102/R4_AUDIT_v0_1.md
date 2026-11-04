# R4 audit: **R4 PASS recorded**

2026-11-03. Skeleton seat (Claude Opus 5.5), under saphir's go ("Go"). Answers #1428 and #1429.

**Producer package matched:** `stage_a_completion_v1/RESULT_R4_v0_1.md` `b9305e1c…`, `FINAL_R4_MANIFEST_v0_1.json` `9b1c4d40…`. **All 45 manifest entries re-hashed locally by script, sizes included: 45 match, 0 differ.**

**Binding.** Bound template `de7d4ea6…` and receipt `1fde30dd…` (#1428): by script, the bound template differs from the accepted draft `6f59c2e5…` only in status, receipt and decision-hash fields, and the receipt has `all_expected_equal: true` on v19. Accept-on-posting under `R4_TEMPLATE_DECISION_v0_1.md` (`f53647f2…`) applied correctly.

**Source** `FVLTPhasePartnersV1.lean` `81b55661…`. Scripted comparison (`SKELETON_R4_AUDIT/SKELETON_R4_COMPARE_OUTPUT_20261103.txt`, 0 failures):
- the 11 frozen headers occur verbatim, with all binders;
- `unreducedPhases` equals the frozen definition with exactly the erratum S1 annotation `fun e : ℕ` (`03c54bbf…`), and nothing else differs;
- the public declarations are exactly those 12;
- the 6 private helpers are `admissible_two`, `interior_numerator`, `phase_description`, `sign_witness`, `unit_phase` and `complement_coordinates`;
- the imports are R3, `Mathlib.Data.Int.ModEq` and `Mathlib.Tactic`;
- there is no `sorry`, `admit`, `native_decide`, `unsafe`, `partial`, `axiom` or linter suppression.

**Independent recompile and replay by skeleton on nucleus**, in a separate folder `~/skeleton_audit/r4_20261103/`, with the exact sources of F1, F2 and R1–R4, the pinned checker and executable, the latest library v19, and the template limits:
- All seven modules exit 0 with 0 errors; R4 took 2.31 s and 3.52 GB.
- **Axioms:** 17 of 17 reports are `[propext, Classical.choice, Quot.sound]`.
- **Strict checker:** 40/40 constants, `failures: []`, 0 unsafe, partial or `sorryAx`, `g1Excluded: true`.
- **Library:** `sha256sum -c` OK before and after.
- The R4 olean bytes differ from the producer's (`c70e745b…` vs `875d7726…`). They are not a target; the proofs were rechecked from source.

**Verdict: R4 PASS.** It covers exactly the 11 frozen statements:
- `phases_eq_unreduced` and `phase_domain`;
- `denominator_partner` and `partner_congruence`, with the numerator range kept;
- `cross_denominator`;
- `isolation_criterion` and `endpoint_isolation`;
- `complement_mem`, `complement_adj`, `complement_graph_auto` and `isolated_complement_pairs`.

All of these hold on the interior phase domain.

Manager-audited count: 44 + 11 = **55 of 60**, with 5 remaining (R5). Not yet VERIFIED or FIDELITY-REVIEWED; the final integration stays separately gated.

**Next:** R5 under its own template, as a receipt check.
