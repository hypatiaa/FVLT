from pathlib import Path
import json,hashlib,shutil
p=Path(__file__).resolve().parent
sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def save(n,o):
 f=p/n;f.write_text(json.dumps(o,indent=2)+'\n',encoding='utf-8',newline='\n');return sha(f)
src=p/'attempts/Parameter02/src';src.mkdir(parents=True);(src.parent/'build').mkdir()
shutil.copyfile(p/'attempts/Parameter01/src/FVLTFordBulbDataV1.lean',src/'FVLTFordBulbDataV1.lean')
s=(p/'attempts/Parameter01/src/FVLTFordBulbParameterV1.lean').read_text(encoding='utf-8')
s=s.replace('import FVLTFordBulbDataV1\n','import FVLTFordBulbDataV1\nimport Mathlib.Analysis.Calculus.Deriv.Add\n')
s=s.replace('(hasDerivAt_pow 2 (alpha lambda)).add_const (cardioidParameter lambda)','(hasDerivAt_add_const_iff (cardioidParameter lambda)).2 (hasDerivAt_pow 2 (alpha lambda))')
(src/'FVLTFordBulbParameterV1.lean').write_text(s,encoding='utf-8',newline='\n')
shutil.copyfile(p/'attempts/Parameter01/AuditFVLTFordBulbParameterV1.lean',src.parent/'AuditFVLTFordBulbParameterV1.lean')
ch=save('CAPACITY_BATCH01_PARAMETER02.json',{'observed_unix':1793820586,'available_kib':28974252,'host':'nucleus','transport':'Tailscale 100.105.106.41','owner':'01a18167-41de-74e0-882e-9171e642530f'})
b=json.loads((p/'BOUND_BATCH01_PARAMETER01.json').read_text());b.update(fresh_capacity_receipt_file='CAPACITY_BATCH01_PARAMETER02.json',fresh_capacity_receipt_sha256=ch);bh=save('BOUND_BATCH01_PARAMETER02.json',b)
c=json.loads((p/'COMPARE_PARAMETER01.json').read_text());c['source_sha256']={f.name:sha(f) for f in sorted(src.glob('*.lean'))};c['method']='Proof-only retry: explicit Deriv.Add import and add-constant iff; all four frozen public headers unchanged; Data full bytes unchanged; runner recomputes inventory and closure';co=save('COMPARE_PARAMETER02.json',c)
j=json.loads((p/'JOB_CompileFVLTFordBulbParameterV1Batch01Parameter01.json').read_text());j.update(run_id='CompileFVLTFordBulbParameterV1Batch01Parameter02',attempt_folder='attempts/Batch01Parameter02',template_sha256=bh,source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_PARAMETER02.json',signature_comparison_receipt_sha256=co);jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_PARAMETER02.json');r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r.update(bound_template_file='BOUND_BATCH01_PARAMETER02.json',bound_template_sha256=bh,accepted_job_sha256=[jh]);save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'bound':bh,'capacity':ch,'job':jh,'comparison':co,'source':sha(src/'FVLTFordBulbParameterV1.lean')},indent=2))
