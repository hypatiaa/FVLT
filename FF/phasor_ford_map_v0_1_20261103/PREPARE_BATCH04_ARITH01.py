from pathlib import Path
import json,hashlib,re,shutil
root=Path(__file__).resolve().parent;p=root/'batch04';p.mkdir(exist_ok=False)
src=p/'attempts/Arithmetic01/src';src.mkdir(parents=True);(src.parent/'build').mkdir()
sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def text(f,s): f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;text(f,json.dumps(o,indent=2)+'\n');return sha(f)
shutil.copyfile(root/'batch02/attempts/Data02/src/FVLTRosetteFordDataV1.lean',src/'FVLTRosetteFordDataV1.lean')
h=(root/'freeze_packet_v0_1/FF3_HEADERS_PROPOSED_v0_1.lean.txt').read_text(encoding='utf-8')
section=h.split('-- FVLTRosetteFordArithmeticV1:')[1].split('-- FVLTRosetteFordSweepV1:')[0]
items=list(re.finditer(r'^theorem\s+(\w+)',section,re.M))
proofs=[r'''by
  simpa [fordAddress, Int.cast_mul] using
    Rat.den_div_intCast_eq_one_iff (t2 * s) (n3 : ℤ)
      (by exact_mod_cast (Nat.ne_of_gt hn3))
''',r'''by
  constructor
  · rintro ⟨k, hk⟩
    apply (integer_address_iff t2 s n3 hn3).mp
    rw [hk]
    simp
  · intro hd
    refine ⟨(fordAddress t2 (s : ℚ) n3).num, ?_⟩
    exact ((Rat.den_eq_one_iff _).mp ((integer_address_iff t2 s n3 hn3).mpr hd)).symm
''',r'''by
  simp [FVLT.FordGeometryV1.radius, (integer_address_iff t2 s n3 hn3).mpr hdiv]
''',r'''by
  ext N
  simp only [integerContactWindow, divisorWindow, Finset.mem_filter,
    Finset.mem_Icc, Finset.mem_inter, Nat.mem_divisors]
  constructor
  · rintro ⟨⟨h1, hM⟩, hd⟩
    have hz : (N : ℤ) ∣ (s : ℤ) := by
      simpa using (integer_address_iff 1 (s : ℤ) N (by omega)).mp hd
    have hdvd : N ∣ s := by exact_mod_cast hz
    exact ⟨⟨hdvd, Nat.ne_of_gt hs⟩, h1, hM⟩
  · rintro ⟨⟨hdvd, _⟩, h1, hM⟩
    refine ⟨⟨h1, hM⟩, (integer_address_iff 1 (s : ℤ) N (by omega)).mpr ?_⟩
    simpa using (show (N : ℤ) ∣ (s : ℤ) by exact_mod_cast hdvd)
''',r'''by
  simp [fordAddress]
''',r'''by
  ext N
  simp [integerContactWindow, fordAddress]
''']
out='import FVLTRosetteFordDataV1\n\nopen FVLT.FareyContactV1 FVLT.FordExactCoordinatesV1\nnamespace FVLT.PhasorFordV1\n\n'
for i,proof in enumerate(proofs):
 out+=section[items[i].start():items[i+1].start()].strip()+' := '+proof+'\n'
out+='end FVLT.PhasorFordV1\n';text(src/'FVLTRosetteFordArithmeticV1.lean',out)
assert b'\r' not in (src/'FVLTRosetteFordArithmeticV1.lean').read_bytes()
names=['FVLT.PhasorFordV1.'+m.group(1) for m in items[:6]]
text(src.parent/'AuditRosetteFordArithmeticV1.lean','import FVLTRosetteFordArithmeticV1\n'+''.join('#print axioms '+n+'\n' for n in names))
save('DEADLINE_BATCH04.json',{'cap_seconds':1800,'origin_unix':1793784377,'deadline_unix':1793786177,'no_reset_or_extension':True,'batch':'FF3 Batch04'})
rh=save('HOST_RESERVATION_BATCH04.json',{'host':'nucleus','owner':'01a18167-41de-74e0-882e-9171e642530f','transport':'Tailscale 100.105.106.41','cpu_jobs':1,'address_space_bytes':8589934592,'start_unix':1793784377,'end_unix':1793786177,'other_owned_builds':False})
ch=save('CAPACITY_BATCH04.json',{'observed_unix':1793784377,'available_mib':28286,'load':[0,.01,0],'host':'nucleus','transport':'Tailscale 100.105.106.41','owner':'01a18167-41de-74e0-882e-9171e642530f'})
b=json.loads((root/'rebind_v22_v0_1/JOB_TEMPLATE_v0_1.json').read_text());b.update(status='BOUND_ACCEPTED',signature_freeze_sha256='6c9d2f7671d233c0ac49c9af4bb887756ecbeaf63e894c4c8c7599346c2b2047',host_reservation_reference='HOST_RESERVATION_BATCH04.json SHA'+rh,fresh_capacity_receipt_file='CAPACITY_BATCH04.json',fresh_capacity_receipt_sha256=ch)
bh=save('BOUND_BATCH04.json',b)
c=json.loads((root/'batch03/COMPARE_PHASE02.json').read_text());c.update(source_sha256={f.name:sha(f) for f in sorted(src.glob('*.lean'))},present_targets=names,axiom_report_targets=names,method='Data byte-exact accepted successor; first six frozen arithmetic headers copied verbatim LF; no extra public declarations; UTF8/noBOM/LF source',header_comparison='Six integer-address and zero-case headers match frozen LF text')
co=save('COMPARE_ARITHMETIC01.json',c)
j=json.loads((root/'batch03/JOB_CompileFVLTRosetteFordPhaseV1Batch03Phase02.json').read_text());j.update(module='FVLTRosetteFordArithmeticV1',run_id='CompileFVLTRosetteFordArithmeticV1Batch04Arithmetic01',attempt_folder='attempts/Batch04Arithmetic01',template_sha256=bh,source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_ARITHMETIC01.json',signature_comparison_receipt_sha256=co,deadline_file='DEADLINE_BATCH04.json')
jh=save('JOB_'+j['run_id']+'.json',j)
r=json.loads((root/'batch03/REVIEW_ACCEPTANCE.json').read_text());r.update(bound_template_file='BOUND_BATCH04.json',bound_template_sha256=bh,accepted_job_sha256=[jh]);r['reviewed_files'].update({'DEADLINE_BATCH04.json':sha(p/'DEADLINE_BATCH04.json'),'HOST_RESERVATION_BATCH04.json':rh});save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'bound':bh,'capacity':ch,'reservation':rh,'job':jh,'comparison':co,'sources':c['source_sha256']},indent=2))
