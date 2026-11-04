// FF-2 fidelity review: finite semantic check of the 28 statements AND of the
// definitions against the work order's prose, written independently by the
// fidelity reviewer (not a copy of the producer's or skeleton's checker).
// Finite evidence only, not a proof. Usage: node mirror_check_v0_1.cjs [maxOmega] [maxAB]
'use strict';
const fs = require('fs'), path = require('path');
const MAXW = +(process.argv[2] || 10), MAXAB = +(process.argv[3] || 6);
const out = []; const log = s => { out.push(s); console.log(s); };
const tally = {}; let fails = 0; const failMsgs = [];
function ck(tag, c, msg) { tally[tag] = (tally[tag] || 0) + 1; if (!c) { fails++; if (failMsgs.length < 50) failMsgs.push(tag + ': ' + msg()); } }
const pc = v => { let c = 0; while (v) { c += v & 1; v >>>= 1; } return c; };
const emod = (z, m) => ((z % m) + m) % m;

for (let w = 3; w <= MAXW; w++) {
  const cyc = z => emod(z, w); // Lean: Fin.ofNat w ((z % w).toNat); Int % is emod
  const next = i => cyc(i + 1), prev = i => cyc(i - 1);
  const has = (v, d) => ((v >> d) & 1) === 1;
  const ins = (v, d) => v | (1 << d), era = (v, d) => v & ~(1 << d);
  const toggle = (v, d) => v ^ (1 << d);
  const eps = v => (pc(v) % 2 === 0 ? 1 : -1);
  const NV = 1 << w;
  const edges = [], squares = [];
  for (let v = 0; v < NV; v++) for (let d = 0; d < w; d++) {
    if (!has(v, d)) edges.push([v, d]);
    if (!has(v, d) && !has(v, next(d))) squares.push([v, d]);
  }
  const ek = (v, d) => v * 64 + d; // edge key = (lower, dir)
  const mkEdge = (v, d) => ek(era(v, d), d);
  const lower = k => Math.floor(k / 64), dirOf = k => k % 64, upper = k => ins(lower(k), dirOf(k));
  const squareAt = (x, i) => [era(era(x, i), next(i)), i];
  const sqKey = f => f[0] * 64 + f[1];
  const corners = f => { const [v, i] = f, j = next(i); return new Set([v, ins(v, i), ins(v, j), ins(ins(v, i), j)]); };
  const bcache = new Map();
  function boundary(f) {
    const key = sqKey(f); if (bcache.has(key)) return bcache.get(key);
    const [v, i] = f, j = next(i), e = eps(v), m = new Map();
    const add = (k, c) => m.set(k, (m.get(k) || 0) + c);
    add(mkEdge(v, i), e); add(mkEdge(ins(v, i), j), e); add(mkEdge(ins(v, j), i), -e); add(mkEdge(v, j), -e);
    for (const [k, c] of [...m]) if (c === 0) m.delete(k);
    bcache.set(key, m); return m;
  }
  const coeff = (f, k) => boundary(f).get(k) || 0;
  // A1 counts, chi, genus
  const V = NV, E = edges.length, F = squares.length;
  ck('A1.vertex_count', V === 2 ** w, () => `w=${w}`);
  ck('A1.edge_count', E === w * 2 ** (w - 1), () => `w=${w} E=${E}`);
  ck('A1.square_count', F === w * 2 ** (w - 2), () => `w=${w} F=${F}`);
  const chi = V - E + F;
  ck('A1.chi_formula', chi === 2 ** (w - 2) * (4 - w), () => `w=${w} chi=${chi}`);
  ck('A6.chi_even', chi % 2 === 0, () => `w=${w}`);
  const genus = 1 - Math.trunc(chi / 2); // chi even, so every rounding convention agrees
  ck('A6.genus_formula', genus === 1 + (w - 4) * 2 ** (w - 3), () => `w=${w} g=${genus}`);
  if (w === 3) ck('A6.cube_genus_zero', genus === 0, () => `g=${genus}`);
  // definition checks on boundary: four distinct edges, no cancellation; d1 d2 = 0
  const incid = new Map(); const total = new Map();
  const edgeSet = new Set(edges.map(([v, d]) => ek(v, d)));
  for (const f of squares) {
    const B = boundary(f), C = corners(f);
    ck('DEF.boundary_four_terms', B.size === 4, () => `w=${w} f=${f}`);
    ck('DEF.corners_four', C.size === 4, () => `w=${w} f=${f}`);
    const d1 = new Map();
    for (const [k, c] of B) {
      ck('DEF.boundary_coeff_is_pm_eps', c === eps(f[0]) || c === -eps(f[0]), () => `w=${w}`);
      ck('DEF.boundary_support_is_geometric_face', C.has(lower(k)) && C.has(upper(k)), () => `w=${w} f=${f} e=${k}`);
      d1.set(upper(k), (d1.get(upper(k)) || 0) + c); d1.set(lower(k), (d1.get(lower(k)) || 0) - c);
      if (!incid.has(k)) incid.set(k, []); incid.get(k).push(f);
      total.set(k, (total.get(k) || 0) + c);
    }
    ck('DEF.boundary_is_cycle(d1d2=0)', [...d1.values()].every(x => x === 0), () => `w=${w} f=${f}`);
    // geometric faces of f (cube edges with both ends among corners) are exactly the support
    let geo = 0;
    for (const x of C) for (let d = 0; d < w; d++) if (!has(x, d) && C.has(ins(x, d))) { geo++; ck('DEF.geometric_face_in_support', B.has(ek(x, d)), () => `w=${w}`); }
    ck('DEF.four_geometric_faces', geo === 4, () => `w=${w}`);
  }
  // A2, A4
  for (const [v, d] of edges) {
    const k = ek(v, d), L = incid.get(k) || [];
    const fa = squareAt(v, prev(d)), fb = squareAt(v, d);
    ck('A2.incident_pair_distinct', sqKey(fa) !== sqKey(fb), () => `w=${w}`);
    const got = new Set(L.map(sqKey));
    ck('A2.incident_pair_exhaustive', got.size === 2 && got.has(sqKey(fa)) && got.has(sqKey(fb)), () => `w=${w} e=${v},${d}`);
    ck('A2.incident_square_count', L.length === 2, () => `w=${w}`);
    if (L.length === 2) ck('A4.incident_coefficients_opposite', coeff(L[0], k) === -coeff(L[1], k), () => `w=${w}`);
    const pairs = new Set(L.map(f => [f[1], next(f[1])].sort((p, q) => p - q).join('-')));
    ck('A2.seat_pairs_match_prose', pairs.has([prev(d), d].sort((p, q) => p - q).join('-')) && pairs.has([d, next(d)].sort((p, q) => p - q).join('-')), () => `w=${w}`);
  }
  ck('A4.total_boundary_zero', [...total.values()].every(x => x === 0), () => `w=${w}`);
  // negative control: without the eps(v) factor, A4 must fail somewhere
  if (w <= 6) {
    const tot2 = new Map(); const add2 = (k, c) => tot2.set(k, (tot2.get(k) || 0) + c);
    for (const [v, i] of squares) { const j = next(i); add2(mkEdge(v, i), 1); add2(mkEdge(ins(v, i), j), 1); add2(mkEdge(ins(v, j), i), -1); add2(mkEdge(v, j), -1); }
    ck('A4.control_without_eps_fails', [...tot2.values()].some(x => x !== 0), () => `w=${w}`);
  }
  // A3 link, A5 cube
  const squaresAt = new Map();
  for (const f of squares) for (const c of corners(f)) { if (!squaresAt.has(c)) squaresAt.set(c, []); squaresAt.get(c).push(f); }
  for (let x = 0; x < NV; x++) {
    let incCount = 0; const dirs = new Set();
    for (let d = 0; d < w; d++) { const k = mkEdge(x, d); if (edgeSet.has(k) && (lower(k) === x || upper(k) === x)) { incCount++; dirs.add(dirOf(k)); } }
    // independent count of incident edges straight from the Edge type
    let incCount2 = 0; for (let d = 0; d < w; d++) { if (!has(x, d)) incCount2++; if (has(x, d)) incCount2++; }
    ck('A3.incident_direction_equiv', incCount === w && dirs.size === w && incCount2 === w, () => `w=${w}`);
    const sqAtX = squaresAt.get(x) || [];
    ck('A3.squares_at_vertex_count_omega', sqAtX.length === w, () => `w=${w} x=${x} n=${sqAtX.length}`);
    for (let i = 0; i < w; i++) for (let j = 0; j < w; j++) {
      const carriers = sqAtX.filter(f => { const C = corners(f); return C.has(toggle(x, i)) && C.has(toggle(x, j)); });
      const linkAdj = i !== j && carriers.length > 0;
      ck('A3.link_cycle', linkAdj === (j === next(i) || i === next(j)), () => `w=${w} x=${x} i=${i} j=${j}`);
      if (linkAdj) ck('A3.link_simple(multiplicity_one)', carriers.length === 1, () => `w=${w}`);
    }
    if (w <= 7) for (let y = 0; y < NV; y++) {
      let adj = false; for (let d = 0; d < w; d++) if (y === toggle(x, d)) adj = true;
      let isEdge = false; for (let d = 0; d < w; d++) { if (!has(x, d) && y === ins(x, d)) isEdge = true; if (!has(y, d) && x === ins(y, d)) isEdge = true; }
      ck('A5.cube_edge_iff', adj === isEdge, () => `w=${w}`);
    }
  }
  { const seen = new Uint8Array(NV); const q = [0]; seen[0] = 1;
    while (q.length) { const x = q.pop(); for (let d = 0; d < w; d++) { const y = toggle(x, d); if (!seen[y]) { seen[y] = 1; q.push(y); } } }
    ck('A5.cube_connected', seen.every(s => s === 1), () => `w=${w}`); }
  // A7, A8 pen
  const step = (s, st) => { const d = cyc(st[1] - s * eps(st[0])); return [toggle(st[0], d), d]; };
  const dirCoef = (x, y, k) => (x === lower(k) && y === upper(k)) ? 1 : (x === upper(k) && y === lower(k)) ? -1 : 0;
  for (let v = 0; v < NV; v++) for (let b = 0; b < w; b++) for (const s of [1, -1]) {
    const st = [v, b]; const n1 = step(s, st);
    ck('A7.pen_adjacent_seat', (n1[1] === next(b) || n1[1] === prev(b)) && n1[1] !== b, () => `w=${w}`);
    const kb = mkEdge(v, b), kd = mkEdge(v, n1[1]);
    const cands = (squaresAt.get(v) || []).filter(f => coeff(f, kb) !== 0 && coeff(f, kd) !== 0);
    const candsAll = squares.length <= 400 ? squares.filter(f => coeff(f, kb) !== 0 && coeff(f, kd) !== 0) : cands;
    ck('A7.unique_square_with_both_edges', cands.length === 1 && candsAll.length === 1, () => `w=${w}`);
    const din = dirCoef(toggle(v, b), v, kb), dout = dirCoef(v, n1[0], kd);
    ck('A7.directed_nonzero', din !== 0 && dout !== 0, () => `w=${w}`);
    ck('A7.pen_oriented_square', cands.some(f => din === s * coeff(f, kb) && dout === s * coeff(f, kd)), () => `w=${w} st=${st} s=${s}`);
    ck('A7.control_opposite_sign_fails', !cands.some(f => din === -s * coeff(f, kb) && dout === -s * coeff(f, kd)), () => `w=${w}`);
    let cur = st; const vis = [st[0]]; const it = [st];
    for (let k = 1; k <= 4; k++) { cur = step(s, cur); it.push(cur); if (k < 4) vis.push(cur[0]); }
    ck('A8.pen_return_four', it[4][0] === v && it[4][1] === b, () => `w=${w}`);
    for (let k = 1; k < 4; k++) ck('A8.pen_no_earlier_return', !(it[k][0] === v && it[k][1] === b), () => `w=${w} k=${k}`);
    const VS = new Set(vis);
    ck('A8.pen_four_corners', VS.size === 4 && (squaresAt.get(v) || []).some(f => { const C = corners(f); return [...C].every(c => VS.has(c)); }), () => `w=${w}`);
  }
  log(`omega=${w}: V=${V} E=${E} F=${F} chi=${chi} genus=${genus}`);
}

