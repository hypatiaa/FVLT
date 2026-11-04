import Ruliology.CellularAutomata.Rule30FiniteConfigs
import Ruliology.CellularAutomata.Rule30ZeroBoundaryBarriers

/-!
S4d additive finite-predecessor reduction.  Actual kit `evol`, not an abstract CA.
Finite predecessor means a predecessor within FinConfig, not global Garden of Eden.
The eventual-period assertion includes the transient; no initial phase is required.
-/

namespace FVLT.S4dSpanReductionV1

open Ruliology.CellularAutomata
open Rule30Jen Rule30Realization Rule30PeriodTwoSideways Rule30PeriodTwoCoupled
open Rule30FiniteConfigs Rule30ZeroBoundaryBarriers

def EventuallyTwo (x : Int → Bool) : Prop :=
  ∃ T : Nat, ∀ t, T ≤ t → evol x (t + 2) 0 = evol x t 0

def FinitePredecessor (x : Int → Bool) : Prop :=
  ∃ y : Int → Bool, FinConfig y ∧ (fun p => evol y 1 p) = x

def NoFinitePredecessor (x : Int → Bool) : Prop := ¬ FinitePredecessor x

/-- Reflection here is used only for support endpoints, not as a CA symmetry. -/
theorem exists_rightmost {x : Int → Bool} (hfin : FinConfig x)
    (hne : ∃ p, x p = true) :
    ∃ hi, x hi = true ∧ ∀ p, hi < p → x p = false := by
  have hf : FinConfig (fun p => x (-p)) := by
    obtain ⟨W, hW⟩ := hfin
    refine ⟨W, fun p hp => hW (-p) ?_⟩
    simpa using hp
  have hn : ∃ p, x (-p) = true := by
    obtain ⟨p, hp⟩ := hne
    exact ⟨-p, by simpa using hp⟩
  obtain ⟨lo, hlo, hz⟩ := exists_leftmost hf hn
  refine ⟨-lo, hlo, fun p hp => ?_⟩
  have h := hz (-p) (by omega)
  simpa using h

structure Seed where
  row : Int → Bool
  finite : FinConfig row
  nonzero : ∃ p, row p = true

noncomputable def leftmost (s : Seed) : Int :=
  Classical.choose (exists_leftmost s.finite s.nonzero)

noncomputable def rightmost (s : Seed) : Int :=
  Classical.choose (exists_rightmost s.finite s.nonzero)

theorem leftmost_spec (s : Seed) :
    s.row (leftmost s) = true ∧ ∀ p, p < leftmost s → s.row p = false :=
  Classical.choose_spec (exists_leftmost s.finite s.nonzero)

theorem rightmost_spec (s : Seed) :
    s.row (rightmost s) = true ∧ ∀ p, rightmost s < p → s.row p = false :=
  Classical.choose_spec (exists_rightmost s.finite s.nonzero)

theorem endpoint_order (s : Seed) : leftmost s ≤ rightmost s := by
  apply Classical.byContradiction
  intro h
  have hz := (rightmost_spec s).2 (leftmost s) (by omega)
  rw [(leftmost_spec s).1] at hz
  cases hz

noncomputable def span (s : Seed) : Nat := (rightmost s - leftmost s).toNat

theorem span_congr {s r : Seed} (h : s.row = r.row) : span s = span r := by
  cases s
  cases r
  cases h
  rfl

theorem leftmost_eq_of_edge (s : Seed) {lo : Int} (hb : s.row lo = true)
    (hz : ∀ p, p < lo → s.row p = false) : leftmost s = lo := by
  apply Classical.byContradiction
  intro h
  have hor : leftmost s < lo ∨ lo < leftmost s := by omega
  rcases hor with hlt | hgt
  · have hf := hz (leftmost s) hlt
    rw [(leftmost_spec s).1] at hf
    cases hf
  · have hf := (leftmost_spec s).2 lo hgt
    rw [hb] at hf
    cases hf

theorem rightmost_eq_of_edge (s : Seed) {hi : Int} (hb : s.row hi = true)
    (hz : ∀ p, hi < p → s.row p = false) : rightmost s = hi := by
  apply Classical.byContradiction
  intro h
  have hor : rightmost s < hi ∨ hi < rightmost s := by omega
  rcases hor with hlt | hgt
  · have hf := (rightmost_spec s).2 hi hlt
    rw [hb] at hf
    cases hf
  · have hf := hz (rightmost s) hgt
    rw [(rightmost_spec s).1] at hf
    cases hf

def step (s : Seed) : Seed where
  row := fun p => evol s.row 1 p
  finite := evol_finConfig s.finite 1
  nonzero := by
    have h := left_edge (leftmost_spec s).1 (leftmost_spec s).2 1
    exact ⟨leftmost s - 1, by simpa using h.1⟩

