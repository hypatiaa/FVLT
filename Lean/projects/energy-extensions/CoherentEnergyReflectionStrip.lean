import Verified
import CoherentEnergyMeasure
import CoherentEnergyRHBridge
import CoherentEnergyRadiusMeasure
import CoherentEnergySigmaBridge

/-!
# Positive-half reflection, strip zero-freeness for general σ, and directional wrappers

Formalises R2 and R3 from `ANALYTIC_CONTINUATION_NOTE_v0_1_20261123/NOTE.md`:

1. **R2 (`RightHalfZeroFree`):** Standalone equivalence `RiemannHypothesis ↔ RightHalfZeroFree`
   using Mathlib's functional equation (`completedRiemannZeta_one_sub` and `Complex.Gammaℝ_eq_zero_iff`),
   citing Alpöge's `Formalism.VW.rh_of_right` and `RHConnections.PoleCompensation.riemannHypothesis_of_right_zero_free`
   as prior art. Plus direct one-way theorem `rightHalfZeroFree_of_sigma_energy_bound` (and `_measure_`)
   that does *not* invoke `riemannHypothesis_of_right_zero_free` or `completedRiemannZeta_one_sub`
   (as audited separately in `DEPENDENCY_AUDIT.json`).
2. **R3 (General-`σ` fixed-strip equivalence for `θ ∈ [1/2, 1)` with `σ + θ > 1`):**
   `fixed_strip_iff_sigma_energy_power`, `fixed_strip_iff_sigma_measure_power`, and explicit
   one-way `zero_free_strip_of_sigma_energy_bound` / `_measure_bound`.
3. **Directional splits for R1 constant-dependency audit:** Clean single-direction declarations
   for Mertens, `v0.1` measure (`σ = 1`), and general-`σ` measure (`σ ≥ 1/2`).
-/

noncomputable section
open scoped BigOperators
open Filter MeasureTheory Complex

namespace RHConnections.CoherentEnergyContinuation

open RHConnections.ArithmeticFourierInversion
open RHConnections.CoherentEnergyBounds
open RHConnections.MertensCriterion
open RHConnections.CoherentEnergyMeasure
open RHConnections.CoherentEnergyRadius

/-! ## R2: RightHalfZeroFree and functional-equation reflection -/

/-- Zero-freeness of `riemannZeta` on the open right half `{s : ℂ | 1/2 < s.re}`. -/
def RightHalfZeroFree : Prop :=
  ∀ s : ℂ, 1 / 2 < s.re → riemannZeta s ≠ 0

theorem rightHalfZeroFree_of_riemannHypothesis (hRH : RiemannHypothesis) :
    RightHalfZeroFree := by
  intro s hs hzero
  have hs1 : s ≠ 1 := by
    rintro rfl
    exact riemannZeta_ne_zero_of_one_le_re (by norm_num) hzero
  have hnt : ¬ ∃ n : ℕ, s = -2 * (↑n + 1) := by
    rintro ⟨n, rfl⟩
    have hneg : (-2 * ((n : ℂ) + 1)).re < 0 := by simp; linarith
    linarith
  have hre : s.re = 1 / 2 := hRH s hzero hnt hs1
  linarith

/-- Reflection from `RightHalfZeroFree` (`Re s > 1/2`) to Mathlib's `RiemannHypothesis`,
proved directly from Mathlib's functional equation `completedRiemannZeta_one_sub` and
`Complex.Gammaℝ_eq_zero_iff`.
Prior art: Alpöge's `Formalism.VW.rh_of_right` (`rh_of_every → rh_of_right`) and
`RHConnections.PoleCompensation.riemannHypothesis_of_right_zero_free`. -/
theorem riemannHypothesis_of_rightHalfZeroFree (hfree : RightHalfZeroFree) :
    RiemannHypothesis := by
  intro s hzero hnt hs1
  have hs0 : s ≠ 0 := by
    rintro rfl
    norm_num [riemannZeta_zero] at hzero
  have hGamma : Complex.Gammaℝ s ≠ 0 := by
    rw [Ne, Complex.Gammaℝ_eq_zero_iff]
    rintro ⟨n, hn⟩
    cases n with
    | zero => exact hs0 (by simpa using hn)
    | succ k =>
      apply hnt
      exact ⟨k, by simpa [Nat.cast_succ, neg_mul] using hn⟩
  have hcomp : completedRiemannZeta s = 0 := by
    rw [riemannZeta_def_of_ne_zero hs0, div_eq_zero_iff] at hzero
    exact hzero.resolve_right hGamma
  have hdual : riemannZeta (1 - s) = 0 := by
    rw [riemannZeta_def_of_ne_zero (sub_ne_zero.mpr (Ne.symm hs1)),
      completedRiemannZeta_one_sub, hcomp, zero_div]
  apply le_antisymm
  · by_contra! hlt
    exact hfree s hlt hzero
  · by_contra! hlt
    have h1ms : 1 / 2 < (1 - s).re := by
      simp only [Complex.sub_re, Complex.one_re]
      linarith
    exact hfree (1 - s) h1ms hdual

