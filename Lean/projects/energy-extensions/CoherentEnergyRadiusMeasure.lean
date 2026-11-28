import CoherentEnergyMeasure

/-!
# General-radius Poisson measure on the prime torus

Generalises `RHConnections.CoherentEnergyMeasure` (radius `1/p`) to arbitrary prime radii
`ρ : ℕ → ℝ` with `0 ≤ ρ p < 1` at each prime `p`:

* `rhoProd ρ m = ∏ p | m, (ρ p)^{v_p(m)}` (completely multiplicative).
* `primeTorusMeasureOf ρ = ⊗_p ν_{ρ_p}` with moments `E[z_p^a \bar z_p^b] = ρ_p^{|a-b|}`.
* Orthogonal local modes `phiLocalOf ρ p a = z_p^a - ρ_p z_p^{a-1}` (`a ≥ 1`), tensor products
  `PsiOf ρ r`, and squared norm `jWeightOf ρ r = ∏_{p | r} (1 - ρ_p²)`.
* Expansion `Z n = ∑_{r | n} ρ(n/r) PsiOf ρ r`.
* Parseval / coherent energy identity:
  `‖D_{X,B}‖²_{ν_ρ} = ∑_{r ≤ X, gcd(r,B) = 1} j_ρ(r) S_ρ(B, ⌊X/r⌋)²`.
* Exact reduction to `RHConnections.CoherentEnergyMeasure` when `ρ p = (p : ℝ)⁻¹`.

Formalised from `RADIUS_FAMILY_NOTE.md` §1 (saphir / hypatiaa prime-phasor construction).
-/

noncomputable section
open scoped BigOperators ENNReal NNReal
open MeasureTheory Complex

namespace RHConnections.CoherentEnergyRadius

open RHConnections.CoherentEnergyMeasure

private lemma norm_exp_I_mul_real' (x : ℝ) : ‖Complex.exp (Complex.I * (x : ℂ))‖ = 1 := by
  simp

private lemma conj_exp_I_mul_int' (m : ℤ) (t : ℝ) :
    starRingEnd ℂ (Complex.exp (Complex.I * (m : ℂ) * (t : ℂ))) =
      Complex.exp (Complex.I * ((-m : ℤ) : ℂ) * (t : ℂ)) := by
  rw [← Complex.exp_conj, map_mul, map_mul, Complex.conj_I, Complex.conj_ofReal,
    show starRingEnd ℂ (m : ℂ) = (m : ℂ) from Complex.conj_ofReal (m : ℝ)]
  congr 1; push_cast; ring

/-! ## Completely multiplicative radius product -/

def rhoProd (ρ : ℕ → ℝ) (m : ℕ) : ℝ :=
  ∏ p ∈ m.primeFactors, ρ p ^ m.factorization p

@[simp] theorem rhoProd_one (ρ : ℕ → ℝ) : rhoProd ρ 1 = 1 := by
  simp [rhoProd]

@[simp] theorem rhoProd_prime_pow (ρ : ℕ → ℝ) {p k : ℕ} (hp : p.Prime) :
    rhoProd ρ (p ^ k) = ρ p ^ k := by
  by_cases hk : k = 0
  · subst hk; simp
  · unfold rhoProd
    rw [Nat.primeFactors_prime_pow hk hp, Finset.prod_singleton, hp.factorization_pow,
      Finsupp.single_eq_same]

theorem rhoProd_mul (ρ : ℕ → ℝ) {m n : ℕ} (hm : m ≠ 0) (hn : n ≠ 0) :
    rhoProd ρ (m * n) = rhoProd ρ m * rhoProd ρ n := by
  unfold rhoProd
  rw [Nat.primeFactors_mul hm hn]
  have hm_eq : ∏ p ∈ m.primeFactors, ρ p ^ m.factorization p =
      ∏ p ∈ m.primeFactors ∪ n.primeFactors, ρ p ^ m.factorization p := by
    refine Finset.prod_subset Finset.subset_union_left fun p _ hp => ?_
    have hz : m.factorization p = 0 :=
      Finsupp.notMem_support_iff.mp (by simpa [Nat.support_factorization] using hp)
    simp [hz]
  have hn_eq : ∏ p ∈ n.primeFactors, ρ p ^ n.factorization p =
      ∏ p ∈ m.primeFactors ∪ n.primeFactors, ρ p ^ n.factorization p := by
    refine Finset.prod_subset Finset.subset_union_right fun p _ hp => ?_
    have hz : n.factorization p = 0 :=
      Finsupp.notMem_support_iff.mp (by simpa [Nat.support_factorization] using hp)
    simp [hz]
  rw [hm_eq, hn_eq, ← Finset.prod_mul_distrib]
  refine Finset.prod_congr rfl fun p _ => ?_
  rw [Nat.factorization_mul hm hn, Finsupp.coe_add, Pi.add_apply, pow_add]

theorem rhoProd_nonneg {ρ : ℕ → ℝ} (hρ : ∀ p, p.Prime → 0 ≤ ρ p) (m : ℕ) :
    0 ≤ rhoProd ρ m := by
  unfold rhoProd
  exact Finset.prod_nonneg fun p hp => pow_nonneg (hρ p (Nat.prime_of_mem_primeFactors hp)) _

theorem rhoProd_inv_prime {m : ℕ} (hm : m ≠ 0) :
    rhoProd (fun p => (p : ℝ)⁻¹) m = (m : ℝ)⁻¹ := by
  unfold rhoProd
  have hfac := congr_arg (fun k : ℕ => ((k : ℝ)⁻¹)) (Nat.prod_primeFactors_pow_factorization hm)
  simp only [Nat.cast_prod, Nat.cast_pow] at hfac
  rw [hfac, ← Finset.prod_inv_distrib]
  refine Finset.prod_congr rfl fun p _ => ?_
  rw [inv_pow]

/-! ## General-radius Poisson measure on the prime torus -/

def poissonDensityNNOf (ρ : ℕ → ℝ) (p : ℕ) (θ : ℝ) : ℝ≥0 :=
  Real.toNNReal ((2 * Real.pi)⁻¹ * poissonKernel (ρ p) θ)

theorem poissonDensityNNOf_continuous {ρ : ℕ → ℝ} {p : ℕ}
    (hρ0 : 0 ≤ ρ p) (hρ1 : ρ p < 1) :
    Continuous (poissonDensityNNOf ρ p) :=
  continuous_real_toNNReal.comp (continuous_const.mul (poissonKernel_continuous hρ0 hρ1))

theorem poissonDensityNNOf_coe {ρ : ℕ → ℝ} {p : ℕ}
    (hρ0 : 0 ≤ ρ p) (hρ1 : ρ p < 1) (θ : ℝ) :
    ((poissonDensityNNOf ρ p θ : ℝ≥0) : ℝ) = (2 * Real.pi)⁻¹ * poissonKernel (ρ p) θ :=
  Real.coe_toNNReal _ (mul_nonneg (by positivity) (poissonKernel_pos hρ0 hρ1 θ).le)

def poissonMeasureOf (ρ : ℕ → ℝ) (p : ℕ) : Measure ℝ :=
  if p.Prime ∧ 0 ≤ ρ p ∧ ρ p < 1 then
    (volume.restrict (Set.Ioc 0 (2 * Real.pi))).withDensity
      (fun θ => (poissonDensityNNOf ρ p θ : ℝ≥0∞))
  else
    Measure.dirac 0

theorem integral_poissonMeasureOf_exp {ρ : ℕ → ℝ} {p : ℕ} (hp : p.Prime)
    (hρ0 : 0 ≤ ρ p) (hρ1 : ρ p < 1) (m : ℤ) :
    ∫ θ, Complex.exp (Complex.I * (m : ℂ) * θ) ∂(poissonMeasureOf ρ p) =
      (ρ p : ℂ) ^ m.natAbs := by
  have hcond : p.Prime ∧ 0 ≤ ρ p ∧ ρ p < 1 := ⟨hp, hρ0, hρ1⟩
  simp only [poissonMeasureOf, hcond, and_self, ↓reduceIte]
  have hf_meas : Measurable (poissonDensityNNOf ρ p) :=
    (poissonDensityNNOf_continuous hρ0 hρ1).measurable
  rw [integral_withDensity_eq_integral_smul hf_meas]
  have hpi0 : (0 : ℝ) ≤ 2 * Real.pi := by positivity
  have h_eq : ∀ θ : ℝ,
      (poissonDensityNNOf ρ p θ) • Complex.exp (Complex.I * (m : ℂ) * θ) =
        ((2 * Real.pi : ℂ)⁻¹) *
          (Complex.exp (Complex.I * (m : ℂ) * θ) * (poissonKernel (ρ p) θ : ℂ)) := by
    intro θ
    rw [NNReal.smul_def, Complex.real_smul, poissonDensityNNOf_coe hρ0 hρ1 θ]
    push_cast
    ring
  simp_rw [h_eq]
  rw [integral_const_mul, ← intervalIntegral.integral_of_le hpi0]
  exact poissonKernel_fourier_moment hρ0 hρ1 m

