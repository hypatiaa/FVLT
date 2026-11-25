'use strict';
// Verifier: is EXPECTED_FAILS_v0419.txt rebuilt honestly from the logs of record? For every SUITE: every [baseline] FAIL line must be in the same suite's log
// of the builder's v0.4.18 Linux baseline run; every [new card] line must NOT be there (else it should be [baseline]); and list how the baseline FAIL lines that
// are absent from the list went away. Also compares the list with a v0.4.19 run's logs (builder's and the verifier's).
// usage: node list_honesty.cjs <EXPECTED_FAILS_v0419.txt> <baseline logs dir> <v0419 logs dir (builder)> [<v0419 logs dir (verifier)>]
const fs=require('fs'),path=require('path');
const [LIST,BASE,...RUNS]=process.argv.slice(2);
const norm=l=>l.replace(/\b\d+ ms\b/g,'<n> ms');
const fails=f=>fs.existsSync(f)?fs.readFileSync(f,'utf8').split(/\r?\n/).filter(l=>l.startsWith('FAIL ')).map(norm):null;
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(!c&&x!==undefined?' :: '+x:''));c?pass++:fail++;};
const suites=[];let cur=null;
for(const l of fs.readFileSync(LIST,'utf8').split(/\r?\n/)){let m;
  if((m=/^SUITE (\S+)$/.exec(l))){cur={name:m[1],lines:[]};suites.push(cur);continue;}
  if(cur&&(m=/^\[([^\]]+)\] (FAIL .*)$/.exec(l)))cur.lines.push({label:m[1],line:norm(m[2])});}
let nb=0,nn=0;const notes=[];
for(const s of suites){
  const bl=fails(path.join(BASE,s.name+'.run.log'));
  for(const x of s.lines){
    if(x.label==='baseline'){nb++;if(!bl||!bl.includes(x.line))notes.push('BASELINE-LABEL NOT IN BASELINE LOG: '+s.name+' :: '+x.line.slice(0,140));}
    else{nn++;if(bl&&bl.includes(x.line))notes.push('NEW-CARD LABEL BUT IN BASELINE: '+s.name+' :: '+x.line.slice(0,140));}}
  if(bl){const want=s.lines.map(x=>x.line);for(const b of bl)if(!want.includes(b))console.log('INFO baseline FAIL line not in the v0.4.19 list ('+s.name+'): '+b.slice(0,160));}
}
console.log('INFO list: '+suites.length+' suites, '+nb+' [baseline] lines, '+nn+' [new card] lines');
for(const n of notes)console.log('     '+n);
ok('every [baseline] line is in the same suite of the v0.4.18 Linux baseline logs; no [new card] line is there',notes.length===0,notes.length+' issue(s)');
for(const R of RUNS){let mism=[];
  for(const s of suites){const got=fails(path.join(R,s.name+'.run.log'));if(!got){mism.push(s.name+': no log');continue;}
    const want=s.lines.map(x=>x.line),rest=got.slice();for(const w of want){const i=rest.indexOf(w);if(i<0)mism.push(s.name+' MISSING '+w.slice(0,120));else rest.splice(i,1);}for(const u of rest)mism.push(s.name+' UNEXPECTED '+u.slice(0,120));}
  for(const m of mism)console.log('     '+m);
  ok('FAIL-line multiset of every suite in '+R+' equals the list',mism.length===0,mism.length);}
console.log('SUMMARY list_honesty: '+pass+' passed, '+fail+' failed');process.exitCode=fail?1:0;
