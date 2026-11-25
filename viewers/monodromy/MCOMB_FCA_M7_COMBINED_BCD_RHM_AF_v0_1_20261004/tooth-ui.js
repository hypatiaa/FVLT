/* Tooth contact 0.1.3 panel (v0.1.1 repaired Astra's F1/F2; v0.1.2 re-renders on every receipt invalidation; v0.1.3 adds latest-import ownership, review H1), host adapter and diagnostics (worker D) for the Basel-link v0.1.2 host successor.
 * Implements the accepted per-tooth contact schema (TOOTH_CONTACT_SCHEMA_v0_1_1, snapshot 0.1.0) as an opt-in
 * panel. The exact schedule comes from McombToothContactCoreV1 in an epoch-tagged worker (message types tc/…).
 * The host is READ through liftSourceSnapshot(), selectedShellBase(), combOffsets() and isBranchOffsetVisible();
 * it is WRITTEN only by the explicit "Place selected contact" action, after the schema §6 adapter checks:
 * running-identity binding (digest AND build name), exact t1/t2/n6/alpha comparison, tooth-offset membership
 * and base agreement, all before any write; then every placed field is read back. Stationary shells have no
 * isolated event and are never placed. The c = 0 tooth is kept apart from the M4 divisor register (contact
 * s in Z versus M4 encounter s/N in Z); no M4 code is called. Floats are used for drawing only. The existing
 * c = -1 contact-sweep panel and the Basel panel are untouched. */
