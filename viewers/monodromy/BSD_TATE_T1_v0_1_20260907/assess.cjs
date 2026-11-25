'use strict';
const fs=require('node:fs'),path=require('node:path'),{spawnSync}=require('node:child_process'),assert=require('node:assert/strict');
const T=require('./t1.cjs'),{discoverPython}=require('../BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/runtime-discovery.cjs');
function assess(bytes,certificateBytes=null){
 if(typeof bytes!=='string'||Buffer.byteLength(bytes)>6000000)throw Error('T1 packet size cap');
 if(certificateBytes!==null&&(typeof certificateBytes!=='string'||Buffer.byteLength(certificateBytes)>100000))throw Error('Certificate size cap');
 // Keep original text for the Python duplicate-key gate, including nested parent bytes.
 const input='{"packet":'+bytes+',"certificate":'+(certificateBytes===null?'null':certificateBytes)+'}';
 const runtime=discoverPython({projectRoot:__dirname}),run=spawnSync(runtime.executable,[path.join(__dirname,'validate.py')],{input,encoding:'utf8',windowsHide:true,timeout:20000,maxBuffer:200000,env:{...process.env,PYTHONDONTWRITEBYTECODE:'1'}});
 if(run.status!==0||run.stdout.trim()!=='STRUCTURE_PASS')throw Error('Structural gate failed: '+(run.error?.message||run.stderr));
 const result=T.replay(JSON.parse(bytes));if(certificateBytes!==null)assert.deepEqual(JSON.parse(certificateBytes),result.certificate,'Claimed certificate does not replay');return result;
}
module.exports={assess};
if(require.main===module){try{if(![3,4].includes(process.argv.length))throw Error('Use node assess.cjs packet.json [certificate.json]');const read=f=>{if(fs.statSync(f).size>6000000)throw Error('File size cap');return new TextDecoder('utf-8',{fatal:true}).decode(fs.readFileSync(f));};console.log(JSON.stringify(assess(read(process.argv[2]),process.argv[3]?read(process.argv[3]):null),null,2));}catch(e){console.error(e.message);process.exitCode=1;}}
