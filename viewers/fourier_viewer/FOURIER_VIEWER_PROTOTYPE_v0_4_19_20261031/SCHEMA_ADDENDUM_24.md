# SCHEMA ADDENDUM 24 (v0.4.17, 2026-10-29): group D exact, two display-only Panels cards

No change to the state schema (`fv-comb-hopf-state/0.2`), the exact export, the Lift JSON, the address id (`fv-comb-hopf/0.2`), the PNG export or any readout of an existing state. The two cards hold their own dials in the module `instruments/comb-hopf/panel-elliptic.js` (global `FVEllipticCards.S`); they read nothing from the host model and write nothing (panel rule R9). saphir: **"No floating point"**.

## 1. Registers

- **Exact register: BigInt.** Integers, exact rationals `{num, den}` (BigInt, den > 0, reduced), residues mod p (BigInt, canonical in [0, p)). Used for curves, invariants, points, the five-case addition table, [k]P, reduction mod p, enc, a_p by both routes, reduction types, the cubic 4x³ + b2x² + 2b4x + b6 and its Sturm sequence.
- **Numerical register with guarantees: interval enclosures.** Every real quantity of the period card is a dyadic interval [lo, hi]·2^−W with BigInt lo, hi, rounded outward at every step. A printed digit string shows only the places on which round-half-up of lo and of hi agree (at most D), so the true value rounds to it; the width is printed as `width = n·2^−W ≤ 10^−k`.
- **Drawing register: canvas pixels.** Integers obtained by BigInt arithmetic and handed to canvas by the single helper `px` (BigInt → Number, the only `Number(...)` call in the new files). Canvas transforms, dash patterns and line widths are small integer constants.

## 2. Modules

- `host-core/elliptic-exact-core.js` (fv-elliptic-exact-core 0_1_0, global `FVEllipticExact`). Fields `FQ` and `Fp(p)` (inverses by the extended Euclidean algorithm). `curve(ainvs, F)` with b2, b4, b6, b8, c4, c6, Δ. O is `{inf: true}`; affine points `{inf: false, x, y}`. `neg`: −(x, y) = (x, −y − a1x − a3). `add(E, P1, P2)` returns `{R, case, key, index, lambda?, nu?}`; `caseOf` evaluates the five conditions and throws unless exactly one holds. `doublingLambda` refuses at 2-torsion. `mul(E, k, P)` (left-to-right double-and-add, every step with its case). `reduce`, `enc`, `points`, `singularPoints`, `apNaive` (route i), `apCharSum` (route ii, Jacobi reciprocity), `reductionType` (tangent cone at the singular point), `changeModel` / `mapPoint` (Sage's (u, r, s, t) convention), `order`, `cyclicWitness`.
- `host-core/elliptic-period-core.js` (fv-elliptic-period-core 0_1_0, global `FVEllipticPeriod`). `periods(ainvs, D)` → record (§4). Δ < 0 → `{refused: true, label: "Δ < 0: not implemented in the exact register"}`; Δ = 0 → refused as singular.

## 3. Card "Elliptic points (exact)" (id `elliptic-points-exact`, group D, collapsed: true)

State `{k: BigInt 1…20 (5), p: BigInt prime < 100 (5), i1, i2: indices into E_ns(F_p) (−1 = P mod p)}`. Shows: curve data; kP and the trace table (step, operation, case, result); the E(F_p) scatter on a p × p grid with O as a diamond outside the grid, P1 amber, P2 violet, P1 + P2 green; at p = 37 the singular point (5, 18) in red with its reduction type; P1 + P2 with the five-case table (active row `data-active="1"`); the enc collision count; the a_p table (p, #E, a_p (i), a_p (ii), agree, reduction).

## 4. Card "Period lattice (exact intervals)" (id `period-lattice-exact`, group D, collapsed: true)

State `{curve: "37a1" | "11a1" ("37a1"), D: BigInt 10…100 (50)}`. W = ⌈33220·D/10000⌉ + 48 bits. Record: `e1, e2, e3, sqrt13, sqrt12, sqrt23, pi, agm1, agm2, w1, w2_over_i, tau_over_i, Omega`, each `{digits, places, width, width_pow10, width_ulps, lo, hi, W}`; `agm*.steps[n] = {n, a, b}`, `agm*.bound` (the stop rule: a_n.hi − b_n.lo ≤ 16·2^−W, and b_n ≤ M ≤ a_n for every n, so M ∈ [b_N.lo, a_N.hi]); `omega_reason` (Δ > 0: E(ℝ) has two components, Ω = 2ω1); `lattice` (rectangular). ω1 = π/AGM(√(e1−e3), √(e1−e2)), ω2/i = π/AGM(√(e1−e3), √(e2−e3)), τ/i = ω2/(iω1), π by Machin with a term-count error bound. The cell drawing uses the lower endpoints of ω1 and ω2/i.

## 5. Not claimed

Nothing about ECDL or BSD. The points card is a finite exact readout for one curve; the period card's digits are guaranteed only in the sense of §1 (the enclosures are rigorous given correct BigInt arithmetic).
