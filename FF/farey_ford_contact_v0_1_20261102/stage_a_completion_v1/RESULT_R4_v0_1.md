# FF-1 R4: producer PASS

2026-11-03. **FINISHED (producer compile and strict replay PASS); independent audit and statement-fidelity sign-off pending.** All eleven frozen phase-mode targets are proved, including phase-set equivalence, the full signed partner/congruence conditions, isolation, and the complement graph automorphism.

## Governing inputs and dispatch

The original Stage A order/signature freeze, E1/S1 and reviewed continuation sequence remain in force. Manager R3 PASS is pinned by `8003559f76ce6b2035e4a91be7638f55ec5440f784c6305d944a6c05e1ec3562`. R4's template decision is `f53647f25f5439c46eb2f028cf04796de8c972e9d6400e86fec3fc3b3795bf17` (#1427 / accepted ledger 1430).

The metadata-only 22:29:53Z nucleus/Tailscale receipt `1fde30ddd029690baeb945a5d52d656e2321883f3dddf0b7f3032cd0750864b8` matched every expected library/compiler/Mathlib/checker/runner pin, all twelve predecessor source/object files and six PASS records. Latest library was v19; all 381 checksums passed; no writable regular entries were found; about 28685 MiB was available at load 0.00. It performed no theorem compilation or mathematical checks.

Bound template `de7d4ea627cf9b64e2e8e87faec3fe9136938cf3534d854f6c05ac4673a57dab` and receipt were posted once as **#1428 / accepted ledger 1431**, exact stored candidate/topic/canonical-ledger verification reported by the coordinator. The all-match acceptance-on-posting gate was met before drafting. R4's clock began at unix **1793745113** with independent 1800-second deadline **1793746913**; the final replay ended before **1793745504**, about 391 seconds after drafting began. No inherited allowance or excluded review wait was used.

## Exact output and raw verdict

`FVLTPhasePartnersV1.lean`, namespace `FVLT.FareyContactV1`, imports only the exact audited R3 module and standard Mathlib. All eleven original headers and their explicit binders remain verbatim. The one public definition, `unreducedPhases`, differs from the original text only by the **already accepted S1** image-lambda annotation `e : ℕ`. Its domain and value are unchanged. No predecessor definition is redeclared or edited.

Final source SHA256: `81b55661b4e1c6c8e4a8a837fdd62bf1ce61b7358499334d818756fa173e80ac`.

Producer object SHA256 on nucleus: `875d7726a34ca13d247b53d71525087141481441fbef5b0928586712b84f77a3`.

| Run | Exit | Seconds | Result |
| --- | ---: | ---: | --- |
| R4Compile01 | 1 | 2.420 | Preserved missing cast-one simplification in complement helper |
| R4Compile02 | 0 | 2.471 | Eleven targets and six helpers compile; seven redundant-binder warnings |
| R4Replay01 | 0 | 3.020 | **PASS, 40/40 declarations**, zero failures/unsafe/partial |

All three calls ran serially on **nucleus over Tailscale**, using runner `3d6cb1535a64a81fd71dfb4b8546e98b8c269d8583ca2c869bce8f2148580478`: one CPU, nice 19, hard 8 GiB address space, Lean `-j1 -s65536 -M7680 -D Elab.async=false`, at most 240 seconds/call, process cap 256, file/output cap 64 MiB. No mathematics ran on Neo.

All **17 theorem axiom reports** (eleven targets and six private helpers) use only `propext`, `Classical.choice`, `Quot.sound`. The strict checker replays and audits every declaration in the target module, including generated auxiliaries; imported dependencies are reused rather than fully replayed. G1 is excluded. All three receipts report unchanged source, twelve predecessors and six PASS records, with post-call library checksum verification successful.

## Mathematics and scope

The proofs characterize a phase by its strict interior bounds and admissible **reduced** denominator. They prove equality with the original unreduced profile-event set using divisor membership and exact rescaling, without an enumeration bound. A determinant-one partner is proved to recover the proposed numerator/denominator canonically. Congruence is accompanied by the exact Euclidean quotient range; it is never used as a substitute for that range.

The interior cross-denominator result retains the frozen guards. Isolation and endpoint isolation use the same signed determinant/quotient conditions. Complement preserves phase membership and determinant adjacency, gives an actual Mathlib graph isomorphism acting by x ↦ 1−x, and pairs isolated vertices with fixed point exactly 1/2. No conclusion about endpoint phases 0/1 or 1/1 is substituted for the interior theorem.

## Helpers and preserved repair

Six private helpers, each explicitly bound, axiom-reported and strictly replayed:

- `admissible_two`: admissible denominators are at least two.
- `interior_numerator`: exact numerator range and denominator lower bound from strict interior bounds.
- `phase_description`: canonical phase membership characterization.
- `sign_witness`: signed determinant-one witness.
- `unit_phase`: admissible unit fraction's membership and canonical coordinates.
- `complement_coordinates`: exact numerator/denominator change under complement.

No new instances or extra public targets were introduced. The first compile's single error was in `complement_coordinates`: a restricted simplification list left the cast of natural one unnormalized. The proof-only repair used the standard simplifier; no formula, definition, guard, binder or target changed. Minor redundant-tactic cleanup was also proof-only. The failed source/job/review snapshot/log/receipt is preserved, and its error-recovery `sorryAx` is not accepted proof evidence. The final compile and strict replay are clean.

The final log's seven warnings concern frozen hypotheses that the particular proofs do not require (`hα`, `hx` or `hy` at their recorded declarations). They are intentionally retained as explicit binders; no linter suppression or scope change was introduced. Accepted source contains no `sorry`, `admit`, added axiom, `native_decide`, unsafe or partial declaration.

## Remaining audit and next decision

`README_R4_v0_1.md` supplies the per-target source/standing map with independent fidelity sign-off pending. Opus should independently recheck the closed pins and binding, compare all headers and `unreducedPhases` under S1, compile/replay the exact source and record the eleven-target outcome. No new Sage/finite computation was needed or run; these are general Lean proofs over the frozen domains.

Manager-audited status remains 44/60 until that audit. The producer has supplied eleven more, leaving R5's five fixtures queued under their own template. Final all-60 integration and independent per-row fidelity remain separate gates. No Stage B, FF-2/FF-3 execution, G1, Rule 30 result, viewer work, synchronization, commit, kernel adoption, installation or release follows.

Remote root: `/home/saphir/fvlt_formalization_20261028/ff1_v03_20261103/stage_a_completion_v1`.
