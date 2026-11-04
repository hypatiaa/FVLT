# R1 statement and standing table

2026-11-03. All names below are in `FVLT.FareyContactV1`; frozen full headers are in the bound template. **Independent per-row statement-fidelity sign-off is pending.** This table proposes source relationships; it does not assign kernel standing to helper extensions. Governing kernel: v3.3.1, SHA256 `e49533088843e2cd0a1c531c4d8ba113ea30113e8135a15c17c040bdfca3e0e0`.

| Lean target | Source relationship | Standing retained | Independent sign-off |
| --- | --- | --- | --- |
| raw_det_one_coprime | Classical determinant-one arithmetic supporting II.5b and II.5i; signature freeze A1 | General helper extension; no new kernel standing | Pending |
| rawValue_num_den | Canonical rational round-trip; signature freeze A1 and order §3 representation choice | Implementation/classical helper | Pending |
| rawValue_canonical | Coprime numerator and positive-denominator bridge; signature freeze A1 | Implementation/classical helper | Pending |
| rawValue_unique | Uniqueness under the explicit reducedness/positivity binders; signature freeze A1 | Implementation/classical helper | Pending |
| coprime_den_not_adj | Explicit 1/3, 1/5 determinant-two guard witness; signature freeze A1, supporting the II.5b determinant criterion | Exact finite arithmetic witness, not a general connectivity result | Pending |
| adjacent_mediant | Classical Farey mediant background supporting II.5b; signature freeze A2 | General classical helper extension | Pending |
| rosette | II.5b unconditional rosette specialization, kernel paragraph beginning at line 716; signature freeze A2 | Unconditional arithmetic specialization, no interpretive cone-placement claim | Pending |

The private helpers `coprime_from_det` and `unitFrac_data` are proof support, not additional kernel claims. The rosette's two flanks have determinant 2; the two adjacency conclusions join the middle circle to each flank, not the flanks to one another. Its mediant need not preserve the unreduced numerator/denominator sums in this non-neighbour case.

Credit: framework assembled by Robin Miller; Farey/Ford components are classical results of others. See the module header and work order for Ford, Apostol and Paulson references. No novelty claim or automatic kernel adoption is made.
