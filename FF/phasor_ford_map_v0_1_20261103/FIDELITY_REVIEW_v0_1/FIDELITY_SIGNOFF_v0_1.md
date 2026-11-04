# FF-3 statement-fidelity signoff v0.1

2026-11-04. Reviewer: independent fidelity reviewer subagent, Claude Opus (Claude Opus 5.5), spawned by skeleton 2026-11-04.

**Result: PASS (meaning only).**
- All 37 targets: MATCH.
- All 19 data definitions: MATCH.
- Against `WORK_ORDER_v0_2.md` §3–§6, with the M1–M4 corrections.

This is the meaning review only. Final FF-3 PASS also needs the auditor's independent rebuild, named-axiom report and strict replay. I ran no Lean and used no network. I wrote only inside this folder.

The machine-readable record, with the SHA-256 of every reviewed file, is `FIDELITY_SIGNOFF_v0_1.json`.

## Mechanical findings

- **Statements.** The delivered sources contain exactly 37 public theorems: Phase 5, Arithmetic 15, Sweep 9, Endpoints 8.
  - Each is identical, after whitespace normalization, to its frozen header in `b8a052dc…`.
  - Each sits in its declared module.
  - There are no extra public theorems (`statement_compare.cjs`).
- **Data module.** `FVLTRosetteFordDataV1.lean` is byte-identical to the accepted successor `FF3_DEFINITIONS_PROPOSED_v0_2.lean.txt` (`02814fa1…`). It has 19 declarations.
  - The v0.2 repair only annotates `m : ℕ` in `fareySet` and `shellEvents`.
  - That is the type both definitions meant. No meaning changed.
- **Private helpers.** There are eight, all `private theorem`:
  - Arithmetic: `raw_normalization`, `gcd_nonzero`, `product_one_iff`.
  - Sweep: `unit_numerator`, `raw_den_bound`, `bounded_bezout`, `interval_denominator_bound`, `exists_bounded_successor`.

  Each is an auxiliary arithmetic or order fact. None is exported, none adds a public claim, and none carries Lemma 6a content.
- **Imports.**
  - Data imports the FF-1 modules `FVLTFareyArithmeticCompletionV1` and `FVLTFordExactCoordinatesV1`, plus three Mathlib modules.
  - Phase, Arithmetic and Endpoints import only Data.
  - Sweep imports Phase and `Mathlib.Data.Int.GCD`.

  No delivered source contains `sorry`, `axiom`, `opaque`, `native_decide`, `set_option` or `variable`.
- **Lemma 6a** is not assumed:
  - it is not imported and not named;
  - P5 (iii) is proved inside the Sweep module from bounded Bézout plus the mediant denominator bound;
  - Lemma 6a is a markdown candidate, not a Lean module.
- **No arcs, no inversion.**
  - No statement constructs, orients or parameterizes an arc.
  - No statement recovers an address from a phasor value.
  - The only statement from phasor to address is the M3 non-descent example.

## Computational evidence (finite, not proof)

**Positive run.** `semantic_check.cjs` mirrors the FF-3 v0.2 and inherited FF-1 definitions in exact BigInt rationals with Lean semantics: reduced, den > 0, x/0 = 0.
- Result: **939,644 checks across all 37 statements, 0 failures** (`semantic_check_output.json`).
- Rows marked [float] are the phase statements. They reduce the rational address mod 2 exactly, then use floating-point sin/cos.
- At B = 40 there are 860 shell events, 491 deduplicated addresses, and |F₄₀| = 491. This matches §7 of the order.

**Negative controls.** These show the script can fail (`semantic_check_negative_output.json`): **76,957 checks, 25,393 failures.**

