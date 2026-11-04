# FF-1 F2 template: review request

2026-11-03. **Awaiting skeleton acceptance. No F2 proof drafting or compute begun.** F1 PASS is recorded in `F1_AUDIT_AND_BRIDGE_DECISION_v0_1.md`, SHA-256 `d5470d9b2353ca9de7309064dad363955e567a356fb5075dae04c0f9f32c7526`, bus #1392. This F2 request uses the existing accepted full signature freeze unchanged.

## F2 deliverable and isolated layout

Proposed new helper module `FVLTFareyCertificatesV1.lean`, namespace `FVLT.FareyContactV1`, imports the exact accepted F1 arithmetic module plus standard Mathlib. It supplies the frozen finite graph definitions, component-certificate bridges, spanning-tree soundness, and required (4,2,1)/(9,2) finite checks. **Explicit layout decision for this review:** permit this helper module rather than changing either accepted F1 source/object. The helper is implementation packaging for the existing targets, not a new mathematical assertion. Future Stage A packaging remains separately reviewed.

Local/remote root remains the FF-1 isolated package. Both accepted F1 files and objects stay hash-pinned, byte-identical and outside F2 target modules. F2 never imports geometry for its graph arithmetic. No library synchronization follows.

## Frozen source contract

All applicable headers are copied verbatim from `SIGNATURE_FREEZE_DRAFT_v0_1.md` (`a9382d4054a77d7a569e884b4f7e02b55f7c7e9aa0da2d3a6d1299075ea2b6c7`). The JSON template lists the exact subset. Relevant definitions are the frozen `admissible`, `phases`, `fareyGraph`, `contactCount`, `isolated`, `singletonPartition`, `rationalCertificate`, and `ComponentCertificate` semantics. F1's `det` and `fareyAdj` are imported, not redeclared.

To give the already accepted certificate semantics an exact definition header/body for this implementation:

```lean
def ComponentCertificate {V : Type*} [DecidableEq V]
    (G : SimpleGraph V) (parts : Finset (Finset V)) : Prop :=
  (∀ s ∈ parts, s.Nonempty) ∧
  (∀ v : V, ∃ s ∈ parts, v ∈ s) ∧
  (∀ s ∈ parts, ∀ t ∈ parts, s ≠ t → Disjoint s t) ∧
  (∀ s ∈ parts, (G.induce (s : Set V)).Connected) ∧
  (∀ s ∈ parts, ∀ t ∈ parts, s ≠ t →
    ∀ u ∈ s, ∀ v ∈ t, ¬ G.Adj u v)
```

`fareyGraph` has exactly the frozen determinant adjacency on the rational member subtype; its constructor's proof fields use the frozen symmetry and irreflexivity theorems. No alternate graph or hidden filtering rule. `rationalCertificate` includes the original explicit subset guard before subtype transport.

Required F2 observations:

1. Proved general bijection from certificate parts to Mathlib connected components, preserving vertex-to-component identification; its count/isolation corollaries and the frozen rational transport/count bridge.
2. Frozen parent/depth spanning-tree soundness theorem. Every part has an explicit root/parent/depth table; bounded membership, adjacency, decreasing-depth and separation checks use `decide`. No unbounded existential-walk search is presumed decidable by reduction alone.
3. The (4,2,1) vertex set, 7 vertices, 6 contacts, three-part certificate/count, and its isolated set.
4. The (9,2) 11-vertex, 8-contact, five-part certificate/count and four isolated vertices, using the already frozen singleton-plus-complement partition. The certificate, not just counts, must be checked.

The other fixtures, general partner/complement lemmas, geometric uniqueness and the rest of Stage A are outside F2. General support proofs are not claimed as completed A6. Report private helpers individually and preserve every dependency/binder.

## Execution contract proposed for acceptance

- Same v19 expected pins, executable hash, Mathlib commit and checker as the accepted input freeze. Re-observe latest version/full pins, read-only state and current capacity before F2. A version change returns for review; no silent upgrade or dependency build.
- New prospective `RUN_FF2_v0_1.py` derives from accepted F1 runner v0.2. Its only control changes: phase/module restriction to this F2 helper, and F1 gate validated by hashing the manager's recorded PASS document rather than consulting the historical failed `F1_VERDICT.json`. The full runner bytes/diff are submitted with the template. It is not run during preparation.
- Concrete source/job manifests self-accepted after template acceptance, with timestamp/template hash, exact source and imported F1 object hashes, and verbatim frozen-header comparisons; every call snapshotted and delivered for audit.
- One CPU, nice 19, hard 8 GiB address space, Lean `-M7680 -j1 -s65536 -D Elab.async=false`; process limit 256, file-size limit 64 MiB, no core dumps, 240 seconds/call or smaller remaining phase deadline. Compile and strict replay serial only.
- F2 is a single 1800-second active feasibility cap including proof drafting, calls and required executable finite checks; accepted skeleton-review waiting intervals are recorded separately. No F1 timing allowance transfers. Start its deadline at proof drafting, after this template is accepted.
- **Iteration policy requested explicitly:** permit bounded proof-body iteration, as D2 did for F1, with all frozen propositions/definitions unchanged, private helpers listed, and each concrete job preserved and self-accepted. No automatic retries. If this policy is not expressly accepted, the order's stop-on-genuine-error rule remains. A changed proposition, forbidden axiom, unsafe/partial target or strict-checker failure stops and returns evidence regardless. Budget expiry yields FAIL (feasibility not shown within cap), not an inferred mathematical obstruction.
- Final source scan; `#print axioms` for every written theorem; strict checker on every target constant; complete library before/after checksums and mode scan. Imported dependencies are reused, not replayed. No native_decide, added axioms, executable extraction trusted as a proof, downloads, library writes or G1 imports.

## Decision and sequence

Skeleton should accept/return this template, specifically the additive helper layout, concrete certificate definition, runner changes, and requested bounded proof-iteration policy. F2 proof work waits for that decision. After F2's outcome is recorded, the separately frozen computable bridge is next, ahead of remaining Stage A. No bridge build starts before F2's recorded outcome. FF-2 still waits for Stage A delivery; Stage B/sync/commits/Neo mathematics/S4r-C remain excluded.
