# FF-2 statement-fidelity signoff v0.1 (atom skin + pillowcase)

2026-11-04. Reviewer: independent fidelity reviewer subagent, Claude Opus, spawned by skeleton 2026-11-04.

**Scope.** This is a meaning review only. It reads each of the 28 frozen statements together with the Lean definitions in force and compares them against `WORK_ORDER_v0_3.md`. Compilation, kernel replay and the axiom audit are separate and were not done here. No Lean was run, no network was used, nothing was posted, and no existing file was modified. The machine-readable version is `FIDELITY_SIGNOFF_v0_1.json`.

**Result: PASS (meaning review).** 28 MATCH. No HARMLESS_GENERALIZATION, NARROWER_THAN_SOURCE, TRANSLATION_DEFECT, PROSE_CORRECTION_CANDIDATE or UNRESOLVED verdicts.

## Files reviewed

Paths are relative to `atom_skin_v0_1_20261103/`.

| File | SHA-256 |
|---|---|
| `WORK_ORDER_v0_3.md` | `8e108ff4bd48784b8d33c0529afbc1aab35e652f8573986a77761999e16f6fac` |
| `freeze_packet_v0_1/FF2_DEFINITIONS_PROPOSED_v0_1.lean.txt` | `61ca7137e1307967866f97d096dda974d2f6400d32374f69252fcfe6598de615` |
| `definition_repair_v0_1/FF2_DEFINITIONS_PROPOSED_v0_3.lean.txt` | `a1ea047d677555c081cfda988487429446a6ab5f08e2b090427dc903d2012727` |
| `definition_repair_v0_1/REPAIR_DECISION_v0_1.md` | `d6a666bdeb3ad65bc294d29da7e0f54f5fce8af51695b058ee5591d0b07abcb9` |
| `freeze_packet_v0_1/FF2_HEADERS_PROPOSED_v0_1.lean.txt` | `b4484f6e148291dd20512e58ce4ec81b4bdf08527f4bd66b3e304cbb2654785a` |
| `FF2_FREEZE_DECISION_v0_1.md` | `3a5250764f4ab8a6ed998fb6c8ee403beab0d8798286bab97813205dc67e9d76` |
| `batch07/producer_complete_v0_1/src/FVLTAtomSkinDataV1.lean` | `8d165af954019dd15fad6f7bf082922119d9364a3727fa59879d945fc5e8f085` |
| `batch07/producer_complete_v0_1/src/FVLTAtomSkinCountsV1.lean` | `57be30510d889b8921c3f5b474b9f892570ac19d9f1a556552504498acf8bad0` |
| `batch07/producer_complete_v0_1/src/FVLTAtomSkinPenV1.lean` | `62be605efe85fcfbded3f0419c124aa2f1f2f0a772669aa81448400ac116cccc` |
| `batch07/producer_complete_v0_1/src/FVLTPillowcaseDataV1.lean` | `b8a03b38d0e8a8defb68bc93701f9c6ded0a8ff8ce9e9c9f1af636790ce3bcd2` |
| `batch07/producer_complete_v0_1/src/FVLTPillowcaseV1.lean` | `27e7c00dcae05e2f7e93de3d79e8f56380a553b76c2848f919deb6a3f5d82a3f` |

The hash prefixes cited in the freeze and repair decisions (`8e108ff4`, `61ca7137`, `b4484f6e`, `a1ea047d`, `b8a03b38`, `3a525076`) equal these files.

## Scripts (finite evidence, not proof)

**`compare_statements_v0_1.cjs`** (`3b1ae7a8…`; output `compare_statements_v0_1.out.txt`, `b89928ed…`): **ALL OK.**
- All 28 delivered statements equal the frozen headers after whitespace normalisation, each in its frozen namespace.
- The proof modules contain no public declarations other than these 28.
- There are 98 private helpers: 29 in Counts, 39 in Pen and 30 in Pillowcase.
- No source has any `sorry`, `axiom`, `instance`, `attribute`, `notation`, `variable`, `set_option` or `native_decide` line.
- The `FVLT.AtomSkinV1` block is byte-equal to definitions v0.3. The `FVLT.PillowcaseV1` block is byte-equal to definitions v0.1, which is identical to v0.3 for that block.

