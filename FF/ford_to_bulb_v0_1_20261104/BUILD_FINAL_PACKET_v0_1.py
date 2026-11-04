from pathlib import Path
import json,hashlib,re,shutil,datetime
root=Path(__file__).resolve().parent;out=root/'final_source_packet_v0_1';sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
assert not out.exists();out.mkdir()
def write(f,s):f.parent.mkdir(parents=True,exist_ok=True);f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):write(out/n,json.dumps(o,indent=2)+'\n')
def copy(src,dest):
 f=out/dest;f.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,f)
closure=json.loads((root/'batch06/BATCH06_CLOSURE_v0_1.json').read_text());assert closure['cumulative_theorem_targets']==33 and closure['final_manager_acceptance']=='PENDING'
idx=json.loads((root/'freeze_packet_v0_1/TARGET_INDEX_v0_1.json').read_text());checks=[];sourcepins={}
for row in closure['latest_module_results']:
 module=row['module'];src=root/row['source'];assert sha(src)==row['source_sha256'];copy(src,'sources/'+src.name);sourcepins[src.name]=sha(src)
 if module=='FVLTFordBulbDataV1':assert src.read_bytes()==(root/'freeze_packet_v0_1/FF4_DEFINITIONS_PROPOSED_v0_1.lean.txt').read_bytes()
 else:
  s=src.read_text(encoding='utf-8');actual=[]
  for m in re.finditer(r'^theorem\s+([A-Za-z0-9_]+)',s,re.M):
   header=s[m.start():s.index(' := by',m.start())];name='FVLT.FordBulbV1.'+m.group(1)
   expected=next(t for t in idx['targets'] if t['name']==name and t['module']==module)
   assert header==expected['header'];actual.append(name);checks.append({'name':name,'module':module,'header_sha256':hashlib.sha256(header.encode()).hexdigest(),'exact_frozen_match':True})
  assert set(actual)=={t['name'] for t in idx['targets'] if t['module']==module}
 for mode,entry in row['receipts'].items():
  f=root/entry['file'];assert sha(f)==entry['sha256'];copy(f,'evidence/'+f.name);copy(f.with_suffix('.log'),'evidence/'+f.with_suffix('.log').name)
  receipt=json.loads(f.read_text());assert receipt['accepted_result']
  job=root/f.parent.name/('JOB_'+receipt['job']['run_id']+'.json');copy(job,'evidence/jobs/'+job.name)
 compilefile=root/row['receipts']['Compile']['file'];cr=json.loads(compilefile.read_text());obj=src.parent.parent/'build'/f'{module}.olean';assert sha(obj)==cr['olean_sha256'];copy(obj,'producer_objects/'+obj.name)
assert len(checks)==33
save('FINAL_STATEMENT_CHECK_v0_1.json',{'verdict':'PASS','exact_public_headers':33,'expected_public_headers':33,'full_data_byte_match':True,'source_sha256':sourcepins,'checks':checks})
save('FINAL_SOURCE_FREEZE_v0_1.json',{'status':'ALL_33_PRODUCER_PASS_INDEPENDENT_AUDIT_PENDING','source_sha256':sourcepins,'public_targets':33,'data_named_targets':31,'strict_constants_separate_modules':closure['separate_module_strict_constants'],'library':'v23','lean':'leanprover/lean4:v4.35.0','mathlib_rev':'56a005855ea17e0b0958f73ec801ae140b0a1679','accepted_freeze_decision_sha256':'5195a4be569cc05c60aced44dd14bbf23a615a10cfe5f39cca12e490d694d8f7','original_freeze_manifest_sha256':'115a6c7d95384e2caeb8c5453ff876f2ea4519bf4afdc8eec23e4aaec1906d90','independent_rebuild':'PENDING','independent_fidelity':'PENDING','final_manager_acceptance':'PENDING','kernel_adoption':False,'library_publication':False,'rule30_claim':False})
shutil.copytree(root/'freeze_packet_v0_1',out/'accepted_original_freeze')
for n in ['WORK_ORDER_v0_2.md','FF4_FREEZE_DECISION_v0_1.md']:copy(root/n,'authority/'+n)
copy(root/'owner_review_v0_1/ACCEPTANCE_v0_2.md','authority/OWNER_ACCEPTANCE_v0_2.md')
for batch in range(1,7):
 b=f'batch{batch:02d}';B=f'BATCH{batch:02d}'
 for suffix in ['STATUS_v0_1.md','CLOSURE_v0_1.json','MANIFEST_v0_1.json']:copy(root/b/(B+'_'+suffix),'history/'+B+'_'+suffix)
write(out/'README.md','''# FF-4 final source packet v0.1

2026-11-04. **All 33 frozen targets pass producer checks. Independent rebuild, fidelity review and final manager acceptance are pending.**

The three files in `sources/` are the closed review inputs: the exact 31-declaration Data file, four parameter theorems, and 29 combinatorial theorems. `FINAL_STATEMENT_CHECK_v0_1.json` checks all 33 headers byte for byte against the accepted freeze and verifies the entire Data file. `FINAL_SOURCE_FREEZE_v0_1.json` records source and library pins.

`evidence/` retains successful compile, raw named axiom and strict all-constant replay receipts and logs for each final module. `producer_objects/` holds the hash-matched objects as producer evidence; an independent review must rebuild its own. Strict replay counts cover the latest separate modules, not an integrated dependency replay. Named reports contain only standard Lean axioms or a subset.

`authority/` and `accepted_original_freeze/` preserve the accepted work order, freeze decision and original review inputs. Historical proposal/example files there remain historical. `history/` pins all six closed development batches, including their links to preserved failures and proof-only repairs in the workspace. Do not reuse a closed producer clock or job; the independent reviewer should preregister its own clean folder, capacity, reservation and jobs under the accepted limits.

The mathematical scope is exact finite mechanical words, their characteristic integer/rational addresses, period and orbit/rank laws, the unique directed unit gap including the closing edge, full arbitrary-address interval ordering, Farey consequences, and the four parameter identities. Full angle ordering is not restricted to Farey neighbours. Review the meaning separately from compilation, especially the cyclic closing edge, arbitrary denominators in C1, guards on reduced addresses, and primitive-root order.

B6 uniqueness and parameter-ray landing are deferred. This packet makes no MLC, Rule 30, quantum advantage, kernel-adoption, release/publication or prize-submission claim. The locked FVLT kernel is unchanged. G1 is excluded. Execution used nucleus over Tailscale and pinned read-only v23. Four old if/dif lemma names produce deprecation warnings; final sources have no compile errors.
''')
files=[f for f in sorted(out.rglob('*')) if f.is_file() and f.name!='FINAL_PACKET_MANIFEST_v0_1.json']
save('FINAL_PACKET_MANIFEST_v0_1.json',{'schema':'ff4-final-source-packet/1','status':'PRODUCER_ALL_33_PASS_AUDIT_PENDING','entries':[{'path':f.relative_to(out).as_posix(),'sha256':sha(f),'bytes':f.stat().st_size} for f in files]})
assert all(sha(out/e['path'])==e['sha256'] for e in json.loads((out/'FINAL_PACKET_MANIFEST_v0_1.json').read_text())['entries'])
print(json.dumps({'packet':str(out),'manifest_sha256':sha(out/'FINAL_PACKET_MANIFEST_v0_1.json'),'entries':len(files),'source_freeze_sha256':sha(out/'FINAL_SOURCE_FREEZE_v0_1.json'),'statement_check_sha256':sha(out/'FINAL_STATEMENT_CHECK_v0_1.json'),'source_sha256':sourcepins},indent=2))
