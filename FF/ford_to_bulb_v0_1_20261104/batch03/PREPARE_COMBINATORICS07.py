from pathlib import Path
import json,hashlib,shutil
p=Path(__file__).resolve().parent;sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def write(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;write(f,json.dumps(o,indent=2)+'\n');return sha(f)
src=p/'attempts/Combinatorics07/src';src.mkdir(parents=True);(src.parent/'build').mkdir()
shutil.copyfile(p/'attempts/Combinatorics06/src/FVLTFordBulbDataV1.lean',src/'FVLTFordBulbDataV1.lean')
s=(p/'attempts/Combinatorics06/src/FVLTFordBulbCombinatoricsV1.lean').read_text(encoding='utf-8').split('end FVLT.FordBulbV1')[0]
s=s.replace('import FVLTFordBulbDataV1\n','import FVLTFordBulbDataV1\nimport Mathlib.Data.Nat.ModEq\n')
idx=json.loads((p.parent/'freeze_packet_v0_1/TARGET_INDEX_v0_1.json').read_text());t=next(t for t in idx['targets'] if t['name'].endswith('.word_strict'))
s+=(p/'WORD_ORDER_HELPERS_v0_1.lean.txt').read_text(encoding='utf-8')+'\n'+t['header']+''' := by
  intro u v huv
  have hv : u.val < v.val := huv
  have hq : 0 < d.q := Nat.lt_trans d.p_pos d.p_lt_q
  have hle := phase_block_monotone d u v (Nat.le_of_lt hv) d.q
  change blockValue d.p d.q u.val d.q < blockValue d.p d.q v.val d.q
  by_contra hnot
  have he : blockValue d.p d.q u.val d.q = blockValue d.p d.q v.val d.q := by omega
  have hr : d.q - v.val < d.q := by have := v.isLt; omega
  obtain ⟨n, hn⟩ := coprime_phase_surjective d (d.q - v.val) hr
  have hp := binary_prefix_equal d.p d.q u.val v.val d.q n.val (Nat.le_of_lt n.isLt) he
  have hc := binary_equal_count d.p d.q u.val v.val n.val hp
  rw [raw_digit_prefix_count d u, raw_digit_prefix_count d v] at hc
  have hucond : ¬ d.q ≤ u.val + (d.q - v.val) := by have := v.isLt; omega
  have hvcond : d.q ≤ v.val + (d.q - v.val) := by have := v.isLt; omega
  have hdiv : (u.val + n.val * d.p) / d.q < (v.val + n.val * d.p) / d.q := by
    simp only [Nat.add_div hq, Nat.div_eq_of_lt u.isLt, Nat.div_eq_of_lt v.isLt,
      Nat.mod_eq_of_lt u.isLt, Nat.mod_eq_of_lt v.isLt, hn,
      if_neg hucond, if_pos hvcond]
    omega
  omega

end FVLT.FordBulbV1
''';write(src/'FVLTFordBulbCombinatoricsV1.lean',s)
c=json.loads((p/'COMPARE_COMBINATORICS06.json').read_text());names=c['present_targets']+[t['name']]
write(src.parent/'AuditFVLTFordBulbCombinatoricsV1.lean','import FVLTFordBulbCombinatoricsV1\n'+''.join('#print axioms '+n+'\n' for n in names))
ch=save('CAPACITY_BATCH03_COMBINATORICS07.json',{'observed_unix':1793824127,'available_kib':28831976,'host':'nucleus','transport':'Tailscale [ts-redacted1]','owner':'01a18167-41de-74e0-882e-9171e642530f'})
b=json.loads((p/'BOUND_BATCH03.json').read_text());b.update(fresh_capacity_receipt_file='CAPACITY_BATCH03_COMBINATORICS07.json',fresh_capacity_receipt_sha256=ch);bh=save('BOUND_BATCH03_COMBINATORICS07.json',b)
c.update(source_sha256={f.name:sha(f) for f in sorted(src.glob('*.lean'))},present_targets=names,axiom_report_targets=names,method='Sixteen predecessor public proofs preserved; one additional unchanged frozen header; five private word-order helpers; proof-only ModEq import; Data fullbytes unchanged; runner recomputes');co=save('COMPARE_COMBINATORICS07.json',c)
j=json.loads((p/'JOB_CompileFVLTFordBulbCombinatoricsV1Batch03Combinatorics06.json').read_text());j.update(run_id='CompileFVLTFordBulbCombinatoricsV1Batch03Combinatorics07',attempt_folder='attempts/Batch03Combinatorics07',template_sha256=bh,source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_COMBINATORICS07.json',signature_comparison_receipt_sha256=co);jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_COMBINATORICS07.json');r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r.update(bound_template_file='BOUND_BATCH03_COMBINATORICS07.json',bound_template_sha256=bh,accepted_job_sha256=[jh]);save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'bound':bh,'capacity':ch,'job':jh,'comparison':co,'source':sha(src/'FVLTFordBulbCombinatoricsV1.lean')},indent=2))
