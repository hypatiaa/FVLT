import Verified
import CoherentEnergyMeasure
import CoherentEnergyRHBridge
import CoherentEnergyRadiusMeasure
import CoherentEnergySigmaBridge
import CoherentEnergyReflectionStrip

/-!
# Complex rotated-centre Poisson measure and critical-line `(σ, t)` family (R4)

Generalises `RHConnections.CoherentEnergyRadius` from real centres `ρ_p ∈ [0, 1)` to arbitrary
**complex** inside centres `w : ℕ → ℂ` with `‖w p‖ < 1` at each prime `p`:

* `complexPoissonKernel w θ = (1 - ‖w‖²) / ‖exp(iθ) - w‖²` with complex Fourier moments
  `E[z^m] = w^m` (`m ≥ 0`) and `E[z^m] = conj(w)^{|m|}` (`m < 0`).
* Orthogonal local modes `phiLocalC w p a = z_p^a - w_p z_p^{a-1}` (`a ≥ 1`), tensor products
  `PsiC w r`, and squared norm `jWeightC w r = ∏_{p | r} (1 - ‖w_p‖²)`.
* Expansion `Z n ω = ∑_{r | n} w(n/r) PsiC w r ω` and `D_{X,B} = ∑ S_w(B, ⌊X/r⌋) PsiC w r`.
* Expectation identity `mean_D_eq_scalarSC`: `∫ ω, D B X ω ∂(primeTorusMeasureC w) = scalarSC w B X`.
* Parseval identity `norm_sq_D_eq_energyC`:
  `∫ ω, ‖D B X ω‖² ∂(primeTorusMeasureC w) = ∑_{r ≤ X, (r,B)=1} j_w(r) ‖S_w(B, ⌊X/r⌋)‖²`.
* Rotated `(σ, t)` family `w_p = p^(-σ - it)`: transfer with the same `ζ(σ + θ)` constant,
  `rightHalfZeroFree_of_rotated_measure_bound`, and `RH ↔ E_{B,σ,t}(X) = O(X^{1+δ})`
  for every `σ ≥ 1/2`, every real `t`, and every `B ≥ 1`.

Checks against `ANALYTIC_CONTINUATION_NOTE_v0_1_20261123/check_rotated_centre.py`.
-/

noncomputable section
open scoped BigOperators ENNReal NNReal
open Filter MeasureTheory Complex ArithmeticFunction

namespace RHConnections.CoherentEnergyRotated

open RHConnections.CoherentEnergyMeasure
open RHConnections.CoherentEnergyRadius
open RHConnections.CoherentEnergyBounds
open RHConnections.MertensCriterion
open RHConnections.ArithmeticFourierInversion
open RHConnections.CoherentEnergyContinuation

private lemma norm_exp_I_mul_real'' (x : ℝ) : ‖Complex.exp (Complex.I * (x : ℂ))‖ = 1 := by
  simp

private lemma conj_exp_I_mul_int'' (m : ℤ) (t : ℝ) :
    starRingEnd ℂ (Complex.exp (Complex.I * (m : ℂ) * (t : ℂ))) =
      Complex.exp (Complex.I * ((-m : ℤ) : ℂ) * (t : ℂ)) := by
  rw [← Complex.exp_conj, map_mul, map_mul, Complex.conj_I, Complex.conj_ofReal,
    show starRingEnd ℂ (m : ℂ) = (m : ℂ) from Complex.conj_ofReal (m : ℝ)]
  congr 1; push_cast; ring

/-! ## 1. Complex Poisson kernel and Fourier moments -/

def complexPoissonKernel (w : ℂ) (θ : ℝ) : ℝ :=
  (1 - ‖w‖ ^ 2) / ‖Complex.exp (Complex.I * (θ : ℂ)) - w‖ ^ 2

theorem complexPoissonKernel_denom_pos {w : ℂ} (hw : ‖w‖ < 1) (θ : ℝ) :
    0 < ‖Complex.exp (Complex.I * (θ : ℂ)) - w‖ ^ 2 := by
  have h1 : 1 - ‖w‖ ≤ ‖Complex.exp (Complex.I * (θ : ℂ)) - w‖ := by
    calc 1 - ‖w‖ = ‖Complex.exp (Complex.I * (θ : ℂ))‖ - ‖w‖ := by rw [norm_exp_I_mul_real'']
      _ ≤ ‖Complex.exp (Complex.I * (θ : ℂ)) - w‖ := norm_sub_norm_le _ _
  have hpos : 0 < ‖Complex.exp (Complex.I * (θ : ℂ)) - w‖ := lt_of_lt_of_le (sub_pos.mpr hw) h1
  exact sq_pos_of_pos hpos

theorem complexPoissonKernel_pos {w : ℂ} (hw : ‖w‖ < 1) (θ : ℝ) :
    0 < complexPoissonKernel w θ := by
  have hsq : ‖w‖ ^ 2 < 1 := by nlinarith [norm_nonneg w]
  exact div_pos (sub_pos.mpr hsq) (complexPoissonKernel_denom_pos hw θ)

