# How many times does the Möbius lift vanish at alignment?

Give every prime the same complex phase `z`. For a positive integer `N`, let
`d` be the number of distinct primes dividing `N`, and let `k` be the sum of
`v_p(N) − 1` over those primes. The diagonal lift is the polynomial

\[
A_N(z)=z^k(z-1)^d.
\]

`diagonalLift_eval` identifies its value at `z = exp(i t)` with the existing
divisor-sum definition `mobiusLift N (fun _ => t)`. The proof uses the prime
factorization of the Möbius lift in the pinned arithmetic-Fourier package.
`diagonalLift_rootMultiplicity_one` then gives its exact polynomial root
multiplicity at 1. The factor left after removing `(z − 1)^d` takes the value
1 there. Every other phase on the unit circle gives a nonzero value by
`diagonalLift_eval_ne_zero`. At `N = 1` the empty product is 1 and the order
is zero.

For `720 = 2⁴ · 3² · 5`, the three prime directions give `d = 3` and the
remaining exponents give `k = 3 + 1 + 0 = 4`. Lean proves both the polynomial
`X^4 * (X - 1)^3` and its multiplicity 3.

## Where the Stepanov comparison applies

`StepanovCounting.card_mul_order_le_natDegree` proves the polynomial counting
inequality over any field. If a nonzero polynomial has root multiplicity at
least `m` at each of the distinct points in a finite set `S`, then
`m * S.card ≤ P.natDegree`. The proof counts roots with multiplicity.

For the prime-phase lift the multiplicity theorem concerns one alignment on
the diagonal. The RH-equivalent energy averages a weighted sum of lifts over
the full prime torus. A bound on that average would require a further
estimate. Stepanov's curve argument also requires constructing an auxiliary
function with many prescribed zeros and controlled poles.

## Replay

The Lake package pins the [arithmetic-Fourier repository](https://github.com/hypatiaa/arithmetic-fourier-rh/tree/3ba8b062bc2a324a3372b7ada6f7f00983f6a6f1)
and uses Lean 4.35.0. In this directory, with the pinned dependencies available, run

```sh
lake build
lake env lean Checks.lean
lake env leanchecker --fresh MobiusLiftDiagonal
```

## Verification on 25 November 2026

On Scout, Lean 4.35.0 (commit `eb6cafb7290e8bd5f2937522d8d804f58f02bafc`)
compiled the pinned upstream `CoherentEnergyMeasure.lean` from source and
then compiled `MobiusLiftDiagonal.lean` against Mathlib commit
`56a005855ea17e0b0958f73ec801ae140b0a1679`. This run used a fresh
build directory and the existing pinned Mathlib cache.

All seven public theorems in `Checks.lean` reported exactly `propext`,
`Classical.choice`, and `Quot.sound`. The command
`leanchecker --fresh --verbose MobiusLiftDiagonal` exited with status 0.

| Input | SHA-256 |
| --- | --- |
| CoherentEnergyMeasure.lean (upstream) | `581ccf729cf074c0ed39af0123c74fd54976f4ae24b05116440ea1b0c556a903` |
| MobiusLiftDiagonal.lean | `647aebc9dcddd998807443b297f5cc79e0904fb54cac920c61bd3f090aa42472` |
| Checks.lean | `7bb4fe8a08a19077c70cff5d1d3222157e68cc4135214c992fa368cdb6cd1a7b` |
