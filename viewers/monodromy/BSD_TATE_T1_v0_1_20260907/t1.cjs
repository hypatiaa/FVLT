'use strict';
// Bounded T1 proof replay. This is not a full Tate algorithm.
const fs=require('node:fs'),path=require('node:path');
const C=require('../BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/model-replay.cjs');
const {R,S,hash,canonical,model,transform,compose,pointMap,verifyTransport}=C;
const ID={u:'1',r:'0',s:'0',t:'0'};
const panels=['MCOMB','CARRIER_ADDITION','ELLIPTIC_MODEL','MARKED_CLIFFORD_LEAF','EXACT_CURVE_BSD','PRIME_PRODUCT'];
const fail=m=>{throw Error(m);};
const eq=(a,b,m)=>{if(canonical(a)!==canonical(b))fail(m);};
const shaFile=f=>require('node:crypto').createHash('sha256').update(fs.readFileSync(f)).digest('hex');
function verifier(){return {name:'BSD_TATE_T1_REPLAY',version:'0.1.0',sha256:shaFile(__filename),arithmeticSha256:shaFile(require.resolve('../BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/model-replay.cjs'))};}
function context(q){q.contextId=hash({anchor:q.anchor,modelId:q.normalization.targetModelId,normalization:q.normalization,transformations:q.transformations,twistLineage:q.twistLineage});q.panelBindings=panels.map(panel=>({panel,contextId:q.contextId,modelId:q.normalization.targetModelId,normalizationId:hash(q.normalization),markingId:hash(q.marking)}));}
function source(q,body){const bytes=canonical(body),sha256=hash(bytes);if(!q.sources.some(s=>s.sha256===sha256))q.sources.push({sha256,mediaType:'application/json',bytes});return sha256;}
function seed(ainvs,selectedMultiplier='1',points=[]){
 const m=model(ainvs),q={schema:'BSD_MINIMAL_TATE_RECORD_V1',anchor:{inputModelId:m.modelId,sourceHash:'',legacyContextId:null},contextId:'',models:[m],twistLineage:[],transformations:[],normalization:{modelDifferential:'dx/(2*y+a1*x+a3)',sourceSelectedMultiplier:selectedMultiplier,targetModelId:m.modelId,targetSelectedMultiplier:selectedMultiplier,composedPullbackFactor:'1',neron:null},marking:{basisMatrix:[['1','0'],['0','1']],convention:'TARGET_BASIS_EQUALS_U_TIMES_M_SOURCE_BASIS',mcombSourceHash:null,phaseConvention:'FULL_PERIOD_FRACTIONS_MOD_Z2'},points:[],minimalModel:null,localData:[],badPrimeInventory:null,aggregate:null,panelBindings:[],sources:[]};
 q.anchor.sourceHash=source(q,{field:'Q',ainvs,selectedMultiplier});
 q.points=points.map(coordinates=>({modelId:m.modelId,coordinates,sourceHash:source(q,{modelId:m.modelId,coordinates})}));context(q);verifyTransport(q);return q;
}
function transport(parent,steps){
 verifyTransport(parent);if(!Array.isArray(steps)||steps.length>3)fail('T1 adapter allows at most three additional steps');
 const q=structuredClone(parent),parentTarget=q.normalization.targetModelId,originalPoints=q.points.filter(p=>p.modelId===parentTarget);let composite={...ID};
 // All old claims remain in the bound parent bytes. Child claims are recomputed separately.
 q.minimalModel=null;q.localData=[];q.badPrimeInventory=null;q.aggregate=null;q.normalization.neron=null;
 for(const w of steps){
  const from=q.models.find(m=>m.modelId===q.normalization.targetModelId),to=model(transform(from.ainvs,w));
  if(!q.models.some(m=>m.modelId===to.modelId))q.models.push(to);
  const c=S(C.div(R(q.normalization.targetSelectedMultiplier),R(w.u)));
  q.transformations.push({fromModelId:from.modelId,toModelId:to.modelId,direction:'SOURCE_TO_TARGET',urst:w,pullbackModelDifferentialFactor:w.u,targetSelectedMultiplier:c});
  composite=compose(composite,w);q.normalization.targetModelId=to.modelId;q.normalization.targetSelectedMultiplier=c;
  q.normalization.composedPullbackFactor=S(C.mul(R(q.normalization.composedPullbackFactor),R(w.u)));
 }
 const a=parent.models.find(m=>m.modelId===parentTarget).ainvs;
 // Preserve all old addresses, including repeated visits; append one transported visit per input visit.
 const indices=parent.points.map((p,i)=>p.modelId===parentTarget?i:-1).filter(i=>i>=0);
 const pointTransports=originalPoints.map((p,index)=>{
  const coordinates=pointMap(a,composite,p.coordinates),modelId=q.normalization.targetModelId;
  const mapped={modelId,coordinates,sourceHash:source(q,{modelId,coordinates})};q.points.push(mapped);
  return {sourcePointIndex:indices[index],targetPointIndex:q.points.length-1,sourceHash:p.sourceHash,targetHash:mapped.sourceHash};
 });
 if(q.points.length>200||q.models.length>40||q.transformations.length>16||q.sources.length>300)fail('Transport record work cap');
 context(q);verifyTransport(q);
 return {record:q,adapter:{parentContextId:parent.contextId,sourceModelId:parentTarget,targetModelId:q.normalization.targetModelId,steps,composite,pullbackModelDifferentialFactor:composite.u,targetSelectedMultiplier:q.normalization.targetSelectedMultiplier,pointTransports}};
}
function clearing(a){let D=1n;const gcd=(a,b)=>b?gcd(b,a%b):a;for(const s of a){const d=R(s)[1];D=D/gcd(D,d)*d;if(D.toString().length>96)fail('Denominator clearing work cap');}const w={u:S([1n,D]),r:'0',s:'0',t:'0'};const out=transform(a,w);out.forEach(s=>{if(R(s)[1]!==1n)fail('Denominator clearing failed');});return w;}
function primeProof(s){if(typeof s!=='string'||! /^(0|[1-9][0-9]*)$/.test(s))fail('Canonical prime required');const p=Number(s);if(!Number.isSafeInteger(p)||p<2||p>1009)fail('UNAVAILABLE: prime proof/count domain is 2..1009');const trials=[];for(let d=2;d*d<=p;d++){const remainder=p%d;if(!remainder)fail('Composite prime');trials.push({divisor:String(d),remainder:String(remainder)});}return {method:'EXHAUSTIVE_TRIAL_DIVISION_TO_SQRT',p:s,trials};}
function valuation(s,p){let [n,d]=R(s);if(!n)return {kind:'INFINITY'};const P=BigInt(p);let exponent=0;while(n%P===0n){n/=P;exponent++;}while(d%P===0n){d/=P;exponent--;}return {kind:'FINITE',exponent:String(exponent),unit:S([n,d])};}
function mod(s,p){const P=BigInt(p),[n,d]=R(s);if(d%P===0n)fail('Non-p-integral model');for(let k=1n;k<P;k++)if(d*k%P===1n)return Number(((n*k)%P+P)%P);fail('No residue inverse');}
function count(a,p){const v=a.map(x=>mod(x,p)),byX=[];let total=1;for(let x=0;x<p;x++){let n=0;for(let y=0;y<p;y++)if(((y*y+v[0]*x*y+v[2]*y-x*x*x-v[1]*x*x-v[3]*x-v[4])%p+p)%p===0)n++;byX.push(String(n));total+=n;}return {reducedAinvs:v.map(String),affineCountsByX:byX,pointsIncludingInfinity:String(total),ap:String(p+1-total)};}
function inventory(m){let remaining=R(m.invariants.discriminant);if(remaining[1]!==1n)fail('Integral model required for inventory');let cofactor=remaining[0]<0n?-remaining[0]:remaining[0];const factors=[];for(let p=2;p<=1009&&cofactor>1n;p++){let proof;try{proof=primeProof(String(p));}catch{continue;}let exponent=0;while(cofactor%BigInt(p)===0n){cofactor/=BigInt(p);exponent++;}if(exponent)factors.push({p:String(p),exponent:String(exponent),primeProof:proof});}return {scope:'MODEL_DISCRIMINANT_SUPPORT_NOT_CURVE_BAD_PRIMES',modelId:m.modelId,absoluteDiscriminant:String(remaining[0]<0n?-remaining[0]:remaining[0]),factors,remainingCofactor:String(cofactor),complete:cofactor===1n,trialDivisionBound:'1009'};}
function trace(record,pString){
 const proof=primeProof(pString),p=Number(pString),m=record.models.find(m=>m.modelId===record.normalization.targetModelId);
 if(m.ainvs.some(x=>R(x)[1]%BigInt(p)===0n))fail('Local model is not p-integral');
 const vd=valuation(m.invariants.discriminant,p),vc4=valuation(m.invariants.c4,p),vc6=valuation(m.invariants.c6,p);
 const base={schema:'BSD_TATE_T1_TRACE_V1',contextId:record.contextId,modelId:m.modelId,normalizationId:hash(record.normalization),markingId:hash(record.marking),p:pString,primeProof:proof,ainvs:m.ainvs,valuations:{discriminant:vd,c4:vc4,c6:vc6},steps:[{operation:'CHECK_P_INTEGRAL',denominatorResidues:m.ainvs.map(s=>String(R(s)[1]%BigInt(p)))},{operation:'VALUATIONS',discriminant:vd,c4:vc4,c6:vc6}],terminal:null};
 if(vd.exponent==='0'){
  const counts=count(m.ainvs,p);base.steps.push({operation:'UNIT_DISCRIMINANT',residue:String(mod(m.invariants.discriminant,p))},{operation:'COUNT_GOOD_FIBRE',...counts});
  base.terminal={branch:'GOOD_UNIT_DISCRIMINANT',status:'REPLAYABLE',result:{reduction:'GOOD',kodaira:'I0',split:null,discriminantValuation:'0',conductorExponent:'0',wildConductorContribution:'0',tamagawaNumber:'1',ap:counts.ap,eulerPolynomial:['1',String(-BigInt(counts.ap)),pString],localMinimality:'PROVED_BY_UNIT_DISCRIMINANT'}};
 }else if(p>=5&&vc4.exponent==='0'){
  const n=Number(vd.exponent),negativeC6=mod(S(C.mul(R('-1'),R(m.invariants.c6))),p),roots=[];if(n<1||!negativeC6)fail('Invalid multiplicative precondition');
  for(let y=0;y<p;y++)if(y*y%p===negativeC6)roots.push(String(y));const split=roots.length===2;if(![0,2].includes(roots.length))fail('Invalid square root count');
  base.steps.push({operation:'MULTIPLICATIVE_C4_UNIT',residue:String(mod(m.invariants.c4,p))},{operation:'SPLIT_NEGATIVE_C6',residue:String(negativeC6),roots});
  base.terminal={branch:'MULTIPLICATIVE_P_GE_5',status:'REPLAYABLE',result:{reduction:split?'SPLIT_MULTIPLICATIVE':'NONSPLIT_MULTIPLICATIVE',kodaira:'I'+n,split,discriminantValuation:String(n),conductorExponent:'1',wildConductorContribution:'0',tamagawaNumber:String(split?n:n%2?1:2),ap:split?'1':'-1',eulerPolynomial:['1',split?'-1':'1'],localMinimality:'PROVED_BY_C4_UNIT'}};
 }else base.terminal={branch:'UNSUPPORTED',status:'UNAVAILABLE',reason:p<5?'WILD_OR_MULTIPLICATIVE_SMALL_CHARACTERISTIC_REQUIRES_T3':'ADDITIVE_BRANCH_REQUIRES_T2'};
 return base;
}
function assemble(parentBytes,steps,p,backend=null){const parent=JSON.parse(parentBytes),adapted=transport(parent,steps),m=adapted.record.models.find(m=>m.modelId===adapted.record.normalization.targetModelId);return {schema:'BSD_TATE_T1_PACKET_V1',parent:{sha256:hash(parentBytes),bytes:parentBytes},...adapted,inventory:inventory(m),backend,trace:trace(adapted.record,p)};}
function replay(packet){
 if(hash(packet.parent.bytes)!==packet.parent.sha256)fail('Parent bytes hash mismatch');const parent=JSON.parse(packet.parent.bytes),want=transport(parent,packet.adapter.steps);
 eq(packet.record,want.record,'Child transport/context/point replay mismatch');eq(packet.adapter,want.adapter,'Adapter tuple or differential replay mismatch');
 const m=packet.record.models.find(m=>m.modelId===packet.record.normalization.targetModelId);eq(packet.inventory,inventory(m),'Model inventory mismatch');
 const expected=trace(packet.record,packet.trace.p);eq(packet.trace,expected,'Local trace replay mismatch');
 if(packet.backend)require('./pari-adapter.cjs').verifyReport(packet.backend,parent,packet.adapter.steps,packet.trace);
 const bindings={packetHash:hash(packet),parentSourceHash:packet.parent.sha256,contextId:packet.record.contextId,sourceModelId:packet.adapter.sourceModelId,modelId:m.modelId,normalizationId:hash(packet.record.normalization),markingId:hash(packet.record.marking),p:packet.trace.p,traceHash:hash(packet.trace),verifier:verifier()};
 if(expected.terminal.status==='UNAVAILABLE')return {...bindings,status:'UNAVAILABLE',reason:expected.terminal.reason,transportStatus:'PASS',backendAssessment:packet.backend?'REPLAYED_TRANSFORMATIONS_SOURCE_REPORTED_REDUCTION':'ABSENT',certificate:null,bsdPromotion:false};
 const certificate={schema:'BSD_TATE_T1_LOCAL_CERTIFICATE_V1',...bindings,status:'CERTIFIED',scope:'LOCAL_MODEL_AT_ONE_PRIME_ONLY',method:expected.terminal.branch,result:expected.terminal.result,assumptions:[],globalMinimality:'NOT_ASSESSED',neronDifferential:'NOT_ASSESSED',bsdPromotion:false};
 return {...bindings,status:'PASS',transportStatus:'PASS',backendAssessment:packet.backend?'REPLAYED_TRANSFORMATIONS_AND_MATCHING_LOCAL_RESULT':'ABSENT',certificateId:hash(certificate),certificate,bsdPromotion:false};
}
module.exports={...C,ID,panels,seed,transport,clearing,primeProof,valuation,mod,count,inventory,trace,assemble,replay,verifier,shaFile};
