(function(root){
'use strict';
// fv-gearbox-core 0.1.0: EXACT register. Port of v0.3.2 gearbox.js analyze() (logic ported, not copied).
// Input: plain BigInt/string values {shellMode, n1, m, phi3, B}  (B already resolved). Output: BigInt facts and labels.
const gcd=(a,b)=>{while(b){const t=a%b;a=b;b=t;}return a;};
const mod=(a,m)=>((a%m)+m)%m;
function analyze(v){
  const n1=BigInt(v.n1),m=BigInt(v.m),g=BigInt(v.phi3),B=BigInt(v.B),factorial=v.shellMode==='factorial';
  if(m<2n||m>720n||g<0n||g>B+1n)throw Error('Shell or gear outside the supported domain.');
  const N=B+1n-g,first=(B+1n)%m;
  let phi=0n;for(let k=1n;k<m;k++)if(gcd(k,m)===1n)phi++;
  const defect=m-1n-phi,prime=defect===0n,eligible=N>0n&&factorial&&m===n1+1n&&g===0n;
  const remainder=N>0n?N%m:null,resident=N>0n?remainder===0n:null,stride=resident?N/m:null;
  const agreement=eligible?prime===resident:null;
  let code='DEGENERATE_AMBIENT_HOLD',label='N = 0: no cyclic ambient group or resident cycle.',tone='hold';
  if(N>0n){
    if(eligible&&agreement!==true){code='WILSON_INCONSISTENT_HOLD';label='Wilson consistency failure: hold.';}
    else if(eligible&&prime&&resident){code='WILSON_PRIME_RESIDENT';tone='wilson';label='Wilson prime witness: m = '+m+' divides '+n1+'! + 1 = '+N+'.';}
    else if(eligible&&!prime&&!resident){code='WILSON_COMPOSITE_EXCLUDED';tone='neutral';label='Wilson composite exclusion: m = '+m+' does not divide '+n1+'! + 1 = '+N+'.';}
    else if(resident){code=prime?'PRIME_RESIDENT_OFF_WILSON':'COMPOSITE_RESIDENT';tone='resident';label='Resident cycle: m = '+m+' divides N = '+N+'. Off the Wilson setting, residency alone is not a primality witness.';}
    else{code=prime?'PRIME_NOT_RESIDENT':'COMPOSITE_NOT_RESIDENT';tone='neutral';label='Not resident: N mod m = '+remainder+'. No resident cycle.';}
  }
  const nextDelta=mod(first-g,m)||m,previousDelta=mod(g-first,m)||m;
  const next=g+nextDelta<=B?g+nextDelta:null,previous=g-previousDelta>=0n?g-previousDelta:null;
  const signature=factorial&&m===n1+1n?(prime&&first===0n?'WILSON_PRIME_ZERO':m===4n&&first===3n?'P4_EXCEPTION_THREE':m>=6n&&!prime&&first===1n?'COMPOSITE_ONE':'GENERAL_GEARBOX'):'GENERAL_GEARBOX';
  return {B,N,n1,m,g,phi,defect,prime,first,remainder,resident,stride,eligible,agreement,code,label,tone,previous,next,signature};
}
// v0.3 (addendum 8): between shells (N = p/q, q > 1) the gearbox has no residency: no shell N, no N mod m, no gear g. Only the m-only facts
// (phi(m), defect, primality of m) and the B-only first resident gear (B + 1) mod m are stated; every residency field is null and the code is BETWEEN_SHELLS.
// `label` is the between-shells label passed in by comb-core (one wording everywhere).
function between(v){
  const n1=BigInt(v.n1),m=BigInt(v.m),B=BigInt(v.B),factorial=v.shellMode==='factorial';
  if(m<2n||m>720n)throw Error('Shell or gear outside the supported domain.');
  let phi=0n;for(let k=1n;k<m;k++)if(gcd(k,m)===1n)phi++;
  const defect=m-1n-phi,prime=defect===0n,first=(B+1n)%m;
  return {B,N:null,n1,m,g:null,phi,defect,prime,first,remainder:null,resident:null,stride:null,eligible:false,agreement:null,
    code:'BETWEEN_SHELLS',label:String(v.label),tone:'hold',previous:null,next:null,signature:null,betweenShells:true};
}
const api={analyze,between};
if(typeof module!=='undefined'&&module.exports)module.exports=api;else root.FVGearbox=api;
})(typeof globalThis!=='undefined'?globalThis:this);
