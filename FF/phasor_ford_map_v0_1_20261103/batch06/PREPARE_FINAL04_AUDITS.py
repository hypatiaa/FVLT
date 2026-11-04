from pathlib import Path
import json,hashlib,shutil
p=Path(__file__).resolve().parent
sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def save(n,o):
 f=p/n;f.write_text(json.dumps(o,indent=2)+'\n');return sha(f)
base=json.loads((p/'JOB_CompileFVLTRosetteFordSweepV1Batch06Final04.json').read_text())
receipt='CompileFVLTRosetteFordSweepV1Batch06Final04.json'
compiled=json.loads((p/receipt).read_text());assert compiled['accepted_result']
hashes=[]
for mode in ['axioms','replay']:
 j=json.loads(json.dumps(base));j.update(mode=mode,run_id=mode+'FVLTRosetteFordSweepV1Batch06Final04',own_compile_receipt_file=receipt)
 j['dependency_olean_sha256']['FVLTRosetteFordSweepV1.olean']=compiled['olean_sha256']
 j['prerequisite_receipt_sha256'][receipt]=sha(p/receipt)
 if mode=='axioms':
  j.update(axiom_report_source='AuditRosetteFordSweepV1.lean',axiom_report_source_sha256=sha(p/'attempts/Final04/AuditRosetteFordSweepV1.lean'),axiom_targets=json.loads((p/'COMPARE_FINAL04.json').read_text())['axiom_report_targets'])
 h=save('JOB_'+j['run_id']+'.json',j);hashes.append(h)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_FINAL04_AUDITS.json')
r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r['accepted_job_sha256']+=hashes;save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps(hashes))
