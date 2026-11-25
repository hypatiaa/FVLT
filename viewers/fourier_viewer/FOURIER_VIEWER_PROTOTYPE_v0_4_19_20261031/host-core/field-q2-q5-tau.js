(function(root){
'use strict';
// fv-field-q2-q5-tau 0_1_0 (v0.4.18, SCHEMA_ADDENDUM_25): exact number fields for the surface pens. EXACT register: BigInt rationals only.
// A tower field Q(g_0, ..., g_{k-1}) with g_i^2 = r_i, r_i an integral element of Q(g_0, ..., g_{i-1}). Basis: the 2^k monomials, bit i of the index = g_i.
// F = Q(sqrt2, sqrt5, tau), tau^2 = sqrt5 - 1 (degree 8): sinh(l/2) = tau/2 for the {5,4} edge l (cosh(l/2) = (sqrt2 + sqrt10)/4 = cos 36 deg / sin 45 deg).
//   Correction recorded in the brief: Q(sqrt2, sqrt5) alone does not suffice, since sinh^2(l/2) = cos 72 deg = (sqrt5 - 1)/4.
// K = Q(sqrt3, sqrt5) (degree 4): the dodecahedron preset of the sphere pen (cos 60 = 1/2, sin 60 = sqrt3/2, cos a = sqrt5/3, sin a = 2/3).
// An element is {n: BigInt[2^k], d: BigInt > 0} meaning (sum n_j e_j)/d, kept reduced (gcd of all n_j and d is 1). Multiplication: the tower rule
// (u1 + v1 g)(u2 + v2 g) = (u1 u2 + v1 v2 r) + (u1 v2 + v1 u2) g, recursively; the reduction table it implies is checked by the tests.
// Inverses: (u + v g)^-1 = (u - v g) / (u^2 - v^2 r), recursively down the tower.
const IV=typeof module!=='undefined'&&module.exports?require('./pen-interval-core.js'):root.FVPenIv;
const VERSION='fv-field-q2-q5-tau 0_1_0';
const babs=a=>a<0n?-a:a;
const gcd=(a,b)=>{a=babs(a);b=babs(b);while(b){[a,b]=[b,a%b];}return a;};
function makeTower(name,gens){
  // gens: [{name, sq: BigInt[] over the basis of the lower field (length 2^i)}]
  const k=gens.length,DIM=1<<k;
  const zeros=n=>{const o=[];for(let i=0;i<n;i++)o.push(0n);return o;};
  // integer-vector multiplication in the field with j generators (length 2^j)
  function mulV(a,b,j){
    if(j===0)return [a[0]*b[0]];
    const h=1<<(j-1),u1=a.slice(0,h),v1=a.slice(h),u2=b.slice(0,h),v2=b.slice(h),r=gens[j-1].sq;
    const uu=mulV(u1,u2,j-1),vv=mulV(v1,v2,j-1),vvr=mulV(vv,r,j-1),uv=mulV(u1,v2,j-1),vu=mulV(v1,u2,j-1);
    const lo=uu.map((x,i)=>x+vvr[i]),hi=uv.map((x,i)=>x+vu[i]);return lo.concat(hi);
  }
  const norm=x=>{let g=x.d;for(const c of x.n)g=gcd(g,c);if(g===0n)g=1n;if(g!==1n)return {n:x.n.map(c=>c/g),d:x.d/g};return x;};
  const make=(n,d)=>{if(d===undefined)d=1n;if(d<0n){n=n.map(c=>-c);d=-d;}if(d===0n)throw Error('zero denominator');while(n.length<DIM)n=n.concat([0n]);return norm({n,d});};
  const fromInt=(a,d)=>{const n=zeros(DIM);n[0]=BigInt(a);return make(n,d===undefined?1n:BigInt(d));};
  const ZERO=fromInt(0n),ONE=fromInt(1n);
  const gen=i=>{const n=zeros(DIM);n[1<<i]=1n;return make(n,1n);};
  const add=(x,y)=>make(x.n.map((c,i)=>c*y.d+y.n[i]*x.d),x.d*y.d);
  const neg=x=>({n:x.n.map(c=>-c),d:x.d});
  const sub=(x,y)=>add(x,neg(y));
  const mul=(x,y)=>make(mulV(x.n,y.n,k),x.d*y.d);
  const scale=(x,p,q)=>make(x.n.map(c=>c*BigInt(p)),x.d*BigInt(q===undefined?1n:q));
  const isZero=x=>x.n.every(c=>c===0n);
  const eq=(x,y)=>x.d===y.d&&x.n.every((c,i)=>c===y.n[i]);
  // inverse by the tower conjugation, on integer vectors with a rational denominator: returns {n, d}
  function invV(a,j){   // a: integer vector of length 2^j, nonzero; returns [vector b, integer D] with a*b = D (D != 0 integer)
    if(j===0){if(a[0]===0n)throw Error('inverse of zero');return [[1n],a[0]];}
    const h=1<<(j-1),u=a.slice(0,h),v=a.slice(h),r=gens[j-1].sq;
    const conj=u.concat(v.map(c=>-c));                      // u - v g
    const nrm=mulV(u,u,j-1).map((x,i)=>x-mulV(mulV(v,v,j-1),r,j-1)[i]);   // u^2 - v^2 r, in the lower field
    const [ib,D]=invV(nrm,j-1);                             // nrm * ib = D
    const pad=ib.concat(zeros(h));                         // ib as an element of the field with j generators
    return [mulV(conj,pad,j),D];                            // a * (conj * ib) = nrm * ib = D
  }
  const inv=x=>{if(isZero(x))throw Error('inverse of zero');const [b,D]=invV(x.n,k);return make(b.map(c=>c*x.d),D);};
  const divE=(x,y)=>mul(x,inv(y));
  const key=x=>x.n.join(',')+'/'+x.d;
  const str=x=>{const parts=[];x.n.forEach((c,i)=>{if(c===0n)return;const mono=gens.filter((g,b)=>i&(1<<b)).map(g=>g.name).join('·');parts.push((c<0n?'− ':parts.length?'+ ':'')+(babs(c)===1n&&mono?'':String(babs(c)))+mono);});return (parts.length?parts.join(' '):'0')+(x.d!==1n?' (/'+x.d+')':'');};
  // interval enclosure at scale W: basis values by interval square roots down the tower
  const BASIS=new Map();
  function basisIv(W){
    if(BASIS.has(W))return BASIS.get(W);
    const Wg=W+IV.GUARD,S=1n<<Wg,b=[IV.pt(S)];
    for(let i=0;i<k;i++){const r=gens[i].sq;let rv=IV.pt(0n);r.forEach((c,j)=>{if(c!==0n)rv=IV.add(rv,IV.mulInt(b[j],c));});
      const g=IV.sqrt(rv,Wg);const h=1<<i;for(let j=0;j<h;j++)b[h+j]=IV.mul(b[j],g,Wg);}
    const out={Wg,b};BASIS.set(W,out);return out;
  }
  function toIv(x,W){const B=basisIv(W);let s=IV.pt(0n);x.n.forEach((c,j)=>{if(c!==0n)s=IV.add(s,IV.mulInt(B.b[j],c));});
    return IV.iv(IV.fdiv(IV.shrF(s.lo,IV.GUARD),x.d),IV.cdiv(IV.shrC(s.hi,IV.GUARD),x.d));}
  // exact sign of a real element (the field is real: every generator is the positive root): decided from enclosures of increasing precision
  function signOf(x){if(isZero(x))return 0;for(let W=64n;W<=8192n;W*=2n){const s=IV.sign(toIv(x,W));if(s!==null&&s!==0)return s;}throw Error('sign not decided');}
  // the reduction table e_i e_j = sum_k T[i][j][k] e_k (integers), from mulV on basis vectors; mulT multiplies integer vectors through it, skipping zeros
  const TBL=[];for(let i=0;i<DIM;i++)for(let j=0;j<DIM;j++){const a=zeros(DIM),b=zeros(DIM);a[i]=1n;b[j]=1n;TBL.push(mulV(a,b,k).map((c,kk)=>[kk,c]).filter(e=>e[1]!==0n));}
  function mulT(x,y){const o=zeros(DIM);for(let i=0;i<DIM;i++){const xi=x[i];if(xi===0n)continue;for(let j=0;j<DIM;j++){const yj=y[j];if(yj===0n)continue;const p=xi*yj;for(const [kk,c] of TBL[i*DIM+j])o[kk]+=c===1n?p:p*c;}}return o;}
  return {name,k,DIM,gens,TBL,mulT,make,fromInt,ZERO,ONE,gen,add,sub,neg,mul,scale,inv,div:divE,isZero,eq,key,str,toIv,signOf,mulV};
}
// F = Q(sqrt2, sqrt5, tau): g0 = sqrt2 (sq 2), g1 = sqrt5 (sq 5), g2 = tau (sq sqrt5 - 1 = [-1, 0, 1, 0] over {1, sqrt2, sqrt5, sqrt10})
const F=makeTower('Q(√2, √5, τ)',[{name:'√2',sq:[2n]},{name:'√5',sq:[5n,0n]},{name:'τ',sq:[-1n,0n,1n,0n]}]);
// K = Q(sqrt3, sqrt5)
const K=makeTower('Q(√3, √5)',[{name:'√3',sq:[3n]},{name:'√5',sq:[5n,0n]}]);
// ---------------------------------------------------------------- F[i] and SU(1,1) over F
// a complex element is {re, im} in F; a matrix [[a, b], [conj b, conj a]] is stored as {a, b}
const C={
  make:(re,im)=>({re,im:im||F.ZERO}),
  add:(x,y)=>({re:F.add(x.re,y.re),im:F.add(x.im,y.im)}),
  sub:(x,y)=>({re:F.sub(x.re,y.re),im:F.sub(x.im,y.im)}),
  mul:(x,y)=>({re:F.sub(F.mul(x.re,y.re),F.mul(x.im,y.im)),im:F.add(F.mul(x.re,y.im),F.mul(x.im,y.re))}),
  conj:x=>({re:x.re,im:F.neg(x.im)}),
  neg:x=>({re:F.neg(x.re),im:F.neg(x.im)}),
  abs2:x=>F.add(F.mul(x.re,x.re),F.mul(x.im,x.im)),
  eq:(x,y)=>F.eq(x.re,y.re)&&F.eq(x.im,y.im),
  isZero:x=>F.isZero(x.re)&&F.isZero(x.im),
  div:(x,y)=>{const d=F.inv(C.abs2(y)),n=C.mul(x,C.conj(y));return {re:F.mul(n.re,d),im:F.mul(n.im,d)};},
  key:x=>F.key(x.re)+'|'+F.key(x.im)
};
const SU={
  I:{a:C.make(F.ONE),b:C.make(F.ZERO)},
  mul:(g,h)=>({a:C.add(C.mul(g.a,h.a),C.mul(g.b,C.conj(h.b))),b:C.add(C.mul(g.a,h.b),C.mul(g.b,C.conj(h.a)))}),
  inv:g=>({a:C.conj(g.a),b:C.neg(g.b)}),                    // exact inverse when |a|^2 - |b|^2 = 1
  det:g=>F.sub(C.abs2(g.a),C.abs2(g.b)),
  eq:(g,h)=>C.eq(g.a,h.a)&&C.eq(g.b,h.b),
  neg:g=>({a:C.neg(g.a),b:C.neg(g.b)}),
  point:g=>C.div(g.b,C.conj(g.a)),                          // g(0) = b / conj(a)
  key:g=>C.key(g.a)+'#'+C.key(g.b)
};
const S2=F.gen(0),S5=F.gen(1),TAU=F.gen(2),S10=F.mul(S2,S5);
const HALF_S2=F.scale(S2,1n,2n);
const CH=F.scale(F.add(S2,S10),1n,4n);                      // cosh(l/2) = (sqrt2 + sqrt10)/4
const SH=F.scale(TAU,1n,2n);                                // sinh(l/2) = tau/2
const RL={a:{re:HALF_S2,im:HALF_S2},b:C.make(F.ZERO)};     // rotation by +90 deg about 0: z -> i z  (a = e^{i pi/4})
const RR={a:{re:HALF_S2,im:F.neg(HALF_S2)},b:C.make(F.ZERO)};
const TE={a:C.make(CH),b:C.make(SH)};                       // translation by the edge l along the real axis: z -> (c z + s)/(s z + c)
const ML=SU.mul(RL,TE),MR=SU.mul(RR,TE);                    // one pen step: turn, then walk one edge
const api={VERSION,makeTower,F,K,C,SU,S2,S5,S10,TAU,CH,SH,RL,RR,TE,ML,MR,gcd};
if(typeof module!=='undefined'&&module.exports)module.exports=api;else root.FVFieldQ2Q5Tau=api;
})(typeof globalThis!=='undefined'?globalThis:this);
