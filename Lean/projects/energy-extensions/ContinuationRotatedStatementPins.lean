import Verified
import CoherentEnergyMeasure
import CoherentEnergyRHBridge
import CoherentEnergyRadiusMeasure
import CoherentEnergySigmaBridge
import CoherentEnergyReflectionStrip
import CoherentEnergyRotatedCentre
import CoherentEnergyFlipAndAlpha
import FVLTAlphaAmplitudeV1

/-!
# Statement pins for reflection, general-σ strips, one-sided strips, rotated centres, flip, and FVLT alpha

Pure Mathlib-level restatements (`rfl` agreement with repository definitions) pinning R2, R3, R4, R6, and R7
from `ANALYTIC_CONTINUATION_NOTE_v0_1_20261123/NOTE.md` (`#2201` and `#2202`).
-/

open scoped BigOperators ComplexConjugate
open Filter MeasureTheory

namespace ContinuationRotatedStatementPins

/-! ## Independent definitions -/

noncomputable def mertensFn (n : ℕ) : ℝ :=
  ∑ j ∈ Finset.Icc 1 n, (ArithmeticFunction.moebius j : ℝ)

def rightHalfZeroFree : Prop :=
  ∀ s : ℂ, 1 / 2 < s.re → riemannZeta s ≠ 0

noncomputable def rhoSigma (σ : ℝ) (p : ℕ) : ℝ :=
  (p : ℝ) ^ (-σ)

noncomputable def rhoProd (ρ : ℕ → ℝ) (m : ℕ) : ℝ :=
  ∏ p ∈ m.primeFactors, ρ p ^ m.factorization p

noncomputable def scalarRho (ρ : ℕ → ℝ) (B n : ℕ) : ℝ :=
  ∑ k ∈ (Finset.Icc 1 n).filter (fun k => Nat.Coprime k B), mertensFn (n / k) * rhoProd ρ k

noncomputable def weightRho (ρ : ℕ → ℝ) (r : ℕ) : ℝ :=
  ∏ p ∈ r.primeFactors, (1 - ρ p ^ 2)

noncomputable def energyRho (ρ : ℕ → ℝ) (B X : ℕ) : ℝ :=
  ∑ r ∈ (Finset.Icc 1 X).filter (fun r => Nat.Coprime r B), weightRho ρ r * scalarRho ρ B (X / r) ^ 2

noncomputable def poissonRho (ρ : ℕ → ℝ) (p : ℕ) : Measure ℝ :=
  if p.Prime ∧ 0 ≤ ρ p ∧ ρ p < 1 then
    (volume.restrict (Set.Ioc 0 (2 * Real.pi))).withDensity fun θ =>
      ENNReal.ofReal ((2 * Real.pi)⁻¹ *
        ((1 - ρ p ^ 2) / (1 - 2 * ρ p * Real.cos θ + ρ p ^ 2)))
  else Measure.dirac 0

noncomputable def nuRho (ρ : ℕ → ℝ) : Measure (ℕ → ℝ) := Measure.infinitePi (poissonRho ρ)

noncomputable def wProd (w : ℕ → ℂ) (m : ℕ) : ℂ :=
  ∏ p ∈ m.primeFactors, w p ^ m.factorization p

noncomputable def scalarW (w : ℕ → ℂ) (B n : ℕ) : ℂ :=
  ∑ k ∈ (Finset.Icc 1 n).filter (fun k => Nat.Coprime k B), (mertensFn (n / k) : ℂ) * wProd w k

noncomputable def weightW (w : ℕ → ℂ) (r : ℕ) : ℝ :=
  ∏ p ∈ r.primeFactors, (1 - ‖w p‖ ^ 2)

noncomputable def energyW (w : ℕ → ℂ) (B X : ℕ) : ℝ :=
  ∑ r ∈ (Finset.Icc 1 X).filter (fun r => Nat.Coprime r B), weightW w r * ‖scalarW w B (X / r)‖ ^ 2

