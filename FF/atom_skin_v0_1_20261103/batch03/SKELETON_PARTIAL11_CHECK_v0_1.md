# Skeleton check: FF-2 partial delivery, 11 of 28 (bus #1468–#1473)

2026-11-03. Skeleton (Claude Opus 5.5). This is an interim check of the producer's records by script. It is not my independent recompile or replay, not the fidelity review, and not an FF-2 outcome.

## Packet

- Result `7d8501a2...`, manifest `5565922f...` and new-theorems list `75a69a7f...` match their posted hashes.
- All **102 of 102** manifest entries re-hash correctly.
- The current sources are:
  - Counts `552b7716...`;
  - Pillowcase `c2844ce4...`;
  - the data modules, unchanged: `8d165af9...` and `b8a03b38...`.

## Statements, condition 2

Script `../SKELETON_FF2_HEADER_COMPARE_v0_1.cjs` (`a4949a61...`) compares the 11 public theorems with the frozen headers `b4484f6e...`. All 11 are **byte-identical**:

- **Atom skin (5):**
  - `vertex_count`;
  - `cube_genus_zero`;
  - `cube_edge_iff`;
  - `cube_connected`;
  - `incident_direction_equiv`.
- **Pillowcase (6):**
  - `pillowRel_equivalence`;
  - `halfTurn_not_identity`;
  - `fixingHalfTurn_iff_multiples`;
  - `nonzero_translation_fixes_nothing`;
  - `fixingHalfTurn_iff_corner_class`;
  - `four_corner_classes_distinct`.

There is no `sorry`, `admit`, `axiom`, `unsafe` or `extern`. All nine helpers are `private`: two in Counts (`adjacent_symmetric`, `path_from_empty`) and seven in Pillowcase.

## Verification records

| Module | Strict replay | Named axiom log |
|---|---|---|
| Pillowcase, 6 laws | `e31f5151...`: PASS, 37/37, kernel completed, 0 fail/unsafe/partial | `763626b0...`: 6 lines, standard three only |
| Counts, 5 laws | `a98652f5...`: PASS, 27/27, kernel completed, 0 fail/unsafe/partial | `c34a05ec...`: 5 lines, standard three only |

Every launch followed its posting:

| Run | Started | Posting it follows |
|---|---|---|
| Pillowcase axioms | 1793760233 | #1466 (1793760184) |
| Pillowcase replay | 1793760245 | #1466 (1793760184) |
| Graph02 compile | 1793761077 | #1470 (1793761037) |
| Counts axioms | 1793761267 | #1471 (1793761228) |
| Counts replay | 1793761279 | #1471 (1793761228) |

- Batch 2 closed at 1793760247.6, before its deadline 1793761040.
- Batch 3 closed at 1793761281.6, before its deadline 1793762458.
- Neither batch was reset.
- The Graph01 failure, caused by the proof body, is preserved. Graph02 changed only the proof body, which bounded iteration allows.

## Standing

- **Producer-clear:** 11 of 28.
- **Open:** 17:
  - Counts: `edge_count`, `square_count` and `chi_formula`, A2 incidence (3 statements), `link_cycle`, A4 (2 statements) and A6 (2 statements);
  - Pen: 5 statements;
  - `key_classifies`.
- **Unchanged:** all #1448 conditions stand. My recompile, replay and fidelity review come at final. FF-3 builds stay held.
