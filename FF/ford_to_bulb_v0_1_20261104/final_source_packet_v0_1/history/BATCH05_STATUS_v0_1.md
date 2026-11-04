# FF-4 batch 5: the unique unit gap

2026-11-04. **The unique-unit-gap theorem passes producer checks; cumulative progress is 30 of 33.** Independent clean rebuild and mathematical-fidelity review remain pending.

The theorem identifies the sole directed gap of size one in the whole sorted orbit: it starts at the lower characteristic numerator and ends at the upper numerator. Every other directed gap is at least two, including the closing edge.

The proof establishes the final digit and hence parity of every phase word, identifies sorted coordinates using the increasing finite-set embedding, and checks the nonwrapping and wrapping cases separately. Other interior neighbours have equal parity; the closing edge is bounded below using strict interior word bounds. This is a uniform proof, without bounded enumeration.

| Latest module | Public theorem targets | Strict replay constants |
|---|---:|---:|---|
| FVLTFordBulbDataV1 | 0 | 54 |
| FVLTFordBulbParameterV1 | 4 | 4 |
| FVLTFordBulbCombinatoricsV1 | 26 | 136 |

Compilation, raw named axiom checks and strict replay pass. Named axioms are subsets of `propext`, `Classical.choice`, `Quot.sound`; every introduced helper and generated declaration is replayed. Counts are for the latest separate modules, without adding superseded counts.

Private list-index conversion attempts were preserved when they failed. The successful helper-only source was a compile checkpoint, not a full-pass claim; the final public module recompiles and replays those helpers. Repairs remain confined to proofs. All public statements and full frozen Data remain unchanged. Four if/dif lemma deprecation warnings remain.

Execution used nucleus over Tailscale and read-only v23, one CPU, 8 GiB and 240-second child limits. The original 1,800-second batch clock was never reset. All runs retained 401 checksums and unchanged protected files. G1 is excluded.

## Remaining frozen targets

- `FVLT.FordBulbV1.angle_order`
- `FVLT.FordBulbV1.intervals_disjoint`
- `FVLT.FordBulbV1.mediant_interval`

Next prove full arbitrary-address angle ordering, then interval disjointness and the mediant interval. C1 remains unrestricted to Farey neighbours. B6 uniqueness and ray landing remain deferred. Independent clean rebuild and separate fidelity review are required for final acceptance. No Rule 30 result, kernel adoption or library publication is claimed.

[Machine-readable closure](BATCH05_CLOSURE_v0_1.json) records final source and successful receipt hashes. Adjacent jobs, raw logs and the manifest retain the evidence. [Prior status](../batch04/BATCH04_STATUS_v0_1.md) remains unchanged.
