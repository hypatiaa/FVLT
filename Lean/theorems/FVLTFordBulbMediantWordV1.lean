import FVLTFordBulbCombinatoricsV1
import Mathlib.Data.Nat.ModEq
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Zify

/-!
FF-4 B6c: the rank-0 word of a Farey mediant is the concatenation of its neighbours' words.

For rotation addresses `d` below `e` with `e.p * d.q = d.p * e.q + 1` (Farey neighbours) and
the mediant address `m` (`m.p = d.p + e.p`, `m.q = d.q + e.q`), the FF-4 rank-0 word of `m`
(`blockValue m.p m.q 0 m.q`, a `m.q`-bit word) is the `d.q`-bit word of `d` followed by the
`e.q`-bit word of `e`. The statements are exact statements about natural numbers; no analytic
dynamics and no Rule 30 claim is made here.

The mediant-concatenation observation is Gemini's (lane E), in saphir's B6 programme.
The framework was assembled by Robin Miller; its components are classical results of others.
-/
set_option autoImplicit false
open scoped BigOperators
namespace FVLT.FordBulbV1

-- BEGIN FROZEN DEFINITIONS
-- END FROZEN DEFINITIONS


private theorem raw_digit_carry0 (p q i : ℕ) (hq : 0 < q) (hpq : p < q) :
    rawDigit p q 0 i = (i + 1) * p / q - i * p / q := by
  unfold rawDigit
  rw [Nat.zero_add, Nat.add_mul, one_mul]
  have h1 := Nat.div_add_mod (i * p) q
  have h2 := Nat.mod_lt (i * p) hq
  generalize i * p = x at h1 h2 ⊢
  generalize x % q = r at h1 h2 ⊢
  generalize x / q = a at h1 ⊢
  subst h1
  have e : q * a + r + p = (r + p) + q * a := by ring
  rw [e, Nat.add_mul_div_left _ _ hq]
  split_ifs with h
  · have e2 : r + p = (r + p - q) + q := by omega
    rw [e2, Nat.add_div_right _ hq, Nat.div_eq_of_lt (show r + p - q < q by omega)]
    omega
  · rw [Nat.div_eq_of_lt (show r + p < q by omega)]
    omega