// Part B
const mkKey = (a, b) => {
  const net = (X, Y) => { const x = emod(X, 2 * a), y = emod(Y, 2 * b); return b < y ? [(2 * a - x) % (2 * a), 2 * b - y] : [x, y]; };
  return (X, Y) => { const [x, y] = net(X, Y); const r = x <= a ? x : 2 * a - x;
    if (r === 0 || r === a || y === 0 || y === b) return `B:${r},${y}`; return x < a ? `F:${r},${y}` : `K:${r},${y}`; };
};
const pb = [];
for (let a = 1; a <= MAXAB; a++) for (let b = 1; b <= MAXAB; b++) {
  const key = mkKey(a, b);
  // relation: w-v in L or w+v in L, L = 2aZ x 2bZ (pillowRel unfolded)
  const red = (X, Y) => [emod(X, 2 * a), emod(Y, 2 * b)];
  const cls = (X, Y) => { const p = red(X, Y), q = red(-X, -Y); return (p[0] < q[0] || (p[0] === q[0] && p[1] <= q[1])) ? p.join(',') : q.join(','); };
  const R = 3; const k2c = new Map(), c2k = new Map();
  const cornerCls = [[0, 0], [a, 0], [0, b], [a, b]].map(([x, y]) => cls(x, y));
  for (let X = -R * 2 * a; X < R * 2 * a; X++) for (let Y = -R * 2 * b; Y < R * 2 * b; Y++) {
    const k = key(X, Y), c = cls(X, Y);
    if (!k2c.has(k)) k2c.set(k, c); ck('B1.key_classifies(key=>rel)', k2c.get(k) === c, () => `a=${a} b=${b} (${X},${Y})`);
    if (!c2k.has(c)) c2k.set(c, k); ck('B1.key_classifies(rel=>key)', c2k.get(c) === k, () => `a=${a} b=${b} (${X},${Y})`);
    let lit = false; // literal HasFixingHalfTurn: exists i j, (2ia - X, 2jb - Y) = (X, Y)
    for (let i = -2 * R - 1; i <= 2 * R + 1 && !lit; i++) for (let j = -2 * R - 1; j <= 2 * R + 1 && !lit; j++) if (2 * i * a - X === X && 2 * j * b - Y === Y) lit = true;
    const mult = emod(X, a) === 0 && emod(Y, b) === 0;
    ck('B2.fixingHalfTurn_iff_multiples', lit === mult, () => `a=${a} b=${b}`);
    ck('B2.fixingHalfTurn_iff_corner_class', lit === cornerCls.includes(c), () => `a=${a} b=${b} (${X},${Y})`);
    for (let i = -2; i <= 2; i++) for (let j = -2; j <= 2; j++) if (i || j) ck('B2.nonzero_translation_fixes_nothing', !(X + 2 * i * a === X && Y + 2 * j * b === Y), () => '');
  }
  ck('B2.four_corner_classes_distinct', new Set(cornerCls).size === 4, () => `a=${a} b=${b}`);
  ck('B2.four_corner_keys_distinct', new Set([[0, 0], [a, 0], [0, b], [a, b]].map(([x, y]) => key(x, y))).size === 4, () => `a=${a} b=${b}`);
  pb.push(`a=${a} b=${b}: classes in window=${c2k.size} (expected 2ab+2 = ${2 * a * b + 2})`);
  ck('B.class_count_2ab+2', c2k.size === 2 * a * b + 2, () => `a=${a} b=${b}`);
}
// literal pillowRel cross-validation for small a,b (search i,j directly; window +-2 periods)
for (let a = 1; a <= 3; a++) for (let b = 1; b <= 3; b++) {
  const key = mkKey(a, b);
  const pts = []; for (let X = -2 * a; X < 2 * a; X++) for (let Y = -2 * b; Y < 2 * b; Y++) pts.push([X, Y]);
  for (const [X, Y] of pts) for (const [U, W] of pts) {
    let rel = false;
    for (let i = -3; i <= 3 && !rel; i++) for (let j = -3; j <= 3 && !rel; j++)
      if ((U === X + 2 * i * a && W === Y + 2 * j * b) || (U === 2 * i * a - X && W === 2 * j * b - Y)) rel = true;
    ck('B1.literal_pillowRel_pairwise', (key(X, Y) === key(U, W)) === rel, () => `a=${a} b=${b}`);
  }
}
for (let a = 0; a <= 3; a++) for (let b = 0; b <= 3; b++) for (let i = -3; i <= 3; i++) for (let j = -3; j <= 3; j++)
  ck('B2.halfTurn_not_identity(witness i*a+1)', (2 * i * a - (i * a + 1)) !== i * a + 1, () => '');
pb.forEach(s => log(s));
log('--- check counts by tag (finite evidence, not proof) ---');
let tot = 0; for (const t of Object.keys(tally).sort()) { log(`${t}: ${tally[t]}`); tot += tally[t]; }
log(`TOTAL checks: ${tot}; failures: ${fails}`);
failMsgs.forEach(m => log('FAIL ' + m));
fs.writeFileSync(path.join(__dirname, 'mirror_check_v0_1.out.txt'), `args: maxOmega=${MAXW} maxAB=${MAXAB}\n` + out.join('\n') + '\n');
