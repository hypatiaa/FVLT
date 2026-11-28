# Four proof-atlas nodes · 28 November 2026

**The full local rank–matching theorem passed.** For the Farey merge, the García pair count, and the logarithmic saving, the files below give the proved steps and the hypotheses that still require proofs. The eight open estimates in the atlas retain their previous status.

## Farey merge

[FareyMerge.lean](FareyMerge.lean) defines the finite Farey set, the two successive parent maps, and the displacement using the original positive ranks. The parent with smaller denominator wins and ties go left. Lean proves the variance identity, the two-move bound, the signed rank-displacement bound, and the parent and total budgets. In particular the final constant is 86,400.

The first missing geometric statement concerns the parents actually selected by the code. For every integer $N\ge4$ and positive $r\in F_N$, set $b=\operatorname{parent}_{\lfloor N/4\rfloor}(\operatorname{parent}_{\lfloor N/2\rfloor}(r))$, and $q=\operatorname{den}(b)$. Prove $|r-b|\le12/(qN)$. One way to discharge it is to show that the bracketing neighbors computed at each order $J$ have determinant one and denominators with sum greater than $J$. For an observation equal to an anchor the displacement at that step is zero.

The remaining assembly must apply the original-order spacing to each parent fibre (population at most $25N/q$), prove $N^2/8\le m\le N^2$ for the original positive count, sum the parent weights $\sum_b q_b^{-3}\le3$, and instantiate the two weighted means with their original populations. The current Lean budget has those bounds as hypotheses. The larger question of controlling the **retained** anchor energy is a separate node.

## García denominator pairs

[GarciaPairs.lean](GarciaPairs.lean) proves cancellation of the common squarefree factor in each pair sign, positivity for every eligible pair of reduced height below 35, and the negative sign at $(19,35)$. Its `ratio_budget` uses the actual Möbius weights, reduced-ratio rows, both endpoint counts, and the stated density. Given a sieve constant $C$ and a bound $W$ on the row modulus factors, its bound is $4CW\sqrt X\,Y\sqrt Y$.

The missing uniform sieve estimate, for $m\ge1,t\ge1$, is

$$
\left|\sum_{1\le d\le t,\,(d,m)=1}\mu(d)^2-t\rho(m)\right|
\le C 2^{\omega(m)}\sqrt t,\qquad
\rho(m)=\frac6{\pi^2}\prod_{p\mid m}\frac p{p+1}.
$$

Here $C$ must be independent of both arguments. Completing the original pair-count statement also needs the gcd reindexing of the denominator double sum and $2^{\omega(6ab)}\le C_\eta Y^\eta$ for the row range. The bound then gives the written counting-error exponent at cube-root height. Bounding the signed high pairs together with the low-pair main term is a further open estimate.

## Local binomial rank and maximum matching

[LocalPaths.lean](LocalPaths.lean) proves `AtlasLocal.local_rank_matching`. For arbitrary injective integer row and column positions, and every natural radius $H$, the real matrix with entries $\binom{2H}{y_j+H-x_i}$ (zero outside its range) has rank equal to the greatest number of disjoint pairs satisfying $|y_j-x_i|\le H$. The statement includes empty sets and radius zero. Taking the two positions lists from the positive and negative denominator classes specializes it to either grading.

The proof expands each ordered minor one time step at a time. A collision gives equal rows. At least one strictly ordered reachable successor remains when the endpoints are aligned and reachable, giving strict positivity. Sorting preserves the two distance inequalities of an arbitrary matching. In the reverse direction, a minor attaining matrix rank exhibits a supported permutation in its determinant. This proves the rank identity without assuming a particular matching or using the finite scan. It leaves the size of the unmatched surplus to be bounded.

## Logarithmic saving

[LogSurplus.lean](LogSurplus.lean) defines the untwisted and $\chi_4$-twisted band weights and their short sums. It proves the all-offset average, the elementary exceptional-set budget, and $|A|+|B|=\max(|A+B|,|A-B|)$ for the simultaneous grading. Its `band_budget` applies to the integer starts from $\lfloor X/2\rfloor$ through $X-h$, retaining the $2h$ cost of the end blocks.

For $h=\lfloor\sqrt X\rfloor$, the missing analytic lemma is the following for **each** of the two signed functions. Outside at most $C X/(\log h)^{1/100}$ starts in that interval, prove

$$
 h^{-1}\left|\sum_{t<n\le t+h} f(n)\right|\le C/(\log h)^{1/200}
$$

for all sufficiently large $X$. The written proof uses the quantitative short-interval theorem together with cancellation of the long periodic Möbius average. The finite proof still needs to build the actual matching inside each offset's disjoint blocks to supply `hm` in `band_budget`. The real rank–matching identity alone gives neither estimate.

## Replay

[Nucleus kernel log](NUCLEUS_REPLAY.log) · [Replay driver](replay.py). The driver uses Lean 4.35.0 and Mathlib `56a005855ea17e0b0958f73ec801ae140b0a1679`, compiles in a fresh directory with warnings as errors, runs `leanchecker` on each module, and audits the axioms of every public theorem. To repeat on the pinned Nucleus installation, run `python3 replay.py` beside the four sources. Each source imports only Mathlib.
