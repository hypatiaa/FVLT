'use strict';
const fs=require('node:fs'),path=require('node:path'),T=require('../BSD_TATE_T1_v0_1_20260907/t1.cjs'),U=require('./global-reduction.cjs');
try{
 const [mode,file]=process.argv.slice(2);if(!['--record','--input'].includes(mode)||!file||process.argv.length!==4)throw Error('Use node build.cjs --record record.json, or --input input.json');
 if(fs.statSync(file).size>4000000)throw Error('Input size cap');let bytes=new TextDecoder('utf-8',{fatal:true}).decode(fs.readFileSync(file));
 if(mode==='--input'){
  const rt=require('../BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/runtime-discovery.cjs').discoverPython({projectRoot:__dirname});
  const gate=require('node:child_process').spawnSync(rt.executable,[path.join(__dirname,'validate.py'),'--custom-input'],{input:bytes,encoding:'utf8',windowsHide:true,timeout:20000,maxBuffer:200000,env:{...process.env,PYTHONDONTWRITEBYTECODE:'1'}});
  if(gate.status!==0||gate.stdout.trim()!=='STRUCTURE_PASS')throw Error('Custom input gate: '+(gate.error?.message||gate.stderr));
  const q=JSON.parse(bytes);bytes=JSON.stringify(T.seed(q.ainvs,q.selectedMultiplier,q.points));
 }
 require('../BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/assess.cjs').assess(bytes);
 const packet=U.construct(bytes),result=require('./assess.cjs').assess(JSON.stringify(packet));
 console.error('T4 assessment: '+result.status+(result.reason?' — '+result.reason:''));console.log(JSON.stringify(packet,null,2));
}catch(e){console.error(e.message);process.exitCode=1;}
