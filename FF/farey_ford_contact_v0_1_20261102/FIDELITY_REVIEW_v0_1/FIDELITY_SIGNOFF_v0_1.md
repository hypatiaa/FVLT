# FF-1 Stage A statement-fidelity sign-off v0.1

2026-11-03. Reviewer: independent verifier subagent (Claude Opus) for the skeleton seat. This is a meaning review of frozen Lean statements against the pinned kernel v3.3.1. Proofs, compilation, axioms and replay are not judged here; they are verified elsewhere.

## Verdict summary

| Verdict | All 72 | A rows (60) | B rows (12) |
|---|---|---|---|
| MATCH | 67 | 55 | 12 |
| HARMLESS_GENERALIZATION | 3 | 3 | 0 |
| NARROWER_THAN_SOURCE | 2 | 2 | 0 |
| TRANSLATION_DEFECT | 0 | 0 | 0 |
| PROSE_CORRECTION_CANDIDATE | 0 | 0 | 0 |
| UNRESOLVED | 0 | 0 | 0 |

No translation defect, prose-correction candidate or unresolved row was found. Two rows state less than their kernel sentence (A26, A27) and three state more than the kernel context (A29, A30, A31); none of these changes a kernel claim. Details follow.

## Method

1. **Closed inputs.** Only the files listed under Inputs were read. Their SHA-256 values are in `FIDELITY_SIGNOFF_v0_1.json`.
2. **Integrity.** A script checked, for all 72 rows: the source file SHA-256 against the matrix; that the matrix `frozen_header` equals the actual source text at `source_line` (whitespace-normalized); that each A header appears verbatim in `REFERENCE_SIGNATURE_FREEZE_v0_1.md` and each B header in `BRIDGE_SIGNATURE_FREEZE_DRAFT_v0_1.md`. All passed. The matrix kernel pin (`e4953308…`) and signature pin (`a9382d40…`) equal the hashes of the reference copies, and the work order equals E1's pin (`43560b88…`).
3. **Definitions.** Every definition a statement uses was read in the source and compared with the signature freeze: det, fareyAdj, rawValue, mediant, unitFrac, radius, centre, disk, boundary, realAxis, tangent, kissN, kissM, kiss, admissible, phases, unreducedPhases, fareyGraph, phaseGraph, integerPath, vertexSet, contactCount, isolated, singletonPartition, ComponentCertificate, rationalCertificate, and the bridge producer definitions. All match; phases and unreducedPhases differ only by the S1 binder annotation `: ℕ`.
4. **Kernel reading.** Each statement was read against the kernel text: §9.4 Ford row (line 644), Rmk II.5b (716-751), Rmk II.5c spine law (785-795), Rmk II.5f (891-905, already reading "induced subgraph on V of the integer path"), Setting (908-942), Lemma II.5g (945-963), Def II.5h (968-1008), Lemma II.5i (1013-1047), Cor II.5i.1 (1050-1056), Cor II.5j (1061-1072), Cor II.5j.1 (1075-1101), worked fixture (1105-1153), Prop II.5k (1158-1205). The producer's locators were verified or corrected.
5. **Exact arithmetic by script** (node, integers/BigInt only, in the reviewer scratchpad): the four fixtures ((4,2,1), (4,3,2,1), (9,2), (8,3)): D, F, edges, T_ph, components, isolated sets; II.5g set equality, the exact II.5i partner sets, cross-denominator edges and complement-isolation symmetry over all 219 nonincreasing profiles with 1 ≤ m ≤ 3 and 1 ≤ a_i ≤ 9 (0 mismatches); the gap determinant and k > 2 parity law for a, k < 60 (0 mismatches); the kiss point lying on both circles and n²+1 = (a²+c²)m for all reduced adjacent pairs with q, s < 25 (0 mismatches). The fixture outputs agree with every count in the kernel and in the Lean statements, and confirm that the "one large part" in each II.5k singletonPartition is a single component.

Classification vocabulary: MATCH, HARMLESS_GENERALIZATION, NARROWER_THAN_SOURCE, TRANSLATION_DEFECT, PROSE_CORRECTION_CANDIDATE, UNRESOLVED. Rows with no directly named kernel item are marked "classical helper, no native kernel item"; no kernel ID is invented for them.

