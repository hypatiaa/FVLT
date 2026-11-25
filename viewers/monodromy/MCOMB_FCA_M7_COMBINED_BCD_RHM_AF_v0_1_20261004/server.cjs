'use strict';
// /assess server v0.2: isolated repair successor of the inherited server.cjs (SHA-256 689432af58fdc5070e34dbc8b1e8ba82346de756abe8009557935dcee71a572e),
// per the 429 investigation (ASSESS_429_INVESTIGATION_20260930) and Astra's bounded repair scope (2026-09-30):
//  1. cancellation is bound to a specific request/job and its own child; nothing kills a global "active" child;
//  2. premature response closure (client disconnect before the response is written) is detected and distinguished from
//     normal completion; the end of the request body alone is not cancellation;
//  3. the slot stays occupied until the job's child has actually closed (kill() is not confirmation);
//  4. cleanup is idempotent and ownership-checked: a late callback of an old job never touches a newer job;
//  5. a request that arrives while a CANCELLED job is still terminating may wait for the slot, bounded by
//     WAIT_LIMIT_MS and a queue capacity of WAIT_QUEUE_CAPACITY; a waiting client that disconnects leaves the queue.
//     Contention with a LIVE job keeps the explicit contract: 429 "Verifier busy", immediately;
//  6. a cancelled job's result is discarded before signing or sending.
// Unchanged: Host/Origin checks, launch token, request binding headers, 32 MB cap, fixed endpoint, the signed
// BSD_LOCALHOST_ASSESSMENT_V1 payload, the 120 s verifier cap and 2 MB output cap, and the page served at "/".
// start() with no options behaves like the inherited server for the package directory that contains this file.
// Options exist for tests only and are documented in TESTS.md: root (package directory), verifierArgs, execPath,
// verifierTimeoutMs, skipIntegrity, waitLimitMs, killChild (delays cancellation's kill, to hold a job in the terminating state), exposeForTests (returns the token and a lifecycle trace to the test process).
const http = require('node:http'), fs = require('node:fs'), path = require('node:path'), crypto = require('node:crypto'), { spawn } = require('node:child_process');
const hash = b => crypto.createHash('sha256').update(b).digest('hex');
const WAIT_LIMIT_MS = 3000, WAIT_QUEUE_CAPACITY = 1, MAX_BYTES = 32000000, VERIFIER_TIMEOUT_MS = 120000, MAX_OUTPUT = 2000000;

