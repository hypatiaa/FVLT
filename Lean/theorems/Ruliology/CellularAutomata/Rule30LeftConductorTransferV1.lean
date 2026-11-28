module

public import Ruliology.CellularAutomata.Rule30Prize

@[expose] public section

namespace Ruliology.CellularAutomata.Rule30LeftConductorTransferV1

open Ruliology.CellularAutomata

/-!
# Redirected Task T7 (#878): Exact-Conductor & Residue-Class Transfer Through the Forced Left Sideways Map
(Vision / Gemini, 2026-10-28)

Formal Lean 4 verification for Stack Bus `#878` (with Sol's exact-projection and
nonlinear transfer/cancellation/regeneration qualifications).
All theorems are universally quantified over arbitrary right-half configurations
`R : Nat → Bool` and arbitrary Boolean trace streams `u : Nat → Bool`.

## Contents
1. **Sideways Recurrence, Algebraic Normal Form, and Spin Identity**:
   - `leftSidewaysBit c_d_next c_d c_dm1 = xor c_d_next (c_d || c_dm1)`
   - Exact equivalence with forward Rule 30 step (`leftSidewaysBit_iff_rule30Bit`)
   - Exact $\mathbb{F}_2$ ANF decomposition (`leftSidewaysBit_anf`)
   - Exact spin $\{-1, +1\}$ nonlinear transfer identity (`leftSidewaysBit_spin_eq`)
2. **Three Exact Nonlinear Spectral Transfer / Cancellation Mechanisms**:
   - Mechanism 1 (OR-Shielding Linear Phase-Inverting Shift): `leftSidewaysBit_or_shield_left`, `leftSidewaysBit_or_shield_right`
   - Mechanism 2a (Complementary OR-Saturation Cancellation): `leftSidewaysBit_complement_or_cancel`
   - Mechanism 2b (Shift-vs-OR XOR Self-Cancellation): `leftSidewaysBit_complement_xor_cancel`
3. **Period 2 (`w = 01`, $2p = 4$) Universal Golden-Mean & Left Column Transfer ($d = 1 \dots 4$)**:
   - `w01_right_trace_no_adj_ones`: For every initial right row $R_0$ and every $k \ge 0$,
     the white-time trace $u(k) = R(2k, 1)$ satisfies $u(k) \land u(k+1) = \text{false}$.
   - `w01_col1_4_symbolic`: Exact symbolic formulas for $\operatorname{col}_1 \dots \operatorname{col}_4$,
     proving that $\operatorname{col}_4(2k) = u(k) \land u(k+1) = \text{false}$ identically (`w01_col4_even_zero`),
     which cuts the number of active off-$\mathrm{Div}(4)$ residue classes in half from $2$ ($d = 2, 3$)
     to $1$ ($d = 4$) and refutes monotonicity of single-column and pair off-$\mathrm{Div}(4)$ energy.
   - `w01_ether_period4_cycle`: Exact $(7, 4)$-ether lock where all left columns have period $4 = 2p$
     (hence identically zero off-$\mathrm{Div}(4)$ energy $A_d = 0$ for all $d \ge 0$) while repeating
     spatially with period $7$ ($\operatorname{col}_{d+7} = \operatorname{col}_d$).
4. **Period 3 (`w = 001` and `w = 011`, $2p = 6$) Exact Left Column Transfer, Cancellation & Regeneration**:
   - `w001_col1_6_symbolic`: Exact symbolic formulas for $\operatorname{col}_1 \dots \operatorname{col}_6$
     under `w = 001` with $r(3k) = \text{false}$, proving the $(1, 2, 1, 1, 3, 3)$ active-stream sequence:
     doubling at $d = 1 \to 2$, $50\%$ cancellation at $d = 2 \to 3$, $\mathbb{F}_2$-difference filtering
     $u_0 \oplus u_1$ at $d = 4$, and 3-stream regeneration at $d = 5, 6$.
   - `w011_col1_4_symbolic`: Exact symbolic formulas for $\operatorname{col}_1 \dots \operatorname{col}_4$
     under `w = 011` for any right trace $r$, proving the $(1, 2, 3, 1)$ active-stream sequence and exact
     boundary reset $(\neg(u_0 \oplus u_1), \text{false}, \text{true})$ at $d = 4$.
