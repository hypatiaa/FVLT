import Ruliology.CellularAutomata.Rule30Jen
import FVLTWovenEvolutionV1
import FVLTFiniteStateObstructionV1
import FVLTWovenCylinderV1

/-! Explicit identification with the kit's actual single-seed Rule30 dynamics.
The kit module retains its separately reviewed generated-helper qualification.
This module's own declarations are subject to strict replay. -/
namespace FVLT.WovenKitBridgeV1
open WovenEvolutionV1
open Ruliology.CellularAutomata

theorem infinite_eq_kit (t : ℕ) (i : ℤ) : infinite t i=Rule30Jen.cell t i := by
  induction t generalizing i with
  | zero => rfl
  | succ t ih =>
    change rule (infinite t (i-1)) (infinite t i) (infinite t (i+1))=
      Rule30Jen.rule (Rule30Jen.cell t (i-1)) (Rule30Jen.cell t i) (Rule30Jen.cell t (i+1))
    rw [ih, ih, ih]
    rfl

theorem kit_no_two_periodic :
    ¬ (FiniteStateObstructionV1.EventuallyPeriodic (fun t=>infinite t 0) ∧
      FiniteStateObstructionV1.EventuallyPeriodic (fun t=>infinite t 1)) := by
  rintro ⟨h0,h1⟩
  apply Rule30Jen.not_adjacent 0
  · simpa only [FiniteStateObstructionV1.EventuallyPeriodic, infinite_eq_kit,
      Rule30Jen.EventuallyPeriodic] using h0
  · simpa only [FiniteStateObstructionV1.EventuallyPeriodic, infinite_eq_kit,
      Rule30Jen.EventuallyPeriodic, zero_add] using h1

theorem growing_weave_eq_kit (L : ℕ → ℕ) (hpos : ∀t,0<L t)
    (hcap : ∀t,2*t+1≤L t) (hgap : ∀t,L (t+1)/2+t+1<L t)
    (t : ℕ) (i : ℤ) (hi : |i|≤(t : ℤ)) : weave L t i=Rule30Jen.cell t i := by
  rw [weave_eq_infinite_core L hpos hcap hgap t i hi, infinite_eq_kit]

theorem fixed_cylinder_arbitrarily_late_kit_mismatch (L : ℕ) [NeZero L] (T : ℕ) :
    ∃t, T≤t ∧ ∃i : ℤ, |i|≤(t : ℤ) ∧
      weave (fun _=>L) t i ≠ Rule30Jen.cell t i := by
  simpa only [infinite_eq_kit] using
    WovenCylinderV1.fixed_cylinder_arbitrarily_late_mismatch L infinite kit_no_two_periodic T

end FVLT.WovenKitBridgeV1
