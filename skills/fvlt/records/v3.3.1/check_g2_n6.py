"""Exact checks for the G2 / n6 correction candidate (Lemma II.23.9a, guard G2).

Phases are exact rationals in units of pi; a point r*exp(i*pi*a) is the pair (r, a mod 2).
Standard library only.
"""
from fractions import Fraction as F
from itertools import product


def canon(r, a):
    """Normal form of r*exp(i*pi*a) with r a rational: (|r|, a mod 2), sign absorbed as +1 in a."""
    if r == 0:
        return (F(0), F(0))
    if r < 0:
        r, a = -r, a + 1
    return (r, a % 2)


TALLY = {"substantive": 0, "by_construction": 0}


def check(cond, msg, by_construction=False):
    """Count only checks that actually execute. by_construction marks checks that restate a definition
    or the normal form and so cannot fail unless the code itself is wrong."""
    if not cond:
        raise SystemExit("FAIL: " + msg)
    TALLY["by_construction" if by_construction else "substantive"] += 1


def section_report():
    out = dict(TALLY)
    TALLY["substantive"] = TALLY["by_construction"] = 0
    return out["substantive"] + out["by_construction"], out["substantive"], out["by_construction"]


vals = [F(-2), F(-1), F(-1, 2), F(1, 3), F(1), F(2)]

# 1. II.5a: signed n6 enters R_alpha = n6 * n3^alpha. Negating n6 is a constant half-turn:
#    point(-n6) = |R| * exp(i*pi*(address + 1)), address = k*s/n3 (units of pi).
for n6, n3, k, s, alpha in product([F(1), F(2), F(-3)], [F(1), F(2), F(5)], [F(-1), F(0), F(3)], vals, [-1, 0, 1]):
    R = n6 * n3 ** alpha
    addr = k * s / n3
    neg = canon(-R, addr)
    check(neg == canon(R, addr + 1), "n6 sign is a half-turn", by_construction=True)
    check(neg[1] == (canon(R, addr)[1] + 1) % 2, "half-turn: address shifts by exactly 1 (pi)", by_construction=True)

# 2. Def II.23.9: rho = |n6| N^alpha ignores the sign of n6.
for n6, N, alpha in product([F(1), F(-1), F(3), F(-3)], [F(2), F(7)], [-1, 0, 1]):
    check(abs(n6) * N ** alpha == abs(-n6) * N ** alpha, "rho ignores sign of n6", by_construction=True)

# 3. Branch lift (p,q)_c = (N t1, -c t2), z1 = a e^{i p tau}, z2 = b e^{i q tau}.
#    c -> -c fixes p and sends q -> -q: (z1, z2) -> (z1, conj z2), i.e. winding reversal of the
#    second torus coordinate only. Quotient degree k_c = p - q = N t1 + c t2 becomes N t1 - c t2.
#    Full conjugation (chi: whole angular argument flipped) sends (p,q) -> (-p,-q), degree -> -k_c.
#    These agree iff p = N t1 = 0 (static first coordinate).
for N, t1, t2, c in product([F(2), F(3), F(7)], [F(0), F(1), F(1, 2), F(-2)], [F(1), F(1, 3), F(2)], [F(-2), F(-1), F(1), F(2), F(3)]):
    p, q = N * t1, -c * t2
    pm, qm = N * t1, -(-c) * t2          # branch -c
    check(pm == p and qm == -q, "c -> -c: p fixed, q -> -q", by_construction=True)
    k, km = p - q, pm - qm
    check(k == N * t1 + c * t2 and km == N * t1 - c * t2, "reflected gearbox pair N t1 +/- c t2")
    pchi, qchi = -p, -q                   # chi: full conjugation
    check(((pchi, qchi) == (pm, qm)) == (p == 0), "chi equals c -> -c exactly when p = 0")

n, sub, bc = section_report()
print(f"PASS: {n} exact checks ({sub} substantive, {bc} by construction). Under the printed Rmk II.5a scalar formula, n6 -> -n6 is a constant half-turn (address + 1); rho ignores the sign of n6; "
      f"c -> -c reverses only the second torus winding (q -> -q, p fixed); full conjugation chi reverses both "
      f"and coincides with c -> -c only when p = N t1 = 0.")


# 4. saphir 2026-10-30: the instrument's n6 sign is the flip across the y axis, z -> -conj(z)
#    (FVLT Explorer v2.3.1 computeState: "n6 = +/-1 mirrors across y-axis (negate real components)").
#    On a phasor r*e^{i*pi*a} that is r*e^{i*pi*(1-a)}: phase a -> 1 - a, i.e. winding reversal plus a
#    constant half-turn. It is NOT the scalar half-turn a -> a + 1 of the printed Rmk II.5a formula.
def ymirror(r, a):
    return canon(r, 1 - a)

for r, a in product([F(1), F(2), F(1, 3)], vals):
    check(ymirror(r, a) == canon(r, F(1) - a), "y-mirror: a -> 1 - a", by_construction=True)
    check((ymirror(r, a) == canon(-r, a)) == (a % 1 == 0),
          "y-mirror equals the scalar half-turn exactly on the real axis (a an integer)")