instance poissonMeasureOf_isProbabilityMeasure (ρ : ℕ → ℝ) (p : ℕ) :
    IsProbabilityMeasure (poissonMeasureOf ρ p) := by
  by_cases hcond : p.Prime ∧ 0 ≤ ρ p ∧ ρ p < 1
  · rcases hcond with ⟨hp, hρ0, hρ1⟩
    constructor
    simp only [poissonMeasureOf, hp, hρ0, hρ1, and_self, ↓reduceIte]
    rw [withDensity_apply _ MeasurableSet.univ, setLIntegral_univ]
    let f : ℝ → ℝ := fun θ => ((poissonDensityNNOf ρ p θ : ℝ≥0) : ℝ)
    have hf_cont : Continuous f := NNReal.continuous_coe.comp (poissonDensityNNOf_continuous hρ0 hρ1)
    have hf_int : Integrable f (volume.restrict (Set.Ioc 0 (2 * Real.pi))) :=
      hf_cont.continuousOn.integrableOn_Icc.mono_set Set.Ioc_subset_Icc_self
    have hf_nn : 0 ≤ᵐ[volume.restrict (Set.Ioc 0 (2 * Real.pi))] f :=
      ae_of_all _ (fun θ => NNReal.coe_nonneg _)
    have h_lint :
        (∫⁻ θ, (poissonDensityNNOf ρ p θ : ℝ≥0∞) ∂volume.restrict (Set.Ioc 0 (2 * Real.pi))) =
          ENNReal.ofReal (∫ θ, f θ ∂volume.restrict (Set.Ioc 0 (2 * Real.pi))) := by
      rw [ofReal_integral_eq_lintegral_ofReal hf_int hf_nn]
      congr 1; ext θ
      exact ENNReal.ofReal_coe_nnreal.symm
    rw [h_lint]
    have hpi0 : (0 : ℝ) ≤ 2 * Real.pi := by positivity
    have hm0 := poissonKernel_fourier_moment hρ0 hρ1 0
    simp only [Int.cast_zero, mul_zero, zero_mul, Complex.exp_zero, one_mul, Int.natAbs_zero,
      pow_zero] at hm0
    have hre : ∫ θ, f θ ∂volume.restrict (Set.Ioc 0 (2 * Real.pi)) = 1 := by
      have hc : (((∫ θ, f θ ∂volume.restrict (Set.Ioc 0 (2 * Real.pi))) : ℝ) : ℂ) = 1 := by
        calc (((∫ θ, f θ ∂volume.restrict (Set.Ioc 0 (2 * Real.pi))) : ℝ) : ℂ)
            = ∫ θ, (f θ : ℂ) ∂volume.restrict (Set.Ioc 0 (2 * Real.pi)) := by
              simpa using (Complex.ofRealCLM.integral_comp_comm hf_int).symm
          _ = ((2 * Real.pi : ℂ)⁻¹) *
                ∫ θ in (0 : ℝ)..(2 * Real.pi), (poissonKernel (ρ p) θ : ℂ) := by
              rw [intervalIntegral.integral_of_le hpi0, ← integral_const_mul]
              congr 1; ext θ
              dsimp [f]
              rw [poissonDensityNNOf_coe hρ0 hρ1 θ]
              push_cast; rfl
          _ = 1 := hm0
      exact_mod_cast hc
    rw [hre, ENNReal.ofReal_one]
  · simp only [poissonMeasureOf, hcond, ↓reduceIte]
    infer_instance

def primeTorusMeasureOf (ρ : ℕ → ℝ) : Measure (ℕ → ℝ) :=
  Measure.infinitePi (poissonMeasureOf ρ)

instance (ρ : ℕ → ℝ) : IsProbabilityMeasure (primeTorusMeasureOf ρ) := by
  unfold primeTorusMeasureOf
  infer_instance

theorem integral_finset_prod_primeTorusOf (ρ : ℕ → ℝ) (s : Finset ℕ) (f : ℕ → ℝ → ℂ)
    (hf : ∀ p ∈ s, AEStronglyMeasurable (f p) (poissonMeasureOf ρ p)) :
    ∫ ω, (∏ p ∈ s, f p (ω p)) ∂(primeTorusMeasureOf ρ) =
      ∏ p ∈ s, ∫ t, f p t ∂(poissonMeasureOf ρ p) := by
  let g : (Π _ : s, ℝ) → ℂ := fun y => ∏ p : s, f p.1 (y p)
  have hg_meas : AEStronglyMeasurable g (Measure.pi fun p : s => poissonMeasureOf ρ p.1) := by
    refine Finset.aestronglyMeasurable_fun_prod _ fun p _ => ?_
    exact (hf p.1 p.2).comp_measurePreserving
      (MeasureTheory.measurePreserving_eval (fun q : s => poissonMeasureOf ρ q.1) p)
  have hpi := MeasureTheory.integral_restrict_infinitePi
    (μ := poissonMeasureOf ρ) (s := s) (f := g) hg_meas
  have hprod : (∫ y, g y ∂Measure.pi fun p : s => poissonMeasureOf ρ p.1) =
      ∏ p : s, ∫ t, f p.1 t ∂(poissonMeasureOf ρ p.1) :=
    MeasureTheory.integral_fintype_prod_eq_prod (fun p : s => f p.1)
  have heq : (fun ω : ℕ → ℝ => g (s.restrict ω)) = fun ω => ∏ p ∈ s, f p (ω p) := by
    ext ω
    dsimp [g, Finset.restrict]
    exact Finset.prod_attach s (fun p => f p (ω p))
  unfold primeTorusMeasureOf
  rw [← heq, hpi, hprod]
  exact Finset.prod_attach s (fun p => ∫ t, f p t ∂(poissonMeasureOf ρ p))

/-! ## Inner product and monomial moments -/

def innerNuOf (ρ : ℕ → ℝ) (F G : (ℕ → ℝ) → ℂ) : ℂ :=
  ∫ ω, F ω * starRingEnd ℂ (G ω) ∂(primeTorusMeasureOf ρ)

private def localExpDiff (d e p : ℕ) (t : ℝ) : ℂ :=
  Complex.exp (Complex.I * (((d.factorization p : ℤ) - (e.factorization p : ℤ) : ℤ) : ℂ) * (t : ℂ))

theorem innerNuOf_Z {ρ : ℕ → ℝ} (hρ : ∀ p, p.Prime → 0 ≤ ρ p ∧ ρ p < 1)
    {d e : ℕ} (hd : d ≠ 0) (he : e ≠ 0) :
    innerNuOf ρ (Z d) (Z e) =
      ∏ p ∈ (d * e).primeFactors,
        (ρ p : ℂ) ^ ((d.factorization p : ℤ) - (e.factorization p : ℤ)).natAbs := by
  let S : Finset ℕ := (d * e).primeFactors
  have hS_primes : ∀ p ∈ S, p.Prime := fun p hp => Nat.prime_of_mem_primeFactors hp
  have hd_sub : d.primeFactors ⊆ S := by
    rw [show S = d.primeFactors ∪ e.primeFactors from Nat.primeFactors_mul hd he]
    exact Finset.subset_union_left
  have he_sub : e.primeFactors ⊆ S := by
    rw [show S = d.primeFactors ∪ e.primeFactors from Nat.primeFactors_mul hd he]
    exact Finset.subset_union_right
  have h_prod_eq : ∀ ω : ℕ → ℝ,
      Z d ω * starRingEnd ℂ (Z e ω) = ∏ p ∈ S, localExpDiff d e p (ω p) := by
    intro ω
    have hZd : Z d ω = ∏ p ∈ S, Complex.exp (Complex.I * ((d.factorization p : ℤ) : ℂ) * (ω p : ℂ)) := by
      unfold Z phasor
      have hp_eq : ∏ p ∈ d.primeFactors, Complex.exp (Complex.I * (ω p : ℂ)) ^ d.factorization p =
          ∏ p ∈ d.primeFactors, Complex.exp (Complex.I * ((d.factorization p : ℤ) : ℂ) * (ω p : ℂ)) := by
        refine Finset.prod_congr rfl fun p _ => ?_
        rw [← Complex.exp_nat_mul]; congr 1; push_cast; ring
      rw [hp_eq]
      refine Finset.prod_subset hd_sub fun p _ hp => ?_
      have hz : d.factorization p = 0 :=
        Finsupp.notMem_support_iff.mp (by simpa [Nat.support_factorization] using hp)
      simp [hz]
    have hZe : starRingEnd ℂ (Z e ω) =
        ∏ p ∈ S, Complex.exp (Complex.I * ((-(e.factorization p : ℤ) : ℤ) : ℂ) * (ω p : ℂ)) := by
      unfold Z phasor
      rw [map_prod]
      have hp_eq : ∏ p ∈ e.primeFactors, starRingEnd ℂ (Complex.exp (Complex.I * (ω p : ℂ)) ^ e.factorization p) =
          ∏ p ∈ e.primeFactors, Complex.exp (Complex.I * ((-(e.factorization p : ℤ) : ℤ) : ℂ) * (ω p : ℂ)) := by
        refine Finset.prod_congr rfl fun p _ => ?_
        rw [← Complex.exp_nat_mul, show (e.factorization p : ℂ) * (Complex.I * (ω p : ℂ)) =
          Complex.I * ((e.factorization p : ℤ) : ℂ) * (ω p : ℂ) by push_cast; ring]
        exact conj_exp_I_mul_int' (e.factorization p : ℤ) (ω p)
      rw [hp_eq]
      refine Finset.prod_subset he_sub fun p _ hp => ?_
      have hz : e.factorization p = 0 :=
        Finsupp.notMem_support_iff.mp (by simpa [Nat.support_factorization] using hp)
      simp [hz]
    rw [hZd, hZe, ← Finset.prod_mul_distrib]
    refine Finset.prod_congr rfl fun p _ => ?_
    rw [← Complex.exp_add]
    unfold localExpDiff
    congr 1; push_cast; ring
  have h_meas : ∀ p ∈ S, AEStronglyMeasurable (localExpDiff d e p) (poissonMeasureOf ρ p) := by
    intro p _
    unfold localExpDiff
    exact (Complex.continuous_exp.comp (continuous_const.mul Complex.continuous_ofReal)).aestronglyMeasurable
  unfold innerNuOf
  simp_rw [h_prod_eq]
  rw [integral_finset_prod_primeTorusOf ρ S (localExpDiff d e) h_meas]
  refine Finset.prod_congr rfl fun p hp => ?_
  have hp_prime := hS_primes p hp
  have hp_bounds := hρ p hp_prime
  exact integral_poissonMeasureOf_exp hp_prime hp_bounds.1 hp_bounds.2
    ((d.factorization p : ℤ) - (e.factorization p : ℤ))

