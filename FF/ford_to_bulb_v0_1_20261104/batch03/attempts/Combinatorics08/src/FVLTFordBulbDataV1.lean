import FVLTFareyArithmeticCompletionV1
import Mathlib.Data.Finset.Sort
import Mathlib.Data.Rat.Lemmas
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.RingTheory.RootsOfUnity.Complex

open scoped BigOperators

namespace FVLT.FordBulbV1

structure RotationAddress where
  p : ℕ
  q : ℕ
  p_pos : 0 < p
  p_lt_q : p < q
  coprime : Nat.Coprime p q

def address (d : RotationAddress) : ℚ := (d.p : ℚ) / (d.q : ℚ)

def modulus (d : RotationAddress) : ℕ := 2 ^ d.q - 1

def upperIndex (d : RotationAddress) : Fin d.q := ⟨d.p, d.p_lt_q⟩

def lowerIndex (d : RotationAddress) : Fin d.q :=
  ⟨d.p - 1, lt_of_le_of_lt (Nat.sub_le d.p 1) d.p_lt_q⟩

def rawDigit (p q u i : ℕ) : ℕ := if q - p ≤ (u + i * p) % q then 1 else 0

def blockValue (p q u n : ℕ) : ℕ :=
  ∑ i ∈ Finset.range n, rawDigit p q u i * 2 ^ (n - 1 - i)

def digit (d : RotationAddress) (u i : Fin d.q) : ℕ :=
  rawDigit d.p d.q u.val i.val

def wordValue (d : RotationAddress) (u : Fin d.q) : ℕ :=
  blockValue d.p d.q u.val d.q

def upperDigit (d : RotationAddress) (i : Fin d.q) : ℕ := digit d (upperIndex d) i

def lowerDigit (d : RotationAddress) (i : Fin d.q) : ℕ := digit d (lowerIndex d) i

def upperNumerator (d : RotationAddress) : ℕ := wordValue d (upperIndex d)

def lowerNumerator (d : RotationAddress) : ℕ := wordValue d (lowerIndex d)

def upperAngle (d : RotationAddress) : ℚ := (upperNumerator d : ℚ) / (modulus d : ℚ)

def lowerAngle (d : RotationAddress) : ℚ := (lowerNumerator d : ℚ) / (modulus d : ℚ)

def psi (d : RotationAddress) : ℚ × ℚ := (lowerAngle d, upperAngle d)

def angleInterval (d : RotationAddress) : Set ℚ := Set.Icc (lowerAngle d) (upperAngle d)

def doubleNum (d : RotationAddress) (n : ℕ) : ℕ := (2 * n) % modulus d

def iterateNum (d : RotationAddress) (n i : ℕ) : ℕ := (2 ^ i * n) % modulus d

def orbitPoint (d : RotationAddress) (i : ℕ) : ℕ := iterateNum d (upperNumerator d) i

def orbitSet (d : RotationAddress) : Finset ℕ :=
  (Finset.range d.q).image (orbitPoint d)

def rank (d : RotationAddress) (n : ℕ) : ℕ := ((orbitSet d).filter (fun x => x < n)).card

def orderedOrbit (d : RotationAddress) : List ℕ := (orbitSet d).sort (· ≤ ·)

def edgeStart (d : RotationAddress) (i : Fin (orderedOrbit d).length) : ℕ :=
  (orderedOrbit d).get i

def edgeEnd (d : RotationAddress) (i : Fin (orderedOrbit d).length) : ℕ :=
  if h : i.val + 1 < (orderedOrbit d).length then
    (orderedOrbit d).get ⟨i.val + 1, h⟩
  else (orderedOrbit d).get ⟨0, lt_of_le_of_lt (Nat.zero_le i.val) i.isLt⟩

def directedGap (d : RotationAddress) (i : Fin (orderedOrbit d).length) : ℕ :=
  if i.val + 1 < (orderedOrbit d).length then edgeEnd d i - edgeStart d i
  else modulus d + edgeEnd d i - edgeStart d i

noncomputable def cardioidParameter (lambda : ℂ) : ℂ := lambda / 2 - lambda ^ 2 / 4

noncomputable def alpha (lambda : ℂ) : ℂ := lambda / 2

noncomputable def quadratic (c z : ℂ) : ℂ := z ^ 2 + c

noncomputable def quadraticMultiplier (z : ℂ) : ℂ := 2 * z

noncomputable def canonicalMultiplier (d : RotationAddress) : ℂ :=
  Complex.exp (((2 * Real.pi * (address d : ℝ)) : ℂ) * Complex.I)

end FVLT.FordBulbV1
