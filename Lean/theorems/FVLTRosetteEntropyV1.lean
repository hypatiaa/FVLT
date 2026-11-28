module

public import Mathlib.Analysis.Convex.Jensen
public import Mathlib.Analysis.SpecialFunctions.Log.NegMulLog
public import Mathlib.NumberTheory.Divisors
public import Mathlib.Tactic

@[expose] public section

open scoped BigOperators

namespace FVLT.RosetteEntropyV1

def support (M : ℕ) : Finset ℕ := Finset.Ioc 0 M

def uniformMass (M : ℕ) (_n : ℕ) : ℚ := 1 / (M : ℚ)

def naiveMass (M n : ℕ) : ℚ :=
  (1 / (M : ℚ)) *
    ∑ s ∈ (support M).filter (fun s => n ∣ s), 1 / (s.divisors.card : ℚ)

noncomputable def entropy (M : ℕ) (p : ℕ → ℚ) : ℝ :=
  ∑ n ∈ support M, Real.negMulLog (p n : ℝ)

noncomputable def finiteKL (M : ℕ) (p q : ℕ → ℚ) : ℝ :=
  ∑ n ∈ (support M).filter (fun n => 0 < p n),
    (p n : ℝ) * Real.log ((p n : ℝ) / (q n : ℝ))

theorem uniform_mass_sum (M : ℕ) (hM : 0 < M) :
    (∑ n ∈ support M, uniformMass M n) = 1 := by
  have hm : (M : ℚ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt hM)
  simp [support, uniformMass, hm]

