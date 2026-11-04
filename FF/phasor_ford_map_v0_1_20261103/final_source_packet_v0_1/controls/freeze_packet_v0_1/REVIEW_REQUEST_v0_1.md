# FF-3 input, signature, template and runner review request

Status: proposed review packet, not accepted; no proof work, Lean invocation, numerical experiment or build has run for FF-3.

Robin's execution go is already recorded. FF-1, the exact rational bridge and FF-2 have their accepted outcomes, and v21 is ready. This request is for the remaining mandatory technical review, not another human permission request.

The governing FF-1 order, inherited by FF-3 v0.2, requires that “signatures are reviewed and frozen (hashed) first; proofs are written only against frozen signatures.” The FF-3 design review says its signature precisions “are obligations for the signature review, not permission to bypass it.” Both source documents are pinned under inputs.

Please decide the proposed exact data declarations, all 37 theorem headers, module/target mapping, current execution inputs, capped job template, runner and strict checker. The declaration text is intentionally uncompiled: static validation does not claim Lean elaboration. Any required mathematical or interface change will be an additive successor packet before proof work.

The original order named an older library snapshot. This packet explicitly returns with current v21 for review, rather than silently treating the old freeze as current. Its actual package configuration is lakefile.toml. All 397 library checksums passed and no library path was writable. The six inherited project source dependencies match v21 exactly. The Mathlib revision and Lean executable match the recorded versions. Kernel II.5 is identical between the historical v3.3.1 input and current locked v3.4.0; both full files are pinned.

## Mathematical interfaces to inspect

- The rational-spin real-axis law uses the full phase address and a nonzero real amplitude. Integer parity is a separate theorem with an explicit integer spin and integer exponent, including negative values.
- The free amplitude r is a scalar parameter, not the n6 sign operation. This packet does not define n6 or identify a negative scalar with the corrected y-axis reflection.
- P1 separates positive divisor windows and zero spin. P2–P4 state exact multiplication identities before integer-quotient corollaries, use reduced rational determinants, retain positive denominators, and use absolute value for signed column parameters.
- P5 defines finite shell events and separately proves their membership predicate is the contact predicate. It deduplicates Ford addresses, bridges the actual finite Farey enumeration to the rational membership predicate, and sorts that same set before the signed consecutive-neighbour theorem. B >= 1, N >= 2, spin bounds, and all index guards are explicit.
- P6 uses Fin (m+1) circle sequences and Fin m edges, explicit mutually exclusive/exhaustive cases, determinant zero iff equal addresses, and exact rational certificates only for tangent edges. The constructor named gap is the work order's break event; IsBreak retains its full logical and determinant conditions.
- No oriented arcs, continuous dynamics, unlabelled-phasor inverse, register identification, factoring advantage, viewer change or kernel adoption is proposed. Lemma 6a is unaudited reference material and is not an assumption or import.

## Execution-policy questions for this review

The proposed limits are one CPU, 8 GiB address space, -j1 -s65536 -M7680, process limit 256, 64 MiB output-file limit, 240 seconds per child and 1800 seconds per development batch starting before proof writing/staging. A new batch needs a fresh posted capacity/reservation and deadline; a capacity refresh never extends a batch. Nucleus over Tailscale is the sole initial host.

Please explicitly settle whether later all-match bindings may alter only status and the four declared binding fields, and become accepted on posting of their exact hashes. This workflow is proposed for FF-3; FF-2's earlier decision is not assumed to authorize it. Every concrete job must be posted before launch regardless.

Proposed repair discipline: a failed compile stops that item and all dependent checks; preserve the complete attempt. A proof-only repair may use a fresh additive attempt, with unchanged frozen data/public headers, a fresh comparison and exact prospective job posting. Any definition/header change, wrong axiom set, genuine strict-replay failure or scope change returns for review. No stopped predecessor is overwritten.

The runner adds mechanical project-import G1 exclusion and strict named-axiom parsing to the inherited process/source/hash guards. The raw axiom log is still delivered verbatim. The checker is byte-identical to the accepted 9c6f2ac1 version. Imported dependencies are reused, not replayed. See RUNNER_CHANGELOG_v0_1.md.

Independent clean rebuild/replay and separate meaning/fidelity review remain mandatory after producer results. Library inclusion, publication, kernel changes, hosted checking and release do not follow from this packet or Robin's go.
