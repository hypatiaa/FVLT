# FF-1 F2: local compile and strict replay PASS

2026-11-03. **All 16 frozen targets compile; strict replay PASS, 61/61 target constants. Awaiting skeleton's independent audit and recorded outcome.** No bridge invocation has started. F1's accepted source/object pair remains unchanged.

## 1. Governing inputs

- Exact order v0.3, its E1 erratum and Stage A execution-go record govern this phase.
- F1 PASS and sequence decision: `F1_AUDIT_AND_BRIDGE_DECISION_v0_1.md`, SHA-256 `d5470d9b2353ca9de7309064dad363955e567a356fb5075dae04c0f9f32c7526`, #1392.
- F2 template: `F2_JOB_TEMPLATE_v0_1.json`, SHA-256 `d1bffb5df9c8a3e04daf71a6d722cf518f4239e4cad35874f3540886ca2db461`; accepted runner `RUN_FF2_v0_1.py`, `6ebe28fa70fd5b1a68778bf5e6b4b4a254cc3ad975764e6372797231f63c68ef`.
- F2 acceptance: `I3_TEMPLATE_ACCEPTANCE_F2_v0_1.md`, `fe8331fd7bd8753a112f727df197982e1f2b5e4db93d0205d4c1b09995520113`, explicitly permitting bounded proof-body iteration, private helpers and the additive certificate module.
- Frozen signatures: `SIGNATURE_FREEZE_DRAFT_v0_1.md`, `a9382d4054a77d7a569e884b4f7e02b55f7c7e9aa0da2d3a6d1299075ea2b6c7`, unchanged. All 16 target headers appear verbatim in final source.
- Annotation erratum S1: `SIGNATURE_FREEZE_ERRATUM_S1.md`, `03c54bbfa34cb9854f7e10179f50a5e2fa2fdef3332e6886ec2a9613a92f9299`, #1398. Only the phase numerator lambda gains its intended `c : ℕ` annotation; other definition values and all target statements remain unchanged.

Fresh nucleus preflight at 12:13:22Z found latest directory v19, all five expected top-level pins equal, all **381 listed file checksums OK**, zero writable entries among 153937 non-symlink entries, matching Lean executable/compiler and Mathlib identities. The known documentation symlink resolves inside the read-only tree. About 28 GiB was available and load averages were zero. Complete receipts: `F2_INPUT_OBSERVATIONS_v0_1.json`, `F2_LIBRARY_SHA256_CHECK_v0_1.txt`. This is a fresh observation, not inherited F1 evidence.

Library root `/home/saphir/rule30_theorem_library/v19`; SHA256SUMS `e25d4d54d074f152c452aa7247ccbe992e14b29d58306809660a75770ae7ddd5`, manifest `f0ee6b00fe4a622b63cac1f4fb24146e9b2808bdb0fb430ebdac074fecb258fa`. Full remaining input hashes are in the accepted input/template and re-observation receipt. Runtime is Lean 4.35.0, Mathlib `56a005855ea17e0b0958f73ec801ae140b0a1679`, executable `bf8d54e4714cc4b03d3f6bb34c83b7202b87e49c8bfcbff6895c085bb90ceb38`, checker `9c6f2ac11b50fdb846df2d5099ea673553903275a5dba11fce5a5673cae14bd0`.

## 2. Final source and object

`FVLTFareyCertificatesV1.lean` source SHA-256:

`4119bffe98e36c703dfef30a1ff48b956ee90a623b12dbc931a1d6695a91121e`.

Compiled object on nucleus:

`99d3b3c3a44d0f4b4aa020e0e797dff255eddddb0459b7b1e4a3b7fad8ef651e`.

Isolated dependency: F1 arithmetic source `2760392f984bd1375169920a702ae53c13115ddfb36d71bae36b3855950d1e4b`, object `202d39c1c940eef0a6cd23ea422e251df2d9e111255bbc460cb14650c8f042e8`. Geometry is not imported. Only standard Mathlib imports and this exact isolated F1 module are used. No library file or F1 theorem source was edited.

## 3. Proved scope

All 16 accepted headers are proved:

- symmetry/irreflexivity and the exact graph-adjacency bridge;
- generic parent/depth spanning-tree soundness;
- generic certificate-part/Mathlib-component bijection, component cardinality and isolation;
- exact ordered-pair contact count = Mathlib edge-set cardinality;
- rational-part subtype transport preserves component counts under the explicit subset guard;
- (4,2,1): exact seven-vertex phase set, actual three-part certificate, 7 vertices/6 contacts/3 components, isolated set {1/5,4/5};
- (9,2): actual five-part certificate, 11 vertices/8 contacts/5 components, isolated set {1/10,1/5,4/5,9/10}.

