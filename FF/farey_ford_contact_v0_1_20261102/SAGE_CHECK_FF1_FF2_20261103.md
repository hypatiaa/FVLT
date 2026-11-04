# Sage check of FF-1 signatures and FF-2 claims

2026-11-03. Skeleton seat (Claude Opus 5.5), at saphir's instruction "You have access to sage so use it". Sage 10.9 on nucleus (sage-nucleus MCP), three runs, sessions released afterwards. This adds general (symbolic) checks to the finite script check in `FREEZE_REVIEW_v0_1_ADDENDUM_A1_SCRIPTED.md`.

## 1. FF-1 identities, symbolically over ℚ[a, c, q, s] (x = a/q, y = c/s, D = a s − c q)

All **True**:
- A3 `ford_distance_identity`: |c_x − c_y|² − (r_x + r_y)² − (D² − 1)/(q² s²) = 0 in the fraction field.
- A4 no internal tangency: d² − (r_x − r_y)² = (x − y)², so for x ≠ y two Ford circles meet in one point only by external tangency (d = r_x + r_y, i.e. D² = 1).
- A4 `kiss_membership` for both circles: (|k − c|² − r²)·4q⁴(q² + s²)² lies in the ideal (D − e, e² − 1), i.e. vanishes whenever D = ±1.
- A4 `two_squares` (Brahmagupta) as a polynomial identity; A4 `kiss_integer_identity` in the ideal (D − e, e² − 1).
- A2: det(x, m) = det(m, y) = D and (a + c) q − a (q + s) = −D for the mediant m = (a + c)/(q + s); hence the mediant is reduced and adjacent to both when |D| = 1.
- A6: det(1 − x, 1 − y) = −D.
- A5: det(1/n, 1/(n + k)) = k; rosette det = 2; 2/(2n + 2) = 1/(n + 1).

## 2. FF-2 Part A, the skin, as Sage complexes

`CubicalComplex` of the squares (cube coordinates [0,1] on the pair {i, i+1}, fixed elsewhere), ω = 3 … 7:

| ω | χ (Sage) | χ formula | H₁ | H₂ | 2g |
|---|---|---|---|---|---|
| 3 | 2 | 2 | 0 | ℤ | 0 |
| 4 | 0 | 0 | ℤ² | ℤ | 2 |
| 5 | −8 | −8 | ℤ¹⁰ | ℤ | 10 |
| 6 | −32 | −32 | ℤ³⁴ | ℤ | 34 |
| 7 | −96 | −96 | ℤ⁹⁸ | ℤ | 98 |

H₂ = ℤ: closed, connected, orientable. H₁ torsion-free of rank 2g with g = 1 + (ω−4)·2^(ω−3).

Vertex links, ω = 3 … 10, built from the actual squares at each vertex (edge directions as link vertices, one link edge per square): every link is a single simple cycle of length ω (order ω, size ω, all degrees 2, connected, no multiple edges). **True** at every vertex.

## 3. FF-2 Part B, all point pairs in the window [−2a, 4a] × [−2b, 4b], grids a, b = 1 … 6

- pillowKey ∘ pillow identifies exactly the orbits of the half-turn group: **True on all 36 grids**.
- The net map pillow(X,Y) alone is exact **only for a = 1** (grids (1,1) … (1,6)); it fails for every a ≥ 2. This confirms the FF-2 v0.1 Part B error found by the script and the v0.2 correction (B1 on pillowKey).
- Four cone classes on all 36 grids: **True**.

## 4. Scope

Section 1 holds for all values of the variables (polynomial / ideal-membership identities). Sections 2 and 3 are finite: ω ≤ 7 for homology, ω ≤ 10 for links, a, b ≤ 6 for Part B. The generic certificate theorems of FF-1 A7 are not checked here.
