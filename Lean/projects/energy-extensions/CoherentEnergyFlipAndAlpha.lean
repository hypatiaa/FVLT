import Verified
import CoherentEnergyReflectionStrip
import CoherentEnergyRotatedCentre
import FVLTAlphaAmplitudeV1

/-!
# Critical-line flip, Hardy rotation, off-line `χ` stretch, and FVLT alpha bridge

Addresses items **R6** and **R7** from Stack Bus `#2202` (addendum to `#2201`),
at `saphir`'s request:

1. **R6 (Flip on the line, Hardy rotation, and off-line stretch):**
   - `chiFactor s := (1 - s).Gammaℝ / s.Gammaℝ`.
   - On `{s | s ≠ 0 ∧ 1 - s ≠ 0}`, `riemannZeta s = chiFactor s * riemannZeta (1 - s)`.
   - Inside `0 < σ < 1`, `ζ(σ + it) = chiFactor (σ + it) * conj (ζ((1 - σ) + it))`.
   - On the critical line `σ = 1/2`, `‖chiFactor (1/2 + it)‖ = 1` and
     `ζ(1/2 + it) = chiFactor (1/2 + it) * conj (ζ(1/2 + it))` ("mirror, then turn").
   - Defining `hardyTheta t := ((1/2 + it).Gammaℝ).arg`, the rotated value
     `exp (i * hardyTheta t) * ζ(1/2 + it)` is real (`(.im = 0)`), and the `-1` flip keeps it real.
   - Off the critical line (`σ ≠ 1/2` real), `‖chiFactor (σ + it)‖ ≠ 1` for all sufficiently large `|t|`
     (`‖chiFactor‖ < 1` for `σ > 1/2` and `1 < ‖chiFactor‖` for `σ < 1/2`), proved via `GammaSeq` ratios.

2. **R7 (Honest algebraic/structural bridge to `FVLT.AlphaAmplitudeV1`):**
   - Twin map `alphaTwin α = -1 - α` has unique fixed point `α = -1/2` (`α ↔ -σ`).
   - Positive radius `FVLT.AlphaAmplitudeV1.radius m (-σ) 1` equals `‖wSigmaT σ t m.n3‖`.
   - Negating `n6 ↦ -n6` preserves norm and real-axis contact finset while flipping `point` by `-1`;
     dividing by signed radius strips `α` and `n6` while preserving `phase`; `z2_eq_conj_z1` mirrors
     conjugation.
   - **Scope limit (no analytic bridge claimed):** `FVLT.AlphaAmplitudeV1` uses a single positive integer
     modulus `m.n3` with discrete rational rosette phases and has neither Dirichlet-series Euler products
     nor off-line `χ` stretching / analytic continuation.
-/

noncomputable section
open scoped BigOperators ComplexConjugate
open Complex Filter Topology

namespace RHConnections.CoherentEnergyFlip

open RHConnections.CoherentEnergyRotated

/-! ## R6.1: The functional-equation factor `χ(s) = Γ_ℝ(1 - s) / Γ_ℝ(s)` and critical-line flip -/

def chiFactor (s : ℂ) : ℂ := (1 - s).Gammaℝ / s.Gammaℝ

def hardyTheta (t : ℝ) : ℝ := ((⟨1 / 2, t⟩ : ℂ).Gammaℝ).arg

theorem chiFactor_conj (s : ℂ) : chiFactor (conj s) = conj (chiFactor s) := by
  unfold chiFactor
  rw [map_div₀, ← Complex.Gammaℝ_conj, ← Complex.Gammaℝ_conj, map_sub, map_one]

theorem chiFactor_one_sub_mul {s : ℂ} (hs : s.Gammaℝ ≠ 0) (h1s : (1 - s).Gammaℝ ≠ 0) :
    chiFactor (1 - s) * chiFactor s = 1 := by
  unfold chiFactor
  rw [sub_sub_cancel]
  field_simp [hs, h1s]

theorem riemannZeta_eq_chiFactor_mul_one_sub {s : ℂ} (hs0 : s ≠ 0) (h1s0 : 1 - s ≠ 0)
    (hsG : s.Gammaℝ ≠ 0) (h1sG : (1 - s).Gammaℝ ≠ 0) :
    riemannZeta s = chiFactor s * riemannZeta (1 - s) := by
  rw [riemannZeta_def_of_ne_zero hs0, riemannZeta_def_of_ne_zero h1s0,
    completedRiemannZeta_one_sub s, chiFactor]
  field_simp [hsG, h1sG]

theorem riemannZeta_eq_chiFactor_mul_conj_twin {σ : ℝ} (hσ0 : 0 < σ) (hσ1 : σ < 1) (t : ℝ) :
    riemannZeta (⟨σ, t⟩ : ℂ) = chiFactor (⟨σ, t⟩ : ℂ) * conj (riemannZeta (⟨1 - σ, t⟩ : ℂ)) := by
  let s : ℂ := ⟨σ, t⟩
  have hs_re : 0 < s.re := hσ0
  have h1s_re : 0 < (1 - s).re := by simp [s]; linarith
  have hs0 : s ≠ 0 := fun h => by have := congr_arg Complex.re h; simp [s] at this; linarith
  have h1s0 : 1 - s ≠ 0 := fun h => by have := congr_arg Complex.re h; simp [s] at this; linarith
  have hconj : 1 - s = conj (⟨1 - σ, t⟩ : ℂ) := by
    apply Complex.ext <;> simp [s]
  rw [riemannZeta_eq_chiFactor_mul_one_sub hs0 h1s0
      (Complex.Gammaℝ_ne_zero_of_re_pos hs_re) (Complex.Gammaℝ_ne_zero_of_re_pos h1s_re),
    hconj, riemannZeta_conj]

private lemma one_sub_half_add_I_eq_conj (t : ℝ) :
    1 - (⟨1 / 2, t⟩ : ℂ) = conj (⟨1 / 2, t⟩ : ℂ) := by
  apply Complex.ext
  · simp; norm_num
  · simp

theorem chiFactor_critical_line_norm (t : ℝ) :
    ‖chiFactor (⟨1 / 2, t⟩ : ℂ)‖ = 1 := by
  let s : ℂ := ⟨1 / 2, t⟩
  have hGs : s.Gammaℝ ≠ 0 := Complex.Gammaℝ_ne_zero_of_re_pos (by simp [s])
  unfold chiFactor
  rw [one_sub_half_add_I_eq_conj t, Complex.Gammaℝ_conj, norm_div, Complex.norm_conj,
    div_self (norm_ne_zero_iff.mpr hGs)]

theorem chiFactor_critical_line_eq_exp (t : ℝ) :
    chiFactor (⟨1 / 2, t⟩ : ℂ) = Complex.exp (-(2 * (hardyTheta t : ℂ) * Complex.I)) := by
  let s : ℂ := ⟨1 / 2, t⟩
  have hGs : s.Gammaℝ ≠ 0 := Complex.Gammaℝ_ne_zero_of_re_pos (by simp [s])
  have hnorm : (‖s.Gammaℝ‖ : ℂ) ≠ 0 := Complex.ofReal_ne_zero.mpr (norm_ne_zero_iff.mpr hGs)
  have hpol : s.Gammaℝ = (‖s.Gammaℝ‖ : ℂ) * Complex.exp ((hardyTheta t : ℂ) * Complex.I) := by
    symm
    exact Complex.norm_mul_exp_arg_mul_I s.Gammaℝ
  have hpol_conj : conj s.Gammaℝ = (‖s.Gammaℝ‖ : ℂ) * Complex.exp (-((hardyTheta t : ℂ) * Complex.I)) := by
    calc conj s.Gammaℝ
        = conj ((‖s.Gammaℝ‖ : ℂ) * Complex.exp ((hardyTheta t : ℂ) * Complex.I)) := by rw [← hpol]
      _ = (‖s.Gammaℝ‖ : ℂ) * Complex.exp (-((hardyTheta t : ℂ) * Complex.I)) := by
          rw [map_mul, Complex.conj_ofReal, ← Complex.exp_conj, map_mul, Complex.conj_ofReal,
            Complex.conj_I, mul_neg]
  unfold chiFactor
  rw [one_sub_half_add_I_eq_conj t, Complex.Gammaℝ_conj, hpol_conj]
  nth_rw 2 [hpol]
  rw [mul_div_mul_left _ _ hnorm, ← Complex.exp_sub]
  congr 1
  ring

