/* arithmetic-fourier 0.1.1: JavaScript port of af_reference.py (sha256 4425c6be41df8cff3d43506fe9d1013b31f728ab545dec11f9d030f4d741a061).
 * Builder candidate for the arithmetic-Fourier panel v0.1 (MCOMB_FCA_M7_COMBINED_BCD_AF_v0_1_20261001). Not accepted, sealed or passed.
 * Credit: purpose and atom reading, saphir; schema handoff, panel reviews and audits, Astra; schema construction, Fable (Claude);
 * panel handoff, the handoff drafter (Claude) under the oversight seat; this port and its checks, the builder (Claude).
 *
 * Ported statement for statement. Every value is a BigInt or a canonical string. Number appears only for loop counters and
 * array indices provably below 2^31, and in the strict upstream parser's finiteness decision for float tokens (HANDOFF 7.2
 * item 5, C1): a float token becomes {kind:'float', text, value:Number(text)} and value is used for nothing but
 * Number.isFinite. Python's // and % floor toward minus infinity; floorDiv/floorMod below reproduce that on BigInt.
 * No floating point enters any record field, comparison or status. No network, no timers, no DOM.
 */
(function (root) {
  'use strict';

  // ------------------------------------------------------------------ errors
  class ContractError extends Error {
    constructor(message) { super(message); this.name = 'ContractError'; }
  }
  function require_(cond, code, msg) { if (!cond) throw new ContractError(code + ': ' + msg); }
  const codeOf = e => String(e && e.message !== undefined ? e.message : e).split(':')[0];

  // ------------------------------------------------------------------ BigInt helpers (Python semantics)
  const floorDiv = (a, b) => { const q = a / b; return (a % b !== 0n && ((a < 0n) !== (b < 0n))) ? q - 1n : q; };
  const floorMod = (a, b) => { const r = a % b; return (r !== 0n && ((r < 0n) !== (b < 0n))) ? r + b : r; };
  const bigAbs = a => (a < 0n ? -a : a);
  function gcd(a, b) { a = bigAbs(a); b = bigAbs(b); while (b !== 0n) { const t = a % b; a = b; b = t; } return a; }
  function pow(b, e) { let r = 1n; for (let i = 0n; i < e; i++) r *= b; return r; }

  // ------------------------------------------------------------------ synchronous SHA-256
  const K = new Uint32Array([
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2]);
  function sha256Hex(bytes) {
    if (!isBytes(bytes)) throw new TypeError('sha256Hex: bytes required');
    const n = bytes.length, total = ((n + 9 + 63) >> 6) << 6, m = new Uint8Array(total);
    m.set(bytes); m[n] = 0x80;
    const bitsHi = Math.floor(n / 0x20000000), bitsLo = (n << 3) >>> 0;
    m[total - 8] = (bitsHi >>> 24) & 255; m[total - 7] = (bitsHi >>> 16) & 255; m[total - 6] = (bitsHi >>> 8) & 255; m[total - 5] = bitsHi & 255;
    m[total - 4] = (bitsLo >>> 24) & 255; m[total - 3] = (bitsLo >>> 16) & 255; m[total - 2] = (bitsLo >>> 8) & 255; m[total - 1] = bitsLo & 255;
    const H = new Uint32Array([0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19]), W = new Uint32Array(64);
    for (let off = 0; off < total; off += 64) {
      for (let i = 0; i < 16; i++) W[i] = (m[off + 4 * i] << 24) | (m[off + 4 * i + 1] << 16) | (m[off + 4 * i + 2] << 8) | m[off + 4 * i + 3];
      for (let i = 16; i < 64; i++) {
        const x = W[i - 15], y = W[i - 2];
        const s0 = ((x >>> 7) | (x << 25)) ^ ((x >>> 18) | (x << 14)) ^ (x >>> 3);
        const s1 = ((y >>> 17) | (y << 15)) ^ ((y >>> 19) | (y << 13)) ^ (y >>> 10);
        W[i] = (W[i - 16] + s0 + W[i - 7] + s1) | 0;
      }
      let a = H[0], b = H[1], c = H[2], d = H[3], e = H[4], f = H[5], g = H[6], h = H[7];
      for (let i = 0; i < 64; i++) {
        const S1 = ((e >>> 6) | (e << 26)) ^ ((e >>> 11) | (e << 21)) ^ ((e >>> 25) | (e << 7));
        const ch = (e & f) ^ (~e & g);
        const t1 = (h + S1 + ch + K[i] + W[i]) | 0;
        const S0 = ((a >>> 2) | (a << 30)) ^ ((a >>> 13) | (a << 19)) ^ ((a >>> 22) | (a << 10));
        const mj = (a & b) ^ (a & c) ^ (b & c);
        const t2 = (S0 + mj) | 0;
        h = g; g = f; f = e; e = (d + t1) | 0; d = c; c = b; b = a; a = (t1 + t2) | 0;
      }
      H[0] += a; H[1] += b; H[2] += c; H[3] += d; H[4] += e; H[5] += f; H[6] += g; H[7] += h;
    }
    let out = '';
    for (let i = 0; i < 8; i++) out += H[i].toString(16).padStart(8, '0');
    return out;
  }

  // ------------------------------------------------------------------ bytes and text
  function isBytes(x) { return x !== null && typeof x === 'object' && ArrayBuffer.isView(x) && Object.prototype.toString.call(x) === '[object Uint8Array]'; }
  function asciiBytes(s) {
    const out = new Uint8Array(s.length);
    for (let i = 0; i < s.length; i++) { const c = s.charCodeAt(i); if (c > 0x7f) throw new TypeError('asciiBytes: non-ASCII'); out[i] = c; }
    return out;
  }
  function utf8Bytes(s) {          // strict: a lone surrogate throws, as Python's str.encode('utf-8') raises
    const out = [];
    for (let i = 0; i < s.length; i++) {
      let c = s.charCodeAt(i);
      if (c >= 0xd800 && c <= 0xdbff) {
        const d = i + 1 < s.length ? s.charCodeAt(i + 1) : 0;
        if (d >= 0xdc00 && d <= 0xdfff) { c = 0x10000 + ((c - 0xd800) << 10) + (d - 0xdc00); i++; } else throw new TypeError('utf8Bytes: lone surrogate');
      } else if (c >= 0xdc00 && c <= 0xdfff) throw new TypeError('utf8Bytes: lone surrogate');
      if (c < 0x80) out.push(c);
      else if (c < 0x800) out.push(0xc0 | (c >> 6), 0x80 | (c & 63));
      else if (c < 0x10000) out.push(0xe0 | (c >> 12), 0x80 | ((c >> 6) & 63), 0x80 | (c & 63));
      else out.push(0xf0 | (c >> 18), 0x80 | ((c >> 12) & 63), 0x80 | ((c >> 6) & 63), 0x80 | (c & 63));
    }
    return Uint8Array.from(out);
  }
  let decoder = null;
  function strictUtf8(bytes) {     // null when malformed (Python: UnicodeDecodeError)
    if (!decoder) decoder = new TextDecoder('utf-8', { fatal: true, ignoreBOM: true });
    try { return decoder.decode(bytes); } catch (_) { return null; }
  }
  function cpLength(s) { let n = 0; for (let i = 0; i < s.length; i++) { const c = s.charCodeAt(i); if (c >= 0xd800 && c <= 0xdbff && i + 1 < s.length) { const d = s.charCodeAt(i + 1); if (d >= 0xdc00 && d <= 0xdfff) i++; } n++; } return n; }
  function cpCompare(a, b) {        // Python str ordering: by code point
    let i = 0, j = 0;
    while (i < a.length && j < b.length) {
      let x = a.codePointAt(i), y = b.codePointAt(j);
      // a lone surrogate is its own code point; codePointAt already returns it
      if (x !== y) return x < y ? -1 : 1;
      i += x > 0xffff ? 2 : 1; j += y > 0xffff ? 2 : 1;
    }
    if (i >= a.length) return j >= b.length ? 0 : -1;
    return 1;
  }

  // ------------------------------------------------------------------ the one serializer (json.dumps, sort_keys, compact)
  const own = (o, k) => Object.prototype.hasOwnProperty.call(o, k);
  const get = (o, k) => (own(o, k) ? o[k] : undefined);           // Python dict.get
  function isDict(x) {
    if (x === null || typeof x !== 'object' || Array.isArray(x) || isBytes(x)) return false;
    const p = Object.getPrototypeOf(x);
    return p === null || p === Object.prototype || (p && p.constructor && p.constructor.name === 'Object' && Object.getPrototypeOf(p) === null);
  }
  function escapeString(s, ensureAscii) {
    let out = '"';
    for (let i = 0; i < s.length; i++) {
      const c = s.charCodeAt(i);
      if (c === 0x22) out += '\\"';
      else if (c === 0x5c) out += '\\\\';
      else if (c === 0x0a) out += '\\n';
      else if (c === 0x0d) out += '\\r';
      else if (c === 0x09) out += '\\t';
      else if (c === 0x08) out += '\\b';
      else if (c === 0x0c) out += '\\f';
      else if (c < 0x20 || (ensureAscii && c > 0x7e)) out += '\\u' + c.toString(16).padStart(4, '0');
      else out += s[i];
    }
    return out + '"';
  }
  function pyDumps(x, ensureAscii) {
    if (typeof x === 'string') return escapeString(x, ensureAscii);
    if (typeof x === 'bigint') return x.toString();
    if (x === true) return 'true';
    if (x === false) return 'false';
    if (x === null) return 'null';
    if (typeof x === 'number') { if (Number.isSafeInteger(x)) return String(x); throw new TypeError('pyDumps: non-integer number'); }
    if (Array.isArray(x)) return '[' + x.map(v => pyDumps(v, ensureAscii)).join(',') + ']';
    if (isDict(x)) {
      const keys = Object.keys(x).sort(cpCompare);
      return '{' + keys.map(k => escapeString(k, ensureAscii) + ':' + pyDumps(x[k], ensureAscii)).join(',') + '}';
    }
    throw new TypeError('pyDumps: unsupported value');
  }
  const canonical = x => pyDumps(x, true);                         // sorted keys, compact, ASCII (no trailing LF)

  // ------------------------------------------------------------------ constants (af_reference.py)
  const SCHEMA_NAME = 'arithmetic-fourier', SCHEMA_VERSION = '0.1.1', KIND = 'af_atom_comparison';
  const SCOPE = 'Finite local facts and finite coefficient assembly for one integral Weierstrass model ' +
    'and one atom. Agreement on the listed indices is exact equality on those indices only. ' +
    'It does not prove that two L-functions are equal, and it supplies no L-value, rank, ' +
    'regulator, Sha, BSD or RH conclusion.';
  const EXCLUSIONS = Object.freeze(['NO_L_VALUE_OR_CENTRAL_VALUE', 'NO_ANALYTIC_OR_ALGEBRAIC_RANK', 'NO_REGULATOR_OR_SHA', 'NO_BSD_OR_RH_CONCLUSION',
    'NO_STURM_ARGUMENT', 'NO_CONDUCTOR_OR_COMPLETE_BAD_PRIME_INVENTORY', 'NO_GLOBAL_MINIMAL_MODEL', 'NOT_THE_VIEWER_DFT_RAMANUJAN_FCA_OR_GEOMETRIC_MODES']);
  const METHOD = Object.freeze({
    reference: 'af_reference', version: '0.1.1', point_count: 'PROJECTIVE_BRUTE_FORCE_OVER_X_AND_Y_INCLUDING_INFINITY',
    local_criterion: 'UNIT_DISCRIMINANT_THEN_C4_RESIDUE_THEN_LASKA_KRAUS_CONNELL_EXPONENT', polynomial_order: 'ASCENDING_POWERS_OF_T',
    euler_variable: 'T_EQUALS_P_TO_THE_MINUS_S', q_convention: 'Q_EQUALS_EXP_2_PI_I_Z', serializer: 'SORTED_KEYS_COMPACT_ASCII_ONE_LF' });
  const A_MAX = 10n ** 6n, P_MAX = 257n, PRIMES_MAX = 55, N_MAX = 10n ** 6n, PREFIX_MAX = 256n, INDICES_MAX = 256, COEFF_ABS_MAX = 10n ** 9n,
    LEVEL_MAX = 10n ** 9n, QP_FACTORS_MAX = 4, RAW_CAP = 1 << 20, UPSTREAM_CAP = 1 << 20, UPSTREAM_DEPTH_MAX = 16, UPSTREAM_CLASS_ROWS_MAX = 64,
    DEPTH_MAX = 8, ARRAY_MAX = 256, STRING_MAX = 400;

  // ------------------------------------------------------------------ source registry (fixed, five entries)
  const ROLE_MF = 'LMFDB_MF_NEWFORMS_ROW', ROLE_EC = 'LMFDB_EC_CURVEDATA_CLASS';
  const SOURCE_REGISTRY = {
    schema: 'arithmetic-fourier-source-registry', schema_version: '0.1.1', standing: 'PROPOSED_BY_THE_BUILDER_PENDING_INDEPENDENT_REVIEW',
    entries: [
      { sha256: '240d874a54a56e68295d9ede98c8ca67f819fb19a26495ea75c6417cb2f0391c', role: 'LMFDB_MF_NEWFORMS_ROW', locator: '32.2.a.a', bytes: '14917',
        file: 'sources/lmfdb_api_mf_newforms_32.2.a.a.json', url: 'https://www.lmfdb.org/api/mf_newforms/?label=32.2.a.a&_format=json', acquired: '2026-10-01' },
      { sha256: 'c9e065fad170bdfcf0299b33ff77ee16afaa6c7d266e9cbdb1192efa474cded1', role: 'LMFDB_MF_NEWFORMS_ROW', locator: '37.2.a.a', bytes: '15353',
        file: 'sources/lmfdb_api_mf_newforms_37.2.a.a.json', url: 'https://www.lmfdb.org/api/mf_newforms/?label=37.2.a.a&_format=json', acquired: '2026-10-01' },
      { sha256: '13769b7e6c64f826ba307ed0a632674097e5083eb2a9e8b6b0a9550a6904af03', role: 'LMFDB_EC_CURVEDATA_CLASS', locator: '11.a', bytes: '6539',
        file: 'sources/lmfdb_api_ec_curvedata_11.a.json', url: 'https://www.lmfdb.org/api/ec_curvedata/?lmfdb_iso=11.a&_format=json', acquired: '2026-10-01' },
      { sha256: '5cf5ba4e4f52123d488c1cacc505b953c137d64076b466d17d8886f51355035e', role: 'LMFDB_EC_CURVEDATA_CLASS', locator: '32.a', bytes: '7437',
        file: 'sources/lmfdb_api_ec_curvedata_32.a.json', url: 'https://www.lmfdb.org/api/ec_curvedata/?lmfdb_iso=32.a&_format=json', acquired: '2026-10-01' },
      { sha256: '73cf59c902240ed2b8f767ed47b84e03b2344a601ed04977851f28991e5fbead', role: 'LMFDB_EC_CURVEDATA_CLASS', locator: '37.a', bytes: '2211',
        file: 'sources/lmfdb_api_ec_curvedata_37.a.json', url: 'https://www.lmfdb.org/api/ec_curvedata/?lmfdb_iso=37.a&_format=json', acquired: '2026-10-01' }
    ]
  };
  const REGISTRY_SHA256_EXPECTED = '0942479e6f84288323b605d7ffd14a679e71ff1947c14c9832d34470209b56a9';
  const REG = new Map(SOURCE_REGISTRY.entries.map(e => [e.sha256, e]));
  const regGet = d => (typeof d === 'string' && REG.has(d) ? REG.get(d) : undefined);
  const registryBytes = () => asciiBytes(pyDumps(SOURCE_REGISTRY, true) + '\n');
  const registrySha256 = () => sha256Hex(registryBytes());
  // Hash-checked at load: if the embedded registry does not reproduce its accepted digest, the port refuses to load.
  const REGISTRY_OK = registrySha256() === REGISTRY_SHA256_EXPECTED;
  if (!REGISTRY_OK) throw new Error('arithmetic-Fourier port: the embedded source registry does not reproduce 0942479e…56a9; refusing to load');

  const INT_RE = /^(?:0|-?[1-9][0-9]{0,39})$/, UINT_RE = /^(?:0|[1-9][0-9]{0,39})$/, HEX_RE = /^[0-9a-f]{64}$/;
  const LABEL_RE = /^([1-9][0-9]{0,8})\.2\.a\.[a-z]{1,4}$/, ISO_RE = /^([1-9][0-9]{0,8})\.([a-z]{1,4})$/, STATEMENT_RE = /^[ -~]{1,300}$/;
  const EXTRACTION_MF = 'LMFDB_MF_NEWFORMS_API_TRACES_V1', WITNESS_LMFDB = 'LMFDB_CLASS_LINK';

  // ------------------------------------------------------------------ strings
  function _int(v, code, name, lo, hi) {
    require_(typeof v === 'string' && INT_RE.test(v), code, name + ': not a canonical integer string');
    const x = BigInt(v);
    require_((lo === undefined || x >= lo) && (hi === undefined || x <= hi), code, name + ': outside the declared range');
    return x;
  }
  function _uint(v, code, name, lo = 0n, hi) {
    require_(typeof v === 'string' && UINT_RE.test(v), code, name + ': not a canonical natural-number string');
    const x = BigInt(v);
    require_(x >= lo && (hi === undefined || x <= hi), code, name + ': outside the declared range');
    return x;
  }
  function sameKeySet(obj, expected) {
    const ks = Object.keys(obj); if (ks.length !== expected.length) return false;
    const want = new Set(expected); for (const k of ks) if (!want.has(k)) return false; return true;
  }
  function _keys(obj, expected, code, name) { require_(isDict(obj) && sameKeySet(obj, expected), code, name + ': key set differs from the contract'); }
  function _is_prime(p) {
    if (p < 2n) return false;
    let d = 2n;
    while (d * d <= p) { if (p % d === 0n) return false; d += 1n; }
    return true;
  }

  // ------------------------------------------------------------------ canonical bytes
  function serialize(record) {
    const raw = asciiBytes(pyDumps(record, true) + '\n');
    require_(raw.length <= RAW_CAP, 'V0', 'record exceeds the 1 MiB output cap');
    return raw;
  }
  function _depth_scan(raw, limit = DEPTH_MAX, code = 'R') {
    let depth = 0, inStr = false, esc = false;
    for (let i = 0; i < raw.length; i++) {
      const b = raw[i];
      if (inStr) { if (esc) esc = false; else if (b === 0x5c) esc = true; else if (b === 0x22) inStr = false; }
      else if (b === 0x22) inStr = true;
      else if (b === 0x7b || b === 0x5b) { depth += 1; require_(depth <= limit, code, 'nesting deeper than the declared limit'); }
      else if (b === 0x7d || b === 0x5d) depth -= 1;
    }
  }

  // Strict JSON text parser with Python json.loads acceptance (C scanner, strict=True). mode 'R' (records: every number
  // token refused, NaN/Infinity refused) or 'U' (upstream: integer tokens -> tagged BigInt, float tokens -> tagged finite).
  class UpNum { constructor(kind, value, text) { this.kind = kind; this.value = value; this.text = text; Object.freeze(this); } }
  const NUM_RE = /-?(?:0|[1-9][0-9]*)(?:\.[0-9]+)?(?:[eE][-+]?[0-9]+)?/y;
  const HEX4 = /^[0-9a-fA-F]{4}$/;
  function parseText(text, mode) {
    const code = mode, n = text.length;
    let i = 0;
    const bad = m => { throw new ContractError(code + (mode === 'U' ? ': upstream attachment: ' : ': ') + m); };
    const ws = () => { while (i < n) { const c = text.charCodeAt(i); if (c === 0x20 || c === 0x09 || c === 0x0a || c === 0x0d) i++; else break; } };
    function str() {           // at the opening quote
      i++;
      let out = '';
      for (;;) {
        if (i >= n) bad('not one well-formed JSON value');
        const c = text.charCodeAt(i);
        if (c === 0x22) { i++; return out; }
        if (c < 0x20) bad('not one well-formed JSON value');
        if (c !== 0x5c) { out += text[i]; i++; continue; }
        i++;
        if (i >= n) bad('not one well-formed JSON value');
        const e = text[i];
        if (e === '"') out += '"'; else if (e === '\\') out += '\\'; else if (e === '/') out += '/';
        else if (e === 'b') out += '\b'; else if (e === 'f') out += '\f'; else if (e === 'n') out += '\n';
        else if (e === 'r') out += '\r'; else if (e === 't') out += '\t';
        else if (e === 'u') { const h = text.slice(i + 1, i + 5); if (!HEX4.test(h)) bad('not one well-formed JSON value'); out += String.fromCharCode(parseInt(h, 16)); i += 4; }
        else bad('not one well-formed JSON value');
        i++;
      }
    }
    function value() {
      ws();
      if (i >= n) bad('not one well-formed JSON value');
      const c = text[i];
      if (c === '{') {
        i++; const obj = {}; ws();
        if (text[i] === '}') { i++; return obj; }
        for (;;) {
          ws();
          if (text[i] !== '"') bad('not one well-formed JSON value');
          const k = str(); ws();
          if (text[i] !== ':') bad('not one well-formed JSON value');
          i++;
          const v = value();
          if (own(obj, k)) bad('duplicate key');
          Object.defineProperty(obj, k, { value: v, enumerable: true, writable: true, configurable: true });
          ws();
          if (text[i] === '}') { i++; return obj; }
          if (text[i] !== ',') bad('not one well-formed JSON value');
          i++;
        }
      }
      if (c === '[') {
        i++; const arr = []; ws();
        if (text[i] === ']') { i++; return arr; }
        for (;;) {
          arr.push(value()); ws();
          if (text[i] === ']') { i++; return arr; }
          if (text[i] !== ',') bad('not one well-formed JSON value');
          i++;
        }
      }
      if (c === '"') return str();
      if (c === 'n' && text.startsWith('null', i)) { i += 4; return null; }
      if (c === 't' && text.startsWith('true', i)) { i += 4; return true; }
      if (c === 'f' && text.startsWith('false', i)) { i += 5; return false; }
      if ((c === 'N' && text.startsWith('NaN', i)) || (c === 'I' && text.startsWith('Infinity', i)) || (c === '-' && text.startsWith('-Infinity', i)))
        throw new ContractError(mode === 'U' ? 'U: upstream attachment: NaN or Infinity token' : 'R: NaN or Infinity token');
      NUM_RE.lastIndex = i;
      const m = NUM_RE.exec(text);
      if (!m) bad('not one well-formed JSON value');
      const tok = m[0]; i += tok.length;
      if (mode === 'R') throw new ContractError('R: numeric token in the record (all numbers are strings)');
      if (/[.eE]/.test(tok)) {
        const v = Number(tok);                                      // C1: finiteness only
        if (!Number.isFinite(v)) throw new ContractError('U: upstream attachment: non-finite number');
        return new UpNum('float', v, tok);
      }
      const digits = tok[0] === '-' ? tok.length - 1 : tok.length;
      if (digits > 4300) bad('not one well-formed JSON value');     // Python int() string-conversion limit (ValueError)
      return new UpNum('int', BigInt(tok), tok);
    }
    ws();
    const v = value();
    ws();
    if (i !== n) bad('not one well-formed JSON value');
    return v;
  }
  function _limits(node) {
    if (isDict(node)) {
      for (const k of Object.keys(node)) { require_(cpLength(k) <= STRING_MAX, 'R', 'key longer than the declared limit'); _limits(node[k]); }
    } else if (Array.isArray(node)) {
      require_(node.length <= ARRAY_MAX, 'R', 'array longer than the declared limit');
      for (const v of node) _limits(v);
    } else if (typeof node === 'string') {
      require_(cpLength(node) <= STRING_MAX, 'R', 'string longer than the declared limit');
    } else throw new ContractError('R: only objects, arrays and strings are admitted');
  }
  function load_json_bytes(raw) {
    require_(isBytes(raw), 'R', 'raw input must be bytes');
    require_(raw.length <= RAW_CAP, 'R', 'raw input exceeds 1 MiB');
    require_(!(raw.length >= 3 && raw[0] === 0xef && raw[1] === 0xbb && raw[2] === 0xbf), 'R', 'byte-order mark');
    const text = strictUtf8(raw);
    if (text === null) throw new ContractError('R: malformed UTF-8');
    _depth_scan(raw);
    const obj = parseText(text, 'R');
    require_(isDict(obj), 'R', 'top level must be an object');
    _limits(obj);
    return obj;
  }

  // ------------------------------------------------------------------ curve
  function curve_invariants(a) {
    const [a1, a2, a3, a4, a6] = a;
    const b2 = a1 * a1 + 4n * a2, b4 = 2n * a4 + a1 * a3, b6 = a3 * a3 + 4n * a6;
    const b8 = a1 * a1 * a6 + 4n * a2 * a6 - a1 * a3 * a4 + a2 * a3 * a3 - a4 * a4;
    const c4 = b2 * b2 - 24n * b4;
    const c6 = -(b2 ** 3n) + 36n * b2 * b4 - 216n * b6;
    const delta = -b2 * b2 * b8 - 8n * b4 ** 3n - 27n * b6 * b6 + 9n * b2 * b4 * b6;
    return { b2, b4, b6, b8, c4, c6, discriminant: delta };
  }
  function model_id(ainvsText, invText) {
    const body = { field: 'Q', ainvs: ainvsText, invariants: invText };
    return sha256Hex(utf8Bytes(pyDumps(body, false)));
  }
  function _vp(n, p) { let v = 0n; while (floorMod(n, p) === 0n) { n = floorDiv(n, p); v += 1n; } return v; }
  function scaling_exponent(c4, c6, delta, p) {
    const g = gcd(c6 * c6, delta);
    let d = floorDiv(_vp(g, p), 12n);
    if (d > 0n) {
      if (p === 2n) {
        const a = floorMod(floorDiv(c4, pow(2n, 4n * d)), 16n);
        const b = floorMod(floorDiv(c6, pow(2n, 6n * d)), 32n);
        if (floorMod(b, 4n) !== 3n && !(a === 0n && (b === 0n || b === 8n))) d -= 1n;
      } else if (p === 3n) {
        if (c6 !== 0n && _vp(c6, 3n) === 6n * d + 2n) d -= 1n;
      }
    }
    return d;
  }
  function count_points(a, p) {
    const [a1, a2, a3, a4, a6] = a.map(x => floorMod(x, p));
    let n = 1n;
    for (let x = 0n; x < p; x++) {
      const rhs = floorMod(x * x * x + a2 * x * x + a4 * x + a6, p);
      const t = floorMod(a1 * x + a3, p);
      for (let y = 0n; y < p; y++) if (floorMod(y * y + t * y - rhs, p) === 0n) n += 1n;
    }
    return n;
  }
  function local_row(a, inv, p) {
    const c4 = inv.c4, c6 = inv.c6, delta = inv.discriminant;
    const vd = _vp(delta, p);
    const row = { prime: String(p), valuations: { discriminant: String(vd), c4: c4 === 0n ? 'INFINITE' : String(_vp(c4, p)), c6: c6 === 0n ? 'INFINITE' : String(_vp(c6, p)) } };
    const d = vd > 0n ? scaling_exponent(c4, c6, delta, p) : 0n;
    row.scaling_exponent = String(d);
    row.minimality = d === 0n ? 'MINIMAL_AT_P' : 'NONMINIMAL_AT_P';
    if (d > 0n) { row.reduction = 'REDUCTION_UNRESOLVED'; row.unresolved_reason = 'MODEL_NONMINIMAL_AT_P'; return [row, null]; }
    const count = count_points(a, p);
    const ap = p + 1n - count;
    let kind, shape, rule, poly;
    if (vd === 0n) {
      kind = 'GOOD'; shape = 'NONSINGULAR'; rule = 'GOOD_RECURRENCE'; poly = [1n, -ap, p];
      require_(ap * ap <= 4n * p, 'E', 'internal: Hasse bound violated at a good prime');
    } else if (floorMod(c4, p) !== 0n) {
      shape = 'NODE';
      require_(ap === 1n || ap === -1n, 'E', 'internal: node count is neither p nor p + 2');
      if (ap === 1n) { kind = 'SPLIT_MULTIPLICATIVE'; rule = 'SPLIT_ALL_ONE'; poly = [1n, -1n]; }
      else { kind = 'NONSPLIT_MULTIPLICATIVE'; rule = 'NONSPLIT_ALTERNATING'; poly = [1n, 1n]; }
    } else {
      shape = 'CUSP';
      require_(ap === 0n, 'E', 'internal: cusp count is not p + 1');
      kind = 'ADDITIVE'; rule = 'ADDITIVE_ZERO'; poly = [1n];
    }
    row.reduction = kind; row.reduced_curve = shape; row.reduced_point_count = String(count); row.a_p = String(ap);
    row.denominator_polynomial = poly.map(c => String(c));
    return [row, [rule, ap]];
  }
  function prime_power_coefficients(rule, ap, p, e) {
    const out = [1n];
    for (let k = 1; BigInt(k) <= e; k++) {
      if (rule === 'GOOD_RECURRENCE') out.push(k === 1 ? ap : ap * out[k - 1] - p * out[k - 2]);
      else if (rule === 'SPLIT_ALL_ONE') out.push(1n);
      else if (rule === 'NONSPLIT_ALTERNATING') out.push(-out[k - 1]);
      else out.push(0n);
    }
    return out;
  }
  function factor_over(m, primes) {
    const out = [];
    for (const p of primes) {
      if (floorMod(m, p) === 0n) { let e = 0n; while (floorMod(m, p) === 0n) { m = floorDiv(m, p); e += 1n; } out.push([p, e]); }
    }
    return m === 1n ? out : null;
  }
  function q_product_coefficients(factors, length) {
    const L = Number(length);                                       // array length, at most 256
    const poly = new Array(L).fill(0n);
    poly[0] = 1n;
    for (const [d, r] of factors) {
      let n = 1n;
      while (d * n <= length - 1n) {
        const step = d * n, s = Number(step);                       // array index, below 256
        for (let rep = 0n; rep < r; rep++) for (let k = L - 1; k >= s; k--) poly[k] -= poly[k - s];
        n += 1n;
      }
    }
    return poly;
  }
  const coefficients_sha256 = coeffs => sha256Hex(asciiBytes(coeffs.join('\n') + '\n'));

  // ------------------------------------------------------------------ inputs
  function _check_claim(claim, code) {
    _keys(claim, ['level', 'label_locator'], code, 'modular.claim');
    const level = _uint(claim.level, code, 'claim.level', 1n, LEVEL_MAX);
    const lab = claim.label_locator;
    require_(typeof lab === 'string', code, 'claim.label_locator must be a string');
    if (lab !== 'NONE') {
      const m = LABEL_RE.exec(lab);
      require_(m !== null, code, 'claim.label_locator: not a weight-2 trivial-character newform locator');
      require_(BigInt(m[1]) === level, code, 'claim.label_locator: level differs from claim.level');
    }
    return level;
  }
  // check_inputs: V0 then V1 then V2. stopAfterV0 (panel use only) returns after the V0 section, unchanged otherwise.
  function check_inputs(inp, stopAfterV0 = false) {
    _keys(inp, ['ainvs', 'atom', 'primes', 'indices', 'modular', 'association'], 'V0', 'inputs');
    const av = inp.ainvs;
    require_(Array.isArray(av) && av.length === 5, 'V0', 'ainvs: five coefficients a1,a2,a3,a4,a6');
    const a = av.map(x => _int(x, 'V0', 'ainvs', -A_MAX, A_MAX));
    const n = _uint(inp.atom, 'V0', 'atom', 1n, N_MAX);
    const pl = inp.primes;
    require_(Array.isArray(pl) && pl.length <= PRIMES_MAX, 'V0', 'primes: at most 55 requested primes');
    const primes = pl.map(x => _uint(x, 'V0', 'prime', 2n, P_MAX));
    const il = inp.indices;
    require_(Array.isArray(il) && il.length >= 1 && il.length <= INDICES_MAX, 'V0', 'indices: 1 to 256 comparison indices');
    const indices = il.map(x => _uint(x, 'V0', 'index', 1n, N_MAX));

    const mod = inp.modular;
    require_(isDict(mod) && typeof get(mod, 'origin') === 'string', 'V0', 'modular.origin missing');
    const origin = mod.origin;
    const m = { origin, registered: false, assoc_registered: false };
    if (origin === 'NONE') {
      _keys(mod, ['origin'], 'V0', 'modular');
    } else if (origin === 'Q_PRODUCT') {
      _keys(mod, ['origin', 'factors', 'prefix_length', 'claim'], 'V0', 'modular');
      const fl = mod.factors;
      require_(Array.isArray(fl) && fl.length >= 1 && fl.length <= QP_FACTORS_MAX, 'V0', 'q-product: 1 to 4 factors');
      const fac = [];
      for (const f of fl) {
        _keys(f, ['d', 'r'], 'V0', 'q-product factor');
        fac.push([_uint(f.d, 'V0', 'q-product d', 1n, PREFIX_MAX), _uint(f.r, 'V0', 'q-product r', 1n, 4n)]);
      }
      let inc = true; for (let i = 0; i < fac.length - 1; i++) if (!(fac[i][0] < fac[i + 1][0])) inc = false;
      require_(inc, 'V0', 'q-product: d strictly increasing');
      require_(fac.reduce((s, [d, r]) => s + d * r, 0n) === 24n, 'V0', 'q-product: sum of d*r must be 24 (leading term q)');
      require_(fac.reduce((s, [, r]) => s + r, 0n) === 4n, 'V0', 'q-product: sum of r must be 4 (weight 2)');
      m.factors = fac;
      m.length = _uint(mod.prefix_length, 'V0', 'prefix_length', 1n, PREFIX_MAX);
      m.level = _check_claim(mod.claim, 'V0');
      m.claim = mod.claim;
    } else if (origin === 'SUPPLIED_TABLE') {
      _keys(mod, ['origin', 'coefficients', 'origin_statement', 'upstream', 'claim'], 'V0', 'modular');
      const cl = mod.coefficients;
      require_(Array.isArray(cl) && cl.length >= 1 && BigInt(cl.length) <= PREFIX_MAX, 'V0', 'table: 1 to 256 coefficients');
      for (const c of cl) _int(c, 'V0', 'table coefficient', -COEFF_ABS_MAX, COEFF_ABS_MAX);
      require_(cl[0] === '1', 'V0', 'table: a_1 must be 1 (normalized form)');
      const st = mod.origin_statement;
      require_(typeof st === 'string' && STATEMENT_RE.test(st), 'V0', 'origin_statement: 1 to 300 printable ASCII characters');
      const up = mod.upstream;
      _keys(up, ['sha256', 'extraction'], 'V0', 'modular.upstream');
      require_(typeof up.sha256 === 'string' && typeof up.extraction === 'string', 'V0', 'upstream fields must be strings');
      if (up.sha256 === 'NONE') require_(up.extraction === 'NONE', 'V0', 'upstream: no digest, so no extraction rule');
      else {
        require_(HEX_RE.test(up.sha256), 'V0', 'upstream.sha256: 64 lowercase hex');
        require_(up.extraction === EXTRACTION_MF, 'V0', 'upstream.extraction: unknown rule');
      }
      m.level = _check_claim(mod.claim, 'V0');
      if (up.sha256 !== 'NONE') {
        require_(mod.claim.label_locator !== 'NONE', 'V0', 'an upstream newform record needs its label locator');
        const ent = regGet(up.sha256);
        if (ent !== undefined) {
          require_(ent.role === ROLE_MF, 'V0', 'a registered source is declared in a role it does not have');
          require_(ent.locator === mod.claim.label_locator, 'V0', 'registered newform row: its label differs from the claimed label');
          m.registered = true;
        }
      }
      m.coeffs = cl.slice();
      m.length = BigInt(cl.length);
      m.statement = st;
      m.upstream = { sha256: up.sha256, extraction: up.extraction };
      m.claim = mod.claim;
    } else if (origin === 'DERIVED_FROM_CURVE') {
      _keys(mod, ['origin', 'prefix_length'], 'V0', 'modular');
      m.length = _uint(mod.prefix_length, 'V0', 'prefix_length', 1n, PREFIX_MAX);
    } else throw new ContractError('V0: modular.origin: unknown value');

    const assoc = inp.association;
    require_(isDict(assoc) && typeof get(assoc, 'witness') === 'string', 'V0', 'association.witness missing');
    if (assoc.witness === 'NONE') {
      _keys(assoc, ['witness'], 'V0', 'association');
    } else if (assoc.witness === WITNESS_LMFDB) {
      _keys(assoc, ['witness', 'curve_upstream_sha256', 'iso_class'], 'V0', 'association');
      require_(typeof assoc.curve_upstream_sha256 === 'string' && HEX_RE.test(assoc.curve_upstream_sha256), 'V0', 'association.curve_upstream_sha256: 64 lowercase hex');
      const im = typeof assoc.iso_class === 'string' ? ISO_RE.exec(assoc.iso_class) : null;
      require_(im !== null, 'V0', 'association.iso_class: not an isogeny-class locator');
      require_(origin === 'SUPPLIED_TABLE' && m.upstream.sha256 !== 'NONE', 'V0', 'this witness needs a supplied table with an upstream newform record');
      require_(BigInt(im[1]) === m.level, 'V0', 'association.iso_class: conductor differs from claim.level');
      const ent = regGet(assoc.curve_upstream_sha256);
      if (ent !== undefined) {
        require_(ent.role === ROLE_EC, 'V0', 'a registered source is declared in a role it does not have');
        require_(ent.locator === assoc.iso_class, 'V0', 'registered curve-class listing: its class differs from the declared class');
        m.assoc_registered = m.registered;
      }
    } else throw new ContractError('V0: association.witness: unknown value');
    if (stopAfterV0) return null;

    // V1: primality, order, factorization
    require_(primes.every(p => _is_prime(p)), 'V1', 'requested primes: a composite entry');
    let ok = true; for (let i = 0; i < primes.length - 1; i++) if (!(primes[i] < primes[i + 1])) ok = false;
    require_(ok, 'V1', 'requested primes: strictly increasing');
    ok = true; for (let i = 0; i < indices.length - 1; i++) if (!(indices[i] < indices[i + 1])) ok = false;
    require_(ok, 'V1', 'indices: strictly increasing');
    require_(indices.includes(n), 'V1', 'the atom must be one of the comparison indices');
    const fact = new Map();
    for (const idx of indices) {
      const f = factor_over(idx, primes);
      require_(f !== null, 'V1', 'an index has a prime factor outside the requested primes');
      fact.set(idx, f);
    }
    if (origin === 'DERIVED_FROM_CURVE') {
      const need = []; for (let p = 2n; p <= m.length; p++) if (_is_prime(p)) need.push(p);
      require_(need.every(p => primes.includes(p)), 'V1', 'a derived prefix needs every prime up to its length among the requested primes');
    }
    // V2: the curve
    const inv = curve_invariants(a);
    require_(inv.discriminant !== 0n, 'V2', 'singular model (discriminant zero)');
    return { a, ainvs_text: av.slice(), n, primes, indices, fact, inv, mod: m, assoc: Object.assign({}, assoc) };
  }

  function fractionText(num, den) {           // str(Fraction(num, den)), den != 0
    let g = gcd(num, den); if (den < 0n) g = -g;
    const p = num / g, q = den / g;
    return q === 1n ? String(p) : String(p) + '/' + String(q);
  }

  // ------------------------------------------------------------------ builder
  function build(inputs) {
    const c = check_inputs(inputs);
    const a = c.a, inv = c.inv, primes = c.primes;
    const invText = {};
    for (const k of Object.keys(inv)) invText[k] = String(inv[k]);
    invText.j = fractionText(inv.c4 ** 3n, inv.discriminant);
    const curve = { field: 'Q', ainvs: c.ainvs_text, invariants: invText, model_id: model_id(c.ainvs_text, invText) };

    const rows = [], loc = new Map();
    for (const p of primes) { const [row, res] = local_row(a, inv, p); rows.push(row); loc.set(p, res); }

    function coefficient(fac) {
      let value = 1n;
      for (const [p, e] of fac) {
        if (loc.get(p) === null) return null;
        const r = loc.get(p);
        value *= prime_power_coefficients(r[0], r[1], p, e)[Number(e)];
      }
      return value;
    }
    const nfac = c.fact.get(c.n);
    const pps = [], missing = [];
    for (const [p, e] of nfac) {
      const entry = { prime: String(p), exponent: String(e) };
      if (loc.get(p) === null) { entry.rule = 'UNAVAILABLE_REDUCTION_UNRESOLVED'; missing.push(String(p)); }
      else { const r = loc.get(p); entry.rule = r[0]; entry.coefficients = prime_power_coefficients(r[0], r[1], p, e).map(x => String(x)); }
      pps.push(entry);
    }
    const a_n = missing.length ? { availability: 'UNAVAILABLE', reason: 'REDUCTION_UNRESOLVED', primes: missing }
      : { availability: 'AVAILABLE', assembly: nfac.length === 0 ? 'EMPTY_PRODUCT' : 'PRODUCT_OF_PRIME_POWER_COEFFICIENTS', value: String(coefficient(nfac)) };
    const atom = { n: String(c.n), factors: nfac.map(([p, e]) => ({ prime: String(p), exponent: String(e) })), prime_powers: pps, a_n };

    const m = c.mod, origin = m.origin;
    let fixedClaim = null;
    if (origin === 'Q_PRODUCT' || origin === 'SUPPLIED_TABLE')
      fixedClaim = { weight: '2', character: 'TRIVIAL', normalization: 'A1_EQUALS_1', level: m.claim.level, label_locator: m.claim.label_locator, status: 'DECLARED_NOT_VERIFIED' };
    let modular, coeffs;
    if (origin === 'NONE') { modular = { origin: 'NONE' }; coeffs = null; }
    else if (origin === 'Q_PRODUCT') {
      coeffs = q_product_coefficients(m.factors, m.length).map(x => String(x));
      modular = { origin, factors: m.factors.map(([d, r]) => ({ d: String(d), r: String(r) })), prefix_length: String(m.length), coefficients: coeffs,
        coefficients_sha256: coefficients_sha256(coeffs), claim: fixedClaim };
    } else if (origin === 'SUPPLIED_TABLE') {
      coeffs = m.coeffs;
      modular = { origin, prefix_length: String(m.length), coefficients: coeffs, coefficients_sha256: coefficients_sha256(coeffs), origin_statement: m.statement,
        upstream: m.upstream, claim: fixedClaim };
    } else {
      coeffs = [];
      for (let idx = 1n; idx <= m.length; idx++) { const v = coefficient(factor_over(idx, primes)); coeffs.push(v === null ? 'UNAVAILABLE' : String(v)); }
      modular = { origin, prefix_length: String(m.length), coefficients: coeffs, coefficients_sha256: coefficients_sha256(coeffs) };
    }
    const lmfdbUp = origin === 'SUPPLIED_TABLE' && m.upstream.sha256 !== 'NONE';
    const registered = lmfdbUp && m.registered;
    let association;
    if (c.assoc.witness === 'NONE') association = { witness: 'NONE', status: 'NOT_ESTABLISHED' };
    else association = { witness: WITNESS_LMFDB, curve_upstream_sha256: c.assoc.curve_upstream_sha256, iso_class: c.assoc.iso_class,
      status: m.assoc_registered ? 'SOURCE_REPORTED_REQUIRES_UPSTREAM_REPLAY' : 'WITNESS_DECLARED_UNREGISTERED_SOURCE' };

    const comparisons = [], tally = { EQUAL: 0n, MISMATCH: 0n, NOT_COMPARABLE: 0n, DERIVED_NOT_A_COMPARISON: 0n };
    for (const idx of c.indices) {
      const cv = coefficient(c.fact.get(idx));
      const cs = cv === null ? { availability: 'UNAVAILABLE', reason: 'REDUCTION_UNRESOLVED' } : { availability: 'AVAILABLE', value: String(cv) };
      let ms;
      if (coeffs === null) ms = { availability: 'UNAVAILABLE', reason: 'NO_MODULAR_SOURCE' };
      else if (idx > BigInt(coeffs.length)) ms = { availability: 'UNAVAILABLE', reason: 'INDEX_BEYOND_COVERAGE' };
      else if (coeffs[Number(idx) - 1] === 'UNAVAILABLE') ms = { availability: 'UNAVAILABLE', reason: 'DERIVED_ENTRY_UNAVAILABLE' };
      else ms = { availability: 'AVAILABLE', value: coeffs[Number(idx) - 1] };
      let result;
      if (cs.availability === 'AVAILABLE' && ms.availability === 'AVAILABLE') {
        if (origin === 'DERIVED_FROM_CURVE') result = 'DERIVED_NOT_A_COMPARISON';
        else result = cs.value === ms.value ? 'EQUAL' : 'MISMATCH';
      } else result = 'NOT_COMPARABLE';
      tally[result] += 1n;
      comparisons.push({ index: String(idx), curve: cs, modular: ms, result });
    }
    const outcome = tally.MISMATCH ? 'MISMATCH_PRESENT' : tally.EQUAL ? 'ALL_COMPARED_EQUAL' : 'NOTHING_COMPARED';
    const summary = { indices: String(comparisons.length), equal: String(tally.EQUAL), mismatch: String(tally.MISMATCH), not_comparable: String(tally.NOT_COMPARABLE),
      derived: String(tally.DERIVED_NOT_A_COMPARISON), outcome };
    const mbStatus = { NONE: 'NONE', Q_PRODUCT: 'REGENERABLE_FROM_THE_DECLARED_Q_PRODUCT', DERIVED_FROM_CURVE: 'DERIVED_FROM_CURVE' }[origin]
      || (registered ? 'EMBEDDED_TABLE_REGISTERED_SOURCE_DIGEST' : lmfdbUp ? 'EMBEDDED_TABLE_UNREGISTERED_DIGEST' : 'EMBEDDED_TABLE_NO_UPSTREAM');
    const evidence = {
      source_registry_sha256: registrySha256(),
      curve_side: { status: 'EXACT_REGENERABLE_FROM_THE_MODEL', unresolved_primes: rows.filter(r => r.reduction === 'REDUCTION_UNRESOLVED').map(r => r.prime) },
      modular_bytes: { status: mbStatus },
      modular_membership: { status: (origin === 'NONE' || origin === 'DERIVED_FROM_CURVE') ? 'NOT_APPLICABLE' : registered ? 'SOURCE_REPORTED_REQUIRES_UPSTREAM_REPLAY' : 'DECLARED_NOT_VERIFIED' },
      curve_form_association: { status: (origin === 'NONE' || origin === 'DERIVED_FROM_CURVE') ? 'NOT_APPLICABLE' : association.status },
      comparison: { class: { NONE: 'NONE', Q_PRODUCT: 'ALGORITHM_NOT_USING_THE_CURVE', SUPPLIED_TABLE: 'SUPPLIED_REFERENCE_ORIGIN_DECLARED',
        DERIVED_FROM_CURVE: 'TAUTOLOGICAL_NOT_A_COMPARISON' }[origin], outcome, meaning: 'EXACT_EQUALITY_ON_THE_LISTED_INDICES_ONLY' }
    };
    const record = {
      schema: SCHEMA_NAME, schema_version: SCHEMA_VERSION, kind: KIND, scope: SCOPE, exclusions: EXCLUSIONS.slice(), method: Object.assign({}, METHOD),
      curve, atom, primes: primes.map(p => String(p)), local: rows, indices: c.indices.map(i => String(i)), modular, association, comparisons, summary, evidence
    };
    serialize(record);
    return record;
  }

  // ------------------------------------------------------------------ validator
  const TOP_KEYS = ['schema', 'schema_version', 'kind', 'scope', 'exclusions', 'method', 'curve', 'atom', 'primes', 'local', 'indices', 'modular', 'association',
    'comparisons', 'summary', 'evidence'];
  function deepEqual(x, y) {            // Python == on JSON-like values (dict, list, str, int, bool, None); type-strict and key-set-exact
    if (typeof x === 'string' || typeof y === 'string') return x === y;
    if (x === null || y === null) return x === y;
    if (typeof x === 'boolean' || typeof y === 'boolean') return x === y;
    if (typeof x === 'bigint' && typeof y === 'bigint') return x === y;
    if (Array.isArray(x) || Array.isArray(y)) {
      if (!Array.isArray(x) || !Array.isArray(y) || x.length !== y.length) return false;
      for (let i = 0; i < x.length; i++) if (!deepEqual(x[i], y[i])) return false;
      return true;
    }
    if (isDict(x) && isDict(y)) {
      if (!sameKeySet(x, Object.keys(y))) return false;
      for (const k of Object.keys(x)) if (!deepEqual(x[k], y[k])) return false;
      return true;
    }
    return false;
  }
  function _extract_inputs(r) {
    _keys(r, TOP_KEYS, 'V0', 'record');
    require_(isDict(r.curve) && isDict(r.atom) && isDict(r.modular) && isDict(r.association), 'V0', 'curve, atom, modular and association must be objects');
    const mod = r.modular, origin = get(mod, 'origin');
    let m;
    if (origin === 'NONE') m = { origin: 'NONE' };
    else if (origin === 'Q_PRODUCT') {
      require_(isDict(get(mod, 'claim')), 'V0', 'modular.claim missing');
      m = { origin, factors: get(mod, 'factors'), prefix_length: get(mod, 'prefix_length'), claim: { level: get(mod.claim, 'level'), label_locator: get(mod.claim, 'label_locator') } };
    } else if (origin === 'SUPPLIED_TABLE') {
      require_(isDict(get(mod, 'claim')), 'V0', 'modular.claim missing');
      m = { origin, coefficients: get(mod, 'coefficients'), origin_statement: get(mod, 'origin_statement'), upstream: get(mod, 'upstream'),
        claim: { level: get(mod.claim, 'level'), label_locator: get(mod.claim, 'label_locator') } };
    } else if (origin === 'DERIVED_FROM_CURVE') m = { origin, prefix_length: get(mod, 'prefix_length') };
    else throw new ContractError('V0: modular.origin: unknown value');
    const assoc = {};
    for (const k of Object.keys(r.association)) if (k !== 'status') Object.defineProperty(assoc, k, { value: r.association[k], enumerable: true, writable: true, configurable: true });
    return { ainvs: get(r.curve, 'ainvs'), atom: get(r.atom, 'n'), primes: r.primes, indices: r.indices, modular: m, association: assoc };
  }
  function _check_stated_factorization(r) {
    const fl = get(r.atom, 'factors');
    require_(Array.isArray(fl) && fl.length <= PRIMES_MAX, 'V1', 'atom.factors: malformed');
    const n = _uint(get(r.atom, 'n'), 'V0', 'atom', 1n, N_MAX);
    let prod = 1n, last = 1n;
    for (const f of fl) {
      _keys(f, ['prime', 'exponent'], 'V1', 'atom factor');
      const p = _uint(f.prime, 'V1', 'atom factor prime', 2n, P_MAX);
      const e = _uint(f.exponent, 'V1', 'atom factor exponent', 1n, 19n);
      require_(_is_prime(p), 'V1', 'atom.factors: a composite entry');
      require_(p > last, 'V1', 'atom.factors: primes strictly increasing, no duplicate');
      last = p;
      prod *= p ** e;
      require_(prod <= N_MAX, 'V1', 'atom.factors: product exceeds the atom range');
    }
    require_(prod === n, 'V1', 'atom.factors: product differs from n (missing or wrong factor)');
  }
  function validate(record) {
    try {
      require_(isDict(record), 'V0', 'record must be an object');
      const inputs = _extract_inputs(record);
      check_inputs(inputs);
      _check_stated_factorization(record);
      const regen = build(inputs);
      for (const key of ['ainvs', 'invariants', 'model_id', 'field'])
        require_(deepEqual(get(record.curve, key), regen.curve[key]), 'V2', 'curve.' + key + ' differs from the exact value');
      require_(deepEqual(record.curve, regen.curve), 'V2', 'curve block differs from the exact value');
      require_(deepEqual(record.local, regen.local), 'V3', 'local rows differ from the exact regeneration');
      require_(deepEqual(record.atom, regen.atom), 'V4', 'atom assembly differs from the exact regeneration');
      require_(deepEqual(record.modular, regen.modular), 'V5', 'modular block differs from the exact regeneration');
      for (const key of ['association', 'comparisons', 'summary', 'evidence'])
        require_(deepEqual(record[key], regen[key]), 'V6', key + ' differs from the exact regeneration');
      require_(deepEqual(record, regen), 'V7', 'record differs from the exact regeneration');
      return true;
    } catch (e) {
      if (e instanceof ContractError) throw e;
      throw new ContractError('MALFORMED: ' + (e && e.name ? e.name : 'Error'));
    }
  }
  function bytesEqual(a, b) { if (a.length !== b.length) return false; for (let i = 0; i < a.length; i++) if (a[i] !== b[i]) return false; return true; }
  function import_and_validate(raw) {
    const record = load_json_bytes(raw);
    validate(record);
    require_(bytesEqual(serialize(record), raw), 'V8', 'bytes are not the canonical serialization');
    return record;
  }
  // D6 wrapper: the record is valid on its own; the binding to (model_id, n) is the panel's.
  function validateBound(raw, binding) {
    const record = import_and_validate(raw);
    require_(binding && typeof binding.modelId === 'string' && typeof binding.n === 'string', 'BINDING', 'expected binding (modelId, n) missing');
    require_(record.curve.model_id === binding.modelId, 'BINDING', 'curve.model_id differs from the expected host modelId');
    require_(record.atom.n === binding.n, 'BINDING', 'atom.n differs from the expected atom');
    return record;
  }

  // ------------------------------------------------------------------ upstream attachments
  function load_upstream_json(raw) {
    require_(isBytes(raw), 'U', 'upstream attachment must be bytes');
    require_(raw.length <= UPSTREAM_CAP, 'U', 'upstream attachment over 1 MiB');
    require_(!(raw.length >= 3 && raw[0] === 0xef && raw[1] === 0xbb && raw[2] === 0xbf), 'U', 'upstream attachment: byte-order mark');
    const text = strictUtf8(raw);
    if (text === null) throw new ContractError('U: upstream attachment: malformed UTF-8');
    _depth_scan(raw, UPSTREAM_DEPTH_MAX, 'U');
    return parseText(text, 'U');
  }
  const _exact_int = x => x instanceof UpNum && x.kind === 'int';    // excludes booleans and float tokens, 2.0 included
  const upDict = x => isDict(x);
  function upstream_newform_row(doc, length) {
    require_(upDict(doc) && get(doc, 'table') === 'mf_newforms', 'U', 'newform record: table is not mf_newforms');
    const data = get(doc, 'data');
    require_(Array.isArray(data) && data.length === 1 && upDict(data[0]), 'U', 'newform record: not exactly one row object');
    const row = data[0];
    for (const key of ['weight', 'dim', 'char_order', 'level']) require_(_exact_int(get(row, key)), 'U', 'newform record: ' + key + ' is not an integer');
    require_(typeof get(row, 'label') === 'string', 'U', 'newform record: label is not a string');
    const rel = get(row, 'related_objects');
    require_(Array.isArray(rel) && rel.every(x => typeof x === 'string'), 'U', 'newform record: related_objects is not a list of strings');
    const tr = get(row, 'traces');
    const L = Number(length);
    require_(Array.isArray(tr) && tr.length >= L && tr.slice(0, L).every(x => _exact_int(x)), 'U', 'newform record: traces missing, too short, or not integers');
    return row;
  }
  function upstream_curve_rows(doc) {
    require_(upDict(doc) && get(doc, 'table') === 'ec_curvedata', 'U', 'curve-class record: table is not ec_curvedata');
    const data = get(doc, 'data');
    require_(Array.isArray(data) && data.length >= 1 && data.length <= UPSTREAM_CLASS_ROWS_MAX, 'U', 'curve-class record: 1 to 64 rows expected');
    for (const row of data) {
      require_(upDict(row), 'U', 'curve-class record: a row is not an object');
      const av = get(row, 'ainvs');
      require_(Array.isArray(av) && av.length === 5 && av.every(x => _exact_int(x)), 'U', 'curve-class record: ainvs is not five integers');
      require_(typeof get(row, 'lmfdb_iso') === 'string', 'U', 'curve-class record: lmfdb_iso is not a string');
      require_(_exact_int(get(row, 'conductor')), 'U', 'curve-class record: conductor is not an integer');
    }
    return data;
  }
  function _attachment(files, digest, what) {
    if (!files || !(files instanceof Map ? files.has(digest) : own(files, digest))) return null;
    const raw = files instanceof Map ? files.get(digest) : files[digest];
    require_(isBytes(raw) && raw.length <= UPSTREAM_CAP, 'U', what + ': upstream attachment over 1 MiB');
    require_(sha256Hex(raw) === digest, 'U', what + ': upstream bytes do not have the declared digest');
    return raw;
  }
  function filesNonEmpty(files) { if (!files) return false; return files instanceof Map ? files.size > 0 : Object.keys(files).length > 0; }

  // ------------------------------------------------------------------ consumer assessment
  function assess(raw, upstreamFiles = null) {
    const record = import_and_validate(raw);
    const mod = record.modular, assoc = record.association, origin = mod.origin;
    const files = filesNonEmpty(upstreamFiles) ? upstreamFiles : null;
    const dims = {
      curve_side: 'REPLAYED_EXACT',
      modular_bytes: { NONE: 'UNAVAILABLE', Q_PRODUCT: 'REPLAYED_FROM_THE_DECLARED_Q_PRODUCT', DERIVED_FROM_CURVE: 'DERIVED_FROM_CURVE' }[origin] || 'EMBEDDED_ONLY',
      modular_membership: (origin === 'NONE' || origin === 'DERIVED_FROM_CURVE') ? 'NOT_APPLICABLE' : 'DECLARED_NOT_VERIFIED',
      curve_form_association: (origin === 'NONE' || origin === 'DERIVED_FROM_CURVE') ? 'NOT_APPLICABLE' : 'NOT_ESTABLISHED',
      comparison: { class: record.evidence.comparison.class, outcome: record.summary.outcome }
    };
    let row = null, mfRegistered = false;
    if (origin === 'SUPPLIED_TABLE' && mod.upstream.sha256 !== 'NONE') {
      const digest = mod.upstream.sha256;
      const att = _attachment(files, digest, 'newform record');
      if (att !== null) {
        const length = BigInt(mod.prefix_length);
        row = upstream_newform_row(load_upstream_json(att), length);
        const tr = row.traces.slice(0, Number(length)).map(x => x.value.toString());
        require_(deepEqual(tr, mod.coefficients), 'U', 'embedded coefficients differ from the upstream traces');
        require_(row.weight.value === 2n && row.dim.value === 1n && row.char_order.value === 1n && row.level.value.toString() === mod.claim.level
          && row.label === mod.claim.label_locator, 'U', 'newform record: weight, dimension, character, level or label differs from the claim');
        mfRegistered = regGet(digest) !== undefined && regGet(digest).role === ROLE_MF;
        if (mfRegistered) { dims.modular_bytes = 'REGISTERED_SOURCE_REPLAYED'; dims.modular_membership = 'SOURCE_REPORTED'; }
        else dims.modular_bytes = 'UNREGISTERED_ATTACHMENT_REPLAYED';
      }
    }
    if (assoc.witness === WITNESS_LMFDB) {
      dims.curve_form_association = 'WITNESS_DECLARED_NOT_REPLAYED';
      const cdigest = assoc.curve_upstream_sha256;
      const att = _attachment(files, cdigest, 'curve-class record');
      if (att !== null) {
        const rows = upstream_curve_rows(load_upstream_json(att));
        const want = record.curve.ainvs.map(x => BigInt(x));
        const hit = rows.filter(r => r.ainvs.length === want.length && r.ainvs.every((v, i) => v.value === want[i]) && r.lmfdb_iso === assoc.iso_class);
        require_(hit.length === 1, 'U', 'curve-class record: this exact model is not listed in the declared class');
        const [cond, letter] = assoc.iso_class.split('.');
        require_(hit[0].conductor.value.toString() === cond, 'U', 'curve-class record: conductor differs from the class locator');
        if (row !== null) {
          require_(row.related_objects.includes('EllipticCurve/Q/' + cond + '/' + letter), 'U', 'newform record does not list the declared isogeny class');
          const ecRegistered = regGet(cdigest) !== undefined && regGet(cdigest).role === ROLE_EC;
          dims.curve_form_association = (mfRegistered && ecRegistered) ? 'SOURCE_REPORTED' : 'UNREGISTERED_ATTACHMENT_REPLAYED';
        }
      }
    }
    return { schema: 'arithmetic-fourier-assessment', schema_version: SCHEMA_VERSION, record_sha256: sha256Hex(raw), validation: 'PASS',
      trust_policy: 'AF_TRUST_POLICY_0_1_1', source_registry_sha256: registrySha256(), dimensions: dims,
      limit: 'SOURCE_REPORTED means the attachment is a snapshot listed in this package\'s source registry and ' +
        'its extraction was replayed. It is a third-party statement, not a replayed proof. An attachment ' +
        'outside the registry has no third-party standing, whatever digest a record declares.' };
  }

  // ------------------------------------------------------------------ panel-side helpers (not part of af_reference)
  const D5_PRIMES = Object.freeze((() => { const out = []; for (let p = 2n; p <= P_MAX; p++) if (_is_prime(p)) out.push(String(p)); return out; })());
  function d5Indices(nText) {          // 1..256 when n <= 256, else 1..255 plus n (strictly increasing)
    const n = BigInt(nText), out = [];
    if (n <= 256n) { for (let i = 1; i <= 256; i++) out.push(String(i)); }
    else { for (let i = 1; i <= 255; i++) out.push(String(i)); out.push(String(n)); }
    return out;
  }
  function b64decode(s) {
    if (typeof s !== 'string' || !/^[A-Za-z0-9+/]*={0,2}$/.test(s) || s.length % 4 !== 0) return null;
    const A = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    const pad = s.endsWith('==') ? 2 : s.endsWith('=') ? 1 : 0, len = s.length / 4 * 3 - pad, out = new Uint8Array(len);
    let o = 0;
    for (let i = 0; i < s.length; i += 4) {
      const v = (A.indexOf(s[i]) << 18) | (A.indexOf(s[i + 1]) << 12) | ((s[i + 2] === '=' ? 0 : A.indexOf(s[i + 2])) << 6) | (s[i + 3] === '=' ? 0 : A.indexOf(s[i + 3]));
      if (o < len) out[o++] = (v >> 16) & 255; if (o < len) out[o++] = (v >> 8) & 255; if (o < len) out[o++] = v & 255;
    }
    return out;
  }
  // D3: the data module must list exactly the five registry entries, in registry order, each decoding to bytes whose SHA-256
  // and length equal the compiled registry constants. Anything else: registry unavailable.
  function checkSourcesModule(list) {
    if (!REGISTRY_OK) return { ok: false, reason: 'registry unavailable: the embedded registry does not reproduce 0942479e…56a9' };
    if (!Array.isArray(list)) return { ok: false, reason: 'registry unavailable: data module missing' };
    if (list.length !== SOURCE_REGISTRY.entries.length) return { ok: false, reason: 'registry unavailable: ' + list.length + ' entries instead of 5' };
    const files = new Map();
    for (let i = 0; i < list.length; i++) {
      const x = list[i], e = SOURCE_REGISTRY.entries[i];
      if (!isDict(x) || x.role !== e.role || x.locator !== e.locator || x.sha256 !== e.sha256 || x.bytes !== e.bytes)
        return { ok: false, reason: 'registry unavailable: entry ' + (i + 1) + ' does not match the compiled registry' };
      const b = b64decode(x.base64);
      if (b === null) return { ok: false, reason: 'registry unavailable: entry ' + (i + 1) + ' payload is not base64' };
      if (String(b.length) !== e.bytes) return { ok: false, reason: 'registry unavailable: entry ' + (i + 1) + ' byte count differs' };
      if (sha256Hex(b) !== e.sha256) return { ok: false, reason: 'registry unavailable: entry ' + (i + 1) + ' SHA-256 differs' };
      files.set(e.sha256, b);
    }
    return { ok: true, reason: 'registry available: 5 snapshots, digests and byte counts equal the compiled registry', files };
  }
  const TABLES = Object.freeze({
    '32.2.a.a': { newform: '240d874a54a56e68295d9ede98c8ca67f819fb19a26495ea75c6417cb2f0391c', iso: '32.a', classListing: '5cf5ba4e4f52123d488c1cacc505b953c137d64076b466d17d8886f51355035e' },
    '37.2.a.a': { newform: 'c9e065fad170bdfcf0299b33ff77ee16afaa6c7d266e9cbdb1192efa474cded1', iso: '37.a', classListing: '73cf59c902240ed2b8f767ed47b84e03b2344a601ed04977851f28991e5fbead' }
  });
  const PRESETS = Object.freeze({
    QP32: { factors: [{ d: '4', r: '2' }, { d: '8', r: '2' }], level: '32', label: 'NONE' },
    QP11: { factors: [{ d: '1', r: '2' }, { d: '11', r: '2' }], level: '11', label: 'NONE' }
  });
  const ATOM_RE = /^[1-9][0-9]{0,6}$/, L_RE = /^[1-9][0-9]{0,2}$/;
  function deepFreeze(x) { if (x && typeof x === 'object') { for (const k of Object.keys(x)) deepFreeze(x[k]); Object.freeze(x); } return x; }
  // H2: one place builds the job input from the control state. Returns {ok:true, jobInput, inputDigest} or {ok:false, reason}.
  // ctl = {binding:{modelId,ainvs,hostEpoch,hostContextId}, atom, origin, prefix, preset, factors:[{d,r}], level, label, table, witness}
  // sources = Map(sha256 -> bytes) from checkSourcesModule, or null when the registry is unavailable.
  function makeJobInput(ctl, sources) {
    const fail = reason => ({ ok: false, reason });
    if (!ctl || !ctl.binding) return fail('HOST_PENDING: no exact curve binding');
    const b = ctl.binding;
    if (typeof ctl.atom !== 'string' || !ATOM_RE.test(ctl.atom) || BigInt(ctl.atom) > N_MAX) return fail('INPUT: atom n must be a canonical decimal 1..1000000');
    const origin = ctl.origin;
    let modular, preset = 'NONE', registeredSource = 'NONE', association = { witness: 'NONE' };
    const attachments = [];
    const needL = () => (typeof ctl.prefix === 'string' && L_RE.test(ctl.prefix) && BigInt(ctl.prefix) <= PREFIX_MAX) ? ctl.prefix : null;
    if (origin === 'NONE') modular = { origin };
    else if (origin === 'DERIVED_FROM_CURVE') { const L = needL(); if (!L) return fail('INPUT: prefix length L must be 1..256'); modular = { origin, prefix_length: L }; }
    else if (origin === 'Q_PRODUCT') {
      const L = needL(); if (!L) return fail('INPUT: prefix length L must be 1..256');
      if (!Array.isArray(ctl.factors) || !ctl.factors.every(f => f && typeof f.d === 'string' && typeof f.r === 'string')) return fail('INPUT: factors');
      preset = (typeof ctl.preset === 'string' && ctl.preset) ? ctl.preset : 'CUSTOM';
      modular = { origin, factors: ctl.factors.map(f => ({ d: f.d, r: f.r })), prefix_length: L, claim: { level: String(ctl.level), label_locator: String(ctl.label) } };
    } else if (origin === 'SUPPLIED_TABLE') {
      const L = needL(); if (!L) return fail('INPUT: prefix length L must be 1..256');
      if (!sources) return fail('REGISTRY_UNAVAILABLE: registered tables and witnesses are refused while the registry is unavailable');
      const t = TABLES[ctl.table];
      if (!t) return fail('INPUT: unknown registered table');
      let row;
      try { row = upstream_newform_row(load_upstream_json(sources.get(t.newform)), BigInt(L)); }
      catch (e) { return fail('U: ' + String(e.message).replace(/^U: /, '')); }
      const coeffs = row.traces.slice(0, Number(L)).map(x => x.value.toString());
      modular = { origin, coefficients: coeffs,
        origin_statement: 'LMFDB API mf_newforms record ' + row.label + ', field traces, first ' + L + ' entries; generation method as documented by LMFDB, not pinned here',
        upstream: { sha256: t.newform, extraction: EXTRACTION_MF }, claim: { level: row.level.value.toString(), label_locator: row.label } };
      registeredSource = t.newform;
      attachments.push(t.newform);
      if (ctl.witness) { association = { witness: WITNESS_LMFDB, curve_upstream_sha256: t.classListing, iso_class: t.iso }; attachments.push(t.classListing); }
    } else return fail('INPUT: unknown origin');
    attachments.sort();
    const jobInput = {
      schema: 'MCOMB_AF_JOB_INPUT_V1',
      binding: { modelId: b.modelId, ainvs: b.ainvs.slice(), hostEpoch: String(b.hostEpoch), hostContextId: String(b.hostContextId) },
      inputs: { ainvs: b.ainvs.slice(), atom: ctl.atom, primes: D5_PRIMES.slice(), indices: d5Indices(ctl.atom), modular, association },
      selection: { preset, registeredSource },
      assessment: { attachments }
    };
    try { check_inputs(jobInput.inputs, true); }            // the port's own V0, unchanged; INVALID_INPUT carries its code
    catch (e) { if (e instanceof ContractError) return fail(e.message); return fail('MALFORMED: ' + e.name); }
    deepFreeze(jobInput);
    return { ok: true, jobInput, inputDigest: inputDigest(jobInput) };
  }
  const inputDigest = jobInput => sha256Hex(asciiBytes(canonical(jobInput)));

  const api = {
    ContractError, codeOf, floorDiv, floorMod, gcd, sha256Hex, asciiBytes, utf8Bytes, cpLength, cpCompare, pyDumps, canonical, isBytes, bytesEqual,
    SCHEMA_NAME, SCHEMA_VERSION, KIND, SCOPE, EXCLUSIONS, METHOD, SOURCE_REGISTRY, REGISTRY_SHA256_EXPECTED, REGISTRY_OK, registryBytes, registrySha256,
    serialize, load_json_bytes, curve_invariants, model_id, _vp, scaling_exponent, count_points, local_row, prime_power_coefficients, factor_over,
    q_product_coefficients, coefficients_sha256, check_inputs, build, validate, import_and_validate, validateBound, load_upstream_json,
    upstream_newform_row, upstream_curve_rows, assess, UpNum, deepEqual,
    D5_PRIMES, d5Indices, b64decode, checkSourcesModule, TABLES, PRESETS, makeJobInput, inputDigest, EXTRACTION_MF, WITNESS_LMFDB
  };
  root.McombArithmeticFourierCoreV1 = Object.freeze(api);
  if (typeof module === 'object' && module && module.exports) module.exports = api;
})(typeof globalThis !== 'undefined' ? globalThis : this);
