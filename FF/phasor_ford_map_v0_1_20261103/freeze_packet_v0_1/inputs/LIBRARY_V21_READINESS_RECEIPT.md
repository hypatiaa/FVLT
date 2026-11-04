# Shared theorem library v21: readiness receipt (FF-2)

2026-11-04. Skeleton (Claude Opus 5.5). I checked all three hosts independently after receiving the single publication writer's receipt, a cross-session message from the Rule 30 tooling session. Authority: saphir's "Yes, sync it" and the plan `SYNC_PLAN_FF2_v0_1.md` (`34367b35...`).

**Method.** My own script, `skeleton_v21_check.sh`, ran read-only over Tailscale on nucleus 100.105.106.41, scout 100.113.13.47 and membrane 100.98.98.121. It writes only under `/tmp`. The named axiom report was recomputed from my own final-audit file `SkeletonAuditFF2.lean` (`2ec4a335...`). It was compiled against v21's built library from a `/tmp` copy, using the pinned Lean (`bf8d54e4...`) with `-j1 -s65536 -M7680` under 8 GiB.

| Check | nucleus | scout | membrane |
|---|---|---|---|
| Latest version | v21 | v21 | v21 |
| `v21/SHA256SUMS` | `648ac325...` | `648ac325...` | `648ac325...` |
| `v21/LIBRARY_MANIFEST.json` | `799b3baa...` | `799b3baa...` | `799b3baa...` |
| `v21/lake-manifest.json` (same as v20) | `1f0e0c1c...` | `1f0e0c1c...` | `1f0e0c1c...` |
| Entries; `sha256sum -c` failures | 397; 0 | 397; 0 | 397; 0 |
| `find v21 -writable` (before and after the check) | 0; 0 | 0; 0 | 0; 0 |
| Symlinks in v21 | 1 | 1 | 1 |
| Five FF-2 sources (`theorems/`) vs the audited hashes | 5/5 identical | 5/5 | 5/5 |
| 28-target axiom report, recomputed | exit 0, 28 lines, `37e9ba24...` | same | same |
| v20 afterwards | `a2933a5c...`, 0 failures, 0 writable | same | same |

- **Axiom report.** It is byte-identical on all three hosts and to my final-audit log (`37e9ba24...`, `FF2_FINAL_AUDIT_v0_1.md`):
  - 23 targets use `propext`, `Classical.choice` and `Quot.sound`;
  - 5 pillowcase targets use `propext` and `Quot.sound` only;
  - no `sorryAx`.
- **From the writer's receipt; I did not rerun these:**
  - the full-library AxiomCheck, AXIOMS_OK with 107 modules and 4532 constants, identical on all three hosts (`51baf057...`);
  - the gates: 0 CHANGED or DROPPED, the added set exactly the five, and inherited hashes 388/388.
- **Deviation recorded.** The library's per-process Lean flags stay at the lakefile's `-M8192`, unchanged since v1, rather than the template's `-M7680`. Changing them would have been a non-metadata assembler change. Each build ran under a hard cgroup ceiling of 8 GiB with one CPU. I accept this; it affects only build limits, not content.

**Verdict: READY.** Shared library **v21** on nucleus, scout and membrane contains FF-2:
- 28 statements, VERIFIED (final audit #1506) and FIDELITY-REVIEWED (28/28 MATCH);
- built and axiom-checked on every host;
- frozen read-only, with v20 and older versions intact.

Seats may build on v21.

This is library inclusion only. It is not kernel adoption, a lock, an installation or a release, and no kernel text changes. FF-2 is instrument-tier under WORK_ORDER_v0_3 (`8e108ff4...`). The scope limits stand: no surface realization, no arbitrary-sign or Rule 30 periodicity claim, and no viewer certification.

Credit: the framework was assembled by Robin Miller; its components are classical results of others.
