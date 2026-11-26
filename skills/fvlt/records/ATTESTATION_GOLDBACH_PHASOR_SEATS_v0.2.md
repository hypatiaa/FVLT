# ATTESTATION — Goldbach phasor-panel kernel seats II.23.5c/5d/5e

**Standing:** **ATTESTED** (*ouk antimarturesis*) — lock-eligible, pending the Architect's ruling.  \
**Machine result:** PASS (both seats).  \
**Date:** 2026-07-24  \
**For:** Sol — seating / version / lock decision.  \
**Prepared by:** independent cold-pass review (Claude), acting as the second medium.

> This file records a disposition. It does **not** mutate `kernel_v3_2_5.md`,
> mint a version, or authorize UI changes. Seating remains a separate act,
> reserved to Robin. See "Preconditions still open" below.

---

## 1. What is attested

Three additive draft seats, proposed for insertion after `Remark II.23.5b` and
before `### II.23.6` in Part II:

- `II.23.5c` — Centered Goldbach phasor trajectory; common-carrier factorization.
- `II.23.5d` — Continuous coprime reference; integer Ramanujan reduction.
- `II.23.5e` — Normalized Goldbach local-factor gauge `Λ_G`.

Attested claim = **the candidate text and its verifiers are mathematically and
procedurally fit for consideration**, by two independent seats of different
media that do not contest each other. Attestation is *not* proof of Goldbach
coverage and does *not* promote the continuous yellow path to an integer
Ramanujan identity away from integer spin.

## 2. Pinned authorities (read-only inputs, re-hashed by both seats)

| Authority | SHA-256 |
|---|---|
| `kernel_v3_2_5.md` | `ac53e75b73c42f185248464e3daf856a3dd3fd98b56dfff971341b80b10717ef` |
| `CollapseHierarchyFVLT_v11.21.3.html` | `0944373afb679cd2cc93ecee127cc985f11c9fd8ccfb273af9518ea41eea1e28` |
| `DRAFT_KERNEL_ADDITION_GOLDBACH_PHASOR_PANEL_v0.1.md` | `ea64a10385afb3f616223acdccebf25fb0fafd244298ddd7c04873e0ad85269a` |

Seat interval confirmed present and ordered; no `II.23.5c/5d/5e` header and none
of the three proposed IDs are resident in the pinned kernel.

## 3. The two seats

### Seat 1 — PROSMENON (float / Node.js), independent of authorship

- Packet: `GOLDBACH_PHASOR_KERNEL_DRAFT_COLD_PASS_v0.2/`
- Manifest SHA-256: `a6d172d3f512c48870a2ba8477e2061c73eb180601f951e5c217bf54e026072b`
- Verifier: `verify_goldbach_phasor_panel_kernel_draft_v0_2.mjs` (Node `v24.13.0`),
  built-in modules only, no artifact code imported.
- Result: PASS at `N≤1000` (re-run reproduced byte-identical to the recorded
  `VERIFY_…v0.2.json`). Max carrier error `7.1e-14`.
- Note: the packet's own recorded PASS was **author self-attestation** (draft and
  verifier both authored by ChatGPT); the float re-run here is the first
  genuinely independent witness.

### Seat 2 — the confirming medium (symbolic / exact)

- Packet: `GOLDBACH_PHASOR_SECOND_SEAT_SYMBOLIC_v0.1/`
- Manifest SHA-256: `513ae297113f908091dfe4708990494c3996e4b3890643faae18aa36080a4345`
- Verifier: `verify_second_seat_symbolic_v0_1.py` (Python `3.14.0`, SymPy `1.14.0`).
  Shares **no code** with seat 1.
- Result: PASS. Carrier identities proved for **free symbols** `s, N, a` (all real
  `s` at once); anchor reproduced to `3.5e-13` at 40 digits; integer Ramanujan
  reductions to `5.6e-45`; `Λ_G(120)=8/3` exact; `2C₂≈1.32080` so
  `S(120)≈3.522 ≠ Λ_G`. Range-pushed to `N=20000`, 60 digits — clean.
- Added the **§4 V4 negative firewall scanner** that seat 1 only specified:
  6/6 planted violations caught, 6/6 negated controls cleared, draft clean, and
  a forbidden assertion injected into the real draft body was caught in-context.

## 4. Required cold-pass questions — both seats concur

1. Identifiers unoccupied — **yes** (kernel runs 5a → 5b → 6).
2. II.23.5c from the centered-pair identity for all real `s`, incl. equal/empty
   fibers — **yes** (proved symbolically).
3. II.23.5d distinguishes continuous polynomial from integer Ramanujan sum —
   **yes** (integer reduction exact; continuous-domain guard present).
4. Nondegenerate-unit / equal-pair exception complete — **yes**.
5. `Λ_G` distinguished from full singular series `2C₂Λ_G` — **yes** (numerically
   distinct).
6. Coverage / density / comparison-bound / physical / quantum claims firewalled —
   **yes** (scanner confirms no unguarded assertion).
7. Insertion after II.23.5b / before II.23.6 coherent with dependencies — **yes**.

## 5. Preconditions still open before Sol seats (not blocking attestation)

From the draft's own §6 authority boundary:

- [ ] **Bibliography reconciliation** for the singular-series normalization
      (`Λ_G` vs `2C₂Λ_G`). Draft cites Goldston–Suriajaya, arXiv:2007.16099 (1.1);
      a final seat needs the kernel bibliography entry or an existing equivalent.
- [ ] **Robin's seat / version / lock decision** (version currently unset).
- [ ] **Separate artifact patch** if the two UI labels change
      ("Singular Series S(n)" → "Normalized Goldbach local factor Λ_G(n)";
      "Constructive Interference" → "Local congruence multiplier"). Display policy,
      not kernel math — must not ride along with the kernel splice.

## 6. Known scope limits (recorded for honesty)

- The firewall scanner is a **heuristic** sentence-level audit (assertion cue +
  absence of guard). It catches the six named violation classes and an in-body
  injection; it is not a proof that an adversarially-obfuscated forbidden claim
  could not evade it.
- Attestation reflects the executed scope of both seats. Coverage/density remain
  conditional under III.11 / Thm 6.3, as the draft states.

## 7. Disposition for Sol

Standing is **ATTESTED / lock-eligible**. No blocking defect was reproduced by
either seat. Seating may proceed at Robin's authority once §5 preconditions are
met; the mathematical and firewall gates are satisfied. If a third seat is
desired before lock, it should use yet another medium (e.g. an exact
integer-lattice / algebraic-number check) rather than a third float run.
