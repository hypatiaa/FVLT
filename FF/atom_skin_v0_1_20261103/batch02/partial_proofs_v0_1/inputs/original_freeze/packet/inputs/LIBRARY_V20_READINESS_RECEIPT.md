# Shared theorem library v20: readiness receipt (FF-1 Stage A)

2026-11-03. Skeleton seat (Claude Opus 5.5). Independent three-host check after the single publication writer's receipt (the Rule 30 tooling session, cross-session message), under saphir's sync authorization (#1436) and the accepted plan (#1444).

**Skeleton's own checks, run over Tailscale (nucleus 100.105.106.41, scout 100.113.13.47, membrane 100.98.98.121), read-only:**

| Check | nucleus | scout | membrane |
|---|---|---|---|
| Latest version | v20 | v20 | v20 |
| `v20/SHA256SUMS` | `a2933a5c…` | `a2933a5c…` | `a2933a5c…` |
| `v20/LIBRARY_MANIFEST.json` | `4e318f9b…` | `4e318f9b…` | `4e318f9b…` |
| `v20/lake-manifest.json` (= v19's) | `1f0e0c1c…` | `1f0e0c1c…` | `1f0e0c1c…` |
| `sha256sum -c SHA256SUMS` | exit 0, 392 OK, 0 not OK | same | same |
| `find v20 -writable` | 0 | 0 | 0 |
| Symlinks in v20 | 1, internal (`.lake/packages/batteries/docs/README.md -> ../README.md`) | same | same |
| Eleven FF-1 sources vs the audited hashes | 11/11 byte-identical | 11/11 | 11/11 |
| Entry point re-elaborated against v20's built library (copy in `/tmp`, nothing written into v20) | exit 0, 0 errors | same | same |
| 72 FF-1 axiom reports | 67 full standard, 3 `propext`, 1 `propext`+`Quot.sound`, 1 none | identical | identical |
| v19 afterwards | `sha256sum -c` OK, 0 writable | same | same |

The 72-name axiom distribution equals skeleton's integration audit (`INTEGRATION_AUDIT_v0_1.md` `3ae4aff5…`). The writer's full-library AxiomCheck (102 modules, 4118 constants, AXIOMS_OK, identical on all three hosts) and its zero CHANGED/DROPPED gate are recorded in the writer's receipt; skeleton did not re-run the full-library scan.

**Verdict: READY.** Shared library **v20** on nucleus, scout and membrane contains FF-1 Stage A: 60 targets and 12 bridge links, VERIFIED and FIDELITY-REVIEWED, built and axiom-checked on every host, frozen read-only, with all prior versions intact. Seats may build on v20.

This is library inclusion only. It is not kernel adoption, a lock, installation or a release; no kernel text changes. FF-1's historical semantic reference stays kernel v3.3.1, and its II.5 text is byte-identical in v3.4.0.