noncomputable def poissonW (w : ℕ → ℂ) (p : ℕ) : Measure ℝ :=
  if p.Prime ∧ ‖w p‖ < 1 then
    (volume.restrict (Set.Ioc 0 (2 * Real.pi))).withDensity fun θ =>
      ENNReal.ofReal ((2 * Real.pi)⁻¹ *
        ((1 - ‖w p‖ ^ 2) / ‖Complex.exp (Complex.I * (θ : ℂ)) - w p‖ ^ 2))
  else Measure.dirac 0

noncomputable def nuW (w : ℕ → ℂ) : Measure (ℕ → ℝ) := Measure.infinitePi (poissonW w)

noncomputable def wSigmaT (σ t : ℝ) (p : ℕ) : ℂ :=
  if p = 0 then 0 else (p : ℂ) ^ (-(⟨σ, t⟩ : ℂ))

noncomputable def phasorMonomial (d : ℕ) (θ : ℕ → ℝ) : ℂ :=
  ∏ p ∈ d.primeFactors, Complex.exp (Complex.I * (θ p : ℂ)) ^ d.factorization p

noncomputable def window (B X n : ℕ) : ℝ :=
  ∑ b ∈ (∏ p ∈ B.primeFactors, p).divisors,
    if n ≤ X / b then (ArithmeticFunction.moebius b : ℝ) else 0

noncomputable def poly (B X : ℕ) (θ : ℕ → ℝ) : ℂ :=
  ∑ n ∈ (Finset.Icc 1 X).filter (fun n => Nat.Coprime n B),
    (window B X n : ℂ) *
      ∑ d ∈ n.divisors, (ArithmeticFunction.moebius (n / d) : ℂ) * phasorMonomial d θ

/-- Classical `σ = 1` real scalar defined from scratch for one-sided strip extension (R3). -/
noncomputable def scalarOne (B n : ℕ) : ℝ :=
  ∑ k ∈ (Finset.Icc 1 n).filter (fun k => Nat.Coprime k B), mertensFn (n / k) / (k : ℝ)

/-! ## Definitional agreement with repository definitions -/

theorem rightHalfZeroFree_eq :
    rightHalfZeroFree = RHConnections.CoherentEnergyContinuation.RightHalfZeroFree := rfl

theorem rhoSigma_eq (σ : ℝ) :
    rhoSigma σ = RHConnections.CoherentEnergyRadius.rhoSigma σ := rfl

theorem rhoProd_eq (ρ : ℕ → ℝ) (m : ℕ) :
    rhoProd ρ m = RHConnections.CoherentEnergyRadius.rhoProd ρ m := rfl

theorem weightRho_eq (ρ : ℕ → ℝ) (r : ℕ) :
    weightRho ρ r = RHConnections.CoherentEnergyRadius.jWeightOf ρ r := rfl

theorem nuRho_eq (ρ : ℕ → ℝ) :
    nuRho ρ = RHConnections.CoherentEnergyRadius.primeTorusMeasureOf ρ := rfl

theorem wProd_eq (w : ℕ → ℂ) (m : ℕ) :
    wProd w m = RHConnections.CoherentEnergyRotated.wProd w m := rfl

theorem weightW_eq (w : ℕ → ℂ) (r : ℕ) :
    weightW w r = RHConnections.CoherentEnergyRotated.jWeightC w r := rfl

theorem nuW_eq (w : ℕ → ℂ) :
    nuW w = RHConnections.CoherentEnergyRotated.primeTorusMeasureC w := rfl

theorem wSigmaT_eq (σ t : ℝ) :
    wSigmaT σ t = RHConnections.CoherentEnergyRotated.wSigmaT σ t := rfl

theorem poly_eq (B X : ℕ) :
    poly B X = RHConnections.CoherentEnergyMeasure.D B X := rfl

theorem mertensFn_eq (n : ℕ) :
    mertensFn n = RHConnections.CoherentEnergyMeasure.mertens n := by
  unfold mertensFn RHConnections.CoherentEnergyMeasure.mertens
  have h : Finset.Icc 1 n = Finset.Ioc 0 n := by
    ext k; simp only [Finset.mem_Icc, Finset.mem_Ioc]; omega
  rw [h]

