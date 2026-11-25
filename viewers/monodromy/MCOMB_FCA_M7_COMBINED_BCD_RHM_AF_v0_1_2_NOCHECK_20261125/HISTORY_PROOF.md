# M6 definitions and finite proof obligations

The tooth alphabet is C_m = {-(m-1)/2,...,(m-1)/2} for odd m and {-(m-1),-(m-3),...,m-1} for even m. Every letter retains its original integer identity. A depth-d word is an ordered d-tuple of letters, including the zero letter when present. Parent is the length-(d-1) prefix.

Integer endpoint is start + sum c. Quotient endpoint reduces this sum modulo q. Atom endpoint is start + (sum c)v coordinatewise modulo the declared orders. These maps need not be injective. Words are never merged during generation. The breadth-first tree retains every displayed word and every prefix state; a node cap labels incomplete depths. Endpoint folding groups only the displayed words and retains all their IDs and multiplicities. It is COMPLETE only through the tree's last fully generated depth.

Counts use a separate recurrence starting at the chosen start address with count one. For each current endpoint x and each original letter c, add its count to x+c (or x+cv). This is w_(d+1)(j)=sum_c w_d(j-c). Repeated actions and loops therefore retain their multiplicity. Summing a complete layer gives m^d, or its residue modulo ell. Since the alphabet is symmetric this agrees with the function translation-sum convention in the inherited spectrum.

Integer counts fold into quotient counts: applying reduction to every endpoint commutes with each translated addition, so induction on depth proves equality, retaining multiplicity. For m=2 the integer counts are binomial(d,(d+j)/2). W1 has two depth-one histories at the same quotient endpoint; W2 has row 1,4,6,4,1.

Prime-field recurrence reduces every addition modulo a validated small prime ell. ell is not q and not a curve prime. Zero residues remain present for reachable endpoints. Counts are not complex amplitudes. Only unreduced count vectors are used in the numerical test of character evolution lambda_k^d; the UI exports no Fourier certificate.

Work caps are enforced before adding a new sparse cell and before further recurrence additions. A partially computed layer is discarded, retaining only fully computed rows. Tree and recurrence statuses are independent. The exact input, options, complete output, nested source and predecessor pin participate in the sidecar digest; replay recomputes everything. Hashing is not authentication of an actual walk visit.

## M5 audit follow-ups

O1: Independent graph tests now include 14 through 36 neighborhood vertices, including the 32-vertex boundary and refused exhaustive searches beyond it. Independent adjacency, boundary and clique computations bound every intermediate state.

O2: createSearch accepts a local stepLimit used by the SAME advance loop and frontier-bound result code. Default stays 250000. Tests set one step on a genuinely unresolved graph; no processed counter is forged. The result is PARTIAL / TOTAL_STEP_LIMIT with a valid witness and valid coloring/frontier upper bound. Further advance is stopped, and identical local-budget replay agrees. Production inspect and packet construction always use the unchanged default; a local-budget result cannot replay as a production packet. This exercises control flow, not natural exhaustion of the production cap.

O3: An additional quotient comparison uses signed minimum-absolute representatives, retaining the positive representative at an even half-modulus tie. Both u and t are explicitly recorded. Integer positions and integer patterns are recomputed using these representatives; quotient positions agree modulo q with the original comparison. Each new sufficient bound uses q > M + max |tested position| for THESE positions. Original canonical comparison and its certificate remain unchanged. A failed sufficient bound asserts no disagreement. No spectral-minimum equality follows.
