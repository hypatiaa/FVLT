import FareyPrimeCharacterFormula

/-! Reflection a ↦ -a identifies the principal residue weight and kills
every other even character in the entire Farey rank transform. -/
namespace FareyPrimeCharacterEnergy

open scoped ComplexConjugate
noncomputable section
variable {p : ℕ} [Fact p.Prime]

theorem principal_coefficient_constant (z : ℂ) :
    coefficient (fun _ : (ZMod p)ˣ => z) (1 : DirichletCharacter ℂ p) = z := by
  have ht : (p.totient : ℂ) ≠ 0 := by exact_mod_cast (Nat.totient_pos.mpr (Fact.out : p.Prime).pos).ne'
  simp [coefficient, MulChar.one_apply_coe, ZMod.card_units_eq_totient, ht]

theorem nonprincipal_coefficient_constant (χ : DirichletCharacter ℂ p) (hχ : χ ≠ 1) (z : ℂ) :
    coefficient (fun _ : (ZMod p)ˣ => z) χ = 0 := by
  obtain ⟨u, hu⟩ := MulChar.ne_one_iff.mp hχ
  exact eq_zero_of_mul_eq_self_left hu
    (coefficient_translate (fun _ : (ZMod p)ˣ => z) u χ).symm

theorem characterWeight_reflection (χ : DirichletCharacter ℂ p) :
    characterWeight χ + χ (-1) * characterWeight χ =
      coefficient (fun _ : (ZMod p)ˣ => -1) χ := by
  let f := fun a : (ZMod p)ˣ => residueWeight (a : ZMod p)
  have h (a : (ZMod p)ˣ) : f a + f ((-1) * a) = -1 := by
    have hp : (p : ℂ) ≠ 0 := by exact_mod_cast (Fact.out : p.Prime).ne_zero
    dsimp [f, residueWeight]
    rw [neg_one_mul, ZMod.neg_val, ite_eq_right a.ne_zero, Nat.cast_sub (ZMod.val_lt _).le]
    field_simp
    ring
  calc
    _ = coefficient f χ + coefficient (fun a => f ((-1) * a)) χ := by
      rw [coefficient_translate]
      rfl
    _ = coefficient (fun a => f a + f ((-1) * a)) χ := by
      simp only [coefficient, add_mul, Finset.sum_add_distrib, mul_add]
    _ = _ := by simp_rw [h]

theorem principal_weight : characterWeight (1 : DirichletCharacter ℂ p) = -(1/2) := by
  have h := characterWeight_reflection (1 : DirichletCharacter ℂ p)
  rw [show (1 : DirichletCharacter ℂ p) (-1) = 1 from
    MulChar.one_apply_coe (-1 : (ZMod p)ˣ), principal_coefficient_constant, one_mul] at h
  linear_combination h / 2

theorem nonprincipal_even_weight (χ : DirichletCharacter ℂ p) (hχ : χ ≠ 1) (he : χ.Even) :
    characterWeight χ = 0 := by
  have h := characterWeight_reflection χ
  rw [show χ (-1) = 1 from he, one_mul, nonprincipal_coefficient_constant χ hχ] at h
  linear_combination h / 2

theorem nonprincipal_even_coefficient (N : ℕ) (χ : DirichletCharacter ℂ p)
    (hχ : χ ≠ 1) (he : χ.Even) : coefficient (rankError N) χ = 0 := by
  rw [coefficient_eq_character_mertens, nonprincipal_even_weight χ hχ he, zero_mul]

private theorem mertens_row_sum (N : ℕ) :
    ∑ k ∈ Finset.Icc 1 N, (mertens (N/k) : ℂ) = if 0 < N then 1 else 0 := by
  by_cases hn : 0 < N
  · have h := TwistedFarey.coeff_sum (1 : DirichletCharacter ℂ 1) N hn
    have h1 (k : ℕ) : (1 : DirichletCharacter ℂ 1) k = 1 := by
      rw [Subsingleton.elim (k : ZMod 1) 1, map_one]
    simpa [hn, TwistedFarey.coeff, TwistedFarey.mertens, h1, mertens] using h
  · have : N = 0 := by omega
    simp [this]

private theorem mertens_multiple_rows (N : ℕ) :
    ∑ k ∈ (Finset.Icc 1 N).filter (p ∣ ·), (mertens (N/k) : ℂ) =
      ∑ j ∈ Finset.Icc 1 (N/p), (mertens ((N/p)/j) : ℂ) := by
  classical
  have hp := (Fact.out : p.Prime).pos
  symm
  apply Finset.sum_bij (fun j _ => p * j)
  · intro j hj
    obtain ⟨hj1,hjn⟩ := Finset.mem_Icc.mp hj
    exact Finset.mem_filter.mpr ⟨Finset.mem_Icc.mpr ⟨Nat.mul_pos hp hj1,
      by simpa [Nat.mul_comm] using (Nat.le_div_iff_mul_le hp).mp hjn⟩, dvd_mul_right ..⟩
  · intro a _ b _ hab
    exact Nat.eq_of_mul_eq_mul_left hp hab
  · intro a ha
    obtain ⟨ha, ⟨j,rfl⟩⟩ := Finset.mem_filter.mp ha
    obtain ⟨hpos,hle⟩ := Finset.mem_Icc.mp ha
    refine ⟨j, Finset.mem_Icc.mpr ⟨?_,?_⟩, rfl⟩
    · by_contra! hj
      simp_all
    · exact (Nat.le_div_iff_mul_le hp).mpr (by simpa [Nat.mul_comm] using hle)
  · intro j _
    rw [Nat.div_div_eq_div_mul]

/-- Before the first Farey endpoint of denominator p enters the sample, the
mean error is -1/2. At N=0 and from N=p onward it is exactly zero. -/
theorem principal_coefficient (N : ℕ) :
    coefficient (rankError N) (1 : DirichletCharacter ℂ p) =
      if 0 < N ∧ N < p then -(1/2) else 0 := by
  have hp := (Fact.out : p.Prime).pos
  have row (k : ℕ) : (mertens (N/k) : ℂ) * (1 : DirichletCharacter ℂ p) k =
      (mertens (N/k) : ℂ) - (if p ∣ k then (mertens (N/k) : ℂ) else 0) := by
    by_cases h : p ∣ k
    · simp [h, (ZMod.natCast_eq_zero_iff k p).mpr h, MulChar.map_zero]
    · simp [h, MulChar.one_apply (isUnit_iff_ne_zero.mpr (mt (ZMod.natCast_eq_zero_iff k p).mp h))]
  rw [coefficient_eq_character_mertens, principal_weight]
  simp_rw [row]
  rw [Finset.sum_sub_distrib, ← Finset.sum_filter, mertens_multiple_rows, mertens_row_sum, mertens_row_sum]
  by_cases hN : 0 < N
  · by_cases hlt : N < p
    · simp [hN, hlt, Nat.div_eq_of_lt hlt]
    · simp [hN, hlt, Nat.div_pos (by omega : p ≤ N) hp]
  · simp [show N = 0 by omega]

end
end FareyPrimeCharacterEnergy
