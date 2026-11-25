# M4 API and limits

The same atom-core.js and atom-packet.js are evaluated in Node verification and embedded into the browser. They reuse McombCayleyCoreV1 and the unchanged BSDV1Spectral.assess. No arithmetic service or endpoint is added.

## Exact inputs

`McombAtomCoreV1.derive(input, source)` takes the validated existing Cayley source and an object with exactly N, factors, start, step, binding, chirality, character. Every integer is a canonical decimal string. Factors are ascending distinct primes and positive exponents, with N equal to their product. Tuples have one entry per prime, in canonical residue range. An empty factorization describes N=1 and its sole address.

- At most 16 factors; primes at most 1,000,000, proven by trial division; exponents 1 through 64; shell at most 256 bits.
- Automatic factorization/presets and the q character-order view support integers 1 through 10^12. Explicit factors allow the larger declared shell domain. Automatic shell factors must still satisfy the explicit factor domain.
- Selected-step order at most 4096: larger orders return UNAVAILABLE before allocating the orbit.
- Full coset enumeration only when the atom has at most 4096 addresses. Otherwise the selected orbit and its exact least representative are available; the complete coset list is NOT_COMPUTED.
- The complete serialized M4 sidecar must fit the 12,000,000-byte replay cap. A mathematically admitted input whose full output exceeds this limit returns UNAVAILABLE before any export is offered.
- Complete graph drawing at most 256 vertices and 4096 edges per relation; larger atoms show a selected-orbit view, capped at 256 visible addresses. Exports keep all supported orbit addresses.
- The q-divisor view retains inherited exact nullity when factoring q is unavailable. L-I is admitted only for odd m, exactly as spectral.js requires. m=1 is an explicit identity-only special case.

`preset(N)`, `record(input,q)`, `address(atom,tuple,character)`, `orbit(atom)`, `cosets(atom)`, `contributions(atom,m)`, `graphs(atom)` and `spectralOrders(source,operator)` expose the underlying computations. Returned derived records separate exact expressions and integers from `FLOAT64_NOT_BOUNDED` geometry. The schema AtomRecord retains its original field names.

## Geometry and relations

An address reports its integer divisor, exponent tuple, exponent sum, exact coordinate phases, chosen character phase, exact planar expression and numerical planar coordinates. `compare(left,right)` returns separate tuple equality, character-phase equality, and a planar result. Its symbolic rule combines exact rational coefficients on equal/opposite rational phases. When this does not prove equality, it reports only numerical proximity and its tolerance. A small floating distance never proves equality.

`extract-atom.cjs` reads the pinned sibling atom HTML, checks its full SHA-256, and extracts divisorPosition verbatim. Only Math is required. Tests execute that extracted function; they do not execute the atom UI or maintain a second oracle formula. BUILD_PINS.json records source and function hashes.

## Packet and replay

`await McombAtomPacketV1.construct(cayleyBytes,input)` produces `MCOMB_ATOM_ADAPTER_V1`. The embedded original Cayley packet remains unchanged. Fields are schema, pins, cayleyBytes, cayleySha256, input, selection, atomRecord, certificate, exactDigest. Selection has the schema's source revision and original tooth/quotient/Fourier fields plus the atom start and exact coset representative. Clicking an inspection address is temporary; using it as comb start changes the selected comb and its exported Selection.

`await McombAtomPacketV1.replay(bytes)` checks duplicate JSON keys, byte limits, digests, the original Cayley packet, all exact fields, bindings, and recomputed derived data. Exact fields require equality. Numerical fields must be within 64 * Number.EPSILON * max(1, abs(supplied), abs(recomputed)); the result contains fresh local computations, never promotes imported floating values, and does not authorize new exact geometry. Digests bind bytes but are not proofs. An attacker who recomputes a digest still cannot change a derived conclusion.

In the UI, McombAtomAdapterV1 exposes configure, refresh, reopen, follow, inspect, snapshot, inspection and a read-only state. Source, atom, step, coset, chirality and character changes invalidate inspection. Pending work has a generation guard and a source identity guard. Held settings retain their own source until Follow is selected. M4 performs combinatorial calculations in file mode, while all inherited BSD file-mode restrictions remain intact.
