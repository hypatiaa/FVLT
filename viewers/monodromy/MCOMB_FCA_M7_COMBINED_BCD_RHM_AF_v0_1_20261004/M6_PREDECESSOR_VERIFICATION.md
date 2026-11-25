# Verification procedure

Run node verify.cjs from the package for the full default run. It copies the candidate, sealed predecessors and pinned external inputs into scratch, runs real arithmetic and browser workers, and verifies source and scratch inventories unchanged. Receipts are external. After a full pre-seal PASS, run node seal.cjs with the external receipt path. Then run node verify.cjs again without arguments. Finally node check-integrity.cjs must pass. No post-seal source edits are permitted.

The history suite includes W1/W2, 180 independent word/count cases, atom wraps, all work-cap outcomes, prime arithmetic, complex-lane evolution, nested replay, 11 rehashed attacks, duplicate keys, and the three M5 audit observations. Browser checks use the assembled viewer with external HTTPS blocked, including standalone-file mode. The inherited historical Cayley smoke retains its declared PARTIAL scope even when all its checks pass.

No independent cold-audit or lock result is asserted here. The external final handoff binds the actual receipts and manifests.
