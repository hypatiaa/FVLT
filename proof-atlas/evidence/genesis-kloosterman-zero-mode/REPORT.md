# GENESIS García at zero frequency and the signed denominator band

28 November 2026. Written mathematical derivation and exact Sage 10.9 checks on Nucleus. The comparison with the GRH sources is a reading of the linked declarations and workbook. The pair estimates below have a paper proof. This study adds no Lean theorem.

## 1. Where the trace ends

Use the full unit group in GENESIS García. Its plotted value for a pair of inputs is
$$
 K(a,b;q)=\sum_{u\in(\mathbb Z/q\mathbb Z)^\times} e((au+bu^{-1})/q),
 \qquad e(t)=\exp(2\pi i t).
$$
Inverting the dummy variable identifies this exactly with the workbook's classical Kloosterman sum. The proper-subgroup setting gives a different sum. At $a=1,b=0$, the inverse term disappears. Inclusion–exclusion on $(u,q)=1$ gives $K(1,0;q)=c_q(1)=\mu(q)$. For example $K(1,0;31)=-1$, while the exact sum of $|K(1,b;31)|^2$ over all 31 choices of $b$ is 930 by Fourier orthogonality. The viewer draws floating-point values. The checker evaluates these identities in cyclotomic fields. [Viewer implementation](https://github.com/hypatiaa/FVLT/blob/5310311943545a906ed628533adb97c8306c4d7b/viewers_latest/genesis-garcia-.html#L468-L475)

In the classical Petersson model for even weight $k\ge4$ and **positive** indices $m,n$, each modulus contributes a multiple of
$$
 \frac{S(m,n;q)}{q}\,J_{k-1}(4\pi\sqrt{mn}/q).
$$
At zero output index a holomorphic cusp form has zero constant coefficient. Formally setting $n=0$ in the geometric weight gives $J_{k-1}(0)=0$ at every modulus. Thus the Kloosterman factor survives as $\mu(q)$ at $m=1$, and the spectral measurement annihilates it before the sum over moduli. Dividing out the zero weight has no justification. The workbook's model near-orthogonality estimate already follows from Bessel decay using the trivial bound on the Kloosterman factor. [Petersson formula and near orthogonality, §§10.2–3](https://ultronozm.github.io/grh-workbook/20261125T010500--poincare-series-and-near-orthogonality__workbook.html)

In the readable Lean reconstruction the actual second moment averages the squared Hilbert–Schmidt norm of $P^*\rho(g)P$ over a finite group of level translations. Theorem B concludes that few translates span a stated fraction of the target dimension. Its parameter named $b$ is a positive weight. The workbook explains the classical Kloosterman comparison through the nonidentity double cosets in the Gram operator. These sources support the comparison without identifying a viewer invocation in the Lean proof. [Second-moment declaration](https://github.com/lsernau/grh-lean/blob/72fead1/grh/src/New/Spanning/SecondMoment/SpanningTheorem.lean#L266-L280) · [Theorem B](https://github.com/lsernau/grh-lean/blob/72fead1/grh/src/New/Reduction/ShortAndEnough.lean#L443-L453) · [Gram-operator comparison, §39.2](https://ultronozm.github.io/grh-workbook/20261126T020210--bessel-poincare-series-and-their-gram-operators__workbook.html)

Two attempts to keep a positive frequency clarify this boundary. Periodicity gives $K(1,q;q)=\mu(q)$ exactly, but the Petersson sum fixes the frequency as the modulus varies. Taking a single common multiple of the eligible moduli also gives the right inner sum on the band. The resulting trace still has its modulus-dependent Bessel weight and contributions outside the band. Even the least such common multiple contains every prime between $X/2$ and $X$ larger than three, so its logarithm grows at least linearly in $X$ by the prime number theorem.

## 2. A deterministic estimate for growing families of denominator pairs

Write $I_X=\{q:X/2<q\le X,\ (q,6)=1\}$, $V=\sum_{I_X}\mu(q)$, and $Q=\sum_{I_X}\mu(q)^2$. The diagonal of $V^2$ is $Q\le X$. For each distinct pair on the squarefree support, write $q=da<r=db$ with $d=(q,r)$. Then $(a,b)=1$, $a<b<2a$, and $\mu(q)\mu(r)=\mu(a)\mu(b)$. The common factor disappears from the sign. The two orders of that pair contribute
$$
 2\mu(a)\mu(b)
 \sum_{\substack{X/(2a)<d\le X/b\$d,6ab)=1}}\mu(d)^2.
