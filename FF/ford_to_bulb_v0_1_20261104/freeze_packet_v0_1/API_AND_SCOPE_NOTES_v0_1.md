# FF-4 proposed interfaces and scope

2026-11-04. Review packet only. No definitions or theorem signatures have yet been accepted, elaborated by Lean or proved. The order is accepted v0.2; this packet requires its own manager decision.

## Representation decisions

`RotationAddress` stores positive natural p<q and their coprimality. Its proof fields are part of the guarded domain. `address` is p/q as an exact rational. The four address-bridge targets establish canonical numerator/denominator, interval membership, injectivity and existence for every rational in (0,1). Thus `psi` is total on the intended guarded domain, with no value silently assigned to the excluded endpoints. No function maps an arbitrary complex point or a point on a Ford circle.

`rawDigit` and `blockValue` are total natural-number support functions. Only explicitly guarded address statements have mathematical standing; invalid p,q inputs are not silently given rotation semantics. The primary word has an intercept u:Fin q and digits i:Fin q. Its raw range-sum implementation uses weight 2^(q-1-i), and `word_sum` connects it to the Fin-indexed formulation. `lowerIndex` uses p-1 with its bound proved from the record; the original one-based minus formula appears in `lower_digit_equiv` together with the no-underflow bound 1<=(i+1)*p.

`upperNumerator`/`lowerNumerator` are W(p), W(p-1). `upperAngle`/`lowerAngle` are exact rationals over `modulus=2^q-1`. B0 proves all relevant positivity/strict bounds. `angleInterval` is a set of rational angle representatives, not the complex-plane wake.

The modulus 2^q-1 comes from binary period-q repetition; it is derived from q rather than supplied independently. The address p/q is the internal rotation label. The two external-angle candidates generally have a different denominator and are not identified with that label. `canonicalMultiplier` uses exp(2*pi*i*p/q), not either characteristic angle. These are dimensionless circle coordinates; no identification with an FVLT harmonic/Hasse register or its phasor normalization is inferred.

`orbitSet` uses exactly the q iterates starting at the upper numerator. Rank counts distinct set elements below a natural representative. `orbit_set_eq`, cardinality, sorted length and rank targets identify its sorted enumeration with W(u). The rank-step equation uses reduction modulo q and includes the return edge.

Directed edges are indexed by Fin of the actual sorted-list length, with bounded `get` accesses and no default values. `edgeEnd` wraps to the first point at the final index. `directedGap` includes the modulus only for that wrap edge. The cardinality theorem proves there are q such edges before they are interpreted as a q-cycle. `unique_unit_gap` gives one specifically named lower-to-upper edge of size one and a lower bound of two for every other edge.

The order's root(lambda) is named `cardioidParameter`; its formula is unchanged. `quadraticMultiplier` is explicitly 2z. Both that equation and the actual `HasDerivAt` statement are frozen, so derivative standing is not inferred from an unproved caption. `canonicalMultiplier` uses the exact complex exponential of the rational address; A1c states `IsPrimitiveRoot`. These complex definitions are explicitly noncomputable, separate from the computable Nat/Rat data.

## Public-target decomposition (33 proposed targets)

| Order item | Public targets |
|---|---|
| Canonical source bridge | address_canonical, address_interval, address_injective, address_surjective |
| B0 and digit correspondence | q_at_least_two, modulus_pos, word_sum, upper_digit_equiv, lower_digit_equiv, word_bounds, characteristic_bounds |
| B1 | characteristic_adjacent, characteristic_angle_gap |
| B2 | characteristic_period_return, characteristic_period_minimal |
| B3 | same_cycle |
| B4 | word_strict, orbit_set_eq, orbit_card, orbit_length, rank_word, double_word, rank_step |
| B5 | unique_unit_gap |
| C1 | angle_order, intervals_disjoint |
| C2 | mediant_interval |
| C3 | farey_denominator_min, farey_denominator_eq_iff |
| A1 | parameter_fixed_point, parameter_multiplier, parameter_derivative, canonical_multiplier_primitive |

Twenty-nine targets share one combinatorial module; four form an independent parameter-algebra module. The 31 named data declarations form a third module. This keeps the finite word/prefix/repetition helpers private within the combinatorial module. The exact split is a review proposal, not an upgrade of any kernel item or acceptance of any additional public helper.

C2 constructs a guarded mediant address and states both strict angle separations. C3 is over canonical rationals, so reducedness and positive denominators are intrinsic to the type; its explicit binders include order and Farey adjacency. It includes the equality case and imports no private FF-3 declaration. Actual inherited project imports are the three pinned FF-1 sources in `INPUT_LIBRARY_SOURCE_CLOSURE_v0_1.json`.

B6 uniqueness is absent. The optional infinite staircase note is retained as a reference, not a definition, premise or theorem target. Analytic ray landing, wakes/limb geometry, attracting cycles and Rule30 claims are absent. The kit's doubling vocabulary is no bridge to Rule30's specific sequence. No viewer/kernel edit, commit, release or sync is in this packet.

## Source conventions and checks

All newly authored Lean sources must use UTF-8 without BOM and LF endings. Every hypothesis is an explicit binder or guarded record field; ambient section variables are refused. Data source bytes must equal the entire accepted definition file, including imports/namespace. Proof modules import the data module, open BigOperators, use the one frozen namespace, and write public headers followed by the canonical ` := by` separator. Helpers remain private. Public attribute wrappers and extra public declaration kinds require review rather than bypassing the header parser.

The new FF-4 runner recomputes data/header checks against the pinned target index before Lean starts. An external comparison receipt is still required. Strict replay covers private helpers and generated constants as well as named public targets. Static parser fixtures are in-memory strings and never mathematical Lean files; no proof claim comes from those fixtures.

The frozen checker is the module-agnostic strict checker already used in FF-3, hash `9c6f2ac11b50fdb846df2d5099ea673553903275a5dba11fce5a5673cae14bd0`. Its Python/Lean API maintenance advisory remains separate from actual proof success/failure. A fresh FF-4-specific runner, module whitelist, phase identifier, root and v23 guard are proposed; the FF-3 runner is kept only as a pinned predecessor for the diff.
