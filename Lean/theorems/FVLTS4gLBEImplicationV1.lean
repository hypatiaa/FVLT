import FVLTS4gLeftScreenV1
import FVLTS4eUniformPeriodV1
import Mathlib.Data.Nat.Find

/-!
S4g: the left black-pin exclusion is a sufficient uniform dynamical obligation.
No instance of LBEPeriodP at a positive period is asserted here. The driver
quantifier covers every nonconstant P-periodic word, not only primitive words.
-/

namespace FVLT.S4gLBEImplicationV1

open Ruliology.CellularAutomata
open Rule30Realization Rule30PeriodTwoCoupled Rule30PeriodTwoSideways Rule30FiniteConfigs
open Rule30ZeroBoundaryBarriers Rule30DrivenLeft
open FVLT.S4gLeftScreenV1

/-- Finite on the negative half only; nonnegative input values are ignored. -/
def FiniteLeft (s : Int → Bool) : Prop :=
  ∃ W : Nat, ∀ p : Int, p < -(W : Int) → s p = false

/-- Necessary centre-consistency pins, imposed only at black driver times. -/
def Pins (c : Nat → Bool) (s : Int → Bool) : Prop :=
  ∀ t : Nat, c t = true → L c s t (-1) = !c (t + 1)

/-- The proposed left-only exclusion for every nonconstant P-periodic driver.
The supplied period need not be minimal. No right-half compatibility is assumed. -/
def LBEPeriodP (P : Nat) : Prop :=
  ∀ c : Nat → Bool, (∀ t, c (t + P) = c t) →
    (¬ ∃ b : Bool, ∀ t, c t = b) →
    ∀ s : Int → Bool, FiniteLeft s → ¬ Pins c s

/-- The ordinary finite-support guard implies the negative-half guard. -/
theorem finiteLeft_of_finConfig {s : Int → Bool} (hs : FinConfig s) : FiniteLeft s := by
  obtain ⟨W, hW⟩ := hs
  refine ⟨W, fun p hp => hW p ?_⟩
  omega

/-- A finite actual configuration supplies the pins on its actual centre driver. -/
theorem actual_pins (x : Int → Bool) :
    Pins (fun t => evol x t 0) x := by
  intro t ht
  exact actual_black_pin x x (fun k => evol x k 0)
    (fun _ _ => rfl) (fun _ => rfl) t ht

/-- Restarting an actual eventually P-periodic centre produces a globally
P-periodic driver and a finitely supported negative half. The existing P1
theorem excludes a constant driver. This is an implication, not LBE itself. -/
theorem LBEPeriodP_implies_allFiniteExclusion (P : Nat) (_hP : 0 < P)
    (hLBE : LBEPeriodP P) : FVLT.S4eUniformPeriodV1.AllFiniteExclusion P := by
  intro x hxfin hxne hperiod
  obtain ⟨T, hT⟩ := hperiod
  let z : Int → Bool := fun p => evol x T p
  let c : Nat → Bool := fun t => evol z t 0
  have hzfin : FinConfig z := evol_finConfig hxfin T
  have hcp : ∀ t, c (t + P) = c t := by
    intro t
    change evol (fun p => evol x T p) (t + P) 0 =
      evol (fun p => evol x T p) t 0
    rw [evol_restart, evol_restart]
    simpa only [Nat.add_assoc] using hT (T + t) (by omega)
  have hcn : ¬ ∃ b : Bool, ∀ t, c t = b := by
    rintro ⟨b, hb⟩
    apply no_column_eventually_constant_finite hxfin hxne 0
    refine ⟨T, b, fun t ht => ?_⟩
    have hh := hb (t - T)
    change evol (fun p => evol x T p) (t - T) 0 = b at hh
    rw [evol_restart] at hh
    simpa only [show T + (t - T) = t by omega] using hh
  exact hLBE c hcp hcn z (finiteLeft_of_finConfig hzfin) (actual_pins z)

