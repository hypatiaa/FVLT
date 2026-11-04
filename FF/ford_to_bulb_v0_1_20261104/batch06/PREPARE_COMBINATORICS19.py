from pathlib import Path
import json,hashlib,shutil
p=Path(__file__).resolve().parent;root=p.parent;old=root/'batch05';sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def write(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;write(f,json.dumps(o,indent=2)+'\n');return sha(f)
src=p/'attempts/Combinatorics19/src';src.mkdir(parents=True);(src.parent/'build').mkdir()
shutil.copyfile(old/'attempts/Combinatorics18/src/FVLTFordBulbDataV1.lean',src/'FVLTFordBulbDataV1.lean')
s=(old/'attempts/Combinatorics18/src/FVLTFordBulbCombinatoricsV1.lean').read_text(encoding='utf-8').split('end FVLT.FordBulbV1')[0]
s+=(p/'C1_HELPERS_v0_1.lean.txt').read_text(encoding='utf-8')+'\nend FVLT.FordBulbV1\n';write(src/'FVLTFordBulbCombinatoricsV1.lean',s)
c=json.loads((old/'COMPARE_COMBINATORICS18.json').read_text());names=c['present_targets']
write(src.parent/'AuditFVLTFordBulbCombinatoricsV1.lean','import FVLTFordBulbCombinatoricsV1\n'+''.join('#print axioms '+n+'\n' for n in names))
rh=save('HOST_RESERVATION_BATCH06.json',{'host':'nucleus','owner':'01a18167-41de-74e0-882e-9171e642530f','transport':'Tailscale [ts-redacted1]','cpu_jobs':1,'address_space_bytes':8589934592,'start_unix':1793827083,'end_unix':1793828883,'other_owned_builds':False})
ch=save('CAPACITY_BATCH06.json',{'observed_unix':1793827253,'available_kib':28971584,'host':'nucleus','transport':'Tailscale [ts-redacted1]','owner':'01a18167-41de-74e0-882e-9171e642530f','latest_library':23,'full_checks':401,'checksum_failures':0,'writable_files':0})
b=json.loads((old/'BOUND_BATCH05_COMBINATORICS17.json').read_text());b.update(host_reservation_reference='HOST_RESERVATION_BATCH06.json SHA'+rh,fresh_capacity_receipt_file='CAPACITY_BATCH06.json',fresh_capacity_receipt_sha256=ch);bh=save('BOUND_BATCH06.json',b)
c.update(source_sha256={f.name:sha(f) for f in sorted(src.glob('*.lean'))},method='Twenty-six public proofsheaders unchanged; tenPRIVATE fullC1prefix/commonblock/repetition helpers, no newpublictargetclaim; fullData unchanged; runner recomputes');co=save('COMPARE_COMBINATORICS19.json',c)
j=json.loads((old/'JOB_CompileFVLTFordBulbCombinatoricsV1Batch05Combinatorics18.json').read_text());j.update(run_id='CompileFVLTFordBulbCombinatoricsV1Batch06Combinatorics19',attempt_folder='attempts/Batch06Combinatorics19',template_sha256=bh,source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_COMBINATORICS19.json',signature_comparison_receipt_sha256=co,deadline_file='DEADLINE_BATCH06.json');jh=save('JOB_'+j['run_id']+'.json',j)
r=json.loads((old/'REVIEW_ACCEPTANCE.json').read_text());r.update(bound_template_file='BOUND_BATCH06.json',bound_template_sha256=bh,accepted_job_sha256=[jh]);r['reviewed_files'].update({n:sha(p/n) for n in ['HOST_RESERVATION_BATCH06.json','DEADLINE_BATCH06.json']});save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'bound':bh,'capacity':ch,'reservation':rh,'job':jh,'comparison':co,'source':sha(src/'FVLTFordBulbCombinatoricsV1.lean')},indent=2))