private theorem floor_left (a b c d' i : ℕ) (hb : 0 < b) (hd : 0 < d')
    (hadj : c * b = a * d' + 1) (hi : i ≤ b) :
    i * (a + c) / (b + d') = i * a / b := by
  have hQ : 0 < b + d' := by omega
  have E1 := Nat.div_add_mod (i * a) b
  have hs := Nat.mod_lt (i * a) hb
  generalize i * a / b = n at E1 ⊢
  generalize i * a % b = s at E1 hs
  have E1' : ((i : ℤ) * a) = b * n + s := by exact_mod_cast E1.symm
  have E2 : ((c : ℤ) * b) = a * d' + 1 := by exact_mod_cast hadj
  have hbz : (0 : ℤ) < b := by exact_mod_cast hb
  have hsz : (s : ℤ) < b := by exact_mod_cast hs
  have hiz : (i : ℤ) ≤ b := by exact_mod_cast hi
  have hdz : (0 : ℤ) < d' := by exact_mod_cast hd
  apply le_antisymm
  · apply Nat.le_of_lt_succ
    rw [Nat.div_lt_iff_lt_mul hQ]
    have hdiff : (b : ℤ) * (((n : ℤ) + 1) * (b + d')) - b * (i * (a + c)) =
        ((b : ℤ) - s) * (b + d') - i := by
      linear_combination (-((b : ℤ) + d')) * E1' + (-(i : ℤ)) * E2
    have h3 : ((b : ℤ) - s) * (b + d') ≥ 1 * (b + d') := by
      apply mul_le_mul_of_nonneg_right _ (by positivity)
      linarith
    have h : (b : ℤ) * (i * (a + c)) < b * (((n : ℤ) + 1) * (b + d')) := by linarith
    have h' := lt_of_mul_lt_mul_left h (le_of_lt hbz)
    exact_mod_cast h'
  · rw [Nat.le_div_iff_mul_le hQ]
    have hdiff : (b : ℤ) * (i * (a + c)) - b * (n * (b + d')) = s * (b + d') + i := by
      linear_combination ((b : ℤ) + d') * E1' + (i : ℤ) * E2
    have hnn : (0 : ℤ) ≤ s * (b + d') + i := by positivity
    have h : (b : ℤ) * (n * (b + d')) ≤ b * (i * (a + c)) := by linarith
    have h' := le_of_mul_le_mul_left h hbz
    exact_mod_cast h'

private theorem floor_right (a b c d' j : ℕ) (hb : 0 < b) (hd : 0 < d')
    (hadj : c * b = a * d' + 1) (hj : j ≤ d') :
    (b + j) * (a + c) / (b + d') = a + j * c / d' := by
  have hQ : 0 < b + d' := by omega
  have E3 := Nat.div_add_mod (j * c) d'
  have ht := Nat.mod_lt (j * c) hd
  generalize j * c / d' = k at E3 ⊢
  generalize j * c % d' = t at E3 ht
  have E3' : ((j : ℤ) * c) = d' * k + t := by exact_mod_cast E3.symm
  have E2 : ((c : ℤ) * b) = a * d' + 1 := by exact_mod_cast hadj
  have hdz : (0 : ℤ) < d' := by exact_mod_cast hd
  have htz : (t : ℤ) < d' := by exact_mod_cast ht
  have hjz : (j : ℤ) ≤ d' := by exact_mod_cast hj
  have hbz : (0 : ℤ) < b := by exact_mod_cast hb
  apply le_antisymm
  · apply Nat.le_of_lt_succ
    rw [Nat.div_lt_iff_lt_mul hQ]
    have hdiff : (d' : ℤ) * (((a : ℤ) + k + 1) * (b + d')) - d' * ((b + j) * (a + c)) =
        ((d' : ℤ) - t) * (b + d') - (d' - j) := by
      linear_combination (-((d' : ℤ) - j)) * E2 + (-((b : ℤ) + d')) * E3'
    have h3 : ((d' : ℤ) - t) * (b + d') ≥ 1 * (b + d') := by
      apply mul_le_mul_of_nonneg_right _ (by positivity)
      linarith
    have hj0 : (0 : ℤ) ≤ j := by positivity
    have h : (d' : ℤ) * ((b + j) * (a + c)) < d' * (((a : ℤ) + k + 1) * (b + d')) := by linarith
    have h' := lt_of_mul_lt_mul_left h (le_of_lt hdz)
    exact_mod_cast h'
  · rw [Nat.le_div_iff_mul_le hQ]
    have hdiff : (d' : ℤ) * ((b + j) * (a + c)) - d' * ((a + k) * (b + d')) =
        t * (b + d') + (d' - j) := by
      linear_combination ((d' : ℤ) - j) * E2 + ((b : ℤ) + d') * E3'
    have hnn : (0 : ℤ) ≤ t * (b + d') := by positivity
    have h : (d' : ℤ) * ((a + k) * (b + d')) ≤ d' * ((b + j) * (a + c)) := by linarith
    have h' := le_of_mul_le_mul_left h hdz
    exact_mod_cast h'

private theorem digit_left (a b c d' i : ℕ) (hb : 0 < b) (hd : 0 < d') (hab : a < b)
    (hcd : c < d') (hadj : c * b = a * d' + 1) (hi : i < b) :
    rawDigit (a + c) (b + d') 0 i = rawDigit a b 0 i := by
  rw [raw_digit_carry0 (a + c) (b + d') i (by omega) (by omega), raw_digit_carry0 a b i hb hab,
    floor_left a b c d' (i + 1) hb hd hadj (by omega), floor_left a b c d' i hb hd hadj (by omega)]

private theorem digit_right (a b c d' j : ℕ) (hb : 0 < b) (hd : 0 < d') (hab : a < b)
    (hcd : c < d') (hadj : c * b = a * d' + 1) (hj : j < d') :
    rawDigit (a + c) (b + d') 0 (b + j) = rawDigit c d' 0 j := by
  rw [raw_digit_carry0 (a + c) (b + d') (b + j) (by omega) (by omega),
    raw_digit_carry0 c d' j hd hcd, show b + j + 1 = b + (j + 1) by ring,
    floor_right a b c d' (j + 1) hb hd hadj (by omega), floor_right a b c d' j hb hd hadj (by omega),
    Nat.add_sub_add_left]

private theorem block_rec (f : ℕ → ℕ) (n : ℕ) :
    ∑ i ∈ Finset.range (n + 1), f i * 2 ^ (n + 1 - 1 - i) =
      2 * ∑ i ∈ Finset.range n, f i * 2 ^ (n - 1 - i) + f n := by
  rw [Finset.sum_range_succ, Finset.mul_sum]
  congr 1
  · apply Finset.sum_congr rfl
    intro i hi
    rw [Finset.mem_range] at hi
    have e : n + 1 - 1 - i = (n - 1 - i) + 1 := by omega
    rw [e, pow_succ]
    ring
  · simp

private theorem block_concat (f : ℕ → ℕ) (n k : ℕ) :
    ∑ i ∈ Finset.range (n + k), f i * 2 ^ (n + k - 1 - i) =
      (∑ i ∈ Finset.range n, f i * 2 ^ (n - 1 - i)) * 2 ^ k +
        ∑ j ∈ Finset.range k, f (n + j) * 2 ^ (k - 1 - j) := by
  induction k with
  | zero => simp
  | succ k ih =>
    have h1 := block_rec f (n + k)
    have h2 : ∑ j ∈ Finset.range (k + 1), f (n + j) * 2 ^ (k + 1 - 1 - j) =
        2 * ∑ j ∈ Finset.range k, f (n + j) * 2 ^ (k - 1 - j) + f (n + k) :=
      block_rec (fun j => f (n + j)) k
    rw [show n + (k + 1) = n + k + 1 by ring, h1, ih, h2, pow_succ]
    ring

/-- B6c.1: the mediant's rank-0 word is the left neighbour's word followed by the right
    neighbour's word. -/
theorem mediant_word_concat (d e m : RotationAddress)
    (hadj : e.p * d.q = d.p * e.q + 1) (hp : m.p = d.p + e.p) (hq : m.q = d.q + e.q) :
    blockValue m.p m.q 0 m.q = blockValue d.p d.q 0 d.q * 2 ^ e.q + blockValue e.p e.q 0 e.q := by
  have hp1 := d.p_pos
  have hq1 := d.p_lt_q
  have hp2 := e.p_pos
  have hq2 := e.p_lt_q
  have hb : 0 < d.q := by omega
  have hd : 0 < e.q := by omega
  rw [hp, hq]
  unfold blockValue
  have hc := block_concat (fun i => rawDigit (d.p + e.p) (d.q + e.q) 0 i) d.q e.q
  beta_reduce at hc
  rw [hc]
  congr 1
  · congr 1
    apply Finset.sum_congr rfl
    intro i hi
    rw [Finset.mem_range] at hi
    rw [digit_left d.p d.q e.p e.q i hb hd hq1 hq2 hadj hi]
  · apply Finset.sum_congr rfl
    intro j hj
    rw [Finset.mem_range] at hj
    rw [digit_right d.p d.q e.p e.q j hb hd hq1 hq2 hadj hj]

/-- B6c.N1 (negative control, adjacency is needed): 1/3 and 3/4 are not Farey neighbours, and
    the word of their mediant 4/7 is not the concatenation of their words. -/
theorem nonneighbour_not_concat :
    3 * 3 ≠ 1 * 4 + 1 ∧
      blockValue 4 7 0 7 ≠ blockValue 1 3 0 3 * 2 ^ 4 + blockValue 3 4 0 4 := by
  decide

/-- B6c.N2 (negative control, order is needed): 1/3 and 1/2 are Farey neighbours, and the
    right-first concatenation is not the word of their mediant 2/5. -/
theorem mediant_word_order_matters :
    3 * 1 = 1 * 2 + 1 ∧
      blockValue 2 5 0 5 ≠ blockValue 1 2 0 2 * 2 ^ 3 + blockValue 1 3 0 3 := by
  decide

end FVLT.FordBulbV1
