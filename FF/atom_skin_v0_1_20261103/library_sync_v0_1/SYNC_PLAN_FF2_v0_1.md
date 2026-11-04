# FF-2 library sync plan v0.1: shared theorem library v21

2026-11-04. Skeleton (Claude Opus 5.5), on saphir's "Yes, sync it". This follows saphir's standing rule that each verified Lean delivery goes into the next library version. It follows the FF-1 v20 pattern (`farey_ford_contact_v0_1_20261102/library_sync_v0_1/SYNC_PLAN_DECISION_v0_1.md` `997aad1b...`).

**Basis:** FF-2 final audit PASS, `FF2_FINAL_AUDIT_v0_1.md` `70d6dbf5...`, posted as bus #1506.

## Scope: exactly five sources, unchanged

| Module | SHA-256 (audited) |
|---|---|
| `FVLTAtomSkinDataV1.lean` | `8d165af954019dd15fad6f7bf082922119d9364a3727fa59879d945fc5e8f085` |
| `FVLTAtomSkinCountsV1.lean` | `57be30510d889b8921c3f5b474b9f892570ac19d9f1a556552504498acf8bad0` |
| `FVLTAtomSkinPenV1.lean` | `62be605efe85fcfbded3f0419c124aa2f1f2f0a772669aa81448400ac116cccc` |
| `FVLTPillowcaseDataV1.lean` | `b8a03b38d0e8a8defb68bc93701f9c6ded0a8ff8ce9e9c9f1af636790ce3bcd2` |
| `FVLTPillowcaseV1.lean` | `27e7c00dcae05e2f7e93de3d79e8f56380a553b76c2848f919deb6a3f5d82a3f` |

- **Source location:** `atom_skin_v0_1_20261103/batch07/producer_complete_v0_1/src/`. The same bytes are on nucleus at `~/skeleton_audit/ff2_final_20261104/src/`.
- **Targets:** the 28 frozen statements (headers `b4484f6e...`) and nothing else.
- **Dependencies:** the five modules import only Mathlib and Lean modules plus each other. They do not import FF-1 or Rule 30 modules, and G1 is excluded.
- **Excluded:** no new theorems, no proof edits, no smoke drivers, and no producer attempt folders or evidence files. Only these five `.lean` files are added.

## Writer and safeguards

The safeguards are the FF-1 v20 conditions, unchanged.

1. **Single publication writer:** the Rule 30 tooling session (`local_74e563f3-3a53-456a-8be6-a86287549380`). Neither skeleton nor Codex writes a version.
2. **Base:** discover the latest version, expected to be v20, and recheck it just before assembly. If another version appears in the meantime, stop. Nothing reserves v21 in advance.
3. **Assembler:** an additive, metadata-only assembler successor, with its diff reviewed. The outer runner rejects any CHANGED or DROPPED file, and the added set must be exactly these five sources and their build outputs. Inherited source and kit hashes are compared against v20.
4. **Prohibited:**
   - the `_v16tool` resolver;
   - writes into frozen bases or through links;
   - compute on Neo.
5. **Runner limits:** a bounded runner with its limits stated. Use the FF-2 template limits where applicable: one CPU, 8 GiB, `-j1 -s65536 -M7680`.
6. **Checks on every host:** a full-library AxiomCheck on **nucleus, scout and membrane**, with matching reports. The 28 FF-2 targets must show only `propext`, `Classical.choice` and `Quot.sound`.
7. **Freezing:** v21 is frozen read-only on every host, with 0 writable files and checksums rechecked after freezing. v20 and all older versions stay intact.
8. **Membrane:** v21 is added alongside the existing versions. Verify its Tailscale address ([ts-redact-4]) before use.

## Provenance to record in v21

- **Standing:** FF-2 is an instrument-tier formalization of WORK_ORDER_v0_3 (`8e108ff4...`). It adds no kernel-native item and changes no kernel text.
- **Scope limits:**
  - exact combinatorial certificates and numerical invariants only;
  - no surface realization;
  - nothing about pen behaviour under arbitrary signs, and no Rule 30 periodicity;
  - no viewer certification.
- **Accepted definition repair:** `a1ea047d...`, recorded in bus #1458.
- **Credits:**
  - FVLT assembled by Robin Miller; components are classical results of others;
  - Codex as producer;
  - skeleton (Claude Opus 5.5) as independent verifier;
  - the fidelity review by an independent verifier subagent (`FIDELITY_SIGNOFF_v0_1.json` `63831157...`);
  - no novelty claims for classical results.

## Readiness

After the writer's three-host receipt, skeleton checks all three hosts read-only:
- `sha256sum -c`;
- latest version = v21;
- `find v21 -writable` = 0;
- the five sources byte-identical to the table above;
- the 28 named axiom reports recomputed against v21's built library, from a copy in `/tmp` with nothing written into v21, and equal on all hosts;
- v20 still verifies.

Only then does skeleton post a readiness receipt. Readiness is never declared on the first successful host alone.

**Not covered:** kernel adoption, a lock, release, commits, viewer changes or FF-3.
