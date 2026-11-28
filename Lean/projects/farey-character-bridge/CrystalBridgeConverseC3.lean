import CrystalBridge
import CrystalBridgeConverseC2
import Mathlib.Analysis.Complex.AbsMax
import Mathlib.Analysis.Complex.BorelCaratheodory
import Mathlib.Analysis.Complex.HasPrimitives
import Mathlib.Analysis.Real.Pi.Bounds
import Mathlib.Analysis.SpecialFunctions.Complex.LogBounds
import Mathlib.NumberTheory.ZetaValues

/-! # Subpolynomial growth of the reciprocal under EveryCharacter

C3 of the all-characters converse. At large height a disk of radius 5/2 about
3+it avoids the pole and lies in the zero-free region. A primitive of L'/L
extends the bounded logarithm on the inner disk. Borel–Carathéodory bounds
the extension by O(log(1+|t|)) on a smaller disk. The maximum principle on
an annulus makes that logarithmic coefficient arbitrarily small on the target
strip. The bounded heights follow by compactness.
-/

noncomputable section

/-! On the absolute-convergence side, the Dirichlet series stays in a fixed
disk about 1. Its principal logarithm therefore supplies a bounded branch,
uniform in the height and in the character. -/


namespace Ratioque.CrystalBridge.C3

open Complex

