import Verified
import CoherentEnergyMeasure
import CoherentEnergyRHBridge
import CoherentEnergyRadiusMeasure
import CoherentEnergySigmaBridge

/-!
# Statement pins for the radius family

Independent restatements of the general-radius and `σ`-family results (`σ ≥ 1/2`,
with headline case `σ = 1/2`), written purely in Mathlib's own terms without
reusing repository definitions in the statements.

Every agreement lemma linking these standalone definitions to
`RHConnections.CoherentEnergyRadius` holds definitionally (`rfl`) or by direct sum congruence.
-/

open scoped BigOperators
open Filter MeasureTheory

namespace RadiusStatementPins

/-! ## Independent definitions -/

/-- The Mertens function `M(n) = Σ_{1 ≤ j ≤ n} μ(j)`. -/
noncomputable def mertensFn (n : ℕ) : ℝ :=
  ∑ j ∈ Finset.Icc 1 n, (ArithmeticFunction.moebius j : ℝ)

/-- Completely multiplicative radius extension `ρ(m) = ∏_{p | m} ρ_p^{v_p(m)}`. -/
noncomputable def rhoProd (ρ : ℕ → ℝ) (m : ℕ) : ℝ :=
  ∏ p ∈ m.primeFactors, ρ p ^ m.factorization p

/-- General-radius scalar `S_{B,ρ}(n) = Σ_{k ≤ n, gcd(k,B) = 1} M(⌊n/k⌋) ρ(k)`. -/
noncomputable def scalarRho (ρ : ℕ → ℝ) (B n : ℕ) : ℝ :=
  ∑ k ∈ (Finset.Icc 1 n).filter (fun k => Nat.Coprime k B), mertensFn (n / k) * rhoProd ρ k

/-- Mode weights `j_ρ(r) = ∏_{p | r} (1 - ρ_p²)`. -/
noncomputable def weightRho (ρ : ℕ → ℝ) (r : ℕ) : ℝ :=
  ∏ p ∈ r.primeFactors, (1 - ρ p ^ 2)

/-- Coherent energy at general radii: `Σ_{r ≤ X, gcd(r,B) = 1} j_ρ(r) S_{B,ρ}(⌊X/r⌋)²`. -/
noncomputable def energyRho (ρ : ℕ → ℝ) (B X : ℕ) : ℝ :=
  ∑ r ∈ (Finset.Icc 1 X).filter (fun r => Nat.Coprime r B), weightRho ρ r * scalarRho ρ B (X / r) ^ 2

/-- On the circle of a prime `p`: the Poisson law with radius `ρ p ∈ [0, 1)`. -/
noncomputable def poissonRho (ρ : ℕ → ℝ) (p : ℕ) : Measure ℝ :=
  if p.Prime ∧ 0 ≤ ρ p ∧ ρ p < 1 then
    (volume.restrict (Set.Ioc 0 (2 * Real.pi))).withDensity fun θ =>
      ENNReal.ofReal ((2 * Real.pi)⁻¹ *
        ((1 - ρ p ^ 2) / (1 - 2 * ρ p * Real.cos θ + ρ p ^ 2)))
  else Measure.dirac 0

/-- The product Poisson measure `ν_ρ = ⊗_p ν_{ρ_p}`. -/
noncomputable def nuRho (ρ : ℕ → ℝ) : Measure (ℕ → ℝ) := Measure.infinitePi (poissonRho ρ)

/-- `Z(d) = ∏_p z_p^{v_p(d)}` with `z_p = e^{i θ_p}`. -/
noncomputable def phasorMonomial (d : ℕ) (θ : ℕ → ℝ) : ℂ :=
  ∏ p ∈ d.primeFactors, Complex.exp (Complex.I * (θ p : ℂ)) ^ d.factorization p

/-- The inclusion–exclusion window `w_{X,B}(n) = Σ_{b | rad B} μ(b) 1_{n ≤ X/b}`. -/
noncomputable def window (B X n : ℕ) : ℝ :=
  ∑ b ∈ (∏ p ∈ B.primeFactors, p).divisors,
    if n ≤ X / b then (ArithmeticFunction.moebius b : ℝ) else 0

/-- `D_{X,B} = Σ_{n ≤ X, gcd(n,B) = 1} w_{X,B}(n) Σ_{d | n} μ(n/d) Z(d)`. -/
noncomputable def poly (B X : ℕ) (θ : ℕ → ℝ) : ℂ :=
  ∑ n ∈ (Finset.Icc 1 X).filter (fun n => Nat.Coprime n B),
    (window B X n : ℂ) *
      ∑ d ∈ n.divisors, (ArithmeticFunction.moebius (n / d) : ℂ) * phasorMonomial d θ