# On the lift, y-mirroring both coordinates sends phase slopes (p, q) -> (-p, -q): same as chi, and equal to
# c -> -c (p fixed, q -> -q) only when p = 0. (Slope of 1 - a(tau) is minus the slope of a(tau).)
for p, q in product([F(0), F(2), F(-3, 2)], [F(1), F(-2)]):
    mirrored = (-p, -q); branch = (p, -q)
    check((mirrored == branch) == (p == 0), "y-mirror of both coordinates = c -> -c iff p = 0")
n, sub, bc = section_report()
print(f"PASS (y-axis reading): {n} further exact checks ({sub} substantive, {bc} by construction). The y-axis flip z -> -conj(z) reverses both windings "
      f"up to a constant phase; it equals c -> -c only when p = 0, and it is not the scalar half-turn of Rmk II.5a.")


# 5. Restated Rmk II.5a (change N6-II5a-SIGN-AS-Y-REFLECTION), exact in phase-address form.
#    z_j = r e^{i pi a_j} for n6>0, 0 for n6=0, -r e^{-i pi a_j} = reflection of the positive point for n6<0,
#    with r = |n6| n3^alpha and a_j = k_j s / n3. Checks: radius unchanged from the old |R_alpha|; reflection
#    of the n6>0 point; conjugate pair z2 = conj z1 at integer s, integer t1 (Lemma II.23.2) preserved for both
#    signs; Im z1 = 0 condition unchanged (and the same as under the old scalar form).
def conj(pt):
    r, a = pt
    return canon(r, -a)

def z_new(n6, n3, alpha, a):
    r = abs(n6) * n3 ** alpha
    if n6 == 0:
        return (F(0), F(0))
    return canon(r, a) if n6 > 0 else canon(-r, -a)

def z_old(n6, n3, alpha, a):
    return canon(n6 * n3 ** alpha, a)

def on_real_axis(pt):
    return pt[0] == 0 or pt[1] % 1 == 0

for n6, n3, alpha, t1, t2, s in product([F(1), F(-1), F(2), F(-3)], [F(1), F(2), F(3), F(6), F(7)], [-1, 0, 1],
                                         [F(1), F(2), F(-1)], [F(1), F(2), F(1, 2)], [F(0), F(1), F(2), F(3), F(5), F(6)]):
    k1, k2 = n3 * t1 - t2, n3 * t1 + t2
    a1, a2 = k1 * s / n3, k2 * s / n3
    z1, z2 = z_new(n6, n3, alpha, a1), z_new(n6, n3, alpha, a2)
    check(z1[0] == abs(n6 * n3 ** alpha), "radius unchanged", by_construction=True)
    if n6 < 0:
        check(z1 == canon(-z_new(-n6, n3, alpha, a1)[0], -z_new(-n6, n3, alpha, a1)[1]), "n6<0 is the y-reflection of n6>0", by_construction=True)
    check(z2 == conj(z1), "conjugate pair preserved (integer s, integer t1)")
    check(on_real_axis(z1) == (((t1 * s - t2 * s / n3) % 1) == 0), "contact identity unchanged")
    check(on_real_axis(z1) == on_real_axis(z_old(n6, n3, alpha, a1)), "same contact set as old scalar form")
n, sub, bc = section_report()
print(f"PASS (restated II.5a): {n} further exact checks ({sub} substantive, {bc} by construction; the n6<0 reflection check runs only for n6<0). Radius unchanged; n6<0 is the y-reflection of n6>0; "
      f"conjugate pair and contact identity preserved.")


# 6. Reader note (a): what the restatement changes in the drawn rosette for n6 < 0.
#    a1 + a2 = 2 t1 s, so -a1 = a2 (mod 2) exactly when t1 s is an integer. Then the new point pair is the old
#    pair with z1 and z2 swapped: the drawn image is unchanged and only the labels (and the sign of Im z1) change.
#    When t1 s is not an integer the image itself changes. Here s and t1 range over integers and half-integers.
swapped_cases = changed_cases = 0
for n6, n3, alpha, t1, t2, s in product([F(-1), F(-3)], [F(1), F(2), F(3), F(6), F(7)], [-1, 0, 1],
                                         [F(1), F(2), F(-1), F(1, 2), F(3, 2)], [F(1), F(2), F(1, 2)],
                                         [F(0), F(1), F(2), F(5), F(1, 2), F(3, 2)]):
    k1, k2 = n3 * t1 - t2, n3 * t1 + t2
    a1, a2 = k1 * s / n3, k2 * s / n3
    new = (z_new(n6, n3, alpha, a1), z_new(n6, n3, alpha, a2))
    old = (z_old(n6, n3, alpha, a1), z_old(n6, n3, alpha, a2))
    integral = (t1 * s) % 1 == 0
    check((new == (old[1], old[0])) == integral, "new pair = old pair swapped exactly when t1 s is an integer")
    check((set(new) == set(old)) == (integral or (on_real_axis(old[0]) and on_real_axis(old[1]))),
          "drawn image unchanged exactly when t1 s is an integer or both old points are real")
    if integral and not on_real_axis(old[0]):
        check(new[0] != old[0], "labels differ off the real axis")
    swapped_cases += integral
    changed_cases += set(new) != set(old)
n, sub, bc = section_report()
print(f"PASS (reader note a): {n} further exact checks ({sub} substantive, {bc} by construction). For n6<0 the new "
      f"pair is the old pair with z1, z2 swapped exactly when t1 s is an integer ({swapped_cases} cases); the drawn "
      f"image changes in {changed_cases} cases, all with t1 s not an integer.")
