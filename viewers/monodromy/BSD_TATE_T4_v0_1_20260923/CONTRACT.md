# T4 proof contract

## Exact model direction

For every source-to-target tuple `(u,r,s,t)`,

```text
x = u^2 x' + r
y = u^3 y' + s u^2 x' + t
phi* omega_target = u omega_source
c_target = c_source / u
```

All five coefficients, point coordinates, composite and inverse tuples, and differential factors replay in the frozen exact arithmetic. The parent is bound by original bytes, not just a parsed object. Its prior claims remain in those bytes; child claims are recomputed. A twist remains a different curve context, never an isomorphism transport.

## Local minimization without spoiling other primes

Denominator clearing first produces an integral source. Factor its discriminant by the inherited exact trial-division procedure through 1009. For each listed prime p, the frozen T3 engine (2,3) or T2 engine (p >= 5) supplies a replayed local minimal model and a composite tuple `w=(u,r,s,t)`, where `u=p^k`, k >= 0.

A p-local tuple can contain denominators at other primes. Applying it verbatim globally would not preserve integral coefficients. T4 instead chooses integer representatives

```text
R = r                 mod u^2
S = s                 mod u
T = t + s(R-r)        mod u^3
```

Rational residues use an extended-Euclidean inverse of a denominator coprime to p. Representatives are in `[0, modulus)`. Modulus 1 gives 0. Let `v=(u,R,S,T)`. The transition from the local target to the integral target is `inverse(w) followed by v`, explicitly

```text
(1, (R-r)/u^2, (S-s)/u, (T-t-s(R-r))/u^3).
```

Its translation and shear are p-integral. Thus the integral target is p-integrally isomorphic to the certified local minimum. At every other prime, v has unit scale and integral translations. Direct coefficient substitution also confirms global integrality. The discriminant drops by exactly `p^(12k)`; no other prime's discriminant valuation changes.

After all stages, T4 replays the map from every local terminal model to the same final integral model. These transitions have p-unit scale and p-integral translations at the corresponding prime. They preserve local minimality and the certified local reduction, conductor exponent, Euler factor and Tamagawa number. Selected differential transport is checked independently of the model differential.

When the final discriminant factorization is complete, these local proofs cover every prime where minimality is not already implied by a unit discriminant. This establishes global minimality over Q. The exact curve bad primes are the final discriminant's support. Source-model exclusions which become good are retained separately as `recoveredGood`.

This is an implementation of the successive-local-minimization construction described in [Cremona, Algorithms for Modular Elliptic Curves, chapter 3, section 3.2](https://johncremona.github.io/book/fulltext/chapter3.pdf). The integral-lift congruences above are the explicit derivation used here, with exact coefficient and valuation checks at each step.

## Global arithmetic and differential

For each certified bad prime, take its replayed local `f_p` and `c_p`. The conductor is `product p^f_p`; the finite Tamagawa product is `product c_p`. Neither product includes a real-component multiplier. Bad Euler factors come from the local certificate rather than a raw singular point count or from c_p.

On an integral global minimal model, the invariant model differential is a Néron differential up to sign. T4 chooses that model differential as its representative. It retains the signed pullback factors from the current input and the original anchor, and distinguishes the selected differential `c_min omega_min` from the Néron differential. Their ratio is exactly `1/c_min`.

For total real measure, take absolute values: `Omega_min=|u| Omega_input` and `Omega_min=|1/c_min| Omega_selected`. These fields are **scaling factors only**. `periodValue=NOT_COMPUTED`. The real curve has two components for positive discriminant and one for negative discriminant. A later period computation must integrate over all real components using its explicitly declared convention. No numerical period or BSD equality is inferred from this normalization record.

## Partial results and limits

The unresolved discriminant cofactor is unchanged by the permitted p-power scalings. If it is not 1, the result is `UNAVAILABLE: UNRESOLVED_DISCRIMINANT_COFACTOR`, with `certificate:null`. Proven local data and `knownPrimeProducts` survive, explicitly scoped `ONLY_LISTED_PRIMES`. Global minimality, Néron normalization, complete bad-prime inventory and global aggregate remain unassessed/null. Even an input whose unseen factor could eventually disappear has no global certificate until that factor is handled.

The inherited input bounds remain: canonical rationals with numerator/denominator of at most 96 digits, nonzero discriminant, at most 40 models, 16 transformations, 200 point visits and 300 source artifacts; the internal rational work cap is 16384 bits. Each stage's source adapter adds two ledger entries, then the local engine adds its entries, so a parent already near the ledger/visit limit can fail before the outer result exists. These are explicit errors, never PASS or a global claim.

T4 additionally limits source support to 24 listed primes, products to 96 digits, parent bytes to 4 MB, packet bytes to 32 MB, optional certificate bytes to 100 kB, and the validation envelope to 34 MB. Local algorithm work bounds are unchanged. Larger prime factors and factorization/primality extensions require a successor; trial support here is not a claim to handle arbitrary curves over Q within fixed resources.

## Evidence and public gate

`assess.cjs` first applies strict offline JSON schemas, rejects duplicate keys including bound parent JSON, then reconstructs the full packet from original parent bytes. It compares every tuple, local trace/certificate, transfer, inventory, product, normalization, source artifact and panel binding. Optional certificates must equal the reconstructed certificate. Unknown fields reject.

The certificate binds curve context, source and final model IDs, normalization and marking IDs, proof hash, local certificate IDs, and hashes of the global verifier and inherited exact/local engines. It sets `heights=NOT_COMPUTED` and `bsdPromotion=false`. This is executable exact replay, not a formal proof-assistant kernel.

`record` uses the existing v0.3 schema. Its source artifacts identify the replayed local certificates and global proof. A generic v0.3 structural/consistency pass alone does not authenticate T4 certification: consumers must retain the packet and run the T4 public gate. Never adopt an arbitrary record's `CERTIFIED` text as evidence.

`pari-comparison.cjs` runs the pinned runtime on the denominator-cleared source. It checks PARI's exact global transformation, compares minimal discriminant/conductor/Tamagawa product, and verifies an exact unit-scale map between the two minimal models. [PARI's documented ellglobalred tuple](https://pari.math.u-bordeaux.fr/dochtml/ref/Elliptic_curves.html#ellglobalred) supplies N and the finite Tamagawa product as its first and third entries. The comparison is a source report, excluded from the certificate construction. Sage remains unrun and separate.

## Panel and arithmetic boundary

All six record bindings share the final context/model/normalization/marking IDs. Repeated point visits remain distinct, including the point at infinity. Exact membership, transport, twist identity and marking do not depend on a successful global claim. This package does not retrofit the running browser, import mcomb bytes, compute an elliptic logarithm, or turn rational torus addresses into Mordell-Weil generators. Those consumer changes belong to V1/P1.
