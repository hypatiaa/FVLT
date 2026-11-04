import FVLTGearboxV1
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic.FieldSimp

/-!
# FVLT's coupled n3 point construction

The positive integer n3 is shared by the original gearbox teeth, the angular
denominator and the amplitude. This is the integer rosette specialization of
FVLT v3.3.0, II.5a, with n6 = 1 and alpha = 1. The full family's separate
operating value and denominator are not identified outside this specialization.
-/
namespace FVLT.CoupledPointV1

noncomputable section

structure Modulus where
  n3 : ℕ
  positive : 0 < n3

def tooth1 (m : Modulus) (t1 t2 : ℤ) : ℤ := GearboxV1.k1 m.n3 t1 t2
def tooth2 (m : Modulus) (t1 t2 : ℤ) : ℤ := GearboxV1.k2 m.n3 t1 t2

def angle (m : Modulus) (k s : ℤ) : ℝ :=
  Real.pi * (k : ℝ) * (s : ℝ) / (m.n3 : ℝ)

def point (m : Modulus) (k s : ℤ) : ℂ :=
  (m.n3 : ℂ) * Complex.exp ((angle m k s : ℂ) * Complex.I)

def z1 (m : Modulus) (t1 t2 s : ℤ) : ℂ := point m (tooth1 m t1 t2) s
def z2 (m : Modulus) (t1 t2 s : ℤ) : ℂ := point m (tooth2 m t1 t2) s

theorem n3_real_pos (m : Modulus) : 0 < (m.n3 : ℝ) := by exact_mod_cast m.positive
theorem n3_real_ne_zero (m : Modulus) : (m.n3 : ℝ) ≠ 0 := ne_of_gt (n3_real_pos m)

theorem angle_tooth1 (m : Modulus) (t1 t2 s : ℤ) :
    angle m (tooth1 m t1 t2) s =
      Real.pi * (t1 : ℝ) * (s : ℝ) - Real.pi * (t2 : ℝ) * (s : ℝ) / (m.n3 : ℝ) := by
  unfold angle tooth1 GearboxV1.k1
  push_cast
  field_simp [n3_real_ne_zero m]

theorem angle_tooth2 (m : Modulus) (t1 t2 s : ℤ) :
    angle m (tooth2 m t1 t2) s =
      Real.pi * (t1 : ℝ) * (s : ℝ) + Real.pi * (t2 : ℝ) * (s : ℝ) / (m.n3 : ℝ) := by
  unfold angle tooth2 GearboxV1.k2
  push_cast
  field_simp [n3_real_ne_zero m]

theorem norm_point (m : Modulus) (k s : ℤ) : ‖point m k s‖ = (m.n3 : ℝ) := by
  simp [point, Complex.norm_exp]

theorem norm_z1 (m : Modulus) (t1 t2 s : ℤ) : ‖z1 m t1 t2 s‖ = (m.n3 : ℝ) :=
  norm_point m _ _

theorem norm_z2 (m : Modulus) (t1 t2 s : ℤ) : ‖z2 m t1 t2 s‖ = (m.n3 : ℝ) :=
  norm_point m _ _

theorem point_ne_zero (m : Modulus) (k s : ℤ) : point m k s ≠ 0 := by
  intro h
  have hn := norm_point m k s
  rw [h, norm_zero] at hn
  exact n3_real_ne_zero m hn.symm

theorem point_recovers_modulus (m n : Modulus) (k s l r : ℤ)
    (h : point m k s = point n l r) : m.n3 = n.n3 := by
  have hn := congrArg norm h
  rw [norm_point, norm_point] at hn
  exact_mod_cast hn

theorem point_im (m : Modulus) (k s : ℤ) :
    (point m k s).im = (m.n3 : ℝ) * Real.sin (angle m k s) := by
  simp [point, Complex.mul_im, Complex.exp_im]

theorem point_real_iff_sin (m : Modulus) (k s : ℤ) :
    (point m k s).im = 0 ↔ Real.sin (angle m k s) = 0 := by
  rw [point_im, mul_eq_zero]
  simp [n3_real_ne_zero m]

theorem point_real_iff_divides (m : Modulus) (k s : ℤ) :
    (point m k s).im = 0 ↔ (m.n3 : ℤ) ∣ k * s := by
  rw [point_real_iff_sin, Real.sin_eq_zero_iff]
  constructor
  · rintro ⟨n, hn⟩
    have h := (eq_div_iff (n3_real_ne_zero m)).mp hn
    have hc : (n : ℝ) * (m.n3 : ℝ) = (k : ℝ) * (s : ℝ) := by
      apply mul_left_cancel₀ Real.pi_ne_zero
      convert h using 1 <;> ring
    have hi : n * (m.n3 : ℤ) = k * s := by exact_mod_cast hc
    exact ⟨n, by rw [← hi]; ring⟩
  · rintro ⟨n, hn⟩
    refine ⟨n, ?_⟩
    apply (eq_div_iff (n3_real_ne_zero m)).mpr
    have hr : (k : ℝ) * (s : ℝ) = (m.n3 : ℝ) * (n : ℝ) := by exact_mod_cast hn
    change (n : ℝ) * Real.pi * (m.n3 : ℝ) = Real.pi * (k : ℝ) * (s : ℝ)
    rw [mul_assoc Real.pi, hr]
    ring

theorem tooth1_contact_divides (m : Modulus) (t1 t2 s : ℤ) :
    ((m.n3 : ℤ) ∣ tooth1 m t1 t2 * s) ↔ (m.n3 : ℤ) ∣ t2 * s := by
  have hb : (m.n3 : ℤ) ∣ (m.n3 : ℤ) * t1 * s := ⟨t1 * s, by ring⟩
  constructor
  · intro h
    convert hb.sub h using 1; simp only [tooth1, GearboxV1.k1]; ring
  · intro h
    convert hb.sub h using 1; simp only [tooth1, GearboxV1.k1]; ring

theorem tooth2_contact_divides (m : Modulus) (t1 t2 s : ℤ) :
    ((m.n3 : ℤ) ∣ tooth2 m t1 t2 * s) ↔ (m.n3 : ℤ) ∣ t2 * s := by
  have hb : (m.n3 : ℤ) ∣ (m.n3 : ℤ) * t1 * s := ⟨t1 * s, by ring⟩
  constructor
  · intro h
    convert h.sub hb using 1; simp only [tooth2, GearboxV1.k2]; ring
  · intro h
    convert hb.add h using 1; simp only [tooth2, GearboxV1.k2]; ring

theorem z1_real_iff_divides (m : Modulus) (t1 t2 s : ℤ) :
    (z1 m t1 t2 s).im = 0 ↔ (m.n3 : ℤ) ∣ t2 * s := by
  exact (point_real_iff_divides m _ _).trans (tooth1_contact_divides m t1 t2 s)

theorem z2_real_iff_divides (m : Modulus) (t1 t2 s : ℤ) :
    (z2 m t1 t2 s).im = 0 ↔ (m.n3 : ℤ) ∣ t2 * s := by
  exact (point_real_iff_divides m _ _).trans (tooth2_contact_divides m t1 t2 s)

theorem z1_reference_contact (m : Modulus) (s : ℤ) :
    (z1 m 1 1 s).im = 0 ↔ (m.n3 : ℤ) ∣ s := by
  simpa using z1_real_iff_divides m 1 1 s

theorem z2_reference_contact (m : Modulus) (s : ℤ) :
    (z2 m 1 1 s).im = 0 ↔ (m.n3 : ℤ) ∣ s := by
  simpa using z2_real_iff_divides m 1 1 s

end
end FVLT.CoupledPointV1
