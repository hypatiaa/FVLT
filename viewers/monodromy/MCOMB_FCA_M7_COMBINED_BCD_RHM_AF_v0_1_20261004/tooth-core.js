/* Tooth contact 0.1 exact core (worker D): per-tooth comb contacts, snapshot schema 0.1.0.
 * JS mirror of the accepted reference TOOTH_CONTACT_SCHEMA_v0_1_1_20260926/tooth_contact_contract.py.
 * Tooth c of the centered comb (t1=t2=1) has signed frequency k=N+c; a contact solves k*s/N=j for every
 * selected tooth, every shell N=2..Q+1 with k!=0 and every signed half-turn j=0..k, before any reduction.
 * A shell with k=0 is STATIONARY_ON_AXIS: reported, never counted. Canonical time order (s, c, N, j).
 * All arithmetic that decides a claim is BigInt; Numbers are used only for loop bounds already
 * range-checked (Q<=256, |c|<=719) and for drawing. No Farey table, Stern-Brocot traversal, coprimality
 * prefilter, sampled frame, M4 visit or multiplicity formula is a generation input. */
(function (root, factory) {
  const api = factory();
  if (typeof module === 'object' && module.exports) module.exports = api;
  else root.McombToothContactCoreV1 = api;
})(typeof globalThis !== 'undefined' ? globalThis : this, function () {
  'use strict';
  const VERSION = '0.1.0';
  const SCHEMA_VERSION = '0.1.0', KIND = 'fourier_tooth_contact_snapshot', CONVENTION = 'SIGNED_TOOTH_AXIS_HALF_TURNS_V1';
  const MAX_Q = 256, MAX_EVENTS = 102400, MAX_IMPORT_BYTES = 64 * 1024 * 1024;
  const DIRECT_BASE_MIN = 2, DIRECT_BASE_MAX = 1000000, FACTORIAL_INDEX_MIN = 3, FACTORIAL_INDEX_MAX = 8;
  const COMB_M_MIN = 2, COMB_M_MAX = 720;
  const UINT = /^(?:0|[1-9][0-9]*)$/, SINT = /^(?:0|-?[1-9][0-9]*)$/;

  class ContractError extends Error {
    constructor(message) { super(message); this.name = 'ContractError'; }
  }
  function need(condition, message) { if (!condition) throw new ContractError(message); }
  const isPlain = v => v !== null && typeof v === 'object' && !Array.isArray(v);
  const abs = a => a < 0n ? -a : a;
  const gcd = (a, b) => { a = abs(a); b = abs(b); while (b) [a, b] = [b, a % b]; return a; };

  function integer(value, positive = false) {
    need(typeof value === 'string' && value.length <= 128 && UINT.test(value), 'noncanonical integer string');
    const n = BigInt(value);
    need(!positive || n > 0n, 'positive integer required');
    return n;
  }
  function signed(value) {
    need(typeof value === 'string' && value.length <= 129 && SINT.test(value), 'noncanonical signed integer string');
    return BigInt(value);
  }
  function reduce(n, d) {
    need(typeof n === 'bigint' && typeof d === 'bigint' && d > 0n, 'rational denominator must be positive');
    const g = gcd(n, d) || 1n;
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
    need(r.n >= 0n && r.d > 0n, 'negative spin or address is outside this convention');
    const q = reduce(r.n, r.d);
    return { numerator: String(q.n), denominator: String(q.d) };
  }
  const compare = (a, b) => { const l = a.n * b.d, r = b.n * a.d; return l < r ? -1 : l > r ? 1 : 0; };
  const fractionId = r => r.n + '/' + r.d;
  const text = r => r.d === 1n ? String(r.n) : r.n + '/' + r.d;
  function factorial(k) { let f = 1n; for (let i = 2n; i <= BigInt(k); i++) f *= i; return f; }

  /* The host's centered comb (combOffsets in the pinned viewer), ascending. */
  function combOffsets(m) {
    const M = Math.floor(m / 2), out = [];
    if (m % 2 === 1) { for (let c = -M; c <= M; c++) out.push(c); }
    else { for (let j = M; j >= 1; j--) out.push(-(2 * j - 1)); for (let j = 1; j <= M; j++) out.push(2 * j - 1); }
    return out;
  }

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
  /* Teeth text: comma or space separated canonical signed integers. Canonical order is the caller's job. */
  function parseTeethText(raw) {
    need(typeof raw === 'string' && raw.length <= 4096, 'teeth text is limited to 4096 characters');
    const parts = raw.split(/[\s,]+/).filter(Boolean);
    need(parts.length >= 1 && parts.length <= 720, 'enter 1..720 tooth offsets');
    for (const p of parts) need(SINT.test(p) && p.length <= 4, 'tooth offset must be a canonical signed integer: ' + p.slice(0, 20));
    const values = [...new Set(parts.map(Number))].sort((a, b) => a - b);
    return values;
  }

  /* Same field order as the reference configuration(); canonical_bytes preserves insertion order. */
  function configuration(Q, teeth, { m = 2, B = null, factorialIndex = null, n6 = '1', alpha = '1' } = {}) {
    return {
      Q: String(Q), base_B: String(B === null ? Math.max(DIRECT_BASE_MIN, Q) : B),
      base_mode: factorialIndex === null ? 'direct' : 'factorial',
      factorial_index: factorialIndex === null ? null : String(factorialIndex),
      comb_m: String(m), teeth: teeth.map(c => String(c)), t1: '1', t2: '1', n6: String(n6), alpha: String(alpha)
    };
  }

  function expectedEventCount(Q, teeth) {
    let total = 0;
    for (const c of teeth) for (let N = 2; N <= Q + 1; N++) if (N + c !== 0) total += Math.abs(N + c) + 1;
    return total;
  }

  /* Profile and resource check (reference check_config). Returns { Q, teeth (Numbers), sign }. */
  function checkConfig(config) {
    need(isPlain(config), 'configuration object required');
    const Qb = integer(config.Q, true);
    need(Qb <= BigInt(MAX_Q), 'Q exceeds declared resource cap');
    const B = integer(config.base_B, true);
    need(B >= Qb, 'host base must cover Q');
    need(config.base_mode === 'direct' || config.base_mode === 'factorial', 'invalid base mode');
    if (config.base_mode === 'factorial') {
      const index = integer(config.factorial_index, true);
      need(index >= BigInt(FACTORIAL_INDEX_MIN) && index <= BigInt(FACTORIAL_INDEX_MAX), 'factorial index is outside profile 3..8');
      need(B === factorial(index), 'base_B does not equal factorial(index)');
    } else {
      need(config.factorial_index === null, 'direct base cannot carry factorial index');
      need(B >= BigInt(DIRECT_BASE_MIN) && B <= BigInt(DIRECT_BASE_MAX), 'direct base is outside profile 2..1000000');
    }
    const mb = integer(config.comb_m, true);
    need(mb >= BigInt(COMB_M_MIN) && mb <= BigInt(COMB_M_MAX), 'comb order outside host range 2..720');
    need(Array.isArray(config.teeth) && config.teeth.length > 0, 'at least one tooth required');
    const big = config.teeth.map(signed);
    for (let i = 1; i < big.length; i++) need(big[i - 1] < big[i], 'teeth must be strictly ascending');
    const offsets = new Set(combOffsets(Number(mb)).map(BigInt));
    need(big.every(c => offsets.has(c)), 'tooth is not an offset of the declared comb');
    need(config.t1 === '1' && config.t2 === '1', 'canonical coefficients t1=t2=1 required');
    need(config.n6 === '-1' || config.n6 === '1', 'zero or unsupported radius sign');
    need(config.alpha === '-1' || config.alpha === '0' || config.alpha === '1', 'unsupported radial exponent');
    const Q = Number(Qb), teeth = big.map(Number);                    // bounded: Q<=256, |c|<=719
    need(expectedEventCount(Q, teeth) <= MAX_EVENTS, 'selection exceeds declared event cap 102400');
    return { Q, teeth, sign: config.n6 === '1' ? 1 : -1 };
  }

  const side = (sign, j) => (sign * (j % 2 !== 0 ? -1 : 1) > 0 ? 'positive_real' : 'negative_real');

  /* Full scheduled inventory on [0, Q+1]: unreduced witnesses (c, N, j), exact s and x, order (s, c, N, j). */
  function schedule(config) {
    const { Q, teeth, sign } = checkConfig(config), rows = [];
    for (const c of teeth) {
      for (let N = 2; N <= Q + 1; N++) {
        const k = N + c;
        if (k === 0) continue;
        const step = k > 0 ? 1 : -1, bN = BigInt(N), bk = BigInt(k);
        for (let j = 0; j !== k + step; j += step) {           // 0..k inclusive, signed with k
          const bj = BigInt(j), s = reduce(bN * abs(bj), abs(bk));   // k*s/N = j  <=>  s = N*j/k >= 0
          need(bk * s.n === bN * bj * s.d, 'phase identity failed');
          need(s.n <= bN * s.d, 'contact outside per-shell window');
          rows.push({ c, N, k, j, s, x: reduce(s.n, s.d * bN), side: side(sign, j) });
        }
      }
    }
    rows.sort((a, b) => compare(a.s, b.s) || a.c - b.c || a.N - b.N || a.j - b.j);
    return rows;
  }
  const eventId = r => r.c + ':' + r.N + ':' + r.j;
  function prefixLength(rows, cursor) {
    let lo = 0, hi = rows.length;
    while (lo < hi) { const mid = (lo + hi) >> 1; if (compare(rows[mid].s, cursor) <= 0) lo = mid + 1; else hi = mid; }
    return lo;
  }
  function strictPrefixLength(rows, cursor) {
    let lo = 0, hi = rows.length;
    while (lo < hi) { const mid = (lo + hi) >> 1; if (compare(rows[mid].s, cursor) < 0) lo = mid + 1; else hi = mid; }
    return lo;
  }
  function nextTime(rows, cursor) { const i = prefixLength(rows, cursor); return i < rows.length ? rows[i].s : null; }
  function previousTime(rows, cursor) { const i = strictPrefixLength(rows, cursor); return i > 0 ? rows[i - 1].s : null; }

  function eventRecord(r) {
    return { event_id: eventId(r), tooth_c: String(r.c), shell_N: String(r.N), frequency_k: String(r.k), half_turn_j: String(r.j),
      spin_s: encode(r.s), coordinate_x: encode(r.x), axis_side: r.side };
  }

  function stationaryShells(config) {
    const { Q, teeth, sign } = checkConfig(config);
    return teeth.filter(c => 2 <= -c && -c <= Q + 1).map(c => ({ tooth_c: String(c), shell_N: String(-c), frequency_k: '0',
      status: 'STATIONARY_ON_AXIS', axis_side: side(sign, 0) }));
  }

  /* Absolute nonzero frequencies |N+c| over the shell window. */
  function windowFreqs(Q, c) { const out = []; for (let N = 2; N <= Q + 1; N++) if (N + c !== 0) out.push(Math.abs(N + c)); return out; }
  /* Denominators b<=order dividing no window frequency. (Same set as the reference's direct search.) */
  function missing(order, freqs) {
    const present = new Uint8Array(order + 1); for (const q of freqs) present[q] = 1;
    const out = [];
    for (let b = 1; b <= order; b++) { let hit = false; for (let q = b; q <= order; q += b) if (present[q]) { hit = true; break; } if (!hit) out.push(b); }
    return out;
  }
  function windowSummaries(config) {
    const { Q, teeth } = checkConfig(config), per = [], union = [];
    for (const c of teeth) {
      const freqs = windowFreqs(Q, c); union.push(...freqs);
      const order = freqs.length ? Math.max(...freqs) : 0, miss = missing(order, freqs), st = 2 <= -c && -c <= Q + 1 ? -c : null;
      per.push({ tooth_c: String(c), frequency_min: String(2 + c), frequency_max: String(Q + 1 + c), address_order: String(order),
        missing_denominators: miss.map(String), farey_status: order && !miss.length ? 'FULL_FAREY' : 'GAPPED',
        stationary_shell: st === null ? null : String(st), events_expected: String(expectedEventCount(Q, [c])) });
    }
    let order = 0; for (const q of union) if (q > order) order = q;
    const miss = missing(order, union);
    return { teeth: per, union: { address_order: String(order), missing_denominators: miss.map(String), farey_status: order && !miss.length ? 'FULL_FAREY' : 'GAPPED' } };
  }

  /* Address groups of a time-ordered prefix; event ids stay in visit order. */
  function groups(prefixRows) {
    const byId = new Map();
    for (const r of prefixRows) {
      const id = fractionId(r.x); let g = byId.get(id);
      if (!g) { g = { x: r.x, rows: [] }; byId.set(id, g); }
      g.rows.push(r);
    }
    return [...byId.values()].sort((a, b) => compare(a.x, b.x));
  }

  /* Portable 0.1.0 snapshot of the exact prefix at cursor (reference snapshot()). */
  function snapshot(config, cursor, source, { epoch = '0', selected = null, rows = null } = {}) {
    const { Q, teeth } = checkConfig(config);
    integer(epoch);
    need(cursor && typeof cursor.n === 'bigint' && typeof cursor.d === 'bigint' && cursor.d > 0n, 'exact cursor required');
    const cur = reduce(cursor.n, cursor.d);
    need(cur.n >= 0n && compare(cur, { n: BigInt(Q + 1), d: 1n }) <= 0, 'cursor is outside collection interval');
    const all = rows || schedule(config), prefix = all.slice(0, prefixLength(all, cur));
    const coverage = cur.d === 1n && cur.n === BigInt(Q + 1) ? 'COMPLETE' : 'PARTIAL';
    const windows = windowSummaries(config), ordered = groups(prefix);
    const fractions = ordered.map(g => {
      const counts = new Map(); for (const r of g.rows) counts.set(r.c, (counts.get(r.c) || 0) + 1);
      return { fraction_id: fractionId(g.x), coordinate_x: encode(g.x), event_ids: g.rows.map(eventId), multiplicity: String(g.rows.length),
        tooth_multiplicities: [...counts.entries()].sort((a, b) => a[0] - b[0]).map(([c, n]) => ({ tooth_c: String(c), multiplicity: String(n) })) };
    });
    const full = coverage === 'COMPLETE' && windows.union.farey_status === 'FULL_FAREY', order = BigInt(windows.union.address_order);
    const neighbors = [];
    for (let i = 0; i + 1 < ordered.length; i++) {
      const l = ordered[i].x, r = ordered[i + 1].x, det = l.d * r.n - l.n * r.d, total = l.d + r.d;
      if (full) need(det === 1n && total > order, 'complete Farey adjacency failed');
      neighbors.push({ left_id: fractionId(l), right_id: fractionId(r), determinant: String(det), denominator_sum: String(total),
        status: full ? 'FAREY_NEIGHBORS' : coverage === 'COMPLETE' ? 'CONSECUTIVE_ONLY' : 'OBSERVED_ONLY' });
    }
    need(selected === null || prefix.some(r => eventId(r) === selected), 'selection must name a collected event');
    const stationary = stationaryShells(config);
    return {
      schema_version: SCHEMA_VERSION, kind: KIND, convention: CONVENTION,
      source: { ...source }, config: { ...config, teeth: [...config.teeth] },
      position: { cursor_s: encode(cur), generation_epoch: epoch },
      coverage, events: prefix.map(eventRecord), stationary, fractions, neighbors, windows,
      counts: { events_seen: String(prefix.length), events_expected: String(expectedEventCount(Q, teeth)), addresses_seen: String(fractions.length),
        neighbor_pairs: String(neighbors.length), stationary_shells: String(stationary.length) },
      selected_event_id: selected
    };
  }

  /* The one export serializer (reference canonical_bytes): Python json.dumps(data, separators=(",", ":"),
   * ensure_ascii=True) + LF. Keys in insertion order; printable ASCII literal except '"' and '\\'; the short
   * escapes \" \\ \n \r \t \b \f; every other code unit (controls, DEL, non-ASCII, surrogates) as lowercase
   * \uXXXX. Only null, strings, arrays and plain objects occur in a snapshot; anything else is refused.
   * Refuses to emit more than the 64 MiB cap. */
  const SHORT = { 0x22: '\\"', 0x5c: '\\\\', 0x0a: '\\n', 0x0d: '\\r', 0x09: '\\t', 0x08: '\\b', 0x0c: '\\f' };
  function quote(s) {
    let out = '"', start = 0;
    for (let i = 0; i < s.length; i++) {
      const u = s.charCodeAt(i);
      if (u >= 0x20 && u <= 0x7e && u !== 0x22 && u !== 0x5c) continue;
      out += s.slice(start, i) + (SHORT[u] || '\\u' + u.toString(16).padStart(4, '0')); start = i + 1;
    }
    return out + s.slice(start) + '"';
  }
  function serialize(v, parts) {
    if (v === null) parts.push('null');
    else if (typeof v === 'string') parts.push(quote(v));
    else if (Array.isArray(v)) { parts.push('['); v.forEach((x, i) => { if (i) parts.push(','); serialize(x, parts); }); parts.push(']'); }
    else if (isPlain(v)) { parts.push('{'); let first = true; for (const k of Object.keys(v)) { if (!first) parts.push(','); first = false; parts.push(quote(k), ':'); serialize(v[k], parts); } parts.push('}'); }
    else throw new ContractError('EXPORT: only null, strings, arrays and objects occur in this format');
  }
  function canonicalBytes(data) {
    const parts = []; serialize(data, parts); parts.push('\n');
    const s = parts.join('');
    need(s.length <= MAX_IMPORT_BYTES, 'EXPORT: canonical serialization exceeds the 64 MiB cap');   // ASCII: 1 byte per unit
    const bytes = new Uint8Array(s.length);
    for (let i = 0; i < s.length; i++) bytes[i] = s.charCodeAt(i);
    return bytes;
  }

  return Object.freeze({
    VERSION, SCHEMA_VERSION, KIND, CONVENTION, MAX_Q, MAX_EVENTS, MAX_IMPORT_BYTES, DIRECT_BASE_MIN, DIRECT_BASE_MAX,
    FACTORIAL_INDEX_MIN, FACTORIAL_INDEX_MAX, COMB_M_MIN, COMB_M_MAX, ContractError, need, isPlain, gcd, integer, signed, reduce,
    rational, encode, compare, fractionId, text, factorial, combOffsets, parseRationalText, parseTeethText, configuration,
    expectedEventCount, checkConfig, schedule, eventId, prefixLength, strictPrefixLength, nextTime, previousTime, eventRecord,
    stationaryShells, windowSummaries, groups, snapshot, canonicalBytes
  });
});