theorem scalarRho_eq (ρ : ℕ → ℝ) (B n : ℕ) :
    scalarRho ρ B n = RHConnections.CoherentEnergyRadius.scalarSOf ρ B n := by
  unfold scalarRho RHConnections.CoherentEnergyRadius.scalarSOf
  simp only [mertensFn_eq, rhoProd_eq]

theorem energyRho_eq (ρ : ℕ → ℝ) (B X : ℕ) :
    energyRho ρ B X = RHConnections.CoherentEnergyRadius.energyOf ρ B X := by
  unfold energyRho RHConnections.CoherentEnergyRadius.energyOf
  refine Finset.sum_congr rfl fun r _ => ?_
  rw [weightRho_eq, scalarRho_eq]

theorem scalarW_eq (w : ℕ → ℂ) (B n : ℕ) :
    scalarW w B n = RHConnections.CoherentEnergyRotated.scalarSC w B n := by
  unfold scalarW RHConnections.CoherentEnergyRotated.scalarSC
  simp only [mertensFn_eq, wProd_eq]

theorem energyW_eq (w : ℕ → ℂ) (B X : ℕ) :
    energyW w B X = RHConnections.CoherentEnergyRotated.energyC w B X := by
  unfold energyW RHConnections.CoherentEnergyRotated.energyC
  refine Finset.sum_congr rfl fun r _ => ?_
  rw [weightW_eq, scalarW_eq]

theorem scalarOne_eq (B n : ℕ) :
    scalarOne B n = RHConnections.ArithmeticFourierInversion.S B n := by
  rw [← RHConnections.CoherentEnergyMeasure.scalarS_eq_S]
  unfold scalarOne RHConnections.CoherentEnergyMeasure.scalarS
  simp only [mertensFn_eq]

/-! ## Pinned headline theorems for R2, R3, R4 -/

/-- R2: `RiemannHypothesis ↔ ∀ s, 1/2 < s.re → riemannZeta s ≠ 0`. -/
theorem pin_rh_iff_rightHalfZeroFree :
    _root_.RiemannHypothesis ↔ rightHalfZeroFree := by
  rw [rightHalfZeroFree_eq]
  exact RHConnections.CoherentEnergyContinuation.riemannHypothesis_iff_rightHalfZeroFree

/-- R2 one-way: `σ`-energy bound (`σ ≥ 1/2`) directly implies `RightHalfZeroFree`. -/
theorem pin_rightHalfZeroFree_of_sigma_measure {σ : ℝ} (hσ : 1 / 2 ≤ σ) {B : ℕ} (hB : 1 ≤ B) :
    (∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧ ∀ X : ℕ, 1 ≤ X →
      ∫ θ, ‖poly B X θ‖ ^ 2 ∂(nuRho (rhoSigma σ)) ≤ C * (X : ℝ) ^ (1 + δ)) →
      rightHalfZeroFree := by
  rw [nuRho_eq, rhoSigma_eq, rightHalfZeroFree_eq]
  simp_rw [poly_eq]
  exact RHConnections.CoherentEnergyContinuation.rightHalfZeroFree_of_sigma_measure_bound hσ hB

/-- R3: One-way zero-free strip from `σ`-measure bound (`σ > 0`, `θ ∈ [1/2, 1)`, `σ + θ > 1`). -/
theorem pin_strip_zero_free_of_sigma_measure {σ θ : ℝ} (hσ : 0 < σ)
    (hθ : 1 / 2 ≤ θ) (hθ1 : θ < 1) (hστ : 1 < σ + θ) {B : ℕ} (hB : 1 ≤ B) :
    (∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧ ∀ X : ℕ, 1 ≤ X →
      ∫ φ, ‖poly B X φ‖ ^ 2 ∂(nuRho (rhoSigma σ)) ≤ C * (X : ℝ) ^ (2 * θ + δ)) →
      (∀ s : ℂ, θ < s.re → riemannZeta s ≠ 0) := by
  rw [nuRho_eq, rhoSigma_eq]
  simp_rw [poly_eq]
  exact RHConnections.CoherentEnergyContinuation.zero_free_strip_of_sigma_measure_bound hσ hθ hθ1 hστ hB

