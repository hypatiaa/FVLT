import FVLTRule30LiftedBaselineV1
import FVLTRule30RightStripV1

/-! Finite reconstructed-prefix witness to failure of exact lifted-state closure at K=2.
Lane G word01 phase1 is black-first: c(t)=decide(t%2=0).
Q2 result SHA256: 7791c289de006dfdd870cb50548b561c17f26f027950229c9a8773e60a278ecb.
Independent verification SHA256: 764cfeffc6b36465ddced802ae659931737bebb6a1083b2d564b3e8eef606797.
This refutes only exact closure of S at K=2 in the K-relaxed setting.
No full-right, infinite-support, forcing, uniform, CQ01 or prize claim. -/

open FVLT.Rule30FiniteReconstructionV1 FVLT.Rule30RightStripV1
open FVLT.Rule30LiftedBaselineV1

namespace FVLT.Rule30K2LiftedClosureWitnessV1

theorem k2_black_first_equal_lift_different_next_baseline :
    let c : Nat → Bool := fun t => decide (t % 2 = 0)
    let u : List Bool := [false, true, true, false, true, false, false]
    let v : List Bool := [true, false, false, true, true, false, false]
    u.length = 7 ∧ v.length = 7 ∧
    reachable 2 (by decide) c u = reachable 2 (by decide) c v ∧
    (reachable 2 (by decide) c u).Nonempty ∧
    (reachable 2 (by decide) c (u ++ [true])).Nonempty ∧
    (reachable 2 (by decide) c (v ++ [true])).Nonempty ∧
    prefixDepth c u = 7 ∧ prefixDepth c v = 7 ∧
    baseline c u = false ∧ baseline c v = false ∧
    baseline c (u ++ [true]) = true ∧
    baseline c (v ++ [true]) = false ∧
    prefixDepth c (u ++ [true]) = 8 ∧
    prefixDepth c (v ++ [true]) = 8 := by
  decide

end FVLT.Rule30K2LiftedClosureWitnessV1
