'use strict';
const fs=require('node:fs'),path=require('node:path');
const ref=k=>({$ref:'#/$defs/'+k}), obj=p=>({type:'object',additionalProperties:false,required:Object.keys(p),properties:p}), array=(item,max=100)=>({type:'array',items:item,maxItems:max}), nullable=s=>({oneOf:[{type:'null'},s]}), en=(...xs)=>({enum:xs});
const text={type:'string',minLength:1,maxLength:2000},digest={type:'string',pattern:'^[a-f0-9]{64}$'},integer={type:'string',pattern:'^(0|-?[1-9][0-9]*)$',maxLength:96},natural={type:'string',pattern:'^(0|[1-9][0-9]*)$',maxLength:96},positive={type:'string',pattern:'^[1-9][0-9]*$',maxLength:96},rational={type:'string',pattern:'^(0|-?[1-9][0-9]*)(/[1-9][0-9]*)?$',maxLength:194};
const defs={rational,integer,natural,positive,digest};
defs.evidence=obj({status:en('UNVERIFIED','NUMERICAL','RIGOROUS_BOUND','CERTIFIED','CONDITIONAL'),method:text,software:text,sourceHash:digest,assumptions:array(text,20),dependencies:array(digest,40),certificate:nullable(obj({artifactSha256:digest,verifier:text,conclusion:text}))});
defs.source=obj({sha256:digest,mediaType:en('application/json','text/plain'),bytes:{type:'string',maxLength:200000}});
defs.model=obj({modelId:digest,field:{const:'Q'},ainvs:{...array(ref('rational'),5),minItems:5},invariants:obj(Object.fromEntries(['b2','b4','b6','b8','c4','c6','discriminant','j'].map(k=>[k,ref('rational')])))});
defs.urst=obj(Object.fromEntries(['u','r','s','t'].map(k=>[k,ref('rational')])));
defs.transform=obj({fromModelId:digest,toModelId:digest,direction:{const:'SOURCE_TO_TARGET'},urst:ref('urst'),pullbackModelDifferentialFactor:ref('rational'),targetSelectedMultiplier:ref('rational')});
defs.twist=obj({baseModelId:digest,twistedModelId:digest,kind:en('QUADRATIC_SHORT','QUARTIC_B_ZERO'),parameter:ref('rational'),sourceHash:digest});
defs.point={oneOf:[obj({infinity:{const:true}}),obj({x:ref('rational'),y:ref('rational')})]};
defs.localResult=obj({reduction:en('GOOD','SPLIT_MULTIPLICATIVE','NONSPLIT_MULTIPLICATIVE','ADDITIVE'),kodaira:{type:'string',pattern:'^(I0|I[1-9][0-9]*|II|III|IV|I(0|[1-9][0-9]*)[*]|IV[*]|III[*]|II[*])$'},split:nullable({type:'boolean'}),discriminantValuation:ref('natural'),conductorExponent:ref('natural'),wildConductorContribution:ref('natural'),tamagawaNumber:ref('positive'),eulerPolynomial:{...array(ref('integer'),3),minItems:1}});
defs.local=obj({p:ref('positive'),modelId:digest,minimalityEvidence:nullable(ref('evidence')),result:nullable(ref('localResult')),evidence:ref('evidence')});
defs.normalization=obj({modelDifferential:{const:'dx/(2*y+a1*x+a3)'},sourceSelectedMultiplier:ref('rational'),targetModelId:digest,targetSelectedMultiplier:ref('rational'),composedPullbackFactor:ref('rational'),neron:nullable(obj({modelId:digest,convention:{const:'GLOBAL_MINIMAL_MODEL_DIFFERENTIAL_UP_TO_SIGN'},evidence:ref('evidence')}))});
defs.minimal=obj({modelId:digest,scope:en('GLOBAL_Q','LOCAL_QP'),prime:nullable(ref('positive')),evidence:ref('evidence')});
defs.inventory=obj({modelId:digest,factors:array(obj({p:ref('positive'),exponent:ref('positive')}),50),remainingCofactor:ref('positive'),complete:{type:'boolean'},evidence:ref('evidence')});
defs.aggregate=obj({modelId:digest,conductor:ref('positive'),tamagawaProduct:ref('positive'),localDataPrimes:array(ref('positive'),50),evidence:ref('evidence')});
const schema={
 $schema:'https://json-schema.org/draft/2020-12/schema',
 $id:'urn:robin:bsd:minimal-tate-record:1:draft-0.3',
 title:'BSD minimal models and Tate reduction record, audit draft 0.3',
 description:'Structural schema only. The mandatory semantic contract is SCHEMA_FOR_AUDIT.md. Evidence labels and certificate references do not establish local verification.',
 ...obj({schema:{const:'BSD_MINIMAL_TATE_RECORD_V1'},anchor:obj({inputModelId:digest,sourceHash:digest,legacyContextId:nullable(digest)}),contextId:digest,models:{...array(ref('model'),40),minItems:1},twistLineage:array(ref('twist'),8),transformations:array(ref('transform'),16),normalization:ref('normalization'),marking:obj({basisMatrix:{type:'array',minItems:2,maxItems:2,items:{type:'array',minItems:2,maxItems:2,items:ref('integer')}},convention:{const:'TARGET_BASIS_EQUALS_U_TIMES_M_SOURCE_BASIS'},mcombSourceHash:nullable(digest),phaseConvention:{const:'FULL_PERIOD_FRACTIONS_MOD_Z2'}}),points:array(obj({modelId:digest,coordinates:ref('point'),sourceHash:digest}),200),minimalModel:nullable(ref('minimal')),localData:array(ref('local'),50),badPrimeInventory:nullable(ref('inventory')),aggregate:nullable(ref('aggregate')),panelBindings:{...array(obj({panel:en('MCOMB','CARRIER_ADDITION','ELLIPTIC_MODEL','MARKED_CLIFFORD_LEAF','EXACT_CURVE_BSD','PRIME_PRODUCT'),contextId:digest,modelId:digest,normalizationId:digest,markingId:digest}),6),minItems:6},sources:array(ref('source'),300)}),
 $defs:defs
};
fs.writeFileSync(path.join(__dirname,'minimal-tate-record.schema.json'),JSON.stringify(schema,null,2)+'\n');
console.log('Draft 2020-12 schema generated.');