-/

/-- Elementary Rule 30 local update `p ⊕ (q ∨ r)`. -/
def rule30Bit (p q r : Bool) : Bool :=
  xor p (q || r)

/-- One step of the forced left sideways map:
`col(d+1, t) = col(d, t+1) ⊕ (col(d, t) ∨ col(d-1, t))`. -/
def leftSidewaysBit (c_d_next c_d c_dm1 : Bool) : Bool :=
  xor c_d_next (c_d || c_dm1)

/-- Forced left head `h(t) = c(t+1) ⊕ (c(t) ∨ r(t))`. -/
def forcedHeadBit (c_next c_cur r_cur : Bool) : Bool :=
  xor c_next (c_cur || r_cur)

/-- Spin encoding `x = 2b - 1 ∈ {-1, +1}` used in FVLT exact-conductor profiles. -/
def spin (b : Bool) : Int :=
  if b then 1 else -1

/-- One step of Rule 30 on the right half (`idx = j - 1`, driven by centre bit `c`). -/
def rightStep (c : Bool) (R : Nat → Bool) (idx : Nat) : Bool :=
  match idx with
  | 0 => rule30Bit c (R 0) (R 1)
  | k + 1 => rule30Bit (R k) (R (k + 1)) (R (k + 2))

/-! ## 1. Sideways Recurrence, Algebraic Normal Form, and Spin Identity -/

/-- Exact equivalence between the left sideways map and the forward Rule 30 step. -/
theorem leftSidewaysBit_iff_rule30Bit (c_dp1 c_d_next c_d c_dm1 : Bool) :
    c_dp1 = leftSidewaysBit c_d_next c_d c_dm1 ↔
      c_d_next = rule30Bit c_dp1 c_d c_dm1 := by
  cases c_dp1 <;> cases c_d_next <;> cases c_d <;> cases c_dm1 <;> decide

/-- Algebraic Normal Form (ANF) over $\mathbb{F}_2$: the sideways step decomposes into
the linear shift-difference `c_d_next ⊕ c_d ⊕ c_dm1` and the quadratic term `c_d && c_dm1`. -/
theorem leftSidewaysBit_anf (c_d_next c_d c_dm1 : Bool) :
    leftSidewaysBit c_d_next c_d c_dm1 =
      xor (xor c_d_next (xor c_d c_dm1)) (c_d && c_dm1) := by
  cases c_d_next <;> cases c_d <;> cases c_dm1 <;> rfl

/-- Exact spin identity in $\mathbb{Z}$ (`x = 2b - 1 ∈ {-1, +1}`):
`2 * spin(col_{d+1}(t)) = - spin(col_d(t+1)) * (1 + spin(col_d(t)) + spin(col_{d-1}(t)) - spin(col_d(t)) * spin(col_{d-1}(t)))`. -/
theorem leftSidewaysBit_spin_eq (c_d_next c_d c_dm1 : Bool) :
    2 * spin (leftSidewaysBit c_d_next c_d c_dm1) =
      - spin c_d_next * (1 + spin c_d + spin c_dm1 - spin c_d * spin c_dm1) := by
  cases c_d_next <;> cases c_d <;> cases c_dm1 <;> rfl

/-! ## 2. Three Exact Nonlinear Spectral Transfer / Cancellation Mechanisms -/

/-- Mechanism 1a (OR-Shielding by `col_d = true`): the lower-depth bit `c_dm1` is
completely annihilated, and `c_d_next` transfers with exact bitwise negation. -/
theorem leftSidewaysBit_or_shield_left (c_d_next c_dm1 : Bool) :
    leftSidewaysBit c_d_next true c_dm1 = !c_d_next := by
  cases c_d_next <;> cases c_dm1 <;> rfl

