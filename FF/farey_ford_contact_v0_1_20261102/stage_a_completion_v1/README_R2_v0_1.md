# R2 statement and standing map

2026-11-03. All public target names are in `FVLT.FordGeometryV1`. Governing kernel v3.3.1, SHA256 `e49533088843e2cd0a1c531c4d8ba113ea30113e8135a15c17c040bdfca3e0e0`. Each row's exact header is in the accepted R2 template and original Stage A signature freeze. **Independent per-row fidelity sign-off is pending throughout.**

| Lean target | Original frozen group / source relationship | Standing retained | Independent sign-off |
| --- | --- | --- | --- |
| ford_open_disjoint | A3; classical Ford separation supporting II.5b's tangency reading, paragraph beginning line 716 | Classical geometry helper extension | Pending |
| ford_boundary_disjoint | A3; determinant gap separation in the same classical Ford background | Classical geometry helper, explicit distinctness and determinant bound | Pending |
| ford_tangent_iff | A3; classical determinant-one Ford law supporting II.5b / §9.4 | Exact singleton-intersection predicate; no dynamical reading | Pending |
| ford_real_axis | A3; classical Ford footpoint fact supporting that plane realization | Classical helper extension | Pending |
| kiss_unique | A4; classical coordinate/kiss background supporting II.5b | Full singleton equality, stronger than F1 membership | Pending |
| two_squares | A4; classical two-squares determinant identity | General integer polynomial helper | Pending |
| kiss_integer_identity | A4; determinant-one specialization of that identity | Exact integer identity, no new kernel standing | Pending |
| kiss_real_identity | A4; exact real cast of the integer identity | Classical helper extension | Pending |

The original signature freeze labels A3/A4's general results as classical background/helper extensions. This table does not relabel them as new kernel theorems. The six private helpers are implementation support and have no independent kernel standing.

All distinctness/positivity/adjacency/determinant-bound hypotheses remain explicit. Boundary intersections and open disks are different predicates. The rational bridge is not a dependency of these proofs, and these geometry results do not construct an oriented arc or an inverse from an unlabelled phasor.

Credit: framework assembled by Robin Miller; components are classical results of others, including Farey and Ford. Apostol ch. 5 and Paulson's Isabelle AFP development are structural references as recorded in the order and module header. No novelty claim or kernel promotion is made.
