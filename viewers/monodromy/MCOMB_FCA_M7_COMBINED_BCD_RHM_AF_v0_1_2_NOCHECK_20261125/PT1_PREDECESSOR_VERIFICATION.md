# PT1 verification and output isolation

Default node verify.cjs runs all inherited viewer suites, new PT1 arithmetic/forgery/independent checks and PT1 browser lifecycle checks, then the entire 1,040-group T4/T3/T2/T1/schema chain. Worker receipts require explicit PASS. The eight-check inherited smoke harness retains overall PARTIAL scope. The old strict 84 pair and 84 doubling counts remain mandatory in its unchanged harness.

The runner inventories source and staged packages before and after every run, including failure, and checks pinned runtime bytes. Workers refuse in-place execution. The legacy Cayley harness runs in its own disposable fixture. Outputs remain outside the immutable staged source. The candidate stores no benchmark runtime path or mutable worker receipt; test-harness.worker.cjs verifies this and its pre-seal manifest summary after sealing.

New independent arithmetic uses Python Fraction in a different coordinate system, checks all subgroup pair sums and associativity, signed small multiples, and brute-force counts at every supplied prime for all 18 reference fixtures. Its 18 inner case checks are recorded separately and are not added again to the top-level suite total.

Use node verify.cjs pt1 for only PT1 mathematical and browser checks, core for non-browser worker suites, and v1-only for viewer plus PT1 without the inherited arithmetic chain. These modes are never described as a completed default run. Test counts are taken from actual receipts, not the older v0.8 count of 440 viewer + 1,040 arithmetic groups.

Seal with node seal.cjs followed by the path to a successful external full or v1-only receipt. It validates the receipt, source inventory, deterministic build and every required suite, then writes a portable PRESEAL_SUMMARY.json, external pins and the manifest. After that, run node verify.cjs with no mode argument and retain its fresh receipt in the external post-seal evidence directory. Never copy a changing receipt into the sealed candidate.