/-- The tail beyond the first coefficient is strictly smaller than one. -/
theorem anchor_LFunction_sub_one {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N)
    {s : ℂ} (hs : 2 ≤ s.re) : ‖DirichletCharacter.LFunction χ s - 1‖ ≤ 3 / 4 := by
  let f : ℕ → ℂ := fun n => χ (n : ZMod N)
  let a := LSeries.term f s
  let b (n : ℕ) : ℝ := 1 / (n : ℝ) ^ 2
  have hs' : 1 < s.re := by linarith
  have ha : Summable a := DirichletCharacter.LSeriesSummable_of_one_lt_re χ hs'
  have hb : HasSum b (Real.pi ^ 2 / 6) := hasSum_zeta_two
  have hsum : (∑' n : ℕ, a (n + 2)) = DirichletCharacter.LFunction χ s - 1 := by
    apply eq_sub_of_add_eq
    rw [add_comm, DirichletCharacter.LFunction_eq_LSeries χ hs']
    change 1 + (∑' n : ℕ, a (n + 2)) = ∑' n : ℕ, a n
    simpa [Finset.sum_range_succ, a, f] using ha.sum_add_tsum_nat_add 2
  have hsumB : (∑' n : ℕ, b (n + 2)) = Real.pi ^ 2 / 6 - 1 := by
    apply eq_sub_of_add_eq
    rw [add_comm, ← hb.tsum_eq]
    simpa [Finset.sum_range_succ, b] using hb.summable.sum_add_tsum_nat_add 2
  have hle (n : ℕ) : ‖a (n + 2)‖ ≤ b (n + 2) := by
    calc
      _ ≤ ‖LSeries.term f 2 (n + 2)‖ :=
        LSeries.norm_term_le_of_re_le_re f (by simpa using hs) _
      _ ≤ _ := by
        rw [LSeries.norm_term_eq, ite_eq_right (by omega)]
        simp only [re_ofNat, Real.rpow_two, b]
        exact div_le_div_of_nonneg_right (χ.norm_le_one _) (sq_nonneg _)
  have haTail : Summable (fun n : ℕ => ‖a (n + 2)‖) := (summable_nat_add_iff 2).mpr ha.norm
  have hbTail : Summable (fun n : ℕ => b (n + 2)) := (summable_nat_add_iff 2).mpr hb.summable
  rw [← hsum]
  refine (norm_tsum_le_tsum_norm haTail).trans ((haTail.tsum_mono hbTail hle).trans ?_)
  rw [hsumB]
  nlinarith [Real.pi_lt_d2, Real.pi_pos, mul_self_le_mul_self Real.pi_pos.le Real.pi_lt_d2.le]

/-- The principal branch can be used throughout the inner disk of the C3 argument. -/
theorem anchor_log {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N) {s : ℂ}
    (hs : 2 ≤ s.re) :
    DifferentiableAt ℂ (fun z => Complex.log (DirichletCharacter.LFunction χ z)) s ∧
    Complex.exp (Complex.log (DirichletCharacter.LFunction χ s)) = DirichletCharacter.LFunction χ s ∧
    ‖Complex.log (DirichletCharacter.LFunction χ s)‖ ≤ 8 := by
  let z := DirichletCharacter.LFunction χ s - 1
  have hz : ‖z‖ ≤ 3 / 4 := anchor_LFunction_sub_one χ hs
  have hz' : ‖z‖ < 1 := by linarith
  have he : 1 + z = DirichletCharacter.LFunction χ s := by dsimp [z]; ring
  have hslit := Complex.mem_slitPlane_of_norm_lt_one hz'
  rw [he] at hslit
  have hs1 : s ≠ 1 := by rintro rfl; norm_num at hs
  refine ⟨(Complex.differentiableAt_log hslit).comp s
    (DirichletCharacter.differentiableAt_LFunction χ s (.inl hs1)),
    Complex.exp_log (Complex.slitPlane_ne_zero hslit), ?_⟩
  rw [← he]
  refine (Complex.norm_log_one_add_le hz').trans ?_
  have hden : (1 - ‖z‖)⁻¹ ≤ 4 := by
    rw [inv_eq_one_div, div_le_iff₀ (by linarith)]
    linarith
  have hprod := mul_le_mul (mul_self_le_mul_self (norm_nonneg z) hz) hden
    (inv_nonneg.mpr (by linarith)) (by norm_num)
  nlinarith [hprod, norm_nonneg z]

end Ratioque.CrystalBridge.C3

end

noncomputable section

open Complex Set Metric
namespace Ratioque.CrystalBridge.C3

/-- The disk for height t has center 3+it and radius 5/2. -/
def center (t : ℝ) : ℂ := ⟨3, t⟩

theorem disk_geometry {t : ℝ} (ht : 5 ≤ |t|) {z : ℂ} (hz : ‖z‖ < 5/2) :
    1/2 < (center t + z).re ∧ 1 ≤ |(center t + z).im| ∧
      |(center t + z).im| ≤ |t| + 5/2 := by
  change 1/2 < 3 + z.re ∧ 1 ≤ |t + z.im| ∧ |t + z.im| ≤ |t| + 5/2
  have hre := (abs_le.mp (Complex.abs_re_le_norm z)).1
  have him := Complex.abs_im_le_norm z
  have ha : |t| ≤ |t + z.im| + |z.im| := by
    simpa using abs_sub (t + z.im) z.im
  refine ⟨by linarith, by linarith, (abs_add_le ..).trans ?_⟩
  linarith

theorem disk_nonzero {N : ℕ} [NeZero N] (h : EveryCharacter) (χ : DirichletCharacter ℂ N)
    {t : ℝ} (ht : 5 ≤ |t|) {z : ℂ} (hz : z ∈ ball (0:ℂ) (5/2)) :
    DirichletCharacter.LFunction χ (center t + z) ≠ 0 := by
  obtain ⟨hre, him, _⟩ := disk_geometry ht (mem_ball_zero_iff.mp hz)
  apply h N χ _ hre
  right
  intro h1
  rw [h1] at him
  norm_num at him

theorem disk_holomorphic {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N)
    {t : ℝ} (ht : 5 ≤ |t|) :
    DifferentiableOn ℂ (fun z => DirichletCharacter.LFunction χ (center t + z))
      (ball 0 (5/2)) := by
  intro z hz
  have him := (disk_geometry ht (mem_ball_zero_iff.mp hz)).2.1
  have hs : center t + z ≠ 1 := by intro h; rw [h] at him; norm_num at him
  exact ((DirichletCharacter.differentiableAt_LFunction χ _ (.inl hs)).comp z
    (differentiableAt_const _ |>.add differentiableAt_id)).differentiableWithinAt

/-- The portion with bounded height is compact and avoids both zeros and the principal pole. -/
theorem small_height {N : ℕ} [NeZero N] (h : EveryCharacter) (χ : DirichletCharacter ℂ N)
    {η : ℝ} (hη : 0 < η) :
    ∃ B : ℝ, 0 ≤ B ∧ ∀ s : ℂ, 1/2 + η ≤ s.re → s.re ≤ 2 →
      1 ≤ |s.im| → |s.im| ≤ 5 → ‖(DirichletCharacter.LFunction χ s)⁻¹‖ ≤ B := by
  let S : Set ℂ := {s | (1/2 + η ≤ s.re ∧ s.re ≤ 2) ∧ (1 ≤ |s.im| ∧ |s.im| ≤ 5)}
  have hclosed : IsClosed S :=
    ((isClosed_le continuous_const continuous_re).inter (isClosed_le continuous_re continuous_const)).inter
      ((isClosed_le continuous_const continuous_im.abs).inter (isClosed_le continuous_im.abs continuous_const))
  have hsubset : S ⊆ closedBall (0:ℂ) 7 := by
    intro s hs
    apply mem_closedBall_zero_iff.mpr
    apply (Complex.norm_le_abs_re_add_abs_im s).trans
    rcases hs with ⟨⟨hl, hu⟩, _, ht⟩
    rw [abs_of_nonneg (show 0 ≤ s.re by linarith)]
    linarith
  have hc := (isCompact_closedBall (0:ℂ) 7).of_isClosed_subset hclosed hsubset
  have hcont : ContinuousOn (fun s : ℂ => (DirichletCharacter.LFunction χ s)⁻¹) S := by
    intro s hs
    rcases hs with ⟨⟨hl, _⟩, hi, _⟩
    have h1 : s ≠ 1 := by intro h; rw [h] at hi; norm_num at hi
    exact ((DirichletCharacter.differentiableAt_LFunction χ s (.inl h1)).continuousAt.inv₀
      (h N χ s (by linarith) (.inr h1))).continuousWithinAt
  obtain ⟨B, hb⟩ := hc.exists_bound_of_continuousOn hcont
  exact ⟨max 0 B, le_max_left .., fun s hl hu hi ht =>
    (hb s ⟨⟨hl, hu⟩, hi, ht⟩).trans (le_max_right ..)⟩

end Ratioque.CrystalBridge.C3

end

noncomputable section

open Complex Filter Metric Set
open scoped Topology

namespace Ratioque.CrystalBridge.C3

/-- Integrating the logarithmic derivative on the large disk extends a prescribed
logarithm on the concentric unit disk. -/
theorem exists_log_on_disk {L g : ℂ → ℂ}
    (hL : DifferentiableOn ℂ L (ball 0 (5 / 2)))
    (hn : ∀ z ∈ ball (0 : ℂ) (5 / 2), L z ≠ 0)
    (hg : DifferentiableOn ℂ g (ball 0 1))
    (heg : ∀ z ∈ ball (0 : ℂ) 1, exp (g z) = L z) :
    ∃ F : ℂ → ℂ, DifferentiableOn ℂ F (ball 0 (5 / 2)) ∧
      (∀ z ∈ ball (0 : ℂ) (5 / 2), exp (F z) = L z) ∧ EqOn F g (ball 0 1) := by
  have hlogderiv := (hL.deriv isOpen_ball).div hL hn
  obtain ⟨F, hF0, hF⟩ := hlogderiv.isExactOn_ball.with_val_at 0 (g 0)
  have hFd : DifferentiableOn ℂ F (ball 0 (5 / 2)) :=
    fun z hz => (hF z hz).differentiableAt.differentiableWithinAt
  have hsub : ball (0 : ℂ) 1 ⊆ ball 0 (5 / 2) := ball_subset_ball (by norm_num)
  have h0 : (0 : ℂ) ∈ ball 0 1 := mem_ball_self zero_lt_one
  let Q (z : ℂ) := L z * exp (-F z)
  have hQ (z : ℂ) (hz : z ∈ ball (0 : ℂ) (5 / 2)) : HasDerivAt Q 0 z := by
    have d := (hL.differentiableAt (isOpen_ball.mem_nhds hz)).hasDerivAt
    apply (d.mul (hF z hz).neg.cexp).congr_deriv
    change deriv L z * exp (-F z) + L z * (exp (-F z) * -(deriv L z / L z)) = 0
    field_simp [hn z hz]
    ring
  have hQ0 : Q 0 = 1 := by
    change L 0 * exp (-F 0) = 1
    rw [hF0, ← heg 0 h0, exp_neg, mul_inv_cancel₀ (exp_ne_zero _)]
  refine ⟨F, hFd, ?_, ?_⟩
  · intro z hz
    have eqQ := isOpen_ball.is_const_of_deriv_eq_zero (𝕜 := ℂ) (convex_ball (0 : ℂ) (5 / 2)).isPreconnected
      (fun x hx => (hQ x hx).differentiableAt.differentiableWithinAt)
      (fun x hx => (hQ x hx).deriv) hz (hsub h0)
    rw [hQ0] at eqQ
    change L z * exp (-F z) = 1 at eqQ
    rw [exp_neg, ← div_eq_mul_inv, div_eq_one_iff_eq (exp_ne_zero _)] at eqQ
    exact eqQ.symm
  · apply isOpen_ball.eqOn_of_deriv_eq (convex_ball (0 : ℂ) 1).isPreconnected (hFd.mono hsub) hg _ h0 hF0
    intro z hz
    have hdg := (hg.differentiableAt (isOpen_ball.mem_nhds hz)).hasDerivAt.cexp
    have he : L =ᶠ[𝓝 z] (fun w => exp (g w)) := by
      filter_upwards [isOpen_ball.mem_nhds hz] with w hw using (heg w hw).symm
    have hder := (hdg.congr_of_eventuallyEq he).deriv
    rw [(hF z (hsub hz)).deriv]
    change deriv L z / L z = deriv g z
    rw [hder, heg z hz]
    field_simp [hn z (hsub hz)]

/-- Borel--Carathéodory with the radius gap `η / 2` kept explicit. -/
theorem log_disk_bound {F : ℂ → ℂ} {M η : ℝ} (hM : 0 < M) (hη : 0 < η)
    (hF : DifferentiableOn ℂ F (ball 0 (5 / 2)))
    (hRe : ∀ z ∈ ball (0 : ℂ) (5 / 2), (F z).re ≤ M)
    {z : ℂ} (hz : ‖z‖ ≤ 5 / 2 - η / 2) : ‖F z‖ ≤ (10 / η) * (M + ‖F 0‖) := by
  have hr : ‖z‖ < (5 / 2 : ℝ) := by linarith
  have hpos : 0 < (5 / 2 : ℝ) - ‖z‖ := sub_pos.mpr hr
  have hbc := Complex.borelCaratheodory hM hF (fun _ hz => hRe _ hz) (by norm_num)
    (mem_ball_zero_iff.mpr hr)
  apply hbc.trans
  have hA : 2 * ‖z‖ / (5 / 2 - ‖z‖) ≤ 10 / η := by
    apply (div_le_div_iff₀ hpos hη).mpr
    nlinarith [mul_le_mul_of_nonneg_right hr.le hη.le]
  have hB : (5 / 2 + ‖z‖) / (5 / 2 - ‖z‖) ≤ 10 / η := by
    apply (div_le_div_iff₀ hpos hη).mpr
    nlinarith [mul_le_mul_of_nonneg_right hr.le hη.le]
  calc
    _ = (2 * ‖z‖ / (5 / 2 - ‖z‖)) * M + ((5 / 2 + ‖z‖) / (5 / 2 - ‖z‖)) * ‖F 0‖ := by ring
    _ ≤ (10 / η) * M + (10 / η) * ‖F 0‖ :=
      add_le_add (mul_le_mul_of_nonneg_right hA hM.le) (mul_le_mul_of_nonneg_right hB (norm_nonneg _))
    _ = _ := by ring

end Ratioque.CrystalBridge.C3

end

noncomputable section

/-! A disk estimate for a family of holomorphic functions with a uniform inner bound. -/

open Complex Set Metric Bornology

namespace Ratioque.CrystalBridge.C3

/-- If a holomorphic function is bounded by `A` on the inner disk, the fraction of its
outer bound `B` needed on an intermediate disk can be made arbitrarily small. The
additive constant depends only on the radii, `A`, and that fraction. -/
theorem disk_propagation {a r R A δ : ℝ}
    (ha : 0 < a) (har : a < r) (hrR : r < R) (hA : 0 ≤ A) (hδ : 0 < δ) :
    ∃ C : ℝ, 0 ≤ C ∧ ∀ (F : ℂ → ℂ) (B : ℝ), 0 ≤ B →
      (∀ z : ℂ, ‖z‖ ≤ R → DifferentiableAt ℂ F z) →
      (∀ z : ℂ, ‖z‖ ≤ a → ‖F z‖ ≤ A) →
      (∀ z : ℂ, ‖z‖ ≤ R → ‖F z‖ ≤ B) →
      ∀ z : ℂ, ‖z‖ ≤ r → ‖F z‖ ≤ δ * B + C := by
  have hr := ha.trans har
  have hR := hr.trans hrR
  obtain ⟨n, hn⟩ := exists_pow_lt_of_lt_one hδ ((div_lt_one hR).mpr hrR)
  refine ⟨A + A * (r / a) ^ n, by positivity, ?_⟩
  intro F B hB hF hin hout z hz
  by_cases hz₀ : ‖z‖ ≤ a
  · apply (hin z hz₀).trans
    linarith [mul_nonneg hδ.le hB, mul_nonneg hA (pow_nonneg (div_nonneg hr.le ha.le) n)]
  let U : Set ℂ := {w | a < ‖w‖ ∧ ‖w‖ < R}
  let G : ℂ → ℂ := fun w => F w / w ^ n
  have hclosed : closure U ⊆ {w : ℂ | a ≤ ‖w‖ ∧ ‖w‖ ≤ R} :=
    closure_minimal (fun w hw => ⟨hw.1.le, hw.2.le⟩)
      ((isClosed_le continuous_const continuous_norm).inter (isClosed_le continuous_norm continuous_const))
  have hopen : IsOpen U :=
    (isOpen_lt continuous_const continuous_norm).inter (isOpen_lt continuous_norm continuous_const)
  have hbdd : IsBounded U := (isBounded_ball (x := (0 : ℂ)) (r := R)).subset (by
    intro w hw
    simpa only [mem_ball, dist_zero_right] using hw.2)
  have hG : DiffContOnCl ℂ G U := by
    apply DifferentiableOn.diffContOnCl
    intro w hw
    obtain ⟨hwa, hwR⟩ := hclosed hw
    have hw₀ : w ≠ 0 := norm_pos_iff.mp (ha.trans_le hwa)
    exact ((hF w hwR).div (differentiableAt_id.pow n) (pow_ne_zero n hw₀)).differentiableWithinAt
  have hfront (w : ℂ) (hw : w ∈ frontier U) :
      ‖G w‖ ≤ A / a ^ n + B / R ^ n := by
    obtain ⟨hwa, hwR⟩ := hclosed (frontier_subset_closure hw)
    have hnot : w ∉ U := by
      have h := hw.2
      rwa [hopen.interior_eq] at h
    have hside : ‖w‖ = a ∨ ‖w‖ = R := by
      by_contra! h
      exact hnot ⟨lt_of_le_of_ne hwa (Ne.symm h.1), lt_of_le_of_ne hwR h.2⟩
    change ‖F w / w ^ n‖ ≤ _
    rw [norm_div, norm_pow]
    rcases hside with h | h
    · rw [h]
      exact (div_le_div_of_nonneg_right (hin w h.le) (pow_nonneg ha.le n)).trans
        (le_add_of_nonneg_right (div_nonneg hB (pow_nonneg hR.le n)))
    · rw [h]
      exact (div_le_div_of_nonneg_right (hout w hwR) (pow_nonneg hR.le n)).trans
        (le_add_of_nonneg_left (div_nonneg hA (pow_nonneg ha.le n)))
  have hu : z ∈ U := ⟨lt_of_not_ge hz₀, hz.trans_lt hrR⟩
  have he := Complex.norm_le_of_forall_mem_frontier_norm_le hbdd hG hfront (subset_closure hu)
  change ‖F z / z ^ n‖ ≤ _ at he
  rw [norm_div, norm_pow, div_le_iff₀ (pow_pos (ha.trans hu.1) n)] at he
  calc
    ‖F z‖ ≤ (A / a ^ n + B / R ^ n) * ‖z‖ ^ n := he
    _ ≤ (A / a ^ n + B / R ^ n) * r ^ n :=
      mul_le_mul_of_nonneg_left (pow_le_pow_left₀ (norm_nonneg _) hz n) (by positivity)
    _ = A * (r / a) ^ n + B * (r / R) ^ n := by rw [div_pow, div_pow]; ring
    _ ≤ δ * B + (A + A * (r / a) ^ n) := by
      linarith [mul_le_mul_of_nonneg_left hn.le hB, mul_comm B δ]

end Ratioque.CrystalBridge.C3

end

noncomputable section

open Complex Set Metric
namespace Ratioque.CrystalBridge.C3

/-- A linear majorant on the translated disk, uniformly in its height. -/
theorem disk_upper {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N)
    (anchor : ∀ s : ℂ, 2 ≤ s.re → ‖DirichletCharacter.LFunction χ s - 1‖ ≤ 3/4) :
    ∃ D : ℝ, 1 ≤ D ∧ ∀ t : ℝ, 5 ≤ |t| → ∀ z ∈ ball (0:ℂ) (5/2),
      ‖DirichletCharacter.LFunction χ (center t + z)‖ ≤ D * (1 + |t|) := by
  obtain ⟨C, hC, h⟩ := LFunction_linear_growth χ
  refine ⟨4*(C+1), by linarith, ?_⟩
  intro t ht z hz
  let s := center t + z
  obtain ⟨hre, him, him'⟩ := disk_geometry ht (mem_ball_zero_iff.mp hz)
  by_cases hu : s.re ≤ 2
  · calc
      _ ≤ C * (1 + |s.im|) := h s hre.le hu him
      _ ≤ C * (4 * (1 + |t|)) := by
        apply mul_le_mul_of_nonneg_left _ hC.le
        change 1 + |(center t + z).im| ≤ _
        linarith [abs_nonneg t]
      _ ≤ _ := by nlinarith [abs_nonneg t]
  · have hsmall := anchor s (le_of_not_ge hu)
    have hL : ‖DirichletCharacter.LFunction χ s‖ ≤ 3/4 + 1 := by
      calc _ = ‖(DirichletCharacter.LFunction χ s - 1) + 1‖ := by simp
           _ ≤ ‖DirichletCharacter.LFunction χ s - 1‖ + ‖(1:ℂ)‖ := norm_add_le ..
           _ ≤ _ := by simpa using add_le_add_right hsmall 1
    apply hL.trans
    nlinarith [abs_nonneg t, mul_nonneg hC.le (abs_nonneg t)]

/-- A uniform bound for the real part of a branch follows from the bound for its exponential. -/
theorem re_of_exp_le {w : ℂ} {D T : ℝ} (hD : 1 ≤ D) (hT : 1 ≤ T)
    (h : ‖Complex.exp w‖ ≤ D*T) : w.re ≤ Real.log D + Real.log T := by
  rw [Complex.norm_exp] at h
  simpa [Real.log_mul (show D ≠ 0 by linarith) (show T ≠ 0 by linarith)] using
    (Real.log_le_log (Real.exp_pos _) h)

/-- Convert a logarithm bound with an arbitrarily small coefficient into a power bound. -/
theorem inv_exp_estimate {w L : ℂ} {T ε A : ℝ} (hT : 0 < T)
    (hw : Complex.exp w = L) (hf : ‖w‖ ≤ ε * Real.log T + A) :
    ‖L⁻¹‖ ≤ Real.exp A * T ^ ε := by
  calc
    _ = ‖Complex.exp (-w)‖ := by rw [Complex.exp_neg, hw]
    _ = Real.exp (-w.re) := by rw [Complex.norm_exp, Complex.neg_re]
    _ ≤ Real.exp (ε * Real.log T + A) := Real.exp_le_exp.mpr ((by
      linarith [(abs_le.mp (Complex.abs_re_le_norm w)).1] : -w.re ≤ ‖w‖).trans hf)
    _ = _ := by
      rw [Real.exp_add, Real.rpow_def_of_pos hT, mul_comm ε (Real.log T), mul_comm]

end Ratioque.CrystalBridge.C3

end

noncomputable section

open Complex Set Metric
namespace Ratioque.CrystalBridge.C3

/-- A logarithm of L on each translated disk, anchored at the absolutely convergent side. -/
theorem disk_family {N : ℕ} [NeZero N] (h : EveryCharacter) (χ : DirichletCharacter ℂ N)
    (d : ℝ) (hd : 0 < d) (hd' : d ≤ 1/2) :
    ∃ D : ℝ, 0 < D ∧ ∀ t : ℝ, 5 ≤ |t| → ∃ F : ℂ → ℂ,
      (∀ z, ‖z‖ ≤ 5/2-d/2 → DifferentiableAt ℂ F z) ∧
      (∀ z, ‖z‖ ≤ 1/2 → ‖F z‖ ≤ 8) ∧
      (∀ z, ‖z‖ ≤ 5/2-d/2 → ‖F z‖ ≤ D*(1+Real.log (1+|t|))) ∧
      ∀ z, ‖z‖ ≤ 5/2-d → Complex.exp (F z) = DirichletCharacter.LFunction χ (center t+z) := by
  obtain ⟨D, hD, upper⟩ := disk_upper χ (fun s hs => anchor_LFunction_sub_one χ hs)
  have hlogD := Real.log_nonneg hD
  refine ⟨(10/d) * (10 + Real.log D), by positivity, ?_⟩
  intro t ht
  let f := fun z : ℂ => DirichletCharacter.LFunction χ (center t + z)
  let g := fun z : ℂ => Complex.log (f z)
  have right (z : ℂ) (hz : z ∈ ball 0 1) : 2 ≤ (center t+z).re := by
    change 2 ≤ 3 + z.re
    have := mem_ball_zero_iff.mp hz
    linarith [(abs_le.mp (Complex.abs_re_le_norm z)).1]
  have hg : DifferentiableOn ℂ g (ball 0 1) := by
    intro z hz
    exact ((anchor_log χ (right z hz)).1.comp z <|
      (differentiableAt_const _ |>.add differentiableAt_id)).differentiableWithinAt
  have heg : ∀ z ∈ ball (0:ℂ) 1, Complex.exp (g z) = f z :=
    fun z hz => (anchor_log χ (right z hz)).2.1
  obtain ⟨F, hF, hexp, hagree⟩ := exists_log_on_disk
    (L := f) (g := g) (disk_holomorphic χ ht) (fun z hz => disk_nonzero h χ ht hz) hg heg
  have inner (z : ℂ) (hz : ‖z‖ ≤ 1/2) : ‖F z‖ ≤ 8 := by
    have hz' : z ∈ ball (0:ℂ) 1 := mem_ball_zero_iff.mpr (by linarith)
    rw [hagree hz']
    exact (anchor_log χ (right z hz')).2.2
  have hT : 1 ≤ 1 + |t| := by linarith [abs_nonneg t]
  have hlogT := Real.log_nonneg hT
  have real_bound (z : ℂ) (hz : z ∈ ball (0:ℂ) (5/2)) :
      (F z).re ≤ 1 + Real.log D + Real.log (1+|t|) := by
    have he : ‖Complex.exp (F z)‖ ≤ D*(1+|t|) := by rw [hexp z hz]; exact upper t ht z hz
    linarith [re_of_exp_le hD hT he]
  refine ⟨F, ?_, inner, ?_, ?_⟩
  · intro z hz
    exact hF.differentiableAt (isOpen_ball.mem_nhds (mem_ball_zero_iff.mpr (by linarith)))
  · intro z hz
    have hb := log_disk_bound (show 0 < 1 + Real.log D + Real.log (1+|t|) by linarith)
      hd hF real_bound hz
    refine hb.trans ?_
    calc
      _ ≤ (10/d) * ((10 + Real.log D) * (1 + Real.log (1+|t|))) := by
        apply mul_le_mul_of_nonneg_left _ (by positivity)
        have h0 := inner 0 (by norm_num)
        nlinarith [mul_nonneg hlogD hlogT]
      _ = _ := by ring
  · intro z hz
    exact hexp z (mem_ball_zero_iff.mpr (by linarith))

end Ratioque.CrystalBridge.C3

end

noncomputable section

open Complex

namespace Ratioque.CrystalBridge.C3

/-- Propagate the uniformly normalized logarithm from the central disk and combine this
large-height estimate with compactness on the remainder of the strip. -/
theorem of_disk_family {N : ℕ} [NeZero N] (h : EveryCharacter) (χ : DirichletCharacter ℂ N)
    (disks : ∀ d : ℝ, 0 < d → d ≤ 1/2 → ∃ D : ℝ, 0 < D ∧
      ∀ t : ℝ, 5 ≤ |t| → ∃ F : ℂ → ℂ,
        (∀ z : ℂ, ‖z‖ ≤ 5/2-d/2 → DifferentiableAt ℂ F z) ∧
        (∀ z : ℂ, ‖z‖ ≤ 1/2 → ‖F z‖ ≤ 8) ∧
        (∀ z : ℂ, ‖z‖ ≤ 5/2-d/2 → ‖F z‖ ≤ D * (1 + Real.log (1+|t|))) ∧
        ∀ z : ℂ, ‖z‖ ≤ 5/2-d → Complex.exp (F z) = DirichletCharacter.LFunction χ (center t + z))
    {ε η : ℝ} (hε : 0 < ε) (hη : 0 < η) :
    ∃ C : ℝ, 0 < C ∧ ∀ s : ℂ, (1/2 : ℝ) + η ≤ s.re → s.re ≤ 2 → 1 ≤ |s.im| →
      ‖(DirichletCharacter.LFunction χ s)⁻¹‖ ≤ C * (1 + |s.im|) ^ ε := by
  let d : ℝ := min η (1/2)
  have hd : 0 < d := lt_min hη (by norm_num)
  have hd' : d ≤ 1/2 := min_le_right ..
  have hdη : d ≤ η := min_le_left ..
  obtain ⟨D, hD, hfamily⟩ := disks d hd hd'
  obtain ⟨K, _, hprop⟩ := disk_propagation (a := 1/2) (r := 5/2-d) (R := 5/2-d/2)
    (A := 8) (δ := ε/D) (by norm_num) (by linarith) (by linarith) (by norm_num) (div_pos hε hD)
  obtain ⟨B, hB, hsmall⟩ := small_height h χ hη
  let E := Real.exp (ε + K)
  refine ⟨B+E, add_pos_of_nonneg_of_pos hB (Real.exp_pos _), ?_⟩
  intro s hσ hσ' ht
  let T := 1 + |s.im|
  have hT₁ : 1 ≤ T := by dsimp [T]; linarith [abs_nonneg s.im]
  have hT : 0 < T := zero_lt_one.trans_le hT₁
  have hpow := Real.one_le_rpow hT₁ hε.le
  by_cases hlarge : 5 ≤ |s.im|
  · obtain ⟨F, hF, hin, hout, hexp⟩ := hfamily s.im hlarge
    let z : ℂ := ((s.re - 3 : ℝ) : ℂ)
    have hz : ‖z‖ ≤ 5/2 - d := by
      dsimp [z]
      rw [Complex.norm_real, Real.norm_eq_abs, abs_of_nonpos (by linarith : s.re - 3 ≤ 0)]
      linarith
    have hsz : center s.im + z = s := by
      apply Complex.ext
      · change 3 + (s.re - 3) = s.re
        ring
      · change s.im + 0 = s.im
        ring
    have hOuter : 0 ≤ D * (1 + Real.log T) :=
      mul_nonneg hD.le (by linarith [Real.log_nonneg hT₁])
    have hbound := hprop F (D * (1 + Real.log T)) hOuter hF hin hout z hz
    have hlog : ‖F z‖ ≤ ε * Real.log T + (ε+K) := by
      calc
        _ ≤ ε / D * (D * (1 + Real.log T)) + K := hbound
        _ = _ := by field_simp [hD.ne']; ring
    have hL := hexp z hz
    rw [hsz] at hL
    apply (inv_exp_estimate hT hL hlog).trans
    exact mul_le_mul_of_nonneg_right (le_add_of_nonneg_left hB) (by positivity)
  · have hb := hsmall s hσ hσ' ht (le_of_not_ge hlarge)
    apply hb.trans
    calc
      B ≤ B + E := le_add_of_nonneg_right (Real.exp_pos _).le
      _ ≤ (B + E) * T ^ ε := le_mul_of_one_le_right
        (add_nonneg hB (Real.exp_pos _).le) hpow

end Ratioque.CrystalBridge.C3

end

noncomputable section

namespace Ratioque.CrystalBridge

/-- C3 of the all-characters converse, including principal and imprimitive characters. -/
theorem inv_LFunction_subpolynomial_of_everyCharacter (h : EveryCharacter)
    {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N) {ε η : ℝ} (hε : 0 < ε) (hη : 0 < η) :
    ∃ C : ℝ, 0 < C ∧ ∀ s : ℂ, (1 / 2 : ℝ) + η ≤ s.re → s.re ≤ 2 → 1 ≤ |s.im| →
      ‖(DirichletCharacter.LFunction χ s)⁻¹‖ ≤ C * (1 + |s.im|) ^ ε := by
  exact C3.of_disk_family h χ (C3.disk_family h χ) hε hη

#print axioms inv_LFunction_subpolynomial_of_everyCharacter

end Ratioque.CrystalBridge

end
