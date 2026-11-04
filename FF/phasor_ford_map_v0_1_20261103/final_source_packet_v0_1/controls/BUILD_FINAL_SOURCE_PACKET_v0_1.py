from pathlib import Path
import json,hashlib,re,shutil
root=Path(__file__).resolve().parent
out=root/'final_source_packet_v0_1'
sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def write(f,s):f.parent.mkdir(parents=True,exist_ok=True);f.write_text(s,encoding='utf-8',newline='\n')
def save(f,o):write(f,json.dumps(o,indent=2)+'\n')
sources={
 'FVLTRosetteFordDataV1':('batch02','Data02'),
 'FVLTRosetteFordPhaseV1':('batch03','Phase02'),
 'FVLTRosetteFordArithmeticV1':('batch04','Arithmetic03'),
 'FVLTRosetteFordSweepV1':('batch06','Final04'),
 'FVLTRosetteFordEndpointsV1':('batch02','Endpoints02')}
out.mkdir(exist_ok=False);(out/'sources').mkdir()
source_index={};checks=[];actual_headers={}
frozen=(root/'freeze_packet_v0_1/FF3_HEADERS_PROPOSED_v0_1.lean.txt').read_text(encoding='utf-8')
matches=list(re.finditer(r'^theorem\s+(\w+)\b',frozen,re.M));expected={}
for i,m in enumerate(matches):
 t=frozen[m.start():matches[i+1].start() if i+1<len(matches) else len(frozen)]
 t=t.split('\n--')[0].split('\nend ')[0].strip();expected[m.group(1)]=t
assert len(expected)==37
for module,(batch,attempt) in sources.items():
 src=root/batch/'attempts'/attempt/'src'/(module+'.lean')
 target=out/'sources'/src.name;shutil.copyfile(src,target)
 data=target.read_bytes();source_index[module]={'source_origin':str(src),'sha256':sha(target),'bytes':len(data),'CR_bytes':data.count(b'\r'),'UTF8_BOM':data.startswith(b'\xef\xbb\xbf')}
 text=target.read_text(encoding='utf-8')
 assert not re.search(r'\b(sorry|admit|axiom|native_decide|implemented_by|unsafe|extern)\b',text)
 assert not re.search(r'^\s*variable\b',text,re.M)
 for m in re.finditer(r'^theorem\s+(\w+)\b',text,re.M):
  header=text[m.start():].split(' := by',1)[0].strip();name=m.group(1)
  assert name not in actual_headers and header==expected[name],name
  actual_headers[name]={'module':module,'header_match_after_newline_normalization':True}
 stem=module+batch.replace('batch','Batch')+attempt
 recs={}
 for mode in ['Compile','axioms','replay']:
  name=mode+stem
  receipt=root/batch/(name+'.json');log=root/batch/(name+'.log');r=json.loads(receipt.read_text())
  assert r['accepted_result'] and r['exit_code']==0 and not r['timeout']
  assert r['library_checksums_before']==r['library_checksums_after']==396
  assert r['source_unchanged'] and r['reviewed_files_unchanged'] and r['library'].endswith('/v22')
  assert sha(log)==r['log_sha256']
  for sn,sh in r['job']['source_sha256'].items():assert sha(out/'sources'/sn)==sh if (out/'sources'/sn).exists() else sha(root/batch/'attempts'/attempt/'src'/sn)==sh
  dst=out/'checks'/module;dst.mkdir(parents=True,exist_ok=True)
  shutil.copyfile(receipt,dst/receipt.name);shutil.copyfile(log,dst/log.name)
  recs[mode]={'receipt':str((dst/receipt.name).relative_to(out)),'sha256':sha(receipt),'seconds':r['seconds']}
  if mode=='axioms':
   recs[mode]['named_reports']=r['named_axiom_reports'];assert all(set(a)<= {'propext','Classical.choice','Quot.sound'} for a in r['named_axiom_reports'].values())
  if mode=='replay':
   replay=json.loads(log.read_text().splitlines()[-1]);assert replay['verdict']=='PASS' and replay['kernelReplayCompleted'] and not replay['failures'] and replay['unsafeConstants']==replay['partialConstants']==0
   recs[mode]['introduced_constants']=replay['targetConstants']
 checks.append({'module':module,'checks':recs})