## All 72 rows

| ID | Lean name | Kernel locator (verified) | Verdict | Note |
|---|---|---|---|---|
| A01 | `FareyContactV1.raw_det_one_coprime` | Classical helper; echoes the automatic-coprimality argument of Lemma II.5i (lines 1034-1039) and work order A1. No native kernel item. | MATCH | classical helper, no native kernel item. |
| A02 | `FareyContactV1.rawValue_num_den` | Classical helper (work order A1 canonical bridge). No native kernel item. | MATCH | classical helper, no native kernel item. |
| A03 | `FareyContactV1.rawValue_canonical` | Classical helper (work order A1 canonical bridge). No native kernel item. | MATCH | classical helper, no native kernel item. |
| A04 | `FareyContactV1.rawValue_unique` | Classical helper (work order A1 canonical bridge). No native kernel item. | MATCH | classical helper, no native kernel item. |
| A05 | `FareyContactV1.fareyAdj_symm` | Classical helper; supports the undirected edge relation of Def II.5h (line 968). No native kernel item. | MATCH | classical helper, no native kernel item. |
| A06 | `FareyContactV1.fareyAdj_irrefl` | Classical helper; supplies the "two distinct vertices" clause of Def II.5h (line 976). No native kernel item. | MATCH | classical helper, no native kernel item. |
| A07 | `FareyContactV1.fareyGraph_adj` | Def II.5h (lines 968-981): adjacency of the phase-mode contact graph is \|as-cq\| = 1 on reduced data (definitional). | MATCH | The producer listed this as a support obligation only; it is the definitional content of Def II.5h for fareyGraph S (phaseGraph = fareyGraph (phases α)). |
| A08 | `FareyContactV1.coprime_den_not_adj` | Rmk II.5b Guard 2 (lines 734-737): 1/3, 1/5 reduced with coprime denominators, det = 2. | MATCH | Corrected locator: Guard 2, not the line-716 background. |
| A09 | `FareyContactV1.adjacent_mediant` | Classical helper (Stern-Brocot mediant property; II.5b cites §9.2). No native kernel item. | MATCH | classical helper, no native kernel item. |
| A10 | `FareyContactV1.rosette` | Rmk II.5b mediant and adjacency bullets (lines 719-724) plus Guard 1, flank det = 2 (lines 728-729). | MATCH | N:ℕ with 2 ≤ N, so N-1 ≥ 1 (no truncation). |
| A11 | `FordGeometryV1.radius_pos` | Classical helper; §9.4 Ford row (line 644), radius 1/(2q^2). No native kernel item. | MATCH | classical helper, no native kernel item. |
| A12 | `FordGeometryV1.ford_distance_identity` | Classical helper (Ford distance identity); supports the §9.4 row (line 644) and the II.5b tangency bullet. No native kernel item. | MATCH | classical helper, no native kernel item. |
| A13 | `FordGeometryV1.ford_open_disjoint` | Classical helper; supports II.5f Setup "disjoint otherwise" (line 893) and the §9.4 row. No native kernel item. | MATCH | classical helper, no native kernel item. |
| A14 | `FordGeometryV1.ford_boundary_disjoint` | II.5f Setup (line 893): Ford circles with \|det\| ≠ 1 are "disjoint otherwise"; §9.4 row (line 644). | MATCH | For x ≠ y, det ≠ 0, so \|det\| ≠ 1 iff \|det\| ≥ 2: the hypothesis 2 ≤ \|det\| is exactly the kernel case. |
| A15 | `FordGeometryV1.ford_tangent_iff` | §9.4 Ford row (line 644) "tangent iff Farey neighbors"; II.5b tangency bullet (lines 725-726); II.5f Setup (line 893); Def II.5h (line 983). | MATCH | tangent := x ≠ y ∧ the boundary circles meet in exactly one point (distinct-circle convention, work order §3). |
| A16 | `FordGeometryV1.ford_real_axis` | Classical helper; II.5f Setup "tangent to the real axis at 1/a" (line 893), here for all x; §9.4 row "circle ... at p/q". No native kernel item. | MATCH | classical helper, no native kernel item. |
| A17 | `FordGeometryV1.kiss_membership` | Classical helper (kiss point (n+i)/m); not in the kernel text (work order A4, viewer code). No native kernel item. | MATCH | classical helper, no native kernel item. |
| A18 | `FordGeometryV1.kiss_unique` | Classical helper (kiss uniqueness, work order A4). No native kernel item. | MATCH | classical helper, no native kernel item. |
| A19 | `FordGeometryV1.two_squares` | Classical helper (Brahmagupta-Fibonacci two-squares identity). No native kernel item. | MATCH | classical helper, no native kernel item. |
| A20 | `FordGeometryV1.kiss_integer_identity` | Classical helper (n^2+1 = (a^2+c^2) m, work order A4). No native kernel item. | MATCH | classical helper, no native kernel item. |
| A21 | `FordGeometryV1.kiss_real_identity` | Classical helper (real cast of A20). No native kernel item. | MATCH | classical helper, no native kernel item. |
| A22 | `FareyContactV1.unitFrac_injective_positive` | Classical helper; supports II.5f Setup "repeated exponent values ... one circle" (line 893). No native kernel item. | MATCH | classical helper, no native kernel item. |
| A23 | `FareyContactV1.integerPath_adj` | Classical helper (unfolding of integerPath; "integer path" of II.5f (i), line 895). No native kernel item. | MATCH | classical helper, no native kernel item. |
| A24 | `FareyContactV1.unitFrac_adj` | II.5f Setup (line 893), "On unit fractions this is \|b-a\|", and the II.5c unit-fraction spine law (lines 785-788): adjacent iff k = 1. | MATCH | a, b ≥ 1, as V ⊂ ℤ≥1. |
| A25 | `FordGeometryV1.unitFrac_tangent` | II.5f Setup (line 893): F(1/a), F(1/b) tangent iff \|a-b\| = 1; II.5b tangency bullet (lines 725-726) for the rosette. | MATCH | Includes a = b (tangent false, \|0\| ≠ 1), consistent with "repeated values contribute one circle". |
| A26 | `FareyContactV1.unitFrac_graph_iso` | II.5f (i) (line 895), first sentence: the tangency graph of {F(1/a)} is the induced subgraph on V of the integer path, with an edge exactly between consecutive integers. | NARROWER_THAN_SOURCE | The conclusion is Nonempty (integerPath.induce V ≃g fareyGraph (vertexSet V)): existence of SOME graph isomorphism, not that the canonical map a ↦ 1/a is one. |
| A27 | `FareyContactV1.unitFrac_graph_connected` | II.5f (i) (line 895), connectivity sentence. | NARROWER_THAN_SOURCE | For nonempty V ⊂ ℤ≥1: connected iff V = Icc m M with 1 ≤ m ≤ M. |
| A28 | `FareyContactV1.empty_graph_convention` | Classical helper (work order A5 empty-case convention, under Mathlib Preconnected/Connected). No native kernel item. | MATCH | classical helper, no native kernel item. |
| A29 | `FareyContactV1.gap_det` | II.5f (iii) (line 899), gap width k = det k; exactly the II.5c unit-fraction spine law (lines 785-788). | HARMLESS_GENERALIZATION | Kernel (iii) states it for a, a+k ∈ V with no intermediate values; Lean states it for all a ≥ 1, k ≥ 1, independent of V. |
| A30 | `FareyContactV1.minimal_gap_mediant` | II.5f (iii) (line 899), minimal break k = 2: med(1/a, 1/(a+2)) = 1/(a+1); also II.5c (line 791). | HARMLESS_GENERALIZATION | Stated for every a ≥ 1, without the kernel context a, a+2 ∈ V, a+1 ∉ V. |
| A31 | `FareyContactV1.gap_mediant_unit_iff` | II.5f (iii) (line 899): for k > 2 the endpoint mediant 2/(2a+k) is a unit fraction iff k is even; also II.5c (lines 790-791). | HARMLESS_GENERALIZATION | Stated for every a ≥ 1, k > 2, without the V-context. |
| A32 | `FareyContactV1.phases_eq_unreduced` | Lemma II.5g (lines 945-963) against the Setting F(a) (lines 908-942). | MATCH | unreducedPhases = {e/(a+1) : a ∈ α, 1 ≤ e ≤ a} = {red(e/n_i) : 1 ≤ e ≤ n_i - 1}; values in ℚ do the reduction. |
| A33 | `FareyContactV1.phase_domain` | Setting (lines 922-942): F(a) ⊂ ℚ ∩ (0,1), with reduced denominators in D(a), q ≥ 2. | MATCH | One direction (membership implies the domain facts), as frozen; it matches the Setting. |
| A34 | `FareyContactV1.denominator_partner` | Lemma II.5i (lines 1013-1045), first statement and automatic coprimality. | MATCH | For any integer c: c/s is a vertex with reduced denominator s and numerator c, adjacent to x, iff 1 ≤ c ≤ s-1 and a s - c q = ε ∈ {±1}. |
| A35 | `FareyContactV1.partner_congruence` | Lemma II.5i, "Equivalently" clause (lines 1025-1032). | MATCH | Int.ModEq q (a s) ε means a s ≡ ε (mod q). |
| A36 | `FareyContactV1.cross_denominator` | Cor II.5i.1 (lines 1050-1056). | MATCH | Restricted to x, y ∈ phases α (interior domain), where it holds; the work order notes that it fails at 0/1 and 1/1, which lie outside the domain. |
| A37 | `FareyContactV1.isolation_criterion` | Cor II.5j (lines 1061-1072). | MATCH | isolated = member with no fareyAdj partner in the set = degree-zero vertex of fareyGraph. |
| A38 | `FareyContactV1.endpoint_isolation` | Cor II.5j.1, endpoint form (lines 1077-1084). | MATCH | For 1/n (n ∈ D, so 1/n is a vertex): s ≡ ε (mod n) with an interior induced numerator (s-ε)/n. |
| A39 | `FareyContactV1.complement_mem` | Cor II.5j.1 (lines 1086-1092): ι maps F(a) to itself (well-definedness of the automorphism). | MATCH | Holds for every rational x; no hidden restriction. |
| A40 | `FareyContactV1.complement_adj` | Cor II.5j.1 identity \|(q-a)s-(s-c)q\| = \|cq-as\| (lines 1094-1096). | MATCH | The interior hypotheses are not mathematically needed (true for all rationals, since den(1-x) = den x), but they match the kernel domain F(a) ⊂ (0,1). |
| A41 | `FareyContactV1.complement_graph_auto` | Cor II.5j.1 (lines 1086-1092): ι(x) = 1 - x is an automorphism of G_ph(a). | MATCH | Existence of a graph automorphism acting exactly as x ↦ 1 - x on vertices: the canonical map, as the kernel says. |
| A42 | `FareyContactV1.isolated_complement_pairs` | Cor II.5j.1 (lines 1083-1084, 1098-1099): complementary isolation status; isolated vertices come in complementary pairs, except the fixed vertex 1/2. | MATCH | Isolation is invariant under x ↦ 1 - x, and 1/2 is the only fixed point: exactly the pairing statement with its exception. |
| A43 | `FareyContactV1.spanning_tree_connected` | Classical helper (spanning-tree certificate soundness; work order R3). No native kernel item. | MATCH | classical helper, no native kernel item. |
| A44 | `FareyContactV1.certificate_component_bijection` | Classical helper (certificate-to-Mathlib ConnectedComponent bijection; work order R3). No native kernel item. | MATCH | classical helper, no native kernel item. |
| A45 | `FareyContactV1.certificate_component_count` | Classical helper (count corollary of A44). No native kernel item. | MATCH | classical helper, no native kernel item. |
| A46 | `FareyContactV1.certificate_isolation` | Classical helper (isolated vertex iff singleton part). No native kernel item. | MATCH | classical helper, no native kernel item. |
| A47 | `FareyContactV1.contactCount_eq_edge_count` | Def II.5h (lines 986-990): T_ph(a) = \|E(G_ph(a))\|. | MATCH | contactCount counts each unordered edge once by rational order; this theorem identifies it with the Mathlib edgeSet cardinality, i.e. |
| A48 | `FareyContactV1.rational_certificate_count` | Classical helper (transport of certificates to subtype vertices). No native kernel item. | MATCH | classical helper, no native kernel item. |
| A49 | `FareyContactV1.fixture421_vertices` | Worked fixture after II.5j.1 (lines 1105-1119): F(4,2,1). | MATCH | Script: D = {2,3,5}, F = {1/5, 1/3, 2/5, 1/2, 3/5, 2/3, 4/5}. |
| A50 | `FareyContactV1.fixture421_certificate` | Worked fixture (lines 1128-1136): three components. | MATCH | Certificate with parts {1/5}, {1/3, 2/5, 1/2, 3/5, 2/3}, {4/5}; by A44 these are exactly the Mathlib components. |
| A51 | `FareyContactV1.fixture421_counts` | Worked fixture (lines 1122-1128): \|F\| = 7, T_ph = 6, three components. | MATCH | Script: \|F\| = 7, T = 6, 3 components. |
| A52 | `FareyContactV1.fixture4321_connected` | Worked fixture (lines 1142-1151): the (4,3,2,1) graph is connected. | MATCH | Script: 9 vertices, 10 edges, 1 component. |
| A53 | `FareyContactV1.fixture4321_repair_edges` | Worked fixture (lines 1142-1149): 1/4 and 3/4 enter; edges 1/5-1/4 and 3/4-4/5. | MATCH | "Enter" (absence from F(4,2,1)) follows from A49. |
| A54 | `FareyContactV1.fixture92_certificate` | Prop II.5k (lines 1158-1203): G_ph(9,2) has 5 components and isolated set {1/10, 1/5, 4/5, 9/10}. | MATCH | singletonPartition = the four isolated singletons plus the remaining 7 vertices as one part. |
| A55 | `FareyContactV1.fixture83_certificate` | Prop II.5k (lines 1158-1203): G_ph(8,3) has 3 components and isolated set {1/9, 8/9}. | MATCH | Two singletons plus the remaining 9 vertices as one part; the script confirms. |
| A56 | `FareyContactV1.fixture92_counts` | Prop II.5k (lines 1166-1179): \|F(9,2)\| = 11, T_ph = 8, 5 components. | MATCH | Script: D = {2,3,5,10}, \|F\| = 11, T = 8, 5 components. |
| A57 | `FareyContactV1.fixture83_counts` | Prop II.5k (lines 1166-1183): \|F(8,3)\| = 11, T_ph = 8, 3 components. | MATCH | Script: D = {2,3,4,9}, \|F\| = 11, T = 8, 3 components. |
| A58 | `FareyContactV1.fixture421_isolated` | Worked fixture (lines 1138-1140): 1/5 isolated; 4/5 by complement symmetry. | MATCH | Exact isolated set {1/5, 4/5}, stated for all x : ℚ (non-members are not isolated by definition). |
| A59 | `FareyContactV1.fixture92_isolated` | Prop II.5k (lines 1186-1190): isolated set of (9,2). | MATCH | Script reproduces {1/10, 1/5, 4/5, 9/10}. |
| A60 | `FareyContactV1.fixture83_isolated` | Prop II.5k (lines 1192-1196): isolated set of (8,3). | MATCH | Script reproduces {1/9, 8/9}. |
| B01 | `FordExactCoordinatesV1.kissNQ_eq` | Bridge freeze link 1 (interface theorem, not a kernel item). | MATCH | kissNQ = F1 kissN, for all rational pairs. |
| B02 | `FordExactCoordinatesV1.kissMQ_eq` | Bridge freeze link 2 (interface theorem, not a kernel item). | MATCH | kissMQ = F1 kissM. |
| B03 | `FordExactCoordinatesV1.kissMQ_pos` | Bridge freeze link 3 (interface theorem, not a kernel item). | MATCH | Positivity proved, not assumed. |
| B04 | `FordExactCoordinatesV1.radiusQ_pos` | Bridge freeze link 4 (interface theorem, not a kernel item). | MATCH | Positivity proved, not assumed. |
| B05 | `FordExactCoordinatesV1.radiusQ_cast` | Bridge freeze link 5 (interface theorem, not a kernel item). | MATCH | The rational radius casts to the F1 real radius. |
| B06 | `FordExactCoordinatesV1.embedQ_injective` | Bridge freeze link 6 (interface theorem, not a kernel item). | MATCH | embedQ (u, v) = u + v i is injective. |
| B07 | `FordExactCoordinatesV1.centreQ_embed` | Bridge freeze link 7 (interface theorem, not a kernel item). | MATCH | The exact centre agrees with the F1 centre. |
| B08 | `FordExactCoordinatesV1.kissQ_embed` | Bridge freeze link 8 (interface theorem, not a kernel item). | MATCH | The exact kiss point agrees with the F1 kiss point. |
| B09 | `FordExactCoordinatesV1.sqDistanceQ_cast` | Bridge freeze link 9 (interface theorem, not a kernel item). | MATCH | The rational squared distance casts to the complex norm squared. |
| B10 | `FordExactCoordinatesV1.boundaryQ_iff` | Bridge freeze link 10 (interface theorem, not a kernel item). | MATCH | Rational boundary predicate iff F1 boundary membership of the embedded point; for supplied rational points only, as the freeze intends. |
| B11 | `FordExactCoordinatesV1.boundaryCheckQ_correct` | Bridge freeze link 11 (interface theorem, not a kernel item). | MATCH | Correctness of the Boolean checker, both directions. |
| B12 | `FordExactCoordinatesV1.adjacent_kissQ` | Bridge freeze link 12 (interface theorem, not a kernel item). | MATCH | For Farey-adjacent x, y the checker accepts kissQ x y on both circles; adjacency is required only here, as frozen. |

