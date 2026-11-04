# FF-3 library sync plan v0.1: shared theorem library v23

2026-11-04. Skeleton (Claude Opus 5.5). This follows saphir's standing rule that each verified Lean delivery goes into the next library version. It uses the same pattern as FF-2's v21 sync (`atom_skin_v0_1_20261103/library_sync_v0_1/SYNC_PLAN_FF2_v0_1.md`).

**Basis:** FF-3 final audit PASS, `FF3_FINAL_AUDIT_v0_1.md` `cf9f59c9...`, posted as bus #1554.

## Scope: exactly five sources, unchanged

| Module | SHA-256 (audited) |
|---|---|
| `FVLTRosetteFordDataV1.lean` | `02814fa15dfdafc3551d63943baedf57655f6b671c618895ca8dd8f490809388` |
| `FVLTRosetteFordPhaseV1.lean` | `2a48f1c65b7a5a31cbeaecac2edf13f2a64fec583e2d70af6473f06a41917459` |
| `FVLTRosetteFordArithmeticV1.lean` | `f74e1a1d8f02a60beceb6a1a44a7e5833b2583777f74cd4e36ebed459b67726f` |
| `FVLTRosetteFordSweepV1.lean` | `1d982d2ee145511e2b4a55a72675b14e53b1df2cb94c872abb5baaf3a0697e23` |
| `FVLTRosetteFordEndpointsV1.lean` | `53ea5f08a71001be2bb6b4ba7de3932740f7861711058c7bb6ae4890cadde9e0` |

- **Source location:** `phasor_ford_map_v0_1_20261103/final_source_packet_v0_1/sources/`. The same bytes are on nucleus at `~/skeleton_audit/ff3_final_20261104/src/`.
- **Bytes stay exactly as audited.** Phase and Endpoints use CRLF line endings; keep them. Do not normalize line endings.
- **Dependencies:** the modules import the library's FF-1 modules (`FVLTFareyArithmeticCompletionV1` and `FVLTFordExactCoordinatesV1`, which are already in `theorems/`), each other, and Mathlib. G1 is excluded.
- **Targets:** the 37 frozen statements (headers `b8a052dc...`) and nothing else. No proof edits, drivers or producer attempt files.

## Writer and safeguards (as for v21/v22)

1. **Single writer:** the Rule 30 tooling session (`local_74e563f3-3a53-456a-8be6-a86287549380`).
2. **Base:** discover the latest version, expected to be v22, and recheck it just before assembly. If another version appears in the meantime, stop. Nothing reserves v23 in advance.
3. **Gates:**
   - use runner v3 with an **empty drop list**;
   - its inherited-hash gate on that path was tested and fails correctly (`RUNNER_V3_EMPTY_DROP_GATE_TEST_v1.md` `de872490...`). Cite it in the receipt;
   - 0 CHANGED and 0 DROPPED;
   - the added set must be exactly these five plus their build outputs and roots.
4. **Prohibited:** the `_v16tool` resolver, writes into frozen bases, and compute on Neo.
5. **Runner limits:** a bounded runner, as before.
6. **Checks on every host:** a full-library AxiomCheck on nucleus, scout and membrane, with matching reports. The 37 FF-3 targets must show only `propext`, `Classical.choice` and `Quot.sound`.
7. **Freezing:** v23 is frozen read-only on all hosts, with checksums rechecked after freezing. v22 and older versions stay intact.

## Provenance to record

- **Standing:** FF-3 formalizes WORK_ORDER v0.2 (`5b41c955...`), a discrete map on lifted data from rosette addresses to Ford circles with exact endpoint certificates. It adds no kernel item and changes no kernel text.
- **Not claimed:**
  - arcs;
  - recovering an address from an unlabelled phasor;
  - any register identification;
  - viewer work.
- **Accepted repair:** `02814fa1...`, recorded in bus #1517.
- **Rebinding:** to v22, recorded in bus #1513.
- **Lemma 6a:** not assumed.
- **Credits:**
  - the question of the map, the rosette and the instruments: saphir;
  - FVLT assembled by Robin Miller; components are classical results of others;
  - Codex as producer;
  - skeleton (Claude Opus 5.5) as independent verifier;
  - the fidelity review by an independent verifier subagent (`abbf810a...`);
  - no novelty claims.

## Readiness

After the writer's three-host receipt, skeleton checks all three hosts read-only:
- the checksums;
- latest version = v23;
- 0 writable files;
- the five sources byte-identical to the table above;
- the diff against v22 is exactly the five added sources plus the roots and the manifest;
- the 37 named axiom reports recomputed against v23 equal skeleton's final-audit log;
- v22 still verifies.

Only then does skeleton post readiness.
