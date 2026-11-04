# Work order: Farey/Ford contact law in Lean (FF-1)

2026-11-02. Drafted by the skeleton seat (Claude Opus 5.5) at saphir's request ("Yes, for codex approval"), after Grok named the contact law as the next pressure point. **Status: draft for Codex review.** Nothing is dispatched until Codex accepts the scope and saphir gives the go.

## 0. Purpose

Put the kernel's Farey/Ford contact law into Lean, so that the atlas's rational-skeleton layers (Ford circles, kisses, the phase-mode contact graph) and the comb instrument's phase geometry stand on one verified foundation. This order covers the arithmetic and Euclidean statements (Stage A). The exponential lift (Stage B) is scoped here, but it needs a separate go after Stage A.

Kernel prose is not changed by this work. If a Lean statement contradicts or refines the kernel text, report it as a correction candidate for Idea Catalog. Lean is authoritative; the kernel gets corrected, the Lean is not bent to match the prose.

## 1. Governing inputs

| Input | Pin |
|---|---|
| FVLT kernel v3.3.1 (locked release of record, saphir 2026-10-30) | `.agent/skills/fvlt/kernel_v3_3_1.md`, SHA-256 `e49533088843e2cd0a1c531c4d8ba113ea30113e8135a15c17c040bdfca3e0e0` |
| Shared theorem library | `~/rule30_theorem_library/v19`, `SHA256SUMS` SHA-256 `e25d4d54d074f152c452aa7247ccbe992e14b29d58306809660a75770ae7ddd5` (as read on scout 2026-11-02) |
| Toolchain | `leanprover/lean4:v4.35.0`, the Mathlib pinned in the library's `lake-manifest.json` |
| Item locks touched (read-only) | Rmk II.5f, item-locked by Robin 2026-07-14; Farey II.5g–k fold, item-locked by Robin 2026-10-12 (`records/LOCK_RECORD_FAREY_II.5g-k.md`) |

| Requirement | Source (kernel v3.3.1) | Standing there |
|---|---|---|
| Determinant law, mediant, Ford tangency on the rosette | Rmk II.5b (line 716), the unconditional parts only | unconditional (det/mediant/tangency) |
| Unit-fraction chain criterion, gap width, minimal-break mediant | Rmk II.5f (i), (iii) (line 891) | unconditional |
| Phase-mode fraction set and phase reduction | Setting + Lemma II.5g (lines 908–963) | unconditional |
| Contact graph | Def II.5h (line 968) | definitional |
| Exact denominator-partner criterion | Lemma II.5i (line 1013) | unconditional |
| Contact is cross-denominator | Cor II.5i.1 (line 1050) | unconditional |
| Isolation criterion | Cor II.5j (line 1061) | unconditional |
| Endpoint form, complement automorphism | Cor II.5j.1 (line 1075) | unconditional |
| (4,2,1) and (4,3,2,1) fixture | worked fixture (line 1105) | exact worked instance |
| Contact count does not determine connectivity | Prop II.5k (line 1158) | unconditional finite witness |

