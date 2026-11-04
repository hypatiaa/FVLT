from pathlib import Path
import json,hashlib,shutil
p=Path(__file__).resolve().parent;sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def save(n,o):
 f=p/n;f.write_text(json.dumps(o,indent=2)+'\n',encoding='utf-8',newline='\n');return sha(f)
src=p/'attempts/Combinatorics01/src';src.mkdir(parents=True);(src.parent/'build').mkdir()
shutil.copyfile(p/'attempts/Data01/src/FVLTFordBulbDataV1.lean',src/'FVLTFordBulbDataV1.lean')
proofs={
'address_canonical':'''by
  simpa [address, FVLT.FareyContactV1.rawValue] using
    FVLT.FareyContactV1.rawValue_canonical (d.p : ℤ) d.q
      (Nat.lt_trans d.p_pos d.p_lt_q) (by simpa using d.coprime)
''',
'address_interval':'''by
  have hp : (0 : ℚ) < d.p := by exact_mod_cast d.p_pos
  have hq : (0 : ℚ) < d.q := by exact_mod_cast Nat.lt_trans d.p_pos d.p_lt_q
  have hpq : (d.p : ℚ) < d.q := by exact_mod_cast d.p_lt_q
  exact ⟨div_pos hp hq, (div_lt_one hq).mpr hpq⟩
''',
'address_injective':'''by
  have hp : d.p = e.p := by
    have hi : (d.p : ℤ) = e.p := by
      rw [← (address_canonical d).1, ← (address_canonical e).1, h]
    exact_mod_cast hi
  have hq : d.q = e.q := by
    rw [← (address_canonical d).2, ← (address_canonical e).2, h]
  cases d
  cases e
  cases hp
  cases hq
  rfl
''',
'q_at_least_two':'''by
  have := d.p_pos
  have := d.p_lt_q
  omega
''',
'modulus_pos':'''by
  have hq := q_at_least_two d
  have hp : 1 < (2 : ℕ) ^ d.q := one_lt_pow₀ (by decide) (by omega)
  unfold modulus
  omega
''',
'upper_digit_equiv':'''by
  have heq : d.p + i.val * d.p = (i.val + 1) * d.p := by ring
  change (if d.q - d.p ≤ (d.p + i.val * d.p) % d.q then 1 else 0) = _
  rw [heq]
''',
'lower_digit_equiv':'''by
  have hp : 0 < (i.val + 1) * d.p := Nat.mul_pos (by omega) d.p_pos
  have heq : d.p - 1 + i.val * d.p = (i.val + 1) * d.p - 1 := by
    rw [Nat.add_mul]
    simp only [one_mul]
    have := d.p_pos
    omega
  constructor
  · omega
  · change (if d.q - d.p ≤ (d.p - 1 + i.val * d.p) % d.q then 1 else 0) = _
    rw [heq]
'''}
idx=json.loads((p.parent/'freeze_packet_v0_1/TARGET_INDEX_v0_1.json').read_text())
ts=[t for t in idx['targets'] if t['name'].split('.')[-1] in proofs]
assert len(ts)==7
s='import FVLTFordBulbDataV1\nopen scoped BigOperators\nnamespace FVLT.FordBulbV1\n\n'+''.join(t['header']+' := '+proofs[t['name'].split('.')[-1]]+'\n' for t in ts)+'end FVLT.FordBulbV1\n'
(src/'FVLTFordBulbCombinatoricsV1.lean').write_text(s,encoding='utf-8',newline='\n')
names=[t['name'] for t in ts]
(src.parent/'AuditFVLTFordBulbCombinatoricsV1.lean').write_text('import FVLTFordBulbCombinatoricsV1\n'+''.join('#print axioms '+n+'\n' for n in names),encoding='utf-8',newline='\n')
ch=save('CAPACITY_BATCH01_COMBINATORICS01.json',{'observed_unix':1793820887,'available_kib':28980196,'host':'nucleus','transport':'Tailscale 100.105.106.41','owner':'01a18167-41de-74e0-882e-9171e642530f'})
b=json.loads((p/'BOUND_BATCH01_PARAMETER02.json').read_text());b.update(fresh_capacity_receipt_file='CAPACITY_BATCH01_COMBINATORICS01.json',fresh_capacity_receipt_sha256=ch);bh=save('BOUND_BATCH01_COMBINATORICS01.json',b)
c=json.loads((p/'COMPARE_PARAMETER02.json').read_text());c.update(source_sha256={f.name:sha(f) for f in sorted(src.glob('*.lean'))},present_targets=names,axiom_report_targets=names,method='Seven frozen headers copied unchanged from accepted target index; full frozen Data unchanged; runner checks actual inventory/importclosure');co=save('COMPARE_COMBINATORICS01.json',c)
j=json.loads((p/'JOB_CompileFVLTFordBulbParameterV1Batch01Parameter02.json').read_text());j.update(module='FVLTFordBulbCombinatoricsV1',run_id='CompileFVLTFordBulbCombinatoricsV1Batch01Combinatorics01',attempt_folder='attempts/Batch01Combinatorics01',template_sha256=bh,source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_COMBINATORICS01.json',signature_comparison_receipt_sha256=co);jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_COMBINATORICS01.json');r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r.update(bound_template_file='BOUND_BATCH01_COMBINATORICS01.json',bound_template_sha256=bh,accepted_job_sha256=[jh]);save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'bound':bh,'capacity':ch,'job':jh,'comparison':co,'source':sha(src/'FVLTFordBulbCombinatoricsV1.lean')},indent=2))
