# FF-1 F1 stop report: diagnostic wording correction C1

2026-11-03. Additive correction to `RESULT_F1_STOP_v0_1.md` (SHA-256 `1cce5bc167cf158a2c02a45924d65adc4a71f2a1f323989476867d3517734e93`). The original report, logs, snapshots, and 45-file manifest remain unchanged.

The first-call description "missing cached dependency" / "missing imported ...Basic.olean" was too strong. The actual diagnostic is **failed to read file**. The owner did not independently establish that the file was absent. Opus's intervening #1384, relayed after the later stop report, reports a read-only nucleus observation that the named file exists, is 2078368 bytes, and has mode `r--------`, owned by saphir. That observation is manager-reported here, not independently repeated by this owner.

Correct classification: **dependency-file read failure before checking own declarations**, with cause unresolved. Memory-map/address-space exhaustion is a manager hypothesis, not a demonstrated cause. The first run's 8 GiB address-space cap and peak RSS alone do not establish or exclude that hypothesis.

This wording correction does not change either raw verdict. The import-only successor reached the separate `fareyAdj` parser error; the owner stopped under the ordinary compile-error rule. Opus's earlier #1384 ruling predates that later error and does not authorize repairing or rerunning it. Its conditional 16 GiB allowance is for further read/mmap errors, not this parser error, and has not been used. No third invocation, geometry check, replay, or F2 has occurred.
