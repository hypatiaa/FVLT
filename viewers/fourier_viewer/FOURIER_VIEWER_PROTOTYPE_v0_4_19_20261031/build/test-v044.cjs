'use strict';
// v0.4.4 unit test (SCHEMA_ADDENDUM_12): CA presets and the Robin readout. Node only. Exact statements use BigInt here, independently of ca-core.
const C=require('../host-core/comb-core.js'),A=require('../host-core/ca-core.js'),RH=require('../host-core/rhm-core.js'),fs=require('fs'),path=require('path'),crypto=require('crypto');
let pass=0,fail=0;const t=(n,f)=>{let ok=false,x='';try{const r=f();ok=r===true||(r&&r.ok===true);if(r&&r.note)x=' '+r.note;}catch(e){x=' threw '+e.message;}console.log((ok?'PASS ':'FAIL ')+n+x);ok?pass++:fail++;};
const gcd=(a,b)=>{while(b)[a,b]=[b,a%b];return a;};
const PR=[];{const s=new Uint8Array(2001);for(let i=2;i<=2000;i++){if(!s[i]){PR.push(BigInt(i));for(let j=i*i;j<=2000;j+=i)s[j]=1;}}}
function factor(n){const f=[];for(const p of PR){if(p*p>n)break;let e=0;while(n%p===0n){n/=p;e++;}if(e)f.push([p,e]);}if(n>1n)f.push([n,1]);return f;}
const sigp=(p,a)=>a===0?1n:(p**BigInt(a+1)-1n)/(p-1n);
// ---- CA membership, exact from the definition (Alaoglu-Erdos): n is CA iff some eps>0 has sigma(n)/n^(1+eps) >= sigma(k)/k^(1+eps) for ALL k.
// f_eps(k)=sigma(k)/k^(1+eps) is multiplicative, so it is maximised prime by prime: g_p(a)=sigma(p^a)/p^(a(1+eps)). With eps=u/v,
// g_p(a) >= g_p(b)  <=>  sigma(p^a)^v * p^(b(v+u)) >= sigma(p^b)^v * p^(a(v+u))   (integers).
// Finite check. sigma(p^a)/p^a < p/(p-1), so g_p(a) < (p/(p-1)) p^(-a eps) <= 1 = g_p(0) as soon as p^(a eps) >= p/(p-1), i.e. p^(a u) (p-1)^v >= p^v.
// (i) p^(eps)(1-1/p) is increasing in p for eps>0, so from the first P with p^u (p-1)^v >= p^v every prime p>=P has g_p(a)<1 for all a>=1: its exponent must be 0.
// (ii) for p<P, every a>=a0 (the least a with the inequality) has g_p(a)<1=g_p(0), so a maximiser has exponent < a0, and we compare n's exponent with every b in 0..a0.
function witnessOK(n,u,v){
  const fac=new Map(factor(n)),U=BigInt(u),V=BigInt(v);
  let P=2n;while(!(P**U*(P-1n)**V>=P**V))P++;
  if(P>BigInt(PR[PR.length-1]))throw Error('prime table too short for P='+P);
  for(const q of fac.keys())if(q>=P)return false;
  for(const p of PR){
    if(p>=P)break;
    let a0=1;while(!(p**(BigInt(a0)*U)*(p-1n)**V>=p**V))a0++;
    const e=fac.get(p)||0;if(e>=a0)return false;
    for(let b=0;b<=a0;b++)if(!(sigp(p,e)**V*p**(BigInt(b)*(V+U))>=sigp(p,b)**V*p**(BigInt(e)*(V+U))))return false;
  }
  return true;
}
const search=n=>{for(let v=1;v<=60;v++)for(let u=1;u<=v*3;u++){if(gcd(BigInt(u),BigInt(v))!==1n)continue;if(witnessOK(n,u,v))return [u,v];}return null;};
const found={};
t('every CA preset is colossally abundant: an exact rational witness eps=u/v exists (checked from the definition, per prime, in integers)',()=>{
  for(const B of A.CA_PRESETS){const w=search(B);if(!w)return {ok:false,note:'no witness for '+B};found[B]=w;}
  return {ok:true,note:Object.entries(found).map(([b,[u,v]])=>b+':eps='+u+'/'+v).join(' ')};});
t('control: the checker is not vacuous - 4, 8, 24, 36, 720, 5039, 10080, 1441441 have no witness in the same search',()=>{
  for(const n of [4n,8n,24n,36n,720n,5039n,10080n,1441441n])if(search(n))return {ok:false,note:'false witness for '+n};return true;});
t('at each witnessed eps the maximiser built prime by prime from g_p is a preset (cross-check of the witness search; ties resolve upward)',()=>{
  const out=[];
  for(const B of A.CA_PRESETS){const [u,v]=found[B],U=BigInt(u),V=BigInt(v);let n=1n;
    for(const p of PR){let a0=1;while(!(p**(BigInt(a0)*U)*(p-1n)**V>=p**V))a0++;let best=0;
      for(let b=1;b<a0;b++)if(sigp(p,b)**V*p**(BigInt(best)*(V+U))>=sigp(p,best)**V*p**(BigInt(b)*(V+U)))best=b;
      if(best===0)break;n*=p**BigInt(best);}
    out.push(n);if(!A.isPreset(n))return {ok:false,note:'maximiser '+n+' for '+B};}
  return {ok:true,note:'maximisers '+out.join(',')};});
