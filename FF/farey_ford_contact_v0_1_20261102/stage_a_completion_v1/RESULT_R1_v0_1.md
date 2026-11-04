# FF-1 R1: producer PASS

2026-11-03. **FINISHED (producer build/replay PASS); awaiting Opus's independent recompile/replay and fidelity review.** Only R1 is covered. No R2–R5 or final Stage A acceptance is implied.

## Governing inputs

Work order v0.3 `43560b88ab50dc77d8e222562f83bad68c8ba17d12a073523a99597a484d6fdd`, E1, original signature freeze `a9382d4054a77d7a569e884b4f7e02b55f7c7e9aa0da2d3a6d1299075ea2b6c7` and S1 remain unchanged. R1 template/layout/runner/policies were accepted in manager #1410 (`R1_TEMPLATE_DECISION_v0_1.md`, `34cfd2e2734fee2606cb0bfb91ded8332ca5afe216e3b505997fb1d6acaf25b6`).

Fresh metadata receipt `R1_INPUT_OBSERVATIONS_v0_1.json`, SHA256 `f5cd392cd7d60b27ce2a55d83e45982057c19de76e37f1a375583b5bc5ff798f`, records 18:02:29Z on nucleus through Tailscale: latest v19, all expected pins equal, compiler identity/binary, Mathlib, checker, runner, six predecessor files and three manager records matched; 381 checksums OK; 153937 scanned regular entries, zero writable; one known in-tree documentation symlink skipped. About 28871 MiB was available with load 0.00. No mathematics ran during that preflight.

Bound template `8ebcc04011eabe08a19238037be287ec9ae3167e6ccd84c7298d11f94b7fb4b7` was posted under the manager's all-match acceptance-on-posting rule as **#1412 / accepted ledger 1415**, topic and ledger verified by the coordinator. Proof drafting began only afterwards, at unix **1793729048**. Deadline was **1793730848**, a fresh 1800-second cap with no inherited allowance or excluded review wait. All five Lean calls finished by unix 1793729412, about 364 seconds from drafting start.

## Result

`FVLTFareyArithmeticCompletionV1.lean` imports the accepted F2 module plus standard Mathlib and supplies all seven frozen R1 targets and all three frozen definitions verbatim. It does not edit or redeclare the accepted predecessor declarations and does not import the bridge.

The results prove determinant-one coprimality, rational round-trip and canonical numerator/denominator recovery, uniqueness of reduced positive-denominator representations, the 1/3–1/5 coprime-but-not-adjacent witness, the reduced mediant and its neighbouring edges, and the unit-fraction rosette identities.

| Run | Exit | Observation |
| --- | ---: | --- |
| R1Compile01 | 1 | Cast and rewrite-order errors; preserved |
| R1Compile02 | 1 | Remaining nonzero-denominator cancellation goal in rosette; preserved |
| R1Compile03 | 0 | Seven targets compiled |
| R1Compile04 | 0 | Final source; added axiom prints for both private helpers |
| R1Replay01 | 0 | **PASS, 29/29 declarations**, zero failures, unsafe or partial declarations |

The final compile took about 2.07 seconds; strict replay about 2.27 seconds. All execution was on **nucleus over Tailscale**, never Neo, using the accepted runner SHA256 `a07e738a973429be2e8ade6406f49fea1bb6b5e351ac5ede263f721b933cbd73`: one CPU, nice 19, hard 8 GiB, Lean `-M7680 -j1 -s65536 -D Elab.async=false`, 240-second per-call maximum, process cap 256, file/output cap 64 MiB, serial parent lock, no automatic retries.

The nine theorem axiom prints (seven targets and two private helpers) use only `propext`, `Classical.choice`, `Quot.sound`. The strict checker audits the same allowed set across every target-module declaration, including generated auxiliary declarations. Imported dependencies are reused, not fully replayed. G1 is excluded. All five receipts report unchanged source, six predecessors and three PASS records, with successful post-call library checksum verification.

## Deviations and helpers

Bounded proof-only iteration was expressly authorized. The first two failed sources, jobs, review snapshots, logs and receipts are preserved. Error-recovery `sorryAx` in those failed compiler logs is not an accepted proof. No accepted source contains `sorry`, `admit`, `native_decide`, an added axiom, an unsafe or partial declaration. All seven target headers and three definition values remain verbatim. The final axiom-print-only compile preserves the successful proof body's meaning.

Two private helpers, both explicitly bound and strictly replayed:

- `coprime_from_det (a b c d : ℤ) (h : |a*d-c*b| = 1)`: natural coprimality of the first pair's absolute values, by gcd divisibility.
- `unitFrac_data (a : ℕ) (ha : 0 < a)`: canonical numerator 1 and denominator a, from the frozen rational canonicalization theorem.

No new instances were added. The final log has four linter warnings: two frozen but redundant positivity binders and two tactic-style warnings at one line. They do not indicate proof gaps; the frozen binders were deliberately retained. A preparation-only header extraction initially grouped adjacent headers because the original draft omits blank lines; the metadata parser was corrected before the reviewed template was produced. No proof or statement changed as a result.

## Not tested and next decision

Opus owns the independent recompile, strict replay, receipt/pin check and exact statement-fidelity sign-off. The current source/standing table is in `README_R1_v0_1.md`, with independent sign-off explicitly pending. No new Sage computation was requested or run; pre-existing finite reviewer checks are not substituted for these general Lean proofs.

R2–R5 remain unproved in this continuation. There are now 34 queued original targets after this producer result; their manager-audited count does not advance until independent R1 acceptance. The integrated all-60 build and per-row fidelity audit remain separate gates. No Stage B, FF-2/FF-3 execution, G1, Rule 30 conclusion, viewer work, kernel edit, library sync, commit, installation or release follows.

Remote root: `/home/saphir/fvlt_formalization_20261028/ff1_v03_20261103/stage_a_completion_v1`.
