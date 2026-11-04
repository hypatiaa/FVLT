import FVLTFordBulbDataV1
import Mathlib.Data.Nat.ModEq
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

private theorem binary_block_rec (p q u n : ℕ) :
    blockValue p q u (n + 1) = 2 * blockValue p q u n + rawDigit p q u n := by
  unfold blockValue
  rw [Finset.sum_range_succ]
  simp only [Nat.add_sub_cancel, Nat.sub_self, pow_zero, mul_one]
  have hs : (∑ i ∈ Finset.range n, rawDigit p q u i * 2 ^ (n - i)) =
      2 * (∑ i ∈ Finset.range n, rawDigit p q u i * 2 ^ (n - 1 - i)) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i hi
    have hi' : i < n := Finset.mem_range.mp hi
    have he : n - i = (n - 1 - i) + 1 := by omega
    rw [he, pow_succ]
    ring
  rw [hs]

private theorem raw_digit_carry (d : RotationAddress) (u : Fin d.q) (n : ℕ) :
    (u.val + (n + 1) * d.p) / d.q =
      (u.val + n * d.p) / d.q + rawDigit d.p d.q u.val n := by
  have hq : 0 < d.q := Nat.lt_trans d.p_pos d.p_lt_q
  have he : u.val + (n + 1) * d.p = (u.val + n * d.p) + d.p := by ring
  rw [he, Nat.add_div hq, Nat.div_eq_of_lt d.p_lt_q, Nat.mod_eq_of_lt d.p_lt_q]
  have hc : d.q ≤ (u.val + n * d.p) % d.q + d.p ↔
      d.q - d.p ≤ (u.val + n * d.p) % d.q := by
    have := d.p_lt_q
    omega
  simp only [Nat.add_zero, hc, rawDigit]

private theorem raw_digit_prefix_count (d : RotationAddress) (u : Fin d.q) (n : ℕ) :
    (∑ i ∈ Finset.range n, rawDigit d.p d.q u.val i) = (u.val + n * d.p) / d.q := by
  induction n with
  | zero => simp [Nat.div_eq_of_lt u.isLt]
  | succ n ih =>
    rw [Finset.sum_range_succ, ih]
    exact (raw_digit_carry d u n).symm

private theorem raw_digit_full_count (d : RotationAddress) (u : Fin d.q) :
    (∑ i ∈ Finset.range d.q, rawDigit d.p d.q u.val i) = d.p := by
  rw [raw_digit_prefix_count]
  rw [Nat.add_mul_div_left u.val d.p (Nat.lt_trans d.p_pos d.p_lt_q)]
  simp [Nat.div_eq_of_lt u.isLt]

private theorem binary_count_bounds (p q u n : ℕ) :
    blockValue p q u n ≤ 2 ^ n - 1 ∧
    (∑ i ∈ Finset.range n, rawDigit p q u i) ≤ blockValue p q u n ∧
    blockValue p q u n + n ≤ 2 ^ n - 1 +
      (∑ i ∈ Finset.range n, rawDigit p q u i) := by
  induction n with
  | zero => simp [blockValue]
  | succ n ih =>
    have hb : rawDigit p q u n ≤ 1 := by unfold rawDigit; split <;> omega
    have hp : 1 ≤ (2 : ℕ) ^ n := Nat.one_le_pow n 2 (by decide)
    rw [binary_block_rec, Finset.sum_range_succ, pow_succ]
    rcases ih with ⟨h1, h2, h3⟩
    omega


theorem word_bounds (d : RotationAddress) (u : Fin d.q) :
    0 < wordValue d u ∧ wordValue d u < modulus d := by
  have hc := raw_digit_full_count d u
  have hb := binary_count_bounds d.p d.q u.val d.q
  have hp := d.p_pos
  have hpq := d.p_lt_q
  change 0 < blockValue d.p d.q u.val d.q ∧
    blockValue d.p d.q u.val d.q < 2 ^ d.q - 1
  omega

