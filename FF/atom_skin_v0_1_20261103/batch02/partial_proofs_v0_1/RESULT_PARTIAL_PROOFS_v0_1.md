# FF-2 Batch02: eight target proofs, producer result

**Eight of the28frozen FF-2 targets now pass producer compilation, named axiom checks and strict kernel replay. Twenty remain open.** This is a partial proof delivery, not FF-2 completion or independent Skeleton acceptance. FF-3 builds remain held.

## What is proved by these sources

| Frozen target | Work-order row | Exact scope |
|---|---|---|
| FVLT.AtomSkinV1.vertex_count | A1, vertices only | For every omega≥3, the finite vertex type has2^omega members. Edge/square counts are still open. |
| FVLT.AtomSkinV1.cube_genus_zero | A6, omega=3 fixture | The cardinality-defined integer numerical genus at3 is0. No topological realization or surface classification is asserted. |
| FVLT.PillowcaseV1.pillowRel_equivalence | B1, relation only | The declared arithmetic relation is reflexive, symmetric and transitive on integer pairs, for positive grid dimensions. The tagged-key classification theorem remains open. |
| FVLT.PillowcaseV1.halfTurn_not_identity | B2 support | Every declared half-turn map is nonidentity, including the map centred at the origin. |
| FVLT.PillowcaseV1.fixingHalfTurn_iff_multiples | B2 | A point is fixed by some declared half-turn exactly when its coordinates are integer multiples of the grid dimensions. |
| FVLT.PillowcaseV1.nonzero_translation_fixes_nothing | B2 | A translation with at least one nonzero integer translation index has no fixed point when both grid dimensions are positive. |
| FVLT.PillowcaseV1.fixingHalfTurn_iff_corner_class | B2 | The half-turn fixing set is exactly the union of the four arithmetic classes represented by the rectangle's corners. |
| FVLT.PillowcaseV1.four_corner_classes_distinct | B2 | Those four representatives lie in pairwise distinct arithmetic classes. |

All proposition hypotheses retain their exact frozen binders. The half-turn equation is (2ia−X,2jb−Y)=(X,Y), and centre(0,0) is permitted. These are statements about lattice points and the specified arithmetic relation. No continuous pillowcase, branch angle, covering, dynamics, graphical renderer or abstract group-action bridge has been constructed.

## Latest checked sources and replay

| Module | Source SHA-256 | Object SHA-256 on nucleus | Introduced declarations replayed |
|---|---|---|---|
| FVLTAtomSkinCountsV1 |4c499cb08eb7ac7e11a1f7009054ceb5a3a49e440f813a5599a6617fea15152c|f94de8beb4edf37299a48f7447bcdaaa640d060306d83a5ad30310ccb26f6a45|2|
| FVLTPillowcaseV1, Proof03 |c2844ce47b2d6ce97273a5c563169d9a96390f804d2bd737a5a17e3f87db4ef1|bbdd0cca8169b47d777e399d3edf7723487e91a7a44c53ee5b2a340b8f09b87d|37|

Both strict reports have verdictPASS, kernelReplayCompleted=true, failures=[], unsafeConstants=0 and partialConstants=0. The37pillowcase declarations include all six target theorems, seven private parity helpers and other generated declarations. The earlier four-law version's15declarations are historical; they are not added again to this39declaration total.

The four data/source files under src form the current partial source snapshot. Its data dependencies are the previously checked skin53and pillowcase55declarations from Batch01, reused at their exact object pins. This batch does not claim a fresh integrated147declaration rebuild or replay: only the two new proof modules were freshly compiled/replayed here. Imported library and Mathlib dependencies were reused, not rebuilt or kernel-replayed.

## Axioms: raw logs, not just exit codes

The two count targets use only propext, Classical.choice and Quot.sound. Of the six pillowcase targets, the nonzero-translation law uses those same three; each of the other five uses only propext and Quot.sound. Every introduced constant is also audited by the strict checker. No sorry, admitted theorem, added axiom, native_decide, unsafe target or implementation replacement was introduced.