Full notes for every row are in the JSON (`rows[].scope_note`).

## Non-MATCH rows in full

### A26 `FVLT.FareyContactV1.unitFrac_graph_iso`: NARROWER_THAN_SOURCE

Kernel: II.5f (i) (line 895), first sentence: the tangency graph of {F(1/a)} is the induced subgraph on V of the integer path, with an edge exactly between consecutive integers.

The conclusion is Nonempty (integerPath.induce V ≃g fareyGraph (vertexSet V)): existence of SOME graph isomorphism, not that the canonical map a ↦ 1/a is one. The kernel sentence identifies the graphs through a ↦ F(1/a) ("an edge exactly between consecutive integers"). An abstract isomorphism does not say which vertex corresponds to which. The canonical edge rule is stated separately and exactly by A24 (with A22 for injectivity), so the package as a whole loses no kernel content, but this row alone is weaker than its sentence. The row also speaks of the Farey-adjacency graph; its identification with the "tangency graph" goes through A25.

### A27 `FVLT.FareyContactV1.unitFrac_graph_connected`: NARROWER_THAN_SOURCE

Kernel: II.5f (i) (line 895), connectivity sentence.

For nonempty V ⊂ ℤ≥1: connected iff V = Icc m M with 1 ≤ m ≤ M. This faithfully translates "connected iff V is an interval of consecutive integers". The (i) clause "and additionally anchored at the unit circle F(1/1) iff min V = 1" is omitted, and no other row states it (the omission is declared in the signature freeze; the clause is mathematically trivial). Empty V is handled separately by A28.

