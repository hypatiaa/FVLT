from pathlib import Path
import json,hashlib,re,shutil
root=Path(__file__).resolve().parent;p=root/'batch06';p.mkdir(exist_ok=False)
src=p/'attempts/Final01/src';shutil.copytree(root/'batch05/attempts/Sweep04/src',src);(src.parent/'build').mkdir()
sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def text(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;text(f,json.dumps(o,indent=2)+'\n');return sha(f)
f=src/'FVLTRosetteFordSweepV1.lean';s=f.read_text(encoding='utf-8').split('end FVLT.PhasorFordV1')[0]
s=s.replace('import FVLTRosetteFordPhaseV1\n','import FVLTRosetteFordPhaseV1\nimport Mathlib.Data.Int.GCD\n',1)
s+=r'''
private theorem bounded_bezout (a b B : ℕ) (hb : 0 < b) (hbB : b ≤ B)
    (hcop : Nat.Coprime a b) :
    ∃ c d : ℤ, 0 < d ∧ d ≤ (B : ℤ) ∧ (B : ℤ) < (b : ℤ) + d ∧
      (b : ℤ) * c - (a : ℤ) * d = 1 := by
  let c0 := Nat.gcdB a b
  let d0 := -Nat.gcdA a b
  let k := ((B : ℤ) - d0) / (b : ℤ)
  let c := c0 + (a : ℤ) * k
  let d := d0 + (b : ℤ) * k
  have hbez : (b : ℤ) * c0 - (a : ℤ) * d0 = 1 := by
    have he := Nat.gcd_eq_gcd_ab a b
    rw [hcop.gcd_eq_one] at he
    dsimp [c0, d0]
    nlinarith [he]
  have hbz : (0 : ℤ) < (b : ℤ) := by exact_mod_cast hb
  have hBz : (b : ℤ) ≤ (B : ℤ) := by exact_mod_cast hbB
  have hr0 := Int.emod_nonneg ((B : ℤ) - d0) hbz.ne'
  have hrlt := Int.emod_lt_of_pos ((B : ℤ) - d0) hbz
  have hdiv := Int.mul_ediv_add_emod ((B : ℤ) - d0) (b : ℤ)
  have hdpos : 0 < d := by dsimp [d, k]; nlinarith [hdiv, hr0, hrlt]
  have hdB : d ≤ (B : ℤ) := by dsimp [d, k]; nlinarith [hdiv, hr0]
  have hlarge : (B : ℤ) < (b : ℤ) + d := by dsimp [d, k]; nlinarith [hdiv, hrlt]
  refine ⟨c, d, hdpos, hdB, hlarge, ?_⟩
  calc
    (b : ℤ) * c - (a : ℤ) * d = (b : ℤ) * c0 - (a : ℤ) * d0 := by dsimp [c, d]; ring
    _ = 1 := hbez

private theorem interval_denominator_bound (x y z : ℚ)
    (hdet : (x.den : ℤ) * y.num - x.num * (y.den : ℤ) = 1)
    (hxz : x < z) (hzy : z < y) : x.den + y.den ≤ z.den := by
  have hxp : (0 : ℚ) < (x.den : ℚ) := by exact_mod_cast x.den_pos
  have hyp : (0 : ℚ) < (y.den : ℚ) := by exact_mod_cast y.den_pos
  have hzp : (0 : ℚ) < (z.den : ℚ) := by exact_mod_cast z.den_pos
  have hlq : (x.num : ℚ) * (z.den : ℚ) < (z.num : ℚ) * (x.den : ℚ) := by
    apply (div_lt_div_iff₀ hxp hzp).mp
    simpa only [Rat.num_div_den] using hxz
  have hrq : (z.num : ℚ) * (y.den : ℚ) < (y.num : ℚ) * (z.den : ℚ) := by
    apply (div_lt_div_iff₀ hzp hyp).mp
    simpa only [Rat.num_div_den] using hzy
  have hl : (1 : ℤ) ≤ z.num * (x.den : ℤ) - x.num * (z.den : ℤ) := by
    have hh : x.num * (z.den : ℤ) < z.num * (x.den : ℤ) := by exact_mod_cast hlq
    omega
  have hr : (1 : ℤ) ≤ y.num * (z.den : ℤ) - z.num * (y.den : ℤ) := by
    have hh : z.num * (y.den : ℤ) < y.num * (z.den : ℤ) := by exact_mod_cast hrq
    omega
  have he : (y.num * (z.den : ℤ) - z.num * (y.den : ℤ)) * (x.den : ℤ) +
      (z.num * (x.den : ℤ) - x.num * (z.den : ℤ)) * (y.den : ℤ) = (z.den : ℤ) := by
    calc
      _ = (z.den : ℤ) * ((x.den : ℤ) * y.num - x.num * (y.den : ℤ)) := by ring
      _ = (z.den : ℤ) := by rw [hdet, mul_one]
  have h1 := mul_le_mul_of_nonneg_right hr (show (0 : ℤ) ≤ (x.den : ℤ) by positivity)
  have h2 := mul_le_mul_of_nonneg_right hl (show (0 : ℤ) ≤ (y.den : ℤ) by positivity)
  have hh : (x.den : ℤ) + (y.den : ℤ) ≤ (z.den : ℤ) := by nlinarith [he, h1, h2]
  exact_mod_cast hh

end FVLT.PhasorFordV1
''';text(f,s);assert b'\r' not in f.read_bytes()
names=['FVLT.PhasorFordV1.'+m.group(1) for m in re.finditer(r'^theorem\s+(\w+)',s,re.M)];assert len(names)==8
text(src.parent/'AuditRosetteFordSweepV1.lean','import FVLTRosetteFordSweepV1\n'+''.join('#print axioms '+n+'\n' for n in names))
save('DEADLINE_BATCH06.json',{'cap_seconds':1800,'origin_unix':1793786877,'deadline_unix':1793788677,'no_reset_or_extension':True,'batch':'FF3 Batch06'})
rh=save('HOST_RESERVATION_BATCH06.json',{'host':'nucleus','owner':'01a18167-41de-74e0-882e-9171e642530f','transport':'Tailscale [ts-redacted1]','cpu_jobs':1,'address_space_bytes':8589934592,'start_unix':1793786877,'end_unix':1793788677,'other_owned_builds':False})
ch=save('CAPACITY_BATCH06.json',{'observed_unix':1793786877,'available_mib':28270,'load':[0,.01,0],'host':'nucleus','transport':'Tailscale [ts-redacted1]','owner':'01a18167-41de-74e0-882e-9171e642530f'})
b=json.loads((root/'rebind_v22_v0_1/JOB_TEMPLATE_v0_1.json').read_text());b.update(status='BOUND_ACCEPTED',signature_freeze_sha256='6c9d2f7671d233c0ac49c9af4bb887756ecbeaf63e894c4c8c7599346c2b2047',host_reservation_reference='HOST_RESERVATION_BATCH06.json SHA'+rh,fresh_capacity_receipt_file='CAPACITY_BATCH06.json',fresh_capacity_receipt_sha256=ch);bh=save('BOUND_BATCH06.json',b)
c=json.loads((root/'batch05/COMPARE_SWEEP04.json').read_text());c.update(source_sha256={f.name:sha(f) for f in sorted(src.glob('*.lean'))},present_targets=names,axiom_report_targets=names,method='Eight prior Sweep proof bodies retained; two new private final-proof preparation helpers; additional Mathlib.Data.Int.GCD import; public headers unchanged LF; final public theorem still absent',header_comparison='Eight existing frozen Sweep statements unchanged LF')
co=save('COMPARE_FINAL01.json',c)
j=json.loads((root/'batch05/JOB_CompileFVLTRosetteFordSweepV1Batch05Sweep04.json').read_text());j.update(run_id='CompileFVLTRosetteFordSweepV1Batch06Final01',attempt_folder='attempts/Batch06Final01',template_sha256=bh,source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_FINAL01.json',signature_comparison_receipt_sha256=co,deadline_file='DEADLINE_BATCH06.json');jh=save('JOB_'+j['run_id']+'.json',j)
r=json.loads((root/'batch05/REVIEW_ACCEPTANCE.json').read_text());r.update(bound_template_file='BOUND_BATCH06.json',bound_template_sha256=bh,accepted_job_sha256=[jh]);r['reviewed_files'].update({'DEADLINE_BATCH06.json':sha(p/'DEADLINE_BATCH06.json'),'HOST_RESERVATION_BATCH06.json':rh});save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'bound':bh,'capacity':ch,'reservation':rh,'job':jh,'comparison':co,'source':sha(f)},indent=2))
