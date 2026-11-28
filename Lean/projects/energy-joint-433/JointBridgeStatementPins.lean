import CoherentEnergyRHBridge

/-!
# Dual-environment statement pins for `CoherentEnergyRHBridge` (`Lean 4.33.1` and `Lean 4.35.0`)

Defines pure-Mathlib copies of the measure-bridge objects and proves `rfl` agreement with
`RHConnections.CoherentEnergyMeasure.*`, then pins both headline bridge theorems verbatim.
Compiled with identical source bytes in BOTH:
1. Alpöge's Lean `4.33.1` / Mathlib `0df444a3` environment (`out433`), and
2. Upstream Lean `4.35.0` / Mathlib `56a00585` against untouched `CoherentEnergyRHBridge.olean`.
-/

noncomputable section
open scoped BigOperators ENNReal NNReal
open MeasureTheory

namespace JointBridgeStatementPins

def poissonKernelPin (ρ θ : ℝ) : ℝ :=
  (1 - ρ ^ 2) / (1 - 2 * ρ * Real.cos θ + ρ ^ 2)

def poissonDensityNNPin (p : ℕ) (θ : ℝ) : ℝ≥0 :=
  Real.toNNReal ((2 * Real.pi)⁻¹ * poissonKernelPin ((p : ℝ)⁻¹) θ)

def poissonMeasurePin (p : ℕ) : Measure ℝ :=
  if p.Prime then
    (volume.restrict (Set.Ioc 0 (2 * Real.pi))).withDensity
      (fun θ => (poissonDensityNNPin p θ : ℝ≥0∞))
  else
    Measure.dirac 0

def primeTorusMeasurePin : Measure (ℕ → ℝ) :=
  Measure.infinitePi poissonMeasurePin

def phasorPin (p : ℕ) (ω : ℕ → ℝ) : ℂ :=
  Complex.exp (Complex.I * (ω p : ℂ))

def ZPin (n : ℕ) (ω : ℕ → ℝ) : ℂ :=
  ∏ p ∈ n.primeFactors, phasorPin p ω ^ n.factorization p

def mobiusLiftPin (N : ℕ) (ω : ℕ → ℝ) : ℂ :=
  ∑ d ∈ N.divisors, (ArithmeticFunction.moebius (N / d) : ℂ) * ZPin d ω

def radPin (B : ℕ) : ℕ :=
  ∏ p ∈ B.primeFactors, p

def sievingWindowPin (B X n : ℕ) : ℝ :=
  ∑ b ∈ (radPin B).divisors, if n ≤ X / b then (ArithmeticFunction.moebius b : ℝ) else 0

def DPin (B X : ℕ) (ω : ℕ → ℝ) : ℂ :=
  ∑ n ∈ (Finset.Icc 1 X).filter (fun n => Nat.Coprime n B),
    (sievingWindowPin B X n : ℂ) * mobiusLiftPin n ω

theorem poissonKernelPin_eq :
    poissonKernelPin = RHConnections.CoherentEnergyMeasure.poissonKernel := rfl

theorem poissonDensityNNPin_eq :
    poissonDensityNNPin = RHConnections.CoherentEnergyMeasure.poissonDensityNN := rfl

theorem poissonMeasurePin_eq :
    poissonMeasurePin = RHConnections.CoherentEnergyMeasure.poissonMeasure := rfl

theorem primeTorusMeasurePin_eq :
    primeTorusMeasurePin = RHConnections.CoherentEnergyMeasure.primeTorusMeasure := rfl

theorem phasorPin_eq :
    phasorPin = RHConnections.CoherentEnergyMeasure.phasor := rfl

theorem ZPin_eq :
    ZPin = RHConnections.CoherentEnergyMeasure.Z := rfl

theorem mobiusLiftPin_eq :
    mobiusLiftPin = RHConnections.CoherentEnergyMeasure.mobiusLift := rfl

theorem radPin_eq :
    radPin = RHConnections.CoherentEnergyMeasure.rad := rfl

theorem sievingWindowPin_eq :
    sievingWindowPin = RHConnections.CoherentEnergyMeasure.sievingWindow := rfl

theorem DPin_eq :
    DPin = RHConnections.CoherentEnergyMeasure.D := rfl

theorem pin_coherent_energy_measure_growth_iff_RH {B : ℕ} (hB : 1 ≤ B) :
    (∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧
        ∀ X : ℕ, 1 ≤ X →
          ∫ ω, ‖DPin B X ω‖ ^ 2 ∂primeTorusMeasurePin ≤ C * (X : ℝ) ^ (1 + δ)) ↔
      _root_.RiemannHypothesis := by
  rw [DPin_eq, primeTorusMeasurePin_eq]
  exact RHConnections.CoherentEnergyMeasure.coherent_energy_measure_growth_iff_RH hB

theorem pin_fixed_strip_iff_coherent_energy_measure_power {B : ℕ} (hB : 1 ≤ B)
    {a : ℝ} (ha : 1 / 2 ≤ a) (ha1 : a < 1) :
    (∀ s : ℂ, a < s.re → riemannZeta s ≠ 0) ↔
      (∀ ε : ℝ, 0 < ε → ∃ C : ℝ, 0 ≤ C ∧
        ∀ X : ℕ, 1 ≤ X →
          ∫ ω, ‖DPin B X ω‖ ^ 2 ∂primeTorusMeasurePin ≤ C * (X : ℝ) ^ (2 * a + ε)) := by
  rw [DPin_eq, primeTorusMeasurePin_eq]
  exact RHConnections.CoherentEnergyMeasure.fixed_strip_iff_coherent_energy_measure_power hB ha ha1

end JointBridgeStatementPins

#print axioms JointBridgeStatementPins.pin_coherent_energy_measure_growth_iff_RH
#print axioms JointBridgeStatementPins.pin_fixed_strip_iff_coherent_energy_measure_power
