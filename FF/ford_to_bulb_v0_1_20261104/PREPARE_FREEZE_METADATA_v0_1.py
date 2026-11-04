"""Prepare review files only: no imports/execution of runner and no Lean/Sage calls."""
from pathlib import Path
import ast,hashlib,json,re,shutil,difflib
root=Path(__file__).resolve().parent;p=root/'freeze_packet_v0_1';parent=root.parent
sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def text(f,s):f.parent.mkdir(parents=True,exist_ok=True);f.write_text(s,encoding='utf-8',newline='\n')
def save(f,o):text(f,json.dumps(o,indent=2)+'\n')
mods=['FVLTFordBulbDataV1','FVLTFordBulbParameterV1','FVLTFordBulbCombinatoricsV1']
data=(p/'FF4_DEFINITIONS_PROPOSED_v0_1.lean.txt').read_text(encoding='utf-8')
headers=(p/'FF4_HEADERS_PROPOSED_v0_1.lean.txt').read_text(encoding='utf-8')
matches=list(re.finditer(r'^theorem\s+(\w+)\b',headers,re.M));targets=[]
for i,m in enumerate(matches):
 h=headers[m.start():matches[i+1].start() if i+1<len(matches) else len(headers)].split('\n--')[0].split('\nend ')[0].strip()
 module=mods[1] if m.group(1) in {'parameter_fixed_point','parameter_multiplier','parameter_derivative','canonical_multiplier_primitive'} else mods[2]
 targets.append({'name':'FVLT.FordBulbV1.'+m.group(1),'module':module,'header':h,'header_sha256':hashlib.sha256(h.encode()).hexdigest()})
