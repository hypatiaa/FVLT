# FF-2 Batch04: sixteen target proofs, producer result

**Sixteen of28frozen FF-2 targets now pass producer compilation, named axiom checks and strict kernel replay. Twelve remain open.** Independent Skeleton recompile/replay and meaning review remain pending. This is not a completed FF-2 outcome; FF-3 builds remain held.

## Five new uniform proofs

For every natural omega with the explicit hypothesis3≤omega, Lean now proves the following from the actual finite types in the accepted definitions:

\[
V=2^\omega,\qquad E=\omega2^{\omega-1},\qquad F=\omega2^{\omega-2},
\]
\[
\chi=V-E+F=2^{\omega-2}(4-\omega),\qquad
g_{\mathrm{num}}=1-\chi/2=1+(\omega-4)2^{\omega-3}.
\]

The new frozen theorem names are edge_count, square_count, chi_formula, chi_even and genus_formula. Vertex_count was already proved. Chi and numerical genus use integers, so omega−4 is signed; the omega=3value stays0. Chi is proved even, and integer division by2 is justified by its explicit factor2. No natural-number truncation of omega−4 is used.

The proof counts vertices avoiding one labelled direction for each edge, and vertices avoiding two distinct cyclic-neighbour directions for each square. The cyclic-neighbour distinctness is proved from the accepted Int-modulo direction definition, rather than assumed. The finite-cardinality results are general theorems, not bounded enumeration or a fitted count formula.

The numerical invariant is not a theorem about the genus of a topological realization. The outstanding incidence, cycle-link and orientation certificates remain genuine obligations. No surface classification, curvature or universal cover follows from this batch.

## Exact latest source and checks

| Artifact | SHA-256 |
|---|---|
| src/FVLTAtomSkinCountsV1.lean |75ecf996dfd88abacc59d5c640d79e9cd891d256c3a1fbdb9e99508ac65914f5|
| compiled object on nucleus |dc766d634aa1017cfa057beef37fc621d0b066cc52bbe5aadcaf85b9ed3ac027|
| compile receipt |831266ba0a8b65db9125417fbb918795e0c2e3a6f1f1c0676a6a468246a9806f|
| raw ten-name axiom log |1cb83582ae3097286b23ce7e3c5b0f93f5db179cfa5ccff2a199e823b7fbe6b9|
| raw strict replay log |c9b23c301459aa07a4d62f11a85ac6e3333fca33d036af022dc25fb9321ad521|
| strict replay receipt |d327033a9dad2019a2877200d34f21119c34e0f45b682bf7fcdb78526dfeede8|

Counts02 compiled in1.519442s and strictly replayed in2.219511s. All47introduced declarations, including seven private helpers and generated declarations, replayed successfully: kernelReplayCompleted=true, failures=[], unsafeConstants=0, partialConstants=0, verdictPASS. Every one of the ten named target axiom reports uses only propext, Classical.choice and Quot.sound. The raw logs were read in full; runner exit0 alone is not used as the axiom verdict.

The retained six-law pillowcase source still has its separately checked37introduced declarations. Thus the current proof-module total is47+37=84, including16public target theorems. Earlier count-module27/2and four-law15reports are historical and are not added again. The108data declarations retain their prior checked source/object versions. No fresh integrated192declaration rebuild/replay is claimed.

The original first count attempt failed only at the private Int-to-Nat remainder conversion proof. No dependent check was run on that failed module. A fresh additive attempt used the inspected Int.toNat_emod lemma with explicit nonnegativity facts and a natural remainder normalization. No public header, hypothesis, definition or imported data object changed. The original failed source, log and receipt remain preserved.

## Inputs, bounds and provenance

All ten current public count headers match the28header freeze b4484f6e148291dd20512e58ce4ec81b4bdf08527f4bd66b3e304cbb2654785a, under manifest22650c5b0304d82bfd7d89a1bcfcb20884f6c11d104729aaf8187e678efd02c5. Producer comparison checks present headers exactly after whitespace normalization; independent statement/meaning comparison remains required. The seven count private helpers and seven retained pillowcase private helpers are inventoried in SUPPORT_DECLARATIONS_v0_3.json, with no new public helper or instance.

Skin data remains the accepted a1ea047d successor, decision d6a666bd; its boundary/coefficient mathematical bodies are unchanged and their noncomputable standing is retained. Pillowcase data remains its original frozen namespace. The four current sources are under src. The complete partial11predecessor, including its own predecessor and closed authority/evidence packets, is retained byte-for-byte under predecessor_packet.

All mathematical calls ran on nucleus over Tailscale using pinned v20, Lean4.35.0, the unchanged runner6a73ec37 and checker9c6f2ac1, one CPU,8GiB address space,240seconds maximum per child, isolated source/object paths and an explicit toolchain PATH. All392library checksum entries and source/review pins passed after every call. Dependencies were reused, not cold-built or replayed by this checker. No mathematical computation ran on Neo; no library/cache, kernel or viewer write, commit or release occurred.

Every launch followed its exact posting receipt: first compile1475/1478, additive repair1476/1479, axiom/replay1477/1480. Batch04 origin1793761889 and deadline1793763689 never changed; capacity refresh did not reset or extend them. The last child ended1793762820.4616802, about931.46seconds from origin, within1800seconds. Batch04 is closed for mathematical calls. A further batch needs a freshly posted binding, capacity/reservation and a new deadline file.

## Remaining twelve targets

The exact OPEN names are:

- incident_pair_distinct, incident_pair_exhaustive, incident_square_count;
- link_cycle;
- incident_coefficients_opposite, total_boundary_zero;
- pen_adjacent_seat, pen_oriented_square, pen_return_four, pen_no_earlier_return, pen_four_corners;
- key_classifies.

NEW_THEOREMS_v0_3.json lists all28targets with their current standings. All16cleared rows are producer results pending independent verification, not new kernel standing. In particular, the arithmetic pillowcase classes do not yet certify the viewer's tagged key, and the count formula does not fill the missing surface certificates. FF-3 builds remain held until FF-2 has its recorded outcome.

Credit: the framework was assembled by Robin Miller; its components are classical results of others. No novelty claim is made.
