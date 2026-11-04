# FF-1 R5: remaining finite fixtures

2026-11-03. **Awaiting Opus receipt check. No R5 source, proof drafting, preflight, computation or build.** Parent `R4_AUDIT_v0_1.md`, SHA256 `ffbb74192b3ef1c037bb9862e81ff96284585717356cc7270e6cb4b31199a302`, independently matched and read in full, records R4 PASS #1430. The manager-audited total is 55/60. Robin's Stage A go and accepted continuation sequence remain in force.

## Exact bounded deliverable

One additive `FVLTFareyFixturesCompletionV1.lean`, namespace `FVLT.FareyContactV1`, imports the exact audited R4 module and standard Mathlib. It introduces **no new public definitions**, and reuses all accepted phase, adjacency, graph, contact-count, isolation, partition and component-certificate semantics.

Five original A7 target headers, verbatim in the template:

1. `fixture4321_connected`: the phase graph of [4,3,2,1] is connected.
2. `fixture4321_repair_edges`: membership of 1/5, 1/4, 3/4, 4/5 in that phase set and the two declared Farey repair edges.
3. `fixture83_certificate`: the exact frozen rational component partition for [8,3], using the singleton parts {1/9}, {8/9} plus their complement.
4. `fixture83_counts`: 11 vertices, 8 contacts and 3 actual Mathlib connected components.
5. `fixture83_isolated`: the isolated set is exactly {1/9, 8/9}.

The partition's nonempty parts, coverage, pairwise disjointness, internal connectedness and absence of cross edges must be proved through the already audited `rationalCertificate`/`ComponentCertificate` semantics. The existing general component bijection/count bridge is reused; the number of listed parts is not silently substituted for the number of graph components. The subset guard on rational-to-subtype transport stays intact.

Bounded finite arithmetic/certificate checks may use kernel `decide`/`decide +kernel`, including the already accepted Mathlib bounded-walk decider, or explicit finite parent/depth certificates with the audited soundness theorem. No `native_decide`, executable result trusted as proof, arbitrary path search, altered graph or approximate arithmetic is allowed. Private proof helpers and ordinary decidability instances are implementation support, individually listed and strictly replayed. No extra public fixture or definition is silently added.

These are exact finite witnesses: [4,3,2,1] comes from the worked repair fixture after II.5j.1; [8,3] is the second II.5k witness. They do not become a general profile-connectivity theorem or a Rule 30 result. The already audited R3 supplies its separate general unit-fraction result, on its own domain.

## Mechanical runner continuation

`RUN_R5_v0_1.py` is the accepted R4 runner with only R5 module/phase/artifact constants and R4's source/object/PASS pins added. Full diff included. It protects **14 predecessor source/object files and seven PASS records**, retaining the R4 producer object `875d7726…` rather than substituting Opus's audit rebuild. The isolated root, parent serial lock, expected library/compiler/Mathlib/checker, commands, modes, integrity checks and caps are unchanged.

The template has an empty new-definition list. R4's S1 annotation metadata is no longer needed for this module because its definitions are imported unchanged. All five statements remain exactly those already signature-frozen; only the final five original targets are dispatched.

## Same binding, resource and stop gates

After receipt-check acceptance, run metadata-only fresh nucleus/Tailscale latest-library, all-pin/identity, full-checksum, read-only, capacity and predecessor/gate observation. Expected v19 pins are not a claim of fresh observation. Any mismatch returns for review before proof drafting. Request the same all-match bound-template acceptance on verified bus posting, with delivery recorded before starting the proof clock.

One fresh 1800-second active allowance starts at R5 proof drafting; no transferred allowance. Same accepted caps: one CPU, nice 19, hard 8 GiB, Lean `-j1 -s65536 -M7680 -D Elab.async=false`, maximum 240 seconds/call or smaller remaining deadline, process cap 256, file/output cap 64 MiB, no cores, serial calls, no automatic retries. Bounded proof-only iteration, timestamped concrete self-accepted manifests, helper/instance reports and failed snapshots follow the continuation policy. Review-wait exclusions need preserved records.

Changed propositions or definition values, forbidden axioms, unsafe/partial targets, strict-checker failure, integrity drift or budget expiry stop and return evidence. A finite checker exceeding the cap does not justify changing the certificate or importing an unreviewed external result. General helpers cannot be given kernel standing by being used in a fixture.

## Delivery and final boundary

Deliver exact source, all five headers compared verbatim, every proof attempt/snapshot/receipt, target/helper axiom reports, strict replay of every module declaration, predecessor/library integrity receipts, a closed manifest and per-target source/standing map. Opus independently recompiles/replays and verifies the binding before recording R5 PASS.

An audited R5 would cover all 60 original targets individually. It would **not** by itself complete the separately gated integrated import/package build or independent per-row fidelity sign-off under §10. Prepare those as concrete reviewable jobs after R5's audit. No synchronization, kernel adoption, seal, installation or release follows automatically. Stage B, FF-2/FF-3 execution, G1, Rule 30 forcing, viewer changes and commits remain excluded. Framework credit remains Robin Miller; classical components retain their source credit.
