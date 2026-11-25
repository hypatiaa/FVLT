# M-comb Cayley visualization — implementation schema

Revision: v0.1-C · 2026-09-21  
Target: Monodromy .30.1, with an optional atom-viewer adapter  
Status: proposed implementation contract; the panels described here are not yet implemented.

## 1. Goal and first build

Add a Cayley inspector to the existing m-comb viewer. It must let a user see which exact teeth coincide, how the weighted graph encodes the Fourier kernel, and what information disappears when addresses become phases or planar positions.

The first build has three synchronized views: the existing phasors, a cyclic graph with weighted edges and loops, and the kernel curve with quotient samples. Selecting a tooth or quotient residue links all three. A compact neighborhood inspector exposes triangles, opposite-neighborhood boundaries, and clique witnesses only for an explicitly selected simple adjacency.

Follow this with the atom adapter and recursive views. The final pipeline is:

`exact source → integer labels → quotient operator → selected address/coset → character contributions → resultant`

Keep the exact source authoritative. A drawing, camera, hidden branch mask, approximate minimum, or layout coincidence must never rewrite it.

## 2. Source baseline and integration points

| Artifact | SHA-256 |
|---|---|
| `monodromy-30-1-reduction-audit.html` | `5dc69781082a3d2b41e1b38b49f71c44ec349a219221ed19b15969f8c0c0ee84` |
| `helix_atlas_doily_witness_v27_patched_3_wl2(6).html` | `3d65e14af4b0887b543e48d986ccc6367b0129afc150e0f9a254bd407b3ab106` |

These are content pins for the supplied files, not claims that every module has been audited. This schema was grounded in the comb functions, exact source/transport interfaces, carrier-addition displacement, divisor embedding, and local-comb construction.

### Existing interfaces

- `combOffsets(m)`: sorted, complete canonical tooth labels.
- `combKernel(m, B)`: real kernel; **B is radians**.
- `computeVernier(...)`: displayed teeth, carrier, radius and resultant. Its returned `N`/`n3` is the current angular denominator; do not substitute the outer factorial shell.
- `liftSourceSnapshot()`: exact host fields alongside display fields.
- `McombElliptic.validateSource(source)`: current exact transport admission.
- `McombElliptic.address(source,c)`: exact torus address for an admitted tooth.
- `McombEllipticLink.current`: cloned capture and transport, or null.
- `mcomb:transport`: existing window event announcing transport updates/clearing.
- `McombCarrierAddition`: selected-pair displacement is named `D`; it is **cD₁**, not the unit displacement.

### Proposed modules

```text
McombCayleyCoreV1       Pure exact arithmetic, weights, certificates, cache keys.
McombCayleyAdapterV1    Reads captured host state and selection; owns no source controls.
McombCayleyPanelV1      Graph, spectrum, neighborhood and recursive presentation.
AtomCayleyAdapterV1    Optional exponent-group and embedding adapter.
```

Implement two named capture routes in the first release:

| Route | Source and limits | Required presentation |
|---|---|---|
| `ELLIPTIC_CAPTURE` | Existing `McombEllipticLink.current.capture`; configured curve, paused exact-spin admission and selected exact orbit-index point; m=1…31, N≤10⁶, amplitudeSign=±1, and existing rational work-range checks | Captured N and s, origin route, live/held/blocked state and inherited limits |
| `DIRECT_HOST_CAPTURE` | New shared exact host-capture helper; full host m=2…720, plus m=1 core/import fixture support; no curve or BSD setup | Explicit choice of exact selected index address or exact live-register snapshot; captured N/s and source revision |

The elliptic route subscribes to `mcomb:transport`, reads `McombEllipticLink.current.capture`, and recomputes from that capture. Read once on initialization too. Its source builder takes N from `selected.N` and s from `selected.indexSExact`, not from the live controls. The paused exact-spin gate does not make those selected-address values equal to live display values. Null/invalid capture clears the current binding; old results must not remain labeled live. Reuse the capture without requiring a BSD comparison or appending any BSD evidence.

Promote the direct-host adapter before the atom adapter. Extract/refactor source capture into a shared helper with separate algebraic and elliptic admission; do not route large combs through `McombElliptic.validateSource` or relax that validator. The abstract operator needs only m and exact θ. For host linkage, retain the source fields producing θ and the carrier; apply the actual host's exact-input admission. Accept a Number-valued N only after `Number.isSafeInteger(N)` and positivity checks, or derive it from an available exact representation. Never rationalize a Float64 display angle into an exact capture.

Define a new `mcomb:cayley-source` event at the shared exact-capture commit point for direct-host updates, with sourceRevision and route; it does not exist in .30.1. Subscribe to committed source changes rather than requiring a curve's transport event or adding another animation loop. Selection-only updates need not rebuild the operator. Keep provenance distinguishing `EXACT_INDEX_ADDRESS` from `EXACT_LIVE_REGISTER`; switching between them is an explicit action. Do not invent an already-existing public API or duplicate subtly different source builders. Demo presets remain detached records.

The direct adapter needs its own resource/admission validator, supporting all m≤720 accepted by the host while keeping arbitrary-precision arithmetic bounded by input-byte/work quotas. It must not inherit the elliptic N≤10⁶ cap as a mathematical restriction. Retain nonzero-amplitude admission for the linked carrier/torus record in this release; any zero-amplitude purely combinatorial preview remains a separately declared mode. Show both admission limits and drawing budgets distinctly. Small m can also collide; large m is an important supported use case, not a prerequisite for collision.

Use an additive namespaced module block, e.g. `MCOMB_CAYLEY_V1_BEGIN/END`; preserve existing module pins and export validators. This is a new sidecar export, not an undocumented change to the linked elliptic/BSD packet.

## 3. Exact conventions

All serialized integers are canonical decimal strings. All rationals are reduced `{num,den}` with positive denominator. Use BigInt internally; JSON has no native BigInt. Canonical phase residues lie in `[0,1)`. Reject zero denominators and unsafe Number-to-integer conversions. Existing host rational strings are parsed using its exact rational machinery before conversion.

