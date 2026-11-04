from pathlib import Path
import json,hashlib,shutil
p=Path(__file__).resolve().parent;sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def save(n,o):
 f=p/n;f.write_text(json.dumps(o,indent=2)+'\n',encoding='utf-8',newline='\n');return sha(f)
base=json.loads((p/'JOB_CompileFVLTFordBulbCombinatoricsV1Batch05Combinatorics18.json').read_text())
receipt='CompileFVLTFordBulbCombinatoricsV1Batch05Combinatorics18.json';r=json.loads((p/receipt).read_text());assert r['accepted_result']
targets=json.loads((p/'COMPARE_COMBINATORICS18.json').read_text())['axiom_report_targets']
audit=p/'attempts/Combinatorics18/AuditFVLTFordBulbCombinatoricsV1.lean'
jobs=[]
for mode in ['axioms','replay']:
 j=json.loads(json.dumps(base));j.update(mode=mode,run_id=mode+'FVLTFordBulbCombinatoricsV1Batch05Combinatorics18',own_compile_receipt_file=receipt)
 j['dependency_olean_sha256']['FVLTFordBulbCombinatoricsV1.olean']=r['olean_sha256'];j['prerequisite_receipt_sha256'][receipt]=sha(p/receipt)
 if mode=='axioms':j.update(axiom_report_source=audit.name,axiom_report_source_sha256=sha(audit),axiom_targets=targets)
 jobs.append(save('JOB_'+j['run_id']+'.json',j))
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_COMBINATORICS18_AUDITS.json')
review=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());review['accepted_job_sha256']+=jobs;save('REVIEW_ACCEPTANCE.json',review)
print(json.dumps({'compile_receipt':sha(p/receipt),'audit_sha256':sha(audit),'axiom_job':jobs[0],'replay_job':jobs[1]},indent=2))
