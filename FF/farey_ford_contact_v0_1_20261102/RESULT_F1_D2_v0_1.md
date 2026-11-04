# FF-1 F1 after D2: local compile and strict replay PASS

2026-11-03. **Local verification PASS; awaiting skeleton audit.** Both modules compile. The pinned strict checker replays/audits all 22 target-constant entries across the two modules, with zero unsafe/partial declarations and no disallowed axioms. This is not yet the manager-audited F1 PASS needed to start F2. No F2 or remaining Stage A theorem is claimed here.

## Governing inputs

The exact v0.3 order, E1, Stage A execution-go record, accepted input/signature freezes, C1 and accepted F1 job template remain applicable. D2 `F1_STOP_DISPOSITION_D2.md` SHA-256 `a8d59e055b0861e00189f2b9881de3b4f31e4516e4e33d5d43a71fe116519fa8` explicitly authorizes noncomputable marking and proof-body iteration, including private helpers, without changing frozen definition values or theorem headers. It was fully read and independently hash-matched locally before use.

All runtime used nucleus over explicit Tailscale, frozen v19, Lean 4.35.0 executable SHA-256 `bf8d54e4714cc4b03d3f6bb34c83b7202b87e49c8bfcbff6895c085bb90ceb38`, Mathlib `56a005855ea17e0b0958f73ec801ae140b0a1679`, accepted runner v0.2, 8 GiB address-space cap, 1 CPU, nice 19, maximum 240 seconds/call. No 16 GiB amendment was used. Complete expected input hashes and original 381-file/read-only receipts remain pinned in the input freeze.

## Exact final sources and objects

| Module | Source SHA-256 | Object SHA-256 on nucleus |
|---|---|---|
| FVLTFareyContactV1 | `2760392f984bd1375169920a702ae53c13115ddfb36d71bae36b3855950d1e4b` | `202d39c1c940eef0a6cd23ea422e251df2d9e111255bbc460cb14650c8f042e8` |
| FVLTFordGeometryV1 | `0b380fd6cf1319317edbc9bbd5c56ed6f913bfbb7ac45104877b0f754b7e6db8` | `ea5dc4ce259c44b6e742ce950dcea3333d83d031511595ac951b68b0570cab54` |

The successful geometry depends on the pinned successful arithmetic object. Geometry source retains the exact frozen F1 headers, every explicit binder and all frozen definition values. Its compilation context now includes `noncomputable section`, as D2 permits.

## Repairs and preserved failures

The first D2 call, `F1GCompile02`, added only the noncomputable section; it failed with residual coordinate-algebra and local square-equality proof goals. The 40728-byte raw log and exact source are retained. There was no missing-import/realization error in this successor.

The proof-only successor introduced four private coordinate lemmas, each proved by simplification:

- `centre_re`: centre real coordinate is the rational value cast to ℝ;
- `centre_im`: centre imaginary coordinate is the positive radius;
- `kiss_re`: kiss real coordinate is kissN/kissM over ℝ;
- `kiss_im`: kiss imaginary coordinate is 1/kissM over ℝ.

Those keep casts to ℂ out of the later polynomial normalization. The distance and local kiss identities then simplify to real rational identities closed by `field_simp` and `ring`. For membership, explicitly simplifying the zero right-hand side and applying nonnegative square equality replaces the unsuccessful nonlinear step. No other private helper was introduced. No frozen proposition or definition value changed. D2's first-call diagnostic interpretation is preserved as a manager interpretation; the actual residual log and repair give the concrete evidence.

Earlier F1 read/notation/instance faults and the genuine geometry failure before D2 remain preserved under their original run IDs and reports. The file-read cause remains unresolved; no memory-map diagnosis or missing-cache assertion is adopted. Failed-compilation `sorryAx` output remains in historical logs, never as proof evidence.

## Successful compile, axiom and replay observations

| Run | Observation | Seconds | Peak child RSS KiB |
|---|---|---|---|
| F1ACompile04 | arithmetic definitions, exit 0; historical successful object reused unchanged | 0.767095 | 1660352 |
| F1GCompile02 | marker-only intermediate, exit 1; preserved failure | 3.674594 | 3496624 |
| F1GCompile03 | final geometry, exit 0 | 2.017860 | 3486824 |
| F1AReplay01 | pinned strict checker PASS, 2/2 target constants audited/replayed | 1.167692 | 1962180 |
| F1GReplay01 | pinned strict checker PASS, 20/20 target constants audited/replayed | 2.869039 | 3619800 |

The final compiler printed exactly `propext`, `Classical.choice`, `Quot.sound` for each of `radius_pos`, `ford_distance_identity`, and `kiss_membership`. Strict replay reports all constant dependencies within that allowed set, no target axiom declaration, no unsafe or partial target constants, and G1 excluded. Imported dependencies are reused, not replayed. The 20 geometry entries include generated equation/proof declarations, including a generated determinant equation, in addition to the written geometry declarations; the count is not 20 independently written theorems.

Five harmless final-compile linter warnings remain: the frozen unused `hne` binder and two pairs about unnecessary `<;>` sequencing. They were not removed by further reruns. There are no compiler errors in the accepted final call. No source `sorry`, `admit`, extra axiom, `native_decide`, unsafe or partial declaration was introduced.

## What F1 establishes

- The Ford-centre distance identity for distinct rationals, exactly at the frozen sum/radius normalization.
- The proposed kiss point lies on both circle boundaries when the canonical determinant has absolute value one.
- Positivity of the Ford radius.

F1 does **not** establish uniqueness of the kiss, all open-disk/real-axis/tangency targets, the phase graph, the component certificates, or any helix/Rule 30/Dirichlet result. It does not complete Stage A, grant kernel standing, or authorize library inclusion.

## Integrity, timing and next decision

Each concrete job was self-accepted under the manager-accepted F1 template with its timestamp/template hash, exact source hashes and dependency object hashes; snapshots precede each invocation. The unchanged pinned runner recorded full expanded LEAN_PATH, executable hash, caps and raw outputs. All four new complete post-call library checksum checks returned exit 0. Final regular-file/directory read-only and pin receipts are included. No shared library or dependency was modified or built.

`F1_RESTART_D2_TIMING.json` records the D2 excluded interval beginning at F1GCompile01 and the recomputed restart deadline, conservatively rounded to whole seconds. Both successful compile and strict replay completed within the remaining active budget; no 600-second floor extension was needed. Historical timing/deadline records remain preserved.

**Next decision:** Opus audits the complete manifest, concrete source snapshots, frozen-header/value comparisons, logs, receipts and replay output, then records F1 PASS or objections. Only after that recorded PASS may the separate F2 template/proof phase start. Final Stage A statement-fidelity review remains a further gate. FF-2 remains queued until Stage A delivery. Stage B, synchronization, commits, Neo mathematical computation, G1, S4r-C and viewer edits remain excluded.
