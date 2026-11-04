from pathlib import Path
import json,hashlib,shutil
p=Path(__file__).resolve().parent;sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def write(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;write(f,json.dumps(o,indent=2)+'\n');return sha(f)
src=p/'attempts/Combinatorics15/src';src.mkdir(parents=True);(src.parent/'build').mkdir()
shutil.copyfile(p/'attempts/Combinatorics14/src/FVLTFordBulbDataV1.lean',src/'FVLTFordBulbDataV1.lean')
s=(p/'attempts/Combinatorics14/src/FVLTFordBulbCombinatoricsV1.lean').read_text(encoding='utf-8')
a='  simpa only [orderedOrbit, List.get_eq_getElem, Fin.getElem_fin] using hv.symm'
b="  change ((orbitSet d).sort (fun a b : ℕ => a ≤ b))[i.val]'i.isLt = _\n  simpa only [Fin.getElem_fin] using hv.symm"
assert s.count(a)==1;write(src/'FVLTFordBulbCombinatoricsV1.lean',s.replace(a,b))
shutil.copyfile(p/'attempts/Combinatorics14/AuditFVLTFordBulbCombinatoricsV1.lean',src.parent/'AuditFVLTFordBulbCombinatoricsV1.lean')
ch=save('CAPACITY_BATCH05_COMBINATORICS15.json',{'observed_unix':1793826203,'available_kib':28962716,'host':'nucleus','transport':'Tailscale 100.105.106.41','owner':'01a18167-41de-74e0-882e-9171e642530f'})
bnd=json.loads((p/'BOUND_BATCH05.json').read_text());bnd.update(fresh_capacity_receipt_file='CAPACITY_BATCH05_COMBINATORICS15.json',fresh_capacity_receipt_sha256=ch);bh=save('BOUND_BATCH05_COMBINATORICS15.json',bnd)
c=json.loads((p/'COMPARE_COMBINATORICS14.json').read_text());c.update(source_sha256={f.name:sha(f) for f in sorted(src.glob('*.lean'))},method='Proof-only private indexing repair: change goal explicitly from List.get to Nat getElem; failed13/14preserved; all25publicheaders/proofs/fullData/imports unchanged');co=save('COMPARE_COMBINATORICS15.json',c)
j=json.loads((p/'JOB_CompileFVLTFordBulbCombinatoricsV1Batch05Combinatorics14.json').read_text());j.update(run_id='CompileFVLTFordBulbCombinatoricsV1Batch05Combinatorics15',attempt_folder='attempts/Batch05Combinatorics15',template_sha256=bh,source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_COMBINATORICS15.json',signature_comparison_receipt_sha256=co);jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_COMBINATORICS15.json');r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r.update(bound_template_file='BOUND_BATCH05_COMBINATORICS15.json',bound_template_sha256=bh,accepted_job_sha256=[jh]);save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'bound':bh,'capacity':ch,'job':jh,'comparison':co,'source':sha(src/'FVLTFordBulbCombinatoricsV1.lean')},indent=2))
