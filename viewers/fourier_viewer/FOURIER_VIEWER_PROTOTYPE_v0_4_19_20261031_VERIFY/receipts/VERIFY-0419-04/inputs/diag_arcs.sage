# diagnose the arc containment failure of VERIFY-0419-03: list every failing coordinate with the exact gap
import json, sys
D = json.load(open(sys.argv[1]))
RIF = RealIntervalField(600); s3I, s5I = RIF(3).sqrt(), RIF(5).sqrt()
def kIv(c):
    n = [Integer(z) for z in c[:4]]; d = Integer(c[4]); return (n[0] + n[1]*s3I + n[2]*s5I + n[3]*s3I*s5I) / d
P = Integer(D['P']); S = 2^P; nf = 0; nund = 0; nout = 0
for ei, a in enumerate(D['arcs']):
    A = [kIv(c) for c in a['a']]; B = [kIv(c) for c in a['b']]
    for k, pt in enumerate(a['pts'], start=1):
        m = [(8 - k) * A[i] + k * B[i] for i in range(3)]
        nr = (m[0]^2 + m[1]^2 + m[2]^2).sqrt()
        for i in range(3):
            tv = m[i] / nr; lo = Integer(pt[i][0]); hi = Integer(pt[i][1]); sv = tv * S
            inside = (RIF(lo) <= sv) and (sv <= RIF(hi))
            outside = (sv < RIF(lo)) or (sv > RIF(hi))
            if not inside:
                nf += 1
                if outside: nout += 1
                else: nund += 1
                if nf <= 12: print('edge %d k %d coord %d: lo %d hi %d true*2^P %s  (%s)' % (ei, k, i, lo, hi, sv.center().str(no_sci=2)[:40], 'OUTSIDE' if outside else 'undecided at 600 bits'))
print('not certainly inside: %d (certainly outside: %d, undecided: %d) of %d' % (nf, nout, nund, 30*7*3))
