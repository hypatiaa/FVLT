from pathlib import Path
import json,hashlib,shutil
p=Path(__file__).resolve().parent;root=p.parent;sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def text(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;text(f,json.dumps(o,indent=2)+'\n');return sha(f)
src=p/'attempts/Parameter01/src';src.mkdir(parents=True);(src.parent/'build').mkdir()
shutil.copyfile(p/'attempts/Data01/src/FVLTFordBulbDataV1.lean',src/'FVLTFordBulbDataV1.lean')
targets=[t for t in json.loads((root/'freeze_packet_v0_1/TARGET_INDEX_v0_1.json').read_text(encoding='utf-8'))['targets'] if t['module']=='FVLTFordBulbParameterV1']
proofs=[r'''by
  unfold quadratic cardioidParameter alpha
  ring
''',r'''by
  unfold quadraticMultiplier alpha
  ring
''',r'''by
  have h : HasDerivAt (fun z : ℂ => z ^ 2 + cardioidParameter lambda)
      (2 * alpha lambda) (alpha lambda) := by
    simpa using (hasDerivAt_pow 2 (alpha lambda)).add_const (cardioidParameter lambda)
  have hm : (2 : ℂ) * alpha lambda = lambda := by unfold alpha; ring
  rw [hm] at h
  exact h
''',r'''by
  have he : canonicalMultiplier d =
      Complex.exp (2 * (Real.pi : ℂ) * Complex.I * ((d.p : ℂ) / (d.q : ℂ))) := by
    unfold canonicalMultiplier address
    congr 1
    push_cast
    ring
  rw [he]
  exact Complex.isPrimitiveRoot_exp_of_coprime d.p d.q
    (Nat.ne_of_gt (Nat.lt_trans d.p_pos d.p_lt_q)) d.coprime
''']
assert len(targets)==len(proofs)==4
s='import FVLTFordBulbDataV1\nopen scoped BigOperators\nnamespace FVLT.FordBulbV1\n\n'+''.join(t['header']+' := '+proof+'\n' for t,proof in zip(targets,proofs))+'end FVLT.FordBulbV1\n'
text(src/'FVLTFordBulbParameterV1.lean',s)
names=[t['name'] for t in targets];text(src.parent/'AuditFVLTFordBulbParameterV1.lean','import FVLTFordBulbParameterV1\n'+''.join('#print axioms '+n+'\n' for n in names))
ch=save('CAPACITY_BATCH01_PARAMETER01.json',{'observed_unix':1793820271,'available_kib':28892240,'load':[.10,.04,.01],'host':'nucleus','transport':'Tailscale [ts-redacted1]','owner':'01a18167-41de-74e0-882e-9171e642530f'})
b=json.loads((p/'BOUND_BATCH01.json').read_text(encoding='utf-8'));b.update(fresh_capacity_receipt_file='CAPACITY_BATCH01_PARAMETER01.json',fresh_capacity_receipt_sha256=ch);bh=save('BOUND_BATCH01_PARAMETER01.json',b)
c=json.loads((p/'COMPARE_DATA01.json').read_text(encoding='utf-8'));c.update(source_sha256={f.name:sha(f) for f in sorted(src.glob('*.lean'))},present_targets=names,axiom_report_targets=names,method='Full data exact accepted19fcd5d3; four public Parameter headers copied byte-identical LF from target index; no extra public declarations/attributes/ambient variables; UTF8LFnoBOM; runner recomputes checks');co=save('COMPARE_PARAMETER01.json',c)
j=json.loads((p/'JOB_CompileFVLTFordBulbDataV1Batch01Data01.json').read_text(encoding='utf-8'));j.update(module='FVLTFordBulbParameterV1',run_id='CompileFVLTFordBulbParameterV1Batch01Parameter01',attempt_folder='attempts/Batch01Parameter01',template_sha256=bh,source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_PARAMETER01.json',signature_comparison_receipt_sha256=co,dependency_olean_sha256={'FVLTFordBulbDataV1.olean':'21df17bc2e550337e13519487014f011c7ed712178c903d7bda283c546bd75f3'},prerequisite_receipt_sha256={n:sha(p/n) for n in ['CompileFVLTFordBulbDataV1Batch01Data01.json','axiomsFVLTFordBulbDataV1Batch01Data01.json','replayFVLTFordBulbDataV1Batch01Data01.json']});jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_PARAMETER01.json');r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text(encoding='utf-8'));r.update(bound_template_file='BOUND_BATCH01_PARAMETER01.json',bound_template_sha256=bh,accepted_job_sha256=[jh]);save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'source':sha(src/'FVLTFordBulbParameterV1.lean'),'bound':bh,'capacity':ch,'job':jh,'comparison':co},indent=2))
