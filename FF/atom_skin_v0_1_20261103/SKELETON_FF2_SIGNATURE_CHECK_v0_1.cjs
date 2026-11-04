// Skeleton check of the proposed FF-2 signatures (freeze_packet_v0_1), mirroring the proposed
// Lean definitions exactly: vertices as bitmasks, edges (lower, d) with d not in lower,
// squares (v, i) with i, next i not in v, mkEdge = (v.erase d, d), boundary with epsilon(v).
// Finite ranges: evidence, not proof.
"use strict";
let checks = 0, fails = 0; const log = {};
const ok = (name, c, info) => { checks++; if (!c) { fails++; (log[name] = log[name] || []).length < 4 && log[name].push(info); } };
const pc = v => { let c = 0; while (v) { c += v & 1; v >>= 1; } return c; };
const mod = (a, n) => ((a % n) + n) % n;

for (let w = 3; w <= 9; w++) {
  const V = 1 << w, nxt = i => mod(i + 1, w), prv = i => mod(i - 1, w), eps = v => (pc(v) & 1) ? -1 : 1;
  const edges = []; for (let v = 0; v < V; v++) for (let d = 0; d < w; d++) if (!(v >> d & 1)) edges.push([v, d]);
  const ek = (l, d) => l + "," + d;
  const squares = []; for (let v = 0; v < V; v++) for (let i = 0; i < w; i++) if (!(v >> i & 1) && !(v >> nxt(i) & 1)) squares.push([v, i]);
  const sk = s => s[0] + "," + s[1];
  const mkEdge = (v, d) => [v & ~(1 << d), d];
  const boundary = ([v, i]) => { const j = nxt(i), e = eps(v), m = new Map();
    const add = (ed, c) => { const k = ek(...ed); m.set(k, (m.get(k) || 0) + c); };
    add(mkEdge(v, i), e); add(mkEdge(v | 1 << i, j), e); add(mkEdge(v | 1 << j, i), -e); add(mkEdge(v, j), -e);
    for (const [k, c] of m) if (c === 0) m.delete(k); return m; };
  const B = new Map(squares.map(s => [sk(s), boundary(s)]));
  const coef = (s, ed) => B.get(sk(s)).get(ek(...ed)) || 0;
  const squareAt = (x, i) => [x & ~(1 << i) & ~(1 << nxt(i)), i];
  const corners = ([v, i]) => { const j = nxt(i); return new Set([v, v | 1 << i, v | 1 << j, v | 1 << i | 1 << j]); };
  const toggle = (v, d) => v ^ (1 << d);
  const lower = e => e[0], upper = e => e[0] | 1 << e[1];
  const dirCoef = (x, y, e) => (x === lower(e) && y === upper(e)) ? 1 : (x === upper(e) && y === lower(e)) ? -1 : 0;
  // A1
  const chi = V - edges.length + squares.length;
  ok("A1 counts", V === 2 ** w && edges.length === w * 2 ** (w - 1) && squares.length === w * 2 ** (w - 2), w);
  ok("A1 chi_formula", chi === 2 ** (w - 2) * (4 - w), w);
  // A2
  for (const e of edges) {
    const f1 = squareAt(lower(e), prv(e[1])), f2 = squareAt(lower(e), e[1]);
    ok("A2 incident_pair_distinct", sk(f1) !== sk(f2), [w, e] + "");
    const inc = squares.filter(s => coef(s, e) !== 0).map(sk).sort();
    ok("A2 incident_pair_exhaustive", JSON.stringify(inc) === JSON.stringify([sk(f1), sk(f2)].sort()), [w, e] + "");
    ok("A2 incident_square_count", inc.length === 2, [w, e] + "");
    // A4 opposite coefficients
    const cs = squares.filter(s => coef(s, e) !== 0).map(s => coef(s, e));
    ok("A4 incident_coefficients_opposite", cs.length === 2 && cs[0] === -cs[1], [w, e] + "");
  }
  // A4 total boundary zero
  const tot = new Map(); for (const s of squares) for (const [k, c] of B.get(sk(s))) tot.set(k, (tot.get(k) || 0) + c);
  ok("A4 total_boundary_zero", [...tot.values()].every(c => c === 0), w);
  // A3
  for (let x = 0; x < V; x++) {
    const incE = edges.filter(e => x === lower(e) || x === upper(e)).map(e => e[1]).sort((a, b) => a - b);
    ok("A3 incident_direction_equiv", JSON.stringify(incE) === JSON.stringify([...Array(w).keys()]), [w, x] + "");
    for (let i = 0; i < w; i++) for (let j = 0; j < w; j++) {
      const la = i !== j && squares.some(s => { const C = corners(s); return C.has(x) && C.has(toggle(x, i)) && C.has(toggle(x, j)); });
      ok("A3 link_cycle", la === (j === nxt(i) || i === nxt(j)), [w, x, i, j] + "");
    }
  }
  // A6
  ok("A6 chi_even", chi % 2 === 0, w);
  ok("A6 genus_formula", 1 - chi / 2 === 1 + (w - 4) * 2 ** (w - 3), w);
  if (w === 3) ok("A6 cube_genus_zero", 1 - chi / 2 === 0, w);
  // A7, A8 over every state and sign
  const step = (s, [v, b]) => { const d = mod(b - s * eps(v), w); return [toggle(v, d), d]; };
  for (let v = 0; v < V; v++) for (let b = 0; b < w; b++) for (const s of [1, -1]) {
    const st = [v, b], st1 = step(s, st), d = st1[1];
    ok("A7 pen_adjacent_seat", (d === nxt(b) || d === prv(b)) && d !== b, [w, v, b, s] + "");
    const eIn = mkEdge(v, b), eOut = mkEdge(v, d);
    const good = squares.some(f => coef(f, eIn) !== 0 && coef(f, eOut) !== 0 &&
      dirCoef(toggle(v, b), v, eIn) === s * coef(f, eIn) &&
      dirCoef(v, st1[0], eOut) === s * coef(f, eOut));
    ok("A7 pen_oriented_square", good, [w, v, b, s] + "");
    let cur = st; const traj = [cur]; for (let k = 1; k <= 4; k++) { cur = step(s, cur); traj.push(cur); }
    ok("A8 pen_return_four", traj[4][0] === v && traj[4][1] === b, [w, v, b, s] + "");
    for (let k = 1; k < 4; k++) ok("A8 pen_no_earlier_return", !(traj[k][0] === v && traj[k][1] === b), [w, v, b, s, k] + "");
    const four = new Set(traj.slice(0, 4).map(t => t[0]));
    ok("A8 pen_four_corners", squares.some(f => { const C = corners(f); return C.size === four.size && [...four].every(c => C.has(c)); }), [w, v, b, s] + "");
  }
}

