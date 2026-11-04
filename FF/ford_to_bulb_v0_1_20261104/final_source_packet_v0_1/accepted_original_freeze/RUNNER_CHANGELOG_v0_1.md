# Proposed FF-4 runner: review changes

2026-11-04. This runner has not been imported or executed. Python grammar and an extracted pure text-check function have been tested; no host/process logic, Lean or Sage was invoked.

Predecessor: accepted FF-3 v22 runner `643fef3438bd81e77b2471951724e8628ab6a93ccf9f1852c670990d09799eeb`, retained under `inputs/harness_predecessor/`. The exact proposed diff is `RUNNER_DIFF_v0_1.patch`.

Changes:

- Fresh root `/home/saphir/fvlt_formalization_20261104/ff4_v01`, phase `FF4_COMBINATORIAL`, and three FF-4 module names. No old FF-3 module is an executable target.
- Current library v23 with all five metadata pins, full 401-entry readonly checks and a latest-version guard. Any later library requires binding review.
- New data/header/target files and namespace. The runner directly re-hashes the frozen definition and header files.
- A pure preflight checks exact data bytes and every present public theorem header against the pinned target index. It rejects unreviewed public declaration kinds, attributes, duplicate/unknown names, indentation wrappers, CRLF/BOM and changed definitions. Expected incremental target subsets remain allowed. Present-target inventory is checked against the external comparison receipt and recorded in the runtime receipt.
- Scope exclusions are FF-4's: exact doubling cycles are included; analytic quadratic dynamics, landing/wake/limb claims and B6 are excluded. A blanket exclusion of all dynamics from FF-3 would misdescribe FF-4 and is not carried over.

Unchanged controls include Tailscale/host enforcement; reviewed exact job hashes; pinned all-match binding; fresh capacity age 0..600 seconds; one CPU; 8 GiB address space; Lean `-j1 -s65536 -M7680`; 256 processes; 64 MiB output; 240-second child cap; 1800-second batch deadline beginning before proof writing/staging; a single-run lock; fresh own output; source/dependency/import-closure pins; successful prerequisite receipts; G1 exclusion; standard named-axiom parsing; all-constant strict replay; unchanged-source/protected-file/library checks; raw logs and additive runtime receipts.

The all-match binding and proof-only retry policies are requested for FF-4's own manager decision. A hash in an example, this changelog or a proposed template is not execution acceptance. No actual `REVIEW_ACCEPTANCE.json` or bound job exists in this packet.
