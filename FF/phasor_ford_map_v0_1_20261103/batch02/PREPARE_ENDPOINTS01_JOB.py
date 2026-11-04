from pathlib import Path
import json, hashlib, shutil
p=Path(__file__).resolve().parent
sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def save(name,obj):
 f=p/name; f.write_text(json.dumps(obj,indent=2)+'\n'); return sha(f)
capacity={'observed_unix':1793783224,'available_mib':28278,'load':[0.04,0.04,0.00], 'host':'nucleus','transport':'Tailscale [ts-redacted1]','owner':'01a18167-41de-74e0-882e-9171e642530f'}
ch=save('CAPACITY_BATCH02_ENDPOINTS01.json',capacity)
b=json.loads((p/'BOUND_BATCH02.json').read_text())
b['fresh_capacity_receipt_file']='CAPACITY_BATCH02_ENDPOINTS01.json'
b['fresh_capacity_receipt_sha256']=ch
bh=save('BOUND_BATCH02_ENDPOINTS01.json',b)
c=json.loads((p/'COMPARE_ENDPOINTS01.json').read_text())
j=json.loads((p/'JOB_CompileFVLTRosetteFordDataV1Batch02Data02.json').read_text())
j.update(module='FVLTRosetteFordEndpointsV1',run_id='CompileFVLTRosetteFordEndpointsV1Batch02Endpoints01',
 template_sha256=bh,attempt_folder='attempts/Batch02Endpoints01', source_sha256=c['source_sha256'],
 dependency_olean_sha256={'FVLTRosetteFordDataV1.olean':'ccb8d144cdd85989dd5acd0f092c976094ed4b7136e173590bcbc617a222b8e9'},
 prerequisite_receipt_sha256={f:sha(p/f) for f in ['CompileFVLTRosetteFordDataV1Batch02Data02.json','axiomsFVLTRosetteFordDataV1Batch02Data02.json','replayFVLTRosetteFordDataV1Batch02Data02.json']},
 signature_comparison_receipt_file='COMPARE_ENDPOINTS01.json',signature_comparison_receipt_sha256=sha(p/'COMPARE_ENDPOINTS01.json'))
jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_ENDPOINTS01.json')
r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text())
r.update(bound_template_file='BOUND_BATCH02_ENDPOINTS01.json',bound_template_sha256=bh,accepted_job_sha256=[jh])
save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'bound':bh,'capacity':ch,'job':jh,'comparison':sha(p/'COMPARE_ENDPOINTS01.json')},indent=2))
