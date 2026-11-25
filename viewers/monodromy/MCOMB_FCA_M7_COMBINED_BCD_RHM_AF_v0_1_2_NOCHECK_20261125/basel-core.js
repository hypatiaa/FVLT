/* Basel Fourier prototype core v0.1.3 — exact integer-beta arithmetic (JavaScript BigInt).
 *
 * v0.1.2 adds the prime strip (prototype-only quantities, NOT in the accepted v0.1.2 schema):
 *   F_p = (1 - p^-b)^-1, T_p = sum_{k<=v_p(N)} p^(-kb), and the remainder R_P = prod_{p>P} F_p,
 *   enclosed as [zeta_lo / Pi_P, zeta_hi / Pi_P] with Pi_P = prod_{p<=P} F_p exact (b >= 2).
 *   Exact identity: zeta/Z = prod_{p|N} F_p/T_p * prod_{p!|N, p<=P} F_p * R_P  (for P >= every prime of N).
 *
 * v0.1.3 (Astra): display logs of ratios are log1p(toNumber(ratio - 1)) with the subtraction exact, so
 *   contributions like 2^64/(2^64-1) no longer round to log 1 = 0; toNumber keeps ~64 significant bits
 *   for any magnitude; the remainder reports whether its enclosure resolves R_P > 1 at the zeta-table precision.
 *   Certified logs (Astra): -log(1 - a/c) = sum_{j<=m} t^j/j + eps, 0 <= eps <= a^(m+1) / ((m+1) c^m (c - a)),
 *   summed at scale 2^K with floor/ceil, K chosen from the size of t plus a 72-bit margin (not a fixed 256).
 *   Cells use t = p^-(v+1)b exactly. log R_P is the intersection of two certified routes: the zeta-table route
 *   [log R_lo, log R_hi] (0 as lower end when R_lo <= 1) and the direct route sum_{P<p<=M} -log(1 - p^-b) plus
 *   a tail in [0, M / ((b-1)(M^b - 1))]. Floating point is used only to draw.
 *
 * Semantics follow the accepted schema baseline BASEL_FOURIER_READOUT v0.1.2 (delta audit PASS,
 * manifest 6aea9e88c6bce4a2d6a6b123bab73490955ee2ba44b0dc7db077733b400df4a2) for the quantities the
 * prototype shows: Z_N(b), node weights 1/d^b, subcone sums Z_d(b), and for b >= 2 the zeta comparison
 * (E_N(b), exponent tails E - Z exact, gap and absent-prime enclosures with directed 60-place rounding
 * from the pinned zeta table). test_core.cjs checks every such string against the pinned v0.1.2
 * fixtures. Floating point is used ONLY for drawing sizes and chart positions, never for a readout.
 *
 * No export, no Ramanujan route, no noninteger beta (UNRESOLVED), no standalone E_N field (a
 * next-version candidate): E_N is shown only inside the b >= 2 comparison, exactly as in v0.1.2.
 */
