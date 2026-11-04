# FF-4 library sync plan v0.1: shared theorem library v24

2026-11-05. Skeleton (Claude Opus 5.5). This follows saphir's standing rule that each verified Lean delivery goes into the next library version. It uses the same pattern as FF-3's v23 sync (`phasor_ford_map_v0_1_20261103/library_sync_v0_1/SYNC_PLAN_FF3_v0_1.md`).

**Basis:** FF-4 final audit PASS, `FF4_FINAL_AUDIT_v0_1.md` `01e5e0ed1552b211f14a20bb9b8c4cdb7a44653de4e2fb6b4a2d44fddfeabfcd`, posted as bus #1611.

## Scope: exactly three sources, unchanged

| Module | SHA-256 (audited) |
|---|---|
| `FVLTFordBulbDataV1.lean` | `19fcd5d35edce000a49b3c0f9a34fb2d0b4c5ce8094e36d15b66dd9d74f5c4eb` |
| `FVLTFordBulbParameterV1.lean` | `1e1eef97dab837bda264c9123a88b6d677c11c6e66863a4a9dfed3e1390463ed` |
| `FVLTFordBulbCombinatoricsV1.lean` | `41db1fb606df471df0780284385ef0659f15e3c59ba3b55e269190f5e526d761` |

- **Source location:** `ford_to_bulb_v0_1_20261104/final_source_packet_v0_1/sources/`. The same bytes are on nucleus at `~/skeleton_audit/ff4_final_20261105/src/`.
- **Bytes stay exactly as audited.** All three use LF line endings.
- **Dependencies:** Data imports the library's FF-1 module `FVLTFareyArithmeticCompletionV1`, which is already in `theorems/`. Parameter and Combinatorics import Data. All three also import Mathlib. G1 is excluded.
- **Targets:** the 33 frozen statements (headers `c5b569b1...`) and nothing else. No proof edits, drivers or producer attempt files.

## Writer and safeguards (as for v21–v23)

1. **Single writer:** the Rule 30 tooling session (`local_74e563f3-3a53-456a-8be6-a86287549380`).
2. **Base:** discover the latest version, expected to be v23, and recheck it just before assembly. If another version appears in the meantime, stop. Nothing reserves v24 in advance.
3. **Gates:**
   - runner v3 with an **empty drop list**, and its gate test (`RUNNER_V3_EMPTY_DROP_GATE_TEST_v1.md` `de872490...`) cited in the receipt;
   - 0 CHANGED and 0 DROPPED;
   - the added set must be exactly these three sources plus their build outputs and roots.
4. **Prohibited:** the `_v16tool` resolver, writes into frozen bases, and compute on Neo.
5. **Runner limits:** a bounded runner, as before.
6. **Checks on every host:** a full-library AxiomCheck on nucleus, scout and membrane, with matching reports. The 33 FF-4 targets must show only `propext`, `Classical.choice` and `Quot.sound`.
7. **Freezing:** v24 is frozen read-only on all hosts, with checksums rechecked after freezing. v23 and older versions stay intact.

## Provenance to record

- **Standing:** FF-4 formalizes WORK_ORDER v0.2 (`d28dfd0e...`), the combinatorial side of the Ford-to-bulb map:
  - mechanical words and the unit gap;
  - rotation number p/q;
  - order and mediants;
  - the bulb root and multiplier algebra.

  It adds no kernel item and changes no kernel text.
- **Not claimed:**
  - parameter-ray landing;
  - wakes and limb geometry;
  - analytic dynamics;
  - B6, which is deferred;
  - any Rule 30 claim.
- **Freeze decision:** `5195a4be...` (#1563).
- **Credits:**
  - the fraction-fan/bulb observation and the instruments: saphir;
  - FVLT assembled by Robin Miller; components are classical results of others;
  - the formalization owner for the design review and the C1 route;
  - Codex as producer;
  - skeleton (Claude Opus 5.5) as independent verifier;
  - the fidelity review by an independent verifier subagent (`034639fc...`);
  - no novelty claims.

## Readiness

After the writer's three-host receipt, skeleton checks all three hosts read-only:
- the checksums;
- latest version = v24;
- 0 writable files;
- the three sources byte-identical to the table above;
- the diff against v23 is exactly the three added sources plus the roots and the manifest;
- the 33 named axiom reports recomputed against v24 equal skeleton's final-audit log;
- v23 still verifies.

Only then does skeleton post readiness.