private theorem nondividing_pred_quotient (a q : ℕ) (hq : 0 < q) (hn : ¬ q ∣ a) :
    (a - 1) / q = a / q := by
  have hr : 0 < a % q := Nat.pos_of_ne_zero (by
    intro h
    exact hn (Nat.dvd_of_mod_eq_zero h))
  have he := Nat.div_add_mod a q
  have hb := Nat.mod_lt a hq
  have ha : 0 < a := by omega
  have hpred : a - 1 + 1 = a := Nat.sub_add_cancel (by omega)
  apply Nat.div_eq_of_lt_le <;> nlinarith

private theorem characteristic_prefix_counts_equal (d : RotationAddress) (n : ℕ)
    (hn : n + 1 < d.q) :
    (d.p + n * d.p) / d.q = (d.p - 1 + n * d.p) / d.q := by
  have hq : 0 < d.q := Nat.lt_trans d.p_pos d.p_lt_q
  have hnd : ¬ d.q ∣ (n + 1) * d.p := by
    intro h
    have hdiv := d.coprime.symm.dvd_of_dvd_mul_right h
    have hle := Nat.le_of_dvd (by omega : 0 < n + 1) hdiv
    omega
  have h1 : d.p + n * d.p = (n + 1) * d.p := by ring
  have h2 : d.p - 1 + n * d.p = (n + 1) * d.p - 1 := by
    rw [Nat.add_mul]
    simp only [one_mul]
    have := d.p_pos
    omega
  rw [h1, h2]
  exact (nondividing_pred_quotient _ _ hq hnd).symm

private theorem characteristic_early_digit_equal (d : RotationAddress) (n : ℕ)
    (hn : n + 2 < d.q) :
    rawDigit d.p d.q d.p n = rawDigit d.p d.q (d.p - 1) n := by
  have h0 := characteristic_prefix_counts_equal d n (by omega)
  have h1 := characteristic_prefix_counts_equal d (n + 1) (by omega)
  have hu := raw_digit_carry d (upperIndex d) n
  have hl := raw_digit_carry d (lowerIndex d) n
  change (d.p + (n + 1) * d.p) / d.q =
    (d.p + n * d.p) / d.q + rawDigit d.p d.q d.p n at hu
  change (d.p - 1 + (n + 1) * d.p) / d.q =
    (d.p - 1 + n * d.p) / d.q + rawDigit d.p d.q (d.p - 1) n at hl
  omega

private theorem characteristic_early_block_equal (d : RotationAddress) (n : ℕ)
    (hn : n + 1 < d.q) :
    blockValue d.p d.q d.p n = blockValue d.p d.q (d.p - 1) n := by
  induction n with
  | zero => simp [blockValue]
  | succ n ih =>
    rw [binary_block_rec, binary_block_rec, ih (by omega),
      characteristic_early_digit_equal d n (by omega)]