(() => {
  'use strict';
  const C = window.McombToothContactCoreV1, V = window.McombToothContactValidateV1, PINS = window.McombToothContactBuildPins;
  if (!C || !V || !PINS || typeof liftSourceSnapshot !== 'function') throw Error('Tooth contact modules or host seam missing');
  const SOURCE = Object.freeze({ host_build: PINS.hostBuild, host_sha256: PINS.hostSha256 });
  const TICKS = 240n, TABLE_ALL = 400, TABLE_WINDOW = 200, CHIP_MAX_M = 31;
  const $ = id => document.getElementById(id);
  const el = (tag, attrs = {}, text = null) => { const e = document.createElement(tag); for (const [k, v] of Object.entries(attrs)) e.setAttribute(k, v); if (text !== null) e.textContent = text; return e; };
  const approx = r => (Number(r.n) / Number(r.d)).toPrecision(8).replace(/\.?0+$/, '');
  const R = (n, d = 1n) => C.reduce(BigInt(n), BigInt(d));
  const eventId = C.eventId;
  const signTxt = c => (c < 0 ? '−' + (-c) : String(c));

  let epoch = 0n, staleRejected = 0, worker = null, pending = null, pollTimer = null, frame = null;
  const panel = { open: false, Q: 24, teeth: [-1, 1], speed: 20, status: 'INCOMPATIBLE', reason: 'panel closed', error: null };
  let record = null;   // { kind, config, source, rows, cursor, attached (always true since v0.1.1), hostKey, index, importName }
  let receiptCleared = null;   // v0.1.1 (F1): the last receipt withdrawn because the host no longer matches its read-back
  let hiddenSig = null, lastKey = null, selected = null, hostKey = null, placement = null, guard = false, lastTime = 0, acc = 0;

  /* ---------------- host read seam ---------------- */
  function hostProfile() {
    const h = liftSourceSnapshot(), B = h.shellBase;
    const base = { mode: h.shellMode === 'integer' ? 'direct' : 'factorial', B, index: h.shellMode === 'factorial' ? h.n1 : null };
    const out = { base, n6: h.n6, alpha: h.alpha, m: h.m, t1: h.t1Exact, t2: h.t2Exact, config: null, reason: null };
    const Q = panel.Q, teeth = panel.teeth;
    const offsets = Number.isSafeInteger(h.m) ? new Set(combOffsets(h.m)) : new Set();
    const absent = teeth.filter(c => !offsets.has(c));
    if (!Number.isSafeInteger(B)) out.reason = 'host base is not an exact safe integer';
    else if (base.mode === 'direct' && (B < C.DIRECT_BASE_MIN || B > C.DIRECT_BASE_MAX)) out.reason = `host direct base M=${B} is outside the tooth-contact profile 2..1,000,000 (not clamped)`;
    else if (base.mode === 'factorial' && (h.n1 < C.FACTORIAL_INDEX_MIN || h.n1 > C.FACTORIAL_INDEX_MAX)) out.reason = `host factorial index ${h.n1}! is outside the tooth-contact profile 3..8 (not clamped)`;
    else if (Q > B) out.reason = `Q=${Q} exceeds host base B=${B}; choose Q ≤ B`;
    else if (!Number.isSafeInteger(h.m) || h.m < C.COMB_M_MIN || h.m > C.COMB_M_MAX) out.reason = `host comb order m=${h.m} is outside 2..720`;
    else if (absent.length) out.reason = `selected ${absent.length > 1 ? 'teeth' : 'tooth'} c=${absent.map(signTxt).join(', ')} ${absent.length > 1 ? 'are' : 'is'} not an offset of the host comb m=${h.m}; choose teeth from {${combOffsets(h.m).slice(0, 24).map(signTxt).join(', ')}${h.m > 24 ? ', …' : ''}}`;
    else if (h.t1Exact !== '1' || h.t2Exact !== '1') out.reason = `canonical coefficients t₁=t₂=1 required (k=N+c); host has t₁=${h.t1Exact}, t₂=${h.t2Exact}. This panel never changes host coefficients; use the host gearbox.`;
    else if (h.n6 === 0) out.reason = 'zero radius (n₆=0) is refused: no axis side exists';
    else if (h.n6 !== 1 && h.n6 !== -1) out.reason = `radius sign n₆=${h.n6} is outside the exact profile {−1,+1}`;
    else if (![-1, 0, 1].includes(h.alpha)) out.reason = `radial exponent α=${h.alpha} is outside the exact profile {−1,0,1}`;
    else if (C.expectedEventCount(Q, teeth) > C.MAX_EVENTS) out.reason = `selection needs ${C.expectedEventCount(Q, teeth).toLocaleString('en')} events, over the declared cap 102,400; refused, never truncated`;
    if (!out.reason) {
      out.config = C.configuration(Q, teeth, { m: h.m, B, factorialIndex: base.index, n6: String(h.n6), alpha: String(h.alpha) });
      C.checkConfig(out.config);
    }
    out.key = JSON.stringify([Q, teeth, base, h.n6, h.alpha, h.m, h.t1Exact, h.t2Exact]);
    return out;
  }
  const hidden = c => { try { return typeof isBranchOffsetVisible === 'function' ? !isBranchOffsetVisible(c) : false; } catch (_) { return false; } };

  /* ---------------- epochs, worker, generation ---------------- */
  function workerInstance() {
    if (worker) return worker;
    const url = URL.createObjectURL(new Blob([window.McombToothContactWorkerSource], { type: 'text/javascript' }));
    worker = new Worker(url); URL.revokeObjectURL(url);
    worker.onmessage = ev => {
      const msg = ev.data || {};
      if (typeof msg.type !== 'string' || !msg.type.startsWith('tc/') || !pending || msg.epoch !== pending.epoch || String(epoch) !== msg.epoch) { staleRejected++; return; }
      const job = pending; pending = null;
      if (msg.type === 'tc/error') { panel.status = 'ERROR'; panel.error = 'Generation failed: ' + msg.error; draw(); return; }
      const { Q, teeth } = C.checkConfig(job.config);
      if (msg.type !== 'tc/schedule' || !Array.isArray(msg.rows) || msg.rows.length !== C.expectedEventCount(Q, teeth)) { panel.status = 'ERROR'; panel.error = 'Worker returned an incomplete schedule'; draw(); return; }
      record = { kind: 'LIVE', config: job.config, source: SOURCE, rows: msg.rows, cursor: R(0), attached: true, hostKey: job.hostKey, index: indexRows(msg.rows) };
      selected = null; placement = null; panel.error = null; setStatus(); draw();
    };
    worker.onerror = e => { if (pending) { pending = null; panel.status = 'ERROR'; panel.error = 'Worker error: ' + (e.message || 'unknown'); draw(); } };
    return worker;
  }
  function bump() { epoch += 1n; return String(epoch); }
  function stopPlay() { if (frame !== null) cancelAnimationFrame(frame); frame = null; }
  function generate(profile) {
    stopPlay();
    const e = bump();
    record = null; selected = null; placement = null; receiptCleared = null; panel.error = null;
    pending = { epoch: e, config: profile.config, hostKey: profile.key };
    panel.status = 'READY'; panel.reason = 'generating exact schedule…';
    workerInstance().postMessage({ type: 'tc/generate', epoch: e, config: profile.config });
    draw();
  }
  function cancel() {
    stopPlay();
    const hadPending = !!pending;
    bump();
    if (pending) { pending = null; worker?.terminate(); worker = null; }
    if (hadPending) { placement = null; panel.status = 'ERROR'; panel.error = 'Generation cancelled; Reset starts a new epoch.'; }
    else setStatus();
    draw();
    return { cancelled: hadPending, epoch: String(epoch) };
  }
  function indexRows(rows) {
    const all = C.groups(rows), pos = new Map(), eventPos = new Map();
    rows.forEach((r, i) => eventPos.set(eventId(r), i));
    all.forEach((g, i) => { pos.set(C.fractionId(g.x), i); g.firstVisit = eventPos.get(eventId(g.rows[0])); });
    return { groups: all, pos, eventPos };
  }
  const prefix = () => record ? C.prefixLength(record.rows, record.cursor) : 0;
  const Qof = rec => Number(rec.config.Q);
  const endOf = rec => R(Qof(rec) + 1);
  function setStatus() {
    if (!record) return;
    if (C.compare(record.cursor, endOf(record)) === 0) panel.status = 'COMPLETE';
    else if (frame !== null) panel.status = 'RUNNING';
    else panel.status = C.compare(record.cursor, R(0)) === 0 ? 'READY' : 'PAUSED';
    panel.reason = null;
  }

  /* ---------------- host observation ---------------- */
  function poll() {
    if (!panel.open) return;
    if (checkReceipt()) draw();
    let profile;
    try { profile = hostProfile(); } catch (e) { panel.status = 'ERROR'; panel.error = 'Host read failed: ' + e.message; draw(); return; }
    const hs = JSON.stringify(combOffsets(profile.m).filter(hidden));           // host branch mask: disclosure only
    if (hs !== hiddenSig) { hiddenSig = hs; if (profile.key === hostKey) draw(); }
    if (profile.key === hostKey) { if (record?.kind === 'IMPORTED') drawHostNote(profile); return; }
    hostKey = profile.key;
    if (record?.kind === 'IMPORTED') { drawHostNote(profile); draw(); return; }
    invalidate(profile);
  }
  function invalidate(profile) {
    stopPlay();
    if (pending) pending = null;
    if (!profile.config) {
      bump(); record = null; selected = null; placement = null;
      panel.status = 'INCOMPATIBLE'; panel.reason = profile.reason; panel.error = null; draw(); return;
    }
    generate(profile);
  }

  /* ---------------- transport ---------------- */
  function requireLive(action) {
    if (!record) throw new C.ContractError(action + ': no ready record (' + panel.status + (panel.reason ? ': ' + panel.reason : '') + ')');
    if (record.kind !== 'LIVE') throw new C.ContractError(action + ': imported snapshot is held; Reset returns to the live host');
  }
  function moveTo(cursor) {
    const Q = Qof(record);
    C.need(cursor.n >= 0n && C.compare(cursor, R(Q + 1)) <= 0, `cursor must lie in [0, ${Q + 1}]`);
    record.cursor = C.reduce(cursor.n, cursor.d);
    if (selected !== null && record.index.eventPos.get(selected) >= prefix()) selected = null;
    if (placement && placement.event !== selected) placement = null;      // receipt bound to its selected event
    setStatus();
  }
  function seekExact(cursor) { requireLive('seek'); stopPlay(); moveTo(cursor); draw(); }
  function step(direction) {
    requireLive('step'); stopPlay();
    const t = direction > 0 ? C.nextTime(record.rows, record.cursor) : C.previousTime(record.rows, record.cursor);
    if (t) moveTo(t); else setStatus();
    draw();
  }
  function play() {
    requireLive('play');
    if (panel.status === 'COMPLETE') { panel.reason = 'End reached at Q+1; Reset to replay.'; draw(); return; }
    if (frame !== null) return;
    lastTime = performance.now(); acc = 0;
    frame = requestAnimationFrame(tick); setStatus(); draw();
  }
  function pause() { stopPlay(); if (record) setStatus(); draw(); }
  function tick(now) {
    frame = null;
    if (!record || record.kind !== 'LIVE') return;
    const Q = Qof(record), rate = Number(TICKS) * (Q + 1) / panel.speed;   // pacing only
    acc += Math.max(0, now - lastTime) / 1000 * rate; lastTime = now;
    const k = BigInt(Math.floor(acc)); acc -= Number(k);
    if (k > 0n) {
      let next = C.reduce(record.cursor.n * TICKS + k * record.cursor.d, record.cursor.d * TICKS);
      if (C.compare(next, R(Q + 1)) >= 0) next = R(Q + 1);
      moveTo(next);
    }
    if (C.compare(record.cursor, R(Q + 1)) === 0) { setStatus(); draw(); return; }
    frame = requestAnimationFrame(tick); setStatus(); draw();
  }
  function reset() {
    stopPlay();
    const profile = hostProfile(); hostKey = profile.key;
    if (!profile.config) { invalidate(profile); return; }
    if (record?.kind === 'LIVE' && record.hostKey === profile.key) {
      bump(); record.cursor = R(0); selected = null; placement = null; panel.error = null; setStatus(); draw(); return;
    }
    generate(profile);
  }

  /* ---------------- snapshots, import, export ---------------- */
  function currentSnapshot() {
    if (record?.kind === 'LIVE' && panel.open) poll();                 // never export against a stale host reading
    if (!record) throw new C.ContractError('snapshot: no ready record (' + panel.status + ')');
    const snap = C.snapshot(record.config, record.cursor, record.source, { epoch: String(epoch), selected, rows: record.rows });
    if (record.attached) V.validateLive(snap, { hostSha256: SOURCE.host_sha256, hostBuild: SOURCE.host_build });
    else V.validateSnapshot(snap);
    return snap;
  }
  const exportText = () => { const b = C.canonicalBytes(currentSnapshot()); let s = ''; for (let i = 0; i < b.length; i += 65536) s += String.fromCharCode.apply(null, b.subarray(i, i + 65536)); return s; };
  function exportSnapshot() {
    const snap = currentSnapshot(), bytes = C.canonicalBytes(snap);         // the one export serializer
    const blob = new Blob([bytes], { type: 'application/json' }), a = el('a');
    a.href = URL.createObjectURL(blob);
    a.download = `tooth-contact-Q${snap.config.Q}-teeth${snap.config.teeth.join('_')}-S${C.text(record.cursor).replace('/', '_')}-B${snap.config.base_B}.json`;
    document.body.append(a); a.click(); a.remove(); setTimeout(() => URL.revokeObjectURL(a.href), 1000);
    return { bytes: bytes.length, epoch: snap.position.generation_epoch };
  }
  /* v0.1.3 (Astra combined-handoff review H1): latest-import ownership. Every import action takes a distinct operation token
   * (beginImport) BEFORE its size check and file read. Only the holder of the latest token may commit anything: the record,
   * selection, epoch, transport, placement/receipt or the error text. Ownership is re-checked after the file read, after
   * validation and in every catch path. A superseded operation changes nothing in the host or the panel; it is only logged.
   * The token is not an epoch: an import that is refused never bumps the epoch. */
  let importSeq = 0;
  const importEvents = [];
  const logImport = (event, detail) => { importEvents.push({ event, ...detail }); if (importEvents.length > 200) importEvents.shift(); };
  const ownsImport = op => op === importSeq;
  function beginImport(entry) { importSeq += 1; logImport('IMPORT_BEGIN', { op: importSeq, entry }); return importSeq; }
  function supersededImport(op, where) { logImport('IMPORT_SUPERSEDED', { op, latest: importSeq, where }); return { op, committed: false, superseded: true }; }
  // the only writer of an import refusal: it commits the visible error only for the latest operation
  function refuseImport(op, e, where) {
    if (!ownsImport(op)) return supersededImport(op, where);
    logImport('IMPORT_REJECTED', { op, where, reason: String(e && e.message).slice(0, 200) });
    panel.error = 'Import rejected; previous state retained. ' + e.message; draw(); throw e;
  }
  async function importFile(file, op) {
    if (op === undefined) op = beginImport('file-input');                // the token exists before the size check and the read
    if (file.size > C.MAX_IMPORT_BYTES) return refuseImport(op, new C.ContractError('JSON: import byte limit exceeded'), 'size check');
    let bytes;
    try { bytes = new Uint8Array(await file.arrayBuffer()); }
    catch (e) { return refuseImport(op, new C.ContractError('JSON: the file could not be read (' + (e && e.name) + ')'), 'file read'); }
    if (!ownsImport(op)) return supersededImport(op, 'after file read, before validation');
    return importBytes(bytes, file.name, op);
  }
  function importBytes(bytes, name = 'import', op) {
    if (op === undefined) op = beginImport('diagnostics');                // diagnostics entry: a token before validation
    // v0.1.1 (Astra F2): the record is loaded, validated AND bound to the running identity (digest and build) before
    // anything is committed. On any failure the prior record, selection, epoch, transport and host are untouched.
    let data, rows;
    try {
      data = V.loadSnapshotBytes(bytes);
      try { V.validateLive(data, { hostSha256: SOURCE.host_sha256, hostBuild: SOURCE.host_build }); }
      catch (e) { throw new C.ContractError('live identity refused (' + e.message + '): the record names ' + String(data.source.host_build).slice(0, 80) + ' ' + String(data.source.host_sha256).slice(0, 12) + '…; this build is ' + SOURCE.host_build + ' ' + SOURCE.host_sha256.slice(0, 12) + '…'); }
      rows = C.schedule(data.config);
    } catch (e) { return refuseImport(op, e, 'validation'); }
    if (!ownsImport(op)) return supersededImport(op, 'after validation, before commit');
    logImport('IMPORT_COMMITTED', { op, name: String(name).slice(0, 120) });
    stopPlay(); if (pending) pending = null;
    bump();
    record = { kind: 'IMPORTED', config: data.config, source: { ...data.source }, rows, cursor: C.rational(data.position.cursor_s),
      attached: true, importName: String(name).slice(0, 200), index: indexRows(rows) };
    selected = data.selected_event_id; placement = null; receiptCleared = null; panel.error = null; setStatus();
    draw(); drawHostNote(hostProfileSafe());
    return { op, committed: true, attached: true, epoch: String(epoch) };
  }

  /* ---------------- host placement (schema §6) ---------------- */
  function selectedRow() { return selected === null || !record ? null : record.rows[record.index.eventPos.get(selected)]; }
  function coefficientMismatch(cfg) {
    const h = liftSourceSnapshot(), bad = [];
    if (h.t1Exact !== cfg.t1) bad.push(`t₁=${h.t1Exact} (record ${cfg.t1})`);
    if (h.t2Exact !== cfg.t2) bad.push(`t₂=${h.t2Exact} (record ${cfg.t2})`);
    if (String(h.n6) !== cfg.n6) bad.push(`n₆=${h.n6} (record ${cfg.n6})`);
    if (String(h.alpha) !== cfg.alpha) bad.push(`α=${h.alpha} (record ${cfg.alpha})`);
    return bad.join(', ');
  }
  /* Host tooth-c half-turn phase (N·t₁ + c·t₂)·s/N from exact host strings, as reduced text. */
  function hostToothPhase(c, N, sExact) {
    try {
      const q = t => { const [a, b = '1'] = String(t).split('/'); return { n: BigInt(a), d: BigInt(b) }; };
      const h = liftSourceSnapshot(), t1 = q(h.t1Exact), t2 = q(h.t2Exact), s = q(sExact), bN = BigInt(N), bc = BigInt(c);
      let n = (bN * t1.n * t2.d + bc * t2.n * t1.d) * s.n, d = t1.d * t2.d * s.d * bN;
      if (d < 0n) { n = -n; d = -d; }
      const g = C.gcd(n, d) || 1n; n /= g; d /= g;
      return d === 1n ? String(n) : n + '/' + d;
    } catch (_) { return null; }
  }
  const identityProblem = src => src.host_sha256 !== SOURCE.host_sha256 ? 'host digest ' + String(src.host_sha256).slice(0, 12) + '… is not this build ' + SOURCE.host_sha256.slice(0, 12) + '…'
    : src.host_build !== SOURCE.host_build ? 'host build ' + JSON.stringify(String(src.host_build).slice(0, 60)) + ' is not ' + SOURCE.host_build : null;
  function placeSelected({ applySnapshotBase = false } = {}) {
    const fail = reason => { placement = { status: 'HOST_PLACEMENT_UNAVAILABLE', reason: reason + '; no host write performed', event: selected, hostWrite: false }; draw(); return JSON.parse(JSON.stringify(placement)); };
    if (record?.kind === 'LIVE') poll();                               // never place against a stale host reading
    if (!record) return fail('no ready record');
    const row = selectedRow();
    if (!row) return fail('no selected contact');
    const idp = identityProblem(record.source); if (idp) return fail('identity: ' + idp);
    const cfg = record.config, B = Number(cfg.base_B), index = cfg.factorial_index === null ? null : Number(cfg.factorial_index);
    const mismatch = coefficientMismatch(cfg);
    if (mismatch) return fail('host coefficients do not realize this contact: ' + mismatch);
    const h0 = liftSourceSnapshot(), offsets = new Set(combOffsets(h0.m)), absent = cfg.teeth.map(Number).filter(c => !offsets.has(c));
    if (absent.length) return fail(`selected ${absent.length > 1 ? 'teeth' : 'tooth'} c=${absent.map(signTxt).join(', ')} absent from the host comb m=${h0.m}`);
    const hb = hostProfile().base, sameBase = hb.mode === cfg.base_mode && hb.B === B && hb.index === index;
    if (!sameBase && !applySnapshotBase) return fail(`record base ${cfg.base_mode === 'factorial' ? index + '!=' : 'M='}${B} differs from host base; choose Apply record base`);
    const sText = C.text(row.s), receipt = { event: selected, c: row.c, N: row.N, k: row.k, j: row.j, sExact: sText, pausedHost: [], hostWrite: true };
    guard = true;
    try {
      if (state.isAnimating) { toggleAnim('phi3'); receipt.pausedHost.push('phi3'); }
      if (state.isAnimatingS) { toggleAnim('s'); receipt.pausedHost.push('s'); }
      if (!sameBase) { applySelectedShell(cfg.base_mode === 'factorial' ? { mode: 'factorial', n1: index } : { mode: 'integer', directBase: B }); receipt.baseChanged = true; }
      const hostB = selectedShellBase();
      state.phi3 = hostB + 1 - row.N;
      phi3Slider.value = String(row.N);
      updateStepperState(); updateSSliderRange();
      setSValue(Number(row.s.n) / Number(row.s.d), sText, 'tooth contact ' + selected);
    } catch (e) { guard = false; placement = { status: 'HOST_PLACEMENT_UNAVAILABLE', reason: 'host write failed: ' + e.message, ...receipt }; draw(); return JSON.parse(JSON.stringify(placement)); }
    guard = false;
    const hbase = selectedShellBase(), h1 = liftSourceSnapshot();
    const read = { mode: state.shellMode === 'integer' ? 'direct' : 'factorial', B: hbase, index: state.shellMode === 'factorial' ? state.n1 : null,
      N: currentN(), phi3: state.phi3, slider: Number(phi3Slider.value), sliderMax: Number(phi3Slider.max), sExact: state.sExact, m: h1.m };
    receipt.readBack = read;
    receipt.hostCoefficients = { t1: h1.t1Exact, t2: h1.t2Exact, n6: String(h1.n6), alpha: String(h1.alpha) };
    receipt.recordTeeth = cfg.teeth.map(Number);
    const after = coefficientMismatch(cfg), phase = hostToothPhase(row.c, read.N, read.sExact), inComb = combOffsets(h1.m).includes(row.c);
    receipt.hostToothPhase = phase; receipt.coefficients = after ? 'MISMATCH: ' + after : 'MATCH'; receipt.toothInHostComb = inComb;
    receipt.hiddenTooth = hidden(row.c);
    receipt.note = receipt.hiddenTooth ? `tooth c=${signTxt(row.c)} is hidden by the host branch mask (hiddenBranchOffsets): the address is placed exactly, but the tooth is not drawn` : null;
    receipt.register = row.c === 0 ? { tooth: 'c=0 contact: s ∈ ℤ', m4: 'separate register: an M4 divisor encounter needs s/N ∈ ℤ; ' + (row.s.d === 1n && row.s.n % BigInt(row.N) === 0n ? 's/N = ' + (row.s.n / BigInt(row.N)) + ' ∈ ℤ here' : 's/N = ' + C.fractionId(row.x) + ' ∉ ℤ here: not an M4 encounter') } : null;
    const ok = read.mode === cfg.base_mode && read.B === B && read.index === index && read.N === row.N && read.phi3 === B + 1 - row.N &&
      read.slider === row.N && read.sliderMax === B + 1 && read.sExact === sText && !after && inComb && phase === String(row.j);
    receiptCleared = null;
    placement = ok ? { status: 'PLACED_EXACT_ADDRESS', ...receipt } : { status: 'HOST_PLACEMENT_UNAVAILABLE', reason: after ? 'coefficients changed during placement: ' + after : 'read-back mismatch', ...receipt };
    const h2 = hostProfile();
    if (record.kind === 'LIVE') hostKey = h2.key;
    drawHostNote(h2); draw();
    return JSON.parse(JSON.stringify(placement));
  }
  /* v0.1.1 (Astra F1): receipt validity is separate from schedule invalidation. A PLACED receipt stays only while the
   * actual host still equals its read-back: base (mode, B, index), orbit (N, φ₃, slider, slider max), exact spin, the
   * coefficients t₁, t₂, n₆, α, and comb membership of every record tooth. Checked on every poll, every draw and every
   * diagnostic read. Clearing the receipt never regenerates the contact inventory; the record (LIVE or IMPORTED) stays. */
  function receiptDrift(p) {
    let h; try { h = liftSourceSnapshot(); } catch (e) { return 'host read failed: ' + e.message; }
    const rb = p.readBack, hc = p.hostCoefficients, bad = [];
    const mode = h.shellMode === 'integer' ? 'direct' : 'factorial', index = h.shellMode === 'factorial' ? h.n1 : null;
    if (mode !== rb.mode || h.shellBase !== rb.B || index !== rb.index) bad.push(`base ${mode === 'factorial' ? index + '!=' : 'M='}${h.shellBase} (placed ${rb.mode === 'factorial' ? rb.index + '!=' : 'M='}${rb.B})`);
    const slider = Number(phi3Slider.value), sliderMax = Number(phi3Slider.max);
    if (h.N !== rb.N || h.phi3 !== rb.phi3 || slider !== rb.slider || sliderMax !== rb.sliderMax) bad.push(`orbit N=${h.N} φ₃=${h.phi3} slider=${slider}/${sliderMax} (placed N=${rb.N} φ₃=${rb.phi3} slider=${rb.slider}/${rb.sliderMax})`);
    if (h.sExact !== rb.sExact) bad.push(`spin s=${h.sExact ?? '≈' + h.s} (placed s=${rb.sExact})`);
    for (const [k, label, v] of [['t1', 't₁', h.t1Exact], ['t2', 't₂', h.t2Exact], ['n6', 'n₆', String(h.n6)], ['alpha', 'α', String(h.alpha)]])
      if (v !== hc[k]) bad.push(`${label}=${v} (placed ${hc[k]})`);
    const offs = Number.isSafeInteger(h.m) ? new Set(combOffsets(h.m)) : new Set(), absent = p.recordTeeth.filter(c => !offs.has(c));
    if (absent.length) bad.push(`comb m=${h.m} lacks c=${absent.map(signTxt).join(', ')}`);
    return bad.join('; ');
  }
  /* v0.1.2: the single receipt-invalidation function. Whatever path calls it (poll, draw, status(), receipt()), a withdrawn
   * receipt is re-rendered at once through renderPlacement(), so diagnostics and the visible text can never disagree.
   * It reads the host only: no host write, no schedule regeneration, the record is kept. */
  function checkReceipt() {
    if (!placement || placement.status !== 'PLACED_EXACT_ADDRESS') return false;
    const drift = receiptDrift(placement);
    if (!drift) return false;
    receiptCleared = { event: placement.event, reason: 'host no longer matches the placement read-back: ' + drift, readBack: placement.readBack };
    placement = null;
    renderPlacement();
    return true;
  }
  /* v0.1.2: the single renderer of the placement view (#tc-placement); safe to call whether or not the panel is open. */
  function renderPlacement() {
    const pl = $('tc-placement'); if (!pl) return;
    pl.textContent = !placement && receiptCleared ? `Receipt cleared · ${receiptCleared.event} · ${receiptCleared.reason}. The record remains; place again to re-apply.` : placement ? ('Last host placement · ' + placement.status + (placement.status === 'PLACED_EXACT_ADDRESS'
      ? ` · ${placement.event} · B=${placement.readBack.B} N=${placement.readBack.N} φ₃=${placement.readBack.phi3} slider=${placement.readBack.slider}/${placement.readBack.sliderMax} s=${placement.readBack.sExact} · tooth phase ${placement.hostToothPhase}` + (placement.note ? ' · ' + placement.note : '')
      : ' · ' + placement.reason)) : 'Selection does not move the host. "Place selected contact on host" is the only host write.';
    pl.dataset.receipt = placement ? placement.status : receiptCleared ? 'CLEARED' : 'NONE';
  }
  function placeStationary(c) {
    const row = record && C.stationaryShells(record.config).find(s => s.tooth_c === String(c));
    const reason = row ? `stationary shell N=${row.shell_N} of tooth c=${signTxt(Number(c))} (k=0) is on the real axis for every s: there is no isolated event to place` : `no stationary shell for tooth c=${c} in this record`;
    placement = { status: 'HOST_PLACEMENT_UNAVAILABLE', reason: reason + '; no host write performed', event: null, hostWrite: false, stationary: row || null };
    draw(); return JSON.parse(JSON.stringify(placement));
  }
  document.addEventListener('click', e => {
    if (guard && e.target.closest?.('.export-bar button')) { e.stopImmediatePropagation(); e.preventDefault(); }
  }, true);

  /* ---------------- DOM ---------------- */
  const style = el('style');
  style.textContent = `
  #tc-toggle{margin-left:8px}
  #tc-panel{margin-top:12px;border:1px solid #2a2a44;border-radius:6px;padding:10px;background:var(--bg-inset);color:var(--text-bright);font-size:11px;max-width:100%;box-sizing:border-box}
  #tc-panel[hidden]{display:none}
  #tc-panel h3{margin:0 0 6px;font-size:12px;color:var(--accent-z1);font-weight:600}
  #tc-panel .tc-row{display:flex;flex-wrap:wrap;gap:6px;align-items:center;margin:4px 0}
  #tc-panel input[type=text]{width:7em;background:var(--bg-panel);color:var(--text-bright);border:1px solid #2a2a44;padding:2px 4px}
  #tc-panel #tc-teeth{width:12em}
  #tc-panel canvas{width:100%;height:64px;display:block;background:var(--bg-card);border:1px solid #1f1f33;cursor:crosshair}
  #tc-panel .tc-axis{color:var(--text-dim);font-size:10px;display:flex;justify-content:space-between}
  #tc-panel .tc-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:8px}
  #tc-panel .tc-box{border:1px solid #1f1f33;border-radius:4px;padding:6px;min-width:0;overflow-wrap:anywhere}
  #tc-panel .tc-status{font-weight:600}
  #tc-panel .COMPLETE{color:var(--accent-good)} #tc-panel .PARTIAL,#tc-panel .PAUSED,#tc-panel .RUNNING{color:var(--accent-warn)}
  #tc-panel .ERROR,#tc-panel .INCOMPATIBLE,#tc-panel .tc-bad{color:var(--accent-defend)}
  #tc-panel .tc-dim{color:var(--text-dim)}
  #tc-panel .tc-chip[aria-pressed=true]{outline:1px solid var(--accent-z1);color:var(--accent-z1)}
  #tc-table-wrap{max-height:220px;overflow:auto;border:1px solid #1f1f33}
  #tc-table{border-collapse:collapse;width:100%;font-variant-numeric:tabular-nums}
  #tc-table td,#tc-table th{padding:1px 6px;text-align:left;border-bottom:1px solid #1a1a2c;white-space:nowrap}
  #tc-table tr.sel{background:#10304a}
  #tc-table tr{cursor:pointer}`;
  document.head.append(style);
  const toggle = el('button', { id: 'tc-toggle', type: 'button', class: 'micro-button', 'aria-expanded': 'false', title: 'Opt-in exact per-tooth axis contacts of selected comb teeth (k = N + c)' }, '⋔ Tooth contacts');
  const sliderRow = $('s-direct-input').closest('.slider-row');
  sliderRow.querySelector('.s-direct-row').append(toggle);
  const root = el('section', { id: 'tc-panel', hidden: '', 'aria-label': 'Tooth contacts' });
  root.innerHTML = `
  <h3>Tooth contacts · selected comb teeth c · frequency k = N + c · exact signed axis contacts</h3>
  <div class="tc-row"><span class="tc-status" id="tc-status"></span><span id="tc-reason" class="tc-dim"></span></div>
  <div class="tc-row">
    <label for="tc-teeth">teeth c</label><input id="tc-teeth" type="text" value="-1, 1" aria-label="Selected tooth offsets">
    <button type="button" id="tc-teeth-apply">Apply teeth</button><button type="button" id="tc-teeth-all">All host teeth</button>
    <span id="tc-chips"></span>
  </div>
  <div class="tc-row">
    <label for="tc-q">Q</label><input id="tc-q" type="text" inputmode="numeric" value="24" aria-label="Shell bound Q">
    <button type="button" id="tc-q-apply">Apply Q</button>
    <button type="button" id="tc-play">▶ Play</button><button type="button" id="tc-reset">Reset</button>
    <button type="button" id="tc-prev" title="previous distinct exact event time">◀ Prev contact</button>
    <button type="button" id="tc-next" title="next distinct exact event time">Next contact ▶</button>
    <label for="tc-speed">pace</label><select id="tc-speed"><option value="60">slow · 60 s</option><option value="20" selected>20 s</option><option value="5">fast · 5 s</option></select>
  </div>
  <div class="tc-row">
    <label for="tc-seek">set S</label><input id="tc-seek" type="text" placeholder="24/23 or 1.25" aria-label="Exact cursor">
    <button type="button" id="tc-seek-apply">Seek</button><span id="tc-seek-note" class="tc-dim"></span>
  </div>
  <div id="tc-range" class="tc-dim"></div>
  <div class="tc-axis"><span>spin s = 0</span><span>event-time order (s, c, N, j) · collected contacts</span><span id="tc-tl-max"></span></div>
  <canvas id="tc-timeline" tabindex="0" aria-label="Exact spin timeline"></canvas>
  <div class="tc-axis"><span>x = 0</span><span>reduced address x = s/N · address order</span><span>x = 1</span></div>
  <canvas id="tc-rail" tabindex="0" aria-label="Rational address rail"></canvas>
  <div class="tc-grid">
    <div class="tc-box" id="tc-summary"></div>
    <div class="tc-box" id="tc-windows"></div>
    <div class="tc-box" id="tc-selected"></div>
    <div class="tc-box" id="tc-pair"></div>
  </div>
  <div class="tc-row">
    <button type="button" id="tc-place">Place selected contact on host</button>
    <label id="tc-base-wrap" hidden><input type="checkbox" id="tc-apply-base"> Apply record base first</label>
    <button type="button" id="tc-export">Export tooth-contact JSON</button>
    <label class="micro-button">Import tooth-contact JSON<input type="file" id="tc-import" accept="application/json,.json" hidden></label>
  </div>
  <div id="tc-placement" class="tc-dim"></div>
  <div id="tc-host-note" class="tc-dim"></div>
  <div id="tc-error" class="tc-bad" role="alert"></div>
  <div id="tc-cap" class="tc-dim"></div>
  <div id="tc-table-wrap"><table id="tc-table"><thead><tr><th>#</th><th>address a/b</th><th>≈ x</th><th>witnesses</th><th>per tooth c:n</th><th>right det</th></tr></thead><tbody></tbody></table></div>`;
  ($('bz-panel') || $('cs-panel') || sliderRow).after(root);

  function drawHostNote(profile) {
    const n = $('tc-host-note');
    if (!record || record.kind !== 'IMPORTED' || !profile) { n.textContent = ''; $('tc-base-wrap').hidden = true; $('tc-apply-base').checked = false; return; }
    const c = record.config, same = profile.base.mode === c.base_mode && String(profile.base.B) === c.base_B;
    n.textContent = `IMPORTED ${record.importName} · ATTACHED to this build (digest and build verified) · held (no live sweep) · host base ${same ? 'matches' : 'differs from'} record base.`;
    $('tc-base-wrap').hidden = same;
    if ($('tc-base-wrap').hidden) $('tc-apply-base').checked = false;
  }
  function sizeCanvas(cv) {
    const w = Math.max(100, cv.clientWidth), h = cv.clientHeight || 64, dpr = window.devicePixelRatio || 1;
    if (cv.width !== Math.round(w * dpr) || cv.height !== Math.round(h * dpr)) { cv.width = Math.round(w * dpr); cv.height = Math.round(h * dpr); }
    const g = cv.getContext('2d'); g.setTransform(dpr, 0, 0, dpr, 0, 0); g.clearRect(0, 0, w, h); return { g, w, h };
  }
  const css = name => getComputedStyle(document.documentElement).getPropertyValue(name).trim() || '#0ff';
  const toothColor = c => { const teeth = record ? record.config.teeth.map(Number) : panel.teeth, i = Math.max(0, teeth.indexOf(c)); return `hsl(${(190 + i * 137) % 360} 80% 62%)`; };
  function drawTimeline(p) {
    const cv = $('tc-timeline'), { g, w, h } = sizeCanvas(cv);
    if (!record) return;
    const Q = Qof(record), X = s => 4 + (w - 8) * (Number(s.n) / Number(s.d)) / (Q + 1);
    g.globalAlpha = 0.75;
    const byTooth = new Map();
    for (let i = 0; i < p; i++) { const r = record.rows[i]; let a = byTooth.get(r.c); if (!a) byTooth.set(r.c, a = []); a.push(X(r.s)); }
    for (const [c, xs] of byTooth) { g.strokeStyle = toothColor(c); g.beginPath(); for (const x of xs) { g.moveTo(x, h - 6); g.lineTo(x, h - 22); } g.stroke(); }
    g.globalAlpha = 1;
    const sel = selectedRow();
    if (sel) { g.strokeStyle = css('--accent-warn'); g.lineWidth = 2; g.beginPath(); g.moveTo(X(sel.s), 4); g.lineTo(X(sel.s), h - 4); g.stroke(); g.lineWidth = 1; }
    g.strokeStyle = css('--text-bright'); g.setLineDash([3, 3]); g.beginPath(); g.moveTo(X(record.cursor), 2); g.lineTo(X(record.cursor), h - 2); g.stroke(); g.setLineDash([]);
  }
  const visibleGroups = p => record.index.groups.filter(g => g.firstVisit < p);
  function drawRail(vis) {
    const cv = $('tc-rail'), { g, w, h } = sizeCanvas(cv);
    if (!record) return;
    const X = x => 4 + (w - 8) * Number(x.n) / Number(x.d);
    g.strokeStyle = css('--accent-z1'); g.beginPath();
    for (const q of vis) { const x = X(q.x), len = Math.max(3, (h - 10) / Math.sqrt(Number(q.x.d))); g.moveTo(x, h - 4); g.lineTo(x, h - 4 - len); }
    g.stroke();
    const sel = selectedRow();
    if (sel) { g.strokeStyle = css('--accent-warn'); g.lineWidth = 2; g.beginPath(); g.moveTo(X(sel.x), 2); g.lineTo(X(sel.x), h - 2); g.stroke(); g.lineWidth = 1; }
  }
  const inPrefix = (r, p) => record.index.eventPos.get(eventId(r)) < p;
  const neighborStatus = (complete, fullUnion) => complete ? (fullUnion ? 'FAREY_NEIGHBORS' : 'CONSECUTIVE_ONLY') : 'OBSERVED_ONLY';
  function hostProfileSafe() { try { return hostProfile(); } catch (_) { return null; } }
  function drawChips() {
    const box = $('tc-chips'); box.replaceChildren();
    let m; try { m = liftSourceSnapshot().m; } catch (_) { return; }
    if (!Number.isSafeInteger(m) || m > CHIP_MAX_M) { box.append(el('span', { class: 'tc-dim' }, `host comb m=${m}: type offsets`)); return; }
    for (const c of combOffsets(m)) {
      const b = el('button', { type: 'button', class: 'micro-button tc-chip', 'data-c': String(c), 'aria-pressed': String(panel.teeth.includes(c)), title: hidden(c) ? 'hidden by the host branch mask' : '' }, signTxt(c) + (hidden(c) ? '·h' : ''));
      box.append(b);
    }
    box.dataset.m = String(m);
  }
  function stamp(node, p) { node.dataset.epoch = String(epoch); node.dataset.cursor = record ? C.text(record.cursor) : ''; node.dataset.selected = selected ?? ''; node.dataset.prefix = String(p); }
  function draw() {
    if (!checkReceipt()) renderPlacement();          // v0.1.2: the placement view is current on every draw, open or closed
    if (!panel.open) return;
    const p = prefix(), Q = record ? Qof(record) : panel.Q;
    const status = $('tc-status'); status.textContent = panel.status; status.className = 'tc-status ' + panel.status;
    $('tc-reason').textContent = panel.reason || '';
    $('tc-error').textContent = panel.error || '';
    const live = record?.kind === 'LIVE';
    for (const id of ['tc-play', 'tc-prev', 'tc-next', 'tc-seek-apply']) $(id).disabled = !live;
    $('tc-play').textContent = frame !== null ? '⏸ Pause' : '▶ Play';
    $('tc-play').disabled = !live || panel.status === 'COMPLETE';
    $('tc-place').disabled = !record || selected === null;
    $('tc-export').disabled = !record;
    const profile = hostProfileSafe();
    drawHostNote(profile);
    const chipsM = $('tc-chips').dataset.m, chipsSig = JSON.stringify([profile?.m, panel.teeth, profile ? combOffsets(profile.m).filter(hidden) : []]);
    if ($('tc-chips').dataset.sig !== chipsSig || chipsM === undefined) { drawChips(); $('tc-chips').dataset.sig = chipsSig; }
    $('tc-range').textContent = `shells N = 2…${Q + 1} · span s ∈ [0, ${Q + 1}] · window 0 ≤ s ≤ N per shell · predicate k·s/N ∈ ℤ with k = N + c (not the M4 divisor encounter s/N ∈ ℤ) · event cap 102,400`;
    $('tc-tl-max').textContent = 's = ' + (Q + 1);
    drawTimeline(p);
    const vis = record ? visibleGroups(p) : [];
    drawRail(vis);
    const sum = $('tc-summary'); sum.replaceChildren(); stamp(sum, p);
    const winBox = $('tc-windows'); winBox.replaceChildren(); stamp(winBox, p);
    if (record) {
      const complete = C.compare(record.cursor, endOf(record)) === 0, teeth = record.config.teeth.map(Number), expected = C.expectedEventCount(Q, teeth);
      const W = C.windowSummaries(record.config), hiddenTeeth = teeth.filter(hidden);
      const lines = [
        ['coverage', complete ? 'COMPLETE' : 'PARTIAL'],
        ['cursor S', C.text(record.cursor) + (record.cursor.d === 1n ? '' : ' ≈ ' + approx(record.cursor))],
        ['witnesses', p + ' / ' + expected], ['distinct addresses', String(vis.length)], ['epoch', String(epoch)],
        ['host', record.kind === 'LIVE' ? 'LIVE · ' + SOURCE.host_build : 'IMPORTED · ' + record.source.host_build + ' · ATTACHED'],
        ['base', record.config.base_mode === 'factorial' ? record.config.factorial_index + '! = ' + record.config.base_B : 'M = ' + record.config.base_B],
        ['teeth', teeth.map(signTxt).join(', ') + ' of comb m=' + record.config.comb_m],
        ['drawn', hiddenTeeth.length ? `hidden by the host branch mask: c=${hiddenTeeth.map(signTxt).join(', ')} (collected, not drawn)` : 'all selected teeth visible on the host'],
        ['n₆ · α', record.config.n6 + ' · ' + record.config.alpha], ['schema', '0.1.0 (per-tooth contact)']];
      if (complete) lines.splice(1, 0, ['label', W.union.farey_status === 'FULL_FAREY' ? `F_${W.union.address_order} complete · |F_${W.union.address_order}| = ${vis.length}` : `complete sweep · union GAPPED (missing ${W.union.missing_denominators.join(', ')}) · CONSECUTIVE_ONLY, no Farey claim`]);
      else if (vis.length) lines.splice(1, 0, ['label', 'partial prefix · neighbours are observed only']);
      for (const [k, v] of lines) { const d = el('div'); d.append(el('span', { class: 'tc-dim' }, k + ': '), el('span', { class: k === 'coverage' ? v : '', 'data-field': k }, v)); sum.append(d); }
      winBox.append(el('div', { class: 'tc-dim' }, 'windows (complete-sweep properties, cursor independent)'));
      for (const w of W.teeth) {
        const c = Number(w.tooth_c);
        winBox.append(el('div', { 'data-tooth': w.tooth_c, 'data-status': w.farey_status }, `c=${signTxt(c)}: k ∈ [${w.frequency_min}, ${w.frequency_max}] · order ${w.address_order} · ${w.farey_status}` +
          (w.missing_denominators.length ? ` · missing ${w.missing_denominators.join(', ')}` : '') + ` · ${w.events_expected} events` + (hidden(c) ? ' · hidden on host' : '') + (c === 0 ? ' · c=0: contacts s ∈ ℤ, not the M4 register' : '')));
      }
      winBox.append(el('div', { 'data-union': W.union.farey_status }, `union: order ${W.union.address_order} · ${W.union.farey_status}` + (W.union.missing_denominators.length ? ` · missing ${W.union.missing_denominators.join(', ')}` : '')));
      const st = C.stationaryShells(record.config);
      if (st.length) for (const s of st) winBox.append(el('div', { class: 'tc-dim', 'data-stationary': s.tooth_c }, `STATIONARY_ON_AXIS: c=${signTxt(Number(s.tooth_c))}, N=${s.shell_N}, k=0, side ${s.axis_side} · reported, not counted · no isolated event to place`));
      else winBox.append(el('div', { class: 'tc-dim' }, 'no stationary shell in this window'));
    }
    const key = [String(epoch), p, selected, record ? C.text(record.cursor) : ''].join('|');
    if (key !== lastKey) { lastKey = key; drawSelection(p, vis); drawTable(p, vis); }
  }
  function drawSelection(p, vis) {
    const box = $('tc-selected'), pair = $('tc-pair'); box.replaceChildren(); pair.replaceChildren(); stamp(box, p); stamp(pair, p);
    const row = selectedRow();
    if (!row) { box.append(el('div', { class: 'tc-dim' }, 'No selection. Click the timeline, rail or table.')); pair.append(el('div', { class: 'tc-dim' }, 'Selected pair appears with a selection.')); return; }
    const grp = record.index.groups[record.index.pos.get(C.fractionId(row.x))];
    box.append(el('div', {}, `address x = ${C.fractionId(row.x)} ≈ ${approx(row.x)}`),
      el('div', {}, `selected witness ${selected}: tooth c=${signTxt(row.c)}, N=${row.N}, k=${row.k}, j=${row.j}, s=${C.text(row.s)}`),
      el('div', {}, `full phase k·s/N = ${row.k}·${C.text(row.s)}/${row.N} = ${row.j} · normalized s/N = ${C.fractionId(row.x)}`),
      el('div', {}, 'axis side: ' + (row.side === 'positive_real' ? 'positive real ray' : 'negative real ray') + (hidden(row.c) ? ' · tooth hidden by the host branch mask' : '')));
    if (row.c === 0) box.append(el('div', { class: 'tc-dim', 'data-m4': 'separate' }, `c=0 tooth contact: s = ${C.text(row.s)} ∈ ℤ. The M4 divisor register is separate: its encounter needs s/N ∈ ℤ, here s/N = ${C.fractionId(row.x)}${row.x.d === 1n ? ' ∈ ℤ' : ' ∉ ℤ'}.`));
    const wit = el('div'); const rows = grp.rows.filter(r => inPrefix(r, p));
    wit.append(el('span', { class: 'tc-dim' }, `collected witnesses (${rows.length}): `));
    rows.slice(0, 64).forEach(r => { const b = el('button', { type: 'button', class: 'micro-button' }, `(${r.c}, ${r.N}, ${r.j}, ${C.text(r.s)})`); b.onclick = () => guardUi(selectEvent)(eventId(r)); wit.append(b, ' '); });
    if (rows.length > 64) wit.append(el('span', { class: 'tc-dim' }, `… ${rows.length - 64} more (drawing cap)`));
    box.append(wit);
    const i = vis.indexOf(grp), complete = C.compare(record.cursor, endOf(record)) === 0, full = C.windowSummaries(record.config).union.farey_status === 'FULL_FAREY';
    for (const [label, other] of [['left', vis[i - 1]], ['right', vis[i + 1]]]) {
      if (!other) { pair.append(el('div', { class: 'tc-dim' }, label + ' neighbour: none (endpoint of collected list)')); continue; }
      const [l, r] = label === 'left' ? [other.x, grp.x] : [grp.x, other.x], det = l.d * r.n - l.n * r.d;
      pair.append(el('div', { 'data-status': neighborStatus(complete, full) }, `${label}: ${C.fractionId(l)} < ${C.fractionId(r)} · det = ${det} · b+d = ${l.d + r.d} · ${neighborStatus(complete, full)}`));
    }
  }
  function drawTable(p, vis) {
    const body = $('tc-table').tBodies[0]; body.replaceChildren(); stamp($('tc-table'), p);
    const row = selectedRow();
    let from = 0, to = vis.length;
    if (vis.length > TABLE_ALL) {
      const center = row ? vis.indexOf(record.index.groups[record.index.pos.get(C.fractionId(row.x))]) : 0;
      from = Math.max(0, Math.min(vis.length - TABLE_WINDOW, center - TABLE_WINDOW / 2)); to = Math.min(vis.length, from + TABLE_WINDOW);
      $('tc-cap').textContent = `Table drawing cap: rows ${from + 1}–${to} of ${vis.length} shown around the selection. Arithmetic records, rail, timeline and export contain all ${vis.length} addresses and ${p} witnesses.`;
    } else $('tc-cap').textContent = '';
    for (let i = from; i < to; i++) {
      const g = vis[i], next = vis[i + 1], tr = el('tr'), rows = g.rows.filter(r => inPrefix(r, p)), per = new Map();
      for (const r of rows) per.set(r.c, (per.get(r.c) || 0) + 1);
      if (row && C.compare(g.x, row.x) === 0) tr.className = 'sel';
      const det = next ? String(g.x.d * next.x.n - g.x.n * next.x.d) : '—';
      for (const t of [String(i + 1), C.fractionId(g.x), approx(g.x), String(rows.length), [...per.entries()].sort((a, b) => a[0] - b[0]).map(([c, n]) => c + ':' + n).join(' '), det]) tr.append(el('td', {}, t));
      tr.onclick = () => guardUi(selectEvent)(eventId(rows[0]));
      body.append(tr);
    }
  }
  function selectEvent(id) {
    C.need(record, 'selectEvent: no ready record');
    C.need(typeof id === 'string' && record.index.eventPos.has(id) && record.index.eventPos.get(id) < prefix(), 'selectEvent: not a collected event ' + id);
    if (placement && placement.event !== id) placement = null;
    selected = id; draw(); return id;
  }
  function pick(canvas, ev, kind) {
    if (!record) return;
    const rect = canvas.getBoundingClientRect(), px = ev.clientX - rect.left, w = rect.width, p = prefix();
    if (kind === 'rail') {
      let best = null, bd = Infinity;
      for (const g of visibleGroups(p)) { const d = Math.abs(4 + (w - 8) * Number(g.x.n) / Number(g.x.d) - px); if (d < bd) { bd = d; best = g; } }
      if (best) selectEvent(eventId(best.rows.find(r => inPrefix(r, p))));
    } else {
      const Q = Qof(record); let best = -1, bd = Infinity;
      for (let i = 0; i < p; i++) { const s = record.rows[i].s, d = Math.abs(4 + (w - 8) * (Number(s.n) / Number(s.d)) / (Q + 1) - px); if (d < bd) { bd = d; best = i; } }
      if (best >= 0) selectEvent(eventId(record.rows[best]));
    }
  }
  function applyTeeth(values) {
    C.need(Array.isArray(values) && values.length >= 1 && values.length <= 720 && values.every(Number.isSafeInteger), 'teeth: 1..720 integer offsets required');
    panel.teeth = [...new Set(values)].sort((a, b) => a - b);
    $('tc-teeth').value = panel.teeth.join(', ');
    hostKey = null; if (record?.kind === 'IMPORTED') record = null; poll();
  }
  const guardUi = fn => (...a) => { try { panel.error = null; return fn(...a); } catch (e) { panel.error = e.message; draw(); } };
  const ro = window.ResizeObserver ? new ResizeObserver(() => draw()) : null;
  toggle.onclick = () => {
    panel.open = !panel.open; root.hidden = !panel.open; toggle.setAttribute('aria-expanded', String(panel.open));
    if (panel.open) { hostKey = null; poll(); pollTimer = setInterval(poll, 250); if (ro) ro.observe(root); }
    else { clearInterval(pollTimer); pollTimer = null; stopPlay(); if (record) setStatus(); if (ro) ro.disconnect(); }
  };
  $('tc-q-apply').onclick = guardUi(() => {
    const t = $('tc-q').value.trim();
    C.need(/^[1-9][0-9]{0,2}$/.test(t) && +t <= C.MAX_Q, 'Q must be an integer 1…256');
    panel.Q = +t; hostKey = null; if (record?.kind === 'IMPORTED') record = null; poll();
  });
  $('tc-teeth-apply').onclick = guardUi(() => applyTeeth(C.parseTeethText($('tc-teeth').value)));
  $('tc-teeth-all').onclick = guardUi(() => applyTeeth(combOffsets(liftSourceSnapshot().m)));
  $('tc-chips').onclick = guardUi(e => {
    const b = e.target.closest?.('button.tc-chip'); if (!b) return;
    const c = Number(b.dataset.c), next = panel.teeth.includes(c) ? panel.teeth.filter(x => x !== c) : [...panel.teeth, c];
    C.need(next.length > 0, 'at least one tooth required'); applyTeeth(next);
  });
  for (const [id, btn] of [['tc-q', 'tc-q-apply'], ['tc-teeth', 'tc-teeth-apply'], ['tc-seek', 'tc-seek-apply']])
    $(id).addEventListener('keydown', e => { if (e.key === 'Enter') { e.preventDefault(); $(btn).click(); } });
  $('tc-play').onclick = guardUi(() => frame !== null ? pause() : play());
  $('tc-reset').onclick = guardUi(() => { if (record?.kind === 'IMPORTED') record = null; reset(); });
  $('tc-prev').onclick = guardUi(() => step(-1));
  $('tc-next').onclick = guardUi(() => step(1));
  $('tc-speed').onchange = () => { panel.speed = Number($('tc-speed').value); };
  $('tc-seek-apply').onclick = guardUi(() => {
    try { seekExact(C.parseRationalText($('tc-seek').value)); $('tc-seek-note').textContent = 'exact seek'; $('tc-seek-note').className = 'tc-dim'; }
    catch (e) { $('tc-seek-note').textContent = e.message; $('tc-seek-note').className = 'tc-bad'; throw e; }
  });
  $('tc-place').onclick = guardUi(() => placeSelected({ applySnapshotBase: $('tc-apply-base').checked }));
  $('tc-export').onclick = guardUi(exportSnapshot);
  $('tc-import').onchange = e => {
    const f = e.target.files[0]; e.target.value = '';                     // the File stays readable; the control is free again
    if (!f) return;
    const op = beginImport('file-input');                                  // token taken synchronously in the change event
    importFile(f, op).catch(() => { /* a refusal is reported in the panel by its owner; superseded operations stay silent */ });
  };
  $('tc-timeline').onclick = ev => guardUi(pick)($('tc-timeline'), ev, 'timeline');
  $('tc-rail').onclick = ev => guardUi(pick)($('tc-rail'), ev, 'rail');
  // Keyboard isolation (Basel audit F2 lesson): navigation keys pressed inside the panel never reach the host's
  // window shortcuts (←/→ step φ₃, Shift+←/→ step s). No preventDefault: native control behaviour is kept.
  const ISOLATED_KEYS = new Set(['ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown', 'Home', 'End', 'PageUp', 'PageDown']);
  root.addEventListener('keydown', e => { if (ISOLATED_KEYS.has(e.key)) e.stopPropagation(); });

  window.McombToothContactDiagnosticsV1 = Object.freeze({
    snapshot: () => JSON.parse(JSON.stringify(currentSnapshot())),
    exportText: () => exportText(),
    seek: ({ numerator, denominator }) => { seekExact(C.rational({ numerator, denominator })); return JSON.parse(JSON.stringify(currentSnapshot())); },
    reset: () => { if (record?.kind === 'IMPORTED') record = null; reset(); return { epoch: String(epoch), status: panel.status }; },
    selectEvent: id => selectEvent(id),
    place: (options = {}) => placeSelected(options),
    receipt: () => { checkReceipt(); return placement && JSON.parse(JSON.stringify(placement)); },
    placeStationary: c => placeStationary(c),
    importText: (textValue, name = 'diagnostic import') => { const op = beginImport('diagnostics importText'); return importBytes(new TextEncoder().encode(textValue), name, op); },
    importBytes: (bytes, name = 'diagnostic import') => { const op = beginImport('diagnostics importBytes'); return importBytes(bytes instanceof Uint8Array ? bytes : Uint8Array.from(bytes), name, op); },
    importLog: () => ({ latestOp: importSeq, events: JSON.parse(JSON.stringify(importEvents)) }),
    cancel: () => cancel(),
    status: () => { checkReceipt(); return {
      open: panel.open, status: panel.status, reason: panel.reason, error: panel.error, epoch: String(epoch), pending: !!pending, teeth: [...panel.teeth], Q: panel.Q,
      kind: record?.kind ?? null, attached: record?.attached ?? null, staleRejected, selected, running: frame !== null,
      cursor: record ? C.text(record.cursor) : null, placement: placement && JSON.parse(JSON.stringify(placement)),
      receiptCleared: receiptCleared && JSON.parse(JSON.stringify(receiptCleared)), build: { ...SOURCE } }; }
  });
})();
