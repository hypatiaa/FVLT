import CoherentEnergyRotatedCentre
import R5SimpleZeroResonance

/-!
# Statement pins for R5 simple-zero and off-zero rotated energy resonance (`B = 1`, `σ = 1/2`)

Pure Mathlib-level restatements (`rfl` / definitional agreement with repository definitions)
pinning T1, T2, T3 (`m = 1` simple zero), and T3' (`m = 0` off-zero) from
`R5_ENERGY_SCAN_CODEX_20261123/RESONANCE.md`, `R5_SKELETON_RECHECK_v0_1_20261123/RECHECK.md`,
and `R5_DENSE_SCAN_v0_1_20261123/REPORT.md` (`#2209`, `#2212`, `#2213`).
-/

open scoped BigOperators ENNReal
open Filter MeasureTheory

namespace RHConnections.R5ResonancePins

/-! ## Independent Mathlib-level definitions -/

noncomputable def mertensFn (n : ℕ) : ℝ :=
  ∑ j ∈ Finset.Icc 1 n, (ArithmeticFunction.moebius j : ℝ)

noncomputable def wProdFn (w : ℕ → ℂ) (m : ℕ) : ℂ :=
  ∏ p ∈ m.primeFactors, w p ^ m.factorization p

noncomputable def scalarWFn (w : ℕ → ℂ) (B n : ℕ) : ℂ :=
  ∑ k ∈ (Finset.Icc 1 n).filter (fun k => Nat.Coprime k B), (mertensFn (n / k) : ℂ) * wProdFn w k

noncomputable def weightWFn (w : ℕ → ℂ) (r : ℕ) : ℝ :=
  ∏ p ∈ r.primeFactors, (1 - ‖w p‖ ^ 2)

noncomputable def energyWFn (w : ℕ → ℂ) (B X : ℕ) : ℝ :=
  ∑ r ∈ (Finset.Icc 1 X).filter (fun r => Nat.Coprime r B), weightWFn w r * ‖scalarWFn w B (X / r)‖ ^ 2

noncomputable def poissonWFn (w : ℕ → ℂ) (p : ℕ) : Measure ℝ :=
  if p.Prime ∧ ‖w p‖ < 1 then
    (volume.restrict (Set.Ioc 0 (2 * Real.pi))).withDensity fun θ =>
      ENNReal.ofReal ((2 * Real.pi)⁻¹ *
        ((1 - ‖w p‖ ^ 2) / ‖Complex.exp (Complex.I * (θ : ℂ)) - w p‖ ^ 2))
  else Measure.dirac 0

noncomputable def nuWFn (w : ℕ → ℂ) : Measure (ℕ → ℝ) :=
  Measure.infinitePi (poissonWFn w)

noncomputable def wSigmaTFn (σ t : ℝ) (p : ℕ) : ℂ :=
  if p = 0 then 0 else (p : ℂ) ^ (-(⟨σ, t⟩ : ℂ))

noncomputable def phasorMonomialFn (d : ℕ) (θ : ℕ → ℝ) : ℂ :=
  ∏ p ∈ d.primeFactors, Complex.exp (Complex.I * (θ p : ℂ)) ^ d.factorization p

noncomputable def windowFn (B X n : ℕ) : ℝ :=
  ∑ b ∈ (∏ p ∈ B.primeFactors, p).divisors,
    if n ≤ X / b then (ArithmeticFunction.moebius b : ℝ) else 0

noncomputable def polyFn (B X : ℕ) (θ : ℕ → ℝ) : ℂ :=
  ∑ n ∈ (Finset.Icc 1 X).filter (fun n => Nat.Coprime n B),
    (windowFn B X n : ℂ) *
      ∑ d ∈ n.divisors, (ArithmeticFunction.moebius (n / d) : ℂ) * phasorMonomialFn d θ

noncomputable def sCritFn (t : ℝ) : ℂ := ⟨1 / 2, t⟩

noncomputable def uZeroFn (t : ℝ) : ℂ := ⟨1 / 2, -t⟩

noncomputable def S_tFn (t : ℝ) (x : ℝ) : ℂ :=
  if x < 1 then 0 else scalarWFn (wSigmaTFn (1 / 2) t) 1 ⌊x⌋₊

noncomputable def E_tFn (t : ℝ) (x : ℝ) : ℝ :=
  if x < 1 then 0 else energyWFn (wSigmaTFn (1 / 2) t) 1 ⌊x⌋₊

