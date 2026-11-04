from pathlib import Path
import json,hashlib,shutil
p=Path(__file__).resolve().parent;root=p.parent;old=root/'batch01';sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def write(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;write(f,json.dumps(o,indent=2)+'\n');return sha(f)
src=p/'attempts/Combinatorics02/src';src.mkdir(parents=True);(src.parent/'build').mkdir()
shutil.copyfile(old/'attempts/Data01/src/FVLTFordBulbDataV1.lean',src/'FVLTFordBulbDataV1.lean')
s=(old/'attempts/Combinatorics01/src/FVLTFordBulbCombinatoricsV1.lean').read_text(encoding='utf-8').split('end FVLT.FordBulbV1')[0]
idx=json.loads((root/'freeze_packet_v0_1/TARGET_INDEX_v0_1.json').read_text())
ts={t['name'].split('.')[-1]:t for t in idx['targets']}
proofs={
'address_surjective':'''by
  have hd : (0 : ℚ) < x.den := by exact_mod_cast x.den_pos
  have he : (x.num : ℚ) = x * (x.den : ℚ) :=
    (div_eq_iff hd.ne').mp (Rat.num_div_den x)
  have hnq : (0 : ℚ) < (x.num : ℚ) := by rw [he]; positivity
  have hnz : (0 : ℤ) ≤ x.num := by exact_mod_cast hnq.le
  have hnm : (x.num.natAbs : ℤ) = x.num := by
    rw [Int.natCast_natAbs, abs_of_nonneg hnz]
  have hmq : (x.num.natAbs : ℚ) = (x.num : ℚ) := by
    simpa only [Int.cast_natCast] using congrArg (fun z : ℤ => (z : ℚ)) hnm
  have hp : 0 < x.num.natAbs := by
    have hh : (0 : ℚ) < x.num.natAbs := by rw [hmq]; exact hnq
    exact_mod_cast hh
  have hpq : x.num.natAbs < x.den := by
    have hh : (x.num.natAbs : ℚ) < x.den := by
      rw [hmq, he]
      simpa using mul_lt_mul_of_pos_right hx1 hd
    exact_mod_cast hh
  refine ⟨⟨x.num.natAbs, x.den, hp, hpq, x.reduced⟩, ?_⟩
  change (x.num.natAbs : ℚ) / (x.den : ℚ) = x
  rw [hmq]
  exact Rat.num_div_den x
''',
'word_sum':'''by
  unfold wordValue blockValue
  symm
  apply Finset.sum_bij (fun (i : Fin d.q) _ => i.val)
  · intro i hi
    exact Finset.mem_range.mpr i.isLt
  · intro i hi j hj hij
    exact Fin.ext hij
  · intro b hb
    exact ⟨⟨b, Finset.mem_range.mp hb⟩, Finset.mem_univ _, rfl⟩
  · intro i hi
    rfl
'''}
for name,proof in proofs.items():s+=ts[name]['header']+' := '+proof+'\n'
s+='end FVLT.FordBulbV1\n';write(src/'FVLTFordBulbCombinatoricsV1.lean',s)
names=json.loads((old/'COMPARE_COMBINATORICS01.json').read_text())['present_targets']+[ts[n]['name'] for n in proofs]
write(src.parent/'AuditFVLTFordBulbCombinatoricsV1.lean','import FVLTFordBulbCombinatoricsV1\n'+''.join('#print axioms '+n+'\n' for n in names))
rh=save('HOST_RESERVATION_BATCH02.json',{'host':'nucleus','owner':'01a18167-41de-74e0-882e-9171e642530f','transport':'Tailscale [ts-redacted1]','cpu_jobs':1,'address_space_bytes':8589934592,'start_unix':1793822057,'end_unix':1793823857,'other_owned_builds':False})
ch=save('CAPACITY_BATCH02.json',{'observed_unix':1793822057,'available_kib':28979548,'load':[0,.07,.04],'host':'nucleus','transport':'Tailscale [ts-redacted1]','owner':'01a18167-41de-74e0-882e-9171e642530f','latest_library':23,'full_checks':401,'checksum_failures':0,'writable_files':0})
b=json.loads((old/'BOUND_BATCH01_COMBINATORICS01.json').read_text());b.update(host_reservation_reference='HOST_RESERVATION_BATCH02.json SHA'+rh,fresh_capacity_receipt_file='CAPACITY_BATCH02.json',fresh_capacity_receipt_sha256=ch);bh=save('BOUND_BATCH02.json',b)
c=json.loads((old/'COMPARE_COMBINATORICS01.json').read_text());c.update(source_sha256={f.name:sha(f) for f in sorted(src.glob('*.lean'))},present_targets=names,axiom_report_targets=names,method='Seven predecessor public proofs retained byte-identical; two additional frozen headers copied unchanged; full Data unchanged; runner recomputes source inventory and imports');co=save('COMPARE_COMBINATORICS02.json',c)
j=json.loads((old/'JOB_CompileFVLTFordBulbCombinatoricsV1Batch01Combinatorics01.json').read_text());j.update(run_id='CompileFVLTFordBulbCombinatoricsV1Batch02Combinatorics02',attempt_folder='attempts/Batch02Combinatorics02',template_sha256=bh,source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_COMBINATORICS02.json',signature_comparison_receipt_sha256=co,deadline_file='DEADLINE_BATCH02.json');jh=save('JOB_'+j['run_id']+'.json',j)
r=json.loads((old/'REVIEW_ACCEPTANCE.json').read_text());r.update(bound_template_file='BOUND_BATCH02.json',bound_template_sha256=bh,accepted_job_sha256=[jh]);r['reviewed_files'].update({n:sha(p/n) for n in ['HOST_RESERVATION_BATCH02.json','DEADLINE_BATCH02.json']});save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'bound':bh,'capacity':ch,'reservation':rh,'job':jh,'comparison':co,'source':sha(src/'FVLTFordBulbCombinatoricsV1.lean')},indent=2))
