'use strict';
// v0.4.2 tests (SCHEMA_ADDENDUM_10): (1) the N = 0 Wilson wording; (2) the shell-switch clamp (panel.js, tested in build/browser-check-v042.cjs;
// here only its source scope). Byte identity with the v0.4.1 modules (and the v0.4 modules) for every N != 0 state; at N = 0 the only differences
// are the Wilson fields, listed by exact field name. The v0.4.1 and v0.4 folders are read (require / readFileSync) and never written.
const fs=require('fs'),path=require('path');
const X=require('../exact-lib/exact-lib-0.2.0.js'),C=require('./comb-core.js'),O=require('./orbit-core.js'),NUM=require('./comb-numeric.js'),FS=require('./fraction-stack-core.js');
const P41='../../FOURIER_VIEWER_PROTOTYPE_v0_4_1_20261019/',P4='../../FOURIER_VIEWER_PROTOTYPE_v0_4_20261019/';
const C41=require(P41+'host-core/comb-core.js'),O41=require(P41+'host-core/orbit-core.js'),N41=require(P41+'host-core/comb-numeric.js'),FS41=require(P41+'host-core/fraction-stack-core.js');
const C4=require(P4+'host-core/comb-core.js'),O4=require(P4+'host-core/orbit-core.js'),N4=require(P4+'host-core/comb-numeric.js'),FS4=require(P4+'host-core/fraction-stack-core.js');
let pass=0,fail=0;
const t=(name,fn)=>{let ok=false,extra='';try{const r=fn();ok=r===true||(r&&r.ok===true);if(r&&r.note)extra=' '+r.note;}catch(e){extra=' threw '+e.message;}console.log((ok?'PASS ':'FAIL ')+name+extra);ok?pass++:fail++;};
const {rat,text}=X;
const NEW='N = 0: no comb, so the Wilson test does not apply.',OLD='N = 1 is not prime.';
const BJ=(k,v)=>typeof v==='bigint'?String(v)+'n':v;
// ---------------------------------------------------------------- state sets
// (a) the v0.4.1 test's 408-state preset grid plus 1,600 random states (same generator, same seed), copied from host-core/test-v041.cjs
const PRE=[];
for(const N of [2,3,4,5,6,7,8,9,10,11,12])for(const m of [2,3,4,5,6,7])for(const [t1,t2] of [['1','1'],['1/2','1'],['2','1/3'],['3/2','-3/2'],['-1','2'],['1','2/3']])
  PRE.push({shellMode:'integer',B:'24',nMode:'integer',phi3:String(25-N),m:String(m),t1,t2,n6:N%2?'1':'-1',alpha:N%3?'0':'1',sTyped:['0','1','7/3','-5/2'][(N+m)%4]});
for(const phi3 of ['7/2','89/4'])for(const m of [3,4,6])for(const [t1,t2] of [['1','1'],['1/2','3']])PRE.push({shellMode:'integer',B:'24',nMode:'continuous',phi3,m:String(m),t1,t2,n6:'1',alpha:'0',sTyped:'1/3'});
let seed=20261019;const rnd=()=>{seed=(seed*1103515245+12345)%2147483648;return seed/2147483648;},pick=a=>a[Math.floor(rnd()*a.length)];
for(let i=0;i<1600;i++){const fac=rnd()<0.5,n1=String(3+Math.floor(rnd()*4)),B=fac?null:String(2+Math.floor(rnd()*60));const Bv=fac?[6,24,120,720][Number(n1)-3]:Number(B);
  const cont=rnd()<0.3,phi3=cont?text(rat(BigInt(Math.floor(rnd()*4*(Bv+1))),4n)):String(Math.floor(rnd()*(Bv+2)));
  PRE.push({shellMode:fac?'factorial':'integer',n1,B:B||'24',nMode:cont?'continuous':'integer',phi3,m:String(2+Math.floor(rnd()*9)),t1:pick(['1','0','2','1/2','-3/2','1/3']),t2:pick(['1','0','-1','2','1/2','3/4']),n6:pick(['1','-1','0','2']),alpha:pick(['0','1','1/2','-1']),sTyped:pick(['0','1','-1','1/3','7/2','-5/4','12'])});}
