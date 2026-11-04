import Mathlib.Data.Rat.Defs
import Mathlib.Algebra.Order.Group.Unbundled.Abs
import Mathlib.Algebra.Order.Ring.Int

/-!
FF-1 F1 arithmetic definitions only. Classical Ford/Farey arithmetic.
Framework assembled by Robin Miller; components are classical results of others.
Ford (1938), Apostol ch. 5; Paulson, Farey Sequences and Ford Circles (AFP, 2025).
-/
namespace FVLT.FareyContactV1

def det (x y : ℚ) : ℤ := x.num * (y.den : ℤ) - y.num * (x.den : ℤ)
def fareyAdj (x y : ℚ) : Prop := |det x y| = 1

end FVLT.FareyContactV1
