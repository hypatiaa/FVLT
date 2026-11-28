import CrystalBridge
import Verified

/-! # C4. Twisted Mertens cancellation from reciprocal growth

This module specializes the arithmetic-Fourier library's Perron ramp to the
Möbius coefficients twisted by a Dirichlet character. It removes the principal
character's singularity from the reciprocal, moves the contour with the pinned
strip-transfer theorem, and bounds the cost of recovering the sharp cutoff.
The companion module composes C1 through C4 with the original crystal bridge.
-/

noncomputable section

namespace Ratioque.CrystalBridge.C4
open Complex Set Metric

open scoped Classical in
/-- The reciprocal completed at the principal character's simple pole. -/
def reciprocal {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N) (s : ℂ) : ℂ :=
  if χ = 1 then (s-1) / DirichletCharacter.LFunctionTrivChar₁ N s
  else (DirichletCharacter.LFunction χ s)⁻¹

theorem reciprocal_eq {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N)
    {s : ℂ} (hs : s ≠ 1) : reciprocal χ s = (DirichletCharacter.LFunction χ s)⁻¹ := by
  classical
  by_cases hχ : χ = 1
  · subst χ
    rw [reciprocal, if_pos rfl, DirichletCharacter.LFunctionTrivChar₁, Function.update_of_ne hs]
    change (s-1) / ((s-1) * DirichletCharacter.LFunction 1 s) = _
    rw [div_mul_eq_div_div, div_self (sub_ne_zero.mpr hs), one_div]
  · simp [reciprocal, hχ]

theorem reciprocal_analytic {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N)
    (hnz : ∀ s : ℂ, (1/2 : ℝ) < s.re → (χ ≠ 1 ∨ s ≠ 1) → DirichletCharacter.LFunction χ s ≠ 0)
    {s : ℂ} (hs : 1/2 < s.re) : AnalyticAt ℂ (reciprocal χ) s := by
  classical
  by_cases hχ : χ = 1
  · subst χ
    have ha := (DirichletCharacter.differentiable_LFunctionTrivChar₁ N).analyticAt (z := s)
    have hne : DirichletCharacter.LFunctionTrivChar₁ N s ≠ 0 := by
      rcases eq_or_ne s 1 with rfl | h1
      · exact DirichletCharacter.LFunctionTrivChar₁_apply_one_ne_zero N
      · rw [DirichletCharacter.LFunctionTrivChar₁, Function.update_of_ne h1]
        exact mul_ne_zero (sub_ne_zero.mpr h1) (hnz s hs (.inr h1))
    have he : reciprocal (1 : DirichletCharacter ℂ N) = fun z => (z-1) / DirichletCharacter.LFunctionTrivChar₁ N z := by
      funext z
      simp [reciprocal]
    rw [he]
    exact (show AnalyticAt ℂ (fun z : ℂ => z-1) s from analyticAt_id.sub analyticAt_const).div ha hne
  · have ha := (DirichletCharacter.differentiable_LFunction hχ).analyticAt (z := s)
    have he : reciprocal χ = fun z => (DirichletCharacter.LFunction χ z)⁻¹ := by
      funext z
      simp [reciprocal, hχ]
    rw [he]
    exact ha.inv (hnz s hs (.inl hχ))

