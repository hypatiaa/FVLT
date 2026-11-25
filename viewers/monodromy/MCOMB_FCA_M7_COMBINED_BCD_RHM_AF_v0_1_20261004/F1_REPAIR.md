# F1 repair: sealed verification output isolation

The source-pinned V1 v0.3 cold audit found that `node verify.cjs` could not reproduce after sealing. The benchmark worker overwrote a sealed receipt in the assessed scratch package. Its absolute runtime path changed on each run, so the server correctly rejected the modified inventory. The earlier builder PASS was from before sealing; a later live-launch check did not test this failure path.

V1 v0.4 preserves that predecessor and changes the harness rather than bypassing the integrity check:

1. Each V1 worker writes receipts, browser downloads and screenshots through `outputPath(name)`, into `<scratch>/run-output/v1/`. It reads code and frozen artifacts from the separately staged package. Absolute/path-traversal output names are rejected; direct in-place workers remain refused.
2. The benchmark's runtime path remains useful run provenance. It is permitted to differ between fresh receipts. Packaged historical receipts are never overwritten by verification.
3. The old Cayley harness writes in place, so it receives a disposable clone in `<scratch>/run-output/cayley-fixture/`. Its preview substitution and results cannot mutate the pinned LF1 copy used by the server.
4. The runner checks fresh machine receipts for explicit PASS, preserving the inherited smoke suite's declared PARTIAL scope. It checks both source and staged package inventories, audit files and runtime bytes after all work, including a failed job.
5. When a manifest exists, the staged seal is checked after the non-browser workers and after all suites. The source seal is checked again as well. The report records `sealedAtStart` and the exact `sourceManifest`.
6. Release preparation requires sealing first and then successfully running the default `node verify.cjs`, including the inherited T4 chain. That post-seal receipt is kept outside the package, with its candidate manifest hash. Copying it into the sealed candidate would change the candidate being attested.

The six added harness checks exercise output placement, path rejection, in-place refusal, fresh explicit PASS receipts, preservation of v0.3's sealed benchmark and preservation of the candidate's benchmark when sealed. The final post-seal run is the decisive regression test for F1. Pre-seal testing alone does not close it.

Runtime behavior is unchanged: server and fixed T4 endpoint, client authentication and retry handling, exact arithmetic worker, spectrum, identity display and benchmark evidence boundaries retain their v0.3 bytes. Only build metadata identifies this additive package. The cold audit's socket-idle-timeout observation remains an unmodified observation, not a defect claimed repaired here.

See the adjacent v0.4 build report and external post-seal evidence for actual execution status. This document describes the repair and required checks; it does not grant independent audit, seating or lock.
