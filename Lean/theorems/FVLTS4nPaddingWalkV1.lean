import FVLTWovenCanonicalV1
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Algebra.Ring.Parity

/-! Descriptive padding arithmetic only. No prime-frequency or CA-center claim. -/
namespace FVLT.S4nPaddingWalkV1

def lip (C t : ℕ) : ℕ := 2*t+C
def inverseTwo (d : ℕ) : ℕ := (d+1)/2
def phase (C d : ℕ) : ℕ :=
  ((-(C : ℤ)*(inverseTwo d : ℤ)) % (d : ℤ)).toNat
def firstMultiplier (C d : ℕ) : ℕ := lip C (phase C d) / d

theorem inverseTwo_spec (d : ℕ) (hd : Odd d) : 2*inverseTwo d=d+1 := by
  have ho := Nat.odd_iff.mp hd
  unfold inverseTwo
  omega

theorem phase_cast (C d : ℕ) (hd : 0<d) :
    (phase C d : ℤ) = (-(C : ℤ)*(inverseTwo d : ℤ)) % (d : ℤ) := by
  unfold phase
  exact Int.toNat_of_nonneg (Int.emod_nonneg _ (by exact_mod_cast Nat.ne_of_gt hd))

theorem phase_lt (C d : ℕ) (hd : 0<d) : phase C d<d := by
  have h := Int.emod_lt_of_pos (-(C : ℤ)*(inverseTwo d : ℤ))
    (show 0<(d : ℤ) by exact_mod_cast hd)
  rw [← phase_cast C d hd] at h
  exact_mod_cast h

theorem phase_contact (C d : ℕ) (hd : 0<d) (ho : Odd d) : d ∣ lip C (phase C d) := by
  have hi : 2*(inverseTwo d : ℤ)=(d : ℤ)+1 := by exact_mod_cast inverseTwo_spec d ho
  let a : ℤ := -(C : ℤ)*(inverseTwo d : ℤ)
  have hm : Int.ModEq (d : ℤ) (phase C d : ℤ) a := by
    rw [phase_cast C d hd]
    exact Int.mod_modEq a (d : ℤ)
  have hdiff : (d : ℤ) ∣ a-(phase C d : ℤ) := Int.modEq_iff_dvd.mp hm
  have hbase : (d : ℤ) ∣ 2*a+(C : ℤ) := by
    refine ⟨-(C : ℤ), ?_⟩
    dsimp [a]
    calc
      2*(-(C : ℤ)*(inverseTwo d : ℤ))+(C : ℤ) =
          -(C : ℤ)*(2*(inverseTwo d : ℤ)-1) := by ring
      _ = (d : ℤ)*(-(C : ℤ)) := by rw [hi]; ring
  have hh := dvd_sub hbase (dvd_mul_of_dvd_right hdiff (2 : ℤ))
  have hz : (d : ℤ) ∣ 2*(phase C d : ℤ)+(C : ℤ) := by
    convert hh using 1 <;> ring
  unfold lip
  exact_mod_cast hz

theorem odd_cancel_two (d : ℕ) (ho : Odd d) (x : ℤ)
    (h : (d : ℤ) ∣ 2*x) : (d : ℤ) ∣ x := by
  obtain ⟨q,hq⟩ := ho.exists_bit1
  have hqz : (d : ℤ)=2*(q : ℤ)+1 := by exact_mod_cast hq
  have hh := dvd_sub (dvd_mul_right (d : ℤ) x)
    (dvd_mul_of_dvd_right h (q : ℤ))
  convert hh using 1 <;> rw [hqz] <;> ring

theorem contact_iff_residue (C d t : ℕ) (hd : 0<d) (ho : Odd d) :
    d ∣ lip C t ↔ t % d=phase C d := by
  constructor
  · intro ht
    have h0 : (d : ℤ) ∣ 2*(phase C d : ℤ)+(C : ℤ) := by
      exact_mod_cast phase_contact C d hd ho
    have h1 : (d : ℤ) ∣ 2*(t : ℤ)+(C : ℤ) := by
      exact_mod_cast ht
    have hh : (d : ℤ) ∣ 2*((t : ℤ)-(phase C d : ℤ)) := by
      convert dvd_sub h1 h0 using 1 <;> ring
    have hm := Int.modEq_iff_dvd.mpr (odd_cancel_two d ho _ hh)
    have he : (phase C d : ℤ) % (d : ℤ)=(t : ℤ) % (d : ℤ) := hm
    have hn : phase C d % d=t % d := by exact_mod_cast he
    simpa [Nat.mod_eq_of_lt (phase_lt C d hd)] using hn.symm
  · intro he
    have hp := phase_contact C d hd ho
    have ht : t=phase C d+d*(t/d) := by
      have h := Nat.mod_add_div t d
      omega
    rw [ht]
    rcases hp with ⟨k,hk⟩
    refine ⟨k+2*(t/d), ?_⟩
    unfold lip at hk ⊢
    nlinarith

theorem contact_iff_progression (C d t : ℕ) (hd : 0<d) (ho : Odd d) :
    d ∣ lip C t ↔ ∃ s : ℕ, t=phase C d+s*d := by
  rw [contact_iff_residue C d t hd ho]
  constructor
  · intro he
    refine ⟨t/d, ?_⟩
    have h := Nat.mod_add_div t d
    nlinarith
  · rintro ⟨s,rfl⟩
    simp [Nat.add_mod, Nat.mod_eq_of_lt (phase_lt C d hd)]

