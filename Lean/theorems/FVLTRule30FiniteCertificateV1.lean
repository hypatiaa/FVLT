import FVLTRule30RightStripV1
import Ruliology.CellularAutomata.Rule30ZeroBoundaryBarriers

open Ruliology.CellularAutomata Rule30Realization
open FVLT.Rule30FiniteReconstructionV1 FVLT.Rule30RightStripV1

namespace FVLT.Rule30FiniteCertificateV1

-- BEGIN FROZEN DEFINITIONS
def checkExtinct (c : Nat → Bool) (K : Nat) (hK : 0 < K) (L m : Nat) : Bool :=
  (traceLevel K hK c m).all (fun pair =>
    (List.range (m + 1)).any (fun k =>
      decide (L < k) && traceColumn c pair.1 k 0))

-- END FROZEN DEFINITIONS

theorem checkExtinct_eq_true_iff (c : Nat → Bool) (K : Nat) (hK : 0 < K)
    (L m : Nat) :
    checkExtinct c K hK L m = true ↔
      ∀ u : List Bool, u.length = m → (reachable K hK c u).Nonempty →
        ∃ k : Nat, L < k ∧ k ≤ m ∧ traceColumn c u k 0 = true := by
  constructor
  · intro h u hlen hn
    have hmem : (u, reachable K hK c u) ∈ traceLevel K hK c m :=
      (traceLevel_complete K hK c m u _).mpr ⟨hlen, rfl, hn⟩
    have hany := (List.all_eq_true.mp h) (u, reachable K hK c u) hmem
    obtain ⟨k, hkr, hk⟩ := List.any_eq_true.mp hany
    have hparts := Bool.and_eq_true_iff.mp hk
    exact ⟨k, of_decide_eq_true hparts.1, by
      have := List.mem_range.mp hkr
      omega, hparts.2⟩
  · intro h
    apply List.all_eq_true.mpr
    rintro ⟨u, S⟩ hmem
    obtain ⟨hlen, rfl, hn⟩ := (traceLevel_complete K hK c m u S).mp hmem
    obtain ⟨k, hL, hkm, hblack⟩ := h u hlen hn
    apply List.any_eq_true.mpr
    refine ⟨k, List.mem_range.mpr (by omega), ?_⟩
    apply Bool.and_eq_true_iff.mpr
    exact ⟨by simpa only [decide_eq_true_eq] using hL, hblack⟩

theorem checkExtinct_no_compatible (c : Nat → Bool) (K : Nat) (hK : 0 < K)
    (L m : Nat) (hcheck : checkExtinct c K hK L m = true) :
    ¬ ∃ u : List Bool, u.length = m ∧ finiteCompatible c L u := by
  rintro ⟨u, hlen, hR, hwhite⟩
  obtain ⟨k, hL, hkm, hblack⟩ := (checkExtinct_eq_true_iff c K hK L m).mp hcheck u hlen
    (rightRealizable_implies_strip K hK c u hR)
  have hz := hwhite k hL (by omega)
  rw [hblack] at hz
  contradiction

theorem checkExtinct_no_actual (c : Nat → Bool) (K : Nat) (hK : 0 < K)
    (L m : Nat) (hcheck : checkExtinct c K hK L m = true) :
    ¬ ∃ x : Int → Bool, leftBounded x L ∧
      ∀ t : Nat, t ≤ m → evol x t 0 = c t := by
  rintro ⟨x, hL, hc⟩
  apply checkExtinct_no_compatible c K hK L m hcheck
  refine ⟨(List.range m).map (fun t => evol x t 1), by simp, ?_⟩
  exact actual_trace_compatible x c m L hL (fun t ht => (hc t ht).symm)

theorem checkExtinct_no_restart (c : Nat → Bool) (K : Nat) (hK : 0 < K)
    (L m : Nat) (hcheck : checkExtinct c K hK L m = true) :
    ¬ ∃ (x : Int → Bool) (T : Nat), leftBounded (evol x T) L ∧
      ∀ t : Nat, t ≤ m → evol x (T + t) 0 = c t := by
  rintro ⟨x, T, hL, hc⟩
  apply checkExtinct_no_actual c K hK L m hcheck
  refine ⟨fun p => evol x T p, hL, ?_⟩
  intro t ht
  rw [Rule30ZeroBoundaryBarriers.evol_restart]
  exact hc t ht

end FVLT.Rule30FiniteCertificateV1
