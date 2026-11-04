# FF-4 batch 4: periods, cycles and ranks

2026-11-04. **Seven new theorem targets pass producer checks; cumulative progress is 29 of 33.** Independent clean rebuild and mathematical-fidelity review remain pending.

The new results are:

- `FVLT.FordBulbV1.characteristic_period_minimal`
- `FVLT.FordBulbV1.same_cycle`
- `FVLT.FordBulbV1.orbit_set_eq`
- `FVLT.FordBulbV1.orbit_card`
- `FVLT.FordBulbV1.orbit_length`
- `FVLT.FordBulbV1.rank_word`
- `FVLT.FordBulbV1.rank_step`

The exact phase-iteration law combines the modular doubling theorem with induction. Coprimality makes the phase walk surjective; strict word ordering makes it injective. Together they prove the minimal period and common cycle. The rank theorem counts phase words below a given word, and the rank-step law then follows from doubling.

| Latest module | Public theorem targets | Strict replay constants |
|---|---:|---:|---|
| FVLTFordBulbDataV1 | 0 | 54 |
| FVLTFordBulbParameterV1 | 4 | 4 |
| FVLTFordBulbCombinatoricsV1 | 25 | 113 |

All listed modules pass compilation, named axiom reports and strict replay. Axioms are subsets of `propext`, `Classical.choice`, `Quot.sound`. Replay counts are separate-module checks; superseded modules are not counted again. The two existing if-lemma deprecation warnings remain and do not affect proof checking.

Failed attempts retain their sources, jobs, receipts and raw logs. Repairs are confined to proofs, with the public statements and full frozen Data unchanged. Execution used nucleus over Tailscale with read-only v23, one CPU, 8 GiB and 240-second child caps. The new 1,800-second clock began before proof writing/staging and was never reset. All runs retained 401 checksum entries and unchanged protected files. G1 is excluded.

## Remaining frozen targets

- `FVLT.FordBulbV1.unique_unit_gap`
- `FVLT.FordBulbV1.angle_order`
- `FVLT.FordBulbV1.intervals_disjoint`
- `FVLT.FordBulbV1.mediant_interval`

Next prove the unique unit gap, then full arbitrary-address interval ordering and its disjointness/mediant consequences. Full C1 is not restricted to Farey neighbours. B6 uniqueness and ray landing remain deferred. Independent clean rebuild and separate fidelity review are still required for final acceptance. No Rule 30 consequence, kernel adoption or library publication is claimed.

[Machine-readable closure](BATCH04_CLOSURE_v0_1.json) records the pinned final sources and successful receipts. The adjacent manifest, jobs and raw logs preserve the evidence. [Prior status](../batch03/BATCH03_STATUS_v0_1.md) remains unchanged.
