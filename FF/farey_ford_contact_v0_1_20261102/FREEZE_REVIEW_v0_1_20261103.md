# FF-1 Stage A freeze review v0.1

2026-11-03. Skeleton seat (Claude Opus 5.5), the freeze reviewer named in #1371. Inputs matched by skeleton before reading:

| File | SHA-256 |
|---|---|
| `PREPARATION_MANIFEST_v0_1.json` | `f177f4d473a888d297f44eaa88c841d3b2c9dec2772e07b45930468d404ef0b0` |
| `INPUT_FREEZE_DRAFT_v0_1.md` | `7235f2dc860e9246d9b7a0ec98c1c650516c1e4e4855efcbde84b3697650629f` |
| `SIGNATURE_FREEZE_DRAFT_v0_1.md` | `a9382d4054a77d7a569e884b4f7e02b55f7c7e9aa0da2d3a6d1299075ea2b6c7` |
| `INPUT_OBSERVATIONS_v0_1.json` | `d7d2151de0c9f26f41f195629cfdf34d1fd9601144564181a8b7d53460b633ee` |
| `LIBRARY_SHA256_CHECK_v0_1.txt` | `3e301cad0b1c422bdc6fe6f14d3764bb8ff5c6ddaee1d6cf7ed60e2e89f9aabf` |
| `RUN_FF1_v0_1.py` (read, not run) | `5c0d29c179ad2d8942ac1874d608b1cc00f5892811461af132c26c110ce3207f` |

## 1. Input freeze: **ACCEPT, with conditions I1–I3**

- Library v19 `SHA256SUMS` (`e25d4d54…`), compiler commit `eb6cafb7…`, Mathlib `56a00585…` and checker `9c6f2ac1…` equal the order's §1 pins. Kernel v3.3.1 `e4953308…` re-matched locally by skeleton.
- `LIBRARY_SHA256_CHECK_v0_1.txt`: 381 lines, all `OK`, none other. `LIBRARY_MANIFEST.json`, `lake-manifest.json`, `lakefile.toml` and `lean-toolchain` all appear in that check, so their bytes are covered by the pinned `SHA256SUMS`. That gives their expected values a source beyond the same-session observation. (Skeleton saw the check output, not the `SHA256SUMS` file itself; the digest comparison is the owner's.)
- `lakefile.toml` as the actual package configuration: accepted; the order allowed "or the package configuration actually used".
- The read-only scan (0 writable of 153937; one in-tree doc symlink not followed) and the preparation-only path faults are accepted as recorded.

**I1. Runner command form: accepted as equivalent to `lake env lean`**, on the condition that each job manifest pins the SHA-256 of the `lean` executable at `/home/saphir/.elan/toolchains/leanprover--lean4---v4.35.0/bin/lean` and the runner receipt records the full expanded `LEAN_PATH` (as `RUN_FF1_v0_1.py` builds it: the isolated root, v19's `.lake/build/lib/lean`, and the package build roots). The runner was read: it asserts host `nucleus`, its own hash, an accepted job-manifest hash and source/olean hashes, runs serially under a lock, and re-runs `sha256sum -c` after each call. No network use beyond `gethostname`. Not executed by skeleton.
**I2.** Fresh contention and capacity recheck immediately before F1, as the draft says; return contention rather than compete.
**I3.** Source-job manifests come to skeleton for acceptance before each invocation (hash check of the exact source bytes against these frozen signatures; this is a receipt check, not a new design round).

Resource proposal (1 CPU, nice 19, 8 GiB address space, Lean `-M7680`, 240 s per call, serial 30-minute F1 and F2 deadlines, no retries): accepted.

## 2. Signature freeze: **ACCEPT** (`SIGNATURE_FREEZE_DRAFT_v0_1.md`, `a9382d40…`, frozen as is)

Every header was read against the order (§4, R3, scope notes) and checked by hand for truth and binder adequacy:
- A1: the det-one coprimality argument, canonical bridges and uniqueness under coprimality hold; the 1/3, 1/5 witness gives det 2.
- A2: det(x, mediant) = det(x, y), so adjacency and reducedness of the mediant follow; the rosette gives det 2 and mediant 2/(2N) = 1/N.
- A3–A4: |c_x − c_y|² − (r_x + r_y)² = (x − y)² − 4 r_x r_y = (det² − 1)/(q² s²); open disks disjoint for distinct rationals; tangency iff |det| = 1 with `tangent` excluding self-contact; the kiss point ((a q + c s) + i)/(q² + s²) and the Brahmagupta identity give `kiss_integer_identity` when det = ±1. Uniqueness is a separate target, as A4 requires.
- A5: det(1/a, 1/b) = b − a; induced-subgraph isomorphism (the REPAIR-HUNK-040 wording); connected iff an interval; empty-graph convention correct.
- A6: interior guards explicit; the partner statement keeps the numerator range 1 ≤ c ≤ s − 1; complement det(1 − x, 1 − y) = −det(x, y); Int `/` is Euclidean and divisibility follows from the congruence, as noted.
- A7: `ComponentCertificate` has nonempty parts, coverage, disjointness, induced connectedness of every part and no cross edges (R3). `certificate_isolation` and the bijection are true as stated. In `rationalCertificate`, `s ⊆ S` makes the subtype map injective on parts, so the count is preserved.

**Independent recount of the fixtures** (skeleton, exact integer script, not a proof):

| Profile | V | E | components | isolated |
|---|---|---|---|---|
| (4,2,1) | 7 | 6 | 3 | 1/5, 4/5 |
| (4,3,2,1) | 9 | 10 | 1 | none |
| (9,2) | 11 | 8 | 5 | 1/10, 1/5, 4/5, 9/10 |
| (8,3) | 11 | 8 | 3 | 1/9, 8/9 |

All agree with the frozen fixture statements and partitions.

Non-blocking notes (no change required): `singletonPartition` adds `S \ I` even when empty, which the nonempty clause would then reject, so it is correct only where `S \ I` is nonempty (true for both fixtures); `gap_mediant_unit_iff` is stated for k > 2, with k = 2 covered by `minimal_gap_mediant`; several hypotheses (`hne`, `hq`, `hs`, `hk`) are redundant, which the draft permits.

## 3. What this review does and does not do

It freezes the inputs and the signatures above. Proof development, F1 and then F2 may start once the I3 job manifest for F1 is accepted. No changes to these propositions without a return to review. The independent statement-fidelity review of the final Lean statements remains required. Not covered: Stage B, library sync (still a proposal awaiting separate authorization), commits, Neo compute, G1, S4r-C. Skeleton did not contact nucleus or run Lean.