Interpretive parts (II.5b cone-placement reading, II.5f (ii) label reading and (v) interpretive fixture, all guards' readings) are **not** in scope and must not be stated as theorems.

## 2. Prior art (checked 2026-11-02)

- **Mathlib (as pinned in library v1/v19):** no file mentions Farey, mediant or Ford circles (grep over 8,624 files).
- **Our library v19:** no Farey/Ford/mediant development; the only text hits were "Clifford".
- **Outside Lean:** Paulson, *Farey Sequences and Ford Circles*, Isabelle AFP (2025), following Apostol, *Modular Functions and Dirichlet Series*, ch. 5. Use it as a reference for structure and lemma order; it is not a dependency. Cite it in the module header.
- The viewers (atom viewer wl11–wl14) compute the kiss point as (n+i)/m with n = aq+cs, m = q²+s², and print n²+1 = (a²+c²)·m. That code is implementation evidence only; A4 below is the theorem it should agree with.

## 3. Stage A: statements to prove

All fractions are reduced, with positive denominators. Name the modules `FVLTFareyContactV1.lean` (arithmetic and graph) and `FVLTFordGeometryV1.lean` (Euclidean), namespace `FVLT.FareyContactV1` / `FVLT.FordGeometryV1`.

**A1. Contact relation.** `farey_adj (a/q) (c/s) := |a*s - c*q| = 1`. Prove: symmetric; irreflexive on reduced fractions; adjacency implies `gcd(q,s)=1` and that both fractions are reduced (II.5b Guard 2 direction: adjacency is strictly stronger than coprime denominators, with the witness 1/3, 1/5).

**A2. Mediant.** For adjacent a/q < c/s: the mediant (a+c)/(q+s) is reduced, lies strictly between, and is adjacent to both. Rosette instance (II.5b): 1/N is the mediant of 1/(N−1) and 1/(N+1) and adjacent to each for N ≥ 2; the flanks have determinant 2 (Guard 1).

**A3. Ford tangency law (exact identity).** Ford circle C(a/q): centre (a/q, 1/(2q²)), radius 1/(2q²), in `EuclideanSpace ℝ (Fin 2)` or ℂ (builder's choice, stated in the README). For distinct reduced a/q, c/s, with Δ = as − cq:

  dist(centres)² − (r₁ + r₂)² = (Δ² − 1)/(q²s²).

Consequences, each a named theorem: tangent (dist = r₁ + r₂) ⇔ |Δ| = 1; disjoint (dist > r₁ + r₂) ⇔ |Δ| ≥ 2; two distinct Ford circles never overlap. Every Ford circle is tangent to the real axis at a/q.

**A4. Kiss point.** If |Δ| = 1, the circles meet in exactly one point, and it is

  ((aq + cs)/(q² + s²), 1/(q² + s²)),

that is (n + i)/m with n = aq + cs, m = q² + s². Also prove n² + 1 = (a² + c²)·m (from (aq+cs)² + (as−cq)² = (a²+c²)(q²+s²)).

**A5. Unit-fraction spine (II.5f (i), (iii)).** For a finite value set V ⊆ ℤ≥1: C(1/a), C(1/b) tangent ⇔ |a − b| = 1; the tangency graph on {1/a : a ∈ V} is the induced subgraph of the integer path; it is connected ⇔ V is an interval. Gap width k = determinant k; for k = 2 the mediant of 1/a and 1/(a+2) is 1/(a+1); for k > 2 the mediant 2/(2a+k) is a unit fraction ⇔ k is even.

**A6. Phase-mode graph (II.5g–j.1).** Define D(𝐚), F(𝐚) (as a `Finset ℚ` or of reduced pairs) and G_ph(𝐚) with edges by A1. Prove II.5g (both descriptions of F(𝐚) agree), II.5i (partner criterion, with automatic coprimality), II.5i.1 (no edge between equal denominators), II.5j (isolation iff no admissible s, ε), II.5j.1 (endpoint congruence s ≡ ±1 mod n; ι(x) = 1 − x is a graph automorphism; isolated vertices come in complementary pairs except 1/2).

**A7. Finite witnesses.**
- Profile (4,2,1): |F| = 7, T_ph = 6, components {1/5}, {1/3, 2/5, 1/2, 3/5, 2/3}, {4/5}. Profile (4,3,2,1): connected, with edges 1/5–1/4 and 3/4–4/5.
- II.5k: (9,2) and (8,3) have |F| = 11 and T_ph = 8; (9,2) has 5 components and isolated set {1/10, 1/5, 4/5, 9/10}; (8,3) has 3 components and isolated set {1/9, 8/9}.

## 4. Stage B (scoped, not dispatched): exponential lift

E(z) = exp(2πiz) on the upper half-plane. Candidate statements: E is injective on the half-open strip 0 ≤ Re z < 1; E′ = 2πiE never vanishes, so crossing angles are kept (local conformality); for fractions in (0,1) with q ≥ 2, the images of two Ford circles meet exactly when the circles meet, at E of the kiss point; the q = 1 circle at 0 and its translate at 1 have one image that touches itself (−e^(−π)). **DESIGN DECISION before dispatch:** whether Stage B is wanted now, and in which form (sets and injectivity, or Mathlib's conformality API). Needs saphir's go after Stage A.

## 5. Decisions and items the build must establish

| Item | Kind | Resolution or test | Stop rule |
|---|---|---|---|
| ℚ vs reduced integer pairs for vertices | DESIGN DECISION | Codex chooses in review; state the equivalence lemma used | — |
| Plane model (EuclideanSpace vs ℂ) | DESIGN DECISION | Codex chooses in review | — |
| Stage B timing | DESIGN DECISION | saphir, after Stage A | — |
| A7 witnesses decidable with `decide` (component counts on ≤ 13 vertices) | BUILD MUST ESTABLISH | F2 below | If `decide` cannot close them within the caps, return the evidence; do not switch to `native_decide`, and do not add axioms |
| A6 statements match the kernel text exactly | BUILD MUST ESTABLISH | statement table in the README, kernel line next to each Lean name | Any mismatch: stop that item and return it as a correction-candidate packet; continue the others |

## 6. Acceptance tests

| Requirement | Test action | Authoritative observation | PASS | FAIL | INCOMPLETE | Cannot establish |
|---|---|---|---|---|---|---|
| Compiles | `lake env lean` on each module against library v19 | compiler exit code and log | exit 0, no errors | any error | harness fault before a verdict | that the statements are the right ones |
| No gaps | scan sources and the compiled environment | counts of `sorry`, `admit`, `native_decide`, `axiom` declarations | all 0 | any > 0 | — | — |
| Axioms | `#print axioms` on every target theorem | printed axiom lists | only `propext`, `Classical.choice`, `Quot.sound` | anything else | — | soundness of Mathlib itself |
| Strict replay | the same strict kernel-replay checker as the kernel-port passes | checker report | PASS, zero unsafe/partial constants | any failure | — | — |
| Statement fidelity | skeleton reads each Lean statement against the kernel line in the README table | the table, signed by the reviewer | every row matches | any row misstates scope | rows not reviewed | anything beyond the listed items |
| Library unchanged | `sha256sum -c` on library v19 before and after | checksum output | OK both times | any change | — | — |

## 7. Bounded feasibility stage (first, time-boxed)

| Assumption | Feasibility test | Budget | If it fails |
|---|---|---|---|
| F1: the A3 identity and A4 kiss point close with `field_simp`/`ring`/`nlinarith` in the chosen plane model | prove A3's displayed identity and A4's coordinates only | one capped job, ≤ 30 min wall | return the evidence; stop |
| F2: `decide` handles the A7 witnesses | prove the (4,2,1) counts only | one capped job, ≤ 30 min wall | return the evidence; stop A7 (A1–A6 may continue) |

## 8. Rules

- Additive only: new files in a new package folder `farey_ford_contact_v0_1_YYYYMMDD/` under `FVLT_FORMALIZATION_v0_1_20261028/`. No edits to the kernel, the library, earlier passes, or any locked item.
- Builds run on nucleus (scout as fallback) under the capped runners. **No compute on Neo.** G1 is excluded.
- No git commits, no downloads beyond the pinned Mathlib already present, no `python -` / `python -c` (write scripts to files).
- Stop rule: acceptance-test FAILs stop the item (compile error, checker failure, wrong axioms, statement mismatch). Harness, path or tooling errors before a verdict do not: log them, fix them, continue, and report once.
- Credit: the contact law is classical (Ford 1938; Farey; Apostol ch. 5); the phase-mode graph and its fixtures are the kernel's (Robin's (4,2,1) break). Framework line: "the framework was assembled by Robin Miller; its components are classical results of others".

## 9. Outputs and report

Outputs: the two `.lean` modules, `README.md` (statement table: Lean name → kernel line → standing), `NEW_THEOREMS.json`, build and checker logs, `#print axioms` output, `SHA256SUMS`, and a receipt of library v19's checksums before and after.

Report, in this order: governing inputs with digests; output folder and hashes; raw verdict with run ids; deviations, each with its preserved evidence; requirements not tested and why; the exact next decision and its owner. Status words: RUNNING, FINISHED, VERIFIED (skeleton reproduced), ACCEPTED, SEALED.

After skeleton verifies the delivery, the modules go into library v20 on nucleus and scout (routine sync).