private theorem characteristic_final_digits (d : RotationAddress) :
    rawDigit d.p d.q d.p (d.q - 2) = 1 ∧
    rawDigit d.p d.q (d.p - 1) (d.q - 2) = 0 ∧
    rawDigit d.p d.q d.p (d.q - 1) = 0 ∧
    rawDigit d.p d.q (d.p - 1) (d.q - 1) = 1 := by
  have hq2 := q_at_least_two d
  have hq : 0 < d.q := by omega
  have hp := d.p_pos
  have hpsub : d.p - 1 + 1 = d.p := by omega
  have hpred : d.q - 1 + 1 = d.q := by omega
  have hpre : d.q - 2 + 1 = d.q - 1 := by omega
  have heU : d.p + (d.q - 1) * d.p = d.q * d.p := by
    nlinarith [congrArg (fun n : ℕ => n * d.p) hpred]
  have heL : d.p - 1 + (d.q - 1) * d.p = d.q * d.p - 1 := by
    have hprod : 0 < d.q * d.p := Nat.mul_pos hq hp
    omega
  have cu : (d.p + (d.q - 1) * d.p) / d.q = d.p := by
    rw [heU]
    exact Nat.mul_div_cancel_left _ hq
  have cl : (d.p - 1 + (d.q - 1) * d.p) / d.q = d.p - 1 := by
    rw [heL]
    simpa using Nat.mul_sub_div 0 d.q d.p (Nat.mul_pos hq hp)
  have fu := raw_digit_full_count d (upperIndex d)
  have fl := raw_digit_full_count d (lowerIndex d)
  rw [raw_digit_prefix_count] at fu fl
  change (d.p + d.q * d.p) / d.q = d.p at fu
  change (d.p - 1 + d.q * d.p) / d.q = d.p at fl
  have hu1 := raw_digit_carry d (upperIndex d) (d.q - 1)
  have hl1 := raw_digit_carry d (lowerIndex d) (d.q - 1)
  have hu2 := raw_digit_carry d (upperIndex d) (d.q - 2)
  have hl2 := raw_digit_carry d (lowerIndex d) (d.q - 2)
  change (d.p + (d.q - 1 + 1) * d.p) / d.q =
    (d.p + (d.q - 1) * d.p) / d.q + rawDigit d.p d.q d.p (d.q - 1) at hu1
  change (d.p - 1 + (d.q - 1 + 1) * d.p) / d.q =
    (d.p - 1 + (d.q - 1) * d.p) / d.q + rawDigit d.p d.q (d.p - 1) (d.q - 1) at hl1
  change (d.p + (d.q - 2 + 1) * d.p) / d.q =
    (d.p + (d.q - 2) * d.p) / d.q + rawDigit d.p d.q d.p (d.q - 2) at hu2
  change (d.p - 1 + (d.q - 2 + 1) * d.p) / d.q =
    (d.p - 1 + (d.q - 2) * d.p) / d.q + rawDigit d.p d.q (d.p - 1) (d.q - 2) at hl2
  rw [hpred, fu, cu] at hu1
  rw [hpred, fl, cl] at hl1
  rw [hpre, cu] at hu2
  rw [hpre, cl] at hl2
  have hc := characteristic_prefix_counts_equal d (d.q - 2) (by omega)
  have hb : rawDigit d.p d.q d.p (d.q - 2) ≤ 1 := by unfold rawDigit; split <;> omega
  omega


theorem characteristic_adjacent (d : RotationAddress) : upperNumerator d = lowerNumerator d + 1 := by
  have hq := q_at_least_two d
  have h1 : d.q - 2 + 1 = d.q - 1 := by omega
  have h2 : d.q - 1 + 1 = d.q := by omega
  have he := characteristic_early_block_equal d (d.q - 2) (by omega)
  rcases characteristic_final_digits d with ⟨hu2, hl2, hu1, hl1⟩
  have ru2 := binary_block_rec d.p d.q d.p (d.q - 2)
  have rl2 := binary_block_rec d.p d.q (d.p - 1) (d.q - 2)
  have ru1 := binary_block_rec d.p d.q d.p (d.q - 1)
  have rl1 := binary_block_rec d.p d.q (d.p - 1) (d.q - 1)
  rw [h1, hu2] at ru2
  rw [h1, hl2] at rl2
  rw [h2, hu1] at ru1
  rw [h2, hl1] at rl1
  change blockValue d.p d.q d.p d.q = blockValue d.p d.q (d.p - 1) d.q + 1
  omega

theorem characteristic_bounds (d : RotationAddress) :
    0 < lowerNumerator d ∧ lowerNumerator d < upperNumerator d ∧ upperNumerator d < modulus d := by
  have hl := word_bounds d (lowerIndex d)
  have hu := word_bounds d (upperIndex d)
  have he := characteristic_adjacent d
  change 0 < lowerNumerator d ∧ lowerNumerator d < modulus d at hl
  change 0 < upperNumerator d ∧ upperNumerator d < modulus d at hu
  omega

