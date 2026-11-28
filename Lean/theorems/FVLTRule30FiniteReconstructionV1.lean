import Ruliology.CellularAutomata.Rule30Realization
import Ruliology.CellularAutomata.Rule30FiniteConfigs
import Mathlib.Tactic

open Ruliology.CellularAutomata Rule30Jen Rule30Realization

namespace FVLT.Rule30FiniteReconstructionV1

-- BEGIN FROZEN DEFINITIONS
def traceColumn (c : Nat → Bool) (u : List Bool) (k t : Nat) : Bool :=
  (Nat.rec (motive := fun _ => (Nat → Bool) × (Nat → Bool))
    ((fun t => u.getD t false), c)
    (fun _ pair => (pair.2, fun t =>
      xor (pair.2 (t + 1)) (pair.2 t || pair.1 t))) k).2 t

def leftBounded (x : Int → Bool) (L : Nat) : Prop :=
  ∀ p : Int, p < -(L : Int) → x p = false

def rightRealizable (c : Nat → Bool) (u : List Bool) : Prop :=
  ∃ R : Int → Bool, ∀ t : Nat, t < u.length →
    u.getD t false = rh R c t 1

def finiteCompatible (c : Nat → Bool) (L : Nat) (u : List Bool) : Prop :=
  rightRealizable c u ∧
    ∀ k : Nat, L < k → k ≤ u.length → traceColumn c u k 0 = false

-- END FROZEN DEFINITIONS


private theorem trace_one (c : Nat → Bool) (u : List Bool) (t : Nat) :
    traceColumn c u 1 t = xor (c (t + 1)) (c t || u.getD t false) := by rfl

private theorem trace_next (c : Nat → Bool) (u : List Bool) (k t : Nat) :
    traceColumn c u (k + 2) t = xor (traceColumn c u (k + 1) (t + 1))
      (traceColumn c u (k + 1) t || traceColumn c u k t) := by rfl

private theorem trace_actual_aux (x : Int → Bool) (c : Nat → Bool)
    (u : List Bool) (m : Nat)
    (hc : ∀ t : Nat, t ≤ m → c t = evol x t 0)
    (hu : ∀ t : Nat, t < m → u.getD t false = evol x t 1) :
    ∀ k t : Nat, k + t ≤ m → traceColumn c u k t = evol x t (-(k : Int))
  | 0, t, h => by simpa [traceColumn] using hc t (by omega)
  | 1, t, h => by
      rw [trace_one, hc (t + 1) (by omega), hc t (by omega), hu t (by omega)]
      simpa using (Rule30FiniteConfigs.evol_left x t 0).symm
  | k + 2, t, h => by
      rw [trace_next,
        trace_actual_aux x c u m hc hu (k + 1) (t + 1) (by omega),
        trace_actual_aux x c u m hc hu (k + 1) t (by omega),
        trace_actual_aux x c u m hc hu k t (by omega)]
      have hleft : -((k + 2 : Nat) : Int) = -((k + 1 : Nat) : Int) - 1 := by omega
      have hright : -((k + 1 : Nat) : Int) + 1 = -(k : Int) := by omega
      have hx := Rule30FiniteConfigs.evol_left x t (-((k + 1 : Nat) : Int))
      rw [← hleft, hright] at hx
      exact hx.symm

private theorem rh_prefix (x : Int → Bool) (c : Nat → Bool) (m : Nat)
    (hc : ∀ t : Nat, t ≤ m → c t = evol x t 0) :
    ∀ (t : Nat) (p : Int), t < m → 1 ≤ p → rh x c t p = evol x t p
  | 0, p, ht, hp => rfl
  | t + 1, p, ht, hp => by
      rw [rh, evol,
        rh_prefix x c m hc t p (by omega) hp,
        rh_prefix x c m hc t (p + 1) (by omega) (by omega)]
      by_cases he : p = 1
      · subst p
        simp only [ite_true]
        rw [hc t (by omega)]
        rfl
      · rw [if_neg he, rh_prefix x c m hc t (p - 1) (by omega) (by omega)]

private theorem gap_white (y : Int → Bool) (L k : Nat)
    (hgap : ∀ j : Nat, L < j → j < k → y (-(j : Int)) = false) :
    ∀ (t : Nat) (p : Int), -(k : Int) + t < p → p < -(L : Int) - t →
      evol y t p = false
  | 0, p, hlo, hhi => by
      have hp : p = -(((-p).toNat : Nat) : Int) := by omega
      change y p = false
      rw [hp]
      exact hgap (-p).toNat (by omega) (by omega)
  | t + 1, p, hlo, hhi => by
      rw [evol,
        gap_white y L k hgap t (p - 1) (by omega) (by omega),
        gap_white y L k hgap t p (by omega) (by omega),
        gap_white y L k hgap t (p + 1) (by omega) (by omega)]
      rfl

theorem traceColumn_eq_evol (x : Int → Bool) (c : Nat → Bool)
    (u : List Bool) (m : Nat) (hlen : u.length = m)
    (hc : ∀ t : Nat, t ≤ m → c t = evol x t 0)
    (hu : ∀ t : Nat, t < m → u.getD t false = evol x t 1)
    (k t : Nat) (hcone : k + t ≤ m) :
    traceColumn c u k t = evol x t (-(k : Int)) := by
  exact trace_actual_aux x c u m hc hu k t hcone

theorem actual_trace_compatible (x : Int → Bool) (c : Nat → Bool)
    (m L : Nat) (hL : leftBounded x L)
    (hc : ∀ t : Nat, t ≤ m → c t = evol x t 0) :
    finiteCompatible c L ((List.range m).map (fun t => evol x t 1)) := by
  have hlen : ((List.range m).map (fun t => evol x t 1)).length = m := by simp
  have hu : ∀ t : Nat, t < m →
      ((List.range m).map (fun t => evol x t 1)).getD t false = evol x t 1 := by
    intro t ht
    simp [List.getElem?_eq_getElem, ht]
  constructor
  · refine ⟨x, ?_⟩
    intro t ht
    rw [hu t (by simpa using ht), rh_prefix x c m hc t 1 (by simpa using ht) (by decide)]
  · intro k hk hkm
    rw [traceColumn_eq_evol x c _ m hlen hc hu k 0 (by simpa using hkm)]
    exact hL (-(k : Int)) (by omega)

theorem escape_diagonal (y : Int → Bool) (L k : Nat) (hLk : L < k)
    (hleft : leftBounded y k) (hk : y (-(k : Int)) = true)
    (hgap : ∀ j : Nat, L < j → j < k → y (-(j : Int)) = false)
    (t : Nat) (ht : 2 * t + L < k) :
    evol y t ((t : Int) - (k : Int)) = true := by
  induction t with
  | zero => simpa [evol] using hk
  | succ t ih =>
    have hprev := ih (by omega)
    have hmid := gap_white y L k hgap t (((t + 1 : Nat) : Int) - (k : Int))
      (by omega) (by omega)
    have hright := gap_white y L k hgap t (((t + 1 : Nat) : Int) - (k : Int) + 1)
      (by omega) (by omega)
    change rule (evol y t (((t + 1 : Nat) : Int) - (k : Int) - 1))
      (evol y t (((t + 1 : Nat) : Int) - (k : Int)))
      (evol y t (((t + 1 : Nat) : Int) - (k : Int) + 1)) = true
    rw [show ((t + 1 : Nat) : Int) - (k : Int) - 1 = (t : Int) - (k : Int) by omega,
      hprev, hmid, hright]
    rfl

end FVLT.Rule30FiniteReconstructionV1
