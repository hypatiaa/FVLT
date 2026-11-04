# Skeleton check: FF-2 data foundations (bus #1459–#1461)

2026-11-03. Skeleton (Claude Opus 5.5). This checks the producer's records by re-hashing and parsing them. It is not my independent recompile or replay, which comes at the final FF-2 audit, and it is not an FF-2 outcome. **All 28 statements are still open.**

## Hashes

Every file named in #1459–#1461 re-hashes to its posted value:
- result `1ac6172a...`;
- manifest `685962e8...`, all 15 of its listed files matching;
- batch close `612be810...`;
- skin compile receipt `d47d963b...`, with object `5d7862ee...` and source `8d165af9...`;
- jobs `160f588b...` and `0ed5cf51...`;
- axiom log `57bc602e...`;
- replay log `094986ba...` and replay receipt `8e29e665...`.

## Skin data source

- The source equals lines 1–105 of the accepted successor `a1ea047d...`, plus a trailing newline, checked line by line by script.
- The comparison receipt `46b5d4f3...` names `22650c5b...`, `a1ea047d...` and `d6a666bd...`.
- Binding `BOUND_BATCH01D` differs from template `95774fa3...` only in the permitted fields.

## Order and clock

| Run | Started | Posting it follows |
|---|---|---|
| Compile | 1793758666.7 | #1459 (1793758624) |
| Axioms | 1793758789.7 | #1460 (1793758753) |
| Replay | 1793758801.3 | #1460 (1793758753) |

- The last child process ended at 1793758802.97, before the deadline 1793758915.
- Wall caps were cut to the time remaining: 125 s and 114 s.
- Sources and reviewed files were unchanged, and the 392 v20 checksums passed after each run.

## Results

- **Skin strict replay:** verdict PASS, 53 of 53 introduced constants, kernel replay completed, 0 failures, 0 unsafe, 0 partial. The axioms used are exactly `propext`, `Quot.sound` and `Classical.choice`.
- **Skin named axiom log:** 29 lines, all parsed. Every axiom is one of the standard three, and `Sign`, its constructors, its recursor and `signValue` use none.
- **Pillowcase data** (checked in #1458): 55 of 55 constants replay with PASS, and its 13 named definitions use no axioms.
- **Total:** 108 introduced constants across the two data modules. Imported Mathlib is reused, not replayed.

## Standing

- **Data foundations clear on the producer's records.** BATCH01 is closed.
- **Next batch.** The proof batch needs a fresh posted binding and a new deadline file, under condition 3 of #1448.
- **Unchanged.** All #1448 conditions stand. FF-3 builds stay held.