theorem riemannZeta_critical_line_eq_chi_mul_conj (t : ℝ) :
    riemannZeta (⟨1 / 2, t⟩ : ℂ) =
      chiFactor (⟨1 / 2, t⟩ : ℂ) * conj (riemannZeta (⟨1 / 2, t⟩ : ℂ)) := by
  have h := riemannZeta_eq_chiFactor_mul_conj_twin (σ := 1 / 2) (by norm_num) (by norm_num) t
  have hhalf : (1 : ℝ) - 1 / 2 = 1 / 2 := by norm_num
  rwa [hhalf] at h

theorem completedRiemannZeta_critical_line_real (t : ℝ) :
    (completedRiemannZeta (⟨1 / 2, t⟩ : ℂ)).im = 0 := by
  let s : ℂ := ⟨1 / 2, t⟩
  have hs0 : s ≠ 0 := fun h => by have := congr_arg Complex.re h; simp [s] at this
  have hsc0 : conj s ≠ 0 := fun h => hs0 ((map_eq_zero (starRingEnd ℂ)).mp h)
  have hGs : s.Gammaℝ ≠ 0 := Complex.Gammaℝ_ne_zero_of_re_pos (by simp [s])
  have hGsc : (conj s).Gammaℝ ≠ 0 := Complex.Gammaℝ_ne_zero_of_re_pos (by simp [s])
  have hcz : completedRiemannZeta s = s.Gammaℝ * riemannZeta s := by
    rw [riemannZeta_def_of_ne_zero hs0, mul_div_cancel₀ _ hGs]
  have hcz_conj : conj (completedRiemannZeta s) = completedRiemannZeta s := by
    calc conj (completedRiemannZeta s)
        = conj (s.Gammaℝ * riemannZeta s) := by rw [hcz]
      _ = (conj s).Gammaℝ * riemannZeta (conj s) := by
          rw [map_mul, Complex.Gammaℝ_conj, riemannZeta_conj]
      _ = completedRiemannZeta (conj s) := by
          rw [riemannZeta_def_of_ne_zero hsc0, mul_div_cancel₀ _ hGsc]
      _ = completedRiemannZeta (1 - s) := by rw [← one_sub_half_add_I_eq_conj t]
      _ = completedRiemannZeta s := completedRiemannZeta_one_sub s
  exact Complex.conj_eq_iff_im.mp hcz_conj

theorem hardy_rotation_real (t : ℝ) :
    (Complex.exp ((hardyTheta t : ℂ) * Complex.I) * riemannZeta (⟨1 / 2, t⟩ : ℂ)).im = 0 := by
  let s : ℂ := ⟨1 / 2, t⟩
  have hs0 : s ≠ 0 := fun h => by have := congr_arg Complex.re h; simp [s] at this
  have hGs : s.Gammaℝ ≠ 0 := Complex.Gammaℝ_ne_zero_of_re_pos (by simp [s])
  have hnorm : (‖s.Gammaℝ‖ : ℂ) ≠ 0 := Complex.ofReal_ne_zero.mpr (norm_ne_zero_iff.mpr hGs)
  have hpol : Complex.exp ((hardyTheta t : ℂ) * Complex.I) =
      (‖s.Gammaℝ‖⁻¹ : ℝ) * s.Gammaℝ := by
    have hp := Complex.norm_mul_exp_arg_mul_I s.Gammaℝ
    change (‖s.Gammaℝ‖ : ℂ) * Complex.exp ((hardyTheta t : ℂ) * Complex.I) = s.Gammaℝ at hp
    rw [Complex.ofReal_inv, mul_comm ((‖s.Gammaℝ‖ : ℂ)⁻¹), eq_mul_inv_iff_mul_eq₀ hnorm, mul_comm]
    exact hp
  have heq : Complex.exp ((hardyTheta t : ℂ) * Complex.I) * riemannZeta s =
      ((‖s.Gammaℝ‖⁻¹ : ℝ) : ℂ) * completedRiemannZeta s := by
    rw [hpol, mul_assoc, riemannZeta_def_of_ne_zero hs0, mul_div_cancel₀ _ hGs]
  rw [heq, Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, completedRiemannZeta_critical_line_real t]
  ring

theorem hardy_rotation_neg_real (t : ℝ) :
    (Complex.exp ((hardyTheta t : ℂ) * Complex.I) * (-riemannZeta (⟨1 / 2, t⟩ : ℂ))).im = 0 := by
  rw [mul_neg, Complex.neg_im, hardy_rotation_real t, neg_zero]

/-! ## R6.2: Off-critical-line `‖χ(σ + it)‖ ≠ 1` for large `|t|` via `GammaSeq` -/

private lemma exp_one_lt_four : Real.exp 1 < 4 := by
  have h1 : (3 / 4 : ℝ) ≤ Real.exp (-(1 / 4 : ℝ)) := by
    have h := Real.add_one_le_exp (-(1 / 4 : ℝ))
    linarith
  have h2 : Real.exp (1 / 4 : ℝ) ≤ 4 / 3 := by
    have hpos : (0 : ℝ) < Real.exp (-(1 / 4 : ℝ)) := Real.exp_pos _
    rw [show (1 / 4 : ℝ) = -(-(1 / 4 : ℝ)) by ring, Real.exp_neg]
    exact inv_le_of_inv_le₀ (by norm_num) (by linarith)
  have h4 : Real.exp 1 = (Real.exp (1 / 4 : ℝ)) ^ 4 := by
    rw [← Real.exp_nat_mul]
    norm_num
  rw [h4]
  calc (Real.exp (1 / 4 : ℝ)) ^ 4 ≤ (4 / 3 : ℝ) ^ 4 :=
        pow_le_pow_left₀ (Real.exp_pos _).le h2 4
    _ < 4 := by norm_num

private lemma harmonic_two_pow_ge (m : ℕ) :
    1 + (m : ℝ) / 2 ≤ ∑ k ∈ Finset.range (2 ^ m), (1 : ℝ) / ((k : ℝ) + 1) := by
  induction m with
  | zero => simp
  | succ m ih =>
    have hsplit : 2 ^ (m + 1) = 2 ^ m + 2 ^ m := by ring
    rw [hsplit, Finset.sum_range_add]
    have hlow : (1 : ℝ) / 2 ≤ ∑ k ∈ Finset.range (2 ^ m), (1 : ℝ) / (((2 ^ m + k : ℕ) : ℝ) + 1) := by
      have hterm : ∀ k ∈ Finset.range (2 ^ m),
          (1 : ℝ) / ((2 ^ (m + 1) : ℕ) : ℝ) ≤ (1 : ℝ) / (((2 ^ m + k : ℕ) : ℝ) + 1) := by
        intro k hk
        have hklt : k < 2 ^ m := Finset.mem_range.mp hk
        apply one_div_le_one_div_of_le (by positivity)
        exact_mod_cast (show 2 ^ m + k + 1 ≤ 2 ^ (m + 1) by omega)
      calc (1 : ℝ) / 2
          = ((2 ^ m : ℕ) : ℝ) * ((1 : ℝ) / ((2 ^ (m + 1) : ℕ) : ℝ)) := by
            push_cast [pow_succ]; field_simp
        _ = ∑ _k ∈ Finset.range (2 ^ m), (1 : ℝ) / ((2 ^ (m + 1) : ℕ) : ℝ) := by
            rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul]
        _ ≤ ∑ k ∈ Finset.range (2 ^ m), (1 : ℝ) / (((2 ^ m + k : ℕ) : ℝ) + 1) :=
            Finset.sum_le_sum hterm
    push_cast at hlow ⊢
    linarith

