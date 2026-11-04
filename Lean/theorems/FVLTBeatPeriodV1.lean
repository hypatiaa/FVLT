import Mathlib.Analysis.SpecialFunctions.Complex.CircleAddChar
import Mathlib.Data.Int.NatAbs
import Mathlib.Data.Nat.GCD.Basic
import Mathlib.Tactic

/-!
Exact integer beat periods in the common cyclic clock P*Q. Positive input
periods are required, but equality and the singleton clock are not excluded.
No global Hopf-fibration, energy or Rule30 prize theorem is asserted.
-/
noncomputable section
namespace FVLT.BeatPeriodV1

theorem addOrderOf_intCast (M : ℕ) [NeZero M] (a : ℤ) :
    addOrderOf (a : ZMod M) = M / Nat.gcd M a.natAbs := by
  obtain ⟨n, hn | hn⟩ := Int.eq_nat_or_neg a
  · subst a
    simpa using ZMod.addOrderOf_coe n (NeZero.ne M)
  · subst a
    simpa using ZMod.addOrderOf_coe n (NeZero.ne M)

theorem character_eq_one_iff {M : ℕ} [NeZero M] (z : ZMod M) :
    ZMod.stdAddChar z = 1 ↔ z = 0 := by
  rw [← (ZMod.stdAddChar (N := M)).map_zero_eq_one]
  exact ZMod.injective_stdAddChar.eq_iff

theorem intCast_isUnit_of_coprime (M : ℕ) (a : ℤ)
    (h : Nat.Coprime a.natAbs M) : IsUnit (a : ZMod M) := by
  obtain ⟨n, hn | hn⟩ := Int.eq_nat_or_neg a
  · subst a
    simpa using (ZMod.isUnit_iff_coprime n M).mpr (by simpa using h)
  · subst a
    have hu : IsUnit (n : ZMod M) :=
      (ZMod.isUnit_iff_coprime n M).mpr (by simpa using h)
    simpa using hu.neg

variable (P Q : ℕ) [NeZero P] [NeZero Q]

instance clock_neZero : NeZero (P * Q) :=
  ⟨Nat.mul_ne_zero (NeZero.ne P) (NeZero.ne Q)⟩

def frequency : ZMod (P * Q) := (((Q : ℤ) - (P : ℤ) : ℤ) : ZMod (P * Q))

def beatCyclic (z : ZMod (P * Q)) : ℂ := ZMod.stdAddChar (frequency P Q * z)

def beat (t : ℤ) : ℂ := beatCyclic P Q (t : ZMod (P * Q))

def leastPeriod : ℕ := (P * Q) / Nat.gcd (P * Q) ((Q : ℤ) - (P : ℤ)).natAbs

theorem frequency_order : addOrderOf (frequency P Q) = leastPeriod P Q := by
  exact addOrderOf_intCast (P * Q) ((Q : ℤ) - (P : ℤ))

theorem leastPeriod_pos : 0 < leastPeriod P Q := by
  rw [← frequency_order P Q]
  exact addOrderOf_pos _

theorem beat_period_iff (n : ℕ) :
    Function.Periodic (beat P Q) (n : ℤ) ↔ leastPeriod P Q ∣ n := by
  rw [← frequency_order P Q]
  constructor
  · intro h
    have hz := h 0
    have hk : frequency P Q * (n : ZMod (P * Q)) = 0 := by
      apply (character_eq_one_iff _).mp
      simpa [beat, beatCyclic, AddChar.map_zero_eq_one] using hz
    apply addOrderOf_dvd_iff_nsmul_eq_zero.mpr
    simpa [nsmul_eq_mul, mul_comm] using hk
  · intro h t
    have hk : frequency P Q * (n : ZMod (P * Q)) = 0 := by
      have hs := addOrderOf_dvd_iff_nsmul_eq_zero.mp h
      simpa [nsmul_eq_mul, mul_comm] using hs
    simp only [beat, beatCyclic, Int.cast_add, Int.cast_natCast, mul_add, hk, add_zero]

theorem leastPeriod_isLeast :
    IsLeast {n : ℕ | 0 < n ∧ Function.Periodic (beat P Q) (n : ℤ)} (leastPeriod P Q) := by
  constructor
  · exact ⟨leastPeriod_pos P Q, (beat_period_iff P Q _).mpr dvd_rfl⟩
  · intro n hn
    exact Nat.le_of_dvd hn.1 ((beat_period_iff P Q n).mp hn.2)

