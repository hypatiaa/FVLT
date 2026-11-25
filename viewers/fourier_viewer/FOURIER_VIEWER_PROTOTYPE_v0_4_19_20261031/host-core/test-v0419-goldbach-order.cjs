'use strict';
// v0.4.19 test-v0419-goldbach-order (SCHEMA_ADDENDUM_26, item 1): the Goldbach tooth order decided by saphir on 2026-10-31 ("both sides").
// Specification: the teeth of the shell's comb ordered by |c| ascending, and for each |c| > 0, +c before -c. Odd m: 0, 1, -1, 2, -2, ...;
// even m: no c = 0 tooth, so 1, -1, 3, -3, .... Every unordered prime pair {p, q}, p != q, is drawn twice (at +c and -c), the equal pair once: #+ = 2 g(N) - delta.
// The reference here is independent of goldbach-core.js and pen-streams-core.js: its own sieve, its own pair set, its own comb (the v0.4.14 convention B,
// transcribed: n = N/2; t2 = 2 if n is odd, else 1; a_p = n - p; m = a_max + 1, or 3 when a_max = 0; odd m: c = -(m-1)/2 ... (m-1)/2; even m: odd c,
// -(m-1) ... (m-1)), its own ordering (a sort by (|c|, sign), not the build's loop), and its own mask (+ iff n - |c| t2 and n + |c| t2 are both prime).
// Cases: N = 4, 6, 24, 100, 1448, then every even N from 4 to 1,448 and the full run to 1,448 (concatenation, boundaries, totals). Integers only.
const PS=require('./pen-streams-core.js');
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
const LIM=1448,comp=new Uint8Array(LIM+1);comp[0]=1;comp[1]=1;for(let i=2;i*i<=LIM;i++)if(!comp[i])for(let j=i*i;j<=LIM;j+=i)comp[j]=1;
const prime=k=>k>=2&&k<=LIM&&!comp[k];
function reference(N){
  const n=N>>1,pairs=[];for(let p=2;p<=n;p++)if(prime(p)&&prime(N-p))pairs.push(p);
  let amax=0;for(const p of pairs)if(n-p>amax)amax=n-p;
  const t2=n%2===1?2:1,m=amax===0?3:amax+1,teeth=[];
  if(m%2===1){const h=(m-1)>>1;for(let c=-h;c<=h;c++)teeth.push(c);}else{for(let c=-(m-1);c<=m-1;c+=2)teeth.push(c);}
  const abs=c=>c<0?-c:c;
  const order=teeth.slice().sort((x,y)=>abs(x)!==abs(y)?abs(x)-abs(y):(y-x));   // |c| ascending, then +c before -c
  const sign=c=>prime(n-abs(c)*t2)&&prime(n+abs(c)*t2)?1:-1;
  const g=pairs.length,delta=prime(n)?1:0;
  return {N,n,t2,m,c:order,s:order.map(sign),g,delta,plus:order.filter(c=>sign(c)>0).length};
}
const same=(a,b)=>a.length===b.length&&a.every((v,i)=>v===b[i]);
for(const N of [4,6,24,100,1448]){
  const r=reference(N),b=PS.goldbachShell(N),bs=Array.from(b.s);
  const head=r.c.slice(0,9).join(', ');
  ok('N = '+N+' (m = '+r.m+', '+(r.m%2?'odd':'even')+' m, t₂ = '+r.t2+'): tooth order = reference ('+head+(r.c.length>9?', …':'')+'), '+r.c.length+' teeth',same(b.c,r.c)&&b.len===r.m,b.c.slice(0,9).join(', '));
  ok('N = '+N+': signs = reference mask (+ iff N/2 ± |c|·t₂ both prime)',same(bs,r.s));
  ok('N = '+N+': #+ = '+r.plus+' = 2·g(N) − δ = 2·'+r.g+' − '+r.delta+' (pairs p ≠ N − p twice, the equal pair once)',b.plus===r.plus&&r.plus===2*r.g-r.delta&&b.g===r.g&&b.delta===r.delta);
  if(r.m%2===1)ok('N = '+N+': odd m starts 0, 1, −1, …',r.c[0]===0&&(r.m<3||(r.c[1]===1&&r.c[2]===-1)));
  else ok('N = '+N+': even m has no c = 0 tooth and starts 1, −1, 3, −3',!r.c.includes(0)&&same(r.c.slice(0,4),[1,-1,3,-3]));
  // every pair p != q appears at +c and -c with the same sign +; the equal pair (c = 0) once
  {let both=true;for(let i=0;i<r.c.length;i++){const c=r.c[i];if(c>0){const j=r.c.indexOf(-c);if(j!==i+1||r.s[j]!==r.s[i])both=false;}}ok('N = '+N+': each +c is followed by −c with the same sign (both sides)',both);}
}
// every shell 4 ... 1,448
{let bad=[],parity=[];for(let N=4;N<=LIM;N+=2){const r=reference(N),b=PS.goldbachShell(N);if(!same(b.c,r.c)||!same(Array.from(b.s),r.s)||b.plus!==2*r.g-r.delta)bad.push(N);
    if(N!==4&&(N%4===2)!==(r.m%2===1))parity.push(N);}
  ok('every even N = 4 … 1,448 (723 shells): order, signs and #+ = 2·g − δ equal the reference',bad.length===0,bad.slice(0,10).join(','));
  ok('odd m exactly for N ≡ 2 mod 4 (and N = 4, whose comb is m = 3); even m exactly for N ≡ 0 mod 4, N ≥ 8',parity.length===0&&reference(4).m===3,parity.slice(0,10).join(','));}
// the full run to 1,448: concatenation in shell order, boundaries at shell starts, totals
{const run=PS.goldbachRun(LIM),s=[],bounds=[];let g=0,d=0;for(let N=4;N<=LIM;N+=2){const r=reference(N);bounds.push(s.length);for(const v of r.s)s.push(v);g+=r.g;d+=r.delta;}
  const plus=s.filter(v=>v>0).length;
  ok('run to 1,448: '+run.shells+' shells, '+run.len+' signs, boundaries at the shell starts, every sign equal to the reference',run.shells===723&&run.len===s.length&&same(run.bounds,bounds)&&same(Array.from(run.s),s));
  ok('run to 1,448: #+ = '+plus+' = 2·Σg − Σδ = 2·'+g+' − '+d+' (expected 30,534 = 2·15,331 − 128)',run.plus===plus&&plus===2*g-d&&plus===30534&&g===15331&&d===128&&run.len===257430);}
console.log('SUMMARY test-v0419-goldbach-order: '+pass+' passed, '+fail+' failed');process.exitCode=fail?1:0;
