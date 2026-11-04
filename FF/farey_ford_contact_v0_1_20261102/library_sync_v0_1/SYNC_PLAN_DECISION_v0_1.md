# FF-1 library sync plan: decision

2026-11-03. Skeleton seat (Claude Opus 5.5), under saphir's go ("Go") and saphir's sync authorization (#1436, `a47a92c1…`), whose conditions are met (#1440 fidelity, #1442 integration). Answers #1443.

**Matched:** `SYNC_PLAN_v0_1.md` `588d7a17…` (read in full), `SYNC_INPUT_PINS_v0_1.json` `383a0e17…`. The eleven listed sources equal the audited integration sources (`INTEGRATION_AUDIT_v0_1.md` `3ae4aff5…`).

**Decision: ACCEPT the plan, with these settings:**

1. **Single publication writer: the "Rule 30 tooling discussion" session** (`local_74e563f3-3a53-456a-8be6-a86287549380`). It built the shared library through v19, and saphir's standing rule routes verified Lean deliveries there. Neither the formalization owner nor skeleton writes a version.
2. **Scope:** exactly the eleven sources. The 60 targets and 12 bridge links stay unchanged. There are no new theorems, no smoke drivers and no proof attempts.
3. **The plan's safeguards are adopted as conditions:**
   - discover the base and recheck it just before assembly, and stop on a concurrent advance;
   - no reservation of v20;
   - an additive, metadata-only assembler successor, with its diff reviewed;
   - the outer runner rejects any CHANGED or DROPPED file and requires the added set to be exactly the eleven;
   - inherited source and kit hashes are compared against the base;
   - the `_v16tool` resolver is not used;
   - no G1 dependency;
   - no writes into frozen bases or through links;
   - a bounded runner with limits stated and no compute on Neo;
   - the full AxiomCheck over the library on **nucleus, scout and membrane**, with matching reports;
   - each new version frozen read-only on every host with 0 writable files, and checksums rechecked after freezing.
4. **Membrane:** its mirror was at v17. The new version is added there alongside the existing ones; nothing older is rewritten. Its Tailscale address is verified before use.
5. **Provenance:**
   - the historical semantic reference stays v3.3.1;
   - kernel v3.4.0 text compatibility is recorded in `KERNEL_V3_4_0_COMPATIBILITY_NOTE.md`: II.5 is byte-identical;
   - credits: FVLT assembled by Robin Miller; Codex as producer; skeleton (Claude Opus 5.5) as independent verifier; the fidelity review by an independent verifier subagent; no novelty claims for classical results.
6. **Readiness:** after the writer's three-host receipt, skeleton independently checks all three hosts:
   - `sha256sum -c`;
   - the axioms check;
   - `find -writable` = 0;
   - the eleven sources byte-identical to the audited ones.

   Then skeleton posts the readiness receipt. No readiness on the first successful host alone.

Not covered: kernel adoption, release, commits, viewer changes, Stage B, FF-2, FF-3.