// (b) the v0.4.1 test's B = 1, 2 set (every shell position, both N modes), copied from host-core/test-v041.cjs
const SMALL=[];
for(const sh of [{shellMode:'factorial',n1:'1'},{shellMode:'factorial',n1:'2'},{shellMode:'integer',B:'1'},{shellMode:'integer',B:'2'}]){
  const B=sh.shellMode==='factorial'?(sh.n1==='1'?1:2):Number(sh.B);
  const phis=[];for(let g=0;g<=B+1;g++)phis.push(['integer',String(g)]);for(let q=0;q<=4*(B+1);q++)phis.push(['continuous',text(rat(BigInt(q),4n))]);
  for(const [nMode,phi3] of phis)for(const m of ['2','3','4','5'])for(const [t1,t2] of [['1','1'],['1/2','1'],['0','1'],['1','0'],['2','-1/3']])for(const s of ['0','1','1/3'])
    SMALL.push({...sh,nMode,phi3,m,t1,t2,n6:'1',alpha:'1',sTyped:s});
}
// ---------------------------------------------------------------- named components and a field-level diff
// Each component is compared byte for byte; when bytes differ, the component is flattened (JSON) and the differing leaves are named by path.
function comps(Cm,Om,Nm,FSm,st,full){
  const num=Nm.compute(st),orbs=num.empty||num.refused?[]:Nm.orbits(st,num);
  const o={exportExact:Cm.exportExact(st,null,{}),exportExactWitness5:Cm.exportExact(st,null,{witnessP:'5'}),exportState:Cm.exportState(st),address:Cm.encodeAddress(st),
    readouts:JSON.stringify(Cm.readouts(st),BJ),liftBranches:JSON.stringify(Om.branches(st).map(Om.liftBranch)),gates:JSON.stringify(Om.gates(st)),field:Om.field(st).line,
    stopSet:JSON.stringify(Cm.stopSet(st),BJ),stepUp:JSON.stringify(Cm.step(st,1),BJ),stepDown:JSON.stringify(Cm.step(st,-1),BJ),fsCaption:FSm.caption(st),
    numeric:JSON.stringify(num,BJ),orbits:JSON.stringify(orbs,BJ),mirrorPairs:JSON.stringify(Om.mirrorPairs(st),BJ),cyclo:JSON.stringify(Cm.cycloJson(st),BJ),divisors:JSON.stringify(Cm.divisorsOf(st),BJ)};
  if(full){o.mirrorParity=JSON.stringify(Om.mirrorParity(st),BJ);o.foliation=JSON.stringify(Om.carrierFoliation(st,24,7),BJ);}
  return o;
}
function flat(v,p,out){if(v&&typeof v==='object'){const ks=Object.keys(v);if(!ks.length)out[p]=JSON.stringify(v);for(const k of ks)flat(v[k],p+'.'+k,out);}else out[p]=JSON.stringify(v);return out;}
const parseC=s=>{try{return JSON.parse(s);}catch(e){return s;}};
function diffFields(a,b){const d=[];for(const k of Object.keys(a)){if(a[k]===b[k])continue;const fa=flat(parseC(a[k]),k,{}),fb=flat(parseC(b[k]),k,{});
  for(const p of new Set([...Object.keys(fa),...Object.keys(fb)]))if(fa[p]!==fb[p])d.push(p);}return d.sort();}
