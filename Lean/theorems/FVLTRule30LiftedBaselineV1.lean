import FVLTRule30RightStripV1

open FVLT.Rule30FiniteReconstructionV1 FVLT.Rule30RightStripV1

namespace FVLT.Rule30LiftedBaselineV1

/-- General finite reconstruction identities. The three definitions are
the reviewed lifted-baseline coordinates; prefixDepth is finite only.
One-step prediction is distinct from closure of a lifted state.
No helix dynamics, uniform escape, CQ01 or prize result is claimed. -/
-- BEGIN FROZEN DEFINITIONS

def nextCell (c : Nat → Bool) (u : List Bool) (b : Bool) : Bool :=
  traceColumn c (u ++ [b]) (u.length + 1) 0

def baseline (c : Nat → Bool) (u : List Bool) : Bool :=
  nextCell c u false

def prefixDepth (c : Nat → Bool) (u : List Bool) : Nat :=
  ((Finset.range (u.length + 1)).filter (fun k => traceColumn c u k 0 = true)).sup id

-- END FROZEN DEFINITIONS

private theorem trace_one (c : Nat → Bool) (u : List Bool) (t : Nat) :
    traceColumn c u 1 t = xor (c (t + 1)) (c t || u.getD t false) := by
  rfl

private theorem trace_next (c : Nat → Bool) (u : List Bool) (k t : Nat) :
    traceColumn c u (k + 2) t = xor (traceColumn c u (k + 1) (t + 1))
      (traceColumn c u (k + 1) t || traceColumn c u k t) := by
  rfl

private theorem getD_tail (u : List Bool) (t : Nat) :
    u.tail.getD t false = u.getD (t + 1) false := by
  simp only [List.getD_eq_getElem?_getD, List.getElem?_tail]

private theorem trace_agree (c : Nat → Bool) (u v : List Bool) (m : Nat)
    (hu : ∀ j : Nat, j < m → u.getD j false = v.getD j false)
    (k t : Nat) (h : k + t ≤ m) :
    traceColumn c u k t = traceColumn c v k t := by
  induction k using Nat.strong_induction_on generalizing t with
  | h k ih =>
    cases k with
    | zero => rfl
    | succ k =>
      cases k with
      | zero =>
        rw [trace_one, trace_one, hu t (by omega)]
      | succ k =>
        rw [trace_next, trace_next,
          ih (k + 1) (by omega) (t + 1) (by omega),
          ih (k + 1) (by omega) t (by omega),
          ih k (by omega) t (by omega)]

theorem traceColumn_append_local (c : Nat → Bool) (u : List Bool)
    (b : Bool) (k t : Nat) (h : k + t ≤ u.length) :
    traceColumn c (u ++ [b]) k t = traceColumn c u k t := by
  refine trace_agree c (u ++ [b]) u u.length ?_ k t h
  intro j hj
  simp only [List.getD_eq_getElem?_getD, List.getElem?_append_left hj]

theorem traceColumn_time_shift (c : Nat → Bool) (u : List Bool)
    (k t : Nat) :
    traceColumn c u k (t + 1) =
      traceColumn (fun s => c (s + 1)) u.tail k t := by
  induction k using Nat.strong_induction_on generalizing t with
  | h k ih =>
    cases k with
    | zero => rfl
    | succ k =>
      cases k with
      | zero =>
        exact congrArg
          (fun b : Bool => xor (c ((t + 1) + 1)) (c (t + 1) || b))
          (getD_tail u t).symm
      | succ k =>
        rw [trace_next, trace_next,
          ih (k + 1) (by omega) (t + 1),
          ih (k + 1) (by omega) t,
          ih k (by omega) t]

private theorem boundary_xor_antidiagonal (c : Nat → Bool) (u : List Bool)
    (k t : Nat) (hk : 0 < k) (hkt : k + t = u.length + 1) :
    xor (traceColumn c (u ++ [false]) k t)
      (traceColumn c (u ++ [true]) k t) = !(c u.length) := by
  induction k using Nat.strong_induction_on generalizing t with
  | h k ih =>
    cases k with
    | zero => omega
    | succ k =>
      cases k with
      | zero =>
        have ht : t = u.length := by omega
        subst t
        rw [trace_one, trace_one]
        have he (b : Bool) : (u ++ [b]).getD u.length false = b := by
          rw [List.getD_eq_getElem?_getD,
            List.getElem?_append_right (Nat.le_refl u.length)]
          simp
        rw [he false, he true]
        cases c u.length <;> cases c (u.length + 1) <;> rfl
      | succ k =>
        have hcancel (a b z : Bool) : xor (xor a z) (xor b z) = xor a b := by
          cases a <;> cases b <;> cases z <;> rfl
        rw [trace_next, trace_next,
          traceColumn_append_local c u false (k + 1) t (by omega),
          traceColumn_append_local c u false k t (by omega),
          traceColumn_append_local c u true (k + 1) t (by omega),
          traceColumn_append_local c u true k t (by omega), hcancel]
        exact ih (k + 1) (by omega) (t + 1) (by omega) (by omega)

private theorem boundary_sensitivity (c : Nat → Bool) (u : List Bool) :
    xor (nextCell c u false) (nextCell c u true) = !(c u.length) := by
  exact boundary_xor_antidiagonal c u (u.length + 1) 0 (by omega) (by omega)

theorem nextCell_affine (c : Nat → Bool) (u : List Bool) (b : Bool) :
    nextCell c u b = xor (baseline c u) ((!(c u.length)) && b) := by
  cases b with
  | false => simp [baseline]
  | true =>
    have hs := boundary_sensitivity c u
    cases h0 : nextCell c u false <;>
      cases h1 : nextCell c u true <;>
      cases hc : c u.length <;>
      simp_all [baseline]

end FVLT.Rule30LiftedBaselineV1
