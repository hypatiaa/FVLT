# Farey ranks at prime denominators

Let $p$ be prime. For $1\le a<p$, let $R_N(a/p)$ count positive reduced Farey fractions with denominator at most $N$ and value at most $a/p$. Write $m_N=\sum_{d\le N}\varphi(d)$ and $D(a)=R_N(a/p)-m_N a/p$. The convention includes $1/1$, excludes $0/1$, and counts a fraction exactly on the anchor. The Mertens function is $M(x)=\sum_{1\le d\le x}\mu(d)$.

For every complex Dirichlet character $χ$ modulo $p$, the normalized coefficient is

$$
c_\chi=\frac{1}{p-1}\sum_{a=1}^{p-1}D(a)\overline{\chi(a)}.
$$

* [Inversion and Parseval](FareyPrimeCharacterEnergy.lean) reconstruct all the individual rank errors and give $\sum_\chi |c_\chi|^2=(p-1)^{-1}\sum_a|D(a)|^2$. The same module proves the finite Mertens floor formula for the actual Farey ranks.
* [The arithmetic factorization](FareyPrimeCharacterFormula.lean) gives $c_\chi=W_\chi H_\chi(N)$, where
  $$
  W_\chi=-\frac{1}{p(p-1)}\sum_{a=1}^{p-1}a\overline{\chi(a)},
  \qquad H_\chi(N)=\sum_{k=1}^{N}M(\lfloor N/k\rfloor)\chi(k).
  $$
  The proof identifies the $k$-th floor error with the negative least residue of $ka$ divided by $p$. Multiplication by a unit permutes the anchors. A multiple of $p$ contributes zero.
* [Reflection and the endpoint](FareyPrimeCharacterParity.lean) show that $W_1=-1/2$. The principal coefficient equals $-1/2$ for $0<N<p$, and zero for $N=0$ or $N\ge p$. Every nonprincipal even character has coefficient zero at every $N$. At $p=7$, the quadratic character is odd and summing its six signed residues gives $W_\chi=1/6$, the normalization used in the earlier package.
* [Quadratic Gaussian periods](PrimeQuadraticPeriods.lean) use a primitive **additive** character to form the two phasor sums $A,B$ on the residues and nonresidues. For odd $p$, $A+B=-1$, $(A-B)^2=\chi_2(-1)p$, and $AB=(1-\chi_2(-1)p)/4$.

The energy formula is an equality for each $p,N$. An upper estimate on the right as $p,N$ vary requires additional bounds on the weighted sums $H_\chi(N)$. In particular, a square-root bound on the single-prime Gauss sum concerns the additive phasor input. The rank transform has its own arithmetic factor $H_\chi(N)$.

## Kernel replay

The code imports the [positive Farey counting module](TwistedCount.lean) verbatim from the earlier pinned package. With Lean 4.35.0 and built Mathlib revision `56a005855ea17e0b0958f73ec801ae140b0a1679`, run:

```sh
python3 replay.py --packages /path/to/project/.lake/packages
```

The script compiles all five modules in a fresh temporary directory, prints the axioms of the new public theorems, checks them against the standard three, and rechecks each module with `leanchecker`. [Nucleus replay output](NUCLEUS_REPLAY.log)