/-- R3: Two-way strip equivalence for `σ`-measure (`σ > 0`, `θ ∈ [1/2, 1)`, `σ + θ > 1`). -/
theorem pin_strip_iff_sigma_measure {σ θ : ℝ} (hσ : 0 < σ)
    (hθ : 1 / 2 ≤ θ) (hθ1 : θ < 1) (hστ : 1 < σ + θ) {B : ℕ} (hB : 1 ≤ B) :
    (∀ s : ℂ, θ < s.re → riemannZeta s ≠ 0) ↔
      (∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧ ∀ X : ℕ, 1 ≤ X →
        ∫ φ, ‖poly B X φ‖ ^ 2 ∂(nuRho (rhoSigma σ)) ≤ C * (X : ℝ) ^ (2 * θ + δ)) := by
  rw [nuRho_eq, rhoSigma_eq]
  simp_rw [poly_eq]
  exact RHConnections.CoherentEnergyContinuation.fixed_strip_iff_sigma_measure_power hσ hθ hθ1 hστ hB

/-- R3 extension of `StatementPins` for `σ = 1` one-sided strip (`a ∈ [1/2, 1)`). -/
theorem pin_strip_iff_one_sided_sigma1 (B : ℕ) {a sgn : ℝ}
    (ha : 1 / 2 ≤ a) (ha1 : a < 1) (hsgn : sgn = 1 ∨ sgn = -1) :
    (∀ s : ℂ, a < s.re → riemannZeta s ≠ 0) ↔
      (∀ ε : ℝ, 0 < ε → ∃ C : ℝ, 0 ≤ C ∧
        ∀ᶠ n : ℕ in atTop, -(C * (n : ℝ) ^ (a + ε)) ≤ sgn * scalarOne B n) := by
  simp_rw [scalarOne_eq]
  exact RHConnections.ArithmeticFourierInversion.fixed_strip_iff_one_sided_fourier_scalar B ha ha1 hsgn

/-- R4: Expectation `E[D_{X,B}] = S_w(B, X)` at complex rotated centre `|w_p| < 1`. -/
theorem pin_mean_D_rotated {w : ℕ → ℂ} (hw : ∀ p, p.Prime → ‖w p‖ < 1)
    {B : ℕ} (hB : 1 ≤ B) (X : ℕ) :
    ∫ θ, poly B X θ ∂(nuW w) = scalarW w B X := by
  rw [nuW_eq, poly_eq, scalarW_eq]
  exact RHConnections.CoherentEnergyRotated.mean_D_eq_scalarSC hw hB X

/-- R4: Parseval identity at complex rotated centre `|w_p| < 1`. -/
theorem pin_energy_identity_rotated {w : ℕ → ℂ} (hw : ∀ p, p.Prime → ‖w p‖ < 1)
    {B : ℕ} (hB : 1 ≤ B) (X : ℕ) :
    ∫ θ, ‖poly B X θ‖ ^ 2 ∂(nuW w) = energyW w B X := by
  rw [nuW_eq, poly_eq, energyW_eq]
  exact RHConnections.CoherentEnergyRotated.norm_sq_D_eq_energyC hw hB X

/-- R4: RH equivalence at rotated `(σ, t)` centre for every `σ ≥ 1/2`, real `t`, and `B ≥ 1`. -/
theorem pin_rh_iff_norm_rotated {σ : ℝ} (hσ : 1 / 2 ≤ σ) (t : ℝ) {B : ℕ} (hB : 1 ≤ B) :
    _root_.RiemannHypothesis ↔
      ∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧ ∀ X : ℕ, 1 ≤ X →
        ∫ θ, ‖poly B X θ‖ ^ 2 ∂(nuW (wSigmaT σ t)) ≤ C * (X : ℝ) ^ (1 + δ) := by
  rw [nuW_eq, wSigmaT_eq]
  simp_rw [poly_eq]
  exact (RHConnections.CoherentEnergyRotated.coherent_energy_rotated_measure_growth_iff_RH hσ t hB).symm

