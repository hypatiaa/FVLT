'use strict';
require('./worker-guard.cjs')();
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),{spawnSync}=require('node:child_process');
const T=require('../BSD_TATE_T1_v0_1_20260907/t1.cjs'),U=require('./global-reduction.cjs'),{assess}=require('./assess.cjs'),P=require('./pari-comparison.cjs');
const checks=[],fixtures=[],comparisons=[];const check=(name,fn)=>{fn();checks.push({name,status:'PASS'});},clone=structuredClone;
const bases=[
 ['37-nonminimal',[0,0,0,-16,16],['37','37','1'],[{x:'0',y:'4'},{x:'0',y:'4'},{infinity:true}]],
 ['37-general',[0,0,1,-1,0],['37','37','1'],[{x:'0',y:'0'}]],
 ['11-split-I5',[0,-1,1,-10,-20],['-161051','11','5'],[]],
 ['32-CM',[0,0,0,-1,0],['64','32','2'],[{x:'0',y:'0'}]],
 ['27-CM',[0,0,1,0,-7],['-19683','27','3'],[]],
 ['14-general',[1,0,1,4,-6],null,[]],
 ['cubic17',[0,0,0,0,17],null,[{x:'4',y:'9'},{x:'2',y:'5'}]],
 ['tame-star',[0,0,0,-75,875],null,[]],
 ['jzero7',[0,0,0,0,7],null,[]],
 ['jzero343',[0,0,0,0,343],null,[]]
];
const variants=[['identity',T.ID],['mixed-scale',{u:'1/30',r:'7/900',s:'-2/15',t:'11/27000'}],['rational-signed',{u:'-6',r:'2',s:'3',t:'-1'}],['scale49',{u:'1/49',r:'9/2401',s:'3/49',t:'4/117649'}]];
for(const [name,nums,known,points]of bases)for(const [label,w]of variants)check('Fixture '+name+' '+label,()=>{
 const a=nums.map(String),ainvs=T.transform(a,w),pts=points.map(z=>T.pointMap(a,w,z)),parent=T.seed(ainvs,'-3/7',pts),packet=U.construct(JSON.stringify(parent)),assessment=U.replay(packet);
 assert.equal(assessment.status,'PASS');const r=assessment.certificate.result;if(known)assert.deepEqual([r.minimalDiscriminant,r.conductor,r.tamagawaProduct],known);
 assert.equal(packet.record.points.length,2*pts.length);assert.equal(packet.adapter.pointTransports.length,pts.length);
 for(const b of packet.record.panelBindings){assert.equal(b.modelId,r.modelId);assert.equal(b.normalizationId,T.hash(packet.record.normalization));assert.equal(b.markingId,T.hash(parent.marking));}
 const comparison=P.compare(packet);comparisons.push({name:name+' '+label,...comparison});fixtures.push({name:name+' '+label,packet,assessment});
});
check('Preexisting signed ledger and nontrivial marking survive',()=>{
 let parent=T.seed(['0','0','1','-1','0'],'5/3',[{x:'0',y:'0'},{infinity:true}]);parent.marking.basisMatrix=[['0','-1'],['1','0']];for(const b of parent.panelBindings)b.markingId=T.hash(parent.marking);
 parent=T.transport(parent,[{u:'-1/6',r:'1/36',s:'1/6',t:'1/216'}]).record;
 const packet=U.construct(JSON.stringify(parent)),assessment=assess(JSON.stringify(packet));assert.equal(assessment.status,'PASS');assert.equal(assessment.certificate.result.normalization.signedPullbackToAnchor,'-1');assert.deepEqual(packet.record.marking,parent.marking);fixtures.push({name:'signed-ledger-marking',packet,assessment});comparisons.push({name:'signed-ledger-marking',...P.compare(packet)});
});
check('Twist stays a separate exact curve context',()=>{
 const parent=JSON.parse(fs.readFileSync(path.join(__dirname,'../BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/fixtures/separate-quadratic-twist.json'),'utf8'));
 const packet=U.construct(JSON.stringify(parent)),assessment=assess(JSON.stringify(packet));assert.equal(assessment.status,'PASS');assert.deepEqual(packet.record.twistLineage,parent.twistLineage);fixtures.push({name:'twist-lineage',packet,assessment});comparisons.push({name:'twist-lineage',...P.compare(packet)});
});
for(const [name,a]of [['unresolved-bad',['0','0','0','0','1013']],['unresolved-obscured-good',T.transform(['0','0','1','-1','0'],{u:'1/1013',r:'0',s:'0',t:'0'})]])check(name,()=>{
 const packet=U.construct(JSON.stringify(T.seed(a))),assessment=assess(JSON.stringify(packet));assert.equal(assessment.status,'UNAVAILABLE');assert.equal(assessment.certificate,null);assert.equal(packet.record.minimalModel,null);assert.equal(packet.record.normalization.neron,null);assert.equal(packet.record.aggregate,null);assert.equal(packet.record.badPrimeInventory,null);assert.equal(packet.proof.knownPrimeProducts.scope,'ONLY_LISTED_PRIMES');fixtures.push({name,packet,assessment});
});
check('All fixtures meet public structure and certificate schemas',()=>{
 fs.writeFileSync(path.join(__dirname,'t4-fixtures.json'),JSON.stringify(fixtures,null,2)+'\n');
 const source="import json; from validate import validate; from pathlib import Path; fs=json.loads(Path('t4-fixtures.json').read_text('utf-8')); [(validate(f['packet'],f['assessment']['certificate'])) for f in fs]; print('ALL_STRUCTURE_PASS')";
 const r=spawnSync(process.env.BSD_AUDIT_RESOLVED_PYTHON,['-c',source],{cwd:__dirname,encoding:'utf8',windowsHide:true,timeout:120000,maxBuffer:30000});assert.equal(r.status,0,r.stderr);assert.match(r.stdout,/ALL_STRUCTURE_PASS/);
});
check('Global result invariant under order of local minimization',()=>{
 for(const f of fixtures.filter(f=>f.name.includes('mixed-scale'))){const q=f.packet;let a=q.integralSource.ainvs,composite={...T.ID};for(const {p}of [...q.sourceInventory.factors].reverse()){
  const engine=require(Number(p)<5?'../BSD_TATE_T3_v0_1_20260907/t3.cjs':'../BSD_TATE_T2_v0_1_20260907/t2.cjs');const local=engine.construct(JSON.stringify(T.seed(a)),p,null),w=U.integralLift(local.adapter.composite,Number(p)).lift;a=T.transform(a,w);assert(a.every(x=>T.R(x)[1]===1n));composite=T.compose(composite,w);
 }const final=q.record.models.find(m=>m.modelId===q.record.normalization.targetModelId),map=T.compose(T.inverse(composite),q.adapter.steps[1]);assert.equal(map.u,'1');assert.deepEqual(T.transform(a,map),final.ainvs);assert.equal(T.model(a).invariants.discriminant,final.invariants.discriminant);}
});
check('Integral lift cross term is necessary, not just recorded',()=>{
 // A locally integral tuple with denominators prime to 5. Congruences do not depend on a curve.
 const w={u:'5',r:'1/2',s:'1/3',t:'1/7'},got=U.integralLift(w,5),naive={...got.lift,t:U.residue(w.t,125n)};
 assert.notEqual(naive.t,got.lift.t);const bad=T.compose(T.inverse(w),naive);assert(Number(T.valuation(bad.t,5).exponent)<0);assert.equal(got.localToIntegral.u,'1');
});
check('Good reduction recovered from nonminimal model exclusions',()=>{
 const q=fixtures[0].packet;assert(q.proof.recoveredGood.includes('2'));assert.deepEqual(q.proof.globalResult.curveBadPrimes,['37']);assert.deepEqual(q.record.aggregate.localDataPrimes,['37']);assert(q.record.localData.some(l=>l.p==='2'&&l.result.reduction==='GOOD'));
});
const witness=fixtures.find(f=>f.name==='37-nonminimal mixed-scale').packet;
for(const [name,edit]of [
 ['global conductor',q=>q.proof.globalResult.conductor='1'],['global Tamagawa product',q=>q.record.aggregate.tamagawaProduct='9'],['minimal discriminant',q=>q.proof.globalResult.minimalDiscriminant='1'],
 ['omitted stage',q=>q.stages.pop()],['omitted bad prime',q=>q.proof.globalResult.curveBadPrimes=[]],['inventory support',q=>q.candidateInventory.factors=[]],
 ['lift tuple sign',q=>q.stages[0].lift.u='-2'],['lift t',q=>q.stages[0].lift.t=String(BigInt(q.stages[0].lift.t)+1n)],['local transfer',q=>q.proof.transfers[0].localToFinal.u='5'],
 ['borrowed local certificate',q=>q.stages[0].localCertificate=clone(fixtures[8].packet.stages[0].localCertificate)],['coherent local Tamagawa rewrite',q=>{q.stages[0].localCertificate.result.tamagawaNumber='7';q.stages[0].localCertificateId=T.hash(q.stages[0].localCertificate);q.proof.stageHashes[0]=T.hash(q.stages[0]);}],
 ['selected normalization',q=>q.proof.globalResult.normalization.neronOverSelectedMultiplier='1'],['signed normalization',q=>q.proof.globalResult.normalization.signedPullbackToInput='-30'],['absolute measure factor',q=>q.proof.globalResult.normalization.absoluteRealMeasureFactorFromSelected='-1'],
 ['real components',q=>q.proof.globalResult.normalization.realComponents='1'],['stale panel',q=>q.record.panelBindings[0].normalizationId='0'.repeat(64)],['verifier hash',q=>q.proof.verifier.sha256='0'.repeat(64)],
 ['unknown field',q=>q.proof.assumedBSD=true],['repaired parent hash',q=>{const p=JSON.parse(q.parent.bytes);p.normalization.sourceSelectedMultiplier='1';q.parent.bytes=JSON.stringify(p);q.parent.sha256=T.hash(q.parent.bytes);}]
])check('Reject '+name,()=>{const q=clone(witness);edit(q);assert.throws(()=>assess(JSON.stringify(q)));});
check('Incomplete inventory cannot become complete by editing every global field',()=>{const q=clone(fixtures.find(f=>f.name==='unresolved-bad').packet);for(const v of [q.sourceInventory,q.candidateInventory,q.proof.sourceInventory,q.proof.candidateInventory]){v.complete=true;v.remainingCofactor='1';}q.proof.globalResult=clone(witness.proof.globalResult);assert.throws(()=>assess(JSON.stringify(q)));});
check('Certificate and packet transplant rejected',()=>{const a=U.replay(witness),q=fixtures[0].packet;assert.throws(()=>assess(JSON.stringify(q),JSON.stringify(a.certificate)));const c=clone(a.certificate);c.result.conductor='1';assert.throws(()=>assess(JSON.stringify(witness),JSON.stringify(c)));assert.equal(assess(JSON.stringify(witness),JSON.stringify(a.certificate)).status,'PASS');});
check('Unavailable packet refuses a borrowed global certificate',()=>{assert.throws(()=>assess(JSON.stringify(fixtures.find(f=>f.name==='unresolved-bad').packet),JSON.stringify(U.replay(witness).certificate)));});
check('Duplicate outer and embedded parent keys rejected',()=>{
 assert.throws(()=>assess(JSON.stringify(witness).replace('"schema":','"schema":"forged","schema":')));
 const q=clone(witness);q.parent.bytes=q.parent.bytes.replace('"schema":','"schema":"forged","schema":');q.parent.sha256=T.hash(q.parent.bytes);assert.throws(()=>assess(JSON.stringify(q)));
 const v=clone(witness);v.stages[0].localPacket.parent.bytes=v.stages[0].localPacket.parent.bytes.replace('"schema":','"schema":"forged","schema":');assert.throws(()=>assess(JSON.stringify(v)));
});
check('Exact point membership does not depend on complete reduction',()=>{const a=['0','0','0','-1013','1'],parent=T.seed(a,'1',[{x:'0',y:'1'}]);assert.equal(T.pointOn(a,{x:'0',y:'1'}),true);T.verifyTransport(parent);assert.throws(()=>T.seed(a,'1',[{x:'0',y:'2'}]));});
check('Domain caps and nonfinite scaling reject',()=>{assert.throws(()=>U.integralLift({u:'6',r:'0',s:'0',t:'0'},2));assert.throws(()=>U.integralLift({u:'1/2',r:'0',s:'0',t:'0'},2));assert.throws(()=>U.residue('1/5',25n));assert.throws(()=>assess('x'.repeat(32000001)));assert.throws(()=>U.construct(JSON.stringify(T.seed(['0','0','0','0','0']))));});
check('24-prime work cap refuses global computation',()=>{const primes=[];for(let p=2;primes.length<25;p++)if(Array.from({length:p-2},(_,i)=>i+2).every(d=>p%d!==0))primes.push(p);const b=primes.reduce((a,p)=>a*BigInt(p),1n);assert.throws(()=>U.construct(JSON.stringify(T.seed(['0','0','0','0',String(b)]))),/24-prime/);});
check('Custom-input CLI works and rejects duplicate keys',()=>{
 const file=path.join(__dirname,'cli-input.json');fs.writeFileSync(file,JSON.stringify({ainvs:['0','0','0','-16','16'],points:[{x:'0',y:'4'}],selectedMultiplier:'1'}));
 const args=[path.join(__dirname,'build.cjs'),'--input',file],r=spawnSync(process.execPath,args,{encoding:'utf8',windowsHide:true,timeout:60000,maxBuffer:4000000});assert.equal(r.status,0,r.stderr);assert.equal(assess(r.stdout).status,'PASS');fs.writeFileSync(file,'{"ainvs":[],"ainvs":[],"points":[],"selectedMultiplier":"1"}');const bad=spawnSync(process.execPath,args,{encoding:'utf8',windowsHide:true,timeout:30000});assert.notEqual(bad.status,0);assert.match(bad.stderr,/Duplicate/);fs.unlinkSync(file);
});
check('Schema generation is byte reproducible',()=>{for(const [name,schema]of Object.entries(require('./make-schemas.cjs')))assert.equal(fs.readFileSync(path.join(__dirname,name),'utf8'),JSON.stringify(schema,null,2)+'\n');});
const out={status:'PASS',standing:'BUILDER_VERIFICATION_NOT_COLD_AUDIT',total:checks.length,fixtures:fixtures.length,certifiedFixtures:fixtures.filter(f=>f.assessment.status==='PASS').length,unavailableControls:fixtures.filter(f=>f.assessment.status==='UNAVAILABLE').length,pariComparisons:comparisons.length,checks};
fs.writeFileSync(path.join(__dirname,'t4-tests.json'),JSON.stringify(out,null,2)+'\n');fs.writeFileSync(path.join(__dirname,'pari-comparisons.json'),JSON.stringify(comparisons,null,2)+'\n');console.log(checks.length+' T4 groups PASS; '+out.certifiedFixtures+' explicit PASS fixtures; '+out.unavailableControls+' explicit unavailable controls');