theorem characteristic_angle_gap (d : RotationAddress) :
    upperAngle d - lowerAngle d = 1 / (modulus d : ℚ) := by
  unfold upperAngle lowerAngle
  rw [characteristic_adjacent]
  push_cast
  ring

private theorem rational_cross_strict (x y : ℚ) (h : x < y) :
    x.num * (y.den : ℤ) < y.num * (x.den : ℤ) := by
  have hx : (0 : ℚ) < x.den := by exact_mod_cast x.den_pos
  have hy : (0 : ℚ) < y.den := by exact_mod_cast y.den_pos
  have hc : (x.num : ℚ) * y.den < (y.num : ℚ) * x.den := by
    apply (div_lt_div_iff₀ hx hy).mp
    simpa only [Rat.num_div_den] using h
  exact_mod_cast hc

private theorem farey_oriented_unit (x y : ℚ) (hxy : x < y)
    (hadj : FVLT.FareyContactV1.fareyAdj x y) :
    (x.den : ℤ) * y.num - x.num * (y.den : ℤ) = 1 := by
  have hp := rational_cross_strict x y hxy
  have hu : |(x.den : ℤ) * y.num - x.num * (y.den : ℤ)| = 1 := by
    simpa [FVLT.FareyContactV1.fareyAdj, FVLT.FareyContactV1.det, abs_sub_comm,
      mul_comm] using hadj
  rwa [abs_of_pos (by nlinarith)] at hu

private theorem farey_interval_frame (x y z : ℚ) (hxy : x < y)
    (hadj : FVLT.FareyContactV1.fareyAdj x y) (hxz : x < z) (hzy : z < y) :
    1 ≤ z.num * (x.den : ℤ) - x.num * (z.den : ℤ) ∧
    1 ≤ y.num * (z.den : ℤ) - z.num * (y.den : ℤ) ∧
    (y.num * (z.den : ℤ) - z.num * (y.den : ℤ)) * (x.den : ℤ) +
      (z.num * (x.den : ℤ) - x.num * (z.den : ℤ)) * (y.den : ℤ) = z.den ∧
    (y.num * (z.den : ℤ) - z.num * (y.den : ℤ)) * x.num +
      (z.num * (x.den : ℤ) - x.num * (z.den : ℤ)) * y.num = z.num := by
  have hdet := farey_oriented_unit x y hxy hadj
  have hl := rational_cross_strict x z hxz
  have hr := rational_cross_strict z y hzy
  refine ⟨by omega, by omega, ?_, ?_⟩
  · calc
      _ = (z.den : ℤ) * ((x.den : ℤ) * y.num - x.num * (y.den : ℤ)) := by ring
      _ = (z.den : ℤ) := by rw [hdet, mul_one]
  · calc
      _ = z.num * ((x.den : ℤ) * y.num - x.num * (y.den : ℤ)) := by ring
      _ = z.num := by rw [hdet, mul_one]

private theorem positive_frame_bound (A B X Y Z : ℤ) (hA : 1 ≤ A) (hB : 1 ≤ B)
    (hX : 0 < X) (hY : 0 < Y) (he : B * X + A * Y = Z) : X + Y ≤ Z := by
  nlinarith [mul_nonneg (sub_nonneg.mpr hA) hY.le,
    mul_nonneg (sub_nonneg.mpr hB) hX.le]

private theorem positive_frame_unit (A B X Y : ℤ) (hA : 1 ≤ A) (hB : 1 ≤ B)
    (hX : 0 < X) (hY : 0 < Y) (he : B * X + A * Y = X + Y) : A = 1 ∧ B = 1 := by
  have hx : 0 ≤ X - 1 := by omega
  have hy : 0 ≤ Y - 1 := by omega
  have hm1 := mul_nonneg (sub_nonneg.mpr hA) hy
  have hm2 := mul_nonneg (sub_nonneg.mpr hB) hx
  constructor <;> nlinarith


