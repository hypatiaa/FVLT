-- REVIEW TEXT ONLY. No Lean invocation or proof is supplied by this file.
import FVLTFareyArithmeticCompletionV1
import FVLTFordExactCoordinatesV1
import Mathlib.Data.Finset.Sort
import Mathlib.NumberTheory.Divisors
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic

open FVLT.FareyContactV1 FVLT.FordExactCoordinatesV1

namespace FVLT.PhasorFordV1

structure LiftedData where
  t1 : ℤ
  t2 : ℤ
  s : ℚ
  n3 : ℕ
  hn3 : 0 < n3
  r : ℝ
  hr : r ≠ 0

def fordAddress (t2 : ℤ) (s : ℚ) (n3 : ℕ) : ℚ := (t2 : ℚ) * s / (n3 : ℚ)

def phaseAddress (t1 t2 : ℤ) (s : ℚ) (n3 : ℕ) : ℚ :=
  (t1 : ℚ) * s - fordAddress t2 s n3

def IsIntegral (x : ℚ) : Prop := ∃ k : ℤ, x = (k : ℚ)

noncomputable def phasorValue (t1 t2 : ℤ) (s : ℚ) (n3 : ℕ) (r : ℝ) : ℂ :=
  (r : ℂ) * Complex.exp (((Real.pi * (phaseAddress t1 t2 s n3 : ℝ)) : ℂ) * Complex.I)

noncomputable def liftedPhasor (d : LiftedData) : ℂ :=
  phasorValue d.t1 d.t2 d.s d.n3 d.r

noncomputable def circleMap (d : LiftedData) : Set ℂ :=
  FVLT.FordGeometryV1.boundary (fordAddress d.t2 d.s d.n3)

def gcdFactor (a : ℤ) (q : ℕ) : ℕ := Nat.gcd a.natAbs q

def integerContactWindow (s : ℤ) (M : ℕ) : Finset ℕ :=
  (Finset.Icc 1 M).filter (fun N => (fordAddress 1 (s : ℚ) N).den = 1)

def divisorWindow (s M : ℕ) : Finset ℕ := s.divisors ∩ Finset.Icc 1 M

def fareySet (B : ℕ) : Finset ℚ :=
  (Finset.Icc 1 B).biUnion (fun q =>
    ((Finset.range (q + 1)).filter (fun m => Nat.Coprime m q)).image
      (fun (m : ℕ) => (m : ℚ) / (q : ℚ)))

def shellEvents (B : ℕ) : Finset (ℕ × ℚ) :=
  (Finset.Icc 2 (B + 1)).biUnion (fun N =>
    (Finset.range N).image (fun (m : ℕ) => (N, (m : ℚ) * (N : ℚ) / ((N : ℚ) - 1))))

def shellEventAddresses (B : ℕ) : Finset ℚ :=
  (shellEvents B).image (fun p => fordAddress 1 p.2 p.1)

def fareyList (B : ℕ) : List ℚ := (fareySet B).sort (· ≤ ·)

inductive EdgeKind where
  | tangent
  | stall
  | gap
  deriving DecidableEq

def IsBreak (x y : ℚ) : Prop := x ≠ y ∧ ¬fareyAdj x y ∧ 2 ≤ |det x y|

def classifyEdge (x y : ℚ) : EdgeKind :=
  if x = y then .stall else if |det x y| = 1 then .tangent else .gap

def pathEdgeKind (m : ℕ) (x : Fin (m + 1) → ℚ) (k : Fin m) : EdgeKind :=
  classifyEdge (x k.castSucc) (x k.succ)

def endpointCertificate (m : ℕ) (x : Fin (m + 1) → ℚ) (k : Fin m) : Option RatPlane :=
  if |det (x k.castSucc) (x k.succ)| = 1
  then some (kissQ (x k.castSucc) (x k.succ)) else none

end FVLT.PhasorFordV1
