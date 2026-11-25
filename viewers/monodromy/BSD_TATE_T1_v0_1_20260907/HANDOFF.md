# Cold-seat entry: T1 v0.1

This additive folder is an audit candidate. No standing, lock or release is awarded by the builder. The cold-audited predecessor is schema v0.3, whose Fable report and receipt are source-pinned alongside the predecessor manifests and source files.

Read `README.md`, `CONTRACT.md`, both JSON schemas, `t1.cjs`, `pari-adapter.cjs`, the public structural gate and the two test sources. The new code calls the pinned predecessor exact arithmetic and consistency gates; the old viewer is not copied or patched. The six panel contract entries are transported in packets, while live consumption remains V1 work.

Run `node verify.cjs`. It checks available manifests/pins, discovers dependencies, stages all source inputs, and executes workers only in scratch. It then invokes the full frozen v0.3 verifier from the staged tree. Inspect both scratch receipts and source inventories; the tests do not overwrite pinned results or screenshots. `receipts/` holds the builder's selected frozen rerun. The top-level manifest intentionally excludes itself; `SOURCE_PINS.json` pins external lineage/runtime inputs.

The core witness is y^2=x^3-16x+16 with P=(0,4). The composite (2,0,0,4) gives y'^2+y'=x'^3-x', P'=(0,0), multiplier 1/2 from source multiplier 1. The local proof at 37 is nonsplit I1 and c_37=1. It proves minimality at 37 from c4 being a unit; it does not certify global minimality or a Neron differential.

Adversarial audit targets:

- Repair hashes after changing a tuple, signed scale, selected differential, point index, context/marking/panel binding, residue or complete root list. The corresponding exact replay must reject.
- Change all dependent split/Euler/Tamagawa fields coherently. Actual residue proof must still reject wrong splitting or c_p.
- Replace an unsupported additive/wild terminal by a fabricated supported result, or add a certificate to an unavailable outcome.
- Forge an incomplete model inventory as complete or as curve-level bad primes.
- Alter a backend claim/transcript coherently: transformation replay, matching local results and inherited H1/H2/G1 gates must remain active. Backend origin/status is never proof.
- Exercise schema unknown fields/duplicate keys, out-of-domain primes, non-p-integral local models, noncanonical rationals, invalid runtime override and in-place worker refusal.

The builder's Python check uses polynomial substitution, independent discriminants, quadratic-discriminant Legendre counts and singular tangent cones. It does not import the JavaScript formulas. This is methodological cross-checking by the builder, not a second seat. Sage generic Tate remains live-UNAVAILABLE; its scaffold has only syntax validation. The exact packet itself can be replayed without the PARI runtime, but regenerating backend reports requires the pinned runtime files. No auto-download path exists.

Next construction after review is T2, with the separate Sage producer comparison outstanding as stated in `NEXT_STEPS.md`.
