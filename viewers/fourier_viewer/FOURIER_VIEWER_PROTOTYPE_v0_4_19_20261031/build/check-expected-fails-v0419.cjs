'use strict';
// v0.4.19 check-expected-fails-v0419 (SCHEMA_ADDENDUM_26, item 3; verify findings 2 and 3 of v0.4.18): the successor of check-expected-fails-v0418.
// For EVERY suite listed in build/EXPECTED_FAILS_v0419.txt it compares three things with the list, and passes only if all three match for every suite:
//   (1) the exact multiset of FAIL lines of the suite's log (lines that start with "FAIL ");
//   (2) the suite's exit code, read from the run's summary file (runall.sh writes "<suite> exit=<code> ..." for every suite);
//   (3) the suite's SUMMARY line: the last log line that reports "<p> pass[ed] ... <f> fail[ed]", compared as an exact line and as the two counts.
// Every suite named in the run's summary file must be listed (an unlisted suite fails the check), and every listed suite must have a log and an exit line.
// The list is HOST-TAGGED: membrane (Linux) is the host of record (saphir, 2026-10-31: browser checks run on membrane). On any other host this checker
// prints the host and exits 2 ("not the host of record"), instead of reporting a false FAIL.
// Usage: node build/check-expected-fails-v0419.cjs [--list FILE] [--logs DIR] [--summary FILE]
//   defaults: build/EXPECTED_FAILS_v0419.txt, build/_logs/, build/_logs/SUMMARY_v0419.txt. Exit 0 = all match, 1 = a mismatch, 2 = wrong host or bad input.
const fs=require('fs'),path=require('path'),os=require('os');
const root=path.join(__dirname,'..');
const arg=(k,d)=>{const i=process.argv.indexOf(k);return i>0&&process.argv[i+1]?process.argv[i+1]:d;};
const LIST=arg('--list',path.join(__dirname,'EXPECTED_FAILS_v0419.txt')),LOGS=arg('--logs',path.join(__dirname,'_logs')),SUMF=arg('--summary',path.join(LOGS,'SUMMARY_v0419.txt'));
const SELF='check-expected-fails-v0419';
// Timings are not results: before any comparison every "<digits> ms" in a FAIL line or a SUMMARY line is replaced by "<n> ms" (norm), in the list and in
// the logs alike (old suites print measured timings inside some FAIL lines, e.g. browser-check-v0418). Nothing else is normalised.
const norm=l=>l.replace(/\b\d+ ms\b/g,'<n> ms');
const COUNT_RE=/(\d+)\s+pass(?:ed)?\b[^\n]*?(\d+)\s+fail(?:ed)?\b/;
function parseList(text){
  const L={host:null,suites:new Map()};let cur=null;
  for(const raw of text.split(/\r?\n/)){const l=raw;if(l===''||l.startsWith('#'))continue;
    let m;
    if((m=/^HOST (\S+) (\S+)$/.exec(l))){L.host={name:m[1],platform:m[2]};continue;}
    if((m=/^SUITE (\S+)$/.exec(l))){cur={name:m[1],exit:null,summary:null,counts:null,fails:[]};L.suites.set(cur.name,cur);continue;}
    if(!cur)throw Error('list: line outside a SUITE block: '+l);
    if((m=/^EXIT (\d+)$/.exec(l))){cur.exit=m[1];continue;}
    if((m=/^SUMMARY-LINE (.*)$/.exec(l))){cur.summary=norm(m[1]);continue;}
    if((m=/^COUNTS (\d+) (\d+)$/.exec(l))){cur.counts=[m[1],m[2]];continue;}
    if((m=/^\[([^\]]+)\] (FAIL .*)$/.exec(l))){cur.fails.push({label:m[1],line:norm(m[2])});continue;}
    throw Error('list: unreadable line: '+l);}
  return L;
}
function summaryOf(log){let s=null;for(const l of log.split(/\r?\n/))if(COUNT_RE.test(l)&&!/^(PASS|FAIL) /.test(l))s=l;return s===null?null:norm(s);}
function main(){
  const host=os.hostname(),platform=process.platform;
  let L;try{L=parseList(fs.readFileSync(LIST,'utf8'));}catch(e){console.log('BAD INPUT: '+e.message);return 2;}
  if(!L.host){console.log('BAD INPUT: the list has no HOST line');return 2;}
  console.log('HOST this machine: '+host+' ('+platform+'); list host of record: '+L.host.name+' ('+L.host.platform+')');
  if(host!==L.host.name||platform!==L.host.platform){console.log('NOT THE HOST OF RECORD: the expected-fails list is for '+L.host.name+' ('+L.host.platform+'); this machine is '+host+' ('+platform+'). Nothing was compared (exit 2, not a FAIL).');return 2;}
  if(!fs.existsSync(SUMF)){console.log('BAD INPUT: no summary file '+SUMF);return 2;}
  const exits=new Map();
  for(const l of fs.readFileSync(SUMF,'utf8').split(/\r?\n/)){const m=/^(\S+) exit=(\d+)/.exec(l);if(m)exits.set(m[1],m[2]);}
  let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' :: '+x:''));c?pass++:fail++;};
  for(const name of exits.keys())if(name!==SELF&&!L.suites.has(name))ok('suite '+name+' (in the run) is listed',false,'UNLISTED suite');
  for(const S of L.suites.values()){
    const f=path.join(LOGS,S.name+'.run.log');
    if(!fs.existsSync(f)){ok(S.name+': log present',false,'MISSING log '+f);continue;}
    const log=fs.readFileSync(f,'utf8'),got=log.split(/\r?\n/).filter(l=>l.startsWith('FAIL ')).map(norm),want=S.fails.map(x=>x.line);
    const rest=got.slice(),missing=[];for(const w of want){const i=rest.indexOf(w);if(i<0)missing.push(w);else rest.splice(i,1);}
    const det=[];for(const m of missing)det.push('MISSING: '+m);for(const u of rest)det.push('UNEXPECTED: '+u);
    const ex=exits.has(S.name)?exits.get(S.name):null,sm=summaryOf(log),cm=sm?COUNT_RE.exec(sm):null;
    if(ex!==S.exit)det.push('EXIT: expected '+S.exit+', got '+(ex===null?'(no exit line)':ex));
    if(sm!==S.summary)det.push('SUMMARY: expected "'+S.summary+'", got '+(sm===null?'(none)':'"'+sm+'"'));
    if(!cm||cm[1]!==S.counts[0]||cm[2]!==S.counts[1])det.push('COUNTS: expected '+S.counts.join(' / ')+', got '+(cm?cm[1]+' / '+cm[2]:'(none)'));
    ok(S.name+': '+want.length+' expected FAIL line(s), exit '+S.exit+', summary '+S.counts[0]+' / '+S.counts[1],det.length===0,det.join(' | '));
    for(const d of det)console.log('     '+d);}
  console.log('SUMMARY '+SELF+': '+pass+' passed, '+fail+' failed');
  return fail?1:0;
}
module.exports={parseList,summaryOf,COUNT_RE,norm};
if(require.main===module)process.exit(main());
