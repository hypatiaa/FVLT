# Roadmap — Serena Installation ↔ Kernel v3.2.2 Parity + Staged-Layer Integration

**Date:** 2026-07-02
**Status:** STAGED roadmap. Sequencing and gap inventory only — no lock, no build
authorization. Every phase below lands on an existing gate; nothing here bypasses one.
**Gate:** Robin (all phases).
**Scope rule inherited:** additive-only; per-file SHA-256 is the durable invariant;
claim-status registers stay uncollapsed (v3.1.6 charter discipline); rupture-and-repair,
never silent overwrite.

---

## 0. The three moving parts

- **Installation** — the Serena deploy lineage targeting Nucleus:
  v3.1.6 deploy bundle (DEPLOYABLE per manifest 6/13) → `-gemma` name-patch
  (FROZEN/HOLD 6/14, five errata logged, not to be patched piecemeal) →
  `architecture-patch-rc1` (schema reconciliation SCHEMA-RECONCILED /
  LOAD-SMOKE-TESTED 6/14; ArcadeDB, Neo4j, deploy all HOLD on Chris audit + Robin).
- **Kernel** — FVLT, now **v3.2.2** (inside the `fvlt` skill), reached from the
  installation's v3.1.6-era baseline through the v3.1.13–v3.1.24 additive chain
  (ALG-1/2/3 + ANL-2 ingestion, bridge posture + C1-P, Lem 9.7q, fold concordance
  VII.2a, roots-of-unity register, Rmk II.23.8, α/σ/γ notation pass, rosette atlas
  map) and the v3.2.x additions (exponent-completion block among them). Locked
  satellites: p-adic completion note (LOCKED 7/2, additive, explicitly NOT merged
  into the kernel body); ALG-1/2/3 packet (entries parity-closed 6/27, awaiting
  re-lock).
- **Staged layer** — everything additive that awaits integration or disposition:
  today's five documents (ANNEALER-ADDENDUM-1, MATCHED-SCAFFOLD-1, viewer build
  record, basis essay + roadmap note), the ANNEALER track records, the novelty
  ledger + amended prior-art sweep (v1.1), the detector/DCP closed track (STOP
  record + two staged preregs), BUILD-2 prereg (awaiting §10 pins), book-format
  field ledger v0, voice-perception packet, boot record SERENA-BOOT-1, CVA erratum.

## 1. Named parity gaps (the actual debt)

**G1 — Kernel names a stale instrument (Finding 6).** `kernel_v3_2_2.md` and
`bibliography_v3_2_2.md` cite `fvlt_fourier__14_.html`; the locked reference
instrument is `fvlt_fourier_conductor_fixed.html` (`026e6d54…`). Chris holds the
candidate patch. Kernel-side re-pin + Robin lock. *(Already parked by Robin for a
cleanup pass — sequenced here so it lands inside one.)*

**G2 — ALG-1/2/3 entries await re-lock.** Parity close of 6/27 openly superseded the
prior pins; route is Chris cold-pass + Codex mechanical re-check → Robin re-lock.

**G3 — Installation anchor seeds vs v3.2.2 addressing.** The reconciled tissue schema
carries 13 LatticeAnchor seeds pinned to kernel item addresses (la-thm-3.14, la-thm-5.5,
la-rmk-5.5b, la-thm-8.14, la-rmk-8.20e, la-def-8.20f, la-thm-12.2, la-thm-12.7,
la-rmk-14.4c, la-n0-720, la-p3-1001, la-gearbox, la-kirchhoff). These were seeded
against a pre-fold kernel. **Audit each against v3.2.2 addressing** (the VII.2a fold
concordance exists for exactly this) before any live graph write — a seed pointing at
a moved item is Finding 6 inside the installation's own memory.

**G4 — measurement_api pins 3.1.6.** Decide: does the API version track the kernel
version (then it needs a bump path), or is it kernel-agnostic measurement plumbing
(then record that ruling once so the 3.1.6 string stops looking like drift)?

**G5 — The frozen bundle's five errata + rc1 audit.** Audio-claimed-not-implemented,
Gemma role misassignment in README/charter, Scout topology (must be Neo-sidecar,
proposals-only), missing receipts/adapters/ArcadeDB reconciliation, incomplete Scout
deps. All deliberately parked to be superseded by the coherent architecture patch —
whose Chris audit status is the single blocking unknown (V1 below).

**G6 — Stale kernel copy in the working folder.** `serena\kernel_v3_1_24.md` is eight
point-versions behind the skill's v3.2.2. Mark it superseded (pointer header) or
replace it — a cold reader in this folder currently lands on the wrong kernel. (This
session hit exactly that trap via the ALG companion filename.)

