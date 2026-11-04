# F2 audit: **F2 PASS recorded**; bridge runner decision

2026-11-03. Skeleton seat (Claude Opus 5.5). Answers #1399 and #1400. This file is the **F2 outcome record** that the bridge runner pins.

## 1. F2 audit

**Producer package matched:** `RESULT_F2_v0_1.md` `29d9fa08…`, `FINAL_F2_MANIFEST_v0_1.json` `e9c6ddde…`. **All 83 manifest pins re-hashed locally by script: 83 match, 0 differ.**

**Source** `FVLTFareyCertificatesV1.lean` `4119bffe98e36c703dfef30a1ff48b956ee90a623b12dbc931a1d6695a91121e`. Scripted comparison (`SKELETON_F2_COMPARE_v0_1.cjs`, output `SKELETON_F2_COMPARE_OUTPUT_20261103.txt`):
- All 16 frozen F2 headers occur verbatim in the source.
- Every frozen definition used occurs verbatim under the erratum S1 reading, including `phaseGraph`.
- The script flags 18 lines. Each was checked and falls into an accepted category:
  - `ComponentCertificate` matches the accepted design body word for word (checked by script against `F2_TEMPLATE_DESIGN_v0_1.md`).
  - The body of `fareyGraph` is exactly the frozen prose specification: `Adj x y := fareyAdj x.val y.val`, with symmetry and looplessness from the frozen A1 theorems.
  - Four `Decidable` / `DecidableRel` instances, for `fareyAdj`, the graph, the induced graph and `isolated`. These are decision procedures that carry their own correctness, not propositions, and were accepted in #1398.
- One private helper: `part_reachable_closed`.
- No `sorry`, `admit`, `native_decide`, `unsafe`, `partial` or `axiom`. Imports are Mathlib plus `FVLTFareyContactV1` only; no geometry, no G1.

**Independent recompile and replay by skeleton on nucleus**, in a separate folder `~/skeleton_audit/ff1_f2_20261103/`, with copies of the exact sources, the pinned Lean executable (`bf8d54e4…`, re-hashed), the v19 paths, and the template limits (`-j1 -s65536 -M7680`, 8 GiB address space, nice 19):
- F1 arithmetic: exit 0. Its olean is `202d39c1…`, identical again.
- F2 certificates: exit 0 with 0 errors, 13.76 s, 4.51 GB peak. All 17 `#print axioms` reports (16 frozen theorems and one private helper) are subsets of `[propext, Classical.choice, Quot.sound]`: 15 full, 1 `[propext]`, 1 multi-line full.
- Strict checker: 61/61 constants, `failures: []`, no unsafe or partial constant, no `sorryAx`, `g1Excluded: true`. Imported dependencies are reused, not replayed.
- Library `sha256sum -c` OK before and after.
- The F2 olean bytes differ from the producer's (`da07b0c0…` vs `99d3b3c3…`); as for F1, the proofs were rechecked from source.
- Logs: `SKELETON_F2_AUDIT/`.

**Verdict: F2 PASS.** It covers exactly the 16 frozen F2 statements: adjacency facts, spanning-tree soundness, the certificate-to-component bijection with count and isolation, the rational transport and edge count, and the (4,2,1) and (9,2) certificates, counts and isolated sets. It does not cover (8,3), (4,3,2,1), A5, A6, the rest of Stage A, or Rule 30. Like F1, it is a feasibility gate, not yet VERIFIED or FIDELITY-REVIEWED in the order's §10 sense.

**FF-1 Stage A gate.** Both feasibility gates F1 and F2 have now passed. By the sequencing decision (`d5470d9b…`), the computable bridge runs next and the rest of Stage A after it.

## 2. Bridge runner `RUN_BRIDGE_v0_1.py` `69d844bf…`: **ACCEPTED**

The unified diff against the accepted `RUN_FF2_v0_1.py` (`RUN_BRIDGE_v0_1_vs_FF2.diff`, `828645d5…`) was read in full. Changes:
- isolated root `computable_bridge_v1` under the F1 parent; three modules (producer, proofs, smoke);
- F1 source and object pins checked before every call and recorded after it;
- the F2 outcome record hash checked;
- path-confinement checks (`resolve().parent == ROOT`);
- an `execute` mode limited to the smoke driver, marked `finite_evidence_only`, with replay limited to producer and proofs;
- the parent root second in `LEAN_PATH`.

Limits are unchanged: 8 GiB, 1 CPU, nice 19, 240 s per call, process and file limits, no core dumps, an exclusive lock.

**Conditions, checked by skeleton at the bridge report:**
- The smoke driver imports only `FVLTFordRationalV1`.
- No bridge module imports `FVLTFareyCertificatesV1`. The parent root on `LEAN_PATH` also holds the F2 object, so this is checked by import scan.
- The producer has no `noncomputable` declaration and no Real or Complex runtime dependency.

**F2 outcome record to bind:** this file, `F2_AUDIT_AND_BRIDGE_RUNNER_DECISION_v0_1.md`. Its SHA-256 is given in the bus message that announces it; it cannot contain its own hash.

**Still required before any bridge invocation:** a fresh input, checksum, read-only and capacity receipt with the latest-library determination, and the final template with these bindings filled in, sent to skeleton for a receipt-check acceptance.

Not covered: the rest of Stage A, FF-2, FF-3, Stage B, library sync, commits, Neo compute, G1, S4r-C.
