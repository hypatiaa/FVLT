# FF-2 Batch06: square incidence, links and boundary cancellation

**27 of 28 frozen targets have passed producer compilation, named axiom checks and strict kernel replay. One remains open.** Independent rebuild/replay and meaning review remain pending. This is not the final FF-2 outcome. FF-3 builds remain held.

## What the new counts proofs establish

For every omega with the explicit hypothesis 3 <= omega, each edge has exactly two distinct incident squares in the selected cyclic square structure. They are the squares labelled by the edge direction and its predecessor. The boundary coefficient is nonzero exactly for those two squares. One coefficient is epsilon at the edge's lower vertex; the other is its negative. Summing all square boundaries therefore gives zero as an exact finitely supported integer chain.

The link at every vertex is exactly the cycle on the labelled directions: i and j are linked precisely when j is next(i) or i is next(j). For the forward direction, a square's four corners keep every coordinate outside its two axes unchanged, so a toggle between corners must use one of those axes. The converse constructs the square explicitly. These are uniform theorems, with no bounded enumeration.

This completes all 16 frozen counts-module targets. It proves local combinatorial incidence, cycle links, and an algebraic orientation certificate. It does not construct a Lean topological realization, classify a surface, or identify the numerical genus invariant with a topological genus. The selected squares use cyclic neighbouring directions; they are not all two-dimensional faces of a higher-dimensional cube.

The pen module now proves all five frozen targets, including pen_oriented_square. For each state and fixed sign, its incoming and outgoing directed edges belong to one square and agree with that square boundary multiplied by the same sign. This identifies orientation, beyond the earlier four-corner and period-four laws. The pen source has 87 strictly replayed declarations. The raw five-name axiom report was read in full and contains only propext, Classical.choice and Quot.sound.

The fixed-sign pen laws make no claim about arbitrary sign streams or Rule 30 dynamics. The full pillowcase key classification remains a separate obligation.

## Exact evidence

Counts source SHA-256: 57be30510d889b8921c3f5b474b9f892570ac19d9f1a556552504498acf8bad0

Counts compiled object: fa5989983e04535cc7abde0a4080820fccfc5209cc54f7b67e20fd8c5e87da05

Strict counts replay receipt: dbfcf48c1150a47875321489194398d046decba79aa4c0b0b65c0c989f281851

Strict raw counts replay log: f7bf0e1206ff4c15436c250b3d3caccbdbd1807b2f045946106d3d5469084309

All 100 introduced counts declarations, including private helpers and generated declarations, replayed: PASS, kernelReplayCompleted true, failures empty, unsafe and partial constants zero. The fresh compile took 2.9195384979248 seconds and strict replay 3.06903767585754 seconds. Imported dependencies were reused, not cold-built or replayed by this checker. These are producer runs; independent reviewer execution remains pending.

The raw sixteen-name counts axiom report was read in full:

    'FVLT.AtomSkinV1.vertex_count' depends on axioms: [propext, Classical.choice, Quot.sound]
    'FVLT.AtomSkinV1.cube_genus_zero' depends on axioms: [propext, Classical.choice, Quot.sound]
    'FVLT.AtomSkinV1.cube_edge_iff' depends on axioms: [propext, Classical.choice, Quot.sound]
    'FVLT.AtomSkinV1.cube_connected' depends on axioms: [propext, Classical.choice, Quot.sound]
    'FVLT.AtomSkinV1.incident_direction_equiv' depends on axioms: [propext, Classical.choice, Quot.sound]
    'FVLT.AtomSkinV1.edge_count' depends on axioms: [propext, Classical.choice, Quot.sound]
    'FVLT.AtomSkinV1.square_count' depends on axioms: [propext, Classical.choice, Quot.sound]
    'FVLT.AtomSkinV1.chi_formula' depends on axioms: [propext, Classical.choice, Quot.sound]
    'FVLT.AtomSkinV1.chi_even' depends on axioms: [propext, Classical.choice, Quot.sound]
    'FVLT.AtomSkinV1.genus_formula' depends on axioms: [propext, Classical.choice, Quot.sound]
    'FVLT.AtomSkinV1.incident_pair_distinct' depends on axioms: [propext, Classical.choice, Quot.sound]
    'FVLT.AtomSkinV1.incident_pair_exhaustive' depends on axioms: [propext, Classical.choice, Quot.sound]
    'FVLT.AtomSkinV1.incident_square_count' depends on axioms: [propext, Classical.choice, Quot.sound]
    'FVLT.AtomSkinV1.incident_coefficients_opposite' depends on axioms: [propext, Classical.choice, Quot.sound]
    'FVLT.AtomSkinV1.total_boundary_zero' depends on axioms: [propext, Classical.choice, Quot.sound]
    'FVLT.AtomSkinV1.link_cycle' depends on axioms: [propext, Classical.choice, Quot.sound]

