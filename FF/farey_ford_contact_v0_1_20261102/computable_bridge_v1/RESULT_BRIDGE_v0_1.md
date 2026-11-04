# Computable Ford-coordinate bridge: producer PASS

2026-11-03. Producer result only; awaiting Opus's independent compile, strict replay and smoke rerun. Authority: final template acceptance #1405, SHA256 `539c4e8479f07df4723d075569e7ac3b099f10c352c24bf425139be117cc4cf8`.

The exact rational producer now computes Ford radii, centres, kiss points, squared distances and boundary decisions. Twelve frozen theorems link those computations to F1's existing real and complex definitions, including correctness of the boundary checker and membership of a Farey-neighbour kiss point on both circles. This supplies an executable exact-coordinate interface for a viewer without changing F1.

## Verification

All Lean execution was on nucleus through Tailscale (`100.105.106.41`). No Lean or mathematical tests ran on Neo. Lean 4.35.0, v19 library, pinned executable and checker, and all four F1 source/object pins were checked by the accepted runner. Each call used one CPU, nice 19, 8 GiB address-space cap, a 240-second maximum and the shared serial lock. The bridge's independent 1800-second allowance started at unix 1793712003; all six calls finished before 1793712541, within that allowance.

| Call | Exit | Seconds | Result |
| --- | ---: | ---: | --- |
| BridgeProducerCompile01 | 0 | 0.769 | Rational producer compiled |
| BridgeProofCompile01 | 1 | 1.718 | Preserved failed norm-square proof |
| BridgeProofCompile02 | 0 | 1.721 | All 12 links compiled |
| BridgeProducerReplay01 | 0 | 1.318 | Strict replay PASS, 11/11 declarations |
| BridgeProofReplay01 | 0 | 2.869 | Strict replay PASS, 19/19 declarations |
| BridgeSmoke01 | 0 | 0.767 | Six groups, 24 comparisons, 24 passed |

Both strict checker reports have zero failures, zero unsafe declarations and zero partial declarations. Every target declaration's axiom dependencies are confined to `propext`, `Classical.choice` and `Quot.sound`; some use fewer or none. This replays all declarations of the two target modules, not every imported library dependency. G1 is excluded.

All six receipts report unchanged source, unchanged F1 dependencies and successful post-call library checksum verification. The latest successful compile prints the axiom dependencies of all 12 links. No `sorry`, `admit`, new axiom or `native_decide` occurs in the accepted sources.

## Preserved failure and repair

The first proof compile failed only in `sqDistanceQ_cast`: simplification expanded the squared norm too early. The authorized proof-only repair rewrites with `Complex.sq_norm` before simplifying coordinates. No frozen statement or definition changed. The original source snapshot, manifest, failed log and receipt remain in the packet. The failed log's error-recovery `sorryAx` is not an accepted proof; the successful compile and strict replay are clean.

A preparation-time lexical check also initially matched lowercase words in a comment because PowerShell matching was case insensitive. The metadata helper was corrected to case-sensitive matching before execution; no mathematical source was changed by that correction.

## Computability and scope

`FVLTFordRationalV1.lean` imports only `Mathlib.Data.Rat.Defs`, has no noncomputable definitions, and uses rational/integer/natural computations. `FVLTFordRationalSmokeV1.lean` imports only that producer, so its successful execution exercises the rational interface without importing the real/complex proof module. None of the bridge sources imports `FVLTFareyCertificatesV1`.

The fixture expectations remain the six preregistered groups: radii/centres at 0, 1, 1/2 and -3/4; the adjacent pair 1/2 and 1/3 with kiss point (5/13, 1/13); and a nonadjacent pair with both boundary decisions false. Their 24 successful comparisons are finite execution evidence, separate from the 12 general theorems.

Not established here: the optional converse, kiss-point uniqueness, the rest of FF-1 Stage A, a phasor-to-Ford arc map, or any Rule 30 theorem. No library update or release is claimed. The closed successor manifest pins the packet for independent review.

## Final source pins

- `FVLTFordRationalV1.lean`: `fdccda2c22abe186acc8530f4c7f28bcbce7c8498407061dd2f5ba693c606559`
- `FVLTFordExactCoordinatesV1.lean`: `23f776a40d9daec1cd7ec4f27c9c64917be6430595416756c6d7fe7d88dc7f3d`
- `FVLTFordRationalSmokeV1.lean`: `f5dfe53f2fee0f20dd49df2e5fe1e9328f3a468d1e0b2f580cc7fc3641f49f4e`
- Producer object on nucleus: `6691b599440e4413ed4dd2aed348cbc12d419177a5465044c22515a14fd446f6`
- Proof object on nucleus: `ff7193e200351820627eba32fe846892e4ff2c0fdea43b1b3109d62c7328a3e2`

Remote root: `/home/saphir/fvlt_formalization_20261028/ff1_v03_20261103/computable_bridge_v1`.
