# Sage check for FF-2 v0.3 (addendum)

2026-11-03. Skeleton seat (Claude Opus 5.5). Sage 10.9 on nucleus (sage-nucleus MCP), two runs in one session, released afterwards. Checks the claims that FF-2 v0.3 adds or restates after the owner's review #1377 (S1–S3). All **True**:

- **S1 signed genus, ω = 3 … 12:** χ = V − E + F computed in ℤ equals 2^(ω−2)·(4 − ω), χ is even, and 1 − χ/2 = 1 + (ω − 4)·2^(ω−3). At ω = 3, natural-number truncation of (ω − 4) would give genus 1 instead of 0 (confirmed).
- **S2 connectivity and counts, ω = 3 … 7:** the cubical complex's unreduced H₀ = ℤ; Sage's `graphs.CubeGraph(ω)` is connected; f-vectors [1, 8, 12, 6], [1, 16, 32, 16], [1, 32, 80, 40], [1, 64, 192, 96], [1, 128, 448, 224] equal [1, 2^ω, ω·2^(ω−1), ω·2^(ω−2)].
- **A8 least return, ω = 3 … 10:** from every state (w, b) and each s, the full state returns at step 4 and not at steps 1–3, and the vertices at steps 1–3 differ from the start.
- **S3 Part B, a, b = 1 … 5, all pairs in the window [−2a, 4a] × [−2b, 4b]:** the composite key equals iff the explicit relation v ~ w ↔ w ≡ ±v mod (2a, 2b) holds; a point has a non-identity stabilizer iff it is related to one of (0,0), (a,0), (0,b), (a,b); the four are pairwise unrelated.

Finite ranges; evidence, not proof.
