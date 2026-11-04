# FF-2 job template draft v0.1

Status: preparation only, not executable or accepted. Requires the complete reviewed input/signature freezes and a pinned runner before binding a job.

## Fixed scope

Parts A1–A8 and B1–B2 of WORK_ORDER_v0_3.md only. No Part C, FF-3 builds, library publication, viewer edits, G1 dependency, new axioms, sorry or native_decide. All mathematical execution on nucleus over Tailscale. Local work is limited to text, hashes and orchestration.

## Required binding fields

- Job ID, purpose, start permission and reviewer receipt.
- Full input packet manifest hash, signature freeze hash and source hashes.
- Exact current library version, complete checksum list and manifest hashes; toolchain and dependency manifest hashes. Stop for review if latest version differs from the accepted binding.
- Import closure, with a mechanically checked no-G1 condition for this delivery. Do not call importing a whole library equivalent to avoiding a dependency.
- Runner path/hash, checker source/hash and invocation; explicit ordered list of modules and expected declarations when known.
- Fresh isolated source/build/output paths, separate from the immutable library. No global LEAN_PATH mutation; no dependency writes or cold cache build.
- Resource reservation: one owner, one build process, one CPU job, maximum 8 GiB address-space/Lean memory budget, maximum 240 seconds per Lean/checker child, maximum 1800 seconds wall time per bound development batch including staging. These are proposed limits pending reviewer acceptance and measured feasibility.
- Fresh per-job time origin; exact exit codes and process-group termination on timeout. Never kill a shared kernel or unrelated process.

## Checks and failure policy

Before staging and after each child: full library checksums, relevant source pins and unchanged guard records. No dependent compile after a prerequisite failure. Keep failed sources/logs as additive attempts. Proof-body development can iterate within accepted frozen signatures; a changed signature returns to review. A genuine final proof/check failure stops the affected acceptance line.

Separate source compile, named theorem axiom reports, and strict all-constant kernel replay into distinct records. Check every constant introduced by each new module, including private helpers and generated declarations. Report only the actual replay result and standard axioms; do not infer strict replay from compilation or the library AxiomCheck scanner.

## Outputs

Per-call manifests, measured timings, raw logs and exits; all source/object hashes; explicit-binder signature comparison; complete theorem/fidelity pairing against instrument-tier source lines; source audit; fresh strict replay; final bounded report separating general theorems, finite examples, implementation correspondence and open realization claims. Forward the completed delivery for independent Skeleton verification. No automatic readiness, kernel standing or library sync follows.
