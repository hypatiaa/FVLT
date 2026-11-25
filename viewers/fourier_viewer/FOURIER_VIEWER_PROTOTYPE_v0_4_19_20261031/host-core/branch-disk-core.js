(function(root){
'use strict';
// fv-branch-disk-core 0.1.0 (v0.4.10, SCHEMA_ADDENDUM_18): EXACT register only. BigInt and exact rationals from exact-lib; no Number arithmetic sources any statement here.
//  (1) primitivity(st): "Branch primitivity (trial division)": N prime <=> every branch c = 2..floor(sqrt N) is primitive (g_c = 1), read off orbit-core.branches
//      at gears (1,1) on an odd comb that contains c = 2..floor(sqrt N). Display only; a summary of the Clifford chips.
//  (2) disk(st): the exact data of the Poincare disk card: Cayley images of the cusps of the shell's Farey layer F(a) (kernel Lemma II.5g, Def II.5h),
//      the contact edges (centre in Q(i), radius in Q), and Astra's orbit points zeta = (k - m - 2n i)/(k + m + 2) for m | n^2 + 1 when N - 1 = n^2.
//  Neither enters the state, the address, the exact export or any tab.
const X=typeof module!=='undefined'&&module.exports?require('../exact-lib/exact-lib-0.2.0.js'):root.FVExact;
const C=typeof module!=='undefined'&&module.exports?require('./comb-core.js'):root.FVCombCore;
const O=typeof module!=='undefined'&&module.exports?require('./orbit-core.js'):root.FVOrbit;
const SH=typeof module!=='undefined'&&module.exports?require('./shell-core.js'):root.FVShell;
const REPEAT_LINES=8,MISSING_LINES=12,CUSP_LINES=12,EDGE_LINES=8,ORBIT_LINES=14,MATRIX_CAP=1000000n,F_CAP=4000;
const babs=n=>n<0n?-n:n,gcd=X.gcd,isqrt=X.isqrt,MINUS='−';
const one=X.rat(1n);
// ------------------------------------------------------------------ (1) branch primitivity
function primitivity(st){
  const R=C.resolve(st),out={applies:false,reason:'',N:null,r:null,n:null,quadratic:false,rows:[]};
  if(R.Nq.n<=0n){out.reason=R.Nq.n===0n?'N = 0: no shell, no branch windings.':'N ≤ 0: no shell, no branch windings.';return out;}
  if(!R.Nint){out.reason='N = '+X.text(R.Nq)+' is not an integer (between shells): the branch windings have no trial-division reading.';return out;}
  const N=R.N;out.N=N;out.r=isqrt(N);
  const q=N-1n,rq=isqrt(q);if(q>=1n&&rq*rq===q){out.quadratic=true;out.n=rq;}
  if(X.cmp(R.t1,one)!==0||X.cmp(R.t2,one)!==0){
    out.reason='gears are (t₁, t₂) = ('+X.text(R.t1)+', '+X.text(R.t2)+'), not (1, 1): the branch multiplicity is g_c = gcd(L·N·t₁, L·c·t₂), which equals gcd(N, c) for every c only at t₁ = t₂ = 1; no verdict.';return out;}
  if(R.m%2===0){out.reason='m = '+R.m+' is even: the comb has only odd offsets (±1, ±3, …), so the even branches c = 2, 4, … are absent and a verdict would be wrong (at N = 26, m = 8 every shown branch is ×1 although 2 | 26); no verdict. Use an odd m ≥ 2·⌊√N⌋ + 1.';return out;}
  if(N===1n){out.reason='N = 1 is neither prime nor composite; the range c = 2…⌊√N⌋ is empty.';return out;}
  const half=BigInt((R.m-1)/2);
  if(out.r>half){const miss=[];for(let c=(half+1n>2n?half+1n:2n);c<=out.r;c++)miss.push(c);
    out.missing=miss;out.reason='m = '+R.m+' is too small: comb(m) = {−'+half+', …, '+half+'} lacks the branches c = '+miss.slice(0,MISSING_LINES).join(', ')+(miss.length>MISSING_LINES?', … ('+(miss.length-MISSING_LINES)+' more, up to '+out.r+')':'')+' needed for ⌊√N⌋ = '+out.r+'; no verdict. Use m ≥ '+(2n*out.r+1n)+' (odd).';return out;}
  out.applies=true;
  const br=O.branches(st),byC=new Map(br.map(b=>[b.c,b]));
  for(let c=2n;c<=out.r;c++){const b=byC.get(c);out.rows.push({c,g:b.commonFactor,primitive:b.primitive,type:b.canonicalType,chip:O.chipText(b),repeated:b.commonFactor>1n,unknot:b.canonicalType==='UNKNOT'});}
  out.total=out.rows.length;out.primitiveCount=out.rows.filter(x=>!x.repeated).length;out.repeatedRows=out.rows.filter(x=>x.repeated);
  out.formAllPrimitive=out.repeatedRows.length===0;out.formNoUnknot=!out.rows.some(x=>x.unknot);out.formsAgree=out.formAllPrimitive===out.formNoUnknot;
  out.prime=out.formAllPrimitive;out.least=out.prime?null:out.repeatedRows[0];
  const pm=byC.get(1n),mm=byC.get(-1n),z=byC.get(0n);
  out.unit={plus:pm?O.chipText(pm):null,minus:mm?O.chipText(mm):null};out.zero=z?{g:z.commonFactor,chip:O.chipText(z)}:null;
  out.n6zero=R.n6.n===0n;
  return out;
}
// ------------------------------------------------------------------ (2) the Poincare disk data
const fmtG=(P,Q,D)=>{let g=gcd(gcd(babs(P),babs(Q)),D);if(g===0n)g=1n;P/=g;Q/=g;D/=g;
  const sP=x=>(x<0n?MINUS:"")+babs(x),body=Q===0n?sP(P):P===0n?(Q<0n?MINUS:'')+(babs(Q)===1n?'':babs(Q))+'i':sP(P)+' '+(Q<0n?MINUS:'+')+' '+(babs(Q)===1n?'':babs(Q))+'i';
  return D===1n?body:(Q===0n||P===0n?body:'('+body+')')+'/'+D;};
// Cayley image of the cusp p/q (z - i)/(z + i): ((p^2 - q^2) - 2pq i)/(p^2 + q^2), a point of the unit circle in Q(i)
function cusp(p,q){const D=p*p+q*q;return {p,q,re:p*p-q*q,im:-2n*p*q,den:D,text:fmtG(p*p-q*q,-2n*p*q,D)};}
// Farey edge between a/b and c/d (|ad - bc| = 1): centre (a - ib)(c - id)/s, s = ac + bd, radius 1/|s|; s = 0: a diameter
function edge(a,b,c,d){
  if(babs(a*d-b*c)!==1n)throw Error('not a Farey pair');
  const s=a*c+b*d;if(s===0n)return {diameter:true,s,text:'diameter'};
  return {diameter:false,s,cre:a*c-b*d,cim:-(a*d+b*c),den:s,rad:[1n,babs(s)],ctext:fmtG(a*c-b*d,-(a*d+b*c),s),rtext:'1/'+babs(s)};
}
function profile(N){const f=SH.factor(N),out=[];for(const [p,e] of f)out.push([p,BigInt(e)]);out.sort((x,y)=>x[0]<y[0]?-1:x[0]>y[0]?1:0);return out;}
// F(a) (Lemma II.5g): reduced e/n_i, 1 <= e <= n_i - 1, n_i = a_i + 1 the orders of the exponent profile of N
function fareyF(N){
  const prof=profile(N),seen=new Map();
  for(const [,e] of prof){const n=e+1n;for(let k=1n;k<n;k++){const g=gcd(k,n),p=k/g,q=n/g,key=p+'/'+q;if(!seen.has(key))seen.set(key,[p,q]);}}
  const F=[...seen.values()].sort((x,y)=>{const l=x[0]*y[1],r=y[0]*x[1];return l<r?-1:l>r?1:0;});
  return {prof,F};
}
// contact edges of G_ph (Def II.5h): |a s - c q| = 1; isolated phase beads have degree zero
function contactGraph(F){
  const E=[],deg=F.map(()=>0);
  for(let i=0;i<F.length;i++)for(let j=i+1;j<F.length;j++){if(babs(F[i][0]*F[j][1]-F[j][0]*F[i][1])===1n){E.push([i,j]);deg[i]++;deg[j]++;}}
  return {E,deg,isolated:deg.filter(x=>x===0).length};
}
// matrix (a b; c d) in SL(2, Z) with gamma i = (n + i)/m: m = c^2 + d^2 (primitive), a = (n c + d)/m, b = (n d - c)/m
function orbitMatrix(n,m){
  if(m>MATRIX_CAP)return null;const lim=isqrt(m);
  for(let c=0n;c<=lim;c++){const d2=m-c*c,d=isqrt(d2);if(d*d!==d2||gcd(c,d)!==1n)continue;
    for(const [cc,dd] of [[c,d],[c,-d],[-c,d],[-c,-d],[d,c],[d,-c],[-d,c],[-d,-c]]){
      if((n*cc+dd)%m===0n&&(n*dd-cc)%m===0n){const a=(n*cc+dd)/m,b=(n*dd-cc)/m;if(a*dd-b*cc===1n&&a*cc+b*dd===n)return [a,b,cc,dd];}}}
  return null;
}
// Astra's points: zeta = (k - m - 2n i)/(k + m + 2), cosh d(0, zeta) = (k + m)/2, for every divisor m of N = n^2 + 1, k = N/m
function orbit(N){
  const q=N-1n,n=isqrt(q);if(q<1n||n*n!==q)return {square:false};
  const pts=SH.divisors(N).map(m=>{const k=N/m,D=k+m+2n,mat=orbitMatrix(n,m);
    return {m,k,re:k-m,im:-2n*n,den:D,text:fmtG(k-m,-2n*n,D),cosh:X.rat(k+m,2n),coshText:X.text(X.rat(k+m,2n)),norm2:[k+m-2n,D],matrix:mat,
      edgeCusps:mat?[[mat[0],mat[2]],[mat[1],mat[3]]]:null};});
  return {square:true,n,pts};
}
function disk(st){
  const R=C.resolve(st),out={idle:false,reason:''};
  if(R.Nq.n<=0n){out.idle=true;out.reason=R.Nq.n===0n?'N = 0: no shell.':'N ≤ 0: no shell.';return out;}
  if(!R.Nint){out.idle=true;out.reason='between shells: shell arithmetic undefined (N = '+X.text(R.Nq)+').';return out;}
  const N=R.N;out.N=N;
  const {prof,F}=fareyF(N);out.prof=prof;out.F=F;
  if(F.length>F_CAP){out.farey={refused:true,reason:'|F(a)| = '+F.length+' exceeds the draw cap '+F_CAP+'.'};out.F=[];}
  const G=contactGraph(out.F);out.G=G;
  out.cusps=out.F.map(([p,q])=>cusp(p,q));
  out.edges=G.E.map(([i,j])=>({i,j,e:edge(out.F[i][0],out.F[i][1],out.F[j][0],out.F[j][1])}));
  out.orbit=orbit(N);
  return out;
}
const api={REPEAT_LINES,MISSING_LINES,CUSP_LINES,EDGE_LINES,ORBIT_LINES,MATRIX_CAP,F_CAP,primitivity,cusp,edge,profile,fareyF,contactGraph,orbitMatrix,orbit,disk,fmtG};
if(typeof module!=='undefined'&&module.exports)module.exports=api;else root.FVBranchDisk=api;
})(typeof globalThis!=='undefined'?globalThis:this);