data_names=re.findall(r'^(?:noncomputable\s+)?(?:def|structure|inductive)\s+(\w+)',data,re.M)
assert len(targets)==33 and len({x['name'] for x in targets})==33
save(p/'TARGET_INDEX_v0_1.json',{'data_module':mods[0],'data_axiom_targets':['FVLT.FordBulbV1.'+n for n in data_names],'targets':targets,'excluded_target':'B6 uniqueness','standing':'PROPOSED_FOR_REVIEW_NOT_LEAN_ELABORATED'})
prior=parent/'phasor_ford_map_v0_1_20261103/rebind_v22_v0_1/RUN_FF3_v0_1.py'
original=prior.read_text(encoding='utf-8');code=original.replace('FF-3','FF-4').replace('RUN_FF3','RUN_FF4').replace('ff3_v02','ff4_v01').replace('theorem_library/v22','theorem_library/v23').replace('latest == 22','latest == 23').replace("'FF3_DISCRETE'","'FF4_COMBINATORIAL'").replace('FVLT.PhasorFordV1.','FVLT.FordBulbV1.')
start=code.index('MODULES = ');end=code.index('\nALLOWED_AXIOMS',start)
code=code[:start]+"MODULES = ('FVLTFordBulbDataV1', 'FVLTFordBulbParameterV1',\n           'FVLTFordBulbCombinatoricsV1')"+code[end:]
helper=r'''
def frozen_source_check(src, source_names, target_index, definitions):
    expected = {t['name'].split('.')[-1]: t for t in target_index['targets']}
    actual = []
    for filename in source_names:
        path = member(src, filename)
        raw = path.read_bytes()
        assert b'\r' not in raw and not raw.startswith(b'\xef\xbb\xbf'), 'UTF8 LF/noBOM required'
        text = raw.decode('utf-8')
        if filename == target_index['data_module'] + '.lean':
            assert raw == definitions.read_bytes(), 'Data definition bytes changed: return for review'
            continue
        assert text.count('namespace FVLT.FordBulbV1\n') == 1
        assert text.count('end FVLT.FordBulbV1') == 1
        assert not re.search(r'^\s*@\[', text, re.M), 'Attribute wrappers require review'
        assert not re.search(r'^\s*(?:noncomputable\s+)?(?:def|abbrev|opaque|lemma|structure|inductive|class|instance|example)\b', text, re.M), 'Extra public declaration refused; helpers must be private'
        for match in re.finditer(r'^([ \t]*)theorem\s+(\w+)\b', text, re.M):
            assert not match[1], 'Public theorem commands must start at column zero'
            name = match[2]
            assert name in expected and name not in actual
            t = expected[name]
            assert filename == t['module'] + '.lean'
            tail = text[match.start():]
            assert ' := by' in tail, 'Canonical reviewed public proof separator required'
            header = tail.split(' := by', 1)[0].strip()
            assert header == t['header'], 'Frozen public header changed: ' + name
            actual.append(name)
    return ['FVLT.FordBulbV1.' + n for n in actual]

'''
code=code.replace('\ndef main():',helper+'\ndef main():',1)
needle="    target_index = read(targetpath)\n"
code=code.replace(needle,needle+"    definitions = member(ROOT, template['definitions_file'])\n    assert sha(definitions) == template['definitions_sha256']\n    assert sha(member(ROOT, template['headers_file'])) == template['headers_sha256']\n",1)
needle="    closure = project_import_closure(src, job['source_sha256'])\n"
code=code.replace(needle,"    actual_targets = frozen_source_check(src, job['source_sha256'], target_index, definitions)\n    assert read(comparison)['present_targets'] == actual_targets\n"+needle,1)
code=code.replace("project_import_closure=closure, child_PATH=env['PATH'])","project_import_closure=closure, frozen_public_targets=actual_targets, child_PATH=env['PATH'])",1)
ast.parse(code)
text(p/'RUN_FF4_v0_1.py',code)
(p/'inputs/harness_predecessor').mkdir(parents=True,exist_ok=True)
shutil.copyfile(prior,p/'inputs/harness_predecessor/RUN_FF3_v0_1.py')
text(p/'RUNNER_DIFF_v0_1.patch',''.join(difflib.unified_diff(original.splitlines(True),code.splitlines(True),fromfile='accepted-FF3-v22-643fef34',tofile='proposed-FF4-v23')))
checker=parent/'phasor_ford_map_v0_1_20261103/freeze_packet_v0_1/IndependentFVLTReplay435.lean'
assert sha(checker)=='9c6f2ac11b50fdb846df2d5099ea673553903275a5dba11fce5a5673cae14bd0'
shutil.copyfile(checker,p/checker.name)
expected={'SHA256SUMS':'394e72c5ce5010349779fd41b1490c4672f160f72aa779b732df272086317903','LIBRARY_MANIFEST.json':'3b8ea55068d2c92c6e70cbafe9c6ee55698b34912b791c99ce0fa2df4bedc3f5','lake-manifest.json':'1f0e0c1c0a06e2a9ecc117aed82f7a8ee62b418235e10686d3bda2d6986ea527','lakefile.toml':'23b3055199e230fe224c888dbb87533e69896ffa4e44ad8cb7662639c72c440b','lean-toolchain':'ca5f1f601d34c49079e38d7e7041eb0f2a9c227fbc1df0f404820069a052330c'}
for n,h in expected.items():assert sha(p/'inputs/library_metadata'/n)==h
base=json.loads((parent/'phasor_ford_map_v0_1_20261103/rebind_v22_v0_1/JOB_TEMPLATE_v0_1.json').read_text())
base.update(schema='ff4-job-template/1',status='PROPOSED_AWAITING_FF4_INPUT_SIGNATURE_TEMPLATE_RUNNER_REVIEW',phase='FF4_COMBINATORIAL',root='/home/saphir/fvlt_formalization_20261104/ff4_v01',library='/home/saphir/rule30_theorem_library/v23',library_expected=expected,runner='RUN_FF4_v0_1.py',runner_sha256=sha(p/'RUN_FF4_v0_1.py'),definitions_file='FF4_DEFINITIONS_PROPOSED_v0_1.lean.txt',definitions_sha256=sha(p/'FF4_DEFINITIONS_PROPOSED_v0_1.lean.txt'),headers_file='FF4_HEADERS_PROPOSED_v0_1.lean.txt',headers_sha256=sha(p/'FF4_HEADERS_PROPOSED_v0_1.lean.txt'),target_index_sha256=sha(p/'TARGET_INDEX_v0_1.json'),module_order=mods)
base['comparison_required_fields'].append('present_targets')
base['imported_local_sources']='Every imported new source is staged and pinned; inherited project sources traverse readonly v23; Mathlib/Lean standard imports trusted as pinned library dependencies'
base['signature_enforcement']='Runner byte-checks full data source; compares each public header to pinned target index; extra public declarations/attribute wrappers refused; proof helpers private; all new sources UTF8LFnoBOM'
base['excluded']=['G1','Neo mathematical computation','Wolfram restart','B6 uniqueness','parameter-ray landing','complex-plane wakes/limb geometry','attracting-cycle dynamics','MLC/hyperbolicity/renormalization','Rule30 claims','viewer edits','kernel adoption','library writes/publication','commits','hosted submission']
save(p/'JOB_TEMPLATE_v0_1.json',base)
save(p/'INPUT_OBSERVATION_v0_1.json',{'observed_unix':1793795683,'host':'nucleus','transport':'Tailscale [ts-redacted1]','latest_library':'v23','checksum_entries':401,'checksum_failures':0,'writable_files':0,'library_expected':expected,'lean_executable_sha256':base['lean_executable_sha256'],'mathlib_rev':base['mathlib_rev'],'lean_invoked':False,'Sage_invoked':False,'scope':'Read-only input verification, not execution capacity or host reservation'})
closure={}
for f in sorted((p/'inputs/library_sources').glob('*.lean')):
 imports=[]
 for line in f.read_text(encoding='utf-8').splitlines():
  if line.startswith('import '):imports.extend(line.split('--',1)[0].split()[1:])
 assert not any('g1' in x.lower() for x in imports)
 closure[f.name]={'sha256':sha(f),'imports':imports,'role':'ACTUAL_INHERITED_IMPORT'}
