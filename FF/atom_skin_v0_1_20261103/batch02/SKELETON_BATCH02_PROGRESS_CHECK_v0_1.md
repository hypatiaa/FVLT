# Skeleton progress check: FF-2 BATCH02 (bus #1463–#1466)

2026-11-03. Skeleton (Claude Opus 5.5). This is an interim check of the producer's records: re-hashing, parsing and statement comparison, all by script. It is not my independent recompile or replay, and it is not an FF-2 outcome.

## Statements, condition 2

Script `../SKELETON_FF2_HEADER_COMPARE_v0_1.cjs` compares each delivered public theorem with the frozen headers `b4484f6e...`, which hold 28 statements.

- `partial_proofs_v0_1/src/FVLTAtomSkinCountsV1.lean` `4c499cb0...` delivers two statements, `vertex_count` and `cube_genus_zero`. Both are **byte-identical** to the freeze.
- `partial_proofs_v0_1/src/FVLTPillowcaseV1.lean` `c2844ce4...` delivers six statements, all **byte-identical** to the freeze:
  - `pillowRel_equivalence`;
  - `halfTurn_not_identity`;
  - `fixingHalfTurn_iff_multiples`;
  - `nonzero_translation_fixes_nothing`;
  - `fixingHalfTurn_iff_corner_class`;
  - `four_corner_classes_distinct`.
- Neither file contains `sorry`, `admit`, `axiom`, `unsafe` or `extern`. There are no public non-theorem declarations, and all seven helpers are `private`.

## Verification records

| Module (attempt) | Strict replay | Named axioms |
|---|---|---|
| Pillowcase, 4 laws (Proof01) | log `a8bc69d8...`: PASS, 15/15, kernel completed, 0 fail/unsafe/partial | log `45c1b4f8...`: 4 lines, standard three only |
| Counts, 2 laws (Proof02) | log `e1efa148...`: PASS, 2/2, kernel completed, 0 fail/unsafe/partial | log `1652666e...`: 2 lines, standard three only |
| Pillowcase, 6 laws (Proof03) | compile only so far: receipt `ef6a545d...`; axiom and replay jobs posted in #1466 | pending |

Every launch followed its posting:

| Run | Started | Posting it follows |
|---|---|---|
| Pillowcase axioms | 1793759771 | #1464 (1793759623) |
| Pillowcase replay | 1793759782 | #1464 (1793759623) |
| Counts axioms | 1793760030 | #1465 (1793759983) |
| Proof03 compile | 1793760053 | #1465 (1793759983) |

The Counts Proof01 failure (`decide` with a free `h3`) is preserved. Proof02 changes only the proof body, which is allowed under bounded iteration.

## Standing

- **Producer-clear so far:** 6 of 28 statements, the 4 pillowcase laws plus `vertex_count` and `cube_genus_zero`.
- **Compiled, verification pending:** `fixingHalfTurn_iff_corner_class` and `four_corner_classes_distinct`.
- **Open:** 20 statements, including `key_classifies` and all of A2–A8 except `vertex_count`.
- **Batch clock:** BATCH02 runs from origin 1793759240 to deadline 1793761040, with no reset.
- **Unchanged:** all #1448 conditions stand. FF-3 builds stay held.
