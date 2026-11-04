import Mathlib.Analysis.SpecialFunctions.Complex.CircleAddChar
import Mathlib.Tactic

/-!
Declared successor reflection in the Y axis of the chosen complex plane:
R_y(z)=-star z. This is real-linear and conjugate-linear over C, not the
complex-linear half-turn z -> -z. No old kernel, chi, or viewer identification
is asserted or edited by this module.
-/
noncomputable section
namespace FVLT.YReflectionV1

def reflect (z : ℂ) : ℂ := -star z

@[simp] theorem reflect_re (z : ℂ) : (reflect z).re = -z.re := by
  simp [reflect, Complex.star_def]

@[simp] theorem reflect_im (z : ℂ) : (reflect z).im = z.im := by
  simp [reflect, Complex.star_def]

@[simp] theorem reflect_zero : reflect 0 = 0 := by simp [reflect]

@[simp] theorem reflect_one : reflect 1 = -1 := by simp [reflect]

@[simp] theorem reflect_I : reflect Complex.I = Complex.I := by
  simp [reflect, Complex.star_def]

theorem reflect_involutive : Function.Involutive reflect := by
  intro z
  simp [reflect]

@[simp] theorem reflect_reflect (z : ℂ) : reflect (reflect z) = z :=
  reflect_involutive z

@[simp] theorem reflect_norm (z : ℂ) : ‖reflect z‖ = ‖z‖ := by
  simp [reflect]

theorem reflect_normSq (z : ℂ) : Complex.normSq (reflect z) = Complex.normSq z := by
  simp [Complex.normSq_eq_norm_sq]

theorem reflect_add (z w : ℂ) : reflect (z + w) = reflect z + reflect w := by
  simp only [reflect, star_add]
  ring

theorem reflect_sub (z w : ℂ) : reflect (z - w) = reflect z - reflect w := by
  simp only [reflect, star_sub]
  ring

/-- A complex coefficient is conjugated; this is not complex-linear scalar transport. -/
theorem reflect_mul (c z : ℂ) : reflect (c * z) = star c * reflect z := by
  simp only [reflect, star_mul]
  ring

theorem reflect_complex_smul (c z : ℂ) : reflect (c • z) = star c • reflect z :=
  reflect_mul c z

theorem reflect_real_smul (c : ℝ) (z : ℂ) : reflect (c • z) = c • reflect z := by
  simp [reflect, star_smul, smul_neg]

def realLinearEquiv : ℂ ≃ₗ[ℝ] ℂ where
  toFun := reflect
  invFun := reflect
  left_inv := reflect_reflect
  right_inv := reflect_reflect
  map_add' := reflect_add
  map_smul' := reflect_real_smul

theorem reflect_ne_zero_iff (z : ℂ) : reflect z ≠ 0 ↔ z ≠ 0 := by
  constructor
  · intro h hz
    exact h (by simp [hz])
  · intro h hz
    apply h
    have he := congrArg reflect hz
    simpa only [reflect_reflect, reflect_zero] using he

/-- Equality with the old half-turn occurs exactly on the real axis. -/
theorem reflect_eq_neg_iff_im_zero (z : ℂ) : reflect z = -z ↔ z.im = 0 := by
  constructor
  · intro h
    have hi := congrArg Complex.im h
    rw [reflect_im, Complex.neg_im] at hi
    linarith
  · intro hi
    apply Complex.ext <;> simp [hi]

theorem reflect_not_conjugation : reflect ≠ (fun z : ℂ => star z) := by
  intro h
  have he := congrFun h 1
  norm_num at he

theorem reflect_not_complex_linear :
    ¬ ∃ L : ℂ →ₗ[ℂ] ℂ, ∀ z, L z = reflect z := by
  rintro ⟨L, h⟩
  have hI : L Complex.I = Complex.I := by rw [h, reflect_I]
  have h1 : L 1 = -1 := by rw [h, reflect_one]
  have he := L.map_smul Complex.I (1 : ℂ)
  simp only [smul_eq_mul, mul_one, hI, h1, mul_neg] at he
  have hi := congrArg Complex.im he
  norm_num at hi

/-- Both minus signs cancel in a common reflection of a quotient; the ratio conjugates. -/
theorem reflect_quotient (z w : ℂ) (_hw : w ≠ 0) :
    reflect z / reflect w = star (z / w) := by
  simp only [reflect, neg_div_neg_eq, star_div₀]

/-- Individual angular phase theta goes to pi-theta, rather than merely -theta. -/
theorem reflect_exp (theta : ℝ) :
    reflect (Complex.exp ((theta : ℂ) * Complex.I)) =
      Complex.exp (((Real.pi - theta : ℝ) : ℂ) * Complex.I) := by
  apply Complex.ext <;>
    simp [reflect, Complex.star_def, Complex.exp_re, Complex.exp_im,
      Real.cos_pi_sub, Real.sin_pi_sub]

theorem reflect_exp_pi (x : ℝ) :
    reflect (Complex.exp (((Real.pi * x : ℝ) : ℂ) * Complex.I)) =
      Complex.exp (((Real.pi * (1 - x) : ℝ) : ℂ) * Complex.I) := by
  simpa only [show Real.pi - Real.pi * x = Real.pi * (1 - x) by ring]
    using reflect_exp (Real.pi * x)

end FVLT.YReflectionV1
