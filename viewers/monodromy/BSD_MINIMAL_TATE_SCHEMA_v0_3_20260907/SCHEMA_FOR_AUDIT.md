# Minimal models and Tate reduction — schema for audit v0.3

Date: 2026-09-07. Status: **AUDIT CANDIDATE**. This successor adds exact tame Kodaira consistency and conductor bounds to the audited v0.2 contract. It retains scoped exact good-prime assessment. It is not an implemented or certified full Tate engine. The accompanying Monodromy.30.1 viewer is byte-identical to v0.2 and v0.1; existing exact point entry and mcomb connections continue to work. The new general-model packet's live adapter remains future work.

## 1. Organizing object and deliverables

The organizing object remains the exact elliptic curve over Q, with its twist lineage, specified models, rational isomorphisms, selected differential and marked periods. Minimalization changes its presentation; a nontrivial twist changes the arithmetic curve. No j-invariant or picture identifies a Q-isomorphism class.

This draft supplies `minimal-tate-record.schema.json`, exact model/differential transport in `model-replay.cjs`, positive and adversarial fixtures, and a scratch-copy verifier. It additionally supplies `good-prime-certificate.schema.json` and a public read-only `assess.cjs` entry point. The proposed production implementation must add general minimalization, bad-prime Tate reduction/certificate replay and linked-panel consumption. Neither source-reported bad-prime data nor this draft's PASS receipts supply those capabilities. See `IMPLEMENTATION_PLAN.md` for the staged work and completion gates.

The scope includes general Weierstrass models, including primes 2 and 3. A production implementation may return an explicit unavailable result when its work bounds are exceeded. It must never substitute an assumed good prime, Tamagawa factor 1, or complete inventory.

## 2. Exact objects, identity, and provenance

Write E(a) as

\[
y^2+a_1xy+a_3y=x^3+a_2x^2+a_4x+a_6,
\qquad \omega_a=\frac{dx}{2y+a_1x+a_3}.
\]

Store all five coefficients as canonical reduced rational strings: positive denominator, no leading zeros, no negative zero, denominator 1 omitted. Exact inputs never originate by rounding a float. Reject singular models. Recompute b2, b4, b6, b8, c4, c6, Delta and j; the identity c4^3-c6^2=1728 Delta must hold. `modelId` hashes the canonical body `{field,ainvs,invariants}`. It is a model fingerprint, not a canonical isomorphism-class label.

The anchor's source is the exact UTF-8 JSON transcription `{field:"Q",ainvs,selectedMultiplier}`. A non-null `legacyContextId` additionally requires replay of the original BSD v1 packet by its own verifier, an effective-model match and a pinned conversion receipt. The reference checker declines that adapter until implemented. Do not synthesize a legacy ID or rewrite legacy evidence into a new context.

The context hash binds `{anchor,modelId:targetModelId,normalization,transformations,twistLineage}`. The normalization ID hashes the full normalization object. All source byte hashes are checked before interpretation. A certificate digest is a reference, not proof that the certificate has been verified. A producer's status and the consumer's assessment are separate:

| Producer status | Permitted consumer interpretation before independent replay |
|---|---|
| UNVERIFIED | Exact transcription or proposed result, with no certification asserted |
| NUMERICAL | An approximation, no certified enclosure |
| RIGOROUS_BOUND | Source reports a rigorous bound; verify its artifact/method before use as a local bound |
| CERTIFIED | Source reports certification; no automatic local certification |
| CONDITIONAL | Explicit assumptions retained throughout dependencies |

Dependencies reference earlier source artifacts; missing, forward, cyclic and self references reject. Unknown local verification methods reject. No imported `assessment`, audit standing, lock or release field is admitted. The reference checker's result is returned separately. Its legacy top-level `minimalityAssessment: NOT_IMPLEMENTED` refers to the general minimalization engine; `tateAssessment: NOT_IMPLEMENTED` refers to full Tate reduction. These coexist with explicitly scoped local good-prime proofs in `localAssessments`. `bsdPromotion` remains false: no source field or live BSD register is rewritten.

## 3. One transformation convention

An edge `(u,r,s,t)` means **source E -> target E'**, with u a nonzero rational, including negative u. Define

\[
x'=(x-r)/u^2,\quad y'=(y-s(x-r)-t)/u^3,
\]

