# FF-3 Batch04: all fifteen arithmetic theorems

2026-11-04. **Producer-local PASS: 28/37 frozen FF-3 targets.** This includes Phase 5, Arithmetic 15 and Endpoints 8. Sweep 9 remains open. Independent clean rebuild and separate statement-fidelity review are still required; this is not final FF-3 acceptance, kernel adoption or a Rule 30 result.

## What this batch proves

The six integer-address results establish denominator one and integral Ford address exactly when the shell index divides the integer product t2*s; the radius is then one half. The reference integer-contact window recovers exactly the divisors within the stated finite window. Zero spin is kept separate: its address is zero, and every scanned shell is an integer contact.

The reduced-determinant law first multiplies by the two positive gcd factors. Its quotient form follows with a proved nonzero denominator, so integer division is exact here. A private normalization lemma proves that a raw numerator/denominator is recovered by multiplying its reduced numerator/denominator by its gcd.

The row law and signed-column law follow from that determinant identity. Their tangency criteria retain the gcd factors. The signed column uses absolute value and treats zero as a stall. The reference-column criterion uses the existing coprime gcd-product theorem for consecutive integers. The unit-fraction spine has adjacent consecutive terms. All fifteen public statements retain the frozen headers and explicit hypothesis binders.

## Sources and checks

Final source: `attempts/Arithmetic03/src/FVLTRosetteFordArithmeticV1.lean`, SHA-256 `f74e1a1d8f02a60beceb6a1a44a7e5833b2583777f74cd4e36ebed459b67726f`.

It contains all 15 frozen arithmetic statements and three private helpers. The preceding six-target Arithmetic01 and eight-target Arithmetic02 sources and their successful checks remain intact. Their proof bodies are retained in the final extension; no definition or public header was changed. The data source is byte-identical to the accepted successor `02814fa15dfdafc3551d63943baedf57655f6b671c618895ca8dd8f490809388`.

All new arithmetic Lean sources are explicitly UTF-8 without BOM and LF-only, with zero CR bytes checked before posting. Earlier pinned endpoint/phase sources remain unchanged; their historical header comparisons normalize newlines as recorded in Batch03.

| Attempt | Public arithmetic targets | Compile | Strict replay |
|---|---:|---|---|
| Arithmetic01 | 6 | PASS, 1.567 s | PASS, 14/14 constants |
| Arithmetic02 | 8 | PASS, 1.669 s | PASS, 18/18 constants |
| Arithmetic03 | 15 | PASS, 1.868 s | PASS, 31/31 constants |

Each attempt also passes its exact named axiom inventory. Every one of the final 15 reports lists only `propext`, `Classical.choice`, `Quot.sound`. Strict replay includes private and generated constants and reports completed replay, zero failures, zero unsafe constants and zero partial constants. Final compilation has only unused frozen-guard and tactic-style warnings, retained in its raw log without suppression.

The **latest** checked modules contain 117 introduced constants: Data 64, Phase 9, Arithmetic 31, Endpoints 13. This is a sum of separate module checks, not a clean integrated rebuild; it does not add the predecessor arithmetic counts again.

All nine arithmetic calls ran on nucleus over Tailscale, using readonly library v22 and Lean 4.35.0. The runner checked all 396 library entries before and after each call; protected files and source hashes were unchanged. Limits were one CPU, 8 GiB address space and 240 seconds per child. The G1-free import closure and transport are recorded in runtime receipts. No mathematical compute ran on Neo.

## Posting and clock record

- #1530: fresh Batch04 binding and six-target compile.
- #1531: six-target named axioms and strict replay.
- #1532: partial 19/37 result.
- #1533: refreshed-capacity binding and reduced-determinant extension compile.
- #1534: eight-target named axioms and strict replay.
- #1535: partial 21/37 result.
- #1536: refreshed-capacity binding and final seven-target extension compile.
- #1537: all-fifteen named axioms and strict replay.

Every exact job was posted before launch. Capacity refreshes stayed within the same batch clock. Origin 1793784377 and original deadline 1793786177 were never extended or reset. Closure prohibits further calls under this batch. No compile failed in Batch04.

## Remaining nine targets

The Sweep module must still prove exact shell-contact parameterization, its phasor interpretation, shell-contact Ford addresses, actual finite event membership, rational Farey-set membership, equality of deduplicated event addresses with that set, sorted-list membership and strictness, and consecutive signed determinant one. The unaudited Lemma 6a is not assumed. In particular, passing the arithmetic module does not establish the final Farey-consecutive theorem.

After Sweep, final acceptance requires a clean integrated rebuild/replay on independently pinned inputs plus a separate statement-fidelity review. Current producer-local progress does not authorize publication, library sync, kernel editing or viewer changes. Continuous/oriented arcs, a dynamical correspondence, unlabelled-phasor inversion and factoring advantage remain outside FF-3.

Credit: Robin Miller assembled the framework and posed the instrument/map question. Farey/Ford arithmetic and the reused number-theoretic components are classical; no novelty is claimed.
