import FVLT.PenGaussCore
import FVLT.PenGaussPrime
import FVLT.PenGaussRamanujan

/-! The finite arithmetic–Fourier endpoint, its character laws, and divisor combs. -/

namespace FVLT.PenGaussV1

/-- At frequency one the primitive pen on an individual modulus reads its Möbius coefficient. -/
theorem pen_one_frequency_one {N : ℕ} (hN : 0 < N) :
    pen (1 : DirichletCharacter ℂ N) 1 = (ArithmeticFunction.moebius N : ℂ) := by
  simpa using pen_one_ramanujan hN (1 : ℤ)

/-- Summing these endpoints over the positive moduli gives the exact finite Mertens sum. -/
theorem sum_pen_frequency_one (X : ℕ) :
    (∑ N ∈ Finset.Ioc 0 X, pen (1 : DirichletCharacter ℂ N) 1) =
      ∑ N ∈ Finset.Ioc 0 X, (ArithmeticFunction.moebius N : ℂ) := by
  apply Finset.sum_congr rfl
  intro N hN
  exact pen_one_frequency_one (Finset.mem_Ioc.mp hN).1

end FVLT.PenGaussV1
