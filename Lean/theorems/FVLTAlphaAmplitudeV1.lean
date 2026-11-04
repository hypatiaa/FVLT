import FVLTRosetteTrailV1
import Mathlib.Analysis.SpecialFunctions.Pow.Real

/-!
# Real radial alpha for the positive-integer reference rosette

The radial base is explicitly the positive modulus n3 in this specialization.
This does not identify the full family's independent operating/radial base with
its angular denominator. Alpha here is radial, not channel alpha_ch or walk tilt.
The real signed scale n6 can vanish; raw real-axis contact then collapses.
-/
namespace FVLT.AlphaAmplitudeV1

open CoupledPointV1
noncomputable section

def radius (m : Modulus) (alpha n6 : ℝ) : ℝ := n6 * (m.n3 : ℝ) ^ alpha

def phase (m : Modulus) (k s : ℤ) : ℂ :=
  Complex.exp ((angle m k s : ℂ) * Complex.I)

def point (m : Modulus) (alpha n6 : ℝ) (k s : ℤ) : ℂ :=
  (radius m alpha n6 : ℂ) * phase m k s

def z1 (m : Modulus) (alpha n6 : ℝ) (t1 t2 s : ℤ) : ℂ :=
  point m alpha n6 (tooth1 m t1 t2) s

def z2 (m : Modulus) (alpha n6 : ℝ) (t1 t2 s : ℤ) : ℂ :=
  point m alpha n6 (tooth2 m t1 t2) s

theorem radial_power_pos (m : Modulus) (alpha : ℝ) : 0 < (m.n3 : ℝ) ^ alpha :=
  Real.rpow_pos_of_pos (n3_real_pos m) alpha

theorem radius_ne_zero_iff (m : Modulus) (alpha n6 : ℝ) :
    radius m alpha n6 ≠ 0 ↔ n6 ≠ 0 := by
  simp [radius, ne_of_gt (radial_power_pos m alpha)]

theorem radius_pos (m : Modulus) (alpha n6 : ℝ) (h : 0 < n6) :
    0 < radius m alpha n6 := mul_pos h (radial_power_pos m alpha)

@[simp] theorem radius_zero_scale (m : Modulus) (alpha : ℝ) : radius m alpha 0 = 0 := by
  simp [radius]

@[simp] theorem radius_alpha_one (m : Modulus) (n6 : ℝ) :
    radius m 1 n6 = n6 * (m.n3 : ℝ) := by simp [radius]

@[simp] theorem radius_alpha_zero (m : Modulus) (n6 : ℝ) : radius m 0 n6 = n6 := by
  simp [radius]

@[simp] theorem radius_alpha_neg_one (m : Modulus) (n6 : ℝ) :
    radius m (-1) n6 = n6 / (m.n3 : ℝ) := by simp [radius, Real.rpow_neg_one, div_eq_mul_inv]

theorem norm_phase (m : Modulus) (k s : ℤ) : ‖phase m k s‖ = 1 := by
  simp [phase, Complex.norm_exp]

theorem norm_point (m : Modulus) (alpha n6 : ℝ) (k s : ℤ) :
    ‖point m alpha n6 k s‖ = |n6| * (m.n3 : ℝ) ^ alpha := by
  simp [point, norm_phase, radius,
    abs_of_pos (radial_power_pos m alpha)]

theorem point_ne_zero_iff (m : Modulus) (alpha n6 : ℝ) (k s : ℤ) :
    point m alpha n6 k s ≠ 0 ↔ n6 ≠ 0 := by
  simp [point, phase, Complex.exp_ne_zero, radius_ne_zero_iff]

@[simp] theorem point_zero_scale (m : Modulus) (alpha : ℝ) (k s : ℤ) :
    point m alpha 0 k s = 0 := by simp [point]

