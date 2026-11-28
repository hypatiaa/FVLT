import CoherentEnergyRotatedCentre
import Mathlib.NumberTheory.LSeries.SumCoeff
import Mathlib.NumberTheory.LSeries.Convolution
import Mathlib.NumberTheory.LSeries.Dirichlet
import Mathlib.NumberTheory.LSeries.RiemannZeta
import Mathlib.NumberTheory.LSeries.HurwitzZetaValues
import Mathlib.Data.Nat.Totient
import Mathlib.Analysis.MellinTransform
import Mathlib.Analysis.Complex.RemovableSingularity
import Mathlib.Analysis.Analytic.IsolatedZeros
import Mathlib.Analysis.Analytic.Uniqueness
import Mathlib.MeasureTheory.Integral.IntegralEqImproper
import Mathlib.Analysis.SpecialFunctions.Pow.Real

/-!
# R5 simple-zero and off-zero rotated energy resonance (`B = 1`, `σ = 1/2`)

Formalises the analytic derivation from `R5_ENERGY_SCAN_CODEX_20261123/RESONANCE.md`
(rechecked in `R5_SKELETON_RECHECK_v0_1_20261123/RECHECK.md`) on top of the exact
critical-line arithmetic energy definitions `scalarSC`, `energyC`, `jWeightC`, `wSigmaT`,
`primeTorusMeasureC`, and `D` from `RHConnections.CoherentEnergyRotated` (`B = 1`, `σ = 1/2`):

* **T1 (`mellin_S_eq_zeta_div`):** For `1 < u.re`,
  `∫ x in Ioi 1, S_t t x * (x : ℂ)^(-(u + 1)) = ζ(u + sCrit t) / (u * ζ(u))`.
* **T2 (`lintegral_E_eq_J_mul_lintegral_S_sq` & `totient_LSeries_eq_zeta_div`):**
  For `h > 0`, allowing infinite integrals in `ℝ≥0∞`,
  `∫⁻ x in Ioi 1, ofReal (E_t t x * x^(-2 - h)) = ofReal (J_h h) * ∫⁻ y in Ioi 1, ofReal (‖S_t t y‖^2 * y^(-2 - h))`,
  where `J_h h = ∑' r, φ(r) / r^(2 + h) = (ζ(1 + h) / ζ(2 + h)).re` and `h * J_h h → 6 / π^2` as `h → 0⁺`.
* **T3 (`simple_zero_energy_limsup_ge` & `simple_zero_torus_energy_limsup_ge`):**
  Unconditionally (with no RH assumption), if `uZero t = 1/2 - it` is a simple zero of `riemannZeta`,
  `limsup_{N → ∞} E_t(N) / (N (log N)^3) ≥ 2 / (π^2 * ‖uZero t * ζ'(uZero t)‖^2)`.
* **T3' (`off_zero_energy_limsup_ge` & `off_zero_torus_energy_limsup_ge`):**
  Unconditionally, if `riemannZeta (uZero t) ≠ 0`,
  `limsup_{N → ∞} E_t(N) / (N log N) ≥ 6 / (π^2 * ‖uZero t * ζ(uZero t)‖^2)`.

**Scope note:** These are unconditional subsequential lower bounds only. Because no off-zero upper
bound on `E_t(N)` is known here, energy magnitude alone does not yet separate zero heights from
non-zero heights at finite cutoffs or asymptotically.
-/

noncomputable section

open scoped BigOperators ENNReal NNReal LSeries.notation
open Filter MeasureTheory Complex ArithmeticFunction Topology

namespace RHConnections.R5Resonance

open RHConnections.CoherentEnergyMeasure
open RHConnections.CoherentEnergyRotated

/-! ## 1. Core rotated definitions and elementary identities -/

def sCrit (t : ℝ) : ℂ := ⟨1 / 2, t⟩

def uZero (t : ℝ) : ℂ := ⟨1 / 2, -t⟩

@[simp] theorem uZero_re (t : ℝ) : (uZero t).re = 1 / 2 := rfl

@[simp] theorem sCrit_re (t : ℝ) : (sCrit t).re = 1 / 2 := rfl

@[simp] theorem uZero_add_sCrit (t : ℝ) : uZero t + sCrit t = 1 := by
  apply Complex.ext <;> simp [uZero, sCrit]
  norm_num

theorem uZero_ne_zero (t : ℝ) : uZero t ≠ 0 := by
  intro h
  have := congr_arg Complex.re h
  norm_num [uZero] at this

theorem uZero_ne_one (t : ℝ) : uZero t ≠ 1 := by
  intro h
  have := congr_arg Complex.re h
  norm_num [uZero] at this

def S_t (t : ℝ) (x : ℝ) : ℂ :=
  if x < 1 then 0 else scalarSC (wSigmaT (1 / 2) t) 1 ⌊x⌋₊

def E_t (t : ℝ) (x : ℝ) : ℝ :=
  if x < 1 then 0 else energyC (wSigmaT (1 / 2) t) 1 ⌊x⌋₊

def H_t (t : ℝ) (u : ℂ) : ℂ :=
  ∫ x in Set.Ioi (1 : ℝ), S_t t x * (x : ℂ) ^ (-(u + 1))

def J_h (h : ℝ) : ℝ :=
  ∑' r : ℕ, (r.totient : ℝ) / (r : ℝ) ^ (2 + h)

def regZeta (z : ℂ) : ℂ :=
  Function.update (fun w : ℂ => (w - 1) * riemannZeta w) 1 1 z

lemma S_t_of_lt_one (t : ℝ) {x : ℝ} (hx : x < 1) : S_t t x = 0 := by
  rw [S_t, ite_eq_left hx]

lemma S_t_of_one_le (t : ℝ) {x : ℝ} (hx : 1 ≤ x) :
    S_t t x = scalarSC (wSigmaT (1 / 2) t) 1 ⌊x⌋₊ := by
  rw [S_t, ite_eq_right (not_lt.mpr hx)]

lemma E_t_of_lt_one (t : ℝ) {x : ℝ} (hx : x < 1) : E_t t x = 0 := by
  rw [E_t, ite_eq_left hx]

lemma E_t_of_one_le (t : ℝ) {x : ℝ} (hx : 1 ≤ x) :
    E_t t x = energyC (wSigmaT (1 / 2) t) 1 ⌊x⌋₊ := by
  rw [E_t, ite_eq_right (not_lt.mpr hx)]

lemma wSigmaT_half_norm_lt_one (t : ℝ) : ∀ p : ℕ, p.Prime → ‖wSigmaT (1 / 2) t p‖ < 1 :=
  fun _ hp => wSigmaT_norm_lt_one (by norm_num : (0 : ℝ) < 1 / 2) t hp

lemma wSigmaT_half_norm_le_one (t : ℝ) : ∀ p : ℕ, p.Prime → ‖wSigmaT (1 / 2) t p‖ ≤ 1 :=
  fun p hp => (wSigmaT_half_norm_lt_one t p hp).le

lemma E_t_nonneg (t : ℝ) (x : ℝ) : 0 ≤ E_t t x := by
  by_cases hx : x < 1
  · rw [E_t_of_lt_one t hx]
  · rw [E_t_of_one_le t (not_lt.mp hx)]
    unfold energyC
    refine Finset.sum_nonneg fun r _ => ?_
    exact mul_nonneg (jWeightC_nonneg (wSigmaT_half_norm_le_one t) r) (sq_nonneg _)

