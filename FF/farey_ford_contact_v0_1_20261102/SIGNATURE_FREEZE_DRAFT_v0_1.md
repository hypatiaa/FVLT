# FF-1 Stage A signature freeze draft v0.1

2026-11-03. **AWAITING REVIEW. No proofs written or run.** Applies only to the exact v0.3 order and its E1 erratum. These are proposed Lean declaration headers and mathematical definitions, not an executable Lean source file. No omitted body is an axiom or a proof placeholder in a compiled environment. Parsing/elaboration has not been attempted. A change to any stated proposition, binder, domain, definition or graph semantics returns for review; implementation-only API spelling fixes must be recorded and checked not to change the proposition.

Modules: `FVLTFareyContactV1.lean` (namespace `FVLT.FareyContactV1`) and `FVLTFordGeometryV1.lean` (namespace `FVLT.FordGeometryV1`). Only standard Mathlib dependencies are planned; neither Rule 30 project imports nor G1 imports are needed. Geometry imports the arithmetic module. Every hypothesis, including positivity and typeclass assumptions, is an explicit binder. A binder may be unused in a helper proof without being removed from its statement.

## Definitions to freeze

In `FVLT.FareyContactV1`:

```lean
def rawValue (a : ℤ) (q : ℕ) : ℚ := (a : ℚ) / (q : ℚ)
def det (x y : ℚ) : ℤ := x.num * (y.den : ℤ) - y.num * (x.den : ℤ)
def fareyAdj (x y : ℚ) : Prop := |det x y| = 1
def mediant (x y : ℚ) : ℚ :=
  rawValue (x.num + y.num) (x.den + y.den)
def unitFrac (a : ℕ) : ℚ := 1 / (a : ℚ)
def admissible (α : List ℕ) : Finset ℕ :=
  α.toFinset.biUnion (fun a => (a + 1).divisors.filter (fun q => 2 ≤ q))
def phases (α : List ℕ) : Finset ℚ :=
  (admissible α).biUnion (fun q =>
    ((Finset.Icc 1 (q - 1)).filter (fun c => Nat.Coprime c q)).image
      (fun c => (c : ℚ) / (q : ℚ)))
def unreducedPhases (α : List ℕ) : Finset ℚ :=
  α.toFinset.biUnion (fun a => (Finset.Icc 1 a).image
    (fun e => (e : ℚ) / ((a + 1 : ℕ) : ℚ)))
def vertexSet (V : Finset ℕ) : Finset ℚ := V.image unitFrac
def integerPath : SimpleGraph ℕ
def fareyGraph (S : Finset ℚ) : SimpleGraph {x : ℚ // x ∈ S}
def phaseGraph (α : List ℕ) := fareyGraph (phases α)
def contactCount (S : Finset ℚ) : ℕ :=
  ((S.product S).filter (fun xy => xy.1 < xy.2 ∧ fareyAdj xy.1 xy.2)).card
def isolated (S : Finset ℚ) (x : ℚ) : Prop :=
  x ∈ S ∧ ∀ y ∈ S, ¬ fareyAdj x y
def singletonPartition (S I : Finset ℚ) : Finset (Finset ℚ) :=
  I.image (fun x => {x}) ∪ {S \ I}
```

`integerPath` has adjacency `| (a : ℤ) - (b : ℤ) | = 1`. `fareyGraph S` has adjacency exactly `fareyAdj x.val y.val`, without an extra hidden domain or coprimality test. Symmetry/looplessness are supplied from A1. Use Mathlib's `SimpleGraph` constructor, not a new graph model. Noncomputable/classical instances needed for definitions must not substitute a different finite graph. `contactCount` counts each unordered edge once by rational order; the bridge below identifies it with Mathlib's edge-set cardinality.

In `FVLT.FordGeometryV1`, with the arithmetic namespace open:

```lean
def radius (x : ℚ) : ℝ := 1 / (2 * (x.den : ℝ)^2)
def centre (x : ℚ) : ℂ := (x : ℂ) + (radius x : ℂ) * Complex.I
def disk (x : ℚ) : Set ℂ := {z | ‖z - centre x‖ < radius x}
def boundary (x : ℚ) : Set ℂ := {z | ‖z - centre x‖ = radius x}
def realAxis : Set ℂ := {z | z.im = 0}
def tangent (x y : ℚ) : Prop :=
  x ≠ y ∧ ∃ z : ℂ, boundary x ∩ boundary y = {z}
def kissN (x y : ℚ) : ℤ := x.num * (x.den : ℤ) + y.num * (y.den : ℤ)
def kissM (x y : ℚ) : ℕ := x.den^2 + y.den^2
def kiss (x y : ℚ) : ℂ :=
  ((kissN x y : ℂ) + Complex.I) / (kissM x y : ℂ)
```

## A1 — raw arithmetic, canonical bridges, adjacency

Each displayed header is a separate target unless explicitly stated otherwise.

```lean
theorem raw_det_one_coprime (a c : ℤ) (q s : ℕ)
  (hq : 0 < q) (hs : 0 < s)
  (hdet : |a * (s : ℤ) - c * (q : ℤ)| = 1) :
  Nat.Coprime a.natAbs q ∧ Nat.Coprime c.natAbs s ∧ Nat.Coprime q s

theorem rawValue_num_den (x : ℚ) : rawValue x.num x.den = x
theorem rawValue_canonical (a : ℤ) (q : ℕ) (hq : 0 < q)
  (hred : Nat.Coprime a.natAbs q) :
  (rawValue a q).num = a ∧ (rawValue a q).den = q
theorem rawValue_unique (a c : ℤ) (q s : ℕ)
  (hq : 0 < q) (hs : 0 < s)
  (ha : Nat.Coprime a.natAbs q) (hc : Nat.Coprime c.natAbs s) :
  rawValue a q = rawValue c s ↔ a = c ∧ q = s
theorem fareyAdj_symm (x y : ℚ) : fareyAdj x y ↔ fareyAdj y x
theorem fareyAdj_irrefl (x : ℚ) : ¬ fareyAdj x x
theorem fareyGraph_adj (S : Finset ℚ) (x y : {x : ℚ // x ∈ S}) :
  (fareyGraph S).Adj x y ↔ fareyAdj x.val y.val
theorem coprime_den_not_adj :
  Nat.Coprime (unitFrac 3).den (unitFrac 5).den ∧
  ¬ fareyAdj (unitFrac 3) (unitFrac 5) ∧
  |det (unitFrac 3) (unitFrac 5)| = 2
```

## A2 — mediants and the rosette

```lean
theorem adjacent_mediant (x y : ℚ) (hxy : x < y) (h : fareyAdj x y) :
  Nat.Coprime (x.num + y.num).natAbs (x.den + y.den) ∧
  (mediant x y).num = x.num + y.num ∧
  (mediant x y).den = x.den + y.den ∧
  x < mediant x y ∧ mediant x y < y ∧
  fareyAdj x (mediant x y) ∧ fareyAdj (mediant x y) y
theorem rosette (N : ℕ) (hN : 2 ≤ N) :
  |det (unitFrac (N - 1)) (unitFrac (N + 1))| = 2 ∧
  mediant (unitFrac (N - 1)) (unitFrac (N + 1)) = unitFrac N ∧
  fareyAdj (unitFrac N) (unitFrac (N - 1)) ∧
  fareyAdj (unitFrac N) (unitFrac (N + 1))
```

## A3–A4 — geometry and kiss uniqueness