theorem complexPoissonKernel_continuous {w : ℂ} (hw : ‖w‖ < 1) :
    Continuous (complexPoissonKernel w) := by
  unfold complexPoissonKernel
  refine Continuous.div continuous_const ?_ (fun θ => (complexPoissonKernel_denom_pos hw θ).ne')
  exact (((Complex.continuous_exp.comp (continuous_const.mul Complex.continuous_ofReal)).sub
    continuous_const).norm).pow 2

def complexPoissonTerm (w : ℂ) (k : ℕ) (θ : ℝ) : ℂ :=
  w ^ (k + 1) * Complex.exp (-(Complex.I * ((k + 1 : ℕ) : ℂ) * θ)) +
    (starRingEnd ℂ w) ^ (k + 1) * Complex.exp (Complex.I * ((k + 1 : ℕ) : ℂ) * θ)

lemma norm_complexPoissonTerm_le (w : ℂ) (k : ℕ) (θ : ℝ) :
    ‖complexPoissonTerm w k θ‖ ≤ 2 * ‖w‖ ^ (k + 1) := by
  unfold complexPoissonTerm
  have h1 : ‖Complex.exp (-(Complex.I * ((k + 1 : ℕ) : ℂ) * θ))‖ = 1 := by
    have he : Complex.exp (-(Complex.I * ((k + 1 : ℕ) : ℂ) * θ)) =
        Complex.exp (Complex.I * ((-((k + 1 : ℕ) * θ) : ℝ) : ℂ)) := by
      push_cast; ring_nf
    rw [he, norm_exp_I_mul_real'']
  have h2 : ‖Complex.exp (Complex.I * ((k + 1 : ℕ) : ℂ) * θ)‖ = 1 := by
    have he : Complex.exp (Complex.I * ((k + 1 : ℕ) : ℂ) * θ) =
        Complex.exp (Complex.I * (((k + 1 : ℕ) * θ : ℝ) : ℂ)) := by
      push_cast; ring_nf
    rw [he, norm_exp_I_mul_real'']
  have hnw : ‖starRingEnd ℂ w‖ = ‖w‖ := RCLike.norm_conj w
  calc ‖w ^ (k + 1) * Complex.exp (-(Complex.I * ((k + 1 : ℕ) : ℂ) * θ)) +
          (starRingEnd ℂ w) ^ (k + 1) * Complex.exp (Complex.I * ((k + 1 : ℕ) : ℂ) * θ)‖
      ≤ ‖w ^ (k + 1) * Complex.exp (-(Complex.I * ((k + 1 : ℕ) : ℂ) * θ))‖ +
          ‖(starRingEnd ℂ w) ^ (k + 1) * Complex.exp (Complex.I * ((k + 1 : ℕ) : ℂ) * θ)‖ :=
        norm_add_le _ _
    _ = ‖w‖ ^ (k + 1) * 1 + ‖w‖ ^ (k + 1) * 1 := by
        rw [norm_mul, norm_mul, norm_pow, norm_pow, hnw, h1, h2]
    _ = 2 * ‖w‖ ^ (k + 1) := by ring

theorem complexPoissonKernel_eq_tsum {w : ℂ} (hw : ‖w‖ < 1) (θ : ℝ) :
    (complexPoissonKernel w θ : ℂ) = 1 + ∑' k : ℕ, complexPoissonTerm w k θ := by
  let z : ℂ := Complex.exp (Complex.I * (θ : ℂ))
  let w₁ : ℂ := w * z⁻¹
  let w₂ : ℂ := starRingEnd ℂ w * z
  have hz : ‖z‖ = 1 := norm_exp_I_mul_real'' θ
  have hzin : ‖z⁻¹‖ = 1 := by rw [norm_inv, hz, inv_one]
  have hw₁_norm : ‖w₁‖ < 1 := by
    rw [norm_mul, hzin, mul_one]; exact hw
  have hw₂_norm : ‖w₂‖ < 1 := by
    rw [norm_mul, hz, mul_one, RCLike.norm_conj]; exact hw
  have hs₁ : Summable (fun k : ℕ => w₁ ^ k) := summable_geometric_of_norm_lt_one hw₁_norm
  have hs₂ : Summable (fun k : ℕ => w₂ ^ k) := summable_geometric_of_norm_lt_one hw₂_norm
  have hgeom₁ : (1 - w₁)⁻¹ = 1 + ∑' k : ℕ, w₁ ^ (k + 1) := by
    rw [← (hasSum_geometric_of_norm_lt_one hw₁_norm).tsum_eq, hs₁.tsum_eq_zero_add, pow_zero]
  have hgeom₂ : w₂ * (1 - w₂)⁻¹ = ∑' k : ℕ, w₂ ^ (k + 1) := by
    rw [← (hasSum_geometric_of_norm_lt_one hw₂_norm).tsum_eq, ← tsum_mul_left]
    congr 1; ext k; ring
  have hs₁' : Summable (fun k : ℕ => w₁ ^ (k + 1)) := (summable_nat_add_iff 1).mpr hs₁
  have hs₂' : Summable (fun k : ℕ => w₂ ^ (k + 1)) := (summable_nat_add_iff 1).mpr hs₂
  have hterm (k : ℕ) : w₁ ^ (k + 1) + w₂ ^ (k + 1) = complexPoissonTerm w k θ := by
    dsimp [w₁, w₂, z, complexPoissonTerm]
    have hzm : (Complex.exp (Complex.I * (θ : ℂ)))⁻¹ ^ (k + 1) =
        Complex.exp (-(Complex.I * ((k + 1 : ℕ) : ℂ) * θ)) := by
      rw [← Complex.exp_neg, ← Complex.exp_nat_mul]; congr 1; ring
    have hzp : Complex.exp (Complex.I * (θ : ℂ)) ^ (k + 1) =
        Complex.exp (Complex.I * ((k + 1 : ℕ) : ℂ) * θ) := by
      rw [← Complex.exp_nat_mul]; congr 1; ring
    rw [mul_pow, mul_pow, hzm, hzp]
  have hsum_eq : (1 - w₁)⁻¹ + w₂ * (1 - w₂)⁻¹ = 1 + ∑' k : ℕ, complexPoissonTerm w k θ := by
    rw [hgeom₁, hgeom₂, add_assoc]
    congr 1
    rw [← hs₁'.tsum_add hs₂']
    exact tsum_congr hterm
  have hne₁ : 1 - w₁ ≠ 0 := by
    intro h
    have hn : ‖w₁‖ = 1 := by rw [show w₁ = 1 from (sub_eq_zero.mp h).symm, norm_one]
    linarith
  have hne₂ : 1 - w₂ ≠ 0 := by
    intro h
    have hn : ‖w₂‖ = 1 := by rw [show w₂ = 1 from (sub_eq_zero.mp h).symm, norm_one]
    linarith
  have hz_conj : starRingEnd ℂ z = z⁻¹ := by
    rw [show starRingEnd ℂ z = Complex.exp (-(Complex.I * (θ : ℂ))) by
      simpa [z] using conj_exp_I_mul_int'' 1 θ, Complex.exp_neg]
  have hzw : ((‖z - w‖ ^ 2 : ℝ) : ℂ) = (1 - w₁) * (1 - w₂) := by
    have hn : ((‖z - w‖ ^ 2 : ℝ) : ℂ) = (z - w) * starRingEnd ℂ (z - w) := by
      rw [Complex.mul_conj', Complex.ofReal_pow]
    rw [hn, map_sub, hz_conj]
    dsimp [w₁, w₂]
    calc (z - w) * (z⁻¹ - starRingEnd ℂ w)
        = (z * z⁻¹) - w * z⁻¹ - (z * starRingEnd ℂ w) + w * starRingEnd ℂ w := by ring
      _ = 1 - w * z⁻¹ - starRingEnd ℂ w * z + (w * starRingEnd ℂ w) * (z⁻¹ * z) := by
          rw [mul_inv_cancel₀ (Complex.exp_ne_zero _), inv_mul_cancel₀ (Complex.exp_ne_zero _),
            mul_one, mul_comm z (starRingEnd ℂ w)]
      _ = (1 - w * z⁻¹) * (1 - starRingEnd ℂ w * z) := by ring
  have hnum : (1 - w₂) + (1 - w₁) * w₂ = ((1 - ‖w‖ ^ 2 : ℝ) : ℂ) := by
    have hwc : w * starRingEnd ℂ w = ((‖w‖ ^ 2 : ℝ) : ℂ) := by
      rw [Complex.mul_conj', Complex.ofReal_pow]
    dsimp [w₁, w₂]
    calc (1 - starRingEnd ℂ w * z) + (1 - w * z⁻¹) * (starRingEnd ℂ w * z)
        = 1 - (w * starRingEnd ℂ w) * (z⁻¹ * z) := by ring
      _ = 1 - ((‖w‖ ^ 2 : ℝ) : ℂ) := by
          rw [inv_mul_cancel₀ (Complex.exp_ne_zero _), mul_one, hwc]
      _ = ((1 - ‖w‖ ^ 2 : ℝ) : ℂ) := by push_cast; rfl
  have hratio : (1 - w₁)⁻¹ + w₂ * (1 - w₂)⁻¹ =
      ((1 - ‖w‖ ^ 2 : ℝ) : ℂ) / ((‖z - w‖ ^ 2 : ℝ) : ℂ) := by
    rw [hzw, ← hnum]
    field_simp [hne₁, hne₂]
  rw [← hsum_eq, hratio]
  unfold complexPoissonKernel
  push_cast
  rfl

private lemma complexPoisson_fourier_orthogonality_Ioc (m : ℤ) :
    ((2 * Real.pi : ℂ)⁻¹) *
        ∫ θ in Set.Ioc (0 : ℝ) (2 * Real.pi), Complex.exp (Complex.I * (m : ℂ) * θ) =
      if m = 0 then 1 else 0 := by
  have hpi0 : (0 : ℝ) ≤ 2 * Real.pi := by positivity
  rw [← intervalIntegral.integral_of_le hpi0]
  exact fourier_orthogonality m

private def complexFourierF (w : ℂ) (m : ℤ) (k : ℕ) (θ : ℝ) : ℂ :=
  Complex.exp (Complex.I * (m : ℂ) * θ) * complexPoissonTerm w k θ

private lemma complexFourierF_continuous (w : ℂ) (m : ℤ) (k : ℕ) :
    Continuous (complexFourierF w m k) := by
  unfold complexFourierF complexPoissonTerm
  fun_prop

private lemma complexFourierF_integrable (w : ℂ) (m : ℤ) (k : ℕ) :
    Integrable (complexFourierF w m k) (volume.restrict (Set.Ioc 0 (2 * Real.pi))) :=
  (complexFourierF_continuous w m k).continuousOn.integrableOn_Icc.mono_set Set.Ioc_subset_Icc_self

private lemma complexFourier_term_integral (w : ℂ) (m : ℤ) (k : ℕ) :
    ((2 * Real.pi : ℂ)⁻¹) *
        ∫ θ in Set.Ioc (0 : ℝ) (2 * Real.pi), complexFourierF w m k θ =
      w ^ (k + 1) * (if m - ((k + 1 : ℕ) : ℤ) = 0 then (1 : ℂ) else 0) +
        (starRingEnd ℂ w) ^ (k + 1) * (if m + ((k + 1 : ℕ) : ℤ) = 0 then 1 else 0) := by
  have hsplit : ∀ θ : ℝ, complexFourierF w m k θ =
      w ^ (k + 1) * Complex.exp (Complex.I * ((m - ((k + 1 : ℕ) : ℤ) : ℤ) : ℂ) * θ) +
        (starRingEnd ℂ w) ^ (k + 1) * Complex.exp (Complex.I * ((m + ((k + 1 : ℕ) : ℤ) : ℤ) : ℂ) * θ) := by
    intro θ
    unfold complexFourierF complexPoissonTerm
    have hm1 : Complex.exp (Complex.I * (m : ℂ) * θ) *
        Complex.exp (-(Complex.I * ((k + 1 : ℕ) : ℂ) * θ)) =
        Complex.exp (Complex.I * ((m - ((k + 1 : ℕ) : ℤ) : ℤ) : ℂ) * θ) := by
      rw [← Complex.exp_add]; congr 1; push_cast; ring
    have hm2 : Complex.exp (Complex.I * (m : ℂ) * θ) *
        Complex.exp (Complex.I * ((k + 1 : ℕ) : ℂ) * θ) =
        Complex.exp (Complex.I * ((m + ((k + 1 : ℕ) : ℤ) : ℤ) : ℂ) * θ) := by
      rw [← Complex.exp_add]; congr 1; push_cast; ring
    rw [mul_add, mul_left_comm _ (w ^ (k + 1)), mul_left_comm _ ((starRingEnd ℂ w) ^ (k + 1)), hm1, hm2]
  have hI1 : Integrable (fun θ : ℝ =>
      w ^ (k + 1) * Complex.exp (Complex.I * ((m - ((k + 1 : ℕ) : ℤ) : ℤ) : ℂ) * θ))
      (volume.restrict (Set.Ioc 0 (2 * Real.pi))) :=
    ((Complex.continuous_exp.comp (continuous_const.mul Complex.continuous_ofReal)).const_mul _).continuousOn.integrableOn_Icc.mono_set
      Set.Ioc_subset_Icc_self
  have hI2 : Integrable (fun θ : ℝ =>
      (starRingEnd ℂ w) ^ (k + 1) * Complex.exp (Complex.I * ((m + ((k + 1 : ℕ) : ℤ) : ℤ) : ℂ) * θ))
      (volume.restrict (Set.Ioc 0 (2 * Real.pi))) :=
    ((Complex.continuous_exp.comp (continuous_const.mul Complex.continuous_ofReal)).const_mul _).continuousOn.integrableOn_Icc.mono_set
      Set.Ioc_subset_Icc_self
  simp_rw [hsplit]
  rw [integral_add hI1 hI2, integral_const_mul, integral_const_mul]
  have fo1 := complexPoisson_fourier_orthogonality_Ioc (m - ((k + 1 : ℕ) : ℤ))
  have fo2 := complexPoisson_fourier_orthogonality_Ioc (m + ((k + 1 : ℕ) : ℤ))
  rw [mul_add, mul_left_comm ((2 * Real.pi : ℂ)⁻¹) (w ^ (k + 1)),
    mul_left_comm ((2 * Real.pi : ℂ)⁻¹) ((starRingEnd ℂ w) ^ (k + 1)), fo1, fo2]

private lemma complex_fourier_tsum_eval (w : ℂ) (m : ℤ) :
    (if m = 0 then (1 : ℂ) else 0) +
      ∑' k : ℕ, (w ^ (k + 1) * (if m - ((k + 1 : ℕ) : ℤ) = 0 then (1 : ℂ) else 0) +
        (starRingEnd ℂ w) ^ (k + 1) * (if m + ((k + 1 : ℕ) : ℤ) = 0 then 1 else 0)) =
      if 0 ≤ m then w ^ m.natAbs else (starRingEnd ℂ w) ^ m.natAbs := by
  rcases lt_trichotomy m 0 with hm_lt | rfl | hm_gt
  · have hn0 : m ≠ 0 := hm_lt.ne
    have hnot : ¬ (0 ≤ m) := not_le.mpr hm_lt
    have hpos : 0 < m.natAbs := Int.natAbs_pos.mpr hn0
    have hkm : m.natAbs - 1 + 1 = m.natAbs := Nat.sub_add_cancel hpos
    have hsingle : ∀ k : ℕ, k ≠ m.natAbs - 1 →
        w ^ (k + 1) * (if m - ((k + 1 : ℕ) : ℤ) = 0 then (1 : ℂ) else 0) +
          (starRingEnd ℂ w) ^ (k + 1) * (if m + ((k + 1 : ℕ) : ℤ) = 0 then 1 else 0) = 0 := by
      intro k hk
      split_ifs <;> first | omega | ring
    simp only [hn0, hnot, ↓reduceIte, zero_add]
    rw [tsum_eq_single (m.natAbs - 1) hsingle, hkm]
    split_ifs <;> first | omega | ring
  · have hzero : ∀ k : ℕ,
        w ^ (k + 1) * (if (0 : ℤ) - ((k + 1 : ℕ) : ℤ) = 0 then (1 : ℂ) else 0) +
          (starRingEnd ℂ w) ^ (k + 1) * (if (0 : ℤ) + ((k + 1 : ℕ) : ℤ) = 0 then 1 else 0) = 0 := by
      intro k
      split_ifs <;> first | omega | ring
    rw [tsum_congr hzero, tsum_zero]
    simp
  · have hn0 : m ≠ 0 := hm_gt.ne'
    have hge : 0 ≤ m := hm_gt.le
    have hpos : 0 < m.natAbs := Int.natAbs_pos.mpr hn0
    have hkm : m.natAbs - 1 + 1 = m.natAbs := Nat.sub_add_cancel hpos
    have hsingle : ∀ k : ℕ, k ≠ m.natAbs - 1 →
        w ^ (k + 1) * (if m - ((k + 1 : ℕ) : ℤ) = 0 then (1 : ℂ) else 0) +
          (starRingEnd ℂ w) ^ (k + 1) * (if m + ((k + 1 : ℕ) : ℤ) = 0 then 1 else 0) = 0 := by
      intro k hk
      split_ifs <;> first | omega | ring
    simp only [hn0, hge, ↓reduceIte, zero_add]
    rw [tsum_eq_single (m.natAbs - 1) hsingle, hkm]
    split_ifs <;> first | omega | ring

private lemma complexPoisson_fourier_swap {w : ℂ} (hw : ‖w‖ < 1) (m : ℤ) :
    ∫ θ in Set.Ioc (0 : ℝ) (2 * Real.pi), ∑' k : ℕ, complexFourierF w m k θ =
      ∑' k : ℕ, ∫ θ in Set.Ioc (0 : ℝ) (2 * Real.pi), complexFourierF w m k θ := by
  have hs_geom : Summable (fun k : ℕ => 2 * ‖w‖ ^ (k + 1)) :=
    ((summable_nat_add_iff 1).mpr (summable_geometric_of_lt_one (norm_nonneg w) hw)).mul_left 2
  have h_F_int : ∀ k : ℕ, Integrable (complexFourierF w m k) (volume.restrict (Set.Ioc 0 (2 * Real.pi))) :=
    complexFourierF_integrable w m
  have h_norm_int_le : ∀ k : ℕ,
      ∫ θ in Set.Ioc (0 : ℝ) (2 * Real.pi), ‖complexFourierF w m k θ‖ ≤ (2 * Real.pi) * (2 * ‖w‖ ^ (k + 1)) := by
    intro k
    have hpt : ∀ θ : ℝ, ‖complexFourierF w m k θ‖ ≤ 2 * ‖w‖ ^ (k + 1) := by
      intro θ
      unfold complexFourierF
      rw [norm_mul, show ‖Complex.exp (Complex.I * (m : ℂ) * θ)‖ = 1 by
        simpa [mul_assoc] using norm_exp_I_mul_real'' ((m : ℝ) * θ), one_mul]
      exact norm_complexPoissonTerm_le w k θ
    calc ∫ θ in Set.Ioc 0 (2 * Real.pi), ‖complexFourierF w m k θ‖
        ≤ ∫ _ in Set.Ioc 0 (2 * Real.pi), (2 * ‖w‖ ^ (k + 1)) :=
          integral_mono (h_F_int k).norm (integrable_const _) hpt
      _ = (2 * Real.pi) * (2 * ‖w‖ ^ (k + 1)) := by
          rw [integral_const, smul_eq_mul, Measure.real_def, Measure.restrict_apply MeasurableSet.univ,
            Set.univ_inter, Real.volume_Ioc, sub_zero, ENNReal.toReal_ofReal (by positivity)]
  have h_F_sum : Summable (fun k : ℕ => ∫ θ in Set.Ioc (0 : ℝ) (2 * Real.pi), ‖complexFourierF w m k θ‖) :=
    Summable.of_nonneg_of_le (fun _ => integral_nonneg fun _ => norm_nonneg _)
      h_norm_int_le (hs_geom.mul_left (2 * Real.pi))
  exact (integral_tsum_of_summable_integral_norm h_F_int h_F_sum).symm

theorem complexPoissonKernel_fourier_moment {w : ℂ} (hw : ‖w‖ < 1) (m : ℤ) :
    ((2 * Real.pi : ℂ)⁻¹) *
        ∫ θ in (0 : ℝ)..(2 * Real.pi),
          Complex.exp (Complex.I * (m : ℂ) * θ) * (complexPoissonKernel w θ : ℂ) =
      if 0 ≤ m then w ^ m.natAbs else (starRingEnd ℂ w) ^ m.natAbs := by
  have hpi0 : (0 : ℝ) ≤ 2 * Real.pi := by positivity
  have hs_geom : Summable (fun k : ℕ => 2 * ‖w‖ ^ (k + 1)) :=
    ((summable_nat_add_iff 1).mpr (summable_geometric_of_lt_one (norm_nonneg w) hw)).mul_left 2
  have h_sum_term : ∀ θ : ℝ, Summable (fun k : ℕ => complexPoissonTerm w k θ) := fun θ =>
    Summable.of_norm_bounded hs_geom (fun k => norm_complexPoissonTerm_le w k θ)
  have h_eq : ∀ θ : ℝ,
      Complex.exp (Complex.I * (m : ℂ) * θ) * (complexPoissonKernel w θ : ℂ) =
        Complex.exp (Complex.I * (m : ℂ) * θ) + ∑' k : ℕ, complexFourierF w m k θ := by
    intro θ
    rw [complexPoissonKernel_eq_tsum hw θ, mul_add, mul_one, ← (h_sum_term θ).tsum_mul_left]
    rfl
  have h_E_cont : Continuous (fun θ : ℝ => Complex.exp (Complex.I * (m : ℂ) * θ)) :=
    Complex.continuous_exp.comp (continuous_const.mul Complex.continuous_ofReal)
  have h_lhs_cont : Continuous (fun θ : ℝ => Complex.exp (Complex.I * (m : ℂ) * θ) * (complexPoissonKernel w θ : ℂ)) :=
    h_E_cont.mul (Complex.continuous_ofReal.comp (complexPoissonKernel_continuous hw))
  have h_lhs_int : Integrable (fun θ : ℝ => Complex.exp (Complex.I * (m : ℂ) * θ) * (complexPoissonKernel w θ : ℂ))
      (volume.restrict (Set.Ioc 0 (2 * Real.pi))) :=
    h_lhs_cont.continuousOn.integrableOn_Icc.mono_set Set.Ioc_subset_Icc_self
  have h_E_int : Integrable (fun θ : ℝ => Complex.exp (Complex.I * (m : ℂ) * θ))
      (volume.restrict (Set.Ioc 0 (2 * Real.pi))) :=
    h_E_cont.continuousOn.integrableOn_Icc.mono_set Set.Ioc_subset_Icc_self
  have h_tsum_fun :
      (fun θ : ℝ => ∑' k : ℕ, complexFourierF w m k θ) =
        fun θ : ℝ => Complex.exp (Complex.I * (m : ℂ) * (θ : ℂ)) * (complexPoissonKernel w θ : ℂ) -
          Complex.exp (Complex.I * (m : ℂ) * (θ : ℂ)) := by
    ext θ; exact eq_sub_iff_add_eq'.mpr (h_eq θ).symm
  rw [intervalIntegral.integral_of_le hpi0]
  have hsub := integral_sub h_lhs_int h_E_int
  have hadd : (∫ θ in Set.Ioc 0 (2 * Real.pi), Complex.exp (Complex.I * (m : ℂ) * θ) * (complexPoissonKernel w θ : ℂ)) =
      (∫ θ in Set.Ioc 0 (2 * Real.pi), Complex.exp (Complex.I * (m : ℂ) * θ)) +
      (∫ θ in Set.Ioc 0 (2 * Real.pi), ∑' k : ℕ, complexFourierF w m k θ) := by
    rw [h_tsum_fun, hsub, add_sub_cancel]
  rw [hadd, complexPoisson_fourier_swap hw m, mul_add, ← tsum_mul_left,
    complexPoisson_fourier_orthogonality_Ioc, tsum_congr (complexFourier_term_integral w m),
    complex_fourier_tsum_eval]

/-! ## 2. Product measure on the prime torus at complex centres w_p -/

def complexPoissonDensityNN (w : ℕ → ℂ) (p : ℕ) (θ : ℝ) : ℝ≥0 :=
  Real.toNNReal ((2 * Real.pi)⁻¹ * complexPoissonKernel (w p) θ)

theorem complexPoissonDensityNN_continuous {w : ℕ → ℂ} {p : ℕ} (hw : ‖w p‖ < 1) :
    Continuous (complexPoissonDensityNN w p) :=
  continuous_real_toNNReal.comp (continuous_const.mul (complexPoissonKernel_continuous hw))

theorem complexPoissonDensityNN_coe {w : ℕ → ℂ} {p : ℕ} (hw : ‖w p‖ < 1) (θ : ℝ) :
    ((complexPoissonDensityNN w p θ : ℝ≥0) : ℝ) = (2 * Real.pi)⁻¹ * complexPoissonKernel (w p) θ :=
  Real.coe_toNNReal _ (mul_nonneg (by positivity) (complexPoissonKernel_pos hw θ).le)

def complexPoissonMeasureOf (w : ℕ → ℂ) (p : ℕ) : Measure ℝ :=
  if p.Prime ∧ ‖w p‖ < 1 then
    (volume.restrict (Set.Ioc 0 (2 * Real.pi))).withDensity
      (fun θ => (complexPoissonDensityNN w p θ : ℝ≥0∞))
  else
    Measure.dirac 0

theorem integral_complexPoissonMeasureOf_exp {w : ℕ → ℂ} {p : ℕ} (hp : p.Prime)
    (hw : ‖w p‖ < 1) (m : ℤ) :
    ∫ θ, Complex.exp (Complex.I * (m : ℂ) * θ) ∂(complexPoissonMeasureOf w p) =
      if 0 ≤ m then w p ^ m.natAbs else (starRingEnd ℂ (w p)) ^ m.natAbs := by
  have hcond : p.Prime ∧ ‖w p‖ < 1 := ⟨hp, hw⟩
  simp only [complexPoissonMeasureOf, hcond, and_self, ↓reduceIte]
  have hf_meas : Measurable (complexPoissonDensityNN w p) :=
    (complexPoissonDensityNN_continuous hw).measurable
  rw [integral_withDensity_eq_integral_smul hf_meas]
  have hpi0 : (0 : ℝ) ≤ 2 * Real.pi := by positivity
  have h_eq : ∀ θ : ℝ,
      (complexPoissonDensityNN w p θ) • Complex.exp (Complex.I * (m : ℂ) * θ) =
        ((2 * Real.pi : ℂ)⁻¹) *
          (Complex.exp (Complex.I * (m : ℂ) * θ) * (complexPoissonKernel (w p) θ : ℂ)) := by
    intro θ
    rw [NNReal.smul_def, Complex.real_smul, complexPoissonDensityNN_coe hw θ]
    push_cast
    ring
  simp_rw [h_eq]
  rw [integral_const_mul, ← intervalIntegral.integral_of_le hpi0]
  exact complexPoissonKernel_fourier_moment hw m

instance complexPoissonMeasureOf_isProbabilityMeasure (w : ℕ → ℂ) (p : ℕ) :
    IsProbabilityMeasure (complexPoissonMeasureOf w p) := by
  by_cases hcond : p.Prime ∧ ‖w p‖ < 1
  · rcases hcond with ⟨hp, hw⟩
    constructor
    simp only [complexPoissonMeasureOf, hp, hw, and_self, ↓reduceIte]
    rw [withDensity_apply _ MeasurableSet.univ, setLIntegral_univ]
    let f : ℝ → ℝ := fun θ => ((complexPoissonDensityNN w p θ : ℝ≥0) : ℝ)
    have hf_cont : Continuous f := NNReal.continuous_coe.comp (complexPoissonDensityNN_continuous hw)
    have hf_int : Integrable f (volume.restrict (Set.Ioc 0 (2 * Real.pi))) :=
      hf_cont.continuousOn.integrableOn_Icc.mono_set Set.Ioc_subset_Icc_self
    have hf_nn : 0 ≤ᵐ[volume.restrict (Set.Ioc 0 (2 * Real.pi))] f :=
      ae_of_all _ (fun θ => NNReal.coe_nonneg _)
    have h_lint :
        (∫⁻ θ, (complexPoissonDensityNN w p θ : ℝ≥0∞) ∂volume.restrict (Set.Ioc 0 (2 * Real.pi))) =
          ENNReal.ofReal (∫ θ, f θ ∂volume.restrict (Set.Ioc 0 (2 * Real.pi))) := by
      rw [ofReal_integral_eq_lintegral_ofReal hf_int hf_nn]
      congr 1; ext θ
      exact ENNReal.ofReal_coe_nnreal.symm
    rw [h_lint]
    have hpi0 : (0 : ℝ) ≤ 2 * Real.pi := by positivity
    have hm0 := complexPoissonKernel_fourier_moment hw 0
    simp only [Int.cast_zero, mul_zero, zero_mul, Complex.exp_zero, one_mul, le_refl, ↓reduceIte,
      Int.natAbs_zero, pow_zero] at hm0
    have hre : ∫ θ, f θ ∂volume.restrict (Set.Ioc 0 (2 * Real.pi)) = 1 := by
      have hc : (((∫ θ, f θ ∂volume.restrict (Set.Ioc 0 (2 * Real.pi))) : ℝ) : ℂ) = 1 := by
        calc (((∫ θ, f θ ∂volume.restrict (Set.Ioc 0 (2 * Real.pi))) : ℝ) : ℂ)
            = ∫ θ, (f θ : ℂ) ∂volume.restrict (Set.Ioc 0 (2 * Real.pi)) := by
              simpa using (Complex.ofRealCLM.integral_comp_comm hf_int).symm
          _ = ((2 * Real.pi : ℂ)⁻¹) *
                ∫ θ in (0 : ℝ)..(2 * Real.pi), (complexPoissonKernel (w p) θ : ℂ) := by
              rw [intervalIntegral.integral_of_le hpi0, ← integral_const_mul]
              congr 1; ext θ
              dsimp [f]
              rw [complexPoissonDensityNN_coe hw θ]
              push_cast; rfl
          _ = 1 := hm0
      exact_mod_cast hc
    rw [hre, ENNReal.ofReal_one]
  · simp only [complexPoissonMeasureOf, hcond, ↓reduceIte]
    infer_instance

def primeTorusMeasureC (w : ℕ → ℂ) : Measure (ℕ → ℝ) :=
  Measure.infinitePi (complexPoissonMeasureOf w)

instance (w : ℕ → ℂ) : IsProbabilityMeasure (primeTorusMeasureC w) := by
  unfold primeTorusMeasureC
  infer_instance

theorem integral_finset_prod_primeTorusC (w : ℕ → ℂ) (s : Finset ℕ) (f : ℕ → ℝ → ℂ)
    (hf : ∀ p ∈ s, AEStronglyMeasurable (f p) (complexPoissonMeasureOf w p)) :
    ∫ ω, (∏ p ∈ s, f p (ω p)) ∂(primeTorusMeasureC w) =
      ∏ p ∈ s, ∫ t, f p t ∂(complexPoissonMeasureOf w p) := by
  let g : (Π _ : s, ℝ) → ℂ := fun y => ∏ p : s, f p.1 (y p)
  have hg_meas : AEStronglyMeasurable g (Measure.pi fun p : s => complexPoissonMeasureOf w p.1) := by
    refine Finset.aestronglyMeasurable_fun_prod _ fun p _ => ?_
    exact (hf p.1 p.2).comp_measurePreserving
      (MeasureTheory.measurePreserving_eval (fun q : s => complexPoissonMeasureOf w q.1) p)
  have hpi := MeasureTheory.integral_restrict_infinitePi
    (μ := complexPoissonMeasureOf w) (s := s) (f := g) hg_meas
  have hprod : (∫ y, g y ∂Measure.pi fun p : s => complexPoissonMeasureOf w p.1) =
      ∏ p : s, ∫ t, f p.1 t ∂(complexPoissonMeasureOf w p.1) :=
    MeasureTheory.integral_fintype_prod_eq_prod (fun p : s => f p.1)
  have heq : (fun ω : ℕ → ℝ => g (s.restrict ω)) = fun ω => ∏ p ∈ s, f p (ω p) := by
    ext ω
    dsimp [g, Finset.restrict]
    exact Finset.prod_attach s (fun p => f p (ω p))
  unfold primeTorusMeasureC
  rw [← heq, hpi, hprod]
  exact Finset.prod_attach s (fun p => ∫ t, f p t ∂(complexPoissonMeasureOf w p))

def innerNuC (w : ℕ → ℂ) (F G : (ℕ → ℝ) → ℂ) : ℂ :=
  ∫ ω, F ω * starRingEnd ℂ (G ω) ∂(primeTorusMeasureC w)

/-! ## 3. Multiplicative weight w(m), orthogonal modes Ψ_r, mean, and Parseval -/

def wProd (w : ℕ → ℂ) (m : ℕ) : ℂ :=
  ∏ p ∈ m.primeFactors, w p ^ m.factorization p

@[simp] theorem wProd_one (w : ℕ → ℂ) : wProd w 1 = 1 := by
  simp [wProd]

@[simp] theorem wProd_prime_pow (w : ℕ → ℂ) {p k : ℕ} (hp : p.Prime) :
    wProd w (p ^ k) = w p ^ k := by
  by_cases hk : k = 0
  · subst hk; simp
  · unfold wProd
    rw [Nat.primeFactors_prime_pow hk hp, Finset.prod_singleton, hp.factorization_pow,
      Finsupp.single_eq_same]

theorem wProd_mul (w : ℕ → ℂ) {m n : ℕ} (hm : m ≠ 0) (hn : n ≠ 0) :
    wProd w (m * n) = wProd w m * wProd w n := by
  unfold wProd
  rw [Nat.primeFactors_mul hm hn]
  have hm_eq : ∏ p ∈ m.primeFactors, w p ^ m.factorization p =
      ∏ p ∈ m.primeFactors ∪ n.primeFactors, w p ^ m.factorization p := by
    refine Finset.prod_subset Finset.subset_union_left fun p _ hp => ?_
    have hz : m.factorization p = 0 :=
      Finsupp.notMem_support_iff.mp (by simpa [Nat.support_factorization] using hp)
    simp [hz]
  have hn_eq : ∏ p ∈ n.primeFactors, w p ^ n.factorization p =
      ∏ p ∈ m.primeFactors ∪ n.primeFactors, w p ^ n.factorization p := by
    refine Finset.prod_subset Finset.subset_union_right fun p _ hp => ?_
    have hz : n.factorization p = 0 :=
      Finsupp.notMem_support_iff.mp (by simpa [Nat.support_factorization] using hp)
    simp [hz]
  rw [hm_eq, hn_eq, ← Finset.prod_mul_distrib]
  refine Finset.prod_congr rfl fun p _ => ?_
  rw [Nat.factorization_mul hm hn, Finsupp.coe_add, Pi.add_apply, pow_add]

def phiLocalC (w : ℕ → ℂ) (p a : ℕ) (t : ℝ) : ℂ :=
  if a = 0 then 1
  else Complex.exp (Complex.I * (a : ℂ) * (t : ℂ)) -
    w p * Complex.exp (Complex.I * ((a - 1 : ℕ) : ℂ) * (t : ℂ))

@[simp] theorem phiLocalC_zero (w : ℕ → ℂ) (p : ℕ) (t : ℝ) : phiLocalC w p 0 t = 1 := by
  simp [phiLocalC]

def PsiC (w : ℕ → ℂ) (r : ℕ) (ω : ℕ → ℝ) : ℂ :=
  ∏ p ∈ r.primeFactors, phiLocalC w p (r.factorization p) (ω p)

@[simp] theorem PsiC_one (w : ℕ → ℂ) (ω : ℕ → ℝ) : PsiC w 1 ω = 1 := by
  simp [PsiC]

def jWeightC (w : ℕ → ℂ) (r : ℕ) : ℝ :=
  ∏ p ∈ r.primeFactors, (1 - ‖w p‖ ^ 2)

@[simp] theorem jWeightC_one (w : ℕ → ℂ) : jWeightC w 1 = 1 := by
  simp [jWeightC]

theorem jWeightC_factor_nonneg {w : ℕ → ℂ} (hw : ∀ p, p.Prime → ‖w p‖ ≤ 1)
    {p : ℕ} (hp : p.Prime) : 0 ≤ 1 - ‖w p‖ ^ 2 := by
  have h1 := hw p hp
  have hsq : ‖w p‖ ^ 2 ≤ 1 := by nlinarith [norm_nonneg (w p)]
  linarith

theorem jWeightC_nonneg {w : ℕ → ℂ} (hw : ∀ p, p.Prime → ‖w p‖ ≤ 1) (r : ℕ) :
    0 ≤ jWeightC w r :=
  Finset.prod_nonneg fun _p hp => jWeightC_factor_nonneg hw (Nat.prime_of_mem_primeFactors hp)

theorem jWeightC_le_one {w : ℕ → ℂ} (hw : ∀ p, p.Prime → ‖w p‖ ≤ 1) (r : ℕ) :
    jWeightC w r ≤ 1 := by
  have hprod (T : Finset ℕ) (hT : T ⊆ r.primeFactors) :
      (∏ p ∈ T, (1 - ‖w p‖ ^ 2)) ≤ 1 := by
    induction T using Finset.induction_on with
    | empty => simp
    | insert p T hp ih =>
      have hsub : T ⊆ r.primeFactors := (Finset.subset_insert _ _).trans hT
      rw [Finset.prod_insert hp]
      calc (1 - ‖w p‖ ^ 2) * ∏ q ∈ T, (1 - ‖w q‖ ^ 2)
          ≤ 1 * 1 := mul_le_mul (sub_le_self _ (sq_nonneg _)) (ih hsub)
            (Finset.prod_nonneg fun q hq =>
              jWeightC_factor_nonneg hw (Nat.prime_of_mem_primeFactors (hsub hq)))
            zero_le_one
        _ = 1 := one_mul _
  exact hprod r.primeFactors (fun _ h => h)

private lemma phiLocalC_continuous (w : ℕ → ℂ) (p a : ℕ) : Continuous (phiLocalC w p a) := by
  unfold phiLocalC
  split_ifs
  · exact continuous_const
  · fun_prop

private lemma single_prime_phiLocalC_integral {w : ℕ → ℂ} {p : ℕ} (hp : p.Prime)
    (hw : ‖w p‖ < 1) (a : ℕ) :
    ∫ t, phiLocalC w p a t ∂(complexPoissonMeasureOf w p) = if a = 0 then 1 else 0 := by
  by_cases ha : a = 0
  · subst ha; simp [phiLocalC]
  · have hapos : 0 < a := Nat.pos_of_ne_zero ha
    have h_int_exp : ∀ m : ℤ,
        Integrable (fun t : ℝ => Complex.exp (Complex.I * (m : ℂ) * (t : ℂ)))
          (complexPoissonMeasureOf w p) := by
      intro m
      refine Integrable.of_bound
        ((Complex.continuous_exp.comp (continuous_const.mul Complex.continuous_ofReal)).aestronglyMeasurable)
        1 (ae_of_all _ fun t => ?_)
      rw [show ‖Complex.exp (Complex.I * (m : ℂ) * (t : ℂ))‖ = 1 by
        simpa [mul_assoc] using norm_exp_I_mul_real'' ((m : ℝ) * t)]
    have hfun : (fun t : ℝ => phiLocalC w p a t) = fun t : ℝ =>
        Complex.exp (Complex.I * ((a : ℤ) : ℂ) * (t : ℂ)) -
          w p * Complex.exp (Complex.I * (((a - 1 : ℕ) : ℤ) : ℂ) * (t : ℂ)) := by
      ext t; simp [phiLocalC, ha]
    rw [hfun, integral_sub (h_int_exp _) ((h_int_exp _).const_mul _), integral_const_mul,
      integral_complexPoissonMeasureOf_exp hp hw (a : ℤ),
      integral_complexPoissonMeasureOf_exp hp hw ((a - 1 : ℕ) : ℤ)]
    simp only [Int.natCast_nonneg, ↓reduceIte, ha]
    have ha1 : (a : ℤ).natAbs = a := Int.natAbs_natCast a
    have ha2 : (((a - 1 : ℕ) : ℤ)).natAbs = a - 1 := Int.natAbs_natCast (a - 1)
    rw [ha1, ha2, show w p ^ a = w p * w p ^ (a - 1) by
      conv_lhs => rw [show a = 1 + (a - 1) by omega, pow_add, pow_one], sub_self]

theorem integral_PsiC {w : ℕ → ℂ} (hw : ∀ p, p.Prime → ‖w p‖ < 1) {r : ℕ} (hr : r ≠ 0) :
    ∫ ω, PsiC w r ω ∂(primeTorusMeasureC w) = if r = 1 then 1 else 0 := by
  by_cases hr1 : r = 1
  · subst hr1; simp
  · simp only [hr1, ↓reduceIte]
    unfold PsiC
    have h_meas : ∀ p ∈ r.primeFactors,
        AEStronglyMeasurable (fun t => phiLocalC w p (r.factorization p) t)
          (complexPoissonMeasureOf w p) := fun p _ =>
      (phiLocalC_continuous w p _).aestronglyMeasurable
    rw [integral_finset_prod_primeTorusC w r.primeFactors _ h_meas]
    have hex : ∃ p ∈ r.primeFactors, r.factorization p ≠ 0 := by
      have hne : r.primeFactors.Nonempty := by
        rw [Nat.nonempty_primeFactors]; omega
      obtain ⟨p, hp⟩ := hne
      refine ⟨p, hp, (Nat.Prime.factorization_pos_of_dvd (Nat.prime_of_mem_primeFactors hp) hr
        (Nat.dvd_of_mem_primeFactors hp)).ne'⟩
    obtain ⟨p₀, hp₀, hfac⟩ := hex
    refine Finset.prod_eq_zero hp₀ ?_
    have hp_prime := Nat.prime_of_mem_primeFactors hp₀
    rw [single_prime_phiLocalC_integral hp_prime (hw p₀ hp_prime)]
    simp [hfac]

private lemma single_prime_phiLocalC_inner {w : ℕ → ℂ} {p : ℕ} (hp : p.Prime)
    (hw : ‖w p‖ < 1) (a b : ℕ) :
    ∫ t, phiLocalC w p a t * starRingEnd ℂ (phiLocalC w p b t) ∂(complexPoissonMeasureOf w p) =
      if a = b then (if a = 0 then (1 : ℂ) else ((1 - ‖w p‖ ^ 2 : ℝ) : ℂ)) else 0 := by
  have h_int_exp : ∀ m : ℤ,
      Integrable (fun t : ℝ => Complex.exp (Complex.I * (m : ℂ) * (t : ℂ)))
        (complexPoissonMeasureOf w p) := by
    intro m
    refine Integrable.of_bound
      ((Complex.continuous_exp.comp (continuous_const.mul Complex.continuous_ofReal)).aestronglyMeasurable)
      1 (ae_of_all _ fun t => ?_)
    rw [show ‖Complex.exp (Complex.I * (m : ℂ) * (t : ℂ))‖ = 1 by
      simpa [mul_assoc] using norm_exp_I_mul_real'' ((m : ℝ) * t)]
  by_cases ha : a = 0 <;> by_cases hb : b = 0
  · subst ha; subst hb
    simp [phiLocalC]
  · subst ha
    have hbpos : 0 < b := Nat.pos_of_ne_zero hb
    have hfun : (fun t : ℝ => phiLocalC w p 0 t * starRingEnd ℂ (phiLocalC w p b t)) =
        fun t : ℝ =>
          Complex.exp (Complex.I * ((-(b : ℤ) : ℤ) : ℂ) * (t : ℂ)) -
          starRingEnd ℂ (w p) *
            Complex.exp (Complex.I * ((-((b - 1 : ℕ) : ℤ) : ℤ) : ℂ) * (t : ℂ)) := by
      ext t
      simp only [phiLocalC, ↓reduceIte, hb, one_mul, map_sub, map_mul]
      have c1 := conj_exp_I_mul_int'' (b : ℤ) t
      have c2 := conj_exp_I_mul_int'' ((b - 1 : ℕ) : ℤ) t
      push_cast at c1 c2 ⊢
      rw [c1, c2]
    rw [hfun, integral_sub (h_int_exp _) ((h_int_exp _).const_mul _), integral_const_mul,
      integral_complexPoissonMeasureOf_exp hp hw (-(b : ℤ)),
      integral_complexPoissonMeasureOf_exp hp hw (-((b - 1 : ℕ) : ℤ))]
    have h0b : (0 : ℕ) ≠ b := Ne.symm hb
    have hnb1 : ¬ (0 ≤ -(b : ℤ)) := by omega
    have hnb1_abs : (-(b : ℤ)).natAbs = b := by omega
    have hnb2_abs : (-((b - 1 : ℕ) : ℤ)).natAbs = b - 1 := by omega
    by_cases hb1 : b = 1
    · subst hb1
      simp
    · have hnb2 : ¬ (0 ≤ -((b - 1 : ℕ) : ℤ)) := by omega
      simp only [h0b, hnb1, hnb2, ↓reduceIte, hnb1_abs, hnb2_abs]
      have hpow : (starRingEnd ℂ (w p)) ^ b =
          starRingEnd ℂ (w p) * (starRingEnd ℂ (w p)) ^ (b - 1) := by
        conv_lhs => rw [show b = 1 + (b - 1) by omega, pow_add, pow_one]
      rw [hpow, sub_self]
  · subst hb
    have hapos : 0 < a := Nat.pos_of_ne_zero ha
    have hfun : (fun t : ℝ => phiLocalC w p a t * starRingEnd ℂ (phiLocalC w p 0 t)) =
        fun t : ℝ =>
          Complex.exp (Complex.I * ((a : ℤ) : ℂ) * (t : ℂ)) -
          w p * Complex.exp (Complex.I * (((a - 1 : ℕ) : ℤ) : ℂ) * (t : ℂ)) := by
      ext t; simp [phiLocalC, ha]
    rw [hfun, integral_sub (h_int_exp _) ((h_int_exp _).const_mul _), integral_const_mul,
      integral_complexPoissonMeasureOf_exp hp hw (a : ℤ),
      integral_complexPoissonMeasureOf_exp hp hw ((a - 1 : ℕ) : ℤ)]
    simp only [ha, Int.natCast_nonneg, ↓reduceIte, Int.natAbs_natCast]
    have hpow : w p ^ a = w p * w p ^ (a - 1) := by
      conv_lhs => rw [show a = 1 + (a - 1) by omega, pow_add, pow_one]
    rw [hpow, sub_self]
  · have hapos : 0 < a := Nat.pos_of_ne_zero ha
    have hbpos : 0 < b := Nat.pos_of_ne_zero hb
    have hfun : (fun t : ℝ => phiLocalC w p a t * starRingEnd ℂ (phiLocalC w p b t)) =
        fun t : ℝ =>
          (Complex.exp (Complex.I * (((a : ℤ) - (b : ℤ) : ℤ) : ℂ) * (t : ℂ)) -
           starRingEnd ℂ (w p) *
             Complex.exp (Complex.I * (((a : ℤ) - ((b - 1 : ℕ) : ℤ) : ℤ) : ℂ) * (t : ℂ))) -
          (w p * Complex.exp (Complex.I * ((((a - 1 : ℕ) : ℤ) - (b : ℤ) : ℤ) : ℂ) * (t : ℂ)) -
           (w p * starRingEnd ℂ (w p)) *
             Complex.exp (Complex.I * ((((a - 1 : ℕ) : ℤ) - ((b - 1 : ℕ) : ℤ) : ℤ) : ℂ) * (t : ℂ))) := by
      ext t
      simp only [phiLocalC, ha, hb, ↓reduceIte, map_sub, map_mul]
      have c1 := conj_exp_I_mul_int'' (b : ℤ) t
      have c2 := conj_exp_I_mul_int'' ((b - 1 : ℕ) : ℤ) t
      push_cast at c1 c2 ⊢
      rw [c1, c2]
      have m11 : Complex.exp (Complex.I * (a : ℂ) * (t : ℂ)) * Complex.exp (Complex.I * (-(b : ℂ)) * (t : ℂ)) =
          Complex.exp (Complex.I * (((a : ℤ) - (b : ℤ) : ℤ) : ℂ) * (t : ℂ)) := by
        rw [← Complex.exp_add]; congr 1; push_cast; ring
      have m12 : Complex.exp (Complex.I * (a : ℂ) * (t : ℂ)) *
          Complex.exp (Complex.I * (-((b - 1 : ℕ) : ℂ)) * (t : ℂ)) =
          Complex.exp (Complex.I * (((a : ℤ) - ((b - 1 : ℕ) : ℤ) : ℤ) : ℂ) * (t : ℂ)) := by
        rw [← Complex.exp_add]; congr 1; push_cast; ring
      have m21 : Complex.exp (Complex.I * ((a - 1 : ℕ) : ℂ) * (t : ℂ)) *
          Complex.exp (Complex.I * (-(b : ℂ)) * (t : ℂ)) =
          Complex.exp (Complex.I * ((((a - 1 : ℕ) : ℤ) - (b : ℤ) : ℤ) : ℂ) * (t : ℂ)) := by
        rw [← Complex.exp_add]; congr 1; push_cast; ring
      have m22 : Complex.exp (Complex.I * ((a - 1 : ℕ) : ℂ) * (t : ℂ)) *
          Complex.exp (Complex.I * (-((b - 1 : ℕ) : ℂ)) * (t : ℂ)) =
          Complex.exp (Complex.I * ((((a - 1 : ℕ) : ℤ) - ((b - 1 : ℕ) : ℤ) : ℤ) : ℂ) * (t : ℂ)) := by
        rw [← Complex.exp_add]; congr 1; push_cast; ring
      have h_alg :
          (Complex.exp (Complex.I * (a : ℂ) * (t : ℂ)) -
            w p * Complex.exp (Complex.I * ((a - 1 : ℕ) : ℂ) * (t : ℂ))) *
          (Complex.exp (Complex.I * (-(b : ℂ)) * (t : ℂ)) -
            starRingEnd ℂ (w p) * Complex.exp (Complex.I * (-((b - 1 : ℕ) : ℂ)) * (t : ℂ))) =
          (Complex.exp (Complex.I * (a : ℂ) * (t : ℂ)) * Complex.exp (Complex.I * (-(b : ℂ)) * (t : ℂ)) -
           starRingEnd ℂ (w p) * (Complex.exp (Complex.I * (a : ℂ) * (t : ℂ)) *
             Complex.exp (Complex.I * (-((b - 1 : ℕ) : ℂ)) * (t : ℂ)))) -
          (w p * (Complex.exp (Complex.I * ((a - 1 : ℕ) : ℂ) * (t : ℂ)) *
             Complex.exp (Complex.I * (-(b : ℂ)) * (t : ℂ))) -
           (w p * starRingEnd ℂ (w p)) * (Complex.exp (Complex.I * ((a - 1 : ℕ) : ℂ) * (t : ℂ)) *
             Complex.exp (Complex.I * (-((b - 1 : ℕ) : ℂ)) * (t : ℂ)))) := by
        ring
      rw [h_alg, m11, m12, m21, m22]
      push_cast
      rfl
    rw [hfun]
    have hi1 : Integrable (fun t : ℝ =>
        Complex.exp (Complex.I * (((a : ℤ) - (b : ℤ) : ℤ) : ℂ) * (t : ℂ)) -
        starRingEnd ℂ (w p) *
          Complex.exp (Complex.I * (((a : ℤ) - ((b - 1 : ℕ) : ℤ) : ℤ) : ℂ) * (t : ℂ)))
        (complexPoissonMeasureOf w p) :=
      (h_int_exp _).sub ((h_int_exp _).const_mul _)
    have hi2 : Integrable (fun t : ℝ =>
        w p * Complex.exp (Complex.I * ((((a - 1 : ℕ) : ℤ) - (b : ℤ) : ℤ) : ℂ) * (t : ℂ)) -
        (w p * starRingEnd ℂ (w p)) *
          Complex.exp (Complex.I * ((((a - 1 : ℕ) : ℤ) - ((b - 1 : ℕ) : ℤ) : ℤ) : ℂ) * (t : ℂ)))
        (complexPoissonMeasureOf w p) :=
      ((h_int_exp _).const_mul _).sub ((h_int_exp _).const_mul _)
    rw [integral_sub hi1 hi2,
      integral_sub (h_int_exp _) ((h_int_exp _).const_mul _),
      integral_sub ((h_int_exp _).const_mul _) ((h_int_exp _).const_mul _),
      integral_const_mul, integral_const_mul, integral_const_mul,
      integral_complexPoissonMeasureOf_exp hp hw ((a : ℤ) - (b : ℤ)),
      integral_complexPoissonMeasureOf_exp hp hw ((a : ℤ) - ((b - 1 : ℕ) : ℤ)),
      integral_complexPoissonMeasureOf_exp hp hw (((a - 1 : ℕ) : ℤ) - (b : ℤ)),
      integral_complexPoissonMeasureOf_exp hp hw (((a - 1 : ℕ) : ℤ) - ((b - 1 : ℕ) : ℤ))]
    rcases Nat.lt_trichotomy a b with hab | rfl | hab
    · have hne : a ≠ b := by omega
      have h1 : ¬ (0 ≤ (a : ℤ) - (b : ℤ)) := by omega
      have h3 : ¬ (0 ≤ ((a - 1 : ℕ) : ℤ) - (b : ℤ)) := by omega
      have h4 : ¬ (0 ≤ ((a - 1 : ℕ) : ℤ) - ((b - 1 : ℕ) : ℤ)) := by omega
      have hn1 : ((a : ℤ) - (b : ℤ)).natAbs = b - a := by omega
      have hn3 : (((a - 1 : ℕ) : ℤ) - (b : ℤ)).natAbs = b - a + 1 := by omega
      have hn4 : (((a - 1 : ℕ) : ℤ) - ((b - 1 : ℕ) : ℤ)).natAbs = b - a := by omega
      by_cases hab1 : a = b - 1
      · have h2 : (0 : ℤ) ≤ (a : ℤ) - ((b - 1 : ℕ) : ℤ) := by omega
        have hn2 : ((a : ℤ) - ((b - 1 : ℕ) : ℤ)).natAbs = 0 := by omega
        simp only [hne, h1, h2, h3, h4, ↓reduceIte, hn1, hn2, hn3, hn4, pow_zero]
        rw [show b - a = 1 by omega, pow_one, pow_add, pow_one]; ring
      · have h2 : ¬ (0 ≤ (a : ℤ) - ((b - 1 : ℕ) : ℤ)) := by omega
        have hn2 : ((a : ℤ) - ((b - 1 : ℕ) : ℤ)).natAbs = b - 1 - a := by omega
        simp only [hne, h1, h2, h3, h4, ↓reduceIte, hn1, hn2, hn3, hn4]
        have ha1 : (starRingEnd ℂ (w p)) ^ (b - a) =
            starRingEnd ℂ (w p) * (starRingEnd ℂ (w p)) ^ (b - 1 - a) := by
          conv_lhs => rw [show b - a = 1 + (b - 1 - a) by omega, pow_add, pow_one]
        have ha2 : (starRingEnd ℂ (w p)) ^ (b - a + 1) =
            starRingEnd ℂ (w p) * (starRingEnd ℂ (w p)) ^ (b - a) := by
          rw [pow_add, pow_one, mul_comm]
        rw [ha2, ha1]; ring
    · have h1 : (0 : ℤ) ≤ (a : ℤ) - (a : ℤ) := by omega
      have h2 : (0 : ℤ) ≤ (a : ℤ) - ((a - 1 : ℕ) : ℤ) := by omega
      have h3 : ¬ (0 ≤ ((a - 1 : ℕ) : ℤ) - (a : ℤ)) := by omega
      have h4 : (0 : ℤ) ≤ ((a - 1 : ℕ) : ℤ) - ((a - 1 : ℕ) : ℤ) := by omega
      have hn1 : ((a : ℤ) - (a : ℤ)).natAbs = 0 := by omega
      have hn2 : ((a : ℤ) - ((a - 1 : ℕ) : ℤ)).natAbs = 1 := by omega
      have hn3 : (((a - 1 : ℕ) : ℤ) - (a : ℤ)).natAbs = 1 := by omega
      have hn4 : (((a - 1 : ℕ) : ℤ) - ((a - 1 : ℕ) : ℤ)).natAbs = 0 := by omega
      simp only [ha, h1, h2, h3, h4, ↓reduceIte, hn1, hn2, hn3, hn4, pow_zero, pow_one]
      rw [Complex.conj_mul']
      push_cast
      ring
    · have hne : a ≠ b := by omega
      have h1 : 0 ≤ (a : ℤ) - (b : ℤ) := by omega
      have h2 : 0 ≤ (a : ℤ) - ((b - 1 : ℕ) : ℤ) := by omega
      have h3 : 0 ≤ ((a - 1 : ℕ) : ℤ) - (b : ℤ) := by omega
      have h4 : 0 ≤ ((a - 1 : ℕ) : ℤ) - ((b - 1 : ℕ) : ℤ) := by omega
      have hn1 : ((a : ℤ) - (b : ℤ)).natAbs = a - b := by omega
      have hn2 : ((a : ℤ) - ((b - 1 : ℕ) : ℤ)).natAbs = a - b + 1 := by omega
      have hn3 : (((a - 1 : ℕ) : ℤ) - (b : ℤ)).natAbs = a - 1 - b := by omega
      have hn4 : (((a - 1 : ℕ) : ℤ) - ((b - 1 : ℕ) : ℤ)).natAbs = a - b := by omega
      simp only [hne, h1, h2, h3, h4, ↓reduceIte, hn1, hn2, hn3, hn4]
      have ha1 : w p ^ (a - b + 1) = w p * w p ^ (a - b) := by
        rw [pow_add, pow_one, mul_comm]
      have ha2 : w p ^ (a - b) = w p * w p ^ (a - 1 - b) := by
        conv_lhs => rw [show a - b = 1 + (a - 1 - b) by omega, pow_add, pow_one]
      rw [ha1, ha2]; ring

theorem innerNuC_PsiC {w : ℕ → ℂ} (hw : ∀ p, p.Prime → ‖w p‖ < 1)
    {r s : ℕ} (hr : r ≠ 0) (hs : s ≠ 0) :
    innerNuC w (PsiC w r) (PsiC w s) = if r = s then (jWeightC w r : ℂ) else 0 := by
  let S : Finset ℕ := (r * s).primeFactors
  have hS_primes : ∀ p ∈ S, p.Prime := fun p hp => Nat.prime_of_mem_primeFactors hp
  have hr_sub : r.primeFactors ⊆ S := by
    rw [show S = r.primeFactors ∪ s.primeFactors from Nat.primeFactors_mul hr hs]
    exact Finset.subset_union_left
  have hs_sub : s.primeFactors ⊆ S := by
    rw [show S = r.primeFactors ∪ s.primeFactors from Nat.primeFactors_mul hr hs]
    exact Finset.subset_union_right
  have h_prod_eq : ∀ ω : ℕ → ℝ,
      PsiC w r ω * starRingEnd ℂ (PsiC w s ω) =
        ∏ p ∈ S, (phiLocalC w p (r.factorization p) (ω p) *
          starRingEnd ℂ (phiLocalC w p (s.factorization p) (ω p))) := by
    intro ω
    have hPr : PsiC w r ω = ∏ p ∈ S, phiLocalC w p (r.factorization p) (ω p) := by
      unfold PsiC
      refine Finset.prod_subset hr_sub fun p _ hp => ?_
      have hz : r.factorization p = 0 :=
        Finsupp.notMem_support_iff.mp (by simpa [Nat.support_factorization] using hp)
      simp [hz]
    have hPs : starRingEnd ℂ (PsiC w s ω) =
        ∏ p ∈ S, starRingEnd ℂ (phiLocalC w p (s.factorization p) (ω p)) := by
      unfold PsiC
      rw [map_prod]
      refine Finset.prod_subset hs_sub fun p _ hp => ?_
      have hz : s.factorization p = 0 :=
        Finsupp.notMem_support_iff.mp (by simpa [Nat.support_factorization] using hp)
      simp [hz]
    rw [hPr, hPs, ← Finset.prod_mul_distrib]
  have h_meas : ∀ p ∈ S,
      AEStronglyMeasurable
        (fun t => phiLocalC w p (r.factorization p) t *
          starRingEnd ℂ (phiLocalC w p (s.factorization p) t))
        (complexPoissonMeasureOf w p) := by
    intro p _
    exact ((phiLocalC_continuous w p _).mul
      (Complex.continuous_conj.comp (phiLocalC_continuous w p _))).aestronglyMeasurable
  unfold innerNuC
  simp_rw [h_prod_eq]
  rw [integral_finset_prod_primeTorusC w S _ h_meas]
  have h_factor : ∀ p ∈ S,
      (∫ t, phiLocalC w p (r.factorization p) t *
          starRingEnd ℂ (phiLocalC w p (s.factorization p) t) ∂(complexPoissonMeasureOf w p)) =
        if r.factorization p = s.factorization p then
          (if r.factorization p = 0 then (1 : ℂ) else ((1 - ‖w p‖ ^ 2 : ℝ) : ℂ))
        else 0 := fun p hp =>
    single_prime_phiLocalC_inner (hS_primes p hp) (hw p (hS_primes p hp)) _ _
  rw [Finset.prod_congr rfl h_factor]
  by_cases hrs : r = s
  · subst hrs
    simp only [↓reduceIte]
    unfold jWeightC
    rw [Complex.ofReal_prod]
    have hS_eq : S = r.primeFactors := by
      dsimp [S]; rw [Nat.primeFactors_mul hr hr, Finset.union_self]
    rw [hS_eq]
    refine Finset.prod_congr rfl fun p hp => ?_
    have hpos : r.factorization p ≠ 0 :=
      (Nat.Prime.factorization_pos_of_dvd (Nat.prime_of_mem_primeFactors hp) hr
        (Nat.dvd_of_mem_primeFactors hp)).ne'
    simp only [↓reduceIte, hpos]
  · simp only [hrs, ↓reduceIte]
    have hne_fac : r.factorization ≠ s.factorization := by
      intro heq
      exact hrs (Nat.factorization_inj hr hs heq)
    have hex : ∃ p ∈ S, r.factorization p ≠ s.factorization p := by
      by_contra hall
      push Not at hall
      apply hne_fac
      ext p
      by_cases hpS : p ∈ S
      · exact hall p hpS
      · have hpr : r.factorization p = 0 :=
          Finsupp.notMem_support_iff.mp (fun hm => hpS (hr_sub (by simpa [Nat.support_factorization] using hm)))
        have hps : s.factorization p = 0 :=
          Finsupp.notMem_support_iff.mp (fun hm => hpS (hs_sub (by simpa [Nat.support_factorization] using hm)))
        exact hpr.trans hps.symm
    obtain ⟨p₀, hp₀, hne⟩ := hex
    refine Finset.prod_eq_zero hp₀ ?_
    simp [hne]

private lemma PsiC_prime_pow (w : ℕ → ℂ) {p k : ℕ} (hp : p.Prime) (ω : ℕ → ℝ) :
    PsiC w (p ^ k) ω = phiLocalC w p k (ω p) := by
  by_cases hk : k = 0
  · subst hk; simp
  · unfold PsiC
    rw [Nat.primeFactors_prime_pow hk hp, Finset.prod_singleton, hp.factorization_pow,
      Finsupp.single_eq_same]

private lemma PsiC_mul_coprime (w : ℕ → ℂ) {m n : ℕ} (hm : m ≠ 0) (hn : n ≠ 0)
    (hmn : m.Coprime n) (ω : ℕ → ℝ) :
    PsiC w (m * n) ω = PsiC w m ω * PsiC w n ω := by
  unfold PsiC
  have hdisj : Disjoint m.primeFactors n.primeFactors := hmn.disjoint_primeFactors
  rw [Nat.primeFactors_mul hm hn, Finset.prod_union hdisj]
  congr 1
  · refine Finset.prod_congr rfl fun p hp => ?_
    rw [Nat.factorization_mul hm hn, Finsupp.coe_add, Pi.add_apply]
    have hn0 : n.factorization p = 0 :=
      Finsupp.notMem_support_iff.mp (fun hm' => Finset.disjoint_left.mp hdisj hp
        (by simpa [Nat.support_factorization] using hm'))
    simp [hn0]
  · refine Finset.prod_congr rfl fun p hp => ?_
    rw [Nat.factorization_mul hm hn, Finsupp.coe_add, Pi.add_apply]
    have hm0 : m.factorization p = 0 :=
      Finsupp.notMem_support_iff.mp (fun hm' => Finset.disjoint_right.mp hdisj hp
        (by simpa [Nat.support_factorization] using hm'))
    simp [hm0]

private def ZArithC (ω : ℕ → ℝ) : ArithmeticFunction ℂ :=
  ⟨fun n => if n = 0 then 0 else Z n ω, by simp⟩

private theorem ZArithC_isMultiplicative (ω : ℕ → ℝ) : (ZArithC ω).IsMultiplicative := by
  refine ⟨by simp [ZArithC], fun {m n} _ => ?_⟩
  by_cases hm : m = 0
  · subst hm; simp [ZArithC]
  · by_cases hn : n = 0
    · subst hn; simp [ZArithC]
    · simp [ZArithC, hm, hn, mul_ne_zero hm hn, Z_mul hm hn ω]

theorem Z_eq_sum_PsiC (w : ℕ → ℂ) {n : ℕ} (hn : n ≠ 0) (ω : ℕ → ℝ) :
    Z n ω = ∑ r ∈ n.divisors, wProd w (n / r) * PsiC w r ω := by
  let A : ArithmeticFunction ℂ := ⟨fun k => if k = 0 then 0 else wProd w k, by simp⟩
  let P : ArithmeticFunction ℂ := ⟨fun r => if r = 0 then 0 else PsiC w r ω, by simp⟩
  have hA_mult : A.IsMultiplicative := by
    refine ⟨by simp [A], fun {a b} _ => ?_⟩
    by_cases ha : a = 0
    · subst ha; simp [A]
    · by_cases hb : b = 0
      · subst hb; simp [A]
      · simp [A, ha, hb, mul_ne_zero ha hb, wProd_mul w ha hb]
  have hP_mult : P.IsMultiplicative := by
    refine ⟨by simp [P], fun {a b} hab => ?_⟩
    by_cases ha : a = 0
    · subst ha; simp [P]
    · by_cases hb : b = 0
      · subst hb; simp [P]
      · simp [P, ha, hb, mul_ne_zero ha hb, PsiC_mul_coprime w ha hb hab ω]
  let Q : ArithmeticFunction ℂ := P * A
  have hQ_mult : Q.IsMultiplicative := hP_mult.mul hA_mult
  have hQ_apply : ∀ k : ℕ, k ≠ 0 →
      Q k = ∑ r ∈ k.divisors, wProd w (k / r) * PsiC w r ω := by
    intro k hk
    have hQ_eq : Q k = (A * P) k := by simp [Q, mul_comm]
    rw [hQ_eq, ArithmeticFunction.mul_apply,
      Nat.sum_divisorsAntidiagonal' (f := fun x y => A x * P y)]
    refine Finset.sum_congr rfl fun r hr => ?_
    have hr0 : r ≠ 0 := ne_zero_of_dvd_ne_zero hk (Nat.dvd_of_mem_divisors hr)
    have hkr0 : k / r ≠ 0 :=
      Nat.div_ne_zero_iff.mpr ⟨hr0, Nat.le_of_dvd (Nat.pos_of_ne_zero hk) (Nat.dvd_of_mem_divisors hr)⟩
    simp [A, P, hr0, hkr0]
  have hZ_mult : (ZArithC ω).IsMultiplicative := ZArithC_isMultiplicative ω
  have h_eq_Q : Q n = Z n ω := by
    have hpair : (n.primeFactors : Set ℕ).Pairwise
        (fun p q => Nat.Coprime (p ^ n.factorization p) (q ^ n.factorization q)) := by
      intro p hp q hq hpq
      exact Nat.Coprime.pow _ _
        ((Nat.coprime_primes (Nat.prime_of_mem_primeFactors hp) (Nat.prime_of_mem_primeFactors hq)).mpr hpq)
    have hz_prod : Z n ω = ∏ p ∈ n.primeFactors, Z (p ^ n.factorization p) ω := by
      conv_lhs => rw [Nat.prod_primeFactors_pow_factorization hn]
      have hmult := hZ_mult.map_prod (fun p => p ^ n.factorization p) n.primeFactors hpair
      have hn_prod_nz : (∏ p ∈ n.primeFactors, p ^ n.factorization p) ≠ 0 := by
        rw [← Nat.prod_primeFactors_pow_factorization hn]; exact hn
      calc Z (∏ p ∈ n.primeFactors, p ^ n.factorization p) ω
          = ZArithC ω (∏ p ∈ n.primeFactors, p ^ n.factorization p) := by
            simp [ZArithC, hn_prod_nz]
        _ = ∏ p ∈ n.primeFactors, ZArithC ω (p ^ n.factorization p) := hmult
        _ = ∏ p ∈ n.primeFactors, Z (p ^ n.factorization p) ω :=
            Finset.prod_congr rfl fun p hp => by
              have hp0 : p ≠ 0 := (Nat.prime_of_mem_primeFactors hp).ne_zero
              simp [ZArithC, hp0]
    conv_lhs => rw [Nat.prod_primeFactors_pow_factorization hn, hQ_mult.map_prod _ _ hpair]
    rw [hz_prod]
    refine Finset.prod_congr rfl fun p hp => ?_
    have hprime : p.Prime := Nat.prime_of_mem_primeFactors hp
    have hpk0 : p ^ n.factorization p ≠ 0 := pow_ne_zero _ hprime.ne_zero
    rw [hQ_apply _ hpk0, Nat.sum_divisors_prime_pow hprime]
    have htelescope : ∀ k : ℕ,
        ∑ i ∈ Finset.range (k + 1), wProd w (p ^ k / p ^ i) * PsiC w (p ^ i) ω =
          Z (p ^ k) ω := by
      intro k
      induction k with
      | zero => simp
      | succ m ih =>
        rw [Finset.sum_range_succ]
        have h_last : wProd w (p ^ (m + 1) / p ^ (m + 1)) * PsiC w (p ^ (m + 1)) ω =
            Z (p ^ (m + 1)) ω - w p * Z (p ^ m) ω := by
          rw [Nat.div_self (pow_pos hprime.pos _), wProd_one, one_mul,
            PsiC_prime_pow w hprime, Z_prime_pow hprime, Z_prime_pow hprime]
          simp only [phiLocalC, Nat.add_eq_zero_iff, one_ne_zero, and_false, ↓reduceIte,
            Nat.add_sub_cancel]
          have heq1 : Complex.exp (Complex.I * ((m + 1 : ℕ) : ℂ) * (ω p : ℂ)) = phasor p ω ^ (m + 1) := by
            unfold phasor; rw [← Complex.exp_nat_mul]; congr 1; push_cast; ring
          have heq0 : Complex.exp (Complex.I * (m : ℂ) * (ω p : ℂ)) = phasor p ω ^ m := by
            unfold phasor; rw [← Complex.exp_nat_mul]; congr 1; ring
          rw [heq1, heq0]
        have h_head : (∑ i ∈ Finset.range (m + 1),
              wProd w (p ^ (m + 1) / p ^ i) * PsiC w (p ^ i) ω) =
            w p * Z (p ^ m) ω := by
          calc (∑ i ∈ Finset.range (m + 1),
                  wProd w (p ^ (m + 1) / p ^ i) * PsiC w (p ^ i) ω)
              = ∑ i ∈ Finset.range (m + 1),
                  w p * (wProd w (p ^ m / p ^ i) * PsiC w (p ^ i) ω) := by
                refine Finset.sum_congr rfl fun i hi => ?_
                have him : i ≤ m := Nat.lt_succ_iff.mp (Finset.mem_range.mp hi)
                rw [Nat.pow_div (by omega) hprime.pos, Nat.pow_div him hprime.pos,
                  wProd_prime_pow w hprime, wProd_prime_pow w hprime,
                  show m + 1 - i = (m - i) + 1 by omega, pow_succ]
                ring
            _ = w p * ∑ i ∈ Finset.range (m + 1),
                  wProd w (p ^ m / p ^ i) * PsiC w (p ^ i) ω := (Finset.mul_sum ..).symm
            _ = w p * Z (p ^ m) ω := by rw [ih]
        rw [h_head, h_last, add_sub_cancel]
    exact htelescope (n.factorization p)
  rw [← hQ_apply n hn, h_eq_Q]

def scalarSC (w : ℕ → ℂ) (B n : ℕ) : ℂ :=
  ∑ k ∈ (Finset.Icc 1 n).filter (fun k => Nat.Coprime k B), (CoherentEnergyMeasure.mertens (n / k) : ℂ) * wProd w k

def energyC (w : ℕ → ℂ) (B X : ℕ) : ℝ :=
  ∑ r ∈ (Finset.Icc 1 X).filter (fun r => Nat.Coprime r B), jWeightC w r * ‖scalarSC w B (X / r)‖ ^ 2

theorem D_eq_sum_PsiC (w : ℕ → ℂ) {B : ℕ} (hB : 1 ≤ B) (X : ℕ) (ω : ℕ → ℝ) :
    D B X ω =
      ∑ r ∈ (Finset.Icc 1 X).filter (fun r => Nat.Coprime r B),
        scalarSC w B (X / r) * PsiC w r ω := by
  rw [D_eq_mertens_sum hB X ω]
  have hbox_L :
      (∑ d ∈ (Finset.Icc 1 X).filter (fun d => Nat.Coprime d B), (CoherentEnergyMeasure.mertens (X / d) : ℂ) * Z d ω) =
        ∑ d ∈ Finset.Icc 1 X, ∑ r ∈ Finset.Icc 1 X,
          if d.Coprime B ∧ r ∣ d then
            (CoherentEnergyMeasure.mertens (X / d) : ℂ) * wProd w (d / r) * PsiC w r ω
          else 0 := by
    rw [Finset.sum_filter]
    refine Finset.sum_congr rfl fun d hd => ?_
    have hd_pos : 0 < d := (Finset.mem_Icc.mp hd).1
    have hd_le : d ≤ X := (Finset.mem_Icc.mp hd).2
    by_cases hdc : d.Coprime B
    · rw [ite_eq_left hdc, Z_eq_sum_PsiC w hd_pos.ne' ω, Finset.mul_sum]
      have heq_set : d.divisors = (Finset.Icc 1 X).filter (fun r => r ∣ d) := by
        ext r
        simp only [Nat.mem_divisors, Finset.mem_filter, Finset.mem_Icc]
        constructor
        · intro hr; exact ⟨⟨Nat.pos_of_dvd_of_pos hr.1 hd_pos, (Nat.le_of_dvd hd_pos hr.1).trans hd_le⟩, hr.1⟩
        · intro hr; exact ⟨hr.2, hd_pos.ne'⟩
      rw [heq_set, Finset.sum_filter]
      refine Finset.sum_congr rfl fun r _ => ?_
      by_cases hrd : r ∣ d
      · rw [ite_eq_left hrd, ite_eq_left ⟨hdc, hrd⟩]; ring
      · rw [ite_eq_right hrd, ite_eq_right (fun h => hrd h.2)]
    · rw [ite_eq_right hdc]
      symm
      refine Finset.sum_eq_zero fun r _ => ?_
      rw [ite_eq_right (fun h => hdc h.1)]
  have hbox_R :
      (∑ r ∈ (Finset.Icc 1 X).filter (fun r => Nat.Coprime r B), scalarSC w B (X / r) * PsiC w r ω) =
        ∑ r ∈ Finset.Icc 1 X, ∑ d ∈ Finset.Icc 1 X,
          if d.Coprime B ∧ r ∣ d then
            (CoherentEnergyMeasure.mertens (X / d) : ℂ) * wProd w (d / r) * PsiC w r ω
          else 0 := by
    rw [Finset.sum_filter]
    refine Finset.sum_congr rfl fun r hr => ?_
    have hr_pos : 0 < r := (Finset.mem_Icc.mp hr).1
    by_cases hrc : r.Coprime B
    · rw [ite_eq_left hrc]
      unfold scalarSC
      rw [Finset.sum_filter, Finset.sum_mul]
      have h_rk :
          (∑ k ∈ Finset.Icc 1 (X / r),
              (if k.Coprime B then (CoherentEnergyMeasure.mertens ((X / r) / k) : ℂ) * wProd w k else 0) * PsiC w r ω) =
            ∑ d ∈ Finset.Icc 1 X,
              if d.Coprime B ∧ r ∣ d then
                (CoherentEnergyMeasure.mertens (X / d) : ℂ) * wProd w (d / r) * PsiC w r ω
              else 0 := by
        symm
        calc (∑ d ∈ Finset.Icc 1 X,
                if d.Coprime B ∧ r ∣ d then
                  (CoherentEnergyMeasure.mertens (X / d) : ℂ) * wProd w (d / r) * PsiC w r ω
                else 0)
            = ∑ d ∈ Finset.Icc 1 X, ∑ k ∈ Finset.Icc 1 (X / r),
                if r * k = d ∧ k.Coprime B then
                  (CoherentEnergyMeasure.mertens (X / d) : ℂ) * wProd w (d / r) * PsiC w r ω
                else 0 := by
              refine Finset.sum_congr rfl fun d hd => ?_
              have hd_pos : 0 < d := (Finset.mem_Icc.mp hd).1
              have hd_le : d ≤ X := (Finset.mem_Icc.mp hd).2
              by_cases hdiv : r ∣ d
              · let k₀ := d / r
                have hk₀_eq : r * k₀ = d := Nat.mul_div_cancel' hdiv
                have hk₀_pos : 0 < k₀ := Nat.div_pos (Nat.le_of_dvd hd_pos hdiv) hr_pos
                have hk₀_le : k₀ ≤ X / r := Nat.div_le_div_right hd_le
                have hk₀_mem : k₀ ∈ Finset.Icc 1 (X / r) := Finset.mem_Icc.mpr ⟨hk₀_pos, hk₀_le⟩
                rw [Finset.sum_eq_single k₀]
                · have hcop_iff : d.Coprime B ↔ k₀.Coprime B := by
                    rw [← hk₀_eq, Nat.coprime_mul_iff_left]
                    exact ⟨fun h => h.2, fun h => ⟨hrc, h⟩⟩
                  by_cases hk₀c : k₀.Coprime B
                  · rw [ite_eq_left ⟨hcop_iff.mpr hk₀c, hdiv⟩, ite_eq_left ⟨hk₀_eq, hk₀c⟩]
                  · rw [ite_eq_right (fun h => hk₀c (hcop_iff.mp h.1)), ite_eq_right (fun h => hk₀c h.2)]
                · intro k _ hkne
                  have hnot : ¬ (r * k = d ∧ k.Coprime B) := by
                    rintro ⟨hrk, _⟩
                    exact hkne (Nat.eq_of_mul_eq_mul_left hr_pos (hrk.trans hk₀_eq.symm))
                  rw [ite_eq_right hnot]
                · intro hk_nmem; exact absurd hk₀_mem hk_nmem
              · have hzero : ∀ k ∈ Finset.Icc 1 (X / r),
                    (if r * k = d ∧ k.Coprime B then
                      (CoherentEnergyMeasure.mertens (X / d) : ℂ) * wProd w (d / r) * PsiC w r ω
                    else 0) = 0 := by
                  intro k _
                  have hnot : ¬ (r * k = d ∧ k.Coprime B) := fun ⟨hrk, _⟩ => hdiv ⟨k, hrk.symm⟩
                  rw [ite_eq_right hnot]
                rw [Finset.sum_eq_zero hzero, ite_eq_right (fun h => hdiv h.2)]
          _ = ∑ k ∈ Finset.Icc 1 (X / r), ∑ d ∈ Finset.Icc 1 X,
                if r * k = d ∧ k.Coprime B then
                  (CoherentEnergyMeasure.mertens (X / d) : ℂ) * wProd w (d / r) * PsiC w r ω
                else 0 := Finset.sum_comm
          _ = ∑ k ∈ Finset.Icc 1 (X / r),
                (if k.Coprime B then (CoherentEnergyMeasure.mertens ((X / r) / k) : ℂ) * wProd w k else 0) * PsiC w r ω := by
              refine Finset.sum_congr rfl fun k hk => ?_
              have hk_pos : 0 < k := (Finset.mem_Icc.mp hk).1
              have hk_le : k ≤ X / r := (Finset.mem_Icc.mp hk).2
              have hrk_le : r * k ≤ X := by
                calc r * k = k * r := mul_comm r k
                  _ ≤ X := (Nat.le_div_iff_mul_le hr_pos).mp hk_le
              have hrk_mem : r * k ∈ Finset.Icc 1 X := Finset.mem_Icc.mpr ⟨Nat.mul_pos hr_pos hk_pos, hrk_le⟩
              rw [Finset.sum_eq_single (r * k)]
              · by_cases hkc : k.Coprime B
                · rw [ite_eq_left ⟨rfl, hkc⟩, ite_eq_left hkc,
                    Nat.mul_div_cancel_left k hr_pos, Nat.div_div_eq_div_mul]
                · rw [ite_eq_right (fun h => hkc h.2), ite_eq_right hkc, zero_mul]
              · intro d _ hdne
                rw [ite_eq_right (fun h => hdne h.1.symm)]
              · intro hm; exact absurd hrk_mem hm
      exact h_rk
    · rw [ite_eq_right hrc]
      symm
      refine Finset.sum_eq_zero fun d _ => ?_
      have hnot : ¬ (d.Coprime B ∧ r ∣ d) := fun ⟨hdc, hrd⟩ => hrc (hdc.coprime_dvd_left hrd)
      rw [ite_eq_right hnot]
  rw [hbox_L, hbox_R, Finset.sum_comm]

private lemma norm_phiLocalC_le_two {w : ℕ → ℂ} (hw : ∀ p, p.Prime → ‖w p‖ < 1)
    {p : ℕ} (hp : p.Prime) (a : ℕ) (t : ℝ) : ‖phiLocalC w p a t‖ ≤ 2 := by
  unfold phiLocalC
  split_ifs
  · norm_num
  · have h1 : ‖Complex.exp (Complex.I * (a : ℂ) * (t : ℂ))‖ = 1 := by
      simpa [mul_assoc] using norm_exp_I_mul_real'' ((a : ℝ) * t)
    have h2 : ‖w p * Complex.exp (Complex.I * ((a - 1 : ℕ) : ℂ) * (t : ℂ))‖ ≤ 1 := by
      rw [norm_mul, show ‖Complex.exp (Complex.I * ((a - 1 : ℕ) : ℂ) * (t : ℂ))‖ = 1 by
        simpa [mul_assoc] using norm_exp_I_mul_real'' (((a - 1 : ℕ) : ℝ) * t), mul_one]
      exact (hw p hp).le
    calc ‖Complex.exp (Complex.I * (a : ℂ) * (t : ℂ)) -
            w p * Complex.exp (Complex.I * ((a - 1 : ℕ) : ℂ) * (t : ℂ))‖
        ≤ ‖Complex.exp (Complex.I * (a : ℂ) * (t : ℂ))‖ +
            ‖w p * Complex.exp (Complex.I * ((a - 1 : ℕ) : ℂ) * (t : ℂ))‖ := norm_sub_le _ _
      _ ≤ 1 + 1 := add_le_add (le_of_eq h1) h2
      _ = 2 := by norm_num

private lemma PsiC_continuous (w : ℕ → ℂ) (r : ℕ) : Continuous (PsiC w r) := by
  unfold PsiC
  exact continuous_finsetProd _ fun p _ => (phiLocalC_continuous w p _).comp (continuous_apply p)

private lemma norm_PsiC_le {w : ℕ → ℂ} (hw : ∀ p, p.Prime → ‖w p‖ < 1)
    (r : ℕ) (ω : ℕ → ℝ) : ‖PsiC w r ω‖ ≤ (2 : ℝ) ^ r.primeFactors.card := by
  have hprod (T : Finset ℕ) (hT : T ⊆ r.primeFactors) :
      ∏ p ∈ T, ‖phiLocalC w p (r.factorization p) (ω p)‖ ≤ (2 : ℝ) ^ T.card := by
    induction T using Finset.cons_induction with
    | empty => simp
    | cons p s hp ih =>
      have hps : p ∈ r.primeFactors := hT (Finset.mem_cons_self p s)
      have hs_sub : s ⊆ r.primeFactors := fun q hq => hT (Finset.mem_cons_of_mem hq)
      simp only [Finset.prod_cons, Finset.card_cons, pow_succ']
      exact mul_le_mul (norm_phiLocalC_le_two hw (Nat.prime_of_mem_primeFactors hps) _ _)
        (ih hs_sub) (Finset.prod_nonneg fun _ _ => norm_nonneg _) (by norm_num)
  unfold PsiC
  rw [norm_prod]
  exact hprod r.primeFactors (fun _ h => h)

theorem mean_D_eq_scalarSC {w : ℕ → ℂ} (hw : ∀ p, p.Prime → ‖w p‖ < 1)
    {B : ℕ} (hB : 1 ≤ B) (X : ℕ) :
    ∫ ω, D B X ω ∂(primeTorusMeasureC w) = scalarSC w B X := by
  let T := (Finset.Icc 1 X).filter (fun r => Nat.Coprime r B)
  have hD_eq : ∀ ω : ℕ → ℝ, D B X ω = ∑ r ∈ T, scalarSC w B (X / r) * PsiC w r ω :=
    fun ω => D_eq_sum_PsiC w hB X ω
  have h_int : ∀ r : ℕ, Integrable (fun ω : ℕ → ℝ => scalarSC w B (X / r) * PsiC w r ω)
      (primeTorusMeasureC w) := by
    intro r
    exact Integrable.of_bound
      ((continuous_const.mul (PsiC_continuous w r)).aestronglyMeasurable)
      (‖scalarSC w B (X / r)‖ * (2 : ℝ) ^ r.primeFactors.card) (ae_of_all _ fun ω => by
        rw [norm_mul]; exact mul_le_mul_of_nonneg_left (norm_PsiC_le hw r ω) (norm_nonneg _))
  calc ∫ ω, D B X ω ∂(primeTorusMeasureC w)
      = ∫ ω, ∑ r ∈ T, scalarSC w B (X / r) * PsiC w r ω ∂(primeTorusMeasureC w) := by
        congr 1; ext ω; exact hD_eq ω
    _ = ∑ r ∈ T, ∫ ω, scalarSC w B (X / r) * PsiC w r ω ∂(primeTorusMeasureC w) :=
        integral_finsetSum T fun r _ => h_int r
    _ = ∑ r ∈ T, scalarSC w B (X / r) * ∫ ω, PsiC w r ω ∂(primeTorusMeasureC w) := by
        refine Finset.sum_congr rfl fun r _ => integral_const_mul _ _
    _ = scalarSC w B X := by
        by_cases hX : X = 0
        · subst hX; simp [T, scalarSC]
        · have hXpos : 1 ≤ X := Nat.pos_of_ne_zero hX
          have hmem : 1 ∈ T := by simp [T, hXpos]
          rw [Finset.sum_eq_single 1]
          · rw [integral_PsiC hw one_ne_zero]; simp
          · intro r hr hr1
            have hr0 : r ≠ 0 := Nat.ne_of_gt (Finset.mem_Icc.mp (Finset.mem_filter.mp hr).1).1
            rw [integral_PsiC hw hr0, ite_eq_right hr1, mul_zero]
          · intro hnm; exact absurd hmem hnm

theorem norm_sq_D_eq_energyC {w : ℕ → ℂ} (hw : ∀ p, p.Prime → ‖w p‖ < 1)
    {B : ℕ} (hB : 1 ≤ B) (X : ℕ) :
    ∫ ω, ‖D B X ω‖ ^ 2 ∂(primeTorusMeasureC w) = energyC w B X := by
  let T := (Finset.Icc 1 X).filter (fun r => Nat.Coprime r B)
  have hD_eq : ∀ ω : ℕ → ℝ, D B X ω = ∑ r ∈ T, scalarSC w B (X / r) * PsiC w r ω :=
    fun ω => D_eq_sum_PsiC w hB X ω
  have hPsi_pair_int : ∀ r s : ℕ,
      Integrable (fun ω : ℕ → ℝ =>
        (scalarSC w B (X / r) * PsiC w r ω) *
          starRingEnd ℂ (scalarSC w B (X / s) * PsiC w s ω)) (primeTorusMeasureC w) := by
    intro r s
    have hc : Continuous (fun ω : ℕ → ℝ =>
        (scalarSC w B (X / r) * PsiC w r ω) *
          starRingEnd ℂ (scalarSC w B (X / s) * PsiC w s ω)) :=
      (continuous_const.mul (PsiC_continuous w r)).mul
        (Complex.continuous_conj.comp (continuous_const.mul (PsiC_continuous w s)))
    refine Integrable.of_bound hc.aestronglyMeasurable
      ((‖scalarSC w B (X / r)‖ * (2 : ℝ) ^ r.primeFactors.card) *
        (‖scalarSC w B (X / s)‖ * (2 : ℝ) ^ s.primeFactors.card)) (ae_of_all _ fun ω => ?_)
    rw [norm_mul, RCLike.norm_conj, norm_mul, norm_mul]
    exact mul_le_mul
      (mul_le_mul_of_nonneg_left (norm_PsiC_le hw r ω) (norm_nonneg _))
      (mul_le_mul_of_nonneg_left (norm_PsiC_le hw s ω) (norm_nonneg _))
      (mul_nonneg (norm_nonneg _) (norm_nonneg _))
      (mul_nonneg (norm_nonneg _) (by positivity))
  have hD_cont : Continuous (fun ω : ℕ → ℝ => D B X ω) := by
    simp_rw [hD_eq]
    exact continuous_finsetSum _ fun r _ => continuous_const.mul (PsiC_continuous w r)
  have hD_norm_int : Integrable (fun ω : ℕ → ℝ => ‖D B X ω‖ ^ 2) (primeTorusMeasureC w) := by
    have hD_bound : ∃ C : ℝ, ∀ ω : ℕ → ℝ, ‖D B X ω‖ ^ 2 ≤ C := by
      refine ⟨(∑ r ∈ T, ‖scalarSC w B (X / r)‖ * (2 : ℝ) ^ r.primeFactors.card) ^ 2, fun ω => ?_⟩
      have htri : ‖D B X ω‖ ≤ ∑ r ∈ T, ‖scalarSC w B (X / r)‖ * (2 : ℝ) ^ r.primeFactors.card := by
        rw [hD_eq ω]
        calc ‖∑ r ∈ T, scalarSC w B (X / r) * PsiC w r ω‖
            ≤ ∑ r ∈ T, ‖scalarSC w B (X / r) * PsiC w r ω‖ := norm_sum_le _ _
          _ ≤ ∑ r ∈ T, ‖scalarSC w B (X / r)‖ * (2 : ℝ) ^ r.primeFactors.card := by
              refine Finset.sum_le_sum fun r _ => ?_
              rw [norm_mul]
              exact mul_le_mul_of_nonneg_left (norm_PsiC_le hw r ω) (norm_nonneg _)
      exact pow_le_pow_left₀ (norm_nonneg _) htri 2
    obtain ⟨C, hC⟩ := hD_bound
    refine Integrable.of_bound ((hD_cont.norm.pow 2).aestronglyMeasurable) C (ae_of_all _ fun ω => ?_)
    simpa [Real.norm_of_nonneg (sq_nonneg ‖D B X ω‖)] using hC ω
  have h_complex :
      ((∫ ω, ‖D B X ω‖ ^ 2 ∂(primeTorusMeasureC w) : ℝ) : ℂ) =
        ∑ r ∈ T, ((jWeightC w r * ‖scalarSC w B (X / r)‖ ^ 2 : ℝ) : ℂ) := by
    calc ((∫ ω, ‖D B X ω‖ ^ 2 ∂(primeTorusMeasureC w) : ℝ) : ℂ)
        = ∫ ω, ((‖D B X ω‖ ^ 2 : ℝ) : ℂ) ∂(primeTorusMeasureC w) := by
          simpa using (Complex.ofRealCLM.integral_comp_comm hD_norm_int).symm
      _ = ∫ ω, D B X ω * starRingEnd ℂ (D B X ω) ∂(primeTorusMeasureC w) := by
          congr 1; ext ω; push_cast; exact (Complex.mul_conj' (D B X ω)).symm
      _ = ∫ ω, ∑ r ∈ T, ∑ s ∈ T,
            (scalarSC w B (X / r) * PsiC w r ω) *
              starRingEnd ℂ (scalarSC w B (X / s) * PsiC w s ω) ∂(primeTorusMeasureC w) := by
          congr 1; ext ω
          rw [hD_eq ω, map_sum, Finset.sum_mul]
          refine Finset.sum_congr rfl fun r _ => Finset.mul_sum _ _ _
      _ = ∑ r ∈ T, ∫ ω, ∑ s ∈ T,
            (scalarSC w B (X / r) * PsiC w r ω) *
              starRingEnd ℂ (scalarSC w B (X / s) * PsiC w s ω) ∂(primeTorusMeasureC w) := by
          refine integral_finsetSum T fun r _ => ?_
          exact integrable_finsetSum T fun s _ => hPsi_pair_int r s
      _ = ∑ r ∈ T, ∑ s ∈ T, ∫ ω,
            (scalarSC w B (X / r) * PsiC w r ω) *
              starRingEnd ℂ (scalarSC w B (X / s) * PsiC w s ω) ∂(primeTorusMeasureC w) := by
          refine Finset.sum_congr rfl fun r _ => integral_finsetSum T fun s _ => hPsi_pair_int r s
      _ = ∑ r ∈ T, ∑ s ∈ T,
            (scalarSC w B (X / r) * starRingEnd ℂ (scalarSC w B (X / s))) *
              innerNuC w (PsiC w r) (PsiC w s) := by
          refine Finset.sum_congr rfl fun r _ => Finset.sum_congr rfl fun s _ => ?_
          have heq : (fun ω : ℕ → ℝ =>
              (scalarSC w B (X / r) * PsiC w r ω) *
                starRingEnd ℂ (scalarSC w B (X / s) * PsiC w s ω)) =
              fun ω => (scalarSC w B (X / r) * starRingEnd ℂ (scalarSC w B (X / s))) *
                (PsiC w r ω * starRingEnd ℂ (PsiC w s ω)) := by
            ext ω
            simp only [map_mul]
            ring
          rw [heq, integral_const_mul]
          rfl
      _ = ∑ r ∈ T, ((jWeightC w r * ‖scalarSC w B (X / r)‖ ^ 2 : ℝ) : ℂ) := by
          refine Finset.sum_congr rfl fun r hr => ?_
          have hr_pos : 0 < r := (Finset.mem_Icc.mp (Finset.mem_filter.mp hr).1).1
          rw [Finset.sum_eq_single r]
          · rw [innerNuC_PsiC hw hr_pos.ne' hr_pos.ne']
            simp only [↓reduceIte, Complex.mul_conj', Complex.ofReal_pow, Complex.ofReal_mul]
            ring
          · intro s hs hrs
            have hs_pos : 0 < s := (Finset.mem_Icc.mp (Finset.mem_filter.mp hs).1).1
            rw [innerNuC_PsiC hw hr_pos.ne' hs_pos.ne']
            simp only [hrs.symm, ↓reduceIte, mul_zero]
          · intro hr_nmem; exact absurd hr hr_nmem
  rw [← Complex.ofReal_sum] at h_complex
  exact_mod_cast h_complex

theorem complexPoissonKernel_ofReal {ρ : ℝ} (hρ0 : 0 ≤ ρ) (θ : ℝ) :
    complexPoissonKernel (ρ : ℂ) θ = CoherentEnergyMeasure.poissonKernel ρ θ := by
  unfold complexPoissonKernel CoherentEnergyMeasure.poissonKernel
  rw [Complex.norm_real, Real.norm_of_nonneg hρ0]
  congr 1
  have hcos : ‖Complex.exp (Complex.I * (θ : ℂ)) - (ρ : ℂ)‖ ^ 2 = 1 - 2 * ρ * Real.cos θ + ρ ^ 2 := by
    have he : Complex.exp (Complex.I * (θ : ℂ)) - (ρ : ℂ) =
        ((Real.cos θ - ρ : ℝ) : ℂ) + ((Real.sin θ : ℝ) : ℂ) * Complex.I := by
      rw [mul_comm Complex.I (θ : ℂ), Complex.exp_mul_I]
      simp only [← Complex.ofReal_cos, ← Complex.ofReal_sin]
      push_cast; ring
    have hnormSq : ‖Complex.exp (Complex.I * (θ : ℂ)) - (ρ : ℂ)‖ ^ 2 =
        Complex.normSq (Complex.exp (Complex.I * (θ : ℂ)) - (ρ : ℂ)) :=
      (Complex.normSq_eq_norm_sq _).symm
    rw [hnormSq, he]
    simp only [Complex.normSq_add_mul_I]
    linear_combination Real.sin_sq_add_cos_sq θ
  rw [hcos]

theorem primeTorusMeasureC_ofReal_eq {ρ : ℕ → ℝ} (hρ : ∀ p, p.Prime → 0 ≤ ρ p) :
    primeTorusMeasureC (fun p => (ρ p : ℂ)) = primeTorusMeasureOf ρ := by
  unfold primeTorusMeasureC primeTorusMeasureOf
  refine congrArg Measure.infinitePi (funext fun p => ?_)
  by_cases hp : p.Prime
  · have hr0 : 0 ≤ ρ p := hρ p hp
    have hnorm : ‖(ρ p : ℂ)‖ = ρ p := by rw [Complex.norm_real, Real.norm_of_nonneg hr0]
    by_cases hr1 : ρ p < 1
    · have hc1 : p.Prime ∧ ‖(ρ p : ℂ)‖ < 1 := ⟨hp, by linarith⟩
      have hc2 : p.Prime ∧ 0 ≤ ρ p ∧ ρ p < 1 := ⟨hp, hr0, hr1⟩
      rw [complexPoissonMeasureOf, ite_eq_left hc1, poissonMeasureOf, ite_eq_left hc2]
      congr 1; funext θ; congr 1
      unfold complexPoissonDensityNN poissonDensityNNOf
      rw [complexPoissonKernel_ofReal hr0 θ]
    · have hc1 : ¬ (p.Prime ∧ ‖(ρ p : ℂ)‖ < 1) := fun h => hr1 (hnorm ▸ h.2)
      have hc2 : ¬ (p.Prime ∧ 0 ≤ ρ p ∧ ρ p < 1) := fun h => hr1 h.2.2
      rw [complexPoissonMeasureOf, ite_eq_right hc1, poissonMeasureOf, ite_eq_right hc2]
  · simp [complexPoissonMeasureOf, poissonMeasureOf, hp]

/-! ## 4. The rotated critical-line family w_{σ,t}(p) = p^(-σ - it) -/

def wSigmaT (σ t : ℝ) (p : ℕ) : ℂ :=
  if p = 0 then 0 else (p : ℂ) ^ (-(⟨σ, t⟩ : ℂ))

theorem norm_wSigmaT (σ t : ℝ) {k : ℕ} (hk : 1 ≤ k) :
    ‖wSigmaT σ t k‖ = (k : ℝ) ^ (-σ) := by
  have hk0 : k ≠ 0 := by omega
  have hk_pos : 0 < (k : ℝ) := Nat.cast_pos.mpr hk
  rw [wSigmaT, ite_eq_right hk0, ← Complex.ofReal_natCast, Complex.norm_cpow_eq_rpow_re_of_pos hk_pos]
  simp

theorem wSigmaT_norm_lt_one {σ : ℝ} (hσ : 0 < σ) (t : ℝ) {p : ℕ} (hp : p.Prime) :
    ‖wSigmaT σ t p‖ < 1 := by
  rw [norm_wSigmaT σ t hp.one_le]
  have hp1 : (1 : ℝ) < (p : ℝ) := by exact_mod_cast hp.one_lt
  simpa using Real.rpow_lt_rpow_of_exponent_lt hp1 (show -σ < 0 by linarith)

theorem wProd_wSigmaT (σ t : ℝ) {m : ℕ} (hm : m ≠ 0) :
    wProd (wSigmaT σ t) m = (m : ℂ) ^ (-(⟨σ, t⟩ : ℂ)) := by
  unfold wProd
  have hm_eq : (m : ℂ) ^ (-(⟨σ, t⟩ : ℂ)) =
      (∏ p ∈ m.primeFactors, ((p : ℂ) ^ m.factorization p)) ^ (-(⟨σ, t⟩ : ℂ)) := by
    have h := congr_arg (fun k : ℕ => ((k : ℂ) ^ (-(⟨σ, t⟩ : ℂ))))
      (Nat.prod_primeFactors_pow_factorization hm)
    simp only [Nat.cast_prod, Nat.cast_pow] at h
    exact h
  rw [hm_eq]
  have hprod_c :
      (∏ p ∈ m.primeFactors, ((p : ℂ) ^ m.factorization p)) ^ (-(⟨σ, t⟩ : ℂ)) =
        ∏ p ∈ m.primeFactors, (((p : ℂ) ^ m.factorization p) ^ (-(⟨σ, t⟩ : ℂ))) := by
    have hreal : ∀ (T : Finset ℕ),
        (∏ p ∈ T, ((p : ℝ) ^ m.factorization p : ℝ)) ≥ 0 := fun _ =>
      Finset.prod_nonneg fun q _ => pow_nonneg (Nat.cast_nonneg q) _
    induction m.primeFactors using Finset.cons_induction with
    | empty => simp
    | cons p s hp ih =>
      simp only [Finset.prod_cons]
      have hcast1 : ((p : ℂ) ^ m.factorization p) = (((p : ℝ) ^ m.factorization p : ℝ) : ℂ) := by
        push_cast; rfl
      have hcast2 : (∏ x ∈ s, (x : ℂ) ^ m.factorization x) =
          (((∏ x ∈ s, (x : ℝ) ^ m.factorization x : ℝ)) : ℂ) := by
        push_cast; rfl
      rw [hcast1, hcast2, Complex.mul_cpow_ofReal_nonneg (pow_nonneg (Nat.cast_nonneg p) _) (hreal s),
        ← hcast1, ← hcast2, ih]
  rw [hprod_c]
  refine Finset.prod_congr rfl fun p hp => ?_
  have hp_prime : Nat.Prime p := Nat.prime_of_mem_primeFactors hp
  rw [wSigmaT, ite_eq_right hp_prime.ne_zero, ← Complex.cpow_nat_mul,
    Complex.natCast_cpow_natCast_mul]

/-! ## 5. Complex coprime inverse and transfer with constant ζ(σ + θ) -/

def muC : ArithmeticFunction ℂ := ↑ArithmeticFunction.moebius

def MC (n : ℕ) : ℂ := ∑ j ∈ Finset.Ioc 0 n, muC j

theorem MC_eq_M (n : ℕ) : MC n = (M n : ℂ) := by
  unfold MC M muC muR
  rw [Complex.ofReal_sum]
  refine Finset.sum_congr rfl fun j _ => ?_
  simp

def gSigmaT (σ t : ℝ) (B : ℕ) : ArithmeticFunction ℂ :=
  ⟨fun k => if k = 0 then 0 else if k.Coprime B then (k : ℂ) ^ (-(⟨σ, t⟩ : ℂ)) else 0, by simp⟩

theorem gSigmaT_apply (σ t : ℝ) (B k : ℕ) :
    gSigmaT σ t B k = if k = 0 then 0 else if k.Coprime B then (k : ℂ) ^ (-(⟨σ, t⟩ : ℂ)) else 0 := rfl

theorem gSigmaT_mul (σ t : ℝ) (B j k : ℕ) :
    gSigmaT σ t B (j * k) = gSigmaT σ t B j * gSigmaT σ t B k := by
  by_cases hj0 : j = 0
  · subst hj0; simp [gSigmaT_apply]
  · by_cases hk0 : k = 0
    · subst hk0; simp [gSigmaT_apply]
    · have hjk0 : j * k ≠ 0 := mul_ne_zero hj0 hk0
      simp only [gSigmaT_apply, hj0, hk0, hjk0, ↓reduceIte, Nat.coprime_mul_iff_left, Nat.cast_mul]
      by_cases hj : j.Coprime B <;> by_cases hk : k.Coprime B
      · rw [ite_eq_left ⟨hj, hk⟩, ite_eq_left hj, ite_eq_left hk]
        rw [← Complex.ofReal_natCast j, ← Complex.ofReal_natCast k]
        exact Complex.mul_cpow_ofReal_nonneg (Nat.cast_nonneg j) (Nat.cast_nonneg k) _
      · rw [ite_eq_right (fun h => hk h.2), ite_eq_left hj, ite_eq_right hk, mul_zero]
      · rw [ite_eq_right (fun h => hj h.1), ite_eq_right hj, zero_mul]
      · rw [ite_eq_right (fun h => hj h.1), ite_eq_right hj, zero_mul]

def hSigmaT (σ t : ℝ) (B : ℕ) : ArithmeticFunction ℂ :=
  (gSigmaT σ t B).pmul muC

theorem hSigmaT_apply (σ t : ℝ) (B k : ℕ) :
    hSigmaT σ t B k =
      if k = 0 then 0
      else if k.Coprime B then (ArithmeticFunction.moebius k : ℂ) * (k : ℂ) ^ (-(⟨σ, t⟩ : ℂ))
      else 0 := by
  simp only [hSigmaT, ArithmeticFunction.pmul_apply, gSigmaT_apply, muC]
  by_cases hk0 : k = 0
  · subst hk0; simp
  · by_cases hk : k.Coprime B <;> simp [hk0, hk, mul_comm]

theorem twist_convolution_rotated (σ t : ℝ) (B : ℕ) (u v : ArithmeticFunction ℂ) :
    (gSigmaT σ t B).pmul u * (gSigmaT σ t B).pmul v = (gSigmaT σ t B).pmul (u * v) := by
  ext n
  simp only [ArithmeticFunction.pmul_apply, ArithmeticFunction.mul_apply, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro p hp
  have he : p.1 * p.2 = n := (Nat.mem_divisorsAntidiagonal.mp hp).1
  rw [← he, gSigmaT_mul]
  ring

theorem gSigmaT_convolution_hSigmaT (σ t : ℝ) (B : ℕ) :
    gSigmaT σ t B * hSigmaT σ t B = 1 := by
  have he := twist_convolution_rotated σ t B (↑ArithmeticFunction.zeta : ArithmeticFunction ℂ) muC
  rw [ArithmeticFunction.pmul_zeta,
    show (↑ArithmeticFunction.zeta : ArithmeticFunction ℂ) * muC = 1 from
      ArithmeticFunction.coe_zeta_mul_coe_moebius] at he
  rw [hSigmaT, he]
  ext n
  by_cases hn : n = 1
  · subst n
    simp [ArithmeticFunction.pmul_apply, gSigmaT_apply]
  · simp [ArithmeticFunction.pmul_apply, hn]

def SSigmaT (σ t : ℝ) (B n : ℕ) : ℂ :=
  ∑ j ∈ Finset.Ioc 0 n, (gSigmaT σ t B * muC) j

theorem SSigmaT_from_MC (σ t : ℝ) (B n : ℕ) :
    SSigmaT σ t B n = ∑ k ∈ Finset.Ioc 0 n, gSigmaT σ t B k * MC (n / k) :=
  ArithmeticFunction.sum_Ioc_mul_eq_sum_sum (gSigmaT σ t B) muC n

theorem MC_from_SSigmaT (σ t : ℝ) (B n : ℕ) :
    MC n = ∑ k ∈ Finset.Ioc 0 n, hSigmaT σ t B k * SSigmaT σ t B (n / k) := by
  have hi : hSigmaT σ t B * (gSigmaT σ t B * muC) = muC := by
    rw [← mul_assoc, mul_comm (hSigmaT σ t B) (gSigmaT σ t B), gSigmaT_convolution_hSigmaT, one_mul]
  calc
    MC n = ∑ j ∈ Finset.Ioc 0 n, (hSigmaT σ t B * (gSigmaT σ t B * muC)) j := by rw [hi]; rfl
    _ = _ := ArithmeticFunction.sum_Ioc_mul_eq_sum_sum (hSigmaT σ t B) (gSigmaT σ t B * muC) n

theorem SSigmaT_eq_scalarSC (σ t : ℝ) (B n : ℕ) :
    SSigmaT σ t B n = scalarSC (wSigmaT σ t) B n := by
  rw [SSigmaT_from_MC]
  unfold scalarSC
  have heq : Finset.Icc 1 n = Finset.Ioc 0 n := by
    ext k; simp only [Finset.mem_Icc, Finset.mem_Ioc]; omega
  rw [heq, Finset.sum_filter]
  refine Finset.sum_congr rfl fun k hk => ?_
  have hk_pos : 0 < k := (Finset.mem_Ioc.mp hk).1
  rw [gSigmaT_apply, ite_eq_right hk_pos.ne', wProd_wSigmaT σ t hk_pos.ne', MC_eq_M,
    CoherentEnergyMeasure.mertens_eq_M]
  by_cases hkc : k.Coprime B <;> simp [hkc, mul_comm]

theorem norm_gSigmaT_le (σ t : ℝ) (B : ℕ) {k : ℕ} (hk : 1 ≤ k) :
    ‖gSigmaT σ t B k‖ ≤ 1 / (k : ℝ) ^ σ := by
  have hk0 : k ≠ 0 := by omega
  have hk_pos : 0 < (k : ℝ) := Nat.cast_pos.mpr hk
  rw [gSigmaT_apply, ite_eq_right hk0]
  split_ifs
  · rw [← Complex.ofReal_natCast, Complex.norm_cpow_eq_rpow_re_of_pos hk_pos]
    simp [Real.rpow_neg (Nat.cast_nonneg k), one_div]
  · rw [norm_zero]; positivity

theorem norm_hSigmaT_le (σ t : ℝ) (B : ℕ) {k : ℕ} (hk : 1 ≤ k) :
    ‖hSigmaT σ t B k‖ ≤ 1 / (k : ℝ) ^ σ := by
  have hk0 : k ≠ 0 := by omega
  have hk_pos : 0 < (k : ℝ) := Nat.cast_pos.mpr hk
  rw [hSigmaT_apply, ite_eq_right hk0]
  split_ifs
  · rw [norm_mul, ← Complex.ofReal_natCast, Complex.norm_cpow_eq_rpow_re_of_pos hk_pos]
    simp only [Complex.neg_re, Real.rpow_neg (Nat.cast_nonneg k), one_div]
    have hμ : ‖(ArithmeticFunction.moebius k : ℂ)‖ ≤ 1 := by
      rw [← Complex.ofReal_intCast, Complex.norm_real, Real.norm_eq_abs]
      exact_mod_cast ArithmeticFunction.abs_moebius_le_one (n := k)
    simpa [one_div] using mul_le_mul_of_nonneg_right hμ (inv_nonneg.mpr (Real.rpow_nonneg (Nat.cast_nonneg k) σ))
  · simp; positivity

theorem quotient_sum_explicit_bound_rotated {F G w : ℕ → ℂ} {σ θ A : ℝ}
    (hθ : 0 ≤ θ) (hsum_gt : 1 < σ + θ) (hA : 0 ≤ A)
    (hw : ∀ k : ℕ, 1 ≤ k → ‖w k‖ ≤ 1 / (k : ℝ) ^ σ)
    (hG : ∀ n, G n = ∑ k ∈ Finset.Ioc 0 n, w k * F (n / k))
    (hF : ∀ m : ℕ, 1 ≤ m → ‖F m‖ ≤ A * (m : ℝ) ^ θ) :
    ∀ n : ℕ, 1 ≤ n → ‖G n‖ ≤ (A * pSeries (σ + θ)) * (n : ℝ) ^ θ := by
  let p (k : ℕ) := 1 / (k : ℝ) ^ (σ + θ)
  have hp : Summable p := Real.summable_one_div_nat_rpow.mpr hsum_gt
  intro n _
  have hterm (k : ℕ) (hk : k ∈ Finset.Ioc 0 n) :
      ‖w k * F (n / k)‖ ≤ (A * (n : ℝ) ^ θ) * p k := by
    have hi := Finset.mem_Ioc.mp hk
    have hk1 : 1 ≤ k := hi.1
    have hk' : 0 < (k : ℝ) := Nat.cast_pos.mpr hk1
    have hq : ‖F (n / k)‖ ≤ A * ((n : ℝ) / (k : ℝ)) ^ θ :=
      (hF _ (Nat.div_pos hi.2 hk1)).trans
        (mul_le_mul_of_nonneg_left
          (Real.rpow_le_rpow (Nat.cast_nonneg _) Nat.cast_div_le hθ) hA)
    rw [norm_mul]
    calc
      _ ≤ (1 / (k : ℝ) ^ σ) * (A * ((n : ℝ) / (k : ℝ)) ^ θ) :=
        mul_le_mul (hw k hk1) hq (norm_nonneg _) (by positivity)
      _ = _ := by
        dsimp only [p]
        rw [Real.div_rpow (Nat.cast_nonneg n) hk'.le, Real.rpow_add hk']
        simp only [div_eq_mul_inv, _root_.mul_inv_rev]
        ring
  rw [hG n]
  calc
    _ ≤ ∑ k ∈ Finset.Ioc 0 n, ‖w k * F (n / k)‖ := norm_sum_le _ _
    _ ≤ ∑ k ∈ Finset.Ioc 0 n, (A * (n : ℝ) ^ θ) * p k := Finset.sum_le_sum hterm
    _ = (A * (n : ℝ) ^ θ) * ∑ k ∈ Finset.Ioc 0 n, p k := (Finset.mul_sum ..).symm
    _ ≤ (A * (n : ℝ) ^ θ) * ∑' k, p k := mul_le_mul_of_nonneg_left
      (hp.sum_le_tsum _ (fun k _ => by dsimp [p]; positivity)) (by positivity)
    _ = (A * pSeries (σ + θ)) * (n : ℝ) ^ θ := by
      unfold pSeries; ring

theorem M_power_bound_iff_SSigmaT (σ t : ℝ) (B : ℕ) {θ : ℝ}
    (hθ : 0 ≤ θ) (hsum_gt : 1 < σ + θ) :
    NaturalPowerBound M θ ↔
      (∃ A : ℝ, 0 ≤ A ∧ ∀ n : ℕ, 1 ≤ n → ‖SSigmaT σ t B n‖ ≤ A * (n : ℝ) ^ θ) := by
  constructor
  · rintro ⟨A, hA, hM⟩
    refine ⟨A * pSeries (σ + θ), mul_nonneg hA (tsum_nonneg fun _ => by positivity), ?_⟩
    have hMC : ∀ m : ℕ, 1 ≤ m → ‖MC m‖ ≤ A * (m : ℝ) ^ θ := by
      intro m hm
      rw [MC_eq_M, Complex.norm_real, Real.norm_eq_abs]
      exact hM m hm
    exact quotient_sum_explicit_bound_rotated hθ hsum_gt hA (fun k hk => norm_gSigmaT_le σ t B hk)
      (SSigmaT_from_MC σ t B) hMC
  · rintro ⟨A, hA, hS⟩
    refine ⟨A * pSeries (σ + θ), mul_nonneg hA (tsum_nonneg fun _ => by positivity), ?_⟩
    have hM' := quotient_sum_explicit_bound_rotated hθ hsum_gt hA (fun k hk => norm_hSigmaT_le σ t B hk)
      (MC_from_SSigmaT σ t B) hS
    intro n hn
    simpa only [MC_eq_M, Complex.norm_real, Real.norm_eq_abs] using hM' n hn

/-! ## 6. Squeeze, RH equivalence, and strip criteria at complex rotated centre (σ, t) -/

theorem scalarSC_norm_sq_le_energyC {w : ℕ → ℂ} (hw : ∀ p, p.Prime → ‖w p‖ ≤ 1)
    (B X : ℕ) (hX : 1 ≤ X) :
    ‖scalarSC w B X‖ ^ 2 ≤ energyC w B X := by
  have hm : 1 ∈ (Finset.Icc 1 X).filter (fun r => Nat.Coprime r B) := by simp [hX]
  simpa only [jWeightC_one, Nat.div_one, one_mul, energyC] using
    (Finset.single_le_sum (f := fun r => jWeightC w r * ‖scalarSC w B (X / r)‖ ^ 2)
      (fun r _ => mul_nonneg (jWeightC_nonneg hw r) (sq_nonneg _)) hm)

private lemma sq_rpow_nonneg'' (x : ℝ) (hx : 0 ≤ x) (t : ℝ) : (x ^ t) ^ 2 = x ^ (2 * t) := by
  calc (x ^ t) ^ 2 = (x ^ t) ^ (2 : ℝ) := by norm_num
    _ = x ^ (2 * t) := by rw [← Real.rpow_mul hx, mul_comm t]

theorem energyC_upper {w : ℕ → ℂ} (hw : ∀ p, p.Prime → ‖w p‖ ≤ 1)
    (B X : ℕ) {A θ : ℝ} (hA : 0 ≤ A) (hθ : 1 / 2 < θ)
    (hS : ∀ k : ℕ, 1 ≤ k → ‖scalarSC w B k‖ ≤ A * (k : ℝ) ^ θ) :
    energyC w B X ≤ A ^ 2 * pSeries (2 * θ) * (X : ℝ) ^ (2 * θ) := by
  let T := (Finset.Icc 1 X).filter fun r => Nat.Coprime r B
  have hp : Summable (fun r : ℕ => 1 / (r : ℝ) ^ (2 * θ)) :=
    Real.summable_one_div_nat_rpow.mpr (by linarith)
  have hterm (r : ℕ) (hr : r ∈ T) :
      jWeightC w r * ‖scalarSC w B (X / r)‖ ^ 2 ≤ (A ^ 2 * (X : ℝ) ^ (2 * θ)) * (1 / (r : ℝ) ^ (2 * θ)) := by
    have hi := Finset.mem_Icc.mp (Finset.mem_filter.mp hr).1
    have hr' : 0 < (r : ℝ) := by exact_mod_cast (show 0 < r by omega)
    have hnat : ((X / r : ℕ) : ℝ) ≤ (X : ℝ) / (r : ℝ) := by
      apply (le_div_iff₀ hr').mpr
      exact_mod_cast Nat.div_mul_le_self X r
    have harg : ‖scalarSC w B (X / r)‖ ≤ A * ((X : ℝ) / (r : ℝ)) ^ θ :=
      (hS _ (Nat.div_pos hi.2 (by omega))).trans <|
        mul_le_mul_of_nonneg_left (Real.rpow_le_rpow (Nat.cast_nonneg _) hnat (by linarith)) hA
    have hsquare := pow_le_pow_left₀ (norm_nonneg _) harg 2
    calc
      jWeightC w r * ‖scalarSC w B (X / r)‖ ^ 2 ≤ ‖scalarSC w B (X / r)‖ ^ 2 := by
        simpa only [one_mul] using
          mul_le_mul_of_nonneg_right (jWeightC_le_one hw r) (sq_nonneg ‖scalarSC w B (X / r)‖)
      _ ≤ (A * ((X : ℝ) / (r : ℝ)) ^ θ) ^ 2 := hsquare
      _ = _ := by
        rw [mul_pow, sq_rpow_nonneg'' _ (div_nonneg (Nat.cast_nonneg X) hr'.le),
          Real.div_rpow (Nat.cast_nonneg X) hr'.le]
        ring
  calc
    energyC w B X ≤ ∑ r ∈ T, (A ^ 2 * (X : ℝ) ^ (2 * θ)) * (1 / (r : ℝ) ^ (2 * θ)) := Finset.sum_le_sum hterm
    _ = (A ^ 2 * (X : ℝ) ^ (2 * θ)) * ∑ r ∈ T, 1 / (r : ℝ) ^ (2 * θ) := by rw [Finset.mul_sum]
    _ ≤ (A ^ 2 * (X : ℝ) ^ (2 * θ)) * pSeries (2 * θ) := by
      apply mul_le_mul_of_nonneg_left _ (by positivity)
      exact hp.sum_le_tsum T (fun _ _ => by positivity)
    _ = _ := by ring

theorem all_epsilon_iff_energyC {w : ℕ → ℂ} (hw : ∀ p, p.Prime → ‖w p‖ ≤ 1) (B : ℕ) :
    (∀ ε : ℝ, 0 < ε → ∃ A : ℝ, 0 ≤ A ∧
      ∀ X : ℕ, 1 ≤ X → ‖scalarSC w B X‖ ≤ A * (X : ℝ) ^ (1 / 2 + ε)) ↔
    (∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
      ∀ X : ℕ, 1 ≤ X → energyC w B X ≤ C * (X : ℝ) ^ (1 + δ)) := by
  constructor
  · intro h δ hδ
    obtain ⟨A, hA, hS⟩ := h (δ / 2) (by positivity)
    have he : 2 * (1 / 2 + δ / 2) = 1 + δ := by ring
    refine ⟨A ^ 2 * pSeries (1 + δ), mul_nonneg (sq_nonneg _) (tsum_nonneg fun _ => by positivity), ?_⟩
    intro X _
    simpa only [he] using energyC_upper hw B X hA (show 1 / 2 < 1 / 2 + δ / 2 by linarith) hS
  · intro h ε hε
    obtain ⟨C, hC, hE⟩ := h (2 * ε) (by positivity)
    refine ⟨Real.sqrt C, Real.sqrt_nonneg C, ?_⟩
    intro X hX
    have hb := (scalarSC_norm_sq_le_energyC hw B X hX).trans (hE X hX)
    have ht : (Real.sqrt C * (X : ℝ) ^ (1 / 2 + ε)) ^ 2 = C * (X : ℝ) ^ (1 + 2 * ε) := by
      rw [mul_pow, Real.sq_sqrt hC, sq_rpow_nonneg'' _ (Nat.cast_nonneg X), show 2 * (1 / 2 + ε) = 1 + 2 * ε by ring]
    exact (sq_le_sq₀ (norm_nonneg _) (by positivity)).mp (ht ▸ hb)

theorem rightHalfZeroFree_of_rotated_measure_bound {σ : ℝ} (hσ : 1 / 2 ≤ σ) (t : ℝ)
    {B : ℕ} (hB : 1 ≤ B)
    (hE : ∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
      ∀ X : ℕ, 1 ≤ X →
        ∫ ω, ‖D B X ω‖ ^ 2 ∂(primeTorusMeasureC (wSigmaT σ t)) ≤ C * (X : ℝ) ^ (1 + δ)) :
    RightHalfZeroFree := by
  have hσ_pos : 0 < σ := by linarith
  have hw_lt : ∀ p, p.Prime → ‖wSigmaT σ t p‖ < 1 := fun p hp => wSigmaT_norm_lt_one hσ_pos t hp
  have hw_le : ∀ p, p.Prime → ‖wSigmaT σ t p‖ ≤ 1 := fun p hp => (hw_lt p hp).le
  simp_rw [norm_sq_D_eq_energyC hw_lt hB] at hE
  have hS : ∀ ε : ℝ, 0 < ε → ∃ A : ℝ, 0 ≤ A ∧
      ∀ n : ℕ, 1 ≤ n → ‖SSigmaT σ t B n‖ ≤ A * (n : ℝ) ^ (1 / 2 + ε) := by
    have hS' := (all_epsilon_iff_energyC hw_le B).mpr hE
    intro ε hε
    obtain ⟨A, hA, hb⟩ := hS' ε hε
    exact ⟨A, hA, fun n hn => by simpa only [SSigmaT_eq_scalarSC] using hb n hn⟩
  have hM : ∀ ε : ℝ, 0 < ε → ∃ C : ℝ, 0 ≤ C ∧
      ∀ n : ℕ, 1 ≤ n → |M n| ≤ C * (n : ℝ) ^ (1 / 2 + ε) := by
    intro ε hε
    exact (M_power_bound_iff_SSigmaT σ t B (by linarith) (by linarith)).mpr (hS ε hε)
  exact MertensCriterion.right_zero_free_of_mertens (mertensCancellation_of_natural_power_bounds hM)

theorem coherent_energy_rotated_growth_iff_RH {σ : ℝ} (hσ : 1 / 2 ≤ σ) (t : ℝ) (B : ℕ) :
    (∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
      ∀ X : ℕ, 1 ≤ X → energyC (wSigmaT σ t) B X ≤ C * (X : ℝ) ^ (1 + δ)) ↔
    RiemannHypothesis := by
  have hσ_pos : 0 < σ := by linarith
  have hw_le : ∀ p, p.Prime → ‖wSigmaT σ t p‖ ≤ 1 := fun p hp => (wSigmaT_norm_lt_one hσ_pos t hp).le
  have h_chain :
      (∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
        ∀ X : ℕ, 1 ≤ X → energyC (wSigmaT σ t) B X ≤ C * (X : ℝ) ^ (1 + δ)) ↔
      (∀ ε : ℝ, 0 < ε → ∃ C : ℝ, 0 ≤ C ∧
        ∀ n : ℕ, 1 ≤ n → |M n| ≤ C * (n : ℝ) ^ (1 / 2 + ε)) := by
    rw [← all_epsilon_iff_energyC hw_le B]
    simp_rw [← SSigmaT_eq_scalarSC]
    constructor
    · intro h ε hε
      exact (M_power_bound_iff_SSigmaT σ t B (by linarith) (by linarith)).mpr (h ε hε)
    · intro h ε hε
      exact (M_power_bound_iff_SSigmaT σ t B (by linarith) (by linarith)).mp (h ε hε)
  rw [h_chain]
  exact ⟨fun h => riemannHypothesis_of_mertens (mertensCancellation_of_natural_power_bounds h),
    fun h => natural_mertens_bounds_of_RH h⟩

theorem coherent_energy_rotated_measure_growth_iff_RH {σ : ℝ} (hσ : 1 / 2 ≤ σ) (t : ℝ)
    {B : ℕ} (hB : 1 ≤ B) :
    (∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
      ∀ X : ℕ, 1 ≤ X →
        ∫ ω, ‖D B X ω‖ ^ 2 ∂(primeTorusMeasureC (wSigmaT σ t)) ≤ C * (X : ℝ) ^ (1 + δ)) ↔
      RiemannHypothesis := by
  have hσ_pos : 0 < σ := by linarith
  simp_rw [norm_sq_D_eq_energyC (fun p hp => wSigmaT_norm_lt_one hσ_pos t hp) hB]
  exact coherent_energy_rotated_growth_iff_RH hσ t B

/-- Headline rotated film point: `w_p = p^(-1/2 - it)` for every real `t` and every `B ≥ 1`. -/
theorem coherent_energy_film_point_iff_RH (t : ℝ) {B : ℕ} (hB : 1 ≤ B) :
    (∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
      ∀ X : ℕ, 1 ≤ X →
        ∫ ω, ‖D B X ω‖ ^ 2 ∂(primeTorusMeasureC (wSigmaT (1 / 2) t)) ≤ C * (X : ℝ) ^ (1 + δ)) ↔
      RiemannHypothesis :=
  coherent_energy_rotated_measure_growth_iff_RH (le_refl (1 / 2 : ℝ)) t hB

theorem fixed_strip_iff_rotated_measure_power {σ θ : ℝ} (hσ : 0 < σ)
    (hθ : 1 / 2 ≤ θ) (hθ1 : θ < 1) (hστ : 1 < σ + θ) (t : ℝ) {B : ℕ} (hB : 1 ≤ B) :
    (∀ s : ℂ, θ < s.re → riemannZeta s ≠ 0) ↔
      (∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
        ∀ X : ℕ, 1 ≤ X →
          ∫ ω, ‖D B X ω‖ ^ 2 ∂(primeTorusMeasureC (wSigmaT σ t)) ≤ C * (X : ℝ) ^ (2 * θ + δ)) := by
  have hw_lt : ∀ p, p.Prime → ‖wSigmaT σ t p‖ < 1 := fun p hp => wSigmaT_norm_lt_one hσ t hp
  have hw_le : ∀ p, p.Prime → ‖wSigmaT σ t p‖ ≤ 1 := fun p hp => (hw_lt p hp).le
  simp_rw [norm_sq_D_eq_energyC hw_lt hB]
  constructor
  · intro hStrip δ hδ
    have hM : NaturalPowerBound M (θ + δ / 2) :=
      natural_mertens_bounds_of_strip hStrip hθ hθ1 (δ / 2) (by positivity)
    obtain ⟨A, hA, hS⟩ :=
      (M_power_bound_iff_SSigmaT σ t B (by linarith) (by linarith)).mp hM
    have hS' : ∀ k : ℕ, 1 ≤ k → ‖scalarSC (wSigmaT σ t) B k‖ ≤ A * (k : ℝ) ^ (θ + δ / 2) := by
      intro k hk
      simpa only [← SSigmaT_eq_scalarSC] using hS k hk
    refine ⟨A ^ 2 * pSeries (2 * (θ + δ / 2)),
      mul_nonneg (sq_nonneg A) (tsum_nonneg fun _ => by positivity), fun X _ => ?_⟩
    have he : 2 * (θ + δ / 2) = 2 * θ + δ := by ring
    simpa only [he] using energyC_upper hw_le B X hA (by linarith : 1 / 2 < θ + δ / 2) hS'
  · intro hE s hs
    let ε : ℝ := min ((s.re - θ) / 2) ((1 - θ) / 2)
    have hε : 0 < ε := lt_min (by linarith) (by linarith)
    have hb0 : 0 ≤ θ + ε := by linarith
    have hb1 : θ + ε < 1 := by linarith [min_le_right ((s.re - θ) / 2) ((1 - θ) / 2)]
    have hbs : θ + ε < s.re := by linarith [min_le_left ((s.re - θ) / 2) ((1 - θ) / 2)]
    obtain ⟨C, hC, hBnd⟩ := hE (2 * ε) (by positivity)
    have hS : ∃ A : ℝ, 0 ≤ A ∧ ∀ X : ℕ, 1 ≤ X → ‖SSigmaT σ t B X‖ ≤ A * (X : ℝ) ^ (θ + ε) := by
      refine ⟨Real.sqrt C, Real.sqrt_nonneg C, fun X hX => ?_⟩
      have h1 := (scalarSC_norm_sq_le_energyC hw_le B X hX).trans (hBnd X hX)
      have ht : (Real.sqrt C * (X : ℝ) ^ (θ + ε)) ^ 2 = C * (X : ℝ) ^ (2 * θ + 2 * ε) := by
        rw [mul_pow, Real.sq_sqrt hC, sq_rpow_nonneg'' _ (Nat.cast_nonneg X)]
        congr 1; ring_nf
      exact (sq_le_sq₀ (norm_nonneg _) (by positivity)).mp
        (by rw [SSigmaT_eq_scalarSC]; exact ht ▸ h1)
    have hM := (M_power_bound_iff_SSigmaT σ t B hb0 (by linarith : 1 < σ + (θ + ε))).mpr hS
    exact zero_free_of_natural_mertens_power hb0 hb1 hM s hbs

theorem rotated_measure_of_RH_dir {σ : ℝ} (hσ : 1 / 2 ≤ σ) (t : ℝ) {B : ℕ} (hB : 1 ≤ B)
    (hRH : RiemannHypothesis) :
    ∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
      ∀ X : ℕ, 1 ≤ X →
        ∫ ω, ‖D B X ω‖ ^ 2 ∂(primeTorusMeasureC (wSigmaT σ t)) ≤ C * (X : ℝ) ^ (1 + δ) := by
  have hσ_pos : 0 < σ := by linarith
  have hw_lt : ∀ p, p.Prime → ‖wSigmaT σ t p‖ < 1 := fun p hp => wSigmaT_norm_lt_one hσ_pos t hp
  have hw_le : ∀ p, p.Prime → ‖wSigmaT σ t p‖ ≤ 1 := fun p hp => (hw_lt p hp).le
  have hM := natural_mertens_bounds_of_RH hRH
  have hS : ∀ ε : ℝ, 0 < ε → ∃ A : ℝ, 0 ≤ A ∧
      ∀ X : ℕ, 1 ≤ X → ‖scalarSC (wSigmaT σ t) B X‖ ≤ A * (X : ℝ) ^ (1 / 2 + ε) := by
    intro ε hε
    obtain ⟨A, hA, hBnd⟩ := (M_power_bound_iff_SSigmaT σ t B (by linarith) (by linarith)).mp (hM ε hε)
    exact ⟨A, hA, fun n hn => by simpa only [← SSigmaT_eq_scalarSC] using hBnd n hn⟩
  have hE := (all_epsilon_iff_energyC hw_le B).mp hS
  simpa only [norm_sq_D_eq_energyC hw_lt hB] using hE

theorem RH_of_rotated_measure_dir {σ : ℝ} (hσ : 1 / 2 ≤ σ) (t : ℝ) {B : ℕ} (hB : 1 ≤ B)
    (hE : ∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
      ∀ X : ℕ, 1 ≤ X →
        ∫ ω, ‖D B X ω‖ ^ 2 ∂(primeTorusMeasureC (wSigmaT σ t)) ≤ C * (X : ℝ) ^ (1 + δ)) :
    RiemannHypothesis :=
  RHConnections.PoleCompensation.riemannHypothesis_of_right_zero_free
    (rightHalfZeroFree_of_rotated_measure_bound hσ t hB hE)

end RHConnections.CoherentEnergyRotated
