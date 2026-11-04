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


private theorem raw_normalization (a : ℤ) (q : ℕ) (hq : 0 < q) :
    (rawValue a q).num * (gcdFactor a q : ℤ) = a ∧
      (rawValue a q).den * gcdFactor a q = q := by
  have hu := rawValue_canonical 1 q hq (by simp)
  have hv : (a : ℚ) * rawValue 1 q = rawValue a q := by
    simp [rawValue, div_eq_mul_inv]
  have hn := Rat.num_mul_num_eq_num_mul_gcd (a : ℚ) (rawValue 1 q)
  have hd := Rat.den_mul_den_eq_den_mul_gcd (a : ℚ) (rawValue 1 q)
  simp only [hv, hu.1, hu.2] at hn hd
  constructor
  · simpa [gcdFactor] using hn.symm
  · simpa [gcdFactor] using hd.symm

theorem reduced_det_mul
    (a c : ℤ) (q r : ℕ) (hq : 0 < q) (hr : 0 < r) :
    |det (rawValue a q) (rawValue c r)| * (gcdFactor a q : ℤ) * (gcdFactor c r : ℤ) =
      |a * (r : ℤ) - c * (q : ℤ)| := by
  have ha := raw_normalization a q hq
  have hc := raw_normalization c r hr
  have hq' : ((rawValue a q).den : ℤ) * (gcdFactor a q : ℤ) = (q : ℤ) := by
    exact_mod_cast ha.2
  have hr' : ((rawValue c r).den : ℤ) * (gcdFactor c r : ℤ) = (r : ℤ) := by
    exact_mod_cast hc.2
  have he : det (rawValue a q) (rawValue c r) * (gcdFactor a q : ℤ) *
      (gcdFactor c r : ℤ) = a * (r : ℤ) - c * (q : ℤ) := by
    calc
      _ = ((rawValue a q).num * (gcdFactor a q : ℤ)) *
          (((rawValue c r).den : ℤ) * (gcdFactor c r : ℤ)) -
          ((rawValue c r).num * (gcdFactor c r : ℤ)) *
          (((rawValue a q).den : ℤ) * (gcdFactor a q : ℤ)) := by unfold det; ring
      _ = _ := by rw [ha.1, hc.1, hq', hr']
  simpa only [abs_mul, abs_of_nonneg (show (0 : ℤ) ≤ (gcdFactor a q : ℤ) by positivity),
    abs_of_nonneg (show (0 : ℤ) ≤ (gcdFactor c r : ℤ) by positivity)] using congrArg abs he

theorem reduced_det_quotient
    (a c : ℤ) (q r : ℕ) (hq : 0 < q) (hr : 0 < r) :
    |det (rawValue a q) (rawValue c r)| =
      |a * (r : ℤ) - c * (q : ℤ)| / ((gcdFactor a q : ℤ) * (gcdFactor c r : ℤ)) := by
  have hg : 0 < gcdFactor a q := Nat.gcd_pos_of_pos_right _ hq
  have hh : 0 < gcdFactor c r := Nat.gcd_pos_of_pos_right _ hr
  have hn : (gcdFactor a q : ℤ) * (gcdFactor c r : ℤ) ≠ 0 := by
    exact_mod_cast (Nat.ne_of_gt (Nat.mul_pos hg hh))
  rw [← reduced_det_mul a c q r hq hr, mul_assoc]
  exact (Int.mul_ediv_cancel _ hn).symm


private theorem gcd_nonzero (a : ℤ) (q : ℕ) (hq : 0 < q) : (gcdFactor a q : ℤ) ≠ 0 := by
  exact_mod_cast (Nat.ne_of_gt (Nat.gcd_pos_of_pos_right a.natAbs hq))

private theorem product_one_iff (a g h b : ℤ) (hgh : g * h ≠ 0)
    (he : a * g * h = b) : a = 1 ↔ b = g * h := by
  constructor
  · intro ha
    simpa [ha] using he.symm
  · intro hb
    apply mul_right_cancel₀ hgh
    simpa only [one_mul, ← mul_assoc] using he.trans hb

