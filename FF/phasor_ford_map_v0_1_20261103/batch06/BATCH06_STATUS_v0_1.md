# FF-3: all 37 frozen theorem targets pass producer checks

2026-11-04. **Producer-local proof work is complete: 37/37 targets.** The final `farey_consecutive_det` theorem now passes compilation, named-axiom checking and strict all-introduced-constant replay on nucleus over Tailscale.

**Final acceptance remains pending:** an independent clean integrated rebuild/replay and a separate statement-fidelity review of the pinned five-module packet. This report is not those reviews, a library release, kernel adoption, a viewer change or a Rule 30 result. Historical reports that call the last theorem OPEN remain intact; this report supersedes that producer status only.

## The final proof

The final theorem applies for every frozen admissible B and list index, not a finite census. It keeps the original statement and explicit hypothesis binders.

The proof first obtains a Bezout solution and uses Euclidean remainder to put its denominator d within the finite window, with B < b+d. Coprimality gives a reduced rational successor w and the positive signed determinant b*w.num-a*w.den=1. A private interval lemma shows that every rational strictly between x and w has denominator at least b+d. Since members of the Farey set have denominator at most B, no such member intervenes. Strict sorted-index consecutivity identifies the actual next list entry with w, yielding the frozen determinant-one conclusion.

No unaudited Lemma 6a, finite-check substitute, placeholder proof or additional axiom is assumed. The existing eight Sweep bodies are retained. The full Sweep module has five private helpers; none acquires additional public kernel standing.

## Final selected sources

The handoff folder is `../final_source_packet_v0_1/`. Its `sources/` contains exact selected source bytes:

| Module | SHA-256 |
|---|---|
| Data | `02814fa15dfdafc3551d63943baedf57655f6b671c618895ca8dd8f490809388` |
| Phase | `2a48f1c65b7a5a31cbeaecac2edf13f2a64fec583e2d70af6473f06a41917459` |
| Arithmetic | `f74e1a1d8f02a60beceb6a1a44a7e5833b2583777f74cd4e36ebed459b67726f` |
| Sweep | `1d982d2ee145511e2b4a55a72675b14e53b1df2cb94c872abb5baaf3a0697e23` |
| Endpoints | `53ea5f08a71001be2bb6b4ba7de3932740f7861711058c7bb6ae4890cadde9e0` |

The source-comparison script verifies all 37 frozen public header texts, normalizing line endings only for comparison. Data equals the accepted two-annotation successor byte for byte. Historical Phase and Endpoints CRLF bytes are preserved. New Arithmetic and Sweep sources are UTF-8 without BOM and LF-only. No public theorem statement was narrowed, strengthened or replaced during proof repair.

## Checks and limits

Final Sweep compilation: exit 0 in 5.723 seconds. Its nine named reports contain only `propext`, `Classical.choice`, `Quot.sound`. Strict replay: **44/44 introduced constants**, PASS, completed kernel replay, zero failures, zero unsafe constants and zero partial constants. Linter warnings about unused frozen guards and tactic style are retained without suppression.

The latest selected modules have these separate replay counts:

| Module | Public theorem targets | Named data/theorem reports | Introduced constants |
|---|---:|---:|---:|
| Data | 0 | 19 | 64 |
| Phase | 5 | 5 | 9 |
| Arithmetic | 15 | 15 | 31 |
| Sweep | 9 | 9 | 44 |
| Endpoints | 8 | 8 | 13 |
| Total | 37 | 56 | 161 |

The 161 count is a sum of the latest separate module checks. It does not add predecessor counts again and does not claim a clean integrated rebuild.

All six Batch06 Lean calls ran on nucleus over Tailscale with readonly library v22 and Lean 4.35.0. Each checked all 396 library checksum entries before and after, with unchanged source/protected files. Limits were one CPU, 8 GiB address space and 240 seconds per child. The verified project import closure excludes G1. No mathematical compute ran on Neo.

## Preserved attempts and gates

Final01 failed at a private Bezout cast-normalization step. Final02 repairs that helper and compiles the preparation lemmas; it did not yet include the final public theorem or claim replay. Final03 includes the complete final statement/proof but failed at a positive-multiplication-cancellation API call in its private successor helper. Final04 changes only that private proof step and passes all final checks. Failed sources, logs and receipts remain intact, and no dependent audit ran on either failed compile.

Exact posting sequence: #1547 fresh Batch06 binding/preparation compile; #1548 private-helper proof retry; #1549 refreshed capacity/full final-proof compile; #1550 private API repair; #1551 final nine-target axioms/replay. Every exact job was posted before launch.

Batch06 origin 1793786877 and original deadline 1793788677 were never reset or extended. Closure follows the observed end of all runs and prohibits further calls under this batch.

## Review handoff

`final_source_packet_v0_1/PACKET_MANIFEST_v0_1.json` pins 99 files, excluding the manifest itself, SHA-256 `2b4ac17abb7699509028ef20b6c840db33382e4dd4f00946ad4a65b73777cfdd`.

The packet includes all five selected sources, their 30 selected raw logs/runtime receipts, the original freeze packet, accepted rebind and repair controls, the producer comparison and check indexes, a reproduction script and an independent-build README. Its source/header comparison SHA-256 is `33a3c637e4cce36d59716c917760768d11a0888b76c8dcc6a76c6f758637057e`; its check index SHA-256 is `0bd4e836f229a3ec89b1c6c6d263cf027a07e4f429bd15005b1d6ebba47ead89`.

The independent reviewer must build all five modules in a fresh output folder with freshly rebuilt local dependencies, recheck the currently latest library/toolchain and all pins, collect all 56 named reports and strict replay per module, and separately assess statement fidelity. Existing scope and resource gates remain in force. No new human go is required for that already-authorized FF-3 review; no sync/publication or kernel/viewer edit is authorized by this producer result.

FF-3 covers the declared lifted phasor/Ford-address construction, discrete row/column arithmetic, actual shell-event/Farey-set sweep and exact rational endpoint certificates. It does not construct continuous/oriented arcs, infer dynamics or identify registers, invert unlabelled phasors, give a factoring advantage, or reinterpret the scalar amplitude as the n6 reflection. Robin Miller assembled the framework and posed the instrument/map question; its Farey/Ford and number-theoretic components are classical. No novelty is claimed.
