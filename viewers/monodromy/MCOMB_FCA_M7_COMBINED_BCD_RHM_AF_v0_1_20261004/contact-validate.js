/* Contact sweep 0.1 import/validation boundary for schema 0.2.0.
 * Structure is checked by a hand-written mirror of contact-sweep.schema.json
 * (differentially tested against Draft 2020-12 jsonschema), then exact
 * semantics by per-event identities followed by full regeneration. Raw
 * imports are byte-capped before decoding; BOM, malformed UTF-8, duplicate
 * keys and nonstandard numeric constants are rejected. Nothing is repaired. */
(function (root, factory) {
  const api = factory(typeof module === 'object' && module.exports ? require('./contact-core.js') : root.McombContactSweepCoreV1,
    typeof module === 'object' && module.exports ? require('./strict-json.js') : root.strictJSON);
  if (typeof module === 'object' && module.exports) module.exports = api;
  else root.McombContactSweepValidateV1 = api;
})(typeof globalThis !== 'undefined' ? globalThis : this, function (C, strictJSON) {
  'use strict';
  const { ContractError, need } = C;
  const UINT = /^(0|[1-9][0-9]*)$/, POS = /^[1-9][0-9]*$/, EVENT_ID = /^[1-9][0-9]*:(0|[1-9][0-9]*)$/,
    FRACTION_ID = /^(0|[1-9][0-9]*)\/[1-9][0-9]*$/, SHA = /^[0-9a-f]{64}$/;
  const isPlain = v => v !== null && typeof v === 'object' && !Array.isArray(v);

  function structural(data) {
    const fail = (path, message) => { throw new ContractError('STRUCTURE at ' + (path || '<root>') + ': ' + message); };
    const obj = (v, path, required, optional = []) => {
      if (!isPlain(v)) fail(path, 'object required');
      for (const k of required) if (!Object.prototype.hasOwnProperty.call(v, k)) fail(path, "'" + k + "' is a required property");
      for (const k of Object.keys(v)) if (!required.includes(k) && !optional.includes(k)) fail(path, 'additional property ' + JSON.stringify(k));
    };
    const str = (v, path, re, max, min = 0) => {
      if (typeof v !== 'string') fail(path, 'string required');
      const n = [...v].length; if (n > max || n < min || (re && !re.test(v))) fail(path, 'string does not match pattern or length');
    };
    const uint = (v, p) => str(v, p, UINT, 128), pos = (v, p) => str(v, p, POS, 128);
    const rat = (v, p) => { obj(v, p, ['numerator', 'denominator']); uint(v.numerator, p + '/numerator'); pos(v.denominator, p + '/denominator'); };
    const oneOf = (v, p, values) => { if (!values.includes(v)) fail(p, 'value not in ' + JSON.stringify(values)); };
    const arr = (v, p, min, max) => { if (!Array.isArray(v)) fail(p, 'array required'); if (v.length < min || v.length > max) fail(p, 'array length outside [' + min + ',' + max + ']'); };

    obj(data, '', ['schema_version', 'kind', 'convention', 'source', 'config', 'position', 'coverage', 'events', 'fractions', 'neighbors', 'counts', 'selected_event_id']);
    oneOf(data.schema_version, 'schema_version', ['0.2.0', '0.3.0']);
    oneOf(data.kind, 'kind', ['fourier_contact_sweep_snapshot']);
    oneOf(data.convention, 'convention', ['CANONICAL_LOWER_AXIS_HALF_TURNS_V1']);
    obj(data.source, 'source', ['host_build', 'host_sha256']);
    str(data.source.host_build, 'source/host_build', null, 256, 1);
    str(data.source.host_sha256, 'source/host_sha256', SHA, 64, 64);
    const c = data.config;
    obj(c, 'config', ['Q', 'base_B', 'base_mode', 'factorial_index', 'comb_m', 't1', 't2', 'branch', 'n6', 'alpha']);
    pos(c.Q, 'config/Q'); pos(c.base_B, 'config/base_B');
    oneOf(c.base_mode, 'config/base_mode', ['direct', 'factorial']);
    if (c.factorial_index !== null) pos(c.factorial_index, 'config/factorial_index');
    if (c.base_mode === 'factorial') oneOf(c.factorial_index, 'config/factorial_index', ['3', '4', '5', '6', '7', '8']);
    else if (c.factorial_index !== null) fail('config/factorial_index', 'null required for direct base');
    // 0.2.0 is the sealed binary-comb contract; 0.3.0 differs only by comb_m in 3..720.
    if (data.schema_version === '0.2.0') oneOf(c.comb_m, 'config/comb_m', ['2']);
    else { pos(c.comb_m, 'config/comb_m'); if (c.comb_m === '2' || c.comb_m.length > 3 || +c.comb_m > 720) fail('config/comb_m', '0.3.0 requires comb order 3..720'); } oneOf(c.t1, 'config/t1', ['1']); oneOf(c.t2, 'config/t2', ['1']);
    oneOf(c.branch, 'config/branch', ['-1']); oneOf(c.n6, 'config/n6', ['-1', '1']); oneOf(c.alpha, 'config/alpha', ['-1', '0', '1']);
    obj(data.position, 'position', ['cursor_s', 'generation_epoch']);
    rat(data.position.cursor_s, 'position/cursor_s'); uint(data.position.generation_epoch, 'position/generation_epoch');
    oneOf(data.coverage, 'coverage', ['PARTIAL', 'COMPLETE']);
    arr(data.events, 'events', 1, 33152);
    data.events.forEach((e, i) => {
      const p = 'events/' + i;
      obj(e, p, ['event_id', 'shell_N', 'tooth_k', 'half_turn_j', 'spin_s', 'coordinate_x', 'axis_side']);
      str(e.event_id, p + '/event_id', EVENT_ID, 257); pos(e.shell_N, p + '/shell_N'); pos(e.tooth_k, p + '/tooth_k');
      uint(e.half_turn_j, p + '/half_turn_j'); rat(e.spin_s, p + '/spin_s'); rat(e.coordinate_x, p + '/coordinate_x');
      oneOf(e.axis_side, p + '/axis_side', ['positive_real', 'negative_real']);
    });
    arr(data.fractions, 'fractions', 1, 33152);
    data.fractions.forEach((f, i) => {
      const p = 'fractions/' + i;
      obj(f, p, ['fraction_id', 'coordinate_x', 'event_ids', 'multiplicity']);
      str(f.fraction_id, p + '/fraction_id', FRACTION_ID, 257); rat(f.coordinate_x, p + '/coordinate_x');
      arr(f.event_ids, p + '/event_ids', 1, 256);
      f.event_ids.forEach((id, k) => str(id, p + '/event_ids/' + k, EVENT_ID, 257));
      if (new Set(f.event_ids).size !== f.event_ids.length) fail(p + '/event_ids', 'has non-unique elements');
      pos(f.multiplicity, p + '/multiplicity');
    });
    arr(data.neighbors, 'neighbors', 0, 33151);
    data.neighbors.forEach((n, i) => {
      const p = 'neighbors/' + i;
      obj(n, p, ['left_id', 'right_id', 'determinant', 'denominator_sum', 'status']);
      str(n.left_id, p + '/left_id', FRACTION_ID, 257); str(n.right_id, p + '/right_id', FRACTION_ID, 257);
      pos(n.determinant, p + '/determinant'); pos(n.denominator_sum, p + '/denominator_sum');
      oneOf(n.status, p + '/status', ['OBSERVED_ONLY', 'FAREY_NEIGHBORS']);
      if (data.coverage === 'COMPLETE') { oneOf(n.status, p + '/status', ['FAREY_NEIGHBORS']); oneOf(n.determinant, p + '/determinant', ['1']); }
      else oneOf(n.status, p + '/status', ['OBSERVED_ONLY']);
    });
    obj(data.counts, 'counts', ['events_seen', 'events_expected', 'addresses_seen', 'neighbor_pairs']);
    for (const k of ['events_seen', 'events_expected', 'addresses_seen', 'neighbor_pairs']) uint(data.counts[k], 'counts/' + k);
    if (data.selected_event_id !== null) str(data.selected_event_id, 'selected_event_id', EVENT_ID, 257);
    return true;
  }

  const canonical = x => x === null || typeof x !== 'object' ? JSON.stringify(x)
    : Array.isArray(x) ? '[' + x.map(canonical).join(',') + ']'
      : '{' + Object.keys(x).sort().map(k => JSON.stringify(k) + ':' + canonical(x[k])).join(',') + '}';

  function semantics(data, expectedHostSha256 = null) {
    const Q = C.checkConfig(data.config);
    need(data.schema_version === C.schemaVersionFor(data.config), 'schema version does not match comb order');
    need(data.events.length <= Q * (Q + 3) / 2, 'Q-dependent event budget exceeded');
    if (expectedHostSha256 !== null) need(data.source.host_sha256 === expectedHostSha256, 'host digest mismatch');
    const cursor = C.rational(data.position.cursor_s);
    C.integer(data.position.generation_epoch);
    for (const e of data.events) {
      const N = C.integer(e.shell_N, true), k = C.integer(e.tooth_k, true), j = C.integer(e.half_turn_j);
      const s = C.rational(e.spin_s), x = C.rational(e.coordinate_x);
      need(N >= 2n && N <= BigInt(Q + 1) && k === N - 1n, 'invalid shell/tooth');
      need(j <= k && s.n <= N * s.d, 'contact outside per-shell window');
      need(e.event_id === N + ':' + j, 'event id/witness mismatch');
      need(k * s.n === N * j * s.d && x.n * N * s.d === s.n * x.d, 'contact phase/address identity failed');
    }
    // Exact regeneration checks prefix membership, ties, reductions, order,
    // groups, neighbors, counts, completeness and selection in one comparison.
    const expected = C.snapshot(data.config, cursor, data.source,
      { epoch: data.position.generation_epoch, selected: data.selected_event_id });
    for (const key of ['coverage', 'events', 'fractions', 'neighbors', 'counts'])
      need(canonical(data[key]) === canonical(expected[key]), 'semantic mismatch in ' + key);
    return true;
  }

  function validateSnapshot(data, { expectedHostSha256 = null } = {}) {
    try { structural(data); return semantics(data, expectedHostSha256); }
    catch (e) { if (e instanceof ContractError) throw e; throw new ContractError('STRUCTURE: malformed snapshot (' + e.name + ')'); }
  }

  /* Raw import: bytes -> strict text -> decoded JSON -> full validation. */
  function loadSnapshotBytes(bytes, { expectedHostSha256 = null } = {}) {
    need(bytes instanceof Uint8Array, 'JSON: input must be bytes');
    need(bytes.length <= C.MAX_IMPORT_BYTES, 'JSON: import byte limit exceeded');
    need(!(bytes[0] === 0xef && bytes[1] === 0xbb && bytes[2] === 0xbf), 'JSON: UTF-8 byte-order mark is not accepted; save as UTF-8 without BOM');
    let data;
    try {
      const textValue = new TextDecoder('utf-8', { fatal: true, ignoreBOM: true }).decode(bytes);
      data = strictJSON(textValue, C.MAX_IMPORT_BYTES);
    } catch (e) { throw new ContractError('JSON: malformed import (' + e.message + ')'); }
    validateSnapshot(data, { expectedHostSha256 });
    return data;
  }

  return Object.freeze({ structural, semantics, validateSnapshot, loadSnapshotBytes, canonical });
});