noncomputable def J_hFn (h : ℝ) : ℝ :=
  ∑' r : ℕ, (r.totient : ℝ) / (r : ℝ) ^ (2 + h)

/-! ## Definitional agreement with repository definitions -/

theorem wProdFn_eq (w : ℕ → ℂ) (m : ℕ) :
    wProdFn w m = RHConnections.CoherentEnergyRotated.wProd w m := rfl

theorem weightWFn_eq (w : ℕ → ℂ) (r : ℕ) :
    weightWFn w r = RHConnections.CoherentEnergyRotated.jWeightC w r := rfl

theorem nuWFn_eq (w : ℕ → ℂ) :
    nuWFn w = RHConnections.CoherentEnergyRotated.primeTorusMeasureC w := rfl

theorem wSigmaTFn_eq (σ t : ℝ) :
    wSigmaTFn σ t = RHConnections.CoherentEnergyRotated.wSigmaT σ t := rfl

theorem polyFn_eq (B X : ℕ) :
    polyFn B X = RHConnections.CoherentEnergyMeasure.D B X := rfl

theorem mertensFn_eq (n : ℕ) :
    mertensFn n = RHConnections.CoherentEnergyMeasure.mertens n := by
  unfold mertensFn RHConnections.CoherentEnergyMeasure.mertens
  have h : Finset.Icc 1 n = Finset.Ioc 0 n := by
    ext k; simp only [Finset.mem_Icc, Finset.mem_Ioc]; omega
  rw [h]

theorem scalarWFn_eq (w : ℕ → ℂ) (B n : ℕ) :
    scalarWFn w B n = RHConnections.CoherentEnergyRotated.scalarSC w B n := by
  unfold scalarWFn RHConnections.CoherentEnergyRotated.scalarSC
  simp only [mertensFn_eq, wProdFn_eq]

theorem energyWFn_eq (w : ℕ → ℂ) (B X : ℕ) :
    energyWFn w B X = RHConnections.CoherentEnergyRotated.energyC w B X := by
  unfold energyWFn RHConnections.CoherentEnergyRotated.energyC
  refine Finset.sum_congr rfl fun r _ => ?_
  rw [weightWFn_eq, scalarWFn_eq]

theorem sCritFn_eq (t : ℝ) : sCritFn t = RHConnections.R5Resonance.sCrit t := rfl

theorem uZeroFn_eq (t : ℝ) : uZeroFn t = RHConnections.R5Resonance.uZero t := rfl

theorem S_tFn_eq (t : ℝ) (x : ℝ) : S_tFn t x = RHConnections.R5Resonance.S_t t x := by
  unfold S_tFn RHConnections.R5Resonance.S_t
  simp only [scalarWFn_eq, wSigmaTFn_eq]

theorem E_tFn_eq (t : ℝ) (x : ℝ) : E_tFn t x = RHConnections.R5Resonance.E_t t x := by
  unfold E_tFn RHConnections.R5Resonance.E_t
  simp only [energyWFn_eq, wSigmaTFn_eq]

theorem J_hFn_eq (h : ℝ) : J_hFn h = RHConnections.R5Resonance.J_h h := rfl

/-! ## Pinned headline theorems (T1, T2, T3, T3') -/

/-- Rotated weight `jWeightC (wSigmaT (1/2) t) r` equals `φ(r) / r` for `r ≥ 1`. -/
theorem pin_jWeightC_totient_div {r : ℕ} (hr : 1 ≤ r) (t : ℝ) :
    weightWFn (wSigmaTFn (1 / 2) t) r = (r.totient : ℝ) / (r : ℝ) := by
  rw [weightWFn_eq, wSigmaTFn_eq]
  exact RHConnections.R5Resonance.jWeightC_wSigmaT_half_eq_totient_div hr t

/-- T1: Mellin identity `∫_{1}^{∞} S_t(x) x^{-(u+1)} dx = ζ(u + s) / (u ζ(u))` for `Re u > 1`. -/
theorem pin_T1_mellin_S_eq_zeta_div (t : ℝ) {u : ℂ} (hu : 1 < u.re) :
    (∫ x in Set.Ioi (1 : ℝ), S_tFn t x * (x : ℂ) ^ (-(u + 1))) =
      riemannZeta (u + sCritFn t) / (u * riemannZeta u) := by
  simp_rw [S_tFn_eq, sCritFn_eq]
  exact RHConnections.R5Resonance.mellin_S_eq_zeta_div t hu

