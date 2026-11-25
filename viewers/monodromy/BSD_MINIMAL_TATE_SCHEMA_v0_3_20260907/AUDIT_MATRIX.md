# Audit matrix — minimal/Tate schema v0.3

Assess this package as a schema/reference-checker successor with scoped good-prime certification. The Monodromy.30.1 viewer is unchanged. Do not apply a full Tate-engine implementation verdict to an algorithm this package does not contain. Read `SCHEMA_FOR_AUDIT.md` first.

| Gate | Required check | Current implementation boundary |
|---|---|---|
| S1 | Draft 2020-12 metaschema and all five positive fixtures | Python jsonschema; strict unknown-field rejection |
| S2 | Reject numeric exact coefficients, malformed points, unknown statuses and audit-authority fields | Structural negatives supplied |
| T1 | Recompute complete five-coefficient models and invariants | BigInt rational replay; singular models rejected |
| T2 | Verify tuple direction, inverse and composition | Exact replay and independent Python polynomial substitution |
| T3 | Preserve selected differential through signed u, translations and shear | Exact replay and denominator identity in Python |
| T4 | Convert the old model-scaling parameter reciprocally | Normative rule; inverse/composition fixtures; legacy packet adapter still required |
| T5 | Distinguish twists from Q-isomorphisms | Short quadratic fixture and false-isomorphism rejection; quartic coefficient replay supported |
| V1 | Bind all six panels to curve, model, normalization and marking | Fixture contract and stale-binding rejections; new live general-model adapter not implemented |
| V2 | Preserve exact mcomb source and jets while transporting geometry | Normative equations and inherited browser regression; new packet migration not implemented |
| E1 | Exact point entry without minimality, rank or generator assumptions | General equation membership in reference; live short-model (0,4) test |
| E2 | Keep producer statuses separate from local assessments | UNVERIFIED transcriptions; reject forged LOCAL methods; no BSD promotion |
| R1 / G2 | Prove good reduction obscured by a short presentation | 37.a1 target certified at 2 and 3 by exact unit-discriminant/count replay; no general minimalization algorithm |
| R2 / G1 | Local-prime, valuation, Euler-polynomial, reduction type, splitting, Tamagawa sets and product consistency | Exact checks at p<=1009; bad-prime data remain source reports |
| R3 | Complete discriminant support before aggregate claims | Factorization replay and missing/unresolved prime rejection |
| F1 | Relabel displayed-model exclusions | Implemented in .30.1; current counts unchanged |
| F2 | All 84 formula cases explicitly PASS, both comparisons tallied | Implemented in new math worker: 84/84 pair and 84/84 doubling |
| F6 | Default verification never rewrites shipped artifacts | Scratch staging, worker guards, before/after hashes of source dependencies |
| P1 | Reconstruct .30 bytes from .30.1 | Strip one named insertion and restore title; exact hash required |
| G3 | Portable runtime discovery and scratch execution | Capabilities probed, actual runtimes recorded; explicit override failures are fatal; no fixed user/vendor path or downloads |
| G2a | Good-prime proof requires no imported minimality | Remove global/local minimal claims and their evidence; retain local proof with unchanged producer status and no input mutation |
| G2b | Certificate scope and exact binding | Separate strict certificate schema; bind model/context/normalization/prime/verifier and independently recount |
| G1a | Coherently forged multiplicative/additive and splitting reports | Repair flags, polynomial and factor together; exact c4/-c6 criterion must reject |
| G1b | Additive type-specific c_p sets | Check eight type families against candidate factors 1 through 5; accepted members remain unverified reports, not assertions that each member occurs on the fixture |
| G1c | Good c4=0 and characteristic boundaries | Good j=0 accepted; p=2/3 never use the p>=5 bad-prime test |
| Audit H1 | Tame additive labels agree with Delta/j valuations | Eight families, 56 competing-label forgeries, j=0, colliding discriminant values and p-unit rational transforms; no bad-prime certification |
| Audit H2 | Q conductor caps and conductor-discriminant inequality | Boundary 8 at 2 and 5 at 3 accepted, next integer rejected; f>v_p(Delta) rejected even below the cap |

## Current suite inventory

| Suite | Required PASS groups | Evidence |
|---|---|---|
| Original semantic replay | 40 | Exact models, points, transformations, context and evidence gates |
| Original independent Python | 23 | Strict schema and polynomial/differential substitution |
| New local gates | 22 | G1/G2 positive cases and adversarial records; public parser checks |
| New independent good certificates | 4 | Fraction invariants and independent finite-field recount |
| New valuation gates | 25 | All four audit forgeries reproduced against v0.2 and rejected by v0.3; tame/wild boundary and public-entry checks |
| Inherited math | 17 | Includes 84 pair PASS and 84 doubling PASS plus 52 finite-count comparisons |
| Carrier/product browser | 19 | Original behavior preserved |
| Connected-panel regression | 20 | Original mcomb connections and panels preserved |
| Maintenance browser | 3 | Exclusion labels, strict title and exact point entry |
| Runtime discovery | 9 | Discovery, overrides, capability failure and scratch execution |

These 182 groups across ten suites are builder checks. A passing group is not a new independent audit standing. The four certificate cases cover general equations at 2 and 3, a good c4=0 curve, and a p-integral rational model. The new valuation suite additionally checks preserved good-prime certification on a1-nonzero models at 2 and 3. `valuation-forgery-reproductions.json` in the scratch output contains the four complete adversarial packets for independent replay.

## Gates reserved for the production arithmetic module

- Independently replay global integral/minimal model selection, not only isomorphism.
- Check all additive Kodaira types, split and nonsplit multiplicative reduction, good reduction, and wild conductor behavior at 2 and 3 against an independent implementation.
- Pin the Tate algorithm, exact trace format, prime certificates and verifier version. Reject a claimed certificate that fails or is unavailable.
- Verify local-to-global compatibility, inventory completeness, conductor and Tamagawa products with fully assessed dependencies.
- Exercise a live model change in every panel, including a general-model point with nonzero a1/a3, old positive scaling, negative u, basis change, held source, twist, pending edit and unsupported period family.
- Add legacy BSD/mcomb packet conversion with full inherited replay. The reference checker currently declines these non-null source bindings rather than claiming migration works.
- Add exact imported point -> numerical elliptic logarithm placement, with no inferred generator status. Test real components and numerical period-adapter unavailability separately.
- Test the BSD height convention, local correction terms, bounded truncation, basis independence/saturation and regulator scaling. No height result is supplied by this package.
- Retain independent Sha orders separately from BSD-conditioned quotients.

## Review procedure

Run `node verify.cjs`. Its announced scratch directory contains logs, receipts, and screenshots. The source package is hash-checked before and after. An interrupted or failed run remains a failed/incomplete receipt, even if an earlier receipt passed. Never run a build or packaging command as an integrity check.

The shipped `receipts/` are copies from an identified local scratch run. They are evidence of those checks only. Independent review can use the same safe runner or a different arithmetic medium without modifying the pinned package.
