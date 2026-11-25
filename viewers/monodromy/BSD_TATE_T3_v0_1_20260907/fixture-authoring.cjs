'use strict';
// Deterministic builder corpus. Expected outputs are cross-checked with live PARI by the worker.
const fs=require('node:fs'),path=require('node:path'),K=require('./small-prime-tate.cjs'),T=require('../BSD_TATE_T1_v0_1_20260907/t1.cjs');
if(fs.existsSync(path.join(__dirname,'MANIFEST.sha256')))throw Error('Sealed candidate; create a successor');
const corpus=[],keys=new Set();let seed=301202609;
const rng=n=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%n;};
function keep(a,p,name,force=false){if(T.model(a).invariants.discriminant==='0')return;const trace=K.compute(a,String(p)),r=trace.result,key=[p,r.kodaira,r.tamagawaNumber,r.conductorExponent,r.split].join(':');if(!force&&keys.has(key))return;keys.add(key);corpus.push({name:name||key,p:String(p),ainvs:a,expected:{kodaira:r.kodaira,tamagawaNumber:r.tamagawaNumber,conductorExponent:r.conductorExponent,discriminantValuation:r.discriminantValuation,split:r.split},selectedMultiplier:'1',points:[]});}
for(const p of [2,3]){
 for(let i=0;i<1800;i++){
  const profile=i%4,thresholds=profile===0?[0,0,0,0,0]:profile===1?[1,1,1,1,1]:profile===2?[1,1,2,2,3]:[1,2,3,4,5];
  const a=thresholds.map(e=>String(BigInt(rng(31)-15)*BigInt(p)**BigInt(e+rng(3))));if(T.model(a).invariants.discriminant!=='0')keep(a,p);
 }
 for(const n of Array.from({length:16},(_,i)=>i+1))for(const cp of [2,4]){
  const x=Math.floor((n-1)/2)+2,odd=n%2===1,b=cp===4?0:odd||p===2?1:2;
  const a=['0',String(p),odd?String(BigInt(p)**BigInt(x)):'0',odd?'0':String(BigInt(p)**BigInt(x+1)),String(BigInt(b)*BigInt(p)**BigInt(odd?2*x:2*x+1))];
  const r=K.compute(a,String(p)).result;if(r.kodaira!=='I'+n+'*'||r.tamagawaNumber!==String(cp))throw Error('Constructed star family failed '+[p,n,cp]);keep(a,p,'constructed-'+p+'-I'+n+'*-'+cp,true);
 }
 for(const a of [['0','0','1','-1','0'],['1','0','1','4','-6'],['0','0','0','-1','0'],['0','0','0','0','1'],['0','0','0','0','3'],['0','1','0','0','3'],['0','2','0','0','3']])keep(a,p,'named-'+p+'-'+a.join('_'),true);
}
// A denominator-cleared model can still need repeated Tate rescaling and translations.
for(const p of [2,3])for(const base of [['0','0','1','-1','0'],['0','0','0','-1','0'],['0','1','0','0','3']]){
 const w={u:'-1/'+String(p**3),r:'7',s:'-3',t:'5'},a=T.transform(base,w);keep(a,p,'hidden-three-scalings-'+p+'-'+base.join('_'),true);
}
for(const p of [2,3]){const base=['0','0','0','-1','0'],w={u:'-2/3',r:'1/3',s:'-1/2',t:'7/4'},a=T.transform(base,w),pt=T.pointMap(base,w,{x:'0',y:'0'}),integral=T.transform(a,T.clearing(a)),r=K.compute(integral,String(p)).result;corpus.push({name:'rational-signed-points-'+p,p:String(p),ainvs:a,selectedMultiplier:'-5/3',points:[pt,pt,{infinity:true}],expected:{kodaira:r.kodaira,tamagawaNumber:r.tamagawaNumber,conductorExponent:r.conductorExponent,discriminantValuation:r.discriminantValuation,split:r.split}});}
fs.writeFileSync(path.join(__dirname,'fixture-inputs.json'),JSON.stringify({schema:'BSD_T3_BUILDER_INPUT_CORPUS_V1',seed:301202609,randomCandidates:3600,expectedStatus:'BUILDER_COMPUTED_MUST_MATCH_PARI_AND_PYTHON',cases:corpus},null,2)+'\n');
console.log(JSON.stringify({cases:corpus.length,coverage:[...keys].sort()},null,2));