$$
In this section $a,b$ are reduced denominator coordinates, independent of the viewer's inputs. Call $b=r/(q,r)$ the height of the pair.

Every nonzero pair at height below 35 has positive sign. The first squarefree composite coprime to six is 35, and $b/2<a<b$ excludes 1. At height 35 one obtains $(a,b)=(19,35)$ and sign $-1$. This is a statement about the actual signs at every cutoff. Individual signed families have computable asymptotic size. Counting both orders, $(5,7)$ contributes $+3X/(16\pi^2)+O(\sqrt X)$, while $(19,35)$ contributes $-3X/(320\pi^2)+O(\sqrt X)$.

For an integer $m\ge1$ define $\rho(m)=(6/\pi^2)\prod_{p\mid m}p/(p+1)$. Uniformly for $t\ge1$,
$$
 \sum_{d\le t,(d,m)=1}\mu(d)^2
 =t\rho(m)+O(2^{\omega(m)}\sqrt t).
$$
Indeed, expand $\mu(d)^2=\sum_{h^2\mid d}\mu(h)$. For $(h,m)=1$ the inner coprime count is $t\varphi(m)/(h^2m)+O(2^{\omega(m)})$ by inclusion–exclusion. Extending the main sum from $h\le\sqrt t$ to infinity costs $O(\sqrt t)$, and its Euler product gives $\rho(m)$.

Let $L_Y(X)$ be the signed contribution of all off-diagonal pairs of height $\le Y$, counting both orders, and define
$$
 C(Y)=2\!\!\sum_{\substack{a<b\le Y,\ b<2a\$a,b)=(ab,6)=1}}
 \mu(a)\mu(b)\rho(6ab)\left(\frac1b-\frac1{2a}\right).
$$
For $2\le Y\le X/2$,
$$
 L_Y(X)=XC(Y)+O_\eta\!\left(\sqrt X\,Y^{3/2+\eta}\right)
 \quad(\eta>0).
$$
At each height $b$ there are at most $b/2$ choices of $a$; both interval endpoints have size at most $X/b$. The elementary divisor bound gives $2^{\omega(6ab)}\ll_\eta b^\eta$. Summing the squarefree counting errors proves the estimate. Independently, counting every pair by absolute size gives $|L_Y|\le XY$, so every subpolynomial range $Y=X^{o(1)}$ contributes at most $X^{1+o(1)}$ even before signs are used.

**What closes at cube-root height.** Set $Y=\lfloor X^{1/3}\rfloor$ and let $H_Y$ denote the signed sum above that height. For every $\varepsilon>0$, the counting error is $O_\varepsilon(X^{1+\varepsilon})$, the desired scale after squaring. Hence
$$
 V(X)^2=Q(X)+XC(Y)+H_Y(X)+O_\varepsilon(X^{1+\varepsilon}).
$$
It is sufficient, and equivalent at the level of all positive exponents, to establish the **one-sided** upper bound $H_Y(X)+XC(Y)\le A_\varepsilon X^{1+\varepsilon}$ at every sufficiently large $X$. Counting the common factors of the low pairs is now controlled. The signed main term and the high pairs remain to be bounded together; there is no estimate for that combination here.

| $X$ | $Y$ | diagonal $Q$ | low signed $L_Y$ | high signed $H_Y$ | $V(X)$ |
|---:|---:|---:|---:|---:|---:|
| 10,000 | 21 | 1,524 | +922 | −1,770 | −26 |
| 100,000 | 46 | 15,198 | +16,756 | −28,354 | −60 |
| 1,000,000 | 100 | 151,980 | +224,664 | −369,248 | +86 |

