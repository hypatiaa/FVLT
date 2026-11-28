import Ruliology.CellularAutomata.Rule30ZeroBoundary
import FVLTS4iResidualV1
import S4l_G_ZeroBoundaryPotentialsV1

set_option autoImplicit false

/-!
# S4m-G: Period-2 Residual Structure of `compressedPhi`, Exact `Theta` ↔ `compressedPhi` Bridge,
# Update-Derived One-Block Transition & Seam Carry, and All-Continuation Depth-2 Latch Merge

Formalizes the theorem suite for Study `S4m-G` (`#1201`, `#1205`, `#1207`, `#1211`,
`WORK_ORDER.md` `80b74b3d...` and `WORK_ORDER_ADDENDUM_1.md` `39ebf85b...`) against
Rule 30 Theorem Library `v7` (`SHA256SUMS` `68bc215f...`):

1. **Part A (`D3`) — Non-Circular Residual Equivalence & Update-Derived One-Block Congruence
   (`ResidualEquiv`, `ResidualEquivUpTo`, `prepend_append`, `residual_append`,
   `residual_step_congr`, `residual_emit_congr`):**
   - Defines `ResidualEquiv F u v` and finite-window `ResidualEquivUpTo F d u v` without any
     reference to `Surv`, death times, `FiniteLeft`, or `BoundedDeath`.
   - Proves that consuming one more input bit `b : Bool` acts by right-composition
     `residual F (u ++ [b]) = residual (residual F u) [b]`, so `ResidualEquiv F u v`
     is a right-congruence under single-block extension `u ↦ u ++ [b]` and preserves the
     emitted step output `F (prepend (u ++ [b]) z) u.length`.

2. **Part A (`D3`) — Exact Bidirectional Bridge Between `Rule30ZeroBoundary.Theta` / `back`
   and `compressedPhi` (`zrowOfBits`, `L_c_zero_eq_zrow_bitRow`, `pins_driver_iff_zrow`,
   `pins_driver_true_iff_inX`, `thetaBits_pins`, `infiniteBits_true_eq_thetaBits`,
   `compressedPhi_true_thetaWhite`, `backThetaBits_pins`, `infiniteBits_false_eq_backThetaBits`,
   `compressedPhi_false_backThetaWhite`):**
   - Bridges `Rule30DrivenLeft.L` and `FVLT.S4hInfinitePinsV1.infiniteBits` to
     `Rule30ZeroBoundary.zrow`, `InX`, `Theta`, and `back`.
   - Proves that for phase `true` (`10`), `Pins (driver true) (bitRow a) ↔ InX (zrowOfBits a)`,
     and for every temporal free-bit stream `f : Stream`, `compressedPhi true (thetaWhite f) = thetaBlack f`.
   - Proves that for phase `false` (`01`), for every initial bit `b0 : Bool` and temporal
     stream `f : Stream`, `compressedPhi false (backThetaWhite b0 f) = backThetaBlack b0 f`.

3. **Part C2 (`D4`) — Update-Derived One-Block Backward Decomposition & 2-Bit Spatial Seam Carry
   (`Theta_step_back`, `back_agree_from`, `back_or_latch_depth3`):**
   - Derives from `two_step_shift` and `eq_back` the exact 1-block backward decomposition
     `Theta f k = back true (back (f 0) (Theta (fun s => f (s + 1)))) k`.
   - Proves the 2-bit spatial seam carry theorem `back_agree_from` and the depth-3 OR-latch
     seam erasure `back_or_latch_depth3` (`back false y (m + 3) = back true y (m + 3)` when
     `y 1 = true` and `y 2 = false`).

4. **Part B & C2 (`D4`) — Explicit Low-Depth Closed Forms, Depth-1 Separations, and Exact
   All-Continuation Depth-2 Myhill–Nerode Residual Merge (`compressedPhi_true_at_zero`,
   `compressedPhi_true_at_one`, `compressedPhi_false_at_zero`, `compressedPhi_false_at_one`,
   `residual_true_sep_depth1`, `residual_false_sep_depth1`, `residual_false_latch_merge_depth2`):**
   - Proves closed-form output laws at low depth for all streams `x : Stream`.
   - Proves `[false]` and `[true]` are separated in both phases `true` (`10`) and `false` (`01`).
   - Proves the unconditional all-continuation depth-2 Myhill–Nerode merge for phase `false` (`01`):
     `residual (compressedPhi false) [false, true] = residual (compressedPhi false) [true, true]`.
-/

namespace FVLT.S4mPeriodTwoResidualsV1

open Ruliology.CellularAutomata
open Rule30DrivenLeft
open Rule30ZeroBoundary
open FVLT.S4gLBEImplicationV1
open FVLT.S4hInfinitePinsV1
open FVLT.S4hFiniteTailV1
open FVLT.S4iResidualV1
open FVLT.S4iUniformLatchV1
open FVLT.S4lZeroBoundaryPotentialsV1

