# FF-4 v0.2 architecture evidence (Sage 10.9 on nucleus, exact; finite checks, not proofs)

2026-11-04. Skeleton (Claude Opus 5.5). Sage session `9c1ecadc…`, 0.26 s. These checks cover the owner's proof architecture (`owner_review_v0_1/REVIEW_v0_1.md`, `C1_PROOF_ROUTE_v0_1.md`) as written into `WORK_ORDER_v0_2.md`.

**Definitions used.** W(p, q, u) = Σ_{j=1..q} [((u + (j−1)p) mod q) ≥ q − p] · 2^{q−j}, with the digit rules of §3, and M = 2^q − 1.

| Check | Range | Result |
|---|---|---|
| N⁻ = W(p−1) and N⁺ = W(p) | coprime 0<p<q≤18 (101 pairs) | 101/101 |
| W strictly increasing in u (rank(W(u)) = u) | same | 101/101 |
| Doubling sends W(u) to W((u+p) mod q) | same | 101/101 |
| 0 < N⁻ < N⁺ < M | same | 101/101 |
| W(u) odd iff u < p | same | 101/101 |
| B5: the unique directed gap of 1 is W(p−1) → W(p); all others are ≥ 2, including the wrap M + W(0) − W(q−1) | same | 101/101 |
| S⁺(n) = ⌊(n+1)p/q⌋ (prefix count of the plus word) | n < 3q, same pairs | 3,726/3,726 |
| S⁻(n) = ⌊((n+1)p − 1)/q⌋ | same | 3,726/3,726 |
| C1 prefix domination S⁺(p/q; n) ≤ S⁻(p′/q′; n) for n ≤ q·q′ | ordered pairs p/q < p′/q′, q, q′ ≤ 12 | 990/990 |
| C1 at common length L = q·q′: R⁺ < R⁻, with R/(2^L − 1) equal to the angle | same | 990/990 |
| C3: x.den + y.den ≤ z.den | Farey neighbours x < y with b + d ≤ 25, every z strictly between with den ≤ 25 | 1,719/1,719 |
| C3: equality iff z = mediant(x, y) | same | 1,719/1,719 |

**Code.** The exact definitions and loops are reproduced below.

```python
def W(p, q, u): return sum((1 if ((u + (j-1)*p) % q) >= q - p else 0) * 2**(q-j) for j in range(1, q+1))
def digit(p, q, j, minus): return 1 if (((j*p - (1 if minus else 0)) % q) >= q - p) else 0
# N- = W(p-1), N+ = W(p); W increasing; (2*W(u)) % M == W((u+p)%q); W(u) odd iff u<p;
# gaps = [W(u+1)-W(u)] + [M + W(0) - W(q-1)]: exactly one 1, at index p-1;
# prefix counts vs ((n+1)p)//q and ((n+1)p-1)//q; C1 domination for n<=q*q', common-length R+ < R-;
# C3 bound and equality over the Farey sequence of order 25.
```
