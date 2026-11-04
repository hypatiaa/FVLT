# FF-4 batch 1: producer progress and handoff

2026-11-04. **Closed partial batch: 11 of 33 frozen theorem targets pass producer checks.** Independent clean rebuild and mathematical-fidelity review remain pending.

The work ran on nucleus over Tailscale against the accepted v23 library. Each job was posted before launch. The original 1,800-second batch clock was preserved, with one CPU, 8 GiB and a 240-second child limit. All runs retained 401 library checksum entries and unchanged protected files. G1 is excluded.

| Module | Public theorem targets | Strict replay constants | Result |
|---|---:|---:|---|
| FVLTFordBulbDataV1 | 0 | 54 | Producer compile, named axioms and strict replay pass |
| FVLTFordBulbParameterV1 | 4 | 4 | Producer compile, named axioms and strict replay pass |
| FVLTFordBulbCombinatoricsV1 | 7 | 14 | Producer compile, named axioms and strict replay pass |

The Data module retains all 31 accepted declarations byte for byte. The four parameter theorems prove the cardioid fixed point, multiplier, derivative, and primitiveness of the canonical root of unity. The seven combinatorial theorems prove canonical reduced coordinates, the open-unit-interval range, injectivity, the lower bound on q, positivity of the modulus, and both digit formulas.

Parameter01 failed at a derivative helper API call. Its source, job, receipt and raw log remain intact. Parameter02 adds the derivative-addition import to the proof module and uses an explicit lemma; no frozen definition or public statement changed.

Every named axiom report uses only `propext`, `Classical.choice`, `Quot.sound`, or a subset. Strict replay checks every declaration introduced by each module; the counts are separate module checks, not an integrated dependency replay.

## What remains

The remaining 22 frozen targets are:

- `FVLT.FordBulbV1.address_surjective`
- `FVLT.FordBulbV1.word_sum`
- `FVLT.FordBulbV1.word_bounds`
- `FVLT.FordBulbV1.characteristic_bounds`
- `FVLT.FordBulbV1.characteristic_adjacent`
- `FVLT.FordBulbV1.characteristic_angle_gap`
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

The next proof chunk should begin with address surjectivity and the finite-word sum identity, then establish mechanical-word bounds and adjacency. Those support the exact rotation/orbit laws, unique unit gap, arbitrary-address interval ordering, and Farey consequences. C1 remains an arbitrary ordered reduced-fraction claim, not a restriction to Farey neighbours.

After the 33 targets are complete: independent clean rebuild, raw named axiom audit, strict replay, and separate statement-fidelity review. This batch does not claim ray landing, B6 uniqueness, Rule 30 consequences, kernel adoption, or publication.

## Evidence

[Machine-readable closure](BATCH01_CLOSURE_v0_1.json) records every passing receipt and source hash. [Batch deadline](DEADLINE_BATCH01.json) preserves the original clock. The adjacent jobs, comparison receipts and raw logs retain the full compile and replay evidence.
