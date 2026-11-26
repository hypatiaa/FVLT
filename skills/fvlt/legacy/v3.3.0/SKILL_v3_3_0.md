---
name: fvlt
description: "FVLT (Ratioque Factorial Vernier Lattice Transform) — atlas-general divisor-lattice and Vernier harmonic framework for Div(N), exact-conductor signal analysis, finite Hasse/crystal Hilbert realizations, and factorial-shell worked instances. Trigger on: FVLT, Ratioque, divisor lattice, Vernier harmonic instrument. Robin Miller (2011–present). v3.3.0, LOCKED release of record (saphir 2026-10-28): the reviewed successor corrections (integrated corrections of 2026-10-24 and repair topics 1–14) on the locked v3.2.7, on the v3.2.0 semantic-correction baseline; v3.2.7 and v3.2.6 are kept for historical reproduction."
---

# FVLT skill: Ratioque v3.3.0 (LOCKED release of record, saphir 2026-10-28)

**Release state.** The kernel is FVLT v3.3.0, LOCKED by saphir on 2026-10-28 ("lock the kernel"), SHA-256 `35ca26ee4cc68fee56013a769070eb14240ddf8aa8376b038a29c3d470e2b5ce`, on the content of the corrected candidate `3e32818ea4e12957a53b4e85d8dcd16213d7f52653995102c14258603f85e6bc`. saphir assigned the label on 2026-10-28. A lock given the same day named an earlier candidate whose release records were incomplete, and it was superseded before publication (`records/v3.3.0/RELEASE_LOCK.md`). The release lock covers the assembled kernel as a whole; it does not renew the item locks on the edited item-locked text listed below. v3.2.7 (`legacy/v3.2.7/`) is the previous locked release.

This skill sends questions to the v3.3.0 kernel and keeps every standing and limitation intact. It does not restate the kernel. If this file and the kernel disagree, the kernel wins: say so, and report the discrepancy.

v3.3.0 applies 292 replacement hunks to v3.2.7 (290 excluding the two header hunks; including the footer metadata hunk and the 2026-10-24 integrated corrections), with the reviewed corrections of 14 repair topics. Many statements are narrowed, scoped or withdrawn. **Read the item itself before answering.** The summaries below are only routing aids.

## Files and authority

| File | Role |
|---|---|
| `kernel_v3_3_0.md` | **Authority.** The locked v3.3.0 kernel (SHA-256 `35ca26ee…b5ce`), with its 186 native-id tags and per-item status lines. |
| `CORRECTIONS_v3_3_0.json` | Release metadata. Every replacement declared against the pinned v3.2.7 bytes, plus the `release` block: label, lock, the reviewed mathematical-text hash, and the item-lock interactions. It is an index, not mathematical authority. |
| `records/v3.3.0/` | The v3.3.0 release candidate (corrected), the lock record (the current lock of 2026-10-28 and, above it, the first lock, superseded before publication), the release-metadata units, and `ITEM_LOCK_INTERSECTIONS_v2.json` (the script-derived list of replacements inside item-locked text from five lock sources, the 108-occurrence lock-word census, and the native-tag changes). `ITEM_LOCK_INTERSECTIONS.json` is the superseded round-1 list, which used ITEMS.json only. |
| `records/v3.2.7/` | The v3.2.7 release record (`RELEASE_CANDIDATE.md`, finalized as LOCKED). |
| `records/` (top level) | The v3.2.6 release lock and candidate, and the item-lock records with the authority documents they cite. Each record governs only the items and bytes it names. |
| `bibliography_v3_2_6.md` | Citations and bibliography-tier entries, at their own stated standing. **It was not revised for v3.3.0** and is carried over unchanged as the current bibliography. It also carries an inherited working-assembly changelog, unedited. |
| `references/CURRENT_WORK.md`, `references/CURRENT_WORK_INDEX.json` | Dated, advisory routes to developing work. **They were built against the v3.2.6 kernel and not refreshed for v3.3.0.** |
| `legacy/v3.2.7/` | The superseded v3.2.7 kernel and its `legacy/v3.2.7/ITEMS_v3_2_7.json`. **For historical reproduction only.** |
| `legacy/v3.2.6/` | The superseded v3.2.6 kernel, `legacy/v3.2.6/ITEMS_v3_2_6.json` and skill instructions (`legacy/v3.2.6/SKILL_v3_2_6.md`). **For historical reproduction only.** |
| `legacy/v3.2.5/` | The superseded v3.2.5 kernel, bibliography and skill instructions. **For historical reproduction only.** |
| `PROVENANCE.json`, `MANIFEST.sha256`, `scripts/verify_bundle.py` | The source commit and path of every copied file, the checksums, and a standalone verifier. |

