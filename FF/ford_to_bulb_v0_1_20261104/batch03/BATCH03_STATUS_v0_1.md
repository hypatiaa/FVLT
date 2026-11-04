# FF-4 batch 3: order, rotation and Farey arithmetic

2026-11-04. **Five new theorem targets pass producer checks; cumulative progress is 22 of 33.** Independent clean rebuild and mathematical-fidelity review remain pending.

The new results prove exact return after q doublings, the Farey denominator lower bound, equality only at the mediant, strict ordering of all phase words, and the modular doubling/phase-rotation identity.

Strict ordering uses coprime modular surjectivity and exact prefix counts, with binary prefix uniqueness. The rotation identity follows by comparing prepend and append recurrences modulo `2^q - 1`. These are uniform proofs, without bounded enumeration. The denominator argument uses positive integer coordinates in an adjacent Farey basis; its classical bound follows the earlier FF-3 private proof pattern without referencing a private API.

| Latest module | Public theorem targets | Strict replay constants |
|---|---:|---:|---|
| FVLTFordBulbDataV1 | 0 | 54 |
| FVLTFordBulbParameterV1 | 4 | 4 |
| FVLTFordBulbCombinatoricsV1 | 18 | 97 |

Compilation, named axiom reports and strict replay pass for every listed module. Axioms are subsets of `propext`, `Classical.choice`, `Quot.sound`. Replay counts are separate-module checks; superseded combinatorial counts are not added again. Two old if-lemma names produce deprecation warnings in the strict-order proof; they do not affect proof checking.

Every failed attempt is preserved with its source and raw log. Repairs remain confined to proofs; all public statements and the entire frozen Data file are unchanged. Execution stayed on nucleus over Tailscale with the accepted read-only v23 library, one CPU, 8 GiB and 240-second child caps. The original 1,800-second batch clock was never reset. All runs retained 401 checksums and unchanged protected files. G1 is excluded.

## Remaining frozen targets

- `FVLT.FordBulbV1.characteristic_period_minimal`
- `FVLT.FordBulbV1.same_cycle`
- `FVLT.FordBulbV1.orbit_set_eq`
- `FVLT.FordBulbV1.orbit_card`
- `FVLT.FordBulbV1.orbit_length`
- `FVLT.FordBulbV1.rank_word`
- `FVLT.FordBulbV1.rank_step`
- `FVLT.FordBulbV1.unique_unit_gap`
- `FVLT.FordBulbV1.angle_order`
- `FVLT.FordBulbV1.intervals_disjoint`
- `FVLT.FordBulbV1.mediant_interval`

Next derive the arbitrary-iteration phase law, minimal period, common cycle, orbit set/cardinality, sorted ranks and the unique unit gap. Then prove full arbitrary-address interval ordering and its interval/mediant consequences. Full C1 remains unrestricted to Farey neighbours. B6 and ray-landing claims remain deferred.

Independent rebuild and separate fidelity review are still required for final acceptance. No Rule 30 result, kernel adoption or library publication is claimed.

[Machine-readable closure](BATCH03_CLOSURE_v0_1.json) pins final sources and successful receipts. Jobs, comparison records and raw logs remain adjacent; the manifest pins their bytes. [Prior batch status](../batch02/BATCH02_STATUS_v0_1.md) remains unchanged.
