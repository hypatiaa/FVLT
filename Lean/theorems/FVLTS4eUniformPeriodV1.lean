import FVLTS4dSpanReductionV1

/-!
S4e: uniform finite-predecessor reduction for actual Rule 30 center periods.
This reduces proof obligations; it does not prove exclusion for an arbitrary period.
The period-zero definition is permitted, while exported intended-period theorems
explicitly require positivity. Predecessors always mean finite predecessors.
-/

namespace FVLT.S4eUniformPeriodV1

open Ruliology.CellularAutomata
open Rule30Realization Rule30PeriodTwoSideways Rule30PeriodTwoCoupled
open Rule30FiniteConfigs Rule30ZeroBoundaryBarriers
open FVLT.S4dSpanReductionV1

def EventuallyPeriodic (P : Nat) (x : Int → Bool) : Prop :=
  ∃ T : Nat, ∀ t, T ≤ t → evol x (t + P) 0 = evol x t 0

def AllFiniteExclusion (P : Nat) : Prop :=
  ∀ x : Int → Bool, FinConfig x → (∃ p, x p = true) → ¬ EventuallyPeriodic P x

def RootExclusion (P : Nat) : Prop :=
  ∀ x : Int → Bool, FinConfig x → (∃ p, x p = true) →
    NoFinitePredecessor x → ¬ EventuallyPeriodic P x

/-- Actual one-step restart supplies the precise pullback threshold T+1. -/
theorem period_pullback_at_threshold (P T : Nat) {x y : Int → Bool}
    (hstep : (fun p => evol y 1 p) = x)
    (hT : ∀ t, T ≤ t → evol x (t + P) 0 = evol x t 0) :
    ∀ t, T + 1 ≤ t → evol y (t + P) 0 = evol y t 0 := by
  intro t ht
  have hr (k : Nat) : evol y (k + 1) 0 = evol x k 0 := by
    calc
      evol y (k + 1) 0 = evol (fun p => evol y 1 p) k 0 := by
        simpa [Nat.add_comm] using (evol_restart y 1 k 0).symm
      _ = evol x k 0 := by rw [hstep]
  have h0 := hr (t - 1)
  have hP := hr ((t - 1) + P)
  have hp := hT (t - 1) (by omega)
  have hh := hP.trans (hp.trans h0.symm)
  simpa only [show t - 1 + 1 = t by omega,
    show t - 1 + P + 1 = t + P by omega] using hh

theorem eventuallyPeriodic_pullback (P : Nat) {x y : Int → Bool}
    (hstep : (fun p => evol y 1 p) = x)
    (h : EventuallyPeriodic P x) : EventuallyPeriodic P y := by
  obtain ⟨T, hT⟩ := h
  exact ⟨T + 1, period_pullback_at_threshold P T hstep hT⟩

/-- Any predicate preserved by finite backward extension admits the same reduction.
The strong induction is on the unbounded exact support span from S4d. -/
theorem backward_stable_exclusion_iff (D : (Int → Bool) → Prop)
    (hback : ∀ x y : Int → Bool, (fun p => evol y 1 p) = x → D x → D y) :
    (∀ x : Int → Bool, FinConfig x → (∃ p, x p = true) → ¬ D x) ↔
    (∀ x : Int → Bool, FinConfig x → (∃ p, x p = true) →
      NoFinitePredecessor x → ¬ D x) := by
  classical
  constructor
  · intro h x hf hn _
    exact h x hf hn
  · intro h
    have key : ∀ n : Nat, ∀ s : Seed, span s = n → ¬ D s.row := by
      intro n
      refine Nat.strongRecOn n ?_
      intro n ih s hs hD
      by_cases hp : FinitePredecessor s.row
      · obtain ⟨y, hyfin, hys⟩ := hp
        have hyne := predecessor_nonzero s.nonzero hys
        let q : Seed := ⟨y, hyfin, hyne⟩
        have hrows : (step q).row = s.row := hys
        have hg : span s = span q + 2 := by
          rw [← span_congr hrows]
          exact span_step q
        have hlt : span q < n := by omega
        exact ih (span q) hlt q rfl (hback s.row y hys hD)
      · exact h s.row s.finite s.nonzero hp hD
    intro x hf hn
    exact key (span ⟨x, hf, hn⟩) ⟨x, hf, hn⟩ rfl

