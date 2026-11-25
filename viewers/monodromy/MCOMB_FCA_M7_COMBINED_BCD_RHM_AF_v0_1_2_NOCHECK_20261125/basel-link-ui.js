/* Basel link v0.1.2 — the divisor-cone readout linked into the Fourier host (additive, opt-in).
 *
 * v0.1.2 repairs Astra's delta-audit F2 (keyboard isolation): navigation keys pressed inside the panel
 * (Arrow keys, Home, End, PageUp, PageDown) stop propagating at the panel root, so the host's window-level
 * shortcuts (←/→ step φ₃, Shift+←/→ step s) no longer fire while a panel control has focus. No
 * preventDefault: the native range/select/text behaviour is untouched. Escape is not isolated: the host's
 * Esc ↔ fullscreen toggle is a whole-viewer view action that changes no arithmetic state. Retries now also
 * cover a failed re-render on an unchanged host key (β, cutoff, resize): 3 attempts in total per trigger.
 *
 * v0.1.1 repairs Astra's audit F1 (stale M7 success and mixed-atom readouts after a host-valid but
 * M7-unsupported atom such as B = 1000003): the M7 domain is checked before definition(); any unexpected
 * host transform error is caught locally and becomes an explicit UNAVAILABLE; every render first clears
 * every section, then renders each section independently and stamps it with the atom it describes
 * (data-atom), so no readout can present an older atom as current; stored and visible errors are cleared
 * on recovery; a failed render is retried on the next poll (at most 3 times per host key).
 *
 * Host seam (read only): liftSourceSnapshot().shellBase / shellMode / n1, polled every 250 ms while the
 * panel is open. The panel never writes host state; shells are stepped with the host's own n1 buttons or
 * direct-base input. It never reads the host spin s / sExact, and the Dirichlet exponent beta is panel-local.
 * The atom is the host shell base B (the host's own N is its orbit, N = B + 1 - phi3, and is NOT used here).
 *
 * Divisor route: the host's own M7 transform, window.McombFCAV1.transforms, fed the accepted v0.1.2 adapter
 * g(d) = (B/d)^b, normalised by B^b, Mobius round trip asserted, cross-checked against the exact Euler route
 * of basel-core.js (prototype v0.1.3, byte-identical). Prime-strip and certified-log quantities are
 * PROTOTYPE-ONLY display values (not in the accepted schema; no export). Floats are used only to draw.
 */
