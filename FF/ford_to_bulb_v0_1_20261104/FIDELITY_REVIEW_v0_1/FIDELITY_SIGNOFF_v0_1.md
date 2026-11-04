# FF-4 statement-fidelity review v0.1

**Reviewer:** independent fidelity reviewer subagent, Claude Opus, spawned by skeleton 2026-11-05 (model `claude-opus-5-5`). The local machine date during the review was 2026-11-04.

**Scope:** meaning only. I read each of the 33 frozen public statements together with the 31 frozen data declarations and the inherited FF-1 definitions (`det`, `fareyAdj`, `rawValue`, `mediant`), and compared them with `WORK_ORDER_v0_2.md`. Compilation, axioms and replay are the auditor's job. No Lean was run, no network was used, nothing was posted, and no existing file was modified.

**Result: PASS.**
- 33/33 targets: MATCH.
- 31/31 data declarations: MATCH.
- No TRANSLATION_DEFECT, NARROWER_THAN_SOURCE, PROSE_CORRECTION_CANDIDATE or UNRESOLVED verdict.
- Three advisory notes, listed below.

The machine-readable version is `FIDELITY_SIGNOFF_v0_1.json`, which also holds the SHA-256 of every reviewed file.

## Source state

- `FVLTFordBulbDataV1.lean` is byte-identical to `FF4_DEFINITIONS_PROPOSED_v0_1.lean.txt` (`19fcd5d3…`).
- **Public headers:** all 33 delivered headers equal the frozen headers after whitespace normalization (Combinatorics 29, Parameter 4). There are no extra public declarations. A negative control that mutated one frozen header was detected.
- **Private helpers:**
  - Combinatorics has 44: binary_block_rec, raw_digit_carry, raw_digit_prefix_count, raw_digit_full_count, binary_count_bounds, nondividing_pred_quotient, characteristic_prefix_counts_equal, characteristic_early_digit_equal, characteristic_early_block_equal, characteristic_final_digits, rational_cross_strict, farey_oriented_unit, farey_interval_frame, positive_frame_bound, positive_frame_unit, raw_digit_le_one, binary_equal_count, binary_prefix_equal, phase_block_monotone, coprime_phase_surjective, raw_digit_step, block_prepend, block_phase_mod, raw_digit_period, iterate_num_succ, phase_iteration, coprime_shift_surjective, no_short_word_period, phase_last_digit, word_parity, ordered_word_at, edge_start_word, edge_end_nonwrap, edge_end_wrap, cross_binary_equal_count, cross_block_monotone, address_cross_lt, ordered_prefix_counts, full_count_multiple, ordered_common_blocks, block_concat, block_period_start, modulus_cast, repetition_cross.
  - Parameter has none.
- **Extra imports in the proof modules:** `Mathlib.Data.Nat.ModEq` in Combinatorics and `Mathlib.Analysis.Calculus.Deriv.Add` in Parameter. Neither changes any meaning.
- **Text search:**
  - No `sorry`, `admit`, `axiom` or `native_decide` occurs. This search does not replace the axiom report.
  - None of Goldberg, landing, ray, wake, limb, Rule 30, attracting, parabolic, B6 or Mandelbrot occurs.
- The inherited FF-1 sources are byte-identical to the freeze-packet copies. Pins: Contact `2760392f…`, ArithmeticCompletion `01abe886…`.

## Targets

| # | Target | Order item | Verdict | Note |
|---|---|---|---|---|
| 1 | address_canonical | §3 bridge | MATCH | num = p, den = q |
| 2 | address_interval | change 2 | MATCH | 0 < p/q < 1, so there is no endpoint value |
| 3 | address_injective | §3 | MATCH | Equal addresses give equal records (the proof fields are Props) |
| 4 | address_surjective | §1, C1 domain | MATCH | Every rational in (0,1) is an address |
| 5 | q_at_least_two | B0 | MATCH | |
| 6 | modulus_pos | B0 | MATCH | |
| 7 | word_sum | §3, change 2 | MATCH | Fin q sum with weight 2^(q−1−i); the reversed-weight control fails here |
| 8 | upper_digit_equiv | §3 b⁺_j | MATCH | j = i+1 |
| 9 | lower_digit_equiv | §3 b⁻_j, change 2 | MATCH | Proves 1 ≤ (i+1)p before the subtraction; the data uses u = p−1 with p ≥ 1 |
| 10 | word_bounds | B0, §5 B5 | MATCH | 0 < W(u) < M for every u; supports the wrap gap |
| 11 | characteristic_bounds | B0 | MATCH | N⁻ = W(p−1) and N⁺ = W(p) hold by definition |
| 12 | characteristic_adjacent | B1 | MATCH | |
| 13 | characteristic_angle_gap | B1 | MATCH | θ⁺ − θ⁻ = 1/M in ℚ |
| 14 | characteristic_period_return | B2 | MATCH | (2^q n) mod M = n, equivalent to the congruence since n < M |
| 15 | characteristic_period_minimal | B2 | MATCH | For 0 < k < q |
| 16 | same_cycle | B3 | MATCH | N⁻ ∈ O |
| 17 | word_strict | B4, §5 | MATCH | StrictMono W |
| 18 | orbit_set_eq | B4 | MATCH | O = W(Fin q) |
| 19 | orbit_card | B4, change 4 | MATCH | q distinct points |
| 20 | orbit_length | B4/B5 | MATCH | q edges |
| 21 | rank_word | B4 | MATCH | |
| 22 | double_word | B4 | MATCH | W(u) ↦ W((u+p) mod q) |
| 23 | rank_step | B4, change 4 | MATCH | Holds for every x ∈ O, so the return edge is included; the canonical residue ≡ the congruence since rank < q |
| 24 | unique_unit_gap | B5, change 4 | MATCH | Named edge N⁻ → N⁺ has gap 1; every other edge, the wrap edge included, has gap ≥ 2. The no-modulus control fails here |
| 25 | angle_order | C1 | MATCH | General over all addresses, with no narrowing |
| 26 | intervals_disjoint | C1 | MATCH | |
| 27 | mediant_interval | C2 | MATCH | Both endpoints are addresses; FF-1 `fareyAdj`; m is an address with address m = FF-1 mediant; both strict separations hold |
| 28 | farey_denominator_min | C3 | MATCH | Over all of ℚ (see advisory 1) |
| 29 | farey_denominator_eq_iff | C3 equality case | MATCH | Over all of ℚ; no FF-3 private API; the midpoint control fails here |
| 30 | parameter_fixed_point | A1a | MATCH | |
| 31 | parameter_multiplier | A1b | MATCH | An explicit 2α = λ, paired with a real derivative theorem |
| 32 | parameter_derivative | A1b | MATCH | `HasDerivAt f f' x` reads as (function, derivative, point): the derivative of z ↦ z² + root(λ) at α(λ) is λ; the swapped-reading control fails |
| 33 | canonical_multiplier_primitive | A1c | MATCH | `IsPrimitiveRoot (exp(2πi·p/q)) q`; the guards come from the record |

