# T3 v0.1 arithmetic and evidence contract

## Exact record and transport

The exact elliptic curve over Q is the organizing record. Denominator clearing is an explicit inherited transformation from the selected parent model to an integral source. The complete small-prime trace computes from that source, using all five coefficients. No short-form division by 2 or 3 is performed.

For the source-to-target substitution x=u²x'+r and y=u³y'+s u²x'+t, the existing five coefficient formulas are replayed exactly. With omega=dx/(2y+a1x+a3), the pullback is phi*omega'=u omega; the selected multiplier becomes c'=c/u. Signed u, exact points, repeated visits, twists and markings are retained. The child ledger stores denominator clearing and the composite local step; the trace retains every intermediate step. All six panel bindings move to the same context/model/normalization/marking IDs.

The target of a local proof is not automatically labelled a global minimal model. The model inventory remains attached to the denominator-cleared integral source.

## Tate decisions

The mathematical reference is [Cremona, section 3.2](https://johncremona.github.io/book/fulltext/chapter3.pdf), cross-checked against [Sage's generic local-data implementation](https://raw.githubusercontent.com/sagemath/sage/develop/src/sage/schemes/elliptic_curves/ell_local_data.py). The implementation is restricted to Q with residue fields F2 and F3.

T3 enumerates the singular-point equations F=Fx=Fy=0, retaining all p² evaluations. A verified translation moves the unique singular point to the origin. For unit c4, the node's tangent quadratic decides split versus nonsplit multiplicative reduction. This includes the p=3 extension identified in Fable's audits.

Otherwise the a6, b8 and b6 divisibility tests determine II, III or IV. If they all continue, T3 searches s mod p and t/p mod p for the required coefficient divisibilities. The star cubic then separates the distinct-, double- and triple-root branches. Complete quadratic splitting determines IV, IV* and I_n* Tamagawa factors; the distinct star cubic gives the I0* factor.

In the double-root branch, alternating Y and X refinements retain both shifts and levels. The terminal level determines n, independently of the discriminant valuation. In the triple-root branch, IV*, III* and II* are tested before a coefficient-divisibility witness permits u=p rescaling and a fresh Tate pass.

## Minimality, conductor and finite-field witnesses

A terminal general Tate branch proves local minimality. Good and multiplicative branches additionally identify the unit-discriminant or unit-c4 obstruction. The result names the criterion and rescaling count; it never substitutes the tame short-model minimality criterion at 2 or 3.

Once the branch and geometric component count m are established, Ogg's formula supplies f=v_p(Delta_min)+1-m. The wild contribution is f minus 0, 1 or 2 for good, multiplicative or additive reduction respectively. The conductor witness explicitly names this dependence. The component-count identity and conductor caps are checks, not independent second derivations of f.

Degree-two and degree-three witnesses reuse the frozen T2 finite-field engine. Each contains exact coefficients, all field evaluations, every root with multiplicity, and the residual polynomial with its evaluations. In these degrees a nonconstant residual with no field root is irreducible. The finite fields are perfect, so an irreducible residual is separable, also in characteristics 2 and 3. Canonical root and event ordering is required.

## Public admission and comparison

The public gate rejects unknown properties and duplicate JSON keys before arithmetic, including bound parent bytes. It reconstructs the packet from its parent and prime and checks every field against that reconstruction. A submitted certificate must match the recomputed certificate exactly.

An optional T1/PARI packet must have the same parent bytes and prime, pass its own replay, and contain the pinned backend report. An exact map relates the two terminal models and selected differentials. Kodaira type, minimal discriminant valuation, conductor and c_p must agree. A source-reported c_p cannot override the T3 witness.

The certificate binds the parent hash, context, source/target model, normalization, marking, prime, trace and verifier source hashes. Its scope is ONE_PRIME_2_OR_3_ONLY. Global minimality and Neron normalization stay NOT_ASSESSED; no BSD assertion is promoted. Trusted mathematical inputs are Tate's algorithm and Ogg's formula, not a claim of formal theorem-prover verification.

## Bounds and failures

Primes are exactly 2 or 3. Inherited canonical rational, record-size and arithmetic limits apply, including the 96-digit numerator/denominator bound on reparsed rationals (also derived invariants) and the intermediate bit cap. The trace allows at most 32 rescalings, 64 star-refinement rounds, I_n* index 128, 256 components and 2048 events. Exceeding any limit is an explicit error and cannot issue a certificate.

Packet, envelope and parent size caps remain 12 MB, 16 MB and 4 MB. Two new composite record transformations and inherited point/model/ledger bounds apply. Internal arithmetic helpers require structurally valid input; external callers use assess.cjs. No unavailable result is counted as a successful fixture.