-- ============================================================================
-- 1. Part A (D3): Non-Circular Residual Equivalence & One-Block Congruence
-- ============================================================================

/-- Non-circular length-matched Myhill–Nerode residual equivalence for a stream transducer `F`.
Makes no reference to `Surv`, death times, `FiniteLeft`, or `BoundedDeath`. -/
def ResidualEquiv (F : Stream → Stream) (u v : List Bool) : Prop :=
  u.length = v.length ∧ residual F u = residual F v

/-- Finite-window residual profile equivalence up to continuation lookahead `d`. -/
def ResidualEquivUpTo (F : Stream → Stream) (d : Nat) (u v : List Bool) : Prop :=
  u.length = v.length ∧ ∀ (z : Stream) (k : Nat), k < d → residual F u z k = residual F v z k

theorem residualEquiv_refl (F : Stream → Stream) (u : List Bool) :
    ResidualEquiv F u u := ⟨rfl, rfl⟩

theorem residualEquiv_symm {F : Stream → Stream} {u v : List Bool}
    (h : ResidualEquiv F u v) : ResidualEquiv F v u := ⟨h.1.symm, h.2.symm⟩

theorem residualEquiv_trans {F : Stream → Stream} {u v w : List Bool}
    (huv : ResidualEquiv F u v) (hvw : ResidualEquiv F v w) :
    ResidualEquiv F u w := ⟨huv.1.trans hvw.1, huv.2.trans hvw.2⟩

theorem prepend_nil (x : Stream) : prepend [] x = x := rfl

theorem prepend_cons (b : Bool) (u : List Bool) (x : Stream) :
    prepend (b :: u) x = fun n => match n with | 0 => b | k + 1 => prepend u x k := rfl

theorem prepend_append (u v : List Bool) (x : Stream) :
    prepend (u ++ v) x = prepend u (prepend v x) := by
  induction u with
  | nil => rfl
  | cons b u ih =>
    funext n
    cases n with
    | zero => rfl
    | succ k => exact congrFun ih k

/-- **One-block composition of residuals (`D4`):**
The residual after `u ++ v` is the `v`-residual of the `u`-residual. -/
theorem residual_append (F : Stream → Stream) (u v : List Bool) :
    residual F (u ++ v) = residual (residual F u) v := by
  funext x k
  unfold residual
  rw [prepend_append, List.length_append, Nat.add_assoc]

/-- **One-step right-congruence (`D4`):**
Equal residuals at prefixes `u, v` produce equal residuals after any single-block extension `b`. -/
theorem residual_step_congr (F : Stream → Stream) (u v : List Bool)
    (h : residual F u = residual F v) (b : Bool) :
    residual F (u ++ [b]) = residual F (v ++ [b]) := by
  rw [residual_append, residual_append, h]

theorem residualEquiv_step {F : Stream → Stream} {u v : List Bool}
    (h : ResidualEquiv F u v) (b : Bool) :
    ResidualEquiv F (u ++ [b]) (v ++ [b]) := by
  refine ⟨by simp [h.1], residual_step_congr F u v h.2 b⟩

/-- **Emitted output congruence (`D4`):**
Equal residuals at `u, v` emit the same output at step `u.length` under any extension `b :: z`. -/
theorem residual_emit_congr (F : Stream → Stream) (u v : List Bool)
    (h : ResidualEquiv F u v) (b : Bool) (z : Stream) :
    F (prepend (u ++ [b]) z) u.length = F (prepend (v ++ [b]) z) v.length := by
  have h0 := congrFun (congrFun h.2 (prepend [b] z)) 0
  unfold residual at h0
  rw [Nat.add_zero, Nat.add_zero, ← prepend_append, ← prepend_append] at h0
  exact h0

-- ============================================================================
-- 2. Part A (D3): Exact Bridge Between `Rule30ZeroBoundary` and `compressedPhi`
-- ============================================================================

/-- Convert a 0-indexed initial-row bit sequence `a : Nat → Bool` (where `a n` is spatial
position `-(n + 1)`) to a 1-indexed ZBL start `L : Nat → Bool` (where `L 0 = false` is the wall
and `L (n + 1) = a n` is depth `n + 1`). -/
def zrowOfBits (a : Nat → Bool) : Nat → Bool :=
  fun k => bitRow a (-(k : Int))

theorem zrowOfBits_zero (a : Nat → Bool) : zrowOfBits a 0 = false := rfl

theorem zrowOfBits_succ (a : Nat → Bool) (n : Nat) :
    zrowOfBits a (n + 1) = a n :=
  bitRow_at a n

