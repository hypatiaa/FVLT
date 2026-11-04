# R4 statement and standing map

2026-11-03. All targets are in `FVLT.FareyContactV1`. Kernel v3.3.1 SHA256 `e49533088843e2cd0a1c531c4d8ba113ea30113e8135a15c17c040bdfca3e0e0`. Exact headers are in the original A6 freeze and accepted R4 template. **Independent per-row fidelity sign-off is pending throughout.**

| Lean target | Kernel source relationship (original freeze routing) | Standing retained | Sign-off |
| --- | --- | --- | --- |
| phases_eq_unreduced | Setting / II.5g, lines 908–963 | Unconditional set equality on frozen profile domain | Pending |
| phase_domain | Same Setting / II.5g | Interior/admissible-denominator helper, explicit guards | Pending |
| denominator_partner | II.5i, paragraph beginning line 1013 | Unconditional exact partner criterion with range/recovery | Pending |
| partner_congruence | II.5i | Unconditional congruence plus induced-numerator range | Pending |
| cross_denominator | II.5i.1, beginning line 1050 | Unconditional on the interior phase domain only | Pending |
| isolation_criterion | II.5j, beginning line 1061 | Unconditional no-partner criterion | Pending |
| endpoint_isolation | II.5j.1, beginning line 1075 | Unconditional unit-fraction congruence/range form | Pending |
| complement_mem | II.5j.1 | Unconditional complement closure | Pending |
| complement_adj | II.5j.1, with classical rational coordinate helper | Unconditional adjacency preservation with frozen interior guards | Pending |
| complement_graph_auto | II.5j.1 | Actual Mathlib graph automorphism, specified action | Pending |
| isolated_complement_pairs | II.5j.1 | Unconditional complementary pairing, fixed point 1/2 | Pending |

The six private helpers support the translation without receiving new kernel standing. The S1 natural image-lambda annotation is an elaboration correction already accepted; it does not alter the event set. `phases`, admissibility, adjacency, graph and isolation semantics are imported from their audited predecessors.

The guards are part of these statements: positivity of the profile, membership in its phase set or admissible denominator set, strict interior bounds, and the exact numerator range remain as frozen. No modulo-only criterion or endpoint extension is claimed. General statements that happen to admit weaker hypotheses have not replaced the frozen headers.

Credit remains Robin Miller for the framework, with classical components attributed as in the order/module header. This delivery assigns no automatic kernel standing, adoption, dynamical interpretation or Rule 30 consequence.
