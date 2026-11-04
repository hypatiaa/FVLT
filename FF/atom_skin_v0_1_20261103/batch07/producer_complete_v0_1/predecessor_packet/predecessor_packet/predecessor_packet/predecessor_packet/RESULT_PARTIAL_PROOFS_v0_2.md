# FF-2 Batch03: eleven target proofs, producer result

**FF-2 now has11of28frozen target proofs cleared by producer compilation, named axiom checks and strict kernel replay. Seventeen remain open.** This is a partial result, not independent Skeleton acceptance or a completed FF-2 outcome. FF-3 builds remain held.

## Three additional proofs

All three are uniform for every natural omega with an explicit3≤omega binder, and every indicated vertex. They use the unchanged accepted AtomSkinV1 definitions.

| Target | Work-order row | Exact result |
|---|---|---|
| cube_edge_iff | A5 | The single-direction toggle relation is exactly the undirected endpoint relation of the declared representative edges. |
| cube_connected | A5 | Between any two vertices there is a finite-prefix path using those same cube edges. The proof explicitly constructs paths, rather than checking finitely many dimensions. |
| incident_direction_equiv | A3, vertex-label bridge | The incident edges at a vertex are in a bijection with Fin omega, and that bijection sends each edge to its actual direction label. The square-incidence cycle-link theorem remains open. |

The source retains the previously proved vertex_count and cube_genus_zero with their original headers. Combined with Batch02's six arithmetic pillowcase laws, the cumulative target total is11. The two private helpers adjacent_symmetric and path_from_empty support these proofs; both keep their hypotheses explicit and are included in strict replay. No public helper or new theorem statement was added beyond names from the accepted28header freeze.

The cube's edges are the common1-skeleton used by this skin construction. Connectedness does not establish its face-incidence count, orientation, closed-surface certificate, topological genus, metric curvature or universal cover. No such result is inferred here.

## Latest source and verification

| Artifact | SHA-256 |
|---|---|
| src/FVLTAtomSkinCountsV1.lean |552b7716e1d9845a55415793fe33f3ac1f02f9f6b3c708236f38cfaae88a5175|
| compiled object on nucleus |4619957b0d8661529bfff70d8b171c8596e53cac5010b7a011915b274a1b140c|
| compile receipt |e0e4c9f03d8ee0cb6cfd9863b2445955b00c4f1be95a43038d0775b26ab1ec97|
| raw five-name axiom log |c34a05ec515ead78f40de5a78d94856c36e6f1f844b676bee69fe598a7ae3b88|
| raw strict replay log |a98652f528b62ad91f3da4f9bde85c74bb9ccb2e0fd0c60bd5f307e6362fc96b|
| strict replay receipt |9c41c2e8e72ca83188af93c31f9f5cd9d2a741f28fb04b3c9ee775464372a6a2|

Graph02 compiled in1.116954s. All five named axiom reports use only propext, Classical.choice and Quot.sound. Strict replay completed for all27introduced declarations, including private helpers and generated constants: verdictPASS, kernelReplayCompleted=true, failures=[], unsafeConstants=0, partialConstants=0. The replay took1.718216s. These are warm-cache per-call timings, not cold builds or whole workflow times.

The retained six-law pillowcase module has37introduced declarations and its Batch02 replay remains at the pinned source/object versions in predecessor_packet. The current proof-module total is therefore27+37=64introduced declarations. Historical count-module2and four-law15declaration reports are not added again. The108data declarations were checked in Batch01 and reused; no fresh integrated172declaration compile/replay is claimed.

## Repairs and bounds

The first graph development attempt stopped on proof-body elaboration problems: a conditional needed an explicit inequality at the path join, a Finset lemma name was unavailable, and rewriting a vertex inside a dependent subtype produced an invalid motive. No dependent check followed that failed compile. Graph02 is a fresh additive attempt: it supplies the inequality, uses simplification for erase, and uses congrArg on erase instead of the dependent rewrite. Deprecated if_pos/if_neg proof aliases were replaced by their current names. The five theorem headers and all definitions are unchanged. The failed source/log/receipt are preserved.

All mathematical execution ran on nucleus over Tailscale with pinned library v20 and Lean4.35.0. The runner6a73ec37 and strict checker9c6f2ac1 are unchanged. Calls used one CPU,8GiB address space,240seconds maximum each, isolated source/object folders and an explicit toolchain PATH. Every call rechecked all392library checksum entries and all source/review pins successfully. Dependencies were cached/reused, not cold-rebuilt or replayed by this module check. No mathematics ran on Neo, and no library/cache, kernel or viewer file was written.

The original Batch03 origin1793760658 and deadline1793762458 were never changed. The capacity refresh did not reset or extend the batch. Every launch followed its exact posting receipt: Graph01 compile1469/1472, Graph02 repair1470/1473, axiom/replay1471/1474. The final child ended1793761281.5989432, about623.60seconds after origin, within the1800second cap. Batch03 is now closed for mathematical calls. Further proof work needs a distinct freshly posted batch binding and deadline.

## Source and authority chain

The original freeze manifest is22650c5b0304d82bfd7d89a1bcfcb20884f6c11d104729aaf8187e678efd02c5, and all28headers remain b4484f6e148291dd20512e58ce4ec81b4bdf08527f4bd66b3e304cbb2654785a. Producer comparison checked the five present headers exactly after whitespace normalization. Independent byte/meaning comparison remains required.

Skin data retains the a1ea047d declaration successor accepted1458/1461, decision d6a666bd. Boundary/coefficient retain their mathematical bodies with noncomputable code-generation standing; they are not runtime certificates. Pillowcase data remains the original frozen namespace. All four current source snapshots are under src. The complete prior partial8packet, including its closed input freeze, sources and evidence, is preserved byte-for-byte under predecessor_packet. This successor does not overwrite or re-label it.

NEW_THEOREMS_v0_2.json inventories all28targets and their exact current standings. SUPPORT_DECLARATIONS_v0_2.json lists the nine private proof-support declarations in the two current proof sources. No new public instance, admitted proof, new axiom, native_decide, unsafe target or implementation override was introduced.

## What remains

Seventeen frozen statements remain OPEN: the other11count/incidence/link/orientation/general-genus results, all5pen results, and key_classifies. In particular, arithmetic pillowcase equivalence and its four fixing classes do not by themselves prove that the viewer's tagged key classifies that relation.

The pairings in this report are producer pairings to the instrument-tier work order. Skeleton's independent nucleus recompile/replay and fresh meaning review are still required. This is not kernel adoption, library publication, a Rule30 result, or the sequencing outcome that permits FF-3 builds. No commit, release or viewer change occurred. Credit remains: the framework was assembled by Robin Miller; its components are classical results of others.
