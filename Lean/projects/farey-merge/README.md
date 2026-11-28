# Farey merge · Nucleus replay, 28 November 2026

For every integer $N\ge4$, the two-level, smaller-denominator Farey parent satisfies

$$
|r-b|\le\frac{12}{qN},\qquad 0\le T_2(N)=B_1(N)-B_2(N)\le86{,}400N.
$$

Here $r$ is an original observation, $b$ its final parent, and $q$ the reduced denominator of $b$. The observations are all positive members of $F_N$, including 1. Zero may be a parent. The two coarse orders are $\lfloor N/2\rfloor$ and $\lfloor N/4\rfloor$. Retained points anchor themselves and denominator ties go left. All means use the original ranks and populations. The hypothesis of the final theorem is exactly $4\le N$.

| Step | Lean declaration | What it establishes |
|---|---|---|
| Actual geometry | [parent_step and actual_radius](FareyParent.lean) | A mediant search brackets the observation between determinant-one neighbors. Once their denominators sum to more than the coarse order, no point of that order can lie strictly between them. The endpoints coincide with the extrema used by the atlas code. A step of order $K$ satisfies $|r-p|\,\mathrm{den}(p)(K+1)\le2$ and never increases the denominator. |
| Original population | [population_lower](FareyCount.lean) | $m=|F_N\setminus\{0\}|\ge N^2/8$. In the $N$-by-$N$ grid, each coprime pair maps to a reduced fraction and an orientation. Common divisors cover the remaining pairs. Summing their reciprocal squares leaves the required fraction of the grid. |
| Packing and original rank | [fibre_population and displacement_at_anchor](FareyPacking.lean) | Distinct fractions are at least $1/N^2$ apart. A parent fibre has at most $25N/q$ observations. The rank and position changes have the same sign, giving $|\delta_N(r)-\delta_N(b)|\le12N/(mq)$. |
| Parent weights | [denominator_mass](FareyEnergy.lean) | There are at most $q$ positive reduced fractions of denominator $q$. The extra zero anchor contributes one. Telescoping gives $\sum_b q_b^{-3}\le3$. |
| Energy on the actual partition | [parentMean_original, merge_balance, and actual_merge_bound](FareyEnergy.lean) | The weighted child means give the original parent mean. Centering at the anchor bounds the variance by $28{,}800N/q^3$ per parent. Summing gives $86{,}400N$. |

The parent definitions and original variance estimates are the byte-identical [previously replayed FareyMerge module](https://github.com/hypatiaa/FVLT/blob/6f3fd64b8dfe80c9341d0b43954c1c2288313642/Lean/projects/atlas-four-gaps/FareyMerge.lean). The new modules discharge the geometric, counting, and partition hypotheses. The signed rank errors at the **retained** anchors are the separate open estimate on the atlas.

[Kernel replay and source SHA-256 values](NUCLEUS_REPLAY.log) · [Replay driver](replay.py). Run `python3 replay.py` on the pinned Nucleus installation. It builds in a fresh directory with Lean 4.35.0 and Mathlib `56a005855ea17e0b0958f73ec801ae140b0a1679`, checks the compiled modules with `leanchecker`, and audits every public theorem for the standard axioms.

