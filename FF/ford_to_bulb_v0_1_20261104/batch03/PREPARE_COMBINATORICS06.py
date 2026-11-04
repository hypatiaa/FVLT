from pathlib import Path
import json,hashlib,shutil
p=Path(__file__).resolve().parent;root=p.parent;old=root/'batch02';sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def write(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;write(f,json.dumps(o,indent=2)+'\n');return sha(f)
src=p/'attempts/Combinatorics06/src';src.mkdir(parents=True);(src.parent/'build').mkdir()
shutil.copyfile(old/'attempts/Combinatorics05/src/FVLTFordBulbDataV1.lean',src/'FVLTFordBulbDataV1.lean')
s=(old/'attempts/Combinatorics05/src/FVLTFordBulbCombinatoricsV1.lean').read_text(encoding='utf-8').split('end FVLT.FordBulbV1')[0]
idx=json.loads((root/'freeze_packet_v0_1/TARGET_INDEX_v0_1.json').read_text());ts={t['name'].split('.')[-1]:t for t in idx['targets']}
s+=(p/'FAREY_FRAME_HELPERS_v0_1.lean.txt').read_text(encoding='utf-8')+'\n'
proofs={
'characteristic_period_return':'''by
  have hpow : (2 : ℕ) ^ d.q = modulus d + 1 := by
    have hp := modulus_pos d
    unfold modulus at *
    omega
  have hbound : n < modulus d := by
    rcases hn with rfl | rfl
    · exact (characteristic_bounds d).2.1.trans (characteristic_bounds d).2.2
    · exact (characteristic_bounds d).2.2
  unfold iterateNum
  rw [hpow]
  simp [Nat.add_mul, Nat.add_mod, Nat.mod_eq_of_lt hbound]
''',
'farey_denominator_min':'''by
  rcases farey_interval_frame x y z hxy hadj hxz hzy with ⟨hA, hB, he, hn⟩
  have hX : (0 : ℤ) < x.den := by exact_mod_cast x.den_pos
  have hY : (0 : ℤ) < y.den := by exact_mod_cast y.den_pos
  have hh := positive_frame_bound _ _ _ _ _ hA hB hX hY he
  exact_mod_cast hh
''',
'farey_denominator_eq_iff':'''by
  constructor
  · intro heq
    rcases farey_interval_frame x y z hxy hadj hxz hzy with ⟨hA, hB, hd, hn⟩
    have hX : (0 : ℤ) < x.den := by exact_mod_cast x.den_pos
    have hY : (0 : ℤ) < y.den := by exact_mod_cast y.den_pos
    have hs : (z.den : ℤ) = (x.den : ℤ) + (y.den : ℤ) := by exact_mod_cast heq
    have hu := positive_frame_unit _ _ _ _ hA hB hX hY (hd.trans hs)
    rw [hu.1, hu.2] at hn
    simp only [one_mul] at hn
    unfold FVLT.FareyContactV1.mediant FVLT.FareyContactV1.rawValue
    rw [← hn, ← heq]
    exact (Rat.num_div_den z).symm
  · intro hz
    rw [hz]
    exact (FVLT.FareyContactV1.adjacent_mediant x y hxy hadj).2.2.1
'''}
for n,pr in proofs.items():s+=ts[n]['header']+' := '+pr+'\n'
s+='end FVLT.FordBulbV1\n';write(src/'FVLTFordBulbCombinatoricsV1.lean',s)
c=json.loads((old/'COMPARE_COMBINATORICS05.json').read_text());names=c['present_targets']+[ts[n]['name'] for n in proofs]
write(src.parent/'AuditFVLTFordBulbCombinatoricsV1.lean','import FVLTFordBulbCombinatoricsV1\n'+''.join('#print axioms '+n+'\n' for n in names))
rh=save('HOST_RESERVATION_BATCH03.json',{'host':'nucleus','owner':'01a18167-41de-74e0-882e-9171e642530f','transport':'Tailscale [ts-redacted1]','cpu_jobs':1,'address_space_bytes':8589934592,'start_unix':1793823650,'end_unix':1793825450,'other_owned_builds':False})
ch=save('CAPACITY_BATCH03.json',{'observed_unix':1793823650,'available_kib':28988136,'host':'nucleus','transport':'Tailscale [ts-redacted1]','owner':'01a18167-41de-74e0-882e-9171e642530f','latest_library':23,'full_checks':401,'checksum_failures':0,'writable_files':0})
b=json.loads((old/'BOUND_BATCH02_COMBINATORICS04.json').read_text());b.update(host_reservation_reference='HOST_RESERVATION_BATCH03.json SHA'+rh,fresh_capacity_receipt_file='CAPACITY_BATCH03.json',fresh_capacity_receipt_sha256=ch);bh=save('BOUND_BATCH03.json',b)
c.update(source_sha256={f.name:sha(f) for f in sorted(src.glob('*.lean'))},present_targets=names,axiom_report_targets=names,method='Thirteen predecessor public proofs retained; three additional unchanged frozen headers; five private Farey frame helpers; fullData unchanged; runner recomputes');co=save('COMPARE_COMBINATORICS06.json',c)
j=json.loads((old/'JOB_CompileFVLTFordBulbCombinatoricsV1Batch02Combinatorics05.json').read_text());j.update(run_id='CompileFVLTFordBulbCombinatoricsV1Batch03Combinatorics06',attempt_folder='attempts/Batch03Combinatorics06',template_sha256=bh,source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_COMBINATORICS06.json',signature_comparison_receipt_sha256=co,deadline_file='DEADLINE_BATCH03.json');jh=save('JOB_'+j['run_id']+'.json',j)
r=json.loads((old/'REVIEW_ACCEPTANCE.json').read_text());r.update(bound_template_file='BOUND_BATCH03.json',bound_template_sha256=bh,accepted_job_sha256=[jh]);r['reviewed_files'].update({n:sha(p/n) for n in ['HOST_RESERVATION_BATCH03.json','DEADLINE_BATCH03.json']});save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'bound':bh,'capacity':ch,'reservation':rh,'job':jh,'comparison':co,'source':sha(src/'FVLTFordBulbCombinatoricsV1.lean')},indent=2))
