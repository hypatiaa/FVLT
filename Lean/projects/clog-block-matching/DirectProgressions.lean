import ExceptionalTransfer

namespace AtlasLog
open Finset MeasureTheory ArithmeticFunction
open scoped ArithmeticFunction.Moebius
noncomputable section

/-- The complete residue slice of the real interval (x,x+H]. -/
def windowSum (q r : ℕ) (x H : ℝ) : ℝ :=
  ∑ n ∈ Ioc ⌊x⌋₊ ⌊x+H⌋₊, if n%q=r then (μ n : ℝ) else 0

theorem windowSum_nat (r h : ℕ) {x : ℝ} (hx : 0≤x) :
    windowSum 12 r x h = apSum r ⌊x⌋₊ h := by
  simp [windowSum, apSum, Nat.floor_add_natCast hx]

/-- An immediate paper specialization of 1.1(i): constant observable, A=1,
ε=1/12, complete residue slices only. E is shared by the progressions. -/
def ConstantProgressionEstimate : Prop :=
  ∃ C : ℝ, 0<C ∧ ∃ M₀ : ℕ, ∀ M ≥ M₀, ∀ h : ℕ,
    (M:ℝ)^(5/12:ℝ) ≤ h → (h:ℝ) ≤ (M:ℝ)^(11/12:ℝ) →
    ∃ E : Set ℝ, volume E ≤ ENNReal.ofReal (C*M/Real.log M) ∧
      ∀ x ∈ Set.Icc (M:ℝ) (2*M), x ∉ E → ∀ q : ℕ, 0<q → ∀ r : ℕ, r<q →
        |windowSum q r x h| ≤ C*h/Real.log M

theorem sqrt_window_range (X : ℕ) (hx : 32≤X) :
    ((X/2:ℕ):ℝ)^(5/12:ℝ) ≤ X.sqrt ∧ (X.sqrt:ℝ) ≤ ((X/2:ℕ):ℝ)^(11/12:ℝ) := by
  let M := X/2
  have hm : 16≤M := by dsimp [M]; omega
  have hs : 5≤X.sqrt := Nat.le_sqrt.mpr (by omega)
  have s := Nat.lt_succ_sqrt X
  have sm := Nat.sqrt_le X
  have mx : X ≤ 3*M := by dsimp [M]; omega
  have two : 2*M ≤ X := by dsimp [M]; omega
  have ms : M ≤ X.sqrt ^ 2 := by nlinarith
  have mr : (1:ℝ) ≤ M := by exact_mod_cast (show 1 ≤ M by omega)
  have lo := Real.rpow_le_rpow (show (0:ℝ)≤M by positivity)
    (show (M:ℝ)≤(X.sqrt:ℝ)^2 by exact_mod_cast ms) (by norm_num : (0:ℝ)≤1/2)
  have upper : X.sqrt ^ 4 ≤ M^3 := calc
    _ = (X.sqrt*X.sqrt)^2 := by ring
    _ ≤ (3*M)^2 := Nat.pow_le_pow_left (sm.trans mx) 2
    _ ≤ M^3 := by nlinarith [Nat.mul_le_mul_right (M*M) (show 9≤M by omega)]
  have hi := Real.rpow_le_rpow (by positivity : (0:ℝ)≤(X.sqrt:ℝ)^4)
    (show (X.sqrt:ℝ)^4≤(M:ℝ)^3 by exact_mod_cast upper) (by norm_num : (0:ℝ)≤1/4)
  rw [←Real.rpow_natCast,←Real.rpow_mul (by positivity)] at lo
  norm_num at lo
  simp only [←Real.rpow_natCast,←Real.rpow_mul (by positivity : (0:ℝ)≤X.sqrt),
    ←Real.rpow_mul (by positivity : (0:ℝ)≤M)] at hi
  norm_num at hi
  exact ⟨(Real.rpow_le_rpow_of_exponent_le mr (by norm_num : (5/12:ℝ)≤1/2)).trans lo,
    hi.trans (Real.rpow_le_rpow_of_exponent_le mr (by norm_num))⟩

theorem log_half_scale (X : ℕ) (hx : 32≤X) :
    0 < Real.log (X/2:ℕ) ∧ Real.log X ≤ 2*Real.log (X/2:ℕ) := by
  let M := X/2
  have m : 16≤M := by dsimp [M]; omega
  have xl : X ≤ 3*M := by dsimp [M]; omega
  have l := Real.log_le_log (by positivity : 0<(X:ℝ))
    (show (X:ℝ) ≤ (M:ℝ)^2 by exact_mod_cast (show X≤M^2 by nlinarith))
  rw [Real.log_pow] at l
  exact ⟨Real.log_pos (by exact_mod_cast (show 1<M by omega)),by simpa using l⟩

theorem ap12_of_constant_progressions (H : ConstantProgressionEstimate) : AP12Measure := by
  obtain ⟨C,hC,M₀,H⟩ := H
  refine ⟨2*C,by positivity,max 32 (2*M₀),?_⟩
  intro X hx
  have x32 := (le_max_left 32 (2*M₀)).trans hx
  have m0 : M₀ ≤ X/2 := by omega
  obtain ⟨low,high⟩ := sqrt_window_range X x32
  obtain ⟨E,size,good⟩ := H _ m0 _ low high
  obtain ⟨lp,lx⟩ := log_half_scale X x32
  have xp : 0<Real.log X := Real.log_pos (by exact_mod_cast (show 1<X by omega))
  have scale (y : ℝ) (hy : 0≤y) :
      C*y/Real.log (X/2:ℕ) ≤ 2*C*y/Real.log X := by
    rw [div_le_div_iff₀ lp xp]
    nlinarith [mul_le_mul_of_nonneg_left lx (show 0≤C*y by positivity)]
  have sub : realBad X (2*C*X.sqrt/Real.log X) ⊆ E := by
    intro x hx'
    obtain ⟨a,b,r,hr,large⟩ := hx'
    by_contra he
    have rr : r<12 := by simp [residues] at hr; omega
    have g := good x ⟨a,b⟩ he 12 (by decide) r rr
    rw [windowSum_nat r _ ((by positivity : 0≤(↑(X/2:ℕ):ℝ)).trans a)] at g
    exact (not_lt_of_ge (g.trans (scale _ (by positivity)))) large
  apply (measure_mono sub).trans (size.trans (ENNReal.ofReal_le_ofReal ?_))
  apply (scale _ (by positivity)).trans
  exact div_le_div_of_nonneg_right (mul_le_mul_of_nonneg_left
    (by exact_mod_cast Nat.div_le_self X 2) (by positivity)) xp.le

end
end AtlasLog
