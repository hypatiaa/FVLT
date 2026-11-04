from pathlib import Path
import json,hashlib,shutil
p=Path(__file__).resolve().parent;sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def write(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;write(f,json.dumps(o,indent=2)+'\n');return sha(f)
src=p/'attempts/Combinatorics16/src';src.mkdir(parents=True);(src.parent/'build').mkdir()
shutil.copyfile(p/'attempts/Combinatorics15/src/FVLTFordBulbDataV1.lean',src/'FVLTFordBulbDataV1.lean')
s=(p/'attempts/Combinatorics15/src/FVLTFordBulbCombinatoricsV1.lean').read_text(encoding='utf-8')
a='  simpa only [Fin.getElem_fin] using hv.symm';b='  simp only [Fin.getElem_fin] at hv\n  convert hv.symm using 1 <;> congr 1 <;> apply Subsingleton.elim'
assert s.count(a)==1;write(src/'FVLTFordBulbCombinatoricsV1.lean',s.replace(a,b))
shutil.copyfile(p/'attempts/Combinatorics15/AuditFVLTFordBulbCombinatoricsV1.lean',src.parent/'AuditFVLTFordBulbCombinatoricsV1.lean')
c=json.loads((p/'COMPARE_COMBINATORICS15.json').read_text());c.update(source_sha256={f.name:sha(f) for f in sorted(src.glob('*.lean'))},method='Proof-only private getter congruence repair; failed13/14/15preserved; all25publicheaders/proofs/fullData/imports unchanged');co=save('COMPARE_COMBINATORICS16.json',c)
j=json.loads((p/'JOB_CompileFVLTFordBulbCombinatoricsV1Batch05Combinatorics15.json').read_text());j.update(run_id='CompileFVLTFordBulbCombinatoricsV1Batch05Combinatorics16',attempt_folder='attempts/Batch05Combinatorics16',source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_COMBINATORICS16.json',signature_comparison_receipt_sha256=co);jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_COMBINATORICS16.json');r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r.update(accepted_job_sha256=[jh]);save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'job':jh,'comparison':co,'source':sha(src/'FVLTFordBulbCombinatoricsV1.lean')},indent=2))
