import FVLTDivisorBoltzmannV1
import FVLTRosetteEntropyV1
import FVLTRosetteFairBridgeV1

open scoped BigOperators
namespace FVLT.RosetteLogLossV1

open FVLT.RosetteEntropyV1
open FVLT.RosetteFairBridgeV1

noncomputable def crossEntropy (M : ℕ) (data predictor : ℕ → ℚ) : ℝ :=
  ∑ n ∈ (support M).filter (fun n => 0 < data n),
    -(data n : ℝ) * Real.log (predictor n : ℝ)

theorem crossEntropy_sub_entropy_eq_finiteKL (M : ℕ) (data predictor : ℕ → ℚ)
    (hdata : ∀ n ∈ support M, 0 ≤ data n)
    (hpredictor : ∀ n ∈ support M, 0 < data n → 0 < predictor n) :
    crossEntropy M data predictor - entropy M data = finiteKL M data predictor := by
  have he : entropy M data =
      ∑ n ∈ (support M).filter (fun n => 0 < data n), Real.negMulLog (data n : ℝ) := by
    rw [entropy, Finset.sum_filter]
    apply Finset.sum_congr rfl
    intro n hn
    split_ifs with h
    · rfl
    · have hz : data n = 0 := le_antisymm (le_of_not_gt h) (hdata n hn)
      simp [hz]
  rw [crossEntropy, he, ← Finset.sum_sub_distrib, finiteKL]
  apply Finset.sum_congr rfl
  intro n hn
  obtain ⟨hn, hd⟩ := Finset.mem_filter.mp hn
  have hd' : (0 : ℝ) < data n := by exact_mod_cast hd
  have hp' : (0 : ℝ) < predictor n := by exact_mod_cast hpredictor n hn hd
  rw [Real.log_div hd'.ne' hp'.ne', Real.negMulLog_def]
  ring

private theorem uniform_pos (M : ℕ) (hM : 0 < M) (n : ℕ) :
    0 < uniformMass M n := by
  unfold uniformMass
  positivity

theorem naive_data_uniform_predictor (M : ℕ) (hM : 0 < M) :
    crossEntropy M (naiveMass M) (uniformMass M) = Real.log (M : ℝ) ∧
    crossEntropy M (naiveMass M) (uniformMass M) - entropy M (naiveMass M) =
      finiteKL M (naiveMass M) (uniformMass M) := by
  have hs : (∑ n ∈ support M, (naiveMass M n : ℝ)) = 1 := by
    exact_mod_cast naive_mass_sum M hM
  have hm : (M : ℝ) ≠ 0 := by exact_mod_cast hM.ne'
  constructor
  · unfold crossEntropy
    rw [Finset.filter_true_of_mem (fun _ hn => naive_mass_pos hn)]
    simp only [uniformMass, Rat.cast_div, Rat.cast_one, Rat.cast_natCast,
      Real.log_div one_ne_zero hm, Real.log_one, zero_sub, neg_mul_neg,
      ← Finset.sum_mul, hs, one_mul]
  · exact crossEntropy_sub_entropy_eq_finiteKL M _ _
      (fun _ hn => (naive_mass_pos hn).le) (fun n _ _ => uniform_pos M hM n)

theorem fair_data_naive_predictor (M : ℕ) (hM : 0 < M) :
    crossEntropy M (uniformMass M) (naiveMass M) - Real.log (M : ℝ) =
      finiteKL M (uniformMass M) (naiveMass M) := by
  rw [← entropy_uniform M hM]
  exact crossEntropy_sub_entropy_eq_finiteKL M _ _
    (fun n _ => (uniform_pos M hM n).le) (fun _ hn _ => naive_mass_pos hn)

theorem fair_data_naive_predictor_pos (M : ℕ) (hM : 2 ≤ M) :
    0 < finiteKL M (uniformMass M) (naiveMass M) := by
  have hm : 0 < M := by omega
  let u (n : ℕ) : ℝ := (uniformMass M n : ℝ)
  let p (n : ℕ) : ℝ := (naiveMass M n : ℝ)
  have hu (n : ℕ) : 0 < u n := by
    dsimp [u]
    exact_mod_cast uniform_pos M hm n
  have hp (n : ℕ) (hn : n ∈ support M) : 0 < p n := by
    dsimp [p]
    exact_mod_cast naive_mass_pos hn
  have h1 : 1 ∈ support M := Finset.mem_Ioc.mpr ⟨by decide, by omega⟩
  have hdiff : p 1 ≠ u 1 := by
    have ht : 1 < (M : ℝ) * p 1 := by
      dsimp [p]
      exact_mod_cast naive_mass_one_scaled_gt_one M hM
    intro he
    have hz : (M : ℝ) * u 1 = 1 := by
      have hm' : (M : ℝ) ≠ 0 := by exact_mod_cast hm.ne'
      simp [u, uniformMass, hm']
    rw [he, hz] at ht
    exact (lt_irrefl _ ht)
  have hidentity (n : ℕ) (hn : n ∈ support M) :
      -(u n * (p n / u n - 1)) = u n - p n := by
    field_simp [(hu n).ne']
    ring
  have hlog (n : ℕ) (hn : n ∈ support M) :
      Real.log (u n / p n) = -Real.log (p n / u n) := by
    rw [Real.log_div (hu n).ne' (hp n hn).ne', Real.log_div (hp n hn).ne' (hu n).ne']
    ring
  have hsum := Finset.sum_lt_sum
    (s := support M)
    (f := fun n => u n - p n)
    (g := fun n => u n * Real.log (u n / p n))
    (fun n hn => by
      rw [← hidentity n hn, hlog n hn]
      have h := mul_le_mul_of_nonneg_left (Real.log_le_sub_one_of_pos (div_pos (hp n hn) (hu n))) (hu n).le
      rw [mul_neg]
      exact neg_le_neg h)
    ⟨1, h1, by
      rw [← hidentity 1 h1, hlog 1 h1]
      have hr : p 1 / u 1 ≠ 1 := by
        intro h
        apply hdiff
        exact (div_eq_iff (hu 1).ne').mp h |>.trans (one_mul _)
      have h := mul_lt_mul_of_pos_left (Real.log_lt_sub_one_of_pos (div_pos (hp 1 h1) (hu 1)) hr) (hu 1)
      rw [mul_neg]
      exact neg_lt_neg h⟩
  have hps : (∑ n ∈ support M, p n) = 1 := by
    dsimp [p]
    exact_mod_cast naive_mass_sum M hm
  have hus : (∑ n ∈ support M, u n) = 1 := by
    dsimp [u]
    exact_mod_cast uniform_mass_sum M hm
  rw [Finset.sum_sub_distrib, hps, hus, sub_self] at hsum
  unfold finiteKL
  rw [Finset.filter_true_of_mem (fun n _ => uniform_pos M hm n)]
  exact hsum

theorem fair_rosette_eq_zero_logit_softmax {M n : ℕ} (hn : n ∈ support M) :
    (fairMass M n : ℝ) = FVLT.DivisorBoltzmannV1.softmax (support M) (fun _ => 0) n := by
  rw [fair_mass_eq_uniform hn, FVLT.DivisorBoltzmannV1.softmax_zero]
  simp [uniformMass, support]

end FVLT.RosetteLogLossV1