/-- Extend the high-frequency estimate to the whole vertical strip. -/
theorem reciprocal_growth {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N)
    (hnz : ∀ s : ℂ, (1/2 : ℝ) < s.re → (χ ≠ 1 ∨ s ≠ 1) → DirichletCharacter.LFunction χ s ≠ 0)
    {d b : ℝ} (hd : 0 < d) (hb : 1/2 < b)
    (hinv : ∃ C : ℝ, 0 < C ∧ ∀ s : ℂ, b ≤ s.re → s.re ≤ 2 → 1 ≤ |s.im| →
      ‖(DirichletCharacter.LFunction χ s)⁻¹‖ ≤ C * (1 + |s.im|) ^ d) :
    ∃ D : ℝ, 0 ≤ D ∧ ∀ s : ℂ, s.re ∈ Icc b 2 →
      ‖reciprocal χ s‖ ≤ D*(1+|s.im|)^d := by
  obtain ⟨C, hC, hlarge⟩ := hinv
  let S : Set ℂ := {s | s.re ∈ Icc b 2 ∧ |s.im| ≤ 1}
  have hclosed : IsClosed S := (isClosed_Icc.preimage continuous_re).inter
    (isClosed_le continuous_im.abs continuous_const)
  have hsubset : S ⊆ closedBall (0:ℂ) 3 := by
    intro s hs
    apply mem_closedBall_zero_iff.mpr
    apply (norm_le_abs_re_add_abs_im s).trans
    rcases hs with ⟨⟨hl, hu⟩, hi⟩
    rw [abs_of_nonneg (show 0 ≤ s.re by linarith)]
    linarith
  have hc := (isCompact_closedBall (0:ℂ) 3).of_isClosed_subset hclosed hsubset
  obtain ⟨A, hA⟩ := hc.exists_bound_of_continuousOn (f := reciprocal χ)
    (fun s hs => (reciprocal_analytic χ hnz (hb.trans_le hs.1.1)).continuousAt.continuousWithinAt)
  refine ⟨max A C, hC.le.trans (le_max_right ..), ?_⟩
  intro s hs
  have hpow := Real.one_le_rpow (show 1 ≤ 1+|s.im| by linarith [abs_nonneg s.im]) hd.le
  by_cases hi : 1 ≤ |s.im|
  · have h1 : s ≠ 1 := by rintro rfl; norm_num at hi
    rw [reciprocal_eq χ h1]
    exact (hlarge s hs.1 hs.2 hi).trans
      (mul_le_mul_of_nonneg_right (le_max_right ..) (zero_le_one.trans hpow))
  · exact (hA s ⟨hs, le_of_not_ge hi⟩).trans ((le_max_left ..).trans
      (le_mul_of_one_le_right (hC.le.trans (le_max_right A C)) hpow))

end Ratioque.CrystalBridge.C4

end

noncomputable section

/-! Specialization of the arithmetic Fourier library's smoothed Perron
identity to the Dirichlet-character twist of the Möbius coefficients. -/


namespace Ratioque.CrystalBridge.C4

open MeasureTheory RHConnections.PerronRamp RHConnections.PerronGrowthTransfer

/-- Absolute convergence gives the reciprocal on the initial line, independently
of the cancellation hypothesis. -/
theorem twisted_lseries_eq_inv {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N)
    {s : ℂ} (hs : 1 < s.re) :
    LSeries (twistedCoeff χ) s = (DirichletCharacter.LFunction χ s)⁻¹ := by
  have he : DirichletCharacter.LFunction χ s * LSeries (twistedCoeff χ) s = 1 := by
    rw [DirichletCharacter.LFunction_eq_LSeries χ hs, twistedCoeff_eq_LSeries_mul]
    exact DirichletCharacter.LSeries.mul_mu_eq_one χ hs
  have hn : DirichletCharacter.LFunction χ s ≠ 0 := by
    intro h
    simp [h] at he
  rw [← one_div, eq_div_iff hn, mul_comm]
  exact he

