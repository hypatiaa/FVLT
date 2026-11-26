# FVLT v3.2.6 — release lock

**Locked by Robin, 2026-10-12**, based on `main` at `395344841cbff50938c24a923d405b829b4bcaf3`. Robin's verbatim statement:

> I lock the assembled FVLT v3.2.6 release based on main 3953448, including the confirmed Farey and Goldbach item locks, preserving their reviewed standings and limitations. Prepare the release-lock PR for Codex’s final verification. Keep #18 held until the release is finalized.

This commit applies the release-lock procedure in `RELEASE_CANDIDATE.md` and awaits Codex's final verification. The candidate document is kept unchanged as the record of what was reviewed.

## Locked artifacts

| Artifact | SHA-256 |
|---|---|
| `kernel/next/kernel.md` (stage `v3.2.6-locked`) | `4a23d62e15ada3819defe6919e56fe9f2ef6a9a10eb7f5c4082e4b6b442cdb94` |
| `kernel/next/bibliography.md` | `f109a7e1097275795bb44fa481d4f63422dce7456c3dbbd7e7348f3468a4c474` |
| `LOCK_RECORD_FAREY_II.5g-k.md` | `067cb91c411a7fa9e60985336ae32dd43202b0acb803ba3c399efe3c1d42f6a6` |
| `LOCK_RECORD_GOLDBACH_II.23.5c-e.md` | `7ab76f305ac9267eca274b1d923b80641f9251ba341ef2e88bd2692275032370` |
| v3.2.5 base (superseded release of record) | `ac53e75b73c42f185248464e3daf856a3dd3fd98b56dfff971341b80b10717ef` |

## What the lock changed

Relative to the candidate on `main` (`b99f6118…`):

- **Kernel text.** The title, version paragraph and changelog take the locked v3.2.6 form, and the two "(v3.2.6 release candidate)" headings become "(v3.2.6)". In the concordance:
  - Farey II.5g–II.5k: "item lock pending" becomes "item-locked by Robin 2026-10-12".
  - Goldbach II.23.5c–e: "item lock pending" becomes "item-locked by Robin 2026-10-12; attestation seated: false". "ATTESTED; machine PASS" and the [GS20] note stay.
  - The five II.23.9 rows: "working fold only" becomes "folded verbatim from the locked entry", because they are now part of a release.

  No mathematical text, item tag or not-claimed clause changes.
- **Lock records.** Both are finalized with the verbatim statement, and their DRAFT marker is removed. Their standing sections are unchanged.
- **`ITEMS.json`.**
  - Each of the ten Farey and Goldbach items cites its lock record (path and SHA-256) in `authority`.
  - Farey moves to `item_locked`. Goldbach moves to `item_locked_attested_seated_false`, a new vocabulary entry that keeps the seated: false limitation.
  - `release`: `status: locked`, `assembled_release_locked: true`, plus a `release_lock` record with the verbatim statement.
  - Each correction's `release_status` becomes "included in v3.2.6 (locked …)".
- **Segments.** The four edited segments are re-declared, each with `replaces` naming its -rc predecessor at the same anchor. No content segment is retired.

## Verification

```powershell
python tools/verify_kernel_base.py
python tools/verify_kernel_next.py --input-root kernel/inputs/2026-10-11/sources --input-root kernel/inputs/2026-10-11-bibliography/sources --input-root .
python -m unittest discover -s tools/tests
python tools/check_omega2_rings.py
```

All four pass, with no MISSING INPUT. The third input root (`.`) lets the verifier hash-check both lock records against their pins.

#18 stays held until this release is finalized. After that, its export is rebuilt against the locked stage before the one bounded ArcadeDB run.
