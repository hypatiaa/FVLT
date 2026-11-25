# Build brief: v0.3 step 2, fix round after VERIFY (F1, F2, F4, F5, F6)

Author: Claude Fable 5.1 (saphir's session), 2026-10-14. Decisions: saphir, "go with your leans", on the dispositions in `NOTE_v0_3_step1_for_owner_20261014.md`. Verifier report: `../FOURIER_VIEWER_PROTOTYPE_v0_3_VERIFY_20261014/VERIFY.md`. Same ground rules as `BUILD_BRIEF_v0_3_CONTINUOUS_N_20261014.md` §0 (this folder only; never touch the v0.2 folder; no git writes; no PowerShell in deployables; no Python on stdin; registers; never loosen a test to pass; stop and report if an item cannot be met).

## Items

1. **F1, φ₃ drawer (owner decision: drawer).** Remove the always-visible φ₃ box from the φ₃ row. Make the φ₃ label a chip like α / n₆ / m: tapping it opens a drawer with ◀ exact box ▶ (decimal or fraction; Enter applies; refused with reason outside 0 … B+1). The drawer is available in both modes (in integer mode the box accepts integers only, refusing a fraction with the reason "N integer mode: φ₃ must be an integer; switch to N∈ℚ for fractions"). The slider, ⏮, ◀ ▶ and the N∈ℤ/N∈ℚ toggle stay on the row. Result to assert: visible controls in the instrument panel ≤ 40 in BOTH modes (make the existing cap check run in continuous mode too), and the φ₃ slider at 375 px is at least as wide as the s slider minus the width of the toggle (measure; report the number).

2. **F2, phone first screen between shells (owner decision: shorten, do not accept the scroll).**
   - The per-tab warning line between shells becomes the short form **"between shells: shell arithmetic undefined"** (one line at 375 px, never ellipsized). The fraction stays visible in the shell readout ("N = 11/4") and in every card, where the full handoff wording **"between shells: N = p/q; shell arithmetic undefined"** remains verbatim. Record this split in `SCHEMA_ADDENDUM_8.md` as an amendment (marked "amended 2026-10-14, saphir F2"), do not rewrite the original text.
   - The SPREAD-refusal sentence ("SPREAD needs an integer gearbox: N = p/q") moves from its own line under the view to the s-row stepper message, where other 4e refusals are shown; it appears when a step is refused and in the s ⓘ text, not permanently under the view.
   - Then assert the first-screen rule at 375×812 in continuous mode between shells on all four tabs (view frame, φ₃ row, s row, transport visible, nothing opened), at the state N = 11/4 (B = 24, φ₃ = 89/4), m = 2 and also m = 5. If Clifford or Hopf still overflow after the two changes, do NOT loosen the check: report the exact pixel overflow per tab and stop on this item; saphir then decides about those two tabs.

3. **F6.** The page's `fv-build-pins` block gets its own id `fv-comb-hopf-build/0.1` (it must no longer share `fv-comb-hopf/0.2` with the exact export). Update `build/package.cjs` and any check that reads the block; add a browser assertion that the three ids (build pins, exact export, state export) are pairwise distinct.

4. **F4.** `host-core/comb-numeric.js` line ~118 comment: `(1+ln N)` → `(1+|ln N|)`, consistent with the code, the README and addendum 8.

5. **F5.** README v0.3 sections state the container formula C = 2·q·a·L_k for N = a/b with one sentence of derivation (exponent of e^{iπ·k·s/N} lies in (1/(L_k·q·a))·ℤ) and the convention label; `host-core/comb-core.js` comment lines ~266–268 updated from the integer-N description to the general one.

6. **BUILD_REPORT.** Append a section "v0.3 step 2: fix round after VERIFY (2026-10-14)" with: the F1–F6 dispositions, files changed with line references, one observation line per new or changed check, the measured first-screen bottoms at 375×812 per tab in integer mode, in continuous mode on a shell, and between shells (before and after this round; the verifier measured 882 Fourier / 943 Clifford and Hopf before), the slider width, and the verbatim summary lines of every suite. Correct the step-1 section's single Fourier number by adding a one-line marked correction, not by rewriting it.

7. **Tests that may change and why.** Browser assertions that match the old long warning-line text or the SPREAD line under the view must change to the new placement; say so per assertion in the report. Nothing else may be weakened. Add: cap ≤ 40 in continuous mode; first screen between shells on four tabs; drawer opens/closes and the box applies 89/4; integer-mode fraction refusal; distinct ids.

## Commands (all must pass)

`node exact-lib/test-exact.cjs`, `node host-core/test-core.cjs`, `node host-core/parity-sample.cjs`, `node build/package.cjs`, `node build/contrast-check.cjs`, `node build/browser-check.cjs`, `sha256sum -c dist/MANIFEST.sha256`. Report the sha256 of `dist/comb-hopf.html` and `dist/MANIFEST.sha256` after the build. The integer-mode test-core PASS lines must still be verbatim the 134 of v0.2 (diff them).

## Report shape

Verbatim suite lines; files changed with line references; one observation line per new or changed check; the pixel measurements; anything not met and why (item 2 may legitimately stop); pins. Do not write a verifier's report.
