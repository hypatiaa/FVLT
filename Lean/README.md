# FVLT Lean modules: cloud backup

This folder is a private backup of the 84 FVLT Lean modules, copied byte for byte from the frozen theorem library **v21** on nucleus (`~/rule30_theorem_library/v21/theorems/FVLT*.lean`) on 2026-11-04.

- **Pins of the source version:**
  - v21 `SHA256SUMS`: `648ac325c5df362b0a034dab3ee1e0bd495982d33f0ead433293168ba6c269cc`
  - `LIBRARY_MANIFEST.json`: `799b3baa0b61f227d626c36016ebda8180645abf92127f331fdd23a2d2779a81`
  - `lake-manifest.json`: `1f0e0c1c0a06e2a9ecc117aed82f7a8ee62b418235e10686d3bda2d6986ea527`
  - Lean `v4.35.0`, Mathlib `56a005855ea17e0b0958f73ec801ae140b0a1679`
- **Check:** `MANIFEST.sha256` lists the 84 lines of v21's `SHA256SUMS` for these files. In this folder, `sha256sum -c MANIFEST.sha256` must report 84 OK. `.gitattributes` turns off line-ending conversion, so the files stay byte-identical.

## What this folder is not

- **It is not a buildable project.** There is no lakefile. The full library is the record, with a build and axiom check on nucleus, scout and membrane.
- **It is not every module.** 52 of the modules need only Mathlib and each other. The other 32 also import modules from the Wolfram Rule 30 Prize kit (WolframInstitute/Rule30PrizeKit, commit `7d665044`), or our own `Ruliology.*` files kept in the library. Neither of those is copied here.
- **It is not a full backup.** The full backup of every version, with the kit copies, manifests, tools and logs, is meant for a local drive, not this repository.

Credit: saphir (@saphirbijoux), with the authoring model seats recorded in the library's `LIBRARY_MANIFEST.json`.

## Update 2026-11-04: library v23 (FF-3)

The v21 backup above is unchanged, and `MANIFEST.sha256` still pins it. This update adds the five FF-3 modules from frozen library **v23** (`FVLTRosetteFord{Arithmetic,Data,Endpoints,Phase,Sweep}V1.lean`). The 84 v21 files are byte-identical in v23, so nothing else changed.

- v23 `SHA256SUMS`: `394e72c5ce5010349779fd41b1490c4672f160f72aa779b732df272086317903`
- `MANIFEST_v23.sha256`: the 89 v23 entries for `theorems/FVLT*.lean`; `sha256sum -c MANIFEST_v23.sha256` must report 89 OK.
- FF-2's modules (`FVLTAtomSkin*`, `FVLTPillowcase*`) were already in v21. The FF-2 and FF-3 working records are in `../FF/`.

## Update 2026-11-04: library v24 (FF-4)

The v21 and v23 sections above are unchanged, and `MANIFEST.sha256` and `MANIFEST_v23.sha256` still pin them. This update adds the three FF-4 modules from frozen library **v24** (`FVLTFordBulb{Data,Parameter,Combinatorics}V1.lean`). The 89 v23 files are byte-identical in v24.

- v24 `SHA256SUMS`: `74e30ce658ac1367b144318716272d830fece449166357ee110f51bd2dcf94cb` (404 entries)
- `MANIFEST_v24.sha256`: the 92 v24 entries for `theorems/FVLT*.lean`; `sha256sum -c MANIFEST_v24.sha256` must report 92 OK.
- The FF-4 working records are in `../FF/ford_to_bulb_v0_1_20261104/`.
