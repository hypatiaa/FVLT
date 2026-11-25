(function(root){
'use strict';
// fv-fraction-stack-core 0.1.0: EXACT register. Lattice, gates, spread-zero columns and even head selection for the
// Clifford-tab fraction stack (addendum 3; host v0.8.7-fix.1). The full raw set is never materialised.
const X=typeof module!=='undefined'&&module.exports?require('../exact-lib/exact-lib-0.2.0.js'):root.FVExact;
const C=typeof module!=='undefined'&&module.exports?require('./comb-core.js'):root.FVCombCore;
const MAX_HEADS=4000,MAX_ORDER=60n;
// -> {idle:true,reason} or {idle:false,q,source,span,columns,raw}
function lattice(st){
  const R=C.resolve(st);
  if(R.Nq.n<=0n)return {idle:true,reason:'no current shell'};
  if(!R.Nint)return {idle:true,reason:C.BETWEEN(R.Nq)};   // addendum 8: the stack's gates assume an integer shell N; between shells it is idle with the label
  if(!X.isInt(R.t1)||!X.isInt(R.t2)||R.t1.n===0n||R.t2.n===0n)return {idle:true,reason:'integer gearbox required for the certified fraction-stack register'};
  const s=X.parse(st.sTyped);let q,source;
  if(s.d>1n){q=s.d;source='slider lattice';}
  else{
    const mt=BigInt(R.m)*(R.t2.n<0n?-R.t2.n:R.t2.n),g=X.gcd(R.m%2?2n*R.N:R.N,mt);q=mt/g;
    if(q===1n)return {idle:true,reason:'this shell’s spread stops are integers — the full stack already carries them'};
    source='shell spread lattice (integer spin)';
  }
  if(q>MAX_ORDER)return {idle:true,reason:'lattice ζ_'+q+' beyond draw cap '+MAX_ORDER};
  const span=R.B+1n,columns=q*span+1n,raw=columns*BigInt(R.m);
  return {idle:false,q,source,span,columns,raw};
}
// exact spread-zero test at s: x = t2*s/N;  odd m: m*x/2 in Z and x/2 not in Z;  even m: m*x in Z and x not in Z
function spreadZero(s,N,m,t2){
  const x=X.div(X.mul(t2,s),X.rat(N));
  if(m%2){const h=X.div(x,X.rat(2n));return X.isInt(X.mul(X.rat(BigInt(m)),h))&&!X.isInt(h);}
  return X.isInt(X.mul(X.rat(BigInt(m)),x))&&!X.isInt(x);
}
// evenly selected raw indices: floor(i*raw/max) for i < min(raw,max); j outer, c inner
function selectIndices(raw,max=MAX_HEADS){
  const n=raw<BigInt(max)?Number(raw):max,out=[];
  if(raw<=BigInt(max)){for(let i=0;i<n;i++)out.push(BigInt(i));return out;}
  for(let i=0;i<n;i++)out.push(BigInt(i)*raw/BigInt(max));return out;
}
// the heads: [{j,c,s (rational),spreadZero}] -- only the selected specs are built
function heads(st){
  const L=lattice(st);if(L.idle)return {lattice:L,heads:[]};
  const R=C.resolve(st),offs=C.offsets(R.m),idx=selectIndices(L.raw),zeroCache=new Map();
  const out=idx.map(i=>{const j=i/BigInt(R.m),c=offs[Number(i%BigInt(R.m))],s=X.rat(j,L.q);
    let z=zeroCache.get(j);if(z===undefined){z=spreadZero(s,R.N,R.m,R.t2);zeroCache.set(j,z);}
    return {j,c,s,spreadZero:z};});
  return {lattice:L,heads:out};
}
function caption(st,long){                                // short caption for the surface; long=true adds the provenance clauses
  const L=lattice(st);if(L.idle)return 'fraction stack idle — '+L.reason;
  const n=L.raw<BigInt(MAX_HEADS)?L.raw:BigInt(MAX_HEADS);
  return 'fraction stack s ∈ (1/'+L.q+')·ℤ · '+(long?L.source+' · current shell · ':'')+n+'/'+L.raw+' heads · spread-zero columns bright'+(long?' · display only, excluded from teeth, orbits, Hopf tab and exports':'');
}
const api={MAX_HEADS,MAX_ORDER,lattice,spreadZero,selectIndices,heads,caption};
if(typeof module!=='undefined'&&module.exports)module.exports=api;else root.FVFractionStack=api;
})(typeof globalThis!=='undefined'?globalThis:this);
