# T4 verification receipts

The package records the builder's verification. It does not award itself an independent cold standing or a lock ruling.

The initial scratch run passed 76 T4 groups and 44 distinct Python groups. The corpus has 42 complete cases, each explicitly PASS, and two controls explicitly UNAVAILABLE because their residual factorization is incomplete. All 42 complete cases agree with the pinned PARI runtime on minimal discriminant, conductor and finite Tamagawa product, and the minimal models are connected by replayed exact isomorphisms.

`t4-fixtures.json` contains the parent bytes, complete packets and assessments. `t4-tests.json` names the 76 groups; `independent-tests.json` names the 44 Python groups. `pari-comparisons.json` records the live runtime, scripts, stdout, hashes and exact model comparisons. The Python method uses Fraction substitutions, the frozen distinct T3 formulas and exhaustive u=p checks at 2/3, and short-invariant/residue formulas at tame primes. It does not ask the JavaScript trace or PARI to choose the local answer. It is a second builder method, not a separate cold seat.

The corpus includes known 37.a1, 11.a1 and CM examples; general Weierstrass coefficients; the y^2=x^3+17 point example; tame-star and j=0 cases; multiple-prime rescalings; rational denominators and signed coordinates; a preexisting negative-u ledger; nontrivial marking; twist lineage; repeated visits and infinity. Reversing local-minimization order yields exactly isomorphic final models with the same discriminant. A dedicated congruence example shows that dropping the t cross term fails.

Public-gate negative tests alter conductor, Tamagawa product, discriminant, prime coverage, local scale and translations, transferred local certificates, differential signs and absolute factors, real-component count, panel binding, verifier hashes, parent bytes, and optional certificates. They also attempt a coherent local rewrite, factorization-completeness promotion and duplicate keys in three JSON layers. Point membership is independently checked before reduction. Caps and custom-input CLI behavior are exercised.

Run `node verify.cjs` for a new full verification in a fresh temporary copy. It includes the frozen T3 chain's 920 groups, for an expected total of **1,040 groups** (76 + 44 + 920). The strict inherited formula tally must remain 84 pair PASS and 84 doubling PASS. `node verify.cjs --t4-only` runs the new 120 groups.

`builder-verification.json` is the pre-seal T4-only receipt; a null candidate manifest there is intentional. A post-seal full-chain receipt is written **beside**, never into, the sealed package and named `BSD_TATE_T4_v0_1_SEALED_VERIFICATION_20260923.json`. Check that receipt's actual status rather than treating the expected total above as evidence of a run.

The runner inventories every source package, external audit and host plan before and after, verifies predecessor manifests/pins, stages the pinned PARI files, and records runtime discovery. Direct workers refuse to run in the source package. Runtime paths in a receipt describe that run; they are not hard-coded executable defaults. A different host needs its own available runtime and a new receipt. No automatic installation occurs.
