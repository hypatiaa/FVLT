import FVLTRosetteEntropyV1
import FVLTDiceExactV1

open scoped BigOperators

namespace FVLT.RosetteFairBridgeV1

open FVLT.RosetteEntropyV1
open FVLT.DiceExactV1
open Finset

def inverseQuotientSum (M s : ℕ) : ℚ :=
  ∑ d ∈ s.divisors, 1 / ((M / d : ℕ) : ℚ)

def spiralMass (M s : ℕ) : ℚ :=
  (1 / (M : ℚ)) * inverseQuotientSum M s

def fairConditional (M s n : ℕ) : ℚ :=
  if n ∣ s then (1 / ((M / n : ℕ) : ℚ)) / inverseQuotientSum M s else 0

def fairMass (M n : ℕ) : ℚ :=
  ∑ s ∈ support M, spiralMass M s * fairConditional M s n

theorem spiral_mass_sum (M : ℕ) (hM : 0 < M) :
    (∑ s ∈ support M, spiralMass M s) = 1 := by
  have hm : (M : ℚ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt hM)
  unfold spiralMass inverseQuotientSum
  rw [← Finset.mul_sum]
  have hswap : (∑ s ∈ support M, ∑ d ∈ s.divisors, (1 : ℚ) / ((M / d : ℕ) : ℚ)) =
      ∑ d ∈ support M, (1 : ℚ) := by
    calc
      _ = ∑ s ∈ support M, ∑ d ∈ support M, if d ∣ s then (1 : ℚ) / ((M / d : ℕ) : ℚ) else 0 := by
        apply sum_congr rfl
        intro s hs
        rw [← sum_filter, (show (support M).filter (· ∣ s) = s.divisors from divisors_eq_filter hs)]
      _ = ∑ d ∈ support M, (1 : ℚ) := by
        rw [sum_comm]
        apply sum_congr rfl
        intro d hd
        have hd' := mem_Ioc.mp hd
        have hq : ((M / d : ℕ) : ℚ) ≠ 0 := by
          exact_mod_cast (Nat.ne_of_gt (Nat.div_pos hd'.2 hd'.1))
        rw [← sum_filter, sum_const]
        change ((Ioc 0 M).filter (d ∣ ·)).card • (1 / ((M / d : ℕ) : ℚ)) = 1
        rw [Nat.Ioc_filter_dvd_card_eq_div, nsmul_eq_mul]
        simp [hq]
  rw [hswap]
  simp [support, hm]

theorem fair_conditional_sum {M s : ℕ} (hs : s ∈ support M) :
    (∑ n ∈ support M, fairConditional M s n) = 1 := by
  have hA : inverseQuotientSum M s ≠ 0 := ne_of_gt (inv_sum_pos hs)
  unfold fairConditional
  rw [← sum_filter, (show (support M).filter (· ∣ s) = s.divisors from divisors_eq_filter hs), ← sum_div]
  exact div_self hA

theorem fair_conditional_eq_stageTwoProb {M s : ℕ}
    (hs : s ∈ support M) (n : ℕ) :
    fairConditional M s n = FVLT.DiceExactV1.stageTwoProb M s n := by
  unfold fairConditional stageTwoProb
  split_ifs with hn
  · have hnd := Nat.mem_divisors.mpr ⟨hn, Nat.ne_of_gt (mem_Ioc.mp hs).1⟩
    have hL : (0 : ℚ) < Ls M s := by exact_mod_cast Ls_pos hs
    have hq : (0 : ℚ) < q M n := by exact_mod_cast q_pos hs hnd
    have hA := inv_sum_pos hs
    rw [weight_cast hs hnd, total_cast hs]
    change (1 / (q M n : ℚ)) / (∑ d ∈ s.divisors, 1 / (q M d : ℚ)) = _
    field_simp
  · rfl

theorem fair_mass_eq_pickProb (M n : ℕ) :
    fairMass M n = FVLT.DiceExactV1.pickProb M n := by
  unfold fairMass pickProb
  have h1 : ∀ d ∈ Ioc 0 M,
      (∑ k ∈ Ioc 0 (q M d), (1 / (M : ℚ)) * (1 / (q M d : ℚ)) * stageTwoProb M (k * d) n) =
      ∑ s ∈ Ioc 0 M, if d ∣ s then (1 / (M : ℚ)) * (1 / (q M d : ℚ)) * stageTwoProb M s n else 0 := by
    intro d hd
    rw [inner_reindex M d (mem_Ioc.mp hd).1 (fun s =>
      (1 / (M : ℚ)) * (1 / (q M d : ℚ)) * stageTwoProb M s n), sum_filter]
  rw [sum_congr rfl h1, sum_comm]
  apply sum_congr rfl
  intro s hs
  rw [fair_conditional_eq_stageTwoProb hs, ← sum_filter, divisors_eq_filter hs]
  unfold spiralMass inverseQuotientSum
  rw [Finset.mul_sum, Finset.sum_mul]
  rfl

theorem fair_mass_eq_uniform {M n : ℕ} (hn : n ∈ support M) :
    fairMass M n = uniformMass M n := by
  rw [fair_mass_eq_pickProb]
  exact fair_pick_exact M n (mem_Ioc.mp hn).1 (mem_Ioc.mp hn).2

theorem fair_mass_sum (M : ℕ) (hM : 0 < M) :
    (∑ n ∈ support M, fairMass M n) = 1 := by
  rw [sum_congr rfl (fun _ hn => fair_mass_eq_uniform hn), uniform_mass_sum M hM]

theorem entropy_fair (M : ℕ) (hM : 0 < M) :
    entropy M (fairMass M) = Real.log (M : ℝ) := by
  rw [← entropy_uniform M hM]
  unfold entropy
  exact sum_congr rfl (fun _ hn => by rw [fair_mass_eq_uniform hn])

end FVLT.RosetteFairBridgeV1
