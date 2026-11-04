from pathlib import Path
import json,hashlib,re,shutil
p=Path(__file__).resolve().parent;sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def text(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;text(f,json.dumps(o,indent=2)+'\n');return sha(f)
old=p/'attempts/Final03';new=p/'attempts/Final04';shutil.copytree(old,new)
f=new/'src/FVLTRosetteFordSweepV1.lean';s=f.read_text(encoding='utf-8');before='''    apply (mul_le_mul_left hbz).mp
    have hd1 : (1 : ℤ) ≤ d := by omega
    nlinarith [hdet, hmul, hd1]''';after='''    have hd1 : (1 : ℤ) ≤ d := by omega
    have hprod : (x.den : ℤ) * c ≤ (x.den : ℤ) * d := by nlinarith [hdet, hmul, hd1]
    exact le_of_mul_le_mul_left hprod hbz''';assert s.count(before)==1;s=s.replace(before,after);text(f,s)
headers=lambda t:re.findall(r'^theorem\s+.*?(?= := by)',t,re.M|re.S)
assert headers(s)==headers((old/'src/FVLTRosetteFordSweepV1.lean').read_text(encoding='utf-8')) and len(headers(s))==9
c=json.loads((p/'COMPARE_FINAL03.json').read_text());c['source_sha256']={f.name:sha(f) for f in sorted((new/'src').glob('*.lean'))};c['method']='All nine frozen headers unchanged LF; single private successor proof repair to explicit positive multiplication cancellation API; all previous bodies/helpers and dependency bytes retained; Final03 failure preserved';co=save('COMPARE_FINAL04.json',c)
j=json.loads((p/'JOB_CompileFVLTRosetteFordSweepV1Batch06Final03.json').read_text());j.update(run_id='CompileFVLTRosetteFordSweepV1Batch06Final04',attempt_folder='attempts/Batch06Final04',source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_FINAL04.json',signature_comparison_receipt_sha256=co);jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_FINAL04.json');r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r['accepted_job_sha256']=[jh];save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'source':sha(f),'comparison':co,'job':jh},indent=2))
