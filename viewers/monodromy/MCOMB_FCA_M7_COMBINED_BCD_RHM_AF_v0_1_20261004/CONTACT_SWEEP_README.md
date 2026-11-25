# Contact sweep v0.1.1 — repair candidate on the M7 camera host

Built 2026-09-26 by Claude Opus 5.5 after Astra's cold audit of v0.1: **HOLD**, one P1 finding (F1) and one observation (O1). Standing: **builder checks PASS; unsealed; re-audit pending**. There is no seal, seating or lock.

This is an additive successor. The following are pinned and never written:
- the audited candidate `MCOMB_FCA_M7_CONTACT_SWEEP_v0_1_20260926` (viewer `2cd7461d…`, pins `23a40078…`);
- Astra's report `M7_CONTACT_SWEEP_ASTRA_AUDIT_20260926/CONTACT_SWEEP_COLD_AUDIT_ASTRA_20260926.md`;
- the sealed camera package (manifest `55280b7d…`);
- the sealed v0.2 schema package.

As in v0.1, 164 inherited camera files are byte-identical copies. Copied camera documents describe the predecessor.

## Changes from v0.1

**F1 — imported placement bypassed coefficient compatibility.** `showSelectedContact` now compares the current host t₁, t₂, n₆ and α with the record's config before any host write. On a mismatch it returns `HOST_PLACEMENT_UNAVAILABLE`, names each differing field and states "no host write performed". The imported record stays available for inspection. After a placement the fields are checked again. The host's own lower phase (N·t₁−t₂)·s/N is recomputed exactly from host strings and must equal j. The receipt carries `coefficients` and `hostLowerPhase`. Coefficient changes remain a separate, explicit **Apply canonical coefficients (t₁=t₂=1)** action.

**O1 — historical receipts.** The placement line now reads "Last host placement · …". It is cleared when its context is discarded: on invalidation, cancelled generation, Reset, a new generation, a backward seek that drops the placed event, or selection of a different event.

**Snapshot-time host re-read.** This is the audit's untimed boundary note. `snapshot()`/export now polls the host first, so an export right after a coefficient edit is refused instead of using the stale record.

**Comb order widened, by Robin's instruction 2026-09-26.** Every host comb m=2..720 contains the tooth c=−1 (`combOffsets`). At t₁=t₂=1 its frequency is k=N−1, so its contact set s=N·j/(N−1) does not depend on m. The panel therefore collects branch c=−1 for any m, and the other teeth stay visible but are not collected.
- m=2 snapshots keep the sealed schema **0.2.0** unchanged.
- Other m export an explicit **0.3.0**, defined in `contact-sweep-0.3.schema.json`. It is identical to 0.2.0 except for `schema_version` and `comb_m`, which ranges over 3..720.
- Changing m starts a new epoch because comb_m is recorded provenance. The event set is identical.
- Placement does not compare m, since it does not affect the contact. t₁ and t₂ do affect it, so they are compared.

## Unchanged

- Exact generator, validator boundary, epochs, transport, table cap, sidecar separation.
- Base/shell placement protocol, including the three base/shell endpoint fixtures.
- Profile limits other than m.

## Run

`node server.cjs` here, or `../M7_CONTACT_SWEEP_REPAIR_WORK_20260926/launch-viewer.ps1`. Evidence and limits: `../M7_CONTACT_SWEEP_REPAIR_WORK_20260926/CONTACT_SWEEP_CHECKS.md`.

Astra's `attached-q24-contact.json` was bound to the v0.1 build identity. In this build it therefore imports as OFFLINE, and placement from it is refused on provenance. The F1 acceptance tests use a snapshot exported by this build.

Finite contact collection is not S2 seating, theorem adoption, novelty, or BSD/rank evidence.
