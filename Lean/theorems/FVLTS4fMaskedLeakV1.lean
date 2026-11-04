import FVLTS4eUniformPeriodV1

/-! S4f: the exact white-gated right-column obstruction. These are necessary
conditions under a hypothesized periodic centre, not a periodicity exclusion.
All actual configurations, finite support guards and observed columns are explicit. -/

namespace FVLT.S4fMaskedLeakV1

open Ruliology.CellularAutomata
open Rule30Jen Rule30Realization Rule30PeriodTwoCoupled Rule30PeriodTwoSideways
open Rule30FiniteConfigs

def whiteRight (x : Int → Bool) (t : Nat) : Bool :=
  (!evol x t 0) && evol x t 1

theorem mask_equality_iff (n c a b : Bool) :
    xor n (c || a) = xor n (c || b) ↔ ((!c) && a) = ((!c) && b) := by
  cases n <;> cases c <;> cases a <;> cases b <;> decide

theorem mask_difference (n c a b : Bool) :
    xor (xor n (c || a)) (xor n (c || b)) = ((!c) && xor a b) := by
  cases n <;> cases c <;> cases a <;> cases b <;> rfl

/-- This completes only the local centre equation, not a global CA spacetime. -/
theorem arbitrary_right_trace_local_completion (c r : Nat → Bool) (t : Nat) :
    rule (xor (c (t + 1)) (c t || r t)) (c t) (r t) = c (t + 1) := by
  cases c (t + 1) <;> cases c t <;> cases r t <;> rfl

theorem actual_left_rule (x : Int → Bool) (t : Nat) :
    evol x t (-1) = xor (evol x (t + 1) 0) (evol x t 0 || evol x t 1) := by
  simpa using (Rule30FiniteConfigs.evol_left x t 0)

theorem left_equality_iff_white_right_equality (x : Int → Bool) (t P : Nat)
    (hc : evol x (t + P) 0 = evol x t 0)
    (hn : evol x (t + P + 1) 0 = evol x (t + 1) 0) :
    (evol x (t + P) (-1) = evol x t (-1)) ↔
      whiteRight x (t + P) = whiteRight x t := by
  rw [actual_left_rule, actual_left_rule, hn, hc]
  unfold whiteRight
  rw [hc]
  exact mask_equality_iff _ _ _ _

theorem actual_masked_difference (x : Int → Bool) (t P : Nat)
    (hc : evol x (t + P) 0 = evol x t 0)
    (hn : evol x (t + P + 1) 0 = evol x (t + 1) 0) :
    xor (evol x (t + P) (-1)) (evol x t (-1)) =
      ((!evol x t 0) && xor (evol x (t + P) 1) (evol x t 1)) := by
  rw [actual_left_rule, actual_left_rule, hn, hc]
  exact mask_difference _ _ _ _

theorem left_period_iff_white_right_period {x : Int → Bool} {T P : Nat}
    (hc : ∀ t, T ≤ t → evol x (t + P) 0 = evol x t 0) :
    (∀ t, T ≤ t → evol x (t + P) (-1) = evol x t (-1)) ↔
      (∀ t, T ≤ t → whiteRight x (t + P) = whiteRight x t) := by
  have hi (t : Nat) (ht : T ≤ t) :=
    left_equality_iff_white_right_equality x t P (hc t ht)
      (by simpa [Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using hc (t + 1) (by omega))
  constructor
  · intro h t ht
    exact (hi t ht).mp (h t ht)
  · intro h t ht
    exact (hi t ht).mpr (h t ht)

/-- Different possible periods are synchronized; no shared-period assumption. -/
theorem left_ep_iff_white_right_ep {x : Int → Bool}
    (hc : Rule30Jen.EventuallyPeriodic (fun t => evol x t 0)) :
    Rule30Jen.EventuallyPeriodic (fun t => evol x t (-1)) ↔
      Rule30Jen.EventuallyPeriodic (whiteRight x) := by
  constructor
  · intro hl
    obtain ⟨T, P, hP, hcP, hlP⟩ := Rule30Jen.common_period hc hl
    exact ⟨T, P, hP, (left_period_iff_white_right_period hcP).mp hlP⟩
  · intro hm
    obtain ⟨T, P, hP, hcP, hmP⟩ := Rule30Jen.common_period hc hm
    exact ⟨T, P, hP, (left_period_iff_white_right_period hcP).mpr hmP⟩

/-- Jen turns periodicity of the masked right signal into a contradiction.
This is stronger in scope than root seeds but does not prove the signal periodic. -/
theorem white_right_not_ep_of_center_ep {x : Int → Bool}
    (hf : FinConfig x) (hne : ∃ p, x p = true)
    (hc : Rule30Jen.EventuallyPeriodic (fun t => evol x t 0)) :
    ¬ Rule30Jen.EventuallyPeriodic (whiteRight x) := by
  intro hm
  have hl := (left_ep_iff_white_right_ep hc).mpr hm
  exact (Rule30FiniteConfigs.jen_finite hf hne (-1) 0 (by decide)) ⟨hl, hc⟩

/-- A hypothesized periodic finite centre requires arbitrarily late unmasked
right-column mismatches. No finite search bound or existence of such a seed. -/
theorem white_leak_arbitrarily_late {x : Int → Bool} {T P : Nat}
    (hf : FinConfig x) (hne : ∃ p, x p = true) (hP : 0 < P)
    (hc : ∀ t, T ≤ t → evol x (t + P) 0 = evol x t 0) :
    ∀ B : Nat, ∃ t : Nat, B ≤ t ∧ T ≤ t ∧ evol x t 0 = false ∧
      evol x (t + P) 1 ≠ evol x t 1 := by
  intro B
  refine Classical.byContradiction fun hno => ?_
  apply white_right_not_ep_of_center_ep hf hne ⟨T, P, hP, hc⟩
  refine ⟨max B T, P, hP, fun t ht => ?_⟩
  have htB : B ≤ t := by omega
  have htT : T ≤ t := by omega
  cases hb : evol x t 0 with
  | false =>
    have hr : evol x (t + P) 1 = evol x t 1 := by
      refine Classical.byContradiction fun hr => ?_
      exact hno ⟨t, htB, htT, hb, hr⟩
    simp [whiteRight, hc t htT, hb, hr]
  | true => simp [whiteRight, hc t htT, hb]

end FVLT.S4fMaskedLeakV1
