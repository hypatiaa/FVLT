# FF-4 batch 2: exact words and characteristic adjacency

2026-11-04. **Six new theorem targets pass producer checks; cumulative progress is 17 of 33.** Independent clean rebuild and mathematical-fidelity review remain pending.

The new results establish:

- Every rational strictly between 0 and 1 has a guarded reduced address.
- The finite indexed digit sum equals the encoded binary word.
- Every word is strictly between zero and the modulus `2^q - 1`.
- The upper characteristic numerator is exactly the lower numerator plus one.
- Both characteristic numerators lie strictly inside the modulus, in increasing order.
- The characteristic angle gap is exactly `1 / (2^q - 1)`.

The bounds proof counts digits by a carry identity and telescoping, then applies binary bounds. The adjacency proof uses coprimality to rule out an earlier divisible prefix, proves the early words agree, and identifies the final `01`/`10` swap. These are uniform exact proofs, with no finite enumeration.

One private natural-subtraction tactic failed in Combinatorics04. Its source, job, receipt and raw log are preserved. Combinatorics05 replaces only that tactic with `omega`; all public statements and frozen Data remain unchanged.

| Latest module | Public theorem targets | Strict replay constants |
|---|---:|---:|
| FVLTFordBulbDataV1 | 0 | 54 |
| FVLTFordBulbParameterV1 | 4 | 4 |
| FVLTFordBulbCombinatoricsV1 | 13 | 59 |

Every module passes compilation, raw named axiom checks, and strict replay of all introduced constants. Named axioms are subsets of `propext`, `Classical.choice`, and `Quot.sound`. Counts above are separate-module checks; superseded combinatorial modules are not counted again.

Execution used nucleus over Tailscale with the accepted read-only v23 library, one CPU, 8 GiB and 240-second child limits. The new 1,800-second batch clock began before proof writing and staging, and was never reset. All runs retained 401 checksums and unchanged protected files. G1 remains excluded.

## Remaining frozen targets

- `FVLT.FordBulbV1.characteristic_period_return`
- `FVLT.FordBulbV1.characteristic_period_minimal`
- `FVLT.FordBulbV1.same_cycle`
- `FVLT.FordBulbV1.word_strict`
- `FVLT.FordBulbV1.orbit_set_eq`
- `FVLT.FordBulbV1.orbit_card`
- `FVLT.FordBulbV1.orbit_length`
- `FVLT.FordBulbV1.rank_word`
- `FVLT.FordBulbV1.double_word`
- `FVLT.FordBulbV1.rank_step`
- `FVLT.FordBulbV1.unique_unit_gap`
- `FVLT.FordBulbV1.angle_order`
- `FVLT.FordBulbV1.intervals_disjoint`
- `FVLT.FordBulbV1.mediant_interval`
- `FVLT.FordBulbV1.farey_denominator_min`
- `FVLT.FordBulbV1.farey_denominator_eq_iff`

Next: exact period return and minimal period, the common cycle, strict word ordering and orbit/rank laws, the unique unit gap, then arbitrary-address interval ordering and Farey consequences. Full C1 remains an arbitrary ordered reduced-fraction statement; it is not weakened to Farey neighbours.

Independent rebuild, raw axiom audit, strict replay and separate fidelity review are still required for final acceptance. No ray-landing/B6 uniqueness, Rule 30, kernel-adoption or publication claim is made.

[Machine-readable closure](BATCH02_CLOSURE_v0_1.json) pins the final sources and every successful receipt. The adjacent manifest, frozen jobs and raw logs preserve the evidence. [Prior batch status](../batch01/BATCH01_STATUS_v0_1.md) remains unchanged.
