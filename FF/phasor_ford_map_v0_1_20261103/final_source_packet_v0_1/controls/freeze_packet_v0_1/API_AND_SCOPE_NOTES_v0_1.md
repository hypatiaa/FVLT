# API and scope observations for the proposed FF-3 freeze

Read-only source inspection; no Lean invocation, proof drafting or finite numerical test.

The six inherited project modules in INPUT_LIBRARY_SOURCE_CLOSURE_v0_1.json were read from the independently audited FF-1 delivery and matched byte-for-byte against current v21. They provide rawValue and reduced-canonicalization laws; the reduced determinant and adjacency definitions; the real/complex Ford radius, centre and boundary; and the exact rational kissQ/boundaryCheckQ bridge. FVLTFordExactCoordinatesV1.adjacent_kissQ is the inherited endpoint-certificate theorem, not a new FF-3 result.

At pinned Mathlib revision 56a005855ea17e0b0958f73ec801ae140b0a1679, the inspected primary source APIs include:

- Real.sin_eq_zero_iff, Analysis/SpecialFunctions/Trigonometric/Basic.lean:526, giving an integer multiple of pi;
- Complex.exp_int_mul, Analysis/Complex/Exponential.lean:172, using an integer exponent;
- Rat.num_div_eq_of_coprime and Rat.den_div_eq_of_coprime, Data/Rat/Lemmas.lean:236 and :242.

Their source hashes are recorded in INPUT_FREEZE_v0_1.json. Their presence is API evidence, not a proof that the proposed declarations elaborate or that the new theorems follow without further work.

A filename search found no Farey-named Mathlib file in that checkout. This is not an equivalence search or a proof that no reusable Farey lemma exists. The general consecutive-neighbour result in P5 remains a substantial obligation; the work order's finite B=40 check and the unaudited Lemma 6a are not used as proofs.

The actual v21 package configuration is lakefile.toml, not lakefile.lean. A read-only probe of the latter returned not found; the actual TOML is copied and pinned. The inherited library configuration uses -M8192 for its own package builds, as recorded in the v21 readiness receipt. Proposed FF-3 child calls use explicit -M7680 and an 8 GiB address-space ceiling; they do not run a whole-library lake build or change its configuration.

The current locked kernel is v3.4.0, SHA-256 0d6beee233602502576c1d0eedfe5a586e66f1b4e4b8a1858c39189d872ec1a2. The work order's historical v3.3.1 input remains pinned separately. Section II.5 is text-identical in both files. Its Ford-arc row remains historical interpretive text. A proof of this lifted discrete endpoint map would be a candidate for a precisely scoped future correction, not an automatic rewrite or proof of a continuous arc correspondence.

In particular, the scalar r in phasorValue is not n6. The corrected kernel models negative n6 by -conjugate(z), not by negative scalar multiplication. No n6 operation is introduced or identified by this packet. Rational-spin shell contacts and integer-address contacts remain different predicates.