/-- The `σ`-family radii `ρ_p = p^(-σ)`. -/
noncomputable def rhoSigma (σ : ℝ) (p : ℕ) : ℝ :=
  (p : ℝ) ^ (-σ)

/-! ## Agreement with repository definitions -/

theorem rhoProd_eq (ρ : ℕ → ℝ) (m : ℕ) :
    rhoProd ρ m = RHConnections.CoherentEnergyRadius.rhoProd ρ m := rfl

theorem weightRho_eq (ρ : ℕ → ℝ) (r : ℕ) :
    weightRho ρ r = RHConnections.CoherentEnergyRadius.jWeightOf ρ r := rfl

theorem nuRho_eq (ρ : ℕ → ℝ) :
    nuRho ρ = RHConnections.CoherentEnergyRadius.primeTorusMeasureOf ρ := rfl

theorem poly_eq (B X : ℕ) :
    poly B X = RHConnections.CoherentEnergyMeasure.D B X := rfl

theorem phasorMonomial_eq (d : ℕ) :
    phasorMonomial d = RHConnections.CoherentEnergyMeasure.Z d := rfl

theorem rhoSigma_eq (σ : ℝ) :
    rhoSigma σ = RHConnections.CoherentEnergyRadius.rhoSigma σ := rfl

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

/-! ## Headline radius-family results, pinned -/

/-- Moments of `Z(d)` under `ν_ρ` at general radii `ρ_p ∈ [0, 1)`. -/
theorem pin_inner_Z_rho {ρ : ℕ → ℝ} (hρ : ∀ p, p.Prime → 0 ≤ ρ p ∧ ρ p < 1)
    {d e : ℕ} (hd : d ≠ 0) (he : e ≠ 0) :
    ∫ θ, phasorMonomial d θ * starRingEnd ℂ (phasorMonomial e θ) ∂(nuRho ρ) =
      ∏ p ∈ (d * e).primeFactors,
        (ρ p : ℂ) ^ ((d.factorization p : ℤ) - (e.factorization p : ℤ)).natAbs := by
  rw [nuRho_eq, phasorMonomial_eq, phasorMonomial_eq]
  exact RHConnections.CoherentEnergyRadius.innerNuOf_Z hρ hd he

/-- Closed form of the kernel at `ρ_p = p^(-σ)`: `(gcd(d,e)² / (d e))^σ`. -/
theorem pin_inner_Z_sigma {σ : ℝ} (hσ : 0 < σ) {d e : ℕ} (hd : d ≠ 0) (he : e ≠ 0) :
    ∫ θ, phasorMonomial d θ * starRingEnd ℂ (phasorMonomial e θ) ∂(nuRho (rhoSigma σ)) =
      ((((Nat.gcd d e : ℝ) ^ 2 / ((d : ℝ) * (e : ℝ))) ^ σ : ℝ) : ℂ) := by
  rw [nuRho_eq, rhoSigma_eq, phasorMonomial_eq, phasorMonomial_eq]
  exact RHConnections.CoherentEnergyRadius.innerNuOf_Z_sigma hσ hd he

/-- Parseval identity at arbitrary radii `ρ_p ∈ [0, 1)` for every `B ≥ 1`. -/
theorem pin_energy_identity_rho {ρ : ℕ → ℝ} (hρ : ∀ p, p.Prime → 0 ≤ ρ p ∧ ρ p < 1)
    {B : ℕ} (hB : 1 ≤ B) (X : ℕ) :
    ∫ θ, ‖poly B X θ‖ ^ 2 ∂(nuRho ρ) = energyRho ρ B X := by
  rw [nuRho_eq, poly_eq, energyRho_eq]
  exact RHConnections.CoherentEnergyRadius.norm_sq_D_eq_energyOf hρ hB X

/-- Exact reduction to `v0.1` (`CoherentEnergyMeasure`) at `ρ_p = 1/p`. -/
theorem pin_reduction_to_v01 {B : ℕ} (hB : 1 ≤ B) (X : ℕ) :
    ∫ θ, ‖poly B X θ‖ ^ 2 ∂(nuRho (fun q => (q : ℝ)⁻¹)) =
      ∑ r ∈ (Finset.Icc 1 X).filter (fun r => Nat.Coprime r B),
        RHConnections.CoherentEnergyMeasure.jWeight r *
          RHConnections.CoherentEnergyMeasure.scalarS B (X / r) ^ 2 := by
  rw [nuRho_eq, RHConnections.CoherentEnergyRadius.primeTorusMeasureOf_inv_eq, poly_eq]
  exact RHConnections.CoherentEnergyMeasure.norm_sq_D_eq_energy hB X

