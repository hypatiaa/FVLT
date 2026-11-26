# LOCK RECORD — Part II / II.23.9

**Lock issued by:** Robin — *"the II.23.9 is a lock"* (2026-07-23), sole lock authority.
**Recorded by:** Fable (Claude / Opus), this session.
**Status transition:** candidate / provisional  →  **LOCKED**.

## Locked object

Subsection **II.23.9 — Gearbox–winding identity and the Vernier Lissajous lift**,
seated as the final subsection of Part II / II.23 (insert after II.23.8, kernel_v3_2_5.md
content ends L2472, before the `---` / `# Part III` boundary L2474/L2476). No `II.23.9*`
collision; zero renumbering risk (grep-verified).

Contents (dependency order):
- **Def II.23.9** — per-branch Clifford lift + normalized Hopf quotient (definitional)
- **Lemma II.23.9a** — gearbox = degree of the normalized quotient circle map `u_c:S¹→S¹`,
  `k_c = p−q` (unconditional, adapted)
- **Rmk II.23.9b** — Vernier Lissajous as the Hopf-quotient image (interpretive)
- **Prop II.23.9c** — stereographic exteriorization of the zero-side foliation (unconditional, adapted)
- **Cor II.23.9d** — full-stack reciprocal leaf sampling (unconditional given defs, project-original)

## Locked bytes (pin-once)

- `ENTRY_II_23_9.md`      SHA-256 `f0ebab9126985a13389894b95a63bd5ae905fd3eb1e11183c3bdfab98ec3c854`
- `II_23_9_combined.zip`  SHA-256 `85ff7e7447799381be44a2006df6b2ff13f74d867538b7f8e8e38c5a70210766`

Companion verifiers (deterministic, green, pinned): `verify_gearbox_winding.py`,
`verify_reciprocal_foliation.py`.

## Cold-pass provenance (the road to lock)

- **9c/9d (foliation):** Sol cold pass — PASS after patches (`COLD_AUDIT_RESPONSE_SOL.md`).
- **9/9a/9b (gearbox):** Sol first combined pass — **HOLD** (reduced-orbit / degree-domain /
  G3 wording) → Sol corrective delta (S¹→S¹ degree explicit; ℂ×/ρ>0 domain fenced; unreduced
  `k_c` vs rendered `k_c/d` separated; G3 = d-fold cover, not d-component link; verifier
  extended to test the distinction) → **independent delta cold pass by Fable (Opus): PASS**
  (`OPUS_DELTA_COLD_PASS_VERDICT_II_23_9.md`, SHA-256
  `f91c3166796b3d4f181b4801a0c8d49b11af0ec3ceca4bb2b04eb16689d2a9c7`).

## Three-stack

Robin — architect, seat decision, lock authority.  Sol (ChatGPT) — propositions
(9c/9d), cold passes, corrective delta.  Fable (Claude/Opus) — verification, packaging,
combined assembly, independent delta cold pass.

## Post-lock bookkeeping (follow-up, kernel-side)

1. Insert the II.23.9 block into `kernel_v3_2_5.md` at the seat above.
2. Add the five II.23.9 rows (Def/Lemma/Rmk/Prop/Cor) to the **VII.2a fold concordance**.
3. Bump the kernel version note / changelog to record the additive II.23.9 lock.

## Discipline

Pin-once: this record certifies the locked bytes above; any future change is a **new lock
event** with its own record, superseding rather than overwriting this one. The lock seats the
analytic/geometric statements as recorded; it does not assert a compiled Lean topological-degree
bridge, nor seat S³ as a theorem-bearing Hilbert register (Note 9.7n; deferred).

— Lock issued by Robin; recorded by Fable, 2026-07-23.
