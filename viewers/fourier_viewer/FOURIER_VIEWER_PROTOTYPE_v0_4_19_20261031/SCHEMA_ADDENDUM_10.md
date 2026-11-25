# SCHEMA ADDENDUM 10: comb-hopf v0.4.2 (2026-10-19)

**Status:** builder's record for v0.4.2, an additive successor of v0.4.1 in its own folder. It is not reviewed yet.

**Credits:**
- saphir: the decision ("fix both in one small successor, v0.4.2. I like your leans.");
- the v0.4.1 build report: both defects (SCHEMA_ADDENDUM_9 §1, "Not changed (pre-existing, recorded here)" and "Interaction, unchanged rule"; BUILD_REPORT "v0.4.1", items 1 and 2 of "Not done, observations, for decision");
- Claude Opus 5.5: v0.4.2.

**Amends:** SCHEMA_ADDENDUM_9 §1 (the N = 0 Wilson label and the shell-switch clamp rule). Everything else stands.

**Schema ids are unchanged:** address `fv-comb-hopf/0.2`, the state, exact, Lift and pair schemas, and the build-pins schema `fv-comb-hopf-build/0.1`. The build pins read `viewer: "comb-hopf v0.4.2"`. No field was added or removed; the address and state format is unchanged (tested).

## 1. The N = 0 Wilson wording (exact register)

At N = 0 (φ₃ = B + 1, on any shell, in either N mode) there is no comb, so the shell-N Wilson test has nothing to test. v0.4.1 labelled that state "N = 1 is not prime." It now says so.

| Where | v0.4.1 at N = 0 | v0.4.2 at N = 0 |
|---|---|---|
| exact export, field `exact.wilsonN` | `"N = 1 is not prime."` | `"N = 0: no comb, so the Wilson test does not apply."` |
| Wilson card, "Shell-N primality (Wilson test on N)" line | N = 1 is not prime. | N = 0: no comb, so the Wilson test does not apply. |
| stats export, line `Wilson shell-N: …` | Wilson shell-N: N = 1 is not prime. | Wilson shell-N: N = 0: no comb, so the Wilson test does not apply. |
| internal readout record `readouts().wilsonN` (not exported) | `{checked: true, prime: false, residue: 0n, label: …}` | `{checked: false, prime: null, residue: null, label: …}` |

- **One source.** All of these read the single function `wilsonN(N)` in `host-core/comb-core.js`; v0.4.2 adds one line there, the N = 0 branch. The N = 1 label "N = 1 is not prime." is unchanged.
- **The internal record.** Its fields `checked`, `prime` and `residue` now follow the pattern the module already uses for "not evaluated" (above N = 10,000, and between shells): `checked: false`, `prime: null`, `residue: null`. They appear in no export and no readout text. Nothing in the code reads them at N = 0 (searched). They are listed here because the test compares the record field by field.
- **Not carried elsewhere.** The PNG caption, the drawing, the CSV, the state export and the Lift JSON never carried the Wilson label; they are unchanged at N = 0 too (tested on the page, PNG by sha256).
- **Derived consequence.** The pair export records the sha256 of the exact export, so at N = 0 the pair's `exact.sha256` changes with it. The pair format is unchanged.
- **Wording choice.** It follows the neighbouring readouts: the label is a sentence that starts "N = 0:" like the empty-state reason ("N = 0: the Fourier comb has no angular denominator, so no walk is defined."), and ends with a period like the other Wilson labels.

**Scope (tested, `host-core/test-v042.cjs`):** for every state with N ≠ 0, every export and readout is byte-identical to v0.4.1 (and to v0.4 for the states v0.4 accepts). For every state with N = 0, the differences are exactly these named fields, and no others:
`exportExact.exact.wilsonN` (also with the order-m witness set), `readouts.wilsonN.label`, `readouts.wilsonN.checked`, `readouts.wilsonN.prime`, `readouts.wilsonN.residue`.

## 2. The shell-switch clamp (interaction only)

| | v0.4.1 | v0.4.2 |
|---|---|---|
| Shell switch (n₁ select, ◀ n₁ ▶, factorial ↔ integer mode, M box) when the current φ₃ > new B + 1 | φ₃ := B + 1, so N = 0 (the empty state) | **φ₃ := B, so N = 1** |
| Shell switch when φ₃ ≤ new B + 1 | φ₃ kept | φ₃ kept (unchanged) |

- **One rule for both N modes.** The clamp is the single function `clampPhi` in `instruments/comb-hopf/panel.js`. It compares φ₃ with B + 1 exactly (φ₃ may be a rational in continuous mode) and is used in both N modes, so the change applies in continuous mode as well. There is no separate continuous-mode clamp. In continuous mode the clamped value is the integer shell φ₃ = B.
- **Examples.** From the default state (n₁ = 4, φ₃ = 23, N = 2), picking n₁ = 1 gives φ₃ = 1 (N = 1); picking n₁ = 2 gives φ₃ = 2 (N = 1). From the default, integer mode then M box 1 gives B = 1, φ₃ = 1 (N = 1).
- **N = 0 is still a valid state.** It is chosen directly with φ₃ = B + 1: the φ₃ box, the N − 1 arrow ◀ or the slider at its maximum.
- **Boundary, as specified.** The rule fires only when φ₃ is above the new range. Default → n₁ = 2 (φ₃ = 2, N = 1) → n₁ = 1 keeps φ₃ = 2, which is B + 1 on the new shell, so it lands on N = 0. This is recorded, not changed (BUILD_REPORT "v0.4.2", for decision).
- **States and their outputs are unchanged.** Only which state a shell switch produces has changed. Every other transition gives the same state as on the v0.4.1 page (tested over a transition battery on both pages, `build/browser-check-v042.cjs`).

## 3. Tests of record

- `host-core/test-v042.cjs`:
  - the wording on every shell in both N modes;
  - the source scope: one line added in comb-core.js, two lines of clampPhi changed in panel.js, every other module byte-identical;
  - the field-level comparison with v0.4.1 over the 408-state grid plus the 1,600 random states, and over the 3,480 B = 1, 2 states;
  - the adapted v0.4.1 "unchanged states" assertion against v0.4;
  - address and schema-constant identity.
- `build/browser-check-v042.cjs`, at 375×812 and 1280×800:
  - n₁ = 1 and n₁ = 2 from the default (both N modes), and integer B = 1, each landing on N = 1, with the v0.4.1 page as control;
  - N = 0 still reachable directly;
  - the transition battery;
  - the page outputs (cards, drawing, stats, exact, state, CSV, Lift, PNG sha256) against the v0.4.1 page;
  - the screenshots `shot_v042_*`.
- `host-core/test-v041.cjs` runs unchanged. Its "unchanged states" assertion (0 differences against v0.4, N = 0 included) fails by design at the 62 N = 0 states. The adapted assertion is in `test-v042.cjs`.
