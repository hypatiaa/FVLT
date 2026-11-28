import FiniteSphereFlipV1
import CoherentEnergyFlipAndAlpha

/-!
# Statement pins for `FiniteSphereFlipV1` and side-by-side R6 comparison

Independent Mathlib-level definitions (`rfl` agreement with `RHConnections.FiniteSphereFlip` and
`RHConnections.CoherentEnergyFlip`), pinning Statements 1–6 of `FINITE_SPHERE_FLIP_NOTE_v0_1_20261123/NOTE.md`
alongside the critical-line flip theorems from R6 (`CoherentEnergyFlipAndAlpha`).

**Scope note:** `finiteZetaFn` is a finite divisor sum whose prime-power Euler product holds for all
`s : ℂ`, yielding trivial finite RH (`Re s = 0`). The Riemann zeta function `riemannZeta` has a
convergent Euler product only for `1 < Re s` (zero-free), so the critical-line flip here is paired
with `riemannZeta_critical_line_eq_chi_mul_conj` solely as a structural model, **not** a route to RH.
-/

noncomputable section
open scoped BigOperators ComplexConjugate

namespace FiniteSphereFlipStatementPins

/-! ## Independent Mathlib-level definitions -/

def finiteZetaFn (N : ℕ) (s : ℂ) : ℂ :=
  ∑ d ∈ N.divisors, (d : ℂ) ^ (-s)

def finiteHardyZFn (N : ℕ) (t : ℝ) : ℂ :=
  (N : ℂ) ^ ((⟨0, t⟩ : ℂ) / 2) * finiteZetaFn N (⟨0, t⟩ : ℂ)

def bigOmegaFn (n : ℕ) : ℕ :=
  n.primeFactorsList.length

def omegaLayerFn (N k : ℕ) : Finset ℕ :=
  N.divisors.filter (fun d => bigOmegaFn d = k)

def chiFactorFn (s : ℂ) : ℂ :=
  (1 - s).Gammaℝ / s.Gammaℝ

def hardyThetaFn (t : ℝ) : ℝ :=
  ((⟨1 / 2, t⟩ : ℂ).Gammaℝ).arg

/-! ## Definitional agreement (`rfl`) -/

theorem finiteZetaFn_eq :
    finiteZetaFn = RHConnections.FiniteSphereFlip.finiteZeta := rfl

theorem finiteHardyZFn_eq :
    finiteHardyZFn = RHConnections.FiniteSphereFlip.finiteHardyZ := rfl

theorem bigOmegaFn_eq :
    bigOmegaFn = RHConnections.FiniteSphereFlip.bigOmega := rfl

theorem omegaLayerFn_eq :
    omegaLayerFn = RHConnections.FiniteSphereFlip.omegaLayer := rfl

theorem chiFactorFn_eq :
    chiFactorFn = RHConnections.CoherentEnergyFlip.chiFactor := rfl

theorem hardyThetaFn_eq :
    hardyThetaFn = RHConnections.CoherentEnergyFlip.hardyTheta := rfl

/-! ## Pins for Statements 1–6 (`NOTE.md`) -/

/-- Statement 1: Finite functional equation and equator mirror-and-turn identity. -/
theorem pin_S1_functional_eq {N : ℕ} (hN : N ≠ 0) (s : ℂ) (t : ℝ) :
    finiteZetaFn N s = (N : ℂ) ^ (-s) * finiteZetaFn N (-s) ∧
      finiteZetaFn N (⟨0, t⟩ : ℂ) =
        (N : ℂ) ^ (-(⟨0, t⟩ : ℂ)) * conj (finiteZetaFn N (⟨0, t⟩ : ℂ)) := by
  rw [finiteZetaFn_eq]
  exact ⟨RHConnections.FiniteSphereFlip.finiteZeta_functional_eq hN s,
    RHConnections.FiniteSphereFlip.finiteZeta_equator_eq_flip_mul_conj hN t⟩

