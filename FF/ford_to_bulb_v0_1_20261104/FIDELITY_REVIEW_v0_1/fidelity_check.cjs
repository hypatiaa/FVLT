// Independent finite mirror of the FF-4 frozen definitions (BigInt / exact rationals).
// Finite evidence only, not proof.
// Usage: node fidelity_check.cjs [mutation] [QMAX] [QPAIR] [C3DEN]
//   mutations (negative controls): none | reversed_weight | lower_index_plus |
//     wrap_no_modulus | c3_midpoint | swap_hasderiv
'use strict';
const MUT = process.argv[2] || 'none';
const QMAX = +(process.argv[3] || 16), QPAIR = +(process.argv[4] || 12), C3DEN = +(process.argv[5] || 18);
const B = BigInt;
const gcd = (a, b) => { a = a < 0n ? -a : a; b = b < 0n ? -b : b; while (b) { [a, b] = [b, a % b]; } return a; };
// exact rationals, canonical (den > 0, reduced) like Lean's Rat
const R = (n, d = 1n) => { n = B(n); d = B(d); if (d < 0n) { n = -n; d = -d; } const g = gcd(n, d) || 1n; return { n: n / g, d: d / g }; };
const lt = (x, y) => x.n * y.d < y.n * x.d, eq = (x, y) => x.n === y.n && x.d === y.d;
const sub = (x, y) => R(x.n * y.d - y.n * x.d, x.d * y.d);
// Lean Nat truncated subtraction
const tsub = (a, b) => (a > b ? a - b : 0n);

// ---------- frozen data declarations (FVLTFordBulbDataV1) ----------
const rawDigit = (p, q, u, i) => (tsub(q, p) <= (u + i * p) % q ? 1n : 0n);
const blockValue = (p, q, u, n) => {
  let s = 0n;
  for (let i = 0n; i < n; i++) {
    const w = MUT === 'reversed_weight' ? i : tsub(tsub(n, 1n), i);
    s += rawDigit(p, q, u, i) * 2n ** w;
  }
  return s;
};
const modulus = d => tsub(2n ** d.q, 1n);
const upperIndex = d => d.p;
const lowerIndex = d => (MUT === 'lower_index_plus' ? (d.p + 1n) % d.q : tsub(d.p, 1n));
const digit = (d, u, i) => rawDigit(d.p, d.q, u, i);
const wordValue = (d, u) => blockValue(d.p, d.q, u, d.q);
const upperDigit = (d, i) => digit(d, upperIndex(d), i);
const lowerDigit = (d, i) => digit(d, lowerIndex(d), i);
const upperNumerator = d => wordValue(d, upperIndex(d));
const lowerNumerator = d => wordValue(d, lowerIndex(d));
const upperAngle = d => R(upperNumerator(d), modulus(d));
const lowerAngle = d => R(lowerNumerator(d), modulus(d));
const address = d => R(d.p, d.q);
const doubleNum = (d, n) => (2n * n) % modulus(d);
const iterateNum = (d, n, i) => (2n ** i * n) % modulus(d);
const orbitPoint = (d, i) => iterateNum(d, upperNumerator(d), i);
const orbitSet = d => { const s = new Set(); for (let i = 0n; i < d.q; i++) s.add(orbitPoint(d, i)); return [...s]; };
const rank = (d, n) => B(orbitSet(d).filter(x => x < n).length);
const orderedOrbit = d => orbitSet(d).sort((a, b) => (a < b ? -1 : a > b ? 1 : 0));
const edgeStart = (d, i) => orderedOrbit(d)[i];
const edgeEnd = (d, i) => { const L = orderedOrbit(d); return i + 1 < L.length ? L[i + 1] : L[0]; };
const directedGap = (d, i) => {
  const L = orderedOrbit(d);
  if (i + 1 < L.length) return tsub(edgeEnd(d, i), edgeStart(d, i));
  // Lean parse: (modulus d + edgeEnd d i) - edgeStart d i, Nat subtraction
  return MUT === 'wrap_no_modulus' ? tsub(edgeEnd(d, i), edgeStart(d, i)) : tsub(modulus(d) + edgeEnd(d, i), edgeStart(d, i));
};
// ---------- inherited FF-1 ----------
const det = (x, y) => x.n * y.d - y.n * x.d;
const fareyAdj = (x, y) => { const t = det(x, y); return t === 1n || t === -1n; };
const mediant = (x, y) => R(x.n + y.n, x.d + y.d); // rawValue (num sum)/(den sum), Rat-normalized

// ---------- checks ----------
const fails = {}, counts = {};
const chk = (name, ok, ctx) => {
  counts[name] = (counts[name] || 0) + 1;
  if (!ok) { fails[name] = fails[name] || { n: 0, examples: [] }; fails[name].n++; if (fails[name].examples.length < 3) fails[name].examples.push(ctx); }
};
const addrs = [];
for (let q = 2n; q <= B(QMAX); q++) for (let p = 1n; p < q; p++) if (gcd(p, q) === 1n) addrs.push({ p, q });

