# Work order: the Ford-to-bulb map (FF-4), v0.1

2026-11-04. Drafted by the skeleton seat (Claude Opus 5.5) at saphir's request. The queue note is `QUEUED_FF4_FORD_TO_BULB_20261103.md` (`633ec404...`), and saphir's "Queue it after the kernel work is done" was followed by "alright lets go" once FF-1, FF-2 and FF-3 had passed.

**Status: draft for design review.** Nothing is preregistered, built or dispatched until the formalization owner accepts this exact order and saphir gives a separate execution go.

## 1. Purpose

saphir's observation: the fraction fan also maps the Mandelbrot set. The p/q bulbs on the main cardioid are arranged in Farey order.

This order formalizes the **combinatorial side** of that observation as exact rational and finite statements. It defines a map Ψ from a reduced fraction p/q (a Ford address, as in FF-1 and FF-3) to a pair of angles (θ₋, θ₊). It then proves the following:
- the two angles form a period-q orbit of the doubling map D(t) = 2t mod 1, with rotation number p/q;
- their arc is the orbit's unique shortest gap;
- Ψ respects Farey order and mediants.

By a classical theorem (Douady–Hubbard; Goldberg; Milnor), these are the angles of the two parameter rays landing at the root of the p/q bulb. **That landing theorem is cited, not formalized.**

## 2. Governing inputs

| Input | Pin |
|---|---|
| Evidence for this draft (Sage, exact) | `ford_to_bulb_v0_1_20261104/SAGE_EVIDENCE_v0_1.md` |
| Shared library, with FF-1 Farey/Ford, FF-2 and FF-3 | latest at the input freeze: v22, or v23 once READY |
| FF-1 `adjacent_mediant`, `fareyAdj`, `det` | in the library's `theorems/` |
| FF-3 `fareySet`, `fareyList`, `farey_consecutive_det` | FF-3 final PASS #1554 |
| Library, toolchain, Mathlib, checker | re-observed at this order's own input freeze |

## 3. Definitions (proposed)

For naturals with 0 < p < q and gcd(p, q) = 1, write M = 2^q − 1.
- **Digits.** For j = 1, …, q:
  - b⁺_j = 1 iff (j·p mod q) ≥ q − p;
  - b⁻_j = 1 iff ((j·p − 1) mod q) ≥ q − p.
- **Numerators.** N^± = Σ_j b^±_j · 2^{q−j} (naturals below M).
- **Angles.** θ^± = N^± / M ∈ ℚ, read as points of ℝ/ℤ. These are the repeating binary words b^±₁ ⋯ b^±_q.
- **Doubling on numerators.** k ↦ 2k mod M. The orbit of N is x_i = 2^i·N mod M, for i = 0, …, q−1.
- **Rank.** rank(x) is the number of orbit points strictly below x.
- **The map.** Ψ(p/q) := (θ⁻, θ⁺), defined for reduced p/q ∈ (0, 1). For p/q = 0/1 or 1/1 the cardioid cusp is not a bulb, so Ψ is undefined there.
- **Bulb root (complex).** For λ ∈ ℂ: root(λ) := λ/2 − λ²/4, and α(λ) := λ/2.

## 4. Statements to prove

All statements are for coprime 0 < p < q unless stated otherwise.

