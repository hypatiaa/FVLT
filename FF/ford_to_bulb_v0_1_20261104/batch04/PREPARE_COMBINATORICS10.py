from pathlib import Path
import json,hashlib,shutil
p=Path(__file__).resolve().parent;root=p.parent;old=root/'batch03';sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def write(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;write(f,json.dumps(o,indent=2)+'\n');return sha(f)
src=p/'attempts/Combinatorics10/src';src.mkdir(parents=True);(src.parent/'build').mkdir()
shutil.copyfile(old/'attempts/Combinatorics09/src/FVLTFordBulbDataV1.lean',src/'FVLTFordBulbDataV1.lean')
s=(old/'attempts/Combinatorics09/src/FVLTFordBulbCombinatoricsV1.lean').read_text(encoding='utf-8').split('end FVLT.FordBulbV1')[0]
idx=json.loads((root/'freeze_packet_v0_1/TARGET_INDEX_v0_1.json').read_text());ts={t['name'].split('.')[-1]:t for t in idx['targets']}
s+=(p/'ORBIT_HELPERS_v0_1.lean.txt').read_text(encoding='utf-8')+'\n'
proofs={
'characteristic_period_minimal':'''by
  rcases hn with rfl | rfl
  · exact no_short_word_period d (lowerIndex d) k hk0 hkq
  · exact no_short_word_period d (upperIndex d) k hk0 hkq
''',
'same_cycle':'''by
  obtain ⟨i, hi⟩ := coprime_shift_surjective d d.p (d.p - 1) (lowerIndex d).isLt
  refine ⟨i, ?_⟩
  change iterateNum d (wordValue d (upperIndex d)) i.val = wordValue d (lowerIndex d)
  rw [phase_iteration]
  apply congrArg (wordValue d)
  exact Fin.ext hi
''',
'orbit_set_eq':'''by
  ext n
  constructor
  · intro hn
    obtain ⟨k, hk, rfl⟩ := Finset.mem_image.mp hn
    let v : Fin d.q := ⟨(d.p + k * d.p) % d.q, Nat.mod_lt _ (Nat.lt_trans d.p_pos d.p_lt_q)⟩
    apply Finset.mem_image.mpr
    refine ⟨v, Finset.mem_univ _, ?_⟩
    exact (phase_iteration d (upperIndex d) k).symm
  · intro hn
    obtain ⟨v, hv, rfl⟩ := Finset.mem_image.mp hn
    obtain ⟨k, hk⟩ := coprime_shift_surjective d d.p v.val v.isLt
    apply Finset.mem_image.mpr
    refine ⟨k.val, Finset.mem_range.mpr k.isLt, ?_⟩
    change iterateNum d (wordValue d (upperIndex d)) k.val = wordValue d v
    rw [phase_iteration]
    apply congrArg (wordValue d)
    exact Fin.ext hk
''',
'orbit_card':'''by
  rw [orbit_set_eq, Finset.card_image_of_injective _ (word_strict d).injective]
  simp
''',
'orbit_length':'''by
  simp [orderedOrbit, Finset.length_sort, orbit_card]
'''}
for n,pr in proofs.items():s+=ts[n]['header']+' := '+pr+'\n'
s+='end FVLT.FordBulbV1\n';write(src/'FVLTFordBulbCombinatoricsV1.lean',s)
c=json.loads((old/'COMPARE_COMBINATORICS09.json').read_text());names=c['present_targets']+[ts[n]['name'] for n in proofs]
write(src.parent/'AuditFVLTFordBulbCombinatoricsV1.lean','import FVLTFordBulbCombinatoricsV1\n'+''.join('#print axioms '+n+'\n' for n in names))
rh=save('HOST_RESERVATION_BATCH04.json',{'host':'nucleus','owner':'01a18167-41de-74e0-882e-9171e642530f','transport':'Tailscale 100.105.106.41','cpu_jobs':1,'address_space_bytes':8589934592,'start_unix':1793824929,'end_unix':1793826729,'other_owned_builds':False})
ch=save('CAPACITY_BATCH04.json',{'observed_unix':1793824929,'available_kib':28959752,'host':'nucleus','transport':'Tailscale 100.105.106.41','owner':'01a18167-41de-74e0-882e-9171e642530f','latest_library':23,'full_checks':401,'checksum_failures':0,'writable_files':0})
b=json.loads((old/'BOUND_BATCH03_COMBINATORICS09.json').read_text());b.update(host_reservation_reference='HOST_RESERVATION_BATCH04.json SHA'+rh,fresh_capacity_receipt_file='CAPACITY_BATCH04.json',fresh_capacity_receipt_sha256=ch);bh=save('BOUND_BATCH04.json',b)
c.update(source_sha256={f.name:sha(f) for f in sorted(src.glob('*.lean'))},present_targets=names,axiom_report_targets=names,method='Eighteen predecessor public proofs retained; five additional unchanged frozen headers; four private iteration/orbithelpers; fullData unchanged; runner recomputes');co=save('COMPARE_COMBINATORICS10.json',c)
j=json.loads((old/'JOB_CompileFVLTFordBulbCombinatoricsV1Batch03Combinatorics09.json').read_text());j.update(run_id='CompileFVLTFordBulbCombinatoricsV1Batch04Combinatorics10',attempt_folder='attempts/Batch04Combinatorics10',template_sha256=bh,source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_COMBINATORICS10.json',signature_comparison_receipt_sha256=co,deadline_file='DEADLINE_BATCH04.json');jh=save('JOB_'+j['run_id']+'.json',j)
r=json.loads((old/'REVIEW_ACCEPTANCE.json').read_text());r.update(bound_template_file='BOUND_BATCH04.json',bound_template_sha256=bh,accepted_job_sha256=[jh]);r['reviewed_files'].update({n:sha(p/n) for n in ['HOST_RESERVATION_BATCH04.json','DEADLINE_BATCH04.json']});save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'bound':bh,'capacity':ch,'reservation':rh,'job':jh,'comparison':co,'source':sha(src/'FVLTFordBulbCombinatoricsV1.lean')},indent=2))