for (const d of addrs) {
  const { p, q } = d, M = modulus(d), c = `${p}/${q}`;
  const a = address(d);
  chk('address_canonical', a.n === p && a.d === q, c);
  chk('address_interval', lt(R(0), a) && lt(a, R(1)), c);
  chk('q_at_least_two', 2n <= q, c);
  chk('modulus_pos', 0n < M, c);
  const W = []; for (let u = 0n; u < q; u++) W.push(wordValue(d, u));
  for (let u = 0n; u < q; u++) {
    let s = 0n; for (let i = 0n; i < q; i++) s += digit(d, u, i) * 2n ** (q - 1n - i);
    chk('word_sum', W[u] === s, c + ' u' + u);
    chk('word_bounds', 0n < W[u] && W[u] < M, c + ' u' + u);
  }
  for (let i = 0n; i < q; i++) {
    chk('upper_digit_equiv', upperDigit(d, i) === (tsub(q, p) <= ((i + 1n) * p) % q ? 1n : 0n), c + ' i' + i);
    chk('lower_digit_equiv', 1n <= (i + 1n) * p && lowerDigit(d, i) === (tsub(q, p) <= tsub((i + 1n) * p, 1n) % q ? 1n : 0n), c + ' i' + i);
  }
  const Nm = lowerNumerator(d), Np = upperNumerator(d);
  chk('characteristic_bounds', 0n < Nm && Nm < Np && Np < M, c);
  chk('characteristic_adjacent', Np === Nm + 1n, c);
  chk('characteristic_angle_gap', eq(sub(upperAngle(d), lowerAngle(d)), R(1n, M)), c);
  for (const n of [Nm, Np]) {
    chk('characteristic_period_return', iterateNum(d, n, q) === n, c);
    for (let k = 1n; k < q; k++) chk('characteristic_period_minimal', iterateNum(d, n, k) !== n, c + ' k' + k);
  }
  let found = false; for (let i = 0n; i < q; i++) if (orbitPoint(d, i) === Nm) found = true;
  chk('same_cycle', found, c);
  let sm = true; for (let u = 0; u + 1 < W.length; u++) if (!(W[u] < W[u + 1])) sm = false;
  chk('word_strict', sm, c);
  const O = orbitSet(d), Ws = new Set(W);
  chk('orbit_set_eq', O.length === Ws.size && O.every(x => Ws.has(x)), c);
  chk('orbit_card', B(O.length) === q, c);
  chk('orbit_length', B(orderedOrbit(d).length) === q, c);
  for (let u = 0n; u < q; u++) {
    chk('rank_word', rank(d, W[u]) === u, c + ' u' + u);
    chk('double_word', doubleNum(d, W[u]) === wordValue(d, (u + p) % q), c + ' u' + u);
  }
  for (const x of O) chk('rank_step', rank(d, doubleNum(d, x)) === (rank(d, x) + p) % q, c + ' x' + x);
  const L = orderedOrbit(d).length; const wit = [];
  for (let i = 0; i < L; i++) if (edgeStart(d, i) === Nm && edgeEnd(d, i) === Np && directedGap(d, i) === 1n) {
    let ok = true; for (let j = 0; j < L; j++) if (j !== i && !(2n <= directedGap(d, j))) ok = false;
    if (ok) wit.push(i);
  }
  chk('unique_unit_gap', wit.length >= 1, c);
}
// address_injective / address_surjective on the finite range (all p/q with q <= QMAX, unreduced included)
{
  const seen = new Map(); let inj = true;
  for (const d of addrs) { const x = address(d), k = `${x.n}/${x.d}`; if (seen.has(k)) inj = false; seen.set(k, d); }
  chk('address_injective', inj, 'all');
  for (let q = 1n; q <= B(QMAX); q++) for (let p = 1n; p < q; p++) { const x = R(p, q); chk('address_surjective', seen.has(`${x.n}/${x.d}`), `${p}/${q}`); }
}
// C1, C2 on all ordered pairs with q <= QPAIR; mediant address looked up among all q <= QMAX
const small = addrs.filter(d => d.q <= B(QPAIR));
const allByKey = new Map(addrs.map(d => [`${d.p}/${d.q}`, d]));
for (const d of small) for (const e of small) {
  if (!lt(address(d), address(e))) continue;
  const c = `${d.p}/${d.q}<${e.p}/${e.q}`;
  chk('angle_order', lt(upperAngle(d), lowerAngle(e)), c);
  const lo1 = lowerAngle(d), hi1 = upperAngle(d), lo2 = lowerAngle(e), hi2 = upperAngle(e);
  chk('intervals_disjoint', lt(hi1, lo2) || lt(hi2, lo1), c); // Icc in Q disjoint
  if (fareyAdj(address(d), address(e))) {
    const m = mediant(address(d), address(e));
    // the RotationAddress m whose address is the mediant (exists iff 0 < num < den, coprime; canonical Rat is coprime)
    // (v0 of this script looked m up only among q <= QMAX and failed 22 pairs with mediant den > QMAX: harness bug, fixed here)
    const md = (m.n > 0n && m.n < m.d && gcd(m.n, m.d) === 1n) ? { p: m.n, q: m.d } : null;
    chk('mediant_interval', !!md && lt(upperAngle(d), lowerAngle(md)) && lt(upperAngle(md), lowerAngle(e)), c);
  }
}
// C3 over every rational in [-2,2] with den <= C3DEN (negatives and integers included; statement is over all of Q)
const Qs = [];
for (let dd = 1n; dd <= B(C3DEN); dd++) for (let n = -2n * dd; n <= 2n * dd; n++) if (gcd(n, dd) === 1n) Qs.push(R(n, dd));
Qs.sort((x, y) => (lt(x, y) ? -1 : lt(y, x) ? 1 : 0));
let adjPairs = 0, eqHits = 0;
for (let i = 0; i < Qs.length; i++) for (let j = i + 1; j < Qs.length; j++) {
  const x = Qs[i], y = Qs[j]; if (!fareyAdj(x, y)) continue; adjPairs++;
  const m = mediant(x, y);
  const target = MUT === 'c3_midpoint' ? R(x.n * y.d + y.n * x.d, 2n * x.d * y.d) : m;
  for (let k = i + 1; k < j; k++) {
    const z = Qs[k], c = `${x.n}/${x.d},${y.n}/${y.d},${z.n}/${z.d}`;
    chk('farey_denominator_min', x.d + y.d <= z.d, c);
    const lhs = z.d === x.d + y.d; if (lhs) eqHits++;
    chk('farey_denominator_eq_iff', lhs === eq(z, target), c);
  }
}
// A1c exact criterion: exp(2 pi i p/q)^k = 1 iff q | k*p; primitive of order q iff that holds for k = q and fails for 0<k<q
for (const d of addrs) {
  let ok = true; for (let k = 1n; k <= d.q; k++) { const one = (k * d.p) % d.q === 0n; if (one !== (k === d.q)) ok = false; }
  chk('canonical_multiplier_primitive', ok, `${d.p}/${d.q}`);
  const t = 2 * Math.PI * Number(d.p) / Number(d.q); let okf = true;
  for (let k = 1; k <= Number(d.q); k++) { const dist = Math.hypot(Math.cos(k * t) - 1, Math.sin(k * t)); if (k < Number(d.q) ? dist < 1e-9 : dist > 1e-9) okf = false; }
  chk('canonical_multiplier_primitive_float', okf, `${d.p}/${d.q}`);
}
// A1a/A1b and the HasDerivAt argument order (float sanity checks, not exact)
const cm = (a, b) => [a[0] * b[0] - a[1] * b[1], a[0] * b[1] + a[1] * b[0]], ca = (a, b) => [a[0] + b[0], a[1] + b[1]], cs = (a, k) => [a[0] * k, a[1] * k];
const cdist = (a, b) => Math.hypot(a[0] - b[0], a[1] - b[1]);
let seed = 12345; const rnd = () => { seed = (seed * 1103515245 + 12345) % 2147483648; return seed / 2147483648 * 6 - 3; };
for (let t = 0; t < 200; t++) {
  const L = [rnd(), rnd()], al = cs(L, 0.5), c = ca(al, cs(cm(L, L), -0.25)); // alpha, cardioidParameter
  const f = z => ca(cm(z, z), c); // quadratic c z
  chk('parameter_fixed_point', cdist(f(al), al) < 1e-9, 't' + t);
  chk('parameter_multiplier', cdist(cs(al, 2), L) < 1e-12, 't' + t);
  // HasDerivAt f f' x : derivative of f at x is f'. Frozen: f' = lambda, x = alpha lambda.
  const pt = MUT === 'swap_hasderiv' ? L : al, want = MUT === 'swap_hasderiv' ? al : L, h = 1e-6;
  const der = cs(ca(f(ca(pt, [h, 0])), cs(f(ca(pt, [-h, 0])), -1)), 1 / (2 * h));
  chk('parameter_derivative', cdist(der, want) < 1e-6, 't' + t);
}
const total = Object.values(counts).reduce((a, b) => a + b, 0);
const failedChecks = Object.values(fails).reduce((a, b) => a + b.n, 0);
console.log(JSON.stringify({
  mutation: MUT, QMAX, QPAIR, C3DEN, addresses: addrs.length, c3_rationals: Qs.length, c3_adjacent_pairs: adjPairs, c3_equality_hits: eqHits,
  total_checks: total, failed_checks: failedChecks, targets_checked: Object.keys(counts).length,
  failed_targets: Object.keys(fails), counts, fails
}, null, 1));
