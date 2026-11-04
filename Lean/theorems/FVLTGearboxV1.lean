import Mathlib.Data.Int.GCD
import Mathlib.Tactic.Ring

/-!
# Original FVLT two-tooth gearbox

Robin Miller's constructor from FVLT v3.3.0, II.5 and Remark II.5a.
Integer specialization: k₁ = N t₁ - t₂, k₂ = N t₁ + t₂.
The identities hold for arbitrary integer N; an arithmetic-progression modulus
is interpreted with N > 0. Integer subtraction is intentional.
This module proves the arithmetic interface, not prime infinitude or a phasor theorem.
-/
namespace FVLT.GearboxV1

def k1 (N t1 t2 : ℤ) : ℤ := N * t1 - t2
def k2 (N t1 t2 : ℤ) : ℤ := N * t1 + t2

theorem k1_step (N t1 t2 : ℤ) : k1 N (t1 + 1) t2 = k1 N t1 t2 + N := by
  unfold k1; ring

theorem k2_step (N t1 t2 : ℤ) : k2 N (t1 + 1) t2 = k2 N t1 t2 + N := by
  unfold k2; ring

theorem k1_shift (N t1 t2 h : ℤ) : k1 N (t1 + h) t2 = k1 N t1 t2 + N * h := by
  unfold k1; ring

theorem k2_shift (N t1 t2 h : ℤ) : k2 N (t1 + h) t2 = k2 N t1 t2 + N * h := by
  unfold k2; ring

theorem teeth_sum (N t1 t2 : ℤ) : k1 N t1 t2 + k2 N t1 t2 = 2 * N * t1 := by
  unfold k1 k2; ring

theorem teeth_gap (N t1 t2 : ℤ) : k2 N t1 t2 - k1 N t1 t2 = 2 * t2 := by
  unfold k1 k2; ring

theorem k1_residue_dvd (N t1 t2 : ℤ) : N ∣ k1 N t1 t2 - (-t2) := by
  exact ⟨t1, by unfold k1; ring⟩

theorem k2_residue_dvd (N t1 t2 : ℤ) : N ∣ k2 N t1 t2 - t2 := by
  exact ⟨t1, by unfold k2; ring⟩

theorem k1_residue (N t1 t2 : ℤ) : k1 N t1 t2 % N = (-t2) % N := by
  simp [k1, sub_eq_add_neg, Int.add_emod]

theorem k2_residue (N t1 t2 : ℤ) : k2 N t1 t2 % N = t2 % N := by
  simp [k2, Int.add_emod]

theorem k1_covers_residue (N t2 x : ℤ) :
    (N ∣ x - (-t2)) ↔ ∃ t1 : ℤ, k1 N t1 t2 = x := by
  constructor
  · rintro ⟨t1, h⟩
    exact ⟨t1, by unfold k1; rw [← h]; ring⟩
  · rintro ⟨t1, rfl⟩
    exact k1_residue_dvd N t1 t2

theorem k2_covers_residue (N t2 x : ℤ) :
    (N ∣ x - t2) ↔ ∃ t1 : ℤ, k2 N t1 t2 = x := by
  constructor
  · rintro ⟨t1, h⟩
    exact ⟨t1, by unfold k2; rw [← h]; ring⟩
  · rintro ⟨t1, rfl⟩
    exact k2_residue_dvd N t1 t2

theorem k1_gcd (N t1 t2 : ℤ) : Int.gcd (k1 N t1 t2) N = Int.gcd t2 N := by
  exact Int.gcd_mul_left_sub_left N t2 t1

theorem k2_gcd (N t1 t2 : ℤ) : Int.gcd (k2 N t1 t2) N = Int.gcd t2 N := by
  exact Int.gcd_mul_left_add_left N t2 t1

def PrimitiveOffset (N t2 : ℤ) : Prop := Int.gcd t2 N = 1

theorem k1_primitive_iff (N t1 t2 : ℤ) :
    Int.gcd (k1 N t1 t2) N = 1 ↔ PrimitiveOffset N t2 := by
  rw [k1_gcd]; rfl

theorem k2_primitive_iff (N t1 t2 : ℤ) :
    Int.gcd (k2 N t1 t2) N = 1 ↔ PrimitiveOffset N t2 := by
  rw [k2_gcd]; rfl

theorem k1_reference (N : ℤ) : k1 N 1 1 = N - 1 := by simp [k1]
theorem k2_reference (N : ℤ) : k2 N 1 1 = N + 1 := by simp [k2]

theorem k1_unit_offset_primitive (N t1 : ℤ) : Int.gcd (k1 N t1 1) N = 1 := by
  simp [k1_gcd]
theorem k2_unit_offset_primitive (N t1 : ℤ) : Int.gcd (k2 N t1 1) N = 1 := by
  simp [k2_gcd]

end FVLT.GearboxV1
