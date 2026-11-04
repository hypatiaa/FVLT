# FF-1 R5: producer PASS

2026-11-03. **FINISHED (producer compile and strict replay PASS); independent audit and statement-fidelity sign-off pending.** All five remaining original A7 fixture statements are proved. The [8,3] result includes the actual frozen partition certificate and its connection to Mathlib components, not just matching numerical counts.

## Governing inputs and dispatch

The original Stage A order/signature freeze, E1/S1 and reviewed continuation sequence remain in force. Manager R4 PASS is pinned by `ffbb74192b3ef1c037bb9862e81ff96284585717356cc7270e6cb4b31199a302`. R5 template acceptance is recorded in `R5_TEMPLATE_DECISION_v0_1.md`, SHA256 `cec9d25d49255923273e265b400aa560365216062b28e1a3672945352443555a` (#1432, acceptance ledger 1435), independently read and hash-matched.

Fresh metadata-only receipt `2dc111588b3c8bb234e6f2efde432e39cac0644a8ea22ae94466156a54f374e2`, timestamp 23:14:29Z on nucleus through Tailscale, matched every expected library/compiler/Mathlib/checker/runner pin, fourteen predecessor source/object files and seven PASS records. Latest library remained v19, all 381 checksums passed, no writable regular entries were found, and about 28687 MiB was available at load 0.08/0.02/0.01. The preflight ran no mathematical checks or proof compilations.

Bound template `38a69f260e34557d390bb4b547738884fb74f4cebde172133843a47c4beab8a9` and receipt were posted once as **#1433 / accepted ledger 1436**, with exact stored candidate/topic/canonical-ledger verification reported by the coordinator. The all-match acceptance-on-posting gate was met before drafting. R5's clock began at unix **1793747774**, with independent 1800-second deadline **1793749574**. The final replay ended before **1793747961**, about 187 seconds after drafting began. No inherited allowance or excluded review wait was used.

## Exact output and raw verdict

`FVLTFareyFixturesCompletionV1.lean`, namespace `FVLT.FareyContactV1`, imports the exact audited R4 module and standard Mathlib. All five original headers match verbatim. There are no new public definitions, private helpers or instances; all graph, phase, certificate, contact and isolation definitions are imported unchanged.

Final source SHA256: `85b05d8021e6f44979c0f98533ade819f1b88363adfce331cdbe9f26e5ba0a2d`.

Producer object SHA256 on nucleus: `237223a3837de4529d87d08264eeae3eead7bec8d28775b73587e262b7aca9c5`.

| Run | Exit | Seconds | Result |
| --- | ---: | ---: | --- |
| R5Compile01 | 1 | 10.430 | Preserved direct phaseGraph connectivity decidability error; other four targets compiled |
| R5Compile02 | 0 | 11.431 | All five targets compile, zero warnings |
| R5Replay01 | 0 | 12.482 | **PASS, 18/18 declarations**, zero failures/unsafe/partial |

All three calls ran serially on **nucleus over Tailscale**, with accepted runner `d28faa682336f7a04f734bce545b8083ac32b5cbb15060d05fe588b1efb4f22c`: one CPU, nice 19, hard 8 GiB, Lean `-j1 -s65536 -M7680 -D Elab.async=false`, maximum 240 seconds/call, process cap 256, file/output cap 64 MiB. No mathematics ran on Neo.

All five target axiom reports use only `propext`, `Classical.choice`, `Quot.sound`. Strict replay audited every module declaration, including generated finite-proof auxiliaries, against the same allowed set. Imported dependencies are reused, not fully replayed. G1 is excluded. All three receipts report unchanged source, fourteen predecessors and seven PASS records, and successful post-call library checksum verification.

## Certificate semantics and proof scope

For [4,3,2,1], kernel `decide` uses Mathlib's proved finite-connectivity decider to establish actual `Connected`, and separately proves the four memberships and two declared repair edges. No extra vertex/contact count theorem for that profile is claimed by this delivery.

For [8,3], `fixture83_certificate` checks the frozen rational partition `{ {1/9}, {8/9}, phases [8,3] \ {1/9,8/9} }`. It proves the subset guard plus all five existing component-certificate clauses: nonempty parts, coverage, pairwise disjointness, internal induced connectedness and no cross edges. The audited `rational_certificate_count` and component-bijection machinery then proves that its three parts are exactly the three Mathlib connected components. The other two count conjuncts give eleven vertices and eight contacts.

The isolated-set theorem covers arbitrary rational x: a finite subtype check handles members of the phase set, and the explicit subset guard excludes any outside rational from both sides. The isolated vertices are exactly 1/9 and 8/9. Every finite decision is checked by Lean's kernel; no external executable or native evaluator is trusted as a proof.

These are exact finite fixture theorems. They do not replace the separate general R3/R4 results, create an unrestricted profile classification or imply a Rule 30 result.

## Preserved repair

Bounded proof-only iteration was accepted. The first compile could not synthesize the finite-connectivity decision procedure through the `phaseGraph` alias. The repair explicitly changes that proof goal to its definitionally equal `fareyGraph (phases ...)` form before kernel decision. No new instance, graph, proposition, binder or definition value was introduced. The failed source/job/review snapshot/log/receipt is preserved. Its error-recovery `sorryAx` is not accepted proof evidence; the final compile and strict replay are clean.

A pre-call lexical scan also rejected the name of the forbidden native tactic in an explanatory comment. The comment was shortened before any concrete job was created or Lean invoked; the rejected comment-only source is retained as text. No mathematical declaration changed during that preparation repair. Accepted source contains no `sorry`, `admit`, added axiom, native decision tactic, unsafe or partial declaration.

## Remaining audit and final boundary

`README_R5_v0_1.md` supplies the exact source/standing map with independent fidelity sign-off pending. Opus should recheck the closed pins and input binding, independently compile/replay the exact source, inspect the frozen partition semantics and record the five-target outcome.

Manager-audited status remains 55/60 pending that audit. The producer has now supplied proofs for all 60 original targets individually. **Final integrated build/package checks and independent per-row fidelity review remain separately gated.** No whole Stage A §10 status, kernel adoption, sync, seal, installation or release is inferred. Stage B, FF-2/FF-3 execution, G1, Rule 30 forcing, viewer changes and commits remain outside this delivery.

Remote root: `/home/saphir/fvlt_formalization_20261028/ff1_v03_20261103/stage_a_completion_v1`.
