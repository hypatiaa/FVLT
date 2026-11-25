# M4 mathematics and evidence boundary

## Exponent group, orbits and cosets

For a verified factorization N = product p_i^a_i, use n_i = a_i+1 and G = product Z/n_i. The tuple e represents exactly product p_i^e_i; the exponent sum is sum e_i of the canonical representatives. Distinct tuples remain distinct even if a character or drawing identifies them.

The coordinate step v_i has order n_i/gcd(n_i,v_i). The step in the product has order the least common multiple of these orders, q_atom. Its cosets partition G into |G|/q_atom disjoint orbits. Enumerating one exact orbit and taking its lexicographically least tuple gives its canonical representative. For small G, a visited-tuple set partitions the entire group; for larger G only the selected orbit is computed.

The zero step has order one. A step in a cyclic group need not generate it. Div(4) has coordinate period three, while Div(8) has coordinate period four: step two has orders three and two respectively.

The character k has phase sum k_i e_i/n_i modulo one. Its step phase has reduced denominator equal to its phase order, which divides q_atom. A nontrivial character kernel never licenses address merging.

The map j mod q_torus -> jv is well-defined precisely when q_atom divides q_torus. Its kernel consists of multiples of q_atom, with size q_torus/q_atom. It is an isomorphism onto the selected cyclic subgroup precisely when the two orders agree. SHARED_OFFSETS_ONLY asserts no map between quotient groups.

## Planar embedding and contributions

With r prime coordinates, the positive embedding is sum_i (1/n_i) [exp(2 pi i (e_i/n_i+i/r)) - exp(2 pi i i/r)]. Anchor indices begin at zero in ascending-prime order. For r=0 the empty sum is zero. Global chirality negates both coordinate and anchor phases; winding chirality negates only coordinate phases.

For the comb x+c v, summing this expression over the actual canonical offsets gives the specified coordinate contribution

    (1/n_i) exp(2 pi i anchor_i) [chi_i(x) K_m(2 pi v_i/n_i) - m].

The symmetric offset multiset makes K_m even, so winding reversal does not change its kernel value. Summing coordinates gives the resultant; division by m gives its centroid. These trigonometric evaluations are Float64 observations, never bounded arithmetic. Exact phases, coefficients and offsets remain available. Direct sums in the acceptance tests use the verbatim extracted divisorPosition function from the pinned source, including its chirality conventions.

Exponent sums are computed on each wrapped tooth tuple before summing or averaging. They are not a group homomorphism into the real line and cannot be recovered from the planar formula.

The symbolic zero rule uses only exp(2 pi i (t+1/2)) = -exp(2 pi i t), exact rational phase reduction and coefficient addition. It can prove zero/equality without any floating evaluation. In Div(6) and Div(36), equal coordinate phases and weights at opposite anchors cancel; the diagonal addresses therefore share the origin exactly. The rule is sufficient, not complete: more complicated cyclotomic cancellations can remain NOT_CERTIFIED. Every other visual coincidence is reported as numerical proximity only.

## Separate graph relations

The complete-strand graph is the Cartesian product of complete graphs K_n_i. It has degree sum(n_i-1) and |G| times that degree divided by two edges. For each coordinate its eigenvalues are n_i-1 once and -1 with multiplicity n_i-1. Convolving these finite integer spectra gives the complete strand spectrum exactly.

The cover graph changes exactly one canonical exponent by one without wrapping; it has sum_i (|G|/n_i)(n_i-1) edges. The implementation enumerates both graph relations independently within the drawing budget.

The selected-step comb preserves every coset. Each coset is a copy of the cyclic operator on Z/q_atom, so its spectrum is repeated cosetCount times. The plotted cyclic eigenvalues remain numerical evaluations of exact character sums; they are never substituted for the strand spectrum.

## Character-order atom of q

This view concerns q_torus from the captured Cayley source, not shell N. Exactly phi(d) characters of Z/q have order d. M4 asks unchanged spectral.js for the exact zero predicate at the representative index q/d (zero for d=1), and compares the sum of phi(d) over distinct accepted orders with its exact nullity.

For odd m, zeros of L have d>1 dividing m. For even m, d divides 2m and does not divide 2. Every displayed d also divides q. For odd m=2h+1>1, zeros of L-I have d>1 dividing h or d dividing 2h+2 without dividing h+1. The union is formed by visiting each divisor once. Overlap, including d=2 when applicable, is not counted twice. For m=1, L-I=0 and nullity=q is explicitly the special case. Numerical eigenvalue values are not used for any of these zero decisions.

## Scope

No M4 result certifies rational elliptic points, torsion, rank, heights, regulators, L-values or Sha. T1–T4/PT1/U1/P1 remain unchanged. In particular 37a1 retains only its original PT1 rank >= 1 certificate. Torsion-subgroup lattices, Atkin–Lehner operations, root numbers, M5–M7 and P1 integration improvements are deferred.
