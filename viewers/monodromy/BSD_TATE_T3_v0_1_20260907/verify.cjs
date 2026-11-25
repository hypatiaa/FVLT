'use strict';
const fs=require('node:fs'),path=require('node:path'),os=require('node:os'),assert=require('node:assert/strict'),{spawnSync}=require('node:child_process');
const T=require('../BSD_TATE_T1_v0_1_20260907/t1.cjs'),P=require('../BSD_TATE_T1_v0_1_20260907/pari-adapter.cjs'),{inventory,manifest}=require('../BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/verify.cjs'),{discover}=require('../BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/runtime-discovery.cjs');
const names=[path.basename(__dirname),'BSD_TATE_T2_v0_1_20260907','BSD_TATE_T1_v0_1_20260907','BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907','BSD_MINIMAL_TATE_SCHEMA_v0_2_20260907','BSD_MINIMAL_TATE_SCHEMA_v0_1_20260907','MCOMB_CARRIER_ADDITION_v0_1_20260907','MCOMB_CONNECTED_PANELS_v0_1_20260907','MCOMB_ELLIPTIC_BSD_LINK_v0_1_20260907','BSD_CURVE_RECORD_v0_1_20260907'];
const extras=['v27_elliptic_bridge.js','SAGE_SERENA_NUCLEUS_HOST_PLAN_v0_1_20260907.md',...['MONODROMY_30_1_SCHEMA_COLD_AUDIT_FABLE_20260907','MINIMAL_TATE_SCHEMA_v0_2_COLD_AUDIT_FABLE_20260907','MINIMAL_TATE_SCHEMA_v0_3_COLD_AUDIT_FABLE_20260907','BSD_TATE_T1_v0_1_COLD_AUDIT_FABLE_20260907','BSD_TATE_T2_v0_1_COLD_AUDIT_FABLE_20260907'].flatMap(n=>[n+'.md',n+'.json'])];
function run({inherited=true}={}){
 const source=__dirname,parent=path.dirname(source),before=Object.fromEntries(names.map(n=>[n,inventory(path.join(parent,n))])),extraHashes=Object.fromEntries(extras.map(n=>[n,T.shaFile(path.join(parent,n))]));
 const manifests=Object.fromEntries(names.slice(0,7).map(n=>[n,manifest(path.join(parent,n))]));require('../BSD_TATE_T2_v0_1_20260907/check-integrity.cjs').check();if(fs.existsSync(path.join(source,'MANIFEST.sha256')))require('./check-integrity.cjs').check();
 const rt=discover({projectRoot:source,python:true,browser:inherited}),pari=P.runtime(),scratch=fs.mkdtempSync(path.join(os.tmpdir(),'bsd-t3-audit-')),stage=path.join(scratch,path.basename(source));
 fs.writeFileSync(path.join(scratch,'.bsd-t3-scratch.json'),JSON.stringify({kind:'BSD_T3_SCRATCH_V1',sourcePackage:source}));
 for(const n of names)fs.cpSync(path.join(parent,n),path.join(scratch,n),{recursive:true});for(const n of extras)fs.copyFileSync(path.join(parent,n),path.join(scratch,n));
 const runtimeDir=path.join(scratch,'.bsd-arithmetic-runtime');fs.mkdirSync(runtimeDir);for(const n of Object.keys(P.runtimeFiles))fs.copyFileSync(path.join(pari.dir,n),path.join(runtimeDir,n));
 const env={...process.env,BSD_T3_SCRATCH_ROOT:scratch,BSD_T1_PARI_DIR:runtimeDir,BSD_AUDIT_PYTHON:rt.python.executable,BSD_AUDIT_RESOLVED_PYTHON:rt.python.executable,PYTHONDONTWRITEBYTECODE:'1'};
 if(rt.browser){env.BSD_AUDIT_PLAYWRIGHT=rt.browser.modulePath;env.BSD_AUDIT_PLAYWRIGHT_MODULE=rt.browser.modulePath;env.BSD_AUDIT_CHROMIUM=rt.browser.executable;}
 console.log('Scratch: '+scratch);const checks=[];let failure=null;
 const job=(name,exe,args,cwd=stage)=>{const r=spawnSync(exe,args,{cwd,env,encoding:'utf8',windowsHide:true,timeout:600000,maxBuffer:8000000});fs.writeFileSync(path.join(scratch,name+'.log'),(r.stdout||'')+(r.stderr||''));if(r.stdout)process.stdout.write(r.stdout);if(r.status!==0||r.error)throw Error(name+' failed: '+(r.error?.message||r.stderr||r.status));checks.push({name,status:'PASS'});return r;};
 try{job('t3',process.execPath,['check-t3.worker.cjs']);job('independent',rt.python.executable,['check-independent.py']);if(inherited){const r=job('inherited-t2',process.execPath,['verify.cjs'],path.join(scratch,'BSD_TATE_T2_v0_1_20260907'));const match=[...r.stdout.matchAll(/Receipt: (.+)/g)].at(-1);if(!match)throw Error('No inherited receipt');const file=match[1].trim();assert.equal(JSON.parse(fs.readFileSync(file,'utf8')).status,'PASS');fs.copyFileSync(file,path.join(stage,'inherited-verification.json'));}}
 catch(e){failure=e.message;}
 finally{
  try{for(const n of names)assert.deepEqual(inventory(path.join(parent,n)),before[n],'Changed source '+n);for(const n of extras)assert.equal(T.shaFile(path.join(parent,n)),extraHashes[n]);P.runtime();checks.push({name:'All source packages, audits, host plan and runtimes unchanged',status:'PASS'});}catch(e){failure=(failure?failure+'; ':'')+e.message;}
  const receipt={status:failure?'FAIL':'PASS',standing:'BUILDER_SCRATCH_VERIFICATION_NOT_COLD_AUDIT',scope:inherited?'T3_PLUS_T2_T1_AND_V03':'T3_ONLY',sourcePackage:source,scratch,stage,manifests,sourceInventories:before,extraHashes,runtimes:rt,pari,checks,failure,sageComparison:'SEPARATE_SERENA_NUCLEUS_LINE_ITEM'};
  fs.writeFileSync(path.join(scratch,'verification.json'),JSON.stringify(receipt,null,2)+'\n');console.log('Receipt: '+path.join(scratch,'verification.json'));
 }
 if(failure)throw Error(failure);return {scratch,stage};
}
module.exports={run,names,extras};
if(require.main===module){try{const args=process.argv.slice(2);if(args.length>1||args.length===1&&args[0]!=='--t3-only')throw Error('Use node verify.cjs [--t3-only]');run({inherited:!args.length});}catch(e){console.error(e.message);process.exitCode=1;}}
