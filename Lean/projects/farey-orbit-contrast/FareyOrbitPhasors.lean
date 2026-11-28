import Mathlib.RingTheory.RootsOfUnity.PrimitiveRoots
import Mathlib.Tactic.LinearCombination
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

/-! The two doubling orbits of nonzero residues modulo seven give two
three-term Gaussian periods at a primitive seventh root of unity. -/

namespace FareyOrbitPhasors

variable {R : Type*} [CommRing R]

/-- Sum of the phasors with exponents in the doubling orbit of 1. -/
def periodA (ζ : R) : R := ζ + ζ ^ 2 + ζ ^ 4

/-- Sum of the phasors with exponents in the doubling orbit of 3. -/
def periodB (ζ : R) : R := ζ ^ 3 + ζ ^ 5 + ζ ^ 6

variable [IsDomain R] {ζ : R}

theorem periods_add (hζ : IsPrimitiveRoot ζ 7) : periodA ζ + periodB ζ = -1 := by
  have h := hζ.geom_sum_eq_zero (by decide)
  simp only [Finset.sum_range_succ, Finset.sum_range_zero, pow_zero, pow_one, zero_add] at h
  unfold periodA periodB
  linear_combination h

theorem periods_mul (hζ : IsPrimitiveRoot ζ 7) : periodA ζ * periodB ζ = 2 := by
  have h := periods_add hζ
  unfold periodA periodB at h ⊢
  linear_combination h + (3 + ζ + ζ ^ 2 + ζ ^ 3) * hζ.pow_eq_one

theorem periods_sub_sq (hζ : IsPrimitiveRoot ζ 7) : (periodA ζ - periodB ζ) ^ 2 = -7 := by
  calc
    _ = (periodA ζ + periodB ζ) ^ 2 - 4 * (periodA ζ * periodB ζ) := by ring
    _ = -7 := by rw [periods_add hζ, periods_mul hζ]; norm_num

end FareyOrbitPhasors

#print axioms FareyOrbitPhasors.periods_add
#print axioms FareyOrbitPhasors.periods_mul
#print axioms FareyOrbitPhasors.periods_sub_sq
