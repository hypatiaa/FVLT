import FVLTS4dSpanReductionV1
import FVLTS4dScannerV1

/-!
S4f R3: exact all-time support-span accounting for actual Rule 30.
No periodicity exclusion or root-preservation claim is made.
-/

namespace FVLT.S4fSpanTimeV1

open Ruliology.CellularAutomata
open Rule30Realization Rule30FiniteConfigs Rule30ZeroBoundaryBarriers
open FVLT.S4dSpanReductionV1

/-- An arbitrary-time state remains a finite nonzero seed. -/
def evolveSeed (s : Seed) (T : Nat) : Seed where
  row := fun p => evol s.row T p
  finite := evol_finConfig s.finite T
  nonzero := by
    have h := left_edge (leftmost_spec s).1 (leftmost_spec s).2 T
    exact ⟨leftmost s - T, h.1⟩

theorem evolveSeed_zero_row (s : Seed) : (evolveSeed s 0).row = s.row := rfl

theorem evolveSeed_succ_row (s : Seed) (T : Nat) :
    (evolveSeed s (T + 1)).row = (step (evolveSeed s T)).row := by
  funext p
  exact (evol_restart s.row T 1 p).symm

theorem span_evolveSeed_zero (s : Seed) : span (evolveSeed s 0) = span s :=
  span_congr (evolveSeed_zero_row s)

theorem span_evolveSeed_succ (s : Seed) (T : Nat) :
    span (evolveSeed s (T + 1)) = span (evolveSeed s T) + 2 := by
  calc
    span (evolveSeed s (T + 1)) = span (step (evolveSeed s T)) :=
      span_congr (evolveSeed_succ_row s T)
    _ = span (evolveSeed s T) + 2 := span_step _

/-- Exact depth/time trade, not only a finite-speed upper bound. -/
theorem span_evolveSeed (s : Seed) (T : Nat) :
    span (evolveSeed s T) = span s + 2 * T := by
  induction T with
  | zero => simpa using span_evolveSeed_zero s
  | succ T ih =>
    rw [span_evolveSeed_succ, ih]
    omega

theorem span_time_conserved (s : Seed) (T : Nat) :
    span (evolveSeed s T) - 2 * T = span s := by
  rw [span_evolveSeed]
  omega

theorem span_evolveSeed_mono (s : Seed) {T U : Nat} (h : T ≤ U) :
    span (evolveSeed s T) ≤ span (evolveSeed s U) := by
  rw [span_evolveSeed, span_evolveSeed]
  omega

theorem span_time_balance (s : Seed) (T U : Nat) :
    span (evolveSeed s T) + 2 * U = span (evolveSeed s U) + 2 * T := by
  rw [span_evolveSeed, span_evolveSeed]
  omega

/-- Every positive-time restart has an explicit finite predecessor. -/
theorem finite_predecessor_evolveSeed_succ (s : Seed) (T : Nat) :
    FinitePredecessor (evolveSeed s (T + 1)).row := by
  refine ⟨(evolveSeed s T).row, (evolveSeed s T).finite, ?_⟩
  exact (evolveSeed_succ_row s T).symm

/-- Restarting a root at a positive time leaves the root class. -/
theorem not_root_evolveSeed_succ (s : Seed) (T : Nat) :
    ¬ NoFinitePredecessor (evolveSeed s (T + 1)).row := by
  intro h
  exact h (finite_predecessor_evolveSeed_succ s T)

/-- Finite predecessors are unique, by the existing right-white inverse theorem. -/
theorem finite_step_injective {s r : Seed}
    (h : (step s).row = (step r).row) : s.row = r.row := by
  have hy := (rightmost_spec (step s)).2
  have hs := FVLT.S4dScannerV1.inverse_unique_right_tail hy
    (show (fun p => evol s.row 1 p) = (step s).row from rfl)
    ⟨rightmost s, (rightmost_spec s).2⟩
  have hr := FVLT.S4dScannerV1.inverse_unique_right_tail hy
    (show (fun p => evol r.row 1 p) = (step s).row from h.symm)
    ⟨rightmost r, (rightmost_spec r).2⟩
  exact hs.trans hr.symm

theorem evolveSeed_add_row (s : Seed) (T U : Nat) :
    (evolveSeed (evolveSeed s T) U).row = (evolveSeed s (T + U)).row := by
  funext p
  exact evol_restart s.row T U p

/-- Cancellation of any equal number of steps among finite nonzero seeds. -/
theorem evolved_row_injective (s r : Seed) (T : Nat)
    (h : (evolveSeed s T).row = (evolveSeed r T).row) : s.row = r.row := by
  revert h
  induction T with
  | zero => intro h; exact h
  | succ T ih =>
    intro h
    have hh : (step (evolveSeed s T)).row = (step (evolveSeed r T)).row :=
      (evolveSeed_succ_row s T).symm.trans (h.trans (evolveSeed_succ_row r T))
    exact ih (finite_step_injective hh)

/-- Cancel the common initial number of steps from a meeting of two finite trajectories. -/
theorem evolved_row_cancel_le (s r : Seed) {T U : Nat} (hle : T ≤ U)
    (h : (evolveSeed s T).row = (evolveSeed r U).row) :
    s.row = (evolveSeed r (U - T)).row := by
  apply evolved_row_injective s (evolveSeed r (U - T)) T
  calc
    (evolveSeed s T).row = (evolveSeed r U).row := h
    _ = (evolveSeed r ((U - T) + T)).row := by rw [Nat.sub_add_cancel hle]
    _ = (evolveSeed (evolveSeed r (U - T)) T).row :=
      (evolveSeed_add_row r (U - T) T).symm

/-- A common finite descendant determines both its predecessor-free root and its depth. -/
theorem root_ancestor_unique (s r : Seed)
    (hs : NoFinitePredecessor s.row) (hr : NoFinitePredecessor r.row)
    (T U : Nat) (h : (evolveSeed s T).row = (evolveSeed r U).row) :
    T = U ∧ s.row = r.row := by
  have htime : T = U := by
    apply Classical.byContradiction
    intro hne
    have hor : T < U ∨ U < T := by omega
    rcases hor with hlt | hlt
    · have hc := evolved_row_cancel_le s r (Nat.le_of_lt hlt) h
      have hg : U - T = (U - T - 1) + 1 := by omega
      have hn : ¬ NoFinitePredecessor (evolveSeed r (U - T)).row := by
        rw [hg]
        exact not_root_evolveSeed_succ r (U - T - 1)
      apply hn
      rw [← hc]
      exact hs
    · have hc := evolved_row_cancel_le r s (Nat.le_of_lt hlt) h.symm
      have hg : T - U = (T - U - 1) + 1 := by omega
      have hn : ¬ NoFinitePredecessor (evolveSeed s (T - U)).row := by
        rw [hg]
        exact not_root_evolveSeed_succ s (T - U - 1)
      apply hn
      rw [← hc]
      exact hr
  refine ⟨htime, ?_⟩
  subst U
  exact evolved_row_injective s r T h

end FVLT.S4fSpanTimeV1
