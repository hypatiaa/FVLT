-- Proposed exact definition bytes, not an executable proof file.
-- Skeleton review precedes any Lean invocation. No target proof is present.
import Mathlib
open scoped BigOperators

namespace FVLT.AtomSkinV1

abbrev Vertex (ω : ℕ) := Finset (Fin ω)
abbrev Edge (ω : ℕ) := {p : Vertex ω × Fin ω // p.2 ∉ p.1}

def cyclicDir (ω : ℕ) (hω : 3 ≤ ω) (z : ℤ) : Fin ω :=
  letI : NeZero ω := ⟨by omega⟩
  Fin.ofNat ω (z % (ω : ℤ)).toNat

def next (ω : ℕ) (hω : 3 ≤ ω) (i : Fin ω) : Fin ω :=
  cyclicDir ω hω ((i.val : ℤ) + 1)

def prev (ω : ℕ) (hω : 3 ≤ ω) (i : Fin ω) : Fin ω :=
  cyclicDir ω hω ((i.val : ℤ) - 1)

abbrev Square (ω : ℕ) (hω : 3 ≤ ω) :=
  {p : Vertex ω × Fin ω // p.2 ∉ p.1 ∧ next ω hω p.2 ∉ p.1}

def mkEdge (ω : ℕ) (v : Vertex ω) (d : Fin ω) : Edge ω :=
  ⟨(v.erase d, d), by simp⟩

def lower (ω : ℕ) (e : Edge ω) : Vertex ω := e.val.1
def upper (ω : ℕ) (e : Edge ω) : Vertex ω := insert e.val.2 e.val.1

def toggle (ω : ℕ) (v : Vertex ω) (d : Fin ω) : Vertex ω :=
  if d ∈ v then v.erase d else insert d v

def epsilon (ω : ℕ) (v : Vertex ω) : ℤ := (-1) ^ v.card

def squareAt (ω : ℕ) (hω : 3 ≤ ω) (x : Vertex ω) (i : Fin ω) :
    Square ω hω :=
  ⟨((x.erase i).erase (next ω hω i), i), by simp⟩

def corners (ω : ℕ) (hω : 3 ≤ ω) (f : Square ω hω) :
    Finset (Vertex ω) :=
  let v := f.val.1
  let i := f.val.2
  let j := next ω hω i
  {v, insert i v, insert j v, insert i (insert j v)}

abbrev Chain1 (ω : ℕ) := Edge ω →₀ ℤ

def boundary (ω : ℕ) (hω : 3 ≤ ω) (f : Square ω hω) : Chain1 ω :=
  let v := f.val.1
  let i := f.val.2
  let j := next ω hω i
  Finsupp.single (mkEdge ω v i) (epsilon ω v) +
    Finsupp.single (mkEdge ω (insert i v) j) (epsilon ω v) -
    Finsupp.single (mkEdge ω (insert j v) i) (epsilon ω v) -
    Finsupp.single (mkEdge ω v j) (epsilon ω v)

def coefficient (ω : ℕ) (hω : 3 ≤ ω) (f : Square ω hω) (e : Edge ω) : ℤ :=
  boundary ω hω f e

def edgeIncident (ω : ℕ) (e : Edge ω) (x : Vertex ω) : Prop :=
  x = lower ω e ∨ x = upper ω e

def cubeAdjacent (ω : ℕ) (x y : Vertex ω) : Prop :=
  ∃ d : Fin ω, y = toggle ω x d

def linkAdjacent (ω : ℕ) (hω : 3 ≤ ω) (x : Vertex ω) (i j : Fin ω) : Prop :=
  i ≠ j ∧ ∃ f : Square ω hω,
    x ∈ corners ω hω f ∧
    toggle ω x i ∈ corners ω hω f ∧
    toggle ω x j ∈ corners ω hω f

def chi (ω : ℕ) (hω : 3 ≤ ω) : ℤ :=
  (Fintype.card (Vertex ω) : ℤ) - (Fintype.card (Edge ω) : ℤ) +
    (Fintype.card (Square ω hω) : ℤ)

def genus (ω : ℕ) (hω : 3 ≤ ω) : ℤ := 1 - chi ω hω / 2

inductive Sign where
  | positive
  | negative
  deriving DecidableEq, Fintype

def signValue (s : Sign) : ℤ :=
  match s with
  | .positive => 1
  | .negative => -1

abbrev State (ω : ℕ) := Vertex ω × Fin ω

def step (ω : ℕ) (hω : 3 ≤ ω) (s : Sign) (st : State ω) : State ω :=
  let d := cyclicDir ω hω ((st.2.val : ℤ) - signValue s * epsilon ω st.1)
  (toggle ω st.1 d, d)

def directedCoefficient (ω : ℕ) (x y : Vertex ω) (e : Edge ω) : ℤ :=
  if x = lower ω e ∧ y = upper ω e then 1
  else if x = upper ω e ∧ y = lower ω e then -1 else 0

end FVLT.AtomSkinV1

