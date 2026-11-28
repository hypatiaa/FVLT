import FVLTTemporalMismatchEnergyV1
import Ruliology.CellularAutomata.Rule30Realization
import Ruliology.CellularAutomata.Rule30FiniteConfigs
import Ruliology.CellularAutomata.Rule30ZeroBoundaryBarriers

/-!
A2: exact real complete-residue SUM energies on length-2P temporal windows.
The left-neighbour bounds apply to the left only; no right <= 2*w_P assertion.
Period and synchronization hypotheses stay explicit; the equivalence assumes
neither side. No existence of such a finite-seed tail is claimed. Coexistence of
centre zero energy and neighbour positive energy
is not a contradiction. No nonperiodicity, Q01/CQ01, prize, density, bounded-wait
or further-propagation conclusion; O1/O2/O3 stay open. No kernel change.
-/
set_option autoImplicit false
noncomputable section
namespace FVLT.Rule30PeriodicSeedControlV1
open Ruliology.CellularAutomata
open Rule30Realization Rule30PeriodTwoSideways
open FVLT.TemporalMismatchEnergyV1

-- BEGIN FROZEN DEFINITIONS
/-- Spatially 4-periodic seed. Int `%` is emod, including negative positions. -/
def periodicSeed4 (p : Int) : Bool := decide (p % 4 = 0)
-- END FROZEN DEFINITIONS

private theorem evol_mod4 (t : Nat) (p : Int) :
    evol periodicSeed4 t p=evol periodicSeed4 t (p%4) := by
  induction t generalizing p with
  | zero => simp [Rule30Realization.evol,periodicSeed4,Int.emod_emod]
  | succ t ih =>
    change Rule30Jen.rule (evol periodicSeed4 t (p-1)) (evol periodicSeed4 t p)
        (evol periodicSeed4 t (p+1)) =
      Rule30Jen.rule (evol periodicSeed4 t (p%4-1)) (evol periodicSeed4 t (p%4))
        (evol periodicSeed4 t (p%4+1))
    congr 1
    · calc
        evol periodicSeed4 t (p-1)=evol periodicSeed4 t ((p-1)%4) := ih (p-1)
        _ = evol periodicSeed4 t ((p%4-1)%4) := by congr 1; omega
        _ = evol periodicSeed4 t (p%4-1) := (ih (p%4-1)).symm
    · exact ih p
    · calc
        evol periodicSeed4 t (p+1)=evol periodicSeed4 t ((p+1)%4) := ih (p+1)
        _ = evol periodicSeed4 t ((p%4+1)%4) := by congr 1; omega
        _ = evol periodicSeed4 t (p%4+1) := (ih (p%4+1)).symm

private theorem return8_at_residue (r : Fin 4) :
    evol periodicSeed4 8 (r.val : Int)=periodicSeed4 (r.val : Int) := by
  fin_cases r <;> decide

private theorem return8 (p : Int) : evol periodicSeed4 8 p=periodicSeed4 p := by
  have hn : 0≤p%4 := Int.emod_nonneg _ (by decide)
  have hl : p%4<4 := Int.emod_lt_of_pos _ (by decide)
  let r : Fin 4 := ⟨(p%4).toNat,by omega⟩
  have hr : (r.val : Int)=p%4 := by dsimp [r]; omega
  calc
    evol periodicSeed4 8 p=evol periodicSeed4 8 (p%4) := evol_mod4 8 p
    _ = evol periodicSeed4 8 (r.val : Int) := by rw [hr]
    _ = periodicSeed4 (r.val : Int) := return8_at_residue r
    _ = periodicSeed4 p := by simp only [periodicSeed4,hr,Int.emod_emod]

/-- Unconditional infinite-support control on actual full-line evol; not a finite-horizon check. -/
theorem periodicSeed4_not_finite : ¬ FinConfig periodicSeed4 := by
  rintro ⟨W,hW⟩
  let p : Int := (4*(W+1) : Nat)
  have hb : W<p.natAbs := by
    change W<4*(W+1)
    omega
  have hd : p%4=0 := by dsimp [p]; omega
  have hs : periodicSeed4 p=true := by simp [periodicSeed4,hd]
  have hz := hW p hb
  rw [hs] at hz
  cases hz

/-- Unconditional infinite-support control on actual full-line evol; not a finite-horizon check. -/
theorem periodicSeed4_columns_period8 (t : Nat) :
    evol periodicSeed4 (t + 8) 0 = evol periodicSeed4 t 0 ∧
    evol periodicSeed4 (t + 8) 1 = evol periodicSeed4 t 1 := by
  have hrow : (fun p : Int => evol periodicSeed4 8 p)=periodicSeed4 := funext return8
  have he (p : Int) : evol periodicSeed4 (t+8) p=evol periodicSeed4 t p := by
    have h := Rule30ZeroBoundaryBarriers.evol_restart periodicSeed4 8 t p
    rw [hrow] at h
    simpa only [Nat.add_comm] using h.symm
  exact ⟨he 0,he 1⟩

/-- Unconditional infinite-support control on actual full-line evol; not a finite-horizon check. -/
theorem periodicSeed4_right_off_energy_zero (t0 : Nat) :
    offEnergy 16 8 (window (fun t => evol periodicSeed4 t 1) t0) = 0 := by
  rw [off_energy_eq_twice_mismatchCount 8 (by decide)]
  have hz : mismatchCount 8 (fun t => evol periodicSeed4 t 1) t0=0 := by
    unfold mismatchCount
    apply Finset.card_eq_zero.mpr
    apply Finset.eq_empty_iff_forall_notMem.mpr
    intro j hj
    obtain ⟨_,hne⟩ := Finset.mem_filter.mp hj
    apply hne
    have hp := (periodicSeed4_columns_period8 (t0+j)).2
    simpa only [Nat.add_assoc,Nat.add_comm,Nat.add_left_comm] using hp.symm
  rw [hz]
  norm_num

end FVLT.Rule30PeriodicSeedControlV1
end
