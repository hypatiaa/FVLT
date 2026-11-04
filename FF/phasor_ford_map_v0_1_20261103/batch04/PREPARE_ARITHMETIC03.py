from pathlib import Path
import json,hashlib,re,shutil
p=Path(__file__).resolve().parent;root=p.parent;sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def text(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;text(f,json.dumps(o,indent=2)+'\n');return sha(f)
new=p/'attempts/Arithmetic03';shutil.copytree(p/'attempts/Arithmetic02',new,dirs_exist_ok=True)
f=new/'src/FVLTRosetteFordArithmeticV1.lean';s=f.read_text(encoding='utf-8').split('end FVLT.PhasorFordV1')[0]
s+=r'''
private theorem gcd_nonzero (a : ℤ) (q : ℕ) (hq : 0 < q) : (gcdFactor a q : ℤ) ≠ 0 := by
  exact_mod_cast (Nat.ne_of_gt (Nat.gcd_pos_of_pos_right a.natAbs hq))

private theorem product_one_iff (a g h b : ℤ) (hgh : g * h ≠ 0)
    (he : a * g * h = b) : a = 1 ↔ b = g * h := by
  constructor
  · intro ha
    simpa [ha] using he.symm
  · intro hb
    apply mul_right_cancel₀ hgh
    simpa only [one_mul, ← mul_assoc] using he.trans hb

'''
h=(root/'freeze_packet_v0_1/FF3_HEADERS_PROPOSED_v0_1.lean.txt').read_text(encoding='utf-8')
section=h.split('-- FVLTRosetteFordArithmeticV1:')[1].split('-- FVLTRosetteFordSweepV1:')[0]
items=list(re.finditer(r'^theorem\s+(\w+)',section,re.M))
proofs=[r'''by
  have he := reduced_det_mul (s : ℤ) ((s + 1 : ℕ) : ℤ) N N hN hN
  have hc : |(s : ℤ) * (N : ℤ) - ((s + 1 : ℕ) : ℤ) * (N : ℤ)| = (N : ℤ) := by
    rw [show (s : ℤ) * (N : ℤ) - ((s + 1 : ℕ) : ℤ) * (N : ℤ) = -(N : ℤ) by push_cast; ring,
      abs_neg, abs_of_nonneg (by positivity)]
  simpa only [hc] using he
''',r'''by
  unfold fareyAdj
  rw [product_one_iff _ _ _ _
    (mul_ne_zero (gcd_nonzero (s : ℤ) N hN) (gcd_nonzero ((s + 1 : ℕ) : ℤ) N hN))
    (row_law N s hN hs)]
  norm_cast
''',r'''by
  have he := reduced_det_mul u u n (n + 1) (by omega) (by omega)
  have hc : u * ((n + 1 : ℕ) : ℤ) - u * (n : ℤ) = u := by push_cast; ring
  simpa only [hc] using he
''',r'''by
  exact product_one_iff _ _ _ _
    (mul_ne_zero (gcd_nonzero u n (by omega)) (gcd_nonzero u (n + 1) (by omega)))
    (signed_column_law u n hn)
''',r'''by
  simp [rawValue, det, fareyAdj]
''',r'''by
  rw [signed_column_tangent_iff (s : ℤ) n hn]
  simp only [gcdFactor, Int.natAbs_natCast, Int.abs_natCast]
  norm_cast
  rw [eq_comm]
  exact Nat.gcd_mul_gcd_eq_iff_dvd_mul_of_coprime (by
    rw [Nat.coprime_self_add_right]
    simp)
''',r'''by
  constructor
  · rfl
  · have ha := rawValue_canonical 1 n (by omega) (by simp)
    have hb := rawValue_canonical 1 (n + 1) (by omega) (by simp)
    change |(rawValue 1 n).num * ((rawValue 1 (n + 1)).den : ℤ) -
      (rawValue 1 (n + 1)).num * ((rawValue 1 n).den : ℤ)| = 1
    rw [ha.1, ha.2, hb.1, hb.2]
    push_cast
    ring_nf <;> norm_num
''']
for i,proof in zip(range(8,15),proofs):
 end=items[i+1].start() if i+1<len(items) else len(section)
 s+=section[items[i].start():end].strip()+' := '+proof+'\n'
s+='end FVLT.PhasorFordV1\n';text(f,s);assert b'\r' not in f.read_bytes()
names=['FVLT.PhasorFordV1.'+m.group(1) for m in items]
text(new/'AuditRosetteFordArithmeticV1.lean','import FVLTRosetteFordArithmeticV1\n'+''.join('#print axioms '+n+'\n' for n in names))
ch=save('CAPACITY_BATCH04_ARITHMETIC03.json',{'observed_unix':1793785111,'available_mib':28143,'load':[.11,.05,.01],'host':'nucleus','transport':'Tailscale [ts-redacted1]','owner':'01a18167-41de-74e0-882e-9171e642530f'})
b=json.loads((p/'BOUND_BATCH04_ARITHMETIC02.json').read_text());b.update(fresh_capacity_receipt_file='CAPACITY_BATCH04_ARITHMETIC03.json',fresh_capacity_receipt_sha256=ch);bh=save('BOUND_BATCH04_ARITHMETIC03.json',b)
c=json.loads((p/'COMPARE_ARITHMETIC02.json').read_text());c.update(source_sha256={f.name:sha(f) for f in sorted((new/'src').glob('*.lean'))},present_targets=names,axiom_report_targets=names,method='All eight prior proofs retained; remaining seven frozen arithmetic headers appended verbatim LF; three private helpers total; data unchanged; UTF8LFnoBOM',header_comparison='All fifteen frozen arithmetic headers unchanged LF text')
co=save('COMPARE_ARITHMETIC03.json',c)
j=json.loads((p/'JOB_CompileFVLTRosetteFordArithmeticV1Batch04Arithmetic02.json').read_text());j.update(run_id='CompileFVLTRosetteFordArithmeticV1Batch04Arithmetic03',attempt_folder='attempts/Batch04Arithmetic03',template_sha256=bh,source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_ARITHMETIC03.json',signature_comparison_receipt_sha256=co)
jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_ARITHMETIC03.json');r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r.update(bound_template_file='BOUND_BATCH04_ARITHMETIC03.json',bound_template_sha256=bh,accepted_job_sha256=[jh]);save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'source':sha(f),'comparison':co,'job':jh,'bound':bh,'capacity':ch},indent=2))
