'use strict';
require('./worker-guard.cjs')();
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),T=require('./t1.cjs'),P=require('./pari-adapter.cjs'),{assess}=require('./assess.cjs');
const checks=[],packets=[],clone=structuredClone;
function check(name,fn){fn();checks.push({name,status:'PASS'});}
function make(name,a,p,expected,points=[]){const parent=T.seed(a,'1',points),made=P.produce(parent,String(p)),packet=T.assemble(JSON.stringify(parent),made.steps,String(p),made.report),out=T.replay(packet);assert.equal(out.status,expected.status);if(expected.kodaira)assert.equal(out.certificate.result.kodaira,expected.kodaira);if(expected.cp)assert.equal(out.certificate.result.tamagawaNumber,expected.cp);packets.push({name,packet,assessment:out,expected});return packet;}
let witness;
check('37.a1 short nonminimal presentation maps (0,4) exactly to general minimal candidate',()=>{
 witness=make('37a1-nonminimal-at-37',['0','0','0','-16','16'],37,{status:'PASS',kodaira:'I1',cp:'1'},[{x:'0',y:'4'},{x:'0',y:'4'},{infinity:true}]);
 assert.deepEqual(witness.adapter.composite,{u:'2',r:'0',s:'0',t:'4'});assert.equal(witness.record.normalization.targetSelectedMultiplier,'1/2');assert.equal(witness.record.points.length,6);assert.equal(witness.adapter.pointTransports.length,3);assert.deepEqual(witness.record.points[3].coordinates,{x:'0',y:'0'});assert.deepEqual(witness.record.points[4].coordinates,{x:'0',y:'0'});assert.equal(witness.record.minimalModel,null);assert.equal(witness.record.normalization.neron,null);
 for(const b of witness.record.panelBindings){assert.equal(b.modelId,witness.adapter.targetModelId);assert.equal(b.normalizationId,T.hash(witness.record.normalization));}
});
for(const p of [2,3])check('Recovered good reduction on 37.a1 at '+p,()=>make('37a1-good-'+p,['0','0','0','-16','16'],p,{status:'PASS',kodaira:'I0',cp:'1'},[{x:'0',y:'4'}]));
for(const a2 of [1,2])for(const n of [1,2,3,4])check((a2===1?'Split':'Nonsplit')+' I'+n+' actual Tamagawa proof',()=>{const q=make('multip-'+a2+'-'+n,['0',String(a2),'0','0',String(5**n)],5,{status:'PASS',kodaira:'I'+n,cp:String(a2===1?n:n%2?1:2)});assert.equal(q.trace.terminal.result.split,a2===1);});
for(const p of [2,3])check('General a1 nonzero good fibre at '+p,()=>make('general-good-'+p,['1','0','0','0','1'],p,{status:'PASS',kodaira:'I0',cp:'1'}));
check('Good reduction when c4 is identically zero',()=>make('good-c4-zero',['0','0','0','0','1'],5,{status:'PASS',kodaira:'I0',cp:'1'}));
check('Prime/count work boundary 1009 is actually exercised',()=>make('good-at-1009',['0','0','1','-1','0'],1009,{status:'PASS',kodaira:'I0',cp:'1'}));
check('Documented PARI translated/sheared example',()=>{const q=make('pari-urst-example',['6','6','12','55','233'],31,{status:'PASS',kodaira:'I1',cp:'1'});assert.deepEqual(q.adapter.steps[1],{u:'2',r:'-5',s:'-3',t:'9'});});
const additive=[['II','5','5'],['III','5','25'],['IV','25','25'],['I0star','25','125'],['I1star','-75','875'],['IVstar','625','625'],['IIIstar','125','3125'],['IIstar','625','3125']];
for(const [label,A,B]of additive)check('Additive '+label+' remains unavailable with retained source report',()=>{const q=make('additive-'+label,['0','0','0',A,B],5,{status:'UNAVAILABLE'});assert(q.backend);assert.equal(q.trace.terminal.branch,'UNSUPPORTED');});
for(const [name,a,p]of [['wild2',['0','0','0','0','-1'],2],['wild3',['0','0','0','0','3'],3],['small-multip',['1','0','1','4','-6'],2]])check(name+' is not silently promoted',()=>make(name,a,p,{status:'UNAVAILABLE'}));
check('Rational denominators, negative scale and exact points survive PARI minimization',()=>{
 const a=['0','0','1','-1','0'],w={u:'-2',r:'1/3',s:'-1/2',t:'7/4'},b=T.transform(a,w),point=T.pointMap(a,w,{x:'0',y:'0'});
 const q=make('rational-denominators',b,37,{status:'PASS',kodaira:'I1',cp:'1'},[point]);assert.notEqual(q.adapter.steps[0].u,'1');assert(q.record.points.every(p=>T.pointOn(q.record.models.find(m=>m.modelId===p.modelId).ainvs,p.coordinates)));
});
check('Signed composite, inverse, full basis marking and differential transport',()=>{
 const p=T.seed(['0','0','1','-1','0'],'-3/2',[{x:'0',y:'0'}]);p.marking.basisMatrix=[['1','1'],['0','1']];p.panelBindings.forEach(x=>x.markingId=T.hash(p.marking));
 const w={u:'-2',r:'1/3',s:'-1/2',t:'7/4'},q=T.transport(p,[w,T.inverse(w)]);assert.deepEqual(q.adapter.composite,T.ID);assert.deepEqual(q.record.marking,p.marking);assert.equal(q.record.normalization.targetSelectedMultiplier,'-3/2');assert.deepEqual(T.phaseMap(['1/3','1/2'],p.marking.basisMatrix),['1/3','1/6']);
 const signed=T.transport(p,[{u:'-1',r:'0',s:'0',t:'0'}]);assert.equal(signed.adapter.pullbackModelDifferentialFactor,'-1');assert.equal(signed.record.normalization.targetSelectedMultiplier,'3/2');
});
check('Bound parent bytes retain twist lineage without treating a twist as an isomorphism',()=>{const parentBytes=fs.readFileSync(path.join(__dirname,'../BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/fixtures/separate-quadratic-twist.json'),'utf8'),p=JSON.parse(parentBytes),m=P.produce(p,'3'),q=T.assemble(parentBytes,m.steps,'3',m.report);assert.deepEqual(q.record.twistLineage,p.twistLineage);assert.equal(T.replay(q).status,'PASS');packets.push({name:'retained-quadratic-twist',packet:q,assessment:T.replay(q),expected:{status:'PASS'}});});
check('Exact membership works without a backend or minimality',()=>{const p=T.seed(['0','0','0','0','17'],'1',[{x:'4',y:'9'},{x:'2',y:'5'},{x:'-2',y:'-3'}]);assert.equal(p.minimalModel,null);assert.equal(T.verifyTransport(p).status,'PASS');assert.throws(()=>T.seed(['0','0','0','0','17'],'1',[{x:'4',y:'8'}]),/membership/);});
check('A direct local certificate needs no producer report',()=>{const p=T.seed(['0','1','0','0','25']);const q=T.assemble(JSON.stringify(p),[],'5');assert.equal(T.replay(q).certificate.result.tamagawaNumber,'2');packets.push({name:'backend-free-proof',packet:q,assessment:T.replay(q),expected:{status:'PASS'}});});
check('Incomplete model factorization remains visibly incomplete',()=>{const p=T.seed(['0','0','0','0','1013']);const q=T.assemble(JSON.stringify(p),[],'5');assert.equal(q.inventory.complete,false);assert.equal(q.inventory.remainingCofactor,'1026169');assert.equal(q.inventory.scope,'MODEL_DISCRIMINANT_SUPPORT_NOT_CURVE_BAD_PRIMES');packets.push({name:'incomplete-inventory',packet:q,assessment:T.replay(q),expected:{status:'PASS'}});});
for(const [name,mutate] of [
 ['parent hash',q=>q.parent.sha256='0'.repeat(64)],['composite sign',q=>q.adapter.composite.u='-2'],['step direction',q=>q.adapter.steps[1]=T.inverse(q.adapter.steps[1])],['point identity',q=>q.adapter.pointTransports[0].sourcePointIndex=1],['selected differential',q=>q.record.normalization.targetSelectedMultiplier='2'],['panel binding',q=>q.record.panelBindings[0].normalizationId='0'.repeat(64)],['marking',q=>q.trace.markingId='0'.repeat(64)],['valuation',q=>q.trace.valuations.discriminant.exponent='2'],['valuation unit',q=>q.trace.valuations.discriminant.unit='2'],['prime witness',q=>q.trace.primeProof.trials[0].remainder='0'],['missing decision',q=>q.trace.steps.pop()],['reordered decisions',q=>q.trace.steps.reverse()],['splitting roots',q=>q.trace.steps[3].roots=['1','36']],['coherent split forgery',q=>{const r=q.trace.terminal.result;r.split=true;r.reduction='SPLIT_MULTIPLICATIVE';r.ap='1';r.eulerPolynomial=['1','-1'];}],['Tamagawa',q=>q.trace.terminal.result.tamagawaNumber='37'],['conductor',q=>q.trace.terminal.result.conductorExponent='2'],['inventory',q=>q.inventory.remainingCofactor='2'],['stale producer',q=>q.backend.producer.adapterSha256='0'.repeat(64)],['stdout hash',q=>q.backend.stdout+=' '],['producer tuple',q=>q.backend.claims.URST[0]='3'],['hidden global claim',q=>q.record.minimalModel={modelId:q.trace.modelId}],['false unsupported',q=>q.trace.terminal={branch:'UNSUPPORTED',status:'UNAVAILABLE',reason:'ADDITIVE_BRANCH_REQUIRES_T2'}]
])check('Reject forged '+name,()=>{const q=clone(witness);mutate(q);assert.throws(()=>T.replay(q));});
check('Good-fibre count and Euler forgeries reject',()=>{const q=clone(packets.find(x=>x.name==='37a1-good-2').packet);q.trace.steps[3].affineCountsByX[0]='0';q.trace.terminal.result.ap='0';q.trace.terminal.result.eulerPolynomial=['1','0','2'];assert.throws(()=>T.replay(q));});
check('Unsupported additive branch cannot carry a fabricated certificate',()=>{const q=clone(packets.find(x=>x.name==='additive-II').packet);q.trace.terminal=clone(witness.trace.terminal);assert.throws(()=>T.replay(q));});
check('Singular, composite, noncanonical and exceeded prime domains reject',()=>{assert.throws(()=>T.seed(['0','0','0','0','0']));for(const p of ['1','4','9','1001','1013','05','-5','1/2'])assert.throws(()=>T.primeProof(p));assert.equal(T.primeProof('1009').p,'1009');assert.throws(()=>T.trace(T.seed(['0','0','0','-1/16','0']),'2'),/p-integral/);});
check('Parser rejects GP expressions and output ambiguity',()=>{for(const s of ['1+2','[1,2];system("bad")','[1,]','1/0','01','[[[[[[[[[[0]]]]]]]]]]'])assert.throws(()=>P.parse(s));assert.throws(()=>P.decode(witness.backend.stdout+witness.backend.stdout));});
check('Bad explicit runtime override fails without fallback',()=>assert.throws(()=>P.runtime({...process.env,BSD_T1_PARI_DIR:path.join(__dirname,'missing-runtime')})));
check('Mutated runtime bytes fail their pin before execution',()=>{const dir=path.join(__dirname,'bad-runtime-test');fs.mkdirSync(dir);fs.writeFileSync(path.join(dir,'gp-sta.js'),'tampered');assert.throws(()=>P.runtime({...process.env,BSD_T1_PARI_DIR:dir}),/pin mismatch/);});
check('Workers reject a missing scratch marker before any work',()=>{const env={...process.env};delete env.BSD_T1_SCRATCH_ROOT;const r=require('node:child_process').spawnSync(process.execPath,[__filename],{env,encoding:'utf8',windowsHide:true,timeout:10000,maxBuffer:10000});assert.notEqual(r.status,0);assert.match(r.stderr,/staged T1 scratch copy/);});
check('Inherited H1 and H2 gates reject coherently repaired producer transcripts',()=>{
 for(const [name,edit]of [['additive-II',c=>c.LOCAL[1]='-2'],['wild2',c=>c.LOCAL[0]='12']]){
  const q=clone(packets.find(x=>x.name===name).packet);edit(q.backend.claims);
  const gp=x=>Array.isArray(x)?'['+x.map(gp).join(', ')+']':x;
  q.backend.stdout=q.backend.stdout.replace(/T1_LOCAL\|[^\r\n]*/, 'T1_LOCAL|'+gp(q.backend.claims.LOCAL));q.backend.stdoutSha256=T.hash(q.backend.stdout);
  assert.throws(()=>T.replay(q),/Kodaira label contradicts|Conductor exponent exceeds the bound/);
 }
});
check('Public custom-input CLI builds a fully replayable packet',()=>{
 const r=require('node:child_process').spawnSync(process.execPath,[path.join(__dirname,'build.cjs'),'--input',path.join(__dirname,'example-input.json'),'37'],{encoding:'utf8',windowsHide:true,timeout:30000,maxBuffer:200000});assert.equal(r.status,0,r.stderr);assert.equal(assess(r.stdout).status,'PASS');
});
check('Public schema rejects unknown fields, duplicate keys, stale certificate and enforces exact PASS',()=>{
 const bytes=JSON.stringify(witness),out=assess(bytes);assert.equal(out.status,'PASS');assert.equal(assess(bytes,JSON.stringify(out.certificate)).status,'PASS');
 assert.throws(()=>assess(JSON.stringify({...witness,status:'CERTIFIED'})),/Structural/);assert.throws(()=>assess('{"schema":"bad",'+bytes.slice(1)),/Duplicate JSON key/);
 const q=clone(witness);q.trace.steps[0].unknown=true;assert.throws(()=>assess(JSON.stringify(q)),/Structural/);
 const c=clone(out.certificate);c.verifier.sha256='0'.repeat(64);assert.throws(()=>assess(bytes,JSON.stringify(c)),/certificate/);
});
check('Every generated schema is byte-equivalent to its versioned source',()=>{for(const [f,s]of Object.entries(require('./make-schema.cjs')))assert.deepEqual(JSON.parse(fs.readFileSync(path.join(__dirname,f),'utf8')),s);});
fs.writeFileSync(path.join(__dirname,'t1-fixtures.json'),JSON.stringify(packets,null,2)+'\n');
fs.writeFileSync(path.join(__dirname,'t1-tests.json'),JSON.stringify({status:'PASS',standing:'BUILDER_VERIFICATION_NOT_COLD_AUDIT',total:checks.length,checks,fixtures:packets.length,certifiedFixtures:packets.filter(q=>q.assessment.status==='PASS').length,unavailableFixtures:packets.filter(q=>q.assessment.status==='UNAVAILABLE').length,pariRuntime:P.runtime(),sageLive:{status:'UNAVAILABLE',reason:'SAGE_NOT_INSTALLED_ON_BUILD_HOST'}},null,2)+'\n');
console.log(checks.length+' T1 groups PASS; '+packets.length+' explicit fixture outcomes');
