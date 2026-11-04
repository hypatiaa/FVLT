# FF-1 R3: unit-fraction spine continuation

2026-11-03. **Awaiting Opus receipt check. No R3 proof drafting, source, computation or build.** R2 PASS #1420 is recorded in parent `R2_AUDIT_v0_1.md`, SHA256 `48e4ee942af299f2fed279057c4852aa6c6d539bf405b5dbad18fe8a72a6c75d`, independently matched and read in full. Manager-audited progress is 34/60. This continues the existing Stage A go and reviewed continuation plan.

## Frozen scope and names

One additive module `FVLTUnitFractionSpineV1.lean` imports the exact audited `FVLTFordGeometryCompletionV1` and standard Mathlib. All predecessor definitions and theorems are reused without editing their source or compiled objects.

Ten targets, with headers verbatim from the original signature freeze and accepted R3 coverage rows:

1. Positive-domain unit-fraction injectivity.
2. The integer path's adjacency formula.
3. Unit-fraction Farey adjacency iff integer distance one.
4. Unit-fraction Ford tangency iff integer distance one.
5. Graph isomorphism from the integer path induced on a finite positive set to its unit-fraction Farey graph.
6. For a finite nonempty positive set, connectedness iff the set is a consecutive positive interval.
7. The frozen empty-graph convention: preconnected and not connected.
8. The determinant across a gap of positive size.
9. The minimal gap's mediant.
10. For gap size greater than two, the mediant is a positive unit fraction iff the gap size is even.

The first, second, third and fifth through tenth declarations belong to `FVLT.FareyContactV1`. **`unitFrac_tangent` belongs to `FVLT.FordGeometryV1`**, opening the arithmetic namespace there, exactly as the original freeze's A5 placement note requires. This packaging uses one module with explicit namespace blocks; it does not change any header or binder. The template records that namespace exception explicitly.

The new definitions are the frozen `vertexSet V := V.image unitFrac` and `integerPath : SimpleGraph ℕ`. Its adjacency is **exactly** `|(a : ℤ) - (b : ℤ)| = 1`. The original freeze specifies that adjacency semantically and leaves the constructor proof fields to implementation. Those fields must prove symmetry and looplessness, without another condition or a different graph. The image/subtype graph correspondence uses Mathlib `SimpleGraph`, not a replacement connectivity notion.

All positivity and nonemptiness hypotheses remain explicit. In particular, empty preconnectedness is not used to claim connectedness of an empty vertex set. No anchoring, complete insertion repair, strict-staircase classification or primorial-representative claim is added: the original A5 omissions remain.

## Runner and dependency changes

`RUN_R3_v0_1.py` is the accepted R2 runner with only R3 phase/module/artifact constants changed and R2 source/object and PASS pins added. The full diff is included. It protects **ten predecessor source/object files and five manager records**, with the R2 producer object `ce38bf44…` retained. The root, parent serial lock, library/toolchain/checker expectations, compile/replay modes and resource logic are unchanged.

Expected library remains v19 pending a fresh check. No R3 metadata preflight is claimed by this draft. After the receipt-check acceptance, perform fresh metadata-only latest/full pins/compiler/Mathlib/checksums/read-only/capacity/predecessor/gate observation on nucleus through Tailscale. Any mismatch returns for review before drafting. Request the same all-match bound-template acceptance on verified bus posting; deliver that receipt before starting the proof clock.

## Same bounded execution policy

One independent 1800-second active R3 allowance begins at proof drafting, with no transferred allowance. One CPU, nice 19, hard 8 GiB address space, Lean `-j1 -s65536 -M7680 -D Elab.async=false`, 240 seconds per call or the smaller remaining deadline, process cap 256, file/output cap 64 MiB, no core dumps, serial calls and no automatic retries. Bounded proof-body iteration and listed/replayed private helpers or decidability instances follow the already accepted continuation policy. Concrete manifests are self-accepted only under that accepted template, timestamped and snapshotted. Failed attempts remain preserved.

The same hard stops apply: proposition or definition-value changes, forbidden axioms, unsafe/partial declarations, strict-checker failure, integrity drift or budget expiry return evidence. Recorded review-wait exclusions follow the manager's accepted rule. Difficult connectivity API work is not permission to weaken the theorem, substitute finite fixtures or extend the deadline.

## Delivery and boundary

The packet must show all ten headers, their actual fully qualified names, both definitions and the exact integer adjacency semantics, all proof attempts, theorem/helper axiom prints, strict replay of every module declaration and complete input/predecessor/library integrity receipts. An independent audit records the R3 outcome; a separate per-row fidelity review and integrated all-60 build remain required.

R4 and R5 remain separately gated. No Stage B, FF-2/FF-3 execution, G1, Rule 30 result, viewer work, synchronization, commit, kernel adoption, installation or release follows. The source table will retain II.5f (i)/(iii)'s scoped unconditional standing and mark general implementation helpers separately. The framework was assembled by Robin Miller; these Farey/Ford components are classical results of others.
