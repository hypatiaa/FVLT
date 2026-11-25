/* Reciprocal link v0.1 — the accepted divisor reciprocal record, shown beside the frozen Basel panel.
 *
 * Idea (1/n is also n/1: two readouts of one atom, keeping the construction visible beneath the evaluated
 * value): saphir. Record form and scope: Astra (RECIPROCAL_RECORD_SPEC_v0_1_1, delta audit PASS). Build:
 * worker B (Claude), from handoff B v0.2.
 *
 * Read only. The panel reads the host shell base B through liftSourceSnapshot(), the Basel atom through
 * McombBaselLinkDiagnosticsV1.atom(), and the Basel selection through the stamps of #bz-sel-d
 * (data-atom / data-failed / data-value). It never calls selectDivisor (a setter), never parses the
 * formatted factorization text, never wraps or replaces a frozen function and never writes host or Basel
 * state. Each read follows handoff B §"Selection bridge" in order:
 *   1. B_host from liftSourceSnapshot().shellBase, as a canonical integer string;
 *   2. A = atom(), with A.B === B_host;
 *   3. #bz-sel-d: data-atom === B_host, data-failed absent, data-value present;
 *   4. data-value parsed as a canonical positive decimal string within the 400-digit domain, before BigInt;
 *   5. d | B, and d in Div(B) as given by A's factorization;
 *   6. only then the record is built (BigInt port) and validated, and its canonical bytes round-trip
 *      through the port of the accepted raw loader.
 * Any failed step shows "unavailable" with the reason in words and blocks export. The readout is stamped
 * with (B, d) and cleared before any change of either is shown. Tracking: a 250 ms poll while #bz-panel is
 * open, plus MutationObservers on #bz-sel-d's stamp attributes and on #bz-panel's hidden attribute.
 * #rr-panel is its own section, the next sibling after #bz-panel, outside every node the Basel renderer
 * clears; it is shown only while #bz-panel is not hidden. Navigation keys inside it stop at its root.
 * Export (optional in the handoff): the unchanged record's canonical bytes only. The provenance envelope
 * is NOT built in this version (Astra implementation note 2). Exact values are shown as text; no floats.
 */
