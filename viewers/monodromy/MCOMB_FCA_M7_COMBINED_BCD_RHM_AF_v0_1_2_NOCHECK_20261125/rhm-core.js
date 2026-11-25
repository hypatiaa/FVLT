/* RH margin panel v0.1 core: a statement-for-statement BigInt port of the accepted reference
 * RH_CRITERIA_READOUT_SPEC_v0_1_20260929 (rh_enclosures.py and the build_atom path of rh_criteria_readout.py,
 * schema rh-criteria-readout 0.1.0). Accepted specification and audit: Astra. Idea: saphir. Criteria mapping: Opus.
 * Port: RH margin builder (Claude).
 *
 * Every value is a BigInt or an exact rational {n, d} (d > 0, gcd(n, d) = 1, as Python's Fraction). No floating
 * point is used anywhere in this file. The reference's sieve loop bound int(limit ** 0.5) is replaced by the
 * integer bound i * i <= limit (corrigendum C1); the prime list is identical. Python floor division (//) is
 * fdiv, ceiling division is cdiv. The one export serializer reproduces json.dumps(record, separators=(",", ":"),
 * ensure_ascii=True) + LF for the record shapes built here (insertion-ordered keys, strings and null only).
 */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) module.exports = factory();
  else root.McombRhMarginCoreV1 = factory();
})(typeof self !== 'undefined' ? self : this, function () {
  'use strict';
  /* ---------------- rational arithmetic (Python Fraction semantics) ---------------- */
  const abs = a => (a < 0n ? -a : a);
  const gcd = (a, b) => { a = abs(a); b = abs(b); while (b) { [a, b] = [b, a % b]; } return a; };
  function F(n, d = 1n) {
    n = BigInt(n); d = BigInt(d);
    if (d === 0n) throw new RangeError('zero denominator');
    if (d < 0n) { n = -n; d = -d; }
    const g = gcd(n, d) || 1n;
    return Object.freeze({ n: n / g, d: d / g });
  }
  const fr = x => (typeof x === 'object' && x !== null && 'n' in x ? x : F(x));
  const add = (a, b) => { a = fr(a); b = fr(b); return F(a.n * b.d + b.n * a.d, a.d * b.d); };
  const sub = (a, b) => { a = fr(a); b = fr(b); return F(a.n * b.d - b.n * a.d, a.d * b.d); };
  const mul = (a, b) => { a = fr(a); b = fr(b); return F(a.n * b.n, a.d * b.d); };
  const div = (a, b) => { a = fr(a); b = fr(b); return F(a.n * b.d, a.d * b.n); };
  const cmp = (a, b) => { a = fr(a); b = fr(b); const x = a.n * b.d - b.n * a.d; return x < 0n ? -1 : x > 0n ? 1 : 0; };
  const fdiv = (a, b) => { const q = a / b; return (a % b !== 0n && ((a < 0n) !== (b < 0n))) ? q - 1n : q; };   // Python a // b
  const cdiv = (a, b) => -fdiv(-a, b);
  const bitLength = n => { n = abs(n); return n === 0n ? 0 : n.toString(2).length; };   // Python int.bit_length
  const minB = xs => xs.reduce((m, x) => (x < m ? x : m)), maxB = xs => xs.reduce((m, x) => (x > m ? x : m));

  /* ================================================================ rh_enclosures.py ================ */
  const METHOD_ID = 'RH_ENCLOSURE_V1_EM_GAMMA_ATANH_LN_TAYLOR_EXP_FIXED_POINT_OUTWARD';
  const GAMMA_EM_N = 128, GUARD_BITS = 64;
  class EnclosureError extends Error { constructor(m) { super(m); this.name = 'EnclosureError'; } }
  const needE = (cond, msg) => { if (!cond) throw new EnclosureError(msg); };
  const frac_floor = (x, G) => { x = fr(x); return fdiv(x.n << BigInt(G), x.d); };
  const frac_ceil = (x, G) => { x = fr(x); return cdiv(x.n << BigInt(G), x.d); };

  const _atanh_terms = G => Math.floor(G / 3) + 4;
  function atanh_interval(t_lo, t_hi, G) {
    const S = 1n << BigInt(G), S2 = S * S;
    needE(0n <= t_lo && t_lo <= t_hi && 100n * t_hi <= 34n * S, 'atanh argument outside [0, 0.34]');
    const K = _atanh_terms(G);
    let lo = 0n, p = t_lo;
    for (let j = 0; j < K; j++) { lo += fdiv(p, BigInt(2 * j + 1)); p = fdiv(p * t_lo * t_lo, S2); }
    let hi = 0n; p = t_hi;
    for (let j = 0; j < K; j++) { hi += cdiv(p, BigInt(2 * j + 1)); p = cdiv(p * t_hi * t_hi, S2); }
    hi += cdiv(p * S2, BigInt(2 * K + 1) * (S2 - t_hi * t_hi));
    return [lo, hi];
  }
  const _LN2 = new Map();
  function ln2_interval(G) {
    if (!_LN2.has(G)) {
      const S = 1n << BigInt(G);
      const [a_lo, a_hi] = atanh_interval(fdiv(S, 3n), cdiv(S, 3n), G);
      _LN2.set(G, [2n * a_lo, 2n * a_hi]);
    }
    return _LN2.get(G);
  }
  function _floor_log2(x) {
    const n = x.n, d = x.d;
    let k = bitLength(n) - bitLength(d);
    const ge = kk => (kk >= 0 ? n >= (d << BigInt(kk)) : (n << BigInt(-kk)) >= d);
    while (!ge(k)) k -= 1;
    while (ge(k + 1)) k += 1;
    return k;
  }
  function _ln_point(x, G, upper) {
    x = fr(x);
    needE(x.n > 0n, 'ln of a nonpositive number');
    const k = _floor_log2(x);
    const y = k >= 0 ? div(x, F(1n << BigInt(k))) : mul(x, F(1n << BigInt(-k)));   // x / 2^k
    const t = div(sub(y, 1n), add(y, 1n));
    const tt = upper ? frac_ceil(t, G) : frac_floor(t, G);
    const [a_lo, a_hi] = atanh_interval(tt, tt, G);
    const [l2_lo, l2_hi] = ln2_interval(G);
    const K = BigInt(k);
    if (upper) return 2n * a_hi + K * (k >= 0 ? l2_hi : l2_lo);
    return 2n * a_lo + K * (k >= 0 ? l2_lo : l2_hi);
  }
  function ln_interval(x_lo, x_hi, G) {
    needE(cmp(x_lo, x_hi) <= 0, 'empty interval');
    return [_ln_point(x_lo, G, false), _ln_point(x_hi, G, true)];
  }
  function exp_interval(X_lo, X_hi, G) {
    const S = 1n << BigInt(G);
    needE(0n <= X_lo && X_lo <= X_hi && X_hi < S, 'exp argument outside [0, 1)');
    let K = 1, f = 2n;
    const lim = 1n << BigInt(G + 2);
    while (f <= lim) { K += 1; f *= BigInt(K + 1); }
    let lo = S, term = S;
    for (let j = 1; j <= K; j++) { term = fdiv(term * X_lo, S * BigInt(j)); lo += term; }
    let hi = S; term = S;
    for (let j = 1; j <= K + 1; j++) { term = cdiv(term * X_hi, S * BigInt(j)); if (j <= K) hi += term; }
    hi += cdiv(term * S * BigInt(K + 2), S * BigInt(K + 2) - X_hi);
    return [lo, hi];
  }
  const _BERN = [F(1n)];
  function comb(n, k) { n = BigInt(n); k = BigInt(k); if (k < 0n || k > n) return 0n; let r = 1n; for (let i = 1n; i <= k; i++) r = r * (n - k + i) / i; return r; }
  function bernoulli(n) {
    while (_BERN.length <= n) {
      const m = _BERN.length;
      let s = F(0n);
      for (let j = 0; j < m; j++) s = add(s, mul(comb(m + 1, j), _BERN[j]));
      _BERN.push(div(F(-s.n, s.d), BigInt(m + 1)));
    }
    return _BERN[n];
  }
  function em_remainder_bound(m, n) {
    let f = 1n;
    for (let i = 2; i < 2 * m; i++) f *= BigInt(i);
    return F(4n * f, 36n ** BigInt(m) * BigInt(n) ** BigInt(2 * m));
  }
  const _GAMMA = new Map();
  function gamma_interval(G) {
    if (_GAMMA.has(G)) return _GAMMA.get(G);
    const n = GAMMA_EM_N;
    const target = F(1n, 1n << BigInt(G + 2));
    let m = 1;
    while (cmp(em_remainder_bound(m, n), target) > 0) { m += 1; needE(m <= 400, 'Euler-Maclaurin order cap exceeded'); }
    const R = em_remainder_bound(m, n);
    let core = F(0n);
    for (let j = 1; j <= n; j++) core = add(core, F(1n, BigInt(j)));
    core = sub(core, F(1n, BigInt(2 * n)));
    let bs = F(0n);
    for (let k = 1; k <= m; k++) bs = add(bs, div(bernoulli(2 * k), BigInt(2 * k) * BigInt(n) ** BigInt(2 * k)));
    core = add(core, bs);
    const [ln_lo, ln_hi] = ln_interval(F(BigInt(n)), F(BigInt(n)), G);
    const lo = frac_floor(core, G) - ln_hi - frac_ceil(R, G);
    const hi = frac_ceil(core, G) - ln_lo + frac_ceil(R, G);
    const out = [lo, hi, { n, m, remainder_bound: R }];
    _GAMMA.set(G, out);
    return out;
  }
  function mul_interval(a, b, G) {
    const S = 1n << BigInt(G);
    const ps = [];
    for (const x of a) for (const y of b) ps.push(x * y);
    return [fdiv(minB(ps), S), cdiv(maxB(ps), S)];
  }
  function to_grid(iv, G, bits) {
    needE(G >= bits, 'output grid finer than working scale');
    const sh = 1n << BigInt(G - bits);
    return [F(fdiv(iv[0], sh), 1n << BigInt(bits)), F(cdiv(iv[1], sh), 1n << BigInt(bits))];
  }
  const working_bits = bits => bits + GUARD_BITS;
  function threshold_components(B, bits) {
    needE(typeof B === 'bigint' && B >= 2n, 'threshold needs an integer B >= 2');
    const G = working_bits(bits), S = 1n << BigInt(G);
    const [g_lo, g_hi, info] = gamma_interval(G);
    needE(0n <= g_lo && g_lo <= g_hi && g_hi < S, 'gamma enclosure outside [0, 1)');
    const eg = exp_interval(g_lo, g_hi, G);
    const lnB = ln_interval(F(B), F(B), G);
    needE(lnB[0] > 0n, 'ln B lower bound not positive');
    const lnlnB = ln_interval(F(lnB[0], S), F(lnB[1], S), G);
    const thr = mul_interval(eg, lnlnB, G);
    const out = {
      gamma: to_grid([g_lo, g_hi], G, bits), exp_gamma: to_grid(eg, G, bits), ln_B: to_grid(lnB, G, bits),
      ln_ln_B: to_grid(lnlnB, G, bits), threshold: to_grid(thr, G, bits),
      em_n: info.n, em_m: info.m, em_remainder_bound: info.remainder_bound, working_bits: G,
    };
    const w = sub(out.threshold[1], out.threshold[0]);
    needE(cmp(w, F(3n, 1n << BigInt(bits))) <= 0, 'threshold enclosure wider than 3 * 2^-bits');
    return out;
  }

  /* ================================================================ rh_criteria_readout.py (build_atom) */
  const SCHEMA_NAME = 'rh-criteria-readout', SCHEMA_VERSION = '0.1.0', MAX_RECORD_BYTES = 1024 * 1024;
  const MAX_B_BITS = 256, MAX_PRIME = 1000000, MAX_EXPONENT = 64, MAX_FACTORS = 16, FACTORIAL_INDEX_MAX = 57;
  const BITS_MIN = 2, BITS_MAX = 256, C1_RANGE_START = 5041n, C1_BOUNDARY = 5040n;
  const PLACEHOLDER_SOURCE = { host_build: 'SPEC_EXAMPLE_NO_HOST', host_sha256: '0'.repeat(64) };
  const RH_STATUS = 'NOT_EVIDENCE';
  const SCOPE = 'Finite value of an RH-equivalent quantity. Finitely many satisfied cases do not '
    + "establish RH; a certified violation inside a criterion's quantified range would "
    + 'refute RH. No counterexample search is performed.';
  const SOURCES_DIR = 'RH_CRITERIA_SOURCES_20260929';
  const SRC_LAGARIAS = {
    reference: 'J. C. Lagarias, An Elementary Problem Equivalent to the Riemann Hypothesis, arXiv math/0008177v2',
    locus: 'eq. (1.2), printed p. 2 (PDF p. 2)',
    file: SOURCES_DIR + '/lagarias_math0008177v2.pdf',
    sha256: '49cd7ad205f153197c327fa2035dce5bd676738e06fa696ac5e15cca1e49e43c',
    original: 'G. Robin, J. Math. Pures Appl. 63 (1984) 187-213 (Lagarias ref. [18]); original not byte-pinned',
  };
  const SRC_NICOLAS = {
    reference: 'J.-L. Nicolas, Small values of the Euler function and the Riemann hypothesis, arXiv 1202.0729v2',
    locus: 'introduction, printed p. 2 (PDF p. 2); eq. (1.10), printed p. 3 (PDF p. 3)',
    file: SOURCES_DIR + '/nicolas_1202.0729.pdf',
    sha256: 'd5ff55f73a832714ef9f9aa176ca5f69f4813de33d9949158f1f452183d49fc1',
    original: 'J.-L. Nicolas, J. Number Theory 17 (1983) 375-388 (Nicolas ref. [6]); original not byte-pinned',
  };
  const C1_FIXED = {
    criterion_id: 'C1_G_ROBIN_1984',
    criterion_name: 'G. Robin (1984) criterion',
    criterion_statement: 'RH holds iff sigma(N)/N < exp(gamma) * ln ln N for every integer N > 5040 '
      + '(strict), where gamma is the Euler-Mascheroni constant.',
    criterion_source: SRC_LAGARIAS,
    quantity: 'SIGMA_B_OVER_B',
    criterion_direction: 'CRITERION_ASKS_VALUE_BELOW_THRESHOLD',
  };
  const C2_FIXED = {
    criterion_id: 'C2_NICOLAS_1983',
    criterion_name: 'Nicolas (1983) criterion',
    criterion_statement: 'RH holds iff N_k/phi(N_k) > exp(gamma) * ln ln N_k for every k >= 1, where N_k '
      + 'is the product of the first k primes; gamma is the Euler-Mascheroni constant.',
    criterion_source: SRC_NICOLAS,
    quantity: 'B_OVER_PHI_B',
    criterion_direction: 'CRITERION_ASKS_VALUE_ABOVE_THRESHOLD',
  };
  const NOTE_C1 = {
    IN_RANGE: 'B > 5040: inside the criterion\'s quantified range; finite value only.',
    OUT_OF_RANGE: 'Outside the criterion\'s range (B <= 5040); numerical value only.',
    DOMAIN_UNAVAILABLE: 'ln ln B is undefined at B = 1; threshold and side are absent.',
  };
  const NOTE_C2 = {
    IN_RANGE: 'B is the primorial N_k (product of the first k primes); finite value only.',
    NOT_IN_FAMILY: 'B is not a primorial N_k; numerical value only, not an instance of the criterion.',
    DOMAIN_UNAVAILABLE: 'ln ln B is undefined at B = 1; threshold and side are absent.',
  };
  const BOUNDARY_NOTE_5040 = 'Boundary fixture: the largest known violator, outside the criterion\'s range.';
  const K1_NOTE = 'k = 1 (N = 2): ln ln 2 < 0, so the inequality is immediate.';
  const ENCLOSURE_METHOD = {
    method_id: METHOD_ID,
    gamma_name: 'Euler-Mascheroni constant gamma',
    gamma_method: 'Euler-Maclaurin summation of 1/x from n = 128 with m Bernoulli terms; remainder '
      + '<= 4 (2m-1)! / (36^m n^(2m)); no decimal table',
    ln_method: 'binary range reduction and 2 atanh((y-1)/(y+1)) with geometric tail bound',
    exp_method: 'Taylor series with tail x^(K+1)/(K+1)! / (1 - x/(K+2))',
    rounding: 'fixed point at 2^-(precision_bits + 64), outward; outputs outward on the 2^-precision_bits grid',
  };

  class ContractError extends Error { constructor(m) { super(m); this.name = 'ContractError'; } }
  const require_ = (cond, code, msg) => { if (!cond) throw new ContractError(code + ': ' + msg); };
  const UINT = /^(?:0|[1-9][0-9]*)$/;

  const enc_rat = x => { x = fr(x); return x.d === 1n ? x.n.toString() : `${x.n}/${x.d}`; };
  const enc_iv = pair => ({ lo: enc_rat(pair[0]), hi: enc_rat(pair[1]) });
  function side_of(m_lo, m_hi) {
    if (cmp(m_lo, 0n) > 0) return 'ABOVE';
    if (cmp(m_hi, 0n) < 0) return 'BELOW';
    return 'UNDECIDED_AT_PRECISION';
  }
  // json.dumps(data, separators=(",", ":"), ensure_ascii=True): compact; every char outside 0x20..0x7e escaped as \uXXXX.
  const canonicalText = data => JSON.stringify(data).replace(/[^\x20-\x7e]/g, c => '\\u' + c.charCodeAt(0).toString(16).padStart(4, '0')) + '\n';
  function canonicalBytes(data, cap = MAX_RECORD_BYTES) {
    const text = canonicalText(data);
    const raw = new TextEncoder().encode(text);
    require_(raw.length <= cap, 'EXPORT', 'canonical serialization exceeds the record cap');
    return raw;
  }

  /* number theory (builder side) */
  let _PRIMES = null;
  function _small_primes(limit) {
    const sieve = new Uint8Array(limit + 1).fill(1);
    sieve[0] = 0; sieve[1] = 0;
    for (let i = 2; i * i <= limit; i++) if (sieve[i]) for (let j = i * i; j <= limit; j += i) sieve[j] = 0;   // integer bound (corrigendum C1)
    const out = [];
    for (let i = 0; i <= limit; i++) if (sieve[i]) out.push(i);
    return out;
  }
  const _primes_to_cap = () => (_PRIMES || (_PRIMES = _small_primes(MAX_PRIME)));
  function factor_in_domain(B) {
    require_(1n <= B && bitLength(B) <= MAX_B_BITS, 'V0', 'B outside 1 .. 2^256 - 1');
    const out = []; let n = B;
    for (const pn of _primes_to_cap()) {
      const p = BigInt(pn);
      if (n === 1n || p * p > n) break;
      if (n % p === 0n) { let e = 0; while (n % p === 0n) { n /= p; e += 1; } out.push([p, e]); }
    }
    if (n > 1n) { require_(n <= BigInt(MAX_PRIME), 'V0', 'B has a prime factor above 10^6'); out.push([n, 1]); }
    require_(out.length <= MAX_FACTORS, 'V0', 'more than 16 distinct primes');
    require_(out.every(([, e]) => e <= MAX_EXPONENT), 'V0', 'exponent above 64');
    return out;
  }
  function sigma_over(fac) {
    let v = F(1n);
    for (const [p, a] of fac) v = mul(v, F(p ** BigInt(a + 1) - 1n, p ** BigInt(a) * (p - 1n)));
    return v;
  }
  function n_over_phi(fac) {
    let v = F(1n);
    for (const [p] of fac) v = mul(v, F(p, p - 1n));
    return v;
  }
  function primorial_k(fac) {
    if (!fac.length) return null;
    const first = _primes_to_cap().slice(0, fac.length);
    if (fac.every(([p, a], i) => p === BigInt(first[i]) && a === 1)) return fac.length;
    return null;
  }
  function _uint_in(value, name, lo, hi) {
    require_(typeof value === 'string' && value.length <= 80 && UINT.test(value), 'V0', `${name}: noncanonical nonnegative integer string`);
    const n = BigInt(value);
    require_(BigInt(lo) <= n && n <= BigInt(hi), 'V0', `${name} outside ${lo}..${hi}`);
    return n;
  }
  function _criterion_block(fixed, notes, applicability, value, comps, extra) {
    const block = JSON.parse(JSON.stringify(fixed));        // dict(fixed): same keys, same order (strings and objects only)
    block.value = enc_rat(value);
    block.applicability = applicability;
    block.applicability_note = notes[applicability];
    Object.assign(block, extra);
    if (applicability !== 'DOMAIN_UNAVAILABLE') {
      const [t_lo, t_hi] = comps.threshold;
      const m_lo = sub(value, t_hi), m_hi = sub(value, t_lo);
      block.threshold = enc_iv([t_lo, t_hi]);
      block.margin = enc_iv([m_lo, m_hi]);
      block.side = side_of(m_lo, m_hi);
    }
    return block;
  }
  const MAX_B = (1n << BigInt(MAX_B_BITS)) - 1n;
  function factorialBig(n) { let f = 1n; for (let i = 2n; i <= n; i++) f *= i; return f; }
  function buildAtom(inputs) {
    require_(inputs !== null && typeof inputs === 'object' && !Array.isArray(inputs)
      && Object.keys(inputs).length === 4 && ['B', 'mode', 'factorial_index', 'precision_bits'].every(k => Object.prototype.hasOwnProperty.call(inputs, k)),
      'V0', 'atom inputs: B, mode, factorial_index, precision_bits');
    const bits = Number(_uint_in(inputs.precision_bits, 'precision_bits', BITS_MIN, BITS_MAX));
    const B = _uint_in(inputs.B, 'B', 1, MAX_B);
    const mode = inputs.mode;
    require_(mode === 'direct' || mode === 'factorial', 'V0', 'mode is direct or factorial');
    if (mode === 'factorial') {
      const idx = _uint_in(inputs.factorial_index, 'factorial_index', 1, FACTORIAL_INDEX_MAX);
      require_(B === factorialBig(idx), 'V0', 'B does not equal factorial(index)');
    } else require_(inputs.factorial_index === null, 'V0', 'direct mode carries no factorial index');
    const fac = factor_in_domain(B);
    const comps = B >= 2n ? threshold_components(B, bits) : null;
    let a1, a2;
    if (B === 1n) a1 = a2 = 'DOMAIN_UNAVAILABLE';
    else { a1 = B >= C1_RANGE_START ? 'IN_RANGE' : 'OUT_OF_RANGE'; a2 = primorial_k(fac) !== null ? 'IN_RANGE' : 'NOT_IN_FAMILY'; }
    const k = B > 1n ? primorial_k(fac) : null;
    const c1 = _criterion_block(C1_FIXED, NOTE_C1, a1, sigma_over(fac), comps, { boundary_note: B === C1_BOUNDARY ? BOUNDARY_NOTE_5040 : null });
    const c2 = _criterion_block(C2_FIXED, NOTE_C2, a2, n_over_phi(fac), comps,
      { primorial_k: k === null ? null : String(k), convention_note: k === 1 ? K1_NOTE : null });
    let constants;
    if (comps === null) constants = { availability: 'UNAVAILABLE_AT_B_EQUALS_1' };
    else constants = { availability: 'AVAILABLE', gamma: enc_iv(comps.gamma), exp_gamma: enc_iv(comps.exp_gamma),
      ln_B: enc_iv(comps.ln_B), ln_ln_B: enc_iv(comps.ln_ln_B), em_n: String(comps.em_n), em_m: String(comps.em_m),
      em_remainder_bound: enc_rat(comps.em_remainder_bound), working_bits: String(comps.working_bits) };
    return {
      schema: SCHEMA_NAME, schema_version: SCHEMA_VERSION, kind: 'rh_atom_margins',
      rh_status: RH_STATUS, scope: SCOPE, source: { ...PLACEHOLDER_SOURCE },
      atom: { B: B.toString(), mode, factorial_index: inputs.factorial_index, factors: fac.map(([p, a]) => ({ prime: p.toString(), exponent: String(a) })) },
      precision_bits: String(bits), enclosure_method: { ...ENCLOSURE_METHOD },
      constants, c1, c2,
    };
  }
  // Live export: the reference record with source replaced by the declared host identity (the validator's
  // expected_source binding), serialized by the one serializer.
  function withSource(record, source) { const r = JSON.parse(JSON.stringify(record)); r.source = { host_build: source.host_build, host_sha256: source.host_sha256 }; return r; }

  /* display helpers (exact; used by the panel, never by the builder) */
  const RAT = /^(?:0|-?[1-9][0-9]*(?:\/(?:[2-9]|[1-9][0-9]+))?)$/;
  function parseRat(s) { if (typeof s !== 'string' || !RAT.test(s)) throw new ContractError('display: noncanonical rational ' + String(s).slice(0, 40)); const [a, b] = s.split('/'); return F(BigInt(a), b ? BigInt(b) : 1n); }
  // Directed decimal text of a rational with `digits` fractional digits: 'floor' or 'ceil'. Exact BigInt arithmetic.
  function decimal(x, digits, dir) {
    x = fr(x); const s = 10n ** BigInt(digits);
    const q = dir === 'ceil' ? cdiv(x.n * s, x.d) : fdiv(x.n * s, x.d);
    const neg = q < 0n, a = abs(q), ip = a / s, fp = (a % s).toString().padStart(digits, '0');
    return (neg ? '−' : '') + ip.toString() + (digits ? '.' + fp : '');
  }

  return Object.freeze({
    SCHEMA_NAME, SCHEMA_VERSION, SCOPE, RH_STATUS, PLACEHOLDER_SOURCE, METHOD_ID, MAX_PRIME, FACTORIAL_INDEX_MAX, BITS_MIN, BITS_MAX,
    NOTE_C1, NOTE_C2, BOUNDARY_NOTE_5040, K1_NOTE, ContractError, EnclosureError,
    buildAtom, withSource, canonicalText, canonicalBytes, threshold_components, factor_in_domain,
    F, add, sub, mul, div, cmp, enc_rat, parseRat, decimal,
  });
});
