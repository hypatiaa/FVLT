# Merged viewer v0.1.2 NOCHECK (2026-11-25)

**What it is.** An additive successor of `MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004` (the monodromy merged viewer with every candidate panel). saphir asked for it on 2026-11-25 ("remove the start up check from the viewer"). Built by Claude Opus 5.5 (skeleton seat).

**The one code change.** `server.cjs`, in `start()`. These four lines are removed:

```js
  if (!options.skipIntegrity) {
    require(path.join(root, '..', 'BSD_TATE_T4_v0_1_20260923', 'check-integrity.cjs')).check();
    if (fs.existsSync(path.join(root, 'MANIFEST.sha256'))) require(path.join(root, 'check-integrity.cjs')).check();
  }
```

A one-line comment replaces them. Starting `node server.cjs` therefore no longer walks the predecessor chain (T4 → T3 → … each hashing its whole package). On 2026-10-18 that chain was still running after two minutes of CPU.

**What is kept.**
- `start()` still reads `BUILD_PINS.json` and refuses to serve if `monodromy-31-linked-reduction.html` does not hash to `viewerSha256` (`b4cee4e3…b8e248`). This is one file hash and costs milliseconds.
- The viewer page and every other file are byte-identical to the parent.
- Server behaviour once running is unchanged: 127.0.0.1 only, random port, token, caps.

**Pins changed.**
- `server.cjs`: `20caf539…8424311` becomes `bcf9215f…40c3`.
- `BUILD_PINS.json`: the five entries holding the old server hash now hold the new one.
- `MANIFEST.sha256` is regenerated for this folder.
- `check-integrity.cjs` is still present but unused. The `*.worker.cjs` tests and `seal.cjs` that compare `server.cjs` against older baselines will now report that difference by design.

**Not changed.** The parent folder and the FASTSTART launcher are untouched.

**Still outside this folder.** The file-import assessment endpoint (`assess-stdin.cjs`) loads `../BSD_TATE_T4_v0_1_20260923/assess.cjs` at request time. That needs the T1–T4 folders, a Python runtime and the vendored PARI. Without them the viewer page serves and runs, and only an imported curve packet fails to assess.

**How to run.** Use `START_MERGED_VIEWER_NOCHECK.cmd` in the `s6_atom` root, or `node server.cjs` in this folder.
