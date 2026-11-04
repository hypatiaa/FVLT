# Computable Ford bridge: input and job freeze plan v0.1

2026-11-03. **Review paperwork only.** No bridge execution before F2's recorded outcome, reviewed bridge inputs/signatures/template and concrete source-job acceptance. This is not a fresh live bridge input verification receipt.

## Expected fixed inputs

Reuse the accepted F1 input set as a proposed bridge base, preserving F1's historical v19 standing:

| Input | Expected SHA-256 |
|---|---|
| v19 `SHA256SUMS` | `e25d4d54d074f152c452aa7247ccbe992e14b29d58306809660a75770ae7ddd5` |
| v19 `LIBRARY_MANIFEST.json` | `f0ee6b00fe4a622b63cac1f4fb24146e9b2808bdb0fb430ebdac074fecb258fa` |
| v19 `lake-manifest.json` | `1f0e0c1c0a06e2a9ecc117aed82f7a8ee62b418235e10686d3bda2d6986ea527` |
| v19 `lakefile.toml` | `4f0aea1336d288cba45c00727ce81c2cc064c39fca46e8ccf4505ae38ca6191f` |
| v19 `lean-toolchain` | `ca5f1f601d34c49079e38d7e7041eb0f2a9c227fbc1df0f404820069a052330c` |
| Lean executable | `bf8d54e4714cc4b03d3f6bb34c83b7202b87e49c8bfcbff6895c085bb90ceb38` |
| Strict checker | `9c6f2ac11b50fdb846df2d5099ea673553903275a5dba11fce5a5673cae14bd0` |
| Isolated F1 arithmetic source | `2760392f984bd1375169920a702ae53c13115ddfb36d71bae36b3855950d1e4b` |
| Isolated F1 geometry source | `0b380fd6cf1319317edbc9bbd5c56ed6f913bfbb7ac45104877b0f754b7e6db8` |
| Isolated F1 arithmetic object | `202d39c1c940eef0a6cd23ea422e251df2d9e111255bbc460cb14650c8f042e8` |
| Isolated F1 geometry object | `ea5dc4ce259c44b6e742ce950dcea3333d83d031511595ac951b68b0570cab54` |
| F1 PASS/sequence decision | `d5470d9b2353ca9de7309064dad363955e567a356fb5075dae04c0f9f32c7526` |

Toolchain identity remains Lean 4.35.0 `eb6cafb7290e8bd5f2937522d8d804f58f02bafc`, Mathlib `56a005855ea17e0b0958f73ec801ae140b0a1679`. No F1 library promotion is assumed. No F2 module is a bridge dependency. The F2 outcome is a sequencing gate, not a mathematical premise of a bridge theorem.

At this extension's execution freeze, re-observe the latest released library, all expected/observed hashes, complete checksum/read-only checks, exact compiler/Mathlib identities, F1 dependency source/object hashes and capacity. If the latest library differs, return a pin proposal for review before work, retaining F1's original source standing. Hash and review the actual F2 outcome record and bridge runner before invocation; neither is available/accepted as part of this draft. Inherited receipts do not substitute for fresh observations. Root paths and commands are proposed, not an executed bridge environment.

## Template proposed for acceptance

- Isolated root: `/home/saphir/fvlt_formalization_20261028/ff1_v03_20261103/computable_bridge_v1`.
- Allowed theorem/producer modules: `FVLTFordRationalV1`, `FVLTFordExactCoordinatesV1`; allowed modes: compile, pinned strict replay. Executable smoke driver `FVLTFordRationalSmokeV1` is separate, imports the producer only, and is run solely for finite executable evidence, not as a proof target.
- Explicit LEAN_PATH: isolated bridge root first, exact F1 isolated predecessor root second, then the reviewed library/dependency build roots. No F2 object dependency. Fully expanded path and executable hash in each receipt.
- Same resource proposal as F1: 1 CPU, nice 19, 8 GiB hard address space, Lean `-j1 -s65536 -M7680 -D Elab.async=false`, 240 seconds per call, process cap 256, file-size cap 64 MiB, core dumps disabled; serial only.
- Separate 1800-second active cap including source/proof development, compile, replay and smoke checks. It starts after all gates when drafting begins, not with today's paperwork. Record accepted manager-wait exclusions. No timing allowance transfers from F1/F2.
- Concrete exact-source/job manifests self-accepted only under a manager-accepted template, timestamp/template hash logged, source/object snapshots before calls, no automatic retries. Request bounded proof-body iteration as in D2 while preserving frozen values/headers; absent explicit acceptance the ordinary stop rule applies. Scope/proposition changes, unsafe/partial/extra-axiom target, strict-checker failure or cap expiry stop and return evidence.
- Strict checker audits all target constants of producer and proof modules; imported dependencies reused, not replayed. Every written theorem gets `#print axioms`. Executable driver code/results are kept separate from formal theorem/replay status.
- The producer must compile without `noncomputable` and without real/complex/classical runtime dependencies. A smoke driver using those producers gives separate executable evidence. The geometric proof module may use the declared noncomputable embedding.
- Preregister `BRIDGE_SMOKE_FIXTURES_v0_1.json` unchanged before tests. Check exact rational values and both Boolean boundary results, with nonzero process exit on any mismatch. Report pass/fail counts, output and runner/source hashes. No floating point or native_decide, and no generated evaluator code passed off as a theorem.
- All predecessors remain byte-identical; no commits, library writes, viewer changes, G1 or Neo mathematical computation. All runtime on nucleus over explicit Tailscale after a fresh capacity check.

## Outputs and limits

Return exact sources/objects, all signatures, the actual reviewed input/job records and runner, 12 theorem axiom reports, strict replay reports, finite smoke receipts, before/after library checksums/modes, and a fidelity table connecting each link to the actual F1 definition. Local build/replay PASS, independent review, kernel adoption and library inclusion remain distinct. The current acceptance of a design direction does not establish any of these twelve theorems.

Opus should review this signature/fixture/template paperwork while F2 proceeds. Execution waits for F2's recorded outcome and completion of the bridge's own reviewed execution freeze. The optional converse is deferred. The rest of Stage A follows the bridge under the manager's sequencing decision.
