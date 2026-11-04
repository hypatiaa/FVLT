from pathlib import Path
import json,hashlib,shutil
p=Path(__file__).resolve().parent;sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def write(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;write(f,json.dumps(o,indent=2)+'\n');return sha(f)
src=p/'attempts/Combinatorics18/src';src.mkdir(parents=True);(src.parent/'build').mkdir()
shutil.copyfile(p/'attempts/Combinatorics17/src/FVLTFordBulbDataV1.lean',src/'FVLTFordBulbDataV1.lean')
s=(p/'attempts/Combinatorics17/src/FVLTFordBulbCombinatoricsV1.lean').read_text(encoding='utf-8')
a='  unfold edgeEnd\n  split_ifs with h\n  · exact ordered_word_at d ⟨i.val + 1, h⟩\n  · exact False.elim (h hi)'
b='  unfold edgeEnd\n  rw [dif_pos hi]\n  exact ordered_word_at d ⟨i.val + 1, hi⟩'
assert s.count(a)==1;s=s.replace(a,b)
a='  unfold edgeEnd\n  split_ifs with h\n  · exact False.elim (hi h)\n  · exact ordered_word_at d ⟨0, by have := i.isLt; omega⟩'
b='  unfold edgeEnd\n  rw [dif_neg hi]\n  exact ordered_word_at d ⟨0, by have := i.isLt; omega⟩'
assert s.count(a)==1;s=s.replace(a,b);write(src/'FVLTFordBulbCombinatoricsV1.lean',s)
shutil.copyfile(p/'attempts/Combinatorics17/AuditFVLTFordBulbCombinatoricsV1.lean',src.parent/'AuditFVLTFordBulbCombinatoricsV1.lean')
c=json.loads((p/'COMPARE_COMBINATORICS17.json').read_text());c.update(source_sha256={f.name:sha(f) for f in sorted(src.glob('*.lean'))},method='Proof-only endpoint helpers replace eager split_ifs with explicit dif_pos/dif_neg; failed17preserved; all26publicproofsheaders/fullData/imports unchanged');co=save('COMPARE_COMBINATORICS18.json',c)
j=json.loads((p/'JOB_CompileFVLTFordBulbCombinatoricsV1Batch05Combinatorics17.json').read_text());j.update(run_id='CompileFVLTFordBulbCombinatoricsV1Batch05Combinatorics18',attempt_folder='attempts/Batch05Combinatorics18',source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_COMBINATORICS18.json',signature_comparison_receipt_sha256=co);jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_COMBINATORICS18.json');r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r.update(accepted_job_sha256=[jh]);save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'job':jh,'comparison':co,'source':sha(src/'FVLTFordBulbCombinatoricsV1.lean')},indent=2))