/-- Mechanism 1b (OR-Shielding by `col_{d-1} = true`): `c_d` is completely annihilated,
and `c_d_next` transfers with exact bitwise negation. -/
theorem leftSidewaysBit_or_shield_right (c_d_next c_d : Bool) :
    leftSidewaysBit c_d_next c_d true = !c_d_next := by
  cases c_d_next <;> cases c_d <;> rfl

/-- Mechanism 2a (Complementary OR-Saturation Cancellation): two complementary streams
`u` and `!u` at depths `d` and `d-1` saturate the OR gate (`u || !u = true`), cancelling
their fluctuations identically inside the OR gate. -/
theorem leftSidewaysBit_complement_or_cancel (c_d_next u : Bool) :
    leftSidewaysBit c_d_next u (!u) = !c_d_next ∧
      leftSidewaysBit c_d_next (!u) u = !c_d_next := by
  cases c_d_next <;> cases u <;> decide

/-- Mechanism 2b (Shift-vs-OR XOR Cancellation): when `c_d_next = u`, `c_d = !u`,
and `c_dm1 = false`, the shift term and the OR term cancel identically in the XOR gate
to the constant `true`, eliminating all off-period energy in that residue class. -/
theorem leftSidewaysBit_complement_xor_cancel (u : Bool) :
    leftSidewaysBit u (!u) false = true ∧
      leftSidewaysBit (!u) u false = true := by
  cases u <;> decide

/-! ## 3. Period 2 (`w = 01`, $2p = 4$): Universal Golden-Mean Law & Left Column Transfer -/

/-- First step of a `01` period block (`c = false`). -/
def step01_1 (R : Nat → Bool) : Nat → Bool :=
  rightStep false R

/-- Complete 2-step `01` period block (`c = false, true`). -/
def block01 (R : Nat → Bool) : Nat → Bool :=
  rightStep true (step01_1 R)

/-- Universal Golden-Mean Theorem for `w = 01`: for ANY right-half configuration `R`,
if the right head at an even step is `R 0 = true`, then after one full `01` period
(`block01 R`) the right head is `false`. Equivalently, `u(k) && u(k+1) = false`
for every initial right row $R_0$ and every $k \ge 0$. -/
theorem w01_right_trace_no_adj_ones (R : Nat → Bool) :
    (R 0 && block01 R 0) = false := by
  dsimp [block01, step01_1, rightStep, rule30Bit]
  cases R 0 <;> cases R 1 <;> cases R 2 <;> decide

/-- Exact symbolic left column transfer for `w = 01` across depths `d = 1 .. 4`
on residue classes `(2k, 2k+1)` from white-time trace values `(u0, u1, u2)`
and arbitrary black-time trace values `(v0, v1, v2)`:
- `col1 = (!u0, true)` (completely independent of `v0`)
- `col2 = (u0, u1)` (2 active streams)
- `col3 = (!u1, !u1)` (2 synchronized active streams)
- `col4 = (u0 && u1, u2)` (collapses to `(false, u2)` whenever `u0 && u1 = false`). -/
theorem w01_col1_4_symbolic (u0 v0 u1 v1 u2 : Bool) :
    let c0_0 := false
    let c0_1 := true
    let c0_2 := false
    let c0_3 := true
    let c0_4 := false
    let c0_5 := true
    -- col1 at t = 2k .. 2k+4
    let c1_0 := forcedHeadBit c0_1 c0_0 u0
    let c1_1 := forcedHeadBit c0_2 c0_1 v0
    let c1_2 := forcedHeadBit c0_3 c0_2 u1
    let c1_3 := forcedHeadBit c0_4 c0_3 v1
    let c1_4 := forcedHeadBit c0_5 c0_4 u2
    -- col2 at t = 2k .. 2k+3
    let c2_0 := leftSidewaysBit c1_1 c1_0 c0_0
    let c2_1 := leftSidewaysBit c1_2 c1_1 c0_1
    let c2_2 := leftSidewaysBit c1_3 c1_2 c0_2
    let c2_3 := leftSidewaysBit c1_4 c1_3 c0_3
    -- col3 at t = 2k .. 2k+2
    let c3_0 := leftSidewaysBit c2_1 c2_0 c1_0
    let c3_1 := leftSidewaysBit c2_2 c2_1 c1_1
    let c3_2 := leftSidewaysBit c2_3 c2_2 c1_2
    -- col4 at t = 2k .. 2k+1
    let c4_0 := leftSidewaysBit c3_1 c3_0 c2_0
    let c4_1 := leftSidewaysBit c3_2 c3_1 c2_1
    (c1_0, c1_1) = (!u0, true) ∧
    (c2_0, c2_1) = (u0, u1) ∧
    (c3_0, c3_1) = (!u1, !u1) ∧
    (c4_0, c4_1) = (u0 && u1, u2) := by
  cases u0 <;> cases v0 <;> cases u1 <;> cases v1 <;> cases u2 <;> decide

