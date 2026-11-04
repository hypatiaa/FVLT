# Library v24 readiness receipt (FF-4)

2026-11-04. Skeleton (Claude Opus 5.5). I checked all three hosts independently after the single writer's receipt from the Rule 30 tooling session (`local_74e563f3…`).
- **Authority:** saphir's standing sync rule.
- **Plan:** `SYNC_PLAN_FF4_v0_1.md` (`91813a11…`), with the owner's handoff `35ebf0ca…` (#1612).
- **Basis:** FF-4 final PASS, #1611.

**Outcome: v24 READY.**

## Read-only check on nucleus, scout and membrane (`skeleton_v24_check.sh`)

The results were identical on all three hosts:
- latest = v24;
- SHA256SUMS `74e30ce658ac1367…` (404 entries), 0 check failures and 0 writable files, before and after the check;
- LIBRARY_MANIFEST `703854b83ee1f3cf…`; lake-manifest `1f0e0c1c0a06e2a9…`, unchanged from v23;
- **delta against v23:** exactly three added sources, `theorems/FVLTFordBulb{Data,Parameter,Combinatorics}V1.lean`, plus `lakefile.toml` and `LIBRARY_MANIFEST.json`. Nothing was removed.
  - On nucleus, the lakefile diff is exactly the three new FF-4 roots, inserted in sorted order.
- **sources** byte-identical to the plan table: `19fcd5d3…`, `1e1eef97…`, `41db1fb6…`;
- **axiom report:** my `SkeletonAuditFF4.lean` (`7401d6d5…`) run in frozen v24 printed 64 lines, sha `024dbc9e…`. That is byte-identical to my final-audit `logs/axioms.log`. Every target and every data declaration uses only the standard axioms. Three targets use a subset of them:
  - `q_at_least_two` and `lower_digit_equiv` use `propext` and `Quot.sound`;
  - `upper_digit_equiv` uses `propext`.
- **v23** still verifies: 0 check failures and 0 writable files.

## From the writer's receipt

Consistent with the checks above, not re-derived:
- runner v3 with an empty drop list (gate test `de872490…`);
- CHANGED [] and DROPPED [];
- 397 inherited files unchanged;
- full-library AxiomCheck AXIOMS_OK, 129 modules and 5295 constants, report `093898ac…` identical on all three hosts;
- 4 expected deprecation warnings in Combinatorics, with the source bytes unchanged.

## Date correction (metadata only)

- v24's `LIBRARY_MANIFEST.json` "date" and the staging receipt read **2026-11-05**. The correct date is **2026-11-04**.
- The writer disclosed this, and the source of the error is mine: `SYNC_PLAN_FF4_v0_1.md`, `FF4_FINAL_AUDIT_v0_1.md` and `BUS_RECEIPT_1611.md` all carry 2026-11-05 in their headers.
- Folder names such as `ff4_final_20261105` are labels only.
- No mathematical content, hash or check is affected.
- The frozen and pinned files are left unchanged, and no v25 is made for this. The README's [CORRECTED 2026-11-04] line, and `DATE_CORRECTION_v0_1.md` beside the audit, record it.

The library is not a release, and this receipt changes no kernel text.
