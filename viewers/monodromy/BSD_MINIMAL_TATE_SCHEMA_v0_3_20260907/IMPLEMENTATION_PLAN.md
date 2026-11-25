# Full Tate reduction, Tamagawa certification and heights

Date: 2026-09-07. Planning baseline: minimal/Tate audit foundation v0.3. Status: **implementation plan; future capabilities below are not delivered by this package**. Each construction produces an additive, pinned audit candidate and keeps the prior cold-audited bytes.

The exact elliptic curve over Q anchors every result. Each artifact binds the curve context, actual arithmetic model, normalization, method, producer version, source hashes, dependencies and any assumptions. Display state cannot supply arithmetic evidence. Exact point import and polynomial membership remain usable throughout all stages; numerical elliptic-log placement can be developed alongside reduction work.

## Delivered baseline

G1 adds bad-prime c4/-c6 consistency and Kodaira-specific Tamagawa sets. G2 certifies the bounded good-prime case by exact calculation on a p-integral model with unit discriminant. G3 discovers and records verification runtimes without fixed host paths. The exact tuple/differential/marking replay, strict 84-case formula gate and scratch-copy default continue to apply.

The v0.2 cold audit attested G1–G3 and raised audit flags H1 and H2. Version 0.3 implements their tame Kodaira valuation and Q-conductor-bound gates before T1, with the same source-report assessment boundary. The audit flags H1/H2 are distinct from the future height stages H1/H2 in the table below. These repairs do not advance full Tate, actual bad-prime certification or height computations.

The current checker does not minimize a model, execute a bad-prime Tate branch, certify a reported additive Tamagawa factor, compute heights, or feed the new general-model packet into live panels. The current prime proof/count domain is 2 <= p <= 1009. Extending that domain requires explicit algorithms and bounds, not removal of a guard.

## Build order and dependencies

| Stage | Deliverables | Depends on | Completion gate |
|---|---|---|---|
| T1: trace and model adapter | Strict local certificate/trace schema, exact backend adapter, denominator clearing, candidate minimal models and complete/incomplete prime inventories | v0.3 | All transformations replay; backend outputs remain reports until their proof traces replay |
| T2: tame Tate | Every p >= 5 local reduction branch, local minimality replay, splitting and actual component data | T1 | Independent fixtures and adversarial traces for every supported branch |
| T3: wild Tate | Complete characteristic-2 and characteristic-3 branches and wild conductor computation | T1; share T2 infrastructure | General equations, repeated scaling and wild cases independently checked; no tame shortcuts |
| T4: certified global reduction | Actual bad-prime c_p certificates, complete local-to-global reconciliation, conductor/Tamagawa product, global minimal/Neron assessment | T2 + T3 and complete prime inventory | Every dependency verified; unresolved data prevent the corresponding aggregate certification |
| V1: linked consumers | One live general-model/local-assessment adapter across mcomb, carrier, model, leaf, BSD and prime-product panels | T1 packet contract; G2 can be consumed first | Atomic context changes, exact transport and provenance survive all six panels and exports |
| P1: imported-point placement | Exact membership receipts and numerical elliptic logarithms for the marked leaf | Exact model and supported period adapter | Membership works without T1–T4; logarithm precision and residual are separate |
| H1: numerical heights | Declared local-height convention, numerical local terms, pairing and Gram determinant for a supplied list | T4 for the chosen minimal-model local-height route; exact point list | Independent numerical agreement, explicit NUMERICAL status, no automatic rank/regulator claim |
| H2: bounded heights | Verified local formulas, archimedean error bounds, interval pairings and determinant | H1 and bounded-arithmetic backend | Replayed error bounds; denominator/zero/pole edge cases and precision failure handled |
| B1: BSD consumers | Regulator only with a certified full basis; normalized leading-term comparison with dependency statuses | H2 plus separate rank, saturation, torsion and L-function evidence | Each factor retains its status; BSD-inferred Sha stays conditional |

T1 is the next construction. V1 and P1 can proceed as soon as their interfaces are settled; the table does not impose a minimality prerequisite on exact point checks. T2 and T3 receive separate coverage receipts, and “full Tate” is reserved for their completed union over the supported Q-domain.

## T1 — exact producer adapter and replayable local records

Create a versioned local certificate containing the input five coefficients, p and its primality proof, exact local model, ordered `(u,r,s,t)` steps, signed composite tuple, invariant valuations, residue decisions and a terminal Tate branch. Bind both source and target model IDs, normalization ID and algorithm/verifier source hashes. A trace must specify enough exact data to recompute each decision; a log line saying “Tate passed” is insufficient.

