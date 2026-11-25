'use strict';
// Read-only CLI: emits a candidate packet on stdout. Never writes an audited input.
const fs=require('node:fs'),T=require('./t1.cjs'),P=require('./pari-adapter.cjs');
try {
 if(process.argv.length!==5||!['--record','--input'].includes(process.argv[2]))throw Error('Use node build.cjs --record record.json PRIME, or --input input.json PRIME');
 if(fs.statSync(process.argv[3]).size>4000000)throw Error('Input size cap');const bytes=new TextDecoder('utf-8',{fatal:true}).decode(fs.readFileSync(process.argv[3]));let parentBytes=bytes;
 if(process.argv[2]==='--input'){const q=JSON.parse(bytes);if(Object.keys(q).sort().join('|')!=='ainvs|points|selectedMultiplier')throw Error('Input requires exactly ainvs, points, selectedMultiplier');parentBytes=JSON.stringify(T.seed(q.ainvs,q.selectedMultiplier,q.points));}
 require('../BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/assess.cjs').assess(parentBytes);
 const parent=JSON.parse(parentBytes),p=process.argv[4];T.primeProof(p);const made=P.produce(parent,p),packet=T.assemble(parentBytes,made.steps,p,made.report);
 require('./assess.cjs').assess(JSON.stringify(packet));console.log(JSON.stringify(packet,null,2));
}catch(e){console.error(e.message);process.exitCode=1;}
