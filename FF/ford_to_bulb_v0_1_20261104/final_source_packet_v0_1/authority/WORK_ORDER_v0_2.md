# Work order: the Ford-to-bulb map (FF-4), v0.2

2026-11-04. Drafted by the skeleton seat (Claude Opus 5.5).
- **Successor of v0.1** (`WORK_ORDER_v0_1.md`, `cbfa51a7322e85766605ca4ca7cfbd4a4fb5129ba7f5d48aaeb88a11864393e9`, unchanged; #1555).
- **Incorporates the owner's design review** (ACCEPT WITH CHANGES, #1558): `owner_review_v0_1/REVIEW_v0_1.md` (`523f4f6d…`) and `owner_review_v0_1/C1_PROOF_ROUTE_v0_1.md` (`c32d835e…`), both matched by skeleton.
- **saphir's FF-4 go** was relayed firsthand in #1557. It authorizes the review workflow; it does not accept a draft, freeze or runner in advance.

**Status:** corrected order for owner acceptance. No preregistration, freeze or build happens until the owner accepts this exact order. The definitions, public headers, runner and template then go to skeleton's freeze review.

## What changed from v0.1 (owner corrections 1–8)

1. **Cycle wording.** θ⁻ and θ⁺ are two points of one q-point cycle; they are not themselves an orbit. Exact period (B2) and common-cycle membership (B3) are now separate statements.
2. **Explicit domains.**
   - Every statement binds p, q with 0 < p < q and gcd(p, q) = 1.
   - Digits are indexed by Fin q (i, with j = i + 1, weight 2^{q−1−i}).
   - q ≥ 2, M > 0 and 0 < N⁻ < N⁺ < M are proved.
   - The minus digit is computed only after proving j·p ≥ 1.
   - Ψ is undefined at 0 and 1.
3. **What is mapped.**
   - A reduced Ford address is mapped to an exact rational angle pair.
   - The primary domain is the guarded record (p, q, guards), with a proved bridge to the canonical rational p/q.
   - [θ⁻, θ⁺] is called the **combinatorial angle interval**, not the complex-plane wake.
   - Nothing is mapped from complex points or from points of a Ford circle.
4. **Cyclic order, rank and gaps.**
   - Rank is defined on the orbit's distinct-point set in [0, M).
   - The orbit is proved to have q distinct points before rank is used.
   - The rank shift is stated modulo q, including the return edge.
   - All q directed gaps are defined, including the wrap gap M + first − last.
   - B5 names the ordered edge N⁻ → N⁺.
5. **C1 stays general;** C2 is guarded. C1 is kept for all reduced fractions in (0, 1), with no narrowing at proof time. C2 requires both endpoints in Ψ's domain and states both strict separations.
6. **C3 includes its equality case.** It is stated on canonical rationals, uses no private FF-3 API, and gets its own equality proof.
7. **A1 is split.** The polynomial fixed-point identity, the quadratic multiplier identity and the primitive-root claim are three statements. "Parabolic" is used only as cited interpretation, under Milnor's convention.
8. **B6 is deferred** out of this execution scope. No statement assumes uniqueness.

## 1. Purpose

saphir's observation: the fraction fan maps the Mandelbrot bulbs, which sit on the main cardioid in Farey order.

This order formalizes the **combinatorial side** as exact, finite statements. Ψ sends a reduced Ford address p/q ∈ (0, 1) to an exact rational angle pair (θ⁻, θ⁺). The order proves:
- both angles lie on one period-q cycle of doubling t ↦ 2t mod 1, with rotation number p/q;
- the ordered edge θ⁻ → θ⁺ is the cycle's unique gap of length 1/(2^q − 1);
- the combinatorial angle intervals are ordered like the fractions and respect mediants.

By a classical theorem (Milnor, *Periodic Orbits, External Rays and the Mandelbrot Set*, Thm 3.1; Douady–Hubbard; Goldberg 1992), the corresponding parameter rays land at the root of the p/q bulb. **That landing theorem, the wake and any limb geometry are cited, not formalized.** A precise main-cardioid identification of this digit rule with the characteristic ray pair is documented separately before any external caption claims it.

## 2. Governing inputs

| Input | Pin |
|---|---|
| Owner design review and C1 route | `owner_review_v0_1/REVIEW_v0_1.md` `523f4f6d…`; `C1_PROOF_ROUTE_v0_1.md` `c32d835e…` |
| Evidence | `SAGE_EVIDENCE_v0_1.md` `9708a994…`; `SAGE_EVIDENCE_v0_2.md` (this revision's architecture checks) |
| Shared library | the latest at FF-4's own input freeze: v23 now, re-verified then. FF-3's v22 binding and runner are **not** reused. |
| FF-1 `fareyAdj`, `det`, `adjacent_mediant`, `mediant` | in the library's `theorems/` |
| Toolchain, Mathlib, checker | re-observed at the input freeze |

## 3. Definitions (proposed; exact forms are frozen at signature review)

The domain is a record (p, q) with 0 < p < q and Nat.Coprime p q. Write M = 2^q − 1.

- **Mechanical words.** For u ∈ Fin q, W(u) := Σ_{i<q} d_i · 2^{q−1−i}, with d_i = 1 iff ((u + i·p) mod q) ≥ q − p.
- **Characteristic numerators.** N⁺ := W(p) and N⁻ := W(p − 1). Equivalently, by digits: b⁺_j = 1 iff (j·p mod q) ≥ q − p, and b⁻_j = 1 iff ((j·p − 1) mod q) ≥ q − p, for j = 1…q.
- **Angles.** θ^± := N^± / M ∈ ℚ.
- **The map.** Ψ(p, q) := (θ⁻, θ⁺). There is a bridge lemma to the canonical rational p/q (reduced, den = q).
- **Doubling on numerators.** k ↦ 2k mod M. The orbit set is O := {2^i·N⁺ mod M : i < q}.
- **Rank.** rank(x) := #{y ∈ O : y < x}.
- **Directed gaps.** List O in increasing order as x_0 < … < x_{q−1}. The gaps are x_{i+1} − x_i for i < q − 1, plus the wrap gap M + x_0 − x_{q−1}.
- **Complex algebra (A1).** For λ ∈ ℂ: root(λ) := λ/2 − λ²/4 and α(λ) := λ/2. For the exponential specialization, λ_{p/q} := exp(2πi·p/q) with the p, q guards bound.

## 4. Statements to prove

All statements are for the guarded domain unless stated otherwise.

| # | Statement |
|---|---|
| A1a | **Fixed point.** For every λ ∈ ℂ: α(λ)² + root(λ) = α(λ). |
| A1b | **Multiplier.** For every λ ∈ ℂ: the derivative of z ↦ z² + root(λ) at α(λ), namely 2·α(λ), equals λ. |
| A1c | **Primitive root.** λ_{p/q} is a primitive q-th root of unity. (The "parabolic" reading is cited interpretation, not formalized.) |
| B0 | **Bounds and words.** q ≥ 2, M > 0, N⁻ = W(p−1), N⁺ = W(p), and 0 < N⁻ < N⁺ < M. |
| B1 | **Adjacent.** N⁺ = N⁻ + 1, so θ⁺ − θ⁻ = 1/M. |
| B2 | **Exact period.** For N ∈ {N⁻, N⁺}: 2^q·N ≡ N (mod M), and 2^k·N ≢ N (mod M) for 0 < k < q. |
| B3 | **Common cycle.** N⁻ ∈ O. Equivalently, N⁻ = 2^i·N⁺ mod M for some i < q. |
| B4 | **Rank and rotation.** O has exactly q elements; O = {W(u) : u < q} with rank(W(u)) = u; and doubling sends W(u) to W((u + p) mod q), so rank(2x mod M) ≡ rank(x) + p (mod q) for every x ∈ O, including the return edge. |
| B5 | **Unique unit gap.** Among the q directed gaps, including the wrap gap, the ordered edge N⁻ → N⁺ is the unique one of size 1. All others are at least 2. |
| C1 | **Order.** For reduced p/q < p′/q′, both in (0, 1): θ⁺(p/q) < θ⁻(p′/q′). The combinatorial angle intervals are disjoint and ordered like the fractions. |
| C2 | **Mediant.** For Farey neighbours x < y (FF-1 `fareyAdj`) with x, y ∈ (0, 1) in Ψ's domain, and m = mediant(x, y) (reduced by FF-1): θ⁺(x) < θ⁻(m) and θ⁺(m) < θ⁻(y). |
| C3 | **Smallest denominator, with equality case.** For canonical rationals x < y with fareyAdj x y, and x < z < y: x.den + y.den ≤ z.den, with equality iff z = mediant(x, y). Proved here, with its own helper, and no private FF-3 API. |
| B6 | **Deferred.** The uniqueness of the rotation-p/q cycle (Goldberg) is outside this order. It may get its own order, freeze and go later. |

## 5. Proof architecture (owner design; paper plan, not a Lean result)

- **Mechanical-word layer.**
  - **Prefix counts.** These are S⁺(n) = ⌊(n+1)p/q⌋ and S⁻(n) = ⌊((n+1)p − 1)/q⌋, by telescoping floor increments. Digit = floor difference; these are proved in ℕ, never via truncated-subtraction ring steps.
  - **Order of the words.** For u < v, the prefix counts are weakly ordered, and coprimality gives a strict witness. A first-difference binary lemma then gives W(u) < W(v).
- **B1–B5 from the words.**
  - Doubling is a cyclic left shift, sending W(u) to W(u + p).
  - B1: the two digit words differ only in their final two digits, 01 against 10.
  - B5: W(u) is odd exactly when u < p. The single odd-to-even transition is the unit gap; within each block, gaps are at least 2; and the wrap gap is at least 2 because 0 < W(0) and W(q−1) < M.
- **C1 from a common length.**
  - Compare the words at the common length L = q·q′. Prefix domination gives S⁺(p/q; n) ≤ S⁻(p′/q′; n) for all n.
  - The total counts p·q′ < p′·q give a first differing bit, and the first-difference lemma gives R⁺ < R⁻.
  - The geometric identities R·(2^q − 1) = N·(2^L − 1) return to the angles. No real infinite series and no binary-expansion ambiguity are involved.
- **A skeleton aside (non-binding).** The same facts can be read as one staircase, S(ρ) = Σ 2^{−k}⌊kρ⌋, with θ⁺ = S(p/q), θ⁻ = S(p/q⁻), and a jump of 1/M. See `C1_PROOF_ROUTE_NOTE_v0_1.md` (`992cc86f…`). The owner's finite route is preferred for Lean.
- **Suggested groupings** (not frozen names):
  - domain, digits and angles;
  - generic finite-word lemmas;
  - cycle, rank and gaps (B0–B5);
  - order and mediants (C1–C3);
  - complex algebra (A1), kept separate from the computable definitions.

## 6. Not claimed

- **Analytic statements.** Parameter-ray landing, the complex-plane wake, limb geometry, the dynamics of attracting cycles, bulb sizes, MLC, density of hyperbolicity and renormalization are all cited or excluded, never formalized. The polynomial fixed-point and multiplier facts of A1 are the only complex statements, and they are formalized.
- **B6.** It is deferred and never assumed.
- **Rule 30.** The kit's equivalents entry [10] states Problem 1 via the same doubling map. This is a shared-vocabulary link only: FF-4 says nothing about x₂.
- **No other changes:** no viewer, kernel, commit, release or sync follows from this order.

## 7. Evidence (exact, finite; not proofs)

- **v0.1 checks** (`SAGE_EVIDENCE_v0_1.md`):
  - A1 holds for 45/45 pairs with q ≤ 12;
  - B1–B5 hold for 79/79 pairs with q ≤ 16;
  - B6 holds for 45/45 pairs with q ≤ 12;
  - C1 holds for 78/78 consecutive pairs;
  - C2 and C3 hold for 50/50 Farey-neighbour pairs.
- **v0.2 architecture checks** (`SAGE_EVIDENCE_v0_2.md`; Sage 10.9, session `9c1ecadc…`):
  - N⁻ = W(p−1) and N⁺ = W(p): 101/101 pairs (q ≤ 18);
  - W strictly increasing: 101/101;
  - doubling W(u) → W(u+p): 101/101;
  - bounds: 101/101;
  - W(u) odd iff u < p: 101/101;
  - B5 with all directed gaps, including the wrap: 101/101;
  - prefix-count formulas: 3,726/3,726 each;
  - C1 prefix domination at L = q·q′: 990/990 ordered pairs (q ≤ 12);
  - the common-length comparison with its angle identities: 990/990;
  - C3 bound: 1,719/1,719;
  - C3 equality case: 1,719/1,719.
- **Staircase route checks:** θ^± = S(·), and the jump, for 127/127 pairs (q ≤ 20).
- **The two discarded v0.1 digit rules** are provenance, not counterexamples to the current rule.

## 8. Gates (requested explicitly for FF-4; not inherited by default)

- **Freeze review.** An input freeze on the then-latest library, with full checksums, read-only state, toolchain, Mathlib, checker and the actual import closure. A signature freeze of the exact definitions and public headers. A fresh FF-4 runner and template, with a closed input packet, for skeleton's review.
- **Policies, requested for FF-4's own decision:**
  - all-match binding accepted on posting;
  - proof-only retries in fresh additive attempts;
  - any definition or header change, wrong axioms, genuine replay failure or scope change returns for review.
- **Execution limits:**
  - one CPU, 8 GiB, `-j1 -s65536 -M7680`, 240 s per child;
  - 1800 s batches with clocks started before proof writing;
  - exact jobs posted before launch;
  - strict named-axiom parsing and strict replay of all introduced constants;
  - nucleus only, with scout and membrane as backups and no compute on Neo; G1 excluded.
- **Final.** Skeleton's independent clean rebuild and replay, then a separate fidelity review.
- **After PASS.** Library sync, under saphir's standing rule.

**Prior art.**
- Milnor, *Periodic Orbits, External Rays and the Mandelbrot Set*;
- Goldberg (1992), on rotation subsets;
- Bullett–Sentenac (1994);
- Douady–Hubbard;
- Devaney (1999).

The kit and `submissions.json` have no Mandelbrot, bulb, ray or Farey material. No novelty claim.

**Credit.** The observation that the fraction fan maps the bulbs, and the instruments: saphir. The design review, the C1 route and the proof architecture: the formalization owner. This draft: skeleton (Claude Opus 5.5). "The framework was assembled by Robin Miller; its components are classical results of others."
