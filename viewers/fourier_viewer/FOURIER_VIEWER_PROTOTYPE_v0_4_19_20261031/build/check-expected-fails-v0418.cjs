'use strict';
// v0.4.18 (brief part F) check-expected-fails: the old suites are not edited. build/EXPECTED_FAILS_v0418.txt lists, per suite, the exact FAIL lines those
// suites are expected to print on v0.4.18; this check passes only if, for every listed suite, the set of FAIL lines in its log equals the listed set exactly.
// So a FAIL line that is new (a regression) or missing shows up. It reads the logs of the same run (build/_logs/<suite>.run.log, written by runall.sh
// before it), or with --run runs the suites itself first. File format: "<suite><TAB><FAIL line>"; lines starting with # are comments; a suite with no
// expected FAIL is listed as "<suite><TAB>(none)".
const fs=require('fs'),path=require('path'),{execFileSync}=require('child_process');
const root=path.join(__dirname,'..'),L=path.join(root,'build','_logs');
const SCRIPT={'test-v0410':'build/test-v0410.cjs','test-v0411':'build/test-v0411.cjs','test-v0412':'build/test-v0412.cjs','test-v0413':'build/test-v0413.cjs','test-v0414':'build/test-v0414.cjs',
  'browser-check-v0410':'build/browser-check-v0410.cjs','browser-check-v0411':'build/browser-check-v0411.cjs','browser-check-v0412':'build/browser-check-v0412.cjs','browser-check-v0413':'build/browser-check-v0413.cjs',
  'browser-check-v0414':'build/browser-check-v0414.cjs','browser-check-v0417':'build/browser-check-v0417.cjs'};
const exp=new Map();
for(const line of fs.readFileSync(path.join(__dirname,'EXPECTED_FAILS_v0418.txt'),'utf8').split(/\r?\n/)){if(!line||line.startsWith('#'))continue;const i=line.indexOf('\t');if(i<0)continue;const s=line.slice(0,i),f=line.slice(i+1);if(!exp.has(s))exp.set(s,new Set());if(f!=='(none)')exp.get(s).add(f);}
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
const run=process.argv.includes('--run');
for(const [suite,want] of exp){
  const log=path.join(L,suite+'.run.log');
  if(run){let out='';try{out=execFileSync(process.execPath,[path.join(root,SCRIPT[suite])],{cwd:root,encoding:'utf8',maxBuffer:1<<28,stdio:['ignore','pipe','pipe']});}catch(e){out=String(e.stdout||'');}fs.writeFileSync(log,out);}
  if(!fs.existsSync(log)){ok(suite+': log present',false,log);continue;}
  const got=new Set(fs.readFileSync(log,'utf8').split(/\r?\n/).filter(l=>l.startsWith('FAIL ')));
  const extra=[...got].filter(l=>!want.has(l)),missing=[...want].filter(l=>!got.has(l));
  ok(suite+': the FAIL lines equal the expected list ('+want.size+' expected, '+got.size+' found)',extra.length===0&&missing.length===0,(extra.length?' UNEXPECTED: '+extra.map(l=>l.slice(0,200)).join(' || '):'')+(missing.length?' MISSING: '+missing.map(l=>l.slice(0,200)).join(' || '):''));}
console.log('SUMMARY check-expected-fails-v0418: '+pass+' passed, '+fail+' failed');process.exitCode=fail?1:0;