### A29 `FVLT.FareyContactV1.gap_det`: HARMLESS_GENERALIZATION

Kernel: II.5f (iii) (line 899), gap width k = det k; exactly the II.5c unit-fraction spine law (lines 785-788).

Kernel (iii) states it for a, a+k ∈ V with no intermediate values; Lean states it for all a ≥ 1, k ≥ 1, independent of V. The V-context does not affect the determinant, so the generalization is harmless. Against II.5c (1/(N-k), 1/N with N > k ≥ 1) it matches exactly.

### A30 `FVLT.FareyContactV1.minimal_gap_mediant`: HARMLESS_GENERALIZATION

Kernel: II.5f (iii) (line 899), minimal break k = 2: med(1/a, 1/(a+2)) = 1/(a+1); also II.5c (line 791).

Stated for every a ≥ 1, without the kernel context a, a+2 ∈ V, a+1 ∉ V. The phrase "the unique missing exponent" is trivial and not stated separately.

### A31 `FVLT.FareyContactV1.gap_mediant_unit_iff`: HARMLESS_GENERALIZATION

Kernel: II.5f (iii) (line 899): for k > 2 the endpoint mediant 2/(2a+k) is a unit fraction iff k is even; also II.5c (lines 790-791).

Stated for every a ≥ 1, k > 2, without the V-context. "Unit fraction" is rendered as ∃ b > 0 with mediant = 1/b. The kernel remarks "identifies only the midpoint, not the full missing set" and "exact only at k = 2" are non-claim prose and are not formalized. II.5c also covers k = 1 (odd, not a unit fraction); no row states that case, but II.5c lies outside the order scope.

