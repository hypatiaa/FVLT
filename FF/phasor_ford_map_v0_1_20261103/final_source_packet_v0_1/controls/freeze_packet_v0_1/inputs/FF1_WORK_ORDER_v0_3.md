# Work order: Farey/Ford contact law in Lean (FF-1), v0.3

2026-11-02. Drafted by the skeleton seat (Claude Opus 5.5) at saphir's request. Successor of v0.2 (`WORK_ORDER_v0_2.md`, SHA-256 `8cd67620078037a156037f6b1529b703b0dc099daaee653d35377fadd0828d98`, unchanged; v0.1 `4be9b367…` also unchanged).

v0.2 incorporated Astra's review in bus #1365 (ACCEPT WITH CHANGES; `FF1_DESIGN_REVIEW_20261102.md`, SHA-256 `6007b0c289e884a3aa71691d52ede4781ed082a9b755b60a73ede0c39ddb6bb7`), packets CP-01 … CP-06. v0.3 incorporates the formalization owner's review of v0.2, relayed in bus #1367 (ACCEPT WITH CHANGES; `rule30_seats/codex/reviews/ff1_design_20261102/REVIEW_v0_2.md`, SHA-256 `02bf29309b27e1ce310e6a750afbcf0a804803e77d5db02c7829cf7b7dfe10bc`, matched by skeleton), packets R1 … R3 and its scope notes. Every change carries its packet number.

**Status: draft for review by the formalization owner.** This review authorizes nothing. Nothing is preregistered, built or dispatched until the review accepts v0.2 and saphir gives the separate execution go. Stage B needs its own go after that.

## 0. Purpose

Put the kernel's Farey/Ford contact law into Lean, so that the atlas's rational-skeleton layers (Ford circles, kisses, the phase-mode contact graph) and the comb instrument's phase geometry stand on one verified foundation. Stage A covers the arithmetic and Euclidean statements. Stage B (the exponential lift) is scoped here but not dispatched.

## 1. Governing inputs (CP-01)

