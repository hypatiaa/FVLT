# BSD Tate T4 v0.1 — build and sealed verification

**Builder result: PASS, 1,040 groups. Cold audit pending; no lock ruling.**

The additive [T4 package](BSD_TATE_T4_v0_1_20260923/README.md) now reconciles T2/T3 local certificates with one integral global minimal model over Q, within its declared domain. It certifies the minimal discriminant, complete curve bad-prime inventory, conductor, finite Tamagawa product and Néron differential up to sign. Every claim is reconstructed from the parent bytes, with exact model maps, signed differential scaling, selected normalization, twist/marking identity, exact point visits and six record bindings retained.

This closes the T4 implementation step in the existing plan. It does not confer T3's independent standing on the successor, calculate heights, or claim BSD.

## What changed

A local minimalization may use rational translations with denominators at other primes. T4 converts it to an integral tuple with the same p-power scale, including the necessary t cross term, then verifies that later changes preserve each previous local minimum. Full discriminant support plus those local proofs establishes the global result. PARI supplies a separately recorded comparison and never supplies a certificate input.

For the non-minimal input `y^2=x^3-16x+16`, the result is `y^2+y=x^3-x`, with discriminant 37, conductor 37 and Tamagawa product 1. The exact map is `x=4x'`, `y=8y'+4`; the target differential pulls back to twice the source differential. The source-model exclusion at 2 becomes certified good reduction. Real-period fields record exact scaling factors and real-component count, with the period value explicitly not computed.

An unresolved discriminant cofactor blocks the global certificate. The two partial controls retain certified listed-prime results and explicitly scoped partial products, while global minimality, Néron status and aggregate remain unassessed. Exact point membership remains available before reduction succeeds.

## Reproduced after sealing

| Suite | JavaScript / inherited groups | Python groups |
|---|---:|---:|
| T4 | 76 | 44 |
| T3 | 225 | 190 |
| T2 | 127 | 99 |
| T1 | 66 | 31 |
| v0.3 schema, arithmetic, browser and runtime chain | 182 | included |
| **Total** | **1,040 across both columns** | |

All 42 complete T4 fixtures explicitly PASS; two controls explicitly remain UNAVAILABLE. The 42 live PARI comparisons agree on minimal discriminant, conductor, Tamagawa product and exact isomorphism. The T4 fixtures, test receipt and Python receipt reproduced byte-for-byte. The inherited formula tally remains 84 pair PASS and 84 doubling PASS.

Public-gate forgeries were rejected, including altered products, prime support, local maps/certificates, normalization signs/factors, component count, panel bindings, parent bytes and duplicate keys. The tests also cover changing local-minimization order, rational inputs, general coefficients, signed prior transformations, twists and repeated point visits.

The scratch runner confirmed that all source packages, pinned audits, host plan and arithmetic runtime remained unchanged. Direct workers refuse in-place execution. The full [sealed verification receipt](BSD_TATE_T4_v0_1_SEALED_VERIFICATION_20260923.json) includes the actual suite receipts and source inventories; SHA-256 `2fd827e34cf4f246395ed93dfb90f233f7067d26c5480bec1a556cebbc9682ad`.

## Seal and scope

T4 manifest: **26 entries**, SHA-256 `269a052593babfef65a7fe4529f9db42dae48176bf985e7796b63022337d9f39`. All **26 external pins** and recursively checked predecessor manifests match. T3 remains at `ea0d0bbe2939610e5d2405eba1ef9d548288f122f779566f2fe5ba1e596c10be`.

Supported factorization is bounded by 1009, with at most 24 listed source primes and the inherited rational/record/work caps. An unresolved factor cannot be promoted by trusting a backend report. A global minimal model is not claimed to be PARI's canonical reduced representative. These are executable exact-replay certificates, not proof-assistant proofs.

## Current viewer and remaining work

Robin identified **Cayley M3 camera2 LF1** as the current viewer during this build. Its preview hash is `ebaaa76592733400cf8ccaa85eb1ad0ce73c1db6d7c56688241fcd91c9323285`, and all 117 entries in its manifest were checked. Its source package and preview were not modified. Its runtime suites were not rerun here; its own stated local PASS/unseated standing is unchanged.

The [latest-viewer baseline handoff](BSD_V1_LATEST_VIEWER_BASELINE_20260923.md) binds that selection to the T4 seal. **V1 must extend this Cayley source package**, preserving its current capture, packet, graph, camera and inspector behavior. The older viewer is only an inherited regression dependency. The 1,040-group result must not be read as a runtime test of the Cayley LF1 viewer.

Next: cold-audit T4; integrate its assessment into all six live panels on that baseline; add supported elliptic-logarithm point placement; implement numerical then rigorously bounded heights; establish basis/saturation evidence before calling a height determinant the curve regulator; and complete the L-function/rank/period/BSD comparison. Any Sha inferred through BSD must remain conditional. Sage on Serena/Nucleus is still a separate, unrun comparison item.

The [T4 cold handoff](BSD_TATE_T4_v0_1_20260923/HANDOFF.md) and [proof contract](BSD_TATE_T4_v0_1_20260923/CONTRACT.md) give the exact review targets and boundaries.