All 31 data declarations are MATCH; the per-declaration notes are in the JSON. Highlights:
- `edgeEnd` wraps to index 0.
- `directedGap` is `(M + x₀) − x_{q−1}` on the wrap edge and `x_{i+1} − x_i` elsewhere.
- `orbitSet` is the Finset of q iterates of N⁺.
- `rank` counts the points strictly below.
- `angleInterval` is a rational Icc, not the wake.

## Advisory notes (not defects)

1. **C3 is quantified over all of ℚ.** The C3 cell and owner item 6 say "canonical rationals" with no interval bound, so this is the literal statement. If one reads the table preamble's "guarded domain" as also governing C3, the Lean statement is a harmless generalization that implies the version restricted to (0,1). My evidence includes negative rationals and integers.
2. **No public target mentions `psi` by name.** The statements use `lowerAngle` and `upperAngle`, which are its components by definition. This is cosmetic.
3. **`directedGap` uses Nat subtraction.** It is inert:
   - the sorted list is strictly increasing;
   - x_{q−1} < M;
   - truncation could only shrink a gap, which would make B5's "≥ 2" clause harder, never vacuous.

## Scope confirmations

- B6 (Goldberg uniqueness) is absent.
- No ray landing, wake, limb, analytic dynamics or Rule 30 claim.
- C1 is general.
- C2 is guarded, with both separations.
- C3 has its equality case.
- A1 is split three ways, plus the derivative statement.

## Finite evidence (evidence, not proof)

`fidelity_check.cjs` mirrors the frozen definitions in BigInt and exact rationals, including Lean's truncated Nat subtraction.

**Coverage:**
- all 79 coprime pairs with 0 < p < q ≤ 16, for every per-address statement;
- C1 and C2 on all ordered pairs with q ≤ 12: 990 C1 pairs and 68 Farey-adjacent C2 pairs;
- C3 on all 409 rationals in [−2, 2] with denominator ≤ 18: 812 adjacent pairs, 2,860 (x, y, z) triples and 404 equality hits;
- A1c through the exact criterion q | kp ⇔ q | k, with a float cross-check of the exponential;
- A1a and A1b, and the `HasDerivAt` argument order, by float sanity checks on 200 sample values of λ.

**Baseline:** 17,432 checks over 34 check names, with 0 failures.

**Harness correction, disclosed.** My first baseline run failed 22 `mediant_interval` checks. The cause was the script, not the statement: it looked the mediant up only among addresses with q ≤ 16, while the mediants reach denominator 23. I fixed the lookup to build the address from the canonical mediant, and the rerun has no failures.

**Negative controls (each shows the script can fail):**

| Mutation | Failed checks | Failed targets |
|---|---|---|
| reversed bit weight 2^i | 2,883 | word_sum, characteristic_bounds/adjacent/angle_gap, word_strict, rank_word, unique_unit_gap, double_word |
| lowerIndex = p+1 | 905 | lower_digit_equiv, characteristic_*, unique_unit_gap, angle_order, intervals_disjoint, mediant_interval |
| wrap gap without M | 79 | unique_unit_gap |
| C3 equality with the midpoint instead of the mediant | 472 | farey_denominator_eq_iff |
| `HasDerivAt` read as (f′ = α, x = λ) | 200 | parameter_derivative |

`header_compare.cjs`: the baseline matches 33/33. Mutating the `rank_step` header is detected.

## Files

- `fidelity_check.cjs` and `check_{none,reversed_weight,lower_index_plus,wrap_no_modulus,c3_midpoint,swap_hasderiv}.json`
- `header_compare.cjs`, `header_compare_output.json` and `header_compare_negative_control.json`
- `build_signoff.cjs`, which writes the JSON signoff
