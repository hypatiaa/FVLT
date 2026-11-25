# decide exactly, in K = Q(sqrt3, sqrt5), every arc coordinate whose build enclosure is [0, 0]: the exact m_k coordinate must be 0
import json, sys
D = json.load(open(sys.argv[1]))
x = polygen(QQ); K.<s3, s5> = NumberField([x^2 - 3, x^2 - 5])
def kel(c):
    n = [Integer(z) for z in c[:4]]; d = Integer(c[4]); return (n[0] + n[1]*s3 + n[2]*s5 + n[3]*s3*s5) / d
zero_iv = 0; zero_exact = 0; bad = 0
for a in D['arcs']:
    A = [kel(c) for c in a['a']]; B = [kel(c) for c in a['b']]
    for k, pt in enumerate(a['pts'], start=1):
        for i in range(3):
            mi = (8 - k) * A[i] + k * B[i]
            if Integer(pt[i][0]) == 0 and Integer(pt[i][1]) == 0:
                zero_iv += 1
                if mi == 0: zero_exact += 1
                else: bad += 1
            elif mi == 0: bad += 1
print('enclosures equal to [0,0]: %d; exact coordinate 0 in K: %d; mismatches either way: %d' % (zero_iv, zero_exact, bad))
print(('PASS' if bad == 0 else 'FAIL') + ' arc zero coordinates decided exactly')