The certificate predicates retain nonempty parts, coverage, pairwise disjointness, connectedness of each induced graph, and no cross-part edges. The generic bijection connects these actual certificates to `SimpleGraph.ConnectedComponent`; component counts are not just separate numerical observations.

`spanning_tree_connected` is proved in full generality by well-founded induction on the stated depth. The one private helper, `part_reachable_closed`, proves that reachability cannot leave a certificate part. The bijection selects a vertex in each nonempty part and proves its component assignment is bijective, with the required vertex-identification property. `certificate_isolation` and transport/count statements have their exact frozen domains, including empty-type cases where applicable.

## 4. Finite reduction method, repairs and raw results

The initial bare `decide` reductions stalled on rational/finite-set normalization. `decide +kernel` closes these checks inside Lean's kernel; it is not native_decide and introduces no `Lean.ofReduceBool` dependency. Fixture connectedness uses Mathlib's proved finite-walk decision (length < vertex cardinality). It checks the actual induced-connectedness clauses. This replaces the initially suggested explicit parent tables; S1 explicitly accepts that implementation, while the separate frozen spanning-tree theorem is still proved. No unbounded existential-walk decider is assumed.

The first source failed because the frozen phase image lambda lacked a natural-number binder annotation and because of constructor/instance/proof issues. The phase definition was held unchanged until S1's explicit acceptance, then received only `: ℕ` on that binder. Further ordinary bounded iterations supplied the current `Std.Symm`/`Std.Irrefl` constructor forms, explicit decidability instances, graph constructor proof, and finite clause decomposition. Four auxiliary instances cover rational adjacency, graph adjacency, induced graph adjacency and isolation; they do not alter the declared predicates. No source sorry/admit, extra axiom, native_decide, unsafe or partial target was introduced.

| Run | Exit | Seconds | Peak child RSS KiB |
|---|---:|---:|---:|
| F2Compile01 | 1 | 12.635337 | 3576672 |
| F2Compile02 | 1 | 2.524968 | 3496704 |
| F2Compile03 | 1 | 2.168125 | 3513604 |
| F2Compile04 | 1 | 2.268603 | 3515248 |
| F2Compile05 | 0 | 13.832431 | 4510500 |
| F2Replay01 | 0 | 15.686853 | 4645744 |
| F2Compile06 | 0 | 13.834419 | 4510680 |

All failures and every before-call source snapshot, concrete manifest and owner acceptance log are preserved. Failed-compilation error-recovery `sorryAx` output is historical failure evidence only, never proof acceptance.

Compile06 differs from successful Compile05 **only by adding the explicit `#print axioms` for the private helper**. Every definition and proof is identical, and both emit the **same byte-identical object hash** above. Replay01 checked that exact object. No redundant second replay was run; the receipt pins Compile05's source while Compile06's receipt independently proves that the final source emits the identical replayed object. Both source snapshots and logs are included for this provenance check.

Final compile prints allowed axioms for all sixteen targets and the private helper: subsets of `propext`, `Classical.choice`, `Quot.sound`. Strict checker: **61/61 constants audited and replayed; PASS; zero unsafe/partial constants, zero failures, G1 excluded**. Those 61 include generated constants and instances, not 61 written theorems. Imported dependencies are reused, not replayed. Two harmless final linter warnings remain; diagnostic `#print` output of the standard graph definitions is retained.

## 5. Capacity, timing and integrity

All mathematics ran serially on nucleus via explicit Tailscale `100.105.106.41`, using the accepted 1 CPU/nice19/8GiB/240-second-per-call limits. No higher-memory amendment, parallel run, download or dependency build occurred. F2 drafting started unix1793708107 with its own 1800-second budget. Only a conservative 45-second review wait (bus request1397 timestamp1793708586 through S1 timestamp1793708631) was excluded; the actual request preceded its relay, so this does not overstate the permitted exclusion. Final deadline unix1793709952. All successful computation completed before it, with no F1 allowance transferred.

Every call's complete post-check reports all 381 library pins OK and source bytes unchanged. Final regular-file/directory mode scan found no writable entries; top-level library hashes and F2 object hash are recorded in `F2_FINAL_READONLY_AND_PINS.txt`. All relevant before/after evidence is pinned in the F2 manifest.

## 6. Standing and next decision

**Local F2 compile/replay PASS is ready for Opus's audit.** The full manager-audited F2 outcome is not yet recorded by this producer report. Opus should independently recompile/replay and review the exact headers, S1 annotation and certificate semantics, then record the outcome.

Next is the computable-coordinate bridge, under its already reviewed twelve-link paperwork, **after F2's outcome is recorded and the actual bridge runner/final input/template bindings are accepted**. No bridge invocation has occurred. Remaining Stage A, final statement-fidelity/verification, FF-2, Stage B and any library inclusion remain separate. No Rule 30, Dirichlet, quantum-speed or kernel-adoption claim follows.