/-- On the initial line of real part 2, integrate any representative of the
reciprocal that agrees with the absolutely convergent Euler series. -/
theorem smoothed_twisted_euler {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N)
    (G : ℂ → ℂ) (hG : ∀ s : ℂ, 1 < s.re → G s = (DirichletCharacter.LFunction χ s)⁻¹)
    {h X : ℝ} (hh : 0 < h) (hX : 0 < X) :
    smoothedLSeries (twistedCoeff χ) h X =
      ∫ v : ℝ, integrand G h X (probe 2 v) := by
  have hsum : LSeriesSummable (twistedCoeff χ) (2 : ℂ) := by
    rw [twistedCoeff_eq_LSeries_mul]
    exact DirichletCharacter.LSeriesSummable_mul χ
      (ArithmeticFunction.LSeriesSummable_moebius_iff.mpr (by norm_num))
  rw [smoothedLSeries_eq_euler_integral (twistedCoeff χ) (by simp [twistedCoeff]) hh
    (by norm_num : (0 : ℝ) < 2) hX hsum]
  apply integral_congr_ae
  refine ae_of_all _ fun v => ?_
  have hs : 1 < (probe 2 v).re := by rw [probe_re]; norm_num
  change LSeries (twistedCoeff χ) (probe 2 v) * (X : ℂ) ^ (probe 2 v) * kernel h (probe 2 v) =
    G (probe 2 v) * (X : ℂ) ^ (probe 2 v) * kernel h (probe 2 v)
  rw [twisted_lseries_eq_inv χ hs, hG _ hs]

end Ratioque.CrystalBridge.C4

end

noncomputable section

/-! Removing the logarithmic ramp costs only the number of integers in its transition region.
The estimate is uniform for coefficients of norm at most one. -/

namespace Ratioque.CrystalBridge.C4
open RHConnections.PerronRamp