/-- The root-class version follows without asserting either exclusion premise. -/
theorem LBEPeriodP_implies_rootExclusion (P : Nat) (hP : 0 < P)
    (hLBE : LBEPeriodP P) : FVLT.S4eUniformPeriodV1.RootExclusion P :=
  (FVLT.S4eUniformPeriodV1.period_exclusion_iff P).mp
    (LBEPeriodP_implies_allFiniteExclusion P hP hLBE)

/-- Quantification over all positive periods keeps the driver period nonminimal. -/
theorem all_LBE_implies_allFiniteExclusion
    (hLBE : ∀ P : Nat, 0 < P → LBEPeriodP P) :
    ∀ P : Nat, 0 < P → FVLT.S4eUniformPeriodV1.AllFiniteExclusion P := by
  intro P hP
  exact LBEPeriodP_implies_allFiniteExclusion P hP (hLBE P hP)

/-- Primitive means least strictly positive period, not merely a supplied period. -/
def PrimitivePeriod (P : Nat) (c : Nat → Bool) : Prop :=
  0 < P ∧ (∀ t, c (t + P) = c t) ∧
    ∀ q : Nat, 0 < q → q < P → ¬ (∀ t, c (t + q) = c t)

/-- The original primitive-word formulation, with constants separately excluded. -/
def PrimitiveLBE (P : Nat) : Prop :=
  ∀ c : Nat → Bool, PrimitivePeriod P c →
    (¬ ∃ b : Bool, ∀ t, c t = b) →
    ∀ s : Int → Bool, FiniteLeft s → ¬ Pins c s

/-- Every positive periodic driver has a least positive period. No divisibility
or computational search bound is asserted. -/
theorem exists_primitivePeriod (P : Nat) (hP : 0 < P)
    (c : Nat → Bool) (hc : ∀ t, c (t + P) = c t) :
    ∃ Q : Nat, PrimitivePeriod Q c := by
  classical
  have hex : ∃ q : Nat, 0 < q ∧ ∀ t, c (t + q) = c t := ⟨P, hP, hc⟩
  refine ⟨Nat.find hex, (Nat.find_spec hex).1, (Nat.find_spec hex).2, ?_⟩
  intro q hq hlt hperiod
  exact Nat.find_min hex hlt ⟨hq, hperiod⟩

/-- At a single P, the nonminimal-period formulation also handles primitive P. -/
theorem LBEPeriodP_implies_primitiveLBE (P : Nat) (h : LBEPeriodP P) :
    PrimitiveLBE P := by
  intro c hc hn s hs hp
  exact h c hc.2.1 hn s hs hp

/-- Quantification over all positive primitive periods recovers the full driver
quantifier at every supplied period, without a divisibility lemma. -/
theorem allPrimitiveLBE_implies_allLBE
    (h : ∀ Q : Nat, 0 < Q → PrimitiveLBE Q) :
    ∀ P : Nat, 0 < P → LBEPeriodP P := by
  intro P hP c hc hn s hs hp
  obtain ⟨Q, hQ⟩ := exists_primitivePeriod P hP c hc
  exact h Q hQ.1 c hQ hn s hs hp

/-- A uniform primitive-word exclusion would suffice for the all-finite target.
The premise remains the open dynamical obligation. -/
theorem allPrimitiveLBE_implies_allFiniteExclusion
    (h : ∀ Q : Nat, 0 < Q → PrimitiveLBE Q) :
    ∀ P : Nat, 0 < P → FVLT.S4eUniformPeriodV1.AllFiniteExclusion P :=
  all_LBE_implies_allFiniteExclusion (allPrimitiveLBE_implies_allLBE h)

theorem allPrimitiveLBE_implies_allRootExclusion
    (h : ∀ Q : Nat, 0 < Q → PrimitiveLBE Q) :
    ∀ P : Nat, 0 < P → FVLT.S4eUniformPeriodV1.RootExclusion P := by
  intro P hP
  exact LBEPeriodP_implies_rootExclusion P hP (allPrimitiveLBE_implies_allLBE h P hP)

end FVLT.S4gLBEImplicationV1
