# Farey cluster means one level coarser

27 November 2026. This study gives a written argument and finite exact checks. The Lean theorem used at the end is [the Franel growth criterion](https://github.com/hypatiaa/FVLT/blob/8370e7a4e1fb87caf50404b767b7d9af6c3eec19/Lean/projects/farey-character-bridge/FranelEnergy.lean#L27).

## Result

Keep the original order-$N$ displacement of each fraction. Merge its order-$\lfloor N/2\rfloor$ cluster as a unit into an order-$\lfloor N/4\rfloor$ parent. The energy measuring how far the child means move from their parent mean has order $N$, unconditionally. The weighted squared error in replacing **every interior parent mean by the original displacement at its anchor**, all together, is only $O(1)$. The two endpoints separately contribute an explicitly determined linear term to the retained energy.

This leaves a signed counting problem at rational anchors. For an interior parent $a/q$, it is the error between the actual number of order-$N$ fractions through $a/q$ and $m a/q$, where $m$ is the total number. An unconditional estimate dispatches a growing band of small denominators, including every fixed power of $\log N$. The uniform upper bound over the larger denominators remains open.

## What is being grouped

For $0=r_0<r_1<\cdots<r_m=1$, set $\delta_k=r_k-k/m$. **The observations are exactly $k=1,\ldots,m$. Zero is available as an anchor and receives no observation of its own.** Each retained rational anchors itself. Each other point goes to the endpoint of its coarse gap with smaller denominator; ties go left. The first map uses $H=\lfloor N/2\rfloor$; the second uses $J=\lfloor N/4\rfloor$ and acts on the first map’s anchors. Every cluster inherits its total original population $L$ and displacement sum. These definitions implement the original full-sequence rank convention.

Let $E=m\sum_k\delta_k^2=I_N-1/12$, and let $B_1,B_2$ be the sums $m\sum L\bar\delta^2$ after the respective merges. For every $N\ge4$,
$$
B_1=T_2+B_2,\qquad
T_2=m\sum_b\sum_{a\to b} L_a(\bar\delta_a-\bar\delta_b)^2.
$$
Exact variance decomposition gives this identity without a cross term.

**Upper bound for the merge.** If a final anchor has denominator $q$, the first displacement in position is at most $4/(qN)$ and the second is at most $8/(qN)$. Indeed adjacent Farey denominators $u,v$ have gap $1/(uv)$ and $u+v$ exceeds the coarse order. The chosen denominator is the smaller, and denominators never increase along the two assignments. Every descendant therefore lies within $12/(qN)$ of its final anchor. Spacing of at least $1/N^2$ gives at most $12N/q$ intervening ranks and at most $1+24N/q\le25N/q$ descendants. Position and rank change in the same direction, so their difference changes by at most $12N/(mq)$. Replacing each parent mean by the original anchor displacement can only increase the within-parent squared error. Hence
$$0\le T_2\le E-B_2\le86{,}400N,$$
using $m\ge N^2/8$ and $1+\sum_{q\le J}\varphi(q)/q^3\le3$. This is a deliberately loose absolute constant. In the other direction, two explicitly enumerable endpoint groups give $\liminf T_2/N\ge0.02287434426\ldots$. Thus the linear exponent for the merge is sharp.

## Exact finite results

Each entry is an energy divided by $N$, rounded from an exact rational. First-level totals agree exactly with the preceding study at eight powers of two. An independent implementation sorted the reduced rationals, assigned parents by direct lookup, and recomputed all levels at every $N=2,\ldots,40$. The main sweep included 19 cutoffs and tested odd as well as even orders.

| $N$ | Original points | Child means $B_1/N$ | Removed $T_2/N$ | Parent means $B_2/N$ |
|---:|---:|---:|---:|---:|
| 128 | 5,022 | 0.124556 | 0.026357 | 0.098199 |
| 256 | 19,948 | 0.128830 | 0.028516 | 0.100314 |
| 512 | 79,852 | 0.139882 | 0.029121 | 0.110762 |
| 1,024 | 318,964 | 0.143319 | 0.029816 | 0.113503 |
| 1,025 | 319,764 | 0.142517 | 0.029891 | 0.112626 |

## How closely the means follow the actual anchors

Write $A_N(x)=\#\{k:1\le k\le m,\ r_k\le x\}$ and $\delta_N(x)=x-A_N(x)/m$. Uniformly for every reduced interior parent $x=a/q$,
$$L_x\asymp N/q,\qquad |\bar\delta_x-\delta_N(x)|\ll N^{-2}.$$
The reason is the integer determinant $qb-ad$ for a fine fraction $b/d$. At fixed distance $t/(qN)$ only the finitely many determinants $\pm h$ with $h\le t$ can occur. Counting opposite signs in congruence classes gives the same main term and a bounded count difference at every smaller radius. The actual two-level cluster differs from the symmetric window at $t=4$ by only a bounded number of points when $q\le J/2$. For $q>J/2$ the entire cluster already lies within $O(N^{-2})$ of its anchor. This proves
$$
R=m\sum_{0<x<1}L_x(\bar\delta_x-\delta_N(x))^2=O(1).
$$
At $N=1024$ the exact computation gives $R=0.035096$ rounded, **in raw energy units**. This controls the difference of the two energy norms by $O(1)$. A bounded difference of the two squared energies does not follow.

The endpoints have one-sided windows. Their **retained** contribution divided by $N$ tends to $0.09011871579\ldots$. At $N=1024$ they account for $0.089298N$ of $0.113503N$, about $79\%$ of the parent energy. The interior contributes $0.024205N$ at this cutoff. The earlier reviewed obstruction $I_N/N\to\infty$, together with $E-B_2=O(N)$, implies $B_2/N\to\infty$. Endpoints of linear energy cannot account for that growth.

## Where the proof now stalls

Define $D_N(a/q)=A_N(a/q)-m a/q$. Uniform centering and population comparison give the residual target
$$
\sum_{Q(N)<q\le\lfloor N/4\rfloor}\frac1q
\sum_{\substack{1\le a<q\\(a,q)=1}}D_N(a/q)^2
\ \ll_\varepsilon N^{2+\varepsilon}\qquad(\varepsilon>0).
$$
Here one may take $Q(N)=\exp(\eta(\log N)^{3/5}(\log\log N)^{-1/5})$ for a sufficiently small fixed $\eta>0$. A split of the Möbius sum, using the unconditional Mertens estimate from a shrinking zero-free region, shows that **all interior parents through this cutoff together contribute $o(N)$**. The shorter proof using the classical region gives $Q(N)=\exp(\eta\sqrt{\log N})$. In contrast, the argument does not reach any fixed positive power of $N$ for this aggregate conclusion. The signed counting identities behind the split passed 3,090 direct exact tests.

The displayed tail bound is necessary and sufficient for the target $I_N=O_\varepsilon(N^{1+\varepsilon})$. The endpoints and both within-group terms are already on the required scale. At large denominators, a parent can track its anchor to $O(N^{-2})$ while its anchor’s original rank error is much larger. A second-moment estimate for those actual rank errors would finish this route. Replacing them by order-$J$ ranks would lose exactly the offset being measured.

One signed signal can be isolated even without squaring every anchor. The true left-half displacement sum equals $-\tfrac18[S_1(N)-\tfrac12S_1(\lfloor N/2\rfloor)]$. The left parent clusters recover this sum up to an absolute constant. Through F1, a uniform square-root-with-epsilon bound even for this scalar contrast would suffice for RH.

Source: public reading copy of the 27 November 2026 cluster-means report. The workspace report has SHA-256 `5177a7bde64007dae6ee6e83c23492e61e48f4a77b3f41d49687116b086a7bc5`.