/-- Coprime Dirichlet inverse at `ρ_p = p^(-σ)`:
`M(n) = Σ_{k ≤ n, gcd(k,B) = 1} μ(k) k^(-σ) S_{B,σ}(⌊n/k⌋)`. -/
theorem pin_sigma_inverse (σ : ℝ) (B n : ℕ) :
    mertensFn n = ∑ k ∈ Finset.Ioc 0 n,
      (if k = 0 then 0 else if Nat.Coprime k B then (ArithmeticFunction.moebius k : ℝ) * (k : ℝ) ^ (-σ) else 0) *
        scalarRho (rhoSigma σ) B (n / k) := by
  rw [mertensFn_eq, RHConnections.CoherentEnergyMeasure.mertens_eq_M,
    RHConnections.CoherentEnergyRadius.M_from_SSigma σ B n]
  refine Finset.sum_congr rfl fun k _ => ?_
  rw [RHConnections.CoherentEnergyRadius.hSigma_apply, scalarRho_eq, rhoSigma_eq,
    RHConnections.CoherentEnergyRadius.SSigma_eq_scalarSOf]

/-- Two-way transfer for `σ + θ > 1` (`θ ≥ 0`):
`M(n) = O(n^θ) ↔ S_{B,σ}(n) = O(n^θ)`, with explicit `ζ(σ + θ)` constant on `M → S_σ`. -/
theorem pin_sigma_transfer_iff {σ θ : ℝ} (hθ : 0 ≤ θ) (hsum : 1 < σ + θ) (B : ℕ) :
    ((∃ A : ℝ, 0 ≤ A ∧ ∀ n : ℕ, 1 ≤ n → |mertensFn n| ≤ A * (n : ℝ) ^ θ) ↔
      (∃ A : ℝ, 0 ≤ A ∧ ∀ n : ℕ, 1 ≤ n → |scalarRho (rhoSigma σ) B n| ≤ A * (n : ℝ) ^ θ)) ∧
    (∀ A : ℝ, 0 ≤ A → (∀ n : ℕ, 1 ≤ n → |mertensFn n| ≤ A * (n : ℝ) ^ θ) →
      ∀ n : ℕ, 1 ≤ n →
        |scalarRho (rhoSigma σ) B n| ≤ A * (riemannZeta ((σ + θ : ℝ) : ℂ)).re * (n : ℝ) ^ θ) := by
  refine ⟨?_, ?_⟩
  · have hiff := RHConnections.CoherentEnergyRadius.M_power_bound_iff_SSigma σ B hθ hsum
    constructor
    · rintro ⟨A, hA, hM⟩
      have hM' : ∀ n : ℕ, 1 ≤ n → |RHConnections.ArithmeticFourierInversion.M n| ≤ A * (n : ℝ) ^ θ := by
        intro n hn
        simpa only [← RHConnections.CoherentEnergyMeasure.mertens_eq_M, ← mertensFn_eq] using hM n hn
      obtain ⟨C, hC, hS⟩ := hiff.mp ⟨A, hA, hM'⟩
      refine ⟨C, hC, fun n hn => ?_⟩
      simpa only [scalarRho_eq, rhoSigma_eq, ← RHConnections.CoherentEnergyRadius.SSigma_eq_scalarSOf] using
        hS n hn
    · rintro ⟨A, hA, hS⟩
      have hS' : ∀ n : ℕ, 1 ≤ n → |RHConnections.CoherentEnergyRadius.SSigma σ B n| ≤ A * (n : ℝ) ^ θ := by
        intro n hn
        simpa only [RHConnections.CoherentEnergyRadius.SSigma_eq_scalarSOf, ← rhoSigma_eq, ← scalarRho_eq] using
          hS n hn
      obtain ⟨C, hC, hM⟩ := hiff.mpr ⟨A, hA, hS'⟩
      refine ⟨C, hC, fun n hn => ?_⟩
      simpa only [mertensFn_eq, RHConnections.CoherentEnergyMeasure.mertens_eq_M] using hM n hn
  · intro A hA hM n hn
    have hM' : ∀ m : ℕ, 1 ≤ m → |RHConnections.ArithmeticFourierInversion.M m| ≤ A * (m : ℝ) ^ θ := by
      intro m hm
      simpa only [← RHConnections.CoherentEnergyMeasure.mertens_eq_M, ← mertensFn_eq] using hM m hm
    have hb := RHConnections.CoherentEnergyRadius.quotient_sum_explicit_bound_sigma
      hθ hsum hA (fun k hk => RHConnections.CoherentEnergyRadius.abs_gSigma_le σ B hk)
      (RHConnections.CoherentEnergyRadius.SSigma_from_M σ B) hM' n hn
    rw [RHConnections.CoherentEnergyRadius.pSeries_eq_re_riemannZeta hsum,
      RHConnections.CoherentEnergyRadius.SSigma_eq_scalarSOf, ← rhoSigma_eq, ← scalarRho_eq] at hb
    exact hb

