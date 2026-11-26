---
name: fvlt
description: "FVLT (Ratioque Factorial Vernier Lattice Transform) — atlas-general divisor-lattice and Vernier harmonic framework for Div(N), exact-conductor signal analysis, finite Hasse/crystal Hilbert realizations, and factorial-shell worked instances. Trigger on: FVLT, Ratioque, divisor lattice, Vernier harmonic instrument. Robin Miller (2011–present). v3.2.6, LOCKED release of record (Robin 2026-10-12): folds II.23.9, Farey II.5g–k and Goldbach II.23.5c–e on the v3.2.0 semantic-correction baseline; v3.2.5 is kept for historical reproduction."
---

# FVLT Skill — Ratioque v3.2.6 (LOCKED release of record, Robin 2026-10-12)

This skill routes questions to the locked kernel and keeps every standing and limitation intact. It does not restate the kernel. When this file and the kernel disagree, the kernel wins; say so and report the discrepancy.

## Files and authority

| File | Role |
|---|---|
| `kernel_v3_2_6.md` | **Authority.** The locked v3.2.6 kernel (SHA-256 `4a23d62e…cdb94`), with its native-id tags and per-item status lines. |
| `records/` | Release lock, release candidate, and the item-lock records with the authority documents they cite. Each governs only the items it names. |
| `bibliography_v3_2_6.md` | Citations and bibliography-tier entries, at their own stated standing. It carries an inherited working-assembly changelog unedited. |
| `ITEMS_v3_2_6.json` | Release metadata: per-item standing, authority pins, corrections, segments and stage hash. An index, not mathematical authority. |
| `references/CURRENT_WORK.md`, `references/CURRENT_WORK_INDEX.json` | Dated, advisory routes to catalog contributions, external companions, research proposals and Serena software/design sources. Their tools and proof texts are not bundled. |
| `legacy/v3.2.5/` | The superseded v3.2.5 kernel, bibliography and skill instructions (`legacy/v3.2.5/SKILL_v3_2_5.md`). **Historical reproduction only.** |
| `PROVENANCE.json`, `MANIFEST.sha256`, `scripts/verify_bundle.py` | Source commit and path for every copied file; checksums; a standalone verifier. |

Route authority in this order:
1. the locked kernel text, including the item's own status line or native-id tag;
2. the lock record covering that item;
3. the bibliography, for citations;
4. implementation evidence (programs, viewers, UI labels), which is evidence only.

Audit reports, cold-pass verdicts and review clearances keep their stated scope. They do not authorize future changes, and they do not upgrade a standing. A checksum or review PASS is not a theorem, lock or promotion.

## Baseline contract (v3.2.0, unchanged in v3.2.6)

Kernel front matter: "Register separation contract (v3.2.0)" and "How to read this document".

- FVLT is atlas-general. The substrate is $\mathcal{A}_{\mathbb{N}} = \{\mathrm{Div}(N) : N > 0\}$, not $\mathrm{Div}(720)$. The 720 material is a worked factorial-shell / 1001 complement instance (Part V).
- Keep registers separate: atlas/Hasse, Vernier/phasor, harmonic exact-conductor, $H_{\mathrm{Hasse}}(N)$, $H_{\mathrm{harm}}(N)$, and application/tooling evidence. Shared divisor labels do not identify the spaces and do not imply a canonical unitary map. ASCII aliases: `H_Hasse(N)`, `H_harm(N)`.
- Use $E_q^{\mathrm{line}}$ for the scalar Ramanujan-line/coherent statistic and $E_q^{\mathrm{full}}$ for full exact-conductor subspace energy. Active Parseval/Plancherel statements use $E_q^{\mathrm{full}}$. Windowed forms must declare support, anchoring, normalization and taper policy.
- The Vernier contact rule is $n_3 \mid t_2 s$ in the finite instrument range. Recovery of $\mathrm{Div}(s)$ is restricted to the reference $t_2 = 1$ specialization.
- The coprime Virasoro/Fock branch (Part II / II.21–II.22) is non-normative research/history. Do not route it as active theorem authority, and do not invoke Stone–von Neumann as established. Corrected mode counts: $\varphi(720)=192$ (paired 96), $\varphi(1001)=720$ (paired 360), $\varphi(720720)=138240$ (paired 69120).
- **Roots-of-unity register discipline (v3.1.18, front matter).** Phases are roots of unity first; degrees and decimals are display annotations. The $\Omega = 2$ ring statement (hexagon/star cosets of $\mu_{12}$, inner $\mu_3$-cosets) is scoped in v3.2.6 to the **constant exponent-two six-prime crystal** (e.g. $N = 30030^2$); the placement depends on the common exponent. Do not transfer it to other exponent profiles.
- Quote each item's own status text (its native-id tag or `**Status:**` line) together with the claim. Part VII / VII.1 lists the frozen v2.2 core vocabulary (unconditional, conditional, empirical, definitional, interpretive, open). Newer items also use compound labels outside that list, such as "not-claimed", "comparator-only", "heuristic-context", "adapted-classical" and "unconditional finite witness". Report those as written; do not collapse them into the six core labels.