/-- T2 (series factor): `∑' r, φ(r) / r^(2 + h) = ζ(1 + h) / ζ(2 + h)` for `h > 0`. -/
theorem pin_T2_totient_LSeries_eq_zeta_div {h : ℝ} (hh : 0 < h) :
    (J_hFn h : ℂ) = riemannZeta (1 + (h : ℂ)) / riemannZeta (2 + (h : ℂ)) := by
  rw [J_hFn_eq]
  exact RHConnections.R5Resonance.totient_LSeries_eq_zeta_div hh

/-- T2 (Tonelli identity in `ℝ≥0∞`): `∫⁻ E_t(x) x^(-2-h) dx = J(h) ∫⁻ |S_t(y)|² y^(-2-h) dy`. -/
theorem pin_T2_lintegral_E_eq_J_mul_lintegral_S_sq (t : ℝ) {h : ℝ} (hh : 0 < h) :
    (∫⁻ x in Set.Ioi (1 : ℝ), ENNReal.ofReal (E_tFn t x * x ^ (-2 - h))) =
      ENNReal.ofReal (J_hFn h) *
        ∫⁻ y in Set.Ioi (1 : ℝ), ENNReal.ofReal (‖S_tFn t y‖ ^ 2 * y ^ (-2 - h)) := by
  simp_rw [E_tFn_eq, J_hFn_eq, S_tFn_eq]
  exact RHConnections.R5Resonance.lintegral_E_eq_J_mul_lintegral_S_sq t hh

/-- T3 (eventual-bound form): `E_t(N) ≤ K N (log N)^3` forces `K ≥ 2 / (π² |u₀ ζ'(u₀)|²)`. -/
theorem pin_T3_simple_zero_energy_eventually_le_lower (t : ℝ)
    (hz : riemannZeta (uZeroFn t) = 0) (hdz : deriv riemannZeta (uZeroFn t) ≠ 0)
    {K : ℝ} (hK : 0 < K)
    (hev : ∀ᶠ N : ℕ in atTop, energyWFn (wSigmaTFn (1 / 2) t) 1 N ≤ K * (N : ℝ) * (Real.log N) ^ 3) :
    2 / (Real.pi ^ 2 * ‖uZeroFn t * deriv riemannZeta (uZeroFn t)‖ ^ 2) ≤ K := by
  simp_rw [uZeroFn_eq, energyWFn_eq, wSigmaTFn_eq] at hz hdz hev ⊢
  exact RHConnections.R5Resonance.simple_zero_energy_eventually_le_lower t hz hdz hK hev

/-- T3 (headline): unconditionally, at any simple zero `u₀ = 1/2 - it`,
`limsup_{N → ∞} E_t(N) / (N (log N)^3) ≥ 2 / (π² |u₀ ζ'(u₀)|²)`. -/
theorem pin_T3_simple_zero_energy_limsup_ge (t : ℝ)
    (hz : riemannZeta (uZeroFn t) = 0) (hdz : deriv riemannZeta (uZeroFn t) ≠ 0) :
    ENNReal.ofReal (2 / (Real.pi ^ 2 * ‖uZeroFn t * deriv riemannZeta (uZeroFn t)‖ ^ 2)) ≤
      Filter.limsup
        (fun N : ℕ => ENNReal.ofReal (energyWFn (wSigmaTFn (1 / 2) t) 1 N / ((N : ℝ) * (Real.log N) ^ 3)))
        atTop := by
  simp_rw [uZeroFn_eq, energyWFn_eq, wSigmaTFn_eq] at hz hdz ⊢
  exact RHConnections.R5Resonance.simple_zero_energy_limsup_ge t hz hdz

/-- T3 (torus-integral form): same lower bound expressed directly as `∫ ω, ‖D 1 N ω‖² ∂ν_{1/2, t}`. -/
theorem pin_T3_simple_zero_torus_energy_limsup_ge (t : ℝ)
    (hz : riemannZeta (uZeroFn t) = 0) (hdz : deriv riemannZeta (uZeroFn t) ≠ 0) :
    ENNReal.ofReal (2 / (Real.pi ^ 2 * ‖uZeroFn t * deriv riemannZeta (uZeroFn t)‖ ^ 2)) ≤
      Filter.limsup
        (fun N : ℕ => ENNReal.ofReal
          ((∫ ω, ‖polyFn 1 N ω‖ ^ 2 ∂(nuWFn (wSigmaTFn (1 / 2) t))) /
            ((N : ℝ) * (Real.log N) ^ 3)))
        atTop := by
  simp_rw [uZeroFn_eq, polyFn_eq, nuWFn_eq, wSigmaTFn_eq] at hz hdz ⊢
  exact RHConnections.R5Resonance.simple_zero_torus_energy_limsup_ge t hz hdz