```lean
theorem radius_pos (x : ℚ) : 0 < radius x
theorem ford_distance_identity (x y : ℚ) (hne : x ≠ y) :
  ‖centre x - centre y‖^2 - (radius x + radius y)^2 =
    (((det x y : ℤ) : ℝ)^2 - 1) /
      ((x.den : ℝ)^2 * (y.den : ℝ)^2)
theorem ford_open_disjoint (x y : ℚ) (hne : x ≠ y) : Disjoint (disk x) (disk y)
theorem ford_boundary_disjoint (x y : ℚ) (hne : x ≠ y)
  (hsep : 2 ≤ |det x y|) : Disjoint (boundary x) (boundary y)
theorem ford_tangent_iff (x y : ℚ) (hne : x ≠ y) : tangent x y ↔ fareyAdj x y
theorem ford_real_axis (x : ℚ) : boundary x ∩ realAxis = {(x : ℂ)}
theorem kiss_membership (x y : ℚ) (h : fareyAdj x y) :
  kiss x y ∈ boundary x ∧ kiss x y ∈ boundary y
theorem kiss_unique (x y : ℚ) (h : fareyAdj x y) :
  boundary x ∩ boundary y = {kiss x y}
theorem two_squares (a c : ℤ) (q s : ℤ) :
  (a*q + c*s)^2 + (a*s - c*q)^2 = (a^2 + c^2)*(q^2 + s^2)
theorem kiss_integer_identity (x y : ℚ) (h : fareyAdj x y) :
  (kissN x y)^2 + 1 = (x.num^2 + y.num^2) * (kissM x y : ℤ)
theorem kiss_real_identity (x y : ℚ) (h : fareyAdj x y) :
  (kissN x y : ℝ)^2 + 1 =
    ((x.num : ℝ)^2 + (y.num : ℝ)^2) * (kissM x y : ℝ)
```

F1 tests only `ford_distance_identity` and `kiss_membership` (including any supporting definitions/identities), not `kiss_unique` or the other geometry goals. Feasibility proofs do not imply full A3/A4 acceptance.

## A5 — unit-fraction graph

```lean
theorem unitFrac_injective_positive (a b : ℕ) (ha : 0 < a) (hb : 0 < b) :
  unitFrac a = unitFrac b ↔ a = b
theorem integerPath_adj (a b : ℕ) :
  integerPath.Adj a b ↔ |(a : ℤ) - (b : ℤ)| = 1
theorem unitFrac_adj (a b : ℕ) (ha : 0 < a) (hb : 0 < b) :
  fareyAdj (unitFrac a) (unitFrac b) ↔ |(a : ℤ) - (b : ℤ)| = 1
theorem unitFrac_tangent (a b : ℕ) (ha : 0 < a) (hb : 0 < b) :
  tangent (unitFrac a) (unitFrac b) ↔ |(a : ℤ) - (b : ℤ)| = 1
theorem unitFrac_graph_iso (V : Finset ℕ) (hV : ∀ a ∈ V, 0 < a) :
  Nonempty ((integerPath.induce (V : Set ℕ)) ≃g fareyGraph (vertexSet V))
theorem unitFrac_graph_connected (V : Finset ℕ) (hne : V.Nonempty)
  (hV : ∀ a ∈ V, 0 < a) :
  (fareyGraph (vertexSet V)).Connected ↔
    ∃ m M : ℕ, 1 ≤ m ∧ m ≤ M ∧ V = Finset.Icc m M
theorem empty_graph_convention :
  (fareyGraph ∅).Preconnected ∧ ¬ (fareyGraph ∅).Connected
theorem gap_det (a k : ℕ) (ha : 0 < a) (hk : 0 < k) :
  |det (unitFrac a) (unitFrac (a + k))| = (k : ℤ)
theorem minimal_gap_mediant (a : ℕ) (ha : 0 < a) :
  mediant (unitFrac a) (unitFrac (a + 2)) = unitFrac (a + 1)
theorem gap_mediant_unit_iff (a k : ℕ) (ha : 0 < a) (hk : 2 < k) :
  (∃ b : ℕ, 0 < b ∧
    mediant (unitFrac a) (unitFrac (a + k)) = unitFrac b) ↔ Even k
```

Placement: graph/determinant claims are arithmetic; `unitFrac_tangent` is in geometry. The claimed graph isomorphism may later be supplied as an explicit equivalence with adjacency preserved if API elaboration demands it; changing the mathematical assertion still returns for review.

II.5f anchoring, complete insertion repair, strict-staircase classification and canonical primorial representative are deliberately omitted. This batch formalizes the scoped (i)/(iii) targets, not every clause of II.5f. No interpretation or profile-to-prime-label action is inferred.

