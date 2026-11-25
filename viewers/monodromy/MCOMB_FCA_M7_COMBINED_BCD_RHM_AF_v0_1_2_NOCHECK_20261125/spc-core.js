/* Shell prime-count panel v0.1 — core (worker C, Claude). Pure functions shared by the page, the counting Web Worker and Node tests.
 *
 * Governing spec: SHELL_PRIME_COUNT_PANEL_SPEC_v0_1_2_20260929/PANEL_SPEC.md (schema 0.1.2, Astra PASS). Idea: saphir.
 * Notation SHELL_PRIME_COUNT_NOTATION_V1: prime count pi(B) = primeCountUpTo, prime divisor set = primeDivisorSet,
 * distinct prime divisors omega(B) = distinctPrimeDivisorCount, Euler totient phi(B) = eulerTotient,
 * coprime composites C_B = coprimeCompositeCount, prime share of reduced residues Y_B = residuePrimeShare.
 * No bare-Greek identifier is introduced; the host spin s and the Basel exponent are never used here.
 *
 * Exactness (spec section 7.3): every semantic integer and rational check below runs in BigInt, on strings that have
 * already passed the structural (ECMA-262) patterns and the length bound. Fractions are compared as canonical reduced
 * strings; nothing is cross-multiplied in Number. Route replays (S3/S5/S7) are supplied by the caller as BigInt
 * functions (the worker's LUCY_HEDGEHOG_V1 and SEGMENTED_SIEVE_V1 routes).
 *
 * Import boundary: byte cap, UTF-8 without BOM (fatal decoding), duplicate keys rejected, every numeric token rejected
 * (the schema has none), NaN/Infinity rejected. Export serializer: Python json.dumps(obj, separators=(",", ":"),
 * ensure_ascii=True) plus LF, reproduced exactly (ensureAsciiJson).
 *
 * Source rule for this file: no regex literals and no bitwise operators (patterns are built from strings).
 */
