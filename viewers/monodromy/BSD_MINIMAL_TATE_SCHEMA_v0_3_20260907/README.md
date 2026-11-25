# Minimal/Tate audit foundation v0.3

Date: 2026-09-07. **AUDIT CANDIDATE with local verification. No independent audit or release standing is claimed.**

This additive successor addresses Fable's H1 and H2 on the audited v0.2 schema, before implementation stage T1. Read [REPAIR_NOTES.md](REPAIR_NOTES.md) for the exact rules and reproductions, [SCHEMA_FOR_AUDIT.md](SCHEMA_FOR_AUDIT.md) for the contract, and [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) for the subsequent work.

| New audit flag | Delivered change | Assessment boundary |
|---|---|---|
| H1 | At additive primes p >= 5, check the Kodaira label against exact discriminant and j valuations under the submitted minimality claim. Handle j=0 as infinite valuation. | Reject inconsistent reports; do not certify minimality or bad-prime data. |
| H2 | Enforce f_2 <= 8, f_3 <= 5, f_p <= 2 for p >= 5, plus f_p <= v_p(Delta). | Necessary conductor bounds over Q; no wild Tate branch or actual conductor computation is added. |

The independently attested G1–G3 capabilities are retained:

| Flag | Delivered change | Assessment boundary |
|---|---|---|
| G1 | At bad primes p >= 5, compare the reported reduction with c4 and splitting with the nonzero-square test for -c6. Enforce the Kodaira-specific Tamagawa value sets. | Bad-prime data remain consistency-checked source reports; minimality and the actual additive Tamagawa factor are not proved. |
| G2 | A p-integral model with unit discriminant and an exact full-equation point count produces a model/prime/context-bound good-reduction certificate. No imported minimality evidence is required for this branch. | Proves local minimality, good reduction, c_p=1 and the good Euler polynomial at that prime only. Does not certify a global minimal model, Neron normalization or BSD aggregates. |
| G3 | Discover capable Python/jsonschema and Playwright/Chromium installations; honor explicit overrides and record resolved versions/paths. | No user-specific default runtime path, implicit install, or fallback after a failed explicit override. |

The exact rational curve, twist lineage, signed transformations and differential normalization remain the organizing record. Exact point membership continues to work without minimality. Full Tate reduction, bad-prime Tamagawa certificates, heights and the live adapter for this new general-model packet are planned, not implemented here.

## Use the checker

Run `node assess.cjs fixtures/37a1-model-exclusion.json` for the worked example. It validates the strict packet schema, rejects duplicate JSON keys, then replays exact semantics. It prints a separate assessment report to stdout; it never changes the packet or the viewer's BSD register. A producer's `CERTIFIED` label alone does not cause local certification.

## Verify safely

```powershell
node verify.cjs
node verify.cjs --suite schema
node verify.cjs --suite math
node verify.cjs --suite browser
node verify.cjs --suite runtime
node check-integrity.cjs
```

`verify.cjs` defaults to all ten suites in a fresh temporary copy. Logs, receipts and screenshots stay in the announced scratch directory; source packages and dependencies are hashed before and after. Direct workers refuse to run in place. The read-only integrity command verifies the complete manifest, pins, unchanged .30.1 viewer and byte-exact .30 reconstruction. The new 25-group valuation suite is included in `--suite schema`; it also proves that the frozen v0.2 checker accepts the four audit forgeries which v0.3 now rejects.

All 84 inherited formula cases still require explicit pair PASS and doubling PASS. The .30.1 model-exclusion labels and exact custom-point entry are retained byte-for-byte. Open [the viewer](monodromy-30-1-reduction-audit.html) to use those existing features; this successor adds audit arithmetic and tooling, not a new panel adapter.

Read [RUNTIME_SETUP.md](RUNTIME_SETUP.md) for portable setup and override rules. Verification does not install dependencies. The shipped receipts record the actual runtime used, rather than prescribing that host's paths.

## Authoring and audit

The authoring sequence is `node make-schema.cjs`, `node make-fixtures.cjs`, `node make-workers.cjs`, `node build.cjs`, then `node verify.cjs`. These generation/build commands write files and must not be used as integrity checks on a pinned copy. Copy the resulting verification receipts from scratch into `receipts/`, then use `node package.cjs` to pin the reviewed state. Packaging requires every suite to pass and rejects source changes since the full scratch run.

The predecessor `BSD_MINIMAL_TATE_SCHEMA_v0_2_20260907`, schema v0.1, Monodromy.30 and Fable's audit files remain untouched. [HANDOFF.md](HANDOFF.md), [AUDIT_MATRIX.md](AUDIT_MATRIX.md), the source pins and receipts provide the next cold seat's entry points. The main packet shape and five original fixtures are retained; the stricter semantic gates intentionally reject the newly identified forgeries. Newly emitted good-prime certificates identify verifier 0.3.0 and its source hash; their dedicated schema has a new reference-version URI. Old certificates remain governed by their pinned predecessor schema and verifier. Python cross-checks in this builder run are a different arithmetic implementation, not a separate independent audit seat.
