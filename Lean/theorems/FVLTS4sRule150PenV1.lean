import Ruliology.CellularAutomata.Rule30Realization
import Mathlib.Tactic

/-! Rule 150 pen confinement.

The squeezed-sphere pen reads the centre pair (x_t(0), x_t(1)). For single-seed Rule 150
the centre is always black (kit `center150`), so the pen turns left exactly when x_t(1) is
black. We prove:

* `double`: Rule 150 from one cell satisfies x_{2t}(p) = [p even] x_t(p/2) (Frobenius over F_2);
* `col_even`, `col_odd`: the column c(t) = x_t(1) obeys c(2t) = false, c(2t+1) = !c(t);
* `block8`: every 8-step block of the pen is fixed by c(m) alone;
* `pen_at_8m`: at times 8m the pen is at (0,0) heading east or at (-2,0) heading west;
* `pen_confined`: for every t, |x| ≤ 3 and |y| ≤ 2.

The planar pen turns ±90° and steps one lattice unit (heading 0 = east), as in
`frontier_dimension_v0_1.py`. Exact; no claim about Rule 30.
Credits: saphir (the pen on surfaces); the kit (`run`, `g150`, `center150`). -/
namespace FVLT.S4sRule150PenV1
open Ruliology.CellularAutomata.Rule30Realization

/-- Two Rule 150 steps: x_{t+2}(p) = x_t(p-2) ⊕ x_t(p) ⊕ x_t(p+2). -/
theorem two_step (t : Nat) (p : Int) :
    run g150 (t + 1 + 1) p =
      xor (run g150 t (p - 2)) (xor (run g150 t p) (run g150 t (p + 2))) := by
  have e1 : p - 1 - 1 = p - 2 := by omega
  have e2 : p - 1 + 1 = p := by omega
  have e3 : p + 1 - 1 = p := by omega
  have e4 : p + 1 + 1 = p + 2 := by omega
  simp only [run, g150, e1, e2, e3, e4]
  generalize run g150 t (p - 2) = a
  generalize run g150 t (p - 1) = b
  generalize run g150 t p = c
  generalize run g150 t (p + 1) = d
  generalize run g150 t (p + 2) = e
  cases a <;> cases b <;> cases c <;> cases d <;> cases e <;> rfl

/-- Frobenius doubling for single-seed Rule 150. -/
theorem double : ∀ (t : Nat) (p : Int),
    run g150 (2 * t) p = if p % 2 = 0 then run g150 t (p / 2) else false
  | 0, p => by
    by_cases h : p % 2 = 0
    · rw [if_pos h]
      show decide (p = 0) = decide (p / 2 = 0)
      exact decide_eq_decide.mpr (by omega)
    · rw [if_neg h]
      show decide (p = 0) = false
      exact decide_eq_false (by omega)
  | t + 1, p => by
    rw [show 2 * (t + 1) = 2 * t + 1 + 1 by ring, two_step, double t (p - 2), double t p,
      double t (p + 2)]
    by_cases h : p % 2 = 0
    · have h1 : (p - 2) % 2 = 0 := by omega
      have h2 : (p + 2) % 2 = 0 := by omega
      have e1 : (p - 2) / 2 = p / 2 - 1 := by omega
      have e2 : (p + 2) / 2 = p / 2 + 1 := by omega
      simp only [h, h1, h2, if_true, e1, e2]
      rfl
    · have h1 : ¬ (p - 2) % 2 = 0 := by omega
      have h2 : ¬ (p + 2) % 2 = 0 := by omega
      simp only [h, h1, h2, if_false]
      rfl

/-- Column 1 of single-seed Rule 150. -/
def c (t : Nat) : Bool := run g150 t 1

theorem col_even (t : Nat) : c (2 * t) = false := by
  unfold c
  rw [double]
  simp

theorem col_odd (t : Nat) : c (2 * t + 1) = !c t := by
  unfold c
  have h0 : run g150 (2 * t) 0 = true := by rw [double]; simp [center150]
  have h1 : run g150 (2 * t) 1 = false := by rw [double]; simp
  have h2 : run g150 (2 * t) 2 = run g150 t 1 := by rw [double]; simp
  show xor (run g150 (2 * t) (1 - 1)) (g150 (run g150 (2 * t) 1) (run g150 (2 * t) (1 + 1))) = _
  rw [show (1 : Int) - 1 = 0 by norm_num, show (1 : Int) + 1 = 2 by norm_num, h0, h1, h2]
  cases run g150 t 1 <;> rfl

theorem c8_0 (m : Nat) : c (8 * m) = false := by
  rw [show 8 * m = 2 * (4 * m) by ring, col_even]
theorem c8_1 (m : Nat) : c (8 * m + 1) = true := by
  rw [show 8 * m + 1 = 2 * (4 * m) + 1 by ring, col_odd, show 4 * m = 2 * (2 * m) by ring,
    col_even]; rfl
theorem c8_2 (m : Nat) : c (8 * m + 2) = false := by
  rw [show 8 * m + 2 = 2 * (4 * m + 1) by ring, col_even]
