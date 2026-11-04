import FVLTYReflectionV1
import Mathlib.Tactic

/-!
Additive successor convention: a negative n6 selects y-axis reflection of the
positive-orientation point. The reflection is -star, not point negation.
The real scale is explicit and can later be instantiated by a positive radial
power. No previous N6 mirror, locked kernel, or viewer is modified here.
-/
namespace FVLT.N6OrientationV1
noncomputable section
open YReflectionV1

def point (scale n6 : ℝ) (u : ℂ) : ℂ :=
  if n6 < 0 then -((|n6| *scale : ℝ) : ℂ)*star u
  else ((|n6| *scale : ℝ) : ℂ)*u

theorem point_zero (scale : ℝ) (u : ℂ) : point scale 0 u=0 := by
  simp [point]

theorem point_zero_scale (n6 : ℝ) (u : ℂ) : point 0 n6 u=0 := by
  by_cases h : n6<0 <;> simp [point,h]

theorem point_zero_phase (scale n6 : ℝ) : point scale n6 0=0 := by
  by_cases h : n6<0 <;> simp [point,h]

/-- Nonnegative n6 retains the old signed-scalar formula. -/
theorem point_of_nonneg (scale n6 : ℝ) (u : ℂ) (hn : 0≤n6) :
    point scale n6 u=((n6*scale : ℝ) : ℂ)*u := by
  simp [point, not_lt.mpr hn, abs_of_nonneg hn]

theorem point_of_pos (scale n6 : ℝ) (u : ℂ) (hn : 0<n6) :
    point scale n6 u=((n6*scale : ℝ) : ℂ)*u :=
  point_of_nonneg scale n6 u (le_of_lt hn)

theorem point_of_neg (scale n6 : ℝ) (u : ℂ) (hn : n6<0) :
    point scale n6 u=-(((-n6)*scale : ℝ) : ℂ)*star u := by
  simp [point,hn,abs_of_neg hn]

/-- The negative branch is a signed scalar times the conjugated phase. -/
theorem point_of_neg_signed_conjugate (scale n6 : ℝ) (u : ℂ) (hn : n6<0) :
    point scale n6 u=((n6*scale : ℝ) : ℂ)*star u := by
  rw [point_of_neg scale n6 u hn]
  push_cast
  ring

theorem point_of_neg_reflect_abs (scale n6 : ℝ) (u : ℂ) (hn : n6<0) :
    point scale n6 u=reflect (((|n6| *scale : ℝ) : ℂ)*u) := by
  simp [point,hn,reflect]

/-- Valid at every n6, including the zero branch. -/
theorem point_sign_flip (scale n6 : ℝ) (u : ℂ) :
    point scale (-n6) u=reflect (point scale n6 u) := by
  rcases lt_trichotomy n6 0 with hn | hz | hp
  · have hneg : ¬ -n6<0 := by linarith
    simp [point,hn,hneg,reflect,abs_neg]
  · subst n6
    simp [point,reflect]
  · have hnon : ¬ n6<0 := by linarith
    have hneg : -n6<0 := by linarith
    simp [point,hnon,hneg,reflect,abs_neg]

theorem point_negative_reflect_positive (scale r : ℝ) (u : ℂ) (_hr : 0≤r) :
    point scale (-r) u=reflect (point scale r u) :=
  point_sign_flip scale r u

theorem norm_point (scale n6 : ℝ) (u : ℂ) :
    ‖point scale n6 u‖=|n6| *|scale| *‖u‖ := by
  unfold point
  split_ifs <;> simp [norm_mul, Complex.norm_real, Real.norm_eq_abs, abs_mul]

theorem point_ne_zero_iff (scale n6 : ℝ) (u : ℂ) :
    point scale n6 u≠0 ↔ n6≠0 ∧ scale≠0 ∧ u≠0 := by
  rw [← norm_ne_zero_iff, norm_point]
  simp only [mul_ne_zero_iff, abs_ne_zero, norm_ne_zero_iff, and_assoc]

theorem point_ne_zero (scale n6 : ℝ) (u : ℂ)
    (hn : n6≠0) (hs : scale≠0) (hu : u≠0) : point scale n6 u≠0 :=
  (point_ne_zero_iff scale n6 u).mpr ⟨hn,hs,hu⟩

/-- Conjugation is essential off the real axis: the successor negative branch
agrees with the old signed-scalar point exactly when the phase is real. -/
theorem negative_agrees_old_iff (scale n6 : ℝ) (u : ℂ)
    (hn : n6<0) (hs : scale≠0) :
    point scale n6 u=((n6*scale : ℝ) : ℂ)*u ↔ star u=u := by
  rw [point_of_neg_signed_conjugate scale n6 u hn]
  have hc : ((n6*scale : ℝ) : ℂ)≠0 := by
    exact_mod_cast mul_ne_zero (ne_of_lt hn) hs
  exact ⟨fun h => mul_left_cancel₀ hc h,
    fun h => congrArg (fun z : ℂ => ((n6*scale : ℝ) : ℂ)*z) h⟩

end
end FVLT.N6OrientationV1