/-! ## Orthogonal modes Ψ_r and weights j_ρ(r) -/

def phiLocalOf (ρ : ℕ → ℝ) (p a : ℕ) (t : ℝ) : ℂ :=
  if a = 0 then 1
  else Complex.exp (Complex.I * (a : ℂ) * (t : ℂ)) -
    (ρ p : ℂ) * Complex.exp (Complex.I * ((a - 1 : ℕ) : ℂ) * (t : ℂ))

@[simp] theorem phiLocalOf_zero (ρ : ℕ → ℝ) (p : ℕ) (t : ℝ) : phiLocalOf ρ p 0 t = 1 := by
  simp [phiLocalOf]

def PsiOf (ρ : ℕ → ℝ) (r : ℕ) (ω : ℕ → ℝ) : ℂ :=
  ∏ p ∈ r.primeFactors, phiLocalOf ρ p (r.factorization p) (ω p)

@[simp] theorem PsiOf_one (ρ : ℕ → ℝ) (ω : ℕ → ℝ) : PsiOf ρ 1 ω = 1 := by
  simp [PsiOf]

def jWeightOf (ρ : ℕ → ℝ) (r : ℕ) : ℝ :=
  ∏ p ∈ r.primeFactors, (1 - ρ p ^ 2)

@[simp] theorem jWeightOf_one (ρ : ℕ → ℝ) : jWeightOf ρ 1 = 1 := by
  simp [jWeightOf]

theorem jWeightOf_factor_nonneg {ρ : ℕ → ℝ} (hρ : ∀ p, p.Prime → 0 ≤ ρ p ∧ ρ p ≤ 1)
    {p : ℕ} (hp : p.Prime) : 0 ≤ 1 - ρ p ^ 2 := by
  have h1 := hρ p hp
  have hsq : ρ p ^ 2 ≤ 1 := by nlinarith
  linarith

theorem jWeightOf_nonneg {ρ : ℕ → ℝ} (hρ : ∀ p, p.Prime → 0 ≤ ρ p ∧ ρ p ≤ 1) (r : ℕ) :
    0 ≤ jWeightOf ρ r :=
  Finset.prod_nonneg fun _p hp => jWeightOf_factor_nonneg hρ (Nat.prime_of_mem_primeFactors hp)

theorem jWeightOf_le_one {ρ : ℕ → ℝ} (hρ : ∀ p, p.Prime → 0 ≤ ρ p ∧ ρ p ≤ 1) (r : ℕ) :
    jWeightOf ρ r ≤ 1 := by
  have hprod (T : Finset ℕ) (hT : T ⊆ r.primeFactors) :
      (∏ p ∈ T, (1 - ρ p ^ 2)) ≤ 1 := by
    induction T using Finset.induction_on with
    | empty => simp
    | insert p T hp ih =>
      have hsub : T ⊆ r.primeFactors := (Finset.subset_insert _ _).trans hT
      rw [Finset.prod_insert hp]
      calc (1 - ρ p ^ 2) * ∏ q ∈ T, (1 - ρ q ^ 2)
          ≤ 1 * 1 := mul_le_mul (sub_le_self _ (sq_nonneg _)) (ih hsub)
            (Finset.prod_nonneg fun q hq =>
              jWeightOf_factor_nonneg hρ (Nat.prime_of_mem_primeFactors (hsub hq)))
            zero_le_one
        _ = 1 := one_mul _
  exact hprod r.primeFactors (fun _ h => h)

private lemma phiLocalOf_continuous (ρ : ℕ → ℝ) (p a : ℕ) : Continuous (phiLocalOf ρ p a) := by
  unfold phiLocalOf
  split_ifs
  · exact continuous_const
  · fun_prop