Use these sources in this order of authority:
1. The v3.3.0 kernel text, including the item's own status line or native-id tag.
2. The lock record that covers that item and those bytes.
3. The bibliography, for citations.
4. Implementation evidence (programs, viewers, UI labels), which counts as evidence only.

Audit reports, cold-pass verdicts and review clearances keep their stated scope. They do not authorize future changes, and they do not upgrade a standing. A checksum or a review PASS is not a theorem, a lock or a promotion.

## What v3.3.0 changes

- **Corrections.** The integrated corrections of 2026-10-24, then repair topics 1–13 (2026-10-25) with the Opus follow-up, then topic 14 (2026-10-28, read-review corrections, fix rounds 1–4). Each is declared against the v3.2.7 bytes in `CORRECTIONS_v3_3_0.json`. The kernel's v3.3.0 changelog comment (front matter, line 9) lists the topics.
- **What the release covers.** Astra cleared the mathematical text at `4c89fba`. The label, the superseded lock and the correction round changed release metadata only: the header, the version and release-scope paragraphs, the changelog and the footer.
- **"Successor draft" in the body.** Edit records and notes in the kernel say "successor draft". The phrase means the v3.3.0 text as changed from v3.2.7.
- **Standing: none upgraded, eleven native tags changed.** No status is upgraded, and no Goldbach, RH/Landau or centered-comb standing is raised. Eleven native tags change against v3.2.7, each by a reviewed correction:
  - **Withdrawn or downgraded.** Thm 6.2, Thm 8.14a and Thm 8.20h.3 are withdrawn to open (register proved to conditional, status unconditional to open). Rmk 8.20h.4 goes from unconditional to open. **Do not quote the earlier "proved" labels as current.**
  - **Weakened.** In Rmk 9.7z the iff is weakened to sufficiency (necessity open). Rmk 9.7z was itself locked (see below).
  - **Label splits.** Rmk 1.2 and Rmk 3.6 split into unconditional and interpretive parts.
  - **Dependency lists only.** Def 5.1, Def 5.2, Rmk 9.4a and Note 9.4b.
- **C-01.** The C-01 value (HLA entropy row) stays explicitly unresolved: its numbers are historical observations, excluded from validated quantitative conclusions.
- **New notation table.** "Successor notation entries" (Part VII / VII.8) separates glyphs that carry more than one meaning. No item is renamed.
- **Status labels.** The §1.3 Proof Status Convention is historical (Part VII / VII.1). Its Conditional row is widened, and a current-label rule keeps each item's literal register, status and provenance strings.

### Item-locked text that v3.3.0 edits

The v3.3.0 release covers the kernel as a whole. **It does not re-attest these items or renew their locks.** Their earlier attestations and item locks cover the original bytes only.

**Scope of the list.** It is complete with respect to five lock sources:
- (a) item-locked folds in ITEMS.json;
- (b) native-tag lock fields;
- (c) in-body item-lock records;
- (d) version-history item-lock records;
- (e) bodies described as locked.

All 108 lock-word occurrences in the v3.2.7 kernel are classified (`records/v3.3.0/ITEM_LOCK_INTERSECTIONS_v2.json`). Locks outside the kernel (bibliography tier, companions) are not covered.

**Sources (a)–(d): 22 replacements in 8 locked spans.**