/-- R4 headline film point (`σ = 1/2`, arbitrary real `t`, `B ≥ 1`). -/
theorem pin_rh_iff_norm_film_point (t : ℝ) {B : ℕ} (hB : 1 ≤ B) :
    _root_.RiemannHypothesis ↔
      ∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧ ∀ X : ℕ, 1 ≤ X →
        ∫ θ, ‖poly B X θ‖ ^ 2 ∂(nuW (wSigmaT (1 / 2) t)) ≤ C * (X : ℝ) ^ (1 + δ) :=
  pin_rh_iff_norm_rotated (le_refl (1 / 2 : ℝ)) t hB

/-- R4 + R2: One-way direction at rotated `(σ, t)` yields `RightHalfZeroFree`. -/
theorem pin_rightHalfZeroFree_of_rotated_measure {σ : ℝ} (hσ : 1 / 2 ≤ σ) (t : ℝ)
    {B : ℕ} (hB : 1 ≤ B) :
    (∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧ ∀ X : ℕ, 1 ≤ X →
      ∫ θ, ‖poly B X θ‖ ^ 2 ∂(nuW (wSigmaT σ t)) ≤ C * (X : ℝ) ^ (1 + δ)) →
      rightHalfZeroFree := by
  rw [nuW_eq, wSigmaT_eq, rightHalfZeroFree_eq]
  simp_rw [poly_eq]
  exact RHConnections.CoherentEnergyRotated.rightHalfZeroFree_of_rotated_measure_bound hσ t hB

/-! ## Independent definitions and agreement lemmas for R6 and R7 -/

noncomputable def chiFn (s : ℂ) : ℂ := (1 - s).Gammaℝ / s.Gammaℝ

noncomputable def hardyAngle (t : ℝ) : ℝ := ((⟨1 / 2, t⟩ : ℂ).Gammaℝ).arg

noncomputable def alphaTwinFn (α : ℝ) : ℝ := -1 - α

theorem chiFn_eq (s : ℂ) : chiFn s = RHConnections.CoherentEnergyFlip.chiFactor s := rfl

theorem hardyAngle_eq (t : ℝ) : hardyAngle t = RHConnections.CoherentEnergyFlip.hardyTheta t := rfl

theorem alphaTwinFn_eq (α : ℝ) : alphaTwinFn α = RHConnections.CoherentEnergyFlip.alphaTwin α := rfl

/-! ## Pinned headline theorems for R6 and R7 (`#2202`) -/

/-- R6: Critical-line functional-equation flip `ζ(1/2+it) = χ(1/2+it) · conj ζ(1/2+it)` with `‖χ‖ = 1`. -/
theorem pin_zeta_critical_line_flip (t : ℝ) :
    riemannZeta (⟨1 / 2, t⟩ : ℂ) =
      chiFn (⟨1 / 2, t⟩ : ℂ) * starRingEnd ℂ (riemannZeta (⟨1 / 2, t⟩ : ℂ)) ∧
      ‖chiFn (⟨1 / 2, t⟩ : ℂ)‖ = 1 := by
  rw [chiFn_eq]
  exact ⟨RHConnections.CoherentEnergyFlip.riemannZeta_critical_line_eq_chi_mul_conj t,
    RHConnections.CoherentEnergyFlip.chiFactor_critical_line_norm t⟩

/-- R6: Rotating by `exp (i · hardyAngle t)` lands `ζ(1/2+it)` on the real axis. -/
theorem pin_hardy_rotation_real (t : ℝ) :
    (Complex.exp ((hardyAngle t : ℂ) * Complex.I) * riemannZeta (⟨1 / 2, t⟩ : ℂ)).im = 0 := by
  rw [hardyAngle_eq]
  exact RHConnections.CoherentEnergyFlip.hardy_rotation_real t

