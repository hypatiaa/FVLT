/* Contact sweep 0.1 exact core: canonical lower-tooth real-axis contacts.
 * Generation solves the native phase equation k*s/N = j for every shell
 * N=2..Q+1 and every half-turn j=0..N-1 before any address is reduced. No
 * Farey table, Stern-Brocot traversal, coprimality prefilter, sampled frame,
 * pixel test, M4 visit or Div(|t2*s|) row is consulted. All arithmetic is
 * BigInt; Numbers appear only for loop bounds already range-checked. */
(function (root, factory) {
  const api = factory();
  if (typeof module === 'object' && module.exports) module.exports = api;
  else root.McombContactSweepCoreV1 = api;
})(typeof globalThis !== 'undefined' ? globalThis : this, function () {
  'use strict';
  const VERSION = '0.1.1';
  const SCHEMA_VERSION = '0.2.0';          // sealed contract: binary comb m=2
  const SCHEMA_VERSION_ANY_M = '0.3.0';    // explicit widening: any host comb m=2..720
  const COMB_M_MIN = 2, COMB_M_MAX = 720;  // host comb range; every such comb contains tooth c=-1
  const MAX_Q = 256;
  const MAX_EVENTS = MAX_Q * (MAX_Q + 3) / 2;
  const MAX_IMPORT_BYTES = 32 * 1024 * 1024;
  const DIRECT_BASE_MIN = 2;
  const DIRECT_BASE_MAX = 1000000;
  const FACTORIAL_INDEX_MIN = 3;
  const FACTORIAL_INDEX_MAX = 8;
  const UINT = /^(?:0|[1-9][0-9]*)$/;

  class ContractError extends Error {
    constructor(message) { super(message); this.name = 'ContractError'; }
  }
  function need(condition, message) { if (!condition) throw new ContractError(message); }
  const isPlain = v => v !== null && typeof v === 'object' && !Array.isArray(v);
  const gcd = (a, b) => { a = a < 0n ? -a : a; b = b < 0n ? -b : b; while (b) [a, b] = [b, a % b]; return a; };

  function integer(value, positive = false) {
    need(typeof value === 'string' && value.length <= 128 && UINT.test(value), 'noncanonical integer string');
    const n = BigInt(value);
    need(!positive || n > 0n, 'positive integer required');
    return n;
  }
  function reduce(n, d) {
    need(typeof n === 'bigint' && typeof d === 'bigint' && d > 0n, 'rational denominator must be positive');
    const g = gcd(n, d);
    return { n: n / g, d: d / g };
  }
  function rational(value) {
    need(isPlain(value) && Object.keys(value).length === 2 && 'numerator' in value && 'denominator' in value,
      'rational fields must be numerator and denominator');
    const n = integer(value.numerator), d = integer(value.denominator, true);
    need(gcd(n, d) === 1n, 'rational must be reduced, including zero as 0/1');
    return { n, d };
  }
  function encode(r) {
    need(r.n >= 0n && r.d > 0n && gcd(r.n, r.d) === 1n, 'encoded rational must be reduced and nonnegative');
    return { numerator: String(r.n), denominator: String(r.d) };
  }
  const compare = (a, b) => { const l = a.n * b.d, r = b.n * a.d; return l < r ? -1 : l > r ? 1 : 0; };
  const fractionId = r => r.n + '/' + r.d;
  const text = r => r.d === 1n ? String(r.n) : r.n + '/' + r.d;
  function factorial(k) { let f = 1n; for (let i = 2n; i <= BigInt(k); i++) f *= i; return f; }

  /* Exact user cursor text: nonnegative integer, a/b, or a finite decimal. */
  function parseRationalText(raw) {
    need(typeof raw === 'string' && raw.length <= 256, 'cursor text is limited to 256 characters');
    const t = raw.trim();
    let m = /^(0|[1-9][0-9]*)\s*\/\s*([0-9]+)$/.exec(t);
    if (m) { const d = BigInt(m[2]); need(d > 0n, 'zero denominator'); return reduce(BigInt(m[1]), d); }
    m = /^([0-9]+)(?:\.([0-9]+))?$/.exec(t);
    need(m, 'enter a nonnegative integer, fraction a/b, or finite decimal');
    const frac = m[2] || '';
    return reduce(BigInt(m[1] + frac), 10n ** BigInt(frac.length));
  }

  /* The collected branch is the c=-1 tooth, k=(N*t1-t2)=N-1 at t1=t2=1. It is
   * present in every comb m>=2, and its contact set depends on N, t1, t2 only,
   * so comb_m is recorded provenance, not a generation input. */
  const schemaVersionFor = config => config.comb_m === '2' ? SCHEMA_VERSION : SCHEMA_VERSION_ANY_M;
  function configuration(Q, { B = null, factorialIndex = null, n6 = '1', alpha = '1', m = '2' } = {}) {
    return {
      Q: String(Q), base_B: String(B === null ? Math.max(DIRECT_BASE_MIN, Q) : B),
      base_mode: factorialIndex === null ? 'direct' : 'factorial',
      factorial_index: factorialIndex === null ? null : String(factorialIndex),
      comb_m: String(m), t1: '1', t2: '1', branch: '-1', n6: String(n6), alpha: String(alpha)
    };
  }

  /* Profile check shared by generation and semantic validation. Returns Q. */
  function checkConfig(config) {
    need(isPlain(config), 'configuration object required');
    const Q = integer(config.Q, true);
    need(Q <= BigInt(MAX_Q), 'Q exceeds declared resource cap');
    const B = integer(config.base_B, true);
    need(B >= Q, 'host base must cover Q');
    need(config.base_mode === 'direct' || config.base_mode === 'factorial', 'invalid base mode');
    if (config.base_mode === 'factorial') {
      const index = integer(config.factorial_index, true);
      need(index >= BigInt(FACTORIAL_INDEX_MIN) && index <= BigInt(FACTORIAL_INDEX_MAX),
        'factorial index is outside pinned host UI domain 3..8');
      need(B === factorial(index), 'base_B does not equal factorial(index)');
    } else {
      need(config.factorial_index === null, 'direct base cannot carry factorial index');
      need(B >= BigInt(DIRECT_BASE_MIN) && B <= BigInt(DIRECT_BASE_MAX),
        'direct base is outside pinned host domain 2..1000000');
    }
    const m = integer(config.comb_m, true);
    need(m >= BigInt(COMB_M_MIN) && m <= BigInt(COMB_M_MAX), 'comb order outside host range 2..720');
    for (const [name, expected] of [['t1', '1'], ['t2', '1'], ['branch', '-1']])
      need(config[name] === expected, 'incompatible canonical field: ' + name);
    need(config.n6 === '-1' || config.n6 === '1', 'zero or unsupported radius sign');
    need(config.alpha === '-1' || config.alpha === '0' || config.alpha === '1', 'unsupported radial exponent');
    return Number(Q);
  }

  /* Full scheduled inventory on [0, Q+1], canonical time order (s, N, j).
   * Each row keeps its unreduced witness (N, j) and exact reduced s and x. */
  function schedule(config) {
    const Q = checkConfig(config), sign = config.n6 === '1' ? 1 : -1, rows = [];
    for (let N = 2; N <= Q + 1; N++) {
      const k = N - 1, bN = BigInt(N), bk = BigInt(k);
      for (let j = 0; j <= k; j++) {
        const bj = BigInt(j), s = reduce(bN * bj, bk);     // k*s/N = j  <=>  s = N*j/k
        need(s.n * bk === bN * bj * s.d, 'phase identity failed');
        need(s.n <= bN * s.d, 'contact outside per-shell window');
        const x = reduce(s.n, s.d * bN);
        rows.push({ N, j, s, x, side: sign * (j % 2 ? -1 : 1) });
      }
    }
    rows.sort((a, b) => compare(a.s, b.s) || a.N - b.N || a.j - b.j);
    return rows;
  }

  /* Number of scheduled events with s <= cursor (schedule is time-sorted). */
  function prefixLength(rows, cursor) {
    let lo = 0, hi = rows.length;
    while (lo < hi) { const mid = (lo + hi) >> 1; if (compare(rows[mid].s, cursor) <= 0) lo = mid + 1; else hi = mid; }
    return lo;
  }
  /* Number of scheduled events with s < cursor. */
  function strictPrefixLength(rows, cursor) {
    let lo = 0, hi = rows.length;
    while (lo < hi) { const mid = (lo + hi) >> 1; if (compare(rows[mid].s, cursor) < 0) lo = mid + 1; else hi = mid; }
    return lo;
  }
  /* Next / previous distinct scheduled event time strictly after / before the cursor. */
  function nextTime(rows, cursor) { const i = prefixLength(rows, cursor); return i < rows.length ? rows[i].s : null; }
  function previousTime(rows, cursor) { const i = strictPrefixLength(rows, cursor); return i > 0 ? rows[i - 1].s : null; }

  function eventRecord(row) {
    return {
      event_id: row.N + ':' + row.j, shell_N: String(row.N), tooth_k: String(row.N - 1),
      half_turn_j: String(row.j), spin_s: encode(row.s), coordinate_x: encode(row.x),
      axis_side: row.side > 0 ? 'positive_real' : 'negative_real'
    };
  }

  /* Address groups for a time-ordered prefix; event ids stay in visit order. */
  function groups(prefixRows) {
    const byId = new Map();
    for (const row of prefixRows) {
      const id = fractionId(row.x);
      let g = byId.get(id);
      if (!g) { g = { x: row.x, rows: [] }; byId.set(id, g); }
      g.rows.push(row);
    }
    return [...byId.values()].sort((a, b) => compare(a.x, b.x));
  }

  function neighborRows(ordered, Q, complete) {
    const out = [];
    for (let i = 0; i + 1 < ordered.length; i++) {
      const l = ordered[i].x, r = ordered[i + 1].x, det = l.d * r.n - l.n * r.d, sum = l.d + r.d;
      if (complete) need(det === 1n && sum > BigInt(Q), 'complete adjacency failed');
      out.push({ left_id: fractionId(l), right_id: fractionId(r), determinant: String(det),
        denominator_sum: String(sum), status: complete ? 'FAREY_NEIGHBORS' : 'OBSERVED_ONLY' });
    }
    return out;
  }

  /* Portable v0.2 snapshot of the exact prefix at cursor. */
  function snapshot(config, cursor, source, { epoch = '0', selected = null, rows = null } = {}) {
    const Q = checkConfig(config);
    integer(epoch);
    need(cursor && typeof cursor.n === 'bigint' && typeof cursor.d === 'bigint', 'exact cursor required');
    const c = reduce(cursor.n, cursor.d);
    need(c.n >= 0n && compare(c, { n: BigInt(Q + 1), d: 1n }) <= 0, 'cursor is outside collection interval');
    const all = rows || schedule(config), prefix = all.slice(0, prefixLength(all, c));
    const complete = c.d === 1n && c.n === BigInt(Q + 1);
    const ordered = groups(prefix);
    need(selected === null || prefix.some(r => r.N + ':' + r.j === selected), 'selection must name a collected event');
    const fractions = ordered.map(g => ({ fraction_id: fractionId(g.x), coordinate_x: encode(g.x),
      event_ids: g.rows.map(r => r.N + ':' + r.j), multiplicity: String(g.rows.length) }));
    const neighbors = neighborRows(ordered, Q, complete);
    return {
      schema_version: schemaVersionFor(config), kind: 'fourier_contact_sweep_snapshot',
      convention: 'CANONICAL_LOWER_AXIS_HALF_TURNS_V1',
      source: { host_build: source.host_build, host_sha256: source.host_sha256 },
      config: { ...config },
      position: { cursor_s: encode(c), generation_epoch: epoch },
      coverage: complete ? 'COMPLETE' : 'PARTIAL',
      events: prefix.map(eventRecord), fractions, neighbors,
      counts: { events_seen: String(prefix.length), events_expected: String(Q * (Q + 3) / 2),
        addresses_seen: String(fractions.length), neighbor_pairs: String(neighbors.length) },
      selected_event_id: selected
    };
  }

  return Object.freeze({
    VERSION, SCHEMA_VERSION, SCHEMA_VERSION_ANY_M, COMB_M_MIN, COMB_M_MAX, schemaVersionFor, MAX_Q, MAX_EVENTS, MAX_IMPORT_BYTES, DIRECT_BASE_MIN, DIRECT_BASE_MAX,
    FACTORIAL_INDEX_MIN, FACTORIAL_INDEX_MAX, ContractError, need, gcd, integer, reduce, rational, encode,
    compare, fractionId, text, factorial, parseRationalText, configuration, checkConfig, schedule,
    prefixLength, strictPrefixLength, nextTime, previousTime, eventRecord, groups, neighborRows, snapshot
  });
});
