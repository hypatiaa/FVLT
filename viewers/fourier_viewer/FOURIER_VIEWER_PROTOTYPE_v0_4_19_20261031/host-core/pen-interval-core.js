(function(root){
'use strict';
// fv-pen-interval-core 0_1_0 (v0.4.18, SCHEMA_ADDENDUM_25): guaranteed numerical register for the surface pens. BigInt only (saphir: "No floating point").
// A real number is an interval {lo, hi} of integers at a scale 2^-W fixed by the caller: the true value v satisfies lo*2^-W <= v <= hi*2^-W.
// Every operation rounds outward: lower ends are floored, upper ends are ceiled. Nothing here uses a JS Number for arithmetic of the mathematics.
const VERSION='fv-pen-interval-core 0_1_0';
const iv=(lo,hi)=>{if(lo>hi)throw Error('empty interval');return {lo,hi};};
const pt=x=>({lo:x,hi:x});
const fdiv=(a,b)=>{if(b<0n){a=-a;b=-b;}const q=a/b;return (a%b!==0n&&a<0n)?q-1n:q;};
const cdiv=(a,b)=>-fdiv(-a,b);
const shrF=(a,k)=>a>>k;                     // floor(a / 2^k) (BigInt >> is an arithmetic, flooring shift)
const shrC=(a,k)=>-((-a)>>k);               // ceil(a / 2^k)
const babs=a=>a<0n?-a:a;
const bmin=(...x)=>x.reduce((p,q)=>q<p?q:p),bmax=(...x)=>x.reduce((p,q)=>q>p?q:p);
const blen=a=>{a=babs(a);return a===0n?0n:BigInt(a.toString(2).length);};
function isqrt(n){if(n<0n)throw Error('isqrt of a negative');if(n<2n)return n;let x=1n<<(blen(n)/2n+1n),y;for(;;){y=(x+n/x)/2n;if(y>=x)return x;x=y;}}
const isqrtCeil=n=>{const r=isqrt(n);return r*r===n?r:r+1n;};
// ---------------------------------------------------------------- arithmetic at scale W
const add=(a,b)=>iv(a.lo+b.lo,a.hi+b.hi);
const sub=(a,b)=>iv(a.lo-b.hi,a.hi-b.lo);
const neg=a=>iv(-a.hi,-a.lo);
function mul(a,b,W){const p=[a.lo*b.lo,a.lo*b.hi,a.hi*b.lo,a.hi*b.hi];return iv(shrF(bmin(...p),W),shrC(bmax(...p),W));}
function mulInt(a,k){return k>=0n?iv(a.lo*k,a.hi*k):iv(a.hi*k,a.lo*k);}
function sqr(a,W){if(a.lo>=0n)return iv(shrF(a.lo*a.lo,W),shrC(a.hi*a.hi,W));if(a.hi<=0n)return iv(shrF(a.hi*a.hi,W),shrC(a.lo*a.lo,W));return iv(0n,shrC(bmax(a.lo*a.lo,a.hi*a.hi),W));}
function div(a,b,W){if(b.lo<=0n&&b.hi>=0n)throw Error('interval division by an interval containing 0');
  const S=1n<<W,p=[[a.lo,b.lo],[a.lo,b.hi],[a.hi,b.lo],[a.hi,b.hi]];return iv(bmin(...p.map(([x,y])=>fdiv(x*S,y))),bmax(...p.map(([x,y])=>cdiv(x*S,y))));}
function sqrt(a,W){const lo=a.lo<0n?0n:a.lo;if(a.hi<0n)throw Error('square root of a negative interval');return iv(isqrt(lo<<W),isqrtCeil(a.hi<<W));}
const fromRat=(n,d,W)=>iv(fdiv(n<<W,d),cdiv(n<<W,d));
const rescale=(a,W,W2)=>W2>=W?iv(a.lo<<(W2-W),a.hi<<(W2-W)):iv(shrF(a.lo,W-W2),shrC(a.hi,W-W2));
const hull=(a,b)=>iv(bmin(a.lo,b.lo),bmax(a.hi,b.hi));
const sign=a=>a.lo>0n?1:a.hi<0n?-1:(a.lo===0n&&a.hi===0n)?0:null;   // null: undecided (the interval straddles 0)
const width=a=>a.hi-a.lo;
// ---------------------------------------------------------------- pi (Machin) and trigonometric functions of rational turns
const GUARD=40n;
function atanInv(x,W){let s=0n,k=0n,pw=x,terms=0n;const x2=x*x,S=1n<<W;
  for(;;){const t=S/((2n*k+1n)*pw);if(t===0n)break;s+=(k%2n===0n)?t:-t;terms++;k++;pw*=x2;}
  return iv(s-terms-1n,s+terms+1n);}   // each floored term errs by < 1 unit; the alternating tail is below the first omitted term (< 1 unit)
const PI_CACHE=new Map();
function pi(W){if(PI_CACHE.has(W))return PI_CACHE.get(W);const a=atanInv(5n,W),b=atanInv(239n,W),r=iv(16n*a.lo-4n*b.hi,16n*a.hi-4n*b.lo);PI_CACHE.set(W,r);return r;}
// cos and sin of x0 * 2^-W for an exact dyadic 0 <= x0*2^-W < pi/2, by the Taylor series with truncated terms.
// Error bound (in units of 2^-W): every computed term errs by at most 3k + 3 units (truncation of the division and of x^2); summed over n terms this is
// below 4(n + 2)^2; the omitted tail of the alternating series is below the first omitted term (the terms decrease from k = 2 on, x^2 < 247/100 < 12),
// and that term is below 1 + its own error. The bound used is 4(n + 2)^2 + 8(n + 2) units.
function cosSinSeries(x0,W){
  const S=1n<<W,x2=(x0*x0)>>W;let c=S,s=x0,tc=S,ts=x0,k=0n,n=1n;
  for(;;){tc=-(tc*x2/S)/((k+1n)*(k+2n));ts=-(ts*x2/S)/((k+2n)*(k+3n));n++;if(tc===0n&&ts===0n)break;c+=tc;s+=ts;k+=2n;}
  const e=4n*(n+2n)*(n+2n)+8n*(n+2n);return {c:iv(c-e,c+e),s:iv(s-e,s+e),terms:n};
}
const TRIG_CACHE=new Map();
// cos and sin of 2*pi*p/q (q > 0), enclosed at scale W. Quadrant reduction is exact; r = 0 gives exact point values.
function cosSinTurn(p,q,W){
  p=BigInt(p);q=BigInt(q);if(q<=0n)throw Error('q must be positive');
  const key=p+'/'+q+'@'+W;if(TRIG_CACHE.has(key))return TRIG_CACHE.get(key);
  const pm=((p%q)+q)%q,n4=4n*pm,k=n4/q,r=n4-k*q,Wg=W+GUARD,S=1n<<Wg;
  let c,s;
  if(r===0n){c=pt(S);s=pt(0n);}
  else{const P=pi(Wg),phi=iv(fdiv(P.lo*r,2n*q),cdiv(P.hi*r,2n*q)),cs=cosSinSeries(phi.lo,Wg),w=phi.hi-phi.lo;   // cos, sin are 1-Lipschitz: widen by the width of phi
    c=iv(cs.c.lo-w,cs.c.hi+w);s=iv(cs.s.lo-w,cs.s.hi+w);}
  const clamp=a=>iv(bmax(a.lo,-S),bmin(a.hi,S));c=clamp(c);s=clamp(s);
  let C,Sn;switch(k%4n){case 0n:C=c;Sn=s;break;case 1n:C=neg(s);Sn=c;break;case 2n:C=neg(c);Sn=neg(s);break;default:C=s;Sn=neg(c);}
  const out={c:rescale(C,Wg,W),s:rescale(Sn,Wg,W)};TRIG_CACHE.set(key,out);return out;
}
// ---------------------------------------------------------------- logarithm
// atanh(u) = u + u^3/3 + u^5/5 + ... for 0 <= u <= 1/3, as a lower bound (floored terms, tail dropped) or an upper bound (ceiled terms, tail <= 2 * last term).
function atanhBound(un,ud,W,up){
  // term = u^k * 2^W (floored for the lower bound, ceiled for the upper); every rounding moves the bound the right way (all terms are positive).
  const S=1n<<W;let term=up?cdiv(un*S,ud):fdiv(un*S,ud);const u2n=un*un,u2d=ud*ud;let sum=0n,k=1n;
  if(!up){for(;;){const t=term/k;if(t===0n)break;sum+=t;term=term*u2n/u2d;k+=2n;}return sum;}
  for(;;){if(term<=1n)return sum+2n;sum+=cdiv(term,k);term=cdiv(term*u2n,u2d);k+=2n;}   // once the (upper) term is <= 1 unit, the rest of the series is <= 9/8 of it (ratio u^2 <= 1/9): add 2 units
}
const LN2=new Map();
function ln2(W){if(LN2.has(W))return LN2.get(W);const r=iv(2n*atanhBound(1n,3n,W,false),2n*atanhBound(1n,3n,W,true));LN2.set(W,r);return r;}
// log of the positive dyadic n * 2^-W, enclosed at scale W: n = m * 2^(L-1), m in [1, 2), log = (L - 1 - W) ln 2 + 2 atanh((m - 1)/(m + 1)).
function logPoint(n,W,up){
  if(n<=0n)throw Error('log of a non-positive number');
  const L=blen(n),e=L-1n-W,Wg=W+GUARD,M=n,Md=1n<<(L-1n);   // m = M / Md exactly
  const l2=ln2(Wg),base=e>=0n?(up?e*l2.hi:e*l2.lo):(up?e*l2.lo:e*l2.hi);
  const a=2n*atanhBound(M-Md,M+Md,Wg,up);
  return up?shrC(base+a,GUARD):shrF(base+a,GUARD);
}
function log(a,W){if(a.lo<=0n)throw Error('log of an interval that is not positive');return iv(logPoint(a.lo,W,false),logPoint(a.hi,W,true));}
// ---------------------------------------------------------------- decimal output
const P10=n=>10n**BigInt(n);
function roundTo(n,W,d){return fdiv(n*P10(d)*2n+(1n<<W),1n<<(W+1n));}
function fmt(m,d,MINUS){const neg=m<0n,a=babs(m),q=P10(d),ip=a/q,fp=(a%q+q).toString().slice(1);return (neg?MINUS:'')+ip+(d>0n?'.'+fp:'');}
// the places on which round-half-up of lo and of hi agree (at most D)
function digits(I,W,D){D=BigInt(D);for(let d=D;d>=0n;d--){const a=roundTo(I.lo,W,d),b=roundTo(I.hi,W,d);if(a===b)return {text:fmt(a,d,'−'),places:d};}return {text:'(no guaranteed digit)',places:-1n};}
// scientific form for a positive interval: m.mmm × 10^k with the significant digits on which both ends agree (at most D)
function sci(I,W,D){
  if(I.lo<=0n)return digits(I,W,D);
  const ip=I.lo>>W,k=ip>0n?BigInt(ip.toString().length)-1n:0n;
  if(k<6n)return digits(I,W,D);
  const sc=P10(k);const J=iv(fdiv(I.lo,sc),cdiv(I.hi,sc));const g=digits(J,W,D);return {text:g.text+' × 10^'+k,places:g.places,exp:k};
}
// ---------------------------------------------------------------- complex intervals and pixels
const cx=(re,im)=>({re,im});
const cAdd=(a,b)=>cx(add(a.re,b.re),add(a.im,b.im)),cSub=(a,b)=>cx(sub(a.re,b.re),sub(a.im,b.im));
const cMul=(a,b,W)=>cx(sub(mul(a.re,b.re,W),mul(a.im,b.im,W)),add(mul(a.re,b.im,W),mul(a.im,b.re,W)));
const cConj=a=>cx(a.re,neg(a.im)),cNeg=a=>cx(neg(a.re),neg(a.im));
const cAbs2=(a,W)=>add(sqr(a.re,W),sqr(a.im,W));
function cDiv(a,b,W){const d=cAbs2(b,W),n=cMul(a,cConj(b),W);return cx(div(n.re,d,W),div(n.im,d,W));}
// a pixel from an enclosure: value * R (R a BigInt number of pixels); returns the pixel (floor of the midpoint) and whether the enclosure is <= 1/4 pixel wide.
function pixel(a,W,R,off,flip){const lo=a.lo*R,hi=a.hi*R,ok=4n*(hi-lo)<=(1n<<W),mid=fdiv(lo+hi,1n<<(W+1n));return {p:flip?off-mid:off+mid,ok};}
// v0.4.19 (SCHEMA_ADDENDUM_26, verify finding 5): the same pixel, with the two certificates kept apart.
//   wide: the enclosure is wider than 1/4 pixel (the v0.4.18 "not certified" count; ok = !wide);
//   undecided: the enclosure of the drawn coordinate straddles an integer pixel edge, so floor(lo) != floor(hi) for the coordinate off + v*R (or off - v*R
//   when flipped): the true integer pixel is then not decided by the enclosure, and the drawn pixel (floor of the midpoint) may differ from it by one.
//   A true value can sit exactly on an edge, so undecided points need not vanish at any precision.
function pixelCert(a,W,R,off,flip){const r=pixel(a,W,R,off,flip),S=1n<<W,lo=a.lo*R,hi=a.hi*R;
  const f0=flip?shrF(off*S-hi,W):shrF(off*S+lo,W),f1=flip?shrF(off*S-lo,W):shrF(off*S+hi,W);
  return {p:r.p,ok:r.ok,wide:!r.ok,undecided:f0!==f1};}
const api={VERSION,iv,pt,add,sub,neg,mul,mulInt,sqr,div,sqrt,fromRat,rescale,hull,sign,width,fdiv,cdiv,shrF,shrC,isqrt,isqrtCeil,blen,babs,bmin,bmax,
  pi,cosSinTurn,cosSinSeries,ln2,log,logPoint,atanhBound,digits,sci,fmt,cx,cAdd,cSub,cMul,cConj,cNeg,cAbs2,cDiv,pixel,pixelCert,GUARD};
if(typeof module!=='undefined'&&module.exports)module.exports=api;else root.FVPenIv=api;
})(typeof globalThis!=='undefined'?globalThis:this);