private lemma single_prime_phiLocalOf_inner {ρ : ℕ → ℝ} {p : ℕ} (hp : p.Prime)
    (hρ0 : 0 ≤ ρ p) (hρ1 : ρ p < 1) (a b : ℕ) :
    ∫ t, phiLocalOf ρ p a t * starRingEnd ℂ (phiLocalOf ρ p b t) ∂(poissonMeasureOf ρ p) =
      if a = b then (if a = 0 then (1 : ℂ) else 1 - (ρ p : ℂ) ^ 2) else 0 := by
  have h_int_exp : ∀ m : ℤ,
      Integrable (fun t : ℝ => Complex.exp (Complex.I * (m : ℂ) * (t : ℂ))) (poissonMeasureOf ρ p) := by
    intro m
    refine Integrable.of_bound
      ((Complex.continuous_exp.comp (continuous_const.mul Complex.continuous_ofReal)).aestronglyMeasurable)
      1 (ae_of_all _ fun t => ?_)
    rw [show ‖Complex.exp (Complex.I * (m : ℂ) * (t : ℂ))‖ = 1 by
      simpa [mul_assoc] using norm_exp_I_mul_real' ((m : ℝ) * t)]
  by_cases ha : a = 0 <;> by_cases hb : b = 0
  · subst ha; subst hb
    simp [phiLocalOf]
  · subst ha
    have hbpos : 0 < b := Nat.pos_of_ne_zero hb
    have hfun : (fun t : ℝ => phiLocalOf ρ p 0 t * starRingEnd ℂ (phiLocalOf ρ p b t)) =
        fun t : ℝ =>
          Complex.exp (Complex.I * ((-(b : ℤ) : ℤ) : ℂ) * (t : ℂ)) -
          (ρ p : ℂ) * Complex.exp (Complex.I * ((-((b - 1 : ℕ) : ℤ) : ℤ) : ℂ) * (t : ℂ)) := by
      ext t
      simp only [phiLocalOf, ↓reduceIte, hb, one_mul, map_sub, map_mul, Complex.conj_ofReal]
      have c1 := conj_exp_I_mul_int' (b : ℤ) t
      have c2 := conj_exp_I_mul_int' ((b - 1 : ℕ) : ℤ) t
      push_cast at c1 c2 ⊢
      rw [c1, c2]
    rw [hfun, integral_sub (h_int_exp _) ((h_int_exp _).const_mul _), integral_const_mul,
      integral_poissonMeasureOf_exp hp hρ0 hρ1 (-(b : ℤ)),
      integral_poissonMeasureOf_exp hp hρ0 hρ1 (-((b - 1 : ℕ) : ℤ))]
    have hnab1 : (-(b : ℤ)).natAbs = b := by omega
    have hnab2 : (-((b - 1 : ℕ) : ℤ)).natAbs = b - 1 := by omega
    have h0b : (0 : ℕ) ≠ b := Ne.symm hb
    rw [hnab1, hnab2]
    simp only [h0b, ↓reduceIte]
    have hpow : (ρ p : ℂ) ^ b = (ρ p : ℂ) * (ρ p : ℂ) ^ (b - 1) := by
      conv_lhs => rw [show b = 1 + (b - 1) by omega, pow_add, pow_one]
    rw [hpow, sub_self]
  · subst hb
    have hapos : 0 < a := Nat.pos_of_ne_zero ha
    have hfun : (fun t : ℝ => phiLocalOf ρ p a t * starRingEnd ℂ (phiLocalOf ρ p 0 t)) =
        fun t : ℝ =>
          Complex.exp (Complex.I * ((a : ℤ) : ℂ) * (t : ℂ)) -
          (ρ p : ℂ) * Complex.exp (Complex.I * (((a - 1 : ℕ) : ℤ) : ℂ) * (t : ℂ)) := by
      ext t
      simp only [phiLocalOf, ha, ↓reduceIte, map_one, mul_one]
      push_cast; rfl
    rw [hfun, integral_sub (h_int_exp _) ((h_int_exp _).const_mul _), integral_const_mul,
      integral_poissonMeasureOf_exp hp hρ0 hρ1 (a : ℤ),
      integral_poissonMeasureOf_exp hp hρ0 hρ1 ((a - 1 : ℕ) : ℤ)]
    have hnab1 : ((a : ℤ)).natAbs = a := by omega
    have hnab2 : (((a - 1 : ℕ) : ℤ)).natAbs = a - 1 := by omega
    rw [hnab1, hnab2]
    simp only [ha, ↓reduceIte]
    have hpow : (ρ p : ℂ) ^ a = (ρ p : ℂ) * (ρ p : ℂ) ^ (a - 1) := by
      conv_lhs => rw [show a = 1 + (a - 1) by omega, pow_add, pow_one]
    rw [hpow, sub_self]
  · have hapos : 0 < a := Nat.pos_of_ne_zero ha
    have hbpos : 0 < b := Nat.pos_of_ne_zero hb
    have hfun : (fun t : ℝ => phiLocalOf ρ p a t * starRingEnd ℂ (phiLocalOf ρ p b t)) =
        fun t : ℝ =>
          (Complex.exp (Complex.I * (((a : ℤ) - (b : ℤ) : ℤ) : ℂ) * (t : ℂ)) -
           (ρ p : ℂ) * Complex.exp (Complex.I * (((a : ℤ) - ((b - 1 : ℕ) : ℤ) : ℤ) : ℂ) * (t : ℂ))) -
          ((ρ p : ℂ) * Complex.exp (Complex.I * ((((a - 1 : ℕ) : ℤ) - (b : ℤ) : ℤ) : ℂ) * (t : ℂ)) -
           ((ρ p : ℂ) * (ρ p : ℂ)) *
             Complex.exp (Complex.I * ((((a - 1 : ℕ) : ℤ) - ((b - 1 : ℕ) : ℤ) : ℤ) : ℂ) * (t : ℂ))) := by
      ext t
      simp only [phiLocalOf, ha, hb, ↓reduceIte, map_sub, map_mul, Complex.conj_ofReal]
      have c1 := conj_exp_I_mul_int' (b : ℤ) t
      have c2 := conj_exp_I_mul_int' ((b - 1 : ℕ) : ℤ) t
      push_cast at c1 c2 ⊢
      rw [c1, c2]
      have m11 : Complex.exp (Complex.I * (a : ℂ) * (t : ℂ)) * Complex.exp (Complex.I * (-(b : ℂ)) * (t : ℂ)) =
          Complex.exp (Complex.I * (((a : ℤ) - (b : ℤ) : ℤ) : ℂ) * (t : ℂ)) := by
        rw [← Complex.exp_add]; congr 1; push_cast; ring
      have m12 : Complex.exp (Complex.I * (a : ℂ) * (t : ℂ)) * Complex.exp (Complex.I * (-((b - 1 : ℕ) : ℂ)) * (t : ℂ)) =
          Complex.exp (Complex.I * (((a : ℤ) - ((b - 1 : ℕ) : ℤ) : ℤ) : ℂ) * (t : ℂ)) := by
        rw [← Complex.exp_add]; congr 1; push_cast; ring
      have m21 : Complex.exp (Complex.I * ((a - 1 : ℕ) : ℂ) * (t : ℂ)) * Complex.exp (Complex.I * (-(b : ℂ)) * (t : ℂ)) =
          Complex.exp (Complex.I * ((((a - 1 : ℕ) : ℤ) - (b : ℤ) : ℤ) : ℂ) * (t : ℂ)) := by
        rw [← Complex.exp_add]; congr 1; push_cast; ring
      have m22 : Complex.exp (Complex.I * ((a - 1 : ℕ) : ℂ) * (t : ℂ)) * Complex.exp (Complex.I * (-((b - 1 : ℕ) : ℂ)) * (t : ℂ)) =
          Complex.exp (Complex.I * ((((a - 1 : ℕ) : ℤ) - ((b - 1 : ℕ) : ℤ) : ℤ) : ℂ) * (t : ℂ)) := by
        rw [← Complex.exp_add]; congr 1; push_cast; ring
      have h_alg :
          (Complex.exp (Complex.I * (a : ℂ) * (t : ℂ)) -
            (ρ p : ℂ) * Complex.exp (Complex.I * ((a - 1 : ℕ) : ℂ) * (t : ℂ))) *
          (Complex.exp (Complex.I * (-(b : ℂ)) * (t : ℂ)) -
            (ρ p : ℂ) * Complex.exp (Complex.I * (-((b - 1 : ℕ) : ℂ)) * (t : ℂ))) =
          (Complex.exp (Complex.I * (a : ℂ) * (t : ℂ)) * Complex.exp (Complex.I * (-(b : ℂ)) * (t : ℂ)) -
           (ρ p : ℂ) * (Complex.exp (Complex.I * (a : ℂ) * (t : ℂ)) * Complex.exp (Complex.I * (-((b - 1 : ℕ) : ℂ)) * (t : ℂ)))) -
          ((ρ p : ℂ) * (Complex.exp (Complex.I * ((a - 1 : ℕ) : ℂ) * (t : ℂ)) * Complex.exp (Complex.I * (-(b : ℂ)) * (t : ℂ))) -
           ((ρ p : ℂ) * (ρ p : ℂ)) * (Complex.exp (Complex.I * ((a - 1 : ℕ) : ℂ) * (t : ℂ)) * Complex.exp (Complex.I * (-((b - 1 : ℕ) : ℂ)) * (t : ℂ)))) := by
        ring
      rw [h_alg, m11, m12, m21, m22]
      push_cast
      rfl
    rw [hfun]
    have hi1 : Integrable (fun t : ℝ =>
        Complex.exp (Complex.I * (((a : ℤ) - (b : ℤ) : ℤ) : ℂ) * (t : ℂ)) -
        (ρ p : ℂ) * Complex.exp (Complex.I * (((a : ℤ) - ((b - 1 : ℕ) : ℤ) : ℤ) : ℂ) * (t : ℂ))) (poissonMeasureOf ρ p) :=
      (h_int_exp _).sub ((h_int_exp _).const_mul _)
    have hi2 : Integrable (fun t : ℝ =>
        (ρ p : ℂ) * Complex.exp (Complex.I * ((((a - 1 : ℕ) : ℤ) - (b : ℤ) : ℤ) : ℂ) * (t : ℂ)) -
        ((ρ p : ℂ) * (ρ p : ℂ)) * Complex.exp (Complex.I * ((((a - 1 : ℕ) : ℤ) - ((b - 1 : ℕ) : ℤ) : ℤ) : ℂ) * (t : ℂ))) (poissonMeasureOf ρ p) :=
      ((h_int_exp _).const_mul _).sub ((h_int_exp _).const_mul _)
    rw [integral_sub hi1 hi2,
      integral_sub (h_int_exp _) ((h_int_exp _).const_mul _),
      integral_sub ((h_int_exp _).const_mul _) ((h_int_exp _).const_mul _),
      integral_const_mul, integral_const_mul, integral_const_mul,
      integral_poissonMeasureOf_exp hp hρ0 hρ1 ((a : ℤ) - (b : ℤ)),
      integral_poissonMeasureOf_exp hp hρ0 hρ1 ((a : ℤ) - ((b - 1 : ℕ) : ℤ)),
      integral_poissonMeasureOf_exp hp hρ0 hρ1 (((a - 1 : ℕ) : ℤ) - (b : ℤ)),
      integral_poissonMeasureOf_exp hp hρ0 hρ1 (((a - 1 : ℕ) : ℤ) - ((b - 1 : ℕ) : ℤ))]
    rcases Nat.lt_trichotomy a b with hab | rfl | hab
    · have hne : a ≠ b := by omega
      rw [ite_eq_right hne]
      have h1 : ((a : ℤ) - (b : ℤ)).natAbs = b - a := by omega
      have h2 : ((a : ℤ) - ((b - 1 : ℕ) : ℤ)).natAbs = b - 1 - a := by omega
      have h3 : (((a - 1 : ℕ) : ℤ) - (b : ℤ)).natAbs = b - a + 1 := by omega
      have h4 : (((a - 1 : ℕ) : ℤ) - ((b - 1 : ℕ) : ℤ)).natAbs = b - a := by omega
      rw [h1, h2, h3, h4]
      have ha1 : (ρ p : ℂ) ^ (b - a) = (ρ p : ℂ) * (ρ p : ℂ) ^ (b - 1 - a) := by
        conv_lhs => rw [show b - a = 1 + (b - 1 - a) by omega, pow_add, pow_one]
      have ha2 : (ρ p : ℂ) ^ (b - a + 1) = (ρ p : ℂ) * (ρ p : ℂ) ^ (b - a) := by
        rw [pow_add, pow_one, mul_comm]
      rw [ha2, ha1]; ring
    · rw [ite_eq_left rfl, ite_eq_right ha]
      have h1 : ((a : ℤ) - (a : ℤ)).natAbs = 0 := by omega
      have h2 : ((a : ℤ) - ((a - 1 : ℕ) : ℤ)).natAbs = 1 := by omega
      have h3 : (((a - 1 : ℕ) : ℤ) - (a : ℤ)).natAbs = 1 := by omega
      have h4 : (((a - 1 : ℕ) : ℤ) - ((a - 1 : ℕ) : ℤ)).natAbs = 0 := by omega
      rw [h1, h2, h3, h4, pow_zero, pow_one, sq]
      ring
    · have hne : a ≠ b := by omega
      rw [ite_eq_right hne]
      have h1 : ((a : ℤ) - (b : ℤ)).natAbs = a - b := by omega
      have h2 : ((a : ℤ) - ((b - 1 : ℕ) : ℤ)).natAbs = a - b + 1 := by omega
      have h3 : (((a - 1 : ℕ) : ℤ) - (b : ℤ)).natAbs = a - 1 - b := by omega
      have h4 : (((a - 1 : ℕ) : ℤ) - ((b - 1 : ℕ) : ℤ)).natAbs = a - b := by omega
      rw [h1, h2, h3, h4]
      have ha1 : (ρ p : ℂ) ^ (a - b + 1) = (ρ p : ℂ) * (ρ p : ℂ) ^ (a - b) := by
        rw [pow_add, pow_one, mul_comm]
      have ha2 : (ρ p : ℂ) ^ (a - b) = (ρ p : ℂ) * (ρ p : ℂ) ^ (a - 1 - b) := by
        conv_lhs => rw [show a - b = 1 + (a - 1 - b) by omega, pow_add, pow_one]
      rw [ha1, ha2]; ring

theorem innerNuOf_PsiOf {ρ : ℕ → ℝ} (hρ : ∀ p, p.Prime → 0 ≤ ρ p ∧ ρ p < 1)
    {r s : ℕ} (hr : r ≠ 0) (hs : s ≠ 0) :
    innerNuOf ρ (PsiOf ρ r) (PsiOf ρ s) = if r = s then (jWeightOf ρ r : ℂ) else 0 := by
  let S : Finset ℕ := (r * s).primeFactors
  have hS_primes : ∀ p ∈ S, p.Prime := fun p hp => Nat.prime_of_mem_primeFactors hp
  have hr_sub : r.primeFactors ⊆ S := by
    rw [show S = r.primeFactors ∪ s.primeFactors from Nat.primeFactors_mul hr hs]
    exact Finset.subset_union_left
  have hs_sub : s.primeFactors ⊆ S := by
    rw [show S = r.primeFactors ∪ s.primeFactors from Nat.primeFactors_mul hr hs]
    exact Finset.subset_union_right
  have h_prod_eq : ∀ ω : ℕ → ℝ,
      PsiOf ρ r ω * starRingEnd ℂ (PsiOf ρ s ω) =
        ∏ p ∈ S, (phiLocalOf ρ p (r.factorization p) (ω p) *
          starRingEnd ℂ (phiLocalOf ρ p (s.factorization p) (ω p))) := by
    intro ω
    have hPr : PsiOf ρ r ω = ∏ p ∈ S, phiLocalOf ρ p (r.factorization p) (ω p) := by
      unfold PsiOf
      refine Finset.prod_subset hr_sub fun p _ hp => ?_
      have hz : r.factorization p = 0 :=
        Finsupp.notMem_support_iff.mp (by simpa [Nat.support_factorization] using hp)
      simp [hz]
    have hPs : starRingEnd ℂ (PsiOf ρ s ω) =
        ∏ p ∈ S, starRingEnd ℂ (phiLocalOf ρ p (s.factorization p) (ω p)) := by
      unfold PsiOf
      rw [map_prod]
      refine Finset.prod_subset hs_sub fun p _ hp => ?_
      have hz : s.factorization p = 0 :=
        Finsupp.notMem_support_iff.mp (by simpa [Nat.support_factorization] using hp)
      simp [hz]
    rw [hPr, hPs, ← Finset.prod_mul_distrib]
  have h_meas : ∀ p ∈ S,
      AEStronglyMeasurable
        (fun t => phiLocalOf ρ p (r.factorization p) t *
          starRingEnd ℂ (phiLocalOf ρ p (s.factorization p) t))
        (poissonMeasureOf ρ p) := by
    intro p _
    exact ((phiLocalOf_continuous ρ p _).mul
      (Complex.continuous_conj.comp (phiLocalOf_continuous ρ p _))).aestronglyMeasurable
  unfold innerNuOf
  simp_rw [h_prod_eq]
  rw [integral_finset_prod_primeTorusOf ρ S _ h_meas]
  have h_factor : ∀ p ∈ S,
      (∫ t, phiLocalOf ρ p (r.factorization p) t *
          starRingEnd ℂ (phiLocalOf ρ p (s.factorization p) t) ∂(poissonMeasureOf ρ p)) =
        if r.factorization p = s.factorization p then
          (if r.factorization p = 0 then (1 : ℂ) else 1 - (ρ p : ℂ) ^ 2)
        else 0 := fun p hp =>
    single_prime_phiLocalOf_inner (hS_primes p hp)
      (hρ p (hS_primes p hp)).1 (hρ p (hS_primes p hp)).2 _ _
  rw [Finset.prod_congr rfl h_factor]
  by_cases hrs : r = s
  · subst hrs
    simp only [↓reduceIte]
    unfold jWeightOf
    rw [Complex.ofReal_prod]
    have hS_eq : S = r.primeFactors := by
      dsimp [S]; rw [Nat.primeFactors_mul hr hr, Finset.union_self]
    rw [hS_eq]
    refine Finset.prod_congr rfl fun p hp => ?_
    have hpos : r.factorization p ≠ 0 :=
      (Nat.Prime.factorization_pos_of_dvd (Nat.prime_of_mem_primeFactors hp) hr
        (Nat.dvd_of_mem_primeFactors hp)).ne'
    simp only [↓reduceIte, hpos]
    push_cast
    rfl
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

/-! ## Expansion Z(n) = ∑_{r | n} ρ(n/r) Ψ_r -/

private lemma PsiOf_prime_pow (ρ : ℕ → ℝ) {p k : ℕ} (hp : p.Prime) (ω : ℕ → ℝ) :
    PsiOf ρ (p ^ k) ω = phiLocalOf ρ p k (ω p) := by
  by_cases hk : k = 0
  · subst hk; simp
  · unfold PsiOf
    rw [Nat.primeFactors_prime_pow hk hp, Finset.prod_singleton, hp.factorization_pow,
      Finsupp.single_eq_same]

private lemma PsiOf_mul_coprime (ρ : ℕ → ℝ) {m n : ℕ} (hm : m ≠ 0) (hn : n ≠ 0)
    (hmn : m.Coprime n) (ω : ℕ → ℝ) :
    PsiOf ρ (m * n) ω = PsiOf ρ m ω * PsiOf ρ n ω := by
  unfold PsiOf
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

private def ZArithOf (ω : ℕ → ℝ) : ArithmeticFunction ℂ :=
  ⟨fun n => if n = 0 then 0 else Z n ω, by simp⟩

private theorem ZArithOf_isMultiplicative (ω : ℕ → ℝ) : (ZArithOf ω).IsMultiplicative := by
  refine ⟨by simp [ZArithOf], fun {m n} _ => ?_⟩
  by_cases hm : m = 0
  · subst hm; simp [ZArithOf]
  · by_cases hn : n = 0
    · subst hn; simp [ZArithOf]
    · simp [ZArithOf, hm, hn, mul_ne_zero hm hn, Z_mul hm hn ω]

theorem Z_eq_sum_PsiOf (ρ : ℕ → ℝ) {n : ℕ} (hn : n ≠ 0) (ω : ℕ → ℝ) :
    Z n ω = ∑ r ∈ n.divisors, (rhoProd ρ (n / r) : ℂ) * PsiOf ρ r ω := by
  let A : ArithmeticFunction ℂ := ⟨fun k => if k = 0 then 0 else (rhoProd ρ k : ℂ), by simp⟩
  let P : ArithmeticFunction ℂ := ⟨fun r => if r = 0 then 0 else PsiOf ρ r ω, by simp⟩
  have hA_mult : A.IsMultiplicative := by
    refine ⟨by simp [A], fun {a b} _ => ?_⟩
    by_cases ha : a = 0
    · subst ha; simp [A]
    · by_cases hb : b = 0
      · subst hb; simp [A]
      · simp [A, ha, hb, mul_ne_zero ha hb, rhoProd_mul ρ ha hb, Complex.ofReal_mul]
  have hP_mult : P.IsMultiplicative := by
    refine ⟨by simp [P], fun {a b} hab => ?_⟩
    by_cases ha : a = 0
    · subst ha; simp [P]
    · by_cases hb : b = 0
      · subst hb; simp [P]
      · simp [P, ha, hb, mul_ne_zero ha hb, PsiOf_mul_coprime ρ ha hb hab ω]
  let Q : ArithmeticFunction ℂ := P * A
  have hQ_mult : Q.IsMultiplicative := hP_mult.mul hA_mult
  have hQ_apply : ∀ k : ℕ, k ≠ 0 →
      Q k = ∑ r ∈ k.divisors, (rhoProd ρ (k / r) : ℂ) * PsiOf ρ r ω := by
    intro k hk
    have hQ_eq : Q k = (A * P) k := by simp [Q, mul_comm]
    rw [hQ_eq, ArithmeticFunction.mul_apply,
      Nat.sum_divisorsAntidiagonal' (f := fun x y => A x * P y)]
    refine Finset.sum_congr rfl fun r hr => ?_
    have hr0 : r ≠ 0 := ne_zero_of_dvd_ne_zero hk (Nat.dvd_of_mem_divisors hr)
    have hkr0 : k / r ≠ 0 :=
      Nat.div_ne_zero_iff.mpr ⟨hr0, Nat.le_of_dvd (Nat.pos_of_ne_zero hk) (Nat.dvd_of_mem_divisors hr)⟩
    simp [A, P, hr0, hkr0]
  have hZ_mult : (ZArithOf ω).IsMultiplicative := ZArithOf_isMultiplicative ω
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
          = ZArithOf ω (∏ p ∈ n.primeFactors, p ^ n.factorization p) := by
            simp [ZArithOf, hn_prod_nz]
        _ = ∏ p ∈ n.primeFactors, ZArithOf ω (p ^ n.factorization p) := hmult
        _ = ∏ p ∈ n.primeFactors, Z (p ^ n.factorization p) ω :=
            Finset.prod_congr rfl fun p hp => by
              have hp0 : p ≠ 0 := (Nat.prime_of_mem_primeFactors hp).ne_zero
              simp [ZArithOf, hp0]
    conv_lhs => rw [Nat.prod_primeFactors_pow_factorization hn, hQ_mult.map_prod _ _ hpair]
    rw [hz_prod]
    refine Finset.prod_congr rfl fun p hp => ?_
    have hprime : p.Prime := Nat.prime_of_mem_primeFactors hp
    have hpk0 : p ^ n.factorization p ≠ 0 := pow_ne_zero _ hprime.ne_zero
    rw [hQ_apply _ hpk0, Nat.sum_divisors_prime_pow hprime]
    have htelescope : ∀ k : ℕ,
        ∑ i ∈ Finset.range (k + 1), (rhoProd ρ (p ^ k / p ^ i) : ℂ) * PsiOf ρ (p ^ i) ω =
          Z (p ^ k) ω := by
      intro k
      induction k with
      | zero => simp
      | succ m ih =>
        rw [Finset.sum_range_succ]
        have h_last : (rhoProd ρ (p ^ (m + 1) / p ^ (m + 1)) : ℂ) * PsiOf ρ (p ^ (m + 1)) ω =
            Z (p ^ (m + 1)) ω - (ρ p : ℂ) * Z (p ^ m) ω := by
          rw [Nat.div_self (pow_pos hprime.pos _), rhoProd_one, Complex.ofReal_one, one_mul,
            PsiOf_prime_pow ρ hprime, Z_prime_pow hprime, Z_prime_pow hprime]
          simp only [phiLocalOf, Nat.add_eq_zero_iff, one_ne_zero, and_false, ↓reduceIte,
            Nat.add_sub_cancel]
          have heq1 : Complex.exp (Complex.I * ((m + 1 : ℕ) : ℂ) * (ω p : ℂ)) = phasor p ω ^ (m + 1) := by
            unfold phasor; rw [← Complex.exp_nat_mul]; congr 1; push_cast; ring
          have heq0 : Complex.exp (Complex.I * (m : ℂ) * (ω p : ℂ)) = phasor p ω ^ m := by
            unfold phasor; rw [← Complex.exp_nat_mul]; congr 1; ring
          rw [heq1, heq0]
        have h_head : (∑ i ∈ Finset.range (m + 1),
              (rhoProd ρ (p ^ (m + 1) / p ^ i) : ℂ) * PsiOf ρ (p ^ i) ω) =
            (ρ p : ℂ) * Z (p ^ m) ω := by
          calc (∑ i ∈ Finset.range (m + 1),
                  (rhoProd ρ (p ^ (m + 1) / p ^ i) : ℂ) * PsiOf ρ (p ^ i) ω)
              = ∑ i ∈ Finset.range (m + 1),
                  (ρ p : ℂ) * ((rhoProd ρ (p ^ m / p ^ i) : ℂ) * PsiOf ρ (p ^ i) ω) := by
                refine Finset.sum_congr rfl fun i hi => ?_
                have him : i ≤ m := Nat.lt_succ_iff.mp (Finset.mem_range.mp hi)
                rw [Nat.pow_div (by omega) hprime.pos, Nat.pow_div him hprime.pos,
                  rhoProd_prime_pow ρ hprime, rhoProd_prime_pow ρ hprime,
                  show m + 1 - i = (m - i) + 1 by omega, pow_succ]
                push_cast; ring
            _ = (ρ p : ℂ) * ∑ i ∈ Finset.range (m + 1),
                  (rhoProd ρ (p ^ m / p ^ i) : ℂ) * PsiOf ρ (p ^ i) ω := (Finset.mul_sum ..).symm
            _ = (ρ p : ℂ) * Z (p ^ m) ω := by rw [ih]
        rw [h_head, h_last, add_sub_cancel]
    exact htelescope (n.factorization p)
  rw [← hQ_apply n hn, h_eq_Q]

/-! ## General-radius Parseval identity -/

def scalarSOf (ρ : ℕ → ℝ) (B n : ℕ) : ℝ :=
  ∑ k ∈ (Finset.Icc 1 n).filter (fun k => Nat.Coprime k B), mertens (n / k) * rhoProd ρ k

def energyOf (ρ : ℕ → ℝ) (B X : ℕ) : ℝ :=
  ∑ r ∈ (Finset.Icc 1 X).filter (fun r => Nat.Coprime r B), jWeightOf ρ r * (scalarSOf ρ B (X / r)) ^ 2

theorem D_eq_sum_PsiOf (ρ : ℕ → ℝ) {B : ℕ} (hB : 1 ≤ B) (X : ℕ) (ω : ℕ → ℝ) :
    D B X ω =
      ∑ r ∈ (Finset.Icc 1 X).filter (fun r => Nat.Coprime r B),
        (scalarSOf ρ B (X / r) : ℂ) * PsiOf ρ r ω := by
  rw [D_eq_mertens_sum hB X ω]
  have hbox_L :
      (∑ d ∈ (Finset.Icc 1 X).filter (fun d => Nat.Coprime d B), (mertens (X / d) : ℂ) * Z d ω) =
        ∑ d ∈ Finset.Icc 1 X, ∑ r ∈ Finset.Icc 1 X,
          if d.Coprime B ∧ r ∣ d then
            (mertens (X / d) : ℂ) * (rhoProd ρ (d / r) : ℂ) * PsiOf ρ r ω
          else 0 := by
    rw [Finset.sum_filter]
    refine Finset.sum_congr rfl fun d hd => ?_
    have hd_pos : 0 < d := (Finset.mem_Icc.mp hd).1
    have hd_le : d ≤ X := (Finset.mem_Icc.mp hd).2
    by_cases hdc : d.Coprime B
    · rw [ite_eq_left hdc, Z_eq_sum_PsiOf ρ hd_pos.ne' ω, Finset.mul_sum]
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
      (∑ r ∈ (Finset.Icc 1 X).filter (fun r => Nat.Coprime r B), (scalarSOf ρ B (X / r) : ℂ) * PsiOf ρ r ω) =
        ∑ r ∈ Finset.Icc 1 X, ∑ d ∈ Finset.Icc 1 X,
          if d.Coprime B ∧ r ∣ d then
            (mertens (X / d) : ℂ) * (rhoProd ρ (d / r) : ℂ) * PsiOf ρ r ω
          else 0 := by
    rw [Finset.sum_filter]
    refine Finset.sum_congr rfl fun r hr => ?_
    have hr_pos : 0 < r := (Finset.mem_Icc.mp hr).1
    by_cases hrc : r.Coprime B
    · rw [ite_eq_left hrc]
      unfold scalarSOf
      rw [Complex.ofReal_sum, Finset.sum_filter, Finset.sum_mul]
      have h_rk :
          (∑ k ∈ Finset.Icc 1 (X / r),
              (if k.Coprime B then ((mertens ((X / r) / k) * rhoProd ρ k : ℝ) : ℂ) else 0) * PsiOf ρ r ω) =
            ∑ d ∈ Finset.Icc 1 X,
              if d.Coprime B ∧ r ∣ d then
                (mertens (X / d) : ℂ) * (rhoProd ρ (d / r) : ℂ) * PsiOf ρ r ω
              else 0 := by
        symm
        calc (∑ d ∈ Finset.Icc 1 X,
                if d.Coprime B ∧ r ∣ d then
                  (mertens (X / d) : ℂ) * (rhoProd ρ (d / r) : ℂ) * PsiOf ρ r ω
                else 0)
            = ∑ d ∈ Finset.Icc 1 X, ∑ k ∈ Finset.Icc 1 (X / r),
                if r * k = d ∧ k.Coprime B then
                  (mertens (X / d) : ℂ) * (rhoProd ρ (d / r) : ℂ) * PsiOf ρ r ω
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
                      (mertens (X / d) : ℂ) * (rhoProd ρ (d / r) : ℂ) * PsiOf ρ r ω
                    else 0) = 0 := by
                  intro k _
                  have hnot : ¬ (r * k = d ∧ k.Coprime B) := fun ⟨hrk, _⟩ => hdiv ⟨k, hrk.symm⟩
                  rw [ite_eq_right hnot]
                rw [Finset.sum_eq_zero hzero, ite_eq_right (fun h => hdiv h.2)]
          _ = ∑ k ∈ Finset.Icc 1 (X / r), ∑ d ∈ Finset.Icc 1 X,
                if r * k = d ∧ k.Coprime B then
                  (mertens (X / d) : ℂ) * (rhoProd ρ (d / r) : ℂ) * PsiOf ρ r ω
                else 0 := Finset.sum_comm
          _ = ∑ k ∈ Finset.Icc 1 (X / r),
                (if k.Coprime B then ((mertens ((X / r) / k) * rhoProd ρ k : ℝ) : ℂ) else 0) * PsiOf ρ r ω := by
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
                  push_cast; rfl
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

private lemma norm_phiLocalOf_le_two {ρ : ℕ → ℝ} (hρ : ∀ p, p.Prime → 0 ≤ ρ p ∧ ρ p < 1)
    {p : ℕ} (hp : p.Prime) (a : ℕ) (t : ℝ) : ‖phiLocalOf ρ p a t‖ ≤ 2 := by
  unfold phiLocalOf
  split_ifs
  · norm_num
  · have h1 : ‖Complex.exp (Complex.I * (a : ℂ) * (t : ℂ))‖ = 1 := by
      simpa [mul_assoc] using norm_exp_I_mul_real' ((a : ℝ) * t)
    have hρ_le : |ρ p| ≤ 1 := abs_le.mpr ⟨by linarith [(hρ p hp).1], (hρ p hp).2.le⟩
    have h2 : ‖(ρ p : ℂ) * Complex.exp (Complex.I * ((a - 1 : ℕ) : ℂ) * (t : ℂ))‖ ≤ 1 := by
      rw [norm_mul, Complex.norm_real, Real.norm_eq_abs,
        show ‖Complex.exp (Complex.I * ((a - 1 : ℕ) : ℂ) * (t : ℂ))‖ = 1 by
          simpa [mul_assoc] using norm_exp_I_mul_real' (((a - 1 : ℕ) : ℝ) * t), mul_one]
      exact hρ_le
    calc ‖Complex.exp (Complex.I * (a : ℂ) * (t : ℂ)) -
            (ρ p : ℂ) * Complex.exp (Complex.I * ((a - 1 : ℕ) : ℂ) * (t : ℂ))‖
        ≤ ‖Complex.exp (Complex.I * (a : ℂ) * (t : ℂ))‖ +
            ‖(ρ p : ℂ) * Complex.exp (Complex.I * ((a - 1 : ℕ) : ℂ) * (t : ℂ))‖ := norm_sub_le _ _
      _ ≤ 1 + 1 := add_le_add (le_of_eq h1) h2
      _ = 2 := by norm_num

private lemma PsiOf_continuous (ρ : ℕ → ℝ) (r : ℕ) : Continuous (PsiOf ρ r) := by
  unfold PsiOf
  exact continuous_finsetProd _ fun p _ => (phiLocalOf_continuous ρ p _).comp (continuous_apply p)

private lemma norm_PsiOf_le {ρ : ℕ → ℝ} (hρ : ∀ p, p.Prime → 0 ≤ ρ p ∧ ρ p < 1)
    (r : ℕ) (ω : ℕ → ℝ) : ‖PsiOf ρ r ω‖ ≤ (2 : ℝ) ^ r.primeFactors.card := by
  have hprod (T : Finset ℕ) (hT : T ⊆ r.primeFactors) :
      ∏ p ∈ T, ‖phiLocalOf ρ p (r.factorization p) (ω p)‖ ≤ (2 : ℝ) ^ T.card := by
    induction T using Finset.cons_induction with
    | empty => simp
    | cons p s hp ih =>
      have hps : p ∈ r.primeFactors := hT (Finset.mem_cons_self p s)
      have hs_sub : s ⊆ r.primeFactors := fun q hq => hT (Finset.mem_cons_of_mem hq)
      simp only [Finset.prod_cons, Finset.card_cons, pow_succ']
      exact mul_le_mul (norm_phiLocalOf_le_two hρ (Nat.prime_of_mem_primeFactors hps) _ _)
        (ih hs_sub) (Finset.prod_nonneg fun _ _ => norm_nonneg _) (by norm_num)
  unfold PsiOf
  rw [norm_prod]
  exact hprod r.primeFactors (fun _ h => h)

theorem norm_sq_D_eq_energyOf {ρ : ℕ → ℝ} (hρ : ∀ p, p.Prime → 0 ≤ ρ p ∧ ρ p < 1)
    {B : ℕ} (hB : 1 ≤ B) (X : ℕ) :
    ∫ ω, ‖D B X ω‖ ^ 2 ∂(primeTorusMeasureOf ρ) = energyOf ρ B X := by
  let T := (Finset.Icc 1 X).filter (fun r => Nat.Coprime r B)
  have hD_eq : ∀ ω : ℕ → ℝ, D B X ω = ∑ r ∈ T, (scalarSOf ρ B (X / r) : ℂ) * PsiOf ρ r ω :=
    fun ω => D_eq_sum_PsiOf ρ hB X ω
  have hPsi_pair_int : ∀ r s : ℕ,
      Integrable (fun ω : ℕ → ℝ =>
        ((scalarSOf ρ B (X / r) : ℂ) * PsiOf ρ r ω) *
          starRingEnd ℂ ((scalarSOf ρ B (X / s) : ℂ) * PsiOf ρ s ω)) (primeTorusMeasureOf ρ) := by
    intro r s
    have hc : Continuous (fun ω : ℕ → ℝ =>
        ((scalarSOf ρ B (X / r) : ℂ) * PsiOf ρ r ω) *
          starRingEnd ℂ ((scalarSOf ρ B (X / s) : ℂ) * PsiOf ρ s ω)) :=
      (continuous_const.mul (PsiOf_continuous ρ r)).mul
        (Complex.continuous_conj.comp (continuous_const.mul (PsiOf_continuous ρ s)))
    refine Integrable.of_bound hc.aestronglyMeasurable
      ((|scalarSOf ρ B (X / r)| * (2 : ℝ) ^ r.primeFactors.card) *
        (|scalarSOf ρ B (X / s)| * (2 : ℝ) ^ s.primeFactors.card)) (ae_of_all _ fun ω => ?_)
    rw [norm_mul, RCLike.norm_conj, norm_mul, norm_mul, Complex.norm_real, Complex.norm_real,
      Real.norm_eq_abs, Real.norm_eq_abs]
    exact mul_le_mul
      (mul_le_mul_of_nonneg_left (norm_PsiOf_le hρ r ω) (abs_nonneg _))
      (mul_le_mul_of_nonneg_left (norm_PsiOf_le hρ s ω) (abs_nonneg _))
      (mul_nonneg (abs_nonneg _) (norm_nonneg _))
      (mul_nonneg (abs_nonneg _) (by positivity))
  have hD_cont : Continuous (fun ω : ℕ → ℝ => D B X ω) := by
    simp_rw [hD_eq]
    exact continuous_finsetSum _ fun r _ => continuous_const.mul (PsiOf_continuous ρ r)
  have hD_norm_int : Integrable (fun ω : ℕ → ℝ => ‖D B X ω‖ ^ 2) (primeTorusMeasureOf ρ) := by
    have hD_bound : ∃ C : ℝ, ∀ ω : ℕ → ℝ, ‖D B X ω‖ ^ 2 ≤ C := by
      refine ⟨(∑ r ∈ T, |scalarSOf ρ B (X / r)| * (2 : ℝ) ^ r.primeFactors.card) ^ 2, fun ω => ?_⟩
      have htri : ‖D B X ω‖ ≤ ∑ r ∈ T, |scalarSOf ρ B (X / r)| * (2 : ℝ) ^ r.primeFactors.card := by
        rw [hD_eq ω]
        calc ‖∑ r ∈ T, (scalarSOf ρ B (X / r) : ℂ) * PsiOf ρ r ω‖
            ≤ ∑ r ∈ T, ‖(scalarSOf ρ B (X / r) : ℂ) * PsiOf ρ r ω‖ := norm_sum_le _ _
          _ ≤ ∑ r ∈ T, |scalarSOf ρ B (X / r)| * (2 : ℝ) ^ r.primeFactors.card := by
              refine Finset.sum_le_sum fun r _ => ?_
              rw [norm_mul, Complex.norm_real, Real.norm_eq_abs]
              exact mul_le_mul_of_nonneg_left (norm_PsiOf_le hρ r ω) (abs_nonneg _)
      exact pow_le_pow_left₀ (norm_nonneg _) htri 2
    obtain ⟨C, hC⟩ := hD_bound
    refine Integrable.of_bound ((hD_cont.norm.pow 2).aestronglyMeasurable) C (ae_of_all _ fun ω => ?_)
    simpa [Real.norm_of_nonneg (sq_nonneg ‖D B X ω‖)] using hC ω
  have h_complex :
      ((∫ ω, ‖D B X ω‖ ^ 2 ∂(primeTorusMeasureOf ρ) : ℝ) : ℂ) =
        ∑ r ∈ T, ((jWeightOf ρ r * (scalarSOf ρ B (X / r)) ^ 2 : ℝ) : ℂ) := by
    calc ((∫ ω, ‖D B X ω‖ ^ 2 ∂(primeTorusMeasureOf ρ) : ℝ) : ℂ)
        = ∫ ω, ((‖D B X ω‖ ^ 2 : ℝ) : ℂ) ∂(primeTorusMeasureOf ρ) := by
          simpa using (Complex.ofRealCLM.integral_comp_comm hD_norm_int).symm
      _ = ∫ ω, D B X ω * starRingEnd ℂ (D B X ω) ∂(primeTorusMeasureOf ρ) := by
          congr 1; ext ω; push_cast; exact (Complex.mul_conj' (D B X ω)).symm
      _ = ∫ ω, ∑ r ∈ T, ∑ s ∈ T,
            ((scalarSOf ρ B (X / r) : ℂ) * PsiOf ρ r ω) *
              starRingEnd ℂ ((scalarSOf ρ B (X / s) : ℂ) * PsiOf ρ s ω) ∂(primeTorusMeasureOf ρ) := by
          congr 1; ext ω
          rw [hD_eq ω, map_sum, Finset.sum_mul]
          refine Finset.sum_congr rfl fun r _ => Finset.mul_sum _ _ _
      _ = ∑ r ∈ T, ∫ ω, ∑ s ∈ T,
            ((scalarSOf ρ B (X / r) : ℂ) * PsiOf ρ r ω) *
              starRingEnd ℂ ((scalarSOf ρ B (X / s) : ℂ) * PsiOf ρ s ω) ∂(primeTorusMeasureOf ρ) := by
          refine integral_finsetSum T fun r _ => ?_
          exact integrable_finsetSum T fun s _ => hPsi_pair_int r s
      _ = ∑ r ∈ T, ∑ s ∈ T, ∫ ω,
            ((scalarSOf ρ B (X / r) : ℂ) * PsiOf ρ r ω) *
              starRingEnd ℂ ((scalarSOf ρ B (X / s) : ℂ) * PsiOf ρ s ω) ∂(primeTorusMeasureOf ρ) := by
          refine Finset.sum_congr rfl fun r _ => integral_finsetSum T fun s _ => hPsi_pair_int r s
      _ = ∑ r ∈ T, ∑ s ∈ T,
            ((scalarSOf ρ B (X / r) : ℂ) * (scalarSOf ρ B (X / s) : ℂ)) *
              innerNuOf ρ (PsiOf ρ r) (PsiOf ρ s) := by
          refine Finset.sum_congr rfl fun r _ => Finset.sum_congr rfl fun s _ => ?_
          have heq : (fun ω : ℕ → ℝ =>
              ((scalarSOf ρ B (X / r) : ℂ) * PsiOf ρ r ω) *
                starRingEnd ℂ ((scalarSOf ρ B (X / s) : ℂ) * PsiOf ρ s ω)) =
              fun ω => ((scalarSOf ρ B (X / r) : ℂ) * (scalarSOf ρ B (X / s) : ℂ)) *
                (PsiOf ρ r ω * starRingEnd ℂ (PsiOf ρ s ω)) := by
            ext ω
            simp only [map_mul, Complex.conj_ofReal]
            ring
          rw [heq, integral_const_mul]
          rfl
      _ = ∑ r ∈ T, ((jWeightOf ρ r * (scalarSOf ρ B (X / r)) ^ 2 : ℝ) : ℂ) := by
          refine Finset.sum_congr rfl fun r hr => ?_
          have hr_pos : 0 < r := (Finset.mem_Icc.mp (Finset.mem_filter.mp hr).1).1
          rw [Finset.sum_eq_single r]
          · rw [innerNuOf_PsiOf hρ hr_pos.ne' hr_pos.ne']
            simp only [↓reduceIte]
            push_cast; ring
          · intro s hs hrs
            have hs_pos : 0 < s := (Finset.mem_Icc.mp (Finset.mem_filter.mp hs).1).1
            rw [innerNuOf_PsiOf hρ hr_pos.ne' hs_pos.ne']
            simp only [hrs.symm, ↓reduceIte, mul_zero]
          · intro hr_nmem; exact absurd hr hr_nmem
  rw [← Complex.ofReal_sum] at h_complex
  exact_mod_cast h_complex

/-! ## Exact reduction to CoherentEnergyMeasure v0.1 at ρ_p = 1/p -/

theorem poissonMeasureOf_inv_eq (p : ℕ) :
    poissonMeasureOf (fun q => (q : ℝ)⁻¹) p = poissonMeasure p := by
  by_cases hp : p.Prime
  · have hr0 : 0 ≤ (p : ℝ)⁻¹ := by positivity
    have hr1 : (p : ℝ)⁻¹ < 1 := inv_lt_one_of_one_lt₀ (by exact_mod_cast hp.one_lt)
    have hcond : p.Prime ∧ 0 ≤ (p : ℝ)⁻¹ ∧ (p : ℝ)⁻¹ < 1 := ⟨hp, hr0, hr1⟩
    simp only [poissonMeasureOf, poissonMeasure, hcond, and_self, ↓reduceIte]
    rfl
  · simp [poissonMeasureOf, poissonMeasure, hp]

theorem primeTorusMeasureOf_inv_eq :
    primeTorusMeasureOf (fun q => (q : ℝ)⁻¹) = primeTorusMeasure := by
  unfold primeTorusMeasureOf primeTorusMeasure
  exact congrArg Measure.infinitePi (funext poissonMeasureOf_inv_eq)

theorem PsiOf_inv_eq (r : ℕ) (ω : ℕ → ℝ) :
    PsiOf (fun q => (q : ℝ)⁻¹) r ω = Psi r ω := by
  unfold PsiOf Psi
  refine Finset.prod_congr rfl fun p _ => ?_
  unfold phiLocalOf phiLocal
  split_ifs <;> simp

theorem jWeightOf_inv_eq (r : ℕ) :
    jWeightOf (fun q => (q : ℝ)⁻¹) r = jWeight r := by
  unfold jWeightOf jWeight
  refine Finset.prod_congr rfl fun p _ => ?_
  rw [one_div, inv_pow]

theorem scalarSOf_inv_eq (B n : ℕ) :
    scalarSOf (fun q => (q : ℝ)⁻¹) B n = scalarS B n := by
  unfold scalarSOf scalarS
  refine Finset.sum_congr rfl fun k hk => ?_
  have hk_pos : 0 < k := (Finset.mem_Icc.mp (Finset.mem_filter.mp hk).1).1
  rw [rhoProd_inv_prime hk_pos.ne', div_eq_mul_inv]

theorem energyOf_inv_eq (B X : ℕ) :
    energyOf (fun q => (q : ℝ)⁻¹) B X =
      ∑ r ∈ (Finset.Icc 1 X).filter (fun r => Nat.Coprime r B), jWeight r * (scalarS B (X / r)) ^ 2 := by
  unfold energyOf
  refine Finset.sum_congr rfl fun r _ => ?_
  rw [jWeightOf_inv_eq, scalarSOf_inv_eq]

end RHConnections.CoherentEnergyRadius
