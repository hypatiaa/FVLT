from pathlib import Path
import json,hashlib,shutil
p=Path(__file__).resolve().parent;sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def write(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;write(f,json.dumps(o,indent=2)+'\n');return sha(f)
src=p/'attempts/Combinatorics03/src';src.mkdir(parents=True);(src.parent/'build').mkdir()
shutil.copyfile(p/'attempts/Combinatorics02/src/FVLTFordBulbDataV1.lean',src/'FVLTFordBulbDataV1.lean')
s=(p/'attempts/Combinatorics02/src/FVLTFordBulbCombinatoricsV1.lean').read_text(encoding='utf-8').split('end FVLT.FordBulbV1')[0]
idx=json.loads((p.parent/'freeze_packet_v0_1/TARGET_INDEX_v0_1.json').read_text());t=next(t for t in idx['targets'] if t['name'].endswith('.word_bounds'))
s+=(p/'WORD_BOUNDS_HELPERS_v0_1.lean.txt').read_text(encoding='utf-8')+'\n'+t['header']+''' := by
  have hc := raw_digit_full_count d u
  have hb := binary_count_bounds d.p d.q u.val d.q
  have hp := d.p_pos
  have hpq := d.p_lt_q
  change 0 < blockValue d.p d.q u.val d.q ∧
    blockValue d.p d.q u.val d.q < 2 ^ d.q - 1
  omega

end FVLT.FordBulbV1
''';write(src/'FVLTFordBulbCombinatoricsV1.lean',s)
c=json.loads((p/'COMPARE_COMBINATORICS02.json').read_text());names=c['present_targets']+[t['name']]
write(src.parent/'AuditFVLTFordBulbCombinatoricsV1.lean','import FVLTFordBulbCombinatoricsV1\n'+''.join('#print axioms '+n+'\n' for n in names))
ch=save('CAPACITY_BATCH02_COMBINATORICS03.json',{'observed_unix':1793822445,'available_kib':28867956,'host':'nucleus','transport':'Tailscale 100.105.106.41','owner':'01a18167-41de-74e0-882e-9171e642530f'})
b=json.loads((p/'BOUND_BATCH02.json').read_text());b.update(fresh_capacity_receipt_file='CAPACITY_BATCH02_COMBINATORICS03.json',fresh_capacity_receipt_sha256=ch);bh=save('BOUND_BATCH02_COMBINATORICS03.json',b)
c.update(source_sha256={f.name:sha(f) for f in sorted(src.glob('*.lean'))},present_targets=names,axiom_report_targets=names,method='Nine predecessor public proofs preserved; one additional unchanged frozen header; five private finite arithmetic helpers; Data fullbytes unchanged; runner recomputes');co=save('COMPARE_COMBINATORICS03.json',c)
j=json.loads((p/'JOB_CompileFVLTFordBulbCombinatoricsV1Batch02Combinatorics02.json').read_text());j.update(run_id='CompileFVLTFordBulbCombinatoricsV1Batch02Combinatorics03',attempt_folder='attempts/Batch02Combinatorics03',template_sha256=bh,source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_COMBINATORICS03.json',signature_comparison_receipt_sha256=co);jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_COMBINATORICS03.json');r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r.update(bound_template_file='BOUND_BATCH02_COMBINATORICS03.json',bound_template_sha256=bh,accepted_job_sha256=[jh]);save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'bound':bh,'capacity':ch,'job':jh,'comparison':co,'source':sha(src/'FVLTFordBulbCombinatoricsV1.lean')},indent=2))