| Control | Failures |
|---|---|
| NC1: v0.1 column law without `abs` (M2) | 13,350 |
| NC2: `shellEvents` with m ≤ N | 36 |
| NC3: tangent tested as \|det\| = 2 | 778 |
| NC4: parity identity without the (−1)^{t₁s} factor | 4,752 |
| NC5: phase law at r = 0 (shows the r ≠ 0 guard is needed) | 80 |
| NC6: shell parameterization for s < 0 (shows the s ≥ 0 guard is needed) | 21 |
| NC7: unreduced instead of reduced determinant | 6,376 |

## Specific questions answered

- **Integer `/` in `reduced_det_quotient`.** Lean's ℤ `/` is Euclidean division.
  - The divisor g(a,q)·g(c,r) ≥ 1 because q, r > 0.
  - `reduced_det_mul` shows the numerator is an exact multiple of it.
  - So the quotient equals the rational quotient, and no truncation occurs. The quotient form is stated after the multiplication form, as the order requires.
- **ℚ.num and ℚ.den in `det`.** FF-1 `det x y = x.num·y.den − y.num·x.den` is taken on the reduced fraction, which is what P2 means by "determinants of the reduced fractions". NC7 confirms the reduced and unreduced versions differ.
- **The M2 sign.** `signed_column_law` has right side `|u|` for every u : ℤ. Quantifying over all u : ℤ is the same set as u = t₂s.
- **The phase law.**
  - `phasorValue = (r : ℂ) * Complex.exp (((π * a : ℝ) : ℂ) * I)` is z₁ = r·e^{iπa}.
  - `(-1 : ℂ) ^ (t1 * s)` is `zpow` with an integer exponent. Negative exponents give the same sign.
  - The parity identity is stated only for s : ℤ.
- **`IsIntegral` shadowing.** `FVLT.PhasorFordV1.IsIntegral x := ∃ k : ℤ, x = k`.
  - Mathlib's root `IsIntegral` takes a ring type as its first explicit argument, so `IsIntegral (q : ℚ)` cannot elaborate to it.
  - Inside the namespace, the local name is the one used.
  - Even `IsIntegral ℤ x` would be equivalent on ℚ, because ℤ is integrally closed.
  - So there is no meaning change. Advisory: a downstream file that opens this namespace could see a name ambiguity.
- **Guards.** Every guard is satisfiable and within the order's domain, so no statement is vacuous. Some guards are not needed for truth but are harmless:
  - `hn3` in the phase statements; the order's domain has 0 < n₃ anyway.
  - `1 ≤ B` in the Sweep membership statements; B = 0 is the empty case.
  - `hk0` in `farey_consecutive_det`, which `hk1` implies.

  Guards that are needed, as NC5 and NC6 show: r ≠ 0, and 0 ≤ s ≤ N.

## Target verdicts