/-- Combining `w01_right_trace_no_adj_ones` with `w01_col1_4_symbolic` proves that
for EVERY right-half configuration `R`, the even-time residue class of `col4` is
identically `false` (`col4(2k) = false`), halving the number of active streams from 2 to 1. -/
theorem w01_col4_even_zero (R : Nat → Bool) (v0 v1 u2 : Bool) :
    let u0 := R 0
    let u1 := block01 R 0
    let c1_0 := forcedHeadBit true false u0
    let c1_1 := forcedHeadBit false true v0
    let c1_2 := forcedHeadBit true false u1
    let c1_3 := forcedHeadBit false true v1
    let c1_4 := forcedHeadBit true false u2
    let c2_0 := leftSidewaysBit c1_1 c1_0 false
    let c2_1 := leftSidewaysBit c1_2 c1_1 true
    let c2_2 := leftSidewaysBit c1_3 c1_2 false
    let c2_3 := leftSidewaysBit c1_4 c1_3 true
    let c3_0 := leftSidewaysBit c2_1 c2_0 c1_0
    let c3_1 := leftSidewaysBit c2_2 c2_1 c1_1
    let c3_2 := leftSidewaysBit c2_3 c2_2 c1_2
    let c4_0 := leftSidewaysBit c3_1 c3_0 c2_0
    let c4_1 := leftSidewaysBit c3_2 c3_1 c2_1
    (c4_0, c4_1) = (false, u2) := by
  have hno := w01_right_trace_no_adj_ones R
  have hsym := w01_col1_4_symbolic (R 0) v0 (block01 R 0) v1 u2
  rcases hsym with ⟨_, _, _, h4⟩
  rw [hno] at h4
  exact h4

/-- Period-4 sideways operator on 4-tuples `(b0, b1, b2, b3)` representing a strictly
4-periodic column (`2p = 4` for `w = 01`). -/
def sidewaysMod4 (prev cur : Bool × Bool × Bool × Bool) : Bool × Bool × Bool × Bool :=
  let (p0, p1, p2, p3) := prev
  let (c0, c1, c2, c3) := cur
  (leftSidewaysBit c1 c0 p0,
   leftSidewaysBit c2 c1 p1,
   leftSidewaysBit c3 c2 p2,
   leftSidewaysBit c0 c3 p3)

/-- Exact `(7, 4)`-ether cycle for `w = 01`: when the right trace has period 4
`r = (true, true, false, false)^∞` (realized from `t = 0` by finite right row `R0 = 9`),
`col0 = (false, true, false, true)` and `col1 = (false, true, true, true)` generate a
strictly 7-periodic spatial cycle of 4-periodic left columns (`col7 = col0, col8 = col1`),
all having identically zero off-`Div(4)` energy while forcing `col_d(0) = true`
at `d ≡ 2, 3, 6 (mod 7)`. -/
theorem w01_ether_period4_cycle :
    let col0 := (false, true, false, true)
    let col1 := (false, true, true, true)
    let col2 := sidewaysMod4 col0 col1
    let col3 := sidewaysMod4 col1 col2
    let col4 := sidewaysMod4 col2 col3
    let col5 := sidewaysMod4 col3 col4
    let col6 := sidewaysMod4 col4 col5
    let col7 := sidewaysMod4 col5 col6
    let col8 := sidewaysMod4 col6 col7
    col2 = (true, false, false, true) ∧
    col3 = (true, true, false, false) ∧
    col4 = (false, true, false, false) ∧
    col5 = (false, true, false, false) ∧
    col6 = (true, true, false, false) ∧
    col7 = col0 ∧
    col8 = col1 := by
  decide

