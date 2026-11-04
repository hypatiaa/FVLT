from pathlib import Path
import json,hashlib,re,shutil
p=Path(__file__).resolve().parent;root=p.parent;sha=lambda f:hashlib.sha256(f.read_bytes()).hexdigest()
def text(f,s):f.write_text(s,encoding='utf-8',newline='\n')
def save(n,o):
 f=p/n;text(f,json.dumps(o,indent=2)+'\n');return sha(f)
new=p/'attempts/Final03';shutil.copytree(p/'attempts/Final02',new)
f=new/'src/FVLTRosetteFordSweepV1.lean';s=f.read_text(encoding='utf-8').split('end FVLT.PhasorFordV1')[0]
s+=r'''
private theorem exists_bounded_successor (B : ℕ) (hB : 1 ≤ B) (x : ℚ)
    (hx : x ∈ fareySet B) (hx1 : x < 1) :
    ∃ w : ℚ, w ∈ fareySet B ∧ x < w ∧
      (x.den : ℤ) * w.num - x.num * (w.den : ℤ) = 1 ∧ B < x.den + w.den := by
  rcases (mem_fareySet B hB x).mp hx with ⟨hx0, hxle, hxB⟩
  have hnum := unit_numerator x hx0 hxle
  have ha : (x.num.natAbs : ℤ) = x.num := Rat.intCast_injective (by
    simpa only [Int.cast_natCast] using hnum.1)
  rcases bounded_bezout x.num.natAbs x.den B x.den_pos hxB x.reduced with
    ⟨c, d, hdpos, hdB, hlarge, hdet⟩
  rw [ha] at hdet
  let q := d.toNat
  have hqd : (q : ℤ) = d := Int.toNat_of_nonneg hdpos.le
  have hqpos : 0 < q := by
    have hh : (0 : ℤ) < (q : ℤ) := by rw [hqd]; exact hdpos
    exact_mod_cast hh
  have hqB : q ≤ B := by
    have hh : (q : ℤ) ≤ (B : ℤ) := by rw [hqd]; exact hdB
    exact_mod_cast hh
  have hbq : (0 : ℚ) < (x.den : ℚ) := by exact_mod_cast x.den_pos
  have hqq : (0 : ℚ) < (q : ℚ) := by exact_mod_cast hqpos
  have hbz : (0 : ℤ) < (x.den : ℤ) := by exact_mod_cast x.den_pos
  have hdetraw : |x.num * (q : ℤ) - c * (x.den : ℤ)| = 1 := by
    rw [hqd, show x.num * d - c * (x.den : ℤ) = -1 by nlinarith [hdet]]
    norm_num
  have hred := (raw_det_one_coprime x.num c x.den q x.den_pos hqpos hdetraw).2.1
  have hw := rawValue_canonical c q hqpos hred
  let w := rawValue c q
  have hxw : x < w := by
    change x < (c : ℚ) / (q : ℚ)
    have hcross : (x.num : ℚ) * (q : ℚ) < (c : ℚ) * (x.den : ℚ) := by
      have hh : x.num * (q : ℤ) < c * (x.den : ℤ) := by rw [hqd]; nlinarith [hdet]
      exact_mod_cast hh
    calc
      x = (x.num : ℚ) / (x.den : ℚ) := (Rat.num_div_den x).symm
      _ < (c : ℚ) / (q : ℚ) := (div_lt_div_iff₀ hbq hqq).mpr hcross
  have haw : x.num < (x.den : ℤ) := by
    have hh : (x.num : ℚ) < (x.den : ℚ) := (div_lt_one hbq).mp (by
      simpa only [Rat.num_div_den] using hx1)
    exact_mod_cast hh
  have hmul := mul_le_mul_of_nonneg_right (show x.num ≤ (x.den : ℤ) - 1 by omega) hdpos.le
  have hcd : c ≤ d := by
    apply (mul_le_mul_left hbz).mp
    have hd1 : (1 : ℤ) ≤ d := by omega
    nlinarith [hdet, hmul, hd1]
  have hwle : w ≤ 1 := by
    change (c : ℚ) / (q : ℚ) ≤ 1
    apply (div_le_one hqq).mpr
    have hh : c ≤ (q : ℤ) := by rw [hqd]; exact hcd
    exact_mod_cast hh
  refine ⟨w, (mem_fareySet B hB w).mpr ⟨hx0.trans hxw.le, hwle, ?_⟩, hxw, ?_, ?_⟩
  · change (rawValue c q).den ≤ B
    rw [hw.2]
    exact hqB
  · change (x.den : ℤ) * (rawValue c q).num - x.num * ((rawValue c q).den : ℤ) = 1
    rw [hw.1, hw.2, hqd]
    exact hdet
  · change B < x.den + (rawValue c q).den
    rw [hw.2]
    have hh : (B : ℤ) < (x.den : ℤ) + (q : ℤ) := by rw [hqd]; exact hlarge
    exact_mod_cast hh

'''
h=(root/'freeze_packet_v0_1/FF3_HEADERS_PROPOSED_v0_1.lean.txt').read_text(encoding='utf-8');section=h.split('-- FVLTRosetteFordSweepV1:')[1].split('-- FVLTRosetteFordEndpointsV1:')[0];header=section[section.index('theorem farey_consecutive_det'):].strip()
s+=header+r''' := by
  let x := (fareyList B).get ⟨k, hk0⟩
  let y := (fareyList B).get ⟨k + 1, hk1⟩
  change (x.den : ℤ) * y.num - x.num * (y.den : ℤ) = 1
  have hsort : StrictMono (fareyList B).get := (fareyList_strict B hB).sortedLT
  have hxy : x < y := hsort (show (⟨k, hk0⟩ : Fin (fareyList B).length) < ⟨k + 1, hk1⟩ from Nat.lt_succ_self k)
  have hxm : x ∈ fareySet B := (fareyList_membership B hB x).mp (List.get_mem _ _)
  have hym : y ∈ fareySet B := (fareyList_membership B hB y).mp (List.get_mem _ _)
  have hy1 : y ≤ 1 := ((mem_fareySet B hB y).mp hym).2.1
  have hx1 : x < 1 := hxy.trans_le hy1
  rcases exists_bounded_successor B hB x hxm hx1 with ⟨w, hwm, hxw, hdet, hlarge⟩
  have hnext (z : ℚ) (hzm : z ∈ fareySet B) (hxz : x < z) : y ≤ z := by
    have hzin : z ∈ fareyList B := (fareyList_membership B hB z).mpr hzm
    rcases List.mem_iff_getElem.mp hzin with ⟨i, hi, he⟩
    have heget : (fareyList B).get ⟨i, hi⟩ = z := he
    have hki : (⟨k, hk0⟩ : Fin (fareyList B).length) < ⟨i, hi⟩ :=
      hsort.lt_iff_lt.mp (by simpa only [x, heget] using hxz)
    have hle : k + 1 ≤ i := by have hh : k < i := hki; omega
    have hh := hsort.monotone (show (⟨k + 1, hk1⟩ : Fin (fareyList B).length) ≤ ⟨i, hi⟩ from hle)
    simpa only [y, heget] using hh
  have hyw : y ≤ w := hnext w hwm hxw
  have hwy : w ≤ y := by
    by_contra hn
    have hywlt : y < w := lt_of_not_ge hn
    have hden := interval_denominator_bound x w y hdet hxy hywlt
    have hyB := ((mem_fareySet B hB y).mp hym).2.2
    omega
  have heq : y = w := le_antisymm hyw hwy
  simpa only [← heq] using hdet

end FVLT.PhasorFordV1
''';text(f,s);assert b'\r' not in f.read_bytes()
names=['FVLT.PhasorFordV1.'+m.group(1) for m in re.finditer(r'^theorem\s+(\w+)',s,re.M)];assert len(names)==9
text(new/'AuditRosetteFordSweepV1.lean','import FVLTRosetteFordSweepV1\n'+''.join('#print axioms '+n+'\n' for n in names))
ch=save('CAPACITY_BATCH06_FINAL03.json',{'observed_unix':1793787277,'available_mib':28276,'load':[.07,.03,0],'host':'nucleus','transport':'Tailscale [ts-redacted1]','owner':'01a18167-41de-74e0-882e-9171e642530f'})
b=json.loads((p/'BOUND_BATCH06.json').read_text());b.update(fresh_capacity_receipt_file='CAPACITY_BATCH06_FINAL03.json',fresh_capacity_receipt_sha256=ch);bh=save('BOUND_BATCH06_FINAL03.json',b)
c=json.loads((p/'COMPARE_FINAL02.json').read_text());c.update(source_sha256={f.name:sha(f) for f in sorted((new/'src').glob('*.lean'))},present_targets=names,axiom_report_targets=names,method='Eight prior Sweep bodies and two compiled private preparation helpers retained; private bounded-successor helper and exact ninth frozen header with proof appended; total five private helpers; dependencies bytes unchanged; UTF8LFnoBOM',header_comparison='All nine frozen Sweep headers unchanged LF')
co=save('COMPARE_FINAL03.json',c)
j=json.loads((p/'JOB_CompileFVLTRosetteFordSweepV1Batch06Final02.json').read_text());j.update(run_id='CompileFVLTRosetteFordSweepV1Batch06Final03',attempt_folder='attempts/Batch06Final03',template_sha256=bh,source_sha256=c['source_sha256'],signature_comparison_receipt_file='COMPARE_FINAL03.json',signature_comparison_receipt_sha256=co);j['prerequisite_receipt_sha256']['CompileFVLTRosetteFordSweepV1Batch06Final02.json']=sha(p/'CompileFVLTRosetteFordSweepV1Batch06Final02.json');jh=save('JOB_'+j['run_id']+'.json',j)
shutil.copyfile(p/'REVIEW_ACCEPTANCE.json',p/'REVIEW_ACCEPTANCE_PRE_FINAL03.json');r=json.loads((p/'REVIEW_ACCEPTANCE.json').read_text());r.update(bound_template_file='BOUND_BATCH06_FINAL03.json',bound_template_sha256=bh,accepted_job_sha256=[jh]);save('REVIEW_ACCEPTANCE.json',r)
print(json.dumps({'source':sha(f),'comparison':co,'job':jh,'bound':bh,'capacity':ch},indent=2))
