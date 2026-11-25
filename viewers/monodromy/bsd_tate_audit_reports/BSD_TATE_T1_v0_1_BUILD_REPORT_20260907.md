# T1 v0.1 build report

**Builder result: PASS within the stated scope. Cold audit pending.** This is an additive candidate after Fable's v0.3 audit, not a transfer of its standing or a lock ruling.

Package: [T1 audit handoff](<C:/Users/robin/s6_atom/cold audit fourier/BSD_TATE_T1_v0_1_20260907/HANDOFF.md>). The 28-entry manifest has SHA-256 `de4467a54d77fa6669ecbae43612ffa7425ef6746bcbeba877e0d0edb52b6032`; all 12 external pins verify. The post-seal [verification receipt](<C:/Users/robin/s6_atom/cold audit fourier/BSD_TATE_T1_v0_1_SEALED_VERIFICATION_20260907.json>) records the final run and before/after inventories.

T1 now clears rational denominators, produces candidate minimal models through pinned PARI GP 2.17.4 WebAssembly, and replays exact source-to-target tuples, composition, selected differentials, points and all six panel contract bindings. Original source bytes, twists, markings and repeated visits are retained. Source-reported minimality is separate from locally replayed proof. Exact point membership remains available without minimality or any arithmetic backend.

The first bad-prime proof covers **multiplicative I_n reduction at p>=5** within the bounded prime domain 2..1009. Unit-c4 minimality, actual splitting, conductor exponent and the exact local Tamagawa number are replayed. Good-reduction proofs work throughout the domain, including general equations at 2 and 3. The prime inventory remains explicitly model-level, with an exact unresolved cofactor when needed.

For the 37.a1 witness, y²=x³−16x+16 maps by `(u,r,s,t)=(2,0,0,4)` to y'²+y'=x'³−x'. The exact point (0,4) becomes (0,0), and the selected differential multiplier changes from 1 to 1/2. At 37 the local proof gives nonsplit I1, f_37=1 and c_37=1. It certifies local minimality at 37; it makes no global minimality or Neron assertion.

| Final sealed scratch run | Result |
|---|---|
| T1 adversarial, backend and public-interface groups | 66 PASS |
| Python polynomial/Legendre/tangent-cone fixture checks | 31 PASS |
| Local fixture outcomes | 20 certified; 11 explicitly unavailable |
| Inherited v0.3 suites | 10 suites; 182 groups PASS |
| Strict formula tally | 84 pair PASS; 84 doubling PASS |
| Package, predecessor, audit and runtime bytes | Unchanged |

The Python implementation is a distinct calculation method by this builder, not a second audit seat. Sage is absent on this host. Its generic-Tate producer scaffold has syntax validation only; live execution, a pinned Sage distribution, receiver integration and the Sage/PARI comparison remain outstanding. No system installation was performed.

The audited v0.3, v0.2, v0.1 and Monodromy.30 packages remain unchanged. The Monodromy.30.1 viewer remains byte-identical. T1 binds the six panel contracts in the exact packet; live panel consumption remains V1 work.

The [remaining-work plan](<C:/Users/robin/s6_atom/cold audit fourier/BSD_TATE_T1_v0_1_20260907/NEXT_STEPS.md>) keeps tame additive Tate, wild 2/3 Tate, global minimal/Neron and Tamagawa aggregation, live consumers, imported-point logarithms and heights separate. Unsupported additive or small-characteristic bad-prime reports cannot acquire a T1 certificate. No rank, regulator, L-function or Sha claim is promoted.
