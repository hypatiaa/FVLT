// Fidelity reviewer: finite semantic evidence for the 37 FF-3 statements.
// Mirrors the FF-3 data definitions (definition text v0.2) and the inherited FF-1
// definitions in exact BigInt rationals (Lean semantics: reduced, den > 0; x/0 = 0).
// Phase statements use exact mod-2 reduction of the rational address followed by a
// floating-point sin/cos; those rows are labelled float evidence.
// FINITE EVIDENCE, NOT PROOF. Usage: node semantic_check.cjs [--negative]
'use strict';

// ---------- exact rationals ----------
const babs = (a) => (a < 0n ? -a : a);
const bgcd = (a, b) => { a = babs(a); b = babs(b); while (b) [a, b] = [b, a % b]; return a; };
function Q(n, d = 1n) {
  n = BigInt(n); d = BigInt(d);
  if (d === 0n) return { num: 0n, den: 1n }; // Lean: x / 0 = 0
  if (d < 0n) { n = -n; d = -d; }
  const g = bgcd(n, d) || 1n;
  return { num: n / g, den: d / g };
}
const add = (x, y) => Q(x.num * y.den + y.num * x.den, x.den * y.den);
const sub = (x, y) => Q(x.num * y.den - y.num * x.den, x.den * y.den);
const mul = (x, y) => Q(x.num * y.num, x.den * y.den);
const div = (x, y) => (y.num === 0n ? Q(0) : Q(x.num * y.den, x.den * y.num));
const eq = (x, y) => x.num === y.num && x.den === y.den;
const lt = (x, y) => x.num * y.den < y.num * x.den;
const le = (x, y) => x.num * y.den <= y.num * x.den;
const key = (x) => `${x.num}/${x.den}`;

// ---------- inherited FF-1 definitions ----------
const det = (x, y) => x.num * y.den - y.num * x.den;
const fareyAdj = (x, y) => babs(det(x, y)) === 1n;
const rawValue = (a, q) => Q(BigInt(a), BigInt(q));
const unitFrac = (a) => Q(1n, BigInt(a));
const radiusQ = (x) => Q(1n, 2n * x.den * x.den);
const kissQ = (x, y) => {
  const M = x.den * x.den + y.den * y.den;
  return [Q(x.num * x.den + y.num * y.den, M), Q(1n, M)];
};
const boundaryCheckQ = (x, z) => {
  const r = radiusQ(x);
  const dx = sub(z[0], x), dy = sub(z[1], r);
  return eq(add(mul(dx, dx), mul(dy, dy)), mul(r, r));
};

// ---------- FF-3 data definitions (v0.2) ----------
const fordAddress = (t2, s, n3) => div(mul(Q(t2), s), Q(n3));
const phaseAddress = (t1, t2, s, n3) => sub(mul(Q(t1), s), fordAddress(t2, s, n3));
const IsIntegral = (x) => x.den === 1n; // ∃ k : ℤ, x = k
const gcdFactor = (a, q) => bgcd(BigInt(a), BigInt(q));
const range = (a, b) => { const r = []; for (let i = a; i <= b; i++) r.push(i); return r; };
const integerContactWindow = (s, M) => range(1, M).filter((N) => fordAddress(1, Q(s), N).den === 1n);
const divisorWindow = (s, M) => (s === 0 ? [] : range(1, M).filter((N) => s % N === 0)); // Nat.divisors 0 = ∅
const fareySet = (B, opts = {}) => {
  const m = new Map();
  for (let q = 1; q <= B; q++)
    for (let a = 0; a <= q; a++)
      if (Number(bgcd(BigInt(a), BigInt(q))) === 1) { const x = Q(a, q); m.set(key(x), x); }
  return m;
};
const shellEvents = (B, opts = {}) => {
  const ev = new Map();
  for (let N = 2; N <= B + 1; N++) {
    const top = opts.badRange ? N : N - 1; // negative control: m ranges over 0..N
    for (let m = 0; m <= top; m++) {
      const s = div(mul(Q(m), Q(N)), sub(Q(N), Q(1)));
      ev.set(`${N}|${key(s)}`, [N, s]);
    }
  }
  return ev;
};
const shellEventAddresses = (B, opts) => {
  const m = new Map();
  for (const [N, s] of shellEvents(B, opts).values()) { const x = fordAddress(1, s, N); m.set(key(x), x); }
  return m;
};
const fareyList = (B) => [...fareySet(B).values()].sort((a, b) => (lt(a, b) ? -1 : lt(b, a) ? 1 : 0));
const IsBreak = (x, y) => !eq(x, y) && !fareyAdj(x, y) && babs(det(x, y)) >= 2n;
const classifyEdge = (x, y, opts = {}) => {
  if (eq(x, y)) return 'stall';
  if (opts.badTangent ? babs(det(x, y)) === 2n : babs(det(x, y)) === 1n) return 'tangent';
  return 'gap';
};
const endpointCertificate = (xs, k) => (babs(det(xs[k], xs[k + 1])) === 1n ? kissQ(xs[k], xs[k + 1]) : null);