async function start(options = {}) {
  const root = options.root || __dirname;
  if (!options.skipIntegrity) {
    require(path.join(root, '..', 'BSD_TATE_T4_v0_1_20260923', 'check-integrity.cjs')).check();
    if (fs.existsSync(path.join(root, 'MANIFEST.sha256'))) require(path.join(root, 'check-integrity.cjs')).check();
  }
  const token = crypto.randomBytes(32).toString('hex'), keys = crypto.generateKeyPairSync('ec', { namedCurve: 'prime256v1' }),
    publicKey = keys.publicKey.export({ format: 'jwk' }), launchId = crypto.randomBytes(16).toString('hex');
  const pinned = JSON.parse(fs.readFileSync(path.join(root, 'BUILD_PINS.json'), 'utf8')), html = fs.readFileSync(path.join(root, 'monodromy-31-linked-reduction.html'), 'utf8');
  if (hash(html) !== pinned.viewerSha256) throw Error('V1 viewer hash mismatch');
  const execPath = options.execPath || process.execPath, verifierArgs = options.verifierArgs || [path.join(root, 'assess-stdin.cjs')];
  const verifierTimeoutMs = options.verifierTimeoutMs || VERIFIER_TIMEOUT_MS, waitLimitMs = options.waitLimitMs || WAIT_LIMIT_MS;
  const killChild = options.killChild || (child => child.kill());   // test-only seam: lets tests widen the termination window
  let origin, host, slot = null, nextJob = 0, closing = false;
  const waiters = [];                       // requests waiting for a cancelled job to finish terminating
  const events = [];                        // lifecycle trace for tests (no secrets)
  const note = (kind, data) => { events.push({ t: Date.now(), kind, ...data }); if (events.length > 5000) events.shift(); };

  function newJob() {
    const job = { id: ++nextJob, child: null, cancelled: false, released: false, childClosed: false };
    job.release = reason => {                               // idempotent, ownership-checked
      if (job.released) return;
      job.released = true;
      if (slot === job) slot = null;
      note('slot_released', { job: job.id, reason });
      wakeWaiter();
    };
    job.cancel = reason => {
      if (job.cancelled || job.released) return;
      job.cancelled = true;
      note('job_cancelled', { job: job.id, reason, childAlive: !!job.child && !job.childClosed });
      if (job.child && !job.childClosed) killChild(job.child);   // only this job's own child
      else if (!job.child) job.release('cancelled before verifier start');
      // else: the slot is released by the child's own 'close' (point 3)
    };
    return job;
  }
  function wakeWaiter() {
    while (waiters.length && !slot) {
      const w = waiters.shift();
      if (w.gone) continue;
      clearTimeout(w.timer);
      w.resume();
      return;
    }
  }

  const server = http.createServer((req, res) => {
    res.setHeader('Cache-Control', 'no-store'); res.setHeader('X-Content-Type-Options', 'nosniff'); res.setHeader('Referrer-Policy', 'no-referrer'); res.setHeader('Cross-Origin-Resource-Policy', 'same-origin');
    const reject = (code, message) => { if (res.headersSent || res.destroyed) return; res.writeHead(code, { 'Content-Type': 'application/json', Connection: 'close' }); res.end(JSON.stringify({ error: message })); };
    if (req.headers.host !== host || req.headers.origin && req.headers.origin !== origin) return reject(403, 'Host/Origin rejected');
    if (req.method === 'GET' && req.url === '/') {
      const config = { origin, token, publicKey, launchId, verifier: pinned.t4Verifier }; const script = '<script>window.BSDVerifierLaunch=' + JSON.stringify(config).replace(/</g, '\\u003c') + ';</script>';
      res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' }); return res.end(html.replace('<head>', '<head>' + script));
    }
    if (req.method !== 'POST' || req.url !== '/assess') return reject(404, 'Fixed endpoint only');
    if (req.headers.origin !== origin || req.headers['content-type'] !== 'application/json') return reject(403, 'Exact Origin and JSON content type required');
    const auth = Buffer.from(req.headers.authorization || ''), wanted = Buffer.from('Bearer ' + token); if (auth.length !== wanted.length || !crypto.timingSafeEqual(auth, wanted)) return reject(403, 'Launch token rejected');
    const requestId = req.headers['x-bsd-request-id'], contextId = req.headers['x-bsd-context']; if (!/^[a-f0-9]{32}$/.test(requestId || '') || !/^[a-f0-9]{64}$/.test(contextId || '')) return reject(400, 'Request binding required');
    if (Number(req.headers['content-length'] || 0) > MAX_BYTES) return reject(413, 'Inherited 32 MB packet cap');
    if (closing) return reject(503, 'Server closing');
    const rid = requestId.slice(0, 8);
    note('request_in', { rid });
    if (!slot) return run();
    // Point 5: contention. A live job keeps the explicit 429 contract; a cancelled job that is still terminating may be waited for.
    if (!slot.cancelled) { note('busy_live', { rid, holder: slot.id }); return reject(429, 'Verifier busy'); }
    if (waiters.filter(w => !w.gone).length >= WAIT_QUEUE_CAPACITY) { note('busy_queue_full', { rid, holder: slot.id }); return reject(429, 'Verifier busy'); }
    const w = { gone: false, resume: null, timer: null };
    w.resume = () => { if (w.gone) return; w.gone = true; note('waiter_resumed', { rid }); run(); };
    w.timer = setTimeout(() => { if (w.gone) return; w.gone = true; note('waiter_timeout', { rid }); reject(429, 'Verifier busy'); }, waitLimitMs);
    res.on('close', () => { if (!w.gone && !res.writableFinished) { w.gone = true; clearTimeout(w.timer); note('waiter_left', { rid }); } });
    waiters.push(w);
    note('waiter_queued', { rid, holder: slot.id });
    return undefined;

    function run() {
      if (closing) return reject(503, 'Server closing');
      if (slot) { note('busy_live', { rid, holder: slot.id }); return reject(429, 'Verifier busy'); }
      const job = newJob(); slot = job;
      note('job_start', { job: job.id, rid });
      const chunks = []; let size = 0, bodyDone = false;
      // Point 2: premature closure = the response closes before it has been written completely (client went away).
      res.on('close', () => { if (!res.writableFinished) job.cancel('client closed before the response was written'); });
      req.setTimeout(15000, () => req.destroy());
      req.on('error', () => { if (!bodyDone) job.cancel('request error before body end'); });
      req.on('data', chunk => {
        size += chunk.length;
        if (size > MAX_BYTES) { bodyDone = true; job.release('packet cap'); reject(413, 'Inherited 32 MB packet cap'); req.destroy(); } else chunks.push(chunk);
      });
      req.on('end', () => {
        if (bodyDone) return; bodyDone = true;
        if (job.cancelled || job.released) return;                      // cancelled while the body was arriving: no verifier
        const bytes = Buffer.concat(chunks), requestSha256 = hash(bytes);
        let child;
        try {
          child = spawn(execPath, verifierArgs, { cwd: root, windowsHide: true, stdio: ['pipe', 'pipe', 'pipe'], env: { ...process.env, PYTHONDONTWRITEBYTECODE: '1' } });
        } catch (e) { note('spawn_throw', { job: job.id, error: e.message }); job.release('spawn failed'); return reject(500, 'Verifier could not start'); }
        job.child = child;
        note('verifier_spawn', { job: job.id, pid: child.pid ?? null });
        let output = '', error = '', overflow = false, settled = false;
        const timer = setTimeout(() => { note('verifier_timeout', { job: job.id }); child.kill(); }, verifierTimeoutMs);
        child.stdout.on('data', c => { output += c; if (output.length > MAX_OUTPUT) { overflow = true; child.kill(); } });
        child.stderr.on('data', c => { if (error.length < 8000) error += c; });
        child.stdin.on('error', () => {});
        const settle = (code, how) => {
          if (settled) return; settled = true; clearTimeout(timer);
          job.childClosed = true;
          note('verifier_exit', { job: job.id, code, how, cancelled: job.cancelled });
          job.release(how);                                                // point 3: only now is the slot free
          if (job.cancelled) { note('result_discarded', { job: job.id }); return; }   // point 6: nothing signed or sent
          let assessment = null;
          try { if (code !== 0 || overflow) throw Error(error || 'Verifier failed or exceeded runtime/output cap'); assessment = JSON.parse(output); }
          catch (e) { assessment = { status: 'REJECTED', reason: String(e.message).slice(0, 2000), certificate: null }; }
          const payload = JSON.stringify({ schema: 'BSD_LOCALHOST_ASSESSMENT_V1', launchId, requestId, contextId, requestSha256, assessment }),
            signature = crypto.sign('sha256', Buffer.from(payload), { key: keys.privateKey, dsaEncoding: 'ieee-p1363' }).toString('base64');
          if (!res.destroyed && !res.headersSent) { res.writeHead(200, { 'Content-Type': 'application/json' }); res.end(JSON.stringify({ payload, signature })); }
        };
        child.on('error', e => { error = e.message; if (child.pid === undefined) settle(null, 'spawn error'); });   // spawn failure: no 'close' is guaranteed
        child.on('close', code => settle(code, 'close'));
        child.stdin.end(bytes);
      });
      return undefined;
    }
  });
  server.requestTimeout = 15000; server.headersTimeout = 15000; server.maxRequestsPerSocket = 30;
  await new Promise((resolve, rej) => { server.once('error', rej); server.listen(0, '127.0.0.1', resolve); }); host = '127.0.0.1:' + server.address().port; origin = 'http://' + host;
  const close = () => new Promise(resolve => {
    closing = true;
    for (const w of waiters.splice(0)) { if (!w.gone) { w.gone = true; clearTimeout(w.timer); } }
    const holder = slot;
    const finish = () => { server.close(() => resolve()); server.closeAllConnections(); };
    if (holder && holder.child && !holder.childClosed) {
      holder.cancel('server closing');
      const t = setTimeout(finish, 5000);                               // bounded shutdown wait
      holder.child.once('close', () => { clearTimeout(t); finish(); });
    } else finish();
  });
  const service = { server, origin, close };
  if (options.exposeForTests) Object.assign(service, { token, launchId, publicKey, events,      // test-only: never set by the served page's launcher
    state: () => ({ slot: slot && { id: slot.id, cancelled: slot.cancelled, childPid: slot.child?.pid ?? null }, waiters: waiters.filter(w => !w.gone).length }) });
  return service;
}
module.exports = { start, WAIT_LIMIT_MS, WAIT_QUEUE_CAPACITY };
if (require.main === module) {
  if (process.argv.length !== 2) throw Error('No host, port or path arguments accepted');
  start().then(q => { console.log('BSD V1 viewer: ' + q.origin + '/'); for (const signal of ['SIGINT', 'SIGTERM']) process.on(signal, () => q.close().then(() => process.exit(0))); }).catch(e => { console.error(e.message); process.exitCode = 1; });
}