/-- **Exact evolution bridge (`L_c_zero_eq_zrow_bitRow`):**
Zero-boundary driven evolution `L c_zero (bitRow a)` equals `Rule30ZeroBoundary.zrow (zrowOfBits a)`. -/
theorem L_c_zero_eq_zrow_bitRow (a : Nat → Bool) (t k : Nat) (hk : 1 ≤ k) :
    Rule30DrivenLeft.L c_zero (bitRow a) t (-(k : Int)) = zrow (zrowOfBits a) t k :=
  Rule30ZeroBoundary.L_eq_zrow (bitRow a) t k hk

theorem L_c_zero_eq_zrow_one (a : Nat → Bool) (t : Nat) :
    Rule30DrivenLeft.L c_zero (bitRow a) t (-1) = zrow (zrowOfBits a) t 1 :=
  L_c_zero_eq_zrow_bitRow a t 1 (Nat.le_refl 1)

theorem driver_no_adjacent_black (phase : Bool) (t : Nat) :
    driver phase t = true → driver phase (t + 1) = false := by
  intro ht
  rw [driver_alternates, ht]
  rfl

theorem pins_driver_iff_L_zero (phase : Bool) (a : Nat → Bool) :
    Pins (driver phase) (bitRow a) ↔
      ∀ t : Nat, driver phase t = true → Rule30DrivenLeft.L c_zero (bitRow a) t (-1) = true := by
  constructor
  · intro hpins t hblack
    have hEq := L_eq_L_zero_of_no_adjacent_black (driver phase) t (bitRow a)
      (fun t' _ ht' => driver_no_adjacent_black phase t' ht')
      (fun t' _ ht' => hpins t' ht') t (by omega) (-1) (by omega)
    have hpin := hpins t hblack
    rw [driver_no_adjacent_black phase t hblack] at hpin
    exact hEq.symm.trans hpin
  · intro hzero t hblack
    have hEq := L_eq_L_zero_of_black_samples (driver phase) t (bitRow a)
      (fun t' _ ht' => hzero t' ht') t (by omega) (-1) (by omega)
    rw [hEq, hzero t hblack, driver_no_adjacent_black phase t hblack]
    rfl

/-- **Pin characterization in `zrow` coordinates (`D3`):**
`bitRow a` satisfies `Pins (driver phase)` iff column `-1` (`k = 1`) of `zrow (zrowOfBits a)`
is `true` at every black step of `driver phase`. -/
theorem pins_driver_iff_zrow (phase : Bool) (a : Nat → Bool) :
    Pins (driver phase) (bitRow a) ↔
      ∀ t : Nat, driver phase t = true → zrow (zrowOfBits a) t 1 = true := by
  rw [pins_driver_iff_L_zero]
  constructor
  · intro h t ht
    rw [← L_c_zero_eq_zrow_one a t]
    exact h t ht
  · intro h t ht
    rw [L_c_zero_eq_zrow_one a t]
    exact h t ht

/-- **Phase `true` (`10`) Pin ↔ `InX` Equivalence (`D3`):**
`bitRow a` satisfies `Pins (driver true)` iff `zrowOfBits a` lies in `Rule30ZeroBoundary.InX`. -/
theorem pins_driver_true_iff_inX (a : Nat → Bool) :
    Pins (driver true) (bitRow a) ↔ InX (zrowOfBits a) := by
  rw [pins_driver_iff_zrow]
  constructor
  · intro h s
    apply h (2 * s)
    simp [driver]
  · intro hX t ht
    by_cases hev : t % 2 = 0
    · have ht2 : t = 2 * (t / 2) := by omega
      rw [ht2]
      exact hX (t / 2)
    · simp [driver, hev] at ht

/-- Initial-row 0-indexed bit sequence associated to `Theta f`. -/
def thetaBits (f : Stream) (n : Nat) : Bool := Theta f (n + 1)

/-- Initial-row white subsequence of `Theta f` (depths `2k + 2`, i.e., `whiteAt true k = 2k + 1`). -/
def thetaWhite (f : Stream) (k : Nat) : Bool := Theta f (2 * k + 2)

/-- Initial-row black subsequence of `Theta f` (depths `2k + 1`, i.e., `blackAt true k = 2k`). -/
def thetaBlack (f : Stream) (k : Nat) : Bool := Theta f (2 * k + 1)

theorem zrowOfBits_thetaBits (f : Stream) :
    zrowOfBits (thetaBits f) = Theta f := by
  funext k
  cases k with
  | zero => exact (Theta_wall f).symm
  | succ n => exact zrowOfBits_succ (thetaBits f) n

theorem thetaBits_pins (f : Stream) :
    Pins (driver true) (bitRow (thetaBits f)) := by
  rw [pins_driver_true_iff_inX, zrowOfBits_thetaBits]
  exact Theta_inX f

theorem infiniteBits_true_eq_thetaBits (f : Stream) :
    infiniteBits (driver true) (expandWhite true (thetaWhite f)) = thetaBits f := by
  symm
  apply infiniteBits_unique (driver true) (expandWhite true (thetaWhite f))
    (thetaBits f) (thetaBits_pins f)
  intro i
  change Theta f (i.val + 1) = Theta f (2 * (i.val / 2) + 2)
  have hw := whiteAt_of_white true i.val i.property
  simp [whiteAt] at hw
  exact congrArg (Theta f) (by omega)

