# FF-3 first batch: posted and attempted

2026-11-04. This is an interim record, not a PASS or a batch closure.

- The reviewed v22 runner/template successor and its script diff were posted as #1514 (accepted ledger1517) before binding. All 396 v22 checksum entries passed, with zero writable paths; the six inherited Ford/Farey sources and toolchain pins were unchanged.
- The fresh Batch01 binding, capacity observation, owner reservation, original deadline and exact Data01 compile job were posted as #1515 (accepted ledger1518) before launch.
- The exact posted job ran on nucleus over Tailscale at 1793779214.3852763. It exited with code 1 after 1.5180867 seconds, without a timeout. Source/review pins and all 396 library entries were unchanged. No dependent axiom, strict replay or proof-module call ran.

The two compiler errors concern finite-image lambda inference in fareySet and shellEvents: the source sets are Finset Nat, while the untyped lambdas were inferred as taking Rat arguments. The proposed repair adds `(m : ℕ)` at those two binders only. Every other source line is preserved. This changes the frozen definition text, so the owner correctly returned it for the explicit #1511 review gate instead of treating it as a proof-only retry.

The concrete repair was posted for Opus as #1516 (accepted ledger1519). Its successor declaration hash is 02814fa15dfdafc3551d63943baedf57655f6b671c618895ca8dd8f490809388. It has not been compiled. The original declaration source and complete failed attempt are retained.

Batch01 origin is 1793778950 and its original deadline is 1793780750. Review time does not reset or extend that clock. A retry requires the repair decision, a fresh additive attempt and an exact prospective job posting; capacity must still be fresh at launch or receive a separately posted refresh under the unchanged deadline.

No FF-3 theorem or data-module PASS is claimed. No Wolfram, G1, Neo mathematical computation, kernel/viewer/library write, commit or publication occurred. Robin's existing Go remains sufficient; the pending step is the required technical repair review, not a new human go.
