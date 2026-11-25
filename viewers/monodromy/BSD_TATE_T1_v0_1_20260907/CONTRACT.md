# T1 audit contract v0.1

This is a bounded replay engine, not the full Tate algorithm. The normative predecessor remains `../BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/SCHEMA_FOR_AUDIT.md`. The parent record is structurally and semantically replayed before any child proof. Imported status words never establish local proof.

## Exact transport

The tuple (u,r,s,t), u nonzero, maps source to target by

`x'=(x-r)/u^2; y'=(y-s(x-r)-t)/u^3`.

The invariant differentials satisfy `phi*omega_target = u omega_source`. A selected differential `c_source omega_source` consequently has target multiplier `c_target=c_source/u`. The sign survives in the ordered and composite tuples, the differential factor, the marking and the child normalization ID. A negative u is not replaced by its absolute value. Absolute values belong only to unoriented real measures in a later consumer.

For denominator clearing, D is the exact LCM of the five coefficient denominators. The tuple `(1/D,0,0,0)` gives `a_i'=D^i a_i`, an integral equation. Each later tuple is independently replayed against all five returned coefficients; composition uses the already audited direction. [Sage transformation definitions](https://doc.sagemath.org/html/en/reference/arithmetic_curves/sage/schemes/elliptic_curves/weierstrass_morphism.html)

The child retains parent sources, points, anchor, twist edges and marking. It appends a transported point for each visit on the parent's current target, including repeated visits and infinity. The point-index map records every correspondence. Point visits on earlier models remain on those exact models. Limits are 200 points, 40 models, 16 total transforms and three added transforms per T1 packet. Old reduction/minimality/aggregate/Neron assertions remain in the bound parent bytes and are cleared in the child; their arithmetic context is not silently reused. All six contract bindings move to the child target atomically.

The inherited marking convention is retained: target marked periods equal the signed composite scale times the recorded SL2Z matrix times the anchor periods. No new basis change is introduced by T1. The inherited contragredient full-period fraction rule is unchanged. The inherited gate still refuses unreplayed legacy/mcomb source packets; the live V1 adapter is pending.

## Arithmetic producer

The process receives a fixed, generated GP script containing only canonical, bounded coefficients and a checked prime. `ellminimalmodel` provides a global candidate and its tuple. `elllocalred` is then called separately on that candidate to retain its actual local tuple, followed by `ellchangecurve`. No local tuple is taken from the tuple-deleting Q output of `ellglobalred`. Global/local candidates are source reports until the separate local trace establishes a supported terminal proof. [PARI elliptic-curve reference](https://pari.math.u-bordeaux.fr/dochtml/html/Elliptic_curves.html)

Reports preserve the exact request, stdout/stderr, their hashes, runtime bytes' pins, Node executable hash/version, adapter hash and PARI version/revision. A strict vector/rational parser is used; GP output is never evaluated as code. The process is capped at 20 seconds and 200 KB output and has no shell interpolation. Missing runtimes, pin mismatches, producer errors and resource exhaustion fail explicitly without fallback or a certificate.

The replay gate compares every raw claim to the stdout transcript, reconstructs both target models, and reuses all v0.3 consistency gates. For good/multiplicative results, finite-field point counts also check the reported Euler sign. Unsupported additive/wild results stay consistency-checked source reports. Source hashes bind bytes; they do not authenticate who produced a report. Certification does not trust their status labels or claimed origin.

## Local proofs

Primes are proved by trial division through floor(sqrt(p)), with exact recorded remainders. Each coefficient denominator is a p-unit. Valuation witnesses contain the exact exponent and residual rational unit; zero is typed INFINITY. The verifier recomputes every witness, its order, and the entire terminal result rather than accepting a log or an allowed Kodaira/Tamagawa pair.

For **good reduction**, v_p(Delta)=0 proves smooth reduction and local minimality. The trace enumerates affine solutions on the full general Weierstrass equation by x and adds exactly one point at infinity. It obtains `a_p=p+1-N_p` and the polynomial `1-a_p*T+p*T^2`. The Kodaira symbol is I0, f_p=0, c_p=1.

For **multiplicative reduction at p>=5**, v_p(Delta)=n>0 and v_p(c4)=0 prove nodal reduction and local minimality. The trace enumerates every root of `z^2=-c6 mod p`, whose nonzero discriminant residue gives zero or two roots. Two roots mean split. The type is I_n, f_p=1, a_p=1 for split and -1 otherwise. The exact Tamagawa number is n for split, 1 for nonsplit odd n, and 2 for nonsplit even n. The Euler polynomial is `1-a_p*T`.

Minimality in these two cases follows directly from invariant scaling: a reducing integral model with v_p(u)>0 would have negative valuation of Delta/u^12 in the good case, or c4/u^4 in the unit-c4 case, contradicting p-integrality. Thus this proof does not merely assume the backend model is minimal. The nodal splitting/type/component facts are the mathematical Tate branch used by the replay engine. [Sage local Tate implementation](https://github.com/sagemath/sage/blob/develop/src/sage/schemes/elliptic_curves/ell_local_data.py)

No additive Tamagawa number is certified merely because v0.3 permits it. A surviving unsupported trace has no certificate. A local certificate binds the entire packet, parent bytes, source/target/context IDs, normalization/marking, prime, trace and both replay/arithmetic source hashes. A claimed certificate is accepted only by recomputing it from the bound packet. This is exact finite mathematical replay in a declared bounded domain, not a machine-checked proof in a foundational theorem prover.

## Inventories and evidence boundaries

Trial division of the integral target's absolute discriminant runs through 1009. Every extracted prime has a proof, and the exact remaining cofactor is always retained. Complete means precisely cofactor=1. A remaining cofactor might be prime or composite; it is not relabelled as a prime. The inventory is explicitly `MODEL_DISCRIMINANT_SUPPORT_NOT_CURVE_BAD_PRIMES`, even when PARI calls the target global minimal.

Full tame additive branches, wild branches at 2/3, global minimality and Neron assessment, curve-level conductor/Tamagawa products and heights remain outside this package. A packet may have a locally certified prime despite an incomplete model inventory elsewhere. Exact rational point membership remains independent of every reduction capability.

Schemas reject unknown fields and duplicate JSON keys before replay. The public packet cap is 6 MB, parent cap 4 MB, validated envelope cap 8 MB; rational and intermediate arithmetic limits are inherited. Out-of-domain requests are explicit errors/unavailable capabilities, never PASS. Internal helpers are not public schema gates.

## Verification meaning

PARI is a pinned live result producer. Python Fraction polynomial substitution and Legendre/tangent-cone calculations are a distinct calculation method written by this builder. They are not a second audit seat. Sage is not live-validated. All expected supported fixtures require explicit PASS; expected unsupported fixtures require explicit UNAVAILABLE with no certificate. The inherited strict 84/84 gate remains active in the default full verifier.
