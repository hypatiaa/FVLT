'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const T=require('./t1.cjs'),{inventory,manifest}=require('../BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/verify.cjs');
function check(){
 const pins=JSON.parse(fs.readFileSync(path.join(__dirname,'SOURCE_PINS.json'),'utf8'));for(const pin of pins){const file=pin.path.startsWith('../.bsd-arithmetic-runtime/')&&process.env.BSD_T1_PARI_DIR?path.join(path.resolve(process.env.BSD_T1_PARI_DIR),path.basename(pin.path)):path.resolve(__dirname,pin.path);assert.equal(T.shaFile(file),pin.sha256,pin.path);}
 const file=path.join(__dirname,'MANIFEST.sha256'),rows=fs.readFileSync(file,'utf8').trim().split(/\r?\n/),all=inventory(__dirname);delete all['MANIFEST.sha256'];
 const listed={};for(const row of rows){const hit=/^([a-f0-9]{64})  (.+)$/.exec(row);if(!hit||listed[hit[2]])throw Error('Malformed/duplicate manifest row');listed[hit[2]]=hit[1];}assert.deepEqual(listed,all,'Exact package inventory differs');
 const names=['BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907','BSD_MINIMAL_TATE_SCHEMA_v0_2_20260907','BSD_MINIMAL_TATE_SCHEMA_v0_1_20260907','MCOMB_CARRIER_ADDITION_v0_1_20260907'];
 return {status:'PASS',candidate:{entries:rows.length,sha256:T.shaFile(file)},sourcePins:pins.length,predecessors:Object.fromEntries(names.map(n=>[n,manifest(path.join(__dirname,'..',n))]))};
}
module.exports={check};
if(require.main===module){try{console.log(JSON.stringify(check(),null,2));}catch(e){console.error(e.message);process.exitCode=1;}}
