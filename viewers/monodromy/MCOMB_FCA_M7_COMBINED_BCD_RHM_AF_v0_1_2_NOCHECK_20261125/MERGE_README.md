# Combined viewer: G. Robin margin + arithmetic–Fourier on combined B/C/D (merge candidate)

Package `MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004`, built in Stage 1 run `20261004T122523Z` (`COMBINED_VIEWER_MERGE_S1_20261004T122523Z/`).

**Standing: unsealed merge candidate** (`UNSEALED_MERGE_CANDIDATE`). Nothing here is accepted, verified, sealed or published by being built. Sealing waits for RZ1, which joins later as a separately reviewed successor.

## Merge

- Governing handoff: `COMBINED_VIEWER_MERGE_HANDOFF_v0_1_8_20261004/` (MANIFEST `af2305b4dcb234b8cf91d4e7422a1d06c3d30a8097b4a26e37220b862c02cf0a`), with its review `COMBINED_VIEWER_MERGE_HANDOFF_V018_SOL_REVIEW_20261004/` (MANIFEST `0152e79a46f7aba61f5f2048d91d974c26f43dc05fea50f0a216b7f12bf75673`).
- Baseline: the accepted combined B/C/D package `MCOMB_FCA_M7_COMBINED_BCD_v0_1_20261001` (MANIFEST `3f4f12d0b13159092ad18db585aa52311af58a3de057114d07ffa343bab36cc4`, viewer `3cd1352f0b5846fb22f673dffae627f1191a00601c611128bb661224a7d1da9c`), accepted in `COMBINED_BCD_ASTRA_INTEGRATION_AUDIT_20261001/` (MANIFEST `86a374b91b6578845cbf2cf593fe95c307ab10fa2ec146641541bb3d253c235b`).
- G. Robin margin panel: from the accepted sibling `MCOMB_FCA_M7_COMBINED_BCD_RH_MARGIN_v0_1_20261001` (MANIFEST `3f562965306039d56fedba77819076f3c47ba0be9488e7236330cabd4fbe2ef1`). Audit: `RH_MARGIN_ASTRA_AUDIT_20261001/` (MANIFEST `84d9c8f05f268516e2f7e6c1dd578c4656700e7cfbe87071f6b4785f50f48a69`).
- Arithmetic–Fourier panel: from the accepted sibling `MCOMB_FCA_M7_COMBINED_BCD_AF_v0_1_20261001` (MANIFEST `84654fee39b2633ee53823113f9d4f8373480a0af19090b34ddffbd242a9b6da`). Audit: `ARITHMETIC_FOURIER_ASTRA_FINAL_AUDIT_20261002/` (MANIFEST `df2a9475df58c5dd908101aff8d0fe5e6c3bfea46cd2761f29187e36bca7b5a5`).
- Viewer `monodromy-31-linked-reduction.html`: the baseline viewer plus two blocks immediately before `</body>`, the G. Robin block first and the arithmetic–Fourier block second (MD-1 (a): the page shows `rr-panel`, `afp-panel`, `rhm-panel`). Each block equals its sibling's insertion except its pins line, which carries the host identity re-derived for this package (MD-2 option R: only the identity's `build` differs from the accepted sibling identity).
- `BUILD_PINS.json`: the baseline pins with `viewerSha256` set to this viewer, then the sections `rhMargin`, `arithmeticFourier` and `mergeRhmAf`.
- Every other baseline file is byte-identical to the baseline; the nine sibling files are byte-identical to their sibling packages; this README is the one new file.

## Timing wording

Any citation of G. Robin worker timings must be accompanied by `RH_MARGIN_ASTRA_AUDIT_20261001/TIMING_CLARIFICATION.md` (sha256 `13c69e0529abfd264ede0d8c349ed61905efc87d80e07d3c7140356d1d3e348a`): those timings are historical development measurements only.

## Sibling READMEs

`RH_MARGIN_README.md` and `ARITHMETIC_FOURIER_README.md` are carried byte for byte. They describe their sibling packages (`MCOMB_FCA_M7_COMBINED_BCD_RH_MARGIN_v0_1_20261001` and `MCOMB_FCA_M7_COMBINED_BCD_AF_v0_1_20261001`), not this merged package.

## Credits

Idea and merge decision: saphir. Reviews: Astra and Sol. Drafting and oversight: Claude (the handoff drafter and the oversight seat). Build and checks: the builder (Claude).
