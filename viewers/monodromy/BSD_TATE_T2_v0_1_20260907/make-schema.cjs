'use strict';
const fs=require('node:fs'),path=require('node:path');
const old=require('../BSD_TATE_T1_v0_1_20260907/t1-packet.schema.json');
const obj=p=>({type:'object',additionalProperties:false,required:Object.keys(p),properties:p}),arr=(items,minItems=0,maxItems=256)=>({type:'array',items,minItems,maxItems}),literal=c=>({const:c}),en=(...a)=>({enum:a});
const rational={type:'string',pattern:'^(0|-?[1-9][0-9]*)(/[1-9][0-9]*)?$',maxLength:194},nat={type:'string',pattern:'^(0|[1-9][0-9]*)$',maxLength:96},hash={type:'string',pattern:'^[0-9a-f]{64}$'},five=arr(rational,5,5),tuple=obj({u:rational,r:rational,s:rational,t:rational});
const val={oneOf:[obj({kind:literal('INFINITY')}),obj({kind:literal('FINITE'),exponent:rational,unit:rational})]};
const minimality={modelId:hash,shortA:rational,shortB:rational,valuationA:val,valuationB:val,criterion:literal('V_A_LT_4_OR_V_B_LT_6_AT_P_GE_5')};
const polynomial=obj({p:nat,rationalCoefficients:arr(rational,2,4),coefficients:arr(nat,2,4),evaluations:arr(nat,5,1009),roots:arr(obj({root:nat,multiplicity:nat}),0,3),residualCoefficients:arr(nat,1,4),residualEvaluations:arr(nat,0,1009),residualStatus:en('CONSTANT','IRREDUCIBLE_DEGREE_2','IRREDUCIBLE_DEGREE_3'),separable:{type:'boolean'}});
const event={oneOf:[
 obj({operation:literal('MODEL_CHANGE'),purpose:en('SHORT_FORM','REMOVE_P_POWER','CENTER_DOUBLE_ROOT','CENTER_TRIPLE_ROOT','REFINE_DOUBLE_ROOT'),fromModelId:hash,toModelId:hash,fromAinvs:five,toAinvs:five,urst:tuple,selectedMultiplierBefore:rational,selectedMultiplierAfter:rational}),
 obj({operation:literal('MINIMAL_SHORT'),...minimality,discriminantValuation:nat}),
 obj({operation:literal('DIVISIBILITY_TEST'),name:en('TYPE_II','TYPE_III','TYPE_IV','TYPE_III_STAR','TYPE_II_STAR'),value:rational,valuation:val,threshold:nat,passes:{type:'boolean'}}),
 obj({operation:literal('RESIDUE_POLYNOMIAL'),purpose:en('MULTIPLICATIVE_SPLIT','TYPE_IV_COMPONENTS','STAR_CUBIC','STAR_ODD_COMPONENTS','STAR_EVEN_COMPONENTS','TYPE_IV_STAR_COMPONENTS'),xLevel:nat,yLevel:nat,witness:polynomial}),
 obj({operation:literal('ADVANCE_LEVEL'),axis:en('X','Y'),from:nat,to:nat}),
 obj({operation:literal('GOOD_FIBRE_COUNT'),reducedAinvs:five,affineCountsByX:arr(nat,5,1009),pointsIncludingInfinity:nat,ap:rational})
]};
const result=obj({reduction:en('GOOD','SPLIT_MULTIPLICATIVE','NONSPLIT_MULTIPLICATIVE','ADDITIVE'),kodaira:{type:'string',pattern:'^(I(0|[1-9][0-9]*)([*])?|II|III|IV|II[*]|III[*]|IV[*])$'},split:{type:['boolean','null']},discriminantValuation:nat,conductorExponent:nat,wildConductorContribution:literal('0'),tamagawaNumber:nat,ap:rational,eulerPolynomial:arr(rational,1,3),geometricComponents:nat,componentMultiplicities:arr(nat,1,256),localMinimality:literal('PROVED_AT_THIS_PRIME'),minimalityWitness:obj(minimality)});
const trace=obj({schema:literal('BSD_TAME_TATE_TRACE_V1'),p:nat,primeProof:old.properties.trace.properties.primeProof,sourceModelId:hash,sourceAinvs:five,sourceSelectedMultiplier:rational,events:arr(event,2,512),composite:tuple,targetModelId:hash,targetAinvs:five,targetSelectedMultiplier:rational,result});
const packet=obj({schema:literal('BSD_TAME_TATE_PACKET_V1'),parent:old.properties.parent,record:old.properties.record,adapter:old.properties.adapter,integralSource:{$ref:'urn:robin:bsd:minimal-tate-record:1:draft-0.3#/$defs/model'},inventory:old.properties.inventory,trace,comparison:{anyOf:[{type:'null'},{$ref:'urn:robin:bsd:tate-t1-packet:1'}]},comparisonMap:{anyOf:[{type:'null'},tuple]}});
const verifier=obj({name:literal('BSD_TAME_TATE_REPLAY'),version:literal('0.1.0'),sha256:hash,tateSha256:hash,finiteFieldSha256:hash,transportSha256:hash,arithmeticSha256:hash});
const certificate=obj({schema:literal('BSD_TAME_TATE_LOCAL_CERTIFICATE_V1'),status:literal('CERTIFIED'),scope:literal('ONE_PRIME_P_GE_5_ONLY'),packetHash:hash,parentSourceHash:hash,contextId:hash,sourceModelId:hash,modelId:hash,normalizationId:hash,markingId:hash,p:nat,traceHash:hash,verifier,method:literal('EXACT_TAME_TATE_WITH_COMPLETE_RESIDUE_POLYNOMIAL_WITNESSES'),result,assumptions:arr({type:'string'},0,0),globalMinimality:literal('NOT_ASSESSED'),neronDifferential:literal('NOT_ASSESSED'),bsdPromotion:literal(false)});
const base={$schema:'https://json-schema.org/draft/2020-12/schema'};
const schemas={'t2-packet.schema.json':{...base,$id:'urn:robin:bsd:tame-tate-packet:1',...packet},'t2-certificate.schema.json':{...base,$id:'urn:robin:bsd:tame-tate-certificate:1',...certificate}};
module.exports=schemas;
if(require.main===module){if(fs.existsSync(path.join(__dirname,'MANIFEST.sha256')))throw Error('Sealed candidate; create a successor');for(const [file,schema]of Object.entries(schemas))fs.writeFileSync(path.join(__dirname,file),JSON.stringify(schema,null,2)+'\n');}
