'use strict';
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict'),T=require('../BSD_TATE_T1_v0_1_20260907/t1.cjs'),{inventory}=require('../BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/verify.cjs');
function check(){
 const pins=JSON.parse(fs.readFileSync(path.join(__dirname,'SOURCE_PINS.json'),'utf8'));for(const pin of pins){const f=pin.path.startsWith('../.bsd-arithmetic-runtime/')&&process.env.BSD_T1_PARI_DIR?path.join(path.resolve(process.env.BSD_T1_PARI_DIR),path.basename(pin.path)):path.resolve(__dirname,pin.path);assert.equal(T.shaFile(f),pin.sha256,pin.path);}
 const file=path.join(__dirname,'MANIFEST.sha256'),rows=fs.readFileSync(file,'utf8').trim().split(/\r?\n/),actual=inventory(__dirname);delete actual['MANIFEST.sha256'];const listed={};for(const row of rows){const m=/^([a-f0-9]{64})  (.+)$/.exec(row);if(!m||listed[m[2]])throw Error('Invalid manifest row');listed[m[2]]=m[1];}assert.deepEqual(actual,listed,'Exact package inventory differs');
 return {status:'PASS',candidate:{entries:rows.length,sha256:T.shaFile(file)},sourcePins:pins.length,predecessor:require('../BSD_TATE_T1_v0_1_20260907/check-integrity.cjs').check()};
}
module.exports={check};if(require.main===module){try{console.log(JSON.stringify(check(),null,2));}catch(e){console.error(e.message);process.exitCode=1;}}
