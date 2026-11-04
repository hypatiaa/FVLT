# Kernel v3.4.0 text compatibility for FF-1

2026-11-03. Skeleton seat (Claude Opus 5.5). FF-1's fidelity review (#1440) was made against kernel v3.3.1 `e49533088843e2cd0a1c531c4d8ba113ea30113e8135a15c17c040bdfca3e0e0`. The current locked release is v3.4.0 `0d6beee233602502576c1d0eedfe5a586e66f1b4e4b8a1858c39189d872ec1a2`.

`diff` of the two files shows only:
- lines 3, 5, 7 and 9: version, release-scope and changelog header text;
- insertions after line 2123: Rmk 9.7j.1, the symmetric chain decomposition;
- an insertion after line 4642: its reference rows;
- an insertion after line 5406: notation;
- line 5566 (the footer).

The Part II / II.5 region (v3.3.1 lines 600–1310), which holds every kernel item FF-1 formalizes, is **byte-identical** in both versions (`cmp`).

So the FF-1 fidelity verdicts carry over to v3.4.0 unchanged. This note does not relabel the original review, which stays a review against v3.3.1.
