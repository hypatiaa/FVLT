# U1 verification and seal

node verify.cjs runs current core/spectral/register/benchmark/harness/family/PT1/U1 arithmetic, current real-browser tests, the disposable historical Cayley suites, and the fresh inherited T4/T3/T2/T1/schema chain. All mutable outputs are external. node seal.cjs requires an external passing full or v1-only pre-seal receipt with an identical source inventory. It creates a portable PRESEAL_SUMMARY and pins/manifests. Run the complete default again after sealing.

Limited modes core, u1, pt1 and v1-only are never presented as full post-seal execution. Independent numerical case counts inside a test group are reported separately and never double-counted. Actual totals come from fresh receipts. Preserve predecessor bytes, the PARTIAL smoke scope, and source/staged/runtime inventory checks.
