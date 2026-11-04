# FF-1 freeze review v0.1, addendum A1: scripted check of the frozen signatures

2026-11-03. Skeleton seat (Claude Opus 5.5), at saphir's instruction "You do need to verify by script". Additive: `FREEZE_REVIEW_v0_1_20261103.md` (`e7769841…`) is unchanged. Its signature section said "checked by hand"; this addendum adds the scripted check.

- Script: `SKELETON_SIGNATURE_CHECK_20261103.cjs`, SHA-256 `e0cac846829de7f5b5f4ea9e8c525b90587561a1f5ca2e3ea890fb21c87fd0b3`. Exact integer and BigInt-rational arithmetic only.
- Run: job `SKEL-FF-SIGCHECK-0001` on membrane under `run_capped_v2.sh` (core 0, nice 19, 4096 MiB, 1800 s), PREREG `463e7819…`, 2.7 s wall, library checks OK before and after. Receipt, stdout, stderr, PREREG and manifest copied to `SKEL_FF_SIGCHECK_0001/` (stdout `fb216026…`, RECEIPT `f4e14d97…`).
- Result: **1,950,186 checks, 18 failures, all in FF-2 Part B** (the pillow statement as written in FF-2 v0.1). **Zero failures in FF-1 A1–A7.**

Domains for FF-1 (finite; evidence, not proof):
- A1: integers a, c in [−12, 12], q, s in [1, 12]; canonical forms for a in [−20, 20], q ≤ 20; symmetry and irreflexivity on all reduced rationals with denominator ≤ 14 and numerator in [−2q, 3q] (the set below).
- A2: adjacent mediants on that set; rosette for N = 2 … 300.
- A3–A4: on that set, exactly (centres have rational coordinates): the distance identity, open-disk disjointness, boundary disjointness when |det| ≥ 2, "exactly one common point (d = r₁ + r₂ or d = |r₁ − r₂|) iff |det| = 1", kiss membership on both circles, the kiss integer identity; real-axis contact on 200 × 200 pairs; the two-squares identity on [−9, 9]⁴.
- A5: a, b ≤ 80; connectivity iff interval over every nonempty subset of {1, …, 11}; gap determinant, minimal-gap mediant and the even-gap criterion for a, k ≤ 60.
- A6: all profiles [a], [a, b], [a, b, c] with 14 ≥ a ≥ b ≥ c (c odd), plus [4,3,2,1], [9,2], [8,3], [12,6,4,3,2,1]: set equality, domain, the partner statement for every c in [−s−2, s+2], the congruence form with Euclidean division, cross-denominator, isolation and endpoint isolation, complement membership, adjacency and pairs.
- A7: counts, isolated sets and partitions of all four fixtures; the (4,2,1) vertex set and the (4,3,2,1) repair edges.

Not covered by the script: the generic certificate theorems (`spanning_tree_connected`, `certificate_component_bijection`, `certificate_component_count`, `certificate_isolation`) and `contactCount_eq_edge_count` as general statements; they rest on the hand argument in the review and on the Lean proofs to come. The FF-1 freeze decisions in #1373 stand.
