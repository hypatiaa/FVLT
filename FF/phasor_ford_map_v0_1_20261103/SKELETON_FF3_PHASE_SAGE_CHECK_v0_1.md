# Skeleton FF-3 phase-statement check in Sage (exact)

2026-11-04. Skeleton (Claude Opus 5.5). Sage 10.9 on nucleus, session `812ef59a…`, 3.65 s.

**Method.** Each e^{iπa} with rational a = p/d is computed exactly as E(2d)^p in the UniversalCyclotomicField, so no floating point is used. A value is "real" when it equals its own complex conjugate. A nonzero rational amplitude r stands in for the real amplitude: multiplying by it does not change whether the value is real. These are finite checks, not proofs.

**What is checked:**
- `phasor_real_iff` for t₁, t₂ ∈ [−3, 3], n₃ ∈ [1, 6], s = p/d with d ∈ [1, 6] and p ∈ [−8, 8], and r ∈ {1, −5/3};
- `integer_spin_parity` for t₁, t₂ ∈ [−4, 4], integer s ∈ [−6, 6] and n₃ ∈ [1, 7], including negative exponents;
- `phasor_alias_not_address_alias` for r ∈ {1, −2, 7/3};
- `shell_phasor_contact_iff` for N ∈ [2, 12], every s = p/d ∈ [0, N] with d ≤ 2N+2, and amplitude −3.

**Result:** `{'phasor_real_iff': [59976, 0], 'integer_spin_parity': [7371, 0], 'phasor_alias_not_address_alias': [3, 0], 'shell_phasor_contact_iff': [15818, 0]}`. Each entry is [checks, failures]: 83,168 checks in total, with 0 failures.

**Code:**

```python
from sage.all import UniversalCyclotomicField, QQ, ZZ
U = UniversalCyclotomicField()
def epi(a):
    a = QQ(a); d = a.denominator(); p = a.numerator()
    return U.gen(2*d)**p
fa = lambda t2,s,n3: QQ(t2)*QQ(s)/QQ(n3)
pa = lambda t1,t2,s,n3: QQ(t1)*QQ(s) - fa(t2,s,n3)
# phasor_real_iff:  z = r*epi(pa(...)); (z == z.conjugate()) == (pa(...) in ZZ)
# integer_spin_parity: epi(pa(t1,t2,s,n3)) == (-1)**(t1*s) * epi(-fa(t2,s,n3))
# alias: r*epi(pa(1,1,0,3)) == r*epi(pa(1,1,3,3)) and fa(1,0,3) != fa(1,3,3)
# shell_phasor_contact_iff: (z real) == (s in {m*N/(N-1) : 0 <= m <= N-1})
```
