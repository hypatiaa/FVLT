# M7 API and budgets
McombFCAV1.definition({N,factors,step,m}) validates factorization against immutable M4 rules. Integer fields are canonical strings, except bounded safe-integer m. fca-core.js is used by Node tests and the browser worker unchanged.

derive(input, options) returns definition, fcaRecord, context, lattice, independent divisor/extent/face selections, actionCertificate, strand, walk and arithmeticPromotion:false. Options have exactly contextId, action, walkSemantics, start, depth, conceptLimit, selectedDivisor, selectedExtent, face. An extent is null or a canonical ordered closed object set. A face is a tuple of null (free) or canonical exponent strings. A selected divisor is an exponent tuple, not an extent ID.
Record metadata is derived from the context: object kind, label kind, preserving/reversing orientation and EXTENT_INCLUSION. Translation action is allowed only for nominal and strand contexts. Walk semantics are independent and must be one of the three explicit operators.

Limits: 256 enumerated context objects; 2,048 attributes; 256 concepts; 40,000 NextClosure calls; 65,536 matrix cells (both B and BBt bounded); walk depth ≤12 and 2,048 nodes; sidecar ≤16 MB. Known concept counts and selected faces remain exact above object limits. Unknown strand concept totals remain null if enumeration is incomplete. Diagram ≤64 vertices; concept covers computed only for complete lattices with ≤128 concepts. Incidence UI ≤4,096 cells. These are display limits, never exactness tests.

transforms(definition, values) admits ≤256 canonical integer values, each ≤256 bits, and returns exact zeta and inverse rows. rootSums(Q,k) admits 1≤Q≤100000 and bounded integer k. The Fourier UI uses exact step phases and separately labelled numerical eigenvalues.

McombFCAPacketV1.construct(atomBytes, options) first replays a manual or shell-walk M4 packet. It derives factors, step and comb size from that source, binds atomInputDigest to canonical M4 input and atomSha256 to exact nested bytes. replay recomputes all content and compares canonical records, rejecting unknown fields, duplicate keys, forged nested sources, metadata, selected extents and certificates. MCOMB_FCA_CONTEXT_V1 is an own sidecar, preserving predecessor envelopes.

McombFCAAdapterV1 exposes compute, follow, reopen, snapshot and read-only state. Worker tickets and fresh source keys prevent stale commits. Control edits clear export authority; source checks run again before export. Imports start held. Invalid imports cannot regain authority through Apply. Changing incidence clears the selected extent, retaining the selected divisor when valid. A different coordinate family resets incompatible local selection/start controls.

## Inherited M6 clarification
History count cellLimit is a cumulative total across all retained layers, not a per-layer cap. A partial layer is discarded; the prior complete rows remain exact. The code implementing those counts is unchanged.

## Verification retry
Only a failed browser job whose output explicitly reports a timeout is retried, once. Process watchdog failures and ordinary assertions are not retried. The first log and extant suite result files are copied to attempt-1 evidence. The receipt retries array gives first/second exit codes and PASS_AFTER_RETRY or FAIL. A second failure fails the run. Arithmetic suites never auto-retry. This is a verifier behavior change, not a mathematical relaxation.