Write `e(t)=exp(2πit)`; all schema phases are **turns**. Only the adapter to `combKernel` multiplies by `2π`.

For odd `m=2M+1`, `C_m={-M,…,M}`. For even `m=2M`, `C_m={±1,±3,…,±(2M-1)}`. Preserve every original tooth label, including zero and labels coinciding in a quotient. Host admission currently allows `m=1`; support that identity-only case explicitly.

Set `θ=t₂s/(2N) mod 1 = h/q`, reduced; for θ=0 use h=0,q=1. Then:

```text
D₁ = (0, −θ) mod 1
C  = ((t₁s + [amplitudeSign < 0])/2 mod 1, 0)
P_c = C + cD₁
χ(α,β) = e(α−β)
χ(D₁) = e(θ)
```

`q=ord(D₁)`, not the selected tooth's torsion order, not `ord(cD₁)`, and not the finite-field prime used elsewhere. The displacement order of tooth c is `q/gcd(q,c)` (also valid for c=0). The physical phase at residue j is `χ(C)e(hj/q)`; multiplication by h permutes quotient characters when q>1.

The amplitude is deliberately separate. Reproduce physical phasors with `|radius|χ(P_c)`, where the carrier address already includes the negative-amplitude half-turn. Do not apply the sign twice. Current exact transport rejects zero amplitude; show its admission reason rather than fabricate a torus capture. A future purely combinatorial zero-amplitude adapter needs its own declared scope.

## 4. Three records and their boundaries

The authoritative records contain exact inputs and definitions. Expensive derived arrays may be omitted with explicit status. Numerical output has a method and precision label; it is not placed in exact fields.

```ts
type Z = string; // canonical base-10 integer
type Q = { num: Z; den: Z };
type Phase = { alpha: Q; beta: Q };
type ComputationStatus =
  | 'EXACT' | 'NUMERICAL' | 'CERTIFIED_INTERVAL'
  | 'PARTIAL' | 'NOT_COMPUTED' | 'NOT_APPLICABLE' | 'BLOCKED';

interface IntegerLabelRecord {
  kind: 'CANONICAL_MCOMB';
  m: Z;
  offsets: Z[];                 // sorted full C_m; never visibility-filtered
  positiveFrequencies: Z[];     // positive offsets, not carrier frequencies k_c
  zeroMultiplicity: Z;          // 1 odd, 0 even
  sourceBytes: string;          // exact captured JSON for byte provenance
  sourceSha256: string;
  hostPin: string;
}

interface QuotientRecord {
  kind: 'CYCLIC_TORSION';
  q: Z;
  physicalStepTurns: Q;         // θ=h/q; retain h to place physical phases
  unitDisplacement: Phase;      // D₁
  carrier: Phase;               // C
  weightEntries: Array<{
    residue: Z; weight: Z; toothLabels: Z[];
  }>;                          // sparse, sorted, exact
  toothMap: Array<{
    c: Z; residue: Z; displacementOrder: Z; point: Phase;
  }>;
  operator: 'SUM_OF_TRANSLATIONS';
  rowSum: Z;                   // m
  diagonalWeight: Z;           // weight at residue "0", or "0" if absent; not array index 0
  toothInjective: boolean;
  simpleConversion:
    | { status: 'VALID'; subtractIdentity: '0' | '1'; degree: Z }
    | { status: 'NOT_APPLICABLE'; reason: string };
}

interface AtomRecord {
  kind: 'DIVISOR_EXPONENT_GROUP';
  N: Z;                        // atom shell, distinct from host N unless bound
  factors: Array<{ prime: Z; exponent: Z }>;
  orders: Z[];                 // n_i=a_i+1
  start: Z[];                  // x, canonical exponent representatives
  step: Z[];                   // v, canonical residues
  groupSize: Z;                // τ(N)=product n_i
  stepOrder: Z;                // q_atom=lcm_i(n_i/gcd(n_i,v_i))
  cosetCount: Z;               // groupSize/stepOrder
  binding:
    | { kind: 'SHARED_OFFSETS_ONLY' }
    | { kind: 'CYCLIC_ISOMORPHISM'; order: Z }
    | { kind: 'DECLARED_HOMOMORPHISM'; description: string };
  chirality: 'positive' | 'global' | 'winding';
}
```

`AtomRecord` is optional. Default atom binding is `SHARED_OFFSETS_ONLY`: the same labels drive two different address spaces. Do not infer equality of q_atom and q_torus from a shared N. A cyclic isomorphism jD₁↦jv requires equal orders. A declared map Z/q_torus→<v>, j↦jv, is well-defined only if q_atom divides q_torus; expose its kernel. Otherwise shared integer labels still make sense, but no quotient map is asserted.

Add display/selection state outside these records:

```ts
interface Selection {
  sourceRevision: Z;
  tooth: Z | null;
  quotientResidue: Z | null;
  fourierIndex: Z | null;
  atomAddress: Z[] | null;
  cosetRepresentative: Z[] | null;
  historyWord: Z[] | null;
  visibleOffsets: Z[];          // presentation only
}
```

For every derived certificate, export `{status, method, inputDigest, value, reason?, elapsedMs?}`. A source hash binds bytes; it does not certify a mathematical conclusion or independent verification.

## 5. Weighted operator, spectrum and simple conversion

For j in Z/q:

`(Lf)(j)=Σ_{c∈C_m} f(j+c)`.

Store `w(r)=#{c:c≡r mod q}`. The matrix, when explicitly requested for a small example, is `L[j,k]=w(k−j)`. Symmetry follows from the symmetric offset multiset. Loops are diagonal weights, not edges counted twice by an undirected-graph degree convention. Row sum is always m.

The character `f_k(j)=e(kj/q)` has eigenvalue:

`λ_k=Σ_c e(kc/q)=K_m(2πk/q)`.

The identity is exact; a Float64 cosine evaluation is numerical. Store the exact rational angle and offset expression even when showing a decimal value. Do not call every computed eigenvalue or numerical minimum exact merely because its defining formula is exact.

