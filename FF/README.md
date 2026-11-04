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