| Input | Pin |
|---|---|
| FVLT kernel v3.3.1 (locked release of record, saphir 2026-10-30) | `.agent/skills/fvlt/kernel_v3_3_1.md`, SHA-256 `e49533088843e2cd0a1c531c4d8ba113ea30113e8135a15c17c040bdfca3e0e0` (also verified by Astra, #1365) |
| Shared theorem library | `~/rule30_theorem_library/v19`; `SHA256SUMS` SHA-256 `e25d4d54d074f152c452aa7247ccbe992e14b29d58306809660a75770ae7ddd5` (read on scout 2026-11-02) |
| Toolchain | Lean 4.35.0, `x86_64-unknown-linux-gnu`, commit `eb6cafb7290e8bd5f2937522d8d804f58f02bafc` (as recorded in the kernel-port receipts) |
| Mathlib | commit `56a005855ea17e0b0958f73ec801ae140b0a1679` (`mathlibCommit` in the kernel-port receipts) |
| Strict replay checker | `IndependentFVLTReplay435.lean`, SHA-256 `9c6f2ac11b50fdb846df2d5099ea673553903275a5dba11fce5a5673cae14bd0` (byte-identical in the four kernel-port packages that carry it, e.g. `euclidean_progression_helix_v0_1_20261029/checker/`). It replays every target constant through `Lean.Kernel.Environment.replay` and fails on unsafe or partial target constants; imported dependencies are reused, not replayed. |
| Item locks touched (read-only) | Rmk II.5f, item-locked by Robin 2026-07-14; Farey II.5g–k fold, item-locked by Robin 2026-10-12 (`records/LOCK_RECORD_FAREY_II.5g-k.md`) |

**Input freeze (CP-01, R2).** The table above gives the expected values known now. At the authorized input and signature preparation stage, after the execution go and **before any proof work**, the builder records, for the library actually in use, both the expected value (from this table or the library's own records) and the observed value of:
- full SHA-256 of `SHA256SUMS`, `LIBRARY_MANIFEST.json`, `lake-manifest.json`, `lakefile.lean` (or the package configuration actually used), `lean-toolchain`, and the checker;
- the exact compiler identity (`lean --version`) and Mathlib identity (`git rev-parse HEAD`);
- a **complete, successful** library verification receipt: `sha256sum -c` over every file listed, and the read-only check (no writable files);
- the exact build and replay commands.

These go to freeze review. Proof work starts only after the reviewed freeze. This design review has not verified any of these execution inputs; values obtained only after the go are frozen by that review, not assumed. If any observed value differs from its expected value (for example, the library has moved past v19), the order **returns for review**. It does not silently switch pins.

**Signature freeze (CP-01).** Before any proof work, the builder inspects the Mathlib APIs and drafts the Lean signatures of every Stage A target, with every hypothesis as an explicit binder. The signatures are reviewed and frozen (hashed) first; proofs are written only against frozen signatures. Any later signature change goes back through review.

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

Interpretive parts (the II.5b cone-placement reading, the II.5f (ii) label reading and the (v) interpretive fixture, and the readings of all guards) are **not** in scope and must not be stated as theorems.

## 2. Prior art

As in v0.1, checked 2026-11-02: no Farey, mediant or Ford-circle development in the pinned Mathlib (grep over 8,624 files) or in library v19. Outside Lean: Paulson, *Farey Sequences and Ford Circles*, Isabelle AFP (2025), after Apostol, *Modular Functions and Dirichlet Series*, ch. 5; a structural reference, not a dependency; cite it in the module header.

This is a name search, inherited from v0.1. It is not an equivalence or API audit, and the order makes **no novelty claim** (#1365). The API inspection in the signature-freeze step is where equivalent Mathlib material would surface; if it does, reuse it and record it.

The viewers (atom viewer wl11–wl14) compute the kiss point as (n+i)/m and print n²+1 = (a²+c²)·m. That code is implementation evidence only.

## 3. Design decisions (settled in review, #1365)

- **Vertices.** `Finset ℚ`; a vertex is a subtype of its members. Use the canonical reduced numerator and positive denominator (`Rat.num`, `Rat.den`). Add raw integer-pair helpers with round-trip and uniqueness bridge lemmas between pairs and rationals. All casts explicit.
- **Plane model.** ℂ as the Euclidean plane, real radii, complex norm and distance. This keeps the model unchanged for the exponential map in Stage B.

### Scope notes for signature review (#1367)

- Raw numerator casts and positive-denominator hypotheses are explicit. The mediant is defined from canonical numerator and denominator data, not from arbitrary unreduced presentations.
- Tangency is stated for distinct circles (distinct rationals), or through a boundary-singleton definition that excludes a circle meeting itself. Open disks, boundary circles and the real-axis intersection are separate sets.
- The exponent-value unit-fraction graph (A5) and the interior phase-mode graph (A6) stay distinct. A shared repair fixture does not identify them.
- The source-to-statement table labels deliberately omitted clauses and any stronger helper lemmas. An extension gains no kernel standing by being included in this package.

## 4. Stage A: statements to prove

Modules `FVLTFareyContactV1.lean` (arithmetic and graph) and `FVLTFordGeometryV1.lean` (geometry); namespaces `FVLT.FareyContactV1` and `FVLT.FordGeometryV1`.

**A1. Contact relation (CP-03).**
- On raw integer pairs (a, q), (c, s) with q, s ≥ 1: `|a*s − c*q| = 1` implies gcd(a, q) = 1, gcd(c, s) = 1 and gcd(q, s) = 1. Prove it on pairs first, then transport it to rationals through the bridge lemmas.
- On ℚ: `farey_adj x y := |x.num * y.den − y.num * x.den| = 1`; symmetric; irreflexive.
- Adjacency is strictly stronger than coprime denominators: witness 1/3, 1/5 (coprime denominators, determinant 2).

**A2. Mediant (CP-02).**
- For adjacent x < y: the mediant (a+c)/(q+s) is reduced, lies strictly between, and is adjacent to both.
- Rosette flanks, **as a separate theorem with its own algebraic proof** (the flanks have determinant 2, so the adjacent-pair mediant theorem does not apply): for N ≥ 2, 1/(N−1) and 1/(N+1) have determinant 2; the reduced form of their mediant 2/(2N) is 1/N; 1/N is adjacent to each flank.

**A3. Ford tangency law (CP-03).** Ford circle C(x) for x = a/q: centre a/q + i/(2q²), radius 1/(2q²). For **distinct rationals** x ≠ y with Δ = as − cq:
- Identity: |centre(x) − centre(y)|² − (r(x) + r(y))² = (Δ² − 1)/(q²s²).
- The open disks are disjoint, for every x ≠ y.
- The boundary circles meet in exactly one point if |Δ| = 1, and are disjoint if |Δ| ≥ 2.
- Every Ford circle meets the real axis exactly at a/q.

**A4. Kiss point (CP-03).** If |Δ| = 1, the intersection of the two boundary circles is **exactly the singleton** {(n + i)/m} with n = aq + cs, m = q² + s² (uniqueness, not only membership). Also n² + 1 = (a² + c²)·m, from (aq+cs)² + (as−cq)² = (a²+c²)(q²+s²).

**A5. Unit-fraction spine (II.5f (i), (iii); CP-02).**
- Hypotheses: V is a **finite, non-empty** set of positive integers. "Consecutive interval" means V = {m, m+1, …, M} for some 1 ≤ m ≤ M.
- For a, b ≥ 1: C(1/a) and C(1/b) are tangent ⇔ |a − b| = 1.
- The tangency graph on {1/a : a ∈ V} is the induced subgraph on V of the integer path; it is connected ⇔ V is a consecutive interval.
- The empty case is stated separately as its own lemma, under Mathlib's `Preconnected` / `Connected` conventions, and is not folded into the main statement.
- Gaps, with a ≥ 1 and k ≥ 1 bound explicitly: 1/a and 1/(a+k) have determinant k; for k = 2 the mediant is 1/(a+1); for k > 2 the mediant 2/(2a+k) is a unit fraction ⇔ k is even.

**A6. Phase-mode graph (II.5g–j.1; CP-03).** Define D(𝐚), F(𝐚) and G_ph(𝐚) with edges by A1, keeping **interior phases only**, reduced denominators q, s ≥ 2, and the induced numerator-range condition as the kernel states them. Prove:
- II.5g: both descriptions of F(𝐚) agree.
- II.5i: the partner criterion, with automatic coprimality.
- II.5i.1: no edge between equal denominators, **in that interior domain only**. It is not general: it fails at the endpoints 0/1 and 1/1, which lie outside the domain.
- II.5j: isolation iff there is no admissible s, ε.
- II.5j.1: the endpoint congruence s ≡ ±1 mod n; ι(x) = 1 − x is a graph automorphism; isolated vertices come in complementary pairs, except 1/2.

**A7. Finite witnesses (CP-04).**
- Profile (4,2,1): |F| = 7, T_ph = 6, components {1/5}, {1/3, 2/5, 1/2, 3/5, 2/3}, {4/5}.
- Profile (4,3,2,1): connected, with edges 1/5–1/4 and 3/4–4/5.
- II.5k: (9,2) and (8,3) have |F| = 11 and T_ph = 8. (9,2) has 5 components and isolated set {1/10, 1/5, 4/5, 9/10}. (8,3) has 3 components and isolated set {1/9, 8/9}.

Components are proved through a **finite partition certificate** (R3):
- every part is **nonempty**;
- every part is internally connected: **for every pair** of its vertices there is a finite walk joining them whose vertices all stay in the part (equivalently, the induced subgraph is connected). A spanning-tree certificate is acceptable if its soundness is proved;
- coverage and pairwise disjointness of the parts;
- no edge between different parts;
- the isolated set.

A separate, general **bridge lemma** proves a **bijection** between the certificate's parts and Mathlib's connected components (`SimpleGraph.ConnectedComponent`), so the number of parts, singleton parts included, is the number of components. Its exact signature is frozen before proof work. The finite checks use `decide`. No `native_decide`, and no graph semantics beyond Mathlib's and the reviewed bridge lemma.

## 5. Stage B (scoped, not dispatched): exponential lift (CP-03)

E(z) = exp(2πiz). Candidate statements:
- E is injective on the half-open strip 0 ≤ Re z < 1.
- E′ = 2πiE never vanishes, so crossing angles are kept.
- For fractions in (0,1) with q ≥ 2, the images of two Ford circles meet exactly when the circles meet, at E of the kiss point.
- The q = 1 circle at 0 and its translate at 1 have one image that touches itself (at −e^(−π)); this is a **separate self-contact case**.

Domain: Ford circles touch the real axis, so state Stage B on the **closed** upper half-plane for full boundary circles, or treat the real-axis footpoints separately as limits. **DESIGN DECISION before dispatch:** whether Stage B is wanted, and in which form. saphir decides, after Stage A.

## 6. Items the build must establish

| Item | Kind | Resolution or test | Stop rule |
|---|---|---|---|
| Pins and signatures | BUILD MUST ESTABLISH | freeze step and signature freeze (§1) | any pin differs: return for review; signatures unreviewed: no proof work |
| A7 components via certificate | BUILD MUST ESTABLISH | F2 (§8) | If `decide` cannot close the certificate checks within the caps, return the evidence and stop A7 (A1–A6 continue within their own gates). No `native_decide`, no added axioms. |
| A5–A6 statements match the kernel text exactly | BUILD MUST ESTABLISH | statement table in the README, kernel line next to each Lean name | any mismatch: stop that item and return it as a correction-candidate packet (§9); continue the others |
| Stage B timing | DESIGN DECISION | saphir, after Stage A | — |

## 7. Acceptance tests

| Requirement | Test action | Authoritative observation | PASS | FAIL | INCOMPLETE | Cannot establish |
|---|---|---|---|---|---|---|
| Compiles | `lake env lean` on each module against the frozen library | compiler exit code and log | exit 0, no errors | any error | harness fault before a verdict | that the statements are the right ones |
| No gaps | scan sources and the compiled environment | counts of `sorry`, `admit`, `native_decide`, `axiom` declarations | all 0 | any > 0 | — | — |
| Axioms | `#print axioms` on every target theorem | printed axiom lists | only `propext`, `Classical.choice`, `Quot.sound` | anything else | — | soundness of Mathlib itself |
| Strict replay | the pinned checker (§1) | checker report | PASS, zero unsafe or partial target constants | any failure | — | replay of imported dependencies (reused, not replayed) |
| Statement fidelity | an independent reviewer reads each frozen Lean statement against its kernel line in the README table | the table, signed by the reviewer | every row matches | any row misstates scope | rows not reviewed | anything beyond the listed items |
| Library unchanged | `sha256sum -c` on the frozen library before and after | checksum output | OK both times | any change | — | — |

## 8. Bounded feasibility stage (first, time-boxed; CP-04, CP-05)

| Assumption | Feasibility test | Budget | If it fails |
|---|---|---|---|
| F1: the A3 identity and the A4 kiss-point coordinates close with `field_simp` / `ring` / `nlinarith` in ℂ | prove A3's displayed identity and A4's coordinates only | ≤ 30 min wall | return the evidence; stop |
| F2: certificate checks close with `decide` | the (4,2,1) counts **and** the 11-vertex (9,2) partition certificate (nonempty, internally connected parts; R3), with the bijection bridge lemma | ≤ 30 min wall, same job | return the evidence; stop A7 (A1–A6 may continue) |

- The two caps are **serial** exploratory caps: F1, then F2, never in parallel.
- When execution is authorized, record fresh host facts before F1: free capacity, contention, the runner, and the memory, process and output limits.
- The alpha_amplitude logs (3000 MB compile, 8192 MB replay caps, cached builds) are plausible candidate caps, **not** a capacity measurement.
- Scout as fallback needs its own pins and preflight (§1 freeze step) before use.
- F1 passing does **not** establish A6 or A4's uniqueness clause.

## 9. Rules

- Additive only: new files in this package folder `farey_ford_contact_v0_1_20261102/` under `FVLT_FORMALIZATION_v0_1_20261028/`. No edits to the kernel, the library, earlier passes, or any locked item.
- Builds run on nucleus (scout as fallback, after its own preflight) under the capped runners. **No compute on Neo.** G1 is excluded.
- No git commits; no downloads beyond the pinned Mathlib already present; no `python -` / `python -c` (write scripts to files).
- **Stop rule.** These stop the item: compile error, checker failure, wrong axioms, statement mismatch. Harness, path or tooling errors before a verdict do not: log them, fix them, continue, and report once.
- **Kernel discrepancies (CP-06, R1).** A formal theorem establishes its exact proposition under its explicit hypotheses and dependencies; neither compilation nor fidelity review alone decides which prose to correct. A discrepancy triggers independent statement-fidelity **and** mathematical review. Classify it as a translation defect, a scope/hypothesis difference, a prose defect, or unresolved. A proof of the faithful translation confirms that exact claim; a checked counterexample, negation, or other correction theorem may support a prose-correction candidate after its relevance is independently reviewed. A translation defect calls for a corrected formalization, not a kernel correction. Preserve both inputs and report the evidence through the Idea Catalog process. No automatic changes to the kernel or to the target statement follow. This is how saphir's standing rule (verified Lean prevails over kernel prose; corrections via Idea Catalog candidates, 2026-10-30) is applied here.
- **Credit.** The contact law is classical (Ford 1938; Farey; Apostol ch. 5). The phase-mode graph and its fixtures are the kernel's (Robin's (4,2,1) break). Framework line: "the framework was assembled by Robin Miller; its components are classical results of others". No novelty claim.

## 10. Outputs, report and promotion (CP-06)

**Outputs.**
- The two `.lean` modules.
- The frozen-signature file and its hash.
- `README.md`, with the statement table: Lean name → kernel line → standing → reviewer sign-off.
- `NEW_THEOREMS.json`.
- Build and checker logs, and the `#print axioms` output.
- `SHA256SUMS`.
- A receipt of the library checksums before and after.

**Report, in this order.**
1. Governing inputs with digests, including the freeze-step record.
2. Output folder and hashes.
3. The raw verdict, with run ids.
4. Deviations, each with its preserved evidence.
5. Requirements not tested, and why.
6. The exact next decision and its owner.

**Status words, each a distinct step:** RUNNING, FINISHED (build PASS), VERIFIED (skeleton reproduced), FIDELITY-REVIEWED, ACCEPTED, SEALED, installed, released. One step never implies the next.

**Promotion (R1).** Authorization record: saphir, 2026-10-30, to skeleton, "I do want their lean libraries to remain synced after each advance". Recorded in skeleton's working memory (`feedback-sync-library-each-advance`); there is no separate signed record file. Its scope: after skeleton verifies a Lean delivery, the modules go to the Rule 30 tooling session, which builds the next library version on nucleus and scout; skeleton then verifies both hosts (`sha256sum -c`, axioms check, no writable files, files byte-identical to the delivery) and posts a readiness receipt. For FF-1 this authorization applies only after **both** VERIFIED **and** FIDELITY-REVIEWED, and only to library inclusion. Library inclusion is not kernel adoption, a lock, installation or release, and none of those follows from it. The sync goes into the library version current at that time (no number reserved now); if the library has moved past v19, the sync is rebased onto the current version, checked and recorded. If saphir or the formalization owner judges this record insufficient for FF-1, the sync becomes a proposal awaiting separate authorization.