## A6 — interior profile phases

All `α` binders below have `hα : ∀ a ∈ α, 0 < a` explicitly, including where the result also holds on a larger domain. To avoid repeating whole headers, the prefix in each line is written out.

```lean
theorem phases_eq_unreduced (α : List ℕ) (hα : ∀ a ∈ α, 0 < a) :
  phases α = unreducedPhases α
theorem phase_domain (α : List ℕ) (hα : ∀ a ∈ α, 0 < a)
  (x : ℚ) (hx : x ∈ phases α) :
  0 < x ∧ x < 1 ∧ 2 ≤ x.den ∧ x.den ∈ admissible α
theorem denominator_partner (α : List ℕ) (hα : ∀ a ∈ α, 0 < a)
  (x : ℚ) (hx : x ∈ phases α) (s : ℕ) (hs : s ∈ admissible α)
  (c : ℤ) :
  (rawValue c s ∈ phases α ∧ (rawValue c s).den = s ∧
    (rawValue c s).num = c ∧ fareyAdj x (rawValue c s)) ↔
  (1 ≤ c ∧ c ≤ (s : ℤ) - 1 ∧
    ∃ ε : ℤ, (ε = -1 ∨ ε = 1) ∧ x.num*(s : ℤ) - c*(x.den : ℤ) = ε)
theorem partner_congruence (α : List ℕ) (hα : ∀ a ∈ α, 0 < a)
  (x : ℚ) (hx : x ∈ phases α) (s : ℕ) (hs : s ∈ admissible α) :
  (∃ y ∈ phases α, y.den = s ∧ fareyAdj x y) ↔
  ∃ ε : ℤ, (ε = -1 ∨ ε = 1) ∧
    Int.ModEq (x.den : ℤ) (x.num*(s : ℤ)) ε ∧
    1 ≤ (x.num*(s : ℤ) - ε) / (x.den : ℤ) ∧
    (x.num*(s : ℤ) - ε) / (x.den : ℤ) ≤ (s : ℤ) - 1
theorem cross_denominator (α : List ℕ) (hα : ∀ a ∈ α, 0 < a)
  (x y : ℚ) (hx : x ∈ phases α) (hy : y ∈ phases α)
  (h : fareyAdj x y) : x.den ≠ y.den
theorem isolation_criterion (α : List ℕ) (hα : ∀ a ∈ α, 0 < a)
  (x : ℚ) (hx : x ∈ phases α) :
  isolated (phases α) x ↔
    ¬ ∃ s ∈ admissible α, ∃ c ε : ℤ,
      (ε = -1 ∨ ε = 1) ∧ 1 ≤ c ∧ c ≤ (s : ℤ) - 1 ∧
      x.num*(s : ℤ) - c*(x.den : ℤ) = ε
theorem endpoint_isolation (α : List ℕ) (hα : ∀ a ∈ α, 0 < a)
  (n : ℕ) (hn : n ∈ admissible α) :
  isolated (phases α) (unitFrac n) ↔
    ¬ ∃ s ∈ admissible α, ∃ ε : ℤ,
      (ε = -1 ∨ ε = 1) ∧ Int.ModEq (n : ℤ) (s : ℤ) ε ∧
      1 ≤ ((s : ℤ) - ε)/(n : ℤ) ∧
      ((s : ℤ) - ε)/(n : ℤ) ≤ (s : ℤ) - 1
theorem complement_mem (α : List ℕ) (hα : ∀ a ∈ α, 0 < a)
  (x : ℚ) : x ∈ phases α ↔ 1 - x ∈ phases α
theorem complement_adj (x y : ℚ) (hx : 0 < x ∧ x < 1)
  (hy : 0 < y ∧ y < 1) : fareyAdj (1-x) (1-y) ↔ fareyAdj x y
theorem complement_graph_auto (α : List ℕ) (hα : ∀ a ∈ α, 0 < a) :
  ∃ e : phaseGraph α ≃g phaseGraph α,
    ∀ x : {x : ℚ // x ∈ phases α}, (e x).val = 1 - x.val
theorem isolated_complement_pairs (α : List ℕ) (hα : ∀ a ∈ α, 0 < a)
  (x : ℚ) (hx : x ∈ phases α) :
  (isolated (phases α) x ↔ isolated (phases α) (1-x)) ∧
    (1-x = x ↔ x = (1/2 : ℚ))
```

