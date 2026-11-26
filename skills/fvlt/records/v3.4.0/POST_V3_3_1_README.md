# FVLT v3.4.0 on the locked v3.3.1: Rmk 9.7j.1 added

**Status: v3.4.0, LOCKED release of record**, saphir 2026-11-03: "v3.4.0, lock it". It supersedes v3.3.1. Plan status `LOCKED_RELEASE_v3.4.0`. Release records: `docs/releases/v3.4.0/RELEASE_LOCK.md` (and the candidate record `RELEASE_CANDIDATE.md`, kept as history). Before the lock this folder held the same content as the release candidate `516fbbc55b15110dcb3c098004ebd7d4ba1ae04d15fb2255d486d8cdcedd555d`, independently label-verified; the lock changed release metadata only (section "Lock round (2026-11-03)" below). The folder keeps its name `kernel/post-v3.3.1/` (precedent: v3.3.1 lives in `kernel/post-v3.3.0/`).

*Earlier status (label round, kept as history): v3.4.0 release candidate; lock pending saphir. saphir assigned the label on 2026-11-03, answering the proposed v3.4.0 (a minor release) with "lets go"; until the lock v3.3.1 stayed the release of record; plan status `RELEASE_CANDIDATE_v3.4.0`.*

*Earlier status (before the label round, kept as history): draft, version label unassigned, not locked or released; a proposed minor release, label and lock saphir's ("We aren't there yet", 2026-11-03); plan status `DRAFT_VERSION_UNASSIGNED`.*