**Consequence.** None of these five rows misstates a kernel claim. A29-A31 prove the kernel's arithmetic for every a, of which the in-V case is an instance. A26 is weaker than its sentence only in isolation; together with A24 and A22 the canonical identification is proved. The one kernel content that no row covers is the trivial anchoring clause of II.5f (i) ("anchored at F(1/1) iff min V = 1"), which the signature freeze omits on purpose. If a full-coverage claim for II.5f (i) is wanted, a small additional theorem (for example, 1/1 ∈ vertexSet V ↔ V.min = 1, or a canonical-map isomorphism for A26) would close it; that is a choice for the formalization owner, not a defect.

## Locator corrections to the producer mapping

- A07 and A47 are not support-only: A07 is the definitional content of Def II.5h (edges by |as-cq| = 1), and A47 is the bridge for Def II.5h's T_ph = |E(G_ph)|.
- A08 is Rmk II.5b Guard 2 (lines 734-737), not the line-716 background.
- A10's tangency bullet is carried by A25 (and A15); Guard 1's "±2 neighbors relative to the centre" by A29 at k = 2.
- A14, A15, A24, A25 have direct kernel text (§9.4 Ford row; II.5b tangency bullet; II.5f Setup line 893; II.5c spine law), not only "supporting background".
- A29-A31 are also exact instances of the II.5c unit-fraction spine law (lines 785-795).
- A01, A02-A06, A09, A11-A13, A16-A23, A28, A43-A46, A48 are classical helpers with no native kernel item (A01 echoes the automatic-coprimality argument inside Lemma II.5i).

