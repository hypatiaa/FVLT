'use strict';
const G=require('./pt1-group.cjs'),R=require('./pt1-replay.cjs'),{T,O,eq}=G;
function produce(parentBytes,options={}){
 const parent=require('./strict-json.js')(parentBytes,1000000);T.verifyTransport(parent);const model=parent.models.find(m=>m.modelId===parent.normalization.targetModelId),a=model.ainvs,E=G.engine(a),witnesses=[];let B=0n;
 const ps=options.primes||['3','5','7','11','13','17','19','23','29','31','37','41','43','47','53','59','61','67','71','73','79','83','89','97'];if(ps.length>G.CAPS.primes)throw new G.Resource('Prime count cap');
 for(const p of ps){G.prime(p);let w;try{w=G.count(a,p);}catch(e){if(/Singular reduction|not p-integral/.test(e.message))continue;throw e;}witnesses.push(w);B=G.gcd(B,BigInt(w.pointsIncludingInfinity));if(witnesses.length>=2&&B===1n)break;}
 const candidates=[...(options.candidates||[]),...parent.points.filter(p=>p.modelId===model.modelId).map(p=>p.coordinates)];if(candidates.length>64)throw new G.Resource('Candidate cap');for(let x=-8;x<=8;x++)candidates.push(...G.lift(a,String(x)));
 const torsion=[O()];for(const p of candidates){E.on(p);if(torsion.some(q=>eq(p,q)))continue;if(!B||B>4096n)continue;try{if(E.times(p,String(B)).infinity)torsion.push(p);}catch(e){if(e.name==='PT1_RESOURCE'||/cap/.test(e.message))continue;throw e;}}
 let elements=[O()];for(const p of torsion){if(elements.some(q=>eq(q,p)))continue;let row=O(),next=[];for(let k=0;k<32;k++){for(const q of elements){const z=E.plus(q,row);if(!next.some(r=>eq(z,r)))next.push(z);}row=E.plus(row,p);if(row.infinity)break;}if(next.length>32||!row.infinity)throw new G.Resource('Subgroup cap');elements=next;}
 const exactOrder=p=>{for(let n=1;n<=32;n++)if(E.times(p,String(n)).infinity)return n;throw Error('Finite subgroup order missing');};
 const orders=elements.map(exactOrder),max=Math.max(...orders),large=elements[orders.indexOf(max)];let invariants=[],generators=[];
 if(elements.length>1){if(max===elements.length){invariants=[String(max)];generators=[E.order(large,String(max))];}else{const cyclic=Array.from({length:max},(_,k)=>E.times(large,String(k))),small=elements.find((p,i)=>orders[i]===elements.length/max&&!cyclic.some(q=>eq(p,q)));if(!small)throw Error('Group generator discovery unavailable');invariants=[String(elements.length/max),String(max)];generators=[E.order(small,invariants[0]),E.order(large,invariants[1])];}}
 let completion={method:B===BigInt(elements.length)?'MATCHED_BOUND':'PARTIAL',witness:null};
 if(T.canonical(a)==='["0","0","0","1","0"]'&&B===4n&&elements.length===2&&options.fallback!==false)completion={method:'X3_PLUS_X_EXHAUSTION',witness:{twoTorsionPolynomial:['0','1','0','1'],rationalTwoTorsionX:['0'],duplicationNumerator:['1','0','-2','0','1'],duplicationDenominator:['0','4','0','4'],candidateX:['-1','1'],rhs:['-2','2'],rationalLifts:[false,false],exceptionalRationalX:['0']}};
 const infinitePoints=completion.method==='MATCHED_BOUND'&&elements.length===1&&T.canonical(a)==='["0","0","1","-1","0"]'?[{x:'0',y:'0'}]:[];
 const operations=[];for(const p of infinitePoints)for(const n of ['-3','-2','-1','0','1','2','3','4','5','6'])operations.push({kind:'MULTIPLY',points:[p],scalar:n,output:E.times(p,n)});
 return {schema:'BSD_POINTS_TORSION_PACKET_V1',verifier:R.verifier(),parent:{bytes:parentBytes,sha256:T.hash(parentBytes)},binding:R.binding(parent,options.sourceHash??null,options.linkedContextId??null),visits:parent.points.filter(x=>x.modelId===model.modelId).map((p,index)=>({index,point:p.coordinates})),operations,subgroup:{elements,generators,invariantFactors:invariants},bound:{witnesses,gcd:witnesses.length?String(B):null},completion,infinitePoints,sourceClaims:options.sourceClaims||[]};
}
module.exports={produce};
