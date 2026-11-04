# FF-2 Part A signature design v0.1

Status: preparation for the full explicit-binder signature freeze. No proof or build. These are the exact intended propositions and data choices; the final packet must supply and pin the actual Lean definitions and inspect/elaborate the API usage before it is called frozen. This document alone is not the accepted signature freeze.

Every result below has explicit binders `(ω : ℕ) (hω : 3 ≤ ω)`. No fixed maximum ω, selected prime list, or finite test range is a mathematical hypothesis. Cyclic order is the declared ascending Fin ω order, not an unspecified permutation of prime factors.

## Data to freeze

- `Vertex ω := Finset (Fin ω)`.
- `next ω hω i` is the Fin ω element with value `(i.val + 1) % ω`; the proof of its bound comes from hω. `prev` uses `(i.val + ω - 1) % ω`. No hidden NeZero assumption.
- `Edge ω := {vb : Vertex ω × Fin ω // vb.2 ∉ vb.1}`. Endpoints are v and insert d v.
- `Square ω hω := {vi : Vertex ω × Fin ω // vi.2 ∉ vi.1 ∧ next ω hω vi.2 ∉ vi.1}`. Its four-corner finite set uses v, insert i v, insert j v and insert i (insert j v), with j = next i. Do not quotient away or double-count the declared cyclic pair.
- `epsilon ω v : ℤ := (-1) ^ v.card`.
- `C1 ω := Edge ω →₀ ℤ`. The oriented boundary is the sum of four Finsupp.single terms in exactly the order/signs of the work order. Edge subtype witnesses are proof data, not additional mathematical hypotheses. `edgeCoefficient f e` is evaluation of this boundary at e.
- `toggle v d := v.symmDiff {d}`. `cubeAdjacent x y := ∃ d, y = toggle x d`.
- `linkAdjacent x i j` means i ≠ j and some square contains x, toggle x i, and toggle x j among its corners. Define this from actual square incidence, not by defining it to be cycle adjacency.
- `State ω := Vertex ω × Fin ω`. Sign is a two-element inductive type with integer interpretation +1 or -1; it is not an arbitrary integer with an implicit admissibility condition. `step` takes the direction `(b.val - sign*sigma) mod ω` using integer arithmetic and Int.emod, with sigma = epsilon w, then toggles that direction and stores it as the new back direction. In the final expression all casts and positivity witnesses must be explicit.
- `directedEdgeCoefficient x y e` is +1 if x is the lower endpoint and y the upper endpoint of e, -1 in the reverse direction, and 0 otherwise. Its full finite-case definition must be frozen before any orientation proof.

## A1: counts and signed Euler characteristic

Freeze separate theorem signatures, each with `(ω : ℕ) (hω : 3 ≤ ω)`:

    Fintype.card (Vertex ω) = 2 ^ ω
    Fintype.card (Edge ω) = ω * 2 ^ (ω - 1)
    Fintype.card (Square ω hω) = ω * 2 ^ (ω - 2)

Define chi from the three actual cardinalities, cast individually to ℤ. Prove

    chi ω hω = (2 : ℤ) ^ (ω - 2) * (4 - (ω : ℤ)).

This must not define chi by the right-hand formula and then prove a reflexive identity.

## A2: exactly two incident squares

For every `(e : Edge ω)`:

    Fintype.card {f : Square ω hω // edgeCoefficient ω hω f e ≠ 0} = 2.

Also explicitly identify their cyclic directions as prev e.direction and e.direction, with their base vertices obtained by removing both seat directions from an endpoint. The final signature packet must give those two constructors and state distinctness and exhaustive membership. A count alone is weaker than the work order's identified pair.

## A3: canonical link-cycle correspondence

For every `(x : Vertex ω)` and `(i j : Fin ω)`:

    linkAdjacent ω hω x i j ↔
      j = next ω hω i ∨ i = next ω hω j.

Together with the explicit identification of each incident edge with its unique direction, this is the labelled graph isomorphism to C_ω. Include the incident-edge/direction bijection in the final packet; do not rely on a descriptive caption for the bijection.

## A4: orientation certificate

For each e and each distinct pair f,g of incident squares, with incident/nonzero hypotheses as explicit binders:

    edgeCoefficient ω hω f e = -edgeCoefficient ω hω g e.

Then prove in C1 ω:

    (∑ f : Square ω hω, boundary ω hω f) = 0.

Boundary is the concrete four-term Finsupp definition. No topological realization or surface classification is inferred from this equation.

## A5: full-cube connectedness

First state the exact correspondence between the representative edges and cubeAdjacent. Then for every `(x y : Vertex ω)` prove:

    ∃ n : ℕ, ∃ v : ℕ → Vertex ω,
      v 0 = x ∧ v n = y ∧
      ∀ k : ℕ, k < n → cubeAdjacent ω (v k) (v (k + 1)).

The finite prefix is a path witness; its unrestricted tail carries no condition and is irrelevant. The result must refer to the same representative-edge graph as A2–A4.

## A6: numerical genus invariant

Define `genus ω hω : ℤ := 1 - chi ω hω / 2`, using integer division and the A1 cardinality-derived chi. Prove:

    Even (chi ω hω)
    genus ω hω = 1 + ((ω : ℤ) - 4) * (2 : ℤ) ^ (ω - 3)

Record the ω=3 evaluation as zero with an explicitly supplied proof of 3≤3, without taking Nat subtraction of ω−4. This is a numerical invariant, not a genus theorem about a realization.

## A7: pen incidence and orientation

For every state `(st : State ω)` and `(s : Sign)`, let w = st.1, b = st.2, and d = (step ω hω s st).2. Prove d is next b or prev b and d≠b. Prove that some square f has both the incoming edge toggle w b → w and the outgoing edge w → toggle w d. On each of these two directed edges prove its directed coefficient equals sign(s) times f's oriented boundary coefficient.

This same coefficient factor on both edges is what states that s=+1 follows the oriented boundary and s=-1 follows the reverse orientation. Merely sharing a square is insufficient. The incident representative edges and nonzero coefficients must be explicit in the final signatures.

## A8: least full-state return and exact corners

For every state st and sign s:

    (step ω hω s)^[4] st = st

For every `(k : ℕ) (hk0 : 0 < k) (hk4 : k < 4)`:

    (step ω hω s)^[k] st ≠ st.

And for some actual square f:

    (Finset.range 4).image (fun k => ((step ω hω s)^[k] st).1)
      = squareCorners ω hω f.

State return includes the back direction; vertex return alone is not an acceptable substitution. No claim about a variable-sign stream's period follows.

## Completion condition

The full signature freeze must convert every item above into actual Lean declaration headers and full data definitions, enumerate any auxiliary bridge theorems, and pair them to the work-order rows. Any alteration to these propositions is reviewable, not silently folded into proof development. B1/B2 and their tagged-key definitions must be in the same complete review packet or an explicitly accepted separately staged freeze.
