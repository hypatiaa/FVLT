(function(root){
'use strict';
// fv-stack-core 0.1.0 (v0.4.9, SCHEMA_ADDENDUM_17): the full stack ("the hand-built rosette") of the merged FVLT monodromy instrument, ported onto this viewer's exact core.
// The point set: for every integer layer s and every integer shell position phi3 in 0 .. B+1 (the shared span), N = B + 1 - phi3, and every tooth c of the m-comb,
// the tooth z_c = n6 * N^alpha * exp(i*pi*(N*t1 + c*t2)*s/N) of the comb at that state (comb-core teeth(): the same k_c and the same phase k_c*s/N).
// EXACT register: the phase residue (N*t1 + c*t2)*s/N mod 2 of every point is computed with exact integer arithmetic (BigInt, or Number integers when every
// operand stays below 2^53). NUMERICAL / DRAWING register: the amplitude n6*N^alpha and the drawn coordinates are float64, as in comb-numeric compute().
// The (s, phi3) lattice is m-independent through m = 30; above that a fixed total-draw budget thins it (bucketed by m only), as in the host (buildFullStack L7887).
// alpha_Tilt weights the walk only; the stack is made of teeth, so it does not depend on alpha_Tilt (it is not in the key).
const X=typeof module!=='undefined'&&module.exports?require('../exact-lib/exact-lib-0.2.0.js'):root.FVExact;
const C=typeof module!=='undefined'&&module.exports?require('./comb-core.js'):root.FVCombCore;
const GRID_CAP=58081,LIFT_CAP=12000,SAFE=2n**51n;
const num=q=>{const n=q.n,d=q.d;if(n===0n)return 0;const a=n<0n?-n:n;if(a<=2n**53n&&d<=2n**53n)return Number(n)/Number(d);const e=a.toString(2).length-d.toString(2).length,sh=64-e,sc=sh>=0?(n<<BigInt(sh))/d:n/(d<<BigInt(-sh));return Number(sc)*Math.pow(2,-64)*Math.pow(2,e);};
const mod=(a,b)=>{const r=a%b;return r<0n?r+b:r;};
// the cache key: everything the stack depends on (never phi3, s, nMode, tab, view or tilt)
function key(st,R){R=R||C.resolve(st);return [st.shellMode,String(R.B),X.text(R.n6),X.text(R.alpha),X.text(R.t1),X.text(R.t2),String(R.m)].join('|');}
// the (s, phi3) sample lattice (host rule): gridCap = 58081 = 241^2 for m <= 30, else max(400, floor(58081*30/m)); step 1 when (span+1)^2 <= gridCap, else ceil(span/sqrt(gridCap))
function lattice(st,R){
  R=R||C.resolve(st);const span=R.B+1n,spanN=Number(span),m=R.m;
  const gridCap=m<=30?GRID_CAP:Math.max(400,Math.floor(GRID_CAP*30/m)),total=(span+1n)*(span+1n);
  const step=total<=BigInt(gridCap)?1:Math.ceil(spanN/Math.sqrt(gridCap));
  const vals=[];for(let v=0;v<=spanN;v+=step)vals.push(v);
  const zeroCols=vals.includes(spanN)?1:0;               // phi3 = B + 1: N = 0, no comb at that column (labelled, never drawn)
  return {span,spanN,step,gridCap,total,thinned:step>1,mBucket:m>30,sVals:vals,phiVals:vals,ns:vals.length,cells:vals.length*(vals.length-zeroCols),zeroCells:vals.length*zeroCols};
}
// planar stack: cell-major (s outer, phi3 inner, the host's order), teeth inner in offset order. xy[2*(cell*m+t)] = Re, Im.
function build(st){
  const R=C.resolve(st),L=lattice(st,R),m=R.m,offs=C.offsets(m),cN=offs.map(Number);
  const a=R.t1.n,b=R.t1.d,p=R.t2.n,q=R.t2.d,r6=num(R.n6),al=num(R.alpha);
  const xy=new Float64Array(2*L.cells*m),cellS=new Float64Array(L.cells),cellN=new Float64Array(L.cells),rad=new Float64Array(L.cells);
  let i=0,maxR=0,nonFinite=0;
  const radOf=new Map();
  for(const s of L.sVals){const S=BigInt(s);
    for(const ph of L.phiVals){const N=L.span-BigInt(ph);if(N<=0n)continue;
      let radius=radOf.get(N);if(radius===undefined){const Nf=Number(N);radius=r6===0?0:r6*Math.pow(Nf,al);radOf.set(N,radius);}
      // phase residue of tooth c: (a*q*N*S + c*p*b*S) / (b*q*N) mod 2; first tooth c0, then each next offset adds (offset step)*p*b*S
      const den=b*q*N,per=2n*den,r0=mod(a*q*N*S+offs[0]*p*b*S,per),dStep=mod((m%2?1n:2n)*p*b*S,per);
      const fill=(th,t)=>{const x=radius*Math.cos(th),y=radius*Math.sin(th);xy[2*(i*m+t)]=x;xy[2*(i*m+t)+1]=y;};
      if(per<SAFE){const P=Number(per),D=Number(dStep),dn=Number(den);let r=Number(r0);
        for(let t=0;t<m;t++){fill(Math.PI*(r/dn),t);r+=D;if(r>=P)r-=P;}}
      else{let r=r0;for(let t=0;t<m;t++){fill(Math.PI*num({n:r,d:den}),t);r+=dStep;if(r>=per)r-=per;}}
      if(!Number.isFinite(radius))nonFinite++;
      cellS[i]=s;cellN[i]=Number(N);rad[i]=radius;const ar=Math.abs(radius);if(ar>maxR)maxR=ar;i++;}}
  return {key:key(st,R),lattice:L,m,offsets:cN,xy,cellS,cellN,rad,maxRadius:maxR,nonFinite,zeroAmplitude:r6===0,n:L.cells*m};
}
// the exact recurrence of build() for one cell, BigInt only: residues r_t/(b*q*N) in [0, 2) of every tooth, offset order (checked against comb-core teeth() in test-v049)
function residues(st,s,phi3){
  const R=C.resolve(st),m=R.m,offs=C.offsets(m),a=R.t1.n,b=R.t1.d,p=R.t2.n,q=R.t2.d,S=BigInt(s),N=R.B+1n-BigInt(phi3);if(N<=0n)return null;
  const den=b*q*N,per=2n*den,dStep=mod((m%2?1n:2n)*p*b*S,per);let r=mod(a*q*N*S+offs[0]*p*b*S,per);const o=[];
  for(let t=0;t<m;t++){o.push({c:offs[t],n:r,d:den});r+=dStep;if(r>=per)r-=per;}return o;
}
// exact phase of one stack point through comb-core teeth() (the reference the fast path is checked against): reduced rational in (-1, 1], units of pi
function exactPhase(st,s,phi3,c){
  const t=C.teeth({...st,nMode:'integer',phi3:String(phi3),sTyped:String(s)}).find(x=>Number(x.c)===Number(c));return t?t.phase:null;
}
// evenly selected indices (host selectHeadIndices L5082): floor(i*(L-1)/(max-1)) for i < max when L > max
function selectIndices(len,max){if(len<=max){const o=new Array(len);for(let i=0;i<len;i++)o[i]=i;return o;}const o=new Array(max);for(let i=0;i<max;i++)o[i]=Math.floor(i*(len-1)/(max-1));return o;}
// S3 lift of the stack (Clifford tab): each point's own leaf rho_N = |n6|*N^alpha, z1 = a e^{i pi (t1 s + f)}, z2 = b e^{i pi off}, off = -c t2 s / N (exact residues), stereographic
// projection from x4 = +1 as comb-numeric stereo(). Budget: LIFT_CAP - m heads (the host's 12,000-head budget less the current teeth), host head selection.
function lift(st,P,stereo){
  const R=C.resolve(st),m=P.m,offs=C.offsets(m),a=R.t1.n,b=R.t1.d,p=R.t2.n,q=R.t2.d,flip=R.n6.n<0n?b:0n;
  const budget=LIFT_CAP-m,idx=selectIndices(P.n,budget),xyz=new Float64Array(3*idx.length),ok=new Uint8Array(idx.length),cs=new Int32Array(idx.length);
  let bad=0,inf=0,levels=new Set();
  idx.forEach((g,j)=>{const cell=Math.floor(g/m),t=g%m,S=BigInt(P.cellS[cell]),N=BigInt(P.cellN[cell]),c=offs[t];
    const rho=Math.abs(P.rad[cell]),A=rho/Math.sqrt(1+rho*rho),B=1/Math.sqrt(1+rho*rho);levels.add(rho);
    const car=mod(a*S+flip,2n*b),off=mod(-c*p*S,2n*q*N);
    const u=Math.PI*num({n:car,d:b}),v=Math.PI*num({n:off,d:q*N});
    const pr=stereo({re:A*Math.cos(u),im:A*Math.sin(u)},{re:B*Math.cos(v),im:B*Math.sin(v)},rho===0&&2n*off===q*N);   // exact north pole (x4 = +1): rho = 0 and off = 1/2, as comb-numeric compute()
    cs[j]=Number(c);if(pr.vector){xyz[3*j]=pr.vector[0];xyz[3*j+1]=pr.vector[1];xyz[3*j+2]=pr.vector[2];ok[j]=1;}else{bad++;if(pr.status==='AT_INFINITY')inf++;}});
  return {n:idx.length,raw:P.n,budget,thinned:P.n>budget,xyz,ok,c:cs,bad,atInfinity:inf,levels:levels.size};
}
// fraction stack in the plane (Fourier, Hopf): the heads of fraction-stack-core (current shell, s = j/q, certified exact phases) as planar teeth z_c = radius*e^{i pi k_c s/N}
function fractionPlane(st,heads,radius){
  const R=C.resolve(st);
  return heads.map(h=>{const k=X.add(X.mul(R.Nq,R.t1),X.mul(X.rat(h.c),R.t2)),ph=C.phaseRep(X.div(X.mul(k,h.s),R.Nq)),th=Math.PI*num(ph);
    return {c:h.c,j:h.j,zero:h.spreadZero,re:radius*Math.cos(th),im:radius*Math.sin(th)};});
}
// v0.4.11 (SCHEMA_ADDENDUM_19) reciprocal winding (throat at 1/1): the other half of the full stack, its image under w -> 1/conj(w) (inversion in |z| = 1).
// 1/conj(z) = z/|z|^2, so the phase is kept (exact residues unchanged) and the radius n6*N^alpha becomes 1/(n6*N^alpha). A point with radius 0 (n6 = 0) has no image (NaN, counted).
const RECIP=new WeakMap();
function reciprocal(P){
  let r=RECIP.get(P);if(r)return r;
  const m=P.m,nc=P.lattice.cells,xy=new Float64Array(2*nc*m);let undef=0,maxR=0,minR=Infinity;
  for(let i=0;i<nc;i++){const rad=P.rad[i],q=rad*rad,ok=Number.isFinite(q)&&q>0&&Number.isFinite(1/q);
    for(let t=0;t<m;t++){const j=2*(i*m+t);if(ok){xy[j]=P.xy[j]/q;xy[j+1]=P.xy[j+1]/q;}else{xy[j]=NaN;xy[j+1]=NaN;undef++;}}
    if(ok){const a=1/Math.abs(rad);if(a>maxR)maxR=a;if(a<minR)minR=a;}}
  r={xy,undef,maxRadius:maxR,minRadius:minR===Infinity?0:minR,n:P.n};RECIP.set(P,r);return r;
}
// S3 lift of one half with an explicit head budget (recip: leaf 1/rho_N, amplitudes swapped, phases kept). Same arithmetic as lift().
function liftHalf(st,P,stereo,recip,budget){
  const R=C.resolve(st),m=P.m,offs=C.offsets(m),a=R.t1.n,b=R.t1.d,p=R.t2.n,q=R.t2.d,flip=R.n6.n<0n?b:0n;
  const idx=selectIndices(P.n,budget),xyz=new Float64Array(3*idx.length),ok=new Uint8Array(idx.length),cs=new Int32Array(idx.length);
  let bad=0,inf=0,undef=0,levels=new Set();
  idx.forEach((g,j)=>{const cell=Math.floor(g/m),t=g%m,S=BigInt(P.cellS[cell]),N=BigInt(P.cellN[cell]),c=offs[t];cs[j]=Number(c);
    let rho=Math.abs(P.rad[cell]);if(recip){if(!(rho>0)||!Number.isFinite(1/rho)){undef++;return;}rho=1/rho;}
    const A=rho/Math.sqrt(1+rho*rho),B=1/Math.sqrt(1+rho*rho);levels.add(rho);
    const car=mod(a*S+flip,2n*b),off=mod(-c*p*S,2n*q*N);
    const u=Math.PI*num({n:car,d:b}),v=Math.PI*num({n:off,d:q*N});
    const pr=stereo({re:A*Math.cos(u),im:A*Math.sin(u)},{re:B*Math.cos(v),im:B*Math.sin(v)},!recip&&rho===0&&2n*off===q*N);
    if(pr.vector){xyz[3*j]=pr.vector[0];xyz[3*j+1]=pr.vector[1];xyz[3*j+2]=pr.vector[2];ok[j]=1;}else{bad++;if(pr.status==='AT_INFINITY')inf++;}});
  return {n:idx.length,raw:P.n,budget,thinned:P.n>budget,xyz,ok,c:cs,bad,atInfinity:inf,undef,levels:levels.size,recip:!!recip};
}
const api={GRID_CAP,LIFT_CAP,key,lattice,build,residues,exactPhase,selectIndices,lift,fractionPlane,reciprocal,liftHalf};
if(typeof module!=='undefined'&&module.exports)module.exports=api;else root.FVStack=api;
})(typeof globalThis!=='undefined'?globalThis:this);
