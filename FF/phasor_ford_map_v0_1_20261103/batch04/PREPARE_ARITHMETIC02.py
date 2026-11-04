from pathlib import Path
import json,hashlib,re,shutil
p=Path(__file__).resolve().parent;root=p.parent
sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def text(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;text(f,json.dumps(o,indent=2)+'\n');return sha(f)
old=p/'attempts/Arithmetic01';new=p/'attempts/Arithmetic02';shutil.copytree(old,new)
f=new/'src/FVLTRosetteFordArithmeticV1.lean';s=f.read_text(encoding='utf-8').split('end FVLT.PhasorFordV1')[0]
s+=r'''
private theorem raw_normalization (a : ℤ) (q : ℕ) (hq : 0 < q) :
    (rawValue a q).num * (gcdFactor a q : ℤ) = a ∧
      (rawValue a q).den * gcdFactor a q = q := by
  have hu := rawValue_canonical 1 q hq (by simp)
  have hv : (a : ℚ) * rawValue 1 q = rawValue a q := by
    simp [rawValue, div_eq_mul_inv]
  have hn := Rat.num_mul_num_eq_num_mul_gcd (a : ℚ) (rawValue 1 q)
  have hd := Rat.den_mul_den_eq_den_mul_gcd (a : ℚ) (rawValue 1 q)
  simp only [hv, hu.1, hu.2] at hn hd
  constructor
  · simpa [gcdFactor] using hn.symm
  · simpa [gcdFactor] using hd.symm

'''
h=(root/'freeze_packet_v0_1/FF3_HEADERS_PROPOSED_v0_1.lean.txt').read_text(encoding='utf-8')
section=h.split('-- FVLTRosetteFordArithmeticV1:')[1].split('-- FVLTRosetteFordSweepV1:')[0]
items=list(re.finditer(r'^theorem\s+(\w+)',section,re.M))
proofs=[r'''by
  have ha := raw_normalization a q hq
  have hc := raw_normalization c r hr
  have hq' : ((rawValue a q).den : ℤ) * (gcdFactor a q : ℤ) = (q : ℤ) := by
    exact_mod_cast ha.2
  have hr' : ((rawValue c r).den : ℤ) * (gcdFactor c r : ℤ) = (r : ℤ) := by
    exact_mod_cast hc.2
  have he : det (rawValue a q) (rawValue c r) * (gcdFactor a q : ℤ) *
      (gcdFactor c r : ℤ) = a * (r : ℤ) - c * (q : ℤ) := by
    calc
      _ = ((rawValue a q).num * (gcdFactor a q : ℤ)) *
          (((rawValue c r).den : ℤ) * (gcdFactor c r : ℤ)) -
          ((rawValue c r).num * (gcdFactor c r : ℤ)) *
          (((rawValue a q).den : ℤ) * (gcdFactor a q : ℤ)) := by unfold det; ring
      _ = _ := by rw [ha.1, hc.1, hq', hr']
  simpa only [abs_mul, abs_of_nonneg (show (0 : ℤ) ≤ (gcdFactor a q : ℤ) by positivity),
    abs_of_nonneg (show (0 : ℤ) ≤ (gcdFactor c r : ℤ) by positivity)] using congrArg abs he
''',r'''by
  have hg : 0 < gcdFactor a q := Nat.gcd_pos_of_pos_right _ hq
  have hh : 0 < gcdFactor c r := Nat.gcd_pos_of_pos_right _ hr
  have hn : (gcdFactor a q : ℤ) * (gcdFactor c r : ℤ) ≠ 0 := by
    exact_mod_cast (Nat.ne_of_gt (Nat.mul_pos hg hh))
  rw [← reduced_det_mul a c q r hq hr, mul_assoc]
  exact (Int.mul_ediv_cancel _ hn).symm
''']
for i,proof in zip([6,7],proofs):s+=section[items[i].start():items[i+1].start()].strip()+' := '+proof+'\n'
s+='end FVLT.PhasorFordV1\n';text(f,s);assert b'\r' not in f.read_bytes()
names=['FVLT.PhasorFordV1.'+m.group(1) for m in items[:8]]
text(new/'AuditRosetteFordArithmeticV1.lean','import FVLTRosetteFordArithmeticV1\n'+''.join('#print axioms '+n+'\n' for n in names))
ch=save('CAPACITY_BATCH04_ARITHMETIC02.json',{'observed_unix':1793784791,'available_mib':28274,'load':[.03,.01,0],'host':'nucleus','transport':'Tailscale [ts-redacted1]','owner':'01a18167-41de-74e0-882e-9171e642530f'})
b=json.loads((p/'BOUND_BATCH04.json').read_text());b.update(fresh_capacity_receipt_file='CAPACITY_BATCH04_ARITHMETIC02.json',fresh_capacity_receipt_sha256=ch);bh=save('BOUND_BATCH04_ARITHMETIC02.json',b)
c=json.loads((p/'COMPARE_ARITHMETIC01.json').read_text());c.update(source_sha256={f.name:sha(f) for f in sorted((new/'src').glob('*.lean'))},present_targets=names,axiom_report_targets=names,method='First six proofs retained; two frozen reduced-determinant headers appended verbatim LF; one private normalization helper; all data unchanged; zero CR/noBOM',header_comparison='Eight frozen arithmetic headers unchanged LF text')
co=save('COMPARE_ARITHMETIC02.json',c)
j=json.loads((p/'JOB_CompileFVLTRosetteFordArithmeticV1Batch04Arithmetic01.json').read_text());j.update(run_id='CompileFVLTRosetteFordArithmeticV1Batch04Arithmetic02',attempt_folder='attempts/Batch04Arithmetic02',template_sha256=bh,source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_ARITHMETIC02.json',signature_comparison_receipt_sha256=co)
jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_ARITHMETIC02.json');r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r.update(bound_template_file='BOUND_BATCH04_ARITHMETIC02.json',bound_template_sha256=bh,accepted_job_sha256=[jh]);save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'source':sha(f),'comparison':co,'job':jh,'bound':bh,'capacity':ch},indent=2))
