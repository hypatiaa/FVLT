# T3: local Tate reduction at 2 and 3

Additive audit candidate, 2026-09-07. The baseline is the frozen T2 v0.1 package and Fable's T2 cold audit. T2's standing does not transfer to this new construction.

T3 implements the complete general-equation Tate path at primes **2 and 3**, within the declared arithmetic and resource limits. It covers good and multiplicative reduction and every additive Kodaira family, computes the actual local Tamagawa number from residue polynomials, and derives the conductor and wild contribution after establishing the terminal type.

The trace preserves singular-point searches, additive normalization, divisibility tests, complete polynomial witnesses, star refinements, translations and repeated p-scalings. Exact composite maps carry the selected differential, rational points, repeated visits, twist lineage and marking to the child record. All six panel contracts share the new context. The live viewer remains unchanged.

## Use

Run from this directory:

```powershell
node verify.cjs
node verify.cjs --t3-only
node build.cjs --input example-input.json 2 > candidate.json
node build.cjs --input example-input.json 2 --without-pari > offline.json
node assess.cjs candidate.json
```

`--record` takes the v0.3/T1 exact curve record. Custom input has exactly `ainvs`, `selectedMultiplier`, and `points`, using canonical rational strings. Exact point membership does not depend on minimality. Passing a certificate as a second argument to `assess.cjs` replays that certificate as well.

By default, building includes the pinned portable PARI comparison. The two local models are related by a checked exact isomorphism and differential map. The backend does not select T3's branch or Tamagawa number. Backend-free computation remains available.

The default verifier stages all packages and runtime dependencies in scratch, runs T3 and its Python cross-check, then runs the complete frozen T2 verifier including T1 and all inherited browser suites. Workers refuse in-place execution. Runtime discovery and explicit overrides are inherited; no installation or download occurs.

## Scope

T3 certifies one prime at a time. It does not certify a global minimal model, Neron differential, complete curve bad-prime inventory, conductor/Tamagawa product, height, regulator, rank or Sha. The inventory still describes the denominator-cleared integral source model and retains any unresolved cofactor.

Use the frozen T2 tool at primes 5..1009. Together these packages cover the supported local prime domain, with separate certificates and resource bounds. Sage installation/comparison on Serena/Nucleus remains a separate, unrun line item.

See CONTRACT.md, VERIFICATION.md, HANDOFF.md and NEXT_STEPS.md. Builder verification is distinct from cold-audit standing and any lock ruling.

