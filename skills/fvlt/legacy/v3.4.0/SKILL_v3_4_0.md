---
name: fvlt
description: "FVLT (Ratioque Factorial Vernier Lattice Transform) — atlas-general divisor-lattice and Vernier harmonic framework for Div(N), exact-conductor signal analysis, finite Hasse/crystal Hilbert realizations, and factorial-shell worked instances. Trigger on: FVLT, Ratioque, divisor lattice, Vernier harmonic instrument. Robin Miller (2011–present). v3.4.0, LOCKED release of record (saphir 2026-11-03): adds Rmk 9.7j.1, the symmetric chain decomposition of Div(N) by the diagonal sl2 crystal bracket rule, as the first declared native item addition on the locked v3.3.1 (which corrected guard G2 of Lemma II.23.9a and the sign of n6 on v3.3.0, the reviewed successor corrections on v3.2.7, on the v3.2.0 semantic-correction baseline); v3.3.1, v3.3.0, v3.2.7 and v3.2.6 are kept for historical reproduction."
---

# FVLT skill: Ratioque v3.4.0 (LOCKED release of record, saphir 2026-11-03)

**Release state.** The kernel is FVLT v3.4.0, LOCKED by saphir on 2026-11-03 ("v3.4.0, lock it"), SHA-256 `0d6beee233602502576c1d0eedfe5a586e66f1b4e4b8a1858c39189d872ec1a2`. It is a minor release on the locked v3.3.1 (`legacy/v3.3.1/`, SHA-256 `e4953308…e0e0`, LOCKED by saphir 2026-10-30) and adds one declared native item, Rmk 9.7j.1, under the kernel item-addition policy v0.2 adopted by saphir on 2026-11-03. The 186 inherited native tags are byte-identical to v3.3.1. v3.3.1 was itself a point release on the locked v3.3.0 (`legacy/v3.3.0/`, SHA-256 `35ca26ee…b5ce`, LOCKED by saphir 2026-10-28) that applied one correction adopted by saphir on 2026-10-30 ("our kernel needs to comply with the lean. I am good with that"). The release lock covers the assembled kernel as a whole; it does not renew the item locks on the edited item-locked text listed below.

This skill sends questions to the v3.4.0 kernel and keeps every standing and limitation intact. It does not restate the kernel. If this file and the kernel disagree, the kernel wins: say so, and report the discrepancy.

v3.4.0 applies 8 replacements to v3.3.1 (`CORRECTIONS_v3_4_0.json`): the item, its bookkeeping and the release metadata. v3.3.1 applied 13 replacements to v3.3.0 (`legacy/v3.3.1/CORRECTIONS_v3_3_1.json`); v3.3.0 applied 292 replacement hunks to v3.2.7 (290 excluding the two header hunks; including the footer metadata hunk and the 2026-10-24 integrated corrections), with the reviewed corrections of 14 repair topics. Many statements are narrowed, scoped or withdrawn. **Read the item itself before answering.** The summaries below are only routing aids.

## Files and authority

