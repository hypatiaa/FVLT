from pathlib import Path
import json,hashlib,shutil
p=Path(__file__).resolve().parent;sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def write(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;write(f,json.dumps(o,indent=2)+'\n');return sha(f)
src=p/'attempts/Combinatorics20/src';src.mkdir(parents=True);(src.parent/'build').mkdir()
shutil.copyfile(p/'attempts/Combinatorics19/src/FVLTFordBulbDataV1.lean',src/'FVLTFordBulbDataV1.lean')
s=(p/'attempts/Combinatorics19/src/FVLTFordBulbCombinatoricsV1.lean').read_text(encoding='utf-8')
a='  rw [raw_digit_prefix_count d (upperIndex d), raw_digit_prefix_count e (lowerIndex e)]'
b='''  have hd := raw_digit_prefix_count d (upperIndex d) n
  have he := raw_digit_prefix_count e (lowerIndex e) n
  change (∑ i ∈ Finset.range n, rawDigit d.p d.q d.p i) = (d.p + n * d.p) / d.q at hd
  change (∑ i ∈ Finset.range n, rawDigit e.p e.q (e.p - 1) i) =
    (e.p - 1 + n * e.p) / e.q at he
  rw [hd, he]'''
assert s.count(a)==1;s=s.replace(a,b)
a='  push_cast\n\nprivate theorem repetition_cross';b='  push_cast\n  rfl\n\nprivate theorem repetition_cross'
assert s.count(a)==1;s=s.replace(a,b);write(src/'FVLTFordBulbCombinatoricsV1.lean',s)
shutil.copyfile(p/'attempts/Combinatorics19/AuditFVLTFordBulbCombinatoricsV1.lean',src.parent/'AuditFVLTFordBulbCombinatoricsV1.lean')
c=json.loads((p/'COMPARE_COMBINATORICS19.json').read_text());c.update(source_sha256={f.name:sha(f) for f in sorted(src.glob('*.lean'))},method='Proof-only two private syntax repairs: explicit phaseprojection count equalities and final reflexivity after cast normalization; failed19preserved; all26publicproofsheaders/fullData/imports unchanged');co=save('COMPARE_COMBINATORICS20.json',c)
j=json.loads((p/'JOB_CompileFVLTFordBulbCombinatoricsV1Batch06Combinatorics19.json').read_text());j.update(run_id='CompileFVLTFordBulbCombinatoricsV1Batch06Combinatorics20',attempt_folder='attempts/Batch06Combinatorics20',source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_COMBINATORICS20.json',signature_comparison_receipt_sha256=co);jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_COMBINATORICS20.json');r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r.update(accepted_job_sha256=[jh]);save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'job':jh,'comparison':co,'source':sha(src/'FVLTFordBulbCombinatoricsV1.lean')},indent=2))
