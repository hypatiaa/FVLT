import Main
import CrystalBridgeConverse
import FranelEnergy
import FranelMertensBound

/-! # Compose: Alpöge's kernel-checked `allChi` / `rhOfAll` with our equivalences

`allChi : UpperTheory.EveryCharacter` and `rhOfAll : RiemannHypothesis` are taken from
Levent Alpöge's tree (module `Main`, via `Supplements.Kernels.MainTheorems`).
`allChiVCancellation_iff_everyCharacter` (module `CrystalBridgeConverse`) and
`Ratioque.Franel.franel_growth_iff_RH` (module `FranelEnergy`) are ours. This file only
composes them. `Ratioque.Franel.abs_mertens_le_franel` (module `FranelMertensBound`) is
unconditional and is included for its axiom print. -/

namespace Ratioque.CrystalBridge.Compose

/-- The two zero-free statements are the same proposition, by definitional unfolding. -/
theorem everyCharacter_eq_upper : Ratioque.CrystalBridge.EveryCharacter = UpperTheory.EveryCharacter :=
  rfl

/-- Square-root-scale cancellation in every twisted crystal slab, from Alpöge's `allChi`. -/
theorem allChiVCancellation_holds : Ratioque.CrystalBridge.AllChiVCancellation :=
  Ratioque.CrystalBridge.allChiVCancellation_iff_everyCharacter.2 allChi

/-- The untwisted corollary (`χ = 1` at modulus `1`). -/
theorem vCancellation_holds : Ratioque.CrystalBridge.VCancellation :=
  allChiVCancellation_holds 1 (1 : DirichletCharacter ℂ 1)

/-- Franel energy growth `≪ N^(1+δ)` for every `δ > 0`, from Alpöge's `rhOfAll`. -/
theorem franel_growth_holds : ∀ δ : ℝ, 0 < δ → ∃ C : ℝ, 0 ≤ C ∧ ∀ N : ℕ, 1 ≤ N →
    Ratioque.Franel.franelEnergy N ≤ C * (N : ℝ) ^ (1 + δ) :=
  Ratioque.Franel.franel_growth_iff_RH.2 rhOfAll

end Ratioque.CrystalBridge.Compose

#print axioms allChi
#print axioms rhOfAll
#print axioms Ratioque.CrystalBridge.allChiVCancellation_iff_everyCharacter
#print axioms Ratioque.Franel.franel_growth_iff_RH
#print axioms Ratioque.Franel.abs_mertens_le_franel
#print axioms Ratioque.CrystalBridge.Compose.everyCharacter_eq_upper
#print axioms Ratioque.CrystalBridge.Compose.allChiVCancellation_holds
#print axioms Ratioque.CrystalBridge.Compose.vCancellation_holds
#print axioms Ratioque.CrystalBridge.Compose.franel_growth_holds