Congruence statements retain the induced-numerator range. The integer division notation in those statements means Euclidean division of a divisible integer; the congruence guarantees divisibility and positive denominator follows from membership. No congruence-only surrogate is substituted.

## A7 — certificate semantics and finite targets

For any type `V` with explicit `[DecidableEq V]`, graph `G : SimpleGraph V`, and `parts : Finset (Finset V)`, define `ComponentCertificate G parts : Prop` as the conjunction of:

1. `∀ s ∈ parts, s.Nonempty`;
2. `∀ v : V, ∃ s ∈ parts, v ∈ s`;
3. `∀ s ∈ parts, ∀ t ∈ parts, s ≠ t → Disjoint s t`;
4. `∀ s ∈ parts, (G.induce (s : Set V)).Connected`;
5. `∀ s ∈ parts, ∀ t ∈ parts, s ≠ t → ∀ u ∈ s, ∀ v ∈ t, ¬ G.Adj u v`.

This is a certificate of actual Mathlib graph components. For bounded checking, use the following frozen parent/depth soundness target. Its hypotheses on each concrete part can be checked by `decide` with explicit root, parent and depth tables. `decide` is intended for those bounded witness/arithmetic checks, not arbitrary existential walks. No search for arbitrary paths is silently imported.

```lean
theorem spanning_tree_connected (V : Type*) [DecidableEq V]
  (G : SimpleGraph V) (s : Finset V) (r : V)
  (parent : V → V) (depth : V → ℕ) (hr : r ∈ s)
  (hparent : ∀ v ∈ s, v ≠ r →
    parent v ∈ s ∧ G.Adj v (parent v) ∧ depth (parent v) < depth v) :
  (G.induce (s : Set V)).Connected
theorem certificate_component_bijection (V : Type*) [DecidableEq V]
  (G : SimpleGraph V) (parts : Finset (Finset V))
  (h : ComponentCertificate G parts) :
  ∃ e : {s : Finset V // s ∈ parts} ≃ G.ConnectedComponent,
    ∀ s : {s : Finset V // s ∈ parts}, ∀ v ∈ s.val,
      e s = G.connectedComponentMk v
theorem certificate_component_count (V : Type*) [DecidableEq V]
  (G : SimpleGraph V) (parts : Finset (Finset V))
  (h : ComponentCertificate G parts) :
  Nat.card G.ConnectedComponent = parts.card
theorem certificate_isolation (V : Type*) [DecidableEq V]
  (G : SimpleGraph V) (parts : Finset (Finset V))
  (h : ComponentCertificate G parts) (v : V) :
  (∀ w : V, ¬ G.Adj v w) ↔ {v} ∈ parts
theorem contactCount_eq_edge_count (S : Finset ℚ) :
  contactCount S = Nat.card (fareyGraph S).edgeSet
```

For rational parts, the certificate for `fareyGraph S` is transported to subtype vertices using `s.subtype (fun x => x ∈ S)` on each part. Require the explicit coverage-in-S guard `∀ s ∈ parts, s ⊆ S`; prove this transport preserves nonempty parts, their distinctness/cardinality, and membership before invoking the bijection. Do not silently drop vertices by filtering an invalid part. The proposed explicit helper predicate and bridge headers are:

