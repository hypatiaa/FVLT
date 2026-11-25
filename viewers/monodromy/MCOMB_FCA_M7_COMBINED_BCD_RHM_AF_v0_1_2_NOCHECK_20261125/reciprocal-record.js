/* Reciprocal link v0.1 — BigInt port of the accepted reference builder and validator for the divisor
 * reciprocal record (schema 0.1.0, packet RECIPROCAL_RECORD_SPEC_v0_1_1_20260929/reciprocal_record.py).
 *
 * Port by worker B (Claude). Record form: Astra. The reading that 1/n is also n/1 (two readouts of one
 * atom): saphir. The record format is unchanged; this file adds nothing to it.
 *
 * Same declared domain as the reference: integer fields are canonical decimal strings of at most 400
 * digits; primes below 2^64 (Miller-Rabin, first 13 prime bases, as cited by the spec); atom exponents
 * 1..64; at most 16 primes; atom N < 10^400. Validation order follows the reference: structure first
 * (a hand port of reciprocal-record.schema.json), then the selected exponents are bound to the atom
 * primes, the exact regeneration build(...) runs on bounded (p, a, e), and every local row is bound to its
 * atom prime and selected exponent by exact text BEFORE its rational is parsed or any product is taken
 * (Astra F1). Raw import: byte cap, UTF-8 without BOM, duplicate keys, all numeric tokens and
 * NaN/Infinity rejected before validation. Export: one serializer equal to Python
 * json.dumps(data, separators=(",", ":"), ensure_ascii=True) + LF, capped at 1 MiB.
 * Exact integers only (BigInt); no floating point anywhere in this file.
 */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) module.exports = factory();
  else root.McombReciprocalLinkCoreV1 = factory();
})(typeof self !== 'undefined' ? self : this, function () {
  'use strict';
  const SCHEMA_VERSION = '0.1.0', KIND = 'divisor_reciprocal_record', CONVENTION = 'TWO_READOUTS_OF_ATOM_V1';
  const NOTE = 'TWO_READOUTS_OF_ONE_ATOM_NOT_AN_EQUALITY_OF_d_AND_1_OVER_d';
  const MAX_PRIMES = 16, MAX_EXPONENT = 64n, MAX_BYTES = 1024 * 1024, MAX_DIGITS = 400;
  const N_LIMIT = 10n ** 400n, TWO64 = 2n ** 64n;
  const UINT = /^(?:0|[1-9][0-9]*)$/, POS = /^[1-9][0-9]*$/;

  class ContractError extends Error { constructor(m) { super(m); this.name = 'ContractError'; } }
  const need = (ok, msg) => { if (!ok) throw new ContractError(msg); };
  const isObj = v => v !== null && typeof v === 'object' && !Array.isArray(v);
  const own = (o, k) => Object.prototype.hasOwnProperty.call(o, k);

  function gcd(a, b) { while (b) [a, b] = [b, a % b]; return a; }
  function uint(v, name, positive = false) {
    need(typeof v === 'string' && v.length <= MAX_DIGITS && UINT.test(v), `${name}: noncanonical integer string`);
    const n = BigInt(v);
    need(!positive || n > 0n, `${name}: positive integer required`);
    return n;
  }
  function rat(v, name) {
    need(isObj(v) && Object.keys(v).length === 2 && own(v, 'num') && own(v, 'den'), `${name}: rational fields are num and den`);
    const a = uint(v.num, name), b = uint(v.den, name, true);
    need(gcd(a, b) === 1n, `${name}: rational must be reduced`);
    return [a, b];
  }
  function enc(a, b) { const g = gcd(a, b); return { num: String(a / g), den: String(b / g) }; }
  function modpow(b, e, m) { let r = 1n; b %= m; while (e > 0n) { if (e & 1n) r = r * b % m; b = b * b % m; e >>= 1n; } return r; }
  /* Miller-Rabin with the first 13 prime bases; the reference uses it only for n < 2^64 and cites
     Sorenson and Webster (arXiv 1509.00864) for determinism there. Same bases, same order. */
  function isPrime(n) {
    if (n < 2n) return false;
    const small = [2n, 3n, 5n, 7n, 11n, 13n, 17n, 19n, 23n, 29n, 31n, 37n, 41n];
    for (const p of small) if (n % p === 0n) return n === p;
    let d = n - 1n, s = 0;
    while (d % 2n === 0n) { d /= 2n; s++; }
    for (const a of small) {
      let x = modpow(a, d, n);
      if (x === 1n || x === n - 1n) continue;
      let comp = true;
      for (let i = 0; i < s - 1; i++) { x = x * x % n; if (x === n - 1n) { comp = false; break; } }
      if (comp) return false;
    }
    return true;
  }
  const isInt = x => typeof x === 'bigint';   // the analogue of Python's exact int (bool excluded): BigInt only

  /** atomFactors: [[p, a]] (BigInt) with strictly increasing primes; selectedExponents: [e_p] (BigInt) aligned. */
  function build(atomFactors, selectedExponents) {
    need(Array.isArray(atomFactors) && atomFactors.length <= MAX_PRIMES, 'atom: a list of at most 16 (prime, exponent) pairs');
    need(Array.isArray(selectedExponents), 'selected exponents: a list of integers');
    need(atomFactors.every(f => Array.isArray(f) && f.length === 2 && isInt(f[0]) && isInt(f[1])), 'atom: each factor is an integer (prime, exponent) pair');
    need(selectedExponents.every(isInt), 'selected exponents must be integers');
    need(selectedExponents.length === atomFactors.length, 'one selected exponent per atom prime');
    for (const [p, a] of atomFactors) {
      need(2n <= p && p < TWO64 && isPrime(p), `atom prime ${p} is not a prime below 2^64`);
      need(1n <= a && a <= MAX_EXPONENT, 'atom exponent must be 1..64');
    }
    for (let i = 1; i < atomFactors.length; i++) need(atomFactors[i - 1][0] < atomFactors[i][0], 'atom primes must be strictly increasing');
    atomFactors.forEach(([p, a], i) => { const e = selectedExponents[i]; need(0n <= e && e <= a, `selected exponent of ${p} must lie in 0..${a} (d | N)`); });
    let N = 1n, d = 1n;
    atomFactors.forEach(([p, a], i) => { N *= p ** a; d *= p ** selectedExponents[i]; });   // bounded: p < 2^64, a <= 64, <= 16 primes
    need(N < N_LIMIT, 'atom N exceeds the declared domain of 400 decimal digits');
    const local = atomFactors.map(([p], i) => ({ prime: String(p), exponent: String(selectedExponents[i]), abs_p: enc(1n, p ** selectedExponents[i]) }));
    const prodNum = 1n; let prodDen = 1n;                   // empty product = 1
    atomFactors.forEach(([p], i) => { prodDen *= p ** selectedExponents[i]; });
    return {
      schema_version: SCHEMA_VERSION, kind: KIND, convention: CONVENTION, note: NOTE,
      atom: { N: String(N), factors: atomFactors.map(([p, a]) => ({ prime: String(p), exponent: String(a) })) },
      selected: { d: String(d), exponents: atomFactors.map(([p], i) => ({ prime: String(p), exponent: String(selectedExponents[i]) })) },
      local_factors: local,
      readouts: { archimedean: String(d), finite_product: enc(prodNum, prodDen) },
      balance: { reconstructed_d: String(d), product_of_local_factors: enc(prodNum, prodDen),
                 archimedean_times_finite: enc(d * prodNum, prodDen), equals_one: true },
    };
  }

  /* ---- structure: a hand port of reciprocal-record.schema.json (Draft 2020-12, closed objects) ---- */
  function closed(v, keys, at) {
    need(isObj(v), `STRUCTURE at ${at}: not an object`);
    for (const k of keys) need(own(v, k), `STRUCTURE at ${at}: '${k}' is a required property`);
    for (const k of Object.keys(v)) need(keys.includes(k), `STRUCTURE at ${at}: additional property '${k}'`);
  }
  // Python's re.search with '^...$' also admits one trailing "\n"; any such string is then rejected by the
  // semantic steps (canonical uint() or exact regeneration), so the accepted set is the same either way.
  const strPat = (v, re, at) => need(typeof v === 'string' && [...v].length <= MAX_DIGITS && re.test(v), `STRUCTURE at ${at}: not a canonical integer string`);
  const pos = (v, at) => strPat(v, POS, at), uns = (v, at) => strPat(v, UINT, at);
  function ratS(v, at) { closed(v, ['num', 'den'], at); uns(v.num, at + '/num'); pos(v.den, at + '/den'); }
  function arr(v, at) { need(Array.isArray(v) && v.length <= MAX_PRIMES, `STRUCTURE at ${at}: array of at most 16 items`); return v; }
  function structure(r) {
    closed(r, ['schema_version', 'kind', 'convention', 'note', 'atom', 'selected', 'local_factors', 'readouts', 'balance'], '<root>');
    need(r.schema_version === SCHEMA_VERSION, 'STRUCTURE at schema_version: const');
    need(r.kind === KIND, 'STRUCTURE at kind: const'); need(r.convention === CONVENTION, 'STRUCTURE at convention: const');
    need(r.note === NOTE, 'STRUCTURE at note: const');
    closed(r.atom, ['N', 'factors'], 'atom'); pos(r.atom.N, 'atom/N');
    arr(r.atom.factors, 'atom/factors').forEach((f, i) => { closed(f, ['prime', 'exponent'], `atom/factors/${i}`); pos(f.prime, 'prime'); pos(f.exponent, 'exponent'); });
    closed(r.selected, ['d', 'exponents'], 'selected'); pos(r.selected.d, 'selected/d');
    arr(r.selected.exponents, 'selected/exponents').forEach((f, i) => { closed(f, ['prime', 'exponent'], `selected/exponents/${i}`); pos(f.prime, 'prime'); uns(f.exponent, 'exponent'); });
    arr(r.local_factors, 'local_factors').forEach((f, i) => { closed(f, ['prime', 'exponent', 'abs_p'], `local_factors/${i}`); pos(f.prime, 'prime'); uns(f.exponent, 'exponent'); ratS(f.abs_p, `local_factors/${i}/abs_p`); });
    closed(r.readouts, ['archimedean', 'finite_product'], 'readouts'); pos(r.readouts.archimedean, 'readouts/archimedean'); ratS(r.readouts.finite_product, 'readouts/finite_product');
    closed(r.balance, ['reconstructed_d', 'product_of_local_factors', 'archimedean_times_finite', 'equals_one'], 'balance');
    pos(r.balance.reconstructed_d, 'balance/reconstructed_d'); ratS(r.balance.product_of_local_factors, 'balance/product_of_local_factors');
    const t = r.balance.archimedean_times_finite;
    need(isObj(t) && Object.keys(t).length === 2 && t.num === '1' && t.den === '1', 'STRUCTURE at balance/archimedean_times_finite: const 1/1');
    need(r.balance.equals_one === true, 'STRUCTURE at balance/equals_one: const true');
  }
  // Python dict/list equality: key order ignored, types exact.
  function same(a, b) {
    if (a === b) return true;
    if (Array.isArray(a)) return Array.isArray(b) && a.length === b.length && a.every((x, i) => same(x, b[i]));
    if (isObj(a)) { if (!isObj(b)) return false; const ka = Object.keys(a), kb = Object.keys(b); return ka.length === kb.length && ka.every(k => own(b, k) && same(a[k], b[k])); }
    return false;
  }

  /** Structure, then exact semantics. Any failure throws ContractError. */
  function validate(record) {
    try {
      structure(record);
      const fac = record.atom.factors.map(f => [uint(f.prime, 'prime', true), uint(f.exponent, 'exponent', true)]);
      const sel = record.selected.exponents;
      need(sel.length === record.atom.factors.length && sel.every((s, i) => s.prime === record.atom.factors[i].prime), 'selected exponents must list the atom primes in order');
      const es = sel.map(s => uint(s.exponent, 'selected exponent'));
      const expected = build(fac, es);                       // bounded before any power (build checks p, a, e first)
      let d = 1n; fac.forEach(([p], i) => { d *= p ** es[i]; });
      need(uint(record.selected.d, 'd', true) === d, 'd does not equal prod p^e_p');
      const local = record.local_factors;
      need(local.length === fac.length, 'local factors must list exactly the atom primes');
      local.forEach((lf, i) => {                             // Astra F1: bind by exact text BEFORE any arithmetic
        need(lf.prime === record.atom.factors[i].prime, 'local factor prime does not match the atom prime at this position');
        need(lf.exponent === sel[i].exponent, 'local factor exponent does not match the selected exponent');
      });
      let num = 1n, den = 1n;
      local.forEach((lf, i) => {
        const [a, b] = rat(lf.abs_p, 'abs_p'), [p] = fac[i];
        need(a === 1n && b === p ** es[i], `local factor of ${p} is not p^(-e_p)`);   // e <= 64, validated
        num *= a; den *= b;                                  // independent product of the submitted rows
      });
      need(num * d === den, 'product of local factors times d is not 1');
      need(same(record, expected), 'semantic mismatch: record differs from exact regeneration');
      return true;
    } catch (e) {
      if (e instanceof ContractError) throw e;
      throw new ContractError('MALFORMED: ' + (e && e.name || 'Error'));
    }
  }

  /* ---- export: Python json.dumps(data, separators=(",", ":"), ensure_ascii=True) + LF ---- */
  function dumps(v) {
    if (v === null) return 'null';
    if (v === true) return 'true'; if (v === false) return 'false';
    if (typeof v === 'string') return JSON.stringify(v).replace(/[^\x20-\x7e]/g, c => '\\u' + c.charCodeAt(0).toString(16).padStart(4, '0'));
    if (Array.isArray(v)) return '[' + v.map(dumps).join(',') + ']';
    if (isObj(v)) return '{' + Object.keys(v).map(k => dumps(k) + ':' + dumps(v[k])).join(',') + '}';
    throw new ContractError('EXPORT: only strings, booleans, null, arrays and objects are part of this format');
  }
  function canonicalText(record) {
    const t = dumps(record) + '\n';
    need(t.length <= MAX_BYTES, 'EXPORT: record exceeds 1 MiB');   // ASCII only: characters = bytes
    return t;
  }
  function canonicalBytes(record) { const t = canonicalText(record), b = new Uint8Array(t.length); for (let i = 0; i < t.length; i++) b[i] = t.charCodeAt(i); return b; }

  /* ---- raw import: a strict JSON reader equivalent to the reference load() ---- */
  const WS = new Set([' ', '\t', '\n', '\r']), MAX_DEPTH = 64;   // valid records nest 5 deep; Python rejects deep input (RecursionError)
  function parseStrict(text) {
    let i = 0;
    const fail = m => { throw new ContractError('JSON: ' + m); };
    const ws = () => { while (i < text.length && WS.has(text[i])) i++; };
    function str() {
      i++; let out = '';
      for (;;) {
        if (i >= text.length) fail('malformed (unterminated string)');
        const c = text[i], code = c.charCodeAt(0);
        if (c === '"') { i++; return out; }
        if (code < 0x20) fail('malformed (control character in string)');
        if (c !== '\\') { out += c; i++; continue; }
        const e = text[i + 1]; i += 2;
        const map = { '"': '"', '\\': '\\', '/': '/', b: '\b', f: '\f', n: '\n', r: '\r', t: '\t' };
        if (e !== undefined && own(map, e)) { out += map[e]; continue; }
        if (e === 'u') { const h = text.slice(i, i + 4); if (!/^[0-9a-fA-F]{4}$/.test(h)) fail('malformed (bad \\u escape)'); out += String.fromCharCode(parseInt(h, 16)); i += 4; continue; }
        fail('malformed (bad escape)');
      }
    }
    function value(depth) {
      if (depth > MAX_DEPTH) fail('malformed (nesting too deep)');
      ws(); const c = text[i];
      if (c === '{') {
        i++; const o = {}; ws();
        if (text[i] === '}') { i++; return o; }
        for (;;) {
          ws(); if (text[i] !== '"') fail('malformed (expected key)');
          const k = str(); ws(); if (text[i] !== ':') fail('malformed (expected colon)'); i++;
          const v = value(depth + 1);
          if (own(o, k)) fail(`duplicate key '${k}'`);
          Object.defineProperty(o, k, { value: v, enumerable: true, writable: true, configurable: true });   // safe for '__proto__'
          ws(); if (text[i] === ',') { i++; continue; } if (text[i] === '}') { i++; return o; } fail('malformed (expected , or })');
        }
      }
      if (c === '[') {
        i++; const a = []; ws();
        if (text[i] === ']') { i++; return a; }
        for (;;) { a.push(value(depth + 1)); ws(); if (text[i] === ',') { i++; continue; } if (text[i] === ']') { i++; return a; } fail('malformed (expected , or ])'); }
      }
      if (c === '"') return str();
      if (text.startsWith('true', i)) { i += 4; return true; }
      if (text.startsWith('false', i)) { i += 5; return false; }
      if (text.startsWith('null', i)) { i += 4; return null; }
      if (c === '-' || (c >= '0' && c <= '9') || text.startsWith('NaN', i) || text.startsWith('Infinity', i)) fail('numeric tokens are not part of this format');
      fail('malformed (unexpected token)');
    }
    const v = value(0); ws(); if (i !== text.length) fail('malformed (extra data)');
    return v;
  }
  /** Raw import: bytes (Uint8Array) -> validated record. */
  function load(raw) {
    need(raw instanceof Uint8Array, 'JSON: bytes required');
    need(raw.length <= MAX_BYTES, 'JSON: byte cap exceeded');
    need(!(raw.length >= 3 && raw[0] === 0xef && raw[1] === 0xbb && raw[2] === 0xbf), 'JSON: BOM not accepted');
    let text;
    try { text = new TextDecoder('utf-8', { fatal: true, ignoreBOM: true }).decode(raw); } catch (e) { throw new ContractError('JSON: malformed (UnicodeError)'); }
    const data = parseStrict(text);
    validate(data);
    return data;
  }

  return Object.freeze({ SCHEMA_VERSION, KIND, CONVENTION, NOTE, MAX_BYTES, MAX_DIGITS, ContractError, isPrime, build, validate, canonicalText, canonicalBytes, load, parseStrict });
});
