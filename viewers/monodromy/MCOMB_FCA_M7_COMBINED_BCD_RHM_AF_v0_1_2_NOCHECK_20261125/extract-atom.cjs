'use strict';
const fs=require('fs'),path=require('path'),crypto=require('crypto'),vm=require('vm');
const hash=b=>crypto.createHash('sha256').update(b).digest('hex'),PIN='3d65e14af4b0887b543e48d986ccc6367b0129afc150e0f9a254bd407b3ab106';
function extract(){
 const bytes=fs.readFileSync(path.join(__dirname,'../helix_atlas_doily_witness_v27_patched_3_wl2.html'));
 if(hash(bytes)!==PIN)throw Error('Pinned atom source mismatch');
 const source=bytes.toString('utf8').match(/function divisorPosition\(d, fac, chirality\) \{[\s\S]*?\r?\n  \}/)?.[0];
 if(!source)throw Error('Pinned divisorPosition function not found');
 return {sourceSha256:PIN,functionSha256:hash(source),dependencies:['Math'],source};
}
function oracle(){const q=extract();return {...q,position:vm.runInNewContext('('+q.source+')',Object.create(null),{timeout:1000})};}
module.exports={extract,oracle};
if(require.main===module){const {source,...provenance}=extract();console.log(JSON.stringify(provenance));}