## What v3.2.6 adds, and how each item stands

| Items | Kernel location | Standing (as recorded) |
|---|---|---|
| Def II.23.9, Lemma II.23.9a, Rmk II.23.9b, Prop II.23.9c, Cor II.23.9d | Part II / II.23, after II.23.8 | Item-locked by Robin 2026-07-23; folded verbatim (`records/LOCK_RECORD_II_23_9_2026-07-23.md`). Def definitional; Lemma unconditional, adapted; Rmk interpretive; Prop unconditional, adapted; Cor unconditional (given the definitions), project-original. These items carry no native-id tags. |
| Lemma II.5g, Def II.5h, Lemma II.5i, Cor II.5i.1, Cor II.5j, Cor II.5j.1, Prop II.5k | Part II / II.5 | Independently cold-passed and numbered; item-locked by Robin 2026-10-12 (`records/LOCK_RECORD_FAREY_II.5g-k.md`). Each keeps its tagged status. **Prop II.5k is an unconditional finite witness, not a general theorem.** |
| Cor II.23.5c, Def–Prop II.23.5d, Def II.23.5e | Part II / II.23.5 | Item-locked by Robin 2026-10-12 (`records/LOCK_RECORD_GOLDBACH_II.23.5c-e.md`). ATTESTED, machine PASS; **attestation seated: false**. See the Goldbach limits below. |

Corrections in this release. Each is scoped as stated, and none changes a theorem's status:
- **KG-04:** prime support is $\mathcal{P}(N)$ (Rmk 1.6a Warm, and the Part II declared-shell restriction). Notation only.
- **KG-04-VII8:** the VII.8 rows that distinguish $\mathcal{P}(N)$, the power set $\mathcal{P}(S)$, the Goldbach set $P_N$, the prime-counting $\pi(N)$, and $\omega(N)$ from the root of unity $\omega$ and the shell weight $\omega_q$.
- **KG-06:** the S2 efficiency closure recorded under Rmk II.5a Scope. It is closed negative (LOCKED 2026-08-19). The ANL-4 S2 mathematics itself remains unseated.
- **KG-07:** the ALG-5 extension-boundary pointer (Part VII / VII.2).
- **BIB-01:** the [GS20] concordance wording.
- **COMB-M-VII8:** the $\operatorname{comb}(m)$ notation row (Part VII / VII.8).
- **L93-SCOPE:** the exponent-two scope of the $\Omega = 2$ ring statement.

## Limits that must survive every answer

- **Goldbach (II.23.5c–e, III.11).**
  - Binary Goldbach is **not claimed**.
  - Global coverage and prime-surviving fibers stay **conditional on Goldbach** (Thm 6.3, III.11).
  - The items' own clauses stand verbatim: Cor II.23.5c "not-claimed (coverage/density)"; Def–Prop II.23.5d "comparator-only (no bound)"; Def II.23.5e "heuristic-context (pair-density interpretation) + not-claimed (count/coverage/phasor magnitude)".
  - [GS20] supports the singular-series normalization only.
  - The attestation is not seated, and locking did not seat it.
- **$\operatorname{comb}(m)$.** A notation entry only (VII.8): for integer $m \ge 2$, the centered offset set used as the branch set in Def II.23.9 and Cor II.23.9d. It is $\{0, \pm1, \dots, \pm M\}$ for $m = 2M+1$ and $\{\pm1, \pm3, \dots, \pm(2M-1)\}$ for $m = 2M$. It imports no companion hypothesis or result and admits no general-comb result. It is distinct from the local comb $\mathrm{comb}(d)$ of Rmk 9.7k.
- **Centered-comb companion.** It is locked (2026-08-05) at the instrument/bibliography tier, **outside the kernel**. ALG-5 keeps its paired readout and domain. On their common domain its pair is the $m = 2$ specialization only (Part VII / VII.2, "Extension boundary"). **The $m \ge 3$ extension remains EXT at its own gate.** No factoring or quantum advantage is asserted.
- **Unresolved source references.** The II.23.9 dependency list names "ALG-5 (centered m-comb)" and "Def 9.7 (product-torus / Clifford-family shells)". The ALG-5 label refers to the companion family (per the KG-07 pointer), not to the resident pair-only ALG-5. The numeral does not match base Def 9.7, which is the multi-prime divisor-lattice embedding (Part II / II.14). That mismatch was found in a source-reference review outside the kernel (the reviewed II.23.9 graph slice). The intended source is **not identified**, and the locked text is unchanged. Preserve and report the declared dependency list as the kernel states it, and mark these two referents as unresolved. Do not supply a referent, do not treat either label as verified proof support, and do not admit the companion through it.
- **Notation.** $\mathcal{P}(N)$ is the prime-support set, $\pi(N)$ the prime-counting integer (e.g. $\pi(720) = 128$), and $\omega(N) = |\mathcal{P}(N)|$ (e.g. $\omega(720) = 3$). Older text, including the legacy v3.2.5 instructions, writes $\pi(N)$ for prime support. When presenting current mathematics, translate it to $\mathcal{P}(N)$. When quoting or reproducing historical text exactly, keep the original notation and say what it meant.
- **Outside this skill.** Graph tooling and exports, database experiments, candidate research and proposed schema or link rules are not part of the mathematical authority.

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

