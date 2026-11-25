# Merged viewer v0.1.1 FASTSTART (2026-10-18)

**What it is.** An additive successor of `MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004` (the merged viewer with every candidate panel) that starts the parent's own server without the startup inventory check. Requested by saphir on 2026-10-18, for time saving while the viewer is being redone. Built by Claude Fable 5.1 (skeleton seat).

**What it does not do.** It does not touch the parent package (its `MANIFEST.sha256` `65cbb313…39ae` and every file stay byte-identical), does not change the viewer, and does not change the server's behaviour once running (localhost assessment endpoint, token, caps, random port, 127.0.0.1 only).

**How to run.**

- Double-click `START_MERGED_VIEWER_FAST.cmd` in the `s6_atom` root (beside the original `START_MERGED_VIEWER.cmd`), or
- `node start-fast.cjs` in this folder.

It prints one line, `Merged viewer v0.1.1 FASTSTART … http://127.0.0.1:<port>/`, and serves until Ctrl-C. The port is chosen by the parent server at random on each start, as before.

**What is skipped and what is kept.** The parent's `start()` has an option `skipIntegrity`. Without it, startup runs `../BSD_TATE_T4_v0_1_20260923/check-integrity.cjs` and the package's own `check-integrity.cjs`; the T4 check in turn requires the T3 check, and so on down the predecessor chain, each inventorying and hashing its whole package and comparing to checksum baselines. On 2026-10-18 that chain was still running after two minutes of CPU. This launcher passes `skipIntegrity: true`, so that chain is skipped. Kept: `start()` still reads `BUILD_PINS.json` and refuses to serve if `monodromy-31-linked-reduction.html` does not hash to `viewerSha256`; and this launcher itself checks three parent files against the pins below before calling `start()`.

**Parent pins (SHA-256, read from disk 2026-10-18).**

| File in parent | SHA-256 |
|---|---|
| `server.cjs` | `20caf5398cef57f988700adc27c8cdbe49dbe538d7e570ebfa482926d8424311` |
| `BUILD_PINS.json` | `5bafe8bb6353658c49da47ade393d22e8b197680fc6e1b70b136728105fe9341` |
| `monodromy-31-linked-reduction.html` (`viewerSha256`) | `b4cee4e30a753eda7c62f72e8043d6d5c9b3f69c3c2e1dd0da9a3f9ab5b8e248` |
| `check-integrity.cjs` (not run by this launcher) | `bcc8c562a4890aa081cc2f14d47a733b844edd0c76e0b921832a93454b402cc6` |
| `MANIFEST.sha256` | `65cbb313df2b0ee2e2dd162a34a925ed50fc9980056c737ee57460e73a3339ae` |

**Standing.** Unsealed; local use allowed (saphir, 2026-10-07). This folder's own `MANIFEST.sha256` pins its three files. Phones: this is still the node server path, which does not run on phones; the static pages remain the phone route.
