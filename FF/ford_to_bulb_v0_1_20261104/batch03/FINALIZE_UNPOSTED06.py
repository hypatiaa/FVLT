from pathlib import Path
import json,hashlib
p=Path(__file__).resolve().parent;sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def save(n,o):
 f=p/n;f.write_text(json.dumps(o,indent=2)+'\n',encoding='utf-8',newline='\n');return sha(f)
f=p/'attempts/Combinatorics06/src/FVLTFordBulbCombinatoricsV1.lean';s=f.read_text(encoding='utf-8');assert s.count('rw [← hn, ← heq]')==1
f.write_text(s.replace('rw [← hn, ← heq]','rw [hn, ← heq]'),encoding='utf-8',newline='\n')
c=json.loads((p/'COMPARE_COMBINATORICS06.json').read_text());c['source_sha256'][f.name]=sha(f);co=save('COMPARE_COMBINATORICS06.json',c)
j=json.loads((p/'JOB_CompileFVLTFordBulbCombinatoricsV1Batch03Combinatorics06.json').read_text());j.update(source_sha256=c['source_sha256'],signature_comparison_receipt_sha256=co);jh=save('JOB_CompileFVLTFordBulbCombinatoricsV1Batch03Combinatorics06.json',j)
r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r['accepted_job_sha256']=[jh];save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'job':jh,'comparison':co,'source':sha(f)},indent=2))
