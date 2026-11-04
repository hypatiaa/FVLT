import FVLTFordBulbDataV1
open scoped BigOperators
namespace FVLT.FordBulbV1

theorem address_canonical (d : RotationAddress) :
    (address d).num = (d.p : ℤ) ∧ (address d).den = d.q := by
  simpa [address, FVLT.FareyContactV1.rawValue] using
    FVLT.FareyContactV1.rawValue_canonical (d.p : ℤ) d.q
      (Nat.lt_trans d.p_pos d.p_lt_q) (by simpa using d.coprime)

theorem address_interval (d : RotationAddress) : 0 < address d ∧ address d < 1 := by
  have hp : (0 : ℚ) < d.p := by exact_mod_cast d.p_pos
  have hq : (0 : ℚ) < d.q := by exact_mod_cast Nat.lt_trans d.p_pos d.p_lt_q
  have hpq : (d.p : ℚ) < d.q := by exact_mod_cast d.p_lt_q
  exact ⟨div_pos hp hq, (div_lt_one hq).mpr hpq⟩

theorem address_injective (d e : RotationAddress) (h : address d = address e) : d = e := by
  have hp : d.p = e.p := by
    have hi : (d.p : ℤ) = e.p := by
      rw [← (address_canonical d).1, ← (address_canonical e).1, h]
    exact_mod_cast hi
  have hq : d.q = e.q := by
    rw [← (address_canonical d).2, ← (address_canonical e).2, h]
  cases d
  cases e
  cases hp
  cases hq
  rfl

theorem q_at_least_two (d : RotationAddress) : 2 ≤ d.q := by
  have := d.p_pos
  have := d.p_lt_q
  omega

theorem modulus_pos (d : RotationAddress) : 0 < modulus d := by
  have hq := q_at_least_two d
  have hp : 1 < (2 : ℕ) ^ d.q := one_lt_pow₀ (by decide) (by omega)
  unfold modulus
  omega

theorem upper_digit_equiv (d : RotationAddress) (i : Fin d.q) :
    upperDigit d i = if d.q - d.p ≤ ((i.val + 1) * d.p) % d.q then 1 else 0 := by
  have heq : d.p + i.val * d.p = (i.val + 1) * d.p := by ring
  change (if d.q - d.p ≤ (d.p + i.val * d.p) % d.q then 1 else 0) = _
  rw [heq]

theorem lower_digit_equiv (d : RotationAddress) (i : Fin d.q) :
    1 ≤ (i.val + 1) * d.p ∧
      lowerDigit d i = if d.q - d.p ≤ ((i.val + 1) * d.p - 1) % d.q then 1 else 0 := by
  have hp : 0 < (i.val + 1) * d.p := Nat.mul_pos (by omega) d.p_pos
  have heq : d.p - 1 + i.val * d.p = (i.val + 1) * d.p - 1 := by
    rw [Nat.add_mul]
    simp only [one_mul]
    have := d.p_pos
    omega
  constructor
  · omega
  · change (if d.q - d.p ≤ (d.p - 1 + i.val * d.p) % d.q then 1 else 0) = _
    rw [heq]

theorem address_surjective (x : ℚ) (hx0 : 0 < x) (hx1 : x < 1) :
    ∃ d : RotationAddress, address d = x := by
  have hd : (0 : ℚ) < x.den := by exact_mod_cast x.den_pos
  have he : (x.num : ℚ) = x * (x.den : ℚ) :=
    (div_eq_iff hd.ne').mp (Rat.num_div_den x)
  have hnq : (0 : ℚ) < (x.num : ℚ) := by rw [he]; positivity
  have hnz : (0 : ℤ) ≤ x.num := by exact_mod_cast hnq.le
  have hnm : (x.num.natAbs : ℤ) = x.num := by
    rw [Int.natCast_natAbs, abs_of_nonneg hnz]
  have hmq : (x.num.natAbs : ℚ) = (x.num : ℚ) := by
    simpa only [Int.cast_natCast] using congrArg (fun z : ℤ => (z : ℚ)) hnm
  have hp : 0 < x.num.natAbs := by
    have hh : (0 : ℚ) < x.num.natAbs := by rw [hmq]; exact hnq
    exact_mod_cast hh
  have hpq : x.num.natAbs < x.den := by
    have hh : (x.num.natAbs : ℚ) < x.den := by
      rw [hmq, he]
      simpa using mul_lt_mul_of_pos_right hx1 hd
    exact_mod_cast hh
  refine ⟨⟨x.num.natAbs, x.den, hp, hpq, x.reduced⟩, ?_⟩
  change (x.num.natAbs : ℚ) / (x.den : ℚ) = x
  rw [hmq]
  exact Rat.num_div_den x

theorem word_sum (d : RotationAddress) (u : Fin d.q) :
    wordValue d u = ∑ i : Fin d.q, digit d u i * 2 ^ (d.q - 1 - i.val) := by
  unfold wordValue blockValue
  symm
  apply Finset.sum_bij (fun (i : Fin d.q) _ => i.val)
  · intro i hi
    exact Finset.mem_range.mpr i.isLt
  · intro i hi j hj hij
    exact Fin.ext hij
  · intro b hb
    exact ⟨⟨b, Finset.mem_range.mp hb⟩, Finset.mem_univ _, rfl⟩
  · intro i hi
    rfl

end FVLT.FordBulbV1
