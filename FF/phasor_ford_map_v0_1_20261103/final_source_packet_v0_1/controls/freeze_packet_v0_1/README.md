# FF-3 proposed freeze: lifted rosette addresses and Ford endpoints

2026-11-04. **Awaiting input/signature/template/runner acceptance. No FF-3 proof has been drafted, compiled or checked.** Robin's execution go is already recorded; the remaining gate is the technical review required by the accepted work order.

The proposed first pass defines a map from lifted data to the audited Ford circle at its exact rational address. It separates the general rational-spin phase law from integer-spin divisibility, proves signed reduced-determinant laws, constructs the deduplicated finite shell sweep, and gives exact rational endpoints on tangent steps of a finite address path. It does not construct oriented continuous arcs.

## Review artifacts

- FF3_DEFINITIONS_PROPOSED_v0_1.lean.txt: 19 explicit data declarations, including the guarded lifted-data record, the actual address/phase formulas, the finite event/Farey sets and the path classifier/certificate.
- FF3_HEADERS_PROPOSED_v0_1.lean.txt: 37 proposed exact theorem headers, with all hypotheses as explicit binders.
- TARGET_INDEX_v0_1.json: module assignment and proposed standing for every target, plus the data-module axiom-report inventory.
- INPUT_FREEZE_v0_1.json and REFERENCE_PINS_v0_1.json: expected/observed current pins, governing authority, historical/current kernel inputs and read-only observation scope.
- INPUT_LIBRARY_SOURCE_CLOSURE_v0_1.json: six inherited project sources, matched to v21, with imports and hashes. No G1 project dependency is present.
- JOB_TEMPLATE_v0_1.json, RUN_FF3_v0_1.py and unchanged IndependentFVLTReplay435.lean: prospective execution machinery, not a live accepted job.
- REVIEW_REQUEST_v0_1.md: the concrete review request, including proposed binding and proof-only repair policies that need explicit reviewer acceptance.

The example acceptance has null decisions and no accepted jobs. No live REVIEW_ACCEPTANCE.json, bound template, source-proof directory, execution deadline or concrete execution job is supplied. The runner has only been parsed as Python text; it was not imported or executed. Static validation is not Lean elaboration.

## Proposed modules and obligations

| Module | Theorem targets | Scope |
|---|---:|---|
| FVLTRosetteFordDataV1 | 0; 19 explicit data declarations | Lifted data, exact formulas, finite sets, classifier and certificate |
| FVLTRosetteFordPhaseV1 | 5 | General real-axis law, explicit integer-spin specialization/parity, amplitude-independent circle map, non-descent example |
| FVLTRosetteFordArithmeticV1 | 15 | P1–P4: integer-address contacts, divisor windows, zero cases, reduced determinant multiplication/quotient, row/column tangent laws and unit-fraction spine |
| FVLTRosetteFordSweepV1 | 9 | P5: shell contact parametrization, physical-contact bridge, event membership, Farey membership/set equality, strict list and consecutive signed determinant |
| FVLTRosetteFordEndpointsV1 | 8 | P6: zero determinant iff equal addresses, classifier iff laws, exhaustive/exclusive path cases and exact tangent-only certificates |

All sources and public declarations remain review text until acceptance. Later proof-only helpers must be private. Extra imports needed for elaboration will be recorded as boilerplate under the accepted review policy; a changed public proposition or mathematical data body returns for review.

## Current inputs and earlier prerequisites

The accepted order is WORK_ORDER_v0_2.md (5b41c955...), with design review cd0ecc9a... and the direct advance execution go 1035988d.... The 2026-11-04 root relay of Robin's new “Go for FF-3” is recorded separately. The FF-2 final audit PASS and v21 readiness receipt are pinned as prerequisite evidence.

Current library v21 was read on nucleus over Tailscale: all 397 checksum entries pass, no path is writable, and the six project dependencies match the inherited audited sources. The complete checksum output is retained under inputs/library_metadata. Lean is 4.35.0, executable bf8d54e4..., with Mathlib revision 56a005855ea17e0b0958f73ec801ae140b0a1679. The actual package configuration is lakefile.toml and is pinned. Moving from the design's older library snapshot is explicitly submitted for review here.

The historical v3.3.1 kernel and current locked v3.4.0 kernel are both included. Section II.5 is identical between them. The existing §9.4 row has interpretive standing. This new discrete construction could support a future narrowly scoped candidate after verification; no historical kernel text is edited or retroactively declared false.

## Mathematical boundaries

The circle map depends on t2, s and n3 through their rational address. Its data are lifted: equal complex phasor values do not recover an unwrapped address. The real-axis theorem uses the full phase address and a nonzero amplitude. Negative integer spin uses an integer power of -1. The scalar amplitude r is not n6; no negative-scalar/y-reflection identification is made.

The standalone helper formulas are total Lean functions. Their geometric operating domain is restricted by LiftedData.hn3 and the theorem guards. n3 = 0 is not a lifted operating point. Rational shell contacts and integer-address contacts are kept distinct.

P5's finite shell-event set is connected by a proposed theorem to the actual contact predicate, not identified by a caption. Address deduplication occurs before sorting. The general Farey-neighbour theorem must be proved; the historical B=40 finite check and the unaudited Lemma 6a are not proofs or assumptions. No B=0 extension is claimed.

P6 uses one circle at m=0 and no edge indices. Every nonempty edge has exactly one declared case. Only tangent edges receive exact rational kiss points certified on both circles. Two neighbours of an interior circle need not be adjacent to each other; retracing and stalls are permitted. No arc choice, whole-arc membership, parametrization, continuity or dynamical transfer is asserted.

No factoring/computational advantage, Rule 30 forcing, harmonic/Hasse register identification, viewer implementation certification, kernel adoption, library publication, commit, hosted checking or release is part of this packet.

## Verification and execution gates

After acceptance, each development batch gets its own fresh nucleus capacity/reservation, hash-bound template, original 1800-second deadline and exact prospective jobs posted before launch. The proposed child limits are one CPU, 8 GiB address space, -j1 -s65536 -M7680, 256 processes, 64 MiB output files and at most 240 seconds per child. A capacity refresh never resets a batch clock. No parallel builds and no mathematical execution on Neo.

Compilation, raw named axiom reporting, strict all-constant replay and independent semantic/fidelity review are separate results. Data modules and generated/private declarations receive nonempty strict replay. Only propext, Classical.choice and Quot.sound are accepted axioms. Imported dependencies are reused, not replayed or cold-built by those calls.

The static validator initially treated proposition-level let assignments as theorem bodies; its text check was corrected to distinguish them. Definitions and headers did not change for that validator repair. No Lean attempt or mathematical verdict occurred. STATIC_VALIDATION_v0_1.json records only the resulting text/JSON/Python-grammar checks.

Framework: Robin Miller. The components and Ford/Farey contact mathematics are classical results of others; no novelty claim is made.
