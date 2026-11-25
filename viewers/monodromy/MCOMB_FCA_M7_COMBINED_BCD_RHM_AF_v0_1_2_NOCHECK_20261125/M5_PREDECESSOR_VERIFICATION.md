# M5 verification procedure

From the package, run node verify.cjs. It stages disposable copies and writes all results externally, preserves source/staged inventories, includes the new structure and structure-browser suites, all inherited M4/viewer checks and the1040-check arithmetic chain. The historical eight-check Cayley smoke remains PARTIAL in declared scope with passing checks; it is not promoted to full coverage.

Development-only node verify.cjs m5 runs the new arithmetic and browser suites. It does not qualify a seal. After final source and documentation are ready, run the full default verifier, seal using node seal.cjs <external-verification.json>, then rerun node verify.cjs on the sealed package and run node check-integrity.cjs. Full receipts must correspond to unchanged source bytes. Keep logs, screenshots and copied receipts outside the sealed directory.

The M5 arithmetic suite compares180 small graphs with independent adjacency construction and brute-force clique counts, tests S1/S2, general-t membership and lifting, rejects forged rehashed certificates and nested-source modifications, and checks predecessor byte preservation. The browser suite uses actual controls, Blob workers, export/import, source changes and deterministic delayed responses. No mocked browser test is counted as a browser PASS.