The physical kernel at the captured address (captured N and captured s) is λ_h. Label h, not k=1, unless h=1. At integer multiples ℓs of that captured spin, with the other captured parameters fixed, the spread kernel is λ_(ℓh mod q); the carrier may also change, so this is not an identity of full phasor resultants without that factor. Do not label this the live-display kernel unless the capture is explicitly bound to the exact live register and the binding is current.

An auxiliary sampling modulus p is allowed in the spectral view. Store `sampleGrid={kind:'TORSION', modulus:q}` or `{kind:'AUXILIARY', modulus:p}`. The latter is a resolution experiment, not the physical quotient record. Label its markers and minimum separately, use p in its sampling-error bound, and never overwrite q, D₁, the tooth coincidence map or current graph. Primality is unnecessary for the Fourier identity; an optional prime restriction belongs to a named comparison experiment. An auxiliary Cayley graph, if opened, is a detached domain with its own context ID.

### Canonical tooth-injectivity rule

| Case | Injective exactly when |
|---|---|
| odd m | q ≥ m |
| even m, odd q | q ≥ m |
| even m, even q | q ≥ 2m |

Calculate by the sparse weight map as the authority and cross-check this shortcut. When injective, derive `A_simple=L−I` for odd m, and `A_simple=L` for even m. Its degree is m−1 or m, respectively; subtract the same identity contribution from its eigenvalues. For m=1, A_simple is the empty graph on q vertices.

When noninjective, the current conversion is unavailable. One may separately construct the support graph by deleting loops and merging parallel contributions, but that is a **different operator** with separately recomputed spectrum. Never replace L by the support graph silently. Distinct nonzero labels cannot become self-inverse connection residues in an injective canonical comb; otherwise their opposite labels would collide.

For m≥2 the offsets include ±1, so the cyclic weighted graph is connected (including the one-vertex case). For m=1, L=I and q>1 gives q isolated vertices. In the atom group, L along v preserves every coset of <v>; the whole-atom spectrum is the cyclic spectrum repeated groupSize/q_atom times. These coset blocks need not be connected in the identity-only case.

## 6. Linked views and interaction

### A. Cayley graph / orbit

- Vertices are all j in Z/q when within the display budget, not only occupied teeth.
- The selected comb at origin j₀ occupies j₀+c with weight w(c). Keep edge multiplicity and tooth occupancy visually distinct.
- A loop has an explicit weight. Coincident tooth labels appear in a selectable list for the vertex; do not choose an arbitrary label on a residue click.
- Clicking a tooth selects its residue, torus point, and existing host tooth. Clicking an unoccupied vertex selects an inspection address without inventing a tooth or changing the host source.
- Offer wheel and unfolded-integer-strip layouts. Layout changes preserve adjacency and selected IDs.
- Clicking a Fourier sample overlays that character's phases on graph vertices; it does not change the current exact spin. A separate explicit host action would be needed to move s.
- Stable labels and highlighting must work without color alone. Support rotation/pan where a 3D atom is present; never identify vertices from pixels.

### B. Kernel and spectrum

Draw K_m over turns [0,1], quotient sample markers k/q, captured physical sample h/q, sampled minimum, and the optional continuous-minimum enclosure. Make the odd identity shift visible when the simple spectrum is selected. Do not overlay unlike normalizations without labels.

For `F_P(t)=Σ_{a∈P}cos(2πat)`, set m_q=min_k F_P(k/q) and m_*=min_t F_P(t). The analytic inequality is:

`0 ≤ m_q−m_* ≤ π² Σ_a a²/(2q²)`.

For K=δ+2F_P, double this error. This bounds the continuous minimum using **all** q samples. If the display/evaluation visits a subset, its smallest value is not the full sampled minimum. Use `PARTIAL` and report the evaluated indices. A local optimizer supplies an estimate, not a global certificate. A numeric interval badge requires outward-rounded evaluations of samples, π and the bound; otherwise present the analytic inequality and mark the decimal endpoints numerical.

### C. Neighborhood / structure

Require an explicit operator context: integer-label graph, derived quotient simple graph, or atom strand graph. Weighted L alone does not admit unweighted clique/triangle readouts by reinterpretation.

For a symmetric simple connection set S excluding zero, H is the induced graph on N(0)=S:

```text
T = 2|E(H)|                         ordered adjacent pairs in N(0)
B_t = N_H(t) \ N_H(−t)             only when t∈S
|B_t| = ½|N_H(t) △ N_H(−t)|
ω(full graph) = 1 + ω(H)
```

For general t, use `(N(0)∩N(t)) \ N(−t)` in the full graph; t need not be a vertex of H. Keep signed original labels with quotient residues. Clique output includes witness B, lower bound, upper bound, and search status. A found witness is a certified lower bound; maximality is certified only when a justified upper bound meets it. A timeout is partial, not failure and not maximum.

For comparing integer readouts with mod-q readouts, let M=max positive frequency. With base positions and steps in ±P: q>3M suffices for the boundary/clique comparisons; q>4M suffices for five-position membership at u+jt, j=−2,…,2. These are sufficient uniform thresholds, not necessary tests. At general selected positions use `q>M+max_j |u+jt|` for membership. For general-t boundaries use the actual tested positions a±t, not a fixed 3M badge. Empty P has no M: mark the comparison trivial/not applicable as appropriate.

Three regime labels: `q≤3M: modular comparison may differ`; `3M<q≤4M: boundary/clique lifting safe in stated scope`; `q>4M: five-position lifting also safe in stated scope`. None says that the sampled spectral minimum equals the continuous minimum. Genuine torsion coincidences remain valid quotient facts below these thresholds.

The Chowla literature concerns specified integer frequency sets. Original labels remain distinct even when their quotient images collide; quotient multiplicity does not retroactively change the original set into a multiset. Do not transfer asymptotic claims to weighted L. The graph paper's simple-graph theorem has additional quantitative hypotheses; an injectivity badge alone is not a theorem-applicability badge. The first release shows exact definitions and computed quantities, with external theorem references as context rather than automatic guarantees.

## 7. Atom adapter

The atom group is `G_N=product Z/n_i`, with n_i=a_i+1. A divisor address e represents product p_i^e_i. Preserve its integer value, exponent tuple, rank Ω and phase tuple separately.