Use a pinned arithmetic backend as a result producer behind a local process boundary. Begin with Sage's generic Tate path and cross-check against PARI's `elllocalred`, retaining exact data and the backend's proof settings. Sage's local-data implementation exposes the algorithmic branches; its default PARI path and direct PARI calls are not independent algorithms. Pin the selected source revision/distribution when implementation begins. [Sage local-data source](https://raw.githubusercontent.com/sagemath/sage/develop/src/sage/schemes/elliptic_curves/ell_local_data.py)

PARI returns `[f,kod,v,c]` for `elllocalred`, with `v=[u,r,s,t]`. Convert this direction once, verify the five target coefficients and retain the actual local tuple. For curves over Q, `ellglobalred` does not retain these local tuples in its local-data entries; request them separately and reconcile with the returned global model. [PARI elliptic-curve reference](https://pari.math.u-bordeaux.fr/dochtml/html/Elliptic_curves.html)

Clear rational denominators by an explicit isomorphism and replay every step. Factor the integral discriminant with prime certificates and an explicit remaining cofactor. A local computation at a known prime may finish while factorization elsewhere is incomplete. Certifying a complete curve bad-prime inventory requires verified global minimality and the full factorization; keep reported and assessed inventories distinct.

The independent replay layer checks exact substitutions, p-integrality, valuations, finite-field operations, branch preconditions and terminal minimality conditions. An isomorphism alone establishes no minimality. Start with current work bounds and expose `UNAVAILABLE` with a reason when they are exceeded. Larger prime support requires checked primality and efficient finite-field routines with their own tests.

T1 fixtures include rational denominators, signed u, nonzero translations/shears, transformations composed in both directions, twists with different contexts, incomplete factorizations, forged traces, invalid primes, stale source hashes and exceeded work bounds. Exact membership must remain available on all current nonsingular models, including those with no minimality data.

## T2 and T3 — complete local reduction

For p >= 5, implement the complete Tate decisions: I0; split and nonsplit I_n; II, III, IV, I0*, I_n*, IV*, III*, II*. Record residue-polynomial factorizations and roots, translations, p-adic rescalings, component multiplicities and branch termination. The G1 checks become inexpensive consistency gates inside this trace replay. They are not a substitute for determining the actual additive Kodaira type or component group.

At 2 and 3 use all five Weierstrass coefficients and the characteristic-specific Tate branches. Preserve each divisibility and residue-field decision, repeated minimization step and the wild conductor contribution. Verify the conductor with the terminal Kodaira component data and Ogg's identity `f_p = v_p(Delta_min) + 1 - number_of_geometric_components`. This cross-check must not mask an incorrect preceding branch.

For both stages, certify the exact value of c_p by checking the appropriate component/residue-field splitting computation. G1's allowed sets merely reject impossible values; choosing an allowed value does not prove it is the actual one. Where a component polynomial is used, include it, its construction from the local model and the complete checked factor/root data over F_p.

Coverage must include good primes with c4=0, both parities of multiplicative I_n, all additive families, every Tamagawa value that actually occurs in the test domain, twists changing splitting, models obscuring good reduction, and wild conductor examples at 2 and 3. Build a deterministic fixture corpus from two pinned algorithms, then replay with the separate verifier. Include negative traces that change a root, residue, valuation, minimalization step, Kodaira label or c_p while repairing downstream arithmetic. Record unsupported outcomes rather than counting them as PASS.

Only a replayed terminal result obtains a local `CERTIFIED` assessment. Keep source-reported certification visible separately. Any use of a trusted external theorem verifier must name the trust boundary and proof artifact instead of presenting an opaque backend result as an independently replayed trace.

## T4 and V1 — global reconciliation and linked panels

Reconcile local minimal models with one integral global model over Q. Replay its composite transformation and verify minimality at every prime dividing its discriminant; good primes are discharged by the unit-discriminant proof. A complete factorization with all local proofs then supports the certified minimal discriminant, conductor `product p^f_p` and Tamagawa product `product c_p`. An unresolved prime prevents these global certification claims even when partial products are exact.

On a verified global minimal model, the invariant differential is a Neron differential up to sign. For the source-to-minimal tuple use `phi*omega_min = u omega_source`, selected multiplier `c_min = c_source/u`, and total real measure `Omega_min = |u| Omega_source`. Keep the sign for oriented cycles, include every real component in the real measure, and distinguish the selected display differential from the Neron differential.

V1 must consume the same assessment object in all six panels. Implement an atomic context switch with curve/model/normalization/marking IDs, mcomb source bytes, follow/held state and exact visit identity retained. A basis change transports periods and phase fractions by the schema's signed and contragredient rules; mcomb phase jets never become numerical source evidence. General-model points use their exact coordinates and an explicit map to any short plotting presentation.

The prime-product panel keeps three visibly distinct states: displayed-model exclusions, certified curve bad primes and unresolved primes. It can recover good primes on an appropriate integral model, including 2 and 3, as soon as G2 certificates are consumed. Bad Euler factors come from certified local reduction; neither a singular cubic's raw point count nor c_p supplies that factor. Export the finite set and factor convention used. Preserve current exclusion labels and exact point import during the transition.

The existing BSD/mcomb packet adapter must replay the predecessor packet before creating a new context, retain its original bytes/hash and record the conversion. Test model edits, negative u, twists, nontrivial basis changes, hidden panels, held sources, stale data and unsupported period families in every consumer. New live results must clear on context mismatch. A viewer smoke test alone is insufficient evidence of the transport.

## P1, H1 and H2 — points and canonical heights

Accept exact rational points on any nonsingular current model, check the equation with rational arithmetic, and transport them through verified isomorphisms. Membership says nothing about infinite order, independence or a full Mordell-Weil basis. Numerical elliptic logarithms can place these points on a supported marked leaf; retain precision, lattice branch, residual and exact point identity separately. They do not become rational mcomb addresses. [Sage period-lattice reference](https://doc.sagemath.org/html/en/reference/arithmetic_curves/sage/schemes/elliptic_curves/period_lattice.html)

Use the BSD/Cremona canonical height `H(P) = lim 4^(-n) h_x(2^n P)`, with `h_x(O)=0` and `h(a/b)=log max(|a|,|b|)` for reduced a/b. The pairing is `(H(P+Q)-H(P)-H(Q))/2`. This convention is twice the smaller Silverman normalization: multiply such imported heights and pairings by 2 and a rank-r determinant by `2^r`. Sage explicitly uses the larger BSD convention; the 37.a1 point (0,0) provides the reference value approximately 0.0511114082399688. [Sage point-height reference](https://doc.sagemath.org/html/en/reference/arithmetic_curves/sage/schemes/elliptic_curves/ell_point.html)

Define each height artifact by the exact point/list, local models, height convention, local weights/correction terms, precision, method and dependencies. The chosen local-height route consumes the minimal/Tate data. Finite-place contributions require their own validated local-height formulas; a Tamagawa number alone is not a local-height calculation. Archive exact coefficients of log(p) where the formulas provide them. Correct for model changes and prove the truncation of any infinite sum; point denominators can contribute at good primes too.

H1 supplies explicitly numerical local terms, global heights and pairings. Compare with PARI and a distinct duplication/local-height method. Sage's default height backend is PARI, so it is not a second independent algorithm for that comparison. Never label agreement under increased precision a rigorous bound.

H2 adds verified archimedean enclosures with a proved remainder estimate and correct treatment of exceptional/pole/near-zero cases. Arb is a candidate ball-arithmetic backend; it does not by itself prove a chosen height algorithm's error estimate. Store the interval, precision, local bounds and proof method in the receipt. [Arb ball-arithmetic reference](https://python-flint.readthedocs.io/en/latest/arb.html)

Meaningful checks include exact-model invariance, `H(nP)=n^2 H(P)`, the parallelogram identity, zero height for independently known torsion, and independently checked benchmark heights. For bounded releases, compare enclosures and certify determinant/positivity statements only when interval separation permits them. A valid positive lower height bound can prove that a point has infinite order; a positive floating-point value cannot.

## B1 — regulator and BSD evidence

A pairing matrix for an arbitrary point list has a Gram determinant. Call it the regulator of E only after independence and full-basis/saturation evidence establish that the list generates the free part. An index-I sublattice has determinant `I^2 Reg(E)`. Rank bounds, saturation, complete torsion and analytic rank remain separate tasks. The empty determinant convention is 1, but attaching it as the curve's rank-zero regulator requires the corresponding rank evidence.

The leading-term comparison consumes the appropriately normalized real period, regulator, Tamagawa product, torsion order and L-function leading coefficient, retaining each dependency's status. Heights and local reduction do not supply the L-function or rank proofs. A Sha value solved from BSD remains conditional on BSD and on its inputs; an independently established group order has a separate record and provenance.

## Audit and handoff gates for each stage

Ship source pins, exact schema/fixtures, explicit expected outcomes, scratch-only workers, runtime/backend provenance and before/after source inventories. Recompute every derived hash and tuple. No unknown/unavailable result counts as PASS in a fixture that declares a supported case. Retain the original strict 84-case formula and linked-panel regressions whenever the shared viewer or adapters change.

Cold review must distinguish implementation PASS, bounded-domain certification, independent algorithm comparison and independent audit standing. The builder never awards the successor its predecessor's standing. A full Tate release requires both tame and wild branch coverage, actual c_p proofs, certificate rejection tests and global reconciliation; a height release additionally requires the declared error-bound and convention gates above.
