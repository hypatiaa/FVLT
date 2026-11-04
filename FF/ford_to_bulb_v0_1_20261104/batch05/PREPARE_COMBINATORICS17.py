from pathlib import Path
import json,hashlib,shutil
p=Path(__file__).resolve().parent;sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def write(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;write(f,json.dumps(o,indent=2)+'\n');return sha(f)
src=p/'attempts/Combinatorics17/src';src.mkdir(parents=True);(src.parent/'build').mkdir()
shutil.copyfile(p/'attempts/Combinatorics16/src/FVLTFordBulbDataV1.lean',src/'FVLTFordBulbDataV1.lean')
s=(p/'attempts/Combinatorics16/src/FVLTFordBulbCombinatoricsV1.lean').read_text(encoding='utf-8').split('end FVLT.FordBulbV1')[0]
s=s.replace('convert hv.symm using 1 <;> congr 1 <;> apply Subsingleton.elim','convert hv.symm using 1')
idx=json.loads((p.parent/'freeze_packet_v0_1/TARGET_INDEX_v0_1.json').read_text());t=next(t for t in idx['targets'] if t['name'].endswith('.unique_unit_gap'))
s+=(p/'GAP_EDGE_HELPERS_v0_1.lean.txt').read_text(encoding='utf-8')+'\n'+t['header']+' := '+(p/'UNIQUE_GAP_PROOF_v0_1.lean.txt').read_text(encoding='utf-8')+'\nend FVLT.FordBulbV1\n';write(src/'FVLTFordBulbCombinatoricsV1.lean',s)
c=json.loads((p/'COMPARE_COMBINATORICS16.json').read_text());names=c['present_targets']+[t['name']]
write(src.parent/'AuditFVLTFordBulbCombinatoricsV1.lean','import FVLTFordBulbCombinatoricsV1\n'+''.join('#print axioms '+n+'\n' for n in names))
ch=save('CAPACITY_BATCH05_COMBINATORICS17.json',{'observed_unix':1793826541,'available_kib':28961684,'host':'nucleus','transport':'Tailscale 100.105.106.41','owner':'01a18167-41de-74e0-882e-9171e642530f'})
b=json.loads((p/'BOUND_BATCH05_COMBINATORICS15.json').read_text());b.update(fresh_capacity_receipt_file='CAPACITY_BATCH05_COMBINATORICS17.json',fresh_capacity_receipt_sha256=ch);bh=save('BOUND_BATCH05_COMBINATORICS17.json',b)
c.update(source_sha256={f.name:sha(f) for f in sorted(src.glob('*.lean'))},present_targets=names,axiom_report_targets=names,method='Twenty-five prior public proofs/headers preserved; frozen unique_unit_gap added; three private edge helpers; unused private tactic suffix trimmed as C16 linter indicated; fullData/imports unchanged; runner recomputes');co=save('COMPARE_COMBINATORICS17.json',c)
j=json.loads((p/'JOB_CompileFVLTFordBulbCombinatoricsV1Batch05Combinatorics16.json').read_text());j.update(run_id='CompileFVLTFordBulbCombinatoricsV1Batch05Combinatorics17',attempt_folder='attempts/Batch05Combinatorics17',template_sha256=bh,source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_COMBINATORICS17.json',signature_comparison_receipt_sha256=co);jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_COMBINATORICS17.json');r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r.update(bound_template_file='BOUND_BATCH05_COMBINATORICS17.json',bound_template_sha256=bh,accepted_job_sha256=[jh]);save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'bound':bh,'capacity':ch,'job':jh,'comparison':co,'source':sha(src/'FVLTFordBulbCombinatoricsV1.lean')},indent=2))
