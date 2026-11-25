'use strict';
// A separately produced, unauthenticated comparison. It never supplies certificate inputs.
const path=require('node:path'),assert=require('node:assert/strict'),{spawnSync}=require('node:child_process'),T=require('../BSD_TATE_T1_v0_1_20260907/t1.cjs'),P=require('../BSD_TATE_T1_v0_1_20260907/pari-adapter.cjs');
function compare(q){
 const assessment=require('./global-reduction.cjs').replay(q);assert.equal(assessment.status,'PASS','Global comparison requires a complete replay');
 const a=q.integralSource.ainvs,rt=P.runtime(),input=`E=ellinit([${a.join(',')}]);G=ellminimalmodel(E,&V);L=ellglobalred(G);print("T4_VERSION|",version());print("T4_MODEL|",vector(5,i,G[i]));print("T4_MAP|",V);print("T4_DATA|",[G.disc,L[1],L[3]]);quit\n`;
 const run=spawnSync(process.execPath,[path.join(rt.dir,'gp-sta.js'),'-q','-f'],{input,encoding:'utf8',windowsHide:true,timeout:30000,maxBuffer:200000});
 if(run.status!==0||run.error||run.stderr.trim())throw Error('PARI comparison failed: '+(run.error?.message||run.stderr||run.status));
 const claims={};for(const line of run.stdout.split(/\r?\n/)){const m=/^(?:\? )?T4_(VERSION|MODEL|MAP|DATA)\|(.*)$/.exec(line.trim());if(m){if(claims[m[1]])throw Error('Duplicate comparison field');claims[m[1]]=P.parse(m[2]);}else if(line.trim()&&line.trim()!=='?')throw Error('Unexpected comparison output');}
 assert.deepEqual(Object.keys(claims).sort(),['DATA','MAP','MODEL','VERSION']);assert.deepEqual(claims.VERSION,['2','17','4','29757','f24e5d7cc5']);
 const w=P.urst(claims.MAP);assert.deepEqual(T.transform(a,w),claims.MODEL);
 const final=q.record.models.find(m=>m.modelId===q.record.normalization.targetModelId),map=T.compose(T.inverse(w),q.adapter.steps[1]);
 assert.deepEqual(T.transform(claims.MODEL,map),final.ainvs);assert.ok(['1','-1'].includes(map.u));
 const r=assessment.certificate.result;assert.deepEqual(claims.DATA,[r.minimalDiscriminant,r.conductor,r.tamagawaProduct]);
 return {schema:'BSD_T4_PARI_COMPARISON_V1',status:'AGREES',standing:'UNAUTHENTICATED_COMPARISON_NOT_PROOF',packetHash:T.hash(q),certificateId:assessment.certificateId,adapterSha256:T.shaFile(__filename),runtime:rt,script:input,scriptSha256:T.hash(input),stdout:run.stdout,stdoutSha256:T.hash(run.stdout),claims,pariToCertifiedModel:map,certificateUsesComparison:false};
}
module.exports={compare};
if(require.main===module){try{const fs=require('node:fs');if(process.argv.length!==3)throw Error('Use node pari-comparison.cjs packet.json');const bytes=fs.readFileSync(process.argv[2],'utf8');require('./assess.cjs').assess(bytes);console.log(JSON.stringify(compare(JSON.parse(bytes)),null,2));}catch(e){console.error(e.message);process.exitCode=1;}}
