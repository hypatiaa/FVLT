import S4m_G_PeriodTwoResidualsV1

set_option autoImplicit false

/-!
# S4n-G (Target I: Period 2): Inter-Phase `back` Stream Recurrences (I-1),
# Left-Context Latch Obstruction `[0,0,1] ≁ [0,1,1]` (I-2), and
# First Phase-`10` Merge at Depth 3 (`[0,0,0] ~ [1,0,1]`) (I-3)

Formalizes the theorem suite for Study `S4n-G` (`#1242`, `#1244`, `#1246`,
`WORK_ORDER.md` `b88988c0...` and `WORK_ORDER_ADDENDUM_1.md` `03aeef99...`) against
Rule 30 Theorem Library `v8` (`SHA256SUMS` `2124f3a6...`, `LIBRARY_MANIFEST` `92746b7c...`):

1. **Target I-1 — One-Step Inter-Phase Stream Recurrences in Boolean and `±1` Spin Form
   (`back_evenAt_eq`, `oddAt_eq_xor_back_evenAt`, `back_oddAt_succ`,
   `evenAt_eq_xor_back_oddAt_succ`, `wStepFromFalse`, `uStepFromTrue`,
   `compressedPhi_false_succ_eq`, `compressedPhi_true_succ_eq`,
   `spin_uStepFromTrue_eq`, `two_mul_spin_uStepFromTrue_eq`,
   `spin_compressedPhi_true_succ_eq`, `two_mul_spin_compressedPhi_true_succ_eq`,
   `spin_wStepFromFalse_eq`, `two_mul_spin_wStepFromFalse_eq`,
   `spin_compressedPhi_false_succ_eq`, `two_mul_spin_compressedPhi_false_succ_eq`):**
   - Proves the one-step `back` coordinate and stream recurrences linking driver `01`
     (`compressedPhi false`) and driver `10` (`compressedPhi true`), using the `#1238`
     corrected index `u_j = w_j ⊕ (z_j ∨ w_{j-1})` for all `j ≥ 0` (with `z_0 = true` and
     `w_{-1} := false`) and `z_{j+1} = y_j ⊕ (w_j ∨ z_j)`.
   - Explicitly labels these recurrences as **one-step stream and coordinate relations**,
     not as a claim that `compressedPhi` is a finite-state machine.
   - Proves the `±1` spin form over `Int` (`spin false = 1`, `spin true = -1`), where
     `(-1)^c` is plain 1D sign negation (`spin_xor`, `spin_not`, `spin_sign_negation`) and
     Boolean OR satisfies `2 * spin (a || b) = -1 + spin a + spin b + spin a * spin b`
     (`two_mul_spin_or`).

2. **Target I-2 — Left-Context Latch Obstruction `[0,0,1] ≁ [0,1,1]` in Phase `01`
   (`compressedPhi_true_at_two`, `compressedPhi_false_at_two`,
   `compressedPhi_true_at_three`, `compressedPhi_false_at_three`,
   `compressedPhi_true_at_four`, `compressedPhi_false_at_four`,
   `compressedPhi_false_001_at_two`, `compressedPhi_false_011_at_two`,
   `residual_false_001_at_zero`, `residual_false_011_at_zero`,
   `residualEquivUpTo_false_one_001_011`,
   `residual_false_001_at_one_constTrue`, `residual_false_011_at_one_constTrue`,
   `residual_false_sep_001_011`, `not_residualEquiv_false_001_011`,
   `not_all_left_context_latch_merge_false`, `residualEquiv_append_right`,
   `residualEquiv_false_latch_merge_append`):**
   - Derives closed-form output laws at depths `2`, `3`, and `4` directly through the
     `I-1` inter-phase stream recurrences `compressedPhi_true_succ_eq` and
     `compressedPhi_false_succ_eq`.
   - Proves that while `[false, true] ~ [true, true]` merges unconditionally at the root
     (and under all right suffix extensions `[false, true] ++ s ~ [true, true] ++ s`),
     prepending the left context `w = [false]` breaks the merge:
     * At step `j = 2`, emitted outputs already differ (`true` vs. `false`).
     * At residual lookahead `k = 0` (`j = 3`), both prefixes output `false` for all
       continuations (`ResidualEquivUpTo (compressedPhi false) 1 [false, false, true] [false, true, true]`).
     * At residual lookahead `k = 1` (`j = 4`), under the explicit continuation
       `constTrue := fun _ => true`, `[false, false, true]` outputs `true` while
       `[false, true, true]` outputs `false`, proving `[0,0,1] ≁ [0,1,1]` and refuting
       `∀ w, R(w01) = R(w11)`.

3. **Target I-3 — The First Merge of Phase `10` at Depth 3 (`[0,0,0] ~ [1,0,1]`)
   (`trueLatchSwapBits`, `L_trueLatchSwapBits_one_eq_le_neg3`,
   `L_trueLatchSwapBits_two_eq`, `L_trueLatchSwapBits_eq_from_two`,
   `pins_trueLatchSwapBits`, `infiniteBits_101_eq_trueLatchSwapBits`,
   `residual_true_latch_merge_depth3`, `residualEquiv_true_latch_merge_depth3`,
   `uStepFromTrue_000_prefix`, `uStepFromTrue_101_prefix`,
   `uStepFromTrue_000_eq_101_from_two`, `residual_true_sep_100_001`):**
   - Proves the unconditional all-continuation Myhill–Nerode merge at depth `3` in Phase `10`
     for the **same** continuation:
     `residual (compressedPhi true) [false, false, false] = residual (compressedPhi true) [true, false, true]`.
   - Proves that the `back true` continuation map `uStepFromTrue` maps
     `prepend [false, false, false] z` and `prepend [true, false, true] z` to the
     Phase-`01` root latch pair `(true, true)` and `(false, true)` followed by the
     **exact same** Phase-`01` continuation tail from index `2` onward.
   - Proves that the sibling candidate pair `[true, false, false]` and `[false, false, true]`
     remains separated at lookahead `k = 0` (`j = 3`), accounting for the `8 → 7` class
     reduction (single girth-6 cycle) at depth `3` in `S4m`.

Note on FVLT package provenance (`#1242`, `#1244`): `FVLTPeriodProjectorsV1`,
`FVLTConductorProjectorsV1`, and `FVLTRule30WindowBridgeV1` belong to the standalone
`2026-10-28` FVLT-H1 projector package (`fvlt_h1_projectors_v0_1_20261028/`) and are not
in Library `v8`.
-/

namespace FVLT.S4nPeriodTwoTargetIV1

open Ruliology.CellularAutomata
open Rule30DrivenLeft
open Rule30ZeroBoundary
open FVLT.S4gLBEImplicationV1
open FVLT.S4hInfinitePinsV1
open FVLT.S4hFiniteTailV1
open FVLT.S4iResidualV1
open FVLT.S4iUniformLatchV1
open FVLT.S4lZeroBoundaryPotentialsV1
open FVLT.S4mPeriodTwoResidualsV1

-- ============================================================================
-- 1. Target I-1: Row-Level & Stream-Level Inter-Phase `back` Recurrences
-- ============================================================================

theorem xor_self_right (a b : Bool) : xor (xor a b) b = a := by
  cases a <;> cases b <;> rfl

theorem or_comm_bool (a b : Bool) : (a || b) = (b || a) := by
  cases a <;> cases b <;> rfl

/-- Odd spatial depths `2j + 1` of a 1-indexed ZBL row `R` (white inputs `u_j` for phase `01`,
black outputs `z_j` for phase `10`). -/
def oddAt (R : Nat → Bool) (j : Nat) : Bool := R (2 * j + 1)

/-- Even spatial depths `2j + 2` of a 1-indexed ZBL row `R` (black outputs `y_j` for phase `01`,
white inputs `w_j` for phase `10`). -/
def evenAt (R : Nat → Bool) (j : Nat) : Bool := R (2 * j + 2)

/-- Shifted stream accessor `w_{j-1}` with boundary convention `w_{-1} := false` at `j = 0`. -/
def prevStream (w : Stream) : Nat → Bool
  | 0 => false
  | j + 1 => w j

/-- Previous even depth `R (2j)` with boundary convention `false` at `j = 0`. -/
def prevEvenAt (R : Nat → Bool) (j : Nat) : Bool :=
  prevStream (evenAt R) j

/-- 0-indexed bit sequence extracted from positive depths `n + 1` of a ZBL row `R`. -/
def bitsOfZrow (R : Nat → Bool) (n : Nat) : Bool := R (n + 1)

theorem zrowOfBits_bitsOfZrow (R : Nat → Bool) (hwall : R 0 = false) :
    zrowOfBits (bitsOfZrow R) = R := by
  funext k
  cases k with
  | zero => exact hwall.symm
  | succ n => exact zrowOfBits_succ (bitsOfZrow R) n

theorem back_oddAt_zero (b : Bool) (R : Nat → Bool) :
    oddAt (back b R) 0 = b := rfl

