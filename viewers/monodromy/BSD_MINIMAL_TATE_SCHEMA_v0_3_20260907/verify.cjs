'use strict';
const fs=require('node:fs'),path=require('node:path'),os=require('node:os'),crypto=require('node:crypto'),{spawnSync}=require('node:child_process'),assert=require('node:assert/strict');
const {discover}=require('./runtime-discovery.cjs');
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
function files(root){const result=[];function walk(dir){for(const n of fs.readdirSync(dir).sort()){const p=path.join(dir,n),stat=fs.lstatSync(p);if(stat.isSymbolicLink())throw Error('Symlink in audit inputs');if(stat.isDirectory())walk(p);else if(stat.isFile())result.push(p);}}walk(root);return result;}
function inventory(root){return Object.fromEntries(files(root).map(p=>[path.relative(root,p).replaceAll('\\','/'),hash(fs.readFileSync(p))]));}
function manifest(root){const file=path.join(root,'MANIFEST.sha256');if(!fs.existsSync(file))return {status:'AUTHORING_UNPINNED'};const lines=fs.readFileSync(file,'utf8').trim().split(/\r?\n/);for(const line of lines){const m=/^([a-f0-9]{64})  (.+)$/.exec(line);if(!m)throw Error('Malformed manifest');const file=path.resolve(root,m[2]);if(!file.startsWith(path.resolve(root)+path.sep))throw Error('Manifest path escape');assert.equal(hash(fs.readFileSync(file)),m[1],m[2]);}return {status:'PASS',entries:lines.length,sha256:hash(fs.readFileSync(file))};}
async function run(suite='all'){
 if(!['all','math','schema','browser','runtime'].includes(suite))throw Error('Use --suite all, math, schema, browser or runtime');
 const source=__dirname,parent=path.dirname(source),packageName=path.basename(source),predecessor=path.join(parent,'MCOMB_CARRIER_ADDITION_v0_1_20260907');
 const sourceBefore=inventory(source),predecessorBefore=inventory(predecessor),manifests={candidate:manifest(source),predecessor:manifest(predecessor),schemaPredecessor:manifest(path.join(parent,'BSD_MINIMAL_TATE_SCHEMA_v0_2_20260907')),schemaAncestor:manifest(path.join(parent,'BSD_MINIMAL_TATE_SCHEMA_v0_1_20260907'))};
 const scratch=fs.mkdtempSync(path.join(os.tmpdir(),'bsd-reduction-audit-')),stage=path.join(scratch,packageName);
 fs.writeFileSync(path.join(scratch,'.bsd-audit-scratch.json'),JSON.stringify({kind:'BSD_AUDIT_SCRATCH_V1',sourcePackage:source}));
 const names=[packageName,'BSD_MINIMAL_TATE_SCHEMA_v0_2_20260907','BSD_MINIMAL_TATE_SCHEMA_v0_1_20260907','MCOMB_CARRIER_ADDITION_v0_1_20260907','MCOMB_CONNECTED_PANELS_v0_1_20260907','MCOMB_ELLIPTIC_BSD_LINK_v0_1_20260907','BSD_CURVE_RECORD_v0_1_20260907'];
 const inputInventories=Object.fromEntries(names.map(name=>[name,inventory(path.join(parent,name))]));
 for(const name of names)fs.cpSync(path.join(parent,name),path.join(scratch,name),{recursive:true});
 fs.copyFileSync(path.join(parent,'v27_elliptic_bridge.js'),path.join(scratch,'v27_elliptic_bridge.js'));
 const bridgeHash=hash(fs.readFileSync(path.join(parent,'v27_elliptic_bridge.js')));
 const auditFiles=['MONODROMY_30_1_SCHEMA_COLD_AUDIT_FABLE_20260907.md','MONODROMY_30_1_SCHEMA_COLD_AUDIT_FABLE_20260907.json','MINIMAL_TATE_SCHEMA_v0_2_COLD_AUDIT_FABLE_20260907.md','MINIMAL_TATE_SCHEMA_v0_2_COLD_AUDIT_FABLE_20260907.json'];
 const auditHashes=Object.fromEntries(auditFiles.map(n=>[n,hash(fs.readFileSync(path.join(parent,n)))]));
 for(const n of auditFiles)fs.copyFileSync(path.join(parent,n),path.join(scratch,n));
 const env={...process.env,BSD_AUDIT_SCRATCH_ROOT:scratch,PYTHONDONTWRITEBYTECODE:'1'};
 console.log('Scratch: '+scratch);const checks=[];let failure=null,runtimes=null;
 try{
 runtimes=discover({projectRoot:source,env,python:['all','schema','runtime'].includes(suite),browser:['all','browser','runtime'].includes(suite)});
 if(runtimes.python){env.BSD_AUDIT_RESOLVED_PYTHON=runtimes.python.executable;env.BSD_AUDIT_PYTHON=runtimes.python.executable;}
 if(runtimes.browser){env.BSD_AUDIT_PLAYWRIGHT_MODULE=runtimes.browser.modulePath;env.BSD_AUDIT_CHROMIUM=runtimes.browser.executable;}
 const jobs=[];if(['all','schema'].includes(suite)){jobs.push([process.execPath,['check-schema.worker.cjs'],'schema-semantic']);jobs.push([runtimes.python.executable,['check-schema.py'],'schema-python']);jobs.push([process.execPath,['check-local-gates.worker.cjs'],'local-gates']);jobs.push([runtimes.python.executable,['check-good-certificates.py'],'good-certificates']);jobs.push([process.execPath,['check-valuation-gates.worker.cjs'],'valuation-gates']);}
 if(['all','math'].includes(suite))jobs.push([process.execPath,['check-math.worker.cjs'],'math']);
 if(['all','browser'].includes(suite))for(const name of ['browser','regression','maintenance'])jobs.push([process.execPath,['check-'+name+'.worker.cjs'],name]);
 if(['all','runtime'].includes(suite))jobs.push([process.execPath,['check-runtime.worker.cjs'],'runtime']);
 for(const [exe,args,name] of jobs){const result=spawnSync(exe,args,{cwd:stage,env,encoding:'utf8',timeout:300000,maxBuffer:8000000,windowsHide:true});fs.writeFileSync(path.join(stage,name+'.log'),(result.stdout||'')+(result.stderr||''));if(result.stdout)process.stdout.write(result.stdout);if(result.status!==0)throw Error(name+' failed: '+(result.error?.message||result.stderr||'see log'));checks.push({name,status:'PASS'});}}
 catch(e){failure=e.message;}
 finally{
  try{assert.deepEqual(inventory(source),sourceBefore,'Candidate changed during verification');assert.deepEqual(inventory(predecessor),predecessorBefore,'Predecessor changed during verification');for(const name of names)assert.deepEqual(inventory(path.join(parent,name)),inputInventories[name],'Dependency changed: '+name);assert.equal(hash(fs.readFileSync(path.join(parent,'v27_elliptic_bridge.js'))),bridgeHash);for(const n of auditFiles)assert.equal(hash(fs.readFileSync(path.join(parent,n))),auditHashes[n]);checks.push({name:'Candidate and all staged source dependencies unchanged',status:'PASS'});}catch(e){failure=(failure?failure+'; ':'')+e.message;}
  const result={standing:'LOCAL_SCRATCH_VERIFICATION_NOT_COLD_AUDIT',suite,status:failure?'FAIL':'PASS',sourcePackage:source,scratchPackage:stage,manifests,runtimes,inputInventories,bridgeSha256:bridgeHash,auditHashes,checks,failure};fs.writeFileSync(path.join(scratch,'verification.json'),JSON.stringify(result,null,2)+'\n');console.log('Receipt: '+path.join(scratch,'verification.json'));
 }
 if(failure)throw Error(failure);return {scratch,stage};
}
module.exports={run,inventory,manifest};
if(require.main===module){const args=process.argv.slice(2);if(args.length&&!(args.length===2&&args[0]==='--suite'))throw Error('Use node verify.cjs [--suite all|math|schema|browser|runtime]');run(args[1]||'all').catch(e=>{console.error(e.message);process.exitCode=1;});}
