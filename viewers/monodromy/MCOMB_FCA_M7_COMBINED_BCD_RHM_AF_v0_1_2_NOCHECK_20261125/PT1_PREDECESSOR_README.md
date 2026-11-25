# PT1 v0.1 — exact rational points and complete torsion

Implementation baseline: sealed BSD_LINKED_VIEW_V1_v0_8_20260923 (Monodromy.31.7), under PT1 handoff v0.5 and its included Opus addendum. Predecessors remain unchanged. New work is in this package only.

Launch with **node server.cjs** and open the printed random 127.0.0.1 URL. Exact point controls, finite-subgroup proof, full torsion, and the separate 37a1 rank lower bound appear in the PT1 panel. The inherited T4 endpoint and server bytes are unchanged. Browser-local PT1 has separate verifier hashes.

On y²=x³−x, complete torsion C2 × C2, order 4, enters the actual BSD denominator. T4 retains conductor 32 and Tamagawa product 2. On 37a1, complete trivial torsion and nonidentity (0,0) certify **rank ≥ 1 only**. Exact algebraic rank, analytic rank, basis, saturation, regulator, leading term and independent Sha remain outside this result.

Read PT1_CONTRACT.md and HANDOFF.md. The 18 fixtures include all thirteen Opus Tate-normal-form rows, cyclic orders through 12, noncyclic groups through C2 × C8, and rational presentations. Their candidate provenance is separate from replay. Automatic discovery searches x=-8..8 plus supplied exact candidates; it is deliberately bounded. Other inputs can return partial or unavailable. The only exhaustive fallback implemented here is the documented y²=x³+x order-2 proof.

Replay a single raw PT1 packet via **node pt1-replay.cjs**, supplying its JSON on stdin. The Node API is replay(bytes, expectedBinding). Linked exports use BSD_POINTS_TORSION_LINKED_V1 and include the full predecessor linked packet, current evidence records, exact visits and complete PT1 packet. Reopening performs fresh replay. Legacy source export remains separate. Local calculations and O visits work in file mode, with linked authority explicitly offline.

Run **node verify.cjs** for the complete default verifier. It creates disposable scratch packages and writes all receipts, screenshots, downloads and logs outside the assessed package. Optional pt1, core and v1-only modes have smaller stated scopes. A full post-seal run is mandatory; its external receipt, not an old report, determines final builder standing. SOURCE_PINS.json, MANIFEST.sha256, BUILD_PINS.json and PRESEAL_SUMMARY.json identify this candidate.

No Sage installation, independent cold audit, seating or lock is claimed. Optional bad-prime cross-check, coefficients/Sturm, twists, characters, heights, exact rank and P1 placement remain later work.