| Locked span | Earlier lock | Replacements in v3.3.0 |
|---|---|---|
| Farey II.5g–k fold | (a) item-locked by Robin 2026-10-12 (`records/LOCK_RECORD_FAREY_II.5g-k.md`) | REPAIR14-A-11 (census line, with an edit record); REPAIR-HUNK-041 and -042 (the rupture record reads "order" as "admissible denominator") |
| Goldbach II.23.5c–e fold | (a) item-locked by Robin 2026-10-12 (`records/LOCK_RECORD_GOLDBACH_II.23.5c-e.md`); ATTESTED, machine PASS, **seated: false** | REPAIR-HUNK-133 (Def–Prop II.23.5d Status paragraph); REPAIR-HUNK-134 (Def II.23.5e: $\Lambda_G(r)$ defined for any positive integer $r$, comparator use at even $N \ge 4$); REPAIR14-PR60-LAMBDAG (Def II.23.5e displays, with edit records) |
| II.23.9 fold | (a) item-locked by Robin 2026-07-23 (`records/LOCK_RECORD_II_23_9_2026-07-23.md`) | REPAIR14-C-02-POINTER (parameter pointer); REPAIR-HUNK-146 (Rmk II.23.9b gloss) |
| Thm II.3c | (b) `locked: Robin 2026-07-14 (item)` | REPAIR-HUNK-024 (phase-loss identity wording) |
| Rmk II.5f | (b) `locked: Robin 2026-07-14 v1.0 (item)` | REPAIR-HUNK-040: **corrects the mathematics of a locked statement**. In (i), "the path graph on V" becomes "the induced subgraph on V of the integer path (generally a union of paths)". |
| Rmk 9.7z | (c) `Lock: lock_record_2026-06-09_chi-W-coincidence` | REPAIR-HUNK-101 to -109: **corrects the mathematics of a locked statement**. The locked iff is weakened to sufficiency (necessity open), and the lock record is relabelled "Historical lock". |
| Note 14.5 | (c) "Locked 2026-07-01"; (d) v3.2.3 | REPAIR-HUNK-230 (completion wording) |
| Cor 14.5a | (d) v3.2.3 "[LOCKED 2026-07-04 by Robin's word]" | REPAIR-HUNK-231 (p-adic tree relation, now a fixed-level statement); REPAIR14-D-09 ("120 cases" to "121 cases") |

**Locked spans with no edits:**
- Lemma 9.2a and Rmk 9.3j;
- the S2-closure record (LOCKED 2026-08-19);
- Cor 9.7c.1, Rmk 9.7y and Rmk II.5b (2026-06-07 lock).

**Source (e), described as locked, with the lock scope not recorded.** The v3.1.21 entry says "three locked bodies". Of those, Lemma 9.7a has REPAIR-HUNK-087 to -089 (scope corrected) and Rmk 9.7h has REPAIR-HUNK-112 to -114 (the polygon becomes the projection of a lifted chain). Note 9.3a.1 has no edits.

**Native tags.**
- Of the ITEMS.json items, the ten Farey and Goldbach items carry native tags, and those tags are unchanged. The five II.23.9 items carry no native tags.
- The four tag-recorded locks (Thm II.3c, Rmk II.5f, Lemma 9.2a, Rmk 9.3j) keep their tags unchanged.
- Rmk 9.7z's tag changes: the iff is weakened to sufficiency (necessity open).
- Seated: false is kept for Goldbach.

**Prop II.5k is an unconditional finite witness, not a general theorem.**

## Baseline contract (v3.2.0, as corrected in v3.3.0)

These come from the kernel front matter: "Register separation contract (v3.2.0)" and "How to read this document". Read the current wording there.

- **Atlas-general.** FVLT is atlas-general. The substrate is $\mathcal{A}_{\mathbb{N}} = \{\mathrm{Div}(N) : N > 0\}$, not $\mathrm{Div}(720)$. The 720 material is a worked factorial-shell / 1001 complement instance (Part V).
- **Register separation.** Keep these registers separate: atlas/Hasse, Vernier/phasor, harmonic exact-conductor, $H_{\mathrm{Hasse}}(N)$, $H_{\mathrm{harm}}(N)$, and application/tooling evidence. Shared divisor labels do not identify the spaces, and they do not imply a canonical unitary map.
- **Energy statistics.**
  - $E_q^{\mathrm{line}}$ is the scalar Ramanujan-line statistic. $E_q^{\mathrm{full}}$ is the full exact-conductor subspace energy.
  - v3.3.0 adds a complete-period energy scale. Unqualified $E_q^{\mathrm{full}}$ and $E_q^{\mathrm{line}}$ use the sum inner product on $\mathbb{Z}/N\mathbb{Z}$. The mean powers are these values divided by $N$.
  - Windowed forms must declare their support, anchoring, normalization and taper policy.
