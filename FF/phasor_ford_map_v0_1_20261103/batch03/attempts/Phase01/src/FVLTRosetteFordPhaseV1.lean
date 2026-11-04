import FVLTRosetteFordDataV1

open FVLT.FareyContactV1 FVLT.FordExactCoordinatesV1
namespace FVLT.PhasorFordV1

theorem phasor_real_iff
    (t1 t2 : ℤ) (s : ℚ) (n3 : ℕ) (hn3 : 0 < n3) (r : ℝ) (hr : r ≠ 0) :
    (phasorValue t1 t2 s n3 r).im = 0 ↔ IsIntegral (phaseAddress t1 t2 s n3) := by
  have him : (phasorValue t1 t2 s n3 r).im =
      r * Real.sin (Real.pi * (phaseAddress t1 t2 s n3 : ℝ)) := by
    simp [phasorValue, Complex.mul_im, Complex.exp_im]
  rw [him, mul_eq_zero, or_iff_right hr, Real.sin_eq_zero_iff]
  constructor
  · rintro ⟨n, hn⟩
    refine ⟨n, ?_⟩
    have he : (phaseAddress t1 t2 s n3 : ℝ) = (n : ℝ) := by
      apply mul_left_cancel₀ Real.pi_ne_zero
      nlinarith [hn]
    exact_mod_cast he
  · rintro ⟨n, hn⟩
    refine ⟨n, ?_⟩
    rw [hn]
    push_cast
    ring

theorem integer_spin_phase_iff
    (t1 t2 s : ℤ) (n3 : ℕ) (hn3 : 0 < n3) :
    IsIntegral (phaseAddress t1 t2 (s : ℚ) n3) ↔
      IsIntegral (fordAddress t2 (s : ℚ) n3) := by
  change (∃ k : ℤ, (t1 : ℚ) * (s : ℚ) - fordAddress t2 (s : ℚ) n3 = (k : ℚ)) ↔
    ∃ k : ℤ, fordAddress t2 (s : ℚ) n3 = (k : ℚ)
  constructor
  · rintro ⟨k, hk⟩
    refine ⟨t1 * s - k, ?_⟩
    push_cast
    linarith
  · rintro ⟨k, hk⟩
    refine ⟨t1 * s - k, ?_⟩
    push_cast
    linarith

theorem integer_spin_parity
    (t1 t2 s : ℤ) (n3 : ℕ) (hn3 : 0 < n3) :
    Complex.exp (((Real.pi * (phaseAddress t1 t2 (s : ℚ) n3 : ℝ)) : ℂ) * Complex.I) =
      (-1 : ℂ) ^ (t1 * s) *
        Complex.exp (-(((Real.pi * (fordAddress t2 (s : ℚ) n3 : ℝ)) : ℂ) * Complex.I)) := by
  have he : (((Real.pi * (phaseAddress t1 t2 (s : ℚ) n3 : ℝ)) : ℂ) * Complex.I) =
      ((t1 * s : ℤ) : ℂ) * ((Real.pi : ℂ) * Complex.I) +
        -(((Real.pi * (fordAddress t2 (s : ℚ) n3 : ℝ)) : ℂ) * Complex.I) := by
    simp only [phaseAddress]
    push_cast
    ring
  rw [he, Complex.exp_add, Complex.exp_int_mul, Complex.exp_pi_mul_I]

theorem circleMap_amplitude_independent
    (d e : LiftedData) (ht2 : d.t2 = e.t2) (hs : d.s = e.s) (hn3 : d.n3 = e.n3) :
    circleMap d = circleMap e := by
  simp only [circleMap, ht2, hs, hn3]

theorem phasor_alias_not_address_alias (r : ℝ) (hr : r ≠ 0) :
    phasorValue 1 1 0 3 r = phasorValue 1 1 3 3 r ∧
      fordAddress 1 0 3 ≠ fordAddress 1 3 3 := by
  have h0 : phaseAddress 1 1 0 3 = 0 := by norm_num [phaseAddress, fordAddress]
  have h3 : phaseAddress 1 1 3 3 = 2 := by norm_num [phaseAddress, fordAddress]
  have he : Complex.exp (((Real.pi * ((2 : ℚ) : ℝ)) : ℂ) * Complex.I) = 1 := by
    convert Complex.exp_int_mul_two_pi_mul_I (1 : ℤ) using 1 <;> norm_num <;> ring
  constructor
  · simp only [phasorValue, h0, h3]
    rw [he]
    simp
  · norm_num [fordAddress]

end FVLT.PhasorFordV1
