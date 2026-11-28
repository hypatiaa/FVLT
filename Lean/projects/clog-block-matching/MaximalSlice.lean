import DirectProgressions

namespace AtlasLog
open Finset MeasureTheory ArithmeticFunction
open scoped ArithmeticFunction.Moebius
noncomputable section

/-- A finite progression presented by its step, residue, and endpoints. -/
def FiniteProgression (P : Finset ℕ) : Prop :=
  ∃ a b q r : ℕ, 0<q ∧ r<q ∧ P=(Ioc a b).filter (fun n => n%q=r)

/-- Equation (1.4) written as a bound for each progression under the same
exceptional set, with F=1, logarithmic exponent 1, and ε=1/12. -/
def ConstantMaximalEstimate : Prop :=
  ∃ C : ℝ, 0<C ∧ ∃ M₀ : ℕ, ∀ M ≥ M₀, ∀ h : ℕ,
    (M:ℝ)^(5/12:ℝ) ≤ h → (h:ℝ) ≤ (M:ℝ)^(11/12:ℝ) →
    ∃ E : Set ℝ, volume E ≤ ENNReal.ofReal (C*M/Real.log M) ∧
      ∀ x ∈ Set.Icc (M:ℝ) (2*M), x ∉ E → ∀ P : Finset ℕ,
        FiniteProgression P → (∀ n ∈ P, x<n ∧ (n:ℝ)≤x+h) →
        |∑ n ∈ P, (μ n : ℝ)| ≤ C*h/Real.log M

theorem four_from_maximal (paper : ConstantMaximalEstimate) : AP12Measure := by
  apply ap12_of_constant_progressions
  obtain ⟨C,hC,M₀,bound⟩ := paper
  refine ⟨C,hC,M₀,?_⟩
  intro M hM h lo hi
  obtain ⟨E,size,good⟩ := bound M hM h lo hi
  refine ⟨E,size,?_⟩
  intro x xb xe q hq r hr
  have hx : 0≤x := (by positivity : 0≤(M:ℝ)).trans xb.1
  let P := (Ioc ⌊x⌋₊ (⌊x⌋₊+h)).filter (fun n => n%q=r)
  have hp : FiniteProgression P := ⟨_,_,q,r,hq,hr,rfl⟩
  have fits (n : ℕ) (hn : n ∈ P) := (real_interval_membership n h hx).mp (mem_filter.mp hn).1
  simpa [P,windowSum,Nat.floor_add_natCast hx,Finset.sum_filter] using good x xb xe P hp fits

end
end AtlasLog
