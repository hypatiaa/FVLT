'use strict';
// Read-only capability discovery. No downloads, environment creation or installation.
const fs=require('node:fs'),path=require('node:path'),os=require('node:os'),{spawnSync}=require('node:child_process');
function roots(start){const result=[];let p=path.resolve(start);for(let i=0;i<8;i++){result.push(p);const next=path.dirname(p);if(next===p)break;p=next;}return result;}
function pythonCandidates(projectRoot,env=process.env,platform=process.platform){
 if(env.BSD_AUDIT_PYTHON)return [{command:env.BSD_AUDIT_PYTHON,args:[],origin:'explicit override'}];
 const result=[],seen=new Set(),add=(command,args,origin)=>{const key=JSON.stringify([command,args]);if(!seen.has(key)){seen.add(key);result.push({command,args,origin});}};
 const executable=root=>path.join(root,platform==='win32'?'Scripts/python.exe':'bin/python');
 if(env.VIRTUAL_ENV)add(executable(env.VIRTUAL_ENV),[],'active virtual environment');
 if(env.CONDA_PREFIX)add(path.join(env.CONDA_PREFIX,platform==='win32'?'python.exe':'bin/python'),[],'active conda environment');
 for(const root of roots(projectRoot))for(const name of ['.venv','venv','.bsd-audit-venv']){const exe=executable(path.join(root,name));if(fs.existsSync(exe))add(exe,[],'project environment');}
 for(const name of ['python3','python'])add(name,[],'PATH');
 if(platform==='win32')add('py',['-3'],'Windows Python launcher');
 return result;
}
const probeCode=`import sys,os,json,importlib.metadata
vendor=os.environ.get('BSD_SCHEMA_PYTHON_VENDOR')
if vendor: sys.path.insert(0,vendor)
import jsonschema
from jsonschema import Draft202012Validator
Draft202012Validator.check_schema({'$schema':'https://json-schema.org/draft/2020-12/schema','type':'object'})
assert sys.version_info >= (3,9), 'Python >=3.9 required'
print(json.dumps({'executable':sys.executable,'version':sys.version.split()[0],'jsonschemaVersion':importlib.metadata.version('jsonschema'),'jsonschemaPath':jsonschema.__file__,'draft':'2020-12'}))`;
function pythonProbe(candidate,env){
 const r=spawnSync(candidate.command,[...candidate.args,'-c',probeCode],{env:{...env,PYTHONDONTWRITEBYTECODE:'1'},encoding:'utf8',timeout:5000,windowsHide:true,maxBuffer:100000});
 if(r.error||r.status!==0)return {ok:false,reason:r.error?.code||'Python/jsonschema capability probe failed'};
 try{return {ok:true,...JSON.parse(r.stdout.trim().split(/\r?\n/).at(-1))};}catch{return {ok:false,reason:'Invalid probe response'};}
}
function discoverPython({projectRoot=__dirname,env=process.env,probe=pythonProbe,candidates=pythonCandidates(projectRoot,env)}={}){
 if(env.BSD_SCHEMA_PYTHON_VENDOR&&!fs.existsSync(env.BSD_SCHEMA_PYTHON_VENDOR))throw Error('BSD_SCHEMA_PYTHON_VENDOR does not exist; explicit overrides are not silently ignored');
 const attempts=[];
 for(const candidate of candidates){const r=probe(candidate,env);attempts.push({command:candidate.command,origin:candidate.origin,ok:r.ok,reason:r.reason||null});if(r.ok)return {...candidate,...r,attempts,vendor:env.BSD_SCHEMA_PYTHON_VENDOR||null};}
 throw Error((env.BSD_AUDIT_PYTHON?'Explicit BSD_AUDIT_PYTHON failed. ':'No Python with Draft 2020-12 jsonschema found. ')+
  'Create a project .venv (or .bsd-audit-venv), install requirements-verification.txt, or set BSD_AUDIT_PYTHON and optionally BSD_SCHEMA_PYTHON_VENDOR. Tried: '+attempts.map(x=>x.command+' ('+x.reason+')').join('; '));
}
function discoverBrowser({projectRoot=__dirname,env=process.env,resolve=require.resolve,load=require}={}){
 const requested=env.BSD_AUDIT_PLAYWRIGHT||'playwright';let modulePath;
 try{modulePath=resolve(requested,{paths:roots(projectRoot)});}catch{throw Error('Playwright was not found. Install it in the project/ancestor node_modules or set BSD_AUDIT_PLAYWRIGHT to its module path.');}
 const playwright=load(modulePath);if(!playwright.chromium||typeof playwright.chromium.launch!=='function')throw Error('Resolved module lacks Playwright Chromium');
 const executable=env.BSD_AUDIT_CHROMIUM||playwright.chromium.executablePath();
 if(!fs.existsSync(executable))throw Error('Chromium executable is missing. Install Playwright Chromium or set BSD_AUDIT_CHROMIUM; no browser is downloaded automatically.');
 let version='unknown';try{version=JSON.parse(fs.readFileSync(path.join(path.dirname(modulePath),'package.json'),'utf8')).version;}catch{}
 return {modulePath,executable,version,origin:env.BSD_AUDIT_PLAYWRIGHT?'explicit override':'Node module resolution'};
}
function discover({projectRoot=__dirname,env=process.env,python=false,browser=false}={}){
 return {node:{executable:process.execPath,version:process.version},python:python?discoverPython({projectRoot,env}):null,browser:browser?discoverBrowser({projectRoot,env}):null};
}
module.exports={roots,pythonCandidates,pythonProbe,discoverPython,discoverBrowser,discover};
if(require.main===module){try{console.log(JSON.stringify(discover({python:true,browser:true}),null,2));}catch(e){console.error(e.message);process.exitCode=1;}}
