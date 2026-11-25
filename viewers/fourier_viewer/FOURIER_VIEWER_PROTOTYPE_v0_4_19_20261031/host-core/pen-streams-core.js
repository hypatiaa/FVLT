(function(root){
'use strict';
// fv-pen-streams-core 0_1_0 (v0.4.18, SCHEMA_ADDENDUM_25): the sign streams of the surface pens. EXACT register: bits, integers, signs in {+1, -1}.
// Conventions follow the skeleton seat's curvature_pen_v0_2_1.html (caSigns, coinSigns) exactly:
//   Rule 30 / Rule 150 from a single black cell; s_t = -1 when x_t(0) XOR x_t(1) = 1, else +1 (the squeezed-sphere readout of the centre pair);
//   Rule 30 = L XOR (C OR R), Rule 150 = L XOR C XOR R; rows are Uint8 bit rows of width 2T + 5 (the light cone never reaches the border);
//   the fair coin is xorshift32 with shifts 13, 17, 5 on unsigned 32-bit integers, s = +1 on an odd state; the seed is 1 ... 2^32 - 1.
// Goldbach (new in v0.4.18, saphir: "these new viewer will also integrate our goldbach work"): the prime-pair mask of host-core/goldbach-core.js
// (v0.4.14 track, SCHEMA_ADDENDUM_22 item 2), read unchanged. One sign per tooth of the shell N: +1 when the tooth is kept (N/2 +- c*t2 both prime,
// the equal pair at c = 0 included), -1 when it is ghosted. Tooth order: c = 0 first, then |c| = 1, 2, 3, ... with +c before -c (every tooth of the
// shell's comb appears once, so the stream length is the number of teeth m). The pen draws the prime-pair mask; it proves nothing about Goldbach.
const GB=typeof module!=='undefined'&&module.exports?require('./goldbach-core.js'):root.FVGoldbach;
const VERSION='fv-pen-streams-core 0_1_0';
const T_MAX=4096,SEED_MAX=4294967295n;
function checkT(T){if(typeof T!=='number'||T!==(T|0)||T<0||T>T_MAX)throw Error('T must be an integer 0 … '+T_MAX+' (got '+T+')');return T;}
// centre pair (q, r) = (x_t(0), x_t(1)) and the sign
function caRun(rule,T){
  checkT(T);if(rule!==30&&rule!==150)throw Error('rule must be 30 or 150');
  const W=2*T+5,mid=T+2;let a=new Uint8Array(W),b=new Uint8Array(W);a[mid]=1;
  const s=new Int8Array(T),q=new Uint8Array(T),r=new Uint8Array(T),tooth=new Uint8Array(T);
  for(let t=0;t<T;t++){
    q[t]=a[mid];r[t]=a[mid+1];s[t]=(a[mid]^a[mid+1])?-1:1;tooth[t]=a[mid]&a[mid+1];
    for(let i=1;i<W-1;i++){const L=a[i-1],C=a[i],R=a[i+1];b[i]=rule===150?(L^C^R):(L^(C|R));}
    b[0]=0;b[W-1]=0;const tmp=a;a=b;b=tmp;}
  return {s,q,r,tooth};
}
function parseSeed(seed){let b;try{b=BigInt(seed);}catch(e){throw Error('seed must be an integer 1 … '+SEED_MAX);}if(b<1n||b>SEED_MAX)throw Error('seed must be an integer 1 … '+SEED_MAX+' (got '+seed+')');return b;}
function coinSigns(T,seed){
  // the skeleton's x ^= x << 13; x >>>= 0; x ^= x >>> 17; x ^= x << 5; x >>>= 0, written on a BigInt kept in [0, 2^32) (same values, no Number conversion)
  checkT(T);let x=parseSeed(seed);const M=0xffffffffn,s=new Int8Array(T);
  for(let t=0;t<T;t++){x=(x^(x<<13n))&M;x=x^(x>>17n);x=(x^(x<<5n))&M;s[t]=(x&1n)?1:-1;}
  return s;
}
// the shell N: teeth in the order c = 0, 1, -1, 2, -2, ... (only those present in the comb)
function goldbachShell(N,opts){
  const md=GB.model(N,opts),byC=new Map(md.teeth.map(t=>[t.c,t]));
  let cmax=0;for(const t of md.teeth){const a=t.c<0?-t.c:t.c;if(a>cmax)cmax=a;}
  const order=[];if(byC.has(0))order.push(byC.get(0));for(let a=1;a<=cmax;a++){if(byC.has(a))order.push(byC.get(a));if(byC.has(-a))order.push(byC.get(-a));}
  const s=new Int8Array(order.length);let plus=0;order.forEach((t,i)=>{s[i]=t.kept?1:-1;if(t.kept)plus++;});
  const minus=order.length-plus,delta=md.delta,g=md.g;
  return {N,n:md.n,t2:md.t2,m:md.m,g,delta,s,c:order.map(t=>t.c),plus,minus,len:order.length,
    relation:{formula:'#+ = 2g(N) − δ',holds:plus===2*g-delta,text:'#+ = '+plus+' = 2·'+g+' − '+delta+' (each pair p ≠ N − p gives the two teeth ±c; the equal pair p = N/2'+(delta?' is prime and':' (not prime here)')+' gives the one tooth c = 0, counted once)'},
    netQuarterTurns:plus-minus,empty:g===0,emptyLabel:g===0?'g(N) = 0: empty prime-pair fibre (impossible for 4 ≤ N ≤ 1,448; guarded): every tooth is ghosted':''};
}
function checkNmax(N){if(typeof N!=='number'||N!==(N|0)||N%2!==0||N<GB.GB_MIN||N>GB.GB_MAX)throw Error('N must be even, '+GB.GB_MIN+' … '+GB.GB_MAX+' (got '+N+')');return N;}
const RUN_CACHE=new Map();
function goldbachRun(Nmax){
  checkNmax(Nmax);if(RUN_CACHE.has(Nmax))return RUN_CACHE.get(Nmax);
  const shells=[];let len=0;for(let N=GB.GB_MIN;N<=Nmax;N+=2){const sh=goldbachShell(N);shells.push(sh);len+=sh.len;}
  const s=new Int8Array(len),bounds=[];let i=0,plus=0,g=0,dsum=0;
  for(const sh of shells){bounds.push(i);s.set(sh.s,i);i+=sh.len;plus+=sh.plus;g+=sh.g;dsum+=sh.delta;}
  const out={Nmax,s,len,bounds,shells:shells.length,plus,minus:len-plus,gsum:g,deltasum:dsum,netQuarterTurns:2*plus-len,
    relation:{holds:plus===2*g-dsum,text:'#+ = '+plus+' = 2·Σg(N) − Σδ = 2·'+g+' − '+dsum}};
  RUN_CACHE.set(Nmax,out);return out;
}
// one entry point for the shared stream dial: kind in {'30', '150', 'coin', 'gbshell', 'gbrun'}
function stream(kind,o){
  if(kind==='30'||kind==='150'){const r=caRun(kind==='30'?30:150,o.T);return {kind,s:r.s,tooth:kind==='30'?r.tooth:null,q:r.q,r:r.r,len:o.T,bounds:[]};}
  if(kind==='coin')return {kind,s:coinSigns(o.T,o.seed),tooth:null,len:o.T,bounds:[]};
  if(kind==='gbshell'){const g=goldbachShell(checkNmax(o.N));return {kind,s:g.s,tooth:null,len:g.len,bounds:[0],gb:g};}
  if(kind==='gbrun'){const g=goldbachRun(o.Nmax);return {kind,s:g.s,tooth:null,len:g.len,bounds:g.bounds,gb:g};}
  throw Error('unknown stream '+kind);
}
const plusCount=s=>{let p=0;for(let i=0;i<s.length;i++)if(s[i]>0)p++;return p;};
const GUARDS={pen:'The pen draws the prime-pair mask; it proves nothing about Goldbach.',closure:GB.GUARDS.closure,
  bias:'Drawing-register observation only: prime pairs are rare among the teeth, so the stream is mostly −; the drawing shows long runs of right turns closing faces, broken by the prime pairs.'};
const api={VERSION,T_MAX,SEED_MAX,caRun,coinSigns,parseSeed,goldbachShell,goldbachRun,stream,plusCount,checkT,checkNmax,GUARDS};
if(typeof module!=='undefined'&&module.exports)module.exports=api;else root.FVPenStreams=api;
})(typeof globalThis!=='undefined'?globalThis:this);
