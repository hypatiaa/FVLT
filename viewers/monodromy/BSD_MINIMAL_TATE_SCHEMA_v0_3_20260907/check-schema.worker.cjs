'use strict';
require('./worker-guard.cjs')();
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),T=require('./model-replay.cjs');
const read=n=>JSON.parse(fs.readFileSync(path.join(__dirname,'fixtures',n+'.json'),'utf8')),checks=[],check=(name,fn)=>{fn();checks.push({name,status:'PASS'});};
const base=read('37a1-model-exclusion'),clone=x=>JSON.parse(JSON.stringify(x));
for(const name of ['37a1-model-exclusion','exact-point-without-minimality','negative-scale-shear','rational-chain','separate-quadratic-twist'])check('Replay '+name,()=>{const r=T.verifyTransport(read(name));assert.equal(r.status,'PASS');assert.equal(r.minimalityAssessment,'NOT_IMPLEMENTED');assert.equal(r.tateAssessment,'NOT_IMPLEMENTED');assert.equal(r.bsdPromotion,false);});
const negative=[
 ['reversed differential scale',q=>q.transformations[0].pullbackModelDifferentialFactor='1/2'],
 ['lost selected differential',q=>q.transformations[0].targetSelectedMultiplier='2'],
 ['zero u',q=>q.transformations[0].urst.u='0'],
 ['forged coefficient',q=>q.models[1].ainvs[3]='-2'],
 ['noncanonical rational',q=>q.transformations[0].urst.u='4/2'],
 ['stale normalization ID',q=>q.panelBindings[0].normalizationId='0'.repeat(64)],
 ['stale marking ID',q=>q.panelBindings[0].markingId='0'.repeat(64)],
 ['duplicate panel',q=>q.panelBindings[1].panel=q.panelBindings[0].panel],
 ['missing panel',q=>q.panelBindings.pop()],
 ['orientation reversal',q=>q.marking.basisMatrix=[['1','0'],['0','-1']]],
 ['floating exact coordinate',q=>q.points[0].coordinates.x=0],
 ['off-curve point',q=>q.points[0].coordinates.y='5'],
 ['altered source bytes',q=>q.sources[0].bytes+=' '],
 ['unimplemented legacy adapter',q=>q.anchor.legacyContextId='1'.repeat(64)],
 ['unimplemented mcomb adapter',q=>q.marking.mcombSourceHash='2'.repeat(64)],
 ['local status laundering',q=>q.localData[2].evidence.method='LOCAL_TATE_CERTIFIED'],
 ['certificate absent',q=>q.localData[2].evidence.status='CERTIFIED'],
 ['conditional without assumption',q=>q.localData[2].evidence.status='CONDITIONAL'],
 ['self dependency',q=>q.localData[2].evidence.dependencies=[q.localData[2].evidence.sourceHash]],
 ['bad prime omitted',q=>q.badPrimeInventory.factors=[]],
 ['incomplete factorization promoted',q=>{q.badPrimeInventory.factors=[];q.badPrimeInventory.remainingCofactor='37';}],
 ['incorrect conductor',q=>q.aggregate.conductor='1'],
 ['incorrect Tamagawa product',q=>q.aggregate.tamagawaProduct='2'],
 ['missing local result',q=>q.localData[2].result=null],
 ['composite prime',q=>q.localData[0].p='4'],
 ['prime exceeds replay bound',q=>q.localData[0].p='1000000007'],
 ['wrong good-prime count',q=>q.localData[0].result.eulerPolynomial=['1','0','2']],
 ['false multiplicative splitting',q=>q.localData[2].result.split=true],
 ['wrong discriminant valuation',q=>q.localData[2].result.discriminantValuation='2'],
 ['unjustified Neron reference',q=>{q.normalization.neron={modelId:q.anchor.inputModelId,convention:'GLOBAL_MINIMAL_MODEL_DIFFERENTIAL_UP_TO_SIGN',evidence:q.minimalModel.evidence};}],
];
for(const [name,mutate] of negative)check('Reject '+name,()=>{const q=clone(base);mutate(q);assert.throws(()=>T.verifyTransport(q));});
check('Nontrivial twist cannot be smuggled into an isomorphism chain',()=>{const q=read('separate-quadratic-twist');q.transformations=[{fromModelId:q.models[0].modelId,toModelId:q.anchor.inputModelId,direction:'SOURCE_TO_TARGET',urst:{u:'1',r:'0',s:'0',t:'0'},pullbackModelDifferentialFactor:'1',targetSelectedMultiplier:'1'}];assert.throws(()=>T.verifyTransport(q));});
check('Sage documented negative tuple reproduces all five coefficients',()=>assert.deepEqual(T.transform(['0','1','2','3','4'],{u:'-1',r:'2',s:'3',t:'4'}),['-6','-2','-10','-11','-2']));
check('Exact inverse and composed tuple replay',()=>{const a=['0','0','1','-1','0'],w={u:'2',r:'1/3',s:'2/5',t:'-1/7'},v={u:'-3',r:'4',s:'-2',t:'1'};assert.deepEqual(T.transform(T.transform(a,w),T.inverse(w)),a);assert.deepEqual(T.transform(T.transform(a,w),v),T.transform(a,T.compose(w,v)));});
check('Period fractions transform contragrediently',()=>assert.deepEqual(T.phaseMap(['1/3','2/5'],[['1','1'],['0','1']]),['1/3','1/15']));
check('Exact point input remains available without a minimal model',()=>{const q=read('exact-point-without-minimality');assert.equal(q.minimalModel,null);assert(T.pointOn(q.models[0].ainvs,{x:'4',y:'9'}));});
const receipt={standing:'LOCAL_SCHEMA_REFERENCE_CHECK_NOT_TATE_OR_COLD_AUDIT',total:checks.length,checks,unsupported:['Tate engine','global minimality certificates','legacy and mcomb packet migration','live general-model panel adapter','Neron-Tate heights']};fs.writeFileSync(path.join(__dirname,'schema-semantic-verification.json'),JSON.stringify(receipt,null,2)+'\n');console.log(checks.length+' schema semantic groups PASS');
