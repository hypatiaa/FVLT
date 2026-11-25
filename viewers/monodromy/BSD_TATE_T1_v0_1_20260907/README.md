# T1: exact model adapter and local proof records

Additive audit candidate, 2026-09-07. This package extends the frozen minimal/Tate schema v0.3. Its builder verification does not inherit Fable's cold-audit standing or award a lock.

The exact rational curve remains the anchor. T1 clears denominators, obtains candidate minimal models from a pinned PARI process, replays every model change and selected-differential factor, and binds the resulting context to all six panel contract entries. Parent bytes, twists, markings and repeated exact point visits survive transport. This is a packet-level foundation; the Monodromy.30.1 viewer remains byte-identical and does not yet consume these packets.

Two local terminal proofs are implemented within **2 <= p <= 1009**:

| Local condition on the replayed p-integral model | Assessment |
|---|---|
| Unit discriminant, including at 2 and 3 | Local minimality, good reduction, exact N_p/a_p, Euler polynomial, c_p=1 |
| Positive discriminant valuation and unit c4, p >= 5 | Local minimality, split/nonsplit I_n, conductor exponent 1 and the exact local Tamagawa number |
| Additive reduction or bad reduction at 2 or 3 | Explicit UNAVAILABLE certificate; the PARI result remains a source report checked by v0.3's consistency gates |

The first bad-prime certificates therefore have a small, explicit scope. Full Tate, global minimality, a Neron differential, the conductor/Tamagawa product, heights and BSD promotion are not delivered here. A complete **model-discriminant** factorization is still not a certified curve-level bad-prime inventory.

## Run and inspect

From this package directory:

```powershell
node verify.cjs
node verify.cjs --t1-only
node build.cjs --input example-input.json 37 > candidate.json
node assess.cjs candidate.json
```

The default verifier stages all inputs in a new temporary directory, runs T1 and Python checks there, then runs all inherited v0.3 suites in another scratch copy. Workers reject in-place runs. Source packages, audit reports and runtime bytes are checked before/after. The final receipt path is printed. `--t1-only` explicitly omits inherited regressions.

`build.cjs --record predecessor-record.json 37` accepts a schema-v0.3 curve record and preserves its original bytes. Custom input has exactly `ainvs`, `selectedMultiplier`, and `points`; all numeric values are canonical rational strings. `seed()` in `t1.cjs` checks exact point membership without a backend, minimality or reduction data. Membership makes no order/rank assertion.

The build CLI requires the arithmetic runtime; offline proof replay of an existing packet does not. Public `assess.cjs` validates strict JSON schemas (including duplicate-key rejection) before arithmetic replay. To recheck a claimed certificate, use `node assess.cjs packet.json certificate.json`. Internal `t1.cjs` routines expect structurally validated objects.

## Runtime and provenance

Node and Python/jsonschema use the inherited capability-based runtime discovery. No paths to a particular user's Python or browser appear in the implementation. Overrides remain `BSD_AUDIT_PYTHON`, `BSD_SCHEMA_PYTHON_VENDOR`, `BSD_AUDIT_PLAYWRIGHT`, and `BSD_AUDIT_CHROMIUM`; an invalid explicit override fails. The runner also sets the inherited worker's `BSD_AUDIT_PLAYWRIGHT_MODULE` from the resolved module.

The arithmetic adapter uses workspace-local **PARI GP WebAssembly 2.17.4, revision f24e5d7cc5**, under Node. `BSD_T1_PARI_DIR` overrides the default sibling `.bsd-arithmetic-runtime` directory. Both runtime files are SHA-256 pinned in `pari-adapter.cjs`, and the verifier copies only these pinned files to scratch. The runtime was retrieved from PARI's official [GP page](https://pari.math.u-bordeaux.fr/gpwasm.html). No system installer, WSL, package download or installation is invoked by the build/verification code. The URLs can change upstream; a hash mismatch requires a new reviewed pin, never a silent fallback.

The planned Sage-first order was adjusted because Sage and WSL are absent on this host. The portable PARI producer is live-tested. `sage-producer.py` supplies a separate-host generic-Tate producer with `algorithm='generic'` and `proof=True`, source-module hashes and explicit tuple direction. Its **syntax is checked; live execution, receiver integration and a Sage/PARI comparison remain pending**. It is a producer scaffold, not a second oracle receipt or a full branch trace. The first receiving seat must pin that actual Sage distribution and sources before using it.

See `CONTRACT.md` for the proof boundary, `HANDOFF.md` for audit targets, `NEXT_STEPS.md` for the remaining work, and `receipts/` for the frozen builder run. No predecessor bytes are replaced.
