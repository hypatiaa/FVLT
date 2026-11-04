from pathlib import Path
import json,hashlib,re,shutil
p=Path(__file__).resolve().parent;sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def text(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;text(f,json.dumps(o,indent=2)+'\n');return sha(f)
old=p/'attempts/Sweep03';new=p/'attempts/Sweep04';shutil.copytree(old,new)
f=new/'src/FVLTRosetteFordSweepV1.lean';s=f.read_text(encoding='utf-8');before='have hmq : (x.num.natAbs : ℚ) = (x.num : ℚ) := by exact_mod_cast hnm';after='have hmq : (x.num.natAbs : ℚ) = (x.num : ℚ) := by\n    simpa only [Int.cast_natCast] using congrArg (fun z : ℤ => (z : ℚ)) hnm';assert s.count(before)==1;s=s.replace(before,after);text(f,s)
headers=lambda t:re.findall(r'^theorem\s+.*?(?= := by)',t,re.M|re.S)
assert headers(s)==headers((old/'src/FVLTRosetteFordSweepV1.lean').read_text(encoding='utf-8')) and len(headers(s))==8
c=json.loads((p/'COMPARE_SWEEP03.json').read_text());c['source_sha256']={f.name:sha(f) for f in sorted((new/'src').glob('*.lean'))};c['method']='Eight frozen headers unchanged LF; single private helper cast proof repaired using congrArg and Int.cast_natCast; predecessors and dependency bytes preserved';co=save('COMPARE_SWEEP04.json',c)
j=json.loads((p/'JOB_CompileFVLTRosetteFordSweepV1Batch05Sweep03.json').read_text());j.update(run_id='CompileFVLTRosetteFordSweepV1Batch05Sweep04',attempt_folder='attempts/Batch05Sweep04',source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_SWEEP04.json',signature_comparison_receipt_sha256=co);jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_SWEEP04.json');r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r['accepted_job_sha256']=[jh];save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'source':sha(f),'comparison':co,'job':jh},indent=2))
