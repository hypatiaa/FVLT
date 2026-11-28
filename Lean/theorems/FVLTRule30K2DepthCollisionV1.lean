import FVLTRule30RightStripV1

open FVLT.Rule30FiniteReconstructionV1 FVLT.Rule30RightStripV1

namespace FVLT.Rule30K2DepthCollisionV1

/-- Finite reconstructed-prefix collision, not a claim about infinite support.
The centre is Lane G phase 1: w="01", phi=1, black-first.
The two lists are Q1's first witness of cell (phi1,K2).
Result SHA256: 814169117dee55ed3934c51919ccac9e2f3f34c03b0cfc6b770f9c4b4692092c.
Independent verification SHA256: 2b38573be08765f6dfa933de77e157e7c374045a864c812174e292bb7f0a52fc.
The equal mask is the K-relaxed right state; it does not identify full right halves.
Both false-bit appends are rejected and both true-bit appends admitted.
The two explicit false-bit cells record B(u)=true and B(v)=false. -/
theorem k2_black_first_same_mask_depth_different_next :
    let c : Nat → Bool := fun t => decide (t % 2 = 0)
    let u : List Bool := [false, true, true, false, true, false, false, true]
    let v : List Bool := [true, false, false, true, true, false, false, true]
    u.length = 8 ∧ v.length = 8 ∧
    reachable 2 (by decide) c u = reachable 2 (by decide) c v ∧
    (reachable 2 (by decide) c u).Nonempty ∧
    reachable 2 (by decide) c (u ++ [false]) = ∅ ∧
    reachable 2 (by decide) c (v ++ [false]) = ∅ ∧
    (reachable 2 (by decide) c (u ++ [true])).Nonempty ∧
    (reachable 2 (by decide) c (v ++ [true])).Nonempty ∧
    traceColumn c u 8 0 = true ∧
    traceColumn c v 8 0 = true ∧
    traceColumn c (u ++ [false]) 9 0 = true ∧
    traceColumn c (v ++ [false]) 9 0 = false ∧
    traceColumn c (u ++ [true]) 9 0 = true ∧
    traceColumn c (v ++ [true]) 8 0 = true ∧
    traceColumn c (v ++ [true]) 9 0 = false := by
  decide

end FVLT.Rule30K2DepthCollisionV1
