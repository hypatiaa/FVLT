import Mathlib.Analysis.SpecialFunctions.ImproperIntegrals

/-! Port shim (vision, 2026-11-23): one Mathlib lemma present in Lean 4.35 / Mathlib `56a00585`
(`Mathlib/Analysis/SpecialFunctions/ImproperIntegrals.lean:297`), absent in Mathlib `0df444a3` (Lean 4.33.1).
Statement copied verbatim; proof uses Mathlib `0df444a3`'s existing `integrable_inv_one_add_sq` and
`Integrable.comp_mul_left'`. -/

theorem integrable_inv_one_add_mul_sq {b : ℝ} (hb : b ≠ 0) :
    MeasureTheory.Integrable fun x : ℝ ↦ (1 + (b * x) ^ 2)⁻¹ :=
  (integrable_inv_one_add_sq.comp_mul_left' hb).congr (by simp)