theorem riemannHypothesis_iff_rightHalfZeroFree :
    RiemannHypothesis ↔ RightHalfZeroFree :=
  ⟨rightHalfZeroFree_of_riemannHypothesis, riemannHypothesis_of_rightHalfZeroFree⟩

/-- Helper: natural-index `O(n^{1/2 + ε})` bounds on `M` imply real-variable `MertensCancellation`. -/
private theorem mertensCancellation_of_abs_M_bounds
    (hM : ∀ ε : ℝ, 0 < ε → ∃ C : ℝ, 0 ≤ C ∧
      ∀ n : ℕ, 1 ≤ n → |M n| ≤ C * (n : ℝ) ^ (1 / 2 + ε)) :
    MertensCancellation :=
  mertensCancellation_of_natural_power_bounds hM

/-- One-way R2 statement: `σ`-energy growth (`σ ≥ 1/2`) directly yields `RightHalfZeroFree`
*without* invoking `riemannHypothesis_of_right_zero_free` or `completedRiemannZeta_one_sub`.
(Whether internal Mathlib zeta-continuation constants still appear is audited in `DEPENDENCY_AUDIT.json`.) -/
theorem rightHalfZeroFree_of_sigma_energy_bound {σ : ℝ} (hσ : 1 / 2 ≤ σ) (B : ℕ)
    (hE : ∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
      ∀ X : ℕ, 1 ≤ X → energyOf (rhoSigma σ) B X ≤ C * (X : ℝ) ^ (1 + δ)) :
    RightHalfZeroFree := by
  have hσ_pos : 0 < σ := by linarith
  have hρ_le : ∀ p, p.Prime → 0 ≤ rhoSigma σ p ∧ rhoSigma σ p ≤ 1 := fun p hp =>
    ⟨(rhoSigma_mem_Ico hσ_pos hp).1, (rhoSigma_mem_Ico hσ_pos hp).2.le⟩
  have hS : ∀ ε : ℝ, 0 < ε → ∃ A : ℝ, 0 ≤ A ∧
      ∀ X : ℕ, 1 ≤ X → |SSigma σ B X| ≤ A * (X : ℝ) ^ (1 / 2 + ε) := by
    have hS' := (all_epsilon_iff_energyOf hρ_le B).mpr hE
    intro ε hε
    obtain ⟨A, hA, hb⟩ := hS' ε hε
    exact ⟨A, hA, fun X hX => by simpa only [SSigma_eq_scalarSOf] using hb X hX⟩
  have hM : ∀ ε : ℝ, 0 < ε → ∃ C : ℝ, 0 ≤ C ∧
      ∀ n : ℕ, 1 ≤ n → |M n| ≤ C * (n : ℝ) ^ (1 / 2 + ε) :=
    (M_all_epsilon_iff_SSigma hσ B).mpr hS
  exact MertensCriterion.right_zero_free_of_mertens (mertensCancellation_of_abs_M_bounds hM)

theorem rightHalfZeroFree_of_sigma_measure_bound {σ : ℝ} (hσ : 1 / 2 ≤ σ) {B : ℕ} (hB : 1 ≤ B)
    (hE : ∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
      ∀ X : ℕ, 1 ≤ X →
        ∫ ω, ‖D B X ω‖ ^ 2 ∂(primeTorusMeasureOf (rhoSigma σ)) ≤ C * (X : ℝ) ^ (1 + δ)) :
    RightHalfZeroFree := by
  have hσ_pos : 0 < σ := by linarith
  simp_rw [norm_sq_D_eq_energyOf (fun p hp => rhoSigma_mem_Ico hσ_pos hp) hB] at hE
  exact rightHalfZeroFree_of_sigma_energy_bound hσ B hE

/-! ## R3: General θ ∈ [1/2, 1) strip zero-freeness for σ > 0, σ + θ > 1 -/