/-- **Phase `true` (`10`) `Theta` ↔ `compressedPhi` Bridge Theorem (`Part A (2)` / `D3`):**
For every temporal odd-step free-bit stream `f`, `compressedPhi true` maps the initial-row
white subsequence `thetaWhite f` to the initial-row black subsequence `thetaBlack f`. -/
theorem compressedPhi_true_thetaWhite (f : Stream) :
    compressedPhi true (thetaWhite f) = thetaBlack f := by
  funext k
  change infiniteBits (driver true) (expandWhite true (thetaWhite f)) (blackAt true k) =
    Theta f (2 * k + 1)
  rw [infiniteBits_true_eq_thetaBits]
  rfl

/-- Initial-row 0-indexed bit sequence for phase `false` (`01`), obtained by one backward
step `back b0` from `Theta f`. -/
def backThetaBits (b0 : Bool) (f : Stream) (n : Nat) : Bool :=
  back b0 (Theta f) (n + 1)

/-- Initial-row white subsequence of `back b0 (Theta f)` (depths `2k + 1`, i.e., `whiteAt false k = 2k`). -/
def backThetaWhite (b0 : Bool) (f : Stream) (k : Nat) : Bool :=
  back b0 (Theta f) (2 * k + 1)

/-- Initial-row black subsequence of `back b0 (Theta f)` (depths `2k + 2`, i.e., `blackAt false k = 2k + 1`). -/
def backThetaBlack (b0 : Bool) (f : Stream) (k : Nat) : Bool :=
  back b0 (Theta f) (2 * k + 2)

theorem zrowOfBits_backThetaBits (b0 : Bool) (f : Stream) :
    zrowOfBits (backThetaBits b0 f) = back b0 (Theta f) := by
  funext k
  cases k with
  | zero => rfl
  | succ n => exact zrowOfBits_succ (backThetaBits b0 f) n

