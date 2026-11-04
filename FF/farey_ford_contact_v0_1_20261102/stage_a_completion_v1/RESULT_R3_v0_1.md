# FF-1 R3: producer PASS

2026-11-03. **FINISHED (producer compile and strict replay PASS); independent audit and statement-fidelity sign-off pending.** All ten frozen unit-fraction spine targets are proved, including the graph isomorphism and the general consecutive-interval connectivity criterion.

## Governing inputs and dispatch

Original Stage A order, E1/S1 and signature freeze remain unchanged. R2's independently recorded PASS is pinned by `48e4ee942af299f2fed279057c4852aa6c6d539bf405b5dbad18fe8a72a6c75d`. R3's template decision is `0713a265ea67b8f5938ea339fcee8a3afccc6e65d68681a2812d4506502e2376` (#1422 / ledger 1425).

Fresh metadata-only receipt `a8afc4edd8fc542e37badcb64204320e47cd0f54c01161677bb4946dafcfe4d1`, timestamp 21:47:03Z on nucleus through Tailscale, matched all expected library, compiler, Mathlib, checker, runner, ten predecessor source/object and five PASS-record pins. Latest library remained v19, all 381 checksums passed, no writable regular entries were found, and about 28720 MiB was available with load 0.08/0.02/0.01. The preflight performed no theorem compilation or mathematical checks.

Bound template `32b0444d0945bbe5fc48a0131a1ad7f88f00e17900e43c838907dd764db4e4d8` and receipt were posted once as **#1423 / accepted ledger 1426**, with candidate, topic and canonical-ledger delivery verified by the coordinator. The all-match acceptance-on-posting rule applied. Drafting began only afterwards at unix **1793742553**, deadline **1793744353**. Final replay ended before unix **1793742869**, about 316 seconds from drafting start, inside its own 1800-second cap. No inherited allowance or excluded review wait was used.

## Exact output and result

`FVLTUnitFractionSpineV1.lean` imports the exact audited R2 geometry completion and standard Mathlib. Nine targets and both new definitions are in `FVLT.FareyContactV1`; `unitFrac_tangent` is in `FVLT.FordGeometryV1`, as the original freeze's placement note requires. All ten headers, `vertexSet`'s body and `integerPath`'s header are verbatim. The path graph has exactly the frozen adjacency `|(a : ℤ) - (b : ℤ)| = 1`, with only symmetry/looplessness proof fields. Predecessor definitions are imported unchanged.

Final source SHA256: `21b2efd2defd0d42f7a1238c1ee417926a0033f41df700d13c937feee6156bf1`.

Producer object SHA256 on nucleus: `8d5f4cae1a6693a1e873ecc2ad73e81a50d380254eb289ba304d9ddb67508870`.

| Run | Exit | Seconds | Result |
| --- | ---: | ---: | --- |
| R3Compile01 | 1 | 1.918 | Preserved dependent-witness/API/empty-membership proof errors |
| R3Compile02 | 1 | 1.919 | Only the empty-Finset theorem name remained wrong |
| R3Compile03 | 0 | 1.920 | Ten targets and four helpers compiled, zero warnings |
| R3Replay01 | 0 | 2.772 | **PASS, 33/33 declarations**, zero failures/unsafe/partial |

All four calls ran on **nucleus over Tailscale**, serially, with accepted runner `446d2ceda8cfbfa677df6ba1f8ea6957a6010d86bee5dbef86a7449670b3f896`: one CPU, nice 19, hard 8 GiB, Lean `-j1 -s65536 -M7680 -D Elab.async=false`, maximum 240 seconds/call, process cap 256 and file/output cap 64 MiB. No mathematics ran on Neo.

All 14 theorem axiom prints (ten targets, four private helpers) use only `propext`, `Classical.choice`, `Quot.sound`. Strict replay audited every module declaration, including generated auxiliaries, against the same allowed set. Imported dependencies are reused, not fully replayed. G1 is excluded. All four receipts report unchanged source, ten predecessors and five PASS records, and successful post-call library checksums.

## What the graph proof establishes

The proof builds a Mathlib graph isomorphism from the integer path induced on a finite positive denominator set V to the Farey graph on its unit fractions. For connectedness, a finite walk cannot cross a missing integer: adjacency changes the integer coordinate by exactly one. Therefore a connected induced path contains every integer between V's minimum and maximum. Conversely, for a consecutive interval, induction constructs reachability from its minimum by successive edges. The proof holds for arbitrary finite nonempty positive V; no bounded fixture enumeration is substituted.

The empty graph's preconnected/nonconnected convention is proved separately. The tangency theorem treats equal denominators explicitly using the frozen tangency predicate, then uses R2's tangency law in the distinct case. The gap and mediant/parity results retain every original positivity and gap-size binder.

## Helpers and preserved repairs

Four private helpers, listed and strictly replayed:

- `unitFrac_coordinates`: numerator 1 and denominator a for positive a.
- `path_cut`: a walk in the induced integer path cannot cross a missing integer.
- `induced_path_connected`: the general finite induced-path interval criterion.
- `gap_mediant_value`: the exact rational mediant value across a positive gap.

No new instances or additional public targets were added. Bounded proof-only iteration was expressly accepted. The two failed sources, jobs, review snapshots, logs and receipts are preserved. Repairs supplied dependent membership binders, made a subtype value visible to arithmetic, applied the graph connectivity equivalence to its graph argument, and replaced a broad empty-membership simplification with the library's exact `Finset.notMem_empty` theorem. Tactic-style cleanup was also proof-only. All frozen propositions, namespaces, binders, graph semantics and definition values remained unchanged.

Failed-log error-recovery `sorryAx` is not accepted proof evidence. The final source has no `sorry`, `admit`, added axiom, `native_decide`, unsafe or partial declaration; the final compile and strict replay are clean.

## Remaining audit and scope

`README_R3_v0_1.md` maps all ten targets to the scoped II.5f/classical/helper roles and leaves independent per-row fidelity sign-off pending. Opus should verify the closed pins and binding, independently compile/replay the exact module, check `integerPath` adjacency and namespace placement, and record the ten-target R3 outcome.

Manager-audited status remains 34/60 pending this audit. The producer supplies ten more; R4 and R5 have 16 queued targets. Their own templates and final all-60 integration/fidelity remain separately gated. No unscoped II.5f clauses, Stage B, FF-2/FF-3 execution, G1, Rule 30 result, viewer work, sync, commit, kernel adoption, installation or release follows.

Remote root: `/home/saphir/fvlt_formalization_20261028/ff1_v03_20261103/stage_a_completion_v1`.
