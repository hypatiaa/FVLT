import FVLTRosetteFordPhaseV1

open FVLT.FareyContactV1 FVLT.FordExactCoordinatesV1
namespace FVLT.PhasorFordV1

theorem shell_contact_parameterization
    (N : ℕ) (hN : 2 ≤ N) (s : ℚ) (hs0 : 0 ≤ s) (hsN : s ≤ (N : ℚ)) :
    IsIntegral (phaseAddress 1 1 s N) ↔
      ∃ m : ℕ, m ≤ N - 1 ∧ s = (m : ℚ) * (N : ℚ) / ((N : ℚ) - 1) := by
  have hpos : (0 : ℚ) < (N : ℚ) := by exact_mod_cast (show 0 < N by omega)
  have hden : (0 : ℚ) < (N : ℚ) - 1 := by
    have ht : (2 : ℚ) ≤ (N : ℚ) := by exact_mod_cast hN
    linarith
  have hp : phaseAddress 1 1 s N = s * ((N : ℚ) - 1) / (N : ℚ) := by
    unfold phaseAddress fordAddress
    norm_num
    field_simp [hpos.ne']
    <;> ring
  rw [hp]
  constructor
  · rintro ⟨k, hk⟩
    have hk0 : (0 : ℚ) ≤ (k : ℚ) := by
      rw [← hk]
      positivity
    have hkz : (0 : ℤ) ≤ k := by exact_mod_cast hk0
    have hkm : (k.toNat : ℚ) = (k : ℚ) := by
      exact_mod_cast (Int.toNat_of_nonneg hkz)
    have hkle : (k : ℚ) ≤ (N : ℚ) - 1 := by
      rw [← hk]
      apply (div_le_iff₀ hpos).mpr
      nlinarith [hsN]
    refine ⟨k.toNat, ?_, ?_⟩
    · have hle : (k.toNat : ℚ) ≤ ((N - 1 : ℕ) : ℚ) := by
        rw [hkm, Nat.cast_sub (show 1 ≤ N by omega), Nat.cast_one]
        exact hkle
      exact_mod_cast hle
    · apply (eq_div_iff hden.ne').mpr
      rw [hkm]
      have he := (div_eq_iff hpos.ne').mp hk
      nlinarith [he]
  · rintro ⟨m, hm, rfl⟩
    refine ⟨(m : ℤ), ?_⟩
    push_cast
    field_simp [hpos.ne', hden.ne']
    <;> ring

theorem shell_phasor_contact_iff
    (N : ℕ) (hN : 2 ≤ N) (s : ℚ) (hs0 : 0 ≤ s) (hsN : s ≤ (N : ℚ))
    (r : ℝ) (hr : r ≠ 0) :
    (phasorValue 1 1 s N r).im = 0 ↔
      ∃ m : ℕ, m ≤ N - 1 ∧ s = (m : ℚ) * (N : ℚ) / ((N : ℚ) - 1) := by
  rw [phasor_real_iff 1 1 s N (by omega) r hr]
  exact shell_contact_parameterization N hN s hs0 hsN

theorem shell_contact_address (N m : ℕ) (hN : 2 ≤ N) (hm : m ≤ N - 1) :
    fordAddress 1 ((m : ℚ) * (N : ℚ) / ((N : ℚ) - 1)) N =
      (m : ℚ) / ((N : ℚ) - 1) := by
  have hn : (N : ℚ) ≠ 0 := by exact_mod_cast (show N ≠ 0 by omega)
  have hd : (N : ℚ) - 1 ≠ 0 := by
    have ht : (2 : ℚ) ≤ (N : ℚ) := by exact_mod_cast hN
    linarith
  unfold fordAddress
  norm_num
  field_simp [hn, hd] <;> ring

theorem fareyList_membership (B : ℕ) (hB : 1 ≤ B) (x : ℚ) :
    x ∈ fareyList B ↔ x ∈ fareySet B := by
  exact Finset.mem_sort (· ≤ ·)

theorem fareyList_strict (B : ℕ) (hB : 1 ≤ B) : (fareyList B).Pairwise (· < ·) := by
  exact (Finset.sortedLT_sort (fareySet B)).pairwise

end FVLT.PhasorFordV1
