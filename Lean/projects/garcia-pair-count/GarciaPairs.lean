import Mathlib

namespace AtlasPairs
open Finset ArithmeticFunction
open scoped ArithmeticFunction.Moebius

theorem common_factor_sign (d a b : ℕ) (hd : Squarefree d)
    (ha : d.Coprime a) (hb : d.Coprime b) :
    μ (d*a) * μ (d*b) = μ a * μ b := by
  rw [isMultiplicative_moebius.map_mul_of_coprime ha,
    isMultiplicative_moebius.map_mul_of_coprime hb]
  linear_combination (μ a * μ b) * moebius_sq_eq_one_of_squarefree hd

set_option maxRecDepth 6000 in
set_option maxHeartbeats 1600000 in
/-- Exhaust the reduced support below height 35 in the kernel. -/
theorem signs_below_35 (a b : ℕ) (hab : a < b) (hb : b < 35) (hr : b < 2*a)
    (ha6 : a.Coprime 6) (hb6 : b.Coprime 6) (ha : Squarefree a) (hb' : Squarefree b) :
    μ a * μ b = 1 := by
  have small (j : ℕ) (hlo : 1 < j) (hhi : j < 35) (hc : j.Coprime 6)
      (hs : Squarefree j) : j.Prime := by
    have h : ∀ i : Fin 35, (1 < (i : ℕ)) → Nat.Coprime (i : ℕ) 6 →
        i.val=25 ∨ i.val=5 ∨ i.val=7 ∨ i.val=11 ∨ i.val=13 ∨ i.val=17 ∨
        i.val=19 ∨ i.val=23 ∨ i.val=29 ∨ i.val=31 := by decide
    rcases h ⟨j,hhi⟩ hlo hc with h|h|h|h|h|h|h|h|h|h <;> change j = _ at h <;> subst j
    · have hi := hs 5 (by decide : 5*5 ∣ 25)
      norm_num at hi
    all_goals norm_num
  rw [moebius_apply_prime (small a (by omega) (by omega) ha6 ha),
    moebius_apply_prime (small b (by omega) hb hb6 hb')]
  norm_num

theorem first_opposing_pair : (μ 19 : ℤ) * μ 35 = -1 := by
  rw [show (35:ℕ) = 5*7 by decide, isMultiplicative_moebius.map_mul_of_coprime (by decide : Nat.Coprime 5 7),
    moebius_apply_prime (by norm_num : Nat.Prime 19), moebius_apply_prime (by norm_num : Nat.Prime 5),
    moebius_apply_prime (by norm_num : Nat.Prime 7)]
  norm_num

/-- Summing a uniform squarefree counting error per reduced pair at
height b. A factor b from the row count cancels its square-root denominator. -/
theorem accumulate (Y : ℕ) (rows : ℕ → Finset ℕ) (err : ℕ → ℕ → ℝ)
    (A : ℝ) (hA : 0 ≤ A) (hc : ∀ b ∈ Icc 1 Y, (rows b).card ≤ b)
    (he : ∀ b ∈ Icc 1 Y, ∀ a ∈ rows b, |err b a| ≤ A/Real.sqrt b) :
    |∑ b ∈ Icc 1 Y, ∑ a ∈ rows b, err b a| ≤ Y*(A*Real.sqrt Y) := by
  have row (b : ℕ) (hb : b ∈ Icc 1 Y) :
      (∑ a ∈ rows b, |err b a|) ≤ A*Real.sqrt Y := by
    have hpos : 0 < (b : ℝ) := by exact_mod_cast (mem_Icc.mp hb).1
    have hs := Real.sqrt_pos.2 hpos
    calc
      _ ≤ ∑ a ∈ rows b, A/Real.sqrt b := sum_le_sum (he b hb)
      _ = (rows b).card * (A/Real.sqrt b) := by simp
      _ ≤ (b : ℝ) * (A/Real.sqrt b) := by
        gcongr
        exact_mod_cast hc b hb
      _ = A*Real.sqrt b := by field_simp; nlinarith [Real.sq_sqrt hpos.le]
      _ ≤ _ := by gcongr; exact_mod_cast (mem_Icc.mp hb).2
  calc _ ≤ ∑ b ∈ Icc 1 Y, |∑ a ∈ rows b, err b a| := Finset.abs_sum_le_sum_abs ..
       _ ≤ ∑ b ∈ Icc 1 Y, (∑ a ∈ rows b, |err b a|) :=
          sum_le_sum fun b _ => Finset.abs_sum_le_sum_abs ..
       _ ≤ ∑ b ∈ Icc 1 Y, A*Real.sqrt Y := sum_le_sum row
       _ = _ := by simp
/-- Positive squarefree common factors through the real endpoint t. -/
noncomputable def count (m : ℕ) (t : ℝ) : ℝ :=
  ∑ d ∈ (Icc 1 ⌊t⌋₊).filter (fun d => d.Coprime m), (μ d : ℝ)^2

noncomputable def density (m : ℕ) : ℝ :=
  6 / Real.pi^2 * ∏ p ∈ m.primeFactors, (p : ℝ)/(p+1)

/-- The two orders of each denominator pair are included. The uniform squarefree
sieve is the only counting input; W bounds its modulus factor on this row range. -/
theorem ratio_budget (X C W : ℝ) (Y : ℕ) (hX : 2*(Y:ℝ) ≤ X) (hC : 0 ≤ C) (hW : 0 ≤ W)
    (sieve : ∀ m : ℕ, 1 ≤ m → ∀ t : ℝ, 1 ≤ t →
      |count m t - t*density m| ≤ C*(2:ℝ)^m.primeFactors.card*Real.sqrt t)
    (weight : ∀ b ∈ Icc 1 Y, ∀ a ∈ Ico 1 b, (2:ℝ)^(6*a*b).primeFactors.card ≤ W) :
    let rows := fun b => (Ico 1 b).filter (fun a => b < 2*a ∧ a.Coprime b ∧ (a*b).Coprime 6)
    let err := fun b a : ℕ =>
      let m := 6*a*b
      let u := X/b
      let l := X/(2*a)
      2*(μ a : ℝ)*(μ b : ℝ)*(count m u-count m l-(u-l)*density m)
    |∑ b ∈ Icc 1 Y, ∑ a ∈ rows b, err b a| ≤ Y*(4*C*W*Real.sqrt X*Real.sqrt Y) := by
  intro rows err
  apply accumulate Y rows err (4*C*W*Real.sqrt X) (by positivity)
  · intro b _
    exact (Finset.card_filter_le ..).trans (by simp)
  intro b hb a ha
  obtain ⟨har,hlt,_,_⟩ := mem_filter.mp ha
  have hab := mem_Ico.mp har
  have hby := mem_Icc.mp hb
  have hbr : (0:ℝ) < b := by exact_mod_cast hby.1
  have har' : (0:ℝ) < a := by exact_mod_cast hab.1
  have hx' : 2*(b:ℝ) ≤ X := (mul_le_mul_of_nonneg_left (by exact_mod_cast hby.2) (by norm_num : (0:ℝ) ≤ 2)).trans hX
  have hab' : (a:ℝ) ≤ b := by exact_mod_cast hab.2.le
  have hba : (b:ℝ) ≤ 2*a := by exact_mod_cast hlt.le
  let u := X/(b:ℝ)
  let l := X/(2*(a:ℝ))
  let m := 6*a*b
  have hu : 1 ≤ u := (le_div_iff₀ hbr).2 (by linarith)
  have hl : 1 ≤ l := (le_div_iff₀ (by positivity : 0 < 2*(a:ℝ))).2 (by linarith)
  have hlu : l ≤ u := div_le_div_of_nonneg_left (by linarith) hbr hba
  have hm : 1 ≤ m := by
    change 0 < 6*a*b
    exact Nat.mul_pos (Nat.mul_pos (by decide) hab.1) hby.1
  have e (t) (ht : 1 ≤ t) (ht' : t ≤ u) :
      |count m t-t*density m| ≤ C*W*Real.sqrt u := by
    apply (sieve m hm t ht).trans
    gcongr
    exact weight b hb a har
  have triangle := abs_sub (count m u-u*density m) (count m l-l*density m)
  have eu := e u hu le_rfl
  have el := e l hl hlu
  have mid : |count m u-count m l-(u-l)*density m| ≤ 2*(C*W*Real.sqrt u) := by
    rw [show count m u-count m l-(u-l)*density m =
      (count m u-u*density m)-(count m l-l*density m) by ring]; linarith
  have unit (n : ℕ) : |(μ n : ℝ)| ≤ 1 := by
    rcases moebius_eq_or n with hn|hn|hn <;> norm_num [hn]
  change |2*(μ a : ℝ)*(μ b : ℝ)*(count m u-count m l-(u-l)*density m)| ≤ _
  rw [abs_mul, abs_mul, abs_mul, abs_of_nonneg (by norm_num : (0:ℝ) ≤ 2)]
  calc _ ≤ 2*1*1*(2*(C*W*Real.sqrt u)) := by gcongr <;> apply unit
       _ = _ := by dsimp [u]; rw [Real.sqrt_div (by linarith : 0 ≤ X)]; ring
end AtlasPairs
