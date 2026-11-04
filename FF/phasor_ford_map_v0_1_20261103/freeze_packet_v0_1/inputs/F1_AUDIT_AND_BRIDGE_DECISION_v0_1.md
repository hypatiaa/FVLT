# F1 audit: **F1 PASS recorded**; computable bridge decision

2026-11-03. Skeleton seat (Claude Opus 5.5). Answers #1390 and #1391.

## 1. F1 audit

**Producer package matched:** `RESULT_F1_D2_v0_1.md` `a9d85270…`, `FINAL_F1_D2_MANIFEST_v0_1.json` `95a74c7e…`. **All 125 manifest pins re-hashed locally by script: 125 match, 0 differ.**

**Sources** (final): `FVLTFareyContactV1.lean` `2760392f…`, `FVLTFordGeometryV1.lean` `0b380fd6…`.
- Scripted comparison (`SKELETON_HEADER_COMPARE_v0_1.cjs`): both F1 target headers, `radius_pos`, and every frozen definition (bodies line by line) verbatim; 0 failures. Differences from the frozen text are exactly the ones authorized: added Mathlib imports (D1), `noncomputable section` (D2), and four `private` helpers `centre_re`, `centre_im`, `kiss_re`, `kiss_im` (D2). No `sorry`, `admit`, `native_decide`, `unsafe`, `partial` or `axiom`.

**Independent recompile and replay by skeleton on nucleus**, in a separate folder `~/skeleton_audit/ff1_f1_20261103/`, with copies of the exact sources and the pinned checker (`9c6f2ac1…`), the pinned Lean executable (`bf8d54e4…`, re-hashed), the v19 library paths, and the template's limits (`-j1 -s65536 -M7680`, address space 8 GiB, nice 19):
- Arithmetic: exit 0, 0.73 s, 1.66 GB peak. Olean `202d39c1…`, identical to the producer's.
- Geometry: exit 0, 1.91 s, 3.49 GB peak. `#print axioms`: `radius_pos`, `ford_distance_identity`, `kiss_membership` each depend only on `[propext, Classical.choice, Quot.sound]`.
- Strict checker: arithmetic 2/2 constants, geometry 20/20 constants, `failures: []`, no unsafe or partial constant, `g1Excluded: true`. Imported dependencies are reused, not replayed (`fullDependencyReplay: false`), as the order states.
- Library `sha256sum -c SHA256SUMS` OK before and after.
- The geometry olean differs from the producer's (`ad15585a…` vs `ea5dc4ce…`). Olean bytes are not a reproducibility target here; the proofs were rechecked from source.
- Harness note: skeleton's first rerun aborted ("failed to create thread") because it omitted the runner's `-s65536` stack flag under the address-space limit. That was skeleton's harness error, corrected before the recorded run.
- Logs: `SKELETON_F1_AUDIT/`.

**Verdict: F1 PASS.** It covers exactly the frozen `ford_distance_identity`, `kiss_membership` and `radius_pos` (with the frozen definitions), within the cap. It does not cover kiss uniqueness, A6, the rest of Stage A, or Rule 30. F1 is a feasibility gate: it is not yet VERIFIED or FIDELITY-REVIEWED in the order's §10 sense.

## 2. Computable coordinate bridge (saphir's request, #1391)

Proposal `COMPUTABLE_COORDINATE_BRIDGE_PROPOSAL_v0_1.md` `e0593acc…`, read in full. **Accepted as the design direction.** saphir confirmed it to skeleton in chat on 2026-11-03: "Yes. The proposed layer computes exact rational coordinates and proves they embed into the existing radius, centre and kiss definitions."

**Skeleton's checks:**
- Sage: on all reduced rationals with denominator ≤ 12 and numerator in [−2q, 3q], adjacency ⇒ the rational kiss point satisfies `boundaryQ` for both circles. For x ≠ y the converse also holds: the kiss point lies on both boundaries iff the pair is adjacent. The embedding identity (N + i)/M = N/M + i/M holds.
- Fixtures: radiusQ(0) = radiusQ(1) = 1/2, radiusQ(1/2) = 1/8, radiusQ(−3/4) = 1/32. kissQ(1/2, 1/3) = (5/13, 1/13), on the boundary of 1/2. kissQ(1/3, 1/5) is not on the boundary of 1/3.

**Sequencing decision:** F2 runs next, as the gate it is. The bridge comes next as a separately bounded extension, before the rest of Stage A. Its paperwork (scope, pins, signature freeze, template) may be prepared now without compute, and reviewed by skeleton. Its builds start only after F2's outcome is recorded. No parallel builds.

**Bridge gates and notes:**
- Own input freeze: F1's accepted source/object pair is pinned as an isolated dependency; the library is not promoted.
- Own signature freeze for the 12 link statements, after API inspection.
- Own job template.
- Executable smoke fixtures preregistered (the six above plus expected values), kept out of theorem modules.
- `#print axioms` and the strict checker on the theorem module.
- Optional extra target for the freeze: the converse `boundaryCheckQ x (kissQ x y) = true ∧ boundaryCheckQ y (kissQ x y) = true → x ≠ y → fareyAdj x y`. Sage supports it, but it is not required.

**Not covered:** F2 still needs its own accepted template; also not covered are the remaining Stage A, FF-2 (after Stage A), Stage B, library sync, commits, Neo compute, G1, S4r-C, and viewer edits.
