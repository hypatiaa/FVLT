from pathlib import Path
import json,hashlib,shutil
p=Path(__file__).resolve().parent;sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def write(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;write(f,json.dumps(o,indent=2)+'\n');return sha(f)
src=p/'attempts/Combinatorics21/src';src.mkdir(parents=True);(src.parent/'build').mkdir()
shutil.copyfile(p/'attempts/Combinatorics20/src/FVLTFordBulbDataV1.lean',src/'FVLTFordBulbDataV1.lean')
s=(p/'attempts/Combinatorics20/src/FVLTFordBulbCombinatoricsV1.lean').read_text(encoding='utf-8').split('end FVLT.FordBulbV1')[0]
idx=json.loads((p.parent/'freeze_packet_v0_1/TARGET_INDEX_v0_1.json').read_text());ts={t['name'].split('.')[-1]:t for t in idx['targets']}
proofs={
'angle_order':'''by
  let L := d.q * e.q
  let R : ℚ := (2 : ℚ) ^ L - 1
  have hqd : 0 < d.q := Nat.lt_trans d.p_pos d.p_lt_q
  have hqe : 0 < e.q := Nat.lt_trans e.p_pos e.p_lt_q
  have hL : 0 < L := Nat.mul_pos hqd hqe
  have hR : 0 < R := by
    have hp : (1 : ℚ) < (2 : ℚ) ^ L := one_lt_pow₀ (by norm_num) (Nat.ne_of_gt hL)
    dsimp [R]
    linarith
  have hMd : (0 : ℚ) < (modulus d : ℚ) := by exact_mod_cast modulus_pos d
  have hMe : (0 : ℚ) < (modulus e : ℚ) := by exact_mod_cast modulus_pos e
  have hd := repetition_cross d (upperIndex d) e.q
  simp only [Nat.mul_comm e.q d.q] at hd
  change (blockValue d.p d.q d.p L : ℚ) * (modulus d : ℚ) =
    (upperNumerator d : ℚ) * R at hd
  have he := repetition_cross e (lowerIndex e) d.q
  change (blockValue e.p e.q (e.p - 1) L : ℚ) * (modulus e : ℚ) =
    (lowerNumerator e : ℚ) * R at he
  have hfd : (blockValue d.p d.q d.p L : ℚ) / R = upperAngle d := by
    unfold upperAngle
    exact (div_eq_div_iff hR.ne' hMd.ne').2 hd
  have hfe : (blockValue e.p e.q (e.p - 1) L : ℚ) / R = lowerAngle e := by
    unfold lowerAngle
    exact (div_eq_div_iff hR.ne' hMe.ne').2 he
  have hb : (blockValue d.p d.q d.p L : ℚ) < (blockValue e.p e.q (e.p - 1) L : ℚ) := by
    exact_mod_cast ordered_common_blocks d e h
  have hz := div_lt_div_of_pos_right hb hR
  rw [hfd, hfe] at hz
  exact hz
''',
'intervals_disjoint':'''by
  apply Set.disjoint_left.mpr
  intro x hx hy
  exact (not_le_of_gt (angle_order d e h)) (le_trans hy.1 hx.2)
''',
'mediant_interval':'''by
  have ha := FVLT.FareyContactV1.adjacent_mediant (address d) (address e) h hadj
  have hl := ha.2.2.2.1
  have hr := ha.2.2.2.2.1
  have h0 : 0 < FVLT.FareyContactV1.mediant (address d) (address e) :=
    lt_trans (address_interval d).1 hl
  have h1 : FVLT.FareyContactV1.mediant (address d) (address e) < 1 :=
    lt_trans hr (address_interval e).2
  obtain ⟨m, hm⟩ := address_surjective _ h0 h1
  refine ⟨m, hm, ?_, ?_⟩
  · apply angle_order
    rw [hm]
    exact hl
  · apply angle_order
    rw [hm]
    exact hr
'''}
for n,pr in proofs.items():s+=ts[n]['header']+' := '+pr+'\n'
s+='end FVLT.FordBulbV1\n';write(src/'FVLTFordBulbCombinatoricsV1.lean',s)
c=json.loads((p/'COMPARE_COMBINATORICS20.json').read_text());names=c['present_targets']+[ts[n]['name'] for n in proofs]
write(src.parent/'AuditFVLTFordBulbCombinatoricsV1.lean','import FVLTFordBulbCombinatoricsV1\n'+''.join('#print axioms '+n+'\n' for n in names))
ch=save('CAPACITY_BATCH06_COMBINATORICS21.json',{'observed_unix':1793827611,'available_kib':28969320,'host':'nucleus','transport':'Tailscale [ts-redacted1]','owner':'01a18167-41de-74e0-882e-9171e642530f'})
b=json.loads((p/'BOUND_BATCH06.json').read_text());b.update(fresh_capacity_receipt_file='CAPACITY_BATCH06_COMBINATORICS21.json',fresh_capacity_receipt_sha256=ch);bh=save('BOUND_BATCH06_COMBINATORICS21.json',b)
c.update(source_sha256={f.name:sha(f) for f in sorted(src.glob('*.lean'))},present_targets=names,axiom_report_targets=names,method='Twenty-six predecessor public proofs preserved; final3frozenheaders fullangle_order/disjointness/mediant; all29Combheaders exact; helpercheckpointrecompiled; fullData/imports unchanged; runner recomputes');co=save('COMPARE_COMBINATORICS21.json',c)
j=json.loads((p/'JOB_CompileFVLTFordBulbCombinatoricsV1Batch06Combinatorics20.json').read_text());j.update(run_id='CompileFVLTFordBulbCombinatoricsV1Batch06Combinatorics21',attempt_folder='attempts/Batch06Combinatorics21',template_sha256=bh,source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_COMBINATORICS21.json',signature_comparison_receipt_sha256=co);jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_COMBINATORICS21.json');r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r.update(bound_template_file='BOUND_BATCH06_COMBINATORICS21.json',bound_template_sha256=bh,accepted_job_sha256=[jh]);save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'bound':bh,'capacity':ch,'job':jh,'comparison':co,'source':sha(src/'FVLTFordBulbCombinatoricsV1.lean')},indent=2))
