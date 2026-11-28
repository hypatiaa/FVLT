"""Run with sage -python check.py. All comparisons use exact arithmetic."""
from array import array
from itertools import product
from math import gcd, isqrt
from sage.all import CyclotomicField, ZZ, euler_phi, moebius
from sage.env import SAGE_VERSION

def viewer_checks():
    for q in range(2, 49):
        z = CyclotomicField(q).gen()
        units = [u for u in range(1, q) if gcd(u, q) == 1]
        row_zero = sum(z**u for u in units)
        assert row_zero == moebius(q)
        # Exact distance between the b=1 and b=0 columns, averaged over a.
        # Finite Fourier orthogonality collapses the double sum to this diagonal.
        inverse_row = [z**pow(u, -1, q) for u in units]
        distance = sum((w-1)*(w.conjugate()-1) for w in inverse_row)
        assert distance == 2*(euler_phi(q)-moebius(q))
        if q in (5, 15, 31):
            row = [sum(z**((u+b*pow(u, -1, q)) % q) for u in units)
                   for b in range(q)]
            assert sum(w*w.conjugate() for w in row) == q*euler_phi(q)
            print("viewer", q, "K(1,0)", int(row_zero),
                  "sum |K(1,b)|^2", int(q*euler_phi(q)),
                  "mean squared column distance", int(distance))
    print("exact cyclotomic rows checked:", 47)

def walsh_check():
    numbers = [n for n in range(22, 43) if gcd(n, 6) == 1 and moebius(n)]
    factors = {n: [int(p) for p, _ in ZZ(n).factor()] for n in numbers}
    primes = sorted({p for group in factors.values() for p in group})
    second_moment = 0
    for choices in product((-1, 1), repeat=len(primes)):
        signs = dict(zip(primes, choices))
        s = sum(prod_sign(signs[p] for p in factors[n]) for n in numbers)
        second_moment += s*s
    assert second_moment == (2**len(primes))*len(numbers)
    print("Walsh band X=42:", numbers, "assignments", 2**len(primes),
          "mean square", len(numbers), "all minus", int(sum(moebius(n) for n in numbers)))

def prod_sign(values):
    result = 1
    for value in values:
        result *= value
    return result

