'use strict';
const fs=require('node:fs'),path=require('node:path');
const base=require('../BSD_TATE_T2_v0_1_20260907/make-schema.cjs');
const rewrite=s=>s.replaceAll('BSD_TAME_TATE','BSD_SMALL_PRIME_TATE').replaceAll('EXACT_TAME_TATE','EXACT_SMALL_PRIME_TATE').replaceAll('ONE_PRIME_P_GE_5_ONLY','ONE_PRIME_2_OR_3_ONLY').replaceAll('urn:robin:bsd:tame-tate','urn:robin:bsd:small-prime-tate');
const packet=JSON.parse(rewrite(JSON.stringify(base['t2-packet.schema.json']))),certificate=JSON.parse(rewrite(JSON.stringify(base['t2-certificate.schema.json'])));
const obj=p=>({type:'object',additionalProperties:false,required:Object.keys(p),properties:p}),arr=(items,minItems=0,maxItems=256)=>({type:'array',items,minItems,maxItems}),lit=constValue=>({const:constValue}),en=(...x)=>({enum:x});
const tr=packet.properties.trace.properties,ev=tr.events.items.oneOf,change=ev[0],test=ev[2],polynomial=ev[3],advance=ev[4],count=ev[5];
const rational=change.properties.urst.properties.u,five=change.properties.fromAinvs,hash=change.properties.fromModelId,tuple=change.properties.urst,nat=advance.properties.from,val=test.properties.valuation;
const min=obj({criterion:en('UNIT_DISCRIMINANT','UNIT_C4','TATE_ADDITIVE_TERMINAL'),modelId:hash,terminalBranch:tr.result.properties.kodaira,rescalingCount:nat,valuationC4:val,valuationDiscriminant:val});
const conductor=obj({method:lit('OGG_FROM_TATE_COMPONENT_TYPE'),minimalDiscriminantValuation:nat,geometricComponents:nat,tameContribution:nat});
for(const r of [tr.result,certificate.properties.result]){r.properties.minimalityWitness=min;r.properties.conductorWitness=conductor;r.required.push('conductorWitness');r.properties.wildConductorContribution=nat;}
change.properties.purpose=en('CENTER_SINGULAR_POINT','NORMALIZE_ADDITIVE','CENTER_DOUBLE_ROOT','CENTER_TRIPLE_ROOT','REFINE_Y','REFINE_X','CENTER_FINAL_DOUBLE_ROOT','REMOVE_P_POWER');
polynomial.properties.purpose=en('MULTIPLICATIVE_TANGENTS','TYPE_IV_COMPONENTS','STAR_CUBIC','STAR_ODD_COMPONENTS','STAR_EVEN_COMPONENTS','TYPE_IV_STAR_COMPONENTS');
polynomial.properties.witness.properties.evaluations.minItems=2;polynomial.properties.witness.properties.evaluations.maxItems=3;polynomial.properties.witness.properties.residualEvaluations.maxItems=3;
count.properties.affineCountsByX.minItems=2;count.properties.affineCountsByX.maxItems=3;
tr.p=en('2','3');certificate.properties.p=en('2','3');
tr.events=arr({oneOf:[change,test,polynomial,advance,count,
 obj({operation:lit('BEGIN_TATE_PASS'),modelId:hash,ainvs:five,discriminantValuation:nat,rescalingCount:nat}),
 obj({operation:lit('COEFFICIENT_DIVISIBILITY'),name:en('SINGULAR_AT_ORIGIN','STAR_PREPARATION','TRIPLE_ROOT_CENTERED','FINAL_STAR_PREPARATION','RESCALING_ALLOWED'),ainvs:five,valuations:arr(val,5,5),thresholds:arr(nat,5,5)}),
 obj({operation:lit('SINGULAR_POINT_SEARCH'),reducedAinvs:five,rows:arr(obj({x:nat,y:nat,f:nat,fx:nat,fy:nat}),4,9),selected:obj({x:nat,y:nat})}),
 obj({operation:lit('ADDITIVE_NORMALIZATION_SEARCH'),trials:arr(obj({s:rational,t:rational,passes:{type:'boolean'}}),4,9),selected:tuple})
]},2,2048);
const schemas={'t3-packet.schema.json':packet,'t3-certificate.schema.json':certificate};module.exports=schemas;
if(require.main===module){if(fs.existsSync(path.join(__dirname,'MANIFEST.sha256')))throw Error('Sealed candidate; create a successor');for(const [f,s]of Object.entries(schemas))fs.writeFileSync(path.join(__dirname,f),JSON.stringify(s,null,2)+'\n');}