| File | Role |
|---|---|
| `kernel_v3_4_0.md` | **Authority.** The locked v3.4.0 kernel (SHA-256 `0d6beee2…c1a2`), with its 187 native-id tags and per-item status lines. |
| `CORRECTIONS_v3_4_0.json` | Release metadata. The 8 replacements declared against the pinned v3.3.1 bytes (status `LOCKED_RELEASE_v3.4.0`). It is an index, not mathematical authority. |
| `ITEMS_ADDED_v3_4_0.json` | The item-index row for the added Rmk 9.7j.1 (policy rule 8) and its Lean link (rule 9: finite instances and one-step rank lemmas only, `status_effect: none`). It is an index, not mathematical authority. |
| `records/v3.4.0/` | The v3.4.0 lock record (`records/v3.4.0/RELEASE_LOCK.md`), the release candidate record, the script-derived item-lock list (no replacement in any lock span), and the plan README (`records/v3.4.0/POST_V3_3_1_README.md`, with the wording adaptations from the candidate). |
| `legacy/v3.3.1/` | The superseded v3.3.1 kernel, its `legacy/v3.3.1/CORRECTIONS_v3_3_1.json` (the 13 replacements against v3.3.0), and the v3.3.1 skill instructions, provenance and manifest (`legacy/v3.3.1/SKILL_v3_3_1.md`, renamed so no loader takes it for a second skill). **For historical reproduction only**, except that `legacy/v3.3.1/CORRECTIONS_v3_3_1.json` remains the index for why a v3.3.1-era line changed. |
| `records/v3.3.1/` | The v3.3.1 lock record, the script-derived item-lock list, and the G2 / n6 correction record (`records/v3.3.1/G2_N6_README.md`, `records/v3.3.1/G2_N6_CHANGES.json`) with its exact check script `records/v3.3.1/check_g2_n6.py` and output. |
| `legacy/v3.3.0/` | The superseded v3.3.0 kernel, its `legacy/v3.3.0/CORRECTIONS_v3_3_0.json` (every replacement against v3.2.7), and the v3.3.0 skill instructions, provenance and manifest (`legacy/v3.3.0/SKILL_v3_3_0.md`, renamed so no loader takes it for a second skill). **For historical reproduction only**, except that `legacy/v3.3.0/CORRECTIONS_v3_3_0.json` remains the index for why a v3.3.0-era line changed. |
| `records/v3.3.0/` | The v3.3.0 release candidate (corrected), the lock record (the current lock of 2026-10-28 and, above it, the first lock, superseded before publication), the release-metadata units, and `ITEM_LOCK_INTERSECTIONS_v2.json` (the script-derived list of replacements inside item-locked text from five lock sources, the 108-occurrence lock-word census, and the native-tag changes). `ITEM_LOCK_INTERSECTIONS.json` is the superseded round-1 list, which used ITEMS.json only. |
| `records/v3.2.7/` | The v3.2.7 release record (`RELEASE_CANDIDATE.md`, finalized as LOCKED). |
| `records/` (top level) | The v3.2.6 release lock and candidate, and the item-lock records with the authority documents they cite. Each record governs only the items and bytes it names. |
| `bibliography_v3_2_6.md` | Citations and bibliography-tier entries, at their own stated standing. **It was not revised for v3.3.0, v3.3.1 or v3.4.0** and is carried over unchanged as the current bibliography. It also carries an inherited working-assembly changelog, unedited. The three works cited by Rmk 9.7j.1 are named only in the kernel's VII.9 note "v3.4.0 citations (Rmk 9.7j.1)", not here (open limitation F-3, below). |
| `references/CURRENT_WORK.md`, `references/CURRENT_WORK_INDEX.json` | Dated, advisory routes to developing work. **They were built against the v3.2.6 kernel and not refreshed for v3.3.0, v3.3.1 or v3.4.0.** |
| `legacy/v3.2.7/` | The superseded v3.2.7 kernel and its `legacy/v3.2.7/ITEMS_v3_2_7.json`. **For historical reproduction only.** |
| `legacy/v3.2.6/` | The superseded v3.2.6 kernel, `legacy/v3.2.6/ITEMS_v3_2_6.json` and skill instructions (`legacy/v3.2.6/SKILL_v3_2_6.md`). **For historical reproduction only.** |
| `legacy/v3.2.5/` | The superseded v3.2.5 kernel, bibliography and skill instructions. **For historical reproduction only.** |
| `PROVENANCE.json`, `MANIFEST.sha256`, `scripts/verify_bundle.py` | The source commit and path of every copied file, the checksums, and a standalone verifier. |

Use these sources in this order of authority:
1. The v3.4.0 kernel text, including the item's own status line or native-id tag.
2. The lock record that covers that item and those bytes.
3. The bibliography, for citations.
4. Implementation evidence (programs, viewers, UI labels), which counts as evidence only.

Audit reports, cold-pass verdicts and review clearances keep their stated scope. They do not authorize future changes, and they do not upgrade a standing. A checksum or a review PASS is not a theorem, a lock or a promotion.

## What v3.4.0 changes

