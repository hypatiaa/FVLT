// Skeleton check of the proposed FF-3 statements (freeze_packet_v0_1, headers b8a052dc...).
// Mirrors the proposed definitions and inherited FF-1 ones in exact BigInt rationals
// (Lean ℚ: reduced num/den, den > 0). Finite ranges: evidence, not proof.
// The phase statements (complex exponential) are checked separately in Sage, exactly.
"use strict";
let checks = 0, fails = 0; const log = {};
const ok = (n, c, info) => { checks++; if (!c) { fails++; (log[n] = log[n] || []).length < 4 && log[n].push(String(info)); } };
const abs = x => x < 0n ? -x : x;
const gcd = (a, b) => { a = abs(a); b = abs(b); while (b) [a, b] = [b, a % b]; return a; };
const Q = (n, d) => { if (d === 0n) throw "den0"; if (d < 0n) { n = -n; d = -d; } const g = gcd(n, d) || 1n; return { n: n / g, d: d / g }; };
const add = (x, y) => Q(x.n * y.d + y.n * x.d, x.d * y.d), sub = (x, y) => Q(x.n * y.d - y.n * x.d, x.d * y.d);
const mul = (x, y) => Q(x.n * y.n, x.d * y.d), div = (x, y) => Q(x.n * y.d, x.d * y.n);
const eq = (x, y) => x.n === y.n && x.d === y.d, lt = (x, y) => x.n * y.d < y.n * x.d, le = (x, y) => !lt(y, x);
const I = k => Q(BigInt(k), 1n);
const isInt = x => x.d === 1n;
// FF-1 / proposed definitions
const det = (x, y) => x.n * y.d - y.n * x.d;                         // ℤ
const fareyAdj = (x, y) => abs(det(x, y)) === 1n;
const rawValue = (a, q) => Q(BigInt(a), BigInt(q));
const unitFrac = a => Q(1n, BigInt(a));
const fordAddress = (t2, s, n3) => div(mul(I(t2), s), I(n3));
const phaseAddress = (t1, t2, s, n3) => sub(mul(I(t1), s), fordAddress(t2, s, n3));
const gcdFactor = (a, q) => gcd(BigInt(a), BigInt(q));                 // Nat.gcd a.natAbs q
const radiusQ = x => Q(1n, 2n * x.d * x.d);
const kissQ = (x, y) => { const N = x.n * x.d + y.n * y.d, M = x.d * x.d + y.d * y.d; return [Q(N, M), Q(1n, M)]; };
const boundaryCheckQ = (x, z) => { const c = [x, radiusQ(x)]; const dx = sub(z[0], c[0]), dy = sub(z[1], c[1]);
  return eq(add(mul(dx, dx), mul(dy, dy)), mul(radiusQ(x), radiusQ(x))); };
const classifyEdge = (x, y) => eq(x, y) ? "stall" : abs(det(x, y)) === 1n ? "tangent" : "gap";
const IsBreak = (x, y) => !eq(x, y) && !fareyAdj(x, y) && 2n <= abs(det(x, y));
const key = x => x.n + "/" + x.d;
const fareySet = B => { const m = new Map(); for (let q = 1; q <= B; q++) for (let a = 0; a <= q; a++) if (gcd(BigInt(a), BigInt(q)) === 1n) { const x = Q(BigInt(a), BigInt(q)); m.set(key(x), x); } return m; };
const shellEvents = B => { const m = new Map(); for (let N = 2; N <= B + 1; N++) for (let k = 0; k < N; k++) { const s = div(mul(I(k), I(N)), sub(I(N), I(1))); m.set(N + "|" + key(s), [N, s]); } return m; };

// Phase-section arithmetic parts (exact): integer_spin_phase_iff, alias addresses
for (let t1 = -4; t1 <= 4; t1++) for (let t2 = -4; t2 <= 4; t2++) for (let s = -6; s <= 6; s++) for (let n3 = 1; n3 <= 7; n3++)
  ok("integer_spin_phase_iff", isInt(phaseAddress(t1, t2, I(s), n3)) === isInt(fordAddress(t2, I(s), n3)), [t1, t2, s, n3]);
