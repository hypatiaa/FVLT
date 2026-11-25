'use strict';
// Exact transport, reduction consistency and scoped good-prime certification. No full Tate engine.
const crypto = require('node:crypto');
const fail = message => { throw new Error(message); };
const gcd = (a,b) => { a=a<0n?-a:a; b=b<0n?-b:b; while(b)[a,b]=[b,a%b]; return a; };
function rat(n,d=1n) { if(!d)fail('Zero denominator'); if(n.toString(2).length>16384||d.toString(2).length>16384)fail('Exact intermediate work cap'); if(d<0n){n=-n;d=-d;} const g=gcd(n,d); return [n/g,d/g]; }
function R(s) { if(typeof s!=='string'||s.length>194||! /^(0|-?[1-9][0-9]*)(\/[1-9][0-9]*)?$/.test(s))fail('Invalid rational string'); const [n,d='1']=s.split('/'); if(n.replace('-','').length>96||d.length>96)fail('Rational size cap'); const q=rat(BigInt(n),BigInt(d)); if(S(q)!==s)fail('Noncanonical rational'); return q; }
const S=q=>q[1]===1n?String(q[0]):q.join('/');
const add=(a,b)=>rat(a[0]*b[1]+b[0]*a[1],a[1]*b[1]);
const neg=a=>[-a[0],a[1]], sub=(a,b)=>add(a,neg(b));
const mul=(a,b)=>rat(a[0]*b[0],a[1]*b[1]);
const div=(a,b)=>rat(a[0]*b[1],a[1]*b[0]);
const pow=(a,k)=>rat(a[0]**BigInt(k),a[1]**BigInt(k));
const times=(a,n)=>mul(a,[BigInt(n),1n]);
const sum=(...xs)=>xs.reduce(add,[0n,1n]);
function canonical(x){ if(Array.isArray(x))return '['+x.map(canonical).join(',')+']'; if(x&&typeof x==='object')return '{'+Object.keys(x).sort().map(k=>JSON.stringify(k)+':'+canonical(x[k])).join(',')+'}'; return JSON.stringify(x); }
const hash=x=>crypto.createHash('sha256').update(typeof x==='string'?x:canonical(x)).digest('hex');
function shape(x,keys){if(!x||Array.isArray(x)||typeof x!=='object'||Object.keys(x).sort().join('|')!==keys.slice().sort().join('|'))fail('Unexpected fields');}
function invariants(a){
 if(!Array.isArray(a)||a.length!==5)fail('Five coefficients required');
 const [a1,a2,a3,a4,a6]=a.map(R), b2=sum(pow(a1,2),times(a2,4)),b4=sum(times(a4,2),mul(a1,a3)),b6=sum(pow(a3,2),times(a6,4));
 const b8=sum(mul(pow(a1,2),a6),times(mul(a2,a6),4),neg(mul(mul(a1,a3),a4)),mul(a2,pow(a3,2)),neg(pow(a4,2)));
 const c4=sub(pow(b2,2),times(b4,24)),c6=sum(neg(pow(b2,3)),times(mul(b2,b4),36),times(b6,-216));
 const discriminant=sum(neg(mul(pow(b2,2),b8)),times(pow(b4,3),-8),times(pow(b6,2),-27),times(mul(mul(b2,b4),b6),9));
 if(!discriminant[0])fail('Singular model');
 return Object.fromEntries(Object.entries({b2,b4,b6,b8,c4,c6,discriminant,j:div(pow(c4,3),discriminant)}).map(([k,v])=>[k,S(v)]));
}
function model(a){const body={field:'Q',ainvs:a,invariants:invariants(a)}; return {modelId:hash(body),...body};}
function transform(a,w){
 shape(w,['u','r','s','t']); const [u,r,s,t]=['u','r','s','t'].map(k=>R(w[k])); if(!u[0])fail('u must be nonzero');
 const [a1,a2,a3,a4,a6]=a.map(R);
 return [div(sum(a1,times(s,2)),u),div(sum(a2,neg(mul(a1,s)),times(r,3),neg(pow(s,2))),pow(u,2)),div(sum(a3,mul(a1,r),times(t,2)),pow(u,3)),div(sum(a4,times(mul(a2,r),2),neg(mul(a1,sum(mul(r,s),t))),neg(mul(a3,s)),times(pow(r,2),3),times(mul(s,t),-2)),pow(u,4)),div(sum(a6,neg(mul(mul(a1,r),t)),mul(a2,pow(r,2)),neg(mul(a3,t)),mul(a4,r),pow(r,3),neg(pow(t,2))),pow(u,6))].map(S);
}
function inverse(w){const [u,r,s,t]=['u','r','s','t'].map(k=>R(w[k]));return {u:S(div(R('1'),u)),r:S(neg(div(r,pow(u,2)))),s:S(neg(div(s,u))),t:S(div(sub(mul(r,s),t),pow(u,3)))};}
// Composition is first w: E0 -> E1, then v: E1 -> E2.
function compose(w,v){const [u,r,s,t]=['u','r','s','t'].map(k=>R(w[k])),[U,V,W,T]=['u','r','s','t'].map(k=>R(v[k]));return {u:S(mul(u,U)),r:S(sum(r,mul(pow(u,2),V))),s:S(sum(s,mul(u,W))),t:S(sum(t,mul(mul(s,pow(u,2)),V),mul(pow(u,3),T)))};}
function pointOn(a,p){if(p?.infinity===true){shape(p,['infinity']);return true;}shape(p,['x','y']);const [a1,a2,a3,a4,a6]=a.map(R),x=R(p.x),y=R(p.y);return !sub(sum(pow(y,2),mul(mul(a1,x),y),mul(a3,y)),sum(pow(x,3),mul(a2,pow(x,2)),mul(a4,x),a6))[0];}
function pointMap(a,w,p){if(!pointOn(a,p))fail('Off-curve point');if(p.infinity)return {infinity:true};const [u,r,s,t]=['u','r','s','t'].map(k=>R(w[k])),dx=sub(R(p.x),r);const q={x:S(div(dx,pow(u,2))),y:S(div(sum(R(p.y),neg(mul(s,dx)),neg(t)),pow(u,3)))};if(!pointOn(transform(a,w),q))fail('Point transport failed');return q;}
function phaseMap(v,m){const [a,b,c,d]=m.flat().map(x=>{const q=R(x);if(q[1]!==1n)fail('Integral marking required');return q;});if(S(sub(mul(a,d),mul(b,c)))!=='1')fail('Marking must have determinant +1');const [x,y]=v.map(R);return [sub(mul(d,x),mul(c,y)),sub(mul(a,y),mul(b,x))].map(S);}
function verifyTransport(packet){
 if(Buffer.byteLength(JSON.stringify(packet),'utf8')>4000000)fail('Packet byte cap');
 function depth(x,n=0){if(n>24)fail('Nesting cap');if(x&&typeof x==='object')Object.values(x).forEach(v=>depth(v,n+1));}depth(packet);
 const sources=new Map();for(const src of packet.sources){if(sources.has(src.sha256)||hash(src.bytes)!==src.sha256)fail('Source bytes mismatch or duplicate');sources.set(src.sha256,src);}
 const sourceJSON=id=>{if(!sources.has(id))fail('Missing source artifact');return JSON.parse(sources.get(id).bytes);};
 function evidence(e){if(!sources.has(e.sourceHash))fail('Missing evidence source');if(e.method.startsWith('LOCAL_'))fail('Local evidence verifier not implemented');if(e.status==='CONDITIONAL'?!e.assumptions.length:!!e.assumptions.length)fail('Conditional assumptions mismatch');if(['CERTIFIED','RIGOROUS_BOUND'].includes(e.status)&&!e.certificate)fail('Missing certificate reference');const ordered=[...sources.keys()],at=ordered.indexOf(e.sourceHash);for(const id of e.dependencies)if(ordered.indexOf(id)<0||ordered.indexOf(id)>=at)fail('Missing, forward or self dependency');}
 const models=new Map();for(const m of packet.models){if(models.has(m.modelId)||canonical(model(m.ainvs))!==canonical(m))fail('Model identity or invariants mismatch');models.set(m.modelId,m);}
 if(!models.has(packet.anchor.inputModelId))fail('Missing anchor model');
 if(packet.anchor.legacyContextId!==null)fail('Legacy adapter requires independent packet replay; not implemented here');
 if(canonical(sourceJSON(packet.anchor.sourceHash))!==canonical({field:'Q',ainvs:models.get(packet.anchor.inputModelId).ainvs,selectedMultiplier:packet.normalization.sourceSelectedMultiplier}))fail('Anchor source mismatch');
 let twistLast=null;for(const edge of packet.twistLineage){if(!models.has(edge.baseModelId)||!models.has(edge.twistedModelId)||(twistLast&&edge.baseModelId!==twistLast))fail('Disconnected twist lineage');const a=models.get(edge.baseModelId).ainvs;if(a.slice(0,3).some(x=>x!=='0')||!R(edge.parameter)[0])fail('Unsupported or zero twist');const d=R(edge.parameter);let wanted;if(edge.kind==='QUADRATIC_SHORT')wanted=['0','0','0',S(mul(R(a[3]),pow(d,2))),S(mul(R(a[4]),pow(d,3)))];else if(edge.kind==='QUARTIC_B_ZERO'&&a[4]==='0')wanted=['0','0','0',S(mul(R(a[3]),d)),'0'];else fail('Unsupported twist');if(canonical(wanted)!==canonical(models.get(edge.twistedModelId).ainvs))fail('Twist coefficients mismatch');const body={...edge};delete body.sourceHash;if(canonical(sourceJSON(edge.sourceHash))!==canonical(body))fail('Twist source mismatch');twistLast=edge.twistedModelId;}
 if(twistLast&&twistLast!==packet.anchor.inputModelId)fail('Twist does not anchor this curve');
 let last=packet.anchor.inputModelId,c=packet.normalization.sourceSelectedMultiplier,U=R('1');R(c);if(!R(c)[0])fail('Zero differential');
 const reachable=new Set([last]);
 for(const step of packet.transformations){if(step.fromModelId!==last||!models.has(step.toModelId))fail('Disconnected model chain');const from=models.get(last),to=models.get(step.toModelId),want=transform(from.ainvs,step.urst);if(canonical(want)!==canonical(to.ainvs))fail('Transformation coefficients do not replay');if(step.direction!=='SOURCE_TO_TARGET'||step.pullbackModelDifferentialFactor!==step.urst.u)fail('Differential direction mismatch');c=S(div(R(c),R(step.urst.u)));if(step.targetSelectedMultiplier!==c)fail('Selected differential not preserved');U=mul(U,R(step.urst.u));last=step.toModelId;reachable.add(last);}
 const norm=packet.normalization;if(norm.targetModelId!==last||norm.targetSelectedMultiplier!==c||norm.composedPullbackFactor!==S(U))fail('Normalization chain mismatch');
 if(norm.modelDifferential!=='dx/(2*y+a1*x+a3)')fail('Wrong differential');
 const binding={anchor:packet.anchor,modelId:last,normalization:packet.normalization,transformations:packet.transformations,twistLineage:packet.twistLineage};
 if(packet.contextId!==hash(binding))fail('Context hash mismatch');
 const m=packet.marking.basisMatrix;phaseMap(['0','0'],m);
 if(packet.marking.mcombSourceHash!==null)fail('Mcomb source adapter requires inherited transport replay; not implemented here');
 for(const p of packet.points){if(!reachable.has(p.modelId)||!pointOn(models.get(p.modelId).ainvs,p.coordinates))fail('Point membership failed');if(canonical(sourceJSON(p.sourceHash))!==canonical({modelId:p.modelId,coordinates:p.coordinates}))fail('Point source mismatch');}
 const panels=new Set();for(const panel of packet.panelBindings){if(panels.has(panel.panel)||panel.contextId!==packet.contextId||panel.normalizationId!==hash(norm)||panel.markingId!==hash(packet.marking)||!reachable.has(panel.modelId))fail('Stale or duplicate panel binding');panels.add(panel.panel);}
 if(panels.size!==6)fail('Every linked panel must be bound');
 function prime(s){const n=Number(s);if(!Number.isSafeInteger(n)||n<2||n>1009)fail('Prime verification work cap');for(let d=2;d*d<=n;d++)if(n%d===0)fail('Composite prime field');return n;}
 const valuation=(s,p)=>{let [n,d]=R(s),v=0;const P=BigInt(p);if(!n)fail('Zero valuation input');while(n%P===0n){n/=P;v++;}while(d%P===0n){d/=P;v--;}return v;};
 if(packet.minimalModel){const q=packet.minimalModel;if(!reachable.has(q.modelId))fail('Unlinked minimal model');evidence(q.evidence);const a=models.get(q.modelId).ainvs;if(q.scope==='GLOBAL_Q'){if(q.prime!==null||a.some(s=>R(s)[1]!==1n))fail('Global minimal claim requires an integral model');}else{const p=prime(q.prime);if(a.some(s=>R(s)[1]%BigInt(p)===0n))fail('Local model is not p-integral');}}
 if(norm.neron){evidence(norm.neron.evidence);if(!packet.minimalModel||packet.minimalModel.scope!=='GLOBAL_Q'||norm.neron.modelId!==packet.minimalModel.modelId||norm.neron.modelId!==last)fail('Neron reference requires the stated global minimal target');}
 const local=new Map(),localAssessments=[];
 const modulo=(value,p)=>{
  const P=BigInt(p),[n,d]=R(value),a=(n%P+P)%P,b=d%P;
  if(!b)fail('Nonintegral invariant modulo p');
  for(let k=1n;k<P;k++)if(b*k%P===1n)return Number(a*k%P);
  fail('No modular inverse');
 };
 const square=(a,p)=>{for(let y=1;y<p;y++)if(y*y%p===a)return true;return false;};
 const checkAdditiveTamagawa=(kodaira,cp)=>{
  const allowed={II:[1n],'II*':[1n],III:[2n],'III*':[2n],IV:[1n,3n],'IV*':[1n,3n],'I0*':[1n,2n,4n]};
  const values=allowed[kodaira]||(/^I[1-9][0-9]*[*]$/.test(kodaira)?[2n,4n]:null);
  if(!values||!values.includes(cp))fail('Tamagawa number incompatible with Kodaira type');
 };
 const verifier={name:'BSD_LOCAL_REDUCTION_REFERENCE',version:'0.3.0',sha256:hash(require('node:fs').readFileSync(__filename,'utf8'))};
 for(const q of packet.localData){
  const p=prime(q.p);
  if(local.has(q.p)||!reachable.has(q.modelId))fail('Duplicate local prime or unlinked model');
  local.set(q.p,q);evidence(q.evidence);if(q.minimalityEvidence)evidence(q.minimalityEvidence);
  const binding={contextId:packet.contextId,modelId:q.modelId,normalizationId:hash(norm),p:q.p};
  const inputRecordHash=hash(q);
  if(!q.result){localAssessments.push({...binding,assessment:'UNAVAILABLE',producerStatus:q.evidence.status,inputRecordHash});continue;}
  const modelQ=models.get(q.modelId);
  if(modelQ.ainvs.some(s=>R(s)[1]%BigInt(p)===0n))fail('Local model is not p-integral');
  const r=q.result,n=Number(r.discriminantValuation),f=Number(r.conductorExponent),w=Number(r.wildConductorContribution),cp=BigInt(r.tamagawaNumber);
  if(![n,f,w].every(x=>Number.isSafeInteger(x)&&x>=0&&x<=16384))fail('Local exponent work cap');
  if(valuation(modelQ.invariants.discriminant,p)!==n||w>f||p>3&&w!==0)fail('Local valuation or wild conductor mismatch');
  const conductorBound=p===2?8:p===3?5:2;
  if(f>conductorBound)fail('Conductor exponent exceeds the bound over Q at p='+p);
  if(r.reduction==='GOOD'){
   if(n!==0||f!==0||w!==0||cp!==1n||r.kodaira!=='I0'||r.split!==null)fail('Good reduction consistency');
   const a=modelQ.ainvs.map(s=>modulo(s,p));let count=1;
   for(let x=0;x<p;x++)for(let y=0;y<p;y++)if(((y*y+a[0]*x*y+a[2]*y-x*x*x-a[1]*x*x-a[3]*x-a[4])%p+p)%p===0)count++;
   const polynomial=['1',String(count-p-1),String(p)];
   if(canonical(r.eulerPolynomial)!==canonical(polynomial))fail('Good prime polynomial count mismatch');
   const certificate={...binding,schema:'BSD_GOOD_PRIME_CERTIFICATE_V1',verifier,
    method:'P_INTEGRAL_UNIT_DISCRIMINANT_AND_EXHAUSTIVE_FP_COUNT',
    ainvs:modelQ.ainvs,discriminant:modelQ.invariants.discriminant,reducedAinvs:a.map(String),
    discriminantResidue:String(modulo(modelQ.invariants.discriminant,p)),
    pointsIncludingInfinity:String(count),ap:String(p+1-count),eulerPolynomial:polynomial,
    localMinimality:'PROVED_AT_THIS_PRIME_BY_UNIT_DISCRIMINANT',kodaira:'I0',
    conductorExponent:'0',tamagawaNumber:'1',assumptions:[],dependencies:[],
    scope:'THIS_MODEL_AND_THIS_PRIME_ONLY'};
   localAssessments.push({...binding,producerStatus:q.evidence.status,inputRecordHash,
    assessment:'LOCAL_EXACT_GOOD_REDUCTION',status:'CERTIFIED',certificateId:hash(certificate),certificate});
  }else{
   if(!q.minimalityEvidence)fail('Bad-prime result lacks minimality evidence');
   if(n<1)fail('Bad reduction requires positive discriminant valuation');
   const checkedRules=['Q_CONDUCTOR_EXPONENT_BOUND','CONDUCTOR_DISCRIMINANT_INEQUALITY'];
   if(p>=5){
    const c4=modulo(modelQ.invariants.c4,p),expected=c4===0?'ADDITIVE':'MULTIPLICATIVE';
    if(expected==='ADDITIVE'&&r.reduction!=='ADDITIVE'||expected==='MULTIPLICATIVE'&&!['SPLIT_MULTIPLICATIVE','NONSPLIT_MULTIPLICATIVE'].includes(r.reduction))fail('Reduction type contradicts c4 and discriminant');
    checkedRules.push('BAD_PRIME_C4_REDUCTION_TYPE_P_GE_5');
    if(expected==='MULTIPLICATIVE'){
     const negativeC6=(p-modulo(modelQ.invariants.c6,p))%p;
     if(!negativeC6)fail('Multiplicative c6 residue cannot vanish');
     const split=square(negativeC6,p);
     if(r.split!==split||r.reduction!==(split?'SPLIT_MULTIPLICATIVE':'NONSPLIT_MULTIPLICATIVE'))fail('Splitting contradicts the nonzero square test for -c6');
     checkedRules.push('NEGATIVE_C6_NONZERO_SQUARE_SPLITTING_P_GE_5');
    }
   }
   if(f>n)fail('Conductor exponent exceeds the discriminant valuation');
   if(['SPLIT_MULTIPLICATIVE','NONSPLIT_MULTIPLICATIVE'].includes(r.reduction)){
    const split=r.reduction==='SPLIT_MULTIPLICATIVE';
    if(r.kodaira!=='I'+n||f!==1||w!==0||r.split!==split||cp!==(split?BigInt(n):n%2?1n:2n)||canonical(r.eulerPolynomial)!==canonical(['1',split?'-1':'1']))fail('Multiplicative consistency');
   }else if(r.reduction==='ADDITIVE'){
    if(f<2||f-w!==2||r.split!==null||canonical(r.eulerPolynomial)!=='["1"]')fail('Additive consistency');
    if(p>=5){
     // Only a consistency rule under the submitted p-minimality claim.
     // v_p(0)=+infinity: j=0 belongs to the potentially good branch.
     const vj=modelQ.invariants.j==='0'?null:valuation(modelQ.invariants.j,p);
     let expectedKodaira;
     if(vj!==null&&vj<0){
      const m=-vj;
      if(n!==6+m)fail('Additive discriminant valuation contradicts the pole order of j');
      expectedKodaira='I'+m+'*';
     }else{
      expectedKodaira={2:'II',3:'III',4:'IV',6:'I0*',8:'IV*',9:'III*',10:'II*'}[n];
      if(!expectedKodaira)fail('Additive discriminant valuation incompatible with claimed tame minimality');
     }
     if(r.kodaira!==expectedKodaira)fail('Kodaira label contradicts discriminant and j valuations');
     checkedRules.push('ADDITIVE_KODAIRA_FROM_DISCRIMINANT_AND_J_P_GE_5');
    }
    checkAdditiveTamagawa(r.kodaira,cp);
   }else fail('Unknown reduction type');
   checkedRules.push('KODAIRA_TAMAGAWA_AND_EULER_CONSISTENCY');
   localAssessments.push({...binding,producerStatus:q.evidence.status,inputRecordHash,
    assessment:'CONSISTENCY_CHECKED_SOURCE_REPORT',checkedRules,localMinimality:'SOURCE_REPORTED_NOT_LOCALLY_VERIFIED',
    tamagawaAssessment:'NOT_LOCALLY_CERTIFIED'});
  }
 }
 const inventory=packet.badPrimeInventory;if(inventory){evidence(inventory.evidence);if(!packet.minimalModel||packet.minimalModel.scope!=='GLOBAL_Q'||packet.minimalModel.modelId!==inventory.modelId)fail('Inventory lacks global minimal-model claim');let product=1n,lastPrime=1;for(const q of inventory.factors){const p=prime(q.p);if(p<=lastPrime||BigInt(q.exponent)>16384n)fail('Unsorted factorization or exponent cap');lastPrime=p;product*=BigInt(p)**BigInt(q.exponent);if(product.toString(2).length>16384)fail('Factorization product work cap');}product*=BigInt(inventory.remainingCofactor);const d=R(models.get(inventory.modelId).invariants.discriminant);if(d[1]!==1n||product!==(d[0]<0n?-d[0]:d[0])||inventory.complete&&inventory.remainingCofactor!=='1')fail('Incomplete or incorrect discriminant factorization');}
 if(packet.aggregate){const q=packet.aggregate;evidence(q.evidence);if(!inventory?.complete||q.modelId!==inventory.modelId||canonical(q.localDataPrimes)!==canonical(inventory.factors.map(f=>f.p)))fail('Aggregate requires all bad primes');let C=1n,N=1n;for(const p of q.localDataPrimes){const r=local.get(p);if(!r?.result||r.modelId!==q.modelId||r.result.reduction==='GOOD')fail('Missing aggregate local data');C*=BigInt(r.result.tamagawaNumber);N*=BigInt(p)**BigInt(r.result.conductorExponent);}if(String(C)!==q.tamagawaProduct||String(N)!==q.conductor)fail('Incorrect aggregate product');}
 return {status:'PASS',scope:'EXACT_TRANSPORT_WITH_SCOPED_LOCAL_ASSESSMENTS',localAssessments,tateAssessment:'NOT_IMPLEMENTED',minimalityAssessment:'NOT_IMPLEMENTED',neronAssessment:'NOT_ESTABLISHED_BY_TRANSPORT',bsdPromotion:false};
}
module.exports={R,S,add,sub,mul,div,pow,canonical,hash,invariants,model,transform,inverse,compose,pointOn,pointMap,phaseMap,verifyTransport};
