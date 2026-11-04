from pathlib import Path
import json,hashlib,shutil
p=Path(__file__).resolve().parent;sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def write(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;write(f,json.dumps(o,indent=2)+'\n');return sha(f)
src=p/'attempts/Combinatorics04/src';src.mkdir(parents=True);(src.parent/'build').mkdir()
shutil.copyfile(p/'attempts/Combinatorics03/src/FVLTFordBulbDataV1.lean',src/'FVLTFordBulbDataV1.lean')
s=(p/'attempts/Combinatorics03/src/FVLTFordBulbCombinatoricsV1.lean').read_text(encoding='utf-8').split('end FVLT.FordBulbV1')[0]
idx=json.loads((p.parent/'freeze_packet_v0_1/TARGET_INDEX_v0_1.json').read_text());ts={t['name'].split('.')[-1]:t for t in idx['targets']}
s+=(p/'ADJACENCY_HELPERS_v0_1.lean.txt').read_text(encoding='utf-8')+'\n'
proofs={
'characteristic_adjacent':'''by
  have hq := q_at_least_two d
  have h1 : d.q - 2 + 1 = d.q - 1 := by omega
  have h2 : d.q - 1 + 1 = d.q := by omega
  have he := characteristic_early_block_equal d (d.q - 2) (by omega)
  rcases characteristic_final_digits d with ⟨hu2, hl2, hu1, hl1⟩
  have ru2 := binary_block_rec d.p d.q d.p (d.q - 2)
  have rl2 := binary_block_rec d.p d.q (d.p - 1) (d.q - 2)
  have ru1 := binary_block_rec d.p d.q d.p (d.q - 1)
  have rl1 := binary_block_rec d.p d.q (d.p - 1) (d.q - 1)
  rw [h1, hu2] at ru2
  rw [h1, hl2] at rl2
  rw [h2, hu1] at ru1
  rw [h2, hl1] at rl1
  change blockValue d.p d.q d.p d.q = blockValue d.p d.q (d.p - 1) d.q + 1
  omega
''',
'characteristic_bounds':'''by
  have hl := word_bounds d (lowerIndex d)
  have hu := word_bounds d (upperIndex d)
  have he := characteristic_adjacent d
  change 0 < lowerNumerator d ∧ lowerNumerator d < modulus d at hl
  change 0 < upperNumerator d ∧ upperNumerator d < modulus d at hu
  omega
''',
'characteristic_angle_gap':'''by
  unfold upperAngle lowerAngle
  rw [characteristic_adjacent]
  push_cast
  ring
'''}
for n,pr in proofs.items():s+=ts[n]['header']+' := '+pr+'\n'
s+='end FVLT.FordBulbV1\n';write(src/'FVLTFordBulbCombinatoricsV1.lean',s)
c=json.loads((p/'COMPARE_COMBINATORICS03.json').read_text());names=c['present_targets']+[ts[n]['name'] for n in proofs]
write(src.parent/'AuditFVLTFordBulbCombinatoricsV1.lean','import FVLTFordBulbCombinatoricsV1\n'+''.join('#print axioms '+n+'\n' for n in names))
ch=save('CAPACITY_BATCH02_COMBINATORICS04.json',{'observed_unix':1793822792,'available_kib':28952704,'host':'nucleus','transport':'Tailscale [ts-redacted1]','owner':'01a18167-41de-74e0-882e-9171e642530f'})
b=json.loads((p/'BOUND_BATCH02_COMBINATORICS03.json').read_text());b.update(fresh_capacity_receipt_file='CAPACITY_BATCH02_COMBINATORICS04.json',fresh_capacity_receipt_sha256=ch);bh=save('BOUND_BATCH02_COMBINATORICS04.json',b)
c.update(source_sha256={f.name:sha(f) for f in sorted(src.glob('*.lean'))},present_targets=names,axiom_report_targets=names,method='Ten predecessor public proofs preserved; three additional unchanged frozen headers; five new private adjacency helpers; fullData unchanged; runner recomputes');co=save('COMPARE_COMBINATORICS04.json',c)
j=json.loads((p/'JOB_CompileFVLTFordBulbCombinatoricsV1Batch02Combinatorics03.json').read_text());j.update(run_id='CompileFVLTFordBulbCombinatoricsV1Batch02Combinatorics04',attempt_folder='attempts/Batch02Combinatorics04',template_sha256=bh,source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_COMBINATORICS04.json',signature_comparison_receipt_sha256=co);jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_COMBINATORICS04.json');r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r.update(bound_template_file='BOUND_BATCH02_COMBINATORICS04.json',bound_template_sha256=bh,accepted_job_sha256=[jh]);save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'bound':bh,'capacity':ch,'job':jh,'comparison':co,'source':sha(src/'FVLTFordBulbCombinatoricsV1.lean')},indent=2))