(function (root) {
  'use strict';
  const DEC = 60n, TEN60 = 10n ** 60n;
  const ZETA_TABLE = Object.freeze({"2":["1.644934066848226436472415166646025189218949901206798437735558","1.644934066848226436472415166646025189218949901206798437735559"],"3":["1.202056903159594285399738161511449990764986292340498881792271","1.202056903159594285399738161511449990764986292340498881792272"],"4":["1.082323233711138191516003696541167902774750951918726907682976","1.082323233711138191516003696541167902774750951918726907682977"],"5":["1.036927755143369926331365486457034168057080919501912811974192","1.036927755143369926331365486457034168057080919501912811974193"],"6":["1.017343061984449139714517929790920527901817490032853561842408","1.017343061984449139714517929790920527901817490032853561842409"],"7":["1.008349277381922826839797549849796759599863560565238706417283","1.008349277381922826839797549849796759599863560565238706417284"],"8":["1.004077356197944339378685238508652465258960790649850020329110","1.004077356197944339378685238508652465258960790649850020329111"],"9":["1.002008392826082214417852769232412060485605851394888756548596","1.002008392826082214417852769232412060485605851394888756548597"],"10":["1.000994575127818085337145958900319017006019531564477517257788","1.000994575127818085337145958900319017006019531564477517257789"],"11":["1.000494188604119464558702282526469936468606435758208617119141","1.000494188604119464558702282526469936468606435758208617119142"],"12":["1.000246086553308048298637998047739670960416088458003404533040","1.000246086553308048298637998047739670960416088458003404533041"],"13":["1.000122713347578489146751836526357395714275105895509845136702","1.000122713347578489146751836526357395714275105895509845136703"],"14":["1.000061248135058704829258545105135333747481696169154549482755","1.000061248135058704829258545105135333747481696169154549482756"],"15":["1.000030588236307020493551728510645062587627948706858177506569","1.000030588236307020493551728510645062587627948706858177506570"],"16":["1.000015282259408651871732571487636722023237388990471531153105","1.000015282259408651871732571487636722023237388990471531153106"],"17":["1.000007637197637899762273600293563029213088249090262679095379","1.000007637197637899762273600293563029213088249090262679095380"],"18":["1.000003817293264999839856461644621939730454697218953331143174","1.000003817293264999839856461644621939730454697218953331143175"],"19":["1.000001908212716553938925656957795101353258571144838630235933","1.000001908212716553938925656957795101353258571144838630235934"],"20":["1.000000953962033872796113152038683449345943794187410595750056","1.000000953962033872796113152038683449345943794187410595750057"],"21":["1.000000476932986787806463116719604373045966446694784937600207","1.000000476932986787806463116719604373045966446694784937600208"],"22":["1.000000238450502727732990003648186752994935041821779658269849","1.000000238450502727732990003648186752994935041821779658269850"],"23":["1.000000119219925965311073067788718882326387254997784519858603","1.000000119219925965311073067788718882326387254997784519858604"],"24":["1.000000059608189051259479612440207935801227503918837302795864","1.000000059608189051259479612440207935801227503918837302795865"],"25":["1.000000029803503514652280186063705069366011844730919543312398","1.000000029803503514652280186063705069366011844730919543312399"],"26":["1.000000014901554828365041234658506630698628864788167885910547","1.000000014901554828365041234658506630698628864788167885910548"],"27":["1.000000007450711789835429491981004170604119454719031882565829","1.000000007450711789835429491981004170604119454719031882565830"],"28":["1.000000003725334024788457054819204018402423232893059295811519","1.000000003725334024788457054819204018402423232893059295811520"],"29":["1.000000001862659723513049006403909945416948061665330469200665","1.000000001862659723513049006403909945416948061665330469200666"],"30":["1.000000000931327432419668182871764735021219813567955136816185","1.000000000931327432419668182871764735021219813567955136816186"],"31":["1.000000000465662906503378407298923325122007106269185336947307","1.000000000465662906503378407298923325122007106269185336947308"],"32":["1.000000000232831183367650549200145597594049502482982284530311","1.000000000232831183367650549200145597594049502482982284530312"],"33":["1.000000000116415501727005197759297383545630951652247172763593","1.000000000116415501727005197759297383545630951652247172763594"]});

  // ------------------------------------------------------------- exact rationals
  const abs = x => (x < 0n ? -x : x);
  function gcd(a, b) { a = abs(a); b = abs(b); while (b) { [a, b] = [b, a % b]; } return a; }
  function frac(n, d = 1n) {
    if (d === 0n) throw new Error('zero denominator');
    if (d < 0n) { n = -n; d = -d; }
    const g = gcd(n, d) || 1n;
    return { n: n / g, d: d / g };
  }
  const add = (a, b) => frac(a.n * b.d + b.n * a.d, a.d * b.d);
  const sub = (a, b) => frac(a.n * b.d - b.n * a.d, a.d * b.d);
  const mul = (a, b) => frac(a.n * b.n, a.d * b.d);
  const canon = f => (f.d === 1n ? f.n.toString() : `${f.n}/${f.d}`);
  function floorDiv(a, b) {             // b > 0; BigInt '/' truncates toward zero
    const q = a / b;
    return (a % b !== 0n && a < 0n) ? q - 1n : q;
  }
  const ceilDiv = (a, b) => -floorDiv(-a, b);
  function fmt60(n) {
    const s = n < 0n ? '-' : '', m = abs(n);
    return `${s}${m / TEN60}.${(m % TEN60).toString().padStart(60, '0')}`;
  }
  const decFloor = f => fmt60(floorDiv(f.n * TEN60, f.d));
  const decCeil = f => fmt60(ceilDiv(f.n * TEN60, f.d));
  function parseDec(s) {
    const m = /^(-?)(\d+)\.(\d{60})$/.exec(s);
    const v = BigInt(m[2] + m[3]);
    return frac(m[1] ? -v : v, TEN60);
  }
  function toNumber(f) {                // display only: ~64 significant bits at any magnitude, no flush to 0
    if (f.n === 0n) return 0;
    const neg = f.n < 0n, n = neg ? -f.n : f.n, d = f.d, bits = x => x.toString(2).length;
    const shift = 64 - (bits(n) - bits(d));          // quotient scaled to about 2^64
    const q = shift >= 0 ? (n << BigInt(shift)) / d : n / (d << BigInt(-shift));
    const h = Math.trunc(shift / 2);
    const v = Number(q) * Math.pow(2, -h) * Math.pow(2, -(shift - h));
    return neg ? -v : v;
  }
  const logRatio = f => Math.log1p(toNumber(sub(f, frac(1n))));   // display log of a ratio near 1, subtraction exact

  // ------------------------------------------------------------- atoms and divisors
  const SHELL_PRIMES = [2, 3, 5, 7, 11, 13];
  function factorialFactors(k) {        // Legendre: exponent of p in k! = sum floor(k / p^i)
    const out = [];
    for (const p of SHELL_PRIMES) {
      let a = 0, q = p;
      while (q <= k) { a += Math.floor(k / q); q *= p; }
      if (a) out.push([BigInt(p), a]);
    }
    return out;
  }
  const atomValue = fac => fac.reduce((N, [p, a]) => N * p ** BigInt(a), 1n);
  const divisorCount = fac => fac.reduce((t, [, a]) => t * (a + 1), 1);
  function divisorTuples(fac) {         // host M7 canonical order: first prime slowest, last fastest
    let out = [[]];
    for (const [, a] of fac) {
      const next = [];
      for (const t of out) for (let k = 0; k <= a; k++) next.push([...t, k]);
      out = next;
    }
    return out;
  }
  const tupleValue = (fac, e) => fac.reduce((d, [p], i) => d * p ** BigInt(e[i]), 1n);

  // ------------------------------------------------------------- the observable
  function Z(fac, b) {                   // Z_N(b) = prod_p sum_{k<=a} p^(-kb)
    const B = BigInt(b);
    let z = frac(1n);
    for (const [p, a] of fac) {
      let num = 0n;
      for (let k = 0; k <= a; k++) num += p ** (BigInt(a - k) * B);
      z = mul(z, frac(num, p ** (BigInt(a) * B)));
    }
    return z;
  }
  const subconeFactors = (fac, e) => fac.map(([p], i) => [p, e[i]]).filter(([, a]) => a > 0);
  const nodeWeight = (d, b) => frac(1n, d ** BigInt(b));

  function zetaComparison(fac, b) {
    if (b <= 1) return { available: false, reason: 'DOMAIN_BETA_NOT_ABOVE_ONE',
                         words: 'unavailable: ζ(β) comparison needs β > 1' };
    const [zlo, zhi] = ZETA_TABLE[String(b)];
    const zl = parseDec(zlo), zh = parseDec(zhi), B = BigInt(b);
    const z = Z(fac, b);
    let E = frac(1n);
    for (const [p] of fac) E = mul(E, frac(p ** B, p ** B - 1n));
    return {
      available: true,
      zeta: [zlo, zhi],
      Z: z, E, tails: sub(E, z),
      gap: [decFloor(sub(zl, z)), decCeil(sub(zh, z))],
      absent: [decFloor(sub(zl, E)), decCeil(sub(zh, E))],
    };
  }

  // Shell series for the strip chart: exact strings plus display floats.
  function shellSeries(b, kmax = 13) {
    const rows = [];
    for (let k = 1; k <= kmax; k++) {
      const fac = factorialFactors(k), zc = zetaComparison(fac, b);
      const prev = k > 1 ? factorialFactors(k - 1) : [];
      const newPrime = fac.find(([p]) => !prev.some(([q]) => q === p));
      rows.push({ k, fac, zc, addsPrime: newPrime ? newPrime[0] : null,
                  absent: zc.available ? toNumber(parseDec(zc.absent[0])) : null,
                  tails: zc.available ? toNumber(zc.tails) : null,
                  gap: zc.available ? toNumber(parseDec(zc.gap[0])) : null });
    }
    return rows;
  }

  // ------------------------------------------------------------- prime strip (v0.1.2, prototype only)
  const CUTOFFS = [13, 30, 50, 100, 200];         // every cutoff >= 13, so every prime of k! (k <= 13) is shown
  function primesUpTo(P) {
    const sieve = new Uint8Array(P + 1), out = [];
    for (let i = 2; i <= P; i++) { if (!sieve[i]) { out.push(i); for (let j = i * i; j <= P; j += i) sieve[j] = 1; } }
    return out;
  }
  const fullFactor = (p, b) => {                  // (1 - p^-b)^-1 = p^b / (p^b - 1); diverges at b = 0
    const q = BigInt(p) ** BigInt(b);
    return b >= 1 ? frac(q, q - 1n) : null;
  };
  function truncFactor(p, a, b) {                 // sum_{k<=a} p^(-kb); b = 0 gives a + 1
    const P = BigInt(p), B = BigInt(b);
    let num = 0n;
    for (let k = 0; k <= a; k++) num += P ** (BigInt(a - k) * B);
    return frac(num, P ** (BigInt(a) * B));
  }
  function primeStrip(fac, b, P) {
    if (!CUTOFFS.includes(P)) throw new Error('undeclared cutoff');
    const v = new Map(fac.map(([p, a]) => [Number(p), a]));
    if ([...v.keys()].some(p => p > P)) throw new Error('cutoff below a prime of N');
    return primesUpTo(P).map(p => {
      const a = v.get(p) || 0, F = fullFactor(p, b), T = truncFactor(p, a, b);
      return { p, a, present: a > 0, F, T, ratio: F ? frac(F.n * T.d, F.d * T.n) : null };
    });
  }
  function remainder(b, P) {                       // R_P = prod_{p>P} (1 - p^-b)^-1
    if (b === 0) return { available: false, words: 'unavailable: every factor (1 − p⁰)⁻¹ diverges at β = 0' };
    if (b === 1) return { available: false, words: 'unavailable: the product over all primes diverges at β = 1' };
    let Pi = frac(1n);
    for (const p of primesUpTo(P)) Pi = mul(Pi, fullFactor(p, b));
    const [zlo, zhi] = ZETA_TABLE[String(b)], zl = parseDec(zlo), zh = parseDec(zhi);
    const lo = frac(zl.n * Pi.d, zl.d * Pi.n), hi = frac(zh.n * Pi.d, zh.d * Pi.n);
    const one = frac(1n), resolved = lo.n > lo.d;     // lower end > 1: the excess R - 1 > 0 is resolved at table precision
    return { available: true, Pi, R: [decFloor(lo), decCeil(hi)], lo, hi, resolved,
             excessUpper: sub(hi, one), words: resolved ? '' : 'excess R − 1 unresolved at the ζ-table precision (10⁻⁶⁰); only an upper bound is known' };
  }
  const primeCount = x => primesUpTo(Math.floor(x)).length;

  // ------------------------------------------------------------- certified logarithms (v0.1.3)
  const bitLen = x => x.toString(2).length;
  const MARGIN = 72;                               // bits kept below the magnitude of the quantity
  function logSeries(a, c, K) {                    // -log(1 - a/c), 0 < a < c: [lo, hi] as integers at scale 2^K
    const S = 1n << BigInt(K);
    let lo = 0n, hi = 0n, an = a, cn = c;
    for (let j = 1n; ; j++) {
      const num = S * an, den = j * cn;
      lo += num / den; hi += (num + den - 1n) / den;
      const rnum = S * an * a, rden = (j + 1n) * cn * (c - a);   // remainder bound after j terms, scaled
      if (rnum < rden) { hi += 1n; return [lo, hi]; }            // remainder < one unit
      an *= a; cn *= c;
      if (j > 20000n) throw new Error('series budget');
    }
  }
  function logEnclosure(a, c) {                    // certified -log(1 - a/c) as exact fractions, relative width ~2^-MARGIN
    const K = Math.max(8, bitLen(c) - bitLen(a) + MARGIN), S = 1n << BigInt(K);
    const [lo, hi] = logSeries(a, c, K);
    return { lo: frac(lo, S), hi: frac(hi, S) };
  }
  const logOfRational = r => logEnclosure(r.n - r.d, r.n);   // log r for r > 1, via t = (r - 1)/r
  const mid = e => (toNumber(e.lo) + toNumber(e.hi)) / 2;
  function cellLogEnclosure(p, a, b) {             // log(F_p/T_p) = -log(1 - p^-(a+1)b), b >= 1
    const e = logEnclosure(1n, BigInt(p) ** BigInt((a + 1) * b));
    return { ...e, mid: mid(e) };
  }
  const remLogCache = new Map();
  function remainderLog(b, P, relTarget = Math.pow(2, -50), Mcap = 100000) {
    const key = `${b}:${P}`;
    if (remLogCache.has(key)) return remLogCache.get(key);
    if (b <= 1) return remainder(b, P);
    const R = remainder(b, P);
    const zeta = { lo: R.resolved ? logOfRational(R.lo).lo : frac(0n), hi: logOfRational(R.hi).hi };
    const small = primesUpTo(Math.max(2 * P, 1000)), p1 = small.find(q => q > P);
    // choose M from the target: tail ~ M^(1-b)/(b-1) <= relTarget * p1^-b  (the choice does not affect rigour)
    const need = Math.exp((Math.log(1 / relTarget) + b * Math.log(p1) - Math.log(b - 1)) / (b - 1));
    const M = Math.max(p1, Math.min(Mcap, Math.ceil(need)));
    const K = bitLen(BigInt(p1) ** BigInt(b)) + MARGIN, S = 1n << BigInt(K);
    let lo = 0n, hi = 0n;
    for (const q of primesUpTo(M)) if (q > P) { const [l, h] = logSeries(1n, BigInt(q) ** BigInt(b), K); lo += l; hi += h; }
    const MB = BigInt(M);
    hi += (S * MB + BigInt(b - 1) * (MB ** BigInt(b) - 1n) - 1n) / (BigInt(b - 1) * (MB ** BigInt(b) - 1n));   // ceil tail bound
    const direct = { lo: frac(lo, S), hi: frac(hi, S) };
    const gt = (x, y) => x.n * y.d > y.n * x.d;
    const both = { lo: gt(zeta.lo, direct.lo) ? zeta.lo : direct.lo, hi: gt(zeta.hi, direct.hi) ? direct.hi : zeta.hi };
    if (gt(both.lo, both.hi)) throw new Error('routes disagree');
    const out = { available: true, R, zeta, direct, M, log: both, mid: mid(both), resolved: both.lo.n > 0n,
                  zetaResolved: R.resolved, relWidth: toNumber(sub(both.hi, both.lo)) / Math.max(toNumber(both.lo), 1e-300),
                  words: both.lo.n > 0n ? '' : 'excess unresolved at the available precision; only an upper bound is known' };
    remLogCache.set(key, out);
    return out;
  }

  const api = { logSeries, logEnclosure, logOfRational, cellLogEnclosure, remainderLog, logRatio, CUTOFFS, primesUpTo, fullFactor, truncFactor, primeStrip, remainder, primeCount, ZETA_TABLE, frac, add, sub, mul, canon, floorDiv, ceilDiv, decFloor, decCeil, parseDec, toNumber,
                factorialFactors, atomValue, divisorCount, divisorTuples, tupleValue, Z, subconeFactors,
                nodeWeight, zetaComparison, shellSeries };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else root.BaselCore = api;
})(typeof globalThis !== 'undefined' ? globalThis : this);
