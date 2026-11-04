// Skeleton check of the proposed FF-4 statements (freeze_packet_v0_1, headers c5b569b1...).
// Mirrors FF4_DEFINITIONS_PROPOSED_v0_1 exactly (rawDigit, blockValue, Fin indexing, orbitSet, rank,
// orderedOrbit, edgeEnd wrap, directedGap) in BigInt / exact rationals. Finite evidence, not proof.
// The complex statements A1 are checked separately in Sage.
"use strict";
let checks = 0, fails = 0; const log = {};
const ok = (n, c, info) => { checks++; if (!c) { fails++; (log[n] = log[n] || []).length < 4 && log[n].push(String(info)); } };
const gcd = (a, b) => { a = a < 0n ? -a : a; b = b < 0n ? -b : b; while (b) [a, b] = [b, a % b]; return a; };
const Q = (n, d) => { if (d < 0n) { n = -n; d = -d; } const g = gcd(n, d) || 1n; return { n: n / g, d: d / g }; };
const lt = (x, y) => x.n * y.d < y.n * x.d, eq = (x, y) => x.n === y.n && x.d === y.d;
const sub = (x, y) => Q(x.n * y.d - y.n * x.d, x.d * y.d);
const det = (x, y) => x.n * y.d - y.n * x.d, fareyAdj = (x, y) => (det(x, y) < 0n ? -det(x, y) : det(x, y)) === 1n;
const mediant = (x, y) => Q(x.n + y.n, x.d + y.d);   // FF-1: rawValue (num+num) (den+den)
// FF-4 definitions
const rawDigit = (p, q, u, i) => (q - p <= (u + i * p) % q ? 1n : 0n);
const blockValue = (p, q, u, n) => { let s = 0n; for (let i = 0; i < n; i++) s += rawDigit(p, q, u, i) * 2n ** BigInt(n - 1 - i); return s; };
const D = (p, q) => {
  const M = 2n ** BigInt(q) - 1n, word = u => blockValue(p, q, u, q);
  const up = word(p), lo = word(p - 1), iterate = (n, i) => (2n ** BigInt(i) * n) % M;
  const orbit = [...new Set([...Array(q).keys()].map(i => iterate(up, i)))].sort((a, b) => (a < b ? -1 : a > b ? 1 : 0));
  const rank = n => orbit.filter(x => x < n).length;
  const L = orbit.length, edgeEnd = i => (i + 1 < L ? orbit[i + 1] : orbit[0]);
  const gap = i => (i + 1 < L ? edgeEnd(i) - orbit[i] : M + edgeEnd(i) - orbit[i]);
  return { p, q, M, word, up, lo, iterate, orbit, rank, L, edgeEnd, gap, addr: Q(BigInt(p), BigInt(q)),
    upA: Q(up, M), loA: Q(lo, M) };
};
const doms = []; for (let q = 2; q <= 18; q++) for (let p = 1; p < q; p++) if (gcd(BigInt(p), BigInt(q)) === 1n) doms.push(D(p, q));
for (const d of doms) {
  const { p, q, M } = d, tag = p + '/' + q;
  ok('address_canonical', d.addr.n === BigInt(p) && d.addr.d === BigInt(q), tag);
  ok('address_interval', lt(Q(0n, 1n), d.addr) && lt(d.addr, Q(1n, 1n)), tag);
  ok('q_at_least_two', q >= 2, tag); ok('modulus_pos', M > 0n, tag);
  for (let u = 0; u < q; u++) {
    let s = 0n; for (let i = 0; i < q; i++) s += rawDigit(p, q, u, i) * 2n ** BigInt(q - 1 - i);
    ok('word_sum', s === d.word(u), [tag, u]);
    ok('word_bounds', 0n < d.word(u) && d.word(u) < M, [tag, u]);
    ok('rank_word', d.rank(d.word(u)) === u, [tag, u]);
    ok('double_word', (2n * d.word(u)) % M === d.word((u + p) % q), [tag, u]);
    if (u + 1 < q) ok('word_strict', d.word(u) < d.word(u + 1), [tag, u]);
  }
  for (let i = 0; i < q; i++) {
    ok('upper_digit_equiv', rawDigit(p, q, p, i) === (q - p <= ((i + 1) * p) % q ? 1n : 0n), [tag, i]);
    ok('lower_digit_equiv', 1 <= (i + 1) * p && rawDigit(p, q, p - 1, i) === (q - p <= ((i + 1) * p - 1) % q ? 1n : 0n), [tag, i]);
  }
  ok('characteristic_bounds', 0n < d.lo && d.lo < d.up && d.up < M, tag);
  ok('characteristic_adjacent', d.up === d.lo + 1n, tag);
  ok('characteristic_angle_gap', eq(sub(d.upA, d.loA), Q(1n, M)), tag);
  for (const n of [d.lo, d.up]) {
    ok('characteristic_period_return', d.iterate(n, q) === n, tag);
    for (let k = 1; k < q; k++) ok('characteristic_period_minimal', d.iterate(n, k) !== n, [tag, k]);
  }
  ok('same_cycle', [...Array(q).keys()].some(i => d.iterate(d.up, i) === d.lo), tag);
  const words = [...Array(q).keys()].map(u => d.word(u));
  ok('orbit_set_eq', d.orbit.length === words.length && d.orbit.every((x, i) => x === words[i]), tag);
  ok('orbit_card', d.orbit.length === q, tag); ok('orbit_length', d.L === q, tag);
  for (const x of d.orbit) ok('rank_step', d.rank((2n * x) % M) === (d.rank(x) + p) % q, [tag, x]);
  const unit = [...Array(d.L).keys()].filter(i => d.gap(i) === 1n);
  ok('unique_unit_gap', unit.length === 1 && d.orbit[unit[0]] === d.lo && d.edgeEnd(unit[0]) === d.up &&
    [...Array(d.L).keys()].every(j => j === unit[0] || d.gap(j) >= 2n), tag);
}
// address_injective / surjective on the domain grid
const seen = new Map(); for (const d of doms) { const k = d.addr.n + '/' + d.addr.d; ok('address_injective', !seen.has(k), k); seen.set(k, 1); }
for (let b = 2; b <= 18; b++) for (let a = 1; a < b; a++) { const x = Q(BigInt(a), BigInt(b)); ok('address_surjective', seen.has(x.n + '/' + x.d), x.n + '/' + x.d); }
// C1, intervals_disjoint, C2 over all ordered pairs with q <= 18
for (const d of doms) for (const e of doms) if (lt(d.addr, e.addr)) {
  const tag = d.p + '/' + d.q + '<' + e.p + '/' + e.q;
  ok('angle_order', lt(d.upA, e.loA), tag);
  ok('intervals_disjoint', lt(d.upA, e.loA), tag);   // Icc intervals with d.upA < e.loA are disjoint
  if (fareyAdj(d.addr, e.addr) && d.q + e.q <= 18) {
    const m = mediant(d.addr, e.addr), dm = doms.find(x => eq(x.addr, m));
    ok('mediant_interval', !!dm && lt(d.upA, dm.loA) && lt(dm.upA, e.loA), tag);
  }
}
// C3 over all rationals in [-2, 2] with den <= 24 (the statement is over all of Q)
const R = []; const seenR = new Set(); for (let b = 1; b <= 24; b++) for (let a = -2 * b; a <= 2 * b; a++) { const x = Q(BigInt(a), BigInt(b)); const k = x.n + '/' + x.d; if (!seenR.has(k)) { seenR.add(k); R.push(x); } }
R.sort((x, y) => (lt(x, y) ? -1 : lt(y, x) ? 1 : 0));
for (let i = 0; i < R.length; i++) for (let j = i + 1; j < R.length; j++) {
  const x = R[i], y = R[j]; if (!fareyAdj(x, y) || x.d + y.d > 24) continue;
  const m = mediant(x, y);
  for (let k = i + 1; k < j; k++) { const z = R[k];
    ok('farey_denominator_min', x.d + y.d <= z.d, [x.n + '/' + x.d, y.n + '/' + y.d, z.n + '/' + z.d]);
    ok('farey_denominator_eq_iff', (z.d === x.d + y.d) === eq(z, m), [x.n + '/' + x.d, y.n + '/' + y.d, z.n + '/' + z.d]); }
}
console.log(JSON.stringify({ checks, fails, failures: log }, null, 1));
process.exitCode = fails ? 1 : 0;
