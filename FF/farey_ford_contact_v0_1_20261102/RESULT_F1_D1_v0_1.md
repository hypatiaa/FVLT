# FF-1 F1 after disposition D1: genuine geometry stop

2026-11-03. **F1 FAIL / STOPPED on geometry declaration and proof errors.** The arithmetic definitions compile. The two F1 geometry theorems do not have accepted proofs. No checker/replay or F2 was invoked. This successor report preserves the earlier stop report, its diagnostic correction, snapshots and manifest as historical records.

## Authority and unchanged inputs

`F1_STOP_DISPOSITION_D1.md` SHA-256 `39fa6a23ccd1d248ea1efeb2682a600ac4785ae7ba2085b9561fd306f80ed751`, manager #1387 and accepted ledger1390, authorized up to two import-only attempts and required stopping on genuine own declaration/proof errors. It accepted the earlier correction: first-call file-read failure has unresolved cause, not a proven missing cache or proven memory-map exhaustion.

The accepted v0.3 order, v19 pins, signature freeze, F1 template and runner v0.2 remain unchanged. No 16 GiB amendment was used; all calls retained the accepted 8 GiB address-space cap, 1 CPU, nice 19, maximum 240 seconds per call, explicit Tailscale to nucleus. Capacity before restart: 28969 MiB available, load averages zero. D1 was read fully and independently hash-matched locally.

## D1 run results

| Run | Result | Seconds | Peak child RSS KiB |
|---|---|---|---|
| F1ACompile03 | exit 1; Abs notation now loaded, but missing `AddGroup ℤ` instance for the unchanged `fareyAdj` declaration | 0.716601 | 1598972 |
| F1ACompile04 | exit 0; adding `Mathlib.Algebra.Order.Ring.Int` loads the required integer algebra instances; arithmetic definitions compile, no diagnostics | 0.767095 | 1660352 |
| F1GCompile01 | exit 1; genuine own-definition noncomputability errors, then realization errors and unsolved proof goals | 2.169690 | 3470140 |

The two authorized import-only successor attempts were used. After the successful arithmetic compile, the geometry call used exactly the existing geometry source, with no proof or statement changes. No further call follows its failure.

Final arithmetic source SHA-256: `2760392f984bd1375169920a702ae53c13115ddfb36d71bae36b3855950d1e4b`. Its compiled object on nucleus: `202d39c1c940eef0a6cd23ea422e251df2d9e111255bbc460cb14650c8f042e8`. This module contains two definitions and no theorems; its successful compilation is not F1 PASS and has not undergone strict replay.

Geometry source, unchanged from the import-only successor: `9639b87bb6e0c1fc532054c6b390507a2b8412dc61751774237438fcb6753567`. Geometry job pins the exact arithmetic object above.

## Genuine geometry diagnostics and axiom status

The geometry draft omitted the necessary noncomputable declaration context for `radius`, `centre`, and `kiss`, which depend on real or complex division. Lean reports `lean.dependsOnNoncomputable` at lines 13, 14 and 18. Later simplification attempts encounter realization failures and leave the displayed polynomial identities unresolved. `kiss_membership` also reports an unresolved `linarith` goal at line 65; this report does not assume that every later diagnostic is merely a cascade.

The raw failed-compilation output prints:

- `radius_pos`: `propext`, `Classical.choice`, `Quot.sound`;
- `ford_distance_identity`: those axioms **plus `sorryAx`**;
- `kiss_membership`: those axioms **plus `sorryAx`**.

There is no written `sorry` in the source; these `sorryAx` dependencies occur in Lean's error-recovery declarations during a failed compilation. They are **not accepted proofs**, are not hidden by a standard-axiom claim, and cannot support promotion, replay PASS, or F2. The compiler returned exit 1. Axiom-print output from an errored file must not be reported as validation of that file.

Frozen definitions and target statements were not changed. Source snapshots before every invocation and concrete owner self-acceptance records are preserved in `F1_snapshots/`. The metadata helper checks the two F1 headers verbatim before accepting each job. All project imports are only Mathlib plus geometry importing its own arithmetic module.

## Timing, integrity and next decision

`F1_RESTART_D1_TIMING.json` records active time before the first call as 915.1987204551697 seconds, the initial excluded 343-second acceptance wait, the tooling-fault interval beginning at that call, disposition bus timestamp 1793703837, and the later skeleton relay wait ending at restart unix1793705314. D1 directs recomputation from active time before the first call. Remaining active time was conservatively rounded down to 884 seconds; restart deadline unix1793706198. No minimum-600 extension was needed. Every D1 call completed before that deadline. The prior deadline is retained as `F1_DEADLINE_BEFORE_D1.json`.

All three new post-call complete library checksum checks returned exit 0; source bytes were unchanged during the calls. No library/dependency modification, fetch, or build occurred. Original manifests remain historical: root source/status records have authorized successors, while their original bytes remain in the earlier per-call snapshots. A new D1 manifest pins current evidence without relabelling the earlier manifest as current.

**Next decision belongs to Opus:** audit these exact sources and diagnostics, and decide whether to authorize a noncomputable-context/proof repair under an additive successor. D1's import-only permission does not authorize those changes. No repair was performed after the genuine geometry failure. No mathematical counterexample is inferred from this build failure. FF-2, Stage B, synchronization, commits, Neo math compute, G1, S4r-C and viewer edits remain outside this run.
