import FVLT.PenGaussV1
import Verified

/-!
# Mertens criterion in terms of pen endpoints

This optional module uses the arithmetic–Fourier v2.6.4 analytic library.
-/

namespace FVLT.PenGaussV1

open RHConnections.ArithmeticFourierInversion RHConnections.MertensCriterion

/-- The complex sum of frequency-one endpoints is the real Mertens sum
viewed in the complex plane. -/
theorem sum_pen_frequency_one_eq_M (X : ℕ) :
    (∑ N ∈ Finset.Ioc 0 X, pen (1 : DirichletCharacter ℂ N) 1) = (M X : ℂ) := by
  rw [sum_pen_frequency_one, M, Complex.ofReal_sum]
  refine Finset.sum_congr rfl (fun N _ => ?_)
  change (ArithmeticFunction.moebius N : ℂ) = ((ArithmeticFunction.moebius N : ℝ) : ℂ)
  simp

/-- The classical Mertens power bound, written for the frequency-one pen sum. -/
theorem sum_pen_frequency_one_growth_iff_RH :
    (∀ ε : ℝ, 0 < ε → ∃ C : ℝ, 0 ≤ C ∧ ∀ X : ℕ, 1 ≤ X →
      ‖∑ N ∈ Finset.Ioc 0 X, pen (1 : DirichletCharacter ℂ N) 1‖ ≤
        C * (X : ℝ) ^ (1 / 2 + ε)) ↔ RiemannHypothesis := by
  simp only [sum_pen_frequency_one_eq_M, Complex.norm_real, Real.norm_eq_abs]
  exact ⟨fun h => riemannHypothesis_of_mertens (mertensCancellation_of_natural_power_bounds h),
    natural_mertens_bounds_of_RH⟩

end FVLT.PenGaussV1

#print axioms FVLT.PenGaussV1.sum_pen_frequency_one_eq_M
#print axioms FVLT.PenGaussV1.sum_pen_frequency_one_growth_iff_RH
