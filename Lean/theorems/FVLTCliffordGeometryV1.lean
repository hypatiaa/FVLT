import Mathlib.Analysis.SpecialFunctions.Complex.CircleAddChar
import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Tactic

/-!
Two finite arithmetic clocks on the equal-radius Clifford torus.
The ambient norm is the native Euclidean L2 norm on C^2, not a product max norm.
The chart equalities are explicit quotient calculations, not a classification
of all Hopf fibres or an identification with an existing kernel realization.
-/
namespace FVLT.CliffordGeometryV1
noncomputable section

def clock (n : ℕ) [NeZero n] (t : ℤ) : ℂ :=
  ZMod.stdAddChar (t : ZMod n)

@[simp] theorem clock_norm (n : ℕ) [NeZero n] (t : ℤ) : ‖clock n t‖ = 1 := by
  simp [clock,ZMod.stdAddChar_apply]

@[simp] theorem clock_normSq (n : ℕ) [NeZero n] (t : ℤ) :
    Complex.normSq (clock n t) = 1 := by
  simp [clock,ZMod.stdAddChar_apply]

theorem clock_ne_zero (n : ℕ) [NeZero n] (t : ℤ) : clock n t ≠ 0 := by
  simp [clock,ZMod.stdAddChar_apply]

theorem clock_eq_iff (n : ℕ) [NeZero n] (t u : ℤ) :
    clock n t = clock n u ↔ (t : ZMod n) = (u : ZMod n) := by
  exact ZMod.injective_stdAddChar.eq_iff

def cliffordScale : ℝ := 1 / Real.sqrt 2

theorem cliffordScale_pos : 0 < cliffordScale := by
  unfold cliffordScale
  exact div_pos (by norm_num) (Real.sqrt_pos.mpr (by norm_num))

theorem cliffordScale_complex_ne_zero : (cliffordScale : ℂ) ≠ 0 := by
  exact_mod_cast ne_of_gt cliffordScale_pos

theorem cliffordScale_sq : cliffordScale ^ 2 = (1/2 : ℝ) := by
  unfold cliffordScale
  rw [div_pow,one_pow,Real.sq_sqrt (by norm_num : (0 : ℝ) ≤ 2)]

theorem cliffordScale_normSq : Complex.normSq (cliffordScale : ℂ) = (1/2 : ℝ) := by
  rw [Complex.normSq_ofReal,← pow_two]
  exact cliffordScale_sq

abbrev Space := EuclideanSpace ℂ (Fin 2)

def gamma (P Q : ℕ) [NeZero P] [NeZero Q] (t : ℤ) : Space :=
  !₂[(cliffordScale : ℂ)*clock P t, (cliffordScale : ℂ)*clock Q t]

@[simp] theorem gamma_zero (P Q : ℕ) [NeZero P] [NeZero Q] (t : ℤ) :
    gamma P Q t 0 = (cliffordScale : ℂ)*clock P t := rfl

@[simp] theorem gamma_one (P Q : ℕ) [NeZero P] [NeZero Q] (t : ℤ) :
    gamma P Q t 1 = (cliffordScale : ℂ)*clock Q t := rfl

@[simp] theorem gamma_first_normSq (P Q : ℕ) [NeZero P] [NeZero Q] (t : ℤ) :
    Complex.normSq (gamma P Q t 0) = (1/2 : ℝ) := by
  rw [gamma_zero,Complex.normSq_mul,clock_normSq,mul_one,cliffordScale_normSq]

@[simp] theorem gamma_second_normSq (P Q : ℕ) [NeZero P] [NeZero Q] (t : ℤ) :
    Complex.normSq (gamma P Q t 1) = (1/2 : ℝ) := by
  rw [gamma_one,Complex.normSq_mul,clock_normSq,mul_one,cliffordScale_normSq]

theorem gamma_total_normSq (P Q : ℕ) [NeZero P] [NeZero Q] (t : ℤ) :
    Complex.normSq (gamma P Q t 0)+Complex.normSq (gamma P Q t 1) = 1 := by
  rw [gamma_first_normSq,gamma_second_normSq]
  norm_num

theorem euclidean_norm_sq (z : Space) :
    ‖z‖ ^ 2 = Complex.normSq (z 0)+Complex.normSq (z 1) := by
  simp only [EuclideanSpace.norm_sq_eq,Fin.sum_univ_two,Complex.sq_norm]

theorem gamma_norm (P Q : ℕ) [NeZero P] [NeZero Q] (t : ℤ) :
    ‖gamma P Q t‖ = 1 := by
  have h : ‖gamma P Q t‖ ^ 2 = (1 : ℝ) ^ 2 := by
    rw [euclidean_norm_sq,gamma_total_normSq]
    norm_num
  exact (sq_eq_sq₀ (norm_nonneg _) (by norm_num : (0 : ℝ) ≤ 1)).mp h

def chart (z : Space) : ℂ := z 0 / z 1

theorem gamma_second_ne_zero (P Q : ℕ) [NeZero P] [NeZero Q] (t : ℤ) :
    gamma P Q t 1 ≠ 0 := by
  rw [gamma_one]
  exact mul_ne_zero cliffordScale_complex_ne_zero (clock_ne_zero Q t)

theorem chart_gamma (P Q : ℕ) [NeZero P] [NeZero Q] (t : ℤ) :
    chart (gamma P Q t) = clock P t / clock Q t := by
  change ((cliffordScale : ℂ)*clock P t) /
    ((cliffordScale : ℂ)*clock Q t) = clock P t / clock Q t
  exact mul_div_mul_left _ _ cliffordScale_complex_ne_zero

theorem chart_smul (c : ℂ) (hc : c ≠ 0) (z : Space) :
    chart (c • z) = chart z := by
  change (c*z 0)/(c*z 1) = z 0/z 1
  exact mul_div_mul_left _ _ hc

theorem chart_gamma_common_phase (c : ℂ) (hc : c ≠ 0)
    (P Q : ℕ) [NeZero P] [NeZero Q] (t : ℤ) :
    chart (c • gamma P Q t) = clock P t/clock Q t := by
  rw [chart_smul c hc,chart_gamma]

end
end FVLT.CliffordGeometryV1
