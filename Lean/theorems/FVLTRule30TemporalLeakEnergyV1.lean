import FVLTTemporalMismatchEnergyV1
import FVLTS4fMaskedLeakV1
import Ruliology.CellularAutomata.Rule30Realization
import Ruliology.CellularAutomata.Rule30Prize

/-!
Exact temporal windows of length 2P, real complete-residue SUM energy, no taper.
Coexistence of zero centre off-energy and positive neighbour off-energy is not a
contradiction. This module claims no exclusion of eventual centre periodicity,
bounded waiting time, cancellation estimate, Q01/CQ01 solution or prize result.
The mean-scale reading offEnergy/(2P) >= 1/P is a remark, not a seventh target.
-/
set_option autoImplicit false
noncomputable section
namespace FVLT.Rule30TemporalLeakEnergyV1
open Ruliology.CellularAutomata
open Rule30Realization Rule30PeriodTwoSideways
open FVLT.TemporalMismatchEnergyV1

/-- Conditional on a periodic centre tail; no finite-support hypothesis is required. -/
theorem center_off_energy_zero (x : Int → Bool) (T P t0 : Nat)
    (hP : 0 < P) (ht0 : T ≤ t0)
    (hper : ∀ t : Nat, T ≤ t → evol x (t + P) 0 = evol x t 0) :
    offEnergy (2 * P) P (window (fun t => evol x t 0) t0) = 0 := by
  rw [off_energy_eq_twice_mismatchCount P hP]
  have hz : mismatchCount P (fun t => evol x t 0) t0 = 0 := by
    unfold mismatchCount
    apply Finset.card_eq_zero.mpr
    apply Finset.eq_empty_iff_forall_notMem.mpr
    intro j hj
    obtain ⟨_, hne⟩ := Finset.mem_filter.mp hj
    apply hne
    have hp := hper (t0+j) (by omega)
    simpa only [Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using hp.symm
  rw [hz]
  norm_num

/-- Conditional on a periodic centre tail; no claim that such a tail exists. -/
theorem right_off_energy_arbitrarily_late (x : Int → Bool) (T P : Nat)
    (hfin : FinConfig x) (hne : ∃ p : Int, x p = true) (hP : 0 < P)
    (hper : ∀ t : Nat, T ≤ t → evol x (t + P) 0 = evol x t 0)
    (B : Nat) :
    ∃ t0 : Nat, B ≤ t0 ∧ T ≤ t0 ∧ evol x t0 0 = false ∧
      2 ≤ offEnergy (2 * P) P (window (fun t => evol x t 1) t0) := by
  obtain ⟨t0, hB, hT, hw, hr⟩ :=
    FVLT.S4fMaskedLeakV1.white_leak_arbitrarily_late hfin hne hP hper B
  refine ⟨t0, hB, hT, hw, ?_⟩
  apply mismatch_forces_off_energy P hP (fun t => evol x t 1) t0 0 hP
  simpa only [Nat.add_zero] using Ne.symm hr

/-- Conditional kit single-seed consequence; no claim that a periodic centre tail exists. -/
theorem kit_right_off_energy_arbitrarily_late (T P : Nat) (hP : 0 < P)
    (hper : ∀ t : Nat, T ≤ t →
      Rule30Prize.center (t + P) = Rule30Prize.center t)
    (B : Nat) :
    ∃ t0 : Nat, B ≤ t0 ∧ T ≤ t0 ∧ Rule30Jen.cell t0 0 = false ∧
      2 ≤ offEnergy (2 * P) P (window (fun t => Rule30Jen.cell t 1) t0) := by
  have hf : FinConfig Rule30Realization.seed := by
    refine ⟨0, ?_⟩
    intro p hp
    have hn : p ≠ 0 := by
      intro he
      subst p
      simp at hp
    simp [Rule30Realization.seed, hn]
  have hn : ∃ p : Int, Rule30Realization.seed p = true := ⟨0, by decide⟩
  have hp : ∀ t : Nat, T ≤ t →
      evol Rule30Realization.seed (t + P) 0 = evol Rule30Realization.seed t 0 := by
    intro t ht
    simpa only [Rule30Realization.evol_seed, Rule30Prize.center] using hper t ht
  obtain ⟨t0, hB, hT, hw, he⟩ := right_off_energy_arbitrarily_late
    Rule30Realization.seed T P hf hn hP hp B
  refine ⟨t0, hB, hT, ?_, ?_⟩
  · simpa only [Rule30Realization.evol_seed] using hw
  · simpa only [Rule30Realization.evol_seed] using he

end FVLT.Rule30TemporalLeakEnergyV1
end
