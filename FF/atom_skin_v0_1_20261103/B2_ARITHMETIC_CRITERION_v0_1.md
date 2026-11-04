# FF-2 B2: arithmetic criterion draft v0.1

Status: proposed signature precision for review; no proof or build. This selects the arithmetic-relation route already allowed by the accepted work order. It introduces no group-action or continuous-orbifold claim.

The point type is Int × Int. Dimensions a b : Nat and hypotheses ha : 0 < a and hb : 0 < b are explicit binders on every theorem that requires them. Use explicit integer casts in all arithmetic definitions.

For i j : Int define

    translation a b i j (X,Y) = (X + 2*i*(a:Int), Y + 2*j*(b:Int))
    halfTurn a b i j (X,Y) = (2*i*(a:Int) - X, 2*j*(b:Int) - Y)

The orbit relation is exactly the disjunction in the work order: w = translation a b i j v or w = halfTurn a b i j v, for some i,j. It is not inferred from a viewer projection.

The intended fixing condition is

    HasFixingHalfTurn a b v := ∃ i j : Int, halfTurn a b i j v = v.

There is no need to omit i=j=0: the half-turn about the origin is a nonidentity transformation, even though its centre is zero. Conversely a translation with i=j=0 is the identity and must be excluded when asserting that nonidentity translations have no fixed point. Keeping these two notions separate is essential.

## Proposed theorem types

The following are Lean signature text only; the definitions named above and the corrected tagged key will be supplied in the reviewed full signature packet. They are not declarations of axioms in a Lean library.

```lean
-- Every map in the half-turn family really is nonidentity.
theorem halfTurn_not_identity
    (a b : ℕ) (i j : ℤ) :
    (∃ u : ℤ × ℤ, halfTurn a b i j u ≠ u)

-- State the exact arithmetic condition before classifying quotient classes.
theorem fixingHalfTurn_iff_multiples
    (a b : ℕ) (ha : 0 < a) (hb : 0 < b) (v : ℤ × ℤ) :
    HasFixingHalfTurn a b v ↔
      ∃ i j : ℤ, v = (i * (a : ℤ), j * (b : ℤ))

theorem nonzero_translation_fixes_nothing
    (a b : ℕ) (ha : 0 < a) (hb : 0 < b)
    (i j : ℤ) (hij : i ≠ 0 ∨ j ≠ 0) (v : ℤ × ℤ) :
    translation a b i j v ≠ v

-- 'corner' is the four-element Bool × Bool parameterization:
-- corner a b (u,v) = (if u then (a:ℤ) else 0,
--                     if v then (b:ℤ) else 0).
theorem fixingHalfTurn_iff_corner_class
    (a b : ℕ) (ha : 0 < a) (hb : 0 < b) (v : ℤ × ℤ) :
    HasFixingHalfTurn a b v ↔
      ∃ c : Bool × Bool, pillowRel a b v (corner a b c)

theorem four_corner_classes_distinct
    (a b : ℕ) (ha : 0 < a) (hb : 0 < b)
    (c d : Bool × Bool) :
    pillowRel a b (corner a b c) (corner a b d) ↔ c = d
```

The first lemma deliberately needs no positive-dimension hypothesis: a half-turn on the integer plane is nonidentity regardless of its centre. The subsequent theorem signatures keep the positive-dimension guards explicit. This is a signature proposal, not evidence that any lemma compiles.

B1 must independently prove the tagged key classifies this same relation, using positive dimensions, Int.emod and explicit casts. B2 can then be restated as equality of four tagged key classes if useful. Neither direction may be replaced by a bounded sample or by comparing the uncorrected seam-splitting net coordinates.