- **Policy:** `docs/governance/KERNEL_ITEM_ADDITIONS_v0_2.md`, **adopted by saphir 2026-11-03** ("1. Yes, adopt."). This plan is its first use (rule 10), ordered by saphir the same day ("2. Go after 1.").
- **Predecessor:** `kernel/post-v3.3.0/kernel.md`, v3.3.1, LOCKED by saphir 2026-10-30, SHA-256 `e49533088843e2cd0a1c531c4d8ba113ea30113e8135a15c17c040bdfca3e0e0` (same bytes at `0df7105`, `bdc725b` and this branch's HEAD). It and its plan `kernel/post-v3.3.0/CORRECTIONS.json` are unchanged.
- **v3.4.0 (LOCKED):** `kernel.md`, SHA-256 `0d6beee233602502576c1d0eedfe5a586e66f1b4e4b8a1858c39189d872ec1a2`, 600,959 bytes, 187 native tags (after the lock round, below). Release candidate (label round): `516fbbc55b15110dcb3c098004ebd7d4ba1ae04d15fb2255d486d8cdcedd555d`, 600,931 bytes. Earlier drafts: `eb898511022c25d0ab43d836ca238893ca7452b3d8fd58f5e3abde0120ef859f` (fix round 1, 600,820 bytes; the content the fix-1 verifier checked) and `07ff8b9fdbe57fafd37e3b815115cd2071b450052f6a09da30dfc686db3ef408` (first build, 600,779 bytes).
- **Plan:** `CORRECTIONS.json`, 8 replacements against the predecessor and one declared native item addition. `ASSEMBLY.json` lists the 17 active byte segments and `CORRECTIONS.diff` is the full diff. The 186 inherited native identities keep their order, the one addition sits directly after its anchor, and no existing native tag changes.
- **Item index:** `ITEMS_ADDED.json` (rule 8), with the pinned Lean link (rule 9).

Check with `python tools/build_successor_kernel_v2.py --folder kernel/post-v3.3.1 --check`. **The v1 tool refuses this plan** (`ValueError: Native identities or their order changed`), as the policy says it will; v2 is the builder. Receipts are in `BUILD_NOTES.md`.

## What it applies

The candidate Rmk 9.7j.1 v0.1.2 (`docs/investigations/RMK_9_7j_1_symmetric_chains_2026-11-03/FVLT_SCD_CANDIDATE_v0_1_2_20261103/CANDIDATE_RMK_9_7j_1_SYMMETRIC_CHAINS_v0_1_2.md`, sha256 `fd13dc858a80ba76704e25f96b8b7c726174107b9cffa34766363dc57ea527bf`), with the item identity saphir chose (R-4):

```
<!-- id: RMK-9.7j.1-SYMMETRIC-CHAIN-DECOMPOSITION | register: remark | status: unconditional (classical, cited) + interpretive (address) | provenance: adapted-classical | depends: 9.7j -->
```

| Replacement | What it does |
|---|---|
| `SCD-RMK-9.7j.1-ITEM` | Inserts the tag and Rmk 9.7j.1 after Rmk 9.7j's status paragraph, before the II.17 §G routing note. Identity order: 9.7j, 9.7j.1, 9.7k. No byte of Rmk 9.7j changes |
| `SCD-CONCORDANCE-VII2a` | VII.2a: a new table "Post-v3.3.1 item additions (draft, label unassigned)" with the row for Rmk 9.7j.1 (rule 8); the heading said "(successor draft, label unassigned)" before fix round 1 |
| `SCD-BIB-VII9` | VII.9: a short note naming the three works the remark cites |
| `SCD-RELEASE-SCOPE` | Release scope: 186 inherited identities in order, plus one declared addition, 187 in total |
| `POST331-HEADER-TITLE`, `-HEADER-VERSION`, `-CHANGELOG`, `POST331-FOOTER` | Release metadata for an unlabelled draft, following the v3.3.1 draft at `f85e62d`. The v3.3.1 version record and changelog stay as history |

## Wording adaptations (candidate v0.1.2 → kernel text)

The mathematics and every claim are as in v0.1.2. Changes are to form only:
1. **Heading:** "Remark 9.7j.1 (Symmetric chain decomposition by the diagonal tensor rule)" → "Remark 9.7j.1 (Symmetric Chain Decomposition by the Diagonal Tensor Rule)", the title case of Rmk 9.7j and 9.7k.
2. **Notation:** Unicode math → the kernel's LaTeX, e.g. "N = p₁^a₁ ⋯ pₘ^aₘ" → `$N = p_1^{a_1} \cdots p_m^{a_m}$`; "H_Hasse(N) = ⊗ᵢ ℂ^{aᵢ+1}" → `$H_{\mathrm{Hasse}}(N) = \bigotimes_i \mathbb{C}^{a_i+1}$`; "sl₂" → `$\mathfrak{sl}_2$`; "Ẽ, F̃" → `$\tilde{E}, \tilde{F}$`; "Ω(bottom)" → `$\Omega(\mathrm{bottom})$`; "W_⌊Ω_max/2⌋" → `$W_{\lfloor \Omega_{\max}/2 \rfloor}$`; "Then set E = Σ Eᵢ" → "Then set $E = \sum_i E_i$". The module decomposition stays on its own line, as `$$…$$` inside item 3.
3. **Review labels dropped:** "**Declared structure (R-1, R-2).**" → "**Declared structure.**"; "**Strings index the summands; they do not span them (R-1).**" → without "(R-1)"; "The bracket construction for products of chains is standard (R-3)." → without "(R-3)". These are check-spec fix labels (history).
4. **Credit dropped:** "*Proof* (from the line review)." → "*Proof.*" Credit stays in the candidate.
5. **Check reference:** "S-03c (the Appendix B list)" → "S-03c (the check spec's Appendix B list)". The check names S-02, S-03c and S-03d are kept; the new evidence sentence says where they are.
6. **Status block:** the bulleted "*Status.*" list → one `*Status: …*` paragraph, the format of Rmk 9.7j. The sentences are the candidate's, in order; "Greene and Kleitman (1976) give the Boolean-lattice case" is joined to the preceding sentence with a semicolon; "see the survey arXiv 1809.00114" → "see the survey arXiv:1809.00114".
7. **Blank lines** before lists, as in Rmk 9.7j.
8. **Added:** one *Evidence* sentence (not a markdown link): the checks are in `docs/investigations/RMK_9_7j_1_symmetric_chains_2026-11-03/`, and the Lean link in `kernel/post-v3.3.1/ITEMS_ADDED.json` covers finite instances and general rank lemmas only and does not prove the remark in general.
9. **Reading direction (fix round 1, fix 1):** bracket-rule step 2, "and pair each $1$ with the nearest unpaired $0$ to its left" → "and read the word from left to right: pair each $1$, in turn, with the nearest unpaired $0$ to its left". A clarification, not new mathematics: it is the reading of the Lean module, of Sage's tensor convention (S-02) and of every check. The candidate leaves the order unstated. Read right to left, F̃ changes (Ẽ and the string bottoms do not), so Ẽ and F̃ stop being inverse (C1) and the sentence identifying them with the crystal operators of B(a₁) ⊗ ⋯ ⊗ B(aₘ) fails, e.g. N = 30, d = 15 (statement-match review §2.1; precision from the fix-round-1 verify, VERF-03).
10. **Claims named in the status paragraph (fix round 1, fix 5):** "for 1–3 and 5" → "for claims 1–3 and 5"; "4 is an elementary precision statement" → "Claim 4 is an elementary precision statement". The remark has two numbered lists (bracket-rule steps 1–4, claims 1–5); the status refers to the claims.

Not carried into the kernel: the candidate's front matter and history, the "Item identity" block (the tag is applied), the proof sketch, the checks table, "Not done" and the credits.

## Fix round 1 (2026-11-03)

Ordered by saphir 2026-11-03 ("Do it"), one pass of fixes before the label. The draft stays unlabelled and unlocked (`DRAFT_VERSION_UNASSIGNED`). Driven by two reviews:
- the plan verify report `docs/reviews/post-v3.3.1-rmk-9.7j.1_2026-11-03/VERIFY_REPORT.md` (sha256 `746744b9…014bc`, PASS WITH FLAGS), flags F-1, F-4, F-5 (F-6 left as is, below);
- the statement-match review (F-1), copied byte for byte into `docs/reviews/post-v3.3.1-rmk-9.7j.1_2026-11-03/statement_match/` (record `STATEMENT_MATCH_REVIEW.md`, sha256 `d8ebda6b…72d7`, verdict MATCH WITH CORRECTIONS; all 25 lines of its `SHA256SUMS.txt` verify in the copy), §2.1, §6 and §7.

Draft `07ff8b9f…f408` → `eb898511022c25d0ab43d836ca238893ca7452b3d8fd58f5e3abde0120ef859f`. Only replacement `new` texts and plan metadata changed; every `old` text, the tag and the 186 inherited tags are unchanged. Ten kernel lines change, all listed in `BUILD_NOTES.md`.

| Fix | Where | Old → new |
|---|---|---|
| 1 (reading direction; review §2.1) | `SCD-RMK-9.7j.1-ITEM`, bracket rule step 2 | "and pair each $1$ with the nearest unpaired $0$ to its left." → "and read the word from left to right: pair each $1$, in turn, with the nearest unpaired $0$ to its left." |
| 2 (Lean scope; review §6) | `ITEMS_ADDED.json`, `scope` and `lean_version` | All six corrections: (1) the three `_C1` theorems are assembled from their decided halves via `C1_of_halves`, the other 35 instance theorems are plain `decide`; (2) Div(N) is encoded as the exponent box, tied to the integer N by the `_factorisation` theorems only (primality and the divisor bijection not formalised); (3) C5 is stated for 0 ≤ r ≤ Ω_max; (4) not formalised also lists rank-symmetry, rank-unimodality and Sperner, the 720 module isomorphism, claims 3–5 (was "claims 3-4"), the Sage crystal identification and the equivalence of the bracket rule's two readings; (5) the stack scan = left-to-right reading is proved in the review record (§2.1), not in Lean; (6) `lean_version` adds the byte-identical scout recompile SMR-01. "general rank lemmas" → "general one-step rank lemmas" |
| 3 (review field; review §7) | `ITEMS_ADDED.json`, `statement_match_review` | `"pending"` → the reviewer's proposed object, with `record.path` the repository copy and its sha256 `d8ebda6b…72d7`, plus the folder's `SHA256SUMS.txt` pin, `corrections_applied`, and `reviewed_against` (made against `07ff8b9f…`; only fix 1 and the wording fixes 4–5 changed kernel text since; to be rechecked by the next verifier). `status_effect: "none"` kept. `statement_match_note` "None exists yet…" → "Reviewed 2026-11-03 against kernel 07ff8b9f…; the builder's pin of candidate v0.1 does not affect the match (record section 1)." |
| 4 (F-4, "successor draft" for changes from v3.3.1) | title, version paragraph, release scope, changelog comment, VII.2a heading and row, VII.9 note, footer | Title "FVLT — successor draft on v3.3.1, label unassigned" → "FVLT — post-v3.3.1 draft, label unassigned"; "**Version:** successor draft on the locked v3.3.1;" → "**Version:** post-v3.3.1 draft, on the locked v3.3.1;"; "and this successor draft inserts one declared native item" → "and this post-v3.3.1 draft inserts …"; "<!-- successor draft changelog" → "<!-- post-v3.3.1 draft changelog"; "### Post-v3.3.1 item additions (successor draft, label unassigned)" → "(draft, label unassigned)"; "new in this successor draft;" → "new in the post-v3.3.1 draft;"; "**Successor-draft citations (Rmk 9.7j.1).**" → "**Post-v3.3.1 draft citations (Rmk 9.7j.1).**"; footer "end FVLT successor draft on v3.3.1" → "end FVLT post-v3.3.1 draft". The kept v3.3.0/v3.3.1 uses (the release-scope definition and the edit records) are untouched; "successor draft" now occurs in the draft exactly as often as in the predecessor |
| 5 (F-5) | status paragraph of Rmk 9.7j.1 | "for 1–3 and 5" → "for claims 1–3 and 5"; "4 is an elementary precision statement" → "Claim 4 is an elementary precision statement" |
| 6 (consistency) | *Evidence* sentence, version paragraph, VII.2a row | Checked: none repeats a scope statement fix 2 corrects (none says "plain decide"; "finite instances and general rank lemmas only" stays true). No change |
| plan metadata | `CORRECTIONS.json` | `draft_sha256`; the `lean` field "statement-match review pending" → "statement-match review MATCH WITH CORRECTIONS (…), its scope corrections applied …"; `review_sources`: "This plan itself is not yet reviewed." → "The plan was then verified and fixed in fix round 1 (the next two entries).", plus entries for the verify report and the statement-match review |

**F-6 left as is.** The kernel text names `kernel/post-v3.3.1/ITEMS_ADDED.json` in three places. The precedent is that a successor folder keeps its name at lock (v3.3.1 lives in `kernel/post-v3.3.0/`, and its kernel text names `kernel/post-v3.3.0/CORRECTIONS.json`), so the paths stay valid at lock.

## Label round (2026-11-03)

saphir was asked for the label (proposed: v3.4.0, a minor release) and answered "lets go". The lock was not given. This round writes the label and the release-candidate standing into the release metadata, and nothing else: the mathematics, the text of Rmk 9.7j.1, its tag, every `old` text and the 186 inherited tags are unchanged. Draft `eb898511…859f` → release candidate `516fbbc55b15110dcb3c098004ebd7d4ba1ae04d15fb2255d486d8cdcedd555d`. Builder receipts: `BUILD_NOTES.md`, "Label round".

**Kernel text** (8 lines change; the line count stays 5,624 LF-terminated lines):

| Line | Replacement | Old → new |
|---|---|---|
| 3 | `POST331-HEADER-TITLE` | "## FVLT — post-v3.3.1 draft, label unassigned (on the v3.2.0 …)" → "## FVLT — v3.4.0 (on the v3.2.0 …)", the form of the v3.3.0 candidate (`e2d95c4`) and the v3.3.1 lock (`857ac96`) |
| 5 | `POST331-HEADER-VERSION` | "**Version:** post-v3.3.1 draft, on the locked v3.3.1; version label unassigned; not locked or released (a proposed minor release; label and lock pending saphir)." → "**Version:** 3.4.0 (minor release on the locked v3.3.1; label assigned by saphir 2026-11-03: "lets go", in answer to the proposed v3.4.0; **release candidate; lock pending saphir**; release records in `docs/releases/v3.4.0/`). Until the lock, v3.3.1 stays the release of record." The rest of the paragraph and the v3.3.1 record are unchanged |
| 7 | `SCD-RELEASE-SCOPE` | "and this post-v3.3.1 draft inserts one declared native item" → "and v3.4.0 inserts one declared native item" |
| 9 | `POST331-CHANGELOG` | "<!-- post-v3.3.1 draft changelog (label unassigned; not locked; proposed minor release, label and lock pending saphir): add …" → "<!-- v3.4.0 changelog (minor release on the locked v3.3.1; label assigned by saphir 2026-11-03: "lets go", in answer to the proposed v3.4.0; release candidate, lock pending saphir; release records in docs/releases/v3.4.0/): add …" |
| 4691 | `SCD-CONCORDANCE-VII2a` | "### Post-v3.3.1 item additions (draft, label unassigned)" → "### Post-v3.3.1 item additions (v3.4.0)" |
| 4697 | `SCD-CONCORDANCE-VII2a` | "new in the post-v3.3.1 draft;" → "new in v3.4.0;" |
| 5463 | `SCD-BIB-VII9` | "**Post-v3.3.1 draft citations (Rmk 9.7j.1).**" → "**v3.4.0 citations (Rmk 9.7j.1).**" |
| 5624 | `POST331-FOOTER` | "end FVLT post-v3.3.1 draft, label unassigned (v3.2.0 …)" → "end FVLT v3.4.0 kernel (v3.2.0 …)" |

After the round, "post-v3.3.1 draft", "label unassigned" and "unassigned" occur nowhere in `kernel.md`. "post-v3.3.1" remains only in the path `kernel/post-v3.3.1/…` (F-6, kept) and in the VII.2a heading "Post-v3.3.1 item additions (v3.4.0)", where it names the items added after v3.3.1. "successor draft" occurs 8 times, as in the predecessor (inherited uses only). "LOCKED" occurs 18 times, as in the predecessor: every one is inherited and refers to v3.3.1 or earlier. Nothing claims a lock for v3.4.0.

**Plan `CORRECTIONS.json`** (builder-ignored metadata besides the `new` texts above):

| Field | Old → new |
|---|---|
| `status` | `DRAFT_VERSION_UNASSIGNED` → `RELEASE_CANDIDATE_v3.4.0` |
| `draft_sha256` | `eb898511…859f` → `516fbbc5…555d` |
| `version_label` | "unassigned; proposed minor release; label and lock are saphir's" → "v3.4.0 (minor release on the locked v3.3.1; label assigned by saphir 2026-11-03: "lets go", in answer to the proposed v3.4.0; release candidate, lock pending saphir)" |
| `note` of the four `POST331-*` hunks | "Unlabelled-draft …" → "v3.4.0 … (release candidate, lock pending saphir) …", each saying what the label round changed |
| `review_sources` | one entry added: the fix-round-1 verify report (`4bc52f4d…3390`, PASS WITH FLAGS) |
| `release` | new block, as in the v3.3.0 candidate (`e2d95c4`): label, status "release candidate (lock pending saphir)", predecessor, `label_assigned` (saphir, 2026-11-03, "lets go", in answer to the proposed v3.4.0), `lock`: "pending saphir; not given", the content verified (`eb898511…`, fix-1 verify), the release-metadata units, `release_docs`, and an empty `item_lock_interactions` |
| `ASSEMBLY.json` `status` | regenerated by the builder from the plan: `RELEASE_CANDIDATE_v3.4.0` |

Unchanged: every `old` text, the item replacement `SCD-RMK-9.7j.1-ITEM` (its `new`, `note` and `kind`), `allowed_native_item_additions`, `allowed_native_tag_changes` (empty), the base pins, `predecessor`, `source_candidate`, `item_index`, `lean` and `policy` (its "We aren't there yet" is history).

**`ITEMS_ADDED.json`:**

| Field | Old → new |
|---|---|
| `status` | `DRAFT_VERSION_UNASSIGNED` → `RELEASE_CANDIDATE_v3.4.0` |
| `kernel.label` | new: "v3.4.0 (minor release on the locked v3.3.1; label assigned by saphir 2026-11-03; release candidate, lock pending saphir)" |
| `kernel.sha256` | `eb898511…859f` → `516fbbc5…555d` |
| `location.tag_byte_offset` | 244233 → 244409 (header lines before the tag changed length; the tag line stays 2124) |
| `concordance` | "table 'Post-v3.3.1 item additions (draft, label unassigned)'" → "table 'Post-v3.3.1 item additions (v3.4.0)'" |
| `statement_match_review.reviewed_against` | "the current draft is eb898511…" → "the fix-round-1 draft is eb898511…, labelled in the label round of 2026-11-03 as the v3.4.0 release candidate 516fbbc5…, release metadata only"; and after the fix list: "the label round then changed release metadata only (the item text is byte-identical)" |

`status_effect` stays `none` (link and review). The path `kernel/post-v3.3.1/ITEMS_ADDED.json` stays (F-6).

**Open follow-ups below, after this round:** 1 (label: done; lock: saphir's, open); 2 (release records: done, `docs/releases/v3.4.0/`, with the item-lock list; no `RELEASE_LOCK.md`, as there is no lock); 3 (skill bundle: see `RELEASE_CANDIDATE.md`, open item (c); the repository bundle and its test are not affected and must not be set to 187); 4 (statement-match: carried over to `eb898511…` by the fix-1 verify; the label round does not touch the item); 5 (bibliography: open); 6 (independent review: done twice, plan verify and fix-1 verify; this label round itself is for the owner's independent check); 7 (policy wording: the plan now uses the label v3.4.0, as the policy did); 8 (`verify_kernel_next.py`: now PASS, after PR #74 restored the W1 pin, `a307861`).

## Lock round (2026-11-03)

saphir gave the lock word on 2026-11-03: "v3.4.0, lock it". Before it, saphir was told of the label verifier's flag F-1 (policy v0.2, line 63, lists "update the skill-bundle count to 187" as a v3.4.0 follow-up; it does not apply, because the repository bundle `skills/fvlt` is the v3.2.6 package, where 186 is correct, and the v3.4.0 skill is a new local package built after the lock) and of F-3 (the VII.9 bibliographic details are not checked against the papers). F-1 was reported to saphir before the lock word, and the lock was given with it reported. F-3 stays open, a limitation carried by the release. This round converts the release candidate to the locked release in the form of the v3.3.1 lock (`857ac96`), and nothing else: the mathematics, the text of Rmk 9.7j.1, its tag, every `old` text, the title and footer, and the 186 inherited tags are unchanged. Release candidate `516fbbc5…555d` → v3.4.0 `0d6beee233602502576c1d0eedfe5a586e66f1b4e4b8a1858c39189d872ec1a2` (600,959 bytes). Builder receipts: `BUILD_NOTES.md`, "Lock round". Release record: `docs/releases/v3.4.0/RELEASE_LOCK.md`.

**Kernel text** (2 lines change; the line count stays 5,624 LF-terminated lines):

| Line | Replacement | Old → new |
|---|---|---|
| 5 | `POST331-HEADER-VERSION` | "**Version:** 3.4.0 (minor release on the locked v3.3.1; … v3.4.0; **release candidate; lock pending saphir**; release records in `docs/releases/v3.4.0/`). Until the lock, v3.3.1 stays the release of record. It adds one declared native item to the locked v3.3.1 bytes (SHA-256 `e4953308…e0e0`) under …" → "**Version:** 3.4.0 (current; minor release on the locked v3.3.1; … v3.4.0; **LOCKED release of record** by saphir 2026-11-03: "v3.4.0, lock it"; release records in `docs/releases/v3.4.0/`). It supersedes v3.3.1 (SHA-256 `e4953308…e0e0`, LOCKED by saphir 2026-10-30) and adds to its bytes one declared native item under …", the form of the v3.3.1 lock. The rest of the paragraph and the v3.3.1 record (history) are unchanged |
| 9 | `POST331-CHANGELOG` | "<!-- v3.4.0 changelog (…; release candidate, lock pending saphir; release records …" → "<!-- v3.4.0 changelog (…; LOCKED by saphir 2026-11-03: "v3.4.0, lock it"; release records …" |

After the round, "release candidate", "lock pending" and "Until the lock" occur nowhere in `kernel.md`. "LOCKED" occurs 21 times (18 inherited, on v3.3.1 or earlier, plus three new: v3.4.0's "LOCKED release of record" on line 5, "LOCKED by saphir 2026-10-30" for the superseded v3.3.1 on line 5, and the changelog's "LOCKED by saphir 2026-11-03" on line 9).

**Plan `CORRECTIONS.json`:**

| Field | Old → new |
|---|---|
| `status` | `RELEASE_CANDIDATE_v3.4.0` → `LOCKED_RELEASE_v3.4.0` (the form of `LOCKED_RELEASE_v3.3.1`) |
| `draft_sha256` | `516fbbc5…555d` → `0d6beee2…c1a2` |
| `version_label` | "…; release candidate, lock pending saphir)" → "…; LOCKED release of record by saphir 2026-11-03: "v3.4.0, lock it")" |
| `note` of `POST331-HEADER-TITLE`, `-HEADER-VERSION`, `-CHANGELOG` | a "Lock round" sentence appended to each, saying what the lock round changed (for the title: nothing in its text) |
| `release.status` | "release candidate (lock pending saphir)" → "locked" |
| `release.predecessor.status` | "…; stays the release of record until the v3.4.0 lock" → "…; superseded by v3.4.0 (saphir 2026-11-03)" |
| `release.lock` | "pending saphir; not given" → saphir, 2026-11-03, "v3.4.0, lock it", with what was reported before the lock (F-1, F-3) and the scope of the lock round |
| `release.standing`, `release.not_included` | new: no status label change on any inherited item, no standing upgraded; no change to the repository skill bundle, the v3.4.0 skill package built locally after the lock |
| `ASSEMBLY.json` `status` | regenerated by the builder from the plan: `LOCKED_RELEASE_v3.4.0` |

Unchanged: every `old` text, the item replacement `SCD-RMK-9.7j.1-ITEM` (its `new`, `note` and `kind`), the `new` texts of the title, footer, `SCD-RELEASE-SCOPE`, `SCD-CONCORDANCE-VII2a` and `SCD-BIB-VII9`, `allowed_native_item_additions`, `allowed_native_tag_changes` (empty), the base pins, `predecessor`, `review_sources`, `source_candidate`, `item_index`, `lean`, `policy`, and `release.content_verified` (history of the label round).

**`ITEMS_ADDED.json`:** `status` `RELEASE_CANDIDATE_v3.4.0` → `LOCKED_RELEASE_v3.4.0`; `kernel.label` "…; release candidate, lock pending saphir)" → "…; LOCKED release of record by saphir 2026-11-03: "v3.4.0, lock it")"; `kernel.sha256` `516fbbc5…555d` → `0d6beee2…c1a2`; `location.tag_byte_offset` 244409 → 244437 (lines 5 and 9 grew by 28 bytes; the tag line stays 2124). The reviewed scope text and the statement-match record (including `reviewed_against`, which names `516fbbc5…` as the release candidate) are unchanged.

**Elsewhere:** `kernel/post-v3.3.0/README.md` gains a "Superseded (2026-11-03)" paragraph at the top (the form `857ac96` used for `kernel/successor/README.md`); nothing else in that folder changes. `docs/releases/v3.4.0/`: new `RELEASE_LOCK.md`; `scripts/item_lock_check.py` `release` string → the locked form; `ITEM_LOCK_INTERSECTIONS.json` regenerated (only `release` and `plan_sha256` differ; `in_lock_spans` stays empty). `RELEASE_CANDIDATE.md` is kept unchanged as history, as the v3.3.0 lock kept its `RELEASE_CANDIDATE.md`.

**Open follow-ups after the lock:** 1 (label and lock: done); 2 (release records: done, `docs/releases/v3.4.0/RELEASE_LOCK.md`); 3 (skill bundle: the repository bundle stays the v3.2.6 package at 186; the v3.4.0 skill package is built locally after the lock); 5 (bibliography: open, F-3; full entries also open); the lock round was independently verified, PASS WITH FLAGS (`docs/reviews/post-v3.3.1-rmk-9.7j.1_2026-11-03/lock_verify/VERIFY_REPORT.md`, `5f09ded13ebb4772117675b35dc12076f4db26fec6ae9ea91d5d0ec023196f78`).

## Tables that list Rmk 9.7j

| Table | Complete? | Action |
|---|---|---|
| VII.2 anchor map ("key load-bearing theorems by v3.0 destination") | No: a selection (e.g. Rmk 9.7f and 9.7h are absent) | No row added |
| VII.2a "§9.7 cluster detail (subsumed landing table)" | Complete for the v2.7.x §9.7 items | No row added: Rmk 9.7j.1 has no v2.7.x label. Its concordance row is in the new additions table |
| VII.2a "Post-v3.2.5 working-fold concordance (v3.2.6)" | The v3.2.6 additions | Not edited. Its convention (a separate table per working fold of additions, columns Item / Kernel home / Status) is followed by the new table |

The II.17 subsection header (`**Source:** Rmk 9.7j (v2.7.14); …`) is a v2.7.x back-pointer and was left unchanged. The VII.8 notation tables gain no entries; the remark defines its symbols ($E$, $F$, $H$, $\tilde E$, $\tilde F$, $W_r$, $B(a)$) locally.

## Constraints honoured

- No locked bytes edited: `kernel/post-v3.3.0/` and `kernel/successor/` are unchanged.
- The text this plan replaces contains no item-locked text. Rmk 9.7j is not item-locked, and no lock word occurs in II.17 other than in "per-block". The VII.2a insertion lies between two tables and edits no row. A copy of `docs/releases/v3.3.1/scripts/item_lock_check.py` adapted to this plan (job V340-06, in `BUILD_NOTES.md`) finds no replacement in any of the 17 v3.2.7 item-lock spans.
- No status label changes; the added item enters with the status in its tag (rule 7), and nothing is upgraded. `allowed_native_tag_changes` is empty.
- The Lean link is outside the tag, in `ITEMS_ADDED.json`, with `status_effect: none` (rule 9).
- `kernel/next/ITEMS.json` and `kernel/next/bibliography.md` are untouched (rule 8).
- No tool, test, skill or docs file is edited. v1 refuses this plan; v2 builds it.

## Open follow-ups for lock time (draft era, kept as history; current list: "Open follow-ups after the lock" above)

1. **Label and lock:** saphir's. On lock, the title, version paragraph, changelog and footer hunks get the label (as at `857ac96` for v3.3.1), and the plan status changes.
2. **Release records** in `docs/releases/<label>/`, including the item-lock intersection list. It should record that this plan edits no item-locked text.
3. **Skill bundle:** `skills/fvlt/v3.2.6/fvlt/scripts/verify_bundle.py` pins `NATIVE_IDS = 186` and `tools/tests/test_fvlt_skill_bundle.py` asserts 186. Neither is edited here. Both check the v3.2.6 bundle against `kernel/next/kernel.md`, so they do not read this draft and do not fail because of it; a bundle for this release would need its own count (187). The installed FVLT skills describe locked releases (v3.3.0 or v3.3.1, depending on the copy); replacing them needs saphir's checkpoint.
4. **Lean statement-match review** (rule 9): done in fix round 1 (verdict MATCH WITH CORRECTIONS; record in `docs/reviews/post-v3.3.1-rmk-9.7j.1_2026-11-03/statement_match/`). It was made against the previous draft `07ff8b9f…`; the next verifier should recheck it against the current draft (only fixes 1, 4 and 5 changed kernel text since).
5. **Bibliography:** full entries for de Bruijn–van Ebbenhorst Tengbergen–Kruyswijk (1951), Greene–Kleitman (1976) and Kashiwara (arXiv:1809.00114) belong in the working bibliography, which this plan does not edit. The journal details in the VII.9 note were given in the build order and match my own knowledge; I did not check them against an outside source. The Kashiwara survey is cited by arXiv number only, as in the candidate.
6. **Review of this plan:** the plan, the adaptations above and the draft bytes need an independent check before saphir decides.
7. **Policy wording:** the policy's follow-up list calls this plan "v3.4.0". This draft does not use that label.
8. **Pre-existing, not caused by this plan:** `tools/verify_kernel_next.py` (completed-stage, with the input roots of `docs/releases/v3.3.0/RELEASE_LOCK.md`) fails on this branch's HEAD and on main `bdc725b`. `docs/errata/next/W1_II8_def52_weighted_ramanujan.md` was edited in `d5280b2` (2026-10-30), so its sha256 `3f86702b…` no longer matches the `52939de8…` pinned in `kernel/next/ITEMS.json`. The `--partial` structural check passes. Neither file is in this plan's scope.
