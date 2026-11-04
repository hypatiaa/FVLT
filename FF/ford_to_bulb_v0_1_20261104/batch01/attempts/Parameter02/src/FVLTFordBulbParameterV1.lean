import FVLTFordBulbDataV1
import Mathlib.Analysis.Calculus.Deriv.Add
open scoped BigOperators
namespace FVLT.FordBulbV1

theorem parameter_fixed_point (lambda : ℂ) :
    quadratic (cardioidParameter lambda) (alpha lambda) = alpha lambda := by
  unfold quadratic cardioidParameter alpha
  ring

theorem parameter_multiplier (lambda : ℂ) : quadraticMultiplier (alpha lambda) = lambda := by
  unfold quadraticMultiplier alpha
  ring

theorem parameter_derivative (lambda : ℂ) :
    HasDerivAt (fun z : ℂ => quadratic (cardioidParameter lambda) z) lambda (alpha lambda) := by
  have h : HasDerivAt (fun z : ℂ => z ^ 2 + cardioidParameter lambda)
      (2 * alpha lambda) (alpha lambda) := by
    simpa using (hasDerivAt_add_const_iff (cardioidParameter lambda)).2 (hasDerivAt_pow 2 (alpha lambda))
  have hm : (2 : ℂ) * alpha lambda = lambda := by unfold alpha; ring
  rw [hm] at h
  exact h

theorem canonical_multiplier_primitive (d : RotationAddress) :
    IsPrimitiveRoot (canonicalMultiplier d) d.q := by
  have he : canonicalMultiplier d =
      Complex.exp (2 * (Real.pi : ℂ) * Complex.I * ((d.p : ℂ) / (d.q : ℂ))) := by
    unfold canonicalMultiplier address
    congr 1
    push_cast
    ring
  rw [he]
  exact Complex.isPrimitiveRoot_exp_of_coprime d.p d.q
    (Nat.ne_of_gt (Nat.lt_trans d.p_pos d.p_lt_q)) d.coprime

end FVLT.FordBulbV1
