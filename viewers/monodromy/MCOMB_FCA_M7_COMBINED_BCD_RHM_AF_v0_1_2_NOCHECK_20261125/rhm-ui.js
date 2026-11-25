/* RH margin panel v0.1: the accepted rh_atom_margins record (rh-criteria-readout 0.1.0) for the host shell base B.
 *
 * Idea (the atoms underpin zeta; the 6! -> 7! observation): saphir. Criteria mapped to instrument quantities: Opus.
 * Specification, corrections and audits: Astra. Handoff: fable (Claude). Build: RH margin builder (Claude).
 *
 * Host seam (read only): liftSourceSnapshot(). Only shellMode, shellBase and n1 are used; the spin and orbit fields of
 * the snapshot never enter the computation, the refresh key or the provenance. shellMode 'integer' -> record mode
 * 'direct' (factorial_index null); shellMode 'factorial' -> factorial_index = n1 with B = n1! checked in BigInt.
 * The panel never writes host state, never reads the Basel panel, and does its own factorization (rhm-core.js).
 * Every rendered section is stamped with (B, mode, factorial index, precision_bits) and cleared on change.
 * The record is built in an embedded Web Worker (rhm-core.js + rhm-worker.js; message prefix rhm/), with an epoch, a
 * key and a check of the current inputs on arrival: a stale result is discarded, never rendered. Results are cached by
 * their full input key (the build is deterministic). Export: one action; it re-reads the host and the precision control
 * synchronously; it emits only a record bound to the current inputs (source = this panel's logical identity) and
 * refuses while that record is still being computed.
 * Floating point is not used for any value: decimal readings are directed BigInt decimals of the exact rationals.
 */
