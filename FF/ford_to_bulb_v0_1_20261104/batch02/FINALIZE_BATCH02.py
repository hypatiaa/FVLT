from pathlib import Path
import json,hashlib,time,datetime
p=Path(__file__).resolve().parent;old=p.parent/'batch01';sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def write(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):write(p/n,json.dumps(o,indent=2)+'\n')
deadline=json.loads((p/'DEADLINE_BATCH02.json').read_text());now=int(time.time());assert now<deadline['deadline_unix']
groups=[(old,'FVLTFordBulbDataV1','Data01','Batch01Data01'),(old,'FVLTFordBulbParameterV1','Parameter02','Batch01Parameter02'),(p,'FVLTFordBulbCombinatoricsV1','Combinatorics05','Batch02Combinatorics05')]
rows=[];names=[]
for base,module,local,remote in groups:
 row={'module':module,'source':str((base/f'attempts/{local}/src/{module}.lean').relative_to(p.parent)).replace('\\','/'),'source_sha256':sha(base/f'attempts/{local}/src/{module}.lean'),'receipts':{}}
 for mode in ['Compile','axioms','replay']:
  f=base/(mode+module+remote+'.json');r=json.loads(f.read_text())
  assert r['accepted_result'] and r['exit_code']==0 and not r['timeout']
  assert r['source_unchanged'] and r['reviewed_files_unchanged']
  assert r['library_checksums_before']==r['library_checksums_after']==401
  log=f.with_suffix('.log');assert sha(log)==r['log_sha256']
  row['receipts'][mode]={'file':f.relative_to(p.parent).as_posix(),'sha256':sha(f),'log_sha256':sha(log),'seconds':r['seconds']}
  if mode=='Compile':row['theorem_targets']=r['frozen_public_targets'];names+=r['frozen_public_targets']
  if mode=='axioms':assert all(set(a)<=set(['propext','Classical.choice','Quot.sound']) for a in r['named_axiom_reports'].values())
  if mode=='replay':
   rr=json.loads(log.read_text().strip().splitlines()[-1]);assert rr['verdict']=='PASS' and rr['kernelReplayCompleted'] and not rr['failures'] and rr['unsafeConstants']==rr['partialConstants']==0
   assert rr['auditedConstants']==rr['targetConstants']>0;row['strict_constants']=rr['targetConstants']
 rows.append(row)
idx=json.loads((p.parent/'freeze_packet_v0_1/TARGET_INDEX_v0_1.json').read_text());remaining=[t['name'] for t in idx['targets'] if t['name'] not in names]
assert len(names)==17 and len(remaining)==16
state={'status':'CLOSED_PARTIAL_PRODUCER_CHECKS_PASS','closed_unix':now,'closed_utc':datetime.datetime.fromtimestamp(now,datetime.timezone.utc).isoformat(),'deadline':deadline,'new_theorem_targets_in_batch':6,'cumulative_theorem_targets':17,'total_targets':33,'remaining_targets':remaining,'latest_module_results':rows,'separate_module_strict_constants':sum(r['strict_constants'] for r in rows),'preserved_failed_attempt':'CompileFVLTFordBulbCombinatoricsV1Batch02Combinatorics04.json','independent_rebuild':'PENDING','independent_fidelity':'PENDING','g1_excluded':True,'kernel_adoption':False,'library_publication':False,'rule30_claim':False,'clock_closed_no_more_jobs':True}
save('BATCH02_CLOSURE_v0_1.json',state)
ls=['# FF-4 batch 2: exact words and characteristic adjacency','','2026-11-04. **Six new theorem targets pass producer checks; cumulative progress is 17 of 33.** Independent clean rebuild and mathematical-fidelity review remain pending.','','The new results establish:','','- Every rational strictly between 0 and 1 has a guarded reduced address.','- The finite indexed digit sum equals the encoded binary word.','- Every word is strictly between zero and the modulus `2^q - 1`.','- The upper characteristic numerator is exactly the lower numerator plus one.','- Both characteristic numerators lie strictly inside the modulus, in increasing order.','- The characteristic angle gap is exactly `1 / (2^q - 1)`.','','The bounds proof counts digits by a carry identity and telescoping, then applies binary bounds. The adjacency proof uses coprimality to rule out an earlier divisible prefix, proves the early words agree, and identifies the final `01`/`10` swap. These are uniform exact proofs, with no finite enumeration.','','One private natural-subtraction tactic failed in Combinatorics04. Its source, job, receipt and raw log are preserved. Combinatorics05 replaces only that tactic with `omega`; all public statements and frozen Data remain unchanged.','','| Latest module | Public theorem targets | Strict replay constants |','|---|---:|---:|']
ls += [f"| {r['module']} | {len(r['theorem_targets'])} | {r['strict_constants']} |" for r in rows]
ls += ['','Every module passes compilation, raw named axiom checks, and strict replay of all introduced constants. Named axioms are subsets of `propext`, `Classical.choice`, and `Quot.sound`. Counts above are separate-module checks; superseded combinatorial modules are not counted again.','','Execution used nucleus over Tailscale with the accepted read-only v23 library, one CPU, 8 GiB and 240-second child limits. The new 1,800-second batch clock began before proof writing and staging, and was never reset. All runs retained 401 checksums and unchanged protected files. G1 remains excluded.','','## Remaining frozen targets','']
ls += ['- `'+n+'`' for n in remaining]
ls += ['','Next: exact period return and minimal period, the common cycle, strict word ordering and orbit/rank laws, the unique unit gap, then arbitrary-address interval ordering and Farey consequences. Full C1 remains an arbitrary ordered reduced-fraction statement; it is not weakened to Farey neighbours.','','Independent rebuild, raw axiom audit, strict replay and separate fidelity review are still required for final acceptance. No ray-landing/B6 uniqueness, Rule 30, kernel-adoption or publication claim is made.','','[Machine-readable closure](BATCH02_CLOSURE_v0_1.json) pins the final sources and every successful receipt. The adjacent manifest, frozen jobs and raw logs preserve the evidence. [Prior batch status](../batch01/BATCH01_STATUS_v0_1.md) remains unchanged.']
write(p/'BATCH02_STATUS_v0_1.md','\n'.join(ls)+'\n')
fs=[f for f in sorted(p.rglob('*')) if f.is_file() and f.name!='BATCH02_MANIFEST_v0_1.json' and '__pycache__' not in f.parts]
save('BATCH02_MANIFEST_v0_1.json',{'schema':'ff4-batch-manifest/1','closed_unix':now,'entries':[{'path':f.relative_to(p).as_posix(),'sha256':sha(f),'bytes':f.stat().st_size} for f in fs]})
print(json.dumps({'closed_unix':now,'elapsed':now-deadline['origin_unix'],'status':sha(p/'BATCH02_STATUS_v0_1.md'),'closure':sha(p/'BATCH02_CLOSURE_v0_1.json'),'manifest':sha(p/'BATCH02_MANIFEST_v0_1.json'),'entries':len(fs),'strict':state['separate_module_strict_constants']},indent=2))