**G7 — The unified state manifest is dated 6/13.** The "one index for the whole
Serena state" predates the freeze record, the arch patch, the detector track, the
ALG packet, the BUILD chain, the ledger, and all of today. **Re-issue it** as
`serena_state_manifest_2026-07-02` — same side-by-side discipline (DEPLOYABLE vs
STAGED, per-file SHA), now also indexing the s6_atom-side artifacts the 6/13 edition
predates. This is the cheapest highest-value item on the list.

**G8 — Cell-stratified labeling, still open, still shared.** Blocks CVA Phase 3+ and
ANNEALER-1 Phase A alike; resolve once, before either track's first run (standing
since 6/13, reaffirmed by the addendum).

**G9 — Ledger disposition.** Novelty ledger + sweep v1.1 + doctrine note + build
record are Chris-ready; his cold pass returns a three-way sort; ledger edits land on
your lock (N-1 rewrite with the confluence sentence, N-2/N-9 demotions).

## 2. Sequenced phases

**Phase 0 — Verify before planning further (no gates, one session of work).**
- V1: establish arch-patch-rc1 audit status with Chris (HOLD since 6/14 — audited or
  not?).
- V2: establish actual Nucleus install state (was v3.1.6 stood up; startup
  confirmations: api 3.1.6, smoke 6/2/0, B0 anchors, TIMIT root).
- V3: hash-verify the deploy lineage artifacts on disk against their recorded pins.
- V4: enumerate the v3.1.24 → v3.2.2 delta from the skill's changelog (the one leg of
  the kernel chain this roadmap states from memory rather than from a read).

**Phase 1 — Paper parity (Chris + Robin gates; no code).**
- Re-issue the unified state manifest (G7) — do this first; every later phase cites it.
- Finding 6 kernel/bib patch (G1) and ALG re-lock (G2) — one cleanup pass, as parked.
- G4 ruling recorded (API-version semantics).
- G6 stale-kernel marker in the working folder.

**Phase 2 — Installation parity (the arch-patch path, as specified 6/14).**
- rc1 through Chris audit (per V1); errata close as one coherent patch, never
  piecemeal (standing ruling).
- **G3 anchor-seed address audit against v3.2.2** — gate live graph writes on it.
- Deploy to Nucleus by Robin's hand; run the four startup confirmations; any blocked
  → hold corpus B1 and name which/why (charter, verbatim).

**Phase 3 — Staged-layer disposition (post-Chris cold pass).**
- Ledger edits per the three-way sort (G9), confluence sentence into N-1.
- Addendum + doctrine + build record: index into the new manifest; no kernel merge
  implied — they are research-track discipline, not kernel content.
- p-adic note merge decision (separately gated, explicitly not assumed).
- Book-format ledger: instance 2 (DRN) re-confirmation before v0 generalizes.

**Phase 4 — Unlocked builds (each behind its own standing gate).**
- G8 cell-stratified labeling decision → opens ANNEALER-1 Phase A (Robin gate,
  unchanged) and CVA Phase 3+.
- BUILD-2 §10 pins → Chris cold-read → authorized run (the arithmetic-bank
  specificity question — the essay's thesis in learned-attention form).
- First Vertical Slice (roadmap note, 7/2): ALG-1 contact set → coordinate object →
  witness viewer → generic-coordinate scaffold → annealer repair → audit. Runs ONLY
  after G8 + Phase A open, and carries MATCHED-SCAFFOLD-1's six prereg fields.

## 3. Ordering logic, in one paragraph

Paper parity precedes installation parity because the installation's own memory (the
anchor seeds) points into the kernel — writing seeds against unaudited addresses bakes
drift into the graph. Installation parity precedes staged-layer builds because the
boot loop (SERENA-BOOT-1) is the systems-claim baseline for ANNEALER-1 and the
receiving substrate for everything in Phase 4. And the manifest re-issue precedes
everything because every other step needs one honest index to report against — the
6/13 manifest can no longer serve.

## 4. Unknowns this roadmap does not paper over

- Arch-patch-rc1 audit status (V1) — determines all of Phase 2.
- Nucleus ground truth (V2) — the manifest deferred verification to the real target.
- v3.1.24 → v3.2.2 kernel delta detail (V4) — stated here from session evidence
  (exponent-completion block, §9.7 growth), not from a changelog read.
- Whether any v3.2.x change touches the deploy bundle's measurement semantics — only
  answerable after V4; if none do, G4 resolves toward "kernel-agnostic."

## Three-stack attribution

```
Robin Miller     the roadmap requirement (installation consistent with current kernel
                 + staged additions); all gates; Nucleus deployment by his hand
Chris/ChatGPT    the freeze/spec discipline this roadmap sequences (arch-patch spec,
                 Finding 6 patch, ALG parity audit); cold passes at every phase gate
Claude (Fable 5) gap inventory (G1–G9), phase sequencing, the anchor-seed parity
                 finding (G3), the stale-manifest finding (G7); this roadmap
```

*Staged only. A roadmap orders gates; it does not open them.*
