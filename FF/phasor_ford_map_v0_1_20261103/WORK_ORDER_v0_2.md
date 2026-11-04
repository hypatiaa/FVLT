# Work order: the lifted rosette-address to Ford-circle map (FF-3), v0.2

2026-11-03. Drafted by the skeleton seat (Claude Opus 5.5) at saphir's request. Successor of v0.1 (`WORK_ORDER_v0_1.md`, SHA-256 `9ff6cd0ba659d41e3e2e58f2110de0bbd2ae68ea9a63bd1a322cd6dcd9e145fd`, unchanged; #1401). It incorporates the formalization owner's review (ACCEPT WITH CHANGES, #1404; `rule30_seats/codex/reviews/ff3_design_20261103/REVIEW_v0_1.md`, `ef8ab5cad9807b8331acb4cc9a12d60d92d709f2d6857fb49a88e90c17606bf4`, matched by skeleton), packets M1–M4. **Status: draft for design review.** Nothing is preregistered, built or dispatched until the owner accepts this exact order and saphir gives a separate execution go. FF-3 runs after the computable bridge and FF-1 Stage A; its place relative to FF-2 is saphir's call.

**What v0.1 got wrong, now corrected** (each confirmed by skeleton in Sage before this draft):
- **M1.** v0.1 used the integer-spin contact rule for the Farey sweep, whose contacts occur at rational spins. At N = 3, s = 3/2 the reference phasor is real (phase π) while its address s/N = 1/2 is not an integer.
- **M2.** v0.1's P4 was wrong for negative t₂. At t₂ = −1, s = 1, n = 1 the absolute determinant is 1 while v0.1's right side gave −1.
- **M3.** v0.1 called Φ a map from phasor paths. At N = 3, s = 0 and s = 3 give the same phasor but addresses 0 and 1.
- **M4.** v0.1's P6 proved endpoint memberships but called them arcs.

## 1. Purpose

Kernel v3.3.1, Part II / II.5, §9.4 row: "A map sending Vernier phasor paths to Ford-circle arcs has not been defined; this is an interpretive comparison only." This order constructs a **discrete map from lifted rosette data to Ford circles**, with exact rational kiss-point certificates on its tangent steps. It does **not** construct a map from unlabelled phasor values, nor oriented continuous arcs (§6). If proved, the result supports an Idea Catalog correction candidate for the §9.4 row that describes exactly this construction and keeps the limitation on continuous dynamics. That goes through the accepted fidelity and mathematical review; there is no automatic adoption, and the historical statement is not retroactively falsified.

## 2. Governing inputs

| Input | Pin |
|---|---|
| FVLT kernel v3.3.1 (II.5a rosette and contact identity, II.5b, II.5f, §9.4) | `.agent/skills/fvlt/kernel_v3_3_1.md`, `e49533088843e2cd0a1c531c4d8ba113ea30113e8135a15c17c040bdfca3e0e0` |
| FF-1 F1 PASS (`fareyAdj`, `kiss`, `boundary`) | `farey_ford_contact_v0_1_20261102/F1_AUDIT_AND_BRIDGE_DECISION_v0_1.md`, `d5470d9b2353ca9de7309064dad363955e567a356fb5075dae04c0f9f32c7526` |
| FF-1 F2 PASS | `farey_ford_contact_v0_1_20261102/F2_AUDIT_AND_BRIDGE_RUNNER_DECISION_v0_1.md`, `95532c2c4101197646a7a310120c9ec766282a1b41537557f585591d0d4968e1` |
| Computable bridge signatures (`kissQ`, `boundaryCheckQ`, `adjacent_kissQ`) | `farey_ford_contact_v0_1_20261102/BRIDGE_SIGNATURE_FREEZE_DRAFT_v0_1.md`, `4c9c80e59664bf91f2b558611bd764e8e5f58c8286b4db7cebdc00e4e61f4f8d` |
| Lemma 6a, **candidate, unaudited; nothing assumed from it** | `candidates/ANL4_S2_FAREY_INPUT_LEMMA_v0_1_CLAUDE_OPUS_20260925.md`, `220a481905da2767379318d4960d08713ca821f1c6fcee944d6eed598f10bb3b` |
| Library, toolchain, Mathlib, checker | as frozen for FF-1, re-observed at this order's own input freeze |

## 3. Domain, phase law and the map (M1, M3)

**Lifted rosette data.** A record (t₁, t₂, s, n₃) with t₁, t₂ : ℤ, s : ℚ, n₃ : ℕ, 0 < n₃, together with a nonzero real amplitude r. The **phase address** is a(t₁, t₂, s, n₃) := t₁s − t₂s/n₃ ∈ ℚ, so θ₁ = π·a and z₁ = r·e^{iπa}. The **Ford address** is x(t₂, s, n₃) := t₂s/n₃ ∈ ℚ.

**Phase law (general, nonzero amplitude).** z₁ is real ⇔ a ∈ ℤ. Zero amplitude is excluded: then every phasor is the origin.

**Integer-spin specialization.** If additionally s ∈ ℤ, then t₁s ∈ ℤ, so a ∈ ℤ ⇔ x ∈ ℤ ⇔ n₃ ∣ t₂s, and e^{iπa} = (−1)^{t₁s}·e^{−iπx}. This parity identity is stated **only** under s ∈ ℤ.

**Two kinds of event, kept apart:**
- the **integer-address event** (integer spin): x ∈ ℤ, so the circle C(x) has radius 1/2;
- the **shell-contact event** (rational spin, P5): a ∈ ℤ with x usually not an integer.

**The map.** Φ(t₁, t₂, s, n₃) := the Ford circle C(x), with centre x + i/(2q²) and radius 1/(2q²), where q is the reduced denominator of x (F1's `centre`, `radius`). Φ is a map on **lifted data**. It need not descend through the projection to complex phasor values: at N = 3 (t₁ = t₂ = 1, n₃ = 3), s = 0 and s = 3 give the same nonzero phasor (phases 0 and 2π) but addresses 0 and 1. The phase law relates the declared data to the phasor; it is not an inverse recovery theorem. No Hasse or harmonic register identification, and no dynamical correspondence, is inferred from the shared denominator.

## 4. Part A: statements to prove (M1, M2)

Conventions: for a : ℤ and q : ℕ with 0 < q, g(a, q) := Nat.gcd a.natAbs q. Determinants are of the **reduced** fractions. Every determinant law is stated in **multiplication form** first, with the quotient form as a corollary, so no truncating division is confused with rational division.

| # | Statement |
|---|---|
| P1 | **Integer-address contacts (integer spin).** For t₂, s : ℤ and 0 < n₃: den(x) = 1 ⇔ n₃ ∣ t₂s. Reference divisor recovery (t₁ = t₂ = 1): for s > 0 and a scanned shell window 1 ≤ n₃ ≤ M, {n₃ ≤ M : den(s/n₃) = 1} = Div(s) ∩ [1, M]. The case s = 0 is separate: every n₃ gives the integer address 0. |
| P2 | **Reduced determinant, multiplication form.** For a, c : ℤ and 0 < q, r: abs(det(a/q, c/r)) · g(a,q) · g(c,r) = abs(a·r − c·q). |
| P3 | **Row law, reference gearbox t₂ = 1.** For N > 0 and 0 ≤ s < N (s : ℕ): abs(det(s/N, (s+1)/N)) · g(s,N) · g(s+1,N) = N. So the step is tangent iff N = g(s,N)·g(s+1,N). |
| P4 | **Column law, signed.** For u := t₂s : ℤ and n ≥ 1: abs(det(u/n, u/(n+1))) · g(u,n) · g(u,n+1) = abs(u). If u = 0 the two addresses coincide: a **stall**, with determinant 0. Tangent iff abs(u) = g(u,n)·g(u,n+1); in the reference case t₂ = 1, s > 0 this holds iff s ∣ n(n+1). The column s = 1 is the unit-fraction spine of II.5b and II.5f. |
| P5 | **Shell sweep (rational spin).** Canonical lower tooth t₁ = t₂ = 1, shells N = 2, …, B+1, rational s ∈ [0, N], nonzero amplitude. (i) Shell N has shell-contact events exactly at s = mN/(N−1), m = 0, …, N−1, with Ford address x = s/N = m/(N−1). (ii) The **set** of addresses over all shells, deduplicated, equals the Farey set F_B. (iii) Sorted strictly increasingly, consecutive addresses a/b < c/d satisfy b·c − a·d = 1. Proved here; the unaudited Lemma 6a is not assumed. The raw event multiset, with repeated 0 and 1, is not the Farey sequence. |
| P6 | **Exact endpoint certificates (first pass, M4 option (a)).** For a finite address path x₀, …, x_m, each **edge** k (0 ≤ k < m) is classified as exactly one of: **tangent** (fareyAdj x_k x_{k+1}), with certificate kissQ(x_k, x_{k+1}) satisfying boundaryCheckQ on both circles; **stall** (x_k = x_{k+1}); or **break** (neither), labelled with abs(det) ≥ 2. Each edge's certificate is exact and rational. |

## 5. Arcs: what is and is not constructed (M4)

- **Edges and circles are indexed separately.** Edge k joins circles k and k+1. An interior circle k (0 < k < m) touches two edges, k−1 and k. Only the per-edge condition fareyAdj(x_{k−1}, x_k) ∧ fareyAdj(x_k, x_{k+1}) is ever used. Mutual adjacency of all three circles is never assumed: the rosette's flanks 1/(N−1) and 1/(N+1) have determinant 2.
- **First pass delivers only the endpoint lift.** That means the circle sequence, the edge classification, and the exact kiss points of tangent edges. **Oriented arcs are not constructed here.** That needs a choice of which of the two arcs between two points, an equal-endpoint rule for a path that retraces (x_{k−1} = x_{k+1}), a parameterization, and proofs of whole-arc membership and continuity. It remains open, for a separate scope if wanted.
- **Path conventions.** Paths are finite, with initial circle C(x₀) and final circle C(x_m). A break splits the path into tangent runs. A stall is its own event, never identified with tangency. Exact rational endpoints do not imply rational coordinates elsewhere on an arc.

## 6. Not claimed

- No map from unlabelled phasor values or from continuous phasor motion; no dynamical or canonical arc correspondence.
- No oriented arcs (§5).
- No factoring or computational advantage (II.5a scope and the S2 closed-negative record stand).
- No viewer work (viewer track, saphir's direct go). No kernel edit (Idea Catalog candidate only, after review).

## 7. Pre-review evidence (skeleton, Sage 10.9 on nucleus; exact, finite; not proofs)

All **True**:
- P2 multiplication form for |a|, |c| ≤ 12 and 1 ≤ q, r ≤ 12, negatives included.
- P3 for 1 ≤ N < 150.
- P4 for −120 ≤ u ≤ 120 and 1 ≤ n < 80, plus the stall at u = 0. The reference criterion holds for 1 ≤ s, n < 120. v0.1's counterexample (t₂ = −1, s = 1, n = 1) gives abs(det) 1, against v0.1's right side −1.
- P1 window form for 1 ≤ s < 200 and M ∈ {1, 5, 50, 300}.
- P5 at B = 40:
  - every listed s gives a contact, there are exactly N of them, and all lie in [0, N];
  - the deduplicated address set has 491 elements and equals F₄₀, while the raw multiset has 860;
  - all consecutive determinants are 1.
- The M1 example (N = 3, s = 3/2: phase address 1, Ford address 1/2) and the M3 example (N = 3, s = 0 and s = 3: phase addresses 0 and 2, Ford addresses 0 and 1) as stated.

## 8. Prior art, gates, credit

Ford (1938); Haros–Cauchy; paths in the Farey graph (classical). In this project: II.5b and II.5f (the s = 1 column), Lemma 6a (unaudited), FF-1 and the bridge. Kit and `submissions.json`: no Ford, Haros or Farey material (#1401). No novelty claim.

Gates as FF-1 `WORK_ORDER_v0_3.md` (`43560b88…`): input and signature freezes, a job template, standard axioms, the strict checker, skeleton's independent recompile and replay, and verification by script and Sage. No compute on Neo, G1 excluded, no commits, library sync only as separately authorized.

**Credit.** The question of the map, the rosette and the instruments: saphir. Packets M1–M4: the formalization owner's review. This draft and Lemma 6a: skeleton (Claude Opus 5.5). "The framework was assembled by Robin Miller; its components are classical results of others."