/-- Dividing by the signed real radius recovers exactly the unchanged phase.
Negative n6 reverses the ray; no unchanged complex-argument claim is made. -/
theorem point_div_radius (m : Modulus) (alpha n6 : ℝ) (k s : ℤ) (h : n6 ≠ 0) :
    point m alpha n6 k s / (radius m alpha n6 : ℂ) = phase m k s := by
  have hr : (radius m alpha n6 : ℂ) ≠ 0 := by
    exact_mod_cast (radius_ne_zero_iff m alpha n6).mpr h
  simp [point, mul_div_cancel_left₀ _ hr]

theorem point_im (m : Modulus) (alpha n6 : ℝ) (k s : ℤ) :
    (point m alpha n6 k s).im = radius m alpha n6 * Real.sin (angle m k s) := by
  simp [point, phase, Complex.mul_im, Complex.exp_im]

theorem point_real_iff (m : Modulus) (alpha n6 : ℝ) (k s : ℤ) (h : n6 ≠ 0) :
    (point m alpha n6 k s).im = 0 ↔ (CoupledPointV1.point m k s).im = 0 := by
  rw [point_im, mul_eq_zero, CoupledPointV1.point_real_iff_sin]
  simp [(radius_ne_zero_iff m alpha n6).mpr h]

theorem z1_contact (m : Modulus) (alpha n6 : ℝ) (t1 t2 s : ℤ) (h : n6 ≠ 0) :
    (z1 m alpha n6 t1 t2 s).im = 0 ↔ (m.n3 : ℤ) ∣ t2 * s :=
  (point_real_iff m alpha n6 _ s h).trans (CoupledPointV1.z1_real_iff_divides m t1 t2 s)

theorem z2_contact (m : Modulus) (alpha n6 : ℝ) (t1 t2 s : ℤ) (h : n6 ≠ 0) :
    (z2 m alpha n6 t1 t2 s).im = 0 ↔ (m.n3 : ℤ) ∣ t2 * s :=
  (point_real_iff m alpha n6 _ s h).trans (CoupledPointV1.z2_real_iff_divides m t1 t2 s)

theorem phase_conjugacy (m : Modulus) (t1 t2 s : ℤ) :
    phase m (tooth2 m t1 t2) s = star (phase m (tooth1 m t1 t2) s) := by
  have ha : ((angle m (tooth2 m t1 t2) s : ℝ) : ℂ) * Complex.I =
      -((angle m (tooth1 m t1 t2) s : ℝ) : ℂ) * Complex.I +
        ((t1 * s : ℤ) : ℂ) * (2 * Real.pi * Complex.I) := by
    rw [angle_tooth1, angle_tooth2]
    push_cast
    ring
  unfold phase
  rw [ha, Complex.exp_add, Complex.exp_int_mul_two_pi_mul_I, mul_one]
  change _ = (starRingEnd ℂ) (Complex.exp _)
  rw [← Complex.exp_conj]
  congr 1
  simp

theorem z2_eq_conj_z1 (m : Modulus) (alpha n6 : ℝ) (t1 t2 s : ℤ) :
    z2 m alpha n6 t1 t2 s = star (z1 m alpha n6 t1 t2 s) := by
  unfold z1 z2 point
  rw [phase_conjugacy]
  simp

theorem point_reference (m : Modulus) (k s : ℤ) :
    point m 1 1 k s = CoupledPointV1.point m k s := by
  simp [point, radius, phase, CoupledPointV1.point]

def trailPoint (n1 : ℕ) (i : RosetteTrailV1.Trail n1) (arm : Bool)
    (alpha n6 : ℝ) (t1 t2 s : ℤ) : ℂ :=
  if arm then z2 (RosetteTrailV1.modulus n1 i) alpha n6 t1 t2 s
  else z1 (RosetteTrailV1.modulus n1 i) alpha n6 t1 t2 s

theorem trailPoint_reference (n1 : ℕ) (i : RosetteTrailV1.Trail n1) (arm : Bool)
    (t1 t2 s : ℤ) :
    trailPoint n1 i arm 1 1 t1 t2 s = RosetteTrailV1.trailPoint n1 i arm t1 t2 s := by
  cases arm <;> simp [trailPoint, RosetteTrailV1.trailPoint, z1, z2,
    CoupledPointV1.z1, CoupledPointV1.z2, point_reference]