The complete-strand graph connects two addresses differing in exactly one coordinate, by any nonzero amount. It is `K_n1 □ … □ K_nr`, with degree Σa_i, eigenvalues `Σ_i(n_i[k_i=0]−1)`, and, for N>1, minimum eigenvalue −r and clique number max n_i. Its closed neighborhood is the existing local comb of size Σa_i+1. The divisibility-cover graph is a separate relation and does not wrap.

Select x and v. Compute q_atom exactly, then label the orbit x+<v>, group size, orbit size, coverage fraction and coset count. A step on a cyclic group need not generate it: e.g. step 2 on Z/4 covers only two addresses. A zero step has order 1. Do not use the existence of a cyclic phase group as proof that the selected step covers it.

For modest atoms enumerate cosets exactly, choosing the lexicographically least canonical exponent tuple as representative. For large atoms show the selected orbit and an unevaluated coset list; a scalable algebraic quotient implementation may be added later. Do not enumerate a huge atom solely to populate a selector.

For positive chirality, let r_i=1/n_i, φ_i=i/r turns and χ_i(x)=e(x_i/n_i), where **i=0,…,r−1 is zero-based in the host's canonical ascending-prime factor order**. Equivalently, one-based index j uses φ_j=(j−1)/r. Do not rotate all anchors by using one-based i/r. The sum of tooth positions in the plane is:

`Σ_i r_i e(φ_i) [χ_i(x) K_m(2πv_i/n_i) − m]`.

Show each coordinate contribution, the sum, and the centroid=sum/m as different readouts. The resultant generally cannot recover its summands. For global chirality use complex conjugation of the positive result. For winding-only reversal, negate the coordinate phases while retaining anchor phases; because the canonical kernel is even its value is unchanged, but χ_i(x) is conjugated. Match the host's actual chirality convention.

Height is the sum of canonical representatives. It is a well-defined function on G_N, but not an additive homomorphism into R. A coordinate wrap contributes a height jump. Compute heights for every tooth address before summing/averaging; do not derive height from the planar kernel formula.

Distinguish three equivalence relations in selection details:

1. same address: exact tuple equality;
2. same character phase: exact rational phase equality;
3. same planar resultant/position: symbolic identity where available, otherwise only numerical proximity with a stated tolerance.

For the specific vertical torsion subgroup in the m-comb transport, χ is faithful; in a general atom group a chosen character may have a kernel. Its phase order is the denominator of Σ_i k_i v_i/n_i, which divides q_atom. Never use this smaller order to merge actual addresses.

Presets:

| Atom | Orders | Diagonal orbit | Cosets | Purpose |
|---|---|---|---:|---|
| 6 | 2,2 | 1→6→1 | 2 | Smallest planar collapse with incomplete coverage |
| 12 | 3,2 | 1→6→4→3→2→12→1 | 1 | Full cyclic coverage; 9 strand and 7 cover edges |
| 36 | 3,3 | 1→6→36→1 | 3 | Three-point collapse; heights 0,2,4 |
| 720 | 5,3,2 | length 30 | 1 | Larger cyclic factorial example |

At N=6, 1 and 6 project to zero; 2 and 3 project to −1 and +1 respectively in positive chirality. N=36's indicated diagonal has zero planar position throughout. These are algebraic cancellations of equal-weight opposite anchors; certify them symbolically rather than by floating-point equality.

The same N in the atom and transport panels is contextual linkage, not an identification of their groups. The strand operator, selected-step comb operator, doily incidence, and Farey-contact relation keep distinct IDs, spectra and scopes.

## 8. Recursive and alternative-object views

Implement these as subscribers to the same exact record, with explicit operation/domain selectors.

### 8.1 Walk histories and endpoint fibres — first recursion feature

Objects are words `(c₁,…,c_d)` of tooth labels, including repeated quotient actions and zero steps. Extension appends one tooth label. Endpoint is j₀+Σc_i mod q, or x+(Σc_i)v in an atom. Distinct histories remain distinct until the user requests a folded endpoint view.

Selecting an endpoint highlights its histories within the displayed depth; selecting a history highlights each intermediate state. Depth truncation must be visible. A capped tree is a walk unfolding, not automatically a universal cover or a proven fractal. Nonbacktracking walks would be a separately defined rule.

### 8.2 Walk counts and arithmetic patterns

Define counts starting from δ₀ by `w_(d+1)(j)=Σ_c w_d(j−c)`. Symmetry makes this agree with L acting on the count vector. Count modulo a user-selected small prime ell using exact modular arithmetic, or keep BigInt counts within budget. ell is separate from q and from the curve-reduction prime.

For the integer-cover m=2 walk, count at displacement j is `binomial(d,(d+j)/2)` when admissible. Mod 2, this provides the binomial self-similarity case. The finite quotient folds these counts by residue and can erase the visible pattern; label that domain. In the complex/Fourier lane each mode evolves by λ_k^d. Do not treat a count reduced modulo ell as a complex Fourier amplitude.

### 8.3 Compatible quotient refinement

Optional later view: a tower of declared moduli q₀|q₁|… with maps j mod q_next→j mod q_prev. Translation sums commute with pullback of functions along these maps. Keep the same integer labels. This produces an exact hierarchy of fibres. A self-similar drawing alone does not prove a fractal limit. In physical-spin mode each level needs its own exact source; changing q cannot silently leave s and D₁ unchanged.

### 8.4 Divisor intervals and incidence objects

An interval [u,v] with u|v is order-isomorphic to Div(v/u). Selecting it may open a nested atom. This map preserves the divisibility order; the child's cyclic periods are newly defined and need not intertwine the parent phase-group action.

Reserve relation IDs for doily objects (duads, synthemes, flags) and Farey fractions. These may be selected as objects in their own right, linked by explicit incidence maps. Do not label every such relation a Cayley graph, and do not inherit the m-comb spectrum. These are extension points, not required for the first build.

## 9. Computation, caching and responsiveness

Defaults are implementation budgets, not mathematical admissions:

| Work | Initial budget / behavior |
|---|---|
| Graph drawing | ≤256 vertices and ≤4096 aggregated edges; otherwise local view |
| Full cyclic spectrum | q≤4096 in worker; otherwise selected samples and formula |
| Neighborhood clique search | ≤32 vertices by default, 200 ms worker slice; resumable |
| Walk tree | ≤2048 displayed histories; explicit depth/node truncation |
| Modular walk raster | ≤262144 cells, exact modular recurrence in worker |
| Atom coset enumeration | groupSize≤4096; otherwise selected orbit only |

Compute the weight map from at most m labels even when q is enormous. Never allocate length q merely to discover a collision. Before any conversion to a Number index, compare a BigInt quantity against the relevant budget. Export exact q even when no full graph can be drawn.

Cache keys:

- Canonical algebra/injectivity/weights: `(definitionVersion,m,q)`.
- Cyclic numerical spectrum: preceding key plus evaluator version/precision.
- Physical embedding: source digest, including carrier, θ numerator and display amplitude context.
- Atom subgroup/address mapping: ordered n_i, step tuple; coset geometry additionally x and chirality.
- Whole-atom spectral repetition: cyclic cache plus groupSize/q_atom.
- Structure certificates: exact relation ID, connection labels/residues, ambient domain and modulus.

Changing coset does not recompute abstract weights or cyclic eigenvalues. Changing t₁ or amplitude sign changes carrier placement but not those eigenvalues. Changing θ while preserving q permutes the physical character index and positions. Hidden branches only change presentation. Any preview for a visible subset is a separately labeled operator, never the full comb result.

Each async request carries sourceRevision and inputDigest. Discard late results when either differs from the current context. Pause/hold preserves a labeled captured record. Provide cancellation and partial results for expensive searches. Bound caches with LRU eviction, retaining exact selected source independently.

## 10. API and export contract

Proposed signatures (not existing APIs):

```ts
captureCayleySource(): HostCapture | AdmissionFailure;
deriveIntegerRecord(capture): IntegerLabelRecord;
deriveQuotient(integerRecord, capture): QuotientRecord;
evaluateSpectrum(quotient, options, abortSignal): SpectrumResult;
deriveSimpleAdjacency(quotient): SimpleResult;
inspectNeighborhood(simpleRecord, t, budget, abortSignal): StructureResult;
deriveAtomOrbit(atomInput, offsets, budget): AtomOrbitResult;
iterateWalks(record, walkOptions, abortSignal): WalkResult;
exportCayleyRecord(snapshot): Promise<string>;
validateCayleyRecord(jsonBytes): Promise<RecomputedSnapshot>;
```

Export envelope:

```json
{
  "schema": "MCOMB_CAYLEY_INSPECTOR_V1",
  "definitionVersion": "1",
  "sourcePins": {},
  "capture": {},
  "captureBinding": {},
  "integerRecord": {},
  "quotientRecord": {},
  "atomRecord": null,
  "fcaRecord": null,
  "selection": {},
  "computations": [],
  "view": {},
  "exactDigest": "sha256-of-canonical-exact-fields"
}
```

This envelope is a structural template, not a valid fixture. The validator rejects missing/unknown fields for v1, validates canonical integer/rational encodings and quotas, checks source bindings, then recomputes offsets, q, phases, weights, orders and simple conversion. It must not trust an imported `CERTIFIED` string. Replay supported certificates; otherwise retain them as source-reported and visibly unverified. Numerical samples/layouts are optional cached observations and excluded from exactDigest.

`capture` retains `{source,selection,visibleOffsets}` as a separate captured object. `captureBinding` has mandatory `route` (`ELLIPTIC_CAPTURE`, `DIRECT_HOST_CAPTURE`, or `DETACHED_PRESET`), `origin` (`EXACT_INDEX_ADDRESS`, `EXACT_LIVE_REGISTER`, or `PRESET`), `capturedN`, `capturedS`, and `sourceRevision`. Validate N/s against capture.source and the selected source route. UI live/held/blocked status is runtime binding state, not a portable assertion that an imported source is currently live. Reopening an export starts held until explicitly rebound. Hash exact captureBinding fields along with the other exact fields.

Use explicit definitions of which fields are hashed; sort object keys, preserve ordered arrays, and exclude exactDigest itself. Hashing a capture preserves its bytes; separately canonicalize mathematical fields for semantic caching. Record source-reported audit counts separately from checks rerun by this implementation.

The first build exports JSON. CSV extensions may later export teeth, residue weights and spectrum, each carrying domain, operator ID, source digest and numeric status. Use numeric/text rendering rather than injecting imported HTML.

Reserve a later `FREE_FREQUENCY_SET` integer-record variant for experiments such as P=Div(N). It must explicitly specify distinct positive frequencies, optional zero weight, and generator multiplicities. Do not send it through the canonical host `validateSource` or apply the canonical parity/injectivity shortcuts. In that mode compute weights and simple-conversion eligibility directly. Using divisor values as additive frequencies defines another graph, distinct from the atom's exponent-strand graph; retain both relation IDs and the declared label map. This extension broadens the Chowla experiments without changing the existing m-comb definition.

## 11. Acceptance fixtures

Implement these as meaningful checks of independent constructions: matrix versus character evaluation, direct address enumeration versus order formula, and direct tooth-position sum versus factorized kernel. Floating comparisons need scale-aware tolerances and reported residuals; exact counts/orders require equality.