/-- Uniform unsmoothing error for coefficients bounded by one, with the zeroth term omitted. -/
theorem smoothed_sum_error (a : ℕ → ℂ) (ha₀ : a 0 = 0) (hcoeff : ∀ n, ‖a n‖ ≤ 1)
    {X h : ℝ} (hX : 1 ≤ X) (hh : 0 < h) (hh₁ : h ≤ 1) :
    ‖smoothedLSeries a h X - (∑ k ∈ Finset.Icc 1 ⌊X⌋₊, a k)‖ ≤ 3*(X*h+1) := by
  classical
  let L := X*Real.exp (-h)
  let U := X*Real.exp h
  let T := Finset.Icc 1 ⌊U⌋₊
  let J := Finset.Ioc ⌊L⌋₊ ⌊U⌋₊
  let A (n : ℕ) := a n * (ramp h (Real.log X-Real.log n) : ℂ)
  let D (n : ℕ) := if n ∈ Finset.Icc 1 ⌊X⌋₊ then a n else 0
  have hx : 0 < X := by linarith
  have hl : 0 < L := mul_pos hx (Real.exp_pos _)
  have hL : L ≤ X := by
    simpa only [mul_one] using mul_le_mul_of_nonneg_left
      (Real.exp_le_one_iff.mpr (neg_nonpos.mpr hh.le)) hx.le
  have hU : X ≤ U := by
    simpa only [mul_one] using mul_le_mul_of_nonneg_left (Real.one_le_exp_iff.mpr hh.le) hx.le
  have hu : 0 < U := hx.trans_le hU
  have hupper (n : ℕ) (hn : ⌊U⌋₊ < n) : A n = 0 := by
    have hnU : U < (n:ℝ) := (Nat.floor_lt hu.le).mp hn
    have hlog := Real.log_le_log hu hnU.le
    have hUlog : Real.log U = Real.log X+h := by
      dsimp only [U]
      rw [Real.log_mul hx.ne' (Real.exp_pos _).ne',Real.log_exp]
    rw [hUlog] at hlog
    simp [A, ramp_zero hh (show Real.log X-Real.log n ≤ -h by linarith)]
  have hlower (n : ℕ) (hn : 1 ≤ n) (hnL : n ≤ ⌊L⌋₊) : A n = D n := by
    have hn' : 0 < (n:ℝ) := Nat.cast_pos.mpr (by omega)
    have hlog := Real.log_le_log hn' ((Nat.le_floor_iff hl.le).mp hnL)
    have hLlog : Real.log L = Real.log X-h := by
      dsimp only [L]
      rw [Real.log_mul hx.ne' (Real.exp_pos _).ne',Real.log_exp]
      ring
    rw [hLlog] at hlog
    have hm : n ∈ Finset.Icc 1 ⌊X⌋₊ := Finset.mem_Icc.mpr ⟨hn,hnL.trans (Nat.floor_mono hL)⟩
    simp only [A,D,if_pos hm,ramp_one hh (show h ≤ Real.log X-Real.log n by linarith),Complex.ofReal_one,mul_one]
  have hA : smoothedLSeries a h X = ∑ n ∈ T, A n := by
    apply tsum_eq_sum
    intro n hn
    by_cases hn₀ : n = 0
    · subst n
      simp [ha₀]
    · apply hupper
      exact lt_of_not_ge (fun hle => hn (Finset.mem_Icc.mpr ⟨Nat.one_le_iff_ne_zero.mpr hn₀, hle⟩))
  have hT : Finset.Icc 1 ⌊X⌋₊ ⊆ T := fun n hn =>
    Finset.mem_Icc.mpr ⟨(Finset.mem_Icc.mp hn).1,(Finset.mem_Icc.mp hn).2.trans (Nat.floor_mono hU)⟩
  have hD : (∑ k ∈ Finset.Icc 1 ⌊X⌋₊, a k) = ∑ n ∈ T, D n := by
    calc
      _ = ∑ n ∈ Finset.Icc 1 ⌊X⌋₊, D n := Finset.sum_congr rfl (fun n hn => by simp only [D,if_pos hn])
      _ = _ := Finset.sum_subset hT (fun n _ hn => by simp only [D,if_neg hn])
  have hJ : J ⊆ T := fun n hn =>
    Finset.mem_Icc.mpr ⟨by have := (Finset.mem_Ioc.mp hn).1; omega,(Finset.mem_Ioc.mp hn).2⟩
  have hdiff : smoothedLSeries a h X-(∑ k ∈ Finset.Icc 1 ⌊X⌋₊, a k) = ∑ n ∈ J, (A n-D n) := by
    rw [hA,hD,← Finset.sum_sub_distrib]
    symm
    apply Finset.sum_subset hJ
    intro n hn hnJ
    have hn' := Finset.mem_Icc.mp hn
    have hnl : n ≤ ⌊L⌋₊ := le_of_not_gt (fun h => hnJ (Finset.mem_Ioc.mpr ⟨h,hn'.2⟩))
    exact sub_eq_zero.mpr (hlower n hn'.1 hnl)
  have herr (n : ℕ) : ‖A n-D n‖ ≤ 1 := by
    let r := ramp h (Real.log X-Real.log n)
    have hr : 0 ≤ r ∧ r ≤ 1 := ramp_mem_Icc hh _
    by_cases hn : n ∈ Finset.Icc 1 ⌊X⌋₊
    · change ‖a n * (r:ℂ) - (if n ∈ Finset.Icc 1 ⌊X⌋₊ then a n else 0)‖ ≤ 1
      rw [if_pos hn, ← mul_sub_one, norm_mul, ← Complex.ofReal_one, ← Complex.ofReal_sub,
        Complex.norm_real, Real.norm_eq_abs, abs_of_nonpos (sub_nonpos.mpr hr.2)]
      exact (mul_le_mul (hcoeff n) (by linarith : -(r-1) ≤ 1) (by linarith) zero_le_one).trans_eq (one_mul _)
    · change ‖a n * (r:ℂ) - (if n ∈ Finset.Icc 1 ⌊X⌋₊ then a n else 0)‖ ≤ 1
      rw [if_neg hn, sub_zero, norm_mul, Complex.norm_of_nonneg hr.1]
      simpa only [one_mul] using mul_le_mul (hcoeff n) hr.2 hr.1 zero_le_one
  have hwidth : U-L ≤ 3*(X*h) := by
    have hep := Real.abs_exp_sub_one_le (show |h| ≤ 1 by simpa [abs_of_pos hh] using hh₁)
    have hp' := (le_abs_self (Real.exp h-1)).trans hep
    rw [abs_of_pos hh] at hp'
    have he' := Real.add_one_le_exp (-h)
    calc
      _ = X*(Real.exp h-Real.exp (-h)) := by dsimp [U,L]; ring
      _ ≤ X*(3*h) := mul_le_mul_of_nonneg_left (by linarith) hx.le
      _ = _ := by ring
  rw [hdiff]
  calc
    _ ≤ ∑ n ∈ J, ‖A n-D n‖ := norm_sum_le _ _
    _ ≤ ∑ _n ∈ J, (1:ℝ) := Finset.sum_le_sum (fun n _ => herr n)
    _ = (⌊U⌋₊:ℝ) - (⌊L⌋₊:ℝ) := by
      simp [J,Nat.cast_sub (Nat.floor_mono (hL.trans hU))]
    _ ≤ 3*(X*h+1) := by linarith [Nat.floor_le hu.le,Nat.lt_floor_add_one L]


/-- Dirichlet twists preserve the coefficient bound used to remove the ramp. -/
theorem smoothed_twistedMertens_error {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N)
    {X h : ℝ} (hX : 1 ≤ X) (hh : 0 < h) (hh₁ : h ≤ 1) :
    ‖smoothedLSeries (twistedCoeff χ) h X - twistedMertens χ X‖ ≤ 3*(X*h+1) := by
  apply smoothed_sum_error (twistedCoeff χ) (by simp [twistedCoeff]) _ hX hh hh₁
  intro k
  rw [twistedCoeff, norm_mul]
  have hm : ‖(ArithmeticFunction.moebius k : ℂ)‖ ≤ 1 := by
    rw [Complex.norm_intCast]
    exact_mod_cast (ArithmeticFunction.abs_moebius_le_one (n := k))
  simpa using mul_le_mul (χ.norm_le_one k) hm (norm_nonneg _) zero_le_one

end Ratioque.CrystalBridge.C4

end

noncomputable section

namespace Ratioque.CrystalBridge.C4

open Filter Asymptotics RHConnections.PerronRamp

/-- Choose the ramp width at the square-root scale. The displacement of the
integration line and the growth of the reciprocal together cost at most ε. -/
theorem twistedMertensCancellation_of_smoothed_bounds {N : ℕ} (χ : DirichletCharacter ℂ N)
    (hS : ∀ d : ℝ, 0 < d → d ≤ 1 / 4 →
      ∃ C : ℝ, 0 ≤ C ∧ ∀ X h : ℝ, 1 ≤ X → 0 < h → h ≤ 1 →
        ‖smoothedLSeries (twistedCoeff χ) h X‖ ≤ C * X ^ (1 / 2 + d) * h ^ (-d))
    (hE : ∀ X h : ℝ, 1 ≤ X → 0 < h → h ≤ 1 →
      ‖smoothedLSeries (twistedCoeff χ) h X - twistedMertens χ X‖ ≤ 3 * (X * h + 1)) :
    TwistedMertensCancellation χ := by
  intro ε hε
  let d := min (ε / 2) (1 / 4)
  have hd : 0 < d := lt_min (by linarith) (by norm_num)
  have hdε : d ≤ ε / 2 := min_le_left _ _
  obtain ⟨C, hC, hbound⟩ := hS d hd (min_le_right _ _)
  refine isBigO_iff.mpr ⟨C + 6, ?_⟩
  filter_upwards [eventually_ge_atTop (1 : ℝ)] with X hX
  have hXp : 0 < X := zero_lt_one.trans_le hX
  let h := X ^ (-(1 / 2 : ℝ))
  have hh : 0 < h := Real.rpow_pos_of_pos hXp _
  have hh₁ : h ≤ 1 := by
    simpa only [h, Real.rpow_zero] using Real.rpow_le_rpow_of_exponent_le hX
      (show -(1 / 2 : ℝ) ≤ 0 by norm_num)
  have hwidth : X * h = X ^ (1 / 2 : ℝ) := by
    calc
      _ = X ^ (1 : ℝ) * X ^ (-(1 / 2 : ℝ)) := by rw [Real.rpow_one]
      _ = _ := by rw [← Real.rpow_add hXp, show (1 : ℝ) + -(1 / 2) = 1 / 2 by ring]
  have hpower : h ^ (-d) = X ^ (d / 2) := by
    dsimp only [h]
    rw [← Real.rpow_mul hXp.le, show -(1 / 2 : ℝ) * (-d) = d / 2 by ring]
  have hsm := hbound X h hX hh hh₁
  rw [hpower, mul_assoc, ← Real.rpow_add hXp] at hsm
  have hmain := hsm.trans (mul_le_mul_of_nonneg_left
    (Real.rpow_le_rpow_of_exponent_le hX (show 1 / 2 + d + d / 2 ≤ 1 / 2 + ε by linarith)) hC)
  have herr := hE X h hX hh hh₁
  rw [hwidth] at herr
  have hstep := Real.rpow_le_rpow_of_exponent_le hX (show (1 / 2 : ℝ) ≤ 1 / 2 + ε by linarith)
  have hone := Real.one_le_rpow hX (show 0 ≤ 1 / 2 + ε by linarith)
  change ‖twistedMertens χ X‖ ≤ (C + 6) * ‖X ^ (1 / 2 + ε)‖
  rw [Real.norm_of_nonneg (Real.rpow_nonneg hXp.le _)]
  calc
    _ = ‖smoothedLSeries (twistedCoeff χ) h X -
        (smoothedLSeries (twistedCoeff χ) h X - twistedMertens χ X)‖ := by rw [sub_sub_cancel]
    _ ≤ _ := norm_sub_le _ _
    _ ≤ _ := by linarith

end Ratioque.CrystalBridge.C4

end

noncomputable section

namespace Ratioque.CrystalBridge
open RHConnections.PerronRamp RHConnections.PerronGrowthTransfer

/-- The reciprocal subpower estimate transfers to sharp twisted Möbius sums. -/
theorem twistedMertensCancellation_of_inv_bound {N : ℕ} [NeZero N] (χ : DirichletCharacter ℂ N)
    (hnz : ∀ s : ℂ, (1 / 2 : ℝ) < s.re → (χ ≠ 1 ∨ s ≠ 1) → DirichletCharacter.LFunction χ s ≠ 0)
    (hinv : ∀ ε η : ℝ, 0 < ε → 0 < η → ∃ C : ℝ, 0 < C ∧ ∀ s : ℂ, (1 / 2 : ℝ) + η ≤ s.re → s.re ≤ 2 →
      1 ≤ |s.im| → ‖(DirichletCharacter.LFunction χ s)⁻¹‖ ≤ C * (1 + |s.im|) ^ ε) :
    TwistedMertensCancellation χ := by
  apply C4.twistedMertensCancellation_of_smoothed_bounds χ
  · intro d hd hd₁
    let b : ℝ := 1/2 + d
    have hb : 1/2 < b := by dsimp [b]; linarith
    have hb₂ : b ≤ 2 := by dsimp [b]; linarith
    obtain ⟨D, hD, hG⟩ := C4.reciprocal_growth χ hnz hd hb (hinv d d hd hd)
    have hA : AnalyticOnNhd ℂ (C4.reciprocal χ) {s : ℂ | s.re ∈ Set.Icc b 2} :=
      fun _ hs => C4.reciprocal_analytic χ hnz (hb.trans_le hs.1)
    obtain ⟨C, hC, hbound⟩ := euler_integral_bound_of_strip_growth (by linarith : 0 < b)
      hb₂ hd (by linarith : d < 1) hD hA hG
    refine ⟨C, hC, ?_⟩
    intro X h hX hh hh₁
    rw [C4.smoothed_twisted_euler χ (C4.reciprocal χ) (fun s hs => C4.reciprocal_eq χ
      (by rintro rfl; norm_num at hs)) hh (zero_lt_one.trans_le hX)]
    exact hbound X h hX hh hh₁
  · exact fun _ _ hX hh hh₁ => C4.smoothed_twistedMertens_error χ hX hh hh₁

#print axioms twistedMertensCancellation_of_inv_bound

end Ratioque.CrystalBridge

end
