# FF-2 producer-complete handoff

**All 28 frozen FF-2 targets now pass producer compilation, named axiom checks and strict all-constant kernel replay. No target proof remains open.** Independent rebuild/replay and meaning review remain pending. The final FF-2 outcome is NOT RECORDED, and FF-3 builds remain HELD.

## The last theorem

For all positive natural a and b and all integer points v and w, Lean proves:

    key a b v = key a b w ↔ pillowRel a b v w

Both key and pillowRel are the actual frozen definitions. The key equality is equivalent to a permitted translation or half-turn, with integer witnesses; it is not merely a sufficient collision test or a finite example check. The relation negates both coordinates together in the half-turn branch.

The proof reduces an integer point modulo 2a and 2b, carries it through the actual net normalization, and decodes its key to a canonical point in 0 <= x < 2a, 0 <= y <= b, with x <= a on the horizontal boundary. Each input is related to its decoded point. Related canonical points are equal: translation is forced to be the identity by the residue bounds, and a half-turn between normalized points forces both onto a common horizontal boundary, where the remaining x bounds force equality. The proof also establishes the key roundtrip on decoded points. These facts give both directions of the frozen iff.

Zero residues, a = 1 or b = 1, horizontal boundary identifications, and the permitted half-turn centre (0,0) are included in the universal statement. All hypotheses are explicit binders. The seven public pillowcase theorem headers are unchanged from the accepted freeze; all 30 support definitions/theorems in the pillowcase source are private.

This is a mathematical contract for the viewer's classifier. It does not by itself verify an HTML or JavaScript implementation against that contract.

## What the complete FF-2 collection covers

The counts module proves its 16 frozen targets: exact vertex, edge and selected-square counts; Euler and numerical genus identities; cube edges and connectivity; two-square incidence and opposite coefficients; the cycle link at each vertex; and cancellation of the total integer boundary chain.

The pen module proves all five frozen targets: adjacent direction, a common oriented square for incoming/outgoing edges, exact four-step return with no earlier full-state return, and equality of the four visited vertices with one square's corners. The same sign is fixed through an iteration; arbitrary sign streams and Rule 30 forcing are separate questions.

The pillowcase module proves all seven frozen targets: the group relation, the full key classifier, nonidentity half-turns, fixing-point and corner characterizations, distinct corner classes, and absence of fixed points for nonzero translations.

No topological realization or surface-classification theorem has been added, and the numerical genus is not identified in Lean with a topological genus. No kernel claim is adopted or upgraded by this producer result. This work is the FF-2 instrument-tier collection, not a statement that every FVLT kernel item or a Rule 30 prize problem has been proved.

## Final key-module evidence

Source SHA-256: 27e7c00dcae05e2f7e93de3d79e8f56380a553b76c2848f919deb6a3f5d82a3f

Compiled object: cc0c071472adc1c2253f937411b0af42b634b2f0778e3f757258e04273ee26ee

Strict replay receipt: 98529c5d8bdae2e7e1aa68ae339ac656d4b071bd86c47a223e1b6019bb312830

Raw strict replay log: e46e7b4bb8124655365abac825d101c31c8ed24ee58543126a0d90432382683e

All 119 introduced pillowcase declarations, including private helpers and generated declarations, replayed: verdict PASS, kernelReplayCompleted true, no failures, no unsafe or partial constants. The compile took 2.17006397247314 seconds and strict replay 2.71935749053955 seconds. Cached imported dependencies were reused; this is not a cold build or a replay of those dependencies.

The raw seven-name axiom report was read in full:

    'FVLT.PillowcaseV1.pillowRel_equivalence' depends on axioms: [propext, Quot.sound]
    'FVLT.PillowcaseV1.halfTurn_not_identity' depends on axioms: [propext, Quot.sound]
    'FVLT.PillowcaseV1.fixingHalfTurn_iff_multiples' depends on axioms: [propext, Quot.sound]
    'FVLT.PillowcaseV1.nonzero_translation_fixes_nothing' depends on axioms: [propext, Classical.choice, Quot.sound]
    'FVLT.PillowcaseV1.fixingHalfTurn_iff_corner_class' depends on axioms: [propext, Quot.sound]
    'FVLT.PillowcaseV1.four_corner_classes_distinct' depends on axioms: [propext, Quot.sound]
    'FVLT.PillowcaseV1.key_classifies' depends on axioms: [propext, Classical.choice, Quot.sound]

The latest proof modules have 100 + 87 + 119 = 306 separately checked declarations. The prior two data modules have 53 + 55 = 108 separately checked declarations. No fresh integrated 414-declaration rebuild/replay is claimed. The independent handoff asks for a clean build of all five sources and strict replay of all introduced constants.

## Freeze and bounded execution

The original signature manifest is 22650c5b0304d82bfd7d89a1bcfcb20884f6c11d104729aaf8187e678efd02c5; the 28-header freeze is b4484f6e148291dd20512e58ce4ec81b4bdf08527f4bd66b3e304cbb2654785a. Skin data remains accepted successor a1ea047d under decision d6a666bd. Pillowcase data retains its original frozen namespace and checked object, not the skin successor definitions.

Pillow01 failed in two private normalization helpers: one net-coordinate bound remained folded, and a Nat remainder rewrite was attempted after casting it to Int. Pillow02 changed only those proof steps. Both source versions, raw logs and receipts are preserved; no dependent check ran on the failed attempt. No public header, data definition, imported project module or hypothesis changed.

All mathematical calls ran on nucleus over Tailscale using pinned library v20, Lean 4.35.0, unchanged runner 6a73ec37 and checker 9c6f2ac1, one CPU, 8 GiB address space, at most 240 seconds per child and explicit toolchain PATH. All 392 library entries and source/review pins passed after every completed call. Exact job posting preceded each launch: Pillow01 #1502/ledger1505, Pillow02 #1503/ledger1506; the final axiom/replay jobs followed #1504/accepted ledger1507. All launches followed their exact posting receipts.

Batch07 origin 1793768518, deadline 1793770318, last child end 1793769304.17197. Capacity refreshes did not reset or extend it. BATCH07_CLOSE_v0_1.json closes mathematical execution under this clock. No G1 work, Neo mathematical computation, kernel/viewer/library write, hosted check, publication, commit or release occurred.

## Outstanding acceptance work

The producer proof list is complete. What remains is the independent clean rebuild, named axiom reporting, strict replay and semantic/fidelity review under the accepted gates, followed by the manager's recorded FF-2 outcome. FF-3 builds remain held until that outcome. See AUDIT_HANDOFF_v0_1.md and the complete closed manifest.

The entire predecessor packet is retained byte for byte. Robin Miller assembled the framework from classical components; no novelty claim is made.

