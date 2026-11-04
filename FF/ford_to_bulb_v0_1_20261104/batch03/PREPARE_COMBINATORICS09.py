from pathlib import Path
import json,hashlib,shutil
p=Path(__file__).resolve().parent;sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def write(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;write(f,json.dumps(o,indent=2)+'\n');return sha(f)
src=p/'attempts/Combinatorics09/src';src.mkdir(parents=True);(src.parent/'build').mkdir()
shutil.copyfile(p/'attempts/Combinatorics08/src/FVLTFordBulbDataV1.lean',src/'FVLTFordBulbDataV1.lean')
s=(p/'attempts/Combinatorics08/src/FVLTFordBulbCombinatoricsV1.lean').read_text(encoding='utf-8').split('end FVLT.FordBulbV1')[0]
idx=json.loads((p.parent/'freeze_packet_v0_1/TARGET_INDEX_v0_1.json').read_text());t=next(t for t in idx['targets'] if t['name'].endswith('.double_word'))
s+=(p/'DOUBLE_WORD_HELPERS_v0_1.lean.txt').read_text(encoding='utf-8')+'\n'+t['header']+''' := by
  have hq : 0 < d.q := Nat.lt_trans d.p_pos d.p_lt_q
  let v : Fin d.q := ⟨(u.val + d.p) % d.q, Nat.mod_lt _ hq⟩
  have hpre := block_prepend d.p d.q u.val d.q
  have hrec := binary_block_rec d.p d.q u.val d.q
  rw [raw_digit_period] at hrec
  have hv := block_phase_mod d.p d.q (u.val + d.p) d.q
  change blockValue d.p d.q v.val d.q = blockValue d.p d.q (u.val + d.p) d.q at hv
  have hb := word_bounds d v
  change 0 < blockValue d.p d.q v.val d.q ∧
    blockValue d.p d.q v.val d.q < modulus d at hb
  have hpow : (2 : ℕ) ^ d.q = modulus d + 1 := by
    have hp := modulus_pos d
    unfold modulus at *
    omega
  rw [hpow] at hpre
  have he : 2 * blockValue d.p d.q u.val d.q =
      rawDigit d.p d.q u.val 0 * modulus d + blockValue d.p d.q (u.val + d.p) d.q := by
    nlinarith
  change (2 * blockValue d.p d.q u.val d.q) % modulus d = blockValue d.p d.q v.val d.q
  rw [he, ← hv]
  simp [Nat.add_mod, Nat.mod_eq_of_lt hb.2]

end FVLT.FordBulbV1
''';write(src/'FVLTFordBulbCombinatoricsV1.lean',s)
c=json.loads((p/'COMPARE_COMBINATORICS08.json').read_text());names=c['present_targets']+[t['name']]
write(src.parent/'AuditFVLTFordBulbCombinatoricsV1.lean','import FVLTFordBulbCombinatoricsV1\n'+''.join('#print axioms '+n+'\n' for n in names))
ch=save('CAPACITY_BATCH03_COMBINATORICS09.json',{'observed_unix':1793824483,'available_kib':28959840,'host':'nucleus','transport':'Tailscale [ts-redacted1]','owner':'01a18167-41de-74e0-882e-9171e642530f'})
b=json.loads((p/'BOUND_BATCH03_COMBINATORICS07.json').read_text());b.update(fresh_capacity_receipt_file='CAPACITY_BATCH03_COMBINATORICS09.json',fresh_capacity_receipt_sha256=ch);bh=save('BOUND_BATCH03_COMBINATORICS09.json',b)
c.update(source_sha256={f.name:sha(f) for f in sorted(src.glob('*.lean'))},present_targets=names,axiom_report_targets=names,method='Seventeen predecessor public proofs preserved; unchanged frozen double_word header; four private prepend/modularphase helpers; Data fullbytes unchanged; runner recomputes');co=save('COMPARE_COMBINATORICS09.json',c)
j=json.loads((p/'JOB_CompileFVLTFordBulbCombinatoricsV1Batch03Combinatorics08.json').read_text());j.update(run_id='CompileFVLTFordBulbCombinatoricsV1Batch03Combinatorics09',attempt_folder='attempts/Batch03Combinatorics09',template_sha256=bh,source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_COMBINATORICS09.json',signature_comparison_receipt_sha256=co);jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_COMBINATORICS09.json');r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r.update(bound_template_file='BOUND_BATCH03_COMBINATORICS09.json',bound_template_sha256=bh,accepted_job_sha256=[jh]);save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'bound':bh,'capacity':ch,'job':jh,'comparison':co,'source':sha(src/'FVLTFordBulbCombinatoricsV1.lean')},indent=2))
