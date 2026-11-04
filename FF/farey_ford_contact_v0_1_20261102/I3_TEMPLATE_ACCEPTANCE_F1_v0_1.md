# I3: F1 job-template acceptance

2026-11-03T10:38:34Z (unix 1793702314). Skeleton seat (Claude Opus 5.5). **ACCEPT** `F1_JOB_TEMPLATE_v0_1.json`, SHA-256 `45c7d8bf2046298f2f7d9e428e90ce173391050156e77f526c8da5cedd10c274`. The owner's acceptance wait in `F1_TIMING_v0_1.json` (started unix 1793701971) ends at this timestamp; that interval is excluded from the F1 active cap.

**Checked against the accepted records:**
- runner `RUN_FF1_v0_2.py` `c14f263c…` (accepted in clarification C1); Lean executable `bf8d54e4…` (hashed by skeleton on nucleus); signature file `a9382d40…`; v19 pins `e25d4d54…`, `f0ee6b00…`, `1f0e0c1c…`, `4f0aea13…`, `ca5f1f60…`; checker `9c6f2ac1…`: all equal the input freeze and FREEZE_REVIEW.
- Caps equal the accepted resource proposal (1 CPU, nice 19, 8 GiB, `-M7680`, 240 s per call, 1800 s active F1 cap including drafting, serial, no retries, failure stops the item).
- Source rules match clarification C1 (owner self-acceptance only after this acceptance, logged with timestamp and template hash; snapshots before every invocation; changed propositions or outside-template jobs return for review; full audit at the F1 report).

**Scripted check of the current uncompiled drafts** (`SKELETON_HEADER_COMPARE_v0_1.cjs`, output `SKELETON_HEADER_COMPARE_F1_DRAFT_20261103.txt`, 0 failures): `FVLTFareyContactV1.lean` `e11ada27…` and `FVLTFordGeometryV1.lean` `803b13de…`.
- Both template headers occur verbatim in the signature file and in the sources.
- Every top-level `def`/`theorem` in the sources is a frozen declaration (full definition lines compared line by line, bodies included).
- No `sorry`, `admit`, `native_decide`, `unsafe`, `partial def` or `axiom`; imports are `Mathlib` and `FVLTFareyContactV1` only.
- Sage: the local identity used inside the `kiss_membership` proof, |k − c_u|² − r_u² = s²(D² − 1)/((q² + s²)² q²), holds symbolically, and the kiss point is symmetric in its two arguments.

This acceptance is of the template and the drafts' conformance, not of any proof. F1 PASS needs compile exit 0, the axioms check, the checker, and skeleton's audit.
