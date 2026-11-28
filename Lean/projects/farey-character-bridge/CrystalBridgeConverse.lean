import CrystalBridgeConverseC1
import CrystalBridgeConverseC3
import CrystalBridgeConverseC4

/-! The all-characters equivalence, using the pinned bridge and all four converse steps. -/

namespace Ratioque.CrystalBridge

/-- Zero-freeness for every character gives square-root-scale cancellation in every twisted slab. -/
theorem allChiVCancellation_of_everyCharacter (h : EveryCharacter) : AllChiVCancellation := by
  intro N _ χ
  apply twistedVCancellation_of_twistedMertensCancellation
  apply twistedMertensCancellation_of_inv_bound χ (fun s hs hχ => h N χ s hs hχ)
  intro ε η hε hη
  exact inv_LFunction_subpolynomial_of_everyCharacter h χ hε hη

/-- The every-character zero-free statement is equivalent to cancellation on the twisted slabs. -/
theorem allChiVCancellation_iff_everyCharacter : AllChiVCancellation ↔ EveryCharacter :=
  ⟨everyCharacter_of_allChi_V_cancellation, allChiVCancellation_of_everyCharacter⟩

#print axioms allChiVCancellation_of_everyCharacter
#print axioms allChiVCancellation_iff_everyCharacter

end Ratioque.CrystalBridge
