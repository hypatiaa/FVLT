# Work order: the skin of a squarefree divisor atom in Lean (FF-2), v0.3

2026-11-03. Drafted by the skeleton seat (Claude Opus 5.5) at saphir's request. **Status: draft for design review by the formalization owner.** Nothing is preregistered, built or dispatched until the owner's review accepts this exact order and saphir gives a separate FF-2 execution go. FF-2 runs serially after FF-1 Stage A.

**History.** v0.1 (`WORK_ORDER_v0_1.md`, `1b00f78f07c0e09f1dee4a713af85ace8ceaa2910d7045ef2c2f58b95b696101`, #1372) stated Part B for the raw net map; **that claim was false** (it separates seam points of one orbit) and is withdrawn. v0.2 (`WORK_ORDER_v0_2.md`, `7babdc257d6d41e59abd26f37ef6b7f9833510f1fcda65319970978c2c0a3259`, #1374) corrected it. v0.3 incorporates the owner's review of v0.2 (ACCEPT WITH CHANGES, #1377; `rule30_seats/codex/reviews/ff2_design_20261103/REVIEW_v0_2.md`, SHA-256 `289641b9516fac100a0971ba3108d0a1b4f907594db20daa71f262d81aa9dc2c`, matched by skeleton), packets S1–S4. Both predecessors are unchanged.

## 1. Purpose and standing

Put the atom skin pen's skin and its pillowcase quotient into Lean as **exact combinatorial certificates**, uniformly in ω and in the grid size. The skin is instrument-tier, **not a kernel item**; a theorem here does not change that. Pen run readouts (return counts, ledgers) are not targets.

## 2. Governing inputs

| Input | Pin |
|---|---|
| Atom skin pen template v0.2 (skin, `eps`, `skinPen`, `isBoundary` at lines 132–170; flat atoms, `pillow`, `pillowKey` from line 172) | `rule30_prize_research_2026_10_26/s4s_duhamel_prior_art_20261031/atom_skin_pen_v0_1/atom_skin_pen_template_v0_2.html`, SHA-256 `0f996efecf1147d63e8f4e543fc162d5d09785493c3d41799f002bab8a6a8225` |
| Generated page (for reference; the template carries the definitions) | same folder, `atom_skin_pen_v0_2.html`, SHA-256 `fd88dbbf90a60117460f71176231462cc9044fbae1555eaeedb7f16d185539e5` |
| Library, toolchain, Mathlib, checker | as frozen for FF-1 Stage A (`FREEZE_REVIEW_v0_1_20261103.md`, `e7769841…`), re-observed at this order's own input freeze |

## 3. Definitions (S1, S2)

Binders: `(ω : ℕ) (hω : 3 ≤ ω)`. Seats are `Fin ω` with the **declared cyclic order** i ↦ i + 1 (mod ω) as data. An optional divisor reading needs an injective prime labelling `p : Fin ω → ℕ` of primes and the squarefree product N = ∏ pᵢ as explicit hypotheses; no hidden choice of primes.

- **Vertices:** `Finset (Fin ω)`.
- **Edges:** pairs (v, d) with d ∉ v, standing for {v, v ∪ {d}}; one representative per edge.
- **Squares:** pairs (v, i) with i ∉ v and i + 1 ∉ v, corners v, v ∪ {i}, v ∪ {i+1}, v ∪ {i, i+1}; one representative per square. For ω ≥ 3 the seat pairs {i, i+1} are pairwise distinct.
- **Oriented chain groups over ℤ:** C₀, C₁, C₂ free on vertices, edges, squares; ∂(v, i) = ε(v)·( e(v,i) + e(v∪{i}, i+1) − e(v∪{i+1}, i) − e(v, i+1) ) with ε(v) = (−1)^|v|.
- **Link at a vertex x:** the graph whose vertices are the edge directions at x and with one edge {i, i+1} for each square at x.
- **Pen state:** (w, b) with w a vertex and b : Fin ω the back-edge direction; for s ∈ {−1, +1}, step(w, b, s) = (w xor {d}, d) with d = b − s·ε(w) mod ω (template line 153).

## 4. Part A: exact combinatorial certificate (all ω ≥ 3)

| # | Statement |
|---|---|
| A1 | Counts in ℕ: V = 2^ω, E = ω·2^(ω−1), F = ω·2^(ω−2). **χ := (V : ℤ) − E + F**, and χ = (2 : ℤ)^(ω−2)·(4 − (ω : ℤ)). |
| A2 | Every edge is a face of exactly two squares (the seat pairs {d−1, d} and {d, d+1}). |
| A3 | Link condition: for every vertex x the link at x is isomorphic to the cycle graph C_ω. |
| A4 | Orientation: the two squares at each edge give it opposite coefficients; hence ∂(Σ squares) = 0 in C₁. |
| A5 | Connectedness: the 1-skeleton is the full ω-cube graph, which is connected. |
| A6 | **Numerical genus invariant:** χ is even and g := 1 − χ/2 (in ℤ) equals 1 + ((ω : ℤ) − 4)·2^(ω−3). At ω = 3 this is 0 (the cube); natural-number truncation of (ω − 4) would wrongly give 1. |
| A7 | Pen: for every state (w, b) and s, d ≡ b ± 1 (mod ω), so both edges lie in one square at w; s = +1 always runs along the square's oriented boundary in the same sense and s = −1 in the opposite sense. |
| A8 | Least return: for every state (w, b) and fixed s, the full state returns at step 4 and not at steps 1, 2, 3; the four visited vertices are the corners of one square. |

**Standing of Part A (S2).** A2–A5 together are an **exact combinatorial closed-surface and orientation certificate**; A6 is an evaluated **numerical invariant**. Neither is a theorem that a topological realization is a closed surface of that genus, and no surface-classification theorem is claimed. A realization bridge, if wanted, is separately scoped later.

**The viewer's H₁ readout (S2), outside the targets.** `isBoundary` stores integer values in a `Float64Array`. Its exactness holds only while every value stays within the safe-integer range (|x| < 2⁵³); each pen step adds ±1 to one edge, so Σ|c_e| ≤ T, and each solved value is a signed sum of c_e over distinct edges along a dual-tree path, so |x| ≤ T. With the viewer's stream lengths (T ≤ 4096) that range is not approached, but the template does not enforce a bound on T. So the H₁ readout is exact **conditionally on that bound**. No viewer edit is requested.

## 5. Part B: the pillowcase quotient on lattice points (S3)

Binders: `(a b : ℕ) (ha : 0 < a) (hb : 0 < b)`, points v = (X, Y) ∈ ℤ × ℤ with explicit casts.

- **Relation:** v ~ w ↔ ∃ i j : ℤ, w = v + (2ia, 2jb) ∨ w = −v + (2ia, 2jb). Prove it is an equivalence relation. Optionally prove it is the orbit relation of the faithful action of the group generated by the half-turns about (ia, jb); otherwise B1 is stated for this arithmetic relation only.
- **Key:** a tagged type with constructors `boundary (r y : ℕ)`, `front (r y : ℕ)`, `back (r y : ℕ)`, computed as in the template: x = X mod 2a, y = Y mod 2b; if y > b then y ← 2b − y and x ← (2a − x) mod 2a; r = x if x ≤ a else 2a − x; boundary if r ∈ {0, a} or y ∈ {0, b}, else front if x < a, else back. A bridge to the viewer's strings only if claimed.

| # | Statement |
|---|---|
| B1 | key(v) = key(w) ↔ v ~ w. |
| B2 | A point has a non-identity stabilizer (some half-turn fixes it; translations by (2ia, 2jb) ≠ 0 fix nothing) iff its class is one of the four classes of (0,0), (a,0), (0,b), (a,b), and these four classes are pairwise distinct. |

**Standing.** B1–B2 are statements about lattice points. They do not construct the continuous pillowcase, its orbifold angle π at the cone points, or any covering. In a continuous realization the plane-to-pillowcase map is **branched** at the cone points; it is not an unbranched universal cover of the sphere.

## 6. Part C: the universal cover (S4): staged C1, not dispatched

**Current status: C0, no work.** A C1 scope needs its own acceptance and execution go, after Parts A and B.

- **C1a (first stage).** Define based edge loops and the equivalence generated by backtrack cancellation and square-boundary moves. Prove soundness of a checker for an **explicit finite contraction sequence**: if it accepts, the loop is null-homotopic in that sense. A rejection means "certificate rejected or not supplied", **not** "essential".
- **C1b (later, separate).** A terminating, sound and complete decision procedure, which needs an identified normal-form theorem or a correct surface-group presentation together with its equivalence to the C1a loops.
- Keep the cases apart: ω = 3 (the sphere, simply connected), ω = 4 (a torus; the deck group is a rank-two **period sublattice** of the square lattice's translations, to be identified, not assumed to be all unit translations), ω ≥ 5 (surface groups of genus ≥ 5).
- **C2 deferred.** Geometry is stated with care: the unit Euclidean square metric is locally CAT(0) for ω ≥ 4 (flat face interiors); a regular hyperbolic-square metric for ω ≥ 5 is a separate construction. Neither CAT(−1) for the Euclidean metric nor global CAT(0) of the compact skin follows from the cycle links; the simply connected cover is the relevant CAT(0) space. The {4,ω} identification and faithful deck matrices need their own proofs; the viewer's floating ±identity test stays a numeric closure diagnostic.

**Physics reading (from the owner's review, recorded for saphir).** A closed walk carries two kinds of data: its abelian cycle class and its ordered transport. A scalar U(1) character of π₁ factors through H₁, so it cannot tell a commutator from the identity. A suitable non-abelian representation can tell some commutators apart, and only a faithful deck representation tells all of them; non-commutativity alone is not enough. For ω = 4, Bloch phases come after the period sublattice is identified. For ω ≥ 5, hyperbolic band theory is the comparison: Maciejko–Rayan, *Hyperbolic band theory* (arXiv 2008.05489); *Automorphic Bloch theorems for hyperbolic lattices* (2022, arXiv 2108.09314); *Non-Abelian hyperbolic band theory from supercells* (2023, arXiv 2305.04945); circuit-QED hyperbolic lattices, Kollár–Fitzpatrick–Houck (Nature 2019). A physical model would still need a Hilbert space, transport operators, a self-adjoint Hamiltonian and boundary conditions; an SU(1,1) matrix product is not by itself a unitary quantum evolution in the usual inner product. No spectrum or advantage is claimed for the pen.

## 7. Prior art (provisional where marked)

Coxeter's regular maps; McMullen–Schulte–Wills; Ringel and Beineke–Harary (genus of the cube graph); Gromov's link condition; Schläfli and Coxeter for {p,q}. **Provisional:** the identification of this skin with Coxeter's map {4,ω | 4^(⌊ω/2⌋−1)} and the minimal-genus attribution, until an explicit face/incidence isomorphism or a source passage is checked (arXiv 1211.4046, Duke and Schulte, *Cube-like polytopes and complexes*, abstract only so far). No novelty claim. Kit and submissions check: no hits (receipt #1372).

## 8. Pre-review evidence (producer evidence, not the reviewer's re-execution)

- Script SKEL-FF-SIGCHECK-0001 (membrane, `SKELETON_SIGNATURE_CHECK_20261103.cjs`, `e0cac846…`): Part A for ω = 3 … 12; Part B for a, b ≤ 5.
- Sage 10.9 on nucleus (`farey_ford_contact_v0_1_20261102/SAGE_CHECK_FF1_FF2_20261103.md`, `3505744f…`, and the v0.3 addendum `SAGE_CHECK_FF2_v0_3_20261103.md`): cubical complex f-vectors equal the counts for ω = 3 … 7; H₀ = ℤ, H₁ = ℤ^(2g) torsion-free, H₂ = ℤ; links are ω-cycles for ω ≤ 10; signed genus for ω ≤ 12; least return at 4 for ω ≤ 10; B1 against the explicit relation, B2 stabilizer classification and pairwise distinctness for a, b ≤ 5.

## 9. Gates, rules, outputs

As FF-1 `WORK_ORDER_v0_3.md` (SHA-256 `43560b88ab50dc77d8e222562f83bad68c8ba17d12a073523a99597a484d6fdd`): input and signature freezes before proofs, §6–7 gates, §9 rules, §10 outputs, read with "FF-2" for "FF-1". Serial after FF-1 Stage A. No compute on Neo; G1 excluded; no commits; library sync only as separately authorized.

**Credit.** Rule 30 written on surfaces, the divisor atoms, CAT(k) rather than CAT(0), the pen and the cover question: saphir. The skin of Div(30030): the cat0-cube-complexes track owner. The physics comparison and packets S1–S4: the formalization owner's review. "The framework was assembled by Robin Miller; its components are classical results of others."
