from pathlib import Path
import json,hashlib,re,shutil
p=Path(__file__).resolve().parent;sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def text(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;text(f,json.dumps(o,indent=2)+'\n');return sha(f)
old=p/'attempts/Final01';new=p/'attempts/Final02';shutil.copytree(old,new)
f=new/'src/FVLTRosetteFordSweepV1.lean';s=f.read_text(encoding='utf-8');before='''    have he := Nat.gcd_eq_gcd_ab a b
    rw [hcop.gcd_eq_one] at he
    dsimp [c0, d0]
    nlinarith [he]''';after='''    calc
      (b : ℤ) * c0 - (a : ℤ) * d0 =
          (a : ℤ) * Nat.gcdA a b + (b : ℤ) * Nat.gcdB a b := by dsimp [c0, d0]; ring
      _ = (Nat.gcd a b : ℤ) := (Nat.gcd_eq_gcd_ab a b).symm
      _ = 1 := by rw [hcop.gcd_eq_one]; rfl''';assert s.count(before)==1;s=s.replace(before,after);text(f,s)
headers=lambda t:re.findall(r'^theorem\s+.*?(?= := by)',t,re.M|re.S)
assert headers(s)==headers((old/'src/FVLTRosetteFordSweepV1.lean').read_text(encoding='utf-8')) and len(headers(s))==8
c=json.loads((p/'COMPARE_FINAL01.json').read_text());c['source_sha256']={f.name:sha(f) for f in sorted((new/'src').glob('*.lean'))};c['method']='Eight frozen headers and prior bodies unchanged; single private Bezout-helper proof repair via explicit ring calculation and exact gcd identity; previous failure preserved; no final public theorem';co=save('COMPARE_FINAL02.json',c)
j=json.loads((p/'JOB_CompileFVLTRosetteFordSweepV1Batch06Final01.json').read_text());j.update(run_id='CompileFVLTRosetteFordSweepV1Batch06Final02',attempt_folder='attempts/Batch06Final02',source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_FINAL02.json',signature_comparison_receipt_sha256=co);jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_FINAL02.json');r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r['accepted_job_sha256']=[jh];save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'source':sha(f),'comparison':co,'job':jh},indent=2))
