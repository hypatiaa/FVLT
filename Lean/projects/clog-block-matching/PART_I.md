# LongWindow12 and the Part I long-interval argument

The new Lean theorem proves `LongWindow12` from two explicit inputs for the four unit classes modulo 12. Both analytic inputs are established on paper. Their unconditional Lean proofs remain outstanding in this package. [Kernel theorem](PartILong12.lean#L87) · [Part I, Theorem 3.1(i) and its proof strategy](https://arxiv.org/pdf/2204.03754#page=35)

## First missing estimate

Write Pᵣ(y) for the sum of μ(n) over 1 ≤ n ≤ y with n ≡ r modulo 12. The fixed-modulus instance of the Möbius Siegel–Walfisz estimate needed by the reference-window argument is

    |Pᵣ(y)| ≤ B y/(log y)²¹

for all sufficiently large real y and all r ∈ {1,5,7,11}, with one positive B. Part I proves its Proposition 3.2(i) from equation (1.13) by endpoint subtraction. In this package the exact analytic hypothesis is named `Prefix21`. The workspace’s quantitative Mertens theorem controls the unrestricted Möbius prefix. The four classes also distinguish nonprincipal character twists. The earlier χ₄ Farey transfer takes its exponential estimate as a hypothesis. [First missing Lean proposition](PartILong12.lean#L15) · [Part I, proof of Proposition 3.2](https://arxiv.org/pdf/2204.03754#page=39)

## Why 21 logarithms enter

At real starting point x, set L = log x and K = x/L²⁰. The reference sum equals Pᵣ(x+K) − Pᵣ(x) exactly, including nonintegral endpoints. Once L ≥ 1, x+K ≤ 2x. The two endpoint bounds cost at most 3Bx/L²¹. Dividing by K leaves 3B/L. Lean proves this calculation directly. The exponent 21 belongs to this choice of reference length and desired logarithmic saving. [Exact endpoint identity and reference bound](PartILong12.lean#L18)

## What connects the two lengths

Let H = M^0.99, M ≤ x ≤ 2M, and Uᵣ(x,H) be the residue sum divided by H. The other analytic input is the pointwise comparison

    |Uᵣ(x,H) − Uᵣ(x,K)| ≤ C/log x.

`PartIComparison12` uses the range from Part I Proposition 3.4(i) with A = 1, ε = 1/200 and H₂ = K. Lean checks x^(7/12+1/200) ≤ H ≤ K for every sufficiently large M, uniformly in x. The upper inequality uses (log x)²⁰ = o(x^0.01). This matters asymptotically even though the crossover can be very late. Combining the comparison and reference estimate gives |Uᵣ(x,H)| ≤ (C+3B)/log M for every x in the band. Part II’s separate mean-square comparison at square-root length is still a further input to `AP12Measure`. [Part I comparison and range](PartILong12.lean#L52) · [Part I, Proposition 3.4(i)](https://arxiv.org/pdf/2204.03754#page=37)

## Replay

The source imports the [replayed four-class definitions](ShortLong.lean). To replay on Nucleus, run the following command here.

    python3 replay.py LogSurplus BlockMatching OffsetMatching ShortIntervals ExceptionalTransfer DirectProgressions ShortLong PartILong12

The driver checks the Mathlib pin, builds from source, replays each module with leanchecker, and audits the public theorem axioms. [Nucleus replay](PART_I_REPLAY.log)
