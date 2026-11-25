'use strict';
const assert=require('node:assert/strict'),T=require('../BSD_TATE_T1_v0_1_20260907/t1.cjs');
const engines={T2:require('../BSD_TATE_T2_v0_1_20260907/t2.cjs'),T3:require('../BSD_TATE_T3_v0_1_20260907/t3.cjs')};
const {R,S,add,sub,mul,div,pow}=T;
const abs=s=>{const q=R(s);return S([q[0]<0n?-q[0]:q[0],q[1]]);};
function residue(s,m){
 const [n,d]=R(s);if(m===1n)return '0';if(m<=0n||m.toString(2).length>16384)throw Error('Residue modulus cap');
 let a=d,b=m,x=1n,y=0n;while(b){const q=a/b;[a,b]=[b,a-q*b];[x,y]=[y,x-q*y];}
 if(a!==1n)throw Error('Denominator not invertible');return String(((n*x)%m+m)%m);
}
// Replace a p-local tuple by an integral tuple with the same u=p^k.
// The t congruence includes the cross term s*(R-r), required by composition.
function integralLift(w,p){
 const [u,d]=R(w.u);if(d!==1n||u<1n)throw Error('Expected positive integral p-power scale');
 let rem=u;while(rem%BigInt(p)===0n&&rem>1n)rem/=BigInt(p);if(rem!==1n)throw Error('Scale contains another prime');
 const r=residue(w.r,u*u),s=residue(w.s,u),targetT=S(add(R(w.t),mul(R(w.s),sub(R(r),R(w.r))))),t=residue(targetT,u*u*u);
 const lift={u:w.u,r,s,t},localToIntegral=T.compose(T.inverse(w),lift);
 assert.equal(localToIntegral.u,'1');for(const k of ['r','s','t'])if(T.valuation(localToIntegral[k],p).kind==='FINITE'&&Number(T.valuation(localToIntegral[k],p).exponent)<0)throw Error('Nonintegral local equivalence');
 return {lift,localToIntegral,congruences:{rModulus:String(u*u),sModulus:String(u),tModulus:String(u*u*u),tResidueInput:targetT}};
}
function verifier(){return {name:'BSD_GLOBAL_REDUCTION_REPLAY',version:'0.1.0',sha256:T.shaFile(__filename),transportSha256:T.shaFile(require.resolve('../BSD_TATE_T1_v0_1_20260907/t1.cjs')),arithmeticSha256:T.shaFile(require.resolve('../BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/model-replay.cjs')),tame:engines.T2.verifier(),smallPrime:engines.T3.verifier()};}
function rebind(q){q.contextId=T.hash({anchor:q.anchor,modelId:q.normalization.targetModelId,normalization:q.normalization,transformations:q.transformations,twistLineage:q.twistLineage});q.panelBindings=T.panels.map(panel=>({panel,contextId:q.contextId,modelId:q.normalization.targetModelId,normalizationId:T.hash(q.normalization),markingId:T.hash(q.marking)}));}
function artifact(q,body){const bytes=T.canonical(body),sha256=T.hash(bytes);if(!q.sources.some(s=>s.sha256===sha256))q.sources.push({sha256,mediaType:'application/json',bytes});return sha256;}
function oldResult(r){return Object.fromEntries(['reduction','kodaira','split','discriminantValuation','conductorExponent','wildConductorContribution','tamagawaNumber','eulerPolynomial'].map(k=>[k,r[k]]));}
function construct(parentBytes){
 const parent=JSON.parse(parentBytes);T.verifyTransport(parent);const parentHash=T.hash(parentBytes),source=parent.models.find(m=>m.modelId===parent.normalization.targetModelId),clear=T.clearing(source.ainvs),integralSource=T.model(T.transform(source.ainvs,clear)),sourceInventory=T.inventory(integralSource);
 if(sourceInventory.factors.length>24)throw Error('UNAVAILABLE: 24-prime global work cap');
 let composite={...T.ID};const stages=[];
 for(const factor of sourceInventory.factors){
  const p=factor.p,engine=Number(p)<5?'T3':'T2',before=T.transport(parent,[clear,composite]).record,beforeModel=before.models.find(m=>m.modelId===before.normalization.targetModelId);
  const localPacket=engines[engine].construct(T.canonical(before),p,null),assessment=engines[engine].replay(localPacket);assert.equal(assessment.status,'PASS');
  const w=localPacket.adapter.composite,lift=integralLift(w,Number(p)),target=T.model(T.transform(beforeModel.ainvs,lift.lift));
  if(target.ainvs.some(s=>R(s)[1]!==1n))throw Error('Lift did not preserve global integrality');
  assert.deepEqual(T.transform(localPacket.trace.targetAinvs,lift.localToIntegral),target.ainvs,'Local-to-integral coefficients');
  const inputDeltaVal=T.valuation(beforeModel.invariants.discriminant,Number(p)),targetDeltaVal=T.valuation(target.invariants.discriminant,Number(p));
  assert.equal(targetDeltaVal.exponent,assessment.certificate.result.discriminantValuation);
  const scaleVal=T.valuation(w.u,Number(p));assert.equal(Number(inputDeltaVal.exponent)-Number(targetDeltaVal.exponent),12*Number(scaleVal.exponent));
  const fromIntegral=composite;composite=T.compose(composite,lift.lift);
  stages.push({p,engine,sourceModelId:beforeModel.modelId,localPacket,localCertificate:assessment.certificate,localCertificateId:assessment.certificateId,...lift,target,fromIntegral,toIntegral:composite,inputDeltaVal,targetDeltaVal});
 }
 const adapted=T.transport(parent,[clear,composite]),record=adapted.record,model=record.models.find(m=>m.modelId===record.normalization.targetModelId),candidateInventory=T.inventory(model),transfers=[];
 assert.equal(candidateInventory.remainingCofactor,sourceInventory.remainingCofactor,'Unexpected prime support change');
 for(const stage of stages){
  const p=Number(stage.p),map=T.compose(T.inverse(stage.toIntegral),composite);assert.deepEqual(T.transform(stage.target.ainvs,map),model.ainvs);
  for(const k of ['u','r','s','t']){const v=T.valuation(map[k],p);if(k==='u'?v.exponent!=='0':v.kind==='FINITE'&&Number(v.exponent)<0)throw Error('Later change damages local minimality');}
  const cert=stage.localCertificate,r=cert.result;assert.equal(T.valuation(model.invariants.discriminant,p).exponent,r.discriminantValuation);
  const totalMap=T.compose(stage.localToIntegral,map);assert.deepEqual(T.transform(stage.localPacket.trace.targetAinvs,totalMap),model.ainvs);
  const selectedBefore=stage.localPacket.record.normalization.targetSelectedMultiplier;assert.equal(S(div(R(selectedBefore),R(totalMap.u))),record.normalization.targetSelectedMultiplier);
  transfers.push({p:stage.p,localCertificateId:stage.localCertificateId,localModelId:stage.localPacket.trace.targetModelId,globalCandidateModelId:model.modelId,integralStageToFinal:map,localToFinal:totalMap,localMinimality:'TRANSFERRED_BY_P_INTEGRAL_UNIT_ISOMORPHISM',result:oldResult(r),ap:r.ap});
 }
 const knownBad=transfers.filter(t=>t.result.reduction!=='GOOD'),recoveredGood=transfers.filter(t=>t.result.reduction==='GOOD').map(t=>t.p);
 assert.deepEqual(knownBad.map(t=>t.p),candidateInventory.factors.map(f=>f.p));
 let conductor=1n,tamagawa=1n;for(const t of knownBad){conductor*=BigInt(t.p)**BigInt(t.result.conductorExponent);tamagawa*=BigInt(t.result.tamagawaNumber);}
 for(const n of [conductor,tamagawa])if(n.toString().length>96)throw Error('UNAVAILABLE: product size cap');
 const knownPrimeProducts={scope:'ONLY_LISTED_PRIMES',primes:knownBad.map(t=>t.p),conductor:String(conductor),tamagawaProduct:String(tamagawa)};
 const complete=candidateInventory.complete;
 const normalization=complete?{convention:'GLOBAL_MINIMAL_MODEL_DIFFERENTIAL_UP_TO_SIGN',chosenSign:'MODEL_DIFFERENTIAL',modelId:model.modelId,inputModelId:source.modelId,anchorModelId:parent.anchor.inputModelId,signedPullbackToInput:adapted.adapter.composite.u,signedPullbackToAnchor:record.normalization.composedPullbackFactor,selectedMultiplier:record.normalization.targetSelectedMultiplier,neronOverSelectedMultiplier:S(div(R('1'),R(record.normalization.targetSelectedMultiplier))),absoluteRealMeasureFactorFromInput:abs(adapted.adapter.composite.u),absoluteRealMeasureFactorFromAnchor:abs(record.normalization.composedPullbackFactor),absoluteRealMeasureFactorFromSelected:abs(S(div(R('1'),R(record.normalization.targetSelectedMultiplier)))),realComponents:R(model.invariants.discriminant)[0]>0n?'2':'1',periodValue:'NOT_COMPUTED'}:null;
 const globalResult=complete?{modelId:model.modelId,minimalDiscriminant:model.invariants.discriminant,curveBadPrimes:knownBad.map(t=>t.p),conductor:String(conductor),tamagawaProduct:String(tamagawa),goodOutsideInventory:'PROVED_BY_INTEGRAL_MODEL_AND_UNIT_DISCRIMINANT',normalization}:null;
 const proof={schema:'BSD_GLOBAL_REDUCTION_PROOF_V1',parentSourceHash:parentHash,sourceInventory,candidateInventory,stageHashes:stages.map(T.hash),transfers,knownPrimeProducts,recoveredGood,globalResult,verifier:verifier()};
 const dependencies=stages.map(s=>artifact(record,s.localCertificate)),proofHash=artifact(record,proof);
 const evidence={status:'CERTIFIED',method:'T4_EXACT_GLOBAL_REPLAY',software:'BSD_GLOBAL_REDUCTION_REPLAY_0.1.0',sourceHash:proofHash,assumptions:[],dependencies,certificate:{artifactSha256:proofHash,verifier:'BSD_GLOBAL_REDUCTION_REPLAY_0.1.0',conclusion:complete?'GLOBAL_MINIMAL_NERON_AND_REDUCTION_PRODUCTS':'LOCAL_RESULTS_AT_LISTED_PRIMES_ONLY'}};
 record.localData=transfers.map(t=>({p:t.p,modelId:model.modelId,minimalityEvidence:t.result.reduction==='GOOD'?null:evidence,result:t.result,evidence}));
 if(complete){record.minimalModel={modelId:model.modelId,scope:'GLOBAL_Q',prime:null,evidence};record.normalization.neron={modelId:model.modelId,convention:'GLOBAL_MINIMAL_MODEL_DIFFERENTIAL_UP_TO_SIGN',evidence};record.badPrimeInventory={modelId:model.modelId,factors:candidateInventory.factors.map(({p,exponent})=>({p,exponent})),remainingCofactor:'1',complete:true,evidence};record.aggregate={modelId:model.modelId,conductor:String(conductor),tamagawaProduct:String(tamagawa),localDataPrimes:knownBad.map(t=>t.p),evidence};}
 if(record.sources.length>300)throw Error('UNAVAILABLE: source artifact count cap');rebind(record);T.verifyTransport(record);
 return {schema:'BSD_GLOBAL_REDUCTION_PACKET_V1',parent:{sha256:parentHash,bytes:parentBytes},integralSource,sourceInventory,stages,adapter:adapted.adapter,record,candidateInventory,proof,proofHash};
}
function replay(q){
 assert.equal(T.hash(q.parent.bytes),q.parent.sha256,'Parent hash');const expected=construct(q.parent.bytes);assert.deepEqual(q,expected,'T4 global replay mismatch');
 if(!q.candidateInventory.complete)return {status:'UNAVAILABLE',reason:'UNRESOLVED_DISCRIMINANT_COFACTOR',remainingCofactor:q.candidateInventory.remainingCofactor,packetHash:T.hash(q),proofHash:q.proofHash,localCertificates:q.stages.map(s=>s.localCertificateId),knownPrimeProducts:q.proof.knownPrimeProducts,globalMinimality:'NOT_ASSESSED',neronDifferential:'NOT_ASSESSED',certificate:null,bsdPromotion:false};
 const certificate={schema:'BSD_GLOBAL_REDUCTION_CERTIFICATE_V1',status:'CERTIFIED',scope:'GLOBAL_REDUCTION_OVER_Q_WITHIN_DECLARED_BOUNDS',packetHash:T.hash(q),parentSourceHash:q.parent.sha256,contextId:q.record.contextId,sourceModelId:q.adapter.sourceModelId,modelId:q.record.normalization.targetModelId,normalizationId:T.hash(q.record.normalization),markingId:T.hash(q.record.marking),proofHash:q.proofHash,localCertificateIds:q.stages.map(s=>s.localCertificateId),verifier:verifier(),method:'INTEGRAL_LOCAL_LIFTS_COMPLETE_FACTORISATION_AND_LOCAL_CERTIFICATE_REPLAY',result:q.proof.globalResult,globalMinimality:'CERTIFIED',neronDifferential:'CERTIFIED_UP_TO_SIGN',heights:'NOT_COMPUTED',bsdPromotion:false};
 return {status:'PASS',certificateId:T.hash(certificate),certificate,localCertificates:certificate.localCertificateIds,bsdPromotion:false};
}
module.exports={construct,replay,verifier,integralLift,residue};
