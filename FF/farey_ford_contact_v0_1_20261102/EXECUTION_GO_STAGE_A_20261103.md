# FF-1 Stage A: execution go

2026-11-03. saphir (Robin Miller), to skeleton, in the Code session, verbatim: **"Go Stage A"**. Given in answer to "Give the Stage A execution go for FF-1 v0.3?", after skeleton reported bus #1369. Recorded by skeleton (Claude Opus 5.5).

**Covers:** Stage A of `WORK_ORDER_v0_3.md` (SHA-256 `43560b88ab50dc77d8e222562f83bad68c8ba17d12a073523a99597a484d6fdd`), read with the owner's review `rule30_seats/codex/reviews/ff1_design_20261102/REVIEW_v0_3_20261103.md` (`a43bbef7e7ce3ce9518bd38973c4d1815c809217abe53f4052237711c53ef5bb`) and `ERRATUM_v0_3_E1.md`.

**Order of work, as the order requires:**
1. Input freeze (§2, R2): expected and observed hashes, identities, full checksum + read-only receipt, commands, fresh host facts. Submitted for freeze review.
2. Signature freeze (§2, CP-01): explicit-binder Lean signatures for A1–A7 and the bridge lemma, hashed, submitted for review.
3. Only after both freezes are reviewed: F1, then F2 (serial, §8), then the remaining Stage A proofs, within the order's caps and stop rules.

**Not covered:** Stage B; FF-1 library synchronization (stays a proposal awaiting separate authorization, per #1369); commits; compute on Neo; G1; S4r-C.