**`mirror_check_v0_1.cjs`** (`82c71d6f…`; output `mirror_check_v0_1.out.txt`, `2e55694a…`; run with `9 6` on node v24.13.0): **2,153,901 checks, 0 failures.**
- The script is my own independent mirror of the definitions. It is not a copy of the producer's or skeleton's checker.
- It checks ω = 3…9 over every vertex, edge, square, state and sign.
- It checks Part B for a, b = 1…6 over a window of ±3 periods. For a, b ≤ 3 it also runs a literal pairwise search on `pillowRel`.
- It also checks properties of the definitions against the order's prose:
  - ∂ is a genuine 1-cycle (∂₁∂₂ = 0);
  - the boundary's support is exactly the four geometric face edges;
  - each edge's squares are the seat pairs {d−1,d} and {d,d+1};
  - each vertex has exactly ω squares;
  - each link edge has multiplicity one;
  - the class count is 2ab + 2.
- **Negative controls:**
  - Without ε(v), A4 fails (tested for ω = 3…6).
  - With the opposite sign, `pen_oriented_square` fails in every state.
- **Self-correction.** The first run reported 4536 failures, all in the two B2 `HasFixingHalfTurn` tags. My own search range for (i, j) was smaller than the point window. I widened the range, and the recorded output is the corrected run. This was not a defect in the sources.

## Targets

| # | Name | Module | Verdict | Scope note | Order |
|---|---|---|---|---|---|
| 1 | `vertex_count` | Counts | MATCH | 2^ω in ℕ. | §4 A1 |
| 2 | `edge_count` | Counts | MATCH | Edge = (lower vertex, direction), one representative per edge. | §3, A1 |
| 3 | `square_count` | Counts | MATCH | Square = (v, i) with i, i+1 ∉ v, one representative per square. | §3, A1 |
| 4 | `chi_formula` | Counts | MATCH | χ = V − E + F, computed in ℤ; no ℕ truncation. | A1 |
| 5 | `incident_pair_distinct` | Counts | MATCH | True because the seat indices prev d and d differ. That is the right reason, not a vacuous one. | A2 |
| 6 | `incident_pair_exhaustive` | Counts | MATCH | "Face of" is encoded as coefficient ≠ 0. This is faithful because a square's four boundary edges are distinct, so nothing cancels (checked). | A2 |
| 7 | `incident_square_count` | Counts | MATCH | Exactly two squares per edge. | A2 |
| 8 | `incident_direction_equiv` | Counts | MATCH | The incident edges at x are in bijection with Fin ω by direction. | §3 Link, A3 |
| 9 | `link_cycle` | Counts | MATCH | linkAdjacent equals the adjacency of C_ω on Fin ω. With #8, this gives the link ≅ C_ω as a simple graph. The relation form does not count edge multiplicity. Multiplicity one follows informally from A2's count, and the check confirms it. | A3 |
| 10 | `incident_coefficients_opposite` | Counts | MATCH | Not vacuous. It holds because of ε(v): the squares give −ε(v) and +ε(v). | A4 |
| 11 | `total_boundary_zero` | Counts | MATCH | ∂(Σ squares) = 0 in C₁. | A4 |
| 12 | `cube_edge_iff` | Counts | MATCH | The 1-skeleton is the full ω-cube graph. | A5 |
| 13 | `cube_connected` | Counts | MATCH | An explicit path exists between any two vertices. | A5 |
| 14 | `chi_even` | Counts | MATCH | | A6 |
| 15 | `genus_formula` | Counts | MATCH | Stated in ℤ. Integer division is exact because χ is even. This is a numerical invariant only. | A6 |
| 16 | `cube_genus_zero` | Counts | MATCH | The ω = 3 case. | A6 |
| 17 | `pen_adjacent_seat` | Pen | MATCH | d = b ± 1. The extra d ≠ b is redundant but harmless. | A7 |
| 18 | `pen_oriented_square` | Pen | MATCH | One square contains both edges, and both moves have directed coefficient = s × their ∂f coefficient. The equations are substantive: the directed coefficient is never 0, and the opposite-sign control fails. The square is unique. | A7 |
| 19 | `pen_return_four` | Pen | MATCH | The full state returns at step 4. | A8 |
| 20 | `pen_no_earlier_return` | Pen | MATCH | No return at k = 1, 2, 3. | A8 |
| 21 | `pen_four_corners` | Pen | MATCH | Finset equality with `corners f`, which has 4 elements, so the four visited vertices are distinct. | A8 |
| 22 | `pillowRel_equivalence` | Pillowcase | MATCH | The relation is the order's relation verbatim. The guards are not needed but are harmless. | §5, B1 |
| 23 | `key_classifies` | Pillowcase | MATCH | Stated for the arithmetic relation; the group reading was optional. No viewer bridge is claimed. | B1 |
| 24 | `halfTurn_not_identity` | Pillowcase | MATCH | Holds for every a, b, including the half-turn about (0,0). Weak by design. | B2 |
| 25 | `fixingHalfTurn_iff_multiples` | Pillowcase | MATCH | A supporting statement: the fixed points are exactly the half-turn centres (ia, jb). | B2 |
| 26 | `nonzero_translation_fixes_nothing` | Pillowcase | MATCH | The guards are needed here. | B2 |
| 27 | `fixingHalfTurn_iff_corner_class` | Pillowcase | MATCH | "Non-identity stabilizer" is carried by the order's own gloss ("some half-turn fixes it") together with #24 and #26. No formal stabilizer or group object is defined. | B2 |
| 28 | `four_corner_classes_distinct` | Pillowcase | MATCH | | B2 |

