'use strict';
const fs=require('fs'),path=require('path'),vm=require('vm');
function load(){const g=require('./test-helper.cjs').generator();for(const n of ['spectral.js','atom-core.js','atom-packet.js'])vm.runInContext(fs.readFileSync(path.join(__dirname,n),'utf8'),g.context);return {...g,A:vm.runInContext('McombAtomCoreV1',g.context),P:vm.runInContext('McombAtomPacketV1',g.context),S:vm.runInContext('BSDV1Spectral',g.context)};}
async function cayley(C,source){return C.canonical(await C.packet({source,selection:{lane:'live-register',N:source.N,c:source.offsets[0],s:source.s},visibleOffsets:source.offsets},{route:'DIRECT_HOST_CAPTURE',origin:'EXACT_LIVE_REGISTER',capturedN:source.N,capturedS:source.s,sourceRevision:'1'}));}
module.exports={load,cayley};
