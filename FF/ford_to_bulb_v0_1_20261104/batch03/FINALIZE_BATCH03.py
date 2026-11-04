from pathlib import Path
import json,hashlib,time,datetime,sys
p=Path(__file__).resolve().parent;old=p.parent/'batch01';sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
attempt=sys.argv[1] if len(sys.argv)>1 else 'Combinatorics09'
def write(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):write(p/n,json.dumps(o,indent=2)+'\n')
d=json.loads((p/'DEADLINE_BATCH03.json').read_text());now=int(time.time());assert now<d['deadline_unix']
groups=[(old,'FVLTFordBulbDataV1','Data01','Batch01Data01'),(old,'FVLTFordBulbParameterV1','Parameter02','Batch01Parameter02'),(p,'FVLTFordBulbCombinatoricsV1',attempt,'Batch03'+attempt)]
rows=[];names=[]
for base,module,local,remote in groups:
 source=base/f'attempts/{local}/src/{module}.lean'
 row={'module':module,'source':source.relative_to(p.parent).as_posix(),'source_sha256':sha(source),'receipts':{}}
 for mode in ['Compile','axioms','replay']:
  f=base/(mode+module+remote+'.json');r=json.loads(f.read_text());log=f.with_suffix('.log')
  assert r['accepted_result'] and r['exit_code']==0 and not r['timeout']
  assert r['source_unchanged'] and r['reviewed_files_unchanged'] and r['library_checksums_before']==r['library_checksums_after']==401
  assert sha(log)==r['log_sha256'];row['receipts'][mode]={'file':f.relative_to(p.parent).as_posix(),'sha256':sha(f),'log_sha256':sha(log),'seconds':r['seconds']}
  if mode=='Compile':row['theorem_targets']=r['frozen_public_targets'];names+=r['frozen_public_targets']
  if mode=='axioms':assert all(set(a)<=set(['propext','Classical.choice','Quot.sound']) for a in r['named_axiom_reports'].values())
  if mode=='replay':
   rr=json.loads(log.read_text().strip().splitlines()[-1]);assert rr['verdict']=='PASS' and rr['kernelReplayCompleted'] and not rr['failures'] and rr['unsafeConstants']==rr['partialConstants']==0
   assert rr['auditedConstants']==rr['targetConstants']>0;row['strict_constants']=rr['targetConstants']
 rows.append(row)
idx=json.loads((p.parent/'freeze_packet_v0_1/TARGET_INDEX_v0_1.json').read_text());remaining=[t['name'] for t in idx['targets'] if t['name'] not in names]
assert len(names)==22 and len(remaining)==11
failed=[f.name for f in p.glob('Compile*.json') if not json.loads(f.read_text())['accepted_result']]
state={'status':'CLOSED_PARTIAL_PRODUCER_CHECKS_PASS','closed_unix':now,'closed_utc':datetime.datetime.fromtimestamp(now,datetime.timezone.utc).isoformat(),'deadline':d,'new_theorem_targets_in_batch':5,'cumulative_theorem_targets':22,'total_targets':33,'remaining_targets':remaining,'latest_module_results':rows,'separate_module_strict_constants':sum(r['strict_constants'] for r in rows),'preserved_failed_attempts':failed,'independent_rebuild':'PENDING','independent_fidelity':'PENDING','g1_excluded':True,'kernel_adoption':False,'library_publication':False,'rule30_claim':False,'clock_closed_no_more_jobs':True}
save('BATCH03_CLOSURE_v0_1.json',state)
ls=['# FF-4 batch 3: order, rotation and Farey arithmetic','','2026-11-04. **Five new theorem targets pass producer checks; cumulative progress is 22 of 33.** Independent clean rebuild and mathematical-fidelity review remain pending.','','The new results prove exact return after q doublings, the Farey denominator lower bound, equality only at the mediant, strict ordering of all phase words, and the modular doubling/phase-rotation identity.','','Strict ordering uses coprime modular surjectivity and exact prefix counts, with binary prefix uniqueness. The rotation identity follows by comparing prepend and append recurrences modulo `2^q - 1`. These are uniform proofs, without bounded enumeration. The denominator argument uses positive integer coordinates in an adjacent Farey basis; its classical bound follows the earlier FF-3 private proof pattern without referencing a private API.','','| Latest module | Public theorem targets | Strict replay constants |','|---|---:|---:|---|']
ls += [f"| {r['module']} | {len(r['theorem_targets'])} | {r['strict_constants']} |" for r in rows]
ls += ['','Compilation, named axiom reports and strict replay pass for every listed module. Axioms are subsets of `propext`, `Classical.choice`, `Quot.sound`. Replay counts are separate-module checks; superseded combinatorial counts are not added again. Two old if-lemma names produce deprecation warnings in the strict-order proof; they do not affect proof checking.','','Every failed attempt is preserved with its source and raw log. Repairs remain confined to proofs; all public statements and the entire frozen Data file are unchanged. Execution stayed on nucleus over Tailscale with the accepted read-only v23 library, one CPU, 8 GiB and 240-second child caps. The original 1,800-second batch clock was never reset. All runs retained 401 checksums and unchanged protected files. G1 is excluded.','','## Remaining frozen targets','']
ls += ['- `'+n+'`' for n in remaining]
ls += ['','Next derive the arbitrary-iteration phase law, minimal period, common cycle, orbit set/cardinality, sorted ranks and the unique unit gap. Then prove full arbitrary-address interval ordering and its interval/mediant consequences. Full C1 remains unrestricted to Farey neighbours. B6 and ray-landing claims remain deferred.','','Independent rebuild and separate fidelity review are still required for final acceptance. No Rule 30 result, kernel adoption or library publication is claimed.','','[Machine-readable closure](BATCH03_CLOSURE_v0_1.json) pins final sources and successful receipts. Jobs, comparison records and raw logs remain adjacent; the manifest pins their bytes. [Prior batch status](../batch02/BATCH02_STATUS_v0_1.md) remains unchanged.']
write(p/'BATCH03_STATUS_v0_1.md','\n'.join(ls)+'\n')
fs=[f for f in sorted(p.rglob('*')) if f.is_file() and f.name!='BATCH03_MANIFEST_v0_1.json' and '__pycache__' not in f.parts]
save('BATCH03_MANIFEST_v0_1.json',{'schema':'ff4-batch-manifest/1','closed_unix':now,'entries':[{'path':f.relative_to(p).as_posix(),'sha256':sha(f),'bytes':f.stat().st_size} for f in fs]})
print(json.dumps({'closed_unix':now,'elapsed':now-d['origin_unix'],'status':sha(p/'BATCH03_STATUS_v0_1.md'),'closure':sha(p/'BATCH03_CLOSURE_v0_1.json'),'manifest':sha(p/'BATCH03_MANIFEST_v0_1.json'),'entries':len(fs),'strict':state['separate_module_strict_constants']},indent=2))