const WILSON_FIELDS=['exportExact.exact.wilsonN','exportExactWitness5.exact.wilsonN','readouts.wilsonN.checked','readouts.wilsonN.label','readouts.wilsonN.prime','readouts.wilsonN.residue'];
const WILSON_FIELDS_04=WILSON_FIELDS;   // same field names against the v0.4 modules
function compare(set,Cm,Om,Nm,FSm,full,expectFields){
  let n=0,n0=0,bad0=0,badN=0,refusedBoth=0;const perState={},examples=[],fieldCount={};
  for(const o of set){let stOld;try{stOld=Cm.enterSpin(Cm.initial(o),o.sTyped);}catch(e){let e2=null;try{C.enterSpin(C.initial(o),o.sTyped);}catch(x){e2=x.message;}if(e2!==e.message)badN++;else refusedBoth++;continue;}
    const st=C.enterSpin(C.initial(o),o.sTyped);n++;
    if(JSON.stringify(st)!==JSON.stringify(stOld)){badN++;examples.push('state object differs '+C.encodeAddress(st));continue;}
    const isN0=C.resolve(st).Nq.n===0n;const d=diffFields(comps(C,O,NUM,FS,st,full),comps(Cm,Om,Nm,FSm,stOld,full));
    if(isN0){n0++;perState[d.length]=(perState[d.length]||0)+1;d.forEach(f=>fieldCount[f]=(fieldCount[f]||0)+1);if(d.join()!==expectFields.join()){bad0++;if(examples.length<3)examples.push('N=0 '+C.encodeAddress(st)+' -> '+d.join(','));}}
    else if(d.length){badN++;if(examples.length<3)examples.push('N!=0 '+C.encodeAddress(st)+' -> '+d.join(','));}}
  return {n,n0,bad0,badN,refusedBoth,perState,fieldCount,examples};
}
const fmt=r=>'('+r.n+' states compared, '+(r.n-r.n0)+' with N ≠ 0: '+r.badN+' differences; '+r.n0+' with N = 0: '+r.bad0+' outside the Wilson fields; differing fields per N = 0 state: '+Object.entries(r.perState).map(([k,v])=>k+' fields in '+v+' states').join(', ')+'; per field: '+Object.entries(r.fieldCount).map(([k,v])=>k+' ×'+v).join(', ')+')'+(r.examples.length?' '+r.examples.join(' | '):'');
// ---------------------------------------------------------------- 1. the N = 0 Wilson wording
t('Fix 1 wording: at N = 0 the shell-N Wilson record is {checked: false, prime: null, residue: null, label: "'+NEW+'"} on every shell (factorial n₁ = 1…13, integer B ∈ {1, 2, 3, 24, 61, 6227020800}) in both N modes; the exact export field exact.wilsonN carries the same label; N = 1 keeps "'+OLD+'", N = 2 and N = 13 are evaluated as before',()=>{
  let n=0,bad=[];const shells=[];for(let k=1;k<=13;k++)shells.push({shellMode:'factorial',n1:String(k)});for(const B of ['1','2','3','24','61','6227020800'])shells.push({shellMode:'integer',B});
  for(const sh of shells){const R0=C.resolve(C.initial({...sh,phi3:'0'}));const B1=String(R0.B+1n);
    for(const nMode of ['integer','continuous']){const st=C.initial({...sh,nMode,phi3:B1});n++;const w=C.readouts(st).wilsonN,x=JSON.parse(C.exportExact(st,null,{})).exact.wilsonN;
      if(!(w.checked===false&&w.prime===null&&w.residue===null&&w.label===NEW&&x===NEW))bad.push(C.encodeAddress(st));
      {const s1=C.initial({...sh,nMode,phi3:String(R0.B)});const w1=C.readouts(s1).wilsonN;if(w1.label!==OLD||w1.checked!==true||w1.prime!==false)bad.push('N=1 '+C.encodeAddress(s1));}}}
  const ok2=C.wilsonN(2n).label==='Shell N = 2: (N−1)! mod N = 1 · N is prime'&&C.wilsonN(13n).prime===true&&C.wilsonN(1n).label===OLD&&C.wilsonN(0n).label===NEW&&C41.wilsonN(0n).label===OLD;
  return {ok:bad.length===0&&ok2&&n===38,note:'('+n+' N = 0 states, '+bad.length+' wrong) '+bad.slice(0,3).join(' | ')};});
t('Fix 1 scope (source): host-core/comb-core.js differs from v0.4.1 by exactly one added line (the N = 0 branch of wilsonN); every other host-core module and exact-lib file is byte-identical to v0.4.1; instruments/comb-hopf/panel.js differs only in clampPhi (lines 45 and 48); no other instrument file differs',()=>{
  const here=path.join(__dirname,'..'),old=path.join(__dirname,P41);const rd=(r,f)=>fs.readFileSync(path.join(r,f),'utf8');
  const a=rd(old,'host-core/comb-core.js').split('\n'),b=rd(here,'host-core/comb-core.js').split('\n');
  const added=b.length===a.length+1&&b.slice(0,62).join('\n')===a.slice(0,62).join('\n')&&b.slice(63).join('\n')===a.slice(62).join('\n')&&/^  if\(N===0n\)return \{checked:false,prime:null,residue:null,label:'N = 0: no comb, so the Wilson test does not apply\.'\};/.test(b[62]);
  const same=[];const diffs=[];
  for(const dir of ['host-core','exact-lib','instruments/comb-hopf'])for(const f of fs.readdirSync(path.join(old,dir))){const rel=dir+'/'+f;if(rel==='host-core/comb-core.js'||rel==='instruments/comb-hopf/panel.js'||rel==='instruments/comb-hopf/README.md')continue;
    if(!fs.statSync(path.join(old,rel)).isFile())continue;(rd(old,rel)===rd(here,rel)?same:diffs).push(rel);}
  const pa=rd(old,'instruments/comb-hopf/panel.js').split('\n'),pb=rd(here,'instruments/comb-hopf/panel.js').split('\n');
  const pd=pa.map((l,i)=>l===pb[i]?null:i+1).filter(Boolean);
  const clampOk=pa.length===pb.length&&pd.join()==='45,48'&&pb[47].includes('p.phi3=String(B);}')&&pa[47].includes('p.phi3=String(B+1n);}');
  const extra=fs.readdirSync(path.join(here,'host-core')).filter(f=>!fs.existsSync(path.join(old,'host-core',f)));
  return {ok:added&&clampOk&&diffs.length===0&&extra.join()==='test-v042.cjs',note:'('+same.length+' files byte-identical; panel.js lines differing: '+pd.join(', ')+'; new host-core files: '+extra.join(', ')+')'+(diffs.length?' differing: '+diffs.join(', '):'')};});