theorem row_law (N s : ℕ) (hN : 0 < N) (hs : s < N) :
    |det (rawValue (s : ℤ) N) (rawValue ((s + 1 : ℕ) : ℤ) N)| *
      (gcdFactor (s : ℤ) N : ℤ) * (gcdFactor ((s + 1 : ℕ) : ℤ) N : ℤ) = (N : ℤ) := by
  have he := reduced_det_mul (s : ℤ) ((s + 1 : ℕ) : ℤ) N N hN hN
  have hc : |(s : ℤ) * (N : ℤ) - ((s + 1 : ℕ) : ℤ) * (N : ℤ)| = (N : ℤ) := by
    rw [show (s : ℤ) * (N : ℤ) - ((s + 1 : ℕ) : ℤ) * (N : ℤ) = -(N : ℤ) by push_cast; ring,
      abs_neg, abs_of_nonneg (by positivity)]
  simpa only [hc] using he

theorem row_tangent_iff (N s : ℕ) (hN : 0 < N) (hs : s < N) :
    fareyAdj (rawValue (s : ℤ) N) (rawValue ((s + 1 : ℕ) : ℤ) N) ↔
      N = gcdFactor (s : ℤ) N * gcdFactor ((s + 1 : ℕ) : ℤ) N := by
  unfold fareyAdj
  rw [product_one_iff _ _ _ _
    (mul_ne_zero (gcd_nonzero (s : ℤ) N hN) (gcd_nonzero ((s + 1 : ℕ) : ℤ) N hN))
    (row_law N s hN hs)]
  norm_cast

theorem signed_column_law (u : ℤ) (n : ℕ) (hn : 1 ≤ n) :
    |det (rawValue u n) (rawValue u (n + 1))| *
      (gcdFactor u n : ℤ) * (gcdFactor u (n + 1) : ℤ) = |u| := by
  have he := reduced_det_mul u u n (n + 1) (by omega) (by omega)
  have hc : u * ((n + 1 : ℕ) : ℤ) - u * (n : ℤ) = u := by push_cast; ring
  simpa only [hc] using he

theorem signed_column_tangent_iff (u : ℤ) (n : ℕ) (hn : 1 ≤ n) :
    fareyAdj (rawValue u n) (rawValue u (n + 1)) ↔
      |u| = (gcdFactor u n : ℤ) * (gcdFactor u (n + 1) : ℤ) := by
  exact product_one_iff _ _ _ _
    (mul_ne_zero (gcd_nonzero u n (by omega)) (gcd_nonzero u (n + 1) (by omega)))
    (signed_column_law u n hn)

theorem zero_column_stall (n : ℕ) (hn : 1 ≤ n) :
    rawValue 0 n = rawValue 0 (n + 1) ∧
      det (rawValue 0 n) (rawValue 0 (n + 1)) = 0 ∧
      ¬fareyAdj (rawValue 0 n) (rawValue 0 (n + 1)) := by
  simp [rawValue, det, fareyAdj]

theorem reference_column_tangent_iff (s n : ℕ) (hs : 0 < s) (hn : 1 ≤ n) :
    fareyAdj (rawValue (s : ℤ) n) (rawValue (s : ℤ) (n + 1)) ↔ s ∣ n * (n + 1) := by
  rw [signed_column_tangent_iff (s : ℤ) n hn]
  simp only [gcdFactor, Int.natAbs_natCast, Int.abs_natCast]
  norm_cast
  rw [eq_comm]
  exact Nat.gcd_mul_gcd_eq_iff_dvd_mul_of_coprime (by
    rw [Nat.coprime_self_add_right]
    simp)

theorem unit_fraction_spine (n : ℕ) (hn : 1 ≤ n) :
    rawValue 1 n = unitFrac n ∧ fareyAdj (unitFrac n) (unitFrac (n + 1)) := by
  constructor
  · rfl
  · have ha := rawValue_canonical 1 n (by omega) (by simp)
    have hb := rawValue_canonical 1 (n + 1) (by omega) (by simp)
    change |(rawValue 1 n).num * ((rawValue 1 (n + 1)).den : ℤ) -
      (rawValue 1 (n + 1)).num * ((rawValue 1 n).den : ℤ)| = 1
    rw [ha.1, ha.2, hb.1, hb.2]
    push_cast
    ring_nf <;> norm_num

end FVLT.PhasorFordV1
