import S4g

/-!
STUDY ORDER S4h-G (#1099) & S4h ADDENDUM 1 (#1103):
1. Infinite-width T1 causal forcing on the Cantor survivor body `Pins c s`:
   Without any finite-width assumption, each black-step pin `c k = true` uniquely forces
   the initial seed bit `s (-(k+1))` from the earlier prefix `truncateSeed s k`, and two
   infinite left seeds satisfying `Pins c` that agree on all white-step seed positions
   `-(k+1)` (`c k = false`) are identically equal on the entire negative half-line `p < 0`.
2. Exact 1-step cross-phase and 2-step same-phase shift maps on `Pins c s` (`L_stepSeed`,
   `pins_stepSeed`, `pins_twoStepSeed`), formalizing the shift inclusions `H-Rec1` and `H-Rec2`.
-/

namespace FVLT.S4hCantorShiftV1

open Ruliology.CellularAutomata
open Rule30DrivenLeft
open FVLT.S4gLeftScreenV1
open FVLT.S4gLBEImplicationV1

/-- Infinite-width T1 forcing: for any left seed `s : Int -> Bool` satisfying `Pins c s`
(no finite support assumed), every black step `c k = true` uniquely forces `s (-(k+1))`
as a function of the earlier prefix `truncateSeed s k`. -/
theorem cantorBody_black_seed_forced (c : Nat -> Bool) (s : Int -> Bool)
    (hpins : Pins c s) (k : Nat) (hblack : c k = true) :
    s (-((k + 1 : Nat) : Int)) =
      xor (!c (k + 1)) (L c (truncateSeed s k) k (-1)) :=
  (black_pin_iff_seed_forced c s k hblack).mp (hpins k hblack)

/-- If two infinite seeds in the Cantor survivor body `Pins c` agree at all white-step
seed depths `-(j+1)` for `j < k`, then they agree on the entire prefix `[-k, -1]`. -/
theorem cantorBody_prefix_unique_of_white_eq (c : Nat -> Bool) (s s' : Int -> Bool)
    (hs : Pins c s) (hs' : Pins c s') :
    forall k : Nat,
      (forall j : Nat, j < k -> c j = false ->
        s (-((j + 1 : Nat) : Int)) = s' (-((j + 1 : Nat) : Int))) ->
      forall p : Int, -(k : Int) <= p -> p < 0 -> s p = s' p := by
  intro k
  induction k with
  | zero =>
    intro _ p hp hn
    omega
  | succ k ih =>
    intro hwhite p hp hn
    by_cases hpk : -(k : Int) <= p
    case pos =>
      exact ih (fun j hj hcj => hwhite j (by omega) hcj) p hpk hn
    case neg =>
      have hp_eq : p = -((k + 1 : Nat) : Int) := by omega
      rw [hp_eq]
      by_cases hck : c k = false
      case pos =>
        exact hwhite k (by omega) hck
      case neg =>
        have hblack : c k = true := by
          cases hval : c k <;> simp_all
        have htrunc : truncateSeed s k = truncateSeed s' k := by
          funext q
          by_cases hq : -(k : Int) <= q /\ q < 0
          case pos =>
            simp only [truncateSeed, hq, and_self, ite_true]
            exact ih (fun j hj hcj => hwhite j (by omega) hcj) q hq.1 hq.2
          case neg =>
            simp only [truncateSeed, hq, ite_false]
        rw [cantorBody_black_seed_forced c s hs k hblack,
            cantorBody_black_seed_forced c s' hs' k hblack, htrunc]

/-- Global uniqueness of the Cantor causal map `Phi_c`: two infinite left halves satisfying
all black pins forever (`Pins c`) that agree on all white-step initial seed positions
are equal on the entire negative half-line `p < 0`. -/
theorem cantorBody_white_seed_injective (c : Nat -> Bool) (s s' : Int -> Bool)
    (hs : Pins c s) (hs' : Pins c s')
    (hwhite : forall j : Nat, c j = false ->
      s (-((j + 1 : Nat) : Int)) = s' (-((j + 1 : Nat) : Int))) :
    forall p : Int, p < 0 -> s p = s' p := by
  intro p hn
  have hbound : -(((-p).toNat : Nat) : Int) <= p := by omega
  exact cantorBody_prefix_unique_of_white_eq c s s' hs hs' ((-p).toNat)
    (fun j _ hcj => hwhite j hcj) p hbound hn

/-- Time-shifted center driver. -/
def shiftDriver (c : Nat -> Bool) (d : Nat) : Nat -> Bool :=
  fun t => c (t + d)

/-- One-step forward evolution of a left seed under driven Rule 30. -/
def stepSeed (c : Nat -> Bool) (s : Int -> Bool) : Int -> Bool :=
  fun p => L c s 1 p

/-- Semigroup property of driven left evolution `L` for a 1-step seed shift. -/
theorem L_stepSeed (c : Nat -> Bool) (s : Int -> Bool) :
    forall t : Nat, forall p : Int, p <= 0 ->
      L (shiftDriver c 1) (stepSeed c s) t p = L c s (t + 1) p := by
  intro t
  induction t with
  | zero =>
    intro p hp
    by_cases hn : p < 0
    case pos =>
      rw [L_zero hn]
      rfl
    case neg =>
      have hz : p = 0 := by omega
      subst p
      rw [L_col0, L_col0]
      rfl
  | succ t ih =>
    intro p hp
    by_cases hn : p < 0
    case pos =>
      rw [L_succ hn, L_succ hn]
      rw [ih (p - 1) (by omega), ih p hp, ih (p + 1) (by omega)]
    case neg =>
      have hz : p = 0 := by omega
      subst p
      rw [L_col0, L_col0]
      rfl

/-- 1-step cross-phase Cantor body map (`H-Rec1`): if `s` satisfies all black pins for `c`,
then `stepSeed c s` satisfies all black pins for the shifted driver `shiftDriver c 1`. -/
theorem pins_stepSeed (c : Nat -> Bool) (s : Int -> Bool) (hpins : Pins c s) :
    Pins (shiftDriver c 1) (stepSeed c s) := by
  intro t hblack
  rw [L_stepSeed c s t (-1) (by omega)]
  exact hpins (t + 1) hblack

/-- Two-step forward evolution of a left seed under driven Rule 30. -/
def twoStepSeed (c : Nat -> Bool) (s : Int -> Bool) : Int -> Bool :=
  stepSeed (shiftDriver c 1) (stepSeed c s)

/-- 2-step Cantor body map (`H-Rec2`): `twoStepSeed c s` satisfies all black pins for
`shiftDriver c 2`. -/
theorem pins_twoStepSeed (c : Nat -> Bool) (s : Int -> Bool) (hpins : Pins c s) :
    Pins (shiftDriver c 2) (twoStepSeed c s) := by
  intro t hblack
  have h1 := pins_stepSeed (shiftDriver c 1) (stepSeed c s) (pins_stepSeed c s hpins) t
  have h2 : shiftDriver (shiftDriver c 1) 1 t = shiftDriver c 2 t := by
    simp [shiftDriver, Nat.add_assoc]
  have h3 : shiftDriver (shiftDriver c 1) 1 (t + 1) = shiftDriver c 2 (t + 1) := by
    simp [shiftDriver, Nat.add_assoc]
  rw [<- h3]
  exact h1 (h2.trans hblack)

#print axioms cantorBody_black_seed_forced
#print axioms cantorBody_prefix_unique_of_white_eq
#print axioms cantorBody_white_seed_injective
#print axioms L_stepSeed
#print axioms pins_stepSeed
#print axioms pins_twoStepSeed

end FVLT.S4hCantorShiftV1

