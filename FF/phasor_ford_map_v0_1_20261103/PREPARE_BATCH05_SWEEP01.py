from pathlib import Path
import json,hashlib,re,shutil
root=Path(__file__).resolve().parent;p=root/'batch05';p.mkdir(exist_ok=True)
src=p/'attempts/Sweep01/src';src.mkdir(parents=True,exist_ok=True);(src.parent/'build').mkdir(exist_ok=True)
sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def text(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;text(f,json.dumps(o,indent=2)+'\n');return sha(f)
shutil.copyfile(root/'batch02/attempts/Data02/src/FVLTRosetteFordDataV1.lean',src/'FVLTRosetteFordDataV1.lean')
shutil.copyfile(root/'batch03/attempts/Phase02/src/FVLTRosetteFordPhaseV1.lean',src/'FVLTRosetteFordPhaseV1.lean')
h=(root/'freeze_packet_v0_1/FF3_HEADERS_PROPOSED_v0_1.lean.txt').read_text(encoding='utf-8');section=h.split('-- FVLTRosetteFordSweepV1:')[1].split('-- FVLTRosetteFordEndpointsV1:')[0]
items=list(re.finditer(r'^theorem\s+(\w+)',section,re.M));selected=[0,1,2,6,7]
proofs=[r'''by
  have hpos : (0 : ℚ) < (N : ℚ) := by exact_mod_cast (show 0 < N by omega)
  have hden : (0 : ℚ) < (N : ℚ) - 1 := by
    have ht : (2 : ℚ) ≤ (N : ℚ) := by exact_mod_cast hN
    linarith
  have hp : phaseAddress 1 1 s N = s * ((N : ℚ) - 1) / (N : ℚ) := by
    unfold phaseAddress fordAddress
    norm_num
    field_simp [hpos.ne']
    <;> ring
  rw [hp]
  constructor
  · rintro ⟨k, hk⟩
    have hk0 : (0 : ℚ) ≤ (k : ℚ) := by
      rw [← hk]
      positivity
    have hkz : (0 : ℤ) ≤ k := by exact_mod_cast hk0
    have hkm : (k.toNat : ℚ) = (k : ℚ) := by
      exact_mod_cast (Int.toNat_of_nonneg hkz)
    have hkle : (k : ℚ) ≤ (N : ℚ) - 1 := by
      rw [← hk]
      apply (div_le_iff₀ hpos).mpr
      nlinarith [hsN]
    refine ⟨k.toNat, ?_, ?_⟩
    · have hle : (k.toNat : ℚ) ≤ ((N - 1 : ℕ) : ℚ) := by
        rw [hkm, Nat.cast_sub (show 1 ≤ N by omega), Nat.cast_one]
        exact hkle
      exact_mod_cast hle
    · apply (eq_div_iff hden.ne').mpr
      rw [hkm]
      have he := (div_eq_iff hpos.ne').mp hk
      nlinarith [he]
  · rintro ⟨m, hm, rfl⟩
    refine ⟨(m : ℤ), ?_⟩
    push_cast
    field_simp [hpos.ne', hden.ne']
    <;> ring
''',r'''by
  rw [phasor_real_iff 1 1 s N (by omega) r hr]
  exact shell_contact_parameterization N hN s hs0 hsN
''',r'''by
  have hn : (N : ℚ) ≠ 0 := by exact_mod_cast (show N ≠ 0 by omega)
  have hd : (N : ℚ) - 1 ≠ 0 := by
    have ht : (2 : ℚ) ≤ (N : ℚ) := by exact_mod_cast hN
    linarith
  unfold fordAddress
  norm_num
  field_simp [hn, hd] <;> ring
''',r'''by
  exact Finset.mem_sort (· ≤ ·)
''',r'''by
  exact Finset.sortedLT_sort (fareySet B)
''']
out='import FVLTRosetteFordPhaseV1\n\nopen FVLT.FareyContactV1 FVLT.FordExactCoordinatesV1\nnamespace FVLT.PhasorFordV1\n\n'
for i,proof in zip(selected,proofs):out+=section[items[i].start():items[i+1].start()].strip()+' := '+proof+'\n'
out+='end FVLT.PhasorFordV1\n';text(src/'FVLTRosetteFordSweepV1.lean',out);assert b'\r' not in (src/'FVLTRosetteFordSweepV1.lean').read_bytes()
names=['FVLT.PhasorFordV1.'+items[i].group(1) for i in selected];text(src.parent/'AuditRosetteFordSweepV1.lean','import FVLTRosetteFordSweepV1\n'+''.join('#print axioms '+n+'\n' for n in names))
save('DEADLINE_BATCH05.json',{'cap_seconds':1800,'origin_unix':1793785576,'deadline_unix':1793787376,'no_reset_or_extension':True,'batch':'FF3 Batch05'})
rh=save('HOST_RESERVATION_BATCH05.json',{'host':'nucleus','owner':'01a18167-41de-74e0-882e-9171e642530f','transport':'Tailscale 100.105.106.41','cpu_jobs':1,'address_space_bytes':8589934592,'start_unix':1793785576,'end_unix':1793787376,'other_owned_builds':False})
ch=save('CAPACITY_BATCH05.json',{'observed_unix':1793785576,'available_mib':28279,'load':[.04,.07,.01],'host':'nucleus','transport':'Tailscale 100.105.106.41','owner':'01a18167-41de-74e0-882e-9171e642530f'})
b=json.loads((root/'rebind_v22_v0_1/JOB_TEMPLATE_v0_1.json').read_text());b.update(status='BOUND_ACCEPTED',signature_freeze_sha256='6c9d2f7671d233c0ac49c9af4bb887756ecbeaf63e894c4c8c7599346c2b2047',host_reservation_reference='HOST_RESERVATION_BATCH05.json SHA'+rh,fresh_capacity_receipt_file='CAPACITY_BATCH05.json',fresh_capacity_receipt_sha256=ch);bh=save('BOUND_BATCH05.json',b)
c=json.loads((root/'batch04/COMPARE_ARITHMETIC03.json').read_text());c.update(source_sha256={f.name:sha(f) for f in sorted(src.glob('*.lean'))},present_targets=names,axiom_report_targets=names,method='Five frozen sweep headers LF unchanged; data byte-exact accepted successor; Phase02 dependency bytes preserved with historical CRLF; new Sweep UTF8LFnoBOM; no extra publics',header_comparison='Five selected frozen sweep statement texts unchanged LF')
co=save('COMPARE_SWEEP01.json',c)
j=json.loads((root/'batch04/JOB_CompileFVLTRosetteFordArithmeticV1Batch04Arithmetic03.json').read_text());j.update(module='FVLTRosetteFordSweepV1',run_id='CompileFVLTRosetteFordSweepV1Batch05Sweep01',attempt_folder='attempts/Batch05Sweep01',template_sha256=bh,source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_SWEEP01.json',signature_comparison_receipt_sha256=co,deadline_file='DEADLINE_BATCH05.json')
j['dependency_olean_sha256']['FVLTRosetteFordPhaseV1.olean']='12055f4be01f0a2f16ccf1edcd57a615046e1bfa0595651ee39242c9d0ddb805'
for name in ['Compile','axioms','replay']:
 fn=name+'FVLTRosetteFordPhaseV1Batch03Phase02.json';j['prerequisite_receipt_sha256'][fn]=sha(root/'batch03'/fn)
jh=save('JOB_'+j['run_id']+'.json',j)
r=json.loads((root/'batch04/REVIEW_ACCEPTANCE.json').read_text());r.update(bound_template_file='BOUND_BATCH05.json',bound_template_sha256=bh,accepted_job_sha256=[jh]);r['reviewed_files'].update({'DEADLINE_BATCH05.json':sha(p/'DEADLINE_BATCH05.json'),'HOST_RESERVATION_BATCH05.json':rh});save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'bound':bh,'capacity':ch,'reservation':rh,'job':jh,'comparison':co,'sources':c['source_sha256']},indent=2))
