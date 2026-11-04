import FVLTHelixGearboxV1

/-! A new finite centered-offset family with its own proof standing. No result
from the m>=3 companion extension is imported or promoted. -/
noncomputable section
namespace FVLT.MCombHelixV1
open HelixFrameV1 HelixGearboxV1
open scoped BigOperators

def offset (m : ℕ) (j : Fin m) : ℤ :=
  if m%2=0 then 2*(j.val : ℤ)+1-(m : ℤ) else (j.val : ℤ)-(m/2 : ℕ)
def reverseIndex {m : ℕ} (j : Fin m) : Fin m := ⟨m-1-j.val,by omega⟩
def offsets (m : ℕ) : Finset ℤ := Finset.univ.image (offset m)

theorem offset_injective (m : ℕ) : Function.Injective (offset m) := by
  intro i j he
  apply Fin.ext
  unfold offset at he
  split_ifs at he <;> omega
theorem offsets_card (m : ℕ) : (offsets m).card=m := by
  classical
  rw [offsets,Finset.card_image_of_injective _ (offset_injective m)]
  simp
theorem offset_reverse (m : ℕ) (j : Fin m) : offset m (reverseIndex j)= -offset m j := by
  have hj := j.isLt
  by_cases h : m%2=0
  · simp only [offset,h,ite_true,reverseIndex]
    omega
  · simp only [offset,h,ite_false,reverseIndex]
    omega
theorem neg_mem_offsets (m : ℕ) (c : ℤ) (hc : c∈offsets m) : -c∈offsets m := by
  rcases Finset.mem_image.mp hc with ⟨j,hj,rfl⟩
  exact Finset.mem_image.mpr ⟨reverseIndex j,Finset.mem_univ _,offset_reverse m j⟩
theorem neg_mem_offsets_iff (m : ℕ) (c : ℤ) : -c∈offsets m ↔ c∈offsets m := by
  constructor
  · intro h
    simpa using neg_mem_offsets m (-c) h
  · exact neg_mem_offsets m c
theorem offsets_two : offsets 2={-1,1} := by decide
theorem offsets_three : offsets 3={-1,0,1} := by decide
theorem offsets_four : offsets 4={-3,-1,1,3} := by decide
theorem even_comb_excludes_zero (m : ℕ) (he : m%2=0) : 0∉offsets m := by
  intro hz
  rcases Finset.mem_image.mp hz with ⟨j,hj,ho⟩
  simp only [offset,he,ite_true] at ho
  omega
theorem odd_comb_contains_zero (m : ℕ) (ho : m%2=1) : 0∈offsets m := by
  have hm : m/2<m := by omega
  refine Finset.mem_image.mpr ⟨⟨m/2,hm⟩,Finset.mem_univ _,?_⟩
  simp [offset,show m%2≠0 by omega]

def family (m : ℕ) (N t1 t2 h s : ℝ) (j : Fin m) : Pose :=
  walk N t1 t2 h (offset m j) s
def coherent (m : ℕ) (N t1 t2 : ℝ) (w : ℤ → ℂ) (s : ℝ) : ℂ :=
  ∑ c ∈ offsets m, w c*branch N t1 t2 c s

theorem family_walk (m : ℕ) (N t1 t2 h s u : ℝ) (j : Fin m) :
    family m N t1 t2 h (s+u) j=
      twist (alpha t1*u) (advance (beta N t2 (offset m j)*u) (h*u)
        (family m N t1 t2 h s j)) :=
  walker_increment N t1 t2 h (offset m j) s u

theorem coherent_factor (m : ℕ) (N t1 t2 : ℝ) (w : ℤ → ℂ) (s : ℝ) :
    coherent m N t1 t2 w s=phase (alpha t1*s)*
      ∑ c ∈ offsets m, w c*phase (Real.pi*s*(c : ℝ)*t2/N) := by
  unfold coherent
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro c hc
  rw [branch_factor]
  ring

theorem coherent_increment (m : ℕ) (N t1 t2 : ℝ) (w : ℤ → ℂ) (s u : ℝ) :
    coherent m N t1 t2 w (s+u)=
      ∑ c ∈ offsets m, w c*branch N t1 t2 c s*branch N t1 t2 c u := by
  unfold coherent
  apply Finset.sum_congr rfl
  intro c hc
  rw [branch_increment]
  ring

theorem coherent_chart (m : ℕ) (N t1 t2 h a b s : ℝ) (hb : b≠0) (w : ℤ → ℂ) :
    (∑ c ∈ offsets m, w c*CliffordGeometryV1.chart (lift a b (walk N t1 t2 h c s)))=
      ((a/b : ℝ) : ℂ)*coherent m N t1 t2 w s := by
  unfold coherent
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro c hc
  rw [chart_walk N t1 t2 h a b hb]
  ring

theorem coherent_two (N t1 t2 : ℝ) (w : ℤ → ℂ) (s : ℝ) :
    coherent 2 N t1 t2 w s=
      w (-1)*branch N t1 t2 (-1) s+w 1*branch N t1 t2 1 s := by
  simp [coherent,offsets_two]

/-- Explicit real cross term, never the complex bilinear square. -/
theorem two_branch_interference (z w : ℂ) :
    Complex.normSq (z+w)=Complex.normSq z+Complex.normSq w+
      2*(z.re*w.re+z.im*w.im) := by
  simp only [Complex.normSq_apply,Complex.add_re,Complex.add_im]
  ring

end FVLT.MCombHelixV1