One declared native item addition, the first under the kernel item-addition policy v0.2 (adopted by saphir 2026-11-03):
- **Rmk 9.7j.1 (Symmetric Chain Decomposition by the Diagonal Tensor Rule)**, `RMK-9.7j.1-SYMMETRIC-CHAIN-DECOMPOSITION`, Part II / II.17, directly after Rmk 9.7j. It declares the diagonal $\mathfrak{sl}_2$ on $H_{\mathrm{Hasse}}(N)$ alongside Rmk 9.7j (it does not replace 9.7j's commuting-factor reading). The bracket rule reads the word of a divisor **from left to right**, in ascending prime order; its strings form a symmetric chain decomposition of $\mathrm{Div}(N)$, which index (but, for two or more distinct primes, do not span) the irreducible summands. The strings depend on the declared prime order.
- **Status, as in its tag:** "unconditional (classical, cited) + interpretive (address)", provenance adapted-classical. The status paragraph: unconditional (classical, cited) for claims 1–3 and 5; interpretive for the address; claim 4 is an elementary precision statement proved in the item. No new theorem is claimed.
- **Lean link** (`ITEMS_ADDED_v3_4_0.json`): finite instances $N = 720$, $30030$, $720720$ and general one-step rank lemmas only. It does **not** prove the remark in general. `status_effect: none`.
- **Bookkeeping.** A VII.2a concordance table "Post-v3.3.1 item additions (v3.4.0)", a VII.9 citation note, the release-scope paragraph and the release metadata.
- **Standing.** The 186 inherited native identities keep their order and their tags are byte-identical to v3.3.1; 187 in all. No status label changes on any inherited item, no item-locked text is edited, and no standing is upgraded.
- **Open limitation F-3.** The bibliographic details in the VII.9 note (de Bruijn–van Ebbenhorst Tengbergen–Kruyswijk 1951, Greene–Kleitman 1976, and what arXiv:1809.00114 is) are **not checked against the papers**, and the bibliography file is not revised. Quote them as unchecked.

## What v3.3.1 changes (carried into v3.4.0)

One correction, adopted by saphir 2026-10-30, so that the kernel agrees with the verified Lean $y$-reflection law (modules FVLTYReflectionV1 and FVLTN6YReflectionV1; not bundled):
- **Sign of $n_6$ (Rmk II.5a).** $n_6$ enters as magnitude $|n_6|$ (radius $r_\alpha=|n_6|n_3^\alpha$) and sign. The sign is the **$y$-axis reflection** $z\mapsto-\bar z$: for $n_6<0$, $z_j=-r e^{-i\theta_j}$. In phase-address units it sends $a\mapsto 1-a$. The pre-v3.3.1 printed form multiplied by the signed scalar $n_6$, a half-turn $z\mapsto -z$ ($a\mapsto a+1$). The two agree only on the real axis; the scalar reading is history, not the meaning of the sign. The contact identity, conjugate pair, $n_6=0$ collapse and $n_6=1$ reference case are unchanged, and the contact hypothesis reads "Assume $n_6\ne0$". For $n_6<0$, when $t_1 s$ is an integer the new point pair is the old one with $z_1$ and $z_2$ swapped (same picture, different labels); the drawn rosette changes only when $t_1 s$ is not an integer and a point lies off the real axis.
- **Guard G2 (Lemma II.23.9a).** The branch change $c\mapsto -c$ sends $q\mapsto -q$ with $p$ fixed: it reverses the winding of the **second torus coordinate only**. It is **not** the sign of $n_6$ and **not** chirality χ, which (the $y$-reflection applied to both coordinates, or χ extended coordinatewise) would reverse both windings. They agree only when $p=Nt_1=0$. The lift uses $\rho=|n_6|N^\alpha$ and does not apply the sign of $n_6$.
- **χ stays distinct.** Chirality χ (§4.4) is per-phasor conjugation $z\mapsto\bar z$; the $n_6$ sign is $z\mapsto-\bar z$; they differ by a constant half-turn. FVLT Explorer v2.3.1 labels its $n_6$ $y$-flip "§4.4 Chirality". That is an implementation label (evidence only), not an identification.
- **Bookkeeping.** The VII.2a II.23.9 note, the Lemma II.23.9a concordance row and the release-scope paragraph record the G2 edit. The release metadata (title, version paragraph, changelog, footer) name v3.3.1 and keep the v3.3.0 record as history.
- **Standing.** No native tag or status label changes, and no standing is upgraded. All 186 native identities keep their order.

## What v3.3.0 changes (carried into v3.3.1)

- **Corrections.** The integrated corrections of 2026-10-24, then repair topics 1–13 (2026-10-25) with the Opus follow-up, then topic 14 (2026-10-28, read-review corrections, fix rounds 1–4). Each is declared against the v3.2.7 bytes in `legacy/v3.3.0/CORRECTIONS_v3_3_0.json`. The kernel's v3.3.0 changelog comment (front matter, line 9) lists the topics.
- **What the release covers.** Astra cleared the mathematical text at `4c89fba`. The label, the superseded lock and the correction round changed release metadata only: the header, the version and release-scope paragraphs, the changelog and the footer.
- **"Successor draft" in the body.** Edit records and notes in the kernel say "successor draft". The phrase means the release text as changed from v3.2.7 (now v3.4.0).
- **Standing: none upgraded, eleven native tags changed.** No status is upgraded, and no Goldbach, RH/Landau or centered-comb standing is raised. Eleven native tags change against v3.2.7, each by a reviewed correction:
  - **Withdrawn or downgraded.** Thm 6.2, Thm 8.14a and Thm 8.20h.3 are withdrawn to open (register proved to conditional, status unconditional to open). Rmk 8.20h.4 goes from unconditional to open. **Do not quote the earlier "proved" labels as current.**
  - **Weakened.** In Rmk 9.7z the iff is weakened to sufficiency (necessity open). Rmk 9.7z was itself locked (see below).
  - **Label splits.** Rmk 1.2 and Rmk 3.6 split into unconditional and interpretive parts.
  - **Dependency lists only.** Def 5.1, Def 5.2, Rmk 9.4a and Note 9.4b.
- **C-01.** The C-01 value (HLA entropy row) stays explicitly unresolved: its numbers are historical observations, excluded from validated quantitative conclusions.
- **New notation table.** "Successor notation entries" (Part VII / VII.8) separates glyphs that carry more than one meaning. No item is renamed.
- **Status labels.** The §1.3 Proof Status Convention is historical (Part VII / VII.1). Its Conditional row is widened, and a current-label rule keeps each item's literal register, status and provenance strings.

### Item-locked text that v3.3.0 and v3.3.1 edit

The v3.3.0 and v3.3.1 releases cover the kernel as a whole. **They do not re-attest these items or renew their locks.** Their earlier attestations and item locks cover the original bytes only.

**Scope of the list.** It is complete with respect to five lock sources:
- (a) item-locked folds in ITEMS.json;
- (b) native-tag lock fields;
- (c) in-body item-lock records;
- (d) version-history item-lock records;
- (e) bodies described as locked.

All 108 lock-word occurrences in the v3.2.7 kernel are classified (`records/v3.3.0/ITEM_LOCK_INTERSECTIONS_v2.json`). Locks outside the kernel (bibliography tier, companions) are not covered.

**Sources (a)–(d): 23 replacements in 8 locked spans** (22 in v3.3.0, one more in v3.3.1; `records/v3.3.1/ITEM_LOCK_INTERSECTIONS.json`). v3.4.0 adds none (`records/v3.4.0/ITEM_LOCK_INTERSECTIONS.json`).

| Locked span | Earlier lock | Replacements in v3.3.0 and v3.3.1 |
|---|---|---|
| Farey II.5g–k fold | (a) item-locked by Robin 2026-10-12 (`records/LOCK_RECORD_FAREY_II.5g-k.md`) | REPAIR14-A-11 (census line, with an edit record); REPAIR-HUNK-041 and -042 (the rupture record reads "order" as "admissible denominator") |
| Goldbach II.23.5c–e fold | (a) item-locked by Robin 2026-10-12 (`records/LOCK_RECORD_GOLDBACH_II.23.5c-e.md`); ATTESTED, machine PASS, **seated: false** | REPAIR-HUNK-133 (Def–Prop II.23.5d Status paragraph); REPAIR-HUNK-134 (Def II.23.5e: $\Lambda_G(r)$ defined for any positive integer $r$, comparator use at even $N \ge 4$); REPAIR14-PR60-LAMBDAG (Def II.23.5e displays, with edit records) |
| II.23.9 fold | (a) item-locked by Robin 2026-07-23 (`records/LOCK_RECORD_II_23_9_2026-07-23.md`) | REPAIR14-C-02-POINTER (parameter pointer); REPAIR-HUNK-146 (Rmk II.23.9b gloss); **v3.3.1:** G2-N6-CHI-PARENTHETICAL (guard G2): **corrects the mathematics of a locked statement** (c ↦ −c is not the n6 sign or χ) |
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

## Baseline contract (v3.2.0, as corrected in v3.3.0 and v3.3.1)

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
  - In v3.3.1 the hypothesis is $n_6 \ne 0$, and the sign of $n_6$ is the $y$-axis reflection (see "What v3.3.1 changes").
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

- **Native-id tags.** Items carry `<!-- id: PREFIX-NUM-SLUG | register: … | status: … | provenance: … | depends: … -->`, and v3.4.0 has 187 of them: the 186 of v3.2.7, in order, plus `RMK-9.7j.1-SYMMETRIC-CHAIN-DECOMPOSITION` directly after Rmk 9.7j. Search by id or label. Read the tag and the subsection's `**Status:**` line before you answer.
- **Old labels.** Every subsection keeps its v2.7.14 label beside its Part address. Part VII / VII.2a maps old labels to Part addresses.
- **Reference sections.** VII.2 is the theorem/remark/note reference. VII.7 lists open problems, VII.8 is notation (including the successor entries), VII.10 is version history and VII.11 is provenance.
- **Why a line changed.** For the v3.4.0 edits, find the text in `CORRECTIONS_v3_4_0.json` (recorded in the repository under `kernel/post-v3.3.1/`); for the v3.3.1 edits, in `legacy/v3.3.1/CORRECTIONS_v3_3_1.json`; for earlier edits, in `legacy/v3.3.0/CORRECTIONS_v3_3_0.json`. The replacement `id` names the unit, and the unit is recorded in the repository under `kernel/successor/repairs/`.

## Finding developing work

For newer companion studies, research directions or Serena integration, read `references/CURRENT_WORK.md`. Then search `references/CURRENT_WORK_INDEX.json` by catalog ID, KG ID, title or family.

This is dated navigation metadata with no mathematical authority. It was built against the v3.2.6 kernel and has not been refreshed. Its line numbers, reported standings and comparisons refer to older kernels. Keep the v3.4.0 kernel and the locks that apply to it authoritative.

## Answering discipline

- State each claim with its register and status. Keep proved, unconditional, conditional, definitional, interpretive, heuristic-context and not-claimed apart.
- Quote the kernel for anything load-bearing, with its Part address and label.
- Do not extend a scoped statement beyond its stated scope: exponent profile, domain, specialization or finite witness.
- A finite check, a machine PASS or a viewer output is evidence in its own register. It is not a proof unless the kernel records one.
- **Historical reproduction.**
  - To reproduce v3.3.1, v3.3.0, v3.2.7 or v3.2.6 work, use `legacy/v3.3.1/kernel_v3_3_1.md`, `legacy/v3.3.0/kernel_v3_3_0.md`, `legacy/v3.2.7/kernel_v3_2_7.md` or `legacy/v3.2.6/kernel_v3_2_6.md` explicitly, and say that the version is superseded.
  - `legacy/v3.3.1/SKILL_v3_3_1.md`, `legacy/v3.3.0/SKILL_v3_3_0.md` and `legacy/v3.2.6/SKILL_v3_2_6.md` document earlier practice. Their summaries are not v3.4.0 authority; the v3.3.1 text counts 186 native tags, which v3.4.0 raises to 187. In particular, the v3.3.0 text reads the sign of $n_6$ as a scalar half-turn and G2 as "the $n_6$ / χ winding-reversal"; both are corrected in v3.3.1.
  - For v3.2.5, use `legacy/v3.2.5/`.

## Verification

Run `python scripts/verify_bundle.py` from this folder. `PROVENANCE.json` names the source commit and path of every copied file, and the copies are byte-identical to the repository at that commit.

## Version history

- **v3.4.0** (LOCKED by saphir 2026-11-03, "v3.4.0, lock it", `0d6beee2…`; label assigned by saphir 2026-11-03). Minor release on v3.3.1: the declared native item addition Rmk 9.7j.1 (symmetric chain decomposition of $\mathrm{Div}(N)$ by the diagonal $\mathfrak{sl}_2$ crystal bracket rule), under item-addition policy v0.2, with its bookkeeping; 187 native tags. Open limitation F-3 is carried. The record is in `records/v3.4.0/`; the v3.3.1 kernel, corrections and skill instructions are in `legacy/v3.3.1/`.
- **v3.3.1** (LOCKED by saphir 2026-10-30, "v3.3.1, lock it", `e4953308…`). Point release on v3.3.0: guard G2 of Lemma II.23.9a and the sign of $n_6$ in Rmk II.5a ($y$-axis reflection), adopted by saphir 2026-10-30, with lock bookkeeping. The record is in `records/v3.3.1/`.
- **v3.3.0** (LOCKED by saphir 2026-10-28, "lock the kernel", `35ca26ee…`, on candidate `3e32818e…`; label "v3.3.0" assigned by saphir 2026-10-28). A lock on the earlier candidate `edb6528a…` was superseded before publication. v3.3.0 is the reviewed successor corrections on v3.2.7: the integrated corrections of 2026-10-24 and repair topics 1–14. The record is in `records/v3.3.0/`; its kernel, corrections and skill instructions are in `legacy/v3.3.0/`.
- **v3.2.7** (LOCKED by Robin 2026-10-20). Errata on v3.2.6:
  - W1, the Def 5.2 weighted Ramanujan sums;
  - VII.2a notes R1, R2b and G4 on II.23.9.

  The record is in `records/v3.2.7/RELEASE_CANDIDATE.md`.
- **v3.2.6** (LOCKED by Robin 2026-10-12). The II.23.9 fold, Farey II.5g–k, Goldbach II.23.5c–e, and corrections KG-04, KG-04-VII8, KG-06, KG-07, BIB-01, COMB-M-VII8 and L93-SCOPE. The records are in `records/` and `legacy/v3.2.6/SKILL_v3_2_6.md`.
- **v3.2.5** and earlier: see kernel VII.10 and `legacy/v3.2.5/SKILL_v3_2_5.md`.
