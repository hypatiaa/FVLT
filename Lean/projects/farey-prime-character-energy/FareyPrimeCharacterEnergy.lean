import TwistedCount

/-! Multiplicative Fourier analysis of the literal positive Farey ranks sampled
at the nonzero numerators modulo a prime. The transform is normalized by the
number of anchors and uses the complex conjugate of the character. -/

namespace FareyPrimeCharacterEnergy

open Finset
open scoped ComplexConjugate
noncomputable section

variable {p : ℕ} [Fact p.Prime]

def anchor (a : (ZMod p)ˣ) : ℝ := ((a : ZMod p).val : ℝ) / p

/-- The inclusive Farey count minus the total number of positive Farey
fractions times the anchor position. The trivial character has modulus one. -/
def rankError (N : ℕ) (a : (ZMod p)ˣ) : ℂ :=
  TwistedFarey.discrepancy (1 : DirichletCharacter ℂ 1) N (anchor a)

def coefficient (f : (ZMod p)ˣ → ℂ) (χ : DirichletCharacter ℂ p) : ℂ :=
  (p.totient : ℂ)⁻¹ * ∑ a, f a * conj (χ a)

private theorem ortho (a b : (ZMod p)ˣ) :
    ∑ χ : DirichletCharacter ℂ p, conj (χ a) * χ b =
      if a = b then (p.totient : ℂ) else 0 := by
  classical
  simpa only [← RCLike.star_def, MulChar.star_apply', MulChar.inv_apply',
    Units.val_inj] using
    (DirichletCharacter.sum_char_inv_mul_char_eq ℂ a.isUnit (b : ZMod p))

theorem inversion (f : (ZMod p)ˣ → ℂ) (b : (ZMod p)ˣ) :
    ∑ χ : DirichletCharacter ℂ p, coefficient f χ * χ b = f b := by
  classical
  have ht : (p.totient : ℂ) ≠ 0 := by exact_mod_cast (Nat.totient_pos.mpr (Fact.out : p.Prime).pos).ne'
  calc
    _ = (p.totient : ℂ)⁻¹ * ∑ χ : DirichletCharacter ℂ p,
        ∑ a, f a * (conj (χ a) * χ b) := by
          simp only [coefficient, ← mul_assoc, ← sum_mul, mul_sum]
    _ = (p.totient : ℂ)⁻¹ * ∑ a, f a * (if a = b then (p.totient : ℂ) else 0) := by
          congr 1
          rw [sum_comm]
          apply sum_congr rfl
          intro a _
          rw [← mul_sum, ortho]
    _ = f b := by simp [mul_ite, ht, mul_comm]

theorem parseval (f : (ZMod p)ˣ → ℂ) :
    ∑ χ : DirichletCharacter ℂ p, ‖coefficient f χ‖ ^ 2 =
      (p.totient : ℝ)⁻¹ * ∑ a, ‖f a‖ ^ 2 := by
  classical
  apply Complex.ofReal_injective
  simp only [Complex.ofReal_sum, Complex.ofReal_mul, Complex.ofReal_inv,
    Complex.ofReal_natCast, Complex.sq_norm, ← Complex.mul_conj]
  calc
    _ = (p.totient : ℂ)⁻¹ * ∑ χ : DirichletCharacter ℂ p,
        ∑ a : (ZMod p)ˣ, (coefficient f χ * χ a) * conj (f a) := by
          rw [mul_sum]
          apply sum_congr rfl
          intro χ _
          conv_lhs => arg 2; rw [coefficient]
          simp only [map_mul, map_inv₀, map_natCast, map_sum, Complex.conj_conj]
          rw [mul_left_comm, mul_sum]
          congr 1
          apply sum_congr rfl
          intro a _
          ring
    _ = _ := by
          congr 1
          rw [sum_comm]
          apply sum_congr rfl
          intro a _
          rw [← sum_mul, inversion]

def jointEnergy (p N : ℕ) [Fact p.Prime] : ℝ :=
  (p.totient : ℝ)⁻¹ * ∑ a : (ZMod p)ˣ, ‖rankError N a‖ ^ 2

theorem all_components_energy (N : ℕ) :
    ∑ χ : DirichletCharacter ℂ p, ‖coefficient (rankError N) χ‖ ^ 2 =
      jointEnergy p N := parseval _

private theorem trivial_eval (k : ℕ) : (1 : DirichletCharacter ℂ 1) k = 1 := by
  rw [Subsingleton.elim (k : ZMod 1) 1, map_one]

def mertens (N : ℕ) : ℤ := ∑ k ∈ Icc 1 N, ArithmeticFunction.moebius k

def floorError (k : ℕ) (a : (ZMod p)ˣ) : ℂ :=
  (⌊(k : ℝ) * anchor a⌋₊ : ℂ) - k * (anchor a : ℂ)

theorem rankError_eq_mertens_rows (N : ℕ) (a : (ZMod p)ˣ) :
    rankError N a = ∑ k ∈ Icc 1 N, (mertens (N / k) : ℂ) * floorError k a := by
  unfold rankError TwistedFarey.discrepancy
  rw [TwistedFarey.count_eq_floors, TwistedFarey.slope_eq, sum_mul, ← sum_sub_distrib]
  apply sum_congr rfl
  intro k _
  simp only [TwistedFarey.coeff, TwistedFarey.mertens, trivial_eval, one_mul,
    mul_one, mertens, floorError, Int.cast_sum]
  ring

theorem coefficient_eq_mertens_rows (N : ℕ) (χ : DirichletCharacter ℂ p) :
    coefficient (rankError N) χ = ∑ k ∈ Icc 1 N,
      (mertens (N / k) : ℂ) * coefficient (floorError k) χ := by
  classical
  simp only [coefficient, rankError_eq_mertens_rows, sum_mul, mul_assoc]
  rw [sum_comm, mul_sum]
  apply sum_congr rfl
  intro k _
  rw [← mul_sum]
  ring

end
end FareyPrimeCharacterEnergy
