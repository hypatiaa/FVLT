# I3: F2 job-template acceptance

2026-11-03. Skeleton seat (Claude Opus 5.5). Answers #1393. Matched by skeleton: `F2_JOB_TEMPLATE_v0_1.json` `d1bffb5d…`, `F2_TEMPLATE_DESIGN_v0_1.md` `c1d8d8eb…`, `RUN_FF2_v0_1.py` `6ebe28fa…`.

## Decision: **ACCEPT** template, layout, certificate definition, runner and the bounded iteration policy

**Runner.** The diff against the accepted `RUN_FF1_v0_2.py` was read in full. Only these change:
- the docstring and the invocation line;
- the module is restricted to `FVLTFareyCertificatesV1` and the phase to `F2`;
- the F1 gate is now `sha(F1_AUDIT_AND_BRIDGE_DECISION_v0_1.md) == d5470d9b…` (skeleton's recorded PASS), replacing the historical `F1_VERDICT.json` check.

Everything else (host and Tailscale asserts, executable hash, review and manifest hashes, limits, library checks) is byte-identical. **Accepted.**

**Template (scripted check).**
- All 16 `frozen_headers` occur verbatim in `SIGNATURE_FREEZE_DRAFT_v0_1.md` (`a9382d40…`): 16/16, 0 failures.
- Pins equal the accepted records: executable `bf8d54e4…`, checker `9c6f2ac1…`, the five v19 pins.
- The isolated F1 arithmetic pair (`2760392f…` source, `202d39c1…` object, the latter reproduced by skeleton's own compile) is accepted.
- Caps are identical to F1's: 1 CPU, nice 19, 8 GiB, `-M7680`, 240 s per call, 1800 s active, serial, no retries.

**Layout.** One additive helper module, `FVLTFareyCertificatesV1.lean` in namespace `FVLT.FareyContactV1`. It imports the exact accepted F1 arithmetic module plus Mathlib, with no geometry import and no G1. F1 bytes stay unchanged. **Accepted** as implementation packaging, with no new mathematical claim.

**`ComponentCertificate` definition.** The design's body is exactly the five frozen clauses: nonempty parts, coverage, pairwise disjointness, connected induced subgraph per part, and no edges between distinct parts. **Accepted** as the frozen definition body. The implicit `{V : Type*}` binder on the definition is fine; the frozen theorems keep their explicit `(V : Type*)`.

**Condition.** Every frozen definition that a frozen F2 header uses must appear verbatim from the signature file. That includes `phaseGraph` (used by `fixture421_counts` and `fixture92_counts`) and anything it depends on, not only the eight definitions the design lists. Skeleton's comparison script checks this at the F2 report.

**Iteration policy: EXPRESSLY ACCEPTED.** Bounded proof-body iteration, as in D2: serial calls, each concrete job self-accepted after this acceptance and snapshotted; local steps, tactics and `private` helper lemmas allowed, each listed in the report.
- **Hard stops regardless:** a changed frozen proposition or definition, a forbidden axiom, an unsafe or partial target, `native_decide`, or a strict-checker failure.
- **Budget expiry:** F2 FAIL (feasibility not shown within the cap), not an inferred obstruction; return the evidence.

**Before starting.** Re-observe the latest library version, the full pins, the read-only state and current capacity. A version change returns for review. F2's own deadline starts at proof drafting. No F1 timing allowance transfers.

**F2 PASS requires:**
- all 16 headers proved;
- the (4,2,1) and (9,2) certificates themselves checked, not only their counts;
- `#print axioms` showing only `propext`, `Classical.choice`, `Quot.sound` for every written theorem;
- the strict checker on all target constants;
- library checksums before and after;
- skeleton's audit, which includes skeleton's own recompile and replay.

Not covered: the bridge build (only after F2's recorded outcome; paperwork may continue), the rest of Stage A, FF-2, Stage B, library sync, commits, Neo compute, G1, S4r-C.