/-- Logical reduction, also valid at zero; it asserts neither side of the equivalence. -/
theorem period_exclusion_iff (P : Nat) : AllFiniteExclusion P ↔ RootExclusion P := by
  exact backward_stable_exclusion_iff (EventuallyPeriodic P)
    (fun _ _ hs hp => eventuallyPeriodic_pullback P hs hp)

/-- Positive-period presentation of the intended scope. -/
theorem positive_period_exclusion_iff (P : Nat) (_hP : 1 ≤ P) :
    AllFiniteExclusion P ↔ RootExclusion P := period_exclusion_iff P

theorem all_positive_periods_exclusion_iff :
    (∀ P : Nat, 1 ≤ P → AllFiniteExclusion P) ↔
    (∀ P : Nat, 1 ≤ P → RootExclusion P) := by
  constructor
  · intro h P hP
    exact (positive_period_exclusion_iff P hP).mp (h P hP)
  · intro h P hP
    exact (positive_period_exclusion_iff P hP).mpr (h P hP)

/-- Seed-outer statement: the period may depend on the seed. -/
theorem seedwise_all_positive_periods_exclusion_iff :
    (∀ x : Int → Bool, FinConfig x → (∃ p, x p = true) →
      ¬ ∃ P : Nat, 1 ≤ P ∧ EventuallyPeriodic P x) ↔
    (∀ x : Int → Bool, FinConfig x → (∃ p, x p = true) →
      NoFinitePredecessor x → ¬ ∃ P : Nat, 1 ≤ P ∧ EventuallyPeriodic P x) := by
  apply backward_stable_exclusion_iff
  intro x y hs h
  obtain ⟨P, hP, hp⟩ := h
  exact ⟨P, hP, eventuallyPeriodic_pullback P hs hp⟩

/-- The P=2 predicate is exactly the previously defined S4d predicate. -/
theorem eventuallyPeriodic_two_iff (x : Int → Bool) :
    EventuallyPeriodic 2 x ↔ EventuallyTwo x := Iff.rfl

/-- Recovery of the existing CQ01 case through the uniform reduction. -/
theorem CQ01_iff_root_exclusion_two : CQ01 ↔ RootExclusion 2 := by
  have hkit : CQ01 ↔ AllFiniteExclusion 2 := CQ01_iff_no_finite_period_two
  exact hkit.trans (positive_period_exclusion_iff 2 (by omega))

/-- A one-periodic Boolean center tail is an eventually constant center tail. -/
theorem eventuallyPeriodic_one_iff_eventually_constant (x : Int → Bool) :
    EventuallyPeriodic 1 x ↔
      ∃ T : Nat, ∃ b : Bool, ∀ t, T ≤ t → evol x t 0 = b := by
  constructor
  · rintro ⟨T, hT⟩
    refine ⟨T, evol x T 0, fun t ht => ?_⟩
    have tail : ∀ n : Nat, evol x (T + n) 0 = evol x T 0 := by
      intro n
      induction n with
      | zero => rfl
      | succ n ih =>
        calc
          evol x (T + (n + 1)) 0 = evol x (T + n) 0 := by
            rw [show T + (n + 1) = (T + n) + 1 by omega]
            exact hT (T + n) (by omega)
          _ = evol x T 0 := ih
    simpa only [show T + (t - T) = t by omega] using tail (t - T)
  · rintro ⟨T, b, hT⟩
    refine ⟨T, fun t ht => ?_⟩
    exact (hT (t + 1) (by omega)).trans (hT t ht).symm

/-- This is the existing kit period-one theorem, transported through the definition. -/
theorem all_finite_exclusion_one : AllFiniteExclusion 1 := by
  intro x hf hn hp
  exact (no_column_eventually_constant_finite hf hn 0)
    ((eventuallyPeriodic_one_iff_eventually_constant x).mp hp)

theorem root_exclusion_one : RootExclusion 1 :=
  (positive_period_exclusion_iff 1 (by omega)).mp all_finite_exclusion_one

theorem period_one_both_sides : AllFiniteExclusion 1 ∧ RootExclusion 1 :=
  ⟨all_finite_exclusion_one, root_exclusion_one⟩

end FVLT.S4eUniformPeriodV1
