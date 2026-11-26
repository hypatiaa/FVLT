# Lock record — Goldbach II.23.5c–e (LOCKED, Robin 2026-10-12)

**Status: LOCKED.** Robin locked these items on 2026-10-12, together with the assembled v3.2.6 release, based on `main` at `395344841cbff50938c24a923d405b829b4bcaf3`. The standing below is preserved exactly as reviewed; locking fixes the items' text and standing and does not upgrade any status.

## Items and standing (verbatim native-id tags from `kernel/next/kernel.md`, stage `v3.2.6-release-candidate`)

- **Corollary II.23.5c** (kernel/next line 2776):
  ```
  <!-- id: COR-II.23.5c-CENTERED-GOLDBACH-PHASOR-TRAJECTORY | register: corollary | status: unconditional (finite-sum identity, including empty fiber) + definitional (prime-selected index set) + not-claimed (coverage/density) | provenance: adapted (classical centered exponential-pair identity) over original (FVLT summed-trajectory seat and register split) | depends: II.23.2, II.23.5a, II.23.5b, III.11, VI.3a -->
  ```
- **Definition-Proposition II.23.5d** (kernel/next line 2838):
  ```
  <!-- id: DEF-II.23.5d-CONTINUOUS-COPRIME-REFERENCE | register: definition-plus-proposition | status: definitional (continuous interpolation) + unconditional (pair factorization and integer Ramanujan reduction) + comparator-only (no bound) | provenance: adapted (classical Ramanujan sum) over original (FVLT continuous-reference seat and carrier comparison) | depends: 5.7a, II.23.5a, II.23.5c -->
  ```
- **Definition II.23.5e** (kernel/next line 2888):
  ```
  <!-- id: DEF-II.23.5e-NORMALIZED-GOLDBACH-LOCAL-FACTOR | register: measurement-comparator | status: unconditional (finite product identities) + adapted-classical (Hardy-Littlewood local factor) + heuristic-context (pair-density interpretation) + not-claimed (count/coverage/phasor magnitude) | provenance: adapted | depends: II.23.5b, II.23.5c, VI.3a -->
  ```

## Pinned authority and fold source

| Role | Path (under `kernel/inputs/2026-10-11/sources/`) | SHA-256 |
|---|---|---|
| authority | `candidates/TERRA_COLD_PASSED_FINAL_KERNEL_FOLD_2026-07-24/04_ROBIN_NUMBERING_RECORD.md` | `392cc8448a15af91d9fdd3e1049f73bab1822e17d945f212039599f8181e2bac` |
| authority | `candidates/TERRA_COLD_PASSED_FINAL_KERNEL_FOLD_2026-07-24/final_packets/goldbach_v0_2/ATTESTATION_GOLDBACH_PHASOR_SEATS_v0.2.md` | `9fe0a8e8e50de990f89eabd15afaff0628c3051c3fa36970460b67af487abf8b` |
| authority | `candidates/TERRA_COLD_PASSED_FINAL_KERNEL_FOLD_2026-07-24/outputs/ROBIN_RELEASE_GATE.md` | `3440230bedd6bc07b90dd4ee0d1a0f14baa0210dd31f5d342a8b83ca0d58bce0` |
| fold source | `candidates/TERRA_COLD_PASSED_FINAL_KERNEL_FOLD_2026-07-24/final_packets/goldbach_v0_2/DRAFT_KERNEL_ADDITION_GOLDBACH_PHASOR_PANEL_v0.1.md` | `ea64a10385afb3f616223acdccebf25fb0fafd244298ddd7c04873e0ad85269a` |

## Standing carried into the lock

- ATTESTED, machine PASS, lock-eligible (Opus attestation, pinned above). The attestation remains **seated: false**.
- Each item keeps its native-id status as tagged above, including the explicit not-claimed clauses: Cor II.23.5c "not-claimed (coverage/density)"; Def II.23.5e "heuristic-context (pair-density interpretation) + not-claimed (count/coverage/phasor magnitude)"; Def–Prop II.23.5d "comparator-only (no bound)".
- Binary Goldbach is **not claimed**, and the prime-fiber readings that depend on it stay conditional (Rmk II.23.5a/5b standing in the v3.2.5 base is unchanged).
- [GS20] supports the singular-series normalization only (bibliography standing, BIB-01).
- Locking fixes these items' text and standing. It does not upgrade any status or seat the attestation.

## Lock statement

Robin, 2026-10-12 (verbatim, in Robin's chat with Claude):

> I lock the assembled FVLT v3.2.6 release based on main 3953448, including the confirmed Farey and Goldbach item locks, preserving their reviewed standings and limitations. Prepare the release-lock PR for Codex’s final verification. Keep #18 held until the release is finalized.

Repinning or changing these items after this lock requires a new lock event with its own record.