```lean
def rationalCertificate (S : Finset ℚ) (parts : Finset (Finset ℚ)) : Prop :=
  (∀ s ∈ parts, s ⊆ S) ∧
  ComponentCertificate (fareyGraph S)
    (parts.image (fun s => s.subtype (fun x => x ∈ S)))
theorem rational_certificate_count (S : Finset ℚ) (parts : Finset (Finset ℚ))
  (h : rationalCertificate S parts) :
  Nat.card (fareyGraph S).ConnectedComponent = parts.card

theorem fixture421_vertices : phases [4,2,1] =
  {(1/5 : ℚ), 1/3, 2/5, 1/2, 3/5, 2/3, 4/5}
theorem fixture421_certificate : rationalCertificate (phases [4,2,1])
  {{(1/5 : ℚ)}, {1/3, 2/5, 1/2, 3/5, 2/3}, {4/5}}
theorem fixture421_counts : (phases [4,2,1]).card = 7 ∧
  contactCount (phases [4,2,1]) = 6 ∧
  Nat.card (phaseGraph [4,2,1]).ConnectedComponent = 3
theorem fixture4321_connected : (phaseGraph [4,3,2,1]).Connected
theorem fixture4321_repair_edges :
  (1/5 : ℚ) ∈ phases [4,3,2,1] ∧ (1/4 : ℚ) ∈ phases [4,3,2,1] ∧
  (3/4 : ℚ) ∈ phases [4,3,2,1] ∧ (4/5 : ℚ) ∈ phases [4,3,2,1] ∧
  fareyAdj (1/5) (1/4) ∧ fareyAdj (3/4) (4/5)
theorem fixture92_certificate : rationalCertificate (phases [9,2])
  (singletonPartition (phases [9,2]) {(1/10 : ℚ), 1/5, 4/5, 9/10})
theorem fixture83_certificate : rationalCertificate (phases [8,3])
  (singletonPartition (phases [8,3]) {(1/9 : ℚ), 8/9})
theorem fixture92_counts : (phases [9,2]).card = 11 ∧
  contactCount (phases [9,2]) = 8 ∧
  Nat.card (phaseGraph [9,2]).ConnectedComponent = 5
theorem fixture83_counts : (phases [8,3]).card = 11 ∧
  contactCount (phases [8,3]) = 8 ∧
  Nat.card (phaseGraph [8,3]).ConnectedComponent = 3
theorem fixture421_isolated (x : ℚ) :
  isolated (phases [4,2,1]) x ↔ x ∈ ({(1/5 : ℚ), 4/5} : Finset ℚ)
theorem fixture92_isolated (x : ℚ) :
  isolated (phases [9,2]) x ↔ x ∈ ({(1/10 : ℚ), 1/5, 4/5, 9/10} : Finset ℚ)
theorem fixture83_isolated (x : ℚ) :
  isolated (phases [8,3]) x ↔ x ∈ ({(1/9 : ℚ), 8/9} : Finset ℚ)
```

F2 must include the `(4,2,1)` finite checks, the `(9,2)` certificate, and a proved component bijection, within its single serial cap. It does not certify `(8,3)` or `(4,3,2,1)` automatically. The proposed one-large-part partition for each II.5k fixture follows the reported component/isolated counts and is a proof obligation, not a new enumeration result.

## Source/standing map and omitted status

| Targets | Kernel source | Standing retained |
|---|---|---|
| A1, A2 rosette | II.5b unconditional clauses and guards | classical arithmetic and unconditional rosette specialization |
| A2 adjacent mediant, A3, A4 and canonical bridges | classical Ford/Farey background supporting II.5b; general helper extensions | classical helper results; no new kernel standing assigned |
| A5 | II.5f (i)/(iii), scoped clauses only | unconditional; omitted clauses explicitly listed above |
| A6 domain/set equality | Setting and II.5g | unconditional |
| A6 partner/congruence | II.5i | unconditional with the same interior guards |
| A6 cross denominator | II.5i.1 | unconditional on the interior domain |
| A6 isolation/complement | II.5j and II.5j.1 | unconditional |
| A7 421/4321 | worked fixture after II.5j.1 | exact worked instance |
| A7 92/83 | II.5k | unconditional finite witness |
| generic certificate and counting bridges | implementation support using Mathlib semantics | helper extension, not a kernel claim |

Final README must map each actual Lean name to the exact source paragraph/line and independent fidelity sign-off; this grouped draft does not substitute for that final review. No geometric helix/step/twist, Fourier modulus, Dirichlet infinitude, Rule 30 forcing, or Stage B conclusion follows from this batch.
