(function(root){
'use strict';
// fv-comb-numeric 0.1.0: NUMERICAL register. Every value is an approximation carrying `bound`.
// Bound formula (stated, conservative):  bound = 8 * (m + 2 + |alpha|*(1+|ln N|)) * EPS * max(|rho|, 1)
// v0.3 (addendum 8): N here is number(Nq), the float of the exact rational N (an integer on a shell); rho = n6*N^alpha and ln N use that float; the bound uses |ln N| (equal to ln N for N >= 1, so unchanged on every shell; N < 1 is reachable only between shells).
// applied to every tooth z_c and partial sum W_t (absolute error in the plane); Hopf-sphere values carry
// 2*bound/scale (the chart w -> sphere is 2-Lipschitz in w/scale). EPS = 2^-52. Numerical values never source exact statements.
const C=typeof module!=='undefined'&&module.exports?require('./comb-core.js'):root.FVCombCore;
const X=typeof module!=='undefined'&&module.exports?require('../exact-lib/exact-lib-0.2.0.js'):root.FVExact;
const EPS=Math.pow(2,-52),abs=n=>n<0n?-n:n;
const SAFE=9007199254740992n,bits=n=>n.toString(2).length;
function number(q){                                      // exact rational -> float (correctly rounded for safe pairs, else scaled)
  const n=q.n,d=q.d;if(n===0n)return 0;
  if(abs(n)<=SAFE&&d<=SAFE)return Number(n)/Number(d);
  const e=bits(abs(n))-bits(d),shift=64-e,scaled=shift>=0?(n<<BigInt(shift))/d:n/(d<<BigInt(-shift));
  return Number(scaled)*Math.pow(2,-64)*Math.pow(2,e);
}
function hopf(w,scale){                                  // scale A: scale = 1 (w = W); scale B: scale = |rho| (w = W/rho)
  const x=w.re/scale,y=w.im/scale,q=x*x+y*y,d=1+q;return [2*x/d,2*y/d,(q-1)/d];
}
const edgePoints=(a,b,scale,n=16)=>Array.from({length:n+1},(_,i)=>{const t=i/n;return hopf({re:a.re*(1-t)+b.re*t,im:a.im*(1-t)+b.im*t},scale);});
// Comb-walk edge W_{t-1} -> W_t as the TRUE curve on S2 (v0.1.1): the planar segment is sampled (32 equal intervals at least), then every interval whose
// sphere step exceeds 2 degrees is bisected (so a long edge gets as many samples as it needs), and each planar sample w = (a + (b-a)u)/scale is mapped
// through fromAffine. Samples with |w|^2 > POLE_Q are null: the curve is broken near the north pole (w -> infinity) and never joined across the break.
const EDGE_MIN=32,EDGE_MAX_DEG=2,EDGE_CAP=20000,POLE_Q=1e12,EDGE_STEP=EDGE_MAX_DEG*Math.PI/180;
const sphereAngle=(p,q)=>2*Math.asin(Math.min(1,Math.hypot(p[0]-q[0],p[1]-q[1],p[2]-q[2])/2));
function edgeCurve(a,b,scale){
  const at=u=>{const re=(a.re+(b.re-a.re)*u)/scale,im=(a.im+(b.im-a.im)*u)/scale,q=re*re+im*im;return q>POLE_Q?null:fromAffine({re,im});};
  const seg=u=>({u,p:at(u)});
  let pts=[];for(let i=0;i<=EDGE_MIN;i++)pts.push(seg(i/EDGE_MIN));
  const out=[];let budget=EDGE_CAP;
  const refine=(l,r,depth)=>{                            // l, r: samples; push l..r (r excluded) subdividing while a finite step is too long
    if(depth<48&&budget>0&&l.p&&r.p&&sphereAngle(l.p,r.p)>EDGE_STEP){budget--;const mid=seg((l.u+r.u)/2);refine(l,mid,depth+1);refine(mid,r,depth+1);}
    else if(depth<48&&budget>0&&(!l.p)!==(!r.p)&&r.u-l.u>1e-15){budget--;const mid=seg((l.u+r.u)/2);refine(l,mid,depth+1);refine(mid,r,depth+1);}   // locate the pole break
    else out.push(l);};
  for(let i=0;i<EDGE_MIN;i++)refine(pts[i],pts[i+1],0);
  out.push(pts[EDGE_MIN]);
  return out.map(o=>o.p);
}
// v0.4.14 (SCHEMA_ADDENDUM_22): opts.mask = integer walk weights (0, 1, 2) per tooth in offset order, the Goldbach prime-pair mask; absent: every line below is the v0.4.13 code path.
function compute(st,opts){
  const mask=opts&&opts.mask||null;
  const R=C.resolve(st);
  if(R.Nq.n<=0n)return {refused:'N = 0: no walk is defined.',empty:true};
  const alpha=number(R.alpha),r6=number(R.n6),Nf=number(R.Nq);
  const radius=r6===0?0:r6*Math.pow(Nf,alpha);
  if(!Number.isFinite(radius))return {refused:'Physical radius is outside the numerical drawing range.'};
  if(radius===0&&R.n6.n!==0n)return {refused:'n₆ is nonzero but the physical radius n₆·N^α underflows to 0 in floating point; refused rather than drawn as ρ = 0.'};
  const rho=Math.abs(radius),bound0=8*(R.m+2+Math.abs(alpha)*(1+Math.abs(Math.log(Nf))))*EPS*Math.max(rho,1);
  // v0.4.7 (SCHEMA_ADDENDUM_15): alpha_Tilt weights the WALK steps only, w_t = t^tilt, t = 1 … m (offset order); at tilt = 0 this block is skipped (no multiplication by 1).
  const tiltQ=R.tilt,tilted=tiltQ.n!==0n,tl=tilted?number(tiltQ):0,wts=[];
  let bound=bound0;
  if(tilted){for(let t=1;t<=R.m;t++)wts.push(tiltQ.d===1n&&tiltQ.n===1n?t:Math.pow(t,tl));
    const wmax=tl>0?Math.pow(R.m,tl):1;bound=8*(R.m+2+Math.abs(alpha)*(1+Math.abs(Math.log(Nf)))+Math.abs(tl)*(1+Math.log(R.m)))*EPS*Math.max(rho*wmax,1);}
  if(mask&&tilted)return {refused:'The Goldbach mask weights the walk 0/1/2 and cannot be combined with a nonzero α_Tilt (a product weight would not be G_N).'};
  if(mask)bound=2*bound0;      // weights up to 2: the error of a masked sum is at most twice the unweighted bound
  const scaleB=rho||1,scale=st.chart==='comb'?scaleB:1,hb=2*bound/scale;
  const T=C.teeth(st,R),z=[],W=[{re:0,im:0}];
  for(const t of T){
    const th=Math.PI*number(t.phase),zc={c:t.c,re:radius*Math.cos(th),im:radius*Math.sin(th)};
    if(!Number.isFinite(zc.re)||!Number.isFinite(zc.im))return {refused:'Tooth c = '+t.c+' has no finite numerical phase; the walk is refused rather than drawn as NaN.'};
    z.push(zc);const p=W[W.length-1],w=tilted?wts[z.length-1]:1;if(mask){const mw=mask[z.length-1];W.push({re:p.re+mw*zc.re,im:p.im+mw*zc.im});continue;}W.push(tilted?{re:p.re+w*zc.re,im:p.im+w*zc.im}:{re:p.re+zc.re,im:p.im+zc.im});
  }
  if(!W.every(w=>Number.isFinite(w.re)&&Number.isFinite(w.im)))return {refused:'The numerical walk left the finite drawing range; nothing is drawn.'};
  const H=W.map(w=>hopf(w,scale));
  if(!H.every(p=>p.every(Number.isFinite)))return {refused:'The Hopf image left the finite range; nothing is drawn.'};
  const rs=rho/scale,lat=(rs*rs-1)/(rs*rs+1);            // tooth latitude height on the displayed chart
  const resid=mask?Math.abs(hopf(z[0],scale)[2]-lat):Math.abs(H[1][2]-lat),end=W[W.length-1],mag=Math.hypot(end.re,end.im);
  // S3 lift (host liftToS3 L4766, with the exact reduced phases from comb-core), per tooth, and the chart-compat gate
  const a=rho/Math.sqrt(1+rho*rho),b=1/Math.sqrt(1+rho*rho),lift=[];let compat=0;
  T.forEach((t,i)=>{
    const u=Math.PI*number(t.carrier),v=Math.PI*number(t.offset);               // v already carries the negative sign
    const z1={re:a*Math.cos(u),im:a*Math.sin(u)},z2={re:b*Math.cos(v),im:b*Math.sin(v)};
    const s2=hopfBase(z1,z2),proj=stereo(z1,z2,rho===0&&t.offset.n*2n===t.offset.d);
    compat=Math.max(compat,Math.hypot(s2[0]-fromAffine(z[i])[0],s2[1]-fromAffine(z[i])[1],s2[2]-fromAffine(z[i])[2]));
    lift.push({c:t.c,z1,z2,s2,proj});
  });
  const th0=Math.PI*number(T[0].carrier),z0={re:rho*Math.cos(th0),im:rho*Math.sin(th0)};   // carrier phasor rho*e^{i pi t1 s} (|radius|, carrier includes the n6<0 flip)
  const qres=Math.abs(end.im);
  return {empty:false,radius,rho,scale,bound,hopfBound:hb,z,W,H,lat,lift,z0,
    chartCompat:{maxDiff:compat,ok:compat<1e-10},qres:{value:qres,bound},
    gate:{residual:resid,bound:hb,ok:resid<=hb},
    endpoint:{abs:mag,absOverRho:rho?mag/rho:null},rhoZero:rho===0,...(mask?{mask:{w:mask.slice(),kept:mask.filter(x=>x>0).length}}:{}),...(tilted?{tilt:{value:tl,exactWeights:tiltQ.d===1n,weights:wts,wmax:tl>0?Math.pow(R.m,tl):1}}:{})};
}
// ---- Hopf base map HOPF_BASE_S2_Z1_Z2_V1 and its gate fixtures (addendum 1 s C)
function hopfBase(z1,z2){return [2*(z1.re*z2.re+z1.im*z2.im),2*(z1.im*z2.re-z1.re*z2.im),z1.re*z1.re+z1.im*z1.im-z2.re*z2.re-z2.im*z2.im];}
function fromAffine(w){const q=w.re*w.re+w.im*w.im,d=1+q;return [2*w.re/d,2*w.im/d,(q-1)/d];}
// Stereographic projection from the north pole x4 = +1 of (Re z1, Im z1, Re z2, Im z2)  (host L4842)
function stereo(z1,z2,exactNorthPole){
  const x1=z1.re,x2=z1.im,x3=z2.re,x4=z2.im,d=x4>0?(x1*x1+x2*x2+x3*x3)/(1+x4):1-x4,branch=x4>0?'UNIT_S3_COMPLEMENT':'DIRECT';
  if(d>=1e-9)return {status:'FINITE',vector:[x1/d,x2/d,x3/d],d,branch};
  return {status:exactNorthPole?'AT_INFINITY':'CLIPPED_NEAR_POLE',vector:null,d,branch};
}
function gateFixtures(){
  const h=Math.SQRT1_2,f=[
    [[1,0],[0,0],[0,0,1]],[[0,0],[1,0],[0,0,-1]],[[h,0],[h,0],[1,0,0]],[[0,h],[h,0],[0,1,0]]];
  const out=f.map(([a,b,e])=>{const q=hopfBase({re:a[0],im:a[1]},{re:b[0],im:b[1]});return Math.hypot(q[0]-e[0],q[1]-e[1],q[2]-e[2])<1e-12;});
  const q=fromAffine({re:1,im:0});out.push(Math.hypot(q[0]-1,q[1],q[2])<1e-12);return out;
}
// Tooth trail on S2 (host: 49 samples over s +- 1.15*pi/|rate|, rate = pi*k_c/N): the tooth value at sample angle
function trailAngles(theta0,n=49){return Array.from({length:n},(_,i)=>theta0+(i/(n-1)*2-1)*1.15*Math.PI);}
// Clifford meshes (projected). Leaf of radius rho: |z1|=a, |z2|=b. Reference surface: a=b=1/sqrt2.
function torusMesh(a,b,nu=64,nv=32){
  const rows=[];for(let i=0;i<=nu;i++){const row=[],u=2*Math.PI*i/nu;
    for(let j=0;j<=nv;j++){const v=2*Math.PI*j/nv,p=stereo({re:a*Math.cos(u),im:a*Math.sin(u)},{re:b*Math.cos(v),im:b*Math.sin(v)},false);row.push(p.vector);}rows.push(row);}
  return rows;
}
function circle3(a,b,kind,ph0,n=96){                      // builder's reading of the "four circles" on the leaf (addendum gives no formulas)
  const pts=[];for(let i=0;i<=n;i++){const t=2*Math.PI*i/n;let u=ph0[0],v=ph0[1];
    if(kind==='meridian')v+=t;else if(kind==='parallel')u+=t;else if(kind==='hopf'){u+=t;v+=t;}else{u+=t;v-=t;}
    pts.push(stereo({re:a*Math.cos(u),im:a*Math.sin(u)},{re:b*Math.cos(v),im:b*Math.sin(v)},false).vector);}
  return pts;
}
// s-orbits. NUMERICAL; a tooth is stationary (no orbit) only when both lifted rates are 0; k_c = 0 with a nonzero lifted rate is baseFixed (no S2 trail, S3 orbit along the Hopf fibre) (corrected 2026-10-14). Sampling (fix round 4): the carrier phase u = pi*t1*s and the offset
// phase v = pi*c*t2*s/N advance linearly in s; the step in s is chosen so that u, v (and the S2 angle pi*k*s/N) each advance
// at most 2 degrees per step. The orbit closes with period lcm(2/|t1|, 2N/|c*t2|) in s (a zero rate imposes no condition), computed
// exactly with BigInt rationals. One full period is drawn, centred on the current s; if that needs more than ORBIT_CAP points the
// window is a partial orbit of ORBIT_CAP points, flagged `partial`. Points that project to the pole are null (the view breaks there).
const ORBIT_CAP=4000,ORBIT_STEP=Math.PI/90;
function ratLcm(a,b){const g=(x,y)=>X.gcd(x,y),l=(x,y)=>x/g(x,y)*y;return X.rat(l(a.n,b.n),g(a.d,b.d));}   // lcm of reduced positive rationals
function orbitPeriod(t1,t2,c,N){                         // N: a BigInt or an exact rational a/b (addendum 8)
  const Nq=typeof N==='bigint'?X.rat(N):N;
  const ps=[];if(t1.n!==0n)ps.push(X.rat(2n*t1.d,t1.n<0n?-t1.n:t1.n));
  const ct=X.mul(X.rat(c),t2);if(ct.n!==0n)ps.push(X.rat(2n*Nq.n*ct.d,Nq.d*(ct.n<0n?-ct.n:ct.n)));
  return ps.length?ps.reduce(ratLcm):null;}
function orbits(st,num,coarse){                          // `coarse` (preview register, DRAWING only): draw 1/coarse of the points; partial / period / span are those of the full sampling
  coarse=coarse>1?coarse:1;
  if(!num||num.empty||num.refused)return [];
  const R=C.resolve(st),Nf=number(R.Nq),s0=number(X.parse(st.sTyped)),t1=number(R.t1),t2=number(R.t2),rho=num.rho,sg=R.n6.n<0n?Math.PI:0;
  const aa=rho/Math.sqrt(1+rho*rho),bb=1/Math.sqrt(1+rho*rho);
  return C.teeth(st,R).map(t=>{
    const rate=Math.PI*number(t.k)/Nf,ru=Math.abs(t1),rv=Math.abs(Number(t.c)*t2/Nf),rk=Math.abs(rate)/Math.PI;
    const baseFixed=rate===0;   // k_c = 0: the base point is fixed; the tooth is truly stationary only when both lifted rates ru, rv are also 0
    if(baseFixed&&ru===0&&rv===0)return {c:t.c,stationary:true,s2:[],s3:[]};
    const P=orbitPeriod(R.t1,R.t2,t.c,R.Nq),Pf=P?number(P):Infinity;
    const ds=Math.min(...[ru,rv,rk].filter(r=>r>0).map(r=>ORBIT_STEP/(Math.PI*r)));
    let n=Math.ceil(Pf/ds*(1-1e-12)),partial=false;
    if(!(n<=ORBIT_CAP-1)){n=ORBIT_CAP-1;partial=true;}
    const span=partial?n*ds:Pf,s2=[],s3=[];
    if(coarse>1)n=Math.max(16,Math.ceil(n/coarse));
    for(let i=0;i<=n;i++){const sp=s0+(i/n-0.5)*span;
      if(!baseFixed)s2.push({re:num.radius*Math.cos(rate*sp),im:num.radius*Math.sin(rate*sp)});
      const u=Math.PI*t1*sp+sg,v=Math.PI*Number(t.c)*t2*sp/Nf;
      s3.push(stereo({re:aa*Math.cos(u),im:aa*Math.sin(u)},{re:bb*Math.cos(-v),im:bb*Math.sin(-v)},false).vector);}   // null = pole break
    return {c:t.c,stationary:false,baseFixed,s2,s3,partial,period:P?X.text(P):'none',points:n+1,ds,span};
  });
}
// Fraction-stack heads lifted to S3 and projected (display only). Phases are reduced exactly first, then converted.
function fractionPoints(st,heads,num){
  if(!num||num.empty||num.refused)return [];
  const R=C.resolve(st),rho=num.rho,aa=rho/Math.sqrt(1+rho*rho),bb=1/Math.sqrt(1+rho*rho),flip=X.rat(R.n6.n<0n?1n:0n);
  return heads.map(h=>{
    const car=C.phaseRep(X.add(X.mul(R.t1,h.s),flip)),off=C.phaseRep(X.neg(X.div(X.mul(X.mul(X.rat(h.c),R.t2),h.s),R.Nq)));
    const u=Math.PI*number(car),v=Math.PI*number(off),p=stereo({re:aa*Math.cos(u),im:aa*Math.sin(u)},{re:bb*Math.cos(v),im:bb*Math.sin(v)},false);
    return {c:h.c,j:h.j,zero:h.spreadZero,p:p.vector};});
}
// ---- v0.4 mirror axis, NUMERICAL / drawing register. Every exact statement (parity, counts, meeting parameters s_k, beta, reduced phases) comes from
// orbit-core (mirrorParity, mirrorPairs, mirrorMeeting); here the reduced phases are converted once and projected like the tooth dots.
// The reference longitudes are the fixed set of the mirror z2 -> conj(z2) on the leaf |z1| = a, |z2| = b: z2 = +b (beta = 0) and z2 = -b (beta = pi), z1 = a e^{iu}.
// Display objects only: no comb branch, no head, no export field. MIRROR_CAP bounds the meeting points drawn per state (labelled when reached).
const MIRROR_LONG_N=360,MIRROR_CAP=2000;
const ORB=typeof module!=='undefined'&&module.exports?require('./orbit-core.js'):root.FVOrbit;
function mirrorLongitudes(rho){
  const a=rho/Math.sqrt(1+rho*rho),b=1/Math.sqrt(1+rho*rho);
  return [0,1].map(beta=>{const pts=[];for(let i=0;i<=MIRROR_LONG_N;i++){const u=2*Math.PI*i/MIRROR_LONG_N;pts.push(stereo({re:a*Math.cos(u),im:a*Math.sin(u)},{re:beta?-b:b,im:0},false).vector);}return {beta,pts};});
}
// a point of the leaf from exact reduced phases (units of pi): z1 = a e^{i pi car}, z2 = b e^{i pi off}; projected as the tooth dots are
function mirrorLiftPoint(rho,car,off){
  const a=rho/Math.sqrt(1+rho*rho),b=1/Math.sqrt(1+rho*rho),u=Math.PI*number(car),v=Math.PI*number(off);
  return stereo({re:a*Math.cos(u),im:a*Math.sin(u)},{re:b*Math.cos(v),im:b*Math.sin(v)},false).vector;
}
// inverse of the stereographic projection from x4 = +1: a projected point back to (x1, x2, x3, x4) = (Re z1, Im z1, Re z2, Im z2) on S3
function unproject(y){const q=y[0]*y[0]+y[1]*y[1]+y[2]*y[2],d=1+q;return [2*y[0]/d,2*y[1]/d,2*y[2]/d,(q-1)/d];}
// the nearest reference longitude of a projected point: beta (0 or 1, units of pi), the angular distance |arg z2 - beta| (radians) and |z2|
function longitudeDistance(y,shift){
  const x=unproject(y),g=Math.atan2(x[3],x[2])-(shift||0),r=Math.atan2(Math.sin(g),Math.cos(g)),d0=Math.abs(r),dpi=Math.PI-d0;
  return {beta:d0<=dpi?0:1,dist:Math.min(d0,dpi),z1abs:Math.hypot(x[0],x[1]),z2abs:Math.hypot(x[2],x[3])};
}
// The geometry the Clifford view draws: the two longitudes and, per mirror pair, its
// same-time events s_k, 0 <= k < M = P|c t2|/N (review §5 R2); a partial orbit keeps the events of its drawn window, flagged). A collapsed leaf (rho = 0) gets no longitudes and no events.
function mirrorGeometry(st,num,orbs){
  if(!num||num.empty||num.refused)return null;
  if(!(num.rho>0))return {collapsed:true,parity:ORB.mirrorParity(st),longitudes:[],pairs:[],capped:false,cap:MIRROR_CAP};
  const R=C.resolve(st),rho=num.rho,pairs=ORB.mirrorPairs(st),s0=number(X.parse(st.sTyped)),out=[];let left=MIRROR_CAP,capped=false;
  for(const p of pairs){
    const rec={c:p.c,status:p.status,reason:p.reason,count:p.count,period:p.period,spacing:p.spacing,meetings:[],partial:false,capped:false,windowCount:null};
    if(p.status==='defined'){
      const ob=orbs?orbs.find(o=>o.c===p.c):null;let k0,k1;
      if(ob&&ob.partial){rec.partial=true;const w=number(p.spacing);k0=BigInt(Math.ceil((s0-ob.span/2)/w));k1=BigInt(Math.floor((s0+ob.span/2)/w));}   // drawing register: the window of the partial orbit drawn
      else{k0=0n;k1=p.count-1n;}   // review §5 R2: s_k = k N/|c t2|, 0 <= k < M (one common period; the same points as any window of length P)
      rec.windowCount=k1>=k0?k1-k0+1n:0n;
      for(let k=k0;k<=k1;k++){
        if(left<=0){rec.capped=true;capped=true;break;}left--;
        const mt=ORB.mirrorMeeting(st,R,p.c,p.spacing,k);
        rec.meetings.push({k:mt.k,s:mt.s,beta:Number(mt.beta),p:mirrorLiftPoint(rho,mt.carrier,mt.offsetPlus),pMinus:mirrorLiftPoint(rho,mt.carrier,mt.offsetMinus)});}
    }
    out.push(rec);
  }
  return {collapsed:false,parity:ORB.mirrorParity(st),longitudes:mirrorLongitudes(rho),pairs:out,capped,cap:MIRROR_CAP};
}
// ---- v0.4.1 carrier foliation, NUMERICAL / drawing register (exact lattice and labels from orbit-core carrierFoliation). On the leaf |z1| = a, |z2| = b each
// carrier longitude is (a e^{i theta}, b e^{i beta}), theta in [0, 2 pi): FOL_FAMILY_N + 1 samples per family curve, FOL_SEL_N + 1 for the selected beta and its companion.
// t1 = 0: the carrier action is trivial, each of its orbits is a point: one point per beta at the carrier phase theta = pi (t1 s + f) (labelled by the view).
// Collapsed leaf (a = 0 or b = 0): nothing is drawn.
const FOL_FAMILY_N=180,FOL_SEL_N=360;
function folCurve(a,b,betaPi,n,theta0){
  const bt=Math.PI*number(betaPi),z2={re:b*Math.cos(bt),im:b*Math.sin(bt)},pts=[];
  if(n===0){pts.push(stereo({re:a*Math.cos(theta0),im:a*Math.sin(theta0)},z2,false).vector);return pts;}
  for(let i=0;i<=n;i++){const u=2*Math.PI*i/n;pts.push(stereo({re:a*Math.cos(u),im:a*Math.sin(u)},z2,false).vector);}
  return pts;
}
function foliationGeometry(st,num,K,k){
  if(!num||num.empty||num.refused)return null;
  const F=ORB.carrierFoliation(st,K,k),rho=num.rho,a=rho/Math.sqrt(1+rho*rho),b=1/Math.sqrt(1+rho*rho);
  if(!(a>0&&b>0&&Number.isFinite(a)&&Number.isFinite(b)))return {F,collapsed:true,family:[],selected:null,companion:null,a,b};
  const stat=F.t1Zero,th=stat?Math.PI*number(ORB.mirrorCarrierPhase(st)):0,nF=stat?0:FOL_FAMILY_N,nS=stat?0:FOL_SEL_N;
  return {F,collapsed:false,stationary:stat,a,b,
    family:F.family.map(be=>({beta:be,pts:folCurve(a,b,be,nF,th)})),
    selected:{beta:F.beta,pts:folCurve(a,b,F.beta,nS,th)},companion:{beta:F.companion,pts:folCurve(a,b,F.companion,nS,th)}};
}
const api={EDGE_MIN,EDGE_STEP,edgeCurve,ORBIT_CAP,orbitPeriod,EPS,fractionPoints,number,hopf,edgePoints,compute,hopfBase,fromAffine,stereo,gateFixtures,orbits,trailAngles,torusMesh,circle3,MIRROR_CAP,MIRROR_LONG_N,mirrorLongitudes,mirrorLiftPoint,unproject,longitudeDistance,mirrorGeometry,FOL_FAMILY_N,FOL_SEL_N,foliationGeometry};
if(typeof module!=='undefined'&&module.exports)module.exports=api;else root.FVCombNumeric=api;
})(typeof globalThis!=='undefined'?globalThis:this);
