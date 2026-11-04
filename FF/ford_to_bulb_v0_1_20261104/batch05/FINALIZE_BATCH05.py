from pathlib import Path
import json,hashlib,time,datetime,sys
p=Path(__file__).resolve().parent;old=p.parent/'batch01';sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest();attempt=sys.argv[1] if len(sys.argv)>1 else 'Combinatorics17'
def write(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):write(p/n,json.dumps(o,indent=2)+'\n')
d=json.loads((p/'DEADLINE_BATCH05.json').read_text());now=int(time.time());assert now<d['deadline_unix']
groups=[(old,'FVLTFordBulbDataV1','Data01','Batch01Data01'),(old,'FVLTFordBulbParameterV1','Parameter02','Batch01Parameter02'),(p,'FVLTFordBulbCombinatoricsV1',attempt,'Batch05'+attempt)]
rows=[];names=[]
for base,module,local,remote in groups:
 source=base/f'attempts/{local}/src/{module}.lean';row={'module':module,'source':source.relative_to(p.parent).as_posix(),'source_sha256':sha(source),'receipts':{}}
 for mode in ['Compile','axioms','replay']:
  f=base/(mode+module+remote+'.json');r=json.loads(f.read_text());log=f.with_suffix('.log')
  assert r['accepted_result'] and r['exit_code']==0 and not r['timeout'] and r['source_unchanged'] and r['reviewed_files_unchanged']
  assert r['library_checksums_before']==r['library_checksums_after']==401 and sha(log)==r['log_sha256']
  row['receipts'][mode]={'file':f.relative_to(p.parent).as_posix(),'sha256':sha(f),'log_sha256':sha(log),'seconds':r['seconds']}
  if mode=='Compile':row['theorem_targets']=r['frozen_public_targets'];names+=r['frozen_public_targets']
  if mode=='axioms':assert all(set(a)<=set(['propext','Classical.choice','Quot.sound']) for a in r['named_axiom_reports'].values())
  if mode=='replay':
   rr=json.loads(log.read_text().strip().splitlines()[-1]);assert rr['verdict']=='PASS' and rr['kernelReplayCompleted'] and not rr['failures'] and rr['unsafeConstants']==rr['partialConstants']==0
   assert rr['auditedConstants']==rr['targetConstants']>0;row['strict_constants']=rr['targetConstants']
 rows.append(row)
idx=json.loads((p.parent/'freeze_packet_v0_1/TARGET_INDEX_v0_1.json').read_text());remaining=[t['name'] for t in idx['targets'] if t['name'] not in names];assert len(names)==30 and len(remaining)==3
failed=[f.name for f in p.glob('Compile*.json') if not json.loads(f.read_text())['accepted_result']]
state={'status':'CLOSED_PARTIAL_PRODUCER_CHECKS_PASS','closed_unix':now,'closed_utc':datetime.datetime.fromtimestamp(now,datetime.timezone.utc).isoformat(),'deadline':d,'new_theorem_targets_in_batch':['FVLT.FordBulbV1.unique_unit_gap'],'cumulative_theorem_targets':30,'total_targets':33,'remaining_targets':remaining,'latest_module_results':rows,'separate_module_strict_constants':sum(r['strict_constants'] for r in rows),'preserved_failed_attempts':failed,'independent_rebuild':'PENDING','independent_fidelity':'PENDING','g1_excluded':True,'kernel_adoption':False,'library_publication':False,'rule30_claim':False,'clock_closed_no_more_jobs':True}
save('BATCH05_CLOSURE_v0_1.json',state)
ls=['# FF-4 batch 5: the unique unit gap','','2026-11-04. **The unique-unit-gap theorem passes producer checks; cumulative progress is 30 of 33.** Independent clean rebuild and mathematical-fidelity review remain pending.','','The theorem identifies the sole directed gap of size one in the whole sorted orbit: it starts at the lower characteristic numerator and ends at the upper numerator. Every other directed gap is at least two, including the closing edge.','','The proof establishes the final digit and hence parity of every phase word, identifies sorted coordinates using the increasing finite-set embedding, and checks the nonwrapping and wrapping cases separately. Other interior neighbours have equal parity; the closing edge is bounded below using strict interior word bounds. This is a uniform proof, without bounded enumeration.','','| Latest module | Public theorem targets | Strict replay constants |','|---|---:|---:|---|']
ls += [f"| {r['module']} | {len(r['theorem_targets'])} | {r['strict_constants']} |" for r in rows]
ls += ['','Compilation, raw named axiom checks and strict replay pass. Named axioms are subsets of `propext`, `Classical.choice`, `Quot.sound`; every introduced helper and generated declaration is replayed. Counts are for the latest separate modules, without adding superseded counts.','','Private list-index conversion attempts were preserved when they failed. The successful helper-only source was a compile checkpoint, not a full-pass claim; the final public module recompiles and replays those helpers. Repairs remain confined to proofs. All public statements and full frozen Data remain unchanged. Four if/dif lemma deprecation warnings remain.','','Execution used nucleus over Tailscale and read-only v23, one CPU, 8 GiB and 240-second child limits. The original 1,800-second batch clock was never reset. All runs retained 401 checksums and unchanged protected files. G1 is excluded.','','## Remaining frozen targets','']
ls += ['- `'+n+'`' for n in remaining]
ls += ['','Next prove full arbitrary-address angle ordering, then interval disjointness and the mediant interval. C1 remains unrestricted to Farey neighbours. B6 uniqueness and ray landing remain deferred. Independent clean rebuild and separate fidelity review are required for final acceptance. No Rule 30 result, kernel adoption or library publication is claimed.','','[Machine-readable closure](BATCH05_CLOSURE_v0_1.json) records final source and successful receipt hashes. Adjacent jobs, raw logs and the manifest retain the evidence. [Prior status](../batch04/BATCH04_STATUS_v0_1.md) remains unchanged.']
write(p/'BATCH05_STATUS_v0_1.md','\n'.join(ls)+'\n')
fs=[f for f in sorted(p.rglob('*')) if f.is_file() and f.name!='BATCH05_MANIFEST_v0_1.json' and '__pycache__' not in f.parts]
save('BATCH05_MANIFEST_v0_1.json',{'schema':'ff4-batch-manifest/1','closed_unix':now,'entries':[{'path':f.relative_to(p).as_posix(),'sha256':sha(f),'bytes':f.stat().st_size} for f in fs]})
print(json.dumps({'closed_unix':now,'elapsed':now-d['origin_unix'],'status':sha(p/'BATCH05_STATUS_v0_1.md'),'closure':sha(p/'BATCH05_CLOSURE_v0_1.json'),'manifest':sha(p/'BATCH05_MANIFEST_v0_1.json'),'entries':len(fs),'strict':state['separate_module_strict_constants']},indent=2))
