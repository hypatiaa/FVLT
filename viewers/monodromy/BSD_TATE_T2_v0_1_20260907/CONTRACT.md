# Tame Tate audit contract v0.1

The normative input and transport boundary is the frozen minimal/Tate schema v0.3 and T1 v0.1. Structural validation precedes exact replay. Imported evidence labels supply no proof. The polynomial and transformation witnesses are deterministic, including ascending roots, chosen residue representatives and event order; an equivalent but noncanonical transcript is not accepted as this format.

## Computation and minimality

Starting with the current exact rational model, clear its denominators using T1's explicit isomorphism. This integral source is the model to which the model-discriminant inventory refers. It is deliberately distinct from the local target, which may have denominators at primes other than p.

For p>=5, complete the square and remove the x² term by an exact isomorphism with u=1. In this direction r=-b2/12, s=-a1/2, t=-(a3+a1*r)/2, giving y²=x³+A*x+B with A=-c4/48 and B=-c6/864. Denominators 2 and 3 are p-units. Remove one power of p from u whenever p^4 divides A and p^6 divides B, recording every scaling. The process stops with v_p(A)<4 or v_p(B)<6, with v_p(0)=infinity. Since 48 and 864 are p-units, a further reducing integral change would make c4/u^4 or c6/u^6 nonintegral. This is the local minimality obstruction.

The resulting short equation feeds tame Tate. Good and unit-c4 multiplicative branches continue to work. The early additive decisions use v_p(B)<2, then v_p(A)<2, then v_p(B)<3. Under the preceding conditions these are the usual a6, b8 and b6 tests on a short equation. Later branches use the cubic with coefficients B/p³, A/p², 0, 1. The implementation computes its full finite-field factor/root witness, not just a Kodaira label from discriminant valuation. The mathematical branch reference is [Cremona, Algorithms for Modular Elliptic Curves, section 3.2](https://johncremona.github.io/book/fulltext/chapter3.pdf).

For the double-root branch, translate its root times p to the origin. Alternating quadratic decisions refine the model until a distinct-root quadratic occurs. Every nonzero x translation and every valuation-level increase is retained. The short-form implementation has a1=a3=0 throughout these refinements; the degenerate y quadratic has double root zero, so no y translation is needed. The loop index determines n in I_n* independently of v_p(Delta); Ogg's identity then checks the conductor.

For a triple root the centered model enters the IV*, III*, II* decisions. The initial short minimality proof rules out a final nonminimal branch. No p=2 or p=3 shortcut is taken by this engine. The generic implementation used for comparison of the branch structure is [Sage's local Tate source](https://github.com/sagemath/sage/blob/develop/src/sage/schemes/elliptic_curves/ell_local_data.py); no Sage execution is claimed.

## Tamagawa and component witnesses

Every residual polynomial records the rational coefficients used to construct it, their residues, all evaluations in F_p, roots with multiplicity, the residual factor and its evaluations. Remaining quadratic/cubic factors with no F_p root are irreducible. In degrees at most three and characteristic at least five, any repeated factor has a rational root; the complete factorization therefore also decides separability. A zero leading coefficient is rejected rather than changing the asserted degree.

Distinct roots of the star cubic give I0* and c_p=1 plus the number of rational roots. The IV and IV* quadratics determine c_p=1 or 3. The terminal star quadratic determines c_p=2 or 4. The other additive branches have fixed c_p: II/II* give 1 and III/III* give 2. The residue construction and root proof are necessary; an allowed-value set is not sufficient.

The result records the geometric component count and the standard multiplicity **multiset**, not a labelled adjacency graph or a presentation of the component group. For every terminal branch the conductor obeys `f_p=v_p(Delta_min)+1-number_of_geometric_components`. Tame additive f_p is 2, multiplicative f_p is 1, and good f_p is 0. All v0.3 c4/splitting, Kodaira/discriminant/j, conductor and Tamagawa consistency gates are applied again to the terminal result.

## Exact linked transport

The child ledger contains denominator clearing and the composite of the full local trace, keeping within the inherited record bounds. The full ordered transformations remain in the trace with both coefficient vectors and signed differential multipliers. Replay reconstructs the trace and composite and compares the whole packet.

The tuple convention remains x'=(x-r)/u² and y'=(y-s(x-r)-t)/u³. Thus phi*omega'=u*omega and c'=c/u. The exact marking, its full-period convention and twist lineage remain attached to the same anchor curve. The six panel bindings move together. Point-index correspondence preserves repeated visits and infinity. Old assertions remain in bound parent bytes and are cleared in the child; local certification does not establish global minimality or Neron normalization.

A comparison contains a complete T1 packet for the identical parent bytes and prime. Its own structural and arithmetic gates must replay. The map from T2's target to the PARI target is inverse(T2 composite) followed by the PARI composite; all five coefficients and selected differential factors are checked. Its local type, discriminant valuation, conductor and Tamagawa number must agree. Hashes bind source bytes, not producer authorship. The proof's arithmetic never depends on a comparison being present.

## Independent builder calculation

Python recomputes short invariants and minimality and determines the type from the minimal valuations. For I_n* it avoids the refinement loop: let D_unit=Delta_min/p^(n+6) and r be the nonzero double root of the cubic formed from A/p² and B/p³. Even n tests whether D_unit is a square; odd n tests whether -3*r*D_unit is a square. These give c_p=4 for a square and 2 otherwise.

Derivation for this alternative check: lift the critical point r to sufficient p-adic precision so the linear coefficient vanishes to the required order. Write the critical value as p^n*beta. Modulo p, D_unit=-1728*r³*beta. The odd terminal quadratic tests beta and the even one tests -3*r*beta. Since 576*r² is a nonzero square, the asserted tests follow. This is a separate computation method by the builder, not an independent audit seat or a substitute for the main trace.

Python additionally checks polynomial substitutions, differential ratios, exact point membership and residue evaluations. Live PARI comparison is performed on every comparison fixture. Sage on Serena/Nucleus remains a separate line item.

## Bounds and certificate status

The public packet cap is 12 MB and envelope cap 16 MB; parent input remains capped at 4 MB. Rational parsing and intermediate limits are inherited. Limits also include 32 p-scalings, 64 star-refinement rounds, I_n* index <=128, 512 events and 256 components. Exceeding a limit or requesting another prime produces an explicit error/unavailable capability, never PASS. Internal helpers expect schema-validated objects.

A local certificate binds the entire packet and trace, parent source hash, source/target/context IDs, normalization/marking, prime, and the hashes of the verifier, Tate engine, finite-field module and inherited arithmetic/transport. A supplied certificate is compared with the freshly recomputed certificate. This is exact algorithmic replay in a declared bounded domain, not a foundational theorem-prover artifact. Builder PASS and any later cold-audit standing remain distinct.
