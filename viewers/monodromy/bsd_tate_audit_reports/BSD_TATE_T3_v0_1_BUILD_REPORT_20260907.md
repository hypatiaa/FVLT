# T3 v0.1 build report — 2026-09-07

T3 is built and sealed as an additive cold-audit candidate. It supplies the general-equation Tate branches at primes 2 and 3, actual local Tamagawa numbers, local minimality traces, and conductor/wild-contribution witnesses within the declared bounds. The complete post-seal scratch run passed **920 groups**. This is builder verification; T3's cold standing and any lock ruling remain pending.

Read the [cold-seat handoff](<C:/Users/robin/s6_atom/cold audit fourier/BSD_TATE_T3_v0_1_20260907/HANDOFF.md>) and [arithmetic contract](<C:/Users/robin/s6_atom/cold audit fourier/BSD_TATE_T3_v0_1_20260907/CONTRACT.md>). The [sealed receipt](<C:/Users/robin/s6_atom/cold audit fourier/BSD_TATE_T3_v0_1_SEALED_VERIFICATION_20260907.json>) archives all final and inherited suite receipts.

## Delivered arithmetic

The p=3 multiplicative extension is included, using the node's actual tangent quadratic. The engine also handles characteristic-2 multiplicative splitting and every additive Kodaira family at both primes. Complete finite-field witnesses determine the Tamagawa values. Singular-point and normalization searches, coefficient divisibilities, X/Y refinements and repeated p-scalings are explicit trace steps. No tame short-model preprocessing is applied at 2 or 3.

For example, y² = x³ − x at 2 now receives a replayed local certificate: type III, minimal discriminant valuation 6, conductor exponent 5, wild contribution 3 and c_2 = 2. Its earlier T1 output remained a source report. In T3 the terminal Tate branch establishes the component type; Ogg's formula then supplies the conductor. The witness states that dependency directly.

The exact composite map transports the selected differential, rational points, repeated visits, twist lineage and marking to the child curve record. All six panel contracts share the transported context. PARI's potentially different local model is related by a verified isomorphism and differential map. Exact point membership and backend-free reduction remain available.

## Verification

| Suite | PASS groups |
| --- | ---: |
| T3, including 190 required PASS fixtures | 225 |
| Separate Python small-prime method | 190 |
| Frozen T2 | 127 |
| Frozen T2 Python | 99 |
| Frozen T1 | 66 |
| Frozen T1 Python | 31 |
| All ten inherited v0.3 suites | 182 |
| Total | 920 |

All 190 T3 fixtures match live pinned PARI and Python. The Python method uses explicit characteristic-specific coordinate formulas and independently exhausts u=p congruences to test each terminal model's minimality. Exact Fraction substitutions, point membership and residue calculations also pass. These remain builder-method checks, not a second cold seat.

Coverage includes every Kodaira family and applicable Tamagawa outcome at both primes, I_n* indices 1 through 16 with both c_p outcomes at each index, j=0, non-minimal and rational inputs, repeated visits and nontrivial marking/twist contexts. The fixture traces contain 28 nonzero Y refinements, 16 nonzero X refinements and 44 rescalings. Public forgeries include allowed but false Tamagawa values with repaired witnesses/transcripts, wrong conductor/minimality data, omitted steps, borrowed comparisons and tampered/transplanted certificates.

The inherited formula tally remains **84 pair PASS / 84 doubling PASS**. Browser, connected-panel and maintenance suites have zero page errors. The final receipt confirms source-byte preservation across T3, T2, T1, all schema predecessors, Monodromy.30, linked dependencies, audit files, the Sage host plan and both runtime files.

The T3 manifest has **27 entries**, SHA-256 `ea0d0bbe2939610e5d2405eba1ef9d548288f122f779566f2fe5ba1e596c10be`, and **19 external source pins**. Verification writes only to scratch. The earlier negative-test correction and the retained rational-size-cap example are recorded in VERIFICATION.md.

## Next boundary

T2 and T3 now provide the two local reduction paths over the supported prime range and resource bounds. Global model reconciliation, Neron normalization, complete curve-level bad-prime inventory and aggregate conductor/Tamagawa products remain T4. The live viewer is unchanged; V1 must consume the transported packet contracts. Heights and the stronger BSD comparison follow their separate dependencies. No rank, regulator, L-function or Sha evidence is promoted.

The [next-stage plan](<C:/Users/robin/s6_atom/cold audit fourier/BSD_TATE_T3_v0_1_20260907/NEXT_STEPS.md>) retains Sage installation/comparison on Serena/Nucleus as a separate unrun line item. It did not gate this construction.
