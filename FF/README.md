# FF-2 and FF-3 formalization records: cloud backup

This is a private backup, made on 2026-11-04, of the two FVLT formalization working folders. The source is `s6_atom/FVLT_FORMALIZATION_v0_1_20261028/` on Neo, copied byte for byte.

| Folder | Project | Final audit | Library |
|---|---|---|---|
| `atom_skin_v0_1_20261103/` | FF-2: atom skin pen and pillowcase, 28/28 statements | `FF2_FINAL_AUDIT_v0_1.md` `70d6dbf5…`, bus #1506 PASS | modules in v21 (bus #1508) |
| `phasor_ford_map_v0_1_20261103/` | FF-3: rosette address to Ford circle map, 37/37 statements | `FF3_FINAL_AUDIT_v0_1.md` `cf9f59c9…`, bus #1554 PASS | modules in v23 (bus #1556) |

- **What's in them:** statements, Lean sources, build and replay logs, receipts, freeze packets and review records. There are 2,084 files and no `.lake` build folders.
- **Check:** in this folder, run `sha256sum -c MANIFEST.sha256`; it must report 2,084 OK. `.gitattributes` turns off line-ending conversion.
- The verified modules themselves are in `../Lean/theorems/`, and `../Lean/MANIFEST_v23.sha256` pins them.

Credit: saphir (@saphirbijoux), with the model seats named in each folder's records.

## Update 2026-11-04: FF-4

| Folder | Project | Final audit | Library |
|---|---|---|---|
| `ford_to_bulb_v0_1_20261104/` | FF-4: Ford circle to Mandelbrot bulb, combinatorial skeleton, 33/33 statements | `FF4_FINAL_AUDIT_v0_1.md` `01e5e0ed…`, bus #1611 PASS | modules in v24; readiness `library_sync_v0_1/LIBRARY_V24_READINESS_RECEIPT.md` `ef90d59f…` (bus #1614) |

- **Check:** in this folder, run `sha256sum -c MANIFEST_ff4.sha256`; it must report 618 OK. `MANIFEST.sha256` still covers FF-2 and FF-3.
- The folder includes three build `.olean` files, copied byte for byte from the working folder.
- **Date note:** some headers in this folder (the audit, the sync plan, `BUS_RECEIPT_1611`) say 2026-11-05. The true date is 2026-11-04; see `DATE_CORRECTION_v0_1.md`. The bytes are kept as they are.

## Update 2026-11-04: FF-1

| Folder | Project | Library |
|---|---|---|
| `farey_ford_contact_v0_1_20261102/` | FF-1: Farey contact and Ford geometry, Stage A plus completions R1–R5 | modules entered library v20 (bus #1445) and are in `../Lean/theorems/` from the v21 backup on |

- **Modules:** `FVLTFareyContactV1`, `FVLTFordGeometryV1`, `FVLTFareyCertificatesV1`, `FVLTFordRationalV1`, `FVLTFordExactCoordinatesV1`, `FVLTFareyArithmeticCompletionV1`, `FVLTFordGeometryCompletionV1`, `FVLTUnitFractionSpineV1`, `FVLTPhasePartnersV1` and `FVLTFareyFixturesCompletionV1`. `../Lean/MANIFEST.sha256` pins them.
- **Check:** in this folder, run `sha256sum -c MANIFEST_ff1.sha256`; it must report 1,119 OK.
- **G1:** none. The folder mentions G1 only as an exclusion. Its replay tool refuses any import whose name contains "g1", and no G1 files are included.