(function (root, factory) {
  'use strict';
  const api = factory();
  if (typeof module === 'object' && module.exports) module.exports = api;
  else root.McombShellPrimeCountCoreV1 = api;
}(typeof self !== 'undefined' ? self : this, function () {
  'use strict';
  const SCHEMA_TEXT = "{\"$schema\":\"https://json-schema.org/draft/2020-12/schema\",\"$id\":\"urn:robin:fourier:shell-prime-count:readout:0.1.2\",\"title\":\"Shell prime-count readout v0.1.2\",\"description\":\"Exported readout of the shell prime-count panel. Notation per NOTATION_NOTE.md (SHELL_PRIME_COUNT_NOTATION_V1): prime_count = pi(B), prime_divisor_set = P(B), distinct_prime_divisor_count = omega(B), euler_totient = phi(B), coprime_composite_count = C_B, residue_prime_share = Y_B. Patterns use ECMA-262 semantics ($ = end of input). Integer strings are canonical decimals of at most 11 digits; coefficients are the host's canonical reduced rational text. Structural validation must be followed by the semantic checks S0-S13 of PANEL_SPEC.md, using exact (BigInt) arithmetic.\",\"type\":\"object\",\"additionalProperties\":false,\"required\":[\"schema_version\",\"kind\",\"convention\",\"source\",\"shell\",\"exact\",\"neighbour\",\"asymptotic\",\"rosette\"],\"properties\":{\"schema_version\":{\"const\":\"0.1.2\"},\"kind\":{\"const\":\"shell_prime_count_readout\"},\"convention\":{\"const\":\"SHELL_PRIME_COUNT_NOTATION_V1\"},\"source\":{\"$ref\":\"#/$defs/source\"},\"shell\":{\"$ref\":\"#/$defs/shell\"},\"exact\":{\"$ref\":\"#/$defs/exact\"},\"neighbour\":{\"$ref\":\"#/$defs/neighbour\"},\"asymptotic\":{\"anyOf\":[{\"type\":\"null\"},{\"$ref\":\"#/$defs/asymptotic\"}]},\"rosette\":{\"$ref\":\"#/$defs/rosette\"}},\"allOf\":[{\"if\":{\"properties\":{\"shell\":{\"properties\":{\"mode\":{\"const\":\"factorial\"}}}}},\"then\":{\"properties\":{\"asymptotic\":{\"$ref\":\"#/$defs/asymptotic\"}}},\"else\":{\"properties\":{\"asymptotic\":{\"type\":\"null\"}}}}],\"$defs\":{\"uint\":{\"type\":\"string\",\"minLength\":1,\"maxLength\":11,\"pattern\":\"^(0|[1-9][0-9]*)$\"},\"positive\":{\"type\":\"string\",\"minLength\":1,\"maxLength\":11,\"pattern\":\"^[1-9][0-9]*$\"},\"rational\":{\"type\":\"object\",\"additionalProperties\":false,\"required\":[\"numerator\",\"denominator\"],\"properties\":{\"numerator\":{\"$ref\":\"#/$defs/uint\"},\"denominator\":{\"$ref\":\"#/$defs/positive\"}}},\"source\":{\"type\":\"object\",\"additionalProperties\":false,\"required\":[\"host_build\",\"host_sha256\"],\"properties\":{\"host_build\":{\"type\":\"string\",\"minLength\":1,\"maxLength\":256},\"host_sha256\":{\"type\":\"string\",\"minLength\":64,\"maxLength\":64,\"pattern\":\"^[0-9a-f]{64}$\"}}},\"shell\":{\"type\":\"object\",\"additionalProperties\":false,\"required\":[\"mode\",\"factorial_index\",\"base_B\"],\"properties\":{\"mode\":{\"enum\":[\"factorial\",\"direct\"]},\"factorial_index\":{\"anyOf\":[{\"type\":\"null\"},{\"enum\":[\"3\",\"4\",\"5\",\"6\",\"7\",\"8\",\"9\",\"10\",\"11\",\"12\",\"13\"]}]},\"base_B\":{\"$ref\":\"#/$defs/positive\"}},\"allOf\":[{\"if\":{\"properties\":{\"mode\":{\"const\":\"factorial\"}}},\"then\":{\"properties\":{\"factorial_index\":{\"type\":\"string\"}}},\"else\":{\"properties\":{\"factorial_index\":{\"type\":\"null\"}}}}]},\"exact\":{\"type\":\"object\",\"additionalProperties\":false,\"required\":[\"prime_count\",\"prime_count_route\",\"cross_check\",\"prime_divisor_set\",\"distinct_prime_divisor_count\",\"euler_totient\",\"coprime_composite_count\",\"coprime_composite_status\",\"residue_prime_share\"],\"properties\":{\"prime_count\":{\"$ref\":\"#/$defs/uint\"},\"prime_count_route\":{\"const\":\"LUCY_HEDGEHOG_V1\"},\"cross_check\":{\"enum\":[\"SEGMENTED_SIEVE_AGREES\",\"NOT_RUN_ABOVE_LIMIT\"]},\"prime_divisor_set\":{\"type\":\"array\",\"minItems\":1,\"maxItems\":16,\"items\":{\"$ref\":\"#/$defs/positive\"}},\"distinct_prime_divisor_count\":{\"$ref\":\"#/$defs/positive\"},\"euler_totient\":{\"$ref\":\"#/$defs/positive\"},\"coprime_composite_count\":{\"$ref\":\"#/$defs/uint\"},\"coprime_composite_status\":{\"enum\":[\"DIRECT_COUNTED\",\"DERIVED_FROM_PRIME_COUNT\"]},\"residue_prime_share\":{\"$ref\":\"#/$defs/rational\"}}},\"neighbour\":{\"type\":\"object\",\"additionalProperties\":false,\"required\":[\"upper\",\"upper_is_prime\",\"prime_count_upper\"],\"properties\":{\"upper\":{\"$ref\":\"#/$defs/positive\"},\"upper_is_prime\":{\"type\":\"boolean\"},\"prime_count_upper\":{\"$ref\":\"#/$defs/uint\"}}},\"asymptotic\":{\"type\":\"object\",\"additionalProperties\":false,\"required\":[\"family\",\"statement\",\"scaled_share\",\"accuracy_claim\"],\"properties\":{\"family\":{\"const\":\"FACTORIAL\"},\"statement\":{\"const\":\"n*Y -> e^gamma\"},\"scaled_share\":{\"$ref\":\"#/$defs/rational\"},\"accuracy_claim\":{\"const\":\"NONE\"}}},\"rosette\":{\"type\":\"object\",\"additionalProperties\":false,\"required\":[\"reference\",\"host_t1\",\"host_t2\",\"amplitude_nonzero\",\"conditions_met\",\"prime_column_count\",\"basis\"],\"properties\":{\"reference\":{\"const\":\"T1_T2_1_NONZERO_AMPLITUDE_BOTH_RAYS\"},\"host_t1\":{\"$ref\":\"#/$defs/coefficient\"},\"host_t2\":{\"$ref\":\"#/$defs/coefficient\"},\"amplitude_nonzero\":{\"type\":\"boolean\"},\"conditions_met\":{\"type\":\"boolean\"},\"prime_column_count\":{\"anyOf\":[{\"type\":\"null\"},{\"$ref\":\"#/$defs/uint\"}]},\"basis\":{\"const\":\"STATED_FROM_DIVISOR_CONTACT_RULE_NOT_SWEPT\"}},\"allOf\":[{\"if\":{\"properties\":{\"conditions_met\":{\"const\":true}}},\"then\":{\"properties\":{\"prime_column_count\":{\"$ref\":\"#/$defs/uint\"}}},\"else\":{\"properties\":{\"prime_column_count\":{\"type\":\"null\"}}}}]},\"coefficient\":{\"type\":\"string\",\"minLength\":1,\"maxLength\":34,\"description\":\"Host canonical text: signedRationalText of the reduced pair from parseGearboxRational; integer or a/b with b>1, gcd 1, no leading zeros, no plus sign, no -0; at most 34 characters (sign, 16-digit numerator, slash, 16-digit denominator). S13 adds |numerator| <= 9007199254740991, 1 <= denominator <= 9007199254740991 and |value| <= 100.\",\"pattern\":\"^(0|-?[1-9][0-9]*(/[1-9][0-9]*)?)$\"}}}";
  const SCHEMA = JSON.parse(SCHEMA_TEXT);
  const SCHEMA_VERSION = '0.1.2';
  const DIRECT_COUNT_LIMIT = 39916800n;            // 11!: route B and the direct C_B count run at or below this
  const BASE_MAX = 6227020800n;                     // 13! = host DIRECT_SHELL_MAX
  const BASE_MIN = 2n;
  const INTEGER_FIELD_MAX = 13n * BASE_MAX;         // S0: largest value any integer field may hold
  const COEFFICIENT_BOUND = 100n;                   // host T_MIN..T_MAX
  const COEFFICIENT_COMPONENT_MAX = 9007199254740991n;  // 2^53 - 1, host parser component bound (S13, 0.1.2)
  const BYTE_CAP = 65536;                           // import byte cap (every valid packet is below 2 KiB)
  const PLACEHOLDER_BUILD = 'SPEC_EXAMPLE_NO_HOST';

  /* ---------------- structural validator (JSON Schema 2020-12 subset, ECMA-262 patterns) ----------------
   * A line-for-line port of the accepted checker's validate(); JavaScript RegExp without the m flag already gives
   * the ECMA-262 meaning of '$' (end of input only). Lengths count code points, as JSON Schema requires. */
  const patternCache = new Map();
  const pattern = p => { if (!patternCache.has(p)) patternCache.set(p, new RegExp(p, 'u')); return patternCache.get(p); };
  const typeOk = (inst, t) => t === 'object' ? inst !== null && typeof inst === 'object' && !Array.isArray(inst)
    : t === 'array' ? Array.isArray(inst) : t === 'string' ? typeof inst === 'string' : t === 'boolean' ? typeof inst === 'boolean'
    : t === 'null' ? inst === null : false;
  const codePoints = s => Array.from(s).length;
  const own = (o, k) => Object.prototype.hasOwnProperty.call(o, k);
  function resolve(ref) {
    let node = SCHEMA;
    for (const part of ref.replace('#/', '').split('/')) node = node[part];
    return node;
  }
  const same = (a, b) => canonicalJson(a) === canonicalJson(b);
  function validate(inst, sch, path) {
    path = path || '$';
    let errs = [];
    if (own(sch, '$ref')) errs = errs.concat(validate(inst, resolve(sch.$ref), path));
    if (own(sch, 'type') && !typeOk(inst, sch.type)) return errs.concat([path + ': type ' + sch.type]);
    if (own(sch, 'const') && !same(inst, sch.const)) errs.push(path + ': const');
    if (own(sch, 'enum') && !sch.enum.some(v => same(inst, v))) errs.push(path + ': enum');
    if (typeof inst === 'string') {
      if (own(sch, 'pattern') && !pattern(sch.pattern).test(inst)) errs.push(path + ': pattern');
      if (codePoints(inst) < (sch.minLength || 0)) errs.push(path + ': minLength');
      if (own(sch, 'maxLength') && codePoints(inst) > sch.maxLength) errs.push(path + ': maxLength');
    }
    if (typeOk(inst, 'object')) {
      for (const k of sch.required || []) if (!own(inst, k)) errs.push(path + ': missing ' + k);
      const props = sch.properties || {};
      for (const k of Object.keys(inst)) {
        if (own(props, k)) errs = errs.concat(validate(inst[k], props[k], path + '.' + k));
        else if (sch.additionalProperties === false) errs.push(path + ': extra ' + k);
      }
    }
    if (Array.isArray(inst)) {
      if (inst.length < (sch.minItems || 0)) errs.push(path + ': minItems');
      if (own(sch, 'maxItems') && inst.length > sch.maxItems) errs.push(path + ': maxItems');
      if (own(sch, 'items')) inst.forEach((v, i) => { errs = errs.concat(validate(v, sch.items, path + '[' + i + ']')); });
    }
    if (own(sch, 'anyOf') && !sch.anyOf.some(s => validate(inst, s, path).length === 0)) errs.push(path + ': anyOf');
    for (const s of sch.allOf || []) {
      if (own(s, 'if')) {
        const branch = validate(inst, s.if, path).length === 0 ? s.then : s.else;
        if (branch) errs = errs.concat(validate(inst, branch, path));
      } else errs = errs.concat(validate(inst, s, path));
    }
    return errs;
  }
  const structureErrors = pkt => validate(pkt, SCHEMA, '$');

  /* ---------------- exact BigInt arithmetic for the semantic checks ---------------- */
  const big = s => BigInt(s);                        // called only on strings that passed the uint/positive patterns
  const absBig = x => (x < 0n ? -x : x);
  function gcdBig(a, b) { a = absBig(a); b = absBig(b); while (b !== 0n) { const t = a % b; a = b; b = t; } return a; }
  function factorialBig(n) { let f = 1n; for (let i = 2n; i <= n; i += 1n) f *= i; return f; }
  function primeDivisorSetBig(B) {                   // trial division; B <= 13! so at most ~39,500 odd trial divisors
    const out = []; let m = B, p = 2n;
    while (p * p <= m) {
      if (m % p === 0n) { out.push(p); while (m % p === 0n) m /= p; }
      p += (p === 2n ? 1n : 2n);
    }
    if (m > 1n) out.push(m);
    return out;
  }
  function eulerTotientBig(B) { let t = B; for (const p of primeDivisorSetBig(B)) t = t / p * (p - 1n); return t; }
  function modPowBig(base, exponent, modulus) {
    let result = 1n, b = base % modulus, e = exponent;
    while (e > 0n) { if (e % 2n === 1n) result = result * b % modulus; b = b * b % modulus; e /= 2n; }
    return result;
  }
  const MR_BASES = [2n, 3n, 5n, 7n, 11n, 13n, 17n, 19n, 23n, 29n, 31n, 37n, 41n];
  function isPrimeBig(n) {                           // deterministic Miller-Rabin, same base set as the Python reference
    if (n < 2n) return false;
    for (const p of MR_BASES) if (n % p === 0n) return n === p;
    let d = n - 1n, s = 0;
    while (d % 2n === 0n) { d /= 2n; s += 1; }
    outer: for (const a of MR_BASES) {
      let x = modPowBig(a, d, n);
      if (x === 1n || x === n - 1n) continue;
      for (let i = 0; i < s - 1; i++) { x = x * x % n; if (x === n - 1n) continue outer; }
      return false;
    }
    return true;
  }
  function canonicalFraction(num, den) {             // reduced {numerator, denominator} as canonical decimal strings
    const g = gcdBig(num, den);
    return { numerator: (num / g).toString(), denominator: (den / g).toString() };
  }
  const sameFraction = (field, want) => field.numerator === want.numerator && field.denominator === want.denominator;

  /* host canonical coefficient text -> [numerator, denominator] (BigInt), or null (S13) */
  function parseCoefficient(text) {
    let num, den;
    const slash = text.indexOf('/');
    if (slash >= 0) {
      num = BigInt(text.slice(0, slash)); den = BigInt(text.slice(slash + 1));
      if (den === 1n || gcdBig(num, den) !== 1n) return null;
    } else { num = BigInt(text); den = 1n; }
    if (absBig(num) > COEFFICIENT_COMPONENT_MAX || den < 1n || den > COEFFICIENT_COMPONENT_MAX) return null;
    if (absBig(num) > COEFFICIENT_BOUND * den) return null;
    return [num, den];
  }

  function integerFields(pkt) {
    const ex = pkt.exact, nb = pkt.neighbour, asy = pkt.asymptotic, ro = pkt.rosette;
    const vals = [pkt.shell.base_B, ex.prime_count, ex.distinct_prime_divisor_count, ex.euler_totient, ex.coprime_composite_count,
      ex.residue_prime_share.numerator, ex.residue_prime_share.denominator, nb.upper, nb.prime_count_upper].concat(ex.prime_divisor_set);
    if (asy !== null) vals.push(asy.scaled_share.numerator, asy.scaled_share.denominator);
    if (ro.prime_column_count !== null) vals.push(ro.prime_column_count);
    return vals;
  }

  /* S0-S11 and S13 in the accepted checker's order; returns the id of the first failing check, or null.
   * routes: { lucy(B: bigint) -> bigint, segmented(B) -> bigint, directC(B) -> bigint }. Requires structure to have passed. */
  function semantic(pkt, routes) {
    if (integerFields(pkt).some(v => big(v) > INTEGER_FIELD_MAX)) return 'S0';
    const sh = pkt.shell, ex = pkt.exact, nb = pkt.neighbour, asy = pkt.asymptotic, ro = pkt.rosette;
    const B = big(sh.base_B);
    if (B < BASE_MIN || B > BASE_MAX) return 'S1';
    if (sh.mode === 'factorial' && B !== factorialBig(big(sh.factorial_index))) return 'S1';
    const P = ex.prime_divisor_set.map(big), want = primeDivisorSetBig(B);
    if (P.length !== want.length || P.some((p, i) => p !== want[i])) return 'S2';
    const omega = big(ex.distinct_prime_divisor_count);
    if (omega !== BigInt(P.length)) return 'S3';
    if (sh.mode === 'factorial' && omega !== routes.lucy(big(sh.factorial_index))) return 'S3';
    const phi = big(ex.euler_totient);
    if (phi !== eulerTotientBig(B)) return 'S4';
    const pc = big(ex.prime_count);
    if (pc !== routes.lucy(B)) return 'S5';
    const C = big(ex.coprime_composite_count);
    if (pc !== omega + phi - 1n - C) return 'S6';
    if (B <= DIRECT_COUNT_LIMIT) {
      if (ex.cross_check !== 'SEGMENTED_SIEVE_AGREES' || ex.coprime_composite_status !== 'DIRECT_COUNTED') return 'S7';
      if (routes.segmented(B) !== pc) return 'S7';
      if (routes.directC(B) !== C) return 'S7';
    } else if (ex.cross_check !== 'NOT_RUN_ABOVE_LIMIT' || ex.coprime_composite_status !== 'DERIVED_FROM_PRIME_COUNT') return 'S7';
    if (!sameFraction(ex.residue_prime_share, canonicalFraction(pc - omega, phi))) return 'S8';
    if (big(nb.upper) !== B + 1n || nb.upper_is_prime !== isPrimeBig(B + 1n)) return 'S9';
    if (big(nb.prime_count_upper) !== pc + (nb.upper_is_prime ? 1n : 0n)) return 'S9';
    if ((asy === null) !== (sh.mode === 'direct')) return 'S10';
    if (asy !== null && !sameFraction(asy.scaled_share, canonicalFraction(big(sh.factorial_index) * (pc - omega), phi))) return 'S10';
    const t1 = parseCoefficient(ro.host_t1), t2 = parseCoefficient(ro.host_t2);
    if (t1 === null || t2 === null) return 'S13';
    const met = t1[0] === 1n && t1[1] === 1n && t2[0] === 1n && t2[1] === 1n && ro.amplitude_nonzero;
    if (ro.conditions_met !== met) return 'S11';
    if (met && big(ro.prime_column_count) !== pc) return 'S11';
    return null;
  }
  const checkPacket = (pkt, routes) => (structureErrors(pkt).length ? 'STRUCTURE' : semantic(pkt, routes));

  /* S12 (runtime only): the packet's source must be the running build, compared with the page's own build pins. */
  function bindLiveSource(pkt, pins) {
    if (!pins || typeof pins.hostSha256 !== 'string' || typeof pins.hostBuild !== 'string') return 'S12';
    if (pkt.source.host_sha256 !== pins.hostSha256 || pkt.source.host_build !== pins.hostBuild) return 'S12';
    return null;
  }

  /* ---------------- strict JSON import boundary ---------------- */
  function parseStrict(bytes) {
    if (!(bytes instanceof Uint8Array)) throw Error('IMPORT_BYTES: bytes required');
    if (bytes.length > BYTE_CAP) throw Error('IMPORT_BYTE_CAP: ' + bytes.length + ' bytes > ' + BYTE_CAP);
    if (bytes.length >= 3 && bytes[0] === 0xEF && bytes[1] === 0xBB && bytes[2] === 0xBF) throw Error('IMPORT_BOM: UTF-8 byte-order mark rejected');
    let text;
    try { text = new TextDecoder('utf-8', { fatal: true, ignoreBOM: true }).decode(bytes); } catch (e) { throw Error('IMPORT_UTF8: invalid UTF-8'); }
    let i = 0;
    const fail = msg => { throw Error('IMPORT_JSON: ' + msg + ' at offset ' + i); };
    const ws = () => { while (i < text.length && (text[i] === ' ' || text[i] === '\t' || text[i] === '\n' || text[i] === '\r')) i++; };
    const HEX = '0123456789abcdefABCDEF';
    function str() {
      i++; let out = '';
      for (;;) {
        if (i >= text.length) fail('unterminated string');
        const c = text[i], code = text.charCodeAt(i);
        if (c === '"') { i++; return out; }
        if (code < 0x20) fail('control character in string');
        if (c === '\\') {
          const e = text[i + 1];
          const simple = { '"': '"', '\\': '\\', '/': '/', b: '\b', f: '\f', n: '\n', r: '\r', t: '\t' };
          if (own(simple, e)) { out += simple[e]; i += 2; continue; }
          if (e === 'u') {
            const h = text.slice(i + 2, i + 6);
            if (h.length !== 4 || Array.from(h).some(x => HEX.indexOf(x) < 0)) fail('bad unicode escape');
            out += String.fromCharCode(parseInt(h, 16)); i += 6; continue;
          }
          fail('bad escape');
        }
        out += c; i++;
      }
    }
    function value(depth) {
      if (depth > 16) fail('nesting too deep');
      ws();
      const c = text[i];
      if (c === '{') {
        i++; const obj = {}; ws();
        if (text[i] === '}') { i++; return obj; }
        for (;;) {
          ws(); if (text[i] !== '"') fail('object key must be a string');
          const k = str();
          if (own(obj, k)) fail('duplicate key "' + k + '"');
          ws(); if (text[i] !== ':') fail('expected colon'); i++;
          Object.defineProperty(obj, k, { value: value(depth + 1), enumerable: true, writable: true, configurable: true });
          ws(); if (text[i] === ',') { i++; continue; } if (text[i] === '}') { i++; return obj; } fail('expected , or }');
        }
      }
      if (c === '[') {
        i++; const arr = []; ws();
        if (text[i] === ']') { i++; return arr; }
        for (;;) { arr.push(value(depth + 1)); ws(); if (text[i] === ',') { i++; continue; } if (text[i] === ']') { i++; return arr; } fail('expected , or ]'); }
      }
      if (c === '"') return str();
      if (text.startsWith('true', i)) { i += 4; return true; }
      if (text.startsWith('false', i)) { i += 5; return false; }
      if (text.startsWith('null', i)) { i += 4; return null; }
      if (c === '-' || (c >= '0' && c <= '9')) fail('numeric token rejected (every integer is a canonical string)');
      if (text.startsWith('NaN', i) || text.startsWith('Infinity', i)) fail('NaN/Infinity rejected');
      fail('unexpected token');
    }
    const out = value(0); ws();
    if (i !== text.length) fail('trailing content');
    return out;
  }

  /* ---------------- serializers ---------------- */
  function canonicalJson(x) {                        // sorted-key compact JSON (identity objects, comparisons)
    if (x === null || typeof x !== 'object') return JSON.stringify(x);
    if (Array.isArray(x)) return '[' + x.map(canonicalJson).join(',') + ']';
    return '{' + Object.keys(x).sort().map(k => JSON.stringify(k) + ':' + canonicalJson(x[k])).join(',') + '}';
  }
  const HEXL = '0123456789abcdef';
  function asciiString(s) {                          // Python json.dumps(ensure_ascii=True) string encoding
    let out = '"';
    for (let k = 0; k < s.length; k++) {
      const c = s.charCodeAt(k), ch = s[k];
      if (ch === '"') out += '\\"'; else if (ch === '\\') out += '\\\\';
      else if (ch === '\n') out += '\\n'; else if (ch === '\r') out += '\\r'; else if (ch === '\t') out += '\\t';
      else if (ch === '\b') out += '\\b'; else if (ch === '\f') out += '\\f';
      else if (c < 0x20 || c > 0x7E) out += '\\u' + HEXL[Math.floor(c / 4096)] + HEXL[Math.floor(c / 256) % 16] + HEXL[Math.floor(c / 16) % 16] + HEXL[c % 16];
      else out += ch;
    }
    return out + '"';
  }
  function ensureAsciiJson(x) {                      // json.dumps(x, separators=(",", ":"), ensure_ascii=True); insertion order kept
    if (x === null) return 'null';
    if (x === true) return 'true';
    if (x === false) return 'false';
    if (typeof x === 'string') return asciiString(x);
    if (Array.isArray(x)) return '[' + x.map(ensureAsciiJson).join(',') + ']';
    if (typeof x === 'object') return '{' + Object.keys(x).map(k => asciiString(k) + ':' + ensureAsciiJson(x[k])).join(',') + '}';
    throw Error('export serializer: unsupported value ' + typeof x);
  }
  const exportText = pkt => ensureAsciiJson(pkt) + '\n';
  const fixtureText = doc => JSON.stringify(doc, null, 2) + '\n';   // json.dump(indent=2) + LF for ASCII data (fixture parity only)

  /* ---------------- packet builder (key order = the accepted checker's packet_from_row) ---------------- */
  function buildPacket(opts) {
    const r = opts.result, sh = opts.shell, ro = opts.rosette;
    const factorial = sh.mode === 'factorial';
    const met = ro.t1 === '1' && ro.t2 === '1' && ro.amplitudeNonzero === true;
    return {
      schema_version: SCHEMA_VERSION, kind: 'shell_prime_count_readout', convention: 'SHELL_PRIME_COUNT_NOTATION_V1',
      source: { host_build: opts.source.host_build, host_sha256: opts.source.host_sha256 },
      shell: { mode: sh.mode, factorial_index: factorial ? String(sh.n1) : null, base_B: String(sh.B) },
      exact: { prime_count: r.primeCount, prime_count_route: 'LUCY_HEDGEHOG_V1', cross_check: r.crossCheck,
        prime_divisor_set: r.primeDivisorSet.slice(), distinct_prime_divisor_count: r.distinctPrimeDivisorCount,
        euler_totient: r.eulerTotient, coprime_composite_count: r.coprimeCompositeCount, coprime_composite_status: r.coprimeCompositeStatus,
        residue_prime_share: { numerator: r.residuePrimeShare.numerator, denominator: r.residuePrimeShare.denominator } },
      neighbour: { upper: r.upper, upper_is_prime: r.upperIsPrime, prime_count_upper: r.primeCountUpper },
      asymptotic: factorial ? { family: 'FACTORIAL', statement: 'n*Y -> e^gamma', accuracy_claim: 'NONE',
        scaled_share: { numerator: r.scaledShare.numerator, denominator: r.scaledShare.denominator } } : null,
      rosette: { reference: 'T1_T2_1_NONZERO_AMPLITUDE_BOTH_RAYS', host_t1: ro.t1, host_t2: ro.t2, amplitude_nonzero: ro.amplitudeNonzero,
        conditions_met: met, prime_column_count: met ? r.primeCount : null, basis: 'STATED_FROM_DIVISOR_CONTACT_RULE_NOT_SWEPT' }
    };
  }
  /* fixture row (key order = pin_fixtures_once.row) from a worker result */
  function fixtureRow(mode, n1, result) {
    return { mode, factorial_index: mode === 'factorial' ? String(n1) : null, base_B: result.base, prime_count: result.primeCount,
      prime_divisor_set: result.primeDivisorSet.slice(), distinct_prime_divisor_count: result.distinctPrimeDivisorCount,
      euler_totient: result.eulerTotient, coprime_composite_count: result.coprimeCompositeCount,
      residue_prime_share: { numerator: result.residuePrimeShare.numerator, denominator: result.residuePrimeShare.denominator },
      upper_is_prime: result.upperIsPrime, prime_count_upper: result.primeCountUpper };
  }

  /* raw bytes -> { verdict: null | 'IMPORT' | 'STRUCTURE' | 'S0'..'S13', detail, packet } (S12 is applied by the page) */
  function loadPacketBytes(bytes, routes) {
    let pkt;
    try { pkt = parseStrict(bytes); } catch (e) { return { verdict: 'IMPORT', detail: e.message, packet: null }; }
    const errs = structureErrors(pkt);
    if (errs.length) return { verdict: 'STRUCTURE', detail: errs.slice(0, 6).join('; '), packet: null };
    const id = semantic(pkt, routes);
    return { verdict: id, detail: id ? 'semantic check ' + id + ' failed' : 'valid', packet: pkt };
  }

  return Object.freeze({ SCHEMA, SCHEMA_TEXT, SCHEMA_VERSION, DIRECT_COUNT_LIMIT, BASE_MAX, BASE_MIN, INTEGER_FIELD_MAX, COEFFICIENT_BOUND,
    COEFFICIENT_COMPONENT_MAX, BYTE_CAP, PLACEHOLDER_BUILD, validate, structureErrors, semantic, checkPacket, bindLiveSource, parseStrict,
    canonicalJson, ensureAsciiJson, exportText, fixtureText, buildPacket, fixtureRow, loadPacketBytes, parseCoefficient, canonicalFraction,
    primeDivisorSetBig, eulerTotientBig, isPrimeBig, factorialBig, gcdBig, integerFields });
}));