equivalently x=u²x'+r and y=u³y'+su²x'+t. Map O to O. Recompute all five target coefficients by substitution, not just c4, c6 or j. This uses the convention in [Sage's Weierstrass-isomorphism documentation](https://doc.sagemath.org/html/en/reference/arithmetic_curves/sage/schemes/elliptic_curves/weierstrass_morphism.html).

The exact formulas are

\[
\begin{aligned}
ua'_1&=a_1+2s,\\
u^2a'_2&=a_2-a_1s+3r-s^2,\\
u^3a'_3&=a_3+a_1r+2t,\\
u^4a'_4&=a_4+2a_2r-a_1(rs+t)-a_3s+3r^2-2st,\\
u^6a'_6&=a_6-a_1rt+a_2r^2-a_3t+a_4r+r^3-t^2.
\end{aligned}
\]

Thus c4'=c4/u^4, c6'=c6/u^6, Delta'=Delta/u^12 and phi*omega'=u omega. For the selected differential c omega, transport c'=c/u. Signed u matters for oriented periods; absolute values apply only to real measures.

For successive edges w=(u,r,s,t) then v=(U,R,S,T), the combined tuple is `(uU, r+u²R, s+uS, t+su²R+u³T)`. The inverse is `(1/u,-r/u²,-s/u,(rs-t)/u³)`. Verify composition, inverse and point transport exactly. The old positive scaling x_new=v²x_old, y_new=v³y_old becomes `(u,r,s,t)=(1/v,0,0,0)` and c_new=v c_old. This reciprocal conversion is mandatory.

Quadratic short twists `(A,B)->(d²A,d³B)` and quartic B=0 twists `A->dA` are separate typed lineage edges. They are never placed in the rational isomorphism chain unless an actual rational tuple independently replays. In particular, equal j does not authorize carrying points, ranks, local data or Neron normalization between twists. The v0.1 twist adapter is deliberately limited to these existing exact short-model conventions; general-model twists require a verified conversion path.

## 4. Marking, periods and mcomb jets

Use full periods. Write the ordered period column as Omega=(omega1,omega2)^T. With a transported cycle change M in SL(2,Z),

\[
\Omega'=uM\Omega,\qquad v'=M^{-T}v,\qquad z'=uz,
\quad c'\Omega'=cM\Omega.
\]

Here v is the two-component column of period fractions. Identity marking preserves the exact fractions. Reducing fractions modulo Z² is a display/address operation; retain exact unwrapped derivatives separately. A determinant -1 matrix is not silently accepted as an oriented marking.

Retain the mcomb source bytes and their hash, canonical branch population, actual selected visit, follow/held state, exact alpha/beta and exact phase derivatives. A camera change, foliation ruler or Clifford leaf sweep does not change those bytes. A model change does not change N, m, t1, t2, s or their frequency identities. It changes the coordinates representing the same point and the model differential periods according to the exact tuple.

Under the same fixed tuple, coordinate jets obey dx'/ds=dx/ds / u² and dy'/ds=(dy/ds - s_tuple dx/ds)/u³. The tuple's shear parameter and the mcomb traversal parameter must have different code identifiers. Period velocities transform by the same u and basis matrix as periods; selected-differential velocities remain consistent with c'=c/u. These are transport identities, not L-function or rank calculations.

Numerical elliptic logarithms of imported exact rational points may place them on the marked leaf. Store the exact point, log precision, branch/lattice reduction, residual and evidence status separately. Rational period fractions give complex torsion; neither rationality of cubic coordinates nor infinite order follows from a visual encounter. The inherited period-family restrictions remain visible until a general period adapter is implemented.

## 5. Minimal models and local reduction records

An integral model is not automatically minimal. `minimalModel` identifies the asserted model and either global Q scope or local Q_p scope with exactly one prime. Local scope requires a p-integral model and a minimality witness at that prime; global scope requires integral coefficients and a complete argument for minimality at every prime. A returned tuple only proves isomorphism.

Each local result binds the curve context, actual local model, p, minimality evidence when required and result provenance. It contains reduction type, Kodaira symbol, splitting when applicable, minimal discriminant valuation, conductor exponent, wild conductor contribution, Tamagawa number and Euler polynomial. Pending results are null, never zero-filled. Bad-prime reports require reported minimality evidence. A GOOD result on a p-integral model with unit discriminant supplies its own local minimality proof and may have null minimality evidence, even with no `minimalModel` claim anywhere in the packet. For bad reduction at p=2 and p=3, record the actual Tate branches and residue-field decisions in the referenced trace; no p>=5 shortcuts may supply a certified answer.

Tate's algorithm provides local minimal models, reduction type, Tamagawa numbers and conductor exponents; see [Sage's local-data reference](https://doc.sagemath.org/html/en/reference/arithmetic_curves/sage/schemes/elliptic_curves/ell_local_data.html), which cites Tate (1975) and Silverman IV.9.4. The implementation must select and pin its algorithm/version and expose proof settings. A database transcription alone remains source-reported.

Mandatory consistency rules include:

- p is proved prime within the verifier's supported range or via a checked primality certificate. An arbitrary decimal string is not a verified prime.
- A GOOD result has I0, v_p(Delta_min)=0, conductor exponent 0, c_p=1, and polynomial `[1,-a_p,p]`. Count the full five-coefficient equation including O; do not use short-model formulas at 2 or 3.
- Split multiplicative reduction has I_n with n>0, conductor exponent 1, c_p=n, polynomial `[1,-1]`. Nonsplit multiplicative reduction has c_p=1 for odd n and 2 for even n, polynomial `[1,1]`. In both cases v_p(Delta_min)=n and wild contribution is zero.
- Additive reduction has polynomial `[1]`. Its conductor and c_p require the actual local algorithm; neither is inferred from an excluded short-model prime. The p>=5 tame conductor exponent 2 cannot be assumed at 2 or 3. For additive reduction, `split` is null in this schema; any component splitting decisions remain in the Tate trace.
- Recompute stated valuations on the submitted local model. Internal consistency is weaker than minimality or a completed Tate replay.

For a reported bad prime p>=5, first require v_p(Delta)>0. Then c4 being a unit is the multiplicative consistency test; c4 divisible by p is the additive consistency test under the submitted minimal-model claim. In the multiplicative case, require the split flag and reduction label to agree with whether -c6 is a nonzero square in F_p. Do not apply the bad-prime c4 test to GOOD records: a nonsingular reduction can have c4=0. These arithmetic tests are implemented in v0.2; they leave bad-prime minimality source-reported. The characteristic-specific Tate decisions are described in the [Sage local-data implementation](https://raw.githubusercontent.com/sagemath/sage/develop/src/sage/schemes/elliptic_curves/ell_local_data.py).

The implemented additive Tamagawa consistency sets are II/II*: {1}; III/III*: {2}; IV/IV*: {1,3}; I0*: {1,2,4}; I_n* for n>=1: {2,4}. Enforcing these sets does not determine the actual value, prove the submitted Kodaira type, or certify the bad-prime report. All such reports return `CONSISTENCY_CHECKED_SOURCE_REPORT` and `tamagawaAssessment: NOT_LOCALLY_CERTIFIED`.

Version 0.3 also enforces the following tame additive rule under the submitted p-minimality claim, for p>=5. If v_p(j)>=0, the discriminant valuations 2,3,4,6,8,9,10 require the labels II,III,IV,I0*,IV*,III*,II*, respectively; other valuations reject. If v_p(j)=-m<0, require v_p(Delta)=6+m and the label I_m*. Handle j=0 separately as infinite valuation, in the first branch. This rule runs after good/multiplicative/additive separation, and never runs at 2 or 3. A checked report includes `ADDITIVE_KODAIRA_FROM_DISCRIMINANT_AND_J_P_GE_5`. See `REPAIR_NOTES.md` for the mathematical reference and boundary tests.

For every supplied local result over Q, require f_2<=8, f_3<=5 and f_p<=2 for p>=5, and require f_p<=v_p(Delta) on the submitted local model. The conductor caps and conductor-discriminant divisibility are stated in [MIT 18.783 lecture 24, slide 18](https://ocw.mit.edu/courses/18-783-elliptic-curves-fall-2025/mit18_783_f25_lec_s_24.pdf). Existing wild/tame and Euler constraints still apply. Bad-prime assessments identify `Q_CONDUCTOR_EXPONENT_BOUND` and `CONDUCTOR_DISCRIMINANT_INEQUALITY`. These are necessary consistency checks; they do not establish the actual wild exponent, Kodaira type or minimal model at 2 or 3.

The bad-prime inventory is the prime support of a verified global minimal discriminant. Retain its exact factorization, unresolved cofactor, completeness status and evidence. `complete=true` requires a cofactor of 1, checked prime factors, and a verified minimal model before downstream certification. A large unfactored remainder is not silently discarded. Once all necessary local records are verified, form conductor N=product p^f_p and Tamagawa product C=product c_p. Products computed from reported data remain reported even if the multiplication is exact.

## 6. Prime counts and heights consume the same local data

Maintain distinct lists: displayed-model exclusions, verified curve-level bad primes, and unresolved primes. The Monodromy.30.1 label fix makes the first list explicit. It does not fill the other lists. A prime excluded by a nonminimal or denominator-bearing short model may be good for the curve.

Future prime products may add good primes recovered on a verified integral model, including 2 and 3. Good-prime factors at s=1 are p/N_p with O included. Bad-prime Euler factors are supplied separately from Tate data; do not substitute the point count on a singular cubic or multiply by c_p as an Euler factor. Record which primes and which factor convention enter a finite product. A finite trend supplies no analytic continuation, rank or BSD leading term.

Exact point import and polynomial membership remain available without any minimality result. A point's designation as a generator, independence, saturation, full torsion, rank and regulator each require their own evidence.

Future height records must state a precise Neron-Tate convention. Use the BSD/Cremona convention H(P)=lim 4^(-n) h(x(2^n P)), with H(O)=0, h_x(O)=0, and h(a/b)=log max(|a|,|b|) in lowest terms. The pairing is `<P,Q>=(H(P+Q)-H(P)-H(Q))/2`; its full-basis determinant is the regulator. This is twice the smaller height normalization used by Silverman, so adapters using that convention must multiply heights and pairing entries by 2 (and a rank-r determinant by 2^r). Over Q the normalized versus degree-weighted distinction has degree 1. [Sage's height reference](https://doc.sagemath.org/html/en/reference/arithmetic_curves/sage/schemes/elliptic_curves/ell_point.html#sage.schemes.elliptic_curves.ell_point.EllipticCurvePoint_number_field.height) explicitly identifies the larger convention for BSD and gives H((0,0)) approximately 0.05111140824 on 37.a1. Local-height contributions must sum in this convention with their place weights, coordinate/model correction terms, truncation bounds and precision recorded. They are not individually invariant under arbitrary model changes. Canonical height is invariant under the verified Q-isomorphism. This draft computes neither heights nor regulators.

For a verified global minimal target, its invariant differential is a Neron differential up to sign. A source-to-minimal composite with factor u gives total real measure Omega_min=|u| Omega_source for model differentials, including all real components. Preserve signed cycle data separately. The selected display differential is not automatically the Neron differential. A differential multiplier or transported lattice alone does not establish this normalization.

## 7. Linked-panel acceptance contract

All six consumers bind one shared `contextId`, a reachable `modelId`, the same normalization ID and a `markingId` hashing the complete marking object. The marking hash also binds any mcomb source hash; changing only the view need not change the arithmetic context. Apply changes atomically. During an unresolved or edited model state, clear dependent outputs; never mix old reduction data with a new curve. The existing rational-point membership route stays available on a current exact model.

| Consumer | Required behavior for the production adapter |
|---|---|
| Mcomb | Preserve exact source/selection and phase jets; retain follow/held behavior |
| Carrier addition | Transport all role points and their addition relation; use general negation `-(x,y)=(x,-y-a1*x-a3)` |
| Elliptic model | Show the input and selected model, tuple direction, selected multiplier and minimality evidence status |
| Marked Clifford leaf | Use the same marked periods and exact phase transport; numerical geometry stays numerical |
| Exact curve / BSD evidence | Retain source reports, independent assessments, point membership, twist lineage and normalization bindings |
| Prime product | Distinguish model exclusions, curve bad primes and unresolved primes; use one local-data source |

General-model points may be displayed using an explicitly linked short presentation, but their stored arithmetic model and reverse map remain visible in exports. Unsupported numerical period families must leave exact models, point checks and local records usable. Panel bindings in this audit's fixtures are contract examples, not evidence that these new adapters are implemented.

A new packet is a sibling to the existing `BSD_CURVE_RECORD_V1`, not an in-place reinterpretation. Importers must reject unsupported versions, unknown fields, stale IDs, forged transformations and lost differential factors. Existing source records remain byte-preserved. Migration creates a new context with the old packet/source hash retained. Sha inferred by BSD remains conditional and separate from an independently established group order; no local-data or point-import path may populate either automatically.

## 8. Work bounds and audit gates

Structural limits: packet <=4 MB UTF-8; nesting <=24; 96 digits per rational numerator/denominator; 40 models, 16 isomorphism steps, 8 twist steps, 200 points, 50 local primes, 300 source records. The reference checker caps exact intermediate integer size at 16,384 bits and local trial-prime/count work at p<=1009. A production adapter must expose any broader bounds and decline unsupported work. JSON Schema alone does not enforce rational reduction, arithmetic, graph consistency, primality or source truth.

The auditor should assess separately: schema coherence; exact transport implementation; shipped UI corrections; and the future Tate/height implementation requirements. Run `node verify.cjs` from this folder. It stages fresh copies, uses strict PASS assertions for all 84 inherited formula cases, runs both browser suites and the schema/transport suite, then checks source hashes again. It writes receipts and screenshots only to its announced scratch directory. `node verify.cjs --suite math` is the fast formula-only mode. Direct check wrappers invoke this same safe runner. Build and packaging are authoring commands, not verification commands.

Release of a Tate engine requires independent local-reduction fixtures covering good, split/nonsplit multiplicative and every additive Kodaira family, wild behavior at 2 and 3, nonminimal p-adic scaling, negative u, rational denominators, translations/shears, twists, incomplete factorization, and failed certificates. None of those future release gates is satisfied merely by accepting this schema.

## 9. Concrete audit witness

The packet includes the transformation from y²=x³-16x+16 to y²+y=x³-x using `(u,r,s,t)=(2,0,0,4)`. The input discriminant is 2^12*37; the target discriminant is 37. The source differential multiplier 1 becomes 1/2. The exact point (0,4) becomes (0,0), and the target has nonsingular reduction at 2 and 3, which the input short-model filter excluded at 2. This exact transport and finite counting are locally replayed. The target's global minimality and local data at 37 are independently sourced reports in the fixture, not Tate results produced by this package. [LMFDB 37.a1](https://www.lmfdb.org/EllipticCurve/Q/37/a/1) lists the models and nonsplit I1 reduction with c_37=1.

Additional fixtures cover negative u with nonzero r,s,t, inverse and composed transformations, a nontrivial quadratic twist with separate identity, and exact point membership when minimal data are wholly absent. See `AUDIT_MATRIX.md` for required rejections and the separate implementation gates.

## 10. Derived good-prime assessments and portable replay

`assess.cjs` accepts a packet file without writing to it. Structural validation precedes exact replay and rejects unknown fields and duplicate JSON keys. The output `BSD_LOCAL_ASSESSMENT_REPORT_V1` binds the exact UTF-8 packet hash and contains `localAssessments` separately from the producer's `localData`. The result is not an input packet; importers must not paste its derived assessment fields into a producer record.

When a GOOD record's five coefficients are p-integral, Delta is a p-adic unit and the finite count matches its Euler polynomial, the reference checker returns `LOCAL_EXACT_GOOD_REDUCTION` with local status `CERTIFIED`. The certificate proves good reduction and minimality at this prime, I0, f_p=0, c_p=1 and `[1,-a_p,p]` with O included. The unit-discriminant good branch is also the initial terminal case of [Sage's local-data algorithm](https://raw.githubusercontent.com/sagemath/sage/develop/src/sage/schemes/elliptic_curves/ell_local_data.py). Neither a global minimality claim nor a Tate backend is needed for this elementary case.

The strict `BSD_GOOD_PRIME_CERTIFICATE_V1` schema binds contextId, modelId, normalizationId, p, exact coefficients and discriminant, reduced coefficients, nonzero discriminant residue, N_p, a_p, Euler polynomial and the reference verifier's name/version/source SHA-256. The surrounding assessment binds the original local record hash and the certificate digest. Recompute these values when consuming a certificate; its hash alone is not a proof. This version emits certificates and independently checks its fixtures in Python; it does not implement arbitrary imported-certificate ingestion into the live viewer.

The new computation has empty assumptions and dependencies because it rechecks primality, coefficients, unit discriminant and the finite count directly, without relying on the producer's local-data claim. Preserve `producerStatus`, including CONDITIONAL, alongside this new assessment. This certifies the exact submitted mathematical model, not the truth of an external transcription or its claimed real-world provenance. The certificate's scope is `THIS_MODEL_AND_THIS_PRIME_ONLY`. A packet with a pending/null result remains unavailable; no result is filled implicitly. Global minimality, Neron normalization, the bad-prime inventory, aggregate products and BSD evidence are not promoted by this path.

At p<=1009 the reference loop enumerates all x,y in F_p on the full equation. Number arithmetic in this finite loop remains exact within these bounds; rational input/invariant work uses BigInt. The independent Python fixture checker recomputes invariants with Fraction and counts via quadratic-discriminant Legendre symbols at odd primes, with direct enumeration at 2. Source labels and local proof scope are tested independently of imported minimality evidence.

Runtime discovery and setup are specified in `RUNTIME_SETUP.md`. Verification resolves capable runtimes before dispatching scratch workers and records their actual identities. Missing dependencies or bad explicit overrides fail without silently selecting substitutes or installing packages. The default all-suite run covers ten suites, including local-gate, certificate, valuation and runtime checks; all source inventories remain unchanged. Newly emitted certificates bind verifier 0.3.0 and its exact source bytes, with unchanged good-prime mathematical scope. Full Tate/bad-prime certificates and heights are planned in `IMPLEMENTATION_PLAN.md`.
