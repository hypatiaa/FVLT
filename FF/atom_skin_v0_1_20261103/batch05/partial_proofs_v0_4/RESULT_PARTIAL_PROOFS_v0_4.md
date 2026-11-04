# FF-2 Batch05: pen dynamics, producer result

**20 of 28 frozen FF-2 targets now pass producer compilation, named axiom checks and strict kernel replay. 8 remain open.** Independent rebuild/replay and meaning review remain pending. FF-2 has no final recorded outcome; FF-3 builds remain held.

For every omega with the explicit hypothesis 3 <= omega, and every fixed sign and initial state, the pen chooses an adjacent direction, returns to its full state after four steps, and never returns after one, two or three steps. The state includes both the Boolean vertex and the incoming direction. The same sign is used throughout the iteration. These statements make no claim about arbitrary sign streams or Rule 30.

Current public pen targets: pen_adjacent_seat, pen_return_four, pen_no_earlier_return, pen_four_corners. The four visited vertices are exactly the corners of one square in the frozen finite structure. The proof uses toggle involutions and commutation, and treats both cyclic adjacent-direction cases. Square orientation remains open.

## Evidence

Latest pen source SHA-256: 463459058041bb209cf9c8eea99b0e0d4c8948aec32f5b76e4530cf9765ba1c3

Compiled object: a5de881f70886dfa07256cd560688f56301f4f0d17066c5b760354f0e9a9b6a4

Strict replay receipt: 9f85c79f03ecd7e49375a05d50a1c8507f99f25c05279fcdde534f1fc92894c4

Raw strict replay log: 1add6bc0db947eb33a825dcf61395cdc06a7964173fc84818d496bcbee5463b0

Compile time: 1.51791453361511 seconds. Strict replay time: 2.16795563697815 seconds. All 61 introduced declarations, including private helpers and generated declarations, replayed: verdict PASS, kernelReplayCompleted true, no failures, no unsafe or partial constants. Dependencies were reused, not cold-built or replayed by this call. This is producer execution using the strict checker, not the pending independent reviewer's execution.

The raw named axiom log was read in full:

    'FVLT.AtomSkinV1.pen_adjacent_seat' depends on axioms: [propext, Classical.choice, Quot.sound]
    'FVLT.AtomSkinV1.pen_return_four' depends on axioms: [propext, Classical.choice, Quot.sound]
    'FVLT.AtomSkinV1.pen_no_earlier_return' depends on axioms: [propext, Classical.choice, Quot.sound]
    'FVLT.AtomSkinV1.pen_four_corners' depends on axioms: [propext, Classical.choice, Quot.sound]

The retained count module has 47 checked declarations and 10 public targets. The retained pillowcase module has 37 checked declarations and six public targets. Their historical checks remain tied to their exact earlier sources and objects. The data modules retain 108 previously checked declarations. No new integrated rebuild or replay of these separate modules is claimed.

## Freeze, attempts and execution

All public statements retain the original 28-header freeze b4484f6e148291dd20512e58ce4ec81b4bdf08527f4bd66b3e304cbb2654785a under manifest 22650c5b0304d82bfd7d89a1bcfcb20884f6c11d104729aaf8187e678efd02c5. Skin definitions retain the accepted a1ea047d successor; pillowcase definitions retain the original freeze. Every new support declaration is private. No public helper or extra instance was added.

Failed proof attempts and raw diagnostics are preserved additively under evidence/attempts and evidence. Their dependent checks were not run. Pen01 and Pen02 required tactic repairs, with no statement or data change. Pen04 and Pen05 failed on library lemma naming and simplifier order; their sources, logs and receipts are preserved. Pen06 repaired only the private proof bodies and passed all checks. Exact job posting preceded every launch: Pen01 1481/1484, Pen02 1482/1485, Pen03 compile 1483/1486, Pen03 verification 1484/1487; Pen04 compile 1486/1489, Pen05 compile 1487/1490, Pen06 compile 1488/1491, and Pen06 verification 1489/1492. All these receipts preceded their corresponding launches.

All mathematical execution used nucleus via Tailscale, pinned library v20, Lean 4.35.0, unchanged runner 6a73ec37 and checker 9c6f2ac1, one CPU, 8 GiB address space, 240 seconds per child, and explicit toolchain PATH. Every completed call checked all 392 library entries plus source/review pins. No mathematical computation ran on Neo; no library, kernel or viewer write, publication, commit, or G1 work occurred.

Batch05 origin 1793764729, deadline 1793766529, last child end 1793766495.98195. Capacity refreshes did not reset or extend the batch. BATCH05_CLOSE_v0_1.json closes mathematical calls under this clock. A further development batch requires a fresh posted binding and capacity receipt.

## Remaining targets

- FVLT.AtomSkinV1.incident_pair_distinct
- FVLT.AtomSkinV1.incident_pair_exhaustive
- FVLT.AtomSkinV1.incident_square_count
- FVLT.AtomSkinV1.link_cycle
- FVLT.AtomSkinV1.incident_coefficients_opposite
- FVLT.AtomSkinV1.total_boundary_zero
- FVLT.AtomSkinV1.pen_oriented_square
- FVLT.PillowcaseV1.key_classifies

The remaining work separates into square incidence, cyclic links, boundary orientation/cancellation, pen orientation, and the complete pillowcase key classification. These remain genuine proof obligations. Counts alone do not certify a topological surface or its genus, and arithmetic pillowcase classes alone do not certify the viewer's full key.

The full predecessor packet is preserved byte for byte. This successor changes only producer progress and evidence, with no kernel adoption or stronger mathematical standing. Credit: Robin Miller assembled the framework from classical components; no novelty claim is made.

