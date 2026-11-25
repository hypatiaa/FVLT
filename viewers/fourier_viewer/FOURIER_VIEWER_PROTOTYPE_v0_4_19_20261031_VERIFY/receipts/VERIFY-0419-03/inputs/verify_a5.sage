# Independent verifier, Fourier viewer v0.4.19: A5 claim and dodecahedron arcs. Input: out02/a5_moves.json (the build's own moves, dumped by
# verify_0419.cjs from host-core/pen-sphere-core.js dodecaStep by BFS). Exact over QQ; intervals at 400 bits for the arcs.
import json, sys
D = json.load(open(sys.argv[1]))
res = []
def ok(name, c):
    res.append(bool(c)); print(('PASS ' if c else 'FAIL ') + name)
L = [int(i) + 1 for i in D['L']]; R = [int(i) + 1 for i in D['R']]
S60 = SymmetricGroup(60)
G = PermutationGroup([S60(L), S60(R)])
ok('route 1: permutation group of the two build moves on the 60 flags has order %d' % G.order(), G.order() == 60)
ok('route 1: is_isomorphic(AlternatingGroup(5)) = %s' % G.is_isomorphic(AlternatingGroup(5)), G.is_isomorphic(AlternatingGroup(5)))
ok('route 1: transitive and regular on 60 flags', G.is_transitive() and G.is_regular())
ok('route 1: both moves have order 5 (five lefts / five rights close): %d, %d' % (S60(L).order(), S60(R).order()), S60(L).order() == 5 and S60(R).order() == 5)
from collections import Counter
print('element orders: %s' % sorted(Counter(g.order() for g in G).items()))
ok('element orders 1:1, 2:15, 3:20, 5:24', sorted(Counter(g.order() for g in G).items()) == [(1,1),(2,15),(3,20),(5,24)])
# route 2: transcribed body-frame matrices over K = Q(sqrt3, sqrt5), from the DODECA constants ct = 1/2, st = sqrt3/2, ca = sqrt5/3, sa = 2/3
x = polygen(QQ)
K.<s3, s5> = NumberField([x^2 - 3, x^2 - 5])
ct, st, ca, sa = K(1)/2, s3/2, s5/3, K(2)/3
def M(sg):
    sp = st if sg > 0 else -st
    # columns: new x, new v, new w in old body coordinates (x, v, w): turn v <- ct v + sp w, then walk
    vt = vector(K, [0, ct, sp]); xo = vector(K, [1, 0, 0])
    nx = ca * xo + sa * vt; nv = -sa * xo + ca * vt; nw = nx.cross_product(nv)
    return matrix(K, [nx, nv, nw]).transpose()
Mp, Mm = M(1), M(-1)
ok('route 2: M+ and M- orthogonal with det 1', Mp * Mp.transpose() == 1 and Mm * Mm.transpose() == 1 and Mp.det() == 1 and Mm.det() == 1)
# closure by BFS (exact matrices over K), then the regular permutation representation by left multiplication
def frz(A):
    A = copy(A); A.set_immutable(); return A
I3 = frz(identity_matrix(K, 3)); els = [I3]; idx = {I3: 0}; i = 0
while i < len(els) and len(els) <= 200:
    for g in (Mp, Mm):
        h = frz(els[i] * g)
        if h not in idx: idx[h] = len(els); els.append(h)
    i += 1
ok('route 2: matrix group closure has %d elements' % len(els), len(els) == 60)
Sn = SymmetricGroup(len(els))
perm = lambda g: Sn([idx[frz(g * a)] + 1 for a in els])
H = PermutationGroup([perm(Mp), perm(Mm)])
ok('route 2: regular representation order %d, is_isomorphic(AlternatingGroup(5)) = %s' % (H.order(), H.is_isomorphic(AlternatingGroup(5))), H.order() == 60 and H.is_isomorphic(AlternatingGroup(5)))
# tie route 2 to the dump: flags (x, v) of the build; F0 = [x0 v0 w0] world columns; flag of word g = F0 * M_word; check left move = right-mult by M+
def kel(c):
    n = [Integer(z) for z in c[:4]]; d = Integer(c[4]); return (n[0] + n[1]*s3 + n[2]*s5 + n[3]*s3*s5) / d
flags = [(vector(K, [kel(c) for c in f['x']]), vector(K, [kel(c) for c in f['v']])) for f in D['flags']]
good = True
for i, (fx, fv) in enumerate(flags):
    F = matrix(K, [fx, fv, fx.cross_product(fv)]).transpose()
    for P, sg in ((L, Mp), (R, Mm)):
        G2 = F * sg; j = P[i] - 1
        if not (G2.column(0) == flags[j][0] and G2.column(1) == flags[j][1]): good = False
ok('route 2 = route 1: on all 60 dumped flags, the build move equals right multiplication by the transcribed M+ / M-', good)
V = set(tuple(f[0]) for f in flags)
ok('20 distinct vertices, all unit', len(V) == 20 and all(vector(K, v).dot_product(vector(K, v)) == 1 for v in V))
# arcs: every interior point enclosure contains the true normalised point m_k/|m_k|, m_k = (8-k) a + k b; endpoints joined at dot sqrt5/3
RIF = RealIntervalField(400)
s3I, s5I = RIF(3).sqrt(), RIF(5).sqrt()
def kIv(c):
    n = [Integer(z) for z in c[:4]]; d = Integer(c[4]); return (n[0] + n[1]*s3I + n[2]*s5I + n[3]*s3I*s5I) / d
P = Integer(D['P']); S = 2^P
allin = True; dots = True; maxw = 0; npts = 0
for a in D['arcs']:
    A = [kIv(c) for c in a['a']]; B = [kIv(c) for c in a['b']]
    ae = vector(K, [kel(c) for c in a['a']]); be = vector(K, [kel(c) for c in a['b']])
    if ae.dot_product(be) != s5/3: dots = False
    for k, pt in enumerate(a['pts'], start=1):
        m = [(8 - k) * A[i] + k * B[i] for i in range(3)]
        nr = (m[0]^2 + m[1]^2 + m[2]^2).sqrt()
        for i in range(3):
            tv = m[i] / nr; lo = RIF(Integer(pt[i][0])) / S; hi = RIF(Integer(pt[i][1])) / S
            npts += 1
            w = Integer(pt[i][1]) - Integer(pt[i][0]); maxw = max(maxw, w)
            if not (lo.upper() <= tv.lower() and tv.upper() <= hi.lower()): allin = False
ok('30 edges: endpoints at dot sqrt5/3 exactly (dodecahedron edges)', dots)
ok('arcs: all %d coordinate enclosures (30 edges x 7 points x 3) contain the true normalised point; max width %d / 2^%d' % (npts, maxw, P), allin)
print('SUMMARY verify_a5: %d passed, %d failed' % (res.count(True), res.count(False)))
