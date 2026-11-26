# FVLT v3.4.1 (successor of the locked v3.4.0)

**Status: v3.4.1, LOCKED release of record**, saphir 2026-11-04: "v3.4.1, lock it". The label ("I like the point release label") and the adoption ("I approve") were given the same day. Records are in `docs/releases/v3.4.1/`.

- **Base:** `kernel/post-v3.3.1/kernel.md`, v3.4.0 LOCKED, `0d6beee2…`. It is unchanged.
- **Plan:** `CORRECTIONS.json`, 6 replacements: `FF3-FORD-9.4-ROW` (the §9.4 Ford-circles row plus an untagged note, PR #76) and five release-metadata units.
- **Builder:** `tools/build_successor_kernel_v2.py`, run as `python tools/build_successor_kernel_v2.py --folder kernel/post-v3.4.0 --check`.
- **Kernel:** `kernel.md`, `7d46a830…` (locked; the candidate was `90134be9…`). All 187 native identities are kept, with no additions and no tag or status changes.