theorem characteristic_period_return (d : RotationAddress) (n : ℕ)
    (hn : n = lowerNumerator d ∨ n = upperNumerator d) : iterateNum d n d.q = n := by
  have hpow : (2 : ℕ) ^ d.q = modulus d + 1 := by
    have hp := modulus_pos d
    unfold modulus at *
    omega
  have hbound : n < modulus d := by
    rcases hn with rfl | rfl
    · exact (characteristic_bounds d).2.1.trans (characteristic_bounds d).2.2
    · exact (characteristic_bounds d).2.2
  unfold iterateNum
  rw [hpow]
  simp [Nat.add_mul, Nat.add_mod, Nat.mod_eq_of_lt hbound]

theorem farey_denominator_min (x y z : ℚ) (hxy : x < y)
    (hadj : FVLT.FareyContactV1.fareyAdj x y) (hxz : x < z) (hzy : z < y) :
    x.den + y.den ≤ z.den := by
  rcases farey_interval_frame x y z hxy hadj hxz hzy with ⟨hA, hB, he, hn⟩
  have hX : (0 : ℤ) < x.den := by exact_mod_cast x.den_pos
  have hY : (0 : ℤ) < y.den := by exact_mod_cast y.den_pos
  have hh := positive_frame_bound _ _ _ _ _ hA hB hX hY he
  exact_mod_cast hh

theorem farey_denominator_eq_iff (x y z : ℚ) (hxy : x < y)
    (hadj : FVLT.FareyContactV1.fareyAdj x y) (hxz : x < z) (hzy : z < y) :
    z.den = x.den + y.den ↔ z = FVLT.FareyContactV1.mediant x y := by
  constructor
  · intro heq
    rcases farey_interval_frame x y z hxy hadj hxz hzy with ⟨hA, hB, hd, hn⟩
    have hX : (0 : ℤ) < x.den := by exact_mod_cast x.den_pos
    have hY : (0 : ℤ) < y.den := by exact_mod_cast y.den_pos
    have hs : (z.den : ℤ) = (x.den : ℤ) + (y.den : ℤ) := by exact_mod_cast heq
    have hu := positive_frame_unit _ _ _ _ hA hB hX hY (hd.trans hs)
    rw [hu.1, hu.2] at hn
    simp only [one_mul] at hn
    unfold FVLT.FareyContactV1.mediant FVLT.FareyContactV1.rawValue
    rw [hn, ← heq]
    exact (Rat.num_div_den z).symm
  · intro hz
    rw [hz]
    exact (FVLT.FareyContactV1.adjacent_mediant x y hxy hadj).2.2.1

private theorem raw_digit_le_one (p q u i : ℕ) : rawDigit p q u i ≤ 1 := by
  unfold rawDigit
  split <;> omega

private theorem binary_equal_count (p q u v n : ℕ)
    (h : blockValue p q u n = blockValue p q v n) :
    (∑ i ∈ Finset.range n, rawDigit p q u i) =
      ∑ i ∈ Finset.range n, rawDigit p q v i := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [binary_block_rec, binary_block_rec] at h
    have hu := raw_digit_le_one p q u n
    have hv := raw_digit_le_one p q v n
    have he : blockValue p q u n = blockValue p q v n := by omega
    have hb : rawDigit p q u n = rawDigit p q v n := by omega
    rw [Finset.sum_range_succ, Finset.sum_range_succ, ih he, hb]

private theorem binary_prefix_equal (p q u v m n : ℕ) (hn : n ≤ m)
    (h : blockValue p q u m = blockValue p q v m) :
    blockValue p q u n = blockValue p q v n := by
  induction m generalizing n with
  | zero =>
    have hn0 : n = 0 := by omega
    subst n
    rfl
  | succ m ih =>
    by_cases he : n = m + 1
    · subst n; exact h
    · rw [binary_block_rec, binary_block_rec] at h
      have hu := raw_digit_le_one p q u m
      have hv := raw_digit_le_one p q v m
      have hm : blockValue p q u m = blockValue p q v m := by omega
      exact ih n (by omega) hm

