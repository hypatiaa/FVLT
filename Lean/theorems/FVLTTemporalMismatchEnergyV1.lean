import FVLTConductorProjectorsV1
import FVLTS4nPrimeReadoutV1

/-!
Exact temporal windows of length 2P, real complete-residue SUM energy, no taper.
Coexistence of zero centre off-energy and positive neighbour off-energy is not a
contradiction. This module claims no exclusion of eventual centre periodicity,
bounded waiting time, cancellation estimate, Q01/CQ01 solution or prize result.
The mean-scale reading offEnergy/(2P) >= 1/P is a remark, not a seventh target.
-/
set_option autoImplicit false
noncomputable section
namespace FVLT.TemporalMismatchEnergyV1
open Ruliology.CellularAutomata.FVLTPeriodProjectorsV1
open Ruliology.CellularAutomata.FVLTConductorProjectorsV1
open scoped BigOperators

-- BEGIN FROZEN DEFINITIONS
def offEnergy (N P : Nat) (x : Nat → Real) : Real :=
  ∑ q ∈ N.divisors.filter (fun q => ¬ q ∣ P), E_full (K := Real) N q x

def window (f : Nat → Bool) (t0 j : Nat) : Real :=
  FVLT.S4nPrimeReadoutV1.spin (fun t => f (t0 + t)) j

def mismatchCount (P : Nat) (f : Nat → Bool) (t0 : Nat) : Nat :=
  ((Finset.range P).filter (fun j => f (t0 + j) ≠ f (t0 + P + j))).card
-- END FROZEN DEFINITIONS

/-- Exact real sum-scale conductor residual of two consecutive blocks; P is positive. -/
theorem off_energy_two_block (P : Nat) (hP : 0 < P) (x : Nat → Real) :
    offEnergy (2 * P) P x =
      ((1 : Real) / 2) * ∑ j ∈ Finset.range P, (x j - x (P + j)) ^ 2 := by
  have hN : 0 < 2 * P := by omega
  have hd : P ∣ 2 * P := ⟨2, by omega⟩
  have hf : (2 * P).divisors.filter (fun q => q ∣ P) = P.divisors := by
    ext q
    simp only [Finset.mem_filter, Nat.mem_divisors]
    constructor
    · rintro ⟨⟨_, _⟩, hq⟩
      exact ⟨hq, by omega⟩
    · rintro ⟨hq, _⟩
      exact ⟨⟨dvd_trans hq hd, by omega⟩, hq⟩
  have hs := Finset.sum_filter_add_sum_filter_not (2 * P).divisors
    (fun q => q ∣ P) (fun q => E_full (K := Real) (2 * P) q x)
  rw [hf, sum_E_full_divisors_eq_F_fold hN hd x,
    sum_E_full_eq_norm_sq hN x] at hs
  change F_fold (2 * P) P x + offEnergy (2 * P) P x = _ at hs
  have hdiv : 2 * P / P = 2 := by
    simpa [Nat.mul_comm] using Nat.mul_div_cancel_left 2 hP
  have hfold := F_fold_eq_sum_foldSum_sq hN hd x
  have hfs (r : Nat) : foldSum (2 * P) P x r = x r + x (P + r) := by
    simp [foldSum, hdiv, Finset.sum_range_succ, Nat.add_comm]
  simp only [hdiv, Nat.cast_ofNat, hfs] at hfold
  have hnorm : (∑ t ∈ Finset.range (2 * P), x t * x t) =
      ∑ j ∈ Finset.range P, (x j * x j + x (P + j) * x (P + j)) := by
    rw [show 2 * P = P + P by omega, Finset.sum_range_add, Finset.sum_add_distrib]
  rw [hnorm, hfold] at hs
  have hid : (∑ j ∈ Finset.range P, (x j * x j + x (P+j) * x (P+j))) -
      (2 : Real)⁻¹ * (∑ j ∈ Finset.range P, (x j+x (P+j))*(x j+x (P+j))) =
      ((1 : Real)/2) * ∑ j ∈ Finset.range P, (x j-x (P+j))^2 := by
    rw [Finset.mul_sum, ← Finset.sum_sub_distrib, Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j _
    ring
  linarith

/-- Exact Boolean mismatch count in the true=+1, false=-1 convention. -/
theorem off_energy_eq_twice_mismatchCount (P : Nat) (hP : 0 < P)
    (f : Nat → Bool) (t0 : Nat) :
    offEnergy (2 * P) P (window f t0) = 2 * (mismatchCount P f t0 : Real) := by
  rw [off_energy_two_block P hP]
  calc
    ((1 : Real) / 2) * ∑ j ∈ Finset.range P,
        (window f t0 j - window f t0 (P + j)) ^ 2 =
        ((1 : Real) / 2) * ∑ j ∈ (Finset.range P).filter
          (fun j => f (t0 + j) ≠ f (t0 + P + j)), (4 : Real) := by
      congr 1
      rw [Finset.sum_filter]
      apply Finset.sum_congr rfl
      intro j _
      have pair (a b : Bool) :
          ((if a then (1 : Real) else -1) - (if b then (1 : Real) else -1)) ^ 2 =
            if a ≠ b then (4 : Real) else 0 := by
        cases a <;> cases b <;> norm_num
      simpa only [window, FVLT.S4nPrimeReadoutV1.spin, Nat.add_assoc] using
        pair (f (t0+j)) (f (t0+(P+j)))
    _ = 2 * (mismatchCount P f t0 : Real) := by
      simp only [Finset.sum_const, nsmul_eq_mul]
      unfold mismatchCount
      ring

/-- One witnessed disagreement forces sum-scale off-conductor energy at least two. -/
theorem mismatch_forces_off_energy (P : Nat) (hP : 0 < P)
    (f : Nat → Bool) (t0 j : Nat) (hj : j < P)
    (hne : f (t0 + j) ≠ f (t0 + P + j)) :
    2 ≤ offEnergy (2 * P) P (window f t0) := by
  have hc : 0 < mismatchCount P f t0 := by
    unfold mismatchCount
    exact Finset.card_pos.mpr ⟨j, Finset.mem_filter.mpr ⟨Finset.mem_range.mpr hj, hne⟩⟩
  rw [off_energy_eq_twice_mismatchCount P hP f t0]
  exact_mod_cast (show 2 ≤ 2 * mismatchCount P f t0 by omega)

end FVLT.TemporalMismatchEnergyV1
end
