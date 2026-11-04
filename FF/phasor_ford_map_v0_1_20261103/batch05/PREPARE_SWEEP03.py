from pathlib import Path
import json,hashlib,re,shutil
p=Path(__file__).resolve().parent;root=p.parent;sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def text(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;text(f,json.dumps(o,indent=2)+'\n');return sha(f)
new=p/'attempts/Sweep03';shutil.copytree(p/'attempts/Sweep02',new,dirs_exist_ok=True)
f=new/'src/FVLTRosetteFordSweepV1.lean';s=f.read_text(encoding='utf-8').split('end FVLT.PhasorFordV1')[0]
s+=r'''
private theorem unit_numerator (x : ℚ) (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    (x.num.natAbs : ℚ) = (x.num : ℚ) ∧ x.num.natAbs ≤ x.den := by
  have hd : (0 : ℚ) < (x.den : ℚ) := by exact_mod_cast x.den_pos
  have he : (x.num : ℚ) = x * (x.den : ℚ) := (div_eq_iff hd.ne').mp (Rat.num_div_den x)
  have hnq : (0 : ℚ) ≤ (x.num : ℚ) := by rw [he]; positivity
  have hnz : (0 : ℤ) ≤ x.num := by exact_mod_cast hnq
  have hnm : (x.num.natAbs : ℤ) = x.num := by rw [Int.natCast_natAbs, abs_of_nonneg hnz]
  have hmq : (x.num.natAbs : ℚ) = (x.num : ℚ) := by exact_mod_cast hnm
  refine ⟨hmq, ?_⟩
  have hle : (x.num.natAbs : ℚ) ≤ (x.den : ℚ) := by
    rw [hmq, he]
    simpa using mul_le_mul_of_nonneg_right hx1 hd.le
  exact_mod_cast hle

private theorem raw_den_bound (a : ℤ) (q : ℕ) (hq : 0 < q) : (rawValue a q).den ≤ q := by
  have hu := rawValue_canonical 1 q hq (by simp)
  have hv : (a : ℚ) * rawValue 1 q = rawValue a q := by simp [rawValue, div_eq_mul_inv]
  have hd := Rat.mul_den_dvd (a : ℚ) (rawValue 1 q)
  have hdiv : (rawValue a q).den ∣ q := by simpa [hv, hu.2] using hd
  exact Nat.le_of_dvd hq hdiv

'''
h=(root/'freeze_packet_v0_1/FF3_HEADERS_PROPOSED_v0_1.lean.txt').read_text(encoding='utf-8');section=h.split('-- FVLTRosetteFordSweepV1:')[1].split('-- FVLTRosetteFordEndpointsV1:')[0];items=list(re.finditer(r'^theorem\s+(\w+)',section,re.M))
proofs=[r'''by
  constructor
  · intro hevent
    rcases Finset.mem_biUnion.mp hevent with ⟨N', hN', hi⟩
    rcases Finset.mem_image.mp hi with ⟨m, hm, he⟩
    have hne : N' = N := congrArg Prod.fst he
    subst N'
    have hse : (m : ℚ) * (N : ℚ) / ((N : ℚ) - 1) = s := congrArg Prod.snd he
    rcases Finset.mem_Icc.mp hN' with ⟨hN2, hNB⟩
    have hmlt : m < N := Finset.mem_range.mp hm
    have hd : (0 : ℚ) < (N : ℚ) - 1 := by
      have ht : (2 : ℚ) ≤ (N : ℚ) := by exact_mod_cast hN2
      linarith
    have hs0 : (0 : ℚ) ≤ s := by rw [← hse]; positivity
    have hsN : s ≤ (N : ℚ) := by
      rw [← hse]
      apply (div_le_iff₀ hd).mpr
      have hmn : (m : ℚ) + 1 ≤ (N : ℚ) := by exact_mod_cast (show m + 1 ≤ N by omega)
      have hm' : (m : ℚ) ≤ (N : ℚ) - 1 := by linarith
      simpa [mul_comm] using mul_le_mul_of_nonneg_right hm' (show (0 : ℚ) ≤ (N : ℚ) by positivity)
    exact ⟨hN2, hNB, hs0, hsN,
      (shell_contact_parameterization N hN2 s hs0 hsN).mpr ⟨m, by omega, hse.symm⟩⟩
  · rintro ⟨hN2, hNB, hs0, hsN, hint⟩
    rcases (shell_contact_parameterization N hN2 s hs0 hsN).mp hint with ⟨m, hm, hse⟩
    apply Finset.mem_biUnion.mpr
    refine ⟨N, Finset.mem_Icc.mpr ⟨hN2, hNB⟩, ?_⟩
    exact Finset.mem_image.mpr ⟨m, Finset.mem_range.mpr (by omega), Prod.ext rfl hse.symm⟩
''',r'''by
  constructor
  · intro hx
    rcases Finset.mem_biUnion.mp hx with ⟨q, hq, hi⟩
    rcases Finset.mem_Icc.mp hq with ⟨hq1, hqB⟩
    rcases Finset.mem_image.mp hi with ⟨m, hm, rfl⟩
    rcases Finset.mem_filter.mp hm with ⟨hmrange, hmc⟩
    have hmle : m ≤ q := by have := Finset.mem_range.mp hmrange; omega
    have hd : ((m : ℚ) / (q : ℚ)).den = q := by
      simpa [rawValue] using (rawValue_canonical (m : ℤ) q (by omega) (by simpa using hmc)).2
    have hqpos : (0 : ℚ) < (q : ℚ) := by exact_mod_cast (show 0 < q by omega)
    refine ⟨by positivity, (div_le_one hqpos).mpr (by exact_mod_cast hmle), ?_⟩
    simpa [hd] using hqB
  · rintro ⟨hx0, hx1, hxB⟩
    have hn := unit_numerator x hx0 hx1
    apply Finset.mem_biUnion.mpr
    refine ⟨x.den, Finset.mem_Icc.mpr ⟨by have := x.den_pos; omega, hxB⟩, ?_⟩
    refine Finset.mem_image.mpr ⟨x.num.natAbs,
      Finset.mem_filter.mpr ⟨Finset.mem_range.mpr (by omega), x.reduced⟩, ?_⟩
    rw [hn.1]
    exact Rat.num_div_den x
''',r'''by
  ext x
  constructor
  · intro hx
    rcases Finset.mem_image.mp hx with ⟨⟨N, s⟩, hevent, haddr⟩
    rcases (mem_shellEvents B hB N s).mp hevent with ⟨hN2, hNB, hs0, hsN, hint⟩
    rcases (shell_contact_parameterization N hN2 s hs0 hsN).mp hint with ⟨m, hm, hse⟩
    have hv : fordAddress 1 s N = rawValue (m : ℤ) (N - 1) := by
      rw [hse, shell_contact_address N m hN2 hm]
      simp [rawValue, Nat.cast_sub (show 1 ≤ N by omega)]
    change fordAddress 1 s N = x at haddr
    rw [← haddr, hv]
    apply (mem_fareySet B hB _).mpr
    have hq : 0 < N - 1 := by omega
    have hqr : (0 : ℚ) < ((N - 1 : ℕ) : ℚ) := by exact_mod_cast hq
    refine ⟨by unfold rawValue; positivity, ?_, (raw_den_bound (m : ℤ) (N - 1) hq).trans (by omega)⟩
    change (m : ℚ) / ((N - 1 : ℕ) : ℚ) ≤ 1
    exact (div_le_one hqr).mpr (by exact_mod_cast hm)
  · intro hx
    rcases (mem_fareySet B hB x).mp hx with ⟨hx0, hx1, hxB⟩
    have hm := unit_numerator x hx0 hx1
    let N := x.den + 1
    let m := x.num.natAbs
    let s : ℚ := (m : ℚ) * (N : ℚ) / ((N : ℚ) - 1)
    have hN2 : 2 ≤ N := by dsimp [N]; have := x.den_pos; omega
    have hNB : N ≤ B + 1 := by dsimp [N]; omega
    have hmlt : m < N := by dsimp [m, N]; omega
    apply Finset.mem_image.mpr
    refine ⟨(N, s), ?_, ?_⟩
    · apply Finset.mem_biUnion.mpr
      refine ⟨N, Finset.mem_Icc.mpr ⟨hN2, hNB⟩, ?_⟩
      exact Finset.mem_image.mpr ⟨m, Finset.mem_range.mpr hmlt, rfl⟩
    · change fordAddress 1 s N = x
      dsimp [s]
      rw [shell_contact_address N m hN2 (by omega)]
      dsimp [N, m]
      push_cast
      rw [hm.1]
      simpa using Rat.num_div_den x
''']
for i,proof in zip([3,4,5],proofs):s+=section[items[i].start():items[i+1].start()].strip()+' := '+proof+'\n'
s+='end FVLT.PhasorFordV1\n';text(f,s);assert b'\r' not in f.read_bytes()
names=['FVLT.PhasorFordV1.'+m.group(1) for m in re.finditer(r'^theorem\s+(\w+)',s,re.M)];assert len(names)==8
text(new/'AuditRosetteFordSweepV1.lean','import FVLTRosetteFordSweepV1\n'+''.join('#print axioms '+n+'\n' for n in names))
ch=save('CAPACITY_BATCH05_SWEEP03.json',{'observed_unix':1793786149,'available_mib':28129,'load':[.11,.08,.02],'host':'nucleus','transport':'Tailscale [ts-redacted1]','owner':'01a18167-41de-74e0-882e-9171e642530f'})
b=json.loads((p/'BOUND_BATCH05.json').read_text());b.update(fresh_capacity_receipt_file='CAPACITY_BATCH05_SWEEP03.json',fresh_capacity_receipt_sha256=ch);bh=save('BOUND_BATCH05_SWEEP03.json',b)
c=json.loads((p/'COMPARE_SWEEP02.json').read_text());c.update(source_sha256={f.name:sha(f) for f in sorted((new/'src').glob('*.lean'))},present_targets=names,axiom_report_targets=names,method='Five passed proof bodies retained; three frozen membership/set headers appended LF; two private helpers; dependencies bytes unchanged; final consecutive theorem absent',header_comparison='Eight frozen sweep statement texts unchanged LF')
co=save('COMPARE_SWEEP03.json',c)
j=json.loads((p/'JOB_CompileFVLTRosetteFordSweepV1Batch05Sweep02.json').read_text());j.update(run_id='CompileFVLTRosetteFordSweepV1Batch05Sweep03',attempt_folder='attempts/Batch05Sweep03',template_sha256=bh,source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_SWEEP03.json',signature_comparison_receipt_sha256=co);jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_SWEEP03.json');r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r.update(bound_template_file='BOUND_BATCH05_SWEEP03.json',bound_template_sha256=bh,accepted_job_sha256=[jh]);save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'source':sha(f),'comparison':co,'job':jh,'bound':bh,'capacity':ch},indent=2))