def band_checks(limit=10**6):
    mu = array('b', [1])*(limit+1)
    mu[0] = 0
    prime = bytearray([1])*(limit+1)
    for p in range(2, limit+1):
        if prime[p]:
            if p <= isqrt(limit):
                prime[p*p::p] = bytes((limit-p*p)//p+1)
            for n in range(p, limit+1, p):
                mu[n] = -mu[n]
            for n in range(p*p, limit+1, p*p):
                mu[n] = 0
    assert all(mu[i] == moebius(i) for i in range(1, 1001))
    v = array('i', [0])*(limit+1)
    m = 0
    eligible_sum = array('i', [0])*(limit+1)
    for x in range(1, limit+1):
        m += mu[x]
        eligible_sum[x] = eligible_sum[x-1] + (mu[x] if gcd(x,6)==1 else 0)
        v[x] = eligible_sum[x]-eligible_sum[x//2]
        assert m == v[x]-v[x//3]
    print("Mertens identity checked at every cutoff through", limit)
    print("X  V  positive  negative  squarefree  parity fixed at 5,7,11")
    for x in (100, 1000, 10000, 100000, limit):
        pos = neg = control = 0
        for q in range(x//2+1, x+1):
            if gcd(q, 6) != 1 or not mu[q]:
                continue
            pos += int(mu[q] == 1)
            neg += int(mu[q] == -1)
            control += prod_sign(-1 for p in (5,7,11) if q % p == 0)
        assert pos-neg == v[x]
        print(x, v[x], pos, neg, pos+neg, control)

def ratio_checks():
    # Write q=d*a < r=d*b with gcd(a,b)=1. Both orders count in V^2.
    from sage.all import QQ, prime_divisors, RealBallField
    balls = RealBallField(96)
    for x in (100, 1000, 10000, 100000, 1000000):
        y = int(ZZ(x).nth_root(3, truncate_mode=True)[0])
        cutoffs = {y, x.bit_length()-1}
        pos = neg = 0
        main_pi_sq = QQ(0)
        max_height = max(cutoffs)
        # b>=5, hence d<=x/5; retain enough entries also to check small a,b.
        sieve_end = max(x//5, max_height)
        mu = [int(t) for t in moebius.range(0, sieve_end+1)]
        for b in range(2, max_height+1):
            if gcd(b,6) == 1 and mu[b]:
                for a in range(b//2+1, b):
                    if gcd(a,6*b) != 1 or not mu[a]:
                        continue
                    m = 6*a*b
                    weight = mu[a]*mu[b]
                    both = 2*sum(1 for d in range(x//(2*a)+1, x//b+1)
                                 if mu[d] and gcd(d,m) == 1)
                    if weight == 1:
                        pos += both
                    else:
                        neg += both
                        assert b >= 35
                    density_factor = prod_sign(QQ(p)/(p+1) for p in prime_divisors(m))
                    main_pi_sq += 12*weight*(QQ(1)/b-QQ(1)/(2*a))*density_factor
            if b in cutoffs:
                print("ratio", x, b, "low positive/negative/signed", pos, neg, pos-neg,
                      "asymptotic main", x*balls(main_pi_sq)/balls.pi()**2)
                if x <= 1000:
                    band = [(q, int(moebius(q))) for q in range(x//2+1,x+1)
                            if gcd(q,6) == 1 and moebius(q)]
                    low = high = 0
                    for i,(r,wr) in enumerate(band):
                        for q,wq in band[:i]:
                            if r//gcd(q,r) <= b:
                                low += 2*wr*wq
                            else:
                                high += 2*wr*wq
                    assert low == pos-neg
                    assert len(band)+low+high == sum(w for _,w in band)**2
    for a,b,expected in ((5,7,QQ(3)/16),(19,35,-QQ(3)/320)):
        coeff_pi_sq = 12*moebius(a)*moebius(b)*(QQ(1)/b-QQ(1)/(2*a))
        coeff_pi_sq *= prod_sign(QQ(p)/(p+1) for p in prime_divisors(6*a*b))
        assert coeff_pi_sq == expected
    print("fixed ratio coefficients and direct small-band pair checks passed")


def direct_gcd_audit(limit=10**6):
    # Independent tail count. For each r, invert divisibility on the Boolean
    # lattice of its primes to count previous signed rows q with exact gcd(q,r).
    from sage.all import prime_range
    spf = array('I', [0])*(limit+1)
    for pp in prime_range(2, isqrt(limit)+1):
        p = int(pp)
        for k in range(p*p, limit+1, p):
            if not spf[k]:
                spf[k] = p
    for x in (10**4, 10**5, limit):
        y = int(ZZ(x).nth_root(3, truncate_mode=True)[0])
        prefix = array('i', [0])*(x+1)
        low = high = signed = squarefree = 0
        for r in range(x//2+1, x+1):
            if gcd(r,6) != 1:
                continue
            n = r
            divisors = [1]
            sign = 1
            while n != 1:
                p = spf[n] or n
                n //= p
                if n % p == 0:
                    break
                divisors += [p*d for d in divisors]
                sign = -sign
            else:
                exact = [prefix[d] for d in divisors]
                bit = 1
                while bit < len(exact):
                    for mask in range(len(exact)):
                        if mask & bit == 0:
                            exact[mask] -= exact[mask | bit]
                    bit *= 2
                assert sum(exact) == signed
                for d,subtotal in zip(divisors, exact):
                    if r//d <= y:
                        low += 2*sign*subtotal
                    else:
                        high += 2*sign*subtotal
                    prefix[d] += sign
                signed += sign
                squarefree += 1
        assert signed*signed == squarefree+low+high
        print("independent gcd audit X,Y,Q,low,high,V:", x,y,squarefree,low,high,signed)


if __name__ == "__main__":
    print("Sage", SAGE_VERSION)
    viewer_checks()
    walsh_check()
    band_checks()
    ratio_checks()
    direct_gcd_audit()