assert set(closure)=={'FVLTFareyArithmeticCompletionV1.lean','FVLTFareyCertificatesV1.lean','FVLTFareyContactV1.lean'}
save(p/'INPUT_LIBRARY_SOURCE_CLOSURE_v0_1.json',closure)
copy={
 'WORK_ORDER_v0_1.md':root/'WORK_ORDER_v0_1.md','WORK_ORDER_v0_2.md':root/'WORK_ORDER_v0_2.md',
 'SAGE_EVIDENCE_v0_1.md':root/'SAGE_EVIDENCE_v0_1.md','SAGE_EVIDENCE_v0_2.md':root/'SAGE_EVIDENCE_v0_2.md',
 'C1_PROOF_ROUTE_NOTE_v0_1.md':root/'C1_PROOF_ROUTE_NOTE_v0_1.md',
 'OWNER_REVIEW_v0_1.md':root/'owner_review_v0_1/REVIEW_v0_1.md','OWNER_C1_PROOF_ROUTE_v0_1.md':root/'owner_review_v0_1/C1_PROOF_ROUTE_v0_1.md','OWNER_ACCEPTANCE_v0_2.md':root/'owner_review_v0_1/ACCEPTANCE_v0_2.md',
 'FF3_FINAL_AUDIT_v0_1.md':parent/'phasor_ford_map_v0_1_20261103/FF3_FINAL_AUDIT_v0_1.md',
 'LIBRARY_V23_READINESS_RECEIPT.md':parent/'phasor_ford_map_v0_1_20261103/library_sync_v0_1/LIBRARY_V23_READINESS_RECEIPT.md'}
for n,f in copy.items():shutil.copyfile(f,p/'inputs'/n)
save(p/'REFERENCE_PINS_v0_1.json',{n:sha(f) for n,f in copy.items()})
shutil.copyfile(Path(__file__),p/Path(__file__).name)
print(json.dumps({'status':'PREPARATION_ONLY_NOT_LEAN_ELABORATION','data_declarations':len(data_names),'public_targets':len(targets),'target_modules':{m:sum(t['module']==m for t in targets) for m in mods},'runner_sha256':sha(p/'RUN_FF4_v0_1.py'),'definitions_sha256':sha(p/'FF4_DEFINITIONS_PROPOSED_v0_1.lean.txt'),'headers_sha256':sha(p/'FF4_HEADERS_PROPOSED_v0_1.lean.txt'),'template_sha256':sha(p/'JOB_TEMPLATE_v0_1.json')},indent=2))