assert set(actual_headers)==set(expected)
assert (out/'sources/FVLTRosetteFordDataV1.lean').read_bytes()==(root/'definition_repair_v0_1/FF3_DEFINITIONS_PROPOSED_v0_2.lean.txt').read_bytes()
shutil.copytree(root/'freeze_packet_v0_1',out/'controls/freeze_packet_v0_1')
shutil.copytree(root/'rebind_v22_v0_1',out/'controls/rebind_v22_v0_1')
for file in ['FF3_FREEZE_DECISION_v0_1.md','FF3_REBIND_V22_DECISION_v0_1.md']:
 shutil.copyfile(root/file,out/'controls'/file)
shutil.copytree(root/'definition_repair_v0_1',out/'controls/definition_repair_v0_1')
shutil.copyfile(Path(__file__),out/'controls/BUILD_FINAL_SOURCE_PACKET_v0_1.py')
save(out/'SOURCE_INDEX_v0_1.json',source_index)
save(out/'SOURCE_AND_HEADER_COMPARISON_v0_1.json',{'status':'PRODUCER_TEXT_COMPARISON_PASS','theorem_headers':37,'all_headers_match':True,'line_endings_normalized_for_comparison_only':True,'data_exact_successor':True,'items':actual_headers,'independent_semantic_review':'PENDING'})
save(out/'CHECK_INDEX_v0_1.json',{'status':'PRODUCER_LOCAL_37_OF_37_INDEPENDENT_PENDING','modules':checks,'separate_module_constants':sum(x['checks']['replay']['introduced_constants'] for x in checks),'clean_integrated_rebuild':'PENDING','independent_rebuild_replay':'PENDING','independent_statement_fidelity':'PENDING'})
write(out/'README.md','''# FF-3 final producer source packet v0.1

2026-11-04. All 37 frozen theorem targets pass producer-local compilation, named axiom checks and strict all-constant replay. Final acceptance is PENDING independent clean integrated rebuild/replay and separate statement-fidelity review. This packet is review material, not a library release or kernel adoption.

`sources/` contains the five selected final modules, copied byte for byte. `SOURCE_INDEX_v0_1.json` pins source origins, hashes and line endings. Historical Phase and Endpoints CRLF bytes are preserved; only header comparisons normalize newlines. Data equals the accepted annotation successor exactly. All 37 statement headers match the original freeze. Source checks do not substitute for semantic review.

`checks/` contains every selected module's producer compile, named-axiom and strict-replay raw log and receipt. `CHECK_INDEX_v0_1.json` lists results and constant counts; predecessor attempts are not counted twice. Imported library dependencies were reused during producer checks. These are separate module checks, not a cold integrated rebuild.

`controls/` retains the original frozen packet, accepted v22 runner/template rebind and annotation-repair decisions. Original v21 reference metadata stays historical. All actual producer calls used v22 and Lean 4.35.0. Independent work must verify the currently latest library/toolchain, all library hashes/read-only state, fresh Tailscale nucleus capacity/reservation, a batch clock before staging, an all-match binding and exact posted jobs. Do not reuse any closed producer batch. Use one CPU, 8 GiB address space, 240 seconds per child and the pinned strict checker. A library/toolchain change returns for binding review.

For the independent clean build use a new empty output folder, compile Data first, then Phase and Arithmetic, then Sweep and Endpoints with only freshly rebuilt local dependencies. Do not copy producer `.olean` files. Collect exact named reports (Data19, Phase5, Arithmetic15, Sweep9, Endpoints8) and strict all-introduced-constant replay per module. The only permitted axioms are propext, Classical.choice and Quot.sound. Preserve all failures and stop dependents after failure.

G1, Neo mathematical compute, Wolfram restart, continuous/oriented arcs, dynamics, unlabelled-phasor inversion, factoring advantage, viewer/kernel edits, publication, commits and library sync are outside scope. No assumed Lemma6a, placeholder proof or finite-check substitute is used. The final classical Farey result uses bounded Bezout, a unimodular interval denominator bound and strict sorted-index consecutivity.

The original framework/map question is Robin Miller's; the reused arithmetic and Farey/Ford components are classical. No novelty or Rule30 prize claim is made.
''')
files=[{'file':str(f.relative_to(out)).replace('\\','/'),'sha256':sha(f),'bytes':f.stat().st_size} for f in sorted(out.rglob('*')) if f.is_file()]
save(out/'PACKET_MANIFEST_v0_1.json',{'status':'PRODUCER_LOCAL_37_OF_37_INDEPENDENT_PENDING','files':files})
print(json.dumps({'packet':str(out),'files':len(files),'manifest_sha256':sha(out/'PACKET_MANIFEST_v0_1.json'),'source_comparison_sha256':sha(out/'SOURCE_AND_HEADER_COMPARISON_v0_1.json'),'check_index_sha256':sha(out/'CHECK_INDEX_v0_1.json')},indent=2))