theorem back_evenAt_zero (b : Bool) (R : Nat → Bool) :
    evenAt (back b R) 0 = xor (R 1) b := by
  change xor (R 1) (b || false) = xor (R 1) b
  cases R 1 <;> cases b <;> rfl

/-- **Row-level even-depth `back` stream relation (`Target I-1`):**
For all `j ≥ 0`, `evenAt (back b R) j = xor (oddAt R j) (oddAt (back b R) j || prevEvenAt (back b R) j)`.
Labelled strictly as a one-step stream/coordinate relation, not a finite-state claim. -/
theorem back_evenAt_eq (b : Bool) (R : Nat → Bool) (j : Nat) :
    evenAt (back b R) j =
      xor (oddAt R j) (oddAt (back b R) j || prevEvenAt (back b R) j) := by
  cases j with
  | zero => rfl
  | succ j' =>
    unfold evenAt oddAt prevEvenAt prevStream
    have h2 : 2 * (j' + 1) + 2 = (2 * j' + 2) + 2 := by omega
    have h1 : (2 * j' + 2) + 1 = 2 * (j' + 1) + 1 := by omega
    rw [h2, back_add_two b R (2 * j' + 2), h1]
    rfl

/-- **Row-level `#1238` corrected-index stream relation (`Target I-1`):**
For `Y = back b R`, `u_j = w_j ⊕ (z_j ∨ w_{j-1})` for all `j ≥ 0`, with `w_{-1} = false`. -/
theorem oddAt_eq_xor_back_evenAt (b : Bool) (R : Nat → Bool) (j : Nat) :
    oddAt R j =
      xor (evenAt (back b R) j) (oddAt (back b R) j || prevEvenAt (back b R) j) := by
  rw [back_evenAt_eq, xor_self_right]

/-- **Row-level odd-depth `back` stream relation (`Target I-1`):**
For all `j ≥ 0`, `oddAt (back b R) (j + 1) = xor (evenAt R j) (evenAt (back b R) j || oddAt (back b R) j)`.
For `Y = back true L`, this is `z_{j+1} = y_j ⊕ (w_j ∨ z_j)`. -/
theorem back_oddAt_succ (b : Bool) (R : Nat → Bool) (j : Nat) :
    oddAt (back b R) (j + 1) =
      xor (evenAt R j) (evenAt (back b R) j || oddAt (back b R) j) := by
  unfold oddAt evenAt
  have h2 : 2 * (j + 1) + 1 = (2 * j + 1) + 2 := by omega
  have h1 : (2 * j + 1) + 1 = 2 * j + 2 := by omega
  rw [h2, back_add_two b R (2 * j + 1), h1]

/-- **Row-level inverted odd-depth `back` stream relation (`Target I-1`):**
For `L = back u0 Y`, `w_j = u_{j+1} ⊕ (u_j ∨ y_j)` for all `j ≥ 0`. -/
theorem evenAt_eq_xor_back_oddAt_succ (b : Bool) (R : Nat → Bool) (j : Nat) :
    evenAt R j =
      xor (oddAt (back b R) (j + 1)) (oddAt (back b R) j || evenAt (back b R) j) := by
  rw [back_oddAt_succ, or_comm_bool (oddAt (back b R) j) (evenAt (back b R) j), xor_self_right]

/-- **One-step backward reconstruction identity (`self_eq_back_zrow_one`):**
Every ZBL row `R` with wall `R 0 = false` equals `back (R 1) (zrow R 1)`. -/
theorem self_eq_back_zrow_one (R : Nat → Bool) (hwall : R 0 = false) (k : Nat) :
    R k = back (R 1) (zrow R 1) k := by
  have h := eq_back (L := R) (y := zrow R 1) (fun _ _ => rfl) k
  rwa [zrow_zero_self hwall] at h

theorem inX_iff_pins_driver_true_bitsOfZrow (Y : Nat → Bool) (hwall : Y 0 = false) :
    InX Y ↔ Pins (driver true) (bitRow (bitsOfZrow Y)) := by
  rw [pins_driver_true_iff_inX, zrowOfBits_bitsOfZrow Y hwall]

theorem infiniteBits_true_eq_bitsOfZrow (Y : Nat → Bool) (hwall : Y 0 = false) (hX : InX Y) :
    infiniteBits (driver true) (expandWhite true (evenAt Y)) = bitsOfZrow Y := by
  symm
  apply infiniteBits_unique (driver true) (expandWhite true (evenAt Y))
    (bitsOfZrow Y) ((inX_iff_pins_driver_true_bitsOfZrow Y hwall).mp hX)
  intro i
  change Y (i.val + 1) = Y (2 * (i.val / 2) + 2)
  have hw := whiteAt_of_white true i.val i.property
  simp [whiteAt] at hw
  exact congrArg Y (by omega)

theorem compressedPhi_true_evenAt_of_inX (Y : Nat → Bool) (hwall : Y 0 = false) (hX : InX Y) :
    compressedPhi true (evenAt Y) = oddAt Y := by
  funext j
  change infiniteBits (driver true) (expandWhite true (evenAt Y)) (blackAt true j) = Y (2 * j + 1)
  rw [infiniteBits_true_eq_bitsOfZrow Y hwall hX]
  rfl

theorem pins_driver_false_bitsOfZrow_iff (L : Nat → Bool) (hwall : L 0 = false) :
    Pins (driver false) (bitRow (bitsOfZrow L)) ↔
      ∀ t : Nat, driver false t = true → zrow L t 1 = true := by
  rw [pins_driver_iff_zrow, zrowOfBits_bitsOfZrow L hwall]

theorem infiniteBits_false_eq_bitsOfZrow (L : Nat → Bool) (_hwall : L 0 = false)
    (hpins : Pins (driver false) (bitRow (bitsOfZrow L))) :
    infiniteBits (driver false) (expandWhite false (oddAt L)) = bitsOfZrow L := by
  symm
  apply infiniteBits_unique (driver false) (expandWhite false (oddAt L))
    (bitsOfZrow L) hpins
  intro i
  change L (i.val + 1) = L (2 * (i.val / 2) + 1)
  have hw := whiteAt_of_white false i.val i.property
  simp [whiteAt] at hw
  exact congrArg L (by omega)

theorem compressedPhi_false_oddAt_of_pins (L : Nat → Bool) (hwall : L 0 = false)
    (hpins : Pins (driver false) (bitRow (bitsOfZrow L))) :
    compressedPhi false (oddAt L) = evenAt L := by
  funext j
  change infiniteBits (driver false) (expandWhite false (oddAt L)) (blackAt false j) = L (2 * j + 2)
  rw [infiniteBits_false_eq_bitsOfZrow L hwall hpins]
  rfl

theorem driver_false_odd (s : Nat) : driver false (1 + 2 * s) = true := by
  rw [show 1 + 2 * s = 2 * s + 1 by omega, driver_alternates]
  simp [driver]

theorem inX_zrow_one_of_pins_false (L : Nat → Bool) (hwall : L 0 = false)
    (hpins : Pins (driver false) (bitRow (bitsOfZrow L))) :
    InX (zrow L 1) := by
  intro s
  rw [← zrow_shift L 1 (2 * s) 1]
  exact (pins_driver_false_bitsOfZrow_iff L hwall).mp hpins (1 + 2 * s) (driver_false_odd s)

theorem pins_false_zrow_one_of_inX (Y : Nat → Bool) (hX : InX Y) :
    Pins (driver false) (bitRow (bitsOfZrow (zrow Y 1))) := by
  rw [pins_driver_false_bitsOfZrow_iff (zrow Y 1) (zrow_wall Y 1)]
  intro t ht
  by_cases hev : t % 2 = 0
  · simp [driver, hev] at ht
  · rw [← zrow_shift Y 1 t 1]
    have ht2 : 1 + t = 2 * (t / 2 + 1) := by omega
    rw [ht2]
    exact hX (t / 2 + 1)

theorem oddAt_zrowOfBits_false (u : Stream) (j : Nat) :
    oddAt (zrowOfBits (infiniteBits (driver false) (expandWhite false u))) j = u j := by
  change zrowOfBits (infiniteBits (driver false) (expandWhite false u)) (2 * j + 1) = u j
  rw [zrowOfBits_succ]
  exact infiniteBits_at_white false u j

theorem evenAt_zrowOfBits_false (u : Stream) (j : Nat) :
    evenAt (zrowOfBits (infiniteBits (driver false) (expandWhite false u))) j =
      compressedPhi false u j := by
  change zrowOfBits (infiniteBits (driver false) (expandWhite false u)) ((2 * j + 1) + 1) =
    compressedPhi false u j
  rw [zrowOfBits_succ]
  rfl

theorem oddAt_zrowOfBits_true (w : Stream) (j : Nat) :
    oddAt (zrowOfBits (infiniteBits (driver true) (expandWhite true w))) j =
      compressedPhi true w j := by
  change zrowOfBits (infiniteBits (driver true) (expandWhite true w)) (2 * j + 1) =
    compressedPhi true w j
  rw [zrowOfBits_succ]
  rfl

theorem evenAt_zrowOfBits_true (w : Stream) (j : Nat) :
    evenAt (zrowOfBits (infiniteBits (driver true) (expandWhite true w))) j = w j := by
  change zrowOfBits (infiniteBits (driver true) (expandWhite true w)) ((2 * j + 1) + 1) = w j
  rw [zrowOfBits_succ]
  exact infiniteBits_at_white true w j

theorem prevEvenAt_zrowOfBits_true (w : Stream) (j : Nat) :
    prevEvenAt (zrowOfBits (infiniteBits (driver true) (expandWhite true w))) j =
      prevStream w j := by
  cases j with
  | zero => rfl
  | succ j' => exact evenAt_zrowOfBits_true w j'

/-- Induced next-step phase-`10` white stream from a phase-`01` white stream `u`
(`w_j = u_{j+1} ⊕ (u_j ∨ Φ_{01}(u)_j)`). -/
noncomputable def wStepFromFalse (u : Stream) (j : Nat) : Bool :=
  xor (u (j + 1)) (u j || compressedPhi false u j)

/-- Induced next-step phase-`01` white stream from a phase-`10` white stream `w`
with the `#1238` corrected index (`u_j = w_j ⊕ (Φ_{10}(w)_j ∨ w_{j-1})`, `w_{-1} := false`). -/
noncomputable def uStepFromTrue (w : Stream) (j : Nat) : Bool :=
  xor (w j) (compressedPhi true w j || prevStream w j)

theorem evenAt_zrow_one_false_eq_wStepFromFalse (u : Stream) :
    evenAt (zrow (zrowOfBits (infiniteBits (driver false) (expandWhite false u))) 1) =
      wStepFromFalse u := by
  let a := infiniteBits (driver false) (expandWhite false u)
  let L := zrowOfBits a
  have hL : back (u 0) (zrow L 1) = L := by
    funext k
    have h1 : L 1 = u 0 := oddAt_zrowOfBits_false u 0
    rw [← h1]
    exact (self_eq_back_zrow_one L (zrowOfBits_zero a) k).symm
  funext j
  rw [evenAt_eq_xor_back_oddAt_succ (u 0) (zrow L 1) j, hL,
    oddAt_zrowOfBits_false u (j + 1), oddAt_zrowOfBits_false u j, evenAt_zrowOfBits_false u j]
  rfl

/-- **Target I-1a (`compressedPhi_false_succ_eq`):**
One-step stream relation expressing `compressedPhi false u (j + 1)` in terms of
`compressedPhi true (wStepFromFalse u) (j + 1)`.
Labelled as a stream relation, not a finite-state claim. -/
theorem compressedPhi_false_succ_eq (u : Stream) (j : Nat) :
    compressedPhi false u (j + 1) =
      xor (compressedPhi true (wStepFromFalse u) (j + 1))
        (u (j + 1) || compressedPhi false u j) := by
  let a := infiniteBits (driver false) (expandWhite false u)
  let L := zrowOfBits a
  have hL : back (u 0) (zrow L 1) = L := by
    funext k
    have h1 : L 1 = u 0 := oddAt_zrowOfBits_false u 0
    rw [← h1]
    exact (self_eq_back_zrow_one L (zrowOfBits_zero a) k).symm
  have hbits : bitsOfZrow L = a := by
    funext n
    exact zrowOfBits_succ a n
  have hpins : Pins (driver false) (bitRow (bitsOfZrow L)) := by
    rw [hbits]
    exact infiniteBits_pins (driver false) (expandWhite false u)
  have hX : InX (zrow L 1) := inX_zrow_one_of_pins_false L (zrowOfBits_zero a) hpins
  have hoddY : oddAt (zrow L 1) (j + 1) = compressedPhi true (wStepFromFalse u) (j + 1) := by
    have hphi := congrFun (compressedPhi_true_evenAt_of_inX (zrow L 1) (zrow_wall L 1) hX) (j + 1)
    rw [evenAt_zrow_one_false_eq_wStepFromFalse u] at hphi
    exact hphi.symm
  have hstep := back_evenAt_eq (u 0) (zrow L 1) (j + 1)
  rw [hL, oddAt_zrowOfBits_false u (j + 1), evenAt_zrowOfBits_false u (j + 1), hoddY] at hstep
  change compressedPhi false u (j + 1) =
    xor (compressedPhi true (wStepFromFalse u) (j + 1))
      (u (j + 1) || evenAt L j) at hstep
  rwa [evenAt_zrowOfBits_false u j] at hstep

theorem oddAt_zrow_one_true_eq_uStepFromTrue (w : Stream) :
    oddAt (zrow (zrowOfBits (infiniteBits (driver true) (expandWhite true w))) 1) =
      uStepFromTrue w := by
  let a := infiniteBits (driver true) (expandWhite true w)
  let Y := zrowOfBits a
  have hY : back true (zrow Y 1) = Y := by
    funext k
    have h1 : Y 1 = true := by
      change zrowOfBits a 1 = true
      rw [zrowOfBits_succ]
      exact compressedPhi_true_at_zero w
    rw [← h1]
    exact (self_eq_back_zrow_one Y (zrowOfBits_zero a) k).symm
  funext j
  rw [oddAt_eq_xor_back_evenAt true (zrow Y 1) j, hY,
    evenAt_zrowOfBits_true w j, oddAt_zrowOfBits_true w j, prevEvenAt_zrowOfBits_true w j]
  rfl

/-- **Target I-1b (`compressedPhi_true_succ_eq`, with `#1238` corrected index):**
One-step stream relation expressing `compressedPhi true w (j + 1)` in terms of
`compressedPhi false (uStepFromTrue w) j`, where
`uStepFromTrue w j = w j ⊕ (compressedPhi true w j ∨ prevStream w j)`.
Labelled as a stream relation, not a finite-state claim. -/
theorem compressedPhi_true_succ_eq (w : Stream) (j : Nat) :
    compressedPhi true w (j + 1) =
      xor (compressedPhi false (uStepFromTrue w) j)
        (w j || compressedPhi true w j) := by
  let a := infiniteBits (driver true) (expandWhite true w)
  let Y := zrowOfBits a
  have hY : back true (zrow Y 1) = Y := by
    funext k
    have h1 : Y 1 = true := by
      change zrowOfBits a 1 = true
      rw [zrowOfBits_succ]
      exact compressedPhi_true_at_zero w
    rw [← h1]
    exact (self_eq_back_zrow_one Y (zrowOfBits_zero a) k).symm
  have hX : InX Y :=
    (pins_driver_true_iff_inX a).mp (infiniteBits_pins (driver true) (expandWhite true w))
  have hpinsL : Pins (driver false) (bitRow (bitsOfZrow (zrow Y 1))) :=
    pins_false_zrow_one_of_inX Y hX
  have hevenL : evenAt (zrow Y 1) j = compressedPhi false (uStepFromTrue w) j := by
    have hphi := congrFun (compressedPhi_false_oddAt_of_pins (zrow Y 1) (zrow_wall Y 1) hpinsL) j
    rw [oddAt_zrow_one_true_eq_uStepFromTrue w] at hphi
    exact hphi.symm
  have hstep := back_oddAt_succ true (zrow Y 1) j
  rw [hY, oddAt_zrowOfBits_true w (j + 1), oddAt_zrowOfBits_true w j,
    evenAt_zrowOfBits_true w j, hevenL] at hstep
  exact hstep

-- ============================================================================
-- 2. Target I-1: `±1` Spin Form (`spin : Bool → Int`, Plain 1D Sign Negation)
-- ============================================================================

/-- 1D `{+1, -1}` spin encoding `(-1)^b` in `Int`: `false ↦ +1`, `true ↦ -1`. -/
def spin (b : Bool) : Int :=
  if b then -1 else 1

theorem spin_false : spin false = 1 := rfl
theorem spin_true : spin true = -1 := rfl

/-- In 1D spins, Boolean negation is plain sign negation (`-spin b`). -/
theorem spin_not (b : Bool) : spin (!b) = -spin b := by
  cases b <;> rfl

/-- In 1D spins, `xor` is integer multiplication, so `(-1)^c` acts by plain sign negation. -/
theorem spin_xor (a b : Bool) : spin (xor a b) = spin a * spin b := by
  cases a <;> cases b <;> rfl

theorem spin_sign_negation (c : Bool) (s : Int) :
    spin c * s = if c then -s else s := by
  cases c <;> simp [spin]

/-- Exact degree-2 bilinear spin identity for Boolean OR over `Int`. -/
theorem two_mul_spin_or (a b : Bool) :
    2 * spin (a || b) = -1 + spin a + spin b + spin a * spin b := by
  cases a <;> cases b <;> rfl

theorem two_mul_spin_xor_or (x a b : Bool) :
    2 * spin (xor x (a || b)) =
      spin x * (-1 + spin a + spin b + spin a * spin b) := by
  cases x <;> cases a <;> cases b <;> rfl

/-- **Target I-1 (`±1` spin form of `uStepFromTrue`, multiplicative sign negation):** -/
theorem spin_uStepFromTrue_eq (w : Stream) (j : Nat) :
    spin (uStepFromTrue w j) =
      spin (w j) * spin (compressedPhi true w j || prevStream w j) := by
  unfold uStepFromTrue
  exact spin_xor (w j) (compressedPhi true w j || prevStream w j)

/-- **Target I-1 (`±1` spin form of `uStepFromTrue`, expanded bilinear form):** -/
theorem two_mul_spin_uStepFromTrue_eq (w : Stream) (j : Nat) :
    2 * spin (uStepFromTrue w j) =
      spin (w j) *
        (-1 + spin (compressedPhi true w j) + spin (prevStream w j) +
          spin (compressedPhi true w j) * spin (prevStream w j)) := by
  unfold uStepFromTrue
  exact two_mul_spin_xor_or (w j) (compressedPhi true w j) (prevStream w j)

/-- **Target I-1 (`±1` spin form of `compressedPhi_true_succ_eq`, multiplicative sign negation):** -/
theorem spin_compressedPhi_true_succ_eq (w : Stream) (j : Nat) :
    spin (compressedPhi true w (j + 1)) =
      spin (compressedPhi false (uStepFromTrue w) j) *
        spin (w j || compressedPhi true w j) := by
  rw [compressedPhi_true_succ_eq, spin_xor]

/-- **Target I-1 (`±1` spin form of `compressedPhi_true_succ_eq`, expanded bilinear form):** -/
theorem two_mul_spin_compressedPhi_true_succ_eq (w : Stream) (j : Nat) :
    2 * spin (compressedPhi true w (j + 1)) =
      spin (compressedPhi false (uStepFromTrue w) j) *
        (-1 + spin (w j) + spin (compressedPhi true w j) +
          spin (w j) * spin (compressedPhi true w j)) := by
  rw [compressedPhi_true_succ_eq]
  exact two_mul_spin_xor_or (compressedPhi false (uStepFromTrue w) j) (w j) (compressedPhi true w j)

/-- **Target I-1 (`±1` spin form of `wStepFromFalse`, multiplicative sign negation):** -/
theorem spin_wStepFromFalse_eq (u : Stream) (j : Nat) :
    spin (wStepFromFalse u j) =
      spin (u (j + 1)) * spin (u j || compressedPhi false u j) := by
  unfold wStepFromFalse
  exact spin_xor (u (j + 1)) (u j || compressedPhi false u j)

/-- **Target I-1 (`±1` spin form of `wStepFromFalse`, expanded bilinear form):** -/
theorem two_mul_spin_wStepFromFalse_eq (u : Stream) (j : Nat) :
    2 * spin (wStepFromFalse u j) =
      spin (u (j + 1)) *
        (-1 + spin (u j) + spin (compressedPhi false u j) +
          spin (u j) * spin (compressedPhi false u j)) := by
  unfold wStepFromFalse
  exact two_mul_spin_xor_or (u (j + 1)) (u j) (compressedPhi false u j)

/-- **Target I-1 (`±1` spin form of `compressedPhi_false_succ_eq`, multiplicative sign negation):** -/
theorem spin_compressedPhi_false_succ_eq (u : Stream) (j : Nat) :
    spin (compressedPhi false u (j + 1)) =
      spin (compressedPhi true (wStepFromFalse u) (j + 1)) *
        spin (u (j + 1) || compressedPhi false u j) := by
  rw [compressedPhi_false_succ_eq, spin_xor]

/-- **Target I-1 (`±1` spin form of `compressedPhi_false_succ_eq`, expanded bilinear form):** -/
theorem two_mul_spin_compressedPhi_false_succ_eq (u : Stream) (j : Nat) :
    2 * spin (compressedPhi false u (j + 1)) =
      spin (compressedPhi true (wStepFromFalse u) (j + 1)) *
        (-1 + spin (u (j + 1)) + spin (compressedPhi false u j) +
          spin (u (j + 1)) * spin (compressedPhi false u j)) := by
  rw [compressedPhi_false_succ_eq]
  exact two_mul_spin_xor_or (compressedPhi true (wStepFromFalse u) (j + 1)) (u (j + 1)) (compressedPhi false u j)

-- ============================================================================
-- 3. Target I-2: Step-by-Step Reconstruction & Left-Context Obstruction `[0,0,1] ≁ [0,1,1]`
-- ============================================================================

/-- Pure Boolean closed-form function for `compressedPhi false u 2`. -/
def phiFalse2Bool (u0 u1 u2 : Bool) : Bool :=
  xor u1 (u2 || (!u1 && !u0))

/-- Pure Boolean closed-form function for `compressedPhi true w 3`. -/
def phiTrue3Bool (w0 w1 w2 : Bool) : Bool :=
  xor (xor (!w1) (xor w2 (!w0 || w1) || (w1 && w0))) (w2 || !w0)

/-- Pure Boolean closed-form function for `compressedPhi false u 3`. -/
def phiFalse3Bool (u0 u1 u2 u3 : Bool) : Bool :=
  let w0 := !u1
  let w1 := xor u2 (u1 || !u0)
  let y2 := phiFalse2Bool u0 u1 u2
  let w2 := xor u3 (u2 || y2)
  xor (phiTrue3Bool w0 w1 w2) (u3 || y2)

/-- Pure Boolean closed-form function for `compressedPhi true w 4`. -/
def phiTrue4Bool (w0 w1 w2 w3 : Bool) : Bool :=
  let u0 := !w0
  let u1 := !w1
  let u2 := xor w2 (!w0 || w1)
  let z3 := phiTrue3Bool w0 w1 w2
  let u3 := xor w3 (z3 || w2)
  xor (phiFalse3Bool u0 u1 u2 u3) (w3 || z3)

/-- Pure Boolean closed-form function for `compressedPhi false u 4`. -/
def phiFalse4Bool (u0 u1 u2 u3 u4 : Bool) : Bool :=
  let w0 := !u1
  let w1 := xor u2 (u1 || !u0)
  let y2 := phiFalse2Bool u0 u1 u2
  let w2 := xor u3 (u2 || y2)
  let y3 := phiFalse3Bool u0 u1 u2 u3
  let w3 := xor u4 (u3 || y3)
  xor (phiTrue4Bool w0 w1 w2 w3) (u4 || y3)

theorem uStepFromTrue_at_zero (w : Stream) :
    uStepFromTrue w 0 = !(w 0) := by
  unfold uStepFromTrue prevStream
  rw [compressedPhi_true_at_zero]
  cases w 0 <;> rfl

theorem uStepFromTrue_at_one (w : Stream) :
    uStepFromTrue w 1 = !(w 1) := by
  change xor (w 1) (compressedPhi true w 1 || w 0) = !(w 1)
  rw [compressedPhi_true_at_one]
  cases w 0 <;> cases w 1 <;> rfl

theorem wStepFromFalse_at_zero (u : Stream) :
    wStepFromFalse u 0 = !(u 1) := by
  unfold wStepFromFalse
  rw [compressedPhi_false_at_zero]
  cases u 0 <;> cases u 1 <;> rfl

theorem wStepFromFalse_at_one (u : Stream) :
    wStepFromFalse u 1 = xor (u 2) (u 1 || !(u 0)) := by
  unfold wStepFromFalse
  rw [compressedPhi_false_at_one]
  cases u 0 <;> cases u 1 <;> cases u 2 <;> rfl

/-- **Depth-2 closed form for phase `true` (`10`), derived via `I-1` reconstruction:** -/
theorem compressedPhi_true_at_two (w : Stream) :
    compressedPhi true w 2 = !(w 0) := by
  rw [compressedPhi_true_succ_eq w 1, compressedPhi_false_at_one (uStepFromTrue w),
    uStepFromTrue_at_one, uStepFromTrue_at_zero, compressedPhi_true_at_one]
  cases w 0 <;> cases w 1 <;> rfl

theorem uStepFromTrue_at_two (w : Stream) :
    uStepFromTrue w 2 = xor (w 2) (!(w 0) || w 1) := by
  unfold uStepFromTrue prevStream
  rw [compressedPhi_true_at_two]

/-- **Depth-2 closed form for phase `false` (`01`), derived via `I-1` reconstruction:** -/
theorem compressedPhi_false_at_two (u : Stream) :
    compressedPhi false u 2 = phiFalse2Bool (u 0) (u 1) (u 2) := by
  unfold phiFalse2Bool
  rw [compressedPhi_false_succ_eq u 1, compressedPhi_true_at_two (wStepFromFalse u),
    wStepFromFalse_at_zero, compressedPhi_false_at_one]
  cases u 0 <;> cases u 1 <;> cases u 2 <;> rfl

theorem wStepFromFalse_at_two (u : Stream) :
    wStepFromFalse u 2 =
      xor (u 3) (u 2 || phiFalse2Bool (u 0) (u 1) (u 2)) := by
  unfold wStepFromFalse
  rw [compressedPhi_false_at_two]

/-- **Depth-3 closed form for phase `true` (`10`), derived via `I-1` reconstruction:** -/
theorem compressedPhi_true_at_three (w : Stream) :
    compressedPhi true w 3 = phiTrue3Bool (w 0) (w 1) (w 2) := by
  unfold phiTrue3Bool
  rw [compressedPhi_true_succ_eq w 2, compressedPhi_false_at_two (uStepFromTrue w),
    uStepFromTrue_at_zero, uStepFromTrue_at_one, uStepFromTrue_at_two,
    compressedPhi_true_at_two]
  unfold phiFalse2Bool
  cases w 0 <;> cases w 1 <;> cases w 2 <;> rfl

theorem uStepFromTrue_at_three (w : Stream) :
    uStepFromTrue w 3 =
      xor (w 3) (phiTrue3Bool (w 0) (w 1) (w 2) || w 2) := by
  unfold uStepFromTrue prevStream
  rw [compressedPhi_true_at_three]

/-- **Depth-3 closed form for phase `false` (`01`), derived via `I-1` reconstruction:** -/
theorem compressedPhi_false_at_three (u : Stream) :
    compressedPhi false u 3 = phiFalse3Bool (u 0) (u 1) (u 2) (u 3) := by
  unfold phiFalse3Bool
  rw [compressedPhi_false_succ_eq u 2, compressedPhi_true_at_three (wStepFromFalse u),
    wStepFromFalse_at_zero, wStepFromFalse_at_one, wStepFromFalse_at_two,
    compressedPhi_false_at_two]

theorem wStepFromFalse_at_three (u : Stream) :
    wStepFromFalse u 3 =
      xor (u 4) (u 3 || phiFalse3Bool (u 0) (u 1) (u 2) (u 3)) := by
  unfold wStepFromFalse
  rw [compressedPhi_false_at_three]

/-- **Depth-4 closed form for phase `true` (`10`), derived via `I-1` reconstruction:** -/
theorem compressedPhi_true_at_four (w : Stream) :
    compressedPhi true w 4 = phiTrue4Bool (w 0) (w 1) (w 2) (w 3) := by
  unfold phiTrue4Bool
  rw [compressedPhi_true_succ_eq w 3, compressedPhi_false_at_three (uStepFromTrue w),
    uStepFromTrue_at_zero, uStepFromTrue_at_one, uStepFromTrue_at_two,
    uStepFromTrue_at_three, compressedPhi_true_at_three]

/-- **Depth-4 closed form for phase `false` (`01`), derived via `I-1` reconstruction:** -/
theorem compressedPhi_false_at_four (u : Stream) :
    compressedPhi false u 4 = phiFalse4Bool (u 0) (u 1) (u 2) (u 3) (u 4) := by
  unfold phiFalse4Bool
  rw [compressedPhi_false_succ_eq u 3, compressedPhi_true_at_four (wStepFromFalse u),
    wStepFromFalse_at_zero, wStepFromFalse_at_one, wStepFromFalse_at_two,
    wStepFromFalse_at_three, compressedPhi_false_at_three]

theorem prepend3_0 (b0 b1 b2 : Bool) (z : Stream) : prepend [b0, b1, b2] z 0 = b0 := rfl
theorem prepend3_1 (b0 b1 b2 : Bool) (z : Stream) : prepend [b0, b1, b2] z 1 = b1 := rfl
theorem prepend3_2 (b0 b1 b2 : Bool) (z : Stream) : prepend [b0, b1, b2] z 2 = b2 := rfl
theorem prepend3_3 (b0 b1 b2 : Bool) (z : Stream) : prepend [b0, b1, b2] z 3 = z 0 := rfl
theorem prepend3_4 (b0 b1 b2 : Bool) (z : Stream) : prepend [b0, b1, b2] z 4 = z 1 := rfl

/-- **Immediate step-2 emitted output on `[false, false, true]` (`Target I-2`):** -/
theorem compressedPhi_false_001_at_two (z : Stream) :
    compressedPhi false (prepend [false, false, true] z) 2 = true := by
  rw [compressedPhi_false_at_two, prepend3_0, prepend3_1, prepend3_2]
  rfl

/-- **Immediate step-2 emitted output on `[false, true, true]` (`Target I-2`):** -/
theorem compressedPhi_false_011_at_two (z : Stream) :
    compressedPhi false (prepend [false, true, true] z) 2 = false := by
  rw [compressedPhi_false_at_two, prepend3_0, prepend3_1, prepend3_2]
  rfl

/-- **Lookahead `k = 0` (`j = 3`) residual on `[false, false, true]` is identically `false` (`Target I-2`):** -/
theorem residual_false_001_at_zero (z : Stream) :
    residual (compressedPhi false) [false, false, true] z 0 = false := by
  change compressedPhi false (prepend [false, false, true] z) 3 = false
  rw [compressedPhi_false_at_three, prepend3_0, prepend3_1, prepend3_2, prepend3_3]
  cases z 0 <;> rfl

/-- **Lookahead `k = 0` (`j = 3`) residual on `[false, true, true]` is identically `false` (`Target I-2`):** -/
theorem residual_false_011_at_zero (z : Stream) :
    residual (compressedPhi false) [false, true, true] z 0 = false := by
  change compressedPhi false (prepend [false, true, true] z) 3 = false
  rw [compressedPhi_false_at_three, prepend3_0, prepend3_1, prepend3_2, prepend3_3]
  cases z 0 <;> rfl

/-- **`[false, false, true]` and `[false, true, true]` agree at lookahead `d = 1` (`k = 0`):** -/
theorem residualEquivUpTo_false_one_001_011 :
    ResidualEquivUpTo (compressedPhi false) 1 [false, false, true] [false, true, true] := by
  refine ⟨rfl, ?_⟩
  intro z k hk
  have hk0 : k = 0 := by omega
  subst hk0
  rw [residual_false_001_at_zero, residual_false_011_at_zero]

/-- Constant-`true` continuation stream `z(m) = true` witnessing the `[0,0,1] ≁ [0,1,1]` separation. -/
def constTrue : Stream := fun _ => true

/-- **Explicit witness evaluation on `[false, false, true]` at lookahead `k = 1` (`j = 4`),
derived through the `I-1` reconstruction (`Target I-2`):** -/
theorem residual_false_001_at_one_constTrue :
    residual (compressedPhi false) [false, false, true] constTrue 1 = true := by
  change compressedPhi false (prepend [false, false, true] constTrue) 4 = true
  rw [compressedPhi_false_at_four, prepend3_0, prepend3_1, prepend3_2, prepend3_3, prepend3_4]
  rfl

/-- **Explicit witness evaluation on `[false, true, true]` at lookahead `k = 1` (`j = 4`),
derived through the `I-1` reconstruction (`Target I-2`):** -/
theorem residual_false_011_at_one_constTrue :
    residual (compressedPhi false) [false, true, true] constTrue 1 = false := by
  change compressedPhi false (prepend [false, true, true] constTrue) 4 = false
  rw [compressedPhi_false_at_four, prepend3_0, prepend3_1, prepend3_2, prepend3_3, prepend3_4]
  rfl

/-- **Target I-2 (`residual_false_sep_001_011`):**
The phase-`01` prefixes `[false, false, true]` and `[false, true, true]` have distinct
residuals (`R([0] ++ [0,1]) ≠ R([0] ++ [1,1])`). -/
theorem residual_false_sep_001_011 :
    residual (compressedPhi false) [false, false, true] ≠
      residual (compressedPhi false) [false, true, true] := by
  intro h
  have h1 := congrFun (congrFun h constTrue) 1
  rw [residual_false_001_at_one_constTrue, residual_false_011_at_one_constTrue] at h1
  revert h1
  decide

/-- **Target I-2 (`not_residualEquiv_false_001_011`):**
`[0,0,1] ≁ [0,1,1]` in phase `01` (`compressedPhi false`). -/
theorem not_residualEquiv_false_001_011 :
    ¬ ResidualEquiv (compressedPhi false) [false, false, true] [false, true, true] := by
  intro h
  exact residual_false_sep_001_011 h.2

/-- **Target I-2 (`not_all_left_context_latch_merge_false`):**
Refutes the universal left-context latch identity `∀ w, R(w ++ [0,1]) = R(w ++ [1,1])`
using the explicit counterexample `w = [false]`. -/
theorem not_all_left_context_latch_merge_false :
    ¬ (∀ w : List Bool,
        ResidualEquiv (compressedPhi false) (w ++ [false, true]) (w ++ [true, true])) := by
  intro hall
  exact not_residualEquiv_false_001_011 (hall [false])

/-- **Multi-step right-congruence (`residualEquiv_append_right`):**
In contrast to left contexts, right suffix extension `u ++ s ~ v ++ s` preserves
`ResidualEquiv` for every finite suffix `s : List Bool`. -/
theorem residualEquiv_append_right {F : Stream → Stream} {u v : List Bool}
    (h : ResidualEquiv F u v) (s : List Bool) :
    ResidualEquiv F (u ++ s) (v ++ s) := by
  refine ⟨by simp [h.1], ?_⟩
  rw [residual_append, residual_append, h.2]

/-- **All right-suffix extensions of the phase-`01` root latch merge:**
For every suffix `s : List Bool`, `[false, true] ++ s ~ [true, true] ++ s`. -/
theorem residualEquiv_false_latch_merge_append (s : List Bool) :
    ResidualEquiv (compressedPhi false) ([false, true] ++ s) ([true, true] ++ s) :=
  residualEquiv_append_right residualEquiv_false_latch_merge_depth2 s

-- ============================================================================
-- 4. Target I-3: First Merge of Phase `10` at Depth 3 (`[0,0,0] ~ [1,0,1]`)
-- ============================================================================

/-- Replace the first 6 initial-row bits `(a 0, ..., a 5) ↦ (true, true, false, false, false, true)`
while keeping all bits at indices `n + 6` (`n ≥ 0`) identical to `a`. -/
def trueLatchSwapBits (a : Nat → Bool) : Nat → Bool
  | 0 => true
  | 1 => true
  | 2 => false
  | 3 => false
  | 4 => false
  | 5 => true
  | n + 6 => a (n + 6)

theorem trueLatchSwapBits_0 (a : Nat → Bool) : trueLatchSwapBits a 0 = true := rfl
theorem trueLatchSwapBits_1 (a : Nat → Bool) : trueLatchSwapBits a 1 = true := rfl
theorem trueLatchSwapBits_2 (a : Nat → Bool) : trueLatchSwapBits a 2 = false := rfl
theorem trueLatchSwapBits_3 (a : Nat → Bool) : trueLatchSwapBits a 3 = false := rfl
theorem trueLatchSwapBits_4 (a : Nat → Bool) : trueLatchSwapBits a 4 = false := rfl
theorem trueLatchSwapBits_5 (a : Nat → Bool) : trueLatchSwapBits a 5 = true := rfl
theorem trueLatchSwapBits_add_six (a : Nat → Bool) (n : Nat) :
    trueLatchSwapBits a (n + 6) = a (n + 6) := rfl

theorem L_trueLatchSwapBits_one_neg1 (a : Nat → Bool) :
    Rule30DrivenLeft.L (driver true) (bitRow (trueLatchSwapBits a)) 1 (-1) = false := by
  rw [Rule30DrivenLeft.L_succ (by omega),
    show (-1 : Int) - 1 = -((1 + 1 : Nat) : Int) by rfl,
    show (-1 : Int) + 1 = 0 by rfl,
    show (-1 : Int) = -((0 + 1 : Nat) : Int) by rfl,
    Rule30DrivenLeft.L_col0,
    Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
    bitRow_at (trueLatchSwapBits a) 1, bitRow_at (trueLatchSwapBits a) 0]
  rfl

theorem L_orig_000_one_neg1 (a : Nat → Bool) (ha0 : a 0 = true) (ha1 : a 1 = false) :
    Rule30DrivenLeft.L (driver true) (bitRow a) 1 (-1) = true := by
  rw [Rule30DrivenLeft.L_succ (by omega),
    show (-1 : Int) - 1 = -((1 + 1 : Nat) : Int) by rfl,
    show (-1 : Int) + 1 = 0 by rfl,
    show (-1 : Int) = -((0 + 1 : Nat) : Int) by rfl,
    Rule30DrivenLeft.L_col0,
    Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
    bitRow_at a 1, bitRow_at a 0, ha0, ha1]
  rfl

theorem L_trueLatchSwapBits_one_neg2 (a : Nat → Bool) :
    Rule30DrivenLeft.L (driver true) (bitRow (trueLatchSwapBits a)) 1 (-2) = true := by
  rw [Rule30DrivenLeft.L_succ (by omega),
    show (-2 : Int) - 1 = -((2 + 1 : Nat) : Int) by rfl,
    show (-2 : Int) + 1 = -((0 + 1 : Nat) : Int) by rfl,
    show (-2 : Int) = -((1 + 1 : Nat) : Int) by rfl,
    Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
    Rule30DrivenLeft.L_zero (by omega),
    bitRow_at (trueLatchSwapBits a) 2, bitRow_at (trueLatchSwapBits a) 1,
    bitRow_at (trueLatchSwapBits a) 0]
  rfl

theorem L_orig_000_one_neg2 (a : Nat → Bool)
    (ha0 : a 0 = true) (ha1 : a 1 = false) (ha2 : a 2 = true) :
    Rule30DrivenLeft.L (driver true) (bitRow a) 1 (-2) = false := by
  rw [Rule30DrivenLeft.L_succ (by omega),
    show (-2 : Int) - 1 = -((2 + 1 : Nat) : Int) by rfl,
    show (-2 : Int) + 1 = -((0 + 1 : Nat) : Int) by rfl,
    show (-2 : Int) = -((1 + 1 : Nat) : Int) by rfl,
    Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
    Rule30DrivenLeft.L_zero (by omega),
    bitRow_at a 2, bitRow_at a 1, bitRow_at a 0, ha0, ha1, ha2]
  rfl

theorem L_trueLatchSwapBits_one_neg3 (a : Nat → Bool) :
    Rule30DrivenLeft.L (driver true) (bitRow (trueLatchSwapBits a)) 1 (-3) = true := by
  rw [Rule30DrivenLeft.L_succ (by omega),
    show (-3 : Int) - 1 = -((3 + 1 : Nat) : Int) by rfl,
    show (-3 : Int) + 1 = -((1 + 1 : Nat) : Int) by rfl,
    show (-3 : Int) = -((2 + 1 : Nat) : Int) by rfl,
    Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
    Rule30DrivenLeft.L_zero (by omega),
    bitRow_at (trueLatchSwapBits a) 3, bitRow_at (trueLatchSwapBits a) 2,
    bitRow_at (trueLatchSwapBits a) 1]
  rfl

theorem L_orig_000_one_neg3 (a : Nat → Bool)
    (ha1 : a 1 = false) (ha2 : a 2 = true) (ha3 : a 3 = false) :
    Rule30DrivenLeft.L (driver true) (bitRow a) 1 (-3) = true := by
  rw [Rule30DrivenLeft.L_succ (by omega),
    show (-3 : Int) - 1 = -((3 + 1 : Nat) : Int) by rfl,
    show (-3 : Int) + 1 = -((1 + 1 : Nat) : Int) by rfl,
    show (-3 : Int) = -((2 + 1 : Nat) : Int) by rfl,
    Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
    Rule30DrivenLeft.L_zero (by omega),
    bitRow_at a 3, bitRow_at a 2, bitRow_at a 1, ha1, ha2, ha3]
  rfl

/-- At `t = 1`, `trueLatchSwapBits a` and `a` coalesce at every spatial cell `p ≤ -3`. -/
theorem L_trueLatchSwapBits_one_eq_le_neg3 (a : Nat → Bool)
    (ha1 : a 1 = false) (ha2 : a 2 = true) (ha3 : a 3 = false)
    (ha4 : a 4 = true) (ha5 : a 5 = false) (ha6 : a 6 = true) :
    ∀ p : Int, p ≤ -3 →
      Rule30DrivenLeft.L (driver true) (bitRow (trueLatchSwapBits a)) 1 p =
        Rule30DrivenLeft.L (driver true) (bitRow a) 1 p := by
  intro p hp
  obtain ⟨k, rfl⟩ : ∃ k : Nat, p = -((k + 2 + 1 : Nat) : Int) := ⟨(-p - 3).toNat, by omega⟩
  cases k with
  | zero =>
    change Rule30DrivenLeft.L (driver true) (bitRow (trueLatchSwapBits a)) 1 (-3) =
      Rule30DrivenLeft.L (driver true) (bitRow a) 1 (-3)
    rw [L_trueLatchSwapBits_one_neg3, L_orig_000_one_neg3 a ha1 ha2 ha3]
  | succ k1 =>
    cases k1 with
    | zero =>
      rw [Rule30DrivenLeft.L_succ (by omega), Rule30DrivenLeft.L_succ (by omega),
        show (-((3 + 1 : Nat) : Int)) - 1 = -((4 + 1 : Nat) : Int) by rfl,
        show (-((3 + 1 : Nat) : Int)) + 1 = -((2 + 1 : Nat) : Int) by rfl,
        Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
        Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
        Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
        bitRow_at (trueLatchSwapBits a) 4, bitRow_at (trueLatchSwapBits a) 3,
        bitRow_at (trueLatchSwapBits a) 2,
        bitRow_at a 4, bitRow_at a 3, bitRow_at a 2,
        trueLatchSwapBits_4, trueLatchSwapBits_3, trueLatchSwapBits_2, ha2, ha3, ha4]
      rfl
    | succ k2 =>
      cases k2 with
      | zero =>
        rw [Rule30DrivenLeft.L_succ (by omega), Rule30DrivenLeft.L_succ (by omega),
          show (-((4 + 1 : Nat) : Int)) - 1 = -((5 + 1 : Nat) : Int) by rfl,
          show (-((4 + 1 : Nat) : Int)) + 1 = -((3 + 1 : Nat) : Int) by rfl,
          Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
          Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
          Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
          bitRow_at (trueLatchSwapBits a) 5, bitRow_at (trueLatchSwapBits a) 4,
          bitRow_at (trueLatchSwapBits a) 3,
          bitRow_at a 5, bitRow_at a 4, bitRow_at a 3,
          trueLatchSwapBits_5, trueLatchSwapBits_4, trueLatchSwapBits_3, ha3, ha4, ha5]
        rfl
      | succ k3 =>
        cases k3 with
        | zero =>
          rw [Rule30DrivenLeft.L_succ (by omega), Rule30DrivenLeft.L_succ (by omega),
            show (-((5 + 1 : Nat) : Int)) - 1 = -((6 + 1 : Nat) : Int) by rfl,
            show (-((5 + 1 : Nat) : Int)) + 1 = -((4 + 1 : Nat) : Int) by rfl,
            Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
            Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
            Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
            bitRow_at (trueLatchSwapBits a) 6, bitRow_at (trueLatchSwapBits a) 5,
            bitRow_at (trueLatchSwapBits a) 4,
            bitRow_at a 6, bitRow_at a 5, bitRow_at a 4,
            trueLatchSwapBits_add_six a 0, trueLatchSwapBits_5, trueLatchSwapBits_4,
            ha4, ha5, ha6]
          rfl
        | succ k4 =>
          cases k4 with
          | zero =>
            rw [Rule30DrivenLeft.L_succ (by omega), Rule30DrivenLeft.L_succ (by omega),
              show (-((6 + 1 : Nat) : Int)) - 1 = -((7 + 1 : Nat) : Int) by rfl,
              show (-((6 + 1 : Nat) : Int)) + 1 = -((5 + 1 : Nat) : Int) by rfl,
              Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
              Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
              Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
              bitRow_at (trueLatchSwapBits a) 7, bitRow_at (trueLatchSwapBits a) 6,
              bitRow_at (trueLatchSwapBits a) 5,
              bitRow_at a 7, bitRow_at a 6, bitRow_at a 5,
              trueLatchSwapBits_add_six a 1, trueLatchSwapBits_add_six a 0,
              trueLatchSwapBits_5, ha5, ha6]
            cases a 7 <;> rfl
          | succ k5 =>
            rw [Rule30DrivenLeft.L_succ (by omega), Rule30DrivenLeft.L_succ (by omega),
              show (-((k5 + 7 + 1 : Nat) : Int)) - 1 = -((k5 + 8 + 1 : Nat) : Int) by omega,
              show (-((k5 + 7 + 1 : Nat) : Int)) + 1 = -((k5 + 6 + 1 : Nat) : Int) by omega,
              Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
              Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
              Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
              bitRow_at (trueLatchSwapBits a) (k5 + 8),
              bitRow_at (trueLatchSwapBits a) (k5 + 7),
              bitRow_at (trueLatchSwapBits a) (k5 + 6),
              bitRow_at a (k5 + 8), bitRow_at a (k5 + 7), bitRow_at a (k5 + 6)]
            rfl

/-- At `t = 2`, `trueLatchSwapBits a` and `a` coalesce at **every** spatial cell `p < 0`. -/
theorem L_trueLatchSwapBits_two_eq (a : Nat → Bool)
    (ha0 : a 0 = true) (ha1 : a 1 = false) (ha2 : a 2 = true) (ha3 : a 3 = false)
    (ha4 : a 4 = true) (ha5 : a 5 = false) (ha6 : a 6 = true) :
    ∀ p : Int, p < 0 →
      Rule30DrivenLeft.L (driver true) (bitRow (trueLatchSwapBits a)) 2 p =
        Rule30DrivenLeft.L (driver true) (bitRow a) 2 p := by
  intro p hp
  obtain ⟨k, rfl⟩ : ∃ k : Nat, p = -((k + 1 : Nat) : Int) := ⟨(-p - 1).toNat, by omega⟩
  have hL := Rule30DrivenLeft.L_succ (c := driver true) (s := bitRow (trueLatchSwapBits a)) (t := 1)
    (p := -((k + 1 : Nat) : Int)) (by omega)
  have hR := Rule30DrivenLeft.L_succ (c := driver true) (s := bitRow a) (t := 1)
    (p := -((k + 1 : Nat) : Int)) (by omega)
  rw [hL, hR]
  cases k with
  | zero =>
    rw [show (-((0 + 1 : Nat) : Int)) - 1 = -2 by rfl,
      show (-((0 + 1 : Nat) : Int)) + 1 = 0 by rfl,
      show (-((0 + 1 : Nat) : Int)) = -1 by rfl,
      Rule30DrivenLeft.L_col0, Rule30DrivenLeft.L_col0,
      L_trueLatchSwapBits_one_neg2, L_trueLatchSwapBits_one_neg1,
      L_orig_000_one_neg2 a ha0 ha1 ha2, L_orig_000_one_neg1 a ha0 ha1]
    rfl
  | succ k1 =>
    cases k1 with
    | zero =>
      rw [show (-((1 + 1 : Nat) : Int)) - 1 = -3 by rfl,
        show (-((1 + 1 : Nat) : Int)) + 1 = -1 by rfl,
        show (-((1 + 1 : Nat) : Int)) = -2 by rfl,
        L_trueLatchSwapBits_one_neg3, L_trueLatchSwapBits_one_neg2, L_trueLatchSwapBits_one_neg1,
        L_orig_000_one_neg3 a ha1 ha2 ha3, L_orig_000_one_neg2 a ha0 ha1 ha2,
        L_orig_000_one_neg1 a ha0 ha1]
      rfl
    | succ k2 =>
      cases k2 with
      | zero =>
        rw [show (-((2 + 1 : Nat) : Int)) - 1 = -4 by rfl,
          show (-((2 + 1 : Nat) : Int)) + 1 = -2 by rfl,
          show (-((2 + 1 : Nat) : Int)) = -3 by rfl,
          L_trueLatchSwapBits_one_eq_le_neg3 a ha1 ha2 ha3 ha4 ha5 ha6 (-4) (by omega),
          L_trueLatchSwapBits_one_neg3, L_trueLatchSwapBits_one_neg2,
          L_orig_000_one_neg3 a ha1 ha2 ha3, L_orig_000_one_neg2 a ha0 ha1 ha2]
        cases Rule30DrivenLeft.L (driver true) (bitRow a) 1 (-4) <;> rfl
      | succ k3 =>
        rw [L_trueLatchSwapBits_one_eq_le_neg3 a ha1 ha2 ha3 ha4 ha5 ha6
            (-((k3 + 3 + 1 : Nat) : Int) - 1) (by omega),
          L_trueLatchSwapBits_one_eq_le_neg3 a ha1 ha2 ha3 ha4 ha5 ha6
            (-((k3 + 3 + 1 : Nat) : Int)) (by omega),
          L_trueLatchSwapBits_one_eq_le_neg3 a ha1 ha2 ha3 ha4 ha5 ha6
            (-((k3 + 3 + 1 : Nat) : Int) + 1) (by omega)]

theorem L_trueLatchSwapBits_eq_from_two (a : Nat → Bool)
    (ha0 : a 0 = true) (ha1 : a 1 = false) (ha2 : a 2 = true) (ha3 : a 3 = false)
    (ha4 : a 4 = true) (ha5 : a 5 = false) (ha6 : a 6 = true) :
    ∀ (t : Nat) (p : Int), p < 0 →
      Rule30DrivenLeft.L (driver true) (bitRow (trueLatchSwapBits a)) (t + 2) p =
        Rule30DrivenLeft.L (driver true) (bitRow a) (t + 2) p := by
  intro t
  induction t with
  | zero =>
    intro p hp
    exact L_trueLatchSwapBits_two_eq a ha0 ha1 ha2 ha3 ha4 ha5 ha6 p hp
  | succ t ih =>
    intro p hp
    have hL := Rule30DrivenLeft.L_succ (c := driver true) (s := bitRow (trueLatchSwapBits a)) (t := t + 2) hp
    have hR := Rule30DrivenLeft.L_succ (c := driver true) (s := bitRow a) (t := t + 2) hp
    rw [hL, hR, ih (p - 1) (by omega), ih p hp]
    by_cases hp1 : p + 1 < 0
    · rw [ih (p + 1) hp1]
    · have hp0 : p + 1 = 0 := by omega
      rw [hp0, Rule30DrivenLeft.L_col0, Rule30DrivenLeft.L_col0]

theorem pins_trueLatchSwapBits (z : Stream) :
    let a := infiniteBits (driver true) (expandWhite true (prepend [false, false, false] z))
    Pins (driver true) (bitRow (trueLatchSwapBits a)) := by
  intro a t ht
  cases t with
  | zero =>
    rw [driver_no_adjacent_black true 0 ht,
      Rule30DrivenLeft.L_zero (by omega),
      show (-1 : Int) = -((0 + 1 : Nat) : Int) by rfl,
      bitRow_at (trueLatchSwapBits a) 0, trueLatchSwapBits_0]
    rfl
  | succ t1 =>
    cases t1 with
    | zero => simp [driver] at ht
    | succ t' =>
      let w0 := prepend [false, false, false] z
      have ha0 : a 0 = true := compressedPhi_true_at_zero w0
      have ha1 : a 1 = false := infiniteBits_at_white true w0 0
      have ha2 : a 2 = true := compressedPhi_true_at_one w0
      have ha3 : a 3 = false := infiniteBits_at_white true w0 1
      have ha4 : a 4 = true := compressedPhi_true_at_two w0
      have ha5 : a 5 = false := infiniteBits_at_white true w0 2
      have ha6 : a 6 = true := by
        change compressedPhi true w0 3 = true
        rw [compressedPhi_true_at_three]
        rfl
      rw [L_trueLatchSwapBits_eq_from_two a ha0 ha1 ha2 ha3 ha4 ha5 ha6 t' (-1) (by omega)]
      exact infiniteBits_pins (driver true) (expandWhite true w0) (t' + 2) ht

theorem infiniteBits_101_eq_trueLatchSwapBits (z : Stream) :
    infiniteBits (driver true) (expandWhite true (prepend [true, false, true] z)) =
      trueLatchSwapBits
        (infiniteBits (driver true) (expandWhite true (prepend [false, false, false] z))) := by
  let a := infiniteBits (driver true) (expandWhite true (prepend [false, false, false] z))
  symm
  apply infiniteBits_unique (driver true) (expandWhite true (prepend [true, false, true] z))
    (trueLatchSwapBits a) (pins_trueLatchSwapBits z)
  intro i
  have hw := whiteAt_of_white true i.val i.property
  simp [whiteAt] at hw
  obtain ⟨k, hk⟩ : ∃ k : Nat, i.val = 2 * k + 1 := ⟨i.val / 2, by omega⟩
  cases k with
  | zero =>
    change trueLatchSwapBits a i.val = (prepend [true, false, true] z) (i.val / 2)
    rw [hk]
    rfl
  | succ k1 =>
    cases k1 with
    | zero =>
      change trueLatchSwapBits a i.val = (prepend [true, false, true] z) (i.val / 2)
      rw [hk]
      rfl
    | succ k2 =>
      cases k2 with
      | zero =>
        change trueLatchSwapBits a i.val = (prepend [true, false, true] z) (i.val / 2)
        rw [hk]
        rfl
      | succ k3 =>
        change trueLatchSwapBits a i.val = (prepend [true, false, true] z) (i.val / 2)
        have hi : i.val = (2 * k3 + 1) + 6 := by omega
        have hdiv : i.val / 2 = k3 + 3 := by omega
        rw [hi, trueLatchSwapBits, ← hi, hdiv]
        have h_orig := infiniteBits_at_white true (prepend [false, false, false] z) (k3 + 3)
        change a (2 * (k3 + 3) + 1) = (prepend [false, false, false] z) (k3 + 3) at h_orig
        rw [← hk] at h_orig
        exact h_orig

/-- **Target I-3 (`residual_true_latch_merge_depth3`):**
Unconditional all-continuation depth-3 Myhill–Nerode merge in phase `true` (`10`)
for the **same** continuation:
`residual (compressedPhi true) [false, false, false] = residual (compressedPhi true) [true, false, true]`. -/
theorem residual_true_latch_merge_depth3 :
    residual (compressedPhi true) [false, false, false] =
      residual (compressedPhi true) [true, false, true] := by
  funext z k
  change infiniteBits (driver true) (expandWhite true (prepend [false, false, false] z))
      (blackAt true (3 + k)) =
    infiniteBits (driver true) (expandWhite true (prepend [true, false, true] z))
      (blackAt true (3 + k))
  rw [infiniteBits_101_eq_trueLatchSwapBits z]
  have hblk : blackAt true (3 + k) = (2 * k) + 6 := by
    simp [blackAt]; omega
  rw [hblk, trueLatchSwapBits]

theorem residualEquiv_true_latch_merge_depth3 :
    ResidualEquiv (compressedPhi true) [false, false, false] [true, false, true] :=
  ⟨rfl, residual_true_latch_merge_depth3⟩

/-- **Target I-3 (`uStepFromTrue_000_prefix`):**
Under `uStepFromTrue`, `prepend [false, false, false] z` maps at depths `0, 1, 2` to `(true, true, true)`. -/
theorem uStepFromTrue_000_prefix (z : Stream) :
    uStepFromTrue (prepend [false, false, false] z) 0 = true ∧
    uStepFromTrue (prepend [false, false, false] z) 1 = true ∧
    uStepFromTrue (prepend [false, false, false] z) 2 = true := by
  refine ⟨?_, ?_, ?_⟩
  · rw [uStepFromTrue_at_zero]; rfl
  · rw [uStepFromTrue_at_one]; rfl
  · rw [uStepFromTrue_at_two]; rfl

/-- **Target I-3 (`uStepFromTrue_101_prefix`):**
Under `uStepFromTrue`, `prepend [true, false, true] z` maps at depths `0, 1, 2` to `(false, true, true)`,
the sibling branch of the phase-`01` root latch `(false, true) ~ (true, true)`. -/
theorem uStepFromTrue_101_prefix (z : Stream) :
    uStepFromTrue (prepend [true, false, true] z) 0 = false ∧
    uStepFromTrue (prepend [true, false, true] z) 1 = true ∧
    uStepFromTrue (prepend [true, false, true] z) 2 = true := by
  refine ⟨?_, ?_, ?_⟩
  · rw [uStepFromTrue_at_zero]; rfl
  · rw [uStepFromTrue_at_one]; rfl
  · rw [uStepFromTrue_at_two]; rfl

/-- **Target I-3 (`uStepFromTrue_000_eq_101_from_two`):**
Exact continuation-map alignment induced by `back true`: for every continuation `z : Stream`
and every `m ≥ 0`, `uStepFromTrue` on `prepend [false, false, false] z` and
`prepend [true, false, true] z` produces the **exact same** phase-`01` continuation bit at `m + 2`. -/
theorem uStepFromTrue_000_eq_101_from_two (z : Stream) (m : Nat) :
    uStepFromTrue (prepend [false, false, false] z) (m + 2) =
      uStepFromTrue (prepend [true, false, true] z) (m + 2) := by
  cases m with
  | zero =>
    rw [(uStepFromTrue_000_prefix z).2.2, (uStepFromTrue_101_prefix z).2.2]
  | succ m1 =>
    cases m1 with
    | zero =>
      change xor (z 0) (compressedPhi true (prepend [false, false, false] z) 3 || false) =
        xor (z 0) (compressedPhi true (prepend [true, false, true] z) 3 || true)
      have h0 : compressedPhi true (prepend [false, false, false] z) 3 = true := by
        rw [compressedPhi_true_at_three]; rfl
      have h1 : compressedPhi true (prepend [true, false, true] z) 3 = true := by
        rw [compressedPhi_true_at_three]; rfl
      rw [h0, h1]
      cases z 0 <;> rfl
    | succ k =>
      have hres : compressedPhi true (prepend [false, false, false] z) (k + 2 + 2) =
          compressedPhi true (prepend [true, false, true] z) (k + 2 + 2) := by
        rw [show k + 2 + 2 = 3 + (k + 1) by omega]
        exact congrFun (congrFun residual_true_latch_merge_depth3 z) (k + 1)
      unfold uStepFromTrue
      rw [hres]
      rfl

/-- **Target I-3 (`residual_true_sep_100_001`):**
In contrast to `[0,0,0] ~ [1,0,1]`, the sibling candidate pair `[true, false, false]`
and `[false, false, true]` (where `u_2 = false` on both branches) is separated at lookahead `k = 0`. -/
theorem residual_true_sep_100_001 :
    residual (compressedPhi true) [true, false, false] ≠
      residual (compressedPhi true) [false, false, true] := by
  intro h
  have h0 := congrFun (congrFun h (fun _ => false)) 0
  change compressedPhi true (prepend [true, false, false] (fun _ => false)) 3 =
    compressedPhi true (prepend [false, false, true] (fun _ => false)) 3 at h0
  rw [compressedPhi_true_at_three, compressedPhi_true_at_three] at h0
  revert h0
  decide

#print axioms oddAt_eq_xor_back_evenAt
#print axioms compressedPhi_false_succ_eq
#print axioms compressedPhi_true_succ_eq
#print axioms two_mul_spin_uStepFromTrue_eq
#print axioms two_mul_spin_compressedPhi_true_succ_eq
#print axioms not_residualEquiv_false_001_011
#print axioms not_all_left_context_latch_merge_false
#print axioms residual_true_latch_merge_depth3
#print axioms uStepFromTrue_000_eq_101_from_two
#print axioms residual_true_sep_100_001

end FVLT.S4nPeriodTwoTargetIV1
