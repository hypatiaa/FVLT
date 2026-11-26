# FVLT v3.4.1: release lock

**Locked by saphir on 2026-11-04.** The lock word, verbatim:

> v3.4.1, lock it

**Earlier the same day,** saphir assigned the label ("I like the point release label", for the proposed v3.4.1) and adopted the correction ("I approve", candidate v0.3 of `FF3-FORD-9.4-ROW`, PR #76).

v3.4.1 is a point release on the locked v3.4.0. It becomes the release of record, and v3.4.0 is superseded. The v3.4.0 bytes and their records are unchanged and stay as history. `RELEASE_CANDIDATE.md` is kept as the record of what was reviewed.

## Locked artifacts

| Artifact | SHA-256 |
|---|---|
| `kernel/post-v3.4.0/kernel.md`, v3.4.1 LOCKED (187 native tags) | `7d46a830eb144cd3ad61e5f2842629e35432a68e56a2351aabe54ab698e157ce` |
| The release candidate it locks (PR #77 head `74d4ce1`) | `90134be97be012da8a0ea0f5b48338a6a863166f36fbf0781f6822ef37886b39` |
| The reviewed body without release metadata (PR #76: v3.4.0 with v0.3 applied) | `9b6dda3d58f672eec8cac11a2790aec8ca58b0318ee433ed5bad1cba66265625` |
| `kernel/post-v3.4.0/CORRECTIONS.json` (status `LOCKED_RELEASE_v3.4.1`) | `54292dde575a750a2ce5ac7ed763a807315a0d8d1b0de269c46dbffd7683daae` |
| `kernel/post-v3.4.0/ASSEMBLY.json` | `6e34e03e3dc23a48796f3d2691e083a0772d9fa2fe0e82bdb17d8c90aae2a1b3` |
| `kernel/post-v3.4.0/CORRECTIONS.diff` | `62e7bc51ec6799e18f1ec92a4b1180766483dc771c445093f23878b775375fe6` |
| `ITEM_LOCK_INTERSECTIONS.json` | `a0930dc8e1a15c29ec27c239b52fb206bab7026d023a7e64a7cac9c07568cc26` |
| `kernel/post-v3.3.1/kernel.md`, v3.4.0 (superseded; the base pin) | `0d6beee233602502576c1d0eedfe5a586e66f1b4e4b8a1858c39189d872ec1a2` |
| `kernel/post-v3.3.0/kernel.md`, v3.3.1 (superseded) | `e49533088843e2cd0a1c531c4d8ba113ea30113e8135a15c17c040bdfca3e0e0` |

The folder is named `kernel/post-v3.4.0/`, following the convention that each release folder is named after its predecessor.

## What the lock changed

Compared with the candidate, only kernel lines 5 and 9 change:
- the version paragraph (`POST340-HEADER-VERSION`) now reads "**LOCKED release of record** by saphir 2026-11-04: "v3.4.1, lock it"";
- the v3.4.1 changelog head (`POST340-CHANGELOG`) reads "LOCKED by saphir 2026-11-04".

The plan's `status` becomes `LOCKED_RELEASE_v3.4.1`, and `release.lock` holds the statement. The body text, including the Ford row and its note, is unchanged from the candidate and from the PR #76 draft.

## What v3.4.1 changes

See `RELEASE_CANDIDATE.md`. In short:
- **The correction.** One correction: the §9.4 Ford-circles row (Part II / II.5) becomes a short row plus an untagged note. The note states the Lean-verified FF-3 lifted-data map, and arcs, maps from phasor values or paths, and dynamics stay undefined and interpretive.
- **Release metadata** changes as well.
- **Unchanged:** all 187 native identities are kept in order. No item is added, and no native tag or status label changes. No standing is upgraded.

## Item-locked text

No v3.4.1 replacement falls in any of the 17 strict v3.2.7 lock spans (`ITEM_LOCK_INTERSECTIONS.json`). The lock covers the assembled kernel as a whole and renews no item lock.

## Verification

```
python tools/build_successor_kernel_v2.py --folder kernel/post-v3.4.0 --check   # PASS: 6 replacements, 187 identities
python tools/build_successor_kernel_v2.py --folder kernel/post-v3.3.1 --check   # v3.4.0 unchanged: PASS
python -I -B docs/releases/v3.4.1/scripts/item_lock_check.py                     # reproduces ITEM_LOCK_INTERSECTIONS.json
python -I -B kernel/post-v3.3.1/repairs/2026-11-04/ff3-ford-9.4-row/check_ff3_row.py   # PASS 8557
```

## Not included
- **Skill bundle:** no change. The v3.4.1 skill package is built after this lock.
- **Lean:** no Lean change. FF-3 is reported verified by skeleton and is not in this repository.
