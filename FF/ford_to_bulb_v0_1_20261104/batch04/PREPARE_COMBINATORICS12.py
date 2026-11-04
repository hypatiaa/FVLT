from pathlib import Path
import json,hashlib,shutil
p=Path(__file__).resolve().parent;sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def write(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;write(f,json.dumps(o,indent=2)+'\n');return sha(f)
src=p/'attempts/Combinatorics12/src';src.mkdir(parents=True);(src.parent/'build').mkdir()
shutil.copyfile(p/'attempts/Combinatorics11/src/FVLTFordBulbDataV1.lean',src/'FVLTFordBulbDataV1.lean')
s=(p/'attempts/Combinatorics11/src/FVLTFordBulbCombinatoricsV1.lean').read_text(encoding='utf-8').split('end FVLT.FordBulbV1')[0]
idx=json.loads((p.parent/'freeze_packet_v0_1/TARGET_INDEX_v0_1.json').read_text());ts={t['name'].split('.')[-1]:t for t in idx['targets']};proofs=json.loads((p/'RANK_PROOFS_v0_1.json').read_text(encoding='utf-8'))
for n,pr in proofs.items():s+=ts[n]['header']+' := '+pr+'\n'
s+='end FVLT.FordBulbV1\n';write(src/'FVLTFordBulbCombinatoricsV1.lean',s)
c=json.loads((p/'COMPARE_COMBINATORICS11.json').read_text());names=c['present_targets']+[ts[n]['name'] for n in proofs]
write(src.parent/'AuditFVLTFordBulbCombinatoricsV1.lean','import FVLTFordBulbCombinatoricsV1\n'+''.join('#print axioms '+n+'\n' for n in names))
ch=save('CAPACITY_BATCH04_COMBINATORICS12.json',{'observed_unix':1793825400,'available_kib':28963320,'host':'nucleus','transport':'Tailscale [ts-redacted1]','owner':'01a18167-41de-74e0-882e-9171e642530f'})
b=json.loads((p/'BOUND_BATCH04_COMBINATORICS11.json').read_text());b.update(fresh_capacity_receipt_file='CAPACITY_BATCH04_COMBINATORICS12.json',fresh_capacity_receipt_sha256=ch);bh=save('BOUND_BATCH04_COMBINATORICS12.json',b)
c.update(source_sha256={f.name:sha(f) for f in sorted(src.glob('*.lean'))},present_targets=names,axiom_report_targets=names,method='Twenty-three predecessor public proofs retained; two additional unchanged frozen rank headers; no new helpers; fullData unchanged; runner recomputes');co=save('COMPARE_COMBINATORICS12.json',c)
j=json.loads((p/'JOB_CompileFVLTFordBulbCombinatoricsV1Batch04Combinatorics11.json').read_text());j.update(run_id='CompileFVLTFordBulbCombinatoricsV1Batch04Combinatorics12',attempt_folder='attempts/Batch04Combinatorics12',template_sha256=bh,source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_COMBINATORICS12.json',signature_comparison_receipt_sha256=co);jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_COMBINATORICS12.json');r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r.update(bound_template_file='BOUND_BATCH04_COMBINATORICS12.json',bound_template_sha256=bh,accepted_job_sha256=[jh]);save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'bound':bh,'capacity':ch,'job':jh,'comparison':co,'source':sha(src/'FVLTFordBulbCombinatoricsV1.lean')},indent=2))