private lemma prod_ratio_tendsto_zero {a b : ℝ} (ha : 0 < a) (hab : a < b) :
    ∀ ε : ℝ, 0 < ε → ∃ N : ℕ, ∏ j ∈ Finset.range N, ((a + j) / (b + j)) < ε := by
  intro ε hε
  have hb : 0 < b := ha.trans hab
  have hd : 0 < b - a := sub_pos.mpr hab
  let c : ℕ := ⌈b⌉₊ + 1
  have hc_pos : (0 : ℝ) < (c : ℝ) := by positivity
  have hbc : b ≤ (c : ℝ) := (Nat.le_ceil b).trans (by norm_cast; omega)
  let r : ℝ := (b - a) / (c : ℝ)
  have hr : 0 < r := div_pos hd hc_pos
  have hbound : ∀ N : ℕ,
      ∏ j ∈ Finset.range N, ((a + j) / (b + j)) ≤
        Real.exp (-r * ∑ j ∈ Finset.range N, (1 : ℝ) / ((j : ℝ) + 1)) := by
    intro N
    have h1 : ∏ j ∈ Finset.range N, ((a + j) / (b + j)) ≤
        ∏ j ∈ Finset.range N, Real.exp (-(r / ((j : ℝ) + 1))) := by
      refine Finset.prod_le_prod₀ (fun j _ => div_nonneg (by positivity) (by positivity)) fun j _ => ?_
      have hbj_pos : 0 < b + (j : ℝ) := by positivity
      have hbj_le : b + (j : ℝ) ≤ (c : ℝ) * ((j : ℝ) + 1) := by
        have hc1 : (1 : ℝ) ≤ (c : ℝ) := by exact_mod_cast (show 1 ≤ c by omega)
        nlinarith [show (0 : ℝ) ≤ (j : ℝ) from Nat.cast_nonneg j]
      have hsub : (a + (j : ℝ)) / (b + (j : ℝ)) = 1 - (b - a) / (b + (j : ℝ)) := by
        field_simp; ring
      have hstep : 1 - (b - a) / (b + (j : ℝ)) ≤ 1 - r / ((j : ℝ) + 1) := by
        apply sub_le_sub_left
        rw [div_div]
        exact div_le_div_of_nonneg_left hd.le hbj_pos hbj_le
      calc (a + (j : ℝ)) / (b + (j : ℝ))
          ≤ -(r / ((j : ℝ) + 1)) + 1 := by linarith [hsub, hstep]
        _ ≤ Real.exp (-(r / ((j : ℝ) + 1))) := Real.add_one_le_exp _
    rw [← Real.exp_sum] at h1
    refine h1.trans_eq ?_
    congr 1
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl fun j _ => by ring
  obtain ⟨m, hm⟩ := exists_nat_gt (2 * ((-Real.log ε + 1) / r))
  refine ⟨2 ^ m, ?_⟩
  have hsum : -Real.log ε + 1 ≤ r * ∑ j ∈ Finset.range (2 ^ m), (1 : ℝ) / ((j : ℝ) + 1) := by
    have hm1 : (-Real.log ε + 1) / r ≤ 1 + (m : ℝ) / 2 := by linarith
    have hm2 := hm1.trans (harmonic_two_pow_ge m)
    calc -Real.log ε + 1 = r * ((-Real.log ε + 1) / r) := by field_simp [hr.ne']
      _ ≤ r * ∑ j ∈ Finset.range (2 ^ m), (1 : ℝ) / ((j : ℝ) + 1) :=
          mul_le_mul_of_nonneg_left hm2 hr.le
  have hexp : Real.exp (-r * ∑ j ∈ Finset.range (2 ^ m), (1 : ℝ) / ((j : ℝ) + 1)) ≤
      Real.exp (Real.log ε - 1) := by
    rw [Real.exp_le_exp]
    linarith
  have hlt : Real.exp (Real.log ε - 1) < ε := by
    rw [Real.exp_sub, Real.exp_log hε]
    exact div_lt_self hε (Real.one_lt_exp_iff.mpr one_pos)
  exact (hbound (2 ^ m)).trans_lt (hexp.trans_lt hlt)

private lemma norm_add_nat_pos {r : ℝ} (hr : 0 < r) (y : ℝ) (j : ℕ) :
    0 < ‖(⟨r, y⟩ : ℂ) + j‖ := by
  refine norm_pos_iff.mpr fun h => ?_
  have hr0 := congr_arg Complex.re h
  simp only [Complex.add_re, Complex.natCast_re, Complex.zero_re] at hr0
  linarith [Nat.cast_nonneg (α := ℝ) j]

private lemma norm_ratio_le_real_ratio {a b : ℝ} (ha : 0 < a) (hab : a < b) (y : ℝ) (j : ℕ) :
    ‖(⟨b, y⟩ : ℂ) + j‖ / ‖(⟨a, y⟩ : ℂ) + j‖ ≤ (b + j) / (a + j) := by
  have hb : 0 < b := ha.trans hab
  have ha_norm := norm_add_nat_pos ha y j
  have ha_real : 0 < a + (j : ℝ) := by positivity
  rw [div_le_div_iff₀ ha_norm ha_real]
  have hsq : (‖(⟨b, y⟩ : ℂ) + j‖ * (a + (j : ℝ))) ^ 2 ≤
      ((b + (j : ℝ)) * ‖(⟨a, y⟩ : ℂ) + j‖) ^ 2 := by
    rw [mul_pow, mul_pow, ← Complex.normSq_eq_norm_sq, ← Complex.normSq_eq_norm_sq]
    have n1 : Complex.normSq ((⟨b, y⟩ : ℂ) + j) = (b + j) ^ 2 + y ^ 2 := by
      simp [Complex.normSq_apply]; ring
    have n2 : Complex.normSq ((⟨a, y⟩ : ℂ) + j) = (a + j) ^ 2 + y ^ 2 := by
      simp [Complex.normSq_apply]; ring
    rw [n1, n2]
    have hsq_ab : (a + (j : ℝ)) ^ 2 ≤ (b + (j : ℝ)) ^ 2 := by
      nlinarith [show (0 : ℝ) ≤ (b + (j : ℝ)) - (a + (j : ℝ)) by linarith,
        show (0 : ℝ) ≤ (b + (j : ℝ)) + (a + (j : ℝ)) by positivity]
    have hy_ab : y ^ 2 * (a + (j : ℝ)) ^ 2 ≤ y ^ 2 * (b + (j : ℝ)) ^ 2 :=
      mul_le_mul_of_nonneg_left hsq_ab (sq_nonneg y)
    linarith
  have hn1 : 0 ≤ ‖(⟨b, y⟩ : ℂ) + j‖ * (a + (j : ℝ)) := by positivity
  have hn2 : 0 ≤ (b + (j : ℝ)) * ‖(⟨a, y⟩ : ℂ) + j‖ := by positivity
  nlinarith

private lemma norm_Gamma_div_Gamma_le_of_lt {a b : ℝ} (ha : 0 < a) (hab : a < b) (y : ℝ) (N : ℕ) :
    ‖Complex.Gamma ⟨a, y⟩‖ / ‖Complex.Gamma ⟨b, y⟩‖ ≤
      (∏ j ∈ Finset.range N, ((a + j) / (b + j))) *
        (∏ j ∈ Finset.range N, (‖(⟨b, y⟩ : ℂ) + j‖ / ‖(⟨a, y⟩ : ℂ) + j‖)) *
        (Real.Gamma a / Real.Gamma b) := by
  have hb : 0 < b := ha.trans hab
  let s : ℂ := ⟨a, y⟩
  let w : ℂ := ⟨b, y⟩
  have hw_g : w.Gamma ≠ 0 := Complex.Gamma_ne_zero_of_re_pos (by simp [w, hb])
  have hrb_g : Real.Gamma b ≠ 0 := (Real.Gamma_pos_of_pos hb).ne'
  have h_lhs : Tendsto (fun n => ‖Complex.GammaSeq s n‖ / ‖Complex.GammaSeq w n‖)
      atTop (𝓝 (‖Complex.Gamma s‖ / ‖Complex.Gamma w‖)) :=
    ((Complex.GammaSeq_tendsto_Gamma s).norm).div
      ((Complex.GammaSeq_tendsto_Gamma w).norm) (norm_ne_zero_iff.mpr hw_g)
  let C : ℝ := (∏ j ∈ Finset.range N, ((a + j) / (b + j))) *
    (∏ j ∈ Finset.range N, (‖w + j‖ / ‖s + j‖))
  have h_rhs : Tendsto (fun n => C * (Real.GammaSeq a n / Real.GammaSeq b n))
      atTop (𝓝 (C * (Real.Gamma a / Real.Gamma b))) :=
    tendsto_const_nhds.mul ((Real.GammaSeq_tendsto_Gamma a).div
      (Real.GammaSeq_tendsto_Gamma b) hrb_g)
  refine le_of_tendsto_of_tendsto h_lhs h_rhs (eventually_atTop.mpr ⟨max N 1, fun n hn_ge => ?_⟩)
  have hn_pos : 0 < n := Nat.lt_of_lt_of_le (Nat.succ_pos 0) ((le_max_right N 1).trans hn_ge)
  have hNn : N ≤ n + 1 := ((le_max_left N 1).trans hn_ge).trans (Nat.le_succ n)
  have hn_r : 0 < (n : ℝ) := Nat.cast_pos.mpr hn_pos
  have hc_ratio : ∀ (r : ℝ), 0 < r →
      ‖Complex.GammaSeq (⟨r, y⟩ : ℂ) n‖ =
        (n : ℝ) ^ r * (n.factorial : ℝ) / ∏ j ∈ Finset.range (n + 1), ‖(⟨r, y⟩ : ℂ) + j‖ := by
    intro r _
    unfold Complex.GammaSeq
    rw [norm_div, norm_mul, ← Complex.ofReal_natCast, Complex.norm_cpow_eq_rpow_re_of_pos hn_r,
      Complex.norm_natCast, norm_prod]
  have h_cs : ‖Complex.GammaSeq s n‖ / ‖Complex.GammaSeq w n‖ =
      ((n : ℝ) ^ a / (n : ℝ) ^ b) *
        ∏ j ∈ Finset.range (n + 1), (‖w + j‖ / ‖s + j‖) := by
    dsimp only [s, w]
    rw [hc_ratio a ha, hc_ratio b hb, Finset.prod_div_distrib]
    have hp1 : ∏ j ∈ Finset.range (n + 1), ‖(⟨a, y⟩ : ℂ) + j‖ ≠ 0 :=
      (Finset.prod_pos fun j _ => norm_add_nat_pos ha y j).ne'
    have hp2 : ∏ j ∈ Finset.range (n + 1), ‖(⟨b, y⟩ : ℂ) + j‖ ≠ 0 :=
      (Finset.prod_pos fun j _ => norm_add_nat_pos hb y j).ne'
    have hnb0 : (n : ℝ) ^ b ≠ 0 := (Real.rpow_pos_of_pos hn_r b).ne'
    have hfac0 : (n.factorial : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.factorial_ne_zero n)
    field_simp [hp1, hp2, hnb0, hfac0]
  have h_rs : Real.GammaSeq a n / Real.GammaSeq b n =
      ((n : ℝ) ^ a / (n : ℝ) ^ b) *
        ∏ j ∈ Finset.range (n + 1), ((b + j) / (a + j)) := by
    unfold Real.GammaSeq
    rw [Finset.prod_div_distrib]
    have hp1 : ∏ j ∈ Finset.range (n + 1), (a + (j : ℝ)) ≠ 0 :=
      (Finset.prod_pos fun j _ => by positivity).ne'
    have hp2 : ∏ j ∈ Finset.range (n + 1), (b + (j : ℝ)) ≠ 0 :=
      (Finset.prod_pos fun j _ => by positivity).ne'
    have hnb0 : (n : ℝ) ^ b ≠ 0 := (Real.rpow_pos_of_pos hn_r b).ne'
    have hfac0 : (n.factorial : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.factorial_ne_zero n)
    field_simp [hp1, hp2, hnb0, hfac0]
  have h_cancel :
      C * ∏ j ∈ Finset.range (n + 1), ((b + j) / (a + j)) =
        (∏ j ∈ Finset.range N, (‖w + j‖ / ‖s + j‖)) *
          ∏ j ∈ Finset.Ico N (n + 1), ((b + j) / (a + j)) := by
    dsimp [C]
    rw [← Finset.prod_range_mul_prod_Ico (fun j => (b + (j : ℝ)) / (a + (j : ℝ))) hNn]
    have h_id : (∏ j ∈ Finset.range N, ((a + j) / (b + j))) *
        (∏ j ∈ Finset.range N, ((b + j) / (a + j))) = 1 := by
      rw [← Finset.prod_mul_distrib]
      exact Finset.prod_eq_one fun j _ => by
        have ha0 : a + (j : ℝ) ≠ 0 := by positivity
        have hb0 : b + (j : ℝ) ≠ 0 := by positivity
        field_simp [ha0, hb0]
    calc (∏ j ∈ Finset.range N, ((a + j) / (b + j))) *
            (∏ j ∈ Finset.range N, (‖w + j‖ / ‖s + j‖)) *
            ((∏ j ∈ Finset.range N, ((b + j) / (a + j))) *
              (∏ j ∈ Finset.Ico N (n + 1), ((b + j) / (a + j))))
        = ((∏ j ∈ Finset.range N, ((a + j) / (b + j))) *
            (∏ j ∈ Finset.range N, ((b + j) / (a + j)))) *
            ((∏ j ∈ Finset.range N, (‖w + j‖ / ‖s + j‖)) *
              (∏ j ∈ Finset.Ico N (n + 1), ((b + j) / (a + j)))) := by ring
      _ = _ := by rw [h_id, one_mul]
  dsimp only
  rw [h_cs, h_rs, ← mul_assoc, mul_comm C ((n : ℝ) ^ a / (n : ℝ) ^ b), mul_assoc, h_cancel,
    ← Finset.prod_range_mul_prod_Ico (fun j => ‖w + j‖ / ‖s + j‖) hNn]
  refine mul_le_mul_of_nonneg_left ?_ (div_nonneg (Real.rpow_nonneg hn_r.le a) (Real.rpow_nonneg hn_r.le b))
  refine mul_le_mul_of_nonneg_left ?_ (Finset.prod_nonneg fun _ _ => div_nonneg (norm_nonneg _) (norm_nonneg _))
  exact Finset.prod_le_prod₀ (fun j _ => div_nonneg (norm_nonneg _) (norm_nonneg _))
    fun j _ => norm_ratio_le_real_ratio ha hab y j

private lemma tendsto_norm_Gamma_div_zero_of_pos_lt {a b : ℝ} (ha : 0 < a) (hab : a < b) :
    ∀ ε : ℝ, 0 < ε → ∃ Y : ℝ, 0 < Y ∧ ∀ y : ℝ, Y ≤ |y| →
      ‖Complex.Gamma ⟨a, y⟩‖ / ‖Complex.Gamma ⟨b, y⟩‖ < ε := by
  intro ε hε
  have hb : 0 < b := ha.trans hab
  have hga : 0 < Real.Gamma a := Real.Gamma_pos_of_pos ha
  have hgb : 0 < Real.Gamma b := Real.Gamma_pos_of_pos hb
  have hgr : 0 < Real.Gamma a / Real.Gamma b := div_pos hga hgb
  obtain ⟨N, hN⟩ := prod_ratio_tendsto_zero ha hab (ε / (4 * (Real.Gamma a / Real.Gamma b))) (by positivity)
  let Y : ℝ := (b + N + 1) * ((N : ℝ) + 1) + 1
  have hY_pos : 0 < Y := by positivity
  refine ⟨Y, hY_pos, fun y hy => ?_⟩
  have hy_pos : 0 < |y| := hY_pos.trans_le hy
  have hy_sq : 0 < y ^ 2 := sq_pos_iff.mpr (abs_pos.mp hy_pos)
  have hpref : ∏ j ∈ Finset.range N, (‖(⟨b, y⟩ : ℂ) + j‖ / ‖(⟨a, y⟩ : ℂ) + j‖) ≤ 4 := by
    have hterm : ∀ j ∈ Finset.range N,
        ‖(⟨b, y⟩ : ℂ) + j‖ / ‖(⟨a, y⟩ : ℂ) + j‖ ≤ 1 + 1 / ((N : ℝ) + 1) := by
      intro j hj
      have hjlt : j < N := Finset.mem_range.mp hj
      have hbj_le : b + (j : ℝ) ≤ |y| / ((N : ℝ) + 1) := by
        rw [le_div_iff₀ (by positivity)]
        have h1 : b + (j : ℝ) ≤ b + N + 1 := by linarith [show (j : ℝ) ≤ (N : ℝ) by exact_mod_cast hjlt.le]
        have h2 : (b + N + 1) * ((N : ℝ) + 1) ≤ |y| := by linarith
        nlinarith [show (0 : ℝ) < (N : ℝ) + 1 by positivity]
      have hbj_sq : (b + (j : ℝ)) ^ 2 ≤ y ^ 2 / ((N : ℝ) + 1) := by
        have hsq1 : (b + (j : ℝ)) ^ 2 ≤ (|y| / ((N : ℝ) + 1)) ^ 2 := by
          have habs : 0 ≤ b + (j : ℝ) := by positivity
          nlinarith
        have hsq2 : (|y| / ((N : ℝ) + 1)) ^ 2 = y ^ 2 / ((N : ℝ) + 1) ^ 2 := by
          rw [div_pow, sq_abs]
        have hdiv : y ^ 2 / ((N : ℝ) + 1) ^ 2 ≤ y ^ 2 / ((N : ℝ) + 1) := by
          apply div_le_div_of_nonneg_left hy_sq.le (by positivity)
          have hN1 : (1 : ℝ) ≤ (N : ℝ) + 1 := by linarith [Nat.cast_nonneg (α := ℝ) N]
          nlinarith
        exact hsq1.trans (hsq2.symm ▸ hdiv)
      have hsq_num : ‖(⟨b, y⟩ : ℂ) + j‖ ^ 2 ≤ (1 + 1 / ((N : ℝ) + 1)) * ‖(⟨a, y⟩ : ℂ) + j‖ ^ 2 := by
        rw [← Complex.normSq_eq_norm_sq, ← Complex.normSq_eq_norm_sq]
        have n1 : Complex.normSq ((⟨b, y⟩ : ℂ) + j) = (b + j) ^ 2 + y ^ 2 := by
          simp [Complex.normSq_apply]; ring
        have n2 : Complex.normSq ((⟨a, y⟩ : ℂ) + j) = (a + j) ^ 2 + y ^ 2 := by
          simp [Complex.normSq_apply]; ring
        rw [n1, n2]
        have hn2_ge : y ^ 2 ≤ (a + (j : ℝ)) ^ 2 + y ^ 2 := le_add_of_nonneg_left (sq_nonneg _)
        calc (b + (j : ℝ)) ^ 2 + y ^ 2
            ≤ y ^ 2 / ((N : ℝ) + 1) + y ^ 2 := by linarith
          _ = (1 + 1 / ((N : ℝ) + 1)) * y ^ 2 := by ring
          _ ≤ (1 + 1 / ((N : ℝ) + 1)) * ((a + (j : ℝ)) ^ 2 + y ^ 2) :=
              mul_le_mul_of_nonneg_left hn2_ge (by positivity)
      have ha_norm := norm_add_nat_pos ha y j
      have hratio_sq : (‖(⟨b, y⟩ : ℂ) + j‖ / ‖(⟨a, y⟩ : ℂ) + j‖) ^ 2 ≤ (1 + 1 / ((N : ℝ) + 1)) ^ 2 := by
        rw [div_pow, div_le_iff₀ (sq_pos_of_pos ha_norm)]
        have h1u : 1 + 1 / ((N : ℝ) + 1) ≤ (1 + 1 / ((N : ℝ) + 1)) ^ 2 := by
          nlinarith [show (0 : ℝ) ≤ 1 / ((N : ℝ) + 1) by positivity]
        exact hsq_num.trans (mul_le_mul_of_nonneg_right h1u (sq_nonneg _))
      have hn1 : 0 ≤ ‖(⟨b, y⟩ : ℂ) + j‖ / ‖(⟨a, y⟩ : ℂ) + j‖ := div_nonneg (norm_nonneg _) (norm_nonneg _)
      have hn2 : 0 ≤ 1 + 1 / ((N : ℝ) + 1) := by positivity
      nlinarith
    have hprod_pow : ∏ j ∈ Finset.range N, (‖(⟨b, y⟩ : ℂ) + j‖ / ‖(⟨a, y⟩ : ℂ) + j‖) ≤
        (1 + 1 / ((N : ℝ) + 1)) ^ N := by
      calc ∏ j ∈ Finset.range N, (‖(⟨b, y⟩ : ℂ) + j‖ / ‖(⟨a, y⟩ : ℂ) + j‖)
          ≤ ∏ _j ∈ Finset.range N, (1 + 1 / ((N : ℝ) + 1)) :=
            Finset.prod_le_prod₀ (fun j _ => div_nonneg (norm_nonneg _) (norm_nonneg _)) hterm
        _ = (1 + 1 / ((N : ℝ) + 1)) ^ N := by rw [Finset.prod_const, Finset.card_range]
    have hexp_bound : (1 + 1 / ((N : ℝ) + 1)) ^ N ≤ Real.exp 1 := by
      calc (1 + 1 / ((N : ℝ) + 1)) ^ N
          ≤ (Real.exp (1 / ((N : ℝ) + 1))) ^ N :=
            pow_le_pow_left₀ (by positivity) (by linarith [Real.add_one_le_exp (1 / ((N : ℝ) + 1))]) N
        _ = Real.exp ((N : ℝ) * (1 / ((N : ℝ) + 1))) := by rw [← Real.exp_nat_mul]
        _ ≤ Real.exp 1 := by
            rw [Real.exp_le_exp]
            rw [mul_one_div, div_le_one (by positivity)]
            linarith
    exact hprod_pow.trans (hexp_bound.trans exp_one_lt_four.le)
  have hmain := norm_Gamma_div_Gamma_le_of_lt ha hab y N
  have hprod_pos : 0 < ∏ j ∈ Finset.range N, ((a + j) / (b + j)) :=
    Finset.prod_pos fun j _ => div_pos (by positivity) (by positivity)
  have hlead : (∏ j ∈ Finset.range N, ((a + j) / (b + j))) * (Real.Gamma a / Real.Gamma b) < ε / 4 := by
    calc (∏ j ∈ Finset.range N, ((a + j) / (b + j))) * (Real.Gamma a / Real.Gamma b)
        < (ε / (4 * (Real.Gamma a / Real.Gamma b))) * (Real.Gamma a / Real.Gamma b) :=
          mul_lt_mul_of_pos_right hN hgr
      _ = ε / 4 := by field_simp [hgr.ne']
  calc ‖Complex.Gamma ⟨a, y⟩‖ / ‖Complex.Gamma ⟨b, y⟩‖
      ≤ ((∏ j ∈ Finset.range N, ((a + j) / (b + j))) * (Real.Gamma a / Real.Gamma b)) *
          (∏ j ∈ Finset.range N, (‖(⟨b, y⟩ : ℂ) + j‖ / ‖(⟨a, y⟩ : ℂ) + j‖)) :=
        hmain.trans_eq (by ring)
    _ ≤ ((∏ j ∈ Finset.range N, ((a + j) / (b + j))) * (Real.Gamma a / Real.Gamma b)) * 4 := by
          apply mul_le_mul_of_nonneg_left hpref (mul_nonneg hprod_pos.le hgr.le)
    _ < (ε / 4) * 4 := by linarith
    _ = ε := by ring

private lemma Gamma_add_nat_of_im_ne_zero (z : ℂ) (hz : z.im ≠ 0) (m : ℕ) :
    Complex.Gamma (z + m) = (∏ j ∈ Finset.range m, (z + j)) * Complex.Gamma z := by
  induction m with
  | zero => simp
  | succ m ih =>
    have hzm : z + (m : ℕ) ≠ 0 := by
      intro h
      have him := congr_arg Complex.im h
      simp only [Complex.add_im, Complex.natCast_im, add_zero, Complex.zero_im] at him
      exact hz him
    rw [Nat.cast_succ, ← add_assoc, Complex.Gamma_add_one _ hzm, ih, Finset.prod_range_succ]
    ring

theorem tendsto_norm_Gamma_div_zero_of_re_lt {a b : ℝ} (hab : a < b) :
    ∀ ε : ℝ, 0 < ε → ∃ Y : ℝ, 0 < Y ∧ ∀ y : ℝ, Y ≤ |y| →
      ‖Complex.Gamma ⟨a, y⟩‖ / ‖Complex.Gamma ⟨b, y⟩‖ < ε := by
  intro ε hε
  let m : ℕ := ⌊max 0 (-a)⌋₊ + 1
  have ham : 0 < a + (m : ℝ) := by
    have hceil : max 0 (-a) < (m : ℝ) := Nat.lt_succ_floor (max 0 (-a))
    linarith [le_max_right (0 : ℝ) (-a)]
  have hbm : a + (m : ℝ) < b + (m : ℝ) := by linarith
  have hpow2 : (0 : ℝ) < (2 : ℝ) ^ m := by positivity
  obtain ⟨Y₁, hY₁, hpos_bound⟩ := tendsto_norm_Gamma_div_zero_of_pos_lt ham hbm (ε / (2 ^ m)) (div_pos hε hpow2)
  let Y : ℝ := max Y₁ (max (|a| + m + 1) (|b| + m + 1))
  refine ⟨Y, by positivity, fun y hy => ?_⟩
  have hy_pos : 0 < |y| := lt_of_lt_of_le (by positivity) hy
  have hy_ne : y ≠ 0 := abs_pos.mp hy_pos
  have hy1 : Y₁ ≤ |y| := (le_max_left _ _).trans hy
  have hya : |a| + m + 1 ≤ |y| := (le_max_left _ _).trans ((le_max_right _ _).trans hy)
  have hyb : |b| + m + 1 ≤ |y| := (le_max_right _ _).trans ((le_max_right _ _).trans hy)
  let z : ℂ := ⟨a, y⟩
  let w : ℂ := ⟨b, y⟩
  have hz_im : z.im ≠ 0 := hy_ne
  have hw_im : w.im ≠ 0 := hy_ne
  have hzm_eq : z + (m : ℕ) = (⟨a + m, y⟩ : ℂ) := by apply Complex.ext <;> simp [z]
  have hwm_eq : w + (m : ℕ) = (⟨b + m, y⟩ : ℂ) := by apply Complex.ext <;> simp [w]
  have hpz0 : ∏ j ∈ Finset.range m, ‖z + j‖ ≠ 0 := by
    refine (Finset.prod_pos fun j _ => norm_pos_iff.mpr fun h => ?_).ne'
    have him := congr_arg Complex.im h
    simp only [z, Complex.add_im, Complex.natCast_im, add_zero, Complex.zero_im] at him
    exact hy_ne him
  have hpw0 : ∏ j ∈ Finset.range m, ‖w + j‖ ≠ 0 := by
    refine (Finset.prod_pos fun j _ => norm_pos_iff.mpr fun h => ?_).ne'
    have him := congr_arg Complex.im h
    simp only [w, Complex.add_im, Complex.natCast_im, add_zero, Complex.zero_im] at him
    exact hy_ne him
  have hgw0 : ‖Complex.Gamma (w + (m : ℕ))‖ ≠ 0 := by
    rw [hwm_eq]
    exact norm_ne_zero_iff.mpr (Complex.Gamma_ne_zero_of_re_pos (by simp; linarith))
  have hGw_ne : ‖Complex.Gamma w‖ ≠ 0 := by
    intro h0
    have hgm := congr_arg norm (Gamma_add_nat_of_im_ne_zero w hw_im m)
    rw [norm_mul, h0, mul_zero] at hgm
    exact hgw0 hgm
  have hratio_eq :
      ‖Complex.Gamma z‖ / ‖Complex.Gamma w‖ =
        (∏ j ∈ Finset.range m, (‖w + j‖ / ‖z + j‖)) *
          (‖Complex.Gamma (z + (m : ℕ))‖ / ‖Complex.Gamma (w + (m : ℕ))‖) := by
    have hz_id := congr_arg norm (Gamma_add_nat_of_im_ne_zero z hz_im m)
    have hw_id := congr_arg norm (Gamma_add_nat_of_im_ne_zero w hw_im m)
    rw [norm_mul, norm_prod] at hz_id hw_id
    rw [Finset.prod_div_distrib]
    calc ‖Complex.Gamma z‖ / ‖Complex.Gamma w‖
        = ((∏ j ∈ Finset.range m, ‖z + j‖) * ‖Complex.Gamma z‖ / (∏ j ∈ Finset.range m, ‖z + j‖)) /
            ((∏ j ∈ Finset.range m, ‖w + j‖) * ‖Complex.Gamma w‖ / (∏ j ∈ Finset.range m, ‖w + j‖)) := by
            field_simp [hpz0, hpw0, hGw_ne]
      _ = (Complex.Gamma (z + (m : ℕ)) |> norm) / (∏ j ∈ Finset.range m, ‖z + j‖) /
            ((Complex.Gamma (w + (m : ℕ)) |> norm) / (∏ j ∈ Finset.range m, ‖w + j‖)) := by
            rw [← hz_id, ← hw_id]
      _ = _ := by field_simp [hpz0, hpw0, hgw0]
  have hpref : ∏ j ∈ Finset.range m, (‖w + j‖ / ‖z + j‖) ≤ (2 : ℝ) ^ m := by
    have hterm : ∀ j ∈ Finset.range m, ‖w + j‖ / ‖z + j‖ ≤ 2 := by
      intro j hj
      have hjle : (j : ℝ) ≤ (m : ℝ) := by exact_mod_cast (Finset.mem_range.mp hj).le
      have hbj_le : |b + (j : ℝ)| ≤ |y| := by
        calc |b + (j : ℝ)| ≤ |b| + |(j : ℝ)| := abs_add_le _ _
          _ = |b| + (j : ℝ) := by rw [Nat.abs_cast]
          _ ≤ |y| := by linarith
      have hbj_sq : (b + (j : ℝ)) ^ 2 ≤ y ^ 2 := by
        have h := sq_le_sq.mpr (hbj_le.trans (le_abs_self |y|))
        simpa [sq_abs] using h
      have hsq : ‖w + j‖ ^ 2 ≤ 4 * ‖z + j‖ ^ 2 := by
        rw [← Complex.normSq_eq_norm_sq, ← Complex.normSq_eq_norm_sq]
        have n1 : Complex.normSq (w + j) = (b + j) ^ 2 + y ^ 2 := by
          simp [w, Complex.normSq_apply]; ring
        have n2 : Complex.normSq (z + j) = (a + j) ^ 2 + y ^ 2 := by
          simp [z, Complex.normSq_apply]; ring
        rw [n1, n2]
        nlinarith [sq_nonneg (a + (j : ℝ)), sq_nonneg y]
      have hzn : 0 < ‖z + j‖ := by
        refine norm_pos_iff.mpr fun h => ?_
        have him := congr_arg Complex.im h
        simp only [z, Complex.add_im, Complex.natCast_im, add_zero, Complex.zero_im] at him
        exact hy_ne him
      have hn : 0 ≤ ‖w + j‖ := norm_nonneg _
      have hwn : ‖w + j‖ ≤ 2 * ‖z + j‖ := by nlinarith
      exact (div_le_iff₀ hzn).mpr hwn
    calc ∏ j ∈ Finset.range m, (‖w + j‖ / ‖z + j‖)
        ≤ ∏ _j ∈ Finset.range m, (2 : ℝ) :=
          Finset.prod_le_prod₀ (fun j _ => div_nonneg (norm_nonneg _) (norm_nonneg _)) hterm
      _ = (2 : ℝ) ^ m := by rw [Finset.prod_const, Finset.card_range]
  have hpos_m : ‖Complex.Gamma (z + (m : ℕ))‖ / ‖Complex.Gamma (w + (m : ℕ))‖ < ε / (2 ^ m) := by
    rw [hzm_eq, hwm_eq]
    exact hpos_bound y hy1
  rw [hratio_eq]
  calc (∏ j ∈ Finset.range m, (‖w + j‖ / ‖z + j‖)) *
          (‖Complex.Gamma (z + (m : ℕ))‖ / ‖Complex.Gamma (w + (m : ℕ))‖)
      ≤ (2 : ℝ) ^ m * (‖Complex.Gamma (z + (m : ℕ))‖ / ‖Complex.Gamma (w + (m : ℕ))‖) :=
        mul_le_mul_of_nonneg_right hpref (div_nonneg (norm_nonneg _) (norm_nonneg _))
    _ < (2 : ℝ) ^ m * (ε / (2 ^ m)) := mul_lt_mul_of_pos_left hpos_m hpow2
    _ = ε := by field_simp [hpow2.ne']

theorem norm_chiFactor_lt_one_of_gt_half {σ : ℝ} (hσ : 1 / 2 < σ) :
    ∃ T : ℝ, 0 < T ∧ ∀ t : ℝ, T ≤ |t| → ‖chiFactor (⟨σ, t⟩ : ℂ)‖ < 1 := by
  let a : ℝ := (1 - σ) / 2
  let b : ℝ := σ / 2
  have hab : a < b := by dsimp [a, b]; linarith
  have hpi : 0 < Real.pi := Real.pi_pos
  have hpre_pos : 0 < Real.pi ^ (σ - 1 / 2) := Real.rpow_pos_of_pos hpi _
  obtain ⟨Y, hY, hbound⟩ := tendsto_norm_Gamma_div_zero_of_re_lt hab (Real.pi ^ (σ - 1 / 2))⁻¹ (inv_pos.mpr hpre_pos)
  refine ⟨2 * Y, by positivity, fun t ht => ?_⟩
  have hy_ge : Y ≤ |t / 2| := by
    rw [abs_div, abs_of_pos (two_pos : (0 : ℝ) < 2)]
    linarith
  let s : ℂ := ⟨σ, t⟩
  have h1s_div : (1 - s) / 2 = conj (⟨a, t / 2⟩ : ℂ) := by
    apply Complex.ext
    · simp [a, s]
    · simp [s]; ring
  have hs_div : s / 2 = (⟨b, t / 2⟩ : ℂ) := by
    apply Complex.ext <;> simp [b, s]
  have hpow_norm : ‖(Real.pi : ℂ) ^ (-(1 - s) / 2)‖ / ‖(Real.pi : ℂ) ^ (-s / 2)‖ =
      Real.pi ^ (σ - 1 / 2) := by
    rw [Complex.norm_cpow_eq_rpow_re_of_pos hpi, Complex.norm_cpow_eq_rpow_re_of_pos hpi,
      ← Real.rpow_sub hpi]
    congr 1
    simp [s]; ring
  have hchi_norm : ‖chiFactor s‖ =
      Real.pi ^ (σ - 1 / 2) * (‖Complex.Gamma ⟨a, t / 2⟩‖ / ‖Complex.Gamma ⟨b, t / 2⟩‖) := by
    unfold chiFactor
    rw [Complex.Gammaℝ_def, Complex.Gammaℝ_def, norm_div, norm_mul, norm_mul,
      show ((-(1 - s) / 2) : ℂ) = -(1 - s) / 2 from rfl]
    have hconj_n : ‖Complex.Gamma ((1 - s) / 2)‖ = ‖Complex.Gamma ⟨a, t / 2⟩‖ := by
      rw [h1s_div, Complex.Gamma_conj, Complex.norm_conj]
    rw [hconj_n, hs_div]
    calc (‖(Real.pi : ℂ) ^ (-(1 - s) / 2)‖ * ‖Complex.Gamma ⟨a, t / 2⟩‖) /
          (‖(Real.pi : ℂ) ^ (-s / 2)‖ * ‖Complex.Gamma ⟨b, t / 2⟩‖)
        = (‖(Real.pi : ℂ) ^ (-(1 - s) / 2)‖ / ‖(Real.pi : ℂ) ^ (-s / 2)‖) *
            (‖Complex.Gamma ⟨a, t / 2⟩‖ / ‖Complex.Gamma ⟨b, t / 2⟩‖) := by ring
      _ = Real.pi ^ (σ - 1 / 2) * (‖Complex.Gamma ⟨a, t / 2⟩‖ / ‖Complex.Gamma ⟨b, t / 2⟩‖) := by
          rw [hpow_norm]
  rw [hchi_norm]
  calc Real.pi ^ (σ - 1 / 2) * (‖Complex.Gamma ⟨a, t / 2⟩‖ / ‖Complex.Gamma ⟨b, t / 2⟩‖)
      < Real.pi ^ (σ - 1 / 2) * (Real.pi ^ (σ - 1 / 2))⁻¹ :=
        mul_lt_mul_of_pos_left (hbound (t / 2) hy_ge) hpre_pos
    _ = 1 := mul_inv_cancel₀ hpre_pos.ne'

private lemma Gammaℝ_ne_zero_of_im_ne_zero {s : ℂ} (him : s.im ≠ 0) : s.Gammaℝ ≠ 0 := by
  intro h
  obtain ⟨n, hn⟩ := Complex.Gammaℝ_eq_zero_iff.mp h
  have h0 := congr_arg Complex.im hn
  simp only [Complex.neg_im, Complex.mul_im, Complex.re_ofNat, Complex.im_ofNat, Complex.natCast_im,
    Complex.natCast_re, mul_zero, zero_mul, add_zero, neg_zero] at h0
  exact him h0

theorem norm_chiFactor_gt_one_of_lt_half {σ : ℝ} (hσ : σ < 1 / 2) :
    ∃ T : ℝ, 0 < T ∧ ∀ t : ℝ, T ≤ |t| → 1 < ‖chiFactor (⟨σ, t⟩ : ℂ)‖ := by
  obtain ⟨T, hT, hlt⟩ := norm_chiFactor_lt_one_of_gt_half (σ := 1 - σ) (by linarith)
  refine ⟨T, hT, fun t ht => ?_⟩
  let s : ℂ := ⟨σ, t⟩
  have htim : t ≠ 0 := abs_pos.mp (lt_of_lt_of_le hT ht)
  have hGs : s.Gammaℝ ≠ 0 := Gammaℝ_ne_zero_of_im_ne_zero (by simp [s, htim])
  have hG1s : (1 - s).Gammaℝ ≠ 0 := Gammaℝ_ne_zero_of_im_ne_zero (by simp [s, htim])
  have hmul : ‖chiFactor (1 - s)‖ * ‖chiFactor s‖ = 1 := by
    rw [← norm_mul, chiFactor_one_sub_mul hGs hG1s, norm_one]
  have h1s_conj : 1 - s = conj (⟨1 - σ, t⟩ : ℂ) := by apply Complex.ext <;> simp [s]
  have h_1s_lt : ‖chiFactor (1 - s)‖ < 1 := by
    rw [h1s_conj, chiFactor_conj, Complex.norm_conj]
    exact hlt t ht
  have h_pos : 0 < ‖chiFactor (1 - s)‖ := by
    unfold chiFactor
    rw [norm_div]
    exact div_pos (norm_pos_iff.mpr (by rw [sub_sub_cancel]; exact hGs)) (norm_pos_iff.mpr hG1s)
  nlinarith

theorem norm_chiFactor_ne_one_of_ne_half {σ : ℝ} (hne : σ ≠ 1 / 2) :
    ∃ T : ℝ, 0 < T ∧ ∀ t : ℝ, T ≤ |t| → ‖chiFactor (⟨σ, t⟩ : ℂ)‖ ≠ 1 := by
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · obtain ⟨T, hT, hgt1⟩ := norm_chiFactor_gt_one_of_lt_half hlt
    exact ⟨T, hT, fun t ht => (hgt1 t ht).ne'⟩
  · obtain ⟨T, hT, hlt1⟩ := norm_chiFactor_lt_one_of_gt_half hgt
    exact ⟨T, hT, fun t ht => (hlt1 t ht).ne⟩

/-! ## R7: Honest algebraic/structural bridge to `FVLT.AlphaAmplitudeV1`

Scope note: `FVLT.AlphaAmplitudeV1` operates on a single positive integer modulus `m.n3`
with discrete rational rosette phases and signed scale `n6`. The theorems below formalize the
exact parameter dictionary (`α ↔ -σ`, twin map `α ↦ -1 - α` fixed uniquely at `α = -1/2`,
radius equality with `‖wSigmaT σ t m.n3‖`, `-n6` sign flip, phase invariance under dividing by
radius, and finite conjugation `z2 = star z1`). We do **not** claim an analytic Euler-product
or functional-equation stretch correspondence (`FVLTAlphaAmplitudeV1` has neither). -/

def alphaTwin (α : ℝ) : ℝ := -1 - α

theorem alphaTwin_involutive (α : ℝ) : alphaTwin (alphaTwin α) = α := by
  unfold alphaTwin; ring

theorem alphaTwin_fixed_iff (α : ℝ) : alphaTwin α = α ↔ α = -(1 / 2 : ℝ) := by
  unfold alphaTwin
  constructor <;> intro h <;> linarith

theorem alphaTwin_conj_sigmaTwin (σ : ℝ) : alphaTwin (-σ) = -(1 - σ) := by
  unfold alphaTwin; ring

theorem alpha_radius_eq_norm_wSigmaT (m : FVLT.CoupledPointV1.Modulus) (σ t : ℝ) :
    FVLT.AlphaAmplitudeV1.radius m (-σ) 1 = ‖wSigmaT σ t m.n3‖ := by
  rw [FVLT.AlphaAmplitudeV1.radius, one_mul, norm_wSigmaT σ t m.positive]

theorem alpha_norm_point_eq_scaled_norm_wSigmaT
    (m : FVLT.CoupledPointV1.Modulus) (σ t n6 : ℝ) (k s : ℤ) :
    ‖FVLT.AlphaAmplitudeV1.point m (-σ) n6 k s‖ = |n6| * ‖wSigmaT σ t m.n3‖ := by
  rw [FVLT.AlphaAmplitudeV1.norm_point, norm_wSigmaT σ t m.positive]

theorem alpha_neg_flip_point
    (m : FVLT.CoupledPointV1.Modulus) (α n6 : ℝ) (k s : ℤ) :
    FVLT.AlphaAmplitudeV1.point m α (-n6) k s =
      -FVLT.AlphaAmplitudeV1.point m α n6 k s := by
  unfold FVLT.AlphaAmplitudeV1.point FVLT.AlphaAmplitudeV1.radius
  push_cast
  ring

theorem alpha_neg_flip_norm
    (m : FVLT.CoupledPointV1.Modulus) (α n6 : ℝ) (k s : ℤ) :
    ‖FVLT.AlphaAmplitudeV1.point m α (-n6) k s‖ =
      ‖FVLT.AlphaAmplitudeV1.point m α n6 k s‖ := by
  rw [alpha_neg_flip_point, norm_neg]

theorem alpha_neg_flip_contactFinset (n1 s : ℕ) (arm : Bool) (α n6 : ℝ) (h : n6 ≠ 0) :
    FVLT.AlphaAmplitudeV1.contactFinset n1 s arm α (-n6) =
      FVLT.AlphaAmplitudeV1.contactFinset n1 s arm α n6 := by
  rw [FVLT.AlphaAmplitudeV1.contactFinset_transport _ _ _ _ _ (neg_ne_zero.mpr h),
    FVLT.AlphaAmplitudeV1.contactFinset_transport _ _ _ _ _ h]

theorem alpha_phase_independent_of_sigma
    (m : FVLT.CoupledPointV1.Modulus) (σ t n6 : ℝ) (k s : ℤ) (hn6 : n6 ≠ 0) :
    FVLT.AlphaAmplitudeV1.point m (-σ) n6 k s / ((n6 * ‖wSigmaT σ t m.n3‖ : ℝ) : ℂ) =
      FVLT.AlphaAmplitudeV1.phase m k s := by
  have hrad : FVLT.AlphaAmplitudeV1.radius m (-σ) n6 = n6 * ‖wSigmaT σ t m.n3‖ := by
    rw [FVLT.AlphaAmplitudeV1.radius, norm_wSigmaT σ t m.positive]
  rw [← hrad]
  exact FVLT.AlphaAmplitudeV1.point_div_radius m (-σ) n6 k s hn6

theorem alpha_twin_radius_eq_iff (m : FVLT.CoupledPointV1.Modulus) (hm : 2 ≤ m.n3)
    (α n6 : ℝ) (hn6 : n6 ≠ 0) :
    FVLT.AlphaAmplitudeV1.radius m α n6 =
      FVLT.AlphaAmplitudeV1.radius m (alphaTwin α) n6 ↔ α = -(1 / 2 : ℝ) := by
  unfold FVLT.AlphaAmplitudeV1.radius
  have hn3_gt : (1 : ℝ) < (m.n3 : ℝ) := by exact_mod_cast (show 1 < m.n3 by omega)
  constructor
  · intro h
    have hrpow : (m.n3 : ℝ) ^ α = (m.n3 : ℝ) ^ alphaTwin α := mul_left_cancel₀ hn6 h
    have hexp : α = alphaTwin α := (Real.rpow_right_inj (zero_lt_one.trans hn3_gt) hn3_gt.ne').mp hrpow
    exact (alphaTwin_fixed_iff α).mp hexp.symm
  · intro h
    have hexp : α = alphaTwin α := ((alphaTwin_fixed_iff α).mpr h).symm
    rw [← hexp]

theorem alpha_z2_eq_conj_z1 (m : FVLT.CoupledPointV1.Modulus) (σ n6 : ℝ) (t1 t2 s : ℤ) :
    FVLT.AlphaAmplitudeV1.z2 m (-σ) n6 t1 t2 s =
      star (FVLT.AlphaAmplitudeV1.z1 m (-σ) n6 t1 t2 s) :=
  FVLT.AlphaAmplitudeV1.z2_eq_conj_z1 m (-σ) n6 t1 t2 s

end RHConnections.CoherentEnergyFlip
