import Mathlib.Analysis.MellinTransform
import Mathlib.Analysis.SpecialFunctions.ImproperIntegrals
import Mathlib.Data.Nat.Periodic
import Mathlib.NumberTheory.DirichletCharacter.Bounds
import Mathlib.NumberTheory.LSeries.DirichletContinuation
import Mathlib.NumberTheory.LSeries.SumCoeff
import Mathlib.Tactic

/-! # Polynomial growth of Dirichlet L-functions by partial summation

C2 of the all-characters converse, 27 November 2026. A character's partial
sum is its period mean times the real cutoff plus a bounded error. Splitting
the Abel integral gives an analytic correction and an explicit pole term.
On the specified strip this yields the exponent one for every character.
-/

noncomputable section

/-! The sum of a Dirichlet character over each complete period has the same
value. Subtracting its period mean times the length leaves a periodic function
at integer endpoints and a bounded remainder at real endpoints. -/


namespace Ratioque.CrystalBridge

private def charPrefix {N : ℕ} (χ : DirichletCharacter ℂ N) (n : ℕ) : ℂ :=
  ∑ k ∈ Finset.Icc 1 n, χ (k : ZMod N)

/-- The average of the character over one full period, including its zero values. -/
def periodMean {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N) : ℂ :=
  (∑ k ∈ Finset.Icc 1 N, χ (k : ZMod N)) / (N : ℂ)

private lemma charPrefix_succ {N : ℕ} (χ : DirichletCharacter ℂ N) (n : ℕ) :
    charPrefix χ (n + 1) = charPrefix χ n + χ ((n + 1 : ℕ) : ZMod N) := by
  have hs : Finset.Icc 1 (n + 1) = insert (n + 1) (Finset.Icc 1 n) := by
    ext k
    simp only [Finset.mem_insert, Finset.mem_Icc]
    omega
  simp [charPrefix, hs, add_comm]

private lemma charPrefix_add_period {N : ℕ} (χ : DirichletCharacter ℂ N) (n : ℕ) :
    charPrefix χ (N + n) = charPrefix χ N + charPrefix χ n := by
  induction n with
  | zero => simp [charPrefix]
  | succ k ih =>
    rw [← Nat.add_assoc, charPrefix_succ, ih, charPrefix_succ]
    simp [Nat.cast_add, add_assoc]

