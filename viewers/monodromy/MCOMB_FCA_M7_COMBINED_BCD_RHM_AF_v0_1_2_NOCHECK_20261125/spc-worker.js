/* Shell prime-count panel v0.1 — counting routes and Web Worker entry (worker C, Claude).
 *
 * Route A, LUCY_HEDGEHOG_V1 (spec section 5): two Float64Array(r + 1) tables, r = floor(sqrt(B)) <= 78,911.
 *   Every stored value is an integer <= B < 2^53; quotients use Math.floor(a / d), exact for 0 <= a < 2^53;
 *   r comes from Math.sqrt and is corrected by integer adjustment until r*r <= B < (r+1)*(r+1).
 * Route B, SEGMENTED_SIEVE_V1: one segmented pass (segment 2^20 = 1,048,576) counts primes and coprime composites
 *   together; mandatory for every B <= 11! and never run above it.
 * Range guards: B must be a safe integer in [0, 13!] for route A and in [2, 11!] for route B; 13*B < 2^53 bounds every
 *   gcd and scaled-share step. Arithmetic checks: every table value and result is re-checked to be a safe integer in range.
 * Source rule: no bitwise operators anywhere in this file (checked by the source scan), no regex literals.
 *
 * Messages (worker side): every message carries the epoch; every type is prefixed spc/.
 *   in : spc/count {epoch, key, mode, n1, B, hostPrimeDivisorSet, hostUpperIsPrime, testFault}
 *        spc/validate {epoch, requestId, bytes}
 *   out: spc/ready {epoch}, spc/result {epoch, key, result, timings}, spc/error {epoch, key, message},
 *        spc/validated {epoch, requestId, verdict, detail, packet}
 */
