/* Tooth contact 0.1 import/validation boundary (worker D) for snapshot schema 0.1.0.
 * Structure: a hand-written mirror of tooth-contact.schema.json (differentially tested against the
 * Draft 2020-12 jsonschema validator through the accepted Python reference). Semantics: the reference
 * _validate_semantics, i.e. per-event identities, then full regeneration compared on coverage, events,
 * stationary, fractions, neighbors, windows and counts. Raw import (reference load_snapshot_json): 64 MiB
 * cap before decoding; BOM, malformed UTF-8, duplicate keys, NaN/Infinity and EVERY numeric token rejected
 * (the format carries all integers as strings). Every failure is a ContractError. Nothing is repaired.
 * Live binding compares BOTH source.host_sha256 (the reference expected_host_sha256) and source.host_build. */
(function (root, factory) {
  const api = factory(typeof module === 'object' && module.exports ? require('./tooth-core.js') : root.McombToothContactCoreV1);
  if (typeof module === 'object' && module.exports) module.exports = api;
  else root.McombToothContactValidateV1 = api;
})(typeof globalThis !== 'undefined' ? globalThis : this, function (C) {
  'use strict';
  const { ContractError, need, isPlain } = C;
  const P = {
    uint: /^(0|[1-9][0-9]*)$/, positive: /^[1-9][0-9]*$/, sint: /^(0|-?[1-9][0-9]*)$/, nonzero: /^-?[1-9][0-9]*$/,
    event_id: /^(0|-?[1-9][0-9]*):[1-9][0-9]*:(0|-?[1-9][0-9]*)$/, fraction_id: /^(0|[1-9][0-9]*)\/[1-9][0-9]*$/,
    sha: /^[0-9a-f]{64}$/, comb_m: /^([2-9]|[1-9][0-9]|[1-6][0-9]{2}|7[01][0-9]|720)$/
  };
  const has = (o, k) => Object.prototype.hasOwnProperty.call(o, k);

  function structural(data) {
    const fail = (path, message) => { throw new ContractError('STRUCTURE at ' + (path || '<root>') + ': ' + message); };
    const obj = (v, path, keys) => {
      if (!isPlain(v)) fail(path, 'object required');
      for (const k of keys) if (!has(v, k)) fail(path, "'" + k + "' is a required property");
      for (const k of Object.keys(v)) if (!keys.includes(k)) fail(path, 'additional property ' + JSON.stringify(k));
    };
    const str = (v, path, re, max, min = 0) => {
      if (typeof v !== 'string') fail(path, 'string required');
      const n = [...v].length; if (n > max || n < min || (re && !re.test(v))) fail(path, 'string does not match pattern or length');
    };
    const uint = (v, p) => str(v, p, P.uint, 128), pos = (v, p) => str(v, p, P.positive, 128);
    const sint = (v, p) => str(v, p, P.sint, 129), nonzero = (v, p) => str(v, p, P.nonzero, 129);
    const rat = (v, p) => { obj(v, p, ['numerator', 'denominator']); uint(v.numerator, p + '/numerator'); pos(v.denominator, p + '/denominator'); };
    const oneOf = (v, p, values) => { if (!values.includes(v)) fail(p, 'value not in ' + JSON.stringify(values)); };
    const arr = (v, p, min, max) => { if (!Array.isArray(v)) fail(p, 'array required'); if (v.length < min || v.length > max) fail(p, 'array length outside [' + min + ',' + max + ']'); };
    const unique = (v, p) => { if (new Set(v.map(x => typeof x === 'string' ? 's' + x : JSON.stringify(x))).size !== v.length) fail(p, 'has non-unique elements'); };

    obj(data, '', ['schema_version', 'kind', 'convention', 'source', 'config', 'position', 'coverage', 'events', 'stationary', 'fractions', 'neighbors', 'windows', 'counts', 'selected_event_id']);
    oneOf(data.schema_version, 'schema_version', ['0.1.0']);
    oneOf(data.kind, 'kind', ['fourier_tooth_contact_snapshot']);
    oneOf(data.convention, 'convention', ['SIGNED_TOOTH_AXIS_HALF_TURNS_V1']);
    obj(data.source, 'source', ['host_build', 'host_sha256']);
    str(data.source.host_build, 'source/host_build', null, 256, 1);
    str(data.source.host_sha256, 'source/host_sha256', P.sha, 64, 64);
    const c = data.config;
    obj(c, 'config', ['Q', 'base_B', 'base_mode', 'factorial_index', 'comb_m', 'teeth', 't1', 't2', 'n6', 'alpha']);
    pos(c.Q, 'config/Q'); pos(c.base_B, 'config/base_B');
    oneOf(c.base_mode, 'config/base_mode', ['direct', 'factorial']);
    if (c.factorial_index !== null) pos(c.factorial_index, 'config/factorial_index');
    if (c.base_mode === 'factorial') oneOf(c.factorial_index, 'config/factorial_index', ['3', '4', '5', '6', '7', '8']);
    else if (c.factorial_index !== null) fail('config/factorial_index', 'null required');
    str(c.comb_m, 'config/comb_m', P.comb_m, Infinity);
    arr(c.teeth, 'config/teeth', 1, 720); c.teeth.forEach((t, i) => sint(t, 'config/teeth/' + i)); unique(c.teeth, 'config/teeth');
    oneOf(c.t1, 'config/t1', ['1']); oneOf(c.t2, 'config/t2', ['1']);
    oneOf(c.n6, 'config/n6', ['-1', '1']); oneOf(c.alpha, 'config/alpha', ['-1', '0', '1']);
    obj(data.position, 'position', ['cursor_s', 'generation_epoch']);
    rat(data.position.cursor_s, 'position/cursor_s'); uint(data.position.generation_epoch, 'position/generation_epoch');
    oneOf(data.coverage, 'coverage', ['PARTIAL', 'COMPLETE']);
    arr(data.events, 'events', 0, 102400);
    data.events.forEach((e, i) => {
      const p = 'events/' + i;
      obj(e, p, ['event_id', 'tooth_c', 'shell_N', 'frequency_k', 'half_turn_j', 'spin_s', 'coordinate_x', 'axis_side']);
      str(e.event_id, p + '/event_id', P.event_id, 400); sint(e.tooth_c, p + '/tooth_c'); pos(e.shell_N, p + '/shell_N');
      nonzero(e.frequency_k, p + '/frequency_k'); sint(e.half_turn_j, p + '/half_turn_j');
      rat(e.spin_s, p + '/spin_s'); rat(e.coordinate_x, p + '/coordinate_x'); oneOf(e.axis_side, p + '/axis_side', ['positive_real', 'negative_real']);
    });
    arr(data.stationary, 'stationary', 0, 720);
    data.stationary.forEach((s, i) => {
      const p = 'stationary/' + i;
      obj(s, p, ['tooth_c', 'shell_N', 'frequency_k', 'status', 'axis_side']);
      nonzero(s.tooth_c, p + '/tooth_c'); pos(s.shell_N, p + '/shell_N'); oneOf(s.frequency_k, p + '/frequency_k', ['0']);
      oneOf(s.status, p + '/status', ['STATIONARY_ON_AXIS']); oneOf(s.axis_side, p + '/axis_side', ['positive_real', 'negative_real']);
    });
    arr(data.fractions, 'fractions', 0, 102400);
    data.fractions.forEach((f, i) => {
      const p = 'fractions/' + i;
      obj(f, p, ['fraction_id', 'coordinate_x', 'event_ids', 'multiplicity', 'tooth_multiplicities']);
      str(f.fraction_id, p + '/fraction_id', P.fraction_id, 257); rat(f.coordinate_x, p + '/coordinate_x');
      arr(f.event_ids, p + '/event_ids', 1, 102400); f.event_ids.forEach((id, k) => str(id, p + '/event_ids/' + k, P.event_id, 400)); unique(f.event_ids, p + '/event_ids');
      pos(f.multiplicity, p + '/multiplicity');
      arr(f.tooth_multiplicities, p + '/tooth_multiplicities', 1, 720);
      f.tooth_multiplicities.forEach((t, k) => { const q = p + '/tooth_multiplicities/' + k; obj(t, q, ['tooth_c', 'multiplicity']); sint(t.tooth_c, q + '/tooth_c'); pos(t.multiplicity, q + '/multiplicity'); });
    });
    arr(data.neighbors, 'neighbors', 0, 102399);
    const partial = data.coverage === 'PARTIAL';
    data.neighbors.forEach((n, i) => {
      const p = 'neighbors/' + i;
      obj(n, p, ['left_id', 'right_id', 'determinant', 'denominator_sum', 'status']);
      str(n.left_id, p + '/left_id', P.fraction_id, 257); str(n.right_id, p + '/right_id', P.fraction_id, 257);
      pos(n.determinant, p + '/determinant'); pos(n.denominator_sum, p + '/denominator_sum');
      oneOf(n.status, p + '/status', partial ? ['OBSERVED_ONLY'] : ['FAREY_NEIGHBORS', 'CONSECUTIVE_ONLY']);
    });
    const win = (w, p, keys) => { obj(w, p, keys); uint(w.address_order, p + '/address_order'); arr(w.missing_denominators, p + '/missing_denominators', 0, 1024);
      w.missing_denominators.forEach((b, k) => pos(b, p + '/missing_denominators/' + k)); oneOf(w.farey_status, p + '/farey_status', ['FULL_FAREY', 'GAPPED']); };
    obj(data.windows, 'windows', ['teeth', 'union']);
    arr(data.windows.teeth, 'windows/teeth', 1, 720);
    data.windows.teeth.forEach((w, i) => {
      const p = 'windows/teeth/' + i;
      win(w, p, ['tooth_c', 'frequency_min', 'frequency_max', 'address_order', 'missing_denominators', 'farey_status', 'stationary_shell', 'events_expected']);
      sint(w.tooth_c, p + '/tooth_c'); sint(w.frequency_min, p + '/frequency_min'); sint(w.frequency_max, p + '/frequency_max');
      if (w.stationary_shell !== null) pos(w.stationary_shell, p + '/stationary_shell'); uint(w.events_expected, p + '/events_expected');
    });
    win(data.windows.union, 'windows/union', ['address_order', 'missing_denominators', 'farey_status']);
    obj(data.counts, 'counts', ['events_seen', 'events_expected', 'addresses_seen', 'neighbor_pairs', 'stationary_shells']);
    for (const k of ['events_seen', 'events_expected', 'addresses_seen', 'neighbor_pairs', 'stationary_shells']) uint(data.counts[k], 'counts/' + k);
    if (data.selected_event_id !== null) str(data.selected_event_id, 'selected_event_id', P.event_id, 400);
    return true;
  }

  /* Order-insensitive for objects, order-sensitive for arrays: the reference's dict/list equality. */
  const canonical = x => x === null || typeof x !== 'object' ? JSON.stringify(x)
    : Array.isArray(x) ? '[' + x.map(canonical).join(',') + ']'
      : '{' + Object.keys(x).sort().map(k => JSON.stringify(k) + ':' + canonical(x[k])).join(',') + '}';

  /* Reference _validate_semantics. */
  function semantics(data, expectedHostSha256 = null) {
    const { Q, teeth } = C.checkConfig(data.config);
    need(data.events.length <= C.expectedEventCount(Q, teeth), 'event budget exceeded');
    if (expectedHostSha256 !== null) need(data.source.host_sha256 === expectedHostSha256, 'host digest mismatch');
    const cursor = C.rational(data.position.cursor_s), epoch = data.position.generation_epoch;
    C.integer(epoch);
    const selectedTeeth = new Set(teeth.map(BigInt));
    for (const e of data.events) {
      const c = C.signed(e.tooth_c), N = C.integer(e.shell_N, true), k = C.signed(e.frequency_k), j = C.signed(e.half_turn_j);
      const s = C.rational(e.spin_s), x = C.rational(e.coordinate_x);
      need(selectedTeeth.has(c) && N >= 2n && N <= BigInt(Q + 1), 'invalid tooth/shell');
      need(k === N + c && k !== 0n, 'frequency must be N+c and nonzero');
      const ak = k < 0n ? -k : k, aj = j < 0n ? -j : j;
      need(aj <= ak && (j === 0n || (j > 0n) === (k > 0n)), 'half-turn outside signed window');
      need(s.n >= 0n && s.n <= N * s.d, 'contact outside per-shell window');
      need(e.event_id === c + ':' + N + ':' + j, 'event id/witness mismatch');
      need(k * s.n === N * j * s.d && x.n * N * s.d === s.n * x.d, 'contact phase/address identity failed');
    }
    const expected = C.snapshot(data.config, cursor, data.source, { epoch, selected: data.selected_event_id });
    for (const key of ['coverage', 'events', 'stationary', 'fractions', 'neighbors', 'windows', 'counts'])
      need(canonical(data[key]) === canonical(expected[key]), 'semantic mismatch in ' + key);
    return true;
  }

  /* Reference validate_snapshot: structure first, then exact arithmetic. */
  function validateSnapshot(data, { expectedHostSha256 = null } = {}) {
    try { structural(data); return semantics(data, expectedHostSha256); }
    catch (e) { if (e instanceof ContractError) throw e; throw new ContractError('STRUCTURE: malformed snapshot (' + e.name + ')'); }
  }

  /* Live binding to a running build: the reference host-digest check plus the declared build name. */
  function validateLive(data, { hostSha256, hostBuild }) {
    need(typeof hostSha256 === 'string' && P.sha.test(hostSha256) && typeof hostBuild === 'string' && hostBuild.length > 0, 'live binding needs the running identity');
    validateSnapshot(data, { expectedHostSha256: hostSha256 });
    need(data.source.host_build === hostBuild, 'host build mismatch: record names ' + JSON.stringify(String(data.source.host_build).slice(0, 80)));
    return true;
  }

  /* Strict JSON text scan: duplicate keys, numeric tokens, nonstandard constants, depth. Then JSON.parse. */
  function strictParse(textValue) {
    let i = 0; const n = textValue.length;
    const fail = m => { throw new ContractError('JSON: ' + m); };
    const ws = () => { while (i < n) { const ch = textValue.charCodeAt(i); if (ch === 0x20 || ch === 0x0a || ch === 0x0d || ch === 0x09) i++; else break; } };
    const string = decode => {
      const start = i++;
      while (i < n) {
        const ch = textValue.charCodeAt(i);
        if (ch === 0x5c) { i += 2; continue; }
        if (ch < 0x20) fail('control character in string');
        i++;
        if (ch === 0x22) return decode ? JSON.parse(textValue.slice(start, i)) : null;
      }
      fail('unterminated string');
    };
    const value = depth => {
      ws(); if (depth > 64) fail('nesting depth exceeded');
      const ch = textValue[i];
      if (ch === '"') { string(false); return; }
      if (ch === '{') {
        i++; ws(); const seen = new Set();
        if (textValue[i] === '}') { i++; return; }
        for (;;) {
          ws(); if (textValue[i] !== '"') fail('object key required');
          const k = string(true); if (seen.has(k)) fail('duplicate object key ' + JSON.stringify(k).slice(0, 80)); seen.add(k);
          ws(); if (textValue[i++] !== ':') fail('expected colon');
          value(depth + 1); ws();
          const c2 = textValue[i++]; if (c2 === '}') return; if (c2 !== ',') fail('expected object separator');
        }
      }
      if (ch === '[') {
        i++; ws(); if (textValue[i] === ']') { i++; return; }
        for (;;) { value(depth + 1); ws(); const c2 = textValue[i++]; if (c2 === ']') return; if (c2 !== ',') fail('expected array separator'); }
      }
      if (ch === '-' || (ch >= '0' && ch <= '9')) fail('numeric tokens are not part of this format');
      for (const lit of ['true', 'false', 'null']) if (textValue.startsWith(lit, i)) { i += lit.length; return; }
      if (textValue.startsWith('NaN', i) || textValue.startsWith('Infinity', i)) fail('nonstandard numeric constant');
      fail('invalid JSON value');
    };
    value(0); ws(); if (i !== n) fail('trailing content');
    try { return JSON.parse(textValue); } catch (e) { fail('malformed import (' + e.name + ')'); }
  }

  /* Reference load_snapshot_json: bytes -> strict text -> decoded JSON -> full validation. */
  function loadSnapshotBytes(bytes, { expectedHostSha256 = null } = {}) {
    need(bytes instanceof Uint8Array, 'JSON: input must be bytes');
    need(bytes.length <= C.MAX_IMPORT_BYTES, 'JSON: import byte limit exceeded');
    need(!(bytes[0] === 0xef && bytes[1] === 0xbb && bytes[2] === 0xbf), 'JSON: UTF-8 byte-order mark is not accepted');
    let data;
    try { data = strictParse(new TextDecoder('utf-8', { fatal: true, ignoreBOM: true }).decode(bytes)); }
    catch (e) { if (e instanceof ContractError) throw e; throw new ContractError('JSON: malformed import (' + e.name + ')'); }
    validateSnapshot(data, { expectedHostSha256 });
    return data;
  }

  return Object.freeze({ structural, semantics, validateSnapshot, validateLive, strictParse, loadSnapshotBytes, canonical });
});