const certificate={
 $schema:'https://json-schema.org/draft/2020-12/schema',
 $id:'urn:robin:bsd:good-prime-certificate:1:reference-0.3',title:'Scoped exact good-prime certificate, reference verifier 0.3',
 ...obj({schema:{const:'BSD_GOOD_PRIME_CERTIFICATE_V1'},contextId:digest,modelId:digest,normalizationId:digest,p:positive,
 verifier:obj({name:{const:'BSD_LOCAL_REDUCTION_REFERENCE'},version:{const:'0.3.0'},sha256:digest}),
 method:{const:'P_INTEGRAL_UNIT_DISCRIMINANT_AND_EXHAUSTIVE_FP_COUNT'},
 ainvs:{...array(rational,5),minItems:5},discriminant:rational,reducedAinvs:{...array(natural,5),minItems:5},discriminantResidue:positive,
 pointsIncludingInfinity:positive,ap:integer,eulerPolynomial:{...array(integer,3),minItems:3},
 localMinimality:{const:'PROVED_AT_THIS_PRIME_BY_UNIT_DISCRIMINANT'},kodaira:{const:'I0'},conductorExponent:{const:'0'},tamagawaNumber:{const:'1'},
 assumptions:array(text,0),dependencies:array(digest,0),scope:{const:'THIS_MODEL_AND_THIS_PRIME_ONLY'}})
};
fs.writeFileSync(path.join(__dirname,'good-prime-certificate.schema.json'),JSON.stringify(certificate,null,2)+'\n');
