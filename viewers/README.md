# FVLT viewers: cloud backup

Private backup, made on 2026-11-25 at saphir's request, of two viewer packages from `s6_atom` on Neo, copied byte for byte. Neither is a finished release.

| Folder | What it is | Key pin (SHA-256) | Status |
|---|---|---|---|
| `monodromy/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/` | The monodromy instrument: merged viewer with every candidate panel (B/C/D, RH margin, arithmetic Fourier), `monodromy-31-linked-reduction.html` and its local server | viewer `b4cee4e3…b8e248`; package `MANIFEST.sha256` `65cbb313…39ae` | the host the new viewer is rebuilt from |
| `monodromy/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_1_FASTSTART_20261018/` | Fast-start launcher for the package above (skips the predecessor integrity chain; still checks the viewer pin) | `MANIFEST.sha256` in folder | additive, parent unchanged |
| `fourier_viewer/FOURIER_VIEWER_PROTOTYPE_v0_4_19_20261031/` | The new Fourier viewer (comb-hopf: Fourier / Clifford / Hopf / Panels), latest build, source + `dist/comb-hopf.html` | `dist/comb-hopf.html` `08eb1f1d…a3d2` | unfinished: panels still being rebuilt one at a time |
| `fourier_viewer/FOURIER_VIEWER_PROTOTYPE_v0_4_19_20261031_VERIFY/` | Independent verify of v0.4.19 | — | PASS WITH FLAGS (main flag: D1 at per_j ≥ 1024 draws one solid region at q = 1, 2) |

**How to run.**
- Fourier viewer: open `fourier_viewer/FOURIER_VIEWER_PROTOTYPE_v0_4_19_20261031/dist/comb-hopf.html` in a browser (static, offline).
- Monodromy: `node start-fast.cjs` in the FASTSTART folder (Node required). Note that the launcher expects the parent at `../MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004`, which this layout keeps. The full integrity check (`check-integrity.cjs`) needs the predecessor chain in `s6_atom/cold audit fourier/`, which is not copied here.

**Check.** In this folder, run `sha256sum -c MANIFEST.sha256`; it must report 1,123 OK. `.gitattributes` turns off line-ending conversion.

Credit: saphir (@saphirbijoux), with the model seats named in each folder's records.