/-- R6: Off the critical line (`σ ≠ 1/2`), `‖χ(σ + it)‖ ≠ 1` for all sufficiently large `|t|`. -/
theorem pin_chi_norm_ne_one_off_line {σ : ℝ} (hne : σ ≠ 1 / 2) :
    ∃ T : ℝ, 0 < T ∧ ∀ t : ℝ, T ≤ |t| → ‖chiFn (⟨σ, t⟩ : ℂ)‖ ≠ 1 := by
  simp_rw [chiFn_eq]
  exact RHConnections.CoherentEnergyFlip.norm_chiFactor_ne_one_of_ne_half hne

/-- R7: Twin map `α ↦ -1 - α` has the unique fixed point `α = -1/2`. -/
theorem pin_alpha_twin_unique_fixed (α : ℝ) :
    alphaTwinFn α = α ↔ α = -(1 / 2 : ℝ) := by
  rw [alphaTwinFn_eq]
  exact RHConnections.CoherentEnergyFlip.alphaTwin_fixed_iff α

/-- R7: Unit-scale `FVLT.AlphaAmplitudeV1.radius m (-σ) 1` matches `‖wSigmaT σ t m.n3‖`. -/
theorem pin_alpha_radius_matches_wSigmaT (m : FVLT.CoupledPointV1.Modulus) (σ t : ℝ) :
    FVLT.AlphaAmplitudeV1.radius m (-σ) 1 = ‖wSigmaT σ t m.n3‖ := by
  rw [wSigmaT_eq]
  exact RHConnections.CoherentEnergyFlip.alpha_radius_eq_norm_wSigmaT m σ t

/-- R7: Rosette arm conjugation `z2 = star z1` at radial parameter `α = -σ`. -/
theorem pin_alpha_z2_conj_z1 (m : FVLT.CoupledPointV1.Modulus) (σ n6 : ℝ) (t1 t2 s : ℤ) :
    FVLT.AlphaAmplitudeV1.z2 m (-σ) n6 t1 t2 s =
      star (FVLT.AlphaAmplitudeV1.z1 m (-σ) n6 t1 t2 s) :=
  RHConnections.CoherentEnergyFlip.alpha_z2_eq_conj_z1 m σ n6 t1 t2 s

end ContinuationRotatedStatementPins

#print axioms ContinuationRotatedStatementPins.pin_rh_iff_rightHalfZeroFree
#print axioms ContinuationRotatedStatementPins.pin_rightHalfZeroFree_of_sigma_measure
#print axioms ContinuationRotatedStatementPins.pin_strip_zero_free_of_sigma_measure
#print axioms ContinuationRotatedStatementPins.pin_strip_iff_sigma_measure
#print axioms ContinuationRotatedStatementPins.pin_strip_iff_one_sided_sigma1
#print axioms ContinuationRotatedStatementPins.pin_mean_D_rotated
#print axioms ContinuationRotatedStatementPins.pin_energy_identity_rotated
#print axioms ContinuationRotatedStatementPins.pin_rh_iff_norm_rotated
#print axioms ContinuationRotatedStatementPins.pin_rh_iff_norm_film_point
#print axioms ContinuationRotatedStatementPins.pin_rightHalfZeroFree_of_rotated_measure
#print axioms ContinuationRotatedStatementPins.pin_zeta_critical_line_flip
#print axioms ContinuationRotatedStatementPins.pin_hardy_rotation_real
#print axioms ContinuationRotatedStatementPins.pin_chi_norm_ne_one_off_line
#print axioms ContinuationRotatedStatementPins.pin_alpha_twin_unique_fixed
#print axioms ContinuationRotatedStatementPins.pin_alpha_radius_matches_wSigmaT
#print axioms ContinuationRotatedStatementPins.pin_alpha_z2_conj_z1
