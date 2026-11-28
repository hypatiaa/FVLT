import FareyPrimeCharacterEnergy

/-! The Fourier transform of each floor-error row is diagonal under
multiplication by a nonzero residue. The zero residue gives the zero row. -/

namespace FareyPrimeCharacterEnergy

open Finset
open scoped ComplexConjugate
noncomputable section

variable {p : ℕ} [Fact p.Prime]

def residueWeight (z : ZMod p) : ℂ := -(z.val : ℂ) / p

theorem floorError_eq_residueWeight (k : ℕ) (a : (ZMod p)ˣ) :
    floorError k a = residueWeight ((k : ZMod p) * (a : ZMod p)) := by
  have hp : (p : ℂ) ≠ 0 := by exact_mod_cast (Fact.out : p.Prime).ne_zero
  have hx : (k : ℝ) * anchor a = (((k * (a : ZMod p).val : ℕ) : ℝ) / p) := by
    unfold anchor
    push_cast
    ring
  have hv : ((k : ZMod p) * (a : ZMod p)).val = (k * (a : ZMod p).val) % p := by
    rw [← ZMod.natCast_zmod_val (a : ZMod p), ← Nat.cast_mul, ZMod.val_natCast]
    simp
  have h := congrArg (fun n : ℕ => (n : ℂ)) (Nat.mod_add_div (k * (a : ZMod p).val) p)
  push_cast at h
  rw [floorError, hx, Nat.floor_div_eq_div, residueWeight, hv]
  unfold anchor
  push_cast
  field_simp
  linear_combination h

theorem coefficient_translate (f : (ZMod p)ˣ → ℂ) (u : (ZMod p)ˣ)
    (χ : DirichletCharacter ℂ p) :
    coefficient (fun a => f (u * a)) χ = χ u * coefficient f χ := by
  classical
  have h (a : (ZMod p)ˣ) : χ u * conj (χ (u * a : (ZMod p)ˣ)) = conj (χ a) := by
    rw [Units.val_mul, map_mul, map_mul, ← mul_assoc]
    have hu : χ u * conj (χ u) = 1 := by
      rw [Complex.mul_conj, ← Complex.sq_norm, χ.unit_norm_eq_one]
      norm_num
    rw [hu, one_mul]
  unfold coefficient
  rw [mul_left_comm]
  congr 1
  rw [mul_sum]
  apply Fintype.sum_equiv (Equiv.mulLeft u)
  intro a
  change f (u * a) * conj (χ a) = χ u * (f (u * a) * conj (χ (u * a : (ZMod p)ˣ)))
  rw [mul_left_comm, h]

def characterWeight (χ : DirichletCharacter ℂ p) : ℂ :=
  coefficient (fun a : (ZMod p)ˣ => residueWeight (a : ZMod p)) χ

theorem coefficient_floorError (k : ℕ) (χ : DirichletCharacter ℂ p) :
    coefficient (floorError k) χ = χ k * characterWeight χ := by
  classical
  by_cases h : (k : ZMod p) = 0
  · simp [coefficient, floorError_eq_residueWeight, h, residueWeight, MulChar.map_zero]
  · let u : (ZMod p)ˣ := Units.mk0 (k : ZMod p) h
    have hf : floorError k = fun a : (ZMod p)ˣ => residueWeight ((u * a : (ZMod p)ˣ) : ZMod p) := by
      funext a
      exact floorError_eq_residueWeight k a
    rw [hf]
    exact coefficient_translate (fun a : (ZMod p)ˣ => residueWeight (a : ZMod p)) u χ

/-- Every character sees the same deflated Mertens rows with its own twist
and a fixed normalized finite Fourier weight. Includes the principal character. -/
theorem coefficient_eq_character_mertens (N : ℕ) (χ : DirichletCharacter ℂ p) :
    coefficient (rankError N) χ = characterWeight χ *
      ∑ k ∈ Icc 1 N, (mertens (N / k) : ℂ) * χ k := by
  rw [coefficient_eq_mertens_rows, mul_sum]
  apply sum_congr rfl
  intro k _
  rw [coefficient_floorError]
  ring

theorem jointEnergy_eq_character_mertens (N : ℕ) :
    jointEnergy p N = ∑ χ : DirichletCharacter ℂ p, ‖characterWeight χ *
      ∑ k ∈ Icc 1 N, (mertens (N / k) : ℂ) * χ k‖ ^ 2 := by
  rw [← all_components_energy]
  simp_rw [coefficient_eq_character_mertens]

end
end FareyPrimeCharacterEnergy
