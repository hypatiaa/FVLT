# FF-1 input freeze draft v0.1

2026-11-03. **AWAITING REVIEW.** Preparation authorized by `EXECUTION_GO_STAGE_A_20261103.md` for exact v0.3 plus E1 and the owner's v0.3 review. No proof elaboration, F1/F2, formalization-source compile, checker execution, or simulation has occurred. `lake env lean --version` was used only to identify the compiler.

## Observed inputs

Nucleus was reached with the explicit Tailscale endpoint `100.105.106.41`, SSH config `C:/Users/robin/.ssh/config`, host alias `nucleus`, pinned host-key alias `192.168.0.177`, BatchMode and StrictHostKeyChecking enabled. No LAN fallback or scout contact was used.

The latest version directory present is `/home/saphir/rule30_theorem_library/v19`; no later numbered version was present at preparation. Expected and observed values match:

| Input | Expected = observed SHA-256 |
|---|---|
| `SHA256SUMS` | `e25d4d54d074f152c452aa7247ccbe992e14b29d58306809660a75770ae7ddd5` |
| `LIBRARY_MANIFEST.json` | `f0ee6b00fe4a622b63cac1f4fb24146e9b2808bdb0fb430ebdac074fecb258fa` |
| `lake-manifest.json` | `1f0e0c1c0a06e2a9ecc117aed82f7a8ee62b418235e10686d3bda2d6986ea527` |
| `lakefile.toml` (actual configuration) | `4f0aea1336d288cba45c00727ce81c2cc064c39fca46e8ccf4505ae38ca6191f` |
| `lean-toolchain` | `ca5f1f601d34c49079e38d7e7041eb0f2a9c227fbc1df0f404820069a052330c` |
| `IndependentFVLTReplay435.lean` | `9c6f2ac11b50fdb846df2d5099ea673553903275a5dba11fce5a5673cae14bd0` |
| Governing kernel v3.3.1 | `e49533088843e2cd0a1c531c4d8ba113ea30113e8135a15c17c040bdfca3e0e0` |
| Governing order v0.3 | `43560b88ab50dc77d8e222562f83bad68c8ba17d12a073523a99597a484d6fdd` |

The receipt records provenance for each expected value. In particular the `lakefile.toml` expected pin is proposed from the authorized initial v19 inspection and needs this freeze review; it is not represented as a previously reviewed work-order pin. No input changed to force a match.

- Compiler observed: Lean 4.35.0, x86_64-unknown-linux-gnu, commit `eb6cafb7290e8bd5f2937522d8d804f58f02bafc`, Release.
- Mathlib observed Git HEAD: `56a005855ea17e0b0958f73ec801ae140b0a1679`.
- `sha256sum -c SHA256SUMS`: exit 0, **381 OK entries**; complete output is `LIBRARY_SHA256_CHECK_v0_1.txt`.
- Read-only scan: 153937 non-symlink entries scanned, **zero entries with write permission bits**; library root mode 0555. One documentation symlink was not followed, and its resolved target is inside the scanned v19 tree. This does not assert that an owner could never chmod files; it records their current permission modes.
- Live capacity: about 28777 MiB available at the first observation, load averages 0.07 / 0.02 / 0.00; the later receipt records a fresh memory/load/process snapshot. These are observations, not a reservation. Recheck contention before F1; return host-contention issues rather than starting competing work.

Complete structured evidence is in `INPUT_OBSERVATIONS_v0_1.json`; the metadata-only script is `PREPARE_INPUTS_v0_1.py`. These and this draft are pinned in the preparation manifest.

## API inspection and proposed imports

Only permitted shared-library Mathlib source was inspected. Observed APIs:

- `Mathlib/Data/Rat/Defs.lean`: `Rat.mk'_num_den`, `Rat.den_ne_zero`, use of `Rat.num_divInt_den`; `Mathlib/Data/Rat/Lemmas.lean`: `Rat.num_den_mk`, `Rat.den_dvd`, `Rat.num_dvd`, and uses of `Rat.num_div_den`. Canonical reduced-pair bridges remain explicit proof obligations; no theorem name was assumed to solve them automatically.
- `Mathlib/Combinatorics/SimpleGraph/Connectivity/Connected.lean`: `Reachable` is `Nonempty (G.Walk u v)`; `Preconnected` is all-pairs reachability; `Connected` includes nonempty vertices; `ConnectedComponent` is the reachability quotient; `connectedComponentMk` and `ConnectedComponent.eq` connect vertex reachability to quotient equality.
- `Mathlib/Combinatorics/SimpleGraph/Maps.lean`: `G.induce s` is the graph on the subtype with underlying adjacency unchanged (`induce_adj`).
- `Mathlib/Combinatorics/SimpleGraph/Finite.lean`: `edgeFinset` exists under a finite edge-set instance. Proposed signatures instead state exact counts as `Nat.card G.edgeSet`, linked to the bounded rational ordered-pair count by a helper theorem.
- `Mathlib/Analysis/Complex/Norm.lean`: `Complex.normSq_eq_norm_sq`, `Complex.sq_norm` and `normSq_apply` support coordinate reductions.