/-- T3' (eventual-bound form): when `ζ(u₀) ≠ 0`, `E_t(N) ≤ K N log N` forces `K ≥ 6 / (π² |u₀ ζ(u₀)|²)`. -/
theorem pin_T3p_off_zero_energy_eventually_le_lower (t : ℝ) (hnz : riemannZeta (uZeroFn t) ≠ 0)
    {K : ℝ} (hK : 0 < K)
    (hev : ∀ᶠ N : ℕ in atTop, energyWFn (wSigmaTFn (1 / 2) t) 1 N ≤ K * (N : ℝ) * Real.log N) :
    6 / (Real.pi ^ 2 * ‖uZeroFn t * riemannZeta (uZeroFn t)‖ ^ 2) ≤ K := by
  simp_rw [uZeroFn_eq, energyWFn_eq, wSigmaTFn_eq] at hnz hev ⊢
  exact RHConnections.R5Resonance.off_zero_energy_eventually_le_lower t hnz hK hev

/-- T3' (off-zero `limsup` lower bound matching `1 / (ζ(2) |u₀ ζ(u₀)|²)`). -/
theorem pin_T3p_off_zero_energy_limsup_ge (t : ℝ) (hnz : riemannZeta (uZeroFn t) ≠ 0) :
    ENNReal.ofReal (6 / (Real.pi ^ 2 * ‖uZeroFn t * riemannZeta (uZeroFn t)‖ ^ 2)) ≤
      Filter.limsup
        (fun N : ℕ => ENNReal.ofReal (energyWFn (wSigmaTFn (1 / 2) t) 1 N / ((N : ℝ) * Real.log N)))
        atTop := by
  simp_rw [uZeroFn_eq, energyWFn_eq, wSigmaTFn_eq] at hnz ⊢
  exact RHConnections.R5Resonance.off_zero_energy_limsup_ge t hnz

/-- T3' (torus-integral form): same off-zero lower bound expressed via `primeTorusMeasureC` and `D`. -/
theorem pin_T3p_off_zero_torus_energy_limsup_ge (t : ℝ) (hnz : riemannZeta (uZeroFn t) ≠ 0) :
    ENNReal.ofReal (6 / (Real.pi ^ 2 * ‖uZeroFn t * riemannZeta (uZeroFn t)‖ ^ 2)) ≤
      Filter.limsup
        (fun N : ℕ => ENNReal.ofReal
          ((∫ ω, ‖polyFn 1 N ω‖ ^ 2 ∂(nuWFn (wSigmaTFn (1 / 2) t))) /
            ((N : ℝ) * Real.log N)))
        atTop := by
  simp_rw [uZeroFn_eq, polyFn_eq, nuWFn_eq, wSigmaTFn_eq] at hnz ⊢
  exact RHConnections.R5Resonance.off_zero_torus_energy_limsup_ge t hnz

end RHConnections.R5ResonancePins

#print axioms RHConnections.R5ResonancePins.pin_jWeightC_totient_div
#print axioms RHConnections.R5ResonancePins.pin_T1_mellin_S_eq_zeta_div
#print axioms RHConnections.R5ResonancePins.pin_T2_totient_LSeries_eq_zeta_div
#print axioms RHConnections.R5ResonancePins.pin_T2_lintegral_E_eq_J_mul_lintegral_S_sq
#print axioms RHConnections.R5ResonancePins.pin_T3_simple_zero_energy_eventually_le_lower
#print axioms RHConnections.R5ResonancePins.pin_T3_simple_zero_energy_limsup_ge
#print axioms RHConnections.R5ResonancePins.pin_T3_simple_zero_torus_energy_limsup_ge
#print axioms RHConnections.R5ResonancePins.pin_T3p_off_zero_energy_eventually_le_lower
#print axioms RHConnections.R5ResonancePins.pin_T3p_off_zero_energy_limsup_ge
#print axioms RHConnections.R5ResonancePins.pin_T3p_off_zero_torus_energy_limsup_ge
