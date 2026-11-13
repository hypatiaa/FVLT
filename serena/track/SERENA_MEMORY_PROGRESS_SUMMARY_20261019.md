# Serena's memory: what we have done so far

Written 2026-10-19 for saphir. Source: the serena track file and the study, design, raven, handoff, Palantir and row-trial documents it points to. Nothing here is adopted by saphir unless it says so.

Status words: **proved** (a proof is in the document), **checked** (an exact script was run), **reviewed** (a reviewer gave a verdict), **open**, **not adopted**.

## 1. The assignment

On 2026-10-12 saphir said: "create and sign yourself up as owner for the Serena track. This track will develop the software that Serena needs to operate. You will coordinate with the other tracks and the Idea catalog coordinators."

On 2026-10-18 saphir added the memory work: "add to the sources, and look into its mechanics and how it can be extended to the full atlas work."

Scope is inventory, requirements, design, specs, reviews and briefs. Any build, install or run on Serena/Nucleus or Agora stays gated until saphir says build or run. Nothing has been built.

## 2. Where we started

The April module `serena_persistent_state.py` (644 lines, sha256 f9eedff5...). It is Serena's first persistent state, on Div(720).

- It keeps a running average of the energy in each order (EMA), with rate eta = 1/phi^2.
- It has walk runs stored as Neo4j nodes, a lattice memory, and a measurement-with-memory class.
- Its index says v1.0, needing Neo4j wiring.

What the study found (checked by script; the id collision was confirmed by the owner):
- The walk id is not unique. It is hashed before the timestamp is set, so it misses the time, the energies and the state. The graph links then match on a key that repeats.
- Complex input is zeroed.
- Tying eta to the Fiedler value is an analogy only (Open Problem 27), and is not admissible for squarefree N.
- s-orbits are a different object from the orders it tracks.

The good news: the state extends cleanly to the whole atlas at channel level. One state sits over the vertices of the cube complex X(N), atoms are truncations, and energy is conserved. Study v0.1 sha256 2631084f...

## 3. What the memory is now (design v0.2.2)

Design v0.2.2 is the current design. Design only. It is not implemented and not adopted.

- **Built from the complex plane up.** The signal lives in C^L. Energy E_q is measured on the exact-order-q roots of unity, using exact projectors built from Ramanujan sums. Arithmetic is exact: fractions, and Q(i) pairs for complex input.
- **One state over X(N).** A single state over the CAT(0) cube complex X(N). Unobserved is not zero: an order never measured has no entry, and a zero is only written where measured.
- **Atoms are truncations.** Truncating to a smaller atom commutes with the update, with a common rate.
- **One common rational eta**, so mass is conserved. Unequal rates are not allowed.
- **Masks and clocks.** The mask is the set of orders accepted for an update. Each order has its own count of observations, plus a global step count.
- **Surprise before the update.** The surprise is measured against the state as it was before the new data, and only on orders already observed. New orders are reported separately, never as a zero.
- **Hash-bound records.** Each record is canonical JSON with rationals written as reduced p/q strings (n/1 for integers). Its id is bound to eta and the outputs.
- **Append-only log.** Every observation is kept. Snapshots are only caches. Memory can be replayed and verified from the log.
- **Lemma 4.3a (proved, checked).** Under two conditions, H1 (the mask respects fibres) and H2 (each fibre has a uniform history), one update step commutes with the coarse-graining map push_gcd.
- **Corollary 4.3b (proved, checked).** The same holds across a whole sequence only if H1 and H2 hold on the actual domain at every step. A change of L can break H2.
- **Not proposed:** a cube-aware dynamics. The update is diagonal, so cube edges never couple channels.

## 4. How it was checked

