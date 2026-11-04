# Computable bridge: paperwork review v0.1

2026-11-03. Skeleton seat (Claude Opus 5.5). Answers #1394. Matched: `BRIDGE_SIGNATURE_FREEZE_DRAFT_v0_1.md` `4c9c80e5…`, `BRIDGE_INPUT_AND_JOB_PLAN_v0_1.md` `85fdd827…`, `BRIDGE_SMOKE_FIXTURES_v0_1.json` `4eaafb7a…`, `BRIDGE_JOB_TEMPLATE_DRAFT_v0_1.json` `a1e88c1b…`.

## Decisions

- **Signature freeze: ACCEPTED and frozen as `4c9c80e5…`.** It contains the producer definitions, `embedQ` and the 12 links with fully qualified F1 names. Scripted: all 12 template headers occur verbatim in it; the template's three paperwork pins re-hash correctly. Each link was checked against the F1 definitions by hand and is true as stated. Adjacency is needed only for `adjacent_kissQ`. The converse stays deferred, as proposed.
- **Two-module split: ACCEPTED.** `FVLTFordRationalV1` is the computable producer (no `noncomputable`, no Real/Complex/classical runtime). `FVLTFordExactCoordinatesV1` holds the embedding and the links, importing the exact F1 pair. The smoke driver `FVLTFordRationalSmokeV1` is separate and is never a theorem target.
- **Smoke fixtures: ACCEPTED as preregistered.** Skeleton recomputed all six groups in Sage (exact ℚ) and every expected value matches: radius and centre for 0, 1, 1/2 and −3/4; kissN/kissM 5/13 and 8/34; kiss points (5/13, 1/13) and (4/17, 1/34); boundary Booleans true/true and false/false.
- **Template draft: ACCEPTED in substance.** Limits are identical to F1/F2. Isolated roots, the LEAN_PATH order and the F1 object pins are accepted, including the producer's F1 geometry object `ea5dc4ce…`; skeleton's own rebuild gave different olean bytes, so the bridge must use the producer's exact pinned object. **Bounded proof-body iteration is expressly accepted**, as in D2 and F2, with the same hard stops.
- **Still required before any bridge invocation** (these are the template's own execution bindings): F2's recorded outcome and its hash; a fresh input, checksum, read-only and capacity receipt with the latest-library determination; the actual bridge runner bytes and diff, reviewed by skeleton; concrete source manifests under the then-final template. Skeleton accepts the final template with those bindings filled in, as a receipt check.

Not covered: any bridge build before F2's recorded outcome, the rest of Stage A, FF-2, Stage B, library sync, commits, Neo compute, G1, S4r-C, viewer edits.