/-- Partial summation can remove the linear drift even for a principal character. -/
theorem periodic_remainder_bound {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N) :
    ∃ C : ℝ, 0 < C ∧ ∀ x : ℝ, 1 ≤ x →
      ‖(∑ k ∈ Finset.Icc 1 ⌊x⌋₊, χ (k : ZMod N)) - (x : ℂ) * periodMean χ‖ ≤ C := by
  let F (n : ℕ) := charPrefix χ n - (n : ℂ) * periodMean χ
  have hN : (N : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr (NeZero.ne N)
  have hmean : (N : ℂ) * periodMean χ = charPrefix χ N := by
    unfold periodMean charPrefix
    field_simp
  have hper : Function.Periodic F N := by
    intro n
    change charPrefix χ (n + N) - ((n + N : ℕ) : ℂ) * periodMean χ = _
    rw [Nat.add_comm n N, charPrefix_add_period, Nat.cast_add, add_mul, hmean]
    dsimp [F]
    ring
  let K := ∑ k ∈ Finset.range N, ‖F k‖
  have hK : 0 ≤ K := Finset.sum_nonneg fun k _ => norm_nonneg (F k)
  have hF (n : ℕ) : ‖F n‖ ≤ K := by
    rw [← hper.map_mod_nat n]
    apply Finset.single_le_sum (fun k _ => norm_nonneg (F k))
    exact Finset.mem_range.mpr (Nat.mod_lt _ (NeZero.pos N))
  refine ⟨K + ‖periodMean χ‖ + 1, by positivity, ?_⟩
  intro x hx
  have hfrac : ‖((⌊x⌋₊ : ℕ) : ℂ) - (x : ℂ)‖ ≤ 1 := by
    rw [← Complex.ofReal_natCast, ← Complex.ofReal_sub, Complex.norm_real, Real.norm_eq_abs,
      abs_sub_comm]
    exact Nat.abs_sub_floor_le (by linarith)
  change ‖charPrefix χ ⌊x⌋₊ - (x : ℂ) * periodMean χ‖ ≤ _
  calc
    _ = ‖F ⌊x⌋₊ + (((⌊x⌋₊ : ℕ) : ℂ) - (x : ℂ)) * periodMean χ‖ := by
      congr 1
      dsimp [F]
      ring
    _ ≤ ‖F ⌊x⌋₊‖ + ‖(((⌊x⌋₊ : ℕ) : ℂ) - (x : ℂ)) * periodMean χ‖ := norm_add_le _ _
    _ ≤ K + 1 * ‖periodMean χ‖ := by
      rw [norm_mul]
      exact add_le_add (hF _) (mul_le_mul_of_nonneg_right hfrac (norm_nonneg _))
    _ ≤ _ := by linarith

end Ratioque.CrystalBridge

end

noncomputable section

namespace Ratioque.CrystalBridge

open Complex Filter Asymptotics MeasureTheory
open scoped Topology

/-- The Mellin integral of a residual on the half-line above one. -/
def c2Mellin (E : ℝ → ℂ) (s : ℂ) : ℂ :=
  ∫ x in Set.Ioi (1 : ℝ), E x * (x : ℂ) ^ (-(s + 1))

private def c2Cut (E : ℝ → ℂ) : ℝ → ℂ := (Set.Ioi (1 : ℝ)).indicator E

private lemma c2Cut_local {E : ℝ → ℂ} (h : LocallyIntegrableOn E (Set.Ioi 0)) :
    LocallyIntegrableOn (c2Cut E) (Set.Ioi 0) := by
  intro x hx
  obtain ⟨U, hU, hI⟩ := h x hx
  exact ⟨U, hU, hI.indicator measurableSet_Ioi⟩

private lemma c2Cut_top {E : ℝ → ℂ} {K : ℝ} (hb : ∀ x : ℝ, 1 ≤ x → ‖E x‖ ≤ K) :
    c2Cut E =O[atTop] (fun x : ℝ => x ^ (-(0 : ℝ))) := by
  refine isBigO_iff.mpr ⟨K, ?_⟩
  filter_upwards [eventually_gt_atTop (1 : ℝ)] with x hx
  simpa [c2Cut, Set.indicator_of_mem (Set.mem_Ioi.mpr hx)] using hb x hx.le

private lemma c2Cut_bot (E : ℝ → ℂ) (b : ℝ) :
    c2Cut E =O[𝓝[>] (0 : ℝ)] (fun x : ℝ => x ^ (-b)) := by
  refine isBigO_iff.mpr ⟨0, ?_⟩
  have hh : ∀ᶠ x in 𝓝[>] (0 : ℝ), x < 1 :=
    (eventually_lt_nhds (by norm_num : (0 : ℝ) < 1)).filter_mono nhdsWithin_le_nhds
  filter_upwards [hh] with x hx
  simp [c2Cut, not_lt.mpr hx.le]

private lemma c2Mellin_eq (E : ℝ → ℂ) (s : ℂ) :
    mellin (c2Cut E) (-s) = c2Mellin E s := by
  unfold mellin c2Mellin
  have he (x : ℝ) : (x : ℂ) ^ (-s - 1) • c2Cut E x =
      (Set.Ioi (1 : ℝ)).indicator (fun x : ℝ => E x * (x : ℂ) ^ (-(s + 1))) x := by
    by_cases hx : x ∈ Set.Ioi (1 : ℝ)
    · simp only [c2Cut, Set.indicator_of_mem hx, smul_eq_mul,
        show -s - 1 = -(s + 1) by ring, mul_comm]
    · simp [c2Cut, Set.indicator_of_notMem hx]
  simp_rw [he]
  rw [setIntegral_indicator measurableSet_Ioi,
    Set.inter_eq_right.mpr (Set.Ioi_subset_Ioi (by norm_num))]

/-- Absolute integrability of the correction for positive real part. -/
theorem c2Mellin_integrableOn {E : ℝ → ℂ} {K : ℝ}
    (hloc : LocallyIntegrableOn E (Set.Ioi 0)) (hb : ∀ x : ℝ, 1 ≤ x → ‖E x‖ ≤ K)
    {s : ℂ} (hs : 0 < s.re) :
    IntegrableOn (fun x : ℝ => E x * (x : ℂ) ^ (-(s + 1))) (Set.Ioi 1) := by
  have h := mellinConvergent_of_isBigO_rpow (s := -s) (c2Cut_local hloc) (c2Cut_top hb)
    (by change -s.re < 0; linarith) (c2Cut_bot E (-s.re - 1)) (by change -s.re - 1 < -s.re; linarith)
  unfold MellinConvergent at h
  refine (h.mono_set (Set.Ioi_subset_Ioi (zero_le_one : (0 : ℝ) ≤ 1))).congr_fun ?_ measurableSet_Ioi
  intro x hx
  simp only [c2Cut, Set.indicator_of_mem hx, smul_eq_mul,
    show -s - 1 = -(s + 1) by ring, mul_comm]

/-- Holomorphy of the residual correction throughout the open right half-plane. -/
theorem c2Mellin_differentiableAt {E : ℝ → ℂ} {K : ℝ}
    (hloc : LocallyIntegrableOn E (Set.Ioi 0)) (hb : ∀ x : ℝ, 1 ≤ x → ‖E x‖ ≤ K)
    {s : ℂ} (hs : 0 < s.re) : DifferentiableAt ℂ (c2Mellin E) s := by
  have hd := mellin_differentiableAt_of_isBigO_rpow (s := -s) (c2Cut_local hloc) (c2Cut_top hb)
    (by change -s.re < 0; linarith) (c2Cut_bot E (-s.re - 1)) (by change -s.re - 1 < -s.re; linarith)
  have heq : c2Mellin E = (mellin (c2Cut E)) ∘ (fun z : ℂ => -z) :=
    funext fun z => (c2Mellin_eq E z).symm
  rw [heq]
  exact hd.comp s differentiableAt_id.neg

/-- The majorant `K x^(-3/2)` has integral `2K` on `(1,∞)`. -/
theorem norm_c2Mellin_le {E : ℝ → ℂ} {K : ℝ} (hb : ∀ x : ℝ, 1 ≤ x → ‖E x‖ ≤ K)
    {s : ℂ} (hs : (1 / 2 : ℝ) ≤ s.re) : ‖c2Mellin E s‖ ≤ 2 * K := by
  have hK : 0 ≤ K := (norm_nonneg _).trans (hb 1 le_rfl)
  have ha : -(3 / 2 : ℝ) < -1 := by norm_num
  calc
    ‖c2Mellin E s‖ ≤ ∫ x in Set.Ioi (1 : ℝ), K * x ^ (-(3 / 2 : ℝ)) := by
      apply norm_integral_le_of_norm_le ((integrableOn_Ioi_rpow_of_lt ha zero_lt_one).const_mul K)
      filter_upwards [ae_restrict_mem (μ := volume) (measurableSet_Ioi (a := (1 : ℝ)))] with x hx
      have hx1 : 1 < x := hx
      have hx0 : 0 < x := zero_lt_one.trans hx1
      rw [norm_mul, Complex.norm_cpow_eq_rpow_re_of_pos hx0, Complex.neg_re, Complex.add_re, Complex.one_re]
      exact mul_le_mul (hb x hx1.le) (Real.rpow_le_rpow_of_exponent_le hx1.le (by linarith))
        (Real.rpow_nonneg hx0.le _) hK
    _ = 2 * K := by
      rw [integral_const_mul, integral_Ioi_rpow_of_lt ha zero_lt_one, Real.one_rpow]
      ring

end Ratioque.CrystalBridge

end

noncomputable section

/-! The contribution of the one-period mean in the Abel summation formula. -/

open Complex Set MeasureTheory

namespace Ratioque.CrystalBridge.C2

theorem mean_integrable (m s : ℂ) (hs : 1 < s.re) :
    IntegrableOn (fun t : ℝ => m * (t : ℂ) ^ (-s)) (Ioi 1) :=
  (integrableOn_Ioi_cpow_of_lt (by rwa [neg_re, neg_lt_neg_iff]) zero_lt_one).const_mul m

theorem mean_integral (m s : ℂ) (hs : 1 < s.re) :
    (∫ t in Ioi (1 : ℝ), m * (t : ℂ) ^ (-s)) = m / (s - 1) := by
  rw [integral_const_mul,
    integral_Ioi_cpow_of_lt (by rwa [neg_re, neg_lt_neg_iff]) zero_lt_one,
    ofReal_one, one_cpow, show -s + 1 = -(s - 1) by ring, neg_div_neg_eq,
    mul_one_div]

/-- The strip stays one unit from the pole. A bounded Abel integral therefore
yields linear growth in the height of the L-function. -/
theorem strip_estimate (s z m : ℂ) (K : ℝ) (hK : 0 ≤ K) (hz : ‖z‖ ≤ 2 * K)
    (hs₁ : (1 / 2 : ℝ) ≤ s.re) (hs₂ : s.re ≤ 2) (ht : 1 ≤ |s.im|) :
    ‖s * (z + m / (s - 1))‖ ≤ (2 * (2 * K + ‖m‖)) * (1 + |s.im|) := by
  have hden : 1 ≤ ‖s - 1‖ := ht.trans (by simpa using (abs_im_le_norm (s - 1)))
  have hm : ‖m / (s - 1)‖ ≤ ‖m‖ := by
    rw [norm_div]
    exact div_le_self (norm_nonneg _) hden
  have hsum : ‖z + m / (s - 1)‖ ≤ 2 * K + ‖m‖ :=
    (norm_add_le _ _).trans (add_le_add hz hm)
  have hs : ‖s‖ ≤ 2 * (1 + |s.im|) := by
    refine (norm_le_abs_re_add_abs_im s).trans ?_
    rw [abs_of_nonneg (show 0 ≤ s.re by linarith)]
    linarith [abs_nonneg s.im]
  rw [norm_mul]
  calc
    ‖s‖ * ‖z + m / (s - 1)‖ ≤ ‖s‖ * (2 * K + ‖m‖) :=
      mul_le_mul_of_nonneg_left hsum (norm_nonneg _)
    _ ≤ (2 * (1 + |s.im|)) * (2 * K + ‖m‖) :=
      mul_le_mul_of_nonneg_right hs (add_nonneg (mul_nonneg (by norm_num) hK) (norm_nonneg _))
    _ = _ := by ring

end Ratioque.CrystalBridge.C2

end

noncomputable section

/-! Analytic uniqueness for the partial-summation expression of a Dirichlet L-function. -/

open Complex Filter Set
open scoped Topology

namespace Ratioque.CrystalBridge.C2

/-- A holomorphic candidate agreeing with the Dirichlet series on the right agrees with
the continued L-function in either open quadrant of the positive real half-plane. -/
theorem LFunction_eq_of_right {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N)
    (H : ℂ → ℂ) (hH : ∀ z : ℂ, 0 < z.re → z ≠ 1 → DifferentiableAt ℂ H z)
    (heq : ∀ z : ℂ, 1 < z.re → DirichletCharacter.LFunction χ z = H z)
    (s : ℂ) (hs : 0 < s.re) (ht : s.im ≠ 0) :
    DirichletCharacter.LFunction χ s = H s := by
  let w : ℂ := ⟨2, s.im⟩
  have hw : 1 < w.re := by norm_num [w]
  have right : {z : ℂ | 1 < z.re} ∈ 𝓝 w :=
    (isOpen_lt continuous_const continuous_re).mem_nhds hw
  have germ : DirichletCharacter.LFunction χ =ᶠ[𝓝 w] H := by
    filter_upwards [right] with z hz using heq z hz
  have propagate (U : Set ℂ) (ho : IsOpen U) (hc : Convex ℝ U)
      (hU : ∀ z ∈ U, 0 < z.re ∧ z ≠ 1) (hwU : w ∈ U) (hsU : s ∈ U) :
      DirichletCharacter.LFunction χ s = H s := by
    have hL : AnalyticOnNhd ℂ (DirichletCharacter.LFunction χ) U :=
      DifferentiableOn.analyticOnNhd (fun z hz =>
        (DirichletCharacter.differentiableAt_LFunction χ z (.inl (hU z hz).2)).differentiableWithinAt) ho
    have hA : AnalyticOnNhd ℂ H U :=
      DifferentiableOn.analyticOnNhd (fun z hz =>
        (hH z (hU z hz).1 (hU z hz).2).differentiableWithinAt) ho
    exact hL.eqOn_of_preconnected_of_eventuallyEq hA hc.isPreconnected hwU germ hsU
  rcases lt_or_gt_of_ne ht with h | h
  · refine propagate ({z : ℂ | 0 < z.re} ∩ {z : ℂ | z.im < 0})
      ((isOpen_lt continuous_const continuous_re).inter (isOpen_lt continuous_im continuous_const))
      ((convex_halfSpace_re_gt 0).inter (convex_halfSpace_im_lt 0)) ?_ ⟨by norm_num [w], h⟩ ⟨hs, h⟩
    intro z hz
    refine ⟨hz.1, ?_⟩
    rintro rfl
    exact (lt_irrefl (0 : ℝ)) hz.2
  · refine propagate ({z : ℂ | 0 < z.re} ∩ {z : ℂ | 0 < z.im})
      ((isOpen_lt continuous_const continuous_re).inter (isOpen_lt continuous_const continuous_im))
      ((convex_halfSpace_re_gt 0).inter (convex_halfSpace_im_gt 0)) ?_ ⟨by norm_num [w], h⟩ ⟨hs, h⟩
    intro z hz
    refine ⟨hz.1, ?_⟩
    rintro rfl
    exact (lt_irrefl (0 : ℝ)) hz.2

end Ratioque.CrystalBridge.C2

end

noncomputable section

/-! Split the partial-summation integral into the bounded periodic error and its mean. -/

open Complex Filter Asymptotics MeasureTheory Set

namespace Ratioque.CrystalBridge.C2

def remainder {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N) (t : ℝ) : ℂ :=
  (∑ k ∈ Finset.Icc 1 ⌊t⌋₊, χ (k : ZMod N)) - (t : ℂ) * periodMean χ

theorem remainder_locallyIntegrableOn {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N) :
    LocallyIntegrableOn (remainder χ) (Ioi 0) := by
  suffices h : LocallyIntegrableOn (remainder χ) (Ici 0) from h.mono_set Ioi_subset_Ici_self
  unfold remainder
  refine .sub ?_ (ContinuousOn.locallyIntegrableOn (by fun_prop) measurableSet_Ici)
  simpa using locallyIntegrableOn_mul_sum_Icc (m := 1) (fun k : ℕ => χ (k : ZMod N))
    (le_refl (0 : ℝ)) (locallyIntegrableOn_const (1 : ℂ))

theorem LFunction_abel {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N) (s : ℂ)
    (hs : 1 < s.re)
    (hI : IntegrableOn (fun t : ℝ => remainder χ t * (t : ℂ) ^ (-(s+1))) (Ioi 1)) :
    DirichletCharacter.LFunction χ s =
      s * ((∫ t in Ioi (1 : ℝ), remainder χ t * (t : ℂ) ^ (-(s+1))) +
        periodMean χ / (s-1)) := by
  have hO : (fun n : ℕ => ∑ k ∈ Finset.Icc 1 n, ‖χ (k : ZMod N)‖) =O[atTop]
      (fun n : ℕ => (n : ℝ) ^ (1 : ℝ)) := by
    apply isBigO_of_le
    intro n
    rw [Real.norm_eq_abs, abs_of_nonneg (Finset.sum_nonneg (fun _ _ => norm_nonneg _))]
    simpa using (Finset.sum_le_sum (s := Finset.Icc 1 n)
      (fun k _ => χ.norm_le_one (k : ZMod N)))
  rw [DirichletCharacter.LFunction_eq_LSeries χ hs,
    LSeries_eq_mul_integral' (fun k : ℕ => χ (k : ZMod N)) zero_le_one hs hO]
  congr 1
  rw [← mean_integral (periodMean χ) s hs, ← integral_add hI (mean_integrable _ _ hs)]
  apply setIntegral_congr_fun measurableSet_Ioi
  intro t ht
  have ht' : (t : ℂ) ≠ 0 := ne_zero_of_one_lt_re ht
  have hpow : (t : ℂ) * (t : ℂ) ^ (-(s+1)) = (t : ℂ) ^ (-s) := by
    rw [show -(s+1) = -s - 1 by ring, cpow_sub _ _ ht', cpow_one]
    field_simp
  dsimp only [remainder]
  linear_combination (periodMean χ) * hpow

end Ratioque.CrystalBridge.C2

end

noncomputable section

namespace Ratioque.CrystalBridge

/-- Partial summation of a periodic character yields the explicit exponent one. -/
theorem LFunction_linear_growth {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N) :
    ∃ C : ℝ, 0 < C ∧ ∀ s : ℂ, (1 / 2 : ℝ) ≤ s.re → s.re ≤ 2 → 1 ≤ |s.im| →
      ‖DirichletCharacter.LFunction χ s‖ ≤ C * (1 + |s.im|) := by
  obtain ⟨K, hK, hb⟩ := periodic_remainder_bound χ
  have bound : ∀ t : ℝ, 1 ≤ t → ‖C2.remainder χ t‖ ≤ K := hb
  have loc := C2.remainder_locallyIntegrableOn χ
  let H (s : ℂ) := s * (c2Mellin (C2.remainder χ) s + periodMean χ / (s-1))
  have hH (s : ℂ) (hs : 0 < s.re) (h1 : s ≠ 1) : DifferentiableAt ℂ H s := by
    have hdiv : DifferentiableAt ℂ (fun z : ℂ => periodMean χ / (z - 1)) s := by
      fun_prop (disch := exact sub_ne_zero.mpr h1)
    exact differentiableAt_id.mul ((c2Mellin_differentiableAt loc bound hs).add hdiv)
  have heq (s : ℂ) (hs : 1 < s.re) : DirichletCharacter.LFunction χ s = H s :=
    C2.LFunction_abel χ s hs (c2Mellin_integrableOn loc bound (zero_lt_one.trans hs))
  refine ⟨2 * (2*K + ‖periodMean χ‖), by positivity, ?_⟩
  intro s hs₁ hs₂ ht
  have hIm : s.im ≠ 0 := by intro h; norm_num [h] at ht
  rw [C2.LFunction_eq_of_right χ H hH heq s (by linarith) hIm]
  exact C2.strip_estimate s _ _ K hK.le (norm_c2Mellin_le bound hs₁) hs₁ hs₂ ht

/-- C2 of the all-characters converse. -/
theorem LFunction_polynomial_growth {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N) :
    ∃ A C : ℝ, 0 < C ∧ ∀ s : ℂ, (1 / 2 : ℝ) ≤ s.re → s.re ≤ 2 → 1 ≤ |s.im| →
      ‖DirichletCharacter.LFunction χ s‖ ≤ C * (1 + |s.im|) ^ A := by
  obtain ⟨C, hC, h⟩ := LFunction_linear_growth χ
  exact ⟨1, C, hC, fun s h₁ h₂ ht => by simpa only [Real.rpow_one] using h s h₁ h₂ ht⟩

#print axioms LFunction_linear_growth
#print axioms LFunction_polynomial_growth
end Ratioque.CrystalBridge

end