| Step | Item | Verdict |
|---|---|---|
| #509 / #510 | Study v0.1 to Astra | PASS_WITH_FLAGS (reviewed). Five flags R1-R5: off-grid q, the 2N rule needs integral rates, unequal eta breaks mass, EMA memory is not a product, the id must bind eta and outputs |
| #511 / #512 | Study v0.1.1 to Astra | PASS_WITH_FLAGS (reviewed). R1-R5 closed. Two wording cleanups carried forward and folded into the design |
| #519 | Design v0.2 to Idea Catalog (Sol, Luna) | HOLD (reviewed). D1: push_gcd and update do not commute in general. Counterexample 3/2 against 1, checked by the owner. D2: perturbations must use mask intersect observed |
| #525 | Design v0.2.1 delta | HOLD, narrow (reviewed). The induction over a changing L was invalid. Counterexample M=1, eta=1/2, L 1 to 2 |
| #541 | Design v0.2.2 | Sent for re-review. **Pending** per the track file |

The exact checks for v0.2.2: the manifest was verified. `check_seq_v022.py` was rerun and gave identical output, 9225 of 9225 cases agree. When the H2 recheck is skipped there are 2840 divergences. On a fixed L, 5883 of 5883 agree.

## 5. Grounding in the kernel (agreed)

saphir agreed ("That sounds right") that the next design is grounded in kernel_v3_1_15:
- **IV.1, walk-relative lens.** Base, operative and current lens. Contraction is a view change, not erasure. The breathing lens is the masks and clocks.
- **Rmk 1.5c, two readouts.** Hasse says where. Harmonic says what.
- **Rmk 1.6b, three observation contexts.** Node, visit and transition, each with its own concept lattice Lambda_desc. They are never merged. Crossing contexts needs a constructed fourth.

Wording rule: energy, phase and tone are called readouts and observation contexts, not "lens". The v0.3 design that uses this is **open**; v0.2.2 is not yet rewritten around it.

## 6. Testing memory on art (the raven)