theorem trailPoint_norm (n1 : ℕ) (i : RosetteTrailV1.Trail n1) (arm : Bool)
    (alpha n6 : ℝ) (t1 t2 s : ℤ) :
    ‖trailPoint n1 i arm alpha n6 t1 t2 s‖ =
      |n6| * (RosetteTrailV1.selected n1 i : ℝ) ^ alpha := by
  cases arm <;> simp [trailPoint, z1, z2, norm_point]

theorem trailPoint_contact (n1 : ℕ) (i : RosetteTrailV1.Trail n1) (arm : Bool)
    (alpha n6 : ℝ) (t1 t2 s : ℤ) (h : n6 ≠ 0) :
    (trailPoint n1 i arm alpha n6 t1 t2 s).im = 0 ↔
      (RosetteTrailV1.selected n1 i : ℤ) ∣ t2 * s := by
  cases arm <;> simp [trailPoint, z1_contact, z2_contact, h]

theorem trailPoint_zero_scale (n1 : ℕ) (i : RosetteTrailV1.Trail n1) (arm : Bool)
    (alpha : ℝ) (t1 t2 s : ℤ) : trailPoint n1 i arm alpha 0 t1 t2 s = 0 := by
  cases arm <;> simp [trailPoint, z1, z2]

/-- Raw real-axis contacts, including the origin when n6=0. -/
def contactFinset (n1 s : ℕ) (arm : Bool) (alpha n6 : ℝ) : Finset ℕ := by
  classical
  exact (Finset.univ.filter (fun i : RosetteTrailV1.Trail n1 =>
    (trailPoint n1 i arm alpha n6 1 1 s).im = 0)).image (RosetteTrailV1.selected n1)

theorem contactFinset_transport (n1 s : ℕ) (arm : Bool) (alpha n6 : ℝ) (h : n6 ≠ 0) :
    contactFinset n1 s arm alpha n6 = RosetteTrailV1.contactFinset n1 s arm := by
  classical
  unfold contactFinset RosetteTrailV1.contactFinset
  congr 1
  apply Finset.filter_congr
  intro i _
  rw [trailPoint_contact _ _ _ _ _ _ _ _ h, RosetteTrailV1.trailPoint_contact]

theorem mem_contactFinset (n1 s n : ℕ) (arm : Bool) (alpha n6 : ℝ) (h : n6 ≠ 0) :
    n ∈ contactFinset n1 s arm alpha n6 ↔
      0 < n ∧ n ≤ RosetteTrailV1.cap n1 ∧ n ∣ s := by
  rw [contactFinset_transport _ _ _ _ _ h, RosetteTrailV1.mem_contactFinset]

theorem contactFinset_eq_divisors (n1 s : ℕ) (arm : Bool) (alpha n6 : ℝ)
    (h : n6 ≠ 0) (hs : 0 < s) (hwindow : s ≤ RosetteTrailV1.cap n1) :
    contactFinset n1 s arm alpha n6 = Nat.divisors s := by
  rw [contactFinset_transport _ _ _ _ _ h]
  exact RosetteTrailV1.contactFinset_eq_divisors n1 s arm hs hwindow

theorem mem_contactFinset_zero_scale (n1 s n : ℕ) (arm : Bool) (alpha : ℝ) :
    n ∈ contactFinset n1 s arm alpha 0 ↔ 0 < n ∧ n ≤ RosetteTrailV1.cap n1 := by
  classical
  simp only [contactFinset, trailPoint_zero_scale, Complex.zero_im, Finset.mem_image,
    Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · rintro ⟨i, _, rfl⟩
    exact ⟨RosetteTrailV1.selected_pos n1 i, RosetteTrailV1.selected_le_cap n1 i⟩
  · rintro ⟨hn, hc⟩
    exact ⟨RosetteTrailV1.indexOf n1 n hn hc, RosetteTrailV1.selected_indexOf _ _ _ _⟩

end
end FVLT.AlphaAmplitudeV1
