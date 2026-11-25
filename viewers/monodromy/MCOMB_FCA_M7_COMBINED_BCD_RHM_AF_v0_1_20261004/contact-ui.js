/* Contact sweep 0.1 panel, host adapter and diagnostics for the M7 camera host.
 * The exact schedule comes from McombContactSweepCoreV1 in an epoch-tagged
 * worker. The host is read through liftSourceSnapshot/selectedShellBase and
 * written only by the explicit Show selected contact / canonical preset
 * actions. Floating values are used for drawing only. */
(() => {
  'use strict';
  const C = window.McombContactSweepCoreV1, V = window.McombContactSweepValidateV1, PINS = window.McombContactSweepBuildPins;
  if (!C || !V || !PINS) throw Error('Contact sweep modules missing');
  const SOURCE = Object.freeze({ host_build: PINS.hostBuild, host_sha256: PINS.hostSha256 });
  const TICKS = 240n;                                    // exact play increment 1/240 in s
  const TABLE_ALL = 400, TABLE_WINDOW = 200;             // display caps only
  const $ = id => document.getElementById(id);
  const el = (tag, attrs = {}, text = null) => { const e = document.createElement(tag); for (const [k, v] of Object.entries(attrs)) e.setAttribute(k, v); if (text !== null) e.textContent = text; return e; };
  const approx = r => (Number(r.n) / Number(r.d)).toPrecision(8).replace(/\.?0+$/, '');
  const R = (n, d = 1n) => C.reduce(BigInt(n), BigInt(d));
  const eventId = r => r.N + ':' + r.j;

  let epoch = 0n, staleRejected = 0, worker = null, pending = null, pollTimer = null, frame = null;
  const panel = { open: false, Q: 24, speed: 20, status: 'INCOMPATIBLE', reason: 'panel closed', error: null };
  let record = null;       // { kind, config, source, rows, cursor, attached, index, hostKey, importName }
  let lastKey = null, selected = null, hostKey = null, placement = null, guard = false, lastTime = 0, acc = 0;

  /* ---------------- host read seam ---------------- */
  function hostProfile() {
    const h = liftSourceSnapshot(), B = h.shellBase;
    const base = { mode: h.shellMode === 'integer' ? 'direct' : 'factorial', B, index: h.shellMode === 'factorial' ? h.n1 : null };
    const out = { base, n6: h.n6, alpha: h.alpha, m: h.m, t1: h.t1Exact, t2: h.t2Exact, config: null, reason: null, presetFixable: false };
    const Q = panel.Q;
    if (!Number.isSafeInteger(B)) out.reason = 'host base is not an exact safe integer';
    else if (base.mode === 'direct' && (B < C.DIRECT_BASE_MIN || B > C.DIRECT_BASE_MAX)) out.reason = `host direct base M=${B} is outside the contact profile 2..1,000,000 (host range is wider; not clamped)`;
    else if (base.mode === 'factorial' && (h.n1 < C.FACTORIAL_INDEX_MIN || h.n1 > C.FACTORIAL_INDEX_MAX)) out.reason = `host factorial index ${h.n1}! is outside the contact profile 3..8 (host offers 3..13; not clamped)`;
    else if (Q > B) out.reason = `Q=${Q} exceeds host base B=${B}; choose Q ≤ B`;
    else if (!Number.isSafeInteger(h.m) || h.m < C.COMB_M_MIN || h.m > C.COMB_M_MAX) out.reason = `host comb order m=${h.m} is outside 2..720`;
    else if (h.t1Exact !== '1' || h.t2Exact !== '1') { out.reason = `canonical coefficients t₁=t₂=1 required for the c=−1 contact set k=N−1; host has t₁=${h.t1Exact}, t₂=${h.t2Exact}`; out.presetFixable = true; }
    else if (h.n6 === 0) out.reason = 'zero radius (n₆=0) is refused: no axis side exists';
    else if (h.n6 !== 1 && h.n6 !== -1) out.reason = `radius sign n₆=${h.n6} is outside the exact profile {−1,+1}`;
    else if (![-1, 0, 1].includes(h.alpha)) out.reason = `radial exponent α=${h.alpha} is outside the exact profile {−1,0,1}`;
    if (!out.reason) {
      out.config = C.configuration(Q, { B, factorialIndex: base.index, n6: String(h.n6), alpha: String(h.alpha), m: String(h.m) });
      C.checkConfig(out.config);
    }
    out.key = JSON.stringify([Q, base, h.n6, h.alpha, h.m, h.t1Exact, h.t2Exact]);
    return out;
  }

  /* ---------------- epochs, worker, generation ---------------- */
  function workerInstance() {
    if (worker) return worker;
    const url = URL.createObjectURL(new Blob([window.McombContactSweepWorkerSource], { type: 'text/javascript' }));
    worker = new Worker(url); URL.revokeObjectURL(url);
    worker.onmessage = ev => {
      const msg = ev.data;
      if (!pending || msg.epoch !== pending.epoch || String(epoch) !== msg.epoch) { staleRejected++; return; }
      const job = pending; pending = null;
      if (msg.error) { panel.status = 'ERROR'; panel.error = 'Generation failed: ' + msg.error; draw(); return; }
      const rows = msg.rows, Q = C.checkConfig(job.config);
      if (rows.length !== Q * (Q + 3) / 2) { panel.status = 'ERROR'; panel.error = 'Worker returned an incomplete schedule'; draw(); return; }
      record = { kind: 'LIVE', config: job.config, source: SOURCE, rows, cursor: R(0), attached: true, hostKey: job.hostKey, index: indexRows(rows) };
      selected = null; panel.error = null; setStatus(); draw();
    };
    worker.onerror = e => { if (pending) { pending = null; panel.status = 'ERROR'; panel.error = 'Worker error: ' + (e.message || 'unknown'); draw(); } };
    return worker;
  }
  function bump() { epoch += 1n; return String(epoch); }
  function stopPlay() { if (frame !== null) cancelAnimationFrame(frame); frame = null; }
  function generate(profile) {
    stopPlay();
    const e = bump();
    record = null; selected = null; placement = null; panel.error = null;
    pending = { epoch: e, config: profile.config, hostKey: profile.key };
    panel.status = 'READY'; panel.reason = 'generating exact schedule…';
    workerInstance().postMessage({ epoch: e, config: profile.config });
    draw();
  }
  function cancel() {
    stopPlay();
    const hadPending = !!pending;
    bump();
    if (pending) { pending = null; worker?.terminate(); worker = null; }
    if (hadPending) placement = null;
    if (hadPending) { panel.status = 'ERROR'; panel.error = 'Generation cancelled; Reset starts a new epoch.'; }
    else setStatus();
    draw();
    return { cancelled: hadPending, epoch: String(epoch) };
  }
  /* Precomputed address index of the full schedule: address order and first visit. */
  function indexRows(rows) {
    const all = C.groups(rows), pos = new Map(), eventPos = new Map();
    rows.forEach((r, i) => eventPos.set(eventId(r), i));
    all.forEach((g, i) => { pos.set(C.fractionId(g.x), i); g.firstVisit = eventPos.get(eventId(g.rows[0])); });
    const timeIndex = [], times = [];
    rows.forEach((r, i) => { if (!times.length || C.compare(times[times.length - 1], r.s) !== 0) { times.push(r.s); timeIndex.push(i); } });
    return { groups: all, pos, eventPos, times, timeIndex };
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
    let profile;
    try { profile = hostProfile(); } catch (e) { panel.status = 'ERROR'; panel.error = 'Host read failed: ' + e.message; draw(); return; }
    if (profile.key === hostKey) { if (record?.kind === 'IMPORTED') drawHostNote(profile); return; }
    hostKey = profile.key;
    if (record?.kind === 'IMPORTED') { drawHostNote(profile); return; }
    invalidate(profile);
  }
  function invalidate(profile) {
    stopPlay();
    if (pending) { pending = null; }
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
    if (placement && placement.event !== selected) placement = null;   // receipt bound to its selected event
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
      if (C.compare(next, R(Q + 1)) >= 0) next = R(Q + 1);            // stop at the end, no wrap
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
    if (record?.kind === 'LIVE' && panel.open) poll();   // never export against a stale host reading
    if (!record) throw new C.ContractError('snapshot: no ready record (' + panel.status + ')');
    const snap = C.snapshot(record.config, record.cursor, record.source, { epoch: String(epoch), selected, rows: record.rows });
    V.validateSnapshot(snap, { expectedHostSha256: record.kind === 'LIVE' ? SOURCE.host_sha256 : null });
    return JSON.parse(JSON.stringify(snap));
  }
  async function importFile(file) {
    const bytes = new Uint8Array(await file.arrayBuffer());
    return importBytes(bytes, file.name);
  }
  function importBytes(bytes, name = 'import') {
    let data;
    try { data = V.loadSnapshotBytes(bytes); }
    catch (e) { panel.error = 'Import rejected; previous state retained. ' + e.message; drawError(); throw e; }
    let attached = true, attachReason = null;
    try { V.semantics(data, SOURCE.host_sha256); }
    catch (e) { attached = false; attachReason = e.message; }
    stopPlay(); if (pending) pending = null;
    const rows = C.schedule(data.config);
    bump();
    record = { kind: 'IMPORTED', config: data.config, source: data.source, rows, cursor: C.rational(data.position.cursor_s),
      attached, attachReason, importName: String(name).slice(0, 200), index: indexRows(rows) };
    selected = data.selected_event_id; placement = null; panel.error = null; setStatus();
    draw(); drawHostNote(hostProfile());
    return { attached, reason: attachReason, epoch: String(epoch) };
  }
  function exportSnapshot() {
    const snap = currentSnapshot(), text = JSON.stringify(snap, null, 2) + '\n';
    const blob = new Blob([text], { type: 'application/json' }), a = el('a');
    a.href = URL.createObjectURL(blob);
    a.download = `contact-sweep-Q${snap.config.Q}-S${C.text(record.cursor).replace('/', '_')}-B${snap.config.base_B}.json`;
    document.body.append(a); a.click(); a.remove(); setTimeout(() => URL.revokeObjectURL(a.href), 1000);
    return snap;
  }

  /* ---------------- host placement ---------------- */
  function selectedRow() { return selected === null ? null : record.rows[record.index.eventPos.get(selected)]; }
  function showSelectedContact({ applySnapshotBase = false } = {}) {
    const fail = reason => { placement = { status: 'HOST_PLACEMENT_UNAVAILABLE', reason, event: selected }; draw(); return { ...placement }; };
    if (record?.kind === 'LIVE') poll();                 // never place against a stale host reading
    if (!record) return fail('no ready record');
    const row = selectedRow();
    if (!row) return fail('no selected contact');
    if (!record.attached) return fail('offline snapshot: ' + (record.attachReason || 'host digest differs'));
    const cfg = record.config, B = Number(cfg.base_B), index = cfg.factorial_index === null ? null : Number(cfg.factorial_index);
    // 0.1.1 repair (audit F1): the record's comb, coefficients, radius sign and
    // exponent must equal the current host before any write. Build identity and
    // base do not establish them. Coefficient changes stay a separate explicit action.
    const mismatch = coefficientMismatch(cfg);
    if (mismatch) return fail('host coefficients do not realize this contact: ' + mismatch + '; no host write performed');
    const h = hostProfile().base, sameBase = h.mode === cfg.base_mode && h.B === B && h.index === index;
    if (!sameBase && !applySnapshotBase) return fail(`snapshot base ${cfg.base_mode === 'factorial' ? index + '!=' : 'M='}${B} differs from host base; choose Apply snapshot base`);
    const sText = C.text(row.s), receipt = { event: selected, N: row.N, sExact: sText, pausedHost: [] };
    guard = true;
    try {
      if (state.isAnimating) { toggleAnim('phi3'); receipt.pausedHost.push('phi3'); }
      if (state.isAnimatingS) { toggleAnim('s'); receipt.pausedHost.push('s'); }
      if (!sameBase) { applySelectedShell(cfg.base_mode === 'factorial' ? { mode: 'factorial', n1: index } : { mode: 'integer', directBase: B }); receipt.baseChanged = true; }
      const hostB = selectedShellBase();
      state.phi3 = hostB + 1 - row.N;
      phi3Slider.value = String(row.N);
      updateStepperState(); updateSSliderRange();
      setSValue(Number(row.s.n) / Number(row.s.d), sText, 'contact ' + selected);
    } catch (e) { guard = false; return fail('host write failed: ' + e.message); }
    guard = false;
    const hb = selectedShellBase(), read = { mode: state.shellMode === 'integer' ? 'direct' : 'factorial', B: hb, index: state.shellMode === 'factorial' ? state.n1 : null,
      N: currentN(), phi3: state.phi3, slider: Number(phi3Slider.value), sliderMax: Number(phi3Slider.max), sExact: state.sExact };
    receipt.readBack = read;
    const after = coefficientMismatch(cfg), phase = hostLowerPhase(read.N, read.sExact);
    receipt.hostLowerPhase = phase; receipt.coefficients = after ? 'MISMATCH: ' + after : 'MATCH';
    const ok = read.mode === cfg.base_mode && read.B === B && read.index === index && read.N === row.N && read.phi3 === B + 1 - row.N &&
      read.slider === row.N && read.sliderMax === B + 1 && read.sExact === sText && !after && phase === String(row.j);
    placement = ok ? { status: 'PLACED_EXACT_ADDRESS', ...receipt } : { status: 'HOST_PLACEMENT_UNAVAILABLE', reason: after ? 'coefficients changed during placement: ' + after : 'read-back mismatch', ...receipt };
    const h2 = hostProfile();
    hostKey = record.kind === 'LIVE' ? h2.key : hostKey;
    drawHostNote(h2); draw();
    return JSON.parse(JSON.stringify(placement));
  }
  /* Exact host fields the contact depends on, compared with the record's config. */
  function coefficientMismatch(cfg) {
    const h = liftSourceSnapshot(), bad = [];
    if (h.t1Exact !== cfg.t1) bad.push(`t₁=${h.t1Exact} (record ${cfg.t1})`);
    if (h.t2Exact !== cfg.t2) bad.push(`t₂=${h.t2Exact} (record ${cfg.t2})`);
    if (String(h.n6) !== cfg.n6) bad.push(`n₆=${h.n6} (record ${cfg.n6})`);
    if (String(h.alpha) !== cfg.alpha) bad.push(`α=${h.alpha} (record ${cfg.alpha})`);
    return bad.join(', ');
  }
  /* Host lower-tooth half-turn phase (N·t₁−t₂)·s/N from exact host strings, reduced text. */
  function hostLowerPhase(N, sExact) {
    try {
      const q = t => { const [a, b = '1'] = String(t).split('/'); return { n: BigInt(a), d: BigInt(b) }; };
      const h = liftSourceSnapshot(), t1 = q(h.t1Exact), t2 = q(h.t2Exact), s = q(sExact), bN = BigInt(N);
      const kn = bN * t1.n * t2.d - t2.n * t1.d, kd = t1.d * t2.d;
      let n = kn * s.n, d = kd * s.d * bN; if (d < 0n) { n = -n; d = -d; }
      const g = C.gcd(n, d) || 1n; n /= g; d /= g;
      return d === 1n ? String(n) : n + '/' + d;
    } catch (_) { return null; }
  }
  function applyCanonicalPreset() {
    // Explicit user action only: t1=t2=1. Comb m, base, shell and radius are untouched.
    commitGearboxRational('t1', '1'); commitGearboxRational('t2', '1');
    poll();
  }
  // Intermediate host states are never exported: placement is one synchronous
  // task, and this capture guard refuses export clicks should one re-enter.
  document.addEventListener('click', e => {
    if (guard && e.target.closest?.('.export-bar button')) { e.stopImmediatePropagation(); e.preventDefault(); }
  }, true);

  /* ---------------- DOM ---------------- */
  const style = el('style');
  style.textContent = `
  #cs-toggle{margin-left:8px}
  #cs-panel{margin-top:12px;border:1px solid #2a2a44;border-radius:6px;padding:10px;background:var(--bg-inset);color:var(--text-bright);font-size:11px;max-width:100%;box-sizing:border-box}
  #cs-panel[hidden]{display:none}
  #cs-panel h3{margin:0 0 6px;font-size:12px;color:var(--accent-z1);font-weight:600}
  #cs-panel .cs-row{display:flex;flex-wrap:wrap;gap:6px;align-items:center;margin:4px 0}
  #cs-panel input[type=text]{width:7em;background:var(--bg-panel);color:var(--text-bright);border:1px solid #2a2a44;padding:2px 4px}
  #cs-panel canvas{width:100%;height:64px;display:block;background:var(--bg-card);border:1px solid #1f1f33;cursor:crosshair}
  #cs-panel .cs-axis{color:var(--text-dim);font-size:10px;display:flex;justify-content:space-between}
  #cs-panel .cs-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:8px}
  #cs-panel .cs-box{border:1px solid #1f1f33;border-radius:4px;padding:6px;min-width:0;overflow-wrap:anywhere}
  #cs-panel .cs-status{font-weight:600}
  #cs-panel .COMPLETE{color:var(--accent-good)} #cs-panel .PARTIAL,#cs-panel .PAUSED,#cs-panel .RUNNING{color:var(--accent-warn)}
  #cs-panel .ERROR,#cs-panel .INCOMPATIBLE,#cs-panel .cs-bad{color:var(--accent-defend)}
  #cs-panel .cs-dim{color:var(--text-dim)}
  #cs-table-wrap{max-height:220px;overflow:auto;border:1px solid #1f1f33}
  #cs-table{border-collapse:collapse;width:100%;font-variant-numeric:tabular-nums}
  #cs-table td,#cs-table th{padding:1px 6px;text-align:left;border-bottom:1px solid #1a1a2c;white-space:nowrap}
  #cs-table tr.sel{background:#10304a}
  #cs-table tr{cursor:pointer}`;
  document.head.append(style);
  const toggle = el('button', { id: 'cs-toggle', type: 'button', class: 'micro-button', 'aria-expanded': 'false', title: 'Opt-in exact lower-tooth axis contact collector' }, '◎ Contact sweep');
  const host = $('s-direct-input').closest('.slider-row');
  host.querySelector('.s-direct-row').append(toggle);
  const root = el('section', { id: 'cs-panel', hidden: '', 'aria-label': 'Contact sweep' });
  root.innerHTML = `
  <h3>Contact sweep · branch c=−1 · tooth k=N−1 · exact axis contacts</h3>
  <div class="cs-row"><span class="cs-status" id="cs-status"></span><span id="cs-reason" class="cs-dim"></span></div>
  <div class="cs-row">
    <label for="cs-q">Q</label><input id="cs-q" type="text" inputmode="numeric" value="24" aria-label="Shell bound Q">
    <button type="button" id="cs-q-apply">Apply Q</button>
    <button type="button" id="cs-play">▶ Play</button><button type="button" id="cs-reset">Reset</button>
    <button type="button" id="cs-prev" title="previous distinct exact event time">◀ Prev contact</button>
    <button type="button" id="cs-next" title="next distinct exact event time">Next contact ▶</button>
    <label for="cs-speed">pace</label><select id="cs-speed"><option value="60">slow · 60 s</option><option value="20" selected>20 s</option><option value="5">fast · 5 s</option></select>
  </div>
  <div class="cs-row">
    <label for="cs-seek">set S</label><input id="cs-seek" type="text" placeholder="24/23 or 1.25" aria-label="Exact cursor">
    <button type="button" id="cs-seek-apply">Seek</button>
    <button type="button" id="cs-preset" hidden>Apply canonical coefficients (t₁=t₂=1)</button>
    <span id="cs-seek-note" class="cs-dim"></span>
  </div>
  <div id="cs-range" class="cs-dim"></div>
  <div class="cs-axis"><span>spin s = 0</span><span>event-time order · collected contact groups</span><span id="cs-tl-max"></span></div>
  <canvas id="cs-timeline" aria-label="Exact spin timeline"></canvas>
  <div class="cs-axis"><span>x = 0</span><span>reduced address x = s/N · address order</span><span>x = 1</span></div>
  <canvas id="cs-rail" aria-label="Rational address rail"></canvas>
  <div class="cs-grid">
    <div class="cs-box" id="cs-summary"></div>
    <div class="cs-box" id="cs-selected"></div>
    <div class="cs-box" id="cs-pair"></div>
  </div>
  <div class="cs-row">
    <button type="button" id="cs-show">Show selected contact</button>
    <label id="cs-base-wrap" hidden><input type="checkbox" id="cs-apply-base"> Apply snapshot base first</label>
    <button type="button" id="cs-export">Export contact JSON</button>
    <label class="micro-button">Import contact JSON<input type="file" id="cs-import" accept="application/json,.json" hidden></label>
  </div>
  <div id="cs-placement" class="cs-dim"></div>
  <div id="cs-host-note" class="cs-dim"></div>
  <div id="cs-error" class="cs-bad" role="alert"></div>
  <div id="cs-cap" class="cs-dim"></div>
  <div id="cs-table-wrap"><table id="cs-table"><thead><tr><th>#</th><th>address a/b</th><th>≈ x</th><th>witnesses</th><th>right neighbor det</th></tr></thead><tbody></tbody></table></div>`;
  host.after(root);

  function drawError() { $('cs-error').textContent = panel.error || ''; }
  function drawHostNote(profile) {
    const n = $('cs-host-note');
    if (!record || record.kind !== 'IMPORTED') { n.textContent = ''; $('cs-base-wrap').hidden = true; $('cs-apply-base').checked = false; return; }
    const c = record.config, same = profile.base.mode === c.base_mode && String(profile.base.B) === c.base_B;
    n.textContent = `IMPORTED ${record.importName} · ${record.attached ? 'ATTACHED to this build' : 'OFFLINE inspection · ' + record.attachReason} · held (no live sweep) · host base ${same ? 'matches' : 'differs from'} snapshot base.`;
    $('cs-base-wrap').hidden = same || !record.attached;
    if ($('cs-base-wrap').hidden) $('cs-apply-base').checked = false;   // a base change is never carried over
  }
  function sizeCanvas(cv) {
    const w = Math.max(100, cv.clientWidth), h = cv.clientHeight || 64, dpr = window.devicePixelRatio || 1;
    if (cv.width !== Math.round(w * dpr) || cv.height !== Math.round(h * dpr)) { cv.width = Math.round(w * dpr); cv.height = Math.round(h * dpr); }
    const g = cv.getContext('2d'); g.setTransform(dpr, 0, 0, dpr, 0, 0); g.clearRect(0, 0, w, h); return { g, w, h };
  }
  const css = name => getComputedStyle(document.documentElement).getPropertyValue(name).trim() || '#0ff';
  function drawTimeline(p) {
    const cv = $('cs-timeline'), { g, w, h } = sizeCanvas(cv);
    if (!record) return;
    const Q = Qof(record), X = s => 4 + (w - 8) * (Number(s.n) / Number(s.d)) / (Q + 1);
    g.strokeStyle = css('--accent-z1'); g.globalAlpha = 0.75; g.beginPath();
    for (let i = 0; i < p; i++) { const x = X(record.rows[i].s); g.moveTo(x, h - 6); g.lineTo(x, h - 22); }
    g.stroke(); g.globalAlpha = 1;
    const origins = Math.min(p, Q);
    if (origins) { g.fillStyle = css('--accent-z1'); g.fillText('×' + origins, 6, 12); }
    const sel = selectedRow();
    if (sel) { g.strokeStyle = css('--accent-warn'); g.lineWidth = 2; g.beginPath(); g.moveTo(X(sel.s), 4); g.lineTo(X(sel.s), h - 4); g.stroke(); g.lineWidth = 1; }
    g.strokeStyle = css('--text-bright'); g.setLineDash([3, 3]); g.beginPath(); g.moveTo(X(record.cursor), 2); g.lineTo(X(record.cursor), h - 2); g.stroke(); g.setLineDash([]);
  }
  function visibleGroups(p) { return record.index.groups.filter(g => g.firstVisit < p); }
  function drawRail(vis) {
    const cv = $('cs-rail'), { g, w, h } = sizeCanvas(cv);
    if (!record) return;
    const X = x => 4 + (w - 8) * Number(x.n) / Number(x.d);
    g.strokeStyle = css('--accent-z1'); g.beginPath();
    for (const q of vis) { const x = X(q.x), len = Math.max(3, (h - 10) / Math.sqrt(Number(q.x.d))); g.moveTo(x, h - 4); g.lineTo(x, h - 4 - len); }
    g.stroke();
    const sel = selectedRow();
    if (sel) { g.strokeStyle = css('--accent-warn'); g.lineWidth = 2; g.beginPath(); g.moveTo(X(sel.x), 2); g.lineTo(X(sel.x), h - 2); g.stroke(); g.lineWidth = 1; }
  }
  const countIn = (grp, p) => grp.rows.filter(r => record.index.eventPos.get(eventId(r)) < p).length;
  function draw() {
    if (!panel.open) return;
    const p = prefix(), Q = record ? Qof(record) : panel.Q;
    const status = $('cs-status'); status.textContent = panel.status; status.className = 'cs-status ' + panel.status;
    $('cs-reason').textContent = panel.reason || '';
    drawError();
    const live = record?.kind === 'LIVE';
    for (const id of ['cs-play', 'cs-prev', 'cs-next', 'cs-seek-apply']) $(id).disabled = !live;
    $('cs-play').textContent = frame !== null ? '⏸ Pause' : '▶ Play';
    $('cs-play').disabled = !live || (panel.status === 'COMPLETE');
    $('cs-show').disabled = !record || selected === null;
    $('cs-export').disabled = !record;
    const profile = hostProfileSafe();
    $('cs-preset').hidden = !(panel.status === 'INCOMPATIBLE' && profile?.presetFixable);
    if (profile) drawHostNote(profile);
    $('cs-range').textContent = `shells N = 2…${Q + 1} · collection span s ∈ [0, ${Q + 1}] · window 0 ≤ s ≤ N per shell · predicate k·s/N ∈ ℤ (not the divisor encounter s/N ∈ ℤ)`;
    $('cs-tl-max').textContent = 's = ' + (Q + 1);
    drawTimeline(p);
    const vis = record ? visibleGroups(p) : [];
    drawRail(vis);
    const sum = $('cs-summary'); sum.replaceChildren();
    if (record) {
      const complete = C.compare(record.cursor, endOf(record)) === 0, expected = Q * (Q + 3) / 2;
      const lines = [
        ['coverage', complete ? 'COMPLETE' : 'PARTIAL'],
        ['cursor S', C.text(record.cursor) + (record.cursor.d === 1n ? '' : ' ≈ ' + approx(record.cursor))],
        ['witnesses', p + ' / ' + expected], ['distinct addresses', String(vis.length)],
        ['epoch', String(epoch)], ['host', record.kind === 'LIVE' ? 'LIVE · ' + SOURCE.host_build : 'IMPORTED · ' + record.source.host_build],
        ['base', record.config.base_mode === 'factorial' ? record.config.factorial_index + '! = ' + record.config.base_B : 'M = ' + record.config.base_B],
        ['branch', 'c=−1 of comb m=' + record.config.comb_m + ' · other teeth stay visible, not collected'],
        ['n₆ · α', record.config.n6 + ' · ' + record.config.alpha], ['schema', record.config.comb_m === '2' ? '0.2.0 (sealed contract)' : '0.3.0 (comb order widened)']];
      if (complete) lines.splice(1, 0, ['label', `F_${Q} complete · |F_${Q}| = ${vis.length}`]);
      else if (vis.length && p < expected) lines.splice(1, 0, ['label', 'partial prefix · neighbors are observed only']);
      for (const [k, v] of lines) { const d = el('div'); d.append(el('span', { class: 'cs-dim' }, k + ': '), el('span', { class: k === 'coverage' ? v : '' }, v)); sum.append(d); }
    }
    const key = [String(epoch), p, selected, record ? C.text(record.cursor) : ''].join('|');
    if (key !== lastKey) { lastKey = key; drawSelection(p, vis); drawTable(p, vis); }
    const pl = $('cs-placement');
    pl.textContent = placement ? ('Last host placement · ' + placement.status + (placement.status === 'PLACED_EXACT_ADDRESS'
      ? ` · ${placement.event} · B=${placement.readBack.B} N=${placement.readBack.N} φ₃=${placement.readBack.phi3} slider=${placement.readBack.slider}/${placement.readBack.sliderMax} s=${placement.readBack.sExact}` + (placement.note ? ' · ' + placement.note : '')
      : ' · ' + placement.reason)) : 'Selection does not move the host. Show selected contact is the only host write.';
  }
  function hostProfileSafe() { try { return hostProfile(); } catch (_) { return null; } }
  function drawSelection(p, vis) {
    const box = $('cs-selected'), pair = $('cs-pair'); box.replaceChildren(); pair.replaceChildren();
    const row = record && selectedRow();
    if (!row) { box.append(el('div', { class: 'cs-dim' }, 'No selection. Click the timeline, rail or table.')); pair.append(el('div', { class: 'cs-dim' }, 'Selected pair appears with a selection.')); return; }
    const grp = record.index.groups[record.index.pos.get(C.fractionId(row.x))], k = row.N - 1;
    box.append(el('div', {}, `address x = ${C.fractionId(row.x)} ≈ ${approx(row.x)}`),
      el('div', {}, `selected witness ${selected}: N=${row.N}, k=${k}, j=${row.j}, s=${C.text(row.s)}`),
      el('div', {}, `full phase k·s/N = ${k}·${C.text(row.s)}/${row.N} = ${row.j} · normalized s/N = ${C.fractionId(row.x)}`),
      el('div', {}, 'axis side: ' + (row.side > 0 ? 'positive real ray' : 'negative real ray')));
    const wit = el('div'); wit.append(el('span', { class: 'cs-dim' }, `collected witnesses (${countIn(grp, p)}): `));
    grp.rows.filter(r => record.index.eventPos.get(eventId(r)) < p).forEach(r => {
      const b = el('button', { type: 'button', class: 'micro-button' }, `(${r.N}, ${r.j}, ${C.text(r.s)})`);
      b.onclick = () => { selectEvent(eventId(r)); }; wit.append(b, ' ');
    });
    box.append(wit);
    const i = vis.indexOf(grp), complete = record && C.compare(record.cursor, endOf(record)) === 0;
    for (const [label, other] of [['left', vis[i - 1]], ['right', vis[i + 1]]]) {
      if (!other) { pair.append(el('div', { class: 'cs-dim' }, label + ' neighbor: none (endpoint of collected list)')); continue; }
      const [l, r] = label === 'left' ? [other.x, grp.x] : [grp.x, other.x], det = l.d * r.n - l.n * r.d;
      pair.append(el('div', {}, `${label}: ${C.fractionId(l)} < ${C.fractionId(r)} · det b·c−a·d = ${det} · b+d = ${l.d + r.d} · ${complete ? 'FAREY_NEIGHBORS' : 'OBSERVED_ONLY'}`));
    }
  }
  function drawTable(p, vis) {
    const body = $('cs-table').tBodies[0]; body.replaceChildren();
    const row = record && selectedRow();
    let from = 0, to = vis.length;
    if (vis.length > TABLE_ALL) {
      const center = row ? vis.indexOf(record.index.groups[record.index.pos.get(C.fractionId(row.x))]) : 0;
      from = Math.max(0, Math.min(vis.length - TABLE_WINDOW, center - TABLE_WINDOW / 2)); to = Math.min(vis.length, from + TABLE_WINDOW);
      $('cs-cap').textContent = `Table drawing cap: rows ${from + 1}–${to} of ${vis.length} shown around the selection. Arithmetic records, rail, timeline and export contain all ${vis.length} addresses and ${p} witnesses.`;
    } else $('cs-cap').textContent = '';
    for (let i = from; i < to; i++) {
      const g = vis[i], next = vis[i + 1], tr = el('tr');
      if (row && C.compare(g.x, row.x) === 0) tr.className = 'sel';
      const det = next ? String(g.x.d * next.x.n - g.x.n * next.x.d) : '—';
      for (const t of [String(i + 1), C.fractionId(g.x), approx(g.x), String(countIn(g, p)), det]) tr.append(el('td', {}, t));
      tr.onclick = () => selectEvent(eventId(g.rows[0]));
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
      const vis = visibleGroups(p); let best = null, bd = Infinity;
      for (const g of vis) { const d = Math.abs(4 + (w - 8) * Number(g.x.n) / Number(g.x.d) - px); if (d < bd) { bd = d; best = g; } }
      if (best) selectEvent(eventId(best.rows[0]));
    } else {
      const Q = Qof(record); let best = -1, bd = Infinity;
      for (let i = 0; i < p; i++) { const s = record.rows[i].s, d = Math.abs(4 + (w - 8) * (Number(s.n) / Number(s.d)) / (Q + 1) - px); if (d < bd) { bd = d; best = i; } }
      if (best >= 0) selectEvent(eventId(record.rows[best]));
    }
  }
  const guardUi = fn => (...a) => { try { panel.error = null; return fn(...a); } catch (e) { panel.error = e.message; draw(); } };
  toggle.onclick = () => {
    panel.open = !panel.open; root.hidden = !panel.open; toggle.setAttribute('aria-expanded', String(panel.open));
    if (panel.open) { hostKey = null; poll(); pollTimer = setInterval(poll, 250); if (window.ResizeObserver) ro.observe(root); }
    else { clearInterval(pollTimer); pollTimer = null; stopPlay(); if (record) setStatus(); }
  };
  const ro = window.ResizeObserver ? new ResizeObserver(() => draw()) : null;
  $('cs-q-apply').onclick = guardUi(() => {
    const t = $('cs-q').value.trim();
    C.need(/^[1-9][0-9]{0,2}$/.test(t) && +t <= C.MAX_Q, 'Q must be an integer 1…256');
    panel.Q = +t; hostKey = null; if (record?.kind === 'IMPORTED') record = null; poll();
  });
  $('cs-q').addEventListener('keydown', e => { if (e.key === 'Enter') { e.preventDefault(); $('cs-q-apply').click(); } });
  $('cs-play').onclick = guardUi(() => frame !== null ? pause() : play());
  $('cs-reset').onclick = guardUi(() => { if (record?.kind === 'IMPORTED') record = null; reset(); });
  $('cs-prev').onclick = guardUi(() => step(-1));
  $('cs-next').onclick = guardUi(() => step(1));
  $('cs-speed').onchange = () => { panel.speed = Number($('cs-speed').value); };
  $('cs-seek-apply').onclick = guardUi(() => {
    try { seekExact(C.parseRationalText($('cs-seek').value)); $('cs-seek-note').textContent = 'exact seek'; $('cs-seek-note').className = 'cs-dim'; }
    catch (e) { $('cs-seek-note').textContent = e.message; $('cs-seek-note').className = 'cs-bad'; throw e; }
  });
  $('cs-seek').addEventListener('keydown', e => { if (e.key === 'Enter') { e.preventDefault(); $('cs-seek-apply').click(); } });
  $('cs-preset').onclick = guardUi(applyCanonicalPreset);
  $('cs-show').onclick = guardUi(() => showSelectedContact({ applySnapshotBase: $('cs-apply-base').checked }));
  $('cs-export').onclick = guardUi(exportSnapshot);
  $('cs-import').onchange = async e => { const f = e.target.files[0]; e.target.value = ''; if (f) { try { await importFile(f); } catch (_) { /* reported in panel */ } } };
  $('cs-timeline').onclick = ev => guardUi(pick)($('cs-timeline'), ev, 'timeline');
  $('cs-rail').onclick = ev => guardUi(pick)($('cs-rail'), ev, 'rail');

  window.McombContactSweepDiagnosticsV1 = Object.freeze({
    snapshot: () => currentSnapshot(),
    seek: ({ numerator, denominator }) => { seekExact(C.rational({ numerator, denominator })); return currentSnapshot(); },
    reset: () => { if (record?.kind === 'IMPORTED') record = null; reset(); return { epoch: String(epoch), status: panel.status }; },
    selectEvent: id => selectEvent(id),
    showSelectedContact: (options = {}) => showSelectedContact(options),
    cancel: () => cancel(),
    status: () => ({ open: panel.open, status: panel.status, reason: panel.reason, error: panel.error, epoch: String(epoch), pending: !!pending,
      kind: record?.kind ?? null, attached: record?.attached ?? null, staleRejected, selected, running: frame !== null,
      cursor: record ? C.text(record.cursor) : null, placement: placement && JSON.parse(JSON.stringify(placement)), build: SOURCE })
  });
})();
