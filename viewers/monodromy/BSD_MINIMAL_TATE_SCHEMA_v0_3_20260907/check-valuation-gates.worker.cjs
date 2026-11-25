'use strict';
require('./worker-guard.cjs')();
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const T=require('./model-replay.cjs'),prior=require('../BSD_MINIMAL_TATE_SCHEMA_v0_2_20260907/model-replay.cjs'),{assess}=require('./assess.cjs');
const base=JSON.parse(fs.readFileSync(path.join(__dirname,'fixtures/37a1-model-exclusion.json'),'utf8'));
const clone=q=>JSON.parse(JSON.stringify(q)),checks=[],reproductions=[];
const check=(name,fn)=>{fn();checks.push({name,status:'PASS'});};
function packetFor(a,p,result){
 const q=clone(base),m=T.model(a);q.models=[m];q.transformations=[];q.points=[];q.twistLineage=[];q.minimalModel=null;q.badPrimeInventory=null;q.aggregate=null;
 const bytes=JSON.stringify({field:'Q',ainvs:a,selectedMultiplier:'1'}),sourceHash=T.hash(bytes);
 q.sources.push({sha256:sourceHash,mediaType:'application/json',bytes});q.anchor={inputModelId:m.modelId,sourceHash,legacyContextId:null};
 q.normalization={...q.normalization,sourceSelectedMultiplier:'1',targetModelId:m.modelId,targetSelectedMultiplier:'1',composedPullbackFactor:'1',neron:null};
 q.contextId=T.hash({anchor:q.anchor,modelId:m.modelId,normalization:q.normalization,transformations:[],twistLineage:[]});
 q.panelBindings=q.panelBindings.map(x=>({...x,contextId:q.contextId,modelId:m.modelId,normalizationId:T.hash(q.normalization)}));
 const evidence={...clone(base.minimalModel.evidence),method:'ADVERSARIAL_VALUATION_FIXTURE',status:'UNVERIFIED'};
 q.localData=[{p:String(p),modelId:m.modelId,minimalityEvidence:result.reduction==='GOOD'?null:evidence,result,evidence}];return q;
}
const cpFor=type=>['III','III*'].includes(type)||/^I[1-9][0-9]*[*]$/.test(type)?2:1;
function additive(type,n,cp=cpFor(type),f=2){return {reduction:'ADDITIVE',kodaira:type,split:null,discriminantValuation:String(n),conductorExponent:String(f),wildConductorContribution:String(f-2),tamagawaNumber:String(cp),eulerPolynomial:['1']};}
function remainsReport(q){const before=JSON.stringify(q),r=T.verifyTransport(q);assert.equal(JSON.stringify(q),before);assert.equal(r.bsdPromotion,false);assert.equal(r.tateAssessment,'NOT_IMPLEMENTED');const a=r.localAssessments[0];assert.equal(a.assessment,'CONSISTENCY_CHECKED_SOURCE_REPORT');assert.equal(a.tamagawaAssessment,'NOT_LOCALLY_CERTIFIED');assert.equal(a.certificate,undefined);assert.equal(a.status,undefined);assert(a.checkedRules.includes('Q_CONDUCTOR_EXPONENT_BOUND'));return a;}
const tameTypes=[['II','5','5',2],['III','5','25',3],['IV','25','25',4],['I0*','25','125',6],['I1*','-75','875',7],['IV*','625','625',8],['III*','125','3125',9],['II*','625','3125',10]];
const auditForgeries=[
 ['H1 II* with v5(Delta)=2',['0','0','0','5','5'],5,additive('II*',2),/Kodaira label contradicts/],
 ['H1 I0* with v5(Delta)=2',['0','0','0','5','5'],5,additive('I0*',2),/Kodaira label contradicts/],
 ['H1 IV* with v5(Delta)=7',['0','0','0','-75','875'],5,additive('IV*',7),/Kodaira label contradicts/],
 ['H2 f2=12 on y2=x3-1',['0','0','0','0','-1'],2,additive('II',4,1,12),/Conductor exponent exceeds the bound/]
];
for(const [name,a,p,r,reason] of auditForgeries)check('Reproduce and reject '+name,()=>{const q=packetFor(a,p,r),before=JSON.stringify(q);assert.equal(prior.verifyTransport(q).localAssessments[0].assessment,'CONSISTENCY_CHECKED_SOURCE_REPORT');assert.throws(()=>T.verifyTransport(q),reason);assert.equal(JSON.stringify(q),before);reproductions.push({name,expectedPredecessor:'CONSISTENCY_CHECKED_SOURCE_REPORT',expectedSuccessor:'REJECT',packet:q});});
for(const [type,A,B,n] of tameTypes)check('Tame '+type+' passes and every competing fixture label rejects',()=>{
 const q=packetFor(['0','0','0',A,B],5,additive(type,n));
 assert(remainsReport(q).checkedRules.includes('ADDITIVE_KODAIRA_FROM_DISCRIMINANT_AND_J_P_GE_5'));
 for(const [wrong] of tameTypes){if(wrong===type)continue;const forged=clone(q);forged.localData[0].result=additive(wrong,n);assert.throws(()=>T.verifyTransport(forged),/Kodaira label contradicts/);}
});
check('p-unit rational transformations preserve all eight tame types',()=>{for(const [type,A,B,n] of tameTypes){const a=T.transform(['0','0','0',A,B],{u:'-2',r:'1/3',s:'-1/2',t:'7/4'});remainsReport(packetFor(a,5,additive(type,n)));}});
check('j=0 has infinite valuation and supports all applicable additive families',()=>{for(const [B,type,n,cp] of [['5','II',2,1],['25','IV',4,3],['125','I0*',6,2],['625','IV*',8,3],['3125','II*',10,1]]){const q=packetFor(['0','0','0','0',B],5,additive(type,n,cp));assert.equal(q.models[0].invariants.j,'0');remainsReport(q);}});
for(const m of [2,3,4,7])check('Negative j valuation determines I'+m+'* including colliding discriminant values',()=>{const B=String(250n+5n**BigInt(m+3)),q=packetFor(['0','0','0','-75',B],5,additive('I'+m+'*',m+6));remainsReport(q);const wrong={2:'IV*',3:'III*',4:'II*',7:'I0*'}[m];q.localData[0].result=additive(wrong,m+6);assert.throws(()=>T.verifyTransport(q),/Kodaira label contradicts/);});
check('A nonminimal negative-j presentation cannot satisfy the tame pole-order relation',()=>{const a=T.transform(['0','0','0','-75','875'],{u:'1/5',r:'0',s:'0',t:'0'});assert.throws(()=>T.verifyTransport(packetFor(a,5,additive('I1*',19))),/pole order of j/);});
check('A nonminimal potentially good presentation lies outside the tame valuation table',()=>{const a=T.transform(['0','0','0','5','5'],{u:'1/5',r:'0',s:'0',t:'0'});assert.throws(()=>T.verifyTransport(packetFor(a,5,additive('II',14))),/claimed tame minimality/);});
check('The f2=8 boundary is admitted and 9 rejected on the 256.a1 model',()=>{const q=packetFor(['0','1','0','-13','-21'],2,additive('III*',15,2,8));assert(!remainsReport(q).checkedRules.some(s=>s.includes('P_GE_5')));q.localData[0].result=additive('III*',15,2,9);assert.throws(()=>T.verifyTransport(q),/Conductor exponent exceeds the bound/);});
check('The f3=5 boundary is admitted and 6 rejected on y2=x3+3',()=>{const q=packetFor(['0','0','0','0','3'],3,additive('II',5,1,5));assert(!remainsReport(q).checkedRules.some(s=>s.includes('P_GE_5')));q.localData[0].result=additive('II',5,1,6);assert.throws(()=>T.verifyTransport(q),/Conductor exponent exceeds the bound/);});
check('Conductor cannot exceed discriminant valuation even below the Q cap',()=>{const q=packetFor(['0','0','0','0','-1'],2,additive('II',4,1,4));remainsReport(q);q.localData[0].result=additive('II',4,1,5);assert.throws(()=>T.verifyTransport(q),/exceeds the discriminant valuation/);});
check('Public structural entry point rejects the audit forgeries',()=>{for(const [name,a,p,r] of auditForgeries)assert.throws(()=>assess(JSON.stringify(packetFor(a,p,r))),/Kodaira label contradicts|Conductor exponent exceeds the bound/,name);});
check('Good-prime certification on a1 nonzero general models is preserved',()=>{for(const [p,polynomial] of [[2,['1','1','2']],[3,['1','2','3']]]){const q=packetFor(['1','0','0','0','1'],p,{reduction:'GOOD',kodaira:'I0',split:null,discriminantValuation:'0',conductorExponent:'0',wildConductorContribution:'0',tamagawaNumber:'1',eulerPolynomial:polynomial});const a=assess(JSON.stringify(q)).localAssessments[0];assert.equal(a.status,'CERTIFIED');assert.equal(a.certificate.verifier.version,'0.3.0');assert.equal(a.certificate.scope,'THIS_MODEL_AND_THIS_PRIME_ONLY');}});
fs.writeFileSync(path.join(__dirname,'valuation-forgery-reproductions.json'),JSON.stringify(reproductions,null,2)+'\n');
fs.writeFileSync(path.join(__dirname,'valuation-gates-verification.json'),JSON.stringify({standing:'LOCAL_H1_H2_GATES_NOT_TATE_CERTIFICATION',total:checks.length,checks,predecessorAcceptedForgeries:reproductions.length,tameCompetingLabelRejections:56},null,2)+'\n');
console.log(checks.length+' valuation gate groups PASS; all four cold-audit forgeries rejected');
