# Computable bridge runner: exact change summary for review

2026-11-03. `RUN_BRIDGE_v0_1.py` is prospective and **not run**. Compare against accepted `RUN_FF2_v0_1.py` (`6ebe28fa70fd5b1a68778bf5e6b4b4a254cc3ad975764e6372797231f63c68ef`). A machine-generated unified diff is supplied separately. This summary does not substitute for reviewing those exact bytes.

- Uses the isolated `computable_bridge_v1` child directory, adding the original accepted F1 root second in LEAN_PATH.
- Permits producer/proof compile and replay modules, and a separate smoke driver's `execute` mode. The smoke driver can only execute, cannot be a strict theorem-replay target, must be flagged finite evidence, and pins the producer object. The theorem module may contain the declared noncomputable embedding; the producer remains separate.
- Requires a final template review reference, recorded F2 outcome flag, exact F2 outcome file hash, signatures/input review records, runner hash, reviewed file hashes and accepted concrete manifests before calls. The actual outcome binding is pending manager recording/review.
- Checks the exact isolated F1 source/object pair, including the producer's geometry object `ea5dc4ce…`, before and after each call; the bridge never overwrites these files. Checks the manager's F1 PASS record too.
- Restricts own reviewed/source/dependency paths to the bridge root; F2 outcome record is a basename under the parent root. F1 dependencies are separately pinned constants. No F2 module/object is imported.
- New phase `BRIDGE` and its own deadline. Same 8 GiB, 1 CPU, nice19, internal Lean memory/stack/thread flags, 240-second per-call bound, serial exclusive lock, output/process caps, timeout process-group termination and full library checksum checks.
- Receipts record expanded LEAN_PATH, executable hash, exact dependency and outcome pins, and distinguish finite executable evidence from proof replay.

Before any call, Opus still must accept the actual runner/final template with the F2 outcome record and fresh latest-library/input/read-only/capacity observations bound. This draft does not create those records, stage proof sources, start a deadline or run a worker.