private lemma sq_rpow_nonneg' (x : ℝ) (hx : 0 ≤ x) (t : ℝ) : (x ^ t) ^ 2 = x ^ (2 * t) := by
  calc (x ^ t) ^ 2 = (x ^ t) ^ (2 : ℝ) := by norm_num
    _ = x ^ (2 * t) := by rw [← Real.rpow_mul hx, mul_comm t]

theorem zero_free_strip_of_sigma_energy_bound {σ θ : ℝ} (hσ : 0 < σ)
    (hθ : 1 / 2 ≤ θ) (hθ1 : θ < 1) (hστ : 1 < σ + θ) (B : ℕ)
    (hE : ∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
      ∀ X : ℕ, 1 ≤ X → energyOf (rhoSigma σ) B X ≤ C * (X : ℝ) ^ (2 * θ + δ)) :
    ∀ s : ℂ, θ < s.re → riemannZeta s ≠ 0 := by
  have hρ_le : ∀ p, p.Prime → 0 ≤ rhoSigma σ p ∧ rhoSigma σ p ≤ 1 := fun p hp =>
    ⟨(rhoSigma_mem_Ico hσ hp).1, (rhoSigma_mem_Ico hσ hp).2.le⟩
  intro s hs
  let ε : ℝ := min ((s.re - θ) / 2) ((1 - θ) / 2)
  have hε : 0 < ε := lt_min (by linarith) (by linarith)
  have hb0 : 0 ≤ θ + ε := by linarith
  have hb1 : θ + ε < 1 := by linarith [min_le_right ((s.re - θ) / 2) ((1 - θ) / 2)]
  have hbs : θ + ε < s.re := by linarith [min_le_left ((s.re - θ) / 2) ((1 - θ) / 2)]
  obtain ⟨C, hC, hBnd⟩ := hE (2 * ε) (by positivity)
  have hS : NaturalPowerBound (SSigma σ B) (θ + ε) := by
    refine ⟨Real.sqrt C, Real.sqrt_nonneg C, fun X hX => ?_⟩
    have h1 := (scalar_sq_le_energyOf hρ_le B X hX).trans (hBnd X hX)
    have ht : (Real.sqrt C * (X : ℝ) ^ (θ + ε)) ^ 2 = C * (X : ℝ) ^ (2 * θ + 2 * ε) := by
      rw [mul_pow, Real.sq_sqrt hC, sq_rpow_nonneg' _ (Nat.cast_nonneg X)]
      congr 1; ring_nf
    apply (sq_le_sq₀ (abs_nonneg _) (by positivity)).mp
    rw [sq_abs, ht, SSigma_eq_scalarSOf]
    exact h1
  have hM : NaturalPowerBound M (θ + ε) :=
    (M_power_bound_iff_SSigma σ B hb0 (by linarith : 1 < σ + (θ + ε))).mpr hS
  exact zero_free_of_natural_mertens_power hb0 hb1 hM s hbs

theorem zero_free_strip_of_sigma_measure_bound {σ θ : ℝ} (hσ : 0 < σ)
    (hθ : 1 / 2 ≤ θ) (hθ1 : θ < 1) (hστ : 1 < σ + θ) {B : ℕ} (hB : 1 ≤ B)
    (hE : ∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
      ∀ X : ℕ, 1 ≤ X →
        ∫ ω, ‖D B X ω‖ ^ 2 ∂(primeTorusMeasureOf (rhoSigma σ)) ≤ C * (X : ℝ) ^ (2 * θ + δ)) :
    ∀ s : ℂ, θ < s.re → riemannZeta s ≠ 0 := by
  simp_rw [norm_sq_D_eq_energyOf (fun p hp => rhoSigma_mem_Ico hσ hp) hB] at hE
  exact zero_free_strip_of_sigma_energy_bound hσ hθ hθ1 hστ B hE

theorem sigma_energy_bound_of_zero_free_strip {σ θ : ℝ} (hσ : 0 < σ)
    (hθ : 1 / 2 ≤ θ) (hθ1 : θ < 1) (hστ : 1 < σ + θ) (B : ℕ)
    (hStrip : ∀ s : ℂ, θ < s.re → riemannZeta s ≠ 0) :
    ∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
      ∀ X : ℕ, 1 ≤ X → energyOf (rhoSigma σ) B X ≤ C * (X : ℝ) ^ (2 * θ + δ) := by
  have hρ_le : ∀ p, p.Prime → 0 ≤ rhoSigma σ p ∧ rhoSigma σ p ≤ 1 := fun p hp =>
    ⟨(rhoSigma_mem_Ico hσ hp).1, (rhoSigma_mem_Ico hσ hp).2.le⟩
  intro δ hδ
  have hM : NaturalPowerBound M (θ + δ / 2) :=
    natural_mertens_bounds_of_strip hStrip hθ hθ1 (δ / 2) (by positivity)
  obtain ⟨A, hA, hS⟩ :=
    (M_power_bound_iff_SSigma σ B (by linarith) (by linarith)).mp hM
  have hS' : ∀ k : ℕ, 1 ≤ k → |scalarSOf (rhoSigma σ) B k| ≤ A * (k : ℝ) ^ (θ + δ / 2) := by
    intro k hk
    simpa only [← SSigma_eq_scalarSOf] using hS k hk
  refine ⟨A ^ 2 * pSeries (2 * (θ + δ / 2)),
    mul_nonneg (sq_nonneg A) (tsum_nonneg fun _ => by positivity), fun X _ => ?_⟩
  have he : 2 * (θ + δ / 2) = 2 * θ + δ := by ring
  simpa only [he] using energyOf_upper hρ_le B X hA (by linarith : 1 / 2 < θ + δ / 2) hS'

theorem fixed_strip_iff_sigma_energy_power {σ θ : ℝ} (hσ : 0 < σ)
    (hθ : 1 / 2 ≤ θ) (hθ1 : θ < 1) (hστ : 1 < σ + θ) (B : ℕ) :
    (∀ s : ℂ, θ < s.re → riemannZeta s ≠ 0) ↔
      (∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
        ∀ X : ℕ, 1 ≤ X → energyOf (rhoSigma σ) B X ≤ C * (X : ℝ) ^ (2 * θ + δ)) :=
  ⟨sigma_energy_bound_of_zero_free_strip hσ hθ hθ1 hστ B,
    zero_free_strip_of_sigma_energy_bound hσ hθ hθ1 hστ B⟩

theorem fixed_strip_iff_sigma_measure_power {σ θ : ℝ} (hσ : 0 < σ)
    (hθ : 1 / 2 ≤ θ) (hθ1 : θ < 1) (hστ : 1 < σ + θ) {B : ℕ} (hB : 1 ≤ B) :
    (∀ s : ℂ, θ < s.re → riemannZeta s ≠ 0) ↔
      (∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
        ∀ X : ℕ, 1 ≤ X →
          ∫ ω, ‖D B X ω‖ ^ 2 ∂(primeTorusMeasureOf (rhoSigma σ)) ≤ C * (X : ℝ) ^ (2 * θ + δ)) := by
  simp_rw [norm_sq_D_eq_energyOf (fun p hp => rhoSigma_mem_Ico hσ hp) hB]
  exact fixed_strip_iff_sigma_energy_power hσ hθ hθ1 hστ B

/-! ## R1: Clean directional split lemmas for exact constant-dependency audit -/

theorem mertens_of_RH_dir (hRH : RiemannHypothesis) : MertensCancellation :=
  mertensCancellation_of_natural_power_bounds (natural_mertens_bounds_of_RH hRH)

theorem RH_of_mertens_dir (hm : MertensCancellation) : RiemannHypothesis :=
  riemannHypothesis_of_mertens hm

theorem v01_measure_of_RH_dir {B : ℕ} (hB : 1 ≤ B) (hRH : RiemannHypothesis) :
    ∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
      ∀ X : ℕ, 1 ≤ X → ∫ ω, ‖D B X ω‖ ^ 2 ∂primeTorusMeasure ≤ C * (X : ℝ) ^ (1 + δ) := by
  have hσ_pos : (0 : ℝ) < 1 := by norm_num
  have hρ_le : ∀ p, p.Prime → 0 ≤ rhoSigma 1 p ∧ rhoSigma 1 p ≤ 1 := fun p hp =>
    ⟨(rhoSigma_mem_Ico hσ_pos hp).1, (rhoSigma_mem_Ico hσ_pos hp).2.le⟩
  have hM : ∀ ε : ℝ, 0 < ε → ∃ C : ℝ, 0 ≤ C ∧
      ∀ n : ℕ, 1 ≤ n → |M n| ≤ C * (n : ℝ) ^ (1 / 2 + ε) :=
    natural_mertens_bounds_of_RH hRH
  have hS : ∀ ε : ℝ, 0 < ε → ∃ A : ℝ, 0 ≤ A ∧
      ∀ X : ℕ, 1 ≤ X → |scalarSOf (rhoSigma 1) B X| ≤ A * (X : ℝ) ^ (1 / 2 + ε) := by
    have hSS := (M_all_epsilon_iff_SSigma (show (1 / 2 : ℝ) ≤ 1 by norm_num) B).mp hM
    simpa only [SSigma_eq_scalarSOf] using hSS
  have hE := (all_epsilon_iff_energyOf hρ_le B).mp hS
  have hMeas : ∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
      ∀ X : ℕ, 1 ≤ X →
        ∫ ω, ‖D B X ω‖ ^ 2 ∂(primeTorusMeasureOf (rhoSigma 1)) ≤ C * (X : ℝ) ^ (1 + δ) := by
    simpa only [norm_sq_D_eq_energyOf (fun p hp => rhoSigma_mem_Ico hσ_pos hp) hB] using hE
  simpa only [coherent_energy_sigma_one_eq_v01 hB, ← norm_sq_D_eq_coherent_energy hB] using hMeas

theorem RH_of_v01_measure_dir {B : ℕ} (hB : 1 ≤ B)
    (hE : ∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
      ∀ X : ℕ, 1 ≤ X → ∫ ω, ‖D B X ω‖ ^ 2 ∂primeTorusMeasure ≤ C * (X : ℝ) ^ (1 + δ)) :
    RiemannHypothesis := by
  have h1 : ∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
      ∀ X : ℕ, 1 ≤ X →
        ∫ ω, ‖D B X ω‖ ^ 2 ∂(primeTorusMeasureOf (rhoSigma 1)) ≤ C * (X : ℝ) ^ (1 + δ) := by
    simpa only [coherent_energy_sigma_one_eq_v01 hB, ← norm_sq_D_eq_coherent_energy hB] using hE
  exact riemannHypothesis_of_rightHalfZeroFree
    (rightHalfZeroFree_of_sigma_measure_bound (σ := 1) (by norm_num) hB h1)

theorem sigma_measure_of_RH_dir {σ : ℝ} (hσ : 1 / 2 ≤ σ) {B : ℕ} (hB : 1 ≤ B)
    (hRH : RiemannHypothesis) :
    ∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
      ∀ X : ℕ, 1 ≤ X →
        ∫ ω, ‖D B X ω‖ ^ 2 ∂(primeTorusMeasureOf (rhoSigma σ)) ≤ C * (X : ℝ) ^ (1 + δ) := by
  have hσ_pos : 0 < σ := by linarith
  have hρ_le : ∀ p, p.Prime → 0 ≤ rhoSigma σ p ∧ rhoSigma σ p ≤ 1 := fun p hp =>
    ⟨(rhoSigma_mem_Ico hσ_pos hp).1, (rhoSigma_mem_Ico hσ_pos hp).2.le⟩
  have hM : ∀ ε : ℝ, 0 < ε → ∃ C : ℝ, 0 ≤ C ∧
      ∀ n : ℕ, 1 ≤ n → |M n| ≤ C * (n : ℝ) ^ (1 / 2 + ε) :=
    natural_mertens_bounds_of_RH hRH
  have hS : ∀ ε : ℝ, 0 < ε → ∃ A : ℝ, 0 ≤ A ∧
      ∀ X : ℕ, 1 ≤ X → |scalarSOf (rhoSigma σ) B X| ≤ A * (X : ℝ) ^ (1 / 2 + ε) := by
    have hSS := (M_all_epsilon_iff_SSigma hσ B).mp hM
    simpa only [SSigma_eq_scalarSOf] using hSS
  have hE := (all_epsilon_iff_energyOf hρ_le B).mp hS
  simpa only [norm_sq_D_eq_energyOf (fun p hp => rhoSigma_mem_Ico hσ_pos hp) hB] using hE

theorem RH_of_sigma_measure_dir {σ : ℝ} (hσ : 1 / 2 ≤ σ) {B : ℕ} (hB : 1 ≤ B)
    (hE : ∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
      ∀ X : ℕ, 1 ≤ X →
        ∫ ω, ‖D B X ω‖ ^ 2 ∂(primeTorusMeasureOf (rhoSigma σ)) ≤ C * (X : ℝ) ^ (1 + δ)) :
    RiemannHypothesis :=
  riemannHypothesis_of_rightHalfZeroFree (rightHalfZeroFree_of_sigma_measure_bound hσ hB hE)

end RHConnections.CoherentEnergyContinuation
