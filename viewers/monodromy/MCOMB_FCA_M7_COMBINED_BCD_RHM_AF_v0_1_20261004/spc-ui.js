/* Shell prime-count panel v0.1 — page module (worker C, Claude). Additive, opt-in, read-only toward the host.
 *
 * Implements SHELL_PRIME_COUNT_PANEL_SPEC_v0_1_2 (Astra PASS) on the frozen Basel host link v0.1.2. Idea: saphir.
 * pi(B) = omega(B) + phi(B) - 1 - C_B for the host shell base B, in four visibly separate registers labelled in words:
 * exact, neighbour, asymptotic (factorial family only) and rosette reading.
 *
 * Host seam (read only): liftSourceSnapshot() for the shell mode, n1, B and the amplitude n6;
 * parseGearboxRational(gearboxExactText('t1' | 't2')).exact for the canonical coefficients; factorSafePositiveInteger(B)
 * and isPrime(B + 1) are passed to the worker, which recomputes both and refuses to finish on disagreement.
 * The host is polled every 250 ms while the panel is open, and additionally right after any click/change/keyup
 * (listeners only read). The panel never writes host state, never reads the host spin, never uses the Basel exponent.
 *
 * Jobs: key = mode:n1|B:epoch; the epoch increments on every shell change. IDLE -> COMPUTING -> READY | CANCELLED | ERROR.
 * A shell change while COMPUTING terminates the worker (CANCELLED) and a fresh worker takes the new job. A result is
 * accepted only if its epoch and key equal the current job and a fresh host read still shows the job's shell; otherwise
 * it is discarded and logged STALE_DISCARDED, with no render. Every job has a declared time budget (default 30 s); on
 * expiry the worker is terminated and the job becomes ERROR. There is no automatic retry. Coefficient or amplitude
 * changes re-render only the rosette register. Export: READY and current only; snapshot() re-reads the host, builds
 * the 0.1.2 packet, validates it (structure + S0-S13, BigInt) in the validator worker and applies S12 against this
 * running build before any bytes leave. Import: strict bytes -> structure -> S0-S13 -> S12; any rejection renders nothing.
 * v0.1.1 (Astra audit F1): each import action owns a distinct operation token; only the latest may write the import display.
 */
