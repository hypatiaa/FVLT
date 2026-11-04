# FF-1 R2: producer PASS

2026-11-03. **FINISHED (producer compile and strict replay PASS); independent manager audit and statement-fidelity sign-off pending.** The eight frozen R2 geometry statements are proved. In particular, `kiss_unique` proves that the boundary intersection is exactly the singleton containing the frozen kiss point; membership alone was not used as a uniqueness argument.

## Governing inputs and dispatch

R2 operates under the original Stage A order/freeze, read with E1 and S1, and the accepted continuation plan. Manager R1 audit `823f7386d567a7dbf8b1c5c43e81c85cf8876ce0927c1bc85b9430134317a48d` records the predecessor's independent PASS. R2's template decision is `4c6cfa71ae3d75bf8e2d54edbafaaff905d9ae3758d4665aef03834eb9da6ce9` (#1417 / ledger 1420).

The 21:08:19Z metadata-only nucleus/Tailscale preflight matched every expected value: latest v19; five library pins; compiler identity and executable bytes; Mathlib identity; checker and runner; eight predecessor source/object pins; four manager PASS records. All 381 library checksums passed, no writable regular entries were found, and about 28737 MiB was available (load 0.15/0.05/0.01). No theorem compilation or mathematical check ran in the preflight.

Fresh receipt SHA256 `d95ea1ed09205c845b65730e7b6166826504989e1f7554d47a9afa7af75c1831` and bound template `e658afd2c3a862a1642d520db660fb1fe529136a18d60b247e76f85120f9bdb9` were posted once as **#1418 / accepted ledger 1421**, with exact candidate/topic/ledger verification reported by the coordinator. The manager's all-match acceptance-on-posting rule applied. Proof drafting began only afterwards, unix **1793740235**; its independent 1800-second deadline was **1793742035**. The final replay ended before unix **1793740459**, about 224 seconds from drafting start. No inherited allowance or excluded review wait was used.

## Output and raw verdict

Module `FVLTFordGeometryCompletionV1`, namespace `FVLT.FordGeometryV1`, imports exactly the accepted R1 arithmetic completion, original F1 geometry and standard Mathlib. All eight original headers and three definitions (`disk`, `realAxis`, `tangent`) are verbatim. F1/F2/R1 files and definitions are imported and remain unchanged; the bridge is not imported.

Final source SHA256: `c3251f10239e178c243a7793f35e60fddda64637342adfc7c52fdd95dd5b18a1`.

Producer object SHA256 on nucleus: `ce38bf44fe8556c09588461b69782b6752a2e1bd6fe8361f496981ef252ced9b`.

| Run | Exit | Seconds | Verdict |
| --- | ---: | ---: | --- |
| R2Compile01 | 1 | 3.070 | Preserved proof API/rewrite failure |
| R2Compile02 | 0 | 3.070 | All eight targets and six helpers compiled, zero warnings |
| R2Replay01 | 0 | 3.771 | **PASS, 21/21 declarations**, zero failures/unsafe/partial |

All three calls ran serially on **nucleus over Tailscale**, with the accepted runner `45936364e02939ff24628f446cd2b63088649b20520362b226368041589d23cd`, one CPU, nice 19, hard 8 GiB address space, Lean `-j1 -s65536 -M7680 -D Elab.async=false`, per-call wall cap 240 seconds, process cap 256 and file/output cap 64 MiB. No mathematical computation ran on Neo.

The final compile prints axioms for all 14 written theorems: eight targets and six private helpers. `two_squares` uses `propext` and `Quot.sound`; the other 13 use the allowed standard three. Every compiled target-module declaration, including generated auxiliaries, also passed the pinned strict kernel replay and axiom audit. Imported dependencies are reused rather than fully replayed. G1 is excluded.

All three receipts report unchanged source, eight predecessors and four gate records, with successful post-call library checksum verification. No `sorry`, `admit`, new axiom, `native_decide`, unsafe or partial declaration occurs in the accepted source.

## Proof construction and preserved deviations

The uniqueness proof first establishes a weighted norm identity over complex coordinates. For two circles with positive radii whose centre distance equals the radii sum, a point on both circles satisfies a fixed linear equation. Two such points must coincide. The F1 distance identity supplies that external tangency condition for determinant-one fractions; F1 kiss membership then identifies the unique point. Thus the theorem proves the frozen singleton equality, not merely nonempty intersection.

Six private helpers are listed and replayed:

- `det_nonzero`: distinct rational addresses have nonzero determinant.
- `centre_norm_ge`: distinct Ford centres are at least the radii sum apart.
- `centre_norm_gt`: determinant at least two makes that inequality strict.
- `centre_triangle`: triangle bound through an arbitrary point.
- `weighted_norm_identity`: exact complex-coordinate norm identity.
- `circle_inter_unique`: uniqueness for two externally tangent positive-radius circles.

No new instances or additional public targets were introduced. All helper hypotheses are explicit binders.

The first compile failed on three implementation details: the two-argument norm inequality had been used as a three-point API, a zero difference needed conversion to equality, and set-intersection membership needed its conjunction unfolded. Only those proof bodies were repaired. The failed source, job, review snapshot, compiler log and receipt are preserved. Its error-recovery `sorryAx` is not an accepted proof; the final compile and strict replay are clean. All frozen headers, domains and definition values remain unchanged.

## Remaining review and next decision

`README_R2_v0_1.md` maps each target to its classical/source role and explicitly leaves independent fidelity sign-off pending. Opus should recheck the closed packet's pins and input binding, independently compile and replay the exact source in its own folder, and record only the eight-target R2 outcome. No new Sage check was needed or run; symbolic Lean proofs establish the general statements.

Manager-audited status remains 26/60 until that audit; the producer has supplied eight more, leaving R3–R5's 26 targets queued. Their templates and final all-60 integration/fidelity remain separately gated. No Stage B, FF-2/FF-3 execution, viewer change, G1, Rule 30 result, kernel adoption, sync, commit, installation or release follows.

Remote root: `/home/saphir/fvlt_formalization_20261028/ff1_v03_20261103/stage_a_completion_v1`.
