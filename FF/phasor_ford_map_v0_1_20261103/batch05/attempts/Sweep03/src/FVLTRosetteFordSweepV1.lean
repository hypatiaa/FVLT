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


private theorem unit_numerator (x : ℚ) (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    (x.num.natAbs : ℚ) = (x.num : ℚ) ∧ x.num.natAbs ≤ x.den := by
  have hd : (0 : ℚ) < (x.den : ℚ) := by exact_mod_cast x.den_pos
  have he : (x.num : ℚ) = x * (x.den : ℚ) := (div_eq_iff hd.ne').mp (Rat.num_div_den x)
  have hnq : (0 : ℚ) ≤ (x.num : ℚ) := by rw [he]; positivity
  have hnz : (0 : ℤ) ≤ x.num := by exact_mod_cast hnq
  have hnm : (x.num.natAbs : ℤ) = x.num := by rw [Int.natCast_natAbs, abs_of_nonneg hnz]
  have hmq : (x.num.natAbs : ℚ) = (x.num : ℚ) := by exact_mod_cast hnm
  refine ⟨hmq, ?_⟩
  have hle : (x.num.natAbs : ℚ) ≤ (x.den : ℚ) := by
    rw [hmq, he]
    simpa using mul_le_mul_of_nonneg_right hx1 hd.le
  exact_mod_cast hle

private theorem raw_den_bound (a : ℤ) (q : ℕ) (hq : 0 < q) : (rawValue a q).den ≤ q := by
  have hu := rawValue_canonical 1 q hq (by simp)
  have hv : (a : ℚ) * rawValue 1 q = rawValue a q := by simp [rawValue, div_eq_mul_inv]
  have hd := Rat.mul_den_dvd (a : ℚ) (rawValue 1 q)
  have hdiv : (rawValue a q).den ∣ q := by simpa [hv, hu.2] using hd
  exact Nat.le_of_dvd hq hdiv

theorem mem_shellEvents
    (B : ℕ) (hB : 1 ≤ B) (N : ℕ) (s : ℚ) :
    (N, s) ∈ shellEvents B ↔
      2 ≤ N ∧ N ≤ B + 1 ∧ 0 ≤ s ∧ s ≤ (N : ℚ) ∧ IsIntegral (phaseAddress 1 1 s N) := by
  constructor
  · intro hevent
    rcases Finset.mem_biUnion.mp hevent with ⟨N', hN', hi⟩
    rcases Finset.mem_image.mp hi with ⟨m, hm, he⟩
    have hne : N' = N := congrArg Prod.fst he
    subst N'
    have hse : (m : ℚ) * (N : ℚ) / ((N : ℚ) - 1) = s := congrArg Prod.snd he
    rcases Finset.mem_Icc.mp hN' with ⟨hN2, hNB⟩
    have hmlt : m < N := Finset.mem_range.mp hm
    have hd : (0 : ℚ) < (N : ℚ) - 1 := by
      have ht : (2 : ℚ) ≤ (N : ℚ) := by exact_mod_cast hN2
      linarith
    have hs0 : (0 : ℚ) ≤ s := by rw [← hse]; positivity
    have hsN : s ≤ (N : ℚ) := by
      rw [← hse]
      apply (div_le_iff₀ hd).mpr
      have hmn : (m : ℚ) + 1 ≤ (N : ℚ) := by exact_mod_cast (show m + 1 ≤ N by omega)
      have hm' : (m : ℚ) ≤ (N : ℚ) - 1 := by linarith
      simpa [mul_comm] using mul_le_mul_of_nonneg_right hm' (show (0 : ℚ) ≤ (N : ℚ) by positivity)
    exact ⟨hN2, hNB, hs0, hsN,
      (shell_contact_parameterization N hN2 s hs0 hsN).mpr ⟨m, by omega, hse.symm⟩⟩
  · rintro ⟨hN2, hNB, hs0, hsN, hint⟩
    rcases (shell_contact_parameterization N hN2 s hs0 hsN).mp hint with ⟨m, hm, hse⟩
    apply Finset.mem_biUnion.mpr
    refine ⟨N, Finset.mem_Icc.mpr ⟨hN2, hNB⟩, ?_⟩
    exact Finset.mem_image.mpr ⟨m, Finset.mem_range.mpr (by omega), Prod.ext rfl hse.symm⟩

theorem mem_fareySet (B : ℕ) (hB : 1 ≤ B) (x : ℚ) :
    x ∈ fareySet B ↔ 0 ≤ x ∧ x ≤ 1 ∧ x.den ≤ B := by
  constructor
  · intro hx
    rcases Finset.mem_biUnion.mp hx with ⟨q, hq, hi⟩
    rcases Finset.mem_Icc.mp hq with ⟨hq1, hqB⟩
    rcases Finset.mem_image.mp hi with ⟨m, hm, rfl⟩
    rcases Finset.mem_filter.mp hm with ⟨hmrange, hmc⟩
    have hmle : m ≤ q := by have := Finset.mem_range.mp hmrange; omega
    have hd : ((m : ℚ) / (q : ℚ)).den = q := by
      simpa [rawValue] using (rawValue_canonical (m : ℤ) q (by omega) (by simpa using hmc)).2
    have hqpos : (0 : ℚ) < (q : ℚ) := by exact_mod_cast (show 0 < q by omega)
    refine ⟨by positivity, (div_le_one hqpos).mpr (by exact_mod_cast hmle), ?_⟩
    simpa [hd] using hqB
  · rintro ⟨hx0, hx1, hxB⟩
    have hn := unit_numerator x hx0 hx1
    apply Finset.mem_biUnion.mpr
    refine ⟨x.den, Finset.mem_Icc.mpr ⟨by have := x.den_pos; omega, hxB⟩, ?_⟩
    refine Finset.mem_image.mpr ⟨x.num.natAbs,
      Finset.mem_filter.mpr ⟨Finset.mem_range.mpr (by omega), x.reduced⟩, ?_⟩
    rw [hn.1]
    exact Rat.num_div_den x

theorem shell_addresses_eq_farey (B : ℕ) (hB : 1 ≤ B) :
    shellEventAddresses B = fareySet B := by
  ext x
  constructor
  · intro hx
    rcases Finset.mem_image.mp hx with ⟨⟨N, s⟩, hevent, haddr⟩
    rcases (mem_shellEvents B hB N s).mp hevent with ⟨hN2, hNB, hs0, hsN, hint⟩
    rcases (shell_contact_parameterization N hN2 s hs0 hsN).mp hint with ⟨m, hm, hse⟩
    have hv : fordAddress 1 s N = rawValue (m : ℤ) (N - 1) := by
      rw [hse, shell_contact_address N m hN2 hm]
      simp [rawValue, Nat.cast_sub (show 1 ≤ N by omega)]
    change fordAddress 1 s N = x at haddr
    rw [← haddr, hv]
    apply (mem_fareySet B hB _).mpr
    have hq : 0 < N - 1 := by omega
    have hqr : (0 : ℚ) < ((N - 1 : ℕ) : ℚ) := by exact_mod_cast hq
    refine ⟨by unfold rawValue; positivity, ?_, (raw_den_bound (m : ℤ) (N - 1) hq).trans (by omega)⟩
    change (m : ℚ) / ((N - 1 : ℕ) : ℚ) ≤ 1
    exact (div_le_one hqr).mpr (by exact_mod_cast hm)
  · intro hx
    rcases (mem_fareySet B hB x).mp hx with ⟨hx0, hx1, hxB⟩
    have hm := unit_numerator x hx0 hx1
    let N := x.den + 1
    let m := x.num.natAbs
    let s : ℚ := (m : ℚ) * (N : ℚ) / ((N : ℚ) - 1)
    have hN2 : 2 ≤ N := by dsimp [N]; have := x.den_pos; omega
    have hNB : N ≤ B + 1 := by dsimp [N]; omega
    have hmlt : m < N := by dsimp [m, N]; omega
    apply Finset.mem_image.mpr
    refine ⟨(N, s), ?_, ?_⟩
    · apply Finset.mem_biUnion.mpr
      refine ⟨N, Finset.mem_Icc.mpr ⟨hN2, hNB⟩, ?_⟩
      exact Finset.mem_image.mpr ⟨m, Finset.mem_range.mpr hmlt, rfl⟩
    · change fordAddress 1 s N = x
      dsimp [s]
      rw [shell_contact_address N m hN2 (by omega)]
      dsimp [N, m]
      push_cast
      rw [hm.1]
      simpa using Rat.num_div_den x

end FVLT.PhasorFordV1