(() => {
  'use strict';
  const Core = window.McombShellPrimeCountCoreV1, PINS = window.McombShellPrimeCountBuildPins, WSRC = window.McombShellPrimeCountWorkerSourceV1;
  if (!Core || !PINS || typeof WSRC !== 'string' || typeof liftSourceSnapshot !== 'function' || typeof parseGearboxRational !== 'function'
      || typeof gearboxExactText !== 'function' || typeof factorSafePositiveInteger !== 'function' || typeof isPrime !== 'function')
    throw Error('Shell prime-count modules or host seam missing');
  const $ = id => document.getElementById(id);
  const el = (tag, attrs, text) => { const e = document.createElement(tag); for (const [k, v] of Object.entries(attrs || {})) e.setAttribute(k, v); if (text !== undefined && text !== null) e.textContent = text; return e; };
  const now = () => performance.now();
  const DEFAULT_BUDGET_MS = 30000;
  const LIMIT_11 = 39916800;

  const S = { open: false, status: 'IDLE', epoch: 0, shellKey: null, shell: null, job: null, result: null, resultKey: null, timings: null, error: null,
              coef: null, coefKey: null, worker: null, workerReady: false, validator: null, validatorReady: false, pending: new Map(), nextRequest: 1,
              budgetMs: DEFAULT_BUDGET_MS, timer: null, jobsStarted: 0, log: [], zombies: [], faultOnce: null, holdNextMs: 0, keepStaleOnce: false,
              importState: null, importSeq: 0, importHooks: { readHoldMs: 0, readFail: false, commitDelayMs: 0 }, validatorFailOnce: false, lastExport: null, hostError: null };
  let pollTimer = null, pollSoon = null;
  function logEvent(event, extra) { S.log.push(Object.assign({ event, t: Math.round(now()), epoch: S.epoch, key: S.job ? S.job.key : null }, extra || {})); if (S.log.length > 1000) S.log.splice(0, S.log.length - 1000); }

  /* ---------------- host seam (read only) ---------------- */
  function readHost() {
    const h = liftSourceSnapshot();
    const mode = h.shellMode === 'factorial' ? 'factorial' : 'direct';
    const B = h.shellBase;
    if (!Number.isSafeInteger(B) || B < 2 || B > 6227020800) return { error: 'host shell base ' + B + ' is outside 2..13!' };
    const n1 = mode === 'factorial' ? h.n1 : null;
    const coef = { t1: null, t2: null, amplitudeNonzero: h.n6 !== 0, amplitudeText: String(h.n6), failures: [] };
    for (const name of ['t1', 't2']) {
      try { coef[name] = parseGearboxRational(gearboxExactText(name)).exact; }
      catch (e) { coef.failures.push((name === 't1' ? 't₁' : 't₂') + ' unparseable (' + e.message + ')'); }
    }
    const shellKey = mode + ':' + (n1 === null ? '' : n1) + ':' + B;
    return { mode, B, n1, shellKey, coef, coefKey: coef.t1 + '|' + coef.t2 + '|' + coef.amplitudeNonzero + '|' + coef.failures.join(';') };
  }
  const jobKey = (shell, epoch) => (shell.mode === 'factorial' ? 'factorial:' + shell.n1 : 'direct:' + shell.B) + ':' + epoch;

  /* ---------------- workers (built from the embedded source string; static-page compatible) ---------------- */
  function spawn(onMessage) {
    const url = URL.createObjectURL(new Blob([WSRC], { type: 'text/javascript' }));
    const w = new Worker(url); URL.revokeObjectURL(url);
    w.onmessage = ev => onMessage(ev.data, w);
    return w;
  }
  function ensureCounter() {
    if (S.worker) return S.worker;
    S.workerReady = false;
    const w = spawn(onCounterMessage);
    w.onerror = e => { if (w === S.worker && S.status === 'COMPUTING') { failJob('worker error: ' + (e.message || 'unknown')); } };
    S.worker = w;
    return w;
  }
  function killCounter(reason) {
    if (!S.worker) return;
    if (S.keepStaleOnce) { S.keepStaleOnce = false; S.zombies.push(S.worker); logEvent('WORKER_KEPT_FOR_STALE_TEST', { reason }); }
    else S.worker.terminate();
    S.worker = null; S.workerReady = false;
  }
  function clearTimer() { if (S.timer) { clearTimeout(S.timer); S.timer = null; } }

  function onCounterMessage(m, w) {
    if (!m || typeof m.type !== 'string' || m.type.indexOf('spc/') !== 0) { logEvent('MESSAGE_IGNORED'); return; }
    if (m.type === 'spc/ready') { if (w === S.worker) S.workerReady = true; logEvent('WORKER_READY', { msgEpoch: m.epoch }); return; }
    if (m.type !== 'spc/result' && m.type !== 'spc/error') { logEvent('MESSAGE_IGNORED', { type: m.type }); return; }
    const job = S.job;
    let reason = null;
    if (!job) reason = 'no job';
    else if (m.epoch !== job.epoch) reason = 'epoch ' + m.epoch + ' is not the current epoch ' + job.epoch;
    else if (m.key !== job.key) reason = 'key ' + m.key + ' is not the current key ' + job.key;
    else if (S.status !== 'COMPUTING') reason = 'current job is not computing (' + S.status + ')';
    else if (w !== S.worker) reason = 'message from a retired worker';
    else {
      let h = null; try { h = readHost(); } catch (e) { h = { error: e.message }; }
      if (h.error || h.shellKey !== job.shellKey) reason = 'host shell changed before the result arrived';
    }
    if (reason) {
      logEvent('STALE_DISCARDED', { msgEpoch: m.epoch, msgKey: m.key, type: m.type, reason });
      if (S.zombies.indexOf(w) >= 0) { w.terminate(); S.zombies = S.zombies.filter(z => z !== w); }
      if (S.open) schedulePoll();
      return;
    }
    clearTimer();
    if (m.type === 'spc/error') { failJob(m.message); return; }
    S.status = 'READY'; S.result = m.result; S.resultKey = job.key; S.timings = m.timings; S.error = null;
    logEvent('READY', { timings: m.timings });
    render();
  }
  function failJob(message) {
    clearTimer();
    S.status = 'ERROR'; S.error = message; S.result = null; S.resultKey = null;
    logEvent('ERROR', { message });
    render();
  }

  function startJob(h) {
    clearTimer();
    if (S.status === 'COMPUTING' && S.job) { logEvent('CANCELLED', { cancelledKey: S.job.key }); killCounter('shell change'); }
    S.epoch += 1;
    const shell = { mode: h.mode, n1: h.n1, B: h.B };
    const job = { key: jobKey(shell, S.epoch), epoch: S.epoch, shell, shellKey: h.shellKey, started: now() };
    S.job = job; S.shell = shell; S.status = 'COMPUTING'; S.result = null; S.resultKey = null; S.error = null; S.timings = null;
    S.jobsStarted += 1;
    let hostSet, hostUpper;
    try { hostSet = factorSafePositiveInteger(h.B).map(f => f.prime); hostUpper = isPrime(h.B + 1); }
    catch (e) { failJob('host factorisation failed: ' + e.message); return; }
    const msg = { type: 'spc/count', epoch: job.epoch, key: job.key, mode: h.mode, n1: h.n1, B: h.B, hostPrimeDivisorSet: hostSet, hostUpperIsPrime: hostUpper };
    if (S.faultOnce) { msg.testFault = S.faultOnce; S.faultOnce = null; }
    if (S.holdNextMs) { msg.testHoldMs = S.holdNextMs; S.holdNextMs = 0; }
    logEvent('JOB_START', { B: String(h.B), mode: h.mode, hold: msg.testHoldMs || 0, fault: msg.testFault || null });
    render();
    const budget = S.budgetMs;
    S.timer = setTimeout(() => {
      if (S.job === job && S.status === 'COMPUTING') {
        logEvent('TIMEOUT', { budgetMs: budget });
        killCounter('timeout');
        failJob('time budget of ' + budget + ' ms exceeded; the worker was terminated (no automatic retry; change the shell or press recount)');
      }
    }, budget);
    ensureCounter().postMessage(msg);
  }

  /* validator worker: import and export validation (structure + S0-S13 with route replays) off the main thread */
  function onValidatorMessage(m, w) {
    if (w !== S.validator || !m || typeof m.type !== 'string') return;
    if (m.type === 'spc/ready') { S.validatorReady = true; return; }
    if (m.type !== 'spc/validated') return;
    const p = S.pending.get(m.requestId);
    if (!p || p.epoch !== m.epoch) { logEvent('STALE_DISCARDED', { msgEpoch: m.epoch, type: m.type, reason: 'unknown validation request' }); return; }
    S.pending.delete(m.requestId); clearTimeout(p.timer); p.resolve(m);
  }
  // v0.1.1: a failed validator worker (error event, or the test hook) settles every pending request with ERROR and is
  // replaced on the next request, the same way the timeout path restarts it. Each waiting import still decides by its own
  // operation token whether it may commit that ERROR (see importBytes).
  function failValidator(reason) {
    const w = S.validator; if (!w) return;
    for (const q of S.pending.values()) { clearTimeout(q.timer); q.resolve({ verdict: 'ERROR', detail: reason, packet: null }); }
    S.pending.clear(); w.terminate(); S.validator = null; S.validatorReady = false;
    logEvent('VALIDATOR_FAILED', { reason });
  }
  function validateBytes(bytes) {
    if (!S.validator) {
      S.validatorReady = false; const w = spawn(onValidatorMessage); S.validator = w;
      w.onerror = e => { if (w === S.validator) failValidator('validator worker failed: ' + (e.message || 'unknown')); };
    }
    const requestId = S.nextRequest++, epoch = S.epoch, budget = S.budgetMs;
    const injectFailure = S.validatorFailOnce; S.validatorFailOnce = false;
    return new Promise(resolve => {
      const timer = setTimeout(() => {
        if (!S.pending.has(requestId)) return;
        S.pending.delete(requestId);
        for (const q of S.pending.values()) { clearTimeout(q.timer); q.resolve({ verdict: 'ERROR', detail: 'validator restarted after a timeout', packet: null }); }
        S.pending.clear(); S.validator.terminate(); S.validator = null; S.validatorReady = false;
        logEvent('TIMEOUT', { budgetMs: budget, what: 'validation' });
        resolve({ verdict: 'ERROR', detail: 'validation exceeded the time budget of ' + budget + ' ms', packet: null });
      }, budget);
      S.pending.set(requestId, { resolve, timer, epoch });
      const copy = bytes.slice();
      S.validator.postMessage({ type: 'spc/validate', epoch, requestId, bytes: copy.buffer }, [copy.buffer]);
      if (injectFailure) setTimeout(() => failValidator('validator worker failed: injected failure (test hook)'), 0);
    });
  }

  /* ---------------- polling ---------------- */
  function poll() {
    let h;
    try { h = readHost(); } catch (e) { h = { error: 'host read failed: ' + e.message }; }
    if (h.error) { S.hostError = h.error; renderStatus(); return; }
    S.hostError = null;
    if (h.shellKey !== S.shellKey) { S.shellKey = h.shellKey; S.coef = h.coef; S.coefKey = h.coefKey; startJob(h); return; }
    if (h.coefKey !== S.coefKey) { S.coef = h.coef; S.coefKey = h.coefKey; logEvent('COEFFICIENTS_CHANGED', { coefKey: h.coefKey }); renderRosette(); }
  }
  function schedulePoll() { if (!S.open || pollSoon) return; pollSoon = setTimeout(() => { pollSoon = null; if (S.open) poll(); }, 0); }

  /* ---------------- DOM ---------------- */
  const style = el('style');
  style.textContent = `
  #spc-panel{margin:6px 0 10px;padding:8px 10px;border:1px solid var(--line-grid);border-radius:6px;background:var(--bg-card);color:var(--text-bright);font-size:12px}
  #spc-panel h3{margin:0 0 6px;font-size:13px;color:var(--text-bright)}
  #spc-panel h4{margin:0 0 4px;font-size:12px;color:var(--text-mid);font-weight:600}
  #spc-panel .spc-dim{color:var(--text-dim)}
  #spc-panel .spc-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:8px;margin-top:6px}
  #spc-panel .spc-box{border:1px solid #1f1f33;border-radius:4px;padding:6px 8px;min-width:0;overflow-wrap:anywhere}
  #spc-panel #spc-exact{grid-column:1/-1}
  #spc-panel .spc-kv{display:grid;grid-template-columns:max-content minmax(0,1fr);gap:2px 10px;margin:0}
  #spc-panel .spc-kv dt{color:var(--text-dim)} #spc-panel .spc-kv dd{margin:0;font-variant-numeric:tabular-nums}
  #spc-panel .spc-mono{font-family:ui-monospace,Consolas,monospace;font-size:11px}
  #spc-panel .spc-good{color:var(--accent-good)} #spc-panel .spc-bad{color:var(--accent-defend)} #spc-panel .spc-warn{color:var(--accent-warn)}
  #spc-panel .spc-row{display:flex;flex-wrap:wrap;gap:6px 14px;align-items:center;margin-top:6px}
  #spc-panel button,#spc-panel input{background:var(--bg-inset);color:var(--text-bright);border:1px solid var(--line-grid);border-radius:3px;font:inherit;max-width:100%}`;
  document.head.append(style);
  const toggle = el('button', { id: 'spc-toggle', type: 'button', class: 'micro-button', 'aria-expanded': 'false',
    title: 'Opt-in shell prime-count readout: prime count π(B) = ω(B) + φ(B) − 1 − C_B of the host shell base B' }, 'π(B) shell prime count');
  const anchorToggle = $('bz-toggle') || $('cs-toggle');
  anchorToggle.after(toggle);
  const root = el('section', { id: 'spc-panel', hidden: '', 'aria-label': 'Shell prime-count readout' });
  root.innerHTML = `
  <h3>Shell prime count of the host shell base B · π(B) = ω(B) + φ(B) − 1 − C<sub>B</sub> · candidate panel v0.1.1</h3>
  <div class="spc-dim">Reads the host shell base B, the coefficients t₁, t₂ and the amplitude n₆ only; never writes the host. Here π is the circle constant and π(B) the prime count; γ is the Euler–Mascheroni constant. Counting runs in a Web Worker (route A: Lucy_Hedgehog; route B: segmented sieve cross-check up to 11!). A basis-controlled count of classical quantities, not a new prime-counting method.</div>
  <div class="spc-row"><span id="spc-status" role="status" aria-live="polite"></span></div>
  <div class="spc-grid">
    <div class="spc-box" id="spc-exact" tabindex="0" aria-label="exact register"><h4>Exact register</h4><div class="spc-body"></div></div>
    <div class="spc-box" id="spc-neighbour" tabindex="0" aria-label="neighbour register"><h4>Neighbour register</h4><div class="spc-body"></div></div>
    <div class="spc-box" id="spc-asymptotic" tabindex="0" aria-label="asymptotic register"><h4>Asymptotic register (factorial family only)</h4><div class="spc-body"></div></div>
    <div class="spc-box" id="spc-rosette" tabindex="0" aria-label="rosette reading register"><h4>Rosette reading register</h4><div class="spc-body"></div></div>
  </div>
  <div class="spc-row">
    <button id="spc-export" type="button">Export readout (JSON)</button>
    <button id="spc-recount" type="button" title="Start a new job for the current shell (manual; there is no automatic retry)">Recount</button>
    <label>Import readout <input id="spc-import" type="file" accept="application/json,.json"></label>
  </div>
  <div id="spc-msg" class="spc-dim" role="status"></div>
  <div class="spc-box" id="spc-import-result" style="margin-top:6px" hidden><h4>Imported readout</h4><div class="spc-body"></div></div>`;
  const basel = $('bz-panel'), cs = $('cs-panel');
  (basel || cs).after(root);

  const body = id => $(id).querySelector('.spc-body');
  function stamp(id, key, atom, status) { const n = $(id); n.dataset.key = key || ''; n.dataset.atom = atom || ''; n.dataset.status = status || ''; }
  function kv(pairs) {
    const dl = el('dl', { class: 'spc-kv' });
    for (const [k, v, cls] of pairs) { dl.append(el('dt', {}, k)); dl.append(el('dd', cls ? { class: cls } : {}, v)); }
    return dl;
  }
  function clearRegisters(text) {
    for (const id of ['spc-exact', 'spc-neighbour', 'spc-asymptotic', 'spc-rosette']) {
      body(id).replaceChildren(el('div', { class: 'spc-dim' }, text)); stamp(id, '', '', ''); delete $(id).dataset.values;
    }
  }
  const STATE_WORDS = { IDLE: 'idle', COMPUTING: 'computing', READY: 'ready', CANCELLED: 'cancelled', ERROR: 'error' };
  function renderStatus() {
    const s = $('spc-status');
    let t = S.job ? 'job ' + S.job.key + ' · state ' + STATE_WORDS[S.status] : 'state ' + STATE_WORDS[S.status];
    if (S.status === 'READY' && S.timings) t += ' · route A ' + S.timings.routeAms.toFixed(1) + ' ms' + (S.timings.routeBms === null ? ' · route B not run above 11!' : ' · route B ' + S.timings.routeBms.toFixed(1) + ' ms');
    if (S.status === 'ERROR') t += ' · ' + S.error;
    if (S.hostError) t += ' · ' + S.hostError;
    t += ' · time budget ' + S.budgetMs + ' ms';
    s.textContent = t; s.className = S.status === 'ERROR' ? 'spc-bad' : S.status === 'READY' ? 'spc-good' : 'spc-dim';
    s.dataset.state = S.status;
  }
  const current = () => S.status === 'READY' && S.job && S.resultKey === S.job.key && S.result;

  function render() {
    renderStatus();
    if (!current()) {
      clearRegisters(S.status === 'COMPUTING' ? 'computing for B = ' + (S.shell ? S.shell.B : '?') + '…' : S.status === 'ERROR' ? 'unavailable: ' + S.error : 'no current result');
      $('spc-asymptotic').hidden = !(S.shell && S.shell.mode === 'factorial');
      return;
    }
    const r = S.result, sh = S.shell, key = S.job.key, atom = String(sh.B);
    const below = sh.B <= LIMIT_11;
    // exact register
    const ex = [
      ['shell base B', sh.mode === 'factorial' ? atom + ' = ' + sh.n1 + '! (factorial mode)' : atom + ' (direct mode)'],
      ['prime count π(B)', r.primeCount],
      ['prime divisor set 𝒫(B)', '{' + r.primeDivisorSet.join(', ') + '}'],
      ['distinct prime divisors ω(B)', r.distinctPrimeDivisorCount],
      ['Euler totient φ(B)', r.eulerTotient],
      ['coprime composites C_B', r.coprimeCompositeCount + (below ? ' (direct count)' : ' (derived from π(B))')],
      ['prime share of reduced residues Y_B', r.residuePrimeShare.numerator + '/' + r.residuePrimeShare.denominator + '  (exact reduced fraction)'],
      ['identity', 'π(B) = ω(B) + φ(B) − 1 − C_B: ' + r.primeCount + ' = ' + r.distinctPrimeDivisorCount + ' + ' + r.eulerTotient + ' − 1 − ' + r.coprimeCompositeCount],
      ['cross-check', below ? 'segmented sieve agrees' : 'not run above 11!', below ? 'spc-good' : 'spc-dim'],
      ['C_B status', below ? 'direct count' : 'derived from π(B) (not independent validation)']];
    if (sh.mode === 'factorial') ex.push(['ω(n₁!) = π(n₁)', 'ω(' + sh.n1 + '!) = ' + r.distinctPrimeDivisorCount + ' = π(' + sh.n1 + ')']);
    body('spc-exact').replaceChildren(kv(ex));
    stamp('spc-exact', key, atom, 'READY');
    $('spc-exact').dataset.values = JSON.stringify({ B: atom, primeCount: r.primeCount, primeDivisorSet: r.primeDivisorSet, omega: r.distinctPrimeDivisorCount, totient: r.eulerTotient,
      C: r.coprimeCompositeCount, Y: r.residuePrimeShare, crossCheck: r.crossCheck, cStatus: r.coprimeCompositeStatus, primeCountN1: r.primeCountN1 });
    // neighbour register
    body('spc-neighbour').replaceChildren(kv([
      ['upper neighbour B + 1', r.upper + ' (coprime to B)'],
      ['B + 1 is prime', r.upperIsPrime ? 'yes' : 'no'],
      ['prime count π(B + 1)', 'π(B) + [B + 1 prime] = ' + r.primeCount + ' + ' + (r.upperIsPrime ? '1' : '0') + ' = ' + r.primeCountUpper]]));
    stamp('spc-neighbour', key, atom, 'READY');
    $('spc-neighbour').dataset.values = JSON.stringify({ upper: r.upper, upperIsPrime: r.upperIsPrime, primeCountUpper: r.primeCountUpper });
    // asymptotic register: factorial mode only (absent in direct mode even when B is a factorial)
    const asy = $('spc-asymptotic');
    if (sh.mode === 'factorial') {
      asy.hidden = false;
      body('spc-asymptotic').replaceChildren(
        el('div', {}, 'factorial-family asymptotic: n·Y → e^γ (Mertens, PNT, Stirling). No finite-range accuracy claim.'),
        kv([['exact rational n₁·Y_{n₁!}', r.scaledShare.numerator + '/' + r.scaledShare.denominator + '  (n₁ = ' + sh.n1 + ')'],
            ['constant e^γ', '≈ 1.78107 (γ = Euler–Mascheroni constant)']]));
      stamp('spc-asymptotic', key, atom, 'READY');
      asy.dataset.values = JSON.stringify({ present: true, scaledShare: r.scaledShare });
    } else {
      asy.hidden = true; body('spc-asymptotic').replaceChildren(); stamp('spc-asymptotic', key, atom, 'ABSENT_DIRECT_MODE');
      asy.dataset.values = JSON.stringify({ present: false });
    }
    renderRosette();
  }
  function rosetteReading(coef, primeCount) {
    if (coef.failures.length) return { met: false, words: 'reading unavailable: coefficient unparseable (' + coef.failures.join('; ') + ')', exportable: false };
    const failing = [];
    if (coef.t1 !== '1') failing.push('t₁ = ' + coef.t1 + ' is not 1');
    if (coef.t2 !== '1') failing.push('t₂ = ' + coef.t2 + ' is not 1');
    if (!coef.amplitudeNonzero) failing.push('amplitude n₆ is zero');
    if (failing.length) return { met: false, words: 'reading unavailable: ' + failing.join('; '), exportable: true };
    return { met: true, words: 'prime columns = π(B) (stated from the contact rule; not swept)', count: primeCount, exportable: true };
  }
  function renderRosette() {
    const box = $('spc-rosette');
    if (!current() || !S.coef) return;
    const coef = S.coef, rd = rosetteReading(coef, S.result.primeCount);
    const nodes = [el('div', { class: 'spc-dim' }, 'At t₁ = t₂ = 1 with nonzero amplitude, counting distinct divisor contacts on both real rays, the columns s = 2…B with exactly two contacts are the primes.'),
      kv([['host t₁ (canonical)', coef.t1 === null ? 'unparseable' : coef.t1], ['host t₂ (canonical)', coef.t2 === null ? 'unparseable' : coef.t2],
          ['amplitude n₆ nonzero', coef.amplitudeNonzero ? 'yes' : 'no']]),
      el('div', { class: rd.met ? 'spc-good' : 'spc-warn' }, rd.words)];
    if (rd.met) nodes.push(el('div', {}, 'prime column count: ' + rd.count));
    body('spc-rosette').replaceChildren(...nodes);
    stamp('spc-rosette', S.job.key, String(S.shell.B), 'READY');
    box.dataset.coef = S.coefKey;
    box.dataset.values = JSON.stringify({ t1: coef.t1, t2: coef.t2, amplitudeNonzero: coef.amplitudeNonzero, met: rd.met, count: rd.met ? rd.count : null, words: rd.words });
  }

  /* ---------------- export ---------------- */
  function refuse(reason) { logEvent('EXPORT_REFUSED', { reason }); throw Error('EXPORT_REFUSED: ' + reason); }
  async function snapshot() {
    if (S.status !== 'READY') refuse('state is ' + STATE_WORDS[S.status] + ', not ready');
    if (!current()) refuse('no current result');
    const job = S.job;
    const h = readHost();                                   // re-read the host before building the packet
    if (h.error) refuse(h.error);
    if (h.shellKey !== job.shellKey) { schedulePoll(); refuse('host shell changed since the count (' + job.shellKey + ' -> ' + h.shellKey + '); re-reading the host'); }
    if (h.coefKey !== S.coefKey) { S.coef = h.coef; S.coefKey = h.coefKey; renderRosette(); }
    if (h.coef.failures.length) refuse('coefficient unparseable (' + h.coef.failures.join('; ') + ')');
    const pkt = Core.buildPacket({ source: { host_build: PINS.hostBuild, host_sha256: PINS.hostSha256 }, shell: job.shell, result: S.result,
      rosette: { t1: h.coef.t1, t2: h.coef.t2, amplitudeNonzero: h.coef.amplitudeNonzero } });
    const text = Core.exportText(pkt);
    const v = await validateBytes(new TextEncoder().encode(text));
    if (S.job !== job || S.status !== 'READY') refuse('job ' + job.key + ' was superseded during validation');
    const h2 = readHost();
    if (h2.error || h2.shellKey !== job.shellKey || h2.coefKey !== h.coefKey) { schedulePoll(); refuse('host changed during validation; re-reading the host'); }
    if (v.verdict !== null) refuse('validator ' + v.verdict + ': ' + v.detail);
    if (Core.bindLiveSource(v.packet, PINS) !== null) refuse('S12: source is not this running build');
    S.lastExport = { key: job.key, epoch: job.epoch, text };
    logEvent('EXPORT_READY', { exportKey: job.key });
    return { text, key: job.key, epoch: job.epoch, shell: Object.assign({}, job.shell), filename: 'shell-prime-count-' + job.shell.mode + '-' + job.shell.B + '.json', validationMs: v.ms };
  }
  async function exportNow() {
    const msg = $('spc-msg');
    try {
      const snap = await snapshot();
      const url = URL.createObjectURL(new Blob([snap.text], { type: 'application/json' }));
      const a = el('a', { href: url, download: snap.filename }); document.body.append(a); a.click(); a.remove();
      setTimeout(() => URL.revokeObjectURL(url), 5000);
      msg.textContent = 'exported ' + snap.filename + ' for job ' + snap.key + ' (validated: structure, S0–S13, S12 live identity)'; msg.className = 'spc-good';
      return snap;
    } catch (e) { msg.textContent = e.message; msg.className = 'spc-bad'; throw e; }
  }

  /* ---------------- import ---------------- */
  /* v0.1.1 (Astra audit F1): import-operation ownership. Every import action (file input or diagnostics) takes a distinct
   * operation token BEFORE any file reading or validation. Only the latest token may write the imported-readout state,
   * its text, stamps or diagnostic outcome. Ownership is checked after every asynchronous boundary (file read, validation)
   * and in every catch path; a superseded operation stops (or finishes) silently and is logged IMPORT_SUPERSEDED. A matching
   * host epoch is not used: two imports can share one epoch. Export validation is not an import and keeps its own checks. */
  function renderImport() {
    const box = $('spc-import-result'), st = S.importState;
    if (!st) { box.hidden = true; return; }
    box.hidden = false; box.dataset.op = String(st.op);
    if (st.status === 'ACCEPTED') {
      const p = st.packet;
      body('spc-import-result').replaceChildren(el('div', { class: 'spc-good' }, 'import accepted: structure, S0–S13 and S12 (this running build)'),
        kv([['shell', p.shell.mode + ', B = ' + p.shell.base_B], ['prime count π(B)', p.exact.prime_count], ['coprime composites C_B', p.exact.coprime_composite_count],
            ['rosette conditions met', p.rosette.conditions_met ? 'yes' : 'no']]));
      box.dataset.atom = p.shell.base_B; box.dataset.rendered = 'true'; box.dataset.verdict = 'ACCEPTED';
    } else {
      body('spc-import-result').replaceChildren(el('div', { class: st.status === 'REJECTED' ? 'spc-bad' : 'spc-dim' }, st.words));
      box.dataset.atom = ''; box.dataset.rendered = 'false'; box.dataset.verdict = st.verdict || st.status;
    }
  }
  const ownsImport = op => op === S.importSeq;
  function beginImport(entry) {
    S.importSeq += 1; const op = S.importSeq;
    S.importState = { op, status: 'VALIDATING', words: 'validating…' }; logEvent('IMPORT_BEGIN', { op, entry }); renderImport();
    return op;
  }
  // the only writer of the imported-readout state after beginImport
  function commitImport(op, outcome, where) {
    if (!ownsImport(op)) { logEvent('IMPORT_SUPERSEDED', { op, latest: S.importSeq, where, outcome: outcome.status, verdict: outcome.verdict || null }); return false; }
    S.importState = Object.assign({ op }, outcome);
    logEvent(outcome.status === 'ACCEPTED' ? 'IMPORT_ACCEPTED' : 'IMPORT_REJECTED', { op, verdict: outcome.verdict, detail: outcome.words || null });
    renderImport(); return true;
  }
  const rejectState = (verdict, words) => ({ status: 'REJECTED', verdict, words });
  const sleep = ms => new Promise(res => setTimeout(res, ms));
  async function importBytes(bytes, op, entry) {
    if (op === undefined) op = beginImport(entry || 'diagnostics');
    let v;
    logEvent('IMPORT_VALIDATING', { op });
    try { v = await validateBytes(bytes); }
    catch (e) { const st = rejectState('ERROR', 'import failed: ' + e.message); return { op, verdict: 'ERROR', detail: st.words, committed: commitImport(op, st, 'validation threw') }; }
    if (S.importHooks.commitDelayMs) { const d = S.importHooks.commitDelayMs; S.importHooks.commitDelayMs = 0; logEvent('TEST_HOOK_COMMIT_DELAY', { op, ms: d }); await sleep(d); }   // test-only
    let verdict = v.verdict, detail = v.detail;
    if (verdict === null) {
      const bound = Core.bindLiveSource(v.packet, PINS);
      if (bound) { verdict = bound; detail = 'S12: source ' + v.packet.source.host_build + ' / ' + v.packet.source.host_sha256.slice(0, 16) + '… is not this running build (' + PINS.hostBuild + ' / ' + PINS.hostSha256.slice(0, 16) + '…)'; }
    }
    const st = verdict === null ? { status: 'ACCEPTED', verdict: 'ACCEPTED', packet: v.packet } : rejectState(verdict, 'import rejected (' + verdict + '): ' + detail);
    return { op, verdict, detail, committed: commitImport(op, st, 'validation completed') };
  }
  async function importFile(f) {
    const op = beginImport('file-input');              // the token exists before the size check or any read
    if (f.size > Core.BYTE_CAP) return { op, committed: commitImport(op, rejectState('IMPORT', 'import rejected (IMPORT): ' + f.size + ' bytes exceeds the cap of ' + Core.BYTE_CAP), 'size check') };
    let bytes;
    try {
      if (S.importHooks.readFail) { S.importHooks.readFail = false; logEvent('TEST_HOOK_READ_FAIL', { op }); throw Object.assign(Error('injected read failure (test hook)'), { name: 'NotReadableError' }); }   // test-only
      bytes = new Uint8Array(await f.arrayBuffer());
      if (S.importHooks.readHoldMs) { const d = S.importHooks.readHoldMs; S.importHooks.readHoldMs = 0; logEvent('TEST_HOOK_READ_HOLD', { op, ms: d }); await sleep(d); }   // test-only
    } catch (e) { return { op, committed: commitImport(op, rejectState('IMPORT', 'import rejected (IMPORT): the file could not be read (' + e.name + ')'), 'file read') }; }
    if (!ownsImport(op)) { logEvent('IMPORT_SUPERSEDED', { op, latest: S.importSeq, where: 'after file read, before validation', outcome: 'NOT_VALIDATED' }); return { op, committed: false }; }
    try { return await importBytes(bytes, op); }
    catch (e) { return { op, committed: commitImport(op, rejectState('ERROR', 'import failed: ' + e.message), 'import threw') }; }
  }

  /* ---------------- wiring ---------------- */
  toggle.onclick = () => {
    S.open = !S.open; root.hidden = !S.open; toggle.setAttribute('aria-expanded', String(S.open));
    if (S.open) { S.shellKey = null; S.coefKey = null; poll(); pollTimer = setInterval(poll, 250); }
    else {
      clearInterval(pollTimer); pollTimer = null;
      if (S.status === 'COMPUTING') { logEvent('CANCELLED', { cancelledKey: S.job.key, reason: 'panel closed' }); clearTimer(); killCounter('panel closed'); S.status = 'CANCELLED'; render(); }
    }
  };
  $('spc-export').onclick = () => { exportNow().catch(() => {}); };
  $('spc-recount').onclick = () => { if (!S.open) return; S.shellKey = null; poll(); };
  $('spc-import').onchange = ev => {
    const f = ev.target.files && ev.target.files[0]; if (!f) return;
    ev.target.value = '';                              // the File object stays readable; the control is free for the next selection
    importFile(f).catch(() => {});                     // importFile never lets a stale operation write; errors are committed inside
  };
  // Bubble-phase listeners run after the host's own control handlers, so the host change is read (and the registers
  // cleared) in the same event turn; they only read the host. The 250 ms poll covers every other change path.
  for (const type of ['click', 'change', 'keyup']) document.addEventListener(type, () => { if (S.open) poll(); }, { passive: true });
  // keyboard isolation (same pattern as the Basel panel): navigation keys inside this panel never reach the host's
  // window-level shortcuts (<-/-> step phi3, Shift+<-/-> step s). No preventDefault: native control behaviour stays.
  const ISOLATED_KEYS = new Set(['ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown', 'Home', 'End', 'PageUp', 'PageDown']);
  root.addEventListener('keydown', e => { if (ISOLATED_KEYS.has(e.key)) e.stopPropagation(); });
  render();

  window.McombShellPrimeCountDiagnosticsV1 = Object.freeze({
    status: () => ({ open: S.open, status: S.status, key: S.job ? S.job.key : null, epoch: S.epoch, shell: S.shell ? Object.assign({}, S.shell) : null,
      shellKey: S.shellKey, error: S.error, hostError: S.hostError, workerReady: S.workerReady, workerAlive: !!S.worker, jobsStarted: S.jobsStarted,
      budgetMs: S.budgetMs, coef: S.coef, coefKey: S.coefKey, timings: S.timings, resultKey: S.resultKey, zombies: S.zombies.length,
      importState: S.importState ? { op: S.importState.op, status: S.importState.status, verdict: S.importState.verdict || null } : null, importSeq: S.importSeq,
      build: { host_build: PINS.hostBuild, host_sha256: PINS.hostSha256 } }),
    registers: () => Object.fromEntries(['spc-exact', 'spc-neighbour', 'spc-asymptotic', 'spc-rosette'].map(id => {
      const n = $(id); return [id.slice(4), { key: n.dataset.key || '', atom: n.dataset.atom || '', status: n.dataset.status || '', hidden: n.hidden,
        values: n.dataset.values ? JSON.parse(n.dataset.values) : null, text: n.textContent }]; })),
    log: () => S.log.map(x => Object.assign({}, x)),
    poll: () => { if (S.open) poll(); return S.job ? S.job.key : null; },
    snapshot, exportNow,
    importBytes: arr => importBytes(Uint8Array.from(arr), undefined, 'diagnostics.importBytes'),
    importText: text => importBytes(new TextEncoder().encode(text), undefined, 'diagnostics.importText'),
    validateText: text => validateBytes(new TextEncoder().encode(text)),
    runOffline: spec => new Promise((resolve, reject) => {           // fixture parity through a separate worker instance
      const w = spawn((m, src) => { if (m.type === 'spc/ready') return; src.terminate(); if (m.type === 'spc/result') resolve(m); else reject(Error(m.message || m.type)); });
      w.postMessage({ type: 'spc/count', epoch: 0, key: 'offline:' + spec.mode + ':' + spec.B, mode: spec.mode, n1: spec.n1, B: spec.B, hostPrimeDivisorSet: null, hostUpperIsPrime: null });
    }),
    setTimeBudgetMs: ms => { if (!Number.isSafeInteger(ms) || ms < 1 || ms > 600000) throw Error('budget 1..600000 ms'); S.budgetMs = ms; renderStatus(); return S.budgetMs; },
    injectWorkerMessage: m => onCounterMessage(m, S.worker),        // test-only: as if the current worker had sent it
    keepStaleWorkerOnce: () => { S.keepStaleOnce = true; },          // test-only: next cancel keeps the old worker alive
    injectFaultOnce: name => { if (name !== 'routeB') throw Error('unknown fault'); S.faultOnce = name; },
    holdNextJobMs: ms => { S.holdNextMs = ms; },                     // test-only: the next job's worker waits ms before counting
    holdNextImportReadMs: ms => { S.importHooks.readHoldMs = ms; },  // test-only (v0.1.1): next file import pauses ms after its read
    failNextImportRead: () => { S.importHooks.readFail = true; },    // test-only (v0.1.1): next file import's read fails
    delayNextImportCommitMs: ms => { S.importHooks.commitDelayMs = ms; },   // test-only (v0.1.1): next validation result waits ms before its commit
    failValidatorOnce: () => { S.validatorFailOnce = true; },        // test-only (v0.1.1): the next validation request's worker fails
    DEFAULT_BUDGET_MS
  });
})();
