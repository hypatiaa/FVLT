# Shared theorem library v23: readiness receipt (FF-3)

2026-11-04. Skeleton (Claude Opus 5.5). I checked all three hosts independently after receiving the single writer's receipt from the Rule 30 tooling session. Authority: saphir's standing sync rule; the plan is `SYNC_PLAN_FF3_v0_1.md` (`ae9cd99e...`) and the basis is FF-3 final PASS #1554.

**Method.** My own read-only script, `skeleton_v23_check.sh`, ran over Tailscale on nucleus, scout and membrane, writing only under `/tmp`. The axiom report was recomputed from my own final-audit file `SkeletonAuditFF3.lean` (`89d0fb2d...`), which names the 37 targets and the 19 data declarations. It was compiled against v23's built library with the pinned Lean, `-j1 -s65536 -M7680` and 8 GiB.

| Check | nucleus | scout | membrane |
|---|---|---|---|
| Latest version | v23 | v23 | v23 |
| `v23/SHA256SUMS` | `394e72c5...` | same | same |
| `v23/LIBRARY_MANIFEST.json` | `3b8ea550...` | same | same |
| `v23/lake-manifest.json` (same as v22) | `1f0e0c1c...` | same | same |
| Entries; `sha256sum -c` failures; writable (before and after) | 401; 0; 0 / 0 | same | same |
| Diff against v22 | added: the 5 `theorems/FVLTRosetteFord*V1.lean`; changed: `lakefile.toml` and `LIBRARY_MANIFEST.json`; nothing removed | same | same |
| Five sources against the audited hashes | `02814fa1`, `2a48f1c6`, `f74e1a1d`, `1d982d2e`, `53ea5f08`: 5/5 | same | same |
| 56-line axiom report recomputed against v23 | exit 0, `5a4ff70c...` | same | same |
| v22 afterwards | 0 check failures, 0 writable | same | same |

- **Axiom report.** It is byte-identical on all three hosts and to skeleton's final-audit log `logs/axioms.log` (`5a4ff70c...`): all 37 targets and 19 data declarations use only `propext`, `Classical.choice` and `Quot.sound`.
- **From the writer's receipt; I did not rerun these:**
  - the full-library AxiomCheck, AXIOMS_OK with 126 modules and 5076 constants, identical on all hosts, with the 121 v22 module lines unchanged;
  - the gates: 0 CHANGED or DROPPED, inherited 392/392, and the kit gate at 271;
  - the empty-drop gate test `de872490...`, which was cited.
- **Disclosed by the writer.** Its first check that the v22 module lines were unchanged compared empty sets, because a timing-line filter also matched "constants, ". It redid the check with an exact pattern. This does not affect my checks.

**Verdict: READY.** Shared library **v23** on nucleus, scout and membrane contains FF-3:
- 37 statements, VERIFIED (final audit #1554) and FIDELITY-REVIEWED (37/37 MATCH);
- built and axiom-checked on every host;
- frozen read-only, with v22 and older versions intact.

Seats may build on v23. This is library inclusion only: not kernel adoption, a lock or a release, and no kernel text changes. FF-3's scope limits stand: no arcs, no phasor inversion, no register identification, no viewer certification.

Credit: the question of the map, the rosette and the instruments: saphir. "The framework was assembled by Robin Miller; its components are classical results of others."
