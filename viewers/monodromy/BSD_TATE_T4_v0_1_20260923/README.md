# BSD Tate T4 v0.1 — global reconciliation

Date: 2026-09-23. Additive successor to the sealed T3 v0.1 package. Builder candidate; cold audit and lock ruling are separate.

T4 reconciles the replayed T2/T3 local reductions with one integral model over Q. When the model-discriminant factorization is complete in the declared domain, its public gate certifies the global minimal model, minimal discriminant, curve bad-prime inventory, conductor, finite Tamagawa product, and Néron differential up to sign. Exact transformations, signed differential factors, selected differential, twist history, marking, point visits and six panel bindings accompany that result.

The certificate is computed from the bound parent bytes. It does not depend on PARI. `pari-comparison.cjs` provides a separately recorded comparison against the hash-pinned PARI 2.17.4 runtime. Agreement is not an additional proof or authentication of a transcript.

## Run

From this directory, with Node and a Python environment containing jsonschema:

```text
node build.cjs --input example-37-input.json > ../t4-packet.json
node assess.cjs ../t4-packet.json
node pari-comparison.cjs ../t4-packet.json
node check-integrity.cjs
node verify.cjs
```

Write generated output outside the sealed package. PowerShell 7 or a shell preserving UTF-8 should be used for redirected JSON; with older PowerShell, use a Node subprocess and `fs.writeFileSync` rather than its UTF-16 redirection.

`--input` accepts exactly `ainvs`, `selectedMultiplier`, and `points`, with exact rational strings. Alternatively, `--record existing-record.json` consumes a validated v0.3 exact-curve record. `assess.cjs packet.json certificate.json` replays an exported certificate rather than trusting its labels.

`build.cjs` prints a packet on stdout and its PASS/UNAVAILABLE state on stderr. An unresolved factor produces a valid partial packet with exit 0 and no global certificate; callers must inspect the assessment. Invalid input, rejected claims and exceeded work caps fail with exit 1. `construct` and `replay` are internal arithmetic APIs; use `assess` for untrusted JSON and duplicate-key checks.

`verify.cjs` stages all dependencies and runs the T4 suites followed by the complete frozen T3/T2/T1/v0.3 chain. `--t4-only` limits the staged run to the new suites. Workers refuse in-place execution. No install or download occurs. Runtime discovery and overrides are inherited: `BSD_AUDIT_PYTHON`, `BSD_AUDIT_PLAYWRIGHT`, `BSD_AUDIT_CHROMIUM`, and `BSD_T1_PARI_DIR`. An explicit invalid override fails without fallback.

## Boundaries

- Prime factors through 1009, at most 24 distinct listed source primes; unresolved factors prevent global certification.
- A global minimal model need not be the canonical reduced representative chosen by PARI. Exact isomorphisms establish agreement.
- The Néron normalization and real-component count are exact. No real period value, elliptic logarithm, height, rank, regulator, L-value or Sha order is computed here.
- These are linked **record** bindings. The existing viewer is unchanged; live mcomb intake and atomic panel switching remain V1. Non-null legacy/mcomb provenance is still outside the frozen record adapter's accepted domain.
- Point membership is checked on the supplied nonsingular model before any minimality result. It is not contingent on global reduction succeeding.

Read [CONTRACT.md](CONTRACT.md) for the proof and trust boundary, [VERIFICATION.md](VERIFICATION.md) for receipts, and [HANDOFF.md](HANDOFF.md) for cold review and the next construction.