// Part B
for (let a = 1; a <= 6; a++) for (let b = 1; b <= 6; b++) {
  const md = (x, n) => ((x % n) + n) % n;
  const net = ([X, Y]) => { const x = md(X, 2 * a), y = md(Y, 2 * b); return b < y ? [md(2 * a - x, 2 * a), 2 * b - y] : [x, y]; };
  const key = v => { const [x, y] = net(v), r = x <= a ? x : 2 * a - x; return (r === 0 || r === a || y === 0 || y === b) ? "B" + r + "," + y : (x < a ? "F" : "K") + r + "," + y; };
  const rel = ([X, Y], [U, W]) => (md(U - X, 2 * a) === 0 && md(W - Y, 2 * b) === 0) || (md(U + X, 2 * a) === 0 && md(W + Y, 2 * b) === 0);
  const pts = []; for (let X = -2 * a; X <= 4 * a; X++) for (let Y = -2 * b; Y <= 4 * b; Y++) pts.push([X, Y]);
  for (const p of pts) for (const q of pts) ok("B1 key_classifies", (key(p) === key(q)) === rel(p, q), [a, b, p, q] + "");
  const corner = c => [c[0] ? a : 0, c[1] ? b : 0], C = [[0, 0], [1, 0], [0, 1], [1, 1]];
  for (const p of pts) {
    const fix = md(p[0], a) === 0 && md(p[1], b) === 0;   // exists i,j with 2ia-X=X, 2jb-Y=Y
    ok("B2 fixing_iff_corner_class", fix === C.some(c => rel(p, corner(c))), [a, b, p] + "");
  }
  for (const c of C) for (const d of C) ok("B2 four_corner_classes_distinct", rel(corner(c), corner(d)) === (c[0] === d[0] && c[1] === d[1]), [a, b, c, d] + "");
}
console.log(JSON.stringify({ checks, fails, failures: log }, null, 1));
process.exitCode = fails ? 1 : 0;
