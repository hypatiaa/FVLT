# M4 v0.3 verification

Build: node build.cjs. Development checks: node verify.cjs m4. Qualifying verification: node verify.cjs (full default), including all inherited arithmetic and browser suites. Workers require an external scratch copy and write mutable output outside all package seals.

The added walk worker exercises exact product targets, the complete4! walk, reachability, fractional and signed gear/spin inputs, universal alignment, off-axis and individual tooth sides, amplitude sign/zero, between shells, stale/false packet claims, strict parsing and bounded export. Its independent loops compare rational divisibility and per-tooth trigonometric phases. Both tests and implementation preserve numerical versus exact distinctions.

The added browser worker drives base, spin, shell, gearbox and comb controls, observes exact selections, tests geometry stability during the shell walk, manual/live/held transitions, repeated visits, export/fresh-page replay, rehashed forgeries, asynchronous races and the absence of BSD promotion. Fractional shell and amplitude edge cases use explicitly labelled host-state seams. Desktop and narrow screenshots are external outputs. Existing v0.2 browser tests are retained, with an explicit manual Div12 setup because the new default is the shell walk and initial s=0 has no finite atom.

After a full pre-seal PASS, node seal.cjs <external receipt> verifies that all assessed source bytes are unchanged and writes the seal. Then run node verify.cjs again in full default mode. node check-integrity.cjs must pass after every sealed suite. The source and all staged predecessors are inventoried before/after; manifests and source pins must remain unchanged. Seal creation rejects partial development-mode receipts.

Actual counts and provenance are carried by PRESEAL_SUMMARY.json and the external post-seal verification.json/SUMMARY.json. Never infer a post-seal pass from the pre-seal result, or independent audit from builder tests. The LF1 eight-check browser smoke retains its declared PARTIAL scope; no CAP acceptance is inferred.