theorem c8_3 (m : Nat) : c (8 * m + 3) = false := by
  rw [show 8 * m + 3 = 2 * (4 * m + 1) + 1 by ring, col_odd,
    show 4 * m + 1 = 2 * (2 * m) + 1 by ring, col_odd, show 2 * m = 2 * m by rfl, col_even]; rfl
theorem c8_4 (m : Nat) : c (8 * m + 4) = false := by
  rw [show 8 * m + 4 = 2 * (4 * m + 2) by ring, col_even]
theorem c8_5 (m : Nat) : c (8 * m + 5) = true := by
  rw [show 8 * m + 5 = 2 * (4 * m + 2) + 1 by ring, col_odd,
    show 4 * m + 2 = 2 * (2 * m + 1) by ring, col_even]; rfl
theorem c8_6 (m : Nat) : c (8 * m + 6) = false := by
  rw [show 8 * m + 6 = 2 * (4 * m + 3) by ring, col_even]
theorem c8_7 (m : Nat) : c (8 * m + 7) = !c m := by
  rw [show 8 * m + 7 = 2 * (4 * m + 3) + 1 by ring, col_odd,
    show 4 * m + 3 = 2 * (2 * m + 1) + 1 by ring, col_odd, col_odd]
  cases c m <;> rfl

/-- Lattice directions, heading 0 = east, turning left adds 1. -/
def dir : Fin 4 → Int × Int
  | 0 => (1, 0)
  | 1 => (0, 1)
  | 2 => (-1, 0)
  | 3 => (0, -1)

/-- One pen step: turn left on `true`, right on `false`, then move one unit. -/
def stepT (b : Bool) (s : Fin 4 × Int × Int) : Fin 4 × Int × Int :=
  let h : Fin 4 := if b then s.1 + 1 else s.1 + 3
  (h, s.2.1 + (dir h).1, s.2.2 + (dir h).2)

/-- The Rule 150 pen, started at the origin heading east. -/
def pen : Nat → Fin 4 × Int × Int
  | 0 => (0, 0, 0)
  | t + 1 => stepT (c t) (pen t)

/-- The first `j` steps of an 8-block, which do not depend on `c m` for `j ≤ 7`. -/
def pre : Nat → Fin 4 × Int × Int → Fin 4 × Int × Int
  | 0, s => s
  | j + 1, s => stepT ([false, true, false, false, false, true, false].getD j false) (pre j s)

/-- A whole 8-block, given `c m`. -/
def block (b : Bool) (s : Fin 4 × Int × Int) : Fin 4 × Int × Int := stepT (!b) (pre 7 s)

theorem pen_pre (m j : Nat) (hj : j < 8) : pen (8 * m + j) = pre j (pen (8 * m)) := by
  induction j with
  | zero => rfl
  | succ j ih =>
    have ih' := ih (by omega)
    show stepT (c (8 * m + j)) (pen (8 * m + j)) = _
    rw [ih']
    show _ = stepT ([false, true, false, false, false, true, false].getD j false) (pre j _)
    congr 1
    have hj7 : j < 7 := by omega
    interval_cases j
    · exact c8_0 m
    · exact c8_1 m
    · exact c8_2 m
    · exact c8_3 m
    · exact c8_4 m
    · exact c8_5 m
    · exact c8_6 m

theorem block8 (m : Nat) : pen (8 * m + 8) = block (c m) (pen (8 * m)) := by
  show stepT (c (8 * m + 7)) (pen (8 * m + 7)) = _
  rw [pen_pre m 7 (by norm_num), c8_7]
  rfl

/-- At every time `8m` the pen is at the origin heading east, or at (-2, 0) heading west. -/
theorem pen_at_8m : ∀ m : Nat, pen (8 * m) = (0, 0, 0) ∨ pen (8 * m) = (2, -2, 0)
  | 0 => Or.inl rfl
  | m + 1 => by
    rw [show 8 * (m + 1) = 8 * m + 8 by ring, block8]
    rcases pen_at_8m m with h | h <;> rw [h] <;> cases c m <;> decide

/-- The Rule 150 pen never leaves the box |x| ≤ 3, |y| ≤ 2. -/
theorem pen_confined (t : Nat) : |(pen t).2.1| ≤ 3 ∧ |(pen t).2.2| ≤ 2 := by
  have ht : t = 8 * (t / 8) + t % 8 := (Nat.div_add_mod t 8).symm
  have hj : t % 8 < 8 := Nat.mod_lt _ (by norm_num)
  rw [ht, pen_pre _ _ hj]
  generalize t % 8 = j at hj ⊢
  rcases pen_at_8m (t / 8) with h | h <;> rw [h] <;> interval_cases j <;> decide

end FVLT.S4sRule150PenV1

#print axioms FVLT.S4sRule150PenV1.double
#print axioms FVLT.S4sRule150PenV1.col_even
#print axioms FVLT.S4sRule150PenV1.col_odd
#print axioms FVLT.S4sRule150PenV1.block8
#print axioms FVLT.S4sRule150PenV1.pen_at_8m
#print axioms FVLT.S4sRule150PenV1.pen_confined
