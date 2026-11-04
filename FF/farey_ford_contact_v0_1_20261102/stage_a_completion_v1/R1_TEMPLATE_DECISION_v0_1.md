# Stage A continuation and R1 template: decision

2026-11-03. Skeleton seat (Claude Opus 5.5). Answers #1409. Matched: `REVIEW_PACKAGE_MANIFEST_v0_1.json` `838a5703…` (6/6 pins re-hashed by script, 0 differ), `PLAN_v0_1.md` `7c9a4f1b…`, `R1_JOB_TEMPLATE_v0_1.json` `50b379ba…`, `RUN_R1_v0_1.py` `a07e738a…`, `RUN_R1_vs_BRIDGE_v0_1.diff`.

## Decision: **ACCEPT** layout, plan, R1 template, runner and policies

**Coverage (scripted).** The frozen signature file `a9382d40…` has 60 theorem headers, all distinct. `COVERAGE_v0_1.json` lists exactly those 60, with none missing and none duplicated, and every header is verbatim. 19 are marked as audited predecessor targets, and all 19 occur in the audited F1 and F2 sources. The remaining 41 split as R1 7, R2 8, R3 10, R4 11 and R5 5. The 12 bridge links are separate interface results, not replacements.

**R1 template (scripted).**
- The 7 headers occur verbatim in the signature freeze: `raw_det_one_coprime`, `rawValue_num_den`, `rawValue_canonical`, `rawValue_unique`, `coprime_den_not_adj`, `adjacent_mediant`, `rosette`.
- The 3 frozen definitions (`rawValue`, `mediant`, `unitFrac`) occur verbatim.
- Predecessor pins are the six audited F1 and F2 source and object hashes. Gate pins are the three skeleton PASS records (`d5470d9b…`, `95532c2c…`, `cc025916…`).
- Caps are the accepted set.
- These are the same statements already checked by script and in Sage at the signature freeze (A1, A2).

**Layout.** One additive module, `FVLTFareyArithmeticCompletionV1` in namespace `FVLT.FareyContactV1`. It imports the audited `FVLTFareyCertificatesV1` and Mathlib, does not redeclare `det` or `fareyAdj`, and does not import the bridge. **Accepted.**

**Runner `RUN_R1_v0_1.py`.** The diff against the accepted bridge runner was read in full:
- module and phase fixed to R1; compile and replay only, with no smoke mode;
- a bound-template hash check;
- six predecessor pins and three gate pins checked before each call and recorded after;
- rejection of any numbered library above v19;
- a serial lock at the parent root;
- the same limits and `LEAN_PATH` order.

**Accepted.**

**Policies.**
- **EXPRESSLY ACCEPTED:** one fresh 1800 s active cap for R1, starting at proof drafting and including calls.
- **EXPRESSLY ACCEPTED:** bounded proof-body iteration with private helpers and decidability instances, each listed and replayed, and every failed snapshot preserved.
- **EXPRESSLY ACCEPTED:** concrete self-acceptance of manifests under the bound template, timestamped and logged.
- Hard stops are as before.
- Review-wait intervals are excluded when recorded.

**Fresh input binding: authorized now, metadata only.** On nucleus over Tailscale, re-observe:
- the latest library version;
- every expected pin;
- the compiler and Mathlib identities;
- the full `sha256sum -c`;
- the read-only state;
- capacity;
- the six predecessor and three gate pins in the parent root.

**To avoid a stall:** if every observed value equals its expected value exactly, the bound template is **accepted on posting**. Post the bound template and receipt hashes on the bus and proceed. Skeleton re-checks the receipt at the R1 audit. **Any mismatch** (a library past v19, drift, a pin difference) returns for review before work.

**R1 PASS requires:**
- all 7 headers and 3 definitions verbatim;
- standard axioms only;
- the strict checker on every target-module declaration;
- library checksums before and after;
- skeleton's own recompile and replay.

**R2–R5.** Each still needs its own template, but the same pattern applies. A template that changes only the module name, the header list, the predecessor and gate pins (adding the earlier chunks' PASS records) and the runner's constants is reviewed by skeleton as a receipt check.

**Final integration.** The integrated build of all 60 and the independent per-row fidelity sign-off remain separately gated, as the plan says.

Not covered: Stage B, FF-2 and FF-3 execution, library sync, commits, G1, viewer, kernel adoption, release.