// ---- exact sigma(B)/B, hand values
const HAND={2:'3/2',6:'2',12:'7/3',60:'14/5',120:'3',360:'13/4',2520:'26/7',5040:'403/105',55440:'1612/385',720720:'248/55'};
t('sigma(B)/B exact and reduced, equal to the hand values for all ten presets; sigma(5040)=19344, 19344/5040 = 403/105',()=>{
  for(const B of A.CA_PRESETS){const r=A.robinReadout(B);if(r.sigmaOverB!==HAND[B])return {ok:false,note:B+' got '+r.sigmaOverB};
    let s=1n;for(const [p,a] of factor(B))s*=sigp(p,a);const g=gcd(s,B),q=(B/g===1n)?(s/g)+'':(s/g)+'/'+(B/g);if(q!==HAND[B])return {ok:false,note:'independent sigma '+B+' '+q};}
  let s=1n;for(const [p,a] of factor(5040n))s*=sigp(p,a);return s===19344n&&19344n*105n===403n*5040n;});
// ---- threshold + margin sign (numerical, stated tolerance)
const GAMMA=0.5772156649015329,fl=s=>parseFloat(s.replace('−','-')),iv=s=>s.slice(1,-1).split(', ').map(fl);
t('threshold enclosure contains Math.exp(gamma)*Math.log(Math.log(B)) up to 1e-9 (floating point only as cross-check; the shown value is the BigInt enclosure)',()=>{
  for(const B of A.CA_PRESETS){const r=A.robinReadout(B),[lo,hi]=iv(r.thresholdText),f=Math.exp(GAMMA)*Math.log(Math.log(Number(B)));if(!(f>=lo-1e-9&&f<=hi+1e-9))return {ok:false,note:B+' '+r.thresholdText+' vs '+f};}return true;});
const TABLE=[];
t('margin = sigma(B)/B minus threshold (to 2e-6); negative means Robin holds: fails at 2,6,12,60,120,360,2520,5040; holds at 55440 and 720720',()=>{
  for(const B of A.CA_PRESETS){const r=A.robinReadout(B),v=Number(r.value.n)/Number(r.value.d),[mlo,mhi]=iv(r.marginText),[tlo,thi]=iv(r.thresholdText);
    if(Math.abs(mlo-(v-thi))>2e-6||Math.abs(mhi-(v-tlo))>2e-6)return {ok:false,note:'margin '+B};
    const want=B>=55440n?'holds':'fails';if(r.verdict!==want||(want==='holds')!==(mhi<0)||(want==='fails')!==(mlo>=0))return {ok:false,note:B+' '+r.verdict+' '+r.marginText};
    TABLE.push([B,r.sigmaOverB,r.thresholdText,r.marginText,r.verdict]);}return true;});
console.log('TABLE B | sigma(B)/B | threshold | margin | verdict\n'+TABLE.map(r=>r.join(' | ')).join('\n'));
t('caution line says particular numbers only, nothing about the general case or RH',()=>/particular numbers only/.test(A.CAUTION)&&/general case/.test(A.CAUTION)&&/RH/.test(A.CAUTION)&&A.robinReadout(5040).caution===A.CAUTION);
t('rhm-core.js is a byte copy of the accepted panel module (sha256 2a483c04...)',()=>crypto.createHash('sha256').update(fs.readFileSync(path.join(__dirname,'..','host-core','rhm-core.js'))).digest('hex')==='2a483c04d35e6a41eafcfcedd717716e7299f2bd743ed084562b5ab92cd4fe62');
t('record agrees with the accepted builder: 5040 carries the boundary note and side ABOVE; 55440 side BELOW',()=>{
  const r=RH.buildAtom({B:'5040',mode:'direct',factorial_index:null,precision_bits:'64'});return r.c1.boundary_note===RH.BOUNDARY_NOTE_5040&&r.c1.side==='ABOVE'&&RH.buildAtom({B:'55440',mode:'direct',factorial_index:null,precision_bits:'64'}).c1.side==='BELOW';});
// ---- factorial coincidence: 2=2!, 6=3!, 120=5!, 5040=7!
const ser=o=>JSON.stringify(o,(k,v)=>typeof v==='bigint'?v+'n':v);
t('where CA equals a factorial (2,6,120,5040) the CA state equals the n! state in every key except shellMode, and resolve() is identical',()=>{
  for(const [n1,B] of [[2,2],[3,6],[5,120],[7,5040]])for(const [phi3,m] of [['1',String(n1+1)],['0','3'],['1','2']]){
    const f=C.initial({shellMode:'factorial',n1:String(n1),phi3,m}),i=C.initial({shellMode:'integer',n1:String(n1),B:String(B),phi3,m});
    const d=Object.keys(f).filter(k=>ser(f[k])!==ser(i[k]));if(d.join()!=='shellMode')return {ok:false,note:'differs '+d};
    if(ser(C.resolve(f))!==ser(C.resolve(i)))return {ok:false,note:'resolve differs'};}return true;});
t('readouts for those pairs: groups that differ between factorial and integer base are listed (info, not hidden)',()=>{
  const diffs=[];
  for(const [n1,B] of [[2,2],[3,6],[5,120],[7,5040]]){const f=C.initial({shellMode:'factorial',n1:String(n1),phi3:'0',m:String(n1+1)}),i=C.initial({shellMode:'integer',n1:String(n1),B:String(B),phi3:'0',m:String(n1+1)});
    const rf=C.readouts(f),ri=C.readouts(i);for(const k of new Set([...Object.keys(rf),...Object.keys(ri)]))if(ser(rf[k])!==ser(ri[k]))diffs.push(B+':'+k);}
  return {ok:true,note:'differing readout groups: '+(diffs.join(',')||'none')};});
console.log('\n'+pass+' passed, '+fail+' failed');process.exit(fail?1:0);
