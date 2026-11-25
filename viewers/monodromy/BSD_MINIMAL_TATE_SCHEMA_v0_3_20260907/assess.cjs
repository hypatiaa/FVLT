'use strict';
// Public read-only entry point: structural validation precedes exact semantic replay.
const fs=require('node:fs'),path=require('node:path'),{spawnSync}=require('node:child_process'),T=require('./model-replay.cjs'),{discoverPython}=require('./runtime-discovery.cjs');
function assess(bytes){
 if(typeof bytes!=='string'||Buffer.byteLength(bytes,'utf8')>4000000)throw Error('Packet exceeds 4 MB');
 const runtime=discoverPython({projectRoot:__dirname}),env={...process.env,PYTHONDONTWRITEBYTECODE:'1'};
 const result=spawnSync(runtime.executable,[path.join(__dirname,'validate-packet.py')],{input:bytes,env,encoding:'utf8',windowsHide:true,timeout:20000,maxBuffer:200000});
 if(result.status!==0||result.stdout.trim()!=='STRUCTURE_PASS')throw Error('Structural validation failed: '+(result.error?.message||result.stderr));
 return {schema:'BSD_LOCAL_ASSESSMENT_REPORT_V1',packetSourceHash:T.hash(bytes),...T.verifyTransport(JSON.parse(bytes))};
}
module.exports={assess};
if(require.main===module){try{if(process.argv.length!==3)throw Error('Use node assess.cjs path/to/record.json');const file=process.argv[2];if(fs.statSync(file).size>4000000)throw Error('Packet exceeds 4 MB');const bytes=new TextDecoder('utf-8',{fatal:true}).decode(fs.readFileSync(file));console.log(JSON.stringify(assess(bytes),null,2));}catch(e){console.error(e.message);process.exitCode=1;}}