(() => {
  'use strict';
  const R = window.McombReciprocalLinkCoreV1, PINS = window.McombReciprocalLinkBuildPins, BZ = window.McombBaselLinkDiagnosticsV1;
  const $ = id => document.getElementById(id);
  if (!R || !PINS || !BZ || typeof BZ.atom !== 'function' || typeof liftSourceSnapshot !== 'function' || !$('bz-panel') || !$('bz-sel-d'))
    throw Error('Reciprocal link: core, build pins, Basel diagnostics or host seam missing');
  const bzPanel = $('bz-panel'), selEl = $('bz-sel-d');
  const POS = /^[1-9][0-9]*$/;
  const SUP = { 0: '⁰', 1: '¹', 2: '²', 3: '³', 4: '⁴', 5: '⁵', 6: '⁶', 7: '⁷', 8: '⁸', 9: '⁹' };
  const sup = s => String(s).split('').map(c => SUP[c]).join('');
  const el = (tag, attrs = {}, text = null) => { const e = document.createElement(tag); for (const [k, v] of Object.entries(attrs)) e.setAttribute(k, v); if (text !== null) e.textContent = text; return e; };

  /* ---------------- DOM (own section, sibling after #bz-panel) ---------------- */
  const style = el('style');
  style.textContent = `
  #rr-panel{margin:0 0 10px;padding:8px 10px;border:1px solid var(--line-grid);border-radius:6px;background:var(--bg-card);color:var(--text-bright);font-size:12px;min-width:0;overflow-wrap:anywhere}
  #rr-panel h3{margin:0 0 4px;font-size:13px} #rr-panel h4{margin:8px 0 4px;font-size:12px;color:var(--text-mid);font-weight:600}
  #rr-panel .rr-dim{color:var(--text-dim)} #rr-panel .rr-good{color:var(--accent-good)} #rr-panel .rr-bad{color:var(--accent-defend)}
  #rr-panel .rr-exact{font-family:ui-monospace,Consolas,monospace;font-size:11.5px}
  #rr-panel .rr-kv{display:grid;grid-template-columns:max-content minmax(0,1fr);gap:2px 10px} #rr-panel .rr-kv dt{color:var(--text-dim)} #rr-panel .rr-kv dd{margin:0}
  #rr-panel table{border-collapse:collapse;font-variant-numeric:tabular-nums} #rr-panel td,#rr-panel th{border:1px solid #1f1f33;padding:2px 8px;text-align:right}
  #rr-panel th{color:var(--text-dim);font-weight:500} #rr-panel .rr-row{display:flex;flex-wrap:wrap;gap:8px 14px;align-items:center;margin-top:6px}
  #rr-panel pre{white-space:pre-wrap;word-break:break-all;margin:4px 0 0;font-size:10.5px}
  #rr-panel button{background:var(--bg-inset);color:var(--text-bright);border:1px solid var(--line-grid);border-radius:3px;font:inherit;padding:2px 8px}
  #rr-panel button:disabled{opacity:.5}`;
  document.head.append(style);
  const root = el('section', { id: 'rr-panel', hidden: '', 'aria-label': 'Divisor reciprocal record' });
  root.append(
    el('h3', {}, 'Reciprocal record of the selected divisor · two readouts of one atom, not d = 1/d'),
    el('div', { class: 'rr-dim' }, 'For the divisor d selected in the Basel panel above: its prime-labelled exponents, each exact local factor |d|ₚ = p^(−eₚ), the archimedean readout |d|∞ = d and the finite readout ∏ₚ|d|ₚ = 1/d, and their verified balance. d and 1/d stay distinct rationals; the record keeps both readouts and the labelled factors that balance them. Reads only; never writes the host or the Basel panel.'),
    el('div', { id: 'rr-status', role: 'status' }),
    el('div', { id: 'rr-body' }),
    (() => { const r = el('div', { class: 'rr-row' });
      r.append(el('button', { id: 'rr-export', type: 'button', disabled: '', title: 'Download the record as canonical JSON bytes (the accepted record format, unchanged; no provenance envelope)' }, 'export record (canonical JSON)'),
        el('span', { id: 'rr-export-msg', class: 'rr-dim' }));
      return r; })(),
    (() => { const d = el('details', { id: 'rr-bytes' }); d.append(el('summary', {}, 'canonical bytes'), el('pre', { id: 'rr-bytes-text', class: 'rr-exact' })); return d; })(),
    el('div', { class: 'rr-dim', style: 'margin-top:6px' }, 'Idea: saphir (1/n is also n/1). Record form: Astra. Panel: worker B (Claude). Record schema 0.1.0, unchanged.'));
  bzPanel.after(root);

  /* ---------------- state ---------------- */
  const S = { status: 'CLOSED', key: null, B: null, d: null, reason: null, text: null, seq: 0, reads: 0 };
  const HIST = [];
  const note = (status, B, d, reason) => { S.seq++; HIST.push({ seq: S.seq, status, B, d, reason }); if (HIST.length > 64) HIST.shift(); };

  /* ---------------- the selection bridge (handoff B, H4) ---------------- */
  function readSelection() {
    // 1. the live host shell base
    let h; try { h = liftSourceSnapshot(); } catch (e) { return { ok: false, reason: `the host snapshot could not be read (${e.message})` }; }
    const Bn = h && h.shellBase;
    if (!Number.isSafeInteger(Bn) || Bn < 1) return { ok: false, reason: `the host shell base ${Bn} is not a positive safe integer` };
    const Bh = String(Bn);
    // 2. the Basel atom, same B
    let A; try { A = BZ.atom(); } catch (e) { return { ok: false, reason: `the Basel atom could not be read (${e.message})` }; }
    if (!A) return { ok: false, reason: 'the Basel panel has no atom' };
    if (typeof A.B !== 'string' || A.B !== Bh) return { ok: false, reason: `the Basel atom B = ${A.B} is not the host shell base B = ${Bh} (the Basel panel has not read the host yet)` };
    // 3. the selected-section stamps
    const ds = selEl.dataset;                               // all three stamp conditions must hold; the failure flag is reported first
    if (ds.failed !== undefined) return { ok: false, reason: 'the Basel selected-divisor section failed to render' };
    if (ds.atom !== Bh) return { ok: false, reason: ds.atom === undefined || ds.atom === '' ? `the Basel selected divisor carries no atom stamp for B = ${Bh}` : `the Basel selected divisor is stamped for B = ${ds.atom}, not the host shell base B = ${Bh}` };
    if (ds.value === undefined) return { ok: false, reason: 'no divisor is selected in the Basel panel' };
    // 4. canonical positive decimal within the domain, before BigInt
    const dt = ds.value;
    if (typeof dt !== 'string' || dt.length > R.MAX_DIGITS || !POS.test(dt)) return { ok: false, reason: `the selected divisor text "${String(dt).slice(0, 40)}" is not a canonical positive integer of at most 400 digits` };
    // 5. membership: A's factorization is checked against B, then d | B and d in Div(B)
    if (!Array.isArray(A.factors) || A.factors.length > 16) return { ok: false, reason: 'the Basel atom factorization is malformed' };
    const fac = [];
    for (const f of A.factors) {
      if (!Array.isArray(f) || f.length !== 2 || typeof f[0] !== 'string' || f[0].length > R.MAX_DIGITS || !POS.test(f[0]) || !Number.isSafeInteger(f[1]) || f[1] < 1 || f[1] > 64)
        return { ok: false, reason: 'the Basel atom factorization is malformed' };
      fac.push([BigInt(f[0]), BigInt(f[1])]);
    }
    const B = BigInt(Bh);
    let prod = 1n; for (const [p, a] of fac) { prod *= p ** a; if (prod > B) break; }   // bounded: stops once past B
    if (prod !== B) return { ok: false, reason: `the Basel factorization does not multiply to B = ${Bh}` };
    const d = BigInt(dt);
    if (B % d !== 0n) return { ok: false, reason: `the selected d = ${dt} does not divide B = ${Bh}` };
    let rem = d; const es = fac.map(([p, a]) => { let e = 0n; while (e < a && rem % p === 0n) { rem /= p; e++; } return e; });
    if (rem !== 1n) return { ok: false, reason: `the selected d = ${dt} is not in Div(B) under the Basel factorization` };
    return { ok: true, B: Bh, d: dt, fac, es };
  }

  /* ---------------- render ---------------- */
  const body = $('rr-body'), statusEl = $('rr-status'), exportBtn = $('rr-export'), exportMsg = $('rr-export-msg'), bytesText = $('rr-bytes-text');
  function clear() {
    body.replaceChildren(); bytesText.textContent = ''; exportBtn.disabled = true; exportMsg.textContent = '';
    for (const k of ['atom', 'd', 'status', 'seq']) delete root.dataset[k];
    S.key = null; S.B = null; S.d = null; S.text = null;
  }
  function showUnavailable(reason) {
    if (S.status === 'UNAVAILABLE' && S.reason === reason && S.key === null) return;
    clear(); S.status = 'UNAVAILABLE'; S.reason = reason; note('UNAVAILABLE', null, null, reason);
    statusEl.className = 'rr-bad'; statusEl.textContent = `unavailable: ${reason}. Export is blocked.`;
    root.dataset.status = 'UNAVAILABLE'; root.dataset.seq = String(S.seq);
  }
  const facText = rec => rec.atom.factors.length ? rec.atom.factors.map(f => f.exponent === '1' ? f.prime : f.prime + sup(f.exponent)).join('·') : '1 (empty product)';
  const q = r => `${r.num}/${r.den}`;
  function showRecord(sel) {
    clear();                                              // the old (B, d) readout never survives a change
    let rec, text;
    try {
      rec = R.build(sel.fac, sel.es); R.validate(rec);
      text = R.canonicalText(rec);
      const back = R.load(R.canonicalBytes(rec));          // raw round trip through the port of the accepted loader
      if (R.canonicalText(back) !== text || back.atom.N !== sel.B || back.selected.d !== sel.d) throw new R.ContractError('round trip or (B, d) binding failed');
    } catch (e) { S.status = 'IDLE'; showUnavailable(`the record could not be built for B = ${sel.B}, d = ${sel.d} (${e.message})`); return; }
    S.status = 'READY'; S.reason = null; S.key = sel.B + '|' + sel.d; S.B = sel.B; S.d = sel.d; S.text = text;
    note('READY', sel.B, sel.d, null);
    statusEl.className = 'rr-good';
    statusEl.textContent = `record for B = ${sel.B}, d = ${sel.d}: built, validated and raw round-tripped by the port of the accepted checker.`;
    const kv = el('dl', { class: 'rr-kv' });
    const row = (k, v, cls = 'rr-exact', id = null) => { kv.append(el('dt', {}, k)); const dd = el('dd', id ? { class: cls, id } : { class: cls }, v); kv.append(dd); return dd; };
    row('atom (shell base B)', `B = ${rec.atom.N} = ${facText(rec)}`, 'rr-exact', 'rr-atom');
    row('selected divisor', `d = ${rec.selected.d}`, 'rr-exact', 'rr-d');
    row('exponents eₚ', rec.selected.exponents.length ? rec.selected.exponents.map(x => `e${x.prime} = ${x.exponent}`).join(', ') : 'none (B = 1: no primes)', 'rr-exact', 'rr-exps');
    body.append(el('h4', {}, 'Identity'), kv);
    body.append(el('h4', {}, 'Local factors |d|ₚ = p^(−eₚ), for every prime p | B'));
    if (rec.local_factors.length) {
      const t = el('table', { id: 'rr-local' }), hr = el('tr'); ['p', 'eₚ', '|d|ₚ (exact)'].forEach(h => hr.append(el('th', {}, h))); t.append(hr);
      for (const lf of rec.local_factors) { const tr = el('tr', { 'data-p': lf.prime }); tr.append(el('td', {}, lf.prime), el('td', {}, lf.exponent), el('td', { class: 'rr-exact' }, q(lf.abs_p))); t.append(tr); }
      body.append(t);
    } else body.append(el('div', { class: 'rr-dim', id: 'rr-local' }, 'no primes: every product below is the empty product 1'));
    body.append(el('div', { class: 'rr-dim' }, 'Primes p not dividing B have |d|ₚ = 1; the record states this rather than listing them.'));
    const kv2 = el('dl', { class: 'rr-kv' }), row2 = (k, v, id) => { kv2.append(el('dt', {}, k), el('dd', { class: 'rr-exact', id }, v)); };
    row2('archimedean readout |d|∞', `${rec.readouts.archimedean}/1`, 'rr-arch');
    row2('finite readout ∏ₚ |d|ₚ', q(rec.readouts.finite_product), 'rr-fin');
    body.append(el('h4', {}, 'Two readouts of one atom'), kv2);
    const kv3 = el('dl', { class: 'rr-kv' }), row3 = (k, v, id) => { kv3.append(el('dt', {}, k), el('dd', { class: 'rr-exact', id }, v)); };
    row3('reconstructed d = ∏ p^eₚ', rec.balance.reconstructed_d, 'rr-recon');
    row3('product of the local factors', q(rec.balance.product_of_local_factors), 'rr-prod');
    row3('|d|∞ · ∏ₚ |d|ₚ', `${rec.readouts.archimedean}/1 · ${q(rec.readouts.finite_product)} = ${q(rec.balance.archimedean_times_finite)}`, 'rr-bal');
    row3('equals one', rec.balance.equals_one === true ? 'true (exact rational 1/1, verified)' : 'false', 'rr-one');
    body.append(el('h4', {}, 'Verified balance'), kv3, el('div', { class: 'rr-dim rr-exact', id: 'rr-note', style: 'margin-top:4px' }, `note: ${rec.note}`));
    bytesText.textContent = text; exportBtn.disabled = false;
    root.dataset.atom = sel.B; root.dataset.d = sel.d; root.dataset.status = 'READY'; root.dataset.seq = String(S.seq);
  }

  /* ---------------- tracking ---------------- */
  let pollTimer = null;
  function refresh() {
    S.reads++;
    if (bzPanel.hidden) {                                   // shown only while the Basel panel is open
      if (!root.hidden || S.status !== 'CLOSED') { clear(); root.hidden = true; S.status = 'CLOSED'; S.reason = null; note('CLOSED', null, null, null); statusEl.textContent = ''; statusEl.className = ''; }
      if (pollTimer !== null) { clearInterval(pollTimer); pollTimer = null; }
      return;
    }
    if (pollTimer === null) pollTimer = setInterval(refresh, 250);
    const sel = readSelection();
    if (!sel.ok) showUnavailable(sel.reason);
    else if (!(S.status === 'READY' && S.key === sel.B + '|' + sel.d)) showRecord(sel);
    root.hidden = false;                                    // made visible only after a coherent read or an explicit unavailable
  }
  new MutationObserver(refresh).observe(bzPanel, { attributes: true, attributeFilter: ['hidden'] });
  new MutationObserver(refresh).observe(selEl, { attributes: true, attributeFilter: ['data-value', 'data-atom', 'data-failed'] });

  /* ---------------- export (record bytes only; blocked unless a fresh read is coherent) ---------------- */
  function exportRecord() {
    refresh();
    if (S.status !== 'READY') return { ok: false, reason: S.status === 'CLOSED' ? 'the Basel panel is closed' : S.reason };
    return { ok: true, text: S.text, filename: `reciprocal-record-B${S.B}-d${S.d}.json`, B: S.B, d: S.d };
  }
  exportBtn.addEventListener('click', () => {
    const x = exportRecord();
    if (!x.ok) { exportMsg.textContent = `export blocked: ${x.reason}`; return; }
    const url = URL.createObjectURL(new Blob([x.text], { type: 'application/json' })), a = el('a', { href: url, download: x.filename });
    document.body.append(a); a.click(); a.remove(); setTimeout(() => URL.revokeObjectURL(url), 1000);
    exportMsg.textContent = `exported ${x.filename}`;
  });
  const ISOLATED_KEYS = new Set(['ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown', 'Home', 'End', 'PageUp', 'PageDown']);
  root.addEventListener('keydown', e => { if (ISOLATED_KEYS.has(e.key)) e.stopPropagation(); });

  window.McombReciprocalLinkDiagnosticsV1 = Object.freeze({
    status: () => ({ visible: !root.hidden, status: S.status, B: S.B, d: S.d, reason: S.reason, seq: S.seq, reads: S.reads, exportEnabled: !exportBtn.disabled,
                     polling: pollTimer !== null, build: { host_build: PINS.hostBuild, host_sha256: PINS.hostSha256 } }),
    poll: () => { refresh(); return { status: S.status, B: S.B, d: S.d, reason: S.reason, seq: S.seq }; },
    readSelection: () => { const s = readSelection(); return s.ok ? { ok: true, B: s.B, d: s.d, exponents: s.es.map(String) } : s; },
    canonicalText: () => S.text,
    record: () => (S.text ? JSON.parse(S.text) : null),
    exportRecord: () => { const x = exportRecord(); return x.ok ? { ok: true, text: x.text, filename: x.filename } : x; },
    history: () => HIST.map(h => ({ ...h })),
  });
  refresh();
})();
