# M5 API and record boundaries

Definition M5_0.1.0. Existing M4 packet schemas and APIs are unchanged.

McombStructureV1 exports definition(input), graph(input), inspect(input,processedSteps), createSearch(input), advance(state,maxSteps=2000,milliseconds=200), searchResult(state), verifyWitness(input,witness), and preset(name). Internal search state is local-only; it is not an accepted imported proof.

Scalar input keys: context (INTEGER_LABEL or QUOTIENT_SIMPLE), positiveFrequencies (distinct sorted positive decimal strings), canonicalM (decimal string or null), q (null for integers, positive for quotient), origin, t, u (canonical integer strings), comparisonQ (positive string or null). Quotient origin/t are canonical residues. canonicalM, when present, must reproduce the positive canonical comb frequencies. Quotient simple admission independently refuses zero residues or collisions among signed nonzero labels. There is no silent support-graph conversion.

ATOM_STRAND input keys: context, orders, origin, t. Each coordinate order is 2..65; tuples are canonical exponent arrays. Empty orders describe the singleton atom. The UI obtains orders only by replaying an existing exact M4 atom packet. It does not infer addresses from geometry.

Graph output records offsets and translated addresses separately, exact H edges, degree, triangle count through the inspected address, ordered adjacent-neighbor count, both opposite-neighborhood sets and their difference. Boundary t is an offset relative to the inspected address. t need not belong to H. Signed original labels remain paired with quotient offsets.

The clique record contains processedSteps, neighborhood and full-graph witnesses, lower/upper bounds, status and reason, and a proper root coloring. A finite search frontier supplies a valid upper bound. Packet replay reproduces the deterministic search for the recorded number of steps and compares every field. Equal lower and upper bounds justify EXACT even if a search cap was reached; otherwise the result is PARTIAL. Cancellation is a UI event; it cannot convert a partial bound to a maximum.

McombStructurePacketV1.construct(binding,controls,processedSteps='0') and replay(bytes) handle MCOMB_LOCAL_STRUCTURE_V1. Controls are context, origin, t and u (u=null for atom tuples). Bindings are CAYLEY with original packet bytes, ATOM with M4 atom or shell-walk packet bytes, or DETACHED with one of S1, S2_INTEGER, S2_QUOTIENT. The original source gate replays first. The M5 graph must be derived from that source and controls; arbitrary imported graph claims are compared against fresh derivation.

All packet fields except exactDigest itself participate in canonical SHA-256 (exactDigest is replaced by the empty string while hashing). Imported duplicate keys, extra fields, wrong pins, malformed exact values, graph forgeries and modified certificates are rejected. Replay returns fresh values with arithmeticPromotion=false. This is consistency of the declared source, not authentication of a historical visit.

McombStructureAdapterV1 exports configure(contextOrFixture), inspect(), resume(), cancel(), reopen(bytes), snapshot(), and state. configure/reopen initiate asynchronous worker work; await a nonpending snapshot or the visible failure state. Imports start held. Invalid imports clear current authority and cannot be resurrected with Apply. Runtime ticket and fresh source checks guard commits and exports. No method appends to the BSD register or changes the host source.

Limits: 256 bits per input integer; at most360 positive frequencies, 16 atom coordinates and1024 neighbors; default exhaustive search at most32 neighborhood vertices and250000 steps; 200 ms worker slices. Above the search vertex limit, a proper coloring and a clique witness still yield honest bounds. Drawing caps256 vertices and4096 edges never truncate the exact certificate. M5 packets are capped at16000000 UTF-8 bytes; their nested source packets retain their own limits. Full source and certificate replay runs in the worker in the UI, preserving cancellation even during replay.

The lifting result keeps uniform q>3M and q>4M conditions separate from selected-position thresholds q>M+max|u+jt| and q>M+max|a+-t|. Failing a sufficient bound does not assert disagreement. Actual five-position patterns are computed independently in the two domains. No sampled/continuous spectral-minimum equality follows.
