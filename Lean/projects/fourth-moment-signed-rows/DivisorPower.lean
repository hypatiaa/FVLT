import Mathlib

open Finset
noncomputable section
namespace FourthMoment

/-- A small-prime constant in the elementary all-epsilon divisor bound. -/
theorem divisorPower {e : ℝ} (he : 0 < e) :
    ∃ C : ℝ, 0 ≤ C ∧ ∀ n : ℕ, 0 < n → (n.divisors.card : ℝ) ≤ C*(n:ℝ)^e := by
  let b : ℝ := (2:ℝ)^e
  have hb : 1 < b := Real.one_lt_rpow (by norm_num) he
  let C : ℝ := 1 + 1/(b-1)
  have hc : 1 ≤ C := by dsimp [C]; linarith [one_div_pos.mpr (sub_pos.mpr hb)]
  obtain ⟨K,hK⟩ := exists_nat_gt ((2:ℝ)^(1/e))
  refine ⟨C^K, by positivity [le_trans zero_le_one hc], ?_⟩
  intro n hn
  let S := n.primeFactors
  have localB (p : ℕ) (hp : p ∈ S) (a : ℕ) :
      (a:ℝ)+1 ≤ (if p<K then C else 1) * ((p:ℝ)^a)^e := by
    have hp2 : (2:ℝ) ≤ p := by exact_mod_cast (Nat.prime_of_mem_primeFactors hp).two_le
    have hp0 : 0 ≤ (p:ℝ) := Nat.cast_nonneg _
    rw [← Real.rpow_natCast_mul hp0, mul_comm (a:ℝ) e, Real.rpow_mul hp0, Real.rpow_natCast]
    split_ifs with h
    · have bern := one_add_mul_le_pow (show -2 ≤ b-1 by linarith) a
      have bh : b ≤ (p:ℝ)^e := Real.rpow_le_rpow (by norm_num) hp2 he.le
      have b1 : 1 ≤ b^a := one_le_pow₀ hb.le
      have hbern : (a:ℝ)*(b-1) ≤ b^a := by
        convert_to (a:ℝ)*(b-1) ≤ (1+(b-1))^a
        · ring_nf
        linarith
      have hc' : (a:ℝ) ≤ b^a / (b-1) := (le_div_iff₀ (sub_pos.mpr hb)).mpr hbern
      calc _ ≤ C*b^a := by dsimp [C]; rw [add_mul,one_mul]; linarith [show (1/(b-1))*b^a = b^a/(b-1) by ring]
           _ ≤ _ := mul_le_mul_of_nonneg_left (pow_le_pow_left₀ (by positivity [hb.le]) bh a) (by linarith)
    · have hpk : (2:ℝ)^(1/e) ≤ p := hK.le.trans (by exact_mod_cast Nat.le_of_not_gt h)
      have h2 := Real.rpow_le_rpow (by positivity : 0 ≤ (2:ℝ)^(1/e)) hpk he.le
      rw [← Real.rpow_mul (by norm_num), one_div_mul_cancel he.ne', Real.rpow_one] at h2
      rw [one_mul]
      calc _ ≤ (2:ℝ)^a := by exact_mod_cast (show a+1 ≤ 2^a from Nat.lt_two_pow_self)
           _ ≤ _ := pow_le_pow_left₀ (by norm_num) h2 a
  rw [Nat.card_divisors hn.ne', Nat.cast_prod]
  calc
    _ ≤ ∏ p ∈ S, ((if p<K then C else 1) * ((p:ℝ)^(n.factorization p))^e) :=
      Finset.prod_le_prod₀ (fun _ _ => by positivity) fun p hp => by simpa using localB p hp (n.factorization p)
    _ = (∏ p ∈ S.filter (· < K), C) * (n:ℝ)^e := by
      rw [Finset.prod_mul_distrib, Finset.prod_filter, Real.finsetProd_rpow]
      · congr 2
        exact_mod_cast Nat.prod_factorization_pow_eq_self hn.ne'
      · intros; positivity
    _ ≤ _ := by
      apply mul_le_mul_of_nonneg_right _ (by positivity)
      rw [Finset.prod_const]
      exact pow_le_pow_right₀ hc (by simpa using Finset.card_le_card (show S.filter (· < K) ⊆ Finset.range K from
        fun p hp => Finset.mem_range.mpr (Finset.mem_filter.mp hp).2))
end FourthMoment

