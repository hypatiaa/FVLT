# cLog · A shared denominator matching and its analytic input

The finite matching is proved in Lean for every admissible band and block length. The short-interval estimate for both gradings and the logarithmic saving for this matching are proved **in Lean conditional on one explicit analytic proposition**. The paper theorem implying that proposition is unconditional. The Nucleus package contains no proof term for the proposition itself.

## The missing Lean lemma

The exact missing declaration would have type `AtlasLog.AP12Measure`. Set M = ⌊X/2⌋, h = ⌊√X⌋, and let Aᵣ(x,h) sum μ(n) over x < n ≤ x+h with n ≡ r modulo 12. The proposition requires constants K > 0 and X₀ such that for every integer X ≥ X₀,

    meas{x ∈ [M,2M] : max over r ∈ {1,5,7,11} of |Aᵣ(x,h)| > K h/log X}
      ≤ K X/log X.

[Exact Lean proposition and transfer](ExceptionalTransfer.lean)

### Written proof of the analytic input

Apply Theorem 1.1(i) of Matomäki, Radziwiłł, Shao, Tao, and Teräväinen at scale M. Use the constant observable 1 on the trivial nilmanifold, fixed complexity parameter 1/4, logarithmic exponent 1, and ε = 1/12. Since X is 2M or 2M+1, the integer h is between M^(5/12) and M^(11/12) for all sufficiently large M. The theorem bounds the supremum of the Möbius sum over arithmetic progressions inside each good interval by h/log M. Each of the four residue slices is such a progression or is empty. The same exceptional set works for all four. Its measure is O(M/log M). Since log X/log M tends to 1, enlarging one absolute K gives the displayed proposition. This specialization needs no separate estimate for the long Möbius mean. [Published theorem and definition (1.4)](https://doi.org/10.1007/s00222-026-01408-6) · [Authors’ full text](https://arxiv.org/html/2411.05770v2#S1.Thmtheorem1)

The earlier written deduction used the 2016 short-versus-long average theorem and Davenport’s estimate for the long mean of a fixed periodic twist. The four-progression formulation isolates one sufficient analytic input for this square-root block length. [Original short-interval theorem](https://annals.math.princeton.edu/wp-content/uploads/annals-v183-n3-p06-p.pdf#page=2)

### What the kernel checks

1. For integer h, the integers in (x,x+h] are exactly those in (⌊x⌋,⌊x⌋+h]. Each exceptional integer start contributes a disjoint real cell [t,t+1) of measure one. The full cells fit in [M,2M], including when X is odd. Thus the measure estimate bounds the number of bad integer starts. [Transfer](ExceptionalTransfer.lean)
2. The ordinary block sum uses signs ++++ on residues 1,5,7,11. The twisted sum uses ++−−. Away from the common bad set each signed sum has magnitude at most 4Kh/log X. The theorem `signed_short_estimate` also gives the original exponents, namely normalized error O((log h)^(−1/200)) outside O(X/(log h)^(1/100)) starts, with constants uniform in X and in the grading. [Four-progression reduction](ShortIntervals.lean)
3. Each full block matches ordinary positive and negative denominators inside each of the two χ₄ classes. Both projections of the edge set are injective. Every edge has opposite signs in **both** gradings and satisfies |q−r| ≤ 2h. The count of uncovered active rows is exactly the active population minus twice the number of edges. The surplus in a block is at most the larger of the two absolute signed sums. [Actual edges and unmatched cardinality](BlockMatching.lean)
4. Joining disjoint full blocks and trying every starting offset gives one shared matching. The two incomplete ends cost at most 2h together. The other cost is bounded by the average of the full-block surpluses. [Offset theorem](OffsetMatching.lean)
5. Using the exceptional-set estimate in this construction gives a shared matching with O(X/log X) uncovered rows for every sufficiently large X. The original O(X/(log X)^(1/200)) claim follows. The quantitative short-interval input is an explicit theorem argument throughout. Uniform square-root control of the unmatched rows remains open. [Stronger rate](ShortIntervals.lean) · [Atlas corollary](ExceptionalTransfer.lean)

## Replay

Run `python3 replay.py` on Nucleus with Lean 4.35.0 and Mathlib `56a005855ea17e0b0958f73ec801ae140b0a1679`. It rebuilds all five modules in a fresh directory, runs leanchecker on each, records the SHA-256 of the compiled sources, and checks the axioms of each public theorem. [Replay log](NUCLEUS_REPLAY.log)

