# FF-1 R2: geometry continuation template

2026-11-03. **Awaiting Opus receipt check. No R2 proof drafting, source, build or replay.** Robin's Stage A go and the continuation plan remain in force. Manager R1 PASS is recorded in parent `R1_AUDIT_v0_1.md`, SHA256 `823f7386d567a7dbf8b1c5c43e81c85cf8876ce0927c1bc85b9430134317a48d` (#1415 / accepted ledger 1418), read in full and independently hash-matched. The manager-audited count is 26 of 60.

## Exact scope and layout

One additive `FVLTFordGeometryCompletionV1.lean`, namespace `FVLT.FordGeometryV1`, imports the audited R1 arithmetic completion, the original F1 geometry and standard Mathlib. The original namespace `FVLT.FareyContactV1` is opened for determinant/adjacency names. No predecessor file is edited, copied over or redeclared. No bridge or G1 import is required.

The eight target headers are exactly the R2 rows of the already accepted coverage table and original signature freeze:

1. `ford_open_disjoint` — distinct rationals have disjoint open disks.
2. `ford_boundary_disjoint` — determinant absolute value at least two gives disjoint boundaries.
3. `ford_tangent_iff` — the frozen singleton-intersection tangency predicate iff Farey adjacency, under explicit distinctness.
4. `ford_real_axis` — a Ford circle's real-axis intersection is its rational footpoint.
5. `kiss_unique` — adjacent boundaries intersect in exactly the frozen kiss singleton.
6. `two_squares` — the integer two-squares determinant identity.
7. `kiss_integer_identity` — its determinant-one specialization for the frozen kiss numerator/denominator.
8. `kiss_real_identity` — the corresponding real cast.

All eight headers occur verbatim in `R2_JOB_TEMPLATE_v0_1.json`; every hypothesis is an explicit binder. The three new definitions are exactly the already frozen `disk`, `realAxis` and `tangent`. Existing `radius`, `centre`, `boundary`, `kissN`, `kissM` and `kiss` are imported from F1 unchanged. Noncomputable real/complex definitions are allowed as in F1; this chunk makes no executable-real-geometry claim.

Two-squares and general geometry are classical helper results supporting II.5b, not newly assigned kernel claims. Kiss uniqueness is a genuinely stronger result than the already audited membership theorem. Until independently proved and checked it remains an obligation, not a consequence of F1 or the rational bridge.

## Mechanical continuation of the accepted R1 template

`RUN_R2_v0_1.py` derives from the accepted R1 runner. The supplied complete diff changes only R1 phase/module/artifact constants to R2 and adds two R1 source/object predecessor pins and the R1 PASS gate. `PARENT` and isolated `ROOT` are unchanged; R2 output has its own module, jobs, logs, review and deadline names. The parent serial lock remains shared. The R1 files in `stage_a_completion_v1/` are pinned through explicit relative paths from the parent. Accepted producer object `ab3351ff…` is used; Opus's differently built audit object is not silently substituted.

No cap, mode, deadline arithmetic, checksum logic, command, process policy or replay semantics is changed. The same current-library mismatch stop applies. All eight predecessor source/object pins and all four PASS records are checked before and after calls. Strict replay covers every R2 declaration, including private helpers and generated auxiliaries; imported dependencies are reused.

Same requested/previously accepted policies: one fresh 1800-second active cap beginning at R2 proof drafting; no transferred allowance; one CPU, nice 19, 8 GiB address space, Lean `-j1 -s65536 -M7680 -D Elab.async=false`, 240 seconds per call or the smaller remaining deadline, process cap 256, file/output cap 64 MiB, no core dumps, no automatic retries. Bounded proof-only iteration, listed/replayed private helpers and decidability instances, timestamped concrete self-accepted manifests and preserved failed snapshots follow the R1 policy. Changed propositions/definition values, forbidden axioms, unsafe/partial declarations, strict-checker failure, integrity drift or budget expiry stop and return evidence. Review-wait exclusions require preserved records under the accepted policy.

## Fresh binding and dispatch

This template contains expected pins only. After the receipt check, perform metadata-only fresh latest-library determination, full expected/observed library/compiler/Mathlib/checker/runner/predecessor/gate checks, full checksums, read-only scan and capacity check on nucleus through explicit Tailscale. An unchanged value means exact byte/identity equality, not a compatible version assumption. Any mismatch returns for review before proof work.

Under the manager's continuation rule, request the same **all-match bound-template acceptance on bus posting** as R1: post the bound template and receipt hashes once and verify delivery before drafting starts. No additional approval is inferred before that gate. The expected draft, new bound artifact and all observations remain separately preserved.

## Delivery and exclusions

Deliver a closed packet with all eight target/theorem headers and three definition values compared verbatim, all attempts and snapshots, axiom prints on every target and private helper theorem, strict all-constant replay, predecessor and library integrity receipts, current standing/source map and exact next decision. Opus independently recompiles and replays before manager R2 PASS. No claim of whole Stage A completion or §10 VERIFIED/FIDELITY-REVIEWED status follows.

R3–R5 still have their own templates and dispatch gates; final all-60 integration/fidelity stays separate. No Stage B, FF-2/FF-3 execution, synchronization, commit, viewer change, Rule 30 result, G1, kernel adoption, installation or release is authorized here. The framework was assembled by Robin Miller; the Farey/Ford components are classical results of others, credited in the module header.