- **Vernier contact.**
  - v3.3.0 states it as follows. At integer $s$, the real-axis contact condition is $t_1 s - t_2 s/n_3 \in \mathbb{Z}$. It reduces to $n_3 \mid t_2 s$ within the finite window when $t_1 s$ and $t_2 s$ are integers. This is narrower than the v3.2.6 wording.
  - Recovery of $\mathrm{Div}(s)$ is restricted to the reference specialization $t_2 = 1$.
- **Coprime Virasoro/Fock branch.**
  - The branch (Part II / II.21–II.22) is non-normative research and history. Do not treat it as active theorem authority, and do not invoke Stone–von Neumann as established.
  - Mode counts: $\varphi(720)=192$ (paired 96), $\varphi(1001)=720$ (paired 360), $\varphi(720720)=138240$ (paired 69120).
- **Roots-of-unity register discipline (v3.1.18).**
  - Phases are roots of unity first. Degrees and decimals are display annotations.
  - The $\Omega = 2$ ring statement is scoped to the **constant exponent-two six-prime crystal** (for example $N = 30030^2$). Do not transfer it to other exponent profiles.
- **Quoting status.**
  - Quote each item's own status text (its native-id tag or `**Status:**` line) together with the claim.
  - Report compound labels as written, for example "not-claimed", "comparator-only", "heuristic-context", "adapted-classical" and "unconditional finite witness". Do not collapse them into the historical core labels.

## Limits that must survive every answer

- **Goldbach (II.23.5c–e, III.11).**
  - Binary Goldbach is **not claimed**.
  - Global coverage and prime-surviving fibres stay **conditional on Goldbach** (Thm 6.3, III.11).
  - The items' own clauses stand verbatim:
    - Cor II.23.5c: "not-claimed (coverage/density)".
    - Def–Prop II.23.5d: "comparator-only (no bound)".
    - Def II.23.5e: "heuristic-context (pair-density interpretation) + not-claimed (count/coverage/phasor magnitude)".
  - [GS20] supports the singular-series normalization only.
  - The attestation is not seated, and no lock seated it.
- **$\operatorname{comb}(m)$.**
  - It is a notation entry only (VII.8). For integer $m \ge 2$, it is the centered offset set used as the branch set in Def II.23.9 and Cor II.23.9d.
  - It imports no companion hypothesis or result, and it admits no general-comb result.
  - It is distinct from the local comb $\mathrm{comb}(d)$ of Rmk 9.7k.
- **Centered-comb companion.**
  - The companion is locked (2026-08-05) at the instrument/bibliography tier, **outside the kernel**. ALG-5 keeps its paired readout and domain.
  - On their common domain, its pair is the $m = 2$ specialization only (Part VII / VII.2, "Extension boundary").
  - **The $m \ge 3$ extension remains EXT at its own gate.**
  - No factoring or quantum advantage is asserted.
- **II.23.9 dependency list.**
  - Preserve the list as the kernel states it.
  - The VII.2a reference note reads "Def 9.7 (product-torus / Clifford-family shells)" as a context citation of the §9.7 embedding cluster. Base Def 9.7 does not construct those objects. They are defined in Def II.23.9 and Prop II.23.9c.
  - The "ALG-5 (centered m-comb)" label refers to the companion family (the KG-07 pointer), not to the resident pair-only ALG-5.
  - Do not treat either label as verified proof support, and do not admit the companion through it.
- **Notation.**
  - $\mathcal{P}(N)$ is the prime-support set. $\pi(N)$ is the prime-counting integer (for example $\pi(720) = 128$). $\omega(N) = |\mathcal{P}(N)|$.
  - Older text, including the legacy instructions, writes $\pi(N)$ for prime support. When presenting current mathematics, translate it. When quoting historical text, keep the original notation and say what it meant.
- **Outside this skill.** Graph tooling and exports, database experiments, candidate research, and proposed schema or link rules are not part of the mathematical authority.

## Finding things in the kernel

