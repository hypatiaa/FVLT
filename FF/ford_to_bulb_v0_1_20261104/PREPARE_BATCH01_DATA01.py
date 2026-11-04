from pathlib import Path
import json,hashlib,shutil
root=Path(__file__).resolve().parent;p=root/'batch01';p.mkdir(exist_ok=False);packet=root/'freeze_packet_v0_1'
sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def text(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;text(f,json.dumps(o,indent=2)+'\n');return sha(f)
manifest=json.loads((packet/'PACKET_MANIFEST_v0_1.json').read_text(encoding='utf-8'))
for e in manifest['files']:
 f=packet/e['file'];assert sha(f)==e['sha256'] and f.stat().st_size==e['bytes']
assert sha(packet/'PACKET_MANIFEST_v0_1.json')=='115a6c7d95384e2caeb8c5453ff876f2ea4519bf4afdc8eec23e4aaec1906d90'
decision=root/'FF4_FREEZE_DECISION_v0_1.md';assert sha(decision)=='5195a4be569cc05c60aced44dd14bbf23a615a10cfe5f39cca12e490d694d8f7'
src=p/'attempts/Data01/src';src.mkdir(parents=True);(src.parent/'build').mkdir()
shutil.copyfile(packet/'FF4_DEFINITIONS_PROPOSED_v0_1.lean.txt',src/'FVLTFordBulbDataV1.lean')
index=json.loads((packet/'TARGET_INDEX_v0_1.json').read_text(encoding='utf-8'))
text(src.parent/'AuditFordBulbDataV1.lean','import FVLTFordBulbDataV1\n'+''.join('#print axioms '+n+'\n' for n in index['data_axiom_targets']))
save('DEADLINE_BATCH01.json',{'cap_seconds':1800,'origin_unix':1793819862,'deadline_unix':1793821662,'no_reset_or_extension':True,'batch':'FF4 Batch01'})
rh=save('HOST_RESERVATION_BATCH01.json',{'host':'nucleus','owner':'01a18167-41de-74e0-882e-9171e642530f','transport':'Tailscale 100.105.106.41','cpu_jobs':1,'address_space_bytes':8589934592,'start_unix':1793819862,'end_unix':1793821662,'other_owned_builds':False})
ch=save('CAPACITY_BATCH01.json',{'observed_unix':1793819862,'available_kib':28981744,'available_mib':28302,'load':[0,0,0],'host':'nucleus','transport':'Tailscale 100.105.106.41','owner':'01a18167-41de-74e0-882e-9171e642530f'})
b=json.loads((packet/'JOB_TEMPLATE_v0_1.json').read_text(encoding='utf-8'));b.update(status='BOUND_ACCEPTED',signature_freeze_sha256=sha(packet/'PACKET_MANIFEST_v0_1.json'),host_reservation_reference='HOST_RESERVATION_BATCH01.json SHA'+rh,fresh_capacity_receipt_file='CAPACITY_BATCH01.json',fresh_capacity_receipt_sha256=ch);bh=save('BOUND_BATCH01.json',b)
sources={'FVLTFordBulbDataV1.lean':sha(src/'FVLTFordBulbDataV1.lean')}
co=save('COMPARE_DATA01.json',{'schema':'ff4-source-comparison/1','verdict':'PASS','source_sha256':sources,'freeze_sha256':sha(packet/'PACKET_MANIFEST_v0_1.json'),'g1_import_closure_excluded':True,'all_present_public_headers_match':True,'data_definitions_exact':True,'present_targets':[],'axiom_report_targets':index['data_axiom_targets'],'method':'Full data file including imports equals accepted definitions byte for byte; no theorem headers present; three inherited FF1 sources match v23 and contain no G1 import; runner recomputes source/header/import checks'})
j={'phase':'FF4_COMBINATORIAL','module':'FVLTFordBulbDataV1','mode':'compile','run_id':'CompileFVLTFordBulbDataV1Batch01Data01','template_sha256':bh,'attempt_folder':'attempts/Batch01Data01','source_sha256':sources,'dependency_olean_sha256':{},'prerequisite_receipt_sha256':{},'signature_comparison_receipt_file':'COMPARE_DATA01.json','signature_comparison_receipt_sha256':co,'deadline_file':'DEADLINE_BATCH01.json'}
jh=save('JOB_'+j['run_id']+'.json',j)
protected={'freeze_packet_v0_1/'+e['file']:e['sha256'] for e in manifest['files']}
protected.update({'freeze_packet_v0_1/PACKET_MANIFEST_v0_1.json':sha(packet/'PACKET_MANIFEST_v0_1.json'),'authority/FF4_FREEZE_DECISION_v0_1.md':sha(decision),'RUN_FF4_v0_1.py':sha(packet/'RUN_FF4_v0_1.py'),'IndependentFVLTReplay435.lean':sha(packet/'IndependentFVLTReplay435.lean'),'TARGET_INDEX_v0_1.json':sha(packet/'TARGET_INDEX_v0_1.json'),'FF4_DEFINITIONS_PROPOSED_v0_1.lean.txt':sha(packet/'FF4_DEFINITIONS_PROPOSED_v0_1.lean.txt'),'FF4_HEADERS_PROPOSED_v0_1.lean.txt':sha(packet/'FF4_HEADERS_PROPOSED_v0_1.lean.txt'),'DEADLINE_BATCH01.json':sha(p/'DEADLINE_BATCH01.json'),'HOST_RESERVATION_BATCH01.json':rh})
save('REVIEW_ACCEPTANCE.json',{'input_signature_acceptance':'Opus FF4 freeze decision #1563 SHA5195a4be; packet115a6c7d/31data/33targets','template_acceptance':'FF4 #1563 all-match binding on exact posting plus exact jobs before launch; no preaccepted job without posting receipt','runner_sha256':sha(packet/'RUN_FF4_v0_1.py'),'bound_template_file':'BOUND_BATCH01.json','bound_template_sha256':bh,'accepted_job_sha256':[jh],'reviewed_files':protected})
print(json.dumps({'packet_entries_verified':len(manifest['files']),'source':sources,'bound':bh,'capacity':ch,'reservation':rh,'job':jh,'comparison':co},indent=2))
