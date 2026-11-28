import DirectProgressions

namespace AtlasLog
open Finset MeasureTheory
noncomputable section

def longLength (M : ℕ) : ℝ := (M:ℝ)^(99/100:ℝ)

def windowMean (r : ℕ) (x H : ℝ) : ℝ := windowSum 12 r x H / H

/-- Restricted long-interval input just before (3.30), with one log saved. -/
def LongWindow12 : Prop := ∃ A : ℝ, 0<A ∧ ∃ M₀ : ℕ, ∀ M ≥ M₀,
  ∀ x ∈ Set.Icc (M:ℝ) (2*M), ∀ r ∈ residues,
    |windowMean r x (longLength M)| ≤ A / Real.log M

def scaledVariance (M h : ℕ) (x : ℝ) : ENNReal :=
  ∑ r ∈ residues, ENNReal.ofReal
    ((Real.log M * (windowMean r x h - windowMean r x (longLength M)))^2)

/-- Restricted version of the short-minus-long variance in (3.30).
The integrand includes two log factors, leaving one log on the right. -/
def ShortLong12 : Prop := ∃ C : ℝ, 0<C ∧ ∃ X₀ : ℕ, ∀ X ≥ X₀,
  let M := X/2
  ∫⁻ x in Set.Icc (M:ℝ) (2*M), scaledVariance M X.sqrt x
    ≤ ENNReal.ofReal (C*M/Real.log M)

theorem ap12_of_long_and_variance (long : LongWindow12) (variance : ShortLong12) :
    AP12Measure := by
  obtain ⟨A,ha,M₀,long⟩ := long
  obtain ⟨C,hc,X₀,variance⟩ := variance
  let K := 2*(A+C+1)
  refine ⟨K,by dsimp [K]; positivity,max (max 32 X₀) (2*M₀),?_⟩
  intro X hx
  have x32 : 32≤X := by omega
  let M := X/2
  let h := X.sqrt
  let band := Set.Icc (M:ℝ) (2*M)
  let bad := realBad X (K*h/Real.log X)
  have m0 : M₀ ≤ M := by dsimp [M]; omega
  obtain ⟨lm,lx⟩ := log_half_scale X x32
  change 0<Real.log M at lm
  change Real.log X ≤ 2*Real.log M at lx
  have lp : 0<Real.log X := Real.log_pos (by exact_mod_cast (show 1<X by omega))
  have hp : (0:ℝ)<h := by exact_mod_cast Nat.sqrt_pos.mpr (show 0<X by omega)
  have sub : bad ⊆ band := fun _ u => ⟨u.1,u.2.1⟩
  have point (x : ℝ) (xb : x ∈ bad) : 1 ≤ scaledVariance M h x := by
    obtain ⟨l,u,r,hr,big⟩ := xb
    have nonneg : 0≤x := (by positivity : 0≤(M:ℝ)).trans l
    have lbd := long M m0 x ⟨l,u⟩ r hr
    have ds : (A+1)*h/Real.log M ≤ K*h/Real.log X := by
      rw [div_le_div_iff₀ lm lp]
      dsimp [K]
      nlinarith [mul_le_mul_of_nonneg_left lx (show 0≤(A+1)*h by positivity),
        mul_nonneg (mul_nonneg hc.le hp.le) lm.le]
    have bs := ds.trans_lt big
    rw [←windowSum_nat r h nonneg] at bs
    have bmean : (A+1)/Real.log M < |windowMean r x h| := by
      unfold windowMean
      rw [abs_div,abs_of_pos hp,lt_div_iff₀ hp]
      convert bs using 1
      ring
    have tri := abs_add_le (windowMean r x h - windowMean r x (longLength M))
      (windowMean r x (longLength M))
    rw [sub_add_cancel] at tri
    have gap : 1/Real.log M < |windowMean r x h - windowMean r x (longLength M)| := by
      rw [add_div] at bmean
      linarith
    have raw := (div_lt_iff₀ lm).mp gap
    have one : (1:ℝ) ≤ (Real.log M*(windowMean r x h-windowMean r x (longLength M)))^2 := by
      have absone : 1 ≤ |Real.log M*(windowMean r x h-windowMean r x (longLength M))| := by
        rw [abs_mul,abs_of_pos lm,mul_comm]; exact raw.le
      simpa only [one_pow,sq_abs] using (sq_le_sq₀ (by norm_num) (abs_nonneg _)).mpr absone
    apply le_trans _ (Finset.single_le_sum (f:=fun r => ENNReal.ofReal
      ((Real.log M*(windowMean r x h-windowMean r x (longLength M)))^2)) (fun _ _ => zero_le) hr)
    simpa using ENNReal.ofReal_le_ofReal one
  have v : volume bad ≤ ∫⁻ x in band, scaledVariance M h x := calc
    _ = ∫⁻ _ in bad, (1:ENNReal) := by simp
    _ ≤ ∫⁻ x in bad, scaledVariance M h x := by
      have mb : MeasurableSet bad := by
        let S : Set ℕ := {t | ∃ r ∈ residues, K*h/Real.log X < |apSum r t h|}
        have same : bad = band ∩ ((fun x : ℝ => ⌊x⌋₊) ⁻¹' S) := by
          ext x; exact and_assoc.symm
        rw [same]
        exact measurableSet_Icc.inter ((by fun_prop : Measurable (fun x : ℝ => ⌊x⌋₊))
          MeasurableSet.of_discrete)
      exact setLIntegral_mono' mb point
    _ ≤ _ := lintegral_mono_set sub
  apply v.trans ((variance X (by omega)).trans (ENNReal.ofReal_le_ofReal ?_))
  rw [div_le_div_iff₀ lm lp]
  have mx : (M:ℝ) ≤ X := by exact_mod_cast Nat.div_le_self X 2
  dsimp [K]
  nlinarith [mul_le_mul_of_nonneg_left lx (show 0≤C*M by positivity),
    mul_le_mul_of_nonneg_right mx (show 0≤C*Real.log M by positivity),
    mul_nonneg (show 0≤(A+1)*(X:ℝ) by positivity) lm.le]

end
end AtlasLog
