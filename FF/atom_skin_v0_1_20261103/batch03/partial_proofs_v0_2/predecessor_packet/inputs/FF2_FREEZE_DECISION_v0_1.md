# FF-2 freeze packet decision v0.1

2026-11-03. Skeleton (Claude Opus 5.5), under saphir's FF-2 execution go (`EXECUTION_GO_FF2_20261103.md` `79c42179...`) and the FF-2-first sequencing (`SEQUENCING_DECISION_FF2_FF3_20261103.md` `b6e85815...`). This is the technical review gate, not a new permission.

**Decision: ACCEPTED, with the conditions below.** Input freeze, signature freeze and job template/runner are all accepted.

## What was checked

| Item | SHA-256 | Result |
|---|---|---|
| `PACKET_MANIFEST_v0_1.json` | `22650c5b...` | 17/17 pins re-hashed, all match |
| `INPUT_FREEZE_v0_1.json` | `7eaae9fe...` | library v20 pins equal nucleus (SHA256SUMS `a2933a5c...`, LIBRARY_MANIFEST `4e318f9b...`, lake-manifest `1f0e0c1c...`); latest on nucleus = v20 |
| `FF2_DEFINITIONS_PROPOSED_v0_1.lean.txt` | `61ca7137...` | read in full; matches WORK_ORDER_v0_3 (`8e108ff4...`) |
| `FF2_HEADERS_PROPOSED_v0_1.lean.txt` | `b4484f6e...` | 21 Part A + 7 Part B targets read; same statements as v0.3 |
| `SIGNATURE_FREEZE_v0_1.md` | `4d4476b0...` | accepted |
| `JOB_TEMPLATE_v0_1.json` | `95774fa3...` | accepted (as proposed; status becomes BOUND_ACCEPTED only at binding) |
| `RUN_FF2_v0_1.py` | `6a73ec37...` | equals the template pin; read in full |
| `IndependentFVLTReplay435.lean` | `9c6f2ac1...` | equals the strict checker used for FF-1 |

**Scripted signature check** (`SKELETON_FF2_SIGNATURE_CHECK_v0_1.cjs` `879275f3...`, output `9f7e5805...`): mirrors the proposed definitions exactly and tests all 28 statements, for ω = 3..9 (every vertex, edge, square, state and sign) and Part B on all grids a, b ≤ 6 over a 3×3 period window. **12,706,712 checks, 0 failures.** This is finite evidence that the statements are true as written, not a proof; it also rules out a repeat of the false Part B of v0.1.

**Runner review.** Against RUN_R5 it is a rewrite, not a patch. It keeps everything R5 enforced (host and Tailscale transport, review acceptance with runner/job/template hashes, Lean executable and checker pins, latest library = pinned version, full read-only library checksums before and after, serial lock, one CPU, nice 19, 8 GiB, `-j1 -s65536 -M7680 -D Elab.async=false`, 240 s per child, process-group kill, no automatic retry). It adds: path confinement (`member`), `python3 -I`, a 1800 s deadline file per batch, a fresh capacity receipt at most 600 s old, a host reservation reference, a hashed signature-comparison receipt with G1 import closure excluded, own-compile receipt checks before replay/axioms, and a strict replay verdict parse (PASS, kernel replay completed, targets > 0, no failures, no unsafe/partial constants).

## Conditions

1. **Axioms mode.** The runner accepts an axioms job on exit code 0; it does not parse `#print axioms`. The producer posts the axiom log for every module, and skeleton's audit accepts only `propext`, `Classical.choice`, `Quot.sound`. A target with any other axiom, or `sorryAx`, fails regardless of the receipt.
2. **Signature comparison.** The runner trusts the comparison receipt's PASS. Skeleton's audit compares delivered headers byte-for-byte with `b4484f6e...` and definitions with `61ca7137...` independently, as for FF-1.
3. **Binding: all-match accept-on-posting.** A bound template that differs from `95774fa3...` only in `status: BOUND_ACCEPTED`, `signature_freeze_sha256` (naming the manifest `22650c5b...`), the host reservation reference and the fresh capacity receipt file/hash is accepted when posted on the bus with all hashes, without a further skeleton turn. Any other change returns for review. A library newer than v20 returns for rebinding review.
4. **Bounded iteration** as stated in the signature freeze: additive attempt folders only; a failed compile stops dependent calls; a batch is 1800 s from before staging and is never extended or reset; a new batch needs a fresh posted binding (capacity + reservation). A changed definition or header, a genuine checker or axiom failure, or a statement mismatch returns that line to review. A budget failure gives no mathematical conclusion.
5. **Final PASS** still needs skeleton's own recompile and strict replay on nucleus and an independent statement-fidelity review, as for FF-1.

## Exclusions kept

G1, Part C, FF-3 builds before the FF-2 outcome, viewer edits, kernel adoption, library writes or sync, commits, and any mathematical computation on Neo.
