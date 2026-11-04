import Mathlib

namespace FVLT.PillowcaseV1

abbrev Point := ℤ × ℤ

def translation (a b : ℕ) (i j : ℤ) (v : Point) : Point :=
  (v.1 + 2 * i * (a : ℤ), v.2 + 2 * j * (b : ℤ))

def halfTurn (a b : ℕ) (i j : ℤ) (v : Point) : Point :=
  (2 * i * (a : ℤ) - v.1, 2 * j * (b : ℤ) - v.2)

def pillowRel (a b : ℕ) (v w : Point) : Prop :=
  ∃ i j : ℤ, w = translation a b i j v ∨ w = halfTurn a b i j v

def net (a b : ℕ) (v : Point) : ℕ × ℕ :=
  let x := (v.1 % (2 * (a : ℤ))).toNat
  let y := (v.2 % (2 * (b : ℤ))).toNat
  if b < y then ((2 * a - x) % (2 * a), 2 * b - y) else (x, y)

inductive PillowKey where
  | boundary (r y : ℕ)
  | front (r y : ℕ)
  | back (r y : ℕ)
  deriving DecidableEq

def key (a b : ℕ) (v : Point) : PillowKey :=
  let p := net a b v
  let r := if p.1 ≤ a then p.1 else 2 * a - p.1
  if r = 0 ∨ r = a ∨ p.2 = 0 ∨ p.2 = b then .boundary r p.2
  else if p.1 < a then .front r p.2 else .back r p.2

def HasFixingHalfTurn (a b : ℕ) (v : Point) : Prop :=
  ∃ i j : ℤ, halfTurn a b i j v = v

def corner (a b : ℕ) (c : Bool × Bool) : Point :=
  (if c.1 then (a : ℤ) else 0, if c.2 then (b : ℤ) else 0)

end FVLT.PillowcaseV1
