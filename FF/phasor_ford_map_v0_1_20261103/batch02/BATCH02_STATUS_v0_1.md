# FF-3 Batch02: data foundation and endpoint certificates

2026-11-04. Producer-local checks complete for this chunk. Independent clean rebuild and statement-fidelity review remain required. This is not final FF-3 acceptance or kernel adoption.

## What is proved here

Eight of the 37 frozen FF-3 theorem targets have passed compilation, named-axiom checks and strict all-constant replay on nucleus over Tailscale:

1. A reduced rational determinant is zero exactly when its addresses are equal.
2. The stall classification is equivalent to equality of addresses.
3. The tangent classification is equivalent to Farey adjacency.
4. The break classification is equivalent to distinct, nonadjacent addresses with absolute determinant at least two.
5. Every finite path edge is exactly one of tangent, stall or break.
6. The path-edge tangent label agrees with Farey adjacency.
7. Every tangent edge has an exact rational kiss-point certificate satisfying both existing circle boundary checkers.
8. Every nontangent edge has no endpoint certificate.

These results apply to finite rational address paths. Their tangent certificates reuse the audited Ford-coordinate bridge. They do not construct continuous or oriented arcs, infer dynamics, or recover addresses from unlabelled phasors.

## Sources and checks

The successful source is `attempts/Endpoints02/src/FVLTRosetteFordEndpointsV1.lean`, SHA-256 `53ea5f08a71001be2bb6b4ba7de3932740f7861711058c7bb6ae4890cadde9e0`. All eight public headers are unchanged from the frozen packet. Its data dependency is the accepted two-annotation successor `02814fa15dfdafc3551d63943baedf57655f6b671c618895ca8dd8f490809388`, accepted in bus #1517.

| Module | Compile | Named axiom targets | Strict replay |
|---|---|---|---|
| Data02 | PASS, 1.517 s | 19, permitted standard axioms only | PASS, 64/64 introduced constants |
| Endpoints02 | PASS, 1.618 s | 8, permitted standard axioms only | PASS, 13/13 introduced constants |

Strict replay includes generated constants and proof helpers: 77 constants across the two modules. Both reports have zero failures, zero unsafe constants, zero partial constants, and completed kernel replay. This is producer-local replay, not an independent audit. The eight raw named reports are saved verbatim in `axiomsFVLTRosetteFordEndpointsV1Batch02Endpoints02.log`; the 19 data reports are in the corresponding Data02 log.

Every call used readonly library v22 and Lean 4.35.0, with all 396 library checksums passing before and after, unchanged protected inputs and sources, one CPU, 8 GiB address-space limit and a 240-second child cap. Tailscale source/destination addresses are recorded in each runtime receipt. No mathematical compute ran on Neo. The project import closure excludes G1.

## Preserved attempts and authority

Batch01 Data01 failed on inferred binder types. The accepted successor adds only explicit natural-number types to the two finite-image binders; the original frozen packet is preserved.

Batch02 Endpoints01 failed on two remaining simplification goals. Its source, raw failure log and receipt are preserved. Endpoints02 changes two proof bodies, with all eight public headers and all definitions unchanged. No dependent audit ran against the failed attempt.

The Endpoints01 comparison inherited a stale descriptive sentence saying there were no public theorem headers yet. Its explicit eight-target lists and header comparison were correct. Those posted bytes remain unchanged; the additive Endpoints02 comparison corrects the description.

Posting gates: #1518 bound Batch02 and Data02 compile; #1519 Data02 dependent checks; #1520 data results; #1521 Endpoints01 compile; #1522 proof-only Endpoints02 retry; #1523 Endpoints02 dependent checks. Each exact job was posted before launch.

Batch02 origin is 1793782708 and its original deadline is 1793784508. Capacity was refreshed within this clock; the clock was never reset or extended. No further job may use this batch after its closure.

## What remains

29 frozen FF-3 targets remain:

- **Phase: 5.** Nonzero-amplitude real-axis contact iff integral phase address; integer-spin specialization and parity; amplitude independence of the circle map; equal-phasor/different-address example.
- **Arithmetic: 15.** Integer-address/divisibility and divisor-window recovery; zero cases; reduced determinant multiplication and quotient laws; row and signed-column laws and tangency criteria; reference-column and unit-fraction specialization.
- **Sweep: 9.** Exact shell-contact parameterization; actual finite event membership; the deduplicated address set equals the Farey set; sorted membership and strictness; consecutive signed determinant equals one. The unaudited Lemma 6a must not be assumed.

Suggested next bounded chunk is Phase, then Arithmetic, then Sweep. Each fresh batch needs current library/toolchain verification, fresh capacity and reservation, an all-match posted binding, exact posted jobs, preserved failures, named-axiom checks and strict replay. Library drift returns for binding review. Final FF-3 acceptance still requires an independent clean rebuild/replay and separate fidelity review. No publication, library sync, kernel edit or viewer edit is included.

Credit: Robin Miller assembled the framework and posed the instrument/map question; its Farey and Ford components are classical. No novelty or Rule 30 theorem is claimed.
