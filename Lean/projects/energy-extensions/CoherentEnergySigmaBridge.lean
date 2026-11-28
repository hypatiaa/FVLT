import Verified
import CoherentEnergyMeasure
import CoherentEnergyRHBridge
import CoherentEnergyRadiusMeasure
import Mathlib.Analysis.PSeries

/-!
# Sigma-radius family, transfer, RH equivalence, and twin zeros

Generalises the coprime inversion and coherent-energy RH equivalence from `σ = 1` (`1/p`)
to the family `ρ_p = p^(-σ)` for every `σ ≥ 1/2` (and `B ≥ 1`), with headline case `σ = 1/2`
(the prime-phasor radius `p^(-1/2)`).

Contents (following `RADIUS_FAMILY_NOTE.md` §§2–3):
1. `rhoSigma σ p = p^(-σ)`, `rhoProd (rhoSigma σ) m = m^(-σ)`, and kernel
   `innerNuOf (rhoSigma σ) (Z d) (Z e) = (gcd(d,e)^2 / (d * e))^σ`.
2. Coprime Dirichlet inverse `gSigma * hSigma = 1`, explicit transfer constant `pSeries (σ + θ)`
   `= (riemannZeta (σ + θ)).re` when `1 < σ + θ` (`θ ≥ 0`), and `M = O(n^θ) ↔ S_σ = O(n^θ)`.
3. Squeeze & RH equivalence `coherent_energy_sigma_measure_growth_iff_RH` for all `σ ≥ 1/2`, `B ≥ 1`,
   and specialization `coherent_energy_half_measure_growth_iff_RH` (`σ = 1/2`), reusing
   `RHConnections.MertensCriterion.mertens_cancellation_iff_RH` / `natural_mertens_bounds_of_RH`.
4. Reduction at `σ = 1` to `RHConnections.CoherentEnergyMeasure`.
5. Twin-chain zero symmetry `zeta_zero_iff_one_sub_add_im` for `0 < σ < 1`.
-/

noncomputable section
open scoped BigOperators
open Filter MeasureTheory ArithmeticFunction Complex

namespace RHConnections.CoherentEnergyRadius

open RHConnections.ArithmeticFourierInversion
open RHConnections.CoherentEnergyBounds
open RHConnections.MertensCriterion
open RHConnections.CoherentEnergyMeasure

/-! ## 1. The σ-radius family ρ_p = p^(-σ) -/

def rhoSigma (σ : ℝ) (p : ℕ) : ℝ :=
  (p : ℝ) ^ (-σ)

theorem rhoSigma_mem_Ico {σ : ℝ} (hσ : 0 < σ) {p : ℕ} (hp : p.Prime) :
    0 ≤ rhoSigma σ p ∧ rhoSigma σ p < 1 := by
  refine ⟨Real.rpow_nonneg (Nat.cast_nonneg p) (-σ), ?_⟩
  have hp1 : (1 : ℝ) < (p : ℝ) := by exact_mod_cast hp.one_lt
  simpa [rhoSigma] using Real.rpow_lt_rpow_of_exponent_lt hp1 (show -σ < 0 by linarith)

theorem rhoProd_rhoSigma (σ : ℝ) {m : ℕ} (hm : m ≠ 0) :
    rhoProd (rhoSigma σ) m = (m : ℝ) ^ (-σ) := by
  unfold rhoProd rhoSigma
  have hm_eq : (m : ℝ) ^ (-σ) =
      (∏ p ∈ m.primeFactors, ((p : ℝ) ^ m.factorization p)) ^ (-σ) := by
    have h := congr_arg (fun k : ℕ => ((k : ℝ) ^ (-σ))) (Nat.prod_primeFactors_pow_factorization hm)
    simp only [Nat.cast_prod, Nat.cast_pow] at h
    exact h
  rw [hm_eq]
  have hprod_rpow :
      (∏ p ∈ m.primeFactors, ((p : ℝ) ^ m.factorization p)) ^ (-σ) =
        ∏ p ∈ m.primeFactors, (((p : ℝ) ^ m.factorization p) ^ (-σ)) := by
    induction m.primeFactors using Finset.cons_induction with
    | empty => simp
    | cons p s hp ih =>
      simp only [Finset.prod_cons]
      rw [Real.mul_rpow (pow_nonneg (Nat.cast_nonneg p) _)
        (Finset.prod_nonneg fun q _ => pow_nonneg (Nat.cast_nonneg q) _), ih]
  rw [hprod_rpow]
  refine Finset.prod_congr rfl fun p _ => ?_
  rw [← Real.rpow_natCast (p : ℝ), ← Real.rpow_mul (Nat.cast_nonneg p),
    ← Real.rpow_natCast ((p : ℝ) ^ (-σ)), ← Real.rpow_mul (Nat.cast_nonneg p), mul_comm (-σ)]