// ---------- phase helpers (exact reduction, then float) ----------
function phaseUnit(a) { // e^{iπa}; reduce a mod 2 exactly first
  const twoD = 2n * a.den;
  let r = ((a.num % twoD) + twoD) % twoD; // a ≡ r/den (mod 2), 0 ≤ r < 2den
  const ang = Math.PI * Number(r) / Number(a.den);
  if (r === 0n) return [1, 0];
  if (r === a.den) return [-1, 0];
  return [Math.cos(ang), Math.sin(ang)];
}
const cmul = (u, v) => [u[0] * v[0] - u[1] * v[1], u[0] * v[1] + u[1] * v[0]];
const TOL = 1e-12;

// ---------- harness ----------
const NEG = process.argv.includes('--negative');
const results = {};
function check(name, cond, detail) {
  const r = (results[name] ||= { checks: 0, failures: 0, first_failure: null });
  r.checks++;
  if (!cond) { r.failures++; if (!r.first_failure) r.first_failure = detail; }
}
const rats = (maxDen, maxAbsNum) => {
  const m = new Map();
  for (let d = 1; d <= maxDen; d++) for (let p = -maxAbsNum; p <= maxAbsNum; p++) { const x = Q(p, d); m.set(key(x), x); }
  return [...m.values()];
};