## Definitions

All reviewed definitions are **MATCH**. Points to note:

- **`boundary`**
  - It equals ε(v)·(e(v,i) + e(v∪i, i+1) − e(v∪(i+1), i) − e(v, i+1)) term for term.
  - It is a genuine cycle.
  - The ε factor is load-bearing for A4.
  - **Repair consequence.** `boundary` and `coefficient` are `noncomputable`, so they cannot be `#eval`-ed as certificates. The propositions themselves are unchanged.
- **`step`**
  - d = cyclicDir(b − signValue s · ε(w)) and the new state is (toggle w d, d). This matches §3.
  - The template (line 153) is outside the closed file list, so `step` was checked against the order's transcription only.
- **`cyclicDir` / `next` / `prev`.** `Int %` is Euclidean, so the residue lies in [0, ω).
- **`linkAdjacent`.** Its existential over squares forces {i, j} to be the seat pair of a square at x. It is a simple-graph relation.
- **`net` / `key`.** They follow the order's recipe step by step. Natural-number subtraction is safe under a, b > 0. The definitions themselves carry no guard, but every theorem does.
- **`genus`.** Integer division is exact because `chi_even` holds.
- **`Chain1`.** Only C₁ is a type. C₀ and C₂ are not defined, and no target needs them.
- **`Sign`.** `Fintype` was dropped from its deriving list; no statement needs it.
- **`HasFixingHalfTurn` and `corner`** are as the order states.

## Private helpers

All 98 helpers are `private`. Seven are private defs: `boxOrbit` (in both Counts and Pen), `parityBit`, `asPoint`, `residue`, `rawKey`, `decode` and `canonical`. No instances, attributes or notation are introduced, so no helper adds a public claim.

## Other observations

- **Stale comment.** The Data sources keep the definition file's comment "Proposed exact definition bytes … No target proof is present" outside the namespace. This is cosmetic.
- **Optional items not formalised.** The order's optional items are not formalised and not claimed: the prime labelling (divisor reading), the group-orbit reading and the viewer-string bridge. Part C is out of scope.
- **Limits of the standing.** The statements stay within the order's standing: an exact combinatorial certificate plus a numerical invariant, and statements about lattice points. They do not include a surface-classification, orbifold or covering theorem.
- **Not a substitute for the other checks.** This signoff does not replace the recompile, the kernel replay or the axiom audit.