theorem innerNuOf_Z_sigma {σ : ℝ} (hσ : 0 < σ) {d e : ℕ} (hd : d ≠ 0) (he : e ≠ 0) :
    innerNuOf (rhoSigma σ) (Z d) (Z e) =
      ((((Nat.gcd d e : ℝ) ^ 2 / ((d : ℝ) * (e : ℝ))) ^ σ : ℝ) : ℂ) := by
  rw [innerNuOf_Z (fun p hp => rhoSigma_mem_Ico hσ hp) hd he]
  let S : Finset ℕ := (d * e).primeFactors
  have hS_primes : ∀ p ∈ S, p.Prime := fun p hp => Nat.prime_of_mem_primeFactors hp
  have hd_sub : d.primeFactors ⊆ S := by
    rw [show S = d.primeFactors ∪ e.primeFactors from Nat.primeFactors_mul hd he]
    exact Finset.subset_union_left
  have he_sub : e.primeFactors ⊆ S := by
    rw [show S = d.primeFactors ∪ e.primeFactors from Nat.primeFactors_mul hd he]
    exact Finset.subset_union_right
  have hgcd0 : Nat.gcd d e ≠ 0 := Nat.gcd_ne_zero_left hd
  have hgcd_sub : (Nat.gcd d e).primeFactors ⊆ S := by
    intro p hp
    exact hd_sub (Nat.mem_primeFactors.mpr
      ⟨Nat.prime_of_mem_primeFactors hp,
        (Nat.dvd_of_mem_primeFactors hp).trans (Nat.gcd_dvd_left d e), hd⟩)
  have hprod_real :
      ∏ p ∈ S, rhoSigma σ p ^ ((d.factorization p : ℤ) - (e.factorization p : ℤ)).natAbs =
        ((Nat.gcd d e : ℝ) ^ 2 / ((d : ℝ) * (e : ℝ))) ^ σ := by
    have hd_pos : 0 < (d : ℝ) := Nat.cast_pos.mpr (Nat.pos_of_ne_zero hd)
    have he_pos : 0 < (e : ℝ) := Nat.cast_pos.mpr (Nat.pos_of_ne_zero he)
    have hde_pos : 0 < (d : ℝ) * (e : ℝ) := mul_pos hd_pos he_pos
    have hde_rpow_pos : 0 < ((d : ℝ) * (e : ℝ)) ^ σ := Real.rpow_pos_of_pos hde_pos σ
    rw [Real.div_rpow (sq_nonneg _) hde_pos.le, eq_div_iff hde_rpow_pos.ne']
    have hd_prod : (d : ℝ) = ∏ p ∈ S, (p : ℝ) ^ d.factorization p := by
      have h := congr_arg (Nat.cast : ℕ → ℝ) (Nat.prod_primeFactors_pow_factorization hd)
      simp only [Nat.cast_prod, Nat.cast_pow] at h
      rw [h]
      refine Finset.prod_subset hd_sub fun p _ hp => ?_
      have hz : d.factorization p = 0 :=
        Finsupp.notMem_support_iff.mp (by simpa [Nat.support_factorization] using hp)
      simp [hz]
    have he_prod : (e : ℝ) = ∏ p ∈ S, (p : ℝ) ^ e.factorization p := by
      have h := congr_arg (Nat.cast : ℕ → ℝ) (Nat.prod_primeFactors_pow_factorization he)
      simp only [Nat.cast_prod, Nat.cast_pow] at h
      rw [h]
      refine Finset.prod_subset he_sub fun p _ hp => ?_
      have hz : e.factorization p = 0 :=
        Finsupp.notMem_support_iff.mp (by simpa [Nat.support_factorization] using hp)
      simp [hz]
    have hgcd_prod : (Nat.gcd d e : ℝ) ^ 2 =
        ∏ p ∈ S, (p : ℝ) ^ (2 * min (d.factorization p) (e.factorization p)) := by
      have h := congr_arg (fun k : ℕ => (k : ℝ) ^ 2) (Nat.prod_primeFactors_pow_factorization hgcd0)
      simp only [Nat.cast_prod, ← Finset.prod_pow, Nat.cast_pow] at h
      rw [h]
      have hsub_eq : ∏ p ∈ (Nat.gcd d e).primeFactors, ((p : ℝ) ^ (Nat.gcd d e).factorization p) ^ 2 =
          ∏ p ∈ S, ((p : ℝ) ^ (Nat.gcd d e).factorization p) ^ 2 := by
        refine Finset.prod_subset hgcd_sub fun p _ hp => ?_
        have hz : (Nat.gcd d e).factorization p = 0 :=
          Finsupp.notMem_support_iff.mp (by simpa [Nat.support_factorization] using hp)
        simp [hz]
      rw [hsub_eq]
      refine Finset.prod_congr rfl fun p _ => ?_
      rw [Nat.factorization_gcd hd he, Finsupp.inf_apply, ← pow_mul, mul_comm]
    have hprod_pow : ∀ (f : ℕ → ℕ),
        (∏ p ∈ S, (p : ℝ) ^ f p) ^ σ = ∏ p ∈ S, (p : ℝ) ^ ((f p : ℝ) * σ) := by
      intro f
      have h1 : (∏ p ∈ S, (p : ℝ) ^ f p) ^ σ = ∏ p ∈ S, ((p : ℝ) ^ f p) ^ σ := by
        induction S using Finset.cons_induction with
        | empty => simp
        | cons p T hp ih =>
          simp only [Finset.prod_cons]
          rw [Real.mul_rpow (pow_nonneg (Nat.cast_nonneg p) _)
            (Finset.prod_nonneg fun q _ => pow_nonneg (Nat.cast_nonneg q) _), ih]
      rw [h1]
      refine Finset.prod_congr rfl fun p _ => ?_
      rw [← Real.rpow_natCast (p : ℝ), ← Real.rpow_mul (Nat.cast_nonneg p)]
    have hde_rpow : ((d : ℝ) * (e : ℝ)) ^ σ =
        ∏ p ∈ S, (p : ℝ) ^ (((d.factorization p + e.factorization p : ℕ) : ℝ) * σ) := by
      rw [hd_prod, he_prod, ← Finset.prod_mul_distrib]
      conv_lhs =>
        arg 1; arg 2; ext p
        rw [← pow_add]
      exact hprod_pow (fun p => d.factorization p + e.factorization p)
    have hgcd_rpow : ((Nat.gcd d e : ℝ) ^ 2) ^ σ =
        ∏ p ∈ S, (p : ℝ) ^ (((2 * min (d.factorization p) (e.factorization p) : ℕ) : ℝ) * σ) := by
      rw [hgcd_prod]
      exact hprod_pow (fun p => 2 * min (d.factorization p) (e.factorization p))
    rw [hde_rpow, hgcd_rpow, ← Finset.prod_mul_distrib]
    refine Finset.prod_congr rfl fun p hp => ?_
    have hp_pos : 0 < (p : ℝ) := Nat.cast_pos.mpr (hS_primes p hp).pos
    have hexp : (((d.factorization p : ℤ) - (e.factorization p : ℤ)).natAbs : ℕ) +
        2 * min (d.factorization p) (e.factorization p) =
          d.factorization p + e.factorization p := by
      omega
    unfold rhoSigma
    rw [← Real.rpow_natCast ((p : ℝ) ^ (-σ)), ← Real.rpow_mul hp_pos.le,
      ← Real.rpow_add hp_pos]
    congr 1
    have hexpR : ((((d.factorization p : ℤ) - (e.factorization p : ℤ)).natAbs : ℝ) +
        ((2 * min (d.factorization p) (e.factorization p) : ℕ) : ℝ)) =
        ((d.factorization p + e.factorization p : ℕ) : ℝ) := by
      exact_mod_cast hexp
    have hmul := congrArg (fun x : ℝ => x * σ) hexpR
    rw [add_mul] at hmul
    linarith [show -σ * (((d.factorization p : ℤ) - (e.factorization p : ℤ)).natAbs : ℝ) =
      -((((d.factorization p : ℤ) - (e.factorization p : ℤ)).natAbs : ℝ) * σ) by ring]
  have hcast :
      (∏ p ∈ S, (rhoSigma σ p : ℂ) ^ ((d.factorization p : ℤ) - (e.factorization p : ℤ)).natAbs) =
        ((∏ p ∈ S, rhoSigma σ p ^ ((d.factorization p : ℤ) - (e.factorization p : ℤ)).natAbs : ℝ) : ℂ) := by
    simp only [← Complex.ofReal_pow, ← Complex.ofReal_prod]
  rw [hcast, hprod_real]

/-! ## 2. Coprime Dirichlet inverse g_σ * h_σ = 1 and explicit transfer -/

def gSigma (σ : ℝ) (B : ℕ) : ArithmeticFunction ℝ :=
  ⟨fun k => if k = 0 then 0 else if k.Coprime B then (k : ℝ) ^ (-σ) else 0, by simp⟩

theorem gSigma_apply (σ : ℝ) (B k : ℕ) :
    gSigma σ B k = if k = 0 then 0 else if k.Coprime B then (k : ℝ) ^ (-σ) else 0 := rfl

theorem gSigma_mul (σ : ℝ) (B j k : ℕ) :
    gSigma σ B (j * k) = gSigma σ B j * gSigma σ B k := by
  by_cases hj0 : j = 0
  · subst hj0; simp [gSigma_apply]
  · by_cases hk0 : k = 0
    · subst hk0; simp [gSigma_apply]
    · have hjk0 : j * k ≠ 0 := mul_ne_zero hj0 hk0
      simp only [gSigma_apply, hj0, hk0, hjk0, ↓reduceIte, Nat.coprime_mul_iff_left, Nat.cast_mul]
      by_cases hj : j.Coprime B <;> by_cases hk : k.Coprime B
      · rw [ite_eq_left ⟨hj, hk⟩, ite_eq_left hj, ite_eq_left hk]
        exact Real.mul_rpow (Nat.cast_nonneg j) (Nat.cast_nonneg k)
      · rw [ite_eq_right (fun h => hk h.2), ite_eq_left hj, ite_eq_right hk, mul_zero]
      · rw [ite_eq_right (fun h => hj h.1), ite_eq_right hj, zero_mul]
      · rw [ite_eq_right (fun h => hj h.1), ite_eq_right hj, zero_mul]

def hSigma (σ : ℝ) (B : ℕ) : ArithmeticFunction ℝ :=
  (gSigma σ B).pmul muR

theorem hSigma_apply (σ : ℝ) (B k : ℕ) :
    hSigma σ B k =
      if k = 0 then 0
      else if k.Coprime B then (ArithmeticFunction.moebius k : ℝ) * (k : ℝ) ^ (-σ)
      else 0 := by
  simp only [hSigma, ArithmeticFunction.pmul_apply, gSigma_apply, muR]
  by_cases hk0 : k = 0
  · subst hk0; simp
  · by_cases hk : k.Coprime B <;> simp [hk0, hk, mul_comm]

theorem twist_convolution_sigma (σ : ℝ) (B : ℕ) (u v : ArithmeticFunction ℝ) :
    (gSigma σ B).pmul u * (gSigma σ B).pmul v = (gSigma σ B).pmul (u * v) := by
  ext n
  simp only [ArithmeticFunction.pmul_apply, ArithmeticFunction.mul_apply, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro p hp
  have he : p.1 * p.2 = n := (Nat.mem_divisorsAntidiagonal.mp hp).1
  rw [← he, gSigma_mul]
  ring

theorem gSigma_convolution_hSigma (σ : ℝ) (B : ℕ) :
    gSigma σ B * hSigma σ B = 1 := by
  have he := twist_convolution_sigma σ B (↑ArithmeticFunction.zeta : ArithmeticFunction ℝ) muR
  rw [ArithmeticFunction.pmul_zeta,
    show (↑ArithmeticFunction.zeta : ArithmeticFunction ℝ) * muR = 1 from
      ArithmeticFunction.coe_zeta_mul_coe_moebius] at he
  rw [hSigma, he]
  ext n
  by_cases hn : n = 1
  · subst n
    simp [ArithmeticFunction.pmul_apply, gSigma_apply]
  · simp [ArithmeticFunction.pmul_apply, hn]

def SSigma (σ : ℝ) (B n : ℕ) : ℝ :=
  ∑ j ∈ Finset.Ioc 0 n, (gSigma σ B * muR) j

theorem SSigma_from_M (σ : ℝ) (B n : ℕ) :
    SSigma σ B n = ∑ k ∈ Finset.Ioc 0 n, gSigma σ B k * M (n / k) :=
  ArithmeticFunction.sum_Ioc_mul_eq_sum_sum (gSigma σ B) muR n

theorem M_from_SSigma (σ : ℝ) (B n : ℕ) :
    M n = ∑ k ∈ Finset.Ioc 0 n, hSigma σ B k * SSigma σ B (n / k) := by
  have hi : hSigma σ B * (gSigma σ B * muR) = muR := by
    rw [← mul_assoc, mul_comm (hSigma σ B) (gSigma σ B), gSigma_convolution_hSigma, one_mul]
  calc
    M n = ∑ j ∈ Finset.Ioc 0 n, (hSigma σ B * (gSigma σ B * muR)) j := by rw [hi]; rfl
    _ = _ := ArithmeticFunction.sum_Ioc_mul_eq_sum_sum (hSigma σ B) (gSigma σ B * muR) n

theorem SSigma_eq_scalarSOf (σ : ℝ) (B n : ℕ) :
    SSigma σ B n = scalarSOf (rhoSigma σ) B n := by
  rw [SSigma_from_M]
  unfold scalarSOf
  have heq : Finset.Icc 1 n = Finset.Ioc 0 n := by
    ext k; simp only [Finset.mem_Icc, Finset.mem_Ioc]; omega
  rw [heq, Finset.sum_filter]
  refine Finset.sum_congr rfl fun k hk => ?_
  have hk_pos : 0 < k := (Finset.mem_Ioc.mp hk).1
  rw [gSigma_apply, ite_eq_right hk_pos.ne', rhoProd_rhoSigma σ hk_pos.ne', mertens_eq_M]
  split_ifs <;> ring

/-! ## Explicit transfer with ζ(σ + θ) constant -/

theorem pSeries_eq_re_riemannZeta {p : ℝ} (hp : 1 < p) :
    pSeries p = (riemannZeta (p : ℂ)).re := by
  unfold pSeries
  have hz : riemannZeta (p : ℂ) = ∑' r : ℕ, 1 / (r : ℂ) ^ (p : ℂ) :=
    zeta_eq_tsum_one_div_nat_cpow (by simpa using hp)
  have hc : ((∑' r : ℕ, 1 / (r : ℝ) ^ p : ℝ) : ℂ) = ∑' r : ℕ, 1 / (r : ℂ) ^ (p : ℂ) := by
    rw [Complex.ofReal_tsum]
    refine tsum_congr fun r => ?_
    rw [Complex.ofReal_div, Complex.ofReal_one, Complex.ofReal_cpow (Nat.cast_nonneg r),
      Complex.ofReal_natCast]
  rw [← hz] at hc
  simpa using congr_arg Complex.re hc

theorem abs_gSigma_le (σ : ℝ) (B : ℕ) {k : ℕ} (hk : 1 ≤ k) :
    |gSigma σ B k| ≤ 1 / (k : ℝ) ^ σ := by
  have hk0 : k ≠ 0 := by omega
  rw [gSigma_apply, ite_eq_right hk0]
  have hnonneg : 0 ≤ (k : ℝ) ^ (-σ) := Real.rpow_nonneg (Nat.cast_nonneg k) (-σ)
  split_ifs
  · rw [abs_of_nonneg hnonneg, Real.rpow_neg (Nat.cast_nonneg k), one_div]
  · rw [abs_zero]
    positivity

theorem abs_hSigma_le (σ : ℝ) (B : ℕ) {k : ℕ} (hk : 1 ≤ k) :
    |hSigma σ B k| ≤ 1 / (k : ℝ) ^ σ := by
  have hk0 : k ≠ 0 := by omega
  rw [hSigma_apply, ite_eq_right hk0]
  split_ifs
  · rw [abs_mul, Real.rpow_neg (Nat.cast_nonneg k), one_div,
      abs_of_nonneg (inv_nonneg.mpr (Real.rpow_nonneg (Nat.cast_nonneg k) σ))]
    have hμ : |(ArithmeticFunction.moebius k : ℝ)| ≤ 1 := by
      exact_mod_cast (ArithmeticFunction.abs_moebius_le_one (n := k))
    simpa using mul_le_mul_of_nonneg_right hμ (inv_nonneg.mpr (Real.rpow_nonneg (Nat.cast_nonneg k) σ))
  · simp; positivity

theorem quotient_sum_explicit_bound_sigma {F G w : ℕ → ℝ} {σ θ A : ℝ}
    (hθ : 0 ≤ θ) (hsum_gt : 1 < σ + θ) (hA : 0 ≤ A)
    (hw : ∀ k : ℕ, 1 ≤ k → |w k| ≤ 1 / (k : ℝ) ^ σ)
    (hG : ∀ n, G n = ∑ k ∈ Finset.Ioc 0 n, w k * F (n / k))
    (hF : ∀ m : ℕ, 1 ≤ m → |F m| ≤ A * (m : ℝ) ^ θ) :
    ∀ n : ℕ, 1 ≤ n → |G n| ≤ (A * pSeries (σ + θ)) * (n : ℝ) ^ θ := by
  let p (k : ℕ) := 1 / (k : ℝ) ^ (σ + θ)
  have hp : Summable p := Real.summable_one_div_nat_rpow.mpr hsum_gt
  intro n _
  have hterm (k : ℕ) (hk : k ∈ Finset.Ioc 0 n) :
      |w k * F (n / k)| ≤ (A * (n : ℝ) ^ θ) * p k := by
    have hi := Finset.mem_Ioc.mp hk
    have hk1 : 1 ≤ k := hi.1
    have hk' : 0 < (k : ℝ) := Nat.cast_pos.mpr hk1
    have hq : |F (n / k)| ≤ A * ((n : ℝ) / (k : ℝ)) ^ θ :=
      (hF _ (Nat.div_pos hi.2 hk1)).trans
        (mul_le_mul_of_nonneg_left
          (Real.rpow_le_rpow (Nat.cast_nonneg _) Nat.cast_div_le hθ) hA)
    rw [abs_mul]
    calc
      _ ≤ (1 / (k : ℝ) ^ σ) * (A * ((n : ℝ) / (k : ℝ)) ^ θ) :=
        mul_le_mul (hw k hk1) hq (abs_nonneg _) (by positivity)
      _ = _ := by
        dsimp only [p]
        rw [Real.div_rpow (Nat.cast_nonneg n) hk'.le, Real.rpow_add hk']
        simp only [div_eq_mul_inv, _root_.mul_inv_rev]
        ring
  rw [hG n]
  calc
    _ ≤ ∑ k ∈ Finset.Ioc 0 n, |w k * F (n / k)| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ k ∈ Finset.Ioc 0 n, (A * (n : ℝ) ^ θ) * p k := Finset.sum_le_sum hterm
    _ = (A * (n : ℝ) ^ θ) * ∑ k ∈ Finset.Ioc 0 n, p k := (Finset.mul_sum ..).symm
    _ ≤ (A * (n : ℝ) ^ θ) * ∑' k, p k := mul_le_mul_of_nonneg_left
      (hp.sum_le_tsum _ (fun k _ => by dsimp [p]; positivity)) (by positivity)
    _ = (A * pSeries (σ + θ)) * (n : ℝ) ^ θ := by
      unfold pSeries; ring

theorem M_power_bound_iff_SSigma (σ : ℝ) (B : ℕ) {θ : ℝ}
    (hθ : 0 ≤ θ) (hsum_gt : 1 < σ + θ) :
    NaturalPowerBound M θ ↔ NaturalPowerBound (SSigma σ B) θ := by
  constructor
  · rintro ⟨A, hA, hM⟩
    refine ⟨A * pSeries (σ + θ), mul_nonneg hA (tsum_nonneg fun _ => by positivity), ?_⟩
    exact quotient_sum_explicit_bound_sigma hθ hsum_gt hA (fun k hk => abs_gSigma_le σ B hk)
      (SSigma_from_M σ B) hM
  · rintro ⟨A, hA, hS⟩
    refine ⟨A * pSeries (σ + θ), mul_nonneg hA (tsum_nonneg fun _ => by positivity), ?_⟩
    exact quotient_sum_explicit_bound_sigma hθ hsum_gt hA (fun k hk => abs_hSigma_le σ B hk)
      (M_from_SSigma σ B) hS

theorem M_all_epsilon_iff_SSigma {σ : ℝ} (hσ : 1 / 2 ≤ σ) (B : ℕ) :
    (∀ ε : ℝ, 0 < ε → ∃ C : ℝ, 0 ≤ C ∧ ∀ n : ℕ, 1 ≤ n →
      |M n| ≤ C * (n : ℝ) ^ (1 / 2 + ε)) ↔
    (∀ ε : ℝ, 0 < ε → ∃ C : ℝ, 0 ≤ C ∧ ∀ n : ℕ, 1 ≤ n →
      |SSigma σ B n| ≤ C * (n : ℝ) ^ (1 / 2 + ε)) := by
  constructor
  · intro h ε hε
    exact (M_power_bound_iff_SSigma σ B (by linarith) (by linarith)).mp (h ε hε)
  · intro h ε hε
    exact (M_power_bound_iff_SSigma σ B (by linarith) (by linarith)).mpr (h ε hε)

/-! ## 3. Squeeze and RH equivalence for general σ ≥ 1/2 -/

theorem scalar_sq_le_energyOf {ρ : ℕ → ℝ} (hρ : ∀ p, p.Prime → 0 ≤ ρ p ∧ ρ p ≤ 1)
    (B X : ℕ) (hX : 1 ≤ X) :
    scalarSOf ρ B X ^ 2 ≤ energyOf ρ B X := by
  have hm : 1 ∈ (Finset.Icc 1 X).filter (fun r => Nat.Coprime r B) := by
    simp [hX]
  simpa only [jWeightOf_one, Nat.div_one, one_mul, energyOf] using
    (Finset.single_le_sum (f := fun r => jWeightOf ρ r * scalarSOf ρ B (X / r) ^ 2)
      (fun r _ => mul_nonneg (jWeightOf_nonneg hρ r) (sq_nonneg _)) hm)

private lemma sq_rpow_of_nonneg (x : ℝ) (hx : 0 ≤ x) (t : ℝ) :
    (x ^ t) ^ 2 = x ^ (2 * t) := by
  calc (x ^ t) ^ 2 = (x ^ t) ^ (2 : ℝ) := by norm_num
    _ = x ^ (2 * t) := by rw [← Real.rpow_mul hx, mul_comm t]

theorem energyOf_upper {ρ : ℕ → ℝ} (hρ : ∀ p, p.Prime → 0 ≤ ρ p ∧ ρ p ≤ 1)
    (B X : ℕ) {A θ : ℝ} (hA : 0 ≤ A) (hθ : 1 / 2 < θ)
    (hS : ∀ k : ℕ, 1 ≤ k → |scalarSOf ρ B k| ≤ A * (k : ℝ) ^ θ) :
    energyOf ρ B X ≤ A ^ 2 * pSeries (2 * θ) * (X : ℝ) ^ (2 * θ) := by
  let T := (Finset.Icc 1 X).filter fun r => Nat.Coprime r B
  have hp : Summable (fun r : ℕ => 1 / (r : ℝ) ^ (2 * θ)) :=
    Real.summable_one_div_nat_rpow.mpr (by linarith)
  have hterm (r : ℕ) (hr : r ∈ T) :
      jWeightOf ρ r * scalarSOf ρ B (X / r) ^ 2 ≤ (A ^ 2 * (X : ℝ) ^ (2 * θ)) * (1 / (r : ℝ) ^ (2 * θ)) := by
    have hi := Finset.mem_Icc.mp (Finset.mem_filter.mp hr).1
    have hr' : 0 < (r : ℝ) := by exact_mod_cast (show 0 < r by omega)
    have hnat : ((X / r : ℕ) : ℝ) ≤ (X : ℝ) / (r : ℝ) := by
      apply (le_div_iff₀ hr').mpr
      exact_mod_cast Nat.div_mul_le_self X r
    have harg : |scalarSOf ρ B (X / r)| ≤ A * ((X : ℝ) / (r : ℝ)) ^ θ :=
      (hS _ (Nat.div_pos hi.2 (by omega))).trans <|
        mul_le_mul_of_nonneg_left (Real.rpow_le_rpow (Nat.cast_nonneg _) hnat (by linarith)) hA
    have hsquare := pow_le_pow_left₀ (abs_nonneg _) harg 2
    calc
      jWeightOf ρ r * scalarSOf ρ B (X / r) ^ 2 ≤ scalarSOf ρ B (X / r) ^ 2 := by
        simpa only [one_mul] using
          mul_le_mul_of_nonneg_right (jWeightOf_le_one hρ r) (sq_nonneg (scalarSOf ρ B (X / r)))
      _ ≤ (A * ((X : ℝ) / (r : ℝ)) ^ θ) ^ 2 := by simpa only [sq_abs] using hsquare
      _ = _ := by
        rw [mul_pow, sq_rpow_of_nonneg _ (div_nonneg (Nat.cast_nonneg X) hr'.le),
          Real.div_rpow (Nat.cast_nonneg X) hr'.le]
        ring
  calc
    energyOf ρ B X ≤ ∑ r ∈ T, (A ^ 2 * (X : ℝ) ^ (2 * θ)) * (1 / (r : ℝ) ^ (2 * θ)) := Finset.sum_le_sum hterm
    _ = (A ^ 2 * (X : ℝ) ^ (2 * θ)) * ∑ r ∈ T, 1 / (r : ℝ) ^ (2 * θ) := by rw [Finset.mul_sum]
    _ ≤ (A ^ 2 * (X : ℝ) ^ (2 * θ)) * pSeries (2 * θ) := by
      apply mul_le_mul_of_nonneg_left _ (by positivity)
      exact hp.sum_le_tsum T (fun _ _ => by positivity)
    _ = _ := by ring

theorem all_epsilon_iff_energyOf {ρ : ℕ → ℝ} (hρ : ∀ p, p.Prime → 0 ≤ ρ p ∧ ρ p ≤ 1)
    (B : ℕ) :
    (∀ ε : ℝ, 0 < ε → ∃ A : ℝ, 0 ≤ A ∧
      ∀ X : ℕ, 1 ≤ X → |scalarSOf ρ B X| ≤ A * (X : ℝ) ^ (1 / 2 + ε)) ↔
    (∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
      ∀ X : ℕ, 1 ≤ X → energyOf ρ B X ≤ C * (X : ℝ) ^ (1 + δ)) := by
  constructor
  · intro h δ hδ
    obtain ⟨A, hA, hS⟩ := h (δ / 2) (by positivity)
    have he : 2 * (1 / 2 + δ / 2) = 1 + δ := by ring
    refine ⟨A ^ 2 * pSeries (1 + δ), mul_nonneg (sq_nonneg _) (tsum_nonneg fun _ => by positivity), ?_⟩
    intro X _
    simpa only [he] using energyOf_upper hρ B X hA (show 1 / 2 < 1 / 2 + δ / 2 by linarith) hS
  · intro h ε hε
    obtain ⟨C, hC, hE⟩ := h (2 * ε) (by positivity)
    refine ⟨Real.sqrt C, Real.sqrt_nonneg C, ?_⟩
    intro X hX
    have hb := (scalar_sq_le_energyOf hρ B X hX).trans (hE X hX)
    have ht : (Real.sqrt C * (X : ℝ) ^ (1 / 2 + ε)) ^ 2 = C * (X : ℝ) ^ (1 + 2 * ε) := by
      rw [mul_pow, Real.sq_sqrt hC, sq_rpow_of_nonneg _ (Nat.cast_nonneg X), show 2 * (1 / 2 + ε) = 1 + 2 * ε by ring]
    apply (sq_le_sq₀ (abs_nonneg _) (by positivity)).mp
    rw [sq_abs, ht]; exact hb

theorem coherent_energy_sigma_growth_iff_RH {σ : ℝ} (hσ : 1 / 2 ≤ σ) (B : ℕ) :
    (∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
      ∀ X : ℕ, 1 ≤ X → energyOf (rhoSigma σ) B X ≤ C * (X : ℝ) ^ (1 + δ)) ↔
    RiemannHypothesis := by
  have hσ_pos : 0 < σ := by linarith
  have hρ_le : ∀ p, p.Prime → 0 ≤ rhoSigma σ p ∧ rhoSigma σ p ≤ 1 := fun p hp =>
    ⟨(rhoSigma_mem_Ico hσ_pos hp).1, (rhoSigma_mem_Ico hσ_pos hp).2.le⟩
  have h_chain :
      (∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
        ∀ X : ℕ, 1 ≤ X → energyOf (rhoSigma σ) B X ≤ C * (X : ℝ) ^ (1 + δ)) ↔
      (∀ ε : ℝ, 0 < ε → ∃ C : ℝ, 0 ≤ C ∧
        ∀ n : ℕ, 1 ≤ n → |M n| ≤ C * (n : ℝ) ^ (1 / 2 + ε)) := by
    rw [← all_epsilon_iff_energyOf hρ_le B]
    simp_rw [← SSigma_eq_scalarSOf]
    exact (M_all_epsilon_iff_SSigma hσ B).symm
  rw [h_chain]
  exact ⟨fun h => riemannHypothesis_of_mertens (mertensCancellation_of_natural_power_bounds h),
    fun h => natural_mertens_bounds_of_RH h⟩

theorem coherent_energy_sigma_measure_growth_iff_RH {σ : ℝ} (hσ : 1 / 2 ≤ σ)
    {B : ℕ} (hB : 1 ≤ B) :
    (∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
      ∀ X : ℕ, 1 ≤ X →
        ∫ ω, ‖D B X ω‖ ^ 2 ∂(primeTorusMeasureOf (rhoSigma σ)) ≤ C * (X : ℝ) ^ (1 + δ)) ↔
      RiemannHypothesis := by
  have hσ_pos : 0 < σ := by linarith
  simp_rw [norm_sq_D_eq_energyOf (fun p hp => rhoSigma_mem_Ico hσ_pos hp) hB]
  exact coherent_energy_sigma_growth_iff_RH hσ B

/-- Headline case `σ = 1/2`: the prime-phasor radius `p^(-1/2)`. -/
theorem coherent_energy_half_measure_growth_iff_RH {B : ℕ} (hB : 1 ≤ B) :
    (∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
      ∀ X : ℕ, 1 ≤ X →
        ∫ ω, ‖D B X ω‖ ^ 2 ∂(primeTorusMeasureOf (rhoSigma (1 / 2))) ≤ C * (X : ℝ) ^ (1 + δ)) ↔
      RiemannHypothesis :=
  coherent_energy_sigma_measure_growth_iff_RH (le_refl (1 / 2 : ℝ)) hB

theorem rhoSigma_one_eq_inv : rhoSigma 1 = fun p : ℕ => (p : ℝ)⁻¹ := by
  ext p
  simp [rhoSigma, Real.rpow_neg_one]

theorem coherent_energy_sigma_one_eq_v01 {B : ℕ} (hB : 1 ≤ B) (X : ℕ) :
    ∫ ω, ‖D B X ω‖ ^ 2 ∂(primeTorusMeasureOf (rhoSigma 1)) =
      RHConnections.CoherentEnergyBounds.energy
        (RHConnections.ArithmeticFourierInversion.S B) B X := by
  rw [rhoSigma_one_eq_inv, primeTorusMeasureOf_inv_eq]
  exact RHConnections.CoherentEnergyMeasure.norm_sq_D_eq_coherent_energy hB X

/-! ## 4. Twin-chain remark (RADIUS_FAMILY_NOTE.md §3) -/

/-- Functional equation + conjugation symmetry: in the critical strip `0 < σ < 1`,
`ζ(σ + it) = 0 ↔ ζ((1 - σ) + it) = 0`. -/
theorem zeta_zero_iff_one_sub_add_im {σ : ℝ} (hσ0 : 0 < σ) (hσ1 : σ < 1) (t : ℝ) :
    riemannZeta (⟨σ, t⟩ : ℂ) = 0 ↔ riemannZeta (⟨1 - σ, t⟩ : ℂ) = 0 := by
  let z : ℂ := ⟨σ, t⟩
  let w : ℂ := ⟨1 - σ, t⟩
  have hz_re : 0 < z.re := hσ0
  have h1mz_re : 0 < (1 - z).re := by simp [z]; linarith
  have hz_ne : z ≠ 0 := fun h => by have := congr_arg Complex.re h; simp [z] at this; linarith
  have h1mz_ne : 1 - z ≠ 0 := fun h => by
    have := congr_arg Complex.re h; simp [z] at this; linarith
  have hGamma_z : z.Gammaℝ ≠ 0 := Complex.Gammaℝ_ne_zero_of_re_pos hz_re
  have hGamma_1mz : (1 - z).Gammaℝ ≠ 0 := Complex.Gammaℝ_ne_zero_of_re_pos h1mz_re
  have hconj_w : starRingEnd ℂ w = 1 - z := by
    apply Complex.ext <;> simp [w, z]
  calc riemannZeta z = 0
      ↔ completedRiemannZeta z / z.Gammaℝ = 0 := by rw [riemannZeta_def_of_ne_zero hz_ne]
    _ ↔ completedRiemannZeta z = 0 := by simp [div_eq_zero_iff, hGamma_z]
    _ ↔ completedRiemannZeta (1 - z) = 0 := by rw [← completedRiemannZeta_one_sub z]
    _ ↔ completedRiemannZeta (1 - z) / (1 - z).Gammaℝ = 0 := by simp [div_eq_zero_iff, hGamma_1mz]
    _ ↔ riemannZeta (1 - z) = 0 := by rw [riemannZeta_def_of_ne_zero h1mz_ne]
    _ ↔ riemannZeta (starRingEnd ℂ w) = 0 := by rw [hconj_w]
    _ ↔ starRingEnd ℂ (riemannZeta w) = 0 := by rw [riemannZeta_conj]
    _ ↔ riemannZeta w = 0 := map_eq_zero (starRingEnd ℂ)

end RHConnections.CoherentEnergyRadius