- **Study v0.1: negative as style memory (checked).** Surprise finds odd shapes (tuft curls, scribbles) but not the real wing problems of tone and placement. It mostly measures smoothness, and feather surprise tracks shaft length (r = 0.63).
- **Study v0.2: INCONCLUSIVE under the rule declared in advance (checked).** The transition context found a "mechanical placement" signature. Steps are more regular than human ones in 9 of 9 tests (Holm corrected). Step autocorrelation is about -1/2 and the spectral slope about +1.6, which fits a grid plus independent jitter. But the visit context also showed a gap, so the rule gives INCONCLUSIVE. The human reference is weak. The generator target it suggested (AR(1) on the step, phi 0.3 to 0.6) was wrong: it gives positive step correlation, the opposite of the target. The viewer track caught this; the corrected model is AR(1) on the deviation from the row grid, lag-1 = -(1-phi)/2 (handoff v0.1.1, checked exactly).
- **Handoff to the viewer track.** Handoff v0.1 and corrigendum v0.1.1 (answering the viewer track's correction) were delivered (#540, #546).
- **Row trial v0.6.4 (viewer track).** Deviation-AR(1) with phi = 4/5 on one row. The bands moved (heading and length steps in band, spacing just outside, about -0.21). By eye, saphir said it looked mechanical, with harsh opaque shadows and rows not natural to a bird. Coupled and uncoupled looked the same. The raven placement line is **paused**, with no v0.6.5.
- **saphir's reading, recorded:** "just because we can't see something at macro scale, doesn't mean it's not making a difference. the test was small". So: the effect is measured but not visible at single-row scale. This is **not** evidence of no effect. The deviation-AR model stays a candidate. The test was a single row.

## 7. Storage and compatibility decisions

- **#518 (Idea Catalog Codex), reviewed.**
  - Q1: notes, links and refs in ArcadeDB; run records as pinned JSON in git.
  - Q2: the prefixed sha256 and the n/1 canonical form accepted at design scope.
  - Q3: one shared order identity per q; atom anchors (N,d) kept; the ontology mapping is open.
  - Q4: keep every observation; snapshots are derived.
- **Q5, decided by saphir ("I will take the lean").** The serena track owns schema `serena-order-state/0.2`. The Zettelkasten and idea-catalog consume it. Changes go through discipline review. Each version is pinned by hash. The schema id is unchanged through v0.2.2.
- **Palantir compatibility, decided by saphir.** saphir wants compatibility for devs on Palantir for enterprise, or small companies who may later use the free offering. Serena records, concept lattices and implication bases must export in open formats that map onto Foundry Ontology primitives, with no runtime dependency. Local-first stays primary.
- **Spec v0.1 (draft, Sonnet).** The rule is "Serena's ontology governs; the adapter must preserve its meaning." It has 17 object types, 26 link types and 23 CSV tables, and the example check gave 1012 pass, 0 fail (rerun by the owner). Its checklist (section 8) keeps exact rationals, unobserved not zero, contexts never merged, append-only, and hash-bound records. Palantir facts are **unverified**, and the ids and byte layout are assumptions. It has 12 open questions. The first review (#542) is **pending**.

## 8. What is open and next

**Pending reviews:** #541 (design v0.2.2 re-review) and #542 (Palantir spec first review). The track file records no verdict for either.

**The mathematics of memory.** saphir paused the raven placement and said the feather work was done so we could work on how the memory works. The five mathematics items proposed by the owner session:
1. Memory as a presheaf over the atlas, and how small effects compose (including how sub-perceptual effects accumulate to a detection threshold). Started 2026-10-19; no result yet.
2. A canonical eta (Open Problems 27 and 28).
3. Cube-aware dynamics. The design currently proposes none.
4. Orbit = memory (kernel Remark 5.1j) made exact: pi is a discounted average, not an ergodic projection; its relation to the Galois orbits and the viewer s-orbits is open.
5. Lattice-valued memory (concept lattices as the stored object).

**Also open in the design:** the ontology mapping for Q3; a general retention policy; numerical-register serialization and cross-writer conformance; how the Clifford carrier is carried.

**What Serena still lacks (open, not designed here):**
- What it observes.
- What the memory changes in Serena's behaviour.
- Rules linking surprise to Zettelkasten notes.

## Key files

All under `C:/Users/robin/s6_atom/`.

| File | sha256 |
|---|---|
| `stack_bus_autocheck/tracks/serena.json` | (the track record, not hashed here) |
| `serena_track/STATE_MODULE_ATLAS_STUDY_v0_1_20261018/NOTE.md` | 2631084f48753ae640efcf375b30a4e3db22a14163e943e03389fe6a46aeab93 |
| `serena_track/STATE_MODULE_ATLAS_STUDY_v0_1_1_20261019/NOTE.md` | 2ddaefca0e2989a7030d804df78d405ca71e3762fad1a51a7e6ce1ceb1068855 |
| `serena_track/STATE_DESIGN_v0_2_20261019/DESIGN.md` | 7cfb185e5214fd22fa6000e333a589cd1f3e7fffa04a8cf11d145782a17802d4 |
| `serena_track/STATE_DESIGN_v0_2_2_20261019/DESIGN.md` (current) | d63b286af2cf9756b8ec81138c0a8ddc6c5fe54b309faef373c37c72212802b4 |
| `serena_track/RAVEN_FEATHER_MEMORY_STUDY_v0_1_20261019/NOTE.md` | ed4126700443374707730a912e641bed5f263f3160db426d4d614be7c8cadee0 |
| `serena_track/RAVEN_FEATHER_MEMORY_STUDY_v0_2_20261019/NOTE.md` | 0b826ef9a306c78f59d3537d62d372cb91d2cb4a8b3dcf9b86d788f5ab783c7f |
| `serena_track/HANDOFF_RAVEN_PLACEMENT_TO_VIEWER_TRACK_v0_1_1_20261019/HANDOFF.md` | 09ae9f09f6429eb272c702b28c58aff80fdb1a4ee8525fd351e06dd5381d99a3 |
| `serena_track/PALANTIR_COMPAT_SPEC_v0_1_20261019/SPEC.md` | b97d0c9713ea8ffec3d444bf2d776c32ee7c38cb66c5183d0ed7a52b0af5ea67 |
| `MCOMB_RAVEN_DRAWING_v0_6_4_ROW_TRIAL_20261019/VERDICT_SAPHIR_v0_6_4.md` | df3f1f7850427aeeb5087ca6271cc63565251794cdd8feb6513b9cf52af325bd |