/-- Exact identity matching `jWeightC (wSigmaT (1/2) t) r` to `φ(r) / r` for `r ≥ 1`. -/
theorem jWeightC_wSigmaT_half_eq_totient_div {r : ℕ} (hr : 1 ≤ r) (t : ℝ) :
    jWeightC (wSigmaT (1 / 2) t) r = (r.totient : ℝ) / (r : ℝ) := by
  unfold jWeightC
  have hprod :
      (∏ p ∈ r.primeFactors, (1 - ‖wSigmaT (1 / 2) t p‖ ^ 2)) =
        ∏ p ∈ r.primeFactors, (1 - (p : ℝ)⁻¹) := by
    refine Finset.prod_congr rfl fun p hp => ?_
    have hp_prime : p.Prime := Nat.prime_of_mem_primeFactors hp
    have hp0 : (0 : ℝ) ≤ (p : ℝ) := Nat.cast_nonneg p
    rw [norm_wSigmaT (1 / 2) t hp_prime.one_le]
    have hsq : ((p : ℝ) ^ (-(1 / 2 : ℝ))) ^ 2 = (p : ℝ)⁻¹ := by
      calc ((p : ℝ) ^ (-(1 / 2 : ℝ))) ^ 2
          = ((p : ℝ) ^ (-(1 / 2 : ℝ))) ^ (2 : ℝ) := by norm_num
        _ = (p : ℝ) ^ (-(1 / 2 : ℝ) * 2) := by rw [← Real.rpow_mul hp0]
        _ = (p : ℝ) ^ (-1 : ℝ) := by norm_num
        _ = (p : ℝ)⁻¹ := Real.rpow_neg_one (p : ℝ)
    rw [hsq]
  have htot_q := Nat.totient_eq_mul_prod_factors r
  have htot_r : (r.totient : ℝ) = (r : ℝ) * ∏ p ∈ r.primeFactors, (1 - (p : ℝ)⁻¹) := by
    have hcast := congr_arg (Rat.cast : ℚ → ℝ) htot_q
    push_cast at hcast
    exact hcast
  have hr_pos : (0 : ℝ) < (r : ℝ) := Nat.cast_pos.mpr hr
  rw [hprod, htot_r, mul_div_cancel_left₀ _ hr_pos.ne']

lemma S_t_measurable (t : ℝ) : Measurable (S_t t) := by
  have hfloor : Measurable (fun x : ℝ => (Nat.floor x : ℕ)) :=
    Monotone.measurable fun _ _ h => Nat.floor_mono h
  have hsc : Measurable (fun x : ℝ => scalarSC (wSigmaT (1 / 2) t) 1 ⌊x⌋₊) :=
    (measurable_of_countable (fun n : ℕ => scalarSC (wSigmaT (1 / 2) t) 1 n)).comp hfloor
  exact Measurable.ite measurableSet_Iio measurable_const hsc

lemma E_t_measurable (t : ℝ) : Measurable (E_t t) := by
  have hfloor : Measurable (fun x : ℝ => (Nat.floor x : ℕ)) :=
    Monotone.measurable fun _ _ h => Nat.floor_mono h
  have hec : Measurable (fun x : ℝ => energyC (wSigmaT (1 / 2) t) 1 ⌊x⌋₊) :=
    (measurable_of_countable (fun n : ℕ => energyC (wSigmaT (1 / 2) t) 1 n)).comp hfloor
  exact Measurable.ite measurableSet_Iio measurable_const hec

/-! ## 2. T1: Mellin identity for `S_t` on `Re u > 1` -/

private lemma gSigmaT_half_apply (t : ℝ) (k : ℕ) :
    gSigmaT (1 / 2) t 1 k = if k = 0 then 0 else (k : ℂ) ^ (-sCrit t) := by
  simp [gSigmaT_apply, sCrit]

theorem scalarSC_wSigmaT_eq_sum_mul (t : ℝ) (n : ℕ) :
    scalarSC (wSigmaT (1 / 2) t) 1 n =
      ∑ m ∈ Finset.Icc 1 n, (↑(gSigmaT (1 / 2) t 1 * muC) : ℕ → ℂ) m := by
  rw [← SSigmaT_eq_scalarSC (1 / 2) t 1 n, SSigmaT]
  have hset : Finset.Icc 1 n = Finset.Ioc 0 n := by
    ext k; simp only [Finset.mem_Icc, Finset.mem_Ioc]; omega
  rw [hset]

private lemma sum_inv_sqrt_le (M : ℕ) :
    ∑ k ∈ Finset.Icc 1 M, (k : ℝ) ^ (-(1 / 2 : ℝ)) ≤ 2 * Real.sqrt M := by
  induction M with
  | zero => simp
  | succ m ih =>
    have hm_le : Finset.Icc 1 (m + 1) = insert (m + 1) (Finset.Icc 1 m) := by
      ext k; simp only [Finset.mem_Icc, Finset.mem_insert]; omega
    have hnot : m + 1 ∉ Finset.Icc 1 m := by simp
    rw [hm_le, Finset.sum_insert hnot]
    have hm1_pos : (0 : ℝ) < (m + 1 : ℝ) := by positivity
    have hsqrt_le : Real.sqrt m ≤ Real.sqrt (m + 1) :=
      Real.sqrt_le_sqrt (by exact_mod_cast Nat.le_succ m)
    have hr_step : ((m + 1 : ℕ) : ℝ) ^ (-(1 / 2 : ℝ)) = 1 / Real.sqrt (m + 1) := by
      rw [Nat.cast_add, Nat.cast_one, Real.rpow_neg (by positivity),
        ← Real.sqrt_eq_rpow, one_div]
    have hdiff : Real.sqrt (m + 1) ^ 2 - Real.sqrt m ^ 2 = 1 := by
      rw [Real.sq_sqrt (by positivity), Real.sq_sqrt (by positivity)]
      ring
    have hpos_sum : 0 < Real.sqrt (m + 1) + Real.sqrt m :=
      add_pos_of_pos_of_nonneg (Real.sqrt_pos.mpr hm1_pos) (Real.sqrt_nonneg _)
    have hid : 2 * (Real.sqrt (m + 1) - Real.sqrt m) =
        2 / (Real.sqrt (m + 1) + Real.sqrt m) := by
      field_simp [hpos_sum.ne']
      nlinarith [hdiff]
    have hineq : 1 / Real.sqrt (m + 1) ≤ 2 / (Real.sqrt (m + 1) + Real.sqrt m) := by
      rw [div_le_div_iff₀ (Real.sqrt_pos.mpr hm1_pos) hpos_sum]
      linarith
    have hstep : ((m + 1 : ℕ) : ℝ) ^ (-(1 / 2 : ℝ)) ≤ 2 * (Real.sqrt (m + 1) - Real.sqrt m) :=
      hr_step ▸ (hineq.trans_eq hid.symm)
    have hcast : Real.sqrt ((m + 1 : ℕ) : ℝ) = Real.sqrt ((m : ℝ) + 1) := by
      rw [Nat.cast_add, Nat.cast_one]
    linarith [ih, hstep, hcast]

private lemma sum_norm_gSigmaT_mul_muC_le (t : ℝ) (n : ℕ) :
    ∑ m ∈ Finset.Icc 1 n, ‖(↑(gSigmaT (1 / 2) t 1 * muC) : ℕ → ℂ) m‖ ≤ 4 * (n : ℝ) := by
  have h1 :
      ∑ m ∈ Finset.Icc 1 n, ‖(↑(gSigmaT (1 / 2) t 1 * muC) : ℕ → ℂ) m‖ ≤
        ∑ m ∈ Finset.Icc 1 n,
          ∑ p ∈ m.divisorsAntidiagonal, (p.1 : ℝ) ^ (-(1 / 2 : ℝ)) := by
    refine Finset.sum_le_sum fun m _ => ?_
    rw [ArithmeticFunction.mul_apply]
    refine (norm_sum_le _ _).trans (Finset.sum_le_sum fun p hp => ?_)
    have ⟨hp1, _⟩ := Nat.ne_zero_of_mem_divisorsAntidiagonal hp
    have hg : ‖gSigmaT (1 / 2) t 1 p.1‖ ≤ (p.1 : ℝ) ^ (-(1 / 2 : ℝ)) := by
      have hpos : (0 : ℝ) ≤ (p.1 : ℝ) := Nat.cast_nonneg _
      simpa only [one_div, Real.rpow_neg hpos] using norm_gSigmaT_le (1 / 2) t 1 (Nat.pos_of_ne_zero hp1)
    have hmu : ‖muC p.2‖ ≤ 1 := by
      have hmoeb : |(ArithmeticFunction.moebius p.2 : ℝ)| ≤ 1 := by
        exact_mod_cast ArithmeticFunction.abs_moebius_le_one (n := p.2)
      simpa [muC] using hmoeb
    calc ‖gSigmaT (1 / 2) t 1 p.1 * muC p.2‖
        = ‖gSigmaT (1 / 2) t 1 p.1‖ * ‖muC p.2‖ := norm_mul _ _
      _ ≤ (p.1 : ℝ) ^ (-(1 / 2 : ℝ)) * 1 := mul_le_mul hg hmu (norm_nonneg _) (by positivity)
      _ = (p.1 : ℝ) ^ (-(1 / 2 : ℝ)) := mul_one _
  have h2 :
      ∑ m ∈ Finset.Icc 1 n, ∑ p ∈ m.divisorsAntidiagonal, (p.1 : ℝ) ^ (-(1 / 2 : ℝ)) =
        ∑ d ∈ Finset.Icc 1 n, ∑ k ∈ Finset.Icc 1 (n / d), (k : ℝ) ^ (-(1 / 2 : ℝ)) := by
    have hL :
        ∑ m ∈ Finset.Icc 1 n, ∑ p ∈ m.divisorsAntidiagonal, (p.1 : ℝ) ^ (-(1 / 2 : ℝ)) =
          ∑ m ∈ Finset.Icc 1 n,
            ∑ p ∈ Finset.Icc 1 n ×ˢ Finset.Icc 1 n,
              if p.1 * p.2 = m then (p.1 : ℝ) ^ (-(1 / 2 : ℝ)) else 0 := by
      refine Finset.sum_congr rfl fun m hm => ?_
      have hm_le : m ≤ n := (Finset.mem_Icc.mp hm).2
      rw [← Finset.sum_filter]
      refine Finset.sum_congr ?_ fun _ _ => rfl
      ext ⟨k, d⟩
      simp only [Nat.mem_divisorsAntidiagonal, Finset.mem_filter, Finset.mem_product, Finset.mem_Icc]
      constructor
      · rintro ⟨hkd, hm0⟩
        have hk0 : 1 ≤ k := Nat.pos_of_ne_zero fun h => by subst h; simp at hkd; exact hm0 hkd.symm
        have hd0 : 1 ≤ d := Nat.pos_of_ne_zero fun h => by subst h; simp at hkd; exact hm0 hkd.symm
        have hk_le : k ≤ m := hkd ▸ Nat.le_mul_of_pos_right k hd0
        have hd_le : d ≤ m := hkd ▸ Nat.le_mul_of_pos_left d hk0
        exact ⟨⟨⟨hk0, hk_le.trans hm_le⟩, ⟨hd0, hd_le.trans hm_le⟩⟩, hkd⟩
      · rintro ⟨_, hkd⟩
        have hm_pos : 1 ≤ m := (Finset.mem_Icc.mp hm).1
        exact ⟨hkd, by omega⟩
    rw [hL, Finset.sum_comm, Finset.sum_product_right]
    refine Finset.sum_congr rfl fun d hd => ?_
    have hd_pos : 1 ≤ d := (Finset.mem_Icc.mp hd).1
    trans ∑ k ∈ Finset.Icc 1 n, if k * d ≤ n then (k : ℝ) ^ (-(1 / 2 : ℝ)) else 0
    · refine Finset.sum_congr rfl fun k hk => ?_
      have hk_pos : 1 ≤ k := (Finset.mem_Icc.mp hk).1
      dsimp only
      by_cases hkd : k * d ≤ n
      · rw [ite_eq_left hkd, Finset.sum_ite_eq, ite_eq_left]
        simp only [Finset.mem_Icc]
        exact ⟨Nat.mul_pos hk_pos hd_pos, hkd⟩
      · rw [ite_eq_right hkd, Finset.sum_ite_eq, ite_eq_right]
        simp only [Finset.mem_Icc, not_and]
        exact fun _ => hkd
    · rw [← Finset.sum_filter]
      refine Finset.sum_congr ?_ fun _ _ => rfl
      ext k
      simp only [Finset.mem_filter, Finset.mem_Icc]
      constructor
      · rintro ⟨⟨hk1, _⟩, hkd⟩
        exact ⟨hk1, (Nat.le_div_iff_mul_le hd_pos).mpr hkd⟩
      · rintro ⟨hk1, hkd⟩
        have hmul := (Nat.le_div_iff_mul_le hd_pos).mp hkd
        exact ⟨⟨hk1, (Nat.le_mul_of_pos_right k hd_pos).trans hmul⟩, hmul⟩
  have h3 :
      ∑ d ∈ Finset.Icc 1 n, ∑ k ∈ Finset.Icc 1 (n / d), (k : ℝ) ^ (-(1 / 2 : ℝ)) ≤
        4 * (n : ℝ) := by
    calc ∑ d ∈ Finset.Icc 1 n, ∑ k ∈ Finset.Icc 1 (n / d), (k : ℝ) ^ (-(1 / 2 : ℝ))
        ≤ ∑ d ∈ Finset.Icc 1 n, 2 * Real.sqrt ((n / d : ℕ) : ℝ) :=
          Finset.sum_le_sum fun d _ => sum_inv_sqrt_le (n / d)
      _ ≤ ∑ d ∈ Finset.Icc 1 n, 2 * Real.sqrt ((n : ℝ) / (d : ℝ)) := by
          refine Finset.sum_le_sum fun d hd => ?_
          have hd_pos : (0 : ℝ) < (d : ℝ) := Nat.cast_pos.mpr (Finset.mem_Icc.mp hd).1
          gcongr
          rw [le_div_iff₀ hd_pos]
          exact_mod_cast Nat.div_mul_le_self n d
      _ = (2 * Real.sqrt n) * ∑ d ∈ Finset.Icc 1 n, (d : ℝ) ^ (-(1 / 2 : ℝ)) := by
          rw [Finset.mul_sum]
          refine Finset.sum_congr rfl fun d hd => ?_
          have hd0 : (0 : ℝ) ≤ (d : ℝ) := Nat.cast_nonneg d
          rw [Real.sqrt_div (Nat.cast_nonneg n), Real.rpow_neg hd0, ← Real.sqrt_eq_rpow]
          ring
      _ ≤ (2 * Real.sqrt n) * (2 * Real.sqrt n) := by
          gcongr
          exact sum_inv_sqrt_le n
      _ = 4 * (n : ℝ) := by
          have hsq : Real.sqrt n * Real.sqrt n = (n : ℝ) :=
            Real.mul_self_sqrt (Nat.cast_nonneg n)
          linarith
  exact h1.trans (h2 ▸ h3)

/-- **T1 (Rotated Mellin identity on `Re u > 1`).** -/
theorem mellin_S_eq_zeta_div (t : ℝ) {u : ℂ} (hu : 1 < u.re) :
    H_t t u = riemannZeta (u + sCrit t) / (u * riemannZeta u) := by
  let f : ℕ → ℂ := ↑(gSigmaT (1 / 2) t 1 * muC)
  have hu0 : u ≠ 0 := fun h => by
    have : u.re = 0 := by simp [h]
    linarith
  have hus : 1 < (u + sCrit t).re := by simp [sCrit]; linarith
  have hO : (fun n : ℕ => ∑ k ∈ Finset.Icc 1 n, ‖f k‖) =O[atTop] fun n : ℕ => (n : ℝ) ^ (1 : ℝ) := by
    refine Asymptotics.IsBigO.of_bound 4 (Eventually.of_forall fun n => ?_)
    have hsum_nn : 0 ≤ ∑ k ∈ Finset.Icc 1 n, ‖f k‖ := Finset.sum_nonneg fun _ _ => norm_nonneg _
    rw [Real.norm_of_nonneg hsum_nn, Real.norm_of_nonneg (Real.rpow_nonneg (Nat.cast_nonneg n) _),
      Real.rpow_one]
    exact sum_norm_gSigmaT_mul_muC_le t n
  have hL_int : LSeries f u = u * ∫ x in Set.Ioi (1 : ℝ),
      (∑ k ∈ Finset.Icc 1 ⌊x⌋₊, f k) * (x : ℂ) ^ (-(u + 1)) :=
    LSeries_eq_mul_integral' f zero_le_one hu hO
  have hterm_g : ∀ n : ℕ, LSeries.term (⇑(gSigmaT (1 / 2) t 1)) u n = LSeries.term 1 (u + sCrit t) n := by
    intro n
    rcases eq_or_ne n 0 with rfl | hn
    · simp
    · rw [LSeries.term_of_ne_zero hn, LSeries.term_of_ne_zero hn]
      simp only [Pi.one_apply, gSigmaT_half_apply, ite_eq_right hn]
      have hnc : (n : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr hn
      rw [Complex.cpow_add _ _ hnc, Complex.cpow_neg]
      field_simp [hnc]
  have hsum_g : LSeriesSummable (⇑(gSigmaT (1 / 2) t 1)) u :=
    (LSeriesSummable_one_iff.mpr hus).congr fun n => (hterm_g n).symm
  have hL_g : LSeries (⇑(gSigmaT (1 / 2) t 1)) u = riemannZeta (u + sCrit t) := by
    rw [show LSeries (⇑(gSigmaT (1 / 2) t 1)) u = LSeries 1 (u + sCrit t) from
      tsum_congr hterm_g, LSeries_one_eq_riemannZeta hus]
  have hmu_eq : ∀ n : ℕ, (⇑muC : ℕ → ℂ) n = ((ArithmeticFunction.moebius n : ℤ) : ℂ) := fun _ => rfl
  have hsum_mu : LSeriesSummable (⇑muC) u :=
    (LSeriesSummable_moebius_iff.mpr hu).congr fun n => by simp [LSeries.term, hmu_eq n]
  have hzeta_mu : riemannZeta u * LSeries (⇑muC) u = 1 := by
    have hLmu : LSeries (⇑muC) u = LSeries (fun n : ℕ => ((ArithmeticFunction.moebius n : ℤ) : ℂ)) u :=
      tsum_congr fun n => by simp [LSeries.term, hmu_eq n]
    rw [← LSeries_one_eq_riemannZeta hu, hLmu]
    exact LSeries_one_mul_Lseries_moebius hu
  have hL_mul : LSeries f u = LSeries (⇑(gSigmaT (1 / 2) t 1)) u * LSeries (⇑muC) u :=
    ArithmeticFunction.LSeries_mul' hsum_g hsum_mu
  have hL_eq : LSeries f u = riemannZeta (u + sCrit t) / riemannZeta u := by
    rw [hL_mul, hL_g, div_eq_mul_inv]
    congr 1
    exact eq_inv_of_mul_eq_one_right hzeta_mu
  have hint_eq :
      (∫ x in Set.Ioi (1 : ℝ), (∑ k ∈ Finset.Icc 1 ⌊x⌋₊, f k) * (x : ℂ) ^ (-(u + 1))) = H_t t u := by
    refine setIntegral_congr_fun measurableSet_Ioi fun x hx => ?_
    rw [S_t_of_one_le t hx.le, scalarSC_wSigmaT_eq_sum_mul]
  rw [hint_eq, hL_eq] at hL_int
  calc H_t t u
      = (u * H_t t u) / u := (mul_div_cancel_left₀ _ hu0).symm
    _ = (riemannZeta (u + sCrit t) / riemannZeta u) / u := by rw [← hL_int]
    _ = riemannZeta (u + sCrit t) / (u * riemannZeta u) := by ring

/-! ## 3. Totient Dirichlet series and T2: Tonelli energy Mellin identity -/

private lemma totient_sum_term (n : ℕ) :
    (((fun k : ℕ => (k.totient : ℂ)) ⍟ (1 : ℕ → ℂ)) n) = (n : ℂ) := by
  rw [LSeries.convolution_def]
  simp only [Pi.one_apply, mul_one]
  rcases eq_or_ne n 0 with rfl | hn
  · simp
  · rw [Nat.sum_divisorsAntidiagonal (f := fun d _ => (d.totient : ℂ))]
    exact_mod_cast Nat.sum_totient n

private lemma LSeries_totient_eq_zeta_div {z : ℂ} (hz : 2 < z.re) :
    LSeries (fun r : ℕ => (r.totient : ℂ)) z = riemannZeta (z - 1) / riemannZeta z := by
  have hz1 : 1 < z.re := by linarith
  have hz_sub1 : 1 < (z - 1).re := by simp; linarith
  have hsumm_phi : LSeriesSummable (fun r : ℕ => (r.totient : ℂ)) z := by
    have hpow : Summable (fun r : ℕ => (1 : ℝ) / (r : ℝ) ^ (z.re - 1)) :=
      Real.summable_one_div_nat_rpow.mpr (by linarith)
    refine Summable.of_norm_bounded (g := fun r : ℕ => (1 : ℝ) / (r : ℝ) ^ (z.re - 1)) hpow ?_
    intro r
    rcases eq_or_ne r 0 with rfl | hr
    · simp only [LSeries.term_zero, norm_zero, Nat.cast_zero]
      exact div_nonneg zero_le_one (Real.rpow_nonneg le_rfl _)
    · rw [LSeries.term_of_ne_zero hr, norm_div]
      have hr_pos : (0 : ℝ) < (r : ℝ) := Nat.cast_pos.mpr (Nat.pos_of_ne_zero hr)
      rw [Complex.norm_natCast, Complex.norm_natCast_cpow_of_pos (Nat.pos_of_ne_zero hr)]
      have hle : (r.totient : ℝ) ≤ (r : ℝ) := by exact_mod_cast Nat.totient_le r
      calc (r.totient : ℝ) / (r : ℝ) ^ z.re
          ≤ (r : ℝ) / (r : ℝ) ^ z.re := by gcongr
        _ = (r : ℝ) ^ (1 : ℝ) / (r : ℝ) ^ z.re := by simp
        _ = 1 / (r : ℝ) ^ (z.re - 1) := by
            rw [← Real.rpow_sub hr_pos, show (1 - z.re : ℝ) = -(z.re - 1) by ring,
              Real.rpow_neg hr_pos.le, one_div]
  have hsumm_one : LSeriesSummable (1 : ℕ → ℂ) z := LSeriesSummable_one_iff.mpr hz1
  have hconv := LSeries_convolution' hsumm_phi hsumm_one
  have hid : LSeries ((fun k : ℕ => (k.totient : ℂ)) ⍟ (1 : ℕ → ℂ)) z =
      riemannZeta (z - 1) := by
    have hterm : ∀ n : ℕ, LSeries.term ((fun k : ℕ => (k.totient : ℂ)) ⍟ (1 : ℕ → ℂ)) z n =
        LSeries.term (1 : ℕ → ℂ) (z - 1) n := by
      intro n
      rcases eq_or_ne n 0 with rfl | hn
      · simp
      · rw [LSeries.term_of_ne_zero hn, LSeries.term_of_ne_zero hn, totient_sum_term n]
        simp only [Pi.one_apply]
        have hnc : (n : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr hn
        rw [Complex.cpow_sub _ _ hnc, Complex.cpow_one]
        field_simp [hnc]
    rw [show LSeries ((fun k : ℕ => (k.totient : ℂ)) ⍟ (1 : ℕ → ℂ)) z = LSeries 1 (z - 1) from
      tsum_congr hterm, LSeries_one_eq_riemannZeta hz_sub1]
  rw [hconv, LSeries_one_eq_riemannZeta hz1] at hid
  exact eq_div_of_mul_eq (riemannZeta_ne_zero_of_one_lt_re hz1) hid

lemma summable_totient_div_rpow {h : ℝ} (hh : 0 < h) :
    Summable (fun r : ℕ => (r.totient : ℝ) / (r : ℝ) ^ (2 + h)) := by
  refine Summable.of_nonneg_of_le (fun r => by positivity) ?_
    (Real.summable_one_div_nat_rpow.mpr (show 1 < 1 + h by linarith))
  intro r
  rcases eq_or_ne r 0 with rfl | hr
  · simp only [Nat.totient_zero, Nat.cast_zero, zero_div, one_div]
    exact inv_nonneg.mpr (Real.rpow_nonneg le_rfl _)
  · have hr_pos : (0 : ℝ) < (r : ℝ) := Nat.cast_pos.mpr (Nat.pos_of_ne_zero hr)
    have hle : (r.totient : ℝ) ≤ (r : ℝ) := by exact_mod_cast Nat.totient_le r
    calc (r.totient : ℝ) / (r : ℝ) ^ (2 + h)
        ≤ (r : ℝ) / (r : ℝ) ^ (2 + h) := by gcongr
      _ = 1 / (r : ℝ) ^ (1 + h) := by
          rw [show (2 + h : ℝ) = 1 + (1 + h) by ring, Real.rpow_add hr_pos, Real.rpow_one]
          field_simp [hr_pos.ne']

theorem totient_LSeries_eq_zeta_div {h : ℝ} (hh : 0 < h) :
    (J_h h : ℂ) = riemannZeta (1 + (h : ℂ)) / riemannZeta (2 + (h : ℂ)) := by
  have hz : 2 < (2 + (h : ℂ)).re := by simp; linarith
  have hL := LSeries_totient_eq_zeta_div hz
  have hJ : (J_h h : ℂ) = LSeries (fun r : ℕ => (r.totient : ℂ)) (2 + (h : ℂ)) := by
    unfold J_h LSeries
    rw [Complex.ofReal_tsum]
    refine tsum_congr fun r => ?_
    rcases eq_or_ne r 0 with rfl | hr
    · simp
    · rw [LSeries.term_of_ne_zero hr]
      have hpow : (((r : ℝ) ^ (2 + h) : ℝ) : ℂ) = (r : ℂ) ^ ((2 : ℂ) + (h : ℂ)) := by
        rw [← Complex.ofReal_natCast, Complex.ofReal_cpow (Nat.cast_nonneg r)]
        norm_cast
      rw [Complex.ofReal_div, Complex.ofReal_natCast, hpow]
  rw [hJ, hL]
  congr 2
  ring

lemma J_h_pos {h : ℝ} (hh : 0 < h) : 0 < J_h h := by
  have h1 : (1 : ℝ) ≤ J_h h := by
    simpa [J_h] using (summable_totient_div_rpow hh).le_tsum 1 (fun _ _ => by positivity)
  linarith

theorem tendsto_mul_J_h :
    Tendsto (fun h : ℝ => h * J_h h) (𝓝[>] (0 : ℝ)) (𝓝 (6 / Real.pi ^ 2)) := by
  have hc : Tendsto (fun h : ℝ => ((1 + (h : ℂ)) - 1) * riemannZeta (1 + (h : ℂ)))
      (𝓝[>] (0 : ℝ)) (𝓝 (1 : ℂ)) := by
    refine riemannZeta_residue_one.comp ?_
    refine tendsto_nhdsWithin_iff.mpr ⟨?_, ?_⟩
    · have hcont : Continuous (fun h : ℝ => (1 : ℂ) + (h : ℂ)) := continuous_const.add Complex.continuous_ofReal
      simpa using (hcont.tendsto (0 : ℝ)).mono_left nhdsWithin_le_nhds
    · exact eventually_nhdsWithin_iff.mpr <| Eventually.of_forall fun h (hh : 0 < h) => by
        intro heq
        have : ((1 : ℂ) + (h : ℂ)).re = (1 : ℂ).re := congr_arg Complex.re heq
        simp at this
        linarith
  have hd : Tendsto (fun h : ℝ => riemannZeta (2 + (h : ℂ)))
      (𝓝[>] (0 : ℝ)) (𝓝 (riemannZeta 2)) := by
    have hcont : ContinuousAt riemannZeta 2 :=
      (differentiableAt_riemannZeta (by norm_num : (2 : ℂ) ≠ 1)).continuousAt
    refine (hcont.tendsto.comp ?_).mono_left nhdsWithin_le_nhds
    have h2 : Continuous (fun h : ℝ => (2 : ℂ) + (h : ℂ)) := continuous_const.add Complex.continuous_ofReal
    simpa using h2.tendsto (0 : ℝ)
  have hdiv : Tendsto
      (fun h : ℝ => (((1 + (h : ℂ)) - 1) * riemannZeta (1 + (h : ℂ))) / riemannZeta (2 + (h : ℂ)))
      (𝓝[>] (0 : ℝ)) (𝓝 ((1 : ℂ) / riemannZeta 2)) :=
    hc.div hd (riemannZeta_ne_zero_of_one_lt_re (by norm_num : 1 < (2 : ℂ).re))
  have hre := (Complex.continuous_re.tendsto _).comp hdiv
  have hval : ((1 : ℂ) / riemannZeta 2).re = 6 / Real.pi ^ 2 := by
    rw [riemannZeta_two]
    have : (1 : ℂ) / ((Real.pi : ℂ) ^ 2 / 6) = (((6 / Real.pi ^ 2 : ℝ) : ℂ)) := by
      push_cast; ring
    rw [this, Complex.ofReal_re]
  rw [hval] at hre
  refine hre.congr' (eventually_nhdsWithin_iff.mpr <| Eventually.of_forall fun h (hh : 0 < h) => ?_)
  have hJ := totient_LSeries_eq_zeta_div hh
  have heq_c : (((h * J_h h : ℝ) : ℂ)) =
      (((1 + (h : ℂ)) - 1) * riemannZeta (1 + (h : ℂ))) / riemannZeta (2 + (h : ℂ)) := by
    rw [Complex.ofReal_mul, hJ]
    ring
  change (((1 + (h : ℂ) - 1) * riemannZeta (1 + (h : ℂ))) / riemannZeta (2 + (h : ℂ))).re = h * J_h h
  rw [← heq_c, Complex.ofReal_re]

private lemma lintegral_Ioi_comp_mul_left {r : ℝ} (hr : 0 < r) {g : ℝ → ℝ≥0∞}
    (hg : Measurable g) :
    (∫⁻ x in Set.Ioi r, g x) = ENNReal.ofReal r * ∫⁻ y in Set.Ioi (1 : ℝ), g (r * y) := by
  have hsmul := Real.smul_map_volume_mul_left hr.ne'
  rw [abs_of_pos hr] at hsmul
  have hL : (∫⁻ x in Set.Ioi r, g x) =
      ∫⁻ x, (Set.Ioi r).indicator g x ∂(ENNReal.ofReal r • Measure.map (r * ·) volume) := by
    rw [← lintegral_indicator measurableSet_Ioi, hsmul]
  rw [hL, lintegral_smul_measure, lintegral_map (hg.indicator measurableSet_Ioi) (measurable_const_mul r)]
  congr 1
  rw [← lintegral_indicator measurableSet_Ioi]
  refine lintegral_congr fun y => ?_
  by_cases hy : 1 < y
  · have hry : r < r * y := by nlinarith
    simp [Set.indicator_of_mem, hy, hry]
  · have hry : ¬ (r * y ∈ Set.Ioi r) := by
      simp only [Set.mem_Ioi, not_lt] at hy ⊢
      nlinarith
    simp [Set.indicator_of_notMem, hy, hry]

/-- **T2 (Tonelli energy Mellin identity, allowing `∞` in `ℝ≥0∞`).** -/
theorem lintegral_E_eq_J_mul_lintegral_S_sq (t : ℝ) {h : ℝ} (hh : 0 < h) :
    (∫⁻ x in Set.Ioi (1 : ℝ), ENNReal.ofReal (E_t t x * x ^ (-2 - h))) =
      ENNReal.ofReal (J_h h) *
        ∫⁻ y in Set.Ioi (1 : ℝ), ENNReal.ofReal (‖S_t t y‖ ^ 2 * y ^ (-2 - h)) := by
  let f : ℕ → ℝ → ℝ≥0∞ := fun r x =>
    if r = 0 then 0 else
      ENNReal.ofReal (((r.totient : ℝ) / (r : ℝ)) * (‖S_t t (x / (r : ℝ))‖ ^ 2 * x ^ (-2 - h)))
  have hf_meas : ∀ r : ℕ, Measurable (f r) := by
    intro r
    by_cases hr : r = 0
    · subst hr; simp [f]
    · simp only [f, hr, ↓reduceIte]
      refine Measurable.ennreal_ofReal ?_
      refine Measurable.mul measurable_const ?_
      refine Measurable.mul ?_ ?_
      · exact ((S_t_measurable t).comp (measurable_id.div_const (r : ℝ))).norm.pow_const 2
      · exact measurable_id.pow_const (-2 - h)
  have hpoint : ∀ x ∈ Set.Ioi (1 : ℝ),
      ENNReal.ofReal (E_t t x * x ^ (-2 - h)) = ∑' r : ℕ, f r x := by
    intro x hx
    have hx1 : (1 : ℝ) ≤ x := hx.out.le
    have hE_eq : E_t t x * x ^ (-2 - h) =
        ∑ r ∈ Finset.Icc 1 ⌊x⌋₊,
          ((r.totient : ℝ) / (r : ℝ)) * (‖S_t t (x / (r : ℝ))‖ ^ 2 * x ^ (-2 - h)) := by
      rw [E_t_of_one_le t hx1, energyC, Finset.sum_mul]
      have hfilt : (Finset.Icc 1 ⌊x⌋₊).filter (fun r => Nat.Coprime r 1) = Finset.Icc 1 ⌊x⌋₊ := by
        ext r; simp
      rw [hfilt]
      refine Finset.sum_congr rfl fun r hr => ?_
      have hr1 : 1 ≤ r := (Finset.mem_Icc.mp hr).1
      have hr_le : r ≤ ⌊x⌋₊ := (Finset.mem_Icc.mp hr).2
      have hr_pos : (0 : ℝ) < (r : ℝ) := Nat.cast_pos.mpr hr1
      have hxr : 1 ≤ x / (r : ℝ) := by
        rw [one_le_div hr_pos]
        exact (Nat.le_floor_iff (by linarith : 0 ≤ x)).mp hr_le
      rw [jWeightC_wSigmaT_half_eq_totient_div hr1 t, S_t_of_one_le t hxr,
        Nat.floor_div_natCast]
      ring
    have htsum_eq :
        ENNReal.ofReal (E_t t x * x ^ (-2 - h)) =
          ∑ r ∈ Finset.Icc 1 ⌊x⌋₊, f r x := by
      rw [hE_eq, ENNReal.ofReal_sum_of_nonneg]
      · refine Finset.sum_congr rfl fun r hr => ?_
        have hr0 : r ≠ 0 := by have := (Finset.mem_Icc.mp hr).1; omega
        simp [f, hr0]
      · intro r hr
        have hr1 : 1 ≤ r := (Finset.mem_Icc.mp hr).1
        positivity
    rw [htsum_eq]
    symm
    refine tsum_eq_sum fun r hr_not => ?_
    by_cases hr0 : r = 0
    · simp [f, hr0]
    · have hr_gt : ⌊x⌋₊ < r := by
        simp only [Finset.mem_Icc, not_and, not_le] at hr_not
        exact hr_not (Nat.pos_of_ne_zero hr0)
      have hx_lt_r : x < (r : ℝ) := by
        have hlt := Nat.lt_of_floor_lt hr_gt
        exact hlt.trans_le (Nat.cast_le.mpr (by omega))
      have hxr : x / (r : ℝ) < 1 := (div_lt_one (Nat.cast_pos.mpr (Nat.pos_of_ne_zero hr0))).mpr hx_lt_r
      simp [f, hr0, S_t_of_lt_one t hxr]
  have hcongr :
      (∫⁻ x in Set.Ioi (1 : ℝ), ENNReal.ofReal (E_t t x * x ^ (-2 - h))) =
        ∫⁻ x in Set.Ioi (1 : ℝ), ∑' r : ℕ, f r x :=
    setLIntegral_congr_fun measurableSet_Ioi hpoint
  rw [hcongr, lintegral_tsum (fun r => (hf_meas r).aemeasurable)]
  have hterm_int : ∀ r : ℕ,
      (∫⁻ x in Set.Ioi (1 : ℝ), f r x) =
        ENNReal.ofReal ((r.totient : ℝ) / (r : ℝ) ^ (2 + h)) *
          ∫⁻ y in Set.Ioi (1 : ℝ), ENNReal.ofReal (‖S_t t y‖ ^ 2 * y ^ (-2 - h)) := by
    intro r
    rcases eq_or_ne r 0 with rfl | hr0
    · simp [f]
    · have hr1 : 1 ≤ r := Nat.pos_of_ne_zero hr0
      have hr_pos : (0 : ℝ) < (r : ℝ) := Nat.cast_pos.mpr hr1
      let g : ℝ → ℝ≥0∞ := fun x => ENNReal.ofReal (‖S_t t (x / (r : ℝ))‖ ^ 2 * x ^ (-2 - h))
      have hg_meas : Measurable g :=
        Measurable.ennreal_ofReal
          (((S_t_measurable t).comp (measurable_id.div_const (r : ℝ))).norm.pow_const 2 |>.mul
            (measurable_id.pow_const (-2 - h)))
      have hf_eq_mul :
          (fun x => f r x) = fun x => ENNReal.ofReal ((r.totient : ℝ) / (r : ℝ)) * g x := by
        ext x
        simp only [f, hr0, ↓reduceIte, g]
        rw [← ENNReal.ofReal_mul (by positivity)]
      rw [hf_eq_mul, lintegral_const_mul _ hg_meas]
      have hIoi_eq : (∫⁻ x in Set.Ioi (1 : ℝ), g x) = ∫⁻ x in Set.Ioi (r : ℝ), g x := by
        rw [← lintegral_indicator measurableSet_Ioi, ← lintegral_indicator measurableSet_Ioi]
        refine lintegral_congr_ae ?_
        have hae : ∀ᵐ x ∂volume, x ≠ (r : ℝ) := ae_iff.mpr (by simp)
        filter_upwards [hae] with x hxne
        rcases lt_or_gt_of_ne hxne with hlt | hgt
        · have hnot_r : x ∉ Set.Ioi (r : ℝ) := by simp [hlt.le]
          rw [Set.indicator_of_notMem hnot_r]
          by_cases hx1 : (1 : ℝ) < x
          · have hxr : x / (r : ℝ) < 1 := (div_lt_one hr_pos).mpr hlt
            have hgx : g x = 0 := by simp only [g, S_t_of_lt_one t hxr, norm_zero, ne_eq, OfNat.ofNat_ne_zero, not_false_eq_true, zero_pow, zero_mul, ENNReal.ofReal_zero]
            rw [Set.indicator_of_mem (s := Set.Ioi (1 : ℝ)) hx1, hgx]
          · rw [Set.indicator_of_notMem (s := Set.Ioi (1 : ℝ)) (by simpa using hx1)]
        · have hx1 : (1 : ℝ) < x := (by exact_mod_cast hr1 : (1 : ℝ) ≤ (r : ℝ)).trans_lt hgt
          rw [Set.indicator_of_mem (s := Set.Ioi (1 : ℝ)) hx1,
            Set.indicator_of_mem (s := Set.Ioi (r : ℝ)) hgt]
      rw [hIoi_eq, lintegral_Ioi_comp_mul_left hr_pos hg_meas]
      have hscale :
          (∫⁻ y in Set.Ioi (1 : ℝ), g ((r : ℝ) * y)) =
            ENNReal.ofReal ((r : ℝ) ^ (-2 - h)) *
              ∫⁻ y in Set.Ioi (1 : ℝ), ENNReal.ofReal (‖S_t t y‖ ^ 2 * y ^ (-2 - h)) := by
        have hgy : Set.EqOn (fun y => g ((r : ℝ) * y))
            (fun y => ENNReal.ofReal ((r : ℝ) ^ (-2 - h)) * ENNReal.ofReal (‖S_t t y‖ ^ 2 * y ^ (-2 - h)))
            (Set.Ioi (1 : ℝ)) := by
          intro y hy
          have hy_pos : (0 : ℝ) < y := lt_trans zero_lt_one hy
          simp only [g]
          rw [mul_div_cancel_left₀ y hr_pos.ne',
            Real.mul_rpow hr_pos.le hy_pos.le,
            ← ENNReal.ofReal_mul (Real.rpow_nonneg hr_pos.le _)]
          congr 1; ring
        rw [setLIntegral_congr_fun measurableSet_Ioi hgy]
        exact lintegral_const_mul _ (Measurable.ennreal_ofReal
          ((S_t_measurable t).norm.pow_const 2 |>.mul (measurable_id.pow_const (-2 - h))))
      rw [hscale]
      have hcomb :
          ENNReal.ofReal ((r.totient : ℝ) / (r : ℝ)) *
            (ENNReal.ofReal (r : ℝ) * ENNReal.ofReal ((r : ℝ) ^ (-2 - h))) =
            ENNReal.ofReal ((r.totient : ℝ) / (r : ℝ) ^ (2 + h)) := by
        rw [← ENNReal.ofReal_mul hr_pos.le, ← ENNReal.ofReal_mul (by positivity)]
        congr 1
        rw [show (-2 - h : ℝ) = -(2 + h) by ring, Real.rpow_neg hr_pos.le]
        field_simp [hr_pos.ne', (Real.rpow_pos_of_pos hr_pos (2 + h)).ne']
      calc ENNReal.ofReal ((r.totient : ℝ) / (r : ℝ)) *
              (ENNReal.ofReal (r : ℝ) * (ENNReal.ofReal ((r : ℝ) ^ (-2 - h)) *
                ∫⁻ y in Set.Ioi (1 : ℝ), ENNReal.ofReal (‖S_t t y‖ ^ 2 * y ^ (-2 - h))))
          = (ENNReal.ofReal ((r.totient : ℝ) / (r : ℝ)) *
              (ENNReal.ofReal (r : ℝ) * ENNReal.ofReal ((r : ℝ) ^ (-2 - h)))) *
              ∫⁻ y in Set.Ioi (1 : ℝ), ENNReal.ofReal (‖S_t t y‖ ^ 2 * y ^ (-2 - h)) := by ring
        _ = _ := by rw [hcomb]
  simp_rw [hterm_int, ENNReal.tsum_mul_right]
  rw [← ENNReal.ofReal_tsum_of_nonneg (fun r => by positivity) (summable_totient_div_rpow hh)]
  rfl

/-! ## 4. Log-power Mellin integrals and elementary Cauchy–Schwarz -/

private noncomputable def logPowAntideriv (k : ℕ) (h x : ℝ) : ℝ :=
  -x ^ (-h) * ∑ j ∈ Finset.range (k + 1),
    ((k.factorial : ℝ) / (j.factorial : ℝ)) * (Real.log x) ^ j / h ^ (k + 1 - j)

private lemma hasDerivAt_logPowAntideriv (k : ℕ) {h : ℝ} (hh : 0 < h) {x : ℝ} (hx : 1 ≤ x) :
    HasDerivAt (logPowAntideriv k h) ((Real.log x) ^ k * x ^ (-1 - h)) x := by
  have hx0 : 0 < x := lt_of_lt_of_le zero_lt_one hx
  have hlog : HasDerivAt Real.log x⁻¹ x := Real.hasDerivAt_log hx0.ne'
  have hrpow : HasDerivAt (fun t : ℝ => t ^ (-h)) ((-h) * x ^ (-h - 1)) x :=
    Real.hasDerivAt_rpow_const (x := x) (p := -h) (Or.inl hx0.ne')
  let c : ℕ → ℝ := fun j => ((k.factorial : ℝ) / (j.factorial : ℝ)) / h ^ (k + 1 - j)
  let S : ℝ → ℝ := fun t => ∑ j ∈ Finset.range (k + 1), c j * (Real.log t) ^ j
  have hS_deriv : HasDerivAt S
      (∑ j ∈ Finset.range (k + 1), if j = 0 then 0 else c j * (j : ℝ) * (Real.log x) ^ (j - 1) * x⁻¹) x := by
    have heach : ∀ j ∈ Finset.range (k + 1),
        HasDerivAt (fun t => c j * (Real.log t) ^ j)
          (if j = 0 then 0 else c j * (j : ℝ) * (Real.log x) ^ (j - 1) * x⁻¹) x := by
      intro j _
      rcases eq_or_ne j 0 with rfl | hj
      · simp [hasDerivAt_const]
      · simp only [hj, ↓reduceIte]
        have hpow := (hlog.pow j).const_mul (c j)
        convert hpow using 1
        ring
    convert HasDerivAt.sum heach using 1
    ext t
    simp [S]
  have hfn : ((-fun t : ℝ => t ^ (-h)) * S) = logPowAntideriv k h := by
    ext t; simp [logPowAntideriv, S, c, mul_div_assoc, div_mul_eq_mul_div]
  have hprod : HasDerivAt (logPowAntideriv k h) _ x := hfn ▸ (hrpow.neg).mul hS_deriv
  convert hprod using 1
  have hx_pow : x ^ (-h - 1) = x ^ (-1 - h) := by congr 1; ring
  have htelesc : h * S x - x * (∑ j ∈ Finset.range (k + 1),
      if j = 0 then 0 else c j * (j : ℝ) * (Real.log x) ^ (j - 1) * x⁻¹) =
      (Real.log x) ^ k := by
    have h1 : h * S x = ∑ j ∈ Finset.range (k + 1),
        ((k.factorial : ℝ) / (j.factorial : ℝ)) * (Real.log x) ^ j / h ^ (k - j) := by
      simp only [S, c, Finset.mul_sum]
      refine Finset.sum_congr rfl fun j hj => ?_
      have hjk : j ≤ k := Nat.lt_succ_iff.mp (Finset.mem_range.mp hj)
      rw [show k + 1 - j = (k - j) + 1 by omega, pow_succ]
      field_simp [hh.ne']
    have h2 : x * (∑ j ∈ Finset.range (k + 1),
        if j = 0 then 0 else c j * (j : ℝ) * (Real.log x) ^ (j - 1) * x⁻¹) =
        ∑ j ∈ Finset.range k,
          ((k.factorial : ℝ) / (j.factorial : ℝ)) * (Real.log x) ^ j / h ^ (k - j) := by
      rw [Finset.mul_sum, Finset.sum_range_succ']
      simp only [↓reduceIte, mul_zero, add_zero]
      refine Finset.sum_congr rfl fun j hj => ?_
      have hjk : j < k := Finset.mem_range.mp hj
      have hj1 : j + 1 ≠ 0 := Nat.succ_ne_zero j
      simp only [hj1, ↓reduceIte, c, Nat.add_sub_cancel]
      have hsub : k + 1 - (j + 1) = k - j := by omega
      rw [hsub, Nat.factorial_succ]
      push_cast
      field_simp [hh.ne', hx0.ne', (show (j.factorial : ℝ) ≠ 0 by positivity)]
    rw [h1, h2, Finset.sum_range_succ]
    simp only [Nat.sub_self, pow_zero, div_self (show (k.factorial : ℝ) ≠ 0 by positivity),
      one_mul, div_one]
    ring
  have hx_mul : x * x ^ (-1 - h) = x ^ (-h) := by
    calc x * x ^ (-1 - h)
        = x ^ (1 : ℝ) * x ^ (-1 - h) := by rw [Real.rpow_one]
      _ = x ^ (1 + (-1 - h)) := (Real.rpow_add hx0 1 (-1 - h)).symm
      _ = x ^ (-h) := by ring_nf
  calc (Real.log x) ^ k * x ^ (-1 - h)
      = (h * S x - x * ∑ j ∈ Finset.range (k + 1),
          if j = 0 then 0 else c j * (j : ℝ) * (Real.log x) ^ (j - 1) * x⁻¹) * x ^ (-1 - h) := by
          rw [htelesc]
    _ = h * x ^ (-1 - h) * S x - (x * x ^ (-1 - h)) * ∑ j ∈ Finset.range (k + 1),
          if j = 0 then 0 else c j * (j : ℝ) * (Real.log x) ^ (j - 1) * x⁻¹ := by ring
    _ = -(-h * x ^ (-h - 1)) * S x + -(x ^ (-h)) * ∑ j ∈ Finset.range (k + 1),
          if j = 0 then 0 else c j * (j : ℝ) * (Real.log x) ^ (j - 1) * x⁻¹ := by
          rw [hx_mul, ← hx_pow]; ring

private lemma tendsto_logPowAntideriv_atTop (k : ℕ) {h : ℝ} (hh : 0 < h) :
    Tendsto (logPowAntideriv k h) atTop (𝓝 0) := by
  have hterm : ∀ j : ℕ, Tendsto (fun x : ℝ => x ^ (-h) * (Real.log x) ^ j) atTop (𝓝 0) := by
    intro j
    rcases eq_or_ne j 0 with rfl | hj
    · simpa using tendsto_rpow_neg_atTop hh
    · have hj_nat : 0 < j := Nat.pos_of_ne_zero hj
      have hj_pos : (0 : ℝ) < (j : ℝ) := Nat.cast_pos.mpr hj_nat
      have hlog_littleO : Real.log =o[atTop] fun x : ℝ => x ^ (h / (j : ℝ)) :=
        isLittleO_log_rpow_atTop (div_pos hh hj_pos)
      have hpow_littleO : (fun x : ℝ => (Real.log x) ^ j) =o[atTop] fun x : ℝ => (x ^ (h / (j : ℝ))) ^ j :=
        hlog_littleO.pow hj_nat
      have hzero : Tendsto (fun x : ℝ => (Real.log x) ^ j / x ^ h) atTop (𝓝 0) := by
        refine Asymptotics.IsLittleO.tendsto_div_nhds_zero ?_
        refine hpow_littleO.congr' EventuallyEq.rfl ?_
        filter_upwards [eventually_gt_atTop (0 : ℝ)] with x hx
        rw [← Real.rpow_natCast, ← Real.rpow_mul hx.le, div_mul_cancel₀ h hj_pos.ne']
      refine hzero.congr' ?_
      filter_upwards [eventually_gt_atTop (0 : ℝ)] with x hx
      rw [Real.rpow_neg hx.le, div_eq_inv_mul]
  have hsum : Tendsto (fun x : ℝ => ∑ j ∈ Finset.range (k + 1),
      ((k.factorial : ℝ) / (j.factorial : ℝ)) / h ^ (k + 1 - j) * (x ^ (-h) * (Real.log x) ^ j))
      atTop (𝓝 0) := by
    have : Tendsto (fun x : ℝ => ∑ j ∈ Finset.range (k + 1),
        ((k.factorial : ℝ) / (j.factorial : ℝ)) / h ^ (k + 1 - j) * (x ^ (-h) * (Real.log x) ^ j))
        atTop (𝓝 (∑ _j ∈ Finset.range (k + 1), (0 : ℝ))) :=
      tendsto_finsetSum _ fun j _ => by simpa only [mul_zero] using (hterm j).const_mul _
    simpa only [Finset.sum_const_zero] using this
  have hneg : Tendsto (fun x : ℝ => - ∑ j ∈ Finset.range (k + 1),
      ((k.factorial : ℝ) / (j.factorial : ℝ)) / h ^ (k + 1 - j) * (x ^ (-h) * (Real.log x) ^ j))
      atTop (𝓝 0) := by
    simpa only [neg_zero] using hsum.neg
  refine hneg.congr' ?_
  filter_upwards with x
  unfold logPowAntideriv
  calc - ∑ j ∈ Finset.range (k + 1),
        ((k.factorial : ℝ) / (j.factorial : ℝ)) / h ^ (k + 1 - j) * (x ^ (-h) * (Real.log x) ^ j)
      = -(x ^ (-h) * ∑ j ∈ Finset.range (k + 1),
          ((k.factorial : ℝ) / (j.factorial : ℝ)) * (Real.log x) ^ j / h ^ (k + 1 - j)) := by
          congr 1
          rw [Finset.mul_sum]
          refine Finset.sum_congr rfl fun j _ => by ring
    _ = -x ^ (-h) * ∑ j ∈ Finset.range (k + 1),
          ((k.factorial : ℝ) / (j.factorial : ℝ)) * (Real.log x) ^ j / h ^ (k + 1 - j) :=
          (neg_mul _ _).symm

theorem integrableOn_Ioi_log_pow_mul_rpow (k : ℕ) {h : ℝ} (hh : 0 < h) :
    IntegrableOn (fun x : ℝ => (Real.log x) ^ k * x ^ (-1 - h)) (Set.Ioi 1) := by
  refine integrableOn_Ioi_deriv_of_nonneg
    (hasDerivAt_logPowAntideriv k hh le_rfl).continuousAt.continuousWithinAt
    (fun x hx => hasDerivAt_logPowAntideriv k hh hx.out.le)
    (fun x hx => mul_nonneg (pow_nonneg (Real.log_nonneg hx.out.le) _) (Real.rpow_nonneg (by linarith [hx.out]) _))
    (tendsto_logPowAntideriv_atTop k hh)

theorem integral_Ioi_log_pow_mul_rpow (k : ℕ) {h : ℝ} (hh : 0 < h) :
    (∫ x in Set.Ioi (1 : ℝ), (Real.log x) ^ k * x ^ (-1 - h)) = (k.factorial : ℝ) / h ^ (k + 1) := by
  have hint := integrableOn_Ioi_log_pow_mul_rpow k hh
  have heq := integral_Ioi_of_hasDerivAt_of_tendsto'
    (fun x hx => hasDerivAt_logPowAntideriv k hh hx) hint (tendsto_logPowAntideriv_atTop k hh)
  rw [heq, zero_sub]
  unfold logPowAntideriv
  have h1 : ∀ j ∈ Finset.range (k + 1),
      ((k.factorial : ℝ) / (j.factorial : ℝ)) * (Real.log 1) ^ j / h ^ (k + 1 - j) =
        if j = 0 then (k.factorial : ℝ) / h ^ (k + 1) else 0 := by
    intro j _
    rcases eq_or_ne j 0 with rfl | hj
    · simp
    · simp [hj]
  rw [Real.one_rpow, Finset.sum_congr rfl h1, Finset.sum_ite_eq']
  simp

/-- Elementary Cauchy–Schwarz inequality on `Set.Ioi 1` for nonnegative measurable functions. -/
lemma sq_integral_mul_le_mul_integral_sq {a b : ℝ → ℝ}
    (_hb0 : ∀ x ∈ Set.Ioi (1 : ℝ), 0 ≤ b x)
    (ha : IntegrableOn (fun x => a x ^ 2) (Set.Ioi 1))
    (hb : IntegrableOn (fun x => b x ^ 2) (Set.Ioi 1))
    (hab : IntegrableOn (fun x => a x * b x) (Set.Ioi 1)) :
    (∫ x in Set.Ioi (1 : ℝ), a x * b x) ^ 2 ≤
      (∫ x in Set.Ioi (1 : ℝ), a x ^ 2) * (∫ x in Set.Ioi (1 : ℝ), b x ^ 2) := by
  set B := ∫ x in Set.Ioi (1 : ℝ), b x ^ 2
  set C := ∫ x in Set.Ioi (1 : ℝ), a x * b x
  set A := ∫ x in Set.Ioi (1 : ℝ), a x ^ 2
  have hB0 : 0 ≤ B := setIntegral_nonneg measurableSet_Ioi fun _ _ => sq_nonneg _
  have hA0 : 0 ≤ A := setIntegral_nonneg measurableSet_Ioi fun _ _ => sq_nonneg _
  rcases eq_or_lt_of_le hB0 with hBz | hBpos
  · have hbz_ae : (fun x => b x ^ 2) =ᵐ[volume.restrict (Set.Ioi 1)] 0 :=
      (integral_eq_zero_iff_of_nonneg_ae (Eventually.of_forall fun _ => sq_nonneg _) hb).mp hBz.symm
    have hC0 : C = 0 := by
      refine integral_eq_zero_of_ae ?_
      filter_upwards [hbz_ae] with x hx
      have hbx : b x = 0 := sq_eq_zero_iff.mp hx
      simp [hbx]
    rw [hC0, ← hBz]; simp
  · have hquad : ∀ lam : ℝ,
        0 ≤ ∫ x in Set.Ioi (1 : ℝ), (a x - lam * b x) ^ 2 := by
      intro lam
      exact setIntegral_nonneg measurableSet_Ioi fun _ _ => sq_nonneg _
    have hexp : ∀ lam : ℝ,
        (∫ x in Set.Ioi (1 : ℝ), (a x - lam * b x) ^ 2) = A - 2 * lam * C + lam ^ 2 * B := by
      intro lam
      have heq : (fun x => (a x - lam * b x) ^ 2) =
          (fun x => (a x ^ 2 - (2 * lam) * (a x * b x)) + (lam ^ 2) * b x ^ 2) := by
        ext x; ring
      change (∫ x in Set.Ioi (1 : ℝ), (a x - lam * b x) ^ 2) = _
      simp_rw [heq]
      rw [integral_add (f := fun x => a x ^ 2 - (2 * lam) * (a x * b x))
        (g := fun x => (lam ^ 2) * b x ^ 2) (by exact ha.sub (hab.const_mul (2 * lam))) (by exact hb.const_mul (lam ^ 2)),
        integral_sub (by exact ha) (by exact hab.const_mul (2 * lam)), integral_const_mul, integral_const_mul]
    have h0 := hquad (C / B)
    rw [hexp (C / B)] at h0
    have hcalc : (A - 2 * (C / B) * C + (C / B) ^ 2 * B) * B = A * B - C ^ 2 := by
      field_simp [hBpos.ne']
      ring
    have h1 := mul_nonneg h0 hB0
    rw [hcalc] at h1
    linarith

/-! ## 5. Analytic continuation of `H_t` to `Re u > 1/2` -/

lemma differentiable_regZeta : Differentiable ℂ regZeta := by
  have hcomp : DifferentiableOn ℂ regZeta ({1}ᶜ) := by
    intro w hw
    have hw1 : w ≠ 1 := hw
    have hdz : DifferentiableAt ℂ (fun z : ℂ => (z - 1) * riemannZeta z) w :=
      (differentiableAt_id.sub_const 1).mul (differentiableAt_riemannZeta hw1)
    have hev : regZeta =ᶠ[𝓝 w] fun z : ℂ => (z - 1) * riemannZeta z := by
      filter_upwards [(isOpen_ne.mem_nhds hw1)] with z hz
      exact Function.update_of_ne hz 1 _
    exact (hdz.congr_of_eventuallyEq hev).differentiableWithinAt
  have hcont : ContinuousAt regZeta 1 := by
    have ht : Tendsto regZeta (𝓝[≠] 1) (𝓝 1) := by
      refine riemannZeta_residue_one.congr' ?_
      filter_upwards [self_mem_nhdsWithin] with z hz
      exact (Function.update_of_ne hz (1 : ℂ) (fun w : ℂ => (w - 1) * riemannZeta w)).symm
    have h1 : regZeta 1 = 1 := by simp [regZeta]
    exact continuousWithinAt_compl_self.mp (by simpa only [ContinuousWithinAt, h1] using ht)
  rw [← differentiableOn_univ]
  exact (Complex.differentiableOn_compl_singleton_and_continuousAt_iff Filter.univ_mem).mp
    ⟨hcomp.mono fun _ hz => hz.2, hcont⟩

lemma mellin_S_t_eq_H_t (t : ℝ) (u : ℂ) : mellin (S_t t) (-u) = H_t t u := by
  unfold mellin H_t
  rw [← integral_indicator measurableSet_Ioi, ← integral_indicator measurableSet_Ioi]
  refine integral_congr_ae ?_
  have hae : ∀ᵐ x ∂volume, x ≠ (1 : ℝ) := ae_iff.mpr (by simp)
  filter_upwards [hae] with x hxne
  rcases lt_or_gt_of_ne hxne with hlt | hgt
  · rw [Set.indicator_of_notMem (s := Set.Ioi (1 : ℝ)) (by simp; exact hlt.le)]
    by_cases hx0 : (0 : ℝ) < x
    · have hs0 : (x : ℂ) ^ (-u - 1) • S_t t x = 0 := by simp [S_t_of_lt_one t hlt]
      rw [Set.indicator_of_mem (s := Set.Ioi (0 : ℝ)) hx0, hs0]
    · rw [Set.indicator_of_notMem (s := Set.Ioi (0 : ℝ)) (by simpa using hx0)]
  · have hx0 : (0 : ℝ) < x := lt_trans zero_lt_one hgt
    rw [Set.indicator_of_mem (s := Set.Ioi (0 : ℝ)) hx0,
      Set.indicator_of_mem (s := Set.Ioi (1 : ℝ)) hgt, smul_eq_mul, mul_comm]
    congr 2
    ring

private lemma locallyIntegrableOn_S_t (t : ℝ) : LocallyIntegrableOn (S_t t) (Set.Ioi 0) := by
  rw [locallyIntegrableOn_iff isOpen_Ioi.isLocallyClosed]
  intro K _ hK_comp
  by_cases hK_ne : K.Nonempty
  · obtain ⟨M, hM⟩ := hK_comp.bddAbove
    let C : ℝ := ∑ n ∈ Finset.range (⌊M⌋₊ + 1), ‖scalarSC (wSigmaT (1 / 2) t) 1 n‖
    have hC0 : 0 ≤ C := Finset.sum_nonneg fun _ _ => norm_nonneg _
    have hconst : IntegrableOn (fun _ : ℝ => C) K :=
      integrableOn_const hK_comp.measure_lt_top.ne
    refine hconst.mono' (S_t_measurable t).aestronglyMeasurable ?_
    filter_upwards [ae_restrict_mem hK_comp.isClosed.measurableSet] with y hy
    have hy_le : y ≤ M := hM hy
    by_cases hy1 : y < 1
    · simpa [S_t_of_lt_one t hy1] using hC0
    · rw [S_t_of_one_le t (not_lt.mp hy1)]
      have hmem : ⌊y⌋₊ ∈ Finset.range (⌊M⌋₊ + 1) := by
        rw [Finset.mem_range, Nat.lt_succ_iff]
        exact Nat.floor_mono hy_le
      exact Finset.single_le_sum (fun n _ => norm_nonneg _) hmem
  · rw [Set.not_nonempty_iff_eq_empty.mp hK_ne]
    exact integrableOn_empty

private lemma E_t_le_of_eventually_le (t : ℝ) {K : ℝ} (hK : 0 < K) (a : ℕ) {N₀ : ℕ}
    (hN₀ : 3 ≤ N₀) (hbound : ∀ N ≥ N₀, energyC (wSigmaT (1 / 2) t) 1 N ≤ K * (N : ℝ) * (Real.log N) ^ a)
    {x : ℝ} (hx : (N₀ : ℝ) ≤ x) :
    E_t t x ≤ K * x * (Real.log x) ^ a := by
  have hx1 : (1 : ℝ) ≤ x := le_trans (by exact_mod_cast (by omega : 1 ≤ N₀)) hx
  have hfl_ge : N₀ ≤ ⌊x⌋₊ := (Nat.le_floor_iff (by linarith)).mpr hx
  have hfl_pos : 1 ≤ ⌊x⌋₊ := by omega
  have hfl_ge2 : (2 : ℝ) ≤ (⌊x⌋₊ : ℝ) := by exact_mod_cast (by omega : 2 ≤ ⌊x⌋₊)
  have hfl_le_x : (⌊x⌋₊ : ℝ) ≤ x := Nat.floor_le (by linarith)
  have hlog_nn : 0 ≤ Real.log (⌊x⌋₊ : ℝ) := Real.log_nonneg (by linarith)
  have hlog_le : Real.log (⌊x⌋₊ : ℝ) ≤ Real.log x := Real.log_le_log (by linarith) hfl_le_x
  rw [E_t_of_one_le t hx1]
  calc energyC (wSigmaT (1 / 2) t) 1 ⌊x⌋₊
      ≤ K * (⌊x⌋₊ : ℝ) * (Real.log (⌊x⌋₊ : ℝ)) ^ a := hbound ⌊x⌋₊ hfl_ge
    _ ≤ K * x * (Real.log x) ^ a := by
        gcongr

private lemma S_t_isBigO_of_energy_bound (t : ℝ) {K : ℝ} (hK : 0 < K) (a : ℕ) {N₀ : ℕ}
    (hN₀ : 3 ≤ N₀) (hbound : ∀ N ≥ N₀, energyC (wSigmaT (1 / 2) t) 1 N ≤ K * (N : ℝ) * (Real.log N) ^ a)
    {ε : ℝ} (hε : 0 < ε) :
    S_t t =O[atTop] (fun x : ℝ => x ^ (1 / 2 + ε)) := by
  have hlog_o : Real.log =o[atTop] fun x : ℝ => x ^ ((2 * ε) / ((a : ℝ) + 1)) :=
    isLittleO_log_rpow_atTop (by positivity)
  have hpow_o : (fun x : ℝ => (Real.log x) ^ a) =O[atTop] fun x : ℝ => x ^ (2 * ε) := by
    rcases eq_or_ne a 0 with rfl | ha
    · refine Asymptotics.IsBigO.of_bound 1 ?_
      filter_upwards [eventually_ge_atTop (1 : ℝ)] with x hx
      have hx1 : 1 ≤ x ^ (2 * ε) := Real.one_le_rpow hx (by positivity)
      have hpow_nn : 0 ≤ x ^ (2 * ε) := Real.rpow_nonneg (by linarith) _
      simpa [Real.norm_of_nonneg hpow_nn] using hx1
    · have hpo := (hlog_o.pow (Nat.pos_of_ne_zero ha)).isBigO
      refine hpo.trans (Asymptotics.IsBigO.of_bound 1 ?_)
      filter_upwards [eventually_gt_atTop (1 : ℝ)] with x hx
      have hx0 : 0 < x := lt_trans zero_lt_one hx
      rw [← Real.rpow_natCast (x ^ _), ← Real.rpow_mul hx0.le]
      have hexp : (2 * ε) / ((a : ℝ) + 1) * (a : ℝ) ≤ 2 * ε := by
        have ha_nn : (0 : ℝ) ≤ (a : ℝ) := Nat.cast_nonneg a
        rw [div_mul_eq_mul_div, div_le_iff₀ (by positivity)]
        nlinarith
      have hle := Real.rpow_le_rpow_of_exponent_le hx.le hexp
      simpa [Real.norm_of_nonneg (Real.rpow_nonneg hx0.le _)] using hle
  obtain ⟨C, hC_ev⟩ := hpow_o.bound
  have hC0 : 0 ≤ C := by
    obtain ⟨x, hx1, hx⟩ := (eventually_ge_atTop (1 : ℝ) |>.and hC_ev).exists
    have hxp : 0 < x ^ (2 * ε) := Real.rpow_pos_of_pos (by linarith) _
    rw [Real.norm_of_nonneg hxp.le] at hx
    have h0le : 0 ≤ C * x ^ (2 * ε) := le_trans (norm_nonneg _) hx
    exact (mul_nonneg_iff_left_nonneg_of_pos hxp).mp h0le
  refine Asymptotics.IsBigO.of_bound (Real.sqrt (K * C)) ?_
  filter_upwards [eventually_ge_atTop (max (N₀ : ℝ) 2), hC_ev] with x hx_ge hxC
  have hxN₀ : (N₀ : ℝ) ≤ x := le_trans (le_max_left _ _) hx_ge
  have hx2 : (2 : ℝ) ≤ x := le_trans (le_max_right _ _) hx_ge
  have hx1 : (1 : ℝ) ≤ x := by linarith
  have hx0 : 0 < x := by linarith
  have hfl_ge1 : 1 ≤ ⌊x⌋₊ := Nat.le_floor (by simpa using hx1)
  have hsq : ‖S_t t x‖ ^ 2 ≤ E_t t x := by
    rw [S_t_of_one_le t hx1, E_t_of_one_le t hx1]
    exact scalarSC_norm_sq_le_energyC (wSigmaT_half_norm_le_one t) 1 ⌊x⌋₊ hfl_ge1
  have hEt := E_t_le_of_eventually_le t hK a hN₀ hbound hxN₀
  have hlog_nn : 0 ≤ (Real.log x) ^ a := pow_nonneg (Real.log_nonneg hx1) a
  have hC_bound : (Real.log x) ^ a ≤ C * x ^ (2 * ε) := by
    simpa [Real.norm_of_nonneg hlog_nn, Real.norm_of_nonneg (Real.rpow_nonneg hx0.le _)] using hxC
  have hsq_le : ‖S_t t x‖ ^ 2 ≤ (Real.sqrt (K * C) * x ^ (1 / 2 + ε)) ^ 2 := by
    calc ‖S_t t x‖ ^ 2
        ≤ E_t t x := hsq
      _ ≤ K * x * (Real.log x) ^ a := hEt
      _ ≤ K * x * (C * x ^ (2 * ε)) := by gcongr
      _ = (K * C) * (x ^ (1 : ℝ) * x ^ (2 * ε)) := by simp; ring
      _ = (K * C) * x ^ (2 * (1 / 2 + ε)) := by
          rw [← Real.rpow_add hx0]
          congr 2; ring
      _ = (Real.sqrt (K * C) * x ^ (1 / 2 + ε)) ^ 2 := by
          rw [mul_pow, Real.sq_sqrt (by positivity),
            show (x ^ (1 / 2 + ε)) ^ (2 : ℕ) = x ^ (2 * (1 / 2 + ε)) by
              rw [← Real.rpow_natCast (x ^ (1 / 2 + ε)) 2, ← Real.rpow_mul hx0.le]
              push_cast; ring_nf]
  have hnorm_le := (sq_le_sq₀ (norm_nonneg _) (by positivity)).mp hsq_le
  simpa [Real.norm_of_nonneg (Real.rpow_nonneg hx0.le _)] using hnorm_le

private lemma S_t_isBigO_zero (t : ℝ) (b : ℝ) :
    S_t t =O[𝓝[>] (0 : ℝ)] (fun x : ℝ => x ^ (-b)) := by
  refine (Asymptotics.isBigO_zero (fun x : ℝ => x ^ (-b)) (𝓝[>] (0 : ℝ))).congr' ?_ EventuallyEq.rfl
  refine eventually_nhdsWithin_iff.mpr ?_
  filter_upwards [Iio_mem_nhds zero_lt_one] with x hx _
  exact (S_t_of_lt_one t hx).symm

private lemma H_t_analytic_and_hasDerivAt (t : ℝ) {K : ℝ} (hK : 0 < K) (a : ℕ) {N₀ : ℕ}
    (hN₀ : 3 ≤ N₀) (hbound : ∀ N ≥ N₀, energyC (wSigmaT (1 / 2) t) 1 N ≤ K * (N : ℝ) * (Real.log N) ^ a) :
    DifferentiableOn ℂ (H_t t) {u : ℂ | 1 / 2 < u.re} ∧
      ∀ {u : ℂ}, 1 / 2 < u.re →
        HasDerivAt (H_t t) (- ∫ x in Set.Ioi (1 : ℝ), (Real.log x : ℂ) * S_t t x * (x : ℂ) ^ (-(u + 1))) u ∧
        MellinConvergent (S_t t) (-u) ∧
        MellinConvergent (fun x : ℝ => Real.log x • S_t t x) (-u) := by
  have hderiv : ∀ {u : ℂ}, 1 / 2 < u.re →
      HasDerivAt (H_t t) (- ∫ x in Set.Ioi (1 : ℝ), (Real.log x : ℂ) * S_t t x * (x : ℂ) ^ (-(u + 1))) u ∧
      MellinConvergent (S_t t) (-u) ∧
      MellinConvergent (fun x : ℝ => Real.log x • S_t t x) (-u) := by
    intro u hu
    let ε := (u.re - 1 / 2) / 2
    have hε : 0 < ε := by dsimp [ε]; linarith
    have htop := S_t_isBigO_of_energy_bound t hK a hN₀ hbound hε
    have htop' : S_t t =O[atTop] (fun x : ℝ => x ^ (-(-(1 / 2 + ε)))) := by
      simpa only [neg_neg] using htop
    have hbot := S_t_isBigO_zero t (-u.re - 1)
    have hconv : MellinConvergent (S_t t) (-u) :=
      mellinConvergent_of_isBigO_rpow (s := -u) (locallyIntegrableOn_S_t t) htop'
        (by simp [ε]; linarith) hbot (by simp)
    obtain ⟨hmc_log, hm_deriv⟩ := mellin_hasDerivAt_of_isBigO_rpow (s := -u) (locallyIntegrableOn_S_t t)
      htop' (by simp [ε]; linarith) hbot (by simp)
    have hcomp : HasDerivAt (fun z => mellin (S_t t) (-z)) (mellin (fun x : ℝ => Real.log x • S_t t x) (-u) * (-1)) u :=
      hm_deriv.comp u (hasDerivAt_neg u)
    have hH : (fun z => mellin (S_t t) (-z)) = H_t t := funext (mellin_S_t_eq_H_t t)
    rw [hH] at hcomp
    have hint_eq :
        mellin (fun x : ℝ => Real.log x • S_t t x) (-u) * (-1) =
          - ∫ x in Set.Ioi (1 : ℝ), (Real.log x : ℂ) * S_t t x * (x : ℂ) ^ (-(u + 1)) := by
      have hmell_eq :
          mellin (fun x : ℝ => Real.log x • S_t t x) (-u) =
            ∫ x in Set.Ioi (1 : ℝ), (Real.log x : ℂ) * S_t t x * (x : ℂ) ^ (-(u + 1)) := by
        unfold mellin
        rw [← integral_indicator measurableSet_Ioi, ← integral_indicator measurableSet_Ioi]
        refine integral_congr_ae ?_
        have hae : ∀ᵐ x ∂volume, x ≠ (1 : ℝ) := ae_iff.mpr (by simp)
        filter_upwards [hae] with x hxne
        rcases lt_or_gt_of_ne hxne with hlt | hgt
        · rw [Set.indicator_of_notMem (s := Set.Ioi (1 : ℝ)) (by simp; exact hlt.le)]
          by_cases hx0 : (0 : ℝ) < x
          · have hs0 : (x : ℂ) ^ (-u - 1) • (Real.log x • S_t t x) = 0 := by simp [S_t_of_lt_one t hlt]
            rw [Set.indicator_of_mem (s := Set.Ioi (0 : ℝ)) hx0, hs0]
          · rw [Set.indicator_of_notMem (s := Set.Ioi (0 : ℝ)) (by simpa using hx0)]
        · have hx0 : (0 : ℝ) < x := lt_trans zero_lt_one hgt
          rw [Set.indicator_of_mem (s := Set.Ioi (0 : ℝ)) hx0,
            Set.indicator_of_mem (s := Set.Ioi (1 : ℝ)) hgt,
            smul_eq_mul, Complex.real_smul]
          have hexp : (-u - 1 : ℂ) = -(u + 1) := by ring
          rw [hexp]
          ring
      rw [hmell_eq]
      ring
    rw [hint_eq] at hcomp
    exact ⟨hcomp, hconv, hmc_log⟩
  refine ⟨fun u hu => (hderiv hu).1.differentiableAt.differentiableWithinAt, hderiv⟩

private lemma H_t_continuation_eq (t : ℝ) {K : ℝ} (hK : 0 < K) (a : ℕ) {N₀ : ℕ}
    (hN₀ : 3 ≤ N₀) (hbound : ∀ N ≥ N₀, energyC (wSigmaT (1 / 2) t) 1 N ≤ K * (N : ℝ) * (Real.log N) ^ a)
    {u : ℂ} (hu : 1 / 2 < u.re) (hu1 : u ≠ 1) :
    (u - uZero t) * u * riemannZeta u * H_t t u = regZeta (u + sCrit t) := by
  let U : Set ℂ := {z : ℂ | 1 / 2 < z.re}
  have hU_open : IsOpen U := isOpen_lt continuous_const Complex.continuous_re
  have hU_conv : Convex ℝ U := by
    intro x hx y hy c d hc hd hcd
    simp only [U, Set.mem_ofPred_eq, Complex.add_re, Complex.real_smul, Complex.mul_re,
      Complex.ofReal_re, Complex.ofReal_im, zero_mul, sub_zero] at hx hy ⊢
    rcases eq_or_lt_of_le hc with rfl | hc_pos
    · have hd1 : d = 1 := by linarith
      subst hd1; linarith
    · have h1 : c * (1 / 2) < c * x.re := mul_lt_mul_of_pos_left hx hc_pos
      have h2 : d * (1 / 2) ≤ d * y.re := mul_le_mul_of_nonneg_left hy.le hd
      linarith
  have hU_conn : IsPreconnected U := hU_conv.isPreconnected
  let F₁ : ℂ → ℂ := fun z => (z - uZero t) * z * regZeta z * H_t t z
  let F₂ : ℂ → ℂ := fun z => (z - 1) * regZeta (z + sCrit t)
  have hH_diff := (H_t_analytic_and_hasDerivAt t hK a hN₀ hbound).1
  have hF₁_diff : DifferentiableOn ℂ F₁ U := by
    intro z hz
    have h1 : DifferentiableAt ℂ (fun w => (w - uZero t) * w * regZeta w) z :=
      ((differentiableAt_id.sub_const _).mul differentiableAt_id).mul (differentiable_regZeta z)
    exact (h1.differentiableWithinAt.mul (hH_diff z hz))
  have hF₂_diff : DifferentiableOn ℂ F₂ U := by
    intro z _
    have hcomp : DifferentiableAt ℂ (fun w => regZeta (w + sCrit t)) z :=
      (differentiable_regZeta (z + sCrit t)).comp z (differentiableAt_id.add_const _)
    exact ((differentiableAt_id.sub_const 1).mul hcomp).differentiableWithinAt
  have hF₁_an : AnalyticOnNhd ℂ F₁ U := (analyticOnNhd_iff_differentiableOn hU_open).mpr hF₁_diff
  have hF₂_an : AnalyticOnNhd ℂ F₂ U := (analyticOnNhd_iff_differentiableOn hU_open).mpr hF₂_diff
  have hz₀ : (2 : ℂ) ∈ U := by simp [U]; norm_num
  have hev : F₁ =ᶠ[𝓝 (2 : ℂ)] F₂ := by
    have hV : {z : ℂ | 1 < z.re} ∈ 𝓝 (2 : ℂ) :=
      (isOpen_lt continuous_const Complex.continuous_re).mem_nhds (by simp)
    filter_upwards [hV] with z hz
    have hz_ne1 : z ≠ 1 := fun h => by have := congr_arg Complex.re h; simp at this; linarith
    have hzs_ne1 : z + sCrit t ≠ 1 := fun h => by
      have := congr_arg Complex.re h
      simp [sCrit] at this
      linarith
    have hT1 := mellin_S_eq_zeta_div t hz
    have hz_ne0 : z ≠ 0 := fun h => by have := congr_arg Complex.re h; simp at this; linarith
    have hzeta_ne0 : riemannZeta z ≠ 0 := riemannZeta_ne_zero_of_one_lt_re hz
    simp only [F₁, F₂, regZeta, Function.update_of_ne hz_ne1, Function.update_of_ne hzs_ne1, hT1]
    have hdiff_id : z + sCrit t - 1 = z - uZero t := by
      rw [← uZero_add_sCrit t]; ring
    rw [hdiff_id]
    field_simp [hz_ne0, hzeta_ne0]
  have hEq : F₁ u = F₂ u := hF₁_an.eqOn_of_preconnected_of_eventuallyEq hF₂_an hU_conn hz₀ hev hu
  simp only [F₁, F₂, regZeta, Function.update_of_ne hu1] at hEq
  have hcancel : u - 1 ≠ 0 := sub_ne_zero.mpr hu1
  have hEq' : (u - 1) * ((u - uZero t) * u * riemannZeta u * H_t t u) =
      (u - 1) * Function.update (fun w => (w - 1) * riemannZeta w) 1 1 (u + sCrit t) := by
    calc (u - 1) * ((u - uZero t) * u * riemannZeta u * H_t t u)
        = (u - uZero t) * u * ((u - 1) * riemannZeta u) * H_t t u := by ring
      _ = (u - 1) * Function.update (fun w => (w - 1) * riemannZeta w) 1 1 (u + sCrit t) := hEq
  exact mul_left_cancel₀ hcancel hEq'

/-! ## 6. Upper integral comparison and T3 / T3' lower bounds -/

private lemma integrableOn_S_t_sq_mul_rpow (t : ℝ) {K : ℝ} (hK : 0 < K) (a : ℕ) {N₀ : ℕ}
    (hN₀ : 3 ≤ N₀) (hbound : ∀ N ≥ N₀, energyC (wSigmaT (1 / 2) t) 1 N ≤ K * (N : ℝ) * (Real.log N) ^ a)
    {h : ℝ} (hh : 0 < h) :
    IntegrableOn (fun x : ℝ => ‖S_t t x‖ ^ 2 * x ^ (-2 - h)) (Set.Ioi 1) := by
  let M₀ := ∑ n ∈ Finset.range (N₀ + 1), energyC (wSigmaT (1 / 2) t) 1 n
  have hM₀_nn : 0 ≤ M₀ := Finset.sum_nonneg fun n _ => by
    unfold energyC
    exact Finset.sum_nonneg fun r _ => mul_nonneg (jWeightC_nonneg (wSigmaT_half_norm_le_one t) r) (sq_nonneg _)
  have h1N₀ : (1 : ℝ) ≤ (N₀ : ℝ) := by exact_mod_cast (by omega : 1 ≤ N₀)
  have hsplit : Set.Ioi (1 : ℝ) = Set.Ioc 1 (N₀ : ℝ) ∪ Set.Ioi (N₀ : ℝ) :=
    (Set.Ioc_union_Ioi_eq_Ioi h1N₀).symm
  rw [hsplit]
  refine IntegrableOn.union ?_ ?_
  · have hmeas : AEStronglyMeasurable (fun x : ℝ => ‖S_t t x‖ ^ 2 * x ^ (-2 - h))
        (volume.restrict (Set.Ioc 1 (N₀ : ℝ))) :=
      (((S_t_measurable t).norm.pow_const 2).mul (measurable_id.pow_const (-2 - h))).aestronglyMeasurable
    have hconst : IntegrableOn (fun _ : ℝ => M₀) (Set.Ioc 1 (N₀ : ℝ)) :=
      integrableOn_const measure_Ioc_lt_top.ne
    refine hconst.mono' hmeas ?_
    filter_upwards [ae_restrict_mem measurableSet_Ioc] with x hx
    have hx1 : (1 : ℝ) ≤ x := hx.1.le
    have hxN : x ≤ (N₀ : ℝ) := hx.2
    have hfl_ge1 : 1 ≤ ⌊x⌋₊ := Nat.le_floor (by simpa using hx1)
    have hfl_le : ⌊x⌋₊ ≤ N₀ := (Nat.floor_mono hxN).trans_eq (Nat.floor_natCast N₀)
    have hE_le : E_t t x ≤ M₀ := by
      rw [E_t_of_one_le t hx1]
      exact Finset.single_le_sum (fun n _ => by
        unfold energyC
        exact Finset.sum_nonneg fun r _ => mul_nonneg (jWeightC_nonneg (wSigmaT_half_norm_le_one t) r) (sq_nonneg _))
        (Finset.mem_range.mpr (by omega))
    have hrpow_le : x ^ (-2 - h) ≤ 1 := Real.rpow_le_one_of_one_le_of_nonpos hx1 (by linarith)
    have hS_le : ‖S_t t x‖ ^ 2 ≤ E_t t x := by
      rw [S_t_of_one_le t hx1, E_t_of_one_le t hx1]
      exact scalarSC_norm_sq_le_energyC (wSigmaT_half_norm_le_one t) 1 ⌊x⌋₊ hfl_ge1
    have hnn : 0 ≤ ‖S_t t x‖ ^ 2 * x ^ (-2 - h) :=
      mul_nonneg (sq_nonneg _) (Real.rpow_nonneg (by linarith) _)
    rw [Real.norm_of_nonneg hnn]
    calc ‖S_t t x‖ ^ 2 * x ^ (-2 - h)
        ≤ E_t t x * 1 := mul_le_mul hS_le hrpow_le (Real.rpow_nonneg (by linarith) _) (E_t_nonneg t x)
      _ ≤ M₀ := by linarith
  · have hmaj : IntegrableOn (fun x : ℝ => K * ((Real.log x) ^ a * x ^ (-1 - h))) (Set.Ioi (N₀ : ℝ)) :=
      ((integrableOn_Ioi_log_pow_mul_rpow a hh).mono_set (Set.Ioi_subset_Ioi h1N₀)).const_mul K
    have hmeas : AEStronglyMeasurable (fun x : ℝ => ‖S_t t x‖ ^ 2 * x ^ (-2 - h))
        (volume.restrict (Set.Ioi (N₀ : ℝ))) :=
      (((S_t_measurable t).norm.pow_const 2).mul (measurable_id.pow_const (-2 - h))).aestronglyMeasurable
    refine hmaj.mono' hmeas ?_
    filter_upwards [ae_restrict_mem measurableSet_Ioi] with x hx
    have hxN : (N₀ : ℝ) ≤ x := hx.out.le
    have hx1 : (1 : ℝ) ≤ x := le_trans h1N₀ hxN
    have hx0 : 0 < x := by linarith
    have hfl_ge1 : 1 ≤ ⌊x⌋₊ := Nat.le_floor (by simpa using hx1)
    have hS_le : ‖S_t t x‖ ^ 2 ≤ E_t t x := by
      rw [S_t_of_one_le t hx1, E_t_of_one_le t hx1]
      exact scalarSC_norm_sq_le_energyC (wSigmaT_half_norm_le_one t) 1 ⌊x⌋₊ hfl_ge1
    have hEt := E_t_le_of_eventually_le t hK a hN₀ hbound hxN
    have hnn : 0 ≤ ‖S_t t x‖ ^ 2 * x ^ (-2 - h) :=
      mul_nonneg (sq_nonneg _) (Real.rpow_nonneg hx0.le _)
    rw [Real.norm_of_nonneg hnn]
    have hxp : x * x ^ (-2 - h) = x ^ (-1 - h) := by
      calc x * x ^ (-2 - h) = x ^ (1 : ℝ) * x ^ (-2 - h) := by rw [Real.rpow_one]
        _ = x ^ (1 + (-2 - h)) := (Real.rpow_add hx0 1 (-2 - h)).symm
        _ = x ^ (-1 - h) := by ring_nf
    calc ‖S_t t x‖ ^ 2 * x ^ (-2 - h)
        ≤ (K * x * (Real.log x) ^ a) * x ^ (-2 - h) := by gcongr; exact hS_le.trans hEt
      _ = K * ((Real.log x) ^ a * (x * x ^ (-2 - h))) := by ring
      _ = K * ((Real.log x) ^ a * x ^ (-1 - h)) := by rw [hxp]

private lemma E_t_energy_integral_upper (t : ℝ) {K : ℝ} (hK : 0 < K) (a : ℕ) {N₀ : ℕ}
    (hN₀ : 3 ≤ N₀) (hbound : ∀ N ≥ N₀, energyC (wSigmaT (1 / 2) t) 1 N ≤ K * (N : ℝ) * (Real.log N) ^ a)
    {h : ℝ} (hh : 0 < h) :
    let M₀ := ∑ n ∈ Finset.range (N₀ + 1), energyC (wSigmaT (1 / 2) t) 1 n
    J_h h * (∫ x in Set.Ioi (1 : ℝ), ‖S_t t x‖ ^ 2 * x ^ (-2 - h)) ≤
      M₀ * ((N₀ : ℝ) - 1) + K * (a.factorial : ℝ) / h ^ (a + 1) := by
  intro M₀
  have hM₀_nn : 0 ≤ M₀ := Finset.sum_nonneg fun n _ => by
    unfold energyC
    exact Finset.sum_nonneg fun r _ => mul_nonneg (jWeightC_nonneg (wSigmaT_half_norm_le_one t) r) (sq_nonneg _)
  have hint_S := integrableOn_S_t_sq_mul_rpow t hK a hN₀ hbound hh
  have hS_nn : 0 ≤ᵐ[volume.restrict (Set.Ioi 1)] fun x : ℝ => ‖S_t t x‖ ^ 2 * x ^ (-2 - h) :=
    ae_restrict_of_forall_mem measurableSet_Ioi fun x hx =>
      mul_nonneg (sq_nonneg _) (Real.rpow_nonneg (lt_trans zero_lt_one hx).le _)
  have hofReal_S :
      ENNReal.ofReal (∫ x in Set.Ioi (1 : ℝ), ‖S_t t x‖ ^ 2 * x ^ (-2 - h)) =
        ∫⁻ x in Set.Ioi (1 : ℝ), ENNReal.ofReal (‖S_t t x‖ ^ 2 * x ^ (-2 - h)) :=
    ofReal_integral_eq_lintegral_ofReal hint_S hS_nn
  have hJ_nn : 0 ≤ J_h h := (J_h_pos hh).le
  have hI_nn : 0 ≤ ∫ x in Set.Ioi (1 : ℝ), ‖S_t t x‖ ^ 2 * x ^ (-2 - h) :=
    setIntegral_nonneg measurableSet_Ioi fun x hx =>
      mul_nonneg (sq_nonneg _) (Real.rpow_nonneg (lt_trans zero_lt_one hx).le _)
  have hE_lhs :
      ENNReal.ofReal (J_h h * ∫ x in Set.Ioi (1 : ℝ), ‖S_t t x‖ ^ 2 * x ^ (-2 - h)) =
        ∫⁻ x in Set.Ioi (1 : ℝ), ENNReal.ofReal (E_t t x * x ^ (-2 - h)) := by
    rw [ENNReal.ofReal_mul hJ_nn, hofReal_S, lintegral_E_eq_J_mul_lintegral_S_sq t hh]
  let g₁ : ℝ → ℝ≥0∞ := (Set.Ioc 1 (N₀ : ℝ)).indicator (fun _ => ENNReal.ofReal M₀)
  let g₂ : ℝ → ℝ≥0∞ := fun x => ENNReal.ofReal (K * ((Real.log x) ^ a * x ^ (-1 - h)))
  have hg₁_meas : Measurable g₁ := measurable_const.indicator measurableSet_Ioc
  have hg₂_meas : Measurable g₂ := Measurable.ennreal_ofReal
    (measurable_const.mul ((Real.measurable_log.pow_const a).mul (measurable_id.pow_const (-1 - h))))
  have hpoint : ∀ x ∈ Set.Ioi (1 : ℝ),
      ENNReal.ofReal (E_t t x * x ^ (-2 - h)) ≤ g₁ x + g₂ x := by
    intro x hx
    have hx1 : (1 : ℝ) ≤ x := hx.out.le
    have hx0 : 0 < x := lt_trans zero_lt_one hx
    by_cases hxN : x ≤ (N₀ : ℝ)
    · have hxmem : x ∈ Set.Ioc (1 : ℝ) (N₀ : ℝ) := ⟨hx, hxN⟩
      have hfl_ge1 : 1 ≤ ⌊x⌋₊ := Nat.le_floor (by simpa using hx1)
      have hfl_le : ⌊x⌋₊ ≤ N₀ := (Nat.floor_mono hxN).trans_eq (Nat.floor_natCast N₀)
      have hE_le : E_t t x ≤ M₀ := by
        rw [E_t_of_one_le t hx1]
        exact Finset.single_le_sum (fun n _ => by
          unfold energyC
          exact Finset.sum_nonneg fun r _ => mul_nonneg (jWeightC_nonneg (wSigmaT_half_norm_le_one t) r) (sq_nonneg _))
          (Finset.mem_range.mpr (by omega))
      have hrpow_le : x ^ (-2 - h) ≤ 1 := Real.rpow_le_one_of_one_le_of_nonpos hx1 (by linarith)
      have hprod : E_t t x * x ^ (-2 - h) ≤ M₀ := by
        calc E_t t x * x ^ (-2 - h)
            ≤ E_t t x * 1 := mul_le_mul_of_nonneg_left hrpow_le (E_t_nonneg t x)
          _ ≤ M₀ := by linarith
      calc ENNReal.ofReal (E_t t x * x ^ (-2 - h))
          ≤ ENNReal.ofReal M₀ := ENNReal.ofReal_le_ofReal hprod
        _ = g₁ x := by simp [g₁, Set.indicator_of_mem hxmem]
        _ ≤ g₁ x + g₂ x := le_self_add
    · have hEt := E_t_le_of_eventually_le t hK a hN₀ hbound (not_le.mp hxN).le
      have hprod : E_t t x * x ^ (-2 - h) ≤ K * ((Real.log x) ^ a * x ^ (-1 - h)) := by
        have hxp : x * x ^ (-2 - h) = x ^ (-1 - h) := by
          calc x * x ^ (-2 - h) = x ^ (1 : ℝ) * x ^ (-2 - h) := by rw [Real.rpow_one]
            _ = x ^ (1 + (-2 - h)) := (Real.rpow_add hx0 1 (-2 - h)).symm
            _ = x ^ (-1 - h) := by ring_nf
        calc E_t t x * x ^ (-2 - h)
            ≤ (K * x * (Real.log x) ^ a) * x ^ (-2 - h) := by gcongr
          _ = K * ((Real.log x) ^ a * (x * x ^ (-2 - h))) := by ring
          _ = K * ((Real.log x) ^ a * x ^ (-1 - h)) := by rw [hxp]
      calc ENNReal.ofReal (E_t t x * x ^ (-2 - h))
          ≤ g₂ x := ENNReal.ofReal_le_ofReal hprod
        _ ≤ g₁ x + g₂ x := le_add_self
  have hlint_le :
      (∫⁻ x in Set.Ioi (1 : ℝ), ENNReal.ofReal (E_t t x * x ^ (-2 - h))) ≤
        (∫⁻ x in Set.Ioi (1 : ℝ), g₁ x) + ∫⁻ x in Set.Ioi (1 : ℝ), g₂ x := by
    calc (∫⁻ x in Set.Ioi (1 : ℝ), ENNReal.ofReal (E_t t x * x ^ (-2 - h)))
        ≤ ∫⁻ x in Set.Ioi (1 : ℝ), (g₁ x + g₂ x) :=
          setLIntegral_mono (hg₁_meas.add hg₂_meas) hpoint
      _ = (∫⁻ x in Set.Ioi (1 : ℝ), g₁ x) + ∫⁻ x in Set.Ioi (1 : ℝ), g₂ x :=
          lintegral_add_right _ hg₂_meas
  have h1N₀ : (1 : ℝ) ≤ (N₀ : ℝ) := by exact_mod_cast (by omega : 1 ≤ N₀)
  have hg₁_val : (∫⁻ x in Set.Ioi (1 : ℝ), g₁ x) = ENNReal.ofReal (M₀ * ((N₀ : ℝ) - 1)) := by
    calc (∫⁻ x in Set.Ioi (1 : ℝ), g₁ x)
        = ∫⁻ x, (Set.Ioi (1 : ℝ)).indicator g₁ x := by rw [← lintegral_indicator measurableSet_Ioi]
      _ = ∫⁻ x, (Set.Ioc 1 (N₀ : ℝ)).indicator (fun _ => ENNReal.ofReal M₀) x := by
          congr 1; ext x
          by_cases hx : x ∈ Set.Ioc 1 (N₀ : ℝ)
          · simp [g₁, hx, hx.1]
          · simp [g₁, hx]
      _ = ∫⁻ _x in Set.Ioc 1 (N₀ : ℝ), ENNReal.ofReal M₀ := by rw [← lintegral_indicator measurableSet_Ioc]
      _ = ENNReal.ofReal M₀ * volume (Set.Ioc 1 (N₀ : ℝ)) := setLIntegral_const _ _
      _ = ENNReal.ofReal M₀ * ENNReal.ofReal ((N₀ : ℝ) - 1) := by rw [Real.volume_Ioc]
      _ = ENNReal.ofReal (M₀ * ((N₀ : ℝ) - 1)) := (ENNReal.ofReal_mul hM₀_nn).symm
  have hg₂_int : IntegrableOn (fun x : ℝ => K * ((Real.log x) ^ a * x ^ (-1 - h))) (Set.Ioi 1) :=
    (integrableOn_Ioi_log_pow_mul_rpow a hh).const_mul K
  have hg₂_nn : 0 ≤ᵐ[volume.restrict (Set.Ioi 1)] fun x : ℝ => K * ((Real.log x) ^ a * x ^ (-1 - h)) :=
    ae_restrict_of_forall_mem measurableSet_Ioi fun x hx =>
      mul_nonneg hK.le (mul_nonneg (pow_nonneg (Real.log_nonneg hx.out.le) a)
        (Real.rpow_nonneg (lt_trans zero_lt_one hx).le _))
  have hg₂_val : (∫⁻ x in Set.Ioi (1 : ℝ), g₂ x) = ENNReal.ofReal (K * (a.factorial : ℝ) / h ^ (a + 1)) := by
    rw [← ofReal_integral_eq_lintegral_ofReal hg₂_int hg₂_nn,
      integral_const_mul, integral_Ioi_log_pow_mul_rpow a hh]
    congr 1; ring
  have hsum_ofReal :
      ENNReal.ofReal (J_h h * ∫ x in Set.Ioi (1 : ℝ), ‖S_t t x‖ ^ 2 * x ^ (-2 - h)) ≤
        ENNReal.ofReal (M₀ * ((N₀ : ℝ) - 1) + K * (a.factorial : ℝ) / h ^ (a + 1)) := by
    rw [hE_lhs]
    refine hlint_le.trans ?_
    rw [hg₁_val, hg₂_val, ← ENNReal.ofReal_add (mul_nonneg hM₀_nn (by linarith)) (by positivity)]
  exact (ENNReal.ofReal_le_ofReal_iff (add_nonneg (mul_nonneg hM₀_nn (by linarith)) (by positivity))).mp
    hsum_ofReal

private lemma integrableOn_S_t_mul_log_pow (t : ℝ) {K : ℝ} (hK : 0 < K) (a k : ℕ) {N₀ : ℕ}
    (hN₀ : 3 ≤ N₀) (hbound : ∀ N ≥ N₀, energyC (wSigmaT (1 / 2) t) 1 N ≤ K * (N : ℝ) * (Real.log N) ^ a)
    {h : ℝ} (hh : 0 < h) :
    IntegrableOn (fun x : ℝ =>
      (‖S_t t x‖ * x ^ (-(2 + h) / 2)) * ((Real.log x) ^ k * x ^ (-(1 + h) / 2))) (Set.Ioi 1) := by
  have hint_sq := integrableOn_S_t_sq_mul_rpow t hK a hN₀ hbound hh
  have hint_log := integrableOn_Ioi_log_pow_mul_rpow (2 * k) hh
  let b : ℝ → ℝ := fun x => (Real.log x) ^ k * x ^ (-(1 + h) / 2)
  have hmeas : AEStronglyMeasurable (fun x : ℝ =>
      (‖S_t t x‖ * x ^ (-(2 + h) / 2)) * b x) (volume.restrict (Set.Ioi 1)) :=
    (((S_t_measurable t).norm.mul (measurable_id.pow_const (-(2 + h) / 2))).mul
      ((Real.measurable_log.pow_const k).mul (measurable_id.pow_const (-(1 + h) / 2)))).aestronglyMeasurable
  refine (hint_sq.add hint_log).mono' hmeas ?_
  filter_upwards [ae_restrict_mem measurableSet_Ioi] with x hx
  have hx1 : (1 : ℝ) ≤ x := hx.out.le
  have hx0 : 0 < x := lt_trans zero_lt_one hx
  let A := ‖S_t t x‖ * x ^ (-(2 + h) / 2)
  let B := b x
  have hA0 : 0 ≤ A := mul_nonneg (norm_nonneg _) (Real.rpow_nonneg hx0.le _)
  have hB0 : 0 ≤ B := mul_nonneg (pow_nonneg (Real.log_nonneg hx1) k) (Real.rpow_nonneg hx0.le _)
  have hAsq : A ^ 2 = ‖S_t t x‖ ^ 2 * x ^ (-2 - h) := by
    dsimp [A]
    rw [mul_pow, ← Real.rpow_natCast (x ^ _), ← Real.rpow_mul hx0.le]
    congr 2; ring
  have hBsq : B ^ 2 = (Real.log x) ^ (2 * k) * x ^ (-1 - h) := by
    dsimp [B, b]
    rw [mul_pow, ← pow_mul, mul_comm k 2, ← Real.rpow_natCast (x ^ _), ← Real.rpow_mul hx0.le]
    congr 2; ring
  have hAB : A * B ≤ A ^ 2 + B ^ 2 := by nlinarith [sq_nonneg (A - B)]
  rw [Real.norm_of_nonneg (mul_nonneg hA0 hB0)]
  calc A * B ≤ A ^ 2 + B ^ 2 := hAB
    _ = ((fun x => ‖S_t t x‖ ^ 2 * x ^ (-2 - h)) + fun x => (Real.log x) ^ (2 * k) * x ^ (-1 - h)) x := by
        dsimp only [Pi.add_apply]
        rw [hAsq, hBsq]

/-- Subsequential threshold version of T3 (simple zero `m = 1`): any eventual bound
`E_t(N) ≤ K * N * (log N)^3` satisfies `K ≥ 2 / (π^2 * ‖uZero t * ζ'(uZero t)‖^2)`. -/
theorem simple_zero_energy_eventually_le_lower (t : ℝ)
    (hz : riemannZeta (uZero t) = 0) (hdz : deriv riemannZeta (uZero t) ≠ 0)
    {K : ℝ} (hK : 0 < K)
    (hev : ∀ᶠ N : ℕ in atTop, energyC (wSigmaT (1 / 2) t) 1 N ≤ K * (N : ℝ) * (Real.log N) ^ 3) :
    2 / (Real.pi ^ 2 * ‖uZero t * deriv riemannZeta (uZero t)‖ ^ 2) ≤ K := by
  rw [eventually_atTop] at hev
  obtain ⟨N₁, hN₁⟩ := hev
  let N₀ := max N₁ 3
  have hN₀ : 3 ≤ N₀ := le_max_right N₁ 3
  have hbound : ∀ N ≥ N₀, energyC (wSigmaT (1 / 2) t) 1 N ≤ K * (N : ℝ) * (Real.log N) ^ 3 :=
    fun N hN => hN₁ N ((le_max_left N₁ 3).trans hN)
  let Dz : ℂ → ℂ := dslope riemannZeta (uZero t)
  have hDz0 : Dz (uZero t) = deriv riemannZeta (uZero t) := dslope_same riemannZeta (uZero t)
  have hDz_ne : Dz (uZero t) ≠ 0 := hDz0.symm ▸ hdz
  have hV_mem : {z : ℂ | z ≠ 1} ∈ 𝓝 (uZero t) := isOpen_ne.mem_nhds (uZero_ne_one t)
  have hzeta_diff : DifferentiableOn ℂ riemannZeta {z : ℂ | z ≠ 1} :=
    fun z hz' => (differentiableAt_riemannZeta hz').differentiableWithinAt
  have hDz_diff : DifferentiableOn ℂ Dz {z : ℂ | z ≠ 1} :=
    (Complex.differentiableOn_dslope hV_mem).mpr hzeta_diff
  have hDz_cont : ContinuousAt Dz (uZero t) := (hDz_diff.differentiableAt hV_mem).continuousAt
  have hgood_nhds : {z : ℂ | z ≠ 0 ∧ z ≠ 1 ∧ Dz z ≠ 0} ∈ 𝓝 (uZero t) := by
    have h0 : {z : ℂ | z ≠ 0} ∈ 𝓝 (uZero t) := isOpen_ne.mem_nhds (uZero_ne_zero t)
    have hD : {z : ℂ | Dz z ≠ 0} ∈ 𝓝 (uZero t) := hDz_cont.preimage_mem_nhds (isOpen_ne.mem_nhds hDz_ne)
    exact Filter.inter_mem h0 (Filter.inter_mem hV_mem hD)
  obtain ⟨δ₀, hδ₀_pos, hδ₀_sub⟩ := Metric.mem_nhds_iff.mp hgood_nhds
  let rad : ℝ := min δ₀ (1 / 2)
  have hrad_pos : 0 < rad := lt_min hδ₀_pos (by norm_num : (0 : ℝ) < 1 / 2)
  let G₁ : ℂ → ℂ := fun z => regZeta (z + sCrit t) / (z * Dz z)
  have hG₁_diff : DifferentiableOn ℂ G₁ (Metric.ball (uZero t) rad) := by
    intro z hz_ball
    have hzb : z ∈ Metric.ball (uZero t) δ₀ := Metric.ball_subset_ball (min_le_left _ _) hz_ball
    have hzgood := hδ₀_sub hzb
    have hnum : DifferentiableAt ℂ (fun w => regZeta (w + sCrit t)) z :=
      (differentiable_regZeta (z + sCrit t)).comp z (differentiableAt_id.add_const _)
    have hDz_at : DifferentiableAt ℂ Dz z :=
      hDz_diff.differentiableAt (isOpen_ne.mem_nhds hzgood.2.1)
    have hden : DifferentiableAt ℂ (fun w => w * Dz w) z := differentiableAt_id.mul hDz_at
    exact (hnum.div hden (mul_ne_zero hzgood.1 hzgood.2.2)).differentiableWithinAt
  have hG₁_deriv_diff : DifferentiableOn ℂ (deriv G₁) (Metric.ball (uZero t) rad) :=
    hG₁_diff.deriv Metric.isOpen_ball
  have hG₁_cont : ContinuousAt G₁ (uZero t) :=
    (hG₁_diff.differentiableAt (Metric.ball_mem_nhds (uZero t) hrad_pos)).continuousAt
  have hG₁_deriv_cont : ContinuousAt (deriv G₁) (uZero t) :=
    (hG₁_deriv_diff.differentiableAt (Metric.ball_mem_nhds (uZero t) hrad_pos)).continuousAt
  have hG₁_val : G₁ (uZero t) = 1 / (uZero t * deriv riemannZeta (uZero t)) := by
    simp only [G₁, uZero_add_sCrit, regZeta, Function.update_self, hDz0]
  have hH_formula : ∀ {h : ℝ}, 0 < h → h < rad →
      (h : ℂ) ^ 3 * deriv (H_t t) (uZero t + (h : ℂ)) =
        -2 * G₁ (uZero t + (h : ℂ)) + (h : ℂ) * deriv G₁ (uZero t + (h : ℂ)) := by
    intro h hh hhd
    let u : ℂ := uZero t + (h : ℂ)
    have hu_ball : u ∈ Metric.ball (uZero t) rad := by
      simpa [u, Metric.mem_ball, dist_eq_norm, Complex.norm_real, Real.norm_of_nonneg hh.le] using hhd
    have hHeq : (fun z => H_t t z) =ᶠ[𝓝 u] fun z => ((z - uZero t) ^ 2)⁻¹ * G₁ z := by
      let r := min (h / 2) (rad - h)
      have hr : 0 < r := lt_min (by linarith) (by linarith)
      filter_upwards [Metric.ball_mem_nhds u hr] with z hz_ball
      have hz_dist_u : ‖z - u‖ < r := by simpa [Metric.mem_ball, dist_eq_norm] using hz_ball
      have hz_re : 1 / 2 < z.re := by
        have hre_diff : |z.re - u.re| ≤ ‖z - u‖ := by
          simpa [Complex.sub_re] using Complex.abs_re_le_norm (z - u)
        have hlt_r : |z.re - u.re| < h / 2 :=
          hre_diff.trans_lt (hz_dist_u.trans_le (min_le_left _ _))
        have : u.re - h / 2 < z.re := by linarith [(abs_lt.mp hlt_r).1]
        simp [u] at this ⊢; linarith
      have hz_dist_u0 : z ∈ Metric.ball (uZero t) rad := by
        rw [Metric.mem_ball, dist_eq_norm]
        calc ‖z - uZero t‖ = ‖(z - u) + (h : ℂ)‖ := by congr 1; simp [u]; ring
          _ ≤ ‖z - u‖ + ‖(h : ℂ)‖ := norm_add_le _ _
          _ < (rad - h) + h := by
              have hlt1 : ‖z - u‖ < rad - h := hz_dist_u.trans_le (min_le_right _ _)
              have hn : ‖(h : ℂ)‖ = h := by simp [Complex.norm_real, Real.norm_of_nonneg hh.le]
              linarith
          _ = rad := by ring
      have hzgood := hδ₀_sub (Metric.ball_subset_ball (min_le_left _ _) hz_dist_u0)
      have hz_ne_u0 : z ≠ uZero t := fun heq => by
        rw [heq] at hz_re
        simp at hz_re
      have hcont := H_t_continuation_eq t hK 3 hN₀ hbound hz_re hzgood.2.1
      have hsub : riemannZeta z = (z - uZero t) * Dz z := by
        simpa [Dz, smul_eq_mul] using (sub_smul_dslope_of_zero hz z).symm
      rw [hsub] at hcont
      have hz_sub_ne : z - uZero t ≠ 0 := sub_ne_zero.mpr hz_ne_u0
      have hcalc : (z - uZero t) ^ 2 * (z * Dz z) * H_t t z = regZeta (z + sCrit t) := by
        calc (z - uZero t) ^ 2 * (z * Dz z) * H_t t z
            = (z - uZero t) * z * ((z - uZero t) * Dz z) * H_t t z := by ring
          _ = regZeta (z + sCrit t) := hcont
      have hden_ne : (z - uZero t) ^ 2 * (z * Dz z) ≠ 0 :=
        mul_ne_zero (pow_ne_zero 2 hz_sub_ne) (mul_ne_zero hzgood.1 hzgood.2.2)
      calc H_t t z
          = regZeta (z + sCrit t) / ((z - uZero t) ^ 2 * (z * Dz z)) :=
            eq_div_of_mul_eq hden_ne (by rw [mul_comm (H_t t z)]; exact hcalc)
        _ = ((z - uZero t) ^ 2)⁻¹ * G₁ z := by simp only [G₁]; field_simp [hz_sub_ne, hzgood.1, hzgood.2.2]
    have hinv_deriv : HasDerivAt (fun z => ((z - uZero t) ^ 2)⁻¹)
        (-2 * (u - uZero t) / ((u - uZero t) ^ 2) ^ 2) u := by
      have hsub : HasDerivAt (fun z => (z - uZero t) ^ 2) (2 * (u - uZero t) ^ (2 - 1) * 1) u :=
        ((hasDerivAt_id' u).sub_const (uZero t)).pow 2
      have hu_sub_ne : u - uZero t ≠ 0 := by simp [u, hh.ne']
      convert hsub.inv (pow_ne_zero 2 hu_sub_ne) using 1
      ring
    have hG₁_at : HasDerivAt G₁ (deriv G₁ u) u :=
      (hG₁_diff.differentiableAt (Metric.isOpen_ball.mem_nhds hu_ball)).hasDerivAt
    have hprod_deriv := hinv_deriv.mul hG₁_at
    have hderiv_eq : deriv (H_t t) u =
        (-2 * (u - uZero t) / ((u - uZero t) ^ 2) ^ 2) * G₁ u + ((u - uZero t) ^ 2)⁻¹ * deriv G₁ u :=
      (hprod_deriv.congr_of_eventuallyEq hHeq).deriv
    have hhc : (h : ℂ) ≠ 0 := Complex.ofReal_ne_zero.mpr hh.ne'
    have husub : u - uZero t = (h : ℂ) := by simp [u]
    rw [hderiv_eq, husub]
    field_simp [hhc]
    ring
  have hLHS_lim :
      Tendsto (fun h : ℝ => ‖(h : ℂ) ^ 3 * deriv (H_t t) (uZero t + (h : ℂ))‖ ^ 2 * (h * J_h h))
        (𝓝[>] (0 : ℝ))
        (𝓝 (4 / ‖uZero t * deriv riemannZeta (uZero t)‖ ^ 2 * (6 / Real.pi ^ 2))) := by
    have hu_tend : Tendsto (fun h : ℝ => uZero t + (h : ℂ)) (𝓝[>] (0 : ℝ)) (𝓝 (uZero t)) := by
      have hcont : Continuous (fun h : ℝ => uZero t + (h : ℂ)) :=
        continuous_const.add Complex.continuous_ofReal
      simpa using (hcont.tendsto (0 : ℝ)).mono_left nhdsWithin_le_nhds
    have hG_tend := hG₁_cont.tendsto.comp hu_tend
    have hGd_tend := hG₁_deriv_cont.tendsto.comp hu_tend
    have h_expr_tend :
        Tendsto (fun h : ℝ => -2 * G₁ (uZero t + (h : ℂ)) + (h : ℂ) * deriv G₁ (uZero t + (h : ℂ)))
          (𝓝[>] (0 : ℝ)) (𝓝 (-2 * G₁ (uZero t) + 0 * deriv G₁ (uZero t))) := by
      refine (tendsto_const_nhds.mul hG_tend).add ?_
      exact ((Complex.continuous_ofReal.continuousAt.tendsto.mono_left nhdsWithin_le_nhds).mul hGd_tend)
    have h_lim_eq : (-2 * G₁ (uZero t) + 0 * deriv G₁ (uZero t)) =
        -2 / (uZero t * deriv riemannZeta (uZero t)) := by
      rw [zero_mul, add_zero, hG₁_val]; ring
    rw [h_lim_eq] at h_expr_tend
    have h_norm_sq :
        Tendsto (fun h : ℝ => ‖(h : ℂ) ^ 3 * deriv (H_t t) (uZero t + (h : ℂ))‖ ^ 2)
          (𝓝[>] (0 : ℝ)) (𝓝 (‖-2 / (uZero t * deriv riemannZeta (uZero t))‖ ^ 2)) := by
      have hnorm := ((continuous_norm.pow 2).tendsto _).comp h_expr_tend
      refine hnorm.congr' ?_
      filter_upwards [eventually_nhdsWithin_of_eventually_nhds (Iio_mem_nhds hrad_pos),
        self_mem_nhdsWithin] with h hh_lt hh_gt
      simp only [Function.comp_apply, Pi.pow_apply, hH_formula hh_gt hh_lt]
    have hnorm_val : ‖-2 / (uZero t * deriv riemannZeta (uZero t))‖ ^ 2 =
        4 / ‖uZero t * deriv riemannZeta (uZero t)‖ ^ 2 := by
      rw [norm_div, div_pow]
      have h2 : ‖(-2 : ℂ)‖ = 2 := by simp
      rw [h2]; norm_num
    rw [hnorm_val] at h_norm_sq
    exact h_norm_sq.mul tendsto_mul_J_h
  let M₀ := ∑ n ∈ Finset.range (N₀ + 1), energyC (wSigmaT (1 / 2) t) 1 n
  have h_ineq : ∀ᶠ h : ℝ in 𝓝[>] (0 : ℝ),
      ‖(h : ℂ) ^ 3 * deriv (H_t t) (uZero t + (h : ℂ))‖ ^ 2 * (h * J_h h) ≤
        2 * (h ^ 4 * (M₀ * ((N₀ : ℝ) - 1)) + 6 * K) := by
    filter_upwards [eventually_nhdsWithin_of_eventually_nhds (Iio_mem_nhds hrad_pos),
      self_mem_nhdsWithin] with h hh_lt hh_gt
    have hh : 0 < h := hh_gt
    let u : ℂ := uZero t + (h : ℂ)
    have hu : 1 / 2 < u.re := by simp [u]; linarith
    obtain ⟨hderiv_H, _, hmc_log⟩ := (H_t_analytic_and_hasDerivAt t hK 3 hN₀ hbound).2 hu
    have hderiv_val : deriv (H_t t) u =
        - ∫ x in Set.Ioi (1 : ℝ), (Real.log x : ℂ) * S_t t x * (x : ℂ) ^ (-(u + 1)) :=
      hderiv_H.deriv
    have hnorm_deriv :
        ‖deriv (H_t t) u‖ ≤ ∫ x in Set.Ioi (1 : ℝ),
          (‖S_t t x‖ * x ^ (-(2 + h) / 2)) * (Real.log x * x ^ (-(1 + h) / 2)) := by
      rw [hderiv_val, norm_neg]
      calc ‖∫ x in Set.Ioi (1 : ℝ), (Real.log x : ℂ) * S_t t x * (x : ℂ) ^ (-(u + 1))‖
          ≤ ∫ x in Set.Ioi (1 : ℝ), ‖(Real.log x : ℂ) * S_t t x * (x : ℂ) ^ (-(u + 1))‖ :=
            norm_integral_le_integral_norm _
        _ = ∫ x in Set.Ioi (1 : ℝ),
              (‖S_t t x‖ * x ^ (-(2 + h) / 2)) * (Real.log x * x ^ (-(1 + h) / 2)) := by
            refine setIntegral_congr_fun measurableSet_Ioi fun x hx => ?_
            have hx1 : (1 : ℝ) ≤ x := hx.out.le
            have hx0 : 0 < x := lt_trans zero_lt_one hx
            have hpow_re : (-(u + 1)).re = -(3 / 2 + h) := by simp [u]; ring
            have hpow_norm : ‖(x : ℂ) ^ (-(u + 1))‖ = x ^ (-(3 / 2 + h)) := by
              rw [Complex.norm_cpow_eq_rpow_re_of_pos hx0, hpow_re]
            have hlog_nn : 0 ≤ Real.log x := Real.log_nonneg hx1
            rw [norm_mul, norm_mul, hpow_norm, Complex.norm_real, Real.norm_of_nonneg hlog_nn]
            have hsplit : x ^ (-(3 / 2 + h)) = x ^ (-(2 + h) / 2) * x ^ (-(1 + h) / 2) := by
              rw [← Real.rpow_add hx0]
              congr 1; ring
            rw [hsplit]; ring
    have hCS :
        (∫ x in Set.Ioi (1 : ℝ),
            (‖S_t t x‖ * x ^ (-(2 + h) / 2)) * (Real.log x * x ^ (-(1 + h) / 2))) ^ 2 ≤
          (∫ x in Set.Ioi (1 : ℝ), ‖S_t t x‖ ^ 2 * x ^ (-2 - h)) * (2 / h ^ 3) := by
      have ha_sq : IntegrableOn (fun x : ℝ => (‖S_t t x‖ * x ^ (-(2 + h) / 2)) ^ 2) (Set.Ioi 1) := by
        refine (integrableOn_S_t_sq_mul_rpow t hK 3 hN₀ hbound hh).congr_fun (fun x hx => ?_) measurableSet_Ioi
        have hx0 : 0 < x := lt_trans zero_lt_one hx
        rw [mul_pow, ← Real.rpow_natCast (x ^ _), ← Real.rpow_mul hx0.le,
          show (-(2 + h) / 2 * (2 : ℕ) : ℝ) = -2 - h by push_cast; ring]
      have hb_sq : IntegrableOn (fun x : ℝ => (Real.log x * x ^ (-(1 + h) / 2)) ^ 2) (Set.Ioi 1) := by
        refine (integrableOn_Ioi_log_pow_mul_rpow 2 hh).congr_fun (fun x hx => ?_) measurableSet_Ioi
        have hx0 : 0 < x := lt_trans zero_lt_one hx
        rw [mul_pow, ← Real.rpow_natCast (x ^ _), ← Real.rpow_mul hx0.le,
          show (-(1 + h) / 2 * (2 : ℕ) : ℝ) = -1 - h by push_cast; ring]
      have hab : IntegrableOn (fun x : ℝ =>
          (‖S_t t x‖ * x ^ (-(2 + h) / 2)) * (Real.log x * x ^ (-(1 + h) / 2))) (Set.Ioi 1) := by
        simpa only [pow_one] using integrableOn_S_t_mul_log_pow t hK 3 1 hN₀ hbound hh
      have hsq_le := sq_integral_mul_le_mul_integral_sq
        (fun x hx => mul_nonneg (Real.log_nonneg hx.out.le) (Real.rpow_nonneg (lt_trans zero_lt_one hx).le _))
        ha_sq hb_sq hab
      have hA_eq : (∫ x in Set.Ioi (1 : ℝ), (‖S_t t x‖ * x ^ (-(2 + h) / 2)) ^ 2) =
          ∫ x in Set.Ioi (1 : ℝ), ‖S_t t x‖ ^ 2 * x ^ (-2 - h) := by
        refine setIntegral_congr_fun measurableSet_Ioi fun x hx => ?_
        have hx0 : 0 < x := lt_trans zero_lt_one hx
        rw [mul_pow, ← Real.rpow_natCast (x ^ _), ← Real.rpow_mul hx0.le,
          show (-(2 + h) / 2 * (2 : ℕ) : ℝ) = -2 - h by push_cast; ring]
      have hB_eq : (∫ x in Set.Ioi (1 : ℝ), (Real.log x * x ^ (-(1 + h) / 2)) ^ 2) = 2 / h ^ 3 := by
        have hid : (∫ x in Set.Ioi (1 : ℝ), (Real.log x * x ^ (-(1 + h) / 2)) ^ 2) =
            ∫ x in Set.Ioi (1 : ℝ), (Real.log x) ^ 2 * x ^ (-1 - h) := by
          refine setIntegral_congr_fun measurableSet_Ioi fun x hx => ?_
          have hx0 : 0 < x := lt_trans zero_lt_one hx
          rw [mul_pow, ← Real.rpow_natCast (x ^ _), ← Real.rpow_mul hx0.le,
            show (-(1 + h) / 2 * (2 : ℕ) : ℝ) = -1 - h by push_cast; ring]
        rw [hid, integral_Ioi_log_pow_mul_rpow 2 hh]
        norm_num
      rwa [hA_eq, hB_eq] at hsq_le
    have hderiv_sq : ‖deriv (H_t t) u‖ ^ 2 ≤
        (∫ x in Set.Ioi (1 : ℝ), ‖S_t t x‖ ^ 2 * x ^ (-2 - h)) * (2 / h ^ 3) :=
      (pow_le_pow_left₀ (norm_nonneg _) hnorm_deriv 2).trans hCS
    have hup := E_t_energy_integral_upper t hK 3 hN₀ hbound hh
    have hfac : ((3 : ℕ).factorial : ℝ) = 6 := by norm_num
    rw [hfac] at hup
    have hnorm_h3 : ‖(h : ℂ) ^ 3 * deriv (H_t t) u‖ ^ 2 = h ^ 6 * ‖deriv (H_t t) u‖ ^ 2 := by
      rw [norm_mul, norm_pow, Complex.norm_real, Real.norm_of_nonneg hh.le, mul_pow]
      ring
    rw [hnorm_h3]
    have hJ0 : 0 ≤ J_h h := (J_h_pos hh).le
    calc h ^ 6 * ‖deriv (H_t t) u‖ ^ 2 * (h * J_h h)
        = (h ^ 7 * J_h h) * ‖deriv (H_t t) u‖ ^ 2 := by ring
      _ ≤ (h ^ 7 * J_h h) * ((∫ x in Set.Ioi (1 : ℝ), ‖S_t t x‖ ^ 2 * x ^ (-2 - h)) * (2 / h ^ 3)) :=
          mul_le_mul_of_nonneg_left hderiv_sq (by positivity)
      _ = 2 * (h ^ 4 * (J_h h * ∫ x in Set.Ioi (1 : ℝ), ‖S_t t x‖ ^ 2 * x ^ (-2 - h))) := by
          have hh3 : h ^ 3 ≠ 0 := pow_ne_zero 3 hh.ne'
          calc (h ^ 7 * J_h h) * ((∫ x in Set.Ioi (1 : ℝ), ‖S_t t x‖ ^ 2 * x ^ (-2 - h)) * (2 / h ^ 3))
              = 2 * (h ^ 4 * (J_h h * ∫ x in Set.Ioi (1 : ℝ), ‖S_t t x‖ ^ 2 * x ^ (-2 - h))) * (h ^ 3 / h ^ 3) := by
                  ring
            _ = 2 * (h ^ 4 * (J_h h * ∫ x in Set.Ioi (1 : ℝ), ‖S_t t x‖ ^ 2 * x ^ (-2 - h))) := by
                  rw [div_self hh3, mul_one]
      _ ≤ 2 * (h ^ 4 * (M₀ * ((N₀ : ℝ) - 1) + K * 6 / h ^ 4)) := by
          gcongr
      _ = 2 * (h ^ 4 * (M₀ * ((N₀ : ℝ) - 1)) + 6 * K) := by
          have hh4 : h ^ 4 ≠ 0 := pow_ne_zero 4 hh.ne'
          rw [mul_add, mul_div_assoc', mul_div_cancel_left₀ _ hh4, mul_comm K 6]
  have hRHS_lim :
      Tendsto (fun h : ℝ => 2 * (h ^ 4 * (M₀ * ((N₀ : ℝ) - 1)) + 6 * K))
        (𝓝[>] (0 : ℝ)) (𝓝 (2 * (0 ^ 4 * (M₀ * ((N₀ : ℝ) - 1)) + 6 * K))) := by
    have hcont : Continuous (fun h : ℝ => 2 * (h ^ 4 * (M₀ * ((N₀ : ℝ) - 1)) + 6 * K)) := by
      fun_prop
    exact hcont.continuousAt.tendsto.mono_left nhdsWithin_le_nhds
  have hfinal := le_of_tendsto_of_tendsto hLHS_lim hRHS_lim h_ineq
  simp only [zero_pow (by norm_num : 4 ≠ 0), zero_mul, zero_add] at hfinal
  have hden : 0 < Real.pi ^ 2 * ‖uZero t * deriv riemannZeta (uZero t)‖ ^ 2 :=
    mul_pos (pow_pos Real.pi_pos 2) (pow_pos (norm_pos_iff.mpr (mul_ne_zero (uZero_ne_zero t) hdz)) 2)
  rw [div_mul_div_comm, mul_comm (‖uZero t * deriv riemannZeta (uZero t)‖ ^ 2) (Real.pi ^ 2),
    div_le_iff₀ hden] at hfinal
  rw [div_le_iff₀ hden]
  nlinarith

/-- **T3 (Unconditional simple-zero `limsup` lower bound for rotated energy `E_t`).** -/
theorem simple_zero_energy_limsup_ge (t : ℝ)
    (hz : riemannZeta (uZero t) = 0) (hdz : deriv riemannZeta (uZero t) ≠ 0) :
    ENNReal.ofReal (2 / (Real.pi ^ 2 * ‖uZero t * deriv riemannZeta (uZero t)‖ ^ 2)) ≤
      Filter.limsup
        (fun N : ℕ => ENNReal.ofReal (energyC (wSigmaT (1 / 2) t) 1 N / ((N : ℝ) * (Real.log N) ^ 3)))
        atTop := by
  let c₀ : ℝ := 2 / (Real.pi ^ 2 * ‖uZero t * deriv riemannZeta (uZero t)‖ ^ 2)
  have hc₀_pos : 0 < c₀ := by
    have hden : 0 < Real.pi ^ 2 * ‖uZero t * deriv riemannZeta (uZero t)‖ ^ 2 :=
      mul_pos (pow_pos Real.pi_pos 2) (pow_pos (norm_pos_iff.mpr (mul_ne_zero (uZero_ne_zero t) hdz)) 2)
    exact div_pos (by norm_num) hden
  by_contra hlt
  rw [not_le] at hlt
  have hK_ex : ∃ K : ℝ, 0 < K ∧ K < c₀ ∧
      Filter.limsup
        (fun N : ℕ => ENNReal.ofReal (energyC (wSigmaT (1 / 2) t) 1 N / ((N : ℝ) * (Real.log N) ^ 3)))
        atTop < ENNReal.ofReal K := by
    rcases eq_or_ne (Filter.limsup
        (fun N : ℕ => ENNReal.ofReal (energyC (wSigmaT (1 / 2) t) 1 N / ((N : ℝ) * (Real.log N) ^ 3)))
        atTop) 0 with h0 | hne0
    · refine ⟨c₀ / 2, by linarith, by linarith, ?_⟩
      rw [h0]
      exact ENNReal.ofReal_pos.mpr (by linarith)
    · obtain ⟨y, hy1, hy2⟩ := exists_between hlt
      have hy_top : y < ⊤ := hy2.trans_le le_top
      have hy0 : 0 < y := (pos_iff_ne_zero.mpr hne0).trans hy1
      refine ⟨y.toReal, ENNReal.toReal_pos hy0.ne' hy_top.ne, ?_, ?_⟩
      · have hto : ENNReal.toReal y < ENNReal.toReal (ENNReal.ofReal c₀) :=
          ENNReal.toReal_strict_mono ENNReal.ofReal_ne_top hy2
        rwa [ENNReal.toReal_ofReal hc₀_pos.le] at hto
      · rwa [ENNReal.ofReal_toReal hy_top.ne]
  obtain ⟨K, hK_pos, hK_lt, hls_lt⟩ := hK_ex
  have hev_enn := Filter.eventually_lt_of_limsup_lt hls_lt ⟨⊤, Eventually.of_forall fun _ => le_top⟩
  have hev_bound : ∀ᶠ N : ℕ in atTop,
      energyC (wSigmaT (1 / 2) t) 1 N ≤ K * (N : ℝ) * (Real.log N) ^ 3 := by
    filter_upwards [hev_enn, eventually_ge_atTop 3] with N hN _
    have hlt_real : energyC (wSigmaT (1 / 2) t) 1 N / ((N : ℝ) * (Real.log N) ^ 3) < K :=
      (ENNReal.ofReal_lt_ofReal_iff hK_pos).mp hN
    have hlog_pos : 0 < Real.log (N : ℝ) := Real.log_pos (by exact_mod_cast (by omega : 1 < N))
    have hden_pos : 0 < (N : ℝ) * (Real.log N) ^ 3 :=
      mul_pos (by exact_mod_cast (by omega : 0 < N)) (pow_pos hlog_pos 3)
    have hmul := (div_lt_iff₀ hden_pos).mp hlt_real
    linarith
  have hge := simple_zero_energy_eventually_le_lower t hz hdz hK_pos hev_bound
  linarith

/-- **T3 (Torus-integral formulation via `norm_sq_D_eq_energyC`).** -/
theorem simple_zero_torus_energy_limsup_ge (t : ℝ)
    (hz : riemannZeta (uZero t) = 0) (hdz : deriv riemannZeta (uZero t) ≠ 0) :
    ENNReal.ofReal (2 / (Real.pi ^ 2 * ‖uZero t * deriv riemannZeta (uZero t)‖ ^ 2)) ≤
      Filter.limsup
        (fun N : ℕ => ENNReal.ofReal
          ((∫ ω, ‖D 1 N ω‖ ^ 2 ∂(primeTorusMeasureC (wSigmaT (1 / 2) t))) /
            ((N : ℝ) * (Real.log N) ^ 3)))
        atTop := by
  have heq : ∀ N : ℕ,
      (∫ ω, ‖D 1 N ω‖ ^ 2 ∂(primeTorusMeasureC (wSigmaT (1 / 2) t))) =
        energyC (wSigmaT (1 / 2) t) 1 N :=
    fun N => norm_sq_D_eq_energyC (wSigmaT_half_norm_lt_one t) (le_refl 1) N
  simp_rw [heq]
  exact simple_zero_energy_limsup_ge t hz hdz

/-- Subsequential threshold version of T3' (off-zero `m = 0`): any eventual bound
`E_t(N) ≤ K * N * log N` satisfies `K ≥ 6 / (π^2 * ‖uZero t * ζ(uZero t)‖^2)`. -/
theorem off_zero_energy_eventually_le_lower (t : ℝ) (hnz : riemannZeta (uZero t) ≠ 0)
    {K : ℝ} (hK : 0 < K)
    (hev : ∀ᶠ N : ℕ in atTop, energyC (wSigmaT (1 / 2) t) 1 N ≤ K * (N : ℝ) * Real.log N) :
    6 / (Real.pi ^ 2 * ‖uZero t * riemannZeta (uZero t)‖ ^ 2) ≤ K := by
  rw [eventually_atTop] at hev
  obtain ⟨N₁, hN₁⟩ := hev
  let N₀ := max N₁ 3
  have hN₀ : 3 ≤ N₀ := le_max_right N₁ 3
  have hbound : ∀ N ≥ N₀, energyC (wSigmaT (1 / 2) t) 1 N ≤ K * (N : ℝ) * (Real.log N) ^ 1 := by
    intro N hN
    simpa only [pow_one] using hN₁ N ((le_max_left N₁ 3).trans hN)
  have hzeta_cont : ContinuousAt riemannZeta (uZero t) :=
    (differentiableAt_riemannZeta (uZero_ne_one t)).continuousAt
  have hgood_nhds : {z : ℂ | z ≠ 0 ∧ z ≠ 1 ∧ riemannZeta z ≠ 0} ∈ 𝓝 (uZero t) := by
    have h0 : {z : ℂ | z ≠ 0} ∈ 𝓝 (uZero t) := isOpen_ne.mem_nhds (uZero_ne_zero t)
    have h1 : {z : ℂ | z ≠ 1} ∈ 𝓝 (uZero t) := isOpen_ne.mem_nhds (uZero_ne_one t)
    have hZ : {z : ℂ | riemannZeta z ≠ 0} ∈ 𝓝 (uZero t) :=
      hzeta_cont.preimage_mem_nhds (isOpen_ne.mem_nhds hnz)
    exact Filter.inter_mem h0 (Filter.inter_mem h1 hZ)
  obtain ⟨δ₀, hδ₀_pos, hδ₀_sub⟩ := Metric.mem_nhds_iff.mp hgood_nhds
  let G₀ : ℂ → ℂ := fun z => regZeta (z + sCrit t) / (z * riemannZeta z)
  have hG₀_cont : ContinuousAt G₀ (uZero t) := by
    have hnum : ContinuousAt (fun z => regZeta (z + sCrit t)) (uZero t) :=
      ((differentiable_regZeta (uZero t + sCrit t)).comp (uZero t)
        (differentiableAt_id.add_const _)).continuousAt
    have hden : ContinuousAt (fun z => z * riemannZeta z) (uZero t) :=
      continuousAt_id.mul hzeta_cont
    exact hnum.div hden (mul_ne_zero (uZero_ne_zero t) hnz)
  have hG₀_val : G₀ (uZero t) = 1 / (uZero t * riemannZeta (uZero t)) := by
    simp only [G₀, uZero_add_sCrit, regZeta, Function.update_self]
  have hH_formula : ∀ {h : ℝ}, 0 < h → h < δ₀ →
      (h : ℂ) * H_t t (uZero t + (h : ℂ)) = G₀ (uZero t + (h : ℂ)) := by
    intro h hh hhd
    let u : ℂ := uZero t + (h : ℂ)
    have hu_ball : u ∈ Metric.ball (uZero t) δ₀ := by
      simpa [u, Metric.mem_ball, dist_eq_norm, Complex.norm_real, Real.norm_of_nonneg hh.le] using hhd
    have hugood := hδ₀_sub hu_ball
    have hu_re : 1 / 2 < u.re := by simp [u]; linarith
    have hcont := H_t_continuation_eq t hK 1 hN₀ hbound hu_re hugood.2.1
    have husub : u - uZero t = (h : ℂ) := by simp [u]
    rw [husub] at hcont
    have hden_ne : u * riemannZeta u ≠ 0 := mul_ne_zero hugood.1 hugood.2.2
    calc (h : ℂ) * H_t t u
        = (((h : ℂ) * H_t t u) * (u * riemannZeta u)) / (u * riemannZeta u) :=
            (mul_div_cancel_right₀ _ hden_ne).symm
      _ = ((h : ℂ) * u * riemannZeta u * H_t t u) / (u * riemannZeta u) := by ring
      _ = regZeta (u + sCrit t) / (u * riemannZeta u) := by rw [hcont]
      _ = G₀ u := rfl
  have hLHS_lim :
      Tendsto (fun h : ℝ => ‖(h : ℂ) * H_t t (uZero t + (h : ℂ))‖ ^ 2 * (h * J_h h))
        (𝓝[>] (0 : ℝ))
        (𝓝 (1 / ‖uZero t * riemannZeta (uZero t)‖ ^ 2 * (6 / Real.pi ^ 2))) := by
    have hu_tend : Tendsto (fun h : ℝ => uZero t + (h : ℂ)) (𝓝[>] (0 : ℝ)) (𝓝 (uZero t)) := by
      have hcont : Continuous (fun h : ℝ => uZero t + (h : ℂ)) :=
        continuous_const.add Complex.continuous_ofReal
      simpa using (hcont.tendsto (0 : ℝ)).mono_left nhdsWithin_le_nhds
    have hG_tend := hG₀_cont.tendsto.comp hu_tend
    rw [hG₀_val] at hG_tend
    have h_norm_sq :
        Tendsto (fun h : ℝ => ‖(h : ℂ) * H_t t (uZero t + (h : ℂ))‖ ^ 2)
          (𝓝[>] (0 : ℝ)) (𝓝 (‖1 / (uZero t * riemannZeta (uZero t))‖ ^ 2)) := by
      have hnorm := ((continuous_norm.pow 2).tendsto _).comp hG_tend
      refine hnorm.congr' ?_
      filter_upwards [eventually_nhdsWithin_of_eventually_nhds (Iio_mem_nhds hδ₀_pos),
        self_mem_nhdsWithin] with h hh_lt hh_gt
      simp only [Function.comp_apply, Pi.pow_apply, hH_formula hh_gt hh_lt]
    have hnorm_val : ‖1 / (uZero t * riemannZeta (uZero t))‖ ^ 2 =
        1 / ‖uZero t * riemannZeta (uZero t)‖ ^ 2 := by
      rw [norm_div, norm_one, div_pow, one_pow]
    rw [hnorm_val] at h_norm_sq
    exact h_norm_sq.mul tendsto_mul_J_h
  let M₀ := ∑ n ∈ Finset.range (N₀ + 1), energyC (wSigmaT (1 / 2) t) 1 n
  have h_ineq : ∀ᶠ h : ℝ in 𝓝[>] (0 : ℝ),
      ‖(h : ℂ) * H_t t (uZero t + (h : ℂ))‖ ^ 2 * (h * J_h h) ≤
        h ^ 2 * (M₀ * ((N₀ : ℝ) - 1)) + K := by
    filter_upwards [eventually_nhdsWithin_of_eventually_nhds (Iio_mem_nhds hδ₀_pos),
      self_mem_nhdsWithin] with h hh_lt hh_gt
    have hh : 0 < h := hh_gt
    let u : ℂ := uZero t + (h : ℂ)
    have hu : 1 / 2 < u.re := by simp [u]; linarith
    obtain ⟨_, hmc, _⟩ := (H_t_analytic_and_hasDerivAt t hK 1 hN₀ hbound).2 hu
    have hnorm_H :
        ‖H_t t u‖ ≤ ∫ x in Set.Ioi (1 : ℝ),
          (‖S_t t x‖ * x ^ (-(2 + h) / 2)) * ((Real.log x) ^ 0 * x ^ (-(1 + h) / 2)) := by
      calc ‖∫ x in Set.Ioi (1 : ℝ), S_t t x * (x : ℂ) ^ (-(u + 1))‖
          ≤ ∫ x in Set.Ioi (1 : ℝ), ‖S_t t x * (x : ℂ) ^ (-(u + 1))‖ :=
            norm_integral_le_integral_norm _
        _ = ∫ x in Set.Ioi (1 : ℝ),
              (‖S_t t x‖ * x ^ (-(2 + h) / 2)) * ((Real.log x) ^ 0 * x ^ (-(1 + h) / 2)) := by
            refine setIntegral_congr_fun measurableSet_Ioi fun x hx => ?_
            have hx0 : 0 < x := lt_trans zero_lt_one hx
            have hpow_re : (-(u + 1)).re = -(3 / 2 + h) := by simp [u]; ring
            have hpow_norm : ‖(x : ℂ) ^ (-(u + 1))‖ = x ^ (-(3 / 2 + h)) := by
              rw [Complex.norm_cpow_eq_rpow_re_of_pos hx0, hpow_re]
            rw [norm_mul, hpow_norm, pow_zero, one_mul]
            have hsplit : x ^ (-(3 / 2 + h)) = x ^ (-(2 + h) / 2) * x ^ (-(1 + h) / 2) := by
              rw [← Real.rpow_add hx0]
              congr 1; ring
            rw [hsplit]; ring
    have hCS :
        (∫ x in Set.Ioi (1 : ℝ),
            (‖S_t t x‖ * x ^ (-(2 + h) / 2)) * ((Real.log x) ^ 0 * x ^ (-(1 + h) / 2))) ^ 2 ≤
          (∫ x in Set.Ioi (1 : ℝ), ‖S_t t x‖ ^ 2 * x ^ (-2 - h)) * (1 / h) := by
      have ha_sq : IntegrableOn (fun x : ℝ => (‖S_t t x‖ * x ^ (-(2 + h) / 2)) ^ 2) (Set.Ioi 1) := by
        refine (integrableOn_S_t_sq_mul_rpow t hK 1 hN₀ hbound hh).congr_fun (fun x hx => ?_) measurableSet_Ioi
        have hx0 : 0 < x := lt_trans zero_lt_one hx
        rw [mul_pow, ← Real.rpow_natCast (x ^ _), ← Real.rpow_mul hx0.le,
          show (-(2 + h) / 2 * (2 : ℕ) : ℝ) = -2 - h by push_cast; ring]
      have hb_sq : IntegrableOn (fun x : ℝ => ((Real.log x) ^ 0 * x ^ (-(1 + h) / 2)) ^ 2) (Set.Ioi 1) := by
        refine (integrableOn_Ioi_log_pow_mul_rpow 0 hh).congr_fun (fun x hx => ?_) measurableSet_Ioi
        have hx0 : 0 < x := lt_trans zero_lt_one hx
        simp only [pow_zero, one_mul]
        rw [← Real.rpow_natCast (x ^ _), ← Real.rpow_mul hx0.le]
        congr 2; ring
      have hab := integrableOn_S_t_mul_log_pow t hK 1 0 hN₀ hbound hh
      have hsq_le := sq_integral_mul_le_mul_integral_sq
        (fun x hx => by simp; exact Real.rpow_nonneg (lt_trans zero_lt_one hx).le _)
        ha_sq hb_sq hab
      have hA_eq : (∫ x in Set.Ioi (1 : ℝ), (‖S_t t x‖ * x ^ (-(2 + h) / 2)) ^ 2) =
          ∫ x in Set.Ioi (1 : ℝ), ‖S_t t x‖ ^ 2 * x ^ (-2 - h) := by
        refine setIntegral_congr_fun measurableSet_Ioi fun x hx => ?_
        have hx0 : 0 < x := lt_trans zero_lt_one hx
        rw [mul_pow, ← Real.rpow_natCast (x ^ _), ← Real.rpow_mul hx0.le,
          show (-(2 + h) / 2 * (2 : ℕ) : ℝ) = -2 - h by push_cast; ring]
      have hB_eq : (∫ x in Set.Ioi (1 : ℝ), ((Real.log x) ^ 0 * x ^ (-(1 + h) / 2)) ^ 2) = 1 / h := by
        have hid : (∫ x in Set.Ioi (1 : ℝ), ((Real.log x) ^ 0 * x ^ (-(1 + h) / 2)) ^ 2) =
            ∫ x in Set.Ioi (1 : ℝ), (Real.log x) ^ 0 * x ^ (-1 - h) := by
          refine setIntegral_congr_fun measurableSet_Ioi fun x hx => ?_
          have hx0 : 0 < x := lt_trans zero_lt_one hx
          simp only [pow_zero, one_mul]
          rw [← Real.rpow_natCast (x ^ _), ← Real.rpow_mul hx0.le]
          congr 2; ring
        rw [hid, integral_Ioi_log_pow_mul_rpow 0 hh]
        norm_num
      rwa [hA_eq, hB_eq] at hsq_le
    have hH_sq : ‖H_t t u‖ ^ 2 ≤
        (∫ x in Set.Ioi (1 : ℝ), ‖S_t t x‖ ^ 2 * x ^ (-2 - h)) * (1 / h) :=
      (pow_le_pow_left₀ (norm_nonneg _) hnorm_H 2).trans hCS
    have hup := E_t_energy_integral_upper t hK 1 hN₀ hbound hh
    have hfac : ((1 : ℕ).factorial : ℝ) = 1 := by norm_num
    rw [hfac] at hup
    have hnorm_h : ‖(h : ℂ) * H_t t u‖ ^ 2 = h ^ 2 * ‖H_t t u‖ ^ 2 := by
      rw [norm_mul, Complex.norm_real, Real.norm_of_nonneg hh.le, mul_pow]
    rw [hnorm_h]
    have hJ0 : 0 ≤ J_h h := (J_h_pos hh).le
    calc h ^ 2 * ‖H_t t u‖ ^ 2 * (h * J_h h)
        = (h ^ 3 * J_h h) * ‖H_t t u‖ ^ 2 := by ring
      _ ≤ (h ^ 3 * J_h h) * ((∫ x in Set.Ioi (1 : ℝ), ‖S_t t x‖ ^ 2 * x ^ (-2 - h)) * (1 / h)) :=
          mul_le_mul_of_nonneg_left hH_sq (by positivity)
      _ = h ^ 2 * (J_h h * ∫ x in Set.Ioi (1 : ℝ), ‖S_t t x‖ ^ 2 * x ^ (-2 - h)) := by
          field_simp [hh.ne']
      _ ≤ h ^ 2 * (M₀ * ((N₀ : ℝ) - 1) + K * 1 / h ^ (1 + 1)) := by
          gcongr
      _ = h ^ 2 * (M₀ * ((N₀ : ℝ) - 1)) + K := by
          have : h ^ (1 + 1 : ℕ) = h ^ 2 := by ring
          rw [this]
          field_simp [hh.ne']
  have hRHS_lim :
      Tendsto (fun h : ℝ => h ^ 2 * (M₀ * ((N₀ : ℝ) - 1)) + K)
        (𝓝[>] (0 : ℝ)) (𝓝 (0 ^ 2 * (M₀ * ((N₀ : ℝ) - 1)) + K)) := by
    have hcont : Continuous (fun h : ℝ => h ^ 2 * (M₀ * ((N₀ : ℝ) - 1)) + K) := by fun_prop
    exact hcont.continuousAt.tendsto.mono_left nhdsWithin_le_nhds
  have hfinal := le_of_tendsto_of_tendsto hLHS_lim hRHS_lim h_ineq
  simp only [zero_pow (by norm_num : 2 ≠ 0), zero_mul, zero_add] at hfinal
  have hden : 0 < Real.pi ^ 2 * ‖uZero t * riemannZeta (uZero t)‖ ^ 2 :=
    mul_pos (pow_pos Real.pi_pos 2) (pow_pos (norm_pos_iff.mpr (mul_ne_zero (uZero_ne_zero t) hnz)) 2)
  rw [div_mul_div_comm, mul_comm (‖uZero t * riemannZeta (uZero t)‖ ^ 2) (Real.pi ^ 2),
    div_le_iff₀ hden] at hfinal
  rw [div_le_iff₀ hden]
  nlinarith

/-- **T3' (Unconditional off-zero `limsup` lower bound matching `1 / (ζ(2) |u₀ ζ(u₀)|²)`).** -/
theorem off_zero_energy_limsup_ge (t : ℝ) (hnz : riemannZeta (uZero t) ≠ 0) :
    ENNReal.ofReal (6 / (Real.pi ^ 2 * ‖uZero t * riemannZeta (uZero t)‖ ^ 2)) ≤
      Filter.limsup
        (fun N : ℕ => ENNReal.ofReal (energyC (wSigmaT (1 / 2) t) 1 N / ((N : ℝ) * Real.log N)))
        atTop := by
  let c₀ : ℝ := 6 / (Real.pi ^ 2 * ‖uZero t * riemannZeta (uZero t)‖ ^ 2)
  have hc₀_pos : 0 < c₀ := by
    have hden : 0 < Real.pi ^ 2 * ‖uZero t * riemannZeta (uZero t)‖ ^ 2 :=
      mul_pos (pow_pos Real.pi_pos 2) (pow_pos (norm_pos_iff.mpr (mul_ne_zero (uZero_ne_zero t) hnz)) 2)
    exact div_pos (by norm_num) hden
  by_contra hlt
  rw [not_le] at hlt
  have hK_ex : ∃ K : ℝ, 0 < K ∧ K < c₀ ∧
      Filter.limsup
        (fun N : ℕ => ENNReal.ofReal (energyC (wSigmaT (1 / 2) t) 1 N / ((N : ℝ) * Real.log N)))
        atTop < ENNReal.ofReal K := by
    rcases eq_or_ne (Filter.limsup
        (fun N : ℕ => ENNReal.ofReal (energyC (wSigmaT (1 / 2) t) 1 N / ((N : ℝ) * Real.log N)))
        atTop) 0 with h0 | hne0
    · refine ⟨c₀ / 2, by linarith, by linarith, ?_⟩
      rw [h0]
      exact ENNReal.ofReal_pos.mpr (by linarith)
    · obtain ⟨y, hy1, hy2⟩ := exists_between hlt
      have hy_top : y < ⊤ := hy2.trans_le le_top
      have hy0 : 0 < y := (pos_iff_ne_zero.mpr hne0).trans hy1
      refine ⟨y.toReal, ENNReal.toReal_pos hy0.ne' hy_top.ne, ?_, ?_⟩
      · have hto : ENNReal.toReal y < ENNReal.toReal (ENNReal.ofReal c₀) :=
          ENNReal.toReal_strict_mono ENNReal.ofReal_ne_top hy2
        rwa [ENNReal.toReal_ofReal hc₀_pos.le] at hto
      · rwa [ENNReal.ofReal_toReal hy_top.ne]
  obtain ⟨K, hK_pos, hK_lt, hls_lt⟩ := hK_ex
  have hev_enn := Filter.eventually_lt_of_limsup_lt hls_lt ⟨⊤, Eventually.of_forall fun _ => le_top⟩
  have hev_bound : ∀ᶠ N : ℕ in atTop,
      energyC (wSigmaT (1 / 2) t) 1 N ≤ K * (N : ℝ) * Real.log N := by
    filter_upwards [hev_enn, eventually_ge_atTop 3] with N hN _
    have hlt_real : energyC (wSigmaT (1 / 2) t) 1 N / ((N : ℝ) * Real.log N) < K :=
      (ENNReal.ofReal_lt_ofReal_iff hK_pos).mp hN
    have hlog_pos : 0 < Real.log (N : ℝ) := Real.log_pos (by exact_mod_cast (by omega : 1 < N))
    have hden_pos : 0 < (N : ℝ) * Real.log N :=
      mul_pos (by exact_mod_cast (by omega : 0 < N)) hlog_pos
    have hmul := (div_lt_iff₀ hden_pos).mp hlt_real
    linarith
  have hge := off_zero_energy_eventually_le_lower t hnz hK_pos hev_bound
  linarith

/-- **T3' (Torus-integral formulation via `norm_sq_D_eq_energyC`).** -/
theorem off_zero_torus_energy_limsup_ge (t : ℝ) (hnz : riemannZeta (uZero t) ≠ 0) :
    ENNReal.ofReal (6 / (Real.pi ^ 2 * ‖uZero t * riemannZeta (uZero t)‖ ^ 2)) ≤
      Filter.limsup
        (fun N : ℕ => ENNReal.ofReal
          ((∫ ω, ‖D 1 N ω‖ ^ 2 ∂(primeTorusMeasureC (wSigmaT (1 / 2) t))) /
            ((N : ℝ) * Real.log N)))
        atTop := by
  have heq : ∀ N : ℕ,
      (∫ ω, ‖D 1 N ω‖ ^ 2 ∂(primeTorusMeasureC (wSigmaT (1 / 2) t))) =
        energyC (wSigmaT (1 / 2) t) 1 N :=
    fun N => norm_sq_D_eq_energyC (wSigmaT_half_norm_lt_one t) (le_refl 1) N
  simp_rw [heq]
  exact off_zero_energy_limsup_ge t hnz

end RHConnections.R5Resonance