| # | Module | Target | Verdict | Order locator / note |
|---|---|---|---|---|
| 1 | Phase | phasor_real_iff | MATCH | §3 phase law; r ≠ 0 explicit |
| 2 | Phase | integer_spin_phase_iff | MATCH | §3 integer-spin specialization (a ∈ ℤ ⇔ x ∈ ℤ) |
| 3 | Phase | integer_spin_parity | MATCH | §3 e^{iπa} = (−1)^{t₁s} e^{−iπx}, s : ℤ only |
| 4 | Phase | circleMap_amplitude_independent | MATCH | §3 Φ = C(x); true by definition, which is the intended content (independent of r and t₁) |
| 5 | Phase | phasor_alias_not_address_alias | MATCH | §3 / M3 example exactly |
| 6 | Arithmetic | integer_address_iff | MATCH | P1 |
| 7 | Arithmetic | integer_address_integral_iff | MATCH | P1, §3 |
| 8 | Arithmetic | integer_address_radius | MATCH | §3 radius 1/2 |
| 9 | Arithmetic | divisor_recovery_window | MATCH | P1 window, s > 0 |
| 10 | Arithmetic | zero_spin_address | MATCH | P1 s = 0 separate |
| 11 | Arithmetic | zero_spin_window | MATCH | P1 s = 0 separate |
| 12 | Arithmetic | reduced_det_mul | MATCH | P2 multiplication form |
| 13 | Arithmetic | reduced_det_quotient | MATCH | P2 corollary; exact ℤ division |
| 14 | Arithmetic | row_law | MATCH | P3 |
| 15 | Arithmetic | row_tangent_iff | MATCH | P3 tangent iff |
| 16 | Arithmetic | signed_column_law | MATCH | P4 with \|u\| (M2) |
| 17 | Arithmetic | signed_column_tangent_iff | MATCH | P4 tangent iff |
| 18 | Arithmetic | zero_column_stall | MATCH | P4 stall at u = 0 |
| 19 | Arithmetic | reference_column_tangent_iff | MATCH | P4 reference s ∣ n(n+1) |
| 20 | Arithmetic | unit_fraction_spine | MATCH | P4 s = 1 spine |
| 21 | Sweep | shell_contact_parameterization | MATCH | P5 (i) |
| 22 | Sweep | shell_phasor_contact_iff | MATCH | P5 (i), nonzero amplitude |
| 23 | Sweep | shell_contact_address | MATCH | P5 (i) x = m/(N−1) |
| 24 | Sweep | mem_shellEvents | MATCH | P5 events = the order's events; 1 ≤ B harmless |
| 25 | Sweep | mem_fareySet | MATCH | P5 (ii) F_B |
| 26 | Sweep | shell_addresses_eq_farey | MATCH | P5 (ii), deduplicated set only |
| 27 | Sweep | fareyList_membership | MATCH | P5 (iii) |
| 28 | Sweep | fareyList_strict | MATCH | P5 (iii) strict |
| 29 | Sweep | farey_consecutive_det | MATCH | P5 (iii) b·c − a·d = 1, signed form |
| 30 | Endpoints | det_zero_iff_address_equal | MATCH | P4 and P6 stall |
| 31 | Endpoints | classify_stall_iff | MATCH | P6 |
| 32 | Endpoints | classify_tangent_iff | MATCH | P6 |
| 33 | Endpoints | classify_break_iff | MATCH | P6 break, with \|det\| ≥ 2 label (gap = break) |
| 34 | Endpoints | path_edge_trichotomy | MATCH | P6 exactly one; §5 indexing (Fin m edges, Fin (m+1) circles) |
| 35 | Endpoints | path_kind_tangent_iff | MATCH | P6, per-edge only (§5) |
| 36 | Endpoints | tangent_endpoint_certificate | MATCH | P6 kissQ plus boundaryCheckQ on both circles |
| 37 | Endpoints | nontangent_no_certificate | MATCH | P6, certificates only on tangent edges |

## Definition verdicts

All 19 definitions are MATCH:
- LiftedData
- fordAddress
- phaseAddress
- IsIntegral
- phasorValue
- liftedPhasor
- circleMap
- gcdFactor
- integerContactWindow
- divisorWindow
- fareySet
- shellEvents
- shellEventAddresses
- fareyList
- EdgeKind
- IsBreak
- classifyEdge
- pathEdgeKind
- endpointCertificate

Notes:
- **circleMap** is the F1 Ford circle boundary at the reduced address: centre x + i/(2q²), radius 1/(2q²).
- **IsIntegral:** shadowing advisory only, as above.
- **EdgeKind:** `gap` is the order's "break".
- **IsBreak:** its conjunct `2 ≤ |det|` is implied by the other two. Including it makes the order's label part of the predicate.
- **liftedPhasor** is not used by any target and carries no claim.
- **shellEvents** keeps the events of different shells distinct as pairs. That gives 860 at B = 40, the order's raw count, which is not claimed to be Farey.

## Advisories (not defects)

1. **IsIntegral.** Its name shadows Mathlib's root `IsIntegral`. There is no meaning change. A rename would be a definition change, and none is requested.
2. **Unneeded guards** (`hn3` in the phase statements, `1 ≤ B`, `hk0`) are harmless.
3. **Prose.** A later write-up should say that `EdgeKind.gap` is the order's "break".