Proposed imports for arithmetic: rational lemmas, finite-set intervals/divisors, simple-graph connectivity/maps/finite, and required standard tactics. Geometry adds complex norm and imports the arithmetic module. Exact import lines and their no-G1 closure will be part of the compiled-source freeze before first invocation. No shared Rule 30 project module is needed. Equivalent existing material discovered during subsequent authorized work must be reused and reported.

## Prospective runner and exact command forms

Remote isolated package: `/home/saphir/fvlt_formalization_20261028/ff1_v03_20261103`.

`RUN_FF1_v0_1.py` is prospective and **has not been invoked**. It requires a reviewed input/signature acceptance record and a separately accepted job-manifest digest pinning exact source bytes and dependency objects. That acceptance file does not yet exist. Runner source is included in this freeze request for inspection; acceptance of this draft is not a claim that the runner has been tested.

Invocation, after both freezes and the corresponding source/job review:

```text
python3 /home/saphir/fvlt_formalization_20261028/ff1_v03_20261103/RUN_FF1_v0_1.py /home/saphir/fvlt_formalization_20261028/ff1_v03_20261103/JOB.json
```

Within that wrapper, `MODULE` is exactly `FVLTFareyContactV1` or `FVLTFordGeometryV1`; `ROOT` is the isolated package path above; `LEAN` is `/home/saphir/.elan/toolchains/leanprover--lean4---v4.35.0/bin/lean`:

```text
LEAN -j1 -s65536 -M7680 -D Elab.async=false -o ROOT/MODULE.olean ROOT/MODULE.lean
LEAN -j1 -s65536 -M7680 -D Elab.async=false --run ROOT/IndependentFVLTReplay435.lean MODULE
```

The runner records the fully expanded argv for each invocation. `LEAN_PATH` contains only this isolated root, v19's built library, and its cached dependency build roots. Source-job review must record and check the imported project closure before accepting each source job; the pinned checker also audits loaded project module names. No downloads, Lake builds, source modifications to dependencies or native_decide are authorized.

**Command-form proposal requiring review:** the order names `lake env lean`; this runner uses the pinned identical Lean executable with explicit cached dependency search paths, as in prior isolated deliveries. Accept that explicit command form in freeze review or return it for a runner-only revision. It is not represented as a literal `lake env lean` invocation.

Resource proposal: one CPU selected from current affinity, nice 19, Lean one thread, hard 8 GiB address space, Lean's internal 7680 MiB cap, 256 per-user process limit inherited by children, 64 MiB per output/object file, no core dumps, per-call wall cap 240 seconds or the smaller remaining stage budget. Unique run receipts/logs, exclusive serial lock, no automatic retries. A compiler/checker verdict stops the item on failure. Tooling faults are preserved and reported separately; they do not permit unlimited repair attempts.

F1 and F2 have separate **serial 30-minute wall deadlines**, including proof development and calls, with F2 permitted only after a recorded F1 PASS. Deadline records are created only after both freezes are accepted, immediately before beginning that phase's proof development. Finite-certificate tests and proofs stay on nucleus. Remaining proofs require an explicit reviewed job deadline as well; this document grants no unbounded runtime. The runner pins sources/dependency objects, checks library hashes before calls and complete checksums after calls, and preserves the raw exit, timing, RSS, and output hashes. Full before/after read-only receipts remain required at final acceptance as well.

The pinned checker audits and kernel-replays every target constant, rejecting target unsafe/partial/axiom declarations and disallowed dependencies. Imported dependencies are reused, not replayed. The checker's own unsafe implementation is not a target module and does not count as a new mathematical axiom.

## Preparation-only deviations and stop boundary

Initial metadata probing assumed `lakefile.lean`; the file does not exist in this TOML-configured library. Subsequent inspection used `lakefile.toml` and recorded its full hash. Some source-name probes for rational/graph helper files likewise returned missing paths; inspection used the actual named files above. These were read-only path/API discovery faults before any proof verdict, not failed mathematical compiles. No dependency was installed or changed.

Both this input freeze and `SIGNATURE_FREEZE_DRAFT_v0_1.md` must be reviewed before proof development, F1 or F2. If the latest library advances before work begins, return a pin-change proposal as the order requires. Stage B, G1, Neo compute, S4r-C, commits, and library synchronization are excluded. Library synchronization remains a proposal awaiting separate authorization.
