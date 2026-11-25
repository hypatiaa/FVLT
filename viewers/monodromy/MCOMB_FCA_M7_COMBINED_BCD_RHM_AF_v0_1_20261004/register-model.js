/* Read-only projection of a verified T4 result into the BSD component comparison.
   The caller must be the signed-response consumer. Imported CERTIFIED text is not authority. */
(function(root,factory){if(typeof module==='object')module.exports=factory(require('../BSD_CURVE_RECORD_v0_1_20260907/bsd-record.js'));else root.BSDLinkedRegisterModel=factory(root.BSDRecord);})(globalThis,function(B){'use strict';
 const same=(x,y,why)=>{if(B.canonical(x)!==B.canonical(y))throw Error(why);};
 function project(legacy,verified){
  const work=B.clone(legacy),derived=[],binding=verified?.packet.view.binding;let reduction=null,scope='UNVERIFIED',certificateId=null;
  if(verified){
   const {packet:q,assessment:a}=verified;
   same(binding.legacyContextId,legacy.curve.contextId,'T4 result belongs to another curve context');same(JSON.parse(q.input.curveBytes).curve,legacy.curve,'T4 plotting presentation does not match this curve');
   if(a.status==='PASS'){
    const cert=a.certificate;if(!cert||!a.certificateId)throw Error('Full T4 assessment required');
    same(cert.packetHash,binding.packetHash,'T4 packet hash mismatch');same(cert.modelId,q.view.model.modelId,'T4 model mismatch');same(cert.contextId,q.t4.record.contextId,'T4 certificate context mismatch');same(cert.normalizationId,binding.normalizationId,'T4 normalization mismatch');same(cert.markingId,binding.markingId,'T4 marking mismatch');same(cert.result,q.t4.proof.globalResult,'T4 result mismatch');
    if(q.t4.candidateInventory.complete!==true)throw Error('Complete inventory required for Tamagawa comparison');
    const local=q.t4.proof.transfers.filter(x=>x.result.reduction!=='GOOD'),badPrimes=local.map(x=>x.p),factors=local.map(x=>({p:x.p,cp:x.result.tamagawaNumber}));
    same(badPrimes,cert.result.curveBadPrimes,'T4 bad-prime inventory mismatch');same(String(factors.reduce((n,x)=>n*BigInt(x.cp),1n)),cert.result.tamagawaProduct,'T4 product mismatch');
    certificateId=a.certificateId;scope='T4_VERIFIED_GLOBAL_REDUCTION';reduction={...B.clone(cert.result),localData:B.clone(q.t4.proof.transfers)};
    const claim=B.claim(work.curve,'tamagawa',{badPrimes,factors,complete:true},{status:'CERTIFIED',method:'T4_EXACT_GLOBAL_REPLAY',software:'BSD_GLOBAL_REDUCTION_REPLAY_0.1.0',sourceLabel:'Full packet replayed by the localhost T4 public gate',certificate:{artifactSha256:a.certificateId,verifier:cert.verifier.name+'_'+cert.verifier.version,result:'GLOBAL_MINIMAL_NERON_AND_REDUCTION_PRODUCTS'}});
    const row={id:a.certificateId,claim,sourceHash:cert.packetHash,verification:'LOCAL_T4_PUBLIC_GATE_VERIFIED',contextId:q.view.contextId,verifiedModelId:cert.modelId,verifiedNormalizationId:cert.normalizationId,certificate:B.clone(cert)};
    derived.push(row);work.records.push(row);work.active.tamagawa=row.id;
   }else if(a.status==='UNAVAILABLE'&&a.certificate===null){scope='T4_VERIFIED_LISTED_PRIMES_ONLY';reduction={knownPrimeProducts:B.clone(a.knownPrimeProducts),remainingCofactor:a.remainingCofactor,localData:B.clone(q.t4.proof.transfers),globalNormalization:null};}
   else throw Error('Unsupported T4 assessment');
  }
  const pt=verified?.pt1;let pointCertificate=null;
  if(pt?.packet&&pt.assessment?.certificate){
   const c=pt.assessment.certificate,pp=pt.packet,q=verified.packet;
   same(c.binding,pp.binding,'PT1 result binding');same(c.binding.linkedContextId,q.view.contextId,'PT1 stale context');same(c.binding.sourceHash,q.sourceHash,'PT1 source mismatch');same(pp.parent.bytes,q.t4.parent.bytes,'PT1 exact parent mismatch');same(c.modelId,q.view.inputModel.modelId,'PT1 model mismatch');
   if(c.status==='COMPLETE_TORSION'&&pt.assessment.status==='PASS'){
    pointCertificate=c;const id=pt.assessment.certificateId,claim=B.claim(work.curve,'torsion_order',c.torsionOrder,{status:'CERTIFIED',method:'PT1_EXACT_TORSION_REPLAY',software:'PT1_0.1.0',sourceLabel:'Complete group independently replayed by PT1 browser-local gate',certificate:{artifactSha256:id,verifier:'BSD_POINTS_TORSION_REPLAY_0.1.0',result:'COMPLETE_RATIONAL_TORSION'}});
    const row={id,claim,sourceHash:c.packetHash,verification:'LOCAL_EXACT_TORSION_REPLAY',contextId:q.view.contextId,certificate:B.clone(c)};derived.push(row);work.records.push(row);work.active.torsion_order=id;
   }
  }
  const comparison=B.compare(work);if(pointCertificate)for(const f of ['inputs','dependencyClosure'])for(const row of comparison[f]||[])if(row.component==='torsion_order')Object.assign(row,{assessment:'LOCAL_EXACT_TORSION_REPLAY',method:'LOCAL_EXACT_TORSION_REPLAY'});
  comparison.rankLowerBound=pointCertificate?.rankLowerBound||null;
  let periodEnclosure=null;const up=verified?.u1;
  if(up?.assessment?.status==='PASS'&&up.assessment.bindingVerified&&up.record?.request.binding.neron&&verified.assessment.status==='PASS'){
   same(up.record.request.binding.linkedContextId,verified.packet.view.contextId,'U1 stale context');same(up.record.request.binding.modelId,verified.packet.view.model.modelId,'U1 model mismatch');
   periodEnclosure={component:'real_period',value:B.clone(up.record.result.realTotal),assessment:'RIGOROUS_ENCLOSURE',method:'U1_EXACT_DYADIC_REAL_AGM',certificateId:up.assessment.certificateId};
   comparison.inputs=(comparison.inputs||[]).filter(x=>x.component!=='real_period').concat([periodEnclosure]);comparison.reasons=comparison.reasons.filter(s=>s!=='Missing real_period');comparison.realPeriodEnclosure=periodEnclosure;comparison.shaInferred=null;comparison.standing='INCOMPLETE';if(!comparison.reasons.length)comparison.reasons.push('U1 interval comparison does not compute ratios or Sha');
  }
  for(const field of ['inputs','dependencyClosure'])for(const row of comparison[field]||[])if(certificateId&&row.id===certificateId)Object.assign(row,{assessment:'LOCAL_T4_PUBLIC_GATE_VERIFIED',method:'T4_EXACT_GLOBAL_REPLAY',certificateId,packetHash:binding.packetHash});
  comparison.linkedReduction={scope,contextId:verified?.packet.view.contextId||null,packetHash:binding?.packetHash||null,certificateId};
  return {schema:'BSD_LINKED_COMPARISON_V1',legacyContextId:legacy.curve.contextId,contextId:verified?.packet.view.contextId||null,scope,comparison,derived,reduction,periodEnclosure,activeComponents:[...new Set([...Object.keys(work.active),...(periodEnclosure?['real_period']:[])])],periodValueStatus:periodEnclosure?'RIGOROUS_ENCLOSURE':work.active.real_period?work.records.find(r=>r.id===work.active.real_period).claim.evidence.status:'MISSING',verdict:'NO_BSD_PROOF_OR_INDEPENDENT_SHA_ORDER'};
 }
 return Object.freeze({project});
});
