import Mathlib.Data.Rat.Defs

/-! Exact executable rational coordinates. No real or complex runtime. -/
namespace FVLT.FordExactCoordinatesV1

abbrev RatPlane := ℚ × ℚ
def radiusQ (x : ℚ) : ℚ := 1 / (2 * (x.den : ℚ)^2)
def centreQ (x : ℚ) : RatPlane := (x, radiusQ x)
def kissNQ (x y : ℚ) : ℤ :=
  x.num * (x.den : ℤ) + y.num * (y.den : ℤ)
def kissMQ (x y : ℚ) : ℕ := x.den^2 + y.den^2
def kissQ (x y : ℚ) : RatPlane :=
  ((kissNQ x y : ℚ) / (kissMQ x y : ℚ), 1 / (kissMQ x y : ℚ))
def sqDistanceQ (u v : RatPlane) : ℚ :=
  (u.1 - v.1)^2 + (u.2 - v.2)^2
def boundaryQ (x : ℚ) (z : RatPlane) : Prop :=
  sqDistanceQ z (centreQ x) = (radiusQ x)^2
instance (x : ℚ) (z : RatPlane) : Decidable (boundaryQ x z) :=
  inferInstanceAs (Decidable (sqDistanceQ z (centreQ x) = (radiusQ x)^2))
def boundaryCheckQ (x : ℚ) (z : RatPlane) : Bool := decide (boundaryQ x z)

end FVLT.FordExactCoordinatesV1