## Bridge rows (B01-B12)

All 12 headers appear verbatim in the bridge freeze draft and say what it intends: the exact rational producer values (kissNQ, kissMQ, radiusQ, centreQ, kissQ, sqDistanceQ) equal or cast to the F1 real/complex definitions through embedQ (z.1 + z.2·i); boundaryQ and boundaryCheckQ are correct in both directions for supplied rational points; positivity is proved, not assumed; adjacency is required only for adjacent_kissQ. They are interface theorems with no kernel standing. All 12: MATCH.

## Support inventory

PASS: every declaration in the 11 source files is either one of the 72 matrix targets or one of the 64 support entries (no overlap, none missing). All support theorems are private; the public support items are definitions, instances and one abbrev (RatPlane). Every entry has integration_grants_new_kernel_standing = false. No accidental claim promotion found.

- 136 declarations found in the 11 source files = 72 targets + 64 support entries; 0 unlisted, 0 overlapping.
- 0 public theorems in the support list (23 private theorems, 35 definitions, 5 instances, 1 abbrev).
- 0 entries with `integration_grants_new_kernel_standing` other than false; source line text and private flags agree with the source for every entry.
- No `sorry`, `admit`, `native_decide` or `axiom` declaration text in the sources.
- Note: `noncomputable_marker` records only an explicit keyword; definitions inside a `noncomputable section` show false. This is informational.

