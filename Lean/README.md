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
