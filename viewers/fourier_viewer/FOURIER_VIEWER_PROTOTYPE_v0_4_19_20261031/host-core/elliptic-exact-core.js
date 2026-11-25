(function(root){
'use strict';
// fv-elliptic-exact-core 0_1_0 (v0.4.17, SCHEMA_ADDENDUM_24): exact elliptic core for group D of the Panels tab. EXACT register only:
// BigInt integers, exact rationals {num, den} (BigInt, den > 0, reduced), residues mod p (BigInt, canonical in [0, p)). No DOM, no floating point.
// Brief: BUILD_BRIEF_v0_4_17_EXACT_ELLIPTIC.md (saphir: "No floating point"). The five-case addition table follows sec. 3 (first subsection) of Akshima et al.,
// "A Subexponential Time Algorithm for ECDL" (2026), as given in the brief. Curves are general Weierstrass [a1, a2, a3, a4, a6]:
//   y^2 + a1 x y + a3 y = x^3 + a2 x^2 + a4 x + a6.
// The point at infinity O is the explicit flag {inf: true}; an affine point is {inf: false, x, y}. No sentinel coordinates.
const VERSION='fv-elliptic-exact-core 0_1_0';
const MINUS='−';
// ---------------------------------------------------------------- integers
const babs=a=>a<0n?-a:a;
const bgcd=(a,b)=>{a=babs(a);b=babs(b);while(b){const t=a%b;a=b;b=t;}return a;};
const mod=(a,p)=>{const r=a%p;return r<0n?r+p:r;};
const isBig=v=>typeof v==='bigint';
function toBig(v,what){if(isBig(v))return v;if(typeof v==='string'&&/^-?[0-9]+$/.test(v))return BigInt(v);throw Error((what||'value')+' must be a BigInt or an integer string (got '+String(v)+')');}
// extended Euclid: returns [g, s, t] with s a + t b = g = gcd(a, b) >= 0
function egcd(a,b){let r0=a,r1=b,s0=1n,s1=0n,t0=0n,t1=1n;while(r1!==0n){const q=r0/r1;[r0,r1]=[r1,r0-q*r1];[s0,s1]=[s1,s0-q*s1];[t0,t1]=[t1,t0-q*t1];}
  if(r0<0n){r0=-r0;s0=-s0;t0=-t0;}return [r0,s0,t0];}
function invMod(a,p){const [g,s]=egcd(mod(a,p),p);if(g!==1n)throw Error('no inverse of '+a+' mod '+p+' (gcd '+g+')');return mod(s,p);}
function isPrime(n){n=toBig(n,'n');if(n<2n)return false;if(n<4n)return true;if(n%2n===0n)return false;for(let d=3n;d*d<=n;d+=2n)if(n%d===0n)return false;return true;}
function primesBelow(n){n=toBig(n,'n');const out=[];for(let q=2n;q<n;q++)if(isPrime(q))out.push(q);return out;}
// Jacobi symbol (a/n), n odd positive, by quadratic reciprocity (no modular powering)
function jacobi(a,n){
  if(n<=0n||n%2n===0n)throw Error('Jacobi symbol needs an odd positive n (got '+n+')');
  a=mod(a,n);let t=1n;
  while(a!==0n){
    while(a%2n===0n){a/=2n;const r=n%8n;if(r===3n||r===5n)t=-t;}
    [a,n]=[n,a];
    if(a%4n===3n&&n%4n===3n)t=-t;
    a=a%n;
  }
  return n===1n?t:0n;
}
// ---------------------------------------------------------------- rationals
function Q(n,d){n=toBig(n,'numerator');d=d===undefined?1n:toBig(d,'denominator');if(d===0n)throw Error('zero denominator');if(d<0n){n=-n;d=-d;}const g=bgcd(n,d)||1n;return {num:n/g,den:d/g};}
const QZ=Q(0n),Q1=Q(1n);
const qadd=(a,b)=>Q(a.num*b.den+b.num*a.den,a.den*b.den),qsub=(a,b)=>Q(a.num*b.den-b.num*a.den,a.den*b.den),qmul=(a,b)=>Q(a.num*b.num,a.den*b.den);
const qneg=a=>Q(-a.num,a.den),qinv=a=>{if(a.num===0n)throw Error('division by zero in Q');return Q(a.den,a.num);},qdiv=(a,b)=>qmul(a,qinv(b));
const qeq=(a,b)=>a.num===b.num&&a.den===b.den,qcmp=(a,b)=>{const l=a.num*b.den,r=b.num*a.den;return l<r?-1:l>r?1:0;};
const qstr=a=>(a.num<0n?MINUS:'')+babs(a.num)+(a.den===1n?'':'/'+a.den);
const qascii=a=>a.num+(a.den===1n?'':'/'+a.den);
function qparse(s){const m=/^(-?[0-9]+)(?:\/([0-9]+))?$/.exec(String(s).trim());if(!m)throw Error('not an exact rational: '+s);return Q(BigInt(m[1]),m[2]?BigInt(m[2]):1n);}
// ---------------------------------------------------------------- fields: Q, and F_p (p prime)
const FQ={kind:'Q',char:0n,zero:QZ,one:Q1,from:v=>isBig(v)?Q(v):v&&isBig(v.num)?Q(v.num,v.den):qparse(v),add:qadd,sub:qsub,mul:qmul,neg:qneg,inv:qinv,
  eq:qeq,isZero:a=>a.num===0n,str:qstr,ascii:qascii,label:'Q'};
const FP_CACHE=new Map();
function Fp(p){
  p=toBig(p,'p');if(!isPrime(p))throw Error('F_p needs a prime p (got '+p+')');if(FP_CACHE.has(p))return FP_CACHE.get(p);
  const F={kind:'Fp',p,char:p,zero:0n,one:1n%p,
    from:v=>{if(isBig(v))return mod(v,p);const r=v&&isBig(v.num)?v:qparse(v);if(mod(r.den,p)===0n)throw Error('denominator divisible by p = '+p);return mod(r.num*invMod(r.den,p),p);},
    add:(a,b)=>mod(a+b,p),sub:(a,b)=>mod(a-b,p),mul:(a,b)=>mod(a*b,p),neg:a=>mod(-a,p),inv:a=>{if(a===0n)throw Error('division by zero in F_'+p);return invMod(a,p);},
    eq:(a,b)=>a===b,isZero:a=>a===0n,str:a=>String(a),ascii:a=>String(a),label:'F_'+p};
  FP_CACHE.set(p,F);return F;
}
// ---------------------------------------------------------------- curves
// invariants over any field (b2, b4, b6, b8, c4, c6, Delta), the standard formulas
function invariants(F,a){
  const [a1,a2,a3,a4,a6]=a,m=F.mul,ad=F.add,sb=F.sub,k=n=>F.from(BigInt(n));
  const b2=ad(m(a1,a1),m(k(4),a2)),b4=ad(m(k(2),a4),m(a1,a3)),b6=ad(m(a3,a3),m(k(4),a6));
  const b8=sb(ad(sb(ad(m(m(a1,a1),a6),m(k(4),m(a2,a6))),m(a1,m(a3,a4))),m(a2,m(a3,a3))),m(a4,a4));
  const c4=sb(m(b2,b2),m(k(24),b4)),c6=ad(ad(F.neg(m(b2,m(b2,b2))),m(k(36),m(b2,b4))),F.neg(m(k(216),b6)));
  const disc=ad(sb(sb(F.neg(m(m(b2,b2),b8)),m(k(8),m(b4,m(b4,b4)))),m(k(27),m(b6,b6))),m(k(9),m(b2,m(b4,b6))));
  return {b2,b4,b6,b8,c4,c6,disc};
}
function curve(ainvs,field){
  if(!Array.isArray(ainvs)||ainvs.length!==5)throw Error('ainvs must be [a1, a2, a3, a4, a6]');
  const F=field||FQ,a=ainvs.map(v=>F.from(v)),inv=invariants(F,a);
  return {F,a,ainvs:ainvs.slice(),...inv,singular:F.isZero(inv.disc)};
}
const curveQ=ainvs=>curve(ainvs,FQ);
const curveFp=(ainvs,p)=>curve(ainvs,Fp(p));
const O=Object.freeze({inf:true});
const pt=(x,y)=>({inf:false,x,y});
function onCurve(E,P){
  if(P.inf)return true;const F=E.F,[a1,a2,a3,a4,a6]=E.a,{x,y}=P,m=F.mul;
  const lhs=F.add(F.add(m(y,y),m(a1,m(x,y))),m(a3,y)),rhs=F.add(F.add(F.add(m(x,m(x,x)),m(a2,m(x,x))),m(a4,x)),a6);
  return F.eq(lhs,rhs);
}
function neg(E,P){if(P.inf)return O;const F=E.F,[a1,,a3]=E.a;return pt(P.x,F.sub(F.neg(P.y),F.add(F.mul(a1,P.x),a3)));}
const ptEq=(E,P1,P2)=>P1.inf||P2.inf?(P1.inf&&P2.inf):(E.F.eq(P1.x,P2.x)&&E.F.eq(P1.y,P2.y));
// the five-case table: case labels
const CASES=['P1 = O','P2 = O','P2 = −P1','generic','doubling'];
const CASE_KEYS=['p1inf','p2inf','opposite','generic','doubling'];
// which case applies; exactly one must (asserted)
function caseOf(E,P1,P2){
  const F=E.F,[a1,,a3]=E.a;
  const fin=!P1.inf&&!P2.inf;
  const sameX=fin&&F.eq(P1.x,P2.x);
  const conds=[
    P1.inf,
    P2.inf&&!P1.inf,
    sameX&&F.isZero(F.add(F.add(P1.y,P2.y),F.add(F.mul(a1,P2.x),a3))),
    fin&&!sameX,
    fin&&ptEq(E,P1,P2)&&!F.isZero(F.add(F.add(F.mul(F.from(2n),P1.y),F.mul(a1,P1.x)),a3))
  ];
  const n=conds.filter(Boolean).length;
  if(n!==1)throw Error('five-case table: '+n+' cases apply (exactly one must); are both points on the curve?');
  return conds.indexOf(true);
}
// the doubling slope; refuses at 2-torsion (2 y1 + a1 x1 + a3 = 0)
function doublingLambda(E,P){
  const F=E.F,[a1,a2,a3,a4]=E.a,two=F.from(2n),three=F.from(3n);
  if(P.inf)throw Error('doubling refused: P = O');
  const den=F.add(F.add(F.mul(two,P.y),F.mul(a1,P.x)),a3);
  if(F.isZero(den))throw Error('doubling refused: 2y1 + a1x1 + a3 = 0 (P is 2-torsion; the table sends P + P to the case P2 = −P1)');
  const num=F.sub(F.add(F.add(F.mul(three,F.mul(P.x,P.x)),F.mul(two,F.mul(a2,P.x))),a4),F.mul(a1,P.y));
  return F.mul(num,F.inv(den));
}
function genericLambda(E,P1,P2){const F=E.F,dx=F.sub(P2.x,P1.x);if(F.isZero(dx))throw Error('generic slope refused: x1 = x2');return F.mul(F.sub(P2.y,P1.y),F.inv(dx));}
// P1 + P2 with the case label
function add(E,P1,P2){
  const c=caseOf(E,P1,P2),label=CASES[c],key=CASE_KEYS[c];
  if(c===0)return {R:P2,case:label,key,index:c};
  if(c===1)return {R:P1,case:label,key,index:c};
  if(c===2)return {R:O,case:label,key,index:c};
  const F=E.F,[a1,a2,a3]=E.a,lam=c===3?genericLambda(E,P1,P2):doublingLambda(E,P1);
  const nu=F.sub(P1.y,F.mul(lam,P1.x));
  const x3=F.sub(F.sub(F.sub(F.add(F.mul(lam,lam),F.mul(a1,lam)),a2),P1.x),P2.x);
  const y3=F.sub(F.sub(F.neg(F.mul(F.add(lam,a1),x3)),nu),a3);
  return {R:pt(x3,y3),case:label,key,index:c,lambda:lam,nu};
}
// [k]P by left-to-right double-and-add; returns the result and the sequence of steps with their case labels
function mul(E,k,P){
  k=toBig(k,'k');let Q0=P;if(k<0n){k=-k;Q0=neg(E,P);}
  const steps=[];let R=O;
  const bits=k.toString(2);
  if(k===0n)return {R:O,steps};
  for(let i=0;i<bits.length;i++){
    if(i>0){const d=add(E,R,R);steps.push({op:'double',case:d.case,key:d.key,R:d.R});R=d.R;}
    if(bits[i]==='1'){const s=add(E,R,Q0);steps.push({op:'add P',case:s.case,key:s.key,R:s.R});R=s.R;}
  }
  return {R,steps};
}
// reduction of a rational point mod p: O when p divides a denominator
function reduce(Eq,P,p){
  p=toBig(p,'p');const Ep=curve(Eq.ainvs,Fp(p));
  if(P.inf)return {E:Ep,R:O};
  const dx=P.x.den,dy=P.y.den;
  if(mod(dx,p)===0n||mod(dy,p)===0n)return {E:Ep,R:O,why:'p divides a denominator'};
  return {E:Ep,R:pt(Ep.F.from(P.x),Ep.F.from(P.y))};
}
// enc(A) = 2x + (y mod 2) on canonical residues; O is encoded as 2p (outside the affine range [0, 2p)) - this code's convention
function enc(E,P){if(E.F.kind!=='Fp')throw Error('enc is defined over F_p');return P.inf?2n*E.F.p:2n*P.x+(P.y%2n);}
// all points of E(F_p), O first, then affine (x, y) in lexicographic order. Exhaustive over F_p^2 (small p only).
function points(E){
  if(E.F.kind!=='Fp')throw Error('points() needs F_p');const p=E.F.p;if(p>1000n)throw Error('points(): p too large for exhaustive listing');
  const out=[O];for(let x=0n;x<p;x++)for(let y=0n;y<p;y++){const P=pt(x,y);if(onCurve(E,P))out.push(P);}return out;
}
// singular points of the affine cubic over F_p (both partials vanish), exhaustive
function singularPoints(E){
  const F=E.F,p=F.p,[a1,a2,a3,a4]=E.a,out=[];
  for(let x=0n;x<p;x++)for(let y=0n;y<p;y++){const P=pt(x,y);if(!onCurve(E,P))continue;
    const fy=F.add(F.add(F.mul(2n,y),F.mul(a1,x)),a3),fx=F.sub(F.mul(a1,y),F.add(F.add(F.mul(3n,F.mul(x,x)),F.mul(2n,F.mul(a2,x))),a4));
    if(F.isZero(fy)&&F.isZero(fx))out.push(P);}
  return out;
}
// a_p route (i): naive count of all projective points of the reduction (singular point included; one point at infinity [0:1:0])
function apNaive(ainvs,p){
  p=toBig(p,'p');const E=curve(ainvs,Fp(p));let aff=0n;
  for(let x=0n;x<p;x++)for(let y=0n;y<p;y++)if(onCurve(E,pt(x,y)))aff++;
  const N=aff+1n;return {p,count:N,ap:p+1n-N,affine:aff};
}
// a_p route (ii), odd p: (2y + a1x + a3)^2 = 4x^3 + b2x^2 + 2b4x + b6, a_p = -sum_x (f(x)/p), Legendre symbols by Jacobi reciprocity
function apCharSum(ainvs,p){
  p=toBig(p,'p');if(p===2n)throw Error('route (ii) is for odd p only; p = 2 uses route (i)');
  const E=curve(ainvs,Fp(p)),{b2,b4,b6}=E;let s=0n;
  for(let x=0n;x<p;x++){const f=mod(4n*x*x*x+b2*x*x+2n*b4*x+b6,p);s+=jacobi(f,p);}
  return {p,ap:-s,count:p+1n+s};
}
// reduction type at p: good, or for p | Delta: from the tangent cone at the singular point (works for every p, including 2 and 3)
function reductionType(ainvs,p){
  p=toBig(p,'p');const E=curve(ainvs,Fp(p)),F=E.F;
  if(!E.singular)return {type:'good',label:'good reduction'};
  const S=singularPoints(E);if(S.length!==1)throw Error('expected one singular point mod '+p+' (got '+S.length+')');
  const [a1,a2]=E.a,r=S[0].x;
  // translate the singular point to (0, 0): u = 1, s = 0; the tangent cone is Y^2 + a1 X Y - a2' X^2
  const a2p=F.add(a2,F.mul(3n,r));
  const disc=F.add(F.mul(a1,a1),F.mul(4n,a2p));   // b2 of the translated curve
  let type,label;
  if(F.isZero(disc)){type='additive';label='additive (cusp)';}
  else{let split;
    if(p===2n){split=F.isZero(a2p);}   // T^2 + T + a2' has a root in F_2 iff a2' = 0 (a1 = 1 here since b2' != 0)
    else split=jacobi(disc,p)===1n;
    type=split?'split':'nonsplit';label=split?'split multiplicative (node, tangents rational)':'nonsplit multiplicative (node, tangents conjugate over F_p2)';}
  return {type,label,singular:S[0],expected_ap:type==='split'?1n:type==='nonsplit'?-1n:0n,cone:{a1,a2:a2p,disc}};
}
// change of Weierstrass model (u, r, s, t), Sage's convention: x = u^2 x' + r, y = u^3 y' + s u^2 x' + t
function changeModel(ainvs,u,r,s,t){
  const [a1,a2,a3,a4,a6]=ainvs.map(v=>FQ.from(v));[u,r,s,t]=[u,r,s,t].map(v=>FQ.from(v));
  const m=qmul,ad=qadd,sb=qsub,k=n=>Q(BigInt(n)),pw=(x,n)=>{let y=Q1;for(let i=0;i<n;i++)y=m(y,x);return y;};
  const a1p=qdiv(ad(a1,m(k(2),s)),u);
  const a2p=qdiv(sb(ad(sb(a2,m(s,a1)),m(k(3),r)),m(s,s)),pw(u,2));
  const a3p=qdiv(ad(ad(a3,m(r,a1)),m(k(2),t)),pw(u,3));
  const a4p=qdiv(sb(ad(sb(ad(sb(a4,m(s,a3)),m(k(2),m(r,a2))),m(ad(t,m(r,s)),a1)),m(k(3),m(r,r))),m(k(2),m(s,t))),pw(u,4));
  const a6p=qdiv(sb(sb(sb(ad(ad(ad(a6,m(r,a4)),m(m(r,r),a2)),pw(r,3)),m(t,a3)),m(t,t)),m(m(r,t),a1)),pw(u,6));
  return [a1p,a2p,a3p,a4p,a6p];
}
function mapPoint(P,u,r,s,t){
  if(P.inf)return O;[u,r,s,t]=[u,r,s,t].map(v=>FQ.from(v));
  const u2=qmul(u,u),u3=qmul(u2,u),xp=qdiv(qsub(P.x,r),u2),yp=qdiv(qsub(qsub(P.y,qmul(qmul(s,u2),xp)),t),u3);
  return pt(xp,yp);
}
// order of a point over F_p, by repeated addition (small groups only)
function order(E,P,cap){let R=P,n=1n;const lim=toBig(cap||100000n,'cap');while(!R.inf){R=add(E,R,P).R;n++;if(n>lim)throw Error('order above cap');}return n;}
// group structure test: E(F_p) is cyclic iff some point has order #E(F_p) (exhaustive, small p)
function cyclicWitness(E){const pts=points(E),N=BigInt(pts.length);for(const P of pts){if(P.inf&&N>1n)continue;if(order(E,P)===N)return {N,cyclic:true,generator:P};}return {N,cyclic:false,generator:null};}
const ptStr=(E,P)=>P.inf?'O':'('+E.F.str(P.x)+', '+E.F.str(P.y)+')';
const PRESETS={'37a1':{label:'37a1',ainvs:[0n,0n,1n,-1n,0n],P:[Q(0n),Q(-1n)],conductor:37n,note:'y² + y = x³ − x, rank 1, generator P = (0, −1) (Sage E.gens()[0])'}};
const api={VERSION,CASES,CASE_KEYS,PRESETS,O,pt,Q,qadd,qsub,qmul,qdiv,qneg,qinv,qeq,qcmp,qstr,qascii,qparse,FQ,Fp,curve,curveQ,curveFp,invariants,onCurve,neg,ptEq,caseOf,add,mul,
  doublingLambda,genericLambda,reduce,enc,points,singularPoints,apNaive,apCharSum,reductionType,changeModel,mapPoint,order,cyclicWitness,ptStr,jacobi,egcd,invMod,isPrime,primesBelow,mod,bgcd};
if(typeof module!=='undefined'&&module.exports)module.exports=api;
root.FVEllipticExact=api;
})(typeof globalThis!=='undefined'?globalThis:this);
