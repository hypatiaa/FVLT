# FF-4: a proof route for C1 (and B1) through one staircase function, v0.1

2026-11-04. Skeleton (Claude Opus 5.5), offered as an aid to the owner's design review of `WORK_ORDER_v0_1.md` (`cbfa51a7…`, #1555), on saphir's "Go" after the FF-4 go relayed in #1557. It is a suggestion, not a change to the order. The owner decides at design review.

## The route

For ρ ∈ (0, 1), define the staircase:

S(ρ) := Σ_{k≥1} 2^{−k} ⌊kρ⌋.

1. **Digits are floor differences.** For ρ ∈ (0, 1) and k ≥ 1, the condition {kρ} ≥ 1 − ρ holds exactly when kρ + ρ crosses an integer. So:

   1[{kρ} ≥ 1 − ρ] = ⌊(k+1)ρ⌋ − ⌊kρ⌋.

   With ρ = p/q, the left side is the order's digit b⁺_k, since (k·p mod q) ≥ q − p.
2. **θ⁺ is the staircase.** Summing with weights 2^{−k} telescopes:

   θ⁺(p/q) = Σ_k 2^{−k}(⌊(k+1)ρ⌋ − ⌊kρ⌋) = S(ρ) − ⌊ρ⌋ = S(p/q).

   The b⁻ digits shift by one in the same way, giving θ⁻(p/q) = Σ_k 2^{−k}(⌈kρ⌉ − 1) = S(p/q⁻), the left limit.
3. **B1 is the jump.** ⌊kρ⌋ and ⌈kρ⌉ − 1 differ exactly when q | k. Therefore:

   θ⁺ − θ⁻ = Σ_{m≥1} 2^{−mq} = 1/(2^q − 1).
4. **C1 is monotonicity.** S is nondecreasing, because every ⌊kρ⌋ is. For rationals ρ < ρ′ in (0, 1), pick any rational ρ″ strictly between them. Then:

   S(ρ) ≤ S(ρ″⁻) < S(ρ″) ≤ S(ρ′⁻),

   where the strict step is ρ″'s jump. So θ⁺(ρ) < θ⁻(ρ′): the wakes are disjoint and ordered like the fractions. C2 then follows from C1 and FF-1's `adjacent_mediant`.

**Exact closed form for finite proofs.** Using ⌊(k+q)p/q⌋ = ⌊kp/q⌋ + p:

S(p/q) = (A + p·2^{−q}) / (1 − 2^{−q}), where A = Σ_{k=1}^{q} 2^{−k}⌊kp/q⌋.

The same holds for S(p/q⁻), with ⌈·⌉ − 1 in place of ⌊·⌋.

**Classical context.** S is the classical "devil's staircase" linking rotation numbers to doubling-map angles (Bullett–Sentenac 1994; Goldberg 1992). No novelty is claimed.

## Checks (Sage 10.9 on nucleus, exact rationals; finite evidence, not proofs)

Every coprime p/q with q ≤ 20 (127 pairs), session `4f2e8157…`:

| Check | Result |
|---|---|
| θ⁺ = S(p/q), using the order's digit rule | 127/127 |
| θ⁻ = S(p/q⁻) | 127/127 |
| Jump = 1/(2^q − 1) | 127/127 |
| Digit identity, 1[{kρ} ≥ 1 − ρ] = ⌊(k+1)ρ⌋ − ⌊kρ⌋, for k < 3q | 5105/5105 |
| C1 on consecutive fractions | 126/126 |
| Negative control: θ⁺ against the ⌈·⌉ − 1 form (should never match) | 0 matches |

## What it would mean for the order

- **C1 can stay general;** there is no need to restrict it to Farey neighbours.
- **B1 and C1 share one definition.** A Lean formalization could define S, or its finite closed form, once, and prove B1 and C1 from it. The digit rule then becomes a lemma rather than the definition.

That is a definitional choice for the owner and the signature freeze.
