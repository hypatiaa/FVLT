/-! Port shim (skeleton / vision, 2026-11-23): two Lean-core lemmas present in Lean 4.35 (`Init/Core.lean:1179,1188`)
but absent in Lean 4.33.1. Statements copied verbatim; proofs identical. Nothing else is added. -/
universe u
theorem ite_eq_left {c : Prop} {h : Decidable c} (hc : c) {α : Sort u} {t e : α} : (ite c t e) = t :=
  match h with
  | isTrue  _   => rfl
  | isFalse hnc => absurd hc hnc
theorem ite_eq_right {c : Prop} {h : Decidable c} (hnc : ¬c) {α : Sort u} {t e : α} : (ite c t e) = e :=
  match h with
  | isTrue hc   => absurd hc hnc
  | isFalse _   => rfl
