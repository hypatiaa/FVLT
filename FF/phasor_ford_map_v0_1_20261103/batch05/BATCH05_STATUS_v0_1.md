# FF-3 Batch05: exact shell sweep and Farey-set bridge

2026-11-04. **Producer-local PASS: 36/37 frozen FF-3 theorem targets.** Eight of the nine Sweep targets now pass compilation, named-axiom checks and strict replay. `farey_consecutive_det` remains unproved. Independent clean rebuild and separate statement-fidelity review are pending; no final FF-3 acceptance, kernel adoption or Rule 30 result is claimed.

## What is proved

For a shell N >= 2 and rational spin s in [0,N], integral phase address occurs exactly at s=mN/(N-1), for natural m from 0 to N-1. For nonzero real amplitude this is exactly real-axis phasor contact. The corresponding Ford address is m/(N-1).

The actual finite `shellEvents` definition is proved equivalent to the guarded contact condition. The finite `fareySet` definition is proved equivalent to rational membership in [0,1] with reduced denominator at most B. Deduplicating the actual shell-event addresses over shells 2 through B+1 yields exactly `fareySet B`. Membership in the sorted list agrees with set membership, and the sorted list is strictly increasing.

Set equality and strict sorting do **not** establish determinant one for consecutive entries. That last classical theorem is still absent from the compiled module. The unaudited Lemma 6a is never assumed.

## Sources and checks

Final source: `attempts/Sweep04/src/FVLTRosetteFordSweepV1.lean`, SHA-256 `eebe55f30df902c43f7b1634b39f502917f037ee82cb9f719e943baeff915deb`. It contains eight frozen public statements and two private helpers. All new Sweep sources are UTF-8 without BOM, LF-only, with zero CR bytes checked before posting.

Dependencies are pinned byte-for-byte: Data successor `02814fa15dfdafc3551d63943baedf57655f6b671c618895ca8dd8f490809388` and Phase02 source `2a48f1c65b7a5a31cbeaecac2edf13f2a64fec583e2d70af6473f06a41917459`. The historical CRLF Phase source is preserved, as required by the line-ending advisory; no silent conversion occurred.

| Attempt | Public sweep targets | Compile | Strict replay |
|---|---:|---|---|
| Sweep01 | 5 | FAIL: SortedLT/Pairwise interface | Not run |
| Sweep02 | 5 | PASS, 2.118 s | PASS, 15/15 constants |
| Sweep03 | 8 | FAIL: private numerator cast proof | Not run |
| Sweep04 | 8 | PASS, 2.619 s | PASS, 34/34 constants |

Sweep02 repairs only the proof adapter from `SortedLT` to `Pairwise`. Sweep04 repairs only a private helper's integer-to-rational cast proof. Every failed attempt, its raw log and receipt are retained; no dependent audits ran on failed builds. Public statements and definitions were unchanged. Existing passed proof bodies are retained in the final extension. Linter warnings about unused guards/tactics remain in the raw log; none were suppressed.

All eight final named axiom reports list only `propext`, `Classical.choice`, `Quot.sound`. Strict replay reports completed kernel replay, 34/34 introduced constants, zero failures, zero unsafe constants and zero partial constants. The latest separately checked modules have **151 introduced constants**: Data 64, Phase 9, Arithmetic 31, Sweep 34, Endpoints 13. This is not an integrated rebuild, and predecessor Sweep/Arithmetic counts are not added again.

All eight Batch05 Lean calls ran on nucleus over Tailscale with readonly library v22 and Lean 4.35.0, one CPU, 8 GiB address space and a 240-second child limit. Every call checked all 396 library entries before and after, with unchanged sources and protected inputs. The recorded project import closure excludes G1. No mathematical compute ran on Neo.

## Gates and clock

Posting sequence: #1539 fresh Batch05 binding/first compile; #1540 proof-only Sweep02 retry; #1541 five-target axioms/replay; #1542 partial 33/37 result; #1543 refreshed capacity/eight-target extension; #1544 proof-only Sweep04 retry; #1545 eight-target axioms/replay. Every exact job was posted before launch.

Batch05 origin is 1793785576 and its original deadline is 1793787376. Capacity refreshes did not reset or extend the clock. Closure prohibits further calls under this batch.

## What remains

1. Prove the unchanged frozen `farey_consecutive_det` statement. See `LAST_OBLIGATION_PLAN_v0_1.md` for an unproved implementation plan.
2. Complete a clean integrated build/check of the final five modules with their exact final source/dependency pins.
3. Obtain the independent clean rebuild/replay and separate statement-fidelity review required by #1511. Producer-local progress is not those reviews.

No continuous/oriented arcs, dynamical correspondence, unlabelled-phasor inversion, factoring advantage, viewer edit, kernel edit, library sync, commit or publication is included. Robin Miller assembled the framework and posed the instrument/map question; the components used here are classical.