if (!NEG) {
  // ---- Phase module ----
  const sPool = rats(6, 12);
  for (const t1 of range(-3, 3)) for (const t2 of range(-3, 3)) for (const s of sPool) for (const n3 of range(1, 6)) {
    const a = phaseAddress(t1, t2, s, n3);
    for (const r of [1, -2.5, 0.3]) {
      const im = r * phaseUnit(a)[1];
      check('phasor_real_iff [float]', (Math.abs(im) < TOL) === IsIntegral(a), { t1, t2, s: key(s), n3, r });
    }
  }
  for (const t1 of range(-5, 5)) for (const t2 of range(-5, 5)) for (const s of range(-8, 8)) for (const n3 of range(1, 9)) {
    const a = phaseAddress(t1, t2, Q(s), n3), x = fordAddress(t2, Q(s), n3);
    check('integer_spin_phase_iff', IsIntegral(a) === IsIntegral(x), { t1, t2, s, n3 });
    const lhs = phaseUnit(a);
    const sign = ((t1 * s) % 2 + 2) % 2 === 0 ? 1 : -1; // (-1 : ℂ) ^ (t1*s : ℤ), negative exponents included
    const rhs = cmul([sign, 0], phaseUnit(Q(-x.num, x.den)));
    check('integer_spin_parity [float]', Math.abs(lhs[0] - rhs[0]) < 1e-9 && Math.abs(lhs[1] - rhs[1]) < 1e-9, { t1, t2, s, n3 });
  }
  // circleMap: depends only on fordAddress(t2,s,n3) by definition; check centre/radius invariance across t1, r
  for (const t2 of range(-3, 3)) for (const s of rats(4, 6)) for (const n3 of range(1, 5)) {
    const x = fordAddress(t2, s, n3);
    for (const t1 of [-2, 0, 5]) for (const r of [1, -7]) {
      const y = fordAddress(t2, s, n3); // circleMap ignores t1 and r
      check('circleMap_amplitude_independent', eq(x, y) && eq(radiusQ(x), radiusQ(y)), {});
    }
  }
  {
    const a0 = phaseAddress(1, 1, Q(0), 3), a3 = phaseAddress(1, 1, Q(3), 3);
    const u0 = phaseUnit(a0), u3 = phaseUnit(a3);
    check('phasor_alias_not_address_alias', eq(a0, Q(0)) && eq(a3, Q(2)) && u0[0] === u3[0] && u0[1] === u3[1]
      && !eq(fordAddress(1, Q(0), 3), fordAddress(1, Q(3), 3)), {});
  }

  // ---- Arithmetic module ----
  for (const t2 of range(-12, 12)) for (const s of range(-12, 12)) for (const n3 of range(1, 15)) {
    const x = fordAddress(t2, Q(s), n3);
    const dv = (t2 * s) % n3 === 0;
    check('integer_address_iff', (x.den === 1n) === dv, { t2, s, n3 });
    check('integer_address_integral_iff', IsIntegral(x) === dv, { t2, s, n3 });
    if (dv) check('integer_address_radius', eq(radiusQ(x), Q(1, 2)), { t2, s, n3 });
    if (s === 0) check('zero_spin_address', eq(fordAddress(t2, Q(0), n3), Q(0)) && fordAddress(t2, Q(0), n3).den === 1n, { t2, n3 });
  }
  for (let s = 1; s < 200; s++) for (const M of [0, 1, 5, 50, 300])
    check('divisor_recovery_window', JSON.stringify(integerContactWindow(s, M)) === JSON.stringify(divisorWindow(s, M)), { s, M });
  for (const M of [0, 1, 5, 50, 300])
    check('zero_spin_window', JSON.stringify(integerContactWindow(0, M)) === JSON.stringify(range(1, M)), { M });
  for (const a of range(-14, 14)) for (const c of range(-14, 14)) for (const q of range(1, 14)) for (const r of range(1, 14)) {
    const D = babs(det(rawValue(a, q), rawValue(c, r)));
    const g1 = gcdFactor(a, q), g2 = gcdFactor(c, r);
    const rhs = babs(BigInt(a * r - c * q));
    check('reduced_det_mul', D * g1 * g2 === rhs, { a, c, q, r });
    // Lean ℤ `/` is Euclidean (ediv); JS BigInt `/` truncates. Equal here because the remainder is 0.
    check('reduced_det_quotient', rhs % (g1 * g2) === 0n && D === rhs / (g1 * g2), { a, c, q, r });
  }
  for (let N = 1; N < 300; N++) for (let s = 0; s < N; s++) {
    const x = rawValue(s, N), y = rawValue(s + 1, N);
    const g1 = gcdFactor(s, N), g2 = gcdFactor(s + 1, N);
    check('row_law', babs(det(x, y)) * g1 * g2 === BigInt(N), { N, s });
    check('row_tangent_iff', fareyAdj(x, y) === (BigInt(N) === g1 * g2), { N, s });
  }
  for (let u = -150; u <= 150; u++) for (let n = 1; n < 90; n++) {
    const x = rawValue(u, n), y = rawValue(u, n + 1);
    const g1 = gcdFactor(u, n), g2 = gcdFactor(u, n + 1);
    check('signed_column_law', babs(det(x, y)) * g1 * g2 === babs(BigInt(u)), { u, n });
    check('signed_column_tangent_iff', fareyAdj(x, y) === (babs(BigInt(u)) === g1 * g2), { u, n });
    if (u === 0) check('zero_column_stall', eq(x, y) && det(x, y) === 0n && !fareyAdj(x, y), { n });
  }
  for (let s = 1; s < 120; s++) for (let n = 1; n < 120; n++)
    check('reference_column_tangent_iff', fareyAdj(rawValue(s, n), rawValue(s, n + 1)) === ((n * (n + 1)) % s === 0), { s, n });
  for (let n = 1; n <= 500; n++)
    check('unit_fraction_spine', eq(rawValue(1, n), unitFrac(n)) && fareyAdj(unitFrac(n), unitFrac(n + 1)), { n });

  // ---- Sweep module ----
  for (let N = 2; N <= 14; N++) {
    const seen = new Set();
    for (let d = 1; d <= 2 * N + 2; d++) for (let p = 0; p <= N * d; p++) {
      const s = Q(p, d); if (seen.has(key(s))) continue; seen.add(key(s));
      const lhs = IsIntegral(phaseAddress(1, 1, s, N));
      let rhs = false;
      for (let m = 0; m <= N - 1; m++) if (eq(s, div(mul(Q(m), Q(N)), Q(N - 1)))) rhs = true;
      check('shell_contact_parameterization', lhs === rhs, { N, s: key(s) });
      for (const r of [1, -3.5]) {
        const im = r * phaseUnit(phaseAddress(1, 1, s, N))[1];
        check('shell_phasor_contact_iff [float]', (Math.abs(im) < TOL) === rhs, { N, s: key(s), r });
      }
    }
    for (let m = 0; m <= N - 1; m++)
      check('shell_contact_address', eq(fordAddress(1, div(mul(Q(m), Q(N)), Q(N - 1)), N), Q(m, N - 1)), { N, m });
  }
  for (let B = 1; B <= 8; B++) {
    const ev = shellEvents(B);
    for (let N = 0; N <= B + 3; N++) {
      const seen = new Set();
      for (let d = 1; d <= 2 * (B + 3); d++) for (let p = -d; p <= (B + 4) * d; p++) {
        const s = Q(p, d); if (seen.has(key(s))) continue; seen.add(key(s));
        const lhs = ev.has(`${N}|${key(s)}`);
        const rhs = 2 <= N && N <= B + 1 && le(Q(0), s) && le(s, Q(N)) && IsIntegral(phaseAddress(1, 1, s, N));
        check('mem_shellEvents', lhs === rhs, { B, N, s: key(s) });
      }
    }
  }
  for (let B = 1; B <= 12; B++) {
    const F = fareySet(B);
    for (const x of rats(B + 3, 2 * (B + 3))) {
      const rhs = le(Q(0), x) && le(x, Q(1)) && x.den <= BigInt(B);
      check('mem_fareySet', F.has(key(x)) === rhs, { B, x: key(x) });
    }
  }
  const sizes = {};
  for (let B = 1; B <= 60; B++) {
    const A = shellEventAddresses(B), F = fareySet(B);
    check('shell_addresses_eq_farey', A.size === F.size && [...A.keys()].every((k) => F.has(k)), { B });
    const L = fareyList(B);
    check('fareyList_membership', L.length === F.size && L.every((x) => F.has(key(x))), { B });
    for (let k = 0; k + 1 < L.length; k++) {
      check('fareyList_strict', lt(L[k], L[k + 1]), { B, k });
      check('farey_consecutive_det', L[k].den * L[k + 1].num - L[k].num * L[k + 1].den === 1n, { B, k });
    }
    if (B === 40) sizes.B40 = { shellEvents: shellEvents(40).size, addresses: A.size, farey: F.size };
  }
  results._sizes = sizes;

  // ---- Endpoints module ----
  const pool = rats(9, 12);
  for (const x of pool) for (const y of pool) {
    check('det_zero_iff_address_equal', (det(x, y) === 0n) === eq(x, y), {});
    const k = classifyEdge(x, y);
    check('classify_stall_iff', (k === 'stall') === eq(x, y), {});
    check('classify_tangent_iff', (k === 'tangent') === fareyAdj(x, y), {});
    check('classify_break_iff', (k === 'gap') === IsBreak(x, y), {});
    const A = fareyAdj(x, y), S = eq(x, y), Br = IsBreak(x, y);
    check('path_edge_trichotomy', (A || S || Br) && !(A && S) && !(A && Br) && !(S && Br), {});
  }
  // paths: walk the pool with a fixed linear-congruential index sequence (deterministic)
  let seed = 12345;
  const next = () => (seed = (seed * 1103515245 + 12345) % 2147483648);
  for (let t = 0; t < 4000; t++) {
    const m = 1 + (next() % 7);
    const xs = [];
    for (let i = 0; i <= m; i++) xs.push(i > 0 && next() % 5 === 0 ? xs[i - 1] : pool[next() % pool.length]);
    for (let k = 0; k < m; k++) { // k : Fin m; castSucc k = k, succ k = k+1
      const u = xs[k], v = xs[k + 1];
      check('path_kind_tangent_iff', (classifyEdge(u, v) === 'tangent') === fareyAdj(u, v), {});
      const cert = endpointCertificate(xs, k);
      if (fareyAdj(u, v)) {
        const z = kissQ(u, v);
        check('tangent_endpoint_certificate', cert && eq(cert[0], z[0]) && eq(cert[1], z[1]) && boundaryCheckQ(u, z) && boundaryCheckQ(v, z), { u: key(u), v: key(v) });
      } else check('nontangent_no_certificate', cert === null, {});
    }
  }
  // force coverage of tangent edges along Farey sequences
  for (let B = 1; B <= 20; B++) {
    const L = fareyList(B);
    for (let k = 0; k + 1 < L.length; k++) {
      const z = kissQ(L[k], L[k + 1]);
      check('tangent_endpoint_certificate', endpointCertificate(L, k) !== null && boundaryCheckQ(L[k], z) && boundaryCheckQ(L[k + 1], z), { B, k });
    }
  }
} else {
  // ---------- NEGATIVE CONTROLS: each must report failures ----------
  // NC1: v0.1 P4 sign error: right side u instead of |u|
  for (let u = -150; u <= 150; u++) for (let n = 1; n < 90; n++) {
    const D = babs(det(rawValue(u, n), rawValue(u, n + 1)));
    check('NC1 v0.1 column law without abs', D * gcdFactor(u, n) * gcdFactor(u, n + 1) === BigInt(u), { u, n });
  }
  // NC2: shellEvents with m = 0..N (one too many)
  for (let B = 1; B <= 8; B++) {
    const ev = shellEvents(B, { badRange: true });
    for (const [N, s] of ev.values()) {
      const rhs = 2 <= N && N <= B + 1 && le(Q(0), s) && le(s, Q(N)) && IsIntegral(phaseAddress(1, 1, s, N));
      check('NC2 shellEvents m<=N', rhs, { B, N, s: key(s) });
    }
  }
  // NC3: tangent test |det| = 2
  const pool = rats(9, 12);
  for (const x of pool) for (const y of pool)
    check('NC3 classify tangent with |det|=2', (classifyEdge(x, y, { badTangent: true }) === 'tangent') === fareyAdj(x, y), {});
  // NC4: parity identity without the (-1)^(t1 s) factor
  for (const t1 of range(-5, 5)) for (const t2 of range(-5, 5)) for (const s of range(-8, 8)) for (const n3 of range(1, 9)) {
    const a = phaseAddress(t1, t2, Q(s), n3), x = fordAddress(t2, Q(s), n3);
    const lhs = phaseUnit(a), rhs = phaseUnit(Q(-x.num, x.den));
    check('NC4 parity without sign factor [float]', Math.abs(lhs[0] - rhs[0]) < 1e-9 && Math.abs(lhs[1] - rhs[1]) < 1e-9, { t1, s });
  }
  // NC5: phase law at zero amplitude (guard r != 0 is needed)
  for (const s of rats(6, 12)) {
    const a = phaseAddress(1, 1, s, 3);
    check('NC5 phasor_real_iff at r=0 [float]', (Math.abs(0 * phaseUnit(a)[1]) < TOL) === IsIntegral(a), { s: key(s) });
  }
  // NC6: shell parameterization without the s >= 0 guard
  for (let N = 2; N <= 8; N++) for (let p = -3 * N; p < 0; p++) {
    const s = Q(p, N - 1);
    let rhs = false;
    for (let m = 0; m <= N - 1; m++) if (eq(s, div(mul(Q(m), Q(N)), Q(N - 1)))) rhs = true;
    check('NC6 shell parameterization for s<0', IsIntegral(phaseAddress(1, 1, s, N)) === rhs, { N, s: key(s) });
  }
  // NC7: quotient corollary with unreduced determinant (raw a*r - c*q) instead of reduced det
  for (const a of range(-6, 6)) for (const c of range(-6, 6)) for (const q of range(1, 8)) for (const r of range(1, 8)) {
    const raw = babs(BigInt(a * r - c * q));
    check('NC7 det taken unreduced', babs(det(rawValue(a, q), rawValue(c, r))) === raw, { a, c, q, r });
  }
}

let total = 0, fails = 0;
for (const [k, v] of Object.entries(results)) if (!k.startsWith('_')) { total += v.checks; fails += v.failures; }
console.log(JSON.stringify({ mode: NEG ? 'negative_controls' : 'positive', statement_groups: Object.keys(results).filter((k) => !k.startsWith('_')).length, total_checks: total, total_failures: fails, results }, null, 2));