(() => {
  'use strict';
  const C = window.McombRhMarginCoreV1, PINS = window.McombRhMarginBuildPins, WSRC = window.McombRhMarginWorkerSourceV1;
  const $ = id => document.getElementById(id);
  if (!C || !PINS || typeof WSRC !== 'string' || typeof liftSourceSnapshot !== 'function' || !$('rr-panel'))
    throw Error('RH margin panel: core, build pins, worker source, host seam or #rr-panel missing');
  const SOURCE = Object.freeze({ host_build: PINS.hostBuild, host_sha256: PINS.hostSha256 });
  const BIT_CHOICES = ['2', '3', '4', '5', '6', '16', '64', '128', '256'], DEFAULT_BITS = '128';
  const SUP = { 0: '⁰', 1: '¹', 2: '²', 3: '³', 4: '⁴', 5: '⁵', 6: '⁶', 7: '⁷', 8: '⁸', 9: '⁹' };
  const sup = s => String(s).split('').map(c => SUP[c]).join('');
  const el = (tag, attrs = {}, text = null) => { const e = document.createElement(tag); for (const [k, v] of Object.entries(attrs)) e.setAttribute(k, v); if (text !== null) e.textContent = text; return e; };

  /* ---------------- DOM: toggle with the micro-buttons; own section after #rr-panel ---------------- */
  const style = el('style');
  style.textContent = `
  #rhm-panel{margin:0 0 10px;padding:8px 10px;border:1px solid var(--line-grid);border-radius:6px;background:var(--bg-card);color:var(--text-bright);font-size:12px;min-width:0;overflow-wrap:anywhere}
  #rhm-panel h3{margin:0 0 4px;font-size:13px} #rhm-panel h4{margin:0 0 4px;font-size:12px;color:var(--text-mid);font-weight:600}
  #rhm-panel .rhm-dim{color:var(--text-dim)} #rhm-panel .rhm-good{color:var(--accent-good)} #rhm-panel .rhm-bad{color:var(--accent-defend)} #rhm-panel .rhm-warn{color:var(--accent-warn)}
  #rhm-panel .rhm-exact{font-family:ui-monospace,Consolas,monospace;font-size:11px}
  #rhm-panel .rhm-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:8px;margin-top:6px}
  #rhm-panel .rhm-box{border:1px solid #1f1f33;border-radius:4px;padding:6px 8px;min-width:0}
  #rhm-panel .rhm-wide{grid-column:1/-1}
  #rhm-panel .rhm-kv{display:grid;grid-template-columns:max-content minmax(0,1fr);gap:2px 10px;margin:0} #rhm-panel .rhm-kv dt{color:var(--text-dim)} #rhm-panel .rhm-kv dd{margin:0}
  #rhm-panel .rhm-badge{display:inline-block;padding:0 6px;border:1px solid var(--line-grid);border-radius:3px;font-weight:600}
  #rhm-panel table{border-collapse:collapse;font-variant-numeric:tabular-nums} #rhm-panel td,#rhm-panel th{border:1px solid #1f1f33;padding:2px 8px;text-align:right}
  #rhm-panel th{color:var(--text-dim);font-weight:500} #rhm-panel .rhm-row{display:flex;flex-wrap:wrap;gap:6px 14px;align-items:center;margin-top:6px}
  #rhm-panel details summary{cursor:pointer;color:var(--text-dim)} #rhm-panel pre{white-space:pre-wrap;word-break:break-all;margin:4px 0 0;font-size:10.5px}
  #rhm-panel button,#rhm-panel select{background:var(--bg-inset);color:var(--text-bright);border:1px solid var(--line-grid);border-radius:3px;font:inherit;padding:2px 8px}
  #rhm-panel button:disabled{opacity:.5}`;
  document.head.append(style);
  const toggle = el('button', { id: 'rhm-toggle', type: 'button', class: 'micro-button', 'aria-expanded': 'false',
    title: 'Opt-in G. Robin margin: sigma(B)/B against the certified enclosure of e^gamma ln ln B, and the Nicolas primorial criterion, for the host shell base B' }, 'G. Robin margin');
  ($('bz-toggle') ? $('bz-toggle').parentElement : document.querySelector('.s-direct-row')).append(toggle);
  const root = el('section', { id: 'rhm-panel', hidden: '', 'aria-label': 'G. Robin margin readout' });
  root.innerHTML = `
  <h3>G. Robin (1984) and Nicolas (1983) margins of the host shell base B · candidate panel v0.1</h3>
  <div class="rhm-dim">The accepted record rh-criteria-readout 0.1.0 (kind rh_atom_margins) for the atom B, the host's shell base (never the orbit N). Exact values; certified outward enclosures of e<sup>γ</sup> ln ln B, where γ is the Euler–Mascheroni constant γ; margin = value minus threshold. Reads the host only; never writes it.</div>
  <div class="rhm-row">
    <label>precision_bits <select id="rhm-bits" title="output grid 2^-precision_bits"></select></label>
    <button id="rhm-export" type="button" disabled title="Download the record as its canonical JSON bytes, bound to the current atom and precision">export record (canonical JSON)</button>
    <span id="rhm-export-msg" class="rhm-dim"></span>
  </div>
  <div id="rhm-status" role="status" aria-live="polite" class="rhm-row"></div>
  <div class="rhm-box" style="margin-top:6px"><div id="rhm-scope" class="rhm-exact"></div><div id="rhm-rh-status" class="rhm-exact"></div></div>
  <div class="rhm-grid">
    <div class="rhm-box rhm-wide" id="rhm-atom" tabindex="0" aria-label="atom"><h4>Atom</h4><div class="rhm-body"></div></div>
    <div class="rhm-box" id="rhm-c1" tabindex="0" aria-label="C1"><h4>C1 · G. Robin (1984) criterion · σ(B)/B</h4><div class="rhm-body"></div></div>
    <div class="rhm-box" id="rhm-c2" tabindex="0" aria-label="C2"><h4>C2 · Nicolas (1983) criterion · B/φ(B)</h4><div class="rhm-body"></div></div>
    <div class="rhm-box rhm-wide" id="rhm-factors" tabindex="0" aria-label="per-prime factors"><h4>Per-prime factors (display only, exact; not exported)</h4><div class="rhm-body"></div></div>
    <div class="rhm-box rhm-wide" id="rhm-constants" tabindex="0" aria-label="constants"><h4>Constants and enclosure parameters</h4><div class="rhm-body"></div></div>
  </div>
  <details id="rhm-bytes"><summary>canonical bytes of the current export (source = this panel's identity)</summary><pre id="rhm-bytes-text" class="rhm-exact"></pre></details>
  <div class="rhm-dim" style="margin-top:6px">Idea: saphir. Criteria mapping: Opus. Specification, corrections and audits: Astra. Handoff: fable (Claude). Panel: RH margin builder (Claude). Record schema 0.1.0, unchanged.</div>`;
  $('rr-panel').after(root);
  const bitsSel = $('rhm-bits');
  for (const b of BIT_CHOICES) { const o = el('option', { value: b }, b === DEFAULT_BITS ? b + ' (default)' : b); if (b === DEFAULT_BITS) o.selected = true; bitsSel.append(o); }
  $('rhm-scope').textContent = C.SCOPE;
  $('rhm-rh-status').textContent = 'rh_status: ' + C.RH_STATUS;
  const SECTIONS = ['rhm-atom', 'rhm-c1', 'rhm-c2', 'rhm-factors', 'rhm-constants'];
  const bodyOf = id => $(id).querySelector('.rhm-body');
  const statusEl = $('rhm-status'), exportBtn = $('rhm-export'), exportMsg = $('rhm-export-msg'), bytesText = $('rhm-bytes-text');

  /* ---------------- state ---------------- */
  const BUDGET_MS = 30000, CACHE_MAX = 64;
  const S = { open: false, status: 'CLOSED', epoch: 0, key: null, inputs: null, record: null, text: null, refusal: null, job: null, worker: null, workerReady: false,
              timer: null, holdNextMs: 0, seq: 0, reads: 0, jobsStarted: 0, timings: [], mainMs: [], lastExport: null };
  const CACHE = new Map();                                 // key -> { kind: 'READY', text } | { kind: 'REFUSED', refusal }; deterministic, keyed by every input
  const HIST = [];
  const note = (event, extra) => { S.seq++; HIST.push(Object.assign({ seq: S.seq, event, key: S.key, epoch: S.epoch }, extra || {})); if (HIST.length > 500) HIST.shift(); };
  /* ---------------- host binding (handoff §4.5, C1) ---------------- */
  const DEC = /^[1-9][0-9]*$/;
  function readInputs() {
    let h; try { h = liftSourceSnapshot(); } catch (e) { return { ok: false, reason: `the host snapshot could not be read (${e.message})` }; }
    const mode = h.shellMode === 'integer' ? 'direct' : h.shellMode === 'factorial' ? 'factorial' : null;
    if (mode === null) return { ok: false, reason: `unknown host shell mode ${String(h.shellMode).slice(0, 20)}` };
    if (!Number.isSafeInteger(h.shellBase) || h.shellBase < 1) return { ok: false, reason: `the host shell base ${String(h.shellBase).slice(0, 30)} is not a positive safe integer` };
    const B = String(h.shellBase);
    if (!DEC.test(B)) return { ok: false, reason: 'the host shell base is not a canonical decimal' };
    let idx = null;
    if (mode === 'factorial') {
      if (!Number.isSafeInteger(h.n1) || h.n1 < 1) return { ok: false, reason: `the host factorial index ${String(h.n1).slice(0, 20)} is not a positive integer` };
      idx = String(h.n1);
      let f = 1n; for (let i = 2n; i <= BigInt(h.n1); i++) { f *= i; if (f > BigInt(B)) break; }
      if (f.toString() !== B) return { ok: false, reason: `the host shell base ${B} is not ${idx}!` };
    }
    const bits = bitsSel.value;
    if (!BIT_CHOICES.includes(bits)) return { ok: false, reason: 'precision_bits control holds an unknown value' };
    const inputs = { B, mode, factorial_index: idx, precision_bits: bits };
    return { ok: true, inputs, key: `${B}|${mode}|${idx === null ? '-' : idx}|${bits}` };
  }

  /* ---------------- rendering ---------------- */
  const DEC_DIGITS = { 2: 4, 3: 4, 4: 4, 5: 4, 6: 4, 16: 6, 64: 20, 128: 24, 256: 24 };   // display length of the directed decimals only
  const decDigits = bits => DEC_DIGITS[bits] || 24;
  function clear() {
    for (const id of SECTIONS) { bodyOf(id).replaceChildren(); const n = $(id); for (const k of ['key', 'b', 'mode', 'idx', 'bits']) delete n.dataset[k]; }
    bytesText.textContent = ''; exportBtn.disabled = true;
    for (const k of ['key', 'status', 'seq']) delete root.dataset[k];
    S.key = null; S.inputs = null; S.record = null; S.text = null;
  }
  function stamp(id, inputs, key) { const n = $(id); n.dataset.key = key; n.dataset.b = inputs.B; n.dataset.mode = inputs.mode; n.dataset.idx = inputs.factorial_index === null ? '' : inputs.factorial_index; n.dataset.bits = inputs.precision_bits; }
  const facText = rec => (rec.atom.factors.length ? rec.atom.factors.map(f => (f.exponent === '1' ? f.prime : f.prime + sup(f.exponent))).join('·') : '1 (empty product)');
  function kvList(rows) {
    const dl = el('dl', { class: 'rhm-kv' });
    for (const [k, v, attrs] of rows) { dl.append(el('dt', {}, k)); const dd = el('dd', attrs || {}); if (typeof v === 'string') dd.textContent = v; else dd.append(v); dl.append(dd); }
    return dl;
  }
  function ivNode(iv, bits, id) {
    const d = decDigits(bits), lo = C.parseRat(iv.lo), hi = C.parseRat(iv.hi);
    const wrap = el('span', { id, 'data-lo': iv.lo, 'data-hi': iv.hi });
    wrap.append(el('span', { class: 'rhm-exact' }, `[${C.decimal(lo, d, 'floor')}, ${C.decimal(hi, d, 'ceil')}]`), ' ');
    const det = el('details'); det.append(el('summary', {}, 'exact endpoints'), el('pre', { class: 'rhm-exact' }, `lo = ${iv.lo}\nhi = ${iv.hi}`));
    wrap.append(det); return wrap;
  }
  function valueNode(v, bits, id) {
    const d = decDigits(bits), x = C.parseRat(v);
    const s = el('span', { id, class: 'rhm-exact', 'data-value': v });
    s.textContent = `${v}  (≈ ${C.decimal(x, d, 'floor')}…)`;
    return s;
  }
  const ASKS = { CRITERION_ASKS_VALUE_BELOW_THRESHOLD: 'the criterion asks for the value BELOW the threshold', CRITERION_ASKS_VALUE_ABOVE_THRESHOLD: 'the criterion asks for the value ABOVE the threshold' };
  const SIDE_WORDS = { ABOVE: 'value above the threshold enclosure (margin > 0)', BELOW: 'value below the threshold enclosure (margin < 0)', UNDECIDED_AT_PRECISION: 'the margin enclosure contains 0 at this precision' };
  function criterionBox(key, blk, rec) {
    const id = 'rhm-' + key, bits = rec.precision_bits, body = bodyOf(id);
    body.append(el('div', { class: 'rhm-dim', id: id + '-statement' }, blk.criterion_statement));
    const rows = [['value', valueNode(blk.value, bits, id + '-value')]];
    if (blk.applicability === 'DOMAIN_UNAVAILABLE') {
      rows.push(['threshold', el('span', { id: id + '-threshold', class: 'rhm-dim', 'data-absent': 'true' }, 'absent (ln ln B is undefined at B = 1)')]);
      rows.push(['margin (value minus threshold)', el('span', { id: id + '-margin', class: 'rhm-dim', 'data-absent': 'true' }, 'absent')]);
      rows.push(['side', el('span', { id: id + '-side', class: 'rhm-verdict rhm-dim', 'data-absent': 'true' }, 'no side at B = 1')]);
    } else {
      rows.push(['threshold e^γ ln ln B', ivNode(blk.threshold, bits, id + '-threshold')]);
      rows.push(['margin (value minus threshold)', ivNode(blk.margin, bits, id + '-margin')]);
      const scoped = blk.applicability === 'IN_RANGE' ? '' : ' · numerical value only';
      const sd = el('span', { id: id + '-side', class: 'rhm-verdict', 'data-side': blk.side });
      sd.append(el('span', { class: 'rhm-badge ' + (blk.side === 'UNDECIDED_AT_PRECISION' ? 'rhm-warn' : '') }, blk.side), ` ${SIDE_WORDS[blk.side]}${scoped}`);
      rows.push(['side', sd]);
    }
    rows.push(['what it asks', el('span', { id: id + '-direction', class: 'rhm-verdict', 'data-direction': blk.criterion_direction }, `${ASKS[blk.criterion_direction]} (${blk.criterion_direction})`)]);
    rows.push(['applicability', el('span', { id: id + '-applicability', class: 'rhm-verdict', 'data-applicability': blk.applicability }, `${blk.applicability}: ${blk.applicability_note}`)]);
    if (key === 'c1' && blk.boundary_note) rows.push(['boundary note', el('span', { id: id + '-boundary' }, blk.boundary_note)]);
    if (key === 'c2') {
      rows.push(['primorial_k', el('span', { id: id + '-k' }, blk.primorial_k === null ? 'null (B is not a primorial N_k)' : blk.primorial_k)]);
      if (blk.convention_note) rows.push(['k = 1 note', el('span', { id: id + '-k1' }, blk.convention_note)]);
    }
    body.append(kvList(rows));
  }
  function factorsBox(rec) {
    const body = bodyOf('rhm-factors');
    let ps = C.F(1n), pe = C.F(1n);
    if (rec.atom.factors.length) {
      const t = el('table', { id: 'rhm-factor-table' }), hr = el('tr');
      ['p', 'a', 'σ(pᵃ)/pᵃ = (pᵃ⁺¹ − 1)/(pᵃ(p − 1))', 'Euler factor p/(p − 1)'].forEach(h => hr.append(el('th', {}, h))); t.append(hr);
      for (const f of rec.atom.factors) {
        const p = BigInt(f.prime), a = BigInt(f.exponent);
        const s = C.F(p ** (a + 1n) - 1n, p ** a * (p - 1n)), e = C.F(p, p - 1n);
        ps = C.mul(ps, s); pe = C.mul(pe, e);
        const tr = el('tr', { 'data-p': f.prime, 'data-a': f.exponent, 'data-sigma': C.enc_rat(s), 'data-euler': C.enc_rat(e) });
        tr.append(el('td', {}, f.prime), el('td', {}, f.exponent), el('td', { class: 'rhm-exact' }, C.enc_rat(s)), el('td', { class: 'rhm-exact' }, C.enc_rat(e)));
        t.append(tr);
      }
      body.append(t);
    } else body.append(el('div', { class: 'rhm-dim', id: 'rhm-factor-table' }, 'no primes (B = 1): both products are the empty product 1'));
    const okS = C.enc_rat(ps) === rec.c1.value, okE = C.enc_rat(pe) === rec.c2.value;
    body.append(el('div', { id: 'rhm-factor-check', class: okS && okE ? 'rhm-good' : 'rhm-bad', 'data-sigma-product': C.enc_rat(ps), 'data-euler-product': C.enc_rat(pe), 'data-equal': String(okS && okE) },
      `check: ∏ σ(pᵃ)/pᵃ = ${C.enc_rat(ps)} ${okS ? 'equals' : 'DIFFERS FROM'} c1.value = ${rec.c1.value}; ∏ p/(p − 1) = ${C.enc_rat(pe)} ${okE ? 'equals' : 'DIFFERS FROM'} c2.value = ${rec.c2.value} (exact rationals).`));
  }
  function constantsBox(rec) {
    const body = bodyOf('rhm-constants'), c = rec.constants, bits = rec.precision_bits;
    if (c.availability !== 'AVAILABLE') { body.append(el('div', { class: 'rhm-dim', id: 'rhm-const-availability', 'data-availability': c.availability }, `${c.availability}: ln ln B is undefined at B = 1; no enclosures are carried.`)); return; }
    body.append(kvList([
      ['availability', el('span', { id: 'rhm-const-availability', 'data-availability': c.availability }, c.availability)],
      ['γ (Euler–Mascheroni constant γ)', ivNode(c.gamma, bits, 'rhm-const-gamma')],
      ['e^γ', ivNode(c.exp_gamma, bits, 'rhm-const-exp-gamma')],
      ['ln B', ivNode(c.ln_B, bits, 'rhm-const-ln-b')],
      ['ln ln B', ivNode(c.ln_ln_B, bits, 'rhm-const-ln-ln-b')],
      ['Euler–Maclaurin n, m', el('span', { class: 'rhm-exact', id: 'rhm-const-em' }, `n = ${c.em_n}, m = ${c.em_m}`)],
      ['remainder bound', el('span', { class: 'rhm-exact', id: 'rhm-const-em-r' }, c.em_remainder_bound)],
      ['working bits', el('span', { class: 'rhm-exact', id: 'rhm-const-wb' }, `${c.working_bits} (precision_bits ${bits} + 64 guard bits)`)],
      ['method', el('span', { class: 'rhm-dim' }, rec.enclosure_method.method_id)],
    ]));
  }
  function showRecord(sel, rec, text) {
    const inp = sel.inputs;
    const ab = bodyOf('rhm-atom');
    ab.append(el('div', { class: 'rhm-exact', id: 'rhm-atom-line' }, `B = ${inp.mode === 'factorial' ? inp.factorial_index + '! = ' : ''}${rec.atom.B} = ${facText(rec)} · mode ${rec.atom.mode}${inp.mode === 'direct' ? ' (host integer shell M)' : ' (host factorial shell)'} · factorial_index ${rec.atom.factorial_index === null ? 'null' : rec.atom.factorial_index} · precision_bits ${rec.precision_bits}`));
    criterionBox('c1', rec.c1, rec); criterionBox('c2', rec.c2, rec); factorsBox(rec); constantsBox(rec);
    for (const id of SECTIONS) stamp(id, inp, sel.key);
    bytesText.textContent = text; exportBtn.disabled = false;
    root.dataset.key = sel.key; root.dataset.status = 'READY'; root.dataset.seq = String(S.seq);
  }

  /* ---------------- worker (embedded source, static-page compatible; epoch and stale-result rejection) ---------------- */
  function ensureWorker() {
    if (S.worker) return S.worker;
    const url = URL.createObjectURL(new Blob([WSRC], { type: 'text/javascript' }));
    const w = new Worker(url); URL.revokeObjectURL(url);
    w.onmessage = ev => onWorkerMessage(ev.data, w);
    w.onerror = e => { if (w === S.worker && S.status === 'COMPUTING') failJob('worker error: ' + (e.message || 'unknown')); };
    S.worker = w; S.workerReady = false;
    return w;
  }
  function killWorker(reason) { if (S.worker) { S.worker.terminate(); note('WORKER_TERMINATED', { reason }); } S.worker = null; S.workerReady = false; }
  function clearTimer() { if (S.timer) { clearTimeout(S.timer); S.timer = null; } }
  function startJob(sel) {
    clearTimer();
    if (S.job) note('SUPERSEDED', { supersededKey: S.job.key, supersededEpoch: S.job.epoch });
    S.epoch += 1; S.jobsStarted++;
    S.job = { epoch: S.epoch, key: sel.key, inputs: sel.inputs, t0: performance.now() };
    S.status = 'COMPUTING';
    const holdMs = S.holdNextMs; S.holdNextMs = 0;
    ensureWorker().postMessage({ type: 'rhm/build', epoch: S.epoch, key: sel.key, inputs: sel.inputs, source: { ...SOURCE }, holdMs });
    S.timer = setTimeout(() => failJob(`no result within the ${BUDGET_MS} ms budget`), BUDGET_MS);
    note('COMPUTING', { holdMs });
    statusEl.className = 'rhm-row rhm-dim';
    statusEl.textContent = `computing the record for B = ${sel.inputs.B} at precision_bits ${sel.inputs.precision_bits}… (export is refused until it is ready)`;
    root.dataset.key = sel.key; root.dataset.status = 'COMPUTING'; root.dataset.seq = String(S.seq);
  }
  function failJob(message) {
    clearTimer(); killWorker('job failed'); S.job = null;
    S.status = 'ERROR'; S.refusal = 'build error: ' + message; note('ERROR', { message });   // no automatic retry: a new key, or closing and reopening, starts again
    statusEl.className = 'rhm-row rhm-bad'; statusEl.textContent = `${S.refusal}. Nothing is shown; export is blocked.`;
    root.dataset.status = 'ERROR'; root.dataset.seq = String(S.seq);
  }
  function onWorkerMessage(m, w) {
    if (!m || typeof m.type !== 'string' || m.type.indexOf('rhm/') !== 0) { note('MESSAGE_IGNORED'); return; }
    if (m.type === 'rhm/ready') { if (w === S.worker) S.workerReady = true; return; }
    if (m.type !== 'rhm/result' && m.type !== 'rhm/refusal') { note('MESSAGE_IGNORED', { type: m.type }); return; }
    const t0 = performance.now();
    const job = S.job; let reason = null;
    if (!job) reason = 'no job';
    else if (m.epoch !== job.epoch) reason = `epoch ${m.epoch} is not the current epoch ${job.epoch}`;
    else if (m.key !== job.key) reason = `key ${m.key} is not the current key ${job.key}`;
    else if (S.status !== 'COMPUTING') reason = `the current job is not computing (${S.status})`;
    else if (w !== S.worker) reason = 'message from a retired worker';
    else if (!S.open) reason = 'the panel is closed';
    else { const now = readInputs(); if (!now.ok || now.key !== job.key) reason = 'the host or the precision changed before the result arrived'; }
    if (reason) { note('STALE_DISCARDED', { msgEpoch: m.epoch, msgKey: m.key, reason }); if (S.open) refresh(); return; }
    clearTimer();
    let entry;
    if (m.type === 'rhm/refusal') entry = { kind: 'REFUSED', refusal: `${m.name === 'ContractError' ? 'RH-domain refusal' : 'build error'} (${m.message})` };
    else {
      let rec = null; try { rec = JSON.parse(m.text); } catch (_) { rec = null; }
      const inp = job.inputs;
      if (!rec || !rec.atom || rec.atom.B !== inp.B || rec.atom.mode !== inp.mode || rec.atom.factorial_index !== inp.factorial_index || rec.precision_bits !== inp.precision_bits
          || !rec.source || rec.source.host_build !== SOURCE.host_build || rec.source.host_sha256 !== SOURCE.host_sha256 || C.canonicalText(rec) !== m.text) {
        failJob('the worker result is not bound to the requested inputs and identity'); return;
      }
      entry = { kind: 'READY', text: m.text };
    }
    S.timings.push({ key: job.key, workerMs: m.ms, roundTripMs: performance.now() - job.t0, kind: entry.kind }); if (S.timings.length > 500) S.timings.shift();
    CACHE.set(job.key, entry); if (CACHE.size > CACHE_MAX) CACHE.delete(CACHE.keys().next().value);
    S.job = null;
    apply(job, entry);
    S.mainMs.push({ where: 'result', ms: performance.now() - t0 }); if (S.mainMs.length > 500) S.mainMs.shift();
  }
  function apply(sel, entry) {
    if (entry.kind === 'REFUSED') {
      S.status = 'REFUSED'; S.refusal = entry.refusal; note('REFUSED', { reason: S.refusal });
      statusEl.className = 'rhm-row rhm-bad';
      statusEl.textContent = `${S.refusal} for B = ${sel.inputs.B}. The record's domain is 1 ≤ B ≤ 2^256 − 1 with primes ≤ 10^6, exponents ≤ 64, at most 16 primes. Nothing is shown for this atom; export is blocked.`;
      root.dataset.key = sel.key; root.dataset.status = 'REFUSED'; root.dataset.seq = String(S.seq);
      return;
    }
    const rec = JSON.parse(entry.text);
    S.status = 'READY'; S.record = rec; S.text = entry.text; S.refusal = null; note('READY');
    statusEl.className = 'rhm-row rhm-good';
    statusEl.textContent = `record for B = ${sel.inputs.B} (${sel.inputs.mode}${sel.inputs.factorial_index ? ', ' + sel.inputs.factorial_index + '!' : ''}) at precision_bits ${sel.inputs.precision_bits}: built by the BigInt port of the accepted reference.`;
    showRecord(sel, rec, entry.text);
  }

  /* ---------------- refresh (reads the host; never writes it) ---------------- */
  function refresh() {
    if (!S.open) return;
    const t0 = performance.now();
    S.reads++;
    const sel = readInputs();
    if (!sel.ok) {
      if (S.status === 'HOST_ERROR' && S.refusal === sel.reason) return;
      clear(); clearTimer(); S.job = null; S.status = 'HOST_ERROR'; S.refusal = sel.reason; note('HOST_ERROR', { reason: sel.reason });
      statusEl.className = 'rhm-row rhm-bad'; statusEl.textContent = `unavailable: ${sel.reason}. Nothing is shown; export is blocked.`;
      root.dataset.status = 'HOST_ERROR'; root.dataset.seq = String(S.seq); return;
    }
    if (S.key === sel.key && ['READY', 'REFUSED', 'COMPUTING', 'ERROR'].includes(S.status)) return;
    clear();                                               // nothing from an earlier atom or precision survives a change
    S.key = sel.key; S.inputs = sel.inputs; S.refusal = null;
    const hit = CACHE.get(sel.key);
    if (hit) { if (S.job) { note('SUPERSEDED', { supersededKey: S.job.key, supersededEpoch: S.job.epoch }); S.job = null; clearTimer(); } S.epoch += 1; apply(sel, hit); }
    else startJob(sel);
    S.mainMs.push({ where: 'refresh', ms: performance.now() - t0 }); if (S.mainMs.length > 500) S.mainMs.shift();
  }

  /* ---------------- export (one action; R3: synchronous refresh, then refuse or emit bound to the current inputs) ---------------- */
  function exportRecord() {
    if (!S.open) return { ok: false, reason: 'the panel is closed' };
    refresh();
    const now = readInputs();
    if (!now.ok) return { ok: false, reason: now.reason };
    if (S.status === 'COMPUTING') return { ok: false, reason: 'the record for the current inputs is still being computed' };
    if (S.status !== 'READY') return { ok: false, reason: S.refusal || S.status };
    if (S.key !== now.key) return { ok: false, reason: 'the record is not bound to the current inputs' };
    const rec = JSON.parse(S.text);
    if (rec.atom.B !== now.inputs.B || rec.atom.mode !== now.inputs.mode || rec.atom.factorial_index !== now.inputs.factorial_index || rec.precision_bits !== now.inputs.precision_bits)
      return { ok: false, reason: 'the record does not carry the current inputs' };
    const filename = `rh-atom-margins-B${now.inputs.B}-${now.inputs.mode}-bits${now.inputs.precision_bits}.json`;
    S.lastExport = { key: S.key, filename }; note('EXPORT', { filename });
    return { ok: true, text: S.text, filename, key: S.key };
  }
  exportBtn.addEventListener('click', () => {
    const x = exportRecord();
    if (!x.ok) { exportMsg.textContent = `export refused: ${x.reason}`; return; }
    const url = URL.createObjectURL(new Blob([x.text], { type: 'application/json' })), a = el('a', { href: url, download: x.filename });
    document.body.append(a); a.click(); a.remove(); setTimeout(() => URL.revokeObjectURL(url), 1000);
    exportMsg.textContent = `exported ${x.filename}`;
  });

  /* ---------------- wiring ---------------- */
  let pollTimer = null;
  toggle.onclick = () => {
    S.open = !S.open; root.hidden = !S.open; toggle.setAttribute('aria-expanded', String(S.open));
    if (S.open) { note('OPEN'); refresh(); pollTimer = setInterval(refresh, 250); }
    else {
      clearInterval(pollTimer); pollTimer = null; clearTimer();
      if (S.status === 'COMPUTING') note('CANCELLED', { reason: 'panel closed' });
      killWorker('panel closed'); clear(); S.job = null; S.status = 'CLOSED'; S.refusal = null; note('CLOSED');
      statusEl.textContent = ''; statusEl.className = 'rhm-row'; exportMsg.textContent = '';
    }
  };
  bitsSel.addEventListener('change', () => refresh());
  // Bubble-phase listeners run after the host's own control handlers, so a host change is read in the same event
  // turn; they only read the host. The 250 ms poll covers every other path.
  for (const type of ['click', 'change', 'keyup']) document.addEventListener(type, () => { if (S.open) refresh(); }, { passive: true });
  // Keyboard isolation (the host's pattern): navigation keys inside the panel never reach the host's window keydown
  // (<-/-> step phi3, Shift+<-/-> step s). No preventDefault; Esc stays global.
  const ISOLATED_KEYS = new Set(['ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown', 'Home', 'End', 'PageUp', 'PageDown']);
  root.addEventListener('keydown', e => { if (ISOLATED_KEYS.has(e.key)) e.stopPropagation(); });

  /* ---------------- diagnostics: getters are observational; exportRecord and injectHoldOnce are actions ---------------- */
  const copy = x => (x === null || x === undefined ? x : JSON.parse(JSON.stringify(x)));
  window.McombRhMarginDiagnosticsV1 = Object.freeze({
    status: () => ({ open: S.open, visible: !root.hidden, status: S.status, key: S.key, inputs: copy(S.inputs), refusal: S.refusal, epoch: S.epoch, seq: S.seq, reads: S.reads,
      jobsStarted: S.jobsStarted, pending: S.job ? { epoch: S.job.epoch, key: S.job.key } : null, workerAlive: !!S.worker, workerReady: S.workerReady, cacheSize: CACHE.size,
      exportEnabled: !exportBtn.disabled, polling: pollTimer !== null, bits: bitsSel.value, lastExport: copy(S.lastExport), build: { ...SOURCE } }),
    sections: () => Object.fromEntries(SECTIONS.map(id => { const n = $(id); return [id.slice(4), { key: n.dataset.key || '', b: n.dataset.b || '', mode: n.dataset.mode || '', idx: n.dataset.idx || '', bits: n.dataset.bits || '', text: n.textContent }]; })),
    record: () => (S.text ? JSON.parse(S.text) : null),
    canonicalText: () => S.text,
    timings: () => S.timings.map(t => ({ ...t })),
    mainThread: () => S.mainMs.map(t => ({ ...t })),
    history: () => HIST.map(h => ({ ...h })),
    identity: () => ({ hostBuild: PINS.hostBuild, hostSha256: PINS.hostSha256, identity: copy(PINS.identity) }),
    exportRecord: () => exportRecord(),
    injectHoldOnce: ms => { S.holdNextMs = Number.isSafeInteger(ms) && ms > 0 && ms <= 20000 ? ms : 0; return S.holdNextMs; },   // test hook: delays the next worker reply only
  });
})();