theorem leftmost_step (s : Seed) : leftmost (step s) = leftmost s - 1 := by
  have h := left_edge (leftmost_spec s).1 (leftmost_spec s).2 1
  apply leftmost_eq_of_edge (step s)
  · simpa [step] using h.1
  · simpa [step] using h.2

theorem rightmost_step (s : Seed) : rightmost (step s) = rightmost s + 1 := by
  have h := right_edge (rightmost_spec s).1 (rightmost_spec s).2 1
  apply rightmost_eq_of_edge (step s)
  · simpa [step] using h.1
  · simpa [step] using h.2

/-- The exact support span grows by two, for every finite nonzero seed. -/
theorem span_step (s : Seed) : span (step s) = span s + 2 := by
  have ho := endpoint_order s
  unfold span
  rw [rightmost_step, leftmost_step]
  omega

/-- Any finite predecessor of a nonzero output is nonzero. -/
theorem predecessor_nonzero {x y : Int → Bool} (hne : ∃ p, x p = true)
    (hstep : (fun p => evol y 1 p) = x) : ∃ p, y p = true := by
  classical
  apply Classical.byContradiction
  intro hn
  have hy : ∀ p, y p = false := by
    intro p
    cases hp : y p with
    | false => rfl
    | true => exact False.elim (hn ⟨p, hp⟩)
  obtain ⟨p, hp⟩ := hne
  have he : evol y 1 p = true := by rw [congrFun hstep p]; exact hp
  change rule (y (p - 1)) (y p) (y (p + 1)) = true at he
  rw [hy _, hy _, hy _] at he
  cases he

/-- Pullback through one actual step; the explicit new threshold is T+1. -/
theorem eventuallyTwo_pullback {x y : Int → Bool}
    (hstep : (fun p => evol y 1 p) = x) (h : EventuallyTwo x) : EventuallyTwo y := by
  obtain ⟨T, hT⟩ := h
  refine ⟨T + 1, fun t ht => ?_⟩
  have hr (k : Nat) : evol y (k + 1) 0 = evol x k 0 := by
    calc
      evol y (k + 1) 0 = evol (fun p => evol y 1 p) k 0 := by
        simpa [Nat.add_comm] using (evol_restart y 1 k 0).symm
      _ = evol x k 0 := by rw [hstep]
  have h0 := hr (t - 1)
  have h2 := hr ((t - 1) + 2)
  have hp := hT (t - 1) (by omega)
  have hh := h2.trans (hp.trans h0.symm)
  simpa only [show t - 1 + 1 = t by omega,
    show t - 1 + 2 + 1 = t + 2 by omega] using hh

/-- Strong induction on unbounded actual span, not a finite abstraction rank. -/
theorem exclude_all_of_exclude_no_finite_predecessor
    (h : ∀ s : Seed, NoFinitePredecessor s.row → ¬ EventuallyTwo s.row) :
    ∀ s : Seed, ¬ EventuallyTwo s.row := by
  classical
  have key : ∀ n : Nat, ∀ s : Seed, span s = n → ¬ EventuallyTwo s.row := by
    intro n
    refine Nat.strongRecOn n ?_
    intro n ih s hs hE
    by_cases hp : FinitePredecessor s.row
    · obtain ⟨y, hyfin, hys⟩ := hp
      have hyne := predecessor_nonzero s.nonzero hys
      let q : Seed := ⟨y, hyfin, hyne⟩
      have hrows : (step q).row = s.row := hys
      have hg : span s = span q + 2 := by
        rw [← span_congr hrows]
        exact span_step q
      have hlt : span q < n := by omega
      exact ih (span q) hlt q rfl (eventuallyTwo_pullback hys hE)
    · exact h s hp hE
  intro s
  exact key (span s) s rfl

/-- CQ01 may equivalently be tested only on finite seeds without finite predecessors. -/
theorem CQ01_iff_no_finite_predecessor_period_two :
    CQ01 ↔ ∀ x : Int → Bool, FinConfig x → (∃ p, x p = true) →
      NoFinitePredecessor x → ¬ EventuallyTwo x := by
  constructor
  · intro hC x hf hn _
    exact (CQ01_iff_no_finite_period_two.mp hC) x hf hn
  · intro h
    apply CQ01_iff_no_finite_period_two.mpr
    intro x hf hn
    have hs : ∀ s : Seed, NoFinitePredecessor s.row → ¬ EventuallyTwo s.row := by
      intro s hg
      exact h s.row s.finite s.nonzero hg
    exact exclude_all_of_exclude_no_finite_predecessor hs ⟨x, hf, hn⟩

end FVLT.S4dSpanReductionV1
