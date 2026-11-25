(function(root){
'use strict';
// fv-elliptic-period-core 0_1_0 (v0.4.17, SCHEMA_ADDENDUM_24): the real period lattice of an elliptic curve over Q with Delta > 0, in BigInt only.
// NUMERICAL REGISTER WITH GUARANTEES: every real quantity is a dyadic interval [lo, hi] * 2^-W (BigInt lo, hi; one working scale W per record),
// rounded outward at every step. No floating point anywhere (saphir: "No floating point").
//  1. the roots e1 > e2 > e3 of 4x^3 + b2 x^2 + 2 b4 x + b6: Sturm sequence over Q isolates them, exact sign bisection refines them;
//  2. interval square roots by BigInt isqrt (floor for lo, ceiling for hi);
//  3. the AGM in interval arithmetic; the true AGM M satisfies b_n <= M <= a_n for every n, so it is enclosed by [b_N.lo, a_N.hi];
//  4. pi by Machin's formula pi = 16 atan(1/5) - 4 atan(1/239), each term floored, with the term count and the first omitted term as the error bound;
//  5. w1 = pi / AGM(sqrt(e1 - e3), sqrt(e1 - e2)), w2/i = pi / AGM(sqrt(e1 - e3), sqrt(e2 - e3)), tau/i = w2/(i w1), Omega = 2 w1 (E(R) has two components).
// Delta < 0 (one real root) is refused with a visible label; Delta = 0 (singular) is refused.
const EX=typeof module!=='undefined'&&module.exports?require('./elliptic-exact-core.js'):root.FVEllipticExact;
const VERSION='fv-elliptic-period-core 0_1_0';
const MINUS='−';
const D_MIN=10n,D_MAX=100n,GUARD=48n,STOP_ULPS=16n,AGM_MAX=64;
const REFUSE_NEG='Δ < 0: not implemented in the exact register';
const REFUSE_ZERO='Δ = 0: singular curve, no period lattice';
const babs=a=>a<0n?-a:a;
// integer square roots
function isqrt(n){if(n<0n)throw Error('isqrt of a negative');if(n<2n)return n;let x=n,y=(x+1n)/2n;
  // start from a power of two above sqrt(n)
  x=1n<<(BigInt(n.toString(2).length)/2n+1n);
  for(;;){y=(x+n/x)/2n;if(y>=x)return x;x=y;}}
const isqrtCeil=n=>{const r=isqrt(n);return r*r===n?r:r+1n;};
const fdiv=(a,b)=>{if(b<0n){a=-a;b=-b;}const q=a/b;return (a%b!==0n&&a<0n)?q-1n:q;};   // floor division
const cdiv=(a,b)=>-fdiv(-a,b);                                                       // ceiling division
// ---------------------------------------------------------------- polynomials over Z (coefficients low to high), and Sturm over Q
function polyRemQ(a,b){   // remainder of a by b over Q, inputs integer arrays; output integer array (scaled by a positive constant, sign kept)
  a=a.slice();const db=b.length-1,lb=b[db];
  while(a.length-1>=db&&a.length>0){const da=a.length-1,la=a[da];if(la===0n){a.pop();continue;}
    // a <- lb*a - la*x^(da-db)*b  (positive scaling when lb > 0; fix the sign below)
    const s=lb<0n?-1n:1n;const na=a.map(c=>c*lb*s);for(let i=0;i<=db;i++)na[i+da-db]-=la*b[i]*s;na.pop();a=na;
    while(a.length&&a[a.length-1]===0n)a.pop();}
  const g=a.reduce((x,y)=>{x=babs(x);y=babs(y);while(y){[x,y]=[y,x%y];}return x;},0n)||1n;return a.map(c=>c/g);
}
function sturm(f){const d=f.slice(1).map((c,i)=>c*BigInt(i+1));const S=[f,d];while(S[S.length-1].length>1){const r=polyRemQ(S[S.length-2],S[S.length-1]);if(!r.length)break;S.push(r.map(c=>-c));}return S;}
// sign of an integer polynomial at the rational n/d (d > 0)
function signAt(f,n,d){let v=0n;const k=f.length-1;for(let i=k;i>=0;i--){v=v*n+f[i]*(d**BigInt(k-i));}   // Horner on the homogenised form: sum f_i n^i d^(k-i)
  return v>0n?1:v<0n?-1:0;}
function variations(S,n,d){let last=0,v=0;for(const p of S){const s=signAt(p,n,d);if(s===0)continue;if(last!==0&&s!==last)v++;last=s;}return v;}
function variationsInf(S,sgn){let last=0,v=0;for(const p of S){const lc=p[p.length-1],deg=p.length-1;let s=lc>0n?1:-1;if(sgn<0&&deg%2===1)s=-s;if(last!==0&&s!==last)v++;last=s;}return v;}
// ---------------------------------------------------------------- dyadic intervals at scale W
const iv=(lo,hi)=>{if(lo>hi)throw Error('empty interval');return {lo,hi};};
const ivAdd=(a,b)=>iv(a.lo+b.lo,a.hi+b.hi),ivSub=(a,b)=>iv(a.lo-b.hi,a.hi-b.lo);
const ivSqrt=(a,W)=>{if(a.lo<0n)throw Error('interval square root of a possibly negative quantity');return iv(isqrt(a.lo<<W),isqrtCeil(a.hi<<W));};
const ivDivPos=(a,b,W)=>{if(b.lo<=0n||a.lo<0n)throw Error('ivDivPos needs a >= 0 and b > 0');return iv(fdiv(a.lo<<W,b.hi),cdiv(a.hi<<W,b.lo));};
// ---------------------------------------------------------------- pi by Machin
function atanInv(x,W){   // atan(1/x) * 2^W enclosed; terms floor(2^W / ((2k+1) x^(2k+1))) with alternating signs
  let s=0n,k=0n,pw=x,terms=0n;const x2=x*x,S=1n<<W;
  for(;;){const t=S/((2n*k+1n)*pw);if(t===0n)break;s+=(k%2n===0n)?t:-t;terms++;k++;pw*=x2;}
  // each floored term errs by < 1 unit; the omitted tail is below the first omitted term (< 1 unit): |error| < terms + 1
  return {iv:iv(s-terms-1n,s+terms+1n),terms};
}
function piInterval(W){const a=atanInv(5n,W),b=atanInv(239n,W);
  return {iv:iv(16n*a.iv.lo-4n*b.iv.hi,16n*a.iv.hi-4n*b.iv.lo),terms:[a.terms,b.terms],method:'Machin: π = 16 atan(1/5) − 4 atan(1/239); each term floored at 2^−W, error per series < (terms + 1)·2^−W (alternating, decreasing: the tail is below the first omitted term)'};}
// ---------------------------------------------------------------- decimal output from exact values
const P10=n=>10n**BigInt(n);   // n is a BigInt (or a small integer literal)
function roundTo(n,W,d){return fdiv(n*P10(d)*2n+(1n<<W),1n<<(W+1n));}   // round half up of n/2^W to d places, as an integer count of 10^-d
function fmt(m,d){const neg=m<0n,a=babs(m),q=P10(d),ip=a/q,fp=(a%q+q).toString().slice(1);return (neg?MINUS:'')+ip+(d>0n?'.'+fp:'');}
function digits(I,W,D){D=BigInt(D);for(let d=D;d>=0n;d--){const a=roundTo(I.lo,W,d),b=roundTo(I.hi,W,d);if(a===b)return {text:fmt(a,d),places:d,requested:D};}return {text:'(no guaranteed digit)',places:-1n,requested:D};}
function widthInfo(I,W){const w=I.hi-I.lo,S=1n<<W;let k=0n;while(k<400n&&w*P10(k+1n)<=S)k++;return {ulps:w,W,pow10:k,text:'width = '+w+'·2^−'+W+' ≤ 10^−'+k};}
function ivText(I,W,D){const g=digits(I,W,D),w=widthInfo(I,W);return {digits:g.text,places:String(g.places),width:w.text,width_pow10:String(w.pow10),width_ulps:String(w.ulps),lo:String(I.lo),hi:String(I.hi),W:String(W)};}
// ---------------------------------------------------------------- the record
const CACHE=new Map();
function workingBits(D){return (BigInt(D)*33220n+9999n)/10000n+GUARD;}   // 33220/10000 > log2(10), so 2^-W0 <= 10^-D, plus guard bits
function checkD(D){let b;try{b=BigInt(D);}catch(e){throw Error('D must be an integer (got '+D+')');}if(b<D_MIN||b>D_MAX)throw Error('D must be an integer '+D_MIN+' … '+D_MAX+' (got '+D+')');return b;}   // BigInt(non-integer) throws: no float test needed
function rootsOf(f,W){
  // integer bound R with every root in (-R, R): Cauchy, 1 + max |f_i / f_n|
  const n=f.length-1,lc=babs(f[n]);let R=1n;for(let i=0;i<n;i++){const c=cdiv(babs(f[i]),lc)+1n;if(c>R)R=c;}
  const S=sturm(f);const count=(a,b)=>variations(S,a.n,a.d)-variations(S,b.n,b.d);   // roots in (a, b], a and b rationals {n, d}
  const total=variationsInf(S,-1)-variationsInf(S,1);
  // isolate by bisection on dyadic rationals
  const iso=[],stack=[[{n:-R,d:1n},{n:R,d:1n}]];let guard=0;
  while(stack.length){const [a,b]=stack.pop();const c=count(a,b);if(c===0)continue;if(++guard>100000)throw Error('isolation did not terminate');
    if(c===1&&signAt(f,a.n,a.d)!==0){iso.push([a,b]);continue;}   /* a root at the open end a belongs to the neighbour: split further */const L=a.d>b.d?a.d:b.d,m={n:(a.n*(L/a.d)+b.n*(L/b.d)),d:2n*L};stack.push([a,m],[m,b]);}
  // refine each at scale W: integer endpoints lo, hi with f changing sign on [lo, hi]
  const S2=1n<<W,out=[];
  for(const [a,b] of iso){
    if(signAt(f,b.n,b.d)===0&&(S2%b.d===0n)){const x=b.n*(S2/b.d);out.push({iv:iv(x,x),exact:true});continue;}
    let lo=fdiv(a.n*S2,a.d),hi=cdiv(b.n*S2,b.d);const sl=signAt(f,lo,S2),sh=signAt(f,hi,S2);
    if(sl===0){out.push({iv:iv(lo,lo),exact:true});continue;}if(sh===0){out.push({iv:iv(hi,hi),exact:true});continue;}
    if(sl===sh)throw Error('no sign change on an isolating interval (multiple root?)');
    let steps=0;while(hi-lo>1n){const m=(lo+hi)/2n,s=signAt(f,m,S2);steps++;if(s===0){lo=m;hi=m;break;}if(s===sl)lo=m;else hi=m;}
    out.push({iv:iv(lo,hi),exact:lo===hi,steps});}
  out.sort((x,y)=>x.iv.lo>y.iv.lo?-1:x.iv.lo<y.iv.lo?1:0);   // e1 > e2 > e3
  return {roots:out,total,bound:R,sturm_length:S.length};
}
function agm(a0,b0,W){
  let a=a0,b=b0;const steps=[{n:0,a,b}];
  for(let n=1;n<=AGM_MAX;n++){if(a.hi-b.lo<=STOP_ULPS)break;
    const a1=iv(fdiv(a.lo+b.lo,2n),cdiv(a.hi+b.hi,2n)),b1=iv(isqrt(a.lo*b.lo),isqrtCeil(a.hi*b.hi));a=a1;b=b1;steps.push({n,a,b});}
  if(a.hi-b.lo>STOP_ULPS)throw Error('AGM did not reach the stop bound in '+AGM_MAX+' steps');
  return {M:iv(b.lo,a.hi),steps,stop:steps.length-1,bound:'stopped at n = '+(steps.length-1)+' when a_n.hi − b_n.lo ≤ '+STOP_ULPS+'·2^−W; the true AGM M satisfies b_n ≤ M ≤ a_n for every n (b_n increasing, a_n decreasing), so M ∈ [b_n.lo, a_n.hi]'};
}
function periods(ainvs,D){
  D=checkD(D);const key=ainvs.map(String).join(',')+'|'+D;if(CACHE.has(key))return CACHE.get(key);
  const C=EX.curveQ(ainvs),W=workingBits(D),sign=C.disc.num>0n?1:C.disc.num<0n?-1:0;
  const base={version:VERSION,ainvs:ainvs.map(String),D:String(D),W:String(W),disc:EX.qascii(C.disc),disc_sign:sign};
  if(sign<=0){const r={...base,refused:true,label:sign<0?REFUSE_NEG:REFUSE_ZERO};CACHE.set(key,r);return r;}
  // f(x) = 4x^3 + b2 x^2 + 2 b4 x + b6, cleared of denominators
  const co=[C.b6,EX.qmul(EX.Q(2n),C.b4),C.b2,EX.Q(4n)],L=co.reduce((l,c)=>{const g=EX.bgcd(l,c.den);return l/g*c.den;},1n),f=co.map(c=>c.num*(L/c.den));
  const R=rootsOf(f,W);if(R.roots.length!==3||R.total!==3)throw Error('expected three real roots for Δ > 0 (got '+R.roots.length+')');
  const [e1,e2,e3]=R.roots.map(x=>x.iv);
  if(!(e1.lo>e2.hi&&e2.lo>e3.hi))throw Error('root intervals overlap');
  const d13=ivSub(e1,e3),d12=ivSub(e1,e2),d23=ivSub(e2,e3);
  const s13=ivSqrt(d13,W),s12=ivSqrt(d12,W),s23=ivSqrt(d23,W);
  const A1=agm(s13,s12,W),A2=agm(s13,s23,W),PI=piInterval(W);
  const w1=ivDivPos(PI.iv,A1.M,W),w2=ivDivPos(PI.iv,A2.M,W),tau=ivDivPos(A1.M,A2.M,W),Om=iv(2n*w1.lo,2n*w1.hi);
  const T=I=>ivText(I,W,D);
  const r={...base,refused:false,poly:f.map(String),root_bound:String(R.bound),sturm_length:R.sturm_length,
    e1:T(e1),e2:T(e2),e3:T(e3),sqrt13:T(s13),sqrt12:T(s12),sqrt23:T(s23),pi:{...T(PI.iv),method:PI.method,terms:PI.terms.map(String)},
    agm1:{M:T(A1.M),stop:A1.stop,bound:A1.bound,steps:A1.steps.map(s=>({n:s.n,a:T(s.a),b:T(s.b)}))},
    agm2:{M:T(A2.M),stop:A2.stop,bound:A2.bound,steps:A2.steps.map(s=>({n:s.n,a:T(s.a),b:T(s.b)}))},
    w1:T(w1),w2_over_i:T(w2),tau_over_i:T(tau),Omega:T(Om),
    components:2,omega_reason:'Δ > 0: the cubic has three real roots, so E(ℝ) has two components (the identity component and the egg); the real period Ω = 2ω₁ counts both',
    lattice:'rectangular: Λ = ℤω₁ + ℤω₂ with ω₁ real and ω₂ purely imaginary (Δ > 0)',
    raw:{e:[e1,e2,e3],w1,w2,tau,Omega:Om,pi:PI.iv,M1:A1.M,M2:A2.M,agm1:A1.steps,agm2:A2.steps}};
  CACHE.set(key,r);return r;
}
// exact comparison of an interval with a decimal reference string allowing +-10^-tolPow: true iff [lo, hi] meets [ref - tol, ref + tol]
function meetsDecimal(I,W,ref,tolPow){
  const m=/^(-?)([0-9]+)\.([0-9]+)$/.exec(String(ref).replace(MINUS,'-'));if(!m)throw Error('bad reference '+ref);
  const Lp=BigInt(m[3].length),R=BigInt(m[1]+m[2]+m[3]),tp=BigInt(tolPow),Lc=Lp>tp?Lp:tp;
  // compare lo/2^W <= R/10^Lp + 10^-tol and hi/2^W >= R/10^Lp - 10^-tol, all scaled by 10^Lc 2^W
  const S=1n<<W,ref10=R*P10(Lc-Lp),tol10=P10(Lc-tp);
  return I.lo*P10(Lc)<=(ref10+tol10)*S&&I.hi*P10(Lc)>=(ref10-tol10)*S;
}
const api={VERSION,D_MIN,D_MAX,GUARD,STOP_ULPS,REFUSE_NEG,REFUSE_ZERO,periods,isqrt,isqrtCeil,fdiv,cdiv,sturm,signAt,rootsOf,agm,piInterval,atanInv,digits,widthInfo,roundTo,fmt,workingBits,meetsDecimal,CACHE};
if(typeof module!=='undefined'&&module.exports)module.exports=api;
root.FVEllipticPeriod=api;
})(typeof globalThis!=='undefined'?globalThis:this);