theorem backThetaBits_pins (b0 : Bool) (f : Stream) :
    Pins (driver false) (bitRow (backThetaBits b0 f)) := by
  rw [pins_driver_iff_zrow, zrowOfBits_backThetaBits]
  intro t ht
  by_cases hev : t % 2 = 0
  · simp [driver, hev] at ht
  · have ht1 : t = 1 + 2 * (t / 2) := by omega
    rw [ht1, zrow_shift, zrow_congr (L' := Theta f) (fun k hk => zrow_back b0 (Theta f) k hk)]
    exact Theta_inX f (t / 2)

theorem infiniteBits_false_eq_backThetaBits (b0 : Bool) (f : Stream) :
    infiniteBits (driver false) (expandWhite false (backThetaWhite b0 f)) = backThetaBits b0 f := by
  symm
  apply infiniteBits_unique (driver false) (expandWhite false (backThetaWhite b0 f))
    (backThetaBits b0 f) (backThetaBits_pins b0 f)
  intro i
  change back b0 (Theta f) (i.val + 1) = back b0 (Theta f) (2 * (i.val / 2) + 1)
  have hw := whiteAt_of_white false i.val i.property
  simp [whiteAt] at hw
  exact congrArg (back b0 (Theta f)) (by omega)

/-- **Phase `false` (`01`) `back ∘ Theta` ↔ `compressedPhi` Bridge Theorem (`Part A (2)` / `D3`):**
For every initial depth-1 bit `b0` and temporal free-bit stream `f`, `compressedPhi false`
maps `backThetaWhite b0 f` to `backThetaBlack b0 f`. -/
theorem compressedPhi_false_backThetaWhite (b0 : Bool) (f : Stream) :
    compressedPhi false (backThetaWhite b0 f) = backThetaBlack b0 f := by
  funext k
  change infiniteBits (driver false) (expandWhite false (backThetaWhite b0 f)) (blackAt false k) =
    back b0 (Theta f) (2 * k + 2)
  rw [infiniteBits_false_eq_backThetaBits]
  rfl

-- ============================================================================
-- 3. Part C2 (D4): Update-Derived 1-Block Backward Decomposition & Seam Carry
-- ============================================================================

/-- **Update-derived 1-block backward decomposition of `Theta` (`D4`):**
Two steps of `back` with boundary bits `(true, f 0)` reconstruct `Theta f` from the
shifted tail `Theta (fun s => f (s + 1))`. -/
theorem Theta_step_back (f : Stream) (k : Nat) :
    Theta f k = back true (back (f 0) (Theta (fun s => f (s + 1)))) k := by
  have h1 : ∀ m, 1 ≤ m → zrow (zrow (Theta f) 1) 1 m = Theta (fun s => f (s + 1)) m := by
    intro m _
    rw [← zrow_shift (Theta f) 1 1 m, show 1 + 1 = 2 by rfl, two_step_shift]
  have hb1 : ∀ m, zrow (Theta f) 1 m = back (f 0) (Theta (fun s => f (s + 1))) m := by
    intro m
    have heq := eq_back (L := zrow (Theta f) 1) (y := Theta (fun s => f (s + 1))) h1 m
    rw [zrow_zero_self (zrow_wall (Theta f) 1)] at heq
    have hf0 : zrow (Theta f) 1 1 = f 0 := Theta_free f 0
    rwa [hf0] at heq
  have h0 : ∀ m, 1 ≤ m → zrow (Theta f) 1 m = back (f 0) (Theta (fun s => f (s + 1))) m :=
    fun m _ => hb1 m
  have hb0 := eq_back (L := Theta f) (y := back (f 0) (Theta (fun s => f (s + 1)))) h0 k
  rw [zrow_zero_self (Theta_wall f), show Theta f 1 = true from Theta_inX f 0] at hb0
  exact hb0

theorem back_add_two (b : Bool) (y : Nat → Bool) (k : Nat) :
    back b y (k + 2) = xor (y (k + 1)) (back b y (k + 1) || back b y k) := rfl

/-- **2-bit spatial seam carry theorem for `back` (`D4`):**
If two target rows `y0, y1` agree from depth `a + 1` onward and their `back` preimages
agree at the 2-bit seam `(a + 1, a + 2)`, then they agree at all deeper positions. -/
theorem back_agree_from (b0 b1 : Bool) (y0 y1 : Nat → Bool) (a : Nat)
    (hy : ∀ m : Nat, y0 (a + m + 2) = y1 (a + m + 2))
    (ha1 : back b0 y0 (a + 1) = back b1 y1 (a + 1))
    (ha2 : back b0 y0 (a + 2) = back b1 y1 (a + 2)) :
    ∀ m : Nat,
      back b0 y0 (a + m + 1) = back b1 y1 (a + m + 1) ∧
      back b0 y0 (a + m + 2) = back b1 y1 (a + m + 2) := by
  intro m
  induction m with
  | zero => exact ⟨ha1, ha2⟩
  | succ m ih =>
    refine ⟨ih.2, ?_⟩
    rw [show a + (m + 1) + 2 = (a + m + 1) + 2 by omega,
      back_add_two b0 y0 (a + m + 1), back_add_two b1 y1 (a + m + 1),
      show (a + m + 1) + 1 = a + m + 2 by omega, hy m, ih.2, ih.1]

/-- **Depth-3 OR-latch seam erasure for `back` (`D4`):**
Whenever `y 1 = true` and `y 2 = false`, the initial boundary choice `b ∈ {false, true}`
is completely erased from depth `3` onward: `back false y (m + 3) = back true y (m + 3)`. -/
theorem back_or_latch_depth3 (y : Nat → Bool) (hy1 : y 1 = true) (hy2 : y 2 = false) :
    ∀ m : Nat, back false y (m + 3) = back true y (m + 3) := by
  have h3_f : back false y 3 = true := by
    show xor (y 2) (xor (y 1) (false || false) || false) = true
    rw [hy1, hy2]; rfl
  have h3_t : back true y 3 = true := by
    show xor (y 2) (xor (y 1) (true || false) || true) = true
    rw [hy1, hy2]; rfl
  have h4_f : back false y 4 = !(y 3) := by
    show xor (y 3) (back false y 3 || back false y 2) = !(y 3)
    rw [h3_f]; cases y 3 <;> rfl
  have h4_t : back true y 4 = !(y 3) := by
    show xor (y 3) (back true y 3 || back true y 2) = !(y 3)
    rw [h3_t]; cases y 3 <;> rfl
  intro m
  have h := (back_agree_from false true y y 2 (fun _ => rfl)
    (h3_f.trans h3_t.symm) (h4_f.trans h4_t.symm) m).1
  rwa [show 2 + m + 1 = m + 3 by omega] at h

-- ============================================================================
-- 4. Part B & C2: Explicit Low-Depth Outputs, Separations, and Depth-2 Latch Merge
-- ============================================================================

theorem infiniteBits_at_white (phase : Bool) (x : Stream) (k : Nat) :
    infiniteBits (driver phase) (expandWhite phase x) (whiteAt phase k) = x k := by
  have h := infiniteBits_white (driver phase) (expandWhite phase x) (whiteIndex phase k)
  change infiniteBits (driver phase) (expandWhite phase x) (whiteAt phase k) =
    x (whiteAt phase k / 2) at h
  rwa [whiteAt_half] at h

theorem compressedPhi_true_at_zero (x : Stream) :
    compressedPhi true x 0 = true := by
  let a := infiniteBits (driver true) (expandWhite true x)
  have hz0 : zrow (zrowOfBits a) 0 1 = true :=
    (pins_driver_iff_zrow true a).mp (infiniteBits_pins (driver true) (expandWhite true x)) 0 rfl
  have hexp : zrow (zrowOfBits a) 0 1 = a 0 := rfl
  rw [hexp] at hz0
  exact hz0

theorem compressedPhi_true_at_one (x : Stream) :
    compressedPhi true x 1 = !(x 0) := by
  let a := infiniteBits (driver true) (expandWhite true x)
  have ha0 : a 0 = true := compressedPhi_true_at_zero x
  have ha1 : a 1 = x 0 := infiniteBits_at_white true x 0
  have hz2 : zrow (zrowOfBits a) 2 1 = true :=
    (pins_driver_iff_zrow true a).mp (infiniteBits_pins (driver true) (expandWhite true x)) 2 rfl
  have hexp : zrow (zrowOfBits a) 2 1 =
      xor (xor (a 2) (a 1 || a 0)) (xor (a 1) (a 0 || false) || false) := rfl
  rw [hexp, ha0, ha1] at hz2
  change a 2 = !(x 0)
  revert hz2
  cases x 0 <;> cases a 2 <;> decide

theorem compressedPhi_false_at_zero (x : Stream) :
    compressedPhi false x 0 = !(x 0) := by
  let a := infiniteBits (driver false) (expandWhite false x)
  have ha0 : a 0 = x 0 := infiniteBits_at_white false x 0
  have hz1 : zrow (zrowOfBits a) 1 1 = true :=
    (pins_driver_iff_zrow false a).mp (infiniteBits_pins (driver false) (expandWhite false x)) 1 rfl
  have hexp : zrow (zrowOfBits a) 1 1 = xor (a 1) (a 0 || false) := rfl
  rw [hexp, ha0] at hz1
  change a 1 = !(x 0)
  revert hz1
  cases x 0 <;> cases a 1 <;> decide

theorem compressedPhi_false_at_one (x : Stream) :
    compressedPhi false x 1 = (!(x 1) && !(x 0)) := by
  let a := infiniteBits (driver false) (expandWhite false x)
  have ha0 : a 0 = x 0 := infiniteBits_at_white false x 0
  have ha1 : a 1 = !(x 0) := compressedPhi_false_at_zero x
  have ha2 : a 2 = x 1 := infiniteBits_at_white false x 1
  have hz3 : zrow (zrowOfBits a) 3 1 = true :=
    (pins_driver_iff_zrow false a).mp (infiniteBits_pins (driver false) (expandWhite false x)) 3 rfl
  have hexp : zrow (zrowOfBits a) 3 1 =
      xor (xor (xor (a 3) (a 2 || a 1)) (xor (a 2) (a 1 || a 0) || xor (a 1) (a 0 || false)))
        (xor (xor (a 2) (a 1 || a 0)) (xor (a 1) (a 0 || false) || false) || false) := rfl
  rw [hexp, ha0, ha1, ha2] at hz3
  change a 3 = (!(x 1) && !(x 0))
  revert hz3
  cases x 0 <;> cases x 1 <;> cases a 3 <;> decide

/-- **Depth-1 Myhill–Nerode separation for phase `true` (`10`):**
`[false]` and `[true]` have distinct residuals under `compressedPhi true`. -/
theorem residual_true_sep_depth1 :
    residual (compressedPhi true) [false] ≠ residual (compressedPhi true) [true] := by
  intro h
  have h0 := congrFun (congrFun h (fun _ => false)) 0
  change compressedPhi true (prepend [false] (fun _ => false)) 1 =
    compressedPhi true (prepend [true] (fun _ => false)) 1 at h0
  rw [compressedPhi_true_at_one, compressedPhi_true_at_one] at h0
  revert h0
  decide

/-- **Depth-1 Myhill–Nerode separation for phase `false` (`01`):**
`[false]` and `[true]` have distinct residuals under `compressedPhi false`. -/
theorem residual_false_sep_depth1 :
    residual (compressedPhi false) [false] ≠ residual (compressedPhi false) [true] := by
  intro h
  have h0 := congrFun (congrFun h (fun _ => false)) 0
  change compressedPhi false (prepend [false] (fun _ => false)) 1 =
    compressedPhi false (prepend [true] (fun _ => false)) 1 at h0
  rw [compressedPhi_false_at_one, compressedPhi_false_at_one] at h0
  revert h0
  decide

/-- Flip only the first two initial-row bits `(a 0, a 1) ↦ (true, false)` while keeping
all bits at indices `n ≥ 2` identical to `a`. -/
def latchSwapBits (a : Nat → Bool) : Nat → Bool
  | 0 => true
  | 1 => false
  | n + 2 => a (n + 2)

theorem latchSwapBits_zero (a : Nat → Bool) : latchSwapBits a 0 = true := rfl
theorem latchSwapBits_one (a : Nat → Bool) : latchSwapBits a 1 = false := rfl
theorem latchSwapBits_add_two (a : Nat → Bool) (n : Nat) :
    latchSwapBits a (n + 2) = a (n + 2) := rfl

theorem stepSeed_latchSwapBits_eq (a : Nat → Bool)
    (ha0 : a 0 = false) (ha1 : a 1 = true) (ha2 : a 2 = true) :
    ∀ p : Int, p < 0 →
      Rule30DrivenLeft.L (driver false) (bitRow (latchSwapBits a)) 1 p =
        Rule30DrivenLeft.L (driver false) (bitRow a) 1 p := by
  intro p hp
  obtain ⟨k, rfl⟩ : ∃ k : Nat, p = -((k + 1 : Nat) : Int) := ⟨(-p - 1).toNat, by omega⟩
  change Rule30DrivenLeft.L (driver false) (bitRow (latchSwapBits a)) 1 (-((k + 1 : Nat) : Int)) =
    Rule30DrivenLeft.L (driver false) (bitRow a) 1 (-((k + 1 : Nat) : Int))
  cases k with
  | zero =>
    rw [Rule30DrivenLeft.L_succ (by omega), Rule30DrivenLeft.L_succ (by omega),
      show (-((0 + 1 : Nat) : Int)) - 1 = -((1 + 1 : Nat) : Int) by rfl,
      show (-((0 + 1 : Nat) : Int)) + 1 = 0 by rfl,
      Rule30DrivenLeft.L_col0, Rule30DrivenLeft.L_col0,
      Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
      Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
      bitRow_at (latchSwapBits a) 1, bitRow_at (latchSwapBits a) 0,
      bitRow_at a 1, bitRow_at a 0,
      latchSwapBits_one, latchSwapBits_zero, ha0, ha1]
    rfl
  | succ k1 =>
    cases k1 with
    | zero =>
      rw [Rule30DrivenLeft.L_succ (by omega), Rule30DrivenLeft.L_succ (by omega),
        show (-((1 + 1 : Nat) : Int)) - 1 = -((2 + 1 : Nat) : Int) by rfl,
        show (-((1 + 1 : Nat) : Int)) + 1 = -((0 + 1 : Nat) : Int) by rfl,
        Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
        Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
        Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
        bitRow_at (latchSwapBits a) 2, bitRow_at (latchSwapBits a) 1, bitRow_at (latchSwapBits a) 0,
        bitRow_at a 2, bitRow_at a 1, bitRow_at a 0,
        latchSwapBits_add_two a 0, latchSwapBits_one, latchSwapBits_zero, ha0, ha1, ha2]
      rfl
    | succ k2 =>
      cases k2 with
      | zero =>
        rw [Rule30DrivenLeft.L_succ (by omega), Rule30DrivenLeft.L_succ (by omega),
          show (-((2 + 1 : Nat) : Int)) - 1 = -((3 + 1 : Nat) : Int) by rfl,
          show (-((2 + 1 : Nat) : Int)) + 1 = -((1 + 1 : Nat) : Int) by rfl,
          Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
          Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
          Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
          bitRow_at (latchSwapBits a) 3, bitRow_at (latchSwapBits a) 2, bitRow_at (latchSwapBits a) 1,
          bitRow_at a 3, bitRow_at a 2, bitRow_at a 1,
          latchSwapBits_add_two a 1, latchSwapBits_add_two a 0, latchSwapBits_one, ha1, ha2]
        cases a 3 <;> rfl
      | succ k3 =>
        rw [Rule30DrivenLeft.L_succ (by omega), Rule30DrivenLeft.L_succ (by omega),
          show (-((k3 + 3 + 1 : Nat) : Int)) - 1 = -((k3 + 4 + 1 : Nat) : Int) by omega,
          show (-((k3 + 3 + 1 : Nat) : Int)) + 1 = -((k3 + 2 + 1 : Nat) : Int) by omega,
          Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
          Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
          Rule30DrivenLeft.L_zero (by omega), Rule30DrivenLeft.L_zero (by omega),
          bitRow_at (latchSwapBits a) (k3 + 4), bitRow_at (latchSwapBits a) (k3 + 3),
          bitRow_at (latchSwapBits a) (k3 + 2),
          bitRow_at a (k3 + 4), bitRow_at a (k3 + 3), bitRow_at a (k3 + 2)]
        rfl

theorem L_latchSwapBits_eq_from_one (a : Nat → Bool)
    (ha0 : a 0 = false) (ha1 : a 1 = true) (ha2 : a 2 = true) :
    ∀ (t : Nat) (p : Int), p < 0 →
      Rule30DrivenLeft.L (driver false) (bitRow (latchSwapBits a)) (t + 1) p =
        Rule30DrivenLeft.L (driver false) (bitRow a) (t + 1) p := by
  intro t
  induction t with
  | zero =>
    intro p hp
    exact stepSeed_latchSwapBits_eq a ha0 ha1 ha2 p hp
  | succ t ih =>
    intro p hp
    have hL := Rule30DrivenLeft.L_succ (c := driver false) (s := bitRow (latchSwapBits a)) (t := t + 1) hp
    have hR := Rule30DrivenLeft.L_succ (c := driver false) (s := bitRow a) (t := t + 1) hp
    rw [hL, hR, ih (p - 1) (by omega), ih p hp]
    by_cases hp1 : p + 1 < 0
    · rw [ih (p + 1) hp1]
    · have hp0 : p + 1 = 0 := by omega
      rw [hp0, Rule30DrivenLeft.L_col0, Rule30DrivenLeft.L_col0]

theorem pins_latchSwapBits (z : Stream) :
    let a := infiniteBits (driver false) (expandWhite false (prepend [false, true] z))
    Pins (driver false) (bitRow (latchSwapBits a)) := by
  intro a t ht
  cases t with
  | zero => simp [driver] at ht
  | succ t' =>
    have ha0 : a 0 = false := infiniteBits_at_white false (prepend [false, true] z) 0
    have ha1 : a 1 = true := compressedPhi_false_at_zero (prepend [false, true] z)
    have ha2 : a 2 = true := infiniteBits_at_white false (prepend [false, true] z) 1
    rw [L_latchSwapBits_eq_from_one a ha0 ha1 ha2 t' (-1) (by omega)]
    exact infiniteBits_pins (driver false) (expandWhite false (prepend [false, true] z)) (t' + 1) ht

theorem infiniteBits_true_true_eq_latchSwapBits (z : Stream) :
    infiniteBits (driver false) (expandWhite false (prepend [true, true] z)) =
      latchSwapBits (infiniteBits (driver false) (expandWhite false (prepend [false, true] z))) := by
  let a := infiniteBits (driver false) (expandWhite false (prepend [false, true] z))
  symm
  apply infiniteBits_unique (driver false) (expandWhite false (prepend [true, true] z))
    (latchSwapBits a) (pins_latchSwapBits z)
  intro i
  have hw := whiteAt_of_white false i.val i.property
  simp [whiteAt] at hw
  obtain ⟨k, hk⟩ : ∃ k : Nat, i.val = 2 * k := ⟨i.val / 2, by omega⟩
  cases k with
  | zero =>
    change latchSwapBits a i.val = (prepend [true, true] z) (i.val / 2)
    rw [hk]
    rfl
  | succ k1 =>
    cases k1 with
    | zero =>
      change latchSwapBits a i.val = (prepend [true, true] z) (i.val / 2)
      rw [hk]
      exact infiniteBits_at_white false (prepend [false, true] z) 1
    | succ k2 =>
      change latchSwapBits a i.val = (prepend [true, true] z) (i.val / 2)
      have hi : i.val = (2 * k2 + 2) + 2 := by omega
      have hdiv : i.val / 2 = k2 + 2 := by omega
      rw [hi, latchSwapBits, ← hi, hdiv]
      have h_orig := infiniteBits_at_white false (prepend [false, true] z) (k2 + 2)
      change a (2 * (k2 + 2)) = (prepend [false, true] z) (k2 + 2) at h_orig
      rw [← hk] at h_orig
      exact h_orig

/-- **All-Continuation Depth-2 Myhill–Nerode Latch Merge (`Part B` & `C2` / `D4`):**
Under `compressedPhi false` (phase `01`), the prefixes `[false, true]` and `[true, true]`
have identical residual functions across **all** infinite continuations `z : Stream` and
all future output depths `k : Nat`. -/
theorem residual_false_latch_merge_depth2 :
    residual (compressedPhi false) [false, true] =
      residual (compressedPhi false) [true, true] := by
  funext z k
  change infiniteBits (driver false) (expandWhite false (prepend [false, true] z))
      (blackAt false (2 + k)) =
    infiniteBits (driver false) (expandWhite false (prepend [true, true] z))
      (blackAt false (2 + k))
  rw [infiniteBits_true_true_eq_latchSwapBits z]
  have hblk : blackAt false (2 + k) = (2 * k + 3) + 2 := by
    simp [blackAt]; omega
  rw [hblk, latchSwapBits]

theorem residualEquiv_false_latch_merge_depth2 :
    ResidualEquiv (compressedPhi false) [false, true] [true, true] :=
  ⟨rfl, residual_false_latch_merge_depth2⟩

#print axioms ResidualEquiv
#print axioms residual_step_congr
#print axioms pins_driver_true_iff_inX
#print axioms compressedPhi_true_thetaWhite
#print axioms compressedPhi_false_backThetaWhite
#print axioms Theta_step_back
#print axioms back_agree_from
#print axioms back_or_latch_depth3
#print axioms residual_true_sep_depth1
#print axioms residual_false_sep_depth1
#print axioms residual_false_latch_merge_depth2

end FVLT.S4mPeriodTwoResidualsV1
