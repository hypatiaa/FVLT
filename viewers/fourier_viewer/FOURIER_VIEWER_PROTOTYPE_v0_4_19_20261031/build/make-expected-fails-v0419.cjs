'use strict';
// v0.4.19 (SCHEMA_ADDENDUM_26, item 3): writes build/EXPECTED_FAILS_v0419.txt, the host-tagged list read by check-expected-fails-v0419.cjs.
// Inputs: the Linux BASELINE run (the v0.4.18 build's full runall.sh on membrane: its logs and SUMMARY_v0418.txt) and the v0.4.19 logs that define the
// expected state (for every suite of the v0.4.19 runall.sh: exit code, SUMMARY line, counts, FAIL lines), plus a JSON file of labels for the FAIL lines
// that are NOT in the baseline: {"<suite>": {"<exact FAIL line>": "new card: <why>"}}. A FAIL line in the baseline log of the same suite is labelled
// [baseline]; any other FAIL line must have a label, or the list is not written (exit 1). New v0.4.19 suites have no baseline: every FAIL line needs a label.
// Usage: node build/make-expected-fails-v0419.cjs BASE_LOGS NEW_LOGS NEW_SUMMARY LABELS.json OUT [SUITE ...]
const fs=require('fs'),path=require('path');
const CK=require('./check-expected-fails-v0419.cjs');
const [BASE,NEW,NEWSUM,LAB,OUT]=process.argv.slice(2,7);
const labels=JSON.parse(fs.readFileSync(LAB,'utf8'));
const exits=new Map();for(const l of fs.readFileSync(NEWSUM,'utf8').split(/\r?\n/)){const m=/^(\S+) exit=(\d+)/.exec(l);if(m)exits.set(m[1],m[2]);}
const suites=[...exits.keys()].filter(n=>n!=='check-expected-fails-v0419');
const out=['# EXPECTED_FAILS_v0419.txt: the expected state of every suite of the v0.4.19 runall.sh on the host of record (SCHEMA_ADDENDUM_26, item 3).',
  '# Read by build/check-expected-fails-v0419.cjs, which compares, per suite: the exact multiset of FAIL lines, the exit code, the SUMMARY line and its counts.',
  '# Host of record: membrane (Linux; saphir, 2026-10-31: browser checks run on membrane). On another host the checker exits 2 and compares nothing.',
  '# Labels: [baseline] = the same FAIL line is in the log of the same suite in the Linux baseline run (the v0.4.18 build, full runall.sh, membrane);',
  '# [new card: ...] = the line is caused by a v0.4.19 change, named in the label. Written by build/make-expected-fails-v0419.cjs.',
  '# Timings: every "<digits> ms" is written (and compared) as "<n> ms"; timings are not results.',
  'HOST membrane linux'];
let bad=[];
for(const s of suites){
  const f=path.join(NEW,s+'.run.log');if(!fs.existsSync(f)){bad.push(s+': no log');continue;}
  const log=fs.readFileSync(f,'utf8'),fails=log.split(/\r?\n/).filter(l=>l.startsWith('FAIL ')).map(CK.norm),sm=CK.summaryOf(log),cm=sm?CK.COUNT_RE.exec(sm):null;
  if(!sm){bad.push(s+': no SUMMARY line');continue;}
  const bf=path.join(BASE,s+'.run.log'),base=fs.existsSync(bf)?fs.readFileSync(bf,'utf8').split(/\r?\n/).filter(l=>l.startsWith('FAIL ')).map(CK.norm):[];
  out.push('SUITE '+s,'EXIT '+exits.get(s),'SUMMARY-LINE '+sm,'COUNTS '+cm[1]+' '+cm[2]);
  const pool=base.slice();
  for(const l of fails){const i=pool.indexOf(l);if(i>=0){pool.splice(i,1);out.push('[baseline] '+l);continue;}
    const lab=labels[s]&&(labels[s][l]||Object.entries(labels[s]).filter(([k])=>CK.norm(k)===l).map(([,v])=>v)[0]);if(!lab){bad.push(s+': unattributed '+l.slice(0,200));continue;}out.push('['+lab+'] '+l);}
}
if(bad.length){console.log(bad.join('\n'));console.log('NOT WRITTEN: '+bad.length+' problem(s)');process.exit(1);}
fs.writeFileSync(OUT,out.join('\n')+'\n');console.log('wrote '+OUT+': '+suites.length+' suites');