/-! ## 4. Period 3 (`w = 001` and `w = 011`, $2p = 6$): Exact Transfer, Cancellation & Regeneration -/

/-- Exact symbolic left column transfer for `w = 001` across depths `d = 1 .. 6`
when `r(3k) = false` and `u0 = r(3k+1), u1 = r(3k+4), u2 = r(3k+7)` (with arbitrary
black-time bits `w0, w1, w2` at `3k+2`):
- `col1 = (false, !u0, true)` (1 active stream)
- `col2 = (!u0, u0, true)` (2 active streams: off-period energy doubles to `2 E_u`)
- `col3 = (true, false, u1)` (1 active stream: exact cancellation in residues 0 and 1 cuts energy back to `E_u`)
- `col4 = (true, xor u0 u1, false)` (1 active stream: exact $\mathbb{F}_2$-difference filter `w_k = u_k ⊕ u_{k+1}`)
- `col5 = (!(xor u0 u1), xor u0 u1, !u1)` (3 active streams: regeneration to `2 E_w + E_u`)
- `col6 = (!(xor u0 u1), !u0, u2)` (3 active streams: energy `E_w + 2 E_u`). -/
theorem w001_col1_6_symbolic (u0 w0 u1 w1 u2 w2 : Bool) :
    -- col1 at t = 3k .. 3k+7
    let c1_0 := forcedHeadBit false false false
    let c1_1 := forcedHeadBit true false u0
    let c1_2 := forcedHeadBit false true w0
    let c1_3 := forcedHeadBit false false false
    let c1_4 := forcedHeadBit true false u1
    let c1_5 := forcedHeadBit false true w1
    let c1_6 := forcedHeadBit false false false
    let c1_7 := forcedHeadBit true false u2
    let _ := w2
    -- col2 at t = 3k .. 3k+6
    let c2_0 := leftSidewaysBit c1_1 c1_0 false
    let c2_1 := leftSidewaysBit c1_2 c1_1 false
    let c2_2 := leftSidewaysBit c1_3 c1_2 true
    let c2_3 := leftSidewaysBit c1_4 c1_3 false
    let c2_4 := leftSidewaysBit c1_5 c1_4 false
    let c2_5 := leftSidewaysBit c1_6 c1_5 true
    let c2_6 := leftSidewaysBit c1_7 c1_6 false
    -- col3 at t = 3k .. 3k+5
    let c3_0 := leftSidewaysBit c2_1 c2_0 c1_0
    let c3_1 := leftSidewaysBit c2_2 c2_1 c1_1
    let c3_2 := leftSidewaysBit c2_3 c2_2 c1_2
    let c3_3 := leftSidewaysBit c2_4 c2_3 c1_3
    let c3_4 := leftSidewaysBit c2_5 c2_4 c1_4
    let c3_5 := leftSidewaysBit c2_6 c2_5 c1_5
    -- col4 at t = 3k .. 3k+4
    let c4_0 := leftSidewaysBit c3_1 c3_0 c2_0
    let c4_1 := leftSidewaysBit c3_2 c3_1 c2_1
    let c4_2 := leftSidewaysBit c3_3 c3_2 c2_2
    let c4_3 := leftSidewaysBit c3_4 c3_3 c2_3
    let c4_4 := leftSidewaysBit c3_5 c3_4 c2_4
    -- col5 at t = 3k .. 3k+3
    let c5_0 := leftSidewaysBit c4_1 c4_0 c3_0
    let c5_1 := leftSidewaysBit c4_2 c4_1 c3_1
    let c5_2 := leftSidewaysBit c4_3 c4_2 c3_2
    let c5_3 := leftSidewaysBit c4_4 c4_3 c3_3
    -- col6 at t = 3k .. 3k+2
    let c6_0 := leftSidewaysBit c5_1 c5_0 c4_0
    let c6_1 := leftSidewaysBit c5_2 c5_1 c4_1
    let c6_2 := leftSidewaysBit c5_3 c5_2 c4_2
    (c1_0, c1_1, c1_2) = (false, !u0, true) ∧
    (c2_0, c2_1, c2_2) = (!u0, u0, true) ∧
    (c3_0, c3_1, c3_2) = (true, false, u1) ∧
    (c4_0, c4_1, c4_2) = (true, xor u0 u1, false) ∧
    (c5_0, c5_1, c5_2) = (!(xor u0 u1), xor u0 u1, !u1) ∧
    (c6_0, c6_1, c6_2) = (!(xor u0 u1), !u0, u2) := by
  cases u0 <;> cases w0 <;> cases u1 <;> cases w1 <;> cases u2 <;> cases w2 <;> decide

