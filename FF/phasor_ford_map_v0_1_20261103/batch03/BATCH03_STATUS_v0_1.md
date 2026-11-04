# FF-3 Batch03: five phase theorems

2026-11-04. Producer-local PASS for the five frozen phase targets. Together with Batch02's eight endpoint targets, **13 of 37 FF-3 theorem targets** pass local compile, named-axiom checks and strict replay. Independent clean rebuild and statement-fidelity review remain pending. No final FF-3 acceptance, kernel adoption or Rule 30 result is claimed.

## Mathematical result

- A nonzero real amplitude gives a real phasor exactly when the rational phase address is integral.
- For integer spin, integrality of the phase address is equivalent to integrality of the Ford address.
- The integer-spin exponential splits into the integer parity factor and the negative Ford-address phase, including negative integer exponents.
- The circle map depends on its declared Ford-address data and is independent of amplitude.
- At the frozen N=3 example, equal phasor values can have different Ford addresses. This rules out treating the unlabelled phasor value as an inverse address encoding.

The nonzero-amplitude guard is essential to the first theorem. Positivity of the shell index and nonzero amplitude in the last example are retained as frozen domain guards even where these particular proofs do not use them. Their unused-variable warnings are preserved, with no linter suppression or statement changes.

## Exact source and verification

Successful source: `attempts/Phase02/src/FVLTRosetteFordPhaseV1.lean`, SHA-256 `2a48f1c65b7a5a31cbeaecac2edf13f2a64fec583e2d70af6473f06a41917459`.

Data dependency: accepted successor `02814fa15dfdafc3551d63943baedf57655f6b671c618895ca8dd8f490809388`. All five public theorem statements match the frozen phase text after newline normalization. No additional public declarations or changed definitions were introduced.

Compile: exit 0 in 1.668 seconds; only four unused-guard warnings. All five named axiom reports contain only `propext`, `Classical.choice`, `Quot.sound`. Strict replay: **9/9 introduced constants**, PASS, completed kernel replay, zero failures, zero unsafe constants and zero partial constants. Together with Data's 64 and Endpoints' 13, the three modules have 86 locally replayed introduced constants.

All jobs ran on nucleus over Tailscale, with readonly library v22, Lean 4.35.0, one CPU, 8 GiB address-space cap, 240-second child cap, and all 396 library checksum entries passing before and after. Sources and protected files were unchanged. G1 remains excluded. Exact runtime receipts and raw logs are retained beside this report.

Phase01 failed only at the final example's exponential simplification. Its source and failure receipt/log are preserved. Phase02 changes one proof body to use the explicit sum of two pi-I phases; all five public statements and the data definitions remain unchanged. No dependent audit ran on the failed attempt.

Posting sequence: #1525 fresh Batch03 binding and Phase01 compile; #1526 proof-only Phase02 retry; #1528 compile-dependent named-axiom and strict replay jobs. Every exact job was posted before launch.

## Line-ending correction and future writing rule

Opus's advisory #1527 found that the existing endpoint source has CRLF, while the frozen header file has LF. Phase01 and Phase02 were already written and posted with CRLF before this advisory was received. Lean accepts these files; statement comparisons normalize line endings. Therefore references to unchanged or verbatim headers in these preparation records mean unchanged statement text after newline normalization, not byte identity with the LF header file.

All existing pinned source bytes remain intact. No conversion or new acceptance is implied. Future source writers must explicitly select UTF-8 without BOM and LF (`encoding='utf-8', newline='\n'`), then check for zero CR bytes before hashing and posting. Any conversion of an existing source requires a fresh additive attempt and newly posted hashes/jobs. The data source itself remains byte-identical to its accepted successor.

## Remaining work

24 frozen theorem targets remain: Arithmetic (15), then Sweep (9). These cover integer-address divisibility and divisor-window recovery, reduced determinant/gcd laws, row and signed-column tangency, and the actual shell-event-to-deduplicated-Farey-set sweep with consecutive determinant one. The unaudited Lemma 6a is not assumed.

New batches require fresh current-library verification, capacity, reservation, an 1800-second clock beginning before proof writing/staging, a posted all-match binding and exact posted jobs. Batch03 origin 1793783796 and original deadline 1793785596 were never extended or reset. Closure prohibits further calls under this batch.

No continuous arcs, dynamical correspondence, factoring advantage, viewer edit, kernel edit, library sync, commit or publication is included. Robin Miller assembled the framework and posed the instrument/map question; the underlying components are classical.