| # | Statement |
|---|---|
| A1 | **Root and multiplier.** For every λ ∈ ℂ: α(λ)² + root(λ) = α(λ), and the multiplier 2·α(λ) = λ. For λ = e^{2πi p/q}, λ is a primitive q-th root of unity, so α is a parabolic fixed point of z² + root(λ) with that multiplier. |
| B1 | **Adjacent angles.** N⁺ = N⁻ + 1, so θ⁺ − θ⁻ = 1/(2^q − 1). |
| B2 | **Exact period q.** 2^q·N^± ≡ N^± (mod M), and 2^k·N^± ≢ N^± (mod M) for 0 < k < q. |
| B3 | **Same cycle.** N⁻ = 2^i·N⁺ mod M for some i < q. |
| B4 | **Rotation number p/q.** For the orbit x_i of N⁺: rank(x_{i+1}) ≡ rank(x_i) + p (mod q) for every i. Doubling acts on the sorted cycle as rotation by p. |
| B5 | **Unique shortest gap.** In the cyclic order on ℤ/M, every pair of consecutive orbit points except (N⁻, N⁺) is at distance at least 2. So (θ⁻, θ⁺) is the cycle's unique gap of length 1/M. |
| C1 | **Farey order.** For p/q < p′/q′ (both reduced, in (0, 1)): θ⁺(p/q) < θ⁻(p′/q′). The wakes [θ⁻, θ⁺] are disjoint and ordered like the fractions. |
| C2 | **Mediant wake.** For Farey neighbours a/b < c/d (FF-1 `fareyAdj`), the mediant's wake lies strictly between theirs. |
| C3 | **Mediant has the smallest denominator.** For Farey neighbours a/b < c/d, every reduced r/s strictly between them has s ≥ b + d, with equality only for the mediant. FF-1's `adjacent_mediant` supplies the mediant's coprimality and adjacency. |
| B6 (optional, separate gate) | **Uniqueness (Goldberg).** Any period-q cycle of D with rotation number p/q is Ψ(p/q)'s cycle. Sage confirms this for q ≤ 12. It may be dropped or deferred if the proof cost is high. |

**Proof discipline.** C1 is the hardest part, a monotonicity of rotation-set angles in the rotation number. The owner may propose a proof route, or a restriction to Farey neighbours plus C2, at design review, rather than at proof time.

## 5. Not claimed

- **The parameter rays landing at the bulb root.** Classical; cited, not formalized. The same goes for any statement about the actual quadratic dynamics: the rotation number of the attracting cycle, or the shape of the limb.
- **Anything on the analytic side.** No bulb sizes or depths, and no MLC, density of hyperbolicity or renormalization.
- **No Rule 30 claim.** The kit's equivalents catalog (entry [10]) restates Problem 1 as "x₂ is not preperiodic under D". FF-4 studies periodic cycles of the same map D, so this is a shared vocabulary, an interpretive link only. FF-4 says nothing about x₂.
- **No viewer work and no kernel edit.** An Idea Catalog candidate is possible after review.

## 6. Pre-review evidence

Skeleton, Sage 10.9, exact; finite and not proofs. Details are in `SAGE_EVIDENCE_v0_1.md`.
- **A1:** 45/45 for q ≤ 12, in the UniversalCyclotomicField.
- **B1–B5:** 79/79 coprime pairs with q ≤ 16. The closed form reproduces the classical pairs:
  - 1/2: (1/3, 2/3);
  - 1/3: (1/7, 2/7);
  - 2/5: (9/31, 10/31);
  - 3/7: (41/127, 42/127).
- **B6:** 45/45 for q ≤ 12 (a unique cycle).
- **C1:** 78/78 consecutive pairs, all q ≤ 16.
- **C2 and C3:** 50/50 Farey-neighbour pairs with b + d ≤ 16.

Two first guesses at the digit rule failed and were discarded; the rule in §3 was found by a parameter search and then confirmed. The 2026-11-03 numeric "depth" and "mediant deepest" checks are superseded and not relied on.

## 7. Prior art, gates, credit

**Prior art:**
- Douady–Hubbard (Orsay notes);
- Goldberg (1992), on rotation subsets of the circle under z^d;
- Bullett–Sentenac (1994), on ordered orbits of the shift;
- Devaney (1999), on the Mandelbrot set and the Farey tree;
- Milnor, on periodic orbits and external rays;
- Thurston's quadratic minor lamination.

**Project and kit search:**
- In this project: FF-1, FF-3, and the kernel's III.14 cousin atlas (interpretive).
- The v22 kit and `submissions.json` have no Mandelbrot, bulb, ray or Farey material. The kit's only related item is the Problem 1 doubling-map equivalence noted in §5.
- No novelty claim.

**Gates:** as for FF-3:
- input and signature freezes;
- a job template with all-match binding on posting and proof-only retries;
- standard axioms and the strict checker;
- skeleton's independent clean rebuild, replay and separate fidelity review;
- verification by script and Sage;
- no compute on Neo, G1 excluded, no commits;
- library sync after PASS, under saphir's standing rule.

**Credit.** The idea that the fraction fan maps the Mandelbrot bulbs, and the instruments: saphir. This draft: skeleton (Claude Opus 5.5). "The framework was assembled by Robin Miller; its components are classical results of others."