ok("phasor_alias addresses differ", !eq(fordAddress(1, I(0), 3), fordAddress(1, I(3), 3)), "");
ok("phasor_alias phase addresses 0 and 2", eq(phaseAddress(1, 1, I(0), 3), I(0)) && eq(phaseAddress(1, 1, I(3), 3), I(2)), "");
// P1
for (let t2 = -9; t2 <= 9; t2++) for (let s = -12; s <= 12; s++) for (let n3 = 1; n3 <= 15; n3++) {
  const u = BigInt(t2 * s), x = fordAddress(t2, I(s), n3), dv = u % BigInt(n3) === 0n;
  ok("integer_address_iff", (x.d === 1n) === dv, [t2, s, n3]);
  if (dv) ok("integer_address_radius", eq(radiusQ(x), Q(1n, 2n)), [t2, s, n3]);
}
for (let s = 1; s < 200; s++) for (const M of [1, 5, 13, 50, 300]) {
  let w1 = [], w2 = []; for (let N = 1; N <= M; N++) { if (fordAddress(1, I(s), N).d === 1n) w1.push(N); if (s % N === 0) w2.push(N); }
  ok("divisor_recovery_window", w1.join() === w2.join(), [s, M]);
}
for (let M = 0; M <= 30; M++) { let c = 0; for (let N = 1; N <= M; N++) if (fordAddress(1, I(0), N).d === 1n) c++; ok("zero_spin_window", c === M, M); }
for (let t2 = -5; t2 <= 5; t2++) for (let n3 = 1; n3 < 9; n3++) { const x = fordAddress(t2, I(0), n3); ok("zero_spin_address", eq(x, I(0)) && x.d === 1n, [t2, n3]); }
// P2
for (let a = -14; a <= 14; a++) for (let c = -14; c <= 14; c++) for (let q = 1; q <= 14; q++) for (let r = 1; r <= 14; r++) {
  const lhs = abs(det(rawValue(a, q), rawValue(c, r))), g = gcdFactor(a, q) * gcdFactor(c, r), rhs = abs(BigInt(a * r - c * q));
  ok("reduced_det_mul", lhs * g === rhs, [a, c, q, r]);
  ok("reduced_det_quotient (exact division)", rhs % g === 0n && lhs === rhs / g, [a, c, q, r]);
}
// P3
for (let N = 1; N < 300; N++) for (let s = 0; s < N; s++) {
  const x = rawValue(s, N), y = rawValue(s + 1, N), g = gcdFactor(s, N) * gcdFactor(s + 1, N);
  ok("row_law", abs(det(x, y)) * g === BigInt(N), [N, s]);
  ok("row_tangent_iff", fareyAdj(x, y) === (BigInt(N) === g), [N, s]);
}
// P4
for (let u = -150; u <= 150; u++) for (let n = 1; n < 90; n++) {
  const x = rawValue(u, n), y = rawValue(u, n + 1), g = gcdFactor(u, n) * gcdFactor(u, n + 1);
  ok("signed_column_law", abs(det(x, y)) * g === abs(BigInt(u)), [u, n]);
  ok("signed_column_tangent_iff", fareyAdj(x, y) === (abs(BigInt(u)) === g), [u, n]);
  if (u === 0) ok("zero_column_stall", eq(x, y) && det(x, y) === 0n && !fareyAdj(x, y), n);
  if (u > 0) ok("reference_column_tangent_iff", fareyAdj(x, y) === ((n * (n + 1)) % u === 0), [u, n]);
}
for (let n = 1; n < 500; n++) ok("unit_fraction_spine", eq(rawValue(1, n), unitFrac(n)) && fareyAdj(unitFrac(n), unitFrac(n + 1)), n);
// P5 (i): integral phase for rational s in [0,N] iff s = mN/(N-1), m <= N-1. Test all s = p/d, d <= 2N, p/d in [0,N].
for (let N = 2; N <= 14; N++) {
  const cand = new Set(); for (let m = 0; m <= N - 1; m++) cand.add(key(div(mul(I(m), I(N)), sub(I(N), I(1)))));
  const seen = new Map();
  for (let d = 1; d <= 2 * N + 2; d++) for (let p = 0; p <= N * d; p++) { const s = Q(BigInt(p), BigInt(d)); if (seen.has(key(s))) continue; seen.set(key(s), 1);
    ok("shell_contact_parameterization", isInt(phaseAddress(1, 1, s, N)) === cand.has(key(s)), [N, key(s)]); }
  for (let m = 0; m <= N - 1; m++) { const s = div(mul(I(m), I(N)), sub(I(N), I(1)));
    ok("shell_contact_address", eq(fordAddress(1, s, N), Q(BigInt(m), BigInt(N - 1))), [N, m]);
    ok("shell candidates lie in [0,N]", le(I(0), s) && le(s, I(N)), [N, m]); }
}
// P5 (ii)(iii): mem_shellEvents, mem_fareySet, equality, sorted list, consecutive det
for (let B = 1; B <= 60; B++) {
  const F = fareySet(B), E = shellEvents(B);
  for (const [N, s] of E.values()) ok("mem_shellEvents (forward)", N >= 2 && N <= B + 1 && le(I(0), s) && le(s, I(N)) && isInt(phaseAddress(1, 1, s, N)), [B, N, key(s)]);
  if (B <= 12) for (let N = 0; N <= B + 3; N++) for (let d = 1; d <= 2 * N + 2; d++) for (let p = -d; p <= (N + 1) * d; p++) {
    const s = Q(BigInt(p), BigInt(d)); const rhs = N >= 2 && N <= B + 1 && le(I(0), s) && le(s, I(N)) && N > 0 && isInt(phaseAddress(1, 1, s, N));
    ok("mem_shellEvents (iff)", E.has(N + "|" + key(s)) === rhs, [B, N, key(s)]); }
  for (let d = 1; d <= B + 3; d++) for (let p = -2; p <= d + 2; p++) { const x = Q(BigInt(p), BigInt(d));
    ok("mem_fareySet", F.has(key(x)) === (le(I(0), x) && le(x, I(1)) && x.d <= BigInt(B)), [B, key(x)]); }
  const A = new Map(); for (const [N, s] of E.values()) { const x = fordAddress(1, s, N); A.set(key(x), x); }
  ok("shell_addresses_eq_farey", A.size === F.size && [...A.keys()].every(k => F.has(k)), B);
  const L = [...F.values()].sort((x, y) => lt(x, y) ? -1 : lt(y, x) ? 1 : 0);
  ok("fareyList_membership", L.length === F.size, B);
  for (let k = 0; k + 1 < L.length; k++) { ok("fareyList_strict", lt(L[k], L[k + 1]), [B, k]);
    ok("farey_consecutive_det", L[k].d * L[k + 1].n - L[k].n * L[k + 1].d === 1n, [B, k]); }
}
// P6: all pairs of rationals with small denominators
const R = []; for (let d = 1; d <= 9; d++) for (let p = -12; p <= 12; p++) { const x = Q(BigInt(p), BigInt(d)); if (!R.some(y => eq(x, y))) R.push(x); }
for (const x of R) for (const y of R) {
  ok("det_zero_iff_address_equal", (det(x, y) === 0n) === eq(x, y), [key(x), key(y)]);
  const c = classifyEdge(x, y);
  ok("classify_stall_iff", (c === "stall") === eq(x, y), [key(x), key(y)]);
  ok("classify_tangent_iff", (c === "tangent") === fareyAdj(x, y), [key(x), key(y)]);
  ok("classify_break_iff", (c === "gap") === IsBreak(x, y), [key(x), key(y)]);
  const A1 = fareyAdj(x, y), A2 = eq(x, y), A3 = IsBreak(x, y);
  ok("path_edge_trichotomy", (A1 || A2 || A3) && !(A1 && A2) && !(A1 && A3) && !(A2 && A3), [key(x), key(y)]);
  if (A1) { const z = kissQ(x, y); ok("tangent_endpoint_certificate", boundaryCheckQ(x, z) && boundaryCheckQ(y, z), [key(x), key(y)]); }
}
console.log(JSON.stringify({ checks, fails, failures: log }, null, 1));
process.exitCode = fails ? 1 : 0;
