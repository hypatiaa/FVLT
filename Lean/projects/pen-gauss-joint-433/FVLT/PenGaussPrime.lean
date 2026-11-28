import FVLT.PenGaussCore
import Mathlib.NumberTheory.LegendreSymbol.QuadraticChar.Basic

namespace FVLT.PenGaussV1

open scoped ComplexConjugate

private theorem pen_at_one_eq_gaussSum {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N) :
    pen χ 1 = gaussSum χ ZMod.stdAddChar := by
  rw [pen_eq_gaussSum, Int.cast_one, AddChar.mulShift_one]

/-- The squared magnitude of a nontrivial character pen at prime level. -/
theorem pen_normSq_prime {p : ℕ} [Fact p.Prime] (χ : DirichletCharacter ℂ p) (hχ : χ ≠ 1) :
    pen χ 1 * conj (pen χ 1) = (p : ℂ) := by
  rw [pen_at_one_eq_gaussSum]
  change gaussSum χ ZMod.stdAddChar * star (gaussSum χ ZMod.stdAddChar) = (p : ℂ)
  rw [star_gaussSum_eq, gaussSum_mul_gaussSum_eq_card hχ (ZMod.isPrimitive_stdAddChar p),
    ZMod.card]

/-- Nontrivial character pens at prime level have a nonzero endpoint at frequency one. -/
theorem pen_one_ne_zero_of_ne_one {p : ℕ} [Fact p.Prime] (χ : DirichletCharacter ℂ p)
    (hχ : χ ≠ 1) : pen χ 1 ≠ 0 := by
  intro hz
  have h := pen_normSq_prime χ hχ
  rw [hz, zero_mul] at h
  exact Nat.cast_ne_zero.mpr (Fact.out : p.Prime).ne_zero h.symm

/-- The quadratic character of the prime field, with values viewed in ℂ. -/
noncomputable def legendreCharacter (p : ℕ) [Fact p.Prime] : DirichletCharacter ℂ p :=
  (quadraticChar (ZMod p)).ringHomComp (Int.castRingHom ℂ)

/-- At odd prime level the quadratic pen squares to the field size times its sign at −1. -/
theorem pen_quadratic_sq {p : ℕ} [Fact p.Prime] (hp : p ≠ 2) :
    pen (legendreCharacter p) 1 ^ 2 = legendreCharacter p (-1) * (p : ℂ) := by
  have hp' : ringChar (ZMod p) ≠ 2 := by rwa [ZMod.ringChar_zmod_n]
  have hχ : legendreCharacter p ≠ 1 := by
    obtain ⟨a, ha⟩ := quadraticChar_exists_neg_one' hp'
    refine MulChar.ne_one_iff.mpr ⟨a, ?_⟩
    change (quadraticChar (ZMod p) a : ℂ) ≠ 1
    rw [ha]
    norm_num
  have hquad : (legendreCharacter p).IsQuadratic :=
    MulChar.IsQuadratic.comp (quadraticChar_isQuadratic _) _
  rw [pen_at_one_eq_gaussSum, gaussSum_sq hχ hquad (ZMod.isPrimitive_stdAddChar p),
    ZMod.card]

/-- For primes congruent to one modulo four, the quadratic pen squares to the prime. -/
theorem pen_quadratic_sq_of_mod_four_eq_one {p : ℕ} [Fact p.Prime] (hp : p % 4 = 1) :
    pen (legendreCharacter p) 1 ^ 2 = (p : ℂ) := by
  have hp₂ : p ≠ 2 := by omega
  have hp' : ringChar (ZMod p) ≠ 2 := by rwa [ZMod.ringChar_zmod_n]
  have hsign : legendreCharacter p (-1) = 1 := by
    change (quadraticChar (ZMod p) (-1) : ℂ) = 1
    simp only [quadraticChar_neg_one hp', ZMod.card, ZMod.χ₄_nat_one_mod_four hp, Int.cast_one]
  rw [pen_quadratic_sq hp₂, hsign, one_mul]

end FVLT.PenGaussV1