/-- Statement 2: Circle flip without stretch on `σ = 0`, and unit norm iff on the equator (`N ≥ 2`). -/
theorem pin_S2_circle_flip_and_stretch {N : ℕ} (hN : 2 ≤ N) (d : ℕ) (hd : d ∣ N) (t : ℝ) (s : ℂ) :
    ((N / d : ℕ) : ℂ) ^ (-(⟨0, t⟩ : ℂ)) =
        (N : ℂ) ^ (-(⟨0, t⟩ : ℂ)) * conj ((d : ℂ) ^ (-(⟨0, t⟩ : ℂ))) ∧
      (‖(N : ℂ) ^ (-s)‖ = 1 ↔ s.re = 0) :=
  ⟨RHConnections.FiniteSphereFlip.circle_antipode_flip (by omega) hd t,
    RHConnections.FiniteSphereFlip.norm_finiteFlipFactor_eq_one_iff hN s⟩

/-- Statement 3: Prime-power product over `N.primeFactors` and squarefree prime-dice product. -/
theorem pin_S3_prime_dice_product {N : ℕ} (hN : N ≠ 0) (hsq : Squarefree N) (s : ℂ) :
    finiteZetaFn N s =
        ∏ p ∈ N.primeFactors,
          ∑ k ∈ Finset.range (N.factorization p + 1), ((p : ℂ) ^ (-s)) ^ k ∧
      finiteZetaFn N s = ∏ p ∈ N.primeFactors, (1 + (p : ℂ) ^ (-s)) := by
  rw [finiteZetaFn_eq]
  exact ⟨RHConnections.FiniteSphereFlip.finiteZeta_eq_prod_primeFactors hN s,
    RHConnections.FiniteSphereFlip.finiteZeta_eq_prod_squarefree hsq s⟩

/-- Statement 4: Trivial finite RH (all zeros satisfy `s.re = 0`; squarefree iff `∃ p ∣ N, p^(-s) = -1`). -/
theorem pin_S4_trivial_finite_RH {N : ℕ} (hN : N ≠ 0) (hsq : Squarefree N) (s : ℂ) :
    (finiteZetaFn N s = 0 → s.re = 0) ∧
      (finiteZetaFn N s = 0 ↔ ∃ p ∈ N.primeFactors, (p : ℂ) ^ (-s) = -1) := by
  rw [finiteZetaFn_eq]
  exact ⟨RHConnections.FiniteSphereFlip.finiteZeta_zero_re_eq_zero hN,
    RHConnections.FiniteSphereFlip.finiteZeta_squarefree_zero_iff hsq s⟩

/-- Statement 5: Finite Hardy `Z_N(t)` is real for all `N ≥ 1`, and equals the cosine product for squarefree `N`. -/
theorem pin_S5_finite_hardy_real_and_cos {N : ℕ} (hN : N ≠ 0) (hsq : Squarefree N) (t : ℝ) :
    (finiteHardyZFn N t).im = 0 ∧
      finiteHardyZFn N t = ∏ p ∈ N.primeFactors, ((2 * Real.cos (t * Real.log p / 2) : ℝ) : ℂ) := by
  rw [finiteHardyZFn_eq]
  exact ⟨RHConnections.FiniteSphereFlip.finiteHardyZ_im_eq_zero hN t,
    RHConnections.FiniteSphereFlip.finiteHardyZ_squarefree_eq_cos_prod hsq t⟩

/-- Statement 6: Complement `Ω`-layer swap and concrete checks for `N = 30` and `N = 2310`. -/
theorem pin_S6_omega_layer_swap_and_examples {N k : ℕ} (hN : N ≠ 0) (hk : k ≤ bigOmegaFn N) :
    (omegaLayerFn N (bigOmegaFn N - k)).card = (omegaLayerFn N k).card ∧
      (bigOmegaFn 30 = 3 ∧ (omegaLayerFn 30 1).card = 3 ∧ (omegaLayerFn 30 2).card = 3) ∧
      (bigOmegaFn 2310 = 5 ∧ (omegaLayerFn 2310 2).card = 10 ∧ (omegaLayerFn 2310 3).card = 10) := by
  rw [bigOmegaFn_eq, omegaLayerFn_eq]
  refine ⟨RHConnections.FiniteSphereFlip.card_omegaLayer_complement hN hk,
    ⟨RHConnections.FiniteSphereFlip.finite_example_30.1,
      RHConnections.FiniteSphereFlip.finite_example_30.2.1,
      RHConnections.FiniteSphereFlip.finite_example_30.2.2.1⟩,
    ⟨RHConnections.FiniteSphereFlip.finite_example_2310.1,
      RHConnections.FiniteSphereFlip.finite_example_2310.2.1,
      RHConnections.FiniteSphereFlip.finite_example_2310.2.2.1⟩⟩

