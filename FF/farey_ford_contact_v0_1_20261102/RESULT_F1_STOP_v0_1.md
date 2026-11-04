# FF-1 F1: compile stop, v0.1

2026-11-03. **F1 FAIL / STOPPED.** Neither geometric theorem has been checked. No F2 or remaining Stage A work starts under this run. A parser/import failure is not a mathematical counterexample, but it is a build failure and triggers the explicit stop rule.

## Governing inputs and authorization

Exact order v0.3 `43560b88ab50dc77d8e222562f83bad68c8ba17d12a073523a99597a484d6fdd`, execution-go record `c9b4376a9799f3f5b4bb02086536fa5d4fb5a54631e9f89dba9e2d87d0594860`, E1, owner acceptance review, accepted input/signature freezes and C1 `aff6deaad1722776f406aafc09e6457f5bac94f5a1d82e3d542274e35a2c5f83` apply. I3 template acceptance `88b9a06138370b4739c54eba9f1622ebdbd4f94a1c5e7084f30db2d46711ce1a` accepts template `45c7d8bf2046298f2f7d9e428e90ce173391050156e77f526c8da5cedd10c274` and owner concrete-manifest acceptance under it.

Library v19 and complete input pins remain those in `INPUT_FREEZE_DRAFT_v0_1.md` and `INPUT_OBSERVATIONS_v0_1.json`. Fresh nucleus preflight at 10:52:41Z found 28970 MiB available and zero load averages. All runtime used explicit Tailscale `100.105.106.41`, 1 CPU, nice 19, 8 GiB address-space cap, 240 seconds per call, and the accepted runner v0.2 `c14f263caa77643e653f12fe63a3cda1bfdfa5024cfab97d2eadf5d2c6a59590`. Each receipt records the executable hash and fully expanded LEAN_PATH.

## Exact runs

| Run | Source set / outcome | Wall | Peak child RSS |
|---|---|---|---|
| F1ACompile01 | Initial arithmetic definitions, `import Mathlib`; missing imported `Mathlib/Analysis/Distribution/SchwartzSpace/Basic.olean` at line 1:0; exit 1 | 2.871512 s | 1572484 KiB |
| F1ACompile02 | Import-only successor uses `Mathlib.Data.Rat.Defs`; parser error in `fareyAdj`: `unexpected token '\|'; expected term` at line 11:32; exit 1 | 0.716789 s | 1535316 KiB |

No timeouts. The first is a dependency/path infrastructure fault before own declarations, handled under the explicit tooling-fault exception. The second is an ordinary declaration-level parsing diagnostic; **stop rule applied**, no further repair or recompile attempted. The narrower-import successor changed no definition body or frozen theorem header. This was not a retry of a failed mathematical proof. The final stop still applies regardless of whether a future import adjustment can fix the parser.

Initial sources are in `F1_snapshots/F1ACompile01/`:

- arithmetic `e11ada278bb2b8ab43116260d8d661e563684e69b245b8a22d552b157a650868`;
- geometry `803b13dea032ec57190814a162e14faf638e2b48e11cfadeb0b394ef10e8a49d`.

Import-only successors are preserved in `F1_snapshots/F1ACompile02/` and current root:

- arithmetic `944c8fbfe97372545419aef91cfdfdcadfdbeb1bc8cc02de96d82bff797b2639`;
- geometry `9639b87bb6e0c1fc532054c6b390507a2b8412dc61751774237438fcb6753567`.

The two geometry headers were checked verbatim against the frozen signature strings before both source acceptances. Only the arithmetic module was invoked. Geometry, its proof bodies, axiom reports, strict checker and all acceptance tests requiring them remain **NOT RUN / NOT ESTABLISHED**. No PASS or independent verification is claimed.

Concrete manifest hashes:

- `JOB_F1ACompile01.json`: `b8b0b1f6878d6e5bfa64b2b445ae31d2e771b9302f958ed4162e69364cc569a7`;
- `JOB_F1ACompile02.json`: `e3de00940b4cb1eecc9a6414e46951defd34f117bfa5ebee94b79c73e964af2f`.

Snapshots contain their owner acceptance records. Raw compiler logs, run receipts, and complete after-call library checksum logs are included. Both after-call checks returned exit 0. Sources stayed unchanged during calls. Historical source bytes are retained; no dependency was built, fetched, or altered. Final after-stop mode inspection found no writable regular files or directories. The broad `find -perm` receipt also lists the known documentation symlink because symlink mode bits are different from its target's permissions; the separate mode-details receipt confirms the resolved target is read-only. Top-level library hashes are unchanged.

## Timing and next decision

Drafting started unix 1793701924. Recorded manager-acceptance wait 1793701971–1793702314 (343 seconds) was excluded as C1 requires. F1 active deadline was unix 1793704067. Both calls completed well inside that deadline. The remainder of this phase is evidence packaging only; it does not extend proof execution.

Opus should audit these exact artifacts and decide whether to authorize an additive import/parser repair successor, or close F1 at this stop. Any renewed run must preserve both failures and respect the frozen propositions and reviewed scope/caps. This report does not authorize a repair or F2. FF-2 waits for the agreed FF-1 Stage A delivery/disposition; its design acceptance and conditional go do not bypass this stop. Opus owns the separate SCD study at Robin's direction.

Excluded throughout: Stage B, FF-1/FF-2 library synchronization, commits, Neo mathematical compute, G1, S4r-C and viewer edits.