/-- Exact symbolic left column transfer for `w = 011` (`c = (false, true, true)^∞`)
across depths `d = 1 .. 4` for ANY right trace (with white-time trace `u0 = r(3k), u1 = r(3k+3)`
and arbitrary black-time bits `v0, w0, v1, w1`):
- `col1 = (!u0, false, true)` (1 active stream)
- `col2 = (!u0, false, u1)` (2 active streams)
- `col3 = (!u0, u1, u1)` (3 active streams)
- `col4 = (!(xor u0 u1), false, true)` (exact cancellation in residues 1 and 2 back to `(false, true)`,
  resetting the `col1` pattern with `u_k` replaced by `u_k ⊕ u_{k+1}`). -/
theorem w011_col1_4_symbolic (u0 v0 w0 u1 v1 w1 : Bool) :
    -- col1 at t = 3k .. 3k+5
    let c1_0 := forcedHeadBit true false u0
    let c1_1 := forcedHeadBit true true v0
    let c1_2 := forcedHeadBit false true w0
    let c1_3 := forcedHeadBit true false u1
    let c1_4 := forcedHeadBit true true v1
    let c1_5 := forcedHeadBit false true w1
    -- col2 at t = 3k .. 3k+4
    let c2_0 := leftSidewaysBit c1_1 c1_0 false
    let c2_1 := leftSidewaysBit c1_2 c1_1 true
    let c2_2 := leftSidewaysBit c1_3 c1_2 true
    let c2_3 := leftSidewaysBit c1_4 c1_3 false
    let c2_4 := leftSidewaysBit c1_5 c1_4 true
    -- col3 at t = 3k .. 3k+3
    let c3_0 := leftSidewaysBit c2_1 c2_0 c1_0
    let c3_1 := leftSidewaysBit c2_2 c2_1 c1_1
    let c3_2 := leftSidewaysBit c2_3 c2_2 c1_2
    let c3_3 := leftSidewaysBit c2_4 c2_3 c1_3
    -- col4 at t = 3k .. 3k+2
    let c4_0 := leftSidewaysBit c3_1 c3_0 c2_0
    let c4_1 := leftSidewaysBit c3_2 c3_1 c2_1
    let c4_2 := leftSidewaysBit c3_3 c3_2 c2_2
    (c1_0, c1_1, c1_2) = (!u0, false, true) ∧
    (c2_0, c2_1, c2_2) = (!u0, false, u1) ∧
    (c3_0, c3_1, c3_2) = (!u0, u1, u1) ∧
    (c4_0, c4_1, c4_2) = (!(xor u0 u1), false, true) := by
  cases u0 <;> cases v0 <;> cases w0 <;> cases u1 <;> cases v1 <;> cases w1 <;> decide

end Ruliology.CellularAutomata.Rule30LeftConductorTransferV1