At one million the low contribution is $409852-185188$. Its predicted main term is about $224751.7322$. A second algorithm counted both low and high sums directly by exact gcd, using subset inversion on the prime divisors of the larger denominator; it reproduces all three rows. [Sage checker](check.py) · [Nucleus output](sage-output.txt)

## 3. Can another viewer frequency or a phase average recover the signs?

**Every fixed positive $a$ on the zero-frequency axis.** Put $V_a(X)=\sum_{q\in I_X}K(a,0;q)$. The identity $c_q(a)=\sum_{d\mid(a,q)}d\mu(q/d)$ gives
$$
 V_a(X)=\sum_{d\mid a,\ (d,6)=1}dV(X/d).
$$
For example $V_2=V_3=V$ and $V_5(X)=V(X)+5V(X/5)$. To see the obstruction analytically, write $a_0$ for the divisor of $a$ left after removing all factors of 2 and 3. For $\Re s>1$, direct integration of the sharp band gives
$$
 \int_1^\infty V_a(x)x^{-s-1}\,dx
 =\frac{\sum_{d\mid a_0}d^{1-s}}{s(1-3^{-s})\zeta(s)} .
$$
The band factor $1-2^{-s}$ cancels the local factor from removing 2. The numerator factors into geometric polynomials whose zeros all have $\Re s=1$. Consequently changing the fixed positive input $a$ leaves every potential pole with $1/2<\Re s<1$ visible. At $a=1$ the project's Lean identity gives $M(X)=V(X)-V(X/3)$. Conversely, iteration gives $V(X)=\sum_{j\ge0}M(X/3^j)$ with zero tail. Thus any known Mertens estimate transfers, including $V=o(X)$ from the prime number theorem, and the desired fixed-sign square-root estimate would give the corresponding Mertens bound. [Existing Lean identity](https://github.com/hypatiaa/FVLT/blob/8370e7a4e1fb87caf50404b767b7d9af6c3eec19/Lean/projects/farey-character-bridge/CrystalBridge.lean#L283-L292)

**Square-root cancellation at every cutoff for almost every choice of prime signs.** Assign independent uniform signs $\epsilon_p$ to primes above three and weight an eligible squarefree $q$ by $\prod_{p\mid q}\epsilon_p$. Distinct squarefree $q$ give orthogonal functions. The exact mean square of the band sum is $Q(X)$, asymptotic to $3X/(2\pi^2)$. In fact for almost every *single fixed assignment*, simultaneously for all large $X$, the band sum is $O_{\epsilon,\delta}(\sqrt X(\log X)^{3/2+\delta})$ for each $\delta>0$. Here the constant may depend on the assignment. To prove this, split every prefix of $[1,2^k]$ into at most $k+1$ dyadic blocks. Cauchy–Schwarz and orthogonality bound the integral of the squared maximal prefix by $(k+1)^2 2^k$: at each dyadic level the block energies sum to at most $2^k$. Markov's inequality at threshold $2^{k/2}(k+1)^{3/2+\delta}$ gives a summable probability. Borel–Cantelli, taking a countable sequence of positive $\delta$ tending to zero, and subtracting two prefixes prove the assertion. This elementary maximal argument is the Rademacher–Menshov method.

The actual Möbius signs correspond to the single assignment $\epsilon_p=-1$ for all $p>3$. Fixing any finite collection $F$ of those signs to $-1$ still permits setting all remaining signs to $+1$. That choice has band sum
$$
 \frac{3}{2\pi^2}X\,\prod_{p\in F}\frac{p-1}{p+1}+O_F(\sqrt X).
$$
To verify the coefficient, prescribe exactly which primes of $F$ divide $q$. For squarefree $q$, the fractions with a particular prime $p$ absent or present have limiting proportions $p/(p+1)$ and $1/(p+1)$, respectively. The product over the finite set and its error follow from the same coprime squarefree count in §2, after factoring out the prescribed divisors. At $X=10^6$, fixing the negative signs at $5,7,11$ gives $63{,}314$; prescribing every sign to be negative gives $86$. The phase average therefore proves an all-cutoff square-root result for generic assignments while leaving the arithmetic assignment unresolved.
