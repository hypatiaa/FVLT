from pathlib import Path
import json,hashlib,time,datetime
p=Path(__file__).resolve().parent;sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def write(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):write(p/n,json.dumps(o,indent=2)+'\n')
deadline=json.loads((p/'DEADLINE_BATCH01.json').read_text());now=int(time.time())
assert now<deadline['deadline_unix'],'Do not retrospectively claim closure inside the batch'
groups=[('FVLTFordBulbDataV1','Data01','Batch01Data01'),('FVLTFordBulbParameterV1','Parameter02','Batch01Parameter02'),('FVLTFordBulbCombinatoricsV1','Combinatorics01','Batch01Combinatorics01')]
results=[];targets=[]
for module,local,remote in groups:
 row={'module':module,'source':f'attempts/{local}/src/{module}.lean','source_sha256':sha(p/f'attempts/{local}/src/{module}.lean'),'receipts':{}}
 for mode in ['Compile','axioms','replay']:
  name=mode+module+remote+'.json';r=json.loads((p/name).read_text())
  assert r['accepted_result'] and r['exit_code']==0 and not r['timeout']
  assert r['source_unchanged'] and r['reviewed_files_unchanged']
  assert r['library_checksums_before']==r['library_checksums_after']==401
  assert r['started_unix']<deadline['deadline_unix']
  row['receipts'][mode]={'file':name,'sha256':sha(p/name),'seconds':r['seconds'],'log_sha256':r['log_sha256']}
  assert sha(p/(name[:-5]+'.log'))==r['log_sha256']
  if mode=='Compile':
   row['theorem_targets']=r['frozen_public_targets'];targets+=r['frozen_public_targets']
  if mode=='axioms':
   assert all(set(a)<=set(['propext','Classical.choice','Quot.sound']) for a in r['named_axiom_reports'].values())
  if mode=='replay':
   rr=json.loads((p/(name[:-5]+'.log')).read_text().strip().splitlines()[-1])
   assert rr['verdict']=='PASS' and rr['kernelReplayCompleted'] and not rr['failures']
   assert rr['unsafeConstants']==rr['partialConstants']==0 and rr['auditedConstants']==rr['targetConstants']>0
   row['strict_replay_constants']=rr['targetConstants']
 results.append(row)
idx=json.loads((p.parent/'freeze_packet_v0_1/TARGET_INDEX_v0_1.json').read_text())
remaining=[t['name'] for t in idx['targets'] if t['name'] not in targets]
assert len(targets)==11 and len(remaining)==22
status={'status':'CLOSED_PARTIAL_PRODUCER_CHECKS_PASS','closed_unix':now,'closed_utc':datetime.datetime.fromtimestamp(now,datetime.timezone.utc).isoformat(),'deadline':deadline,'library':'v23','theorem_targets_complete':11,'theorem_targets_total':33,'remaining_targets':remaining,'module_results':results,'strict_constants_total_separate_modules':sum(x['strict_replay_constants'] for x in results),'failed_attempt_preserved':'CompileFVLTFordBulbParameterV1Batch01Parameter01.json','independent_rebuild':'PENDING','independent_fidelity':'PENDING','kernel_adoption':False,'library_publication':False,'rule30_claim':False,'g1_excluded':True,'new_job_may_reuse_batch_clock':False}
save('BATCH01_CLOSURE_v0_1.json',status)
lines=['# FF-4 batch 1: producer progress and handoff','','2026-11-04. **Closed partial batch: 11 of 33 frozen theorem targets pass producer checks.** Independent clean rebuild and mathematical-fidelity review remain pending.','','The work ran on nucleus over Tailscale against the accepted v23 library. Each job was posted before launch. The original 1,800-second batch clock was preserved, with one CPU, 8 GiB and a 240-second child limit. All runs retained 401 library checksum entries and unchanged protected files. G1 is excluded.','','| Module | Public theorem targets | Strict replay constants | Result |','|---|---:|---:|---|']
for r in results:lines.append(f"| {r['module']} | {len(r['theorem_targets'])} | {r['strict_replay_constants']} | Producer compile, named axioms and strict replay pass |")
lines+=['','The Data module retains all 31 accepted declarations byte for byte. The four parameter theorems prove the cardioid fixed point, multiplier, derivative, and primitiveness of the canonical root of unity. The seven combinatorial theorems prove canonical reduced coordinates, the open-unit-interval range, injectivity, the lower bound on q, positivity of the modulus, and both digit formulas.','','Parameter01 failed at a derivative helper API call. Its source, job, receipt and raw log remain intact. Parameter02 adds the derivative-addition import to the proof module and uses an explicit lemma; no frozen definition or public statement changed.','','Every named axiom report uses only `propext`, `Classical.choice`, `Quot.sound`, or a subset. Strict replay checks every declaration introduced by each module; the counts are separate module checks, not an integrated dependency replay.','','## What remains','','The remaining 22 frozen targets are:','']
lines += ['- `'+n+'`' for n in remaining]
lines+=['','The next proof chunk should begin with address surjectivity and the finite-word sum identity, then establish mechanical-word bounds and adjacency. Those support the exact rotation/orbit laws, unique unit gap, arbitrary-address interval ordering, and Farey consequences. C1 remains an arbitrary ordered reduced-fraction claim, not a restriction to Farey neighbours.','','After the 33 targets are complete: independent clean rebuild, raw named axiom audit, strict replay, and separate statement-fidelity review. This batch does not claim ray landing, B6 uniqueness, Rule 30 consequences, kernel adoption, or publication.','','## Evidence','','[Machine-readable closure](BATCH01_CLOSURE_v0_1.json) records every passing receipt and source hash. [Batch deadline](DEADLINE_BATCH01.json) preserves the original clock. The adjacent jobs, comparison receipts and raw logs retain the full compile and replay evidence.']
write(p/'BATCH01_STATUS_v0_1.md','\n'.join(lines)+'\n')
files=[f for f in sorted(p.rglob('*')) if f.is_file() and f.name!='BATCH01_MANIFEST_v0_1.json' and '__pycache__' not in f.parts]
save('BATCH01_MANIFEST_v0_1.json',{'schema':'ff4-batch-manifest/1','closed_unix':now,'entries':[{'path':f.relative_to(p).as_posix(),'sha256':sha(f),'bytes':f.stat().st_size} for f in files]})
print(json.dumps({'closed_unix':now,'elapsed':now-deadline['origin_unix'],'remaining_targets':len(remaining),'strict_constants':status['strict_constants_total_separate_modules'],'status_sha256':sha(p/'BATCH01_STATUS_v0_1.md'),'closure_sha256':sha(p/'BATCH01_CLOSURE_v0_1.json'),'manifest_sha256':sha(p/'BATCH01_MANIFEST_v0_1.json'),'manifest_entries':len(files)},indent=2))
