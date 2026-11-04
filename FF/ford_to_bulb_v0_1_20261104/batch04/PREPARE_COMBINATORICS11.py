from pathlib import Path
import json,hashlib,shutil
p=Path(__file__).resolve().parent;sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def write(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;write(f,json.dumps(o,indent=2)+'\n');return sha(f)
src=p/'attempts/Combinatorics11/src';src.mkdir(parents=True);(src.parent/'build').mkdir()
shutil.copyfile(p/'attempts/Combinatorics10/src/FVLTFordBulbDataV1.lean',src/'FVLTFordBulbDataV1.lean')
s=(p/'attempts/Combinatorics10/src/FVLTFordBulbCombinatoricsV1.lean').read_text(encoding='utf-8')
a='  simp [iterateNum, doubleNum, pow_succ, Nat.mul_mod, Nat.mul_assoc, Nat.mul_comm,\n    Nat.mul_left_comm]'
b='  unfold iterateNum doubleNum\n  rw [Nat.mul_mod_mod]\n  congr 1\n  rw [pow_succ]\n  ring'
assert s.count(a)==1;s=s.replace(a,b);write(src/'FVLTFordBulbCombinatoricsV1.lean',s)
shutil.copyfile(p/'attempts/Combinatorics10/AuditFVLTFordBulbCombinatoricsV1.lean',src.parent/'AuditFVLTFordBulbCombinatoricsV1.lean')
ch=save('CAPACITY_BATCH04_COMBINATORICS11.json',{'observed_unix':1793825201,'available_kib':28954748,'host':'nucleus','transport':'Tailscale 100.105.106.41','owner':'01a18167-41de-74e0-882e-9171e642530f'})
bnd=json.loads((p/'BOUND_BATCH04.json').read_text());bnd.update(fresh_capacity_receipt_file='CAPACITY_BATCH04_COMBINATORICS11.json',fresh_capacity_receipt_sha256=ch);bh=save('BOUND_BATCH04_COMBINATORICS11.json',bnd)
c=json.loads((p/'COMPARE_COMBINATORICS10.json').read_text());c.update(source_sha256={f.name:sha(f) for f in sorted(src.glob('*.lean'))},method='Proof-only iteration helper repair using exact Nat.mul_mod_mod then ring; all23headers/fullData/imports unchanged; failed10preserved');co=save('COMPARE_COMBINATORICS11.json',c)
j=json.loads((p/'JOB_CompileFVLTFordBulbCombinatoricsV1Batch04Combinatorics10.json').read_text());j.update(run_id='CompileFVLTFordBulbCombinatoricsV1Batch04Combinatorics11',attempt_folder='attempts/Batch04Combinatorics11',template_sha256=bh,source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_COMBINATORICS11.json',signature_comparison_receipt_sha256=co);jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_COMBINATORICS11.json');r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r.update(bound_template_file='BOUND_BATCH04_COMBINATORICS11.json',bound_template_sha256=bh,accepted_job_sha256=[jh]);save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'bound':bh,'capacity':ch,'job':jh,'comparison':co,'source':sha(src/'FVLTFordBulbCombinatoricsV1.lean')},indent=2))