| ID | Inputs | Required result |
|---|---|---|
| Q1 | m=2,q=1 | offsets ±1 both residue0; L=[2]; injectivity false |
| Q2 | m=2,q=2 | L=[[0,2],[2,0]], eigenvalues 2,−2; no simple conversion |
| Q3 | m=2,q=3 | simple triangle; eigenvalues 2,−1,−1; continuous K minimum −2 |
| Q4 | m=4,q=4 | weights at 1,3 each2; eigenvalues 4,0,−4,0 |
| Q5 | m=4,q=8 | four distinct odd residues; simple K4,4, degree4 |
| Q6 | m=5,q=5 | L=all-ones; eigenvalues 5,0,0,0,0; L−I is K5 |
| Q7 | m=9,q=3 | every residue weight3; eigenvalues 9,0,0; injectivity false |
| Q8 | m=1,q=7 | L=I; injective; simple adjacency empty, seven isolated vertices |
| Q9 | m=4,q=2 | All four labels land on residue1; L=[[0,4],[4,0]], eigenvalues4,−4; K₄(π)=−4 |
| P1 | N=3,m=2,t1=1,t2=2,s=1,sign=+1 | θ=1/3,C=(1/2,0),D₁=(0,2/3),q=3; physical sample k=1 |
| P2 | as P1 with t2=4 | θ=2/3,q=3; same abstract spectrum, physical index k=2 |
| P3 | any valid capture, change sign +1→−1 | carrier shifts half turn; q/weights/spectrum unchanged |
| P4 | any valid capture, t2=0 | q=1; all teeth at carrier; L=[m] |
| A1 | N=6,v=(1,1),x=(0,0) | q=2, two cosets; addresses 1,6 share plan position, heights0,2 |
| A2 | N=12,v=(1,1) | q=6, one coset; orbit 1,6,4,3,2,12; strand9/cover7 edges |
| A3 | N=36,v=(1,1),x=(0,0) | q=3, three cosets; orbit1,6,36, all at plan zero, heights0,2,4 |
| A4 | N=4,v=(2) | phase group Z/3, step order3 (do not confuse exponent bound2 with period3) |
| A5 | N=8,v=(2) | phase group Z/4, step order2; cyclic ambient group but incomplete coverage |
| A6 | N=36, m=2, v=(1,1) | eigenvalues 2,−1,−1 repeated3; distinct from strand spectrum |
| W1 | m=2,q=2,start0,depth1 | two histories, one endpoint; count2, parity0 |
| W2 | integer-cover m=2,depth4 | displacements −4,−2,0,2,4 have counts1,4,6,4,1 |
| S1 | P={4,5},q=19,u=t=5 | five-position pattern10100 over Z and10101 mod19 |
| S2 | P={2,3,8},q=19 | Integer connection set ±P is triangle-free; quotient has triangle {0,3,11}, with 8+8≡−3; q=19≤3M=24 |

Additional integration checks:

- Every canonical m=1…31 and q=1…100: shortcut injectivity agrees with explicit residues; valid simple conversion is symmetric, 0/1 and loopless.
- Direct-host large-comb acceptance: m=720,q=2 yields weight720 at residue1 and spectrum720,−720; no curve is required. Exercise m=32 to catch accidental reuse of the elliptic m≤31 gate. Check m=720,q=1440 is injective and q=1438 is not; sparse arithmetic remains available if drawing is budget-limited.
- When the selected exact index address and live controls disagree in N or s, `ELLIPTIC_CAPTURE` follows the selected address; `DIRECT_HOST_CAPTURE` follows its explicitly selected origin. A source-route change invalidates the binding and selection provenance before presenting recomputed results.
- An injective even comb such as m=2,q=3 has sparse first entry residue1, but diagonalWeight must still be0.
- Hidden-mask changes preserve full offsets and weights; selecting a colliding residue lists every tooth label.
- Changing selected pair offset never changes unit-step q.
- Coset changes preserve L spectrum but may change per-coordinate contributions/resultant.
- Selecting a character with a nontrivial kernel never merges atom addresses.
- Inexact spin: no exact q is inferred from Float64; show admission failure or explicitly held capture.
- Source update during worker work: stale results discarded; imported forged weights/orders/digests rejected.
- Large exact q: sparse weights remain available; partial sampled minima cannot acquire full-minimum labels.
- Keyboard/touch selection, light/dark rendering and narrow layouts retain readable labels and live status.

## 12. Delivery sequence and completion criteria

1. **Exact core + direct-host capture + elliptic compatibility adapter.** Capture one authoritative source with explicit origin; derive sparse quotient and export/replay it; run Q/P and large-comb fixtures. The direct route supports the host's m≤720 without a curve. The elliptic route preserves its narrower admission and source provenance. This adapter work precedes the atom adapter.
2. **Graph + kernel + linked selection.** Preserve full source under visibility changes, expose multiplicity/identity shift, captured-address labeling, inherited admission limits and evaluation status. Together with both capture routes, this is the first useful release.
3. **Atom adapter + three small presets.** Add explicit step/coset selection, contributions/resultant/height, and source-binding status. Do not flatten noncyclic groups into one imagined orbit.
4. **Neighborhood certificates.** Add bounded clique search and comparison regimes with domain labels; no automatic asymptotic theorem badge.
5. **Walk unfolding + count patterns.** Reuse the same operator and endpoint map. Add quotient towers, nested intervals and incidence ontologies only after these work.

Done for the first release means phases and multiplicities recompute from exact source; all Q/P and large-comb fixtures pass; the direct route works without curve setup through m=720; numerical/partial results are labeled; selecting graph/phasor/spectrum elements links their exact IDs; source origin, captured N/s and live/held/blocked state are visible; the JSON export reopens by recomputation; existing host source, curve and BSD exports remain valid.

## 13. Context and scope

