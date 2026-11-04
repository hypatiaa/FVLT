from pathlib import Path
import json,hashlib,shutil,re
p=Path(__file__).resolve().parent;sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def save(n,o):
 f=p/n;f.write_text(json.dumps(o,indent=2)+'\n');return sha(f)
old=p/'attempts/Phase01';new=p/'attempts/Phase02';shutil.copytree(old,new)
f=new/'src/FVLTRosetteFordPhaseV1.lean';s=f.read_text()
before='convert Complex.exp_int_mul_two_pi_mul_I (1 : ℤ) using 1 <;> norm_num <;> ring'
after='rw [show (((Real.pi * ((2 : ℚ) : ℝ)) : ℂ) * Complex.I) =\n      (Real.pi : ℂ) * Complex.I + (Real.pi : ℂ) * Complex.I by push_cast; ring,\n      Complex.exp_add, Complex.exp_pi_mul_I]\n    norm_num'
assert s.count(before)==1;s=s.replace(before,after);f.write_text(s)
c=json.loads((p/'COMPARE_PHASE01.json').read_text());c['source_sha256']={f.name:sha(f) for f in sorted((new/'src').glob('*.lean'))};c['method']='Data exact accepted successor; all five phase headers unchanged; single private proof-body repair to alias exponential identity; Phase01 retained'
headers=lambda s:re.findall(r'^theorem\s+.*?(?= := by)',s,re.M|re.S)
assert headers(s)==headers((old/'src/FVLTRosetteFordPhaseV1.lean').read_text()) and len(headers(s))==5
ch=save('COMPARE_PHASE02.json',c)
j=json.loads((p/'JOB_CompileFVLTRosetteFordPhaseV1Batch03Phase01.json').read_text());j.update(run_id='CompileFVLTRosetteFordPhaseV1Batch03Phase02',attempt_folder='attempts/Batch03Phase02',source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_PHASE02.json',signature_comparison_receipt_sha256=ch)
jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_PHASE02.json');r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r['accepted_job_sha256']=[jh];save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'source':sha(f),'job':jh,'comparison':ch,'failed_receipt':sha(p/'CompileFVLTRosetteFordPhaseV1Batch03Phase01.json')},indent=2))