theorem first_lip_eq (C d : ℕ) (hd : 0<d) (ho : Odd d) :
    lip C (phase C d)=firstMultiplier C d*d := by
  exact (Nat.div_mul_cancel (phase_contact C d hd ho)).symm

theorem progression_lip (C d s : ℕ) (hd : 0<d) (ho : Odd d) :
    lip C (phase C d+s*d)=(firstMultiplier C d+2*s)*d := by
  have h := first_lip_eq C d hd ho
  unfold lip at h ⊢
  nlinarith

theorem firstMultiplier_pos (C d : ℕ) (hC : 0<C) (hd : 0<d) (ho : Odd d) :
    0<firstMultiplier C d := by
  have h := first_lip_eq C d hd ho
  by_contra hn
  have hz : firstMultiplier C d=0 := by omega
  rw [hz] at h
  unfold lip at h
  omega

theorem firstMultiplier_odd (C d : ℕ) (hC : Odd C) (hd : 0<d) (ho : Odd d) :
    Odd (firstMultiplier C d) := by
  apply Nat.odd_iff.mpr
  have hc := Nat.odd_iff.mp hC
  have hd2 := Nat.odd_iff.mp ho
  have hl : (lip C (phase C d))%2=1 := by simp [lip,Nat.add_mod,Nat.mul_mod,hc]
  rw [first_lip_eq C d hd ho] at hl
  simpa [Nat.mul_mod,hd2] using hl

theorem prime_first_iff (C d : ℕ) (hd : 3≤d) (ho : Odd d) :
    Nat.Prime (lip C (phase C d)) ↔ Nat.Prime d ∧ firstMultiplier C d=1 := by
  rw [first_lip_eq C d (by omega) ho, Nat.prime_mul_iff]
  simp [show d≠1 by omega]

theorem later_lip_not_prime (C d s : ℕ) (hC : 0<C) (hd : 3≤d)
    (ho : Odd d) (hs : 1≤s) : ¬Nat.Prime (lip C (phase C d+s*d)) := by
  rw [progression_lip C d s (by omega) ho]
  have hk := firstMultiplier_pos C d hC (by omega) ho
  exact Nat.not_prime_mul (by omega) (by omega)

theorem adjacent_coprime (C t : ℕ) (hC : Odd C) :
    Nat.gcd (lip C t) (lip C (t+1))=1 := by
  let g := Nat.gcd (lip C t) (lip C (t+1))
  have hl : g ∣ lip C t := Nat.gcd_dvd_left _ _
  have hr : g ∣ lip C (t+1) := Nat.gcd_dvd_right _ _
  have htwo : g ∣ 2 := by
    have hh := Nat.dvd_sub hr hl
    have he : lip C (t+1)-lip C t=2 := by unfold lip; omega
    rwa [he] at hh
  rcases Nat.prime_two.eq_one_or_self_of_dvd g htwo with h | h
  · exact h
  · have hodd : Odd (lip C t) := Nat.odd_iff.mpr (by
      simp [lip,Nat.add_mod,Nat.mul_mod,Nat.odd_iff.mp hC])
    rw [h] at hl
    exact False.elim (hodd.not_two_dvd_nat hl)

theorem phase_shift (C D d : ℕ) (hd : 0<d) (ho : Odd d)
    (h : C % d=D % d) : phase C d=phase D d := by
  have hc := phase_contact C d hd ho
  have hmod : lip C (phase C d) % d=lip D (phase C d) % d := by
    simp [lip,Nat.add_mod,h]
  have hz : lip D (phase C d) % d=0 := by rw [←hmod]; exact Nat.mod_eq_zero_of_dvd hc
  have hh := (contact_iff_residue D d (phase C d) hd ho).mp (Nat.dvd_of_mod_eq_zero hz)
  simpa [Nat.mod_eq_of_lt (phase_lt C d hd)] using hh

theorem phase_of_divisor_ge_padding (C d : ℕ) (hC : Odd C) (ho : Odd d)
    (hd : 0<d) (hCd : C≤d) : phase C d=(d-C)/2 := by
  have hc := Nat.odd_iff.mp hC
  have hd2 := Nat.odd_iff.mp ho
  have he : lip C ((d-C)/2)=d := by unfold lip; omega
  have h := (contact_iff_residue C d ((d-C)/2) hd ho).mp (by
    simpa only [he] using dvd_refl d)
  have ht : (d-C)/2<d := by omega
  simpa [Nat.mod_eq_of_lt ht] using h.symm

theorem firstMultiplier_one_of_ge (C d : ℕ) (hC : Odd C) (ho : Odd d)
    (hd : 0<d) (hCd : C≤d) : firstMultiplier C d=1 := by
  rw [firstMultiplier,phase_of_divisor_ge_padding C d hC ho hd hCd]
  have he : lip C ((d-C)/2)=d := by
    have hc := Nat.odd_iff.mp hC
    have hh := Nat.odd_iff.mp ho
    unfold lip
    omega
  rw [he,Nat.div_self hd]

theorem padding15_divisor5_counterexample : phase 15 5=0 ∧ lip 15 (phase 15 5)=15 := by decide
theorem padding5_divisor9_not_prime : firstMultiplier 5 9=1 ∧ ¬Nat.Prime (lip 5 (phase 5 9)) := by decide
theorem padding_phase_changes : phase 5 3=2 ∧ phase 7 3=1 := by decide

end FVLT.S4nPaddingWalkV1
