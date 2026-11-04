import FVLTFareyContactV1
import Mathlib.Analysis.Complex.Norm
import Mathlib.Data.Rat.Cast.Defs
import Mathlib.Tactic

/-!
FF-1 F1: distance identity and kiss membership, not uniqueness.
Classical Ford geometry; framework assembled by Robin Miller.
-/
namespace FVLT.FordGeometryV1
open FVLT.FareyContactV1

def radius (x : ℚ) : ℝ := 1 / (2 * (x.den : ℝ)^2)
def centre (x : ℚ) : ℂ := (x : ℂ) + (radius x : ℂ) * Complex.I
def boundary (x : ℚ) : Set ℂ := {z | ‖z - centre x‖ = radius x}
def kissN (x y : ℚ) : ℤ := x.num * (x.den : ℤ) + y.num * (y.den : ℤ)
def kissM (x y : ℚ) : ℕ := x.den^2 + y.den^2
def kiss (x y : ℚ) : ℂ :=
  ((kissN x y : ℂ) + Complex.I) / (kissM x y : ℂ)

theorem radius_pos (x : ℚ) : 0 < radius x := by
  have hx : (0 : ℝ) < x.den := by exact_mod_cast x.den_pos
  unfold radius
  positivity

theorem ford_distance_identity (x y : ℚ) (hne : x ≠ y) :
  ‖centre x - centre y‖^2 - (radius x + radius y)^2 =
    (((det x y : ℤ) : ℝ)^2 - 1) /
      ((x.den : ℝ)^2 * (y.den : ℝ)^2) := by
  have hq : (x.den : ℝ) ≠ 0 := by exact_mod_cast x.den_ne_zero
  have hs : (y.den : ℝ) ≠ 0 := by exact_mod_cast y.den_ne_zero
  rw [Complex.sq_norm]
  simp [centre, radius, Complex.normSq_apply, Rat.cast_def, det]
  push_cast
  field_simp [hq, hs]
  <;> ring

theorem kiss_membership (x y : ℚ) (h : fareyAdj x y) :
  kiss x y ∈ boundary x ∧ kiss x y ∈ boundary y := by
  have hDint : (det x y)^2 = 1 := by
    have hh : |det x y| = 1 := h
    nlinarith [sq_abs (det x y)]
  have hD : ((det x y : ℤ) : ℝ)^2 = 1 := by exact_mod_cast hDint
  have at_left : ∀ u v : ℚ, ((det u v : ℤ) : ℝ)^2 = 1 →
      kiss u v ∈ boundary u := by
    intro u v huv
    have hq : (u.den : ℝ) ≠ 0 := by exact_mod_cast u.den_ne_zero
    have hs : (v.den : ℝ) ≠ 0 := by exact_mod_cast v.den_ne_zero
    have hmpos : (0 : ℝ) < (u.den : ℝ)^2 + (v.den : ℝ)^2 := by
      nlinarith [sq_pos_of_ne_zero hq, sq_nonneg (v.den : ℝ)]
    have hm : (u.den : ℝ)^2 + (v.den : ℝ)^2 ≠ 0 := ne_of_gt hmpos
    have identity : ‖kiss u v - centre u‖^2 - (radius u)^2 =
        (v.den : ℝ)^2 * (((det u v : ℤ) : ℝ)^2 - 1) /
          (((u.den : ℝ)^2 + (v.den : ℝ)^2)^2 * (u.den : ℝ)^2) := by
      rw [Complex.sq_norm]
      simp [kiss, kissN, kissM, centre, radius, Complex.normSq_apply,
        Complex.div_re, Complex.div_im, Rat.cast_def, det]
      push_cast
      field_simp [hq, hs, hm]
      <;> ring
    rw [huv] at identity
    have hp := radius_pos u
    have hn := norm_nonneg (kiss u v - centre u)
    change ‖kiss u v - centre u‖ = radius u
    nlinarith
  have hswap : det y x = -det x y := by unfold det; ring
  have hDy : ((det y x : ℤ) : ℝ)^2 = 1 := by
    rw [hswap]
    push_cast
    nlinarith
  have hkiss : kiss y x = kiss x y := by
    simp [kiss, kissN, kissM, add_comm]
  constructor
  · exact at_left x y hD
  · rw [← hkiss]
    exact at_left y x hDy

#print axioms FVLT.FordGeometryV1.radius_pos
#print axioms FVLT.FordGeometryV1.ford_distance_identity
#print axioms FVLT.FordGeometryV1.kiss_membership
end FVLT.FordGeometryV1