// ---------------------------------------------------------------- 2. byte identity against v0.4.1 and v0.4
t('Fix 1 exactness vs v0.4.1: the 408-state preset grid plus 1,600 random states of test-v041 — for every N ≠ 0 state the exact export (also with the order-m witness p = 5), state export, address, readouts, Lift branches, gates, field line, stop set, both step records, fraction-stack caption, numerical model, orbit samples, mirror pairs, mirror parity, foliation record, cyclotomic record and divisor report are byte-identical; for every N = 0 state exactly the Wilson fields differ: '+WILSON_FIELDS.join(', '),()=>{
  const r=compare(PRE,C41,O41,N41,FS41,true,WILSON_FIELDS);return {ok:r.badN===0&&r.bad0===0&&r.n>1800&&r.n0>0&&r.n===PRE.length,note:fmt(r)};});
t('Fix 1 exactness vs v0.4.1 on B = 1, 2 (the test-v041 set: n₁ = 1, 2 and integer B = 1, 2, every shell position in both N modes): N ≠ 0 byte-identical; N = 0 differs exactly in the Wilson fields',()=>{
  const r=compare(SMALL,C41,O41,N41,FS41,true,WILSON_FIELDS);return {ok:r.badN===0&&r.bad0===0&&r.n===SMALL.length&&r.n0>0,note:fmt(r)};});
t('adapted from test-v041 "unchanged states" (v0.4 modules): the same 2,008 states — N ≠ 0 byte-identical to v0.4; N = 0 differs exactly in the Wilson fields (the v0.4.1 assertion of 0 differences no longer holds at N = 0 because of Fix 1, by design)',()=>{
  const r=compare(PRE,C4,O4,N4,FS4,false,WILSON_FIELDS_04);return {ok:r.badN===0&&r.bad0===0&&r.n>1800&&r.n0>0,note:fmt(r)};});
// ---------------------------------------------------------------- 3. address and schema ids unchanged
t('address/state format unchanged: ADDRESS_ID, ADDRESS_ID_V01, STATE_SCHEMA, EXACT_SCHEMA, DIAL_KEYS, ADDRESS_KEYS, DEFAULTS and N_MODES equal v0.4.1; every address of the 2,008 + 3,480 states round-trips and equals the v0.4.1 address',()=>{
  const keys=['ADDRESS_ID','ADDRESS_ID_V01','STATE_SCHEMA','EXACT_SCHEMA','DIAL_KEYS','ADDRESS_KEYS','DEFAULTS','N_MODES','TABS'];const kb=keys.filter(k=>JSON.stringify(C[k])!==JSON.stringify(C41[k]));
  let n=0,bad=0;for(const o of [...PRE,...SMALL]){let st;try{st=C.enterSpin(C.initial(o),o.sTyped);}catch(e){continue;}n++;const a=C.encodeAddress(st),b=C41.encodeAddress(C41.enterSpin(C41.initial(o),o.sTyped)),back=C.importAny(a);
    if(a!==b||!back.ok||C.encodeAddress(back.state)!==a)bad++;}
  return {ok:kb.length===0&&bad===0&&n===PRE.length+SMALL.length,note:'('+n+' addresses, '+bad+' differences'+(kb.length?'; constants differing: '+kb.join(','):'')+')'};});
console.log(`test-v042: ${pass} passed, ${fail} failed`);
process.exit(fail?1:0);