The original Chowla/graph discussion motivates comparing a spectral minimum with local additive structure. It does not certify the new implementation. Relevant papers from the discussion are [Bedert](https://arxiv.org/abs/2509.05260), [the subsequent note](https://arxiv.org/abs/2609.05338), and [the graph paper](https://arxiv.org/abs/2509.03490). Version-specific theorem attribution and hypotheses must be checked before adding a theorem-backed user claim.

The factorial cyclicity classification, while correct for k≥2 (only k=2,6), is explanatory context rather than a gate: compute cyclicity from actual coordinate orders. The large-k argument uses the uniform two-prime threshold R₂=11, stated with attribution to Ramanujan in [Sondow's abstract](https://arxiv.org/abs/0907.5232); small k need separate checks.

No claim here identifies torus characters with algebraic curve maps, phase coincidences with rational cubic points, or combinatorial evidence with BSD evidence. The inspector's purpose is to make these distinct maps and their losses observable.

## 14. Checks performed while preparing this schema

On 2026-09-21, a local Python check enumerated all 3,100 pairs m=1…31, q=1…100. Explicit residue counts agreed with the canonical injectivity rule; every injective case had the stated identity weight and symmetric 0/1 off-diagonal weights. Independent weighted adjacency matrices and numerical character sums agreed with the expected spectra in Q1–Q8 within absolute tolerance 1e−12. Direct orbit enumeration matched the order components of A1–A5. S1's two membership patterns and W2's integer walk counts also passed.

Subsequent local checks reproduced Q9's matrix/spectrum and S2's integer triangle-free condition plus the mod19 witness {0,3,11}. Additional arithmetic checks covered (m,q)=(720,2), (32,3), (720,1440), (720,1438), and (2,3). For m32/q3 the residue weights are10,11,11; for m2/q3 the diagonalWeight is0 although its first sparse entry is residue1. The m720/q2 case has off-diagonal weight720; m720/q1440 is injective while m720/q1438 has719 distinct residues. The FCA context and incidence checks are recorded in §15.6. The host's comb range control was also read and confirms maximum720.

These are self-checks of the specification's finite fixtures, not tests of an implemented panel, not a rerun of Fable's audit, and not an independent certification. No panel has been built. The §11 fixtures must run against actual implementation code; capture-binding, stale-result rejection, UI behavior, import validation and asynchronous behavior remain untested implementation requirements. The direct-host adapter likewise remains unimplemented, so no operational large-comb or source-binding test is claimed.

## 15. FCA bridge

This extends the atom adapter. It does not add an FCA dependency to the initial cyclic m-comb panel. One many-valued table supplies the divisor objects and their exponent values; explicit scalings produce different incidence contexts. A scale toggle preserves selected divisor IDs, but changes concept IDs, closure, order and available transformations. It does not assert that the two concept lattices are isomorphic.

### 15.1 Contexts and orientation

Let P be the positive prime powers p_i^k with 1≤k≤a_i, ordered by divisibility. The Birkhoff context has objects P, attributes P, and incidence `(g,b) iff b does not divide g`. Its extents are exactly the down-sets of P. Map extent E to lcm(E), with lcm(empty)=1. This preserves extent inclusion and divisor order. The superficially similar incidence `g divides b` does not give the intended representation.

The many-valued context instead has all divisors as objects, prime coordinates as attributes and exponents as values. Its scaled contexts are:

| Context ID | Attribute / incidence | Extents | Orientation |
|---|---|---|---|
| `DIVISOR_ORDINAL_GE` | (i,k), e_i≥k, 1≤k≤a_i | Principal filters ↑d, the multiples of d in Div(N) | Inclusion reverses labels d |
| `DIVISOR_ORDINAL_LE` | (i,k), e_i≤k, 0≤k<a_i | Principal ideals ↓d | Inclusion preserves labels d |
| `DIVISOR_NOMINAL_EQ` | (i,k), e_i=k, 0≤k≤a_i | Coordinate faces plus empty extent | Inclusion orders faces |
| `DIVISOR_STRAND_MEMBERSHIP` | Complete prime strand; divisor belongs to it | Derived strand incidence | Used to build adjacency, not identified with the whole nominal concept lattice |

Under the usual FCA convention, concepts are ordered by inclusion of extents. Thus GE has the correct number of concepts but is order-reversing under the natural label d of ↑d. Div(N) is self-dual, so labeling ↑d by N/d yields an order isomorphism, but it changes labels. Default to LE for the familiar ascending divisor diagram, or show an explicit reversed-order indicator in GE. Never reverse arrows while claiming the same selected integer label has the same order meaning.

For N>1 every n_i≥2. Nominal faces choose, independently per coordinate, one of n_i fixed values or leave the coordinate free; add the empty extent. Consequently there are product(n_i+1)+1 concepts. A strand is a face with exactly one free coordinate. Incidence in the nominal value context fixes a single coordinate; for three or more coordinates such an attribute is a hyperplane, not itself a strand. Build the strand context by fixing all other coordinates. Do not use the nominal value-incidence matrix in place of the strand-incidence matrix below.

For N=1 handle the sole divisor explicitly; the above nominal count formula assumes a nonempty prime-coordinate family. The empty-attribute context on the one divisor has one concept, not two.

### 15.2 Group action is declared data

Translation on G_N permutes divisor addresses and acts on nominal attributes by `(i,k)↦(i,k+v_i mod n_i)`, preserving incidence. It also permutes complete strands, so their shared-membership adjacency is translation invariant. Choosing the canonical residue encodings and their regular translation action gives the strand Cayley representation.

FCA alone supplies no distinguished cyclic order on each nominal alphabet. Nominal permutations allow many automorphisms; the residue action is additional declared structure. A regular group action on objects requires a chosen invariant relation before a particular Cayley graph is specified.

Every nonzero translation fails to preserve the ordinal divisor order: its unique least element would have to be fixed. Zero translation is the identity. Permuting coordinate chains of equal lengths can preserve the unlabelled divisor order, but this is different from translating exponent values. If prime labels are fixed individually, those coordinate permutations are not label-preserving symmetries. Any automorphism count must state which labels may move.

### 15.3 Incidence factorization and sharp spectral bound

Let r=ω(N), and B have one row per divisor and one column per complete prime strand, with 0/1 membership entries. Every divisor lies on exactly r strands. Two distinct divisors share one strand precisely when they differ in exactly one coordinate. Therefore:

`B Bᵀ = r I + A_strand`.

Positive semidefiniteness proves only `λ_min(A_strand)≥−r`. To prove equality for N>1, choose for each coordinate a nonzero real vector u_i with sum zero. Define `f(e)=product_i u_i(e_i)`. Summing f along any strand gives zero, so `Bᵀf=0` with f nonzero. Hence `A_strand f=−r f`.

The nullspace is the tensor product of the coordinate zero-sum spaces: its dimension is product(n_i−1). This agrees with the character formula, where eigenvalue −r occurs exactly when every coordinate character is nontrivial. Display the factorization identity, lower bound and an attaining witness as separate parts of the certificate.

### 15.4 Order and group transforms

On the divisor poset, the zeta transform is `F(d)=sum_(a|d) f(a)`; Möbius inversion uses `μ_D(a,d)=μ(d/a)`. On the selected finite group, Fourier characters diagonalize translation sums. These are different transforms, attached to different relations on the same address set.

An exact bridge for cyclic root sums is obtained by partitioning all Q-th roots by their exact orders:

`sum_(d|Q) c_d(k) = sum_(j=0)^(Q−1) e(kj/Q) = Q [Q divides k]`,

where c_d(k) is the sum of k-th powers of primitive d-th roots. Möbius inversion gives `c_Q(k)=sum_(d|gcd(Q,k)) d μ(Q/d)`. The primitive-root definition is also stated in [Shareshian–Sundaram, Ramanujan sums and rectangular power sums](https://arxiv.org/abs/2305.12007).

This full-root identity describes a uniformly covered cyclic group; an arbitrary centered m-comb at an arbitrary phase is not automatically that full-root sum. When an actual comb meets a uniform-coverage condition, include its multiplicity and any coset-character factor. Keep all other comparisons as explicitly defined experiments. No content of the earlier Fourier–Kempner note was re-audited for this revision.

The translation operator by itself does not encode the chosen divisor order, but its vertices may retain divisor labels and ordinal attributes. Unrestricted histories also do not recover order: they still permit cyclic wraps. Provide separate walk semantics:

- `GROUP_WALK`: tooth translations, including wraps; cyclic Fourier evolution remains valid.
- `DIVISIBILITY_ASCENT`: directed cover moves increasing one exponent within its bound; different transition operator, not generally diagonalized by cyclic characters.
- `ORDER_ANNOTATED_GROUP_WALK`: original group walk with each transition tagged ascending, descending or incomparable in divisibility; retain the original operator.

### 15.5 Record, UI and validation additions

Add a nullable `fcaRecord` to the draft V1 export envelope:

```ts
interface FCARecord {
  contextId: 'BIRKHOFF_NON_DIVIDES' | 'DIVISOR_ORDINAL_GE'
    | 'DIVISOR_ORDINAL_LE' | 'DIVISOR_NOMINAL_EQ'
    | 'DIVISOR_STRAND_MEMBERSHIP';
  atomInputDigest: string;
  objectKind: 'PRIME_POWER' | 'DIVISOR';
  orderConvention: 'EXTENT_INCLUSION';
  conceptLabel: 'LCM_DOWNSET' | 'FILTER_GENERATOR'
    | 'IDEAL_GENERATOR' | 'FIXED_COORDINATE_FACE' | 'EXTENT';
  labelOrder: 'PRESERVING' | 'REVERSING' | 'NOT_A_DIVISOR_LABEL';
  action: 'NONE' | 'CANONICAL_RESIDUE_TRANSLATION';
  walkSemantics: 'GROUP_WALK' | 'DIVISIBILITY_ASCENT'
    | 'ORDER_ANNOTATED_GROUP_WALK';
}
```

Validate these combinations against context definitions. Translation action is admitted for nominal and strand contexts, not as an automorphism of ordinal contexts. A context mismatch blocks the requested automorphism claim; it does not erase the underlying divisor selection. Concept views may select an extent containing many divisors: keep this selection distinct from one divisor ID. Extent identifiers are canonical object sets or canonical face constraints, not screen coordinates.

The context selector changes incidence; the graph selector changes which relation is rendered; the transform selector chooses order inversion or group Fourier analysis where supported. Do not collapse these three choices into a toggle that silently changes a spectrum's meaning. Optional compact presets can set all three with an explicit description.

Expose B and B Bᵀ only within a matrix budget; compute strand memberships and the factorization certificate combinatorially for larger atoms. Nominal concept counts can exceed the number of divisors substantially: enumerate small cases, otherwise expose selected faces and exact counts. Require the existing status/partial-result conventions for any truncated concept lattice.

### 15.6 Context checks and acceptance additions

Local closure enumeration reproduced:

| N | Birkhoff concepts | GE ordinal concepts | Nominal concepts | Shape of B | Nullity of Bᵀ |
|---|---:|---:|---:|---|---:|
| 12 | 6 | 6 | 13 | 6×5 | 2 |
| 36 | 9 | 9 | 17 | 9×6 | 4 |
| 360 | 24 | 24 | 61 | 24×26 | 6 |
| 720 | 30 | 30 | 73 | 30×31 | 8 |

The check compared Birkhoff lcm labels with every divisor, GE extents with every principal filter, and integer B Bᵀ with rI+A. Numerical matrix-rank checks agreed with the nullity formula; the tensor-product argument above supplies its exact justification. These checks used independent small context constructions, not the existing viewer's UI.

Add acceptance cases for GE label reversal (Div(12): ↑4 is contained in ↑2), LE label preservation, nominal hyperplanes versus strands in a three-coordinate atom, nonzero translation violating the least-element condition, zero translation preserving it, and different endpoints/operator spectra under ascent versus group walks. Keep FCA implementation after the core graph, atom and source-binding milestones.

## 16. Changelog

All entries below are dated 2026-09-21. The current document revision is stated once in the header. The filename retains the v0.1 document-family identifier; the proposed `MCOMB_CAYLEY_INSPECTOR_V1` export ID is a separate interface identifier, not this document's revision.

| Revision | Changes |
|---|---|
| v0.1 | Initial implementation contract, source pins, exact records, graph/spectrum and atom/recursive views, acceptance fixtures and self-check record. |
| v0.1-A | Added FCA contexts, explicit order orientation and group action, strand-incidence factorization with an attaining eigenvector, and three distinct walk semantics. |
| v0.1-B | Promoted direct-host capture through m720 into the first release; documented elliptic admission limits; bound λ_h to captured N/s; corrected residue-zero lookup and anchor indexing; added Q9, S2, large-comb fixtures and captureBinding provenance. |
| v0.1-C | Changed §6B to “captured physical sample”; consolidated revision labeling and this changelog; combined arithmetic check history in §14 and explicitly separated specification checks from future implementation tests. No mathematical contract, source pin or delivery-order changes. |