private theorem phase_block_monotone (d : RotationAddress) (u v : Fin d.q)
    (huv : u.val ≤ v.val) (n : ℕ) :
    blockValue d.p d.q u.val n ≤ blockValue d.p d.q v.val n := by
  induction n with
  | zero => simp [blockValue]
  | succ n ih =>
    have hu := raw_digit_le_one d.p d.q u.val n
    have hv := raw_digit_le_one d.p d.q v.val n
    rcases lt_or_eq_of_le ih with hp | hp
    · rw [binary_block_rec, binary_block_rec]
      omega
    · have hc := binary_equal_count d.p d.q u.val v.val n hp
      have hn : (∑ i ∈ Finset.range (n + 1), rawDigit d.p d.q u.val i) ≤
          ∑ i ∈ Finset.range (n + 1), rawDigit d.p d.q v.val i := by
        rw [raw_digit_prefix_count d u, raw_digit_prefix_count d v]
        exact Nat.div_le_div_right (Nat.add_le_add_right huv _)
      rw [Finset.sum_range_succ, Finset.sum_range_succ] at hn
      rw [binary_block_rec, binary_block_rec, hp]
      omega

private theorem coprime_phase_surjective (d : RotationAddress) (r : ℕ) (hr : r < d.q) :
    ∃ n : Fin d.q, (n.val * d.p) % d.q = r := by
  have hq : 0 < d.q := Nat.lt_trans d.p_pos d.p_lt_q
  let f : Fin d.q → Fin d.q := fun n => ⟨(n.val * d.p) % d.q, Nat.mod_lt _ hq⟩
  have hi : Function.Injective f := by
    intro i j he
    have hm : Nat.ModEq d.q (i.val * d.p) (j.val * d.p) := by
      exact congrArg Fin.val he
    have hc := Nat.ModEq.cancel_right_of_coprime d.coprime.symm hm
    have hv : i.val = j.val := by
      change i.val % d.q = j.val % d.q at hc
      simpa only [Nat.mod_eq_of_lt i.isLt, Nat.mod_eq_of_lt j.isLt] using hc
    exact Fin.ext hv
  obtain ⟨n, hn⟩ := Finite.surjective_of_injective hi ⟨r, hr⟩
  exact ⟨n, congrArg Fin.val hn⟩


theorem word_strict (d : RotationAddress) : StrictMono (wordValue d) := by
  intro u v huv
  have hv : u.val < v.val := huv
  have hq : 0 < d.q := Nat.lt_trans d.p_pos d.p_lt_q
  have hle := phase_block_monotone d u v (Nat.le_of_lt hv) d.q
  change blockValue d.p d.q u.val d.q < blockValue d.p d.q v.val d.q
  by_contra hnot
  have he : blockValue d.p d.q u.val d.q = blockValue d.p d.q v.val d.q := by omega
  have hr : d.q - v.val < d.q := by have := v.isLt; omega
  obtain ⟨n, hn⟩ := coprime_phase_surjective d (d.q - v.val) hr
  have hp := binary_prefix_equal d.p d.q u.val v.val d.q n.val (Nat.le_of_lt n.isLt) he
  have hc := binary_equal_count d.p d.q u.val v.val n.val hp
  rw [raw_digit_prefix_count d u, raw_digit_prefix_count d v] at hc
  have hucond : ¬ d.q ≤ u.val + (d.q - v.val) := by have := v.isLt; omega
  have hvcond : d.q ≤ v.val + (d.q - v.val) := by have := v.isLt; omega
  have hdiv : (u.val + n.val * d.p) / d.q < (v.val + n.val * d.p) / d.q := by
    simp only [Nat.add_div hq, Nat.div_eq_of_lt u.isLt, Nat.div_eq_of_lt v.isLt,
      Nat.mod_eq_of_lt u.isLt, Nat.mod_eq_of_lt v.isLt, hn,
      if_neg hucond, if_pos hvcond]
    omega
  omega

end FVLT.FordBulbV1
