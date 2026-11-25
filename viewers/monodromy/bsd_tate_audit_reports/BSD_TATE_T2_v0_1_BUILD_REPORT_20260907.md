# T2 v0.1 build report — 2026-09-07

T2 is built and sealed as an additive audit candidate. It computes locally minimal models, every tame Kodaira family and the actual local Tamagawa number for primes 5 through 1009, within the documented resource bounds. The final default scratch verifier passed all 505 test groups. This is builder verification; T2 cold standing and any lock ruling remain pending.

The [cold-seat handoff](<C:/Users/robin/s6_atom/cold audit fourier/BSD_TATE_T2_v0_1_20260907/HANDOFF.md>) identifies the proof obligations. The [contract](<C:/Users/robin/s6_atom/cold audit fourier/BSD_TATE_T2_v0_1_20260907/CONTRACT.md>) gives the arithmetic, transformation direction and limits. The [sealed verification receipt](<C:/Users/robin/s6_atom/cold audit fourier/BSD_TATE_T2_v0_1_SEALED_VERIFICATION_20260907.json>) archives the final run and inherited test receipts.

## What changed

The tame Tate engine now computes reduction branches and component polynomials directly. Complete residue-field root and factor witnesses determine c_p for IV, I0*, I_n* and IV*. Alternating star refinements preserve every level and translation and determine n before the discriminant/Ogg cross-check. Local minimality follows from exact short-model invariant valuations. The old consistency gates remain cross-checks.

For example, the included curve y² = x³ − 75x + 875 with the exact point (5,25) has type I1* at 5, discriminant valuation 7, conductor exponent 2 and c_5 = 4. The result is supported by the reduction trace and its polynomial splitting witness. A coherently repaired PARI report carrying an allowed but false Tamagawa value is rejected by the new computation.

Exact model transformations, the selected differential multiplier, imported rational points, repeated visits, twist lineage and markings are carried into the child curve record. All six panel contract bindings move together. T2 and PARI may choose different local models; a replayed coefficient and differential map compares them. Backend-free building and proof replay are also supported.

## Final verification

| Suite | Explicit PASS groups |
| --- | ---: |
| T2, including 99 required PASS fixtures | 127 |
| Separate Python method for the 99 fixtures | 99 |
| Frozen T1 | 66 |
| Frozen T1 Python | 31 |
| All ten inherited v0.3 suites | 182 |
| Total | 505 |

The inherited math receipt retains 84 pair PASS and 84 doubling PASS. Browser, connected-panel and maintenance suites report no page errors. Python uses a discriminant-unit formula for star splitting, distinct from T2's refinement loop; PARI supplies the pinned live backend comparison. These remain builder checks, not a second cold seat.

The manifest has 26 entries and SHA-256 `08bda1b0692ff8a871ea1f9befa8332f44633fc189c95abd6ee8aa03a81bb417`. All 14 external pins verify. Before/after inventories and post-run integrity checks confirm the T2 seal, T1, all schema predecessors, Monodromy.30, linked dependencies, audit files, host plan and pinned runtime bytes are unchanged. Verification ran only in scratch. The new viewer adapter is not part of this package; existing viewer bytes remain unchanged.

## Remaining scope

Certificates apply to the specified prime and model transport. The inventory still names the denominator-cleared integral source model, with any unresolved cofactor visible. Global minimality, Neron normalization, complete curve-level bad-prime inventory and aggregate conductor/Tamagawa products remain subsequent work. Rational point membership stays available without minimality.

The [next-stage plan](<C:/Users/robin/s6_atom/cold audit fourier/BSD_TATE_T2_v0_1_20260907/NEXT_STEPS.md>) separates T3 at primes 2 and 3, T4 global aggregation, live panel consumption and heights. Fable's multiplicative p=3 observation is verified and recorded for T3; T2 itself still rejects that prime. Sage installation/comparison on Serena/Nucleus remains a separate line item and was not run or required here. No rank, regulator, L-function or Sha claim is promoted.
