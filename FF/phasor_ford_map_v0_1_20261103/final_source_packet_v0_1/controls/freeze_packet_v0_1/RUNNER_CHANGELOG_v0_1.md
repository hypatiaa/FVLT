# Prospective FF-3 runner changes

This is review documentation; the runner has not been executed.

Base: the FF-2 runner RUN_FF2_v0_1.py, SHA-256 6a73ec377654b82d35e0981b2a16216fa88e507420ef52d990a00f055afd2860. That file is unchanged.

The successor changes the isolated root to /home/saphir/fvlt_formalization_20261104/ff3_v02, pins latest library v21, changes the phase tag to FF3_DISCRETE, and permits only the five declared FF-3 modules. It retains the inherited checksum, source/receipt pin, own successful compile, single-run lock, process-group timeout, standard strict replay, read-only library, CPU affinity and resource-limit checks.

Additional guards and records:

1. Capacity age must be between 0 and 600 seconds, excluding future-dated observations.
2. Every own source is scanned for admissions, added axiom tokens and forbidden escape mechanisms. Ambient section-variable declarations are refused, preserving the explicit-binder requirement. The reviewed comparison must attest exact data and all present public headers.
3. Imports are traversed through pinned local/new and inherited project sources. Imported local sources must be included in the job's source-hash map. Unresolved nonstandard project imports and G1 import names are refused. Standard package imports remain the explicitly trusted, reused dependency boundary.
4. The child PATH is set explicitly to the pinned toolchain and standard system paths, so the replay checker's child Lean uses the intended executable. It is recorded in the receipt.
5. An axiom report source must contain exactly the module import and the job's declared #print axioms commands. Those targets must equal the comparison's report-target list and the actual own-source public theorem inventory, within the pinned module target index. The data module instead reports all 19 explicit data declarations from that index. The runner parses the actual named output, requires every named target exactly once, and rejects any axiom outside propext, Classical.choice and Quot.sound. The full raw log remains evidence; a compiler exit code alone is not the axiom verdict.
6. The remaining batch time is recomputed immediately before launching the child. Library entry counts before and after and the traversed project source closure are recorded.
7. A malformed or incomplete strict replay report produces an explicit failed receipt rather than an accepted result.

No live REVIEW_ACCEPTANCE.json, bound template, development deadline or concrete execution job is created by the preparation packet. Its example acceptance has null decisions and no accepted job hashes. The prospective runner cannot pass those gates as shipped. Resource observations in the input freeze are read-only historical preflight, not a current execution reservation.