- **Native-id tags.** Items carry `<!-- id: PREFIX-NUM-SLUG | register: … | status: … | provenance: … | depends: … -->`; there are 186 in v3.2.6. Search by id or label, and read the tag and the subsection's `**Status:**` line before answering.
- **Old labels.** Every subsection keeps its v2.7.14 label beside its Part address (dual-reference convention). Part VII / VII.2a maps old labels to Part addresses; for example, its §9.7 detail table shows the §9.7 cluster split mainly across Part II / II.13–II.18, with pieces in III.7, III.10, V.4, VI.13 and VII.4. The "Post-v3.2.5 working-fold concordance (v3.2.6)" rows cover the new items.
- **Reference sections.** VII.2 theorem/remark/note reference (including the ALG notes); VII.7 open problems; VII.8 notation; VII.10 version history; VII.11 provenance.

## Finding developing work

For newer companion studies, research directions or Serena integration, read `references/CURRENT_WORK.md`, then search `references/CURRENT_WORK_INDEX.json` by catalog ID, KG ID, title or family. The dated index supplies source links, hashes, recorded review standing and scoped included/external/proposed/unassessed relations. Follow only the relevant source; if its pinned bytes are unavailable, request that source rather than substituting a live version. Repository links may require access to the private Idea Catalog.

This is navigation metadata with no mathematical authority. Its historical comparisons targeted an earlier working kernel; their old line numbers, reported standings and action proposals are not current-release findings. Keep the locked v3.2.6 kernel and applicable locks authoritative, retain every negative boundary and unknown, and do not turn an indexed companion/proposal, a test PASS or a merged software PR into admission, schema acceptance or permission to run tooling. The index covers the selected catalog and repository, not all local work.

## Answering discipline

- State each claim with its register and status. Keep proved, unconditional, conditional, definitional, interpretive, heuristic-context and not-claimed apart.
- Quote the kernel for anything load-bearing, with its Part address and label.
- Do not extend a scoped statement beyond its stated scope (exponent profile, domain, specialization, finite witness).
- A finite check, a machine PASS or a viewer output is evidence in its own register. It is not a proof unless the kernel records one.
- **Historical reproduction.** When asked to reproduce or cite v3.2.5 work, use `legacy/v3.2.5/kernel_v3_2_5.md` and `legacy/v3.2.5/bibliography_v3_2_5.md` explicitly, and say that v3.2.5 is superseded. `legacy/v3.2.5/SKILL_v3_2_5.md` documents v3.2.5-era practice. Its summaries are not v3.2.6 authority; its authority-routing line and its $\pi(N)$ prime-support notation are superseded.

## Verification

Run `python scripts/verify_bundle.py` from this folder. `PROVENANCE.json` names the source commit and path for every copied file. The copies are byte-identical to the repository at that commit.

## Version history

- **v3.2.6** (LOCKED by Robin 2026-10-12). Adds:
  - the II.23.9 fold;
  - Farey II.5g–k and Goldbach II.23.5c–e, item-locked with standings preserved;
  - corrections KG-04, KG-04-VII8, KG-06, KG-07, BIB-01, COMB-M-VII8 and L93-SCOPE.

  The full record is in `records/RELEASE_LOCK.md` and kernel VII.10. That record is preserved as committed, so it still says the lock "awaits Codex's final verification". That verification was completed: Codex cleared the release-lock PR (#23) and it was merged as `04fc944`, the release of record.
- **v3.2.5** and earlier: see kernel VII.10 and `legacy/v3.2.5/SKILL_v3_2_5.md`.