Pen source SHA-256: 62be605efe85fcfbded3f0419c124aa2f1f2f0a772669aa81448400ac116cccc

Pen compiled object: 1130e0eb59eb5aa29a0473db1327a7958536619da4dce5108f54ad704bdac6a2

Pen strict replay receipt: 0cbf69d4e126901532af9e2b9f067d9618536a990a3e43ad1d2737b7bc22d991

Pen raw strict log: 7502783b4624e5428bfb14006f4f54361c81d2fcb4234c4a644b54874006d901

Pen raw five-name axiom log: 0461f9420c00df44b280ae6b05697b1da00e3e8a3375f0e0b3cbf0da5b6e14a4

    'FVLT.AtomSkinV1.pen_adjacent_seat' depends on axioms: [propext, Classical.choice, Quot.sound]
    'FVLT.AtomSkinV1.pen_return_four' depends on axioms: [propext, Classical.choice, Quot.sound]
    'FVLT.AtomSkinV1.pen_no_earlier_return' depends on axioms: [propext, Classical.choice, Quot.sound]
    'FVLT.AtomSkinV1.pen_four_corners' depends on axioms: [propext, Classical.choice, Quot.sound]
    'FVLT.AtomSkinV1.pen_oriented_square' depends on axioms: [propext, Classical.choice, Quot.sound]

Latest proof-module declaration counts are 100 + 87 + 37 = 224, under their separate checks; the prior 108 data declarations remain separate. No integrated 332-declaration rebuild or replay is claimed.

The retained pillowcase module has six checked public targets and 37 checked declarations. The two data modules retain their 108 separately checked declarations. Historical module versions are not added again to the latest totals. No fresh integrated rebuild/replay of these separate modules is claimed.

## Freeze and execution record

All public target headers match the original b4484f6e freeze under manifest 22650c5b. Skin data retains accepted successor a1ea047d under decision d6a666bd; pillowcase data retains its original namespace. All new support declarations are private; no extra public helper or instance was added. Full hashes and the exact closed file set are in the manifest and retained authority packet.

Counts01 failed on a variable eliminated by substitution, a renamed erase lemma, and a missing contradiction for distinct inserted vertices. Counts02 repaired only private proof bodies. Counts03 added the already-frozen total-boundary target; Counts04 added the already-frozen link-cycle target. Failed sources, raw logs and receipts remain preserved. The stale inherited status_scope text in COMPARE_COUNTS01 was disclosed before launch and corrected in successor comparisons; the actual header list and frozen mathematics were unaffected.

All mathematical calls used nucleus over Tailscale, pinned v20 and Lean 4.35.0, unchanged runner 6a73ec37 and checker 9c6f2ac1, one CPU, 8 GiB address space, at most 240 seconds per child, and explicit toolchain PATH. All 392 library entries and source/review pins passed after each completed call. Exact posting preceded each launch: Counts01 1491/1494, Counts02 1492/1495, Counts03 1493/1496, Counts04 1494/1497, Counts04 verification 1495/1498. Pen07 compile followed #1496, Pen08 followed #1497, Pen09 followed #1499 (the owner directly read the exact topic record and accepted ledger #1502 before launch), and Pen09 verification followed #1500. Pen07 and Pen08 failed only on two private coefficient rewrite calls; Pen09 used default rewrite transparency to resolve their stored-direction and Decidable-instance matching. All failed sources and diagnostics are retained, with the same five frozen headers.

Batch06 origin 1793766673, deadline 1793768473, last child end 1793768341.59846. Capacity refreshes never reset or extended the clock. BATCH06_CLOSE_v0_1.json closes mathematical calls for this batch. A subsequent batch needs a fresh posted binding and capacity receipt. No G1 work, Neo mathematical computation, kernel or viewer write, library publication/sync, commit, or release occurred.

## Remaining targets

- FVLT.PillowcaseV1.key_classifies

The predecessor packet remains byte-identical. NEW_THEOREMS_v0_5.json records every target's standing. Producer verification does not adopt a new kernel claim or finish the independent audit. Robin Miller assembled the framework from classical components; no novelty claim is made.