/-- Same clock, with the two phase channels still visible. -/
theorem beat_common_clock_ratio (z : ZMod (P * Q)) :
    beatCyclic P Q z =
      ZMod.stdAddChar ((Q : ZMod (P * Q)) * z) /
        ZMod.stdAddChar ((P : ZMod (P * Q)) * z) := by
  simp only [beatCyclic, frequency, Int.cast_sub, Int.cast_natCast, sub_mul,
    AddChar.map_sub_eq_div]

theorem beat_eq_exp (t : ℤ) :
    beat P Q t = Complex.exp
      (2 * Real.pi * Complex.I * (t : ℂ) * (1 / (P : ℂ) - 1 / (Q : ℂ))) := by
  have hP : (P : ℂ) ≠ 0 := by exact_mod_cast NeZero.ne P
  have hQ : (Q : ℂ) ≠ 0 := by exact_mod_cast NeZero.ne Q
  unfold beat beatCyclic frequency
  rw [← Int.cast_mul, ZMod.stdAddChar_coe]
  congr 1
  push_cast
  field_simp [hP, hQ]

theorem equal_inputs_period : leastPeriod P P = 1 := by
  unfold leastPeriod
  simp only [sub_self, Int.natAbs_zero, Nat.gcd_zero_right]
  exact Nat.div_self (Nat.mul_pos (Nat.pos_of_ne_zero (NeZero.ne P))
    (Nat.pos_of_ne_zero (NeZero.ne P)))

theorem equal_inputs_beat (t : ℤ) : beat P P t = 1 := by
  simp [beat, beatCyclic, frequency, AddChar.map_zero_eq_one]

theorem unit_corner_period : leastPeriod 1 1 = 1 := by
  exact equal_inputs_period 1

theorem coprime_clock_difference (h : Nat.Coprime P Q) :
    Nat.Coprime (P * Q) ((Q : ℤ) - (P : ℤ)).natAbs := by
  rcases le_total P Q with hpq | hqp
  · rw [Int.natAbs_natCast_sub_natCast_of_ge hpq]
    exact ((Nat.coprime_sub_self_right hpq).mpr (by simpa [Nat.coprime_comm] using h)).mul_left
      ((Nat.coprime_self_sub_right hpq).mpr (by simpa [Nat.coprime_comm] using h))
  · rw [Int.natAbs_natCast_sub_natCast_of_le hqp]
    exact ((Nat.coprime_self_sub_right hqp).mpr (by simpa [Nat.coprime_comm] using h)).mul_left
      ((Nat.coprime_sub_self_right hqp).mpr (by simpa [Nat.coprime_comm] using h))

theorem coprime_period (h : Nat.Coprime P Q) : leastPeriod P Q = P * Q := by
  have hg := (coprime_clock_difference P Q h).gcd_eq_one
  simp only [leastPeriod, hg, Nat.div_one]

theorem coprime_frequency_unit (h : Nat.Coprime P Q) : IsUnit (frequency P Q) :=
  intCast_isUnit_of_coprime (P * Q) ((Q : ℤ) - (P : ℤ))
    (coprime_clock_difference P Q h).symm

/-- Bijection is on the finite clock, not onto all complex numbers or the circle. -/
theorem coprime_multiplier_bijective (h : Nat.Coprime P Q) :
    Function.Bijective (fun z : ZMod (P * Q) => frequency P Q * z) := by
  have hu := coprime_frequency_unit P Q h
  let u : (ZMod (P * Q))ˣ := hu.unit
  have he : (u : ZMod (P * Q)) = frequency P Q := hu.unit_spec
  constructor
  · intro x y hxy
    have hh := congrArg (fun z : ZMod (P * Q) => ((u⁻¹ : (ZMod (P * Q))ˣ) : ZMod (P * Q)) * z) hxy
    simpa [← he, ← mul_assoc] using hh
  · intro y
    refine ⟨((u⁻¹ : (ZMod (P * Q))ˣ) : ZMod (P * Q)) * y, ?_⟩
    simp [← he, ← mul_assoc]

theorem coprime_beatCyclic_injective (h : Nat.Coprime P Q) :
    Function.Injective (beatCyclic P Q) := by
  intro x y he
  apply (coprime_multiplier_bijective P Q h).1
  exact ZMod.injective_stdAddChar he

end FVLT.BeatPeriodV1
