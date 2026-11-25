'use strict';
require('./worker-guard.cjs')();
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),{spawnSync}=require('node:child_process');
const T=require('../BSD_TATE_T1_v0_1_20260907/t1.cjs'),P=require('../BSD_TATE_T1_v0_1_20260907/pari-adapter.cjs'),U=require('./t2.cjs'),K=require('./tame-tate.cjs'),{assess}=require('./assess.cjs');
const checks=[],fixtures=[],coverage={};const check=(name,fn)=>{fn();checks.push({name,status:'PASS'});};
const square=(a,p)=>Array.from({length:p},(_,x)=>x*x%p).includes((a%p+p)%p);
function make(name,a,p,kodaira,cp,{points=[],multiplier='1',parent=null,compare=true}={}){
 parent=parent||T.seed(a,multiplier,points);const bytes=JSON.stringify(parent);let comparison=null;
 if(compare){const m=P.produce(parent,String(p));comparison=T.assemble(bytes,m.steps,String(p),m.report);}
 const packet=U.construct(bytes,String(p),comparison),assessment=U.replay(packet),result=assessment.certificate.result;assert.equal(assessment.status,'PASS');assert.equal(result.kodaira,kodaira,name);assert.equal(result.tamagawaNumber,String(cp),name);
 coverage[kodaira+':'+cp]=(coverage[kodaira+':'+cp]||0)+1;fixtures.push({name,expected:{kodaira,tamagawaNumber:String(cp),status:'PASS'},packet,assessment});return packet;
}
for(const p of [5,7,11]){
 const ns=Array.from({length:p-1},(_,i)=>i+1).find(x=>!square(x,p));
 for(const [type,A,B,cp]of [['II',p,p,1],['III',p,p*p,2],['IV',p*p,p*p,3],['IV',p*p,ns*p*p,1],['IV*',p**4,p**4,3],['IV*',p**4,ns*p**4,1],['III*',p**3,p**5,2],['II*',p**4,p**5,1]])check(type+' cp='+cp+' at '+p,()=>make(type+'-'+cp+'-'+p,['0','0','0',String(A),String(B)],p,type,cp));
 for(const wanted of [0,1,3]){
  let choice;for(let a=0;a<p&&!choice;a++)for(let b=0;b<p&&!choice;b++){if((4*a*a*a+27*b*b)%p===0)continue;const roots=Array.from({length:p},(_,x)=>x).filter(x=>(x*x*x+a*x+b)%p===0);if(roots.length===wanted)choice=[a,b];}
  assert(choice);check('I0* cp='+(wanted+1)+' at '+p,()=>make('I0star-'+(wanted+1)+'-'+p,['0','0','0',String(choice[0]*p*p),String(choice[1]*p**3)],p,'I0*',wanted+1));
 }
 for(const n of [1,2,3,4,7,8,17,18])for(const b of [1,ns]){
  const cp=square(n%2?b:-3*b,p)?4:2;
  check('I'+n+'* cp='+cp+' at '+p,()=>make('star-'+p+'-'+n+'-'+b,['0','0','0',String(-3*p*p),String(2n*BigInt(p)**3n+BigInt(b)*BigInt(p)**BigInt(n+3))],p,'I'+n+'*',cp));
 }
}
for(const [p,b,type,cp]of [[5,1,'I4*',2],[5,2,'I3*',4],[7,1,'I3*',4],[7,2,'I3*',2]])check('Nonzero p-adic refinement '+p+'/'+b,()=>{
 const a=['0',String(3*p),'0',String(p**3),T.S(T.add(T.div(T.R(String(p**5)),T.R('12')),T.R(String(b*p**6))))];
 const q=make('nonzero-refinement-'+p+'-'+b,a,p,type,cp);assert(q.trace.events.some(e=>e.purpose==='REFINE_DOUBLE_ROOT'&&e.urst.r!=='0'));
});
for(const [B,type,cp]of [['5','II',1],['25','IV',3],['125','I0*',2],['625','IV*',3],['3125','II*',1]])check('j=0 '+type,()=>make('j0-'+type,['0','0','0','0',B],5,type,cp));
check('Inherited multiplicative types and both Tamagawa parities',()=>{for(const [a2,n]of [[1,4],[2,3],[2,4]])make('multip-'+a2+'-'+n,['0',String(a2),'0','0',String(5**n)],5,'I'+n,a2===1?n:n%2?1:2);});
check('Good general equation and full upper-bound fibre count',()=>{make('general-good',['1','0','0','0','1'],5,'I0',1);make('prime-bound',['0','0','1','-1','0'],1009,'I0',1);});
check('Repeated p-scalings genuinely recover local minimality',()=>{const a=T.transform(['0','0','0','5','5'],{u:'1/125',r:'0',s:'0',t:'0'}),q=make('three-rescalings',a,5,'II',1);assert.equal(q.trace.events.filter(e=>e.purpose==='REMOVE_P_POWER').length,3);assert.equal(q.record.normalization.targetSelectedMultiplier,'1/125');});
check('General signed rational model, exact points and repeated visits',()=>{
 const a=['0','0','0','-75','875'],w={u:'-2',r:'1/3',s:'-1/2',t:'7/4'},b=T.transform(a,w),pt=T.pointMap(a,w,{x:'5',y:'25'});
 const q=make('rational-general-points',b,5,'I1*',4,{multiplier:'-3/2',points:[pt,pt,{infinity:true}]});assert.equal(q.record.points.length,6);assert.equal(q.adapter.pointTransports.length,3);assert.equal(q.record.normalization.neron,null);assert.equal(q.record.minimalModel,null);
 for(const b of q.record.panelBindings){assert.equal(b.modelId,q.trace.targetModelId);assert.equal(b.normalizationId,T.hash(q.record.normalization));}
});
check('Nontrivial marking and twist context survive exact transport',()=>{
 const parent=JSON.parse(fs.readFileSync(path.join(__dirname,'../BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/fixtures/separate-quadratic-twist.json'),'utf8'));parent.marking.basisMatrix=[['1','1'],['0','1']];parent.panelBindings.forEach(p=>p.markingId=T.hash(parent.marking));const q=make('twist-and-marking',null,5,'I0*',4,{parent});assert.deepEqual(q.record.twistLineage,parent.twistLineage);assert.deepEqual(q.record.marking,parent.marking);
});
check('Backend-free certification and incomplete model inventory',()=>{const q=make('backend-free-incomplete',['0','0','0','0','1013'],5,'I0',1,{compare:false});assert.equal(q.inventory.complete,false);assert.equal(q.inventory.remainingCofactor,'1026169');assert.equal(q.comparison,null);});
const witness=fixtures.find(f=>f.name==='nonzero-refinement-5-1').packet;
const clone=structuredClone,polyEvent=q=>q.trace.events.find(e=>e.operation==='RESIDUE_POLYNOMIAL'&&e.purpose==='STAR_EVEN_COMPONENTS');
for(const [name,edit]of [
 ['cp allowed but wrong',q=>q.trace.result.tamagawaNumber='4'],['Kodaira with colliding valuation',q=>q.trace.result.kodaira='IV*'],['conductor',q=>q.trace.result.conductorExponent='3'],['wild',q=>q.trace.result.wildConductorContribution='1'],['component count',q=>q.trace.result.geometricComponents='99'],['component multiplicity',q=>q.trace.result.componentMultiplicities[0]='2'],['minimality witness',q=>q.trace.result.minimalityWitness.shortA='0'],['missing branch event',q=>q.trace.events.splice(2,1)],['reordered events',q=>q.trace.events.reverse()],['refinement shift',q=>q.trace.events.find(e=>e.purpose==='REFINE_DOUBLE_ROOT').urst.r='0'],['level advance',q=>q.trace.events.find(e=>e.operation==='ADVANCE_LEVEL').to='9'],['polynomial coefficient',q=>polyEvent(q).witness.coefficients[0]='0'],['polynomial rational coefficient',q=>polyEvent(q).witness.rationalCoefficients[0]='0'],['polynomial evaluations',q=>polyEvent(q).witness.evaluations[0]='4'],['root multiplicity',q=>polyEvent(q).witness.roots[0].multiplicity='1'],['omitted roots',q=>polyEvent(q).witness.roots=[]],['residual irreducibility',q=>polyEvent(q).witness.residualStatus='IRREDUCIBLE_DEGREE_3'],['tuple sign',q=>q.adapter.composite.u='-1'],['differential',q=>q.record.normalization.targetSelectedMultiplier='2'],['panel marking',q=>q.record.panelBindings[0].markingId='0'.repeat(64)],['borrowed comparison',q=>q.comparison=fixtures[0].packet.comparison],['comparison map',q=>q.comparisonMap.u='-1'],['inventory completion',q=>q.inventory.remainingCofactor='2'],['parent hash',q=>q.parent.sha256='0'.repeat(64)]
])check('Reject '+name,()=>{const q=clone(witness);edit(q);assert.throws(()=>U.replay(q),undefined,name);});
check('Public entry point verifies certificates and rejects coherent/source forgeries',()=>{
 const bytes=JSON.stringify(witness),r=assess(bytes);assert.equal(r.status,'PASS');assert.equal(assess(bytes,JSON.stringify(r.certificate)).status,'PASS');
 assert.throws(()=>assess(JSON.stringify({...witness,assessment:'CERTIFIED'})),/Structural/);assert.throws(()=>assess('{"schema":"bad",'+bytes.slice(1)),/Duplicate JSON/);
 const q=clone(witness),parent=JSON.parse(q.parent.bytes);parent.normalization.sourceSelectedMultiplier='2';q.parent.bytes=JSON.stringify(parent);q.parent.sha256=T.hash(q.parent.bytes);assert.throws(()=>assess(JSON.stringify(q)));
 const c=clone(r.certificate);c.result.tamagawaNumber='4';assert.throws(()=>assess(bytes,JSON.stringify(c)),/Certificate/);
 const wrong=clone(witness);wrong.trace.result.tamagawaNumber='4';const last=wrong.trace.events.findLast(e=>e.operation==='RESIDUE_POLYNOMIAL');last.witness.roots=[{root:'1',multiplicity:'1'},{root:'4',multiplicity:'1'}];assert.throws(()=>assess(JSON.stringify(wrong)));
});
check('Bounds, singularity and p-integrality gates do not silently pass',()=>{for(const p of ['2','3','4','9','1013','05'])assert.throws(()=>K.compute(['0','0','0','5','5'],p));assert.throws(()=>K.compute(['0','0','0','1/5','1'],'5'));assert.throws(()=>K.compute(['0','0','0','0','0'],'5'));assert.throws(()=>T.seed(['0','0','0','0','17'],'1',[{x:'4',y:'8'}]));});
check('An allowed but false additive PARI c_p cannot override the T2 proof',()=>{const q=clone(witness),b=q.comparison.backend;b.claims.LOCAL[3]='4';const gp=x=>Array.isArray(x)?'['+x.map(gp).join(', ')+']':x;b.stdout=b.stdout.replace(/T1_LOCAL\|[^\r\n]*/,'T1_LOCAL|'+gp(b.claims.LOCAL));b.stdoutSha256=T.hash(b.stdout);assert.equal(T.replay(q.comparison).status,'UNAVAILABLE');assert.throws(()=>assess(JSON.stringify(q)),/PARI Tamagawa disagreement/);});
check('A true unresolved cofactor cannot be relabelled complete',()=>{const q=clone(fixtures.find(f=>f.name==='backend-free-incomplete').packet);q.inventory.complete=true;q.inventory.remainingCofactor='1';assert.throws(()=>assess(JSON.stringify(q)));});
check('p=3 multiplicative note cross-check (T3 extension remains unimplemented)',()=>{for(const a2 of ['1','2']){const a=['0',a2,'0','0','3'],parent=T.seed(a),m=P.produce(parent,'3');assert.equal(T.mod(T.model(a).invariants.c4,3),1);const split=square(-T.mod(T.model(a).invariants.c6,3),3);assert.equal(T.count(a,3).ap,split?'1':'-1');assert.equal(m.report.claims.LOCAL[0],'1');assert.throws(()=>K.compute(a,'3'),/UNAVAILABLE/);}});
check('CLI and scratch refusal work at the real entry points',()=>{const r=spawnSync(process.execPath,[path.join(__dirname,'build.cjs'),'--input',path.join(__dirname,'example-input.json'),'5'],{encoding:'utf8',windowsHide:true,timeout:30000,maxBuffer:300000});assert.equal(r.status,0,r.stderr);assert.equal(assess(r.stdout).status,'PASS');const env={...process.env};delete env.BSD_T2_SCRATCH_ROOT;const bad=spawnSync(process.execPath,[__filename],{env,encoding:'utf8',windowsHide:true,timeout:10000,maxBuffer:10000});assert.notEqual(bad.status,0);assert.match(bad.stderr,/staged T2 scratch/);});
check('Generated schemas match their versioned source',()=>{for(const [file,s]of Object.entries(require('./make-schema.cjs')))assert.deepEqual(JSON.parse(fs.readFileSync(path.join(__dirname,file),'utf8')),s);});
for(const [k,cp]of [['II',1],['III',2],['IV',1],['IV',3],['I0*',1],['I0*',2],['I0*',4],['IV*',1],['IV*',3],['III*',2],['II*',1],['I1*',2],['I1*',4],['I2*',2],['I2*',4]])assert(coverage[k+':'+cp]);
fs.writeFileSync(path.join(__dirname,'t2-fixtures.json'),JSON.stringify(fixtures,null,2)+'\n');
fs.writeFileSync(path.join(__dirname,'t2-tests.json'),JSON.stringify({status:'PASS',standing:'BUILDER_VERIFICATION_NOT_COLD_AUDIT',total:checks.length,fixtures:fixtures.length,checks,coverage,sageLive:'SEPARATE_SERENA_NUCLEUS_LINE_ITEM_NOT_A_T2_GATE'},null,2)+'\n');console.log(checks.length+' T2 groups PASS; '+fixtures.length+' explicit PASS fixtures');
