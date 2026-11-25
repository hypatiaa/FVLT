# Schema addendum 6: v0.2 Release A, the original flow without the clutter

Date: 2026-10-13. Owner: Opus (B1-viewer owner session). This governs over SCHEMA.md and addenda 1–5 where they differ.

## Authority

saphir, 2026-10-13:
- "I want to keep the base functionality of the entire instrument, but simplify it."
- "I really liked the design of the original. it flowed. but it was getting too busy."
- On the eight questions of `FUNCTIONALITY_LEDGER.md` §4: "all leans". That is the owner's recommended answer to each, in the owner's chat:
  1. Yes: the gearbox row (α, n₆, t₁, t₂, m) sits above the view as compact chips with drawers.
  2. Yes: remove the Presets/Continuous switch.
  3. Drop the pinch markers.
  4. **The owner's lean, which differs from the ledger's recommendation:**
     - Drop the float entropy/regime readouts.
     - Keep the noise minima, repaired: rank them on the normalized residual Q-res/ρ, mark the entries that come from the endpoint convention, and label them numerical.
     - This is Wren's §6 lesson, relayed by Idea Catalog. The minima arrive in Release B with the trail.
  5. Yes: Stack is one choice (none / rosette / full / fraction).
  6. Yes: weaves, meridian sweep, η leaf sweep and c₀ foliation are all kept, behind Advanced, in Release C.
  7. Yes: build the paired mirror (M−/M+, theorem guard, joint degeneracy), behind Advanced in the Wilson card, in Release C.
  8. Drop the Wolfram Alpha link. Replace it with "Copy formula", which copies the live formula as text.

## Release A scope

Release A is `FUNCTIONALITY_LEDGER.md` §3 "Release A", all 44 items, built in the ledger's inner order:
1. layout order and the phone stack;
2. gearbox chips with drawers, deleting the lanes;
3. Layers and Camera menus;
4. caption cuts and moves behind ⓘ;
5. the Export ▾ menu;
6. orbit-core and the cyclotomic line (addendum 5; already built in v0.1.1);
7. Lift JSON 0.2 (v0.1.1).

The target layout is ledger §2.3 to §2.5:
- **Order:** header → shell row → gearbox chips → view row → view → Layers/Camera strip → φ₃ row → s row → transport → Export ▾; cards on the right on desktop and below on a phone.
- **Phone:** on a 375×812 phone, the view, both sliders and the transport are on the first screen.
- **Control count:** at most about 40 visible controls in any view.

## Clarifications from the owner

- **Spin readout (ledger L3).** s_typed is always shown. s_eff is shown, labelled, whenever it differs from s_typed (R21.2 requires this). E is shown in the s row's ⓘ, and also on the surface whenever the R21 range has been widened beyond N. R21 is unchanged: s_typed, s_eff and E all stay in the state address and in the exports.
- **Shared library.** Switch the page to exact-lib 0.2.0 (`C:/Users/robin/s6_atom/FOURIER_VIEWER_LIBS/exact-lib-0.2.0/dist/exact-lib.js`, sha256 `3edfc8fb396fda90cfa945963eb18ccdf243f5a491e3ee49275b5c459a223a71`, verified):
  - Inline it as the page's exact library and record it in fv-build-pins (R13a).
  - The prototype's own `exact-lib/exact.js` 0.1 stays in the folder as history, but is no longer inlined.
  - All suites must pass on 0.2.0.
- **Text floor.** The minimum rendered font is exactly ≥ 13 px at 375 px. The delta verifier measured 12.9992 px. Fix it at the source with a `max()` or clamp, not by loosening the check.
- **Kept from v0.1:**
  - the dark palette;
  - the large type and the A−/A+ control;
  - the ⓘ "About this view" boxes;
  - the touch targets of at least 40 px;
  - all R20/R21 behaviour;
  - all tests.

  The compact chips use smaller padding, not smaller text.

## Not in Release A

- **Release B:** stacks, trail with repaired minima, stems, dots, marker size, resident c = ±1, the full Shell card.
- **Release C:** weaves, sweeps, c₀ foliation, paired mirror.

Both need extraction step 2, the remaining host-core libraries.