private theorem support_filter_eq_divisors {M s : ℕ} (hs : s ∈ support M) :
    (support M).filter (fun n => n ∣ s) = s.divisors := by
  have hs' := Finset.mem_Ioc.mp hs
  ext n
  simp only [support, Finset.mem_filter, Finset.mem_Ioc, Nat.mem_divisors]
  constructor
  · exact fun h => ⟨h.2, Nat.ne_of_gt hs'.1⟩
  · exact fun h => ⟨⟨Nat.pos_of_dvd_of_pos h.1 hs'.1,
      (Nat.le_of_dvd hs'.1 h.1).trans hs'.2⟩, h.1⟩

private theorem divisor_card_pos {s : ℕ} (hs : 0 < s) : 0 < s.divisors.card :=
  Finset.card_pos.mpr ⟨1, Nat.mem_divisors.mpr ⟨one_dvd s, Nat.ne_of_gt hs⟩⟩

theorem naive_mass_sum (M : ℕ) (hM : 0 < M) :
    (∑ n ∈ support M, naiveMass M n) = 1 := by
  have hm : (M : ℚ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt hM)
  simp only [naiveMass, ← Finset.mul_sum, Finset.sum_filter]
  rw [Finset.sum_comm]
  calc
    _ = (1 / (M : ℚ)) * ∑ s ∈ support M, (1 : ℚ) := by
      congr 1
      apply Finset.sum_congr rfl
      intro s hs
      rw [← Finset.sum_filter, support_filter_eq_divisors hs]
      have hc : (s.divisors.card : ℚ) ≠ 0 := by
        exact_mod_cast (Nat.ne_of_gt (divisor_card_pos (Finset.mem_Ioc.mp hs).1))
      simp [hc]
    _ = 1 := by simp [support, hm]

theorem naive_mass_pos {M n : ℕ} (hn : n ∈ support M) :
    0 < naiveMass M n := by
  have hn' := Finset.mem_Ioc.mp hn
  have hm : (0 : ℚ) < M := by exact_mod_cast (hn'.1.trans_le hn'.2)
  unfold naiveMass
  apply mul_pos (one_div_pos.mpr hm)
  apply Finset.sum_pos'
  · intro s _
    positivity
  · refine ⟨n, Finset.mem_filter.mpr ⟨hn, dvd_refl n⟩, ?_⟩
    have hc : (0 : ℚ) < n.divisors.card := by exact_mod_cast divisor_card_pos hn'.1
    positivity

theorem naive_mass_one_scaled_gt_one (M : ℕ) (hM : 2 ≤ M) :
    1 < (M : ℚ) * naiveMass M 1 := by
  have hm : (M : ℚ) ≠ 0 := by exact_mod_cast (by omega : M ≠ 0)
  have h1 : 1 ∈ support M := by simp [support]; omega
  have h2 : 2 ∈ (support M).erase 1 := by simp [support, hM]
  have hc : (0 : ℚ) < (Nat.divisors 2).card := by
    exact_mod_cast divisor_card_pos (by decide : 0 < (2 : ℕ))
  have ht : 0 < ∑ s ∈ (support M).erase 1, (1 : ℚ) / s.divisors.card := by
    exact Finset.sum_pos' (fun _ _ => by positivity) ⟨2, h2, by positivity⟩
  unfold naiveMass
  simp only [one_dvd, Finset.filter_true]
  rw [← mul_assoc, mul_one_div_cancel hm, one_mul, ← Finset.sum_erase_add _ _ h1]
  have hcard : (Nat.divisors 1).card = 1 := by decide
  simpa [hcard] using (lt_add_of_pos_left (1 : ℚ) ht)

theorem entropy_uniform (M : ℕ) (hM : 0 < M) :
    entropy M (uniformMass M) = Real.log (M : ℝ) := by
  have hm : (M : ℝ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt hM)
  simp only [entropy, uniformMass, Rat.cast_div, Rat.cast_one, Rat.cast_natCast,
    Real.negMulLog_def, Real.log_div one_ne_zero hm, Real.log_one,
    zero_sub, Finset.sum_const, support, Nat.card_Ioc, Nat.sub_zero, nsmul_eq_mul]
  field_simp

theorem entropy_naive_lt_log (M : ℕ) (hM : 2 ≤ M) :
    entropy M (naiveMass M) < Real.log (M : ℝ) := by
  have hmN : 0 < M := by omega
  have hm : (0 : ℝ) < M := by exact_mod_cast hmN
  have hs : (∑ n ∈ support M, (naiveMass M n : ℝ)) = 1 := by
    exact_mod_cast naive_mass_sum M hmN
  have hw : (∑ n ∈ support M, (1 : ℝ) / M) = 1 := by
    simp [support, nsmul_eq_mul, ne_of_gt hm]
  have h1 : 1 ∈ support M := by simp [support]; omega
  have hb : 1 < (M : ℝ) * (naiveMass M 1 : ℝ) := by
    exact_mod_cast naive_mass_one_scaled_gt_one M hM
  have hdiff : ∃ j ∈ support M, ∃ k ∈ support M,
      (naiveMass M j : ℝ) ≠ (naiveMass M k : ℝ) := by
    by_contra! h
    have hc : (∑ n ∈ support M, (naiveMass M n : ℝ)) =
        ∑ _n ∈ support M, (naiveMass M 1 : ℝ) :=
      Finset.sum_congr rfl (fun n hn => h n hn 1 h1)
    rw [hs] at hc
    simp [support, nsmul_eq_mul] at hc
    linarith
  have hj := Real.strictConcaveOn_negMulLog.lt_map_sum
    (t := support M) (w := fun _ => (1 : ℝ) / M) (p := fun n => (naiveMass M n : ℝ))
    (fun _ _ => one_div_pos.mpr hm) hw
    (fun n hn => Set.mem_Ici.mpr (by exact_mod_cast (naive_mass_pos hn).le)) hdiff
  simp only [smul_eq_mul, ← Finset.mul_sum, hs, mul_one] at hj
  have hu : entropy M (uniformMass M) =
      (M : ℝ) * Real.negMulLog (1 / (M : ℝ)) := by
    simp [entropy, uniformMass, support, nsmul_eq_mul]
  rw [← entropy_uniform M hmN, hu]
  exact (div_lt_iff₀ hm).mp (by simpa [entropy, div_eq_mul_inv, mul_comm] using hj) |>.trans_eq (mul_comm _ _)

theorem entropy_naive_deficit_eq_finiteKL (M : ℕ) (hM : 0 < M) :
    Real.log (M : ℝ) - entropy M (naiveMass M) =
      finiteKL M (naiveMass M) (uniformMass M) := by
  have hm : (M : ℝ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt hM)
  have hs : (∑ n ∈ support M, (naiveMass M n : ℝ)) = 1 := by
    exact_mod_cast naive_mass_sum M hM
  have hf : (support M).filter (fun n => 0 < naiveMass M n) = support M :=
    Finset.filter_true_of_mem (fun _ hn => naive_mass_pos hn)
  unfold finiteKL
  rw [hf]
  calc
    _ = (∑ n ∈ support M, (naiveMass M n : ℝ) * Real.log (naiveMass M n : ℝ)) +
          (∑ n ∈ support M, (naiveMass M n : ℝ) * Real.log (M : ℝ)) := by
      simp [entropy, Real.negMulLog_def, neg_mul, Finset.sum_neg_distrib,
        ← Finset.sum_mul, hs]
      ring
    _ = _ := by
      rw [← Finset.sum_add_distrib]
      apply Finset.sum_congr rfl
      intro n hn
      have hp : (naiveMass M n : ℝ) ≠ 0 := by
        exact_mod_cast (ne_of_gt (naive_mass_pos hn))
      simp only [uniformMass, Rat.cast_div, Rat.cast_one, Rat.cast_natCast]
      rw [Real.log_div hp (one_div_ne_zero hm), Real.log_div one_ne_zero hm, Real.log_one]
      ring

end FVLT.RosetteEntropyV1
