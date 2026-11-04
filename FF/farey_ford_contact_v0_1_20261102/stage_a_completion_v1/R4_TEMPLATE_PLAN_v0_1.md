# FF-1 R4: phase partners, isolation and complement

2026-11-03. **Awaiting Opus receipt check. No R4 proof drafting, source, preflight, computation or build.** R3 PASS #1425 is recorded in parent `R3_AUDIT_v0_1.md`, SHA256 `8003559f76ce6b2035e4a91be7638f55ec5440f784c6305d944a6c05e1ec3562`, independently hash-matched and read in full. Manager-audited progress is 44/60. Robin's Stage A go and accepted continuation sequence remain in force.

## Frozen deliverable

One additive `FVLTPhasePartnersV1.lean`, namespace `FVLT.FareyContactV1`, imports the audited `FVLTUnitFractionSpineV1` plus standard Mathlib. It reuses all existing rational, phase, graph and isolation definitions without redeclaring or editing them.

The eleven original A6 headers, verbatim in the template:

1. `phases_eq_unreduced`: the reduced-denominator and original profile-event descriptions give the same finite phase set.
2. `phase_domain`: membership gives the strict interior bounds, denominator at least two and admissible denominator.
3. `denominator_partner`: exact numerator/denominator recovery, phase membership and adjacency iff the signed determinant equation and numerator range.
4. `partner_congruence`: existence of an admissible partner iff the signed congruence **and** induced numerator range.
5. `cross_denominator`: adjacent interior phases have different denominators.
6. `isolation_criterion`: no signed determinant partner at any admissible denominator.
7. `endpoint_isolation`: the exact unit-fraction endpoint congruence/range criterion.
8. `complement_mem`: phase membership is invariant under x ↦ 1−x.
9. `complement_adj`: complement preserves adjacency with the frozen interior hypotheses.
10. `complement_graph_auto`: an actual Mathlib graph isomorphism acts on vertex values by x ↦ 1−x.
11. `isolated_complement_pairs`: isolation is paired by complement, with fixed point precisely 1/2.

Every original profile-positivity, phase-membership, admissible-denominator and interior hypothesis remains an explicit binder, including hypotheses redundant for some helpers. Integer division remains the frozen Euclidean quotient, justified by the congruence's divisibility and positive denominator. No congruence-only surrogate replaces the partner or isolation statements. The cross-denominator theorem remains an interior-phase claim; it is not extended to 0/1 and 1/1.

The only new public definition is the frozen `unreducedPhases`. The JSON contains the original body verbatim. Existing additive erratum **S1** pre-clears its image-lambda annotation `e : ℕ` if elaboration needs it. That is the only permitted body-text difference, to be recorded and script-compared at delivery; no value, set or domain changes. S1's file and hash are pinned in the template. The already accepted `phases` implementation is imported, not edited.

## Runner and dependency receipt

`RUN_R4_v0_1.py` derives mechanically from the accepted R3 runner: R4 phase/module/artifact constants, two additional R3 source/object predecessor pins, and the R3 PASS gate. Full diff included. It protects **12 predecessor source/object files and six PASS records**, retaining the audited producer R3 object `8d5f4cae…`. Root, parent serial lock, expected library/compiler/Mathlib/checker, compile/replay modes, integrity logic and caps are unchanged.

The template drops R3's integer-path adjacency and exceptional-namespace fields because those are already audited predecessor facts. All R4 targets are in the arithmetic namespace. The S1 annotation metadata preserves an existing accepted exception, rather than changing a proposition or introducing a new graph model.

## Same fresh-binding and execution gates

After receipt-check acceptance, metadata-only nucleus/Tailscale observation must establish the latest library, all expected pins and identities, full listed-file checksums, read-only state, current capacity and all predecessor/gate pins. Any mismatch returns for review. Request the same all-match bound-template acceptance on verified bus posting; no proof drafting starts before its delivery receipt. No fresh input observation is claimed by this draft.

One fresh 1800-second active allowance begins at R4 proof drafting, with no transferred allowance. Same accepted caps: one CPU, nice 19, 8 GiB address space, Lean `-j1 -s65536 -M7680 -D Elab.async=false`, at most 240 seconds/call or remaining deadline, process cap 256, file/output cap 64 MiB, no core dumps, serial calls and no automatic retries. Bounded proof-only iteration, individually listed/replayed private helpers and decidability instances, concrete timestamped self-accepted manifests and failed-source/log/receipt snapshots follow the accepted continuation policy. Recorded review-wait exclusions require preserved evidence.

Proposition or definition-value changes, forbidden axioms, unsafe/partial targets, strict-checker failure, checksum drift or budget expiry stop the item and return evidence. Neither successful compilation nor a finite computation substitutes for the stated general theorem. No extra public lemma is silently promoted into scope.

## Audit and next decision

Deliver all eleven headers and the definition comparison against original/S1, every attempt, all target/helper axiom prints, strict replay of every module declaration, integrity receipts, a closed manifest and a per-target kernel/source/standing map with independent sign-off pending. Opus independently recompiles/replays and verifies the binding before recording R4 PASS.

Source roles remain the Setting/II.5g, II.5i, II.5i.1, II.5j and II.5j.1, with the same interior guards and standing. R5's five fixtures and final all-60 integration/fidelity remain separate gates. No Stage B, FF-2/FF-3 execution, G1, Rule 30 forcing, viewer change, library sync, commit, kernel adoption, installation or release follows. Framework credit remains Robin Miller; classical components retain their source credit.
