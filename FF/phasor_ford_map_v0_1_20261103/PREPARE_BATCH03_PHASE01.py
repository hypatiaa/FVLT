from pathlib import Path
import json,hashlib,re,shutil
root=Path(__file__).resolve().parent
p=root/'batch03';p.mkdir(exist_ok=True)
src=p/'attempts/Phase01/src';src.mkdir(parents=True,exist_ok=True);(src.parent/'build').mkdir(exist_ok=True)
sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def save(n,o):
 f=p/n;f.write_text(json.dumps(o,indent=2)+'\n');return sha(f)
shutil.copyfile(root/'batch02/attempts/Data02/src/FVLTRosetteFordDataV1.lean',src/'FVLTRosetteFordDataV1.lean')
h=(root/'freeze_packet_v0_1/FF3_HEADERS_PROPOSED_v0_1.lean.txt').read_text()
section=h.split('-- FVLTRosetteFordPhaseV1:')[1].split('-- FVLTRosetteFordArithmeticV1:')[0]
items=list(re.finditer(r'^theorem\s+(\w+)',section,re.M))
proofs=[r'''by
  have him : (phasorValue t1 t2 s n3 r).im =
      r * Real.sin (Real.pi * (phaseAddress t1 t2 s n3 : ℝ)) := by
    simp [phasorValue, Complex.mul_im, Complex.exp_im]
  rw [him, mul_eq_zero, or_iff_right hr, Real.sin_eq_zero_iff]
  constructor
  · rintro ⟨n, hn⟩
    refine ⟨n, ?_⟩
    have he : (phaseAddress t1 t2 s n3 : ℝ) = (n : ℝ) := by
      apply mul_left_cancel₀ Real.pi_ne_zero
      nlinarith [hn]
    exact_mod_cast he
  · rintro ⟨n, hn⟩
    refine ⟨n, ?_⟩
    rw [hn]
    push_cast
    ring
''',r'''by
  change (∃ k : ℤ, (t1 : ℚ) * (s : ℚ) - fordAddress t2 (s : ℚ) n3 = (k : ℚ)) ↔
    ∃ k : ℤ, fordAddress t2 (s : ℚ) n3 = (k : ℚ)
  constructor
  · rintro ⟨k, hk⟩
    refine ⟨t1 * s - k, ?_⟩
    push_cast
    linarith
  · rintro ⟨k, hk⟩
    refine ⟨t1 * s - k, ?_⟩
    push_cast
    linarith
''',r'''by
  have he : (((Real.pi * (phaseAddress t1 t2 (s : ℚ) n3 : ℝ)) : ℂ) * Complex.I) =
      ((t1 * s : ℤ) : ℂ) * ((Real.pi : ℂ) * Complex.I) +
        -(((Real.pi * (fordAddress t2 (s : ℚ) n3 : ℝ)) : ℂ) * Complex.I) := by
    simp only [phaseAddress]
    push_cast
    ring
  rw [he, Complex.exp_add, Complex.exp_int_mul, Complex.exp_pi_mul_I]
''',r'''by
  simp only [circleMap, ht2, hs, hn3]
''',r'''by
  have h0 : phaseAddress 1 1 0 3 = 0 := by norm_num [phaseAddress, fordAddress]
  have h3 : phaseAddress 1 1 3 3 = 2 := by norm_num [phaseAddress, fordAddress]
  have he : Complex.exp (((Real.pi * ((2 : ℚ) : ℝ)) : ℂ) * Complex.I) = 1 := by
    convert Complex.exp_int_mul_two_pi_mul_I (1 : ℤ) using 1 <;> norm_num <;> ring
  constructor
  · simp only [phasorValue, h0, h3]
    rw [he]
    simp
  · norm_num [fordAddress]
''']
assert len(items)==len(proofs)==5
out='import FVLTRosetteFordDataV1\n\nopen FVLT.FareyContactV1 FVLT.FordExactCoordinatesV1\nnamespace FVLT.PhasorFordV1\n\n'
for i,m in enumerate(items):
 end=items[i+1].start() if i+1<len(items) else len(section)
 out+=section[m.start():end].strip()+' := '+proofs[i]+'\n'
out+='end FVLT.PhasorFordV1\n'
(src/'FVLTRosetteFordPhaseV1.lean').write_text(out)
names=['FVLT.PhasorFordV1.'+m.group(1) for m in items]
(src.parent/'AuditRosetteFordPhaseV1.lean').write_text('import FVLTRosetteFordPhaseV1\n'+''.join('#print axioms '+n+'\n' for n in names))
save('DEADLINE_BATCH03.json',{'cap_seconds':1800,'origin_unix':1793783796,'deadline_unix':1793785596,'no_reset_or_extension':True,'batch':'FF3 Batch03'})
rh=save('HOST_RESERVATION_BATCH03.json',{'host':'nucleus','owner':'01a18167-41de-74e0-882e-9171e642530f','transport':'Tailscale [ts-redacted1]','cpu_jobs':1,'address_space_bytes':8589934592,'start_unix':1793783796,'end_unix':1793785596,'other_owned_builds':False})
ch=save('CAPACITY_BATCH03.json',{'observed_unix':1793783796,'available_mib':28245,'load':[0,.02,0],'host':'nucleus','transport':'Tailscale [ts-redacted1]','owner':'01a18167-41de-74e0-882e-9171e642530f'})
b=json.loads((root/'rebind_v22_v0_1/JOB_TEMPLATE_v0_1.json').read_text())
b.update(status='BOUND_ACCEPTED',signature_freeze_sha256='6c9d2f7671d233c0ac49c9af4bb887756ecbeaf63e894c4c8c7599346c2b2047',host_reservation_reference='HOST_RESERVATION_BATCH03.json SHA'+rh,fresh_capacity_receipt_file='CAPACITY_BATCH03.json',fresh_capacity_receipt_sha256=ch)
bh=save('BOUND_BATCH03.json',b)
c=json.loads((root/'batch02/COMPARE_ENDPOINTS02.json').read_text());c.update(source_sha256={f.name:sha(f) for f in sorted(src.glob('*.lean'))},present_targets=names,axiom_report_targets=names,method='Data exact accepted successor; five phase public headers copied verbatim from frozen phase section; bodies appended; no additional public declarations',header_comparison='Five frozen phase headers unchanged')
co=save('COMPARE_PHASE01.json',c)
j=json.loads((root/'batch02/JOB_CompileFVLTRosetteFordEndpointsV1Batch02Endpoints02.json').read_text())
j.update(module='FVLTRosetteFordPhaseV1',run_id='CompileFVLTRosetteFordPhaseV1Batch03Phase01',attempt_folder='attempts/Batch03Phase01',template_sha256=bh,source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_PHASE01.json',signature_comparison_receipt_sha256=co,deadline_file='DEADLINE_BATCH03.json')
jh=save('JOB_'+j['run_id']+'.json',j)
r=json.loads((root/'batch02/REVIEW_ACCEPTANCE.json').read_text());r.update(bound_template_file='BOUND_BATCH03.json',bound_template_sha256=bh,accepted_job_sha256=[jh])
r['reviewed_files'].update({'DEADLINE_BATCH03.json':sha(p/'DEADLINE_BATCH03.json'),'HOST_RESERVATION_BATCH03.json':rh})
save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'bound':bh,'capacity':ch,'reservation':rh,'job':jh,'comparison':co,'source':c['source_sha256']},indent=2))
