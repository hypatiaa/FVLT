# R5 audit: **R5 PASS recorded**; all 60 FF-1 Stage A targets individually audited

2026-11-03. Skeleton seat (Claude Opus 5.5), under saphir's go ("Go"). Answers the R5 delivery, which was found in the package before its bus announcement, and #1433.

**Producer package matched:** `stage_a_completion_v1/RESULT_R5_v0_1.md` `5d2d218a…`, `FINAL_R5_MANIFEST_v0_1.json` `ed0c16ac…`. **All 46 manifest entries re-hashed locally by script, sizes included: 46 match, 0 differ.**

**Binding.** Bound template `38a69f26…` and receipt `2dc11158…` (#1433): by script, the bound template differs from the accepted draft `61f05461…` only in status, receipt and decision-hash fields, and the receipt has `all_expected_equal: true` on v19. Accept-on-posting under `R5_TEMPLATE_DECISION_v0_1.md` (`cec9d25d…`) applied correctly.

**Source** `FVLTFareyFixturesCompletionV1.lean` `85b05d80…`. Scripted comparison (`SKELETON_R5_AUDIT/SKELETON_R5_COMPARE_OUTPUT_20261103.txt`, 0 failures):
- the 5 frozen headers occur verbatim;
- the public declarations are exactly those 5, with no private helpers, no new definitions or instances, and no `set_option`;
- the imports are R4 and `Mathlib.Tactic`;
- there is no `sorry`, `admit`, `native_decide`, `unsafe`, `partial` or `axiom`;
- the finite checks are `decide +kernel`: kernel proof terms checked by Lean's kernel, not native evaluation.

**Certificate semantics (read).**
- `fixture83_certificate` unfolds `rationalCertificate` and `ComponentCertificate` and discharges the subset guard and all five clauses by kernel decision.
- `fixture83_counts` gets the component count from the audited `rational_certificate_count` applied to that certificate, not from a separate count.
- `fixture4321_connected` proves Mathlib's `Connected` itself.

**Independent recompile and replay by skeleton on nucleus**, in a separate folder `~/skeleton_audit/r5_20261103/`, with the exact sources of F1, F2 and R1–R5, the pinned checker and executable, the latest library v19, and the template limits:
- All eight modules exit 0 with 0 errors; R5 took 11.49 s and 4.26 GB.
- **Axioms:** 5 of 5 reports are `[propext, Classical.choice, Quot.sound]`.
- **Strict checker:** 18/18 constants, `failures: []`, 0 unsafe, partial or `sorryAx`, `g1Excluded: true`.
- **Library:** `sha256sum -c` OK before and after.
- The R5 olean came out **byte-identical** to the producer's (`237223a3…`).

**Verdict: R5 PASS.** It covers exactly the 5 frozen fixture statements:
- (4,3,2,1): connected, with repair edges 1/5–1/4 and 3/4–4/5;
- (8,3): the actual partition certificate, 11 phases, 8 contacts, 3 components, isolated set exactly {1/9, 8/9}.

## FF-1 Stage A: individual coverage complete

Manager-audited: F1 3 + F2 16 + R1 7 + R2 8 + R3 10 + R4 11 + R5 5 = **60 of 60** frozen Stage A targets. Each target was independently recompiled and replayed by skeleton with standard axioms only and verbatim headers. Records:
- F1 `d5470d9b…`, F2 `95532c2c…`;
- R1 `823f7386…`, R2 `48e4ee94…`, R3 `8003559f…`, R4 `ffbb7419…`;
- R5: this file.

The computable bridge (`cc025916…`, 12 links) is additional.

**Still gated, not claimed here:**
- (1) the integrated build of all 60 targets as one package;
- (2) the independent per-row statement-fidelity review against the kernel;
- (3) the order's §10 VERIFIED, FIDELITY-REVIEWED and later statuses;
- (4) library sync, which is still a proposal needing saphir's separate yes;
- (5) any kernel correction, which goes through Idea Catalog candidates only.

Stage B, FF-2, FF-3 and FF-4 keep their own gates.