(() => {
  'use strict';
  const C = window.BaselCore, F = window.McombFCAV1, PINS = window.McombBaselLinkBuildPins;
  if (!C || !F || !PINS || typeof liftSourceSnapshot !== 'function') throw Error('Basel link modules or host seam missing');
  const $ = id => document.getElementById(id);
  const el = (tag, attrs = {}, text = null) => { const e = document.createElement(tag); for (const [k, v] of Object.entries(attrs)) e.setAttribute(k, v); if (text !== null) e.textContent = text; return e; };
  const SUP = { '-': '⁻', 0: '⁰', 1: '¹', 2: '²', 3: '³', 4: '⁴', 5: '⁵', 6: '⁶', 7: '⁷', 8: '⁸', 9: '⁹' };
  const sup = n => String(n).split('').map(c => SUP[c]).join('');
  const one = C.frac(1n);

  const panel = { open: false, b: 2, P: 30, hoverP: null, selKey: null, hostKey: null, pendingKey: null, fails: 0, sameKeyAttempts: 0, lastRenderOk: true, atom: null, m7: null, error: null,
                  faults: new Map(), faultM7: false };   // faults / faultM7: test-only injection via the diagnostics object
  let pollTimer = null;

  /* ---------------- exact -> display ---------------- */
  function sci(f, sig = 12, plainMin = -4) {
    if (f.n === 0n) return '0';
    const neg = f.n < 0n, n = neg ? -f.n : f.n, d = f.d;
    let e = n.toString().length - d.toString().length;
    const atLeast = x => (x >= 0 ? n >= d * 10n ** BigInt(x) : n * 10n ** BigInt(-x) >= d);
    if (!atLeast(e)) e -= 1;
    const k = sig - 1 - e;
    const m = (k >= 0 ? (n * 10n ** BigInt(k)) / d : n / (d * 10n ** BigInt(-k))).toString();
    let s;
    if (e >= 0 && e <= 6) s = m.slice(0, e + 1) + '.' + m.slice(e + 1);
    else if (e < 0 && e >= plainMin) s = '0.' + '0'.repeat(-e - 1) + m;
    else s = m[0] + '.' + m.slice(1) + ' × 10' + sup(e);
    return (neg ? '−' : '') + s + '…';
  }
  const c3 = f => sci(f, 3, 0).replace(' × ', '×').replace(/…$/, '');
  const exactText = f => { const s = C.canon(f); return s.length <= 60 ? s : s.slice(0, 26) + '…' + s.slice(-26) + ` (${s.length} chars)`; };
  const facText = fac => fac.length ? fac.map(([p, a]) => a > 1 ? `${p}${sup(a)}` : `${p}`).join('·') : '1';
  const cmp = (a, b) => { const x = a.n * b.d - b.n * a.d; return x > 0n ? 1 : x < 0n ? -1 : 0; };
  const arrow = s => (s > 0 ? '↑' : s < 0 ? '↓' : '=');

  /* ---------------- host seam (read only) ---------------- */
  function factorize(B) {                          // host bases are <= 13! < 2^33: trial division is bounded
    let n = BigInt(B); const out = [];
    for (let p = 2n; p * p <= n; p += (p === 2n ? 1n : 2n)) { let a = 0; while (n % p === 0n) { n /= p; a++; } if (a) out.push([p, a]); }
    if (n > 1n) out.push([n, 1]);
    return out;
  }
  function readHost() {
    const h = liftSourceSnapshot();
    const B = h.shellBase;
    if (!Number.isSafeInteger(B) || B < 1) return { error: `host base ${B} is not a positive safe integer` };
    return { mode: h.shellMode === 'factorial' ? 'factorial' : 'direct', B: BigInt(B), n1: h.shellMode === 'factorial' ? h.n1 : null };
  }

  /* ---------------- the host's own M7 transform (divisor route) ---------------- */
  const M7_MAX_PRIME = 1000000n, M7_MAX_FACTORS = 16, M7_MAX_EXPONENT = 64, M7_SHELL_BITS = 256;   // host M7 definition() domain
  function m7Route(atom, b) {
    const { fac, B } = atom, tau = C.divisorCount(fac);
    const bigP = fac.find(([p]) => p > M7_MAX_PRIME);
    if (bigP || fac.length > M7_MAX_FACTORS || fac.some(([, a]) => a > M7_MAX_EXPONENT) || B.toString(2).length > M7_SHELL_BITS)
      return { status: 'UNAVAILABLE', reason: 'M7_DOMAIN', words: bigP
        ? `unavailable: B has the prime factor ${bigP[0]} > 1,000,000, outside the host M7 domain (and outside the accepted schema's input domain; display only)`
        : 'unavailable: B is outside the host M7 domain (at most 16 primes ≤ 10⁶, exponents ≤ 64, B ≤ 256 bits)' };
    if (tau > 256) return { status: 'UNAVAILABLE', reason: 'M7_OBJECT_BUDGET', words: `unavailable: ${tau} divisors, above the M7 transform budget of 256` };
    if ((B ** BigInt(b)).toString(2).length > 256) return { status: 'UNAVAILABLE', reason: 'M7_VALUE_BITS', words: `unavailable: B^${b} exceeds the M7 256-bit value budget` };
    let def, es, input, t;
    try {
      def = F.definition({ N: String(B), factors: fac.map(([p, a]) => ({ prime: String(p), exponent: String(a) })), step: fac.map(() => '0'), m: 1 });
      es = F.tuples(def.orders);
      input = es.map(e => String((B / BigInt(F.value(def, e))) ** BigInt(b)));
      if (panel.faultM7) { panel.faultM7 = false; throw Error('injected M7 fault (test hook)'); }
      t = F.transforms(def, input);
    } catch (e) {                                   // never let a host refusal leave an older result on screen
      return { status: 'UNAVAILABLE', reason: 'M7_HOST_ERROR', words: `unavailable: the host M7 transform raised “${e.message}”` };
    }
    const roundTrip = t.mobiusInverse.length === input.length && t.mobiusInverse.every((x, i) => x === input[i]);
    if (!roundTrip) return { status: 'FAILED', reason: 'MOBIUS_ROUND_TRIP_MISMATCH', words: 'divisor route failed: Möbius round trip', input, t };
    const z = C.frac(BigInt(t.zeta[t.zeta.length - 1]), B ** BigInt(b));
    const euler = C.Z(fac, b);
    return { status: 'EXACT_RATIONAL', value: z, agree: C.canon(z) === C.canon(euler), tuples: es, input, zeta: t.zeta, inverse: t.mobiusInverse,
             relation: t.relation, objects: es.length, m7Version: F.VERSION };
  }

  /* ---------------- panel DOM ---------------- */
  const style = el('style');
  style.textContent = `
  #bz-panel{margin:6px 0 10px;padding:8px 10px;border:1px solid var(--line-grid);border-radius:6px;background:var(--bg-card);color:var(--text-bright);font-size:12px}
  #bz-panel h3{margin:0 0 6px;font-size:13px;color:var(--text-bright)}
  #bz-panel h4{margin:8px 0 4px;font-size:12px;color:var(--text-mid);font-weight:600}
  #bz-panel .bz-dim{color:var(--text-dim)} #bz-panel .bz-mid{color:var(--text-mid)}
  #bz-panel .bz-row{display:flex;flex-wrap:wrap;gap:8px 18px;align-items:center}
  #bz-panel .bz-grid{display:grid;grid-template-columns:minmax(0,1.3fr) minmax(0,1fr);gap:10px}
  @media (max-width:900px){#bz-panel .bz-grid{grid-template-columns:minmax(0,1fr)}}
  #bz-panel .bz-box{border:1px solid #1f1f33;border-radius:4px;padding:6px 8px;min-width:0;overflow-wrap:anywhere}
  #bz-panel .bz-kv{display:grid;grid-template-columns:max-content minmax(0,1fr);gap:2px 10px}
  #bz-panel .bz-kv dt{color:var(--text-dim)} #bz-panel .bz-kv dd{margin:0;font-variant-numeric:tabular-nums}
  #bz-panel .bz-exact{font-family:ui-monospace,Consolas,monospace;font-size:11px}
  #bz-panel .bz-good{color:var(--accent-good)} #bz-panel .bz-bad{color:var(--accent-defend)} #bz-panel .bz-warn{color:var(--accent-warn)}
  #bz-lattice{width:100%;height:340px;display:block;cursor:pointer}
  #bz-panel .bz-bar .head{display:flex;justify-content:space-between;gap:8px}
  #bz-panel .bz-bar .track{height:8px;background:#1f1f33;border-radius:4px;overflow:hidden;margin-top:2px}
  #bz-panel .bz-bar .fill{height:100%}
  #bz-panel .bz-axis{display:flex;justify-content:space-between;gap:8px;white-space:nowrap;color:var(--text-dim);font-size:10.5px;border-top:1px solid #1f1f33;margin-top:4px;padding-top:2px}
  #bz-panel .bz-axis span:nth-child(2){white-space:normal;text-align:center}
  #bz-pgrid{display:grid;grid-template-columns:repeat(auto-fill,minmax(112px,1fr));gap:5px}
  #bz-pgrid .cell{border:1px solid #1f1f33;border-radius:5px;padding:4px 6px;font-size:11px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;font-variant-numeric:tabular-nums}
  #bz-pgrid .cell .pp{font-size:14px;font-weight:700}
  #bz-pgrid .cell[data-state=present]{border-color:var(--accent-spine)} #bz-pgrid .cell[data-state=present] .pp{color:var(--accent-spine)}
  #bz-pgrid .cell[data-state=absent] .pp{color:#60a5fa} #bz-pgrid .cell[data-state=beyond]{border-style:dashed}
  #bz-pgrid .cell.hot{outline:2px solid var(--accent-warn)}
  #bz-pgrid .mini{height:4px;background:#1f1f33;border-radius:2px;margin-top:3px;overflow:hidden} #bz-pgrid .mini div{height:100%}
  #bz-stair,#bz-strip{width:100%;display:block} #bz-stair{height:120px} #bz-strip{height:190px}
  #bz-panel select,#bz-panel input{background:var(--bg-inset);color:var(--text-bright);border:1px solid var(--line-grid);border-radius:3px;font:inherit}`;
  document.head.append(style);
  const toggle = el('button', { id: 'bz-toggle', type: 'button', class: 'micro-button', 'aria-expanded': 'false', title: 'Opt-in divisor-cone readout Z_B(β) = Σ d^−β of the host shell base B' }, '∑ Basel cone');
  const sliderRow = $('s-direct-input').closest('.slider-row');
  sliderRow.querySelector('.s-direct-row').append(toggle);
  const root = el('section', { id: 'bz-panel', hidden: '', 'aria-label': 'Basel cone readout' });
  root.innerHTML = `
  <h3>Basel cone · Z<sub>B</sub>(β) = Σ<sub>d∣B</sub> d<sup>−β</sup> of the host shell base B · prototype link</h3>
  <div class="bz-dim">Reads the host shell base B only; never writes the host; ignores the host spin s. The host's own N (its orbit) is not the atom here. Step shells with the host's n₁ buttons or its direct base.</div>
  <div class="bz-row" style="margin-top:6px">
    <label>Dirichlet exponent β <input id="bz-beta" type="range" min="0" max="32" value="2" style="vertical-align:middle"></label>
    <output id="bz-beta-out" for="bz-beta">2</output>
    <label>prime cutoff P <select id="bz-cutoff"></select></label>
    <label>select divisor d <input id="bz-pick" type="text" inputmode="numeric" size="10"></label><span id="bz-pick-msg" class="bz-dim"></span>
  </div>
  <div class="bz-grid" style="margin-top:6px">
    <div class="bz-box"><h4 style="margin-top:0">Divisor lattice of B (height Ω(d)); disc area ∝ d<sup>−β</sup>; orange = selected subcone</h4><canvas id="bz-lattice" tabindex="0" aria-label="divisor lattice of the host shell base"></canvas></div>
    <div class="bz-box">
      <dl class="bz-kv">
        <dt>shell base B</dt><dd id="bz-atom"></dd>
        <dt>divisors τ(B)</dt><dd id="bz-tau"></dd>
        <dt>Z<sub>B</sub>(β)</dt><dd><span id="bz-z-dec"></span><br><span id="bz-z" class="bz-exact"></span></dd>
        <dt>divisor route</dt><dd id="bz-m7"></dd>
      </dl>
      <h4>Selected divisor</h4>
      <dl class="bz-kv">
        <dt>d</dt><dd id="bz-sel-d"></dd><dt>weight d<sup>−β</sup></dt><dd id="bz-sel-w"></dd><dt>subcone Z<sub>d</sub>(β)</dt><dd id="bz-sel-z"></dd>
      </dl>
      <h4>Gap to ζ(β)</h4><div id="bz-regime" class="bz-dim"></div><div id="bz-bars"></div>
    </div>
  </div>
  <div class="bz-box" style="margin-top:8px"><h4 style="margin-top:0">Prime strip (every prime ≤ P, present or absent) and π(x)</h4>
    <div id="bz-strip-note" class="bz-dim"></div><div id="bz-pgrid"></div><div id="bz-decomp" style="margin-top:5px"></div>
    <svg id="bz-stair" role="img" aria-label="prime-counting staircase"></svg><div id="bz-stair-note" class="bz-dim"></div></div>
  <div class="bz-box" style="margin-top:8px"><h4 style="margin-top:0">Factorial shells 1!…13! at this β (log scale; exact zeros in their own lane); cursor = host n₁ in factorial mode</h4>
    <svg id="bz-strip" role="img" aria-label="absent-prime and exponent-tail gaps across factorial shells"></svg>
    <div class="bz-dim">blue: absent primes ζ(β) − E · orange: exponent tails E − Z · grey dashed: total gap ζ(β) − Z. Shaded: shells that add a prime.</div></div>
  <div id="bz-error" class="bz-bad"></div>`;
  const csPanel = $('cs-panel');
  (csPanel || sliderRow).after(root);

  /* ---------------- state from the host ---------------- */
  function setAtom(h) {
    const fac = factorize(h.B), tuples = C.divisorTuples(fac);
    const nodes = tuples.map((e, i) => { const d = C.tupleValue(fac, e); return { i, e, d, om: e.reduce((s, x) => s + x, 0), lnd: Math.log(Number(d)) }; });
    const omMax = nodes.reduce((m, n) => Math.max(m, n.om), 0);
    const ranks = Array.from({ length: omMax + 1 }, () => []);
    nodes.forEach(n => ranks[n.om].push(n)); ranks.forEach(r => r.sort((a, b) => (a.d < b.d ? -1 : 1)));
    const key = e => e.join(','), index = new Map(nodes.map(n => [key(n.e), n])), edges = [];
    nodes.forEach(n => fac.forEach(([, a], j) => { if (n.e[j] < a) { const up = n.e.slice(); up[j]++; edges.push([n, index.get(key(up))]); } }));
    panel.atom = { ...h, fac, nodes, ranks, omMax, edges, index, key };
    panel.selKey = key(nodes[nodes.length - 1].e);         // select B itself: its subcone is the whole cone
  }
  function poll() {
    try {
      const h = readHost();
      if (h.error) { panel.atom = null; clearAll(); panel.error = h.error; $('bz-error').textContent = h.error; return; }
      const hk = `${h.mode}:${h.B}:${h.n1}`;
      if (hk === panel.hostKey) {                     // same host atom: retry a failed β / cutoff / resize re-render (3 attempts in total)
        if (!panel.lastRenderOk && panel.sameKeyAttempts < 3) { panel.sameKeyAttempts++; render(); }
        return;
      }
      if (hk !== panel.pendingKey) { panel.pendingKey = hk; panel.fails = 0; setAtom(h); }
      const ok = render();
      if (ok || ++panel.fails >= 3) { panel.hostKey = hk; panel.sameKeyAttempts = 3; }   // 3 attempts in total for a host change; they count as used
    } catch (e) { panel.atom = null; clearAll(); panel.error = e.message; $('bz-error').textContent = `host read failed: ${e.message}`; }
  }

  /* ---------------- lattice ---------------- */
  function draw() {
    const A = panel.atom, cv = $('bz-lattice'); if (!A || !cv.clientWidth) return;
    const dpr = window.devicePixelRatio || 1, W = cv.clientWidth, H = cv.clientHeight;
    cv.width = Math.round(W * dpr); cv.height = Math.round(H * dpr);
    const g = cv.getContext('2d'); g.setTransform(dpr, 0, 0, dpr, 0, 0); g.clearRect(0, 0, W, H);
    const padX = 14, padT = 30, padB = 20, rows = A.omMax; let minGap = Infinity;
    A.ranks.forEach((r, om) => { const y = rows ? H - padB - (H - padT - padB) * om / rows : H / 2, gap = (W - 2 * padX) / Math.max(r.length, 1);
      minGap = Math.min(minGap, gap); r.forEach((n, j) => { n.x = padX + gap * (j + 0.5); n.y = y; }); });
    const rowGap = rows ? (H - padT - padB) / rows : H;
    A.rMax = Math.max(2.5, Math.min(12, 0.46 * minGap, 0.42 * rowGap)); A.rRing = Math.max(1.5, Math.min(A.rMax, 4.2));
    const sel = A.index.get(panel.selKey), inSub = n => sel && n.e.every((x, j) => x <= sel.e[j]);
    g.strokeStyle = '#45456a'; g.globalAlpha = A.nodes.length > 400 ? 0.35 : 0.7; g.lineWidth = 0.6; g.beginPath();
    A.edges.forEach(([a, b]) => { g.moveTo(a.x, a.y); g.lineTo(b.x, b.y); }); g.stroke(); g.globalAlpha = 1;
    if (sel) { g.strokeStyle = '#f59e0b'; g.lineWidth = 1.2; g.beginPath(); A.edges.forEach(([a, b]) => { if (inSub(b)) { g.moveTo(a.x, a.y); g.lineTo(b.x, b.y); } }); g.stroke(); }
    A.nodes.forEach(n => {
      const s = inSub(n); g.beginPath(); g.arc(n.x, n.y, A.rRing, 0, 2 * Math.PI); g.fillStyle = s ? '#3b2a1c' : '#0e0e1a'; g.fill();
      g.lineWidth = 0.8; g.strokeStyle = s ? '#f59e0b' : '#45456a'; g.stroke();
      const r = A.rMax * Math.sqrt(Math.exp(-panel.b * n.lnd));       // display only
      if (r > 0.25) { g.beginPath(); g.arc(n.x, n.y, r, 0, 2 * Math.PI); g.fillStyle = '#60a5fa'; g.globalAlpha = 0.85; g.fill(); g.globalAlpha = 1; }
    });
    if (sel) { g.beginPath(); g.arc(sel.x, sel.y, Math.max(A.rRing, A.rMax * Math.sqrt(Math.exp(-panel.b * sel.lnd))) + 3, 0, 2 * Math.PI); g.lineWidth = 2; g.strokeStyle = '#fbbf24'; g.stroke(); }
    g.fillStyle = '#9999b3'; g.font = '11px system-ui,sans-serif'; g.textAlign = 'center';
    const unit = A.ranks[0][0], top = A.ranks[A.omMax][0];
    g.fillText('1', unit.x, unit.y + A.rMax + 12); if (A.omMax) g.fillText(`B = ${A.B}`, top.x, top.y - A.rMax - 5);
  }
  function nodeAt(x, y) {
    let best = null, bd = Infinity; panel.atom.nodes.forEach(n => { const d = Math.hypot(n.x - x, n.y - y); if (d < bd) { bd = d; best = n; } });
    return bd <= Math.max(panel.atom.rMax, 6) + 4 ? best : null;
  }

  /* ---------------- readouts ---------------- */
  function renderAtom() {
    const A = panel.atom, b = panel.b, z = C.Z(A.fac, b);
    $('bz-atom').textContent = `${A.mode === 'factorial' ? `${A.n1}! = ` : 'M = '}${A.B} = ${facText(A.fac)}`;
    $('bz-tau').textContent = String(A.nodes.length);
    $('bz-z-dec').textContent = sci(z); const ze = $('bz-z'); ze.textContent = exactText(z); ze.title = C.canon(z); ze.dataset.value = C.canon(z);
    const m = m7Route(A, b); panel.m7 = m; const box = $('bz-m7');
    box.dataset.status = m.status; box.dataset.reason = m.reason || ''; box.dataset.agree = m.status === 'EXACT_RATIONAL' ? String(m.agree) : '';
    box.dataset.value = m.status === 'EXACT_RATIONAL' ? C.canon(m.value) : '';
    if (m.status === 'EXACT_RATIONAL') box.innerHTML = `host M7 transform (${m.m7Version}, ${m.objects} objects): input (B/d)<sup>β</sup>, zeta ÷ B<sup>β</sup>; Möbius round trip: input recovered; `
      + (m.agree ? '<span class="bz-good">AGREE with the exact Euler route</span>' : '<span class="bz-bad">CROSS-CHECK FAILED: divisor ≠ Euler</span>');
    else box.innerHTML = `<span class="${m.status === 'FAILED' ? 'bz-bad' : 'bz-dim'}">${m.words}</span>; the exact Euler route stands alone`;
  }
  function renderSelected() {
    const A = panel.atom, n = A.index.get(panel.selKey), b = panel.b;
    const w = C.nodeWeight(n.d, b), zs = C.Z(C.subconeFactors(A.fac, n.e), b);
    $('bz-sel-d').textContent = `${n.d} = ${facText(C.subconeFactors(A.fac, n.e))}`; $('bz-sel-d').dataset.value = String(n.d);
    const sw = $('bz-sel-w'); sw.textContent = `${sci(w)} ${exactText(w)}`; sw.dataset.value = C.canon(w);
    const sz = $('bz-sel-z'); sz.textContent = `${sci(zs)} ${exactText(zs)}`; sz.dataset.value = C.canon(zs);
  }
  function logAxis(b, extra = []) {
    const rows = C.shellSeries(b), vals = rows.flatMap(r => [r.absent, r.tails, r.gap]).concat(extra).filter(v => v > 0);
    const lo = Math.floor(Math.log10(Math.min(...vals))); let hi = Math.ceil(Math.log10(Math.max(...vals))); if (hi === lo) hi += 1;
    return { rows, lo, hi, frac: v => (v > 0 ? Math.max(0, Math.min(1, (Math.log10(v) - lo) / (hi - lo))) : 0) };
  }
  function renderBars() {
    const A = panel.atom, b = panel.b, box = $('bz-bars'), zc = C.zetaComparison(A.fac, b);
    $('bz-regime').textContent = { 1: 'β = 1: the weights 1/d exhaust the harmonic series, which diverges; no finite ζ(1).',
      2: 'β = 2: the shells converge to the Basel value ζ(2) = π²/6.',
      3: 'β = 3: the shells converge to Apéry’s constant ζ(3) = 1.2020569031…, proved irrational by Apéry (1978); this convergence does not bear on that proof.' }[b] || '';
    box.dataset.available = String(zc.available);
    if (b === 1) {                                   // Astra: the harmonic boundary, kept finite and explicit
      const E1 = A.fac.reduce((t, [p]) => C.mul(t, C.fullFactor(Number(p), 1)), one);
      const omit = A.fac.reduce((t, [p, a]) => C.mul(t, C.sub(one, C.frac(1n, p ** BigInt(a + 1)))), one);
      const ok = C.canon(C.mul(E1, omit)) === C.canon(C.Z(A.fac, 1));
      box.dataset.identity = String(ok); box.dataset.e1 = C.canon(E1);
      const mert = A.mode === 'factorial' ? ` For B = ${A.n1}!: E = ∏<sub>p≤${A.n1}</sub>(1 − 1/p)<sup>−1</sup>, which grows like e<sup>γ</sup> log k (Mertens); e<sup>γ</sup> log ${A.n1} ≈ ${(Math.exp(0.5772156649015329) * Math.log(A.n1)).toFixed(4)} (asymptotic comparison only).` : '';
      box.innerHTML = `<div class="bz-dim">ζ(1) diverges, but the finite factors do not: E<sub>B</sub>(1) = B/φ(B) = <span class="bz-exact" title="${C.canon(E1)}">${exactText(E1)}</span>, `
        + `and Z<sub>B</sub>(1) = E<sub>B</sub>(1) · ∏<sub>p|B</sub>(1 − p<sup>−(v+1)</sup>) = <span class="bz-exact">${exactText(C.mul(E1, omit))}</span> `
        + `<span class="${ok ? 'bz-good' : 'bz-bad'}">${ok ? '(exact identity holds)' : '(identity FAILED)'}</span>. The second product is exactly what the finite exponent bounds omit.${mert}</div>`;
      return;
    }
    if (!zc.available) { box.innerHTML = `<div class="bz-dim">${zc.words}</div>`; return; }
    const gapLo = C.parseDec(zc.gap[0]), absLo = C.parseDec(zc.absent[0]);
    const ax = logAxis(b, [C.toNumber(gapLo), C.toNumber(absLo), C.toNumber(zc.tails)]);
    const prev = A.mode === 'factorial' && A.n1 > 1 ? C.zetaComparison(C.factorialFactors(A.n1 - 1), b) : null;
    const dirs = prev ? { gap: arrow(cmp(gapLo, C.parseDec(prev.gap[0]))), absent: arrow(cmp(prev.E, zc.E)), tails: arrow(cmp(zc.tails, prev.tails)) } : { gap: '', absent: '', tails: '' };
    const width = x => (100 * ax.frac(C.toNumber(x))).toFixed(3), gapF = C.toNumber(gapLo);
    const bar = (id, label, col, x, dir, data, share) => `<div class="bz-bar" id="${id}" data-dir="${dir}" data-width="${width(x)}" ${data}><div class="head"><span>${dir} ${label}</span>`
      + `<span class="bz-exact">${x.n === 0n ? '0 (exact)' : sci(x)}</span></div><div class="track">${x.n === 0n ? '' : `<div class="fill" style="width:${width(x)}%;background:${col}"></div>`}</div>`
      + (share ? `<div class="bz-dim">${x.n === 0n ? 'exactly 0: no bar' : (100 * C.toNumber(x) / gapF).toPrecision(3) + '% of total gap'}</div>` : '') + '</div>';
    box.innerHTML = bar('bz-bar-gap', 'total gap ζ(β) − Z', '#9ca3af', gapLo, dirs.gap, `data-lower="${zc.gap[0]}" data-upper="${zc.gap[1]}"`, false)
      + bar('bz-bar-absent', 'absent primes ζ(β) − E', '#60a5fa', absLo, dirs.absent, `data-lower="${zc.absent[0]}" data-upper="${zc.absent[1]}"`, true)
      + bar('bz-bar-tails', 'exponent tails E − Z', '#f59e0b', zc.tails, dirs.tails, `data-value="${C.canon(zc.tails)}"`, true)
      + `<div class="bz-axis"><span>10${sup(ax.lo)}</span><span>log scale, fixed across factorial shells at this β${A.mode === 'direct' ? ' (widened to include this direct base)' : ''}</span><span>10${sup(ax.hi)}</span></div>`
      + (prev ? `<div class="bz-dim">arrows compare with ${A.n1 - 1}!</div>` : `<div class="bz-dim">${A.mode === 'direct' ? 'direct base: no previous factorial shell to compare' : ''}</div>`);
  }
  const axisCache = new Map();
  function stripAxis(b, P) {
    const key = b + ':' + P; if (axisCache.has(key)) return axisCache.get(key);
    let mn = Infinity;
    for (let k = 1; k <= 13; k++) for (const c of C.primeStrip(C.factorialFactors(k), b, P)) { const v = C.toNumber(C.cellLogEnclosure(c.p, c.a, b).lo); if (v > 0) mn = Math.min(mn, v); }
    const RL = C.remainderLog(b, P); if (RL.available && RL.resolved) mn = Math.min(mn, C.toNumber(RL.log.lo));
    const out = { lo: Math.floor(Math.log10(mn)), hi: Math.log10(C.logRatio(C.fullFactor(2, b))) }; axisCache.set(key, out); return out;
  }
  function renderPrimeStrip() {
    const A = panel.atom, b = panel.b, P = panel.P, maxp = A.fac.length ? Number(A.fac[A.fac.length - 1][0]) : 1;
    const grid = $('bz-pgrid');
    if (maxp > P) {
      const fits = C.CUTOFFS.find(c => c >= maxp);
      grid.innerHTML = ''; grid.dataset.available = 'false';
      $('bz-strip-note').textContent = fits ? `B has the prime ${maxp} > P = ${P}; choose P ≥ ${fits}.` : `unavailable: B has the prime factor ${maxp}, above the largest cutoff 200.`;
      $('bz-decomp').textContent = ''; renderStair([], maxp); return;
    }
    grid.dataset.available = 'true';
    const cells = C.primeStrip(A.fac, b, P), R = C.remainder(b, P), RL = C.remainderLog(b, P);
    const ax = b >= 1 ? stripAxis(b, P) : null;
    const pct = x => (ax && x > 0 ? Math.max(0, Math.min(100, 100 * (Math.log10(x) - ax.lo) / (ax.hi - ax.lo))) : 0).toFixed(3);
    let html = cells.map(c => {
      const enc = b >= 1 ? C.cellLogEnclosure(c.p, c.a, b) : null, contrib = enc ? enc.mid : null;
      const body = b === 0 ? `<div class="bz-dim">F diverges at β = 0</div><div>T = ${c.a + 1}</div>`
        : `<div title="F = ${C.canon(c.F)}">F−1 ${c3(C.sub(c.F, one))}</div>${c.present ? `<div title="T = ${C.canon(c.T)}">T−1 ${c3(C.sub(c.T, one))}</div><div class="bz-dim">F/T−1 ${c3(C.sub(c.ratio, one))}</div>` : ''}`
          + `<div class="mini"><div style="width:${pct(contrib)}%;background:${c.present ? '#f59e0b' : '#60a5fa'}"></div></div>`;
      return `<div class="cell${panel.hoverP === c.p ? ' hot' : ''}" data-p="${c.p}" data-state="${c.present ? 'present' : 'absent'}" data-a="${c.a}" data-contrib="${contrib ?? ''}" data-width="${b >= 1 ? pct(contrib) : ''}">`
        + `<div class="pp">${c.p}</div><div class="bz-dim">v = ${c.a}</div>${body}</div>`;
    }).join('');
    const remBody = !R.available ? `<div class="bz-dim">${R.words}</div>`
      : RL.resolved ? `<div title="log R ∈ [${C.toNumber(RL.log.lo)}, ${C.toNumber(RL.log.hi)}]">log R ${c3(RL.log.lo)}</div><div class="mini"><div style="width:${pct(RL.mid)}%;background:#60a5fa"></div></div>`
      : `<div>log R ≤ ${c3(RL.log.hi)}</div><div class="bz-dim">unresolved</div>`;
    html += `<div class="cell" data-state="beyond" id="bz-rem" data-available="${R.available}" data-resolved="${R.available ? RL.resolved : ''}" data-log-mid="${R.available ? RL.mid : ''}"><div class="pp">p &gt; ${P}</div><div class="bz-dim">all remaining</div>${remBody}</div>`;
    grid.innerHTML = html;
    $('bz-strip-note').textContent = `${cells.length} primes ≤ ${P}; B uses ${A.fac.length}.` + (ax ? ` Bars: certified log of each factor on a log axis 10${sup(ax.lo)} … log F₂, fixed for this β and P. Ratios multiply exactly to ζ/Z; they are not shares of ζ − Z.` : '');
    if (b >= 2) {
      const tailsL = cells.filter(c => c.present).reduce((t, c) => t + C.cellLogEnclosure(c.p, c.a, b).mid, 0);
      const absL = cells.filter(c => !c.present).reduce((t, c) => t + C.cellLogEnclosure(c.p, c.a, b).mid, 0);
      $('bz-decomp').innerHTML = `log(ζ/Z) = <b style="color:#f59e0b">${tailsL.toExponential(4)}</b> (tails, primes of B) + <b style="color:#60a5fa">${absL.toExponential(4)}</b> (absent ≤ ${P}) + <b style="color:#60a5fa">${RL.resolved ? RL.mid.toExponential(4) : 'unresolved'}</b> (p &gt; ${P})`;
    } else $('bz-decomp').textContent = b === 1 ? 'β = 1: each F_p is finite, but the product over all primes diverges.' : 'β = 0: every Euler factor diverges; exponents and T_p = v + 1 only.';
    renderStair(cells, null);
  }
  function renderStair(cells, maxp) {
    const svg = $('bz-stair'), W = svg.clientWidth || 700, H = svg.clientHeight || 120, P = panel.P, A = panel.atom;
    svg.setAttribute('viewBox', `0 0 ${W} ${H}`);
    const primes = C.primesUpTo(P), n = primes.length, padL = 30, padR = 10, padT = 8, padB = 18;
    const X = x => padL + (W - padL - padR) * x / (P + 1), Y = y => H - padB - (H - padT - padB) * y / n;
    let path = `M ${X(0)} ${Y(0)}`, k = 0; primes.forEach(p => { path += ` H ${X(p)} V ${Y(++k)}`; }); path += ` H ${X(P + 1)}`;
    const present = new Set(A.fac.map(([p]) => Number(p)));
    let g = `<path d="${path}" fill="none" stroke="#6a6a86" stroke-width="1.3"/>`;
    primes.forEach((p, i) => g += `<circle cx="${X(p)}" cy="${Y(i + 1)}" r="${panel.hoverP === p ? 5 : 3.3}" data-p="${p}" data-present="${present.has(p)}" fill="${present.has(p) ? '#f59e0b' : '#0e0e1a'}" stroke="${present.has(p) ? '#f59e0b' : '#60a5fa'}" stroke-width="1.4"><title>p = ${p}, π(${p}) = ${i + 1}</title></circle>`);
    [0, P].forEach(x => g += `<text x="${X(x)}" y="${H - 4}" text-anchor="middle" font-size="10" fill="#6a6a86">${x}</text>`);
    let note = `π(x) up to P = ${P}; filled = primes of B.`;
    if (A.mode === 'factorial') {
      const pik = C.primeCount(A.n1);
      g += `<line x1="${X(A.n1)}" x2="${X(A.n1)}" y1="${padT}" y2="${H - padB}" stroke="#fbbf24" stroke-dasharray="4 3"/><text x="${X(A.n1) + 4}" y="${padT + 10}" font-size="10.5" fill="#fbbf24">x = ${A.n1}</text>`;
      note += ` The cursor is at x = n₁ = ${A.n1}: ω(${A.n1}!) = π(${A.n1}) = ${pik}.`;
      svg.dataset.pik = String(pik);
    } else svg.dataset.pik = '';
    svg.dataset.omega = String(A.fac.length); svg.innerHTML = g; $('bz-stair-note').textContent = note + (maxp ? ` (strip hidden: B has the prime ${maxp})` : '');
  }
  function renderShellStrip() {
    const svg = $('bz-strip'), W = svg.clientWidth || 700, H = svg.clientHeight || 190, b = panel.b, A = panel.atom;
    svg.setAttribute('viewBox', `0 0 ${W} ${H}`);
    if (b <= 1) { svg.innerHTML = `<text x="${W / 2}" y="${H / 2}" text-anchor="middle" fill="#6a6a86" font-size="12">${C.zetaComparison([], b).words}</text>`; return; }
    const { rows, lo, hi } = logAxis(b), padL = 62, padR = 10, padT = 10, padB = 24, yB = H - padB - 22, y0 = H - padB - 6;
    const X = k => padL + (W - padL - padR) * (k - 1) / 12, isZero = (r, key) => key === 'tails' && r.zc.tails.n === 0n;
    const Y = (v, z) => (z ? y0 : padT + (yB - padT) * (hi - Math.log10(v)) / (hi - lo)), colW = (W - padL - padR) / 12;
    let s = '';
    rows.forEach(r => { if (r.addsPrime) s += `<rect x="${X(r.k) - colW / 2}" y="${padT}" width="${colW}" height="${yB - padT}" fill="#141b2c"/>`; });
    s += `<line x1="${padL}" x2="${W - padR}" y1="${yB + 9}" y2="${yB + 9}" stroke="#6a6a86" stroke-dasharray="2 4"/><text x="${padL - 5}" y="${y0 + 4}" text-anchor="end" font-size="10" fill="#6a6a86">0 (exact)</text>`;
    const step = Math.max(1, Math.ceil((hi - lo) / 5));
    for (let e = lo; e <= hi; e += step) s += `<line x1="${padL}" x2="${W - padR}" y1="${Y(10 ** e)}" y2="${Y(10 ** e)}" stroke="#1f1f33"/><text x="${padL - 5}" y="${Y(10 ** e) + 4}" text-anchor="end" font-size="10" fill="#6a6a86">10${sup(e)}</text>`;
    rows.forEach(r => s += `<text x="${X(r.k)}" y="${H - 7}" text-anchor="middle" font-size="10" fill="#6a6a86">${r.k}!</text>`);
    const line = (key, col, dash) => { let out = '', seg = []; const flush = () => { if (seg.length > 1) out += `<polyline points="${seg.join(' ')}" fill="none" stroke="${col}" stroke-width="1.6" ${dash ? 'stroke-dasharray="4 3"' : ''}/>`; seg = []; };
      rows.forEach(r => { if (isZero(r, key)) flush(); else seg.push(`${X(r.k)},${Y(r[key], false)}`); }); flush();
      return out + rows.map(r => { const z = isZero(r, key); return `<circle cx="${X(r.k)}" cy="${Y(r[key], z)}" r="3" fill="${z ? '#0e0e1a' : col}" stroke="${col}" data-k="${r.k}" data-series="${key}" data-zero="${z}"/>`; }).join(''); };
    s += line('gap', '#9ca3af', true) + line('absent', '#60a5fa') + line('tails', '#f59e0b');
    if (A.mode === 'factorial' && A.n1 >= 1 && A.n1 <= 13) s += `<line x1="${X(A.n1)}" x2="${X(A.n1)}" y1="${padT}" y2="${y0 + 6}" stroke="#fbbf24" opacity="0.7"/>`;
    svg.innerHTML = s; svg.dataset.cursor = A.mode === 'factorial' ? String(A.n1) : '';
  }
  const OUTPUTS = ['bz-atom', 'bz-tau', 'bz-z-dec', 'bz-z', 'bz-m7', 'bz-sel-d', 'bz-sel-w', 'bz-sel-z', 'bz-regime', 'bz-bars',
                   'bz-strip-note', 'bz-pgrid', 'bz-decomp', 'bz-stair', 'bz-stair-note', 'bz-strip'];
  const SECTIONS = [['lattice', () => draw(), ['bz-lattice']], ['atom', () => renderAtom(), ['bz-atom', 'bz-z', 'bz-m7']],
                    ['selected', () => renderSelected(), ['bz-sel-d']], ['bars', () => renderBars(), ['bz-bars']],
                    ['prime strip', () => renderPrimeStrip(), ['bz-pgrid', 'bz-stair']], ['shell chart', () => renderShellStrip(), ['bz-strip']]];
  function clearAll() {                              // nothing from a previous atom survives a render
    panel.m7 = null;
    for (const id of OUTPUTS) { const e = $(id); for (const k of Object.keys(e.dataset)) delete e.dataset[k]; if (e.tagName === 'svg') e.innerHTML = ''; else e.textContent = ''; }
    const cv = $('bz-lattice'); delete cv.dataset.atom; const g = cv.getContext('2d'); g.setTransform(1, 0, 0, 1, 0, 0); g.clearRect(0, 0, cv.width, cv.height);
  }
  function sectionFailed(name, ids, message) {
    for (const id of ids) {
      const e = $(id); for (const k of Object.keys(e.dataset)) delete e.dataset[k]; e.dataset.atom = ''; e.dataset.failed = 'true';
      if (id === 'bz-lattice') { const g = e.getContext('2d'); g.setTransform(1, 0, 0, 1, 0, 0); g.clearRect(0, 0, e.width, e.height); g.fillStyle = '#ff4444'; g.font = '12px system-ui'; g.fillText('unavailable: display error', 12, 20); }
      else if (e.tagName === 'svg') e.innerHTML = `<text x="8" y="18" fill="#ff4444" font-size="12">unavailable: display error</text>`;
      else e.textContent = 'unavailable: display error';
    }
    if (name === 'atom') panel.m7 = null;
  }
  function render() {
    if (!panel.atom) return true;
    clearAll();
    const errs = [], B = String(panel.atom.B);
    for (const [name, fn, ids] of SECTIONS) {
      try {
        if (panel.faults.get(name) > 0) { panel.faults.set(name, panel.faults.get(name) - 1); throw Error(`injected ${name} fault (test hook)`); }
        fn();
        for (const id of ids) { $(id).dataset.atom = B; delete $(id).dataset.failed; }
      } catch (e) { errs.push(`${name}: ${e.message}`); sectionFailed(name, ids, e.message); }
    }
    panel.lastRenderOk = errs.length === 0;
    panel.error = errs.length ? errs.join('; ') : null;       // cleared on recovery, stored and visible alike
    $('bz-error').textContent = panel.error ? `display error for B = ${B}; the sections marked unavailable show nothing from any other atom: ${panel.error}` : '';
    return errs.length === 0;
  }

  /* ---------------- controls (panel-local only) ---------------- */
  $('bz-cutoff').innerHTML = C.CUTOFFS.map(P => `<option value="${P}"${P === panel.P ? ' selected' : ''}>${P}</option>`).join('');
  const rerender = () => { panel.sameKeyAttempts = 1; render(); };   // a user-triggered render is attempt 1 of 3
  const setBeta = b => { panel.b = Math.max(0, Math.min(32, b)); $('bz-beta').value = String(panel.b); $('bz-beta-out').textContent = String(panel.b); rerender(); };
  const setCutoff = P => { if (C.CUTOFFS.includes(P)) { panel.P = P; $('bz-cutoff').value = String(P); rerender(); } };
  const selectKey = k => { if (panel.atom && panel.atom.index.has(k)) { panel.selKey = k; draw(); renderSelected(); } };
  $('bz-beta').addEventListener('input', e => setBeta(+e.target.value));
  $('bz-cutoff').addEventListener('change', e => setCutoff(+e.target.value));
  $('bz-lattice').addEventListener('click', e => { const r = e.target.getBoundingClientRect(), n = nodeAt(e.clientX - r.left, e.clientY - r.top); if (n) selectKey(panel.atom.key(n.e)); });
  $('bz-pick').addEventListener('change', e => { const t = e.target.value.trim(), msg = $('bz-pick-msg');
    if (!/^[1-9][0-9]*$/.test(t)) { msg.textContent = 'enter a positive integer'; return; }
    const n = panel.atom && panel.atom.nodes.find(x => x.d === BigInt(t)); msg.textContent = n ? '' : `${t} does not divide B`; if (n) selectKey(panel.atom.key(n.e)); });
  $('bz-pgrid').addEventListener('mouseover', e => { const c = e.target.closest('.cell[data-p]'), p = c ? +c.dataset.p : null; if (p !== panel.hoverP) { panel.hoverP = p; renderPrimeStrip(); } });
  $('bz-pgrid').addEventListener('mouseleave', () => { panel.hoverP = null; renderPrimeStrip(); });
  toggle.onclick = () => {
    panel.open = !panel.open; root.hidden = !panel.open; toggle.setAttribute('aria-expanded', String(panel.open));
    if (panel.open) { panel.hostKey = null; poll(); pollTimer = setInterval(poll, 250); } else { clearInterval(pollTimer); pollTimer = null; }
  };
  window.addEventListener('resize', () => { if (panel.open) rerender(); });
  // F2: keep navigation keys inside the panel away from the host's window-level shortcuts (same pattern the host
  // uses for its own inspector). Native control defaults remain: no preventDefault here.
  const ISOLATED_KEYS = new Set(['ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown', 'Home', 'End', 'PageUp', 'PageDown']);
  root.addEventListener('keydown', e => { if (ISOLATED_KEYS.has(e.key)) e.stopPropagation(); });

  window.McombBaselLinkDiagnosticsV1 = Object.freeze({
    status: () => ({ open: panel.open, beta: panel.b, cutoff: panel.P, hostKey: panel.hostKey, pendingKey: panel.pendingKey, fails: panel.fails,
                     sameKeyAttempts: panel.sameKeyAttempts, lastRenderOk: panel.lastRenderOk, error: panel.error,
                     errorText: $('bz-error').textContent, build: { host_build: PINS.hostBuild, host_sha256: PINS.hostSha256 } }),
    sections: () => Object.fromEntries(SECTIONS.map(([name, , ids]) => [name, ids.map(id => ({ id, atom: $(id).dataset.atom ?? null, failed: $(id).dataset.failed === 'true' }))])),
    injectFaultOnce: (name, times = 1) => {          // TEST-ONLY: make the next `times` renders of one section (or the next M7 call) throw
      if (name === 'm7') { panel.faultM7 = true; return true; }
      if (!SECTIONS.some(([n]) => n === name) || !Number.isInteger(times) || times < 1 || times > 5) return false;
      panel.faults.set(name, (panel.faults.get(name) || 0) + times); return true;
    },
    atom: () => panel.atom && { mode: panel.atom.mode, B: String(panel.atom.B), n1: panel.atom.n1, factors: panel.atom.fac.map(([p, a]) => [String(p), a]), tau: panel.atom.nodes.length },
    lastM7: () => panel.m7 && (panel.m7.status === 'EXACT_RATIONAL'
      ? { status: panel.m7.status, value: C.canon(panel.m7.value), agree: panel.m7.agree, input: panel.m7.input.slice(), zeta: panel.m7.zeta.slice(), inverse: panel.m7.inverse.slice(), tuples: panel.m7.tuples.map(t => t.slice()), m7Version: panel.m7.m7Version, relation: panel.m7.relation }
      : { status: panel.m7.status, reason: panel.m7.reason, words: panel.m7.words }),
    setBeta: b => { setBeta(b); return panel.b; }, setCutoff: P => { setCutoff(P); return panel.P; },
    selectDivisor: d => { const n = panel.atom && panel.atom.nodes.find(x => x.d === BigInt(d)); if (n) selectKey(panel.atom.key(n.e)); return !!n; },
    nodes: () => panel.atom ? panel.atom.nodes.map(n => ({ d: String(n.d), e: n.e.slice(), x: n.x, y: n.y })) : [],
    poll: () => { poll(); return panel.hostKey; }
  });
})();