(function (root, factory) {
  'use strict';
  const core = typeof module === 'object' && module.exports ? require('./spc-core.js') : root.McombShellPrimeCountCoreV1;
  const api = factory(core);
  if (typeof module === 'object' && module.exports) module.exports = api;
  else root.McombShellPrimeCountRoutesV1 = api;
  const isWorker = typeof WorkerGlobalScope !== 'undefined' && root instanceof WorkerGlobalScope;
  if (isWorker) api.installWorker(root);
}(typeof self !== 'undefined' ? self : this, function (Core) {
  'use strict';
  const SAFE = 9007199254740992;                    // 2^53
  const BASE_MAX = 6227020800;                      // 13!
  const DIRECT_COUNT_LIMIT = 39916800;              // 11!
  const SEGMENT = 1048576;                          // 2^20
  const now = () => (typeof performance !== 'undefined' ? performance.now() : Date.now());

  function guard(ok, message) { if (!ok) throw Error('range/arithmetic guard: ' + message); }
  const isIntIn = (x, lo, hi) => Number.isSafeInteger(x) && x >= lo && x <= hi;

  function integerSqrt(n) {                          // floor(sqrt(n)), corrected so r*r <= n < (r+1)*(r+1)
    let r = Math.floor(Math.sqrt(n));
    while (r * r > n) r -= 1;
    while ((r + 1) * (r + 1) <= n) r += 1;
    return r;
  }

  /* Route A: Lucy_Hedgehog prime count pi(N) on Float64Array tables (exact integers below 2^53). */
  function primeCountLucy(N) {
    guard(isIntIn(N, 0, BASE_MAX), 'route A needs 0 <= N <= 13!, got ' + N);
    if (N < 2) return 0;
    const r = integerSqrt(N);
    guard(r * r <= N && (r + 1) * (r + 1) > N && r <= 78911, 'integer square root');
    const small = new Float64Array(r + 1), large = new Float64Array(r + 1);
    for (let i = 1; i <= r; i++) { small[i] = i - 1; large[i] = Math.floor(N / i) - 1; }
    for (let p = 2; p <= r; p++) {
      if (small[p] === small[p - 1]) continue;
      const sp = small[p - 1], p2 = p * p;
      const top = Math.min(r, Math.floor(N / p2));
      for (let i = 1; i <= top; i++) {
        const d = i * p;
        large[i] -= (d <= r ? large[d] : small[Math.floor(N / d)]) - sp;
      }
      for (let v = r; v >= p2; v--) small[v] -= small[Math.floor(v / p)] - sp;
    }
    for (let i = 1; i <= r; i++) guard(Number.isSafeInteger(small[i]) && Number.isSafeInteger(large[i]) && small[i] >= 0 && large[i] >= 0 && large[i] <= N, 'table value ' + i);
    return large[1];
  }

  /* Route B: segmented sieve; counts primes <= B and composites m in [2, B] coprime to B, in one pass. */
  function segmentedCount(B, primeDivisorSet) {
    guard(isIntIn(B, 2, DIRECT_COUNT_LIMIT), 'route B is never run above 11! (B = ' + B + ')');
    const r = integerSqrt(B);
    const baseFlags = new Uint8Array(r + 1), basePrimes = [];
    for (let p = 2; p <= r; p++) {
      if (baseFlags[p] === 1) continue;
      basePrimes.push(p);
      for (let q = p * p; q <= r; q += p) baseFlags[q] = 1;
    }
    let primes = 0, coprimeComposites = 0;
    const composite = new Uint8Array(SEGMENT), shared = new Uint8Array(SEGMENT);
    for (let lo = 2; lo <= B; lo += SEGMENT) {
      const hi = Math.min(lo + SEGMENT, B + 1), len = hi - lo;
      composite.fill(0, 0, len); shared.fill(0, 0, len);
      for (const p of basePrimes) {
        if (p * p >= hi) break;
        let start = Math.max(p * p, Math.floor((lo + p - 1) / p) * p);
        for (let m = start - lo; m < len; m += p) composite[m] = 1;
      }
      for (const q of primeDivisorSet) {
        const start = Math.floor((lo + q - 1) / q) * q;
        for (let m = start - lo; m < len; m += q) shared[m] = 1;
      }
      for (let k = 0; k < len; k++) {
        if (composite[k] === 0) primes += 1;
        else if (shared[k] === 0) coprimeComposites += 1;
      }
    }
    guard(isIntIn(primes, 0, B) && isIntIn(coprimeComposites, 0, B), 'route B totals');
    return { primes, coprimeComposites };
  }

  function primeDivisorSetNumber(B) {               // trial division on a safe integer <= 13!
    guard(isIntIn(B, 1, BASE_MAX), 'factorisation domain');
    const out = []; let m = B;
    for (let p = 2; p * p <= m; p += (p === 2 ? 1 : 2)) {
      if (m % p === 0) { out.push(p); while (m % p === 0) m = m / p; }
    }
    if (m > 1) out.push(m);
    return out;
  }
  function gcdNumber(a, b) { while (b !== 0) { const t = a % b; a = b; b = t; } return a; }
  function reducedFraction(num, den) {               // inputs bounded by 13*B < 2^53, so every gcd step is exact
    guard(isIntIn(num, 0, SAFE - 1) && isIntIn(den, 1, SAFE - 1), 'fraction inputs below 2^53');
    const g = gcdNumber(num, den);
    guard(num % g === 0 && den % g === 0, 'gcd divides');
    return { numerator: String(num / g), denominator: String(den / g) };
  }

  /* One job: every schema field for (mode, n1, B). Throws on any disagreement (the job becomes ERROR). */
  function computeShell(job) {
    const B = job.B, factorial = job.mode === 'factorial';
    guard(isIntIn(B, 2, BASE_MAX), 'shell base B in [2, 13!]');
    guard(13 * B < SAFE, '13*B < 2^53');
    const t0 = now();
    if (isIntIn(job.testHoldMs, 1, 60000)) { const until = t0 + job.testHoldMs; while (now() < until) { /* test-only hold: simulates a slow device so cancellation lands mid-count */ } }
    const P = primeDivisorSetNumber(B);
    if (job.hostPrimeDivisorSet && job.hostPrimeDivisorSet.join(',') !== P.join(','))
      throw Error('host prime divisor set ' + job.hostPrimeDivisorSet.join(',') + ' disagrees with the worker factorisation ' + P.join(','));
    const omega = P.length;
    let phi = B;
    for (const p of P) { guard(phi % p === 0, 'totient step'); phi = phi / p * (p - 1); }
    const tA = now();
    const pc = primeCountLucy(B);
    const routeAms = now() - tA;
    let crossCheck, cStatus, C, routeBms = null;
    if (B <= DIRECT_COUNT_LIMIT) {
      const tB = now();
      const rb = segmentedCount(B, P);
      routeBms = now() - tB;
      if (job.testFault === 'routeB') rb.primes += 1;             // test-only disagreement probe (diagnostics hook)
      if (rb.primes !== pc) throw Error('route disagreement: LUCY_HEDGEHOG_V1 gives ' + pc + ', SEGMENTED_SIEVE_V1 gives ' + rb.primes);
      C = rb.coprimeComposites;
      if (pc !== omega + phi - 1 - C) throw Error('identity failed with the direct C_B count');
      crossCheck = 'SEGMENTED_SIEVE_AGREES'; cStatus = 'DIRECT_COUNTED';
    } else {
      C = omega + phi - 1 - pc;
      crossCheck = 'NOT_RUN_ABOVE_LIMIT'; cStatus = 'DERIVED_FROM_PRIME_COUNT';
    }
    guard(isIntIn(C, 0, B), 'C_B range');
    const share = reducedFraction(pc - omega, phi);
    let scaled = null, primeCountN1 = null;
    if (factorial) {
      guard(isIntIn(job.n1, 3, 13), 'factorial index n1 in 3..13');
      primeCountN1 = primeCountLucy(job.n1);
      if (primeCountN1 !== omega) throw Error('omega(n1!) = ' + omega + ' but pi(n1) = ' + primeCountN1);
      scaled = reducedFraction(job.n1 * (pc - omega), phi);
    }
    const upperIsPrime = Core.isPrimeBig(BigInt(B) + 1n);
    if (typeof job.hostUpperIsPrime === 'boolean' && job.hostUpperIsPrime !== upperIsPrime)
      throw Error('host isPrime(B + 1) = ' + job.hostUpperIsPrime + ' disagrees with the worker Miller-Rabin');
    return {
      result: { base: String(B), primeCount: String(pc), crossCheck, primeDivisorSet: P.map(String), distinctPrimeDivisorCount: String(omega),
        eulerTotient: String(phi), coprimeCompositeCount: String(C), coprimeCompositeStatus: cStatus, residuePrimeShare: share,
        upper: String(B + 1), upperIsPrime, primeCountUpper: String(pc + (upperIsPrime ? 1 : 0)), scaledShare: scaled,
        primeCountN1: primeCountN1 === null ? null : String(primeCountN1) },
      timings: { routeAms, routeBms, totalMs: now() - t0 }
    };
  }

  /* BigInt route interface for the validator replays (S3/S5/S7) */
  function makeRoutes() {
    const memo = new Map();
    const b = B => { const n = Number(B); guard(BigInt(n) === B, 'route input exact'); return n; };
    const routeB = B => { const k = String(B); if (!memo.has(k)) memo.set(k, segmentedCount(b(B), primeDivisorSetNumber(b(B)))); return memo.get(k); };
    return {
      lucy: B => BigInt(primeCountLucy(b(B))),
      segmented: B => BigInt(routeB(B).primes),
      directC: B => BigInt(routeB(B).coprimeComposites)
    };
  }

  function installWorker(scope) {
    let epoch = 0;
    scope.onmessage = ev => {
      const m = ev.data || {};
      epoch = m.epoch;
      if (m.type === 'spc/count') {
        try {
          const out = computeShell(m);
          scope.postMessage({ type: 'spc/result', epoch: m.epoch, key: m.key, result: out.result, timings: out.timings });
        } catch (e) { scope.postMessage({ type: 'spc/error', epoch: m.epoch, key: m.key, message: String(e && e.message || e) }); }
      } else if (m.type === 'spc/validate') {
        try {
          const t0 = now();
          const v = Core.loadPacketBytes(new Uint8Array(m.bytes), makeRoutes());
          scope.postMessage({ type: 'spc/validated', epoch: m.epoch, requestId: m.requestId, verdict: v.verdict, detail: v.detail, packet: v.packet, ms: now() - t0 });
        } catch (e) { scope.postMessage({ type: 'spc/validated', epoch: m.epoch, requestId: m.requestId, verdict: 'ERROR', detail: String(e && e.message || e), packet: null }); }
      } else scope.postMessage({ type: 'spc/error', epoch: m.epoch, key: m.key || null, message: 'unknown message type' });
    };
    scope.postMessage({ type: 'spc/ready', epoch });
  }

  return Object.freeze({ primeCountLucy, segmentedCount, primeDivisorSetNumber, computeShell, makeRoutes, installWorker, integerSqrt,
    SEGMENT, DIRECT_COUNT_LIMIT, BASE_MAX });
}));
