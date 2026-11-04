# FF-1 freeze review v0.1, clarification C1 (sequencing, I1 runner, I3)

2026-11-03. Skeleton seat (Claude Opus 5.5), answering the owner's question relayed in #1376 and the runner revision in #1377. Additive: `FREEZE_REVIEW_v0_1_20261103.md` (`e7769841…`) is unchanged.

**1. Sequencing.** The closing wording of the review ("proof development … may start once the I3 job manifest for F1 is accepted") was wrong for the workflow. Corrected: with both freezes accepted, **source and proof drafting for F1 is authorized now**. **No invocation** (compile, replay, checker) until I3 is satisfied. As in the input freeze draft, the F1 30-minute wall cap covers drafting and calls together; its deadline record starts when F1 drafting starts. Time spent waiting for a skeleton acceptance is recorded and excluded from the cap. F2 starts only after a recorded F1 PASS.

**2. I1 runner revision: ACCEPTED.** `RUN_FF1_v0_2.py`, SHA-256 `c14f263caa77643e653f12fe63a3cda1bfdfa5024cfab97d2eadf5d2c6a59590`. Diff against v0.1 read in full: it adds only `assert job['lean_executable_sha256'] == sha(LEAN)` (LEAN defined at line 20) and records `lean_executable_sha256` and the expanded `LEAN_PATH` in each receipt. The Lean executable `/home/saphir/.elan/toolchains/leanprover--lean4---v4.35.0/bin/lean` was hashed by skeleton on nucleus (read-only `sha256sum` over SSH): `bf8d54e4714cc4b03d3f6bb34c83b7202b87e49c8bfcbff6895c085bb90ceb38`, equal to the owner's observation.

**3. I3, made workable for iteration.** A skeleton acceptance before every compile call would stall proof development. I3 is therefore:
- **(a) Initial I3 artifact:** a job-manifest **template** for F1, sent to skeleton for acceptance once. It fixes: phase, the allowed modes and modules, `lean_executable_sha256` = `bf8d54e4…`, the library pins of the input freeze, the frozen signature file `SIGNATURE_FREEZE_DRAFT_v0_1.md` (`a9382d40…`), the caps, and the rule that the source carries every frozen F1 signature verbatim.
- **(b)** Concrete manifests generated under the accepted template may be self-accepted by the owner (added to `REVIEW_ACCEPTANCE.json` with a timestamp and the template hash), each logged.
- **(c)** Skeleton audits every manifest, source, receipt and log at the F1 report, including a scripted comparison of the source's theorem headers with the frozen signatures. A manifest outside the template, or a changed proposition, is a stop-and-report.
- The same applies to F2 with its own template.
