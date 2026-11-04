import FVLTRosetteFordDataV1

open FVLT.FareyContactV1 FVLT.FordExactCoordinatesV1
namespace FVLT.PhasorFordV1

theorem integer_address_iff
    (t2 s : ℤ) (n3 : ℕ) (hn3 : 0 < n3) :
    (fordAddress t2 (s : ℚ) n3).den = 1 ↔ (n3 : ℤ) ∣ t2 * s := by
  simpa [fordAddress, Int.cast_mul] using
    Rat.den_div_intCast_eq_one_iff (t2 * s) (n3 : ℤ)
      (by exact_mod_cast (Nat.ne_of_gt hn3))

theorem integer_address_integral_iff
    (t2 s : ℤ) (n3 : ℕ) (hn3 : 0 < n3) :
    IsIntegral (fordAddress t2 (s : ℚ) n3) ↔ (n3 : ℤ) ∣ t2 * s := by
  constructor
  · rintro ⟨k, hk⟩
    apply (integer_address_iff t2 s n3 hn3).mp
    rw [hk]
    simp
  · intro hd
    refine ⟨(fordAddress t2 (s : ℚ) n3).num, ?_⟩
    exact ((Rat.den_eq_one_iff _).mp ((integer_address_iff t2 s n3 hn3).mpr hd)).symm

theorem integer_address_radius
    (t2 s : ℤ) (n3 : ℕ) (hn3 : 0 < n3) (hdiv : (n3 : ℤ) ∣ t2 * s) :
    FVLT.FordGeometryV1.radius (fordAddress t2 (s : ℚ) n3) = (1 : ℝ) / 2 := by
  simp [FVLT.FordGeometryV1.radius, (integer_address_iff t2 s n3 hn3).mpr hdiv]

theorem divisor_recovery_window (s M : ℕ) (hs : 0 < s) :
    integerContactWindow (s : ℤ) M = divisorWindow s M := by
  ext N
  simp only [integerContactWindow, divisorWindow, Finset.mem_filter,
    Finset.mem_Icc, Finset.mem_inter, Nat.mem_divisors]
  constructor
  · rintro ⟨⟨h1, hM⟩, hd⟩
    have hz : (N : ℤ) ∣ (s : ℤ) := by
      simpa using (integer_address_iff 1 (s : ℤ) N (by omega)).mp hd
    have hdvd : N ∣ s := by exact_mod_cast hz
    exact ⟨⟨hdvd, Nat.ne_of_gt hs⟩, h1, hM⟩
  · rintro ⟨⟨hdvd, _⟩, h1, hM⟩
    refine ⟨⟨h1, hM⟩, (integer_address_iff 1 (s : ℤ) N (by omega)).mpr ?_⟩
    simpa using (show (N : ℤ) ∣ (s : ℤ) by exact_mod_cast hdvd)

theorem zero_spin_address (t2 : ℤ) (n3 : ℕ) (hn3 : 0 < n3) :
    fordAddress t2 0 n3 = 0 ∧ (fordAddress t2 0 n3).den = 1 := by
  simp [fordAddress]

theorem zero_spin_window (M : ℕ) : integerContactWindow 0 M = Finset.Icc 1 M := by
  ext N
  simp [integerContactWindow, fordAddress]

end FVLT.PhasorFordV1
