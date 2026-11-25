/* arithmetic-fourier panel v0.1 (builder candidate; not accepted, sealed or passed).
 * Credit: purpose and atom reading, saphir; schema handoff, panel reviews and audits, Astra; schema construction, Fable (Claude);
 * panel handoff, the handoff drafter (Claude) under the oversight seat; build and checks, the builder (Claude).
 *
 * Reads the host's exact input model read-only: BSDLinkedReductionV1.epoch and .state (cheap tuple T, sampled every
 * 250 ms while open) and BSDLinkedReductionV1.current (deep clone; read only on opening, on a change of T to verified,
 * and in export validation). Never calls the host's actions, never dispatches host events, writes no host state.
 * The atom n is this panel's own input. Every job, rendered record and export is bound to (uiRevision, inputDigest),
 * where inputDigest = SHA-256 of canonical(jobInput) (HANDOFF 8.7). Arithmetic runs in the embedded worker.
 */
(() => {
  'use strict';
  const C = window.McombArithmeticFourierCoreV1, PINS = window.McombArithmeticFourierBuildPins;
  const WORKER_SOURCE = window.McombArithmeticFourierWorkerSourceV1, SOURCES = window.McombArithmeticFourierSourcesV1;
  const $ = id => document.getElementById(id);
  const JOB_BUDGET_MS = 10000, SAMPLE_MS = 250, SAMPLE_RETRY_CAP = 8;
  const SCOPE_TEXT = 'Finite local facts and finite coefficient assembly for one integral Weierstrass model and one atom. Agreement on the listed indices is exact equality on those indices only. It does not prove that two L-functions are equal, and it supplies no L-value, rank, regulator, Sha, BSD or RH conclusion.';
  const BOUNDARY_TEXT = 'These rows are finite local facts for one exact model and one atom. They do not enter the BSD leading-term comparison and they say nothing about RH.';
  const el = (tag, attrs = {}, text = null) => { const e = document.createElement(tag); for (const [k, v] of Object.entries(attrs)) e.setAttribute(k, v); if (text !== null) e.textContent = text; return e; };
  const v = (text, tag = 'span') => el(tag, { class: 'afp-v' }, text);              // a value spelled as the record spells it

  /* ---------------- DOM ---------------- */
  const style = el('style');
  style.textContent = `
  #afp-panel{margin:0 0 10px;padding:8px 10px;border:1px solid var(--line-grid,#334);border-radius:6px;background:var(--bg-card,#111622);color:var(--text-bright,#e6e6f0);font-size:12px;min-width:0;overflow-wrap:anywhere}
  #afp-panel h3{margin:0 0 4px;font-size:13px} #afp-panel h4{margin:8px 0 4px;font-size:12px;color:var(--text-mid,#bbc);font-weight:600}
  #afp-panel .afp-dim{color:var(--text-dim,#99a)} #afp-panel .afp-mono,#afp-panel .afp-v{font-family:ui-monospace,Consolas,monospace;font-size:11.5px}
  #afp-panel .afp-row{display:flex;flex-wrap:wrap;gap:6px 12px;align-items:end;margin-top:6px}
  #afp-panel label{display:flex;flex-direction:column;gap:2px} #afp-panel input{width:84px}
  #afp-panel input,#afp-panel select,#afp-panel button{background:var(--bg-inset,#0b0f18);color:var(--text-bright,#e6e6f0);border:1px solid var(--line-grid,#334);border-radius:3px;font:inherit;padding:2px 6px;max-width:100%}
  #afp-panel button:disabled{opacity:.5}
  #afp-panel .afp-kv{display:grid;grid-template-columns:max-content minmax(0,1fr);gap:2px 10px;margin:0} #afp-panel .afp-kv dt{color:var(--text-dim,#99a)} #afp-panel .afp-kv dd{margin:0}
  #afp-panel .afp-table{overflow:auto;max-height:280px;border:1px solid #1f1f33}
  #afp-panel table{border-collapse:collapse;font-variant-numeric:tabular-nums} #afp-panel td,#afp-panel th{border:1px solid #1f1f33;padding:2px 6px;text-align:left;vertical-align:top}
  #afp-panel th{color:var(--text-dim,#99a);font-weight:500;position:sticky;top:0;background:var(--bg-card,#111622)}
  #afp-panel .afp-derived{color:var(--text-dim,#99a);font-style:italic}
  #afp-panel .afp-text{margin:6px 0 0;padding:4px 6px;border-left:2px solid var(--line-grid,#334)}
  #afp-panel [hidden]{display:none!important}`;
  document.head.append(style);

  const toggle = el('button', { id: 'afp-toggle', type: 'button', class: 'micro-button', 'aria-expanded': 'false',
    title: 'Opt-in arithmetic–Fourier atom comparison: local rows of the host exact model, the atom assembly of a_n and a modular side' }, 'Arithmetic–Fourier');
  const anchorToggle = $('spc-toggle') || $('bz-toggle') || $('cs-toggle');
  if (anchorToggle) anchorToggle.after(toggle);
  const root = el('section', { id: 'afp-panel', hidden: '', 'aria-label': 'Arithmetic–Fourier atom comparison' });
  root.innerHTML = `
  <h3>Arithmetic–Fourier · one exact curve model and one atom n · candidate panel v0.1</h3>
  <div class="afp-dim">Reads the host's exact input model read-only (served mode, after the host's T4 replay of the current context). The atom n is this panel's own input; the host's orbit N and shell base B are never read. Arithmetic runs in a Web Worker (BigInt port of af_reference 0.1.1).</div>
  <div class="afp-row"><span id="afp-status" role="status" aria-live="polite"></span></div>
  <div class="afp-row"><span id="afp-registry" class="afp-dim"></span></div>
  <div class="afp-row" id="afp-controls">
    <label>atom n<input id="afp-atom" value="225" inputmode="numeric" autocomplete="off"></label>
    <label>modular origin<select id="afp-origin"><option value="NONE">NONE</option><option value="Q_PRODUCT">Q_PRODUCT</option><option value="SUPPLIED_TABLE">SUPPLIED_TABLE (registered snapshot)</option><option value="DERIVED_FROM_CURVE">DERIVED_FROM_CURVE (same data twice — not a comparison)</option></select></label>
    <label id="afp-prefix-wrap">prefix length L (1..256)<input id="afp-prefix" value="256" inputmode="numeric" autocomplete="off"></label>
  </div>
  <div class="afp-row" id="afp-qp-controls">
    <label>preset<select id="afp-preset"><option value="QP32">(4,2)(8,2), declared level 32</option><option value="QP11">(1,2)(11,2), declared level 11</option><option value="CUSTOM">custom factors</option></select></label>
    <span id="afp-factors" class="afp-row"></span>
    <button id="afp-add-factor" type="button">add factor</button>
    <label>declared level (a claim, not a computed conductor)<input id="afp-claim-level" value="32" autocomplete="off"></label>
    <label>label locator<input id="afp-claim-label" value="NONE" autocomplete="off"></label>
  </div>
  <div class="afp-row" id="afp-table-controls">
    <label>registered newform table<select id="afp-table"><option value="32.2.a.a">32.2.a.a</option><option value="37.2.a.a">37.2.a.a</option></select></label>
    <label style="flex-direction:row;align-items:center;gap:6px"><input id="afp-witness" type="checkbox" style="width:auto"> LMFDB_CLASS_LINK witness (registered class listing of that label)</label>
  </div>
  <div id="afp-body"></div>
  <div class="afp-row"><button id="afp-remove-witness" type="button" hidden>Remove the witness and rebuild</button></div>
  <p class="afp-text" id="afp-scope"></p>
  <p class="afp-text afp-mono" id="afp-exclusions"></p>
  <p class="afp-text" id="afp-boundary"></p>
  <div class="afp-row"><button id="afp-export" type="button">Export record (JSON)</button><span id="afp-export-status" role="status" aria-live="polite"></span></div>`;
  const rr = $('rr-panel');
  if (rr) rr.after(root); else document.body.append(root);
  $('afp-scope').textContent = SCOPE_TEXT;
  $('afp-boundary').textContent = BOUNDARY_TEXT;
  $('afp-exclusions').textContent = 'Exclusions: ' + (C ? C.EXCLUSIONS.join(', ') : 'unavailable');

  /* ---------------- state ---------------- */
  const S = {
    open: false, revision: 0, inputDigest: null, jobInput: null, state: 'CURVE_RECORD_UNAVAILABLE', reason: 'panel closed',
    lastT: null, binding: null, bindingT: null, hostStatus: null, sampleFailures: 0, pendingOpen: false,
    record: null, recordText: null, recordSha256: null, recordRevision: null, recordDigest: null, assessment: null, assessRefusal: null,
    job: null, worker: null, workerSerial: 0, pending: new Map(), timer: null,
    discarded: { success: 0, refusal: 0, error: 0, workerError: 0, timeout: 0, cleanup: 0, validated: 0 },
    samples: 0, currentReads: [], exportLog: [], log: [], timings: [], jobsStarted: 0, downloads: 0,
    registry: { ok: false, reason: 'registry unavailable: port not loaded', files: null }
  };
  const log = (kind, data = {}) => { S.log.push({ t: Date.now(), kind, revision: S.revision, ...data }); if (S.log.length > 4000) S.log.shift(); };
  if (C) { try { S.registry = C.checkSourcesModule(SOURCES); } catch (e) { S.registry = { ok: false, reason: 'registry unavailable: ' + e.message, files: null }; } }
  const H = () => window.BSDLinkedReductionV1 || null;

  /* ---------------- host tuple T and the ready sample ---------------- */
  function readT() {
    const h = H(); S.samples++;
    if (!h) return { epoch: null, verified: false, contextId: null, held: false, offline: true, missing: true };
    const st = h.state;
    return { epoch: h.epoch, verified: !!st.verified, contextId: st.contextId === undefined ? null : st.contextId, held: !!st.held, offline: !!st.offline };
  }
  const sameT = (a, b) => !!a && !!b && a.epoch === b.epoch && a.verified === b.verified && a.contextId === b.contextId && a.held === b.held && a.offline === b.offline;
  function readCurrent(why) {
    const h = H(); const cur = h ? h.current : null;
    S.currentReads.push({ t: Date.now(), why, epoch: h ? h.epoch : null, nonNull: !!cur });
    if (S.currentReads.length > 2000) S.currentReads.shift();
    return cur;
  }
  function tick() {
    if (!S.open) return;
    const T = readT();
    if (S.lastT && sameT(T, S.lastT)) return;
    onTChange(T);
  }
  function onTChange(T) {
    bump('host tuple changed');
    S.lastT = T;
    if (!T.verified || T.offline) { nullState(T); return; }
    readySample();
  }
  function nullState(T) {
    S.binding = null; S.bindingT = null; S.hostStatus = null;
    clearRecord(); S.jobInput = null; S.inputDigest = null;
    setState('CURVE_RECORD_UNAVAILABLE', T && T.missing ? 'exact curve record unavailable (host API missing)'
      : T && T.offline ? 'exact curve record unavailable (verifier offline)' : 'exact curve record unavailable (host context unverified)');
  }
  function readySample() {
    const why = S.pendingOpen ? 'open' : 'change'; S.pendingOpen = false;
    const T1 = readT(), cur = readCurrent(why), T2 = readT();
    const model = cur && cur.packet && cur.packet.view && cur.packet.view.inputModel;
    if (!sameT(T1, T2) || !cur || !model || typeof model.modelId !== 'string' || !Array.isArray(model.ainvs)) {
      S.sampleFailures++;
      log('SAMPLE_DISCARDED', { T1, T2, nonNull: !!cur, failures: S.sampleFailures });
      nullState(T2);
      if (S.sampleFailures < SAMPLE_RETRY_CAP) S.lastT = null;      // retry at the next tick (capped)
      return;
    }
    S.sampleFailures = 0;
    bump('new binding');                                            // a new binding increments the revision
    S.lastT = T1;
    S.binding = { modelId: model.modelId, ainvs: model.ainvs.map(String), hostEpoch: String(T1.epoch), hostContextId: String(T1.contextId) };
    S.bindingT = T1;
    S.hostStatus = cur.assessment && typeof cur.assessment.status === 'string' ? cur.assessment.status : null;
    log('BINDING', { modelId: model.modelId, epoch: T1.epoch, contextId: T1.contextId, hostStatus: S.hostStatus });
    recompute();
  }

  /* ---------------- revision, cancellation, jobs ---------------- */
  function bump(why) {
    S.revision++;                                                   // first, before any parsing, validation or dispatch
    cancelJob(why);
    log('REVISION', { why });
  }
  function cancelJob(why) {
    const hadWork = !!S.job || S.pending.size > 0;
    if (S.job) log('CANCELLED', { job: S.job.revision, digest: S.job.inputDigest, why });
    S.job = null;
    for (const [, p] of S.pending) p.reject(Object.assign(new Error('cancelled'), { code: 'CANCELLED' }));
    S.pending.clear();
    if (hadWork && S.worker) { S.worker.terminate(); log('WORKER_TERMINATED', { serial: S.worker.serial }); S.worker = null; }
    // job timers are not cleared here: a late timer callback must meet the identity check (HANDOFF 8.7)
  }
  function ensureWorker() {
    if (S.worker) return S.worker;
    const url = URL.createObjectURL(new Blob([WORKER_SOURCE], { type: 'text/javascript' }));
    const w = new Worker(url); URL.revokeObjectURL(url);
    w.serial = ++S.workerSerial; w.current = null;
    w.onmessage = ev => onWorkerMessage(w, ev.data || {});
    w.onerror = ev => { if (ev && ev.preventDefault) ev.preventDefault(); onWorkerError(w, ev && ev.message ? ev.message : 'worker error'); };
    S.worker = w;
    return w;
  }
  const isCurrent = (rev, digest) => rev === S.revision && digest === S.inputDigest && digest !== null;
  function clearRecord() {
    S.record = null; S.recordText = null; S.recordSha256 = null; S.recordRevision = null; S.recordDigest = null; S.assessment = null; S.assessRefusal = null;
  }
  function recompute() {
    clearRecord();
    if (!S.binding) { setState('CURVE_RECORD_UNAVAILABLE', S.reason && S.reason.startsWith('exact curve record unavailable') ? S.reason : 'exact curve record unavailable (host context unverified)'); return; }
    if (!C) { S.inputDigest = null; setState('INVALID_INPUT', 'port unavailable'); return; }
    const r = C.makeJobInput(controls(), S.registry.ok ? S.registry.files : null);
    if (!r.ok) { S.jobInput = null; S.inputDigest = null; setState('INVALID_INPUT', r.reason); return; }
    S.jobInput = r.jobInput; S.inputDigest = r.inputDigest;
    dispatch();
  }
  function filesFor(jobInput) {
    const out = {};
    for (const d of jobInput.assessment.attachments) out[d] = S.registry.files.get(d).slice();
    return out;
  }
  function dispatch() {
    const job = { revision: S.revision, inputDigest: S.inputDigest, t0: Date.now() };
    S.job = job; S.jobsStarted++;
    setState('BUILDING', 'building the record in the worker');
    const w = ensureWorker();
    w.current = job;
    w.postMessage({ type: 'afp/build', revision: job.revision, inputDigest: job.inputDigest, binding: S.jobInput.binding, inputs: S.jobInput.inputs, files: filesFor(S.jobInput) });
    log('JOB_START', { digest: job.inputDigest });
    setTimeout(() => onTimeout(job), JOB_BUDGET_MS);
  }
  function onTimeout(job) {
    if (job.done) return;                                           // completed before its budget: no timeout
    if (!(S.job === job && isCurrent(job.revision, job.inputDigest))) { S.discarded.timeout++; log('DISCARDED', { path: 'timeout', job: job.revision }); return; }
    job.done = true; S.job = null;
    if (S.worker) { S.worker.terminate(); S.worker = null; }
    clearRecord();
    setState('TIMEOUT', 'TIMEOUT: the build exceeded the declared ' + JOB_BUDGET_MS + ' ms budget; no partial record');
    log('TIMEOUT', { job: job.revision });
  }
  function onWorkerMessage(w, m) {
    if (m.type === 'afp/ready') return;
    if (m.type === 'afp/validated') {
      const p = S.pending.get('validate');
      if (!p || !(isCurrent(m.revision, m.inputDigest) && p.revision === m.revision && p.inputDigest === m.inputDigest)) { S.discarded.validated++; log('DISCARDED', { path: 'validated', rev: m.revision }); return; }
      S.pending.delete('validate'); p.resolve(m); return;
    }
    const job = w.current;
    const path = m.type === 'afp/result' ? 'success' : m.type === 'afp/refused' ? 'refusal' : 'error';
    if (!job || job.done || !(isCurrent(m.revision, m.inputDigest) && S.job === job && job.revision === m.revision && job.inputDigest === m.inputDigest)) {
      S.discarded[path]++; log('DISCARDED', { path, rev: m.revision, digest: m.inputDigest }); return;
    }
    job.done = true; S.job = null; w.current = null;
    if (m.type === 'afp/result') {
      S.record = m.record; S.recordText = m.text; S.recordSha256 = m.recordSha256; S.recordRevision = job.revision; S.recordDigest = job.inputDigest;
      S.assessment = m.assessment; S.assessRefusal = m.assessRefusal;
      S.timings.push(Object.assign({ revision: job.revision }, m.timings)); if (S.timings.length > 500) S.timings.shift();
      setState('READY', m.assessRefusal ? 'record built; consumer assessment refused this witness record (export refused)' : 'record built and validated by the port');
    } else if (m.type === 'afp/refused') {
      clearRecord(); setState('REFUSED', m.message);
    } else {
      clearRecord(); setState('REFUSED', 'INTERNAL_ERROR: ' + m.message);
    }
  }
  function onWorkerError(w, message) {
    const job = w.current;
    if (!job || job.done || !(isCurrent(job.revision, job.inputDigest) && S.job === job)) { S.discarded.workerError++; log('DISCARDED', { path: 'workerError' }); return; }
    job.done = true; S.job = null; w.current = null;
    if (S.worker === w) { w.terminate(); S.worker = null; }
    clearRecord(); setState('REFUSED', 'INTERNAL_ERROR: worker error: ' + message);
  }

  /* ---------------- controls ---------------- */
  function factorRows() { return Array.from($('afp-factors').querySelectorAll('.afp-factor')).map(r => ({ d: r.querySelector('.afp-d').value, r: r.querySelector('.afp-r').value })); }
  function addFactorRow(d, r) {
    const row = el('span', { class: 'afp-factor afp-row' });
    const di = el('input', { class: 'afp-d', 'aria-label': 'factor d' }); di.value = d;
    const ri = el('input', { class: 'afp-r', 'aria-label': 'factor r' }); ri.value = r;
    const rm = el('button', { type: 'button', class: 'afp-remove-factor' }, 'remove');
    const ld = el('label', {}, 'd'); ld.append(di); const lr = el('label', {}, 'r'); lr.append(ri);
    row.append(ld, lr, rm);
    di.addEventListener('input', () => { bump('factor d'); $('afp-preset').value = 'CUSTOM'; recompute(); });
    ri.addEventListener('input', () => { bump('factor r'); $('afp-preset').value = 'CUSTOM'; recompute(); });
    rm.addEventListener('click', () => { bump('remove factor'); row.remove(); $('afp-preset').value = 'CUSTOM'; recompute(); });
    $('afp-factors').append(row);
  }
  function applyPreset(id) {
    const p = C && C.PRESETS[id]; if (!p) return;
    $('afp-factors').replaceChildren();
    for (const f of p.factors) addFactorRow(f.d, f.r);
    $('afp-claim-level').value = p.level; $('afp-claim-label').value = p.label;
  }
  function controls() {
    return { binding: S.binding, atom: $('afp-atom').value, origin: $('afp-origin').value, prefix: $('afp-prefix').value, preset: $('afp-preset').value,
      factors: factorRows(), level: $('afp-claim-level').value, label: $('afp-claim-label').value, table: $('afp-table').value, witness: $('afp-witness').checked };
  }
  function syncControlVisibility() {
    const o = $('afp-origin').value;
    $('afp-qp-controls').hidden = o !== 'Q_PRODUCT';
    $('afp-table-controls').hidden = o !== 'SUPPLIED_TABLE';
    $('afp-prefix-wrap').hidden = o === 'NONE';
  }
  applyPreset('QP32');
  if (!S.registry.ok) { $('afp-witness').disabled = true; $('afp-table').disabled = true; $('afp-origin').querySelector('option[value=SUPPLIED_TABLE]').disabled = true; }
  syncControlVisibility();

  /* ---------------- rendering (everything shown is read from the record) ---------------- */
  function setState(state, reason) { S.state = state; S.reason = reason; render(); }
  function kv(pairs) { const dl = el('dl', { class: 'afp-kv' }); for (const [k, val] of pairs) { dl.append(el('dt', {}, k)); const dd = el('dd'); if (val instanceof Node) dd.append(val); else dd.textContent = val; dl.append(dd); } return dl; }
  function table(head, rows) {
    const wrap = el('div', { class: 'afp-table' }), t = el('table'), th = el('tr');
    for (const h of head) th.append(el('th', {}, h));
    const thead = el('thead'); thead.append(th); t.append(thead);
    const tb = el('tbody'); for (const r of rows) tb.append(r); t.append(tb); wrap.append(t); return wrap;
  }
  function render() {
    const st = $('afp-status');
    st.textContent = S.state + ' · ' + S.reason;
    st.dataset.state = S.state;
    $('afp-registry').textContent = S.registry.reason;
    $('afp-registry').dataset.ok = String(!!S.registry.ok);
    root.dataset.state = S.state; root.dataset.revision = String(S.revision); root.dataset.inputDigest = S.inputDigest || '';
    root.dataset.recordSha256 = S.recordSha256 || '';
    const body = $('afp-body'); body.replaceChildren();
    $('afp-remove-witness').hidden = !(S.state === 'READY' && S.assessRefusal && $('afp-witness').checked);
    $('afp-export').dataset.exportable = String(S.state === 'READY' && !S.assessRefusal);   // never disabled: a press while pending is refused with a typed reason
    if (S.binding) {
      body.append(el('h4', {}, 'Curve (read-only from the host)'), kv([
        ['ainvs [a1, a2, a3, a4, a6]', v('[' + S.binding.ainvs.join(', ') + ']')],
        ['exact input model ID (Tate model schema)', v(S.binding.modelId)],
        ['binding: host epoch / context', v(S.binding.hostEpoch + ' / ' + S.binding.hostContextId)],
        ["host T4 assessment status (the host's word, shown as given)", v(S.hostStatus || 'none')],
        ['note', S.hostStatus === 'UNAVAILABLE' ? 'partial host assessment: an exact input model is available; this is not a complete global-reduction result' : 'read-only from the host; not a global-reduction result of this panel']
      ]));
    }
    const r = S.record;
    if (!r || S.state !== 'READY') return;
    // atom line
    const prod = r.atom.factors.reduce((s, f) => s * BigInt(f.prime) ** BigInt(f.exponent), 1n);
    body.append(el('h4', {}, 'Atom n (this panel’s input)'), kv([
      ['n', v(r.atom.n)],
      ['factorization', v(r.atom.factors.length ? r.atom.factors.map(f => f.prime + '^' + f.exponent).join(' · ') : '(empty product)')],
      ['recoverable: product of the listed prime powers equals n', v(prod.toString() === r.atom.n ? 'yes (' + prod + ')' : 'NO')]
    ]));
    // local rows
    const lrows = r.local.map(row => {
      const tr = el('tr', { 'data-prime': row.prime, 'data-reduction': row.reduction });
      tr.append(el('td', {}, row.prime));
      if (row.reduction === 'REDUCTION_UNRESOLVED') {
        tr.append(el('td', { class: 'afp-unresolved', colspan: '5' }, 'unresolved: model not minimal at p'));
        tr.append(el('td', {}, row.scaling_exponent + ' · ' + row.minimality));
        tr.append(el('td', {}, 'Δ:' + row.valuations.discriminant + ' c4:' + row.valuations.c4 + ' c6:' + row.valuations.c6));
        return tr;
      }
      for (const x of [row.reduction, row.reduced_curve, row.reduced_point_count, row.a_p, '[' + row.denominator_polynomial.join(', ') + ']']) tr.append(el('td', { class: 'afp-v' }, x));
      tr.append(el('td', {}, row.scaling_exponent + ' · ' + row.minimality));
      tr.append(el('td', {}, 'Δ:' + row.valuations.discriminant + ' c4:' + row.valuations.c4 + ' c6:' + row.valuations.c6));
      return tr;
    });
    body.append(el('h4', {}, 'Local rows at the 55 requested primes (from the model; denominator polynomial in ascending powers of T)'),
      table(['p', 'reduction', 'reduced curve', 'point count', 'a_p', 'denominator polynomial', 'scaling exponent · minimality', 'valuations'], lrows));
    // atom assembly
    const pp = r.atom.prime_powers.map(x => { const tr = el('tr'); tr.append(el('td', {}, x.prime + '^' + x.exponent), el('td', { class: 'afp-v' }, x.rule), el('td', { class: 'afp-v' }, x.coefficients ? x.coefficients.join(', ') : 'unavailable')); return tr; });
    const an = r.atom.a_n;
    body.append(el('h4', {}, 'Atom assembly of a_n'), table(['p^e', 'rule', 'a_(p^0) .. a_(p^e)'], pp),
      kv([['a_n', an.availability === 'AVAILABLE' ? v(an.value + ' (' + an.assembly + ')') : v('unavailable: ' + an.reason + ' at ' + an.primes.join(', '))]]));
    // modular side
    const mod = r.modular, pairs = [['origin', v(mod.origin)]];
    if (mod.origin === 'NONE') pairs.push(['modular side', 'no modular source']);
    else {
      pairs.push(['prefix length', v(mod.prefix_length)], ['coefficients SHA-256', v(mod.coefficients_sha256)]);
      if (mod.origin === 'DERIVED_FROM_CURVE') pairs.push(['reading', 'same data twice — not a comparison']);
      if (mod.factors) pairs.push(['factors (d, r)', v(mod.factors.map(f => '(' + f.d + ',' + f.r + ')').join(' '))]);
      if (mod.claim) pairs.push(['declared level (a claim, not a computed conductor)', v(mod.claim.level)], ['label locator', v(mod.claim.label_locator)], ['claim status', v(mod.claim.status)],
        ['claim', v('weight ' + mod.claim.weight + ', character ' + mod.claim.character + ', ' + mod.claim.normalization)]);
      if (mod.origin_statement) pairs.push(['origin statement', v(mod.origin_statement)]);
      if (mod.upstream) pairs.push(['upstream digest / extraction', v(mod.upstream.sha256 + ' / ' + mod.upstream.extraction)]);
    }
    body.append(el('h4', {}, 'Modular side'), kv(pairs));
    // comparisons
    const crow = r.comparisons.map(c => {
      const tr = el('tr', { 'data-index': c.index, 'data-result': c.result });
      const side = s => s.availability === 'AVAILABLE' ? s.value : 'unavailable: ' + s.reason;
      tr.append(el('td', {}, c.index), el('td', { class: 'afp-v' }, side(c.curve)), el('td', { class: 'afp-v' }, side(c.modular)));
      const res = el('td', { class: c.result === 'DERIVED_NOT_A_COMPARISON' ? 'afp-v afp-derived afp-result' : 'afp-v afp-result' }, c.result);
      if (c.result === 'DERIVED_NOT_A_COMPARISON') res.title = 'same data twice — not a comparison';
      tr.append(res);
      return tr;
    });
    const sm = r.summary;
    body.append(el('h4', {}, 'Comparisons at the listed indices' + (mod.origin === 'DERIVED_FROM_CURVE' ? ' (same data twice — not a comparison)' : '')),
      table(['index', 'curve side', 'modular side', 'result'], crow),
      kv([['summary', v('indices ' + sm.indices + ' · EQUAL ' + sm.equal + ' · MISMATCH ' + sm.mismatch + ' · NOT_COMPARABLE ' + sm.not_comparable + ' · DERIVED_NOT_A_COMPARISON ' + sm.derived)],
        ['outcome', v(sm.outcome)]]));
    // evidence and consumer assessment
    const e = r.evidence;
    body.append(el('h4', {}, 'Evidence (producer dimensions, as the record states them)'), kv([
      ['curve side', v(e.curve_side.status + (e.curve_side.unresolved_primes.length ? ' · unresolved primes ' + e.curve_side.unresolved_primes.join(', ') : ''))],
      ['modular bytes', v(e.modular_bytes.status)], ['modular membership', v(e.modular_membership.status)],
      ['curve–form association', v(e.curve_form_association.status + ' (association: ' + r.association.witness + ', ' + r.association.status + ')')],
      ['comparison', v(e.comparison.class + ' · ' + e.comparison.outcome + ' · ' + e.comparison.meaning)],
      ['source registry SHA-256', v(e.source_registry_sha256)]]));
    if (S.assessment || S.assessRefusal) {
      body.append(el('h4', {}, 'Consumer assessment (embedded registered snapshots replayed by the port)'));
      if (S.assessRefusal) body.append(kv([['consumer assessment refused', v(S.assessRefusal)], ['export', 'refused for this witness record; use “Remove the witness and rebuild” to build the same curve and table without the witness']]));
      else { const d = S.assessment.dimensions; body.append(kv([['modular bytes', v(d.modular_bytes)], ['modular membership', v(d.modular_membership)], ['curve–form association', v(d.curve_form_association)],
        ['comparison', v(d.comparison.class + ' · ' + d.comparison.outcome)], ['limit', v(S.assessment.limit)]])); }
    }
    body.append(kv([['record SHA-256', v(S.recordSha256)], ['uiRevision / inputDigest', v(S.recordRevision + ' / ' + S.recordDigest)]]));
  }

  /* ---------------- export (three-step identity check, HANDOFF 8.7) ---------------- */
  function precheck(stage) {
    if (S.state !== 'READY' || !S.recordText) {
      const code = S.state === 'CURVE_RECORD_UNAVAILABLE' ? 'HOST_PENDING' : S.state === 'BUILDING' ? 'BUILD_PENDING' : stage === 'pre' ? S.state : 'STALE_EXPORT';
      return { ok: false, code };
    }
    if (S.assessRefusal) return { ok: false, code: 'ASSESSMENT_REFUSED' };
    if (!(S.recordRevision === S.revision && S.recordDigest === S.inputDigest && S.inputDigest !== null)) return { ok: false, code: 'STALE_EXPORT' };
    const T = readT();
    if (!sameT(T, S.bindingT)) return { ok: false, code: T.verified ? 'STALE_EXPORT' : (stage === 'pre' ? 'HOST_PENDING' : 'STALE_EXPORT') };
    const cur = readCurrent('export');
    const id = cur && cur.packet && cur.packet.view && cur.packet.view.inputModel && cur.packet.view.inputModel.modelId;
    if (id !== S.binding.modelId) return { ok: false, code: 'STALE_EXPORT' };
    return { ok: true };
  }
  function validateInWorker(rev, digest, text, jobInput) {
    return new Promise((resolve, reject) => {
      if (S.pending.has('validate')) { reject(Object.assign(new Error('busy'), { code: 'BUSY' })); return; }
      S.pending.set('validate', { resolve, reject, revision: rev, inputDigest: digest });
      const w = ensureWorker();
      w.postMessage({ type: 'afp/validate', revision: rev, inputDigest: digest, text, modelId: jobInput.binding.modelId, n: jobInput.inputs.atom,
        files: filesFor(jobInput), assess: jobInput.inputs.association.witness !== 'NONE' });
    });
  }
  async function exportNow() {
    const ex = { t: Date.now(), revision: S.revision, inputDigest: S.inputDigest, steps: [], wrote: false, code: null };
    S.exportLog.push(ex);
    const refuse = code => { ex.code = code; $('afp-export-status').textContent = 'export refused: ' + code + ' (no file written)'; log('EXPORT_REFUSED', { code }); return ex; };
    const p1 = precheck('pre'); ex.steps.push({ stage: 'pre', ok: p1.ok, code: p1.code || null });
    if (!p1.ok) return refuse(p1.code);
    const rev = S.revision, digest = S.inputDigest, text = S.recordText, jobInput = S.jobInput;
    let vres;
    try { vres = await validateInWorker(rev, digest, text, jobInput); } catch (e) { vres = { ok: false, code: e.code || 'CANCELLED' }; }
    const p2 = precheck('after-await'); ex.steps.push({ stage: 'after-await', ok: p2.ok, code: p2.code || null, validation: vres.ok ? 'PASS' : vres.code });
    if (!p2.ok || !(rev === S.revision && digest === S.inputDigest)) return refuse('STALE_EXPORT');
    if (!vres.ok) return refuse('VALIDATION_' + vres.code);
    const p3 = precheck('before-download'); ex.steps.push({ stage: 'before-download', ok: p3.ok, code: p3.code || null });
    if (!p3.ok) return refuse('STALE_EXPORT');
    const blob = new Blob([text], { type: 'application/json' }), url = URL.createObjectURL(blob), a = document.createElement('a');
    a.href = url; a.download = 'af-' + jobInput.binding.modelId.slice(0, 12) + '-n' + jobInput.inputs.atom + '.json';
    a.click(); setTimeout(() => URL.revokeObjectURL(url), 1000);
    ex.wrote = true; ex.fileName = a.download; ex.recordSha256 = S.recordSha256; S.downloads++;
    $('afp-export-status').textContent = 'exported ' + a.download;
    log('EXPORTED', { fileName: a.download });
    return ex;
  }

  /* ---------------- wiring ---------------- */
  let sampler = null;
  toggle.onclick = () => {
    S.open = !S.open; root.hidden = !S.open; toggle.setAttribute('aria-expanded', String(S.open));
    if (S.open) { S.lastT = null; S.pendingOpen = true; S.sampleFailures = 0; tick(); sampler = setInterval(tick, SAMPLE_MS); }
    else { clearInterval(sampler); sampler = null; bump('panel closed'); S.binding = null; S.bindingT = null; S.lastT = null; clearRecord(); S.jobInput = null; S.inputDigest = null; setState('CURVE_RECORD_UNAVAILABLE', 'panel closed'); }
  };
  $('afp-atom').addEventListener('input', () => { bump('atom'); recompute(); });
  $('afp-origin').addEventListener('change', () => { bump('origin'); syncControlVisibility(); recompute(); });
  $('afp-prefix').addEventListener('input', () => { bump('prefix length'); recompute(); });
  $('afp-preset').addEventListener('change', () => { bump('preset'); if ($('afp-preset').value !== 'CUSTOM') applyPreset($('afp-preset').value); recompute(); });
  $('afp-add-factor').addEventListener('click', () => { bump('add factor'); addFactorRow('', ''); $('afp-preset').value = 'CUSTOM'; recompute(); });
  $('afp-claim-level').addEventListener('input', () => { bump('claim level'); $('afp-preset').value = 'CUSTOM'; recompute(); });
  $('afp-claim-label').addEventListener('input', () => { bump('claim label'); $('afp-preset').value = 'CUSTOM'; recompute(); });
  $('afp-table').addEventListener('change', () => { bump('registered table'); recompute(); });
  $('afp-witness').addEventListener('change', () => { bump('witness toggle'); recompute(); });
  $('afp-remove-witness').addEventListener('click', () => { bump('remove the witness and rebuild'); $('afp-witness').checked = false; recompute(); });
  $('afp-export').addEventListener('click', () => { exportNow().catch(e => log('EXPORT_ERROR', { message: String(e && e.message) })); });
  // keyboard isolation: navigation keys inside the panel never reach the host's window-level shortcuts; no preventDefault.
  const ISOLATED = new Set(['ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown', 'Home', 'End', 'PageUp', 'PageDown']);
  root.addEventListener('keydown', e => { if (ISOLATED.has(e.key)) e.stopPropagation(); });
  setState('CURVE_RECORD_UNAVAILABLE', 'panel closed');

  /* ---------------- diagnostics (observational) ---------------- */
  const clone = x => (x === null || x === undefined ? x : JSON.parse(JSON.stringify(x)));
  function parityWorker(inputsText) {
    return new Promise((resolve, reject) => {
      const url = URL.createObjectURL(new Blob([WORKER_SOURCE], { type: 'text/javascript' }));
      const w = new Worker(url); URL.revokeObjectURL(url);
      w.onmessage = ev => { const m = ev.data || {}; if (m.type === 'afp/ready') return; w.terminate(); resolve(m.ok ? { ok: true, text: m.text } : { ok: false, code: m.code, message: m.message }); };
      w.onerror = ev => { w.terminate(); reject(Error(ev.message || 'worker error')); };
      w.postMessage({ type: 'afp/parity', id: 1, inputs: JSON.parse(inputsText) });
    });
  }
  function parityMain(inputsText) {
    try { const raw = C.serialize(C.build(JSON.parse(inputsText))); let s = ''; for (const b of raw) s += String.fromCharCode(b); return { ok: true, text: s }; }
    catch (e) { return { ok: false, code: C.codeOf(e), message: e.message }; }
  }
  function timeMainThread(inputsText, attachmentDigests, modelId) {
    const t = () => performance.now(), inputs = JSON.parse(inputsText), files = new Map();
    for (const d of attachmentDigests || []) files.set(d, S.registry.files.get(d));
    const t0 = t(); const raw = C.serialize(C.build(inputs)); const t1 = t();
    C.import_and_validate(raw); const t2 = t();
    C.validateBound(raw, { modelId: modelId || C.import_and_validate(raw).curve.model_id, n: inputs.atom }); const t3 = t();
    let assessMs = null; if (files.size) { const a0 = t(); try { C.assess(raw, files); } catch (_) { /* refusal timed as well */ } assessMs = t() - a0; }
    return { buildMs: t1 - t0, importValidateMs: t2 - t1, validateBoundMs: t3 - t2, assessMs, totalMs: (t3 - t0) + (assessMs || 0), bytes: raw.length };
  }
  window.McombArithmeticFourierDiagnosticsV1 = Object.freeze({
    status: () => ({ open: S.open, state: S.state, reason: S.reason, uiRevision: S.revision, inputDigest: S.inputDigest, lastT: clone(S.lastT),
      binding: clone(S.binding), bindingT: clone(S.bindingT), hostStatus: S.hostStatus, recordSha256: S.recordSha256, recordRevision: S.recordRevision,
      recordDigest: S.recordDigest, assessRefusal: S.assessRefusal, jobPending: !!S.job, jobsStarted: S.jobsStarted, workerAlive: !!S.worker,
      samples: S.samples, downloads: S.downloads, discarded: clone(S.discarded), jobBudgetMs: JOB_BUDGET_MS, samplePeriodMs: SAMPLE_MS,
      registry: { ok: !!S.registry.ok, reason: S.registry.reason } }),
    jobInput: () => clone(S.jobInput),
    recordText: () => S.recordText,
    assessment: () => clone(S.assessment),
    currentReads: () => clone(S.currentReads),
    exportLog: () => clone(S.exportLog),
    log: () => clone(S.log),
    timings: () => clone(S.timings),
    identity: () => clone(PINS || null),
    parityMain, parityWorker, timeMainThread,
    workerSourceSha256: () => (C ? C.sha256Hex(C.utf8Bytes(WORKER_SOURCE)) : null)
  });
})();