/-! ## Side-by-side comparison next to R6 (`CoherentEnergyFlipAndAlpha`) -/

/-- Side-by-side pairing of the finite squeezed-sphere equator model (`Re s = 0`, factor `N ^ (-s)`)
next to R6's critical-line flip (`Re s = 1/2`, factor `χ(s)`), Hardy rotation realness, and
off-line stretching. This states an explicit structural analogy only (not a route to RH). -/
theorem pin_R6_vs_finite_model_side_by_side {N : ℕ} (hN : 2 ≤ N) {σ : ℝ} (hne : σ ≠ 1 / 2)
    (t : ℝ) (s : ℂ) :
    (finiteZetaFn N (⟨0, t⟩ : ℂ) =
        (N : ℂ) ^ (-(⟨0, t⟩ : ℂ)) * conj (finiteZetaFn N (⟨0, t⟩ : ℂ)) ∧
      riemannZeta (⟨1 / 2, t⟩ : ℂ) =
        chiFactorFn (⟨1 / 2, t⟩ : ℂ) * conj (riemannZeta (⟨1 / 2, t⟩ : ℂ))) ∧
    (‖(N : ℂ) ^ (-(⟨0, t⟩ : ℂ))‖ = 1 ∧ ‖chiFactorFn (⟨1 / 2, t⟩ : ℂ)‖ = 1) ∧
    ((finiteHardyZFn N t).im = 0 ∧
      (Complex.exp ((hardyThetaFn t : ℂ) * Complex.I) * riemannZeta (⟨1 / 2, t⟩ : ℂ)).im = 0) ∧
    ((‖(N : ℂ) ^ (-s)‖ = 1 ↔ s.re = 0) ∧
      (∃ T : ℝ, 0 < T ∧ ∀ u : ℝ, T ≤ |u| → ‖chiFactorFn (⟨σ, u⟩ : ℂ)‖ ≠ 1)) := by
  have hN0 : N ≠ 0 := by omega
  rw [finiteZetaFn_eq, finiteHardyZFn_eq, chiFactorFn_eq, hardyThetaFn_eq]
  refine ⟨⟨RHConnections.FiniteSphereFlip.finiteZeta_equator_eq_flip_mul_conj hN0 t,
      RHConnections.CoherentEnergyFlip.riemannZeta_critical_line_eq_chi_mul_conj t⟩,
    ⟨(RHConnections.FiniteSphereFlip.norm_finiteFlipFactor_eq_one_iff hN (⟨0, t⟩ : ℂ)).mpr rfl,
      RHConnections.CoherentEnergyFlip.chiFactor_critical_line_norm t⟩,
    ⟨RHConnections.FiniteSphereFlip.finiteHardyZ_im_eq_zero hN0 t,
      RHConnections.CoherentEnergyFlip.hardy_rotation_real t⟩,
    ⟨RHConnections.FiniteSphereFlip.norm_finiteFlipFactor_eq_one_iff hN s,
      RHConnections.CoherentEnergyFlip.norm_chiFactor_ne_one_of_ne_half hne⟩⟩

end FiniteSphereFlipStatementPins

#print axioms FiniteSphereFlipStatementPins.pin_S1_functional_eq
#print axioms FiniteSphereFlipStatementPins.pin_S2_circle_flip_and_stretch
#print axioms FiniteSphereFlipStatementPins.pin_S3_prime_dice_product
#print axioms FiniteSphereFlipStatementPins.pin_S4_trivial_finite_RH
#print axioms FiniteSphereFlipStatementPins.pin_S5_finite_hardy_real_and_cos
#print axioms FiniteSphereFlipStatementPins.pin_S6_omega_layer_swap_and_examples
#print axioms FiniteSphereFlipStatementPins.pin_R6_vs_finite_model_side_by_side
