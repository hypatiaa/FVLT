# Builder verification

The final pre-seal T2 run passed **127 groups** and **99 explicit PASS fixtures**. The separate Python method passed all **99 fixture groups**. The receipts in this folder's `receipts/` directory identify the source inventories and runtime inputs used before the manifest existed.

Coverage includes every tame Kodaira family and all applicable Tamagawa values, primes 5/7/11, odd/even I_n* through n=18, nonzero refinements, j=0, three successive p-scalings, rational general models and exact repeated point visits, marked twists, good/multiplicative cases, a full good-fibre count at p=1009, and an unresolved cofactor 1013². Every supported fixture requires explicit PASS.

The default full verifier additionally runs the frozen T1 verifier: its 66 T1 groups, 31 Python fixture groups and all ten v0.3 suites (182 groups). This retains the strict 84 pair/84 doubling PASS gate and the existing browser regressions. T2 does not change viewer bytes or claim a new visual test.

After sealing, the builder runs the full default verifier again against the manifest. Its receipt is stored beside the package as `../BSD_TATE_T2_v0_1_SEALED_VERIFICATION_20260907.json`. That receipt binds the final manifest, all source inventories and the inherited run without creating a circular manifest dependency. Reverification writes only to scratch.

The initial authoring probe caught a syntax error in the short-form setup before any model computation ran. The corrected implementation then matched PARI on the initial eight additive examples and on the full fixture corpus. No mathematical failure was converted to PASS or unavailable. Resource/domain rejections remain explicit errors and cannot issue certificates.

The Python calculation uses short invariant valuations and a discriminant-unit formula for star splitting, not the refinement loop being tested. PARI is the live pinned comparison producer. Both are builder validation; neither establishes a second cold-audit seat. Sage on Serena/Nucleus is a separate, still-pending comparison line item and does not gate this candidate.

Standing: builder verification in the declared domain. T2 cold audit and any lock ruling remain separate. Full bad-prime characteristic-2/3 Tate, global minimal/Neron certification, curve-level aggregates, live panel consumption and heights remain future work.
