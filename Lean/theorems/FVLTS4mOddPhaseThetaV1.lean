import FVLTS4mCoordinatesV1
import Ruliology.CellularAutomata.Rule30ZeroBoundary

/-! PRIVATE S4m source-only supplement. The odd-black phase is not identified
with Theta at time0. One actual zero-boundary step reaches the even-time
constraint, and the original head bit is retained by the kit backward map.
No bijection Bool × streams, finite-state result or mortality claim is made. -/
set_option autoImplicit false

namespace FVLT.S4mOddPhaseThetaV1

open Ruliology.CellularAutomata Rule30DrivenLeft Rule30ZeroBoundary
open FVLT.S4gLeftScreenV1 FVLT.S4gForcedBitCountV1 FVLT.S4gLBEImplicationV1
open FVLT.S4hInfinitePinsV1 FVLT.S4kCoreV1 FVLT.S4lZeroBoundaryV1
open FVLT.S4mCoordinatesV1

noncomputable def initial01Row (u : Nat → Bool) : Nat → Bool :=
  depthRow (bitRow (completion01 u))

/-- Odd-time heads of the row after one step, hence original even times2i+2. -/
noncomputable def temporal01OfInitial (u : Nat → Bool) (i : Nat) : Bool :=
  zrow (initial01Row u) (2 * i + 2) 1

/-- The raw phase01 constraint is at ODD zero-boundary times. -/
theorem completion01_odd_samples (u : Nat → Bool) (i : Nat) :
    zrow (initial01Row u) (2 * i + 1) 1 = true := by
  have hs : ∀ K : Nat, Surv c01 (bitRow (completion01 u)) K :=
    fun K => pins_surv (infiniteBits_pins c01 (input01 u)) K
  have hc : IsolatedBlack c01 := singleBlack_isolated (by omega) ⟨1, by omega⟩
  have hb : c01 (2 * i + 1) = true := by
    simp [c01, singleBlack, show (2 * i + 1) % 2 = 1 by omega]
  have hh := (all_surv_iff_zeroSamples c01 _ hc).mp hs (2 * i + 1) hb
  have he := L_eq_zrow (bitRow (completion01 u)) (2 * i + 1) 1 (Nat.le_refl 1)
  change L (fun _ => false) (bitRow (completion01 u)) (2 * i + 1) (-1) =
    zrow (initial01Row u) (2 * i + 1) 1 at he
  exact he.symm.trans hh

/-- After one actual step the odd-time constraint becomes the kit InX. -/
theorem shifted01_inX (u : Nat → Bool) : InX (zrow (initial01Row u) 1) := by
  intro i
  rw [← zrow_shift]
  rw [show 1 + 2 * i = 2 * i + 1 by omega]
  exact completion01_odd_samples u i

/-- Full row equality, including the white wall, after the one-step restart. -/
theorem completion01_after_one_theta (u : Nat → Bool) :
    zrow (initial01Row u) 1 = Theta (temporal01OfInitial u) := by
  have hf : ∀ i : Nat,
      zrow (zrow (initial01Row u) 1) (2 * i + 1) 1 = temporal01OfInitial u i := by
    intro i
    rw [← zrow_shift]
    change zrow (initial01Row u) (1 + (2 * i + 1)) 1 =
      zrow (initial01Row u) (2 * i + 2) 1
    rw [show 1 + (2 * i + 1) = 2 * i + 2 by omega]
  have he := Theta_unique (shifted01_inX u) hf
  rw [zrow_zero_self (zrow_wall (initial01Row u) 1)] at he
  exact he

/-- Recover the original phase01 row using its free INITIAL head u0. -/
theorem completion01_back_theta (u : Nat → Bool) (d : Nat) (hd : 1 ≤ d) :
    initial01Row u d = back (u 0) (Theta (temporal01OfInitial u)) d := by
  have hh : initial01Row u 1 = u 0 := by
    have hb := bitRow_at (completion01 u) 0
    change initial01Row u 1 = completion01 u 0 at hb
    exact hb.trans (completion01_white u 0)
  have he := eq_back (L := initial01Row u) (y := Theta (temporal01OfInitial u))
    (fun k hk => congrFun (completion01_after_one_theta u) k) d
  rw [zrow_zero_of_pos _ hd, hh] at he
  exact he

end FVLT.S4mOddPhaseThetaV1