## Limits of this review

- Meaning review only. It does not establish that the proofs compile, that the axiom lists are clean, or that the replay passes; those are separate checks. The scripted checks above are exact but bounded (fixtures exact; general laws only on the stated ranges) and do not substitute for the Lean proofs.
- The kernel was read only in the pinned reference copy; the II.5g-k lock record and the companion verifier were not consulted (outside the closed list).
- Mathlib semantics (SimpleGraph.induce, Connected, ConnectedComponent, Int.ModEq, Int division, Rat.num/den, Finset.subtype) were taken from standard knowledge of Mathlib, not re-read from the pinned Mathlib source.
- The judgment that the omitted II.5f (i) anchoring clause and the abstract-isomorphism form of A26 are acceptable scope choices belongs to the formalization owner; this review records them and does not decide.
- No input file was modified. No Lean was run and no remote host was contacted.

## Inputs (SHA-256)

| File | SHA-256 |
|---|---|
| `stage_a_integration_v1/FIDELITY_MATRIX_v0_1.json` | `cf5614f7b339304eb2ef88736183bf0429b43b6f6edd7fd2869b90ddaacaebc4` |
| `stage_a_integration_v1/FIDELITY_INDEX_v0_1.md` | `88e7df9660420ef795d5e1c69cb00e8d529d9ccd3a8b4eeaf1533a81be754039` |
| `stage_a_integration_v1/SUPPORT_DECLARATIONS_v0_1.json` | `c8c13e92f04cdbfd35a19bf47862447365e238a5e8097adc81f9c63b4b8d0778` |
| `stage_a_integration_v1/REFERENCE_kernel_v3_3_1.md` | `e49533088843e2cd0a1c531c4d8ba113ea30113e8135a15c17c040bdfca3e0e0` |
| `stage_a_integration_v1/REFERENCE_SIGNATURE_FREEZE_v0_1.md` | `a9382d4054a77d7a569e884b4f7e02b55f7c7e9aa0da2d3a6d1299075ea2b6c7` |
| `stage_a_integration_v1/REFERENCE_WORK_ORDER_v0_3.md` | `43560b88ab50dc77d8e222562f83bad68c8ba17d12a073523a99597a484d6fdd` |
| `stage_a_integration_v1/REFERENCE_ERRATUM_E1.md` | `b7240e8fe36a239d66e19986308b2a2d59aa5212d1c4b5af74dc0683768f4243` |
| `stage_a_integration_v1/REFERENCE_ERRATUM_S1.md` | `03c54bbfa34cb9854f7e10179f50a5e2fa2fdef3332e6886ec2a9613a92f9299` |
| `stage_a_integration_v1/src/FVLTFareyArithmeticCompletionV1.lean` | `01abe886ef9e92dd2cf8d4289a0093733ecb519facefc6345212e758fc4da2ac` |
| `stage_a_integration_v1/src/FVLTFareyCertificatesV1.lean` | `4119bffe98e36c703dfef30a1ff48b956ee90a623b12dbc931a1d6695a91121e` |
| `stage_a_integration_v1/src/FVLTFareyContactV1.lean` | `2760392f984bd1375169920a702ae53c13115ddfb36d71bae36b3855950d1e4b` |
| `stage_a_integration_v1/src/FVLTFareyFixturesCompletionV1.lean` | `85b05d8021e6f44979c0f98533ade819f1b88363adfce331cdbe9f26e5ba0a2d` |
| `stage_a_integration_v1/src/FVLTFordExactCoordinatesV1.lean` | `23f776a40d9daec1cd7ec4f27c9c64917be6430595416756c6d7fe7d88dc7f3d` |
| `stage_a_integration_v1/src/FVLTFordGeometryCompletionV1.lean` | `c3251f10239e178c243a7793f35e60fddda64637342adfc7c52fdd95dd5b18a1` |
| `stage_a_integration_v1/src/FVLTFordGeometryV1.lean` | `0b380fd6cf1319317edbc9bbd5c56ed6f913bfbb7ac45104877b0f754b7e6db8` |
| `stage_a_integration_v1/src/FVLTFordRationalV1.lean` | `fdccda2c22abe186acc8530f4c7f28bcbce7c8498407061dd2f5ba693c606559` |
| `stage_a_integration_v1/src/FVLTPhasePartnersV1.lean` | `81b55661b4e1c6c8e4a8a837fdd62bf1ce61b7358499334d818756fa173e80ac` |
| `stage_a_integration_v1/src/FVLTStageAIntegrationV1.lean` | `0d43383f2d3889a6811565d994e691b8e1811452c12699fbdae0fb83ef9dc9fa` |
| `stage_a_integration_v1/src/FVLTUnitFractionSpineV1.lean` | `21b2efd2defd0d42f7a1238c1ee417926a0033f41df700d13c937feee6156bf1` |
| `BRIDGE_SIGNATURE_FREEZE_DRAFT_v0_1.md` | `4c9c80e59664bf91f2b558611bd764e8e5f58c8286b4db7cebdc00e4e61f4f8d` |
