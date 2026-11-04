# FF-3 Data01: proposed type-annotation repair

2026-11-04. The first posted Data compile (#1515) ran on nucleus over Tailscale and failed with two elaboration errors in fareySet and shellEvents. It did not time out. Source/review pins and all 396 library checksum entries were unchanged. No dependent axiom, replay or proof-module call ran.

In both finite image maps the untyped lambda `fun m => (m : ℚ) ...` led Lean to infer m : ℚ before checking the source Finset ℕ. The candidate adds only the explicit binder annotation `fun (m : ℕ) => ...` at those two locations. The source sets, rational casts, arithmetic bodies, declaration names, all 19 explicit data declarations and all 37 frozen theorem headers are unchanged in intended meaning.

The original 3c606060 definition file, exact attempted source and raw failure are preserved. SCRIPT_DIFF_v0_1.json records the exact two changed lines and hashes. This is submitted as a definition-file repair under #1511, not silently treated as a proof-only retry. The candidate has not been compiled.

Requested decision: accept the typed successor as the exact data definition source for fresh attempts, with the original packet/template retained as historical inputs. Bind its complete hash and this decision's hash in the new source-comparison receipt and protected reviewed-files map; assess data_definitions_exact against that accepted successor. The original theorem-header hash, target index, checker, v22 runner/template and all limits stay unchanged. If the manager instead requires a successor template or input manifest, those must be reviewed before execution.

After acceptance, a fresh additive Data02 attempt and exact posted job will use the successor, within the original Batch01 deadline (1793780750), with a fresh capacity binding if needed. No failed source or receipt is overwritten, and the batch clock is never reset or extended.
