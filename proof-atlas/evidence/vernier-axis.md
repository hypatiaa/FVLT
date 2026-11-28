# The three-tooth Vernier on the Farey denominator band

## The signed real axis

For real $X\ge2$, use the denominators $X/2<q\le X$ with $\gcd(q,6)=1$. Give every tooth amplitude one, set $N=q$ and $t_1=t_2=1$, and use the centered offsets $c=-1,0,+1$. At each reduced numerator $1\le a<q$ the original square-root gear is evaluated at spin $s=a$. With $\zeta_q=\exp(2\pi i/q)$ the teeth in order are

$$z_-=\exp(\pi i a(q-1)/q),\qquad z_0=(-1)^a,\qquad z_+=\exp(\pi i a(q+1)/q).$$

The flanks square to $\zeta_q^{-a}$ and $\zeta_q^a$. They are complex conjugates, so the endpoint lies on the real axis already at each spin. Keep the sign when summing. The general tooth and comb have [public Lean definitions](https://github.com/hypatiaa/FVLT/blob/8370e7a4e1fb87caf50404b767b7d9af6c3eec19/Lean/theorems/FVLTCenteredCombLemmaV1.lean#L24-L29).

## What the endpoint reads

Every retained $q$ is odd and exceeds one. Pairing $a$ with $q-a$ cancels the center. Multiplication by $(q-1)/2$ or $(q+1)/2$ permutes the units modulo $q$, so each flank visits all primitive $q$th roots once. Their sum is $\mu(q)$. Multiplying each complete row by $\chi(q)$ and summing over the band gives the three separate coordinates

$$(V_\chi(X),0,V_\chi(X)),\qquad V_\chi(X)=\sum_{\substack{X/2<q\le X\\(q,6)=1}}\chi(q)\mu(q).$$

The raw endpoint is $2V_\chi(X)$. One flank, or half the endpoint, reads the band sum. This works for both the trivial character and $\chi_4$. Keeping the indicated numerator representatives fixes the center phase. [Lean definition of the band](https://github.com/hypatiaa/FVLT/blob/8370e7a4e1fb87caf50404b767b7d9af6c3eec19/Lean/projects/farey-character-bridge/CrystalBridge.lean#L60-L71)

## A cancellation across denominators

At $X=40$, the rows with nonzero trace are $23,29,31,35,37$. Rows 31 and 35 contribute $-1$ and $+1$ to each ordinary flank. Both denominators are $3\bmod4$, so twisting by $\chi_4$ reverses both signs and preserves their cancellation. The full band gives $(-3,0,-3)$ for $\chi=1$ and $(-1,0,-1)$ for $\chi_4$.

The same disjoint pairing works for $(31k,35k)$ whenever $X/62<k\le X/35$, $k$ is squarefree, and $(k,6510)=1$. Each pair cancels exactly for both characters. The pairs cover a limiting fraction $9/256$ of the nonzero rows.

## The open estimate

Let $R$ be the remaining nonzero rows and $a_q=\chi(q)\mu(q)$. For either of these real characters the squared one-flank sum is

$$\left|\sum_{q\in R}a_q\right|^2=|R|+\sum_{\substack{q,r\in R\\q\ne r}}a_q a_r.$$

At $X=10^8$ the removal leaves 14,663,860 nonzero rows. Their one-flank balances are 726 for the trivial character and 550 for $\chi_4$. The second flank reproduces the same balance. The diagonal costs $O(X)$. A uniform upper bound of order $X^{1+2\varepsilon}$ on the signed off-diagonal would give $|V_\chi(X)|\ll_\varepsilon X^{1/2+\varepsilon}$. That estimate remains open. For the untwisted band and every $\varepsilon>0$, it is the hypothesis of the [Lean implication to RH](https://github.com/hypatiaa/FVLT/blob/8370e7a4e1fb87caf50404b767b7d9af6c3eec19/Lean/projects/farey-character-bridge/CrystalBridge.lean#L823).

The row and packet arguments are written deductions. Exact cyclotomic checks covered the admissible rows through $q=500$, and an integer scan covered all cutoffs from 2 through $10^8$. The general comb and the conditional Lean implication cited above are separate formal results.

## A sufficient condition from zero returns

At integer cutoffs each entering or leaving row changes one flank by at most one. Thus for large integers $X,Y$,

$$|V_\chi(X)-V_\chi(Y)|\le |X-Y|+|\lfloor X/2\rfloor-\lfloor Y/2\rfloor|\le \tfrac32|X-Y|+1.$$

Suppose that for each sufficiently large integer $X$ there is an integer $Y$ with $|X-Y|\le C\sqrt X$ at which the **full signed band endpoint** vanishes. The half-endpoint identity gives $V_\chi(Y)=0$, hence $|V_\chi(X)|\le (3C/2)\sqrt X+1$. The observable is constant between successive integer cutoffs, so this also bounds real $X$. The reports establish exact real-axis alignment; a uniform spacing estimate for returns to zero on that axis remains unproved. This conditional applies to each character for which the spacing hypothesis is supplied.

## Source records

| Research note, 27 November 2026 | SHA-256 of the original report |
| --- | --- |
| Three-tooth square-root Vernier on the Farey denominator band | `854b4498638a318504d49460371f79117f66940078b04a0e54697169ed0f4aae` |
| What the three Vernier teeth cancel across denominators | `028e0f8ac10084d9d01e33783ecb59f1c7a97b188cf53b51223ff2a2910649b4` |
