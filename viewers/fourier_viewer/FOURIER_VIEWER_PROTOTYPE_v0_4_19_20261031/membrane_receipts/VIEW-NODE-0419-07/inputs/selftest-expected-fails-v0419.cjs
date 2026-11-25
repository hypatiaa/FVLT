'use strict';
// v0.4.19 self-test of check-expected-fails-v0419 (SCHEMA_ADDENDUM_26, item 3), with injected logs, as the v0.4.18 verifier did, plus the case that the old
// checker missed. It copies the logs and the summary file of a real run into WORK/<case>/ and changes exactly one thing per case:
//   real        nothing                                                          -> the checker must exit 0
//   injected    one FAIL line added to the log of browser-check-v0414           -> exit 1
//   removed     one expected FAIL line removed from the log of test-v0410       -> exit 1
//   crash       the log of browser-check-v0414 replaced by a crash message (its exit line kept)  -> exit 1
//   truncated   the log of browser-check-v0417 keeps all its expected FAIL lines, then a crash: SUMMARY line gone, exit 134 -> exit 1
// Usage (membrane): node build/selftest-expected-fails-v0419.cjs WORK_DIR [LOGS_DIR]. Exit 0 iff every case gives the exit code required.
const fs=require('fs'),path=require('path'),cp=require('child_process');
const WORK=process.argv[2],LOGS=process.argv[3]||path.join(__dirname,'_logs'),CHK=path.join(__dirname,'check-expected-fails-v0419.cjs');
if(!WORK){console.log('usage: selftest-expected-fails-v0419.cjs WORK_DIR [LOGS_DIR]');process.exit(2);}
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' :: '+x:''));c?pass++:fail++;};
const CRASH='/home/saphir/membrane_compute/viewer/mirror/x.cjs:1\nTypeError: injected crash for the self-test\n    at Object.<anonymous> (x.cjs:1:1)\nNode.js v24.13.0\n';
function setup(name,edit){
  const d=path.join(WORK,name);fs.mkdirSync(d,{recursive:true});
  for(const f of fs.readdirSync(LOGS))if(f.endsWith('.run.log')||f==='SUMMARY_v0419.txt')fs.copyFileSync(path.join(LOGS,f),path.join(d,f));
  if(edit)edit(d);return d;
}
const rd=(d,f)=>fs.readFileSync(path.join(d,f),'utf8'),wr=(d,f,s)=>fs.writeFileSync(path.join(d,f),s);
const CASES=[
  ['real',null,0],
  ['injected',d=>{const s=rd(d,'browser-check-v0414.run.log');const i=s.lastIndexOf('\nSUMMARY');wr(d,'browser-check-v0414.run.log',s.slice(0,i)+'\nFAIL 1280x800 SELFTEST-INJECTED line'+s.slice(i));},1],
  ['removed',d=>{const L=rd(d,'test-v0410.run.log').split('\n');const i=L.findIndex(l=>l.startsWith('FAIL '));if(i<0)throw Error('no FAIL line to remove');L.splice(i,1);wr(d,'test-v0410.run.log',L.join('\n'));},1],
  ['crash',d=>{wr(d,'browser-check-v0414.run.log',CRASH);},1],
  ['truncated',d=>{const L=rd(d,'browser-check-v0417.run.log').split('\n'),keep=L.filter(l=>!/SUMMARY/.test(l));wr(d,'browser-check-v0417.run.log',keep.join('\n')+'\n'+CRASH);
    wr(d,'SUMMARY_v0419.txt',rd(d,'SUMMARY_v0419.txt').split('\n').map(l=>l.startsWith('browser-check-v0417 exit=')?'browser-check-v0417 exit=134 ':l).join('\n'));},1]];
for(const [name,edit,want] of CASES){
  let d;try{d=setup(name,edit);}catch(e){ok(name+': set up',false,e.message);continue;}
  const r=cp.spawnSync(process.execPath,[CHK,'--logs',d,'--summary',path.join(d,'SUMMARY_v0419.txt')],{encoding:'utf8'});
  const lines=(r.stdout||'').split('\n').filter(l=>/^(FAIL|HOST|NOT THE|BAD INPUT)|MISSING|UNEXPECTED|EXIT:|SUMMARY:|COUNTS:/.test(l)).slice(0,8);
  console.log('---- case '+name+': checker exit '+r.status+'\n'+lines.join('\n'));
  ok('case '+name+': the checker exits '+want+' (got '+r.status+')',r.status===want,(r.stderr||'').slice(0,300));}
console.log('SUMMARY selftest-expected-fails-v0419: '+pass+' passed, '+fail+' failed');process.exitCode=fail?1:0;
