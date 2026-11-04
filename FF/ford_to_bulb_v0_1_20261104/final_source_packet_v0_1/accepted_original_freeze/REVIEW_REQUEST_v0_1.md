# FF-4 input/signature/runner review request

2026-11-04. Accepted work order v0.2: `d28dfd0ebbc49d1677e4765b492ec35450b7c842054b85bc7834c6d2f124b2d8`; owner acceptance: `6e5c8b61ed4bd4bf6467bec2277a5cf47eb6ee7010b86a1a1daf418bcb8ec554`. Robin's existing direct FF-4 go persists. This packet is proposed review material, not an execution acceptance or a request for duplicate human permission.

Please review and decide separately:

1. The closed input snapshot: then-latest v23, 401 full checksum successes, zero writable files, Lean 4.35.0 executable and Mathlib revision, actual FF-1 source closure, exact inherited audit/readiness records and prior-art/evidence scope.
2. The exact 31 data declarations in `FF4_DEFINITIONS_PROPOSED_v0_1.lean.txt` and 33 public targets in `FF4_HEADERS_PROPOSED_v0_1.lean.txt`/`TARGET_INDEX_v0_1.json`, including representation and target decomposition in `API_AND_SCOPE_NOTES_v0_1.md`. Keep B6 absent and C1 general.
3. Fresh `RUN_FF4_v0_1.py`, the pinned strict checker and `JOB_TEMPLATE_v0_1.json`. The diff and static-only validation are included. No Lean elaboration or mathematical test has yet occurred.
4. **Requested FF-4 policy:** accept all-match bindings on exact posting, where only status plus the four enumerated binding fields differ; every concrete job still posted before launch. These are requests, not an assumption that FF-3's policy automatically transfers.
5. **Requested bounded proof iteration:** a failed compile stops its item/dependents and is preserved; proof-only retries use fresh additive attempts, unchanged data/public headers, comparison receipts and exact posted jobs. Any definition/header/scope change, wrong axiom set or genuine strict-replay failure returns for review. Each 1800-second batch begins before proof writing/staging and is never reset or extended; fresh batches need fresh bindings.

Final acceptance still requires a clean independent integrated rebuild, named reports and all-introduced-constant replay, followed by a separate fidelity review. All Lean/Sage computation is on nucleus over Tailscale under the resource caps; no Neo compute or G1 dependency. No viewer/kernel edit, sync, commit, release or publication is included.

If a definition or header needs repair at first elaboration, it returns for review even if the intended mathematics appears unchanged. Routine private proof repairs follow only the policy actually granted. The concrete-job and review-acceptance examples are non-dispatchable schemas, with no capacity reservation, frozen-signature binding or accepted job supplied.

The review packet manifest is assembled last and does not hash itself. Future real bindings will name its hash and the actual manager decision. Preserve these bytes; produce successors for any changes after posting.
