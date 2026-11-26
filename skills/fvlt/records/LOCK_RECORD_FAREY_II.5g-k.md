# Lock record — Farey II.5g–II.5k (LOCKED, Robin 2026-10-12)

**Status: LOCKED.** Robin locked these items on 2026-10-12, together with the assembled v3.2.6 release, based on `main` at `395344841cbff50938c24a923d405b829b4bcaf3`. The standing below is preserved exactly as reviewed; locking fixes the items' text and standing and does not upgrade any status.

## Items and standing (verbatim native-id tags from `kernel/next/kernel.md`, stage `v3.2.6-release-candidate`)

- **Lemma II.5g** (kernel/next line 932):
  ```
  <!-- id: LEM-II.5g-PHASE-REDUCTION | register: lemma | status: unconditional | provenance: cold-passed Farey v0.2 | depends: II.5b, II.5f -->
  ```
- **Definition II.5h** (kernel/next line 955):
  ```
  <!-- id: DEF-II.5h-PHASE-MODE-FAREY-CONTACT-GRAPH | register: definition | status: definitional | provenance: cold-passed Farey v0.2 | depends: II.5g -->
  ```
- **Lemma II.5i** (kernel/next line 1000):
  ```
  <!-- id: LEM-II.5i-EXACT-DENOMINATOR-PARTNER | register: lemma | status: unconditional | provenance: cold-passed Farey v0.2 | depends: II.5h -->
  ```
- **Corollary II.5i.1** (kernel/next line 1037):
  ```
  <!-- id: COR-II.5i.1-CROSS-DENOMINATOR-CONTACT | register: corollary | status: unconditional | provenance: cold-passed Farey v0.2 | depends: II.5i -->
  ```
- **Corollary II.5j** (kernel/next line 1048):
  ```
  <!-- id: COR-II.5j-FAREY-ISOLATION-CRITERION | register: corollary | status: unconditional | provenance: cold-passed Farey v0.2 | depends: II.5i -->
  ```
- **Corollary II.5j.1** (kernel/next line 1062):
  ```
  <!-- id: COR-II.5j.1-ENDPOINT-COMPLEMENT-SYMMETRY | register: corollary | status: unconditional | provenance: cold-passed Farey v0.2 | depends: II.5j -->
  ```
- **Proposition II.5k** (kernel/next line 1145):
  ```
  <!-- id: PROP-II.5k-CONTACT-COUNT-STRICT-REFINEMENT | register: proposition | status: unconditional finite witness | provenance: cold-passed Farey v0.2 | depends: II.5h, II.5j -->
  ```

## Pinned authority and fold source

| Role | Path (under `kernel/inputs/2026-10-11/sources/`) | SHA-256 |
|---|---|---|
| authority | `candidates/TERRA_COLD_PASSED_FINAL_KERNEL_FOLD_2026-07-24/04_ROBIN_NUMBERING_RECORD.md` | `392cc8448a15af91d9fdd3e1049f73bab1822e17d945f212039599f8181e2bac` |
| authority | `candidates/TERRA_COLD_PASSED_FINAL_KERNEL_FOLD_2026-07-24/final_packets/farey_v0_2/CLAUDE_COLD_PASS_VERDICT_FAREY_ISOLATION_V0_2_2026-07-24.md` | `30efdcd384172bba85cbb8bb1d02095b6fc3bdbdccf083048f9fdc32c9cfcdb0` |
| authority | `candidates/TERRA_COLD_PASSED_FINAL_KERNEL_FOLD_2026-07-24/outputs/ROBIN_RELEASE_GATE.md` | `3440230bedd6bc07b90dd4ee0d1a0f14baa0210dd31f5d342a8b83ca0d58bce0` |
| fold source | `candidates/TERRA_COLD_PASSED_FINAL_KERNEL_FOLD_2026-07-24/final_packets/farey_v0_2/KERNEL_CANDIDATE_farey_isolation_law_v0_2_REBASED_v3_2_5.md` | `79aa00e9403f8493341753a0c26b877e95c4912b081686db0c49ced2be406104` |

## Standing carried into the lock

- Independently cold-passed (Claude cold-pass verdict, pinned above) and numbered by the 2026-07-24 numbering record.
- The kernel/next text is the mechanical fold of the pinned candidate: wrapper removal, labels, IDs, dependencies and placement only (release gate, item 4).
- Each item keeps its native-id status as tagged above. Proposition II.5k is an "unconditional finite witness", not a general theorem.
- Locking fixes these items' text and standing. It does not upgrade any status.

## Lock statement

Robin, 2026-10-12 (verbatim, in Robin's chat with Claude):

> I lock the assembled FVLT v3.2.6 release based on main 3953448, including the confirmed Farey and Goldbach item locks, preserving their reviewed standings and limitations. Prepare the release-lock PR for Codex’s final verification. Keep #18 held until the release is finalized.

Repinning or changing these items after this lock requires a new lock event with its own record.