| Part | Question it answers |
|---|---|
| I — Substrate | What exists? |
| II — Instruments | How is the substrate measured, visualized, transformed, or read? |
| III — Atlases and Structural Classes | What kinds of atoms or regimes appear across the substrate? |
| IV — Dynamics and Walk Grammar | How do walks move? |
| V — The 720 Factorial-Shell and 1001 Complement Instance | What survives as the local 720/1001 worked instance? |
| VI — Applications, Tooling, and AI | What is the framework for? |
| VII — Status, Scope, Open Problems, Notation, Bibliography | What is proved, what is conditional, what is open? |

- **Native-id tags.** Items carry `<!-- id: PREFIX-NUM-SLUG | register: … | status: … | provenance: … | depends: … -->`, and v3.3.0 has 186 of them, in the v3.2.7 order. Search by id or label. Read the tag and the subsection's `**Status:**` line before you answer.
- **Old labels.** Every subsection keeps its v2.7.14 label beside its Part address. Part VII / VII.2a maps old labels to Part addresses.
- **Reference sections.** VII.2 is the theorem/remark/note reference. VII.7 lists open problems, VII.8 is notation (including the successor entries), VII.10 is version history and VII.11 is provenance.
- **Why a line changed.** Find the text in `CORRECTIONS_v3_3_0.json`. The replacement `id` names the unit, and the unit is recorded in the repository under `kernel/successor/repairs/`.

## Finding developing work

For newer companion studies, research directions or Serena integration, read `references/CURRENT_WORK.md`. Then search `references/CURRENT_WORK_INDEX.json` by catalog ID, KG ID, title or family.

This is dated navigation metadata with no mathematical authority. It was built against the v3.2.6 kernel and has not been refreshed. Its line numbers, reported standings and comparisons refer to older kernels. Keep the v3.3.0 kernel and the locks that apply to it authoritative.

## Answering discipline

- State each claim with its register and status. Keep proved, unconditional, conditional, definitional, interpretive, heuristic-context and not-claimed apart.
- Quote the kernel for anything load-bearing, with its Part address and label.
- Do not extend a scoped statement beyond its stated scope: exponent profile, domain, specialization or finite witness.
- A finite check, a machine PASS or a viewer output is evidence in its own register. It is not a proof unless the kernel records one.
- **Historical reproduction.**
  - To reproduce v3.2.7 or v3.2.6 work, use `legacy/v3.2.7/kernel_v3_2_7.md` or `legacy/v3.2.6/kernel_v3_2_6.md` explicitly, and say that the version is superseded.
  - `legacy/v3.2.6/SKILL_v3_2_6.md` documents v3.2.6-era practice. Its summaries are not v3.3.0 authority.
  - For v3.2.5, use `legacy/v3.2.5/`.

## Verification

Run `python scripts/verify_bundle.py` from this folder. `PROVENANCE.json` names the source commit and path of every copied file, and the copies are byte-identical to the repository at that commit.

## Version history

- **v3.3.0** (LOCKED by saphir 2026-10-28, "lock the kernel", `35ca26ee…`, on candidate `3e32818e…`; label "v3.3.0" assigned by saphir 2026-10-28). A lock on the earlier candidate `edb6528a…` was superseded before publication. v3.3.0 is the reviewed successor corrections on v3.2.7: the integrated corrections of 2026-10-24 and repair topics 1–14. The record is in `records/v3.3.0/`.
- **v3.2.7** (LOCKED by Robin 2026-10-20). Errata on v3.2.6:
  - W1, the Def 5.2 weighted Ramanujan sums;
  - VII.2a notes R1, R2b and G4 on II.23.9.

  The record is in `records/v3.2.7/RELEASE_CANDIDATE.md`.
- **v3.2.6** (LOCKED by Robin 2026-10-12). The II.23.9 fold, Farey II.5g–k, Goldbach II.23.5c–e, and corrections KG-04, KG-04-VII8, KG-06, KG-07, BIB-01, COMB-M-VII8 and L93-SCOPE. The records are in `records/` and `legacy/v3.2.6/SKILL_v3_2_6.md`.
- **v3.2.5** and earlier: see kernel VII.10 and `legacy/v3.2.5/SKILL_v3_2_5.md`.
