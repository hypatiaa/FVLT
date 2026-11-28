# García denominator pairs through cube-root height

For every ε > 0 there is a positive constant Aε such that, for every integer N ≥ 2 and Y = ⌊∛N⌋,

    |L_Y(N) − N C(Y)| ≤ Aε N^(1+ε).

L_Y is the sum over the original denominators N/2 < q < r ≤ N, with gcd(qr,6) = 1 and r/gcd(q,r) ≤ Y. Each summand is 2μ(q)μ(r), accounting for both orders. Squares may occur in the input. Their Möbius weight vanishes. The final theorem uses the integer cube root and includes equality at the height cutoff. [Final theorem and denominator bijection](DenominatorPairs.lean)

Write q = da and r = db in lowest ratio terms a:b. Then b/2 < a < b and the allowed scales satisfy N/(2a) < d ≤ N/b. For each coprime a,b with gcd(ab,6) = 1, the contribution to C(Y) is

    2 μ(a) μ(b) [1/b − 1/(2a)] ρ(6ab),     ρ(m) = (6/π²) ∏_{p|m} p/(p+1).

## What Lean proves

1. Möbius inversion over square divisors gives the exact floor sum for the unrestricted squarefree count. The Basel value and the reciprocal zeta series at 2 give density 6/π². The floor and tail errors together are bounded by 3√t for t ≥ 1. [Base estimate](SquarefreeBase.lean)
2. Let Q_m(t) count positive squarefree d ≤ t coprime to m, and let ω(m) count distinct prime factors. For every m ≥ 1 and every real t ≥ 1, the absolute error from tρ(m) is at most **12 · 2^ω(m) · √t**. When a new prime p is excluded, squarefree multiples of p are exactly p times the new admissible integers through t/p. The density obeys the same recurrence. In the error induction, p ≥ 5 costs at most a factor of two and p = 2,3 each cost at most four. The constant 12 absorbs those two exceptions. [Uniform sieve theorem](CoprimeSquarefree.lean)
3. For every ε > 0, splitting the prime factors at a threshold depending only on ε proves 2^ω(m) ≤ Kε m^ε. Applying the uniform sieve at both endpoints and summing all reduced rows gives an error at most Aε √X Y^(3/2+ε) whenever 2Y ≤ X. At Y³ ≤ X it gives A′ε X^(1+ε). [Height and cube-root budgets](PairHeight.lean)
4. The forward and inverse maps between the actual pairs and their reduced rows are inverse on their full finite domains. The common-scale weights agree including the zero-weight cases. This identifies the estimated sum with L_Y at the original endpoints. [Exact reindexing](DenominatorPairs.lean)

The common-factor sign, first opposing ratio (19,35), and row accumulation come from the earlier [García module](GarciaPairs.lean). The remaining analytic estimate concerns **H_Y(N) + N C(Y)**, where H_Y is the signed sum over larger heights. Closing the cube-root counting error leaves this one-sided bound open.

## Replay

Run `python3 replay.py` on Nucleus with Lean 4.35.0 and Mathlib `56a005855ea17e0b0958f73ec801ae140b0a1679`. It compiles all five modules in a fresh directory, invokes `leanchecker` for each module, records the exact source bytes by SHA-256, and audits every public theorem against Lean’s three standard axioms. [Replay log](NUCLEUS_REPLAY.log)

