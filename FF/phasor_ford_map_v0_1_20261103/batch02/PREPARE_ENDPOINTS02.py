from pathlib import Path
import json, hashlib, shutil, re
p=Path(__file__).resolve().parent
sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def save(name,obj):
 f=p/name; f.write_text(json.dumps(obj,indent=2)+'\n'); return sha(f)
old=p/'attempts/Endpoints01'; new=p/'attempts/Endpoints02'
shutil.copytree(old,new)
f=new/'src/FVLTRosetteFordEndpointsV1.lean'
s=f.read_text()
assert s.count('simp [classifyEdge, IsBreak, hxy, h, fareyAdj] at *')==1
s=s.replace('simp [classifyEdge, IsBreak, hxy, h, fareyAdj] at *', 'have hd : |det x y| = 1 := h\n      simp [classifyEdge, IsBreak, hxy, hd, fareyAdj]')
s=s.replace('simp [h, he, IsBreak]\n', 'simp [he, IsBreak, hself]\n')
f.write_text(s)
c=json.loads((p/'COMPARE_ENDPOINTS01.json').read_text())
c['source_sha256']={f.name:sha(f) for f in sorted((new/'src').glob('*.lean'))}
c['method']='Data byte-identical to accepted successor; eight public headers compared verbatim with frozen P6; two proof-body repairs only; Endpoints01 retained unchanged'
oldtext=(old/'src/FVLTRosetteFordEndpointsV1.lean').read_text()
header=lambda text:re.findall(r'^theorem\s+.*?(?= := by)',text,re.M|re.S)
assert header(s)==header(oldtext) and len(header(s))==8
ch=save('COMPARE_ENDPOINTS02.json',c)
j=json.loads((p/'JOB_CompileFVLTRosetteFordEndpointsV1Batch02Endpoints01.json').read_text())
j.update(run_id='CompileFVLTRosetteFordEndpointsV1Batch02Endpoints02',attempt_folder='attempts/Batch02Endpoints02',source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_ENDPOINTS02.json',signature_comparison_receipt_sha256=ch)
jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_ENDPOINTS02.json')
r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r['accepted_job_sha256']=[jh];save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'source':sha(f),'comparison':ch,'job':jh,'failed_receipt':sha(p/'CompileFVLTRosetteFordEndpointsV1Batch02Endpoints01.json')},indent=2))
