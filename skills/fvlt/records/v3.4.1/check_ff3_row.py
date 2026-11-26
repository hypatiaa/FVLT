"""Independent exact checks of the claims in candidate FF3-FORD-9.4-ROW (stdlib Fractions)."""
from fractions import Fraction as Fr
from math import gcd
from itertools import combinations
ok = 0
def chk(c, m):
    global ok
    if not c: raise SystemExit('FAIL ' + m)
    ok += 1
# shell N with t1=t2=1, n3=N: a = s - s/N; real iff a in Z; events in [0,N]
for N in range(2, 40):
    ev = [Fr(m * N, N - 1) for m in range(N)]
    for s in ev: chk((s - s / N).denominator == 1 and 0 <= s <= N, 'event real')
    # no other rational s in [0,N] with denominator dividing N-1 (complete search on grid 1/(N-1)/N)
    grid = [Fr(k, (N - 1) * N) for k in range(0, (N - 1) * N * N + 1)]
    real = [s for s in grid if (s - s / N).denominator == 1]
    chk(real == ev, 'events exactly mN/(N-1) on fine grid')
    chk([s / N for s in ev] == [Fr(m, N - 1) for m in range(N)], 'addresses m/(N-1)')
# Farey: union over N=2..B+1 equals F_B, consecutive det 1
for B in range(1, 40):
    addr = sorted({Fr(m, N - 1) for N in range(2, B + 2) for m in range(N)})
    FB = sorted({Fr(p, q) for q in range(1, B + 1) for p in range(q + 1)})
    chk(addr == FB, 'F_B')
    for x, y in zip(addr, addr[1:]):
        chk(x.denominator * y.numerator - x.numerator * y.denominator == 1, 'det 1')
# Ford circles: tangent iff |det|=1, stall iff equal, else disjoint; kiss point exact on both circles
def circ(x): q = x.denominator; return (x, Fr(1, 2 * q * q)), Fr(1, 2 * q * q)
pts = sorted({Fr(p, q) for q in range(1, 13) for p in range(0, q + 1)})
for x, y in combinations(pts, 2):
    (c1, r1), (c2, r2) = circ(x), circ(y)
    d2 = (c1[0] - c2[0]) ** 2 + (c1[1] - c2[1]) ** 2
    det = abs(x.numerator * y.denominator - y.numerator * x.denominator)
    if det == 1:
        chk(d2 == (r1 + r2) ** 2, 'tangent')
        t = r1 / (r1 + r2); k = (c1[0] + t * (c2[0] - c1[0]), c1[1] + t * (c2[1] - c1[1]))
        chk((k[0] - c1[0]) ** 2 + (k[1] - c1[1]) ** 2 == r1 ** 2 and (k[0] - c2[0]) ** 2 + (k[1] - c2[1]) ** 2 == r2 ** 2, 'kiss on both')
    else:
        chk(d2 > (r1 + r2) ** 2, 'break = disjoint')
# alias example N=3: s=0 and s=3, same phasor (a=0 and a=2), addresses 0 and 1
a = lambda s, N: s - s / N
chk(a(Fr(0), 3) == 0 and a(Fr(3), 3) == 2 and (a(Fr(3), 3) - a(Fr(0), 3)) % 2 == 0, 'alias phasor')
chk(Fr(0) / 3 == 0 and Fr(3) / 3 == 1, 'alias addresses')
# reality invariant under the v3.3.1 sign of n6: Im(-conj z) = Im z, so z real iff -conj z real (sign test on Im only)
print('PASS', ok)