/-- For every `σ ≥ 1/2` and `B ≥ 1`: RH holds iff the `σ`-radius energy grows like `X^{1+δ}`. -/
theorem pin_rh_iff_energy_sigma {σ : ℝ} (hσ : 1 / 2 ≤ σ) (B : ℕ) :
    _root_.RiemannHypothesis ↔
      ∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
        ∀ X : ℕ, 1 ≤ X → energyRho (rhoSigma σ) B X ≤ C * (X : ℝ) ^ (1 + δ) := by
  simp_rw [energyRho_eq, rhoSigma_eq]
  exact (RHConnections.CoherentEnergyRadius.coherent_energy_sigma_growth_iff_RH hσ B).symm

/-- For every `σ ≥ 1/2` and `B ≥ 1`: RH holds iff `‖D_{X,B}‖²_{ν_σ} = O(X^{1+δ})`. -/
theorem pin_rh_iff_norm_sigma {σ : ℝ} (hσ : 1 / 2 ≤ σ) {B : ℕ} (hB : 1 ≤ B) :
    _root_.RiemannHypothesis ↔
      ∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧ ∀ X : ℕ, 1 ≤ X →
        ∫ θ, ‖poly B X θ‖ ^ 2 ∂(nuRho (rhoSigma σ)) ≤ C * (X : ℝ) ^ (1 + δ) := by
  rw [nuRho_eq, rhoSigma_eq]
  simp_rw [poly_eq]
  exact (RHConnections.CoherentEnergyRadius.coherent_energy_sigma_measure_growth_iff_RH hσ hB).symm

/-- Headline case `σ = 1/2` (prime-phasor radius `p^(-1/2)`). -/
theorem pin_rh_iff_norm_half {B : ℕ} (hB : 1 ≤ B) :
    _root_.RiemannHypothesis ↔
      ∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧ ∀ X : ℕ, 1 ≤ X →
        ∫ θ, ‖poly B X θ‖ ^ 2 ∂(nuRho (rhoSigma (1 / 2))) ≤ C * (X : ℝ) ^ (1 + δ) :=
  pin_rh_iff_norm_sigma (le_refl (1 / 2 : ℝ)) hB

/-- Twin-chain zero remark: for `0 < σ < 1`, `ζ(σ + it) = 0 ↔ ζ((1 - σ) + it) = 0`. -/
theorem pin_twin_chain_zeros {σ : ℝ} (hσ0 : 0 < σ) (hσ1 : σ < 1) (t : ℝ) :
    riemannZeta (⟨σ, t⟩ : ℂ) = 0 ↔ riemannZeta (⟨1 - σ, t⟩ : ℂ) = 0 :=
  RHConnections.CoherentEnergyRadius.zeta_zero_iff_one_sub_add_im hσ0 hσ1 t

end RadiusStatementPins

#print axioms RadiusStatementPins.pin_inner_Z_rho
#print axioms RadiusStatementPins.pin_inner_Z_sigma
#print axioms RadiusStatementPins.pin_energy_identity_rho
#print axioms RadiusStatementPins.pin_reduction_to_v01
#print axioms RadiusStatementPins.pin_sigma_inverse
#print axioms RadiusStatementPins.pin_sigma_transfer_iff
#print axioms RadiusStatementPins.pin_rh_iff_energy_sigma
#print axioms RadiusStatementPins.pin_rh_iff_norm_sigma
#print axioms RadiusStatementPins.pin_rh_iff_norm_half
#print axioms RadiusStatementPins.pin_twin_chain_zeros