| Evidence | SHA-256 |
|---|---|
| Raw count axiom log |1652666ed704395041fbf8591d55b5915a4f783e439d18cf0fdd890e97d8507b|
| Raw count strict replay |e1efa1484b0c47f7a08df135c434e2a686fc51f1179a91192ff18705a8436ecd|
| Count replay receipt |a93f967c844048de2e59d842dfb5720522f496e244f1c5907ffd09fb41cc31ab|
| Raw six-law axiom log |763626b04546b6914462438a447541815e3bc81476ed1f2e0b1a8592c0c64409|
| Raw six-law strict replay |e31f51514ccaddd2dab104876132aff34fedda2ff93b834d88d5b50484cea01b|
| Six-law replay receipt |a98768e9596260d2201d5e0c227f8994173552f6ff0e7c7530895b6331e254ed|

## Frozen statements and private support

The input freeze is manifest22650c5b0304d82bfd7d89a1bcfcb20884f6c11d104729aaf8187e678efd02c5; the28header source is b4484f6e148291dd20512e58ce4ec81b4bdf08527f4bd66b3e304cbb2654785a. The new source-level public theorem declarations are exactly eight names from that freeze. Producer comparison checked each present header after whitespace normalization; no renamed binder, changed hypothesis, hidden section hypothesis or altered proposition was used. Independent exact statement/definition comparison remains required.

Skin data retains the accepted a1ea047d declaration successor, decision d6a666bd (bus1458/ledger1461), with the noncomputable Finsupp boundary/coefficient and both Sign constructors. Pillowcase data retains its original frozen namespace. No data declaration was changed in Batch02.

SUPPORT_DECLARATIONS_v0_1.json inventories the seven private helpers. They only encode Boolean residues0/1, coordinate scaling and elementary parity needed by the class proofs. They do not acquire independent public/kernel standing. All helper hypotheses are explicit binders, and they are covered by strict replay.

## Development, execution and bounds

The first count development attempt compiled the vertex proof but failed at the cube proof because ordinary decide rejected the free proof binder h3. No dependent count check ran. A fresh additive attempt changed only the proof body to decide+revert, exactly as Lean's diagnostic recommended. That compiled in0.817s and then passed axioms/replay. The original failed attempt and its log remain in evidence. The cube theorem header and its explicit binder were not changed.

The initial four-law pillowcase module compiled in1.016s and passed15constant replay. Its six-law extension compiled on its first attempt in1.317s and passed37constant replay in1.718s. Count replay took1.318s. These are warm-cache per-call measurements, not whole workflow or cold build timings.

All mathematical calls ran on nucleus over Tailscale, Lean4.35.0, the pinned v20 library, one CPU,8GiB address space,240s maximum per child. Each call rechecked392library checksum entries and all source/review pins successfully. Both job manifests and binding receipts existed before every mathematical call. Compile jobs posted1463/1466, repair/four-law checks1464/1467, count checks/six-law compile1465/1468, and final six-law checks1466/1469. Explicit toolchain PATH was exported by the actual launcher.

Batch02 is a distinct batch after the closed Batch01. Its origin1793759240 and deadline1793761040 never changed; the capacity refresh did not reset or extend it. The final child ended1793760247.5879393, about1007.59seconds after origin, within the1800second cap. Batch02 is now closed for mathematical calls. A further proof batch requires a fresh posted binding/capacity/reservation/deadline. No other process or shared kernel was stopped. No mathematical computation ran on Neo.

## Standing and remaining work

NEW_THEOREMS_v0_1.json lists all28targets:8producer-cleared,20OPEN. The remaining20are the other14count/incidence/orientation/connectivity/general-genus statements, all5pen statements and key_classifies. Each stays a real proof obligation; compilation of the underlying definitions does not prove them.

This package contains producer pairings to the work-order rows, not an independent fidelity sign-off. Skeleton's independent nucleus recompile/replay and fresh meaning review remain necessary. It is not a Rule30 prize result, a kernel-native addition, a library publication or an FF-3 execution outcome. No kernel edit, viewer edit, commit, library/cache write or release was performed.

Credit: the framework was assembled by Robin Miller; its components are classical results of others. This batch supplies proofs against the accepted instrument definitions, without a novelty claim.
