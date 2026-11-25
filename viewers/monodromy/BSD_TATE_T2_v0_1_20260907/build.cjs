'use strict';
const fs=require('node:fs'),T=require('../BSD_TATE_T1_v0_1_20260907/t1.cjs'),P=require('../BSD_TATE_T1_v0_1_20260907/pari-adapter.cjs'),U=require('./t2.cjs');
try{
 const [mode,file,p,option]=process.argv.slice(2);if(!['--record','--input'].includes(mode)||!file||!p||option&&option!=='--without-pari'||process.argv.length>6)throw Error('Use node build.cjs --record record.json PRIME [--without-pari], or --input input.json PRIME [--without-pari]');
 T.primeProof(p);if(Number(p)<5)throw Error('UNAVAILABLE: T2 supports primes 5..1009; T1 small-prime proofs remain available');if(fs.statSync(file).size>4000000)throw Error('Input size cap');let bytes=new TextDecoder('utf-8',{fatal:true}).decode(fs.readFileSync(file));
 if(mode==='--input'){const q=JSON.parse(bytes);if(Object.keys(q).sort().join('|')!=='ainvs|points|selectedMultiplier')throw Error('Input requires exactly ainvs, points, selectedMultiplier');bytes=JSON.stringify(T.seed(q.ainvs,q.selectedMultiplier,q.points));}
 require('../BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/assess.cjs').assess(bytes);let comparison=null;if(!option){const made=P.produce(JSON.parse(bytes),p);comparison=T.assemble(bytes,made.steps,p,made.report);}
 const packet=U.construct(bytes,p,comparison);require('./assess.cjs').assess(JSON.stringify(packet));console.log(JSON.stringify(packet,null,2));
}catch(e){console.error(e.message);process.exitCode=1;}
