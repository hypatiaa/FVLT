import FVLTS4mResidualV1
import FVLTS4mCoordinatesV1

/-!
PRIVATE, SOURCE ONLY: proposed bridge to the actual initial-coordinate body
operators. No compilation, syntax check or execution is authorized here.
The coordinate module's causal theorems remain uncompiled dependencies until
the prospective root gate. No finite representative family is supplied.
-/

set_option autoImplicit false

namespace FVLT.S4mMachineBridgeV1

open FVLTS4mResidualV1 FVLT.S4mCoordinatesV1

/-- Supplying n prefix bits and the next bit b fixes exactly the first n+1
inputs, irrespective of the continuation after b. -/
theorem prefixCons_samePrefix {n : Nat} (u : Prefix n) (b : Bool)
    (z z' : Stream) :
    SamePrefix (prefixAppend u (streamCons b z))
      (prefixAppend u (streamCons b z')) (n + 1) := by
  intro i hi
  by_cases h : i < n
  · simp [prefixAppend, h]
  · have hn : i = n := by omega
    subst i
    simp [prefixAppend, streamCons]

/-- For body10 the first n+1 inputs determine output n+1. The fixed
lead1 strip consumes the initial forced output0, never an adaptive delay. -/
theorem nextHeadCausal_body10 : NextHeadCausal body10 1 := by
  intro n u b z z'
  change body10 (prefixAppend u (streamCons b z)) (n + 1) =
    body10 (prefixAppend u (streamCons b z')) (n + 1)
  exact body10_causal _ _ (n + 1) (n + 1)
    (prefixCons_samePrefix u b z z') (Nat.le_refl _)

/-- For body01 the first n+1 inputs determine output n, matching lead0. -/
theorem nextHeadCausal_body01 : NextHeadCausal body01 0 := by
  intro n u b z z'
  change body01 (prefixAppend u (streamCons b z)) n =
    body01 (prefixAppend u (streamCons b z')) n
  exact body01_causal _ _ (n + 1) n
    (prefixCons_samePrefix u b z z') (by omega)

/-- The same-level specialization is EXACTLY the core body10 residual
relation, with the physical n+1 output strip already fixed. -/
theorem levelEquiv_body10_iff_coreResidual10 {n : Nat} (u v : Prefix n) :
    LevelEquiv body10 1 n u v ↔ FVLT.S4mCoordinatesV1.Residual10 u v := by
  rfl

/-- The other phase uses the core body's physical n output strip. -/
theorem levelEquiv_body01_iff_coreResidual01 {n : Nat} (u v : Prefix n) :
    LevelEquiv body01 0 n u v ↔ FVLT.S4mCoordinatesV1.Residual01 u v := by
  rfl

/-- Actual next body10 output after input b, for EVERY continuation tail,
agrees with the canonical emittedHead by the proved causal guard. -/
theorem emittedHead_body10 {n : Nat} (u : Prefix n) (b : Bool) (z : Stream) :
    body10 (prefixAppend u (streamCons b z)) (n + 1) =
      emittedHead body10 1 u b := by
  exact emittedHead_eq_of_nextHeadCausal body10 1 nextHeadCausal_body10 u b z

/-- Actual next body01 output law; no temporal-Theta substitution is used. -/
theorem emittedHead_body01 {n : Nat} (u : Prefix n) (b : Bool) (z : Stream) :
    body01 (prefixAppend u (streamCons b z)) n =
      emittedHead body01 0 u b := by
  exact emittedHead_eq_of_nextHeadCausal body01 0 nextHeadCausal_body01 u b z

end FVLT.S4mMachineBridgeV1
