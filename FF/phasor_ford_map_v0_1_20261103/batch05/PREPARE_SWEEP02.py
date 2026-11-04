from pathlib import Path
import json,hashlib,shutil,re
p=Path(__file__).resolve().parent;sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def text(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;text(f,json.dumps(o,indent=2)+'\n');return sha(f)
old=p/'attempts/Sweep01';new=p/'attempts/Sweep02';shutil.copytree(old,new)
f=new/'src/FVLTRosetteFordSweepV1.lean';s=f.read_text(encoding='utf-8');before='exact Finset.sortedLT_sort (fareySet B)';assert s.count(before)==1;s=s.replace(before,'exact (Finset.sortedLT_sort (fareySet B)).pairwise');text(f,s)
headers=lambda s:re.findall(r'^theorem\s+.*?(?= := by)',s,re.M|re.S)
assert headers(s)==headers((old/'src/FVLTRosetteFordSweepV1.lean').read_text(encoding='utf-8')) and len(headers(s))==5
c=json.loads((p/'COMPARE_SWEEP01.json').read_text());c['source_sha256']={f.name:sha(f) for f in sorted((new/'src').glob('*.lean'))};c['method']='Five frozen headers unchanged LF; single proof-only SortedLT.pairwise adapter; Data and Phase dependencies byte-unchanged; Sweep01 failure preserved'
co=save('COMPARE_SWEEP02.json',c)
j=json.loads((p/'JOB_CompileFVLTRosetteFordSweepV1Batch05Sweep01.json').read_text());j.update(run_id='CompileFVLTRosetteFordSweepV1Batch05Sweep02',attempt_folder='attempts/Batch05Sweep02',source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_SWEEP02.json',signature_comparison_receipt_sha256=co);jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_SWEEP02.json');r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r['accepted_job_sha256']=[jh];save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'source':sha(f),'comparison':co,'job':jh},indent=2))
