import Mathlib.Algebra.Field.Periodic
import Mathlib.Data.Rat.Floor
import Mathlib.Tactic

noncomputable section

namespace Ratioque.Franel

/-- The periodic second Bernoulli polynomial at a rational argument. -/
def bTwo (x : ℚ) : ℝ :=
  let u : ℝ := ((Int.fract x : ℚ) : ℝ)
  u ^ 2 - u + 1 / 6

end Ratioque.Franel
