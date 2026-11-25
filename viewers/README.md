# FVLT viewers: cloud backup

Private backup, made on 2026-11-25 at saphir's request, of two viewer packages from `s6_atom` on Neo, copied byte for byte. Neither is a finished release.

| Folder | What it is | Key pin (SHA-256) | Status |
|---|---|---|---|
| `monodromy/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/` | The monodromy instrument: merged viewer with every candidate panel (B/C/D, RH margin, arithmetic Fourier), `monodromy-31-linked-reduction.html` and its local server | viewer `b4cee4e3…b8e248`; package `MANIFEST.sha256` `65cbb313…39ae` | the host the new viewer is rebuilt from |
| `monodromy/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_1_FASTSTART_20261018/` | Fast-start launcher for the package above (skips the predecessor integrity chain; still checks the viewer pin) | `MANIFEST.sha256` in folder | additive, parent unchanged |
| `monodromy/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_2_NOCHECK_20261125/` | **Use this one.** Same viewer with the startup integrity check removed from `server.cjs`; it starts in about 0.1 s and keeps the viewer pin check. See its `README_NOCHECK.md`. Start it with `monodromy/START_MERGED_VIEWER_NOCHECK.cmd` or `node server.cjs` | viewer `b4cee4e3…b8e248` (unchanged); `server.cjs` `bcf9215f…40c3` | added 2026-11-25; start and page fetch tested, tampered page refused |
| `fourier_viewer/FOURIER_VIEWER_PROTOTYPE_v0_4_19_20261031/` | The new Fourier viewer (comb-hopf: Fourier / Clifford / Hopf / Panels), latest build, source + `dist/comb-hopf.html` | `dist/comb-hopf.html` `08eb1f1d…a3d2` | unfinished: panels still being rebuilt one at a time |
| `fourier_viewer/FOURIER_VIEWER_PROTOTYPE_v0_4_19_20261031_VERIFY/` | Independent verify of v0.4.19 | — | PASS WITH FLAGS (main flag: D1 at per_j ≥ 1024 draws one solid region at q = 1, 2) |

**How to run.**
- Fourier viewer: open `fourier_viewer/FOURIER_VIEWER_PROTOTYPE_v0_4_19_20261031/dist/comb-hopf.html` in a browser (static, offline).
- Monodromy: double-click `monodromy/START_MERGED_VIEWER_NOCHECK.cmd`, or run `node server.cjs` in the NOCHECK folder (Node required). The older route is `node start-fast.cjs` in the FASTSTART folder (Node required). Note that the launcher expects the parent at `../MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004`, which this layout keeps. The full integrity check (`check-integrity.cjs`) needs the whole older predecessor chain in `s6_atom/cold audit fourier/`, which is not copied here.

**BSD Tate verifier (the viewer's `/assess` replay).** Added 2026-11-25. The viewer replays every packet through `assess-stdin.cjs`, which loads `../BSD_TATE_T4_v0_1_20260923/assess.cjs`.
- **What was copied:** the five folders that chain needs at run time sit beside the viewer in `monodromy/`, whole and byte for byte, each with its own `MANIFEST.sha256`:
  - `BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907`
  - `BSD_TATE_T1_v0_1_20260907`
  - `BSD_TATE_T2_v0_1_20260907`
  - `BSD_TATE_T3_v0_1_20260907`
  - `BSD_TATE_T4_v0_1_20260923`

  Their build, audit and sealed-verification reports are in `monodromy/bsd_tate_audit_reports/`.
- **Python (once per machine):** the structure gate (`validate.py`) needs Python 3.9 or newer with `jsonschema` 4.26.0. Double-click `monodromy/SETUP_BSD_TATE_PYTHON.cmd`. It creates `monodromy/.bsd-audit-venv`, which the verifier finds by itself; that folder is git-ignored. Alternatively, set `BSD_AUDIT_PYTHON` to any Python that has jsonschema.
- **PARI is not needed:** the PARI WASM runtime is only used when packets are built, not when they are replayed.
- **Tested from this layout on Neo:** all 44 T4 fixture packets replayed through `assess-stdin.cjs` and matched their expected assessments (42 PASS, 2 UNAVAILABLE). Two of them also went through the NOCHECK server's HTTP `/assess`; the signed replies carried the expected assessments.

**Check.** In this folder, run `sha256sum -c MANIFEST.sha256`; it must report every line OK. `.gitattributes` turns off line-ending conversion.

Credit: saphir (@saphirbijoux), with the model seats named in each folder's records.
