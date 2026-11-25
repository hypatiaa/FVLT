'use strict';
const assert=require('node:assert/strict'),T=require('../BSD_TATE_T1_v0_1_20260907/t1.cjs'),K=require('./tame-tate.cjs');
function verifier(){return {name:'BSD_TAME_TATE_REPLAY',version:'0.1.0',sha256:T.shaFile(__filename),tateSha256:T.shaFile(require.resolve('./tame-tate.cjs')),finiteFieldSha256:T.shaFile(require.resolve('./finite-field.cjs')),transportSha256:T.shaFile(require.resolve('../BSD_TATE_T1_v0_1_20260907/t1.cjs')),arithmeticSha256:T.shaFile(require.resolve('../BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/model-replay.cjs'))};}
function kod(code){const n=Number(code);return ({1:'I0',2:'II',3:'III',4:'IV','-1':'I0*','-2':'II*','-3':'III*','-4':'IV*'})[n]||(n>=5?'I'+(n-4):n<=-5?'I'+(-n-4)+'*':null);}
function construct(parentBytes,p,comparison=null){
 const parent=JSON.parse(parentBytes);T.verifyTransport(parent);const source=parent.models.find(m=>m.modelId===parent.normalization.targetModelId),clear=T.clearing(source.ainvs),integral=T.model(T.transform(source.ainvs,clear)),c=T.S(T.div(T.R(parent.normalization.targetSelectedMultiplier),T.R(clear.u)));
 const trace=K.compute(integral.ainvs,p,c),adapted=T.transport(parent,[clear,trace.composite]);
 let comparisonMap=null;if(comparison)comparisonMap=T.compose(T.inverse(adapted.adapter.composite),comparison.adapter.composite);
 return {schema:'BSD_TAME_TATE_PACKET_V1',parent:{sha256:T.hash(parentBytes),bytes:parentBytes},...adapted,integralSource:integral,inventory:T.inventory(integral),trace,comparison,comparisonMap};
}
function replay(q){
 assert.equal(T.hash(q.parent.bytes),q.parent.sha256,'Parent hash');const expected=construct(q.parent.bytes,q.trace.p,q.comparison);assert.deepEqual(q,expected,'T2 trace/transport/context replay mismatch');
 const r=q.trace.result;
 // Reapply all inherited cheap gates to this proof's target result.
 const local=structuredClone(q.record),bytes=T.canonical(q.trace),sha256=T.hash(bytes);local.sources.push({sha256,mediaType:'application/json',bytes});
 const evidence={status:'UNVERIFIED',method:'T2_REPLAY_CHECK_INPUT',software:'BSD_TAME_TATE_REPLAY_0.1.0',sourceHash:sha256,assumptions:[],dependencies:[],certificate:null};
 const {geometricComponents,componentMultiplicities,localMinimality,minimalityWitness,ap,...oldResult}=r;
 local.localData=[{p:q.trace.p,modelId:q.trace.targetModelId,minimalityEvidence:r.reduction==='GOOD'?null:evidence,result:oldResult,evidence}];T.verifyTransport(local);
 if(q.comparison){
  assert.deepEqual(q.comparison.parent,q.parent,'Comparison uses a different source');assert.equal(q.comparison.trace.p,q.trace.p,'Comparison prime mismatch');T.replay(q.comparison);
  const b=q.comparison.backend;if(!b)throw Error('Comparison requires the pinned PARI source report');
  assert.deepEqual(T.transform(q.trace.targetAinvs,q.comparisonMap),q.comparison.trace.ainvs,'Comparison isomorphism');
  assert.equal(T.S(T.div(T.R(q.record.normalization.targetSelectedMultiplier),T.R(q.comparisonMap.u))),q.comparison.record.normalization.targetSelectedMultiplier,'Comparison differential');
  assert.equal(kod(b.claims.LOCAL[1]),r.kodaira,'PARI Kodaira disagreement');assert.equal(b.claims.LOCAL[0],r.conductorExponent,'PARI conductor disagreement');assert.equal(b.claims.LOCAL[3],r.tamagawaNumber,'PARI Tamagawa disagreement');assert.equal(q.comparison.trace.valuations.discriminant.exponent,r.discriminantValuation,'PARI minimal discriminant disagreement');
  if(q.comparison.trace.terminal.status==='REPLAYABLE'){const old=q.comparison.trace.terminal.result;for(const k of ['reduction','split','ap','eulerPolynomial'])assert.deepEqual(r[k],old[k],'Comparison '+k+' disagreement');}
 }
 const certificate={schema:'BSD_TAME_TATE_LOCAL_CERTIFICATE_V1',status:'CERTIFIED',scope:'ONE_PRIME_P_GE_5_ONLY',packetHash:T.hash(q),parentSourceHash:q.parent.sha256,contextId:q.record.contextId,sourceModelId:q.adapter.sourceModelId,modelId:q.trace.targetModelId,normalizationId:T.hash(q.record.normalization),markingId:T.hash(q.record.marking),p:q.trace.p,traceHash:T.hash(q.trace),verifier:verifier(),method:'EXACT_TAME_TATE_WITH_COMPLETE_RESIDUE_POLYNOMIAL_WITNESSES',result:r,assumptions:[],globalMinimality:'NOT_ASSESSED',neronDifferential:'NOT_ASSESSED',bsdPromotion:false};
 return {status:'PASS',certificateId:T.hash(certificate),certificate,comparisonStatus:q.comparison?'MATCHING_SOURCE_REPORT':'ABSENT',bsdPromotion:false};
}
module.exports={construct,replay,verifier,kod};
